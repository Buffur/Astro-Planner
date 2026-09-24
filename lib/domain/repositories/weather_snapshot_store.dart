import '../models/weather_snapshot.dart';
import 'storage_failure.dart';

/// Persistent cache of weather snapshots (TASK 9.3). Keys are built by
/// [WeatherSnapshotStore.keyFor]; the store only saves and returns them.
///
/// Every method throws [StorageFailure] when the store cannot be read or
/// written (TASK 15.1).
abstract class WeatherSnapshotStore {
  Future<WeatherSnapshot?> read(String key);
  Future<void> write(String key, WeatherSnapshot snapshot);

  /// Cache key for a site (coordinates rounded to 0.01°), a model and a
  /// night (its UTC start): data for another site, model or night is never
  /// returned for this one (ADR-012 §6).
  static String keyFor({
    required double latitude,
    required double longitude,
    required String model,
    required DateTime nightStartUtc,
  }) =>
      'weather:${latitude.toStringAsFixed(2)}:${longitude.toStringAsFixed(2)}'
      ':$model:${nightStartUtc.toUtc().millisecondsSinceEpoch}';
}
