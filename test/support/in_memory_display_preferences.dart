import 'package:astroplan/domain/repositories/display_preferences_repository.dart';

/// In-memory [DisplayPreferencesRepository] for tests; [fieldMode] and
/// [sections] are the stored values. [failSections] makes every section
/// read and write throw, as a broken store would.
class InMemoryDisplayPreferences implements DisplayPreferencesRepository {
  InMemoryDisplayPreferences({
    this.fieldMode = false,
    Map<String, bool>? sections,
  }) : sections = sections ?? {};

  bool fieldMode;
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
}
