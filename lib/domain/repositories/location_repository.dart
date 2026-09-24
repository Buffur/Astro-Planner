import '../models/location_profile.dart';
import 'storage_failure.dart';

/// Every method throws [StorageFailure] when the store cannot be read or
/// written (TASK 15.1).
abstract class LocationRepository {
  Future<int> insertLocation(LocationProfile location);
  Future<List<LocationProfile>> getLocations();
  Future<LocationProfile?> getLocationById(int id);
  Future<void> updateLocation(LocationProfile location);
  Future<void> deleteLocation(int id);
}
