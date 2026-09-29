import '../models/calendar_date.dart';
import '../models/execution.dart';
import '../models/session.dart';
import '../models/session_result.dart';
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

  /// Discards a never-saved draft (`draft` without `plannedAtUtc`; S6.3,
  /// U1): deletes it with its blocks. Any other session — a saved plan, a
  /// run, a result, a legacy log — is refused with [SessionStateError] and
  /// nothing changes. A session already gone is not an error.
  Future<void> deleteDraft(int id);

  /// Discards a Saved · changed plan's unsaved changes (S4-DEF-04 = R;
  /// S6.3): its plan is restored from its plan snapshot and it becomes
  /// planned again. The snapshot and `plannedAtUtc` are not touched.
  /// Throws [SavedPlanUnavailable] when the snapshot cannot be read or names
  /// a site, target or rig that no longer exists, and [SessionStateError]
  /// for any other session; nothing changes then.
  Future<Session> revertToSaved(int id);

  /// Records [report] for session [id] after its night (ADR-019 §3.1, §4;
  /// S8.1), in one transaction, with its notes and conditions:
  /// - a Saved (`planned`) plan whose saved night has ended (CALC-44): no
  ///   run and no Save plan. Completed as planned and Partly append a
  ///   `reported` event and one `framesConfirmed` per light block with a
  ///   count; Not done abandons it with the optional reason;
  /// - a run in progress (the legacy live mode): `finished` and corrections
  ///   to the reported counts, or Not done through abandon;
  /// - a completed entry: counts change by correction events, and Completed
  ///   as planned and Partly may be exchanged; a Not done entry: its reason
  ///   and notes.
  ///
  /// The snapshot never changes, and the result totals come from the replay.
  /// Refused, with nothing written: a legacy row, a draft (a Saved · changed
  /// plan is settled first, [settleSavedPlan]; one whose snapshot cannot be
  /// read takes only Not done, S4-DEF-06), a night that has not ended
  /// ([NightNotEnded]), completed ↔ Not done, and an [expectedUpdatedAtUtc]
  /// other than the stored one ([StaleResultForm]).
  Future<Session> recordResult(
    int id,
    ResultReport report, {
    DateTime? expectedUpdatedAtUtc,
  });

  /// Settles a Saved · changed plan (S8.1; S4-DEF-03, I-3), in one
  /// transaction: a new never-saved draft receives its working plan, and it
  /// goes back to what was saved (Saved). A reference its snapshot names that
  /// no longer exists is cleared, as deleting it would have done. When the
  /// snapshot cannot be read the plan is left as it is and only the copy is
  /// made (S4-DEF-06). Returns the copy, or null when [id] is not Saved ·
  /// changed (nothing written; so a repeat does nothing).
  Future<Session?> settleSavedPlan(int id);

  /// Names session [id] (S8.6; 08 §24): [name] trimmed, at most
  /// [maxNameLength] characters; empty or null removes it. A name is a
  /// label, not plan content: the status, the snapshot and the plan never
  /// change. A legacy row is refused.
  Future<Session> rename(int id, String? name);

  static const maxNameLength = 80;
}
