import 'package:astroplan/domain/repositories/display_preferences_repository.dart';
import 'package:astroplan/domain/services/screen_wake.dart';

/// In-memory [DisplayPreferencesRepository] for tests; [fieldMode],
/// [keepScreenOn] and [sections] are the stored values. [failSections]
/// makes every section read and write throw, as a broken store would.
class InMemoryDisplayPreferences implements DisplayPreferencesRepository {
  InMemoryDisplayPreferences({
    this.fieldMode = false,
    this.keepScreenOn = false,
    Map<String, bool>? sections,
  }) : sections = sections ?? {};

  bool fieldMode;
  bool keepScreenOn;
  final Map<String, bool> sections;
  bool failSections = false;

  @override
  Future<Map<String, bool>> loadSectionStates() async {
    if (failSections) throw StateError('unreadable');
    return Map.of(sections);
  }

  @override
  Future<void> saveSectionState(String key, bool open) async {
    if (failSections) throw StateError('unwritable');
    sections[key] = open;
  }

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
