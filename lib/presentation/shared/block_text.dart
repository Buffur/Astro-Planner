import '../../core/utils/quantity_text.dart';
import '../../domain/models/capture_block.dart';
import '../../domain/services/capture_budget_calculator.dart';

/// How a capture block reads in the plan (S6.9; UX-09, 08 §14): what will
/// be captured first — "Ha · 60 s × 100 · 1 h 40 min". The duration is the
/// block's exposure from the budget (`BlockBudget`), never computed here.
/// Camera-specific values (ISO or gain, binning) stay in the block's editor.
abstract final class BlockText {
  /// The block's identity: a light's filter ("Ha"), or "Light" without one;
  /// a calibration frame's type, with its filter if it has one ("Flat
  /// (Ha)").
  static String identity(CaptureBlock b) {
    final name = b.filterName?.trim();
    final filter = name == null || name.isEmpty ? null : name;
    final type = switch (b.frameType) {
      FrameType.light => 'Light',
      FrameType.dark => 'Dark',
      FrameType.flat => 'Flat',
      FrameType.bias => 'Bias',
    };
    if (b.frameType == FrameType.light) return filter ?? type;
    return filter == null ? type : '$type ($filter)';
  }

  /// The row: identity · exposure × count · the block's exposure time, or
  /// "from your library" for library calibration (no time, ADR-009 §3).
  static String row(CaptureBlock b, BlockBudget? budget) => [
    identity(b),
    '${QuantityText.exposure(b.exposureTimeSeconds)} × ${b.frameCount}',
    if (budget != null)
      budget.placement == BudgetPlacement.library
          ? 'from your library'
          : QuantityText.duration(Duration(milliseconds: budget.exposureMs)),
  ].join(' · ');

  /// Where a calibration block's time goes; null for lights and library
  /// blocks (the row already says so).
  static String? placement(CaptureBlock b, BlockBudget? budget) {
    if (b.frameType == FrameType.light || budget == null) return null;
    return switch (budget.placement) {
      BudgetPlacement.window => 'During the imaging window',
      BudgetPlacement.outsideWindow => 'Outside the imaging window',
      BudgetPlacement.library => null,
    };
  }
}
