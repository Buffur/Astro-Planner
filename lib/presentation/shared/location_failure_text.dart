import '../../domain/services/location_service.dart';

/// Which settings page, if any, fixes a [LocationFailure].
enum LocationSettingsTarget { locationSettings, appSettings }

/// User-facing explanation of a [LocationFailure] (TASK 7.2): what happened,
/// why the app asks, and what the user can do instead.
abstract final class LocationFailureText {
  static const String _alternatives =
      'You can also pick a point on the map or enter coordinates.';

  static String message(LocationFailure reason) => switch (reason) {
    LocationFailure.serviceDisabled =>
      'Location services are turned off on this device. $_alternatives',
    LocationFailure.permissionDenied =>
      'AstroPlan uses your position only to compute night times, target '
          'visibility and weather for where you are. $_alternatives',
    LocationFailure.permissionDeniedForever =>
      'Location permission is blocked for AstroPlan. Allow it in the app '
          'settings to use your current position. $_alternatives',
  };

  /// The settings page that fixes [reason], or null when asking again is
  /// enough ([LocationFailure.permissionDenied]).
  static LocationSettingsTarget? settingsTarget(LocationFailure reason) =>
      switch (reason) {
        LocationFailure.serviceDisabled =>
          LocationSettingsTarget.locationSettings,
        LocationFailure.permissionDenied => null,
        LocationFailure.permissionDeniedForever =>
          LocationSettingsTarget.appSettings,
      };
}
