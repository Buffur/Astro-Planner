import 'package:astroplan/domain/repositories/display_preferences_repository.dart';

/// In-memory [DisplayPreferencesRepository] for tests; [fieldMode] is the
/// stored value.
class InMemoryDisplayPreferences implements DisplayPreferencesRepository {
  InMemoryDisplayPreferences({this.fieldMode = false});

  bool fieldMode;

  @override
  Future<bool> loadFieldMode() async => fieldMode;

  @override
  Future<void> saveFieldMode(bool on) async => fieldMode = on;
}
