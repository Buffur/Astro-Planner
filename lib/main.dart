import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:provider/provider.dart';

import 'core/theme/app_theme.dart';
import 'presentation/navigation/app_router.dart';
import 'core/time/clock.dart';
import 'presentation/app_view_models.dart';
import 'data/database/app_database.dart';
import 'data/repositories/drift_target_repository.dart';
import 'domain/repositories/target_repository.dart';
import 'data/services/catalog_seeder.dart';
import 'data/repositories/drift_equipment_repository.dart';
import 'domain/repositories/equipment_repository.dart';
import 'data/services/equipment_seeder.dart';
import 'data/repositories/open_meteo_weather_repository.dart';
import 'domain/repositories/weather_repository.dart';
import 'data/repositories/drift_session_repository.dart';
import 'domain/repositories/session_repository.dart';
import 'data/repositories/drift_location_repository.dart';
import 'domain/repositories/location_repository.dart';
import 'data/repositories/shared_prefs_display_preferences_repository.dart';
import 'data/repositories/shared_prefs_first_run_repository.dart';
import 'data/repositories/shared_prefs_planner_state_repository.dart';
import 'data/repositories/shared_prefs_planning_preferences_repository.dart';
import 'data/repositories/shared_prefs_weather_snapshot_store.dart';
import 'data/services/flutter_timezone_device_time_zone.dart';
import 'data/services/geolocator_location_service.dart';
import 'data/services/nominatim_reverse_geocoder.dart';
import 'data/services/wakelock_screen_wake.dart';
import 'domain/services/night_weather_service.dart';
import 'presentation/viewmodels/theme_viewmodel.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // TASK 8.2: the target catalog's CC BY-SA 4.0 notice in the licence page.
  LicenseRegistry.addLicense(() async* {
    yield LicenseEntryWithLineBreaks(const [
      'OpenNGC (target catalog)',
    ], await rootBundle.loadString('assets/catalog/OPENNGC_NOTICE.txt'));
  });
  final database = AppDatabase();
  final targetRepo = DriftTargetRepository(database);
  final equipmentRepo = DriftEquipmentRepository(database);
  final weatherRepo = OpenMeteoWeatherRepository();
  final sessionRepo = DriftSessionRepository(database);
  final locationRepo = DriftLocationRepository(database);

  final targetSeeder = CatalogSeeder(targetRepo);
  final equipmentSeeder = EquipmentSeeder(equipmentRepo);

  // Seeding must finish before the ViewModel's first read, or a fresh
  // install sees an empty catalog until the app restarts (TD-002). Seeding
  // is idempotent (seedIfNeeded checks for existing rows first), so a
  // failure here is safe to retry on the next launch.
  try {
    await targetSeeder.seedIfNeeded();
    await equipmentSeeder.seedIfNeeded();
  } catch (e) {
    debugPrint('Seeding error: $e');
  }

  // The only place that picks implementations (TASK 12.3): ViewModels see
  // domain interfaces only.
  const clock = SystemClock();
  final vms = AppViewModels(
    targets: targetRepo,
    equipment: equipmentRepo,
    locations: locationRepo,
    preferences: SharedPrefsPlanningPreferencesRepository(),
    plannerState: SharedPrefsPlannerStateRepository(),
    weather: NightWeatherService(
      repository: weatherRepo,
      store: SharedPrefsWeatherSnapshotStore(),
      clock: clock,
      model: OpenMeteoWeatherRepository.model,
    ),
    locationService: GeolocatorLocationService(),
    reverseGeocoder: NominatimReverseGeocoder(),
    deviceTimeZone: FlutterTimezoneDeviceTimeZone(),
    clock: clock,
    display: SharedPrefsDisplayPreferencesRepository(),
    firstRun: SharedPrefsFirstRunRepository(),
    screenWake: WakelockScreenWake(),
    sessions: sessionRepo,
  );
  // Field mode is restored before the first frame, so a restart in field
  // mode never flashes the normal theme (TASK 12.4).
  await vms.theme.load();
  await vms.tonight.load();
  await vms.resumeRun?.load(); // a run left in progress (ADR-016 §5)
  await vms.execution?.loadActive();

  runApp(
    MultiProvider(
      providers: [
        Provider<AppDatabase>.value(value: database),
        Provider<TargetRepository>.value(value: targetRepo),
        Provider<EquipmentRepository>.value(value: equipmentRepo),
        Provider<WeatherRepository>.value(value: weatherRepo),
        Provider<SessionRepository>.value(value: sessionRepo),
        Provider<LocationRepository>.value(value: locationRepo),
        ...vms.providers,
      ],
      child: const AstroPlanApp(),
    ),
  );
}

class AstroPlanApp extends StatelessWidget {
  const AstroPlanApp({super.key});

  /// Keeps the app's state when the field filter is added or removed.
  static final _content = GlobalKey(debugLabel: 'app content');

  @override
  Widget build(BuildContext context) {
    final themeVM = context.watch<ThemeViewModel>();

    return MaterialApp.router(
      title: 'AstroPlan',
      theme: themeVM.isFieldMode ? AppTheme.fieldTheme : AppTheme.light,
      darkTheme: themeVM.isFieldMode ? AppTheme.fieldTheme : AppTheme.dark,
      themeMode: ThemeMode.system,
      routerConfig: AppRouter.router,
      // Field mode: every pixel below the app root, dialogs and snackbars
      // included, goes through the red filter (owner decision, TASK 12.4).
      builder: (context, child) {
        final content = KeyedSubtree(key: _content, child: child!);
        return themeVM.isFieldMode
            ? ColorFiltered(colorFilter: AppTheme.fieldFilter, child: content)
            : content;
      },
      debugShowCheckedModeBanner: false,
    );
  }
}
