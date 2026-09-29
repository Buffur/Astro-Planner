import 'calendar_date.dart';
import 'capture_block.dart';
import 'session_log.dart';
import 'session_result.dart';
import 'session_snapshot.dart';
import 'tracking_type.dart';

/// Where a session is in its life (ADR-014 §3).
enum SessionStatus {
  draft,
  planned,
  inProgress,
  completed,
  abandoned;

  /// Draft, planned or in progress: the planner may still work on it.
  bool get isOpen => this == draft || this == planned || this == inProgress;

  static SessionStatus parse(String stored) => SessionStatus.values.firstWhere(
    (s) => s.name == stored,
    orElse: () => throw ArgumentError.value(stored, 'status'),
  );
}

/// The allowed status changes (ADR-014 §3). Pure; the repository enforces
/// them.
abstract final class SessionLifecycle {
  static bool canTransition(SessionStatus from, SessionStatus to) => switch ((
    from,
    to,
  )) {
    (SessionStatus.draft, SessionStatus.planned) => true,
    (SessionStatus.planned, SessionStatus.planned) => true,
    (SessionStatus.planned, SessionStatus.draft) => true,
    (SessionStatus.draft || SessionStatus.planned, SessionStatus.inProgress) =>
      true,
    (SessionStatus.inProgress, SessionStatus.completed) => true,
    (
      SessionStatus.draft || SessionStatus.planned || SessionStatus.inProgress,
      SessionStatus.abandoned,
    ) =>
      true,
    _ => false,
  };
}

/// Thrown when a write would break ADR-014's lifecycle: a forbidden status
/// change, or an edit of a frozen (completed, abandoned, in-progress plan or
/// legacy) session.
class SessionStateError extends StateError {
  SessionStateError(super.message);
}

/// Discard on a Saved · changed plan was refused (S4-DEF-04 = R; S6.3): its
/// saved snapshot cannot be read, or names a site, target or rig that no
/// longer exists. Nothing was changed; the user can Save or Cancel instead.
class SavedPlanUnavailable extends SessionStateError {
  SavedPlanUnavailable(super.message);
}

/// The plan the planner edits (ADR-014 §2): references, night key, blocks,
/// and the display labels written to the pre-v16 text columns (never used
/// to resolve references; ADR-014 §10).
class SessionPlan {
  const SessionPlan({
    required this.eveningDate,
    required this.timeZoneId,
    required this.siteId,
    required this.targetId,
    required this.rigId,
    required this.blocks,
    required this.targetLabel,
    required this.rigLabel,
    this.siteLabel,
    this.trackingOverride,
  });

  final CalendarDate eveningDate;

  /// The zone the evening date was resolved in (null = mean solar time).
  final String? timeZoneId;
  final int? siteId;
  final int? targetId;
  final int? rigId;
  final List<CaptureBlock> blocks;
  final String targetLabel;
  final String rigLabel;
  final String? siteLabel;

  /// The plan's tracking override (RD-08 = T3; S7.1): one of
  /// [TrackingType.overrides], or null for the rig's default.
  final TrackingType? trackingOverride;

  /// Light frames in the plan (the pre-v16 `planned_light_frames` label).
  int get lightFrameCount => blocks
      .where((b) => b.frameType == FrameType.light)
      .fold(0, (s, b) => s + b.frameCount);
}

/// Results and notes — the part of a completed session that stays editable
/// (ADR-014 §3).
class SessionResults {
  const SessionResults({
    this.actualLightFrames,
    this.rejectedFrames,
    this.environmentalNotes,
    this.processingNotes,
    this.temperatureC,
    this.humidityPct,
    this.cloudCoverPct,
  });

  final int? actualLightFrames;
  final int? rejectedFrames;
  final String? environmentalNotes;
  final String? processingNotes;

  /// Optional conditions as observed (TASK 13.4); null = not entered,
  /// never 0 (SI-008).
  final double? temperatureC;
  final double? humidityPct;
  final int? cloudCoverPct;
}

/// One imaging session — plan, execution and log (ADR-014): the aggregate
/// root read by `SessionRepository`.
class Session {
  const Session({
    required this.record,
    required this.status,
    required this.legacy,
    this.eveningDate,
    this.timeZoneId,
    this.siteId,
    this.targetId,
    this.rigId,
    this.trackingOverride,
    this.createdAtUtc,
    this.updatedAtUtc,
    this.plannedAtUtc,
    this.startedAtUtc,
    this.completedAtUtc,
    this.planSnapshot,
    this.executionStartSnapshot,
    this.hasUnreadableSnapshot = false,
    this.resultKind,
    this.notDoneReason,
  });

  /// The row's labels, counts, results, notes and blocks, in the shape the
  /// logbook has always shared (`toShareableText`). For legacy sessions this
  /// is everything that is known.
  final SessionLog record;

  final SessionStatus status;

  /// Saved before v16, or without a night key (ADR-014 §7; TD-052):
  /// read-only, shown from [record].
  final bool legacy;

  final CalendarDate? eveningDate;
  final String? timeZoneId;
  final int? siteId;
  final int? targetId;
  final int? rigId;

  /// The plan's tracking override (S7.1); null = the rig's default.
  final TrackingType? trackingOverride;
  final DateTime? createdAtUtc;
  final DateTime? updatedAtUtc;
  final DateTime? plannedAtUtc;
  final DateTime? startedAtUtc;
  final DateTime? completedAtUtc;

  /// Null when none was taken — or when the stored one is unreadable or of
  /// an unknown version ([hasUnreadableSnapshot]); never guessed.
  final SessionSnapshot? planSnapshot;
  final SessionSnapshot? executionStartSnapshot;
  final bool hasUnreadableSnapshot;

  /// How a completed session's counts were reported (S8.1); null for one
  /// completed live or before S8.1, and for every other status.
  final ResultKind? resultKind;

  /// Why an abandoned (Not done) session was not done, when the user said.
  final NotDoneReason? notDoneReason;

  int get id => record.id;

  /// A saved plan: Saved (`planned`) or Saved · changed (a draft saved
  /// before, ADR-019 §3.1).
  bool get isSavedPlan =>
      !legacy &&
      (status == SessionStatus.planned ||
          (status == SessionStatus.draft && plannedAtUtc != null));

  /// Saved · changed: a saved plan edited since it was saved.
  bool get isSavedChanged =>
      !legacy && status == SessionStatus.draft && plannedAtUtc != null;
  List<CaptureBlock> get blocks => record.captureBlocks;

  /// Whether the plan (blocks, references, night) may still change.
  bool get planEditable =>
      !legacy &&
      (status == SessionStatus.draft || status == SessionStatus.planned);
}
