/// How the app names and identifies itself (TASK 7.2; name and id decided
/// by the owner in RA.D ID-1 to ID-4 and applied in S13.2; earlier builds
/// carried OD-07's name and id; see `RA_D_IDENTITY_TRANSITION.md` §3).
///
/// OpenStreetMap's tile and Nominatim usage policies require an identifying
/// user agent; a generic or placeholder one (`com.example.astroplan`) may be
/// blocked.
abstract final class AppIdentity {
  /// The name users see: the launcher label (`AndroidManifest.xml`), the
  /// task switcher and every text that names the app.
  static const String appName = 'Culmina';

  /// The Android application id (`android/app/build.gradle.kts`); permanent
  /// once published.
  static const String packageName = 'io.github.buffur.culmina';

  /// The app version (`pubspec.yaml`'s `version`, without the build
  /// number); written into export manifests (TASK 14.3). A test keeps the
  /// two in step.
  static const String version = '1.0.0';

  /// The project's public page: the contact in the user agent (the OSM tile
  /// and Nominatim policies ask for one) and the home of the privacy policy
  /// (TASK 16.3; GitHub Pages of `Buffur/Culmina`, S12.3).
  static const String projectUrl = 'https://buffur.github.io/Culmina/';

  /// The privacy policy (published with every release; S12.3).
  static const String privacyPolicyUrl = '${projectUrl}privacy/';

  /// The source code (GPL-3.0 asks that it be offered with the app).
  static const String sourceUrl = 'https://github.com/Buffur/Culmina';

  /// HTTP `User-Agent` for requests to third-party services: the app, its
  /// version and a contact URL, as the OSM tile policy's example.
  static const String userAgent =
      '$appName/$version (+$projectUrl; $packageName)';
}
