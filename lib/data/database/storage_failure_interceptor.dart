import 'package:drift/drift.dart';

import '../../core/diagnostics/app_log.dart';
import '../../domain/repositories/storage_failure.dart';

/// Turns every error from a database statement into a [StorageFailure]
/// (TASK 15.1), so the Drift repositories throw the typed failure their
/// interfaces document instead of a SQLite error. Applied to every
/// `AppDatabase` connection. Opening and migrating are not intercepted:
/// their errors keep their own types (e.g. `UnsupportedSchemaVersionException`).
///
/// Errors thrown by repository code itself (`SessionStateError`,
/// `ArgumentError`, …) never pass through here and are unchanged.
class StorageFailureInterceptor extends QueryInterceptor {
  Future<T> _guard<T>(String action, Future<T> Function() run) async {
    try {
      return await run();
    } on StorageFailure {
      rethrow;
    } catch (e, s) {
      AppLog.error('storage', 'Could not $action', error: e, stackTrace: s);
      throw StorageFailure(action, e);
    }
  }

  static const _read = 'read the database';
  static const _write = 'write to the database';

  @override
  Future<List<Map<String, Object?>>> runSelect(
    QueryExecutor executor,
    String statement,
    List<Object?> args,
  ) => _guard(_read, () => executor.runSelect(statement, args));

  @override
  Future<int> runInsert(
    QueryExecutor executor,
    String statement,
    List<Object?> args,
  ) => _guard(_write, () => executor.runInsert(statement, args));

  @override
  Future<int> runUpdate(
    QueryExecutor executor,
    String statement,
    List<Object?> args,
  ) => _guard(_write, () => executor.runUpdate(statement, args));

  @override
  Future<int> runDelete(
    QueryExecutor executor,
    String statement,
    List<Object?> args,
  ) => _guard(_write, () => executor.runDelete(statement, args));

  @override
  Future<void> runCustom(
    QueryExecutor executor,
    String statement,
    List<Object?> args,
  ) => _guard(_write, () => executor.runCustom(statement, args));

  @override
  Future<void> runBatched(
    QueryExecutor executor,
    BatchedStatements statements,
  ) => _guard(_write, () => executor.runBatched(statements));

  @override
  Future<void> commitTransaction(TransactionExecutor inner) =>
      _guard(_write, inner.send);
}
