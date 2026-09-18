// Tests for Batch 3.1 — Session Date Selection
//
// Strategy:
//   - ViewModel mutation/getter tests avoid Geolocator by inserting a
//     saved location and setting 'activeLocationId' in SharedPreferences,
//     so _init uses the saved loc and skips useCurrentLocation().
//   - Downstream recalculation tests use VisibilityCalculator directly —
//     these are pure Dart functions with no platform-channel dependencies.

import 'package:flutter_test/flutter_test.dart';
import 'package:drift/native.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:astroplan/data/database/app_database.dart';
import 'package:astroplan/data/repositories/drift_target_repository.dart';
import 'package:astroplan/data/repositories/drift_equipment_repository.dart';
import 'package:astroplan/data/repositories/drift_location_repository.dart';
import 'package:astroplan/data/repositories/light_pollution_repository.dart';
import 'package:astroplan/domain/models/location_profile.dart' as domain;
import 'package:astroplan/domain/models/weather_conditions.dart';
import 'package:astroplan/domain/repositories/weather_repository.dart';
import 'package:astroplan/domain/services/visibility_calculator.dart';
import 'package:astroplan/presentation/viewmodels/planner_viewmodel.dart';

class _MockWeather implements WeatherRepository {
  @override
  Future<WeatherConditions?> getCurrentWeather(double lat, double lon,
      {bool forceRefresh = false}) async => null;
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('PlannerViewModel.setSessionDate() — field mutation (Batch 3.1)', () {
    late AppDatabase database;
    late DriftLocationRepository locationRepo;
    late PlannerViewModel vm;

    setUp(() async {
      database = AppDatabase(NativeDatabase.memory());
      locationRepo = DriftLocationRepository(database);

      // Insert a saved location so _init can resolve activeLocationId without GPS
      final locId = await locationRepo.insertLocation(
        const domain.LocationProfile(
          id: 0, name: 'Test Site',
          latitude: 51.5, longitude: -0.1, elevation: 10,
        ),
      );
      // Telling _init about it means it will not call useCurrentLocation()
      SharedPreferences.setMockInitialValues({'activeLocationId': locId});

      vm = PlannerViewModel(
        DriftTargetRepository(database),
        DriftEquipmentRepository(database),
        _MockWeather(),
        locationRepo,
        LightPollutionRepository(),
      );

      // Let _init resolve
      await Future.delayed(const Duration(milliseconds: 300));
    });

    tearDown(() async {
      await database.close();
    });

    test('sessionDate defaults to today (UTC)', () {
      final now = DateTime.now().toUtc();
      expect(vm.sessionDate.year, now.year);
      expect(vm.sessionDate.month, now.month);
      expect(vm.sessionDate.day, now.day);
    });

    test('setSessionDate() changes the stored date', () {
      final tomorrow = DateTime.now().toUtc().add(const Duration(days: 1));
      vm.setSessionDate(tomorrow);
      expect(vm.sessionDate.year, tomorrow.year);
      expect(vm.sessionDate.month, tomorrow.month);
      expect(vm.sessionDate.day, tomorrow.day);
    });

    test('setSessionDate() triggers notifyListeners()', () {
      var notified = false;
      vm.addListener(() => notified = true);
      vm.setSessionDate(DateTime.now().toUtc().add(const Duration(days: 2)));
      expect(notified, isTrue);
    });

    test('past date (30 days ago) is accepted', () {
      final past = DateTime.now().toUtc().subtract(const Duration(days: 30));
      vm.setSessionDate(past);
      expect(vm.sessionDate.year, past.year);
      expect(vm.sessionDate.month, past.month);
      expect(vm.sessionDate.day, past.day);
    });

    test('future date (365 days ahead) is accepted', () {
      final future = DateTime.now().toUtc().add(const Duration(days: 365));
      vm.setSessionDate(future);
      expect(vm.sessionDate.year, future.year);
      expect(vm.sessionDate.month, future.month);
      expect(vm.sessionDate.day, future.day);
    });
  });

  // Pure domain-layer tests — VisibilityCalculator directly
  group('VisibilityCalculator is date-sensitive (Batch 3.1)', () {
    const lat = 51.5072; // London
    const lon = -0.1276;

    test('nightTimeline differs between summer and winter solstice', () {
      final summerTimeline = VisibilityCalculator.calculateNightTimeline(
        DateTime.utc(2025, 6, 21), lat, lon,
      );
      final winterTimeline = VisibilityCalculator.calculateNightTimeline(
        DateTime.utc(2025, 12, 21), lat, lon,
      );

      // Both maps must be returned (non-empty) without throwing
      expect(summerTimeline, isNotEmpty);
      expect(winterTimeline, isNotEmpty);

      // The sunset times must differ between solstices at lat 51.5°
      // (sun sets much later in summer than in winter)
      final summerSunset = summerTimeline['sunset'];
      final winterSunset = winterTimeline['sunset'];

      expect(summerSunset, isNotNull, reason: 'Sunset must exist on summer solstice');
      expect(winterSunset, isNotNull, reason: 'Sunset must exist on winter solstice');
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
      final illum = VisibilityCalculator.calculateLunarIllumination(
        DateTime.utc(2025, 1, 29),
      );
      expect(illum, lessThan(0.15),
          reason: 'Near new moon illumination should be < 15%');
    });

    test('lunarIllumination is high near full moon (2025-02-12)', () {
      final illum = VisibilityCalculator.calculateLunarIllumination(
        DateTime.utc(2025, 2, 12),
      );
      expect(illum, greaterThan(0.85),
          reason: 'Near full moon illumination should be > 85%');
    });

    test('future date (1 year ahead) does not throw', () {
      final futureDate = DateTime.now().toUtc().add(const Duration(days: 365));
      expect(
        () => VisibilityCalculator.calculateNightTimeline(futureDate, lat, lon),
        returnsNormally,
      );
    });

    test('past date (30 days ago) does not throw', () {
      final pastDate = DateTime.now().toUtc().subtract(const Duration(days: 30));
      expect(
        () => VisibilityCalculator.calculateNightTimeline(pastDate, lat, lon),
        returnsNormally,
      );
    });
  });
}
