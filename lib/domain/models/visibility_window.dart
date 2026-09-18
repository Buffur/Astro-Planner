class VisibilityWindow {
  final DateTime start;
  final DateTime end;

  const VisibilityWindow({
    required this.start,
    required this.end,
  });

  Duration get duration => end.difference(start);

  @override
  String toString() => 'VisibilityWindow(start: ${start.toIso8601String()}, end: ${end.toIso8601String()})';

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is VisibilityWindow &&
          runtimeType == other.runtimeType &&
          start == other.start &&
          end == other.end;

  @override
  int get hashCode => start.hashCode ^ end.hashCode;
}
