import 'package:drift/drift.dart';
import '../../domain/repositories/equipment_repository.dart';
import '../../domain/models/equipment_profile.dart' as domain;
import '../database/app_database.dart';

class DriftEquipmentRepository implements EquipmentRepository {
  final AppDatabase _db;

  DriftEquipmentRepository(this._db);

  domain.EquipmentProfile _mapToDomain(TypedResult row) {
    final rig = row.readTable(_db.opticalRigs);
    final cam = row.readTable(_db.cameraModules);
    final dev = row.readTable(_db.devices);

    return domain.EquipmentProfile(
      id: rig.id,
      name: rig.name,
      manufacturer: dev.manufacturer,
      cameraModel: cam.model,
      sensorWidth: cam.sensorWidthMm,
      sensorHeight: cam.sensorHeightMm,
      pixelPitch: cam.pixelPitchUm,
      resolutionWidth: cam.resolutionWidthPx,
      resolutionHeight: cam.resolutionHeightPx,
      focalLength: rig.focalLengthMm,
      aperture: rig.aperture,
      averageRawFileSizeMB: cam.averageRawFileSizeMB,
      rotation: rig.rotationDegrees,
    );
  }

  @override
  Future<List<domain.EquipmentProfile>> getAllEquipment() async {
    final query = _db.select(_db.opticalRigs).join([
      innerJoin(_db.cameraModules,
          _db.cameraModules.id.equalsExp(_db.opticalRigs.cameraModuleId)),
      innerJoin(_db.devices,
          _db.devices.id.equalsExp(_db.cameraModules.deviceId)),
    ]);
    final rows = await query.get();
    return rows.map(_mapToDomain).toList();
  }

  @override
  Future<domain.EquipmentProfile?> getEquipmentById(int id) async {
    final query = _db.select(_db.opticalRigs).join([
      innerJoin(_db.cameraModules,
          _db.cameraModules.id.equalsExp(_db.opticalRigs.cameraModuleId)),
      innerJoin(_db.devices,
          _db.devices.id.equalsExp(_db.cameraModules.deviceId)),
    ])..where(_db.opticalRigs.id.equals(id));
    
    final row = await query.getSingleOrNull();
    return row != null ? _mapToDomain(row) : null;
  }

  @override
  Future<int> insertEquipment(domain.EquipmentProfile profile) async {
    return await _db.transaction(() async {
      final deviceId = await _db.into(_db.devices).insert(
            DevicesCompanion.insert(
              name: profile.name,
              manufacturer: Value(profile.manufacturer),
            ),
          );

      final camId = await _db.into(_db.cameraModules).insert(
            CameraModulesCompanion.insert(
              deviceId: deviceId,
              name: '${profile.name} Camera',
              manufacturer: Value(profile.manufacturer),
              model: Value(profile.cameraModel),
              sensorWidthMm: profile.sensorWidth,
              sensorHeightMm: profile.sensorHeight,
              resolutionWidthPx: profile.resolutionWidth,
              resolutionHeightPx: profile.resolutionHeight,
              pixelPitchUm: profile.pixelPitch,
              averageRawFileSizeMB: Value(profile.averageRawFileSizeMB),
            ),
          );

      final rigId = await _db.into(_db.opticalRigs).insert(
            OpticalRigsCompanion.insert(
              name: profile.name,
              cameraModuleId: camId,
              focalLengthMm: profile.focalLength,
              aperture: profile.aperture,
              rotationDegrees: Value(profile.rotation),
            ),
          );

      return rigId;
    });
  }

  @override
  Future<void> deleteEquipment(int id) async {
    await _db.transaction(() async {
      final rig = await (_db.select(_db.opticalRigs)
            ..where((t) => t.id.equals(id)))
          .getSingleOrNull();
      if (rig == null) return;

      final cam = await (_db.select(_db.cameraModules)
            ..where((t) => t.id.equals(rig.cameraModuleId)))
          .getSingleOrNull();

      await (_db.delete(_db.opticalRigs)..where((t) => t.id.equals(id))).go();
      
      if (cam != null) {
        await (_db.delete(_db.cameraModules)..where((t) => t.id.equals(cam.id))).go();
        await (_db.delete(_db.devices)..where((t) => t.id.equals(cam.deviceId))).go();
      }
    });
  }

  @override
  Future<void> updateEquipment(domain.EquipmentProfile profile) async {
    await _db.transaction(() async {
      final rig = await (_db.select(_db.opticalRigs)
            ..where((t) => t.id.equals(profile.id)))
          .getSingleOrNull();
      if (rig == null) return;

      final cam = await (_db.select(_db.cameraModules)
            ..where((t) => t.id.equals(rig.cameraModuleId)))
          .getSingleOrNull();

      await (_db.update(_db.opticalRigs)..where((t) => t.id.equals(rig.id))).write(
        OpticalRigsCompanion(
          name: Value(profile.name),
          focalLengthMm: Value(profile.focalLength),
          aperture: Value(profile.aperture),
          rotationDegrees: Value(profile.rotation),
        ),
      );

      if (cam != null) {
        await (_db.update(_db.cameraModules)..where((t) => t.id.equals(cam.id))).write(
          CameraModulesCompanion(
            name: Value('${profile.name} Camera'),
            manufacturer: Value(profile.manufacturer),
            model: Value(profile.cameraModel),
            sensorWidthMm: Value(profile.sensorWidth),
            sensorHeightMm: Value(profile.sensorHeight),
            resolutionWidthPx: Value(profile.resolutionWidth),
            resolutionHeightPx: Value(profile.resolutionHeight),
            pixelPitchUm: Value(profile.pixelPitch),
            averageRawFileSizeMB: Value(profile.averageRawFileSizeMB),
          ),
        );

        await (_db.update(_db.devices)..where((t) => t.id.equals(cam.deviceId))).write(
          DevicesCompanion(
            name: Value(profile.name),
            manufacturer: Value(profile.manufacturer),
          ),
        );
      }
    });
  }
}
