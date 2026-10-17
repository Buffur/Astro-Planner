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
