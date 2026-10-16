// S11.C2 (Stage 11's host blockers, S11H-01 to S11H-03):
// - the rig editor's derived sensor size and its note meet AA contrast
//   (they used the disabled colour and a half-transparent onSurface);
// - "Altitude now" uses QuantityText (a typographic minus, never "-0.0°");
// - the zone picker marks the current zone by more than colour.

import 'package:astroplan/core/theme/app_theme.dart';
import 'package:astroplan/core/time/clock.dart';
import 'package:astroplan/data/database/app_database.dart' show AppDatabase;
import 'package:astroplan/data/repositories/drift_equipment_repository.dart';
import 'package:astroplan/data/repositories/drift_location_repository.dart';
import 'package:astroplan/data/repositories/drift_session_repository.dart';
import 'package:astroplan/data/repositories/drift_target_repository.dart';
import 'package:astroplan/data/services/catalog_seeder.dart';
import 'package:astroplan/data/services/equipment_seeder.dart';
import 'package:astroplan/domain/models/location_profile.dart' as domain;
import 'package:astroplan/domain/repositories/weather_repository.dart';
import 'package:astroplan/main.dart';
import 'package:astroplan/presentation/navigation/app_router.dart';
import 'package:astroplan/presentation/screens/equipment/equipment_editor.dart';
import 'package:astroplan/presentation/screens/sites/zone_picker_dialog.dart';
import 'package:astroplan/presentation/shared/equipment_draft.dart';
import 'package:astroplan/presentation/viewmodels/library_viewmodels.dart';
import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../support/fake_device_time_zone.dart';
import '../support/fake_location_service.dart';
import '../support/fake_reverse_geocoder.dart';
import '../support/in_memory_equipment_repository.dart';
import '../support/no_snapshot_weather.dart';
import '../support/planner_harness.dart';

class _NoForecast with NoSnapshotWeather implements WeatherRepository {}

Future<void> _settle(WidgetTester tester) async {
  for (var i = 0; i < 10; i++) {
    await tester.runAsync(
      () => Future<void>.delayed(const Duration(milliseconds: 20)),
    );
    await tester.pump(const Duration(milliseconds: 100));
  }
}

void main() {
  for (final (name, theme) in [
    ('light', AppTheme.light),
    ('dark', AppTheme.dark),
  ]) {
    testWidgets('S11H-01: the rig editor meets text contrast ($name)', (
      tester,
    ) async {
      tester.view.physicalSize = const Size(412, 915);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.reset);
      await tester.pumpWidget(
        ChangeNotifierProvider(
          create: (_) => GearViewModel(InMemoryEquipmentRepository()),
          child: MaterialApp(
            theme: theme,
            home: Scaffold(
              body: Builder(
                builder: (context) => TextButton(
                  onPressed: () => showEquipmentEditor(
                    context,
                    draft: EquipmentDraft.fromProfile(
                      EquipmentSeeder.defaults.single,
                    ),
                  ),
                  child: const Text('open'),
                ),
              ),
            ),
          ),
        ),
      );
      await tester.tap(find.text('open'));
      await tester.pumpAndSettle();
      final note = find.text('Auto-calculated from Resolution × Pixel Size');
      expect(note, findsOneWidget);
      // The derived fields sit below the fold: the guideline checks only
      // what is on screen.
      await tester.ensureVisible(note);
      await tester.pumpAndSettle();
      await expectLater(tester, meetsGuideline(textContrastGuideline));
    });
  }

  testWidgets('S11H-02: "Altitude now" below the horizon reads with a '
      'typographic minus', (tester) async {
    tester.view.physicalSize = const Size(412, 915);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);
    late AppDatabase db;
    late PlannerHarness vm;
    await tester.runAsync(() async {
      db = AppDatabase(NativeDatabase.memory());
      await CatalogSeeder(DriftTargetRepository(db)).seedIfNeeded();
      await EquipmentSeeder(DriftEquipmentRepository(db)).seedIfNeeded();
      final siteId = await DriftLocationRepository(db).insertLocation(
        domain.LocationProfile(
          id: 0,
          name: 'Ljubljana',
          latitude: 46.05,
          longitude: 14.51,
          timeZoneId: 'Europe/Ljubljana',
        ),
      );
      SharedPreferences.setMockInitialValues({'activeLocationId': siteId});
      // Noon in Ljubljana: M42 is well below the horizon.
      final clock = FixedClock(DateTime.utc(2026, 11, 10, 11));
      vm = PlannerHarness(
        DriftTargetRepository(db),
        DriftEquipmentRepository(db),
        _NoForecast(),
        DriftLocationRepository(db),
        locationService: FakeLocationService(),
        reverseGeocoder: FakeReverseGeocoder(),
        deviceTimeZone: FakeDeviceTimeZone(),
        clock: clock,
        sessionRepository: DriftSessionRepository(db, clock: clock),
      );
      await vm.ready;
      await vm.choosePlan();
    });
    addTearDown(() => tester.runAsync(db.close));
    AppRouter.router.go(AppRouter.session());
    await tester.pumpWidget(
      MultiProvider(providers: vm.providers, child: const AstroPlanApp()),
    );
    await _settle(tester);
    final altitude = vm.conditions.currentAltitude!;
    expect(altitude, lessThan(0));
    expect(find.text('Altitude now'), findsOneWidget);
    expect(find.text('−${altitude.abs().toStringAsFixed(1)}°'), findsOneWidget);
    expect(find.textContaining('-'), findsNothing, reason: 'no hyphen-minus');
  });

  testWidgets('S11H-03: the zone picker marks the current zone with a check, '
      'not colour alone', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Builder(
            builder: (context) => TextButton(
              onPressed: () =>
                  showZonePicker(context, current: 'Europe/Ljubljana'),
              child: const Text('open'),
            ),
          ),
        ),
      ),
    );
    await tester.tap(find.text('open'));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextField), 'Ljubljana');
    await tester.pumpAndSettle();
    final row = find.widgetWithText(ListTile, 'Europe/Ljubljana');
    expect(
      find.descendant(of: row, matching: find.byIcon(Icons.check)),
      findsOneWidget,
    );
    expect(
      find.descendant(
        of: find.widgetWithText(ListTile, 'Unknown'),
        matching: find.byIcon(Icons.check),
      ),
      findsNothing,
    );
  });
}
