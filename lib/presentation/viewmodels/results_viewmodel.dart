import 'package:flutter/foundation.dart';

import '../../domain/models/execution.dart';
import '../../domain/models/session.dart';
import '../../domain/repositories/session_repository.dart';
import '../../domain/services/session_reconciliation.dart';

/// The results page (TASK 13.4): reconcile a run into a log entry — the
/// counts per block, rejected frames, notes and optional conditions, and
/// planned vs actual. Owner decisions: Finish opens this page and nothing
/// is completed until Complete; after completion the counts may still be
/// corrected, each correction a timestamped event.
class ResultsViewModel extends ChangeNotifier {
  ResultsViewModel(this._sessions);

  final SessionRepository _sessions;

  Session? _session;
  ExecutionState? _state;

  Session? get session => _session;

  /// Planned vs actual (CALC-37); null until loaded.
  SessionReconciliation? get reconciliation {
    final s = _session, state = _state;
    return s == null || state == null
        ? null
        : SessionReconciliation.of(s.blocks, state);
  }

  /// Still in progress: Complete (or Abandon) ends it.
  bool get inProgress => _session?.status == SessionStatus.inProgress;

  /// Counts may be changed: during the run, or as corrections afterwards.
  bool get countsEditable =>
      _session != null &&
      !_session!.legacy &&
      (inProgress || _session!.status == SessionStatus.completed);

  Future<void> load(int id) async {
    _session = await _sessions.get(id);
    _state = _session == null ? null : await _sessions.execution(id);
    notifyListeners();
  }

  /// Changes block [blockId]'s confirmed (or, with [rejected], rejected)
  /// count by [delta] — one stored event.
  Future<void> adjust(int blockId, int delta, {bool rejected = false}) async {
    final s = _session;
    if (s == null || delta == 0) return;
    _state = await _sessions.record(
      s.id,
      rejected
          ? ExecutionEventKind.framesRejected
          : ExecutionEventKind.framesConfirmed,
      blockId: blockId,
      delta: delta,
    );
    _session = await _sessions.get(s.id);
    notifyListeners();
  }

  /// Saves notes and conditions with the totals from the counts; while in
  /// progress, also completes the session.
  Future<void> save({
    String? environmentalNotes,
    String? processingNotes,
    double? temperatureC,
    double? humidityPct,
    int? cloudCoverPct,
  }) async {
    final s = _session, r = reconciliation;
    if (s == null || r == null) return;
    await _sessions.updateResults(
      s.id,
      SessionResults(
        actualLightFrames: r.actualLightFrames,
        rejectedFrames: r.rejectedLightFrames,
        environmentalNotes: environmentalNotes,
        processingNotes: processingNotes,
        temperatureC: temperatureC,
        humidityPct: humidityPct,
        cloudCoverPct: cloudCoverPct,
      ),
    );
    if (inProgress) await _sessions.complete(s.id);
    await load(s.id);
  }

  Future<void> abandon() async {
    final s = _session;
    if (s == null || !inProgress) return;
    await _sessions.abandon(s.id);
    await load(s.id);
  }
}
