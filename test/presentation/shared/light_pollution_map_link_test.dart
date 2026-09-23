// The external light-pollution map opens at the given position (TASK 7.4,
// PD-05 option A) — no longer at hard-coded Slovenia coordinates (F-34).

import 'package:astroplan/presentation/shared/light_pollution_map_link.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('the link is centred on the position', () {
    final uri = LightPollutionMapLink.at(37.7749, -122.4194);
    expect(uri.host, 'www.lightpollutionmap.info');
    expect(uri.fragment, contains('lat=37.7749'));
    expect(uri.fragment, contains('lon=-122.4194'));
    expect(uri.fragment, contains('zoom=10.00'));
    expect(uri.fragment, contains('state='));
  });

  test('the old hard-coded Slovenia position is gone', () {
    final uri = LightPollutionMapLink.at(-33.87, 151.21);
    expect(uri.fragment, isNot(contains('45.8720')));
    expect(uri.fragment, isNot(contains('14.5470')));
  });
}
