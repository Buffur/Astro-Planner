// TASK 9.2 (ADR-012): the UTC-aligned WeatherSnapshot — parsing recorded
// Open-Meteo responses (fixtures recorded 2026-09-23 from
// api.open-meteo.com with the ADR-012 parameters) and the night-covering
// request.

import 'dart:convert';
import 'dart:io';

import 'package:astroplan/core/time/clock.dart';
import 'package:astroplan/data/repositories/open_meteo_weather_repository.dart';
import 'package:astroplan/data/services/open_meteo_forecast_parser.dart';
import 'package:astroplan/domain/models/weather_snapshot.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';

Object? _fixture(String name) =>
    jsonDecode(File('test/fixtures/weather/$name').readAsStringSync());

WeatherFetch _parse(Object? json) => OpenMeteoForecastParser.parse(
  json,
  model: 'best_match',
  fetchedAtUtc: DateTime.utc(2026, 9, 23, 12),
  latitude: 46.05,
  longitude: 14.51,
);

WeatherSnapshot _snapshot(WeatherFetch f) => (f as WeatherFetched).snapshot;

void main() {
  group('parser', () {
    test('a recorded response: UTC hours with every variable', () {
      final raw = _fixture('open_meteo_ljubljana_best_match.json')! as Map;
      final s = _snapshot(_parse(raw));
      final hourly = raw['hourly'] as Map;

      expect(s.provider, 'open-meteo');
      expect(s.model, 'best_match');
      expect(s.source, 'provider:open-meteo/best_match');
      expect(s.fetchedAtUtc, DateTime.utc(2026, 9, 23, 12));
      expect(s.hours, hasLength(15));
      // 1790265600 s = 2026-09-24 16:00 UTC (the requested start_hour).
      expect(s.hours.first.timeUtc, DateTime.utc(2026, 9, 24, 16));
      expect(s.hours.last.timeUtc, DateTime.utc(2026, 9, 25, 6));
      final h = s.hours.first;
      expect(h.cloudCoverPct, (hourly['cloud_cover'] as List).first);
      expect(h.cloudCoverHighPct, (hourly['cloud_cover_high'] as List).first);
      expect(h.visibilityM, (hourly['visibility'] as List).first);
      expect(h.windGustsKmh, (hourly['wind_gusts_10m'] as List).first);
      expect(h.dewPointC, (hourly['dew_point_2m'] as List).first);
    });

    // Acceptance: parsed instants do not depend on the device's zone. They
    // are built from UTC epoch seconds as UTC DateTimes, so the zone of the
    // machine running the test (or the site's zone) cannot shift them.
    test('instants are UTC and independent of the device zone', () {
      final s = _snapshot(
        _parse({
          'hourly': {
            'time': [1790265600, 1790269200],
            'temperature_2m': [10.0, 9.5],
          },
        }),
      );
      for (final h in s.hours) {
        expect(h.timeUtc.isUtc, isTrue);
      }
      expect(s.hours.first.timeUtc.millisecondsSinceEpoch, 1790265600 * 1000);
      expect(s.hours.first.timeUtc, DateTime.parse('2026-09-24T16:00:00Z'));
    });

    // A site far from the test machine's zone (Los Angeles, UTC-7 in
    // September): the provider still returns GMT+0 epochs with
    // timeformat=unixtime, and the snapshot keeps them as such.
    test('a site in another zone keeps the same UTC instants', () {
      final s = _snapshot(
        _parse({
          'utc_offset_seconds': 0,
          'timezone': 'GMT',
          'hourly': {
            'time': [1790298000], // 2026-09-25 01:00 UTC = 18:00 PDT
            'cloud_cover': [5],
          },
        }),
      );
      expect(s.hours.single.timeUtc, DateTime.utc(2026, 9, 25, 1));
      expect(s.hours.single.cloudCoverPct, 5);
    });

    test('nulls, short arrays and missing variables are unknown, not 0', () {
      final s = _snapshot(
        _parse({
          'hourly': {
            'time': [1790265600, 1790269200, 1790272800],
            'cloud_cover': [10, null, 30],
            'precipitation_probability': [5], // shorter than time
            // wind_speed_10m missing entirely
          },
        }),
      );
      expect(s.hours[1].cloudCoverPct, isNull);
      expect(s.hours[2].cloudCoverPct, 30);
      expect(s.hours[0].precipitationProbabilityPct, 5);
      expect(s.hours[1].precipitationProbabilityPct, isNull);
      expect(s.hours[2].precipitationProbabilityPct, isNull);
      for (final h in s.hours) {
        expect(h.windSpeedKmh, isNull);
      }
    });

    test('a recorded out-of-range error is a typed failure', () {
      final f = _parse(_fixture('open_meteo_out_of_range.json'));
      expect(f, isA<WeatherFetchFailed>());
      expect((f as WeatherFetchFailed).failure, WeatherFailure.outOfRange);
      expect(f.detail, contains('out of allowed range'));
    });

    test('other errors and malformed bodies', () {
      final other = _parse({'error': true, 'reason': 'Cannot initialize'});
      expect((other as WeatherFetchFailed).failure, WeatherFailure.unavailable);
      expect(
        (_parse([1, 2]) as WeatherFetchFailed).failure,
        WeatherFailure.malformed,
      );
      expect(
        (_parse({'latitude': 1}) as WeatherFetchFailed).failure,
        WeatherFailure.malformed,
      );
      expect(
        (_parse({
          'hourly': {
            'time': ['2026-09-24T16:00'],
          },
        }) as WeatherFetchFailed).failure,
        WeatherFailure.malformed,
        reason: 'ISO strings would be naive local times: rejected',
      );
    });
  });

  group('request', () {
    final clock = FixedClock(DateTime.utc(2026, 9, 23, 12));
    final fixture = File(
      'test/fixtures/weather/open_meteo_ljubljana_best_match.json',
    ).readAsStringSync();

    test('covers the night in UTC with the ADR-012 parameters', () async {
      late Uri requested;
      final repo = OpenMeteoWeatherRepository(
        clock: clock,
        client: MockClient((r) async {
          requested = r.url;
          return http.Response(fixture, 200);
        }),
      );
      final f = await repo.fetchSnapshot(
        latitude: 46.05,
        longitude: 14.51,
        startUtc: DateTime.utc(2026, 9, 24, 16, 20),
        endUtc: DateTime.utc(2026, 9, 25, 7),
      );
      final q = requested.queryParameters;
      expect(q['timeformat'], 'unixtime');
      expect(q['models'], 'best_match');
      expect(q.containsKey('timezone'), isFalse, reason: 'GMT by default');
      expect(q['start_hour'], '2026-09-24T16:00');
      expect(q['end_hour'], '2026-09-25T06:00', reason: 'end is exclusive');
      expect(
        q['hourly']!.split(','),
        containsAll(['cloud_cover_high', 'visibility', 'wind_gusts_10m']),
      );
      expect(_snapshot(f).fetchedAtUtc, clock.nowUtc());
    });

    test('the end is capped at the 16-day horizon', () async {
      late Uri requested;
      final repo = OpenMeteoWeatherRepository(
        clock: clock,
        client: MockClient((r) async {
          requested = r.url;
          return http.Response(fixture, 200);
        }),
      );
      await repo.fetchSnapshot(
        latitude: 46.05,
        longitude: 14.51,
        startUtc: DateTime.utc(2026, 10, 8, 16),
        endUtc: DateTime.utc(2026, 10, 9, 16),
      );
      // Today 2026-09-23 + 16 days − 1 h = 2026-10-08 23:00 UTC.
      expect(requested.queryParameters['end_hour'], '2026-10-08T23:00');
    });

    test(
      'a night beyond the horizon is out of range, without a request',
      () async {
        var calls = 0;
        final repo = OpenMeteoWeatherRepository(
          clock: clock,
          client: MockClient((r) async {
            calls++;
            return http.Response(fixture, 200);
          }),
        );
        final f = await repo.fetchSnapshot(
          latitude: 46.05,
          longitude: 14.51,
          startUtc: DateTime.utc(2026, 11, 24, 16),
          endUtc: DateTime.utc(2026, 11, 25, 16),
        );
        expect((f as WeatherFetchFailed).failure, WeatherFailure.outOfRange);
        expect(calls, 0);
      },
    );

    test('non-200, offline and garbage are unavailable/malformed', () async {
      Future<WeatherFetch> run(MockClientHandler handler) =>
          OpenMeteoWeatherRepository(
            clock: clock,
            client: MockClient(handler),
          ).fetchSnapshot(
            latitude: 46.05,
            longitude: 14.51,
            startUtc: DateTime.utc(2026, 9, 24, 16),
            endUtc: DateTime.utc(2026, 9, 25, 16),
          );
      expect(
        ((await run(
          (_) async => http.Response('busy', 503),
        )) as WeatherFetchFailed).failure,
        WeatherFailure.unavailable,
      );
      expect(
        ((await run(
          (_) async => throw http.ClientException('offline'),
        )) as WeatherFetchFailed).failure,
        WeatherFailure.unavailable,
      );
      expect(
        ((await run(
          (_) async => http.Response('<html>', 200),
        )) as WeatherFetchFailed).failure,
        WeatherFailure.malformed,
      );
      expect(
        ((await run(
          (_) async => http.Response(
            File('test/fixtures/weather/open_meteo_out_of_range.json')
                .readAsStringSync(),
            400,
          ),
        )) as WeatherFetchFailed).failure,
        WeatherFailure.outOfRange,
      );
    });
  });
}
