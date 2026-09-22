import 'calendar_date.dart';

/// One imaging night at one site (ADR-007).
///
/// - **Identity:** the site plus [eveningDate], the civil calendar date at the
///   site on whose evening the night begins.
/// - **Window:** the half-open UTC interval [[startUtc], [endUtc]). [startUtc]
///   is a mean solar noon of the site, and the window is exactly 24 h long.
///   DST never changes it.
///
/// A night always exists, at every latitude and on every date. Polar day,
/// polar night and the absence of astronomical darkness describe what is
/// inside the window (TASK 2.3), not whether the window exists.
///
/// Create instances with `SessionNightResolver`; the constructor only checks
/// the invariants it can see.
class SessionNight {
  /// Throws [ArgumentError] if an instant is not UTC or the window is not
  /// exactly [length] long.
  SessionNight({
    required this.eveningDate,
    required this.startUtc,
    required this.endUtc,
    required this.latitude,
    required this.longitude,
    required this.timeContextId,
  }) {
    if (!startUtc.isUtc || !endUtc.isUtc) {
      throw ArgumentError('SessionNight instants must be UTC');
    }
    if (endUtc.difference(startUtc) != length) {
      throw ArgumentError('SessionNight window must be exactly 24 h');
    }
  }

  /// The length of every window (ADR-007 I1).
  static const Duration length = Duration(hours: 24);

  /// Civil evening date at the site. Persisted as `YYYY-MM-DD`.
  final CalendarDate eveningDate;

  /// Window start (inclusive), UTC: a mean solar noon of the site.
  final DateTime startUtc;

  /// Window end (exclusive), UTC: [startUtc] + 24 h.
  final DateTime endUtc;

  /// Site latitude in degrees, north positive, in [−90°, 90°].
  final double latitude;

  /// Site longitude in degrees, east positive, normalized to (−180°, 180°].
  final double longitude;

  /// The `SiteTimeContext.id` used to resolve [eveningDate].
  final String timeContextId;

  /// Whether the UTC instant [instantUtc] lies in [[startUtc], [endUtc]).
  bool contains(DateTime instantUtc) =>
      !instantUtc.isBefore(startUtc) && instantUtc.isBefore(endUtc);

  @override
  bool operator ==(Object other) =>
      other is SessionNight &&
      eveningDate == other.eveningDate &&
      startUtc == other.startUtc &&
      endUtc == other.endUtc &&
      latitude == other.latitude &&
      longitude == other.longitude &&
      timeContextId == other.timeContextId;

  @override
  int get hashCode => Object.hash(
    eveningDate,
    startUtc,
    endUtc,
    latitude,
    longitude,
    timeContextId,
  );

  @override
  String toString() =>
      'SessionNight($eveningDate, ${startUtc.toIso8601String()} → '
      '${endUtc.toIso8601String()}, lat $latitude, lon $longitude, '
      '$timeContextId)';
}
