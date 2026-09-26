import 'dart:math' as math;

import '../models/equipment_limits.dart';

/// CALC-40 (ADR-018 §4): an **estimate** of a camera's sensor size and
/// effective pixel pitch from what a phone or compact camera writes: the
/// real focal length f, the 35 mm-equivalent focal length f₃₅ and the
/// image's pixel dimensions.
///
/// - crop factor = f₃₅ / f;
/// - sensor diagonal = 43.27 mm (the 36 × 24 mm frame's diagonal) / crop;
/// - the sides follow the long:short pixel ratio;
/// - pixel pitch = long side (mm) / long side (px), in µm: the pitch **of the
///   output mode** (binned or full resolution), which is what the planner's
///   pixel scale needs.
///
/// Assumptions, stated wherever the estimate is shown: f₃₅ is the diagonal
/// equivalent (EXIF does not say whether it matches the diagonal or the
/// width; the two differ by about 4 % for a 4:3 sensor), and f₃₅ is stored
/// as a whole number (±0.5 mm). The result is only ever `estimated`.
class SensorGeometryEstimate {
  const SensorGeometryEstimate._({
    required this.widthMm,
    required this.heightMm,
    required this.pixelPitchUm,
    required this.cropFactor,
  });

  /// The 36 × 24 mm frame's diagonal, mm.
  static final fullFrameDiagonalMm = math.sqrt(36 * 36 + 24 * 24);

  /// The long side, mm.
  final double widthMm;

  /// The short side, mm.
  final double heightMm;

  /// The effective pixel pitch of the output mode, µm.
  final double pixelPitchUm;

  /// f₃₅ / f, dimensionless.
  final double cropFactor;

  /// The estimate, or null when it cannot be made: an input is not positive,
  /// f₃₅ is not longer than f (no crop, or inconsistent values), or a result
  /// is outside [EquipmentLimits]. Never a partial estimate.
  static SensorGeometryEstimate? of({
    required double focalLengthMm,
    required double focalLength35mmEquivalentMm,
    required int longSidePx,
    required int shortSidePx,
  }) {
    if (!(focalLengthMm > 0) ||
        !(focalLength35mmEquivalentMm > focalLengthMm) ||
        shortSidePx <= 0 ||
        longSidePx < shortSidePx) {
      return null;
    }
    final crop = focalLength35mmEquivalentMm / focalLengthMm;
    final diagonalMm = fullFrameDiagonalMm / crop;
    final diagonalPx = math.sqrt(
      longSidePx * longSidePx + shortSidePx * shortSidePx,
    );
    final widthMm = diagonalMm * longSidePx / diagonalPx;
    final heightMm = diagonalMm * shortSidePx / diagonalPx;
    final pitchUm = widthMm / longSidePx * 1000;
    if (!EquipmentLimits.sensorSideMm.contains(widthMm) ||
        !EquipmentLimits.sensorSideMm.contains(heightMm) ||
        !EquipmentLimits.pixelPitchUm.contains(pitchUm)) {
      return null;
    }
    return SensorGeometryEstimate._(
      widthMm: widthMm,
      heightMm: heightMm,
      pixelPitchUm: pitchUm,
      cropFactor: crop,
    );
  }
}
