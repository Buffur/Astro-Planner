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
      sensorWidthMm: 35.0,
      sensorHeightMm: 24.0,
      pixelPitchUm: 3.76,
      resolutionWidthPx: 6000,
      resolutionHeightPx: 4000,
      focalLengthMm: 500,
      focalRatio: 5,
      averageRawFileSizeMB: 42.5,
    );

    final id = await repo.insertEquipment(profile);
    final loaded = await repo.getEquipmentById(id);

    expect(loaded?.averageRawFileSizeMB, 42.5);

    await db.close();
  });
}
