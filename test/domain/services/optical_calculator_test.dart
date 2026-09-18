import 'package:flutter_test/flutter_test.dart';
import 'package:astroplan/domain/services/optical_calculator.dart';

void main() {
  group('OpticalCalculator', () {
    test('calculates effective focal length correctly', () {
      final efl = OpticalCalculator.calculateEffectiveFocalLength(
        focalLength: 400.0,
        opticalMultiplier: 0.8,
      );
      expect(efl, 320.0);
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

    test('estimates theoretical frame size correctly', () {
      final sizeMB = OpticalCalculator.estimateTheoreticalFrameSizeMB(
        resolutionWidth: 6248,
        resolutionHeight: 4176,
        bitDepth: 16,
      );
      expect(sizeMB, closeTo(49.77, 0.01));
    });

    test('calculates NPF exposure accurately', () {
      // f/4, 3.76um pixels, 400mm focal length, dec 0
      // (16.856*4 + 13.713*3.76 + 90) / (400 * cos(0))
      // (67.424 + 51.56096 + 90) / 400
      // 208.98496 / 400 = 0.522
      
      final npf = OpticalCalculator.calculateNPFExposure(
        apertureFNumber: 4.0,
        pixelPitch: 3.76,
        effectiveFocalLength: 400.0,
        declinationDegrees: 0.0,
      );
      
      expect(npf, closeTo(0.522, 0.01));
      
      // Higher declination (e.g. 60 deg -> cos(60) = 0.5)
      // 208.98496 / 200 = 1.044
      final npfHighDec = OpticalCalculator.calculateNPFExposure(
        apertureFNumber: 4.0,
        pixelPitch: 3.76,
        effectiveFocalLength: 400.0,
        declinationDegrees: 60.0,
      );
      
      expect(npfHighDec, closeTo(1.044, 0.01));
    });
  });
}
