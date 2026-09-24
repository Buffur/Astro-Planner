import 'package:astroplan/domain/repositories/display_preferences_repository.dart';
import 'package:astroplan/domain/services/screen_wake.dart';

/// In-memory [DisplayPreferencesRepository] for tests; [fieldMode] and
/// [keepScreenOn] are the stored values.
class InMemoryDisplayPreferences implements DisplayPreferencesRepository {
  InMemoryDisplayPreferences({
    this.fieldMode = false,
    this.keepScreenOn = false,
  });

  bool fieldMode;
  bool keepScreenOn;

  @override
  Future<bool> loadFieldMode() async => fieldMode;

  @override
  Future<void> saveFieldMode(bool on) async => fieldMode = on;

  @override
  Future<bool> loadKeepScreenOn() async => keepScreenOn;

  @override
  Future<void> saveKeepScreenOn(bool on) async => keepScreenOn = on;
}

/// A [ScreenWake] that records the last request instead of touching the
/// platform.
class FakeScreenWake implements ScreenWake {
  bool on = false;
  final List<bool> calls = [];

  @override
  Future<void> keepOn(bool value) async {
    on = value;
    calls.add(value);
  }
}
