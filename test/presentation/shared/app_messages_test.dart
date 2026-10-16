// S9.8 (TD-081): every message goes through `AppMessages.showMessage`, so
// messages stop sliding when the platform asks for less motion, and keep
// their normal slide otherwise.

import 'dart:io';

import 'package:astroplan/presentation/shared/failure_feedback.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('lib/presentation calls showSnackBar only through AppMessages', () {
    final offenders = [
      for (final f
          in Directory('lib/presentation')
              .listSync(recursive: true)
              .whereType<File>()
              .where((f) => f.path.endsWith('.dart')))
        if (!f.path
                .replaceAll(r'\', '/')
                .endsWith('shared/app_messages.dart') &&
            f.readAsStringSync().contains('.showSnackBar('))
          f.path,
    ];
    expect(offenders, isEmpty);
  });

  Future<Animation<double>?> show(
    WidgetTester tester, {
    required bool reduceMotion,
  }) async {
    await tester.pumpWidget(
      MediaQuery(
        data: MediaQueryData(disableAnimations: reduceMotion),
        child: MaterialApp(
          home: Scaffold(
            body: Builder(
              builder: (context) => TextButton(
                onPressed: () => showDone(context, 'Rig saved'),
                child: const Text('go'),
              ),
            ),
          ),
        ),
      ),
    );
    await tester.tap(find.text('go'));
    await tester.pump(); // the message is added
    await tester.pump(const Duration(milliseconds: 50));
    return tester.widget<SnackBar>(find.byType(SnackBar)).animation;
  }

  testWidgets('TD-081: under reduced motion a message is in place at once', (
    tester,
  ) async {
    final animation = await show(tester, reduceMotion: true);
    expect(animation!.value, 1.0);
    expect(find.text('Rig saved'), findsOneWidget);
  });

  testWidgets('otherwise it still slides in', (tester) async {
    final animation = await show(tester, reduceMotion: false);
    expect(animation!.value, lessThan(1.0));
    await tester.pumpAndSettle();
    expect(find.text('Rig saved'), findsOneWidget);
  });
}
