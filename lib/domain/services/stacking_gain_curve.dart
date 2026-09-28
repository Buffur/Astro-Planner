import 'dart:math' as math;

import 'optical_calculator.dart';

/// One point of a [StackingGainCurve]: after [frames] frames of one group,
/// the random noise is [gain] times lower than in one frame of that group.
class GainPoint {
  const GainPoint(this.frames, this.gain);

  final int frames;
  final double gain;

  @override
  bool operator ==(Object other) =>
      other is GainPoint && other.frames == frames && other.gain == gain;

  @override
  int get hashCode => Object.hash(frames, gain);

  @override
  String toString() => 'GainPoint($frames, $gain)';
}

/// How the relative stacking gain grows with the frame count, for one group
/// of light frames with one filter and one exposure (S6.11; P6.10; CALC-42).
/// The same formula as the figure it illustrates, √N (CALC-15), sampled from
/// one frame to [maxFrames] (twice the planned count, at least 4), so the
/// flattening is visible. Relative to one frame of the group (SI-003): never
/// a signal-to-noise ratio, a noise model or an image-quality prediction,
/// and never combined across groups. A graph draws these points and
/// computes nothing.
class StackingGainCurve {
  StackingGainCurve._(this.frames, this.maxFrames, this.points);

  /// The curve for a group of [frames] planned frames, with at most
  /// [samples] points (at least 2); always includes one frame, [frames]
  /// and [maxFrames]. Null-free: [frames] below 1 gives a curve with no
  /// marked point beyond the start.
  factory StackingGainCurve.of(int frames, {int samples = 32}) {
    final planned = math.max(frames, 1);
    final maxFrames = math.max(4, 2 * planned);
    final n = math.max(samples, 2);
    final counts = <int>{
      for (var i = 0; i < n; i++) 1 + ((maxFrames - 1) * i / (n - 1)).round(),
      planned,
    }.toList()..sort();
    return StackingGainCurve._(frames, maxFrames, [
      for (final c in counts)
        GainPoint(c, OpticalCalculator.calculateRelativeStackingGain(c)),
    ]);
  }

  /// The planned count (the marked point).
  final int frames;

  /// Where the curve ends: twice [frames], at least 4.
  final int maxFrames;

  /// Increasing in frames, from 1 to [maxFrames].
  final List<GainPoint> points;

  /// The marked value: √[frames] (0 without frames), as the group's figure.
  double get markedGain =>
      OpticalCalculator.calculateRelativeStackingGain(frames);

  /// The gain at [maxFrames], the curve's end.
  double get endGain => points.last.gain;
}
