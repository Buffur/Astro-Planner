import 'dart:math' as math;

/// Mathematical constants and utilities for astronomical calculations.
class AstroMath {
  /// Converts degrees to radians.
  /// Formula: radians = degrees * (pi / 180)
  static double degreesToRadians(double degrees) {
    return degrees * (math.pi / 180.0);
  }

  /// Converts radians to degrees.
  /// Formula: degrees = radians * (180 / pi)
  static double radiansToDegrees(double radians) {
    return radians * (180.0 / math.pi);
  }

  /// Converts Right Ascension (hours, minutes, seconds) to decimal degrees.
  /// Purpose: Internal coordinate representation.
  /// Inputs: hours (0-24), minutes (0-60), seconds (0-60)
  /// Formula: (h + m/60 + s/3600) * 15
  static double raToDecimalDegrees(int hours, int minutes, double seconds) {
    final decimalHours = hours + (minutes / 60.0) + (seconds / 3600.0);
    return decimalHours * 15.0;
  }

  /// Converts Declination (degrees, minutes, seconds) to decimal degrees.
  /// Purpose: Internal coordinate representation.
  /// Inputs: degrees (-90 to 90), minutes (0-60), seconds (0-60), isNegative (bool)
  /// Formula: (abs(d) + m/60 + s/3600) * sign
  static double decToDecimalDegrees(int degrees, int minutes, double seconds, {bool isNegative = false}) {
    final absDegrees = degrees.abs();
    final decimal = absDegrees + (minutes / 60.0) + (seconds / 3600.0);
    return isNegative || degrees < 0 ? -decimal : decimal;
  }

  /// Normalizes an angle in degrees to the range [0, 360).
  static double normalizeDegrees(double degrees) {
    var result = degrees % 360.0;
    if (result < 0) result += 360.0;
    return result;
  }
}
