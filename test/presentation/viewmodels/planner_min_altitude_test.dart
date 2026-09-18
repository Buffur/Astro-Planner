// Tests for Batch 3.2 — Minimum Altitude Configuration
//
// Covers:
//   - Default value of 20°
//   - setMinAltitude() mutation
//   - notifyListeners() triggered
//   - Clamping: values below 5° clamped to 5°, above 60° clamped to 60°
//   - Boundary values: exactly 5° and 60° are accepted as-is
//   - setMinAltitude() persists to SharedPreferences

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
import 'package:astroplan/presentation/viewmodels/planner_viewmodel.dart';

class _MockWeather implements WeatherRepository {
  @override
  Future<WeatherConditions?> getCurrentWeather(double lat, double lon,
      {bool forceRefresh = false}) async => null;
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late AppDatabase database;
  late DriftLocationRepository locationRepo;
  late PlannerViewModel vm;

  setUp(() async {
    database = AppDatabase(NativeDatabase.memory());
    locationRepo = DriftLocationRepository(database);

    final locId = await locationRepo.insertLocation(
      const domain.LocationProfile(
        id: 0, name: 'Test', latitude: 51.5, longitude: -0.1, elevation: 10,
      ),
    );
    SharedPreferences.setMockInitialValues({'activeLocationId': locId});

    vm = PlannerViewModel(
      DriftTargetRepository(database),
      DriftEquipmentRepository(database),
      _MockWeather(),
      locationRepo,
      LightPollutionRepository(),
    );

    await Future.delayed(const Duration(milliseconds: 300));
  });

  tearDown(() async {
    await database.close();
  });

  group('PlannerViewModel.minAltitude (Batch 3.2)', () {
    test('default is 20 degrees', () {
      expect(vm.minAltitude, 20.0);
    });

    test('setMinAltitude() changes the stored value', () async {
      await vm.setMinAltitude(30.0);
      expect(vm.minAltitude, 30.0);
    });

    test('setMinAltitude() triggers notifyListeners()', () async {
      var notified = false;
      vm.addListener(() => notified = true);
      await vm.setMinAltitude(25.0);
      expect(notified, isTrue);
    });

    test('value below 5 is clamped to 5', () async {
      await vm.setMinAltitude(0.0);
      expect(vm.minAltitude, 5.0);
    });

    test('negative value is clamped to 5', () async {
      await vm.setMinAltitude(-10.0);
      expect(vm.minAltitude, 5.0);
    });

    test('value above 60 is clamped to 60', () async {
      await vm.setMinAltitude(90.0);
      expect(vm.minAltitude, 60.0);
    });

    test('boundary value 5 is accepted as-is', () async {
      await vm.setMinAltitude(5.0);
      expect(vm.minAltitude, 5.0);
    });

    test('boundary value 60 is accepted as-is', () async {
      await vm.setMinAltitude(60.0);
      expect(vm.minAltitude, 60.0);
    });

    test('setMinAltitude() persists to SharedPreferences', () async {
      await vm.setMinAltitude(35.0);
      final prefs = await SharedPreferences.getInstance();
      expect(prefs.getDouble('minAltitude'), closeTo(35.0, 0.001));
    });
  });
}
