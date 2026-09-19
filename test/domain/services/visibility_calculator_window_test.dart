import 'package:flutter_test/flutter_test.dart';
import 'package:astroplan/domain/models/astro_target.dart';
import 'package:astroplan/domain/services/visibility_calculator.dart';
import 'package:astroplan/domain/services/astronomical_engine.dart';

void main() {
  group('VisibilityCalculator.calculateVisibilityWindows (Batch 3.3)', () {
    const lat = 51.5072; // London
    const lon = -0.1276;

    test('Single continuous window for high target in winter', () {
      // Winter solstice
      final date = DateTime.utc(2025, 12, 21);
      
      // Target: M45 Pleiades (approx RA: 56.8°, Dec: +24.1°)
      const target = AstroTarget(
        id: 1, catalogId: 'M45', type: 'Open Cluster', rightAscension: 56.87, declination: 24.11
      );

      final windows = VisibilityCalculator.calculateVisibilityWindows(
        date: date,
        latitude: lat,
        longitude: lon,
        target: target,
        minAltitude: 20.0,
      );

      expect(windows, isNotEmpty);
      expect(windows.length, 1);
      final win = windows.first;
      
      
      // M45 rises high in winter night, so window should be quite long (e.g. > 8 hours)
      expect(win.duration.inHours, greaterThan(8));
    });

    test('No window when sun never sets enough (Summer at high latitude)', () {
      // Summer solstice
      final date = DateTime.utc(2025, 6, 21);
      
      const target = AstroTarget(
        id: 1, catalogId: 'M45', type: 'Open Cluster', rightAscension: 56.87, declination: 24.11
      );

      final windows = VisibilityCalculator.calculateVisibilityWindows(
        date: date,
        latitude: lat,
        longitude: lon,
        target: target,
        minAltitude: 20.0,
      );

      // In London midsummer, Sun doesn't reach -18°
      expect(windows, isEmpty);
    });
    
    test('Can fall back to nautical twilight if requested', () {
      final date = DateTime.utc(2025, 6, 21);
      // Vega (summer target)
      const target = AstroTarget(
        id: 1, catalogId: 'Vega', type: 'Star', rightAscension: 279.23, declination: 38.78
      );

      final windows = VisibilityCalculator.calculateVisibilityWindows(
        date: date,
        latitude: lat,
        longitude: lon,
        target: target,
        minAltitude: 20.0,
        sunAltitudeThreshold: -12.0, // Nautical
      );

      // Sun reaches about -15° in London summer, so -12° should give a window
      expect(windows, isNotEmpty);
    });

    test('Multiple segments for a circumpolar target dipping below minAltitude', () {
      // Find a target that is circumpolar (Dec > 90 - 51.5 = 38.5) but dips below 30°
      // E.g., Dec = +45° -> Max alt = 90 - 51.5 + 45 = 83.5°. Min alt = 51.5 + 45 - 90 = 6.5°
      // If we set minAltitude to 20°, it will dip below 20° during the night.
      
      final date = DateTime.utc(2025, 12, 21);
      
      // Let's set RA to cross meridian exactly at midnight
      final jd = AstronomicalEngine.calculateJulianDate(DateTime.utc(2025, 12, 21, 0, 0));
      final gmst = AstronomicalEngine.calculateGMST(jd);
      final lst = AstronomicalEngine.calculateLST(gmst, lon);
      
      // We want it to be at its lowest point (LHA = 180) around midnight.
      // So LST - RA = 180 => RA = LST - 180
      final targetRA = (lst - 180) % 360;

      final target = AstroTarget(
        id: 2, catalogId: 'Test', type: 'Test', rightAscension: targetRA, declination: 45.0
      );

      final windows = VisibilityCalculator.calculateVisibilityWindows(
        date: date,
        latitude: lat,
        longitude: lon,
        target: target,
        minAltitude: 20.0, // Should dip below this during the long winter night
      );

      
      // Expect two windows (one in evening, one in morning) separated by the dip
      expect(windows.length, 2);
    });
  });
}
