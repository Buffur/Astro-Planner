// SkyDarkness (TASK 7.4): known vs unknown sky darkness, with provenance,
// and no conversion between Bortle and SQM.

import 'package:astroplan/domain/models/calendar_date.dart';
import 'package:astroplan/domain/models/location_profile.dart';
import 'package:astroplan/domain/models/sky_darkness.dart';
import 'package:flutter_test/flutter_test.dart';

LocationProfile _site({int? bortle, double? sqm}) => LocationProfile(
  id: 1,
  name: 'Site',
  latitude: 46.05,
  longitude: 14.51,
  elevation: 300,
  bortleClass: bortle,
  bortleSource: bortle == null ? null : 'user',
  bortleDate: bortle == null ? null : CalendarDate(2026, 9, 23),
  sqm: sqm,
  sqmSource: sqm == null ? null : 'meter',
  sqmDate: sqm == null ? null : CalendarDate(2026, 8, 1),
);

void main() {
  test('nothing entered is unknown, not a default', () {
    expect(SkyDarkness.unknown.isUnknown, isTrue);
    final fromSite = SkyDarkness.fromSite(_site());
    expect(fromSite.isUnknown, isTrue);
    expect(fromSite.bortleClass, isNull);
    expect(fromSite.sqm, isNull);
  });

  test('a site\'s values carry their source and date', () {
    final d = SkyDarkness.fromSite(_site(bortle: 4, sqm: 21.3));
    expect(d.isUnknown, isFalse);
    expect(d.bortleClass, 4);
    expect(d.bortleSource, 'user');
    expect(d.bortleDate, CalendarDate(2026, 9, 23));
    expect(d.sqm, 21.3);
    expect(d.sqmSource, 'meter');
    expect(d.sqmDate, CalendarDate(2026, 8, 1));
    expect(d.isSaved, isTrue);
  });

  test('Bortle and SQM are never derived from each other', () {
    final bortleOnly = SkyDarkness.fromSite(_site(bortle: 6));
    expect(bortleOnly.hasBortle, isTrue);
    expect(bortleOnly.hasSqm, isFalse);
    expect(bortleOnly.sqm, isNull);

    final sqmOnly = SkyDarkness.fromSite(_site(sqm: 18.5));
    expect(sqmOnly.hasSqm, isTrue);
    expect(sqmOnly.hasBortle, isFalse);
    expect(sqmOnly.bortleClass, isNull);
  });
}
