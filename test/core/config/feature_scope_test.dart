// Locks in the PD-06 gate policy (roadmap TASK 4.3, TD-014;
// docs/DECISIONS.md PD-06 E.1), so an accidental flip of one flag is a
// failing test, not a silent policy violation.
//
//   Hidden: metadata import (until G17 / v1.1).
//   Visible since TASK 12.4 (its scheduled phase): red field mode.
//   Visible since TASK 7.4 (its scheduled phase): the light-pollution
//   context — manual Bortle/SQM and the external map at the site.
//   Stays visible: the logbook (and text sharing, which has no gate of its
//   own — it only appears inside the logbook screen this already gates).

import 'package:flutter_test/flutter_test.dart';
import 'package:astroplan/core/config/feature_scope.dart';

void main() {
  // Before TASK 12.4 this asserted `isFalse` (hidden until 12.4, PD-06
  // E.1); 12.4 is the phase PD-06 scheduled it for.
  test('fieldMode is visible (since TASK 12.4)', () {
    expect(FeatureScope.fieldMode, isTrue);
  });

  // Before TASK 7.4 this asserted `isFalse` (hidden until 7.4, PD-06 E.1);
  // 7.4 is the phase PD-06 scheduled it for.
  test('lightPollutionContext is visible (since TASK 7.4)', () {
    expect(FeatureScope.lightPollutionContext, isTrue);
  });

  test('metadataImport is hidden (until G17 / v1.1)', () {
    expect(FeatureScope.metadataImport, isFalse);
  });

  test('logbook stays visible (on the core path)', () {
    expect(FeatureScope.logbook, isTrue);
  });
}
