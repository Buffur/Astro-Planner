import 'package:drift/drift.dart';
import '../../domain/repositories/equipment_repository.dart';
import '../../domain/models/equipment_profile.dart' as domain;
import '../database/app_database.dart';

class DriftEquipmentRepository implements EquipmentRepository {
  final AppDatabase _db;

  DriftEquipmentRepository(this._db);

  domain.EquipmentProfile _mapToDomain(EquipmentProfile dbProfile) {
    return domain.EquipmentProfile(
      id: dbProfile.id,
      name: dbProfile.name,
      sensorWidth: dbProfile.sensorWidth,
      sensorHeight: dbProfile.sensorHeight,
      pixelPitch: dbProfile.pixelPitch,
      resolutionWidth: dbProfile.resolutionWidth,
      resolutionHeight: dbProfile.resolutionHeight,
      focalLength: dbProfile.focalLength,
      aperture: dbProfile.aperture,
      opticalMultiplier: dbProfile.opticalMultiplier,
    );
  }

  @override
  Future<List<domain.EquipmentProfile>> getAllEquipment() async {
    final dbProfiles = await _db.select(_db.equipmentProfiles).get();
    return dbProfiles.map(_mapToDomain).toList();
  }

  @override
  Future<domain.EquipmentProfile?> getEquipmentById(int id) async {
    final dbProfile = await (_db.select(_db.equipmentProfiles)..where((t) => t.id.equals(id))).getSingleOrNull();
    return dbProfile != null ? _mapToDomain(dbProfile) : null;
  }

  @override
  Future<int> insertEquipment(domain.EquipmentProfile profile) async {
    return _db.into(_db.equipmentProfiles).insert(
      EquipmentProfilesCompanion.insert(
        name: profile.name,
        sensorWidth: profile.sensorWidth,
        sensorHeight: profile.sensorHeight,
        pixelPitch: profile.pixelPitch,
        resolutionWidth: profile.resolutionWidth,
        resolutionHeight: profile.resolutionHeight,
        focalLength: profile.focalLength,
        aperture: profile.aperture,
        opticalMultiplier: Value(profile.opticalMultiplier),
      ),
    );
  }

  @override
  Future<void> deleteEquipment(int id) async {
    await (_db.delete(_db.equipmentProfiles)..where((t) => t.id.equals(id))).go();
  }
}
