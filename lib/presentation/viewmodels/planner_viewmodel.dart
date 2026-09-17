import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../domain/models/astro_target.dart';
import '../../domain/models/equipment_profile.dart';
import '../../domain/repositories/target_repository.dart';
import '../../domain/repositories/equipment_repository.dart';
import '../../domain/repositories/weather_repository.dart';
import '../../domain/services/visibility_calculator.dart';
import '../../domain/services/astronomical_engine.dart';
import '../../domain/services/optical_calculator.dart';
import '../../domain/models/weather_conditions.dart';

class PlannerViewModel extends ChangeNotifier {
  final TargetRepository _targetRepository;
  final EquipmentRepository _equipmentRepository;
  final WeatherRepository _weatherRepository;

  AstroTarget? _selectedTarget;
  EquipmentProfile? _selectedEquipment;
  WeatherConditions? _currentWeather;
  
  final DateTime _sessionDate = DateTime.now().toUtc();
  double _latitude = 51.5072;
  double _longitude = -0.1276;
  
  int _lightFrames = 100;
  int _darkFrames = 20;
  int _flatFrames = 20;
  int _biasFrames = 20;
  final int _exposureSeconds = 60;
  int _bortleClass = 4;

  PlannerViewModel(this._targetRepository, this._equipmentRepository, this._weatherRepository) {
    _init();
  }

  Future<void> _init() async {
    final prefs = await SharedPreferences.getInstance();
    
    _latitude = prefs.getDouble('latitude') ?? 51.5072;
    _longitude = prefs.getDouble('longitude') ?? -0.1276;
    _lightFrames = prefs.getInt('lightFrames') ?? 100;
    _darkFrames = prefs.getInt('darkFrames') ?? 20;
    _flatFrames = prefs.getInt('flatFrames') ?? 20;
    _biasFrames = prefs.getInt('biasFrames') ?? 20;
    _bortleClass = prefs.getInt('bortleClass') ?? 4;
    
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
    
    _currentWeather = await _weatherRepository.getCurrentWeather(_latitude, _longitude);
    
    notifyListeners();
  }

  AstroTarget? get selectedTarget => _selectedTarget;
  EquipmentProfile? get selectedEquipment => _selectedEquipment;
  WeatherConditions? get currentWeather => _currentWeather;
  DateTime get sessionDate => _sessionDate;
  double get latitude => _latitude;
  double get longitude => _longitude;
  int get lightFrames => _lightFrames;
  int get darkFrames => _darkFrames;
  int get flatFrames => _flatFrames;
  int get biasFrames => _biasFrames;
  int get exposureSeconds => _exposureSeconds;
  int get bortleClass => _bortleClass;

  Future<void> setLocation(double lat, double lon) async {
    _latitude = lat;
    _longitude = lon;
    _currentWeather = await _weatherRepository.getCurrentWeather(_latitude, _longitude);
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble('latitude', lat);
    await prefs.setDouble('longitude', lon);
  }

  Future<void> setLightFrames(int frames) async {
    _lightFrames = frames;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('lightFrames', _lightFrames);
  }

  Future<void> setDarkFrames(int frames) async {
    _darkFrames = frames;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('darkFrames', _darkFrames);
  }

  Future<void> setFlatFrames(int frames) async {
    _flatFrames = frames;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('flatFrames', _flatFrames);
  }

  Future<void> setBiasFrames(int frames) async {
    _biasFrames = frames;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('biasFrames', _biasFrames);
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
    await prefs.setInt('bortleClass', _bortleClass);
  }

  // Calculations exposed to the UI

  double get lunarIllumination {
    return VisibilityCalculator.calculateLunarIllumination(_sessionDate);
  }

  bool get skyDarknessWarning {
    return lunarIllumination > 0.8 || _bortleClass >= 7;
  }

  double? get currentAltitude {
    if (_selectedTarget == null) return null;
    final jd = AstronomicalEngine.calculateJulianDate(_sessionDate);
    final gmst = AstronomicalEngine.calculateGMST(jd);
    final lst = AstronomicalEngine.calculateLST(gmst, _longitude);
    final lha = VisibilityCalculator.calculateLHA(lst, _selectedTarget!.rightAscension);
    return VisibilityCalculator.calculateAltitude(lha: lha, declination: _selectedTarget!.declination, latitude: _latitude);
  }

  double? get maxAltitude {
    if (_selectedTarget == null) return null;
    return VisibilityCalculator.calculateAltitude(lha: 0.0, declination: _selectedTarget!.declination, latitude: _latitude);
  }

  String get totalIntegrationTime {
    final totalSeconds = _lightFrames * _exposureSeconds;
    final hours = totalSeconds ~/ 3600;
    final minutes = (totalSeconds % 3600) ~/ 60;
    return '${hours}h ${minutes}m';
  }

  double? get theoreticalStorageMB {
    if (_selectedEquipment == null) return null;
    final singleFrame = OpticalCalculator.estimateTheoreticalFrameSizeMB(
      resolutionWidth: _selectedEquipment!.resolutionWidth,
      resolutionHeight: _selectedEquipment!.resolutionHeight,
      bitDepth: 16,
    );
    final totalFrames = _lightFrames + _darkFrames + _flatFrames + _biasFrames;
    return singleFrame * totalFrames;
  }

  double get relativeStackingGain {
    return OpticalCalculator.calculateRelativeStackingGain(_lightFrames);
  }

  double? get pixelScale {
    if (_selectedEquipment == null) return null;
    final efl = OpticalCalculator.calculateEffectiveFocalLength(
      focalLength: _selectedEquipment!.focalLength,
      opticalMultiplier: _selectedEquipment!.opticalMultiplier,
    );
    return OpticalCalculator.calculatePixelScale(pixelPitch: _selectedEquipment!.pixelPitch, effectiveFocalLength: efl);
  }
}
