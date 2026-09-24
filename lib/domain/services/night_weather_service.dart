import '../../core/diagnostics/app_log.dart';
import '../../core/time/clock.dart';
import '../models/night_weather.dart';
import '../models/session_night.dart';
import '../models/weather_snapshot.dart';
import '../repositories/weather_repository.dart';
import '../repositories/weather_snapshot_store.dart';

/// Loads the weather for a night: cache first, provider when needed, and a
/// state that never presents old data as current (ADR-012 §6; TASK 9.3).
/// Driven by the injected [Clock].
class NightWeatherService {
  NightWeatherService({
    required this._repository,
    required this._store,
    required this._clock,
    required this.model,
  });

  final WeatherRepository _repository;
  final WeatherSnapshotStore _store;
  final Clock _clock;

  /// The model the repository requests; part of the cache key.
  final String model;

  /// The weather for [night] at the site.
  ///
  /// - A cached snapshot younger than [WeatherFreshness.agingAfter] is used
  ///   as it is, unless [forceRefresh].
  /// - Otherwise the provider is asked; a success is cached and returned.
  /// - Out of range → [NightWeatherOutOfRange].
  /// - Any other failure → the cached snapshot with its age and the failure
  ///   ([NightWeatherAvailable.refreshFailed]), or [NightWeatherUnavailable]
  ///   when nothing is cached.
  Future<NightWeather> load(
    SessionNight night, {
    required double latitude,
    required double longitude,
    bool forceRefresh = false,
  }) async {
    final key = WeatherSnapshotStore.keyFor(
      latitude: latitude,
      longitude: longitude,
      model: model,
      nightStartUtc: night.startUtc,
    );
    final cached = await _readSafely(key);
    final now = _clock.nowUtc();

    if (cached != null && !forceRefresh) {
      final age = WeatherFreshness.ageOf(cached.fetchedAtUtc, now);
      if (age == WeatherAge.current) return _available(cached, now, true);
    }

    final fetched = await _repository.fetchSnapshot(
      latitude: latitude,
      longitude: longitude,
      startUtc: night.startUtc,
      endUtc: night.endUtc,
    );
    switch (fetched) {
      case WeatherFetched(:final snapshot):
        try {
          await _store.write(key, snapshot);
        } catch (e) {
          // A cache that cannot be written only costs a later refetch.
          AppLog.warning('weather', 'Could not cache the forecast', error: e);
        }
        return _available(snapshot, _clock.nowUtc(), false);
      case WeatherFetchFailed(failure: WeatherFailure.outOfRange):
        return const NightWeatherOutOfRange();
      case WeatherFetchFailed(:final failure):
        if (cached == null) return NightWeatherUnavailable(failure);
        return _available(cached, now, true, refreshFailed: failure);
    }
  }

  Future<WeatherSnapshot?> _readSafely(String key) async {
    try {
      return await _store.read(key);
    } catch (e) {
      // An unreadable cache entry is treated as absent.
      AppLog.warning('weather', 'Could not read the forecast cache', error: e);
      return null;
    }
  }

  static NightWeatherAvailable _available(
    WeatherSnapshot s,
    DateTime nowUtc,
    bool fromCache, {
    WeatherFailure? refreshFailed,
  }) => NightWeatherAvailable(
    snapshot: s,
    age: WeatherFreshness.ageOf(s.fetchedAtUtc, nowUtc),
    ageDuration: nowUtc.difference(s.fetchedAtUtc),
    fromCache: fromCache,
    refreshFailed: refreshFailed,
  );
}
