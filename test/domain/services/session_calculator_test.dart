import 'package:flutter_test/flutter_test.dart';
import 'package:astroplan/domain/models/visibility_window.dart';
import 'package:astroplan/domain/services/session_calculator.dart';

void main() {
  group('SessionCalculator (Batch 3.4)', () {
    // The `estimateTotalDuration` test was removed with the dead function
    // itself (TASK 5.4, ADR-009; recorded in docs/DECISIONS.md). Its
    // replacement is test/domain/services/capture_budget_calculator_test.dart.

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

  group('configurable margin (TASK 5.2)', () {
    final twoHours = [
      VisibilityWindow(
        start: DateTime.utc(2026, 1, 1, 22),
        end: DateTime.utc(2026, 1, 2, 0),
      ),
    ];
    FeasibilityState stateFor(int minutes, double margin) =>
        SessionCalculator.calculateFeasibility(
          availableWindows: twoHours,
          estimatedRequiredTime: Duration(minutes: minutes),
          marginFraction: margin,
        ).state;

    test('default is 15 % (the old fixed 85 % threshold)', () {
      expect(
        SessionCalculator.calculateFeasibility(
          availableWindows: twoHours,
          estimatedRequiredTime: const Duration(minutes: 103),
        ).state,
        FeasibilityState.tight,
      );
      expect(stateFor(102, 0.15), FeasibilityState.feasible);
    });

    test('a larger margin turns the same plan tight; zero margin never', () {
      expect(stateFor(90, 0.15), FeasibilityState.feasible);
      expect(stateFor(90, 0.30), FeasibilityState.tight);
      expect(stateFor(120, 0.0), FeasibilityState.feasible);
      expect(stateFor(121, 0.0), FeasibilityState.infeasible);
    });
  });
}
