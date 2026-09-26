// S3.7 (ADR-018 §7): "Add from a photo" on the equipment screen opens the
// metadata import; a rig saved there appears when the user comes back.

import 'package:astroplan/domain/models/equipment_profile.dart';
import 'package:astroplan/presentation/navigation/app_router.dart';
import 'package:astroplan/presentation/screens/equipment/equipment_selection_screen.dart';
import 'package:astroplan/presentation/viewmodels/library_viewmodels.dart';
import 'package:astroplan/presentation/viewmodels/session_plan_viewmodel.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../../support/in_memory_equipment_repository.dart';

class _Planner extends ChangeNotifier implements SessionPlanViewModel {
  int refreshes = 0;

  @override
  EquipmentProfile? get selectedEquipment => null;

  @override
  Future<void> refreshSelectedEquipment() async => refreshes++;

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

const _imported = EquipmentProfile(
  id: 0,
  name: 'Imported phone',
  sensorWidthMm: 9.89,
  sensorHeightMm: 7.42,
  pixelPitchUm: 2.414,
  resolutionWidthPx: 4096,
  resolutionHeightPx: 3072,
  focalLengthMm: 6.57,
  focalRatio: 1.6,
);

void main() {
  testWidgets('Add from a photo opens the import; a rig saved there is '
      'listed on return', (tester) async {
    final repo = InMemoryEquipmentRepository();
    final planner = _Planner();
    final router = GoRouter(
      routes: [
        GoRoute(
          path: '/',
          builder: (context, state) => const EquipmentSelectionScreen(),
        ),
        GoRoute(
          path: AppRouter.metadata,
          builder: (context, state) => Scaffold(
            appBar: AppBar(title: const Text('Import stand-in')),
            body: TextButton(
              onPressed: () async {
                await repo.insertEquipment(_imported);
                if (context.mounted) context.pop();
              },
              child: const Text('save a rig and return'),
            ),
          ),
        ),
      ],
    );
    await tester.pumpWidget(
      MultiProvider(
        providers: [
          ChangeNotifierProvider(create: (_) => GearViewModel(repo)),
          ChangeNotifierProvider<SessionPlanViewModel>.value(value: planner),
        ],
        child: MaterialApp.router(routerConfig: router),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.text('No equipment profiles found.'), findsOneWidget);

    final button = find.byKey(const Key('rigs.addFromPhoto'));
    expect(button, findsOneWidget);
    expect(find.byTooltip('Add from a photo'), findsOneWidget);
    expect(find.byTooltip('Add rig'), findsOneWidget, reason: 'Add stays');

    await tester.tap(button);
    await tester.pumpAndSettle();
    expect(find.text('Import stand-in'), findsOneWidget);
    await tester.tap(find.text('save a rig and return'));
    await tester.pumpAndSettle();

    expect(find.text('Imported phone'), findsOneWidget);
    expect(planner.refreshes, 1);
  });
}
