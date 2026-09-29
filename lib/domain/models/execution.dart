/// What happened during a session's run (ADR-016 §4). Stored append-only
/// in `session_events`; the names are stored, so never rename a value.
enum ExecutionEventKind {
  started,
  blockSelected,
  paused,

  /// A pause with a reason (ADR-016 §4).
  interrupted,
  resumed,
  framesConfirmed,
  framesRejected,
  finished,
  abandoned,

  /// A result recorded after the night without a run (S8.1; ADR-019 §4,
  /// I-1): it ends a run that never started, and the reported counts
  /// follow as `framesConfirmed` events.
  reported;

  static ExecutionEventKind? tryParse(String? stored) {
    for (final k in values) {
      if (k.name == stored) return k;
    }
    return null;
  }
}

/// Why a run was interrupted (ADR-016 §4). Stored by name.
enum InterruptionReason {
  clouds,
  wind,
  dew,
  equipment,
  other;

  static InterruptionReason? tryParse(String? stored) {
    for (final r in values) {
      if (r.name == stored) return r;
    }
    return null;
  }
}

/// One stored event. [seq] orders events — never [atUtc], which follows
/// the phone's clock (ADR-016 §5).
class ExecutionEvent {
  const ExecutionEvent({
    required this.seq,
    required this.atUtc,
    required this.kind,
    this.blockId,
    this.delta,
    this.reason,
    this.clockAdjusted = false,
  });

  final int seq;
  final DateTime atUtc;
  final ExecutionEventKind kind;

  /// The block for started, blockSelected, framesConfirmed, framesRejected.
  final int? blockId;

  /// The change for framesConfirmed / framesRejected (+1, −1, or an accepted
  /// estimate).
  final int? delta;

  /// For interrupted only.
  final InterruptionReason? reason;

  /// The phone's clock was behind the previous event, so [atUtc] was set to
  /// the previous event's instant (ADR-016 §5).
  final bool clockAdjusted;
}

/// Where a run is (ADR-016 §2): not started, running on a block, paused,
/// or ended (finished or abandoned).
enum ExecutionPhase { notStarted, running, paused, finished, abandoned }

/// Thrown when an event is not allowed in the current state (ADR-016 §2).
class ExecutionError extends StateError {
  ExecutionError(super.message);
}

/// A run's state: a pure fold over its events (ADR-016 §4). Built only by
/// `ExecutionMachine`.
class ExecutionState {
  const ExecutionState({
    required this.blockIds,
    this.phase = ExecutionPhase.notStarted,
    this.blockId,
    this.completed = const {},
    this.rejected = const {},
    this.runningSinceUtc,
    this.runningMsBefore = 0,
    this.reportedInBlock = 0,
    this.lastSeq = 0,
    this.lastEventUtc,
    this.clockAdjusted = false,
    this.lastInterruption,
  });

  /// The session's block ids; events may only name these.
  final Set<int> blockIds;
  final ExecutionPhase phase;

  /// The current block (null before the start).
  final int? blockId;

  /// Confirmed and rejected frames per block id (absent = 0).
  final Map<int, int> completed;
  final Map<int, int> rejected;

  /// While running: when the current running interval began.
  final DateTime? runningSinceUtc;

  /// Running time in the current block before [runningSinceUtc], ms.
  final int runningMsBefore;

  /// Frames confirmed or rejected (net) since the current block was
  /// selected: the estimate counts only frames not reported yet.
  final int reportedInBlock;

  final int lastSeq;
  final DateTime? lastEventUtc;

  /// Any event so far was clock-adjusted (ADR-016 §5).
  final bool clockAdjusted;

  /// The reason of the pause in force, if it was an interruption.
  final InterruptionReason? lastInterruption;

  bool get isActive =>
      phase == ExecutionPhase.running || phase == ExecutionPhase.paused;

  int completedFor(int blockId) => completed[blockId] ?? 0;
  int rejectedFor(int blockId) => rejected[blockId] ?? 0;

  ExecutionState copyWith({
    ExecutionPhase? phase,
    int? blockId,
    Map<int, int>? completed,
    Map<int, int>? rejected,
    DateTime? Function()? runningSinceUtc,
    int? runningMsBefore,
    int? reportedInBlock,
    int? lastSeq,
    DateTime? lastEventUtc,
    bool? clockAdjusted,
    InterruptionReason? Function()? lastInterruption,
  }) => ExecutionState(
    blockIds: blockIds,
    phase: phase ?? this.phase,
    blockId: blockId ?? this.blockId,
    completed: completed ?? this.completed,
    rejected: rejected ?? this.rejected,
    runningSinceUtc: runningSinceUtc == null
        ? this.runningSinceUtc
        : runningSinceUtc(),
    runningMsBefore: runningMsBefore ?? this.runningMsBefore,
    reportedInBlock: reportedInBlock ?? this.reportedInBlock,
    lastSeq: lastSeq ?? this.lastSeq,
    lastEventUtc: lastEventUtc ?? this.lastEventUtc,
    clockAdjusted: clockAdjusted ?? this.clockAdjusted,
    lastInterruption: lastInterruption == null
        ? this.lastInterruption
        : lastInterruption(),
  );
}
