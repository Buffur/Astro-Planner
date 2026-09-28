import 'package:flutter/material.dart';

import '../../core/theme/app_palette.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/utils/quantity_text.dart';
import '../../domain/services/fit_analyzer.dart';
import 'app_words.dart';
import 'night_text.dart';

/// The answer first (S5.4; ADR-019 §6, addendum §3.1–§3.2): the verdict
/// headline in its status colour ("Fits: 2 h 5 min needed of 4 h 20 min
/// usable"), its reason, optional key numbers and an optional action (fill
/// or trim). It calculates nothing: the state, the durations, the reason
/// and the key numbers come from the ViewModel (the fit analysis); values
/// are formatted with `QuantityText`.
class StatusBlock extends StatelessWidget {
  const StatusBlock({
    super.key,
    required this.state,
    this.needed,
    this.usable,
    this.reason,
    this.missing,
    this.keyNumbers = const [],
    this.action,
  });

  final FitState state;

  /// Time needed and usable time; the headline names them only when both
  /// are known (unknown stays unknown).
  final Duration? needed;
  final Duration? usable;

  final String? reason;

  /// For a missing input: [AppWords.needsTarget] (the default) or another
  /// glossary word the adopting screen chooses.
  final String? missing;

  /// Label and already formatted value pairs, e.g. ("Capture ends",
  /// "01:40").
  final List<(String, String)> keyNumbers;

  final Widget? action;

  /// The headline in the glossary's words (RD-14). Pure.
  static String headline(
    FitState state, {
    Duration? needed,
    Duration? usable,
    String? missing,
  }) {
    String measured(String word) => needed == null || usable == null
        ? word
        : AppWords.headline(
            word,
            QuantityText.duration(needed),
            QuantityText.duration(usable),
          );
    return switch (state) {
      FitState.fits => measured(AppWords.fits),
      FitState.tight => measured(AppWords.tight),
      FitState.doesNotFit => measured(AppWords.doesNotFit),
      FitState.noWindow => AppWords.noWindow,
      FitState.needsInput => missing ?? AppWords.needsTarget,
      FitState.nothingToFit => AppWords.needsBlock,
    };
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final p = AppPalette.of(context);
    final text = theme.textTheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Semantics(
          header: true,
          child: Text(
            headline(state, needed: needed, usable: usable, missing: missing),
            key: const Key('status.headline'),
            style: text.titleMedium?.copyWith(
              color: FitText.color(state, theme.colorScheme, p),
            ),
          ),
        ),
        if (reason != null) ...[
          const SizedBox(height: AppSpacing.xs),
          Text(
            reason!,
            style: text.bodyMedium?.copyWith(color: p.textSecondary),
          ),
        ],
        if (keyNumbers.isNotEmpty) ...[
          const SizedBox(height: AppSpacing.md),
          // S6.16: each number as a label above its value, so the answer's
          // figures read as a set (the scale's caption and group roles).
          Wrap(
            spacing: AppSpacing.lg,
            runSpacing: AppSpacing.sm,
            children: [
              for (final (label, value) in keyNumbers)
                MergeSemantics(
                  child: Column(
                    key: Key('status.number.$label'),
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        label,
                        style: text.bodySmall?.copyWith(color: p.textTertiary),
                      ),
                      Text(
                        value,
                        style: text.titleSmall?.copyWith(color: p.textPrimary),
                      ),
                    ],
                  ),
                ),
            ],
          ),
        ],
        if (action != null) ...[const SizedBox(height: AppSpacing.md), action!],
      ],
    );
  }
}
