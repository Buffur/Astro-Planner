// S6.3 (U1; S4-DEF-04 = R; ADR-019 §3.1's invariant): the repository side
// of Discard. Only a never-saved draft is ever deleted; a Saved · changed
// plan goes back to its saved snapshot, which is never changed; everything
// else is refused and nothing changes. Real SQLite (in memory).

import 'package:astroplan/core/time/clock.dart';
import 'package:astroplan/data/database/app_database.dart';
import 'package:astroplan/data/repositories/drift_session_repository.dart';
import 'package:astroplan/data/repositories/drift_target_repository.dart';
import 'package:astroplan/domain/models/astro_target.dart' as domain;
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
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';

class _Clock extends Clock {
  DateTime now = DateTime.utc(2026, 12, 15, 18);
  @override
  DateTime nowUtc() => now;
  void minutes(int m) => now = now.add(Duration(minutes: m));
}

domain.CaptureBlock _light(int frames) => domain.CaptureBlock(
  frameType: domain.FrameType.light,
  filterName: 'L',
  exposureTimeSeconds: 300,
  frameCount: frames,
);

SessionPlan _plan(int frames, {int? targetId}) => SessionPlan(
  eveningDate: CalendarDate(2026, 12, 15),
  timeZoneId: 'Europe/Ljubljana',
  siteId: null,
  targetId: targetId,
  rigId: null,
  blocks: [_light(frames)],
  targetLabel: 'M42',
  rigLabel: 'Rig',
);

final _night = SessionNight(
  eveningDate: CalendarDate(2026, 12, 15),
  startUtc: DateTime.utc(2026, 12, 15, 11),
  endUtc: DateTime.utc(2026, 12, 16, 11),
  latitude: 46.05,
  longitude: 14.51,
  timeContextId: 'Europe/Ljubljana',
);

SessionSnapshot _snapshot(int frames, {domain.AstroTarget? target}) {
  final prefs = PlanningPreferences();
  final blocks = [_light(frames)];
  return SessionSnapshotBuilder.build(
    takenAtUtc: DateTime.utc(2026, 12, 15, 18),
    night: _night,
    timeZoneId: 'Europe/Ljubljana',
    preferences: prefs,
    budget: CaptureBudgetCalculator.calculate(
      blocks: blocks,
      overheads: CaptureOverheads.fromPreferences(prefs),
    ),
    blocks: blocks,
    target: target,
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

  List<int> frames(Session s) => [for (final b in s.blocks) b.frameCount];

  /// Saved with 20 frames, then changed to 7: Saved · changed.
  Future<Session> savedChanged({domain.AstroTarget? target}) async {
    final s = await repo.create(_plan(20, targetId: target?.id));
    await repo.savePlan(
      s.id,
      _plan(20, targetId: target?.id),
      _snapshot(20, target: target),
    );
    clock.minutes(5);
    return repo.updatePlan(s.id, _plan(7, targetId: target?.id));
  }

  Future<int> blockRows(int sessionId) async => (await (db.select(
    db.captureBlocks,
  )..where((t) => t.sessionLogId.equals(sessionId))).get()).length;

  group('deleteDraft', () {
    test('deletes a never-saved draft with its blocks', () async {
      final s = await repo.create(_plan(10));
      await repo.deleteDraft(s.id);
      expect(await repo.get(s.id), isNull);
      expect(await blockRows(s.id), 0);
      await repo.deleteDraft(s.id); // already gone: not an error
    });

    test(
      'refuses every saved or frozen session, and changes nothing',
      () async {
        final planned = await repo.create(_plan(10));
        await repo.savePlan(planned.id, _plan(10), _snapshot(10));
        final changed = await savedChanged();
        final running = await repo.create(_plan(10));
        await repo.start(running.id, _snapshot(10));
        final finished = await repo.create(_plan(10));
        await repo.abandon(finished.id);

        for (final id in [planned.id, changed.id, running.id, finished.id]) {
          final before = (await repo.get(id))!;
          await expectLater(
            repo.deleteDraft(id),
            throwsA(isA<SessionStateError>()),
          );
          final after = (await repo.get(id))!;
          expect(after.status, before.status);
          expect(after.planSnapshot?.json, before.planSnapshot?.json);
          expect(frames(after), frames(before));
        }
      },
    );
  });

  group('revertToSaved', () {
    test('puts a Saved · changed plan back as saved; the snapshot and the '
        'saved time are unchanged', () async {
      final changed = await savedChanged();
      expect(changed.status, SessionStatus.draft);
      expect(frames(changed), [7]);

      clock.minutes(5);
      final reverted = await repo.revertToSaved(changed.id);
      expect(reverted.status, SessionStatus.planned);
      expect(frames(reverted), [20]);
      expect(reverted.eveningDate, CalendarDate(2026, 12, 15));
      expect(reverted.plannedAtUtc, changed.plannedAtUtc);
      expect(reverted.planSnapshot!.json, changed.planSnapshot!.json);
    });

    test('refuses a never-saved draft, a saved plan without changes and a '
        'run', () async {
      final draft = await repo.create(_plan(10));
      final planned = await repo.create(_plan(10));
      await repo.savePlan(planned.id, _plan(10), _snapshot(10));
      final running = await repo.create(_plan(10));
      await repo.start(running.id, _snapshot(10));
      for (final id in [draft.id, planned.id, running.id]) {
        final before = (await repo.get(id))!;
        await expectLater(
          repo.revertToSaved(id),
          throwsA(isA<SessionStateError>()),
        );
        expect((await repo.get(id))!.status, before.status);
      }
    });

    test('refuses, changing nothing, when the saved plan names a target that '
        'no longer exists', () async {
      final targets = DriftTargetRepository(db);
      final id = await targets.insertTarget(
        domain.AstroTarget(
          id: 0,
          catalogId: 'M31',
          commonName: 'Andromeda Galaxy',
          type: 'Galaxy',
          rightAscension: 10.68,
          declination: 41.27,
        ),
      );
      final target = (await targets.getTargetById(id))!;
      final changed = await savedChanged(target: target);
      await targets.deleteTarget(id);
      final before = (await repo.get(changed.id))!;

      await expectLater(
        repo.revertToSaved(changed.id),
        throwsA(isA<SavedPlanUnavailable>()),
      );
      final after = (await repo.get(changed.id))!;
      expect(after.status, SessionStatus.draft);
      expect(frames(after), frames(before));
      expect(after.planSnapshot!.json, before.planSnapshot!.json);
    });

    test('refuses, changing nothing, when the saved snapshot cannot be '
        'read', () async {
      final s = await repo.create(_plan(20));
      final unreadable = SessionSnapshot.fromBuilder({
        ..._snapshot(20).json,
        'blocks': 'junk',
      });
      await repo.savePlan(s.id, _plan(20), unreadable);
      await repo.updatePlan(s.id, _plan(7));

      await expectLater(
        repo.revertToSaved(s.id),
        throwsA(isA<SavedPlanUnavailable>()),
      );
      final after = (await repo.get(s.id))!;
      expect(after.status, SessionStatus.draft);
      expect(frames(after), [7]);
    });
  });

  test('a run\'s counters still equal its replayed events after drafts are '
      'discarded and a saved plan is reverted', () async {
    final run = await repo.create(_plan(10));
    final started = await repo.start(run.id, _snapshot(10));
    final block = started.blocks.single.id;
    await repo.record(
      run.id,
      ExecutionEventKind.framesConfirmed,
      blockId: block,
      delta: 3,
    );

    final draft = await repo.create(_plan(5));
    await repo.deleteDraft(draft.id);
    final changed = await savedChanged();
    await repo.revertToSaved(changed.id);

    final rows = await (db.select(
      db.captureBlocks,
    )..where((t) => t.sessionLogId.equals(run.id))).get();
    final replayed = ExecutionMachine.fold({block}, await repo.events(run.id));
    for (final r in rows) {
      expect(replayed.completedFor(r.id), r.completedFrames);
      expect(replayed.rejectedFor(r.id), r.rejectedFrames);
    }
    expect(rows.single.completedFrames, 3);
  });
}
