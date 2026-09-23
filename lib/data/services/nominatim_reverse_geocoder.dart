import 'dart:async';
import 'dart:collection';
import 'dart:convert';

import 'package:http/http.dart' as http;

import '../../core/config/app_identity.dart';
import '../../core/time/clock.dart';
import '../../domain/services/reverse_geocoder.dart';

/// [ReverseGeocoder] backed by OpenStreetMap's public Nominatim service
/// (TASK 7.2), following its usage policy
/// (https://operations.osmfoundation.org/policies/nominatim/):
///
/// - an identifying user agent ([AppIdentity.userAgent]);
/// - at most one request per [minInterval] (1 s by default): requests are
///   queued, never sent in parallel;
/// - results are cached in memory by coordinates rounded to
///   [cacheDecimals] decimal places (2 = 0.01°, about 1.1 km of latitude), and
///   the rounded coordinates are what is sent, so a cached name is exactly the
///   answer for its key; a place name at `zoom=10` (city/town level) does not
///   change within that distance often enough to matter for a planner;
/// - every name carries [attribution], which the UI must show with it.
///
/// "No name for this point" is cached; failures are not, so a later call can
/// retry.
class NominatimReverseGeocoder implements ReverseGeocoder {
  NominatimReverseGeocoder({
    http.Client? client,
    Clock? clock,
    Future<void> Function(Duration)? delay,
    this.minInterval = const Duration(seconds: 1),
    this.timeout = const Duration(seconds: 6),
    this.cacheDecimals = 2,
    this.maxCacheEntries = 256,
  }) : _client = client ?? http.Client(),
       _clock = clock ?? const SystemClock(),
       _delay = delay ?? Future<void>.delayed;

  static const String attribution = '© OpenStreetMap contributors';

  final http.Client _client;
  final Clock _clock;
  final Future<void> Function(Duration) _delay;
  final Duration minInterval;
  final Duration timeout;
  final int cacheDecimals;
  final int maxCacheEntries;

  /// Insertion-ordered, so the oldest entry is evicted first.
  final LinkedHashMap<String, ReverseGeocodeResult> _cache = LinkedHashMap();

  /// The tail of the request queue; requests run one at a time.
  Future<void> _queue = Future<void>.value();

  DateTime? _lastRequestUtc;

  /// Number of HTTP requests sent (for tests and diagnostics).
  int requestCount = 0;

  @override
  Future<ReverseGeocodeResult> placeNameFor(double latitude, double longitude) {
    final lat = _round(latitude);
    final lon = _round(longitude);
    final key = '$lat,$lon';
    final cached = _cache[key];
    if (cached != null) return Future.value(cached);

    final result = _queue.then((_) => _lookup(key, lat, lon));
    _queue = result.then((_) {}, onError: (_) {});
    return result;
  }

  double _round(double value) =>
      double.parse(value.toStringAsFixed(cacheDecimals));

  Future<ReverseGeocodeResult> _lookup(
    String key,
    double lat,
    double lon,
  ) async {
    // A queued duplicate may have been answered while it waited.
    final cached = _cache[key];
    if (cached != null) return cached;

    final last = _lastRequestUtc;
    if (last != null) {
      final wait = minInterval - _clock.nowUtc().difference(last);
      if (wait > Duration.zero) await _delay(wait);
    }
    _lastRequestUtc = _clock.nowUtc();
    requestCount++;

    final ReverseGeocodeResult result;
    try {
      result = await _request(lat, lon);
    } catch (e) {
      return ReverseGeocodeFailed(e.toString());
    }
    if (result is! ReverseGeocodeFailed) _remember(key, result);
    return result;
  }

  Future<ReverseGeocodeResult> _request(double lat, double lon) async {
    final uri = Uri.https('nominatim.openstreetmap.org', '/reverse', {
      'lat': '$lat',
      'lon': '$lon',
      'format': 'jsonv2',
      'zoom': '10',
      'accept-language': 'en',
    });
    final response = await _client
        .get(uri, headers: {'User-Agent': AppIdentity.userAgent})
        .timeout(timeout);
    if (response.statusCode != 200) {
      return ReverseGeocodeFailed('HTTP ${response.statusCode}');
    }

    final data = json.decode(response.body);
    if (data is! Map<String, dynamic>) {
      return const ReverseGeocodeFailed('unexpected response');
    }
    // Nominatim answers 200 with {"error": "Unable to geocode"} when no
    // object is found at the point.
    if (data.containsKey('error')) return const PlaceNameNotFound();

    final address = data['address'];
    if (address is! Map<String, dynamic>) return const PlaceNameNotFound();
    final name =
        address['city'] ??
        address['town'] ??
        address['village'] ??
        address['county'] ??
        address['state'];
    if (name is! String || name.trim().isEmpty) {
      return const PlaceNameNotFound();
    }
    return PlaceNameFound(name, attribution: attribution);
  }

  void _remember(String key, ReverseGeocodeResult result) {
    _cache[key] = result;
    while (_cache.length > maxCacheEntries) {
      _cache.remove(_cache.keys.first);
    }
  }
}
