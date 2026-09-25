import '../../core/diagnostics/app_log.dart';
import '../models/session.dart';
import '../models/session_snapshot.dart';
import '../repositories/session_repository.dart';
import 'example_capture_plan.dart';

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
  bool _edited = false;

  Session? get session => _session;

  /// True when the current session holds plan changes the user made since
  /// it was created, opened or saved (S1.6; interim for RD-05): replacing it
  /// would leave them in a draft no screen lists. A resumed draft counts as
  /// edited when it is not the untouched example plan, or is a saved plan
  /// edited since.
  bool get hasUnsavedChanges => _edited;

  /// Called when [writeFailure] changes.
  void Function()? onWriteFailureChanged;

  /// Why the last autosave failed, until one succeeds (TASK 15.1). A failed
  /// write never blocks the later ones; each writes the whole plan, so the
  /// next edit retries it.
  Object? get writeFailure => _writeFailure;

  /// Completes when every write started so far has finished.
  Future<void> get idle => _chain;

  /// The most recent open session, or null when there is none.
  Future<Session?> resume() async {
    final s = _session = await _repository.mostRecentOpen();
    _edited =
        s != null &&
        s.status == SessionStatus.draft &&
        (s.plannedAtUtc != null || !ExampleCapturePlan.matches(s.blocks));
    return s;
  }

  /// Makes a new draft for [plan] the current session.
  Future<Session> startNew(SessionPlan plan) => _replacing(() async {
    await _chain;
    return _session = await _repository.create(plan);
  });

  /// Runs an operation after which the plan counts as unedited; if it
  /// fails, the changes still count as unsaved (S1.6).
  Future<T> _replacing<T>(Future<T> Function() run) async {
    final was = _edited;
    _edited = false;
    try {
      return await run();
    } catch (_) {
      _edited = was || _edited;
      rethrow;
    }
  }

  /// Opens [session]: a draft or planned one becomes current; a frozen one
  /// is copied — as [copy] — into a new draft (owner decision, TASK 11.4).
  Future<void> adopt(Session session, SessionPlan Function() copy) =>
      _replacing(() async {
        _session = session.planEditable ? session : await startNew(copy());
      });

  /// Autosaves [plan] into the current session (a planned one returns to
  /// draft until the next Save). Never throws: a failure is kept in
  /// [writeFailure] and logged. [edit] is false for a write the user did not
  /// make in the plan itself (a site change, S1.6).
  Future<void> write(SessionPlan Function() plan, {bool edit = true}) {
    if (edit) _edited = true;
    return _chain = _chain.then((_) async {
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
  }

  /// Start (ADR-016): [plan] is written to the current session (or a new
  /// one), which starts with [snapshot]; the planner then continues on a
  /// fresh draft copy, so it never edits a running session (owner
  /// decision, TASK 13.3). Returns the started session.
  Future<Session> start(SessionPlan plan, SessionSnapshot snapshot) =>
      _replacing(() => _inChain(() => _start(plan, snapshot)));

  Future<Session> _start(SessionPlan plan, SessionSnapshot snapshot) async {
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
  Future<Session> save(SessionPlan plan, SessionSnapshot snapshot) =>
      _replacing(
        () => _inChain(() async {
          final current = _session;
          final id = current != null && current.planEditable
              ? current.id
              : (await _repository.create(plan)).id;
          return _session = await _repository.savePlan(id, plan, snapshot);
        }),
      );

  /// Runs [op] after every write queued so far and queues later writes
  /// after it, so an edit made while Save or Start is running can never
  /// land in the middle of it — before S1.12 it could reach a session that
  /// was being started (ENG-08, RT-04). A failure of [op] reaches the
  /// caller through the returned future; the chain itself goes on.
  Future<T> _inChain<T>(Future<T> Function() op) {
    final result = _chain.then((_) => op());
    _chain = result.then<void>((_) {}, onError: (Object _) => null);
    return result;
  }
}
