import 'package:provider/provider.dart';
import 'package:provider/single_child_widget.dart';

import '../core/time/clock.dart';
import '../domain/repositories/display_preferences_repository.dart';
import '../domain/repositories/equipment_repository.dart';
import '../domain/repositories/location_repository.dart';
import '../domain/repositories/planner_state_repository.dart';
import '../domain/repositories/planning_preferences_repository.dart';
import '../domain/repositories/session_repository.dart';
import '../domain/repositories/target_repository.dart';
import '../domain/services/device_time_zone.dart';
import '../domain/services/location_service.dart';
import '../domain/services/night_weather_service.dart';
import '../domain/services/reverse_geocoder.dart';
import 'viewmodels/capture_analysis_viewmodel.dart';
import 'viewmodels/library_viewmodels.dart';
import 'viewmodels/night_conditions_viewmodel.dart';
import 'viewmodels/session_plan_viewmodel.dart';
import 'viewmodels/settings_viewmodel.dart';
import 'viewmodels/site_viewmodel.dart';
import 'viewmodels/startup_viewmodel.dart';
import 'viewmodels/theme_viewmodel.dart';

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
    SessionRepository? sessions,
  }) {
    site = SiteViewModel(
      locationRepository: locations,
      stateRepository: plannerState,
      locationService: locationService,
      reverseGeocoder: reverseGeocoder,
      deviceTimeZone: deviceTimeZone,
      clock: clock,
    );
    settings = SettingsViewModel(preferences);
    plan = SessionPlanViewModel(
      site: site,
      targetRepository: targets,
      equipmentRepository: equipment,
      stateRepository: plannerState,
      clock: clock,
      sessionRepository: sessions,
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
      settings: settings,
      conditions: conditions,
      clock: clock,
    );
    startup = StartupViewModel(
      site: site,
      settings: settings,
      plan: plan,
      conditions: conditions,
    );
    gear = GearViewModel(equipment);
    targetList = TargetsViewModel(targets);
    sessionList = sessions == null ? null : SessionsViewModel(sessions);
    theme = ThemeViewModel(display);
  }

  late final SiteViewModel site;
  late final SettingsViewModel settings;
  late final SessionPlanViewModel plan;
  late final NightConditionsViewModel conditions;
  late final CaptureAnalysisViewModel analysis;
  late final StartupViewModel startup;
  late final GearViewModel gear;
  late final TargetsViewModel targetList;
  late final SessionsViewModel? sessionList;
  late final ThemeViewModel theme;

  /// One provider per ViewModel, for the widget tree.
  List<SingleChildWidget> get providers => [
    ChangeNotifierProvider.value(value: site),
    ChangeNotifierProvider.value(value: settings),
    ChangeNotifierProvider.value(value: plan),
    ChangeNotifierProvider.value(value: conditions),
    ChangeNotifierProvider.value(value: analysis),
    ChangeNotifierProvider.value(value: startup),
    ChangeNotifierProvider.value(value: gear),
    ChangeNotifierProvider.value(value: targetList),
    if (sessionList case final s?) ChangeNotifierProvider.value(value: s),
    ChangeNotifierProvider.value(value: theme),
  ];
}
