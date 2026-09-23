/// One forecast hour (ADR-012 §3), at a UTC instant. Every value is nullable:
/// a value the provider did not return is **unknown**, never 0 (SI-008).
class WeatherHour {
  const WeatherHour({
    required this.timeUtc,
    this.cloudCoverPct,
    this.cloudCoverLowPct,
    this.cloudCoverMidPct,
    this.cloudCoverHighPct,
    this.precipitationProbabilityPct,
    this.windSpeedKmh,
    this.windGustsKmh,
    this.temperatureC,
    this.dewPointC,
    this.relativeHumidityPct,
    this.visibilityM,
  });

  /// Start of the hour, UTC.
  final DateTime timeUtc;

  /// Total cloud cover, % (a model area fraction).
  final double? cloudCoverPct;

  /// Cloud below 3 km incl. fog / 3–8 km / above 8 km, %.
  final double? cloudCoverLowPct;
  final double? cloudCoverMidPct;
  final double? cloudCoverHighPct;

  /// Chance of precipitation, %; not every model provides it.
  final double? precipitationProbabilityPct;

  /// Wind at 10 m, km/h.
  final double? windSpeedKmh;

  /// Maximum gust at 10 m during the **preceding** hour, km/h.
  final double? windGustsKmh;

  /// Air temperature and dew point at 2 m, °C.
  final double? temperatureC;
  final double? dewPointC;

  /// Relative humidity at 2 m, %.
  final double? relativeHumidityPct;

  /// Horizontal visibility, m — **not** sky transparency.
  final double? visibilityM;
}

/// A forecast fetched for a site and a UTC interval (ADR-012; TASK 9.2):
/// hourly values with the provider, the model requested and when it was
/// fetched, all in UTC.
class WeatherSnapshot {
  const WeatherSnapshot({
    required this.provider,
    required this.model,
    required this.fetchedAtUtc,
    required this.latitude,
    required this.longitude,
    required this.hours,
  });

  /// e.g. `open-meteo`.
  final String provider;

  /// The model requested, e.g. `best_match` (ADR-012 §2).
  final String model;

  /// When the forecast was fetched, UTC (for staleness, TASK 9.3).
  final DateTime fetchedAtUtc;

  /// The site the forecast was requested for (decimal degrees).
  final double latitude;
  final double longitude;

  /// Hours in ascending UTC order.
  final List<WeatherHour> hours;

  /// Provenance id (ADR-008 §6), e.g. `provider:open-meteo/best_match`.
  String get source => 'provider:$provider/$model';
}

/// Why a forecast could not be fetched (ADR-012; TASK 9.2).
enum WeatherFailure {
  /// The requested night lies entirely beyond the provider's horizon.
  outOfRange,

  /// Network error, timeout or an HTTP error status.
  unavailable,

  /// The response could not be understood.
  malformed,
}

/// The outcome of a forecast request.
sealed class WeatherFetch {
  const WeatherFetch();
}

final class WeatherFetched extends WeatherFetch {
  const WeatherFetched(this.snapshot);

  final WeatherSnapshot snapshot;
}

final class WeatherFetchFailed extends WeatherFetch {
  const WeatherFetchFailed(this.failure, [this.detail]);

  final WeatherFailure failure;
  final String? detail;
}
