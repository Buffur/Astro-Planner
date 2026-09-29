// S8.1 (ADR-019 §3.1, §4; DECISIONS E.1, "Stage 8 decisions"): results
// without a run. A saved plan whose night has ended is recorded as Completed
// as planned, Partly or Not done; counts are events and the counters equal
// the replay; the snapshot never changes; a Saved · changed plan settles into
// its saved entry plus a working copy.

import 'package:astroplan/core/time/clock.dart';
import 'package:astroplan/data/database/app_database.dart';
import 'package:astroplan/data/repositories/drift_session_repository.dart';
import 'package:astroplan/domain/models/calendar_date.dart';
import 'package:astroplan/domain/models/capture_block.dart' as domain;
import 'package:astroplan/domain/models/execution.dart';
import 'package:astroplan/domain/models/planning_preferences.dart';
import 'package:astroplan/domain/models/session.dart';
import 'package:astroplan/domain/models/session_log.dart' as log;
import 'package:astroplan/domain/models/session_night.dart';
import 'package:astroplan/domain/models/session_result.dart';
import 'package:astroplan/domain/models/session_snapshot.dart';
import 'package:astroplan/domain/services/capture_budget_calculator.dart';
import 'package:astroplan/domain/services/execution_machine.dart';
import 'package:astroplan/domain/services/saved_night_end.dart';
import 'package:astroplan/domain/services/session_snapshot_builder.dart';
import 'package:drift/drift.dart' show Value;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';

class _Clock extends Clock {
  DateTime now = DateTime.utc(2026, 12, 15, 18);
  @override
  DateTime nowUtc() => now;
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
  domain.CaptureBlock(
    frameType: domain.FrameType.light,
    filterName: 'R',
    exposureTimeSeconds: 120,
    frameCount: 4,
  ),
];

SessionPlan _plan({CalendarDate? night, List<domain.CaptureBlock>? blocks}) =>
    SessionPlan(
      eveningDate: night ?? CalendarDate(2026, 12, 15),
      timeZoneId: 'Europe/Ljubljana',
      siteId: null,
      targetId: null,
      rigId: null,
      blocks: blocks ?? _blocks,
      targetLabel: 'M42',
      rigLabel: 'Rig',
    );

SessionSnapshot _snapshot({List<domain.CaptureBlock>? blocks}) {
  final prefs = PlanningPreferences();
  final b = blocks ?? _blocks;
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
      blocks: b,
      overheads: CaptureOverheads.fromPreferences(prefs),
      targetTransitsInWindow: false,
    ),
    blocks: b,
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

  Future<Session> saved() async {
    final s = await repo.create(_plan());
    return repo.savePlan(s.id, _plan(), _snapshot());
  }

  /// After the saved night's dawn (CALC-44), in the morning of the 16th.
  void afterDawn() => clock.now = DateTime.utc(2026, 12, 16, 7);

  int lightId(Session s, String filter) =>
      s.blocks.firstWhere((b) => b.filterName == filter).id;

  Future<void> expectCountersEqualReplay(int id) async {
    final s = (await repo.get(id))!;
    final replay = ExecutionMachine.fold({
      for (final b in s.blocks) b.id,
    }, await repo.events(id));
    final rows = await (db.select(
      db.captureBlocks,
    )..where((t) => t.sessionLogId.equals(id))).get();
    for (final r in rows) {
      expect(r.completedFrames, replay.completedFor(r.id), reason: 'block');
      expect(r.rejectedFrames, replay.rejectedFor(r.id));
    }
  }

  group('a Saved plan after its night', () {
    test(
      'before its night ends every outcome is refused, nothing written',
      () async {
        final s = await saved();
        clock.now = DateTime.utc(2026, 12, 16, 2); // still dark
        for (final report in <ResultReport>[
          const CompletedAsPlanned(),
          PartlyDone({lightId(s, 'L'): 3}),
          const NotDone(reason: NotDoneReason.clouds),
        ]) {
          await expectLater(
            repo.recordResult(s.id, report),
            throwsA(isA<NightNotEnded>()),
          );
        }
        final after = (await repo.get(s.id))!;
        expect(after.status, SessionStatus.planned);
        expect(await repo.events(s.id), isEmpty);
      },
    );

    test('Completed as planned: reported, then each light block\'s planned '
        'count; the snapshot unchanged; counters equal the replay', () async {
      final s = await saved();
      afterDawn();
      final done = await repo.recordResult(
        s.id,
        const CompletedAsPlanned(
          notes: ResultNotes(environmentalNotes: 'Clear', temperatureC: -3),
        ),
      );
      expect(done.status, SessionStatus.completed);
      expect(done.resultKind, ResultKind.asPlanned);
      expect(done.completedAtUtc, clock.now);
      expect(done.planSnapshot!.json, s.planSnapshot!.json);
      expect(done.record.actualLightFrames, 24);

      expect(done.record.environmentalNotes, 'Clear');
      expect(done.record.temperature, -3);
      final events = await repo.events(s.id);
      expect(events.map((e) => e.kind), [
        ExecutionEventKind.reported,
        ExecutionEventKind.framesConfirmed,
        ExecutionEventKind.framesConfirmed,
      ]);
      expect((events[1].blockId, events[1].delta), (lightId(s, 'L'), 20));
      expect((events[2].blockId, events[2].delta), (lightId(s, 'R'), 4));
      await expectCountersEqualReplay(s.id);
    });

    test('Partly: the typed counts, fewer or more than planned; 0 writes '
        'no event', () async {
      final s = await saved();
      afterDawn();
      final done = await repo.recordResult(
        s.id,
        PartlyDone({lightId(s, 'L'): 7, lightId(s, 'R'): 25}),
      );
      expect(done.resultKind, ResultKind.partly);
      expect(done.record.actualLightFrames, 32);
      final state = await repo.execution(s.id);
      expect(state.completedFor(lightId(s, 'L')), 7);
      expect(state.completedFor(lightId(s, 'R')), 25);
      await expectCountersEqualReplay(s.id);

      final other = await saved();
      final zero = await repo.recordResult(
        other.id,
        PartlyDone({lightId(other, 'L'): 0}),
      );
      expect(zero.record.actualLightFrames, 0);
      expect((await repo.events(other.id)).map((e) => e.kind), [
        ExecutionEventKind.reported,
      ]);
    });

    test('Not done: abandoned with the reason, no event, no counts', () async {
      final s = await saved();
      afterDawn();
      final done = await repo.recordResult(
        s.id,
        const NotDone(reason: NotDoneReason.clouds),
      );
      expect(done.status, SessionStatus.abandoned);
      expect(done.notDoneReason, NotDoneReason.clouds);
      expect(done.resultKind, isNull);
      expect(done.planSnapshot!.json, s.planSnapshot!.json);
      expect(await repo.events(s.id), isEmpty);

      final other = await saved();
      final noReason = await repo.recordResult(other.id, const NotDone());
      expect(noReason.status, SessionStatus.abandoned);
      expect(noReason.notDoneReason, isNull);
    });

    test('a stale form is refused and nothing is written', () async {
      final s = await saved();
      afterDawn();
      await expectLater(
        repo.recordResult(
          s.id,
          const CompletedAsPlanned(),
          expectedUpdatedAtUtc: s.updatedAtUtc!.subtract(
            const Duration(seconds: 1),
          ),
        ),
        throwsA(isA<StaleResultForm>()),
      );
      expect((await repo.get(s.id))!.status, SessionStatus.planned);
      expect(await repo.events(s.id), isEmpty);
      final ok = await repo.recordResult(
        s.id,
        const CompletedAsPlanned(),
        expectedUpdatedAtUtc: s.updatedAtUtc,
      );
      expect(ok.status, SessionStatus.completed);
    });

    test('a draft is refused: a changed saved plan is settled first', () async {
      final s = await saved();
      await repo.updatePlan(s.id, _plan()); // Saved · changed
      afterDawn();
      await expectLater(
        repo.recordResult(s.id, const CompletedAsPlanned()),
        throwsA(isA<SessionStateError>()),
      );
      expect(await repo.events(s.id), isEmpty);
    });
  });

  group('editing a result', () {
    test('counts change by corrections; as planned and partly exchange; '
        'completed never becomes not done', () async {
      final s = await saved();
      afterDawn();
      await repo.recordResult(s.id, const CompletedAsPlanned());
      final edited = await repo.recordResult(
        s.id,
        PartlyDone({lightId(s, 'L'): 12}),
      );
      expect(edited.resultKind, ResultKind.partly);
      // R keeps its reported 4: a block left out keeps its count.
      expect(edited.record.actualLightFrames, 16);
      final last = (await repo.events(s.id)).last;
      expect((last.kind, last.delta), (ExecutionEventKind.framesConfirmed, -8));
      await expectCountersEqualReplay(s.id);

      await expectLater(
        repo.recordResult(s.id, const NotDone()),
        throwsA(isA<SessionStateError>()),
      );
      expect((await repo.get(s.id))!.status, SessionStatus.completed);
    });

    test('a not-done entry keeps its status; its reason can change', () async {
      final s = await saved();
      afterDawn();
      await repo.recordResult(s.id, const NotDone());
      final edited = await repo.recordResult(
        s.id,
        const NotDone(reason: NotDoneReason.dew),
      );
      expect(edited.notDoneReason, NotDoneReason.dew);
      await expectLater(
        repo.recordResult(s.id, const CompletedAsPlanned()),
        throwsA(isA<SessionStateError>()),
      );
    });

    test('a legacy row is read-only', () async {
      final s = await saved();
      await (db.update(db.sessionLogs)..where((t) => t.id.equals(s.id))).write(
        const SessionLogsCompanion(legacy: Value(true)),
      );
      afterDawn();
      await expectLater(
        repo.recordResult(s.id, const CompletedAsPlanned()),
        throwsA(isA<SessionStateError>()),
      );
    });
  });

  group('a run in progress (the live mode, I-2)', () {
    test('Partly finishes it and corrects to the reported counts, keeping '
        'its events', () async {
      final s = await saved();
      await repo.start(s.id, _snapshot());
      final light = lightId(s, 'L');
      await repo.record(
        s.id,
        ExecutionEventKind.framesConfirmed,
        blockId: light,
        delta: 3,
      );
      final done = await repo.recordResult(s.id, PartlyDone({light: 10}));
      expect(done.status, SessionStatus.completed);
      expect(done.resultKind, ResultKind.partly);
      final kinds = (await repo.events(s.id)).map((e) => e.kind).toList();
      expect(kinds, [
        ExecutionEventKind.started,
        ExecutionEventKind.framesConfirmed,
        ExecutionEventKind.finished,
        ExecutionEventKind.framesConfirmed,
      ]);
      expect((await repo.execution(s.id)).completedFor(light), 10);
      await expectCountersEqualReplay(s.id);
    });

    test('Not done abandons it with the reason', () async {
      final s = await saved();
      await repo.start(s.id, _snapshot());
      final done = await repo.recordResult(
        s.id,
        const NotDone(reason: NotDoneReason.equipment),
      );
      expect(done.status, SessionStatus.abandoned);
      expect(done.notDoneReason, NotDoneReason.equipment);
      expect((await repo.events(s.id)).last.kind, ExecutionEventKind.abandoned);
    });
  });

  group('settling a Saved · changed plan (I-3)', () {
    test('the working edits move to a new never-saved draft; the entry is '
        'Saved again, its snapshot unchanged; a repeat does nothing', () async {
      final s = await saved();
      final extra = domain.CaptureBlock(
        frameType: domain.FrameType.light,
        filterName: 'Ha',
        exposureTimeSeconds: 600,
        frameCount: 5,
      );
      await repo.updatePlan(
        s.id,
        _plan(night: CalendarDate(2026, 12, 20), blocks: [..._blocks, extra]),
      );
      final copy = (await repo.settleSavedPlan(s.id))!;
      expect(copy.status, SessionStatus.draft);
      expect(copy.plannedAtUtc, isNull);
      expect(copy.eveningDate, CalendarDate(2026, 12, 20));
      expect(copy.blocks.map((b) => b.filterName), [null, 'L', 'R', 'Ha']);

      final entry = (await repo.get(s.id))!;
      expect(entry.status, SessionStatus.planned);
      expect(entry.eveningDate, CalendarDate(2026, 12, 15));
      expect(entry.blocks.map((b) => b.filterName), [null, 'L', 'R']);
      expect(entry.planSnapshot!.json, s.planSnapshot!.json);
      expect(entry.plannedAtUtc, s.plannedAtUtc);

      expect(await repo.settleSavedPlan(s.id), isNull);
      expect(await repo.settleSavedPlan(copy.id), isNull);
      expect(await repo.list(), hasLength(2));
    });

    test('an unreadable snapshot: the plan stays as it is; only the copy is '
        'made', () async {
      final s = await saved();
      await repo.updatePlan(s.id, _plan(night: CalendarDate(2026, 12, 20)));
      await (db.update(db.sessionLogs)..where((t) => t.id.equals(s.id))).write(
        const SessionLogsCompanion(planSnapshot: Value({'v': 99})),
      );
      final copy = await repo.settleSavedPlan(s.id);
      expect(copy, isNotNull);
      final entry = (await repo.get(s.id))!;
      expect(entry.isSavedChanged, isTrue);
      expect(entry.eveningDate, CalendarDate(2026, 12, 20));
    });

    test('a Saved plan, a draft and a result are not settled', () async {
      final s = await saved();
      expect(await repo.settleSavedPlan(s.id), isNull);
      final draft = await repo.create(_plan());
      expect(await repo.settleSavedPlan(draft.id), isNull);
      expect(await repo.list(), hasLength(2));
    });
  });

  group('S8.6: the optional name', () {
    test('trimmed; empty removes it; the plan, status and snapshot never '
        'change; too long and legacy are refused', () async {
      final s = await saved();
      final named = await repo.rename(s.id, '  Orion, first light  ');
      expect(named.name, 'Orion, first light');
      expect(named.status, SessionStatus.planned, reason: 'not an edit');
      expect(named.planSnapshot!.json, s.planSnapshot!.json);
      expect(named.blocks.length, s.blocks.length);
      expect((await repo.rename(s.id, '   ')).name, isNull);
      expect((await repo.rename(s.id, null)).name, isNull);
      await expectLater(
        repo.rename(s.id, 'x' * 81),
        throwsA(isA<ArgumentError>()),
      );
      await (db.update(db.sessionLogs)..where((t) => t.id.equals(s.id))).write(
        const SessionLogsCompanion(legacy: Value(true)),
      );
      await expectLater(
        repo.rename(s.id, 'Old'),
        throwsA(isA<SessionStateError>()),
      );
    });

    test('a working copy never takes the name', () async {
      final s = await saved();
      await repo.rename(s.id, 'Friday');
      await repo.updatePlan(s.id, _plan(night: CalendarDate(2026, 12, 20)));
      final copy = (await repo.settleSavedPlan(s.id))!;
      expect(copy.name, isNull);
      expect((await repo.get(s.id))!.name, 'Friday');
    });
  });

  group('CALC-44 (SavedNightEnd)', () {
    test('a mid-latitude winter night ends at dawn at the darkness limit, '
        'hours before the window\'s noon', () {
      final end = SavedNightEnd.ofSnapshot(_snapshot())!;
      // Ljubljana, 16 Dec: astronomical dawn about 04:50 UTC.
      expect(end.isAfter(DateTime.utc(2026, 12, 16, 4, 30)), isTrue);
      expect(end.isBefore(DateTime.utc(2026, 12, 16, 5, 15)), isTrue);
    });

    SessionSnapshot at(double latitude, int month) {
      final prefs = PlanningPreferences();
      return SessionSnapshotBuilder.build(
        takenAtUtc: DateTime.utc(2026, month, 15, 18),
        night: SessionNight(
          eveningDate: CalendarDate(2026, month, 15),
          startUtc: DateTime.utc(2026, month, 15, 11),
          endUtc: DateTime.utc(2026, month, 16, 11),
          latitude: latitude,
          longitude: 14.51,
          timeContextId: 'mean-solar',
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

    test('no darkness at the limit (a summer night at 60° N) or darkness all '
        'window (89° N in December): the night\'s end', () {
      expect(
        SavedNightEnd.ofSnapshot(at(60, 6)),
        DateTime.utc(2026, 6, 16, 11),
      );
      expect(
        SavedNightEnd.ofSnapshot(at(89, 12)),
        DateTime.utc(2026, 12, 16, 11),
      );
    });

    test('without a readable snapshot: the latest end of its night key', () {
      final s = Session(
        record: _logFor(1),
        status: SessionStatus.planned,
        legacy: false,
        eveningDate: CalendarDate(2026, 12, 15),
      );
      expect(SavedNightEnd.of(s), DateTime.utc(2026, 12, 17));
      expect(SavedNightEnd.hasEnded(s, DateTime.utc(2026, 12, 16, 23)), false);
      expect(SavedNightEnd.hasEnded(s, DateTime.utc(2026, 12, 17)), true);
    });
  });
}

log.SessionLog _logFor(int id) => log.SessionLog(
  id: id,
  targetName: 'M42',
  equipmentName: 'Rig',
  sessionDate: DateTime.utc(2026, 12, 15),
);
