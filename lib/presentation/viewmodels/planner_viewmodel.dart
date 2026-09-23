import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/scheduler.dart';

import '../../core/time/clock.dart';
import '../../domain/models/astro_target.dart';
import '../../domain/models/calendar_date.dart';
import '../../domain/models/equipment_profile.dart';
import '../../domain/models/capture_block.dart';
import '../../domain/models/night_timeline.dart';
import '../../domain/models/session_night.dart';
import '../../domain/models/site_time_context.dart';
import '../../domain/models/night_weather_summary.dart';
import '../../domain/models/iana_time_context.dart';
import '../../domain/models/location_profile.dart';
import '../../domain/models/sky_darkness.dart';
import '../../domain/models/planning_preferences.dart';
import '../../domain/models/visibility_window.dart';
import '../../domain/repositories/target_repository.dart';
import '../../domain/repositories/equipment_repository.dart';
import '../../domain/repositories/weather_repository.dart';
import '../../domain/repositories/location_repository.dart';
import '../../domain/repositories/planner_state_repository.dart';
import '../../domain/repositories/planning_preferences_repository.dart';
import '../../data/repositories/shared_prefs_planner_state_repository.dart';
import '../../data/repositories/shared_prefs_planning_preferences_repository.dart';
import '../../data/repositories/open_meteo_weather_repository.dart';
import '../../data/repositories/shared_prefs_weather_snapshot_store.dart';
import '../../domain/models/night_weather.dart';
import '../../domain/services/night_weather_service.dart';
import '../../domain/services/night_weather_summarizer.dart';
import '../../domain/models/imaging_opportunity.dart';
import '../../domain/services/imaging_opportunity_calculator.dart';
import '../../data/services/flutter_timezone_device_time_zone.dart';
import '../../data/services/geolocator_location_service.dart';
import '../../data/services/nominatim_reverse_geocoder.dart';
import '../../domain/services/device_time_zone.dart';
import '../../domain/services/location_service.dart';
import '../../domain/services/reverse_geocoder.dart';
import '../../domain/services/session_night_resolver.dart';
import '../../domain/services/visibility_calculator.dart';
import '../../domain/services/optical_calculator.dart';
import '../../domain/services/capability_calculator.dart';
import '../../domain/services/capture_budget_calculator.dart';
import '../../domain/models/moon_conditions.dart';
import '../../domain/services/fit_analyzer.dart';
import '../../domain/services/moon_calculator.dart';
import '../../domain/models/session_log.dart';

class PlannerViewModel extends ChangeNotifier {
  final TargetRepository _targetRepository;
  final EquipmentRepository _equipmentRepository;
  final WeatherRepository _weatherRepository;
  final LocationRepository _locationRepository;
  final LocationService _locationService;
  final ReverseGeocoder _reverseGeocoder;
  final DeviceTimeZone _deviceTimeZone;
  final Clock _clock;
  final PlanningPreferencesRepository _preferencesRepository;
  final PlannerStateRepository _stateRepository;

  /// Completes when the initial state (saved location, capture blocks, target,
  /// equipment, weather) has loaded. It does not wait for the silent
  /// first-launch position lookup or for reverse geocoding.
  late final Future<void> ready;

  bool _isLoading = true;

  /// Set when the initial load (location, capture blocks, target, equipment)
  /// fails. Weather is not part of this — see [nightWeather].
  Object? _bootstrapError;

  /// True until a location is resolved, either from a saved profile or from
  /// the device. While true, [latitude]/[longitude] are the hard-coded
  /// default (London), used silently.
  bool _usingDefaultLocation = true;

  AstroTarget? _selectedTarget;
  EquipmentProfile? _selectedEquipment;

  /// The chosen night's forecast state (ADR-012; TASK 9.3).
  NightWeather _nightWeather = const NightWeatherIdle();
  late final NightWeatherService _nightWeatherService;

  /// Increments with each night-weather request, so a slow answer for a
  /// previous site or night is dropped.
  int _nightWeatherRequest = 0;
  String? _locationName;
  String? _locationNameAttribution;

  /// The evening date the user picked, or null to use the default (the
  /// night containing "now"; ADR-007 §5). Cleared by [newSession].
  CalendarDate? _pickedEveningDate;
  double _latitude = 51.5072;
  double _longitude = -0.1276;

  List<CaptureBlock> _captureBlocks = [];

  /// True while [_captureBlocks] is still the seeded example plan — cleared
  /// as soon as the user saves any capture-block change (TASK 4.4: the
  /// default plan must not look like the user's own plan).
  bool _isExampleCapturePlan = true;

  /// Bortle class of the active site, or null when unknown (SI-007).
  int? _bortleClass;

  /// The active saved site, or null when the position is transient (a map
  /// pick or GPS fix, TASK 7.1) or when there is no position yet.
  LocationProfile? _activeSite;

  /// All saved sites, in insertion order (TASK 7.3).
  List<LocationProfile> _sites = const [];

  SessionLog? _activeSessionLog;
  int? get activeSessionId => _activeSessionLog?.id;
  SessionLog? get activeSessionLog => _activeSessionLog;

  /// Planning thresholds and overhead defaults (TASK 5.2). Defaults,
  /// rationale and valid ranges are documented on [PlanningPreferences].
  PlanningPreferences _preferences = PlanningPreferences();

  PlannerViewModel(
    this._targetRepository,
    this._equipmentRepository,
    this._weatherRepository,
    this._locationRepository, {
    LocationService? locationService,
    ReverseGeocoder? reverseGeocoder,
    DeviceTimeZone? deviceTimeZone,
    Clock? clock,
    PlanningPreferencesRepository? preferencesRepository,
    PlannerStateRepository? stateRepository,
    NightWeatherService? nightWeatherService,
  }) : _locationService = locationService ?? GeolocatorLocationService(),
       _reverseGeocoder = reverseGeocoder ?? NominatimReverseGeocoder(),
       _deviceTimeZone = deviceTimeZone ?? FlutterTimezoneDeviceTimeZone(),
       _clock = clock ?? const SystemClock(),
       _preferencesRepository =
           preferencesRepository ?? SharedPrefsPlanningPreferencesRepository(),
       _stateRepository =
           stateRepository ?? SharedPrefsPlannerStateRepository() {
    _nightWeatherService =
        nightWeatherService ??
        NightWeatherService(
          repository: _weatherRepository,
          store: SharedPrefsWeatherSnapshotStore(),
          clock: _clock,
          model: OpenMeteoWeatherRepository.model,
        );
    ready = _init();
  }

  Future<void> _init() async {
    try {
      await _loadInitialState();
      _bootstrapError = null;
    } catch (e) {
      _bootstrapError = e;
      debugPrint('PlannerViewModel bootstrap error: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }

    if (_bootstrapError == null) {
      // Weather is network-bound and must never hold up the first screen:
      // it loads after the first frame is drawn, not as part of `ready`.
      SchedulerBinding.instance.addPostFrameCallback((_) {
        unawaited(_fetchWeather());
      });
    }
  }

  /// Retries the initial load after a bootstrap failure ([hasBootstrapError]).
  Future<void> retryBootstrap() async {
    _isLoading = true;
    notifyListeners();
    await _init();
  }

  Future<void> _loadInitialState() async {
    final activeLocationId = await _stateRepository.getActiveLocationId();
    if (activeLocationId != null) {
      final loc = await _locationRepository.getLocationById(activeLocationId);
      if (loc != null) {
        _activeSite = loc;
        _latitude = loc.latitude;
        _longitude = loc.longitude;
        _bortleClass = loc.bortleClass;
        _usingDefaultLocation = false;
      }
    } else {
      final transient = await _stateRepository.getTransientPosition();
      if (transient != null) {
        _latitude = transient.latitude;
        _longitude = transient.longitude;
        _usingDefaultLocation = false;
      }
      // Otherwise this is a first run: Home asks for a site. Nothing asks
      // for the location permission until the user chooses to (owner
      // decision, TASK 7.3).
    }
    _sites = await _locationRepository.getLocations();

    try {
      final saved = await _stateRepository.loadCaptureBlocks();
      if (saved != null) {
        _captureBlocks = saved;
        _isExampleCapturePlan = _captureBlocks.isEmpty;
      }
    } catch (e) {
      _captureBlocks = [];
    }
    if (_captureBlocks.isEmpty) {
      _isExampleCapturePlan = true;
      _captureBlocks = [
        CaptureBlock(
          frameType: FrameType.light,
          filterName: 'L',
          exposureTimeSeconds: 60.0,
          frameCount: 100,
        ),
        CaptureBlock(
          frameType: FrameType.dark,
          exposureTimeSeconds: 60.0,
          frameCount: 20,
        ),
        CaptureBlock(
          frameType: FrameType.flat,
          exposureTimeSeconds: 2.0,
          frameCount: 20,
        ),
      ];
    }

    _preferences = await _preferencesRepository.load();

    final targetId = await _stateRepository.getSelectedTargetId();
    if (targetId != null) {
      _selectedTarget = await _targetRepository.getTargetById(targetId);
    }
    if (_selectedTarget == null) {
      final targets = await _targetRepository.searchTargets('M42');
      if (targets.isNotEmpty) _selectedTarget = targets.first;
    }

    final eqId = await _stateRepository.getSelectedEquipmentId();
    if (eqId != null) {
      _selectedEquipment = await _equipmentRepository.getEquipmentById(eqId);
    }
    if (_selectedEquipment == null) {
      final equipment = await _equipmentRepository.getAllEquipment();
      if (equipment.isNotEmpty) _selectedEquipment = equipment.first;
    }

    if (_activeSite == null && !_usingDefaultLocation) {
      unawaited(_reverseGeocode(_latitude, _longitude));
    }
  }

  bool get isLoading => _isLoading;

  /// True when the initial load (location, capture blocks, target,
  /// equipment) failed. Retry with [retryBootstrap].
  bool get hasBootstrapError => _bootstrapError != null;

  /// True until a location is resolved; [latitude]/[longitude] are the
  /// hard-coded default and were not chosen by the user.
  bool get isDefaultLocation => _usingDefaultLocation;

  AstroTarget? get selectedTarget => _selectedTarget;
  EquipmentProfile? get selectedEquipment => _selectedEquipment;

  /// The weather for the chosen night: loading, available (with its age
  /// and whether it came from the cache or a failed refresh), out of range
  /// or unavailable (TASK 9.3). Idle without a site.
  NightWeather get nightWeather => _nightWeather;

  /// Place name of the current position from the [ReverseGeocoder], or null
  /// while unknown (not looked up yet, no name for the point, or the lookup
  /// failed).
  /// An active site shows its own name (TASK 7.3).
  String? get locationName => _activeSite?.name ?? _locationName;

  /// The attribution the place-name source requires wherever [locationName]
  /// is shown (e.g. "© OpenStreetMap contributors"); null with no name.
  String? get locationNameAttribution =>
      _activeSite == null ? _locationNameAttribution : null;

  /// The current [SessionNight], or null when there is no site to resolve
  /// one for (ADR-007 §9: "when no site is set, there is no SessionNight").
  /// Before TASK 7.1 this always resolves through a [MeanSolarTimeContext]
  /// on [_longitude] — the device zone is never used in the computation.
  SessionNight? get sessionNight {
    if (_usingDefaultLocation) return null;
    final timeContext = _timeContext;
    final pickedDate = _pickedEveningDate;
    if (pickedDate != null) {
      return SessionNightResolver.forEveningDate(
        pickedDate,
        latitude: _latitude,
        longitude: _longitude,
        timeContext: timeContext,
      );
    }
    return SessionNightResolver.resolveDefault(
      _clock.nowUtc(),
      latitude: _latitude,
      longitude: _longitude,
      timeContext: timeContext,
    );
  }

  /// The civil evening date of [sessionNight], or null when there is none.
  CalendarDate? get eveningDate => sessionNight?.eveningDate;

  /// Picks a specific evening date, overriding the default (the night
  /// containing "now"). The date alone is stored — it takes effect once a
  /// site is set, even if none is set yet (ADR-007 §2).
  void setEveningDate(CalendarDate date) {
    _pickedEveningDate = date;
    notifyListeners();
    // Another night has its own forecast; a current cached one is reused.
    unawaited(_fetchWeather());
  }

  double get latitude => _latitude;
  double get longitude => _longitude;
  List<CaptureBlock> get captureBlocks => _captureBlocks;

  /// True while the current capture plan is still the seeded example, not a
  /// plan the user has built — the UI must label it accordingly.
  bool get isExampleCapturePlan => _isExampleCapturePlan;

  /// Bortle class of the active site, or null when unknown.
  int? get bortleClass => _bortleClass;

  /// What is known about the sky darkness here (TASK 7.4): the active
  /// site's stored Bortle/SQM with their sources, or, for a transient
  /// position, a Bortle class entered this session (not saved). Never a
  /// fetched or assumed value.
  SkyDarkness get skyDarkness {
    final site = _activeSite;
    if (site != null) return SkyDarkness.fromSite(site);
    final bortle = _bortleClass;
    if (bortle == null) return SkyDarkness.unknown;
    return SkyDarkness(
      bortleClass: bortle,
      bortleSource: 'user',
      isSaved: false,
    );
  }

  /// The active saved site; null when the position is transient.
  LocationProfile? get activeSite => _activeSite;

  /// All saved sites (TASK 7.3).
  List<LocationProfile> get sites => List.unmodifiable(_sites);

  /// Makes the saved site [id] the active one: its coordinates, zone and
  /// sky darkness drive every night time, and the choice persists across
  /// restarts. Does nothing if no such site exists.
  Future<void> selectSite(int id) async {
    final site = await _locationRepository.getLocationById(id);
    if (site == null) return;
    _applySite(site);
    await _stateRepository.setActiveLocationId(site.id);
    notifyListeners();
    await _fetchWeather();
  }

  void _applySite(LocationProfile site) {
    _activeSite = site;
    _latitude = site.latitude;
    _longitude = site.longitude;
    _bortleClass = site.bortleClass;
    _usingDefaultLocation = false;
  }

  /// Saves an explicit user edit of a site (TASK 7.3): `id == 0` inserts a
  /// new site, which becomes the active one; otherwise the site is updated
  /// and, if it is the active one, its new values apply at once. Returns
  /// the site's id.
  Future<int> saveSite(LocationProfile site) async {
    final int id;
    if (site.id == 0) {
      id = await _locationRepository.insertLocation(site);
    } else {
      id = site.id;
      await _locationRepository.updateLocation(site);
    }
    _sites = await _locationRepository.getLocations();
    if (site.id == 0 || _activeSite?.id == id) {
      await selectSite(id);
    } else {
      notifyListeners();
    }
    return id;
  }

  /// Deletes the saved site [id]. If it was the active site, its
  /// coordinates stay as the transient position, so night times keep
  /// working, but its zone and sky darkness no longer apply (owner
  /// decision, TASK 7.3).
  Future<void> deleteSite(int id) async {
    await _locationRepository.deleteLocation(id);
    _sites = await _locationRepository.getLocations();
    final active = _activeSite;
    if (active != null && active.id == id) {
      _activeSite = null;
      _bortleClass = null;
      _locationName = null;
      _locationNameAttribution = null;
      await _stateRepository.clearActiveLocationId();
      await _stateRepository.setTransientPosition(_latitude, _longitude);
      unawaited(_reverseGeocode(_latitude, _longitude));
    }
    notifyListeners();
  }

  /// Today's date for provenance stamps on user edits (the injected clock's
  /// UTC date, as [setBortleClass] uses).
  CalendarDate get today => CalendarDate.fromDateTimeFields(_clock.nowUtc());

  /// The device's IANA zone, to pre-fill the site editor's zone picker
  /// only; never used in a computation (ADR-007 §6).
  Future<String?> deviceZoneId() => _deviceTimeZone.zoneId();

  /// The site's time context: its IANA zone when known (TASK 7.1),
  /// otherwise mean solar time (ADR-007 §6, L1). Never the device zone.
  SiteTimeContext get _timeContext =>
      IanaTimeContext.tryCreate(_activeSite?.timeZoneId) ??
      MeanSolarTimeContext(_longitude);

  /// The IANA zone times should be shown in, or null to use the device zone
  /// (always labelled; ADR-007 §6).
  String? get displayZoneId {
    final ctx = _timeContext;
    return ctx is IanaTimeContext ? ctx.id : null;
  }

  double get dewPointThreshold => _preferences.dewMarginC;

  /// The user's planning thresholds and overhead defaults (TASK 5.2).
  PlanningPreferences get planningPreferences => _preferences;

  /// Replaces the planning preferences, persists them, and refreshes every
  /// value derived from them (windows, feasibility, dew warning).
  Future<void> setPlanningPreferences(PlanningPreferences preferences) async {
    _preferences = preferences;
    notifyListeners();
    await _preferencesRepository.save(_preferences);
  }

  /// Minimum usable altitude. Clamped to [5°, 60°].
  double get minAltitude => _preferences.minAltitudeDeg;

  /// Sets the minimum usable altitude and persists it.
  /// [value] is clamped to the valid range [5°, 60°].
  Future<void> setMinAltitude(double value) async {
    await setPlanningPreferences(_preferences.copyWith(minAltitudeDeg: value));
  }

  /// Looks up a place name for the position through the [ReverseGeocoder]
  /// (TASK 7.2). Best-effort: a failure leaves the name unknown and is logged,
  /// and an answer for a position the user has since moved away from is
  /// ignored.
  Future<void> _reverseGeocode(double lat, double lon) async {
    final result = await _reverseGeocoder.placeNameFor(lat, lon);
    if (lat != _latitude || lon != _longitude) return;
    switch (result) {
      case PlaceNameFound(:final name, :final attribution):
        _locationName = name;
        _locationNameAttribution = attribution;
      case PlaceNameNotFound():
        _locationName = null;
        _locationNameAttribution = null;
      case ReverseGeocodeFailed(:final reason):
        _locationName = null;
        _locationNameAttribution = null;
        debugPrint('Reverse geocoding failed: $reason');
    }
    notifyListeners();
  }

  /// Sets a **transient** position (a map pick or GPS fix, TASK 7.1): it is
  /// remembered across restarts but never written into a saved site, and it
  /// deselects the active site (whose zone and Bortle no longer apply).
  Future<void> setLocation(double lat, double lon) async {
    _latitude = lat;
    _longitude = lon;
    _usingDefaultLocation = false;
    _activeSite = null;
    _bortleClass = null;
    _locationName = null;
    _locationNameAttribution = null;
    await _stateRepository.clearActiveLocationId();
    await _stateRepository.setTransientPosition(lat, lon);
    await _fetchWeather();
    unawaited(_reverseGeocode(lat, lon));
  }

  /// Asks the [LocationService] for the device position without using it,
  /// e.g. for the location picker to preview before the user confirms.
  Future<LocationResult> locateDevice() =>
      _locationService.getCurrentLocation();

  /// Makes the device position the (transient) current position. On a
  /// [LocationUnavailable] nothing changes; the result says why, so the
  /// caller can explain it.
  Future<LocationResult> useCurrentLocation() async {
    final result = await locateDevice();
    if (result is LocationFound) {
      await setLocation(result.location.latitude, result.location.longitude);
    }
    return result;
  }

  /// Opens the device's location settings ([LocationFailure.serviceDisabled]).
  Future<bool> openLocationSettings() =>
      _locationService.openLocationSettings();

  /// Opens the app's settings page
  /// ([LocationFailure.permissionDeniedForever]).
  Future<bool> openAppSettings() => _locationService.openAppSettings();

  Future<void> refreshWeather() => _fetchWeather(forceRefresh: true);

  /// Loads the chosen night's forecast through [NightWeatherService]
  /// (TASK 9.3; the only weather path since TASK 9.4).
  Future<void> _fetchWeather({bool forceRefresh = false}) async {
    final night = sessionNight;
    final request = ++_nightWeatherRequest;
    if (night == null) {
      _nightWeather = const NightWeatherIdle();
      notifyListeners();
      return;
    }
    _nightWeather = const NightWeatherLoading();
    notifyListeners();
    final latitude = _latitude;
    final longitude = _longitude;
    final result = await _nightWeatherService.load(
      night,
      latitude: latitude,
      longitude: longitude,
      forceRefresh: forceRefresh,
    );
    if (request != _nightWeatherRequest) return; // superseded
    _nightWeather = result;
    notifyListeners();
  }

  Future<void> addCaptureBlock(CaptureBlock block) async {
    _captureBlocks.add(block);
    _isExampleCapturePlan = false;
    await _saveBlocks();
  }

  Future<void> updateCaptureBlock(int index, CaptureBlock block) async {
    if (index >= 0 && index < _captureBlocks.length) {
      _captureBlocks[index] = block;
      _isExampleCapturePlan = false;
      await _saveBlocks();
    }
  }

  Future<void> removeCaptureBlock(int index) async {
    if (index >= 0 && index < _captureBlocks.length) {
      _captureBlocks.removeAt(index);
      _isExampleCapturePlan = false;
      await _saveBlocks();
    }
  }

  /// Expects `newIndex` already adjusted for the removal at `oldIndex`, per
  /// the `onReorderItem` contract `capture_plan_widget.dart` uses — do not
  /// re-adjust it here (TD-010: the old `newIndex -= 1` doubled up with that
  /// adjustment and dropped blocks dragged downward one slot short).
  Future<void> reorderCaptureBlocks(int oldIndex, int newIndex) async {
    final item = _captureBlocks.removeAt(oldIndex);
    _captureBlocks.insert(newIndex, item);
    _isExampleCapturePlan = false;
    await _saveBlocks();
  }

  Future<void> _saveBlocks() async {
    notifyListeners();
    await _stateRepository.saveCaptureBlocks(_captureBlocks);
  }

  Future<void> setEquipment(EquipmentProfile profile) async {
    _selectedEquipment = profile;
    notifyListeners();
    await _stateRepository.setSelectedEquipmentId(profile.id);
  }

  Future<void> setTarget(AstroTarget target) async {
    _selectedTarget = target;
    notifyListeners();
    await _stateRepository.setSelectedTargetId(target.id);
  }

  /// An explicit user edit of the Bortle class (null = unknown). For an
  /// active saved site it is stored with source `user` and today's date;
  /// for a transient position it is held in memory only.
  Future<void> setBortleClass(int? bortle) async {
    _bortleClass = bortle;
    notifyListeners();
    final site = _activeSite;
    if (site != null) {
      final updated = site.withUserBortle(
        bortle,
        CalendarDate.fromDateTimeFields(_clock.nowUtc()),
      );
      _activeSite = updated;
      await _locationRepository.updateLocation(updated);
    }
  }

  Future<void> setDewPointThreshold(double threshold) async {
    await setPlanningPreferences(_preferences.copyWith(dewMarginC: threshold));
  }

  Future<void> loadSession(SessionLog log) async {
    _activeSessionLog = log;
    // log.sessionDate is a legacy instant (Drift hands it back as a
    // device-local DateTime); its device-local calendar date is what the
    // app showed for this session before, so that is what it maps to
    // (ADR-007 §10 "legacy rows" proposal).
    _pickedEveningDate = CalendarDate.fromDateTimeFields(
      log.sessionDate.toLocal(),
    );

    // Look up target
    final targets = await _targetRepository.searchTargets(log.targetName);
    if (targets.isNotEmpty) {
      try {
        _selectedTarget = targets.firstWhere(
          (t) =>
              (t.commonName ?? t.catalogId).toLowerCase() ==
              log.targetName.toLowerCase(),
        );
      } catch (e) {
        _selectedTarget = targets.first;
      }
    }

    // Look up equipment
    final equipments = await _equipmentRepository.getAllEquipment();
    if (equipments.isNotEmpty) {
      try {
        _selectedEquipment = equipments.firstWhere(
          (e) => e.name.toLowerCase() == log.equipmentName.toLowerCase(),
        );
      } catch (e) {
        // Keep current or clear
      }
    }

    if (log.captureBlocks.isNotEmpty) {
      _captureBlocks = List.from(log.captureBlocks);
      _isExampleCapturePlan = false;
      await _saveBlocks();
    }

    notifyListeners();
  }

  void newSession() {
    _activeSessionLog = null;
    // Back to the default night (the one containing "now"), not a fixed
    // wrong-zone date (TD-001: this used to re-set DateTime.now().toUtc()).
    _pickedEveningDate = null;
    // we could also clear capture blocks or target if desired, but retaining them might be fine.
    // The requirement says "resets the planner state."
    notifyListeners();
  }

  /// Records [log] as the active session after a successful save (TASK 4.2,
  /// TD-011), without `loadSession`'s heavier re-derivation of target/
  /// equipment/date from the log. A second Save while [log]'s id is set
  /// routes to `updateLog` instead of inserting a duplicate row.
  void markSessionSaved(SessionLog log) {
    _activeSessionLog = log;
    notifyListeners();
  }

  /// Re-reads the selected target from the repository by id (TASK 4.2,
  /// TD-028): clears the selection if it was deleted, or picks up an edit,
  /// instead of leaving stale state. Call after any target edit or delete.
  Future<void> refreshSelectedTarget() async {
    final current = _selectedTarget;
    if (current == null) return;
    _selectedTarget = await _targetRepository.getTargetById(current.id);
    notifyListeners();
  }

  /// Re-reads the selected equipment from the repository by id (TASK 4.2,
  /// TD-028) — see [refreshSelectedTarget].
  Future<void> refreshSelectedEquipment() async {
    final current = _selectedEquipment;
    if (current == null) return;
    _selectedEquipment = await _equipmentRepository.getEquipmentById(
      current.id,
    );
    notifyListeners();
  }

  // Calculations exposed to the UI

  /// The Sun's dusk/dawn timeline for [sessionNight], or null when there is
  /// no site (ADR-007 §8-§9).
  NightTimeline? get nightTimeline {
    final night = sessionNight;
    if (night == null) return null;
    return VisibilityCalculator.calculateNightTimelineForNight(night);
  }

  /// The imaging windows of [imagingOpportunity] — the budget fit's input
  /// since TASK 10.2 (the same windows as before while the optional gates
  /// are off). Empty without a night or target.
  List<VisibilityWindow> get visibilityWindows =>
      imagingOpportunity?.visibilityWindows ?? const [];

  /// When and why the selected target can be imaged tonight (ADR-013, TASK
  /// 10.2): gates, windows with Moon/weather annotations, reasons for the
  /// excluded time. Null without a night or target. Cached per input.
  ImagingOpportunity? get imagingOpportunity {
    final night = sessionNight;
    final target = _selectedTarget;
    if (night == null || target == null) return null;
    final weather = _nightWeather;
    final key = (
      night,
      target.rightAscension,
      target.declination,
      _preferences,
      weather,
      _activeSite,
      _bortleClass,
    );
    if (_opportunityKey != key) {
      if (_sunTrack?.night != night) _sunTrack = SunTrack.forNight(night);
      _opportunity = ImagingOpportunityCalculator.calculate(
        night: night,
        target: target,
        darknessLimitDeg: _preferences.darknessLimit.degrees,
        minAltitudeDeg: _preferences.minAltitudeDeg,
        sunTrack: _sunTrack,
        gates: _preferences.optionalGates,
        moon: moonConditions,
        weather: weather is NightWeatherAvailable
            ? OpportunityWeather(
                snapshot: weather.snapshot,
                age: weather.age,
                dewMarginC: _preferences.dewMarginC,
              )
            : null,
        skyDarkness: skyDarkness,
      );
      _opportunityKey = key;
    }
    return _opportunity;
  }

  Object? _opportunityKey;
  ImagingOpportunity? _opportunity;

  /// The Sun on the current night's grid, shared by every target (TASK 10.2).
  SunTrack? _sunTrack;

  /// Moon context for [sessionNight] and the selected target (ADR-010,
  /// TASK 6.4), or null without a site. Cached per night and target: it
  /// samples the Moon on the whole 5-minute grid.
  MoonConditions? get moonConditions {
    final night = sessionNight;
    if (night == null) return null;
    final target = _selectedTarget;
    final key = (night, target?.rightAscension, target?.declination);
    if (_moonCacheKey != key) {
      _moonCache = MoonCalculator.conditionsForNight(night, target: target);
      _moonCacheKey = key;
    }
    return _moonCache;
  }

  Object? _moonCacheKey;
  MoonConditions? _moonCache;

  /// Lunar illuminated fraction for [sessionNight] at mean solar midnight
  /// (Meeus ch. 48 via [moonConditions]; the mean-phase model was retired in
  /// TASK 6.4). Null when there is no site.
  double? get lunarIllumination => moonConditions?.illuminationAtMidnight;

  bool get skyDarknessWarning {
    final illum = lunarIllumination;
    final bortle = _bortleClass;
    return (illum != null && illum > 0.8) || (bortle != null && bortle >= 7);
  }

  /// The chosen night's weather from sunset to sunrise, as per-hour
  /// indicators and ranges with the dew-spread heuristic (TASK 9.4). Null
  /// unless a forecast is available ([nightWeather]).
  NightWeatherSummary? get nightWeatherSummary {
    final weather = _nightWeather;
    final timeline = nightTimeline;
    if (weather is! NightWeatherAvailable || timeline == null) return null;
    final span = NightWeatherSummarizer.spanOf(timeline);
    return NightWeatherSummarizer.summarize(
      weather.snapshot,
      fromUtc: span.fromUtc,
      toUtc: span.toUtc,
      span: span.span,
      dewMarginC: _preferences.dewMarginC,
    );
  }

  /// The target's altitude right now. Null without a target or a real site
  /// (showing this for the default London coordinates would be a misleading
  /// default, SI-008).
  double? get currentAltitude {
    if (_selectedTarget == null || _usingDefaultLocation) return null;

    return VisibilityCalculator.calculateTargetAltitude(
      _selectedTarget!,
      _clock.nowUtc(),
      _latitude,
      _longitude,
    );
  }

  /// The target's culmination altitude (LHA = 0). Null without a target or a
  /// real site — see [currentAltitude].
  double? get maxAltitude {
    if (_selectedTarget == null || _usingDefaultLocation) return null;

    return VisibilityCalculator.calculateCulminationAltitude(
      _selectedTarget!,
      _clock.nowUtc(),
      _latitude,
    );
  }

  /// The selected rig's capability summary and exposure guidance for the
  /// selected target (TASK 8.6, PD-11) — computed by the domain
  /// [CapabilityCalculator]; null without equipment.
  RigCapability? get rigCapability {
    final rig = _selectedEquipment;
    if (rig == null) return null;
    return CapabilityCalculator.evaluate(
      rig,
      target: _selectedTarget,
      npfK: _preferences.npfK,
    );
  }

  /// The capture budget of the current plan (ADR-009, TASK 5.4). All
  /// budget arithmetic lives in [CaptureBudgetCalculator]; this getter only
  /// supplies its inputs.
  CaptureBudget get captureBudget {
    final overheads = CaptureOverheads.fromPreferences(_preferences);
    final transit = overheads.meridianFlipMs == null ? null : _transitUtc;
    return CaptureBudgetCalculator.calculate(
      blocks: _captureBlocks,
      overheads: overheads,
      targetTransitsInWindow:
          transit != null &&
          visibilityWindows.any(
            (w) => !transit.isBefore(w.start) && transit.isBefore(w.end),
          ),
      averageRawFileSizeMB: _selectedEquipment?.averageRawFileSizeMB,
    );
  }

  /// The target's upper transit tonight, or null without a night/target or
  /// when it culminates outside the night (5-minute resolution).
  DateTime? get _transitUtc {
    final night = sessionNight;
    if (night == null || _selectedTarget == null) return null;
    return CaptureBudgetCalculator.transitInstant(
      VisibilityCalculator.calculateAltitudeCurve(
        night: night,
        target: _selectedTarget!,
      ),
    );
  }

  /// Light-frame integration, formatted "Xh Ym".
  String get totalIntegrationTime {
    final minutes = captureBudget.integration.inMinutes;
    return '${minutes ~/ 60}h ${minutes % 60}m';
  }

  /// The time the plan needs inside the imaging windows: acquisition plus
  /// in-window calibration (ADR-009 §2 "window load"). Calibration taken
  /// outside the window or from a library is not included.
  Duration get estimatedRequiredTime => captureBudget.windowLoad;

  /// Whether and how the plan fits tonight's windows (ADR-009 §6, TASK
  /// 5.5): the budget's event sequence placed atomically into the windows.
  FitResult get fitAnalysis {
    final budget = captureBudget;
    final night = sessionNight;
    final String noWindowReason;
    if (night == null) {
      // Home already shows its own "No site set" state; don't repeat it.
      noWindowReason = "Choose a location to see tonight's windows.";
    } else if (_selectedTarget == null) {
      noWindowReason = "Choose a target to see tonight's windows.";
    } else if (imagingOpportunity?.noWindowReason ==
        NoWindowReason.excludedByOptionalGates) {
      noWindowReason =
          'No usable window: your Moon or cloud gate excludes all of '
          "tonight's dark time with the target high enough.";
    } else {
      noWindowReason = FitAnalyzer.noWindowReason(
        timeline: nightTimeline!,
        darknessLimitDeg: _preferences.darknessLimit.degrees,
        minAltitudeDeg: _preferences.minAltitudeDeg,
      );
    }
    return FitAnalyzer.analyze(
      budget: budget,
      windows: visibilityWindows,
      marginFraction: _preferences.feasibilityMarginFraction,
      transitUtc: budget.countOf(BudgetEventKind.meridianFlip) > 0
          ? _transitUtc
          : null,
      noWindowReason: noWindowReason,
    );
  }

  /// The light block "Fill tonight's window" adjusts: the plan's last light
  /// block (typically the one to trim or extend). Null without one.
  int? get fillWindowBlockIndex {
    for (var i = _captureBlocks.length - 1; i >= 0; i--) {
      if (_captureBlocks[i].frameType == FrameType.light) return i;
    }
    return null;
  }

  /// The frame count for [fillWindowBlockIndex] that fills tonight's windows
  /// with the rest of the plan unchanged (TASK 5.6), or null without a light
  /// block. 0 means not even one frame of it fits.
  int? get fillWindowFrameCount {
    final index = fillWindowBlockIndex;
    if (index == null) return null;
    final overheads = CaptureOverheads.fromPreferences(_preferences);
    final budget = captureBudget;
    final flip = budget.countOf(BudgetEventKind.meridianFlip) > 0;
    return FitAnalyzer.maxFramesForBlock(
      blocks: _captureBlocks,
      blockIndex: index,
      windows: visibilityWindows,
      overheads: overheads,
      targetTransitsInWindow: flip,
      transitUtc: flip ? _transitUtc : null,
    );
  }

  /// Sets [fillWindowBlockIndex]'s frame count to [fillWindowFrameCount].
  /// Returns false (and changes nothing) when there is no light block or
  /// not even one frame fits.
  Future<bool> fillWindow() async {
    final index = fillWindowBlockIndex;
    final count = fillWindowFrameCount;
    if (index == null || count == null || count < 1) return false;
    await updateCaptureBlock(
      index,
      _captureBlocks[index].copyWith(frameCount: count),
    );
    return true;
  }

  /// Estimated storage (MB) for every frame taken (library blocks excluded);
  /// null when the rig's file size is unknown (SI-013).
  double? get estimatedStorageMB => captureBudget.storageMB;

  double get relativeStackingGain =>
      OpticalCalculator.calculateRelativeStackingGain(
        captureBudget.lightFrameCount,
      );

  double? get pixelScale {
    if (_selectedEquipment == null) return null;
    final efl = OpticalCalculator.calculateEffectiveFocalLength(
      focalLength: _selectedEquipment!.focalLengthMm,
    );
    return OpticalCalculator.calculatePixelScale(
      pixelPitch: _selectedEquipment!.pixelPitchUm,
      effectiveFocalLength: efl,
    );
  }
}
