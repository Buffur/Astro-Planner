import 'package:astroplan/data/database/app_database.dart';
import 'package:astroplan/data/repositories/drift_equipment_catalog_repository.dart';
import 'package:astroplan/domain/models/camera_module.dart' as domain;
import 'package:astroplan/domain/models/equipment_device.dart' as domain;
import 'package:astroplan/domain/models/optical_rig.dart' as domain;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  late AppDatabase database;
  late DriftEquipmentCatalogRepository repository;

  setUp(() {
    database = AppDatabase(NativeDatabase.memory());
    repository = DriftEquipmentCatalogRepository(database);
  });

  tearDown(() async {
    await database.close();
  });

  test('stores normalized device, camera module, and optical rig', () async {
    final deviceId = await repository.insertDevice(
      const domain.EquipmentDevice(
        id: 0,
        name: 'Xiaomi 14T Pro',
        manufacturer: 'Xiaomi',
        model: '14T Pro',
      ),
    );

    final moduleId = await repository.insertCameraModule(
      domain.CameraModule(
        id: 0,
        deviceId: deviceId,
        name: 'Main Camera',
        sensorWidthMm: 9.6,
        sensorHeightMm: 7.2,
        resolutionWidthPx: 8160,
        resolutionHeightPx: 6144,
        pixelPitchUm: 1.2,
      ),
    );

    await repository.insertOpticalRig(
      domain.OpticalRig(
        id: 0,
        name: 'Phone main camera fixed rig',
        cameraModuleId: moduleId,
        focalLengthMm: 6.9,
        aperture: 1.7,
        trackingState: 'untracked',
      ),
    );

    final devices = await repository.getDevices();
    final modules = await repository.getCameraModulesForDevice(deviceId);
    final rigs = await repository.getOpticalRigsForCameraModule(moduleId);

    expect(devices.single.name, 'Xiaomi 14T Pro');
    expect(modules.single.name, 'Main Camera');
    expect(rigs.single.trackingState, 'untracked');
  });
}
