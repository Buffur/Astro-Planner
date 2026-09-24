import '../../core/diagnostics/app_log.dart';
import '../../domain/repositories/storage_failure.dart';

/// Runs a preferences read or write, turning any error from the store —
/// a platform failure or an unreadable stored value — into a logged
/// [StorageFailure] (TASK 15.1). [action] is a verb phrase: "read the
/// planning preferences".
Future<T> guardStorage<T>(String action, Future<T> Function() run) async {
  try {
    return await run();
  } on StorageFailure {
    rethrow;
  } catch (e, s) {
    AppLog.error('storage', 'Could not $action', error: e, stackTrace: s);
    throw StorageFailure(action, e);
  }
}
