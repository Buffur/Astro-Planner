# Stage 11 — Phone and owner runbook (S11.5)

> Every row of [`STAGE_11_MATRIX.md`](STAGE_11_MATRIX.md) that needs the owner's phone, a person or an
> owner action, with the steps, the build and what to record. Written 2026-09-30. The agent runs the
> "agent" rows over USB when the owner connects the phone (S11.6); the owner runs the "owner" and
> "person" rows. Results go into `TEST_PLAN.md` (device runs) and the matrix. Readiness is claimed only
> when every **mandatory** row (marked ★) is VERIFIED (S11.7).

## 1. How phone runs are done (D11-3)

- **Never touch the owner's installed app or its data.** Build a separate debug package: locally, in
  `android/app/build.gradle.kts`, add `applicationIdSuffix = ".s2check"` to the debug build type
  (never committed; reverted after the run). The test app then installs beside the owner's app.
- Connect the phone over USB with USB debugging on; `adb devices` must list it.
- **Install and run:** `flutter run --debug -d <id>` for walkthroughs, `flutter drive --profile
  --no-dds -d <id> --driver=test_driver/perf_driver.dart --target=integration_test/<file>` for the
  suites (on the development machine add `--android-project-arg=kotlin.incremental=false`).
- **Afterwards:** `adb uninstall io.github.chacha12.astroplanner.s2check`; revert the local build change;
  delete anything copied to the phone. No owner file is ever uploaded, copied into the repository, or
  quoted.
- **Record** in `TEST_PLAN.md` → "Device runs": date, phone (model, Android version), build (commit,
  mode, package), each row's result.

## 2. Agent rows (the phone connected; S11.6)

| Row | What to run | Pass when | Record |
| --- | --- | --- | --- |
| ★ L10 | The core loop by hand on `.s2check`: first run → a site (typed) → Tonight → the planner (M31, the seeded rig, the example plan) → Save plan → the Logbook → after the saved night (the phone's clock is not changed: use a plan for last night, which Save allows) → Record result → the entry → Export as file | Each step works; the result is listed; the export share sheet opens with a `.json` in local time | Screens and results |
| M3 | `integration_test/perf_scenarios_test.dart` in profile mode (S10.2's command) | The run passes; frame summaries recorded against 16.7 ms as a reference | `build/integration_response_data.json` summarised into `evidence/STAGE_10_MEASUREMENTS.md` (a phone section) |
| M4 | The same run's `candidates.ms` | Under 1 s (TASK 10.4) | The number |
| E6 | Library → Rigs → "Add from a photo" with a DNG and with a JPEG or HEIC the owner picks on the phone; through the rig form; Save; open again ("You already have this rig"); `adb shell run-as io.github.chacha12.astroplanner.s2check du -a cache` | Values as M4 recorded (S3.7); no cache copy | Values not quoted; only pass/fail per field group |
| E5 | M1–M3 (`TEST_PLAN.md`) re-run only if E6 shows a regression | As `TEST_PLAN.md` M1–M3 | — |
| E7 | S2V-06: pick a file through a cloud provider already signed in on the phone (a file the owner chooses, nothing uploaded by the agent); restore a real backup file, cancel at the preview; `run-as … ls cache/file_picker` | Empty or absent after each | Pass/fail |
| L1–L6, L8 | Only if the owner asks for device evidence beyond the emulator's (S11.3 passed them on the emulator) | As `TEST_PLAN.md` | — |

## 3. Person rows (the owner or a participant; HUMAN VERIFIED)

| Row | What to do | What to record |
| --- | --- | --- |
| ★ H6 | TalkBack on, the largest font size, on `.s2check` (or the signed release): the core flow of the matrix row (first run → site → Tonight → the planner's answer → a section → target and rig → a block added, edited, deleted and undone → the timeline's description → Save plan → Tonight's line after the night → the result form → the Logbook entry); then the core part again in field mode | Anything unlabelled, read out of order, or cut off, with the screen |
| H7 | TalkBack on the Logbook's search and filters, a delete confirmation, the Library's management, the Settings controls | The same |
| I2 | `TEST_PLAN.md` 12.4's darkness checklist in a dark room, field mode on | Any non-red or bright pixel, any white flash |
| I3 | Field mode read in real darkness: verdicts, warnings, secondary text, timeline bands, selected states, outlined controls, card borders, the result form | What cannot be read; colour as the only carrier; ARCHITECTURE B16's accepted exceptions noted, not "fixed" |
| A10 | TASK 12.5's walkthrough on a fresh install (the first-run page; GPS after the rationale; a typed site; a second fresh install skipped; Tonight at large text) | Pass/fail per step |
| A9 | The comprehension scenarios (plan tonight's target; adjust a plan that does not fit; save; report the result later; review history; manage a rig or a site) | Whether the retained features are useful, entry is reduced where evidence allows, and the information is clear and compact |
| A8 | Optional: Stage 6's five-second test with someone who has not worked on the app | Their words, verbatim |
| ★ Q3 | Dogfooding on real nights (the missing M3 record) | A go/no-go on the product's bet, with the nights used |

## 4. Owner actions (OWNER)

Each unblocks what is named; none is the agent's to do (trap 21, RD-01).

| Row | Action | Unblocks |
| --- | --- | --- |
| ★ N7 | Decide RD-01 (`chacha12` or `Buffur`; `research/S9.12_PROJECT_IDENTITY.md`) so TD-088's links resolve | Every upload; O9, O11 |
| ★ N8 | A trademark search for "Astro Planner" | The first upload |
| ★ N9 | A Play Console developer account and the app's entry (Play App Signing at its default) | Any Play track |
| ★ N4 | Create the upload key and `android/key.properties` (`docs/RELEASE.md`), build the signed bundle, and run `dart run tool/check_bundle.dart` until "Bundle check passed" | N5; upload |
| ★ N5 | Install the signed release on the phone (an internal testing track, or `flutter install` of the signed build) and run the core loop once | Readiness |
| N6 | Install the Android SDK command-line tools (`flutter doctor` clean) | Tidier builds (not required) |
| ★ O9 | Publish `docs/privacy/index.md` at the policy URL with the contact email, and check that it opens | Data Safety; the store listing |
| ★ O10 | Fill in Play's Data Safety form from `COMPLIANCE.md` | Upload |
| ★ O11 | Keep the source repository public (the GPL-3.0 source offer About links) | Upload (licence obligation) |
| M6 | After the first upload, note Play's reported download and install size | The size record |
| P2 | RD-17: push the CI workflow and watch a first run (deferred by the owner's instruction to commit only) | CI evidence |
| ★ Q5 | The beta go/no-go, recorded in `STAGE_11_VALIDATION.md` | The Stage's exit |
| L7 | When a beta exists: install it, create data, install the next build over it (`adb install -r`) | Upgrade evidence |
| M5 | A low-end phone's profile run, if one becomes available | Low-end evidence (UNVERIFIED until then) |

## 5. Deferred owner gates (not required by the matrix)

S9.10 (the logo), S9.11 (RG-12, the licence), S9.12 (RD-01, also N7 above). Readiness does not wait for
the logo or the licence; it waits for RD-01.
