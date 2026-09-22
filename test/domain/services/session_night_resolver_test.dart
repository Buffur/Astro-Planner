import 'package:astroplan/domain/models/calendar_date.dart';
import 'package:astroplan/domain/models/session_night.dart';
import 'package:astroplan/domain/models/site_time_context.dart';
import 'package:astroplan/domain/services/session_night_resolver.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../support/dst_time_context.dart';

/// The ADR-007 §12 test matrix and the §11 invariants.
///
/// Expected window instants are exact arithmetic
/// (`D 12:00Z − round(λ × 240 000) ms`), computed independently of this code
/// (ADR-007 §12). Every input and assertion is in UTC, so no result depends on
/// the host time zone (T17).

class _Site {
  const _Site(this.latitude, this.longitude);
  final double latitude;
  final double longitude;
}

const _sanFrancisco = _Site(37.7749, -122.4194);
const _tokyo = _Site(35.6762, 139.6503);
const _kiritimati = _Site(1.8721, -157.4278);
const _apia = _Site(-13.8333, -171.7667);
const _berlin = _Site(52.52, 13.405);
const _newYork = _Site(40.7128, -74.0060);
const _tromso = _Site(69.6492, 18.9553);
const _london = _Site(51.5074, -0.1278);

const _tokyoZone = FixedOffsetTimeContext(Duration(hours: 9));
const _kiritimatiZone = FixedOffsetTimeContext(Duration(hours: 14));
const _apiaZone = FixedOffsetTimeContext(Duration(hours: 13));

CalendarDate _d(int y, int m, int d) => CalendarDate(y, m, d);

SessionNight _default(DateTime nowUtc, _Site site, SiteTimeContext ctx) =>
    SessionNightResolver.resolveDefault(
      nowUtc,
      latitude: site.latitude,
      longitude: site.longitude,
      timeContext: ctx,
    );

SessionNight _forDate(CalendarDate date, _Site site, SiteTimeContext ctx) =>
    SessionNightResolver.forEveningDate(
      date,
      latitude: site.latitude,
      longitude: site.longitude,
      timeContext: ctx,
    );

/// The pre-ADR rule: the UTC calendar date of "now"
/// (`_sessionDate = DateTime.now().toUtc()`, read as the night's date).
CalendarDate _oldRule(DateTime nowUtc) =>
    CalendarDate.fromDateTimeFields(nowUtc);

/// Site-local wall-clock "HH:MM" of [utc] in [ctx].
String _local(DateTime utc, SiteTimeContext ctx) {
  final l = utc.add(ctx.offsetAt(utc));
  return '${l.hour.toString().padLeft(2, '0')}:'
      '${l.minute.toString().padLeft(2, '0')}';
}

void main() {
  group('ADR-007 matrix — default night from "now"', () {
    final cases =
        <
          ({
            String name,
            _Site site,
            SiteTimeContext ctx,
            DateTime now,
            CalendarDate expectedDate,
            DateTime expectedStart,
            bool oldRuleWrong,
          })
        >[
          (
            name: 'T1 San Francisco 18:30 PDT',
            site: _sanFrancisco,
            ctx: DstTimeContext.losAngeles,
            now: DateTime.utc(2026, 9, 22, 1, 30),
            expectedDate: _d(2026, 9, 21),
            expectedStart: DateTime.utc(2026, 9, 21, 20, 9, 40, 656),
            oldRuleWrong: true,
          ),
          (
            name: 'T2 San Francisco after midnight 02:00 PDT',
            site: _sanFrancisco,
            ctx: DstTimeContext.losAngeles,
            now: DateTime.utc(2026, 9, 22, 9),
            expectedDate: _d(2026, 9, 21),
            expectedStart: DateTime.utc(2026, 9, 21, 20, 9, 40, 656),
            oldRuleWrong: true,
          ),
          (
            name: 'T3 San Francisco morning 09:00 PDT (L4)',
            site: _sanFrancisco,
            ctx: DstTimeContext.losAngeles,
            now: DateTime.utc(2026, 9, 22, 16),
            expectedDate: _d(2026, 9, 21),
            expectedStart: DateTime.utc(2026, 9, 21, 20, 9, 40, 656),
            oldRuleWrong: true,
          ),
          (
            name: 'T4 San Francisco after solar noon 14:00 PDT',
            site: _sanFrancisco,
            ctx: DstTimeContext.losAngeles,
            now: DateTime.utc(2026, 9, 22, 21),
            expectedDate: _d(2026, 9, 22),
            expectedStart: DateTime.utc(2026, 9, 22, 20, 9, 40, 656),
            oldRuleWrong: false,
          ),
          (
            name: 'T5 Tokyo after midnight 02:00 JST',
            site: _tokyo,
            ctx: _tokyoZone,
            now: DateTime.utc(2026, 9, 21, 17),
            expectedDate: _d(2026, 9, 21),
            expectedStart: DateTime.utc(2026, 9, 21, 2, 41, 23, 928),
            oldRuleWrong: false,
          ),
          (
            name: 'T6 Tokyo morning 10:00 JST',
            site: _tokyo,
            ctx: _tokyoZone,
            now: DateTime.utc(2026, 9, 22, 1),
            expectedDate: _d(2026, 9, 21),
            expectedStart: DateTime.utc(2026, 9, 21, 2, 41, 23, 928),
            oldRuleWrong: true,
          ),
          (
            name: 'T7 Kiritimati (UTC+14) 20:00',
            site: _kiritimati,
            ctx: _kiritimatiZone,
            now: DateTime.utc(2026, 9, 22, 6),
            expectedDate: _d(2026, 9, 22),
            expectedStart: DateTime.utc(2026, 9, 21, 22, 29, 42, 672),
            oldRuleWrong: false,
          ),
          (
            name: 'T8 Apia (UTC+13) 21:00',
            site: _apia,
            ctx: _apiaZone,
            now: DateTime.utc(2026, 9, 22, 8),
            expectedDate: _d(2026, 9, 22),
            expectedStart: DateTime.utc(2026, 9, 21, 23, 27, 4, 8),
            oldRuleWrong: false,
          ),
          (
            name: 'T9 Berlin, EU DST fall-back night, 21:00 CEST',
            site: _berlin,
            ctx: DstTimeContext.berlin,
            now: DateTime.utc(2026, 10, 24, 19),
            expectedDate: _d(2026, 10, 24),
            expectedStart: DateTime.utc(2026, 10, 24, 11, 6, 22, 800),
            oldRuleWrong: false,
          ),
          (
            name: 'T11 New York, US DST fall-back night, 21:00 EDT',
            site: _newYork,
            ctx: DstTimeContext.newYork,
            now: DateTime.utc(2026, 11, 1, 1),
            expectedDate: _d(2026, 10, 31),
            expectedStart: DateTime.utc(2026, 10, 31, 16, 56, 1, 440),
            oldRuleWrong: true,
          ),
          (
            name: 'T12 New York, US DST spring-forward night, 21:00 EST',
            site: _newYork,
            ctx: DstTimeContext.newYork,
            now: DateTime.utc(2026, 3, 8, 2),
            expectedDate: _d(2026, 3, 7),
            expectedStart: DateTime.utc(2026, 3, 7, 16, 56, 1, 440),
            oldRuleWrong: true,
          ),
        ];

    for (final c in cases) {
      test(c.name, () {
        final night = _default(c.now, c.site, c.ctx);

        expect(night.eveningDate, c.expectedDate);
        expect(night.startUtc, c.expectedStart);
        expect(night.endUtc, c.expectedStart.add(const Duration(hours: 24)));
        expect(night.startUtc.isUtc && night.endUtc.isUtc, isTrue);
        expect(night.contains(c.now), isTrue);
        expect(night.timeContextId, c.ctx.id);
        // Resolving the same date again gives the same night (I4).
        expect(_forDate(night.eveningDate, c.site, c.ctx), night);
        // Records whether this case discriminates against the pre-ADR rule
        // (TASK 2.2 acceptance: T1, T2, T11 and T12 fail on the old code).
        if (c.oldRuleWrong) {
          expect(_oldRule(c.now), isNot(c.expectedDate));
        } else {
          expect(_oldRule(c.now), c.expectedDate);
        }
      });
    }
  });

  group('ADR-007 matrix — night for a chosen evening date', () {
    test('T9 EU fall-back: 13:06 CEST → 12:06 CET, still exactly 24 h', () {
      final night = _forDate(_d(2026, 10, 24), _berlin, DstTimeContext.berlin);
      expect(night.startUtc, DateTime.utc(2026, 10, 24, 11, 6, 22, 800));
      expect(night.endUtc, DateTime.utc(2026, 10, 25, 11, 6, 22, 800));
      expect(_local(night.startUtc, DstTimeContext.berlin), '13:06');
      expect(_local(night.endUtc, DstTimeContext.berlin), '12:06');
    });

    test('T10 EU spring-forward: 12:06 CET → 13:06 CEST', () {
      final night = _forDate(_d(2026, 3, 28), _berlin, DstTimeContext.berlin);
      expect(night.startUtc, DateTime.utc(2026, 3, 28, 11, 6, 22, 800));
      expect(night.endUtc, DateTime.utc(2026, 3, 29, 11, 6, 22, 800));
      expect(_local(night.startUtc, DstTimeContext.berlin), '12:06');
      expect(_local(night.endUtc, DstTimeContext.berlin), '13:06');
    });

    test('T11 US fall-back: 12:56 EDT → 11:56 EST', () {
      final night = _forDate(
        _d(2026, 10, 31),
        _newYork,
        DstTimeContext.newYork,
      );
      expect(_local(night.startUtc, DstTimeContext.newYork), '12:56');
      expect(_local(night.endUtc, DstTimeContext.newYork), '11:56');
    });

    test('T12 US spring-forward: 11:56 EST → 12:56 EDT', () {
      final night = _forDate(_d(2026, 3, 7), _newYork, DstTimeContext.newYork);
      expect(_local(night.startUtc, DstTimeContext.newYork), '11:56');
      expect(_local(night.endUtc, DstTimeContext.newYork), '12:56');
    });

    test('T13 Tromsø midnight sun: the window still exists', () {
      final night = _forDate(_d(2026, 6, 20), _tromso, DstTimeContext.oslo);
      expect(night.startUtc, DateTime.utc(2026, 6, 20, 10, 44, 10, 728));
      expect(night.endUtc, DateTime.utc(2026, 6, 21, 10, 44, 10, 728));
      expect(_local(night.startUtc, DstTimeContext.oslo), '12:44');
    });

    test('T14 Tromsø polar night: the window still exists', () {
      final night = _forDate(_d(2026, 12, 20), _tromso, DstTimeContext.oslo);
      expect(night.startUtc, DateTime.utc(2026, 12, 20, 10, 44, 10, 728));
      expect(_local(night.startUtc, DstTimeContext.oslo), '11:44');
    });

    test('T15 London, June (no astronomical darkness)', () {
      final night = _forDate(_d(2026, 6, 20), _london, DstTimeContext.london);
      expect(night.startUtc, DateTime.utc(2026, 6, 20, 12, 0, 30, 672));
      expect(_local(night.startUtc, DstTimeContext.london), '13:00');
    });

    test('T16 antimeridian: λ = 180 and λ = −180 give the same night', () {
      final east = SessionNightResolver.forEveningDate(
        _d(2026, 9, 22),
        latitude: 0,
        longitude: 180,
        timeContext: MeanSolarTimeContext(180),
      );
      final west = SessionNightResolver.forEveningDate(
        _d(2026, 9, 22),
        latitude: 0,
        longitude: -180,
        timeContext: MeanSolarTimeContext(-180),
      );
      expect(east, west);
      expect(east.startUtc, DateTime.utc(2026, 9, 22));
      expect(east.longitude, 180.0);
    });

    test('L1: before TASK 7.1, mean-solar labels Kiritimati one day early', () {
      final now = DateTime.utc(2026, 9, 22, 6); // 20:00 Sep 22 local (+14)
      final civil = _default(now, _kiritimati, _kiritimatiZone);
      final solar = _default(
        now,
        _kiritimati,
        MeanSolarTimeContext(_kiritimati.longitude),
      );
      expect(civil.eveningDate, _d(2026, 9, 22));
      expect(solar.eveningDate, _d(2026, 9, 21));
      // The instants are identical; only the label differs.
      expect(solar.startUtc, civil.startUtc);
      expect(solar.timeContextId, 'solar');
    });
  });

  group('ADR-007 invariants', () {
    final contexts =
        <({String name, _Site site, SiteTimeContext ctx, bool civil})>[
          (
            name: 'LA (DST)',
            site: _sanFrancisco,
            ctx: DstTimeContext.losAngeles,
            civil: true,
          ),
          (
            name: 'Berlin (DST)',
            site: _berlin,
            ctx: DstTimeContext.berlin,
            civil: true,
          ),
          (
            name: 'New York (DST)',
            site: _newYork,
            ctx: DstTimeContext.newYork,
            civil: true,
          ),
          (name: 'Tokyo +9', site: _tokyo, ctx: _tokyoZone, civil: true),
          (
            name: 'Kiritimati +14',
            site: _kiritimati,
            ctx: _kiritimatiZone,
            civil: true,
          ),
          (name: 'Apia +13', site: _apia, ctx: _apiaZone, civil: true),
          for (final lon in [
            -180.0,
            -179.99,
            -122.42,
            0.0,
            13.4,
            179.99,
            180.0,
          ])
            (
              name: 'mean solar λ=$lon',
              site: _Site(45, lon),
              ctx: MeanSolarTimeContext(lon),
              civil: false,
            ),
        ];

    for (final c in contexts) {
      test('P1 ${c.name}: I1–I4 and I7 for 730 consecutive dates', () {
        final offsetMs = MeanSolarTimeContext.meanSolarOffsetMs(
          c.site.longitude,
        );
        var date = _d(2026, 1, 1);
        var night = _forDate(date, c.site, c.ctx);
        for (var i = 0; i < 730; i++) {
          // I1: exactly 24 h.
          expect(
            night.endUtc.difference(night.startUtc).inMilliseconds,
            86400000,
          );
          // I2: the start is a mean solar noon of the site.
          final solar = night.startUtc.add(Duration(milliseconds: offsetMs));
          expect(
            [solar.hour, solar.minute, solar.second, solar.millisecond],
            [12, 0, 0, 0],
            reason: '$date',
          );
          // I4: the label is the requested date.
          expect(night.eveningDate, date);
          // I7: 18:00 civil on the date lies in the window.
          if (c.civil) {
            final evening = date.atUtcHour(18);
            final eveningUtc = evening.subtract(c.ctx.offsetAt(evening));
            expect(night.contains(eveningUtc), isTrue, reason: '$date');
          }
          // I3: the next night starts where this one ends.
          final next = _forDate(date.addDays(1), c.site, c.ctx);
          expect(next.startUtc, night.endUtc, reason: '$date');
          date = date.addDays(1);
          night = next;
        }
      });
    }

    test(
      'P2 simulated 48 h: default is monotonic and switches at solar noon',
      () {
        final ctx = DstTimeContext.losAngeles;
        var now = DateTime.utc(2026, 9, 21, 12);
        final end = now.add(const Duration(hours: 48));
        SessionNight? previous;
        final switchInstants = <DateTime>[];
        while (now.isBefore(end)) {
          final night = _default(now, _sanFrancisco, ctx);
          expect(night.contains(now), isTrue); // I5
          if (previous != null) {
            expect(night.startUtc.isBefore(previous.startUtc), isFalse); // I6
            if (night != previous) switchInstants.add(now);
          }
          previous = night;
          now = now.add(const Duration(minutes: 5));
        }
        // Two switches, each at the first 5-minute step at or after the site's
        // mean solar noon (20:09:40.656Z).
        expect(switchInstants, [
          DateTime.utc(2026, 9, 21, 20, 10),
          DateTime.utc(2026, 9, 22, 20, 10),
        ]);
      },
    );

    test('I5 half-open: the end instant belongs to the next night', () {
      final night = _forDate(
        _d(2026, 9, 21),
        _sanFrancisco,
        DstTimeContext.losAngeles,
      );
      final atEnd = _default(
        night.endUtc,
        _sanFrancisco,
        DstTimeContext.losAngeles,
      );
      expect(atEnd.eveningDate, _d(2026, 9, 22));
      final atStart = _default(
        night.startUtc,
        _sanFrancisco,
        DstTimeContext.losAngeles,
      );
      expect(atStart, night);
    });

    test('P3 antimeridian continuity in a civil context', () {
      const ctx = FixedOffsetTimeContext(Duration(hours: 12));
      final east = _forDate(_d(2026, 9, 22), const _Site(-17, 179.99), ctx);
      final west = _forDate(_d(2026, 9, 22), const _Site(-17, -179.99), ctx);
      expect(east.eveningDate, west.eveningDate);
      expect(
        east.startUtc.difference(west.startUtc).abs(),
        lessThan(const Duration(minutes: 1)),
      );
    });

    test('I9 a window exists at the poles', () {
      for (final lat in [-90.0, 90.0]) {
        final night = SessionNightResolver.forEveningDate(
          _d(2026, 6, 21),
          latitude: lat,
          longitude: 0,
          timeContext: MeanSolarTimeContext(0),
        );
        expect(night.endUtc.difference(night.startUtc), SessionNight.length);
      }
    });

    test('I10 longitude normalization', () {
      expect(MeanSolarTimeContext.normalizeLongitude(-180), 180.0);
      expect(MeanSolarTimeContext.normalizeLongitude(180), 180.0);
      expect(MeanSolarTimeContext.normalizeLongitude(190), -170.0);
      expect(MeanSolarTimeContext.normalizeLongitude(-190), 170.0);
      expect(MeanSolarTimeContext.normalizeLongitude(360), 0.0);
      expect(MeanSolarTimeContext.meanSolarOffsetMs(-122.4194), -29380656);
    });
  });

  group('input validation', () {
    test('a non-UTC "now" is rejected (no host time zone, I8)', () {
      expect(
        () => SessionNightResolver.resolveDefault(
          DateTime(2026, 9, 21, 18, 30),
          latitude: 0,
          longitude: 0,
          timeContext: MeanSolarTimeContext(0),
        ),
        throwsArgumentError,
      );
    });

    test('latitude outside [−90, 90] is rejected', () {
      expect(
        () => _forDate(_d(2026, 1, 1), const _Site(91, 0), _tokyoZone),
        throwsArgumentError,
      );
    });

    test('non-finite longitude is rejected', () {
      expect(
        () => SessionNightResolver.forEveningDate(
          _d(2026, 1, 1),
          latitude: 0,
          longitude: double.nan,
          timeContext: _tokyoZone,
        ),
        throwsArgumentError,
      );
    });

    test('SessionNight rejects a window that is not 24 h', () {
      expect(
        () => SessionNight(
          eveningDate: _d(2026, 1, 1),
          startUtc: DateTime.utc(2026, 1, 1, 12),
          endUtc: DateTime.utc(2026, 1, 2, 11),
          latitude: 0,
          longitude: 0,
          timeContextId: 'solar',
        ),
        throwsArgumentError,
      );
    });
  });
}
