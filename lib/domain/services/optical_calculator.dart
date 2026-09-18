import 'dart:math' as math;

/// Service for calculating optical parameters and equipment capabilities.
class OpticalCalculator {
  /// Calculates the effective focal length of the optical system.
  /// Inputs: native focal length (mm), optical multiplier (e.g. 0.8x reducer).
  /// Output: Effective focal length (mm).
  static double calculateEffectiveFocalLength({
    required double focalLength,
    double opticalMultiplier = 1.0,
  }) {
    return focalLength * opticalMultiplier;
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
    final radians = 2.0 * math.atan(sensorDimension / (2.0 * effectiveFocalLength));
    return radians * (180.0 / math.pi);
  }

  /// Calculates relative stacking gain.
  /// Formula: gain ∝ sqrt(N)
  /// Note: This is relative gain, not absolute SNR.
  /// Inputs: number of light frames (N).
  /// Output: multiplier of signal improvement over a single frame.
  static double calculateRelativeStackingGain(int lightFrames) {
    if (lightFrames <= 0) return 0.0;
    return math.sqrt(lightFrames);
  }

  /// Estimates theoretical payload size for a single raw frame.
  /// Inputs: width (pixels), height (pixels), bitDepth (e.g., 14, 16).
  /// Output: Estimated size in Megabytes (MB).
  static double estimateTheoreticalFrameSizeMB({
    required int resolutionWidth,
    required int resolutionHeight,
    required int bitDepth,
  }) {
    final bits = resolutionWidth * resolutionHeight * bitDepth;
    return bits / (8 * 1024 * 1024);
  }

  /// Estimates empirical frame size for an uncompressed RAW file.
  /// Most cameras store 12-bit and 14-bit pixels inside 16-bit (2 byte) memory blocks.
  /// This includes a small constant overhead for EXIF and embedded JPEG thumbnails.
  static double estimateEmpiricalFrameSizeMB({
    required int resolutionWidth,
    required int resolutionHeight,
  }) {
    // 2 bytes per pixel for 16-bit word padding
    final payloadBytes = resolutionWidth * resolutionHeight * 2;
    // Base payload size + ~1.5 MB for metadata/embedded JPEG
    return (payloadBytes / (1024 * 1024)) + 1.5;
  }

  /// Calculates the NPF rule exposure limit for untracked astrophotography.
  /// This calculates the maximum recommended exposure time to limit visible star trailing.
  /// 
  /// Formula: t = (16.856 * N + 13.713 * p + 90) / (f * cos(declination))
  /// N = aperture (f-number)
  /// p = pixel pitch (microns)
  /// f = effective focal length (mm)
  /// declination = target declination (degrees)
  /// Output: exposure time in seconds.
  static double calculateNPFExposure({
    required double apertureFNumber,
    required double pixelPitch,
    required double effectiveFocalLength,
    required double declinationDegrees,
  }) {
    if (effectiveFocalLength <= 0) throw ArgumentError('Effective focal length must be positive.');
    if (apertureFNumber <= 0) throw ArgumentError('Aperture must be positive.');
    
    // declination in radians
    final declinationRadians = declinationDegrees * (math.pi / 180.0);
    
    // Limit declination to avoid division by zero near poles
    final clampedDec = math.min(declinationRadians.abs(), 89.9 * (math.pi / 180.0));

    final n = apertureFNumber;
    final p = pixelPitch;
    final f = effectiveFocalLength;
    
    return (16.856 * n + 13.713 * p + 90.0) / (f * math.cos(clampedDec));
  }
}
