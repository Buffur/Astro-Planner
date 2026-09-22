// Tests for PlannerViewModel's selection-staleness fixes (roadmap TASK 4.2,
// TD-028).
//
// Before this task, deleting or editing the selected target/equipment left
// the ViewModel holding a stale reference: the deleted row's fields (or the
// pre-edit values). `refreshSelectedTarget`/`refreshSelectedEquipment`
// re-read the selection by id, called from the target/equipment screens
// after any edit or delete. The "also after a restart" case needs no new
// code: bootstrap already falls back when a saved selection id no longer
// resolves (verified here directly, not just asserted).

import 'package:flutter_test/flutter_test.dart';
import 'package:drift/native.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:astroplan/data/database/app_database.dart' hide AstroTarget;
import 'package:astroplan/data/repositories/drift_target_repository.dart';
import 'package:astroplan/data/repositories/drift_equipment_repository.dart';
import 'package:astroplan/data/repositories/drift_location_repository.dart';
import 'package:astroplan/data/repositories/light_pollution_repository.dart';
import 'package:astroplan/domain/models/astro_target.dart';
import 'package:astroplan/domain/models/equipment_profile.dart';
import 'package:astroplan/domain/models/location_profile.dart' as domain;
import 'package:astroplan/domain/models/weather_conditions.dart';
import 'package:astroplan/domain/repositories/weather_repository.dart';
import 'package:astroplan/presentation/viewmodels/planner_viewmodel.dart';

import '../../support/fake_location_service.dart';

class _MockWeather implements WeatherRepository {
  @override
  Future<WeatherConditions?> getCurrentWeather(
    double lat,
    double lon, {
    bool forceRefresh = false,
  }) async => null;
}

const _target = AstroTarget(
  id: 1,
  catalogId: 'M31',
  commonName: 'Andromeda Galaxy',
  type: 'Galaxy',
  rightAscension: 10.68,
  declination: 41.27,
);

const _equipment = EquipmentProfile(
  id: 1,
  name: 'Test Rig',
  sensorWidth: 23.5,
  sensorHeight: 15.7,
  pixelPitch: 3.76,
  resolutionWidth: 6248,
  resolutionHeight: 4176,
  focalLength: 600.0,
  aperture: 6.0,
);

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late AppDatabase database;
  late DriftTargetRepository targetRepo;
  late DriftEquipmentRepository equipmentRepo;
  late DriftLocationRepository locationRepo;
  late PlannerViewModel vm;

  setUp(() async {
    database = AppDatabase(NativeDatabase.memory());
    targetRepo = DriftTargetRepository(database);
    equipmentRepo = DriftEquipmentRepository(database);
    locationRepo = DriftLocationRepository(database);

    await targetRepo.insertTarget(_target);
    await equipmentRepo.insertEquipment(_equipment);

    final locId = await locationRepo.insertLocation(
      domain.LocationProfile(
        id: 0,
        name: 'Test',
        latitude: 51.5,
        longitude: -0.1,
        elevation: 10,
      ),
    );
    SharedPreferences.setMockInitialValues({'activeLocationId': locId});

    vm = PlannerViewModel(
      targetRepo,
      equipmentRepo,
      _MockWeather(),
      locationRepo,
      LightPollutionRepository(),
      locationService: FakeLocationService(),
    );
    await vm.ready;
  });

  tearDown(() async {
    await database.close();
  });

  group('refreshSelectedTarget (TASK 4.2, TD-028)', () {
    test('clears the selection once the selected target is deleted', () async {
      await vm.setTarget(_target);
      expect(vm.selectedTarget, isNotNull);

      await targetRepo.deleteTarget(_target.id);
      await vm.refreshSelectedTarget();

      expect(vm.selectedTarget, isNull);
    });

    test('picks up an edit to the selected target', () async {
      await vm.setTarget(_target);

      final edited = AstroTarget(
        id: _target.id,
        catalogId: _target.catalogId,
        commonName: 'Renamed Galaxy',
        type: _target.type,
        rightAscension: 99.0,
        declination: _target.declination,
      );
      await targetRepo.updateTarget(edited);
      await vm.refreshSelectedTarget();

      expect(vm.selectedTarget?.commonName, 'Renamed Galaxy');
      expect(vm.selectedTarget?.rightAscension, 99.0);
    });

    test('does nothing without a selection', () async {
      expect(vm.selectedTarget, isNull);
      await vm.refreshSelectedTarget();
      expect(vm.selectedTarget, isNull);
    });

    test('is a no-op for an unrelated edit', () async {
      await vm.setTarget(_target);
      final other = const AstroTarget(
        id: 2,
        catalogId: 'M42',
        type: 'Nebula',
        rightAscension: 83.8,
        declination: -5.4,
      );
      await targetRepo.insertTarget(other);
      await vm.refreshSelectedTarget();
      expect(vm.selectedTarget?.id, _target.id);
    });
  });

  group('refreshSelectedEquipment (TASK 4.2, TD-028)', () {
    test(
      'clears the selection once the selected equipment is deleted',
      () async {
        await vm.setEquipment(_equipment);
        expect(vm.selectedEquipment, isNotNull);

        await equipmentRepo.deleteEquipment(_equipment.id);
        await vm.refreshSelectedEquipment();

        expect(vm.selectedEquipment, isNull);
      },
    );

    test('picks up an edit to the selected equipment', () async {
      await vm.setEquipment(_equipment);

      final edited = EquipmentProfile(
        id: _equipment.id,
        name: 'Renamed Rig',
        sensorWidth: _equipment.sensorWidth,
        sensorHeight: _equipment.sensorHeight,
        pixelPitch: _equipment.pixelPitch,
        resolutionWidth: _equipment.resolutionWidth,
        resolutionHeight: _equipment.resolutionHeight,
        focalLength: _equipment.focalLength,
        aperture: 4.0,
      );
      await equipmentRepo.updateEquipment(edited);
      await vm.refreshSelectedEquipment();

      expect(vm.selectedEquipment?.name, 'Renamed Rig');
      expect(vm.selectedEquipment?.aperture, 4.0);
    });

    test('does nothing without a selection', () async {
      // The shared `vm` auto-selects the only seeded equipment row on
      // bootstrap (the fallback "pick the first one" path), so use a
      // database with none at all to get a genuinely empty selection.
      final emptyDb = AppDatabase(NativeDatabase.memory());
      final emptyEquipmentRepo = DriftEquipmentRepository(emptyDb);
      final emptyVm = PlannerViewModel(
        targetRepo,
        emptyEquipmentRepo,
        _MockWeather(),
        locationRepo,
        LightPollutionRepository(),
        locationService: FakeLocationService(),
      );
      await emptyVm.ready;

      expect(emptyVm.selectedEquipment, isNull);
      await emptyVm.refreshSelectedEquipment();
      expect(emptyVm.selectedEquipment, isNull);

      await emptyDb.close();
    });
  });

  group('a deleted selection also clears after a restart (TD-028)', () {
    test(
      'a new PlannerViewModel does not resurrect a deleted target/equipment id',
      () async {
        await vm.setTarget(_target);
        await vm.setEquipment(_equipment);
        // The prefs now hold targetId/equipmentId pointing at rows that are
        // about to be deleted — simulating "close the app, delete from
        // another device/session, reopen".
        await targetRepo.deleteTarget(_target.id);
        await equipmentRepo.deleteEquipment(_equipment.id);

        final restarted = PlannerViewModel(
          targetRepo,
          equipmentRepo,
          _MockWeather(),
          locationRepo,
          LightPollutionRepository(),
          locationService: FakeLocationService(),
        );
        await restarted.ready;

        expect(restarted.selectedTarget?.id, isNot(_target.id));
        expect(restarted.selectedEquipment?.id, isNot(_equipment.id));
      },
    );
  });
}
