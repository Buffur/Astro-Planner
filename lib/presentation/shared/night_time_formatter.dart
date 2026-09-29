import 'package:flutter/material.dart';

import '../../domain/models/calendar_date.dart';
import '../../domain/models/iana_time_context.dart';

/// The one formatter for night-related times and dates (ADR-007 §6, TASK 2.4):
/// no ad-hoc `.toLocal()` calls elsewhere.
///
/// Since TASK 7.1 an instant is shown in the **site's** IANA zone when the
/// active site has one, otherwise in the device's zone — always labelled
/// ([zoneCaption]) — and respects the device's 12/24-hour setting (via
/// [TimeOfDay.format], which reads `MediaQuery.alwaysUse24HourFormat`).
class NightTimeFormatter {
  const NightTimeFormatter._();

  /// A recorded date with its year, for example "Sep 25, 2026" (S9.7: a
  /// sky-darkness reading's date; never an ISO string on screen).
  static String recordedDate(CalendarDate date) =>
      '${_months[date.month - 1]} ${date.day}, ${date.year}';

  static const _months = [
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

  /// [utcInstant]'s wall-clock fields in the site's IANA zone [zoneId]
  /// when given and known (TASK 7.1), otherwise in the device's zone. The
  /// result's y/m/d h:m fields are the local reading; do not treat it as an
  /// instant.
  static DateTime wallClock(DateTime utcInstant, {String? zoneId}) {
    final ctx = IanaTimeContext.tryCreate(zoneId);
    if (ctx == null) return utcInstant.toLocal();
    return utcInstant.toUtc().add(ctx.offsetAt(utcInstant.toUtc()));
  }

  /// The clock time of [utcInstant] in the site's zone [zoneId] (else the
  /// device's), honoring the device's 12/24-hour setting. No zone label —
  /// see [zoneCaption].
  static String clockTime(
    BuildContext context,
    DateTime utcInstant, {
    String? zoneId,
  }) {
    final w = wallClock(utcInstant, zoneId: zoneId);
    return TimeOfDay(hour: w.hour, minute: w.minute).format(context);
  }

  /// [utcInstant]'s clock time plus a "+1" marker when it falls on a later
  /// local calendar day than [windowStartUtc] (ADR-007 §6: "Times after
  /// midnight carry a next-day marker"), in the site's zone [zoneId] when
  /// given, else the device's.
  static String instant(
    BuildContext context,
    DateTime utcInstant, {
    required DateTime windowStartUtc,
    String? zoneId,
  }) {
    final time = clockTime(context, utcInstant, zoneId: zoneId);
    final s = wallClock(windowStartUtc, zoneId: zoneId);
    final i = wallClock(utcInstant, zoneId: zoneId);
    final dayShift = DateTime.utc(
      i.year,
      i.month,
      i.day,
    ).difference(DateTime.utc(s.year, s.month, s.day)).inDays;
    return dayShift > 0 ? '$time (+$dayShift)' : time;
  }

  /// A one-time caption for a group of times: the site's zone when [zoneId]
  /// is known, for example "site zone Europe/London, BST, UTC+01:00", else
  /// the device zone ("device zone, UTC−07:00"). Offsets are at [utcInstant].
  static String zoneCaption(DateTime utcInstant, {String? zoneId}) {
    final ctx = IanaTimeContext.tryCreate(zoneId);
    if (ctx == null) return deviceZoneCaption(utcInstant);
    final utc = utcInstant.toUtc();
    return 'site zone ${ctx.id}, ${ctx.abbreviationAt(utc)}, '
        '${_utcOffset(ctx.offsetAt(utc))}';
  }

  /// The device zone and its UTC offset at [utcInstant], for example
  /// "device zone, UTC−07:00" (used when a site has no zone).
  static String deviceZoneCaption(DateTime utcInstant) =>
      'device zone, ${_utcOffset(utcInstant.toLocal().timeZoneOffset)}';

  static String _utcOffset(Duration offset) {
    final sign = offset.isNegative ? '−' : '+';
    final abs = offset.abs();
    final hh = abs.inHours.toString().padLeft(2, '0');
    final mm = (abs.inMinutes % 60).toString().padLeft(2, '0');
    return 'UTC$sign$hh:$mm';
  }
}
