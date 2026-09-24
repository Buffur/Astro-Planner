import 'package:flutter/foundation.dart';

import '../../core/time/clock.dart';
import '../../domain/models/capture_block.dart';
import '../../domain/models/imaging_opportunity.dart';
import '../../domain/models/session.dart';
import '../../domain/models/session_snapshot.dart';
import '../../domain/services/capability_calculator.dart';
import '../../domain/services/capture_budget_calculator.dart';
import '../../domain/services/fit_analyzer.dart';
import '../../domain/services/optical_calculator.dart';
import '../../domain/services/session_snapshot_builder.dart';
import '../../domain/services/visibility_calculator.dart';
import 'night_conditions_viewmodel.dart';
import 'session_plan_viewmodel.dart';
import 'settings_viewmodel.dart';
import 'site_viewmodel.dart';

/// What the plan needs and whether it fits tonight (split out of the planner
/// ViewModel in TASK 12.3): the capture budget (ADR-009), the fit (TASK
/// 5.5), the rig's capability (TASK 8.6) — all computed by domain services
/// — and Save with its snapshot (ADR-014).
///
/// The budget, the fit and the fill count are cached until an input
/// notifies or the night changes (TASK 15.2): widgets read them several
/// times per frame and the fit is the costliest planner calculation.
class CaptureAnalysisViewModel extends ChangeNotifier {
  CaptureAnalysisViewModel({
    required this._site,
    required this._plan,
    required this._settings,
    required this._conditions,
    required this._clock,
  }) {
    for (final source in [_plan, _settings, _conditions]) {
      source.addListener(_onInputsChanged);
    }
  }

  final SiteViewModel _site;
  final SessionPlanViewModel _plan;
  final SettingsViewModel _settings;
  final NightConditionsViewModel _conditions;
  final Clock _clock;

  /// Bumped on every input change; the cache below is valid for one
  /// generation and one night.
  int _generation = 0;
  Object? _cacheKey;
  CaptureBudget? _budget;
  FitResult? _fit;
  (int?,)? _fillCount;

  void _onInputsChanged() {
    _generation++;
    notifyListeners();
  }

  /// Clears the cache when the inputs or the night changed since it was
  /// filled; the night can roll over with the clock alone.
  void _validateCache() {
    final key = (_generation, _plan.sessionNight);
    if (_cacheKey == key) return;
    _cacheKey = key;
    _budget = null;
    _fit = null;
    _fillCount = null;
  }

  /// The capture budget of the plan (ADR-009, TASK 5.4).
  CaptureBudget get captureBudget {
    _validateCache();
    return _budget ??= _computeBudget();
  }

  CaptureBudget _computeBudget() {
    final overheads = CaptureOverheads.fromPreferences(
      _settings.planningPreferences,
    );
    final transit = overheads.meridianFlipMs == null ? null : _transitUtc;
    return CaptureBudgetCalculator.calculate(
      blocks: _plan.captureBlocks,
      overheads: overheads,
      targetTransitsInWindow:
          transit != null &&
          _conditions.visibilityWindows.any(
            (w) => !transit.isBefore(w.start) && transit.isBefore(w.end),
          ),
      averageRawFileSizeMB: _plan.selectedEquipment?.averageRawFileSizeMB,
    );
  }

  /// The target's upper transit tonight, or null (5-minute resolution);
  /// cached per night and target position.
  DateTime? get _transitUtc {
    final night = _plan.sessionNight;
    final target = _plan.selectedTarget;
    if (night == null || target == null) return null;
    final key = (night, target.rightAscension, target.declination);
    if (_transitKey != key) {
      _transit = CaptureBudgetCalculator.transitInstant(
        VisibilityCalculator.calculateAltitudeCurve(
          night: night,
          target: target,
        ),
      );
      _transitKey = key;
    }
    return _transit;
  }

  Object? _transitKey;
  DateTime? _transit;

  /// Light-frame integration, "Xh Ym".
  String get totalIntegrationTime {
    final minutes = captureBudget.integration.inMinutes;
    return '${minutes ~/ 60}h ${minutes % 60}m';
  }

  /// The window load (ADR-009 §2): acquisition plus in-window calibration.
  Duration get estimatedRequiredTime => captureBudget.windowLoad;

  /// Whether and how the plan fits tonight's windows (TASK 5.5).
  FitResult get fitAnalysis {
    _validateCache();
    return _fit ??= _computeFit();
  }

  FitResult _computeFit() {
    final budget = captureBudget;
    final prefs = _settings.planningPreferences;
    final String noWindowReason;
    if (_plan.sessionNight == null) {
      noWindowReason = "Choose a location to see tonight's windows.";
    } else if (_plan.selectedTarget == null) {
      noWindowReason = "Choose a target to see tonight's windows.";
    } else if (_conditions.imagingOpportunity?.noWindowReason ==
        NoWindowReason.excludedByOptionalGates) {
      noWindowReason =
          'No usable window: your Moon or cloud gate excludes all of '
          "tonight's dark time with the target high enough.";
    } else {
      noWindowReason = FitAnalyzer.noWindowReason(
        timeline: _conditions.nightTimeline!,
        darknessLimitDeg: prefs.darknessLimit.degrees,
        minAltitudeDeg: prefs.minAltitudeDeg,
      );
    }
    return FitAnalyzer.analyze(
      budget: budget,
      windows: _conditions.visibilityWindows,
      marginFraction: prefs.feasibilityMarginFraction,
      transitUtc: budget.countOf(BudgetEventKind.meridianFlip) > 0
          ? _transitUtc
          : null,
      noWindowReason: noWindowReason,
    );
  }

  /// The light block "Fill tonight's window" adjusts: the last one.
  int? get fillWindowBlockIndex {
    final blocks = _plan.captureBlocks;
    for (var i = blocks.length - 1; i >= 0; i--) {
      if (blocks[i].frameType == FrameType.light) return i;
    }
    return null;
  }

  /// The frame count for [fillWindowBlockIndex] that fills tonight's windows
  /// (TASK 5.6); null without a light block, 0 when none fits.
  int? get fillWindowFrameCount {
    _validateCache();
    return (_fillCount ??= (_computeFillCount(),)).$1;
  }

  int? _computeFillCount() {
    final index = fillWindowBlockIndex;
    if (index == null) return null;
    final flip = captureBudget.countOf(BudgetEventKind.meridianFlip) > 0;
    return FitAnalyzer.maxFramesForBlock(
      blocks: _plan.captureBlocks,
      blockIndex: index,
      windows: _conditions.visibilityWindows,
      overheads: CaptureOverheads.fromPreferences(
        _settings.planningPreferences,
      ),
      targetTransitsInWindow: flip,
      transitUtc: flip ? _transitUtc : null,
    );
  }

  /// Applies [fillWindowFrameCount]; false (no change) when nothing fits.
  Future<bool> fillWindow() async {
    final index = fillWindowBlockIndex;
    final count = fillWindowFrameCount;
    if (index == null || count == null || count < 1) return false;
    await _plan.updateCaptureBlock(
      index,
      _plan.captureBlocks[index].copyWith(frameCount: count),
    );
    return true;
  }

  /// Storage for every frame taken; null when the file size is unknown.
  double? get estimatedStorageMB => captureBudget.storageMB;

  /// √N of light frames — a relative stacking gain, not an SNR (SI-003).
  double get relativeStackingGain =>
      OpticalCalculator.calculateRelativeStackingGain(
        captureBudget.lightFrameCount,
      );

  double? get pixelScale {
    final rig = _plan.selectedEquipment;
    if (rig == null) return null;
    return OpticalCalculator.calculatePixelScale(
      pixelPitch: rig.pixelPitchUm,
      effectiveFocalLength: OpticalCalculator.calculateEffectiveFocalLength(
        focalLength: rig.focalLengthMm,
      ),
    );
  }

  /// The rig's capability and exposure guidance (TASK 8.6, PD-11).
  RigCapability? get rigCapability {
    final rig = _plan.selectedEquipment;
    if (rig == null) return null;
    return CapabilityCalculator.evaluate(
      rig,
      target: _plan.selectedTarget,
      npfK: _settings.planningPreferences.npfK,
    );
  }

  /// Save (ADR-014 §3–§4): the plan becomes a planned session with a fresh
  /// snapshot of its whole context.
  Future<Session> saveSession() => _plan.savePlan(_snapshot());

  /// Start (ADR-016; owner: same requirements as Save): the session starts
  /// with its execution-start snapshot; the planner goes on with a copy.
  /// Refused while another session is in progress (SessionStateError).
  Future<Session> startSession() => _plan.startPlan(_snapshot());

  SessionSnapshot _snapshot() {
    final night = _plan.sessionNight;
    if (night == null) {
      throw StateError('Saving needs a site, a target and a rig.');
    }
    return SessionSnapshotBuilder.build(
      takenAtUtc: _clock.nowUtc(),
      night: night,
      timeZoneId: _site.displayZoneId,
      preferences: _settings.planningPreferences,
      budget: captureBudget,
      blocks: _plan.captureBlocks,
      site: _site.activeSite,
      skyDarkness: _site.skyDarkness,
      target: _plan.selectedTarget,
      rig: _plan.selectedEquipment,
      opportunity: _conditions.imagingOpportunity,
      weather: _conditions.nightWeather,
      weatherSummary: _conditions.nightWeatherSummary,
    );
  }

  @override
  void dispose() {
    for (final source in [_plan, _settings, _conditions]) {
      source.removeListener(_onInputsChanged);
    }
    super.dispose();
  }
}
