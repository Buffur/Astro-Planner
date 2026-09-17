import 'package:flutter/foundation.dart';
import '../../domain/models/astro_target.dart';
import '../../domain/models/equipment_profile.dart';
import '../../domain/repositories/target_repository.dart';
import '../../domain/repositories/equipment_repository.dart';
import '../../domain/services/visibility_calculator.dart';
import '../../domain/services/astronomical_engine.dart';
import '../../domain/services/optical_calculator.dart';

class PlannerViewModel extends ChangeNotifier {
  final TargetRepository _targetRepository;
  final EquipmentRepository _equipmentRepository;

  AstroTarget? _selectedTarget;
  EquipmentProfile? _selectedEquipment;
  final DateTime _sessionDate = DateTime.now().toUtc();
  final double _latitude = 51.5072; // London default
  final double _longitude = -0.1276;
  
  int _lightFrames = 100;
  final int _exposureSeconds = 60;

  PlannerViewModel(this._targetRepository, this._equipmentRepository) {
    _init();
  }

  Future<void> _init() async {
    final targets = await _targetRepository.searchTargets('M42');
    if (targets.isNotEmpty) {
      _selectedTarget = targets.first;
    }
    
    final equipment = await _equipmentRepository.getAllEquipment();
    if (equipment.isNotEmpty) {
      // Default to the first phone in the catalog
      _selectedEquipment = equipment.first;
    }
    notifyListeners();
  }

  AstroTarget? get selectedTarget => _selectedTarget;
  EquipmentProfile? get selectedEquipment => _selectedEquipment;
  DateTime get sessionDate => _sessionDate;
  int get lightFrames => _lightFrames;
  int get exposureSeconds => _exposureSeconds;

  void setLightFrames(int frames) {
    _lightFrames = frames;
    notifyListeners();
  }
  
  void setEquipment(EquipmentProfile profile) {
    _selectedEquipment = profile;
    notifyListeners();
  }

  void setTarget(AstroTarget target) {
    _selectedTarget = target;
    notifyListeners();
  }

  // Calculations exposed to the UI

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
    return singleFrame * _lightFrames;
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
