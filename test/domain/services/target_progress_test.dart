// CALC-38 (TASK 14.2): integration so far per target — completed,
// non-legacy sessions only; confirmed light frames × exposure, per filter;
// the last imaged night; the session count.

import 'package:astroplan/domain/models/calendar_date.dart';
import 'package:astroplan/domain/models/capture_block.dart';
import 'package:astroplan/domain/models/execution.dart';
import 'package:astroplan/domain/models/session.dart';
import 'package:astroplan/domain/models/session_log.dart';
import 'package:astroplan/domain/services/execution_machine.dart';
import 'package:astroplan/domain/services/target_progress.dart';
import 'package:flutter_test/flutter_test.dart';

final _t = DateTime.utc(2026, 12, 15, 19);

CaptureBlock _b(int id, FrameType type, String? filter, double exp) =>
    CaptureBlock(
      id: id,
      frameType: type,
      filterName: filter,
      exposureTimeSeconds: exp,
      frameCount: 100,
    );

(Session, ExecutionState) _run({
  required int id,
  int? targetId = 42,
  String name = 'M42',
  SessionStatus status = SessionStatus.completed,
  bool legacy = false,
  CalendarDate? night,
  required List<CaptureBlock> blocks,
  required Map<int, int> confirmed,
}) {
  var s = ExecutionMachine.fold({for (final b in blocks) b.id}, const []);
  s = ExecutionMachine.apply(
    s,
    ExecutionMachine.next(
      s,
      ExecutionEventKind.started,
      _t,
      blockId: blocks.first.id,
    ),
  );
  for (final MapEntry(:key, :value) in confirmed.entries) {
    s = ExecutionMachine.apply(
      s,
      ExecutionMachine.next(
        s,
        ExecutionEventKind.framesConfirmed,
        _t,
        blockId: key,
        delta: value,
      ),
    );
  }
  return (
    Session(
      record: SessionLog(
        id: id,
        targetName: name,
        equipmentName: 'Rig',
        sessionDate: _t,
        captureBlocks: blocks,
        plannedLightFrames: 100,
      ),
      status: status,
      legacy: legacy,
      targetId: targetId,
      eveningDate: night,
    ),
    s,
  );
}

void main() {
  test('sums confirmed light integration per filter across nights', () {
    final p = TargetProgress.of([
      _run(
        id: 1,
        night: CalendarDate(2026, 12, 1),
        blocks: [
          _b(1, FrameType.light, 'Ha', 300),
          _b(2, FrameType.dark, null, 300),
        ],
        confirmed: {1: 12, 2: 20}, // 1 h Ha; darks are not integration
      ),
      _run(
        id: 2,
        night: CalendarDate(2026, 12, 15),
        blocks: [
          _b(3, FrameType.light, 'Ha', 300),
          _b(4, FrameType.light, null, 60),
        ],
        confirmed: {3: 6, 4: 30}, // 30 min Ha + 30 min no filter
      ),
    ])[42]!;
    expect(p.integration, const Duration(hours: 2));
    expect(p.perFilter['Ha'], const Duration(minutes: 90));
    expect(p.perFilter[TargetProgress.noFilter], const Duration(minutes: 30));
    expect(p.lastNight, CalendarDate(2026, 12, 15));
    expect(p.sessionCount, 2);
  });

  test('only completed, non-legacy sessions with a target count', () {
    final blocks = [_b(1, FrameType.light, 'L', 60)];
    final progress = TargetProgress.of([
      _run(id: 1, blocks: blocks, confirmed: {1: 10}),
      _run(
        id: 2,
        status: SessionStatus.abandoned,
        blocks: blocks,
        confirmed: {1: 10},
      ),
      _run(id: 3, legacy: true, blocks: blocks, confirmed: {1: 10}),
      _run(id: 4, targetId: null, blocks: blocks, confirmed: {1: 10}),
    ]);
    expect(progress.keys, [42]);
    expect(progress[42]!.integration, const Duration(minutes: 10));
    expect(progress[42]!.sessionCount, 1);
  });

  test(
    'a completed session with nothing confirmed still counts as a session',
    () {
      final p = TargetProgress.of([
        _run(id: 1, blocks: [_b(1, FrameType.light, 'L', 60)], confirmed: {}),
      ])[42]!;
      expect(p.integration, Duration.zero);
      expect(p.sessionCount, 1);
    },
  );

  test('targets are kept apart; the label is the newest session\'s name', () {
    final blocks = [_b(1, FrameType.light, 'L', 60)];
    final progress = TargetProgress.of([
      _run(
        id: 1,
        name: 'Orion',
        night: CalendarDate(2026, 12, 1),
        blocks: blocks,
        confirmed: {1: 1},
      ),
      _run(
        id: 2,
        name: 'Orion Nebula',
        night: CalendarDate(2026, 12, 9),
        blocks: blocks,
        confirmed: {1: 1},
      ),
      _run(id: 3, targetId: 7, name: 'M31', blocks: blocks, confirmed: {1: 5}),
    ]);
    expect(progress[42]!.label, 'Orion Nebula');
    expect(progress[7]!.integration, const Duration(minutes: 5));
  });
}
