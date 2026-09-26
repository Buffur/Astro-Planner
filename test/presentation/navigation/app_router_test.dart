// Roadmap TASK 4.3, TD-014: a gated feature has no entry point — checked
// here at the route level (home_screen_test.dart checks the button/card
// level). AppRouter.router only ever registers the metadata route when
// FeatureScope.metadataImport is true. Since S3.7 (ADR-018 §7) the import is
// a root route opened from the equipment screen, no longer under Settings.
// TASK 12.2 (ADR-015): routes are nested in the navigation shell, so the
// full paths are collected (support/route_paths.dart); metadata import is
// /equipment/import and the logbook is the Sessions tab, /sessions.

import 'package:flutter_test/flutter_test.dart';
import 'package:astroplan/core/config/feature_scope.dart';
import 'package:astroplan/presentation/navigation/app_router.dart';

import '../../support/route_paths.dart';

void main() {
  test('the metadata import route exists above the tabs, not in Settings', () {
    expect(FeatureScope.metadataImport, isTrue);

    expect(AppRouter.metadata, '/equipment/import');
    expect(allRoutePaths(), contains(AppRouter.metadata));
    expect(allRoutePaths(), isNot(contains('/settings/metadata')));
  });

  test('the logbook route exists while it stays visible', () {
    expect(FeatureScope.logbook, isTrue);

    expect(allRoutePaths(), contains(AppRouter.sessions));
  });
}
