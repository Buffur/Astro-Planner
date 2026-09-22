import 'package:flutter/material.dart';

import '../../domain/models/calendar_date.dart';

/// The one formatter for night-related times and dates (ADR-007 §6, TASK 2.4):
/// no ad-hoc `.toLocal()` calls elsewhere.
///
/// The site's own time zone is not available before TASK 7.1 — every instant
/// is shown in the **device's** zone, labelled as such, and respects the
/// device's 12/24-hour setting (via [TimeOfDay.format], which reads
/// `MediaQuery.alwaysUse24HourFormat`).
class NightTimeFormatter {
  const NightTimeFormatter._();

  /// A civil evening date, for example "Fri, Sep 25".
  static String eveningDate(CalendarDate date) {
    const weekdays = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    const months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];
    final weekday =
        weekdays[DateTime.utc(date.year, date.month, date.day).weekday - 1];
    return '$weekday, ${months[date.month - 1]} ${date.day}';
  }

  /// The clock time of [utcInstant] in the device's zone, honoring the
  /// device's 12/24-hour setting. No zone label — see [instant] for that.
  static String clockTime(BuildContext context, DateTime utcInstant) {
    return TimeOfDay.fromDateTime(utcInstant.toLocal()).format(context);
  }

  /// [utcInstant]'s clock time plus a "+1" marker when it falls on a later
  /// device-local calendar day than [windowStartUtc] (ADR-007 §6: "Times
  /// after midnight carry a next-day marker").
  static String instant(
    BuildContext context,
    DateTime utcInstant, {
    required DateTime windowStartUtc,
  }) {
    final time = clockTime(context, utcInstant);
    final startLocalDay = windowStartUtc.toLocal();
    final instantLocalDay = utcInstant.toLocal();
    final dayShift =
        DateTime(
              instantLocalDay.year,
              instantLocalDay.month,
              instantLocalDay.day,
            )
            .difference(
              DateTime(
                startLocalDay.year,
                startLocalDay.month,
                startLocalDay.day,
              ),
            )
            .inDays;
    return dayShift > 0 ? '$time (+$dayShift)' : time;
  }

  /// A one-time caption for a group of [instant]/[clockTime] values, naming
  /// the device zone and its current UTC offset, for example
  /// "device zone, UTC−07:00". The site's own zone is not shown as a clock
  /// zone before TASK 7.1 (ADR-007 §6).
  static String deviceZoneCaption(DateTime utcInstant) {
    final offset = utcInstant.toLocal().timeZoneOffset;
    final sign = offset.isNegative ? '−' : '+';
    final abs = offset.abs();
    final hh = abs.inHours.toString().padLeft(2, '0');
    final mm = (abs.inMinutes % 60).toString().padLeft(2, '0');
    return 'device zone, UTC$sign$hh:$mm';
  }
}
