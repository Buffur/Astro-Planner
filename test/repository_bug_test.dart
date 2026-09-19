import 'package:flutter_test/flutter_test.dart';
import 'package:astroplan/domain/models/equipment_profile.dart' as domain;
import 'package:astroplan/data/database/app_database.dart';
import 'package:astroplan/data/repositories/drift_equipment_repository.dart';
import 'package:drift/native.dart';

void main() {
  test('saves and loads averageRawFileSizeMB', () async {
    final db = AppDatabase(NativeDatabase.memory());
    final repo = DriftEquipmentRepository(db);
    
    final profile = domain.EquipmentProfile(
      id: 0,
      name: 'Test Rig',
      sensorWidth: 35.0,
      sensorHeight: 24.0,
      pixelPitch: 3.76,
      resolutionWidth: 6000,
      resolutionHeight: 4000,
      focalLength: 500,
      aperture: 5,
      averageRawFileSizeMB: 42.5,
    );

    final id = await repo.insertEquipment(profile);
    final loaded = await repo.getEquipmentById(id);
    
    expect(loaded?.averageRawFileSizeMB, 42.5);
    
    await db.close();
  });
}
