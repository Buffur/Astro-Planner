import 'package:flutter/foundation.dart';

import '../../core/time/clock.dart';
import '../../domain/models/capture_block.dart';
import '../../domain/models/execution.dart';
import '../../domain/models/session.dart';
import '../../domain/repositories/session_repository.dart';
import '../../domain/services/execution_machine.dart';

/// A run found in progress when the app starts (ADR-016 §5).
class ResumeOffer {
  const ResumeOffer({
    required this.session,
    required this.state,
    required this.block,
    required this.runningTime,
    required this.estimate,
    required this.stale,
    required this.clockBehind,
  });

  final Session session;
  final ExecutionState state;

  /// The current block, or null if it cannot be read.
  final CaptureBlock? block;
  final Duration runningTime;

  /// Null when the block or its overhead is unknown (never guessed).
  final FrameEstimate? estimate;

  /// The night in the execution-start snapshot is over.
  final bool stale;

  /// The phone's clock is behind the last stored event.
  final bool clockBehind;
}

/// Offers to resume, pause, finish or abandon a run that was in progress
/// when the app last stopped (ADR-016 §5; TASK 13.2). Nothing is completed
/// or estimated into the counts without the user (owner decision).
class ResumeRunViewModel extends ChangeNotifier {
  ResumeRunViewModel(this._sessions, this._clock);

  final SessionRepository _sessions;
  final Clock _clock;

  ResumeOffer? _offer;
  bool _shown = false;

  /// The run to ask about, until the user answers.
  ResumeOffer? get offer => _offer;

  /// True once, when the prompt should open; call [markShown] when it does.
  bool get promptDue => _offer != null && !_shown;
  void markShown() => _shown = true;

  /// Looks for a session in progress; a failed read offers nothing.
  Future<void> load() async {
    try {
      final session = await _sessions.inProgress();
      if (session != null) _offer = await _offerFor(session);
    } catch (e) {
      debugPrint('Could not read the run in progress: $e');
      _offer = null;
    }
    notifyListeners();
  }

  Future<ResumeOffer> _offerFor(Session session) async {
    final state = await _sessions.execution(session.id);
    final now = _clock.nowUtc();
    final snapshot = session.executionStartSnapshot;
    CaptureBlock? block;
    for (final b in session.blocks) {
      if (b.id == state.blockId) block = b;
    }
    final overhead = snapshot?.perFrameOverheadSeconds;
    return ResumeOffer(
      session: session,
      state: state,
      block: block,
      runningTime: ExecutionMachine.runningTime(state, now),
      estimate: block == null || overhead == null
          ? null
          : ExecutionMachine.estimate(
              state,
              now,
              exposureSeconds: block.exposureTimeSeconds,
              perFrameOverheadSeconds: overhead,
              plannedFrames: block.frameCount,
            ),
      stale: ExecutionMachine.isStale(snapshot?.nightEndUtc, now),
      clockBehind: ExecutionMachine.clockBehind(state, now),
    );
  }

  /// Keep the run as it is (the time the app was closed counts).
  void keepGoing() => _answer(null);

  /// Pause now, if running.
  Future<void> pauseNow() => _answer(() async {
    final o = _offer!;
    if (o.state.phase == ExecutionPhase.running) {
      await _sessions.record(o.session.id, ExecutionEventKind.paused);
    }
  });

  /// Finish with the counts confirmed so far (reconciled in TASK 13.4).
  Future<void> finish() =>
      _answer(() => _sessions.complete(_offer!.session.id));

  Future<void> abandon() =>
      _answer(() => _sessions.abandon(_offer!.session.id));

  Future<void> _answer(Future<void> Function()? action) async {
    if (_offer == null) return;
    await action?.call();
    _offer = null;
    notifyListeners();
  }
}
