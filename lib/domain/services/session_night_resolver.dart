import '../models/calendar_date.dart';
import '../models/session_night.dart';
import '../models/site_time_context.dart';

/// Resolves [SessionNight]s from a civil date or from the current instant
/// (ADR-007 §3–§5).
///
/// Pure and deterministic. Everything is computed in UTC with integer
/// milliseconds, and nothing reads the host or device time zone. No Sun or Moon
/// model is involved: a window depends only on longitude, date and the time
/// context (ADR-007 I12).
///
/// Units: latitude and longitude in degrees (north and east positive); all
/// `DateTime` inputs and outputs are UTC.
class SessionNightResolver {
  const SessionNightResolver._();

  /// The mean solar noon of solar date [solarDate] at [longitude]:
  /// `solarDate 12:00:00.000Z − round(λ × 240 000) ms` (ADR-007 §3).
  static DateTime meanSolarNoonUtc(CalendarDate solarDate, double longitude) =>
      solarDate
          .atUtcHour(12)
          .subtract(
            Duration(
              milliseconds: MeanSolarTimeContext.meanSolarOffsetMs(longitude),
            ),
          );

  /// The night that begins on the civil evening of [eveningDate] at the site.
  ///
  /// The window starts at the mean solar noon nearest to civil noon of
  /// [eveningDate] in [timeContext] (the earlier one on an exact tie), and ends
  /// 24 h later.
  ///
  /// Throws [ArgumentError] for a latitude outside [−90°, 90°], a non-finite
  /// longitude, or a date with no civil noon in [timeContext] (a historical
  /// zone discontinuity, ADR-007 L3).
  static SessionNight forEveningDate(
    CalendarDate eveningDate, {
    required double latitude,
    required double longitude,
    required SiteTimeContext timeContext,
  }) {
    _checkLatitude(latitude);
    final lon = MeanSolarTimeContext.normalizeLongitude(longitude);

    // Civil noon of the date, converted to UTC. Two steps, so the offset is the
    // one in force at (approximately) that instant; civil noon is never inside
    // a DST transition under current rules.
    final noonFields = eveningDate.atUtcHour(12);
    final firstGuess = noonFields.subtract(timeContext.offsetAt(noonFields));
    final civilNoonUtc = noonFields.subtract(timeContext.offsetAt(firstGuess));

    DateTime? best;
    int? bestDistanceMs;
    for (final shift in const [-1, 0, 1]) {
      final candidate = meanSolarNoonUtc(eveningDate.addDays(shift), lon);
      final distanceMs = candidate
          .difference(civilNoonUtc)
          .inMilliseconds
          .abs();
      // Candidates are visited in time order, so `<` keeps the earlier one on
      // an exact tie.
      if (bestDistanceMs == null || distanceMs < bestDistanceMs) {
        best = candidate;
        bestDistanceMs = distanceMs;
      }
    }
    final startUtc = best!;

    if (_eveningDateOf(startUtc, timeContext) != eveningDate) {
      throw ArgumentError.value(
        eveningDate,
        'eveningDate',
        'has no civil noon in time context ${timeContext.id}',
      );
    }

    return SessionNight(
      eveningDate: eveningDate,
      startUtc: startUtc,
      endUtc: startUtc.add(SessionNight.length),
      latitude: latitude,
      longitude: lon,
      timeContextId: timeContext.id,
    );
  }

  /// The default night for the instant [nowUtc]: the night whose window
  /// contains it (ADR-007 §5).
  ///
  /// The default therefore changes once per 24 h, at the site's mean solar
  /// noon. After midnight it is still the night in progress; between sunrise
  /// and solar noon it is the night that has just ended (ADR-007 L4).
  ///
  /// Throws [ArgumentError] if [nowUtc] is not UTC, or for invalid coordinates.
  static SessionNight resolveDefault(
    DateTime nowUtc, {
    required double latitude,
    required double longitude,
    required SiteTimeContext timeContext,
  }) {
    if (!nowUtc.isUtc) {
      throw ArgumentError.value(nowUtc, 'nowUtc', 'must be UTC');
    }
    _checkLatitude(latitude);
    final lon = MeanSolarTimeContext.normalizeLongitude(longitude);

    // Mean solar date at the site, then step back one day while its noon is
    // still in the future.
    final solarFields = nowUtc.add(
      Duration(milliseconds: MeanSolarTimeContext.meanSolarOffsetMs(lon)),
    );
    var startUtc = meanSolarNoonUtc(
      CalendarDate.fromDateTimeFields(solarFields),
      lon,
    );
    if (nowUtc.isBefore(startUtc)) {
      startUtc = startUtc.subtract(SessionNight.length);
    }

    return SessionNight(
      eveningDate: _eveningDateOf(startUtc, timeContext),
      startUtc: startUtc,
      endUtc: startUtc.add(SessionNight.length),
      latitude: latitude,
      longitude: lon,
      timeContextId: timeContext.id,
    );
  }

  /// The civil date of a window start in [timeContext] (ADR-007 §4, `labelOf`).
  static CalendarDate _eveningDateOf(
    DateTime startUtc,
    SiteTimeContext timeContext,
  ) => CalendarDate.fromDateTimeFields(
    startUtc.add(timeContext.offsetAt(startUtc)),
  );

  static void _checkLatitude(double latitude) {
    if (!latitude.isFinite || latitude < -90.0 || latitude > 90.0) {
      throw ArgumentError.value(latitude, 'latitude', 'must be in [-90, 90]');
    }
  }
}
