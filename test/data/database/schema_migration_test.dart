// Schema snapshot and migration tests (roadmap TASK 3.2, ADR-008).
//
// ADR-008 (docs/DECISIONS.md Part F) decided the upgrade floor (v8), the
// migration workflow (Drift schema snapshots + generated verification), and
// that the old v1-v7 upgrade steps be removed: they were written against
// *current* table definitions rather than their own version's, which is the
// root cause of TD-004 (v3 -> v9 threw `no column named optical_multiplier`).
//
// This file is the TASK-3.2 slice of the ADR-008 section 7 test matrix:
//   M1  fresh install matches the v9 snapshot
//   M2  v8 -> v9 data-preservation (device/module/rig chain, target,
//       location, session + 2 blocks, equipment_profiles empty and non-empty)
//   M5  below floor (v3) is refused; file byte-identical afterwards
//   M6  the reset path renames the old file and lets a fresh db be created
//   M7  downgrade (newer-than-app) is refused; file/user_version unchanged
//   M11 a failure mid-step (v8->v9 has two statements) leaves the file
//       unchanged, because the migration runs inside one transaction
// M3/M4/M8-M10 (foreign keys, the orphan table, v10) are TASK 3.3.

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

/// [AppDatabase] with a deliberately broken v8->v9 step: the first statement
/// runs, then it throws. Used by the M11 atomicity test.
class _FailingUpgradeDatabase extends AppDatabase {
  _FailingUpgradeDatabase(super.e);

  @override
  MigrationStrategy get migration {
    return MigrationStrategy(
      onCreate: (m) => m.createAll(),
      onUpgrade: (m, from, to) async {
        await m.database.transaction(() async {
          await m.addColumn(
            equipmentProfiles,
            equipmentProfiles.averageRawFileSizeMB,
          );
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

  group('schema-verification: v8 -> v9', () {
    test(
      'matches the v9 snapshot exactly apart from the three documented '
      'legacy columns (ADR-008 §1, §3: dropping them is TASK 3.3, not 3.2)',
      () async {
        final connection = await verifier.startAt(8);
        final db = AppDatabase(connection);

        // addColumn only adds; it never drops optical_multiplier or
        // bit_depth, so a v8->v9 upgrade keeps them even though the v9 Dart
        // model and a fresh install don't have them. This is the exact,
        // named gap ADR-008 recorded — asserting on it here means an
        // *unexpected* fourth column would still fail this test.
        await expectLater(
          () => verifier.migrateAndValidate(db, 9),
          throwsA(
            isA<SchemaMismatch>().having(
              (e) => e.explanation,
              'explanation',
              allOf(
                contains('equipment_profiles'),
                contains('camera_modules'),
                contains('optical_rigs'),
                contains('optical_multiplier'),
                contains('bit_depth'),
                isNot(contains('average_raw_file_size_m_b')),
              ),
            ),
          ),
        );
        await db.close();
      },
    );
  });

  group('M2: v8 -> v9 data preservation', () {
    test(
      'device/module/rig chain, target, location, session + 2 blocks survive',
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
        // equipment_profiles: one legacy row, to check the M2 "non-empty"
        // case; the "empty" case is covered by the next test.
        raw.execute(
          "INSERT INTO equipment_profiles (id, name, manufacturer, "
          "camera_model, sensor_width, sensor_height, pixel_pitch, "
          "resolution_width, resolution_height, focal_length, aperture, "
          "optical_multiplier, rotation) VALUES "
          "(1, 'Legacy Profile', 'ZWO', 'ASI2600MC', 23.5, 15.7, 3.76, "
          "6248, 4176, 600.0, 6.0, 1.0, NULL);",
        );

        final db = AppDatabase(schema.newConnection());
        // Runs the real onUpgrade (v8 -> v9) via Drift's normal lazy-open
        // path; the strict schema-equality check is the test above, which
        // documents the known legacy-column gap instead of failing on it.
        await db.customSelect('SELECT 1').get();

        final devices = await db.select(db.devices).get();
        expect(devices, hasLength(1));
        expect(devices.single.name, 'ZWO ASI2600MC');

        final modules = await db.select(db.cameraModules).get();
        expect(modules, hasLength(1));
        // bit_depth was dropped from the Dart model; the new column is NULL
        // for a row that predates it (never guessed, SI-008).
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

        final equipmentProfiles = await db.select(db.equipmentProfiles).get();
        expect(equipmentProfiles, hasLength(1));
        expect(equipmentProfiles.single.name, 'Legacy Profile');
        expect(equipmentProfiles.single.averageRawFileSizeMB, isNull);

        await db.close();
      },
    );

    test('an empty equipment_profiles table also upgrades cleanly', () async {
      final schema = await verifier.schemaAt(8);
      final db = AppDatabase(schema.newConnection());
      await db.customSelect('SELECT 1').get();

      final equipmentProfiles = await db.select(db.equipmentProfiles).get();
      expect(equipmentProfiles, isEmpty);

      await db.close();
    });
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
      'M7: a newer-than-app database (v15) is refused; file unchanged',
      () async {
        await _stampFile(dbFile, 15);
        final before = await _readBytes(dbFile);

        final db = AppDatabase(NativeDatabase(dbFile));
        await expectLater(
          () => db.customSelect('SELECT 1').get(),
          throwsA(
            isA<UnsupportedSchemaVersionException>()
                .having((e) => e.foundVersion, 'foundVersion', 15)
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

    test('M11: a failure mid-step in the v8 -> v9 migration leaves the file '
        'unchanged (the migration runs as one transaction)', () async {
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
}
