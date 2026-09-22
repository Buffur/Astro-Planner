import 'package:drift/drift.dart';

import '../../domain/models/calendar_date.dart';
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
      bortleSource: row.bortleSource,
      bortleDate: _date(row.bortleDate),
      sqm: row.sqm,
      sqmSource: row.sqmSource,
      sqmDate: _date(row.sqmDate),
      timeZoneId: row.timeZone,
      notes: row.notes,
    );
  }

  static CalendarDate? _date(String? iso) =>
      iso == null ? null : CalendarDate.parse(iso);

  static LocationProfilesCompanion _companion(domain.LocationProfile l) =>
      LocationProfilesCompanion(
        name: Value(l.name),
        latitude: Value(l.latitude),
        longitude: Value(l.longitude),
        elevation: Value(l.elevation),
        bortleClass: Value(l.bortleClass),
        bortleSource: Value(l.bortleSource),
        bortleDate: Value(l.bortleDate?.toIso8601String()),
        sqm: Value(l.sqm),
        sqmSource: Value(l.sqmSource),
        sqmDate: Value(l.sqmDate?.toIso8601String()),
        timeZone: Value(l.timeZoneId),
        notes: Value(l.notes),
      );

  @override
  Future<int> insertLocation(domain.LocationProfile location) {
    return _db.into(_db.locationProfiles).insert(_companion(location));
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
    )..where((t) => t.id.equals(location.id))).write(_companion(location));
  }

  @override
  Future<void> deleteLocation(int id) {
    return (_db.delete(
      _db.locationProfiles,
    )..where((t) => t.id.equals(id))).go();
  }
}
