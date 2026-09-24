import 'package:shared_preferences/shared_preferences.dart';

import '../../domain/repositories/display_preferences_repository.dart';

/// [DisplayPreferencesRepository] backed by SharedPreferences.
class SharedPrefsDisplayPreferencesRepository
    implements DisplayPreferencesRepository {
  static const _fieldMode = 'fieldMode';
  static const _keepScreenOn = 'keepScreenOnWhileTracking';

  @override
  Future<bool> loadFieldMode() async =>
      (await SharedPreferences.getInstance()).getBool(_fieldMode) ?? false;

  @override
  Future<void> saveFieldMode(bool on) async =>
      (await SharedPreferences.getInstance()).setBool(_fieldMode, on);

  @override
  Future<bool> loadKeepScreenOn() async =>
      (await SharedPreferences.getInstance()).getBool(_keepScreenOn) ?? false;

  @override
  Future<void> saveKeepScreenOn(bool on) async =>
      (await SharedPreferences.getInstance()).setBool(_keepScreenOn, on);
}
