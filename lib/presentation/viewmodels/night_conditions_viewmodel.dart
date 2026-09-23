import 'dart:async';
import 'dart:isolate';

import 'package:flutter/foundation.dart';
import 'package:flutter/scheduler.dart';

import '../../core/time/clock.dart';
import '../../domain/models/imaging_opportunity.dart';
import '../../domain/models/moon_conditions.dart';
import '../../domain/models/night_timeline.dart';
import '../../domain/models/night_weather.dart';
import '../../domain/models/night_weather_summary.dart';
import '../../domain/models/visibility_window.dart';
import '../../domain/repositories/target_repository.dart';
import '../../domain/services/candidate_evaluator.dart';
import '../../domain/services/imaging_opportunity_calculator.dart';
import '../../domain/services/moon_calculator.dart';
import '../../domain/services/night_weather_service.dart';
import '../../domain/services/night_weather_summarizer.dart';
import '../../domain/services/visibility_calculator.dart';
import 'session_plan_viewmodel.dart';
import 'settings_viewmodel.dart';
import 'site_viewmodel.dart';

/// Tonight's conditions for the plan (split out of the planner ViewModel in
/// TASK 12.3): the night timeline, the forecast (ADR-012), the Moon, the
/// imaging opportunity (ADR-013) and tonight's candidates. The forecast
/// reloads whenever the night or the site changes.
class NightConditionsViewModel extends ChangeNotifier {
  NightConditionsViewModel({
    required this._site,
    required this._plan,
    required this._settings,
    required this._weatherService,
    required this._targetRepository,
    required this._clock,
  }) {
    for (final source in [_site, _plan, _settings]) {
      source.addListener(_onInputsChanged);
    }
  }

  final SiteViewModel _site;
  final SessionPlanViewModel _plan;
  final SettingsViewModel _settings;
  final NightWeatherService _weatherService;
  final TargetRepository _targetRepository;
  final Clock _clock;

  NightWeather _nightWeather = const NightWeatherIdle();
  int _weatherRequest = 0;
  Future<void> _weatherLoad = Future.value();
  bool _active = false;
  Object? _weatherKey;

  /// The chosen night's forecast state (TASK 9.3); idle without a site.
  NightWeather get nightWeather => _nightWeather;

  /// Completes when the latest forecast load has finished.
  Future<void> get idle => _weatherLoad;

  /// "Now" from the injected clock (the chart's current-time marker).
  DateTime get nowUtc => _clock.nowUtc();

  /// Starts following the night: records it now and loads its forecast
  /// after the first frame — weather never holds up the first screen.
  void begin() {
    _active = true;
    _weatherKey = _currentWeatherKey();
    SchedulerBinding.instance.addPostFrameCallback((_) {
      unawaited(_loadWeather());
    });
  }

  Object? _currentWeatherKey() {
    final night = _plan.sessionNight;
    return night == null ? null : (night, _site.latitude, _site.longitude);
  }

  void _onInputsChanged() {
    notifyListeners();
    final key = _currentWeatherKey();
    if (!_active || key == _weatherKey) return;
    _weatherKey = key;
    unawaited(_loadWeather());
  }

  Future<void> refreshWeather() => _loadWeather(forceRefresh: true);

  /// Loads the night's forecast (cache → fetch → typed states, TASK 9.3); a
  /// slow answer for a previous site or night is dropped.
  Future<void> _loadWeather({bool forceRefresh = false}) =>
      _weatherLoad = () async {
        final night = _plan.sessionNight;
        final request = ++_weatherRequest;
        if (night == null) {
          _nightWeather = const NightWeatherIdle();
          notifyListeners();
          return;
        }
        _nightWeather = const NightWeatherLoading();
        notifyListeners();
        final result = await _weatherService.load(
          night,
          latitude: _site.latitude,
          longitude: _site.longitude,
          forceRefresh: forceRefresh,
        );
        if (request != _weatherRequest) return;
        _nightWeather = result;
        notifyListeners();
      }();

  /// The Sun's dusk/dawn timeline, or null without a site (ADR-007 §8-§9).
  NightTimeline? get nightTimeline {
    final night = _plan.sessionNight;
    return night == null
        ? null
        : VisibilityCalculator.calculateNightTimelineForNight(night);
  }

  /// The forecast from sunset to sunrise with the dew heuristic (TASK 9.4);
  /// null unless a forecast is available.
  NightWeatherSummary? get nightWeatherSummary {
    final weather = _nightWeather;
    final timeline = nightTimeline;
    if (weather is! NightWeatherAvailable || timeline == null) return null;
    final span = NightWeatherSummarizer.spanOf(timeline);
    return NightWeatherSummarizer.summarize(
      weather.snapshot,
      fromUtc: span.fromUtc,
      toUtc: span.toUtc,
      span: span.span,
      dewMarginC: _settings.planningPreferences.dewMarginC,
    );
  }

  /// Moon context for the night and target (TASK 6.4), cached per input.
  MoonConditions? get moonConditions {
    final night = _plan.sessionNight;
    if (night == null) return null;
    final target = _plan.selectedTarget;
    final key = (night, target?.rightAscension, target?.declination);
    if (_moonKey != key) {
      _moon = MoonCalculator.conditionsForNight(night, target: target);
      _moonKey = key;
    }
    return _moon;
  }

  Object? _moonKey;
  MoonConditions? _moon;

  double? get lunarIllumination => moonConditions?.illuminationAtMidnight;

  OpportunityWeather? _opportunityWeather() {
    final weather = _nightWeather;
    return weather is NightWeatherAvailable
        ? OpportunityWeather(
            snapshot: weather.snapshot,
            age: weather.age,
            dewMarginC: _settings.planningPreferences.dewMarginC,
          )
        : null;
  }

  /// When and why the target can be imaged tonight (ADR-013, TASK 10.2):
  /// null without a night or target; cached per input.
  ImagingOpportunity? get imagingOpportunity {
    final night = _plan.sessionNight;
    final target = _plan.selectedTarget;
    if (night == null || target == null) return null;
    final prefs = _settings.planningPreferences;
    final key = (
      night,
      target.rightAscension,
      target.declination,
      prefs,
      _nightWeather,
      _site.activeSite,
      _site.bortleClass,
    );
    if (_opportunityKey != key) {
      if (_sunTrack?.night != night) _sunTrack = SunTrack.forNight(night);
      _opportunity = ImagingOpportunityCalculator.calculate(
        night: night,
        target: target,
        darknessLimitDeg: prefs.darknessLimit.degrees,
        minAltitudeDeg: prefs.minAltitudeDeg,
        sunTrack: _sunTrack,
        gates: prefs.optionalGates,
        moon: moonConditions,
        weather: _opportunityWeather(),
        skyDarkness: _site.skyDarkness,
      );
      _opportunityKey = key;
    }
    return _opportunity;
  }

  Object? _opportunityKey;
  ImagingOpportunity? _opportunity;
  SunTrack? _sunTrack;

  /// The opportunity's windows — the budget fit's input (TASK 10.2).
  List<VisibilityWindow> get visibilityWindows =>
      imagingOpportunity?.visibilityWindows ?? const [];

  /// Every target evaluated like [imagingOpportunity] (TASK 10.4), on a
  /// background isolate; null without a night.
  Future<List<TonightCandidate>?> tonightCandidates() async {
    final night = _plan.sessionNight;
    if (night == null) return null;
    final targets = await _targetRepository.getAllTargets();
    final prefs = _settings.planningPreferences;
    final weather = _opportunityWeather();
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

  /// The target's altitude now; null without a target or a real site.
  double? get currentAltitude {
    final target = _plan.selectedTarget;
    if (target == null || _site.isDefaultLocation) return null;
    return VisibilityCalculator.calculateTargetAltitude(
      target,
      _clock.nowUtc(),
      _site.latitude,
      _site.longitude,
    );
  }

  @override
  void dispose() {
    for (final source in [_site, _plan, _settings]) {
      source.removeListener(_onInputsChanged);
    }
    super.dispose();
  }
}
