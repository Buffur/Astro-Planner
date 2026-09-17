import 'package:flutter_test/flutter_test.dart';
import 'package:astroplan/core/utils/astro_math.dart';
import 'package:astroplan/domain/services/astronomical_engine.dart';

void main() {
  group('AstroMath', () {
    test('Converts RA to decimal degrees correctly', () {
      final deg = AstroMath.raToDecimalDegrees(5, 35, 17.0);
      expect(deg, closeTo(83.8208, 0.001));
    });

    test('Converts positive Dec to decimal degrees correctly', () {
      final deg = AstroMath.decToDecimalDegrees(45, 30, 0);
      expect(deg, closeTo(45.5, 0.001));
    });

    test('Converts negative Dec to decimal degrees correctly', () {
      final deg = AstroMath.decToDecimalDegrees(5, 23, 28.0, isNegative: true);
      expect(deg, closeTo(-5.3911, 0.001));
    });
  });

  group('AstronomicalEngine', () {
    test('Calculates J2000 epoch JD correctly', () {
      final j2000 = DateTime.utc(2000, 1, 1, 12, 0, 0);
      final jd = AstronomicalEngine.calculateJulianDate(j2000);
      expect(jd, 2451545.0);
    });

    test('Calculates GMST at J2000 correctly', () {
      final gmst = AstronomicalEngine.calculateGMST(2451545.0);
      expect(gmst, closeTo(280.4606, 0.001));
    });

    test('Calculates LST correctly', () {
      final lst = AstronomicalEngine.calculateLST(280.0, 10.0);
      expect(lst, 290.0);
    });
  });
}
