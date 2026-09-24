/// Keeps the phone's screen on while tracking (ADR-016 §6; TASK 13.3).
/// Opt-in, only while the tracking screen is visible and a run is active.
abstract class ScreenWake {
  Future<void> keepOn(bool on);
}
