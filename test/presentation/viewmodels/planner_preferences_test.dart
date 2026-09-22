// TASK 5.2 — planning preferences drive the ViewModel's derived values, and
// the ViewModel no longer touches SharedPreferences directly.

import 'dart:io';

import 'package:astroplan/core/time/clock.dart';
import 'package:astroplan/data/database/app_database.dart';
import 'package:astroplan/data/repositories/drift_equipment_repository.dart';
import 'package:astroplan/data/repositories/drift_location_repository.dart';
import 'package:astroplan/data/repositories/drift_target_repository.dart';
import 'package:astroplan/data/repositories/light_pollution_repository.dart';
import 'package:astroplan/data/services/catalog_seeder.dart';
import 'package:astroplan/domain/models/capture_block.dart';
import 'package:astroplan/domain/models/location_profile.dart' as domain;
import 'package:astroplan/domain/models/planning_preferences.dart';
import 'package:astroplan/domain/models/weather_conditions.dart';
import 'package:astroplan/domain/repositories/weather_repository.dart';
import 'package:astroplan/presentation/viewmodels/planner_viewmodel.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../support/fake_location_service.dart';

class _NoWeather implements WeatherRepository {
  @override
  Future<WeatherConditions?> getCurrentWeather(
    double lat,
    double lon, {
    bool forceRefresh = false,
  }) async => null;
}

Duration _total(PlannerViewModel vm) =>
    vm.visibilityWindows.fold(Duration.zero, (s, w) => s + w.duration);

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late AppDatabase database;
  late PlannerViewModel vm;

  setUp(() async {
    database = AppDatabase(NativeDatabase.memory());
    final targets = DriftTargetRepository(database);
    await CatalogSeeder(targets).seedIfNeeded(); // provides M42
    final locations = DriftLocationRepository(database);
    final locId = await locations.insertLocation(
      const domain.LocationProfile(
        id: 0,
        name: 'London',
        latitude: 51.5,
        longitude: -0.1,
        elevation: 10,
      ),
    );
    SharedPreferences.setMockInitialValues({'activeLocationId': locId});
    vm = PlannerViewModel(
      targets,
      DriftEquipmentRepository(database),
      _NoWeather(),
      locations,
      LightPollutionRepository(),
      locationService: FakeLocationService(),
      // An early-March evening: M42 is already above 20° at dusk, so its
      // window starts when the Sun reaches the darkness limit (a December
      // night would be bounded by the target's altitude at both ends).
      clock: FixedClock(DateTime.utc(2026, 3, 1, 18)),
    );
    await vm.ready;
  });

  tearDown(() async => database.close());

  test('a lighter darkness limit gives longer windows', () async {
    expect(vm.selectedTarget?.catalogId, 'M42');
    final astronomical = _total(vm);
    expect(astronomical, greaterThan(Duration.zero));

    await vm.setPlanningPreferences(
      vm.planningPreferences.copyWith(darknessLimit: DarknessLimit.nautical),
    );
    expect(_total(vm), greaterThan(astronomical));
  });

  test('the minimum altitude preference changes the windows', () async {
    final at20 = _total(vm);
    await vm.setPlanningPreferences(
      vm.planningPreferences.copyWith(minAltitudeDeg: 35),
    );
    expect(_total(vm), lessThan(at20));
  });

  test('per-frame overhead feeds the required time (default 5 s)', () async {
    // Since TASK 5.4 (ADR-009 §2) the required time is the window load:
    // only lights and in-window calibration count. The example plan's darks
    // and flats default to outside the window, so only its lights count.
    final frames = vm.captureBlocks
        .where(
          (b) =>
              b.frameType == FrameType.light ||
              b.calibrationPolicy == CalibrationPolicy.inWindow,
        )
        .fold(0, (s, b) => s + b.frameCount);
    expect(frames, 100);
    final at5 = vm.estimatedRequiredTime;
    await vm.setPlanningPreferences(
      vm.planningPreferences.copyWith(perFrameOverheadSeconds: 0),
    );
    expect(at5 - vm.estimatedRequiredTime, Duration(seconds: frames * 5));
  });

  test('preferences persist and are loaded by a new ViewModel', () async {
    await vm.setPlanningPreferences(
      vm.planningPreferences.copyWith(
        darknessLimit: DarknessLimit.deepNautical,
        feasibilityMarginPercent: 25,
      ),
    );
    final again = PlannerViewModel(
      DriftTargetRepository(database),
      DriftEquipmentRepository(database),
      _NoWeather(),
      DriftLocationRepository(database),
      LightPollutionRepository(),
      locationService: FakeLocationService(),
    );
    await again.ready;
    expect(again.planningPreferences.darknessLimit, DarknessLimit.deepNautical);
    expect(again.planningPreferences.feasibilityMarginPercent, 25);
  });

  // TASK 5.2 acceptance: no SharedPreferences imports in ViewModels.
  test('no ViewModel imports SharedPreferences', () {
    final offenders = Directory('lib/presentation/viewmodels')
        .listSync(recursive: true)
        .whereType<File>()
        .where((f) => f.path.endsWith('.dart'))
        .where((f) => f.readAsStringSync().contains('shared_preferences'))
        .map((f) => f.path)
        .toList();
    expect(offenders, isEmpty);
  });
}
