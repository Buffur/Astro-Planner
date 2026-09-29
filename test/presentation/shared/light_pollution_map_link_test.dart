// The external light-pollution map opens at the given position (TASK 7.4,
// PD-05 option A) — no longer at hard-coded Slovenia coordinates (F-34).
// Since S7.5 (RG-09 = M2): lightpollutionmap.app, in its documented format.

import 'package:astroplan/presentation/shared/light_pollution_map_link.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('the documented format: lightpollutionmap.app/?lat=…&lng=…&zoom=…', () {
    expect(
      LightPollutionMapLink.at(37.7749, -122.4194).toString(),
      'https://lightpollutionmap.app/?lat=37.7749&lng=-122.4194&zoom=10',
    );
    expect(LightPollutionMapLink.at(46.05, 14.51, zoom: 30).queryParameters, {
      'lat': '46.0500',
      'lng': '14.5100',
      'zoom': '18',
    });
    expect(
      LightPollutionMapLink.at(0, 0, zoom: 0).queryParameters['zoom'],
      '2',
    );
  });

  test('the old hard-coded Slovenia position is gone', () {
    final uri = LightPollutionMapLink.at(-33.87, 151.21);
    expect(uri.query, isNot(contains('45.8720')));
    expect(uri.query, isNot(contains('14.5470')));
  });
}
