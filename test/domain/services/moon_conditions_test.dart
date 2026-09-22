// TASK 6.4: Moon–target separation against independent references (USNO
// celnav, JPL Horizons, SIMBAD), and MoonConditions behaviour. Tolerance:
// ADR-010 §4 (separation ≤ 0.05°). Fixture: moon_separation.json.

import 'dart:convert';
import 'dart:io';

import 'package:astroplan/domain/models/astro_target.dart';
import 'package:astroplan/domain/models/calendar_date.dart';
import 'package:astroplan/domain/models/site_time_context.dart';
import 'package:astroplan/domain/services/astronomical_engine.dart';
import 'package:astroplan/domain/services/moon_calculator.dart';
import 'package:astroplan/domain/services/session_night_resolver.dart';
import 'package:flutter_test/flutter_test.dart';

Map<String, dynamic> _fixture(String name) =>
    jsonDecode(File('test/fixtures/astronomy/$name').readAsStringSync())
        as Map<String, dynamic>;

double _n(Object? v) => (v as num).toDouble();

void main() {
  final sep = _fixture('moon_separation.json');
  final stars =
      _fixture('usno_celnav_stars.json')['stars'] as Map<String, dynamic>;
  AstroTarget star(String name) => AstroTarget(
    id: 0,
    catalogId: name,
    commonName: name,
    rightAscension: _n(stars[name]['raDeg']),
    declination: _n(stars[name]['decDeg']),
    type: 'Star',
  );

  test('geocentric Moon–star separation within 0.05° of USNO', () {
    var n = 0;
    for (final e in (sep['geocentric'] as List).cast<Map<String, dynamic>>()) {
      final t = DateTime.parse(e['utc'] as String);
      final aries = _n(e['aries_gha']);
      final moonRef = e['moon'] as Map<String, dynamic>;
      final m = MoonCalculator.position(t);
      (e['stars'] as Map<String, dynamic>).forEach((name, s) {
        final ref = MoonCalculator.angularSeparationDeg(
          aries - _n(moonRef['gha']),
          _n(moonRef['dec']),
          aries - _n(s['gha']),
          _n(s['dec']),
        );
        final target = star(name);
        final (ra, dec) = AstronomicalEngine.precessJ2000ToDate(
          target.rightAscension,
          target.declination,
          AstronomicalEngine.calculateJulianDate(t),
        );
        final ours = MoonCalculator.angularSeparationDeg(
          m.rightAscensionDeg,
          m.declinationDeg,
          ra,
          dec,
        );
        expect((ours - ref).abs(), lessThan(0.05), reason: '$name ${e['utc']}');
        n++;
      });
    }
    expect(n, greaterThanOrEqualTo(40));
  });

  test('topocentric Moon–star separation within 0.05° (Horizons Moon, USNO '
      'stars)', () {
    final geo = {
      for (final e in (sep['geocentric'] as List).cast<Map<String, dynamic>>())
        e['utc']: e,
    };
    var n = 0;
    for (final m
        in (sep['topocentricMoon'] as List).cast<Map<String, dynamic>>()) {
      final e = geo[m['utc']]!;
      final aries = _n(e['aries_gha']);
      final t = DateTime.parse(m['utc'] as String);
      (e['stars'] as Map<String, dynamic>).forEach((name, s) {
        final ref = MoonCalculator.angularSeparationDeg(
          _n(m['raDeg']),
          _n(m['decDeg']),
          aries - _n(s['gha']),
          _n(s['dec']),
        );
        final ours = MoonCalculator.separationFromTarget(
          star(name),
          t,
          _n(m['lat']),
          _n(m['lon']),
        );
        expect(
          (ours - ref).abs(),
          lessThan(0.05),
          reason: '${m['site']} $name ${m['utc']}',
        );
        n++;
      });
    }
    expect(n, greaterThanOrEqualTo(100));
  });

  test('angular separation: identity, antipode, quarter circle', () {
    expect(MoonCalculator.angularSeparationDeg(10, 20, 10, 20), 0);
    expect(
      MoonCalculator.angularSeparationDeg(0, 0, 180, 0),
      closeTo(180, 1e-9),
    );
    expect(MoonCalculator.angularSeparationDeg(0, 0, 0, 90), closeTo(90, 1e-9));
  });

  group('MoonConditions', () {
    final night = SessionNightResolver.forEveningDate(
      CalendarDate(2026, 3, 1),
      latitude: 51.5,
      longitude: -0.1,
      timeContext: MeanSolarTimeContext(-0.1),
    );
    final m42 = AstroTarget(
      id: 0,
      catalogId: 'M42',
      rightAscension: 83.8221,
      declination: -5.3911,
      type: 'Nebula',
    );

    test(
      'samples cover the night grid; illumination at mean solar midnight',
      () {
        final c = MoonCalculator.conditionsForNight(night, target: m42);
        expect(c.samples.length, 289);
        expect(c.samples.first.instantUtc, night.startUtc);
        expect(c.samples.last.instantUtc, night.endUtc);
        expect(
          c.illuminationAtMidnight,
          MoonCalculator.illuminatedFraction(
            night.startUtc.add(const Duration(hours: 12)),
          ),
        );
        // 2026-03-01 is two days before full moon (USNO: 2026-03-03).
        expect(c.illuminationAtMidnight, greaterThan(0.9));
      },
    );

    test('closest approach only counts instants when both are up', () {
      final c = MoonCalculator.conditionsForNight(night, target: m42);
      final approach = c.closestApproachWhileBothUp!;
      final s = c.samples.firstWhere(
        (s) => s.instantUtc == approach.instantUtc,
      );
      expect(s.altitudeDeg, greaterThan(0));
      expect(s.targetAltitudeDeg, greaterThan(0));
      for (final x in c.samples) {
        if (x.altitudeDeg > 0 && x.targetAltitudeDeg! > 0) {
          expect(x.separationDeg, greaterThanOrEqualTo(approach.separationDeg));
        }
      }
    });

    test('a target that never rises: no approach (null, not 0)', () {
      final southern = AstroTarget(
        id: 0,
        catalogId: 'SouthPoleStar',
        rightAscension: 0,
        declination: -80,
        type: 'Star',
      );
      final c = MoonCalculator.conditionsForNight(night, target: southern);
      expect(c.closestApproachWhileBothUp, isNull);
      expect(c.samples.every((s) => s.separationDeg != null), isTrue);
    });

    test('without a target: no separation data', () {
      final c = MoonCalculator.conditionsForNight(night);
      expect(c.samples.every((s) => s.separationDeg == null), isTrue);
      expect(c.closestApproachWhileBothUp, isNull);
    });

    test('up intervals follow rise/set and stay inside the night', () {
      final c = MoonCalculator.conditionsForNight(night);
      for (final (a, b) in c.upIntervals) {
        expect(a.isBefore(b), isTrue);
        expect(night.contains(a) || a == night.startUtc, isTrue);
        expect(!b.isAfter(night.endUtc), isTrue);
        // Mid-interval the Moon is up (topocentric altitude above −1°, the
        // rise/set convention differing slightly from 0° geometric).
        final mid = a.add(b.difference(a) ~/ 2);
        expect(
          MoonCalculator.topocentricAltitude(mid, 51.5, -0.1),
          greaterThan(-1),
        );
      }
    });

    test('Moon below the horizon: those samples have negative altitude', () {
      final c = MoonCalculator.conditionsForNight(night);
      final below = c.samples.where((s) => s.altitudeDeg < 0);
      expect(below, isNotEmpty); // the Moon sets before this night's noon
      for (final (a, b) in c.upIntervals) {
        for (final s in below) {
          final inside =
              !s.instantUtc.isBefore(a.add(const Duration(minutes: 10))) &&
              s.instantUtc.isBefore(b.subtract(const Duration(minutes: 10)));
          expect(inside, isFalse);
        }
      }
    });
  });
}
