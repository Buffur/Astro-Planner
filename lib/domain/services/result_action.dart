import '../models/session.dart';
import 'saved_night_end.dart';

/// What an entry offers for its result (S8.2; ADR-019 §3.1, I-6).
enum ResultAction {
  /// Nothing yet: a plan whose night has not ended, a never-saved draft, or
  /// an old log.
  none,

  /// "Record result": a saved plan whose night has ended, or a run still in
  /// progress from the live mode.
  record,

  /// "Edit result": a completed or not-done entry.
  edit;

  /// Pure: [nowUtc] is passed in.
  static ResultAction of(Session s, DateTime nowUtc) {
    if (s.legacy) return none;
    return switch (s.status) {
      SessionStatus.completed || SessionStatus.abandoned => edit,
      SessionStatus.inProgress => record,
      SessionStatus.planned || SessionStatus.draft =>
        s.isSavedPlan && SavedNightEnd.hasEnded(s, nowUtc) ? record : none,
    };
  }
}
