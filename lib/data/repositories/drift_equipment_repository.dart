import 'package:drift/drift.dart';

import '../../domain/repositories/equipment_repository.dart';
import '../../domain/models/equipment_profile.dart' as domain;
import '../../domain/models/spec_confidence.dart';
import '../../domain/models/tracking_type.dart';
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
      sensorWidthMm: cam.sensorWidthMm,
      sensorHeightMm: cam.sensorHeightMm,
      pixelPitchUm: cam.pixelPitchUm,
      resolutionWidthPx: cam.resolutionWidthPx,
      resolutionHeightPx: cam.resolutionHeightPx,
      focalLengthMm: rig.focalLengthMm,
      // ADR-011 §4: the `aperture` column holds the focal ratio N.
      focalRatio: rig.aperture,
      apertureDiameterMm: rig.apertureDiameterMm,
      averageRawFileSizeMB: cam.averageRawFileSizeMB,
      rotationDeg: rig.rotationDegrees,
      trackingType: TrackingType.fromStorage(rig.trackingState),
      maxExposureS: rig.maxExposureS,
      cameraSource: cam.source,
      cameraConfidence: SpecConfidence.fromStorage(cam.confidence),
      opticsSource: rig.source,
      opticsConfidence: SpecConfidence.fromStorage(rig.confidence),
    );
  }

  @override
  Future<List<domain.EquipmentProfile>> getAllEquipment() async {
    final query = _db.select(_db.opticalRigs).join([
      innerJoin(
        _db.cameraModules,
        _db.cameraModules.id.equalsExp(_db.opticalRigs.cameraModuleId),
      ),
      innerJoin(
        _db.devices,
        _db.devices.id.equalsExp(_db.cameraModules.deviceId),
      ),
    ]);
    final rows = await query.get();
    return rows.map(_mapToDomain).toList();
  }

  @override
  Future<domain.EquipmentProfile?> getEquipmentById(int id) async {
    final query = _db.select(_db.opticalRigs).join([
      innerJoin(
        _db.cameraModules,
        _db.cameraModules.id.equalsExp(_db.opticalRigs.cameraModuleId),
      ),
      innerJoin(
        _db.devices,
        _db.devices.id.equalsExp(_db.cameraModules.deviceId),
      ),
    ])..where(_db.opticalRigs.id.equals(id));

    final row = await query.getSingleOrNull();
    return row != null ? _mapToDomain(row) : null;
  }

  @override
  Future<int> insertEquipment(domain.EquipmentProfile profile) async {
    return await _db.transaction(() async {
      final deviceId = await _db
          .into(_db.devices)
          .insert(
            DevicesCompanion.insert(
              name: profile.name,
              manufacturer: Value(profile.manufacturer),
            ),
          );

      final camId = await _db
          .into(_db.cameraModules)
          .insert(
            CameraModulesCompanion.insert(
              deviceId: deviceId,
              name: '${profile.name} Camera',
              manufacturer: Value(profile.manufacturer),
              model: Value(profile.cameraModel),
              sensorWidthMm: profile.sensorWidthMm,
              sensorHeightMm: profile.sensorHeightMm,
              resolutionWidthPx: profile.resolutionWidthPx,
              resolutionHeightPx: profile.resolutionHeightPx,
              pixelPitchUm: profile.pixelPitchUm,
              averageRawFileSizeMB: Value(profile.averageRawFileSizeMB),
              source: Value(profile.cameraSource),
              confidence: Value(profile.cameraConfidence?.name),
            ),
          );

      final rigId = await _db
          .into(_db.opticalRigs)
          .insert(
            OpticalRigsCompanion.insert(
              name: profile.name,
              cameraModuleId: camId,
              focalLengthMm: profile.focalLengthMm,
              aperture: profile.focalRatio,
              apertureDiameterMm: Value(profile.apertureDiameterMm),
              rotationDegrees: Value(profile.rotationDeg),
              trackingState: Value(profile.trackingType.name),
              maxExposureS: Value(profile.maxExposureS),
              source: Value(profile.opticsSource),
              confidence: Value(profile.opticsConfidence?.name),
            ),
          );

      return rigId;
    });
  }

  @override
  Future<void> deleteEquipment(int id) async {
    await _db.transaction(() async {
      final rig = await (_db.select(
        _db.opticalRigs,
      )..where((t) => t.id.equals(id))).getSingleOrNull();
      if (rig == null) return;

      final cam = await (_db.select(
        _db.cameraModules,
      )..where((t) => t.id.equals(rig.cameraModuleId))).getSingleOrNull();

      await (_db.delete(_db.opticalRigs)..where((t) => t.id.equals(id))).go();

      if (cam != null) {
        // ADR-008 §4: camera_modules.device_id and optical_rigs.camera_module_id
        // are ON DELETE RESTRICT from v10 — deleting a shared row would throw.
        // Every profile is currently created as its own 1:1:1 chain, so these
        // counts are 0 in practice today, but guard anyway for when equipment
        // composition (PD-03) lets rigs and modules be reused.
        final otherRigsOnModule =
            await (_db.selectOnly(_db.opticalRigs)
                  ..addColumns([_db.opticalRigs.id.count()])
                  ..where(_db.opticalRigs.cameraModuleId.equals(cam.id)))
                .map((row) => row.read(_db.opticalRigs.id.count()) ?? 0)
                .getSingle();

        if (otherRigsOnModule == 0) {
          await (_db.delete(
            _db.cameraModules,
          )..where((t) => t.id.equals(cam.id))).go();

          final otherModulesOnDevice =
              await (_db.selectOnly(_db.cameraModules)
                    ..addColumns([_db.cameraModules.id.count()])
                    ..where(_db.cameraModules.deviceId.equals(cam.deviceId)))
                  .map((row) => row.read(_db.cameraModules.id.count()) ?? 0)
                  .getSingle();

          if (otherModulesOnDevice == 0) {
            await (_db.delete(
              _db.devices,
            )..where((t) => t.id.equals(cam.deviceId))).go();
          }
        }
      }
    });
  }

  @override
  Future<void> updateEquipment(domain.EquipmentProfile profile) async {
    await _db.transaction(() async {
      final rig = await (_db.select(
        _db.opticalRigs,
      )..where((t) => t.id.equals(profile.id))).getSingleOrNull();
      if (rig == null) return;

      final cam = await (_db.select(
        _db.cameraModules,
      )..where((t) => t.id.equals(rig.cameraModuleId))).getSingleOrNull();

      await (_db.update(
        _db.opticalRigs,
      )..where((t) => t.id.equals(rig.id))).write(
        OpticalRigsCompanion(
          name: Value(profile.name),
          focalLengthMm: Value(profile.focalLengthMm),
          aperture: Value(profile.focalRatio),
          apertureDiameterMm: Value(profile.apertureDiameterMm),
          rotationDegrees: Value(profile.rotationDeg),
          trackingState: Value(profile.trackingType.name),
          maxExposureS: Value(profile.maxExposureS),
          source: Value(profile.opticsSource),
          confidence: Value(profile.opticsConfidence?.name),
        ),
      );

      if (cam != null) {
        await (_db.update(
          _db.cameraModules,
        )..where((t) => t.id.equals(cam.id))).write(
          CameraModulesCompanion(
            name: Value('${profile.name} Camera'),
            manufacturer: Value(profile.manufacturer),
            model: Value(profile.cameraModel),
            sensorWidthMm: Value(profile.sensorWidthMm),
            sensorHeightMm: Value(profile.sensorHeightMm),
            resolutionWidthPx: Value(profile.resolutionWidthPx),
            resolutionHeightPx: Value(profile.resolutionHeightPx),
            pixelPitchUm: Value(profile.pixelPitchUm),
            averageRawFileSizeMB: Value(profile.averageRawFileSizeMB),
            source: Value(profile.cameraSource),
            confidence: Value(profile.cameraConfidence?.name),
          ),
        );

        await (_db.update(
          _db.devices,
        )..where((t) => t.id.equals(cam.deviceId))).write(
          DevicesCompanion(
            name: Value(profile.name),
            manufacturer: Value(profile.manufacturer),
          ),
        );
      }
    });
  }
}
