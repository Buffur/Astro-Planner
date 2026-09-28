// S6.5 (TD-051, CALC-41): the dark span at the user's darkness limit. It is
// the span the imaging opportunity counts as dark — the same 5-minute grid,
// the same Sun — at −18°, −15° and −12°, and at −18° it is astronomical
// twilight. Reference vectors on fixed nights, including one with no
// darkness at all.

import 'package:astroplan/domain/models/calendar_date.dart';
import 'package:astroplan/domain/models/night_timeline.dart';
import 'package:astroplan/domain/models/session_night.dart';
import 'package:astroplan/domain/models/site_time_context.dart';
import 'package:astroplan/domain/services/imaging_opportunity_calculator.dart';
import 'package:astroplan/domain/services/session_night_resolver.dart';
import 'package:astroplan/domain/services/visibility_calculator.dart';
import 'package:flutter_test/flutter_test.dart';

SessionNight _night(int y, int m, int d, double lat, double lon) =>
    SessionNightResolver.forEveningDate(
      CalendarDate(y, m, d),
      latitude: lat,
      longitude: lon,
      timeContext: MeanSolarTimeContext(lon),
    );

/// The opportunity's dark instants: grid samples with the Sun at or below
/// [limit] (the darkness gate fails only above it).
List<int> _darkSamples(SessionNight night, double limit) {
  final sun = SunTrack.forNight(night).altitudesDeg;
  return [
    for (var i = 0; i < sun.length; i++)
      if (sun[i] <= limit) i,
  ];
}

void main() {
  final ljubljana = _night(2026, 11, 10, 46.05, 14.51);

  for (final limit in [-18.0, -15.0, -12.0]) {
    test('Ljubljana, 10 Nov 2026, $limit°: the span is the opportunity\'s '
        'dark samples', () {
      final dark = VisibilityCalculator.calculateNightTimelineForNight(
        ljubljana,
        darknessLimitDeg: limit,
      ).darkAtLimit!;
      expect(dark.thresholdDeg, limit);
      final samples = _darkSamples(ljubljana, limit);
      expect(samples, isNotEmpty);
      // One contiguous dark span on a normal night.
      expect(samples.last - samples.first + 1, samples.length);
      dark as SunCrossing;
      expect(
        dark.duskUtc,
        ImagingOpportunityCalculator.instantAt(ljubljana, samples.first),
      );
      expect(
        dark.dawnUtc,
        ImagingOpportunityCalculator.instantAt(ljubljana, samples.last + 1),
      );
    });
  }

  test('at −18° it is astronomical twilight; at −12°, nautical', () {
    SunCrossing at(double limit) =>
        VisibilityCalculator.calculateNightTimelineForNight(
              ljubljana,
              darknessLimitDeg: limit,
            ).darkAtLimit!
            as SunCrossing;
    final timeline = VisibilityCalculator.calculateNightTimelineForNight(
      ljubljana,
    );
    final astro = timeline.astronomicalTwilight as SunCrossing;
    final nautical = timeline.nauticalTwilight as SunCrossing;
    expect((at(-18).duskUtc, at(-18).dawnUtc), (astro.duskUtc, astro.dawnUtc));
    expect(
      (at(-12).duskUtc, at(-12).dawnUtc),
      (nautical.duskUtc, nautical.dawnUtc),
    );
    // −15° lies between them.
    expect(at(-15).duskUtc!.isAfter(nautical.duskUtc!), isTrue);
    expect(at(-15).duskUtc!.isBefore(astro.duskUtc!), isTrue);
    expect(timeline.darkAtLimit, isNull, reason: 'built without a limit');
  });

  test('a midsummer night at 60° N has no darkness at −18°, like the '
      'opportunity', () {
    final june = _night(2026, 6, 21, 60.0, 10.0);
    final dark = VisibilityCalculator.calculateNightTimelineForNight(
      june,
      darknessLimitDeg: -18,
    ).darkAtLimit;
    expect(dark, isA<SunNeverBelow>());
    expect(_darkSamples(june, -18), isEmpty);
  });
}
