import '../models/capture_block.dart';
import 'storage_failure.dart';

/// Persistence for the planner's current selections: the active saved
/// location, the selected target and rig, and the working capture plan
/// (TASK 5.2). Keeps storage details out of the ViewModel.
///
/// Every method throws [StorageFailure] when the store cannot be read or
/// written (TASK 15.1).
abstract class PlannerStateRepository {
  Future<int?> getActiveLocationId();
  Future<void> setActiveLocationId(int id);

  /// Deselects the active saved site (TASK 7.1).
  Future<void> clearActiveLocationId();

  /// The transient current position (map pick or GPS), which is never
  /// written into a saved site (TASK 7.1). Degrees, north/east positive.
  Future<({double latitude, double longitude})?> getTransientPosition();
  Future<void> setTransientPosition(double latitude, double longitude);

  Future<int?> getSelectedTargetId();
  Future<void> setSelectedTargetId(int id);

  Future<int?> getSelectedEquipmentId();
  Future<void> setSelectedEquipmentId(int id);

  /// The saved working plan, or null when none is saved. Throws
  /// [StorageFailure] if the saved plan cannot be read.
  Future<List<CaptureBlock>?> loadCaptureBlocks();
  Future<void> saveCaptureBlocks(List<CaptureBlock> blocks);

  /// Removes the working plan and the selected target and rig ids after
  /// they moved into a draft session (TASK 11.4, ADR-014 §6). The site
  /// selection and the transient position stay (app-level, TASK 7.1).
  Future<void> clearPlan();

  /// The session holding plan edits that are not saved, or null (S1.V3):
  /// keeps the confirmation before New, Duplicate or Open (S1.6) across a
  /// restart. Local only.
  Future<int?> getEditedSessionId();
  Future<void> setEditedSessionId(int? id);
}
