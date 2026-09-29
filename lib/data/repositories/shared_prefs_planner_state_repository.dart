import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../../domain/models/capture_block.dart';
import '../../core/diagnostics/app_log.dart';
import '../../domain/repositories/planner_state_repository.dart';
import 'storage_guard.dart';

/// [PlannerStateRepository] backed by SharedPreferences.
///
/// Uses exactly the keys the ViewModel used before TASK 5.2, so existing
/// installs keep their state; the capture-plan JSON is versioned since
/// TASK 5.3 and the pre-5.3 shape is still read.
class SharedPrefsPlannerStateRepository implements PlannerStateRepository {
  static const _activeLocationId = activeLocationIdKey;
  static const _targetId = 'targetId';
  static const _equipmentId = 'equipmentId';
  static const _captureBlocks = 'captureBlocks';

  /// The active site's id: carried by a backup (S8.9, TD-056).
  static const activeLocationIdKey = 'activeLocationId';

  /// The ids of the plan being edited and its selection. They point into
  /// one database, so a restore or a reset clears them (S8.9, ENG-14).
  static const planIdKeys = {_targetId, _equipmentId, _editedSessionId};

  Future<SharedPreferences> get _prefs => SharedPreferences.getInstance();

  static const _read = 'read the planner state';
  static const _save = 'save the planner state';

  @override
  Future<int?> getActiveLocationId() =>
      guardStorage(_read, () async => (await _prefs).getInt(_activeLocationId));

  @override
  Future<void> setActiveLocationId(int id) => guardStorage(
    _save,
    () async => (await _prefs).setInt(_activeLocationId, id),
  );

  static const _transientLat = 'transientLatitude';
  static const _transientLon = 'transientLongitude';

  @override
  Future<void> clearActiveLocationId() =>
      guardStorage(_save, () async => (await _prefs).remove(_activeLocationId));

  @override
  Future<({double latitude, double longitude})?> getTransientPosition() =>
      guardStorage(_read, () async {
        final p = await _prefs;
        final lat = p.getDouble(_transientLat);
        final lon = p.getDouble(_transientLon);
        if (lat == null || lon == null) return null;
        return (latitude: lat, longitude: lon);
      });

  @override
  Future<void> setTransientPosition(double latitude, double longitude) =>
      guardStorage(_save, () async {
        final p = await _prefs;
        await p.setDouble(_transientLat, latitude);
        await p.setDouble(_transientLon, longitude);
      });

  static const _editedSessionId = 'editedSessionId';

  @override
  Future<int?> getEditedSessionId() =>
      guardStorage(_read, () async => (await _prefs).getInt(_editedSessionId));

  @override
  Future<void> setEditedSessionId(int? id) => guardStorage(_save, () async {
    final p = await _prefs;
    if (id == null) {
      await p.remove(_editedSessionId);
    } else {
      await p.setInt(_editedSessionId, id);
    }
  });

  @override
  Future<int?> getSelectedTargetId() =>
      guardStorage(_read, () async => (await _prefs).getInt(_targetId));

  @override
  Future<void> setSelectedTargetId(int id) =>
      guardStorage(_save, () async => (await _prefs).setInt(_targetId, id));

  @override
  Future<int?> getSelectedEquipmentId() =>
      guardStorage(_read, () async => (await _prefs).getInt(_equipmentId));

  @override
  Future<void> setSelectedEquipmentId(int id) =>
      guardStorage(_save, () async => (await _prefs).setInt(_equipmentId, id));

  /// Current plan JSON version (TASK 5.3): `{"version": 2, "blocks": [...]}`.
  /// Version 1 (before 5.3) was a bare list with a free-text `gainIso`; it
  /// is still read. The plan moves into the database in TASK 11.4.
  static const planJsonVersion = 2;

  @override
  Future<List<CaptureBlock>?> loadCaptureBlocks() =>
      guardStorage('read the saved plan', _loadCaptureBlocks);

  Future<List<CaptureBlock>?> _loadCaptureBlocks() async {
    final json = (await _prefs).getString(_captureBlocks);
    if (json == null) return null;
    final decoded = jsonDecode(json);
    final List<dynamic> list;
    final int version;
    if (decoded is List) {
      version = 1;
      list = decoded;
    } else if (decoded is Map && decoded['blocks'] is List) {
      version = (decoded['version'] as num?)?.toInt() ?? planJsonVersion;
      list = decoded['blocks'] as List;
    } else {
      throw const FormatException('Unrecognised capture-plan JSON');
    }
    final blocks = <CaptureBlock>[];
    for (final b in list.whereType<Map>()) {
      final block = _blockFromJson(b, version);
      if (block != null) blocks.add(block);
    }
    return blocks;
  }

  /// One block, or null (logged) when it is invalid — an invalid saved block
  /// must not discard the rest of the plan, nor exist in the domain.
  static CaptureBlock? _blockFromJson(Map b, int version) {
    final type = CaptureBlock.tryParseFrameType(b['frameType'] as String?);
    if (type == null) {
      AppLog.warning(
        'storage',
        'Skipping saved block: frame type ${b['frameType']}',
      );
      return null;
    }
    try {
      final CaptureGain gain;
      if (version >= 2) {
        gain = CaptureGain.fromStored(
          b['gainKind'] as String?,
          (b['gainValue'] as num?)?.toDouble(),
        );
      } else {
        // v1 free text: the kind can't be told, so it is never guessed.
        final legacy = double.tryParse('${b['gainIso'] ?? ''}'.trim());
        gain = legacy != null && legacy.isFinite && legacy >= 0
            ? CaptureGain.unknown(legacy)
            : CaptureGain.none;
      }
      return CaptureBlock(
        id: (b['id'] as num?)?.toInt() ?? 0,
        frameType: type,
        filterName: b['filterName'] as String?,
        exposureTimeSeconds:
            (b['exposureTimeSeconds'] as num?)?.toDouble() ?? 0.0,
        frameCount: (b['frameCount'] as num?)?.toInt() ?? 0,
        binning: (b['binning'] as num?)?.toInt() ?? 1,
        gain: gain,
        calibrationPolicy: type == FrameType.light
            ? null
            : CalibrationPolicy.tryParse(b['calibrationPolicy'] as String?),
      );
    } on ArgumentError catch (e) {
      AppLog.warning('storage', 'Skipping invalid saved block', error: e);
      return null;
    }
  }

  @override
  Future<void> saveCaptureBlocks(List<CaptureBlock> blocks) =>
      guardStorage('save the plan', () => _saveCaptureBlocks(blocks));

  Future<void> _saveCaptureBlocks(List<CaptureBlock> blocks) async {
    final list = blocks
        .map(
          (b) => {
            'id': b.id,
            'frameType': b.frameType.name,
            'filterName': b.filterName,
            'exposureTimeSeconds': b.exposureTimeSeconds,
            'frameCount': b.frameCount,
            'binning': b.binning,
            'gainKind': b.gain.kind.name,
            'gainValue': b.gain.value,
            'calibrationPolicy': b.calibrationPolicy?.name,
          },
        )
        .toList();
    await (await _prefs).setString(
      _captureBlocks,
      jsonEncode({'version': planJsonVersion, 'blocks': list}),
    );
  }

  @override
  Future<void> clearPlan() => guardStorage(_save, () async {
    final p = await _prefs;
    await p.remove(_captureBlocks);
    await p.remove(_targetId);
    await p.remove(_equipmentId);
  });
}
