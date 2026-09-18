import 'package:drift/drift.dart';

import '../../domain/models/location_profile.dart' as domain;
import '../../domain/repositories/location_repository.dart';
import '../database/app_database.dart';

class DriftLocationRepository implements LocationRepository {
  final AppDatabase _db;

  DriftLocationRepository(this._db);

  domain.LocationProfile _mapToDomain(LocationProfile row) {
    return domain.LocationProfile(
      id: row.id,
      name: row.name,
      latitude: row.latitude,
      longitude: row.longitude,
      elevation: row.elevation,
      bortleClass: row.bortleClass,
    );
  }

  @override
  Future<int> insertLocation(domain.LocationProfile location) {
    return _db
        .into(_db.locationProfiles)
        .insert(
          LocationProfilesCompanion.insert(
            name: location.name,
            latitude: location.latitude,
            longitude: location.longitude,
            elevation: location.elevation,
            bortleClass: Value(location.bortleClass),
          ),
        );
  }

  @override
  Future<List<domain.LocationProfile>> getLocations() async {
    final rows = await _db.select(_db.locationProfiles).get();
    return rows.map(_mapToDomain).toList();
  }

  @override
  Future<domain.LocationProfile?> getLocationById(int id) async {
    final row = await (_db.select(
      _db.locationProfiles,
    )..where((t) => t.id.equals(id))).getSingleOrNull();
    return row == null ? null : _mapToDomain(row);
  }

  @override
  Future<void> updateLocation(domain.LocationProfile location) {
    return (_db.update(
      _db.locationProfiles,
    )..where((t) => t.id.equals(location.id))).write(
      LocationProfilesCompanion(
        name: Value(location.name),
        latitude: Value(location.latitude),
        longitude: Value(location.longitude),
        elevation: Value(location.elevation),
        bortleClass: Value(location.bortleClass),
      ),
    );
  }

  @override
  Future<void> deleteLocation(int id) {
    return (_db.delete(
      _db.locationProfiles,
    )..where((t) => t.id.equals(id))).go();
  }
}
