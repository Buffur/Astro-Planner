import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:provider/provider.dart';

import 'core/diagnostics/app_log.dart';
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
import 'data/repositories/shared_prefs_privacy_preferences_repository.dart';
import 'data/repositories/shared_prefs_weather_snapshot_store.dart';
import 'data/services/flutter_timezone_device_time_zone.dart';
import 'data/services/geolocator_location_service.dart';
import 'data/services/nominatim_reverse_geocoder.dart';
import 'data/services/wakelock_screen_wake.dart';
import 'data/export/share_session_exporter.dart';
import 'data/backup/backup_staging.dart';
import 'data/backup/file_backup_service.dart';

import 'package:path_provider/path_provider.dart';

import 'domain/services/night_weather_service.dart';
import 'presentation/viewmodels/theme_viewmodel.dart';
import 'presentation/screens/startup/unsupported_database_screen.dart';
import 'presentation/widgets/night_clock.dart';
import 'core/config/app_identity.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // TASK 8.2: the target catalog's CC BY-SA 4.0 notice in the licence page.
  LicenseRegistry.addLicense(() async* {
    yield LicenseEntryWithLineBreaks(const [
      'OpenNGC (target catalog)',
    ], await rootBundle.loadString('assets/catalog/OPENNGC_NOTICE.txt'));
  });
  await _start();
}

/// Opens the database and starts the app; run again after the recovery
/// screen resets a refused database (S1.5).
Future<void> _start() async {
  // TASK 14.4: a restore confirmed last time replaces the database before
  // it opens (the replaced file is kept as a safety copy).
  try {
    await BackupStaging.apply(
      await getApplicationDocumentsDirectory(),
      nowUtc: DateTime.now().toUtc(),
    );
  } catch (e, s) {
    AppLog.error(
      'backup',
      'Staged restore could not be applied',
      error: e,
      stackTrace: s,
    );
  }
  final database = AppDatabase();

  // A database this build cannot open gets the recovery screen instead of
  // the app, before anything else reads it (ADR-008 §2, S1.5). Other open
  // errors fall through to the bootstrap error state below.
  UnsupportedSchemaVersionException? refused;
  try {
    refused = await refusedSchemaVersion(database);
  } catch (e, s) {
    AppLog.error('startup', 'Database did not open', error: e, stackTrace: s);
  }
  if (refused case final refused?) {
    AppLog.error('startup', 'Database refused', error: refused);
    runApp(
      UnsupportedDatabaseApp(
        newerThanApp: refused.isNewerThanApp,
        foundVersion: refused.foundVersion,
        onReset: () async {
          await resetRefusedDatabase(database, await databaseFile(), refused);
          await _start();
        },
      ),
    );
    return;
  }

  final targetRepo = DriftTargetRepository(database);
  final equipmentRepo = DriftEquipmentRepository(database);
  final weatherRepo = OpenMeteoWeatherRepository();
  final sessionRepo = DriftSessionRepository(database);
  final locationRepo = DriftLocationRepository(database);

  final targetSeeder = CatalogSeeder(targetRepo);
  final equipmentSeeder = EquipmentSeeder(equipmentRepo);

  // Seeding must finish before the ViewModel's first read, or a fresh
  // install sees an empty catalog until the app restarts (TD-002). Seeding
  // is idempotent (seedIfNeeded checks for existing rows first), and a
  // catalog seed with failed inserts is not recorded as applied (S1.2), so
  // a failure here is retried on the next launch.
  try {
    await targetSeeder.seedIfNeeded();
    await equipmentSeeder.seedIfNeeded();
  } catch (e, s) {
    AppLog.error('seeding', 'Seeding failed', error: e, stackTrace: s);
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
    privacy: SharedPrefsPrivacyPreferencesRepository(),
    screenWake: WakelockScreenWake(),
    exporter: ShareSessionExporter(),
    backup: FileBackupService(database, sessionRepo),
    sessions: sessionRepo,
  );
  // Field mode is restored before the first frame, so a restart in field
  // mode never flashes the normal theme (TASK 12.4).
  await vms.theme.load();
  await vms.tonight.load();
  try {
    await vms.backup?.load();
    await vms.resumeRun?.load(); // a run left in progress (ADR-016 §5)
    await vms.execution?.loadActive();
  } catch (e, s) {
    // TASK 15.1: the app still starts; its bootstrap shows the failure
    // with a retry instead of a blank screen.
    AppLog.error('startup', 'Could not restore state', error: e, stackTrace: s);
  }

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
      title: AppIdentity.appName,
      theme: themeVM.isFieldMode ? AppTheme.fieldTheme : AppTheme.light,
      darkTheme: themeVM.isFieldMode ? AppTheme.fieldTheme : AppTheme.dark,
      themeMode: ThemeMode.system,
      routerConfig: AppRouter.router,
      // Field mode: every pixel below the app root, dialogs and snackbars
      // included, goes through the red filter (owner decision, TASK 12.4).
      builder: (context, child) {
        final content = KeyedSubtree(
          key: _content,
          child: NightClock(child: child!),
        );
        return themeVM.isFieldMode
            ? ColorFiltered(colorFilter: AppTheme.fieldFilter, child: content)
            : content;
      },
      debugShowCheckedModeBanner: false,
    );
  }
}
