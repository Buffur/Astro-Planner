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
// Later schema versions add their own groups (v11-v23), each with an
// every-version-to-N schema test and a data-preservation test.
// M10 (the existing repository/database suite, green with FKs on) is the
// rest of `flutter test`, not a dedicated test here.

import 'dart:io';

import 'package:drift/drift.dart' hide isNull, isNotNull;
import 'package:drift/native.dart';
import 'package:drift_dev/api/migrations_native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:path/path.dart' as p;

import 'package:astroplan/data/database/app_database.dart';
import 'package:astroplan/data/database/json_map_converter.dart';
import 'package:astroplan/data/repositories/drift_session_repository.dart';
import 'package:astroplan/domain/models/camera_class.dart';
import 'package:astroplan/domain/models/session.dart' show SessionResults;
import 'package:astroplan/data/repositories/drift_equipment_repository.dart';
import 'package:astroplan/data/repositories/drift_location_repository.dart';
import 'package:astroplan/data/repositories/drift_target_repository.dart';
import 'package:astroplan/domain/models/location_profile.dart' as domain;
import 'package:astroplan/domain/models/spec_confidence.dart';
import 'package:astroplan/domain/models/spec_provenance.dart';
import 'package:astroplan/domain/models/tracking_type.dart';
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

  group('S8.1: v24 (results without a run, ADR-019 §4)', () {
    for (final from in [
      8, 9, 10, 11, 12, 13, 14, 15, 16, 17, 18, 19, 20, 21, 22, 23, //
    ]) {
      test('v$from -> v24 matches the v24 snapshot exactly', () async {
        final connection = await verifier.startAt(from);
        final db = AppDatabase(connection);
        await verifier.migrateAndValidate(db, 24);
        await db.close();
      });
    }

    test('v23 -> v24: every session, block, event and counter kept; no '
        'result kind or reason is invented; `reported` can now be '
        'stored', () async {
      final schema = await verifier.schemaAt(23);
      final raw = schema.rawDatabase;
      raw.execute(
        "INSERT INTO session_logs (id, target_name, equipment_name, "
        "session_date, planned_light_frames, status, legacy, evening_date, "
        "time_zone_id, started_at_utc_ms, completed_at_utc_ms, "
        "actual_light_frames, rejected_frames, environmental_notes) VALUES "
        "(1, 'M42', 'Rig', 1790000000, 10, 'completed', 0, '2026-12-15', "
        "'Europe/Ljubljana', 1790000000000, 1790003600000, 3, 1, 'Dew'), "
        "(2, 'M31', 'Rig', 1790000000, 5, 'abandoned', 0, '2026-12-16', "
        "NULL, NULL, NULL, NULL, NULL, NULL), "
        "(3, 'M45', 'Rig', 1790000000, 5, 'inProgress', 0, '2026-12-17', "
        "NULL, 1790000000000, NULL, NULL, NULL, NULL), "
        "(4, 'Old', 'Old rig', 1690000000, 7, 'completed', 1, NULL, "
        "NULL, NULL, NULL, 7, 0, 'legacy');",
      );
      raw.execute(
        "INSERT INTO capture_blocks (id, session_log_id, frame_type, "
        "exposure_time_seconds, frame_count, position, completed_frames, "
        "rejected_frames) VALUES (1, 1, 'light', 60.0, 10, 0, 3, 1), "
        "(2, 3, 'light', 120.0, 5, 0, 2, 0);",
      );
      raw.execute(
        "INSERT INTO session_events (id, session_log_id, seq, at_utc_ms, "
        "kind, block_id, delta, reason, clock_adjusted) VALUES "
        "(1, 1, 1, 1790000000000, 'started', 1, NULL, NULL, 0), "
        "(2, 1, 2, 1790000060000, 'framesConfirmed', 1, 3, NULL, 0), "
        "(3, 1, 3, 1790000070000, 'interrupted', NULL, NULL, 'clouds', 1), "
        "(4, 1, 4, 1790000080000, 'resumed', NULL, NULL, NULL, 0), "
        "(5, 1, 5, 1790000090000, 'framesRejected', 1, 1, NULL, 0), "
        "(6, 1, 6, 1790003600000, 'finished', NULL, NULL, NULL, 0), "
        "(7, 3, 1, 1790000000000, 'started', 2, NULL, NULL, 0), "
        "(8, 3, 2, 1790000060000, 'framesConfirmed', 2, 2, NULL, 0);",
      );

      final db = AppDatabase(schema.newConnection());
      final rows = await (db.select(
        db.sessionLogs,
      )..orderBy([(t) => OrderingTerm.asc(t.id)])).get();
      expect(rows.map((r) => r.status), [
        'completed',
        'abandoned',
        'inProgress',
        'completed',
      ]);
      expect(rows.map((r) => (r.resultKind, r.notDoneReason)), [
        for (var i = 0; i < 4; i++) (null, null),
      ]);
      expect((rows[0].actualLightFrames, rows[0].rejectedFrames), (3, 1));
      expect(rows[0].environmentalNotes, 'Dew');
      expect(rows[3].legacy, isTrue);
      final events = await (db.select(
        db.sessionEvents,
      )..orderBy([(t) => OrderingTerm.asc(t.id)])).get();
      expect(events.map((e) => (e.sessionLogId, e.seq, e.kind)), [
        (1, 1, 'started'),
        (1, 2, 'framesConfirmed'),
        (1, 3, 'interrupted'),
        (1, 4, 'resumed'),
        (1, 5, 'framesRejected'),
        (1, 6, 'finished'),
        (3, 1, 'started'),
        (3, 2, 'framesConfirmed'),
      ]);
      expect(
        (events[2].reason, events[2].clockAdjusted, events[1].delta),
        ('clouds', true, 3),
      );
      final blocks = await (db.select(
        db.captureBlocks,
      )..orderBy([(t) => OrderingTerm.asc(t.id)])).get();
      expect(blocks.map((b) => (b.completedFrames, b.rejectedFrames)), [
        (3, 1),
        (2, 0),
      ]);
      final repo = DriftSessionRepository(db);
      final replay = await repo.execution(1);
      expect((replay.completedFor(1), replay.rejectedFor(1)), (3, 1));

      await db.customStatement(
        "INSERT INTO session_events (session_log_id, seq, at_utc_ms, kind) "
        "VALUES (2, 1, 1790000000000, 'reported');",
      );
      await expectLater(
        db.customStatement(
          "INSERT INTO session_events (session_log_id, seq, at_utc_ms, kind) "
          "VALUES (2, 2, 1790000000000, 'teleported');",
        ),
        throwsA(anything),
      );
      await db.close();
    });
  });

  group('S7.5: v23 (elevation nullable, RG-08 = E2)', () {
    for (final from in [
      8, 9, 10, 11, 12, 13, 14, 15, 16, 17, 18, 19, 20, 21, 22, //
    ]) {
      test('v$from -> v23 matches the v23 snapshot exactly', () async {
        final connection = await verifier.startAt(from);
        final db = AppDatabase(connection);
        await verifier.migrateAndValidate(db, 23);
        await db.close();
      });
    }

    test('v22 -> v23: every site value kept exactly (a legacy 0 stays 0), '
        "the plans' site references kept; unknown can now be stored", () async {
      final schema = await verifier.schemaAt(22);
      final raw = schema.rawDatabase;
      raw.execute(
        "INSERT INTO location_profiles (id, name, latitude, longitude, "
        "elevation, bortle_class, bortle_source, bortle_date, sqm, "
        "sqm_source, sqm_date, time_zone, notes) VALUES "
        "(1, 'Home', 46.05, 14.51, 295.5, 4, 'user', '2026-09-01', 20.8, "
        "'meter', '2026-08-30', 'Europe/Ljubljana', 'Gate code 12'), "
        "(2, 'Old GPS fix', 45.0, 13.0, 0.0, NULL, NULL, NULL, NULL, NULL, "
        "NULL, NULL, NULL);",
      );
      raw.execute(
        "INSERT INTO session_logs (id, target_name, equipment_name, "
        "session_date, planned_light_frames, status, legacy, evening_date, "
        "time_zone_id, site_id, planned_at_utc_ms) VALUES "
        "(1, 'M42', 'Rig', 1790000000, 10, 'planned', 0, '2026-12-15', "
        "'Europe/Ljubljana', 1, 1790000000000);",
      );

      final db = AppDatabase(schema.newConnection());
      final sites = DriftLocationRepository(db);
      final all = await sites.getLocations();
      final home = all.firstWhere((s) => s.id == 1);
      expect(
        (home.name, home.latitude, home.longitude, home.elevation),
        ('Home', 46.05, 14.51, 295.5),
      );
      expect((home.bortleClass, home.bortleSource), (4, 'user'));
      expect((home.sqm, home.sqmSource), (20.8, 'meter'));
      expect(
        (home.timeZoneId, home.notes),
        ('Europe/Ljubljana', 'Gate code 12'),
      );
      expect(all.firstWhere((s) => s.id == 2).elevation, 0.0);
      expect((await db.select(db.sessionLogs).getSingle()).siteId, 1);

      final id = await sites.insertLocation(
        domain.LocationProfile(
          id: 0,
          name: 'Unknown height',
          latitude: 1,
          longitude: 2,
        ),
      );
      expect((await sites.getLocationById(id))!.elevation, isNull);
      await db.close();
    });
  });

  group('S7.4: v22 (the catalog aliases, RG-07 = T1)', () {
    for (final from in [8, 9, 10, 11, 12, 13, 14, 15, 16, 17, 18, 19, 20, 21]) {
      test('v$from -> v22 matches the v22 snapshot exactly', () async {
        final connection = await verifier.startAt(from);
        final db = AppDatabase(connection);
        await verifier.migrateAndValidate(db, 22);
        await db.close();
      });
    }

    test('v21 -> v22: every target, custom and catalog, and a plan\'s '
        'reference kept; the new alias table starts empty', () async {
      final schema = await verifier.schemaAt(21);
      final raw = schema.rawDatabase;
      raw.execute(
        "INSERT INTO astro_targets (id, catalog_id, common_name, "
        "right_ascension, declination, type, source) VALUES "
        "(7, 'M31', 'My Andromeda', 10.68, 41.27, 'Galaxy', "
        "'catalog:openngc@v20260501'), "
        "(9, 'Backyard field', NULL, 120.5, -10.25, 'Other', 'user');",
      );
      raw.execute(
        "INSERT INTO session_logs (id, target_name, equipment_name, "
        "session_date, planned_light_frames, status, legacy, evening_date, "
        "time_zone_id, target_id, planned_at_utc_ms) VALUES "
        "(1, 'My Andromeda', 'Rig', 1790000000, 10, 'planned', 0, "
        "'2026-12-15', 'Europe/Ljubljana', 7, 1790000000000);",
      );

      final db = AppDatabase(schema.newConnection());
      expect(await db.select(db.targetAliases).get(), isEmpty);
      final targets = DriftTargetRepository(db);
      expect(await targets.aliasCatalogVersion(), isNull);
      final all = await targets.getAllTargets();
      expect(
        [for (final t in all) (t.id, t.catalogId, t.commonName, t.source)],
        [
          (7, 'M31', 'My Andromeda', 'catalog:openngc@v20260501'),
          (9, 'Backyard field', null, 'user'),
        ],
      );
      final plan = await db.select(db.sessionLogs).getSingle();
      expect(plan.targetId, 7);
      await db.close();
    });
  });

  group('S7.3b: v21 (in-camera noise reduction, ADR-020 §8)', () {
    for (final from in [8, 9, 10, 11, 12, 13, 14, 15, 16, 17, 18, 19, 20]) {
      test('v$from -> v21 matches the v21 snapshot exactly', () async {
        final connection = await verifier.startAt(from);
        final db = AppDatabase(connection);
        await verifier.migrateAndValidate(db, 21);
        await db.close();
      });
    }

    test('v20 -> v21: every camera and rig kept, its class too; noise '
        'reduction off, never inferred', () async {
      final schema = await verifier.schemaAt(20);
      final raw = schema.rawDatabase;
      raw.execute("INSERT INTO devices (id, name) VALUES (1, 'Rig');");
      raw.execute(
        "INSERT INTO camera_modules (id, device_id, name, manufacturer, "
        "model, sensor_width_mm, sensor_height_mm, resolution_width_px, "
        "resolution_height_px, pixel_pitch_um, source, confidence, "
        "camera_class) VALUES (1, 1, 'Rig Camera', 'Canon', 'EOS R6', 35.9, "
        "23.9, 5472, 3648, 6.56, 'user', 'reported', 'dslrMirrorless');",
      );
      raw.execute(
        "INSERT INTO optical_rigs (id, name, camera_module_id, "
        "focal_length_mm, aperture, tracking_state) VALUES (1, 'Rig', 1, "
        "135.0, 2.8, 'tracked');",
      );
      final db = AppDatabase(schema.newConnection());
      final p = (await DriftEquipmentRepository(db).getAllEquipment()).single;
      expect(p.inCameraNoiseReduction, isFalse);
      expect(p.noiseReductionApplies, isFalse);
      expect(p.cameraClass, CameraClass.dslrMirrorless);
      expect(p.cameraModel, 'EOS R6');
      expect(p.pixelPitchUm, 6.56);
      expect(p.trackingType, TrackingType.tracked);
      await db.close();
    });
  });

  group('S7.2a: v20 (the camera class, ADR-020 §2)', () {
    for (final from in [8, 9, 10, 11, 12, 13, 14, 15, 16, 17, 18, 19]) {
      test('v$from -> v20 matches the v20 snapshot exactly', () async {
        final connection = await verifier.startAt(from);
        final db = AppDatabase(connection);
        await verifier.migrateAndValidate(db, 20);
        await db.close();
      });
    }

    test('v19 -> v20: every camera and rig kept; each camera Unknown, never '
        'inferred', () async {
      final schema = await verifier.schemaAt(19);
      final raw = schema.rawDatabase;
      raw.execute("INSERT INTO devices (id, name) VALUES (1, 'Rig');");
      raw.execute(
        "INSERT INTO camera_modules (id, device_id, name, manufacturer, "
        "model, sensor_width_mm, sensor_height_mm, resolution_width_px, "
        "resolution_height_px, pixel_pitch_um, source, confidence, "
        "metadata_make, metadata_model) VALUES (1, 1, 'Rig Camera', 'ZWO', "
        "'ASI2600MC', 23.5, 15.7, 6248, 4176, 3.76, 'seed:equipment@2', "
        "'verified', 'ZWO', 'ASI2600MC Pro');",
      );
      raw.execute(
        "INSERT INTO optical_rigs (id, name, camera_module_id, "
        "focal_length_mm, aperture, tracking_state) VALUES (1, 'Rig', 1, "
        "400.0, 5.6, 'guided');",
      );
      final db = AppDatabase(schema.newConnection());
      final p = (await DriftEquipmentRepository(db).getAllEquipment()).single;
      expect(p.cameraClass, CameraClass.unknown);
      expect(p.cameraModel, 'ASI2600MC');
      expect(p.pixelPitchUm, 3.76);
      expect(p.trackingType, TrackingType.guided);
      expect(p.metadataModel, 'ASI2600MC Pro');
      await db.close();
    });
  });

  group("S7.1: v19 (the plan's tracking override, RD-08 = T3)", () {
    for (final from in [8, 9, 10, 11, 12, 13, 14, 15, 16, 17, 18]) {
      test('v$from -> v19 matches the v19 snapshot exactly', () async {
        final connection = await verifier.startAt(from);
        final db = AppDatabase(connection);
        await verifier.migrateAndValidate(db, 19);
        await db.close();
      });
    }

    test('v18 -> v19: every plan and its snapshot kept; no override, so each '
        "plan uses its rig's default, as it did", () async {
      final schema = await verifier.schemaAt(18);
      final raw = schema.rawDatabase;
      raw.execute(
        "INSERT INTO session_logs (id, target_name, equipment_name, "
        "session_date, planned_light_frames, status, legacy, evening_date, "
        "time_zone_id, planned_at_utc_ms, plan_snapshot) VALUES "
        "(1, 'M42', 'Rig', 1790000000, 10, 'planned', 0, '2026-12-15', "
        "'Europe/Ljubljana', 1790000000000, '{\"v\":1,\"rig\":null}');",
      );
      raw.execute(
        "INSERT INTO capture_blocks (id, session_log_id, frame_type, "
        "exposure_time_seconds, frame_count, position) "
        "VALUES (1, 1, 'light', 60.0, 10, 0);",
      );

      final db = AppDatabase(schema.newConnection());
      final row = await db.select(db.sessionLogs).getSingle();
      expect(row.trackingOverride, isNull);
      expect(row.status, 'planned');
      expect(row.eveningDate, '2026-12-15');
      expect(row.planSnapshot, {'v': 1, 'rig': null});
      final session = (await DriftSessionRepository(db).get(1))!;
      expect(session.trackingOverride, isNull);
      expect(session.blocks.single.frameCount, 10);
      await db.close();
    });
  });

  group('S3.4: v18 (per-field equipment provenance, ADR-018 §5)', () {
    for (final from in [8, 9, 10, 11, 12, 13, 14, 15, 16, 17]) {
      test('v$from -> v18 matches the v18 snapshot exactly', () async {
        final connection = await verifier.startAt(from);
        final db = AppDatabase(connection);
        await verifier.migrateAndValidate(db, 18);
        await db.close();
      });
    }

    test('v17 -> v18: every value and group provenance kept; no own pairs, '
        'so each field falls back to its group', () async {
      final schema = await verifier.schemaAt(17);
      final raw = schema.rawDatabase;
      raw.execute("INSERT INTO devices (id, name) VALUES (1, 'Rig');");
      raw.execute(
        "INSERT INTO camera_modules (id, device_id, name, model, "
        "sensor_width_mm, sensor_height_mm, resolution_width_px, "
        "resolution_height_px, pixel_pitch_um, average_raw_file_size_m_b, "
        "source, confidence) VALUES (1, 1, 'Rig Camera', 'ASI2600MC', 23.5, "
        "15.7, 6248, 4176, 3.76, 50.0, 'seed:equipment@2', 'verified');",
      );
      raw.execute(
        "INSERT INTO optical_rigs (id, name, camera_module_id, "
        "focal_length_mm, aperture, tracking_state, source, confidence) "
        "VALUES (1, 'Rig', 1, 403.2, 5.6, 'guided', 'seed:equipment@2', "
        "'estimated');",
      );
      final db = AppDatabase(schema.newConnection());
      final p = (await DriftEquipmentRepository(db).getAllEquipment()).single;
      expect(p.pixelPitchUm, 3.76);
      expect(p.resolutionWidthPx, 6248);
      expect(p.averageRawFileSizeMB, 50.0);
      expect(p.focalLengthMm, 403.2);
      expect(p.focalRatio, 5.6);
      expect(p.trackingType, TrackingType.guided);
      expect(p.cameraConfidence, SpecConfidence.verified);
      expect(p.opticsConfidence, SpecConfidence.estimated);
      expect(p.specProvenance, isEmpty, reason: 'nothing is back-filled');
      expect(p.metadataMake, isNull);
      expect(p.metadataModel, isNull);
      expect(
        p.provenanceOf(EquipmentSpec.pixelPitch),
        const SpecProvenance('seed:equipment@2', SpecConfidence.verified),
      );
      expect(
        p.provenanceOf(EquipmentSpec.focalRatio),
        const SpecProvenance('seed:equipment@2', SpecConfidence.estimated),
      );
      await db.close();
    });

    test('v17 -> v18: a legacy rig with no provenance stays unknown', () async {
      final schema = await verifier.schemaAt(17);
      final raw = schema.rawDatabase;
      raw.execute("INSERT INTO devices (id, name) VALUES (1, 'Phone');");
      raw.execute(
        "INSERT INTO camera_modules (id, device_id, name, sensor_width_mm, "
        "sensor_height_mm, resolution_width_px, resolution_height_px, "
        "pixel_pitch_um) VALUES (1, 1, 'Phone Camera', 9.8, 7.3, 8064, "
        "6048, 1.22);",
      );
      raw.execute(
        "INSERT INTO optical_rigs (id, name, camera_module_id, "
        "focal_length_mm, aperture) VALUES (1, 'Phone', 1, 6.86, 1.78);",
      );
      final db = AppDatabase(schema.newConnection());
      final p = (await DriftEquipmentRepository(db).getAllEquipment()).single;
      for (final spec in EquipmentSpec.values) {
        expect(p.provenanceOf(spec), isNull, reason: spec.name);
      }
      await db.close();
    });
  });

  group('TASK 13.2: v17 (execution events, ADR-016)', () {
    for (final from in [8, 9, 10, 11, 12, 13, 14, 15, 16]) {
      test('v$from -> v17 matches the v17 snapshot exactly', () async {
        final connection = await verifier.startAt(from);
        final db = AppDatabase(connection);
        await verifier.migrateAndValidate(db, 17);
        await db.close();
      });
    }

    test('v16 -> v17: sessions and blocks are kept; no events yet', () async {
      final schema = await verifier.schemaAt(16);
      final raw = schema.rawDatabase;
      raw.execute(
        "INSERT INTO session_logs (id, target_name, equipment_name, "
        "session_date, planned_light_frames, status, legacy, evening_date, "
        "started_at_utc_ms) VALUES "
        "(1, 'M42', 'Rig', 1790000000, 10, 'inProgress', 0, '2026-12-15', "
        "1790000000000);",
      );
      raw.execute(
        "INSERT INTO capture_blocks (id, session_log_id, frame_type, "
        "exposure_time_seconds, frame_count, position, completed_frames) "
        "VALUES (1, 1, 'light', 60.0, 10, 0, 3);",
      );

      final db = AppDatabase(schema.newConnection());
      final row = await db.select(db.sessionLogs).getSingle();
      expect(row.status, 'inProgress');
      expect(row.startedAtUtcMs, 1790000000000);
      final block = await db.select(db.captureBlocks).getSingle();
      expect(block.completedFrames, 3);
      expect(await db.select(db.sessionEvents).get(), isEmpty);
      await db.close();
    });

    group('on a fresh v17 database', () {
      late AppDatabase db;
      setUp(() async {
        db = AppDatabase(NativeDatabase.memory());
        await db.customStatement(
          "INSERT INTO session_logs (id, target_name, equipment_name, "
          "session_date, planned_light_frames, status, legacy, evening_date) "
          "VALUES (1, 'M42', 'Rig', 1790000000, 10, 'inProgress', 0, "
          "'2026-12-15');",
        );
        await db.customStatement(
          "INSERT INTO capture_blocks (id, session_log_id, frame_type, "
          "exposure_time_seconds, frame_count) VALUES (1, 1, 'light', 60, 10);",
        );
      });
      tearDown(() => db.close());

      Future<void> event(int seq, String kind) => db.customStatement(
        "INSERT INTO session_events (session_log_id, seq, at_utc_ms, kind, "
        "block_id) VALUES (1, $seq, 1790000000000, '$kind', 1);",
      );

      test('an unknown kind is rejected by the CHECK constraint', () async {
        await expectLater(event(1, 'teleported'), throwsA(anything));
      });

      test('a sequence number is unique within a session', () async {
        await event(1, 'started');
        await expectLater(event(1, 'paused'), throwsA(anything));
      });

      test('deleting a session deletes its events', () async {
        await event(1, 'started');
        await db.customStatement('DELETE FROM session_logs WHERE id = 1;');
        expect(await db.select(db.sessionEvents).get(), isEmpty);
      });
    });
  });

  group('TASK 11.2: v16 (Session aggregate, ADR-014)', () {
    for (final from in [8, 9, 10, 11, 12, 13, 14, 15]) {
      test('v$from -> v16 matches the v16 snapshot exactly', () async {
        final connection = await verifier.startAt(from);
        final db = AppDatabase(connection);
        await verifier.migrateAndValidate(db, 16);
        await db.close();
      });
    }

    // Acceptance: legacy logs are still listed.
    test(
      'v15 -> v16: every log becomes a completed, read-only legacy '
      'session with its values and blocks kept, and is still listed',
      () async {
        final schema = await verifier.schemaAt(15);
        final raw = schema.rawDatabase;
        raw.execute(
          "INSERT INTO session_logs (id, target_name, equipment_name, "
          "session_date, location_name, planned_light_frames, "
          "actual_light_frames, processing_notes) VALUES "
          "(1, 'M31', 'Rig A', 1790000000, 'Home', 40, 35, 'good'), "
          "(2, 'M42', 'Rig B', 1790100000, NULL, 10, NULL, NULL);",
        );
        raw.execute(
          "INSERT INTO capture_blocks (id, session_log_id, frame_type, "
          "filter_name, exposure_time_seconds, frame_count, position) VALUES "
          "(1, 1, 'light', 'L', 120.0, 40, 0), "
          "(2, 1, 'dark', NULL, 120.0, 20, 1);",
        );

        final db = AppDatabase(schema.newConnection());
        final rows = await (db.select(
          db.sessionLogs,
        )..orderBy([(t) => OrderingTerm.asc(t.id)])).get();
        expect(rows, hasLength(2));
        for (final r in rows) {
          expect(r.status, 'completed');
          expect(r.legacy, isTrue);
          expect(r.eveningDate, isNull);
          expect(r.timeZoneId, isNull);
          expect(r.siteId, isNull, reason: 'never guessed from names');
          expect(r.targetId, isNull, reason: 'never guessed from names');
          expect(r.rigId, isNull, reason: 'never guessed from names');
          expect(r.createdAtUtcMs, isNull);
          expect(r.planSnapshot, isNull);
          expect(r.executionStartSnapshot, isNull);
        }
        expect(rows.first.targetName, 'M31');
        expect(rows.first.actualLightFrames, 35);
        expect(rows.first.processingNotes, 'good');

        final blocks = await db.select(db.captureBlocks).get();
        expect(blocks, hasLength(2));
        expect(blocks.every((b) => b.completedFrames == 0), isTrue);
        expect(blocks.every((b) => b.rejectedFrames == 0), isTrue);
        expect(blocks.first.frameCount, 40);

        final sessions = await DriftSessionRepository(db).list();
        expect(sessions.map((s) => s.record.targetName), ['M42', 'M31']);
        expect(sessions.every((s) => s.legacy), isTrue);
        expect(sessions.last.blocks, hasLength(2));
        await db.close();
      },
    );

    group('on a fresh v16 database', () {
      late AppDatabase db;
      setUp(() => db = AppDatabase(NativeDatabase.memory()));
      tearDown(() => db.close());

      Future<int> session({int? siteId, int? targetId, int? rigId}) => db
          .into(db.sessionLogs)
          .insert(
            SessionLogsCompanion.insert(
              targetName: 'M31',
              equipmentName: 'Rig',
              sessionDate: DateTime.utc(2026, 9, 24),
              plannedLightFrames: 10,
              status: const Value('planned'),
              eveningDate: const Value('2026-09-24'),
              timeZoneId: const Value('Europe/Ljubljana'),
              siteId: Value(siteId),
              targetId: Value(targetId),
              rigId: Value(rigId),
              createdAtUtcMs: Value(
                DateTime.utc(2026, 9, 24, 12).millisecondsSinceEpoch,
              ),
            ),
          );

      Future<SessionLog> read(int id) => (db.select(
        db.sessionLogs,
      )..where((t) => t.id.equals(id))).getSingle();

      test('a new row is a draft, not legacy, with zero counters', () async {
        final id = await db
            .into(db.sessionLogs)
            .insert(
              SessionLogsCompanion.insert(
                targetName: 'M31',
                equipmentName: 'Rig',
                sessionDate: DateTime.utc(2026, 9, 24),
                plannedLightFrames: 0,
              ),
            );
        final row = await read(id);
        expect(row.status, 'draft');
        expect(row.legacy, isFalse);
        await db
            .into(db.captureBlocks)
            .insert(
              CaptureBlocksCompanion.insert(
                sessionLogId: id,
                frameType: 'light',
                exposureTimeSeconds: 60,
                frameCount: 10,
              ),
            );
        final block = await db.select(db.captureBlocks).getSingle();
        expect(block.completedFrames, 0);
        expect(block.rejectedFrames, 0);
      });

      test('an unknown status is rejected by the CHECK constraint', () async {
        await expectLater(
          () => db.customStatement(
            "INSERT INTO session_logs (target_name, equipment_name, "
            "session_date, planned_light_frames, status) "
            "VALUES ('x', 'y', 0, 0, 'done');",
          ),
          throwsA(anything),
        );
      });

      test('deleting a site, target or rig keeps the session and clears '
          'only that reference (SET NULL)', () async {
        final siteId = await db
            .into(db.locationProfiles)
            .insert(
              LocationProfilesCompanion.insert(
                name: 'Home',
                latitude: 46.05,
                longitude: 14.51,
                elevation: const Value(300),
              ),
            );
        final targetId = await db
            .into(db.astroTargets)
            .insert(
              AstroTargetsCompanion.insert(
                catalogId: 'M31',
                rightAscension: 10.68,
                declination: 41.27,
                type: 'Galaxy',
              ),
            );
        final deviceId = await db
            .into(db.devices)
            .insert(DevicesCompanion.insert(name: 'Camera'));
        final cameraId = await db
            .into(db.cameraModules)
            .insert(
              CameraModulesCompanion.insert(
                deviceId: deviceId,
                name: 'Sensor',
                sensorWidthMm: 23.5,
                sensorHeightMm: 15.6,
                resolutionWidthPx: 6000,
                resolutionHeightPx: 4000,
                pixelPitchUm: 3.76,
              ),
            );
        final rigId = await db
            .into(db.opticalRigs)
            .insert(
              OpticalRigsCompanion.insert(
                name: 'Rig',
                cameraModuleId: cameraId,
                focalLengthMm: 400,
                aperture: 5,
              ),
            );
        final id = await session(
          siteId: siteId,
          targetId: targetId,
          rigId: rigId,
        );

        await (db.delete(
          db.astroTargets,
        )..where((t) => t.id.equals(targetId))).go();
        var row = await read(id);
        expect(row.targetId, isNull);
        expect(row.siteId, siteId);
        expect(row.rigId, rigId);

        await (db.delete(
          db.locationProfiles,
        )..where((t) => t.id.equals(siteId))).go();
        await (db.delete(
          db.opticalRigs,
        )..where((t) => t.id.equals(rigId))).go();
        row = await read(id);
        expect(row.siteId, isNull);
        expect(row.rigId, isNull);
        expect(row.status, 'planned');
        expect(row.targetName, 'M31', reason: 'the session itself survives');
      });

      test('snapshots round-trip as JSON; unreadable text reads as an empty '
          'map, never an error', () async {
        final id = await session();
        final snapshot = <String, Object?>{
          'v': 1,
          'takenAtUtcMs': 1790000000000,
          'site': {'name': 'Home', 'latitudeDeg': 46.05, 'bortle': null},
          'windows': [
            {'startUtcMs': 1, 'endUtcMs': 2},
          ],
        };
        await (db.update(db.sessionLogs)..where((t) => t.id.equals(id))).write(
          SessionLogsCompanion(planSnapshot: Value(snapshot)),
        );
        expect((await read(id)).planSnapshot, snapshot);
        expect((await read(id)).executionStartSnapshot, isNull);

        await db.customStatement(
          "UPDATE session_logs SET execution_start_snapshot = 'not json' "
          'WHERE id = $id;',
        );
        expect((await read(id)).executionStartSnapshot, isEmpty);
        expect(const JsonMapConverter().fromSql('[1, 2]'), isEmpty);
      });

      test('a partial write (session results) keeps the other v16 '
          'columns', () async {
        final id = await session();
        await (db.update(db.sessionLogs)..where((t) => t.id.equals(id))).write(
          const SessionLogsCompanion(planSnapshot: Value({'v': 1})),
        );
        await DriftSessionRepository(db)
            .updateResults(id, const SessionResults(processingNotes: 'ok'));

        final row = await read(id);
        expect(row.processingNotes, 'ok');
        expect(row.status, 'planned');
        expect(row.eveningDate, '2026-09-24');
        expect(row.timeZoneId, 'Europe/Ljubljana');
        expect(row.planSnapshot, {'v': 1});
        expect(row.createdAtUtcMs, isNotNull);
      });
    });
  });

  group('TASK 8.5: v15 (equipment provenance)', () {
    for (final from in [8, 9, 10, 11, 12, 13, 14]) {
      test('v$from -> v15 matches the v15 snapshot exactly', () async {
        final connection = await verifier.startAt(from);
        final db = AppDatabase(connection);
        await verifier.migrateAndValidate(db, 15);
        await db.close();
      });
    }

    test(
      'v14 -> v15: legacy equipment keeps its values; provenance unknown',
      () async {
        final schema = await verifier.schemaAt(14);
        final raw = schema.rawDatabase;
        raw.execute("INSERT INTO devices (id, name) VALUES (1, 'Phone');");
        raw.execute(
          "INSERT INTO camera_modules (id, device_id, name, sensor_width_mm, "
          "sensor_height_mm, resolution_width_px, resolution_height_px, "
          "pixel_pitch_um) VALUES (1, 1, 'Phone Camera', 13.2, 8.8, 8192, "
          "6144, 1.6);",
        );
        raw.execute(
          "INSERT INTO optical_rigs (id, name, camera_module_id, "
          "focal_length_mm, aperture) VALUES (1, 'Vivo X100 Pro (Main)', 1, "
          "8.7, 1.75);",
        );
        final db = AppDatabase(schema.newConnection());
        final p = (await DriftEquipmentRepository(db).getAllEquipment()).single;
        expect(p.sensorHeightMm, 8.8, reason: 'not corrected silently');
        expect(p.focalRatio, 1.75);
        expect(p.cameraSource, isNull);
        expect(p.cameraConfidence, isNull);
        expect(p.opticsSource, isNull);
        expect(p.opticsConfidence, isNull);
        await db.close();
      },
    );
  });

  group('TASK 8.4: v14 (aperture diameter, maximum exposure)', () {
    for (final from in [8, 9, 10, 11, 12, 13]) {
      test('v$from -> v14 matches the v14 snapshot exactly', () async {
        final connection = await verifier.startAt(from);
        final db = AppDatabase(connection);
        await verifier.migrateAndValidate(db, 14);
        await db.close();
      });
    }

    test('v13 -> v14: every stored value is kept; f/72 stays 72 and is '
        'flagged; tracking is never inferred', () async {
      final schema = await verifier.schemaAt(13);
      final raw = schema.rawDatabase;
      raw.execute(
        "INSERT INTO devices (id, name) VALUES (1, 'Scope'), (2, 'Phone');",
      );
      raw.execute(
        "INSERT INTO camera_modules (id, device_id, name, sensor_width_mm, "
        "sensor_height_mm, resolution_width_px, resolution_height_px, "
        "pixel_pitch_um) VALUES "
        "(1, 1, 'Scope Camera', 23.5, 15.7, 6248, 4176, 3.76), "
        "(2, 2, 'Phone Camera', 9.8, 7.3, 8064, 6048, 1.22);",
      );
      raw.execute(
        "INSERT INTO optical_rigs (id, name, camera_module_id, "
        "focal_length_mm, aperture, tracking_state, rotation_degrees) VALUES "
        "(1, 'Old scope', 1, 400.0, 72.0, 'tracking', 12.5), "
        "(2, 'Phone', 2, 6.86, 1.78, 'unknown', NULL);",
      );
      final db = AppDatabase(schema.newConnection());
      final rows = await (db.select(
        db.opticalRigs,
      )..orderBy([(t) => OrderingTerm.asc(t.id)])).get();
      expect(rows[0].aperture, 72.0);
      expect(rows[0].focalLengthMm, 400.0);
      expect(rows[0].trackingState, 'tracking');
      expect(rows[0].rotationDegrees, 12.5);
      for (final r in rows) {
        expect(r.apertureDiameterMm, isNull);
        expect(r.maxExposureS, isNull);
      }

      final profiles = await DriftEquipmentRepository(db).getAllEquipment();
      final scope = profiles.firstWhere((p) => p.name == 'Old scope');
      expect(scope.focalRatio, 72.0, reason: 'never converted to f/5.6');
      expect(scope.needsApertureReview, isTrue);
      expect(scope.apertureDiameterMm, isNull);
      expect(
        scope.trackingType,
        TrackingType.unknown,
        reason: 'an unrecognised stored value is not guessed',
      );
      final phone = profiles.firstWhere((p) => p.name == 'Phone');
      expect(phone.focalRatio, 1.78);
      expect(phone.needsApertureReview, isFalse);
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
