import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:astroplan/presentation/screens/equipment/equipment_selection_screen.dart';
import 'package:astroplan/domain/repositories/equipment_repository.dart';
import 'package:astroplan/domain/models/equipment_profile.dart';
import 'package:astroplan/domain/models/tracking_type.dart';
import 'package:astroplan/domain/models/spec_confidence.dart';
import 'package:astroplan/data/services/equipment_seeder.dart';
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

  final List<EquipmentProfile> updated = [];

  @override
  Future<void> updateEquipment(EquipmentProfile equipment) async =>
      updated.add(equipment);

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
  Future<void> refreshSelectedEquipment() async {}

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
      child: const MaterialApp(home: EquipmentSelectionScreen()),
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
    await tester.enterText(
      find.widgetWithText(TextFormField, 'Profile Name'),
      'Test Profile',
    );

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

    await tester.enterText(
      find.widgetWithText(TextFormField, 'Profile Name'),
      'Test Profile',
    );
    await tester.enterText(find.widgetWithText(TextFormField, '6248'), '0');

    await tester.tap(find.text('Save'));
    await tester.pump();

    // TASK 8.4 (ADR-011 §4): bounds replaced "> 0"; a zero resolution now
    // shows the plausibility range with its unit.
    expect(find.text('Must be 100–30000 px'), findsWidgets);
  });

  testWidgets('valid values can still be saved', (WidgetTester tester) async {
    final repo = MockEquipmentRepository();
    final planner = MockPlannerViewModel();

    await tester.pumpWidget(createTestWidget(repo, planner));
    await tester.pumpAndSettle();

    await tester.tap(find.byType(FloatingActionButton));
    await tester.pumpAndSettle();

    // We must enter all required fields because they now validate
    await tester.enterText(
      find.widgetWithText(TextFormField, 'Profile Name'),
      'Valid Rig',
    );

    // Find inputs by hint text to target specific Stellarium rows
    final resW = find.widgetWithText(TextFormField, '6248');
    final resH = find.widgetWithText(TextFormField, '4176');
    final pixelW = find.widgetWithText(TextFormField, '3.76').first;
    final pixelH = find.widgetWithText(TextFormField, '3.76').last;
    final sensorW = find.widgetWithText(TextFormField, '23.50');
    final sensorH = find.widgetWithText(TextFormField, '15.70');
    final focal = find.widgetWithText(
      TextFormField,
      'Effective Focal Length (mm)',
    );
    // TASK 8.4 relabelled the f/ field (ADR-011 §3: unit-explicit names).
    final aperture = find.widgetWithText(TextFormField, 'Focal ratio (f/)');

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

  testWidgets(
    'the pixel-pitch label renders µm, not mojibake (TASK 4.3, TD-015)',
    (WidgetTester tester) async {
      final repo = MockEquipmentRepository();
      await repo.insertEquipment(
        const EquipmentProfile(
          id: 1,
          name: 'Test Rig',
          sensorWidthMm: 23.5,
          sensorHeightMm: 15.7,
          pixelPitchUm: 3.76,
          resolutionWidthPx: 6248,
          resolutionHeightPx: 4176,
          focalLengthMm: 400.0,
          focalRatio: 5.6,
        ),
      );

      await tester.pumpWidget(createTestWidget(repo, MockPlannerViewModel()));
      await tester.pumpAndSettle();

      // Asserting the correct text is enough; tool/check_encoding.dart is
      // what guards against the old mojibake creeping back into source, and
      // a literal mojibake string in this file would itself trip that check.
      expect(find.textContaining('µm'), findsOneWidget);

      await tester.tap(find.byIcon(Icons.edit_outlined));
      await tester.pumpAndSettle();

      // The "Pixel Size" row's unit label, and the "Rotation (°)" field.
      expect(find.text('µm'), findsOneWidget);
      expect(find.text('Rotation (°)'), findsOneWidget);
    },
  );

  // TASK 8.4 (ADR-011)
  Future<void> tallView(WidgetTester tester) async {
    tester.view.physicalSize = const Size(900, 2400);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);
  }

  Future<void> fillSensor(WidgetTester tester) async {
    await tester.enterText(
      find.widgetWithText(TextFormField, 'Profile Name'),
      'Refractor',
    );
    await tester.enterText(find.widgetWithText(TextFormField, '6248'), '6248');
    await tester.enterText(find.widgetWithText(TextFormField, '4176'), '4176');
    await tester.enterText(
      find.widgetWithText(TextFormField, '3.76').first,
      '3.76',
    );
  }

  final focalField = find.widgetWithText(
    TextFormField,
    'Effective Focal Length (mm)',
  );
  final ratioField = find.widgetWithText(TextFormField, 'Focal ratio (f/)');
  final diameterField = find.widgetWithText(
    TextFormField,
    'Aperture diameter (mm)',
  );

  testWidgets('a diameter derives the focal ratio (N = f / D) and is saved', (
    tester,
  ) async {
    await tallView(tester);
    final repo = MockEquipmentRepository();
    await tester.pumpWidget(createTestWidget(repo, MockPlannerViewModel()));
    await tester.pumpAndSettle();
    await tester.tap(find.byType(FloatingActionButton));
    await tester.pumpAndSettle();

    await fillSensor(tester);
    await tester.enterText(focalField, '400');
    await tester.enterText(diameterField, '72');
    await tester.pump();
    expect(
      tester
          .widget<EditableText>(
            find.descendant(
              of: ratioField,
              matching: find.byType(EditableText),
            ),
          )
          .controller
          .text,
      '5.56',
    );
    expect(find.text('From focal length ÷ diameter'), findsOneWidget);

    // Open the tracking dropdown (showing "Unknown") and pick "Guided".
    await tester.tap(find.text('Unknown'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Guided').last);
    await tester.pumpAndSettle();
    await tester.enterText(
      find.widgetWithText(TextFormField, 'Maximum sub-exposure (s)'),
      '300',
    );
    await tester.tap(find.text('Save'));
    await tester.pumpAndSettle();

    final saved = repo._profiles.single;
    expect(saved.focalRatio, closeTo(400 / 72, 1e-9));
    expect(saved.apertureDiameterMm, 72);
    expect(saved.trackingType, TrackingType.guided);
    expect(saved.maxExposureS, 300);
    expect(find.textContaining('f/5.6'), findsOneWidget);
  });

  testWidgets('a ratio above f/32 is rejected by the form', (tester) async {
    await tallView(tester);
    final repo = MockEquipmentRepository();
    await tester.pumpWidget(createTestWidget(repo, MockPlannerViewModel()));
    await tester.pumpAndSettle();
    await tester.tap(find.byType(FloatingActionButton));
    await tester.pumpAndSettle();

    await fillSensor(tester);
    await tester.enterText(focalField, '400');
    await tester.enterText(ratioField, '72');
    await tester.tap(find.text('Save'));
    await tester.pumpAndSettle();

    expect(find.text('Must be 0.5–32'), findsOneWidget);
    expect(repo._profiles, isEmpty);
  });

  testWidgets('a stored f/72 is flagged for review, never converted', (
    tester,
  ) async {
    await tallView(tester);
    final repo = MockEquipmentRepository();
    await repo.insertEquipment(
      const EquipmentProfile(
        id: 5,
        name: 'Old scope',
        sensorWidthMm: 23.5,
        sensorHeightMm: 15.7,
        pixelPitchUm: 3.76,
        resolutionWidthPx: 6248,
        resolutionHeightPx: 4176,
        focalLengthMm: 400,
        focalRatio: 72,
      ),
    );
    await tester.pumpWidget(createTestWidget(repo, MockPlannerViewModel()));
    await tester.pumpAndSettle();
    expect(find.textContaining('f/72 — please review'), findsOneWidget);

    await tester.tap(find.byIcon(Icons.edit_outlined));
    await tester.pumpAndSettle();
    expect(find.textContaining('Please review'), findsOneWidget);
    expect(
      tester
          .widget<EditableText>(
            find.descendant(
              of: ratioField,
              matching: find.byType(EditableText),
            ),
          )
          .controller
          .text,
      '72',
      reason: 'the stored value is shown as it is',
    );

    // The user fixes it by entering the diameter.
    await tester.enterText(diameterField, '72');
    await tester.pump();
    await tester.tap(find.text('Save Changes'));
    await tester.pumpAndSettle();
    final fixed = repo.updated.single;
    expect(fixed.focalRatio, closeTo(400 / 72, 1e-9));
    expect(fixed.apertureDiameterMm, 72);
  });

  testWidgets('every equipment number shows its unit', (tester) async {
    await tallView(tester);
    await tester.pumpWidget(
      createTestWidget(MockEquipmentRepository(), MockPlannerViewModel()),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.byType(FloatingActionButton));
    await tester.pumpAndSettle();
    for (final label in [
      'px',
      'µm',
      'mm',
      'Effective Focal Length (mm)',
      'Focal ratio (f/)',
      'Aperture diameter (mm)',
      'Maximum sub-exposure (s)',
      'Average RAW File Size (MB)',
      'Rotation (°)',
    ]) {
      expect(find.text(label), findsWidgets, reason: label);
    }
  });

  // TASK 8.5
  testWidgets('saving a verified seed unchanged keeps it verified, and the '
      'editor shows the provenance', (tester) async {
    await tallView(tester);
    final repo = MockEquipmentRepository();
    final seed = EquipmentSeeder.defaults.single;
    await repo.insertEquipment(
      EquipmentProfile(
        id: 9,
        name: seed.name,
        manufacturer: seed.manufacturer,
        cameraModel: seed.cameraModel,
        sensorWidthMm: seed.sensorWidthMm,
        sensorHeightMm: seed.sensorHeightMm,
        pixelPitchUm: seed.pixelPitchUm,
        resolutionWidthPx: seed.resolutionWidthPx,
        resolutionHeightPx: seed.resolutionHeightPx,
        focalLengthMm: seed.focalLengthMm,
        focalRatio: seed.focalRatio,
        apertureDiameterMm: seed.apertureDiameterMm,
        cameraSource: seed.cameraSource,
        cameraConfidence: seed.cameraConfidence,
        opticsSource: seed.opticsSource,
        opticsConfidence: seed.opticsConfidence,
      ),
    );
    await tester.pumpWidget(createTestWidget(repo, MockPlannerViewModel()));
    await tester.pumpAndSettle();
    await tester.tap(find.byIcon(Icons.edit_outlined));
    await tester.pumpAndSettle();
    expect(find.textContaining('Camera specs: verified'), findsOneWidget);
    expect(find.textContaining('Optics: estimated'), findsOneWidget);

    await tester.tap(find.text('Save Changes'));
    await tester.pumpAndSettle();
    final saved = repo.updated.single;
    expect(saved.cameraConfidence, SpecConfidence.verified);
    expect(saved.opticsConfidence, SpecConfidence.estimated);
    expect(saved.sensorWidthMm, seed.sensorWidthMm);
    expect(saved.focalRatio, seed.focalRatio);
  });
}
