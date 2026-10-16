import 'storage_failure.dart';

/// Persistence for display preferences (TASK 12.4): field mode survives a
/// restart; since S5.5 which collapsible sections the user left open or
/// closed. (TASK 13.3's keep-screen-on left with the tracker, S8.4.)
///
/// Every method throws [StorageFailure] when the store cannot be read or
/// written (TASK 15.1).
abstract class DisplayPreferencesRepository {
  /// Whether red field mode is on; false when nothing is saved.
  Future<bool> loadFieldMode();

  Future<void> saveFieldMode(bool on);

  /// Every remembered section state: section key → open. Empty when none
  /// is saved (S5.5).
  Future<Map<String, bool>> loadSectionStates();

  Future<void> saveSectionState(String key, bool open);
}
