import 'dart:async';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/scheduler.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../../domain/models/astro_target.dart';
import '../../domain/models/equipment_profile.dart';
import '../../domain/models/capture_block.dart';
import '../../domain/models/weather_conditions.dart';
import '../../domain/models/location_profile.dart';
import '../../domain/models/visibility_window.dart';
import '../../domain/repositories/target_repository.dart';
import '../../domain/repositories/equipment_repository.dart';
import '../../domain/repositories/weather_repository.dart';
import '../../domain/repositories/location_repository.dart';
import '../../data/repositories/light_pollution_repository.dart';
import '../../data/services/geolocator_location_service.dart';
import '../../domain/services/location_service.dart';
import '../../domain/services/visibility_calculator.dart';
import '../../domain/services/astronomical_engine.dart';
import '../../domain/services/optical_calculator.dart';
import '../../domain/services/session_calculator.dart';
import '../../domain/models/session_log.dart';
class PlannerViewModel extends ChangeNotifier {
  final TargetRepository _targetRepository;
  final EquipmentRepository _equipmentRepository;
  final WeatherRepository _weatherRepository;
  final LocationRepository _locationRepository;
  final LightPollutionRepository _lightPollutionRepository;
  final LocationService _locationService;

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

  DateTime _sessionDate = DateTime.now().toUtc();
  double _latitude = 51.5072;
  double _longitude = -0.1276;

  List<CaptureBlock> _captureBlocks = [];
  int _bortleClass = 4;
  double _dewPointThreshold = 2.0;

  SessionLog? _activeSessionLog;
  int? get activeSessionId => _activeSessionLog?.id;
  SessionLog? get activeSessionLog => _activeSessionLog;

  /// Minimum usable altitude in degrees.
  ///
  /// Default: 20°
  /// Rationale: Below 20° atmospheric extinction becomes significant (≥1 mag
  /// attenuation), seeing degrades, and astrophotography quality drops
  /// noticeably. 20° is the widely adopted minimum for productive imaging.
  /// Valid range: 5° – 60°. User-configurable.
  double _minAltitude = 20.0;

  PlannerViewModel(this._targetRepository, this._equipmentRepository, this._weatherRepository, this._locationRepository, this._lightPollutionRepository, {LocationService? locationService})
      : _locationService = locationService ?? GeolocatorLocationService() {
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
    final prefs = await SharedPreferences.getInstance();

    final activeLocationId = prefs.getInt('activeLocationId');
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

    final blocksJson = prefs.getString('captureBlocks');
    if (blocksJson != null) {
      try {
        final list = jsonDecode(blocksJson) as List;
        _captureBlocks = list.map((b) => CaptureBlock(
          id: b['id'] ?? 0,
          frameType: FrameType.values.firstWhere((e) => e.name == b['frameType'], orElse: () => FrameType.light),
          filterName: b['filterName'],
          exposureTimeSeconds: (b['exposureTimeSeconds'] as num?)?.toDouble() ?? 0.0,
          frameCount: b['frameCount'] ?? 0,
          binning: b['binning'] ?? 1,
          gainIso: b['gainIso'],
        )).toList();
      } catch (e) {
        _captureBlocks = [];
      }
    }
    if (_captureBlocks.isEmpty) {
      _captureBlocks = [
        const CaptureBlock(frameType: FrameType.light, filterName: 'L', exposureTimeSeconds: 60.0, frameCount: 100),
        const CaptureBlock(frameType: FrameType.dark, exposureTimeSeconds: 60.0, frameCount: 20),
        const CaptureBlock(frameType: FrameType.flat, exposureTimeSeconds: 2.0, frameCount: 20),
      ];
    }
    
    _dewPointThreshold = prefs.getDouble('dewPointThreshold') ?? 2.0;
    _minAltitude = prefs.getDouble('minAltitude') ?? 20.0;
    
    final targetId = prefs.getInt('targetId');
    if (targetId != null) {
      _selectedTarget = await _targetRepository.getTargetById(targetId);
    }
    if (_selectedTarget == null) {
      final targets = await _targetRepository.searchTargets('M42');
      if (targets.isNotEmpty) _selectedTarget = targets.first;
    }
    
    final eqId = prefs.getInt('equipmentId');
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
  DateTime get sessionDate => _sessionDate;

  void setSessionDate(DateTime date) {
    _sessionDate = date;
    _refreshWeather(); // Date change might need new weather
    notifyListeners();
  }

  Future<void> _refreshWeather() => refreshWeather();

  double get latitude => _latitude;
  double get longitude => _longitude;
  List<CaptureBlock> get captureBlocks => _captureBlocks;
  int get bortleClass => _bortleClass;
  double get dewPointThreshold => _dewPointThreshold;

  /// Minimum usable altitude. Clamped to [5°, 60°].
  double get minAltitude => _minAltitude;

  /// Sets the minimum usable altitude and persists it.
  /// [value] is clamped to the valid range [5°, 60°].
  Future<void> setMinAltitude(double value) async {
    _minAltitude = value.clamp(5.0, 60.0);
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble('minAltitude', _minAltitude);
  }

  /// Resolves lat/lon to a human-readable city/town name via Open-Meteo geocoding.
  /// Uses the free Open-Meteo reverse geocoding endpoint — no API key required.
  Future<void> _reverseGeocode(double lat, double lon) async {
    try {
      final uri = Uri.parse(
        'https://nominatim.openstreetmap.org/reverse?lat=$lat&lon=$lon&format=json&accept-language=en',
      );
      final response = await http.get(uri, headers: {'User-Agent': 'AstroPlan/1.0'})
          .timeout(const Duration(seconds: 6));
      if (response.statusCode == 200) {
        final data = json.decode(response.body) as Map<String, dynamic>;
        final address = data['address'] as Map<String, dynamic>?;
        if (address != null) {
          _locationName = address['city'] as String? ??
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
      final prefs = await SharedPreferences.getInstance();
      final activeId = prefs.getInt('activeLocationId');
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
            )
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
    
    final prefs = await SharedPreferences.getInstance();
    final activeId = prefs.getInt('activeLocationId');
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
          )
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
    await prefs.setInt('activeLocationId', newId);
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
      _currentWeather = await _weatherRepository.getCurrentWeather(_latitude, _longitude, forceRefresh: forceRefresh);
      _weatherError = false;
    } catch (e) {
      _weatherError = true;
      debugPrint('Weather fetch error: $e');
    }
    notifyListeners();
  }

  Future<void> addCaptureBlock(CaptureBlock block) async {
    _captureBlocks.add(block);
    await _saveBlocks();
  }
  
  Future<void> updateCaptureBlock(int index, CaptureBlock block) async {
    if (index >= 0 && index < _captureBlocks.length) {
      _captureBlocks[index] = block;
      await _saveBlocks();
    }
  }

  Future<void> removeCaptureBlock(int index) async {
    if (index >= 0 && index < _captureBlocks.length) {
      _captureBlocks.removeAt(index);
      await _saveBlocks();
    }
  }

  Future<void> reorderCaptureBlocks(int oldIndex, int newIndex) async {
    if (oldIndex < newIndex) {
      newIndex -= 1;
    }
    final item = _captureBlocks.removeAt(oldIndex);
    _captureBlocks.insert(newIndex, item);
    await _saveBlocks();
  }

  Future<void> _saveBlocks() async {
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    final list = _captureBlocks.map((b) => {
      'id': b.id,
      'frameType': b.frameType.name,
      'filterName': b.filterName,
      'exposureTimeSeconds': b.exposureTimeSeconds,
      'frameCount': b.frameCount,
      'binning': b.binning,
      'gainIso': b.gainIso,
    }).toList();
    await prefs.setString('captureBlocks', jsonEncode(list));
  }
  
  Future<void> setEquipment(EquipmentProfile profile) async {
    _selectedEquipment = profile;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('equipmentId', profile.id);
  }

  Future<void> setTarget(AstroTarget target) async {
    _selectedTarget = target;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('targetId', target.id);
  }

  Future<void> setBortleClass(int bortle) async {
    _bortleClass = bortle;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    final activeId = prefs.getInt('activeLocationId');
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
          )
        );
      }
    }
  }

  Future<void> setDewPointThreshold(double threshold) async {
    _dewPointThreshold = threshold;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble('dewPointThreshold', _dewPointThreshold);
  }

  Future<void> loadSession(SessionLog log) async {
    _activeSessionLog = log;
    _sessionDate = log.sessionDate;
    
    // Look up target
    final targets = await _targetRepository.searchTargets(log.targetName);
    if (targets.isNotEmpty) {
      try {
        _selectedTarget = targets.firstWhere((t) => (t.commonName ?? t.catalogId).toLowerCase() == log.targetName.toLowerCase());
      } catch (e) {
        _selectedTarget = targets.first;
      }
    }
    
    // Look up equipment
    final equipments = await _equipmentRepository.getAllEquipment();
    if (equipments.isNotEmpty) {
      try {
        _selectedEquipment = equipments.firstWhere((e) => e.name.toLowerCase() == log.equipmentName.toLowerCase());
      } catch (e) {
        // Keep current or clear
      }
    }

    if (log.captureBlocks.isNotEmpty) {
      _captureBlocks = List.from(log.captureBlocks);
      await _saveBlocks();
    }
    
    notifyListeners();
  }

  void newSession() {
    _activeSessionLog = null;
    _sessionDate = DateTime.now().toUtc();
    // we could also clear capture blocks or target if desired, but retaining them might be fine.
    // The requirement says "resets the planner state." 
    notifyListeners();
  }

  // Calculations exposed to the UI

  Map<String, DateTime?> get nightTimeline {
    return VisibilityCalculator.calculateNightTimeline(_sessionDate, _latitude, _longitude);
  }

  List<VisibilityWindow> get visibilityWindows {
    if (_selectedTarget == null) return [];
    return VisibilityCalculator.calculateVisibilityWindows(
      date: _sessionDate,
      latitude: _latitude,
      longitude: _longitude,
      target: _selectedTarget!,
      minAltitude: _minAltitude,
    );
  }

  double get lunarIllumination {
    return VisibilityCalculator.calculateLunarIllumination(_sessionDate);
  }

  bool get skyDarknessWarning {
    return lunarIllumination > 0.8 || _bortleClass >= 7;
  }

  bool get dewWarning {
    if (_currentWeather == null) return false;
    return (_currentWeather!.temperature - _currentWeather!.dewPoint) <= _dewPointThreshold;
  }

  double? get currentAltitude {
    if (_selectedTarget == null) return null;
    if (_selectedTarget!.rightAscension == 0.0 && _selectedTarget!.declination == 0.0) return null;
    
    final jd = AstronomicalEngine.calculateJulianDate(DateTime.now().toUtc());
    final gmst = AstronomicalEngine.calculateGMST(jd);
    final lst = AstronomicalEngine.calculateLST(gmst, _longitude);
    final lha = VisibilityCalculator.calculateLHA(lst, _selectedTarget!.rightAscension);
    return VisibilityCalculator.calculateAltitude(lha: lha, declination: _selectedTarget!.declination, latitude: _latitude);
  }

  double? get maxAltitude {
    if (_selectedTarget == null) return null;
    if (_selectedTarget!.rightAscension == 0.0 && _selectedTarget!.declination == 0.0) return null;
    
    return VisibilityCalculator.calculateAltitude(lha: 0.0, declination: _selectedTarget!.declination, latitude: _latitude);
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

  String get totalIntegrationTime {
    final totalSeconds = _captureBlocks.where((b) => b.frameType == FrameType.light).fold(0.0, (sum, b) => sum + (b.exposureTimeSeconds * b.frameCount));
    final hours = totalSeconds ~/ 3600;
    final minutes = (totalSeconds % 3600) ~/ 60;
    return '${hours.toInt()}h ${minutes.toInt()}m';
  }

  Duration get estimatedRequiredTime {
    final totalExposure = _captureBlocks.fold(0.0, (sum, b) => sum + (b.exposureTimeSeconds * b.frameCount));
    // add overhead per frame (e.g. 5 seconds download time)
    final totalFrames = _captureBlocks.fold(0, (sum, b) => sum + b.frameCount);
    final overhead = totalFrames * 5.0;
    return Duration(seconds: (totalExposure + overhead).toInt());
  }

  SessionFeasibility get sessionFeasibility {
    return SessionCalculator.calculateFeasibility(
      availableWindows: visibilityWindows,
      estimatedRequiredTime: estimatedRequiredTime,
    );
  }

  double? get estimatedStorageMB {
    if (_selectedEquipment == null) return null;
    final totalFrames = _captureBlocks.fold(0, (sum, b) => sum + b.frameCount);
    return OpticalCalculator.estimateStorageRequirement(
      averageRawFileSizeMB: _selectedEquipment!.averageRawFileSizeMB,
      frameCount: totalFrames,
    );
  }

  double get relativeStackingGain {
    final lights = _captureBlocks.where((b) => b.frameType == FrameType.light).fold(0, (sum, b) => sum + b.frameCount); return OpticalCalculator.calculateRelativeStackingGain(lights);
  }

  double? get pixelScale {
    if (_selectedEquipment == null) return null;
    final efl = OpticalCalculator.calculateEffectiveFocalLength(
      focalLength: _selectedEquipment!.focalLength,
    );
    return OpticalCalculator.calculatePixelScale(pixelPitch: _selectedEquipment!.pixelPitch, effectiveFocalLength: efl);
  }
}
