import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:astroplan/data/database/app_database.dart';
import 'package:astroplan/data/repositories/drift_equipment_repository.dart';
import 'package:astroplan/domain/models/equipment_profile.dart' as domain;

void main() {
  late AppDatabase database;
  late DriftEquipmentRepository repository;

  setUp(() {
    database = AppDatabase(NativeDatabase.memory());
    repository = DriftEquipmentRepository(database);
  });

  tearDown(() async {
    await database.close();
  });

  test('can insert and retrieve equipment profiles', () async {
    await repository.insertEquipment(const domain.EquipmentProfile(
      id: 0,
      name: 'Pixel 8 Pro (Main)',
      sensorWidth: 9.6,
      sensorHeight: 7.2,
      pixelPitch: 1.2,
      resolutionWidth: 8160,
      resolutionHeight: 6144,
      focalLength: 6.9,
      aperture: 1.68,
    ));

    final all = await repository.getAllEquipment();
    expect(all.length, 1);
    expect(all.first.name, 'Pixel 8 Pro (Main)');
    expect(all.first.focalLength, 6.9);
  });
}
