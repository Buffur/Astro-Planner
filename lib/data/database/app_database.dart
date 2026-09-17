import 'dart:io';
import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;
import 'tables/equipment_table.dart';
import 'tables/locations_table.dart';
import 'tables/targets_table.dart';

part 'app_database.g.dart';

class SessionLogs extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get targetName => text()();
  TextColumn get equipmentName => text()();
  DateTimeColumn get sessionDate => dateTime()();
  IntColumn get plannedLightFrames => integer()();
  IntColumn get actualLightFrames => integer().nullable()();
  IntColumn get rejectedFrames => integer().nullable()();
  TextColumn get environmentalNotes => text().nullable()();
  TextColumn get processingNotes => text().nullable()();
}

@DriftDatabase(tables: [EquipmentProfiles, LocationProfiles, AstroTargets, SessionLogs])
class AppDatabase extends _$AppDatabase {
  AppDatabase([QueryExecutor? e]) : super(e ?? _openConnection());

  @override
  int get schemaVersion => 3;

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
          // Additive migration — adds Stellarium-compatible fields to equipment_profiles.
          // Existing rows keep all data; new columns default to NULL.
          await customStatement(
            'ALTER TABLE equipment_profiles ADD COLUMN manufacturer TEXT;',
          );
          await customStatement(
            'ALTER TABLE equipment_profiles ADD COLUMN camera_model TEXT;',
          );
          await customStatement(
            'ALTER TABLE equipment_profiles ADD COLUMN rotation REAL;',
          );
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
