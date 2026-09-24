/// How the app identifies itself to third-party services (TASK 7.2).
///
/// OpenStreetMap's tile and Nominatim usage policies require an identifying
/// user agent; a generic or placeholder one (`com.example.astroplan`) may be
/// blocked.
abstract final class AppIdentity {
  /// The Android application id (`android/app/build.gradle.kts`).
  static const String packageName = 'com.astroplan.astroplan';

  /// HTTP `User-Agent` for requests to third-party services.
  /// The app version (`pubspec.yaml`'s `version`, without the build
  /// number); written into export manifests (TASK 14.3). A test keeps the
  /// two in step.
  static const String version = '1.0.0';

  static const String userAgent = 'AstroPlan ($packageName)';
}
