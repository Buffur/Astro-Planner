// Schema snapshot and migration tests (roadmap TASK 3.2, TASK 3.3, ADR-008).
//
// ADR-008 (docs/DECISIONS.md Part F) decided the upgrade floor (v8), the
// migration workflow (Drift schema snapshots + generated verification), and
// removed the v1-v7 upgrade steps (TASK 3.2). TASK 3.3 adds §4-§5: v10
// enforces foreign keys (one-time orphan cleanup, then real ON DELETE
// actions via a rebuild) and drops the orphaned `equipment_profiles` table.
//
// This file is the ADR-008 section 7 test matrix in full:
//   M1  fresh install matches its own declared schema
//   M2  v8 -> v10 data preservation (device/module/rig chain, target,
//       location, session + 2 blocks, equipment_profiles empty and non-empty)
//   M3  v9 -> v10 matches the v10 snapshot exactly
//   M4  v8 -> v10, step by step (in one onUpgrade call, staged by version),
//       matches the v10 snapshot exactly
//   M5  below floor (v3) is refused; file byte-identical afterwards
//   M6  the reset path renames the old file and lets a fresh db be created
//   M7  downgrade (newer-than-app) is refused; file/user_version unchanged
//   M8  orphans before v10 are deleted and counted; legitimate rows survive
//   M9  foreign keys are on after open: an orphan insert throws; deleting a
//       session cascades to its blocks; deleting a referenced device is
//       refused
//   M11 a failure mid-step leaves the file unchanged, because the migration
//       runs inside one transaction
// M10 (the existing repository/database suite, green with FKs on) is the
// rest of `flutter test`, not a dedicated test here.

import 'dart:io';

import 'package:drift/drift.dart' hide isNull;
import 'package:drift/native.dart';
import 'package:drift_dev/api/migrations_native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:path/path.dart' as p;

import 'package:astroplan/data/database/app_database.dart';
import 'package:astroplan/data/database/generated_migrations/schema.dart';
import 'package:astroplan/data/database/generated_migrations/schema_v8.dart'
    show DatabaseAtV8;

/// A minimal [GeneratedDatabase] with no tables, used only to stamp a file's
/// `user_version` to an arbitrary value without going through [AppDatabase]'s
/// own migration (which is exactly what these tests are probing).
class _StampedAtVersion extends GeneratedDatabase {
  _StampedAtVersion(super.e, this.schemaVersion);

  @override
  final int schemaVersion;

  @override
  Iterable<TableInfo> get allTables => const [];

  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => const [];
}

/// [AppDatabase] with a deliberately broken upgrade step: one real statement
/// runs, then it throws. Used by the M11 atomicity test.
class _FailingUpgradeDatabase extends AppDatabase {
  _FailingUpgradeDatabase(super.e);

  @override
  MigrationStrategy get migration {
    return MigrationStrategy(
      onCreate: (m) => m.createAll(),
      onUpgrade: (m, from, to) async {
        await m.database.transaction(() async {
          await m.addColumn(cameraModules, cameraModules.averageRawFileSizeMB);
          throw StateError('injected mid-step failure (M11)');
        });
      },
    );
  }
}

Future<void> _stampFile(File file, int version) async {
  final db = _StampedAtVersion(NativeDatabase(file), version);
  await db.customSelect('SELECT 1').get(); // forces open -> onCreate
  await db.close();
}

Future<Uint8List> _readBytes(File file) => file.readAsBytes();

void main() {
  late SchemaVerifier verifier;

  setUpAll(() {
    verifier = SchemaVerifier(GeneratedHelper());
  });

  group('M1: fresh install', () {
    test(
      'a freshly created database matches its own declared schema',
      () async {
        final db = AppDatabase(NativeDatabase.memory());
        await db.customSelect('SELECT 1').get(); // forces open -> onCreate
        await db.validateDatabaseSchema();
        await db.close();
      },
    );
  });

  group('schema-verification (M3, M4)', () {
    test(
      'M4: v8 -> v10, step by step, matches the v10 snapshot exactly',
      () async {
        final connection = await verifier.startAt(8);
        final db = AppDatabase(connection);
        await verifier.migrateAndValidate(db, 10);
        await db.close();
      },
    );

    test('M3: v9 -> v10 matches the v10 snapshot exactly', () async {
      final connection = await verifier.startAt(9);
      final db = AppDatabase(connection);
      await verifier.migrateAndValidate(db, 10);
      await db.close();
    });
  });

  group('TASK 8.1: v13 (target epoch, provenance, size, magnitude)', () {
    for (final from in [8, 9, 10, 11, 12]) {
      test('v$from -> v13 matches the v13 snapshot exactly', () async {
        final connection = await verifier.startAt(from);
        final db = AppDatabase(connection);
        await verifier.migrateAndValidate(db, 13);
        await db.close();
      });
    }

    test('v12 -> v13: targets keep their data; epoch J2000, provenance and '
        'the new values unknown (never guessed)', () async {
      final schema = await verifier.schemaAt(12);
      schema.rawDatabase.execute(
        "INSERT INTO astro_targets (id, catalog_id, common_name, "
        "right_ascension, declination, type) VALUES "
        "(1, 'M42', 'Orion Nebula', 83.8221, -5.3911, 'Nebula'), "
        "(2, 'M42', 'My M42', 83.8, -5.4, 'Nebula');",
      );
      final db = AppDatabase(schema.newConnection());
      final rows = await (db.select(
        db.astroTargets,
      )..orderBy([(t) => OrderingTerm.asc(t.id)])).get();

      expect(rows, hasLength(2), reason: 'duplicate legacy ids survive');
      expect(rows[0].catalogId, 'M42');
      expect(rows[0].rightAscension, 83.8221);
      expect(rows[0].declination, -5.3911);
      for (final r in rows) {
        expect(r.epoch, 'J2000');
        expect(r.source, isNull);
        expect(r.angularSizeArcmin, isNull);
        expect(r.magnitude, isNull);
      }
      await db.close();
    });

    test('catalog entries are unique per catalog id; user rows are not', () async {
      final db = AppDatabase(NativeDatabase.memory());
      Future<void> insert(String id, String? source) => db.customStatement(
        "INSERT INTO astro_targets (catalog_id, right_ascension, declination, "
        "type, source) VALUES (?, 10.0, 20.0, 'Galaxy', ?)",
        [id, source],
      );
      await insert('M31', 'seed:catalog@1');
      await expectLater(insert('M31', 'catalog:openngc@1'), throwsA(anything));
      await insert('M31', 'user');
      await insert('M31', 'user');
      await insert('M31', null);
      final count = await db
          .customSelect("SELECT COUNT(*) AS c FROM astro_targets")
          .getSingle();
      expect(count.read<int>('c'), 4);
      await db.close();
    });
  });

  group('TASK 7.1: v12 (site semantics)', () {
    for (final from in [8, 9, 10, 11]) {
      test('v$from -> v12 matches the v12 snapshot exactly', () async {
        final connection = await verifier.startAt(from);
        final db = AppDatabase(connection);
        await verifier.migrateAndValidate(db, 12);
        await db.close();
      });
    }

    test('v11 -> v12: the default Bortle 4 becomes NULL with a note; other '
        'values are kept as legacy; coordinates untouched', () async {
      final schema = await verifier.schemaAt(11);
      final raw = schema.rawDatabase;
      raw.execute(
        "INSERT INTO location_profiles (id, name, latitude, longitude, "
        "elevation, bortle_class) VALUES "
        "(1, 'Custom Location', 51.5, -0.1, 0.0, 4), "
        "(2, 'Dark Site', 44.1, 7.2, 1850.0, 2);",
      );
      final db = AppDatabase(schema.newConnection());
      final rows = await (db.select(
        db.locationProfiles,
      )..orderBy([(t) => OrderingTerm.asc(t.id)])).get();

      expect(rows[0].bortleClass, isNull);
      expect(rows[0].bortleSource, isNull);
      expect(rows[0].notes, contains('app default, not a measurement'));
      expect(rows[0].latitude, 51.5);
      expect(rows[0].name, 'Custom Location');

      expect(rows[1].bortleClass, 2);
      expect(rows[1].bortleSource, 'legacy');
      expect(rows[1].bortleDate, isNull);
      expect(rows[1].notes, isNull);
      expect(rows[1].elevation, 1850.0);

      for (final r in rows) {
        expect(r.timeZone, isNull);
        expect(r.sqm, isNull);
      }
      await db.close();
    });
  });

  group('TASK 5.3: v11 (capture-block order, policy, typed gain)', () {
    for (final from in [8, 9, 10]) {
      test('v$from -> v11 matches the v11 snapshot exactly', () async {
        final connection = await verifier.startAt(from);
        final db = AppDatabase(connection);
        await verifier.migrateAndValidate(db, 11);
        await db.close();
      });
    }

    test(
      'v10 -> v11 converts rows: frame type lower-cased, order kept, '
      'calibration outsideWindow, gain_iso -> unknown kind, never guessed',
      () async {
        final schema = await verifier.schemaAt(10);
        final raw = schema.rawDatabase;
        raw.execute(
          "INSERT INTO session_logs (id, target_name, equipment_name, "
          "session_date, planned_light_frames) VALUES "
          "(1, 'M31', 'Rig', 1735689600, 10);",
        );
        final rows = [
          "(1, 1, 'LIGHT', 'Ha', 300.0, 20, 1, '100')",
          "(2, 1, 'dark', NULL, 300.0, 20, 1, 'Unity')",
          "(3, 1, 'Flat', 'Ha', 2.0, 30, 1, NULL)",
          "(4, 1, 'bias', NULL, 0.001, 50, 1, ' 12.5 ')",
        ];
        for (final r in rows) {
          raw.execute(
            'INSERT INTO capture_blocks (id, session_log_id, frame_type, '
            'filter_name, exposure_time_seconds, frame_count, binning, '
            'gain_iso) VALUES $r;',
          );
        }

        final db = AppDatabase(schema.newConnection());
        final blocks = await (db.select(
          db.captureBlocks,
        )..orderBy([(t) => OrderingTerm.asc(t.position)])).get();

        expect(blocks.map((b) => b.id), [1, 2, 3, 4]); // order preserved
        expect(blocks.map((b) => b.position), [1, 2, 3, 4]);
        expect(blocks.map((b) => b.frameType), [
          'light',
          'dark',
          'flat',
          'bias',
        ]);
        expect(blocks.map((b) => b.calibrationPolicy), [
          null,
          'outsideWindow',
          'outsideWindow',
          'outsideWindow',
        ]);
        expect(blocks.every((b) => b.gainKind == 'unknown'), isTrue);
        expect(blocks.map((b) => b.gainValue), [100.0, null, null, 12.5]);
        expect(blocks[0].filterName, 'Ha');
        expect(blocks[3].exposureTimeSeconds, 0.001);

        final cols = await db
            .customSelect(
              "SELECT name FROM pragma_table_info('capture_blocks')",
            )
            .get();
        expect(
          cols.map((r) => r.read<String>('name')),
          isNot(contains('gain_iso')),
        );
        await db.close();
      },
    );
  });

  group('M2: v8 -> v10 data preservation', () {
    test(
      'device/module/rig chain, target, location, session + 2 blocks survive; '
      'equipment_profiles (non-empty) is gone',
      () async {
        final schema = await verifier.schemaAt(8);
        final raw = schema.rawDatabase;

        raw.execute(
          "INSERT INTO devices (id, name, manufacturer, model, notes) "
          "VALUES (1, 'ZWO ASI2600MC', 'ZWO', 'ASI2600MC', NULL);",
        );
        raw.execute(
          "INSERT INTO camera_modules (id, device_id, name, manufacturer, "
          "model, sensor_width_mm, sensor_height_mm, resolution_width_px, "
          "resolution_height_px, pixel_pitch_um, bit_depth) VALUES "
          "(1, 1, 'ZWO ASI2600MC Camera', 'ZWO', 'ASI2600MC', 23.5, 15.7, "
          "6248, 4176, 3.76, 16);",
        );
        raw.execute(
          "INSERT INTO optical_rigs (id, name, camera_module_id, "
          "focal_length_mm, aperture, optical_multiplier, tracking_state, "
          "rotation_degrees) VALUES "
          "(1, 'Test Rig', 1, 600.0, 6.0, 1.0, 'tracking', NULL);",
        );
        raw.execute(
          "INSERT INTO location_profiles (id, name, latitude, longitude, "
          "elevation, bortle_class) VALUES "
          "(1, 'Backyard', 51.5, -0.1, 10.0, 5);",
        );
        raw.execute(
          "INSERT INTO astro_targets (id, catalog_id, common_name, "
          "right_ascension, declination, type) VALUES "
          "(1, 'M31', 'Andromeda Galaxy', 10.68, 41.27, 'Galaxy');",
        );
        raw.execute(
          "INSERT INTO session_logs (id, target_name, equipment_name, "
          "session_date, location_name, bortle_scale, planned_light_frames, "
          "planned_dark_frames, planned_flat_frames, planned_bias_frames, "
          "integration_time_seconds, focal_length, aperture, temperature, "
          "humidity, cloud_cover, actual_light_frames, rejected_frames, "
          "environmental_notes, processing_notes) VALUES "
          "(1, 'M31', 'Test Rig', 1735689600, 'Backyard', 5.0, 100, 20, 10, "
          "10, 3600.0, 600.0, 6.0, -2.5, 60.0, 10, NULL, NULL, NULL, NULL);",
        );
        raw.execute(
          "INSERT INTO capture_blocks (id, session_log_id, frame_type, "
          "filter_name, exposure_time_seconds, frame_count, binning, "
          "gain_iso) VALUES (1, 1, 'LIGHT', 'Ha', 300.0, 20, 1, '100');",
        );
        raw.execute(
          "INSERT INTO capture_blocks (id, session_log_id, frame_type, "
          "filter_name, exposure_time_seconds, frame_count, binning, "
          "gain_iso) VALUES (2, 1, 'DARK', NULL, 300.0, 20, 1, '100');",
        );
        // equipment_profiles: one legacy row, to check that dropping a
        // *non-empty* orphan table (ADR-008 §5) still migrates cleanly.
        raw.execute(
          "INSERT INTO equipment_profiles (id, name, manufacturer, "
          "camera_model, sensor_width, sensor_height, pixel_pitch, "
          "resolution_width, resolution_height, focal_length, aperture, "
          "optical_multiplier, rotation) VALUES "
          "(1, 'Legacy Profile', 'ZWO', 'ASI2600MC', 23.5, 15.7, 3.76, "
          "6248, 4176, 600.0, 6.0, 1.0, NULL);",
        );

        final db = AppDatabase(schema.newConnection());
        // Runs the real onUpgrade (v8 -> v10, staged) via Drift's normal
        // lazy-open path; the schema-equality checks are M3/M4 above.
        await db.customSelect('SELECT 1').get();

        final devices = await db.select(db.devices).get();
        expect(devices, hasLength(1));
        expect(devices.single.name, 'ZWO ASI2600MC');

        final modules = await db.select(db.cameraModules).get();
        expect(modules, hasLength(1));
        // bit_depth was dropped from the Dart model long before v10; the
        // averageRawFileSizeMB column is NULL for a row that predates it
        // (never guessed, SI-008).
        expect(modules.single.averageRawFileSizeMB, isNull);

        final rigs = await db.select(db.opticalRigs).get();
        expect(rigs, hasLength(1));
        expect(rigs.single.focalLengthMm, 600.0);

        final locations = await db.select(db.locationProfiles).get();
        expect(locations, hasLength(1));
        expect(locations.single.name, 'Backyard');

        final targets = await db.select(db.astroTargets).get();
        expect(targets, hasLength(1));
        expect(targets.single.catalogId, 'M31');

        final sessions = await db.select(db.sessionLogs).get();
        expect(sessions, hasLength(1));
        expect(sessions.single.plannedLightFrames, 100);

        final blocks = await db.select(db.captureBlocks).get();
        expect(blocks, hasLength(2));

        // ADR-008 §5: equipment_profiles no longer exists at all.
        final tables = await db
            .customSelect(
              "SELECT name FROM sqlite_master WHERE type = 'table' AND "
              "name = 'equipment_profiles';",
            )
            .get();
        expect(tables, isEmpty);

        await db.close();
      },
    );

    test('an empty equipment_profiles table also migrates cleanly (dropped, no error)', () async {
      final schema = await verifier.schemaAt(8);
      final db = AppDatabase(schema.newConnection());
      await db.customSelect('SELECT 1').get();

      final tables = await db
          .customSelect(
            "SELECT name FROM sqlite_master WHERE type = 'table' AND "
            "name = 'equipment_profiles';",
          )
          .get();
      expect(tables, isEmpty);

      await db.close();
    });
  });

  group('M8: orphan cleanup before v10', () {
    test(
      'an orphan capture_block and an orphan optical_rig are deleted and '
      'counted; legitimate rows survive; foreign_key_check is empty after',
      () async {
        final schema = await verifier.schemaAt(8);
        final raw = schema.rawDatabase;

        // A legitimate chain, to prove cleanup is selective.
        raw.execute(
          "INSERT INTO devices (id, name) VALUES (1, 'Good Device');",
        );
        raw.execute(
          "INSERT INTO camera_modules (id, device_id, name, "
          "sensor_width_mm, sensor_height_mm, resolution_width_px, "
          "resolution_height_px, pixel_pitch_um) VALUES "
          "(1, 1, 'Good Camera', 23.5, 15.7, 6248, 4176, 3.76);",
        );
        raw.execute(
          "INSERT INTO optical_rigs (id, name, camera_module_id, "
          "focal_length_mm, aperture, optical_multiplier, tracking_state) "
          "VALUES (1, 'Good Rig', 1, 600.0, 6.0, 1.0, 'unknown');",
        );
        raw.execute(
          "INSERT INTO session_logs (id, target_name, equipment_name, "
          "session_date, planned_light_frames) VALUES "
          "(1, 'M31', 'Good Rig', 1735689600, 10);",
        );
        raw.execute(
          "INSERT INTO capture_blocks (id, session_log_id, frame_type, "
          "exposure_time_seconds, frame_count) VALUES "
          "(1, 1, 'LIGHT', 300.0, 10);",
        );

        // An orphan optical_rig pointing at a camera module that doesn't
        // exist (id 999).
        raw.execute(
          "INSERT INTO optical_rigs (id, name, camera_module_id, "
          "focal_length_mm, aperture, optical_multiplier, tracking_state) "
          "VALUES (2, 'Orphan Rig', 999, 400.0, 5.0, 1.0, 'unknown');",
        );
        // An orphan capture_block pointing at a session that doesn't exist
        // (id 999) — the exact case TD-005 verified could be inserted.
        raw.execute(
          "INSERT INTO capture_blocks (id, session_log_id, frame_type, "
          "exposure_time_seconds, frame_count) VALUES "
          "(2, 999, 'DARK', 300.0, 5);",
        );

        final db = AppDatabase(schema.newConnection());
        await db.customSelect('SELECT 1').get();

        final rigs = await db.select(db.opticalRigs).get();
        expect(rigs.map((r) => r.id), [1]);

        final blocks = await db.select(db.captureBlocks).get();
        expect(blocks.map((b) => b.id), [1]);

        final violations = await db
            .customSelect('PRAGMA foreign_key_check;')
            .get();
        expect(violations, isEmpty);

        await db.close();
      },
    );
  });

  group('Floor and downgrade guards (ADR-008 §2, TD-047)', () {
    late Directory tempDir;
    late File dbFile;

    setUp(() {
      tempDir = Directory.systemTemp.createTempSync('astroplan_migration_');
      dbFile = File(p.join(tempDir.path, 'astroplan.sqlite'));
    });

    tearDown(() {
      tempDir.deleteSync(recursive: true);
    });

    test(
      'M5: a below-floor database (v3) is refused; file unchanged',
      () async {
        await _stampFile(dbFile, 3);
        final before = await _readBytes(dbFile);

        final db = AppDatabase(NativeDatabase(dbFile));
        await expectLater(
          () => db.customSelect('SELECT 1').get(),
          throwsA(
            isA<UnsupportedSchemaVersionException>()
                .having((e) => e.foundVersion, 'foundVersion', 3)
                .having((e) => e.isNewerThanApp, 'isNewerThanApp', isFalse),
          ),
        );
        try {
          await db.close();
        } catch (_) {
          // A database that failed to open may already be closed internally.
        }

        final after = await _readBytes(dbFile);
        expect(after, equals(before));
      },
    );

    test(
      'M7: a newer-than-app database (v99) is refused; file unchanged',
      () async {
        await _stampFile(dbFile, 99);
        final before = await _readBytes(dbFile);

        final db = AppDatabase(NativeDatabase(dbFile));
        await expectLater(
          () => db.customSelect('SELECT 1').get(),
          throwsA(
            isA<UnsupportedSchemaVersionException>()
                .having((e) => e.foundVersion, 'foundVersion', 99)
                .having((e) => e.isNewerThanApp, 'isNewerThanApp', isTrue),
          ),
        );
        try {
          await db.close();
        } catch (_) {}

        final after = await _readBytes(dbFile);
        expect(after, equals(before));
      },
    );

    test('M6: the reset path renames the old file, content intact, and a fresh '
        'database can then be created at the original path', () async {
      // A below-floor file with a recognizable marker, to check the
      // backup keeps the content rather than just the byte length.
      final probe = _StampedAtVersion(NativeDatabase(dbFile), 3);
      await probe.customStatement(
        'CREATE TABLE marker (id INTEGER PRIMARY KEY, note TEXT);',
      );
      await probe.customStatement(
        "INSERT INTO marker (note) VALUES ('pre-reset content');",
      );
      await probe.close();
      final originalBytes = await _readBytes(dbFile);

      final backup = await resetUnsupportedDatabaseFile(
        dbFile,
        foundVersion: 3,
      );

      expect(await dbFile.exists(), isFalse);
      expect(backup.path, '${dbFile.path}.v3.bak');
      expect(await backup.exists(), isTrue);
      expect(await backup.readAsBytes(), equals(originalBytes));

      // A fresh AppDatabase can now be created at the original path.
      final fresh = AppDatabase(NativeDatabase(dbFile));
      await fresh.customSelect('SELECT 1').get();
      await fresh.validateDatabaseSchema();
      await fresh.close();
    });

    test('M11: a failure mid-step in an upgrade leaves the file unchanged (the '
        'migration runs as one transaction)', () async {
      // A real, physical v8 database (DatabaseAtV8's default onCreate
      // creates the full v8 schema and stamps user_version = 8).
      final v8db = DatabaseAtV8(NativeDatabase(dbFile));
      await v8db.customSelect('SELECT 1').get();
      await v8db.close();
      final before = await _readBytes(dbFile);

      final failing = _FailingUpgradeDatabase(NativeDatabase(dbFile));
      await expectLater(
        () => failing.customSelect('SELECT 1').get(),
        throwsA(isA<StateError>()),
      );
      try {
        await failing.close();
      } catch (_) {}

      final after = await _readBytes(dbFile);
      expect(
        after,
        equals(before),
        reason:
            'the first addColumn ran inside the transaction that the '
            'second statement then failed; both must be rolled back '
            'together, not just the user_version bump',
      );
    });
  });

  group('M9: foreign keys are on after open (ADR-008 §4)', () {
    late AppDatabase db;

    setUp(() {
      db = AppDatabase(NativeDatabase.memory());
    });

    tearDown(() async {
      await db.close();
    });

    test('PRAGMA foreign_keys is on', () async {
      final row = await db.customSelect('PRAGMA foreign_keys;').getSingle();
      expect(row.read<int>('foreign_keys'), 1);
    });

    test('inserting an orphan capture_block throws', () async {
      await expectLater(
        () => db
            .into(db.captureBlocks)
            .insert(
              CaptureBlocksCompanion.insert(
                sessionLogId: 999, // no such session_logs row
                frameType: 'LIGHT',
                exposureTimeSeconds: 60.0,
                frameCount: 10,
              ),
            ),
        throwsA(anything),
      );
    });

    test('deleting a session cascades to its capture blocks', () async {
      final sessionId = await db
          .into(db.sessionLogs)
          .insert(
            SessionLogsCompanion.insert(
              targetName: 'M31',
              equipmentName: 'Test Rig',
              sessionDate: DateTime.utc(2026, 1, 1),
              plannedLightFrames: 10,
            ),
          );
      await db
          .into(db.captureBlocks)
          .insert(
            CaptureBlocksCompanion.insert(
              sessionLogId: sessionId,
              frameType: 'LIGHT',
              exposureTimeSeconds: 60.0,
              frameCount: 10,
            ),
          );

      await (db.delete(
        db.sessionLogs,
      )..where((t) => t.id.equals(sessionId))).go();

      final remainingBlocks = await (db.select(
        db.captureBlocks,
      )..where((t) => t.sessionLogId.equals(sessionId))).get();
      expect(remainingBlocks, isEmpty);
    });

    test(
      'deleting a device that a camera module still references is refused',
      () async {
        final deviceId = await db
            .into(db.devices)
            .insert(DevicesCompanion.insert(name: 'Shared Device'));
        await db
            .into(db.cameraModules)
            .insert(
              CameraModulesCompanion.insert(
                deviceId: deviceId,
                name: 'Shared Camera',
                sensorWidthMm: 23.5,
                sensorHeightMm: 15.7,
                resolutionWidthPx: 6248,
                resolutionHeightPx: 4176,
                pixelPitchUm: 3.76,
              ),
            );

        await expectLater(
          () =>
              (db.delete(db.devices)..where((t) => t.id.equals(deviceId))).go(),
          throwsA(anything),
        );
      },
    );
  });
}
