// LocationProfile.userEdit (TASK 7.3): what an explicit user edit writes,
// including sky-darkness provenance (ADR-008 §6).

import 'package:astroplan/domain/models/calendar_date.dart';
import 'package:astroplan/domain/models/location_profile.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  final today = CalendarDate(2026, 9, 23);
  final legacy = LocationProfile(
    id: 7,
    name: 'Dark site',
    latitude: 46.2,
    longitude: 14.1,
    elevation: 1200,
    bortleClass: 3,
    bortleSource: 'legacy',
    bortleDate: CalendarDate(2025, 1, 1),
    sqm: 21.3,
    sqmSource: 'meter',
    sqmDate: CalendarDate(2025, 6, 1),
    timeZoneId: 'Europe/Ljubljana',
  );

  LocationProfile edit({int? bortle, double? sqm, LocationProfile? original}) =>
      LocationProfile.userEdit(
        original: original,
        name: 'Dark site',
        latitude: 46.2,
        longitude: 14.1,
        elevation: 1200,
        timeZoneId: 'Europe/Ljubljana',
        bortleClass: bortle,
        sqm: sqm,
        today: today,
      );

  test('elevation unknown is null, never 0 (S7.5, RG-08 = E2); a known one is '
      'still range-checked', () {
    final site = LocationProfile.userEdit(
      name: 'Field',
      latitude: 46.2,
      longitude: 14.1,
      today: today,
    );
    expect(site.elevation, isNull);
    expect(
      () => LocationProfile(
        id: 0,
        name: 'x',
        latitude: 0,
        longitude: 0,
        elevation: 9500,
      ),
      throwsArgumentError,
    );
    expect(legacy.withUserBortle(5, today).elevation, 1200);
  });

  test('a new site gets id 0 and user-sourced sky values dated today', () {
    final site = edit(bortle: 4, sqm: 20.5);
    expect(site.id, 0);
    expect(site.bortleSource, 'user');
    expect(site.bortleDate, today);
    expect(site.sqmSource, 'user');
    expect(site.sqmDate, today);
  });

  test('unchanged sky values keep their source and date', () {
    final site = edit(original: legacy, bortle: 3, sqm: 21.3);
    expect(site.id, 7);
    expect(site.bortleSource, 'legacy');
    expect(site.bortleDate, CalendarDate(2025, 1, 1));
    expect(site.sqmSource, 'meter');
    expect(site.sqmDate, CalendarDate(2025, 6, 1));
  });

  test('a changed value becomes user-sourced, dated today', () {
    final site = edit(original: legacy, bortle: 4, sqm: 21.3);
    expect(site.bortleSource, 'user');
    expect(site.bortleDate, today);
    expect(site.sqmSource, 'meter', reason: 'SQM was not changed');
  });

  test('a cleared value is unknown, with no source or date', () {
    final site = edit(original: legacy);
    expect(site.bortleClass, isNull);
    expect(site.bortleSource, isNull);
    expect(site.bortleDate, isNull);
    expect(site.sqm, isNull);
    expect(site.sqmSource, isNull);
    expect(site.sqmDate, isNull);
  });

  test('out-of-range values are rejected', () {
    expect(() => edit(bortle: 10), throwsArgumentError);
    expect(() => edit(sqm: 24), throwsArgumentError);
  });
}
