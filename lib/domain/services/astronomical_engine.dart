import '../../core/utils/astro_math.dart';

/// Core engine for astronomical calculations.
/// Follows standard algorithms (e.g., Meeus) for time and celestial mechanics.
class AstronomicalEngine {
  /// Calculates the Julian Date (JD) from a UTC DateTime.
  /// Purpose: The standard continuous time reference in astronomy.
  /// Inputs: A UTC DateTime object.
  /// Outputs: Julian Date (double).
  /// Valid range: Valid for Gregorian dates.
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

    final jdMidnight = (365.25 * (year + 4716)).floor() +
        (30.6001 * (month + 1)).floor() +
        day + b - 1524.5;

    final dayFraction = (utcTime.hour + (utcTime.minute / 60.0) + (utcTime.second / 3600.0)) / 24.0;

    return jdMidnight + dayFraction;
  }

  /// Calculates Greenwich Mean Sidereal Time (GMST) in degrees.
  /// Purpose: Reference angle of the Earth\\'s rotation.
  /// Inputs: Julian Date (double).
  /// Outputs: GMST in decimal degrees [0, 360).
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
}
