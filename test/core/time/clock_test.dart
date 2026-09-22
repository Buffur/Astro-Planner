import 'dart:io';

import 'package:astroplan/core/time/clock.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('FixedClock returns its instant and requires UTC', () {
    final instant = DateTime.utc(2026, 9, 22, 1, 30);
    expect(FixedClock(instant).nowUtc(), instant);
    expect(() => FixedClock(DateTime(2026, 9, 22)), throwsArgumentError);
  });

  test('SystemClock returns UTC', () {
    expect(const SystemClock().nowUtc().isUtc, isTrue);
  });

  // TASK 2.2 acceptance / MASTER_ROADMAP AC2: "now" in the domain comes from a
  // Clock, never from DateTime.now().
  test('no DateTime.now() in lib/domain', () {
    final offenders = Directory('lib/domain')
        .listSync(recursive: true)
        .whereType<File>()
        .where((f) => f.path.endsWith('.dart'))
        .where((f) => f.readAsStringSync().contains('DateTime.now('))
        .map((f) => f.path)
        .toList();
    expect(offenders, isEmpty);
  });
}
