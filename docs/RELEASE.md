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

## Size (Stage 10, 2026-09-30)

Measured in `refinement/evidence/STAGE_10_MEASUREMENTS.md`: the release bundle is 68.5 MB (three ABIs
plus the symbols Play keeps); an arm64 phone receives about 24.8 MB (the arm64-v8a release APK) and
the app takes 27.8 MB installed. A **debug** build is 184 MB and about 314 MB installed; never judge
the app's size from a debug install.

**Optional, not adopted (the owner's call at release time):** `--split-debug-info=<dir>` makes the
app 1.3 MB smaller (−5 %). Then each release's symbols file (about 4 MB) must be kept outside the
repository, or that release's Dart stack traces cannot be read again (`flutter symbolize -i <trace>
-d <symbols file>`). `--obfuscate` saves 0.2 MB more and is not recommended for this open-source app.

## Build notes (a development machine)

- **An antivirus that inspects HTTPS** (for example Avast) makes Gradle's downloads fail with "PKIX
  path building failed", because the JDK Flutter uses (Android Studio's JBR) does not trust the
  antivirus's root. Run the first build, which downloads Gradle and the plugins, with a JDK that has
  the Windows trust store (for example Oracle JDK 25) from `android/`:
  `JAVA_HOME=<that JDK> JAVA_TOOL_OPTIONS=-Djavax.net.ssl.trustStoreType=Windows-ROOT gradlew.bat
  bundleRelease`. Later builds work offline through `flutter build`. No system setting needs
  changing.
- **The project and the pub cache on different drives** (for example `D:` and `C:`) make Kotlin's
  incremental compiler fail in a plugin ("Could not close incremental caches"). Add
  `--android-project-arg=kotlin.incremental=false` to `flutter build`, or `-Pkotlin.incremental=false`
  to `gradlew`.

## Status (2026-09-24)

- A release bundle was built on the development machine (66.5 MB; 15 native libraries
  for arm64-v8a, armeabi-v7a and x86_64, all aligned to 16 KB or 64 KB, symbols moved to
  `BUNDLE-METADATA`, R8 mapping present). It is **debug-signed** — the upload key does
  not exist yet — so `tool/check_bundle.dart` fails on the signer, as it should.
- Not done yet (owner): install cmdline-tools, create the upload key and
  `key.properties`, build the signed bundle, install a release build on a device.
