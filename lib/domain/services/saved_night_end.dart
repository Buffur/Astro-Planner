import '../models/calendar_date.dart';
import '../models/night_timeline.dart';
import '../models/session.dart';
import '../models/session_snapshot.dart';
import 'visibility_calculator.dart';

/// When a saved night ends (CALC-44; D8-1, S4-DEF-02): from then a result may
/// be recorded, and the planner no longer treats the saved plan as current.
/// Pure: "now" is always passed in.
///
/// - The night is the one the saved snapshot records (the execution-start
///   snapshot for a run, else the plan snapshot), never the live site's.
/// - It ends at the **dawn** of its dark span at the snapshot's darkness
///   limit: the Sun back above the limit (CALC-41's span, recomputed from
///   the snapshot's night and site).
/// - Without a dawn inside the night (no darkness that night, darkness to
///   the window's end, polar night) or without a recorded limit, it ends at
///   the night's end: the next mean solar noon (ADR-007).
/// - Without a readable snapshot, only the night key is known. It ends at the
///   latest instant any site's night with that evening date can end: the
///   mean solar noon at longitude 180° W, i.e. 00:00 UTC two days after the
///   evening date. Never earlier than the true end.
abstract final class SavedNightEnd {
  /// The end of [session]'s saved night, or null without a night key.
  static DateTime? of(Session session) {
    final snapshot = session.status == SessionStatus.inProgress
        ? session.executionStartSnapshot ?? session.planSnapshot
        : session.planSnapshot;
    final fromSnapshot = snapshot == null ? null : ofSnapshot(snapshot);
    if (fromSnapshot != null) return fromSnapshot;
    final night = snapshot?.eveningDate ?? session.eveningDate;
    return night == null ? null : latestEnd(night);
  }

  /// The end of [snapshot]'s night; null when its night cannot be read.
  static DateTime? ofSnapshot(SessionSnapshot snapshot) {
    final night = snapshot.night;
    if (night == null) return null;
    final limit = snapshot.darknessLimitDeg;
    if (limit == null) return night.endUtc;
    final dark = VisibilityCalculator.calculateNightTimelineForNight(
      night,
      darknessLimitDeg: limit,
    ).darkAtLimit;
    if (dark is SunCrossing) {
      final dawn = dark.dawnUtc;
      if (dawn != null && dawn.isBefore(night.endUtc)) return dawn;
    }
    return night.endUtc;
  }

  /// The latest end of any night keyed [eveningDate] (see the class note).
  static DateTime latestEnd(CalendarDate eveningDate) =>
      DateTime.utc(eveningDate.year, eveningDate.month, eveningDate.day + 2);

  /// Whether [session]'s saved night has ended at [nowUtc]. A session
  /// without a night key has no saved night: false.
  static bool hasEnded(Session session, DateTime nowUtc) {
    final end = of(session);
    return end != null && !nowUtc.isBefore(end);
  }
}
