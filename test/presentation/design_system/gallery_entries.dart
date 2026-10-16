// The design-system gallery's content (S5.1–S5.8), shared by the gallery
// test (which audits it) and the opt-in render test (S5.9, which draws it
// for the owner). Each Stage 5 Task added its samples here.

import 'package:astroplan/core/theme/app_button_styles.dart';
import 'package:astroplan/core/theme/app_palette.dart';
import 'package:astroplan/core/theme/app_spacing.dart';
import 'package:astroplan/domain/models/calendar_date.dart';
import 'package:astroplan/domain/services/fit_analyzer.dart';
import 'package:astroplan/presentation/shared/app_words.dart';
import 'package:astroplan/presentation/shared/collapsible_section.dart';
import 'package:astroplan/presentation/shared/context_line.dart';
import 'package:astroplan/presentation/shared/delete_patterns.dart';
import 'package:astroplan/presentation/shared/detail_scaffold.dart';
import 'package:astroplan/presentation/shared/plan_state.dart';
import 'package:astroplan/presentation/shared/status_block.dart';
import 'package:flutter/material.dart';

/// The text roles in the styles they serve, on one surface.
class _TextRoles extends StatelessWidget {
  const _TextRoles();

  @override
  Widget build(BuildContext context) {
    final p = AppPalette.of(context);
    final t = Theme.of(context).textTheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Fits: 2 h 05 min needed of 4 h 20 min usable',
          style: t.titleMedium?.copyWith(color: p.textPrimary),
        ),
        const SizedBox(height: AppSpacing.xs),
        Text(
          'Integration 1 h 40 min',
          style: t.bodyMedium?.copyWith(color: p.textPrimary),
        ),
        Text(
          'Capture ends 01:40',
          style: t.bodyMedium?.copyWith(color: p.textSecondary),
        ),
        Text(
          'Times in Europe/Ljubljana',
          style: t.bodySmall?.copyWith(color: p.textTertiary),
        ),
      ],
    );
  }
}

/// The three surface levels, each holding the text roles.
List<Widget> _surfaces() => [
  const Padding(
    padding: EdgeInsets.symmetric(vertical: AppSpacing.sm),
    child: _TextRoles(), // on the background
  ),
  const Card(
    child: Padding(
      padding: EdgeInsets.all(AppSpacing.md),
      child: _TextRoles(), // on the surface
    ),
  ),
  const SizedBox(height: AppSpacing.lg),
  Builder(
    builder: (context) => Container(
      color: AppPalette.of(context).surfaceRaised,
      padding: const EdgeInsets.all(AppSpacing.md),
      child: const _TextRoles(), // on the raised surface
    ),
  ),
];

/// S5.2: every button role, enabled and disabled.
List<Widget> _buttons() => [
  const SizedBox(height: AppSpacing.lg),
  Wrap(
    spacing: AppSpacing.sm,
    runSpacing: AppSpacing.sm,
    children: [
      FilledButton(onPressed: () {}, child: const Text('Save plan')),
      OutlinedButton(onPressed: () {}, child: const Text('New plan')),
      TextButton(onPressed: () {}, child: const Text('Cancel')),
      ElevatedButton(onPressed: () {}, child: const Text('Choose a target')),
      Builder(
        builder: (context) => FilledButton(
          style: AppButtonStyles.destructive(Theme.of(context).colorScheme),
          onPressed: () {},
          child: const Text('Delete'),
        ),
      ),
      Builder(
        builder: (context) => TextButton(
          style: AppButtonStyles.destructiveText(Theme.of(context).colorScheme),
          onPressed: () {},
          child: const Text('Delete'),
        ),
      ),
      FilledButton.icon(
        onPressed: () {},
        icon: const Icon(Icons.add),
        label: const Text('Add block'),
      ),
      IconButton(
        tooltip: 'More',
        onPressed: () {},
        icon: const Icon(Icons.more_vert),
      ),
      const FilledButton(onPressed: null, child: Text('Save plan')),
      const OutlinedButton(onPressed: null, child: Text('New plan')),
      const TextButton(onPressed: null, child: Text('Cancel')),
    ],
  ),
];

/// S5.2: a text field in each state; the first is focused.
List<Widget> _fields() => [
  const SizedBox(height: AppSpacing.lg),
  const TextField(
    autofocus: true,
    decoration: InputDecoration(
      labelText: 'Name (optional)',
      hintText: 'M42 from the garden',
    ),
  ),
  const TextField(
    decoration: InputDecoration(
      labelText: 'Exposure (s)',
      helperText: 'Per frame',
    ),
  ),
  TextField(
    controller: TextEditingController(text: '120'),
    decoration: const InputDecoration(
      labelText: 'Frames',
      suffixText: 'frames',
    ),
  ),
  TextField(
    controller: TextEditingController(text: '-3'),
    decoration: const InputDecoration(
      labelText: 'Frames',
      errorText: 'Enter a whole number of at least 1',
    ),
  ),
  const TextField(
    enabled: false,
    decoration: InputDecoration(labelText: 'Pixel size (µm)'),
  ),
  const TextField(
    decoration: InputDecoration(
      labelText: 'Search targets',
      prefixIcon: Icon(Icons.search),
      filled: true,
    ),
  ),
];

/// S5.2: a menu button, a divider and a list row with an icon.
List<Widget> _menus() => [
  const SizedBox(height: AppSpacing.lg),
  const Divider(),
  ListTile(
    leading: const Icon(Icons.nights_stay_outlined),
    title: const Text('Night & Moon'),
    subtitle: const Text('Dark 19:40 – 04:20'),
    trailing: PopupMenuButton<int>(
      key: const Key('gallery.menu'),
      tooltip: 'More',
      itemBuilder: (context) => const [
        PopupMenuItem(value: 1, child: Text('Copy to another night')),
        PopupMenuItem(value: 2, child: Text('New plan')),
      ],
    ),
  ),
];

/// S5.4: the status block in every state, on a card as the planner and
/// Tonight will show it, and every plan-state label.
List<Widget> _status() => [
  const SizedBox(height: AppSpacing.lg),
  for (final state in FitState.values)
    Card(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: StatusBlock(
          state: state,
          needed: const Duration(hours: 2, minutes: 5),
          usable: const Duration(hours: 4, minutes: 20),
          reason: 'Everything fits with 2 h 15 min of window time to spare.',
          keyNumbers: const [
            ('Capture ends', '01:40'),
            ('Integration', '1 h 40 min'),
          ],
          action: state == FitState.fits
              ? TextButton(
                  onPressed: () {},
                  child: const Text("Fill tonight's window"),
                )
              : null,
        ),
      ),
    ),
  const SizedBox(height: AppSpacing.sm),
  Wrap(
    spacing: AppSpacing.sm,
    runSpacing: AppSpacing.sm,
    children: [for (final s in PlanState.values) PlanStateLabel(s)],
  ),
];

/// S5.5: a collapsible section closed and one open, each with its factual
/// summary.
List<Widget> _sections() => [
  const SizedBox(height: AppSpacing.lg),
  const CollapsibleSection(
    sectionKey: 'gallery.closed',
    title: 'Budget details',
    summary: '4 lines · 2 h 35 min total',
    child: Text('Calibration during the window 10 min'),
  ),
  const Divider(),
  const CollapsibleSection(
    sectionKey: 'gallery.open',
    title: 'Assumptions',
    summary: '5 assumptions',
    initiallyOpen: true,
    child: Text('Per-frame overhead 2 s (your setting)'),
  ),
];

/// S5.6: the context line with a site and its zone, a site without a zone,
/// and no site.
List<Widget> _contextLines() => [
  const SizedBox(height: AppSpacing.lg),
  for (final (site, zone) in [
    ('Ljubljana', 'Europe/Ljubljana'),
    ('Dark-sky site near the observatory', null),
  ])
    ContextLine(
      siteName: site,
      night: CalendarDate(2026, 11, 13),
      zoneId: zone,
      nightStartUtc: DateTime.utc(2026, 11, 13, 11),
      onSite: () {},
      onNight: () {},
    ),
  ContextLine(siteName: null, night: null, onSite: () {}, onNight: () {}),
];

/// S5.7: a sample detail page on the template, as the Night & Moon detail
/// will be (addendum §3.4). Not a route: Stage 6 builds the real ones.
Widget galleryDetailPage() => DetailScaffold(
  title: 'Night & Moon',
  context: 'Fri, Nov 13 · Dark-sky site near the observatory',
  zoneRule: ContextLine.zoneRule(
    DateTime.utc(2026, 11, 13, 11),
    zoneId: 'Europe/Ljubljana',
  ),
  summary: const Text('${AppWords.dark} 19:40 – 04:20 (Sun below −18°)'),
  sections: const [
    CollapsibleSection(
      sectionKey: 'gallery.twilight',
      title: 'Twilight',
      summary: '6 events',
      initiallyOpen: true,
      child: Text(
        '${AppWords.civilDusk} 17:03 · ${AppWords.nauticalDusk} 17:39 · '
        '${AppWords.astronomicalDusk} 18:15',
      ),
    ),
    CollapsibleSection(
      sectionKey: 'gallery.moon',
      title: 'Moon',
      summary: '32 % lit · sets 22:10',
      child: Text('Rises 11:20 · sets 22:10'),
    ),
  ],
);

/// S5.8: a deletable row: a visible Delete, and a swipe to the same
/// handler.
List<Widget> _deletable() => [
  const SizedBox(height: AppSpacing.lg),
  SwipeToDelete(
    itemKey: const ValueKey('gallery.rig'),
    onDelete: () {},
    child: ListTile(
      title: const Text('Refractor 400'),
      subtitle: const Text('FOV 3.4° × 2.2° · 1.94″/px'),
      trailing: DeleteButton(tooltip: 'Delete rig', onPressed: () {}),
    ),
  ),
];

/// Every token sample and shared component, in the order the Stage 5
/// Tasks added them: the gallery test audits it, the opt-in render test
/// draws it.
List<Widget> galleryEntries() => [
  ..._surfaces(),
  ..._buttons(),
  ..._fields(),
  ..._menus(),
  ..._status(),
  ..._sections(),
  ..._contextLines(),
  ..._deletable(),
];
