// TASK 6.2: the app's astronomy against independent published references
// (USNO, JPL Horizons, SIMBAD) — never against itself (SCIENTIFIC_INTEGRITY
// Part C rule 3). Fixtures in test/fixtures/astronomy/ record their source,
// query and retrieval date. Tolerances: ADR-010 §4.

import 'dart:convert';
import 'dart:io';

import 'package:astroplan/domain/models/astro_target.dart';
import 'package:astroplan/domain/models/calendar_date.dart';
import 'package:astroplan/domain/models/night_timeline.dart';
import 'package:astroplan/domain/models/session_night.dart';
import 'package:astroplan/domain/models/site_time_context.dart';
import 'package:astroplan/domain/services/astronomical_engine.dart';
import 'package:astroplan/domain/services/session_night_resolver.dart';
import 'package:astroplan/domain/services/visibility_calculator.dart';
import 'package:flutter_test/flutter_test.dart';

Map<String, dynamic> _fixture(String name) =>
    jsonDecode(File('test/fixtures/astronomy/$name').readAsStringSync())
        as Map<String, dynamic>;

double _d(Object? v) => (v as num).toDouble();

SessionNight _night(String eveningDate, double lat, double lon) =>
    SessionNightResolver.forEveningDate(
      CalendarDate.parse(eveningDate),
      latitude: lat,
      longitude: lon,
      timeContext: MeanSolarTimeContext(lon),
    );

SunThresholdResult _atThreshold(NightTimeline tl, double th) => switch (th) {
  -0.833 => tl.sunriseSunset,
  -6.0 => tl.civilTwilight,
  -12.0 => tl.nauticalTwilight,
  _ => tl.astronomicalTwilight,
};

/// ADR-010 §4: events are reported on the 5-min grid at the first sample
/// after the crossing, so reported − reference ∈ [−2, +7] min.
void _expectOnGrid(DateTime? got, DateTime ref, String what) {
  expect(got, isNotNull, reason: '$what: no crossing reported');
  final minutes = got!.difference(ref).inSeconds / 60.0;
  expect(
    minutes,
    inInclusiveRange(-2.0, 7.0),
    reason:
        '$what: reported ${got.toIso8601String()} vs ${ref.toIso8601String()}',
  );
}

void main() {
  group('Sun vs JPL Horizons (airless)', () {
    final hz = _fixture('horizons_sun.json');

    test('altitude within 0.02° at every hourly spot sample', () {
      var worst = 0.0;
      for (final s in hz['spotElevations'] as List) {
        final a = VisibilityCalculator.calculateSunAltitude(
          DateTime.parse(s['utc'] as String),
          _d(s['lat']),
          _d(s['lon']),
        );
        final err = (a - _d(s['elevationDeg'])).abs();
        if (err > worst) worst = err;
      }
      expect(worst, lessThan(0.02)); // measured 0.0097° (2026-09-22)
    });

    test('sunset/sunrise and civil, nautical, astronomical twilight on the grid', () {
      var checked = 0;
      for (final c in hz['crossings'] as List) {
        final tl = VisibilityCalculator.calculateNightTimelineForNight(
          _night(c['eveningDate'] as String, _d(c['lat']), _d(c['lon'])),
        );
        for (final e in c['events'] as List) {
          final res = _atThreshold(tl, _d(e['thresholdDeg']));
          expect(res, isA<SunCrossing>());
          final crossing = res as SunCrossing;
          _expectOnGrid(
            e['kind'] == 'dusk' ? crossing.duskUtc : crossing.dawnUtc,
            DateTime.parse(e['utc'] as String),
            '${c['site']} ${c['eveningDate']} ${e['kind']} ${e['thresholdDeg']}',
          );
          checked++;
        }
      }
      expect(checked, greaterThanOrEqualTo(100));
    });

    test(
      'polar nights: thresholds Horizons never crosses are typed, not null',
      () {
        for (final c in hz['crossings'] as List) {
          final tl = VisibilityCalculator.calculateNightTimelineForNight(
            _night(c['eveningDate'] as String, _d(c['lat']), _d(c['lon'])),
          );
          for (final th in [-0.833, -6.0, -12.0, -18.0]) {
            final res = _atThreshold(tl, th);
            if (_d(c['minElevationDeg']) > th) {
              expect(res, isA<SunNeverBelow>(), reason: '${c['site']} $th');
            }
            if (_d(c['maxElevationDeg']) < th) {
              expect(res, isA<SunAlwaysBelow>(), reason: '${c['site']} $th');
            }
          }
        }
      },
    );
  });

  group('Sun vs USNO rise/set and civil twilight', () {
    final usno = _fixture('usno_sun_moon_events.json');
    final entries = (usno['entries'] as List).cast<Map<String, dynamic>>();
    const phenomena = {
      'Set': (-0.833, 'dusk'),
      'Rise': (-0.833, 'dawn'),
      'End Civil Twilight': (-6.0, 'dusk'),
      'Begin Civil Twilight': (-6.0, 'dawn'),
    };

    test('every USNO event inside a night is reported on the grid', () {
      var checked = 0;
      final evenings = {
        for (final e in entries) (e['site'], e['lat'], e['lon']): true,
      };
      for (final (site, lat, lon) in evenings.keys) {
        for (final d in [
          '2026-03-01',
          '2026-06-21',
          '2026-09-22',
          '2026-12-21',
          '2027-01-15',
        ]) {
          final night = _night(d, _d(lat), _d(lon));
          final tl = VisibilityCalculator.calculateNightTimelineForNight(night);
          for (final e in entries.where((e) => e['site'] == site)) {
            (e['sun'] as Map).forEach((phen, hhmm) {
              final spec = phenomena[phen];
              if (spec == null) return;
              final parts = (hhmm as String).split(':');
              final ref = DateTime.parse(
                '${e['utcDate']}T${parts[0]}:${parts[1]}:00Z',
              );
              if (!night.contains(ref)) return;
              final res = _atThreshold(tl, spec.$1) as SunCrossing;
              // USNO rounds to the minute: allow its ±0.5 min as well.
              final got = spec.$2 == 'dusk' ? res.duskUtc : res.dawnUtc;
              expect(got, isNotNull, reason: '$site $d $phen');
              final minutes = got!.difference(ref).inSeconds / 60.0;
              expect(
                minutes,
                inInclusiveRange(-2.5, 7.5),
                reason: '$site $d $phen: $got vs $ref',
              );
              checked++;
            });
          }
        }
      }
      expect(checked, greaterThanOrEqualTo(40));
    });
  });

  group('Fixed stars vs USNO computed altitude (J2000 from SIMBAD)', () {
    final st = _fixture('usno_celnav_stars.json');
    final stars = st['stars'] as Map<String, dynamic>;
    AstroTarget target(String name) => AstroTarget(
      id: 0,
      catalogId: name,
      commonName: name,
      rightAscension: _d(stars[name]['raDeg']),
      declination: _d(stars[name]['decDeg']),
      type: 'Star',
    );

    test('altitude within 0.05° with J2000 -> date precession', () {
      var worst = 0.0;
      final obs = st['observations'] as List;
      for (final o in obs) {
        final a = VisibilityCalculator.calculateTargetAltitude(
          target(o['star'] as String),
          DateTime.parse(o['utc'] as String),
          _d(o['lat']),
          _d(o['lon']),
        );
        final err = (a - _d(o['hcDeg'])).abs();
        if (err > worst) worst = err;
      }
      expect(obs.length, greaterThanOrEqualTo(50));
      expect(worst, lessThan(0.05)); // measured 0.017° (2026-09-22)
    });

    test('precessed declination matches USNO declination of date to 0.03°', () {
      for (final o in st['observations'] as List) {
        final t = target(o['star'] as String);
        final (_, dec) = AstronomicalEngine.precessJ2000ToDate(
          t.rightAscension,
          t.declination,
          AstronomicalEngine.calculateJulianDate(
            DateTime.parse(o['utc'] as String),
          ),
        );
        expect((dec - _d(o['decOfDateDeg'])).abs(), lessThan(0.03));
      }
    });

    test(
      'without precession the error exceeds the tolerance (regression guard)',
      () {
        var worst = 0.0;
        for (final o in st['observations'] as List) {
          final t = target(o['star'] as String);
          final instant = DateTime.parse(o['utc'] as String);
          final jd = AstronomicalEngine.calculateJulianDate(instant);
          final lst = AstronomicalEngine.calculateLST(
            AstronomicalEngine.calculateGMST(jd),
            _d(o['lon']),
          );
          final a = VisibilityCalculator.calculateAltitude(
            lha: VisibilityCalculator.calculateLHA(lst, t.rightAscension),
            declination: t.declination,
            latitude: _d(o['lat']),
          );
          final err = (a - _d(o['hcDeg'])).abs();
          if (err > worst) worst = err;
        }
        expect(worst, greaterThan(0.2)); // measured 0.32° (2026-09-22)
      },
    );
  });

  test('precession at J2000.0 is the identity', () {
    final (ra, dec) = AstronomicalEngine.precessJ2000ToDate(
      101.287155,
      -16.716116,
      2451545.0,
    );
    expect(ra, closeTo(101.287155, 1e-9));
    expect(dec, closeTo(-16.716116, 1e-9));
  });
}
