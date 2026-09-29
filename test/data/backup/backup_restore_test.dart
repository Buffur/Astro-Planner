// TASK 14.4: backup and restore. Acceptance: a restore on a clean install
// reproduces all sessions (backup → check → stage → apply at next start →
// open). Also: newer schemas refused, older ones below the floor refused,
// damaged files refused, the replaced database kept as a safety copy.

import 'dart:io';
import 'dart:typed_data';

import 'package:astroplan/core/config/app_identity.dart';
import 'package:astroplan/core/time/clock.dart';
import 'package:astroplan/data/backup/backup_archive.dart';
import 'package:astroplan/data/backup/backup_staging.dart';
import 'package:astroplan/data/backup/file_backup_service.dart';
import 'package:astroplan/data/database/app_database.dart' show AppDatabase;
import 'package:astroplan/data/export/session_manifest_codec.dart';
import 'package:astroplan/data/repositories/drift_session_repository.dart';
import 'package:astroplan/domain/models/calendar_date.dart';
import 'package:astroplan/domain/models/capture_block.dart';
import 'package:astroplan/domain/models/execution.dart';
import 'package:astroplan/domain/models/planning_preferences.dart';
import 'package:astroplan/domain/models/session.dart';
import 'package:astroplan/domain/models/session_night.dart';
import 'package:astroplan/domain/services/backup_service.dart';
import 'package:astroplan/domain/services/capture_budget_calculator.dart';
import 'package:astroplan/domain/services/session_exporter.dart';
import 'package:astroplan/domain/services/session_snapshot_builder.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:path/path.dart' as p;

final _clock = FixedClock(DateTime.utc(2026, 12, 16, 8));

final _blocks = [
  CaptureBlock(
    frameType: FrameType.light,
    filterName: 'Ha',
    exposureTimeSeconds: 300,
    frameCount: 24,
  ),
];

Future<void> _seed(DriftSessionRepository repo, AppDatabase db) async {
  final prefs = PlanningPreferences();
  final snapshot = SessionSnapshotBuilder.build(
    takenAtUtc: DateTime.utc(2026, 12, 15, 18),
    night: SessionNight(
      eveningDate: CalendarDate(2026, 12, 15),
      startUtc: DateTime.utc(2026, 12, 15, 11),
      endUtc: DateTime.utc(2026, 12, 16, 11),
      latitude: 46.05,
      longitude: 14.51,
      timeContextId: 'Europe/Ljubljana',
    ),
    preferences: prefs,
    budget: CaptureBudgetCalculator.calculate(
      blocks: _blocks,
      overheads: CaptureOverheads.fromPreferences(prefs),
      targetTransitsInWindow: false,
    ),
    blocks: _blocks,
  );
  SessionPlan plan(String t) => SessionPlan(
    eveningDate: CalendarDate(2026, 12, 15),
    timeZoneId: 'Europe/Ljubljana',
    siteId: null,
    targetId: null,
    rigId: null,
    blocks: _blocks,
    targetLabel: t,
    rigLabel: 'Rig',
  );
  final run = await repo.start((await repo.create(plan('M42'))).id, snapshot);
  await repo.record(
    run.id,
    ExecutionEventKind.framesConfirmed,
    blockId: run.blocks.single.id,
    delta: 12,
  );
  await repo.complete(run.id);
  await repo.savePlan(
    (await repo.create(plan('M31'))).id,
    plan('M31'),
    snapshot,
  );
  await db.customStatement(
    "INSERT INTO session_logs (id, target_name, equipment_name, "
    "session_date, planned_light_frames, actual_light_frames, status, "
    "legacy) VALUES (900, 'M45', 'Old rig', 1767225600, 40, 35, "
    "'completed', 1);",
  );
}

/// Every session with its events, as manifest JSON (a full comparison).
Future<Map<String, Object?>> _everything(DriftSessionRepository repo) async {
  final all = await repo.list();
  all.sort((a, b) => a.id.compareTo(b.id));
  return SessionManifestCodec.encode(
    [
      for (final s in all)
        ExportedSession(s, s.legacy ? const [] : await repo.events(s.id)),
    ],
    exportedAtUtc: _clock.nowUtc(),
    appVersion: AppIdentity.version,
  );
}

void main() {
  late Directory root;
  late Directory oldPhone;
  late Directory newPhone;
  late Directory tmp;

  setUp(() async {
    root = await Directory.systemTemp.createTemp('astroplan_backup');
    oldPhone = await Directory(p.join(root.path, 'old')).create();
    newPhone = await Directory(p.join(root.path, 'new')).create();
    tmp = await Directory(p.join(root.path, 'tmp')).create();
  });
  tearDown(() => root.delete(recursive: true));

  test(
    'acceptance: a restore on a clean install reproduces all sessions',
    () async {
      final oldDb = AppDatabase(
        NativeDatabase(File(p.join(oldPhone.path, BackupStaging.database))),
      );
      final oldRepo = DriftSessionRepository(oldDb, clock: _clock);
      await _seed(oldRepo, oldDb);
      final before = await _everything(oldRepo);
      final service = FileBackupService(
        oldDb,
        oldRepo,
        clock: _clock,
        dataDir: () async => newPhone,
        tempDir: () async => tmp,
      );
      final bytes = await service.createBackup();
      await oldDb.close();

      // The new phone: a clean install stages the checked backup ...
      final checked = service.check(bytes);
      expect(checked.preview.sessionCount, 3);
      expect(checked.preview.schemaVersion, 23); // the app schema (S7.5)
      expect(checked.preview.appVersion, AppIdentity.version);
      await service.stage(checked.database);
      expect(await service.hasStagedRestore(), isTrue);
      // ... and applies it at the next start, before opening the database.
      expect(
        await BackupStaging.apply(newPhone, nowUtc: _clock.nowUtc()),
        isNull,
      );
      final newDb = AppDatabase(
        NativeDatabase(File(p.join(newPhone.path, BackupStaging.database))),
      );
      final after = await _everything(
        DriftSessionRepository(newDb, clock: _clock),
      );
      await newDb.close();

      expect(after, before);
      expect(await service.hasStagedRestore(), isFalse);
    },
  );

  // TD-065 (ADR-017 §6): the picker's cache copy of a picked backup is
  // deleted whatever happens to the pick.
  group('a restore pick always clears the picker cache', () {
    late AppDatabase db;
    late DriftSessionRepository repo;
    late int clears;

    setUp(() {
      db = AppDatabase(NativeDatabase.memory());
      repo = DriftSessionRepository(db, clock: _clock);
      clears = 0;
    });
    tearDown(() => db.close());

    FileBackupService service(
      Future<Uint8List?> Function() pickBytes, {
      Future<void> Function()? clear,
    }) => FileBackupService(
      db,
      repo,
      clock: _clock,
      tempDir: () async => tmp,
      pickBytes: pickBytes,
      clearPicked: clear ?? () async => clears++,
    );

    test('after a good backup is read', () async {
      await _seed(repo, db);
      final bytes = await service(() async => null).createBackup();
      clears = 0;
      final picked = await service(() async => bytes).pick();
      expect(picked!.preview.sessionCount, 3);
      expect(clears, 1);
    });

    test('after a cancel, a refused file and a failed read', () async {
      expect(await service(() async => null).pick(), isNull);
      expect(clears, 1);
      await expectLater(
        service(() async => Uint8List.fromList([1, 2, 3])).pick(),
        throwsA(anything),
      );
      expect(clears, 2);
      await expectLater(
        service(() => Future.error(const FileSystemException('gone'))).pick(),
        throwsA(isA<FileSystemException>()),
      );
      expect(clears, 3);
    });

    test('a failed cleanup never hides the pick result', () async {
      final result = await service(
        () async => null,
        clear: () => Future.error(StateError('cache busy')),
      ).pick();
      expect(result, isNull);
    });
  });

  test('the backup also carries the manifest', () async {
    final db = AppDatabase(NativeDatabase.memory());
    final repo = DriftSessionRepository(db, clock: _clock);
    await _seed(repo, db);
    final service = FileBackupService(
      db,
      repo,
      clock: _clock,
      tempDir: () async => tmp,
    );
    final bytes = await service.createBackup();
    await db.close();
    // The archive is a ZIP; the manifest is readable without the app.
    expect(String.fromCharCodes(bytes.sublist(0, 2)), 'PK');
    expect(BackupArchive.sqliteUserVersion(service.check(bytes).database), 23);
  });

  test('restoring over existing data keeps a safety copy', () async {
    final live = File(p.join(newPhone.path, BackupStaging.database));
    await live.writeAsString('old data');
    await BackupStaging.stage(newPhone, Uint8List.fromList([1, 2, 3]));
    final safety = await BackupStaging.apply(newPhone, nowUtc: _clock.nowUtc());
    expect(await safety!.readAsString(), 'old data');
    expect(await live.readAsBytes(), [1, 2, 3]);
  });

  test(
    'cancel removes a staged restore; nothing staged, nothing applied',
    () async {
      await BackupStaging.stage(newPhone, Uint8List.fromList([1]));
      await BackupStaging.cancel(newPhone);
      expect(await BackupStaging.isStaged(newPhone), isFalse);
      expect(
        await BackupStaging.apply(newPhone, nowUtc: _clock.nowUtc()),
        isNull,
      );
    },
  );

  group('refused backups', () {
    /// A minimal SQLite header saying [userVersion].
    Uint8List sqlite(int userVersion) {
      final b = Uint8List(100)..setAll(0, 'SQLite format 3\u0000'.codeUnits);
      ByteData.sublistView(b).setInt32(60, userVersion);
      return b;
    }

    Uint8List archive(int headerVersion, int dbVersion) => BackupArchive.build(
      database: sqlite(dbVersion),
      manifestJson: '{}',
      preview: BackupPreview(
        createdAtUtc: _clock.nowUtc(),
        schemaVersion: headerVersion,
        appVersion: '9.9.9',
        sessionCount: 0,
      ),
    );

    BackupProblem? problem(Uint8List bytes) {
      try {
        BackupArchive.read(bytes, appSchemaVersion: 17, minSchemaVersion: 8);
        return null;
      } on BackupException catch (e) {
        return e.problem;
      }
    }

    test('a newer schema is refused', () {
      expect(problem(archive(18, 18)), BackupProblem.newerSchema);
    });

    test('below the floor is refused', () {
      expect(problem(archive(7, 7)), BackupProblem.tooOld);
    });

    test('an older supported schema is accepted (migrations upgrade it)', () {
      expect(problem(archive(12, 12)), isNull);
    });

    test('a header that disagrees with the database is refused', () {
      expect(problem(archive(17, 16)), BackupProblem.notABackup);
    });

    test('not a backup at all', () {
      expect(problem(Uint8List.fromList([1, 2, 3])), BackupProblem.notABackup);
      expect(BackupArchive.sqliteUserVersion(Uint8List(10)), isNull);
    });
  });
}
