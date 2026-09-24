# Release build and signing (Android)

> Written for TASK 16.2 (2026-09-24). Follows Flutter's Android deployment guide
> (<https://docs.flutter.dev/deployment/android>). The upload key and its passwords are
> the owner's: they are created and kept by the owner, never committed, and never given
> to an agent (MASTER_ROADMAP 16.2).

## What is set up in the repository

- `android/app/build.gradle.kts` signs release builds with the upload key described by
  `android/key.properties`. Without that file the release build is signed with the
  **debug** key and Gradle warns — Google Play rejects a debug-signed bundle, so such a
  build cannot be uploaded by mistake.
- `key.properties`, `*.jks` and `*.keystore` are gitignored (root and `android/`).
- Application id `io.github.chacha12.astroplanner`, label "Astro Planner" (OD-07).
- `minSdk` 24 and `targetSdk` 36 come from Flutter 3.47.4's defaults. Google Play requires
  target API 36 for new apps and updates from 31 August 2026.
- R8 (code and resource shrinking) is on for release builds, as the Flutter Gradle plugin
  sets it; the mapping file and native debug symbols go into the bundle's
  `BUNDLE-METADATA`, where Play reads them for crash reports. No custom ProGuard rules
  are needed today (the app uses no reflection-based libraries); add
  `android/app/proguard-rules.pro` only if a release build misbehaves.
- `tool/check_bundle.dart` checks a bundle before upload (below).

## One-time setup (owner)

1. **Android SDK command-line tools.** In Android Studio: *Settings → Languages &
   Frameworks → Android SDK → SDK Tools → Android SDK Command-line Tools (latest)*.
   Without them `flutter build appbundle` builds the bundle but then reports "failed to
   strip debug symbols", because its check needs `apkanalyzer` (the bundle itself is
   fine — `tool/check_bundle.dart` confirms it). `flutter doctor` should then show no
   Android toolchain issue.
2. **Create the upload key** — once, outside the repository, with the JDK that ships with
   Android Studio:

   ```
   "C:\Program Files\Android\Android Studio\jbr\bin\keytool.exe" -genkey -v -keystore %USERPROFILE%\keys\astro-planner-upload.jks -keyalg RSA -keysize 2048 -validity 10000 -alias upload
   ```

   Choose strong passwords and keep them, and a copy of the `.jks` file, in your password
   manager or another safe place. If the upload key is lost, Play support can reset it
   (Play App Signing), but it takes time.
3. **Create `android/key.properties`** (never commit it; it is gitignored):

   ```
   storePassword=<your keystore password>
   keyPassword=<your key password>
   keyAlias=upload
   storeFile=C:\\Users\\<you>\\keys\\astro-planner-upload.jks
   ```

4. **Play App Signing.** When the app is first created in the Play Console, keep the
   default: Google generates and keeps the *app signing key*; your key above is only the
   *upload key*. Upload bundles (`.aab`), not APKs.

## Each release

1. **Version.** In `pubspec.yaml`, `version: X.Y.Z+N`:
   - `N` (the Android `versionCode`) must be **higher than every build ever uploaded**,
     including internal tests — increase it for every upload;
   - `X.Y.Z` is the version users see; update `AppIdentity.version` in
     `lib/core/config/app_identity.dart` to the same `X.Y.Z` (a test keeps them equal).
2. **Quality gate:** `dart run tool/check.dart` must pass.
3. **Build** (do **not** pass `--no-pub`: without it, `flutter build` regenerates the
   plugin registrant for release, leaving out the dev-only `integration_test` plugin;
   with `--no-pub` after a debug build or test run the release compile fails with
   "package dev.flutter.plugins.integration_test does not exist"):

   ```
   flutter build appbundle --release
   ```

   Output: `build/app/outputs/bundle/release/app-release.aab`.
4. **Check the bundle:**

   ```
   dart run tool/check_bundle.dart
   ```

   It must end with "Bundle check passed": every native library 16 KB aligned, no debug
   sections left in them, and a signer that is **not** `CN=Android Debug`.
5. **Install test** (the roadmap's test for 16.2): on a device, `flutter build apk
   --release` and `flutter install`, or upload to an internal testing track and install
   from Play. Open the app and run the core loop once.
6. **Upload** the `.aab` to the Play Console (internal testing first). Check its App
   Bundle Explorer for warnings (16 KB, target API, permissions).

## Status (2026-09-24)

- A release bundle was built on the development machine (66.5 MB; 15 native libraries
  for arm64-v8a, armeabi-v7a and x86_64, all aligned to 16 KB or 64 KB, symbols moved to
  `BUNDLE-METADATA`, R8 mapping present). It is **debug-signed** — the upload key does
  not exist yet — so `tool/check_bundle.dart` fails on the signer, as it should.
- Not done yet (owner): install cmdline-tools, create the upload key and
  `key.properties`, build the signed bundle, install a release build on a device.
