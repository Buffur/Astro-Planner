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
    // S9.5: the notice, and the catalog's credit with its link.
    expect(find.textContaining('Mattia Verga'), findsWidgets);
    expect(find.textContaining('CC BY-SA 4.0'), findsWidgets);
    expect(find.textContaining('OpenStreetMap contributors'), findsOneWidget);
    expect(
      find.textContaining('Weather data by Open-Meteo.com'),
      findsOneWidget,
    );
    expect(find.textContaining('CC BY 4.0'), findsOneWidget);
    expect(find.textContaining('lightpollutionmap.app'), findsWidgets);
    expect(find.text('Open-source licences'), findsOneWidget);
  });

  // S9.5 (08 §23, D9-4): the author first, apart from third-party credit,
  // with Reddit prominent; every source a link.
  testWidgets('the author block comes first, with Reddit and GitHub', (
    tester,
  ) async {
    await pumpAbout(tester);
    final author = find.byKey(const Key('about.author'));
    expect(
      find.descendant(of: author, matching: find.text('Made by Buffur')),
      findsOneWidget,
    );
    expect(
      find.descendant(of: author, matching: find.byType(FilledButton)),
      findsOneWidget,
      reason: 'Reddit is the prominent link',
    );
    expect(find.byKey(const Key('about.reddit')), findsOneWidget);
    expect(find.byKey(const Key('about.github')), findsOneWidget);
    expect(AboutScreen.authorReddit, 'https://www.reddit.com/user/Buffur/');
    expect(AboutScreen.authorGitHub, 'https://github.com/Buffur');
    expect(
      tester.getTopLeft(author).dy,
      lessThan(tester.getTopLeft(find.text('Data sources')).dy),
    );
    expect(
      tester.widget<Text>(find.byKey(const Key('about.version'))).data,
      'Version ${AppIdentity.version}',
    );
  });

  testWidgets('every data source has its link', (tester) async {
    await pumpAbout(tester);
    for (final key in [
      'about.openngc',
      'about.osm',
      'about.openMeteo',
      'about.lightPollution',
    ]) {
      expect(
        find.descendant(
          of: find.byKey(Key(key)),
          matching: find.byType(TextButton),
        ),
        findsOneWidget,
        reason: key,
      );
    }
    expect(find.text('openstreetmap.org/copyright'), findsOneWidget);
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
