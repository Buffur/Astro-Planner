import 'dart:math' as math;

import 'package:flutter_test/flutter_test.dart';
import 'package:astroplan/domain/services/optical_calculator.dart';

void main() {
  group('OpticalCalculator', () {
    test('calculates effective focal length correctly', () {
      final efl = OpticalCalculator.calculateEffectiveFocalLength(
        focalLength: 400.0,
      );
      expect(efl, 400.0);
    });

    test('calculates pixel scale accurately (ASI2600MC on 400mm)', () {
      final scale = OpticalCalculator.calculatePixelScale(
        pixelPitch: 3.76,
        effectiveFocalLength: 400.0,
      );
      expect(scale, closeTo(1.9389, 0.0001));
    });

    test('calculates FOV correctly (ASI2600MC on 400mm)', () {
      final fovWidth = OpticalCalculator.calculateFOV(
        sensorDimension: 23.5,
        effectiveFocalLength: 400.0,
      );
      expect(fovWidth, closeTo(3.3651, 0.0001));

      final fovHeight = OpticalCalculator.calculateFOV(
        sensorDimension: 15.7,
        effectiveFocalLength: 400.0,
      );
      expect(fovHeight, closeTo(2.2485, 0.0001));
    });

    test('calculates relative stacking gain correctly', () {
      final gain = OpticalCalculator.calculateRelativeStackingGain(100);
      expect(gain, 10.0);
    });

    test('estimates storage requirement correctly', () {
      final sizeMB = OpticalCalculator.estimateStorageRequirement(
        averageRawFileSizeMB: 50.0,
        frameCount: 10,
      );
      expect(sizeMB, closeTo(500.0, 0.01));
    });

    test(
      'returns null (not a fabricated 0.0) when the RAW file size is unknown',
      () {
        final sizeMB = OpticalCalculator.estimateStorageRequirement(
          averageRawFileSizeMB: null,
          frameCount: 10,
        );
        expect(sizeMB, isNull);
      },
    );

    // TASK 6.5 (SI-001): the old test derived its expected value from the
    // implementation's own wrong "+ 90" constant (circular). These values were
    // computed independently (scratch script, 2026-09-22) from F. Michaud's
    // derivation — t = (k/2)(4.47·550 nm·N + 2p + f·3″) / (f cos δ / 13713) —
    // and cross-checked against his published rounded formula
    // k(16.9N + 0.10f + 13.7p)/(f cos δ), which differs by under 0.2 %.
    group('NPF rule (Michaud, sahavre.fr)', () {
      double npf(double n, double p, double f, double dec, [double k = 1]) =>
          OpticalCalculator.calculateNPFExposure(
            apertureFNumber: n,
            pixelPitch: p,
            effectiveFocalLength: f,
            declinationDegrees: dec,
            k: k,
          );
      double published(double n, double p, double f, double dec, double k) =>
          k *
          (16.9 * n + 0.10 * f + 13.7 * p) /
          (f * math.cos(dec * math.pi / 180));

      for (final (name, n, p, f, dec, k, expected) in [
        (
          'phone: iPhone 15 Pro Max main, f/1.78, 1.22 µm, 6.86 mm',
          1.78,
          1.22,
          6.86,
          0.0,
          1.0,
          6.912376,
        ),
        ('APS-C 24 mm f/2.8, 3.72 µm', 2.8, 3.72, 24.0, 0.0, 1.0, 4.191854),
        ('ASI2600MC 400 mm f/4, δ 0°', 4.0, 3.76, 400.0, 0.0, 1.0, 0.397193),
        ('ASI2600MC 400 mm f/4, δ 60°', 4.0, 3.76, 400.0, 60.0, 1.0, 0.794386),
        (
          'full frame 50 mm f/2.8, 4.0 µm, δ 45°, k 2',
          2.8,
          4.0,
          50.0,
          45.0,
          2.0,
          6.054925,
        ),
      ]) {
        test(name, () {
          final t = npf(n, p, f, dec, k);
          expect(t, closeTo(expected, 1e-5));
          // Within the published rounding of the same rule.
          expect((t / published(n, p, f, dec, k) - 1).abs(), lessThan(0.002));
        });
      }

      test('the derived coefficients match the source derivation', () {
        expect(
          OpticalCalculator.npfApertureCoefficient,
          closeTo(16.856705, 1e-6),
        );
        expect(OpticalCalculator.npfPixelCoefficient, closeTo(13.713, 1e-9));
        expect(OpticalCalculator.npfFocalCoefficient, closeTo(0.0997238, 1e-6));
      });

      test('k scales linearly and is limited to [1, 3]', () {
        expect(npf(2.8, 4, 50, 0, 3) / npf(2.8, 4, 50, 0), closeTo(3, 1e-12));
        expect(() => npf(2.8, 4, 50, 0, 0.5), throwsArgumentError);
        expect(() => npf(2.8, 4, 50, 0, 3.5), throwsArgumentError);
      });

      test(
        'declination uses |δ| (southern fields) and is capped near the pole',
        () {
          expect(npf(2.8, 4, 50, -45), closeTo(npf(2.8, 4, 50, 45), 1e-12));
          expect(npf(2.8, 4, 50, 90), npf(2.8, 4, 50, 89.9));
          expect(npf(2.8, 4, 50, 90).isFinite, isTrue);
        },
      );

      test('invalid optics are rejected', () {
        expect(() => npf(0, 4, 50, 0), throwsArgumentError);
        expect(() => npf(2.8, 0, 50, 0), throwsArgumentError);
        expect(() => npf(2.8, 4, 0, 0), throwsArgumentError);
      });
    });
  });
}
