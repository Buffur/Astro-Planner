import 'night_weather.dart';
import 'session_night.dart';
import 'sky_darkness.dart';
import 'visibility_window.dart';

/// A condition that can exclude time from an imaging window (ADR-013 §2).
///
/// The horizon gate (G3) is reserved by ADR-013 but has no input in 1.0, so
/// it has no value here; the minimum altitude stands in for it.
enum OpportunityGate {
  /// G1: the Sun is above the darkness limit.
  darkness,

  /// G2: the target is below the minimum altitude.
  altitude,

  /// G4 (optional, user-enabled): the Moon is up and at least X % lit.
  moon,

  /// G5 (optional, user-enabled): the hour's total cloud cover is above Y %.
  cloud,
}

/// The optional, user-enabled gates (ADR-013 §2; off by default).
class OptionalGates {
  const OptionalGates({this.moonMinIlluminationPct, this.cloudMaxPct});

  /// Exclude time when the Moon is up and at least this lit, %; null = off.
  final double? moonMinIlluminationPct;

  /// Exclude hours whose total cloud cover is above this, %; null = off.
  final double? cloudMaxPct;

  static const OptionalGates none = OptionalGates();

  @override
  bool operator ==(Object other) =>
      other is OptionalGates &&
      other.moonMinIlluminationPct == moonMinIlluminationPct &&
      other.cloudMaxPct == cloudMaxPct;

  @override
  int get hashCode => Object.hash(moonMinIlluminationPct, cloudMaxPct);
}

/// One instant of the night's 5-minute grid with the gates that fail there.
/// A sample's state holds for `[instantUtc, next sample)`.
class OpportunitySample {
  const OpportunitySample({
    required this.instantUtc,
    required this.sunAltitudeDeg,
    required this.targetAltitudeDeg,
    required this.failing,
  });

  final DateTime instantUtc;

  /// Geometric (airless) altitudes, degrees.
  final double sunAltitudeDeg;
  final double targetAltitudeDeg;

  /// Every gate that fails at this instant; empty = usable.
  final Set<OpportunityGate> failing;

  bool get usable => failing.isEmpty;
}

/// Time excluded from imaging, with **all** its failing gates (ADR-013 §4).
class ExcludedSegment {
  const ExcludedSegment({
    required this.startUtc,
    required this.endUtc,
    required this.reasons,
  });

  final DateTime startUtc;
  final DateTime endUtc;
  final Set<OpportunityGate> reasons;

  Duration get duration => endUtc.difference(startUtc);
}

/// The Moon during one window (ADR-013 §3). Only present when Moon data was
/// supplied — a missing input is a missing annotation, never "Moon down".
class MoonWindowAnnotation {
  const MoonWindowAnnotation({
    required this.upDuration,
    required this.illumination,
    required this.minSeparationDeg,
  });

  /// Time inside the window with the Moon's centre above 0° (airless).
  final Duration upDuration;

  /// Illuminated fraction 0–1 at mean solar midnight (the night's value).
  final double illumination;

  /// Smallest Moon–target separation while the Moon is up in the window,
  /// degrees; null when the Moon is down for the whole window.
  final double? minSeparationDeg;

  bool get moonDown => upDuration == Duration.zero;
}

/// The forecast during one window (ADR-013 §3). Only present when a forecast
/// was supplied. Hours are the forecast hours whose half-hour neighbourhood
/// `[H − 30 min, H + 30 min)` the window touches.
class WeatherWindowAnnotation {
  const WeatherWindowAnnotation({
    required this.age,
    required this.hours,
    required this.hoursWithoutForecast,
    required this.cloudMinPct,
    required this.cloudMaxPct,
    required this.dewRiskHours,
    required this.dewKnownHours,
  });

  /// The forecast's freshness (ADR-012 §6).
  final WeatherAge age;

  final int hours;

  /// Hours with no total-cloud value ("no forecast", never 0).
  final int hoursWithoutForecast;

  /// Total cloud cover over the covered hours, %; null when none is known.
  final double? cloudMinPct;
  final double? cloudMaxPct;

  /// Hours with temperature − dew point ≤ the dew margin (a heuristic,
  /// CALC-32), and hours where that spread is known.
  final int dewRiskHours;
  final int dewKnownHours;
}

/// One imaging window: the usable interval plus its annotations.
class OpportunityWindow {
  const OpportunityWindow({
    required this.window,
    required this.maxAltitudeDeg,
    required this.maxAltitudeAtUtc,
    required this.moon,
    required this.weather,
  });

  /// The interval (UTC), with the night-edge clip flags (ADR-007 §9).
  final VisibilityWindow window;

  /// The target's highest altitude **inside** this window, degrees, and when.
  final double maxAltitudeDeg;
  final DateTime maxAltitudeAtUtc;

  /// Null when no Moon data was supplied.
  final MoonWindowAnnotation? moon;

  /// Null when no forecast was supplied.
  final WeatherWindowAnnotation? weather;

  DateTime get startUtc => window.start;
  DateTime get endUtc => window.end;
  Duration get duration => window.duration;
}

/// Why a night has no imaging window (ADR-013 §4).
enum NoWindowReason {
  /// The Sun never reaches the darkness limit.
  noDarkness,

  /// The target never reaches the minimum altitude.
  targetNeverHighEnough,

  /// Both happen, but never at the same time.
  targetNeverHighEnoughInDarkness,

  /// Dark time with the target high enough exists, but the user's Moon or
  /// cloud gate excludes all of it.
  excludedByOptionalGates,
}

/// When and why one target can be imaged during one night (ADR-013). Built
/// by `ImagingOpportunityCalculator`; no score.
class ImagingOpportunity {
  const ImagingOpportunity({
    required this.night,
    required this.darknessLimitDeg,
    required this.minAltitudeDeg,
    required this.gates,
    required this.samples,
    required this.windows,
    required this.excluded,
    required this.noWindowReason,
    required this.skyDarkness,
  });

  final SessionNight night;
  final double darknessLimitDeg;
  final double minAltitudeDeg;
  final OptionalGates gates;

  /// The night's grid, inclusive of `night.endUtc` (ADR-007 §9).
  final List<OpportunitySample> samples;

  final List<OpportunityWindow> windows;

  /// The rest of the night, merged where the failing gates are identical.
  final List<ExcludedSegment> excluded;

  /// Null when there is at least one window.
  final NoWindowReason? noWindowReason;

  /// The site's sky darkness as context (ADR-013 §3); null when not given.
  final SkyDarkness? skyDarkness;

  /// Total usable time — the only ranking quantity (ADR-013 §5).
  Duration get usableTime =>
      windows.fold(Duration.zero, (s, w) => s + w.duration);

  /// The target's highest altitude inside any window; null without one.
  double? get maxAltitudeInWindowsDeg => windows.isEmpty
      ? null
      : windows.map((w) => w.maxAltitudeDeg).reduce((a, b) => a > b ? a : b);

  /// The windows as the fit analyzer's input (TASK 5.5 API, unchanged).
  List<VisibilityWindow> get visibilityWindows => [
    for (final w in windows) w.window,
  ];
}
