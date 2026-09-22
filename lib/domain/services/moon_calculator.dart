import 'dart:math' as math;

import '../../core/utils/astro_math.dart';
import '../models/astro_target.dart';
import '../models/moon_conditions.dart';
import '../models/session_night.dart';
import 'astronomical_engine.dart';
import 'moon_series.dart';
import 'visibility_calculator.dart';

/// The Moon's geocentric apparent position at one instant (ADR-010 §2).
class MoonPosition {
  const MoonPosition({
    required this.eclipticLongitudeDeg,
    required this.eclipticLatitudeDeg,
    required this.distanceKm,
    required this.rightAscensionDeg,
    required this.declinationDeg,
    required this.horizontalParallaxDeg,
  });

  /// Apparent ecliptic longitude of date (nutation applied), degrees.
  final double eclipticLongitudeDeg;

  /// Ecliptic latitude, degrees.
  final double eclipticLatitudeDeg;

  /// Earth–Moon centre distance, km.
  final double distanceKm;

  /// Apparent right ascension, true equator and equinox of date, degrees.
  final double rightAscensionDeg;

  /// Apparent declination, true equator of date, degrees.
  final double declinationDeg;

  /// Equatorial horizontal parallax, degrees.
  final double horizontalParallaxDeg;
}

/// Kind of a Moon horizon crossing.
enum MoonEventKind { rise, set }

/// One moonrise or moonset, reported on the night's 5-minute grid at the
/// first sample after the crossing (like the Sun timeline, ADR-007 §9).
class MoonEvent {
  const MoonEvent(this.kind, this.utc);
  final MoonEventKind kind;
  final DateTime utc;
}

/// Moonrise/moonset within one [SessionNight]. A night can have no event
/// (the Moon stays up or stays down — typed, never null) or several.
class MoonRiseSet {
  const MoonRiseSet({required this.events, required this.aboveAtStart});

  /// Crossings in time order.
  final List<MoonEvent> events;

  /// Whether the Moon is above the rise/set altitude at the night's start.
  final bool aboveAtStart;

  bool get alwaysAbove => events.isEmpty && aboveAtStart;
  bool get alwaysBelow => events.isEmpty && !aboveAtStart;
}

/// The Moon (ADR-010, CALC-28). Pure, offline and deterministic.
///
/// Sources (Meeus, *Astronomical Algorithms*, 2nd ed., 1998):
/// - ch. 47: geocentric position, the full periodic-term tables
///   ([moonLongitudeDistanceTerms], [moonLatitudeTerms]); stated accuracy
///   about 10″ in longitude and 4″ in latitude;
/// - ch. 22: nutation (the 4-term low-precision Δψ, Δε) and mean obliquity;
/// - ch. 13: ecliptic → equatorial → horizontal;
/// - ch. 40: topocentric correction (parallax up to about 1°);
/// - ch. 25: the Sun's low-accuracy apparent longitude and distance (about
///   0.01°), used only for illumination and phase;
/// - ch. 48: illuminated fraction from the phase angle;
/// - ch. 15: the Moon's rise/set altitude h₀ = 0.7275 π − 0.5667°.
///
/// Time: ch. 47 uses Terrestrial Time. [deltaTSeconds] converts UTC (taken
/// as UT1) to TT. Altitudes are geometric (airless) apart from the h₀
/// rise/set convention (TASK 6.2 refraction policy).
class MoonCalculator {
  const MoonCalculator._();

  /// ΔT = TT − UT1, seconds: 69.2 s, the IERS/USNO value for 2024–2026.
  /// It changes by under 1 s per year at present; a ±10 s error moves the
  /// Moon by less than 6″ (ADR-010 §2). Revisit when leaving 2020–2035.
  static const double deltaTSeconds = 69.2;

  static const double _earthRadiusKm = 6378.14;
  static const double _auKm = 149597870.0;

  static double _julianCenturiesTT(DateTime utc) {
    final jd = AstronomicalEngine.calculateJulianDate(utc);
    return (jd + deltaTSeconds / 86400.0 - 2451545.0) / 36525.0;
  }

  static double _sinD(double deg) => math.sin(AstroMath.degreesToRadians(deg));
  static double _cosD(double deg) => math.cos(AstroMath.degreesToRadians(deg));

  /// Nutation in longitude and true obliquity, degrees (Meeus ch. 22,
  /// low-precision terms; about 0.5″ and 0.1″).
  static (double, double) _nutationAndObliquity(double t) {
    final omega = 125.04452 - 1934.136261 * t;
    final lSun = 280.4665 + 36000.7698 * t;
    final lMoon = 218.3165 + 481267.8813 * t;
    final dPsi =
        (-17.20 * _sinD(omega) -
            1.32 * _sinD(2 * lSun) -
            0.23 * _sinD(2 * lMoon) +
            0.21 * _sinD(2 * omega)) /
        3600.0;
    final dEps =
        (9.20 * _cosD(omega) +
            0.57 * _cosD(2 * lSun) +
            0.10 * _cosD(2 * lMoon) -
            0.09 * _cosD(2 * omega)) /
        3600.0;
    final eps0 =
        23.0 +
        26.0 / 60.0 +
        (21.448 - 46.8150 * t - 0.00059 * t * t + 0.001813 * t * t * t) /
            3600.0;
    return (dPsi, eps0 + dEps);
  }

  /// Geocentric apparent position at [utc].
  static MoonPosition position(DateTime utc) {
    final t = _julianCenturiesTT(utc);
    final t2 = t * t, t3 = t2 * t, t4 = t3 * t;

    // Meeus eq. 47.1–47.5 (degrees).
    final lp = AstroMath.normalizeDegrees(
      218.3164477 +
          481267.88123421 * t -
          0.0015786 * t2 +
          t3 / 538841.0 -
          t4 / 65194000.0,
    );
    final d = AstroMath.normalizeDegrees(
      297.8501921 +
          445267.1114034 * t -
          0.0018819 * t2 +
          t3 / 545868.0 -
          t4 / 113065000.0,
    );
    final m = AstroMath.normalizeDegrees(
      357.5291092 + 35999.0502909 * t - 0.0001536 * t2 + t3 / 24490000.0,
    );
    final mp = AstroMath.normalizeDegrees(
      134.9633964 +
          477198.8675055 * t +
          0.0087414 * t2 +
          t3 / 69699.0 -
          t4 / 14712000.0,
    );
    final f = AstroMath.normalizeDegrees(
      93.2720950 +
          483202.0175233 * t -
          0.0036539 * t2 -
          t3 / 3526000.0 +
          t4 / 863310000.0,
    );
    final a1 = 119.75 + 131.849 * t;
    final a2 = 53.09 + 479264.290 * t;
    final a3 = 313.45 + 481266.484 * t;
    final e = 1 - 0.002516 * t - 0.0000074 * t2;

    double eFactor(int mMultiple) => switch (mMultiple.abs()) {
      1 => e,
      2 => e * e,
      _ => 1.0,
    };

    var sl = 0.0, sr = 0.0, sb = 0.0;
    for (final (cd, cm, cmp, cf, l, r) in moonLongitudeDistanceTerms) {
      final arg = cd * d + cm * m + cmp * mp + cf * f;
      final k = eFactor(cm);
      sl += l * k * _sinD(arg);
      sr += r * k * _cosD(arg);
    }
    for (final (cd, cm, cmp, cf, b) in moonLatitudeTerms) {
      final arg = cd * d + cm * m + cmp * mp + cf * f;
      sb += b * eFactor(cm) * _sinD(arg);
    }
    // Additive terms (Venus, Jupiter, flattening), Meeus ch. 47.
    sl += 3958 * _sinD(a1) + 1962 * _sinD(lp - f) + 318 * _sinD(a2);
    sb +=
        -2235 * _sinD(lp) +
        382 * _sinD(a3) +
        175 * _sinD(a1 - f) +
        175 * _sinD(a1 + f) +
        127 * _sinD(lp - mp) -
        115 * _sinD(lp + mp);

    final (dPsi, eps) = _nutationAndObliquity(t);
    final lambda = AstroMath.normalizeDegrees(lp + sl / 1e6 + dPsi);
    final beta = sb / 1e6;
    final distance = 385000.56 + sr / 1000.0;

    // Ecliptic → equatorial (Meeus eq. 13.3, 13.4).
    final lamR = AstroMath.degreesToRadians(lambda);
    final betR = AstroMath.degreesToRadians(beta);
    final epsR = AstroMath.degreesToRadians(eps);
    final ra = AstroMath.normalizeDegrees(
      AstroMath.radiansToDegrees(
        math.atan2(
          math.sin(lamR) * math.cos(epsR) - math.tan(betR) * math.sin(epsR),
          math.cos(lamR),
        ),
      ),
    );
    final dec = AstroMath.radiansToDegrees(
      math.asin(
        math.sin(betR) * math.cos(epsR) +
            math.cos(betR) * math.sin(epsR) * math.sin(lamR),
      ),
    );

    return MoonPosition(
      eclipticLongitudeDeg: lambda,
      eclipticLatitudeDeg: beta,
      distanceKm: distance,
      rightAscensionDeg: ra,
      declinationDeg: dec,
      horizontalParallaxDeg: AstroMath.radiansToDegrees(
        math.asin(_earthRadiusKm / distance),
      ),
    );
  }

  /// Apparent (local) sidereal time, degrees: mean sidereal time plus the
  /// equation of the equinoxes (Δψ cos ε), matching the apparent RA.
  static double _apparentLst(DateTime utc, double longitude) {
    final jd = AstronomicalEngine.calculateJulianDate(utc);
    final (dPsi, eps) = _nutationAndObliquity(_julianCenturiesTT(utc));
    return AstroMath.normalizeDegrees(
      AstronomicalEngine.calculateLST(
            AstronomicalEngine.calculateGMST(jd),
            longitude,
          ) +
          dPsi * _cosD(eps),
    );
  }

  /// The Moon's topocentric apparent RA and Dec of date, and its local hour
  /// angle, degrees, for a site on the ellipsoid at sea level (Meeus
  /// ch. 40: rigorous parallax correction; flattening b/a = 0.99664719).
  static ({double raDeg, double decDeg, double hourAngleDeg}) topocentric(
    DateTime utc,
    double latitude,
    double longitude,
  ) {
    final p = position(utc);
    final lst = _apparentLst(utc, longitude);
    final h = AstroMath.degreesToRadians(
      AstroMath.normalizeDegrees(lst - p.rightAscensionDeg),
    );
    final dec = AstroMath.degreesToRadians(p.declinationDeg);
    final sinPi = math.sin(AstroMath.degreesToRadians(p.horizontalParallaxDeg));

    final u = math.atan(
      0.99664719 * math.tan(AstroMath.degreesToRadians(latitude)),
    );
    final rhoSin = 0.99664719 * math.sin(u);
    final rhoCos = math.cos(u);

    final dAlpha = math.atan2(
      -rhoCos * sinPi * math.sin(h),
      math.cos(dec) - rhoCos * sinPi * math.cos(h),
    );
    final decTopo = math.atan2(
      (math.sin(dec) - rhoSin * sinPi) * math.cos(dAlpha),
      math.cos(dec) - rhoCos * sinPi * math.cos(h),
    );
    return (
      raDeg: AstroMath.normalizeDegrees(
        p.rightAscensionDeg + AstroMath.radiansToDegrees(dAlpha),
      ),
      decDeg: AstroMath.radiansToDegrees(decTopo),
      hourAngleDeg: AstroMath.normalizeDegrees(
        AstroMath.radiansToDegrees(h - dAlpha),
      ),
    );
  }

  /// Topocentric geometric (airless) altitude of the Moon's centre, degrees,
  /// at a site on the ellipsoid at sea level (Meeus ch. 40 and 13).
  static double topocentricAltitude(
    DateTime utc,
    double latitude,
    double longitude,
  ) {
    final t = topocentric(utc, latitude, longitude);
    return VisibilityCalculator.calculateAltitude(
      lha: t.hourAngleDeg,
      declination: t.decDeg,
      latitude: latitude,
    );
  }

  /// Angular distance between two equatorial positions, degrees (vector
  /// form of Meeus ch. 17, stable for small and large angles).
  static double angularSeparationDeg(
    double ra1Deg,
    double dec1Deg,
    double ra2Deg,
    double dec2Deg,
  ) {
    final d1 = AstroMath.degreesToRadians(dec1Deg);
    final d2 = AstroMath.degreesToRadians(dec2Deg);
    final da = AstroMath.degreesToRadians(ra2Deg - ra1Deg);
    final y = math.sqrt(
      math.pow(math.cos(d2) * math.sin(da), 2) +
          math.pow(
            math.cos(d1) * math.sin(d2) -
                math.sin(d1) * math.cos(d2) * math.cos(da),
            2,
          ),
    );
    final x =
        math.sin(d1) * math.sin(d2) +
        math.cos(d1) * math.cos(d2) * math.cos(da);
    return AstroMath.radiansToDegrees(math.atan2(y, x));
  }

  /// Topocentric Moon–target separation, degrees. The target's J2000
  /// coordinates are precessed to the date first (Meeus ch. 21, TASK 6.2),
  /// so both sit in the equinox of date (ADR-010 §2). Nutation and
  /// aberration of the target are ignored (about 20–40″).
  static double separationFromTarget(
    AstroTarget target,
    DateTime utc,
    double latitude,
    double longitude,
  ) {
    final m = topocentric(utc, latitude, longitude);
    final (ra, dec) = AstronomicalEngine.precessJ2000ToDate(
      target.rightAscension,
      target.declination,
      AstronomicalEngine.calculateJulianDate(utc),
    );
    return angularSeparationDeg(m.raDeg, m.decDeg, ra, dec);
  }

  /// The Sun's apparent geocentric ecliptic longitude (degrees) and
  /// distance (km), Meeus ch. 25 low accuracy (about 0.01°).
  static (double, double) _sun(double t) {
    final l0 = 280.46646 + 36000.76983 * t + 0.0003032 * t * t;
    final m = 357.52911 + 35999.05029 * t - 0.0001537 * t * t;
    final ecc = 0.016708634 - 0.000042037 * t - 0.0000001267 * t * t;
    final c =
        (1.914602 - 0.004817 * t - 0.000014 * t * t) * _sinD(m) +
        (0.019993 - 0.000101 * t) * _sinD(2 * m) +
        0.000289 * _sinD(3 * m);
    final trueLon = l0 + c;
    final nu = m + c;
    final rAu = 1.000001018 * (1 - ecc * ecc) / (1 + ecc * _cosD(nu));
    final omega = 125.04 - 1934.136 * t;
    final apparent = trueLon - 0.00569 - 0.00478 * _sinD(omega);
    return (AstroMath.normalizeDegrees(apparent), rAu * _auKm);
  }

  /// Illuminated fraction of the disk, 0–1 (Meeus ch. 48: geocentric
  /// elongation ψ from the ecliptic coordinates, phase angle i,
  /// k = (1 + cos i) / 2).
  static double illuminatedFraction(DateTime utc) {
    final p = position(utc);
    final (sunLon, sunDist) = _sun(_julianCenturiesTT(utc));
    final cosPsi =
        _cosD(p.eclipticLatitudeDeg) * _cosD(p.eclipticLongitudeDeg - sunLon);
    final psi = math.acos(cosPsi.clamp(-1.0, 1.0));
    final i = math.atan2(
      sunDist * math.sin(psi),
      p.distanceKm - sunDist * math.cos(psi),
    );
    return (1 + math.cos(i)) / 2;
  }

  /// Moon − Sun apparent ecliptic longitude, degrees [0, 360): 0 new moon,
  /// 90 first quarter, 180 full moon, 270 last quarter (the definition USNO
  /// and Meeus ch. 49 use for the phase instants).
  static double phaseLongitudeDeg(DateTime utc) {
    final p = position(utc);
    final (sunLon, _) = _sun(_julianCenturiesTT(utc));
    return AstroMath.normalizeDegrees(p.eclipticLongitudeDeg - sunLon);
  }

  /// Geocentric geometric altitude, degrees (for rise/set with h₀).
  static (double, double) _geocentricAltitudeAndParallax(
    DateTime utc,
    double latitude,
    double longitude,
  ) {
    final p = position(utc);
    final alt = VisibilityCalculator.calculateAltitude(
      lha: AstroMath.normalizeDegrees(
        _apparentLst(utc, longitude) - p.rightAscensionDeg,
      ),
      declination: p.declinationDeg,
      latitude: latitude,
    );
    return (alt, p.horizontalParallaxDeg);
  }

  /// Moonrise and moonset within [night], on its 5-minute grid (Meeus
  /// ch. 15 convention: geocentric altitude = 0.7275 π − 0.5667°).
  static MoonRiseSet riseSetForNight(SessionNight night) {
    bool above(DateTime t) {
      final (alt, pi) = _geocentricAltitudeAndParallax(
        t,
        night.latitude,
        night.longitude,
      );
      return alt > 0.7275 * pi - 0.5667;
    }

    final events = <MoonEvent>[];
    var t = night.startUtc;
    final aboveAtStart = above(t);
    var prev = aboveAtStart;
    while (t.isBefore(night.endUtc)) {
      t = t.add(VisibilityCalculator.sampleStep);
      final now = above(t);
      if (now != prev) {
        events.add(MoonEvent(now ? MoonEventKind.rise : MoonEventKind.set, t));
      }
      prev = now;
    }
    return MoonRiseSet(
      events: List.unmodifiable(events),
      aboveAtStart: aboveAtStart,
    );
  }

  /// Moon context for [night] (and [target], when given) on the night's
  /// 5-minute grid (TASK 6.4; CALC-29).
  static MoonConditions conditionsForNight(
    SessionNight night, {
    AstroTarget? target,
  }) {
    final samples = <MoonSample>[];
    MoonApproach? closest;
    for (
      var elapsed = Duration.zero;
      elapsed <= SessionNight.length;
      elapsed += VisibilityCalculator.sampleStep
    ) {
      final t = night.startUtc.add(elapsed);
      final topo = topocentric(t, night.latitude, night.longitude);
      final moonAlt = VisibilityCalculator.calculateAltitude(
        lha: topo.hourAngleDeg,
        declination: topo.decDeg,
        latitude: night.latitude,
      );
      double? separation;
      double? targetAlt;
      if (target != null) {
        final (ra, dec) = AstronomicalEngine.precessJ2000ToDate(
          target.rightAscension,
          target.declination,
          AstronomicalEngine.calculateJulianDate(t),
        );
        separation = angularSeparationDeg(topo.raDeg, topo.decDeg, ra, dec);
        targetAlt = VisibilityCalculator.calculateTargetAltitude(
          target,
          t,
          night.latitude,
          night.longitude,
        );
        if (moonAlt > 0 &&
            targetAlt > 0 &&
            (closest == null || separation < closest.separationDeg)) {
          closest = MoonApproach(separationDeg: separation, instantUtc: t);
        }
      }
      samples.add(
        MoonSample(
          instantUtc: t,
          altitudeDeg: moonAlt,
          separationDeg: separation,
          targetAltitudeDeg: targetAlt,
        ),
      );
    }
    return MoonConditions(
      night: night,
      samples: List.unmodifiable(samples),
      riseSet: riseSetForNight(night),
      illuminationAtMidnight: illuminatedFraction(
        night.startUtc.add(const Duration(hours: 12)),
      ),
      closestApproachWhileBothUp: closest,
    );
  }
}
