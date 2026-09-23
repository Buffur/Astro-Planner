import '../models/capture_block.dart';

/// The example capture plan shown on a first run and by "New session"
/// (TASK 4.4: it must not look like the user's own plan; moved out of the
/// planner ViewModel in TASK 12.3).
abstract final class ExampleCapturePlan {
  static List<CaptureBlock> blocks() => [
    CaptureBlock(
      frameType: FrameType.light,
      filterName: 'L',
      exposureTimeSeconds: 60.0,
      frameCount: 100,
    ),
    CaptureBlock(
      frameType: FrameType.dark,
      exposureTimeSeconds: 60.0,
      frameCount: 20,
    ),
    CaptureBlock(
      frameType: FrameType.flat,
      exposureTimeSeconds: 2.0,
      frameCount: 20,
    ),
  ];

  /// Whether [plan] is still exactly the example (field by field).
  static bool matches(List<CaptureBlock> plan) {
    final example = blocks();
    if (plan.length != example.length) return false;
    for (var i = 0; i < plan.length; i++) {
      final a = plan[i];
      final e = example[i];
      if (a.frameType != e.frameType ||
          a.filterName != e.filterName ||
          a.exposureTimeSeconds != e.exposureTimeSeconds ||
          a.frameCount != e.frameCount ||
          a.binning != e.binning ||
          a.gain != e.gain ||
          a.calibrationPolicy != e.calibrationPolicy) {
        return false;
      }
    }
    return true;
  }
}
