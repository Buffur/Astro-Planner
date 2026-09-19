import 'dart:io';

import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;

import 'tables/equipment_foundation_tables.dart';
import 'tables/equipment_table.dart';
import 'tables/locations_table.dart';
import 'tables/targets_table.dart';

part 'app_database.g.dart';

class CaptureBlocks extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get sessionLogId => integer().references(SessionLogs, #id)();
  TextColumn get frameType => text()(); // LIGHT, DARK, FLAT, BIAS
  TextColumn get filterName => text().nullable()();
  RealColumn get exposureTimeSeconds => real()();
  IntColumn get frameCount => integer()();
  IntColumn get binning => integer().withDefault(const Constant(1))();
  TextColumn get gainIso => text().nullable()();
}

class SessionLogs extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get targetName => text()();
  TextColumn get equipmentName => text()();
  DateTimeColumn get sessionDate => dateTime()();
  
  TextColumn get locationName => text().nullable()();
  RealColumn get bortleScale => real().nullable()();
  
  IntColumn get plannedLightFrames => integer()();
  IntColumn get plannedDarkFrames => integer().nullable()();
  IntColumn get plannedFlatFrames => integer().nullable()();
  IntColumn get plannedBiasFrames => integer().nullable()();
  RealColumn get integrationTimeSeconds => real().nullable()();
  
  RealColumn get focalLength => real().nullable()();
  RealColumn get aperture => real().nullable()();
  
  RealColumn get temperature => real().nullable()();
  RealColumn get humidity => real().nullable()();
  IntColumn get cloudCover => integer().nullable()();
  
  IntColumn get actualLightFrames => integer().nullable()();
  IntColumn get rejectedFrames => integer().nullable()();
  TextColumn get environmentalNotes => text().nullable()();
  TextColumn get processingNotes => text().nullable()();
}

@DriftDatabase(
  tables: [
    EquipmentProfiles,
    Devices,
    CameraModules,
    OpticalRigs,
    LocationProfiles,
    AstroTargets,
    SessionLogs,
    CaptureBlocks,
  ],
)
class AppDatabase extends _$AppDatabase {
  AppDatabase([QueryExecutor? e]) : super(e ?? _openConnection());

  @override
  int get schemaVersion => 9;

  @override
  MigrationStrategy get migration {
    return MigrationStrategy(
      onCreate: (Migrator m) async {
        await m.createAll();
      },
      onUpgrade: (Migrator m, int from, int to) async {
        if (from < 2) {
          await m.createTable(sessionLogs);
        }
        if (from < 3) {
          await customStatement('ALTER TABLE equipment_profiles ADD COLUMN manufacturer TEXT;');
          await customStatement('ALTER TABLE equipment_profiles ADD COLUMN camera_model TEXT;');
          await customStatement('ALTER TABLE equipment_profiles ADD COLUMN rotation REAL;');
        }
        if (from < 4) {
          await m.createTable(devices);
          await m.createTable(cameraModules);
          await m.createTable(opticalRigs);
        }
        if (from < 5) {
          await customStatement('''INSERT INTO devices (id, name, manufacturer) SELECT id, name, manufacturer FROM equipment_profiles;''');
          await customStatement('''INSERT INTO camera_modules (id, device_id, name, manufacturer, model, sensor_width_mm, sensor_height_mm, resolution_width_px, resolution_height_px, pixel_pitch_um) SELECT id, id, name || ' Camera', manufacturer, camera_model, sensor_width, sensor_height, resolution_width, resolution_height, pixel_pitch FROM equipment_profiles;''');
          await customStatement('''INSERT INTO optical_rigs (id, name, camera_module_id, focal_length_mm, aperture, optical_multiplier, tracking_state, rotation_degrees) SELECT id, name, id, focal_length, aperture, optical_multiplier, 'unknown', rotation FROM equipment_profiles;''');
        }
        if (from < 6) {
          await m.addColumn(locationProfiles, locationProfiles.bortleClass);
        }
        if (from < 7) {
          await m.addColumn(sessionLogs, sessionLogs.locationName);
          await m.addColumn(sessionLogs, sessionLogs.bortleScale);
          await m.addColumn(sessionLogs, sessionLogs.plannedDarkFrames);
          await m.addColumn(sessionLogs, sessionLogs.plannedFlatFrames);
          await m.addColumn(sessionLogs, sessionLogs.plannedBiasFrames);
          await m.addColumn(sessionLogs, sessionLogs.integrationTimeSeconds);
          await m.addColumn(sessionLogs, sessionLogs.focalLength);
          await m.addColumn(sessionLogs, sessionLogs.aperture);
          await m.addColumn(sessionLogs, sessionLogs.temperature);
          await m.addColumn(sessionLogs, sessionLogs.humidity);
          await m.addColumn(sessionLogs, sessionLogs.cloudCover);
        }
        if (from < 8) {
          await m.createTable(captureBlocks);
        }
        if (from < 9) {
          await m.addColumn(equipmentProfiles, equipmentProfiles.averageRawFileSizeMB);
          await m.addColumn(cameraModules, cameraModules.averageRawFileSizeMB);
        }
      },
    );
  }
}

LazyDatabase _openConnection() {
  return LazyDatabase(() async {
    final dbFolder = await getApplicationDocumentsDirectory();
    final file = File(p.join(dbFolder.path, 'astroplan.sqlite'));
    return NativeDatabase.createInBackground(file);
  });
}
