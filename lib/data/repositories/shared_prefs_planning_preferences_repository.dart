import 'package:shared_preferences/shared_preferences.dart';

import '../../domain/models/planning_preferences.dart';
import '../../domain/repositories/planning_preferences_repository.dart';
import 'storage_guard.dart';

/// [PlanningPreferencesRepository] backed by SharedPreferences.
///
/// `minAltitude` and `dewPointThreshold` are the keys the ViewModel used
/// before TASK 5.2, kept so saved values survive. An optional overhead that
/// is off is stored as an absent key.
class SharedPrefsPlanningPreferencesRepository
    implements PlanningPreferencesRepository {
  static const _minAltitude = 'minAltitude';
  static const _dewMargin = 'dewPointThreshold';
  static const _darknessLimit = 'darknessLimitDeg';
  static const _margin = 'feasibilityMarginPercent';
  static const _perFrame = 'perFrameOverheadSeconds';
  static const _ditherEvery = 'ditherEveryNFrames';
  static const _ditherSettle = 'ditherSettleSeconds';
  static const _refocusEvery = 'refocusEveryMinutes';
  static const _refocus = 'refocusSeconds';
  static const _filterChange = 'filterChangeSeconds';
  static const _flip = 'meridianFlipSeconds';
  static const _setup = 'setupMinutes';
  static const _npfK = 'npfK';
  static const _moonGate = 'moonGateEnabled';
  static const _moonGatePct = 'moonGateMinIlluminationPct';
  static const _cloudGate = 'cloudGateEnabled';
  static const _cloudGatePct = 'cloudGateMaxPct';

  @override
  Future<PlanningPreferences> load() =>
      guardStorage('read the planning preferences', _load);

  Future<PlanningPreferences> _load() async {
    final p = await SharedPreferences.getInstance();
    return PlanningPreferences(
      minAltitudeDeg:
          p.getDouble(_minAltitude) ??
          PlanningPreferences.defaultMinAltitudeDeg,
      darknessLimit: DarknessLimit.fromDegrees(p.getDouble(_darknessLimit)),
      feasibilityMarginPercent:
          p.getDouble(_margin) ??
          PlanningPreferences.defaultFeasibilityMarginPercent,
      dewMarginC:
          p.getDouble(_dewMargin) ?? PlanningPreferences.defaultDewMarginC,
      perFrameOverheadSeconds:
          p.getDouble(_perFrame) ??
          PlanningPreferences.defaultPerFrameOverheadSeconds,
      ditherEveryNFrames: p.getInt(_ditherEvery),
      ditherSettleSeconds:
          p.getDouble(_ditherSettle) ??
          PlanningPreferences.defaultDitherSettleSeconds,
      refocusEveryMinutes: p.getDouble(_refocusEvery),
      refocusSeconds:
          p.getDouble(_refocus) ?? PlanningPreferences.defaultRefocusSeconds,
      filterChangeSeconds: p.getDouble(_filterChange),
      meridianFlipSeconds: p.getDouble(_flip),
      setupMinutes: p.getDouble(_setup),
      npfK: p.getDouble(_npfK) ?? PlanningPreferences.defaultNpfK,
      moonGateEnabled: p.getBool(_moonGate) ?? false,
      moonGateMinIlluminationPct:
          p.getDouble(_moonGatePct) ?? PlanningPreferences.defaultGatePct,
      cloudGateEnabled: p.getBool(_cloudGate) ?? false,
      cloudGateMaxPct:
          p.getDouble(_cloudGatePct) ?? PlanningPreferences.defaultGatePct,
    );
  }

  @override
  Future<void> save(PlanningPreferences preferences) =>
      guardStorage('save the planning preferences', () => _save(preferences));

  Future<void> _save(PlanningPreferences preferences) async {
    final p = await SharedPreferences.getInstance();
    await p.setDouble(_minAltitude, preferences.minAltitudeDeg);
    await p.setDouble(_darknessLimit, preferences.darknessLimit.degrees);
    await p.setDouble(_margin, preferences.feasibilityMarginPercent);
    await p.setDouble(_dewMargin, preferences.dewMarginC);
    await p.setDouble(_perFrame, preferences.perFrameOverheadSeconds);
    await p.setDouble(_ditherSettle, preferences.ditherSettleSeconds);
    await p.setDouble(_refocus, preferences.refocusSeconds);
    await p.setDouble(_npfK, preferences.npfK);
    await p.setBool(_moonGate, preferences.moonGateEnabled);
    await p.setDouble(_moonGatePct, preferences.moonGateMinIlluminationPct);
    await p.setBool(_cloudGate, preferences.cloudGateEnabled);
    await p.setDouble(_cloudGatePct, preferences.cloudGateMaxPct);
    await _setOrRemoveInt(p, _ditherEvery, preferences.ditherEveryNFrames);
    await _setOrRemove(p, _refocusEvery, preferences.refocusEveryMinutes);
    await _setOrRemove(p, _filterChange, preferences.filterChangeSeconds);
    await _setOrRemove(p, _flip, preferences.meridianFlipSeconds);
    await _setOrRemove(p, _setup, preferences.setupMinutes);
  }

  static Future<void> _setOrRemove(
    SharedPreferences p,
    String key,
    double? value,
  ) => value == null ? p.remove(key) : p.setDouble(key, value);

  static Future<void> _setOrRemoveInt(
    SharedPreferences p,
    String key,
    int? value,
  ) => value == null ? p.remove(key) : p.setInt(key, value);
}
