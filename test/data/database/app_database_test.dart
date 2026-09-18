import 'package:drift/native.dart';
import 'package:drift/drift.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:astroplan/data/database/app_database.dart';

void main() {
  late AppDatabase database;

  setUp(() {
    database = AppDatabase(NativeDatabase.memory());
  });

  tearDown(() async {
    await database.close();
  });

  test('can create and retrieve equipment profile', () async {
    final id = await database.into(database.equipmentProfiles).insert(
      EquipmentProfilesCompanion.insert(
        name: 'ZWO ASI2600MC Pro',
        sensorWidth: 23.5,
        sensorHeight: 15.7,
        pixelPitch: 3.76,
        resolutionWidth: 6248,
        resolutionHeight: 4176,
        focalLength: 0.0,
        aperture: 0.0,
      ),
    );

    final profile = await (database.select(database.equipmentProfiles)..where((t) => t.id.equals(id))).getSingle();

    expect(profile.name, 'ZWO ASI2600MC Pro');
    expect(profile.sensorWidth, 23.5);
    expect(profile.resolutionWidth, 6248);
  });

  test('can insert and retrieve expanded SessionLog', () async {
    final date = DateTime.now();
    final id = await database.into(database.sessionLogs).insert(
      SessionLogsCompanion.insert(
        targetName: 'M31',
        equipmentName: 'Test Rig',
        sessionDate: date,
        locationName: const Value('Backyard'),
        bortleScale: const Value(4.5),
        plannedLightFrames: 100,
        plannedDarkFrames: const Value(20),
        integrationTimeSeconds: const Value(3600.0),
        temperature: const Value(-2.5),
      ),
    );

    final log = await (database.select(database.sessionLogs)..where((t) => t.id.equals(id))).getSingle();

    expect(log.targetName, 'M31');
    expect(log.locationName, 'Backyard');
    expect(log.bortleScale, 4.5);
    expect(log.plannedDarkFrames, 20);
    expect(log.integrationTimeSeconds, 3600.0);
    expect(log.temperature, -2.5);
  });
}
