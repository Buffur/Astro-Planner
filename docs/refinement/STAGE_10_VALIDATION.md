# Stage 10 — Independent validation (S10.1–S10.7)

Date: 2026-09-30. Reviewed baseline: `3cb67be` (S10.7, documentation only; application code, tests,
dependencies and tooling as at S10.6, `43523bb`; clean working tree before validation). Fresh session,
separate from the one that built S10.1–S10.7; validation only, no application fixes. Procedure:
`CLAUDE.md` V1–V8.

**Scope of this validation.** The frozen Tasks S10.1–S10.7, the Stage's exit (original and the
2026-09-27 amendment), the rules for every Task, DECISIONS E.1 "Stage 10 decisions" (D10-1 to D10-6),
and the `CLAUDE.md` traps the changed code touches. The measurement record
(`evidence/STAGE_10_MEASUREMENTS.md`) is judged against the code it describes.

## Frozen acceptance surface

Frozen before reading the implementation, from `POST_ROADMAP_PLAN.md` ("Stage 10 — Performance &
Application Size": scope, the 2026-09-27 amendment, exit; "Stage 10 — frozen Task sequence (planning,
2026-09-30)": the rules for every Task and S10.1–S10.7 with their scope and acceptance), DECISIONS E.1
(D10-1 to D10-6) and the `CLAUDE.md` traps.

| ID | Criteria to judge |
| --- | --- |
| X | Exit: measurements recorded (method, device, build mode); every optimisation with before-and-after evidence; no functionality lost; the 277 MB classified or recorded as not reproducible; a reproducible release-size baseline with its main contributors measured; the form lag investigated from a reproducible scenario; verified bottlenecks fixed or documented; the timeline and the Logbook responsive on representative hardware (read through D10-1); no visualisation or animation dependency added without need. |
| R | Rules for every Task: claim → evidence → change → before → after → regression check in the record; unlike measurements never compared; no change without a measured problem; no architecture rewrite; no new drawing or animation dependency; scientific sampling and grids unchanged; no function lost; regression tests only where deterministic, no new timing thresholds; signing material untouched; documents in the same change; one Task per commit; verification at the Task's V1 class. |
| T1 | S10.1: each size measurement with command, build mode, ABI and device; main contributors measured; the 277 MB classified or recorded as unreproduced; the release baseline stated; nothing called large without a number. |
| T2 | S10.2: the suite committed with instructions; §Baselines with each scenario's first numbers and environment; the gate passes. |
| T3 | S10.3: the cause stated with evidence; the scenario repeated after the fix with the same setup, compared; behaviour and data unchanged (existing editor tests unchanged); a deterministic rebuild-scope test where possible. |
| T4 | S10.4: each scenario's before and after, or "measured, no change needed"; the memoization tests pass; a new cache, if any, keyed on every input with an invalidation test. |
| T5 | S10.5: the numbers recorded; ENG-11 and ENG-12 closed as measured or fixed with before and after; no semantic change (the seeder and session tests unchanged and passing); a transaction only with a migration-safe test (idempotence and catalog-version rules kept). |
| T6 | S10.6: a table of dependencies and assets with evidence; any removal measured before and after (S10.1's method) and checked on the emulator; RD-02's dependency part decided (D10-5). |
| T7 | S10.7: before and after for each option tried; `RELEASE.md` updated for any adopted change; the Stage's size record final. |
| D | D10-1 (emulator indicative, representative hardware UNVERIFIED until a device run, unlike environments not compared); D10-2 (no new budget; 16.7 ms as reference only); D10-3 (the user-relevant size is the arm64-v8a delivery and its install); D10-4 (one record); D10-5 (decided on evidence); D10-6 (the suite compiled by the gate, which never asserts on timing). |
| I | Invariants touched: the seeding semantics (S1.2: a failed row skipped, the version not recorded, retried next launch; deleted targets never resurrected; the catalog-version rules), trap 15 (errors: a new repository method maps storage errors to `StorageFailure`), trap 16 as amended (`MediaQuery` by aspect), the ViewModel/domain boundary (trap 11), trap 21 (signing). |

## Evidence and judgments

**Outcome: Stage 10 PASS.** No V4 blocker. Four non-blocking findings (S10V-01 to S10V-04) and four
notes. No production code or test was changed.

**Gate reuse (V3):** full quality gate PASS on S10.6's final inputs (`43523bb`): Encoding; Format;
Analyze (no issues); 1,838 tests, 2 expected skips; host E2E `core_loop_test.dart` (2) and
`perf_scenarios_test.dart` (1); Flutter 3.47.4 (`PROGRESS.md`, "Reusable validation evidence").
`git diff --stat 43523bb HEAD -- . ':!docs' ':!CLAUDE.md' ':!README.md'` is empty (checked before
and after the probes); `3cb67be` changed documentation only. Reused, not rerun. The counts agree with
the diffs: 1,833 at the baseline `0f09608`, +4 in S10.3 (`media_query_aspects_test.dart` 1,
`rig_editor_rebuilds_test.dart` 3), +1 in S10.5 (`catalog_seeder_transaction_test.dart`). The
emulator runs are reused as recorded (D10-1: indicative); none was repeated.

**Fresh evidence (this validation; Flutter 3.47.4; nothing committed to `lib/` or `test/`):**

| Probe | What it establishes | Result |
| --- | --- | --- |
| P1 | Targeted run: `catalog_seeder_test.dart`, `catalog_seeder_transaction_test.dart`, `test/presentation/performance/` (20 tests) | **PASS** |
| P2 | A temporary test: the M31 insert fails with a **real SQLite statement error** (a NOT NULL constraint, executed inside the seed's transaction through a `QueryInterceptor`). The seed catches it, commits the other 163 rows, records no catalog version; a second seed adds M31 and records the version | **PASS** (the S1.2 semantics hold inside the transaction; the committed tests simulate failures in Dart before SQLite, so this was not covered) |
| P3 | Mutation: `MediaQuery.sizeOf(context).width` temporarily restored to `MediaQuery.of(context).size.width`; `rig_editor_rebuilds_test.dart` fails ("Expected: <0>, Actual: <12>"); file restored with `git checkout`, `git status` clean | **PASS** (the regression test guards the fix, as the record claims) |
| P4 | `sqlite3_flutter_libs 0.6.0+eol` in the pub cache: `lib/sqlite3_flutter_libs.dart` is an empty library ("This package does not do anything"), no `android/`, `ios/` or native code; its README asks apps to remove it after `sqlite3` 3.x; `pubspec.lock` resolves `sqlite3` 3.5.2; no reference to the package outside `docs/` | **PASS** |

| Frozen item | Judgment | Evidence |
| --- | --- | --- |
| X: exit | **PASS** | Measurements: every table in the record names its command or method, build mode, ABI and device (the environment table; D10-1's evidence level in the header). Optimisations: two (S10.3, S10.5), each with host or emulator before/after (below). No functionality lost: `lib/` changed in four files only (the rig editor's width lookup, the seeder's transaction, one repository method and its interface); the dependency removed is empty (P4) and the app ran on the emulator without it. The 277 MB: classified as consistent with a debug install (314 MB measured by the same Android screen), the exact figure recorded as the owner's unreproduced observation. Release baseline: arm64-v8a APK 24.8 MB, 27.8 MB installed; contributors measured (`--analyze-size`: engine 47 %, Dart AOT 40 %, SQLite 7 %, assets 0.6 %). Form lag: investigated from S10.2's rig-editor scenario across the plan's categories. Verified bottlenecks: both fixed; raster times on the emulated GPU documented as not claimed. Timeline and Logbook: measured on the emulator in profile mode (build averages 1.7–8.1 ms) and recorded as indicative, a phone run being Stage 11's (D10-1; see S10V-04). No dependency added (the `pubspec.yaml` diff is one removal). |
| R: Task rules | **PASS** | The record has claim → evidence → change → before → after → regression check for S10.3 and S10.5, and outcome sections for S10.4, S10.6, S10.7. Unlike measurements: TASK 16.2's 66.5 MB is explicitly not treated as a before/after; S10.7 compares builds from one command (see S10V-03 for one unexplained cross-section difference). No change without a measured problem (S10.4 and S10.7 end "measured, no change"). No architecture rewrite (one interface method, below). No sampling, grid or calculation touched (`lib/domain` changed only in `target_repository.dart`'s interface). Tests: rebuild counts, a transaction count and a source scan; no timing assertion (the host run of the suite skips `watchPerformance` and asserts only non-empty results). Signing: the only `android/` change is `.gitignore` gaining `.kotlin/`; no key material in any commit. Documents: S10.3 and S10.5 updated `FEATURE_STATUS`, `ARCHITECTURE`, `CLAUDE.md`, the record and `PROGRESS`; S10.6 `FEATURE_STATUS`, `TECH_DEBT`, `PROJECT_HANDOFF`, `DECISIONS`; S10.7 `RELEASE.md`. One Task per commit (plus `80dfadd`, the gate correction, recorded under S10.2). Verification per V1: S10.3, S10.5, S10.6 each ended with a full gate; S10.1, S10.4, S10.7 are documentation only; S10.2's gate failure (two host E2E files in one run) was found by S10.3's gate and corrected in `tool/check.dart`, then passed. |
| T1: S10.1 | **PASS** | Release AAB, universal release APK, three per-ABI release APKs, the debug APK, each with its command and bytes; `--analyze-size` for arm64; installed footprint of a debug and a release build on the emulator (app, data, cache, as *Settings → Storage* reports them), with the debug data explained (`kernel_blob.bin` 118 MB). The 277 MB classified with its limits stated. Baseline stated. Nothing called large without a number ("No asset, font or image is a material contributor", with sizes). Precision: S10V-03. |
| T2: S10.2 | **PASS** (with S10V-01, S10V-02) | `integration_test/perf_scenarios_test.dart` and `test_driver/perf_driver.dart` committed; the run command, `--no-dds` and the Kotlin flag in the record; the rig editor, the planner (open, a block through its dialog, four block edits, night and target changes), Night & Moon, Weather, the Logbook at 300 sessions (open, search, a filter, an entry), seeding, ENG-11's list and the candidates have first numbers with their environment (two profile runs); `rig_editor_rebuilds_test.dart` gives the deterministic host counts. The gate passes (after `80dfadd`). The planner's "open a section" step never runs (S10V-01) and the file header's command lacks `--no-dds` (S10V-02). |
| T3: S10.3 | **PASS** | Cause: `MediaQuery.of(context).size` in the `StatefulBuilder` holding the whole form subscribed it to the keyboard inset; host count 12 of 12 keyboard frames → 0 (7,500 → 456 elements), and the test fails when the old line is restored (P3). The other categories checked and recorded (no storage or network on the path, validation only on Save, derived values measured cheap, `Form`'s own rebuilds measured cheap, the target, site and block editors have no `MediaQuery.of`). The emulator scenario repeated with the same setup, two runs each; the record says the host count is the evidence given the spread. `MediaQuery.sizeOf(context)` returns the same `size` through the `size` aspect, so the width is unchanged; no editor test changed. `media_query_aspects_test.dart` keeps `MediaQuery.of(` out of `lib/` (none left). |
| T4: S10.4 | **PASS** | "Measured, no change needed", with the emulator's frame numbers for the planner's events and the detail screens and a host rebuild probe (deleted) showing no planner section rebuilding on keyboard frames and a block edit rebuilding only the plan's sections. No cache added; `planner_memoization_test.dart` in the reused gate. Large text was not profiled separately; recorded (note N1). |
| T5: S10.5 | **PASS** | ENG-12: 11.9–14.8 s (four runs) → 1.7–2.5 s (two runs), same scenario, new database file each time. ENG-11: 48–75 ms for 300 sessions; `DriftSessionRepository.list` reads rows then `_blocksFor(ids)` once, so "no N+1" is true of the list (note N2). `catalog_seeder_test.dart` and the session tests are unchanged since `0f09608` and pass (P1, gate); idempotence, the newer-catalog, pre-8.2 upgrade and failed-insert cases among them. `catalog_seeder_transaction_test.dart`: every catalog insert inside a transaction, two transactions in all. The per-row failure path verified against a real SQLite error (P2). |
| T6: S10.6 | **PASS** | The table covers all 17 runtime dependencies with their use; assets with their references. The removal measured by S10.1's method (arm64 split APK: −12 bytes, identical native libraries, only `NOTICES.Z` differs) and the suite run on the emulator on the new build. D10-5 recorded as decided in DECISIONS E.1. The package is empty (P4). Note N3. |
| T7: S10.7 | **PASS** | `--split-debug-info` and `--split-debug-info --obfuscate` each measured against the same command's baseline; neither adopted, with the cost stated; `RELEASE.md` gains "Size" (the baseline, the option, the symbolize step) and "Build notes"; no build file changed, so no adopted change needed documenting. The record ends with the Stage's size result. |
| D: decisions | **PASS** | D10-1: the record's header and each emulator table say indicative; raster not claimed; phone runs deferred to Stage 11 (S10V-04 for the explicit carry). D10-2: frames reported against 16.7 ms as a reference; the only budget cited is TASK 10.4's (candidates 313–501 ms). D10-3: the arm64-v8a APK and its install are the baseline; the AAB total recorded but not presented as what a user receives (S10V-03 on how the arm64 figure was produced). D10-4: one record. D10-5: decided on the package's content, a build and an emulator run. D10-6: the suite runs on the host in the gate as a smoke test (one step per file) and never asserts on timing. |
| I: invariants | **PASS** | Seeding (S1.2): `insert` still catches and collects a failed row, the version is still written only when `failures` is empty, the `present` skip and the `prefs == null` guard are outside the transaction and unchanged; P2 confirms a real statement error does not abort the other rows. Trap 15: `inOneTransaction` is `_db.transaction`, and `StorageFailureInterceptor` already maps statement and `commitTransaction` errors to `StorageFailure`; `main.dart` still logs a thrown seed error and the next launch retries. Domain boundary: the new interface method exposes no Drift type (`Future<T> Function()`), and the test doubles implement it (`MockTargetRepository` runs the writes directly; `FlakyTargetRepository` delegates). Trap 16 amended in the same commit as the fix. Trap 21: untouched. |

## Findings

### S10V-01 — The suite's "open a section" step never runs, and the record lists it as a scenario

**FOLLOW-UP** (not V4 A: S10.2's planner scenario has baselines for opening, the block dialog, block
edits, the night and the target, and no Exit item depends on the missing step; not B or C: test code
only). `integration_test/perf_scenarios_test.dart` looks for `Key('section.budgetDetails')`, but
`CollapsibleSection` keys itself `Key('section.$sectionKey')` with `PlannerSections.budgetDetails =
'planner.budgetDetails'`, so the key is `section.planner.budgetDetails`. The step is guarded by
`if (section.evaluate().isNotEmpty)` and is skipped silently on every run; the record's §S10.2 table
has no `planner.section` row, while its "Scenarios" paragraph lists "a section opened". The plan's
scenario (2) also names editing a block's exposure; the suite edits only frame counts.

Direction: use `Key('section.${PlannerSections.budgetDetails}')` and fail instead of skipping when it
is missing, optionally add an exposure edit, and take the numbers with Stage 11's device run; until
then correct the record's scenario list.

### S10V-02 — The suite's own run instructions omit `--no-dds`

**FOLLOW-UP** (documentation in a test file). The header of `perf_scenarios_test.dart` gives
`flutter drive --profile -d <device> --driver=… --target=…`, while the record says `--no-dds` "is
required" (the binding cannot reach the VM service otherwise). The record's command is complete; the
file's is not. Direction: align the header with the record when S10V-01 is fixed.

### S10V-03 — The size record leaves two presentation points unexplained

**FOLLOW-UP** (precision; the conclusions stand).
- S10.7's "Today's release" arm64 APK is 25,009,082 bytes (`flutter build apk --release
  --target-platform android-arm64`), while S10.1 and S10.6's arm64 APK is 24,768,842 / 24,768,830
  bytes (`--split-per-abi`), and the Stage's result quotes 24.8 MB. The 0.24 MB difference (likely the
  other ABIs' plugin libraries, 204 KiB in S10.1's `--analyze-size` table) is not stated. S10.7's own
  comparisons use one command, so its −1.31 MB and −0.20 MB are like-for-like.
- D10-3 defines the user-relevant size as "the per-device APK split from the release AAB"; the record's
  figure is Flutter's `--split-per-abi` APK, labelled "what an arm64 phone receives". The record
  already caveats that Play's delivered and download sizes come only after an upload.

Direction: one sentence each in the record (or a bundletool split of the AAB at Stage 11's upload).

### S10V-04 — The Exit's "representative hardware" item should be carried explicitly

**FOLLOW-UP** (for the session that closes the Stage; this report does not edit `PROGRESS.md`).
D10-1 says "responsive on representative hardware" stays **UNVERIFIED** until a physical device run.
The record says emulator numbers are indicative and "a physical device run is Stage 11's", and Stage
11's scope has "low-end performance (15.2, 10.4)", but `PROGRESS.md`'s carried list names no Stage 10
device item. Direction: when closing Stage 10, record that exit item as UNVERIFIED (device) and carry
"Stage 10's scenarios on a phone in profile mode: the rig editor's focus (08 §22), the timeline, the
Logbook at 300, first-run seeding" into Stage 11.

### Notes (not findings)

- **N1 — Large text.** The amendment lists "large text" among the timeline's rendering items to be
  "measured before any change". No change was made to the timeline, and S10.4 says large-text
  rendering was not profiled; the accessibility sweep covers 200 % text for layout, not timing.
  Faithful; nothing to do unless a change is proposed.
- **N2 — ENG-11's reach.** The audit's ENG-11 named Sessions, session detail and Progress; S10.5's
  frozen scope is "the session list's queries". The detail reads one session's blocks with the same
  `_blocksFor([id])`. "Closed as measured" is correct for the list the scope names.
- **N3 — `sqlite3_flutter_libs` as a pin.** Its README notes that packages may depend on 0.6.0 so that
  the old 0.5.x build scripts cannot enter a build. With the app's dependency gone, nothing pins it;
  today no package depends on it. **DEFERRED / IMPLEMENTATION DECISION:** check `pubspec.lock` for a
  0.5.x `sqlite3_flutter_libs` at future dependency upgrades.
- **N4 — `tool/check.dart`.** The E2E steps are now discovered from `integration_test/*_test.dart`; an
  empty directory would yield no E2E step rather than a failure. Hypothetical; recorded only.

## Handoff

**Stage 10 PASS** (V7): every frozen criterion passes, the Exit items are met or recorded at the
evidence level D10-1 allows, and no V4 blocker remains. S10V-01 to S10V-04 are follow-ups and create
no Stage 10 requirement; S10V-01 and S10V-02 fit a later change to the scenario suite (at the latest
before Stage 11's device run), S10V-03 a record edit, S10V-04 the Stage's closing entry. No push
(RD-17).

**What was run:** `git log --oneline 0f09608..HEAD` and the diffs of every Stage 10 commit;
`git diff --stat 43523bb HEAD -- . ':!docs' ':!CLAUDE.md' ':!README.md'` (empty, before and after);
`flutter test --no-pub` on the probe file, `test/data/services/catalog_seeder_test.dart`,
`test/data/services/catalog_seeder_transaction_test.dart` and `test/presentation/performance/` (P1,
P2: 20 passed); the mutation run of P3; an inspection of the cached `sqlite3_flutter_libs` package
(P4). The probe file (`test/zz_probe_s10v_seeder_test.dart`) was deleted and the mutated file
restored; `git status` was clean afterwards. No emulator or device run; no full gate (reused, V3).
Documentation checks: referenced files, keys and IDs resolve; `git diff --check`.
