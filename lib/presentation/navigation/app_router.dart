import 'package:go_router/go_router.dart';
import 'package:latlong2/latlong.dart';

import '../../core/config/feature_scope.dart';
import '../screens/about/about_screen.dart';
import '../screens/home/home_screen.dart';
import '../screens/target/target_selection_screen.dart';
import '../screens/equipment/equipment_selection_screen.dart';
import '../screens/location/location_picker_screen.dart';
import '../screens/metadata/metadata_import_screen.dart';
import '../screens/logbook/logbook_screen.dart';
import '../screens/settings/settings_screen.dart';
import '../screens/tonight/tonight_screen.dart';
import '../screens/sites/site_editor_screen.dart';
import '../screens/sites/sites_screen.dart';

class AppRouter {
  static final router = GoRouter(
    initialLocation: '/',
    routes: [
      GoRoute(path: '/', builder: (context, state) => const HomeScreen()),
      GoRoute(
        path: '/target',
        builder: (context, state) => const TargetSelectionScreen(),
      ),
      GoRoute(
        path: '/equipment',
        builder: (context, state) => const EquipmentSelectionScreen(),
      ),
      GoRoute(
        path: '/location',
        builder: (context, state) => const LocationPickerScreen(),
      ),
      // The map as a coordinate picker for the site editor (TASK 7.3).
      GoRoute(
        path: '/location/pick',
        builder: (context, state) => LocationPickerScreen(
          pickOnly: true,
          initial: state.extra as LatLng?,
        ),
      ),
      GoRoute(path: '/sites', builder: (context, state) => const SitesScreen()),
      GoRoute(
        path: '/sites/edit',
        builder: (context, state) => SiteEditorScreen(
          args: state.extra as SiteEditorArgs? ?? const SiteEditorArgs(),
        ),
      ),
      GoRoute(path: '/about', builder: (context, state) => const AboutScreen()),
      // TASK 10.4: tonight's candidates across all targets.
      GoRoute(
        path: '/tonight',
        builder: (context, state) => const TonightScreen(),
      ),
      GoRoute(
        path: '/settings',
        builder: (context, state) => const SettingsScreen(),
      ),
      if (FeatureScope.metadataImport)
        GoRoute(
          path: '/metadata',
          builder: (context, state) => const MetadataImportScreen(),
        ),
      if (FeatureScope.logbook)
        GoRoute(
          path: '/logbook',
          builder: (context, state) => const LogbookScreen(),
        ),
    ],
  );
}
