/// The civil-time rule of a site: how far its clocks are from UTC at a given
/// instant (ADR-007 §6).
///
/// It is used for one thing only: deciding which civil calendar date a session
/// night belongs to. It never changes a night's instants. The device's time
/// zone is never a [SiteTimeContext].
abstract class SiteTimeContext {
  const SiteTimeContext();

  /// A stable identifier, persisted with a session night: `solar`, a fixed
  /// offset such as `UTC+14:00`, or (from TASK 7.1) an IANA zone id.
  String get id;

  /// The site's UTC offset (local = UTC + offset) at the UTC instant [utc].
  Duration offsetAt(DateTime utc);
}

/// Mean solar time at a longitude: offset = longitude × 4 min per degree.
///
/// The fallback when the site's civil zone is unknown (before TASK 7.1). It
/// agrees with civil time wherever the zone is within 12 h of mean solar time,
/// which is everywhere except the date-line anomalies (ADR-007 L1).
class MeanSolarTimeContext extends SiteTimeContext {
  /// [longitude] in degrees, east positive; any value is normalized to
  /// (−180°, 180°].
  MeanSolarTimeContext(double longitude)
    : offset = Duration(milliseconds: meanSolarOffsetMs(longitude));

  /// The constant offset of this context.
  final Duration offset;

  @override
  String get id => 'solar';

  @override
  Duration offsetAt(DateTime utc) => offset;

  /// Normalizes [longitude] (degrees, east positive) to (−180°, 180°], so that
  /// 180° and −180° are the same meridian (ADR-007 I10).
  static double normalizeLongitude(double longitude) {
    if (!longitude.isFinite) {
      throw ArgumentError.value(longitude, 'longitude', 'must be finite');
    }
    final wrapped = longitude % 360.0; // [0, 360)
    return wrapped > 180.0 ? wrapped - 360.0 : wrapped;
  }

  /// The mean solar offset in whole milliseconds:
  /// `round(λ × 240 000)`, where 1° = 4 min = 240 000 ms (ADR-007 §3).
  static int meanSolarOffsetMs(double longitude) =>
      (normalizeLongitude(longitude) * 240000.0).round();
}

/// A constant UTC offset (no DST), for example Kiritimati's UTC+14.
class FixedOffsetTimeContext extends SiteTimeContext {
  const FixedOffsetTimeContext(this.offset);

  final Duration offset;

  @override
  String get id {
    final minutes = offset.inMinutes;
    final sign = minutes < 0 ? '-' : '+';
    final abs = minutes.abs();
    final hh = (abs ~/ 60).toString().padLeft(2, '0');
    final mm = (abs % 60).toString().padLeft(2, '0');
    return 'UTC$sign$hh:$mm';
  }

  @override
  Duration offsetAt(DateTime utc) => offset;
}
