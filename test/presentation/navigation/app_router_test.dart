// Roadmap TASK 4.3, TD-014: a gated feature has no entry point — checked
// here at the route level (home_screen_test.dart checks the button/card
// level). AppRouter.router only ever registers '/metadata' when
// FeatureScope.metadataImport is true, so with it false (PD-06 E.1) the
// route must not exist at all, not just be unreachable from the UI.

import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:astroplan/core/config/feature_scope.dart';
import 'package:astroplan/presentation/navigation/app_router.dart';

void main() {
  test('the metadata route does not exist while it is gated', () {
    expect(FeatureScope.metadataImport, isFalse);

    final paths = AppRouter.router.configuration.routes
        .whereType<GoRoute>()
        .map((r) => r.path);

    expect(paths, isNot(contains('/metadata')));
  });

  test('the logbook route exists while it stays visible', () {
    expect(FeatureScope.logbook, isTrue);

    final paths = AppRouter.router.configuration.routes
        .whereType<GoRoute>()
        .map((r) => r.path);

    expect(paths, contains('/logbook'));
  });
}
