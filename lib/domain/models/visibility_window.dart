class VisibilityWindow {
  final DateTime start;
  final DateTime end;

  /// True when [start] coincides with the SessionNight's `startUtc` because
  /// the target was already usable at the boundary, rather than because it
  /// became usable during the window. Only possible in polar-edge cases
  /// (ADR-007 §9); always false for windows computed from the legacy
  /// DateTime-based API.
  final bool clippedAtStart;

  /// True when [end] coincides with the SessionNight's `endUtc` because the
  /// target was still usable at the boundary, rather than because it
  /// stopped being usable during the window. Only possible in polar-edge
  /// cases (ADR-007 §9); always false for windows computed from the legacy
  /// DateTime-based API.
  final bool clippedAtEnd;

  const VisibilityWindow({
    required this.start,
    required this.end,
    this.clippedAtStart = false,
    this.clippedAtEnd = false,
  });

  Duration get duration => end.difference(start);

  @override
  String toString() =>
      'VisibilityWindow(start: ${start.toIso8601String()}, end: ${end.toIso8601String()}'
      '${clippedAtStart ? ', clippedAtStart' : ''}${clippedAtEnd ? ', clippedAtEnd' : ''})';

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is VisibilityWindow &&
          runtimeType == other.runtimeType &&
          start == other.start &&
          end == other.end &&
          clippedAtStart == other.clippedAtStart &&
          clippedAtEnd == other.clippedAtEnd;

  @override
  int get hashCode => Object.hash(start, end, clippedAtStart, clippedAtEnd);
}
