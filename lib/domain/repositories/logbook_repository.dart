import '../models/session_log.dart';

abstract class LogbookRepository {
  Future<List<SessionLog>> getAllLogs();
  Future<void> addLog(SessionLog log);
  Future<void> updateLog(SessionLog log);
  Future<void> deleteLog(int id);
}
