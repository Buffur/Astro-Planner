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

  // Replaces the old 'can create and retrieve equipment profile' test, which
  // inserted into equipment_profiles directly: that table is dropped in v10
  // (ADR-008 §5, TASK 3.3) — not read or written by any application code,
  // and now not part of the schema at all. Equipment is the normalized
  // Device -> CameraModule -> OpticalRig chain, so this test covers that
  // instead (the reason is recorded here, per ADR-008 §5's requirement).
  test(
    'can create and retrieve a device/camera-module/optical-rig chain',
    () async {
      final deviceId = await database
          .into(database.devices)
          .insert(
            DevicesCompanion.insert(
              name: 'ZWO ASI2600MC Pro',
              manufacturer: const Value('ZWO'),
            ),
          );

      final cameraModuleId = await database
          .into(database.cameraModules)
          .insert(
            CameraModulesCompanion.insert(
              deviceId: deviceId,
              name: 'ZWO ASI2600MC Pro Camera',
              sensorWidthMm: 23.5,
              sensorHeightMm: 15.7,
              resolutionWidthPx: 6248,
              resolutionHeightPx: 4176,
              pixelPitchUm: 3.76,
            ),
          );

      final rigId = await database
          .into(database.opticalRigs)
          .insert(
            OpticalRigsCompanion.insert(
              name: 'Backyard Rig',
              cameraModuleId: cameraModuleId,
              focalLengthMm: 600.0,
              aperture: 6.0,
            ),
          );

      final rig = await (database.select(
        database.opticalRigs,
      )..where((t) => t.id.equals(rigId))).getSingle();
      final cameraModule = await (database.select(
        database.cameraModules,
      )..where((t) => t.id.equals(cameraModuleId))).getSingle();

      expect(rig.name, 'Backyard Rig');
      expect(rig.cameraModuleId, cameraModuleId);
      expect(cameraModule.deviceId, deviceId);
      expect(cameraModule.sensorWidthMm, 23.5);
      expect(cameraModule.resolutionWidthPx, 6248);
    },
  );

  test('can insert and retrieve expanded SessionLog', () async {
    final date = DateTime.now();
    final id = await database
        .into(database.sessionLogs)
        .insert(
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

    final log = await (database.select(
      database.sessionLogs,
    )..where((t) => t.id.equals(id))).getSingle();

    expect(log.targetName, 'M31');
    expect(log.locationName, 'Backyard');
    expect(log.bortleScale, 4.5);
    expect(log.plannedDarkFrames, 20);
    expect(log.integrationTimeSeconds, 3600.0);
    expect(log.temperature, -2.5);
  });
}
