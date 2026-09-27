// The design-system gallery's harness (S5.1): pumps shared components in a
// theme at a text scale on a phone-width view and audits them with the
// accessibility sweep's guidelines. The route sweep cannot see a component
// no route uses yet, nor a dialog; the gallery can.

import 'package:astroplan/core/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

enum GalleryTheme { light, dark, field }

ThemeData galleryThemeData(GalleryTheme theme) => switch (theme) {
  GalleryTheme.light => AppTheme.light,
  GalleryTheme.dark => AppTheme.dark,
  GalleryTheme.field => AppTheme.fieldTheme,
};

/// Pumps [children] as one scrolling page, 412 logical px wide (a phone)
/// and tall enough that no entry is clipped by scrolling (a clipped node
/// reports a false tap-target size).
Future<void> pumpGallery(
  WidgetTester tester, {
  required GalleryTheme theme,
  required double textScale,
  required List<Widget> children,
}) async {
  tester.view.physicalSize = const Size(412, 12000);
  tester.view.devicePixelRatio = 1.0;
  tester.platformDispatcher.textScaleFactorTestValue = textScale;
  addTearDown(tester.view.reset);
  addTearDown(tester.platformDispatcher.clearAllTestValues);
  await tester.pumpWidget(
    MaterialApp(
      theme: galleryThemeData(theme),
      home: Scaffold(
        body: ListView(padding: const EdgeInsets.all(16), children: children),
      ),
    ),
  );
  await tester.pumpAndSettle();
}

/// Every problem on the page: layout exceptions (overflow), Android's
/// 48 px tap targets, labels on tappable elements and, when [contrast],
/// WCAG AA text contrast. Field mode's secondary red is below AA by design
/// (ARCHITECTURE B16), so its contrast is not asserted.
Future<List<String>> auditGallery(
  WidgetTester tester, {
  required bool contrast,
}) async {
  final problems = <String>[];
  Object? error;
  while ((error = tester.takeException()) != null) {
    problems.add('exception: ${error.toString().split('\n').first}');
  }
  for (final g in [
    androidTapTargetGuideline,
    labeledTapTargetGuideline,
    if (contrast) textContrastGuideline,
  ]) {
    final result = await g.evaluate(tester);
    if (!result.passed) problems.add('${g.description}: ${result.reason}');
  }
  return problems;
}
