// Tests for PlannerHarness's evening-date state (TASK 2.4, ADR-007).
//
// The old test 'sessionDate defaults to today (UTC)' asserted TD-001 itself
// (the default matched the **UTC** calendar date) and was kept deliberately
// as a documented, known-wrong assertion until the fix landed (see
// docs/DECISIONS.md ADR-007, docs/TECH_DEBT.md TD-001). It is replaced below
// by 'the default night contains "now", not the UTC calendar date' — the
// same San Francisco 18:30 PDT case ADR-007 calls T1, which the old rule
// gets wrong by a full day (see the ADR's "Old code" column).
//
// Strategy:
//   - ViewModel tests inject a FixedClock and a real site (so
//     isDefaultLocation is false and sessionNight resolves), and wait on
//     `vm.ready` instead of sleeping.
//   - Downstream recalculation tests use VisibilityCalculator directly —
//     these are pure Dart functions with no platform-channel dependencies.

import 'package:flutter_test/flutter_test.dart';
import 'package:drift/native.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:astroplan/core/time/clock.dart';
import 'package:astroplan/data/database/app_database.dart';
import 'package:astroplan/data/repositories/drift_target_repository.dart';
import 'package:astroplan/data/repositories/drift_equipment_repository.dart';
import 'package:astroplan/data/repositories/drift_location_repository.dart';
import 'package:astroplan/domain/models/calendar_date.dart';
import 'package:astroplan/domain/models/location_profile.dart' as domain;
import 'package:astroplan/domain/models/session.dart';
import 'package:astroplan/domain/models/session_log.dart' as domain;
import 'package:astroplan/domain/repositories/weather_repository.dart';
import 'package:astroplan/domain/services/moon_calculator.dart';
import 'package:astroplan/domain/services/visibility_calculator.dart';

import '../../support/planner_harness.dart';

import '../../support/fake_location_service.dart';
import '../../support/no_snapshot_weather.dart';

class _MockWeather with NoSnapshotWeather implements WeatherRepository {}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('PlannerHarness evening date (TASK 2.4)', () {
    late AppDatabase database;
    late DriftLocationRepository locationRepo;
    late PlannerHarness vm;

    /// San Francisco (ADR-007 T1's site).
    const sfLat = 37.7749;
    const sfLon = -122.4194;

    Future<PlannerHarness> buildViewModel({
      required Clock clock,
      double latitude = sfLat,
      double longitude = sfLon,
    }) async {
      final locId = await locationRepo.insertLocation(
        domain.LocationProfile(
          id: 0,
          name: 'Test Site',
          latitude: latitude,
          longitude: longitude,
          elevation: 10,
        ),
      );
      SharedPreferences.setMockInitialValues({'activeLocationId': locId});

      final built = PlannerHarness(
        DriftTargetRepository(database),
        DriftEquipmentRepository(database),
        _MockWeather(),
        locationRepo,
        locationService: FakeLocationService(),
        clock: clock,
      );
      await built.ready;
      return built;
    }

    setUp(() {
      database = AppDatabase(NativeDatabase.memory());
      locationRepo = DriftLocationRepository(database);
    });

    tearDown(() async {
      await database.close();
    });

    test('the default night contains "now", not the UTC calendar date '
        '(TD-001, ADR-007 T1)', () async {
      // 18:30 PDT on 2026-09-21 = 2026-09-22 01:30 UTC. The UTC calendar
      // date is therefore the 22nd — the old rule showed that, a full
      // day late for this evening. The correct evening is the 21st.
      vm = await buildViewModel(
        clock: FixedClock(DateTime.utc(2026, 9, 22, 1, 30)),
      );

      expect(vm.eveningDate, CalendarDate(2026, 9, 21));
    });

    test('setEveningDate() changes the picked date', () async {
      vm = await buildViewModel(
        clock: FixedClock(DateTime.utc(2026, 9, 22, 1, 30)),
      );
      vm.setEveningDate(CalendarDate(2026, 10, 5));
      expect(vm.eveningDate, CalendarDate(2026, 10, 5));
    });

    test('setEveningDate() triggers notifyListeners()', () async {
      vm = await buildViewModel(
        clock: FixedClock(DateTime.utc(2026, 9, 22, 1, 30)),
      );
      var notified = false;
      vm.addListener(() => notified = true);
      vm.setEveningDate(CalendarDate(2026, 10, 6));
      expect(notified, isTrue);
    });

    test('a past evening date is accepted', () async {
      vm = await buildViewModel(
        clock: FixedClock(DateTime.utc(2026, 9, 22, 1, 30)),
      );
      vm.setEveningDate(CalendarDate(2025, 1, 1));
      expect(vm.eveningDate, CalendarDate(2025, 1, 1));
    });

    test('a future evening date is accepted', () async {
      vm = await buildViewModel(
        clock: FixedClock(DateTime.utc(2026, 9, 22, 1, 30)),
      );
      vm.setEveningDate(CalendarDate(2028, 6, 15));
      expect(vm.eveningDate, CalendarDate(2028, 6, 15));
    });

    test('newSession() returns to the default night, not a fixed wrong '
        'date (TD-001)', () async {
      vm = await buildViewModel(
        clock: FixedClock(DateTime.utc(2026, 9, 22, 1, 30)),
      );
      vm.setEveningDate(CalendarDate(2030, 1, 1));
      vm.newSession();
      expect(vm.eveningDate, CalendarDate(2026, 9, 21));
    });

    test('there is no SessionNight without a site (ADR-007 §9)', () async {
      // No saved location: first launch, default London coordinates.
      SharedPreferences.setMockInitialValues({});
      vm = PlannerHarness(
        DriftTargetRepository(database),
        DriftEquipmentRepository(database),
        _MockWeather(),
        locationRepo,
        locationService: FakeLocationService(),
        clock: FixedClock(DateTime.utc(2026, 9, 22, 1, 30)),
      );
      await vm.ready;

      expect(vm.isDefaultLocation, isTrue);
      expect(vm.sessionNight, isNull);
      expect(vm.eveningDate, isNull);
    });

    test('openSession() maps a legacy instant to its device-local evening date '
        '— a load round trip', () async {
      vm = await buildViewModel(
        clock: FixedClock(DateTime.utc(2026, 9, 22, 1, 30)),
      );

      // Simulate what main.dart's "Save Session" now stores: local
      // midnight of the picked evening date (see home_screen.dart).
      final picked = CalendarDate(2026, 11, 3);
      final storedInstant = DateTime(picked.year, picked.month, picked.day);

      await vm.openSession(
        Session(
          record: domain.SessionLog(
            id: 1,
            targetName: 'M42',
            equipmentName: 'Test Rig',
            sessionDate: storedInstant,
            plannedLightFrames: 10,
          ),
          status: SessionStatus.completed,
          legacy: true,
        ),
      );

      expect(vm.eveningDate, picked);
    });
  });

  // Pure domain-layer tests — VisibilityCalculator directly
  group('VisibilityCalculator is date-sensitive (Batch 3.1)', () {
    const lat = 51.5072; // London
    const lon = -0.1276;

    test('nightTimeline differs between summer and winter solstice', () {
      final summerTimeline = VisibilityCalculator.calculateNightTimeline(
        DateTime.utc(2025, 6, 21),
        lat,
        lon,
      );
      final winterTimeline = VisibilityCalculator.calculateNightTimeline(
        DateTime.utc(2025, 12, 21),
        lat,
        lon,
      );

      // Both maps must be returned (non-empty) without throwing
      expect(summerTimeline, isNotEmpty);
      expect(winterTimeline, isNotEmpty);

      // The sunset times must differ between solstices at lat 51.5°
      // (sun sets much later in summer than in winter)
      final summerSunset = summerTimeline['sunset'];
      final winterSunset = winterTimeline['sunset'];

      expect(
        summerSunset,
        isNotNull,
        reason: 'Sunset must exist on summer solstice',
      );
      expect(
        winterSunset,
        isNotNull,
        reason: 'Sunset must exist on winter solstice',
      );
      // Summer sunset is later in the day than winter sunset
      expect(
        summerSunset!.hour > winterSunset!.hour ||
            (summerSunset.hour == winterSunset.hour &&
                summerSunset.minute > winterSunset.minute),
        isTrue,
        reason: 'Sunset is later in summer than in winter at lat 51.5°',
      );
    });

    test('lunarIllumination is low near new moon (2025-01-29)', () {
      final illum = MoonCalculator.illuminatedFraction(
        DateTime.utc(2025, 1, 29),
      );
      expect(
        illum,
        lessThan(0.15),
        reason: 'Near new moon illumination should be < 15%',
      );
    });

    test('lunarIllumination is high near full moon (2025-02-12)', () {
      final illum = MoonCalculator.illuminatedFraction(
        DateTime.utc(2025, 2, 12),
      );
      expect(
        illum,
        greaterThan(0.85),
        reason: 'Near full moon illumination should be > 85%',
      );
    });

    test('future date (1 year ahead) does not throw', () {
      final futureDate = DateTime.now().toUtc().add(const Duration(days: 365));
      expect(
        () => VisibilityCalculator.calculateNightTimeline(futureDate, lat, lon),
        returnsNormally,
      );
    });

    test('past date (30 days ago) does not throw', () {
      final pastDate = DateTime.now().toUtc().subtract(
        const Duration(days: 30),
      );
      expect(
        () => VisibilityCalculator.calculateNightTimeline(pastDate, lat, lon),
        returnsNormally,
      );
    });
  });
}
