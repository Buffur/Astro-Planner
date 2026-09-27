import '../../core/diagnostics/app_log.dart';
import '../models/session.dart';
import '../models/session_snapshot.dart';
import '../repositories/planner_state_repository.dart';
import '../repositories/session_repository.dart';
import 'example_capture_plan.dart';

/// The session the planner works on and its autosave (ADR-014 §3; TASK
/// 11.4; moved out of the planner ViewModel in TASK 12.3). Writes are
/// serialized so they reach the database in edit order; a frozen session
/// (completed, abandoned, in progress, legacy) is never written — the plan
/// then goes into a new draft.
class CurrentSession {
  CurrentSession(this._repository, [this._marks]);

  final SessionRepository _repository;

  /// Where the id of the session with unsaved edits is remembered across a
  /// restart (S1.V3); null in tests that do not need it.
  final PlannerStateRepository? _marks;
  Session? _session;
  Future<void> _chain = Future.value();
  Object? _writeFailure;
  bool _edited = false;

  Session? get session => _session;

  /// True when the current session holds plan changes the user made since
  /// it was created, opened or saved (S1.6; interim for RD-05): replacing it
  /// would leave them in a draft no screen lists. A resumed draft counts as
  /// edited when it was remembered as edited (S1.V3: any edit — target, rig,
  /// night or blocks), is not the untouched example plan, or is a saved plan
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
    final marked = await _readMark();
    _edited =
        s != null &&
        s.status == SessionStatus.draft &&
        (marked == s.id ||
            s.plannedAtUtc != null ||
            !ExampleCapturePlan.matches(s.blocks));
    return s;
  }

  Future<int?> _readMark() async {
    try {
      return await _marks?.getEditedSessionId();
    } catch (e) {
      AppLog.warning('session', 'Unsaved-changes mark unreadable', error: e);
      return null;
    }
  }

  /// Remembers [id] as the session with unsaved edits, or none. A failure
  /// is logged: the in-memory flag still protects this run.
  Future<void> _mark(int? id) async {
    try {
      await _marks?.setEditedSessionId(id);
    } catch (e) {
      AppLog.warning('session', 'Unsaved-changes mark not saved', error: e);
    }
  }

  /// Makes a new draft for [plan] the current session. It runs in the
  /// autosave chain, so an edit made meanwhile lands in the new draft, not
  /// in the one it replaces (TD-058, S6.2).
  Future<Session> startNew(SessionPlan plan) => _replacing(
    () => _inChain(() async => _session = await _repository.create(plan)),
  );

  /// Runs an operation after which the plan counts as unedited; if it
  /// fails, the changes still count as unsaved (S1.6).
  Future<T> _replacing<T>(Future<T> Function() run) async {
    final was = _edited;
    _edited = false;
    try {
      final result = await run();
      if (!_edited) await _mark(null);
      return result;
    } catch (_) {
      _edited = was || _edited;
      rethrow;
    }
  }

  /// Opens [session]: a draft or planned one becomes current; a frozen one
  /// is copied — as [copy] — into a new draft (owner decision, TASK 11.4).
  /// In the autosave chain, like [startNew] (TD-058, S6.2).
  Future<void> adopt(Session session, SessionPlan Function() copy) =>
      _replacing(
        () => _inChain(() async {
          _session = session.planEditable
              ? session
              : await _repository.create(copy());
        }),
      );

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
      if (edit && _edited) {
        if (_session case final written?) await _mark(written.id);
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
  /// after it, so an edit made while Save, Start, New or Open is running
  /// can never land in the middle of it — before S1.12 (Save, Start) and
  /// S6.2 (New, Open; TD-058) it could reach the session being replaced
  /// (ENG-08, RT-04). A failure of [op] reaches the
  /// caller through the returned future; the chain itself goes on.
  Future<T> _inChain<T>(Future<T> Function() op) {
    final result = _chain.then((_) => op());
    _chain = result.then<void>((_) {}, onError: (Object _) => null);
    return result;
  }
}
