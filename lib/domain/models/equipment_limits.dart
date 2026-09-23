/// An inclusive plausibility range for one equipment quantity.
class Range {
  const Range(this.min, this.max);

  final double min;
  final double max;

  bool contains(double value) => value.isFinite && value >= min && value <= max;
}

/// Plausibility bounds for equipment input (ADR-011 §4). They are
/// assumptions for input sanity, not physics: wide enough for phones,
/// camera lenses and telescopes, narrow enough to catch unit mistakes
/// (e.g. a diameter typed into the f/ field).
abstract final class EquipmentLimits {
  /// Focal ratio N (dimensionless, f/N). f/0.5 is below any real fast lens.
  static const focalRatio = Range(0.5, 32);

  /// Aperture (entrance-pupil) diameter, mm.
  static const apertureDiameterMm = Range(1, 2000);

  /// Focal length, mm (phone main lenses ~2–10 mm, long telescopes < 20 m).
  static const focalLengthMm = Range(1, 20000);

  /// Pixel pitch, µm.
  static const pixelPitchUm = Range(0.5, 30);

  /// Sensor side, mm.
  static const sensorSideMm = Range(1, 100);

  /// Resolution per side, px.
  static const resolutionPx = Range(100, 30000);

  /// Maximum sub-exposure, s (the capture-block limit, TASK 5.3).
  static const maxExposureS = Range(1, 3600);

  /// Average RAW file size, MB.
  static const rawFileSizeMB = Range(0.1, 1000);

  /// Rotation, degrees.
  static const rotationDeg = Range(-360, 360);

  /// A stored focal ratio above this is flagged for the user to review
  /// (ADR-011 §6): most likely a diameter typed into the f/ field.
  static const reviewFocalRatioAbove = 32.0;

  /// When both N and D are given, f / D must match N within this fraction.
  static const apertureAgreement = 0.01;
}

/// Why an aperture input could not be resolved.
enum ApertureProblem {
  missing,
  focalRatioOutOfRange,
  diameterOutOfRange,
  disagree,
}

/// The result of [resolveAperture]: a focal ratio N (always) and the
/// diameter D in mm (only when given), or a [problem].
class ApertureResolution {
  const ApertureResolution._(this.focalRatio, this.diameterMm, this.problem);

  final double? focalRatio;
  final double? diameterMm;
  final ApertureProblem? problem;

  bool get isValid => problem == null;
}

/// Resolves the aperture a user entered (ADR-011 §4):
/// - D given → N = focalLengthMm / D (and N, if also given, must agree
///   within [EquipmentLimits.apertureAgreement]);
/// - only N given → N, D unknown (never back-filled);
/// - neither → [ApertureProblem.missing].
ApertureResolution resolveAperture({
  required double focalLengthMm,
  double? focalRatio,
  double? diameterMm,
}) {
  ApertureResolution fail(ApertureProblem p) =>
      ApertureResolution._(null, null, p);
  if (diameterMm != null) {
    if (!EquipmentLimits.apertureDiameterMm.contains(diameterMm)) {
      return fail(ApertureProblem.diameterOutOfRange);
    }
    final derived = focalLengthMm / diameterMm;
    if (focalRatio != null &&
        (derived - focalRatio).abs() / focalRatio >
            EquipmentLimits.apertureAgreement) {
      return fail(ApertureProblem.disagree);
    }
    if (!EquipmentLimits.focalRatio.contains(derived)) {
      return fail(ApertureProblem.focalRatioOutOfRange);
    }
    return ApertureResolution._(derived, diameterMm, null);
  }
  if (focalRatio == null) return fail(ApertureProblem.missing);
  if (!EquipmentLimits.focalRatio.contains(focalRatio)) {
    return fail(ApertureProblem.focalRatioOutOfRange);
  }
  return ApertureResolution._(focalRatio, null, null);
}
