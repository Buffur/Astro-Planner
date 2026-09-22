import 'dart:math' as math;

import '../../core/utils/astro_math.dart';

/// Core engine for astronomical calculations.
/// Follows standard algorithms (e.g., Meeus) for time and celestial mechanics.
class AstronomicalEngine {
  /// Calculates the Julian Date (JD) from a UTC DateTime.
  /// Purpose: The standard continuous time reference in astronomy.
  /// Inputs: A UTC DateTime object.
  /// Outputs: Julian Date (double).
  /// Valid range: Valid for Gregorian dates.
  /// Source: Meeus, *Astronomical Algorithms*, 2nd ed., ch. 7, eq. 7.1.
  /// Assumptions: UTC is used as UT1 (|UT1 − UTC| < 0.9 s); milliseconds are
  /// ignored (≤ 1 s). No ΔT: this is a UT-based JD (ADR-010 §2 adds ΔT only
  /// where TT is required).
  static double calculateJulianDate(DateTime utcTime) {
    if (!utcTime.isUtc) {
      throw ArgumentError('Time must be UTC');
    }

    var year = utcTime.year;
    var month = utcTime.month;
    final day = utcTime.day;

    if (month <= 2) {
      year -= 1;
      month += 12;
    }

    final a = year ~/ 100;
    final b = 2 - a + (a ~/ 4);

    final jdMidnight =
        (365.25 * (year + 4716)).floor() +
        (30.6001 * (month + 1)).floor() +
        day +
        b -
        1524.5;

    final dayFraction =
        (utcTime.hour + (utcTime.minute / 60.0) + (utcTime.second / 3600.0)) /
        24.0;

    return jdMidnight + dayFraction;
  }

  /// Calculates Greenwich Mean Sidereal Time (GMST) in degrees.
  /// Purpose: Reference angle of the Earth's rotation.
  /// Inputs: Julian Date (double).
  /// Outputs: GMST in decimal degrees [0, 360).
  /// Source: Meeus ch. 12, eq. 12.4 without the T² and T³ terms (their
  /// effect is below 0.1″ for this century). Mean, not apparent, sidereal
  /// time: the equation of the equinoxes (≤ ~1.1 s) is ignored.
  static double calculateGMST(double jd) {
    final d = jd - 2451545.0; // Days since J2000.0
    final gmst = 280.46061837 + 360.98564736629 * d;
    return AstroMath.normalizeDegrees(gmst);
  }

  /// Calculates Local Sidereal Time (LST) in degrees.
  /// Purpose: Determines the local sky configuration.
  /// Inputs: GMST (degrees), Longitude (degrees, East is positive).
  /// Outputs: LST in decimal degrees [0, 360).
  static double calculateLST(double gmst, double longitude) {
    return AstroMath.normalizeDegrees(gmst + longitude);
  }

  /// Precesses J2000.0 mean equatorial coordinates to the mean equator and
  /// equinox of the date [jd] (TASK 6.2 decision, recorded in DECISIONS).
  ///
  /// Formula: Meeus, *Astronomical Algorithms*, 2nd ed., ch. 21, eq. 21.2
  /// (IAU 1976 angles ζ, z, θ in arcseconds, T in Julian centuries from
  /// J2000.0) and eq. 21.4 (rigorous rotation).
  ///
  /// Inputs: RA and Dec in degrees (J2000.0); [jd] a Julian Date.
  /// Output: (RA, Dec) of date in degrees, RA in [0, 360).
  /// Not included: nutation and annual aberration (together about 20″ to
  /// 40″), proper motion. Measured against USNO computed altitudes of nine
  /// stars at three sites: 0.017° residual (0.32° without precession).
  static (double, double) precessJ2000ToDate(
    double raDeg,
    double decDeg,
    double jd,
  ) {
    final t = (jd - 2451545.0) / 36525.0;
    final zeta =
        (2306.2181 * t + 0.30188 * t * t + 0.017998 * t * t * t) / 3600.0;
    final z = (2306.2181 * t + 1.09468 * t * t + 0.018203 * t * t * t) / 3600.0;
    final theta =
        (2004.3109 * t - 0.42665 * t * t - 0.041833 * t * t * t) / 3600.0;

    final ra = AstroMath.degreesToRadians(raDeg);
    final dec = AstroMath.degreesToRadians(decDeg);
    final zetaR = AstroMath.degreesToRadians(zeta);
    final thetaR = AstroMath.degreesToRadians(theta);

    final a = math.cos(dec) * math.sin(ra + zetaR);
    final b =
        math.cos(thetaR) * math.cos(dec) * math.cos(ra + zetaR) -
        math.sin(thetaR) * math.sin(dec);
    final c =
        math.sin(thetaR) * math.cos(dec) * math.cos(ra + zetaR) +
        math.cos(thetaR) * math.sin(dec);

    final raOut = AstroMath.normalizeDegrees(
      AstroMath.radiansToDegrees(math.atan2(a, b)) + z,
    );
    final decOut = AstroMath.radiansToDegrees(math.asin(c.clamp(-1.0, 1.0)));
    return (raOut, decOut);
  }
}
