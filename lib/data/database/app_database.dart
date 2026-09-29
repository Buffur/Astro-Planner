import 'dart:io';

import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:drift/isolate.dart' show DriftRemoteException;
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;

import 'tables/equipment_foundation_tables.dart';
import 'tables/locations_table.dart';
import 'tables/targets_table.dart';

import '../../core/diagnostics/app_log.dart';
import 'json_map_converter.dart';
import 'storage_failure_interceptor.dart';
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

  // TASK 11.2 (v16, ADR-014 §2): execution counters. The planned count is
  // the existing frame_count; these start at 0 (nothing captured yet). For
  // legacy sessions (session_logs.legacy) they carry no information.
  IntColumn get completedFrames => integer().withDefault(const Constant(0))();
  IntColumn get rejectedFrames => integer().withDefault(const Constant(0))();
}

/// The Session aggregate root (ADR-014; evolved in place in v16, TASK
/// 11.2). The columns up to `processing_notes` are the pre-v16 log and stay
/// for legacy rows; new code writes the v16 columns.
@TableIndex(name: 'session_logs_status', columns: {#status})
@TableIndex(name: 'session_logs_evening_date', columns: {#eveningDate})
@TableIndex(name: 'session_logs_target_id', columns: {#targetId})
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

  // --- TASK 11.2 (v16, ADR-014) -------------------------------------------

  /// draft | planned | inProgress | completed | abandoned (ADR-014 §3).
  // Drift's documented column-CHECK pattern: the generator reads the
  // expression; the getter is never evaluated recursively at run time.
  TextColumn get status => text()
      .check(
        // ignore: recursive_getters
        status.isIn(const [
          'draft',
          'planned',
          'inProgress',
          'completed',
          'abandoned',
        ]),
      )
      .withDefault(const Constant('draft'))();

  /// True for rows saved before v16 (ADR-014 §7): completed, read-only,
  /// shown from the text columns above; no snapshot, no references.
  BoolColumn get legacy => boolean().withDefault(const Constant(false))();

  /// Night key (ADR-014 §2): the civil evening date `YYYY-MM-DD` and the zone
  /// id it was resolved in; NULL for legacy rows.
  TextColumn get eveningDate => text().nullable()();
  TextColumn get timeZoneId => text().nullable()();

  /// Stable references (ADR-014 §2): deleting a source never deletes or
  /// blocks a session.
  IntColumn get siteId => integer().nullable().references(
    LocationProfiles,
    #id,
    onDelete: KeyAction.setNull,
  )();
  IntColumn get targetId => integer().nullable().references(
    AstroTargets,
    #id,
    onDelete: KeyAction.setNull,
  )();
  IntColumn get rigId => integer().nullable().references(
    OpticalRigs,
    #id,
    onDelete: KeyAction.setNull,
  )();

  /// Lifecycle instants, UTC epoch milliseconds; NULL = not reached (or
  /// unknown for legacy rows).
  IntColumn get createdAtUtcMs => integer().nullable()();
  IntColumn get updatedAtUtcMs => integer().nullable()();
  IntColumn get plannedAtUtcMs => integer().nullable()();
  IntColumn get startedAtUtcMs => integer().nullable()();
  IntColumn get completedAtUtcMs => integer().nullable()();

  /// Versioned JSON snapshots (ADR-014 §4): the plan (refreshed on each
  /// Save) and the execution start (frozen).
  TextColumn get planSnapshot =>
      text().nullable().map(const JsonMapConverter())();
  TextColumn get executionStartSnapshot =>
      text().nullable().map(const JsonMapConverter())();

  /// The plan's tracking override (RD-08 = T3; S7.1, v19): `untracked`,
  /// `tracked` or `guided`; NULL = the rig's default.
  TextColumn get trackingOverride => text().nullable()();
}

/// A session's run, append-only (ADR-016 §4; TASK 13.2, v17). The events
/// are the record of truth; `capture_blocks.completed_frames` /
/// `rejected_frames` are a projection written in the same transaction.
@TableIndex(
  name: 'session_events_session_seq',
  columns: {#sessionLogId, #seq},
  unique: true,
)
class SessionEvents extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get sessionLogId =>
      integer().references(SessionLogs, #id, onDelete: KeyAction.cascade)();

  /// Orders the events of one session (never the timestamp, ADR-016 §5).
  IntColumn get seq => integer()();
  IntColumn get atUtcMs => integer()();

  /// ExecutionEventKind.name.
  TextColumn get kind => text().check(
    // ignore: recursive_getters
    kind.isIn(const [
      'started',
      'blockSelected',
      'paused',
      'interrupted',
      'resumed',
      'framesConfirmed',
      'framesRejected',
      'finished',
      'abandoned',
    ]),
  )();

  /// The block concerned, when any. The plan is frozen while a session is
  /// in progress, so its blocks outlive its events.
  IntColumn get blockId => integer().nullable().references(
    CaptureBlocks,
    #id,
    onDelete: KeyAction.cascade,
  )();
  IntColumn get delta => integer().nullable()();

  /// InterruptionReason.name, for interruptions.
  TextColumn get reason => text().nullable()();
  BoolColumn get clockAdjusted =>
      boolean().withDefault(const Constant(false))();
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
    SessionEvents,
  ],
)
class AppDatabase extends _$AppDatabase {
  /// Every statement error surfaces as a `StorageFailure` (TASK 15.1).
  AppDatabase([QueryExecutor? e])
    : super(
        (e ?? _openConnection()).interceptWith(StorageFailureInterceptor()),
      );

  @override
  int get schemaVersion => 19;

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
              from14To15: (m, schema) async {
                // TASK 8.5 (ADR-008 §6): provenance of the camera and optics
                // specs. Existing rows stay NULL (unknown): seeded and
                // user-entered rows cannot be told apart, so nothing is
                // back-filled.
                final cams = schema.cameraModules;
                final rigs = schema.opticalRigs;
                await m.addColumn(cams, cams.source);
                await m.addColumn(cams, cams.confidence);
                await m.addColumn(rigs, rigs.source);
                await m.addColumn(rigs, rigs.confidence);
              },
              from15To16: (m, schema) async {
                // TASK 11.2 (ADR-014): session_logs becomes the Session
                // aggregate root, evolved in place. Additive only: every
                // stored value is kept. References are nullable with
                // ON DELETE SET NULL (never guessed from the old name
                // columns, owner decision).
                final sessions = schema.sessionLogs;
                for (final column in [
                  sessions.status,
                  sessions.legacy,
                  sessions.eveningDate,
                  sessions.timeZoneId,
                  sessions.siteId,
                  sessions.targetId,
                  sessions.rigId,
                  sessions.createdAtUtcMs,
                  sessions.updatedAtUtcMs,
                  sessions.plannedAtUtcMs,
                  sessions.startedAtUtcMs,
                  sessions.completedAtUtcMs,
                  sessions.planSnapshot,
                  sessions.executionStartSnapshot,
                ]) {
                  await m.addColumn(sessions, column);
                }
                // ADR-014 §7 (owner): every existing row is a completed,
                // read-only legacy session.
                await m.database.customStatement(
                  "UPDATE session_logs SET status = 'completed', legacy = 1;",
                );

                final blocks = schema.captureBlocks;
                await m.addColumn(blocks, blocks.completedFrames);
                await m.addColumn(blocks, blocks.rejectedFrames);

                await m.create(schema.sessionLogsStatus);
                await m.create(schema.sessionLogsEveningDate);
                await m.create(schema.sessionLogsTargetId);
              },
              from16To17: (m, schema) async {
                // TASK 13.2 (ADR-016 §4): the append-only execution events.
                // New table only; no existing row changes.
                await m.createTable(schema.sessionEvents);
                await m.create(schema.sessionEventsSessionSeq);
              },
              from17To18: (m, schema) async {
                // S3.4 (ADR-018 §5): per-field provenance and the metadata
                // identity. Additive only; existing rows keep NULL, so each
                // field falls back to its group's provenance (nothing is
                // back-filled, ADR-008 §6).
                final cams = schema.cameraModules;
                for (final column in [
                  cams.resolutionSource,
                  cams.resolutionConfidence,
                  cams.pixelPitchSource,
                  cams.pixelPitchConfidence,
                  cams.sensorSizeSource,
                  cams.sensorSizeConfidence,
                  cams.rawFileSizeSource,
                  cams.rawFileSizeConfidence,
                  cams.metadataMake,
                  cams.metadataModel,
                ]) {
                  await m.addColumn(cams, column);
                }
                final rigs = schema.opticalRigs;
                for (final column in [
                  rigs.focalLengthSource,
                  rigs.focalLengthConfidence,
                  rigs.focalRatioSource,
                  rigs.focalRatioConfidence,
                ]) {
                  await m.addColumn(rigs, column);
                }
              },
              from18To19: (m, schema) async {
                // S7.1 (RD-08 = T3): the plan's tracking override. Additive
                // only; every existing plan keeps NULL, the rig's default,
                // which is what it used before (no override existed).
                await m.addColumn(
                  schema.sessionLogs,
                  schema.sessionLogs.trackingOverride,
                );
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

LazyDatabase _openConnection() => openDatabaseConnection(databaseFile);

/// The app's connection to the file [file] resolves to: opened lazily, on a
/// background isolate. Tests of the startup path use this same shape (S1.V1).
LazyDatabase openDatabaseConnection(Future<File> Function() file) =>
    LazyDatabase(() async => NativeDatabase.createInBackground(await file()));

/// The app's database file.
Future<File> databaseFile() async {
  final dbFolder = await getApplicationDocumentsDirectory();
  return File(p.join(dbFolder.path, 'astroplan.sqlite'));
}

/// Opens [database] and returns the refusal when its file is at a schema
/// version this app cannot open (ADR-008 §2), or null when it opens. Any
/// other error is rethrown. The refused file is left unchanged (S1.5).
///
/// On the app's background connection Drift delivers the refusal wrapped in
/// a [DriftRemoteException] whose cause is the original, typed exception;
/// it is unwrapped here (S1.V1, TD-059). A cause that is not that type (for
/// example only its text, over a serializing channel) stays an error.
Future<UnsupportedSchemaVersionException?> refusedSchemaVersion(
  AppDatabase database,
) async {
  try {
    await database.customSelect('SELECT 1').get();
    return null;
  } on UnsupportedSchemaVersionException catch (e) {
    return e;
  } on DriftRemoteException catch (e) {
    Object cause = e;
    while (cause is DriftRemoteException) {
      cause = cause.remoteCause;
    }
    if (cause is UnsupportedSchemaVersionException) return cause;
    rethrow;
  }
}

/// The confirmed reset of a refused below-floor database (ADR-008 §2,
/// S1.5): closes [database] — a close that fails after the refused open is
/// logged, and the file is still renamed — then keeps the file as
/// `<name>.v<N>.bak`. Never for a database newer than the app.
Future<File> resetRefusedDatabase(
  AppDatabase database,
  File file,
  UnsupportedSchemaVersionException refused,
) async {
  if (refused.isNewerThanApp) {
    throw ArgumentError.value(refused, 'refused', 'newer databases are kept');
  }
  try {
    await database.close();
  } catch (e) {
    AppLog.warning('startup', 'Close after a refused open failed', error: e);
  }
  return resetUnsupportedDatabaseFile(file, foundVersion: refused.foundVersion);
}

/// The reset path for a below-floor database (ADR-008 §2): renames [file] to
/// `<name>.v<foundVersion>.bak` (never deletes it) so a fresh database can be
/// created at the original path.
///
/// This performs the file move only. Callers are responsible for asking the
/// user to confirm first (ADR-008: "on the user's explicit confirmation ...
/// without confirmation, nothing is touched"), for closing the database
/// first, and for constructing a new [AppDatabase] afterwards, which creates
/// a fresh database at the current schema on first use. Called from the
/// startup recovery screen (`main.dart`, S1.5); never for a database newer
/// than the app (ADR-008 §2).
Future<File> resetUnsupportedDatabaseFile(
  File file, {
  required int foundVersion,
}) async {
  final backupPath = '${file.path}.v$foundVersion.bak';
  return file.rename(backupPath);
}
