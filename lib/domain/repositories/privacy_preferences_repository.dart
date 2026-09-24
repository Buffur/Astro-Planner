import 'storage_failure.dart';

/// Privacy choices (TASK 16.3, owner decision PD-12): whether the app may
/// send positions to OpenStreetMap Nominatim for place names. Off (false)
/// when nothing is saved.
///
/// Every method throws [StorageFailure] when the store cannot be read or
/// written (TASK 15.1).
abstract class PrivacyPreferencesRepository {
  Future<bool> loadPlaceNameLookup();

  Future<void> savePlaceNameLookup(bool on);
}
