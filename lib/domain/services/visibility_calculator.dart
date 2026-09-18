import 'dart:math' as math;
import '../../core/utils/astro_math.dart';
import '../models/astro_target.dart';
import '../models/visibility_window.dart';
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
    // Known New Moon: Jan 11, 2024, 11:57 UTC (Updated to reduce phase drift)
    final newMoonEpoch = DateTime.utc(2024, 1, 11, 11, 57);
    final diffSeconds = utcTime.difference(newMoonEpoch).inSeconds;
    
    // Lunar synodic month = 29.530588 days
    final lunarCycleSeconds = 29.530588 * 24 * 3600;
    final phase = (diffSeconds % lunarCycleSeconds) / lunarCycleSeconds;

    // Illumination = 0.5 * (1 - cos(phase * 2 * pi))
    return 0.5 * (1 - math.cos(phase * 2 * math.pi));
  }

  /// Calculates the times for sunset, twilights, and sunrise.
  /// Returns a map of important astronomical times for the given local noon (or 12:00 UTC).
  static Map<String, DateTime?> calculateNightTimeline(DateTime date, double latitude, double longitude) {
    // We want to find events for the "night" following the given date.
    // Start scanning from approximate local noon to local noon tomorrow.
    final offsetHours = longitude / 15.0;
    final offsetDuration = Duration(minutes: (offsetHours * 60).round());
    DateTime start = DateTime.utc(date.year, date.month, date.day, 12, 0).subtract(offsetDuration);
    
    DateTime? sunset;
    DateTime? civilDusk;
    DateTime? nauticalDusk;
    DateTime? astroDusk;
    DateTime? astroDawn;
    DateTime? nauticalDawn;
    DateTime? civilDawn;
    DateTime? sunrise;

    double prevAlt = calculateSunAltitude(start, latitude, longitude);
    
    // Scan in 5-minute increments for speed, then refine to 1-minute
    for (int minutes = 5; minutes <= 24 * 60; minutes += 5) {
      DateTime current = start.add(Duration(minutes: minutes));
      double alt = calculateSunAltitude(current, latitude, longitude);
      
      // Check crossings (going down)
      if (prevAlt >= -0.833 && alt < -0.833 && sunset == null) sunset = current;
      if (prevAlt >= -6.0 && alt < -6.0 && civilDusk == null) civilDusk = current;
      if (prevAlt >= -12.0 && alt < -12.0 && nauticalDusk == null) nauticalDusk = current;
      if (prevAlt >= -18.0 && alt < -18.0 && astroDusk == null) astroDusk = current;
      
      // Check crossings (going up)
      if (prevAlt < -18.0 && alt >= -18.0 && astroDawn == null) astroDawn = current;
      if (prevAlt < -12.0 && alt >= -12.0 && nauticalDawn == null) nauticalDawn = current;
      if (prevAlt < -6.0 && alt >= -6.0 && civilDawn == null) civilDawn = current;
      if (prevAlt < -0.833 && alt >= -0.833 && sunrise == null) sunrise = current;
      
      prevAlt = alt;
    }
    
    return {
      'sunset': sunset,
      'civilDusk': civilDusk,
      'nauticalDusk': nauticalDusk,
      'astroDusk': astroDusk,
      'astroDawn': astroDawn,
      'nauticalDawn': nauticalDawn,
      'civilDawn': civilDawn,
      'sunrise': sunrise,
    };
  }

  /// Calculates all usable visibility windows for a target during the night.
  /// A usable window requires:
  /// - The Sun is below the specified twilight threshold (default: -18.0 for Astronomical Twilight).
  /// - The Target is above the [minAltitude].
  static List<VisibilityWindow> calculateVisibilityWindows({
    required DateTime date,
    required double latitude,
    required double longitude,
    required AstroTarget target,
    required double minAltitude,
    double sunAltitudeThreshold = -18.0,
  }) {
    // Scan from approximate local noon today to local noon tomorrow
    final offsetHours = longitude / 15.0;
    final offsetDuration = Duration(minutes: (offsetHours * 60).round());
    final start = DateTime.utc(date.year, date.month, date.day, 12, 0).subtract(offsetDuration);
    final windows = <VisibilityWindow>[];
    
    DateTime? currentWindowStart;
    
    // Scan in 5-minute increments
    const stepMinutes = 5;
    for (int minutes = 0; minutes <= 24 * 60; minutes += stepMinutes) {
      final current = start.add(Duration(minutes: minutes));
      
      final sunAlt = calculateSunAltitude(current, latitude, longitude);
      final isDark = sunAlt <= sunAltitudeThreshold;
      
      bool isTargetHighEnough = false;
      if (isDark) {
        final jd = AstronomicalEngine.calculateJulianDate(current);
        final gmst = AstronomicalEngine.calculateGMST(jd);
        final lst = AstronomicalEngine.calculateLST(gmst, longitude);
        final lha = calculateLHA(lst, target.rightAscension);
        final targetAlt = calculateAltitude(
          lha: lha,
          declination: target.declination,
          latitude: latitude,
        );
        isTargetHighEnough = targetAlt >= minAltitude;
      }
      
      final isUsable = isDark && isTargetHighEnough;
      
      if (isUsable && currentWindowStart == null) {
        currentWindowStart = current;
      } else if (!isUsable && currentWindowStart != null) {
        windows.add(VisibilityWindow(start: currentWindowStart, end: current));
        currentWindowStart = null;
      }
    }
    
    if (currentWindowStart != null) {
      windows.add(VisibilityWindow(start: currentWindowStart, end: start.add(const Duration(hours: 24))));
    }
    
    return windows;
  }
}
