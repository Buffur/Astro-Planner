import 'package:flutter/foundation.dart';

import 'package:astroplan/domain/metadata/capture_file_access.dart';
import 'package:astroplan/core/time/clock.dart';
import 'package:astroplan/data/repositories/open_meteo_weather_repository.dart';
import 'package:astroplan/data/repositories/shared_prefs_planner_state_repository.dart';
import 'package:astroplan/data/repositories/shared_prefs_planning_preferences_repository.dart';
import 'package:astroplan/data/repositories/shared_prefs_weather_snapshot_store.dart';
import 'package:astroplan/data/services/flutter_timezone_device_time_zone.dart';
import 'package:astroplan/data/services/geolocator_location_service.dart';
import 'package:astroplan/data/services/nominatim_reverse_geocoder.dart';
import 'package:astroplan/domain/models/astro_target.dart';
import 'package:astroplan/domain/models/calendar_date.dart';
import 'package:astroplan/domain/models/capture_block.dart';
import 'package:astroplan/domain/models/equipment_profile.dart';
import 'package:astroplan/domain/models/imaging_opportunity.dart';
import 'package:astroplan/domain/models/location_profile.dart';
import 'package:astroplan/domain/models/moon_conditions.dart';
import 'package:astroplan/domain/models/night_timeline.dart';
import 'package:astroplan/domain/models/night_weather.dart';
import 'package:astroplan/domain/models/night_weather_summary.dart';
import 'package:astroplan/domain/models/planning_preferences.dart';
import 'package:astroplan/domain/models/session.dart';
import 'package:astroplan/domain/models/session_night.dart';
import 'package:astroplan/domain/models/sky_darkness.dart';
import 'package:astroplan/domain/models/visibility_window.dart';
import 'package:astroplan/domain/repositories/equipment_repository.dart';
import 'package:astroplan/domain/repositories/location_repository.dart';
import 'package:astroplan/domain/repositories/planner_state_repository.dart';
import 'package:astroplan/domain/repositories/planning_preferences_repository.dart';
import 'package:astroplan/domain/repositories/session_repository.dart';
import 'package:astroplan/domain/repositories/target_repository.dart';
import 'package:astroplan/domain/repositories/weather_repository.dart';
import 'package:astroplan/domain/services/candidate_evaluator.dart';
import 'package:astroplan/domain/services/capability_calculator.dart';
import 'package:astroplan/domain/services/capture_budget_calculator.dart';
import 'package:astroplan/domain/services/device_time_zone.dart';
import 'package:astroplan/domain/services/fit_analyzer.dart';
import 'package:astroplan/domain/services/location_service.dart';
import 'package:astroplan/domain/services/night_weather_service.dart';
import 'package:astroplan/domain/services/reverse_geocoder.dart';
import 'package:astroplan/domain/repositories/display_preferences_repository.dart';
import 'package:astroplan/domain/repositories/first_run_repository.dart';
import 'package:astroplan/domain/repositories/privacy_preferences_repository.dart';
import 'package:astroplan/presentation/app_view_models.dart';
import 'package:astroplan/presentation/viewmodels/capture_analysis_viewmodel.dart';
import 'package:astroplan/presentation/viewmodels/night_conditions_viewmodel.dart';
import 'package:astroplan/presentation/viewmodels/plan_lifecycle_viewmodel.dart';
import 'package:astroplan/presentation/viewmodels/session_plan_viewmodel.dart';
import 'package:astroplan/presentation/viewmodels/settings_viewmodel.dart';
import 'package:astroplan/presentation/viewmodels/site_viewmodel.dart';
import 'package:astroplan/presentation/viewmodels/startup_viewmodel.dart';
import 'package:astroplan/presentation/viewmodels/disclosure_viewmodel.dart';
import 'package:astroplan/presentation/viewmodels/theme_viewmodel.dart';
import 'package:astroplan/domain/services/screen_wake.dart';
import 'package:astroplan/domain/services/backup_service.dart';
import 'package:astroplan/domain/services/session_exporter.dart';
import 'package:astroplan/presentation/viewmodels/execution_viewmodel.dart';
import 'package:astroplan/presentation/viewmodels/results_viewmodel.dart';
import 'package:astroplan/presentation/viewmodels/resume_run_viewmodel.dart';
import 'package:astroplan/presentation/viewmodels/tonight_viewmodel.dart';
import 'package:provider/single_child_widget.dart';

import 'in_memory_display_preferences.dart';
import 'in_memory_privacy_preferences.dart';
import 'in_memory_first_run.dart';

/// One object over the app's ViewModels, for tests (TASK 12.3). It builds
/// the same [AppViewModels] graph `main.dart` does and delegates to it, so
/// tests exercise the real ViewModels; defaults match the app's. Screens
/// get the ViewModels through [providers].
class PlannerHarness extends ChangeNotifier {
  PlannerHarness(
    TargetRepository targetRepository,
    EquipmentRepository equipmentRepository,
    WeatherRepository weatherRepository,
    LocationRepository locationRepository, {
    LocationService? locationService,
    ReverseGeocoder? reverseGeocoder,
    DeviceTimeZone? deviceTimeZone,
    Clock? clock,
    PlanningPreferencesRepository? preferencesRepository,
    PlannerStateRepository? stateRepository,
    NightWeatherService? nightWeatherService,
    SessionRepository? sessionRepository,
    DisplayPreferencesRepository? displayPreferences,
    FirstRunRepository? firstRun,
    PrivacyPreferencesRepository? privacyPreferences,
    ScreenWake? screenWake,
    SessionExporter? exporter,
    BackupService? backup,
    CaptureFileAccess? captureFiles,
  }) {
    final time = clock ?? const SystemClock();
    vms = AppViewModels(
      targets: targetRepository,
      equipment: equipmentRepository,
      locations: locationRepository,
      preferences:
          preferencesRepository ?? SharedPrefsPlanningPreferencesRepository(),
      plannerState: stateRepository ?? SharedPrefsPlannerStateRepository(),
      weather:
          nightWeatherService ??
          NightWeatherService(
            repository: weatherRepository,
            store: SharedPrefsWeatherSnapshotStore(),
            clock: time,
            model: OpenMeteoWeatherRepository.model,
          ),
      locationService: locationService ?? GeolocatorLocationService(),
      reverseGeocoder: reverseGeocoder ?? NominatimReverseGeocoder(),
      deviceTimeZone: deviceTimeZone ?? FlutterTimezoneDeviceTimeZone(),
      clock: time,
      display: displayPreferences ?? InMemoryDisplayPreferences(),
      firstRun: firstRun ?? InMemoryFirstRun(),
      // Place-name lookups ON in tests (the app's default is off, TASK
      // 16.3), so the geocoding tests keep exercising the lookup path.
      privacy:
          privacyPreferences ??
          InMemoryPrivacyPreferences(placeNameLookup: true),
      screenWake: screenWake ?? FakeScreenWake(),
      exporter: exporter,
      backup: backup,
      sessions: sessionRepository,
      captureFiles: captureFiles,
    );
    for (final vm in [site, settings, plan, conditions, analysis, startup]) {
      vm.addListener(notifyListeners);
    }
  }

  late final AppViewModels vms;
  SiteViewModel get site => vms.site;
  SettingsViewModel get settings => vms.settings;
  SessionPlanViewModel get plan => vms.plan;
  PlanLifecycleViewModel get lifecycle => vms.lifecycle;
  NightConditionsViewModel get conditions => vms.conditions;
  CaptureAnalysisViewModel get analysis => vms.analysis;
  StartupViewModel get startup => vms.startup;
  ThemeViewModel get theme => vms.theme;
  DisclosureViewModel get disclosure => vms.disclosure;
  TonightViewModel get tonight => vms.tonight;
  ResumeRunViewModel? get resumeRun => vms.resumeRun;
  ExecutionViewModel? get execution => vms.execution;
  ResultsViewModel? get results => vms.results;

  /// The ViewModels' providers, for a widget tree under test.
  List<SingleChildWidget> get providers => vms.providers;

  // Startup
  Future<void> get ready => startup.ready;
  bool get isLoading => startup.isLoading;
  bool get hasBootstrapError => startup.hasBootstrapError;
  Future<void> retryBootstrap() => startup.retryBootstrap();

  // Site
  bool get isDefaultLocation => site.isDefaultLocation;
  double get latitude => site.latitude;
  double get longitude => site.longitude;
  LocationProfile? get activeSite => site.activeSite;
  List<LocationProfile> get sites => site.sites;
  int? get bortleClass => site.bortleClass;
  String? get locationName => site.locationName;
  String? get locationNameAttribution => site.locationNameAttribution;
  SkyDarkness get skyDarkness => site.skyDarkness;
  String? get displayZoneId => site.displayZoneId;
  CalendarDate get today => site.today;
  Future<String?> deviceZoneId() => site.deviceZoneId();
  Future<void> selectSite(int id) async {
    await site.selectSite(id);
    await _settle();
  }

  Future<int> saveSite(LocationProfile s) async {
    final id = await site.saveSite(s);
    await _settle();
    return id;
  }

  Future<void> deleteSite(int id) => site.deleteSite(id);
  Future<void> setLocation(double lat, double lon) async {
    await site.setLocation(lat, lon);
    await _settle();
  }

  Future<void> setBortleClass(int? bortle) => site.setBortleClass(bortle);
  Future<LocationResult> locateDevice() => site.locateDevice();
  Future<LocationResult> useCurrentLocation() async {
    final result = await site.useCurrentLocation();
    await _settle();
    return result;
  }

  Future<bool> openLocationSettings() => site.openLocationSettings();
  Future<bool> openAppSettings() => site.openAppSettings();

  /// A site change autosaves and reloads the forecast through listeners;
  /// callers of the old API awaited both.
  Future<void> _settle() async {
    await plan.idle;
    await conditions.idle;
  }

  // Settings
  PlanningPreferences get planningPreferences => settings.planningPreferences;
  Future<void> setPlanningPreferences(PlanningPreferences p) =>
      settings.setPlanningPreferences(p);
  double get minAltitude => settings.minAltitude;
  Future<void> setMinAltitude(double v) => settings.setMinAltitude(v);
  double get dewPointThreshold => settings.dewPointThreshold;
  Future<void> setDewPointThreshold(double v) =>
      settings.setDewPointThreshold(v);

  // Session plan
  AstroTarget? get selectedTarget => plan.selectedTarget;
  EquipmentProfile? get selectedEquipment => plan.selectedEquipment;
  List<CaptureBlock> get captureBlocks => plan.captureBlocks;
  bool get isExampleCapturePlan => plan.isExampleCapturePlan;
  Session? get activeSession => plan.activeSession;
  int? get activeSessionId => plan.activeSessionId;
  SessionNight? get sessionNight => plan.sessionNight;
  CalendarDate? get eveningDate => plan.eveningDate;
  Future<void> setEveningDate(CalendarDate d) => plan.setEveningDate(d);
  Future<void> setTarget(AstroTarget t) => plan.setTarget(t);
  Future<void> setEquipment(EquipmentProfile e) => plan.setEquipment(e);
  Future<void> addCaptureBlock(CaptureBlock b) => plan.addCaptureBlock(b);
  Future<void> updateCaptureBlock(int i, CaptureBlock b) =>
      plan.updateCaptureBlock(i, b);
  Future<void> removeCaptureBlock(int i) => plan.removeCaptureBlock(i);
  Future<void> reorderCaptureBlocks(int from, int to) =>
      plan.reorderCaptureBlocks(from, to);
  Future<void> refreshSelectedTarget() => plan.refreshSelectedTarget();
  Future<void> refreshSelectedEquipment() => plan.refreshSelectedEquipment();
  Future<void> openSession(Session s) => lifecycle.openSession(s);
  Future<void> newSession() => lifecycle.newSession();
  Future<void> duplicateForNight(CalendarDate d) =>
      lifecycle.duplicateForNight(d);

  // Night conditions
  NightWeather get nightWeather => conditions.nightWeather;
  Future<void> refreshWeather() => conditions.refreshWeather();
  NightTimeline? get nightTimeline => conditions.nightTimeline;
  NightWeatherSummary? get nightWeatherSummary =>
      conditions.nightWeatherSummary;
  MoonConditions? get moonConditions => conditions.moonConditions;
  double? get lunarIllumination => conditions.lunarIllumination;
  ImagingOpportunity? get imagingOpportunity => conditions.imagingOpportunity;
  List<VisibilityWindow> get visibilityWindows => conditions.visibilityWindows;
  Future<List<TonightCandidate>?> tonightCandidates() =>
      conditions.tonightCandidates();
  double? get currentAltitude => conditions.currentAltitude;
  DateTime get nowUtc => conditions.nowUtc;

  // Capture analysis
  CaptureBudget get captureBudget => analysis.captureBudget;
  Duration get estimatedRequiredTime => analysis.estimatedRequiredTime;
  FitResult get fitAnalysis => analysis.fitAnalysis;
  int? get fillWindowBlockIndex => analysis.fillWindowBlockIndex;
  int? get fillWindowFrameCount => analysis.fillWindowFrameCount;
  Future<bool> fillWindow() => analysis.fillWindow();
  double? get estimatedStorageMB => analysis.estimatedStorageMB;
  double get relativeStackingGain => analysis.relativeStackingGain;
  double? get pixelScale => analysis.pixelScale;
  RigCapability? get rigCapability => analysis.rigCapability;
  Future<Session> saveSession() => analysis.saveSession();
}
