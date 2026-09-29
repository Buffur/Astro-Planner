# Stage 10 measurements

> The Stage 10 record (DECISIONS E.1, D10-4): every measurement, with its method, build mode, ABI and
> device, and every optimisation as claim → evidence → change → before → after → regression check.
> Unlike measurements are never compared. Emulator numbers are RUNTIME VERIFIED and **indicative**
> (D10-1); a physical device run is Stage 11's.

## Environment

| Item | Value |
| --- | --- |
| Commit | `8b62b87` (application code as at `0f09608`) |
| Toolchain | Flutter 3.47.4 (Dart 3.13.3); AGP 9.1.0; Kotlin 2.4.0; Gradle 9.3.1 |
| Emulator | AVD `Medium_Phone_API_36.1`: Android 16 (API 36), `sdk_gphone64_x86_64` (a user build, no root), x86_64 with arm64 translation, 6 vCPU, 2 GB RAM |
| Host | Windows 11, the development machine |

**Build notes (this machine only; nothing in the repository changed):**
- An antivirus (Avast) intercepts HTTPS and re-signs it with its own root. The JDK Flutter uses
  (Android Studio's JBR 21) does not trust that root and has no Windows trust-store provider, so
  Gradle could not download its distribution or the Android and Kotlin plugins. The first build
  therefore ran through `android/gradlew.bat` on the installed Oracle JDK 25 with
  `JAVA_TOOL_OPTIONS=-Djavax.net.ssl.trustStoreType=Windows-ROOT` (the JVM reads the Windows store;
  no system or security setting was changed). Later builds ran through `flutter build` offline.
- The project is on `D:` and the pub cache on `C:`. Kotlin's incremental compiler then fails ("Could
  not close incremental caches") in a plugin module. The builds passed
  `-Pkotlin.incremental=false` (`--android-project-arg=kotlin.incremental=false` for `flutter build`).
- The release builds are signed with the debug key (no `key.properties` on this machine; trap 21).
  Signing does not change the sizes measured below.

## S10.1 — Size

### The artifacts (commit `8b62b87`)

| Artifact | Command | Bytes | MB (10⁶) |
| --- | --- | ---: | ---: |
| Release app bundle (three ABIs; includes `BUNDLE-METADATA`: debug symbols and the R8 map, which Play keeps and never sends to phones) | `gradlew bundleRelease` (as `flutter build appbundle --release`) | 68,546,061 | 68.5 |
| Release APK, universal (three ABIs) | `gradlew assembleRelease` | 71,892,837 | 71.9 |
| **Release APK, arm64-v8a** (what an arm64 phone receives; the owner's phone is arm64) | `flutter build apk --release --split-per-abi` | **24,768,842** | **24.8** |
| Release APK, armeabi-v7a | same | 22,538,388 | 22.5 |
| Release APK, x86_64 | same | 26,286,107 | 26.3 |
| Debug APK (universal) | `gradlew assembleDebug` (as `flutter build apk --debug`) | 183,643,172 | 183.6 |

TASK 16.2 recorded a 66.5 MB release bundle on the owner's machine (2026-09-24). Today's 68.5 MB is
from a different machine and six Stages later. The two are close but are not treated as a
before/after.

### What the arm64 release APK contains

From `flutter build apk --release --analyze-size --target-platform android-arm64`. The sizes are the
analyzer's, and the shares are of the APK's 24,188 KiB; native libraries are stored uncompressed in the APK (16 KB alignment):

| Part | Size | Share |
| --- | ---: | ---: |
| `libflutter.so`, the Flutter engine | 11,473 KiB | 47 % |
| `libapp.so`, the app's compiled Dart (AOT) | 9,729 KiB | 40 % |
| `libsqlite3.so`, SQLite (`sqlite3_flutter_libs`) | 1,692 KiB | 7 % |
| `libdartjni.so` and `libdatastore_shared_counter.so` (plugins) | 135 KiB | 0.6 % |
| Other ABIs' copies of those two plugin libraries (from the plugins' archives) | 204 KiB | 0.9 % |
| `classes.dex` (Java/Kotlin, after R8) | 505 KiB | 2 % |
| `resources.arsc` and `res/` (launcher icon, Android resources) | 362 KiB | 1.5 % |
| `assets/flutter_assets` (the OpenNGC catalog, its notice, `NOTICES.Z` licences, shaders, the Material Icons subset) | 152 KiB | 0.6 % |

The Dart AOT code (9.7 MiB), by package: `package:flutter` 3.5 MiB; `package:astroplan` 1.4 MiB;
read-only strings and pools 0.8 MiB; `package:timezone` 446 KiB (the `latest_all` zone data, kept on
purpose, trap 11); Dart core libraries about 1.6 MiB together (`dart:core`, `dart:ui`,
`dart:typed_data`, `dart:io`, `dart:async`, `dart:_http` and others); `drift` 195 KiB; `flutter_map`
185 KiB; `archive` 105 KiB; `go_router` 92 KiB; everything else under 80 KiB each.

**Reading:** 87 % of a phone's app is the Flutter engine and the compiled Dart that every Flutter
app ships. The app's own code is 1.4 MiB. Its assets are 0.15 MiB. No asset, font or image is a
material contributor.

### The installed footprint on the emulator

Android's *Settings → Apps → Astro Planner → Storage & cache*, read with `uiautomator`, after one
launch (the first-run screen, the catalog seeded), the app stopped:

| Build | App size | User data | Cache | **Total** |
| --- | ---: | ---: | ---: | ---: |
| Debug (the universal debug APK) | 184 MB | 130 MB | 73.73 kB | **314 MB** |
| Release (the x86_64 APK) | 27.42 MB | 193 kB | 197 kB | **27.81 MB** |

What the debug build's 130 MB of user data holds (`run-as`, possible only on a debuggable build):
`app_flutter/flutter_assets/kernel_blob.bin` 118,467,288 bytes and `isolate_snapshot_data`
11,647,016 bytes (the JIT program that a debug build copies out of its APK on first start), and the
database `astroplan.sqlite` 102,400 bytes. The debug APK itself holds that same kernel (118 MB before
compression), debug engines for three ABIs (33–40 MB each before compression), a Vulkan validation
layer (15 MB) and unshrunk dex (17 MB).

### The ~277 MB of 08 §26: classified

The dogfooding report gives no build type or screen. The only builds recorded on the owner's phone
are debug builds (`PROGRESS_HISTORY.md`, M1–M4), and a debug install here totals 314 MB by the same
Android screen a user reads, 94 % of it the debug program (the APK and its extracted JIT kernel).
**Classification: the 277 MB is consistent with a debug build's installed total, not with a release
build**. The exact number cannot be reproduced: the owner's build, device state and reading are
unrecorded, and a phone's total also moves with its optimisation state. It stays recorded as the
owner's HUMAN observation. The owner can confirm it by checking the build type installed on the
phone.

### The release baseline (D10-3)

- **What a user receives:** the arm64-v8a release APK, **24.8 MB** (23.6 MiB). Play delivers the
  same code from the bundle as split APKs and compresses the download, so the store's download size
  is expected to be smaller. Play reports it after an upload (owner, Stage 11).
- **Installed:** **27.8 MB** for a release build (x86_64 on the emulator, after the first run).
- **Main contributors:** the Flutter engine (47 %), compiled Dart (40 %), SQLite (7 %). The app's
  data after the first run is under 0.2 MB.
- **Size target:** none (the plan: only if the owner sets one). A release that installs in about
  28 MB is reasonable for a Flutter app with an embedded database, so no size reduction is claimed or
  required. S10.6 and S10.7 still check the few options that exist (dependencies, symbols).
