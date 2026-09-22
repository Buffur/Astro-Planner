import 'package:timezone/data/latest_10y.dart' as tzdata;
import 'package:timezone/timezone.dart' as tz;

import 'site_time_context.dart';

/// A site's civil time from the IANA time zone database (ADR-007 §6;
/// TASK 7.1). Its [id] is the zone id, e.g. `Pacific/Kiritimati`.
///
/// Uses the `timezone` package's 10-year data set (rules for roughly the
/// current decade). Outside that range the package keeps the last known
/// rule — acceptable for planning; ADR-007's mean-solar fallback covers
/// sites without a zone.
class IanaTimeContext extends SiteTimeContext {
  IanaTimeContext._(this._location);

  final tz.Location _location;

  static bool _initialized = false;

  static void _ensureInitialized() {
    if (_initialized) return;
    tzdata.initializeTimeZones();
    _initialized = true;
  }

  /// The context for [zoneId], or null when it is null or not a known
  /// IANA zone (the caller then falls back to mean solar time).
  static IanaTimeContext? tryCreate(String? zoneId) {
    if (zoneId == null || zoneId.isEmpty) return null;
    _ensureInitialized();
    try {
      return IanaTimeContext._(tz.getLocation(zoneId));
    } on tz.LocationNotFoundException {
      return null;
    }
  }

  @override
  String get id => _location.name;

  @override
  Duration offsetAt(DateTime utc) =>
      _location.timeZone(utc.millisecondsSinceEpoch).offset;

  /// The zone's abbreviation at [utc] (e.g. `PDT`), as the database has it.
  String abbreviationAt(DateTime utc) =>
      _location.timeZone(utc.millisecondsSinceEpoch).abbreviation;
}
