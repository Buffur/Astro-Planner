import 'package:flutter/material.dart';

import '../../core/theme/app_palette.dart';
import '../../core/theme/app_radius.dart';
import '../../core/theme/app_spacing.dart';
import '../../domain/models/session.dart';
import '../../domain/models/session_result.dart';
import 'app_words.dart';

/// A plan's state as the user sees it (S5.4; ADR-019 §3, RD-05, RG-04).
/// The stored statuses stay internal: "Draft" is never shown.
enum PlanState {
  notSaved,
  saved,
  savedChanged,
  tracking,
  completed,

  /// A partial result, recorded through the result form (S8.1–S8.2).
  partly,
  notDone,
  oldLog;

  /// The state the stored fields express: the status, whether the plan was
  /// ever saved (`plannedAtUtc != null`), whether it is a legacy log, and how
  /// a completed result was reported (S8.1). Pure.
  static PlanState from({
    required SessionStatus status,
    required bool savedBefore,
    required bool legacy,
    ResultKind? resultKind,
  }) {
    if (legacy) return oldLog;
    return switch (status) {
      SessionStatus.draft => savedBefore ? savedChanged : notSaved,
      SessionStatus.planned => saved,
      SessionStatus.inProgress => tracking,
      SessionStatus.completed =>
        resultKind == ResultKind.partly ? partly : completed,
      SessionStatus.abandoned => notDone,
    };
  }

  static PlanState of(Session s) => from(
    status: s.status,
    savedBefore: s.plannedAtUtc != null,
    legacy: s.legacy,
    resultKind: s.resultKind,
  );

  String get word => switch (this) {
    notSaved => AppWords.notSaved,
    saved => AppWords.saved,
    savedChanged => AppWords.savedChanged,
    tracking => AppWords.tracking,
    completed => AppWords.completed,
    partly => AppWords.partly,
    notDone => AppWords.notDone,
    oldLog => AppWords.oldLog,
  };

  /// Unsaved work draws attention; a settled plan reads as primary text;
  /// the rest is quiet. A tone, never a verdict.
  Color tone(AppPalette p) => switch (this) {
    notSaved || savedChanged => p.stateUnsaved,
    saved || tracking || completed => p.stateSettled,
    partly || notDone || oldLog => p.stateQuiet,
  };
}

/// The plan-state label (S5.4): the state's word in its tone, in a quiet
/// outlined pill. It wraps at large text sizes; it is not tappable.
class PlanStateLabel extends StatelessWidget {
  const PlanStateLabel(this.state, {super.key});

  final PlanState state;

  @override
  Widget build(BuildContext context) {
    final p = AppPalette.of(context);
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.sm,
        vertical: AppSpacing.xs / 2,
      ),
      decoration: BoxDecoration(
        border: Border.all(color: p.border),
        borderRadius: BorderRadius.circular(AppRadius.pill),
      ),
      child: Text(
        state.word,
        style: Theme.of(context).textTheme.labelMedium
            ?.copyWith(color: state.tone(p)),
      ),
    );
  }
}
