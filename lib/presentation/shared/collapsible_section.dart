import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/theme/app_motion.dart';
import '../../core/theme/app_palette.dart';
import '../../core/theme/app_spacing.dart';
import '../viewmodels/disclosure_viewmodel.dart';

/// Detail one tap away (S5.5; ADR-019 §7, RD-06, RG-06): a header with the
/// section's title and a factual summary, and the content below it when
/// open. The open or closed state is remembered per [sectionKey]
/// ([DisclosureViewModel]).
///
/// The [summary] states facts ("3 lines · 2 h 35 min total"), never a
/// verdict ("good", "fine"); the verdict belongs to the status block. The
/// summary stays visible when the section is open.
class CollapsibleSection extends StatelessWidget {
  const CollapsibleSection({
    super.key,
    required this.sectionKey,
    required this.title,
    required this.child,
    this.summary,
    this.initiallyOpen = false,
    this.open,
    this.onToggle,
  });

  /// Stable and unique, e.g. `planner.budgetDetails`; it names the stored
  /// preference, so never rename one without a reason.
  final String sectionKey;
  final String title;
  final String? summary;
  final Widget child;

  /// The state before the user has opened or closed it.
  final bool initiallyOpen;

  /// Controlled use (S7.6): the caller holds the state, e.g. a dialog whose
  /// section need not be remembered. With both set, the section reads no
  /// [DisclosureViewModel] and [initiallyOpen] is unused.
  final bool? open;
  final VoidCallback? onToggle;

  @override
  Widget build(BuildContext context) {
    final controlled = this.open != null && onToggle != null;
    final vm = controlled ? null : context.watch<DisclosureViewModel>();
    final open =
        this.open ?? vm!.isOpen(sectionKey, initiallyOpen: initiallyOpen);
    final p = AppPalette.of(context);
    final text = Theme.of(context).textTheme;
    void toggle() => controlled ? onToggle!() : vm!.setOpen(sectionKey, !open);
    final resize = AppMotion.duration(context, AppMotion.medium);
    final Widget body = open
        ? Padding(
            padding: const EdgeInsets.only(bottom: AppSpacing.sm),
            child: child,
          )
        : const SizedBox(width: double.infinity);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Semantics(
          key: Key('section.$sectionKey'),
          button: true,
          enabled: true,
          expanded: open,
          onTap: toggle,
          hint: open ? 'Collapse' : 'Expand',
          excludeSemantics: true,
          label: [title, ?summary].join(', '),
          child: InkWell(
            onTap: toggle,
            child: ConstrainedBox(
              constraints: const BoxConstraints(minHeight: 48),
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            title,
                            style: text.titleSmall?.copyWith(
                              color: p.textPrimary,
                            ),
                          ),
                          if (summary != null)
                            Text(
                              summary!,
                              style: text.bodyMedium?.copyWith(
                                color: p.textSecondary,
                              ),
                            ),
                        ],
                      ),
                    ),
                    const SizedBox(width: AppSpacing.sm),
                    AnimatedRotation(
                      turns: open ? 0.5 : 0,
                      duration: AppMotion.duration(context, AppMotion.short),
                      curve: AppMotion.curve,
                      child: Icon(Icons.expand_more, color: p.textSecondary),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
        // Reduced motion: no AnimatedSize at all (with a zero duration it
        // throws a layout assertion).
        if (resize == Duration.zero)
          body
        else
          ClipRect(
            child: AnimatedSize(
              duration: resize,
              curve: AppMotion.curve,
              alignment: Alignment.topCenter,
              child: body,
            ),
          ),
      ],
    );
  }
}
