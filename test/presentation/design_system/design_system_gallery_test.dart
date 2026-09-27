// The design-system gallery (S5.1): every shared token sample and, from
// S5.2 on, every shared control and component (with a dialog, a message and
// an open menu over it), in the light, dark and field themes at
// 100 % and 200 % text, audited like the route sweep (overflow, 48 px tap
// targets, labels, AA contrast in light and dark). Each Stage 5 Task adds
// its components to `galleryEntries` (gallery_entries.dart).

import 'package:astroplan/presentation/shared/confirmation_patterns.dart';
import 'package:astroplan/presentation/shared/delete_patterns.dart';
import 'package:astroplan/presentation/shared/failure_feedback.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'gallery_entries.dart';
import 'gallery_harness.dart';

/// S5.2: opens a dialog, a message and a menu over the gallery in turn and
/// audits each.
Future<List<String>> _auditOverlays(
  WidgetTester tester, {
  required bool contrast,
}) async {
  final problems = <String>[];
  final context = tester.element(find.byType(ListView));

  // S5.8: the shared confirmation for a stored record.
  confirmDestructive(
    context,
    title: 'Delete rig "Refractor 400"?',
    message: 'Plans that use it keep their saved values.',
  );
  await tester.pumpAndSettle();
  expect(find.byType(AlertDialog), findsOneWidget);
  problems.addAll(
    (await auditGallery(
      tester,
      contrast: contrast,
    )).map((p) => 'confirmation: $p'),
  );
  await tester.tap(find.byKey(const Key('confirm.cancel')));
  await tester.pumpAndSettle();

  // S5.8: the unsaved-changes prompt.
  askUnsavedChanges(context, plan: 'M42 · Fri, Nov 13');
  await tester.pumpAndSettle();
  expect(find.text('Unsaved changes'), findsOneWidget);
  problems.addAll(
    (await auditGallery(tester, contrast: contrast)).map((p) => 'prompt: $p'),
  );
  await tester.tap(find.byKey(const Key('unsaved.cancel')));
  await tester.pumpAndSettle();

  // S5.8: the undo message, then the success message replacing it.
  showUndo(context, message: 'Block deleted', onUndo: () {});
  await tester.pumpAndSettle();
  expect(find.text('Block deleted'), findsOneWidget);
  problems.addAll(
    (await auditGallery(tester, contrast: contrast)).map((p) => 'undo: $p'),
  );
  showDone(context, 'Copied to Sat, Nov 14');
  await tester.pumpAndSettle();
  expect(find.text('Copied to Sat, Nov 14'), findsOneWidget);
  problems.addAll(
    (await auditGallery(tester, contrast: contrast)).map((p) => 'done: $p'),
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
  for (final theme in GalleryTheme.values) {
    for (final scale in [1.0, 2.0]) {
      testWidgets('the detail template meets the guidelines: ${theme.name}, '
          '${(scale * 100).round()} % text', (tester) async {
        await pumpGalleryPage(
          tester,
          theme: theme,
          textScale: scale,
          page: galleryDetailPage(),
        );
        expect(find.byKey(const Key('detail.zone')), findsOneWidget);
        expect(
          await auditGallery(tester, contrast: theme != GalleryTheme.field),
          isEmpty,
        );
      });
    }
  }

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
          children: galleryEntries(),
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
