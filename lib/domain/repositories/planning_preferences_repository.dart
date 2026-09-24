import '../models/planning_preferences.dart';
import 'storage_failure.dart';

/// Persistence for the user's [PlanningPreferences] (TASK 5.2).
///
/// Every method throws [StorageFailure] when the store cannot be read or
/// written (TASK 15.1).
abstract class PlanningPreferencesRepository {
  /// The saved preferences, or the documented defaults when nothing is saved.
  Future<PlanningPreferences> load();

  Future<void> save(PlanningPreferences preferences);
}
