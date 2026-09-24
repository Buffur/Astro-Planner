import '../models/calendar_date.dart';
import '../models/capture_block.dart';
import '../models/execution.dart';
import '../models/session.dart';

/// Multi-night progress on one target (TASK 14.2, CALC-38) — without a
/// project entity: the confirmed light integration of its completed
/// sessions, per filter, the last imaged night and the session count.
class TargetProgress {
  const TargetProgress({
    required this.targetId,
    required this.label,
    required this.integration,
    required this.perFilter,
    required this.lastNight,
    required this.sessionCount,
  });

  final int targetId;

  /// The name stored with the most recent session.
  final String label;
  final Duration integration;

  /// By filter name ("No filter" when none was set).
  final Map<String, Duration> perFilter;
  final CalendarDate? lastNight;
  final int sessionCount;

  static const noFilter = 'No filter';

  /// Progress per target id over [runs] (a session with its run state).
  /// Only completed, non-legacy sessions with a target count — a legacy
  /// log has no reliable target or per-block counts (ADR-014 §7).
  static Map<int, TargetProgress> of(Iterable<(Session, ExecutionState)> runs) {
    final out = <int, TargetProgress>{};
    for (final (s, state) in runs) {
      final id = s.targetId;
      if (id == null || s.legacy || s.status != SessionStatus.completed) {
        continue;
      }
      final before = out[id];
      final perFilter = {...?before?.perFilter};
      var total = before?.integration ?? Duration.zero;
      for (final b in s.blocks) {
        if (b.frameType != FrameType.light) continue;
        final d = Duration(
          milliseconds:
              (state.completedFor(b.id) * b.exposureTimeSeconds * 1000).round(),
        );
        final key = (b.filterName?.trim().isEmpty ?? true)
            ? noFilter
            : b.filterName!.trim();
        perFilter[key] = (perFilter[key] ?? Duration.zero) + d;
        total += d;
      }
      final night = s.eveningDate;
      final last = before?.lastNight;
      final newer =
          night != null && (last == null || night.compareTo(last) > 0);
      out[id] = TargetProgress(
        targetId: id,
        label: newer || before == null ? s.record.targetName : before.label,
        integration: total,
        perFilter: perFilter,
        lastNight: newer ? night : last,
        sessionCount: (before?.sessionCount ?? 0) + 1,
      );
    }
    return out;
  }
}
