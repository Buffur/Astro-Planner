import 'package:drift/drift.dart';

import '../../domain/models/camera_module.dart' as domain;
import '../../domain/models/equipment_device.dart' as domain;
import '../../domain/models/optical_rig.dart' as domain;
import '../../domain/repositories/equipment_catalog_repository.dart';
import '../database/app_database.dart';

class DriftEquipmentCatalogRepository implements EquipmentCatalogRepository {
  final AppDatabase _db;

  DriftEquipmentCatalogRepository(this._db);

  domain.EquipmentDevice _mapDevice(Device row) {
    return domain.EquipmentDevice(
      id: row.id,
      name: row.name,
      manufacturer: row.manufacturer,
      model: row.model,
      notes: row.notes,
    );
  }

  domain.CameraModule _mapCameraModule(CameraModule row) {
    return domain.CameraModule(
      id: row.id,
      deviceId: row.deviceId,
      name: row.name,
      manufacturer: row.manufacturer,
      model: row.model,
      sensorWidthMm: row.sensorWidthMm,
      sensorHeightMm: row.sensorHeightMm,
      resolutionWidthPx: row.resolutionWidthPx,
      resolutionHeightPx: row.resolutionHeightPx,
      pixelPitchUm: row.pixelPitchUm,
      averageRawFileSizeMB: row.averageRawFileSizeMB,
    );
  }

  domain.OpticalRig _mapOpticalRig(OpticalRig row) {
    return domain.OpticalRig(
      id: row.id,
      name: row.name,
      cameraModuleId: row.cameraModuleId,
      focalLengthMm: row.focalLengthMm,
      aperture: row.aperture,
      trackingState: row.trackingState,
      rotationDegrees: row.rotationDegrees,
    );
  }

  @override
  Future<int> insertDevice(domain.EquipmentDevice device) {
    return _db
        .into(_db.devices)
        .insert(
          DevicesCompanion.insert(
            name: device.name,
            manufacturer: Value(device.manufacturer),
            model: Value(device.model),
            notes: Value(device.notes),
          ),
        );
  }

  @override
  Future<List<domain.EquipmentDevice>> getDevices() async {
    final rows = await _db.select(_db.devices).get();
    return rows.map(_mapDevice).toList();
  }

  @override
  Future<domain.EquipmentDevice?> getDeviceById(int id) async {
    final row = await (_db.select(
      _db.devices,
    )..where((t) => t.id.equals(id))).getSingleOrNull();
    return row == null ? null : _mapDevice(row);
  }

  @override
  Future<int> insertCameraModule(domain.CameraModule module) {
    return _db
        .into(_db.cameraModules)
        .insert(
          CameraModulesCompanion.insert(
            deviceId: module.deviceId,
            name: module.name,
            manufacturer: Value(module.manufacturer),
            model: Value(module.model),
            sensorWidthMm: module.sensorWidthMm,
            sensorHeightMm: module.sensorHeightMm,
            resolutionWidthPx: module.resolutionWidthPx,
            resolutionHeightPx: module.resolutionHeightPx,
            pixelPitchUm: module.pixelPitchUm,
            averageRawFileSizeMB: Value(module.averageRawFileSizeMB),
          ),
        );
  }

  @override
  Future<List<domain.CameraModule>> getCameraModulesForDevice(
    int deviceId,
  ) async {
    final rows = await (_db.select(
      _db.cameraModules,
    )..where((t) => t.deviceId.equals(deviceId))).get();
    return rows.map(_mapCameraModule).toList();
  }

  @override
  Future<int> insertOpticalRig(domain.OpticalRig rig) {
    return _db
        .into(_db.opticalRigs)
        .insert(
          OpticalRigsCompanion.insert(
            name: rig.name,
            cameraModuleId: rig.cameraModuleId,
            focalLengthMm: rig.focalLengthMm,
            aperture: rig.aperture,
            trackingState: Value(rig.trackingState),
            rotationDegrees: Value(rig.rotationDegrees),
          ),
        );
  }

  @override
  Future<List<domain.OpticalRig>> getOpticalRigsForCameraModule(
    int cameraModuleId,
  ) async {
    final rows = await (_db.select(
      _db.opticalRigs,
    )..where((t) => t.cameraModuleId.equals(cameraModuleId))).get();
    return rows.map(_mapOpticalRig).toList();
  }
}
