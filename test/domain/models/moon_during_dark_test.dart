// S6.13 (UX-17; CALC-43): the Moon during the dark span at the user's
// limit, counted on the night's 5-minute grid as the imaging windows' Moon
// note is: the dark samples, and those with the Moon above the horizon.
// Synthetic Moon altitudes make every expectation exact.

import 'package:astroplan/domain/models/calendar_date.dart';
import 'package:astroplan/domain/models/moon_conditions.dart';
import 'package:astroplan/domain/models/night_timeline.dart';
import 'package:astroplan/domain/models/site_time_context.dart';
import 'package:astroplan/domain/services/moon_calculator.dart';
import 'package:astroplan/domain/services/session_night_resolver.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  final night = SessionNightResolver.forEveningDate(
    CalendarDate(2026, 11, 10),
    latitude: 46.05,
    longitude: 14.51,
    timeContext: MeanSolarTimeContext(14.51),
  );
  const step = Duration(minutes: 5);
  DateTime at(Duration d) => night.startUtc.add(d);

  /// The Moon above the horizon from [upFrom] to [upTo] after the start.
  MoonConditions moon({Duration? upFrom, Duration? upTo}) => MoonConditions(
    night: night,
    samples: [
      for (var i = 0; i <= 288; i++)
        MoonSample(
          instantUtc: at(step * i),
          altitudeDeg:
              upFrom != null &&
                  upTo != null &&
                  step * i >= upFrom &&
                  step * i < upTo
              ? 20
              : -20,
          separationDeg: null,
          targetAltitudeDeg: null,
        ),
    ],
    riseSet: const MoonRiseSet(events: [], aboveAtStart: false),
    illuminationAtMidnight: 0.42,
    closestApproachWhileBothUp: null,
  );

  // Dark from 6 h to 18 h after the night's start (noon): 12 h.
  final dark = SunCrossing(
    -18,
    duskUtc: at(const Duration(hours: 6)),
    dawnUtc: at(const Duration(hours: 18)),
  );

  test('partly: the Moon\'s time within the dark span', () {
    final m = moon(
      upFrom: const Duration(hours: 10),
      upTo: const Duration(hours: 22), // sets after dawn
    ).duringDark(dark)!;
    expect(m.dark, const Duration(hours: 12));
    expect(m.moonUp, const Duration(hours: 8));
    expect(m.moonDown, isFalse);
    expect(m.upAllDark, isFalse);
    expect(m.illumination, 0.42);
  });

  test('down while dark, even when up in daylight', () {
    final m = moon(
      upFrom: const Duration(hours: 0),
      upTo: const Duration(hours: 5),
    ).duringDark(dark)!;
    expect(m.moonUp, Duration.zero);
    expect(m.moonDown, isTrue);
  });

  test('up all the dark time', () {
    final m = moon(
      upFrom: const Duration(hours: 4),
      upTo: const Duration(hours: 20),
    ).duringDark(dark)!;
    expect(m.upAllDark, isTrue);
    expect(m.moonUp, m.dark);
  });

  test('no dark span: nothing to say', () {
    expect(moon().duringDark(const SunNeverBelow(-18)), isNull);
  });

  test('dark all night: the whole grid, without the end instant', () {
    final m = moon().duringDark(const SunAlwaysBelow(-18))!;
    expect(m.dark, const Duration(hours: 24));
  });

  test('dark at the start and again later: both parts count', () {
    // Below the limit until 2 h, and again from 20 h to the end.
    final split = SunCrossing(
      -18,
      duskUtc: at(const Duration(hours: 20)),
      dawnUtc: at(const Duration(hours: 2)),
      belowAtStart: true,
      belowAtEnd: true,
    );
    final m = moon(
      upFrom: const Duration(hours: 1),
      upTo: const Duration(hours: 21),
    ).duringDark(split)!;
    expect(m.dark, const Duration(hours: 6));
    expect(m.moonUp, const Duration(hours: 2)); // 1 h + 1 h
  });
}
