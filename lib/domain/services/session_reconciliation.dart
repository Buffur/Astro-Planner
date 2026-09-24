import '../models/capture_block.dart';
import '../models/execution.dart';

/// One block, planned against what was confirmed (TASK 13.4).
class BlockReconciliation {
  const BlockReconciliation({
    required this.block,
    required this.confirmed,
    required this.rejected,
  });

  final CaptureBlock block;
  final int confirmed;
  final int rejected;

  int get planned => block.frameCount;
  bool get isLight => block.frameType == FrameType.light;

  /// planned × exposure (lights only; zero for calibration blocks).
  Duration get plannedIntegration => _integration(planned);

  /// confirmed × exposure (lights only).
  Duration get actualIntegration => _integration(confirmed);

  Duration _integration(int frames) => isLight
      ? Duration(
          milliseconds: (frames * block.exposureTimeSeconds * 1000).round(),
        )
      : Duration.zero;
}

/// Planned vs actual for a run (TASK 13.4, CALC-37): per block, and the
/// light-frame integration. Rejected frames are captured but not counted as
/// integration. Pure; the counts come from the run's fold.
class SessionReconciliation {
  const SessionReconciliation(this.blocks);

  final List<BlockReconciliation> blocks;

  static SessionReconciliation of(
    List<CaptureBlock> blocks,
    ExecutionState state,
  ) => SessionReconciliation([
    for (final b in blocks)
      BlockReconciliation(
        block: b,
        confirmed: state.completedFor(b.id),
        rejected: state.rejectedFor(b.id),
      ),
  ]);

  Duration get plannedIntegration =>
      blocks.fold(Duration.zero, (sum, b) => sum + b.plannedIntegration);

  Duration get actualIntegration =>
      blocks.fold(Duration.zero, (sum, b) => sum + b.actualIntegration);

  /// Confirmed and rejected light frames (the session's result totals).
  int get actualLightFrames =>
      blocks.where((b) => b.isLight).fold(0, (sum, b) => sum + b.confirmed);

  int get rejectedLightFrames =>
      blocks.where((b) => b.isLight).fold(0, (sum, b) => sum + b.rejected);

  /// actual ÷ planned integration; null when nothing was planned.
  double? get fraction => plannedIntegration == Duration.zero
      ? null
      : actualIntegration.inMilliseconds / plannedIntegration.inMilliseconds;
}
