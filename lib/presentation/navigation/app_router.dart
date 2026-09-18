import 'package:go_router/go_router.dart';

import '../../core/config/feature_scope.dart';
import '../screens/home/home_screen.dart';
import '../screens/target/target_selection_screen.dart';
import '../screens/equipment/equipment_selection_screen.dart';
import '../screens/location/location_picker_screen.dart';
import '../screens/metadata/metadata_import_screen.dart';
import '../screens/logbook/logbook_screen.dart';

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
