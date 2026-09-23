import 'package:astroplan/domain/services/reverse_geocoder.dart';

/// Test double for [ReverseGeocoder]: never touches the network. Answers
/// every lookup with [result] and records the coordinates asked for.
class FakeReverseGeocoder implements ReverseGeocoder {
  FakeReverseGeocoder({this.result = const PlaceNameNotFound()});

  ReverseGeocodeResult result;

  final List<(double, double)> lookups = [];

  @override
  Future<ReverseGeocodeResult> placeNameFor(
    double latitude,
    double longitude,
  ) async {
    lookups.add((latitude, longitude));
    return result;
  }
}
