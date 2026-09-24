/// Whether the first-run setup was finished or skipped (TASK 12.5).
abstract class FirstRunRepository {
  /// False until [markDone] was called on this install.
  Future<bool> isDone();

  Future<void> markDone();
}
