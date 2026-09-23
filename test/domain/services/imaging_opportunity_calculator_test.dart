// TASK 10.2 (ADR-013): the imaging-opportunity calculator — the ADR's
// worked examples V1–V12 on synthetic samples (exact), then real-sky edge
// cases (polar night, midnight sun, a target that never rises, a
// circumpolar dip) and agreement with the previous visibility windows.

import 'package:astroplan/domain/models/astro_target.dart';
import 'package:astroplan/domain/models/calendar_date.dart';
import 'package:astroplan/domain/models/imaging_opportunity.dart';
import 'package:astroplan/domain/models/night_weather.dart';
import 'package:astroplan/domain/models/session_night.dart';
import 'package:astroplan/domain/models/site_time_context.dart';
import 'package:astroplan/domain/models/visibility_window.dart';
import 'package:astroplan/domain/models/weather_snapshot.dart';
import 'package:astroplan/domain/services/imaging_opportunity_calculator.dart';
import 'package:astroplan/domain/services/moon_calculator.dart';
import 'package:astroplan/domain/services/session_night_resolver.dart';
import 'package:astroplan/domain/services/visibility_calculator.dart';
import 'package:flutter_test/flutter_test.dart';

typedef Calc = ImagingOpportunityCalculator;

// A synthetic night: 2026-09-24 12:00 UTC to 2026-09-25 12:00 UTC.
final _night = SessionNight(
  eveningDate: CalendarDate(2026, 9, 24),
  startUtc: DateTime.utc(2026, 9, 24, 12),
  endUtc: DateTime.utc(2026, 9, 25, 12),
  latitude: 46.05,
  longitude: 14.51,
  timeContextId: 'test',
);

/// Hour h of the synthetic night (12–23 on the 24th, 0–12 on the 25th).
DateTime _t(int h, [int m = 0]) =>
    h >= 12 ? DateTime.utc(2026, 9, 24, h, m) : DateTime.utc(2026, 9, 25, h, m);

bool _in(DateTime t, DateTime from, DateTime to) =>
    !t.isBefore(from) && t.isBefore(to);

List<double> _series(double Function(DateTime t) f) => [
  for (var i = 0; i < Calc.gridCount; i++) f(Calc.instantAt(_night, i)),
];

// Common inputs (ADR-013 §7): Sun ≤ −18° during [20:00, 04:00); the target
// ≥ 30° during [22:00, 06:00).
final _sun = _series((t) => _in(t, _t(20), _t(4)) ? -20 : 0);
final _target = _series((t) => _in(t, _t(22), _t(6)) ? 40 : 10);

ImagingOpportunity _run({
  List<double>? sun,
  List<double>? target,
  double limit = -18,
  OptionalGates gates = OptionalGates.none,
  OpportunityMoon? moon,
  OpportunityWeather? weather,
}) => Calc.fromSamples(
  night: _night,
  sunAltitudesDeg: sun ?? _sun,
  targetAltitudesDeg: target ?? _target,
  darknessLimitDeg: limit,
  minAltitudeDeg: 30,
  gates: gates,
  moon: moon,
  weather: weather,
);

List<(DateTime, DateTime)> _spans(ImagingOpportunity o) => [
  for (final w in o.windows) (w.startUtc, w.endUtc),
];

ExcludedSegment _segmentAt(ImagingOpportunity o, DateTime t) =>
    o.excluded.firstWhere((s) => _in(t, s.startUtc, s.endUtc));

/// The Moon up during [21:00, 02:00), [illumination] lit, 40° from the
/// target.
OpportunityMoon _moon(double illumination) => OpportunityMoon(
  altitudesDeg: _series((t) => _in(t, _t(21), _t(2)) ? 20 : -10),
  separationsDeg: _series((_) => 40),
  illumination: illumination,
);

OpportunityWeather _weather(List<WeatherHour> hours) => OpportunityWeather(
  snapshot: WeatherSnapshot(
    provider: 'open-meteo',
    model: 'best_match',
    fetchedAtUtc: _t(12),
    latitude: 46.05,
    longitude: 14.51,
    hours: hours,
  ),
  age: WeatherAge.current,
  dewMarginC: 2,
);

// V6: 22:00 20 %, 23:00 70 %, 00:00 no forecast, 01:00–04:00 10 %.
final _v6Hours = [
  WeatherHour(timeUtc: _t(22), cloudCoverPct: 20),
  WeatherHour(timeUtc: _t(23), cloudCoverPct: 70),
  WeatherHour(timeUtc: _t(0)),
  for (final h in [1, 2, 3, 4]) WeatherHour(timeUtc: _t(h), cloudCoverPct: 10),
];

void main() {
  group('ADR-013 worked examples', () {
    test('V1 broadband, Moon down: [22:00, 04:00) with reasons', () {
      final o = _run(
        moon: OpportunityMoon(
          altitudesDeg: _series((_) => -10),
          separationsDeg: _series((_) => 40),
          illumination: 0.5,
        ),
      );
      expect(_spans(o), [(_t(22), _t(4))]);
      expect(o.usableTime, const Duration(hours: 6));
      expect(_segmentAt(o, _t(21)).reasons, {OpportunityGate.altitude});
      expect(_segmentAt(o, _t(5)).reasons, {OpportunityGate.darkness});
      expect(_segmentAt(o, _t(13)).reasons, {
        OpportunityGate.darkness,
        OpportunityGate.altitude,
      }, reason: 'all failing gates are listed');
      expect(o.windows.single.moon!.moonDown, isTrue);
      expect(o.noWindowReason, isNull);
    });

    test('V2 narrowband with the Moon up, gate off: time kept, annotated', () {
      final o = _run(moon: _moon(0.85));
      expect(_spans(o), [(_t(22), _t(4))]);
      final m = o.windows.single.moon!;
      expect(m.upDuration, const Duration(hours: 4));
      expect(m.illumination, 0.85);
      expect(m.minSeparationDeg, 40);
    });

    test('V3 Moon gate on (50 %): the Moon-up time is excluded', () {
      final o = _run(
        moon: _moon(0.85),
        gates: const OptionalGates(moonMinIlluminationPct: 50),
      );
      expect(_spans(o), [(_t(2), _t(4))]);
      expect(_segmentAt(o, _t(23)).reasons, {OpportunityGate.moon});
      expect(_segmentAt(o, _t(21, 30)).reasons, {
        OpportunityGate.altitude,
        OpportunityGate.moon,
      });
    });

    test('V4 Moon gate on, a 30 % Moon: nothing excluded', () {
      final o = _run(
        moon: _moon(0.30),
        gates: const OptionalGates(moonMinIlluminationPct: 50),
      );
      expect(_spans(o), [(_t(22), _t(4))]);
    });

    test('V5 boundary: exactly 50 % lit fails a 50 % Moon gate', () {
      final o = _run(
        moon: _moon(0.50),
        gates: const OptionalGates(moonMinIlluminationPct: 50),
      );
      expect(_spans(o), [(_t(2), _t(4))]);
    });

    test('V6 cloud gate on (50 %): the cloudy hour is excluded, the hour '
        'without forecast is kept', () {
      final o = _run(
        weather: _weather(_v6Hours),
        gates: const OptionalGates(cloudMaxPct: 50),
      );
      expect(_spans(o), [(_t(22), _t(22, 30)), (_t(23, 30), _t(4))]);
      expect(o.usableTime, const Duration(hours: 5));
      expect(_segmentAt(o, _t(23)).reasons, {OpportunityGate.cloud});
      final w = o.windows[1].weather!;
      expect(w.hours, 5); // 00, 01, 02, 03, 04
      expect(w.hoursWithoutForecast, 1);
      expect(w.cloudMinPct, 10);
      expect(w.cloudMaxPct, 10);
    });

    test('V7 cloud gate off: nothing excluded, cloud annotated', () {
      final o = _run(weather: _weather(_v6Hours));
      expect(_spans(o), [(_t(22), _t(4))]);
      final w = o.windows.single.weather!;
      expect(w.cloudMinPct, 10);
      expect(w.cloudMaxPct, 70);
      expect(w.hoursWithoutForecast, 1);
    });

    test('V8/V9 no astronomical darkness; nautical limit gives a window', () {
      final sun = _series((t) => _in(t, _t(23), _t(1)) ? -14 : -5);
      final alwaysUp = _series((_) => 40);
      final astro = _run(sun: sun, target: alwaysUp);
      expect(astro.windows, isEmpty);
      expect(astro.noWindowReason, NoWindowReason.noDarkness);
      expect(astro.excluded.single.reasons, {OpportunityGate.darkness});

      final nautical = _run(sun: sun, target: alwaysUp, limit: -12);
      expect(_spans(nautical), [(_t(23), _t(1))]);
    });

    test('V10 target never high enough', () {
      final o = _run(target: _series((_) => 25));
      expect(o.windows, isEmpty);
      expect(o.noWindowReason, NoWindowReason.targetNeverHighEnough);
      expect(o.maxAltitudeInWindowsDeg, isNull);
    });

    test('V11 dew risk annotates, never excludes', () {
      final o = _run(
        weather: _weather([
          for (final h in [22, 23, 0, 1])
            WeatherHour(timeUtc: _t(h), temperatureC: 12, dewPointC: 5),
          WeatherHour(timeUtc: _t(2), temperatureC: 6, dewPointC: 5),
          WeatherHour(timeUtc: _t(3), temperatureC: 6, dewPointC: 5),
          WeatherHour(timeUtc: _t(4), temperatureC: 10, dewPointC: 5),
        ]),
        gates: const OptionalGates(cloudMaxPct: 50),
      );
      expect(_spans(o), [(_t(22), _t(4))]);
      expect(o.windows.single.weather!.dewRiskHours, 2);
      expect(o.windows.single.weather!.dewKnownHours, 7);
    });

    test('V12 max altitude inside the window, not at daylight culmination', () {
      final target = _series((t) {
        if (t == _t(13)) return 70; // culmination in daylight
        if (t == _t(3)) return 55;
        return _in(t, _t(22), _t(6)) ? 40 : 10;
      });
      final o = _run(target: target);
      expect(o.maxAltitudeInWindowsDeg, 55);
      expect(o.windows.single.maxAltitudeAtUtc, _t(3));
    });
  });

  group('rules', () {
    test('both limits pass at equality', () {
      final o = _run(sun: _series((_) => -18), target: _series((_) => 30));
      expect(_spans(o), [(_night.startUtc, _night.endUtc)]);
      expect(o.windows.single.window.clippedAtStart, isTrue);
      expect(o.windows.single.window.clippedAtEnd, isTrue);
    });

    test('dark time excluded only by optional gates says so', () {
      final o = _run(
        moon: OpportunityMoon(
          altitudesDeg: _series((_) => 30),
          separationsDeg: List.filled(Calc.gridCount, null),
          illumination: 0.9,
        ),
        gates: const OptionalGates(moonMinIlluminationPct: 50),
      );
      expect(o.windows, isEmpty);
      expect(o.noWindowReason, NoWindowReason.excludedByOptionalGates);
    });

    test('never at the same time: high only in daylight', () {
      final o = _run(target: _series((t) => _in(t, _t(12), _t(18)) ? 40 : 0));
      expect(o.noWindowReason, NoWindowReason.targetNeverHighEnoughInDarkness);
    });

    test('missing inputs are missing annotations; an enabled gate without '
        'data excludes nothing', () {
      final o = _run(
        gates: const OptionalGates(moonMinIlluminationPct: 0, cloudMaxPct: 0),
      );
      expect(_spans(o), [(_t(22), _t(4))]);
      expect(o.windows.single.moon, isNull);
      expect(o.windows.single.weather, isNull);
    });

    test('a Moon series on another grid is rejected', () {
      expect(
        () => _run(
          moon: const OpportunityMoon(
            altitudesDeg: [0],
            separationsDeg: [null],
            illumination: 0.5,
          ),
        ),
        throwsArgumentError,
      );
    });
  });

  group('real sky', () {
    SessionNight night(double lat, double lon, CalendarDate date) =>
        SessionNightResolver.forEveningDate(
          date,
          latitude: lat,
          longitude: lon,
          timeContext: MeanSolarTimeContext(lon),
        );

    AstroTarget target(double raDeg, double decDeg) => AstroTarget(
      id: 1,
      catalogId: 'T',
      commonName: 'Test',
      type: 'Galaxy',
      rightAscension: raDeg,
      declination: decDeg,
    );

    ImagingOpportunity calc(
      SessionNight n,
      AstroTarget t, {
      double minAlt = 20,
      SunTrack? sunTrack,
    }) => Calc.calculate(
      night: n,
      target: t,
      darknessLimitDeg: -18,
      minAltitudeDeg: minAlt,
      sunTrack: sunTrack,
    );

    test('agrees with the previous visibility windows (M42, Ljubljana)', () {
      final n = night(46.05, 14.51, CalendarDate(2026, 12, 15));
      final m42 = target(83.82, -5.39);
      final o = calc(n, m42);
      final before = VisibilityCalculator.calculateVisibilityWindowsForNight(
        night: n,
        target: m42,
        minAltitude: 20,
      );
      expect(before, isNotEmpty);
      expect(o.visibilityWindows, before);
    });

    test('polar night: dark all window, circumpolar target — one window '
        'clipped at both ends', () {
      final n = night(85, 0, CalendarDate(2026, 12, 21));
      final o = calc(n, target(0, 60));
      expect(o.windows, hasLength(1));
      final w = o.windows.single.window;
      expect(
        w,
        VisibilityWindow(
          start: n.startUtc,
          end: n.endUtc,
          clippedAtStart: true,
          clippedAtEnd: true,
        ),
      );
      expect(o.excluded, isEmpty);
    });

    test('midnight sun: no darkness', () {
      final n = night(69.65, 18.96, CalendarDate(2026, 6, 21));
      final o = calc(n, target(0, 80));
      expect(o.windows, isEmpty);
      expect(o.noWindowReason, NoWindowReason.noDarkness);
    });

    test('a target that never rises', () {
      final n = night(46.05, 14.51, CalendarDate(2026, 9, 24));
      final o = calc(n, target(0, -60));
      expect(o.noWindowReason, NoWindowReason.targetNeverHighEnough);
      expect(o.samples.every((s) => s.targetAltitudeDeg < 0), isTrue);
    });

    test('a circumpolar dip splits the night around lower culmination', () {
      // RA near the Sun's (September): lower culmination near midnight at
      // 46 − 30 = 16°, below the 20° minimum.
      final n = night(46.05, 14.51, CalendarDate(2026, 9, 24));
      final o = calc(n, target(182, 60));
      expect(o.windows, hasLength(2));
      final gap = o.excluded.firstWhere(
        (s) =>
            s.startUtc == o.windows[0].endUtc &&
            s.endUtc == o.windows[1].startUtc,
      );
      expect(gap.reasons, {OpportunityGate.altitude});
      expect(o.windows.every((w) => w.maxAltitudeDeg >= 20), isTrue);
    });

    test('a shared Sun track gives the same result; another night is '
        'rejected', () {
      final n = night(46.05, 14.51, CalendarDate(2026, 12, 15));
      final track = SunTrack.forNight(n);
      final a = calc(n, target(83.82, -5.39), sunTrack: track);
      final b = calc(n, target(83.82, -5.39));
      expect(a.visibilityWindows, b.visibilityWindows);
      final other = night(46.05, 14.51, CalendarDate(2026, 12, 16));
      expect(
        () => calc(other, target(83.82, -5.39), sunTrack: track),
        throwsArgumentError,
      );
    });

    test('Moon conditions from MoonCalculator plug in on the same grid', () {
      final n = night(46.05, 14.51, CalendarDate(2026, 12, 15));
      final m42 = target(83.82, -5.39);
      final o = Calc.calculate(
        night: n,
        target: m42,
        darknessLimitDeg: -18,
        minAltitudeDeg: 20,
        moon: MoonCalculator.conditionsForNight(n, target: m42),
      );
      expect(o.windows, isNotEmpty);
      expect(o.windows.first.moon, isNotNull);
    });
  });
}
