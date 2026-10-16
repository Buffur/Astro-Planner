// TASK 11.3 (ADR-014 §4): snapshots are pure, versioned, unit-keyed JSON
// that survive a storage round trip unchanged; missing inputs are null,
// never zero; an unknown version is "unavailable".

import 'dart:convert';

import 'package:astroplan/domain/models/astro_target.dart';
import 'package:astroplan/domain/models/calendar_date.dart';
import 'package:astroplan/domain/models/capture_block.dart';
import 'package:astroplan/domain/models/equipment_profile.dart';
import 'package:astroplan/domain/models/spec_confidence.dart';
import 'package:astroplan/domain/models/spec_provenance.dart';
import 'package:astroplan/domain/models/tracking_type.dart';
import 'package:astroplan/domain/models/location_profile.dart';
import 'package:astroplan/domain/models/night_weather.dart';
import 'package:astroplan/domain/models/planning_preferences.dart';
import 'package:astroplan/domain/models/session_snapshot.dart';
import 'package:astroplan/domain/models/site_time_context.dart';
import 'package:astroplan/domain/models/weather_snapshot.dart';
import 'package:astroplan/domain/services/capture_budget_calculator.dart';
import 'package:astroplan/domain/services/imaging_opportunity_calculator.dart';
import 'package:astroplan/domain/services/night_weather_summarizer.dart';
import 'package:astroplan/domain/services/saved_plan_reader.dart';
import 'package:astroplan/domain/services/session_night_resolver.dart';
import 'package:astroplan/domain/services/session_snapshot_builder.dart';
import 'package:astroplan/domain/services/visibility_calculator.dart';
import 'package:astroplan/presentation/shared/equipment_draft.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../support/metadata_candidates.dart';

final _night = SessionNightResolver.forEveningDate(
  CalendarDate(2026, 12, 15),
  latitude: 46.05,
  longitude: 14.51,
  timeContext: MeanSolarTimeContext(14.51),
);

const _target = AstroTarget(
  id: 7,
  catalogId: 'M42',
  commonName: 'Orion Nebula',
  type: 'Nebula',
  rightAscension: 83.82,
  declination: -5.39,
  source: 'catalog:openngc',
  angularSizeArcmin: 85,
);

final _rig = EquipmentProfile(
  id: 3,
  name: 'Refractor',
  focalRatio: 5,
  focalLengthMm: 400,
  sensorWidthMm: 23.5,
  sensorHeightMm: 15.6,
  resolutionWidthPx: 6000,
  resolutionHeightPx: 4000,
  pixelPitchUm: 3.76,
);

final _site = LocationProfile(
  id: 2,
  name: 'Home',
  latitude: 46.05,
  longitude: 14.51,
  elevation: 300,
  timeZoneId: 'Europe/Ljubljana',
);

final _blocks = [
  CaptureBlock(
    frameType: FrameType.light,
    exposureTimeSeconds: 300,
    frameCount: 20,
  ),
];

SessionSnapshot _build({
  bool full = true,
  EquipmentProfile? rig,
  LocationProfile? site,
}) {
  final prefs = PlanningPreferences();
  final opportunity = ImagingOpportunityCalculator.calculate(
    night: _night,
    target: _target,
    darknessLimitDeg: -18,
    minAltitudeDeg: 20,
  );
  final weather = NightWeatherAvailable(
    snapshot: WeatherSnapshot(
      provider: 'open-meteo',
      model: 'best_match',
      fetchedAtUtc: DateTime.utc(2026, 12, 15, 10),
      latitude: 46.05,
      longitude: 14.51,
      hours: [
        WeatherHour(timeUtc: DateTime.utc(2026, 12, 15, 18), cloudCoverPct: 12),
      ],
    ),
    age: WeatherAge.current,
    ageDuration: const Duration(hours: 1),
    fromCache: false,
  );
  final span = NightWeatherSummarizer.spanOf(
    VisibilityCalculator.calculateNightTimelineForNight(_night),
  );
  return SessionSnapshotBuilder.build(
    takenAtUtc: DateTime.utc(2026, 12, 15, 11),
    night: _night,
    timeZoneId: 'Europe/Ljubljana',
    preferences: prefs,
    budget: CaptureBudgetCalculator.calculate(
      blocks: _blocks,
      overheads: CaptureOverheads.fromPreferences(prefs),
      targetTransitsInWindow: false,
    ),
    blocks: _blocks,
    site: full ? site ?? _site : null,
    target: full ? _target : null,
    rig: full ? rig ?? _rig : null,
    opportunity: full ? opportunity : null,
    weather: full ? weather : null,
    weatherSummary: full
        ? NightWeatherSummarizer.summarize(
            weather.snapshot,
            fromUtc: span.fromUtc,
            toUtc: span.toUtc,
            dewMarginC: 2,
          )
        : null,
  );
}

void main() {
  test('versioned, deterministic, and unchanged by a JSON round trip', () {
    final a = _build();
    final b = _build();
    expect(a.json, b.json);
    expect(a.json['v'], SessionSnapshot.currentVersion);
    final back = SessionSnapshot.tryRead(
      (jsonDecode(jsonEncode(a.json)) as Map).cast<String, Object?>(),
    )!;
    expect(back.json, a.json);
    expect(back.takenAtUtc, DateTime.utc(2026, 12, 15, 11));
    expect(back.eveningDate, CalendarDate(2026, 12, 15));
  });

  test('an unknown elevation is recorded as null, never 0 (S7.5, RG-08 = '
      'E2); an older snapshot with a value reads it unchanged', () {
    final unknown = LocationProfile(
      id: 3,
      name: 'Hill',
      latitude: 46.05,
      longitude: 14.51,
      timeZoneId: 'Europe/Ljubljana',
    );
    final s = _build(site: unknown);
    final site = s.json['site']! as Map;
    expect(site.containsKey('elevationM'), isTrue);
    expect(site['elevationM'], isNull);
    expect(s.siteElevationM, isNull);

    final older = Map<String, Object?>.from(_build().json);
    final back = SessionSnapshot.tryRead(
      (jsonDecode(jsonEncode(older)) as Map).cast<String, Object?>(),
    )!;
    expect(back.siteElevationM, 300);
  });

  test('context is copied with units: site, target, rig, windows, weather', () {
    final s = _build();
    expect(s.siteName, 'Home');
    expect(s.targetName, 'Orion Nebula');
    expect(s.rigName, 'Refractor');
    expect(s.rigFocalLengthMm, 400);
    final site = s.json['site']! as Map;
    expect(site['latitudeDeg'], 46.05);
    expect(site['elevationM'], 300);
    final target = s.json['target']! as Map;
    expect(target['raDegJ2000'], 83.82);
    final opportunity = s.json['opportunity']! as Map;
    expect((opportunity['windows']! as List), isNotEmpty);
    expect(opportunity['usableMs'], isPositive);
    final weather = s.json['weather']! as Map;
    expect(weather['state'], 'available');
    expect(weather['model'], 'best_match');
    final hours = weather['hours']! as List;
    expect(hours.where((h) => (h as Map)['noForecast'] == true), isNotEmpty);
    final budget = s.json['budget']! as Map;
    expect(budget['integrationMs'], 20 * 300 * 1000);
  });

  test('missing inputs are null, never zero', () {
    final s = _build(full: false);
    expect(s.json['site'], isNull);
    expect(s.json['target'], isNull);
    expect(s.json['rig'], isNull);
    expect(s.json['opportunity'], isNull);
    expect(s.json['weather'], {'state': 'none'});
    expect(s.siteName, isNull);
    expect(s.rigFocalLengthMm, isNull);
  });

  test('an unknown version or an unreadable value is unavailable', () {
    expect(SessionSnapshot.tryRead(null), isNull);
    expect(SessionSnapshot.tryRead(const {}), isNull);
    expect(SessionSnapshot.tryRead(const {'v': 2}), isNull);
  });

  // S3.V7 (S3S-01, TD-070): a snapshot keeps a group provenance only when
  // every spec of the group has it; it never records a rig-wide `user` for
  // imported or estimated values. Since S8.8 (TD-070) `provenance` records
  // each valued spec's own pair.
  group('rig provenance', () {
    Map<Object?, Object?> rigOf(EquipmentProfile rig) =>
        _build(rig: rig).json['rig']! as Map;

    test('an imported rig: the camera group is omitted, not `user`', () {
      final d = EquipmentDraft.fromCandidate(phoneCandidate());
      final rig = rigOf(d.build(d.initial, TrackingType.unknown).profile!);
      expect(rig['cameraSource'], isNull);
      expect(rig['cameraConfidence'], isNull);
      expect(rig['opticsSource'], 'metadata:jpeg');
      expect(rig['opticsConfidence'], SpecConfidence.reported.name);
    });

    test("a rig typed by hand is the user's in both groups", () {
      final rig = rigOf(_rig.withEditProvenance(null));
      expect(rig['cameraSource'], 'user');
      expect(rig['cameraConfidence'], SpecConfidence.reported.name);
      expect(rig['opticsSource'], 'user');
    });

    test('a legacy rig stays unknown', () {
      final rig = rigOf(_rig);
      expect(rig['cameraSource'], isNull);
      expect(rig['opticsSource'], isNull);
      expect(rig['provenance'], {
        'resolution': null,
        'pixelPitch': null,
        'sensorSize': null,
        'focalLength': null,
        'focalRatio': null,
      });
    });

    Map<String, Object?> pair(String source, SpecConfidence c) => {
      'source': source,
      'confidence': c.name,
    };

    test('S8.8: an imported rig records its estimated and file-sourced '
        'fields as such, never as `user`', () {
      final d = EquipmentDraft.fromCandidate(phoneCandidate());
      final rig = rigOf(d.build(d.initial, TrackingType.unknown).profile!);
      final file = pair('metadata:jpeg', SpecConfidence.reported);
      final estimate = pair(
        'derived:calc-40/metadata:jpeg',
        SpecConfidence.estimated,
      );
      expect(rig['provenance'], {
        'resolution': file,
        'pixelPitch': estimate,
        'sensorSize': estimate,
        'focalLength': file,
        'focalRatio': file,
      });
    });

    test("S8.8: a typed rig is the user's per field; a field marked "
        'unknown stays unknown', () {
      final typed = _rig.withEditProvenance(null);
      final rig = rigOf(
        EquipmentProfile(
          id: typed.id,
          name: typed.name,
          sensorWidthMm: typed.sensorWidthMm,
          sensorHeightMm: typed.sensorHeightMm,
          pixelPitchUm: typed.pixelPitchUm,
          resolutionWidthPx: typed.resolutionWidthPx,
          resolutionHeightPx: typed.resolutionHeightPx,
          focalLengthMm: typed.focalLengthMm,
          focalRatio: typed.focalRatio,
          averageRawFileSizeMB: 25,
          cameraSource: typed.cameraSource,
          cameraConfidence: typed.cameraConfidence,
          opticsSource: typed.opticsSource,
          opticsConfidence: typed.opticsConfidence,
          specProvenance: const {
            EquipmentSpec.pixelPitch: SpecProvenance.unknown,
          },
        ),
      );
      final user = pair('user', SpecConfidence.reported);
      expect(rig['provenance'], {
        'resolution': user,
        'pixelPitch': null,
        'sensorSize': user,
        'rawFileSize': user,
        'focalLength': user,
        'focalRatio': user,
      });
      expect(rig['cameraSource'], isNull);
      expect(rig['opticsSource'], 'user');
    });

    test('S8.8: a snapshot taken before per-field provenance still reads', () {
      final json = jsonDecode(jsonEncode(_build().json)) as Map;
      (json['rig'] as Map).remove('provenance');
      final old = SessionSnapshot.tryRead(json.cast<String, Object?>());
      expect(old, isNotNull);
      expect(old!.rigName, _rig.name);
      expect(old.rigFocalLengthMm, _rig.focalLengthMm);
      expect(SavedPlanReader.read(old)?.rigLabel, _rig.name);
    });
  });
}
