import '../models/altitude_curve.dart';
import '../models/capture_block.dart';
import '../models/planning_preferences.dart';
import '../models/visibility_window.dart';

/// Capture overheads used by the budget (ADR-009 §4), in integer
/// milliseconds. A null optional overhead is **off** — "not included",
/// never a hidden zero (SI-008).
///
/// Every value is an **assumption — measure your rig**.
class CaptureOverheads {
  const CaptureOverheads({
    this.perFrameMs = 5000,
    this.ditherEveryNFrames,
    this.ditherMs = 15000,
    this.refocusEveryMs,
    this.refocusMs = 90000,
    this.filterChangeMs,
    this.meridianFlipMs,
    this.setupMs,
  });

  /// From the user's [PlanningPreferences] (TASK 5.2).
  factory CaptureOverheads.fromPreferences(PlanningPreferences p) =>
      CaptureOverheads(
        perFrameMs: _ms(p.perFrameOverheadSeconds),
        ditherEveryNFrames: p.ditherEveryNFrames,
        ditherMs: _ms(p.ditherSettleSeconds),
        refocusEveryMs: p.refocusEveryMinutes == null
            ? null
            : _ms(p.refocusEveryMinutes! * 60),
        refocusMs: _ms(p.refocusSeconds),
        filterChangeMs: p.filterChangeSeconds == null
            ? null
            : _ms(p.filterChangeSeconds!),
        meridianFlipMs: p.meridianFlipSeconds == null
            ? null
            : _ms(p.meridianFlipSeconds!),
        setupMs: p.setupMinutes == null ? null : _ms(p.setupMinutes! * 60),
      );

  /// Download or interval gap added to every acquired frame.
  final int perFrameMs;

  /// Dither after every N light frames; null = off.
  final int? ditherEveryNFrames;
  final int ditherMs;

  /// Refocus after every T of accumulated capture time; null = off.
  final int? refocusEveryMs;
  final int refocusMs;

  /// Per change of filter between consecutive light blocks; null = off.
  final int? filterChangeMs;

  /// One meridian flip; null = off.
  final int? meridianFlipMs;

  /// Setup before the first window; null = off.
  final int? setupMs;

  static int _ms(double seconds) => (seconds * 1000).round();
}

/// Kinds of events in the in-window sequence (ADR-009 §4).
enum BudgetEventKind { frame, dither, refocus, filterChange, meridianFlip }

/// One atomic event of the in-window sequence. The fit (TASK 5.5) places
/// exactly these events, in this order, so the budget and the fit cannot
/// disagree.
class BudgetEvent {
  const BudgetEvent(this.kind, this.durationMs, {this.blockIndex});

  final BudgetEventKind kind;
  final int durationMs;

  /// For frames: the index of the block in the plan.
  final int? blockIndex;

  @override
  String toString() =>
      'BudgetEvent(${kind.name}, $durationMs ms'
      '${blockIndex == null ? '' : ', block $blockIndex'})';
}

/// Where a block's time is counted (ADR-009 §2–§3).
enum BudgetPlacement { window, outsideWindow, library }

/// One block's share of the budget.
class BlockBudget {
  const BlockBudget({
    required this.blockIndex,
    required this.placement,
    required this.exposureMs,
    required this.perFrameOverheadMs,
    required this.storageMB,
  });

  final int blockIndex;
  final BudgetPlacement placement;

  /// count × exposure; 0 for library blocks.
  final int exposureMs;

  /// count × per-frame overhead; 0 for library blocks.
  final int perFrameOverheadMs;

  /// exposure + per-frame overhead.
  int get totalMs => exposureMs + perFrameOverheadMs;

  /// Estimated storage in MB, or null when the file size is unknown (never
  /// shown as zero, SI-013). Library blocks: 0 (no files are taken).
  final double? storageMB;
}

/// The capture budget of one plan (ADR-009 §2). All durations are integer
/// milliseconds.
class CaptureBudget {
  const CaptureBudget({
    required this.integrationMs,
    required this.acquisitionMs,
    required this.inWindowCalibrationMs,
    required this.outsideWindowCalibrationMs,
    required this.setupMs,
    required this.sequence,
    required this.blocks,
    required this.lightFrameCount,
    required this.storageMB,
    required this.libraryBlockIndexes,
  });

  /// Σ light exposure — the science quantity.
  final int integrationMs;

  /// Integration + per-frame overhead on lights + in-window overhead events.
  final int acquisitionMs;

  /// In-window calibration frames, exposure + per-frame overhead.
  final int inWindowCalibrationMs;

  /// Calibration taken outside the window; reported, never fitted.
  final int outsideWindowCalibrationMs;

  /// Setup before the first window, or null when not included.
  final int? setupMs;

  /// The ordered in-window events (TASK 5.5 places these).
  final List<BudgetEvent> sequence;

  final List<BlockBudget> blocks;

  /// Total light frames.
  final int lightFrameCount;

  /// Estimated storage, MB; null when the file size is unknown.
  final double? storageMB;

  /// Blocks reused from a library (consume no time).
  final List<int> libraryBlockIndexes;

  /// Acquisition + in-window calibration: the only quantity fitted into the
  /// windows (ADR-009 §6).
  int get windowLoadMs => acquisitionMs + inWindowCalibrationMs;

  /// Window load + outside-window calibration + setup (ADR-009 §2, owner
  /// decision: each shown on its own line).
  int get sessionBudgetMs =>
      windowLoadMs + outsideWindowCalibrationMs + (setupMs ?? 0);

  int countOf(BudgetEventKind kind) =>
      sequence.where((e) => e.kind == kind).length;

  Duration get integration => Duration(milliseconds: integrationMs);
  Duration get acquisition => Duration(milliseconds: acquisitionMs);
  Duration get windowLoad => Duration(milliseconds: windowLoadMs);
  Duration get sessionBudget => Duration(milliseconds: sessionBudgetMs);
}

/// ADR-009 capture budget (CALC-25). Pure and deterministic; no windows are
/// read except for the meridian-flip condition, supplied as a flag.
class CaptureBudgetCalculator {
  const CaptureBudgetCalculator._();

  /// Builds the budget for [blocks] (in plan order).
  ///
  /// [targetTransitsInWindow]: whether the target's upper transit falls in
  /// an available window; the flip (when enabled) is then counted once,
  /// conservatively (ADR-009 §4). [averageRawFileSizeMB]: per frame, or
  /// null when unknown.
  static CaptureBudget calculate({
    required List<CaptureBlock> blocks,
    CaptureOverheads overheads = const CaptureOverheads(),
    bool targetTransitsInWindow = false,
    double? averageRawFileSizeMB,
  }) {
    final perFrame = overheads.perFrameMs;
    final sequence = <BudgetEvent>[];
    final blockBudgets = <BlockBudget>[];
    final library = <int>[];

    var integration = 0;
    var inWindowCal = 0;
    var outsideCal = 0;
    var lightTotal = 0;
    for (final b in blocks) {
      if (b.frameType == FrameType.light) lightTotal += b.frameCount;
    }

    var lightsDone = 0;
    var accumulated = 0; // capture time excluding refocus events
    var nextRefocus = 1;
    String? previousFilter;
    var seenLight = false;

    for (var i = 0; i < blocks.length; i++) {
      final b = blocks[i];
      final exposure = (b.exposureTimeSeconds * 1000).round();
      final isLight = b.frameType == FrameType.light;
      final placement = isLight
          ? BudgetPlacement.window
          : switch (b.calibrationPolicy ?? CalibrationPolicy.outsideWindow) {
              CalibrationPolicy.inWindow => BudgetPlacement.window,
              CalibrationPolicy.outsideWindow => BudgetPlacement.outsideWindow,
              CalibrationPolicy.library => BudgetPlacement.library,
            };

      final counted = placement != BudgetPlacement.library;
      blockBudgets.add(
        BlockBudget(
          blockIndex: i,
          placement: placement,
          exposureMs: counted ? b.frameCount * exposure : 0,
          perFrameOverheadMs: counted ? b.frameCount * perFrame : 0,
          storageMB: !counted
              ? 0
              : averageRawFileSizeMB == null
              ? null
              : averageRawFileSizeMB * b.frameCount,
        ),
      );

      switch (placement) {
        case BudgetPlacement.library:
          library.add(i);
          continue;
        case BudgetPlacement.outsideWindow:
          outsideCal += b.frameCount * (exposure + perFrame);
          continue;
        case BudgetPlacement.window:
          break;
      }

      if (isLight) {
        integration += b.frameCount * exposure;
        if (seenLight &&
            overheads.filterChangeMs != null &&
            b.filterName != previousFilter) {
          sequence.add(
            BudgetEvent(
              BudgetEventKind.filterChange,
              overheads.filterChangeMs!,
            ),
          );
          accumulated += overheads.filterChangeMs!;
        }
        previousFilter = b.filterName;
        seenLight = true;
      }

      for (var n = 0; n < b.frameCount; n++) {
        sequence.add(
          BudgetEvent(
            BudgetEventKind.frame,
            exposure + perFrame,
            blockIndex: i,
          ),
        );
        accumulated += exposure + perFrame;
        if (!isLight) {
          inWindowCal += exposure + perFrame;
          continue;
        }
        lightsDone++;
        final more = lightsDone < lightTotal;
        final ditherN = overheads.ditherEveryNFrames;
        if (more && ditherN != null && lightsDone % ditherN == 0) {
          sequence.add(BudgetEvent(BudgetEventKind.dither, overheads.ditherMs));
          accumulated += overheads.ditherMs;
        }
        final refocusT = overheads.refocusEveryMs;
        if (more && refocusT != null && refocusT > 0) {
          while (accumulated >= nextRefocus * refocusT) {
            sequence.add(
              BudgetEvent(BudgetEventKind.refocus, overheads.refocusMs),
            );
            nextRefocus++;
          }
        }
      }
    }

    if (overheads.meridianFlipMs != null && targetTransitsInWindow) {
      sequence.add(
        BudgetEvent(BudgetEventKind.meridianFlip, overheads.meridianFlipMs!),
      );
    }

    final sequenceTotal = sequence.fold(0, (s, e) => s + e.durationMs);
    double? storage;
    if (averageRawFileSizeMB != null) {
      storage = blockBudgets.fold<double>(0, (s, b) => s + b.storageMB!);
    }

    return CaptureBudget(
      integrationMs: integration,
      acquisitionMs: sequenceTotal - inWindowCal,
      inWindowCalibrationMs: inWindowCal,
      outsideWindowCalibrationMs: outsideCal,
      setupMs: overheads.setupMs,
      sequence: List.unmodifiable(sequence),
      blocks: List.unmodifiable(blockBudgets),
      lightFrameCount: lightTotal,
      storageMB: storage,
      libraryBlockIndexes: List.unmodifiable(library),
    );
  }

  /// The target's upper transit: its highest sample on the night's
  /// 5-minute grid, or null when that maximum is at either end of the night
  /// (the target culminates outside it). Resolution: 5 minutes.
  static DateTime? transitInstant(AltitudeCurve curve) {
    final s = curve.samples;
    if (s.length < 3) return null;
    var best = 0;
    for (var i = 1; i < s.length; i++) {
      if (s[i].targetAltitudeDeg > s[best].targetAltitudeDeg) best = i;
    }
    if (best == 0 || best == s.length - 1) return null;
    return s[best].instantUtc;
  }

  /// Whether [transitInstant] falls inside one of [windows].
  static bool transitFallsInWindows(
    AltitudeCurve curve,
    List<VisibilityWindow> windows,
  ) {
    final t = transitInstant(curve);
    if (t == null) return false;
    return windows.any((w) => !t.isBefore(w.start) && t.isBefore(w.end));
  }
}
