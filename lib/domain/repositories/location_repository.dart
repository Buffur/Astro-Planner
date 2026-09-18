import '../models/location_profile.dart';

abstract class LocationRepository {
  Future<int> insertLocation(LocationProfile location);
  Future<List<LocationProfile>> getLocations();
  Future<LocationProfile?> getLocationById(int id);
  Future<void> updateLocation(LocationProfile location);
  Future<void> deleteLocation(int id);
}
