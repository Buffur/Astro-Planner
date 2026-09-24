import '../models/execution.dart';
import '../models/session.dart';

/// A session as exported (TASK 14.3): the aggregate with its run's events
/// (owner decision: the event log is included).
class ExportedSession {
  const ExportedSession(this.session, this.events);

  final Session session;
  final List<ExecutionEvent> events;
}

/// Writes sessions to a portable manifest file and shares it with a short
/// text summary (TASK 14.3; manifest v2, `docs/EXPORT_MANIFEST.md`).
/// Implemented in the data layer; import is deferred.
abstract class SessionExporter {
  Future<void> share(List<ExportedSession> sessions);
}
