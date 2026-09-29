import '../models/astro_target.dart';
import '../models/capture_block.dart';
import '../models/equipment_profile.dart';
import '../models/imaging_opportunity.dart';
import '../models/location_profile.dart';
import '../models/night_weather.dart';
import '../models/night_weather_summary.dart';
import '../models/planning_preferences.dart';
import '../models/session_night.dart';
import '../models/session_snapshot.dart';
import '../models/sky_darkness.dart';
import '../models/tracking_type.dart';
import 'capture_budget_calculator.dart';

/// Builds a [SessionSnapshot] from domain values (ADR-014 §4; TASK 11.3).
/// Pure and deterministic: the same inputs give the same JSON. Values are
/// copied, so a later edit of a site, target or rig never changes a
/// snapshot already taken.
abstract final class SessionSnapshotBuilder {
  static SessionSnapshot build({
    required DateTime takenAtUtc,
    required SessionNight night,
    required PlanningPreferences preferences,
    required CaptureBudget budget,
    required List<CaptureBlock> blocks,
    String? timeZoneId,
    LocationProfile? site,
    SkyDarkness? skyDarkness,
    AstroTarget? target,
    EquipmentProfile? rig,
    TrackingType? trackingOverride,
    ImagingOpportunity? opportunity,
    NightWeather? weather,
    NightWeatherSummary? weatherSummary,
  }) => SessionSnapshot.fromBuilder({
    'v': SessionSnapshot.currentVersion,
    'takenAtUtcMs': takenAtUtc.toUtc().millisecondsSinceEpoch,
    'night': {
      'eveningDate': night.eveningDate.toIso8601String(),
      'startUtcMs': night.startUtc.millisecondsSinceEpoch,
      'endUtcMs': night.endUtc.millisecondsSinceEpoch,
      'latitudeDeg': night.latitude,
      'longitudeDeg': night.longitude,
      'timeContextId': night.timeContextId,
      'timeZoneId': timeZoneId,
    },
    'site': site == null ? null : _site(site),
    'skyDarkness': skyDarkness == null ? null : _sky(skyDarkness),
    'target': target == null ? null : _target(target),
    'rig': rig == null ? null : _rig(rig),
    // S7.1 (RD-08 = T3): the tracking the plan's guidance used and where it
    // came from; `rig.tracking` stays the rig's default.
    'tracking': rig == null
        ? null
        : _tracking(
            EffectiveTracking.of(
              override: trackingOverride,
              rigDefault: rig.trackingType,
            ),
          ),
    'preferences': _preferences(preferences),
    'blocks': [for (final b in blocks) _block(b)],
    'budget': _budget(budget),
    'opportunity': opportunity == null ? null : _opportunity(opportunity),
    'weather': _weather(weather, weatherSummary),
  });

  static int _ms(DateTime t) => t.toUtc().millisecondsSinceEpoch;

  static Map<String, Object?> _site(LocationProfile s) => {
    'id': s.id,
    'name': s.name,
    'latitudeDeg': s.latitude,
    'longitudeDeg': s.longitude,
    'elevationM': s.elevation,
    'timeZoneId': s.timeZoneId,
  };

  static Map<String, Object?> _sky(SkyDarkness d) => {
    'bortleClass': d.bortleClass,
    'bortleSource': d.bortleSource,
    'bortleDate': d.bortleDate?.toIso8601String(),
    'sqmMagArcsec2': d.sqm,
    'sqmSource': d.sqmSource,
    'sqmDate': d.sqmDate?.toIso8601String(),
  };

  static Map<String, Object?> _target(AstroTarget t) => {
    'id': t.id,
    'catalogId': t.catalogId,
    'commonName': t.commonName,
    'type': t.type,
    'raDegJ2000': t.rightAscension,
    'decDegJ2000': t.declination,
    'epoch': t.epoch,
    'angularSizeArcmin': t.angularSizeArcmin,
    'magnitude': t.magnitude,
    'source': t.source,
  };

  // A group's provenance is recorded only when every spec of the group
  // has it (S3.V7, S3S-01): an imported rig's group pair is `user`, but its
  // estimates and file values are not the user's, so the group is omitted
  // (null) rather than invented. Per-field provenance in snapshots is left
  // to Stage 8 (TD-070).
  static Map<String, Object?> _rig(EquipmentProfile r) {
    final camera = r.sharedProvenance(camera: true);
    final optics = r.sharedProvenance(camera: false);
    return {
      'id': r.id,
      'name': r.name,
      'manufacturer': r.manufacturer,
      'cameraModel': r.cameraModel,
      'cameraClass': r.cameraClass.name, // S7.2a (ADR-020 §2)
      'inCameraNoiseReduction': r.inCameraNoiseReduction, // S7.3b (§8)
      'sensorWidthMm': r.sensorWidthMm,
      'sensorHeightMm': r.sensorHeightMm,
      'pixelPitchUm': r.pixelPitchUm,
      'resolutionWidthPx': r.resolutionWidthPx,
      'resolutionHeightPx': r.resolutionHeightPx,
      'focalLengthMm': r.focalLengthMm,
      'focalRatio': r.focalRatio,
      'apertureDiameterMm': r.apertureDiameterMm,
      'averageRawFileSizeMB': r.averageRawFileSizeMB,
      'rotationDeg': r.rotationDeg,
      'tracking': r.trackingType.name,
      'maxExposureS': r.maxExposureS,
      'cameraSource': camera?.source,
      'cameraConfidence': camera?.confidence?.name,
      'opticsSource': optics?.source,
      'opticsConfidence': optics?.confidence?.name,
    };
  }

  static Map<String, Object?> _tracking(EffectiveTracking t) => {
    'effective': t.type.name,
    'source': t.source.name,
  };

  static Map<String, Object?> _preferences(PlanningPreferences p) => {
    'minAltitudeDeg': p.minAltitudeDeg,
    'darknessLimitDeg': p.darknessLimit.degrees,
    'feasibilityMarginPercent': p.feasibilityMarginPercent,
    'dewMarginC': p.dewMarginC,
    'perFrameOverheadS': p.perFrameOverheadSeconds,
    'ditherEveryNFrames': p.ditherEveryNFrames,
    'ditherSettleS': p.ditherSettleSeconds,
    'refocusEveryMin': p.refocusEveryMinutes,
    'refocusS': p.refocusSeconds,
    'filterChangeS': p.filterChangeSeconds,
    'meridianFlipS': p.meridianFlipSeconds,
    'setupMin': p.setupMinutes,
    'npfK': p.npfK,
    'moonGatePct': p.optionalGates.moonMinIlluminationPct,
    'cloudGatePct': p.optionalGates.cloudMaxPct,
  };

  static Map<String, Object?> _block(CaptureBlock b) => {
    'frameType': b.frameType.name,
    'filterName': b.filterName,
    'exposureS': b.exposureTimeSeconds,
    'frameCount': b.frameCount,
    'binning': b.binning,
    'gainKind': b.gain.kind.name,
    'gainValue': b.gain.value,
    'calibrationPolicy': b.calibrationPolicy?.name,
  };

  static Map<String, Object?> _budget(CaptureBudget b) => {
    'integrationMs': b.integrationMs,
    'acquisitionMs': b.acquisitionMs,
    'inWindowCalibrationMs': b.inWindowCalibrationMs,
    'outsideWindowCalibrationMs': b.outsideWindowCalibrationMs,
    'setupMs': b.setupMs,
    'windowLoadMs': b.windowLoadMs,
    'sessionBudgetMs': b.sessionBudgetMs,
    'lightFrameCount': b.lightFrameCount,
    'storageMB': b.storageMB,
  };

  static Map<String, Object?> _opportunity(ImagingOpportunity o) => {
    'darknessLimitDeg': o.darknessLimitDeg,
    'minAltitudeDeg': o.minAltitudeDeg,
    'usableMs': o.usableTime.inMilliseconds,
    'noWindowReason': o.noWindowReason?.name,
    'windows': [
      for (final w in o.windows)
        {
          'startUtcMs': _ms(w.startUtc),
          'endUtcMs': _ms(w.endUtc),
          'clippedAtStart': w.window.clippedAtStart,
          'clippedAtEnd': w.window.clippedAtEnd,
          'maxAltitudeDeg': w.maxAltitudeDeg,
          'maxAltitudeAtUtcMs': _ms(w.maxAltitudeAtUtc),
          'moon': w.moon == null
              ? null
              : {
                  'upMs': w.moon!.upDuration.inMilliseconds,
                  'illumination': w.moon!.illumination,
                  'minSeparationDeg': w.moon!.minSeparationDeg,
                },
          'weather': w.weather == null
              ? null
              : {
                  'age': w.weather!.age.name,
                  'hours': w.weather!.hours,
                  'hoursWithoutForecast': w.weather!.hoursWithoutForecast,
                  'cloudMinPct': w.weather!.cloudMinPct,
                  'cloudMaxPct': w.weather!.cloudMaxPct,
                  'dewRiskHours': w.weather!.dewRiskHours,
                  'dewKnownHours': w.weather!.dewKnownHours,
                },
        },
    ],
    'excluded': [
      for (final s in o.excluded)
        {
          'startUtcMs': _ms(s.startUtc),
          'endUtcMs': _ms(s.endUtc),
          'reasons': [
            for (final g in OpportunityGate.values)
              if (s.reasons.contains(g)) g.name,
          ],
        },
    ],
  };

  static Map<String, Object?> _weather(
    NightWeather? w,
    NightWeatherSummary? summary,
  ) => switch (w) {
    null || NightWeatherIdle() || NightWeatherLoading() => {'state': 'none'},
    NightWeatherOutOfRange() => {'state': 'outOfRange'},
    NightWeatherUnavailable(:final failure) => {
      'state': 'unavailable',
      'failure': failure.name,
    },
    NightWeatherAvailable() => {
      'state': 'available',
      'provider': w.snapshot.provider,
      'model': w.snapshot.model,
      'fetchedAtUtcMs': _ms(w.snapshot.fetchedAtUtc),
      'age': w.age.name,
      'fromCache': w.fromCache,
      'refreshFailed': w.refreshFailed?.name,
      'hours': summary == null
          ? null
          : [
              for (final slot in summary.slots)
                {
                  'tUtcMs': _ms(slot.timeUtc),
                  if (slot.hour case final h?) ...{
                    'cloudPct': h.cloudCoverPct,
                    'cloudLowPct': h.cloudCoverLowPct,
                    'cloudMidPct': h.cloudCoverMidPct,
                    'cloudHighPct': h.cloudCoverHighPct,
                    'precipProbPct': h.precipitationProbabilityPct,
                    'windKmh': h.windSpeedKmh,
                    'gustKmh': h.windGustsKmh,
                    'temperatureC': h.temperatureC,
                    'dewPointC': h.dewPointC,
                    'humidityPct': h.relativeHumidityPct,
                    'visibilityM': h.visibilityM,
                  } else
                    'noForecast': true,
                },
            ],
    },
  };
}
