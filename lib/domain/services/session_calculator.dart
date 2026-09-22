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
  /// Estimates the total physical time required to execute the capture sequence.
  ///
  /// Incorporates:
  /// - Light exposures
  /// - Dark exposures
  /// - Flat exposures (estimated 5s each)
  /// - Bias exposures (estimated 1s each)
  /// - Baseline overhead (dithering, settling, download, autofocus - estimated 15% of lights duration)
  static Duration estimateTotalDuration({
    required int lightFrames,
    required int darkFrames,
    required int flatFrames,
    required int biasFrames,
    required int exposureSeconds,
  }) {
    final lightsDuration = lightFrames * exposureSeconds;
    final darksDuration = darkFrames * exposureSeconds;
    final flatsDuration = flatFrames * 5;
    final biasDuration = biasFrames * 1;

    // Overhead: typically dithering every N frames, autofocus every 1 hour, filter changes, etc.
    // We apply a flat 15% overhead on light frames duration.
    final overhead = (lightsDuration * 0.15).round();

    final totalSeconds =
        lightsDuration +
        darksDuration +
        flatsDuration +
        biasDuration +
        overhead;
    return Duration(seconds: totalSeconds);
  }

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
