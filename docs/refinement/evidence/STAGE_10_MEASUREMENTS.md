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

## S10.2 — Performance scenarios and baselines

### The suite

- **`integration_test/perf_scenarios_test.dart`**, one test through the real UI and a real SQLite
  file, with a fake forecast and fake position services. On Android it records each step's frames with
  `IntegrationTestWidgetsFlutterBinding.watchPerformance` (engine `FrameTiming`: build and raster
  times) and times the data work with a `Stopwatch`. On the host the quality gate runs it as a smoke
  test, with no timing and a small history (D10-6).
- **Run on a device or emulator** (results in `build/integration_response_data.json`):

  ```
  flutter drive --profile --no-dds -d <device> --driver=test_driver/perf_driver.dart --target=integration_test/perf_scenarios_test.dart
  ```

  `--no-dds` is required: with the Dart Development Service on, the binding cannot reach the VM
  service it uses for timings. On this machine also add
  `--android-project-arg=kotlin.incremental=false` (see "Build notes").
- **Scenarios**, in the plan's priority: the rig editor (open "Add rig"; tap the pixel size, which
  opens the real soft keyboard on a device; type "3.7612"; tap the name and type "Refractor 400"); the
  planner (open; a block through its dialog: tap it, tap Frame Count, type "36", Save; four block edits;
  a night change; a target change; a section opened); Night & Moon; Weather; the Logbook with 300 saved
  plans, two in three with a result (open; search "M3"; a filter; an entry); first-run seeding on a new
  file (ENG-12); the Logbook's list query (ENG-11); tonight's candidates (TASK 10.4).
- **`test/presentation/performance/rig_editor_rebuilds_test.dart`**, host only: the elements rebuilt
  while the keyboard's bottom inset grows over 12 frames (as Android animates it), and per keystroke.
  The counts are deterministic.

### Host counts (deterministic; `8b62b87`)

| Rig editor step | Elements rebuilt | The dialog's content rebuilt |
| --- | ---: | ---: |
| The keyboard opens (12 frames) | 7,500 (625 per frame) | **12 of 12 frames** |
| 6 keystrokes in the pixel size (its `onChanged` calls `setDialogState`) | 3,696 (616 per key) | 6 of 6 |
| 6 keystrokes in the name (no `setDialogState`) | 2,646 (441 per key) | 0 |

Reading: the dialog content (about 600 elements, every field) rebuilds on **every frame of the
keyboard animation**. The only `MediaQuery.of(context)` in `lib/` is in that builder
(`equipment_editor.dart:224`, for the screen width), and `MediaQuery.of` depends on every
MediaQuery field, the keyboard inset included. A keystroke in a name field still rebuilds about 440
elements, because Flutter's `Form` rebuilds all its fields when any one changes (framework
behaviour).

### Emulator, profile mode (two runs; D10-1, indicative)

`8b62b87`, the x86_64 emulator above, profile build, 60 Hz (a 16.7 ms frame). Frame times in ms,
run 1 / run 2. "Over" counts frames above 16.7 ms.

| Scenario | Frames | Build avg | Build p90 | Build worst | Build over | Raster avg | Raster p90 | Raster over |
| --- | ---: | ---: | ---: | ---: | ---: | ---: | ---: | ---: |
| Rig editor: open | 11/10 | 9.3/19.1 | 11.6/65.4 | 69/105 | 1/2 | 23.2/41.2 | 42.6/71.3 | 5/5 |
| Rig editor: focus, keyboard opens | 31/30 | 6.8/4.3 | 16.0/7.6 | 73/48 | 3/2 | 30.4/15.6 | 50.6/33.2 | 25/8 |
| Rig editor: type in pixel size | 11/11 | 1.7/1.0 | 3.5/1.9 | 7/3 | 0/0 | 9.3/14.2 | 13.7/25.2 | 0/3 |
| Rig editor: tap and type the name | 37/37 | 4.1/2.8 | 6.8/4.6 | 43/29 | 1/1 | 35.3/14.5 | 63.9/25.8 | 33/11 |
| Planner: open | 19/19 | 2.5/3.3 | 2.5/5.1 | 27/37 | 1/1 | 9.4/11.4 | 13.2/13.8 | 1/2 |
| Planner: a block through its dialog | 39/39 | 6.1/9.6 | 17.1/16.5 | 52/90 | 5/6 | 44.9/33.2 | 94.7/63.7 | 26/26 |
| Planner: four block edits | 10/11 | 5.5/6.2 | 10.3/11.9 | 14/18 | 0/1 | 9.9/11.3 | 14.4/15.4 | 0/1 |
| Planner: night change | 11/11 | 2.1/2.5 | 2.8/6.2 | 9/14 | 0/0 | 9.1/8.6 | 14.2/14.1 | 1/0 |
| Planner: target change | 11/11 | 2.0/1.7 | 1.3/2.6 | 16/10 | 0/0 | 7.3/7.0 | 11.7/11.4 | 0/0 |
| Night & Moon: open | 11/11 | 1.8/2.0 | 4.1/3.8 | 7/9 | 0/0 | 5.7/8.5 | 10.2/11.9 | 0/1 |
| Weather: open | 12/11 | 2.8/4.0 | 2.2/3.9 | 25/30 | 1/1 | 11.7/8.4 | 26.6/14.6 | 2/1 |
| Logbook (300): open | 14/14 | 6.2/4.8 | 8.1/9.8 | 68/43 | 1/1 | 8.4/8.4 | 15.5/16.8 | 0/2 |
| Logbook: search "M3" | 25/25 | 8.1/7.0 | 15.8/18.7 | 103/94 | 2/3 | 29.6/36.4 | 53.3/68.6 | 13/16 |
| Logbook: a filter | 33/33 | 2.4/6.2 | 8.4/15.7 | 14/65 | 0/3 | 21.0/43.2 | 44.5/77.2 | 14/21 |
| Logbook: an entry | 33/33 | 3.5/3.1 | 3.5/6.8 | 60/45 | 1/1 | 21.3/17.1 | 66.1/38.0 | 10/7 |

| Work (elapsed) | Run 1 | Run 2 | Note |
| --- | ---: | ---: | --- |
| **First-run catalog seeding (164 entries; ENG-12)** | **14,804 ms** | **12,950 ms** | Before `runApp`: the first launch shows no app for this long |
| First-run equipment seeding | 117 ms | 60 ms | |
| The Logbook's list of 300 sessions with their blocks (ENG-11) | 48 ms | 52 ms | Two queries (`_blocksFor`); no N+1 |
| Tonight's candidates (TASK 10.4: under 1 s) | 313 ms | 501 ms | Within the budget |
| Test setup: 300 saved plans (900 writes) | 41,497 ms | 40,113 ms | Not a user path; about 45 ms per write transaction on this emulator |

**Reading:**
- **Build times** (the app's work per frame) are within the frame on average for every scenario.
  They exceed it on the first frames of a newly opened screen or dialog (the worst values, 27–105
  ms) and during the keyboard opening. Both runs agree on where the overruns are.
- **Raster times** (drawing) dominate the misses, above all while the keyboard animates (focus,
  the name, the block dialog, search). This emulator renders through host GPU emulation
  (`ro.hardware.egl=emulation`), so raster numbers say little about a phone. **Not claimed as a
  defect** without a device trace (Stage 11).
- **Verified bottleneck 1 — first-run seeding (ENG-12):** 13–15 s on this emulator, before the first
  frame. Each of the 164 catalog rows is its own autocommit transaction (a sync to storage per row;
  about 45 ms per write transaction here). On a phone's faster storage it is shorter, but it is the
  same 164 syncs. → S10.5.
- **Verified bottleneck 2 — the rig editor rebuilds its whole form on every keyboard frame** (host
  count 12 of 12; device: the focus step has the editor's worst build frames). → S10.3.
- **Not bottlenecks:** ENG-11 (48–52 ms for 300 sessions); the candidates (313–501 ms); the planner's
  edits, night and target changes (build averages 2–6 ms); the detail screens.
- Run-to-run variation on the emulator is large (up to 2× for a worst frame), so single-run
  differences under that are not evidence.

## S10.3 — Form lag

- **Claim:** the rig editor's form rebuilds on every frame while the soft keyboard opens (08 §22:
  "lags when the user taps into editable text fields … particularly … device information").
- **Evidence:** S10.2's host count: the dialog content (about 600 elements, every field) rebuilt on
  12 of 12 keyboard frames. Cause: `equipment_editor.dart:224` read the screen width with
  `MediaQuery.of(context).size`, which subscribes the `StatefulBuilder` holding the whole form to
  every MediaQuery field, the keyboard's bottom inset included. It was the only `MediaQuery.of` in
  `lib/`. The investigation's other categories, checked:
  - storage or network on focus or typing: none (the editor writes only on Save);
  - validation: runs on Save, not per keystroke (no `autovalidateMode`);
  - calculation on typing: the sensor size and the focal ratio are derived with `setDialogState` in
    seven fields, one rebuild per keystroke. Measured cheap on the emulator (build average 0.9–1.7 ms
    while typing in the pixel size), so it is kept: it shows the derived values as the user types;
  - `Form` rebuilds all its fields on any change (Flutter's own behaviour; about 440 elements per
    keystroke in the name). Measured cheap (build average 2.4–4.1 ms), so it is kept;
  - the target, site and block editors: no `MediaQuery.of` (the only such dependency was the rig
    editor's).
- **Change:** `MediaQuery.sizeOf(context).width` (the same width; only the dependency changes).
  `test/presentation/performance/media_query_aspects_test.dart` keeps `MediaQuery.of` out of `lib/`.
- **Before → after, host (deterministic):**

  | Rig editor step | Before: elements / form | After: elements / form |
  | --- | ---: | ---: |
  | The keyboard opens (12 frames) | 7,500 / 12 | **456 / 0** |
  | 6 keystrokes in the pixel size | 3,696 / 6 | 3,696 / 6 (unchanged, intended) |
  | 6 keystrokes in the name | 2,646 / 0 | 2,646 / 0 |

- **Before → after, emulator (profile; the same scenario; two runs each; indicative):**

  | Step | Build avg | Build p90 | Build worst | Build over 16.7 ms |
  | --- | --- | --- | --- | --- |
  | Focus, the keyboard opens: before | 6.8 / 4.3 | 16.0 / 7.6 | 73 / 48 | 3 / 2 |
  | Focus, the keyboard opens: after | 5.1 / 2.7 | 13.6 / 5.5 | **35 / 11** | 3 / 0 |
  | Tap and type the name: before | 4.1 / 2.8 | 6.8 / 4.6 | 43 / 29 | 1 / 1 |
  | Tap and type the name: after | 2.4 / 2.4 | 3.5 / 4.6 | 23 / 17 | 1 / 1 |

  The worst build frames while the keyboard opens are lower in both runs after the change. The
  emulator's run-to-run spread is large, so the host count is the evidence. Raster times did not
  change (the emulated GPU; not the app's work).
- **Regression check:** `rig_editor_rebuilds_test.dart` now asserts no form rebuild on keyboard
  frames (mutation-checked: with `MediaQuery.of` restored it fails), one per keystroke in a derived
  field, none in the name; every existing editor test passes unchanged (the full gate, below).
  Behaviour and saved values are unchanged (the width is the same value).
- **On a phone** the gain is unverified until a device trace (Stage 11): the owner's lag may also have
  come from the debug build (S10.1), which runs JIT code several times slower than a release.
- **Verification:** the full gate after the change, **PASS** (1,837 tests, 2 skips; host E2E core_loop 2 and perf_scenarios 1; Flutter 3.47.4).

## S10.4 — The planner, the timeline and the detail screens

- **Claim checked:** Stage 6's reactive planner (block edits → budget, fit, timeline, gain graph), the
  timeline's redraw on night and target changes, and the detail screens might do unnecessary work.
- **Evidence (S10.2's emulator runs, profile, indicative):** build averages 1.7–6.2 ms and p90 1.3–12
  ms for opening the planner, four block edits, a night change, a target change, Night & Moon and
  Weather; the only frames over 16.7 ms are the first frame of a newly opened screen (27–37 ms) and one
  block-edit frame in one run (18 ms). Raster averages 5.7–11.7 ms.
- **Evidence (host, a temporary probe, deleted):** elements rebuilt per event, through the real app and
  database at 412 × 915:

  | Event | Elements rebuilt | What rebuilds |
  | --- | ---: | --- |
  | The keyboard opens over the planner (12 frames) | 432 (36 per frame) | Only the `Scaffold`, `MediaQuery` and route machinery; no planner section |
  | The keyboard opens over the block dialog (12 frames) | 588 (49 per frame) | The same, plus the dialog's frame; no planner section |
  | 2 keystrokes in the block dialog's Frame Count | 646 | The dialog's fields (focus and decoration) |
  | One block edit through the ViewModel (then settled) | 1,268 | The planner sections that show the plan: the capture plan, budget, fit, status and gain graph |

- **Reading:** the memoization of trap 16 holds (a block edit costs one pass over the dependent
  sections, 5–6 ms of build on the emulator); nothing rebuilds on keyboard frames outside the dialog;
  the timeline and the detail screens draw within the frame after their first frame. The first-frame
  spikes of a new screen are Flutter's first build and shader warm-up, not a repeated cost.
- **Change:** none. **Outcome: measured, no change needed.** No cache added; sampling, grids and
  calculations untouched. Large-text rendering was not profiled separately (no change was made; the
  accessibility sweep keeps covering 200 % text).
