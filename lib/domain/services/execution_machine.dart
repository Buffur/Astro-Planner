import '../models/execution.dart';

/// The execution state machine (ADR-016; TASK 13.2). Pure: transitions are
/// functions of a state and an event, and a run's state is the fold of its
/// stored events. No clock is read here — "now" is always passed in.
abstract final class ExecutionMachine {
  /// The state after [events] (ordered by `seq`) for a session whose blocks
  /// are [blockIds]. Throws [ExecutionError] if the stored events are not a
  /// valid run.
  static ExecutionState fold(
    Set<int> blockIds,
    Iterable<ExecutionEvent> events,
  ) {
    var state = ExecutionState(blockIds: Set.unmodifiable(blockIds));
    for (final e in events) {
      state = apply(state, e);
    }
    return state;
  }

  /// The next event to store for [kind] at the phone's [nowUtc]: numbered
  /// after the last one, and never earlier than it — a clock that went back
  /// is recorded as `clockAdjusted` (ADR-016 §5). Validates it with [apply].
  static ExecutionEvent next(
    ExecutionState state,
    ExecutionEventKind kind,
    DateTime nowUtc, {
    int? blockId,
    int? delta,
    InterruptionReason? reason,
  }) {
    if (!nowUtc.isUtc) throw ArgumentError.value(nowUtc, 'nowUtc', 'not UTC');
    final last = state.lastEventUtc;
    final behind = last != null && nowUtc.isBefore(last);
    final event = ExecutionEvent(
      seq: state.lastSeq + 1,
      atUtc: behind ? last : nowUtc,
      kind: kind,
      blockId: blockId,
      delta: delta,
      reason: reason,
      clockAdjusted: behind,
    );
    apply(state, event); // throws if not allowed
    return event;
  }

  /// [state] after [e]; throws [ExecutionError] when [e] is not allowed.
  static ExecutionState apply(ExecutionState state, ExecutionEvent e) {
    if (e.seq != state.lastSeq + 1) {
      throw ExecutionError(
        'Event ${e.seq} out of order after ${state.lastSeq}.',
      );
    }
    final phase = state.phase;
    void require(bool ok, String why) {
      if (!ok) throw ExecutionError('${e.kind.name} not allowed: $why.');
    }

    int block() {
      final id = e.blockId;
      require(id != null && state.blockIds.contains(id), 'unknown block');
      return id!;
    }

    // Running time of the interval that ends at this event.
    int closedMs() {
      final since = state.runningSinceUtc;
      if (phase != ExecutionPhase.running || since == null) return 0;
      final ms = e.atUtc.difference(since).inMilliseconds;
      return ms < 0 ? 0 : ms;
    }

    final base = state.copyWith(
      lastSeq: e.seq,
      lastEventUtc: e.atUtc,
      clockAdjusted: state.clockAdjusted || e.clockAdjusted,
    );

    switch (e.kind) {
      case ExecutionEventKind.started:
        require(phase == ExecutionPhase.notStarted, 'already started');
        return base.copyWith(
          phase: ExecutionPhase.running,
          blockId: block(),
          runningSinceUtc: () => e.atUtc,
          runningMsBefore: 0,
          reportedInBlock: 0,
        );
      case ExecutionEventKind.blockSelected:
        require(state.isActive, 'not running or paused');
        return base.copyWith(
          blockId: block(),
          runningSinceUtc: () =>
              phase == ExecutionPhase.running ? e.atUtc : null,
          runningMsBefore: 0,
          reportedInBlock: 0,
        );
      case ExecutionEventKind.paused:
      case ExecutionEventKind.interrupted:
        require(phase == ExecutionPhase.running, 'not running');
        final reason = e.reason;
        require(
          (e.kind == ExecutionEventKind.interrupted) == (reason != null),
          'an interruption needs a reason, a pause has none',
        );
        return base.copyWith(
          phase: ExecutionPhase.paused,
          runningSinceUtc: () => null,
          runningMsBefore: state.runningMsBefore + closedMs(),
          lastInterruption: () => reason,
        );
      case ExecutionEventKind.resumed:
        require(phase == ExecutionPhase.paused, 'not paused');
        return base.copyWith(
          phase: ExecutionPhase.running,
          runningSinceUtc: () => e.atUtc,
          lastInterruption: () => null,
        );
      case ExecutionEventKind.framesConfirmed:
      case ExecutionEventKind.framesRejected:
        // After finishing, count corrections are the only events allowed
        // (owner decision, TASK 13.4; ADR-016 §11).
        require(
          state.isActive || phase == ExecutionPhase.finished,
          'not running, paused or finished',
        );
        final id = block();
        final delta = e.delta;
        require(delta != null && delta != 0, 'no change');
        final confirmed = e.kind == ExecutionEventKind.framesConfirmed;
        final counts = confirmed ? state.completed : state.rejected;
        final next = (counts[id] ?? 0) + delta!;
        require(next >= 0, 'a count cannot go below zero');
        final updated = Map<int, int>.unmodifiable({...counts, id: next});
        return base.copyWith(
          completed: confirmed ? updated : null,
          rejected: confirmed ? null : updated,
          reportedInBlock: id == state.blockId
              ? state.reportedInBlock + delta
              : null,
        );
      case ExecutionEventKind.finished:
      case ExecutionEventKind.abandoned:
        require(state.isActive, 'not running or paused');
        return base.copyWith(
          phase: e.kind == ExecutionEventKind.finished
              ? ExecutionPhase.finished
              : ExecutionPhase.abandoned,
          runningSinceUtc: () => null,
          runningMsBefore: state.runningMsBefore + closedMs(),
        );
      case ExecutionEventKind.reported:
        // A result without a run (S8.1): the counts follow as corrections.
        require(phase == ExecutionPhase.notStarted, 'already started');
        return base.copyWith(phase: ExecutionPhase.finished);
    }
  }

  /// Running time in the current block at [nowUtc] (ADR-016 §3). A clock
  /// behind the running interval's start counts that interval as zero.
  static Duration runningTime(ExecutionState state, DateTime nowUtc) {
    var ms = state.runningMsBefore;
    final since = state.runningSinceUtc;
    if (state.phase == ExecutionPhase.running && since != null) {
      final open = nowUtc.difference(since).inMilliseconds;
      if (open > 0) ms += open;
    }
    return Duration(milliseconds: ms);
  }

  /// True when the phone's clock is behind the last stored event.
  static bool clockBehind(ExecutionState state, DateTime nowUtc) {
    final last = state.lastEventUtc;
    return last != null && nowUtc.isBefore(last);
  }

  /// Frames probably captured in the current block and not reported yet
  /// (ADR-016 §3): ⌊running time ÷ (exposure + per-frame overhead)⌋ minus
  /// the frames already confirmed or rejected since the block was selected,
  /// capped at [plannedFrames] minus the block's confirmed frames. Dither,
  /// refocus and meridian-flip time are not subtracted, so this is an upper
  /// bound, not a count.
  static FrameEstimate estimate(
    ExecutionState state,
    DateTime nowUtc, {
    required double exposureSeconds,
    required double perFrameOverheadSeconds,
    required int plannedFrames,
  }) {
    final block = state.blockId;
    if (block == null) {
      return const FrameEstimate(frames: 0, planReached: false);
    }
    final cycleMs = ((exposureSeconds + perFrameOverheadSeconds) * 1000)
        .round();
    if (cycleMs <= 0) {
      throw ArgumentError('exposure + overhead must be positive');
    }
    final captured = runningTime(state, nowUtc).inMilliseconds ~/ cycleMs;
    final unreported = captured - state.reportedInBlock;
    final left = plannedFrames - state.completedFor(block);
    final frames = unreported <= 0 ? 0 : unreported;
    final cap = left <= 0 ? 0 : left;
    return FrameEstimate(
      frames: frames > cap ? cap : frames,
      planReached: frames >= cap,
    );
  }

  /// A run is stale when "now" is past the end of its night (ADR-016 §5):
  /// the app asks, and never finishes it on its own.
  static bool isStale(DateTime? nightEndUtc, DateTime nowUtc) =>
      nightEndUtc != null && nowUtc.isAfter(nightEndUtc);
}
