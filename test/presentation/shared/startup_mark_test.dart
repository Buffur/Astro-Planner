// S13.3 (ID-6 = S2): the startup mark breathes only while shown, is still
// when the platform asks for less motion, and is announced as loading.

import 'package:astroplan/presentation/shared/startup_mark.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

Widget _host({required bool disableAnimations}) => MediaQuery(
  data: MediaQueryData(disableAnimations: disableAnimations),
  child: const MaterialApp(
    home: Scaffold(body: Center(child: StartupMark())),
  ),
);

void main() {
  testWidgets('the star breathes while the mark is shown', (tester) async {
    await tester.pumpWidget(_host(disableAnimations: false));
    expect(tester.hasRunningAnimations, isTrue);
    await tester.pump(const Duration(milliseconds: 800));
    expect(tester.hasRunningAnimations, isTrue);
    // Gone with the loading view: nothing keeps ticking.
    await tester.pumpWidget(const MaterialApp(home: Scaffold()));
    expect(tester.hasRunningAnimations, isFalse);
  });

  testWidgets('still when animations are off', (tester) async {
    await tester.pumpWidget(_host(disableAnimations: true));
    expect(tester.hasRunningAnimations, isFalse);
    expect(find.byType(StartupMark), findsOneWidget);
  });

  testWidgets('announced as loading, with no progress value', (tester) async {
    final semantics = tester.ensureSemantics();
    await tester.pumpWidget(_host(disableAnimations: true));
    expect(find.bySemanticsLabel('Loading'), findsOneWidget);
    expect(find.byType(LinearProgressIndicator), findsNothing);
    expect(find.byType(CircularProgressIndicator), findsNothing);
    semantics.dispose();
  });
}
