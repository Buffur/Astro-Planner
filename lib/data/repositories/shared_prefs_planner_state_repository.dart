import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../../domain/models/capture_block.dart';
import '../../domain/repositories/planner_state_repository.dart';

/// [PlannerStateRepository] backed by SharedPreferences.
///
/// Uses exactly the keys and the capture-plan JSON shape the ViewModel used
/// before TASK 5.2, so existing installs keep their state.
class SharedPrefsPlannerStateRepository implements PlannerStateRepository {
  static const _activeLocationId = 'activeLocationId';
  static const _targetId = 'targetId';
  static const _equipmentId = 'equipmentId';
  static const _captureBlocks = 'captureBlocks';

  Future<SharedPreferences> get _prefs => SharedPreferences.getInstance();

  @override
  Future<int?> getActiveLocationId() async =>
      (await _prefs).getInt(_activeLocationId);

  @override
  Future<void> setActiveLocationId(int id) async =>
      (await _prefs).setInt(_activeLocationId, id);

  @override
  Future<int?> getSelectedTargetId() async => (await _prefs).getInt(_targetId);

  @override
  Future<void> setSelectedTargetId(int id) async =>
      (await _prefs).setInt(_targetId, id);

  @override
  Future<int?> getSelectedEquipmentId() async =>
      (await _prefs).getInt(_equipmentId);

  @override
  Future<void> setSelectedEquipmentId(int id) async =>
      (await _prefs).setInt(_equipmentId, id);

  @override
  Future<List<CaptureBlock>?> loadCaptureBlocks() async {
    final json = (await _prefs).getString(_captureBlocks);
    if (json == null) return null;
    final list = jsonDecode(json) as List;
    return list
        .map(
          (b) => CaptureBlock(
            id: b['id'] ?? 0,
            frameType: FrameType.values.firstWhere(
              (e) => e.name == b['frameType'],
              orElse: () => FrameType.light,
            ),
            filterName: b['filterName'],
            exposureTimeSeconds:
                (b['exposureTimeSeconds'] as num?)?.toDouble() ?? 0.0,
            frameCount: b['frameCount'] ?? 0,
            binning: b['binning'] ?? 1,
            gainIso: b['gainIso'],
          ),
        )
        .toList();
  }

  @override
  Future<void> saveCaptureBlocks(List<CaptureBlock> blocks) async {
    final list = blocks
        .map(
          (b) => {
            'id': b.id,
            'frameType': b.frameType.name,
            'filterName': b.filterName,
            'exposureTimeSeconds': b.exposureTimeSeconds,
            'frameCount': b.frameCount,
            'binning': b.binning,
            'gainIso': b.gainIso,
          },
        )
        .toList();
    await (await _prefs).setString(_captureBlocks, jsonEncode(list));
  }
}
