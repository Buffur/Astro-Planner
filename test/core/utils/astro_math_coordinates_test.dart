// TASK 8.1: pure parsing and formatting of typed RA/Dec. Expected values are
// computed by hand: RA degrees = (h + m/60 + s/3600) × 15; Dec = sign ×
// (d + m/60 + s/3600).

import 'package:astroplan/core/utils/astro_math.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  const eps = 1e-9;

  group('parseRightAscension (hours unless marked as degrees)', () {
    // 05h35m17s = 5.588055… h = 83.820833… °
    const m42 = (5 + 35 / 60 + 17 / 3600) * 15;

    test('the acceptance example and its variants', () {
      for (final text in [
        '05h35m17s',
        '5h35m17s',
        '5h 35m 17s',
        '5:35:17',
        '05 35 17',
        '5ʰ35ᵐ17ˢ',
      ]) {
        expect(
          AstroMath.parseRightAscension(text),
          closeTo(m42, eps),
          reason: text,
        );
      }
      expect(m42, closeTo(83.8208333, 1e-7));
    });

    test('decimal seconds, h m, and decimal hours', () {
      expect(
        AstroMath.parseRightAscension('00h42m44.3s'),
        closeTo((42 / 60 + 44.3 / 3600) * 15, eps),
      );
      expect(
        AstroMath.parseRightAscension('5h35.5m'),
        closeTo(5.591666666 * 15, 1e-6),
      );
      expect(AstroMath.parseRightAscension('5.5'), closeTo(82.5, eps));
      expect(AstroMath.parseRightAscension('0'), 0);
    });

    test('explicit degrees need a suffix', () {
      expect(AstroMath.parseRightAscension('83.82°'), closeTo(83.82, eps));
      expect(AstroMath.parseRightAscension('83.82 deg'), closeTo(83.82, eps));
      expect(AstroMath.parseRightAscension('83.82d'), closeTo(83.82, eps));
      expect(AstroMath.parseRightAscension('83.82'), isNull, reason: '> 24 h');
    });

    test('invalid input is rejected', () {
      for (final text in [
        '',
        'abc',
        '-1',
        '24',
        '24:00:00',
        '5:60:00',
        '5:35:60',
        '5.5:35:17',
        '1 2 3 4',
        '360°',
      ]) {
        expect(AstroMath.parseRightAscension(text), isNull, reason: text);
      }
    });
  });

  group('parseDeclination', () {
    // −05°23′28″ = −(5 + 23/60 + 28/3600) = −5.391111…
    const m42 = -(5 + 23 / 60 + 28 / 3600);

    test('the acceptance example and its variants', () {
      for (final text in [
        '−05°23′28″',
        '-05°23\'28"',
        '-5:23:28',
        '-5 23 28',
        '-5d23m28s',
      ]) {
        expect(
          AstroMath.parseDeclination(text),
          closeTo(m42, eps),
          reason: text,
        );
      }
      expect(m42, closeTo(-5.3911111, 1e-7));
    });

    test('the sign applies to the whole value, including −0°30′', () {
      expect(AstroMath.parseDeclination('-0 30'), closeTo(-0.5, eps));
      expect(AstroMath.parseDeclination('−00°30′00″'), closeTo(-0.5, eps));
      expect(AstroMath.parseDeclination('-0:30:00'), closeTo(-0.5, eps));
      expect(AstroMath.parseDeclination('+0 30'), closeTo(0.5, eps));
    });

    test('decimal degrees and the limits', () {
      expect(AstroMath.parseDeclination('41.2687'), closeTo(41.2687, eps));
      expect(AstroMath.parseDeclination('+90'), 90);
      expect(AstroMath.parseDeclination('-90:00:00'), -90);
    });

    test('invalid input is rejected', () {
      for (final text in [
        '',
        'xyz',
        '-91',
        '90:00:01',
        '45 60 00',
        '--5',
        '5°5°5°5',
      ]) {
        expect(AstroMath.parseDeclination(text), isNull, reason: text);
      }
    });
  });

  group('formatting (the UI only formats)', () {
    test('RA and Dec formats', () {
      final ra = (5 + 35 / 60 + 17.3 / 3600) * 15;
      expect(AstroMath.formatRightAscension(ra), '05h35m17.3s');
      expect(AstroMath.formatRightAscension(0), '00h00m00.0s');
      expect(AstroMath.formatRightAscension(359.99999), '00h00m00.0s');
      expect(
        AstroMath.formatDeclination(-(5 + 23 / 60 + 28 / 3600)),
        '−05°23′28″',
      );
      expect(AstroMath.formatDeclination(41.2687), '+41°16′07″');
      expect(AstroMath.formatDeclination(-0.5), '−00°30′00″');
      expect(AstroMath.formatDeclination(-0.00001), '+00°00′00″');
    });

    test('formatted text parses back within the display resolution', () {
      for (final ra in [0.0, 10.6847, 83.8221, 201.365, 359.9]) {
        final back = AstroMath.parseRightAscension(
          AstroMath.formatRightAscension(ra),
        )!;
        expect(
          (back - ra).abs(),
          lessThan(0.1 / 3600 * 15 + 1e-9),
          reason: '$ra',
        );
      }
      for (final dec in [-89.99, -5.3911, -0.5, 0.0, 41.2687, 90.0]) {
        final back = AstroMath.parseDeclination(
          AstroMath.formatDeclination(dec),
        )!;
        expect((back - dec).abs(), lessThan(1 / 3600 + 1e-9), reason: '$dec');
      }
    });
  });
}
