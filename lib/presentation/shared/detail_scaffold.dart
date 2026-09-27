import 'package:flutter/material.dart';

import '../../core/theme/app_palette.dart';
import '../../core/theme/app_spacing.dart';

/// One layout for the detail screens (S5.7; ADR-019 §9, addendum §3.4–§3.5):
/// Night & Moon and Weather first. Top to bottom:
/// 1. a header: the [title] (a semantic header), its [context] ("Fri, Nov
///    13 · Ljubljana") and the zone rule, **once** ([zoneRule]); all wrap at
///    large text sizes, so the title lives here rather than in the app bar,
///    which keeps only navigation and [actions];
/// 2. the [summary], on a card: facts, never a verdict score (ADR-012);
/// 3. the full content, [sections] (a `CollapsibleSection` where one is
///    long), separated by dividers.
///
/// Every time on the page is in the zone the header names; sections never
/// repeat the zone caption.
class DetailScaffold extends StatelessWidget {
  const DetailScaffold({
    super.key,
    required this.title,
    required this.summary,
    this.context,
    this.zoneRule,
    this.sections = const [],
    this.actions,
  });

  final String title;

  /// The night and site the page describes, e.g. "Fri, Nov 13 · Ljubljana".
  final String? context;

  /// "Times in site zone …" (`ContextLine.zoneRule`), shown once.
  final String? zoneRule;

  final Widget summary;
  final List<Widget> sections;
  final List<Widget>? actions;

  @override
  Widget build(BuildContext buildContext) {
    final p = AppPalette.of(buildContext);
    final text = Theme.of(buildContext).textTheme;
    return Scaffold(
      appBar: AppBar(actions: actions),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(
          AppSpacing.md,
          0,
          AppSpacing.md,
          AppSpacing.lg,
        ),
        children: [
          Semantics(
            header: true,
            child: Text(
              title,
              key: const Key('detail.title'),
              style: text.titleLarge?.copyWith(color: p.textPrimary),
            ),
          ),
          if (context != null)
            Text(
              context!,
              key: const Key('detail.context'),
              style: text.bodyMedium?.copyWith(color: p.textSecondary),
            ),
          if (zoneRule != null)
            Text(
              zoneRule!,
              key: const Key('detail.zone'),
              style: text.bodySmall?.copyWith(color: p.textTertiary),
            ),
          const SizedBox(height: AppSpacing.md),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(AppSpacing.md),
              child: summary,
            ),
          ),
          for (final (i, section) in sections.indexed) ...[
            if (i == 0)
              const SizedBox(height: AppSpacing.sm)
            else
              const Divider(),
            section,
          ],
        ],
      ),
    );
  }
}
