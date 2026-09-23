import 'package:flutter/widgets.dart';
import 'package:go_router/go_router.dart';
import 'package:latlong2/latlong.dart';

import '../../core/config/feature_scope.dart';
import '../screens/about/about_screen.dart';
import '../screens/equipment/equipment_selection_screen.dart';
import '../screens/home/session_planner_route.dart';
import '../screens/library/library_screen.dart';
import '../screens/location/location_picker_screen.dart';
import '../screens/logbook/logbook_screen.dart';
import '../screens/metadata/metadata_import_screen.dart';
import '../screens/settings/settings_screen.dart';
import '../screens/sites/site_editor_screen.dart';
import '../screens/sites/sites_screen.dart';
import '../screens/target/target_selection_screen.dart';
import '../screens/tonight/tonight_candidates_screen.dart';
import '../screens/tonight/tonight_home_screen.dart';
import 'app_shell.dart';

/// The route map of ADR-015 (TASK 12.2; `docs/IA_WIREFRAMES.md` §2).
///
/// Four tabs in a [StatefulShellRoute] — Tonight, Sessions, Library,
/// Settings — each with its own navigator and kept state. Pages that
/// should cover the tabs (the session planner, the pickers it opens, the
/// site editor and the map pickers) live on the root navigator.
class AppRouter {
  static final rootNavigatorKey = GlobalKey<NavigatorState>();

  /// Paths, so screens never spell them out by hand.
  static const tonight = '/tonight';
  static const candidates = '/tonight/candidates';
  static const sessions = '/sessions';
  static const library = '/library';
  static const libraryRigs = '/library/rigs';
  static const libraryTargets = '/library/targets';
  static const librarySites = '/library/sites';
  static const settings = '/settings';
  static const about = '/settings/about';
  static const metadata = '/settings/metadata';

  /// The session planner for the current session (`/session/current`) or
  /// a stored session id.
  static String session([Object id = 'current']) => '/session/$id';
  static const selectTarget = '/select/target';
  static const selectRig = '/select/rig';
  static const selectSite = '/select/site';
  static const siteEdit = '/site/edit';
  static const sitePick = '/site/pick';
  static const position = '/position';

  static final router = GoRouter(
    navigatorKey: rootNavigatorKey,
    initialLocation: tonight,
    redirect: (context, state) =>
        state.uri.path == '/' || state.uri.path.isEmpty ? tonight : null,
    routes: [
      StatefulShellRoute.indexedStack(
        builder: (context, state, shell) => AppShell(navigationShell: shell),
        branches: [
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: tonight,
                builder: (context, state) => const TonightHomeScreen(),
                routes: [
                  GoRoute(
                    path: 'candidates',
                    builder: (context, state) =>
                        const TonightCandidatesScreen(),
                  ),
                ],
              ),
            ],
          ),
          if (FeatureScope.logbook)
            StatefulShellBranch(
              routes: [
                GoRoute(
                  path: sessions,
                  builder: (context, state) => const LogbookScreen(),
                ),
              ],
            ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: library,
                builder: (context, state) => const LibraryScreen(),
                routes: [
                  GoRoute(
                    path: 'rigs',
                    builder: (context, state) =>
                        const EquipmentSelectionScreen(),
                  ),
                  GoRoute(
                    path: 'targets',
                    builder: (context, state) => const TargetSelectionScreen(),
                  ),
                  GoRoute(
                    path: 'sites',
                    builder: (context, state) => const SitesScreen(),
                  ),
                ],
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: settings,
                builder: (context, state) => const SettingsScreen(),
                routes: [
                  GoRoute(
                    path: 'about',
                    builder: (context, state) => const AboutScreen(),
                  ),
                  if (FeatureScope.metadataImport)
                    GoRoute(
                      path: 'metadata',
                      builder: (context, state) => const MetadataImportScreen(),
                    ),
                ],
              ),
            ],
          ),
        ],
      ),
      // Above the tabs (root navigator): back returns where they came from.
      GoRoute(
        path: '/session/:id',
        parentNavigatorKey: rootNavigatorKey,
        builder: (context, state) =>
            SessionPlannerRoute(id: state.pathParameters['id']!),
      ),
      GoRoute(
        path: selectTarget,
        parentNavigatorKey: rootNavigatorKey,
        builder: (context, state) => const TargetSelectionScreen(),
      ),
      GoRoute(
        path: selectRig,
        parentNavigatorKey: rootNavigatorKey,
        builder: (context, state) => const EquipmentSelectionScreen(),
      ),
      GoRoute(
        path: selectSite,
        parentNavigatorKey: rootNavigatorKey,
        builder: (context, state) => const SitesScreen(),
      ),
      GoRoute(
        path: siteEdit,
        parentNavigatorKey: rootNavigatorKey,
        builder: (context, state) => SiteEditorScreen(
          args: state.extra as SiteEditorArgs? ?? const SiteEditorArgs(),
        ),
      ),
      // The map as a coordinate picker for the site editor (TASK 7.3).
      GoRoute(
        path: sitePick,
        parentNavigatorKey: rootNavigatorKey,
        builder: (context, state) => LocationPickerScreen(
          pickOnly: true,
          initial: state.extra as LatLng?,
        ),
      ),
      // A transient position: map pick or GPS (TASK 7.1).
      GoRoute(
        path: position,
        parentNavigatorKey: rootNavigatorKey,
        builder: (context, state) => const LocationPickerScreen(),
      ),
    ],
  );
}
