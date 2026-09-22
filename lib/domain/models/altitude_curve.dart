import 'session_night.dart';

/// The Sun's and a target's altitude at one instant (ADR-007 §9).
class AltitudeSample {
  const AltitudeSample({
    required this.instantUtc,
    required this.sunAltitudeDeg,
    required this.targetAltitudeDeg,
  });

  final DateTime instantUtc;
  final double sunAltitudeDeg;
  final double targetAltitudeDeg;
}

/// A target's altitude curve across one [SessionNight], sampled on the same
/// 5-minute grid as the night timeline and visibility windows (ADR-007 §9),
/// so all three agree on their instants.
///
/// Computed once in the domain (`VisibilityCalculator.calculateAltitudeCurve`)
/// so presentation code — the altitude chart — only renders; it never
/// samples astronomy itself (TD-023, DEV-A3).
class AltitudeCurve {
  const AltitudeCurve({required this.night, required this.samples});

  final SessionNight night;

  /// [samples.first].instantUtc == night.startUtc;
  /// [samples.last].instantUtc == night.endUtc (inclusive of the boundary,
  /// for chart and edge-crossing purposes, even though the window itself is
  /// half-open); every step in between is exactly 5 minutes.
  final List<AltitudeSample> samples;
}
