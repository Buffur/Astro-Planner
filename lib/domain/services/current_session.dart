import '../../core/diagnostics/app_log.dart';
import '../models/session.dart';
import '../models/session_snapshot.dart';
import '../repositories/session_repository.dart';

/// The session the planner works on and its autosave (ADR-014 §3; TASK
/// 11.4; moved out of the planner ViewModel in TASK 12.3). Writes are
/// serialized so they reach the database in edit order; a frozen session
/// (completed, abandoned, in progress, legacy) is never written — the plan
/// then goes into a new draft.
class CurrentSession {
  CurrentSession(this._repository);

  final SessionRepository _repository;
  Session? _session;
  Future<void> _chain = Future.value();
  Object? _writeFailure;

  Session? get session => _session;

  /// Called when [writeFailure] changes.
  void Function()? onWriteFailureChanged;

  /// Why the last autosave failed, until one succeeds (TASK 15.1). A failed
  /// write never blocks the later ones; each writes the whole plan, so the
  /// next edit retries it.
  Object? get writeFailure => _writeFailure;

  /// Completes when every write started so far has finished.
  Future<void> get idle => _chain;

  /// The most recent open session, or null when there is none.
  Future<Session?> resume() async =>
      _session = await _repository.mostRecentOpen();

  /// Makes a new draft for [plan] the current session.
  Future<Session> startNew(SessionPlan plan) async {
    await _chain;
    return _session = await _repository.create(plan);
  }

  /// Opens [session]: a draft or planned one becomes current; a frozen one
  /// is copied — as [copy] — into a new draft (owner decision, TASK 11.4).
  Future<void> adopt(Session session, SessionPlan Function() copy) async {
    _session = session.planEditable ? session : await startNew(copy());
  }

  /// Autosaves [plan] into the current session (a planned one returns to
  /// draft until the next Save). Never throws: a failure is kept in
  /// [writeFailure] and logged.
  Future<void> write(SessionPlan Function() plan) =>
      _chain = _chain.then((_) async {
        final current = _session;
        Object? failure;
        try {
          _session = current != null && current.planEditable
              ? await _repository.updatePlan(current.id, plan())
              : await _repository.create(plan());
        } catch (e, s) {
          failure = e;
          AppLog.error('session', 'Autosave failed', error: e, stackTrace: s);
        }
        if (failure == _writeFailure) return;
        _writeFailure = failure;
        onWriteFailureChanged?.call();
      });

  /// Start (ADR-016): [plan] is written to the current session (or a new
  /// one), which starts with [snapshot]; the planner then continues on a
  /// fresh draft copy, so it never edits a running session (owner
  /// decision, TASK 13.3). Returns the started session.
  Future<Session> start(SessionPlan plan, SessionSnapshot snapshot) async {
    await _chain;
    final current = _session;
    final id = current != null && current.planEditable
        ? (await _repository.updatePlan(current.id, plan)).id
        : (await _repository.create(plan)).id;
    final started = await _repository.start(id, snapshot);
    _session = await _repository.create(plan);
    return started;
  }

  /// Save: the current open session — or a new one — becomes planned with
  /// [snapshot] (ADR-014 §3–§4).
  Future<Session> save(SessionPlan plan, SessionSnapshot snapshot) async {
    await _chain;
    final current = _session;
    final id = current != null && current.planEditable
        ? current.id
        : (await _repository.create(plan)).id;
    return _session = await _repository.savePlan(id, plan, snapshot);
  }
}
