// TASK 11.4 (ADR-014 §3, §6): the planner works on a persisted draft
// session — every edit is in the database when the edit call returns, a
// rebuilt ViewModel (a restart) resumes it, the old preferences plan moves
// once into a draft, and New / Duplicate / Open follow the owner decisions.

import 'package:astroplan/core/time/clock.dart';
import 'package:astroplan/data/database/app_database.dart' show AppDatabase;
import 'package:astroplan/data/repositories/drift_equipment_repository.dart';
import 'package:astroplan/data/repositories/drift_location_repository.dart';
import 'package:astroplan/data/repositories/drift_session_repository.dart';
import 'package:astroplan/data/repositories/drift_target_repository.dart';
import 'package:astroplan/data/repositories/shared_prefs_planner_state_repository.dart';
import 'package:astroplan/data/services/catalog_seeder.dart';
import 'package:astroplan/data/services/equipment_seeder.dart';
import 'package:astroplan/domain/models/calendar_date.dart';
import 'package:astroplan/domain/models/capture_block.dart';
import 'package:astroplan/domain/models/location_profile.dart' as domain;
import 'package:astroplan/domain/models/session.dart';
import 'package:astroplan/domain/models/session_snapshot.dart';
import 'package:astroplan/domain/repositories/weather_repository.dart';

import '../../support/planner_harness.dart';

import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../support/fake_device_time_zone.dart';
import '../../support/fake_location_service.dart';
import '../../support/fake_reverse_geocoder.dart';
import '../../support/no_snapshot_weather.dart';

class _NoWeather with NoSnapshotWeather implements WeatherRepository {}

final _now = DateTime.utc(2026, 11, 10, 18); // evening of Nov 10 in Europe

CaptureBlock _light(int count) => CaptureBlock(
  frameType: FrameType.light,
  filterName: 'Ha',
  exposureTimeSeconds: 300,
  frameCount: count,
);

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late AppDatabase db;
  late DriftSessionRepository sessions;
  late int siteId;

  setUp(() async {
    db = AppDatabase(NativeDatabase.memory());
    await CatalogSeeder(DriftTargetRepository(db)).seedIfNeeded();
    await EquipmentSeeder(DriftEquipmentRepository(db)).seedIfNeeded();
    siteId = await DriftLocationRepository(db).insertLocation(
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
    sessions = DriftSessionRepository(db, clock: FixedClock(_now));
  });

  tearDown(() => db.close());

  /// A fresh ViewModel on the same database and preferences: a restart.
  Future<PlannerHarness> start({DateTime? now}) async {
    final vm = PlannerHarness(
      DriftTargetRepository(db),
      DriftEquipmentRepository(db),
      _NoWeather(),
      DriftLocationRepository(db),
      locationService: FakeLocationService(),
      reverseGeocoder: FakeReverseGeocoder(),
      deviceTimeZone: FakeDeviceTimeZone(),
      clock: FixedClock(now ?? _now),
      sessionRepository: sessions,
    );
    await vm.ready;
    return vm;
  }

  test('a first run creates one draft with the example plan; a restart '
      'resumes it', () async {
    final vm = await start();
    expect(vm.activeSession!.status, SessionStatus.draft);
    expect(vm.isExampleCapturePlan, isTrue);

    final again = await start();
    expect(again.activeSessionId, vm.activeSessionId);
    expect(again.isExampleCapturePlan, isTrue);
    expect(await sessions.list(), hasLength(1));
  });

  // S1.6 (RT-05 / UX-12; RD-05 interim): the planner knows when replacing
  // the current session would leave unsaved plan changes behind.
  group('unsaved changes', () {
    test('an untouched draft has none; an edit has; Save clears them; a '
        'restart keeps them', () async {
      final vm = await start();
      expect(vm.plan.hasUnsavedChanges, isFalse);
      expect((await start()).plan.hasUnsavedChanges, isFalse);

      await vm.addCaptureBlock(_light(3));
      expect(vm.plan.hasUnsavedChanges, isTrue);
      expect((await start()).plan.hasUnsavedChanges, isTrue);

      await vm.saveSession();
      expect(vm.plan.hasUnsavedChanges, isFalse);
      await vm.setEveningDate(CalendarDate(2026, 11, 12));
      expect(vm.plan.hasUnsavedChanges, isTrue);
      expect((await start()).plan.hasUnsavedChanges, isTrue);

      await vm.newSession();
      expect(vm.plan.hasUnsavedChanges, isFalse);
    });

    // S1.V3 (TD-061): every kind of plan edit stays protected after a
    // restart, not only block edits or saved plans.
    for (final kind in ['target', 'rig', 'night', 'blocks']) {
      test('a $kind-only edit is still unsaved after a restart', () async {
        final vm = await start();
        final original = vm.activeSessionId;
        switch (kind) {
          case 'target':
            final targets = await DriftTargetRepository(db).getAllTargets();
            await vm.setTarget(
              targets.firstWhere((t) => t.id != vm.selectedTarget!.id),
            );
          case 'rig':
            final rigs = DriftEquipmentRepository(db);
            final id = await rigs.insertEquipment(
              EquipmentSeeder.defaults.first,
            );
            await vm.setEquipment((await rigs.getEquipmentById(id))!);
          case 'night':
            await vm.setEveningDate(CalendarDate(2026, 11, 12));
          default:
            await vm.addCaptureBlock(_light(3));
        }
        await vm.plan.idle;
        expect(vm.plan.hasUnsavedChanges, isTrue);

        final restarted = await start();
        expect(restarted.activeSessionId, original);
        expect(restarted.plan.hasUnsavedChanges, isTrue);
      });
    }

    test('after Save, a restart has nothing unsaved; an untouched draft '
        'never has', () async {
      final vm = await start();
      await vm.setEveningDate(CalendarDate(2026, 11, 12));
      await vm.saveSession();
      expect((await start()).plan.hasUnsavedChanges, isFalse);

      await vm.newSession();
      await vm.plan.idle;
      expect((await start()).plan.hasUnsavedChanges, isFalse);
    });

    test('a site change is not an edit of the plan', () async {
      final vm = await start();
      await vm.site.setLocation(40.0, -3.7);
      await vm.plan.idle;
      expect(vm.plan.hasUnsavedChanges, isFalse);
    });

    test('a failed Save keeps the changes unsaved', () async {
      final failing = _FailingSave(db, clock: FixedClock(_now));
      final vm = PlannerHarness(
        DriftTargetRepository(db),
        DriftEquipmentRepository(db),
        _NoWeather(),
        DriftLocationRepository(db),
        locationService: FakeLocationService(),
        reverseGeocoder: FakeReverseGeocoder(),
        deviceTimeZone: FakeDeviceTimeZone(),
        clock: FixedClock(_now),
        sessionRepository: failing,
      );
      await vm.ready;
      await vm.addCaptureBlock(_light(3));
      await expectLater(vm.saveSession(), throwsA(isA<StateError>()));
      expect(vm.plan.hasUnsavedChanges, isTrue);
      expect((await start()).plan.hasUnsavedChanges, isTrue, reason: 'S1.V3');
    });
  });

  // S1.4 (ENG-05 = SCI-11 = RT-06; owner decision): without a site the
  // draft's night key is the default night at the default position, resolved
  // per ADR-007 — never the UTC calendar date (CLAUDE.md trap 2).
  test('without a site, the night key is not the UTC date', () async {
    SharedPreferences.setMockInitialValues({});
    // 01:30 UTC on Sep 22 is still the night of Sep 21 at the default
    // position (its mean solar noon is near 12:00 UTC).
    final vm = await start(now: DateTime.utc(2026, 9, 22, 1, 30));
    expect(vm.sessionNight, isNull, reason: 'no astronomy without a site');
    expect(vm.activeSession!.eveningDate, CalendarDate(2026, 9, 21));

    await vm.setEveningDate(CalendarDate(2026, 9, 25));
    expect(
      (await sessions.get(vm.activeSessionId!))!.eveningDate,
      CalendarDate(2026, 9, 25),
      reason: 'a picked date is kept',
    );
  });

  // Acceptance: force-stopping the app never loses edits.
  test('every edit is in the database when the call returns; a restart '
      'rebuilds the same plan', () async {
    final vm = await start();
    final targets = await DriftTargetRepository(db).getAllTargets();
    final other = targets.firstWhere((t) => t.id != vm.selectedTarget!.id);
    await vm.setTarget(other);
    await vm.addCaptureBlock(_light(42));
    await vm.setEveningDate(CalendarDate(2026, 11, 12));
    // No other await: the "force-stop" happens here.

    final restarted = await start();
    expect(restarted.activeSessionId, vm.activeSessionId);
    expect(restarted.selectedTarget!.id, other.id);
    expect(restarted.captureBlocks.last.frameCount, 42);
    expect(restarted.isExampleCapturePlan, isFalse);
    expect(restarted.eveningDate, CalendarDate(2026, 11, 12));
    final prefs = await SharedPreferences.getInstance();
    expect(prefs.containsKey('captureBlocks'), isFalse);
  });

  test('the preferences plan moves once into a draft and is removed', () async {
    final state = SharedPrefsPlannerStateRepository();
    await state.saveCaptureBlocks([_light(7)]);
    final targets = await DriftTargetRepository(db).getAllTargets();
    await state.setSelectedTargetId(targets[3].id);

    final vm = await start();
    expect(vm.captureBlocks.single.frameCount, 7);
    expect(vm.selectedTarget!.id, targets[3].id);
    final draft = (await sessions.get(vm.activeSessionId!))!;
    expect(draft.status, SessionStatus.draft);
    expect(draft.blocks.single.frameCount, 7);
    expect(draft.targetId, targets[3].id);
    final prefs = await SharedPreferences.getInstance();
    expect(prefs.containsKey('captureBlocks'), isFalse);
    expect(prefs.containsKey('targetId'), isFalse);

    final again = await start();
    expect(again.activeSessionId, vm.activeSessionId);
    expect(await sessions.list(), hasLength(1));
  });

  test('duplicate for another night: a new draft with the plan on that '
      'night; the original is unchanged', () async {
    final vm = await start();
    await vm.addCaptureBlock(_light(9));
    final original = vm.activeSessionId!;
    await vm.duplicateForNight(CalendarDate(2026, 11, 20));

    expect(vm.activeSessionId, isNot(original));
    final copy = (await sessions.get(vm.activeSessionId!))!;
    expect(copy.eveningDate, CalendarDate(2026, 11, 20));
    expect(copy.blocks.last.frameCount, 9);
    final kept = (await sessions.get(original))!;
    expect(kept.eveningDate, CalendarDate(2026, 11, 10));
  });

  test('a draft whose night has passed resumes on tonight; a future night '
      'is kept', () async {
    final vm = await start();
    await vm.setEveningDate(CalendarDate(2026, 11, 12));

    final sameDay = await start();
    expect(sameDay.eveningDate, CalendarDate(2026, 11, 12));

    // S6.4 (TD-057): the rolled-forward night of a never-saved draft is
    // stored at the restart, so a restart back on the same day (the old last
    // step) would now read 17 Nov; the order is reversed instead.
    final nextWeek = await start(now: DateTime.utc(2026, 11, 17, 18));
    expect(nextWeek.eveningDate, CalendarDate(2026, 11, 17));
    expect(nextWeek.activeSessionId, vm.activeSessionId);
    await nextWeek.plan.idle;
    expect(
      (await sessions.get(vm.activeSessionId!))!.eveningDate,
      CalendarDate(2026, 11, 17),
    );
  });

  test('New starts a draft for tonight with the example plan', () async {
    final vm = await start();
    await vm.addCaptureBlock(_light(3));
    await vm.setEveningDate(CalendarDate(2026, 11, 15));
    final previous = vm.activeSessionId!;

    await vm.newSession();
    expect(vm.activeSessionId, isNot(previous));
    expect(vm.isExampleCapturePlan, isTrue);
    expect(vm.eveningDate, CalendarDate(2026, 11, 10));
    expect((await sessions.get(previous))!.blocks.last.frameCount, 3);
  });

  test('editing after Save makes it a draft with unsaved changes; opening a '
      'completed session copies it into a new draft', () async {
    final vm = await start();
    final saved = await vm.saveSession();
    expect(saved.status, SessionStatus.planned);

    await vm.addCaptureBlock(_light(5));
    final edited = (await sessions.get(saved.id))!;
    expect(edited.status, SessionStatus.draft);
    expect(edited.plannedAtUtc, isNotNull, reason: 'listed as unsaved changes');

    final resaved = await vm.saveSession();
    await sessions.start(resaved.id, resaved.planSnapshot!);
    await sessions.complete(resaved.id);
    await vm.openSession((await sessions.get(resaved.id))!);
    expect(vm.activeSessionId, isNot(resaved.id));
    expect(vm.activeSession!.status, SessionStatus.draft);
    expect(vm.captureBlocks.last.frameCount, 5);
    expect((await sessions.get(resaved.id))!.status, SessionStatus.completed);
  });
}

/// Saving always fails (S1.6).
class _FailingSave extends DriftSessionRepository {
  _FailingSave(super.db, {super.clock});

  @override
  Future<Session> savePlan(
    int id,
    SessionPlan plan,
    SessionSnapshot snapshot,
  ) => Future.error(StateError('disk full'));
}
