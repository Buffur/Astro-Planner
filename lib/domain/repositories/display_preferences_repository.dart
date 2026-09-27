import 'storage_failure.dart';

/// Persistence for display preferences (TASK 12.4): field mode survives a
/// restart; since TASK 13.3 also the opt-in keep-screen-on while tracking;
/// since S5.5 which collapsible sections the user left open or closed.
///
/// Every method throws [StorageFailure] when the store cannot be read or
/// written (TASK 15.1).
abstract class DisplayPreferencesRepository {
  /// Whether red field mode is on; false when nothing is saved.
  Future<bool> loadFieldMode();

  Future<void> saveFieldMode(bool on);

  /// Whether the screen stays on while tracking (ADR-016 §6); false (off)
  /// when nothing is saved.
  Future<bool> loadKeepScreenOn();

  Future<void> saveKeepScreenOn(bool on);

  /// Every remembered section state: section key → open. Empty when none
  /// is saved (S5.5).
  Future<Map<String, bool>> loadSectionStates();

  Future<void> saveSectionState(String key, bool open);
}
