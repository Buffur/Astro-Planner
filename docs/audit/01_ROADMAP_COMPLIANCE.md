# 01 — Roadmap compliance audit (G0 → TASK 16.3)

> **Audit stage 1.** Captured 2026-09-24 against `main` @ `becae04`, with a clean working tree.
> This is an audit only: no application code or source-of-truth document was changed.
> This file is the only one created.
>
> **Input note.** `docs/audit/00_CONTEXT_BASELINE.md`, named in the brief, **does not exist in
> the repository** (checked with `ls docs/audit`). The Stage 0 baseline produced in this session
> was used instead. It covers the same scope and is not committed.
>
> **Scope.** Every roadmap task from TASK 0.1 through TASK 16.3, checked against
> `docs/MASTER_ROADMAP.md` §4, plus the milestone definitions (§6), the architecture checkpoints
> (§7), the testing checkpoints (§8) and the release checklist (§9) where they apply to G16.

## 0. Method

**Runtime evidence gathered for this audit** (host only: Windows 11, Flutter 3.47.4, Dart 3.13.3):

| Run | Command | Result |
| --- | --- | --- |
| R1 | `dart run tool/check.dart` | Exit 0. Encoding pass, format pass (307 files, 0 changed), analyze "No issues found!", **896 tests passed**, E2E (host, `flutter-tester`) **2 passed** |
| R2 | `flutter test --no-pub`, then `flutter test --no-pub integration_test -d flutter-tester` | Exit 0 both. **896 passed, 0 failed, no skips**; E2E 2 passed |

**Limits of this evidence:**

- The whole suite passed in both runs. Every test cited below is therefore "passed in R1 and R2". Per-test results were not captured separately: the JSON file reporter produced no file.
- **No Android device or emulator is attached** (`flutter devices`: Windows and web only).
- Tests replace the forecast, GPS, the device time zone, the share sheet and the wakelock with fakes (TEST_PLAN § End-to-end). Real network and plugin paths were not exercised.
- The citation "test passed" always means the host.

**Status definitions used:**

| Status | Meaning in this report |
| --- | --- |
| CONFIRMED | The acceptance criterion is demonstrated by code and a passing test (or, for ADR tasks, by an accepted, owner-attributed decision record). The criterion does not require a device. |
| PARTIAL | Part of the required scope is missing, or a clause of the acceptance is not met. |
| NOT IMPLEMENTED | No implementation of the required scope exists. |
| BROKEN | Implemented, but evidence shows it does not work. |
| UNVERIFIED | The implementation exists, but the acceptance explicitly needs device, emulator, CI or human evidence that does not exist. |
| DEFERRED | Explicitly cut or deferred by the owner or the roadmap. Not counted as missing. |
| OWNER DECISION | Completion waits on an owner action or decision. |

A task can carry one primary status plus qualifiers. Confidence is High, Medium or Low, and
reflects the strength of the evidence, not the importance of the finding.

---

## G0 — Governance

### TASK 0.1 — Commit the reconciled documentation
1. **Requirement:** a single documentation checkpoint commit.
2. **Acceptance:** documents clean in `git status`; the commit exists.
3. **Evidence:** commit `34a7157` "docs: finalize project handoff" (2026-09-21; 15 files, +4137). `git status` clean today. OD-02 recorded (DECISIONS Part C).
4. **Actual:** the commit exists, and the source-of-truth documents are tracked.
5. **Status:** **CONFIRMED** · Confidence **High**
6. **Verification needed:** none.

### TASK 0.2 — Adopt the roadmap; resolve PD-06
1. **Requirement:** ROADMAP.md holds the plan, a phase→group map and an "active task" line; PD-06 recorded; placeholders PD-17 to PD-21 registered.
2. **Acceptance:** owner-approved; PD-06 and TD-041 marked resolved with a date.
3. **Evidence:**
   - commit `af076d9`
   - `docs/ROADMAP.md:174` "Adopted plan", `:187` "Active task line", `:476` "Phase → group map"
   - `docs/DECISIONS.md:374` (PD-06 RESOLVED 2026-09-21, owner quote recorded)
   - PD-17 to PD-21 rows at `DECISIONS.md:366-370`
   - `TECH_DEBT.md:159` (TD-041 RESOLVED 2026-09-21)
4. **Actual:** as required.
5. **Status:** **CONFIRMED** · Confidence **High**
6. **Verification needed:** none.

### TASK 0.3 — Repository hygiene
1. **Requirement:**
   - remove the patch scripts, the empty `package-lock.json`, the empty `bin/` and the `GEMINI.md` ignore rule;
   - remove unused `cupertino_icons`;
   - decide on the ADK skill;
   - check whether `sqlite3_flutter_libs` can go, then do a device smoke run.
2. **Acceptance:** "the root holds only project files."
3. **Evidence:**
   - commits `ef20670` (scripts and lockfile), `c8ad208` (`cupertino_icons`), `714426d` (GEMINI rule)
   - `bin/` and `package-lock.json` absent (checked with `ls`)
   - `pubspec.yaml` still lists `sqlite3_flutter_libs: ^0.6.0+eol`
   - `.agents/skills/google-agents-cli-adk-code` and a root-level `skills-lock.json` are still present
   - `TECH_DEBT.md:239-244`: "Not touched (need owner approval): the Google ADK skill and its `skills-lock.json` entry; `docs/archive/` retention; `sqlite3_flutter_libs`"
4. **Actual:** the approved items are removed. Three items are held for owner approval, and no device smoke run was performed.
5. **Status:** **PARTIAL** + **OWNER DECISION** · Confidence **High**
6. **Verification needed:** an owner decision on the ADK skill, `skills-lock.json`, archive retention and `sqlite3_flutter_libs`; a device smoke run.

## G1 — Testability and deterministic startup

### TASK 1.1 — Repair the test harness; add platform seams
1. **Requirement:**
   - a `LocationService` interface, injected, with the Geolocator implementation outside presentation;
   - an awaitable `ready`;
   - no sleeps;
   - fix the RA fixture.
2. **Acceptance:** green three runs in a row; no `Future.delayed` waits in tests.
3. **Evidence:**
   - `lib/domain/services/location_service.dart:27-48` (sealed `LocationResult`, `abstract class LocationService`)
   - `lib/data/services/geolocator_location_service.dart:6`
   - `StartupViewModel.ready` (`lib/presentation/viewmodels/startup_viewmodel.dart:21,31`)
   - `grep "Future.delayed" test integration_test` returns no matches
   - `test/integration_flow_test.dart:74` `rightAscension: 83.85, // degrees (5.59 h x 15)`
   - permission tests in `test/presentation/viewmodels/planner_location_test.dart:153` ("$failure is reported and changes nothing")
   - R1 and R2 green
4. **Actual:** implemented. Since TASK 12.3, `ready` lives on `StartupViewModel`.
5. **Status:** **CONFIRMED** · Confidence **High**. Two consecutive green runs today, not three.
6. **Verification needed:** none material.

### TASK 1.2 — Deterministic bootstrap and empty states
1. **Requirement:** ordered bootstrap (database → idempotent seeding → ViewModel init); weather after the first frame; an error state with retry; empty-state actions; a default-location banner.
2. **Acceptance:** a fresh install shows seeded data without a restart; a repository failure shows the error UI.
3. **Evidence:**
   - `lib/main.dart:74-85` awaits `CatalogSeeder`/`EquipmentSeeder.seedIfNeeded()` before `runApp` (`:129`)
   - `StartupViewModel._load` (`startup_viewmodel.dart:39-53`, error, then `retryBootstrap`)
   - weather is post-frame: `night_conditions_viewmodel.dart:71-72` (`addPostFrameCallback` → `_loadWeather`)
   - tests: `planner_bootstrap_test.dart:46` ("seeding completes before the ViewModel reads…"); `home_screen_test.dart:108` (empty-state actions), `:135` (default-location banner), `:288` (bootstrap failure shows error with retry)
4. **Actual:** implemented. Since TASK 7.3 the "default location" path is replaced by a site prompt (owner decision, F-06).
5. **Status:** **CONFIRMED** (host) · Confidence **High**
6. **Verification needed:** a fresh install on a device (TEST_PLAN L1, not run).

### TASK 1.3 — Quality gate and CI
1. **Requirement:** a script running format, analyze and test; a one-time whole-tree format; a minimal GitHub Actions workflow.
2. **Acceptance:** "CI goes red on any failure; the script is documented."
3. **Evidence:**
   - `tool/check.dart:23-74` runs all steps and calls `exit(1)` on any failure (R1 exit 0)
   - commit `94acd71` (whole-tree format)
   - `.github/workflows/ci.yml` runs `dart run tool/check.dart`
   - documented in `CLAUDE.md` ("Commands")
   - `git ls-remote origin` → `a1bcbd9`; `git merge-base --is-ancestor 97924a0 a1bcbd9` → **not an ancestor**: the workflow is not on the remote
   - `ROADMAP.md:193-195` ("CI has never actually run")
4. **Actual:** the script works and is documented. The CI workflow has never executed on GitHub Actions.
5. **Status:** **UNVERIFIED** for the CI clause; the script is CONFIRMED · Confidence **High**
6. **Verification needed:** push the workflow and observe a red run caused by a deliberate failure.

## G2 — Time foundation: SessionNight

### TASK 2.1 — ADR: SessionNight and time-zone strategy
1. **Requirement:** the window, identity, default rule, storage, display zone, polar states, and when the `timezone` package arrives.
2. **Acceptance:** owner-approved, with at least 10 cases and their expected windows.
3. **Evidence:**
   - ADR-007 (`DECISIONS.md:693`, §12 test matrix at `:977`)
   - PD-01 and PD-02 resolved (`DECISIONS.md:410,433`)
   - test cases T1–T17 in `test/domain/services/session_night_resolver_test.dart:80-255`
4. **Actual:** accepted; more than 10 cases.
5. **Status:** **CONFIRMED** · Confidence **High**
6. **Verification needed:** none.

### TASK 2.2 — SessionNight type, resolver and Clock
1. **Requirement:** `Clock` (system and fixed); `SessionNight` with invariants; `resolveDefault` and `forEveningDate`; documentation.
2. **Acceptance:** all cases pass (the San Francisco case fails on the old code); no `DateTime.now()` in `lib/domain`.
3. **Evidence:**
   - `lib/core/time/clock.dart:6,14,22`
   - `lib/domain/models/session_night.dart:17`
   - `lib/domain/services/session_night_resolver.dart:38,97,134`
   - `test/core/time/clock_test.dart:19` "no DateTime.now() in lib/domain" (passed)
   - resolver test `:193` (records that T1, T2, T11 and T12 fail on the old code); P2 monotonic over 48 h (`:373`)
   - `grep DateTime.now() lib/domain` finds no match
4. **Actual:** implemented.
5. **Status:** **CONFIRMED** · Confidence **High**
6. **Verification needed:** none.

### TASK 2.3 — Calculators consume SessionNight
1. **Requirement:** SessionNight-based APIs; a typed timeline; a domain `AltitudeCurve`; a render-only chart; the darkness limit as a parameter; the 5-minute step documented.
2. **Acceptance:** no astronomy imports in widgets; European results unchanged within the quantization.
3. **Evidence:**
   - `VisibilityCalculator.calculateNightTimelineForNight` / `calculateVisibilityWindowsForNight` / `calculateAltitudeCurve`; `lib/domain/models/night_timeline.dart`, `altitude_curve.dart`
   - `grep` for astronomy-service imports in `lib/presentation` matches only ViewModels (`capture_analysis`, `execution`, `night_conditions`), no widget
   - `visibility_calculator_session_night_test.dart` (9 tests, exact agreement with the legacy wrappers)
   - `altitude_chart_widget_test.dart` (3)
4. **Actual:** implemented. A deprecated wrapper is still present (`visibility_calculator.dart:132`), as the direction allowed.
5. **Status:** **CONFIRMED** · Confidence **High**
6. **Verification needed:** none.

### TASK 2.4 — Planner and UI adopt SessionNight
1. **Requirement:** the ViewModel holds a SessionNight (resolver plus Clock); the picker selects the evening date; one formatter with the zone and the 12/24-hour setting; a "no site set" state; the defect test replaced; loaded sessions mapped to their night.
2. **Acceptance:** "an emulator set to America/Los_Angeles at 18:30 shows tonight."
3. **Evidence:**
   - `SessionNightResolver.resolve` used by `SessionPlanViewModel`
   - `lib/presentation/shared/night_time_formatter.dart:11-12,57` (`TimeOfDay.format`, 24-hour setting)
   - `night_time_formatter_zone_test.dart:55` (`alwaysUse24HourFormat`)
   - `home_screen_test.dart:331` (correct evening date, not the UTC one), `:407` (no site → "No site set")
   - `planner_session_date_test.dart` (13 tests)
   - legacy mapping at `logbook_screen.dart:146` and `session_plan_viewmodel.dart:246` goes through `CalendarDate.fromDateTimeFields(...toLocal())`, as documented in ARCHITECTURE B11
   - `DateTime.now()` remains in presentation only for date-picker bounds (`home_screen.dart:64,183`, `logbook_screen.dart:385`)
4. **Actual:** implemented and tested on the host with a fixed clock.
5. **Status:** **UNVERIFIED**: the acceptance names an emulator run, which has not happened. Host equivalent CONFIRMED · Confidence **High**
6. **Verification needed:** an emulator or device in America/Los_Angeles at 18:30.

## G3 — Persistence baseline

### TASK 3.1 — ADR: persistence baseline and provenance
1. **Requirement:** the floor, the workflow, the foreign-key policy, the orphan table, and provenance.
2. **Acceptance:** owner-approved.
3. **Evidence:** ADR-008 (`DECISIONS.md:1079`), "accepted (owner, 2026-09-22)"; PD-04 and PD-09 resolved (`:450,:477`).
4. **Actual:** accepted.
5. **Status:** **CONFIRMED** · Confidence **High**
6. **Verification needed:** none.

### TASK 3.2 — Schema snapshots and migration tests
1. **Requirement:**
   - (a) v8 and v9 snapshots;
   - (b) generated verification;
   - (c) a v8→v9 data-preservation test;
   - (d) floor handling per 3.1, which ADR-008 §2 and §9 define as "a clear message and a reset path" with its UI message;
   - (e) the workflow documented in DATA_MODEL.
2. **Acceptance:** "a v8 database with sample rows upgrades intact."
3. **Evidence:**
   - `drift_schemas/drift_schema_v8.json` to `v17.json`; `lib/data/database/generated_migrations/schema_v8..v17.dart`; `build.yaml`
   - `app_database.dart:22` (`kMinSupportedSchemaVersion = 8`), `:263-279` (floor and downgrade guards)
   - `schema_migration_test.dart:734` "M2: v8 -> v10 data preservation", `:933` floor and downgrade guards, `:996` M6 reset path, `:1027` M11 atomicity (all passed)
   - `resetUnsupportedDatabaseFile` has **no caller** in `lib` (grep); no UI handles `UnsupportedSchemaVersionException` (grep)
   - ADR-008 status block, `DECISIONS.md:1092-1094`: "no caller exists yet — the confirmation UI §2 requires is not built"
4. **Actual:** the acceptance is met. The "clear message and reset path" UI from scope (d) is not built. This is also TD-047's remaining half.
5. **Status:** **PARTIAL** · Confidence **High**
6. **Verification needed:** what the app shows on device when the database is below the floor or newer than the app (runtime behaviour unknown).

### TASK 3.3 — Enforce foreign keys; retire the orphan table
1. **Requirement:** integrity check, orphan cleanup, foreign keys on; cascade for blocks; guarded shared deletes; drop `equipment_profiles`.
2. **Acceptance:** tests confirm foreign keys are on.
3. **Evidence:**
   - `app_database.dart:502` `beforeOpen` sets `PRAGMA foreign_keys = ON`
   - `_deleteOrphanForeignKeyRows` (`:512`)
   - v10 step rebuilds and drops the table (`from9To10`)
   - schema v17: no `equipment_profiles`; `camera_modules`/`optical_rigs` RESTRICT, `capture_blocks` CASCADE (`equipment_foundation_tables.dart:17,41`; `app_database.dart:64`)
   - tests `schema_migration_test.dart:1057-1121` (M9: "PRAGMA foreign_keys is on", orphan insert throws, session delete cascades); `:865` M8 orphan cleanup
4. **Actual:** implemented.
5. **Status:** **CONFIRMED** · Confidence **High**
6. **Verification needed:** none.

## G4 — Correctness and honesty fixes

### TASK 4.1 — Capture-block editing defects
1. **Requirement:** fix the reorder; stable keys; validators; an edit dialog.
2. **Acceptance:** every reorder case produces the expected order.
3. **Evidence:**
   - `planner_capture_blocks_test.dart:87-139`: up, down, to first, to last, edit, out of range
   - `capture_plan_widget_test.dart:84` (empty input rejected), `:101` (zero or negative rejected), `:121` (valid input adds)
4. **Actual:** implemented.
5. **Status:** **CONFIRMED** · Confidence **High**
6. **Verification needed:** none.

### TASK 4.2 — Save, selection and logbook consistency
1. **Requirement:** a second Save updates rather than duplicates; the selection is refreshed or cleared after an edit or delete; newest-first ordering; delete confirmation.
2. **Acceptance:** the listed tests pass.
3. **Evidence:**
   - `planner_session_save_test.dart:80` "save creates a planned session…; saving again updates the same one"
   - `planner_selection_refresh_test.dart:96,146` (the deleted target or equipment is cleared), `:204` (not resurrected after a restart)
   - `logbook_screen_test.dart:83,96,109` (delete confirmation)
   - `drift_session_repository_test.dart:106` (newest-updated first)
4. **Actual:** implemented. Persistence moved to `SessionRepository` in TASK 11.3, and the tests moved with it.
5. **Status:** **CONFIRMED** · Confidence **High**
6. **Verification needed:** none.

### TASK 4.3 — Encoding fixes and gate enforcement
1. **Requirement:** fix the mojibake and add a UTF-8 check; gate every entry point from one source.
2. **Acceptance:** grep finds no mojibake; the gates match DECISIONS.
3. **Evidence:**
   - `tool/check_encoding.dart` (R1: "Encoding check passed")
   - `lib/core/config/feature_scope.dart`: `fieldMode` true, `lightPollutionContext` true, `metadataImport` false, `logbook` true. This matches PD-06 E.1 (`DECISIONS.md:382-386`) together with the lifts in TASKs 7.4 and 12.4.
   - `feature_scope_test.dart:18-32`; `app_router_test.dart:17` (the metadata route is absent); `home_screen_test.dart:461` (a gated feature has no entry point)
   - `equipment_selection_screen.dart:69` shows "µm"
4. **Actual:** implemented.
5. **Status:** **CONFIRMED** · Confidence **High**
6. **Verification needed:** none.

### TASK 4.4 — Honest numbers and labels
1. **Requirement:**
   - the stacking-gain label renamed;
   - illumination as a whole percentage;
   - "unknown" instead of empty values;
   - the (0,0) sentinel removed;
   - an "Example plan" label;
   - neutral warning text;
   - the seed changed to f/5.6;
   - comments fixed.
2. **Acceptance:** "'SNR' is absent from `lib/`."
3. **Evidence:**
   - `capture_plan_widget_test.dart:178` ("stacking gain is labeled as relative, not SNR"), `:189` (unknown storage renders as Unknown)
   - `OpticalCalculator.estimateStorageRequirement` returns `double?` (`optical_calculator.dart:52`)
   - `SessionPlanViewModel.isExampleCapturePlan` (`:75`)
   - seed `equipment_seeder.dart:35-46` (400 mm, `focalRatio: 400/72`)
   - "wash out" absent (grep)
   - illumination rounded to a whole percentage (`opportunity_text.dart:72`, `tonight_home_screen.dart:247`)
   - `grep "SNR" lib` returns **4 matches, all doc comments that negate it**: `capture_block.dart:33`, `capture_budget_calculator.dart:89`, `optical_calculator.dart:40`, `capture_analysis_viewmodel.dart:208`. The `optical_calculator.dart:40` comment was already present in the TASK 4.4 commit itself (`git grep SNR 514dcc5`).
   - DECISIONS DEV-P2 (`:222-224`) states "the string 'SNR' no longer appears anywhere in `lib/`". That statement is not accurate.
4. **Actual:** every user-facing requirement is met. The acceptance as literally written is not met: "SNR" still appears, but only in explanatory comments.
5. **Status:** **PARTIAL** (literal acceptance) · Confidence **High**. No user-visible "SNR" string was found.
6. **Verification needed:** an owner or maintainer ruling on whether the criterion means user-facing strings. The DEV-P2 statement is inaccurate either way.

## G5 — Capture budget

### TASK 5.1 — ADR: capture-budget semantics
1. **Requirement:** definitions of integration, acquisition and budget; the available-time contract; calibration policy; margin; at least 5 worked examples.
2. **Acceptance:** owner-approved.
3. **Evidence:** ADR-009 (`DECISIONS.md:1316`; §8 vectors E1–E7 at `:1463`); PD-08 resolved (`:488`).
4. **Actual:** accepted, with 7 vectors.
5. **Status:** **CONFIRMED** · Confidence **High**
6. **Verification needed:** none.

### TASK 5.2 — Planning preferences and Settings
1. **Requirement:** a `PlanningPreferences` value type and repository (minimum altitude, darkness limit, margin, overheads, dew margin); a Settings screen.
2. **Acceptance:** no SharedPreferences imports in ViewModels; changing a threshold updates the windows.
3. **Evidence:**
   - `lib/domain/models/planning_preferences.dart:29,145-192`
   - `planner_preferences_test.dart:151` ("no ViewModel imports SharedPreferences"), `:68,:104` (the darkness limit and minimum altitude change the windows)
   - `viewmodel_rules_test.dart:21`
   - `settings_screen_test.dart:85` ("moving a slider persists its value")
   - `planning_preferences_test.dart:28` (clamping)
4. **Actual:** implemented.
5. **Status:** **CONFIRMED** · Confidence **High**
6. **Verification needed:** none.

### TASK 5.3 — CaptureBlock model and schema
1. **Requirement:** domain validation; `position`; `calibrationPolicy`; typed gain; migration and snapshot; versioned plan JSON.
2. **Acceptance:** invalid values are rejected at the domain boundary.
3. **Evidence:**
   - `lib/domain/models/capture_block.dart:99`
   - `capture_block_test.dart:20-52` (rejects exposure, count and binning out of range), `:115,:141` (typed gain and policy round trip)
   - migration `from10To11` (`app_database.dart`); `schema_migration_test.dart:661` (v11 group)
   - v17 `capture_blocks` columns include `position`, `calibration_policy`, `gain_kind` and `gain_value`
4. **Actual:** implemented.
5. **Status:** **CONFIRMED** · Confidence **High**
6. **Verification needed:** none.

### TASK 5.4 — CaptureBudgetCalculator
1. **Requirement:** overhead parameters as labelled assumptions; a per-block and total breakdown; storage or unknown; delete the dead code.
2. **Acceptance:** no budget arithmetic left in ViewModels.
3. **Evidence:**
   - `lib/domain/services/capture_budget_calculator.dart:212` (`calculate` at `:221`)
   - `capture_budget_calculator_test.dart:35-170` (ADR vectors E1–E7), `:214` (unknown storage is null)
   - `grep estimateTotalDuration|SessionCalculator lib` returns no match
   - `capture_analysis_viewmodel.dart` contains no exposure × count arithmetic; the only arithmetic-like line (`:200`) is a `copyWith(frameCount:)`
4. **Actual:** implemented.
5. **Status:** **CONFIRMED** · Confidence **High**
6. **Verification needed:** none.

### TASK 5.5 — Fit analysis
1. **Requirement:** atomic placement into the windows, with gaps; fits, tight or does not fit, with a reason, end time, unused time and unplaced frames; the inverse question; a similar-nights hint.
2. **Acceptance:** the vectors pass.
3. **Evidence:** `lib/domain/services/fit_analyzer.dart:83` (`analyze` `:93`, `maxPlaceableFrames` `:237`, `noWindowReason` `:341`); `fit_analyzer_test.dart:63-298` (E1–E7, margin configuration, inverse).
4. **Actual:** implemented.
5. **Status:** **CONFIRMED** · Confidence **High**
6. **Verification needed:** none.

### TASK 5.6 — Capture planner UI
1. **Requirement:** block editor (policy, typed gain); breakdown outputs; fit with reason and end time; √N per group with help text; storage or unknown; "fill the window"; an assumptions panel.
2. **Acceptance:** a user can see why a plan doesn't fit and fix it with one action.
3. **Evidence:**
   - `lib/presentation/widgets/capture_plan/` (dialog, budget summary, assumptions panel)
   - `capture_plan_fill_test.dart:87` ("a plan that does not fit shows why, and one tap fixes it")
   - `capture_plan_widget_test.dart:200` (policy and typed gain), `:243` (breakdown, "Not included", help text)
4. **Actual:** implemented.
5. **Status:** **CONFIRMED** · Confidence **High**
6. **Verification needed:** none.

## G6 — Astronomical conditions

### TASK 6.1 — ADR: ephemeris approach and moving objects
1. **Requirement:** choose the Moon approach; hide moving objects; set tolerances.
2. **Acceptance:** owner-approved.
3. **Evidence:** ADR-010 (`DECISIONS.md:1560`; §4 tolerances at `:1668`); PD-07 and PD-16 resolved (`:510`).
4. **Actual:** accepted.
5. **Status:** **CONFIRMED** · Confidence **High**
6. **Verification needed:** none.

### TASK 6.2 — Independent reference fixtures; document simplifications
1. **Requirement:** fixtures citing their source, query and retrieval date; tolerance tests; documentation for each CALC entry; the precession and refraction decision.
2. **Acceptance:** "CALC-01 to CALC-11 each have a sourced test."
3. **Evidence:**
   - `test/fixtures/astronomy/*.json`: each has `source` and `retrieved` fields (for example `horizons_sun.json`: JPL Horizons, retrieved 2026-09-22T20:18Z; `usno_celnav_stars.json`: SIMBAD plus USNO celnav)
   - `astronomy_reference_test.dart:54-234`: Sun vs Horizons within 0.02°, events vs USNO, 67 star altitudes within 0.05° with precession (exercises CALC-04 to CALC-08 end to end)
   - `precessJ2000ToDate` (`astronomical_engine.dart:81`)
   - **however,** `astronomical_engine_test.dart:7-38` tests CALC-01, CALC-02 and CALC-06 with hand-written values and no citation; CALC-03 (`normalizeDegrees`) is tested only indirectly (SCIENTIFIC_INTEGRITY Part B lists it as "indirect")
   - CALC-09 is deleted; CALC-10 and CALC-11 are now wrappers or replaced by CALC-22 and CALC-23, which the Sun reference tests cover
4. **Actual:** the sourced reference fixtures exist and pass. Not every CALC-01–11 entry has its own sourced test.
5. **Status:** **PARTIAL** · Confidence **Medium**. Whether an end-to-end reference test counts as "sourced" for each of CALC-04–06 is a matter of interpretation.
6. **Verification needed:** a maintainer ruling on whether indirect coverage satisfies the criterion for CALC-01 to CALC-06.

### TASK 6.3 — Moon ephemeris
1. **Requirement:** topocentric position and altitude, illumination, and rise/set on the night grid.
2. **Acceptance:** within the ADR tolerances; the measured error recorded in SI-002.
3. **Evidence:**
   - `lib/domain/services/moon_calculator.dart:84` and `moon_series.dart`
   - `moon_calculator_test.dart:45` ("at least 20 instants spanning two years"), `:52-93` (RA/Dec, ecliptic coordinates, distance, illumination), `:125` (USNO phases within 10 minutes), `:159` (rise/set vs USNO)
   - SCIENTIFIC_INTEGRITY CALC-28 row lists the measured errors
4. **Actual:** implemented.
5. **Status:** **CONFIRMED** · Confidence **High**
6. **Verification needed:** none.

### TASK 6.4 — MoonConditions; retire the mean-phase model
1. **Requirement:** a `MoonConditions` value; UI shows the Moon up-time and separation; delete the old model and record it in DECISIONS.
2. **Acceptance:** the old model is removed.
3. **Evidence:**
   - `lib/domain/models/moon_conditions.dart`
   - `moon_conditions_test.dart:35,68` (separation vs USNO and Horizons), `:196` (Moon below the horizon)
   - `grep "calculateLunarIllumination"` finds only a comment (`visibility_calculator.dart:126`)
   - `sky_darkness_moon_test.dart`
4. **Actual:** implemented.
5. **Status:** **CONFIRMED** · Confidence **High**
6. **Verification needed:** none.

### TASK 6.5 — Correct NPF (still hidden)
1. **Requirement:** constants from Michaud; a K parameter; declination handling documented; at least 3 published examples including a phone lens; a DECISIONS entry.
2. **Acceptance:** SI-001 marked "fixed, unsurfaced".
3. **Evidence:**
   - `optical_calculator.dart:75-127` (formula and derived constants)
   - `optical_calculator_test.dart:67-136` (5 examples, derivation, k range)
   - DECISIONS SI-001 record (`:591-618`) states a **deviation**: the primary source has no numeric worked examples, so 5 independently computed examples are used
4. **Actual:** implemented. NPF was later surfaced by TASK 8.6, as the roadmap planned.
5. **Status:** **CONFIRMED** (with a documented test-method deviation) · Confidence **High**
6. **Verification needed:** none.

## G7 — Sites and location

### TASK 7.1 — Site model and schema
1. **Requirement:** nullable Bortle with source and date, SQM, elevation in metres, IANA zone and notes; the current position stays transient; the formatter prefers the site's zone; the legacy Bortle 4 becomes null.
2. **Acceptance:** no code path writes into a saved site without explicit user action.
3. **Evidence:**
   - v17 `location_profiles` columns (baseline §4)
   - `from11To12` transformer (Bortle 4 → NULL with a note)
   - `schema_migration_test.dart:626`
   - `planner_site_test.dart:121` ("GPS on first launch creates no site")
   - `night_time_formatter_zone_test.dart:8-38`
   - `IanaTimeContext` (`iana_time_context.dart:15`)
4. **Actual:** implemented. Elevation cannot be unknown (FEATURE_STATUS F-07).
5. **Status:** **CONFIRMED** · Confidence **High**
6. **Verification needed:** none.

### TASK 7.2 — Location and geocoding services
1. **Requirement:** `LocationService` states with rationale and "open settings"; a `ReverseGeocoder` (identifying user agent, at most 1 request/s, rounded cache, attribution); map attribution; typed coordinates offline.
2. **Acceptance:** no `http` or `geolocator` imports in presentation or domain.
3. **Evidence:**
   - `planner_location_test.dart:260` ("no http or geolocator import in presentation or domain"; the grep also finds none)
   - `nominatim_reverse_geocoder.dart:27,32,63-77,115` (user agent, 1 s interval, rounding)
   - `nominatim_reverse_geocoder_test.dart:55-198`
   - `location_picker_screen_test.dart:97-169` (services off, denial, denied forever, typed coordinates, OSM attribution)
4. **Actual:** implemented. Since TASK 16.3 the geocoder is wrapped by `OptInReverseGeocoder` and is off by default.
5. **Status:** **CONFIRMED** (host) · Confidence **High**
6. **Verification needed:** Android permission dialogs and settings deep links on a device (TEST_PLAN L2).

### TASK 7.3 — Sites UI and first-run site setup
1. **Requirement:** a site list with the active one marked; an editor (validation, zone picker defaulting to the device zone, Bortle/SQM with source); "use current position" and "save as site"; a first-run prompt.
2. **Acceptance:** switching sites changes all night times.
3. **Evidence:** `planner_sites_test.dart:89` ("switching sites changes all night times (acceptance)"), `:116` (persists across a restart), `:167` (deleting the active site); `sites_screen_test.dart:110-284`.
4. **Actual:** implemented.
5. **Status:** **CONFIRMED** · Confidence **High**
6. **Verification needed:** none.

### TASK 7.4 — Light-pollution MVP; remove the scraper
1. **Requirement:**
   - A: an external map at the site;
   - B: manual Bortle and/or SQM with source and date;
   - delete `LightPollutionRepository`;
   - document options C and D as deferred.
2. **Acceptance:** no scraping code remains.
3. **Evidence:**
   - `planner_sky_darkness_test.dart:87` (no network call on a location change), `:99` ("no scraping code remains in lib/")
   - `light_pollution_map_link.dart:4`; `light_pollution_map_link_test.dart:8,17`
   - `sites_screen_test.dart:251` (Bortle and SQM stored as user)
   - DECISIONS PD-05 (`:565-589`), with C and D deferred
4. **Actual:** implemented.
5. **Status:** **CONFIRMED** · Confidence **High**
6. **Verification needed:** none.

## G8 — Targets and equipment

### TASK 8.1 — Target model hardening
1. **Requirement:** hide moving types; RA in h:m:s or hours and Dec in d:m:s; epoch, source, size and magnitude columns; edits keep the catalog id; uniqueness; escaped search.
2. **Acceptance:** "05h35m17s / −05°23′28″" is stored as the correct degrees.
3. **Evidence:**
   - `AstroMath.parseRightAscension` (`astro_math.dart:81`)
   - `astro_math_coordinates_test.dart:15,75` ("the acceptance example and its variants"), `:92` (−0°30′)
   - `drift_target_repository_test.dart:95` (id kept), `:113` (unique), `:124` (`%` and `_` literal)
   - `astro_target_user_edit_test.dart:98` (moving types not selectable)
   - `schema_migration_test.dart:559` (v13)
4. **Actual:** implemented.
5. **Status:** **CONFIRMED** · Confidence **High**
6. **Verification needed:** none.

### TASK 8.2 — Curated catalog with provenance (cut line)
1. **Requirement:** an OpenNGC-derived versioned asset; licence checked; versioned seeding that never resurrects deleted targets; attribution in About.
2. **Acceptance:** 110–250 objects with epoch, source and size.
3. **Evidence:**
   - `assets/catalog/catalog_v2.json` (version 2; 164 objects; epoch J2000; source `catalog:openngc@v20260501`; no `sizeArcmin` for M40 and M73 only)
   - `catalog_seeder_test.dart:27` (164), `:41` ("every object has a size except the two OpenNGC has none for"), `:135` (never resurrected), `:72` (spot checks)
   - `about_screen_test.dart:25`
4. **Actual:** implemented. 2 of 164 objects have an unknown size because the source has none; SI-008 requires unknown values to stay unknown.
5. **Status:** **CONFIRMED** · Confidence **High**
6. **Verification needed:** none.

### TASK 8.3 — ADR: equipment model and aperture semantics
1. **Requirement:** flat profile; unit-explicit names; focal ratio plus diameter; tracking type; maximum exposure; no reinterpretation.
2. **Acceptance:** owner-approved.
3. **Evidence:** ADR-011 (`DECISIONS.md:1727`); PD-03 and PD-10 resolved (`:521`).
4. **Actual:** accepted.
5. **Status:** **CONFIRMED** · Confidence **High**
6. **Verification needed:** none.

### TASK 8.4 — Equipment domain and schema
1. **Requirement:** unit renames; plausibility ranges; tracking type, maximum exposure and diameter; the form; a review prompt.
2. **Acceptance:** every equipment number carries a unit in code and in the UI.
3. **Evidence:**
   - `equipment_limits.dart:15` (`resolveAperture`)
   - `equipment_selection_screen_test.dart:379` ("every equipment number shows its unit"), `:330` (stored f/72 flagged, never converted)
   - `equipment_limits_test.dart:11-116`
   - `schema_migration_test.dart:509` (v13→v14: f/72 stays 72)
4. **Actual:** implemented.
5. **Status:** **CONFIRMED** · Confidence **High**
6. **Verification needed:** none.

### TASK 8.5 — Seed verification and provenance
1. **Requirement:** each seed verified against a primary source, with source and confidence, or removed.
2. **Acceptance:** SI-011 closed or explicitly limited.
3. **Evidence:**
   - `equipment_seeder.dart:12` (ZWO product URL), `:35-46`
   - `equipment_seeder_test.dart:60` (one seed), `:84` ("sensor size = resolution x pitch within 2 %")
   - `equipment_provenance_test.dart`
   - v15 `source`/`confidence` columns
   - SCIENTIFIC_INTEGRITY index: SI-011 "Resolved for shipped seeds"
4. **Actual:** implemented. The phone seeds were dropped (owner decision).
5. **Status:** **CONFIRMED** · Confidence **High**
6. **Verification needed:** none.

### TASK 8.6 — Capability summary and untracked guidance
1. **Requirement:** FOV; pixel scale; NPF for untracked rigs with K and declination; recommended maximum sub; FOV fit; a planner warning; decide PD-11.
2. **Acceptance:** a phone with a 30 s block shows the NPF value and a warning.
3. **Evidence:**
   - `capability_calculator.dart:79`
   - `capability_calculator_test.dart:53-158` (`:158` "a phone with a 30 s sub is warned")
   - `capture_plan_widget_test.dart:277` ("a phone on a tripod with a 30 s light block is warned")
   - PD-11 resolved (`DECISIONS.md:549`)
4. **Actual:** implemented.
5. **Status:** **CONFIRMED** · Confidence **High**
6. **Verification needed:** none.

## G9 — Weather

### TASK 9.1 — ADR: provider, variables, alignment, staleness
1. **Requirement:** provider and model; variables; UTC; horizon; staleness; attribution.
2. **Acceptance:** owner-approved.
3. **Evidence:** ADR-012 (`DECISIONS.md:1852`); PD-15 resolved (`:537`).
4. **Actual:** accepted.
5. **Status:** **CONFIRMED** · Confidence **High**
6. **Verification needed:** none.

### TASK 9.2 — WeatherSnapshot and UTC parsing
1. **Requirement:** a typed snapshot with nullable fields; a request that covers the night; nulls become unknown.
2. **Acceptance:** the device time zone doesn't change parsed instants.
3. **Evidence:**
   - `open_meteo_weather_repository.dart:19-56` (`best_match`, `unixtime`, start and end hour, horizon of 16 days)
   - `OpenMeteoForecastParser` (`open_meteo_forecast_parser.dart:11`)
   - `open_meteo_forecast_test.dart:56` ("instants are UTC and independent of the device zone"), `:75`, `:90` (nulls are unknown), `:111-216`
4. **Actual:** implemented.
5. **Status:** **CONFIRMED** · Confidence **High**. Tested against recorded fixtures only.
6. **Verification needed:** the live Open-Meteo response shape (runtime).

### TASK 9.3 — Caching, staleness and failure states
1. **Requirement:** a cache keyed by coordinates, model and fetch time; freshness constants; states for fresh, stale, offline and out of range.
2. **Acceptance:** airplane mode shows cached data with its age.
3. **Evidence:**
   - `night_weather.dart:18-19` (3 h / 12 h)
   - `NightWeatherService` (`night_weather_service.dart:12`)
   - `night_weather_service_test.dart:89-169` (`:128` "offline: the cached forecast is shown with its age")
   - `weather_forecast_widget_test.dart:188`
4. **Actual:** implemented. Offline is simulated with a fake repository.
5. **Status:** **CONFIRMED** (host) · Confidence **High**
6. **Verification needed:** airplane mode on a device (TEST_PLAN L1).

### TASK 9.4 — Night-aligned indicators and UI
1. **Requirement:** slice to the night; per-hour values; dew heuristic; ranges; units; attribution; zone labels.
2. **Acceptance:** a night 5 days ahead shows its own hours, or "no forecast".
3. **Evidence:** `night_weather_summarizer_test.dart:203`; `weather_forecast_widget_test.dart:223` (the same case); `NightWeatherSummarizer` (`night_weather_summarizer.dart:7`).
4. **Actual:** implemented.
5. **Status:** **CONFIRMED** · Confidence **High**
6. **Verification needed:** none.

## G10 — Imaging Opportunity

### TASK 10.1 — ADR: opportunity semantics
1. **Requirement:** which conditions gate and which annotate; optional user gates; no score; vectors.
2. **Acceptance:** owner-approved.
3. **Evidence:** ADR-013 (`DECISIONS.md:1976`; vectors §7 `:2057`); PD-17 resolved (`:622`).
4. **Actual:** accepted.
5. **Status:** **CONFIRMED** · Confidence **High**
6. **Verification needed:** none.

### TASK 10.2 — ImagingOpportunity calculator
1. **Requirement:**
   - gate state per sample;
   - windows with annotations;
   - reasons for excluded time;
   - maximum altitude inside the windows;
   - a shared Sun track;
   - (g) the fit consumes the opportunity windows.
2. **Acceptance:** the vectors pass; the fit uses the opportunity windows.
3. **Evidence:**
   - `imaging_opportunity_calculator.dart:79`, `SunTrack` `:13`
   - `imaging_opportunity_calculator_test.dart:104-389` (V1–V12, polar night, midnight sun, a target that never rises, a circumpolar dip)
   - `night_conditions_viewmodel.dart:224-225` (`visibilityWindows => imagingOpportunity?.visibilityWindows`); `capture_analysis_viewmodel.dart:152,184` (the fit uses `_conditions.visibilityWindows`)
4. **Actual:** implemented. The optional Moon and cloud gates can be set in `PlanningPreferences`, but no UI exposes them (TD-050). UI was out of scope for this task, and no later roadmap task lists the control; see §B.
5. **Status:** **CONFIRMED** · Confidence **High**
6. **Verification needed:** none for this task.

### TASK 10.3 — Opportunity presentation
1. **Requirement:** a timeline (darkness bands, target and Moon altitude, highlighted windows); a text list with annotations; the heuristic warning removed.
2. **Acceptance:** every excluded period shows its reason.
3. **Evidence:** `tonight_opportunity_widget_test.dart:139` ("every excluded period is listed with its reasons"), `:171` (no-window reason), `:83` (every failing gate listed); "wash out" and `skyDarknessWarning` absent from `lib`.
4. **Actual:** implemented.
5. **Status:** **CONFIRMED** · Confidence **High**
6. **Verification needed:** none.

### TASK 10.4 — Tonight's candidates
1. **Requirement:** usable minutes, window start and end, maximum altitude, minimum Moon separation and FOV fit per target; sort and filter; off the UI thread.
2. **Acceptance:** "under 1 s for 250 targets on a mid-range device."
3. **Evidence:**
   - `candidate_evaluator.dart:126`, `MoonTrack` `:17`
   - `Isolate.run` at `night_conditions_viewmodel.dart:238`
   - `candidate_evaluator_test.dart:149` ("250 targets evaluate in under a second", development machine), `:241-280` (sort and filter)
   - `tonight_candidates_screen_test.dart:67` (equals the single-target view)
4. **Actual:** implemented; the host run is under 1 s.
5. **Status:** **UNVERIFIED** (the acceptance names a mid-range device) · Confidence **High**
6. **Verification needed:** timing on a mid-range Android device.

### TASK 10.5 — Azimuth and horizon profile (cut line)
1. **Requirement:** azimuth, a per-site horizon, an editor and gating.
2. **Acceptance:** a 40° eastern obstruction trims the window.
3. **Evidence:** `MASTER_ROADMAP.md:910` "CUT for 1.0 by the owner"; ROADMAP / FEATURE_STATUS F-17 "Missing by decision"; ADR-013 G3 horizon gate "reserved".
4. **Actual:** not implemented, by decision.
5. **Status:** **DEFERRED** · Confidence **High**
6. **Verification needed:** none.

## G11 — Session aggregate

### TASK 11.1 — ADR: Session aggregate, lifecycle and snapshots
1. **Requirement:** root, references, snapshots, LogbookEntry, ExecutionState, storage.
2. **Acceptance:** approved, with an entity diagram.
3. **Evidence:** ADR-014 (`DECISIONS.md:2120`); PD-18 resolved (`:635`).
4. **Actual:** accepted.
5. **Status:** **CONFIRMED** · Confidence **High**
6. **Verification needed:** none.

### TASK 11.2 — Session schema migration
1. **Requirement:**
   - (a) references with SET NULL, night key, status, timestamps and versioned snapshot JSON;
   - (b) block counters;
   - (c) legacy rows marked legacy;
   - (d) indexes;
   - (e) optionally, the `@DataClassName` renames.
2. **Acceptance:** legacy logs are still listed.
3. **Evidence:**
   - v17 `session_logs` (34 columns) and `capture_blocks` counters (baseline §4); three indexes
   - `schema_migration_test.dart:204-439` (v16 group: SET NULL `:339`, CHECK constraint `:328`, JSON round trip `:414`)
   - `drift_session_repository_test.dart:272` (legacy rows read-only and still listed)
   - the optional renames were not done (TD-045, optional by scope)
4. **Actual:** implemented.
5. **Status:** **CONFIRMED** · Confidence **High**
6. **Verification needed:** none.

### TASK 11.3 — SessionRepository and snapshot builders
1. **Requirement:** create, update, status change, list, get; pure builders; replace the LogbookRepository.
2. **Acceptance:** editing a rig after saving leaves the saved snapshot intact.
3. **Evidence:**
   - `lib/domain/repositories/session_repository.dart:15-87`
   - `DriftSessionRepository` (`drift_session_repository.dart:21`)
   - `SessionSnapshotBuilder` (`session_snapshot_builder.dart:18`)
   - `drift_session_repository_test.dart:321` ("editing the rig after saving leaves the snapshot unchanged"), `:255` (rollback)
   - `session_snapshot_builder_test.dart:126-173`
4. **Actual:** implemented.
5. **Status:** **CONFIRMED** · Confidence **High**
6. **Verification needed:** none.

### TASK 11.4 — Planner works on a persisted draft session
1. **Requirement:** a draft created or resumed; autosave; New, Duplicate and Open; migrate the plan from preferences; Save marks planned and takes a snapshot.
2. **Acceptance:** "force-stopping the app never loses edits."
3. **Evidence:** `planner_draft_session_test.dart:87-183` (`:100` "every edit is in the database when the call returns; a restart…", `:120` preferences migration, `:142` duplicate); `CurrentSession` (`current_session.dart:11`); `lifecycle_matrix_test.dart:219` (L3, simulated kill).
4. **Actual:** implemented. The kill is simulated by closing and reopening the database file.
5. **Status:** **CONFIRMED** (host) · Confidence **High**
6. **Verification needed:** a force-stop on a device (TEST_PLAN L3).

## G12 — UX foundation and navigation

### TASK 12.1 — Information architecture ADR
1. **Requirement:** bottom navigation, full-screen execution, field constraints, and PD-14 resolved as a fixed Tonight view.
2. **Acceptance:** owner-approved.
3. **Evidence:** ADR-015 (`DECISIONS.md:2300`); `docs/IA_WIREFRAMES.md`; PD-19 and PD-14 resolved (`:648`). The owner renamed the "Gear & Targets" tab to "Library".
4. **Actual:** accepted.
5. **Status:** **CONFIRMED** · Confidence **High**
6. **Verification needed:** none.

### TASK 12.2 — Navigation shell
1. **Requirement:** a `StatefulShellRoute`; gate-aware routes; correct Android back behaviour.
2. **Acceptance:** every screen is reachable per the map.
3. **Evidence:**
   - `app_router.dart:28,85-220`
   - `app_shell_navigation_test.dart:139` ("every route in the map opens its screen"), `:179` (back behaviour), `:195` (tabs keep their place)
   - route deviations from the wireframes are documented in ADR-015 §7 (`DECISIONS.md:2371-2385`): the rig and target editors are dialogs, and there are no `/library/*/edit` routes
4. **Actual:** implemented, with documented deviations.
5. **Status:** **CONFIRMED** · Confidence **High**
6. **Verification needed:** the physical Android back button on a device.

### TASK 12.3 — Complete the ViewModel decomposition
1. **Requirement:** screen-scoped ViewModels; screens go through them; the mutable list no longer exposed.
2. **Acceptance:** no ViewModel over about 250 lines; no HTTP, SharedPreferences, Drift or Geolocator imports in ViewModels.
3. **Evidence:**
   - `viewmodel_rules_test.dart:21` (no I/O or data-layer import), `:38` (≤ about 250 code lines), `:55` (god object gone)
   - physical line counts: `session_plan` 299, `capture_analysis` 274, `night_conditions` 272, `site` 256; the others are smaller
   - `grep PlannerViewModel lib` finds only a comment
4. **Actual:** implemented. The test counts code lines (≤ 250) with a 300-line physical cap; `session_plan` is at 299 physical lines.
5. **Status:** **CONFIRMED** · Confidence **High**
6. **Verification needed:** none.

### TASK 12.4 — Semantic theme tokens; complete red field mode
1. **Requirement:** tokens for light, dark and field themes; readable type; ≥ 48 dp targets; field mode persisted; the gate lifted after a darkness checklist.
2. **Acceptance:** field mode survives a restart, with no non-red pixels.
3. **Evidence:**
   - `AppPalette` (`app_palette.dart:11`); `AppTheme.fieldFilter` (`app_theme.dart:189`)
   - `presentation_style_rules_test.dart:23` (no hard-coded colour), `:27`, `:31`
   - `app_theme_test.dart:29-111` (field tokens are red or black; filter behaviour)
   - `field_mode_darkness_test.dart:105` ("field mode survives a restart"), `:115` (darkness checklist in pixel tests)
   - TEST_PLAN:739 "Owner checklist (manual, not yet done)" for real darkness on a device
4. **Actual:** implemented. Automated pixel checks pass on the host.
5. **Status:** **CONFIRMED** (host) · Confidence **High**
6. **Verification needed:** the on-device darkness checklist, which is the roadmap's own listed test.

### TASK 12.5 — Tonight dashboard and first-run flow
1. **Requirement:** night window, site, fit and reason, Moon, weather with its age, quick actions; a skippable first run with a permission rationale.
2. **Acceptance:** "no overflow at 200 % text size; owner walkthrough."
3. **Evidence:** `tonight_home_screen_test.dart:112-166` (no site, no rig, no forecast, fits, doesn't fit), `:172-195` (200 % text, no overflow), `:205-250` (first run); TEST_PLAN:753 "Owner walkthrough (manual, not yet done)".
4. **Actual:** implemented. The owner walkthrough clause is not met.
5. **Status:** **PARTIAL** (owner walkthrough outstanding) · Confidence **High**
6. **Verification needed:** the owner walkthrough on a device.

## G13 — Execution

### TASK 13.1 — ADR: execution model under Android constraints
1. **Requirement:** foreground-only tracking; progress from persisted UTC timestamps; every transition persisted; estimates confirmed by the user; opt-in keep-screen-on.
2. **Acceptance:** approved.
3. **Evidence:** ADR-016 (`DECISIONS.md:2387`); PD-20 resolved (`:658`).
4. **Actual:** accepted.
5. **Status:** **CONFIRMED** · Confidence **High**
6. **Verification needed:** none.

### TASK 13.2 — Execution state machine and persistence
1. **Requirement:** transitions (planned → running ⇄ paused → completed or abandoned); counters; events; rejection of invalid transitions; a resume prompt.
2. **Acceptance:** killing the app mid-block restores the exact state.
3. **Evidence:**
   - `execution_machine.dart:6`; `execution_machine_test.dart` (the transition table and clock cases)
   - `drift_session_execution_test.dart:255` ("acceptance: killing the app mid-block restores the exact state", on a file database), `:304` (clock set back)
   - `resume_run_prompt_test.dart:134-214`
   - schema v17 `session_events`
4. **Actual:** implemented. The kill is simulated with a file database.
5. **Status:** **CONFIRMED** (host) · Confidence **High**
6. **Verification needed:** a real process kill on Android (TEST_PLAN L4).

### TASK 13.3 — Execution screen
1. **Requirement:** the current block with estimated vs confirmed counts; +1, −1, reject and pause; countdowns; remaining window vs remaining plan; interruption tags.
2. **Acceptance:** every action reachable with one thumb.
3. **Evidence:** `execution_screen.dart:22`; `ExecutionOutlook` (`execution_outlook.dart:12`); `execution_screen_test.dart:285` ("acceptance: every action is in the lower half, at least…"), `:209-268`, `:305` (200 % text); `execution_outlook_test.dart:118-177`.
4. **Actual:** implemented.
5. **Status:** **CONFIRMED** (host) · Confidence **High**
6. **Verification needed:** TEST_PLAN:789 owner checklist on a device (lock and unlock, kill, keep-screen-on).

### TASK 13.4 — End-of-session reconciliation
1. **Requirement:** confirm actuals, rejected frames, notes and conditions; complete or abandon; planned vs actual.
2. **Acceptance:** a completed session shows planned vs actual integration.
3. **Evidence:** `results_screen.dart:17`; `SessionReconciliation` (`session_reconciliation.dart:35`); `results_screen_test.dart:192` ("acceptance: a completed session shows planned vs actual in…"); `session_reconciliation_test.dart:53-88`; `drift_session_execution_test.dart:322-401`.
4. **Actual:** implemented.
   - **Observation:** the resume prompt's Finish completes the session directly, without the results page (`resume_run_prompt_test.dart:163` "Finish completes the session").
   - ADR-016 §11's owner decision ("Finish opens reconciliation") names only the tracker's Finish (`DECISIONS.md:2578-2579`). Both paths satisfy the acceptance.
5. **Status:** **CONFIRMED** · Confidence **High**
6. **Verification needed:** owner confirmation that completing from the resume prompt without reconciliation is intended.

## G14 — Logbook

### TASK 14.1 — Logbook list and detail
1. **Requirement:** filters by status, target, site and date; a detail view with snapshots and zone, plan vs actual per block, notes; a legacy badge.
2. **Acceptance:** legacy and new sessions both render.
3. **Evidence:** `session_list_filter_test.dart:52-79`; `session_detail_test.dart:197` (acceptance: renders from the execution-start snapshot), `:244` (acceptance: a legacy log renders its stored text), `:156-186`.
4. **Actual:** implemented.
5. **Status:** **CONFIRMED** · Confidence **High**
6. **Verification needed:** none.

### TASK 14.2 — Accumulated integration per target (cut line)
1. **Requirement:** Σ integration per target and filter, last date, session count.
2. **Acceptance:** target detail shows the total logged integration.
3. **Evidence:**
   - `TargetProgress` (`target_progress.dart:9`); `target_progress_test.dart:77-134`
   - `session_detail_test.dart:270` ("the detail shows the target so far; Library → Progress")
   - the owner decided to build this cut-line task (ROADMAP, FEATURE_STATUS header)
4. **Actual:** implemented as a pure domain aggregate shown in Library → Progress and on the session detail. There is no separate target-detail screen. The roadmap direction ("a SQL aggregate") was not followed; that direction was not part of the acceptance.
5. **Status:** **CONFIRMED** · Confidence **Medium**. "Target detail" is realised as a Progress list plus the session-detail line.
6. **Verification needed:** none.

### TASK 14.3 — Export manifest v2
1. **Requirement:** a documented v2 schema (UTC plus zone, snapshots, units, app version); share a file and a text summary; read v1; import deferred.
2. **Acceptance:** an exported file re-parses identically.
3. **Evidence:** `docs/EXPORT_MANIFEST.md:26-39`; `session_manifest_codec.dart:31-68`; `session_manifest_codec_test.dart:141` (acceptance), `:195` (v1), `:213` (unknown versions refused); `session_detail_test.dart:292,305`.
4. **Actual:** implemented. Import is deferred by scope.
5. **Status:** **CONFIRMED** · Confidence **High**
6. **Verification needed:** the share sheet on a device (faked in tests).

### TASK 14.4 — Backup and restore
1. **Requirement:** a consistent database copy plus the manifest, saved to a user-chosen location; restore with a schema check and confirmation; document Auto Backup.
2. **Acceptance:** a restore on a clean install reproduces all sessions. The roadmap's test is "round trip on an emulator".
3. **Evidence:**
   - `FileBackupService` (`file_backup_service.dart:23`); `BackupStaging` (`backup_staging.dart:10`); `main.dart:52-62` (staged restore applied before the database opens)
   - `backup_restore_test.dart:121-248` (host round trip; refusals)
   - `backup_section_test.dart:96-129`
   - Auto Backup documented in `DATA_MODEL.md:314-316` ("unverified on a device")
   - TD-056 (preferences not in the backup)
4. **Actual:** implemented and round-tripped on desktop SQLite.
5. **Status:** **CONFIRMED** (host) · Confidence **High**
6. **Verification needed:** the emulator round trip (TEST_PLAN:846) and Auto Backup behaviour on a device.

## G15 — Quality hardening

### TASK 15.1 — Error handling and diagnostics
1. **Requirement:** typed repository failures; user messages; a debug logger; `empty_catches`; crash reporting deferred.
2. **Acceptance:** no empty catch blocks remain.
3. **Evidence:**
   - `analysis_options.yaml` (`empty_catches: true`)
   - `no_empty_catch_test.dart:23` ("no empty catch block in lib")
   - `StorageFailureInterceptor` (`storage_failure_interceptor.dart:14`); `AppLog` (`app_log.dart:40`); `failure_feedback.dart:40` (`LoadFailureView`)
   - `storage_failure_test.dart:82-187`
   - one `print` remains, in migration orphan logging (`app_database.dart:524-528`, `// ignore: avoid_print`), outside any catch block
   - `SharedPrefsPrivacyPreferencesRepository` (added in 16.3) uses `guardStorage` but has no failure-path test in `storage_failure_test.dart`
4. **Actual:** the acceptance is met.
5. **Status:** **CONFIRMED** · Confidence **High**
6. **Verification needed:** none for the acceptance. Evidence gaps are noted in §G.

### TASK 15.2 — Performance and caching
1. **Requirement:** memoization; profile traces; isolates if needed.
2. **Acceptance:** "no jank in traces; candidates in under 1 s."
3. **Evidence:** `planner_memoization_test.dart:90-149` (`:149` benchmark: about 0.08 ms per cached frame and about 95 ms for the candidates, documented in TEST_PLAN:879-882); TEST_PLAN:883 "Owner checklist (manual, not yet done)" for profile traces.
4. **Actual:** memoization is implemented; the candidates run under 1 s on the host. No traces were taken.
5. **Status:** **PARTIAL** (the traces clause is unmet) · Confidence **High**
6. **Verification needed:** profile-mode traces on a low-end device.

### TASK 15.3 — Accessibility pass
1. **Requirement:** labels, 200 % text, contrast with red-mode limits documented, focus order, chart alternatives, tap targets.
2. **Acceptance:** "guideline tests pass; a TalkBack walkthrough is recorded."
3. **Evidence:** `accessibility_test.dart:149` (6 sweeps; passed), `:189` (chart text alternative); ARCHITECTURE B16 (red-mode limit documented); TEST_PLAN:902 "TalkBack walkthrough… not yet done".
4. **Actual:** the guideline tests pass. No TalkBack walkthrough is recorded.
5. **Status:** **PARTIAL** · Confidence **High**
6. **Verification needed:** a recorded TalkBack walkthrough.

### TASK 15.4 — Lifecycle, process-death and offline matrix
1. **Requirement:** a scripted matrix covering offline install, permissions, "Don't keep activities", rotation and theme, a zone change, beta upgrade and low storage, automated where feasible.
2. **Acceptance:** "passed and recorded."
3. **Evidence:** `lifecycle_matrix_test.dart:170-427` (L1, L3, L4, L5, L6 and L8 on the host; passed); TEST_PLAN:914-941 (every device row "Not run", "Device runs: (none yet)"); ROADMAP:448-452 "In progress… Open".
4. **Actual:** the host rows pass. The device rows L1–L8 have not been run.
5. **Status:** **PARTIAL** · Confidence **High**
6. **Verification needed:** every device row. L7 needs a shipped beta.

### TASK 15.5 — End-to-end regression suite
1. **Requirement:** `integration_test` covering the loop from site to export with a restart, plus time-zone cases, using the real database and a faked network.
2. **Acceptance:** "green on the emulator."
3. **Evidence:** `integration_test/core_loop_test.dart:247,372` (passed on the host in R1 and R2); passed as a native Windows app (DOC only, TEST_PLAN:964-966); TEST_PLAN:970 "Emulator run: not done".
4. **Actual:** the suite exists and is green on the host.
5. **Status:** **UNVERIFIED** · Confidence **High**
6. **Verification needed:** `flutter test integration_test -d <android>`.

## G16 — Release preparation (up to 16.3)

### TASK 16.1 — App identity
1. **Requirement:** an owner name and trademark search; decide the id, label, icon and splash; record in DECISIONS.
2. **Acceptance:** "final before any upload." The roadmap's test is "build and install".
3. **Evidence:**
   - OD-07 (`DECISIONS.md:315`)
   - `AppIdentity` (`lib/core/config/app_identity.dart`); `build.gradle.kts` (`applicationId io.github.chacha12.astroplanner`); manifest label "Astro Planner"
   - `android/app/src/main/kotlin/io/github/chacha12/astroplanner/MainActivity.kt`; adaptive icon resources (`mipmap-anydpi-v26`, `drawable*`, `values-v31`)
   - `app_identity_test.dart:15,26,51`
   - build artifact `build/app/outputs/flutter-apk/app-debug.apk` (2026-09-24 18:25); install not performed (TEST_PLAN:978)
   - only a preliminary web search was done; a formal trademark search is left to the owner (OD-07)
4. **Actual:** the identity is decided and wired.
5. **Status:** **CONFIRMED** (decision and code) · Confidence **High**. Qualifiers:
   - **UNVERIFIED:** install.
   - **OWNER DECISION:** the formal trademark search, and confirming the `chacha12` account. The git remote is `github.com/Buffur/Astro-Planner`.
6. **Verification needed:** install on a device; the owner's trademark and account confirmation.

### TASK 16.2 — Release build and signing
1. **Requirement:**
   - an upload key created by the owner and a gitignored `key.properties`;
   - Play App Signing;
   - versioning;
   - target SDK and page-size checks;
   - an R8 decision;
   - an AAB build.
2. **Acceptance:** "a signed AAB builds locally." The roadmap's test: a release build installs.
3. **Evidence:**
   - `android/app/build.gradle.kts` (reads `key.properties`, falls back to the debug key with a warning)
   - `.gitignore:49-51`; `android/.gitignore:12-14`
   - `tool/check_bundle.dart`; `release_config_test.dart:69-134`
   - `docs/RELEASE.md`
   - **`android/key.properties` is absent** (checked for existence only; nothing read)
   - `build/app/outputs/bundle/release/app-release.aab` (17:50) is debug-signed per RELEASE.md, and older than code commit `2521f42` (18:21)
4. **Actual:** the configuration and tooling are in place. No signed AAB exists.
5. **Status:** **PARTIAL** + **OWNER DECISION** (the upload key) · Confidence **High**
6. **Verification needed:** the signed bundle, `check_bundle` passing, and a release install on a device.

### TASK 16.3 — Legal and compliance (PD-12)
1. **Requirement:** a privacy policy; the Data Safety form; attribution and licence screens; terms re-verified with a date; GPL-3.0 intent confirmed; permission rationale.
2. **Acceptance:** "the policy URL is live; attributions appear in the app."
3. **Evidence:**
   - PD-12 resolved (`DECISIONS.md:669-687`)
   - `docs/privacy/index.md`, where **line 62 still reads `<CONTACT EMAIL>`**
   - `docs/COMPLIANCE.md` (terms checked 2026-09-24; a draft of the Data Safety answers)
   - `about_screen.dart:37-68`; `about_screen_test.dart:25,39,51` (attributions, GPL-3.0, policy link)
   - `OptInReverseGeocoder` (`opt_in_reverse_geocoder.dart:8`); `place_name_lookup_test.dart:60-93`
   - `AppIdentity.privacyPolicyUrl` = `https://chacha12.github.io/astro-planner/privacy/`; whether it is live was not checked (UNKNOWN)
4. **Actual:** the attributions clause is met. The policy URL clause is not demonstrated, and the contact placeholder remains. The Data Safety form is not filed (the owner's step).
5. **Status:** **PARTIAL** + **OWNER DECISION** · Confidence **High**
6. **Verification needed:** publish the policy with a contact, confirm the URL resolves, make the repository public, and file the Data Safety form.

---

## Milestones (§6) up to M6; M7 is out of the baseline

| Milestone | Definition of done | Evidence | Status |
| --- | --- | --- | --- |
| M0 | Docs committed; roadmap adopted; PD-06; tests green without sleeps; deterministic offline start; **CI running** | TASKs 0.1–1.3 above; CI never executed (1.3) | **PARTIAL** |
| M1 | SessionNight matrix green; one source for chart, timeline and windows; zone labels; TD-001 resolved | TASKs 2.1–2.4; resolver T1–T17 | **CONFIRMED** (host); the 2.4 emulator check is UNVERIFIED |
| M2 | Migration tests and snapshots; foreign keys on; orphan table gone; G4 defects resolved; no "SNR"; unknowns shown as unknown | TASKs 3.x and 4.x; 3.2 reset UI missing; "SNR" in comments | **PARTIAL** |
| M3 | Budget fitted to the windows, with reasons and "what fits"; **owner dogfoods on real nights and makes a go/no-go call** | G5 CONFIRMED; no record of dogfooding or a go/no-go call in `docs/` (grep "dogfood", "go/no-go": no matches outside MASTER_ROADMAP) | **PARTIAL** (the product part is CONFIRMED; the go/no-go is UNVERIFIED) |
| M4 | Moon within tolerances; sites with zones; units and provenance; UTC weather with staleness; Opportunity with reasons; candidates | G6–G10 | **CONFIRMED** (host), except 6.2 PARTIAL and 10.4 device UNVERIFIED |
| M5 | Draft, planned and duplicate sessions with snapshots; shell; VM split; complete red mode; Tonight dashboard | G11–G12 | **CONFIRMED** (host); 12.5 walkthrough and 12.4 device darkness check outstanding |
| M6 | Execution survives process death; planned vs actual; export v2; backup and restore | G13–G14 | **CONFIRMED** (host); device kill and emulator backup UNVERIFIED |

No milestone is tagged: `git tag` is empty, although §12 says "tag at each milestone".

## Architecture checkpoints (§7)

No AC review record exists in `docs/` (grep "AC1" to "AC7" outside MASTER_ROADMAP: no match).
The conditions themselves were checked against the code:

| Checkpoint | Condition | Evidence | Status |
| --- | --- | --- | --- |
| AC1 (after G1) | Platform code behind interfaces; awaitable bootstrap; no network on the startup path | `LocationService`, `ReverseGeocoder`, `DeviceTimeZone`, `ScreenWake` interfaces; `StartupViewModel.ready`; weather post-frame | Conditions **CONFIRMED**; review record **absent** |
| AC2 (after G2) | No `DateTime.now()` in the domain; one night source; no astronomy in widgets | `clock_test.dart:19`; the astronomy-import grep matches ViewModels only | Conditions **CONFIRMED**; record absent |
| AC3 (after G3) | Migration workflow works; foreign keys on; each schema bump has a snapshot and a test | snapshots v8–v17; migration groups per version | Conditions **CONFIRMED**; record absent |
| AC4 (after G5, G10) | Pure, deterministic domain; units; thresholds from preferences; no score | `PlanningPreferences`; "score" appears only in "no score" comments | Conditions **CONFIRMED**; record absent |
| AC5 (after G11) | Snapshots immutable; references nullable; **no domain state in SharedPreferences** | SET NULL references; frozen execution snapshot. The active site id and the transient position remain in preferences (`activeLocationId`, `transientLatitude`/`Longitude`), kept app-level by owner decision in TASK 11.4 (FEATURE_STATUS header) | **PARTIAL**: an owner-decided exception to the checkpoint wording |
| AC6 (after G12) | No http, shared_preferences, drift or geolocator in presentation; only Provider; VMs ≤ about 250 lines | grep: no such imports in `lib/presentation`; no other state library; `viewmodel_rules_test.dart:38` | Conditions **CONFIRMED**; record absent |
| AC7 (before G16) | Dependency and licence audit; secrets and HTTPS review; performance budgets | COMPLIANCE.md covers third-party *service* terms; no dependency-licence audit record; no HTTPS or secrets review record (grep finds no `Uri.http(` in `lib`); performance budgets unmeasured on a device | **NOT evidenced** (UNVERIFIED) |

## Testing checkpoints (§8) up to G15

| Gate | Requirement | Evidence | Status |
| --- | --- | --- | --- |
| G1 | Suite green 3 times in a row; no sleeps; startup determinism test | R1 and R2 green today (2 runs); no `Future.delayed`; `planner_bootstrap_test.dart:46` | **CONFIRMED** (2 of 3 re-run here) |
| G2 | Time matrix (Americas, after midnight, ±180°, Kiritimati, EU and US DST, polar); independent of the host zone | resolver T1–T17 (T17 is host-zone independence) | **CONFIRMED** |
| G3+ | Snapshot migration tests plus data preservation for each schema change | migration groups for v11–v17 plus M2 | **CONFIRMED** |
| G5 | ADR vectors exactly; **property tests** ("more frames never take less time; windows stay inside the night") | E1–E7 exact; no property-style test found in the budget or fit tests (grep) | **PARTIAL** |
| G6 | Reference fixtures with sources and tolerances; nothing circular | `astronomy_reference_test.dart`, `moon_calculator_test.dart` | **CONFIRMED** (see 6.2 for CALC-01 to CALC-06) |
| G9 | Recorded parser fixtures; staleness with a fake clock | `test/fixtures/weather/*`; `night_weather_service_test.dart:89` | **CONFIRMED** |
| G10 | Opportunity vectors; candidates equal the single-target view | V1–V12; `tonight_candidates_screen_test.dart:67` | **CONFIRMED** |
| G11 and G13 | Transactional rollback; snapshot immutability; process-death restore | `drift_session_repository_test.dart:255,321`; `drift_session_execution_test.dart:205,255` | **CONFIRMED** (host) |
| G14 | Export round trip; backup and restore | `session_manifest_codec_test.dart:141`; `backup_restore_test.dart:121` | **CONFIRMED** (host) |
| G15 | Accessibility tests; offline and lifecycle matrix; E2E | accessibility sweeps pass; lifecycle device rows not run; E2E host only | **PARTIAL** |
| G16 | Full regression on the device matrix; upgrades from every beta schema | none (no device; no beta) | Out of the 16.3 baseline: belongs to TASK 16.4 |

## Release checklist (§9) items that fall on G16 tasks ≤ 16.3

| Checklist item | Owning task | Evidence | Status |
| --- | --- | --- | --- |
| Privacy policy URL, Data Safety form, attributions (OSM, Open-Meteo, catalog source, Nominatim), licence page | 16.3 | Attributions and licence CONFIRMED (`about_screen_test.dart`); the policy has a `<CONTACT EMAIL>` placeholder; whether the URL is live is UNKNOWN; Data Safety not filed | **PARTIAL / OWNER** |
| Terms re-verified and date-stamped; identifying user agent; GPL-3.0 intent | 16.3 | `COMPLIANCE.md` (2026-09-24); `AppIdentity.userAgent`; PD-12 | **CONFIRMED** |
| Final id and name; icon | 16.1 | OD-07; `app_identity_test.dart` | **CONFIRMED** |
| Versioning; upload key with Play App Signing; target SDK and page-size compliance checked | 16.2 | versioning test; page-size check tool (the bundle check passed on alignment, per RELEASE.md); **no upload key** | **PARTIAL / OWNER** |
| Permission rationale shown; denial paths usable | 7.2, 12.5, 16.3 | `location_picker_screen_test.dart:97-145`; the first-run rationale | **CONFIRMED** (host); device UNVERIFIED |
| Red mode verified in real darkness; keep-screen-on only when opted in | 12.4, 13.3 | pixel tests; `execution_screen_test.dart:268`; darkness check not done | **PARTIAL** |
| Git tag created; tests green on an emulator and on 2 physical devices; closed testing; listing | 16.4 / 16.5 | — | Outside the 16.3 baseline |

---

## Final summary

### A. Confirmed complete (acceptance met with host evidence)

0.1, 0.2 · 1.1, 1.2 · 2.1, 2.2, 2.3 · 3.1, 3.3 · 4.1, 4.2, 4.3 · 5.1–5.6 · 6.1, 6.3, 6.4, 6.5 ·
7.1, 7.2, 7.3, 7.4 · 8.1–8.6 · 9.1–9.4 · 10.1, 10.2, 10.3 · 11.1–11.4 · 12.1–12.4 ·
13.1–13.4 · 14.1–14.4 · 15.1 · 16.1 (decision and code).

The following are "confirmed on host" with a device check still listed by TEST_PLAN:
1.2, 7.2, 9.3, 11.4, 12.4, 13.2, 13.3, 14.4. Their acceptance criteria do not require a
device, but TEST_PLAN lists a device or owner check for each.

### B. Partial / incomplete

| Item | What is missing |
| --- | --- |
| **0.3** | Owner-held hygiene items (ADK skill, root `skills-lock.json`, `sqlite3_flutter_libs`, archive retention); no device smoke run |
| **3.2** | The below-floor or downgrade message and the reset-path UI (ADR-008 §2, §9). `resetUnsupportedDatabaseFile` has no caller |
| **4.4** | The acceptance '"SNR" absent from `lib/`' is not met literally: 4 doc-comment occurrences, all negating. DEV-P2 wrongly says the string is gone |
| **6.2** | CALC-01, CALC-02, CALC-03 and CALC-06 lack cited, sourced tests; CALC-04 and CALC-05 are covered only end to end |
| **12.5** | The owner walkthrough clause of the acceptance |
| **15.2** | Profile traces on a low-end device |
| **15.3** | The recorded TalkBack walkthrough |
| **15.4** | The device rows L1–L8 of the lifecycle matrix |
| **16.2** | A signed AAB; a release install |
| **16.3** | The policy URL live; the contact filled in; Data Safety filed |
| **M0** | CI has never run |
| **M2** | Via 3.2 and 4.4 |
| **M3** | No recorded owner go/no-go |
| **AC5** | Site selection and transient position are kept in preferences, by owner decision |
| **G5 testing checkpoint** | No property tests |
| **Cross-task gap (not owned by any roadmap task)** | The ADR-013 optional Moon and cloud gates have no Settings UI (TD-050). The owner-approved behaviour cannot be reached from the UI. 10.2 excluded UI and 10.3's scope did not list the control |

### C. Broken

**None found.** No acceptance criterion was contradicted by a failing test, and both full runs
were green. This means "not observed broken on the host". It does not show that behaviour on a
device is correct.

### D. Unverified

| Item | Evidence that does not exist |
| --- | --- |
| **1.3** | A CI run: the workflow is not on the remote |
| **2.4** | The emulator check in America/Los_Angeles |
| **10.4** | Timing on a mid-range device |
| **15.5** | The E2E suite green on an emulator |
| **16.1** | The install test |
| **AC7** | No dependency, licence, secrets, HTTPS or performance review recorded |
| **Device-level checks** | Every device-level behaviour (TEST_PLAN L1–L8 and the owner checklists) |
| **Real services** | Real network behaviour (Open-Meteo, Nominatim, OSM tiles); only fakes and recorded fixtures are tested |

### E. Explicitly deferred (not counted as missing)

- TASK 10.5 azimuth and horizon (owner cut; F-17 "Missing by decision"; ADR-013 G3 reserved).
- G17 metadata-assisted logging (v1.1). Metadata import stays gated off (`FeatureScope.metadataImport = false`).
- Manifest import (14.3 scope).
- Crash reporting (15.1, deferred for privacy).
- Notifications (ADR-016 / MASTER_ROADMAP §10).
- Light-pollution options C and D (PD-05).
- Moving-object ephemerides (ADR-010 §3).
- Equipment composition UI and camera reuse (ADR-011 §2).
- Optional `@DataClassName` renames (11.2 (e), TD-045).
- Android Auto Backup left unchanged (14.4, owner decision).
- Everything on the MASTER_ROADMAP §10 rejected and deferred lists.
- TASKs 16.4 and 16.5 are outside the stated baseline.

### F. Owner decisions still open

1. **PD-21**, a placeholder for the metadata formats, is decided in TASK 17.1.
2. **Upload key and `key.properties`** (16.2).
3. **Publishing the privacy policy with a contact email; making the source repository public; the Data Safety form** (16.3).
4. **A formal trademark search** for "Astro Planner" (OD-07).
5. **Confirming the GitHub account `chacha12`.** It is used in `AppIdentity.sourceUrl`/`projectUrl` and in the application id, but the configured remote is `Buffur/Astro-Planner`.
6. **The TASK 0.3 holdovers:** the ADK skill, `skills-lock.json`, `docs/archive/` retention, `sqlite3_flutter_libs`.
7. **Clarification of the resume prompt's Finish** (bypasses reconciliation) against ADR-016 §11. Not formally open; flagged here for confirmation.
8. **Ownership of the TD-050 Settings control.** No roadmap task owns it.

### G. Evidence gaps

1. **No Android runtime evidence at all.** Nothing has been installed or run on a device or emulator. The only artifacts are build files; the AAB is debug-signed and predates HEAD's last code commit.
2. **CI never executed.** The quality gate has only ever run locally.
3. **No recorded milestone reviews or tags:** no AC1–AC7 records, no M1–M6 completion records beyond task entries, no M3 dogfooding or go/no-go record, and `git tag` is empty.
4. **The Stage 0 input file** `docs/audit/00_CONTEXT_BASELINE.md` is absent from the repository.
5. **Per-test results were not captured individually.** The JSON reporter produced no file. Test citations rely on both full-suite runs passing (896 plus 2, 0 failed, no skips).
6. **Real third-party behaviour is untested:** Open-Meteo (recorded fixtures only), Nominatim (a mocked client), OSM tiles, lightpollutionmap.info, and the plugins (file_picker, share_plus, wakelock_plus, flutter_timezone, geolocator).
7. **Missing test coverage for specific items:**
   - `SharedPrefsPrivacyPreferencesRepository` has no failure-path test (15.1's "one per repository" predates it);
   - CALC-01 to CALC-03 and CALC-06 have no sourced tests;
   - the G5 property tests are absent.
8. **Documentation claims contradicted by the repository:**
   - DEV-P2's "SNR no longer appears anywhere in `lib/`" (4.4);
   - F-49 and TD-046 say "no Git remote is configured", but a remote exists without the CI commit;
   - the TEST_PLAN L3 device step still uses the old app id `com.astroplan.astroplan`.

   These affect how far the documents can be used as evidence. They were not used as proof here.
9. **Only 2 consecutive green runs were observed** here, not the 3 that G1 asks for.
