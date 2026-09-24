import 'package:flutter/foundation.dart';

import '../../domain/models/astro_target.dart';
import '../../domain/models/calendar_date.dart';
import '../../domain/models/equipment_profile.dart';
import '../../domain/models/session.dart';
import '../../domain/repositories/equipment_repository.dart';
import '../../domain/repositories/session_repository.dart';
import '../../domain/repositories/target_repository.dart';
import '../../domain/services/session_reconciliation.dart';
import '../../domain/services/target_progress.dart';

/// The Library's rigs (TASK 12.3): screens read and change equipment
/// through this, never through the repository.
class GearViewModel extends ChangeNotifier {
  GearViewModel(this._repository);

  final EquipmentRepository _repository;

  Future<List<EquipmentProfile>> all() => _repository.getAllEquipment();

  Future<int> add(EquipmentProfile rig) async {
    final id = await _repository.insertEquipment(rig);
    notifyListeners();
    return id;
  }

  Future<void> update(EquipmentProfile rig) async {
    await _repository.updateEquipment(rig);
    notifyListeners();
  }

  Future<void> delete(int id) async {
    await _repository.deleteEquipment(id);
    notifyListeners();
  }
}

/// The Library's targets (TASK 12.3).
class TargetsViewModel extends ChangeNotifier {
  TargetsViewModel(this._repository);

  final TargetRepository _repository;

  /// Catalog and user targets matching [query] (all when empty).
  Future<List<AstroTarget>> search(String query) =>
      _repository.searchTargets(query);

  Future<int> add(AstroTarget target) async {
    final id = await _repository.insertTarget(target);
    notifyListeners();
    return id;
  }

  Future<void> update(AstroTarget target) async {
    await _repository.updateTarget(target);
    notifyListeners();
  }

  Future<void> delete(int id) async {
    await _repository.deleteTarget(id);
    notifyListeners();
  }
}

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
  SessionsViewModel(this._repository);

  final SessionRepository _repository;

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
  }
}
