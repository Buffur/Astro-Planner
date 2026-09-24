// The execution state machine (TASK 13.2, ADR-016): the transition table,
// running time across pauses and block changes, clock jumps both ways, the
// frame estimate, and staleness. Pure: "now" is always passed in.

import 'package:astroplan/domain/models/execution.dart';
import 'package:astroplan/domain/services/execution_machine.dart';
import 'package:flutter_test/flutter_test.dart';

final _t0 = DateTime.utc(2026, 12, 15, 18);
DateTime _at(int minutes) => _t0.add(Duration(minutes: minutes));

/// Applies [kind] at [minutes] after t0 through [ExecutionMachine.next].
ExecutionState _step(
  ExecutionState s,
  ExecutionEventKind kind,
  int minutes, {
  int? blockId,
  int? delta,
  InterruptionReason? reason,
}) => ExecutionMachine.apply(
  s,
  ExecutionMachine.next(
    s,
    kind,
    _at(minutes),
    blockId: blockId,
    delta: delta,
    reason: reason,
  ),
);

const _blocks = {1, 2};

ExecutionState _notStarted() =>
    ExecutionMachine.fold(_blocks, const <ExecutionEvent>[]);
ExecutionState _running() =>
    _step(_notStarted(), ExecutionEventKind.started, 0, blockId: 1);
ExecutionState _paused() => _step(_running(), ExecutionEventKind.paused, 10);
ExecutionState _finished() => ExecutionMachine.apply(
  _running(),
  ExecutionMachine.next(_running(), ExecutionEventKind.finished, _at(20)),
);

void main() {
  group('transition table', () {
    // What each phase allows; every other (phase, kind) pair is refused.
    final allowed = <ExecutionPhase, Set<ExecutionEventKind>>{
      ExecutionPhase.notStarted: {ExecutionEventKind.started},
      ExecutionPhase.running: {
        ExecutionEventKind.blockSelected,
        ExecutionEventKind.paused,
        ExecutionEventKind.interrupted,
        ExecutionEventKind.framesConfirmed,
        ExecutionEventKind.framesRejected,
        ExecutionEventKind.finished,
        ExecutionEventKind.abandoned,
      },
      ExecutionPhase.paused: {
        ExecutionEventKind.blockSelected,
        ExecutionEventKind.resumed,
        ExecutionEventKind.framesConfirmed,
        ExecutionEventKind.framesRejected,
        ExecutionEventKind.finished,
        ExecutionEventKind.abandoned,
      },
      ExecutionPhase.finished: {},
      ExecutionPhase.abandoned: {},
    };
    final states = <ExecutionPhase, ExecutionState Function()>{
      ExecutionPhase.notStarted: _notStarted,
      ExecutionPhase.running: _running,
      ExecutionPhase.paused: _paused,
      ExecutionPhase.finished: _finished,
      ExecutionPhase.abandoned: () => ExecutionMachine.apply(
        _paused(),
        ExecutionMachine.next(_paused(), ExecutionEventKind.abandoned, _at(30)),
      ),
    };

    for (final phase in ExecutionPhase.values) {
      for (final kind in ExecutionEventKind.values) {
        final ok = allowed[phase]!.contains(kind);
        test('${phase.name} + ${kind.name}: ${ok ? 'allowed' : 'refused'}', () {
          final s = states[phase]!();
          ExecutionState go() => _step(
            s,
            kind,
            60,
            blockId: 1,
            delta: 1,
            reason: kind == ExecutionEventKind.interrupted
                ? InterruptionReason.clouds
                : null,
          );
          if (ok) {
            expect(go().lastSeq, s.lastSeq + 1);
          } else {
            expect(go, throwsA(isA<ExecutionError>()));
          }
        });
      }
    }
  });

  group('rules', () {
    test('an interruption needs a reason; a pause has none', () {
      expect(
        () => _step(_running(), ExecutionEventKind.interrupted, 5),
        throwsA(isA<ExecutionError>()),
      );
      expect(
        () => _step(
          _running(),
          ExecutionEventKind.paused,
          5,
          reason: InterruptionReason.wind,
        ),
        throwsA(isA<ExecutionError>()),
      );
      final s = _step(
        _running(),
        ExecutionEventKind.interrupted,
        5,
        reason: InterruptionReason.dew,
      );
      expect(s.phase, ExecutionPhase.paused);
      expect(s.lastInterruption, InterruptionReason.dew);
      expect(_step(s, ExecutionEventKind.resumed, 9).lastInterruption, isNull);
    });

    test('an unknown block is refused', () {
      expect(
        () => _step(_notStarted(), ExecutionEventKind.started, 0, blockId: 9),
        throwsA(isA<ExecutionError>()),
      );
      expect(
        () => _step(
          _running(),
          ExecutionEventKind.framesConfirmed,
          1,
          blockId: 9,
          delta: 1,
        ),
        throwsA(isA<ExecutionError>()),
      );
    });

    test('counts never go below zero; a zero change is refused', () {
      var s = _step(
        _running(),
        ExecutionEventKind.framesConfirmed,
        1,
        blockId: 1,
        delta: 2,
      );
      s = _step(
        s,
        ExecutionEventKind.framesConfirmed,
        2,
        blockId: 1,
        delta: -1,
      );
      expect(s.completedFor(1), 1);
      expect(
        () => _step(
          s,
          ExecutionEventKind.framesConfirmed,
          3,
          blockId: 1,
          delta: -2,
        ),
        throwsA(isA<ExecutionError>()),
      );
      expect(
        () => _step(
          s,
          ExecutionEventKind.framesRejected,
          3,
          blockId: 1,
          delta: 0,
        ),
        throwsA(isA<ExecutionError>()),
      );
      s = _step(s, ExecutionEventKind.framesRejected, 4, blockId: 1, delta: 1);
      expect(s.rejectedFor(1), 1);
      expect(s.completedFor(1), 1, reason: 'rejected frames are separate');
    });

    test('events must follow in sequence', () {
      final s = _running();
      expect(
        () => ExecutionMachine.apply(
          s,
          ExecutionEvent(
            seq: s.lastSeq + 2,
            atUtc: _at(5),
            kind: ExecutionEventKind.paused,
          ),
        ),
        throwsA(isA<ExecutionError>()),
      );
    });

    test('fold replays the same state as step by step', () {
      final events = <ExecutionEvent>[];
      var s = _notStarted();
      void add(ExecutionEventKind k, int m, {int? block, int? delta}) {
        final e = ExecutionMachine.next(
          s,
          k,
          _at(m),
          blockId: block,
          delta: delta,
        );
        events.add(e);
        s = ExecutionMachine.apply(s, e);
      }

      add(ExecutionEventKind.started, 0, block: 1);
      add(ExecutionEventKind.framesConfirmed, 5, block: 1, delta: 3);
      add(ExecutionEventKind.paused, 10);
      add(ExecutionEventKind.blockSelected, 12, block: 2);
      add(ExecutionEventKind.resumed, 15);
      add(ExecutionEventKind.framesRejected, 20, block: 2, delta: 1);
      final replayed = ExecutionMachine.fold(_blocks, events);
      expect(replayed.phase, s.phase);
      expect(replayed.blockId, 2);
      expect(replayed.completed, s.completed);
      expect(replayed.rejected, s.rejected);
      expect(
        ExecutionMachine.runningTime(replayed, _at(30)),
        ExecutionMachine.runningTime(s, _at(30)),
      );
    });
  });

  group('running time', () {
    test('counts running intervals only, across a pause', () {
      var s = _running(); // running from 0
      s = _step(s, ExecutionEventKind.paused, 10);
      expect(ExecutionMachine.runningTime(s, _at(50)).inMinutes, 10);
      s = _step(s, ExecutionEventKind.resumed, 40);
      expect(ExecutionMachine.runningTime(s, _at(55)).inMinutes, 25);
    });

    test('starts again at zero on a new block', () {
      var s = _step(
        _running(),
        ExecutionEventKind.blockSelected,
        30,
        blockId: 2,
      );
      expect(ExecutionMachine.runningTime(s, _at(45)).inMinutes, 15);
      s = _step(s, ExecutionEventKind.paused, 50);
      s = _step(s, ExecutionEventKind.blockSelected, 55, blockId: 1);
      expect(ExecutionMachine.runningTime(s, _at(90)), Duration.zero);
    });

    test('a restart after a kill resumes from the stored events', () {
      // The app died at minute 20 while running; it restarts at minute 80.
      final stored = <ExecutionEvent>[];
      var s = _notStarted();
      final start = ExecutionMachine.next(
        s,
        ExecutionEventKind.started,
        _at(0),
        blockId: 1,
      );
      stored.add(start);
      s = ExecutionMachine.apply(s, start);
      final restored = ExecutionMachine.fold(_blocks, stored);
      expect(restored.phase, ExecutionPhase.running);
      expect(ExecutionMachine.runningTime(restored, _at(80)).inMinutes, 80);
    });
  });

  group('clock changes', () {
    test('a clock behind the last event stamps the event at it, flagged', () {
      final s = _step(_running(), ExecutionEventKind.paused, 30);
      final e = ExecutionMachine.next(s, ExecutionEventKind.resumed, _at(10));
      expect(e.atUtc, _at(30));
      expect(e.clockAdjusted, isTrue);
      final after = ExecutionMachine.apply(s, e);
      expect(after.clockAdjusted, isTrue);
      expect(ExecutionMachine.clockBehind(after, _at(10)), isTrue);
    });

    test('a clock behind the running start counts that interval as zero', () {
      final s = _running(); // running since 0
      expect(ExecutionMachine.runningTime(s, _at(-60)), Duration.zero);
    });

    test('a clock far ahead is capped by the frames left', () {
      final e = ExecutionMachine.estimate(
        _running(),
        _at(60 * 24 * 7), // a week later
        exposureSeconds: 60,
        perFrameOverheadSeconds: 5,
        plannedFrames: 40,
      );
      expect(e.frames, 40);
      expect(e.planReached, isTrue);
    });

    test('a non-UTC instant is refused', () {
      expect(
        () => ExecutionMachine.next(
          _running(),
          ExecutionEventKind.paused,
          DateTime(2026, 12, 15, 20),
        ),
        throwsArgumentError,
      );
    });
  });

  group('estimate (ADR-016 §3)', () {
    test('floor(running time / (exposure + overhead))', () {
      // 30 min running, 60 s + 5 s cycles: 1800 / 65 = 27.7 -> 27.
      final e = ExecutionMachine.estimate(
        _running(),
        _at(30),
        exposureSeconds: 60,
        perFrameOverheadSeconds: 5,
        plannedFrames: 100,
      );
      expect(e.frames, 27);
      expect(e.planReached, isFalse);
    });

    test('frames already reported in this block are not counted again', () {
      final s = _step(
        _running(),
        ExecutionEventKind.framesConfirmed,
        20,
        blockId: 1,
        delta: 20,
      );
      final e = ExecutionMachine.estimate(
        s,
        _at(30),
        exposureSeconds: 60,
        perFrameOverheadSeconds: 5,
        plannedFrames: 100,
      );
      expect(e.frames, 7);
    });

    test('a paused run does not grow', () {
      final s = _paused(); // ran 10 min
      final a = ExecutionMachine.estimate(
        s,
        _at(20),
        exposureSeconds: 60,
        perFrameOverheadSeconds: 0,
        plannedFrames: 100,
      );
      final b = ExecutionMachine.estimate(
        s,
        _at(200),
        exposureSeconds: 60,
        perFrameOverheadSeconds: 0,
        plannedFrames: 100,
      );
      expect(a.frames, 10);
      expect(b.frames, 10);
    });

    test('a non-positive cycle is refused', () {
      expect(
        () => ExecutionMachine.estimate(
          _running(),
          _at(5),
          exposureSeconds: 0,
          perFrameOverheadSeconds: 0,
          plannedFrames: 10,
        ),
        throwsArgumentError,
      );
    });
  });

  test('stale: only after the night ends, never without a night', () {
    expect(ExecutionMachine.isStale(_at(60), _at(61)), isTrue);
    expect(ExecutionMachine.isStale(_at(60), _at(59)), isFalse);
    expect(ExecutionMachine.isStale(null, _at(59)), isFalse);
  });
}
