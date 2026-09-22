import '../models/session_log.dart';

abstract class LogbookRepository {
  /// Newest-saved first (TASK 4.2, TD-039).
  Future<List<SessionLog>> getAllLogs();

  /// Returns the new row's id (TASK 4.2, TD-011) so a caller can track it
  /// and route a later save to [updateLog] instead of inserting a duplicate.
  Future<int> addLog(SessionLog log);
  Future<void> updateLog(SessionLog log);
  Future<void> deleteLog(int id);
}
