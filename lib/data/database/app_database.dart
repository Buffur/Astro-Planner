import 'dart:io';

import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;

import 'tables/equipment_foundation_tables.dart';
import 'tables/locations_table.dart';
import 'tables/targets_table.dart';

import 'schema_versions.dart';

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
  // FrameType.name, lower case: light, dark, flat, bias (normalized by v11).
  TextColumn get frameType => text()();
  TextColumn get filterName => text().nullable()();
  RealColumn get exposureTimeSeconds => real()();
  IntColumn get frameCount => integer()();
  IntColumn get binning => integer().withDefault(const Constant(1))();
  // TASK 5.3 (v11): order within the session, ascending. Existing rows
  // received their id, which preserves insertion order.
  IntColumn get position => integer().withDefault(const Constant(0))();
  // CalibrationPolicy.name; NULL for lights (ADR-009 §3).
  TextColumn get calibrationPolicy => text().nullable()();
  // GainKind.name + value, descriptive only (SI-004). Replaced the free-text
  // gain_iso column in v11.
  TextColumn get gainKind => text().withDefault(const Constant('unknown'))();
  RealColumn get gainValue => real().nullable()();
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
  int get schemaVersion => 14;

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
        // Each step is written against its OWN version's generated table
        // shapes (`schema_versions.dart`, `drift_dev schema steps`), never
        // the live Dart tables — ADR-008 §3. The live tables change with
        // every schema bump (TASK 5.3 changed capture_blocks for v11), and a
        // step that rebuilt against them would silently produce the newest
        // shape mid-chain: the root cause of TD-004 / DEV-D1.
        // The whole chain runs inside one transaction, so a failure
        // mid-step leaves the file completely unchanged (ADR-008 §3;
        // verified by a test that injects a failure partway through).
        await m.database.transaction(() async {
          await m.runMigrationSteps(
            from: from,
            to: to,
            steps: migrationSteps(
              from8To9: (m, schema) async {
                await m.addColumn(
                  schema.cameraModules,
                  schema.cameraModules.averageRawFileSizeMB,
                );
                // No equipment_profiles step: that table is dropped by the
                // v10 step, in the same transaction.
              },
              from9To10: (m, schema) async {
                // ADR-008 §4: clean up pre-existing orphans while foreign
                // keys are still off (beforeOpen turns them on afterwards).
                await _deleteOrphanForeignKeyRows(m.database);

                // SQLite can't alter a foreign key's ON DELETE action or
                // drop a column in place: rebuild against the v10 shapes.
                // This also drops the legacy bit_depth/optical_multiplier
                // columns that addColumn-only upgrades left behind.
                await m.alterTable(TableMigration(schema.cameraModules));
                await m.alterTable(TableMigration(schema.opticalRigs));
                await m.alterTable(TableMigration(schema.captureBlocks));

                // ADR-008 §5: the orphaned flat table is retired.
                await m.deleteTable('equipment_profiles');

                final remaining = await m.database
                    .customSelect('PRAGMA foreign_key_check;')
                    .get();
                if (remaining.isNotEmpty) {
                  throw StateError(
                    'ADR-008 v10 migration: foreign_key_check still found '
                    '${remaining.length} violation(s) after cleanup: '
                    '$remaining',
                  );
                }
              },
              from10To11: (m, schema) async {
                // TASK 5.3 (ADR-009 §3, SI-004): capture blocks gain an
                // order, a calibration policy and a typed gain; the
                // free-text gain_iso column is converted, then dropped
                // (owner-approved, ADR-008 §3).
                final blocks = schema.captureBlocks;
                await m.alterTable(
                  TableMigration(
                    blocks,
                    newColumns: [
                      blocks.position,
                      blocks.calibrationPolicy,
                      blocks.gainKind,
                      blocks.gainValue,
                    ],
                    columnTransformer: {
                      // Older rows and fixtures used upper case.
                      blocks.frameType: const CustomExpression<String>(
                        'lower(trim(frame_type))',
                      ),
                      // Existing order = insertion order.
                      blocks.position: const CustomExpression<int>('id'),
                      // ADR-009 §3: calibration defaults to outside the
                      // window; lights have no policy.
                      blocks.calibrationPolicy: const CustomExpression<String>(
                        "CASE WHEN lower(trim(frame_type)) = 'light' "
                        "THEN NULL ELSE 'outsideWindow' END",
                      ),
                      // The old text can't tell ISO from gain: never
                      // guessed, recorded as unknown.
                      blocks.gainKind: const CustomExpression<String>(
                        "'unknown'",
                      ),
                      // A plain non-negative number is kept as the value;
                      // anything else (blank, text, mixed) becomes NULL.
                      blocks.gainValue: const CustomExpression<double>(
                        "CASE WHEN gain_iso IS NOT NULL "
                        "AND trim(gain_iso) <> '' "
                        "AND trim(gain_iso) NOT GLOB '*[^0-9.]*' "
                        "AND trim(gain_iso) GLOB '*[0-9]*' "
                        "THEN CAST(trim(gain_iso) AS REAL) ELSE NULL END",
                      ),
                    },
                  ),
                );
              },
              from11To12: (m, schema) async {
                // TASK 7.1 (owner decisions): sites gain nullable Bortle with
                // its source and date, SQM, an IANA zone and notes. Bortle
                // becomes nullable, which needs a rebuild (SQLite cannot drop
                // a NOT NULL/DEFAULT in place). A stored 4 was the app's
                // default, never a measurement (the badge was hidden and the
                // scraper never succeeded): it becomes NULL with a note.
                // Any other value is kept, marked `legacy`.
                final sites = schema.locationProfiles;
                await m.alterTable(
                  TableMigration(
                    sites,
                    newColumns: [
                      sites.bortleSource,
                      sites.bortleDate,
                      sites.sqm,
                      sites.sqmSource,
                      sites.sqmDate,
                      sites.timeZone,
                      sites.notes,
                    ],
                    columnTransformer: {
                      sites.bortleClass: const CustomExpression<int>(
                        'CASE WHEN bortle_class = 4 THEN NULL '
                        'ELSE bortle_class END',
                      ),
                      sites.bortleSource: const CustomExpression<String>(
                        "CASE WHEN bortle_class IS NULL OR bortle_class = 4 "
                        "THEN NULL ELSE 'legacy' END",
                      ),
                      sites.notes: const CustomExpression<String>(
                        "CASE WHEN bortle_class = 4 THEN 'Bortle: the stored "
                        "value 4 was the app default, not a measurement; "
                        "cleared in schema v12.' ELSE NULL END",
                      ),
                    },
                  ),
                );
              },
              from12To13: (m, schema) async {
                // TASK 8.1: targets gain an epoch (default J2000 — the
                // calculators have always treated every target as J2000,
                // TASK 6.2), provenance (NULL for legacy rows: seeded and
                // user rows cannot be told apart, ADR-008 §6), angular size
                // and magnitude (unknown). The partial unique index covers
                // catalog entries only, so no legacy row can conflict.
                final targets = schema.astroTargets;
                await m.addColumn(targets, targets.epoch);
                await m.addColumn(targets, targets.source);
                await m.addColumn(targets, targets.angularSizeArcmin);
                await m.addColumn(targets, targets.magnitude);
                await m.create(schema.astroTargetsCatalogIdUnique);
              },
              from13To14: (m, schema) async {
                // TASK 8.4 (ADR-011): optional aperture diameter and maximum
                // exposure per rig. Additive only: the `aperture` column keeps
                // every stored value exactly (read as the focal ratio N; a
                // value above 32 is flagged for review in the UI, never
                // converted), and `tracking_state` keeps `unknown`.
                final rigs = schema.opticalRigs;
                await m.addColumn(rigs, rigs.apertureDiameterMm);
                await m.addColumn(rigs, rigs.maxExposureS);
              },
            ),
          );
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
