// TASK 7.1: the formatter prefers the site's IANA zone, and labels it.

import 'package:astroplan/domain/models/calendar_date.dart';
import 'package:astroplan/presentation/shared/night_time_formatter.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('wallClock converts through the site zone, DST-aware', () {
    final utc = DateTime.utc(2026, 7, 1, 21, 30);
    final london = NightTimeFormatter.wallClock(utc, zoneId: 'Europe/London');
    expect((london.hour, london.minute), (22, 30)); // BST, UTC+1
    final tokyo = NightTimeFormatter.wallClock(utc, zoneId: 'Asia/Tokyo');
    expect((tokyo.day, tokyo.hour), (2, 6)); // next day 06:30, UTC+9
    final winter = NightTimeFormatter.wallClock(
      DateTime.utc(2026, 12, 1, 21, 30),
      zoneId: 'Europe/London',
    );
    expect(winter.hour, 21); // GMT
  });

  test('zoneCaption names the site zone, abbreviation and offset', () {
    expect(
      NightTimeFormatter.zoneCaption(
        DateTime.utc(2026, 7, 1, 21),
        zoneId: 'Europe/London',
      ),
      'site zone Europe/London, BST, UTC+01:00',
    );
    expect(
      NightTimeFormatter.zoneCaption(
        DateTime.utc(2026, 9, 22, 6),
        zoneId: 'Pacific/Kiritimati',
      ),
      'site zone Pacific/Kiritimati, +14, UTC+14:00',
    );
  });

  test('without a (known) zone it falls back to the labelled device zone', () {
    final utc = DateTime.utc(2026, 7, 1, 21);
    expect(
      NightTimeFormatter.zoneCaption(utc),
      NightTimeFormatter.deviceZoneCaption(utc),
    );
    expect(
      NightTimeFormatter.zoneCaption(utc, zoneId: 'Not/AZone'),
      startsWith('device zone, UTC'),
    );
  });

  testWidgets('instant marks the next day in the site zone', (tester) async {
    late String text;
    await tester.pumpWidget(
      MaterialApp(
        home: MediaQuery(
          data: const MediaQueryData(alwaysUse24HourFormat: true),
          child: Builder(
            builder: (context) {
              text = NightTimeFormatter.instant(
                context,
                DateTime.utc(2026, 9, 22, 16), // 01:00 Sep 23 in Tokyo
                windowStartUtc: DateTime.utc(2026, 9, 22, 2, 41), // 11:41
                zoneId: 'Asia/Tokyo',
              );
              return const SizedBox.shrink();
            },
          ),
        ),
      ),
    );
    expect(text, '01:00 (+1)');
  });

  // S9.7: a recorded date (a sky-darkness reading's) reads with its year,
  // never as an ISO string.
  test('a recorded date: month, day and year', () {
    expect(
      NightTimeFormatter.recordedDate(CalendarDate(2026, 8, 1)),
      'Aug 1, 2026',
    );
    expect(
      NightTimeFormatter.recordedDate(CalendarDate(2025, 12, 31)),
      'Dec 31, 2025',
    );
  });
}
