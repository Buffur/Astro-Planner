// TASK 8.2: the About page credits the catalog (OpenNGC, CC BY-SA 4.0) with
// its full bundled notice, and the other data sources. TASK 16.3 (the
// roadmap's attribution test): every third-party credit, the app's licence
// with its source, and the privacy summary with the policy link.

import 'dart:io';

import 'package:astroplan/core/config/app_identity.dart';
import 'package:astroplan/presentation/screens/about/about_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  Future<void> pumpAbout(WidgetTester tester) async {
    final notice = File(AboutScreen.noticeAsset).readAsStringSync();
    tester.view.physicalSize = const Size(800, 3000);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(
      MaterialApp(home: AboutScreen(loadNotice: () async => notice)),
    );
    await tester.pumpAndSettle();
  }

  testWidgets('shows the OpenNGC notice and the other credits', (tester) async {
    await pumpAbout(tester);
    expect(find.textContaining('Mattia Verga'), findsOneWidget);
    expect(find.textContaining('CC BY-SA 4.0'), findsWidgets);
    expect(find.textContaining('OpenStreetMap contributors'), findsOneWidget);
    expect(
      find.textContaining('Weather data by Open-Meteo.com'),
      findsOneWidget,
    );
    expect(find.textContaining('CC BY 4.0'), findsOneWidget);
    expect(find.textContaining('lightpollutionmap.app'), findsOneWidget);
    expect(find.text('Open-source licences'), findsOneWidget);
  });

  testWidgets('states the GPL-3.0 licence with a link to the source', (
    tester,
  ) async {
    await pumpAbout(tester);
    final licence = tester.widget<Text>(find.byKey(const Key('about.licence')));
    expect(licence.data, contains('GPL-3.0'));
    expect(licence.data, contains(AppIdentity.appName));
    expect(licence.data, contains(AppIdentity.version));
    expect(find.byKey(const Key('about.source')), findsOneWidget);
    expect(AppIdentity.sourceUrl, startsWith('https://'));
  });

  testWidgets('summarises privacy and links the policy', (tester) async {
    await pumpAbout(tester);
    final privacy = tester.widget<Text>(find.byKey(const Key('about.privacy')));
    for (final phrase in [
      'No account, no ads, no analytics',
      'stay on this device',
      'Open-Meteo',
      'OpenStreetMap',
      'Nominatim',
      'if you switch it on in Settings',
    ]) {
      expect(privacy.data, contains(phrase));
    }
    expect(find.byKey(const Key('about.privacyPolicy')), findsOneWidget);
    expect(AppIdentity.privacyPolicyUrl, startsWith('https://'));
    expect(AppIdentity.privacyPolicyUrl, endsWith('/privacy/'));
  });
}
