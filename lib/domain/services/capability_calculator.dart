import 'dart:math' as math;

import '../models/astro_target.dart';
import '../models/equipment_profile.dart';
import '../models/tracking_type.dart';
import 'optical_calculator.dart';

/// The NPF recommendation for one rig and target (TASK 8.6, PD-11).
class NpfGuidance {
  const NpfGuidance({
    required this.seconds,
    required this.k,
    required this.declinationUsedDeg,
    required this.conditional,
  });

  /// Longest untracked sub-exposure before visible trailing, s.
  final double seconds;

  /// The k used (star-trail tolerance, 1–3).
  final double k;

  /// The |declination| used: the field's minimum (PD-11 decision), degrees.
  final double declinationUsedDeg;

  /// True when the rig's tracking is unknown: the figure applies only if the
  /// rig is in fact untracked.
  final bool conditional;
}

/// What a rig can do for a target (TASK 8.6). Guidance only — never a limit
/// that blocks a plan (ADR-011 §5).
class RigCapability {
  const RigCapability({
    required this.fovWidthDeg,
    required this.fovHeightDeg,
    required this.fovDiagonalDeg,
    required this.pixelScaleArcsecPerPx,
    required this.npf,
    required this.recommendedMaxSubS,
    required this.recommendationIsConditional,
    required this.frameFillFraction,
  });

  /// Field of view, degrees.
  final double fovWidthDeg;
  final double fovHeightDeg;
  final double fovDiagonalDeg;

  /// Image scale, arcsec per pixel.
  final double pixelScaleArcsecPerPx;

  /// NPF, for an untracked rig or one whose tracking is unknown and when a
  /// target is known; otherwise null.
  final NpfGuidance? npf;

  /// Recommended maximum light sub-exposure, s (ADR-011 §5): min(NPF, the
  /// rig's maximum exposure) for an untracked rig; for unknown tracking the
  /// same, flagged [recommendationIsConditional]; the rig's maximum exposure
  /// for a tracked or guided rig. Null when nothing is known.
  final double? recommendedMaxSubS;

  /// True when [recommendedMaxSubS] rests on NPF for a rig of unknown
  /// tracking ("if untracked").
  final bool recommendationIsConditional;

  /// The target's angular size over the shorter side of the field
  /// (e.g. 0.5 = half the frame height); null when the size is unknown.
  final double? frameFillFraction;

  /// Whether a light sub of [exposureS] exceeds the recommendation.
  bool exceedsRecommendation(double exposureS) {
    final limit = recommendedMaxSubS;
    return limit != null && exposureS > limit;
  }
}

/// Capability summary and exposure guidance (TASK 8.6; PD-11 decisions).
abstract final class CapabilityCalculator {
  /// [tracking] is the plan's effective tracking (RD-08 = T3; S7.1); without
  /// one, the rig's default.
  static RigCapability evaluate(
    EquipmentProfile rig, {
    AstroTarget? target,
    double npfK = 1.0,
    TrackingType? tracking,
  }) {
    final trackingType = tracking ?? rig.trackingType;
    final f = rig.focalLengthMm;
    final width = OpticalCalculator.calculateFOV(
      sensorDimension: rig.sensorWidthMm,
      effectiveFocalLength: f,
    );
    final height = OpticalCalculator.calculateFOV(
      sensorDimension: rig.sensorHeightMm,
      effectiveFocalLength: f,
    );
    final diagonal = OpticalCalculator.calculateFOV(
      sensorDimension: math.sqrt(
        rig.sensorWidthMm * rig.sensorWidthMm +
            rig.sensorHeightMm * rig.sensorHeightMm,
      ),
      effectiveFocalLength: f,
    );
    final scale = OpticalCalculator.calculatePixelScale(
      pixelPitch: rig.pixelPitchUm,
      effectiveFocalLength: f,
    );

    final npfApplies =
        trackingType == TrackingType.untracked ||
        trackingType == TrackingType.unknown;
    NpfGuidance? npf;
    if (npfApplies && target != null) {
      final decUsed = fieldMinimumDeclinationDeg(
        target.declination,
        fovDiagonalDeg: diagonal,
      );
      npf = NpfGuidance(
        seconds: OpticalCalculator.calculateNPFExposure(
          apertureFNumber: rig.focalRatio,
          pixelPitch: rig.pixelPitchUm,
          effectiveFocalLength: f,
          declinationDegrees: decUsed,
          k: npfK,
        ),
        k: npfK,
        declinationUsedDeg: decUsed,
        conditional: trackingType == TrackingType.unknown,
      );
    }

    final maxExp = rig.maxExposureS;
    double? recommended;
    if (npf != null) {
      recommended = maxExp == null
          ? npf.seconds
          : math.min(npf.seconds, maxExp);
    } else {
      recommended = maxExp;
    }

    final size = target?.angularSizeArcmin;
    final shortSideArcmin = math.min(width, height) * 60;
    return RigCapability(
      fovWidthDeg: width,
      fovHeightDeg: height,
      fovDiagonalDeg: diagonal,
      pixelScaleArcsecPerPx: scale,
      npf: npf,
      recommendedMaxSubS: recommended,
      recommendationIsConditional:
          npf != null && npf.conditional && recommended == npf.seconds,
      frameFillFraction: (size == null || shortSideArcmin <= 0)
          ? null
          : size / shortSideArcmin,
    );
  }

  /// The minimum |declination| over the field (Michaud's rule for NPF,
  /// PD-11 decision): the target's |δ| minus half the field diagonal — the
  /// field's rotation is unknown, so the diagonal is the conservative extent
  /// — floored at 0 when the field reaches the celestial equator.
  static double fieldMinimumDeclinationDeg(
    double targetDeclinationDeg, {
    required double fovDiagonalDeg,
  }) => math.max(0.0, targetDeclinationDeg.abs() - fovDiagonalDeg / 2);
}
