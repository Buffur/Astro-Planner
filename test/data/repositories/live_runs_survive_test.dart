// S8.4 acceptance 2 (TD-087, S8V-03): the live tracker left the product, but
// a database with a run in progress, a completed live run corrected after
// it finished and an abandoned run opens, lists, exports and backs up as
// before, and the run in progress can be recorded both ways (Partly on one
// copy, Not done on the restored one), the counters always equal to the
// replayed events.

import 'dart:convert';
import 'dart:io';

import 'package:astroplan/core/config/app_identity.dart';
import 'package:astroplan/core/time/clock.dart';
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
import 'package:astroplan/domain/models/session_result.dart';
import 'package:astroplan/domain/services/capture_budget_calculator.dart';
import 'package:astroplan/domain/services/execution_machine.dart';
import 'package:astroplan/domain/services/result_action.dart';
import 'package:astroplan/domain/services/session_exporter.dart';
import 'package:astroplan/domain/services/session_snapshot_builder.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:path/path.dart' as p;
import 'package:shared_preferences/shared_preferences.dart';

import '../../support/legacy_run.dart';

class _Clock extends Clock {
  DateTime now = DateTime.utc(2026, 12, 15, 18);
  @override
  DateTime nowUtc() => now;
}

final _blocks = [
  CaptureBlock(
    frameType: FrameType.light,
    filterName: 'Ha',
    exposureTimeSeconds: 300,
    frameCount: 24,
  ),
];

final _night = CalendarDate(2026, 12, 15);

SessionPlan _plan() => SessionPlan(
  eveningDate: _night,
  timeZoneId: 'Europe/Ljubljana',
  siteId: null,
  targetId: null,
  rigId: null,
  blocks: _blocks,
  targetLabel: 'M42',
  rigLabel: 'Rig',
);

Future<Session> _saved(DriftSessionRepository repo) async {
  final prefs = PlanningPreferences();
  final s = await repo.create(_plan());
  return repo.savePlan(
    s.id,
    _plan(),
    SessionSnapshotBuilder.build(
      takenAtUtc: DateTime.utc(2026, 12, 15, 18),
      night: SessionNight(
        eveningDate: _night,
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
    ),
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
    exportedAtUtc: DateTime.utc(2026, 12, 16, 8),
    appVersion: AppIdentity.version,
  );
}

/// The stored block counters of [id] equal its replayed events.
Future<void> _countersEqualReplay(
  AppDatabase db,
  DriftSessionRepository repo,
  int id,
) async {
  final s = (await repo.get(id))!;
  final replay = ExecutionMachine.fold({
    for (final b in s.blocks) b.id,
  }, await repo.events(id));
  final rows = await (db.select(
    db.captureBlocks,
  )..where((t) => t.sessionLogId.equals(id))).get();
  expect(rows, isNotEmpty);
  for (final r in rows) {
    expect(r.completedFrames, replay.completedFor(r.id), reason: 'block');
    expect(r.rejectedFrames, replay.rejectedFor(r.id));
  }
}

void main() {
  late Directory root;

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    root = await Directory.systemTemp.createTemp('astroplan_live_runs');
  });
  tearDown(() => root.delete(recursive: true));

  test('runs from the retired live mode list, export, back up and record '
      'as before', () async {
    final clock = _Clock();
    final db = AppDatabase(NativeDatabase.memory());
    final repo = DriftSessionRepository(db, clock: clock);
    final saved = await _saved(repo);
    final block = saved.blocks.single.id;

    // A completed live run, corrected after it finished.
    final done = await startLegacyRun(repo, saved);
    final doneBlock = done.blocks.single.id;
    await repo.record(
      done.id,
      ExecutionEventKind.framesConfirmed,
      blockId: doneBlock,
      delta: 8,
    );
    await repo.complete(done.id);
    await repo.record(
      done.id,
      ExecutionEventKind.framesRejected,
      blockId: doneBlock,
      delta: 1,
    );
    // An abandoned live run.
    final dropped = await startLegacyRun(repo, saved);
    await repo.record(
      dropped.id,
      ExecutionEventKind.framesConfirmed,
      blockId: dropped.blocks.single.id,
      delta: 2,
    );
    await repo.abandon(dropped.id);
    // A run still in progress (the app no longer starts one).
    final running = await startLegacyRun(repo, saved);
    final runningBlock = running.blocks.single.id;
    await repo.record(
      running.id,
      ExecutionEventKind.framesConfirmed,
      blockId: runningBlock,
      delta: 7,
    );
    expect(block, isNot(runningBlock));

    // Lists, with the actions the Logbook offers.
    clock.now = DateTime.utc(2026, 12, 16, 7); // after the night's dawn
    final listed = {for (final s in await repo.list()) s.id: s};
    expect(
      [
        for (final id in [done.id, dropped.id, running.id])
          (listed[id]!.status, ResultAction.of(listed[id]!, clock.now)),
      ],
      [
        (SessionStatus.completed, ResultAction.edit),
        (SessionStatus.abandoned, ResultAction.edit),
        (SessionStatus.inProgress, ResultAction.record),
      ],
    );
    final corrected = await repo.execution(done.id);
    expect(
      (corrected.completedFor(doneBlock), corrected.rejectedFor(doneBlock)),
      (8, 1),
    );
    for (final id in [done.id, dropped.id, running.id]) {
      await _countersEqualReplay(db, repo, id);
    }

    // Exports: the manifest reads back to the same sessions and events.
    final before = await _everything(repo);
    final decoded = SessionManifestCodec.decode(
      jsonDecode(jsonEncode(before)) as Map<String, Object?>,
    );
    expect(
      SessionManifestCodec.encode(
        decoded.sessions,
        exportedAtUtc: DateTime.utc(2026, 12, 16, 8),
        appVersion: AppIdentity.version,
      ),
      before,
    );

    // Backs up: a restore on a clean install holds the same.
    final newPhone = await Directory(p.join(root.path, 'new')).create();
    final tmp = await Directory(p.join(root.path, 'tmp')).create();
    final service = FileBackupService(
      db,
      repo,
      clock: clock,
      dataDir: () async => newPhone,
      tempDir: () async => tmp,
    );
    await service.stage(service.check(await service.createBackup()));
    await BackupStaging.apply(newPhone, nowUtc: clock.now);
    final restoredDb = AppDatabase(
      NativeDatabase(File(p.join(newPhone.path, BackupStaging.database))),
    );
    addTearDown(restoredDb.close);
    final restored = DriftSessionRepository(restoredDb, clock: clock);
    expect(await _everything(restored), before);

    // The run in progress is recorded both ways.
    final partly = await repo.recordResult(
      running.id,
      PartlyDone({runningBlock: 3}),
    );
    expect(partly.status, SessionStatus.completed);
    expect(partly.resultKind, ResultKind.partly);
    expect((await repo.execution(running.id)).completedFor(runningBlock), 3);
    await _countersEqualReplay(db, repo, running.id);

    final notDone = await restored.recordResult(
      running.id,
      const NotDone(reason: NotDoneReason.wind),
    );
    expect(notDone.status, SessionStatus.abandoned);
    expect(notDone.notDoneReason, NotDoneReason.wind);
    expect(
      (await restored.events(running.id)).map((e) => e.kind),
      containsAllInOrder([
        ExecutionEventKind.started,
        ExecutionEventKind.framesConfirmed,
      ]),
    );
    await _countersEqualReplay(restoredDb, restored, running.id);
    await db.close();
  });
}
