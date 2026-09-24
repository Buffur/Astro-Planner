// CALC-37 (TASK 13.4): planned vs actual. Integration counts confirmed
// light frames × exposure; rejected frames and calibration blocks are not
// integration; totals are light frames only.

import 'package:astroplan/domain/models/capture_block.dart';
import 'package:astroplan/domain/models/execution.dart';
import 'package:astroplan/domain/services/execution_machine.dart';
import 'package:astroplan/domain/services/session_reconciliation.dart';
import 'package:flutter_test/flutter_test.dart';

final _t = DateTime.utc(2026, 12, 15, 19);

final _blocks = [
  CaptureBlock(
    id: 1,
    frameType: FrameType.light,
    filterName: 'L',
    exposureTimeSeconds: 300,
    frameCount: 24, // 2 h planned
  ),
  CaptureBlock(
    id: 2,
    frameType: FrameType.light,
    filterName: 'Ha',
    exposureTimeSeconds: 600,
    frameCount: 6, // 1 h planned
  ),
  CaptureBlock(
    id: 3,
    frameType: FrameType.dark,
    exposureTimeSeconds: 300,
    frameCount: 20,
    calibrationPolicy: CalibrationPolicy.outsideWindow,
  ),
];

ExecutionState _run(List<(ExecutionEventKind, int, int)> events) {
  var s = ExecutionMachine.fold({1, 2, 3}, const []);
  s = ExecutionMachine.apply(
    s,
    ExecutionMachine.next(s, ExecutionEventKind.started, _t, blockId: 1),
  );
  for (final (kind, block, delta) in events) {
    s = ExecutionMachine.apply(
      s,
      ExecutionMachine.next(s, kind, _t, blockId: block, delta: delta),
    );
  }
  return s;
}

void main() {
  test('planned integration: lights only (3 h)', () {
    final r = SessionReconciliation.of(_blocks, _run(const []));
    expect(r.plannedIntegration, const Duration(hours: 3));
    expect(r.actualIntegration, Duration.zero);
    expect(r.fraction, 0);
  });

  test('actual integration: confirmed lights × exposure; rejected and '
      'darks are not integration', () {
    final r = SessionReconciliation.of(
      _blocks,
      _run(const [
        (ExecutionEventKind.framesConfirmed, 1, 20), // 100 min
        (ExecutionEventKind.framesRejected, 1, 2),
        (ExecutionEventKind.framesConfirmed, 2, 3), // 30 min
        (ExecutionEventKind.framesConfirmed, 3, 20), // darks
      ]),
    );
    expect(r.actualIntegration, const Duration(minutes: 130));
    expect(r.actualLightFrames, 23);
    expect(r.rejectedLightFrames, 2);
    expect(r.fraction, closeTo(130 / 180, 1e-9));
    expect(r.blocks[2].confirmed, 20);
    expect(r.blocks[2].actualIntegration, Duration.zero);
  });

  test('more than planned is reported as it is', () {
    final r = SessionReconciliation.of(
      _blocks,
      _run(const [(ExecutionEventKind.framesConfirmed, 2, 9)]),
    );
    expect(r.blocks[1].actualIntegration, const Duration(minutes: 90));
    expect(r.blocks[1].plannedIntegration, const Duration(minutes: 60));
  });

  test('no light block: no fraction, never a division by zero', () {
    final r = SessionReconciliation.of([_blocks[2]], _run(const []));
    expect(r.plannedIntegration, Duration.zero);
    expect(r.fraction, isNull);
  });
}
