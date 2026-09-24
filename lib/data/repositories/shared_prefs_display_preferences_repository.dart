import 'package:shared_preferences/shared_preferences.dart';

import '../../domain/repositories/display_preferences_repository.dart';
import 'storage_guard.dart';

/// [DisplayPreferencesRepository] backed by SharedPreferences.
class SharedPrefsDisplayPreferencesRepository
    implements DisplayPreferencesRepository {
  static const _fieldMode = 'fieldMode';
  static const _keepScreenOn = 'keepScreenOnWhileTracking';

  @override
  Future<bool> loadFieldMode() => guardStorage(
    'read the display preferences',
    () async =>
        (await SharedPreferences.getInstance()).getBool(_fieldMode) ?? false,
  );

  @override
  Future<void> saveFieldMode(bool on) => guardStorage(
    'save the display preferences',
    () async => (await SharedPreferences.getInstance()).setBool(_fieldMode, on),
  );

  @override
  Future<bool> loadKeepScreenOn() => guardStorage(
    'read the display preferences',
    () async =>
        (await SharedPreferences.getInstance()).getBool(_keepScreenOn) ?? false,
  );

  @override
  Future<void> saveKeepScreenOn(bool on) => guardStorage(
    'save the display preferences',
    () async =>
        (await SharedPreferences.getInstance()).setBool(_keepScreenOn, on),
  );
}
