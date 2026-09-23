import 'weather_snapshot.dart';

/// Which part of the `SessionNight` window the weather summary covers
/// (TASK 9.4, owner decision: sunset to sunrise).
enum NightWeatherSpan {
  /// From sunset to sunrise (h = −0.833°), or a window edge when the Sun is
  /// already down at the start or still down at the end.
  sunsetToSunrise,

  /// The Sun never sets in the window (midnight sun): the whole 24 h
  /// window is shown, labelled as such.
  midnightSun,

  /// The Sun never rises in the window (polar night): the whole 24 h
  /// window is shown, labelled as such.
  polarNight,
}

/// The smallest and largest value of one variable over the covered hours.
class WeatherRange {
  const WeatherRange(this.min, this.max);

  final double min;
  final double max;
}

/// One hour of the night: the forecast hour, or null for "no forecast"
/// (beyond the horizon or missing from the response; ADR-012 §5).
class NightWeatherSlot {
  const NightWeatherSlot({
    required this.timeUtc,
    required this.hour,
    required this.dewSpreadC,
    required this.dewRisk,
  });

  /// Start of the hour, UTC.
  final DateTime timeUtc;

  final WeatherHour? hour;

  /// Air temperature − dew point, °C; null when either is unknown.
  final double? dewSpreadC;

  /// [dewSpreadC] ≤ the configured margin (a heuristic); null when unknown.
  final bool? dewRisk;
}

/// The chosen night's weather as per-hour indicators and per-variable
/// ranges (ADR-012 §3: no score). Built by `NightWeatherSummarizer`.
class NightWeatherSummary {
  const NightWeatherSummary({
    required this.fromUtc,
    required this.toUtc,
    required this.span,
    required this.slots,
    required this.dewMarginC,
    required this.cloudCover,
    required this.cloudCoverLow,
    required this.cloudCoverMid,
    required this.cloudCoverHigh,
    required this.precipitationProbability,
    required this.windSpeed,
    required this.windGusts,
    required this.temperature,
    required this.dewPoint,
    required this.relativeHumidity,
    required this.visibility,
    required this.dewSpread,
  });

  /// The summarised interval `[fromUtc, toUtc)`.
  final DateTime fromUtc;
  final DateTime toUtc;
  final NightWeatherSpan span;

  /// Every hour overlapping `[fromUtc, toUtc)`, in UTC order.
  final List<NightWeatherSlot> slots;

  /// The dew margin used, °C (`PlanningPreferences.dewMarginC`).
  final double dewMarginC;

  /// Ranges over the covered hours; null when no covered hour has a value.
  /// Units: % for cloud, precipitation chance and humidity; km/h for wind
  /// and gusts; °C for temperature, dew point and spread; m for visibility.
  final WeatherRange? cloudCover;
  final WeatherRange? cloudCoverLow;
  final WeatherRange? cloudCoverMid;
  final WeatherRange? cloudCoverHigh;
  final WeatherRange? precipitationProbability;
  final WeatherRange? windSpeed;
  final WeatherRange? windGusts;
  final WeatherRange? temperature;
  final WeatherRange? dewPoint;
  final WeatherRange? relativeHumidity;
  final WeatherRange? visibility;
  final WeatherRange? dewSpread;

  int get totalHours => slots.length;

  /// Hours with a forecast.
  int get coveredHours => slots.where((s) => s.hour != null).length;

  /// Hours whose dew spread is known.
  int get dewKnownHours => slots.where((s) => s.dewRisk != null).length;

  /// Hours at or below the dew margin (a heuristic, not a prediction of
  /// dew on the optics).
  int get dewRiskHours => slots.where((s) => s.dewRisk == true).length;
}
