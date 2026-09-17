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
import 'data/repositories/open_meteo_weather_repository.dart';
import 'domain/repositories/weather_repository.dart';
import 'data/repositories/drift_logbook_repository.dart';
import 'domain/repositories/logbook_repository.dart';
import 'presentation/viewmodels/theme_viewmodel.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final database = AppDatabase();
  final targetRepo = DriftTargetRepository(database);
  final equipmentRepo = DriftEquipmentRepository(database);
  final weatherRepo = OpenMeteoWeatherRepository();
  final logbookRepo = DriftLogbookRepository(database);
  
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
        Provider<WeatherRepository>.value(value: weatherRepo),
        Provider<LogbookRepository>.value(value: logbookRepo),
        ChangeNotifierProvider(create: (_) => PlannerViewModel(targetRepo, equipmentRepo, weatherRepo)),
        ChangeNotifierProvider(create: (_) => ThemeViewModel()),
      ],
      child: const AstroPlanApp(),
    ),
  );
}

class AstroPlanApp extends StatelessWidget {
  const AstroPlanApp({super.key});

  @override
  Widget build(BuildContext context) {
    final themeVM = context.watch<ThemeViewModel>();
    
    return MaterialApp.router(
      title: 'AstroPlan',
      theme: themeVM.isFieldMode ? AppTheme.fieldTheme : AppTheme.light,
      darkTheme: themeVM.isFieldMode ? AppTheme.fieldTheme : AppTheme.dark,
      themeMode: ThemeMode.system,
      routerConfig: AppRouter.router,
      debugShowCheckedModeBanner: false,
    );
  }
}
