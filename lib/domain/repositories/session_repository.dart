import '../models/calendar_date.dart';
import '../models/session.dart';
import '../models/session_snapshot.dart';

/// Persistence of the Session aggregate (ADR-014; TASK 11.3). Every write is
/// one transaction; lifecycle rules (ADR-014 §3) are enforced here and a
/// forbidden write throws [SessionStateError] without changing anything.
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
  /// which is never changed afterwards.
  Future<Session> start(int id, SessionSnapshot snapshot);

  /// In progress → completed.
  Future<Session> complete(int id);

  /// Draft, planned or in progress → abandoned.
  Future<Session> abandon(int id);

  /// Results and notes — editable in every non-legacy status, including
  /// completed (ADR-014 §3).
  Future<Session> updateResults(int id, SessionResults results);

  Future<Session?> get(int id);

  /// Newest-updated first (legacy rows by id). Filters combine.
  Future<List<Session>> list({
    Set<SessionStatus>? statuses,
    CalendarDate? eveningDate,
    int? targetId,
    bool includeLegacy = true,
  });

  /// The session the planner resumes (ADR-014 §3): the most recently
  /// updated non-legacy draft, planned or in-progress session.
  Future<Session?> mostRecentOpen();

  /// Deletes the session with its blocks.
  Future<void> delete(int id);
}
