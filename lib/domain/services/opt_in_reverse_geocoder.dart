import 'reverse_geocoder.dart';

/// Place-name lookups only when the user has switched them on (TASK 16.3,
/// owner decision PD-12): while [enabled] is false nothing is sent to the
/// wrapped service and every position has no name. Nominatim's usage
/// policy asks apps to be able to stop using it without an update; an
/// opt-in that is off by default keeps most installs off it entirely.
class OptInReverseGeocoder implements ReverseGeocoder {
  OptInReverseGeocoder(this._inner);

  final ReverseGeocoder _inner;

  /// Off until the saved choice is loaded.
  bool enabled = false;

  @override
  Future<ReverseGeocodeResult> placeNameFor(
    double latitude,
    double longitude,
  ) => enabled
      ? _inner.placeNameFor(latitude, longitude)
      : Future.value(const PlaceNameNotFound());
}
