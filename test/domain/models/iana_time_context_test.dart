// TASK 7.1: the IANA-backed SiteTimeContext (timezone package) — offsets and
// DST, agreement with the TASK 2.2 DST fakes (whose transition instants were
// copied from the IANA database), and ADR-007 L1 fixed for a site with a zone.

import 'package:astroplan/domain/models/calendar_date.dart';
import 'package:astroplan/domain/models/iana_time_context.dart';
import 'package:astroplan/domain/services/session_night_resolver.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../support/dst_time_context.dart';

void main() {
  test('unknown or missing ids give null (caller falls back)', () {
    expect(IanaTimeContext.tryCreate(null), isNull);
    expect(IanaTimeContext.tryCreate(''), isNull);
    expect(IanaTimeContext.tryCreate('Mars/Olympus_Mons'), isNull);
    expect(IanaTimeContext.tryCreate('Europe/London')!.id, 'Europe/London');
  });

  test('Los Angeles: PDT before and PST after the 2026-11-01 transition', () {
    final la = IanaTimeContext.tryCreate('America/Los_Angeles')!;
    final before = DateTime.utc(2026, 11, 1, 8, 59);
    final after = DateTime.utc(2026, 11, 1, 9, 1);
    expect(la.offsetAt(before), const Duration(hours: -7));
    expect(la.abbreviationAt(before), 'PDT');
    expect(la.offsetAt(after), const Duration(hours: -8));
    expect(la.abbreviationAt(after), 'PST');
  });

  test('agrees with the IANA-derived test fakes, hourly over 2026–2027', () {
    for (final (fake, id) in [
      (DstTimeContext.berlin, 'Europe/Berlin'),
      (DstTimeContext.losAngeles, 'America/Los_Angeles'),
      (DstTimeContext.newYork, 'America/New_York'),
      (DstTimeContext.london, 'Europe/London'),
    ]) {
      final real = IanaTimeContext.tryCreate(id)!;
      for (
        var t = DateTime.utc(2026, 1, 1);
        t.isBefore(DateTime.utc(2028));
        t = t.add(const Duration(hours: 1))
      ) {
        expect(real.offsetAt(t), fake.offsetAt(t), reason: '$id $t');
      }
    }
  });

  test('ADR-007 L1 fixed: a Kiritimati site with its zone labels the civil '
      'evening date', () {
    final now = DateTime.utc(2026, 9, 22, 6); // 20:00 Sep 22 local (+14)
    final night = SessionNightResolver.resolveDefault(
      now,
      latitude: 1.8721,
      longitude: -157.4278,
      timeContext: IanaTimeContext.tryCreate('Pacific/Kiritimati')!,
    );
    expect(night.eveningDate, CalendarDate(2026, 9, 22));
    expect(night.timeContextId, 'Pacific/Kiritimati');
    expect(night.startUtc, DateTime.utc(2026, 9, 21, 22, 29, 42, 672));
  });
}
