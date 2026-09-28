// S6.11 (P6.10; CALC-42): the relative stacking-gain curve is √N (CALC-15)
// sampled from one frame to twice the planned count; its marked value is
// the group's own figure; it rises ever more slowly.

import 'dart:math' as math;

import 'package:astroplan/domain/services/capture_budget_calculator.dart';
import 'package:astroplan/domain/services/stacking_gain_curve.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('from one frame (gain 1) to twice the planned count, each point '
      'exactly √N', () {
    final c = StackingGainCurve.of(100);
    expect(c.maxFrames, 200);
    expect(c.points.first, const GainPoint(1, 1));
    expect(c.points.last.frames, 200);
    for (final p in c.points) {
      expect(p.gain, math.sqrt(p.frames));
    }
    expect(c.points.length, lessThanOrEqualTo(33)); // 32 samples + planned
  });

  test('the planned count is a point, and the marked value is the group\'s '
      'figure', () {
    for (final n in [1, 2, 7, 100, 999]) {
      final c = StackingGainCurve.of(n);
      final group = LightGroup(filterName: 'Ha', exposureMs: 60000, frames: n);
      expect(c.points.map((p) => p.frames), contains(n), reason: '$n');
      expect(c.markedGain, group.relativeStackingGain, reason: '$n');
      expect(group.gainCurve.points, c.points, reason: '$n');
    }
  });

  test('at least four frames wide, so a single frame still shows a curve', () {
    final c = StackingGainCurve.of(1);
    expect(c.maxFrames, 4);
    expect(c.points.map((p) => p.frames), [1, 2, 3, 4]);
    expect(c.endGain, 2);
  });

  test('increasing, with ever smaller steps: the gain flattens', () {
    final c = StackingGainCurve.of(60, samples: 16);
    final frames = c.points.map((p) => p.frames).toList();
    expect(frames, [...frames]..sort());
    expect(frames.toSet(), hasLength(frames.length), reason: 'no duplicates');
    double slope(int i) =>
        (c.points[i + 1].gain - c.points[i].gain) /
        (c.points[i + 1].frames - c.points[i].frames);
    for (var i = 0; i + 2 < c.points.length; i++) {
      expect(slope(i + 1), lessThan(slope(i)), reason: 'at $i');
    }
  });

  test('no frames: nothing marked beyond the start; the gain is 0', () {
    final c = StackingGainCurve.of(0);
    expect(c.markedGain, 0);
    expect(c.points.first, const GainPoint(1, 1));
  });
}
