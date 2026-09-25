# 04 — Functional and runtime audit

> **Audit stage 4.** Run on 2026-09-24/25 against `main` @ `becae04`. This is an audit only:
> no application code or source-of-truth document was changed.
>
> **Inputs.** `docs/audit/00_CONTEXT_BASELINE.md` **still does not exist** in the repository.
> I used this session's Stage 0 baseline and audits 01–03 instead.
>
> **Temporary probes.** To reproduce suspected issues against the real code, I wrote five
> probe tests in `test/_audit_probe/`, ran them, and then **deleted** them. `git status`
> afterwards shows only `docs/audit/`. Copies are kept outside the repository in the
> session scratchpad (`audit_probes/p1–p5`). They exercised only public APIs and did not
> change application code.

## 0. Environment and evidence levels

| Item | Finding |
| --- | --- |
| Host | Windows 11 Pro 10.0.26200; Flutter 3.47.4 / Dart 3.13.3; Visual Studio Build Tools 2026 (Windows desktop builds work) |
| Android | The SDK is installed (`AppData/Local/Android/sdk`: build-tools, platforms, emulator 37.1.11.0, platform-tools). **cmdline-tools are missing** and the **licence status is unknown** (`flutter doctor`). **There are no system images and no AVD** (`emulator -list-avds` is empty; `system-images/` is absent). `adb devices` lists **no device**. Creating an emulator needs a system-image download; that was not done (it needs owner approval) |
| Devices available | Windows desktop, Chrome, Edge (`flutter devices`). Web is not a supported target: the database uses `dart:io`/native SQLite |

**Evidence levels used below:**

| Level | Meaning |
| --- | --- |
| CODE VERIFIED | Read in source |
| TEST VERIFIED | A test in the repository, or a temporary probe, executed on the host test engine (`flutter-tester`) and passed or produced the recorded output |
| RUNTIME VERIFIED | Executed in a real application build. Here that means only the **native Windows desktop** build (not a target platform) |
| DEVICE VERIFIED | On Android hardware or an emulator: **none** |
| HUMAN VERIFIED | By a person using the app: **none** |
| UNVERIFIED | Could not be exercised here |

**Runs performed:**

| Run | Command | Result |
| --- | --- | --- |
| R1, R2 (2026-09-24) | `dart run tool/check.dart`; `flutter test --no-pub` plus host E2E | 896 unit/widget tests pass, 2 E2E pass, analyze clean, format clean, encoding clean |
| R3 (2026-09-25) | `flutter run -d windows integration_test/core_loop_test.dart` | Built `build\windows\x64\runner\Debug\astroplan.exe` in 33.1 s. **Both E2E tests passed as a native Windows app** ("the core loop…" at 00:34; "time zones…" at 00:45; exit 0; wall time 4 min 43 s). The test app process was closed afterwards |
| R4 (2026-09-25) | Five temporary probes (P1–P5) | See §2 |
| R5 (2026-09-25) | `dart run tool/check.dart` on the clean tree after the probes were removed | See the last line of §4 |

**What the end-to-end run covers** (`integration_test/core_loop_test.dart:247,372`; TEST_PLAN § 15.5):

- The core loop, driven through the real UI:
  - first-run Skip;
  - a site typed in the Sites editor;
  - Tonight, then the planner;
  - M31 and the seeded rig chosen through the pickers;
  - the night, forecast and opportunity window;
  - Save, Start, three frames;
  - a simulated process death (widgets torn down, the database file closed);
  - a restart 45 minutes later, the resume prompt, Keep going, three more frames;
  - Finish, Results, Complete;
  - the Sessions log and the session detail;
  - Export, with the v2 manifest parsed back.
- Time-zone cases: a site zone different from the device zone, and a run across the US daylight-saving change.

**What it fakes:**

- **Faked:** the forecast, GPS, the device zone and the share sheet.
- **Real:** the SQLite file and the widget tree.

---

## 1. Main user flows

"Host" below means `flutter-tester` or a probe. "Win" means the native Windows run (R3).

| # | Flow | Evidence | Level reached | Observed issues | Not verifiable here |
| --- | --- | --- | --- | --- | --- |
| 1 | Application startup | `main.dart:44-143` (restore, seeding, then loads before `runApp`); `planner_bootstrap_test.dart:46` (seeding before the first read); `home_screen_test.dart:288` (bootstrap failure with retry); lifecycle L1 (fresh offline install); E2E cold start (Win) | TEST, RUNTIME (Win) | RT-02 (a failed seed is never retried); RT-03 (a newer database gives a generic error and an endless retry); first-run seed takes 885 ms on the host (P2) | Cold start on Android, the splash screen, time to first frame on a low-end phone |
| 2 | Site / location handling | `sites_screen_test.dart:110-284`; `planner_sites_test.dart:89` ("switching sites changes all night times"); `planner_site_test.dart:121` (GPS creates no site); `location_picker_screen_test.dart:97-169` (each permission outcome, with a fake service); E2E typed site (Win) | TEST, RUNTIME (Win: the typed path) | — | The real GPS fix, Android permission dialogs, the "Open settings" deep links, OSM tiles on a device (L2) |
| 3 | Target selection | `target_selection_screen_test.dart`; `drift_target_repository_test.dart:24-139`; `astro_math_coordinates_test.dart`; E2E picks M31 (Win) | TEST, RUNTIME (Win) | New drafts pre-select M42 without an "example" label (02/ENG-15, CODE VERIFIED) | — |
| 4 | Equipment selection | `equipment_selection_screen_test.dart:76-403`; E2E picks the seeded rig (Win) | TEST, RUNTIME (Win) | — | — |
| 5 | Astronomy information | Reference tests (`astronomy_reference_test.dart`, `moon_calculator_test.dart`); P3 (fine-scan comparison) | TEST | RT-08 (grid edges and window end, measured); RT-09 (the two "Moon up" definitions differ by 5–10 min, measured) | — |
| 6 | Weather | `open_meteo_forecast_test.dart` (recorded fixtures); `night_weather_service_test.dart`; `weather_forecast_widget_test.dart:162-223`; P1; P5 | TEST | RT-01 (freshness frozen; no reload when the night rolls over; wrong age saved to the snapshot, **reproduced**); RT-07 (no User-Agent on Open-Meteo requests, **reproduced**) | Live Open-Meteo responses; network failures on a device |
| 7 | Imaging opportunity | `imaging_opportunity_calculator_test.dart` (V1–V12, polar cases); `tonight_opportunity_widget_test.dart:139,171`; `tonight_candidates_screen_test.dart:67-93`; E2E window (Win) | TEST, RUNTIME (Win) | RT-09 | Candidates timing on a mid-range device (TASK 10.4 acceptance) |
| 8 | Capture planning | `capture_budget_calculator_test.dart`; `fit_analyzer_test.dart`; `capture_plan_widget_test.dart`; `capture_plan_fill_test.dart:87`; E2E plan (Win) | TEST, RUNTIME (Win) | — | — |
| 9 | Session creation (draft, Save, New, Duplicate) | `planner_draft_session_test.dart:87-183`; `planner_session_save_test.dart:80`; E2E Save (Win); P4 | TEST, RUNTIME (Win) | RT-04 (Save and an edit interleave, **reproduced with injected timing**); RT-05 (invisible drafts pile up, **reproduced**); RT-06 (a draft without a site takes the UTC date, **reproduced**) | — |
| 10 | Execution (tracker) | `execution_screen_test.dart:124-321`; `drift_session_execution_test.dart`; `execution_machine_test.dart`; E2E Start, frames, Finish (Win) | TEST, RUNTIME (Win) | RT-10 (the resume prompt's Finish skips reconciliation) | Lock/unlock, keep-screen-on on a real screen, the 30 s refresh on a device (TEST_PLAN:789) |
| 11 | Process / app restart | E2E restart after a simulated death (Win); lifecycle L3 and L4 on the host; `drift_session_execution_test.dart:255` (kill mid-block, file database) | TEST, RUNTIME (Win, simulated death inside one process) | — | A real OS process kill, "Don't keep activities", a reboot (L3, L4) |
| 12 | Logbook | `session_list_filter_test.dart`; `session_detail_test.dart:156-316`; `logbook_screen_test.dart`; E2E Sessions and detail (Win); P4 (200 sessions) | TEST, RUNTIME (Win) | The Sessions tab loads 200 completed sessions in 198 ms on the host (P4); acceptable here, device unknown | Scale on a device |
| 13 | Export / backup / restore | `session_manifest_codec_test.dart:141` (round trip); `backup_restore_test.dart:121-248` (backup, stage, apply at next start, refusals); `backup_section_test.dart`; E2E Export parsed back (Win) | TEST, RUNTIME (Win: export) | TD-056 (preferences not included) and 02/ENG-14 (stale preference pointers after a restore) are CODE VERIFIED only | The share sheet and file picker (faked); restore across uninstall and reinstall on an emulator (TEST_PLAN:846); Android Auto Backup |
| 14 | Offline / airplane mode | Lifecycle L1 (fresh offline install: first run, typed site, the opportunity works, forecast "unavailable"); `night_weather_service_test.dart:128-152` (cache with age, unavailable, out of range); `planner_sky_darkness_test.dart:87` (no network call on a location change) | TEST | RT-01 affects how an offline cache is labelled over time | Real airplane mode, map tiles offline, a DNS or timeout on a device |
| 15 | Permissions and failure states | `location_picker_screen_test.dart` (services off, denied, denied forever); lifecycle L8 (full disk while planning and tracking); `storage_failure_test.dart`; `failure_feedback_test.dart`; P5 (newer schema) | TEST | RT-02, RT-03 | Android permission UI; "denied forever" through system settings; low storage on a device |

The Save and Start buttons (`home_screen.dart:300-306` for the planner; `tonight_home_screen.dart:382` for Tonight) are hidden until a night, a target and a rig all exist. That means the `StateError('Saving needs a site, a target and a rig.')` thrown in `capture_analysis_viewmodel.dart:245-249`, which `startSessionWithFeedback` does not catch (`start_session.dart:16-44` catches only `StorageFailure` and `SessionStateError`), cannot be reached from the UI. CODE VERIFIED; not an issue.

---

## 2. Issues observed

### RT-01 — The forecast is shown as "current" for hours, and is not reloaded when the night rolls over
- **Level:** TEST VERIFIED (probe P1).
- **Reproduction (P1):**
  1. Build the real ViewModel graph with a controllable clock and a site with a zone (`PlannerHarness`).
  2. Load the forecast at 2026-09-24 14:00 UTC.
  3. Advance the clock by 5 h without any other input.
  4. Save.
  5. Advance to 2026-09-25 15:00 UTC.
- **Observed:**

  | Step | Output |
  | --- | --- |
  | t0 | `calls=1 age=current ageDuration=0:00:00` |
  | t0 + 5 h | `calls=1 age=current ageDuration=0:00:00`, same state object |
  | The snapshot saved at t0 + 5 h | `age=current`, `fetchedAtUtcMs=1790258400000`, `takenAtUtcMs=1790276400000` (5 h apart, yet recorded as current) |
  | Next day | The default night is 2026-09-25, but the forecast still covers the night that starts 2026-09-24 11:01:57Z. `calls=1`, `age=current` |
  | After an unrelated preference change | `calls=2`: only an input notification triggers the reload |

- **Expected:** ADR-012 §6 ("cached data is never presented as current"). Aging begins at 3 h and stale at 12 h.
- **Impact:** a planner kept open, or resumed from the background, shows an old forecast labelled "Updated just now". After mean solar noon it also annotates the new night with the previous night's hours (they fall outside the new night, so they read as missing).
- **Severity:** Medium. **On a device:** UNVERIFIED how long Android keeps the process alive in practice.

### RT-02 — A failed first-run catalog seed is recorded as done and never retried
- **Level:** TEST VERIFIED (probe P2).
- **Reproduction:** `CatalogSeeder` with a target repository whose `insertTarget` throws `StorageFailure` (for example SQLITE_FULL).
- **Observed:** `thrown=null insertAttempts=164 storedVersion=2 attemptsOnNextLaunch=0`. Every insert failed silently, the seed version was stored, and the next launch skipped seeding. The 164-object catalog stays missing on that install.
- **Expected:** `main.dart:77-80` says "a failure here is safe to retry on the next launch". TASK 1.2 requires idempotent seeding. The cause is in `catalog_seeder.dart:225,230-236`.
- **Severity:** Medium impact, low likelihood (it needs database writes to fail while preference writes succeed).

### RT-03 — A database from a newer app version gives a generic error and a Retry that can never succeed
- **Level:** TEST VERIFIED (probe P5), confirming TD-047 at runtime.
- **Reproduction:** create a v17 database file, set `PRAGMA user_version = 18`, open it with `AppDatabase`, and query three times.
- **Observed:** each attempt throws `UnsupportedSchemaVersionException`. The wording the UI would show is `"Couldn't load your data. Please try again."` (`FailureText.message`). The file is left untouched (`user_version` is still 18; read with raw sqlite3).
- **What the user sees:** Tonight shows "Couldn't load your data." with a Retry that repeats the same failure (`tonight_home_screen.dart:65-75`). Nothing explains that the data comes from a newer version, and no reset path is offered (`resetUnsupportedDatabaseFile` has no caller).
- **Severity:** Low. Only a downgrade (sideloading an older APK) triggers it; no pre-v8 installs exist. The data itself is safe.

### RT-04 — An edit made while Save is in flight can be overwritten by the older plan
- **Level:** TEST VERIFIED (probe P4, with timing injected: `savePlan` was held until the autosave had run).
- **Observed:** after the edit the database held `99 draft`. After Save completed it held `10 planned`, while the planner shows 99, and the current session record says 10.
- **Cause:** `CurrentSession.save` only `await`s the write chain. It does not join it, and it captures the plan before its own awaits (`current_session.dart:85-92`; `session_plan_viewmodel.dart:272-273`).
- **Mitigation already in the code:** the next edit writes the whole plan again.
- **Not verified:** whether a real user can place an edit inside that window on a device. The Save button has no busy state.
- **Severity:** Low.

### RT-05 — Unsaved drafts pile up and are hidden
- **Level:** TEST VERIFIED (probe P4).
- **Observed:** after start, New, New and Duplicate: `rows=4 drafts=4 listed in Sessions=0`. No UI path lists or deletes them, and `mostRecentOpen()` loads them all at startup.
- **Severity:** Low (grows slowly over time).

### RT-06 — A draft created without a site takes the UTC date as its night
- **Level:** TEST VERIFIED (probe P4).
- **Observed:** with the clock at 2026-09-22 01:30 UTC (18:30 on 2026-09-21 in Pacific time) and no site, the draft's `eveningDate` is **2026-09-22**, the UTC calendar date.
- **Expected:** CLAUDE.md trap 2 forbids deriving a night from a `DateTime`'s Y/M/D. The next autosave after a site is set corrects it, and Save and Start require a site.
- **Severity:** Low.

### RT-07 — Open-Meteo requests carry no identifying User-Agent
- **Level:** TEST VERIFIED (probe P5, `MockClient`).
- **Observed:**

  | Host | User-Agent set by the app |
  | --- | --- |
  | `api.open-meteo.com` | none |
  | `nominatim.openstreetmap.org` | `Astro Planner/1.0.0 (+https://chacha12.github.io/astro-planner/; io.github.chacha12.astroplanner)` |

- **Expected:** CLAUDE.md trap 22: "Every request to a third party carries `AppIdentity.userAgent`."
- **Severity:** Low.

### RT-08 — Grid-edge bias, measured
- **Level:** TEST VERIFIED (probe P3). Ljubljana, three nights, the 5-minute grid compared with a 10-second Sun scan.
- **Observed:**

  | Night | Sunset late by | Astro dusk late by | Astro dawn late by | Window end past true dawn | Sun at window end |
  | --- | --- | --- | --- | --- | --- |
  | 2026-09-24 | 50 s | 20 s | 10 s | 10 s | −17.97° |
  | 2026-12-15 | 0 s | 60 s | 190 s | 190 s | −17.46° |
  | 2027-03-10 | 90 s | 110 s | 200 s | 200 s | −17.43° |

- **Meaning:** every reported crossing is late, as documented (CALC-08 tolerance [−2, +7] min). The window's dawn edge extends past the darkness limit, so the fit counts a few minutes of twilight as dark time. The UI shows these times to the minute.
- **Severity:** Low. It is within the documented tolerance; see 03/SCI-04.

### RT-09 — "Moon up" in windows differs from the displayed moonrise and moonset by 5–10 minutes
- **Level:** TEST VERIFIED (probe P3). Ljubljana, 10 nights in October 2026.
- **Observed:** measured from the rise/set events (Meeus h₀) to the first or last sample where the topocentric airless altitude is above 0°:
  - rises: +5 min (once +10 min);
  - sets: −5 to −10 min.
- **Meaning:** a window's "Moon up N min" note and the Moon gate start later, and end earlier, than the moonrise and moonset times shown on the same screen.
- **Severity:** Low. See 03/SCI-03.

### RT-10 — The two Finish paths behave differently
- **Level:** TEST VERIFIED (existing tests).
- **Observed:**
  - The tracker's Finish opens the results page and completes nothing by itself (`execution_screen_test.dart:252`).
  - The resume prompt's Finish completes the session at once (`resume_run_prompt_test.dart:163`, "Finish completes the session"; `resume_run_viewmodel.dart:110-112`).
- **Expected:** ADR-016 §11 ("Finish opens reconciliation") names only the tracker, so this may be intended.
- **Severity:** Low. It needs an owner answer (also raised in 01).

---

## 3. Untested or unverifiable critical paths

**Android and human checks (all UNVERIFIED):**
- An install and launch on any Android device or emulator, debug or release. The R8 release build has never run.
- Runtime permission dialogs; the settings deep links; GPS on a device.
- Real process death, "Don't keep activities", reboot, rotation on a device (L1–L8 device rows).
- Keep-screen-on with the real wakelock; the Android back button on hardware.
- The share sheet, `file_picker`, restore after uninstall and reinstall, Android Auto Backup.
- Red field mode in real darkness; TalkBack; a low-end-device profile trace.
- How long a backgrounded process survives, which decides how often RT-01 shows up in the field.

**Real third-party services (UNVERIFIED, fakes only):** live Open-Meteo, Nominatim, OSM tiles, and the lightpollutionmap.info link.

**Paths with no automated coverage here:**
- Failure of the catalog seeder (RT-02; no repository test).
- Clock-driven or resume-driven weather refresh (RT-01; no test).
- Save and Start concurrent with an edit (RT-04).
- A restore on the same device with the preferences left in place (02/ENG-14).
- The hidden metadata import (gated; out of scope, G17).

---

## 4. Runtime limitations of this audit

- **No device or emulator.** There is no AVD or system image, the cmdline-tools are missing, and no device is attached. DEVICE VERIFIED and HUMAN VERIFIED are empty for every flow. Setting up an emulator needs a system-image download and SDK cmdline-tools, which is the owner's call.
- **Windows desktop is not a target platform.** R3 shows the Dart and Flutter code, the real SQLite file and the widget tree working as a native app. It says nothing about Android plugins or lifecycle.
- **`flutter test integration_test -d windows` fails inside flutter_tools** (documented in TEST_PLAN § 15.5). R3 used `flutter run -d windows`, which printed "integration_test plugin was not detected" but reported the results.
- **Probe timing is from the host (a desktop SSD):**
  - First-run seed: 885 ms.
  - Sessions list with 200 completed sessions: 198 ms (reconciliations 183 ms).
  - Neither says anything about low-end Android.
- **RT-04 depends on injected timing.** The mechanism is real; how often a user can hit it is not shown.
- **R5 gate re-run on the clean tree** (2026-09-25, after the probes were removed): `dart run tool/check.dart` passed every step (Encoding, Format, Analyze, Test with 896 passed, E2E on the host with 2 passed); "Quality gate passed", exit 0. The repository is unchanged apart from `docs/audit/`.

## 5. Summary

| Category | Items |
| --- | --- |
| Actual failures (reproduced) | RT-01 (forecast freshness and rollover), RT-02 (failed catalog seed never retried), RT-03 (newer-schema database: generic error, endless retry) |
| Inconsistent behaviour | RT-04 (Save and edit interleave), RT-06 (UTC night key for a draft without a site), RT-08 (grid edges), RT-09 ("Moon up" definitions), RT-10 (two Finish paths) |
| Missing states | No explanation or reset for a downgraded database (RT-03); no busy state on Save and Start (RT-04); no way to see or delete unsaved drafts (RT-05) |
| Misleading behaviour | "Updated just now" on an old forecast (RT-01); times shown to the minute on a 5-minute grid (RT-08) |
| Compliance defect found at runtime | RT-07 (Open-Meteo request without the identifying user agent) |
| Verified working (host, and Windows where listed) | Startup order, sites, targets, equipment, astronomy against references, the opportunity, capture planning, Save/Start/track/restart/complete, the logbook, export and the host backup round trip, offline first run, permission-state handling with fakes, full-disk handling. Nothing in the core loop failed in any run |
| Unverifiable here | Every Android, device, human and live-service behaviour (§3) |
