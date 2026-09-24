import 'package:flutter/foundation.dart';

import '../../core/diagnostics/app_log.dart';
import '../../core/time/clock.dart';
import '../../domain/models/altitude_curve.dart';
import '../../domain/models/capture_block.dart';
import '../../domain/models/execution.dart';
import '../../domain/models/night_timeline.dart';
import '../../domain/models/session.dart';
import '../../domain/repositories/display_preferences_repository.dart';
import '../../domain/repositories/session_repository.dart';
import '../../domain/services/execution_machine.dart';
import '../../domain/services/execution_outlook.dart';
import '../../domain/services/moon_calculator.dart';
import '../../domain/services/screen_wake.dart';
import '../../domain/services/visibility_calculator.dart';

/// The tracking screen's state (ADR-016; TASK 13.3). The run is always
/// re-read from its stored events — nothing here survives a restart except
/// through the database. Night, target and Moon come from the
/// execution-start snapshot, never from the planner's live state.
class ExecutionViewModel extends ChangeNotifier {
  ExecutionViewModel(this._sessions, this._clock, this._display, this._wake);

  final SessionRepository _sessions;
  final Clock _clock;
  final DisplayPreferencesRepository _display;
  final ScreenWake _wake;

  Session? _session;
  ExecutionState? _state;
  NightTimeline? _timeline;
  AltitudeCurve? _curve;
  MoonRiseSet? _moon;
  bool _keepScreenOn = false;
  bool _visible = false;

  /// The session in progress (or just finished), if any.
  Session? get session => _session;
  ExecutionState? get state => _state;
  bool get keepScreenOn => _keepScreenOn;
  DateTime get nowUtc => _clock.nowUtc();

  /// A run is loaded and still running or paused.
  bool get isActive => _state?.isActive ?? false;

  /// Loads the session in progress, if any (at start and after Start).
  Future<void> loadActive() async {
    try {
      _keepScreenOn = await _display.loadKeepScreenOn();
    } catch (e) {
      _keepScreenOn = false; // off, the default
      AppLog.warning('display', 'Keep-screen-on setting unreadable', error: e);
    }
    final s = await _sessions.inProgress();
    if (s == null) {
      _session = null;
      _state = null;
      notifyListeners();
      return;
    }
    await open(s.id);
  }

  /// Opens session [id]'s run and computes its night once.
  Future<void> open(int id) async {
    final s = await _sessions.get(id);
    _session = s;
    _state = s == null ? null : await _sessions.execution(id);
    final snapshot = s?.executionStartSnapshot;
    final night = snapshot?.night;
    final target = snapshot?.target;
    _timeline = night == null
        ? null
        : VisibilityCalculator.calculateNightTimelineForNight(night);
    _curve = night == null || target == null
        ? null
        : VisibilityCalculator.calculateAltitudeCurve(
            night: night,
            target: target,
          );
    _moon = night == null
        ? null
        : MoonCalculator.conditionsForNight(night).riseSet;
    await _syncWake();
    notifyListeners();
  }

  /// The current block, or null.
  CaptureBlock? get block {
    final id = _state?.blockId;
    for (final b in _session?.blocks ?? const <CaptureBlock>[]) {
      if (b.id == id) return b;
    }
    return null;
  }

  double? get _overhead =>
      _session?.executionStartSnapshot?.perFrameOverheadSeconds;

  /// Frames probably taken and not reported yet (CALC-35); null when the
  /// block or the overhead is unknown.
  FrameEstimate? get estimate {
    final b = block, s = _state, overhead = _overhead;
    if (b == null || s == null || overhead == null) return null;
    return ExecutionMachine.estimate(
      s,
      nowUtc,
      exposureSeconds: b.exposureTimeSeconds,
      perFrameOverheadSeconds: overhead,
      plannedFrames: b.frameCount,
    );
  }

  Duration get runningTime => _state == null
      ? Duration.zero
      : ExecutionMachine.runningTime(_state!, nowUtc);

  bool get clockBehind =>
      _state != null && ExecutionMachine.clockBehind(_state!, nowUtc);

  bool get stale => ExecutionMachine.isStale(
    _session?.executionStartSnapshot?.nightEndUtc,
    nowUtc,
  );

  /// Countdowns and remaining window vs plan (CALC-36).
  ExecutionOutlook? get outlook {
    final s = _state, session = _session;
    if (s == null || session == null) return null;
    final snapshot = session.executionStartSnapshot;
    return ExecutionOutlook.compute(
      nowUtc: nowUtc,
      blocks: session.blocks,
      state: s,
      perFrameOverheadSeconds: _overhead ?? 0,
      windows: snapshot?.windows ?? const [],
      timeline: _timeline,
      curve: _curve,
      minAltitudeDeg: snapshot?.minAltitudeDeg,
      moon: _moon,
    );
  }

  // Actions -------------------------------------------------------------------

  Future<void> confirm(int delta) => _record(
    ExecutionEventKind.framesConfirmed,
    blockId: block?.id,
    delta: delta,
  );

  Future<void> reject() =>
      _record(ExecutionEventKind.framesRejected, blockId: block?.id, delta: 1);

  /// Stores the current estimate as confirmed frames (ADR-016 §3).
  Future<void> acceptEstimate() async {
    final n = estimate?.frames ?? 0;
    if (n > 0) await confirm(n);
  }

  Future<void> pause([InterruptionReason? reason]) => _record(
    reason == null ? ExecutionEventKind.paused : ExecutionEventKind.interrupted,
    reason: reason,
  );

  Future<void> resume() => _record(ExecutionEventKind.resumed);

  Future<void> selectBlock(int id) =>
      _record(ExecutionEventKind.blockSelected, blockId: id);

  Future<void> abandon() => _end(() => _sessions.abandon(_session!.id));

  Future<void> setKeepScreenOn(bool on) async {
    _keepScreenOn = on;
    notifyListeners();
    await _display.saveKeepScreenOn(on);
    await _syncWake();
  }

  /// The tracking screen is shown or left: the wakelock follows it.
  Future<void> setVisible(bool visible) async {
    _visible = visible;
    await _syncWake();
  }

  Future<void> _record(
    ExecutionEventKind kind, {
    int? blockId,
    int? delta,
    InterruptionReason? reason,
  }) async {
    final s = _session;
    if (s == null) return;
    _state = await _sessions.record(
      s.id,
      kind,
      blockId: blockId,
      delta: delta,
      reason: reason,
    );
    await _syncWake();
    notifyListeners();
  }

  Future<void> _end(Future<Session> Function() end) async {
    if (_session == null) return;
    final ended = await end();
    await open(ended.id);
  }

  Future<void> _syncWake() =>
      _wake.keepOn(_visible && _keepScreenOn && isActive);
}
