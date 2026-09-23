// Tests for the TASK 7.2 presentation helpers: the explanation of each
// location-permission outcome, and typed-coordinate validation.

import 'package:astroplan/domain/services/location_service.dart';
import 'package:astroplan/presentation/shared/coordinate_input.dart';
import 'package:astroplan/presentation/shared/location_failure_text.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('LocationFailureText', () {
    test(
      'every failure explains itself and offers the manual alternatives',
      () {
        for (final reason in LocationFailure.values) {
          final text = LocationFailureText.message(reason);
          expect(text, contains('enter coordinates'), reason: '$reason');
        }
        expect(
          LocationFailureText.message(LocationFailure.serviceDisabled),
          contains('turned off'),
        );
        expect(
          LocationFailureText.message(LocationFailure.permissionDenied),
          contains('night times'),
        );
        expect(
          LocationFailureText.message(LocationFailure.permissionDeniedForever),
          contains('app settings'),
        );
      },
    );

    test('each failure points at the settings page that fixes it', () {
      expect(
        LocationFailureText.settingsTarget(LocationFailure.serviceDisabled),
        LocationSettingsTarget.locationSettings,
      );
      expect(
        LocationFailureText.settingsTarget(LocationFailure.permissionDenied),
        isNull,
      );
      expect(
        LocationFailureText.settingsTarget(
          LocationFailure.permissionDeniedForever,
        ),
        LocationSettingsTarget.appSettings,
      );
    });
  });

  group('CoordinateInput', () {
    test('parses decimal degrees, with a comma or a sign', () {
      expect(CoordinateInput.parse('46.0569'), 46.0569);
      expect(CoordinateInput.parse(' -122,4194 '), -122.4194);
      expect(CoordinateInput.parse('abc'), isNull);
      expect(CoordinateInput.parse('NaN'), isNull);
      expect(CoordinateInput.parse(null), isNull);
    });

    test('latitude must be within [-90, 90]', () {
      expect(CoordinateInput.validateLatitude('90'), isNull);
      expect(CoordinateInput.validateLatitude('-90'), isNull);
      expect(CoordinateInput.validateLatitude('90.01'), isNotNull);
      expect(CoordinateInput.validateLatitude(''), isNotNull);
      expect(CoordinateInput.validateLatitude('north'), isNotNull);
    });

    test('longitude must be within [-180, 180]', () {
      expect(CoordinateInput.validateLongitude('180'), isNull);
      expect(CoordinateInput.validateLongitude('-180'), isNull);
      expect(CoordinateInput.validateLongitude('-180.5'), isNotNull);
      expect(CoordinateInput.validateLongitude(' '), isNotNull);
    });
  });
}
