import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:astroplan/presentation/screens/target/target_selection_screen.dart';
import 'package:astroplan/domain/repositories/target_repository.dart';
import 'package:astroplan/domain/models/astro_target.dart';

import 'package:astroplan/presentation/viewmodels/library_viewmodels.dart';
import 'package:astroplan/presentation/viewmodels/session_plan_viewmodel.dart';

class MockTargetRepository implements TargetRepository {
  final List<AstroTarget> _targets = [];

  @override
  Future<T> inOneTransaction<T>(Future<T> Function() writes) => writes();

  @override
  Future<List<AstroTarget>> searchTargets(String query) async => _targets;

  @override
  Future<AstroTarget?> getTargetById(int id) async => null;

  @override
  Future<int> insertTarget(AstroTarget target) async {
    _targets.add(target);
    return 1;
  }

  final List<AstroTarget> updated = [];

  @override
  Future<void> updateTarget(AstroTarget target) async => updated.add(target);

  @override
  Future<void> deleteTarget(int id) async {}

  Future<void> clearAll() async {}

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class MockSessionPlanViewModel extends ChangeNotifier
    implements SessionPlanViewModel {
  AstroTarget? _selectedTarget;

  @override
  AstroTarget? get selectedTarget => _selectedTarget;

  @override
  Future<void> setTarget(AstroTarget target) async {
    _selectedTarget = target;
    notifyListeners();
  }

  @override
  Future<void> refreshSelectedTarget() async {}

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

void main() {
  Widget createTestWidget(TargetRepository repo, SessionPlanViewModel planner) {
    return MultiProvider(
      providers: [
        Provider<TargetRepository>.value(value: repo),
        ChangeNotifierProvider(create: (_) => TargetsViewModel(repo)),
        ChangeNotifierProvider<SessionPlanViewModel>.value(value: planner),
      ],
      child: const MaterialApp(home: TargetSelectionScreen()),
    );
  }

  testWidgets('empty required target fields are rejected', (
    WidgetTester tester,
  ) async {
    final repo = MockTargetRepository();
    final planner = MockSessionPlanViewModel();

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

  // TASK 8.1 changed the input format: RA is entered in hours (h:m:s or
  // decimal hours, or degrees only with an explicit °), Dec in d:m:s or
  // decimal degrees. The four tests below used to type bare degrees and
  // expect the old "Must be a number" / "Must be 0.0 to 360.0" messages; they
  // now check the same rules (garbage, RA out of range, Dec out of range,
  // valid input saves) in the new format.
  final raField = find.widgetWithText(
    TextFormField,
    'Right ascension (J2000) *',
  );
  final decField = find.widgetWithText(TextFormField, 'Declination (J2000) *');
  const raError = 'Use hours: 05h35m17s, 5:35:17 or 5.588 (or degrees: 83.82°)';
  const decError = 'Use −05°23′28″, -5:23:28 or -5.391 (within ±90°)';

  Future<void> openAddDialog(
    WidgetTester tester,
    MockTargetRepository repo,
  ) async {
    await tester.pumpWidget(createTestWidget(repo, MockSessionPlanViewModel()));
    await tester.pumpAndSettle();
    await tester.tap(find.byType(FloatingActionButton));
    await tester.pumpAndSettle();
    await tester.enterText(
      find.widgetWithText(TextFormField, 'Name *'),
      'Test Target',
    );
  }

  Future<void> save(WidgetTester tester) async {
    await tester.tap(find.text('Save'));
    await tester.pump();
  }

  testWidgets('non-numeric input is rejected for RA and Dec', (tester) async {
    await openAddDialog(tester, MockTargetRepository());
    await tester.enterText(raField, 'abc');
    await tester.enterText(decField, 'xyz');
    await save(tester);
    expect(find.text(raError), findsOneWidget);
    expect(find.text(decError), findsOneWidget);
  });

  testWidgets('out of bounds RA is rejected', (tester) async {
    await openAddDialog(tester, MockTargetRepository());
    await tester.enterText(decField, '45');
    for (final bad in ['-1', '24:00:00', '5:60:00', '360.1°', '83.82']) {
      await tester.enterText(raField, bad);
      await save(tester);
      expect(find.text(raError), findsOneWidget, reason: bad);
    }
  });

  testWidgets('out of bounds Dec is rejected', (tester) async {
    await openAddDialog(tester, MockTargetRepository());
    await tester.enterText(raField, '12h00m00s');
    for (final bad in ['-91', '90:00:01', '45 60 00']) {
      await tester.enterText(decField, bad);
      await save(tester);
      expect(find.text(decError), findsOneWidget, reason: bad);
    }
  });

  testWidgets('HMS/DMS input is stored as the correct degrees (acceptance)', (
    tester,
  ) async {
    final repo = MockTargetRepository();
    await openAddDialog(tester, repo);
    await tester.enterText(raField, '05h35m17s');
    await tester.enterText(decField, '−05°23′28″');
    await tester.tap(find.text('Save'));
    await tester.pumpAndSettle();

    expect(find.text(raError), findsNothing);
    expect(find.text(decError), findsNothing);
    final saved = repo._targets.single;
    expect(saved.rightAscension, closeTo(83.820833, 1e-6));
    expect(saved.declination, closeTo(-5.391111, 1e-6));
    expect(saved.catalogId, 'Test Target');
    expect(saved.source, 'user');
    expect(saved.epoch, 'J2000');
    expect(find.text('Test Target'), findsOneWidget);
  });

  testWidgets('moving types are not offered for a new target', (tester) async {
    await openAddDialog(tester, MockTargetRepository());
    await tester.tap(find.text('Galaxy'));
    await tester.pumpAndSettle();
    for (final moving in ['Planet', 'Moon', 'Comet', 'Asteroid']) {
      expect(find.text(moving), findsNothing, reason: moving);
    }
    expect(find.text('Nebula'), findsWidgets);
  });

  testWidgets('an edit keeps the catalog ID; a moving type stays, labelled', (
    tester,
  ) async {
    final repo = MockTargetRepository();
    repo._targets.add(
      const AstroTarget(
        id: 7,
        catalogId: 'C/2025 X1',
        commonName: 'A comet',
        rightAscension: 83.820833,
        declination: -5.391111,
        type: 'Comet',
        source: 'user',
      ),
    );
    await tester.pumpWidget(createTestWidget(repo, MockSessionPlanViewModel()));
    await tester.pumpAndSettle();
    expect(find.textContaining('this object moves'), findsOneWidget);

    await tester.tap(find.byTooltip('Edit target'));
    await tester.pumpAndSettle();
    expect(find.text('Catalog ID: C/2025 X1'), findsOneWidget);
    expect(find.widgetWithText(TextFormField, '05h35m17.0s'), findsOneWidget);
    expect(find.widgetWithText(TextFormField, '−05°23′28″'), findsOneWidget);
    await tester.enterText(
      find.widgetWithText(TextFormField, 'Name *'),
      'Renamed',
    );
    await tester.tap(find.text('Save'));
    await tester.pumpAndSettle();

    final edited = repo.updated.single;
    expect(edited.catalogId, 'C/2025 X1');
    expect(edited.commonName, 'Renamed');
    expect(edited.type, 'Comet', reason: 'never retyped silently');
  });

  testWidgets('a rename keeps the exact coordinates and the source', (
    tester,
  ) async {
    final repo = MockTargetRepository();
    repo._targets.add(
      const AstroTarget(
        id: 3,
        catalogId: 'M42',
        commonName: 'Orion Nebula',
        rightAscension: 83.82208333,
        declination: -5.39111111,
        type: 'Nebula',
        source: 'seed:catalog@1',
      ),
    );
    await tester.pumpWidget(createTestWidget(repo, MockSessionPlanViewModel()));
    await tester.pumpAndSettle();
    await tester.tap(find.byTooltip('Edit target'));
    await tester.pumpAndSettle();
    await tester.enterText(
      find.widgetWithText(TextFormField, 'Name *'),
      'Great Orion Nebula',
    );
    await tester.tap(find.text('Save'));
    await tester.pumpAndSettle();

    final edited = repo.updated.single;
    expect(edited.rightAscension, 83.82208333);
    expect(edited.declination, -5.39111111);
    expect(edited.source, 'seed:catalog@1');
    expect(edited.catalogId, 'M42');
  });
}
