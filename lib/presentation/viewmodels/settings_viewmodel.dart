import 'package:flutter/foundation.dart';

import '../../domain/models/planning_preferences.dart';
import '../../domain/repositories/planning_preferences_repository.dart';

/// The user's planning thresholds and overhead defaults (TASK 5.2; split
/// out of the planner ViewModel in TASK 12.3). Defaults, rationale and
/// valid ranges are documented on [PlanningPreferences].
class SettingsViewModel extends ChangeNotifier {
  SettingsViewModel(this._repository);

  final PlanningPreferencesRepository _repository;

  PlanningPreferences _preferences = PlanningPreferences();

  PlanningPreferences get planningPreferences => _preferences;

  /// Minimum usable altitude, degrees (clamped to [5°, 60°]).
  double get minAltitude => _preferences.minAltitudeDeg;

  /// Temperature − dew point at or below which dew risk is flagged, °C.
  double get dewPointThreshold => _preferences.dewMarginC;

  Future<void> load() async {
    _preferences = await _repository.load();
    notifyListeners();
  }

  /// Replaces the planning preferences, persists them, and lets every value
  /// derived from them (windows, fit, dew risk) refresh.
  Future<void> setPlanningPreferences(PlanningPreferences preferences) async {
    _preferences = preferences;
    notifyListeners();
    await _repository.save(_preferences);
  }

  Future<void> setMinAltitude(double value) =>
      setPlanningPreferences(_preferences.copyWith(minAltitudeDeg: value));

  Future<void> setDewPointThreshold(double threshold) =>
      setPlanningPreferences(_preferences.copyWith(dewMarginC: threshold));
}
