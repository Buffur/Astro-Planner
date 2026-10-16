// S8.3 (ADR-019 §3.1, D1; D8-1, D8-2, I-3, I-8): the next day for a saved
// plan. Once its night has ended (dawn at the snapshot's darkness limit,
// CALC-44), a saved plan stays on its night, awaiting its result, and the
// planner continues on exactly one working copy — with the app open and
// after a restart. A Saved · changed plan's edits move to the copy. A
// failure moves nothing and the next check retries. Save before the night
// ends is Save again (D8-2). Tonight's line names the entry awaiting its
// result. Real SQLite (in memory); Ljubljana, 10 Nov 2026: astronomical dawn
// about 04:10 UTC on the 11th, mean solar noon about 11:02 UTC.

import 'package:astroplan/core/time/clock.dart';
import 'package:astroplan/data/database/app_database.dart' show AppDatabase;
import 'package:astroplan/data/repositories/drift_equipment_repository.dart';
import 'package:astroplan/data/repositories/drift_location_repository.dart';
import 'package:astroplan/data/repositories/drift_session_repository.dart';
import 'package:astroplan/data/repositories/drift_target_repository.dart';
import 'package:astroplan/data/services/catalog_seeder.dart';
import 'package:astroplan/data/services/equipment_seeder.dart';
import 'package:astroplan/domain/models/calendar_date.dart';
import 'package:astroplan/domain/models/capture_block.dart';
import 'package:astroplan/domain/models/location_profile.dart' as domain;
import 'package:astroplan/domain/models/session.dart';
import 'package:astroplan/domain/models/session_result.dart';
import 'package:astroplan/domain/repositories/storage_failure.dart';
import 'package:astroplan/domain/repositories/weather_repository.dart';
import 'package:astroplan/main.dart';
import 'package:astroplan/presentation/navigation/app_router.dart';
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

/// Fails the next session insert once, as a full disk would.
class _Flaky extends DriftSessionRepository {
  _Flaky(super.db, {super.clock});
  bool failNext = false;
  @override
  Future<Session> create(SessionPlan plan) {
    if (failNext) {
      failNext = false;
      throw const StorageFailure('disk full');
    }
    return super.create(plan);
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
  late _Flaky sessions;

  final nov10 = CalendarDate(2026, 11, 10);
  final nov11 = CalendarDate(2026, 11, 11);
  final nov12 = CalendarDate(2026, 11, 12);

  /// Before and after the 10 Nov night's dawn; after the next noon.
  void stillDark() => clock.now = DateTime.utc(2026, 11, 11, 3);
  void afterDawn() => clock.now = DateTime.utc(2026, 11, 11, 5);
  void afterNoon() => clock.now = DateTime.utc(2026, 11, 11, 13);

  setUp(() async {
    db = AppDatabase(NativeDatabase.memory());
    clock = _Clock();
    sessions = _Flaky(db, clock: clock);
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
  Future<PlannerHarness> boot() async {
    final vm = PlannerHarness(
      DriftTargetRepository(db),
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
    await vm.plan.idle;
    return vm;
  }

  Future<Session> savedFriday(PlannerHarness vm) async {
    await vm.choosePlan(); // S6.8: Save needs a target and a rig
    final s = await vm.saveSession();
    await vm.plan.idle;
    return s;
  }

  Future<List<Session>> open() => sessions.list(
    statuses: {SessionStatus.draft, SessionStatus.planned},
    includeLegacy: false,
  );

  test('with the app open: nothing moves before dawn; after it the saved plan '
      'stays on its night, unchanged, and exactly one untouched copy is '
      'current; at noon the copy rolls forward', () async {
    final vm = await boot();
    final saved = await savedFriday(vm);

    stillDark();
    await vm.lifecycle.followNight();
    await vm.plan.idle;
    expect(vm.activeSessionId, saved.id);

    afterDawn();
    await vm.lifecycle.followNight();
    await vm.plan.idle;
    final entry = (await sessions.get(saved.id))!;
    expect(entry.status, SessionStatus.planned);
    expect(entry.eveningDate, nov10);
    expect(entry.planSnapshot!.json, saved.planSnapshot!.json);
    expect(entry.updatedAtUtc, saved.updatedAtUtc);
    final copy = (await sessions.get(vm.activeSessionId!))!;
    expect(copy.id, isNot(saved.id));
    expect((copy.status, copy.plannedAtUtc), (SessionStatus.draft, null));
    expect(copy.targetId, saved.targetId);
    expect(copy.blocks.length, saved.blocks.length);
    expect(vm.plan.hasUnsavedChanges, isFalse, reason: 'an untouched copy');
    expect(await open(), hasLength(2));

    await vm.lifecycle.followNight(); // a repeat does nothing
    await vm.plan.idle;
    expect(await open(), hasLength(2));

    afterNoon();
    await vm.lifecycle.followNight();
    await vm.plan.idle;
    expect(vm.eveningDate, nov11);
    expect((await sessions.get(copy.id))!.eveningDate, nov11);
    expect((await sessions.get(saved.id))!.eveningDate, nov10);
  });

  test('after a restart: the same, once; a repeated restart makes no second '
      'copy', () async {
    final saved = await savedFriday(await boot());
    afterDawn();
    final restarted = await boot();
    expect(restarted.activeSessionId, isNot(saved.id));
    expect((await sessions.get(saved.id))!.status, SessionStatus.planned);
    final copyId = restarted.activeSessionId;
    final again = await boot();
    expect(again.activeSessionId, copyId);
    expect(await open(), hasLength(2));
  });

  test('Saved · changed: the edits (a later night, a block) move to the '
      'copy, which counts as unsaved; the entry is Saved on its night with '
      'its snapshot', () async {
    final vm = await boot();
    final saved = await savedFriday(vm);
    await vm.setEveningDate(nov12);
    await vm.addCaptureBlock(_extra);
    await vm.plan.idle;
    expect((await sessions.get(saved.id))!.isSavedChanged, isTrue);

    afterDawn();
    await vm.lifecycle.followNight();
    await vm.plan.idle;
    final entry = (await sessions.get(saved.id))!;
    expect(entry.status, SessionStatus.planned);
    expect(entry.eveningDate, nov10);
    expect(entry.blocks.length, saved.blocks.length);
    expect(entry.planSnapshot!.json, saved.planSnapshot!.json);
    final copy = (await sessions.get(vm.activeSessionId!))!;
    expect(copy.eveningDate, nov12, reason: 'the working night, still ahead');
    expect(copy.blocks.last.filterName, 'Ha');
    expect(vm.plan.hasUnsavedChanges, isTrue);
    expect(vm.eveningDate, nov12);
  });

  test('a storage failure at the transition moves nothing; the next check '
      'retries', () async {
    final vm = await boot();
    final saved = await savedFriday(vm);
    afterDawn();
    sessions.failNext = true;
    await vm.lifecycle.followNight();
    await vm.plan.idle;
    expect(vm.activeSessionId, saved.id);
    expect(await open(), hasLength(1));

    await vm.lifecycle.followNight();
    await vm.plan.idle;
    expect(vm.activeSessionId, isNot(saved.id));
    expect(await open(), hasLength(2));
  });

  test('D8-2: Save before the night ends replaces the snapshot, a changed '
      'night included; no second saved plan', () async {
    final vm = await boot();
    final saved = await savedFriday(vm);
    await vm.setEveningDate(nov12);
    await vm.plan.idle;
    final again = await vm.saveSession();
    await vm.plan.idle;
    expect(again.id, saved.id);
    expect(again.status, SessionStatus.planned);
    expect(again.planSnapshot!.eveningDate, nov12);
    expect(await open(), hasLength(1));
  });

  // TD-085 (S8V-01): Save tapped after dawn but before the next night
  // check (the minute tick) must not rewrite the ended entry (D8-2): Save
  // runs the night check first, so it writes the working copy.
  for (final changed in [false, true]) {
    test('TD-085: Save after dawn, before the next check, leaves the '
        '${changed ? 'Saved · changed' : 'Saved'} entry as it was and saves '
        'the working copy', () async {
      final vm = await boot();
      final saved = await savedFriday(vm);
      if (changed) {
        await vm.addCaptureBlock(_extra);
        await vm.plan.idle;
      }

      afterDawn(); // no followNight: the minute tick has not run yet
      final result = await vm.saveSession();
      await vm.plan.idle;

      final entry = (await sessions.get(saved.id))!;
      expect(entry.status, SessionStatus.planned);
      expect(entry.eveningDate, nov10);
      expect(entry.planSnapshot!.json, saved.planSnapshot!.json);
      expect(entry.blocks.length, saved.blocks.length);
      expect(result.id, isNot(saved.id));
      expect(result.status, SessionStatus.planned);
      expect(
        result.blocks.length,
        saved.blocks.length + (changed ? 1 : 0),
        reason: 'the working copy holds the edits',
      );
      expect(vm.activeSessionId, result.id);
      expect(await open(), hasLength(2));
    });
  }

  test('opening an ended saved plan opens a copy for tonight; the entry '
      'stays as it was', () async {
    final vm = await boot();
    final saved = await savedFriday(vm);
    afterNoon();
    await vm.lifecycle.followNight();
    await vm.plan.idle;
    final entry = (await sessions.get(saved.id))!;
    await vm.lifecycle.openSession(entry);
    await vm.plan.idle;
    expect(vm.activeSessionId, isNot(saved.id));
    expect(vm.eveningDate, nov11);
    expect((await sessions.get(saved.id))!.updatedAtUtc, entry.updatedAtUtc);
  });

  test('S8.7: Copy to another night makes a new, unsaved plan on that night '
      'from the entry; the entry stays as it was', () async {
    final vm = await boot();
    final saved = await savedFriday(vm);
    afterDawn();
    await vm.lifecycle.followNight();
    await vm.plan.idle;
    final entry = (await sessions.get(saved.id))!;
    await vm.lifecycle.openSession(entry, copyTo: nov12);
    await vm.plan.idle;
    final copy = (await sessions.get(vm.activeSessionId!))!;
    expect(copy.id, isNot(saved.id));
    expect((copy.status, copy.plannedAtUtc), (SessionStatus.draft, null));
    expect(copy.eveningDate, nov12);
    expect(copy.blocks.length, entry.blocks.length);
    expect(vm.plan.hasUnsavedChanges, isTrue, reason: 'W1: a copy');
    expect((await sessions.get(saved.id))!.updatedAtUtc, entry.updatedAtUtc);
  });

  test('Tonight\'s line names the entry once its night has ended, and is '
      'gone once its result is recorded', () async {
    final vm = await boot();
    final saved = await savedFriday(vm);
    await vm.vms.sessionList!.refreshDue();
    expect(vm.vms.sessionList!.dueResult, isNull, reason: 'the night is ahead');

    afterDawn();
    await vm.lifecycle.followNight();
    expect(vm.vms.sessionList!.dueResult?.id, saved.id);

    await vm.results!.load(saved.id);
    await vm.results!.save(const CompletedAsPlanned());
    expect(vm.vms.sessionList!.dueResult, isNull);
  });

  testWidgets('Tonight shows "Last night: …", which opens the result form', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(800, 2000);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);
    late PlannerHarness vm;
    await tester.runAsync(() async {
      vm = await boot();
      await savedFriday(vm);
      afterDawn();
      await vm.lifecycle.followNight();
      await vm.plan.idle;
    });
    AppRouter.router.go(AppRouter.tonight);
    await tester.pumpWidget(
      MultiProvider(providers: vm.providers, child: const AstroPlanApp()),
    );
    for (var i = 0; i < 6; i++) {
      await tester.runAsync(() => Future<void>.delayed(Duration.zero));
      await tester.pump(const Duration(milliseconds: 200));
    }
    final line = find.byKey(const Key('tonight.resultDue'));
    expect(line, findsOneWidget);
    expect(find.textContaining('Last night: '), findsOneWidget);
    await tester.tap(line);
    for (var i = 0; i < 6; i++) {
      await tester.runAsync(() => Future<void>.delayed(Duration.zero));
      await tester.pump(const Duration(milliseconds: 200));
    }
    expect(find.byKey(const Key('results.review')), findsOneWidget);
  });
}
