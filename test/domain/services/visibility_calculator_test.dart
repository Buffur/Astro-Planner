import 'package:flutter_test/flutter_test.dart';
import 'package:astroplan/domain/services/visibility_calculator.dart';

void main() {
  group('VisibilityCalculator', () {
    test('calculates culmination altitude correctly', () {
      // At LHA = 0 (transit), altitude should be 90 - abs(lat - dec)
      final alt = VisibilityCalculator.calculateAltitude(
        lha: 0.0,
        declination: 20.0,
        latitude: 50.0,
      );
      // 90 - (50 - 20) = 60 degrees
      expect(alt, closeTo(60.0, 0.001));
    });

    test('calculates lunar illumination correctly at known new moon', () {
      final newMoon = DateTime.utc(2000, 1, 6, 18, 14);
      final illum = VisibilityCalculator.calculateLunarIllumination(newMoon);
      expect(illum, closeTo(0.0, 0.01));
    });

    test('calculates lunar illumination correctly at full moon (~14.76 days later)', () {
      final fullMoon = DateTime.utc(2000, 1, 6, 18, 14).add(const Duration(days: 14, hours: 18, minutes: 22));
      final illum = VisibilityCalculator.calculateLunarIllumination(fullMoon);
      expect(illum, closeTo(1.0, 0.05)); // allowing some margin for average synodic month approximation
    });
  });
}
