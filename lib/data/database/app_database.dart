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

/// The oldest schema version this app upgrades in place (ADR-008 §2). Every
/// committed build since `d0b737f` creates v8 or later; no older installs are
/// supported. Below this floor, [AppDatabase] refuses to touch the file — see
/// [resetUnsupportedDatabaseFile] for the (separately invoked) reset path.
const int kMinSupportedSchemaVersion = 8;

/// Thrown from [AppDatabase.migration]'s `onUpgrade` when the database file's
/// stored schema version is outside the range this app can migrate (ADR-008
/// §2, §3; TD-047). Thrown before any migration statement runs, so the file
/// is left byte-for-byte unchanged.
class UnsupportedSchemaVersionException implements Exception {
  /// The schema version found in the database file.
  final int foundVersion;

  /// The oldest version this app can upgrade from ([kMinSupportedSchemaVersion]).
  final int minSupportedVersion;

  /// True when [foundVersion] is *newer* than the app's own schema version
  /// (a downgrade: an older app build opened a newer database, TD-047).
  /// False when [foundVersion] is older than [minSupportedVersion].
  final bool isNewerThanApp;

  const UnsupportedSchemaVersionException(
    this.foundVersion, {
    required this.minSupportedVersion,
    required this.isNewerThanApp,
  });

  @override
  String toString() {
    if (isNewerThanApp) {
      return 'UnsupportedSchemaVersionException: database is at schema '
          '$foundVersion, newer than this app version supports. Refusing to '
          'open it; the file was not modified.';
    }
    return 'UnsupportedSchemaVersionException: database is at schema '
        '$foundVersion, older than the supported floor '
        '($minSupportedVersion). Refusing to migrate it; the file was not '
        'modified. See resetUnsupportedDatabaseFile().';
  }
}

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
        // ADR-008 §2: below the floor, refuse instead of running the old
        // v1-v7 steps (removed below; they assumed *current* table
        // definitions, not their own version's — the root cause of TD-004).
        // Every committed build since d0b737f creates v8 or later.
        if (from < kMinSupportedSchemaVersion) {
          throw UnsupportedSchemaVersionException(
            from,
            minSupportedVersion: kMinSupportedSchemaVersion,
            isNewerThanApp: false,
          );
        }
        // ADR-008 §2/TD-047: Drift calls onUpgrade whenever the stored
        // version differs from schemaVersion, including when it is *higher*
        // (an older app build opening a newer database). Never touch it.
        if (from > to) {
          throw UnsupportedSchemaVersionException(
            from,
            minSupportedVersion: kMinSupportedSchemaVersion,
            isNewerThanApp: true,
          );
        }
        // Only v8 -> v9 remains a supported path (floor is v8, current is
        // v9). Wrapped in a transaction so a failure mid-step leaves the
        // file completely unchanged, not partially migrated (verified by
        // a test that injects a failure between the two addColumn calls).
        await m.database.transaction(() async {
          if (from < 9) {
            await m.addColumn(
              equipmentProfiles,
              equipmentProfiles.averageRawFileSizeMB,
            );
            await m.addColumn(
              cameraModules,
              cameraModules.averageRawFileSizeMB,
            );
          }
        });
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

/// The reset path for a below-floor database (ADR-008 §2): renames [file] to
/// `<name>.v<foundVersion>.bak` (never deletes it) so a fresh database can be
/// created at the original path.
///
/// This performs the file move only. Callers are responsible for asking the
/// user to confirm first (ADR-008: "on the user's explicit confirmation ...
/// without confirmation, nothing is touched") and for constructing a new
/// [AppDatabase] afterwards, which creates a fresh v9 database on first use.
/// **Not yet wired into app startup** — no caller exists yet; TD-047's
/// tracking note covers this gap until a bootstrap task wires it in.
Future<File> resetUnsupportedDatabaseFile(
  File file, {
  required int foundVersion,
}) async {
  final backupPath = '${file.path}.v$foundVersion.bak';
  return file.rename(backupPath);
}
