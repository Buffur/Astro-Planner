import '../../domain/models/capture_block.dart';

/// What an edit to the capture blocks replaced (TD-079, S6.16; a delete's
/// too since S6.V1), enough for its Undo: the blocks and the example badge
/// before it, the very blocks it left, and the plan it was made in (the
/// lifecycle's contents generation and the session). Kept only while its
/// Undo message is up; no history.
class BlocksEdit {
  const BlocksEdit({
    required this.before,
    required this.wasExample,
    required this.after,
    required this.contents,
    required this.sessionId,
  });

  final List<CaptureBlock> before;
  final bool wasExample;
  final List<CaptureBlock> after;
  final int contents;
  final int? sessionId;

  /// Whether the edit changed the blocks at all.
  bool get changed => !_same(before, after);

  /// Whether the plan [contents] in session [sessionId] is still the one the
  /// edit was made in: not replaced since (New, Copy, Open, a restore).
  bool inPlan(int contents, int? sessionId) =>
      contents == this.contents && sessionId == this.sessionId;

  /// Whether [blocks], in the plan [contents] and session [sessionId], are
  /// still exactly what the edit left: nothing was edited since.
  bool isCurrent(List<CaptureBlock> blocks, int contents, int? sessionId) =>
      inPlan(contents, sessionId) && _same(after, blocks);

  /// The same block instances, in the same order.
  static bool _same(List<CaptureBlock> a, List<CaptureBlock> b) =>
      a.length == b.length && a.indexed.every((e) => identical(e.$2, b[e.$1]));
}
