import '../services/moon_calculator.dart';
import 'session_night.dart';

/// The Moon at one instant of the night grid.
class MoonSample {
  const MoonSample({
    required this.instantUtc,
    required this.altitudeDeg,
    required this.separationDeg,
    required this.targetAltitudeDeg,
  });

  final DateTime instantUtc;

  /// Topocentric geometric (airless) altitude of the Moon's centre, degrees.
  final double altitudeDeg;

  /// Topocentric Moon–target separation, degrees; null without a target.
  final double? separationDeg;

  /// The target's altitude at this instant, degrees; null without a target.
  final double? targetAltitudeDeg;
}

/// The closest approach of Moon and target while both are above the
/// horizon (altitude > 0°).
class MoonApproach {
  const MoonApproach({required this.separationDeg, required this.instantUtc});
  final double separationDeg;
  final DateTime instantUtc;
}

/// Moon context for one night and (optionally) one target — annotations
/// only, never an "impact %" (ADR-010, TASK 6.4).
class MoonConditions {
  const MoonConditions({
    required this.night,
    required this.samples,
    required this.riseSet,
    required this.illuminationAtMidnight,
    required this.closestApproachWhileBothUp,
  });

  final SessionNight night;

  /// On the night's 5-minute grid, inclusive of both ends (ADR-007 §9).
  final List<MoonSample> samples;

  /// Moonrise/moonset within the night (Meeus ch. 15 convention).
  final MoonRiseSet riseSet;

  /// Illuminated fraction 0–1 at mean solar midnight (`startUtc + 12 h`),
  /// the night's single evaluation instant for night-level scalars (ADR-007
  /// §9 candidate, adopted by TASK 6.4). It changes by at most about 6
  /// percentage points across one night.
  final double illuminationAtMidnight;

  /// Null when there is no target, or the Moon and the target are never
  /// above the horizon at the same time during the night.
  final MoonApproach? closestApproachWhileBothUp;

  /// Intervals when the Moon is up within the night, from [riseSet].
  List<(DateTime, DateTime)> get upIntervals {
    final out = <(DateTime, DateTime)>[];
    DateTime? start = riseSet.aboveAtStart ? night.startUtc : null;
    for (final e in riseSet.events) {
      if (e.kind == MoonEventKind.rise) {
        start = e.utc;
      } else if (start != null) {
        out.add((start, e.utc));
        start = null;
      }
    }
    if (start != null) out.add((start, night.endUtc));
    return out;
  }
}
