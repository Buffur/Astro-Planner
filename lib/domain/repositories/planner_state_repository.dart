import '../models/capture_block.dart';

/// Persistence for the planner's current selections: the active saved
/// location, the selected target and rig, and the working capture plan
/// (TASK 5.2). Keeps storage details out of the ViewModel.
abstract class PlannerStateRepository {
  Future<int?> getActiveLocationId();
  Future<void> setActiveLocationId(int id);

  Future<int?> getSelectedTargetId();
  Future<void> setSelectedTargetId(int id);

  Future<int?> getSelectedEquipmentId();
  Future<void> setSelectedEquipmentId(int id);

  /// The saved working plan, or null when none is saved. Throws if the saved
  /// plan cannot be read.
  Future<List<CaptureBlock>?> loadCaptureBlocks();
  Future<void> saveCaptureBlocks(List<CaptureBlock> blocks);
}
