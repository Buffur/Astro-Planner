import re

with open(r'c:\Users\zalub\OneDrive\Desktop\Astro Planner\Astro-Planner\lib\data\database\app_database.dart', 'r', encoding='utf-8') as f:
    content = f.read()

# Replace schema version
content = content.replace('int get schemaVersion => 6;', 'int get schemaVersion => 7;')

# Add columns to SessionLogs table
table_def_old = """class SessionLogs extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get targetName => text()();
  TextColumn get equipmentName => text()();
  DateTimeColumn get sessionDate => dateTime()();
  IntColumn get plannedLightFrames => integer()();
  IntColumn get actualLightFrames => integer().nullable()();
  IntColumn get rejectedFrames => integer().nullable()();
  TextColumn get environmentalNotes => text().nullable()();
  TextColumn get processingNotes => text().nullable()();
}"""

table_def_new = """class SessionLogs extends Table {
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
}"""

content = content.replace(table_def_old, table_def_new)

# Add migration logic
migration_old = """        if (from < 6) {
          await m.addColumn(locationProfiles, locationProfiles.bortleClass);
        }
      },"""

migration_new = """        if (from < 6) {
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
      },"""

content = content.replace(migration_old, migration_new)

with open(r'c:\Users\zalub\OneDrive\Desktop\Astro Planner\Astro-Planner\lib\data\database\app_database.dart', 'w', encoding='utf-8') as f:
    f.write(content)
