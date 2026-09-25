import 'dart:math' as math;

/// Service for calculating optical parameters and equipment capabilities.
class OpticalCalculator {
  /// Calculates the effective focal length of the optical system.
  /// Inputs: native focal length (mm).
  /// Output: Effective focal length (mm).
  static double calculateEffectiveFocalLength({required double focalLength}) {
    return focalLength;
  }

  /// Calculates the pixel scale (image resolution) in arcseconds per pixel.
  /// Formula: 206.265 * (pixel_pitch_in_microns / effective_focal_length_in_mm)
  /// Inputs: pixelPitch (microns), effectiveFocalLength (mm).
  /// Output: arcseconds/pixel.
  static double calculatePixelScale({
    required double pixelPitch,
    required double effectiveFocalLength,
  }) {
    if (effectiveFocalLength <= 0) return 0.0;
    return 206.265 * (pixelPitch / effectiveFocalLength);
  }

  /// Calculates the Field of View (FOV) dimension in degrees.
  /// Formula: 2 * arctan(sensor_dimension / (2 * effective_focal_length))
  /// Inputs: sensorDimension (mm), effectiveFocalLength (mm).
  /// Output: FOV in decimal degrees.
  static double calculateFOV({
    required double sensorDimension,
    required double effectiveFocalLength,
  }) {
    if (effectiveFocalLength <= 0) return 0.0;
    final radians =
        2.0 * math.atan(sensorDimension / (2.0 * effectiveFocalLength));
    return radians * (180.0 / math.pi);
  }

  /// Calculates relative stacking gain.
  /// Formula: gain ∝ sqrt(N)
  /// Note: This is relative gain, not absolute SNR.
  /// Inputs: number of light frames (N).
  /// Output: the factor by which random noise shrinks relative to one
  /// frame of the same group (SI-003), not an improvement of the signal.
  static double calculateRelativeStackingGain(int lightFrames) {
    if (lightFrames <= 0) return 0.0;
    return math.sqrt(lightFrames);
  }

  /// Estimates the storage requirement for a given number of frames.
  /// Inputs: averageRawFileSizeMB, frameCount.
  /// Output: Estimated size in Megabytes (MB), or null when the equipment's
  /// average RAW file size is unknown — never fabricated as 0.0 (SI-008).
  static double? estimateStorageRequirement({
    required double? averageRawFileSizeMB,
    required int frameCount,
  }) {
    if (averageRawFileSizeMB == null) return null;
    return averageRawFileSizeMB * frameCount;
  }

  /// The complete NPF rule (F. Michaud): the longest **untracked** exposure,
  /// in seconds, before star trailing becomes visible. A recommendation for
  /// fixed-tripod photography, not a limit — it does not apply to tracked or
  /// guided exposures (SI-001). Shown per PD-11 through the rig capability
  /// summary (CALC-31, TASK 8.6) for untracked or unknown tracking.
  ///
  /// Source: F. Michaud, "La Règle NPF" and "Les coulisses de la règle NPF",
  /// Société Astronomique du Havre (sahavre.fr/wp/regle-npf-rule/ and
  /// /les-coulisses-de-la-regle-npf/, read 2026-09-22):
  ///
  ///   t = (k / 2) · (d_Airy + d_seeing + d_Bayer) / v_sensor
  ///
  /// with d_Airy = 4.47 · λ · N (λ = 550 nm), d_seeing = f · 3″, d_Bayer =
  /// 2 · p and v_sensor = f · cos δ / 13713 (13713 ≈ 86164 s / 2π). In usual
  /// units this is
  ///
  ///   t = k · (16.8567 · N + 0.099724 · f + 13.713 · p) / (f · cos δ),
  ///
  /// which Michaud publishes rounded as k · (16.9 N + 0.10 f + 13.7 p) /
  /// (f cos δ); the rounding changes t by under 0.2 %.
  ///
  /// Inputs: [apertureFNumber] N (f-number), [pixelPitch] p (µm),
  /// [effectiveFocalLength] f (mm), [declinationDegrees] δ — per the source,
  /// the **minimum** |declination| of the photographed field, 0 when unknown
  /// (the conservative default) — and [k], the accepted trail in star radii:
  /// 1 (round stars, default) to 3 (slightly elongated).
  ///
  /// |δ| is capped at 89.9° to keep cos δ finite near the pole.
  /// Assumptions (from the source): 3″ seeing, 550 nm, a Bayer sensor, a
  /// moderately aberrated real lens; exceptional seeing or diffraction-
  /// limited optics can make stars finer than predicted.
  static double calculateNPFExposure({
    required double apertureFNumber,
    required double pixelPitch,
    required double effectiveFocalLength,
    required double declinationDegrees,
    double k = 1.0,
  }) {
    if (effectiveFocalLength <= 0) {
      throw ArgumentError('Effective focal length must be positive.');
    }
    if (apertureFNumber <= 0) throw ArgumentError('Aperture must be positive.');
    if (pixelPitch <= 0) throw ArgumentError('Pixel pitch must be positive.');
    if (k < 1 || k > 3) {
      throw ArgumentError.value(k, 'k', 'must be in [1, 3] (Michaud)');
    }

    final clampedDec =
        math.min(declinationDegrees.abs(), 89.9) * (math.pi / 180.0);

    return k *
        (npfApertureCoefficient * apertureFNumber +
            npfFocalCoefficient * effectiveFocalLength +
            npfPixelCoefficient * pixelPitch) /
        (effectiveFocalLength * math.cos(clampedDec));
  }

  /// 13713: the sidereal day over 2π, as rounded by Michaud (s/rad).
  static const double _npfSiderealRate = 13713.0;

  /// ½ · 4.47 · 550 nm · 13713 / 1 mm (Airy term) ≈ 16.8567 s.
  static const double npfApertureCoefficient =
      0.5 * 4.47 * 550e-9 * _npfSiderealRate / 1e-3;

  /// ½ · 2 · 1 µm · 13713 / 1 mm (Bayer term) = 13.713 s/µm.
  static const double npfPixelCoefficient =
      0.5 * 2 * 1e-6 * _npfSiderealRate / 1e-3;

  /// ½ · 3″ (in radians) · 13713 (seeing term) ≈ 0.099724 s/mm.
  static const double npfFocalCoefficient =
      0.5 * 3 * math.pi / (180 * 3600) * _npfSiderealRate;
}
