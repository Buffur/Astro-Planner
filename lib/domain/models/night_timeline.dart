import 'session_night.dart';

/// The Sun's relationship to one altitude threshold h across a
/// [SessionNight] window (ADR-007 §8). Exactly one of [SunCrossing],
/// [SunNeverBelow] or [SunAlwaysBelow] applies; "not reached" is never a
/// bare `null` (SI-008).
sealed class SunThresholdResult {
  const SunThresholdResult(this.thresholdDeg);

  /// The Sun-altitude threshold h, in degrees (for example -18 for
  /// astronomical twilight).
  final double thresholdDeg;
}

/// The Sun crosses h at least once during the window.
///
/// [duskUtc] is the instant it goes below h; [dawnUtc] is the instant it
/// goes back above h. Either can be `null` when that edge of the "below"
/// interval falls outside the window: [belowAtStart] means the Sun was
/// already below h at `startUtc` (no dusk in this window), [belowAtEnd]
/// means it is still below h at `endUtc` (no dawn in this window).
class SunCrossing extends SunThresholdResult {
  const SunCrossing(
    super.thresholdDeg, {
    this.duskUtc,
    this.dawnUtc,
    this.belowAtStart = false,
    this.belowAtEnd = false,
  });

  final DateTime? duskUtc;
  final DateTime? dawnUtc;
  final bool belowAtStart;
  final bool belowAtEnd;
}

/// The Sun stays at or above h for the whole window (midnight sun at
/// h = -0.833°; no astronomical darkness at h = -18°, ADR-007 T15).
class SunNeverBelow extends SunThresholdResult {
  const SunNeverBelow(super.thresholdDeg);
}

/// The Sun stays below h for the whole window (polar night at
/// h = -0.833°, ADR-007 T14 — astronomical dusk/dawn can still exist as
/// their own, separate [SunCrossing]).
class SunAlwaysBelow extends SunThresholdResult {
  const SunAlwaysBelow(super.thresholdDeg);
}

/// The Sun's dusk/dawn timeline for one [SessionNight], at the four
/// standard altitude thresholds (ADR-007 §8, §9). Replaces the old
/// `Map<String, DateTime?>` (TD-024): every field is a typed result, never
/// a bare null.
class NightTimeline {
  const NightTimeline({
    required this.night,
    required this.sunriseSunset,
    required this.civilTwilight,
    required this.nauticalTwilight,
    required this.astronomicalTwilight,
  });

  final SessionNight night;

  /// h = -0.833° (apparent horizon, with mean refraction).
  final SunThresholdResult sunriseSunset;

  /// h = -6°.
  final SunThresholdResult civilTwilight;

  /// h = -12°.
  final SunThresholdResult nauticalTwilight;

  /// h = -18°. The most common "dark enough to image" limit, but any
  /// product-facing darkness limit is a separate, configurable parameter
  /// (ADR-007 §14) — see `VisibilityCalculator.calculateVisibilityWindowsForNight`.
  final SunThresholdResult astronomicalTwilight;
}
