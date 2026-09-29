// The execution state machine (TASK 13.2, ADR-016): the transition table, a
// replay equal to step-by-step application, and a clock set back. Pure:
// "now" is always passed in. S8.4 retired the live tracker's running time,
// estimate and staleness (CALC-35) and their tests; S8.1 added `reported`.

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
  group('a result without a run (S8.1)', () {
    test('reported ends a run that never started; the counts follow as '
        'corrections, and nothing else is accepted', () {
      var s = _step(_notStarted(), ExecutionEventKind.reported, 600);
      expect(s.phase, ExecutionPhase.finished);
      expect(s.blockId, isNull);
      s = _step(
        s,
        ExecutionEventKind.framesConfirmed,
        601,
        blockId: 2,
        delta: 20,
      );
      expect(s.completedFor(2), 20);
      for (final kind in [
        ExecutionEventKind.started,
        ExecutionEventKind.reported,
        ExecutionEventKind.resumed,
        ExecutionEventKind.finished,
      ]) {
        expect(
          () => _step(s, kind, 602, blockId: 1),
          throwsA(isA<ExecutionError>()),
        );
      }
    });

    test('reported after a start is refused', () {
      expect(
        () => _step(_running(), ExecutionEventKind.reported, 5),
        throwsA(isA<ExecutionError>()),
      );
    });
  });

  group('transition table', () {
    // What each phase allows; every other (phase, kind) pair is refused.
    final allowed = <ExecutionPhase, Set<ExecutionEventKind>>{
      // S8.1: a result without a run ends a run that never started.
      ExecutionPhase.notStarted: {
        ExecutionEventKind.started,
        ExecutionEventKind.reported,
      },
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
      // TASK 13.4 (owner): count corrections after finishing.
      ExecutionPhase.finished: {
        ExecutionEventKind.framesConfirmed,
        ExecutionEventKind.framesRejected,
      },
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
      expect(replayed.runningMsBefore, s.runningMsBefore);
      expect(replayed.runningSinceUtc, s.runningSinceUtc);
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
}
