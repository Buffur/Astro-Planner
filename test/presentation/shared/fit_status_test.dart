// S1.9 (UX-16, UX-15(2)): "Tight" is a caution at least as prominent as
// "Fits"; a plan missing its site or target is neutral, while a real
// no-window night stays an error.

import 'package:astroplan/core/theme/app_palette.dart';
import 'package:astroplan/core/theme/app_theme.dart';
import 'package:astroplan/data/database/app_database.dart' show AppDatabase;
import 'package:astroplan/data/repositories/drift_equipment_repository.dart';
import 'package:astroplan/data/repositories/drift_location_repository.dart';
import 'package:astroplan/data/repositories/drift_target_repository.dart';
import 'package:astroplan/data/services/equipment_seeder.dart';
import 'package:astroplan/domain/models/astro_target.dart';
import 'package:astroplan/domain/repositories/weather_repository.dart';
import 'package:astroplan/domain/services/fit_analyzer.dart';
import 'package:astroplan/presentation/shared/night_text.dart';
import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../support/fake_device_time_zone.dart';
import '../../support/fake_location_service.dart';
import '../../support/fake_reverse_geocoder.dart';
import '../../support/no_snapshot_weather.dart';
import '../../support/planner_harness.dart';

class _NoForecast with NoSnapshotWeather implements WeatherRepository {}

/// WCAG contrast ratio of [a] on [b].
double _contrast(Color a, Color b) {
  final la = a.computeLuminance();
  final lb = b.computeLuminance();
  return (la > lb ? la + 0.05 : lb + 0.05) / (la > lb ? lb + 0.05 : la + 0.05);
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('colours', () {
    for (final (name, theme) in [
      ('light', AppTheme.light),
      ('dark', AppTheme.dark),
    ]) {
      test('$name: Tight is the caution colour, readable (AA) and not the '
          'grey of secondary text', () {
        final scheme = theme.colorScheme;
        final palette = theme.extension<AppPalette>()!;
        final tight = FitText.color(FitState.tight, scheme, palette);
        expect(tight, palette.caution);
        expect(tight, isNot(scheme.secondary));
        expect(tight, isNot(scheme.error));
        for (final bg in [theme.scaffoldBackgroundColor, scheme.surface]) {
          expect(_contrast(tight, bg), greaterThanOrEqualTo(4.5));
        }
      });

      test('$name: a missing input is neutral; a real no-window is an '
          'error', () {
        final scheme = theme.colorScheme;
        final palette = theme.extension<AppPalette>()!;
        expect(
          FitText.color(FitState.needsInput, scheme, palette),
          scheme.outline,
        );
        expect(FitText.color(FitState.noWindow, scheme, palette), scheme.error);
        expect(FitText.label(FitState.needsInput), 'No window');
      });
    }
  });

  group('the planner', () {
    late AppDatabase db;
    late PlannerHarness vm;

    setUp(() async {
      SharedPreferences.setMockInitialValues({});
      db = AppDatabase(NativeDatabase.memory());
      await EquipmentSeeder(DriftEquipmentRepository(db)).seedIfNeeded();
      vm = PlannerHarness(
        DriftTargetRepository(db),
        DriftEquipmentRepository(db),
        _NoForecast(),
        DriftLocationRepository(db),
        locationService: FakeLocationService(),
        reverseGeocoder: FakeReverseGeocoder(),
        deviceTimeZone: FakeDeviceTimeZone(),
      );
      await vm.ready;
    });

    tearDown(() => db.close());

    test('no site, then no target: needs input, not "no window"', () async {
      expect(vm.fitAnalysis.state, FitState.needsInput);
      await vm.site.setLocation(46.05, 14.51);
      expect(vm.selectedTarget, isNull, reason: 'the catalog is empty');
      expect(vm.fitAnalysis.state, FitState.needsInput);
      expect(vm.fitAnalysis.reason, contains('Choose a target'));
    });

    test('a target that never rises is a real no-window night', () async {
      await vm.site.setLocation(46.05, 14.51);
      final targets = DriftTargetRepository(db);
      final id = await targets.insertTarget(
        const AstroTarget(
          id: 0,
          catalogId: 'Deep south',
          rightAscension: 90,
          declination: -80,
          type: 'Other',
          source: 'user',
        ),
      );
      await vm.plan.setTarget((await targets.getTargetById(id))!);
      expect(vm.fitAnalysis.state, FitState.noWindow);
    });
  });
}
