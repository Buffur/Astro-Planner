// Tests for PlannerViewModel's deterministic bootstrap (roadmap TASK 1.2).
//
// Covers:
//   - seeding completes before the ViewModel's first read (the ordering fix
//     for TD-002), using the same seeders main.dart uses
//   - a repository failure during the initial load sets hasBootstrapError
//     instead of leaving isLoading stuck forever
//   - retryBootstrap() recovers once the repository stops failing
//   - isDefaultLocation reflects whether a location has been resolved

import 'package:flutter_test/flutter_test.dart';
import 'package:drift/native.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:astroplan/data/database/app_database.dart';
import 'package:astroplan/data/repositories/drift_target_repository.dart';
import 'package:astroplan/data/repositories/drift_equipment_repository.dart';
import 'package:astroplan/data/repositories/drift_location_repository.dart';
import 'package:astroplan/data/repositories/light_pollution_repository.dart';
import 'package:astroplan/data/services/catalog_seeder.dart';
import 'package:astroplan/data/services/equipment_seeder.dart';
import 'package:astroplan/domain/models/location_profile.dart' as domain;
import 'package:astroplan/domain/models/weather_conditions.dart';
import 'package:astroplan/domain/repositories/weather_repository.dart';
import 'package:astroplan/presentation/viewmodels/planner_viewmodel.dart';

import '../../support/fake_location_service.dart';
import '../../support/flaky_target_repository.dart';

class _MockWeather implements WeatherRepository {
  @override
  Future<WeatherConditions?> getCurrentWeather(
    double lat,
    double lon, {
    bool forceRefresh = false,
  }) async => null;
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late AppDatabase database;

  setUp(() {
    SharedPreferences.setMockInitialValues({});
    database = AppDatabase(NativeDatabase.memory());
  });

  tearDown(() async {
    await database.close();
  });

  group('Bootstrap ordering (TASK 1.2)', () {
    test('seeding completes before the ViewModel reads, so a fresh install '
        'shows seeded data without a restart', () async {
      final targetRepo = DriftTargetRepository(database);
      final equipmentRepo = DriftEquipmentRepository(database);

      // Mirrors main.dart's fixed order: seed, then construct the ViewModel.
      await CatalogSeeder(targetRepo).seedIfNeeded();
      await EquipmentSeeder(equipmentRepo).seedIfNeeded();

      final vm = PlannerViewModel(
        targetRepo,
        equipmentRepo,
        _MockWeather(),
        DriftLocationRepository(database),
        LightPollutionRepository(),
        locationService: FakeLocationService(),
      );
      await vm.ready;

      expect(vm.hasBootstrapError, isFalse);
      expect(vm.selectedTarget?.catalogId, 'M42');
      expect(vm.selectedEquipment, isNotNull);
    });
  });

  group('Bootstrap error handling (TASK 1.2)', () {
    test(
      'a repository failure sets hasBootstrapError instead of hanging',
      () async {
        final flakyTargets = FlakyTargetRepository(
          DriftTargetRepository(database),
        );

        final vm = PlannerViewModel(
          flakyTargets,
          DriftEquipmentRepository(database),
          _MockWeather(),
          DriftLocationRepository(database),
          LightPollutionRepository(),
          locationService: FakeLocationService(),
        );
        await vm.ready;

        expect(vm.isLoading, isFalse);
        expect(vm.hasBootstrapError, isTrue);
        expect(vm.selectedTarget, isNull);
      },
    );

    test(
      'retryBootstrap() recovers once the repository stops failing',
      () async {
        final flakyTargets = FlakyTargetRepository(
          DriftTargetRepository(database),
        );
        final equipmentRepo = DriftEquipmentRepository(database);
        await CatalogSeeder(DriftTargetRepository(database)).seedIfNeeded();
        await EquipmentSeeder(equipmentRepo).seedIfNeeded();

        final vm = PlannerViewModel(
          flakyTargets,
          equipmentRepo,
          _MockWeather(),
          DriftLocationRepository(database),
          LightPollutionRepository(),
          locationService: FakeLocationService(),
        );
        await vm.ready;
        expect(vm.hasBootstrapError, isTrue);

        flakyTargets.shouldThrow = false;
        await vm.retryBootstrap();

        expect(vm.hasBootstrapError, isFalse);
        expect(vm.isLoading, isFalse);
        expect(vm.selectedTarget?.catalogId, 'M42');
      },
    );
  });

  group('isDefaultLocation (TASK 1.2)', () {
    test('true on first launch, with no saved location', () async {
      final vm = PlannerViewModel(
        DriftTargetRepository(database),
        DriftEquipmentRepository(database),
        _MockWeather(),
        DriftLocationRepository(database),
        LightPollutionRepository(),
        locationService: FakeLocationService(),
      );
      await vm.ready;

      expect(vm.isDefaultLocation, isTrue);
    });

    test('false once a saved location loads', () async {
      final locationRepo = DriftLocationRepository(database);
      final locId = await locationRepo.insertLocation(
        domain.LocationProfile(
          id: 0,
          name: 'Test Site',
          latitude: 51.5,
          longitude: -0.1,
          elevation: 10,
        ),
      );
      SharedPreferences.setMockInitialValues({'activeLocationId': locId});

      final vm = PlannerViewModel(
        DriftTargetRepository(database),
        DriftEquipmentRepository(database),
        _MockWeather(),
        locationRepo,
        LightPollutionRepository(),
        locationService: FakeLocationService(),
      );
      await vm.ready;

      expect(vm.isDefaultLocation, isFalse);
    });
  });
}
