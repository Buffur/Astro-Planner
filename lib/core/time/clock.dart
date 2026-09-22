/// Source of the current instant.
///
/// Everything that needs "now" takes a [Clock] instead of calling
/// `DateTime.now()`, so that time-dependent logic is deterministic under test
/// (ADR-007 §5, TASK 2.2).
abstract class Clock {
  const Clock();

  /// The current instant, always in UTC (`isUtc == true`).
  DateTime nowUtc();
}

/// The real system clock.
class SystemClock extends Clock {
  const SystemClock();

  @override
  DateTime nowUtc() => DateTime.now().toUtc();
}

/// A clock frozen at one instant. Intended for tests and reproducible runs.
class FixedClock extends Clock {
  /// Throws [ArgumentError] if [instant] is not UTC: a local `DateTime` would
  /// make the result depend on the host time zone.
  FixedClock(this.instant) {
    if (!instant.isUtc) {
      throw ArgumentError.value(instant, 'instant', 'must be UTC');
    }
  }

  final DateTime instant;

  @override
  DateTime nowUtc() => instant;
}
