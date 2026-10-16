import 'session.dart';

/// How a completed session's counts were reported (ADR-019 §4; S8.1, I-1).
/// Stored by name in `session_logs.result_kind`; null for rows completed
/// before S8.1 and for runs finished live without the result form.
enum ResultKind {
  /// "Completed as planned": the counts equal the saved plan's, as a user
  /// statement ("Reported as planned", D8-3), not counted frames.
  asPlanned,

  /// "Partly": the user typed the counts per light block.
  partly;

  static ResultKind? tryParse(String? stored) {
    for (final k in values) {
      if (k.name == stored) return k;
    }
    return null;
  }
}

/// Why a plan was not done (ADR-019 §4; S8.1, I-1). Optional; stored by name
/// in `session_logs.not_done_reason`.
enum NotDoneReason {
  clouds,
  wind,
  dew,
  equipment,
  other;

  static NotDoneReason? tryParse(String? stored) {
    for (final r in values) {
      if (r.name == stored) return r;
    }
    return null;
  }
}

/// The optional notes and conditions a result carries (ADR-019 §4). Null is
/// "not entered", never 0 (SI-008).
class ResultNotes {
  const ResultNotes({
    this.environmentalNotes,
    this.processingNotes,
    this.temperatureC,
    this.humidityPct,
    this.cloudCoverPct,
  });

  final String? environmentalNotes;
  final String? processingNotes;
  final double? temperatureC;
  final double? humidityPct;
  final int? cloudCoverPct;
}

/// What the user reports after the night (ADR-019 §4, the result form).
sealed class ResultReport {
  const ResultReport({this.notes = const ResultNotes()});

  final ResultNotes notes;
}

/// Every light block as planned: its planned count, reported by the user.
class CompletedAsPlanned extends ResultReport {
  const CompletedAsPlanned({super.notes});
}

/// The light frames the user reports per light block id; a block left out
/// keeps its current count. Counts are 0 or more and may exceed the plan.
class PartlyDone extends ResultReport {
  PartlyDone(Map<int, int> lightFrames, {super.notes})
    : lightFrames = Map.unmodifiable(lightFrames) {
    for (final n in lightFrames.values) {
      if (n < 0) throw ArgumentError.value(n, 'lightFrames', 'below zero');
    }
  }

  final Map<int, int> lightFrames;
}

/// Not done, with an optional reason. No counts are asked.
class NotDone extends ResultReport {
  const NotDone({this.reason, super.notes});

  final NotDoneReason? reason;
}

/// A result form opened on an entry that changed since (S4-DEF-08, I-7):
/// nothing was written.
class StaleResultForm extends SessionStateError {
  StaleResultForm(super.message);
}

/// A result for a saved night that has not ended yet (ADR-019 §3.1; D8-1):
/// nothing was written.
class NightNotEnded extends SessionStateError {
  NightNotEnded(super.message);
}
