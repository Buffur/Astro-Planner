import 'dart:async';
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/scheduler.dart';
import 'package:http/http.dart' as http;

import '../../core/time/clock.dart';
import '../../domain/models/astro_target.dart';
import '../../domain/models/calendar_date.dart';
import '../../domain/models/equipment_profile.dart';
import '../../domain/models/capture_block.dart';
import '../../domain/models/night_timeline.dart';
import '../../domain/models/session_night.dart';
import '../../domain/models/site_time_context.dart';
import '../../domain/models/weather_conditions.dart';
import '../../domain/models/location_profile.dart';
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
import '../../data/repositories/light_pollution_repository.dart';
import '../../data/services/geolocator_location_service.dart';
import '../../domain/services/location_service.dart';
import '../../domain/services/session_night_resolver.dart';
import '../../domain/services/visibility_calculator.dart';
import '../../domain/services/optical_calculator.dart';
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
  final LightPollutionRepository _lightPollutionRepository;
  final LocationService _locationService;
  final Clock _clock;
  final PlanningPreferencesRepository _preferencesRepository;
  final PlannerStateRepository _stateRepository;

  /// Completes when the initial state (saved location, capture blocks, target,
  /// equipment, weather) has loaded. It does not wait for the silent
  /// first-launch position lookup or for reverse geocoding.
  late final Future<void> ready;

  bool _isLoading = true;

  /// Set when the initial load (location, capture blocks, target, equipment)
  /// fails. Weather is not part of this — see [weatherError].
  Object? _bootstrapError;

  /// True until a location is resolved, either from a saved profile or from
  /// the device. While true, [latitude]/[longitude] are the hard-coded
  /// default (London), used silently.
  bool _usingDefaultLocation = true;

  AstroTarget? _selectedTarget;
  EquipmentProfile? _selectedEquipment;
  WeatherConditions? _currentWeather;
  bool _weatherError = false;
  String? _locationName;

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
  int _bortleClass = 4;

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
    this._locationRepository,
    this._lightPollutionRepository, {
    LocationService? locationService,
    Clock? clock,
    PlanningPreferencesRepository? preferencesRepository,
    PlannerStateRepository? stateRepository,
  }) : _locationService = locationService ?? GeolocatorLocationService(),
       _clock = clock ?? const SystemClock(),
       _preferencesRepository =
           preferencesRepository ?? SharedPrefsPlanningPreferencesRepository(),
       _stateRepository =
           stateRepository ?? SharedPrefsPlannerStateRepository() {
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
        _latitude = loc.latitude;
        _longitude = loc.longitude;
        _bortleClass = loc.bortleClass;
        _usingDefaultLocation = false;
      }
    } else {
      // First launch — try getting current location silently
      unawaited(useCurrentLocation());
    }

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

    unawaited(_reverseGeocode(_latitude, _longitude));
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
  WeatherConditions? get currentWeather => _currentWeather;

  /// True when the most recent weather fetch threw. Distinct from
  /// [currentWeather] being null, which can also mean "not loaded yet".
  bool get weatherError => _weatherError;

  String? get locationName => _locationName;

  /// The current [SessionNight], or null when there is no site to resolve
  /// one for (ADR-007 §9: "when no site is set, there is no SessionNight").
  /// Before TASK 7.1 this always resolves through a [MeanSolarTimeContext]
  /// on [_longitude] — the device zone is never used in the computation.
  SessionNight? get sessionNight {
    if (_usingDefaultLocation) return null;
    final timeContext = MeanSolarTimeContext(_longitude);
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
    _refreshWeather(); // Date change might need new weather
    notifyListeners();
  }

  Future<void> _refreshWeather() => refreshWeather();

  double get latitude => _latitude;
  double get longitude => _longitude;
  List<CaptureBlock> get captureBlocks => _captureBlocks;

  /// True while the current capture plan is still the seeded example, not a
  /// plan the user has built — the UI must label it accordingly.
  bool get isExampleCapturePlan => _isExampleCapturePlan;
  int get bortleClass => _bortleClass;
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

  /// Resolves lat/lon to a human-readable city/town name via Open-Meteo geocoding.
  /// Uses the free Open-Meteo reverse geocoding endpoint — no API key required.
  Future<void> _reverseGeocode(double lat, double lon) async {
    try {
      final uri = Uri.parse(
        'https://nominatim.openstreetmap.org/reverse?lat=$lat&lon=$lon&format=json&accept-language=en',
      );
      final response = await http
          .get(uri, headers: {'User-Agent': 'AstroPlan/1.0'})
          .timeout(const Duration(seconds: 6));
      if (response.statusCode == 200) {
        final data = json.decode(response.body) as Map<String, dynamic>;
        final address = data['address'] as Map<String, dynamic>?;
        if (address != null) {
          _locationName =
              address['city'] as String? ??
              address['town'] as String? ??
              address['village'] as String? ??
              address['county'] as String? ??
              address['state'] as String?;
          notifyListeners();
        }
      }
    } catch (_) {
      // Reverse geocoding is best-effort — silently fail
    }
  }

  Future<void> _fetchBortle(double lat, double lon) async {
    final bortle = await _lightPollutionRepository.fetchBortleClass(lat, lon);
    if (bortle != null) {
      _bortleClass = bortle;
      notifyListeners();

      // Update saved location profile if active
      final activeId = await _stateRepository.getActiveLocationId();
      if (activeId != null) {
        final existing = await _locationRepository.getLocationById(activeId);
        if (existing != null) {
          await _locationRepository.updateLocation(
            LocationProfile(
              id: activeId,
              name: existing.name,
              latitude: existing.latitude,
              longitude: existing.longitude,
              elevation: existing.elevation,
              bortleClass: bortle,
            ),
          );
        }
      }
    }
  }

  Future<void> setLocation(double lat, double lon) async {
    _latitude = lat;
    _longitude = lon;
    _usingDefaultLocation = false;
    await _fetchWeather();
    unawaited(_reverseGeocode(lat, lon));
    unawaited(_fetchBortle(lat, lon));

    final activeId = await _stateRepository.getActiveLocationId();
    if (activeId != null) {
      final existing = await _locationRepository.getLocationById(activeId);
      if (existing != null) {
        // Update existing saved location
        await _locationRepository.updateLocation(
          LocationProfile(
            id: activeId,
            name: existing.name,
            latitude: lat,
            longitude: lon,
            elevation: existing.elevation,
            bortleClass: _bortleClass,
          ),
        );
        return;
      }
    }

    // Insert new custom location
    final loc = LocationProfile(
      id: 0,
      name: 'Custom Location',
      latitude: lat,
      longitude: lon,
      elevation: 0,
      bortleClass: _bortleClass,
    );
    final newId = await _locationRepository.insertLocation(loc);
    await _stateRepository.setActiveLocationId(newId);
  }

  Future<void> useCurrentLocation() async {
    final position = await _locationService.getCurrentLocation();
    if (position == null) {
      return;
    }
    await setLocation(position.latitude, position.longitude);
  }

  Future<void> refreshWeather() => _fetchWeather(forceRefresh: true);

  Future<void> _fetchWeather({bool forceRefresh = false}) async {
    try {
      _currentWeather = await _weatherRepository.getCurrentWeather(
        _latitude,
        _longitude,
        forceRefresh: forceRefresh,
      );
      _weatherError = false;
    } catch (e) {
      _weatherError = true;
      debugPrint('Weather fetch error: $e');
    }
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

  Future<void> setBortleClass(int bortle) async {
    _bortleClass = bortle;
    notifyListeners();
    final activeId = await _stateRepository.getActiveLocationId();
    if (activeId != null) {
      final existing = await _locationRepository.getLocationById(activeId);
      if (existing != null) {
        await _locationRepository.updateLocation(
          LocationProfile(
            id: activeId,
            name: existing.name,
            latitude: existing.latitude,
            longitude: existing.longitude,
            elevation: existing.elevation,
            bortleClass: bortle,
          ),
        );
      }
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

  List<VisibilityWindow> get visibilityWindows {
    final night = sessionNight;
    if (night == null || _selectedTarget == null) return [];
    return VisibilityCalculator.calculateVisibilityWindowsForNight(
      night: night,
      target: _selectedTarget!,
      minAltitude: _preferences.minAltitudeDeg,
      darknessLimitDeg: _preferences.darknessLimit.degrees,
    );
  }

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
    return (illum != null && illum > 0.8) || _bortleClass >= 7;
  }

  bool get dewWarning {
    if (_currentWeather == null) return false;
    return (_currentWeather!.temperature - _currentWeather!.dewPoint) <=
        _preferences.dewMarginC;
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

  double? get npfExposure {
    if (_selectedEquipment == null || _selectedTarget == null) return null;
    return OpticalCalculator.calculateNPFExposure(
      apertureFNumber: _selectedEquipment!.aperture,
      pixelPitch: _selectedEquipment!.pixelPitch,
      effectiveFocalLength: _selectedEquipment!.focalLength,
      declinationDegrees: _selectedTarget!.declination,
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
      focalLength: _selectedEquipment!.focalLength,
    );
    return OpticalCalculator.calculatePixelScale(
      pixelPitch: _selectedEquipment!.pixelPitch,
      effectiveFocalLength: efl,
    );
  }
}
