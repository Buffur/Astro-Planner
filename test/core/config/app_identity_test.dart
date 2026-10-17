// TASK 16.1: the app's name and id live in one place (AppIdentity) and the
// Android project agrees with it; the icon and splash resources are wired.
// "Build and install" itself needs an Android toolchain (TEST_PLAN).

import 'dart:io';

import 'package:astroplan/core/config/app_identity.dart';
import 'package:flutter_test/flutter_test.dart';

const _res = 'android/app/src/main/res';

String _read(String path) => File(path).readAsStringSync();

void main() {
  test('the owner-decided name and id (RA.D ID-1 to ID-4; S13.2)', () {
    expect(AppIdentity.appName, 'Culmina');
    expect(AppIdentity.packageName, 'io.github.buffur.culmina');
    expect(
      AppIdentity.userAgent,
      'Culmina/${AppIdentity.version} '
      '(+https://buffur.github.io/Culmina/; '
      'io.github.buffur.culmina)',
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
    // S13.3: the themed icon is its own one-colour layer.
    expect(adaptive, contains('@drawable/ic_launcher_monochrome'));
    expect(
      File('$_res/drawable/ic_launcher_monochrome.xml').existsSync(),
      isTrue,
    );
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
      // S13.3 (ID-6 = S2): the animated mark, at most 1,000 ms, no delay.
      expect(styles, contains('@drawable/splash_icon_animated'));
      expect(styles, contains('windowSplashScreenAnimationDuration">1000<'));
    }
    for (final d in ['drawable', 'drawable-v21']) {
      expect(
        _read('$_res/$d/launch_background.xml'),
        contains('@color/splash_background'),
      );
    }
    expect(File('assets/branding/icon_512.png').lengthSync(), greaterThan(0));
  });
  // S13.3: the splash animation stays under 1,000 ms with no start delay
  // above 166 ms (Android splash-screen guidance), and its paths are the
  // launcher icon's.
  test('the animated splash is short and draws the icon', () {
    final avd = _read('$_res/drawable/splash_icon_animated.xml');
    final icon = _read('$_res/drawable/ic_launcher_foreground.xml');
    var end = 0;
    for (final m in RegExp(
      r'android:duration="(\d+)"(?:[^>]*?android:startOffset="(\d+)")?',
    ).allMatches(avd)) {
      final total = int.parse(m[1]!) + int.parse(m[2] ?? '0');
      if (total > end) end = total;
    }
    expect(end, 1000); // the star settles last (500 + 500 ms)
    expect(end, lessThanOrEqualTo(1000));
    // Owner, 2026-10-17: the splash is held until the animation has played,
    // and not held when animations are off.
    final activity = _read(
      'android/app/src/main/kotlin/io/github/buffur/culmina/MainActivity.kt',
    );
    expect(activity, contains('setOnExitAnimationListener'));
    expect(activity, contains('ValueAnimator.areAnimatorsEnabled()'));
    for (final m in RegExp(r'android:pathData="([^"]+)"').allMatches(icon)) {
      expect(avd, contains(m[1]!));
    }
  });

  // S13.2 (RA_D_IDENTITY_TRANSITION.md §3, criterion 2): no trace of the
  // earlier id in code, platform files, tests or tools. The needles are
  // split so this file does not match itself.
  test('the earlier id is gone everywhere', () {
    const oldOwner =
        'chacha'
        '12';
    const oldPackage =
        'astro'
        'planner';
    final skip = RegExp(r'[\\/](build|\.gradle|\.dart_tool)[\\/]');
    final hits = <String>[];
    for (final dir in ['lib', 'android', 'test', 'integration_test', 'tool']) {
      for (final f in Directory(dir).listSync(recursive: true)) {
        if (f is! File || skip.hasMatch(f.path)) continue;
        if (!RegExp(r'\.(dart|kt|kts|xml|py|gradle|properties)$')
            .hasMatch(f.path)) {
          continue;
        }
        final text = f.readAsStringSync().toLowerCase();
        if (text.contains(oldOwner) || text.contains(oldPackage)) {
          hits.add(f.path);
        }
      }
    }
    expect(hits, isEmpty);
  });

  test('the metadata channel has one name on both sides (S13.2)', () {
    const channel = 'io.github.buffur.culmina/metadata_document';
    expect(
      _read('lib/data/metadata/android_capture_file_access.dart'),
      contains("'$channel'"),
    );
    expect(
      _read(
        'android/app/src/main/kotlin/io/github/buffur/culmina/'
        'MetadataDocumentChannel.kt',
      ),
      contains('"$channel"'),
    );
  });
}
