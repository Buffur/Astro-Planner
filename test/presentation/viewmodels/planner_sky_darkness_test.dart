// TASK 7.4 (PD-05): no scraping, no network call on a location change;
// sky darkness is unknown until the user enters it, with its source; the
// sky warning uses a known Bortle class only — SQM is never converted.

import 'dart:io';

import 'package:astroplan/core/time/clock.dart';
import 'package:astroplan/data/database/app_database.dart';
import 'package:astroplan/data/repositories/drift_equipment_repository.dart';
import 'package:astroplan/data/repositories/drift_location_repository.dart';
import 'package:astroplan/data/repositories/drift_target_repository.dart';
import 'package:astroplan/domain/models/astro_target.dart' as model;
import 'package:astroplan/domain/models/calendar_date.dart';
import 'package:astroplan/domain/models/location_profile.dart' as domain;
import 'package:astroplan/domain/repositories/weather_repository.dart';

import '../../support/planner_harness.dart';

import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../support/fake_device_time_zone.dart';
import '../../support/fake_location_service.dart';
import '../../support/fake_reverse_geocoder.dart';
import '../../support/no_snapshot_weather.dart';

class _NoWeather with NoSnapshotWeather implements WeatherRepository {}

/// Counts every HttpClient anything tries to create.
class _CountingHttpOverrides extends HttpOverrides {
  int created = 0;

  @override
  HttpClient createHttpClient(SecurityContext? context) {
    created++;
    return super.createHttpClient(context);
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late AppDatabase database;
  late DriftLocationRepository locations;

  setUp(() {
    SharedPreferences.setMockInitialValues({});
    database = AppDatabase(NativeDatabase.memory());
    locations = DriftLocationRepository(database);
  });

  tearDown(() => database.close());

  // 2026-09-11 is a new Moon, so the Moon cannot trigger the warning.
  Future<PlannerHarness> build() async {
    final vm = PlannerHarness(
      DriftTargetRepository(database),
      DriftEquipmentRepository(database),
      _NoWeather(),
      locations,
      locationService: FakeLocationService(),
      reverseGeocoder: FakeReverseGeocoder(),
      deviceTimeZone: FakeDeviceTimeZone(),
      clock: FixedClock(DateTime.utc(2026, 9, 11, 12)),
    );
    await vm.ready;
    return vm;
  }

  Future<int> siteWith({int? bortle, double? sqm}) => locations.insertLocation(
    domain.LocationProfile(
      id: 0,
      name: 'Site',
      latitude: 46.05,
      longitude: 14.51,
      elevation: 300,
      bortleClass: bortle,
      bortleSource: bortle == null ? null : 'user',
      bortleDate: bortle == null ? null : CalendarDate(2026, 9, 1),
      sqm: sqm,
      sqmSource: sqm == null ? null : 'meter',
      sqmDate: sqm == null ? null : CalendarDate(2026, 9, 1),
    ),
  );

  test('a location change makes no network call', () async {
    final overrides = _CountingHttpOverrides();
    await HttpOverrides.runWithHttpOverrides(() async {
      final vm = await build();
      await vm.setLocation(46.05, 14.51);
      await vm.setLocation(37.77, -122.42);
      await Future<void>.delayed(Duration.zero);
      expect(vm.skyDarkness.isUnknown, isTrue);
    }, overrides);
    expect(overrides.created, 0);
  });

  test('no scraping code remains in lib/', () {
    final offenders = Directory('lib')
        .listSync(recursive: true)
        .whereType<File>()
        .where((f) => f.path.endsWith('.dart'))
        .where((f) {
          final source = f.readAsStringSync();
          return source.contains('clearoutside') ||
              source.contains('LightPollutionRepository') ||
              source.contains('fetchBortleClass');
        })
        .map((f) => f.path)
        .toList();
    expect(offenders, isEmpty);
  });

  test('a site without values is unknown', () async {
    final id = await siteWith();
    final vm = await build();
    await vm.selectSite(id);

    expect(vm.skyDarkness.isUnknown, isTrue);
    expect(vm.lunarIllumination!, lessThan(0.1));
  });

  test('a site\'s Bortle and SQM come with their sources', () async {
    final id = await siteWith(bortle: 4, sqm: 21.3);
    final vm = await build();
    await vm.selectSite(id);

    final d = vm.skyDarkness;
    expect(d.bortleClass, 4);
    expect(d.bortleSource, 'user');
    expect(d.sqm, 21.3);
    expect(d.sqmSource, 'meter');
    expect(d.isSaved, isTrue);
  });

  // TASK 10.3 (ADR-013 §6): the fixed sky warning is gone; Bortle and SQM
  // are context on the opportunity and never change the windows.
  test('Bortle and SQM are context only: no verdict, same windows', () async {
    final dark = await siteWith(bortle: 2);
    final bright = await siteWith(bortle: 8, sqm: 17.0);
    final vm = await build();
    await vm.setTarget(
      const model.AstroTarget(
        id: 1,
        catalogId: 'M31',
        type: 'Galaxy',
        rightAscension: 10.68,
        declination: 41.27,
      ),
    );

    await vm.selectSite(dark);
    final darkWindows = vm.imagingOpportunity!.visibilityWindows;
    expect(vm.imagingOpportunity!.skyDarkness!.bortleClass, 2);

    await vm.selectSite(bright);
    final o = vm.imagingOpportunity!;
    expect(o.skyDarkness!.bortleClass, 8);
    expect(o.skyDarkness!.sqm, 17.0);
    expect(o.visibilityWindows, darkWindows);
  });

  test('Bortle for a transient position is marked as not saved', () async {
    final vm = await build();
    await vm.setLocation(46.05, 14.51);

    await vm.setBortleClass(5);

    expect(vm.skyDarkness.bortleClass, 5);
    expect(vm.skyDarkness.isSaved, isFalse);
    expect(await locations.getLocations(), isEmpty);

    await vm.setLocation(45.0, 13.0);
    expect(vm.skyDarkness.isUnknown, isTrue);
  });
}
