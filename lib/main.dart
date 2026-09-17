import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'core/theme/app_theme.dart';
import 'presentation/navigation/app_router.dart';
import 'presentation/viewmodels/planner_viewmodel.dart';
import 'data/database/app_database.dart';
import 'data/repositories/drift_target_repository.dart';
import 'domain/repositories/target_repository.dart';
import 'data/services/catalog_seeder.dart';
import 'data/repositories/drift_equipment_repository.dart';
import 'domain/repositories/equipment_repository.dart';
import 'data/services/equipment_seeder.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final database = AppDatabase();
  final targetRepo = DriftTargetRepository(database);
  final equipmentRepo = DriftEquipmentRepository(database);
  
  final targetSeeder = CatalogSeeder(targetRepo);
  await targetSeeder.seedIfNeeded();

  final equipmentSeeder = EquipmentSeeder(equipmentRepo);
  await equipmentSeeder.seedIfNeeded();

  runApp(
    MultiProvider(
      providers: [
        Provider<AppDatabase>.value(value: database),
        Provider<TargetRepository>.value(value: targetRepo),
        Provider<EquipmentRepository>.value(value: equipmentRepo),
        ChangeNotifierProvider(create: (_) => PlannerViewModel(targetRepo, equipmentRepo)),
      ],
      child: const AstroPlanApp(),
    ),
  );
}

class AstroPlanApp extends StatelessWidget {
  const AstroPlanApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'AstroPlan',
      theme: AppTheme.light,
      darkTheme: AppTheme.dark,
      routerConfig: AppRouter.router,
      debugShowCheckedModeBanner: false,
    );
  }
}
