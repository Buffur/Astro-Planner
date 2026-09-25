import 'weather_snapshot.dart';

/// How old a forecast is (ADR-012 §6; TASK 9.3).
enum WeatherAge {
  /// Fetched less than [WeatherFreshness.agingAfter] ago.
  current,

  /// Between [WeatherFreshness.agingAfter] and [WeatherFreshness.staleAfter].
  aging,

  /// Older than [WeatherFreshness.staleAfter]: shown, clearly labelled.
  stale,
}

/// The freshness thresholds (ADR-012 §6). Assumptions, not physics: model
/// runs update every few hours, so 3 h tracks them.
abstract final class WeatherFreshness {
  static const Duration agingAfter = Duration(hours: 3);
  static const Duration staleAfter = Duration(hours: 12);

  static WeatherAge ageOf(DateTime fetchedAtUtc, DateTime nowUtc) {
    final age = nowUtc.difference(fetchedAtUtc);
    if (age >= staleAfter) return WeatherAge.stale;
    if (age >= agingAfter) return WeatherAge.aging;
    return WeatherAge.current;
  }
}

/// The weather for the chosen night, as the planner sees it (TASK 9.3).
sealed class NightWeather {
  const NightWeather();

  /// Worth loading again when the app returns to the foreground (S1.3): a
  /// forecast that is no longer current, or none because loading failed.
  bool get isOutdated => switch (this) {
    NightWeatherAvailable(:final age) => age != WeatherAge.current,
    NightWeatherUnavailable() => true,
    _ => false,
  };
}

/// No site or night to forecast for, or not loaded yet.
final class NightWeatherIdle extends NightWeather {
  const NightWeatherIdle();
}

final class NightWeatherLoading extends NightWeather {
  const NightWeatherLoading();
}

/// A forecast is available — fresh from the provider or from the cache.
final class NightWeatherAvailable extends NightWeather {
  const NightWeatherAvailable({
    required this.snapshot,
    required this.age,
    required this.ageDuration,
    required this.fromCache,
    this.refreshFailed,
  });

  final WeatherSnapshot snapshot;
  final WeatherAge age;

  /// Time since [WeatherSnapshot.fetchedAtUtc].
  final Duration ageDuration;

  /// True when served from the cache (not fetched just now).
  final bool fromCache;

  /// Set when a refresh was attempted and failed, so the cached data is
  /// shown instead ("offline, cached") — never presented as current.
  final WeatherFailure? refreshFailed;

  /// This forecast as it stands at [nowUtc]: the age recomputed through
  /// [WeatherFreshness], everything else unchanged (ADR-012 §6; S1.3).
  NightWeatherAvailable at(DateTime nowUtc) => NightWeatherAvailable(
    snapshot: snapshot,
    age: WeatherFreshness.ageOf(snapshot.fetchedAtUtc, nowUtc),
    ageDuration: nowUtc.difference(snapshot.fetchedAtUtc),
    fromCache: fromCache,
    refreshFailed: refreshFailed,
  );
}

/// The night lies beyond the provider's horizon ("no forecast yet").
final class NightWeatherOutOfRange extends NightWeather {
  const NightWeatherOutOfRange();
}

/// The forecast could not be fetched and nothing is cached.
final class NightWeatherUnavailable extends NightWeather {
  const NightWeatherUnavailable(this.failure);

  final WeatherFailure failure;
}
