// ADR-011 (TASK 8.4): aperture resolution (N = f / D, 1 % agreement),
// plausibility bounds, the review flag and tracking-type storage.

import 'package:astroplan/domain/models/equipment_limits.dart';
import 'package:astroplan/domain/models/equipment_profile.dart';
import 'package:astroplan/domain/models/tracking_type.dart';
import 'package:astroplan/presentation/shared/equipment_form_input.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('resolveAperture', () {
    test('a focal ratio alone is kept; the diameter stays unknown', () {
      final r = resolveAperture(focalLengthMm: 6.86, focalRatio: 1.78);
      expect(r.isValid, isTrue);
      expect(r.focalRatio, 1.78);
      expect(r.diameterMm, isNull);
    });

    test('a diameter alone derives N = f / D', () {
      final r = resolveAperture(focalLengthMm: 400, diameterMm: 72);
      expect(r.focalRatio, closeTo(5.5556, 1e-4));
      expect(r.diameterMm, 72);
    });

    test('both: accepted within 1 %, rejected beyond', () {
      // 400 / 72 = 5.5556; 5.6 is 0.8 % away, 5.7 is 2.6 % away.
      expect(
        resolveAperture(
          focalLengthMm: 400,
          focalRatio: 5.6,
          diameterMm: 72,
        ).isValid,
        isTrue,
      );
      final r = resolveAperture(
        focalLengthMm: 400,
        focalRatio: 5.7,
        diameterMm: 72,
      );
      expect(r.problem, ApertureProblem.disagree);
    });

    test('missing and out-of-range inputs', () {
      expect(
        resolveAperture(focalLengthMm: 400).problem,
        ApertureProblem.missing,
      );
      expect(
        resolveAperture(focalLengthMm: 400, focalRatio: 72).problem,
        ApertureProblem.focalRatioOutOfRange,
      );
      expect(
        resolveAperture(focalLengthMm: 400, focalRatio: 0.4).problem,
        ApertureProblem.focalRatioOutOfRange,
      );
      expect(
        resolveAperture(focalLengthMm: 400, diameterMm: 0.5).problem,
        ApertureProblem.diameterOutOfRange,
      );
      // 4000 mm / 100 mm = f/40: the derived ratio is checked too.
      expect(
        resolveAperture(focalLengthMm: 4000, diameterMm: 100).problem,
        ApertureProblem.focalRatioOutOfRange,
      );
    });
  });

  test('the review flag is above f/32 only (ADR-011 §6)', () {
    EquipmentProfile withN(double n) => EquipmentProfile(
      id: 1,
      name: 'x',
      sensorWidthMm: 10,
      sensorHeightMm: 10,
      pixelPitchUm: 2,
      resolutionWidthPx: 5000,
      resolutionHeightPx: 5000,
      focalLengthMm: 400,
      focalRatio: n,
    );
    expect(withN(72).needsApertureReview, isTrue);
    expect(withN(32.01).needsApertureReview, isTrue);
    expect(withN(32).needsApertureReview, isFalse);
    expect(withN(5.6).needsApertureReview, isFalse);
  });

  test('tracking type storage: known names, anything else unknown', () {
    for (final t in TrackingType.values) {
      expect(TrackingType.fromStorage(t.name), t);
    }
    expect(TrackingType.fromStorage(null), TrackingType.unknown);
    expect(TrackingType.fromStorage('tracking'), TrackingType.unknown);
    expect(TrackingType.fromStorage(''), TrackingType.unknown);
  });

  group('form validators (units in every message)', () {
    test('required ranges', () {
      final focal = EquipmentFormInput.required(
        EquipmentLimits.focalLengthMm,
        'mm',
      );
      expect(focal('400'), isNull);
      expect(focal('400,5'), isNull);
      expect(focal(''), 'Required');
      expect(focal('abc'), 'Invalid');
      expect(focal('0'), 'Must be 1–20000 mm');
      final pitch = EquipmentFormInput.required(
        EquipmentLimits.pixelPitchUm,
        'µm',
      );
      expect(pitch('3.76'), isNull);
      expect(pitch('31'), 'Must be 0.5–30 µm');
      final ratio = EquipmentFormInput.required(EquipmentLimits.focalRatio, '');
      expect(ratio('72'), 'Must be 0.5–32');
    });

    test('optional ranges and resolution', () {
      final maxExp = EquipmentFormInput.optional(
        EquipmentLimits.maxExposureS,
        's',
      );
      expect(maxExp(''), isNull);
      expect(maxExp('300'), isNull);
      expect(maxExp('3601'), 'Must be 1–3600 s');
      expect(EquipmentFormInput.validateResolution('6248'), isNull);
      expect(
        EquipmentFormInput.validateResolution('0'),
        'Must be 100–30000 px',
      );
      expect(EquipmentFormInput.validateResolution('62.5'), 'Invalid');
    });
  });
}
