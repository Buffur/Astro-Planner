// S5.7 (ADR-019 §9; addendum §3.4–§3.5): the detail-screen template. The
// title is a header, the context and the zone rule follow it, the zone
// rule appears exactly once, the summary comes before the sections, and
// the title and context wrap at 200 % text instead of overflowing.

import 'package:astroplan/core/theme/app_theme.dart';
import 'package:astroplan/presentation/shared/detail_scaffold.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

const _zone = 'Times in site zone Europe/Ljubljana, CET, UTC+01:00';

Future<void> _pump(WidgetTester tester, {double textScale = 1}) async {
  tester.view.physicalSize = const Size(412, 4000);
  tester.view.devicePixelRatio = 1.0;
  tester.platformDispatcher.textScaleFactorTestValue = textScale;
  addTearDown(tester.view.reset);
  addTearDown(tester.platformDispatcher.clearAllTestValues);
  await tester.pumpWidget(
    MaterialApp(
      theme: AppTheme.light,
      home: const DetailScaffold(
        title: 'Night & Moon',
        context: 'Fri, Nov 13 · Dark-sky site near the observatory',
        zoneRule: _zone,
        summary: Text('Dark 19:40 – 04:20'),
        sections: [Text('Twilight section'), Text('Moon section')],
      ),
    ),
  );
}

void main() {
  testWidgets('the header, then the summary, then the sections; the zone '
      'rule once', (tester) async {
    final handle = tester.ensureSemantics();
    await _pump(tester);
    expect(find.text(_zone), findsOneWidget);
    expect(
      tester.getSemantics(find.byKey(const Key('detail.title'))),
      matchesSemantics(label: 'Night & Moon', isHeader: true),
    );
    double top(Finder f) => tester.getTopLeft(f).dy;
    final title = top(find.byKey(const Key('detail.title')));
    final ctx = top(find.byKey(const Key('detail.context')));
    final zone = top(find.byKey(const Key('detail.zone')));
    final summary = top(find.text('Dark 19:40 – 04:20'));
    final first = top(find.text('Twilight section'));
    final second = top(find.text('Moon section'));
    expect([
      title,
      ctx,
      zone,
      summary,
      first,
      second,
    ], orderedEquals([title, ctx, zone, summary, first, second]..sort()));
    expect(find.byType(Divider), findsOneWidget); // between the sections
    handle.dispose();
  });

  testWidgets('at 200 % text the title and context wrap, without overflow', (
    tester,
  ) async {
    await _pump(tester, textScale: 2);
    expect(tester.takeException(), isNull);
    final line = tester.getSize(find.byKey(const Key('detail.title'))).height;
    expect(
      tester.getSize(find.byKey(const Key('detail.context'))).height,
      greaterThan(line), // more than one line: it wrapped
    );
    expect(
      tester.getSize(find.byKey(const Key('detail.context'))).width,
      lessThanOrEqualTo(412),
    );
  });
}
