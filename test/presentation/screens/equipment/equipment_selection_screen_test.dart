import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:astroplan/presentation/screens/equipment/equipment_selection_screen.dart';
import 'package:astroplan/domain/repositories/equipment_repository.dart';
import 'package:astroplan/domain/models/equipment_profile.dart';
import 'package:astroplan/presentation/viewmodels/planner_viewmodel.dart';

class MockEquipmentRepository implements EquipmentRepository {
  final List<EquipmentProfile> _profiles = [];

  @override
  Future<List<EquipmentProfile>> getAllEquipment() async => _profiles;

  @override
  Future<EquipmentProfile?> getEquipmentById(int id) async => null;

  @override
  Future<int> insertEquipment(EquipmentProfile equipment) async {
    _profiles.add(equipment);
    return 1;
  }

  @override
  Future<void> updateEquipment(EquipmentProfile equipment) async {}

  @override
  Future<void> deleteEquipment(int id) async {}

  Future<void> clearAll() async {}
}

class MockPlannerViewModel extends ChangeNotifier implements PlannerViewModel {
  EquipmentProfile? _selectedEquipment;

  @override
  EquipmentProfile? get selectedEquipment => _selectedEquipment;

  @override
  Future<void> setEquipment(EquipmentProfile profile) async {
    _selectedEquipment = profile;
    notifyListeners();
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

void main() {
  Widget createTestWidget(EquipmentRepository repo, PlannerViewModel planner) {
    return MultiProvider(
      providers: [
        Provider<EquipmentRepository>.value(value: repo),
        ChangeNotifierProvider<PlannerViewModel>.value(value: planner),
      ],
      child: const MaterialApp(
        home: EquipmentSelectionScreen(),
      ),
    );
  }

  testWidgets('empty required field is rejected', (WidgetTester tester) async {
    final repo = MockEquipmentRepository();
    final planner = MockPlannerViewModel();

    await tester.pumpWidget(createTestWidget(repo, planner));
    await tester.pumpAndSettle();

    // Tap FloatingActionButton to add equipment
    await tester.tap(find.byType(FloatingActionButton));
    await tester.pumpAndSettle();

    // Tap save without entering anything
    await tester.tap(find.text('Save'));
    await tester.pump();

    // Validation errors should appear
    expect(find.text('Required'), findsWidgets);
  });

  testWidgets('non-numeric input is rejected', (WidgetTester tester) async {
    final repo = MockEquipmentRepository();
    final planner = MockPlannerViewModel();

    await tester.pumpWidget(createTestWidget(repo, planner));
    await tester.pumpAndSettle();

    await tester.tap(find.byType(FloatingActionButton));
    await tester.pumpAndSettle();

    // Enter valid name
    await tester.enterText(find.widgetWithText(TextFormField, 'Profile Name'), 'Test Profile');

    // Enter non-numeric in Resolution Width (hint: '6248')
    await tester.enterText(find.widgetWithText(TextFormField, '6248'), 'abc');

    await tester.tap(find.text('Save'));
    await tester.pump();

    // Validation error should appear
    expect(find.text('Invalid'), findsWidgets);
  });

  testWidgets('zero is rejected where invalid', (WidgetTester tester) async {
    final repo = MockEquipmentRepository();
    final planner = MockPlannerViewModel();

    await tester.pumpWidget(createTestWidget(repo, planner));
    await tester.pumpAndSettle();

    await tester.tap(find.byType(FloatingActionButton));
    await tester.pumpAndSettle();

    await tester.enterText(find.widgetWithText(TextFormField, 'Profile Name'), 'Test Profile');
    await tester.enterText(find.widgetWithText(TextFormField, '6248'), '0');

    await tester.tap(find.text('Save'));
    await tester.pump();

    expect(find.text('> 0'), findsWidgets);
  });

  testWidgets('valid values can still be saved', (WidgetTester tester) async {
    final repo = MockEquipmentRepository();
    final planner = MockPlannerViewModel();

    await tester.pumpWidget(createTestWidget(repo, planner));
    await tester.pumpAndSettle();

    await tester.tap(find.byType(FloatingActionButton));
    await tester.pumpAndSettle();

    // We must enter all required fields because they now validate
    await tester.enterText(find.widgetWithText(TextFormField, 'Profile Name'), 'Valid Rig');
    
    // Find inputs by hint text to target specific Stellarium rows
    final resW = find.widgetWithText(TextFormField, '6248');
    final resH = find.widgetWithText(TextFormField, '4176');
    final pixelW = find.widgetWithText(TextFormField, '3.76').first;
    final pixelH = find.widgetWithText(TextFormField, '3.76').last;
    final sensorW = find.widgetWithText(TextFormField, '23.50');
    final sensorH = find.widgetWithText(TextFormField, '15.70');
    final focal = find.widgetWithText(TextFormField, 'Effective Focal Length (mm)');
    final aperture = find.widgetWithText(TextFormField, 'Effective Aperture (f/)');

    await tester.enterText(resW, '6000');
    await tester.enterText(resH, '4000');
    await tester.enterText(pixelW, '3.76');
    await tester.enterText(pixelH, '3.76');
    await tester.enterText(sensorW, '23.5');
    await tester.enterText(sensorH, '15.7');
    await tester.enterText(focal, '400');
    await tester.enterText(aperture, '5.6');

    await tester.tap(find.text('Save'));
    await tester.pumpAndSettle();

    // Dialog should close, no validation errors
    expect(find.text('Required'), findsNothing);
    expect(find.text('Invalid'), findsNothing);
    expect(find.text('> 0'), findsNothing);
    expect(find.text('Must be > 0'), findsNothing);
    
    // The list should now contain "Valid Rig"
    expect(find.text('Valid Rig'), findsOneWidget);
  });
}
