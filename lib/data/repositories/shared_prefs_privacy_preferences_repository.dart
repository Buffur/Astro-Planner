import 'package:shared_preferences/shared_preferences.dart';

import '../../domain/repositories/privacy_preferences_repository.dart';
import 'storage_guard.dart';

/// [PrivacyPreferencesRepository] backed by SharedPreferences (TASK 16.3).
class SharedPrefsPrivacyPreferencesRepository
    implements PrivacyPreferencesRepository {
  static const _placeNames = 'placeNameLookup';

  @override
  Future<bool> loadPlaceNameLookup() => guardStorage(
    'read the privacy settings',
    () async =>
        (await SharedPreferences.getInstance()).getBool(_placeNames) ?? false,
  );

  @override
  Future<void> savePlaceNameLookup(bool on) => guardStorage(
    'save the privacy settings',
    () async =>
        (await SharedPreferences.getInstance()).setBool(_placeNames, on),
  );
}
