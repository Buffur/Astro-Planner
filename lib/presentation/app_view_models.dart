import 'package:provider/provider.dart';
import 'package:provider/single_child_widget.dart';

import '../core/time/clock.dart';
import '../domain/metadata/capture_file_access.dart';
import '../domain/repositories/display_preferences_repository.dart';
import '../domain/repositories/equipment_repository.dart';
import '../domain/repositories/first_run_repository.dart';
import '../domain/repositories/location_repository.dart';
import '../domain/repositories/planner_state_repository.dart';
import '../domain/repositories/planning_preferences_repository.dart';
import '../domain/repositories/privacy_preferences_repository.dart';
import '../domain/repositories/session_repository.dart';
import '../domain/repositories/target_repository.dart';
import '../domain/services/device_time_zone.dart';
import '../domain/services/location_service.dart';
import '../domain/services/night_weather_service.dart';
import '../domain/services/opt_in_reverse_geocoder.dart';
import '../domain/services/reverse_geocoder.dart';
import '../domain/services/backup_service.dart';
import '../domain/services/current_session.dart';
import '../domain/services/screen_wake.dart';
import '../domain/services/session_exporter.dart';
import 'viewmodels/backup_viewmodel.dart';
import 'viewmodels/capture_analysis_viewmodel.dart';
import 'viewmodels/execution_viewmodel.dart';
import 'viewmodels/library_viewmodels.dart';
import 'viewmodels/metadata_import_viewmodel.dart';
import 'viewmodels/night_conditions_viewmodel.dart';
import 'viewmodels/plan_lifecycle_viewmodel.dart';
import 'viewmodels/session_plan_viewmodel.dart';
import 'viewmodels/settings_viewmodel.dart';
import 'viewmodels/site_viewmodel.dart';
import 'viewmodels/startup_viewmodel.dart';
import 'viewmodels/disclosure_viewmodel.dart';
import 'viewmodels/theme_viewmodel.dart';
import 'viewmodels/results_viewmodel.dart';
import 'viewmodels/resume_run_viewmodel.dart';
import 'viewmodels/tonight_viewmodel.dart';

/// The app's screen-scoped ViewModels and how they depend on each other
/// (TASK 12.3). Takes interfaces only: `main.dart` passes the real
/// implementations, tests pass fakes or in-memory ones. Building this
/// starts the app's load ([StartupViewModel.ready]).
class AppViewModels {
  AppViewModels({
    required TargetRepository targets,
    required EquipmentRepository equipment,
    required LocationRepository locations,
    required PlanningPreferencesRepository preferences,
    required PlannerStateRepository plannerState,
    required NightWeatherService weather,
    required LocationService locationService,
    required ReverseGeocoder reverseGeocoder,
    required DeviceTimeZone deviceTimeZone,
    required Clock clock,
    required DisplayPreferencesRepository display,
    required FirstRunRepository firstRun,
    required ScreenWake screenWake,
    required PrivacyPreferencesRepository privacy,
    SessionExporter? exporter,
    BackupService? backup,
    SessionRepository? sessions,
    CaptureFileAccess? captureFiles,
  }) {
    // TASK 16.3: place names only when the user switches them on.
    final placeNames = OptInReverseGeocoder(reverseGeocoder);
    site = SiteViewModel(
      locationRepository: locations,
      stateRepository: plannerState,
      locationService: locationService,
      reverseGeocoder: placeNames,
      deviceTimeZone: deviceTimeZone,
      clock: clock,
    );
    settings = SettingsViewModel(preferences, privacy, placeNames)
      ..onPlaceNameLookupChanged = site.refreshPlaceName;
    // One current session for the plan's edits and its lifecycle (S6.1).
    final current = sessions == null
        ? null
        : CurrentSession(sessions, plannerState);
    plan = SessionPlanViewModel(
      site: site,
      targetRepository: targets,
      equipmentRepository: equipment,
      stateRepository: plannerState,
      clock: clock,
      currentSession: current,
    );
    lifecycle = PlanLifecycleViewModel(
      plan: plan,
      site: site,
      targetRepository: targets,
      equipmentRepository: equipment,
      stateRepository: plannerState,
      currentSession: current,
    );
    conditions = NightConditionsViewModel(
      site: site,
      plan: plan,
      settings: settings,
      weatherService: weather,
      targetRepository: targets,
      clock: clock,
    );
    analysis = CaptureAnalysisViewModel(
      site: site,
      plan: plan,
      lifecycle: lifecycle,
      settings: settings,
      conditions: conditions,
      clock: clock,
    );
    startup = StartupViewModel(
      site: site,
      settings: settings,
      lifecycle: lifecycle,
      conditions: conditions,
    );
    gear = GearViewModel(equipment);
    targetList = TargetsViewModel(targets);
    sessionList = sessions == null
        ? null
        : SessionsViewModel(sessions, exporter: exporter);
    resumeRun = sessions == null ? null : ResumeRunViewModel(sessions, clock);
    this.backup = backup == null ? null : BackupViewModel(backup);
    execution = sessions == null
        ? null
        : ExecutionViewModel(sessions, clock, display, screenWake);
    results = sessions == null ? null : ResultsViewModel(sessions);
    theme = ThemeViewModel(display);
    disclosure = DisclosureViewModel(display);
    metadataImport = captureFiles == null
        ? null
        : MetadataImportViewModel(captureFiles, equipment);
    tonight = TonightViewModel(
      site: site,
      startup: startup,
      firstRun: firstRun,
    );
  }

  late final SiteViewModel site;
  late final SettingsViewModel settings;
  late final SessionPlanViewModel plan;

  /// Which plan the planner works on: restore, open, new, copy, save,
  /// start (S6.1).
  late final PlanLifecycleViewModel lifecycle;
  late final NightConditionsViewModel conditions;
  late final CaptureAnalysisViewModel analysis;
  late final StartupViewModel startup;
  late final GearViewModel gear;
  late final TargetsViewModel targetList;
  late final SessionsViewModel? sessionList;

  /// Null without a session repository (some tests).
  late final ResumeRunViewModel? resumeRun;

  /// Null when no backup service is given (tests).
  late final BackupViewModel? backup;
  late final ExecutionViewModel? execution;
  late final ResultsViewModel? results;
  late final ThemeViewModel theme;

  /// Collapsible sections' remembered states (S5.5).
  late final DisclosureViewModel disclosure;

  /// Null where capture files cannot be opened (off Android; tests), S2.5.
  late final MetadataImportViewModel? metadataImport;
  late final TonightViewModel tonight;

  /// One provider per ViewModel, for the widget tree.
  List<SingleChildWidget> get providers => [
    ChangeNotifierProvider.value(value: site),
    ChangeNotifierProvider.value(value: settings),
    ChangeNotifierProvider.value(value: plan),
    Provider.value(value: lifecycle),
    ChangeNotifierProvider.value(value: conditions),
    ChangeNotifierProvider.value(value: analysis),
    ChangeNotifierProvider.value(value: startup),
    ChangeNotifierProvider.value(value: gear),
    ChangeNotifierProvider.value(value: targetList),
    if (sessionList case final s?) ChangeNotifierProvider.value(value: s),
    ChangeNotifierProvider.value(value: theme),
    ChangeNotifierProvider.value(value: disclosure),
    ChangeNotifierProvider.value(value: tonight),
    ChangeNotifierProvider<ResumeRunViewModel?>.value(value: resumeRun),
    ChangeNotifierProvider<BackupViewModel?>.value(value: backup),
    ChangeNotifierProvider<ExecutionViewModel?>.value(value: execution),
    ChangeNotifierProvider<ResultsViewModel?>.value(value: results),
    ChangeNotifierProvider<MetadataImportViewModel?>.value(
      value: metadataImport,
    ),
  ];
}
