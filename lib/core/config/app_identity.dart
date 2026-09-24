/// How the app names and identifies itself (TASK 7.2; name and id decided
/// by the owner in TASK 16.1, DECISIONS OD-07).
///
/// OpenStreetMap's tile and Nominatim usage policies require an identifying
/// user agent; a generic or placeholder one (`com.example.astroplan`) may be
/// blocked.
abstract final class AppIdentity {
  /// The name users see: the launcher label (`AndroidManifest.xml`), the
  /// task switcher and every text that names the app.
  static const String appName = 'Astro Planner';

  /// The Android application id (`android/app/build.gradle.kts`); permanent
  /// once published.
  static const String packageName = 'io.github.chacha12.astroplanner';

  /// The app version (`pubspec.yaml`'s `version`, without the build
  /// number); written into export manifests (TASK 14.3). A test keeps the
  /// two in step.
  static const String version = '1.0.0';

  /// HTTP `User-Agent` for requests to third-party services.
  static const String userAgent = '$appName ($packageName)';
}
