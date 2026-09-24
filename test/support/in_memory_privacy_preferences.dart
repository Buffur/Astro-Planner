import 'package:astroplan/domain/repositories/privacy_preferences_repository.dart';

/// In-memory [PrivacyPreferencesRepository] for tests; [placeNameLookup] is
/// the stored choice.
class InMemoryPrivacyPreferences implements PrivacyPreferencesRepository {
  InMemoryPrivacyPreferences({this.placeNameLookup = false});

  bool placeNameLookup;

  @override
  Future<bool> loadPlaceNameLookup() async => placeNameLookup;

  @override
  Future<void> savePlaceNameLookup(bool on) async => placeNameLookup = on;
}
