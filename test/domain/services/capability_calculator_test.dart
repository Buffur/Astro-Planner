// TASK 8.6: capability summary and untracked guidance (PD-11 decisions).
// Reference values are computed independently in the test:
//   FOV = 2·atan(s / 2f); pixel scale = 206.265·p / f;
//   NPF = k·(16.8567·N + 0.099724·f + 13.713·p) / (f·cos δ) (CALC per SI-001).

import 'dart:math' as math;

import 'package:astroplan/domain/models/astro_target.dart';
import 'package:astroplan/domain/models/equipment_profile.dart';
import 'package:astroplan/domain/models/tracking_type.dart';
import 'package:astroplan/domain/services/capability_calculator.dart';
import 'package:flutter_test/flutter_test.dart';

double _deg(double rad) => rad * 180 / math.pi;
double _fov(double side, double f) => _deg(2 * math.atan(side / (2 * f)));
double _npf(double k, double n, double f, double p, double decDeg) =>
    k *
    (16.8567 * n + 0.099724 * f + 13.713 * p) /
    (f * math.cos(decDeg * math.pi / 180));

EquipmentProfile _rig({
  TrackingType tracking = TrackingType.unknown,
  double? maxExposureS,
  double f = 400,
  double n = 400 / 72,
  double w = 23.5,
  double h = 15.7,
  double p = 3.76,
}) => EquipmentProfile(
  id: 1,
  name: 'rig',
  sensorWidthMm: w,
  sensorHeightMm: h,
  pixelPitchUm: p,
  resolutionWidthPx: 6248,
  resolutionHeightPx: 4176,
  focalLengthMm: f,
  focalRatio: n,
  trackingType: tracking,
  maxExposureS: maxExposureS,
);

AstroTarget _target(double dec, {double? size}) => AstroTarget(
  id: 1,
  catalogId: 'T',
  rightAscension: 0,
  declination: dec,
  type: 'Galaxy',
  angularSizeArcmin: size,
);

void main() {
  test('reference FOV and pixel scale (ASI2600MC at 400 mm)', () {
    final c = CapabilityCalculator.evaluate(_rig());
    expect(c.fovWidthDeg, closeTo(_fov(23.5, 400), 1e-9));
    expect(c.fovHeightDeg, closeTo(_fov(15.7, 400), 1e-9));
    expect(c.fovWidthDeg, closeTo(3.3652, 1e-4));
    expect(c.fovHeightDeg, closeTo(2.2486, 1e-4));
    expect(c.pixelScaleArcsecPerPx, closeTo(206.265 * 3.76 / 400, 1e-9));
    expect(c.npf, isNull, reason: 'no target');
  });

  test('NPF only for untracked or unknown tracking', () {
    final t = _target(30);
    for (final tr in [TrackingType.tracked, TrackingType.guided]) {
      expect(
        CapabilityCalculator.evaluate(_rig(tracking: tr), target: t).npf,
        isNull,
      );
    }
    final untracked = CapabilityCalculator.evaluate(
      _rig(tracking: TrackingType.untracked),
      target: t,
    );
    expect(untracked.npf!.conditional, isFalse);
    expect(untracked.recommendationIsConditional, isFalse);
    final unknown = CapabilityCalculator.evaluate(_rig(), target: t);
    expect(unknown.npf!.conditional, isTrue);
    expect(unknown.recommendationIsConditional, isTrue);
  });

  test('NPF uses the field minimum |δ| (target |δ| − half diagonal)', () {
    final rig = _rig(tracking: TrackingType.untracked);
    final diag = _fov(math.sqrt(23.5 * 23.5 + 15.7 * 15.7), 400);
    final c = CapabilityCalculator.evaluate(rig, target: _target(-30));
    expect(c.npf!.declinationUsedDeg, closeTo(30 - diag / 2, 1e-9));
    expect(
      c.npf!.seconds,
      closeTo(_npf(1, 400 / 72, 400, 3.76, 30 - diag / 2), 1e-3),
    );
    // A field reaching the equator uses δ = 0 (the conservative case).
    final eq = CapabilityCalculator.evaluate(rig, target: _target(1));
    expect(eq.npf!.declinationUsedDeg, 0);
  });

  test('k scales NPF linearly', () {
    final rig = _rig(tracking: TrackingType.untracked);
    final k1 = CapabilityCalculator.evaluate(rig, target: _target(0));
    final k2 = CapabilityCalculator.evaluate(rig, target: _target(0), npfK: 2);
    expect(k2.npf!.seconds, closeTo(2 * k1.npf!.seconds, 1e-9));
    expect(k2.npf!.k, 2);
  });

  test('recommended max sub: min(NPF, max exposure) or the max exposure', () {
    final t = _target(0);
    final npfOnly = CapabilityCalculator.evaluate(
      _rig(tracking: TrackingType.untracked),
      target: t,
    );
    expect(npfOnly.recommendedMaxSubS, npfOnly.npf!.seconds);

    final capped = CapabilityCalculator.evaluate(
      _rig(tracking: TrackingType.untracked, maxExposureS: 0.1),
      target: t,
    );
    expect(capped.recommendedMaxSubS, 0.1);

    final tracked = CapabilityCalculator.evaluate(
      _rig(tracking: TrackingType.guided, maxExposureS: 300),
      target: t,
    );
    expect(tracked.recommendedMaxSubS, 300);
    expect(
      CapabilityCalculator.evaluate(
        _rig(tracking: TrackingType.tracked),
        target: t,
      ).recommendedMaxSubS,
      isNull,
      reason: 'nothing known: no recommendation, no warning',
    );
  });

  test('warning boundaries: equal is fine, longer warns', () {
    final c = CapabilityCalculator.evaluate(
      _rig(tracking: TrackingType.guided, maxExposureS: 300),
    );
    expect(c.exceedsRecommendation(300), isFalse);
    expect(c.exceedsRecommendation(300.1), isTrue);
    expect(c.exceedsRecommendation(60), isFalse);
  });

  test('frame fill: size over the short side of the field', () {
    final c = CapabilityCalculator.evaluate(
      _rig(),
      target: _target(41, size: 177.83),
    );
    expect(c.frameFillFraction, closeTo(177.83 / (_fov(15.7, 400) * 60), 1e-9));
    expect(
      CapabilityCalculator.evaluate(
        _rig(),
        target: _target(41),
      ).frameFillFraction,
      isNull,
    );
  });

  // Roadmap acceptance, domain side: a phone on a tripod with a 30 s block.
  test('a phone with a 30 s sub is warned (NPF of a few seconds)', () {
    final phone = _rig(
      tracking: TrackingType.untracked,
      f: 6.86,
      n: 1.78,
      w: 9.8,
      h: 7.3,
      p: 1.22,
    );
    final c = CapabilityCalculator.evaluate(phone, target: _target(-5));
    expect(c.npf!.seconds, greaterThan(3));
    expect(c.npf!.seconds, lessThan(15));
    expect(c.exceedsRecommendation(30), isTrue);
  });
}
