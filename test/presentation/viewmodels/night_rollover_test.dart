// S6.4 (P6.7; TD-057; ADR-019 §3.1, D1): when the night rolls over — with
// the app open (NightClock → followNight) or at a restart — only a
// never-saved draft moves: its night key is written through the autosave
// chain, a picked night still ahead is kept, and a saved plan's row is not
// written. An open candidates list follows the new night. Real SQLite (in
// memory); the clock crosses Ljubljana's mean solar noon (about 11:02 UTC).

import 'package:astroplan/core/time/clock.dart';
import 'package:astroplan/data/database/app_database.dart' show AppDatabase;
import 'package:astroplan/data/repositories/drift_equipment_repository.dart';
import 'package:astroplan/data/repositories/drift_location_repository.dart';
import 'package:astroplan/data/repositories/drift_session_repository.dart';
import 'package:astroplan/data/repositories/drift_target_repository.dart';
import 'package:astroplan/data/services/catalog_seeder.dart';
import 'package:astroplan/data/services/equipment_seeder.dart';
import 'package:astroplan/domain/models/astro_target.dart';
import 'package:astroplan/domain/models/calendar_date.dart';
import 'package:astroplan/domain/models/capture_block.dart';
import 'package:astroplan/domain/models/location_profile.dart' as domain;
import 'package:astroplan/domain/models/session.dart';
import 'package:astroplan/domain/repositories/weather_repository.dart';
import 'package:astroplan/presentation/screens/tonight/tonight_candidates_screen.dart';
import 'package:astroplan/presentation/shared/night_time_formatter.dart';
import 'package:astroplan/presentation/widgets/night_clock.dart';
import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../support/fake_device_time_zone.dart';
import '../../support/fake_location_service.dart';
import '../../support/fake_reverse_geocoder.dart';
import '../../support/no_snapshot_weather.dart';
import '../../support/planner_harness.dart';

class _Clock extends Clock {
  DateTime now = DateTime.utc(2026, 11, 10, 18); // the evening of 10 Nov
  @override
  DateTime nowUtc() => now;
}

class _NoForecast with NoSnapshotWeather implements WeatherRepository {}

/// Counts the candidates' evaluations (each reads every target once).
class _CountingTargets extends DriftTargetRepository {
  _CountingTargets(super.db);
  int reads = 0;
  @override
  Future<List<AstroTarget>> getAllTargets() {
    reads++;
    return super.getAllTargets();
  }
}

final _extra = CaptureBlock(
  frameType: FrameType.light,
  filterName: 'Ha',
  exposureTimeSeconds: 300,
  frameCount: 7,
);

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late AppDatabase db;
  late _Clock clock;
  late DriftSessionRepository sessions;

  final nov10 = CalendarDate(2026, 11, 10);
  final nov11 = CalendarDate(2026, 11, 11);

  /// After mean solar noon on [day]: tonight is [day]'s evening.
  void moveTo(int day) => clock.now = DateTime.utc(2026, 11, day, 13);

  setUp(() async {
    db = AppDatabase(NativeDatabase.memory());
    clock = _Clock();
    sessions = DriftSessionRepository(db, clock: clock);
    await CatalogSeeder(DriftTargetRepository(db)).seedIfNeeded();
    await EquipmentSeeder(DriftEquipmentRepository(db)).seedIfNeeded();
    final siteId = await DriftLocationRepository(db).insertLocation(
      domain.LocationProfile(
        id: 0,
        name: 'Ljubljana',
        latitude: 46.05,
        longitude: 14.51,
        elevation: 300,
        timeZoneId: 'Europe/Ljubljana',
      ),
    );
    SharedPreferences.setMockInitialValues({'activeLocationId': siteId});
  });

  tearDown(() => db.close());

  /// The app's graph on [db]; a second call is a restart.
  Future<PlannerHarness> boot({DriftTargetRepository? targets}) async {
    final vm = PlannerHarness(
      targets ?? DriftTargetRepository(db),
      DriftEquipmentRepository(db),
      _NoForecast(),
      DriftLocationRepository(db),
      locationService: FakeLocationService(),
      reverseGeocoder: FakeReverseGeocoder(),
      deviceTimeZone: FakeDeviceTimeZone(),
      clock: clock,
      sessionRepository: sessions,
    );
    await vm.ready;
    return vm;
  }

  Future<Session> stored(PlannerHarness vm) async =>
      (await sessions.get(vm.activeSessionId!))!;

  test('with the app open, a never-saved draft\'s night key follows the '
      'rollover, and the write is not an edit', () async {
    final vm = await boot();
    expect((await stored(vm)).eveningDate, nov10);

    moveTo(11);
    await vm.lifecycle.followNight();
    await vm.plan.idle;

    expect(vm.eveningDate, nov11);
    final after = await stored(vm);
    expect(after.eveningDate, nov11);
    expect(after.status, SessionStatus.draft);
    expect(vm.plan.hasUnsavedChanges, isFalse);
  });

  test('a saved plan\'s row is not written at the rollover (D1)', () async {
    final vm = await boot();
    await vm.saveSession();
    await vm.plan.idle;
    final before = await stored(vm);
    expect(before.status, SessionStatus.planned);

    moveTo(11);
    clock.now = clock.now.add(const Duration(minutes: 5));
    await vm.lifecycle.followNight();
    await vm.plan.idle;

    final after = await stored(vm);
    expect(after.eveningDate, nov10);
    expect(after.status, SessionStatus.planned);
    expect(after.updatedAtUtc, before.updatedAtUtc);
    expect(after.planSnapshot!.json, before.planSnapshot!.json);
  });

  test('a picked night still ahead is kept; once it has passed, the draft '
      'rolls forward to tonight', () async {
    final vm = await boot();
    await vm.setEveningDate(CalendarDate(2026, 11, 12));
    await vm.plan.idle;

    moveTo(11);
    await vm.lifecycle.followNight();
    await vm.plan.idle;
    expect(vm.eveningDate, CalendarDate(2026, 11, 12));
    expect((await stored(vm)).eveningDate, CalendarDate(2026, 11, 12));

    moveTo(13);
    await vm.lifecycle.followNight();
    await vm.plan.idle;
    expect(vm.plan.pickedNight, isNull);
    expect(vm.eveningDate, CalendarDate(2026, 11, 13));
    expect((await stored(vm)).eveningDate, CalendarDate(2026, 11, 13));
  });

  test('a past night picked while the app is open stays until tonight '
      'moves on', () async {
    final vm = await boot();
    await vm.setEveningDate(CalendarDate(2026, 11, 8));
    await vm.plan.idle;

    clock.now = clock.now.add(const Duration(minutes: 5)); // same night
    await vm.lifecycle.followNight();
    await vm.plan.idle;
    expect(vm.eveningDate, CalendarDate(2026, 11, 8), reason: 'the pick');
    expect((await stored(vm)).eveningDate, CalendarDate(2026, 11, 8));

    moveTo(11);
    await vm.lifecycle.followNight();
    await vm.plan.idle;
    expect(vm.eveningDate, nov11, reason: 'rolled forward at the rollover');
    expect((await stored(vm)).eveningDate, nov11);
  });

  test('an edit queued during the rollover lands after it, and both are '
      'kept', () async {
    final vm = await boot();
    final blocks = vm.captureBlocks.length;

    moveTo(11);
    final rollover = vm.lifecycle.followNight();
    final edit = vm.addCaptureBlock(_extra);
    await rollover;
    await edit;
    await vm.plan.idle;

    final after = await stored(vm);
    expect(after.eveningDate, nov11);
    expect(after.blocks, hasLength(blocks + 1));
    expect(after.blocks.last.frameCount, 7);
  });

  test('at a restart, a never-saved draft\'s rolled-forward night is stored '
      'at once; a saved plan\'s is not', () async {
    final draft = await boot();
    final draftId = draft.activeSessionId!;
    moveTo(11);
    final restarted = await boot();
    await restarted.plan.idle;
    expect(restarted.activeSessionId, draftId);
    expect(restarted.eveningDate, nov11);
    expect((await sessions.get(draftId))!.eveningDate, nov11);

    await restarted.saveSession();
    await restarted.plan.idle;
    final saved = (await sessions.get(draftId))!;
    expect(saved.status, SessionStatus.planned);
    moveTo(12);
    final again = await boot();
    await again.plan.idle;
    expect(again.eveningDate, CalendarDate(2026, 11, 12), reason: 'as today');
    final after = (await sessions.get(draftId))!;
    expect(after.eveningDate, nov11, reason: 'not written (D1)');
    expect(after.updatedAtUtc, saved.updatedAtUtc);
  });

  testWidgets(
    "NightClock's minute tick makes the plan follow the night, before the "
    'forecast check',
    (tester) async {
      // The write itself is tested above through followNight. Here the plan
      // is kept in preferences (no session repository): a database write
      // started by a fake-time tick could not finish inside the test zone.
      late PlannerHarness vm;
      await tester.runAsync(() async {
        vm = PlannerHarness(
          DriftTargetRepository(db),
          DriftEquipmentRepository(db),
          _NoForecast(),
          DriftLocationRepository(db),
          locationService: FakeLocationService(),
          reverseGeocoder: FakeReverseGeocoder(),
          deviceTimeZone: FakeDeviceTimeZone(),
          clock: clock,
        );
        await vm.ready;
      });
      await tester.pumpWidget(
        MultiProvider(
          providers: vm.providers,
          child: const NightClock(child: SizedBox()),
        ),
      );
      await tester.pump(const Duration(minutes: 1)); // follows tonight once
      var told = 0;
      vm.plan.addListener(() => told++);

      await tester.pump(const Duration(minutes: 1));
      expect(told, 0, reason: 'the same night: nothing to say');

      moveTo(11);
      await tester.pump(const Duration(minutes: 1));
      expect(told, 1, reason: 'a new night');
      expect(vm.eveningDate, nov11);
    },
  );

  testWidgets('an open candidates list is evaluated again for the new night', (
    tester,
  ) async {
    final targets = _CountingTargets(db);
    late PlannerHarness vm;
    await tester.runAsync(() async => vm = await boot(targets: targets));
    await tester.pumpWidget(
      MultiProvider(
        providers: vm.providers,
        child: const MaterialApp(home: TonightCandidatesScreen()),
      ),
    );
    await tester.runAsync(() => Future<void>.delayed(Duration.zero));
    await tester.pump();
    final before = targets.reads;
    expect(before, greaterThan(0));

    moveTo(11);
    await tester.runAsync(() => vm.lifecycle.followNight());
    await tester.pump();

    expect(targets.reads, before + 1);
    final header = find.textContaining(
      'Night of ${NightTimeFormatter.eveningDate(nov11)}',
    );
    for (var i = 0; i < 40 && header.evaluate().isEmpty; i++) {
      await tester.runAsync(
        () => Future<void>.delayed(const Duration(milliseconds: 50)),
      );
      await tester.pump();
    }
    expect(header, findsWidgets, reason: 'the header follows the new night');
  });
}
