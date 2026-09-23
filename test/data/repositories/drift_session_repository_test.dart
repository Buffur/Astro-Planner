// TASK 11.3 (ADR-014): the Session repository — one transaction per write,
// the lifecycle enforced, frozen sessions untouched, legacy rows read-only,
// and a saved snapshot unchanged after its source is edited. Replaces the
// DriftLogbookRepository tests (order, block fidelity, rejected rows).

import 'package:astroplan/core/time/clock.dart';
import 'package:astroplan/data/database/app_database.dart';
import 'package:astroplan/data/repositories/drift_equipment_repository.dart';
import 'package:astroplan/data/repositories/drift_session_repository.dart';
import 'package:astroplan/domain/models/calendar_date.dart';
import 'package:astroplan/domain/models/capture_block.dart' as domain;
import 'package:astroplan/domain/models/equipment_profile.dart' as domain;
import 'package:astroplan/domain/models/planning_preferences.dart';
import 'package:astroplan/domain/models/session.dart';
import 'package:astroplan/domain/models/session_night.dart';
import 'package:astroplan/domain/models/session_snapshot.dart';
import 'package:astroplan/domain/services/capture_budget_calculator.dart';
import 'package:astroplan/domain/services/session_snapshot_builder.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';

class _Clock extends Clock {
  DateTime now = DateTime.utc(2026, 9, 24, 12);
  @override
  DateTime nowUtc() => now;
  void tick() => now = now.add(const Duration(minutes: 1));
}

domain.CaptureBlock _light({int count = 20}) => domain.CaptureBlock(
  frameType: domain.FrameType.light,
  exposureTimeSeconds: 300,
  frameCount: count,
);

SessionPlan _plan({
  String target = 'M31',
  CalendarDate? evening,
  int? targetId,
  int? rigId,
  List<domain.CaptureBlock>? blocks,
}) => SessionPlan(
  eveningDate: evening ?? CalendarDate(2026, 9, 24),
  timeZoneId: 'Europe/Ljubljana',
  siteId: null,
  targetId: targetId,
  rigId: rigId,
  blocks: blocks ?? [_light()],
  targetLabel: target,
  rigLabel: 'Rig',
  siteLabel: 'Home',
);

final _night = SessionNight(
  eveningDate: CalendarDate(2026, 9, 24),
  startUtc: DateTime.utc(2026, 9, 24, 11),
  endUtc: DateTime.utc(2026, 9, 25, 11),
  latitude: 46.05,
  longitude: 14.51,
  timeContextId: 'Europe/Ljubljana',
);

SessionSnapshot _snapshot({domain.EquipmentProfile? rig, int minute = 0}) {
  final prefs = PlanningPreferences();
  final blocks = [_light()];
  return SessionSnapshotBuilder.build(
    takenAtUtc: DateTime.utc(2026, 9, 24, 12, minute),
    night: _night,
    preferences: prefs,
    budget: CaptureBudgetCalculator.calculate(
      blocks: blocks,
      overheads: CaptureOverheads.fromPreferences(prefs),
      targetTransitsInWindow: false,
    ),
    blocks: blocks,
    rig: rig,
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

  test('create makes a draft with the plan, labels and timestamps', () async {
    final s = await repo.create(_plan());
    expect(s.id, isPositive);
    expect(s.status, SessionStatus.draft);
    expect(s.legacy, isFalse);
    expect(s.eveningDate, CalendarDate(2026, 9, 24));
    expect(s.timeZoneId, 'Europe/Ljubljana');
    expect(s.record.targetName, 'M31');
    expect(s.record.plannedLightFrames, 20);
    expect(s.createdAtUtc, clock.now);
    expect(s.blocks.single.frameCount, 20);
    expect(s.planSnapshot, isNull);
  });

  test('list is newest-updated first and filters combine', () async {
    final a = await repo.create(_plan(target: 'A', targetId: null));
    clock.tick();
    final b = await repo.create(
      _plan(target: 'B', evening: CalendarDate(2026, 9, 25)),
    );
    clock.tick();
    await repo.updatePlan(a.id, _plan(target: 'A2'));

    expect((await repo.list()).map((s) => s.id), [a.id, b.id]);
    expect(
      (await repo.list(eveningDate: CalendarDate(2026, 9, 25))).single.id,
      b.id,
    );
    expect(await repo.list(statuses: {SessionStatus.planned}), isEmpty);
  });

  test(
    'blocks keep their order, policy and gain through save and update',
    () async {
      final blocks = [
        domain.CaptureBlock(
          frameType: domain.FrameType.flat,
          exposureTimeSeconds: 2,
          frameCount: 3,
        ),
        domain.CaptureBlock(
          frameType: domain.FrameType.light,
          exposureTimeSeconds: 300,
          frameCount: 20,
          gain: domain.CaptureGain.gain(120),
        ),
        domain.CaptureBlock(
          frameType: domain.FrameType.dark,
          exposureTimeSeconds: 300,
          frameCount: 10,
          calibrationPolicy: domain.CalibrationPolicy.inWindow,
        ),
      ];
      final s = await repo.create(_plan(blocks: blocks));
      var saved = s.blocks;
      expect(saved.map((b) => b.frameType), [
        domain.FrameType.flat,
        domain.FrameType.light,
        domain.FrameType.dark,
      ]);
      expect(saved[1].gain, domain.CaptureGain.gain(120));
      expect(saved[2].calibrationPolicy, domain.CalibrationPolicy.inWindow);
      expect(
        saved[0].calibrationPolicy,
        domain.CalibrationPolicy.outsideWindow,
      );

      saved = (await repo.updatePlan(
        s.id,
        _plan(blocks: [saved[2], saved[0], saved[1]]),
      )).blocks;
      expect(saved.map((b) => b.frameType), [
        domain.FrameType.dark,
        domain.FrameType.flat,
        domain.FrameType.light,
      ]);
    },
  );

  test('a stored block the domain rejects is skipped, not read as a light', () async {
    final s = await repo.create(_plan(blocks: const []));
    await db.customStatement(
      "INSERT INTO capture_blocks (session_log_id, frame_type, "
      "exposure_time_seconds, frame_count) VALUES (${s.id}, 'mystery', 60, 5), "
      "(${s.id}, 'dark', 60, 0), (${s.id}, 'dark', 60, 5);",
    );
    final blocks = (await repo.get(s.id))!.blocks;
    expect(blocks.single.frameType, domain.FrameType.dark);
    expect(blocks.single.frameCount, 5);
  });

  test('savePlan marks planned and replaces the plan snapshot; an edit goes '
      'back to draft', () async {
    final s = await repo.create(_plan());
    clock.tick();
    var saved = await repo.savePlan(s.id, _plan(), _snapshot(minute: 1));
    expect(saved.status, SessionStatus.planned);
    expect(saved.plannedAtUtc, clock.now);
    expect(saved.planSnapshot!.takenAtUtc, DateTime.utc(2026, 9, 24, 12, 1));

    saved = await repo.savePlan(s.id, _plan(), _snapshot(minute: 2));
    expect(saved.planSnapshot!.takenAtUtc, DateTime.utc(2026, 9, 24, 12, 2));

    saved = await repo.updatePlan(s.id, _plan(blocks: [_light(count: 5)]));
    expect(saved.status, SessionStatus.draft);
    expect(saved.blocks.single.frameCount, 5);
  });

  test('lifecycle: start freezes the plan and its snapshot; completed keeps '
      'only results and notes editable', () async {
    final s = await repo.create(_plan());
    await repo.savePlan(s.id, _plan(), _snapshot(minute: 1));
    var started = await repo.start(s.id, _snapshot(minute: 5));
    expect(started.status, SessionStatus.inProgress);
    expect(
      started.executionStartSnapshot!.takenAtUtc,
      DateTime.utc(2026, 9, 24, 12, 5),
    );
    await expectLater(
      repo.start(s.id, _snapshot(minute: 9)),
      throwsA(isA<SessionStateError>()),
    );
    await expectLater(
      repo.updatePlan(s.id, _plan()),
      throwsA(isA<SessionStateError>()),
    );

    final done = await repo.complete(s.id);
    expect(done.status, SessionStatus.completed);
    expect(done.completedAtUtc, isNotNull);
    await expectLater(
      repo.savePlan(s.id, _plan(), _snapshot()),
      throwsA(isA<SessionStateError>()),
    );
    await expectLater(repo.abandon(s.id), throwsA(isA<SessionStateError>()));

    final noted = await repo.updateResults(
      s.id,
      const SessionResults(actualLightFrames: 18, processingNotes: 'ok'),
    );
    expect(noted.record.actualLightFrames, 18);
    expect(noted.record.processingNotes, 'ok');
    started = (await repo.get(s.id))!;
    expect(
      started.executionStartSnapshot!.takenAtUtc,
      DateTime.utc(2026, 9, 24, 12, 5),
      reason: 'the execution-start snapshot never changes',
    );
    expect(started.blocks.single.frameCount, 20);
  });

  test('forbidden transitions are refused', () async {
    final s = await repo.create(_plan());
    await expectLater(repo.complete(s.id), throwsA(isA<SessionStateError>()));
    final gone = await repo.abandon(s.id);
    expect(gone.status, SessionStatus.abandoned);
    await expectLater(
      repo.updatePlan(s.id, _plan()),
      throwsA(isA<SessionStateError>()),
    );
  });

  // Acceptance-adjacent: one transaction per aggregate write.
  test('a failing write rolls back completely', () async {
    final s = await repo.create(_plan(blocks: [_light(count: 7)]));
    await expectLater(
      repo.savePlan(s.id, _plan(rigId: 9999, blocks: []), _snapshot()),
      throwsA(anything), // FOREIGN KEY constraint failed
    );
    final after = (await repo.get(s.id))!;
    expect(after.status, SessionStatus.draft);
    expect(after.rigId, isNull);
    expect(after.planSnapshot, isNull);
    expect(
      after.blocks.single.frameCount,
      7,
      reason: 'the blocks deleted inside the failed transaction are back',
    );
  });

  test('legacy rows, and rows without a night key, are read-only and still '
      'listed', () async {
    await db.customStatement(
      "INSERT INTO session_logs (id, target_name, equipment_name, "
      "session_date, planned_light_frames, status, legacy) VALUES "
      "(100, 'Old', 'Rig', 0, 5, 'completed', 1), "
      "(101, 'Gap', 'Rig', 0, 5, 'draft', 0);",
    );
    final all = await repo.list();
    expect(all.map((s) => s.id), containsAll([100, 101]));
    for (final id in [100, 101]) {
      final s = (await repo.get(id))!;
      expect(s.legacy, isTrue);
      await expectLater(
        repo.updatePlan(id, _plan()),
        throwsA(isA<SessionStateError>()),
      );
      await expectLater(
        repo.updateResults(id, const SessionResults()),
        throwsA(isA<SessionStateError>()),
      );
    }
    expect(await repo.list(includeLegacy: false), isEmpty);
    expect(await repo.mostRecentOpen(), isNull);
  });

  test(
    'mostRecentOpen is the latest-updated open, non-legacy session',
    () async {
      final a = await repo.create(_plan(target: 'A'));
      clock.tick();
      final b = await repo.create(_plan(target: 'B'));
      clock.tick();
      await repo.abandon(b.id);
      expect((await repo.mostRecentOpen())!.id, a.id);
      clock.tick();
      final c = await repo.create(_plan(target: 'C'));
      expect((await repo.mostRecentOpen())!.id, c.id);
    },
  );

  test('delete removes the session and its blocks', () async {
    final s = await repo.create(_plan());
    await repo.delete(s.id);
    expect(await repo.get(s.id), isNull);
    expect(await db.select(db.captureBlocks).get(), isEmpty);
  });

  // Acceptance: editing a rig after saving leaves the saved snapshot intact.
  test('editing the rig after saving leaves the snapshot unchanged', () async {
    final equipment = DriftEquipmentRepository(db);
    final rigId = await equipment.insertEquipment(
      domain.EquipmentProfile(
        id: 0,
        name: 'Refractor',
        focalRatio: 5,
        focalLengthMm: 400,
        sensorWidthMm: 23.5,
        sensorHeightMm: 15.6,
        resolutionWidthPx: 6000,
        resolutionHeightPx: 4000,
        pixelPitchUm: 3.76,
      ),
    );
    final rig = (await equipment.getEquipmentById(rigId))!;
    final s = await repo.create(_plan(rigId: rigId));
    await repo.savePlan(s.id, _plan(rigId: rigId), _snapshot(rig: rig));

    await equipment.updateEquipment(
      domain.EquipmentProfile(
        id: rig.id,
        name: 'Refractor + reducer',
        focalRatio: 4,
        focalLengthMm: 320,
        sensorWidthMm: 23.5,
        sensorHeightMm: 15.6,
        resolutionWidthPx: 6000,
        resolutionHeightPx: 4000,
        pixelPitchUm: 3.76,
      ),
    );

    expect((await equipment.getEquipmentById(rigId))!.focalLengthMm, 320);

    final saved = (await repo.get(s.id))!.planSnapshot!;
    expect(saved.rigName, 'Refractor');
    expect(saved.rigFocalLengthMm, 400);
    expect((await repo.get(s.id))!.rigId, rigId);
  });
}
