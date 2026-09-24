import 'storage_failure.dart';

/// Whether the first-run setup was finished or skipped (TASK 12.5).
///
/// Every method throws [StorageFailure] when the store cannot be read or
/// written (TASK 15.1).
abstract class FirstRunRepository {
  /// False until [markDone] was called on this install.
  Future<bool> isDone();

  Future<void> markDone();
}
