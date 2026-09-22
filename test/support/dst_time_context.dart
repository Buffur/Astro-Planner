import 'package:astroplan/domain/models/site_time_context.dart';

/// A test-only [SiteTimeContext] with daylight saving time, so DST behavior
/// can be tested without the `timezone` package (deferred to TASK 7.1,
/// ADR-007 §6).
///
/// The transition instants are copied from the IANA tz database (checked with
/// Python `zoneinfo` on 2026-09-22) and cover 2026–2027 only.
class DstTimeContext extends SiteTimeContext {
  const DstTimeContext({
    required this.id,
    required this.standardOffset,
    required this.dstOffset,
    required this.dstPeriodsUtc,
  });

  @override
  final String id;
  final Duration standardOffset;
  final Duration dstOffset;

  /// Half-open UTC intervals [start, end) during which [dstOffset] applies.
  final List<(DateTime, DateTime)> dstPeriodsUtc;

  @override
  Duration offsetAt(DateTime utc) {
    for (final (start, end) in dstPeriodsUtc) {
      if (!utc.isBefore(start) && utc.isBefore(end)) return dstOffset;
    }
    return standardOffset;
  }

  static final berlin = DstTimeContext(
    id: 'test:Europe/Berlin',
    standardOffset: const Duration(hours: 1),
    dstOffset: const Duration(hours: 2),
    dstPeriodsUtc: [
      (DateTime.utc(2026, 3, 29, 1), DateTime.utc(2026, 10, 25, 1)),
      (DateTime.utc(2027, 3, 28, 1), DateTime.utc(2027, 10, 31, 1)),
    ],
  );

  static final losAngeles = DstTimeContext(
    id: 'test:America/Los_Angeles',
    standardOffset: const Duration(hours: -8),
    dstOffset: const Duration(hours: -7),
    dstPeriodsUtc: [
      (DateTime.utc(2026, 3, 8, 10), DateTime.utc(2026, 11, 1, 9)),
      (DateTime.utc(2027, 3, 14, 10), DateTime.utc(2027, 11, 7, 9)),
    ],
  );

  static final newYork = DstTimeContext(
    id: 'test:America/New_York',
    standardOffset: const Duration(hours: -5),
    dstOffset: const Duration(hours: -4),
    dstPeriodsUtc: [
      (DateTime.utc(2026, 3, 8, 7), DateTime.utc(2026, 11, 1, 6)),
      (DateTime.utc(2027, 3, 14, 7), DateTime.utc(2027, 11, 7, 6)),
    ],
  );

  /// Europe/Oslo has the same rules as Berlin in these years.
  static final oslo = DstTimeContext(
    id: 'test:Europe/Oslo',
    standardOffset: berlin.standardOffset,
    dstOffset: berlin.dstOffset,
    dstPeriodsUtc: berlin.dstPeriodsUtc,
  );

  /// Europe/London (GMT/BST) has the same transition instants as Berlin.
  static final london = DstTimeContext(
    id: 'test:Europe/London',
    standardOffset: Duration.zero,
    dstOffset: const Duration(hours: 1),
    dstPeriodsUtc: berlin.dstPeriodsUtc,
  );
}
