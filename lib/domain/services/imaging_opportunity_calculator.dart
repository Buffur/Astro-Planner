import '../models/astro_target.dart';
import '../models/imaging_opportunity.dart';
import '../models/moon_conditions.dart';
import '../models/night_weather.dart';
import '../models/session_night.dart';
import '../models/sky_darkness.dart';
import '../models/visibility_window.dart';
import '../models/weather_snapshot.dart';
import 'visibility_calculator.dart';

/// The Sun's altitude on one night's 5-minute grid, computed once and shared
/// by every target of that night (TASK 10.2 (f)).
class SunTrack {
  const SunTrack._(this.night, this.altitudesDeg);

  factory SunTrack.forNight(SessionNight night) => SunTrack._(night, [
    for (var i = 0; i < ImagingOpportunityCalculator.gridCount; i++)
      VisibilityCalculator.calculateSunAltitude(
        ImagingOpportunityCalculator.instantAt(night, i),
        night.latitude,
        night.longitude,
      ),
  ]);

  final SessionNight night;

  /// Geometric (airless) Sun altitude per grid instant, degrees.
  final List<double> altitudesDeg;
}

/// The Moon on the night's grid, as the calculator needs it.
class OpportunityMoon {
  const OpportunityMoon({
    required this.altitudesDeg,
    required this.separationsDeg,
    required this.illumination,
  });

  /// From [MoonCalculator.conditionsForNight] (same grid, same night).
  factory OpportunityMoon.fromConditions(MoonConditions c) => OpportunityMoon(
    altitudesDeg: [for (final s in c.samples) s.altitudeDeg],
    separationsDeg: [for (final s in c.samples) s.separationDeg],
    illumination: c.illuminationAtMidnight,
  );

  /// Topocentric airless altitude of the Moon's centre per grid instant.
  final List<double> altitudesDeg;

  /// Moon–target separation per grid instant, degrees (null = unknown).
  final List<double?> separationsDeg;

  /// Illuminated fraction 0–1 at mean solar midnight (ADR-013 §2).
  final double illumination;
}

/// The chosen night's forecast, as the calculator needs it.
class OpportunityWeather {
  const OpportunityWeather({
    required this.snapshot,
    required this.age,
    required this.dewMarginC,
  });

  final WeatherSnapshot snapshot;
  final WeatherAge age;

  /// `PlanningPreferences.dewMarginC`, °C.
  final double dewMarginC;
}

/// When and why a target can be imaged during one night (ADR-013; TASK
/// 10.2): gates per grid instant, windows with annotations, reasons for the
/// excluded time, and no score. Pure and deterministic.
///
/// Grid: `night.startUtc + i · 5 min` for i = 0 … 288 (inclusive of
/// `night.endUtc`, ADR-007 §9). Sample i's state holds for
/// `[t_i, t_{i+1})`; the last sample only decides whether a window reaching
/// the end of the night is clipped there.
abstract final class ImagingOpportunityCalculator {
  static const Duration step = VisibilityCalculator.sampleStep;

  /// Grid instants per night, both ends included.
  static final int gridCount =
      SessionNight.length.inMilliseconds ~/ step.inMilliseconds + 1;

  static DateTime instantAt(SessionNight night, int i) =>
      night.startUtc.add(step * i);

  /// Computes the target's altitudes (J2000 → date, airless; CALC-07/27)
  /// and delegates to [fromSamples]. Pass [sunTrack] to reuse one night's
  /// Sun samples across targets, [moon] (for this night and target) and
  /// [weather] for annotations and the optional gates. A missing input is a
  /// missing annotation, never a zero (SI-008).
  static ImagingOpportunity calculate({
    required SessionNight night,
    required AstroTarget target,
    required double darknessLimitDeg,
    required double minAltitudeDeg,
    SunTrack? sunTrack,
    OptionalGates gates = OptionalGates.none,
    MoonConditions? moon,
    OpportunityWeather? weather,
    SkyDarkness? skyDarkness,
  }) {
    final sun = sunTrack ?? SunTrack.forNight(night);
    if (sun.night != night) {
      throw ArgumentError('sunTrack belongs to another night');
    }
    return fromSamples(
      night: night,
      sunAltitudesDeg: sun.altitudesDeg,
      targetAltitudesDeg: [
        for (var i = 0; i < gridCount; i++)
          VisibilityCalculator.calculateTargetAltitude(
            target,
            instantAt(night, i),
            night.latitude,
            night.longitude,
          ),
      ],
      darknessLimitDeg: darknessLimitDeg,
      minAltitudeDeg: minAltitudeDeg,
      gates: gates,
      moon: moon == null ? null : OpportunityMoon.fromConditions(moon),
      weather: weather,
      skyDarkness: skyDarkness,
    );
  }

  /// The calculator proper, on already-sampled altitudes (one value per
  /// grid instant). Boundaries are inclusive in the passing direction
  /// (ADR-013 §2): Sun = limit passes, altitude = minimum passes, cloud = Y
  /// passes, illumination = X fails the Moon gate.
  static ImagingOpportunity fromSamples({
    required SessionNight night,
    required List<double> sunAltitudesDeg,
    required List<double> targetAltitudesDeg,
    required double darknessLimitDeg,
    required double minAltitudeDeg,
    OptionalGates gates = OptionalGates.none,
    OpportunityMoon? moon,
    OpportunityWeather? weather,
    SkyDarkness? skyDarkness,
  }) {
    final n = gridCount;
    if (sunAltitudesDeg.length != n || targetAltitudesDeg.length != n) {
      throw ArgumentError('expected $n samples per night');
    }
    if (moon != null &&
        (moon.altitudesDeg.length != n || moon.separationsDeg.length != n)) {
      throw ArgumentError('Moon samples must be on the same $n-point grid');
    }

    final hours = <int, WeatherHour>{
      if (weather != null)
        for (final h in weather.snapshot.hours)
          h.timeUtc.toUtc().millisecondsSinceEpoch: h,
    };
    final moonGate = gates.moonMinIlluminationPct;
    final cloudGate = gates.cloudMaxPct;

    final samples = <OpportunitySample>[];
    for (var i = 0; i < n; i++) {
      final t = instantAt(night, i);
      final failing = <OpportunityGate>{};
      if (sunAltitudesDeg[i] > darknessLimitDeg) {
        failing.add(OpportunityGate.darkness);
      }
      if (targetAltitudesDeg[i] < minAltitudeDeg) {
        failing.add(OpportunityGate.altitude);
      }
      // Unknown never excludes: without data an optional gate passes.
      if (moonGate != null &&
          moon != null &&
          moon.altitudesDeg[i] > 0 &&
          moon.illumination * 100 >= moonGate) {
        failing.add(OpportunityGate.moon);
      }
      if (cloudGate != null) {
        final cloud = hours[_hourKey(t)]?.cloudCoverPct;
        if (cloud != null && cloud > cloudGate) {
          failing.add(OpportunityGate.cloud);
        }
      }
      samples.add(
        OpportunitySample(
          instantUtc: t,
          sunAltitudeDeg: sunAltitudesDeg[i],
          targetAltitudeDeg: targetAltitudesDeg[i],
          failing: Set.unmodifiable(failing),
        ),
      );
    }

    // Runs over the n − 1 intervals.
    final windows = <OpportunityWindow>[];
    final excluded = <ExcludedSegment>[];
    var i = 0;
    while (i < n - 1) {
      final state = samples[i].failing;
      var j = i + 1;
      while (j < n - 1 && _sameSet(samples[j].failing, state)) {
        j++;
      }
      // Interval run [i, j); it ends at t_j (t_{n−1} = night.endUtc).
      final start = samples[i].instantUtc;
      final end = j == n - 1 ? night.endUtc : samples[j].instantUtc;
      if (state.isEmpty) {
        final window = VisibilityWindow(
          start: start,
          end: end,
          clippedAtStart: i == 0,
          clippedAtEnd: j == n - 1 && samples[n - 1].usable,
        );
        windows.add(
          _annotate(window, samples, i, j, moon, weather, hours, night),
        );
      } else {
        excluded.add(
          ExcludedSegment(startUtc: start, endUtc: end, reasons: state),
        );
      }
      i = j;
    }

    return ImagingOpportunity(
      night: night,
      darknessLimitDeg: darknessLimitDeg,
      minAltitudeDeg: minAltitudeDeg,
      gates: gates,
      samples: List.unmodifiable(samples),
      windows: List.unmodifiable(windows),
      excluded: List.unmodifiable(excluded),
      noWindowReason: windows.isEmpty ? _whyNone(samples) : null,
      skyDarkness: skyDarkness,
    );
  }

  /// A forecast hour H covers `[H − 30 min, H + 30 min)` (ADR-013 §2): the
  /// key of the hour nearest [t], rounding half-hours up.
  static int _hourKey(DateTime t) {
    const hourMs = 3600000;
    final ms = t.millisecondsSinceEpoch + hourMs ~/ 2;
    return ms - ms % hourMs;
  }

  static bool _sameSet(Set<OpportunityGate> a, Set<OpportunityGate> b) =>
      a.length == b.length && a.containsAll(b);

  static NoWindowReason _whyNone(List<OpportunitySample> samples) {
    final intervals = samples.sublist(0, samples.length - 1);
    bool any(bool Function(Set<OpportunityGate> f) test) =>
        intervals.any((s) => test(s.failing));
    if (!any((f) => !f.contains(OpportunityGate.darkness))) {
      return NoWindowReason.noDarkness;
    }
    if (!any((f) => !f.contains(OpportunityGate.altitude))) {
      return NoWindowReason.targetNeverHighEnough;
    }
    if (!any(
      (f) =>
          !f.contains(OpportunityGate.darkness) &&
          !f.contains(OpportunityGate.altitude),
    )) {
      return NoWindowReason.targetNeverHighEnoughInDarkness;
    }
    return NoWindowReason.excludedByOptionalGates;
  }

  static OpportunityWindow _annotate(
    VisibilityWindow window,
    List<OpportunitySample> samples,
    int from,
    int to,
    OpportunityMoon? moon,
    OpportunityWeather? weather,
    Map<int, WeatherHour> hours,
    SessionNight night,
  ) {
    var maxIndex = from;
    for (var k = from + 1; k < to; k++) {
      if (samples[k].targetAltitudeDeg > samples[maxIndex].targetAltitudeDeg) {
        maxIndex = k;
      }
    }

    MoonWindowAnnotation? moonNote;
    if (moon != null) {
      var up = 0;
      double? minSep;
      for (var k = from; k < to; k++) {
        if (moon.altitudesDeg[k] <= 0) continue;
        up++;
        final sep = moon.separationsDeg[k];
        if (sep != null && (minSep == null || sep < minSep)) minSep = sep;
      }
      moonNote = MoonWindowAnnotation(
        upDuration: step * up,
        illumination: moon.illumination,
        minSeparationDeg: minSep,
      );
    }

    WeatherWindowAnnotation? weatherNote;
    if (weather != null) {
      final keys = <int>{
        for (var k = from; k < to; k++) _hourKey(samples[k].instantUtc),
      };
      var missing = 0;
      var dewRisk = 0;
      var dewKnown = 0;
      double? lo;
      double? hi;
      for (final key in keys) {
        final h = hours[key];
        final cloud = h?.cloudCoverPct;
        if (cloud == null) {
          missing++;
        } else {
          if (lo == null || cloud < lo) lo = cloud;
          if (hi == null || cloud > hi) hi = cloud;
        }
        final temp = h?.temperatureC;
        final dew = h?.dewPointC;
        if (temp != null && dew != null) {
          dewKnown++;
          if (temp - dew <= weather.dewMarginC) dewRisk++;
        }
      }
      weatherNote = WeatherWindowAnnotation(
        age: weather.age,
        hours: keys.length,
        hoursWithoutForecast: missing,
        cloudMinPct: lo,
        cloudMaxPct: hi,
        dewRiskHours: dewRisk,
        dewKnownHours: dewKnown,
      );
    }

    return OpportunityWindow(
      window: window,
      maxAltitudeDeg: samples[maxIndex].targetAltitudeDeg,
      maxAltitudeAtUtc: samples[maxIndex].instantUtc,
      moon: moonNote,
      weather: weatherNote,
    );
  }
}
