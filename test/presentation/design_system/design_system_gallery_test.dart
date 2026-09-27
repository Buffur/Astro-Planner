// The design-system gallery (S5.1): every shared token sample and, from
// S5.2 on, every shared component, in the light, dark and field themes at
// 100 % and 200 % text, audited like the route sweep (overflow, 48 px tap
// targets, labels, AA contrast in light and dark). Each Stage 5 Task adds
// its components to `_entries`.

import 'package:astroplan/core/theme/app_palette.dart';
import 'package:astroplan/core/theme/app_spacing.dart';
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

List<Widget> _entries() => [..._surfaces()];

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
        final problems = await auditGallery(
          tester,
          contrast: theme != GalleryTheme.field,
        );
        expect(problems, isEmpty);
      });
    }
  }
}
