import '../models/calendar_date.dart';
import '../models/execution.dart';
import '../models/session.dart';
import '../models/session_snapshot.dart';
import 'storage_failure.dart';

/// Persistence of the Session aggregate (ADR-014; TASK 11.3). Every write is
/// one transaction; lifecycle rules (ADR-014 §3) are enforced here and a
/// forbidden write throws [SessionStateError] without changing anything.
///
/// Every method throws [StorageFailure] when the store cannot be read or
/// written (TASK 15.1).
abstract class SessionRepository {
  /// A new draft for [plan].
  Future<Session> create(SessionPlan plan);

  /// Replaces the plan of a draft or planned session. A planned session goes
  /// back to draft (its plan snapshot is re-taken on the next save).
  Future<Session> updatePlan(int id, SessionPlan plan);

  /// Writes [plan], marks the session planned and replaces its plan
  /// snapshot with [snapshot] (ADR-014 §3: refreshed on each Save).
  Future<Session> savePlan(int id, SessionPlan plan, SessionSnapshot snapshot);

  /// Draft/planned → in progress, taking the execution-start snapshot,
  /// which is never changed afterwards, and recording the run's start on
  /// [blockId] — by default the first light block with frames, else the
  /// first block (ADR-016 §2). Refused while another session is in progress
  /// (owner: one at a time), or when the plan has no block.
  Future<Session> start(int id, SessionSnapshot snapshot, {int? blockId});

  /// In progress → completed; the run's `finished` event is recorded in the
  /// same transaction.
  Future<Session> complete(int id);

  /// Draft, planned or in progress → abandoned; for a session in progress
  /// the run's `abandoned` event is recorded in the same transaction.
  Future<Session> abandon(int id);

  /// Records one execution event on the session in progress [id] (ADR-016
  /// §4): the event and its effect on the block counters in one
  /// transaction. Finishing and abandoning go through [complete] and
  /// [abandon]. Throws [ExecutionError] when the event is not allowed now,
  /// and [SessionStateError] when the session is not in progress.
  Future<ExecutionState> record(
    int id,
    ExecutionEventKind kind, {
    int? blockId,
    int? delta,
    InterruptionReason? reason,
  });

  /// The run's stored events, in order.
  Future<List<ExecutionEvent>> events(int id);

  /// The run's state: the fold of its events (ADR-016 §4).
  Future<ExecutionState> execution(int id);

  /// The session in progress, if any (at most one, ADR-016 §2).
  Future<Session?> inProgress();

  /// Results and notes — editable in every non-legacy status, including
  /// completed (ADR-014 §3).
  Future<Session> updateResults(int id, SessionResults results);

  Future<Session?> get(int id);

  /// Newest-updated first (legacy rows by id). Filters combine. [from] and
  /// [to] bound the night (inclusive); a legacy row without a night key
  /// matches by its stored date. A site or target filter never matches a
  /// legacy row (its references are unknown, ADR-014 §7).
  Future<List<Session>> list({
    Set<SessionStatus>? statuses,
    CalendarDate? eveningDate,
    int? targetId,
    int? siteId,
    CalendarDate? from,
    CalendarDate? to,
    bool includeLegacy = true,
  });

  /// The session the planner resumes (ADR-014 §3): the most recently
  /// updated non-legacy draft, planned or in-progress session.
  Future<Session?> mostRecentOpen();

  /// Deletes the session with its blocks.
  Future<void> delete(int id);
}
