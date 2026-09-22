// Tests for the SessionNight-based VisibilityCalculator API (roadmap
// TASK 2.3, ADR-007 §8-§9).
//
// Covers:
//   - the typed NightTimeline never returns a bare null (SunCrossing /
//     SunNeverBelow / SunAlwaysBelow), including the ADR-007 polar cases
//     (T13 midnight sun, T14 polar night, T15 no astronomical darkness)
//   - the new SessionNight-based windows/timeline agree numerically with
//     the legacy DateTime-based wrappers for a normal night
//   - a visibility window that touches the SessionNight boundary in polar
//     night is flagged clippedAtStart/clippedAtEnd
//   - the altitude curve samples the shared 5-minute grid, inclusive of
//     both ends, and agrees with the timeline on the darkness crossing

import 'package:flutter_test/flutter_test.dart';
import 'package:astroplan/domain/models/astro_target.dart';
import 'package:astroplan/domain/models/calendar_date.dart';
import 'package:astroplan/domain/models/night_timeline.dart';
import 'package:astroplan/domain/models/site_time_context.dart';
import 'package:astroplan/domain/services/session_night_resolver.dart';
import 'package:astroplan/domain/services/visibility_calculator.dart';

import '../../support/dst_time_context.dart';

const _pleiades = AstroTarget(
  id: 1,
  catalogId: 'M45',
  type: 'Open Cluster',
  rightAscension: 56.87,
  declination: 24.11,
);

void main() {
  group('calculateNightTimelineForNight (TASK 2.3, ADR-007 §8)', () {
    test('T15-style: London midsummer has no astronomical darkness', () {
      final night = SessionNightResolver.forEveningDate(
        CalendarDate(2026, 6, 20),
        latitude: 51.5074,
        longitude: -0.1278,
        timeContext: DstTimeContext.london,
      );
      final timeline = VisibilityCalculator.calculateNightTimelineForNight(
        night,
      );

      expect(timeline.astronomicalTwilight, isA<SunNeverBelow>());
      expect(timeline.sunriseSunset, isA<SunCrossing>());
      final sunriseSunset = timeline.sunriseSunset as SunCrossing;
      expect(sunriseSunset.duskUtc, isNotNull);
      expect(sunriseSunset.dawnUtc, isNotNull);
    });

    test('T13-style: Tromsø midsummer has midnight sun', () {
      final night = SessionNightResolver.forEveningDate(
        CalendarDate(2026, 6, 20),
        latitude: 69.6492,
        longitude: 18.9553,
        timeContext: DstTimeContext.oslo,
      );
      final timeline = VisibilityCalculator.calculateNightTimelineForNight(
        night,
      );

      expect(timeline.sunriseSunset, isA<SunNeverBelow>());
      expect(timeline.astronomicalTwilight, isA<SunNeverBelow>());
    });

    test('T14-style: Tromsø midwinter has polar night, with a separate '
        'astronomical-twilight crossing', () {
      final night = SessionNightResolver.forEveningDate(
        CalendarDate(2026, 12, 20),
        latitude: 69.6492,
        longitude: 18.9553,
        timeContext: DstTimeContext.oslo,
      );
      final timeline = VisibilityCalculator.calculateNightTimelineForNight(
        night,
      );

      expect(timeline.sunriseSunset, isA<SunAlwaysBelow>());
      expect(timeline.astronomicalTwilight, isA<SunCrossing>());
      final astro = timeline.astronomicalTwilight as SunCrossing;
      expect(astro.duskUtc, isNotNull);
      expect(astro.dawnUtc, isNotNull);
      expect(astro.belowAtStart, isFalse);
      expect(astro.belowAtEnd, isFalse);
    });

    test('a normal night: typed crossings agree with the legacy wrapper', () {
      final night = SessionNightResolver.forEveningDate(
        CalendarDate(2025, 12, 21),
        latitude: 51.5072,
        longitude: -0.1276,
        timeContext: MeanSolarTimeContext(-0.1276),
      );
      final timeline = VisibilityCalculator.calculateNightTimelineForNight(
        night,
      );
      final legacy = VisibilityCalculator.calculateNightTimeline(
        DateTime.utc(2025, 12, 21),
        51.5072,
        -0.1276,
      );

      final sunset = timeline.sunriseSunset as SunCrossing;
      expect(sunset.duskUtc, legacy['sunset']);
      expect(sunset.dawnUtc, legacy['sunrise']);

      final astro = timeline.astronomicalTwilight as SunCrossing;
      expect(astro.duskUtc, legacy['astroDusk']);
      expect(astro.dawnUtc, legacy['astroDawn']);
    });
  });

  group('calculateVisibilityWindowsForNight (TASK 2.3, ADR-007 §9)', () {
    test('agrees with the legacy wrapper for a normal London winter night', () {
      final night = SessionNightResolver.forEveningDate(
        CalendarDate(2025, 12, 21),
        latitude: 51.5072,
        longitude: -0.1276,
        timeContext: MeanSolarTimeContext(-0.1276),
      );
      final windows = VisibilityCalculator.calculateVisibilityWindowsForNight(
        night: night,
        target: _pleiades,
        minAltitude: 20.0,
      );
      final legacy = VisibilityCalculator.calculateVisibilityWindows(
        date: DateTime.utc(2025, 12, 21),
        latitude: 51.5072,
        longitude: -0.1276,
        target: _pleiades,
        minAltitude: 20.0,
      );

      expect(windows.length, legacy.length);
      for (var i = 0; i < windows.length; i++) {
        expect(windows[i].start, legacy[i].start);
        expect(windows[i].end, legacy[i].end);
        expect(windows[i].clippedAtStart, isFalse);
        expect(windows[i].clippedAtEnd, isFalse);
      }
    });

    test('a window spanning the whole night in polar night is flagged '
        'clipped at both ends', () {
      // Tromsø midwinter (T14): the Sun stays below the horizon
      // (-0.833°) for the entire window, so darkness itself touches
      // both boundaries.
      final night = SessionNightResolver.forEveningDate(
        CalendarDate(2026, 12, 20),
        latitude: 69.6492,
        longitude: 18.9553,
        timeContext: DstTimeContext.oslo,
      );
      // Circumpolar from this latitude at this declination: altitude
      // stays roughly 68-71° all night, always above minAltitude.
      const circumpolarTarget = AstroTarget(
        id: 2,
        catalogId: 'Test',
        type: 'Test',
        rightAscension: 0.0,
        declination: 89.0,
      );
      final windows = VisibilityCalculator.calculateVisibilityWindowsForNight(
        night: night,
        target: circumpolarTarget,
        minAltitude: 20.0,
        darknessLimitDeg: -0.833,
      );

      expect(windows.length, 1);
      expect(windows.single.start, night.startUtc);
      expect(windows.single.end, night.endUtc);
      expect(windows.single.clippedAtStart, isTrue);
      expect(windows.single.clippedAtEnd, isTrue);
    });

    test('the legacy DateTime-based wrapper can also report a clipped window '
        '(clipping depends on the astronomy, not the time context)', () {
      const circumpolarTarget = AstroTarget(
        id: 2,
        catalogId: 'Test',
        type: 'Test',
        rightAscension: 0.0,
        declination: 89.0,
      );
      final windows = VisibilityCalculator.calculateVisibilityWindows(
        date: DateTime.utc(2026, 12, 20),
        latitude: 69.6492,
        longitude: 18.9553,
        target: circumpolarTarget,
        minAltitude: 20.0,
        sunAltitudeThreshold: -0.833,
      );

      expect(windows.length, 1);
      expect(windows.single.clippedAtStart, isTrue);
      expect(windows.single.clippedAtEnd, isTrue);
    });
  });

  group('calculateAltitudeCurve (TASK 2.3, ADR-007 §9)', () {
    test('samples the shared 5-minute grid, anchored at startUtc, inclusive '
        'of endUtc', () {
      final night = SessionNightResolver.forEveningDate(
        CalendarDate(2025, 12, 21),
        latitude: 51.5072,
        longitude: -0.1276,
        timeContext: MeanSolarTimeContext(-0.1276),
      );
      final curve = VisibilityCalculator.calculateAltitudeCurve(
        night: night,
        target: _pleiades,
      );

      expect(curve.samples.length, 289); // 24h / 5min + 1
      expect(curve.samples.first.instantUtc, night.startUtc);
      expect(curve.samples.last.instantUtc, night.endUtc);
      for (var i = 1; i < curve.samples.length; i++) {
        expect(
          curve.samples[i].instantUtc.difference(
            curve.samples[i - 1].instantUtc,
          ),
          const Duration(minutes: 5),
        );
      }
    });

    test('agrees with the night timeline on the darkness crossing', () {
      final night = SessionNightResolver.forEveningDate(
        CalendarDate(2025, 12, 21),
        latitude: 51.5072,
        longitude: -0.1276,
        timeContext: MeanSolarTimeContext(-0.1276),
      );
      final timeline = VisibilityCalculator.calculateNightTimelineForNight(
        night,
      );
      final curve = VisibilityCalculator.calculateAltitudeCurve(
        night: night,
        target: _pleiades,
      );

      final astroDusk = (timeline.astronomicalTwilight as SunCrossing).duskUtc!;
      final sampleAtDusk = curve.samples.firstWhere(
        (s) => s.instantUtc == astroDusk,
      );
      expect(sampleAtDusk.sunAltitudeDeg, closeTo(-18.0, 0.5));
    });
  });
}
