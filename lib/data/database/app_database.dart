import 'dart:io';

import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;

import 'tables/equipment_foundation_tables.dart';
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
  // ADR-008 §4: a session's blocks are removed with it.
  IntColumn get sessionLogId =>
      integer().references(SessionLogs, #id, onDelete: KeyAction.cascade)();
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
  int get schemaVersion => 10;

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
        // With the guards above, from is always 8 here today (the only
        // version between the floor and the current one), but the two
        // steps below stay staged by version — exactly like the pre-v10
        // chain — rather than merged into one, so a future app build that
        // genuinely stops at v9 (this repository has never shipped, but
        // nothing here should assume that) still upgrades correctly.
        // Wrapped in one transaction so a failure mid-step leaves the file
        // completely unchanged (ADR-008 §3 "each upgrade runs as one
        // unit"; verified by a test that injects a failure partway
        // through).
        await m.database.transaction(() async {
          if (from < 9) {
            await m.addColumn(
              cameraModules,
              cameraModules.averageRawFileSizeMB,
            );
            // No matching equipmentProfiles.averageRawFileSizeMB step: that
            // table is dropped by the v10 step immediately below, in the
            // same transaction, so adding a column to it first would be
            // pure waste — and it can no longer be referenced by a typed
            // accessor now that EquipmentProfiles isn't a declared table.
          }
          if (from < 10) {
            // ADR-008 §4: clean up any pre-existing orphans (TD-005
            // verified one could exist) while foreign keys are still off —
            // beforeOpen below only turns them on once this whole
            // migration succeeds.
            await _deleteOrphanForeignKeyRows(m.database);

            // SQLite can't ALTER a column's type or a foreign key's ON
            // DELETE action in place, so these three are rebuilt against
            // the *current* Dart definitions (ADR-008 §4-§5): that adds
            // the real ON DELETE actions declared on the tables now, and —
            // for cameraModules and opticalRigs — drops the bit_depth /
            // optical_multiplier columns the old addColumn-only upgrades
            // left behind. By this point cameraModules already has
            // averageRawFileSizeMB (added above, or present on any
            // install that was already at v9), so no newColumns entry is
            // needed here.
            await m.alterTable(TableMigration(cameraModules));
            await m.alterTable(TableMigration(opticalRigs));
            await m.alterTable(TableMigration(captureBlocks));

            // ADR-008 §5: the orphaned flat table is retired.
            await m.deleteTable('equipment_profiles');

            // Confirm the cleanup above actually worked before beforeOpen
            // turns enforcement on.
            final remaining = await m.database
                .customSelect('PRAGMA foreign_key_check;')
                .get();
            if (remaining.isNotEmpty) {
              throw StateError(
                'ADR-008 v10 migration: foreign_key_check still found '
                '${remaining.length} violation(s) after cleanup: $remaining',
              );
            }
          }
        });
      },
      // ADR-008 §4: every connection enforces foreign keys, not just
      // upgraded ones. Runs after onCreate/onUpgrade, so it never sees the
      // v10 migration's own transient state.
      beforeOpen: (details) async {
        await customStatement('PRAGMA foreign_keys = ON;');
      },
    );
  }
}

/// ADR-008 §4: reads `PRAGMA foreign_key_check` and deletes every row it
/// flags — one batch `DELETE ... WHERE rowid IN (...)` per table — logging
/// the count removed. Must run before foreign keys are turned on.
Future<void> _deleteOrphanForeignKeyRows(GeneratedDatabase db) async {
  final violations = await db.customSelect('PRAGMA foreign_key_check;').get();
  final rowIdsByTable = <String, Set<int>>{};
  for (final row in violations) {
    final table = row.read<String>('table');
    final rowId = row.read<int>('rowid');
    rowIdsByTable.putIfAbsent(table, () => {}).add(rowId);
  }
  for (final entry in rowIdsByTable.entries) {
    await db.customStatement(
      'DELETE FROM ${entry.key} WHERE rowid IN (${entry.value.join(',')});',
    );
    // ignore: avoid_print
    print(
      'ADR-008 v10 migration: deleted ${entry.value.length} orphan row(s) '
      'from ${entry.key} (dangling foreign key).',
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
