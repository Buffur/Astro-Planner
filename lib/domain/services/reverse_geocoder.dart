/// Outcome of a reverse-geocoding lookup (TASK 7.2).
sealed class ReverseGeocodeResult {
  const ReverseGeocodeResult();
}

/// A place name for the coordinates, with the attribution its data source
/// requires wherever the name is shown.
final class PlaceNameFound extends ReverseGeocodeResult {
  const PlaceNameFound(this.name, {required this.attribution});

  final String name;

  /// e.g. "© OpenStreetMap contributors" — must be displayed with [name].
  final String attribution;
}

/// The service answered but has no place name for the coordinates (open sea,
/// a remote area).
final class PlaceNameNotFound extends ReverseGeocodeResult {
  const PlaceNameNotFound();
}

/// The lookup failed (offline, timeout, HTTP error, malformed response). The
/// place name is unknown, not absent.
final class ReverseGeocodeFailed extends ReverseGeocodeResult {
  const ReverseGeocodeFailed(this.reason);

  final String reason;
}

/// Turns coordinates into a human-readable place name. Optional enrichment:
/// the app works offline without it (offline-first rule).
abstract class ReverseGeocoder {
  /// [latitude]/[longitude] in decimal degrees (WGS-84, north/east positive).
  /// Never throws; failures are a [ReverseGeocodeFailed].
  Future<ReverseGeocodeResult> placeNameFor(double latitude, double longitude);
}
