// S1.5 (ADR-008 §2; RT-03, TD-047): the recovery screen explains which
// case it is, offers a reset only below the floor, and resets only after
// an explicit confirmation; a failed reset is reported, not swallowed.

import 'package:astroplan/domain/repositories/storage_failure.dart';
import 'package:astroplan/presentation/screens/startup/unsupported_database_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  Future<void> pump(
    WidgetTester tester, {
    required bool newer,
    Future<void> Function()? onReset,
  }) => tester.pumpWidget(
    UnsupportedDatabaseApp(
      newerThanApp: newer,
      foundVersion: newer ? 18 : 7,
      onReset: onReset ?? () async {},
    ),
  );

  final reset = find.byKey(const Key('unsupportedDb.reset'));
  final confirm = find.byKey(const Key('unsupportedDb.confirm'));

  testWidgets('newer data: install the newer version; no reset is offered', (
    tester,
  ) async {
    await pump(tester, newer: true);
    expect(find.text('Your data needs a newer version'), findsOneWidget);
    expect(find.textContaining('saved by a newer version'), findsOneWidget);
    expect(find.textContaining('(data version 18)'), findsOneWidget);
    expect(find.textContaining('Nothing has been changed'), findsOneWidget);
    expect(reset, findsNothing);
    expect(find.text('Retry'), findsNothing);
  });

  testWidgets('below the floor: Cancel changes nothing; Start fresh resets '
      'once', (tester) async {
    var resets = 0;
    await pump(tester, newer: false, onReset: () async => resets++);
    expect(find.textContaining('pre-release build'), findsOneWidget);
    expect(find.textContaining('(data version 7)'), findsOneWidget);

    await tester.tap(reset);
    await tester.pumpAndSettle();
    await tester.tap(find.text('Cancel'));
    await tester.pumpAndSettle();
    expect(resets, 0);

    await tester.tap(reset);
    await tester.pumpAndSettle();
    expect(find.textContaining('is not deleted'), findsOneWidget);
    await tester.tap(confirm);
    await tester.pumpAndSettle();
    expect(resets, 1);
  });

  testWidgets('a failed reset is reported and can be tried again', (
    tester,
  ) async {
    await pump(
      tester,
      newer: false,
      onReset: () async =>
          throw const StorageFailure('start with fresh data', 'EACCES'),
    );
    await tester.tap(reset);
    await tester.pumpAndSettle();
    await tester.tap(confirm);
    await tester.pumpAndSettle();
    expect(find.byType(SnackBar), findsOneWidget);
    expect(tester.widget<FilledButton>(reset).onPressed, isNotNull);
  });

  for (final newer in [true, false]) {
    for (final brightness in Brightness.values) {
      testWidgets(
        'accessible at 200 % text (newer: $newer, ${brightness.name})',
        (tester) async {
          tester.platformDispatcher.platformBrightnessTestValue = brightness;
          addTearDown(
            tester.platformDispatcher.clearPlatformBrightnessTestValue,
          );
          tester.view.physicalSize = const Size(412, 915);
          tester.view.devicePixelRatio = 1;
          tester.platformDispatcher.textScaleFactorTestValue = 2;
          addTearDown(tester.view.reset);
          addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);
          final semantics = tester.ensureSemantics();
          await pump(tester, newer: newer);
          expect(tester.takeException(), isNull, reason: 'no overflow');
          await expectLater(tester, meetsGuideline(androidTapTargetGuideline));
          await expectLater(tester, meetsGuideline(labeledTapTargetGuideline));
          await expectLater(tester, meetsGuideline(textContrastGuideline));
          semantics.dispose();
        },
      );
    }
  }
}
