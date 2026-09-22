/// A calendar date with no time of day and no time zone.
///
/// Used for the civil evening date of a session night (ADR-007 §2). It is
/// deliberately not a `DateTime`: encoding a date as an instant is what made the
/// night depend on the UTC or device zone (SI-010).
class CalendarDate implements Comparable<CalendarDate> {
  /// Throws [ArgumentError] if the fields do not name a real date
  /// (for example February 30).
  factory CalendarDate(int year, int month, int day) {
    final normalized = DateTime.utc(year, month, day);
    if (normalized.year != year ||
        normalized.month != month ||
        normalized.day != day) {
      throw ArgumentError('Invalid calendar date: $year-$month-$day');
    }
    return CalendarDate._(year, month, day);
  }

  const CalendarDate._(this.year, this.month, this.day);

  /// The date fields of [dateTime], read as they are. No zone conversion is
  /// applied, so the caller decides which zone the fields belong to.
  factory CalendarDate.fromDateTimeFields(DateTime dateTime) =>
      CalendarDate._(dateTime.year, dateTime.month, dateTime.day);

  /// Parses an ISO-8601 calendar date, `YYYY-MM-DD`.
  factory CalendarDate.parse(String text) {
    final match = RegExp(r'^(\d{4})-(\d{2})-(\d{2})$').firstMatch(text);
    if (match == null) {
      throw FormatException('Expected YYYY-MM-DD', text);
    }
    return CalendarDate(
      int.parse(match.group(1)!),
      int.parse(match.group(2)!),
      int.parse(match.group(3)!),
    );
  }

  final int year;
  final int month;
  final int day;

  /// The date [days] later (negative for earlier).
  CalendarDate addDays(int days) =>
      CalendarDate.fromDateTimeFields(DateTime.utc(year, month, day + days));

  /// This date at [hour]:00 read as UTC fields. A helper for arithmetic only;
  /// the result is not "this date in UTC" in any civil sense.
  DateTime atUtcHour(int hour) => DateTime.utc(year, month, day, hour);

  /// ISO-8601 `YYYY-MM-DD`, the persisted form (ADR-007 §4, §10).
  String toIso8601String() =>
      '${year.toString().padLeft(4, '0')}-'
      '${month.toString().padLeft(2, '0')}-'
      '${day.toString().padLeft(2, '0')}';

  @override
  int compareTo(CalendarDate other) {
    if (year != other.year) return year.compareTo(other.year);
    if (month != other.month) return month.compareTo(other.month);
    return day.compareTo(other.day);
  }

  @override
  bool operator ==(Object other) =>
      other is CalendarDate &&
      year == other.year &&
      month == other.month &&
      day == other.day;

  @override
  int get hashCode => Object.hash(year, month, day);

  @override
  String toString() => toIso8601String();
}
