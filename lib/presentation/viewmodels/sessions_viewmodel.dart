import 'package:flutter/foundation.dart';

import '../../core/diagnostics/app_log.dart';
import '../../core/time/clock.dart';
import '../../domain/models/calendar_date.dart';
import '../../domain/models/session.dart';
import '../../domain/repositories/session_repository.dart';
import '../../domain/services/result_action.dart';
import '../../domain/services/saved_night_end.dart';
import '../../domain/services/session_exporter.dart';
import '../../domain/services/session_reconciliation.dart';
import '../../domain/services/target_progress.dart';

/// The Sessions list's status chips (TASK 14.1). Planned includes a saved
/// plan edited since ("unsaved changes"); legacy logs are completed.
enum SessionListStatus {
  planned({SessionStatus.draft, SessionStatus.planned}),
  inProgress({SessionStatus.inProgress}),
  completed({SessionStatus.completed}),
  abandoned({SessionStatus.abandoned});

  const SessionListStatus(this.stored);
  final Set<SessionStatus> stored;
}

/// The Sessions list's filters; empty means "all" (TASK 14.1).
class SessionFilter {
  const SessionFilter({
    this.statuses = const {},
    this.targetId,
    this.siteId,
    this.from,
    this.to,
  });

  final Set<SessionListStatus> statuses;
  final int? targetId;
  final int? siteId;
  final CalendarDate? from;
  final CalendarDate? to;

  bool get isEmpty =>
      statuses.isEmpty &&
      targetId == null &&
      siteId == null &&
      from == null &&
      to == null;

  /// How many filters are set (S8.5: the Filters button's badge).
  int get count =>
      statuses.length +
      (targetId == null ? 0 : 1) +
      (siteId == null ? 0 : 1) +
      (from == null && to == null ? 0 : 1);
}

/// A session for its detail page: the planned vs actual of its run (null
/// for legacy) and its target's progress so far (TASK 14.2).
typedef SessionDetail = ({
  Session session,
  SessionReconciliation? reconciliation,
  TargetProgress? progress,
});

/// The Sessions tab (TASKs 11.3–11.4; TASK 12.3): the saved sessions the
/// logbook lists — every non-draft session, a draft saved before
/// ("unsaved changes"), and the legacy logs (owner decisions).
class SessionsViewModel extends ChangeNotifier {
  SessionsViewModel(this._repository, {this._exporter, Clock? clock})
    : _clock = clock ?? const SystemClock();

  final SessionRepository _repository;
  final Clock _clock;

  /// What [s] offers for its result now (S8.2): Record result, Edit result
  /// or nothing.
  ResultAction resultAction(Session s) => ResultAction.of(s, _clock.nowUtc());

  /// The Logbook's filters and search (S8.5; UX-30, I-9), held here so they
  /// survive navigation, as the tab's state does. Search and filters
  /// combine.
  SessionFilter get filter => _filter;
  SessionFilter _filter = const SessionFilter();
  String get query => _query;
  String _query = '';

  void setFilter(SessionFilter f) {
    _filter = f;
    notifyListeners();
  }

  void setQuery(String q) {
    if (q == _query) return;
    _query = q;
    notifyListeners();
  }

  /// The entries in [list] whose target, site or notes contain the search
  /// text, ignoring case (S8.5; in memory, no full-text index).
  List<Session> searched(List<Session> list) {
    final q = _query.trim().toLowerCase();
    if (q.isEmpty) return list;
    bool has(String? text) => text != null && text.toLowerCase().contains(q);
    return [
      for (final s in list)
        if (has(s.record.targetName) ||
            has(s.record.locationName) ||
            has(s.record.environmentalNotes) ||
            has(s.record.processingNotes))
          s,
    ];
  }

  /// Upcoming (saved plans whose night has not ended, soonest first) and
  /// Past (the rest, newest night first); S8.5, ADR-019 §2.
  ({List<Session> upcoming, List<Session> past}) grouped(List<Session> list) {
    final now = _clock.nowUtc();
    CalendarDate night(Session s) =>
        s.eveningDate ??
        CalendarDate.fromDateTimeFields(s.record.sessionDate.toLocal());
    final upcoming = [
      for (final s in list)
        if (s.isSavedPlan && !SavedNightEnd.hasEnded(s, now)) s,
    ]..sort((a, b) => night(a).compareTo(night(b)));
    final past = [
      for (final s in list)
        if (!upcoming.contains(s)) s,
    ]..sort((a, b) => night(b).compareTo(night(a)));
    return (upcoming: upcoming, past: past);
  }

  /// Tonight's line (S8.3; ADR-019 §4, I-8): the saved plan (or run in
  /// progress) whose night has ended most recently and still has no result;
  /// null when none is due. Refreshed by [refreshDue].
  Session? get dueResult => _due;
  Session? _due;

  /// Looks again for the entry [dueResult] names; notifies when it changes.
  /// A store that cannot be read leaves the line as it was (logged).
  Future<void> refreshDue() async {
    Session? due;
    try {
      for (final s in await _repository.list(
        statuses: {
          SessionStatus.draft,
          SessionStatus.planned,
          SessionStatus.inProgress,
        },
        includeLegacy: false,
      )) {
        if (resultAction(s) != ResultAction.record) continue;
        if (due == null || s.eveningDate!.compareTo(due.eveningDate!) > 0) {
          due = s;
        }
      }
    } catch (e, st) {
      AppLog.warning(
        'sessions',
        'Result line not refreshed',
        error: e,
        stackTrace: st,
      );
      return;
    }
    if (due?.id == _due?.id && due?.updatedAtUtc == _due?.updatedAtUtc) return;
    _due = due;
    notifyListeners();
  }

  /// Null in tests that do not export.
  final SessionExporter? _exporter;

  bool get canExport => _exporter != null;

  /// Shares session [id] as a manifest v2 file with its events (TASK 14.3).
  Future<void> exportOne(int id) async {
    final s = await _repository.get(id);
    if (s != null) await _exporter?.share([await _exported(s)]);
  }

  /// Shares every saved session, legacy logs included (owner decision).
  Future<void> exportAll() async {
    final all = await saved();
    await _exporter?.share([for (final s in all) await _exported(s)]);
  }

  Future<ExportedSession> _exported(Session s) async =>
      ExportedSession(s, s.legacy ? const [] : await _repository.events(s.id));

  /// The saved sessions matching [filter] (TASK 14.1; the filtering runs in
  /// the repository's query).
  Future<List<Session>> saved([
    SessionFilter filter = const SessionFilter(),
  ]) async => [
    for (final s in await _repository.list(
      statuses: filter.statuses.isEmpty
          ? null
          : {for (final f in filter.statuses) ...f.stored},
      targetId: filter.targetId,
      siteId: filter.siteId,
      from: filter.from,
      to: filter.to,
    ))
      if (s.legacy || s.status != SessionStatus.draft || s.plannedAtUtc != null)
        s,
  ];

  /// The targets and sites the saved sessions refer to, for the filter
  /// pickers: id → the label stored with the session.
  Future<({Map<int, String> targets, Map<int, String> sites})>
  filterOptions() async {
    final targets = <int, String>{}, sites = <int, String>{};
    for (final s in await saved()) {
      if (s.targetId case final id?) targets[id] ??= s.record.targetName;
      if (s.siteId case final id?) {
        sites[id] ??= s.record.locationName ?? 'Site $id';
      }
    }
    return (targets: targets, sites: sites);
  }

  Future<Session?> get(int id) => _repository.get(id);

  /// A session with its planned vs actual (CALC-37) for the detail page;
  /// legacy rows have no run, so no reconciliation.
  Future<SessionDetail?> detail(int id) async {
    final s = await _repository.get(id);
    if (s == null) return null;
    final targetId = s.targetId;
    return (
      session: s,
      reconciliation: s.legacy
          ? null
          : SessionReconciliation.of(s.blocks, await _repository.execution(id)),
      // TASK 14.2: this target's progress across nights.
      progress: targetId == null
          ? null
          : (await targetProgress())
                .where((p) => p.targetId == targetId)
                .firstOrNull,
    );
  }

  /// Planned vs actual (CALC-37) for each completed, non-legacy session in
  /// [sessions], by id (TASK 13.4, owner: shown in the Sessions list).
  Future<Map<int, SessionReconciliation>> reconciliations(
    List<Session> sessions,
  ) async => {
    for (final s in sessions)
      if (!s.legacy && s.status == SessionStatus.completed)
        s.id: SessionReconciliation.of(
          s.blocks,
          await _repository.execution(s.id),
        ),
  };

  /// Accumulated progress per target (TASK 14.2, CALC-38), newest first.
  Future<List<TargetProgress>> targetProgress() async {
    final completed = await _repository.list(
      statuses: {SessionStatus.completed},
      includeLegacy: false,
    );
    final runs = [
      for (final s in completed)
        if (s.targetId != null) (s, await _repository.execution(s.id)),
    ];
    final list = TargetProgress.of(runs).values.toList()
      ..sort((a, b) {
        final x = a.lastNight, y = b.lastNight;
        if (x == null && y == null) return 0;
        if (x == null || y == null) return x == null ? 1 : -1;
        return y.compareTo(x);
      });
    return list;
  }

  Future<void> delete(int id) async {
    await _repository.delete(id);
    notifyListeners();
    await refreshDue();
  }
}
