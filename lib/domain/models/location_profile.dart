import 'calendar_date.dart';

/// A saved site (TASK 7.1).
///
/// Unknown stays unknown (SI-008): Bortle, SQM and the time zone are
/// nullable, and each sky-darkness value carries its source and date
/// (ADR-008 §6). A site changes only through an explicit user edit; the
/// current map/GPS position is transient and never written into a site.
class LocationProfile {
  /// Throws [ArgumentError] for coordinates or sky values out of range.
  factory LocationProfile({
    required int id,
    required String name,
    required double latitude,
    required double longitude,
    required double elevation,
    int? bortleClass,
    String? bortleSource,
    CalendarDate? bortleDate,
    double? sqm,
    String? sqmSource,
    CalendarDate? sqmDate,
    String? timeZoneId,
    String? notes,
  }) {
    if (!latitude.isFinite || latitude < -90 || latitude > 90) {
      throw ArgumentError.value(latitude, 'latitude', 'must be in [-90, 90]');
    }
    if (!longitude.isFinite || longitude < -180 || longitude > 180) {
      throw ArgumentError.value(
        longitude,
        'longitude',
        'must be in [-180, 180]',
      );
    }
    if (!elevation.isFinite || elevation < -500 || elevation > 9000) {
      throw ArgumentError.value(elevation, 'elevation', 'metres, -500..9000');
    }
    if (bortleClass != null && (bortleClass < 1 || bortleClass > 9)) {
      throw ArgumentError.value(bortleClass, 'bortleClass', 'must be 1..9');
    }
    if (sqm != null && (!sqm.isFinite || sqm < 15 || sqm > 23)) {
      throw ArgumentError.value(sqm, 'sqm', 'mag/arcsec², 15..23');
    }
    return LocationProfile._(
      id: id,
      name: name,
      latitude: latitude,
      longitude: longitude,
      elevation: elevation,
      bortleClass: bortleClass,
      bortleSource: bortleSource,
      bortleDate: bortleDate,
      sqm: sqm,
      sqmSource: sqmSource,
      sqmDate: sqmDate,
      timeZoneId: timeZoneId,
      notes: notes,
    );
  }

  const LocationProfile._({
    required this.id,
    required this.name,
    required this.latitude,
    required this.longitude,
    required this.elevation,
    required this.bortleClass,
    required this.bortleSource,
    required this.bortleDate,
    required this.sqm,
    required this.sqmSource,
    required this.sqmDate,
    required this.timeZoneId,
    required this.notes,
  });

  final int id;
  final String name;

  /// Degrees, north positive.
  final double latitude;

  /// Degrees, east positive.
  final double longitude;

  /// Metres above mean sea level.
  final double elevation;

  /// Bortle class 1–9, or null when unknown.
  final int? bortleClass;

  /// Where [bortleClass] came from (`user`, `legacy`, …), null if unknown.
  final String? bortleSource;
  final CalendarDate? bortleDate;

  /// Sky quality, mag/arcsec², or null when unknown.
  final double? sqm;
  final String? sqmSource;
  final CalendarDate? sqmDate;

  /// IANA time zone id, or null when unknown (ADR-007 §6).
  final String? timeZoneId;

  final String? notes;

  /// A copy with the Bortle class set by the user on [date].
  LocationProfile withUserBortle(int? bortle, CalendarDate date) =>
      LocationProfile(
        id: id,
        name: name,
        latitude: latitude,
        longitude: longitude,
        elevation: elevation,
        bortleClass: bortle,
        bortleSource: bortle == null ? null : 'user',
        bortleDate: bortle == null ? null : date,
        sqm: sqm,
        sqmSource: sqmSource,
        sqmDate: sqmDate,
        timeZoneId: timeZoneId,
        notes: notes,
      );
}
