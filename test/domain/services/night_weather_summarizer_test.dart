// TASK 9.4 (ADR-012 §3–§5): the night's weather summary is a pure function —
// sliced to sunset..sunrise, per-hour slots with "no forecast" gaps, ranges
// over the covered hours only, and the dew-spread heuristic against the
// configured margin.

import 'package:astroplan/domain/models/calendar_date.dart';
import 'package:astroplan/domain/models/night_timeline.dart';
import 'package:astroplan/domain/models/night_weather_summary.dart';
import 'package:astroplan/domain/models/session_night.dart';
import 'package:astroplan/domain/models/site_time_context.dart';
import 'package:astroplan/domain/models/weather_snapshot.dart';
import 'package:astroplan/domain/services/night_weather_summarizer.dart';
import 'package:astroplan/domain/services/session_night_resolver.dart';
import 'package:astroplan/domain/services/visibility_calculator.dart';
import 'package:flutter_test/flutter_test.dart';

WeatherSnapshot _snapshot(List<WeatherHour> hours) => WeatherSnapshot(
  provider: 'open-meteo',
  model: 'best_match',
  fetchedAtUtc: DateTime.utc(2026, 9, 24, 12),
  latitude: 46.05,
  longitude: 14.51,
  hours: hours,
);

DateTime _h(int day, int hour) => DateTime.utc(2026, 9, day, hour);

final _night = SessionNight(
  eveningDate: CalendarDate(2026, 9, 24),
  startUtc: _h(24, 11),
  endUtc: _h(25, 11),
  latitude: 46.05,
  longitude: 14.51,
  timeContextId: 'test',
);

NightTimeline _timeline(SunThresholdResult sunriseSunset) => NightTimeline(
  night: _night,
  sunriseSunset: sunriseSunset,
  civilTwilight: const SunNeverBelow(-6),
  nauticalTwilight: const SunNeverBelow(-12),
  astronomicalTwilight: const SunNeverBelow(-18),
);

void main() {
  group('summarize', () {
    test('slots cover every hour overlapping the interval, in UTC', () {
      final s = NightWeatherSummarizer.summarize(
        _snapshot(const []),
        fromUtc: DateTime.utc(2026, 9, 24, 17, 20), // sunset 17:20
        toUtc: DateTime.utc(2026, 9, 25, 5, 10), // sunrise 05:10
        dewMarginC: 2,
      );
      expect(s.slots.first.timeUtc, _h(24, 17));
      expect(s.slots.last.timeUtc, _h(25, 5));
      expect(s.totalHours, 13);
      expect(s.slots.every((x) => x.timeUtc.isUtc), isTrue);
    });

    test('ranges use only covered hours inside the night; missing values '
        'are ignored, never 0', () {
      final s = NightWeatherSummarizer.summarize(
        _snapshot([
          WeatherHour(timeUtc: _h(24, 16), cloudCoverPct: 100), // before
          WeatherHour(
            timeUtc: _h(24, 18),
            cloudCoverPct: 40,
            windSpeedKmh: 12,
            visibilityM: 24000,
          ),
          WeatherHour(timeUtc: _h(24, 19), cloudCoverPct: 10),
          WeatherHour(timeUtc: _h(24, 20), cloudCoverPct: 25),
          WeatherHour(timeUtc: _h(24, 22), cloudCoverPct: 90), // after
        ]),
        fromUtc: _h(24, 18),
        toUtc: _h(24, 21),
        dewMarginC: 2,
      );
      expect(s.totalHours, 3);
      expect(s.coveredHours, 3);
      expect(s.cloudCover!.min, 10);
      expect(s.cloudCover!.max, 40);
      expect(s.windSpeed!.min, 12);
      expect(s.windSpeed!.max, 12);
      expect(s.visibility!.max, 24000);
      expect(s.precipitationProbability, isNull, reason: 'unknown, not 0');
      expect(s.cloudCoverHigh, isNull);
    });

    test('hours the snapshot lacks are "no forecast" (partial coverage)', () {
      final s = NightWeatherSummarizer.summarize(
        _snapshot([WeatherHour(timeUtc: _h(24, 18), cloudCoverPct: 5)]),
        fromUtc: _h(24, 18),
        toUtc: _h(24, 21),
        dewMarginC: 2,
      );
      expect(s.coveredHours, 1);
      expect(s.slots[1].hour, isNull);
      expect(s.slots[2].hour, isNull);
      expect(s.cloudCover!.min, 5);
    });

    test('dew spread is flagged at or below the margin, unknown without '
        'both values', () {
      final s = NightWeatherSummarizer.summarize(
        _snapshot([
          WeatherHour(timeUtc: _h(24, 18), temperatureC: 10, dewPointC: 7),
          WeatherHour(timeUtc: _h(24, 19), temperatureC: 9, dewPointC: 7),
          WeatherHour(timeUtc: _h(24, 20), temperatureC: 8.5, dewPointC: 7),
          WeatherHour(timeUtc: _h(24, 21), temperatureC: 8),
        ]),
        fromUtc: _h(24, 18),
        toUtc: _h(24, 22),
        dewMarginC: 2,
      );
      expect(s.slots.map((x) => x.dewSpreadC), [3, 2, 1.5, null]);
      expect(s.slots.map((x) => x.dewRisk), [false, true, true, null]);
      expect(s.dewKnownHours, 3);
      expect(s.dewRiskHours, 2);
      expect(s.dewSpread!.min, 1.5);
      expect(s.dewSpread!.max, 3);
      expect(s.dewMarginC, 2);
    });

    test('the margin is the configured one', () {
      final snap = _snapshot([
        WeatherHour(timeUtc: _h(24, 18), temperatureC: 10, dewPointC: 7),
      ]);
      bool? risk(double margin) => NightWeatherSummarizer.summarize(
        snap,
        fromUtc: _h(24, 18),
        toUtc: _h(24, 19),
        dewMarginC: margin,
      ).slots.single.dewRisk;
      expect(risk(2), isFalse);
      expect(risk(3), isTrue);
    });
  });

  group('spanOf (sunset to sunrise)', () {
    test('a normal night runs from sunset to sunrise', () {
      final span = NightWeatherSummarizer.spanOf(
        _timeline(
          SunCrossing(
            -0.833,
            duskUtc: DateTime.utc(2026, 9, 24, 17, 5),
            dawnUtc: DateTime.utc(2026, 9, 25, 4, 55),
          ),
        ),
      );
      expect(span.fromUtc, DateTime.utc(2026, 9, 24, 17, 5));
      expect(span.toUtc, DateTime.utc(2026, 9, 25, 4, 55));
      expect(span.span, NightWeatherSpan.sunsetToSunrise);
    });

    test('a missing sunset or sunrise falls back to the window edge', () {
      final span = NightWeatherSummarizer.spanOf(
        _timeline(
          SunCrossing(
            -0.833,
            dawnUtc: DateTime.utc(2026, 9, 25, 4),
            belowAtStart: true,
          ),
        ),
      );
      expect(span.fromUtc, _night.startUtc);
      expect(span.toUtc, DateTime.utc(2026, 9, 25, 4));
    });

    test('midnight sun and polar night show the whole window, labelled', () {
      final sun = NightWeatherSummarizer.spanOf(
        _timeline(const SunNeverBelow(-0.833)),
      );
      expect(sun.span, NightWeatherSpan.midnightSun);
      expect(sun.fromUtc, _night.startUtc);
      expect(sun.toUtc, _night.endUtc);
      final dark = NightWeatherSummarizer.spanOf(
        _timeline(const SunAlwaysBelow(-0.833)),
      );
      expect(dark.span, NightWeatherSpan.polarNight);
      expect(dark.toUtc.difference(dark.fromUtc), const Duration(hours: 24));
    });

    test('a real night: Ljubljana on 2026-09-24 is about 17:00-05:00 UTC', () {
      final night = SessionNightResolver.forEveningDate(
        CalendarDate(2026, 9, 24),
        latitude: 46.05,
        longitude: 14.51,
        timeContext: MeanSolarTimeContext(14.51),
      );
      final span = NightWeatherSummarizer.spanOf(
        VisibilityCalculator.calculateNightTimelineForNight(night),
      );
      expect(span.span, NightWeatherSpan.sunsetToSunrise);
      expect(span.fromUtc.day, 24);
      expect(span.fromUtc.hour, anyOf(16, 17));
      expect(span.toUtc.day, 25);
      expect(span.toUtc.hour, anyOf(4, 5));
    });
  });

  // Acceptance: a night 5 days ahead shows its own hours, or "no forecast".
  test('a night 5 days ahead shows its own hours, or no forecast', () {
    final ahead = SessionNightResolver.forEveningDate(
      CalendarDate(2026, 9, 29),
      latitude: 46.05,
      longitude: 14.51,
      timeContext: MeanSolarTimeContext(14.51),
    );
    final span = NightWeatherSummarizer.spanOf(
      VisibilityCalculator.calculateNightTimelineForNight(ahead),
    );
    final first = DateTime.utc(
      span.fromUtc.year,
      span.fromUtc.month,
      span.fromUtc.day,
      span.fromUtc.hour,
    );

    NightWeatherSummary summarize(List<WeatherHour> hours) =>
        NightWeatherSummarizer.summarize(
          _snapshot(hours),
          fromUtc: span.fromUtc,
          toUtc: span.toUtc,
          dewMarginC: 2,
        );

    final own = summarize([
      for (
        var t = first;
        t.isBefore(span.toUtc);
        t = t.add(const Duration(hours: 1))
      )
        WeatherHour(timeUtc: t, cloudCoverPct: 30),
    ]);
    expect(own.slots.first.timeUtc, first);
    expect(own.slots.first.timeUtc.day, 29);
    expect(own.coveredHours, own.totalHours);

    // Today's hours (another night) never stand in for that night.
    final other = summarize([
      WeatherHour(timeUtc: DateTime.utc(2026, 9, 24, 20), cloudCoverPct: 0),
    ]);
    expect(other.coveredHours, 0);
    expect(other.cloudCover, isNull);
  });
}
