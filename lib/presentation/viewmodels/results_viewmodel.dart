import 'package:flutter/foundation.dart';

import '../../core/time/clock.dart';
import '../../domain/models/capture_block.dart';
import '../../domain/models/execution.dart';
import '../../domain/models/session.dart';
import '../../domain/models/session_result.dart';
import '../../domain/models/session_snapshot.dart';
import '../../domain/repositories/session_repository.dart';
import '../../domain/services/saved_night_end.dart';
import '../../domain/services/session_reconciliation.dart';

/// "How did it go?" (S8.2; ADR-019 §3.1, §4): the one form for a result.
/// It reviews the saved plan — its snapshot, never the planner's state — and
/// records Completed as planned, Partly or Not done through
/// `SessionRepository.recordResult`. A Saved · changed entry is settled
/// first (its working copy keeps the edits); the form never asks about the
/// planner's plan.
class ResultsViewModel extends ChangeNotifier {
  ResultsViewModel(this._sessions, this._clock, {this._settle});

  final SessionRepository _sessions;
  final Clock _clock;

  /// Settles a Saved · changed entry through the planner's current session
  /// (`PlanLifecycleViewModel.settle`), so the planner moves to the copy
  /// when the entry was its plan. Null in tests without a planner.
  final Future<void> Function(int id)? _settle;

  Session? _session;
  ExecutionState? _state;

  Session? get session => _session;

  /// The saved plan under review: the execution-start snapshot of a run,
  /// else the plan snapshot; null when none can be read (SI-008).
  SessionSnapshot? get review =>
      _session?.executionStartSnapshot ?? _session?.planSnapshot;

  /// Planned vs actual so far (CALC-37); null until loaded.
  SessionReconciliation? get reconciliation {
    final s = _session, state = _state;
    return s == null || state == null
        ? null
        : SessionReconciliation.of(s.blocks, state);
  }

  /// The light blocks a result counts, in plan order.
  List<CaptureBlock> get lightBlocks => [
    for (final b in _session?.blocks ?? const <CaptureBlock>[])
      if (b.frameType == FrameType.light) b,
  ];

  /// Confirmed light frames of [blockId] so far.
  int confirmedFor(int blockId) => _state?.completedFor(blockId) ?? 0;

  /// When the saved night ends (CALC-44); null without a night.
  DateTime? get endsAt => _session == null ? null : SavedNightEnd.of(_session!);

  /// A result may be recorded (or edited) now.
  bool get canRecord {
    final s = _session;
    if (s == null || s.legacy) return false;
    return switch (s.status) {
      SessionStatus.planned => SavedNightEnd.hasEnded(s, _clock.nowUtc()),
      SessionStatus.draft => onlyNotDone,
      SessionStatus.inProgress ||
      SessionStatus.completed ||
      SessionStatus.abandoned => true,
    };
  }

  /// A Saved · changed entry whose saved plan cannot be read (I-4): only
  /// Not done can be recorded, once its night has ended.
  bool get onlyNotDone {
    final s = _session;
    return s != null &&
        s.isSavedChanged &&
        s.planSnapshot == null &&
        SavedNightEnd.hasEnded(s, _clock.nowUtc());
  }

  /// The outcome already stored, for an edit; null for a new result.
  ResultOutcome? get storedOutcome => switch (_session) {
    Session(status: SessionStatus.abandoned) => ResultOutcome.notDone,
    Session(
      status: SessionStatus.completed,
      resultKind: ResultKind.asPlanned,
    ) =>
      ResultOutcome.asPlanned,
    Session(status: SessionStatus.completed) => ResultOutcome.partly,
    // A run finishing from the tracker: its confirmed counts are a start.
    Session(status: SessionStatus.inProgress) => ResultOutcome.partly,
    _ => null,
  };

  /// Loads entry [id]; a Saved · changed one whose night has ended is
  /// settled first, so the form reviews and records the saved plan.
  Future<void> load(int id) async {
    var s = await _sessions.get(id);
    final settle = _settle;
    if (s != null &&
        settle != null &&
        s.isSavedChanged &&
        s.planSnapshot != null &&
        SavedNightEnd.hasEnded(s, _clock.nowUtc())) {
      await settle(id);
      s = await _sessions.get(id);
    }
    _session = s;
    _state = s == null ? null : await _sessions.execution(id);
    notifyListeners();
  }

  /// Records [report] against the entry as loaded (S4-DEF-08): a changed
  /// entry is refused ([StaleResultForm]) and reloaded, then the error
  /// reaches the caller; nothing is written.
  Future<void> save(ResultReport report) async {
    final s = _session;
    if (s == null) return;
    try {
      await _sessions.recordResult(
        s.id,
        report,
        expectedUpdatedAtUtc: s.updatedAtUtc,
      );
    } on StaleResultForm {
      await load(s.id);
      rethrow;
    }
    await load(s.id);
  }
}

/// The three answers to "How did it go?" (ADR-019 §4).
enum ResultOutcome { asPlanned, partly, notDone }
