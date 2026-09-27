// The automated darkness checklist (TASK 12.4, F-46): in field mode every
// rendered pixel is red or black — Tonight, the planner, a dialog, the
// date picker and a snackbar — and the mode is one tap from Tonight and
// survives a restart. The on-device check in real darkness is an owner
// checklist item (docs/TEST_PLAN.md).

import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:astroplan/core/theme/app_theme.dart';
import 'package:astroplan/data/database/app_database.dart';
import 'package:astroplan/data/repositories/drift_equipment_repository.dart';
import 'package:astroplan/data/repositories/drift_location_repository.dart';
import 'package:astroplan/data/repositories/drift_session_repository.dart';
import 'package:astroplan/data/repositories/drift_target_repository.dart';
import 'package:astroplan/domain/repositories/weather_repository.dart';
import 'package:astroplan/main.dart';
import 'package:astroplan/presentation/navigation/app_router.dart';
import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../support/fake_location_service.dart';
import '../../support/in_memory_display_preferences.dart';
import '../../support/no_snapshot_weather.dart';
import '../../support/planner_harness.dart';

class _Weather with NoSnapshotWeather implements WeatherRepository {}

const _shot = Key('screenshot');

void main() {
  late AppDatabase database;
  late PlannerHarness vm;
  late InMemoryDisplayPreferences store;

  Future<void> start(WidgetTester tester, {required bool fieldMode}) async {
    AppRouter.router.go(AppRouter.tonight);
    SharedPreferences.setMockInitialValues({});
    store = InMemoryDisplayPreferences(fieldMode: fieldMode);
    await tester.runAsync(() async {
      database = AppDatabase(NativeDatabase.memory());
      vm = PlannerHarness(
        DriftTargetRepository(database),
        DriftEquipmentRepository(database),
        _Weather(),
        DriftLocationRepository(database),
        locationService: FakeLocationService(),
        sessionRepository: DriftSessionRepository(database),
        displayPreferences: store,
      );
      await vm.ready;
      await vm.theme.load(); // as main.dart does before the first frame
    });
    addTearDown(() => tester.runAsync(database.close));
    await tester.pumpWidget(
      RepaintBoundary(
        key: _shot,
        child: MultiProvider(
          providers: vm.providers,
          child: const AstroPlanApp(),
        ),
      ),
    );
    await settle(tester);
  }

  /// Pixels whose green or blue channel is not zero.
  Future<int> colouredPixels(WidgetTester tester) async {
    final boundary = tester.renderObject<RenderRepaintBoundary>(
      find.byKey(_shot),
    );
    final bytes = (await tester.runAsync(() async {
      final image = await boundary.toImage();
      final data = await image.toByteData(format: ui.ImageByteFormat.rawRgba);
      image.dispose();
      return data!;
    }))!;
    return _countColoured(bytes);
  }

  testWidgets('outside field mode the check does see colour (sanity)', (
    tester,
  ) async {
    await start(tester, fieldMode: false);
    expect(await colouredPixels(tester), greaterThan(0));
  });

  testWidgets('field mode is one tap from Tonight and is saved', (
    tester,
  ) async {
    await start(tester, fieldMode: false);
    await tester.tap(find.byKey(const Key('fieldMode.toggle')));
    await settle(tester);

    expect(vm.theme.isFieldMode, isTrue);
    expect(store.fieldMode, isTrue);
    expect(find.byType(ColorFiltered), findsOneWidget);
    expect(await colouredPixels(tester), 0);
  });

  testWidgets('field mode survives a restart', (tester) async {
    await start(tester, fieldMode: true);
    final context = tester.element(find.text('Tonight').first);
    expect(
      Theme.of(context).scaffoldBackgroundColor,
      AppTheme.fieldTheme.scaffoldBackgroundColor,
    );
    expect(find.byType(ColorFiltered), findsOneWidget);
  });

  testWidgets('darkness checklist: Tonight, planner, date picker, dialog '
      'and snackbar render red only', (tester) async {
    await start(tester, fieldMode: true);
    expect(await colouredPixels(tester), 0, reason: 'Tonight');

    await tester.tap(find.byKey(const Key('tonight.openPlanner')));
    await settle(tester);
    expect(find.byKey(const Key('fieldMode.toggle')), findsOneWidget);
    expect(await colouredPixels(tester), 0, reason: 'planner');

    // S6.2: Copy to another night is in the plan's ⋮ menu.
    await tester.tap(find.byKey(const Key('planner.menu')));
    await settle(tester);
    await tester.tap(find.byKey(const Key('planner.copy')));
    await settle(tester);
    expect(find.byType(DatePickerDialog), findsOneWidget);
    expect(await colouredPixels(tester), 0, reason: 'date picker');
    await tester.tap(find.text('Cancel'));
    await settle(tester);

    final context = tester.element(find.byType(Scaffold).last);
    showDialog<void>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Delete?'),
        actions: [TextButton(onPressed: () {}, child: const Text('Delete'))],
      ),
    );
    await settle(tester);
    expect(await colouredPixels(tester), 0, reason: 'dialog');
    Navigator.of(context).pop();
    await settle(tester);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Saved'),
        action: SnackBarAction(label: 'Undo', onPressed: () {}),
      ),
    );
    await settle(tester);
    expect(find.text('Saved'), findsOneWidget);
    expect(await colouredPixels(tester), 0, reason: 'snackbar');
  });

  testWidgets('Settings has the field-mode switch', (tester) async {
    await start(tester, fieldMode: false);
    AppRouter.router.go(AppRouter.settings);
    await settle(tester);
    final tile = find.byKey(const Key('fieldMode.tile'));
    await tester.scrollUntilVisible(tile, 300);
    await tester.tap(tile);
    await settle(tester);
    expect(store.fieldMode, isTrue);
  });
}

int _countColoured(ByteData bytes) {
  var n = 0;
  for (var i = 0; i < bytes.lengthInBytes; i += 4) {
    if (bytes.getUint8(i + 1) != 0 || bytes.getUint8(i + 2) != 0) n++;
  }
  return n;
}

/// Pumps fixed frames with real-time gaps: database writes and the
/// candidates isolate never let pumpAndSettle finish (TASK 12.2).
Future<void> settle(WidgetTester tester) async {
  for (var i = 0; i < 6; i++) {
    await tester.runAsync(() => Future<void>.delayed(Duration.zero));
    await tester.pump(const Duration(milliseconds: 200));
  }
}
