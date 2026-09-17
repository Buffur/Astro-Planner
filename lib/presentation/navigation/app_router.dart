import 'package:go_router/go_router.dart';
import '../screens/home/home_screen.dart';
import '../screens/target/target_selection_screen.dart';
import '../screens/equipment/equipment_selection_screen.dart';
import '../screens/metadata/metadata_import_screen.dart';
import '../screens/logbook/logbook_screen.dart';

class AppRouter {
  static final router = GoRouter(
    initialLocation: '/',
    routes: [
      GoRoute(
        path: '/',
        builder: (context, state) => const HomeScreen(),
      ),
      GoRoute(
        path: '/target',
        builder: (context, state) => const TargetSelectionScreen(),
      ),
      GoRoute(
        path: '/equipment',
        builder: (context, state) => const EquipmentSelectionSheet(),
      ),
      GoRoute(
        path: '/metadata',
        builder: (context, state) => const MetadataImportScreen(),
      ),
      GoRoute(
        path: '/logbook',
        builder: (context, state) => const LogbookScreen(),
      ),
    ],
  );
}
