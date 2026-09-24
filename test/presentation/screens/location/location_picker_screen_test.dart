// Widget tests for the location picker (TASK 7.2): permission outcomes are
// explained with the right remedy, coordinates can be typed (offline, no
// permission needed), and the OpenStreetMap attribution is visible.

import 'package:astroplan/core/config/app_identity.dart';
import 'package:astroplan/data/database/app_database.dart';
import 'package:astroplan/data/repositories/drift_equipment_repository.dart';
import 'package:astroplan/data/repositories/drift_location_repository.dart';
import 'package:astroplan/data/repositories/drift_target_repository.dart';
import 'package:astroplan/domain/repositories/weather_repository.dart';
import 'package:astroplan/domain/services/location_service.dart';
import 'package:astroplan/presentation/screens/location/location_picker_screen.dart';
import 'package:astroplan/presentation/shared/location_failure_text.dart';

import '../../../support/planner_harness.dart';

import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../support/fake_location_service.dart';
import '../../../support/fake_reverse_geocoder.dart';
import '../../../support/no_snapshot_weather.dart';

class _NoWeather with NoSnapshotWeather implements WeatherRepository {}

void main() {
  late AppDatabase database;
  late PlannerHarness vm;
  late FakeLocationService service;

  setUp(() => SharedPreferences.setMockInitialValues({}));

  Future<void> pumpPicker(
    WidgetTester tester, {
    DeviceLocation? location,
    LocationFailure failure = LocationFailure.permissionDenied,
  }) async {
    service = FakeLocationService(location: location, failure: failure);
    await tester.runAsync(() async {
      database = AppDatabase(NativeDatabase.memory());
      vm = PlannerHarness(
        DriftTargetRepository(database),
        DriftEquipmentRepository(database),
        _NoWeather(),
        DriftLocationRepository(database),
        locationService: service,
        reverseGeocoder: FakeReverseGeocoder(),
      );
      await vm.ready;
    });
    addTearDown(() => tester.runAsync(database.close));
    await tester.pumpWidget(
      MultiProvider(
        providers: vm.providers,
        child: const MaterialApp(home: LocationPickerScreen()),
      ),
    );
    await tester.pump();
  }

  Future<void> tapCurrentLocation(WidgetTester tester) async {
    await tester.tap(find.text('Current Location'));
    await tester.pump();
    // Let the snack bar finish sliding in.
    await tester.pump(const Duration(seconds: 1));
  }

  testWidgets(
    'a permanently denied permission explains and opens app settings',
    (tester) async {
      await pumpPicker(
        tester,
        failure: LocationFailure.permissionDeniedForever,
      );
      final startupCalls = service.calls;

      await tapCurrentLocation(tester);

      expect(service.calls, startupCalls + 1);
      expect(
        find.text(
          LocationFailureText.message(LocationFailure.permissionDeniedForever),
        ),
        findsOneWidget,
      );
      await tester.tap(find.text('Open settings'));
      await tester.pump();
      expect(service.appSettingsOpened, 1);
      expect(service.locationSettingsOpened, 0);
    },
  );

  testWidgets('location services off explains and opens location settings', (
    tester,
  ) async {
    await pumpPicker(tester, failure: LocationFailure.serviceDisabled);

    await tapCurrentLocation(tester);

    expect(
      find.text(LocationFailureText.message(LocationFailure.serviceDisabled)),
      findsOneWidget,
    );
    await tester.tap(find.text('Open settings'));
    await tester.pump();
    expect(service.locationSettingsOpened, 1);
  });

  testWidgets('a plain denial explains why, with no settings action', (
    tester,
  ) async {
    await pumpPicker(tester, failure: LocationFailure.permissionDenied);

    await tapCurrentLocation(tester);

    expect(
      find.text(LocationFailureText.message(LocationFailure.permissionDenied)),
      findsOneWidget,
    );
    expect(find.text('Open settings'), findsNothing);
  });

  testWidgets(
    'granted: the fix moves the marker but is not used until confirmed',
    (tester) async {
      await pumpPicker(
        tester,
        location: const DeviceLocation(latitude: 46.05, longitude: 14.51),
      );
      final before = (vm.latitude, vm.longitude);

      await tapCurrentLocation(tester);

      final marker = tester.widget<MarkerLayer>(find.byType(MarkerLayer));
      expect(marker.markers.single.point.latitude, 46.05);
      expect(marker.markers.single.point.longitude, 14.51);
      expect((vm.latitude, vm.longitude), before);
    },
  );

  testWidgets('typed coordinates are validated and move the marker', (
    tester,
  ) async {
    await pumpPicker(tester);

    await tester.tap(find.byTooltip('Enter coordinates'));
    await tester.pumpAndSettle();
    final fields = find.byType(TextFormField);
    await tester.enterText(fields.at(0), '95');
    await tester.enterText(fields.at(1), '14.51');
    await tester.tap(find.text('Use'));
    await tester.pump();
    expect(find.text('Latitude must be between -90 and 90'), findsOneWidget);

    await tester.enterText(fields.at(0), '46,05');
    await tester.tap(find.text('Use'));
    await tester.pumpAndSettle();

    expect(find.byType(AlertDialog), findsNothing);
    final marker = tester.widget<MarkerLayer>(find.byType(MarkerLayer));
    expect(marker.markers.single.point.latitude, 46.05);
    expect(marker.markers.single.point.longitude, 14.51);
  });

  testWidgets('the map shows the OpenStreetMap attribution', (tester) async {
    await pumpPicker(tester);

    expect(find.text('OpenStreetMap contributors'), findsOneWidget);
    final tiles = tester.widget<TileLayer>(find.byType(TileLayer));
    expect(
      tiles.tileProvider.headers['User-Agent'],
      AppIdentity.userAgent, // with a contact URL (TASK 16.3)
    );
  });
}
