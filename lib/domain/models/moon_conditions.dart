import '../services/moon_calculator.dart';
import 'night_timeline.dart';
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

  /// The Moon during the night's dark span [dark] (S6.13; UX-17; CALC-43):
  /// the same measure as the imaging windows' Moon note (ADR-013): the
  /// samples on the night's 5-minute grid inside the dark span, and those
  /// with the Moon above the horizon (altitude > 0°), each worth one step.
  /// Null when there is no dark span.
  MoonDuringDark? duringDark(SunThresholdResult dark) {
    final spans = _darkSpans(dark);
    if (spans.isEmpty || samples.length < 2) return null;
    final step = samples[1].instantUtc.difference(samples[0].instantUtc);
    bool inDark(DateTime t) =>
        spans.any((s) => !t.isBefore(s.$1) && t.isBefore(s.$2));
    var darkSamples = 0;
    var up = 0;
    for (final s in samples) {
      if (!inDark(s.instantUtc)) continue;
      darkSamples++;
      if (s.altitudeDeg > 0) up++;
    }
    if (darkSamples == 0) return null;
    return MoonDuringDark(
      dark: step * darkSamples,
      moonUp: step * up,
      illumination: illuminationAtMidnight,
    );
  }

  /// The dark span's intervals within the night: one, or two when the Sun
  /// is already below the limit at the start and sets below it again later.
  List<(DateTime, DateTime)> _darkSpans(SunThresholdResult dark) =>
      switch (dark) {
        SunNeverBelow() => const [],
        SunAlwaysBelow() => [(night.startUtc, night.endUtc)],
        SunCrossing(:final duskUtc, :final dawnUtc) => switch ((
          duskUtc,
          dawnUtc,
        )) {
          (final dusk?, final dawn?) when dusk.isBefore(dawn) => [(dusk, dawn)],
          (final dusk?, final dawn?) => [
            (night.startUtc, dawn),
            (dusk, night.endUtc),
          ],
          (final dusk?, null) => [(dusk, night.endUtc)],
          (null, final dawn?) => [(night.startUtc, dawn)],
          (null, null) => const [],
        },
      };
}

/// The Moon while it is dark at the user's limit (S6.13; CALC-43): how
/// long the dark span is, how much of it the Moon is up, and its
/// illumination at mean solar midnight (the night's value, SCI-09). A fact,
/// never an "impact" (ADR-010).
class MoonDuringDark {
  const MoonDuringDark({
    required this.dark,
    required this.moonUp,
    required this.illumination,
  });

  /// The dark span, on the night's grid.
  final Duration dark;

  /// How much of [dark] the Moon is above the horizon.
  final Duration moonUp;

  /// Illuminated fraction 0–1 at mean solar midnight.
  final double illumination;

  bool get moonDown => moonUp == Duration.zero;
  bool get upAllDark => moonUp >= dark;
}
