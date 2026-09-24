// TASK 16.1: the app's name and id live in one place (AppIdentity) and the
// Android project agrees with it; the icon and splash resources are wired.
// "Build and install" itself needs an Android toolchain (TEST_PLAN).

import 'dart:io';

import 'package:astroplan/core/config/app_identity.dart';
import 'package:flutter_test/flutter_test.dart';

const _res = 'android/app/src/main/res';

String _read(String path) => File(path).readAsStringSync();

void main() {
  test('the owner-decided name and id (DECISIONS OD-07)', () {
    expect(AppIdentity.appName, 'Astro Planner');
    expect(AppIdentity.packageName, 'io.github.chacha12.astroplanner');
    expect(
      AppIdentity.userAgent,
      'Astro Planner/${AppIdentity.version} '
      '(+https://chacha12.github.io/astro-planner/; '
      'io.github.chacha12.astroplanner)',
    );
  });

  test('Gradle, the manifest and MainActivity use the same id and name', () {
    final gradle = _read('android/app/build.gradle.kts');
    expect(gradle, contains('applicationId = "${AppIdentity.packageName}"'));
    expect(gradle, contains('namespace = "${AppIdentity.packageName}"'));
    final manifest = _read('android/app/src/main/AndroidManifest.xml');
    expect(manifest, contains('android:label="${AppIdentity.appName}"'));
    expect(manifest, contains('android:icon="@mipmap/ic_launcher"'));
    final activity = File(
      'android/app/src/main/kotlin/'
      '${AppIdentity.packageName.replaceAll('.', '/')}/MainActivity.kt',
    );
    expect(activity.existsSync(), isTrue);
    expect(
      activity.readAsStringSync(),
      startsWith('package ${AppIdentity.packageName}'),
    );
    final everything = [
      for (final f in Directory('android/app/src').listSync(recursive: true))
        if (f is File && RegExp(r'\.(kt|xml|kts)$').hasMatch(f.path))
          f.readAsStringSync(),
      gradle,
    ].join('\n');
    expect(everything, isNot(contains('com.astroplan')));
  });

  test('the adaptive icon, legacy icons and splash are wired', () {
    final adaptive = _read('$_res/mipmap-anydpi-v26/ic_launcher.xml');
    expect(adaptive, contains('@drawable/ic_launcher_foreground'));
    expect(adaptive, contains('@color/ic_launcher_background'));
    expect(adaptive, contains('<monochrome'));
    expect(
      File('$_res/drawable/ic_launcher_foreground.xml').existsSync(),
      isTrue,
    );
    expect(_read('$_res/values/colors.xml'), contains('splash_background'));
    for (final d in ['mdpi', 'hdpi', 'xhdpi', 'xxhdpi', 'xxxhdpi']) {
      expect(File('$_res/mipmap-$d/ic_launcher.png').existsSync(), isTrue);
    }
    for (final d in ['values-v31', 'values-night-v31']) {
      final styles = _read('$_res/$d/styles.xml');
      expect(styles, contains('windowSplashScreenBackground'));
      expect(styles, contains('@drawable/ic_launcher_foreground'));
    }
    for (final d in ['drawable', 'drawable-v21']) {
      expect(
        _read('$_res/$d/launch_background.xml'),
        contains('@color/splash_background'),
      );
    }
    expect(File('assets/branding/icon_512.png').lengthSync(), greaterThan(0));
  });
}
