import 'package:shared_preferences/shared_preferences.dart';

import '../../domain/repositories/display_preferences_repository.dart';
import 'storage_guard.dart';

/// [DisplayPreferencesRepository] backed by SharedPreferences.
class SharedPrefsDisplayPreferencesRepository
    implements DisplayPreferencesRepository {
  static const fieldModeKey = 'fieldMode';

  /// Section states are stored one key each, under this prefix (S5.5).
  static const sectionPrefix = 'section.';

  @override
  Future<bool> loadFieldMode() => guardStorage(
    'read the display preferences',
    () async =>
        (await SharedPreferences.getInstance()).getBool(fieldModeKey) ?? false,
  );

  @override
  Future<void> saveFieldMode(bool on) => guardStorage(
    'save the display preferences',
    () async =>
        (await SharedPreferences.getInstance()).setBool(fieldModeKey, on),
  );

  @override
  Future<Map<String, bool>> loadSectionStates() =>
      guardStorage('read the display preferences', () async {
        final prefs = await SharedPreferences.getInstance();
        return {
          for (final k in prefs.getKeys())
            if (k.startsWith(sectionPrefix))
              k.substring(sectionPrefix.length): prefs.getBool(k) ?? false,
        };
      });

  @override
  Future<void> saveSectionState(String key, bool open) => guardStorage(
    'save the display preferences',
    () async => (await SharedPreferences.getInstance()).setBool(
      '$sectionPrefix$key',
      open,
    ),
  );
}
