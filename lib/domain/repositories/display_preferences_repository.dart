/// Persistence for display preferences (TASK 12.4): field mode survives a
/// restart.
abstract class DisplayPreferencesRepository {
  /// Whether red field mode is on; false when nothing is saved.
  Future<bool> loadFieldMode();

  Future<void> saveFieldMode(bool on);
}
