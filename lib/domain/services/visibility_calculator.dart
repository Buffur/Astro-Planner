import 'dart:math' as math;
import '../../core/utils/astro_math.dart';
import 'astronomical_engine.dart';

/// Service for calculating target visibility, altitudes, and basic solar/lunar ephemerides.
class VisibilityCalculator {
  /// Calculates the Local Hour Angle (LHA) in degrees.
  /// Inputs: Local Sidereal Time (degrees), Right Ascension (degrees).
  static double calculateLHA(double lst, double ra) {
    return AstroMath.normalizeDegrees(lst - ra);
  }

  /// Calculates the altitude of a celestial object above the horizon.
  /// Inputs: LHA (degrees), Declination (degrees), Latitude (degrees).
  /// Output: Altitude in degrees (-90 to +90).
  static double calculateAltitude({
    required double lha,
    required double declination,
    required double latitude,
  }) {
    final lhaRad = AstroMath.degreesToRadians(lha);
    final decRad = AstroMath.degreesToRadians(declination);
    final latRad = AstroMath.degreesToRadians(latitude);

    final sinAlt = math.sin(decRad) * math.sin(latRad) +
        math.cos(decRad) * math.cos(latRad) * math.cos(lhaRad);
    
    return AstroMath.radiansToDegrees(math.asin(sinAlt));
  }

  /// Calculates the approximate altitude of the Sun.
  /// Useful for determining sunrise, sunset, and twilights.
  static double calculateSunAltitude(DateTime utcTime, double latitude, double longitude) {
    final jd = AstronomicalEngine.calculateJulianDate(utcTime);
    final d = jd - 2451545.0;

    // Mean anomaly of the Sun
    final g = AstroMath.normalizeDegrees(357.529 + 0.98560028 * d);
    final gRad = AstroMath.degreesToRadians(g);

    // Ecliptic longitude
    final q = AstroMath.normalizeDegrees(280.459 + 0.98564736 * d);
    final l = AstroMath.normalizeDegrees(q + 1.915 * math.sin(gRad) + 0.020 * math.sin(2 * gRad));
    final lRad = AstroMath.degreesToRadians(l);

    // Obliquity of the ecliptic
    final eRad = AstroMath.degreesToRadians(23.439 - 0.00000036 * d);

    // Sun's declination
    final sinDec = math.sin(eRad) * math.sin(lRad);
    final dec = AstroMath.radiansToDegrees(math.asin(sinDec));

    // Sun's Right Ascension
    final y = math.cos(eRad) * math.sin(lRad);
    final x = math.cos(lRad);
    final ra = AstroMath.normalizeDegrees(AstroMath.radiansToDegrees(math.atan2(y, x)));

    // Calculate LHA and Altitude
    final gmst = AstronomicalEngine.calculateGMST(jd);
    final lst = AstronomicalEngine.calculateLST(gmst, longitude);
    final lha = calculateLHA(lst, ra);

    return calculateAltitude(lha: lha, declination: dec, latitude: latitude);
  }

  /// Calculates approximate lunar illumination percentage (0.0 to 1.0).
  /// Based on a known new moon epoch.
  static double calculateLunarIllumination(DateTime utcTime) {
    // Known New Moon: Jan 6, 2000, 18:14 UTC
    final newMoonEpoch = DateTime.utc(2000, 1, 6, 18, 14);
    final diffSeconds = utcTime.difference(newMoonEpoch).inSeconds;
    
    // Lunar synodic month = 29.530588 days
    final lunarCycleSeconds = 29.530588 * 24 * 3600;
    final phase = (diffSeconds % lunarCycleSeconds) / lunarCycleSeconds;

    // Illumination = 0.5 * (1 - cos(phase * 2 * pi))
    return 0.5 * (1 - math.cos(phase * 2 * math.pi));
  }
}
