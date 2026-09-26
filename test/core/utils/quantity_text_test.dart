// S1.7 (ENG-06, UX-19): one written form per quantity, with its rounding
// rule at the boundaries.

import 'package:astroplan/core/utils/quantity_text.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  String d(Duration value) => QuantityText.duration(value);

  test('durations round to the nearest minute, one form for all', () {
    expect(d(Duration.zero), '0 min');
    expect(d(const Duration(minutes: 45)), '45 min');
    expect(d(const Duration(minutes: 59, seconds: 29)), '59 min');
    expect(d(const Duration(minutes: 59, seconds: 30)), '1 h');
    expect(d(const Duration(hours: 3)), '3 h');
    expect(d(const Duration(hours: 4, minutes: 42)), '4 h 42 min');
    expect(d(const Duration(hours: 1, minutes: 40)), '1 h 40 min');
  });

  test('under a minute is in seconds, never "0 min"', () {
    expect(d(const Duration(seconds: 30)), '30 s');
    expect(d(const Duration(milliseconds: 200)), '1 s');
    expect(d(const Duration(seconds: 59, milliseconds: 600)), '1 min');
  });

  test('a negative duration keeps its sign', () {
    expect(d(const Duration(minutes: -5)), '−5 min');
  });

  test('exposures keep their value without a trailing .0', () {
    expect(QuantityText.exposure(60), '60 s');
    expect(QuantityText.exposure(2.5), '2.5 s');
    expect(QuantityText.exposure(0.25), '1/4 s');
    expect(QuantityText.exposure(0.02), '1/50 s');
    expect(QuantityText.exposure(0.04), '1/25 s');
    expect(QuantityText.exposure(0.04005), '≈1/25 s');
    expect(QuantityText.exposure(0.4), '0.4 s');
    expect(QuantityText.exposure(0), '0 s');
    expect(QuantityText.exposure(1), '1 s');
    expect(QuantityText.exposure(1 / 8000), '1/8000 s');
    expect(QuantityText.exposure(0.009987236), '≈1/100 s');
    expect(QuantityText.exposure(0.0099), '≈1/101 s');
    expect(QuantityText.exposure(0.29), '0.29 s');
  });

  test('degrees and signed numbers use the typographic minus, never −0', () {
    expect(QuantityText.degrees(-18), '−18°');
    expect(QuantityText.degrees(30), '30°');
    expect(QuantityText.degrees(46.05, digits: 3), '46.050°');
    expect(QuantityText.degrees(-0.2), '0°');
    expect(QuantityText.signed(-3, digits: 1), '−3.0');
  });

  test('percentages have a space before the sign', () {
    expect(QuantityText.percent(3.4), '3 %');
    expect(QuantityText.percent(97), '97 %');
  });
}
