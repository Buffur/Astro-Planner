// TASK 8.2: the About page credits the catalog (OpenNGC, CC BY-SA 4.0) with
// its full bundled notice, and the other data sources.

import 'dart:io';

import 'package:astroplan/presentation/screens/about/about_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('shows the OpenNGC notice and the other credits', (tester) async {
    final notice = File(AboutScreen.noticeAsset).readAsStringSync();
    tester.view.physicalSize = const Size(800, 3000);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(
      MaterialApp(home: AboutScreen(loadNotice: () async => notice)),
    );
    await tester.pumpAndSettle();

    expect(find.textContaining('Mattia Verga'), findsOneWidget);
    expect(find.textContaining('CC BY-SA 4.0'), findsWidgets);
    expect(find.textContaining('OpenStreetMap contributors'), findsOneWidget);
    expect(find.textContaining('Open-Meteo'), findsOneWidget);
    expect(find.text('Open-source licences'), findsOneWidget);
  });
}
