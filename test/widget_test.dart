import 'package:flutter_test/flutter_test.dart';
import 'package:astroplan/main.dart';

void main() {
  testWidgets('App should boot and show home screen showcase', (WidgetTester tester) async {
    await tester.pumpWidget(const AstroPlanApp());
    await tester.pumpAndSettle();

    expect(find.text('Phase 3: Design System'), findsOneWidget);
  });
}

