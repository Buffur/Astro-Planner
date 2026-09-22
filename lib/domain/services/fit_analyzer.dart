import '../models/capture_block.dart';
import '../models/night_timeline.dart';
import '../models/visibility_window.dart';
import 'capture_budget_calculator.dart';

/// The answer to "does this plan fit tonight?" (ADR-009 §6).
enum FitState {
  /// There is no usable window tonight.
  noWindow,

  /// The plan has no light frames, so there is nothing to fit.
  nothingToFit,

  /// Some events could not be placed.
  doesNotFit,

  /// Everything was placed, but less than the margin is left free.
  tight,

  /// Everything was placed with at least the margin left free.
  fits,
}

/// The result of placing a plan's in-window event sequence into the night's
/// windows (ADR-009 §6, CALC-26). Durations are integer milliseconds.
class FitResult {
  const FitResult({
    required this.state,
    required this.reason,
    required this.availableMs,
    required this.windowLoadMs,
    required this.placedMs,
    required this.endUtc,
    required this.lostTailsMs,
    required this.unplacedFramesByBlock,
    required this.flipApplied,
    required this.flipDropped,
    required this.nightsNeeded,
  });

  final FitState state;

  /// A human-readable explanation; always present.
  final String reason;

  /// Σ window durations.
  final int availableMs;

  /// The plan's window load (ADR-009 §2).
  final int windowLoadMs;

  /// Σ durations of the events actually placed.
  final int placedMs;

  /// When the last placed event ends; null if nothing was placed.
  final DateTime? endUtc;

  /// Remainders of windows too short for the next event, in order.
  final List<int> lostTailsMs;

  /// Frames that could not be placed, by block index.
  final Map<int, int> unplacedFramesByBlock;

  /// The meridian flip was placed at the first boundary at/after transit.
  final bool flipApplied;

  /// The flip was counted by the budget but not needed: the placed plan ends
  /// before the transit (ADR-009 §4).
  final bool flipDropped;

  /// For a plan that doesn't fit: about how many similar nights it needs
  /// (window load ÷ what one such night holds, rounded up). Null otherwise.
  final int? nightsNeeded;

  /// Window time left over, including lost tails.
  int get unusedMs => availableMs - placedMs;

  int get unplacedFrames =>
      unplacedFramesByBlock.values.fold(0, (s, n) => s + n);
}

/// Places the ADR-009 event sequence into windows (CALC-26). Pure.
class FitAnalyzer {
  const FitAnalyzer._();

  /// [budget]: from [CaptureBudgetCalculator.calculate].
  /// [windows]: sorted, non-overlapping UTC windows for one night.
  /// [marginFraction]: the share of [windows] that must stay free (default
  /// 0.15, a preference since TASK 5.2).
  /// [transitUtc]: the target's upper transit, needed only when the budget
  /// counted a meridian flip.
  /// [noWindowReason]: why [windows] is empty, from the night timeline.
  static FitResult analyze({
    required CaptureBudget budget,
    required List<VisibilityWindow> windows,
    double marginFraction = 0.15,
    DateTime? transitUtc,
    String noWindowReason = 'No usable window tonight.',
  }) {
    final margin = marginFraction.clamp(0.0, 0.5);
    final available = windows.fold(
      0,
      (s, w) => s + w.end.difference(w.start).inMilliseconds,
    );
    final load = budget.windowLoadMs;

    if (budget.lightFrameCount == 0) {
      return _result(
        FitState.nothingToFit,
        'The plan has no light frames, so there is nothing to fit.',
        available,
        load,
      );
    }
    if (windows.isEmpty) {
      return _result(FitState.noWindow, noWindowReason, available, load);
    }

    // The budget appends a counted flip at the end; the fit inserts it at
    // the first event boundary at or after the transit instead.
    final events = budget.sequence
        .where((e) => e.kind != BudgetEventKind.meridianFlip)
        .toList();
    final flipEvents = budget.sequence
        .where((e) => e.kind == BudgetEventKind.meridianFlip)
        .toList();
    BudgetEvent? pendingFlip = flipEvents.isEmpty ? null : flipEvents.first;
    if (pendingFlip != null && transitUtc == null) pendingFlip = null;

    var wi = 0;
    var t = windows.first.start;
    var placed = 0;
    DateTime? end;
    var flipApplied = false;
    final lost = <int>[];
    final unplaced = <int, int>{};

    // Places [d] ms; returns false when no window can hold it.
    bool place(int d) {
      while (wi < windows.length &&
          t.add(Duration(milliseconds: d)).isAfter(windows[wi].end)) {
        lost.add(windows[wi].end.difference(t).inMilliseconds);
        wi++;
        if (wi < windows.length) t = windows[wi].start;
      }
      if (wi >= windows.length) return false;
      t = t.add(Duration(milliseconds: d));
      placed += d;
      end = t;
      return true;
    }

    var outOfWindows = false;
    for (final e in events) {
      if (!outOfWindows &&
          pendingFlip != null &&
          !t.isBefore(transitUtc!) &&
          wi < windows.length) {
        if (place(pendingFlip.durationMs)) {
          flipApplied = true;
          pendingFlip = null;
        } else {
          outOfWindows = true;
        }
      }
      if (!outOfWindows && place(e.durationMs)) continue;
      outOfWindows = true;
      if (e.kind == BudgetEventKind.frame && e.blockIndex != null) {
        unplaced.update(e.blockIndex!, (n) => n + 1, ifAbsent: () => 1);
      }
    }
    final flipDropped = flipEvents.isNotEmpty && !flipApplied;

    if (unplaced.isNotEmpty) {
      final nights = placed > 0 ? (load / placed).ceil() : null;
      final n = unplaced.values.fold(0, (s, v) => s + v);
      final tails = lost.where((ms) => ms > 0).fold(0, (s, v) => s + v);
      final reason = StringBuffer(
        '$n frame${n == 1 ? '' : 's'} don\'t fit tonight',
      );
      if (tails > 0) {
        reason.write(
          '; ${_fmt(tails)} of window time is left in pieces too short '
          'for the next frame',
        );
      }
      if (nights != null && nights > 1) {
        reason.write('. About $nights similar nights are needed');
      }
      reason.write('.');
      return FitResult(
        state: FitState.doesNotFit,
        reason: reason.toString(),
        availableMs: available,
        windowLoadMs: load,
        placedMs: placed,
        endUtc: end,
        lostTailsMs: List.unmodifiable(lost),
        unplacedFramesByBlock: Map.unmodifiable(unplaced),
        flipApplied: flipApplied,
        flipDropped: flipDropped,
        nightsNeeded: nights,
      );
    }

    // Uses the time actually placed: a flip the budget counted but the fit
    // dropped (ADR-009 §4) does not eat into the margin.
    final tight = placed > (1 - margin) * available;
    final free = available - placed;
    final pct = (margin * 100).round();
    final flipNote = flipDropped
        ? ' The meridian flip is not needed: the plan ends before the '
              'target crosses the meridian.'
        : '';
    return FitResult(
      state: tight ? FitState.tight : FitState.fits,
      reason: tight
          ? 'Everything fits, but only ${_fmt(free)} of window time is left '
                '(less than your $pct % margin).$flipNote'
          : 'Everything fits with ${_fmt(free)} of window time to spare.'
                '$flipNote',
      availableMs: available,
      windowLoadMs: load,
      placedMs: placed,
      endUtc: end,
      lostTailsMs: List.unmodifiable(lost),
      unplacedFramesByBlock: const {},
      flipApplied: flipApplied,
      flipDropped: flipDropped,
      nightsNeeded: null,
    );
  }

  /// The inverse question (ADR-009 §6): the largest number of frames of
  /// [exposureSeconds] (as a single light block, with [overheads]) that can
  /// be **placed** in [windows] — margin not applied.
  static int maxPlaceableFrames({
    required double exposureSeconds,
    required List<VisibilityWindow> windows,
    CaptureOverheads overheads = const CaptureOverheads(),
  }) {
    if (windows.isEmpty) return 0;
    bool fits(int n) {
      if (n == 0) return true;
      final budget = CaptureBudgetCalculator.calculate(
        blocks: [
          CaptureBlock(
            frameType: FrameType.light,
            exposureTimeSeconds: exposureSeconds,
            frameCount: n,
          ),
        ],
        overheads: overheads,
      );
      return analyze(
            budget: budget,
            windows: windows,
            marginFraction: 0,
          ).state !=
          FitState.doesNotFit;
    }

    final unit = (exposureSeconds * 1000).round() + overheads.perFrameMs;
    final total = windows.fold(
      0,
      (s, w) => s + w.end.difference(w.start).inMilliseconds,
    );
    var lo = 0;
    var hi = (total ~/ unit).clamp(0, CaptureBlock.maxFrameCount);
    while (lo < hi) {
      final mid = (lo + hi + 1) ~/ 2;
      if (fits(mid)) {
        lo = mid;
      } else {
        hi = mid - 1;
      }
    }
    return lo;
  }

  /// Why there is no window tonight, from the night timeline: the Sun never
  /// reaches the darkness limit, or the target never climbs high enough
  /// while it is dark. Thresholds without a timeline entry (−15°) get the
  /// general wording.
  static String noWindowReason({
    required NightTimeline timeline,
    required double darknessLimitDeg,
    required double minAltitudeDeg,
  }) {
    final SunThresholdResult? atLimit = switch (darknessLimitDeg) {
      -18.0 => timeline.astronomicalTwilight,
      -12.0 => timeline.nauticalTwilight,
      _ => null,
    };
    final limit = darknessLimitDeg.round();
    if (atLimit is SunNeverBelow) {
      return 'No usable window: the Sun never gets below $limit° tonight.';
    }
    return 'No usable window: the target never rises above '
        '${minAltitudeDeg.round()}° while the Sun is below $limit°.';
  }

  static FitResult _result(
    FitState state,
    String reason,
    int available,
    int load,
  ) => FitResult(
    state: state,
    reason: reason,
    availableMs: available,
    windowLoadMs: load,
    placedMs: 0,
    endUtc: null,
    lostTailsMs: const [],
    unplacedFramesByBlock: const {},
    flipApplied: false,
    flipDropped: false,
    nightsNeeded: null,
  );

  static String _fmt(int ms) {
    final minutes = (ms / 60000).round();
    if (minutes < 60) return '$minutes min';
    return '${minutes ~/ 60} h ${minutes % 60} min';
  }
}
