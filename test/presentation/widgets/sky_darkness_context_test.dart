// TASK 7.4: the sky card states the known sky darkness with its source, or
// says it is unknown — never a default value. Since S6.7 the detail is one
// tap away and the collapsed summary states the values, or "Unknown".

import 'package:astroplan/core/time/clock.dart';
import 'package:astroplan/data/database/app_database.dart';
import 'package:astroplan/data/repositories/drift_equipment_repository.dart';
import 'package:astroplan/data/repositories/drift_location_repository.dart';
import 'package:astroplan/data/repositories/drift_target_repository.dart';
import 'package:astroplan/domain/models/calendar_date.dart';
import 'package:astroplan/domain/models/location_profile.dart' as domain;
import 'package:astroplan/domain/repositories/weather_repository.dart';

import '../../support/planner_harness.dart';

import 'package:astroplan/presentation/widgets/sky_darkness_widget.dart';
import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../support/fake_device_time_zone.dart';
import '../../support/fake_location_service.dart';
import '../../support/fake_reverse_geocoder.dart';
import '../../support/no_snapshot_weather.dart';

class _NoWeather with NoSnapshotWeather implements WeatherRepository {}

void main() {
  Future<void> pumpCard(WidgetTester tester, {int? bortle, double? sqm}) async {
    late AppDatabase database;
    late PlannerHarness vm;
    await tester.runAsync(() async {
      database = AppDatabase(NativeDatabase.memory());
      final locations = DriftLocationRepository(database);
      final id = await locations.insertLocation(
        domain.LocationProfile(
          id: 0,
          name: 'Site',
          latitude: 46.05,
          longitude: 14.51,
          elevation: 300,
          bortleClass: bortle,
          bortleSource: bortle == null ? null : 'user',
          bortleDate: bortle == null ? null : CalendarDate(2026, 9, 23),
          sqm: sqm,
          sqmSource: sqm == null ? null : 'meter',
          sqmDate: sqm == null ? null : CalendarDate(2026, 8, 1),
        ),
      );
      SharedPreferences.setMockInitialValues({'activeLocationId': id});
      vm = PlannerHarness(
        DriftTargetRepository(database),
        DriftEquipmentRepository(database),
        _NoWeather(),
        locations,
        locationService: FakeLocationService(),
        reverseGeocoder: FakeReverseGeocoder(),
        deviceTimeZone: FakeDeviceTimeZone(),
        clock: FixedClock(DateTime.utc(2026, 9, 23, 12)),
      );
      await vm.ready;
    });
    addTearDown(() => tester.runAsync(database.close));
    await tester.pumpWidget(
      MultiProvider(
        providers: vm.providers,
        child: const MaterialApp(
          home: Scaffold(
            body: SingleChildScrollView(child: SkyDarknessWidget()),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
  }

  /// S6.7: the detail is one tap away.
  Future<void> open(WidgetTester tester) async {
    await tester.tap(find.text('Sky darkness'));
    await tester.pumpAndSettle();
  }

  testWidgets('unknown sky darkness says so and how to add it', (tester) async {
    await pumpCard(tester);
    expect(find.text('Unknown'), findsOneWidget); // the summary (S6.7)
    await open(tester);
    expect(
      // S1.8 (UX-20): names both entry points — the picker and the editor.
      find.text(
        'Sky darkness unknown — pick a Bortle class above, or add Bortle '
        'or SQM in the site editor.',
      ),
      findsOneWidget,
    );
    expect(find.text('Bortle ?'), findsOneWidget);
  });

  testWidgets('known values are shown with their sources, unconverted', (
    tester,
  ) async {
    await pumpCard(tester, bortle: 4, sqm: 21.3);
    expect(find.text('Bortle 4 · SQM 21.30 mag/arcsec²'), findsOneWidget);
    await open(tester);
    expect(
      find.text(
        'Bortle 4 (user, 2026-09-23) · '
        'SQM 21.30 mag/arcsec² (meter, 2026-08-01)',
      ),
      findsOneWidget,
    );
  });

  testWidgets('an SQM reading alone is not turned into a Bortle class', (
    tester,
  ) async {
    await pumpCard(tester, sqm: 19.0);
    expect(find.text('SQM 19.00 mag/arcsec²'), findsOneWidget);
    await open(tester);
    expect(
      find.text('SQM 19.00 mag/arcsec² (meter, 2026-08-01)'),
      findsOneWidget,
    );
    expect(find.text('Bortle ?'), findsOneWidget);
  });
}
