import 'dart:isolate';

import '../../domain/repositories/target_repository.dart';
import '../../domain/services/candidate_evaluator.dart';
import 'night_conditions_viewmodel.dart';
import 'session_plan_viewmodel.dart';
import 'settings_viewmodel.dart';
import 'site_viewmodel.dart';

/// "What can I image tonight?" (TASK 10.4; split out of
/// `NightConditionsViewModel` in S6.5, which needed the room): every target
/// evaluated like the planner's `imagingOpportunity`, with the same night,
/// preferences, forecast and sky, on a background isolate. Holds no state;
/// the candidates screen keeps the result.
class CandidatesViewModel {
  CandidatesViewModel({
    required this._site,
    required this._plan,
    required this._settings,
    required this._conditions,
    required this._targets,
  });

  final SiteViewModel _site;
  final SessionPlanViewModel _plan;
  final SettingsViewModel _settings;
  final NightConditionsViewModel _conditions;
  final TargetRepository _targets;

  /// Every target for the plan's night; null without a night.
  Future<List<TonightCandidate>?> tonightCandidates() async {
    final night = _plan.sessionNight;
    if (night == null) return null;
    final targets = await _targets.getAllTargets();
    final prefs = _settings.planningPreferences;
    final weather = _conditions.opportunityWeather;
    final sky = _site.skyDarkness;
    final rig = _plan.selectedEquipment;
    // Only plain values cross into the isolate (never `this`).
    return Isolate.run(
      () => CandidateEvaluator.evaluate(
        night: night,
        targets: targets,
        darknessLimitDeg: prefs.darknessLimit.degrees,
        minAltitudeDeg: prefs.minAltitudeDeg,
        gates: prefs.optionalGates,
        weather: weather,
        skyDarkness: sky,
        equipment: rig,
        npfK: prefs.npfK,
      ),
    );
  }
}
