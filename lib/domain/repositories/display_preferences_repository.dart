/// Persistence for display preferences (TASK 12.4): field mode survives a
/// restart; since TASK 13.3 also the opt-in keep-screen-on while tracking.
abstract class DisplayPreferencesRepository {
  /// Whether red field mode is on; false when nothing is saved.
  Future<bool> loadFieldMode();

  Future<void> saveFieldMode(bool on);

  /// Whether the screen stays on while tracking (ADR-016 §6); false (off)
  /// when nothing is saved.
  Future<bool> loadKeepScreenOn();

  Future<void> saveKeepScreenOn(bool on);
}
