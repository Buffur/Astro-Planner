import 'package:go_router/go_router.dart';
import '../screens/home/home_screen.dart';
import '../screens/equipment/equipment_selection_screen.dart';
import '../screens/target/target_selection_screen.dart';
import '../screens/metadata/metadata_import_screen.dart';

class AppRouter {
  static final router = GoRouter(
    initialLocation: '/',
    routes: [
      GoRoute(
        path: '/',
        builder: (context, state) => const HomeScreen(),
      ),
      GoRoute(
        path: '/equipment',
        builder: (context, state) => const EquipmentSelectionScreen(),
      ),
      GoRoute(
        path: '/target',
        builder: (context, state) => const TargetSelectionScreen(),
      ),
      GoRoute(
        path: '/metadata',
        builder: (context, state) => const MetadataImportScreen(),
      ),
    ],
  );
}
