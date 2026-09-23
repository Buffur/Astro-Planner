import 'package:flutter/foundation.dart';

import '../../core/time/clock.dart';
import '../../data/repositories/open_meteo_weather_repository.dart';
import '../../data/repositories/shared_prefs_planner_state_repository.dart';
import '../../data/repositories/shared_prefs_planning_preferences_repository.dart';
import '../../data/repositories/shared_prefs_weather_snapshot_store.dart';
import '../../data/services/flutter_timezone_device_time_zone.dart';
import '../../data/services/geolocator_location_service.dart';
import '../../data/services/nominatim_reverse_geocoder.dart';
import '../../domain/models/astro_target.dart';
import '../../domain/models/calendar_date.dart';
import '../../domain/models/capture_block.dart';
import '../../domain/models/equipment_profile.dart';
import '../../domain/models/imaging_opportunity.dart';
import '../../domain/models/location_profile.dart';
import '../../domain/models/moon_conditions.dart';
import '../../domain/models/night_timeline.dart';
import '../../domain/models/night_weather.dart';
import '../../domain/models/night_weather_summary.dart';
import '../../domain/models/planning_preferences.dart';
import '../../domain/models/session.dart';
import '../../domain/models/session_night.dart';
import '../../domain/models/sky_darkness.dart';
import '../../domain/models/visibility_window.dart';
import '../../domain/repositories/equipment_repository.dart';
import '../../domain/repositories/location_repository.dart';
import '../../domain/repositories/planner_state_repository.dart';
import '../../domain/repositories/planning_preferences_repository.dart';
import '../../domain/repositories/session_repository.dart';
import '../../domain/repositories/target_repository.dart';
import '../../domain/repositories/weather_repository.dart';
import '../../domain/services/candidate_evaluator.dart';
import '../../domain/services/capability_calculator.dart';
import '../../domain/services/capture_budget_calculator.dart';
import '../../domain/services/device_time_zone.dart';
import '../../domain/services/fit_analyzer.dart';
import '../../domain/services/location_service.dart';
import '../../domain/services/night_weather_service.dart';
import '../../domain/services/reverse_geocoder.dart';
import 'capture_analysis_viewmodel.dart';
import 'night_conditions_viewmodel.dart';
import 'session_plan_viewmodel.dart';
import 'settings_viewmodel.dart';
import 'site_viewmodel.dart';
import 'startup_viewmodel.dart';

/// **Transitional facade (TASK 12.3).** The planner's state now lives in
/// [SiteViewModel], [SettingsViewModel], [SessionPlanViewModel],
/// [NightConditionsViewModel], [CaptureAnalysisViewModel] and
/// [StartupViewModel]; this class only builds them and delegates, so
/// screens and tests can move to them one at a time. It is removed when
/// nothing uses it.
class PlannerViewModel extends ChangeNotifier {
  PlannerViewModel(
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
  }) {
    final time = clock ?? const SystemClock();
    final state = stateRepository ?? SharedPrefsPlannerStateRepository();
    site = SiteViewModel(
      locationRepository: locationRepository,
      stateRepository: state,
      locationService: locationService ?? GeolocatorLocationService(),
      reverseGeocoder: reverseGeocoder ?? NominatimReverseGeocoder(),
      deviceTimeZone: deviceTimeZone ?? FlutterTimezoneDeviceTimeZone(),
      clock: time,
    );
    settings = SettingsViewModel(
      preferencesRepository ?? SharedPrefsPlanningPreferencesRepository(),
    );
    plan = SessionPlanViewModel(
      site: site,
      targetRepository: targetRepository,
      equipmentRepository: equipmentRepository,
      stateRepository: state,
      clock: time,
      sessionRepository: sessionRepository,
    );
    conditions = NightConditionsViewModel(
      site: site,
      plan: plan,
      settings: settings,
      weatherService:
          nightWeatherService ??
          NightWeatherService(
            repository: weatherRepository,
            store: SharedPrefsWeatherSnapshotStore(),
            clock: time,
            model: OpenMeteoWeatherRepository.model,
          ),
      targetRepository: targetRepository,
      clock: time,
    );
    analysis = CaptureAnalysisViewModel(
      site: site,
      plan: plan,
      settings: settings,
      conditions: conditions,
      clock: time,
    );
    startup = StartupViewModel(
      site: site,
      settings: settings,
      plan: plan,
      conditions: conditions,
    );
    for (final vm in [site, settings, plan, conditions, analysis, startup]) {
      vm.addListener(notifyListeners);
    }
  }

  late final SiteViewModel site;
  late final SettingsViewModel settings;
  late final SessionPlanViewModel plan;
  late final NightConditionsViewModel conditions;
  late final CaptureAnalysisViewModel analysis;
  late final StartupViewModel startup;

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
  Future<void> openSession(Session s) => plan.openSession(s);
  Future<void> newSession() => plan.newSession();
  Future<void> duplicateForNight(CalendarDate d) => plan.duplicateForNight(d);

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
  String get totalIntegrationTime => analysis.totalIntegrationTime;
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
