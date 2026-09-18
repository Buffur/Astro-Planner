import 'package:flutter_test/flutter_test.dart';
import 'package:astroplan/domain/models/visibility_window.dart';
import 'package:astroplan/domain/services/session_calculator.dart';

void main() {
  group('SessionCalculator (Batch 3.4)', () {
    test('estimates total duration correctly with overhead', () {
      final duration = SessionCalculator.estimateTotalDuration(
        lightFrames: 100, // 100 * 60 = 6000s
        darkFrames: 20,   // 20 * 60 = 1200s
        flatFrames: 20,   // 20 * 5 = 100s
        biasFrames: 20,   // 20 * 1 = 20s
        exposureSeconds: 60,
      );

      // Lights: 6000
      // Overhead 15% of 6000 = 900
      // Darks: 1200
      // Flats: 100
      // Bias: 20
      // Total = 6000 + 900 + 1200 + 100 + 20 = 8220 seconds
      
      expect(duration.inSeconds, 8220);
    });

    test('feasibility is infeasible if available time is 0', () {
      final result = SessionCalculator.calculateFeasibility(
        availableWindows: [],
        estimatedRequiredTime: const Duration(hours: 2),
      );
      
      expect(result.state, FeasibilityState.infeasible);
      expect(result.totalAvailableTime.inSeconds, 0);
    });

    test('feasibility is infeasible if required > available', () {
      final w1 = VisibilityWindow(
        start: DateTime(2025, 1, 1, 20, 0),
        end: DateTime(2025, 1, 1, 22, 0), // 2 hours
      );

      final result = SessionCalculator.calculateFeasibility(
        availableWindows: [w1],
        estimatedRequiredTime: const Duration(hours: 3),
      );
      
      expect(result.state, FeasibilityState.infeasible);
      expect(result.totalAvailableTime.inHours, 2);
    });

    test('feasibility is tight if margin < 15%', () {
      final w1 = VisibilityWindow(
        start: DateTime(2025, 1, 1, 20, 0),
        end: DateTime(2025, 1, 1, 22, 0), // 2 hours = 7200s
      );

      // Required = 1.8 hours = 6480s. 6480 > 7200 * 0.85 (6120) -> tight
      final result = SessionCalculator.calculateFeasibility(
        availableWindows: [w1],
        estimatedRequiredTime: const Duration(minutes: 108),
      );
      
      expect(result.state, FeasibilityState.tight);
    });

    test('feasibility is feasible if margin >= 15%', () {
      final w1 = VisibilityWindow(
        start: DateTime(2025, 1, 1, 20, 0),
        end: DateTime(2025, 1, 1, 22, 0), // 2 hours = 7200s
      );

      // Required = 1 hour = 3600s
      final result = SessionCalculator.calculateFeasibility(
        availableWindows: [w1],
        estimatedRequiredTime: const Duration(hours: 1),
      );
      
      expect(result.state, FeasibilityState.feasible);
    });
    
    test('handles multiple windows', () {
      final w1 = VisibilityWindow(
        start: DateTime(2025, 1, 1, 20, 0),
        end: DateTime(2025, 1, 1, 22, 0), // 2 hours
      );
      final w2 = VisibilityWindow(
        start: DateTime(2025, 1, 1, 23, 0),
        end: DateTime(2025, 1, 2, 2, 0), // 3 hours
      );

      final result = SessionCalculator.calculateFeasibility(
        availableWindows: [w1, w2],
        estimatedRequiredTime: const Duration(hours: 4),
      );
      
      expect(result.totalAvailableTime.inHours, 5);
      expect(result.state, FeasibilityState.feasible);
    });
  });
}
