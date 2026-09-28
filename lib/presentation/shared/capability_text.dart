import '../../domain/models/tracking_type.dart';
import '../../domain/services/capability_calculator.dart';
import 'app_words.dart';

/// Display text for [RigCapability] (TASK 8.6). Formatting only; every
/// figure comes from the domain [CapabilityCalculator].
abstract final class CapabilityText {
  static String _seconds(double s) =>
      s >= 10 ? '${s.round()} s' : '${s.toStringAsFixed(1)} s';

  static String fov(RigCapability c) =>
      '${c.fovWidthDeg.toStringAsFixed(2)}° × ${c.fovHeightDeg.toStringAsFixed(2)}°';

  static String pixelScale(RigCapability c) =>
      '${c.pixelScaleArcsecPerPx.toStringAsFixed(2)} arcsec/px';

  /// e.g. "≈ 12 s (k = 1.0, |δ| 3°) if untracked".
  static String? npf(RigCapability c) {
    final n = c.npf;
    if (n == null) return null;
    return '≈ ${_seconds(n.seconds)} (k = ${n.k.toStringAsFixed(1)}, '
        '|δ| ${n.declinationUsedDeg.round()}°)'
        '${n.conditional ? ' if untracked' : ''}';
  }

  /// e.g. "12 s if untracked"; null when there is no recommendation.
  static String? recommendedMaxSub(RigCapability c) {
    final r = c.recommendedMaxSubS;
    if (r == null) return null;
    return '${_seconds(r)}${c.recommendationIsConditional ? ' if untracked' : ''}';
  }

  /// e.g. "45 % of the frame's short side".
  static String? frameFill(RigCapability c) {
    final f = c.frameFillFraction;
    return f == null ? null : frameFillOf(f);
  }

  /// A frame-fill fraction (CALC-31: the major axis over the frame's short
  /// side), worded the same in the planner and the candidates (SCI-06).
  static String frameFillOf(double fraction) =>
      "${(fraction * 100).round()} % of the frame's short side";

  /// The warning for a light sub longer than the recommendation.
  static String subWarning(RigCapability c) =>
      'Longer than the recommended max sub '
      '(${recommendedMaxSub(c)}) — stars may trail';

  /// The warning with the tracking it rests on (S6.9; RD-08): e.g.
  /// "… — stars may trail (Tracking: Untracked (fixed tripod))".
  static String subWarningFor(RigCapability c, TrackingType tracking) =>
      '${subWarning(c)} (${AppWords.tracking}: ${tracking.label})';

  /// Unknown tracking is a missing input, not a verdict (S6.9, UX-15 (1)):
  /// PD-11's guidance stays conditional ("if untracked").
  static String unknownTracking(RigCapability c) {
    final r = c.recommendedMaxSubS;
    return 'Tracking not set: if this rig is untracked, subs longer than '
        '${r == null ? 'the recommended max' : _seconds(r)} may trail.';
  }
}
