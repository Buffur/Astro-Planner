// TASK 6.3: the Moon (Meeus ch. 47 full tables, ADR-010) against JPL Horizons
// and USNO — independent references, never the code itself. Tolerances are
// ADR-010 §4. Fixtures: test/fixtures/astronomy/horizons_moon.json and
// usno_sun_moon_events.json (sources, queries and retrieval dates inside).

import 'dart:convert';
import 'dart:io';
import 'dart:math' as math;

import 'package:astroplan/domain/models/calendar_date.dart';
import 'package:astroplan/domain/models/site_time_context.dart';
import 'package:astroplan/domain/services/moon_calculator.dart';
import 'package:astroplan/domain/services/session_night_resolver.dart';
import 'package:flutter_test/flutter_test.dart';

Map<String, dynamic> _fixture(String name) =>
    jsonDecode(File('test/fixtures/astronomy/$name').readAsStringSync())
        as Map<String, dynamic>;

const _months = {
  'Jan': 1, 'Feb': 2, 'Mar': 3, 'Apr': 4, 'May': 5, 'Jun': 6, //
  'Jul': 7, 'Aug': 8, 'Sep': 9, 'Oct': 10, 'Nov': 11, 'Dec': 12,
};

/// Horizons "2026-Jan-03 03:17" (UT).
DateTime _hz(String s) {
  final p = s.split(RegExp(r'[- :]'));
  return DateTime.utc(
    int.parse(p[0]),
    _months[p[1]]!,
    int.parse(p[2]),
    int.parse(p[3]),
    int.parse(p[4]),
  );
}

double _angDiff(double a, double b) => ((a - b + 540) % 360) - 180;
double _n(Object? v) => v is num ? v.toDouble() : double.parse(v as String);

void main() {
  final moon = _fixture('horizons_moon.json');
  final geo = (moon['geocentric'] as List).cast<Map<String, dynamic>>();

  group('geocentric vs JPL Horizons (ADR-010 §4)', () {
    test('at least 20 instants spanning two years', () {
      final first = _hz(geo.first['Date__(UT)__HR:MN'] as String);
      final last = _hz(geo.last['Date__(UT)__HR:MN'] as String);
      expect(geo.length, greaterThanOrEqualTo(20));
      expect(last.difference(first).inDays, greaterThan(700));
    });

    test('apparent RA and Dec of date within 0.02°', () {
      for (final r in geo) {
        final p = MoonCalculator.position(
          _hz(r['Date__(UT)__HR:MN'] as String),
        );
        final dRa =
            _angDiff(p.rightAscensionDeg, _n(r['R.A.__(a-app)'])) *
            math.cos(p.declinationDeg * math.pi / 180);
        expect(dRa.abs(), lessThan(0.02), reason: '${r['Date__(UT)__HR:MN']}');
        expect(
          (p.declinationDeg - _n(r['DEC___(a-app)'])).abs(),
          lessThan(0.02),
        );
      }
    });

    test('ecliptic longitude/latitude of date within 0.02°', () {
      for (final r in geo) {
        final p = MoonCalculator.position(
          _hz(r['Date__(UT)__HR:MN'] as String),
        );
        expect(
          _angDiff(p.eclipticLongitudeDeg, _n(r['ObsEcLon'])).abs(),
          lessThan(0.02),
        );
        expect(
          (p.eclipticLatitudeDeg - _n(r['ObsEcLat'])).abs(),
          lessThan(0.02),
        );
      }
    });

    test('distance within 100 km (sets the parallax: 100 km ≈ 0.25″ of π)', () {
      for (final r in geo) {
        final p = MoonCalculator.position(
          _hz(r['Date__(UT)__HR:MN'] as String),
        );
        expect((p.distanceKm - _n(r['delta'])).abs(), lessThan(100));
      }
    });

    test('illuminated fraction within 1 percentage point', () {
      for (final r in geo) {
        final k = MoonCalculator.illuminatedFraction(
          _hz(r['Date__(UT)__HR:MN'] as String),
        );
        expect((k * 100 - _n(r['Illu%'])).abs(), lessThan(1.0));
      }
    });
  });

  test(
    'topocentric airless altitude within 0.05° at 3 sites (incl. 69.65°N)',
    () {
      final sites = (moon['topocentric'] as List).cast<Map<String, dynamic>>();
      expect(sites.map((s) => s['lat']), contains(69.65));
      for (final s in sites) {
        for (final r in (s['rows'] as List).cast<Map<String, dynamic>>()) {
          final alt = MoonCalculator.topocentricAltitude(
            _hz(r['Date__(UT)__HR:MN'] as String),
            _n(s['lat']),
            _n(s['lon']),
          );
          expect(
            (alt - _n(r['Elevation_(a-app)'])).abs(),
            lessThan(0.05),
            reason: '${s['site']} ${r['Date__(UT)__HR:MN']}',
          );
        }
      }
    },
  );

  test('USNO phase instants (2026–2027) within 10 minutes', () {
    const target = {
      'New Moon': 0.0,
      'First Quarter': 90.0,
      'Full Moon': 180.0,
      'Last Quarter': 270.0,
    };
    final phases = (moon['usnoPhases'] as List).cast<Map<String, dynamic>>();
    expect(phases.length, greaterThanOrEqualTo(90));
    for (final ph in phases) {
      final usno = DateTime.parse(ph['utc'] as String);
      final goal = target[ph['phase']]!;
      double f(DateTime t) =>
          _angDiff(MoonCalculator.phaseLongitudeDeg(t), goal);
      // The Moon gains about 12° a day on the Sun, so f rises monotonically
      // through zero within ±1 day of the USNO instant: bisect it.
      var lo = usno.subtract(const Duration(days: 1));
      var hi = usno.add(const Duration(days: 1));
      for (var i = 0; i < 40; i++) {
        final mid = lo.add(hi.difference(lo) ~/ 2);
        if (f(mid) < 0) {
          lo = mid;
        } else {
          hi = mid;
        }
      }
      expect(
        lo.difference(usno).inSeconds.abs() / 60,
        lessThan(10),
        reason: '${ph['phase']} ${ph['utc']}',
      );
    }
  });

  group('moonrise/moonset vs USNO on the night grid ([−2, +7] min)', () {
    final usno = _fixture('usno_sun_moon_events.json');
    final entries = (usno['entries'] as List).cast<Map<String, dynamic>>();
    const nights = [
      '2026-03-01',
      '2026-06-21',
      '2026-09-22',
      '2026-12-21',
      '2027-01-15',
    ];
    final sites = {for (final e in entries) e['site']: (e['lat'], e['lon'])};

    test(
      'every USNO event is reported, and every reported event is USNO\'s',
      () {
        var matched = 0;
        for (final MapEntry(key: site, value: (lat, lon)) in sites.entries) {
          for (final d in nights) {
            final night = SessionNightResolver.forEveningDate(
              CalendarDate.parse(d),
              latitude: _n(lat),
              longitude: _n(lon),
              timeContext: MeanSolarTimeContext(_n(lon)),
            );
            final ours = MoonCalculator.riseSetForNight(night).events;
            final refs = <(MoonEventKind, DateTime)>[];
            for (final e in entries.where((e) => e['site'] == site)) {
              (e['moon'] as Map).forEach((phen, hhmm) {
                final kind = switch (phen) {
                  'Rise' => MoonEventKind.rise,
                  'Set' => MoonEventKind.set,
                  _ => null,
                };
                if (kind == null) return;
                final p = (hhmm as String).split(':');
                final t = DateTime.parse('${e['utcDate']}T${p[0]}:${p[1]}:00Z');
                if (night.contains(t)) refs.add((kind, t));
              });
            }
            expect(
              ours.length,
              refs.length,
              reason:
                  '$site $d: ours ${ours.map((e) => '${e.kind.name} ${e.utc}')}'
                  ' vs USNO $refs',
            );
            for (final (kind, t) in refs) {
              final got = ours.where((e) => e.kind == kind).toList()
                ..sort(
                  (a, b) => a.utc
                      .difference(t)
                      .abs()
                      .compareTo(b.utc.difference(t).abs()),
                );
              expect(got, isNotEmpty, reason: '$site $d $kind');
              final minutes = got.first.utc.difference(t).inSeconds / 60.0;
              // USNO rounds to the minute: ±0.5 min on top of ADR-010's range.
              expect(
                minutes,
                inInclusiveRange(-2.5, 7.5),
                reason: '$site $d $kind: ${got.first.utc} vs $t',
              );
              matched++;
            }
          }
        }
        expect(matched, greaterThanOrEqualTo(20));
      },
    );
  });

  test('a night with no moonrise/moonset is typed, not null', () {
    // Search the fixture nights at 69.65°N for one without events; when the
    // Moon never crosses, the result says whether it stayed up or down.
    for (final d in ['2026-06-21', '2026-12-21', '2027-01-15', '2026-03-01']) {
      final night = SessionNightResolver.forEveningDate(
        CalendarDate.parse(d),
        latitude: 69.65,
        longitude: 18.96,
        timeContext: MeanSolarTimeContext(18.96),
      );
      final rs = MoonCalculator.riseSetForNight(night);
      if (rs.events.isEmpty) {
        expect(rs.alwaysAbove != rs.alwaysBelow, isTrue);
      } else {
        expect(rs.alwaysAbove || rs.alwaysBelow, isFalse);
      }
    }
  });

  test('ΔT is documented and plausible (60–80 s)', () {
    expect(MoonCalculator.deltaTSeconds, inInclusiveRange(60, 80));
  });
}
