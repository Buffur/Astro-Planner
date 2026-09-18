import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:astroplan/presentation/screens/target/target_selection_screen.dart';
import 'package:astroplan/domain/repositories/target_repository.dart';
import 'package:astroplan/domain/models/astro_target.dart';
import 'package:astroplan/presentation/viewmodels/planner_viewmodel.dart';

class MockTargetRepository implements TargetRepository {
  final List<AstroTarget> _targets = [];

  @override
  Future<List<AstroTarget>> searchTargets(String query) async => _targets;

  @override
  Future<AstroTarget?> getTargetById(int id) async => null;

  @override
  Future<int> insertTarget(AstroTarget target) async {
    _targets.add(target);
    return 1;
  }

  @override
  Future<void> updateTarget(AstroTarget target) async {}

  @override
  Future<void> deleteTarget(int id) async {}

  @override
  Future<void> clearAll() async {}

  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class MockPlannerViewModel extends ChangeNotifier implements PlannerViewModel {
  AstroTarget? _selectedTarget;

  @override
  AstroTarget? get selectedTarget => _selectedTarget;

  @override
  Future<void> setTarget(AstroTarget target) async {
    _selectedTarget = target;
    notifyListeners();
  }

  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

void main() {
  Widget createTestWidget(TargetRepository repo, PlannerViewModel planner) {
    return MultiProvider(
      providers: [
        Provider<TargetRepository>.value(value: repo),
        ChangeNotifierProvider<PlannerViewModel>.value(value: planner),
      ],
      child: const MaterialApp(
        home: TargetSelectionScreen(),
      ),
    );
  }

  testWidgets('empty required target fields are rejected', (WidgetTester tester) async {
    final repo = MockTargetRepository();
    final planner = MockPlannerViewModel();

    await tester.pumpWidget(createTestWidget(repo, planner));
    await tester.pumpAndSettle();

    // Tap FloatingActionButton to add custom target
    await tester.tap(find.byType(FloatingActionButton));
    await tester.pumpAndSettle();

    // Tap save without entering anything
    await tester.tap(find.text('Save'));
    await tester.pump();

    // Validation errors should appear for all 3 required fields
    expect(find.text('Required'), findsNWidgets(3));
  });

  testWidgets('non-numeric input is rejected for RA and Dec', (WidgetTester tester) async {
    final repo = MockTargetRepository();
    final planner = MockPlannerViewModel();

    await tester.pumpWidget(createTestWidget(repo, planner));
    await tester.pumpAndSettle();

    await tester.tap(find.byType(FloatingActionButton));
    await tester.pumpAndSettle();

    await tester.enterText(find.widgetWithText(TextFormField, 'Target Name *'), 'Test Target');
    await tester.enterText(find.widgetWithText(TextFormField, '0.0 to 360.0'), 'abc'); // RA
    await tester.enterText(find.widgetWithText(TextFormField, '-90.0 to +90.0'), 'xyz'); // Dec

    await tester.tap(find.text('Save'));
    await tester.pump();

    // Validation error should appear
    expect(find.text('Must be a number'), findsNWidgets(2));
  });

  testWidgets('out of bounds RA is rejected', (WidgetTester tester) async {
    final repo = MockTargetRepository();
    final planner = MockPlannerViewModel();

    await tester.pumpWidget(createTestWidget(repo, planner));
    await tester.pumpAndSettle();

    await tester.tap(find.byType(FloatingActionButton));
    await tester.pumpAndSettle();

    await tester.enterText(find.widgetWithText(TextFormField, 'Target Name *'), 'Test Target');
    await tester.enterText(find.widgetWithText(TextFormField, '0.0 to 360.0'), '-10.0'); // RA
    await tester.enterText(find.widgetWithText(TextFormField, '-90.0 to +90.0'), '45.0'); // Dec

    await tester.tap(find.text('Save'));
    await tester.pump();

    expect(find.text('Must be 0.0 to 360.0'), findsOneWidget);

    await tester.enterText(find.widgetWithText(TextFormField, '0.0 to 360.0'), '360.1'); // RA
    await tester.tap(find.text('Save'));
    await tester.pump();

    expect(find.text('Must be 0.0 to 360.0'), findsOneWidget);
  });

  testWidgets('out of bounds Dec is rejected', (WidgetTester tester) async {
    final repo = MockTargetRepository();
    final planner = MockPlannerViewModel();

    await tester.pumpWidget(createTestWidget(repo, planner));
    await tester.pumpAndSettle();

    await tester.tap(find.byType(FloatingActionButton));
    await tester.pumpAndSettle();

    await tester.enterText(find.widgetWithText(TextFormField, 'Target Name *'), 'Test Target');
    await tester.enterText(find.widgetWithText(TextFormField, '0.0 to 360.0'), '180.0'); // RA
    await tester.enterText(find.widgetWithText(TextFormField, '-90.0 to +90.0'), '-91.0'); // Dec

    await tester.tap(find.text('Save'));
    await tester.pump();

    expect(find.text('Must be -90.0 to +90.0'), findsOneWidget);
    
    await tester.enterText(find.widgetWithText(TextFormField, '-90.0 to +90.0'), '90.1'); // Dec
    await tester.tap(find.text('Save'));
    await tester.pump();

    expect(find.text('Must be -90.0 to +90.0'), findsOneWidget);
  });

  testWidgets('valid values can still be saved', (WidgetTester tester) async {
    final repo = MockTargetRepository();
    final planner = MockPlannerViewModel();

    await tester.pumpWidget(createTestWidget(repo, planner));
    await tester.pumpAndSettle();

    await tester.tap(find.byType(FloatingActionButton));
    await tester.pumpAndSettle();

    await tester.enterText(find.widgetWithText(TextFormField, 'Target Name *'), 'Andromeda');
    await tester.enterText(find.widgetWithText(TextFormField, '0.0 to 360.0'), '10.6847'); // RA
    await tester.enterText(find.widgetWithText(TextFormField, '-90.0 to +90.0'), '41.2687'); // Dec

    await tester.tap(find.text('Save'));
    await tester.pumpAndSettle();

    // Dialog should close, no validation errors
    expect(find.text('Required'), findsNothing);
    expect(find.text('Must be a number'), findsNothing);
    expect(find.text('Must be 0.0 to 360.0'), findsNothing);
    expect(find.text('Must be -90.0 to +90.0'), findsNothing);
    
    // The list should now contain "Andromeda"
    expect(find.text('Andromeda'), findsOneWidget);
  });
}
