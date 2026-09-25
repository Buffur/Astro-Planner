// CALC-01 to CALC-06 (SCIENTIFIC_INTEGRITY.md). Expected values are
// published constants or follow from definitions, not from this code
// (sources added in S1.13; audit 01 TASK 6.2, 06 §2). Reference: J. Meeus,
// "Astronomical Algorithms", 2nd ed., Willmann-Bell, 1998.

import 'package:flutter_test/flutter_test.dart';
import 'package:astroplan/core/utils/astro_math.dart';
import 'package:astroplan/domain/services/astronomical_engine.dart';

void main() {
  group('AstroMath', () {
    // CALC-01: by definition 24 h of right ascension = 360°, so 1 h = 15°:
    // (5 + 35/60 + 17/3600) × 15 = 83.8208°.
    test('Converts RA to decimal degrees correctly', () {
      final deg = AstroMath.raToDecimalDegrees(5, 35, 17.0);
      expect(deg, closeTo(83.8208, 0.001));
    });

    // CALC-02: sexagesimal degrees, d + m/60 + s/3600, the sign applied to
    // the whole value.
    test('Converts positive Dec to decimal degrees correctly', () {
      final deg = AstroMath.decToDecimalDegrees(45, 30, 0);
      expect(deg, closeTo(45.5, 0.001));
    });

    test('Converts negative Dec to decimal degrees correctly', () {
      final deg = AstroMath.decToDecimalDegrees(5, 23, 28.0, isNegative: true);
      expect(deg, closeTo(-5.3911, 0.001));
    });

    // CALC-03: by definition, the same direction as an angle in [0°, 360°);
    // before S1.13 it was only tested indirectly.
    test('Normalizes angles into [0, 360)', () {
      expect(AstroMath.normalizeDegrees(-10), closeTo(350, 1e-9));
      expect(AstroMath.normalizeDegrees(370), closeTo(10, 1e-9));
      expect(AstroMath.normalizeDegrees(360), 0);
      expect(AstroMath.normalizeDegrees(-720.5), closeTo(359.5, 1e-9));
    });
  });

  group('AstronomicalEngine', () {
    // CALC-04: J2000.0 = 2000 January 1.5 = JD 2451545.0 (Meeus, ch. 7).
    test('Calculates J2000 epoch JD correctly', () {
      final j2000 = DateTime.utc(2000, 1, 1, 12, 0, 0);
      final jd = AstronomicalEngine.calculateJulianDate(j2000);
      expect(jd, 2451545.0);
    });

    // CALC-05: Meeus eq. 12.4, θ0 = 280.46061837° + 360.98564736629°
    // × (JD − 2451545.0) + …; at JD 2451545.0 it is the constant term.
    test('Calculates GMST at J2000 correctly', () {
      final gmst = AstronomicalEngine.calculateGMST(2451545.0);
      expect(gmst, closeTo(280.4606, 0.001));
    });

    // CALC-06: local sidereal time = Greenwich sidereal time + east
    // longitude (Meeus, ch. 12, writes θ0 − L with L positive west).
    test('Calculates LST correctly', () {
      final lst = AstronomicalEngine.calculateLST(280.0, 10.0);
      expect(lst, 290.0);
    });
  });
}
