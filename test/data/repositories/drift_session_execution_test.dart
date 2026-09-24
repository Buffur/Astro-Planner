// TASK 13.2 (ADR-016): execution persistence. Every transition is one
// transaction (event + counters); a refused event writes nothing; only one
// session is in progress; a restart mid-block restores the exact state;
// replaying the events reproduces the stored counters.

import 'dart:io';

import 'package:astroplan/core/time/clock.dart';
import 'package:astroplan/data/database/app_database.dart';
import 'package:astroplan/data/repositories/drift_session_repository.dart';
import 'package:astroplan/domain/models/calendar_date.dart';
import 'package:astroplan/domain/models/capture_block.dart' as domain;
import 'package:astroplan/domain/models/execution.dart';
import 'package:astroplan/domain/models/planning_preferences.dart';
import 'package:astroplan/domain/models/session.dart';
import 'package:astroplan/domain/models/session_night.dart';
import 'package:astroplan/domain/models/session_snapshot.dart';
import 'package:astroplan/domain/services/capture_budget_calculator.dart';
import 'package:astroplan/domain/services/execution_machine.dart';
import 'package:astroplan/domain/services/session_snapshot_builder.dart';
import 'package:drift/drift.dart' show OrderingTerm;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:path/path.dart' as p;

class _Clock extends Clock {
  DateTime now = DateTime.utc(2026, 12, 15, 18);
  @override
  DateTime nowUtc() => now;
  void minutes(int m) => now = now.add(Duration(minutes: m));
}

final _blocks = [
  domain.CaptureBlock(
    frameType: domain.FrameType.dark,
    exposureTimeSeconds: 300,
    frameCount: 10,
    calibrationPolicy: domain.CalibrationPolicy.library,
  ),
  domain.CaptureBlock(
    frameType: domain.FrameType.light,
    filterName: 'L',
    exposureTimeSeconds: 300,
    frameCount: 20,
  ),
];

SessionPlan _plan() => SessionPlan(
  eveningDate: CalendarDate(2026, 12, 15),
  timeZoneId: 'Europe/Ljubljana',
  siteId: null,
  targetId: null,
  rigId: null,
  blocks: _blocks,
  targetLabel: 'M42',
  rigLabel: 'Rig',
);

SessionSnapshot _snapshot() {
  final prefs = PlanningPreferences();
  return SessionSnapshotBuilder.build(
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
}

void main() {
  late AppDatabase db;
  late _Clock clock;
  late DriftSessionRepository repo;

  setUp(() {
    db = AppDatabase(NativeDatabase.memory());
    clock = _Clock();
    repo = DriftSessionRepository(db, clock: clock);
  });
  tearDown(() => db.close());

  Future<Session> started() async {
    final s = await repo.create(_plan());
    return repo.start(s.id, _snapshot());
  }

  Future<List<CaptureBlock>> storedBlocks(int id) =>
      (db.select(db.captureBlocks)
            ..where((t) => t.sessionLogId.equals(id))
            ..orderBy([(t) => OrderingTerm.asc(t.position)]))
          .get();

  test('start records the start on the first light block', () async {
    final s = await started();
    expect(s.status, SessionStatus.inProgress);
    final light = s.blocks.firstWhere(
      (b) => b.frameType == domain.FrameType.light,
    );
    final events = await repo.events(s.id);
    expect(events.single.kind, ExecutionEventKind.started);
    expect(events.single.blockId, light.id);
    expect(events.single.atUtc, clock.now);
    final state = await repo.execution(s.id);
    expect(state.phase, ExecutionPhase.running);
    expect(state.blockId, light.id);
  });

  test('only one session in progress at a time (owner)', () async {
    final a = await started();
    final b = await repo.create(_plan());
    await expectLater(
      repo.start(b.id, _snapshot()),
      throwsA(isA<SessionStateError>()),
    );
    expect((await repo.get(b.id))!.status, SessionStatus.draft);
    expect(await repo.events(b.id), isEmpty);
    expect((await repo.inProgress())!.id, a.id);

    await repo.complete(a.id);
    expect(await repo.inProgress(), isNull);
    expect(
      (await repo.start(b.id, _snapshot())).status,
      SessionStatus.inProgress,
    );
  });

  test('a plan without blocks cannot start', () async {
    final s = await repo.create(
      SessionPlan(
        eveningDate: CalendarDate(2026, 12, 15),
        timeZoneId: null,
        siteId: null,
        targetId: null,
        rigId: null,
        blocks: const [],
        targetLabel: 'M42',
        rigLabel: 'Rig',
      ),
    );
    await expectLater(
      repo.start(s.id, _snapshot()),
      throwsA(isA<SessionStateError>()),
    );
    expect((await repo.get(s.id))!.status, SessionStatus.draft);
  });

  test('confirmations and rejections update the counters in the same '
      'transaction, and replaying the events reproduces them', () async {
    final s = await started();
    final light = s.blocks[1].id;
    final dark = s.blocks[0].id;
    clock.minutes(10);
    await repo.record(
      s.id,
      ExecutionEventKind.framesConfirmed,
      blockId: light,
      delta: 2,
    );
    await repo.record(
      s.id,
      ExecutionEventKind.framesRejected,
      blockId: light,
      delta: 1,
    );
    await repo.record(s.id, ExecutionEventKind.paused);
    await repo.record(s.id, ExecutionEventKind.blockSelected, blockId: dark);
    await repo.record(
      s.id,
      ExecutionEventKind.framesConfirmed,
      blockId: dark,
      delta: 4,
    );
    await repo.record(
      s.id,
      ExecutionEventKind.framesConfirmed,
      blockId: light,
      delta: -1,
    );

    final rows = await storedBlocks(s.id);
    expect(rows[0].completedFrames, 4);
    expect(rows[1].completedFrames, 1);
    expect(rows[1].rejectedFrames, 1);

    final replayed = ExecutionMachine.fold({
      for (final b in s.blocks) b.id,
    }, await repo.events(s.id));
    for (final r in rows) {
      expect(replayed.completedFor(r.id), r.completedFrames);
      expect(replayed.rejectedFor(r.id), r.rejectedFrames);
    }
  });

  test('a refused event writes nothing (the transaction rolls back)', () async {
    final s = await started();
    final light = s.blocks[1].id;
    await expectLater(
      repo.record(s.id, ExecutionEventKind.resumed), // not paused
      throwsA(isA<ExecutionError>()),
    );
    await expectLater(
      repo.record(
        s.id,
        ExecutionEventKind.framesConfirmed,
        blockId: light,
        delta: -1,
      ),
      throwsA(isA<ExecutionError>()),
    );
    expect(await repo.events(s.id), hasLength(1));
    expect((await storedBlocks(s.id))[1].completedFrames, 0);
  });

  test('events are only recorded on a session in progress', () async {
    final s = await repo.create(_plan());
    await expectLater(
      repo.record(s.id, ExecutionEventKind.paused),
      throwsA(isA<SessionStateError>()),
    );
    expect(
      () => repo.record(s.id, ExecutionEventKind.finished),
      throwsArgumentError,
    );
  });

  test('finish and abandon close the run with an event; abandoning a draft '
      'records none', () async {
    final a = await started();
    clock.minutes(30);
    final done = await repo.complete(a.id);
    expect(done.status, SessionStatus.completed);
    expect((await repo.events(a.id)).last.kind, ExecutionEventKind.finished);
    expect((await repo.execution(a.id)).phase, ExecutionPhase.finished);

    final b = await started();
    await repo.abandon(b.id);
    expect((await repo.events(b.id)).last.kind, ExecutionEventKind.abandoned);

    final c = await repo.create(_plan());
    await repo.abandon(c.id);
    expect(await repo.events(c.id), isEmpty);
  });

  test(
    'acceptance: killing the app mid-block restores the exact state',
    () async {
      final dir = await Directory.systemTemp.createTemp('astroplan_exec');
      final file = File(p.join(dir.path, 'app.sqlite'));
      addTearDown(() => dir.delete(recursive: true));

      // First run: start, confirm 3, interrupt, resume on the same block.
      var fileDb = AppDatabase(NativeDatabase(file));
      var fileRepo = DriftSessionRepository(fileDb, clock: clock);
      final s = await fileRepo.create(_plan());
      await fileRepo.start(s.id, _snapshot());
      final light = (await fileRepo.get(s.id))!.blocks[1].id;
      clock.minutes(20);
      await fileRepo.record(
        s.id,
        ExecutionEventKind.framesConfirmed,
        blockId: light,
        delta: 3,
      );
      await fileRepo.record(
        s.id,
        ExecutionEventKind.interrupted,
        reason: InterruptionReason.clouds,
      );
      clock.minutes(15);
      await fileRepo.record(s.id, ExecutionEventKind.resumed);
      clock.minutes(10);
      final before = await fileRepo.execution(s.id);
      await fileDb.close(); // the process dies here, mid-block

      // Restart 50 minutes later, on a new connection.
      clock.minutes(50);
      fileDb = AppDatabase(NativeDatabase(file));
      fileRepo = DriftSessionRepository(fileDb, clock: clock);
      final running = await fileRepo.inProgress();
      expect(running!.id, s.id);
      final after = await fileRepo.execution(s.id);
      expect(after.phase, ExecutionPhase.running);
      expect(after.blockId, before.blockId);
      expect(after.completed, before.completed);
      expect(after.runningMsBefore, before.runningMsBefore);
      expect(after.runningSinceUtc, before.runningSinceUtc);
      // 20 min before the interruption + 10 + 50 min since resuming.
      expect(ExecutionMachine.runningTime(after, clock.now).inMinutes, 80);
      await fileDb.close();
    },
  );

  test('a clock set back stamps the event at the last one, flagged', () async {
    final s = await started();
    clock.minutes(30);
    await repo.record(s.id, ExecutionEventKind.paused);
    clock.minutes(-90); // the phone's clock went back
    await repo.record(s.id, ExecutionEventKind.resumed);
    final events = await repo.events(s.id);
    expect(events.last.clockAdjusted, isTrue);
    expect(events.last.atUtc, events[1].atUtc);
    expect(events.map((e) => e.seq), [1, 2, 3]);
  });

  test('deleting a session deletes its events', () async {
    final s = await started();
    await repo.delete(s.id);
    expect(await db.select(db.sessionEvents).get(), isEmpty);
  });

  group('TASK 13.4: completion and corrections (owner decisions)', () {
    test('complete writes the result totals from the counters', () async {
      final s = await started();
      final light = s.blocks[1].id;
      await repo.record(
        s.id,
        ExecutionEventKind.framesConfirmed,
        blockId: light,
        delta: 12,
      );
      await repo.record(
        s.id,
        ExecutionEventKind.framesRejected,
        blockId: light,
        delta: 2,
      );
      await repo.record(
        s.id,
        ExecutionEventKind.framesConfirmed,
        blockId: s.blocks[0].id, // darks: not in the light totals
        delta: 5,
      );
      final done = await repo.complete(s.id);
      expect(done.record.actualLightFrames, 12);
      expect(done.record.rejectedFrames, 2);
    });

    test('a correction after completion is a timestamped event after '
        '"finished"; counters and totals follow', () async {
      final s = await started();
      final light = s.blocks[1].id;
      await repo.record(
        s.id,
        ExecutionEventKind.framesConfirmed,
        blockId: light,
        delta: 10,
      );
      await repo.complete(s.id);
      clock.minutes(600); // the next day
      await repo.record(
        s.id,
        ExecutionEventKind.framesConfirmed,
        blockId: light,
        delta: -3,
      );
      final events = await repo.events(s.id);
      expect(events[events.length - 2].kind, ExecutionEventKind.finished);
      expect(events.last.kind, ExecutionEventKind.framesConfirmed);
      expect(events.last.atUtc, clock.now);
      final row = (await repo.get(s.id))!;
      expect(row.status, SessionStatus.completed);
      expect(row.record.actualLightFrames, 7);
      expect(row.updatedAtUtc, clock.now);
      expect((await storedBlocks(s.id))[1].completedFrames, 7);
    });

    test('after completion only corrections: no pause, no resume', () async {
      final s = await started();
      await repo.complete(s.id);
      await expectLater(
        repo.record(s.id, ExecutionEventKind.paused),
        throwsA(isA<SessionStateError>()),
      );
    });

    test('an abandoned run takes no corrections', () async {
      final s = await started();
      await repo.abandon(s.id);
      await expectLater(
        repo.record(
          s.id,
          ExecutionEventKind.framesConfirmed,
          blockId: s.blocks[1].id,
          delta: 1,
        ),
        throwsA(isA<SessionStateError>()),
      );
    });

    test('optional conditions are stored, and unknown stays unknown', () async {
      final s = await started();
      await repo.complete(s.id);
      var row = await repo.updateResults(
        s.id,
        const SessionResults(temperatureC: -4.5, cloudCoverPct: 20),
      );
      expect(row.record.temperature, -4.5);
      expect(row.record.cloudCover, 20);
      expect(row.record.humidity, isNull);
      row = await repo.updateResults(s.id, const SessionResults());
      expect(row.record.temperature, isNull);
    });
  });

  test('the snapshot exposes the night end and the per-frame overhead', () {
    final snap = _snapshot();
    expect(snap.nightEndUtc, DateTime.utc(2026, 12, 16, 11));
    expect(
      snap.perFrameOverheadSeconds,
      PlanningPreferences.defaultPerFrameOverheadSeconds,
    );
  });
}
