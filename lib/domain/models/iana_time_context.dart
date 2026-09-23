import 'package:timezone/data/latest_all.dart' as tzdata;
import 'package:timezone/timezone.dart' as tz;

import 'site_time_context.dart';

/// A site's civil time from the IANA time zone database (ADR-007 §6;
/// TASK 7.1). Its [id] is the zone id, e.g. `Pacific/Kiritimati`.
///
/// Uses the `timezone` package's full data set (`latest_all`), which also
/// holds the link zones platforms report, e.g. `Europe/Ljubljana` (a link to
/// `Europe/Belgrade`) or `Asia/Calcutta`. TASK 7.1 used the 10-year set, which
/// has only canonical ids, so a device zone like `Europe/Ljubljana` was
/// rejected (TASK 7.3). ADR-007's mean-solar fallback covers sites without a
/// zone.
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

  /// Every zone id the bundled database knows, sorted (for a zone picker).
  static List<String> knownZoneIds() {
    _ensureInitialized();
    return tz.timeZoneDatabase.locations.keys.toList()..sort();
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
