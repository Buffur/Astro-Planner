import 'package:flutter/foundation.dart';

import '../../domain/models/planning_preferences.dart';
import '../../domain/repositories/planning_preferences_repository.dart';
import '../../domain/repositories/privacy_preferences_repository.dart';
import '../../domain/services/opt_in_reverse_geocoder.dart';

/// The user's planning thresholds and overhead defaults (TASK 5.2; split
/// out of the planner ViewModel in TASK 12.3). Defaults, rationale and
/// valid ranges are documented on [PlanningPreferences]. Since TASK 16.3
/// also the privacy choice of place-name lookups.
class SettingsViewModel extends ChangeNotifier {
  SettingsViewModel(this._repository, this._privacy, this._placeNames);

  final PlanningPreferencesRepository _repository;
  final PrivacyPreferencesRepository _privacy;
  final OptInReverseGeocoder _placeNames;

  /// Called when place-name lookups are switched (the site looks its
  /// position up again, or clears the name).
  void Function()? onPlaceNameLookupChanged;

  /// Whether positions are sent to OpenStreetMap Nominatim for place names
  /// (off by default; TASK 16.3).
  bool get placeNameLookup => _placeNames.enabled;

  PlanningPreferences _preferences = PlanningPreferences();

  PlanningPreferences get planningPreferences => _preferences;

  /// Minimum usable altitude, degrees (clamped to [5°, 60°]).
  double get minAltitude => _preferences.minAltitudeDeg;

  /// Temperature − dew point at or below which dew risk is flagged, °C.
  double get dewPointThreshold => _preferences.dewMarginC;

  Future<void> load() async {
    _preferences = await _repository.load();
    _placeNames.enabled = await _privacy.loadPlaceNameLookup();
    notifyListeners();
    if (_placeNames.enabled) onPlaceNameLookupChanged?.call();
  }

  Future<void> setPlaceNameLookup(bool on) async {
    _placeNames.enabled = on;
    notifyListeners();
    onPlaceNameLookupChanged?.call();
    await _privacy.savePlaceNameLookup(on);
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
