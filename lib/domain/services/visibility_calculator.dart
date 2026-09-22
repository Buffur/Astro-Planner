import 'dart:math' as math;

import '../../core/utils/astro_math.dart';
import '../models/altitude_curve.dart';
import '../models/astro_target.dart';
import '../models/calendar_date.dart';
import '../models/night_timeline.dart';
import '../models/session_night.dart';
import '../models/site_time_context.dart';
import '../models/visibility_window.dart';
import 'astronomical_engine.dart';
import 'session_night_resolver.dart';

/// Service for calculating target visibility, altitudes, and basic solar/lunar ephemerides.
class VisibilityCalculator {
  /// Calculates the Local Hour Angle (LHA) in degrees, [0, 360).
  /// Inputs: Local Sidereal Time (degrees), Right Ascension (degrees), both
  /// in the same equinox (see [calculateTargetAltitude] for precession).
  static double calculateLHA(double lst, double ra) {
    return AstroMath.normalizeDegrees(lst - ra);
  }

  /// Calculates the altitude of a celestial object above the horizon.
  /// Inputs: LHA (degrees), Declination (degrees), Latitude (degrees).
  /// Output: Altitude in degrees (-90 to +90), geometric (airless, no
  /// refraction; TASK 6.2 policy).
  /// Source: Meeus ch. 13, eq. 13.6 (spherical astronomy; exact).
  static double calculateAltitude({
    required double lha,
    required double declination,
    required double latitude,
  }) {
    final lhaRad = AstroMath.degreesToRadians(lha);
    final decRad = AstroMath.degreesToRadians(declination);
    final latRad = AstroMath.degreesToRadians(latitude);

    final sinAlt =
        math.sin(decRad) * math.sin(latRad) +
        math.cos(decRad) * math.cos(latRad) * math.cos(lhaRad);

    return AstroMath.radiansToDegrees(math.asin(sinAlt));
  }

  /// A fixed target's geometric (airless) altitude at [utcTime], degrees.
  ///
  /// The target's J2000.0 coordinates are precessed to the date first
  /// (Meeus ch. 21; TASK 6.2 decision). Refraction is not applied: altitudes
  /// are geometric by policy (TASK 6.2), since at imaging altitudes it is
  /// smaller than the minimum-altitude preference's own uncertainty.
  static double calculateTargetAltitude(
    AstroTarget target,
    DateTime utcTime,
    double latitude,
    double longitude,
  ) {
    final jd = AstronomicalEngine.calculateJulianDate(utcTime);
    final (ra, dec) = AstronomicalEngine.precessJ2000ToDate(
      target.rightAscension,
      target.declination,
      jd,
    );
    final lst = AstronomicalEngine.calculateLST(
      AstronomicalEngine.calculateGMST(jd),
      longitude,
    );
    return calculateAltitude(
      lha: calculateLHA(lst, ra),
      declination: dec,
      latitude: latitude,
    );
  }

  /// A fixed target's culmination (upper transit) altitude at [utcTime]'s
  /// date, degrees: LHA = 0 with the declination precessed to that date.
  static double calculateCulminationAltitude(
    AstroTarget target,
    DateTime utcTime,
    double latitude,
  ) {
    final (_, dec) = AstronomicalEngine.precessJ2000ToDate(
      target.rightAscension,
      target.declination,
      AstronomicalEngine.calculateJulianDate(utcTime),
    );
    return calculateAltitude(lha: 0, declination: dec, latitude: latitude);
  }

  /// Calculates the approximate altitude of the Sun.
  /// Useful for determining sunrise, sunset, and twilights.
  ///
  /// Output: geometric (airless) altitude in degrees; sunrise/sunset use the
  /// standard −0.833° threshold, which includes mean refraction and the
  /// semidiameter (TASK 6.2 policy).
  /// Source: the low-precision solar coordinates published by USNO
  /// ("Approximate Solar Coordinates"; stated accuracy about 0.01° within
  /// two centuries of 2000): mean anomaly, two-term equation of centre,
  /// linear obliquity; no nutation or aberration.
  /// Measured (TASK 6.2, 2026-09-22): ≤ 0.0097° against JPL Horizons airless
  /// elevations (375 samples, 3 sites, 5 nights; test/fixtures/astronomy).
  static double calculateSunAltitude(
    DateTime utcTime,
    double latitude,
    double longitude,
  ) {
    final jd = AstronomicalEngine.calculateJulianDate(utcTime);
    final d = jd - 2451545.0;

    // Mean anomaly of the Sun
    final g = AstroMath.normalizeDegrees(357.529 + 0.98560028 * d);
    final gRad = AstroMath.degreesToRadians(g);

    // Ecliptic longitude
    final q = AstroMath.normalizeDegrees(280.459 + 0.98564736 * d);
    final l = AstroMath.normalizeDegrees(
      q + 1.915 * math.sin(gRad) + 0.020 * math.sin(2 * gRad),
    );
    final lRad = AstroMath.degreesToRadians(l);

    // Obliquity of the ecliptic
    final eRad = AstroMath.degreesToRadians(23.439 - 0.00000036 * d);

    // Sun's declination
    final sinDec = math.sin(eRad) * math.sin(lRad);
    final dec = AstroMath.radiansToDegrees(math.asin(sinDec));

    // Sun's Right Ascension
    final y = math.cos(eRad) * math.sin(lRad);
    final x = math.cos(lRad);
    final ra = AstroMath.normalizeDegrees(
      AstroMath.radiansToDegrees(math.atan2(y, x)),
    );

    // Calculate LHA and Altitude
    final gmst = AstronomicalEngine.calculateGMST(jd);
    final lst = AstronomicalEngine.calculateLST(gmst, longitude);
    final lha = calculateLHA(lst, ra);

    return calculateAltitude(lha: lha, declination: dec, latitude: latitude);
  }

  // `calculateLunarIllumination` (the mean-synodic-month phase model, up to
  // 4.7 percentage points off) was deleted in TASK 6.4; the Moon is
  // `MoonCalculator` (ADR-010).

  /// Calculates the times for sunset, twilights, and sunrise.
  ///
  /// **Deprecated (TASK 2.3):** a wrapper over [calculateNightTimelineForNight],
  /// kept for callers not yet migrated to [SessionNight] (TASK 2.4). [date]'s
  /// Y/M/D is read as the evening date and resolved through a
  /// [MeanSolarTimeContext], matching the old behavior exactly (within
  /// millisecond rounding). A threshold with no crossing is reported as
  /// `null` here, even though [calculateNightTimelineForNight] never returns
  /// a bare null — this wrapper exists only to keep the old return shape.
  static Map<String, DateTime?> calculateNightTimeline(
    DateTime date,
    double latitude,
    double longitude,
  ) {
    final night = SessionNightResolver.forEveningDate(
      CalendarDate.fromDateTimeFields(date),
      latitude: latitude,
      longitude: longitude,
      timeContext: MeanSolarTimeContext(longitude),
    );
    final timeline = calculateNightTimelineForNight(night);

    DateTime? dusk(SunThresholdResult r) => r is SunCrossing ? r.duskUtc : null;
    DateTime? dawn(SunThresholdResult r) => r is SunCrossing ? r.dawnUtc : null;

    return {
      'sunset': dusk(timeline.sunriseSunset),
      'civilDusk': dusk(timeline.civilTwilight),
      'nauticalDusk': dusk(timeline.nauticalTwilight),
      'astroDusk': dusk(timeline.astronomicalTwilight),
      'astroDawn': dawn(timeline.astronomicalTwilight),
      'nauticalDawn': dawn(timeline.nauticalTwilight),
      'civilDawn': dawn(timeline.civilTwilight),
      'sunrise': dawn(timeline.sunriseSunset),
    };
  }

  /// The step of the shared sampling grid used by [calculateNightTimelineForNight],
  /// [calculateVisibilityWindowsForNight] and [calculateAltitudeCurve]
  /// (ADR-007 §9). Kept at 5 minutes, the step the pre-SessionNight code
  /// already used for windows and the timeline.
  static const Duration sampleStep = Duration(minutes: 5);

  /// The Sun's dusk/dawn timeline for [night], at the four standard
  /// altitude thresholds (ADR-007 §8). Pure; samples [sampleStep] apart,
  /// anchored at `night.startUtc`, inclusive of `night.endUtc` (ADR-007 §9).
  static NightTimeline calculateNightTimelineForNight(SessionNight night) {
    const thresholds = [-0.833, -6.0, -12.0, -18.0];

    final altitudes = <double>[];
    final instants = <DateTime>[];
    for (
      var elapsed = Duration.zero;
      elapsed <= SessionNight.length;
      elapsed += sampleStep
    ) {
      final instant = night.startUtc.add(elapsed);
      instants.add(instant);
      altitudes.add(
        calculateSunAltitude(instant, night.latitude, night.longitude),
      );
    }

    SunThresholdResult resultFor(double threshold) {
      DateTime? dusk;
      DateTime? dawn;
      for (var i = 1; i < altitudes.length; i++) {
        final prevAlt = altitudes[i - 1];
        final alt = altitudes[i];
        if (prevAlt >= threshold && alt < threshold) {
          dusk ??= instants[i];
        }
        if (prevAlt < threshold && alt >= threshold) {
          dawn ??= instants[i];
        }
      }

      if (dusk == null && dawn == null) {
        return altitudes.first < threshold
            ? SunAlwaysBelow(threshold)
            : SunNeverBelow(threshold);
      }
      return SunCrossing(
        threshold,
        duskUtc: dusk,
        dawnUtc: dawn,
        belowAtStart: altitudes.first < threshold,
        belowAtEnd: altitudes.last < threshold,
      );
    }

    final byThreshold = {for (final h in thresholds) h: resultFor(h)};
    return NightTimeline(
      night: night,
      sunriseSunset: byThreshold[-0.833]!,
      civilTwilight: byThreshold[-6.0]!,
      nauticalTwilight: byThreshold[-12.0]!,
      astronomicalTwilight: byThreshold[-18.0]!,
    );
  }

  /// [target]'s and the Sun's altitude across [night], on the shared
  /// [sampleStep] grid (ADR-007 §9). Presentation code (the altitude chart)
  /// consumes this instead of sampling astronomy itself (TD-023, DEV-A3).
  static AltitudeCurve calculateAltitudeCurve({
    required SessionNight night,
    required AstroTarget target,
  }) {
    final samples = <AltitudeSample>[];
    for (
      var elapsed = Duration.zero;
      elapsed <= SessionNight.length;
      elapsed += sampleStep
    ) {
      final instant = night.startUtc.add(elapsed);
      final sunAlt = calculateSunAltitude(
        instant,
        night.latitude,
        night.longitude,
      );

      final targetAlt = calculateTargetAltitude(
        target,
        instant,
        night.latitude,
        night.longitude,
      );

      samples.add(
        AltitudeSample(
          instantUtc: instant,
          sunAltitudeDeg: sunAlt,
          targetAltitudeDeg: targetAlt,
        ),
      );
    }
    return AltitudeCurve(night: night, samples: samples);
  }

  /// Calculates all usable visibility windows for a target during the night.
  /// A usable window requires:
  /// - The Sun is below the specified twilight threshold (default: -18.0 for Astronomical Twilight).
  /// - The Target is above the [minAltitude].
  ///
  /// **Deprecated (TASK 2.3):** a wrapper over [calculateVisibilityWindowsForNight],
  /// kept for callers not yet migrated to [SessionNight] (TASK 2.4). [date]'s
  /// Y/M/D is read as the evening date and resolved through a
  /// [MeanSolarTimeContext], matching the old behavior exactly (within
  /// millisecond rounding). A window can still be
  /// [VisibilityWindow.clippedAtStart]/`clippedAtEnd` through this wrapper —
  /// the flags depend only on the Sun's altitude at the site's mean solar
  /// noon (polar night), not on which time context picked that noon.
  static List<VisibilityWindow> calculateVisibilityWindows({
    required DateTime date,
    required double latitude,
    required double longitude,
    required AstroTarget target,
    required double minAltitude,
    double sunAltitudeThreshold = -18.0,
  }) {
    final night = SessionNightResolver.forEveningDate(
      CalendarDate.fromDateTimeFields(date),
      latitude: latitude,
      longitude: longitude,
      timeContext: MeanSolarTimeContext(longitude),
    );
    return calculateVisibilityWindowsForNight(
      night: night,
      target: target,
      minAltitude: minAltitude,
      darknessLimitDeg: sunAltitudeThreshold,
    );
  }

  /// [SessionNight]-based visibility windows (ADR-007 §9): the intervals
  /// where the Sun is at or below [darknessLimitDeg] (the product's
  /// configurable "dark enough to image" limit; default -18°, astronomical
  /// twilight) **and** [target] is at or above [minAltitude]. Samples
  /// [sampleStep] apart on the same grid as [calculateNightTimelineForNight]
  /// and [calculateAltitudeCurve].
  ///
  /// A window flagged [VisibilityWindow.clippedAtStart] or
  /// `clippedAtEnd` was already usable at that boundary — only possible when
  /// the Sun is below [darknessLimitDeg] at the site's mean solar noon, i.e.
  /// polar night (ADR-007 §9).
  static List<VisibilityWindow> calculateVisibilityWindowsForNight({
    required SessionNight night,
    required AstroTarget target,
    required double minAltitude,
    double darknessLimitDeg = -18.0,
  }) {
    final curve = calculateAltitudeCurve(night: night, target: target);
    final windows = <VisibilityWindow>[];

    DateTime? currentStart;
    var startClipped = false;

    for (var i = 0; i < curve.samples.length; i++) {
      final sample = curve.samples[i];
      final isUsable =
          sample.sunAltitudeDeg <= darknessLimitDeg &&
          sample.targetAltitudeDeg >= minAltitude;

      if (isUsable && currentStart == null) {
        currentStart = sample.instantUtc;
        startClipped = i == 0;
      } else if (!isUsable && currentStart != null) {
        windows.add(
          VisibilityWindow(
            start: currentStart,
            end: sample.instantUtc,
            clippedAtStart: startClipped,
          ),
        );
        currentStart = null;
        startClipped = false;
      }
    }

    if (currentStart != null) {
      windows.add(
        VisibilityWindow(
          start: currentStart,
          end: night.endUtc,
          clippedAtStart: startClipped,
          clippedAtEnd: true,
        ),
      );
    }

    return windows;
  }
}
