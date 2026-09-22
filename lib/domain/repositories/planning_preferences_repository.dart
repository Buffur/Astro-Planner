import '../models/planning_preferences.dart';

/// Persistence for the user's [PlanningPreferences] (TASK 5.2).
abstract class PlanningPreferencesRepository {
  /// The saved preferences, or the documented defaults when nothing is saved.
  Future<PlanningPreferences> load();

  Future<void> save(PlanningPreferences preferences);
}
