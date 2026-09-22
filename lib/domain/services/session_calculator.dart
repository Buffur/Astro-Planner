import '../models/visibility_window.dart';

enum FeasibilityState { feasible, tight, infeasible }

class SessionFeasibility {
  final Duration totalAvailableTime;
  final Duration estimatedRequiredTime;
  final FeasibilityState state;

  const SessionFeasibility({
    required this.totalAvailableTime,
    required this.estimatedRequiredTime,
    required this.state,
  });
}

class SessionCalculator {
  // `estimateTotalDuration` (the unsourced 15 % overhead model, CALC-19)
  // was dead code and was deleted in TASK 5.4; the budget now comes from
  // `CaptureBudgetCalculator` (ADR-009).

  /// Calculates the feasibility of a planned session given the available visibility windows.
  ///
  /// [marginFraction] is the share of the available time that must stay free
  /// for a plan to count as feasible rather than tight. Default 0.15 (the
  /// fixed 85 % threshold used before TASK 5.2); a user preference since
  /// TASK 5.2 (ADR-009 §6). Clamped to [0, 0.5].
  static SessionFeasibility calculateFeasibility({
    required List<VisibilityWindow> availableWindows,
    required Duration estimatedRequiredTime,
    double marginFraction = 0.15,
  }) {
    final margin = marginFraction.clamp(0.0, 0.5);
    int totalAvailableSeconds = 0;
    for (final window in availableWindows) {
      totalAvailableSeconds += window.duration.inSeconds;
    }

    final available = Duration(seconds: totalAvailableSeconds);

    FeasibilityState state;

    if (available.inSeconds == 0) {
      state = FeasibilityState.infeasible;
    } else if (estimatedRequiredTime.inSeconds > available.inSeconds) {
      state = FeasibilityState.infeasible;
    } else if (estimatedRequiredTime.inSeconds >
        available.inSeconds * (1 - margin)) {
      // Less than the configured margin left
      state = FeasibilityState.tight;
    } else {
      state = FeasibilityState.feasible;
    }

    return SessionFeasibility(
      totalAvailableTime: available,
      estimatedRequiredTime: estimatedRequiredTime,
      state: state,
    );
  }
}
