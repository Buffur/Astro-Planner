import '../models/altitude_curve.dart';
import '../models/capture_block.dart';
import '../models/execution.dart';
import '../models/night_timeline.dart';
import 'moon_calculator.dart';

/// What is left of the night for a run (ADR-016; TASK 13.3, CALC-36): the
/// countdowns and the remaining window against the remaining plan. Pure:
/// the night's timeline, the target's altitude curve and the Moon's
/// rise/set are computed once from the execution-start snapshot and passed
/// in with "now".
class ExecutionOutlook {
  const ExecutionOutlook({
    required this.astronomicalDawnUtc,
    required this.targetBelowLimitUtc,
    required this.targetBelowLimitNow,
    required this.moonriseUtc,
    required this.moonUp,
    required this.remainingWindow,
    required this.remainingPlan,
  });

  /// The next astronomical dawn (Sun back above −18°) after now; null when
  /// there is none left tonight.
  final DateTime? astronomicalDawnUtc;

  /// When the target next drops below the minimum altitude (on the 5-minute
  /// grid); null when it stays above for the rest of the night, or when
  /// it is already below ([targetBelowLimitNow]) or unknown.
  final DateTime? targetBelowLimitUtc;
  final bool targetBelowLimitNow;

  /// The next moonrise after now; null when there is none left tonight.
  final DateTime? moonriseUtc;

  /// Whether the Moon is up now (null when unknown).
  final bool? moonUp;

  /// The planned windows' time still ahead of now.
  final Duration remainingWindow;

  /// The time the plan still needs in the window: frames left × (exposure +
  /// per-frame overhead) for light and in-window calibration blocks.
  /// Dither, refocus and flips are not included (an estimate).
  final Duration remainingPlan;

  static ExecutionOutlook compute({
    required DateTime nowUtc,
    required List<CaptureBlock> blocks,
    required ExecutionState state,
    required double perFrameOverheadSeconds,
    required List<(DateTime, DateTime)> windows,
    NightTimeline? timeline,
    AltitudeCurve? curve,
    double? minAltitudeDeg,
    MoonRiseSet? moon,
  }) {
    // Astronomical dawn: the Sun crossing −18° upwards, if still ahead.
    DateTime? dawn;
    if (timeline?.astronomicalTwilight case SunCrossing(:final dawnUtc?)) {
      if (dawnUtc.isAfter(nowUtc)) dawn = dawnUtc;
    }

    // The target: below now, or the first sample after now below the limit.
    DateTime? below;
    var belowNow = false;
    final samples = curve?.samples;
    if (samples != null && samples.isNotEmpty && minAltitudeDeg != null) {
      final ahead = samples.where((s) => !s.instantUtc.isBefore(nowUtc));
      final current = samples.lastWhere(
        (s) => !s.instantUtc.isAfter(nowUtc),
        orElse: () => samples.first,
      );
      belowNow = current.targetAltitudeDeg < minAltitudeDeg;
      if (!belowNow) {
        for (final s in ahead) {
          if (s.targetAltitudeDeg < minAltitudeDeg) {
            below = s.instantUtc;
            break;
          }
        }
      }
    }

    // The Moon: the next rise after now, and whether it is up now.
    DateTime? rise;
    bool? up;
    if (moon != null) {
      up = moon.aboveAtStart;
      for (final e in moon.events) {
        if (!e.utc.isAfter(nowUtc)) {
          up = e.kind == MoonEventKind.rise;
        } else if (e.kind == MoonEventKind.rise && rise == null) {
          rise = e.utc;
        }
      }
    }

    // Window time ahead of now.
    var windowMs = 0;
    for (final (start, end) in windows) {
      final from = start.isAfter(nowUtc) ? start : nowUtc;
      if (end.isAfter(from)) windowMs += end.difference(from).inMilliseconds;
    }

    // Plan time left in the window.
    var planMs = 0;
    for (final b in blocks) {
      final inWindow =
          b.frameType == FrameType.light ||
          b.calibrationPolicy == CalibrationPolicy.inWindow;
      if (!inWindow) continue;
      final left = b.frameCount - state.completedFor(b.id);
      if (left <= 0) continue;
      planMs +=
          (left * (b.exposureTimeSeconds + perFrameOverheadSeconds) * 1000)
              .round();
    }

    return ExecutionOutlook(
      astronomicalDawnUtc: dawn,
      targetBelowLimitUtc: below,
      targetBelowLimitNow: belowNow,
      moonriseUtc: rise,
      moonUp: up,
      remainingWindow: Duration(milliseconds: windowMs),
      remainingPlan: Duration(milliseconds: planMs),
    );
  }
}
