// The design-system gallery (S5.1): every shared token sample and, from
// S5.2 on, every shared control and component (with a dialog, a message and
// an open menu over it), in the light, dark and field themes at
// 100 % and 200 % text, audited like the route sweep (overflow, 48 px tap
// targets, labels, AA contrast in light and dark). Each Stage 5 Task adds
// its components to `_entries`.

import 'package:astroplan/core/theme/app_button_styles.dart';
import 'package:astroplan/core/theme/app_palette.dart';
import 'package:astroplan/core/theme/app_spacing.dart';
import 'package:astroplan/domain/services/fit_analyzer.dart';
import 'package:astroplan/presentation/shared/collapsible_section.dart';
import 'package:astroplan/presentation/shared/plan_state.dart';
import 'package:astroplan/presentation/shared/status_block.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'gallery_harness.dart';

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
        PopupMenuItem(value: 2, child: Text('Track live (optional)')),
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

List<Widget> _entries() => [
  ..._surfaces(),
  ..._buttons(),
  ..._fields(),
  ..._menus(),
  ..._status(),
  ..._sections(),
];

/// S5.2: opens a dialog, a message and a menu over the gallery in turn and
/// audits each.
Future<List<String>> _auditOverlays(
  WidgetTester tester, {
  required bool contrast,
}) async {
  final problems = <String>[];
  final context = tester.element(find.byType(ListView));

  showDialog<void>(
    context: context,
    builder: (context) => AlertDialog(
      title: const Text('Delete this rig?'),
      content: const Text('Plans that use it keep their saved values.'),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        TextButton(
          style: AppButtonStyles.destructiveText(Theme.of(context).colorScheme),
          onPressed: () => Navigator.pop(context),
          child: const Text('Delete'),
        ),
      ],
    ),
  );
  await tester.pumpAndSettle();
  expect(find.byType(AlertDialog), findsOneWidget);
  problems.addAll(
    (await auditGallery(tester, contrast: contrast)).map((p) => 'dialog: $p'),
  );
  await tester.tap(find.text('Cancel').last);
  await tester.pumpAndSettle();

  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: const Text('Block deleted'),
      action: SnackBarAction(label: 'Undo', onPressed: () {}),
    ),
  );
  await tester.pumpAndSettle();
  expect(find.text('Block deleted'), findsOneWidget);
  problems.addAll(
    (await auditGallery(tester, contrast: contrast)).map((p) => 'message: $p'),
  );
  ScaffoldMessenger.of(context).removeCurrentSnackBar();
  await tester.pumpAndSettle();

  await tester.tap(find.byKey(const Key('gallery.menu')));
  await tester.pumpAndSettle();
  expect(find.text('Copy to another night'), findsOneWidget);
  problems.addAll(
    (await auditGallery(tester, contrast: contrast)).map((p) => 'menu: $p'),
  );
  return problems;
}

void main() {
  testWidgets('the audit does see a problem (sanity)', (tester) async {
    await pumpGallery(
      tester,
      theme: GalleryTheme.light,
      textScale: 1,
      children: [
        const Text('Too faint', style: TextStyle(color: Color(0xFFD0D0D0))),
        IconButton(onPressed: () {}, icon: const Icon(Icons.add)),
      ],
    );
    final problems = await auditGallery(tester, contrast: true);
    expect(problems, hasLength(2)); // the contrast and the missing label
  });

  for (final theme in GalleryTheme.values) {
    for (final scale in [1.0, 2.0]) {
      testWidgets('the gallery meets the guidelines: ${theme.name}, '
          '${(scale * 100).round()} % text', (tester) async {
        await pumpGallery(
          tester,
          theme: theme,
          textScale: scale,
          children: _entries(),
        );
        final contrast = theme != GalleryTheme.field;
        final problems = [
          ...await auditGallery(tester, contrast: contrast),
          ...await _auditOverlays(tester, contrast: contrast),
        ];
        expect(problems, isEmpty);
      });
    }
  }
}
