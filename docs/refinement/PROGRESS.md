# AstroPlan — Refinement Progress

> The compact operational state of post-roadmap refinement. Update it at every Task and Stage
> boundary (see "How to update this file" at the end). Strategy lives in
> `POST_ROADMAP_PLAN.md`, direction in `PRODUCT_DIRECTION.md`.
> **Last updated:** 2026-09-26 (S3.V1). **Stage 3 validation FAILED** at `387e54b` (committed
> `7f790df`). The owner approved the corrective Tasks S3.V1–S3.V5, one at a time. S3.V1 (S3V-01)
> is done. Next: **S3.V2**. Then a fresh independent validation; Stage 4 waits.

## Current state

**Stage 3 validation, 2026-09-26: FAIL.** See [the report](STAGE_3_VALIDATION.md)
and [reproducible probes](evidence/STAGE_3_VALIDATION_PROBES.md). Baseline gate:
1,169 tests, one expected skip, 2 host E2E; four real metadata samples and four
native JVM tests pass. Independent probes reproduce stale-review data loss,
invented provenance, ineffective sensor conflict replacement, rounding of copied
saved values, and absurd dimensions accepted as known. Required real-database
review behavior tests are also missing. No application fixes were made. Stage 4
has not started. This was a validation-only follow-up in the existing chat;
the report discloses its earlier debug/exposure contributions and device limits.

Current visibility is **Add from a photo on Equipment in all build modes**;
the two debug/exposure amendments below are historical and superseded by S3.7.

**Exposure formatting amendment, 2026-09-26 (owner, TD-066):** brought forward
from S3.7 after enabling the debug viewer. Shared `QuantityText.exposure` uses
integer reciprocal fractions within 0.5% relative error, with ≈ for approximation
(1e-12 tolerance for floating-point noise). Thus 0.04005 s → ≈1/25 s and
0.02 s → 1/50 s. Original metadata, raw rationals and calculations are unchanged.
The public workflow and M4 still belong to S3.7. Targeted formatter, metadata-row
and metadata-screen tests: 20 pass. Full quality gate passes: encoding, format,
analysis, 1,094 unit/widget tests (one expected local-sample skip) and 2 host E2E
tests. This run also includes the concurrent S3.2 tests present in the workspace.

**Debug access amendment, 2026-09-26 (owner):** Settings → Import metadata is
enabled in debug builds for Stage 3 development (`FeatureScope.metadataImport`
uses `kDebugMode`). Profile/release visibility and the planned Equipment
"Add from a photo" workflow still wait for S3.7 (ADR-018 §7). This does not
change the Stage 3 Task order or mark any import/persistence Task complete.
Verification: `dart run tool/check.dart` passes after updating the existing
visibility assertions: encoding, format, analysis, 1082 tests (1 expected
local-sample skip) and 2 host E2E tests. Hot restart/relaunch is required for
an already-running debug app to register the route.

| Item | State |
| --- | --- |
| Current strategic phase | **Post-roadmap refinement** (Stages 0–11, `POST_ROADMAP_PLAN.md`). The Master Development Roadmap is closed as a task queue; its open items are carried (`POST_ROADMAP_PLAN.md` Appendix B) |
| Current Stage | **Stage 3 — Metadata → Equipment / Device Import: In validation (FAIL).** S3V-01–S3V-06 require correction; see `STAGE_3_VALIDATION.md`. Original implementation order: S3.1 → S3.2 → S3.4 → S3.3 → S3.5 → S3.6 → S3.8 → S3.7, then S3.9/S3.10 |
| Next Stage | Stage 4 — Product Flow & Information Architecture: Not started |
| Current approved Task | None in progress |
| Next approved Task | **S3.V2 — preserve provenance (S3V-02)**; then S3.V3, S3.V4, S3.V5 (owner-approved, DECISIONS E.1) |
| Code baseline | S3.V1 (see "Completed Tasks"). Not pushed (S1.14) |
| Quality gate at the baseline | **Green after S3.V1**, 2026-09-26: Encoding, Format, Analyze, 1173 tests with 1 expected skip, 2 host E2E. Earlier, **green after S3.10**, 2026-09-26: Encoding, Format, Analyze, 1169 tests with 1 expected skip, 2 host E2E. Earlier, **green after S3.9**, 2026-09-26: Encoding, Format, Analyze, 1165 tests with 1 expected skip, 2 host E2E. Earlier, **green after S3.7**, 2026-09-26: Encoding, Format, Analyze, 1161 tests with 1 expected skip, 2 host E2E. Earlier, **green after S3.8**, 2026-09-26: Encoding, Format, Analyze, 1159 tests with 1 expected skip, 2 host E2E. Earlier, **green after S3.6**, 2026-09-26: Encoding, Format, Analyze, 1150 tests with 1 expected skip, 2 host E2E. Earlier, **green after S3.5**, 2026-09-26: Encoding, Format, Analyze, 1143 tests with 1 expected skip, 2 host E2E. Earlier, **green after S3.3**, 2026-09-26: Encoding, Format, Analyze, 1130 tests with 1 expected skip, 2 host E2E. Earlier, **green after S3.4**, 2026-09-26: Encoding, Format, Analyze, 1115 tests with 1 expected skip, 2 host E2E. Earlier, **green after S3.2**, 2026-09-26: Encoding, Format, Analyze, Test, E2E (host). The run included another session's uncommitted TD-066 edits (1094 tests); The committed state after both sessions has 1094 + 1 skip. Earlier, **green after S3.1**, 2026-09-26: Encoding, Format, Analyze; 1082 tests with 1 expected local-sample skip; 2 host E2E; the local real-sample test passes (DNG 856/856, JPEG 843, HEIC 4,051 bytes). Earlier: **green**, re-run at `0c4848b` on 2026-09-26 by the Stage 3 planning pass (same result; the local real-sample test also passes). First recorded after S2.V4, 2026-09-26: Encoding; Format (349 files, 0 changed); Analyze (no issues); 1068 tests with 1 expected local-sample skip; 2 host E2E; the local real-sample test passes (DNG 848/848, JPEG 843, HEIC 4,051 bytes); no Kotlin change since the native tests were re-run (4 pass) |
| Schema | **v18** (S3.4) |

## Stage status

Vocabulary: Not started · Planning · In progress · In validation · Complete.

| Stage | Name | Status | Opened | Closed | Stage validation |
| --- | --- | --- | --- | --- | --- |
| 0 | Refinement Baseline | Complete | 2026-09-25 | 2026-09-25 | Self-review against the Stage 0 prompt's §22 checklist (below). The prompt asks for no separate validation session |
| 1 | Verified Fixes & Clean Baseline | Complete (owner waiver) | 2026-09-25 | 2026-09-26 | **Did not pass**: independent validation failed at `4e653fb` (TD-059–TD-062, fixed), then at `c99bd7f` (TD-063, X2). The owner closed the Stage anyway: TD-063 goes to Stage 8; X2 and W1 are carried |
| 2 | Metadata Foundation | Complete (owner waiver) | 2026-09-26 | 2026-09-26 | **Did not pass independently**: it failed at `79f392c` (fixed, `ffaff57`) and at `5d8bdbb` (S2R-01/TD-067; fixed by S2.V4/S2.V5, `d8e792c`/`435b3ce`). The owner then waived a third validation (E.1, "Stage 2 closed by the owner") |
| 3 | Metadata → Equipment / Device Import | In validation | 2026-09-26 | — | **FAIL** at `387e54b`, 2026-09-26: S3V-01–S3V-06. Report: `STAGE_3_VALIDATION.md`; no application fixes in the validation |
| 4 | Product Flow & Information Architecture | Not started | — | — | — |
| 5 | Design System Foundation | Not started | — | — | — |
| 6 | Core Planner Redesign | Not started | — | — | — |
| 7 | Data Entry & Automation | Not started | — | — | — |
| 8 | Sessions / Execution / Actuals / Logbook | Not started | — | — | — |
| 9 | Secondary UX & Product Polish | Not started | — | — | — |
| 10 | Performance & Application Size | Not started | — | — | — |
| 11 | Full Validation & Beta Readiness | Not started | — | — | — |

## Completed Tasks

**2026-09-26 — S2.V1–S2.V3 (this corrective commit):** owner-authorized fixes
for S2V-01/02/03; current-state documentation debt S2V-05 reconciled. See
`STAGE_2_CORRECTIONS.md` for implementation and complete verification results.
No visibility change; S2V-04 gates and device verification limits remain open.

| Stage | Task | Date | Commit | Result |
| --- | --- | --- | --- | --- |
| 0 | Stage 0 — Refinement Baseline (documentation only) | 2026-09-25 | `652ad80` | Created `PRODUCT_DIRECTION.md`, `POST_ROADMAP_PLAN.md` and `PROGRESS.md`; archived the Stage 0 prompt in `docs/refinement/prompts/`; committed the audit reports 01–08 and the owner's post-roadmap `CLAUDE.md` governance with them |
| 1 | Stage 1 planning (documentation only): every A–F candidate re-verified at `652ad80` (none stale); RD-03 resolved; RD-05 interim decided; RD-17 included; the Task sequence S1.1–S1.15 frozen | 2026-09-25 | `1ec6e7a` | `POST_ROADMAP_PLAN.md` §5 and §8; DECISIONS E.1 "Stage 1 planning decisions" |
| 1 | S1.1 — Open-Meteo user agent (A3) | 2026-09-25 | `6a90347` | Open-Meteo requests carry `AppIdentity.userAgent`; a `MockClient` test (fails without the fix). Resolves ENG-03 = RT-07. Gate green, 897 + 2 E2E. Found: `ARCHITECTURE.md:494` and F-29's body are stale, added to S1.15 |
| 1 | S1.2 — Seeding and preference failure paths (A2, E1, E3) | 2026-09-25 | `c449c03` | `CatalogSeeder` skips ids a catalog row already holds and leaves the version unrecorded when any other insert fails, so the next launch retries (3 tests, failing before the fix); `EquipmentSeeder` re-checked, already retries; the privacy preferences failure-path test. Resolves ENG-02 = RT-02, 01 §G.7. Gate green, 901 + 2 E2E |
| 1 | S1.3 — Forecast freshness over time, resume and rollover (A1, E2) | 2026-09-25 | `2007dc5` | `NightWeatherAvailable.at` and `NightWeather.isOutdated` (domain); `NightConditionsViewModel.checkClock()`/`resumed()`; a `NightClock` widget at the app root (one-minute tick, `AppLifecycleListener`); a snapshot re-ages first; summary/opportunity caches keyed on the snapshot. 7 tests, the 04/P1 steps (the snapshot test fails without the fix). Resolves ENG-01 = SCI-01 = RT-01. Found and recorded: TD-057 (the draft's night key and an open candidates list do not follow a rollover). Gate green, 908 + 2 E2E |
| 1 | S1.4 — Night key without a site (A4) | 2026-09-25 | `db2702f` | **Scope corrected with the owner:** the planned device-zone rule broke ADR-007 §6, so the key is the default night at the default position (`SessionNightResolver`), never the UTC Y/M/D (DECISIONS E.1; plan entry annotated). `SessionPlanViewModel` resolves one `_night` for both; `today` removed; the VM stays at its 300-line cap. The 04/P4 case as a test (fails before). Resolves ENG-05 = SCI-11 = RT-06. Gate green, 909 + 2 E2E |
| 1 | S1.5 — Unsupported-database recovery (A6) | 2026-09-25 | `07d55e2` | `main.dart` probes the database before building the graph (`refusedSchemaVersion`) and shows `UnsupportedDatabaseApp`: newer data is explained and **never reset** (ADR-008 §2; plan entry annotated), below-floor data can be reset after confirmation (`resetRefusedDatabase`: close, keep `.v<N>.bak`), then the bootstrap reruns. 10 tests (real files: unchanged until confirmed, `.bak` identical, fresh DB seeds 164; the screen: wording, Cancel, a failed reset, a11y at 200 % in light and dark). **Not host-testable:** the `main.dart` wiring itself (platform plugins) — a device check for Stage 11. Resolves TASK 3.2 UI half, RT-03, TD-047 (fully). Gate green, 919 + 2 E2E |
| 1 | S1.6 — Confirm before replacing an unsaved draft (A7, interim) | 2026-09-25 | `c0bfcb7` | `CurrentSession.hasUnsavedChanges` (edits since created/opened/saved; a site change is not an edit; a failed Save or Start keeps them; a resumed draft infers it from its content); `confirmLeavingUnsavedPlan` on the planner's "+" and Duplicate, Tonight's "New session" and "Open in planner" (another session only); the last two also through `runWithFeedback`. `SessionPlanViewModel` still 300 lines. 10 tests: the flag, and each button through the real app (Cancel keeps, Discard proceeds, an untouched draft never asks, the dialog accessible at 200 % in light and dark). RT-05/UX-12 mitigated; RD-05 still open for Stage 4. Gate green, 929 + 2 E2E |
| 1 | S1.7 — One format for durations and numbers (A5, C2) | 2026-09-25 | `20eff0e` | `QuantityText` in `lib/core/utils` (the domain's fit reasons use it too): durations rounded to the minute in one form, exposures without .0 (and no longer rounded to whole seconds in four screens), typographic minus, "3 %"; the three duration formatters delegate or are gone; `totalIntegrationTime` removed; RA/Dec in the session detail as h:m:s / d:m:s. 6 unit tests plus assertions in 4 widget tests (3 updated to the new strings). Resolves ENG-06, UX-19 (IA-independent part). Gate green, 935 + 2 E2E |
| 1 | S1.8 — Visible text defects and labels (C1, C4, B2, B7/SCI-05) | 2026-09-25 | `b03dda9` | Session detail: "f/5.6", "None recorded.", the night key as "Night span"; Settings' overhead note corrected; the candidates footer and frame fill (`CapabilityText.frameFillOf`); the add-block helper wraps; the sky card names both Bortle entry points; "ISO / gain (for your records)". 1 new test plus assertions in 5 widget tests (the candidates test now seeds the default rig so its rows carry a frame fill; the sky-card string updated). Resolves UX-20, UX-18 (IA-independent part), SCI-05, SCI-06. Gate green, 936 + 2 E2E |
| 1 | S1.9 — Fit status colours and the missing-input state (C3) | 2026-09-25 | `705b764` | `AppPalette.caution` in all three palettes (light #9A5B00, AA; dark orange 300; field the primary red) for "Tight"; `FitState.needsInput` (`FitAnalyzer.analyze(inputMissing:)`, set by the VM when the site or target is missing) drawn neutral; a real no-window night stays red. 7 tests (domain states, the VM with no site / no target / a never-rising target, colours and AA contrast in light and dark); the field red-only check covers the token. Resolves UX-16, UX-15(2). Gate green, 943 + 2 E2E |
| 1 | S1.10 — Weather strip at 200 % text; a forecast in the sweep (D1, D2) | 2026-09-25 | `642b235` | The sweep's weather fake serves a full forecast; with it the sweep failed on the old strip (94 px and 222 px overflows, demonstrated), and passes after the fix: no fixed 130 px height (`IntrinsicHeight` in a horizontal scroll), columns widen with the text size, an 8 px label–value gap. A test keeps the forecast on screen and checks the gap (fails before). Resolves UX-31, UX-32. Gate green, 944 + 2 E2E |
| 1 | S1.11 — Tracker controls expose a tap action (D3) | 2026-09-25 | `b0998c6` | **Verified first:** a semantics test showed `run.plus` (and the others) had no tap action and no enabled state. Fixed: the relabelling `Semantics` passes `onTap: onPressed` and `enabled`. The test checks all seven controls and that a semantics tap confirms a frame; fails before. Resolves UX-28 on the host; TalkBack remains a Stage 11 device check. Gate green, 945 + 2 E2E |
| 1 | S1.12 — Save/Start against the autosave chain (F) | 2026-09-25 | `b6fb6c3` | UI-driven test, no injected delays: Save then an edit **did not reproduce** (kept as a regression test); Start then an edit **reproduced** (the edit landed in the session being started). Fixed: Save and Start run inside the chain (`CurrentSession._inChain`). Found and recorded: TD-058 (New/Duplicate/Open, same pattern). Resolves ENG-08 = RT-04. Gate green, 947 + 2 E2E |
| 1 | S1.13 — Scientific labels and documentation (B1, B3, B4, B6, B7/SCI-04) | 2026-09-25 | `f179013` | SCI-02: "Chance of precipitation (preceding hour)" plus a note under the hour strip, CALC-32 corrected. SCI-09: night-level Moon illumination "at midnight" (Tonight, sky card, window annotations). SCI-03: documented in CALC-28/29 (no displayed text claimed they coincide). SCI-04: accepted as documented in SI-009 and CALC-08 (RD-03). B6: the CALC-01 to 06 tests cite Meeus or the definition, and CALC-03 gained a direct test. No calculation changed. Gate green, 948 + 2 E2E |
| 1 | S1.14 — Push CI and observe a first run (RD-17) | 2026-09-25 | `28aaa10` (documentation only) | **Deferred by the owner** when asked before the push. Checked: 155 commits ahead as a fast-forward; the remote is public; no secret file tracked; the workflow pins the local Flutter version. Nothing pushed; RD-17 open again (Stage 11 or on request) |
| 1 | S1.15 — Documentation drift (B5; SCI-10 docs) | 2026-09-25 | `4e653fb` | Corrected, each marked "corrected S1.15" with the old text kept: `optical_calculator.dart` comments (NPF shown; √N is noise, not signal); SI-001/002/003/008/009 statuses (index and sections); CALC-07, CALC-17, CALC-28 and, found here, CALC-13; DEV-P2 ("SNR" appears in four doc comments, none user-facing; DEV-P2 resolved) and the ADR-005 conformance row; F-29 (current state), F-46/F-49 summary rows, F-49 and TD-046 (a public remote exists, never pushed since `a1bcbd9`, S1.14 deferred), F-50's app id; TEST_PLAN L3; `ARCHITECTURE.md` external-services rows (Open-Meteo, Nominatim, OSM tiles) and, found here, the B9 cache note; `PROJECT_HANDOFF.md` header pointer to `docs/refinement/` and §0 marked historical; the `CLAUDE.md` device wording (owner-approved). Historical files untouched. No full re-audit was done. Gate green, 948 + 2 E2E |
| 1 | Independent Stage 1 validation (documentation and probe evidence only) | 2026-09-25 | `db94aaf` | Gate green (948 + 2 E2E), but six additional assertions reproduce TD-059–TD-062. Proposed S1.V1–S1.V4; no fixes or Stage 2 work. See `STAGE_1_VALIDATION.md` |
| 1 | S1.16 — Commit hashes in the registers (V1) and S1.17 — the field theme in the dialog's accessibility check (V2); V3 recorded under RD-05 | 2026-09-25 | `953c0d1` | Owner: "apply fixes for the remaining items to complete Stage 1". 37 `S1.x` stamps in `ARCHITECTURE.md`, `DATA_MODEL.md`, `FEATURE_STATUS.md` and `SCIENTIFIC_INTEGRITY.md`, TD-047, TD-057 and TD-058 cite their commits; the "Discard unsaved changes?" dialog is checked in the light, dark and field themes (contrast not in field, as in the sweep); V3 added to RD-05 (`POST_ROADMAP_PLAN.md` §8). Gate green, 949 + 2 E2E |
| 1 | S1.V1 — Recognize refusal through the production database connection (TD-059) | 2026-09-25 | `3067658` | `refusedSchemaVersion` unwraps `DriftRemoteException` (its `remoteCause` is the typed refusal on the same-group background isolate); the connection builder is shared (`openDatabaseConnection`). 5 tests through that connection; the refusal tests failed before the fix (the exception escaped). Gate green, 954 + 2 E2E |
| 1 | S1.V2 — Seed the replacement database after a confirmed reset (TD-060) | 2026-09-25 | `b34c9ad` | `confirmDatabaseReset` (refuse newer, forget only the catalog seed marker, keep the old file) replaces the bare rename in `main.dart`. 3 tests through the production connection, with and without the marker, other preferences kept; with the S1.5 behaviour the with-marker test gave 0 targets instead of 164. Stale id-holding preferences after a reset left with TD-056/ENG-14. Gate green, 957 + 2 E2E |
| 1 | S1.V3 — Keep the unsaved-plan safeguard across a restart (TD-061) | 2026-09-25 | `ed628f8` | `CurrentSession` remembers the edited session id through `PlannerStateRepository` (preference `editedSessionId`; no schema change; a site change still not an edit). 5 new tests plus a restart check on the failed-Save test: target-, rig-, night- and block-only edits protected after a restart (target, rig and night failed before), Save clears it, an untouched draft never asks. Cancel's navigation clarified (closes the dialog, stays put). Gate green, 962 + 2 E2E |
| 1 | S1.V4 — Reopening the current session keeps its live plan (TD-062) | 2026-09-25 | `ea65231` | `openSession` returns early for the current, editable session. The validation's probe as a UI test through the detail page, a Save and a restart (20 instead of 7 frames before the fix). A first version also skipped frozen sessions; two existing tests caught it and the guard was narrowed to editable sessions. Gate green, 963 + 2 E2E |
| 1 | Fast re-validation after S1.V1–S1.V4 (same session, owner's request; **not independent**) | 2026-09-26 | `c99bd7f` | At `ea65231`: gate green (963 + 2 E2E), clean tree. Throwaway probes: the reset as `main.dart` runs it with a leftover marker → 164 targets, 1 rig, `.bak` kept; edit → New → restart and edit → Start → restart leave nothing unsaved and the run untouched. One low finding **W1**: a Duplicate of an edited plan counts as saved in-session but unsaved after a restart, so New right after Duplicate replaces the copy without asking (the saved original remains; only the copy's night is lost). Proposed: record under RD-05, like V3. Stage 1 still needs an **independent** validation to close |
| 1 | Repeat independent Stage 1 validation (documentation and probe evidence only) | 2026-09-26 | `39392d9` | Fresh session at `c99bd7f`: gate green (963 + 2 E2E); S1.V1–S1.V4 and S1.16/S1.17 pass their acceptance; no test weakened; no scope drift. **Does not pass:** TD-063 was reproduced through the UI (a detail page loaded before Start reopens the running session as the planner's plan, and every autosave is then refused), and X2 (the registers still say S1.5/S1.6 are broken, and the S1.V stamps cite no commit). W1 confirmed. Proposed S1.V5 and S1.V6. See `STAGE_1_REVALIDATION.md` and `evidence/STAGE_1_REVALIDATION_PROBES.patch` |
| 1–2 | Stage 1 closed by the owner, and Stage 2 planning (documentation only) | 2026-09-26 | `565341b` | The owner said "lets go to stage 2" after the re-validation failed. Recorded as a waiver (DECISIONS E.1): TD-063 moved to Stage 8, X2 and W1 carried. Stage 2: TD-018's mechanisms were re-verified at `39392d9` (all still present); six planning-time findings were placed; S2.R1 is frozen and S2.1–S2.6 are provisional (`POST_ROADMAP_PLAN.md`) |
| 2 | S2.R1 — RG-01: formats, libraries, file selection, fixtures (research, documentation only) | 2026-09-26 | `d4b2be4` | The owner's two phone DNGs (Xiaomi, DNG 1.4, 25 MB each; kept outside the repository) were inspected. All their metadata sits in IFD0 within the first 6.7 KB. They have no GPS and no time offset, and the same Model for both cameras (input for RG-02). The prototype finds 0 of 5 capture fields in them (TD-064). Sources read: `exif` 3.3.0 (MIT; TIFF, JPEG and HEIC; no byte-budget API); `file_picker` 13.1.0 / `android_file_picker` 2.0.0 (copies every file whole into the cache; the extension filter drops unknown MIME types; TD-065); the FITS 4.0 standard (`CONTINUE` is standard, `''` escapes, `DATE-OBS` is UTC at the start); XISF 1.0 (focal length in metres, gain in e⁻/DN); N.I.N.A.'s documented keywords (FOCALLEN is user-entered). Recommended: DNG/TIFF now, FITS on a sample, in-house bounded readers, the `exif` and `image_picker` dependencies removed, no GPS or serials, header-only fixtures with consent, the feature hidden until Stage 3. Proposed ADR-017 |
| 2 | RG-01 decided by the owner; ADR-017; Stage 2 frozen (documentation only) | 2026-09-26 | `96454d8` | The owner approved the direction with constraints. Decided: DNG only, and FITS only with a real sample; bounded reads recognised by signature; the approved contract's fields only; Unknown and provenance kept; no GPS, serials or observer; no inferred zone; the owner's slices never committed (synthetic, sanitized fixtures; the real files stay local); the UI hidden in Stage 2; no Equipment writes; TD-065 is in scope. ADR-017 written (Part F), including the justified removal of `exif` and `image_picker` (both copy or read whole files; each has one use). Verified: `image_picker_android` 0.8.13+23 also copies every pick into the cache, and offers images only. Stage 3 evidence recorded (identical Model across the phone's cameras). S2.1–S2.6 frozen. New blocker: no Android device or emulator can run S2.4's native path |
| 2 | S2.1 — Bounded metadata source and format recognition | 2026-09-26 | `a25398c` | `lib/domain/metadata/`: `MetadataSource`, `BudgetedMetadataSource` (1 MiB per file, 64 KiB per read, a read log, refused reads cost nothing), typed `MetadataReadException`, and `MetadataFormatRecognizer` (TIFF, FITS, XISF and JPEG by signature, ≤ 16 bytes). `lib/data/metadata/file_metadata_source.dart`: positioned, serialized reads, with short reads typed. 17 tests: the budget, limits and ranges, wrapping and short reads; signatures and near misses; a real 4 GiB file recognised and read at both ends with ≤ 64 KiB read; the domain purity check, which fails on a domain `dart:io` import (demonstrated with a temporary file, removed) and allows only the prototype until S2.5. Gate green, 980 + 2 E2E |
| 2 | S2.2 — The metadata contract as typed values with provenance | 2026-09-26 | `b8d626a` | Pure Dart. `MetadataValue<T>`: `KnownValue` (value, raw text, origin with format, tag, location and provenance), `AbsentValue`, `UnparseableValue` and `AmbiguousValue`; `combine` keeps agreeing values and marks conflicts ambiguous. `CaptureMetadata` has the 11 contract fields, all absent by default. `MetadataReading`, with its unreadable reasons. `ExifValues`: exact rationals; the 35 mm equivalent kept separate (0 = absent); sensitivity with its kind (SensitivityType 1–3, otherwise unspecified; 0 and 65535 unparseable); capture time as local wall-clock plus an offset only if recorded, otherwise zone unknown with no instant. CALC-39 and an SI-004 note were added. The tests use synthetic timestamps only. 15 tests. Gate green, 995 + 2 E2E |
| 2 | S2.3 — DNG/TIFF reader, with synthetic fixtures and local real-sample validation | 2026-09-26 | `59c9f03` | `TiffMetadataReader`: IFD0 and the EXIF IFD, contract tags only; the GPS IFD, sub-IFDs, MakerNotes, serials and pixels are never followed. Bounds, entry, repeat and loop checks; one bad value makes only that field unparseable; no DNGVersion → unsupported. `CaptureMetadataReader` recognises, then dispatches; `MetadataFormat.dng` added. Synthetic fixture builder, including a sanitized layout like the phone files. 13 reader tests: phone-style, big-endian, EXIF-IFD with an offset, agreement and ambiguity, GPS and serials never read (read log), non-DNG, other formats, truncated, corrupt, budget, bad single values, every truncation up to 1,200 bytes plus 500 seeded corruptions. **Real samples (local, `ASTROPLAN_METADATA_SAMPLES`):** both owner DNGs gave every expected contract value, reading 848 bytes in 11 reads of about 25 MB each (values kept outside the repository). Gate green, 1008 + 1 skipped (the real-sample test) + 2 E2E |
| 2 | S2.4 — Android document access without a copy; picker cache ownership (TD-065) | 2026-09-26 | `26aff9a` | **Implemented, not accepted (device check pending).** `MetadataDocumentChannel.kt` (registered in `MainActivity`): `ACTION_OPEN_DOCUMENT` with no copy; positioned reads on the provider's descriptor; a sequential fallback within 1 MiB for descriptors that cannot seek; a background thread; no persistable grant. Domain `CaptureFileAccess`/`CaptureFile`; data `AndroidCaptureFileAccess` and `ContentUriMetadataSource` with typed failures. TD-065: `FileBackupService.pick` always clears the picker cache (it is injectable; a failed cleanup is logged). 8 tests (5 channel tests against a host stand-in, 3 cleanup tests). The debug APK builds (the Kotlin compiles). TEST_PLAN gains device rows M1 and M2, not run. Gate green, 1016 + 1 skipped + 2 E2E |
| 2 | S2.5 — The hidden import screen on the foundation; the prototype, `exif` and `image_picker` removed | 2026-09-26 | `a2f42a5` | **Implemented; device check M1 pending (with S2.4).** `MetadataImportViewModel` (domain `CaptureFileAccess` only) → `CaptureMetadataReader`; the screen shows every contract row with its unit and source, and unknown, unreadable or conflicting values as such (`metadata_text.dart`). `main.dart` wires Android only; elsewhere "not available". The prototype extractor, `ImageMetadata` and their 2 tests are removed (plus the purity test's allowance test); `exif` and `image_picker` were removed after a `grep` showed no other use (the lock lost 15 packages, nothing else changed; the desktop registrants lost `file_selector`). The gate stays hidden. Privacy and Data Safety were checked: no change (nothing leaves the device). 11 tests (6 screen tests, including a11y at 200 %; 5 wording tests). The debug APK builds. TD-018 and TD-064 resolved. Gate green, 1024 + 1 skipped + 2 E2E |
| 2 | Review of S2.1–S2.5 against the owner's format priorities (documentation only) | 2026-09-26 | `9f7310d` | The owner's direction: one common typed, provenance-aware contract for many formats; the priorities DNG, JPEG, HEIC/HEIF, FITS on a sample, PNG where meaningful, proprietary RAW through research only (no ad hoc parsers), XISF sample-driven; three distinct levels (recognition, extraction, equipment evidence); no decoders or RAW framework. Review (`STAGE_2_ARCHITECTURE_REVIEW.md`): the contract, values, provenance, bounds, privacy and no-write rules already fit; no defect. Gaps: G1 EXIF parsing fused with the DNG container (header at byte 0, format hardcoded); G2 closed dispatch; G3 recognition and extraction share one result; G4 HEIF, PNG, CR2, CR3, RAF, RW2 and ORF are not recognised; G5 EXIF conversions in the contract file; G6 no generic optics identity (for FITS). Recorded: DECISIONS E.1 and ADR-017 §13 (supersedes the §8 list); RG-14; S2.7, S2.8, S2.R2, S2.R3 frozen; S2.9 and S2.10 conditional; the Stage 2 exit amended |
| 2 | S2.7 — Layered recognition and a reusable EXIF extractor | 2026-09-26 | `9a0432b` | A refactor, closing review gaps G1–G5. `ExifStructure` (IFD0 + the EXIF IFD, the same rules), used on any source; `MetadataSourceWindow` for embedded structures; origins labelled by container; `DngMetadataReader` as a thin container; `MetadataFormatReader` with dispatch by registration; recognition (`reading.format`) kept apart from extraction (the subclass), with `nothingFound`, `recognized` and the format on unreadable readings; recognition-only HEIF, PNG, CR2, CR3, RAF, RW2 and ORF; `ExifValues` moved to `exif_values.dart`. **No DNG behaviour change:** every existing metadata test passes with its assertions unchanged (one import added), the synthetic read log is byte-identical to a baseline captured before the change, and the real samples still read 848 bytes. 10 new tests. Gate green, 1034 + 1 skipped + 2 E2E |
| 2 | S2.R2 — HEIC/HEIF metadata research (documentation only), and the owner's FITS/PNG skip | 2026-09-26 | `5cc23a8` | The owner supplied a phone HEIC and JPEG (outside the repository) and skipped FITS and PNG (DECISIONS E.1): S2.6 and S2.10 leave Stage 2, and both formats stay recognised only. HEIC findings (`research/S2.R2_HEIF_METADATA.md`): `meta` in the first 3.2 KB; the Exif item (linked to the primary by `iref cdsc`) sits at the **end** of the file (97 %), so random access is needed and a non-seekable provider hits the budget (typed); its payload skips a JPEG APP1 header through `exif_tiff_header_offset` = 10; the same EXIF structure as the JPEG, with `OffsetTimeOriginal` +03:00; no GPS, no serials. JPEG: APP1 Exif at byte 2, the metadata within 1.8 KB, SOS at 1.3 %. Stage 3 evidence: Model differs by format for the same phone (DNG `…/2407FPN8EG`, JPEG/HEIC `Xiaomi 14T Pro`); the offset is recorded in JPEG/HEIC, not DNG. Recommended: option A, an in-house box walker → `ExifStructure` (S2.9 defined in §7). Owner decision pending |
| 2 | S2.8 — JPEG reader | 2026-09-26 | `360fd8f` | `JpegMetadataReader`: a bounded marker walk (fill bytes; stops at SOS or EOI; a bad marker, a zero length, a second SOI or more than 128 segments is corrupt) → the APP1 `Exif` segment → the shared `ExifStructure` through a window (origins "APP1 …"); no scan data read; no Exif = "nothing found". Registered in `readers`. Synthetic `jpeg_fixture.dart`; 8 tests (phone-style values with the offset, bounded reads, the GPS IFD never followed, segments before Exif, no Exif, truncated and corrupt, a corrupt EXIF inside APP1, every third truncation plus 500 seeded corruptions). One earlier assertion ("JPEG is unsupported") became a HEIF case, since JPEG now has a reader. **Real sample (local):** the owner's phone JPEG gives every expected value, including a UTC time, reading 843 bytes of 4.7 MB; the DNGs are unchanged (848). Gate green, 1042 + 1 skipped + 2 E2E |
| 2 | Device checks M1 and M2 (S2.4 and S2.5 accepted) | 2026-09-26 | `79f392c` | On the owner's Xiaomi 14T Pro (Android 16, API 36), over USB, at `360fd8f`. A separate debug package (`…astroplanner.s2check`) was used; the gate flip and application id suffix were local and reverted, so the owner's installed app and data were untouched. **M1:** both DNGs and the phone JPEG, picked through the system picker, gave every expected value; the HEIC said "not supported yet"; the app cache stayed empty (4 KB) after every pick; a cancel changed nothing. **M2:** a 25 MB DNG through Restore was refused with its message, and the cache was empty right after; so was a cancelled restore. Not run: the non-seekable (cloud) path, which would need uploading owner files; a real backup's preview cancel. Found: TD-066 (a 1/100 s exposure prints as "0.009987236 s"). Afterwards the test package, the copied DNGs and the UI dump were removed from the phone. An Android device is now available, including for Stage 11's device rows |
| 2 | Independent Stage 2 validation (another session) and S2.V1–S2.V3 corrections | 2026-09-26 | `ffaff57` | Validation at `79f392c` **failed** (`STAGE_2_VALIDATION.md`): S2V-01 (a SHORT/LONG pointer reported as a value), S2V-02 (a short JPEG EXIF reported as nothing found), S2V-03 (non-seekable reads not charged cumulatively), S2V-04 (S2.9/S2.R3 open), S2V-05 (stale docs). The owner authorized S2.V1–S2.V3 (`STAGE_2_CORRECTIONS.md`): strict integer counts, the Exif id checked as soon as it fits, and streaming budgets charged natively (`MetadataSequentialReader`, 4 JVM tests). Gate green, 1052 + 1 skipped + 2 E2E (row added by S2.9, which found it recorded only in prose) |
| 2 | S2.9 — HEIC/HEIF reader | 2026-09-26 | `bb28452` | The owner approved S2.R2 §7 ("You can"). `HeifMetadataReader`: walks the top-level boxes by header only; reads `meta` once (≤ 64 KiB, else overBudget); parses `pitm`, `iinf`/`infe` (v2–3), `iloc` (v0–2; field sizes 0/4/8; construction methods 0 and 1; another file never followed) and `iref cdsc`, each bounded by its box; takes the Exif item linked to the primary item, else the only one, else combines all (conflicts ambiguous); honours `exif_tiff_header_offset` (Xiaomi's APP1 prefix) and hands the rest to the shared `ExifStructure` (origin "Exif item …"); refuses several extents or method 2 as corrupt; an extent or TIFF past its end is truncated, never "nothing found"; no image data is read. Registered in `readers`. Synthetic `heif_fixture.dart`; 10 tests (phone layout with the APP1 prefix, six variants, item choice, no Exif, truncated/corrupt/oversized cases, a truncation sweep proving a cut file never reads complete, 500 seeded corruptions). Two earlier cases that listed HEIF as reader-less now use CR3. **Real sample (local):** the owner's HEIC gives every expected value with its UTC offset, reading 4,051 bytes of 1.9 MB; DNG/JPEG unchanged (848, 848, 843). The device check M3 could not run (the phone disconnected; the local test package changes were reverted unused). Gate green, 1062 + 1 skipped + 2 E2E |
| 2 | Device check M3 (HEIC on the phone) | 2026-09-26 | `237c55f` | At `3a23391`, on the owner's Xiaomi 14T Pro (Android 16), through a separate `.s2check` debug package (local changes reverted before install; package removed afterwards): the HEIC gave every expected value with UTC+03:00; the JPEG, re-read under the S2.V3 channel protocol (`ffaff57`), was unchanged; the cache stayed empty. Observed, not caused by this check: the owner's own `io.github.chacha12.astroplanner` shows lastUpdateTime 2026-09-26 09:24:47 (it was 2026-09-25 16:18 earlier the same day); this session installed only `.s2check` |
| 2 | S2.R3 — RG-14: proprietary RAW compatibility and library research (documentation only) | 2026-09-26 | `e444bfa` | `research/S2.R3_RG14_PROPRIETARY_RAW.md`. Verified: AndroidX `ExifInterface` reads DNG, CR2, NEF, NRW, ARW, RW2, ORF, PEF, SRW and RAF (not CR3), with no documented read bound and its own GPS parsing; LibRaw is a decoder (LGPL-2.1/CDDL-1.0). Documented by reverse engineering: RAF's header points to an embedded JPEG holding the EXIF (libopenraw); CR3 keeps IFD0 and the EXIF IFD as TIFF structures in `moov`/`uuid` CMT1/CMT2, with GPS in CMT4 (lclevy). No proprietary RAW sample exists. Recommended: D (recognised only) to close Stage 2; A (container adapters over the shared extractor, one per format, only with a real sample: RAF, then CR2/NEF/ARW, ORF/RW2, CR3 last) afterwards; reject B (`ExifInterface`: unbounded and unprovable reads, a second path) and C (LibRaw: a decoder). Owner decision pending |
| 2 | RG-14 decided by the owner; Stage 2 ready for validation (documentation only) | 2026-09-26 | `5d8bdbb` | The owner chose the recommendation, when asked which "second scenario" was meant: no proprietary RAW in Stage 2 (D); afterwards, per-format adapters over the shared extractor, each only with a real sample (A, in the order RAF → CR2/NEF/ARW → ORF/RW2 → CR3); `ExifInterface` (B) and LibRaw (C) rejected. Stage 2 closes by the repeat independent validation, not a waiver (the owner's choice). The owner's RAW formats are still unknown. Recorded in DECISIONS E.1, ADR-017's status and the plan's post-Stage-2 list |

| 2 | Repeat independent Stage 2 validation (documentation and probe evidence only) | 2026-09-26 | `f137409` | A fresh session at `5d8bdbb`: the gate is green on the clean tree; the real samples pass (DNG 848/848, JPEG 843, HEIC 4,051 bytes); the native JVM tests were re-run (4 pass). S2V-01 to S2V-04 are resolved, and HEIF inherits the fixes (probes P2–P4). **Fails on S2R-01 (TD-067):** a crafted `iloc` with zero-size fields makes the HEIF reader allocate about 1.7 GB in 9–17 s from an 8 KB `meta`, on the UI isolate (probe P1). Low: S2R-02 (AVIF and sequence brands go to the HEIF reader without a sample, and a sequence-only file reads as "corrupt"), S2R-03 (stale F-45 and `TEST_PLAN.md` text), S2R-04 (HEIF test gaps). No code or test changed; the probes were deleted, and their code is in `evidence/STAGE_2_REVALIDATION_PROBES.md`. See `STAGE_2_REVALIDATION.md` |

| 2 | S2.V4 — Bound the HEIF `iloc` work; AVIF and HEIF sequences recognised only; HEIF test gaps | 2026-09-26 | `d8e792c` | The owner said "Do fix"; S2R-02 was taken as the recommended option (a) (DECISIONS E.1). **TD-067 resolved:** `maxExtents` = 16,384 over all items → `corrupt`. New `MetadataFormat.avif` and `heifSequence`, both recognised only and named in `MetadataText`. There are 6 new HEIF tests: the bound (fails on the old reader), the limit, GPS never read, S2V-01, S2V-02, and the brands. One assertion in `metadata_layers_test.dart` changed because of the ruling (`avif` and `msf1` were HEIF). The real samples are unchanged. Gate green (Encoding; Format (349 files, 0 changed); Analyze (no issues); 1068 tests with 1 expected local-sample skip; 2 host E2E). See `STAGE_2_CORRECTIONS.md` |
| 2 | S2.V5 — Documentation reconciliation (S2R-03) | 2026-09-26 | `435b3ce` | F-45's current-implementation and known-issues text, and `TEST_PLAN.md`'s "no device" note, are corrected with the old text quoted. Also updated: `ARCHITECTURE.md` B, ADR-017's note, E.1, TD-067, `POST_ROADMAP_PLAN.md` (the corrective-Task table) and this file |

| 1 | S1.V6 — Stage 1 registers brought up to date (X2; documentation only) | 2026-09-26 | `3dd2598` | Run at the owner's request ("wrap up the important issues" before Stage 3). The validation banners and notes that called S1.5 broken and S1.6 partial are marked superseded, with the old text kept: `FEATURE_STATUS.md` (banner, F-02, F-40), `ARCHITECTURE.md` (banner, B3, B4), `DATA_MODEL.md` (banner, B8) and `TECH_DEBT.md` (banners). TD-047 is closed again. The S1.V1–S1.V4 stamps (8) and TD-059–TD-062 cite `3067658`, `b34c9ad`, `ed628f8` and `ea65231` (each checked with `git log`). No code changed. TD-063 stays in Stage 8, and W1 stays with RD-05 |

| 2–3 | Stage 2 closed by the owner, and Stage 3 planning (documentation only) | 2026-09-26 | `0c4848b` | Asked to choose between a fresh-session validation and a waiver, the owner chose "Waive and go to Stage 3". Recorded as a waiver (E.1). Stage 3 planning at `3dd2598` verified nine facts (`POST_ROADMAP_PLAN.md`, "Verified at planning"). The key one: `EquipmentProfile` and its columns require sensor size, resolution, pixel pitch, focal length and focal ratio, and the metadata contract has no image dimensions, so an import cannot store a rig without invented values. Frozen: S3.R1 (RG-02), S3.R2 (RG-03), S3.D (decisions, ADR-018). Provisional: S3.1–S3.6 |

| 3 | Stage 3 second planning pass, including S3.R1 (RG-02) (documentation only) | 2026-09-26 | `4c46f8f` | From the owner's Stage 3 planning prompt. Verified the Stage 2 foundation at `0c4848b` (gate green; the local real samples pass; no stale claim, except this file's missing `0c4848b`). `research/RG-02_EQUIPMENT_IDENTITY.md`: field classification, derivability matrix, device classes, matching and conflict outcomes, provenance and confirmation, storage options, decisions D1–D4. A throwaway probe (deleted) found that the pixel dimensions are in all four samples (swapped in the portrait JPEG/HEIC) and that no focal-plane tags exist. Refined sequence S3.1–S3.9, provisional; recommended D1 = A1 (complete before saving, with an estimate offered) |

| 3 | S3.D — owner decisions D1–D4; ADR-018; Stage 3 frozen (documentation only) | 2026-09-26 | `792b295` | The owner chose the recommended option for each decision (asked in this session): **D1 = A1** (the import pre-fills the editor, a rig is saved only when complete, and the CALC-40 sensor/pixel estimate is offered as `estimated`); **D2**: RG-03 deferred (S3.R2 and S3.9 leave Stage 3); **D3**: visible at the end of Stage 3, as "Add from a photo" on the equipment screen (RD-16 resolved); **D4**: a DNG pick's file length as the estimated RAW size. ADR-018 accepted: it amends ADR-017 §2 with image dimensions and applies ADR-008 §6 per field to equipment (schema v18). DECISIONS E.1 "Stage 3 decisions (S3.D)". S3.1–S3.8 frozen |

| 3 | S3.1 — Image geometry in the metadata contract (ADR-018 §3) | 2026-09-26 | `60ec4db` | `CaptureMetadata.imageDimensions` (`ImageDimensions`, with long/short sides; orientation not interpreted). `ExifStructure` reads it: DNG from IFD0's main image only (`NewSubfileType` 0 or absent; `DefaultCropSize` when whole, else `ImageWidth`/`ImageLength`; sub-IFDs never followed); JPEG/HEIC from `PixelX/YDimension` combined with IFD0 (disagreement ambiguous). The hidden screen gains an "Image size" row. 14 new tests (`image_dimensions_test.dart`: the DNG rules, crop types, fallbacks, malformed values, a preview IFD0, the JPEG/HEIC rules, wrong-IFD tags, and GPS never read; `metadata_text_test.dart`: the row, and the row count now follows the contract, 11 → 12). **Local real samples:** the DNG crop sizes (checked against an independent Python walk, deleted), and the JPEG/HEIC portrait sizes, were added to `expected.json` outside Git and pass. Each DNG reads 856 bytes (+8). CALC-39, F-45, ARCHITECTURE B, ADR-017/018 status updated. Gate green, 1082 + 1 skip + 2 E2E |

| 3 | S3.2 — Equipment evidence and candidate, with CALC-40 (ADR-018 §4) | 2026-09-26 | **`7560df2`** (the content) and `e9a9d87` (empty) | **Where it landed:** the concurrent TD-066 session committed the shared index while S3.2's files were staged, so S3.2's code, tests and docs are in `7560df2` ("fix: format short exposures as shutter fractions"). `e9a9d87` carries the S3.2 message with no changes. No history was rewritten; the content was checked to be complete in HEAD. Pure domain code in `lib/domain/equipment_import/`, with no UI and no write. `EquipmentCandidate.fromReading`: per field, `ProposedField` (value, source `metadata:<format>` or `derived:calc-40/metadata:<format>`, `reported`/`estimated`, origins) or `UnknownField` (not in file, unreadable, conflicting, out of range, not estimable, never from metadata). Labels come from Make/Model; resolution uses the long side as the width; the aperture diameter, rotation, tracking and maximum exposure are never proposed; the RAW size waits for S3.8. It also carries a suggested name, `EquipmentEvidence` for S3.3, and `hasEnoughEvidence`. `SensorGeometryEstimate` is CALC-40, registered in `SCIENTIFIC_INTEGRITY.md`. As the ADR requires, there is no estimate when f₃₅ ≤ f, so full-frame bodies get none. 11 tests, with expected values computed independently. **Concurrent work noticed:** another session committed `23b962c` (the owner's debug-build metadata viewer) during this Task, and left TD-066 edits uncommitted; S3.2 commits only its own changes. Gate green |

| 3 | S3.4 — Per-field provenance and identity evidence, schema v18 (ADR-018 §5) | 2026-09-26 | `1af68e4` | 14 additive nullable columns: source/confidence pairs for resolution, pixel pitch, sensor size and RAW size, plus `metadata_make` and `metadata_model`, on `camera_modules`; pairs for focal length and focal ratio on `optical_rigs`. Nothing is back-filled. The Drift workflow was followed (v18 snapshot, generated verification and steps; `from17To18` against the step's shapes). Domain: `EquipmentSpec` and `SpecProvenance`; `EquipmentProfile.specProvenance`, `metadataMake/Model` and `provenanceOf` (own pair → group → unknown); `withEditProvenance` per field, which pins the group's old provenance on untouched specs when their group changes (a verified value stays verified), keeps given pairs, and keeps the identity. The repository maps the new columns. The manual editor is unchanged (its tests are not modified). 21 new tests: every version v8–v17 → v18 against the snapshot; v17 → v18 keeps values and group provenance with no own pairs; a legacy rig stays unknown; 8 domain rules; a repository round-trip through a manual edit. **Four existing tests changed** only because they hardcoded the current schema: the backup header now expects 18, and the "newer than the app" example is 19. Session snapshots keep only group provenance. Gate green, 1115 + 1 skip + 2 E2E |

| 3 | S3.3 — Matching saved rigs, with conflicts (ADR-018 §6) | 2026-09-26 | `0e5b93e` | `EquipmentMatcher` is pure domain code with no write. It gives six outcomes (`MatchKind`) with `MatchReason`s, per-field `FieldConflict`s (both provenances; `savedIsVerified`) and `fillable` unknown specs. The stored import identity wins over the labels; comparison is normalised; the prefix rule uses `/`, space, `-` and `_`; f and N use a 1 % tolerance. The capture mode differs when the pixel count differs, or when the file's f₃₅ is more than 10 % from the one the rig implies (f × 43.27 ÷ the sensor diagonal; recorded as an S3.3 implementation choice in ADR-018's note, with the "Pro Max" prefix limit and the no-model rule). 15 tests, one per scenario: none; same; likely (DNG vs JPEG); normalised labels; the stored identity over renamed labels; makes; two identical bodies (ambiguous); the other phone module; a telescope body; digital zoom; a full-resolution mode; the tolerance; verified vs legacy conflicts; the seeded camera. Gate green, 1130 + 1 skip + 2 E2E |

| 3 | S3.5 — A form model for the rig editor, and pre-fill | 2026-09-26 | `9675854` | The editor's value building moved into the pure `EquipmentDraft` (`presentation/shared/equipment_draft.dart`): `fromProfile` (Add/Edit, as before), `fromCandidate` (file values, the CALC-40 estimate, or a saved rig's camera specs as `cameraFrom`), and `build` (the Save logic, moved unchanged, plus per-field provenance: a pre-filled value keeps its origin only while its text is untouched). The dialog moved from the 791-line screen into `showEquipmentEditor` (`equipment_editor.dart`, 578 lines; the screen is now 218). It shows a note under each pre-filled field; D, tracking, rotation and maximum exposure are never pre-filled. The 10 existing editor tests pass unmodified. 13 new tests: 8 form-model tests and 5 widget tests (notes shown and cleared; saved untouched keeps its origin and identity; edited pixel size and derived sensor become the user's; Cancel writes nothing; missing values block Save). `phoneCandidate` in `test/support/metadata_candidates.dart`. No entry point yet (S3.6/S3.7). Gate green, 1143 + 1 skip + 2 E2E |

| 3 | S3.6 — The import review and confirmation flow (ADR-018 §2, §6) | 2026-09-26 | `f230e6b` | `MetadataImportViewModel` now takes the `EquipmentRepository`: after a read it builds the candidate, matches it, keeps the per-field "use the file's value" choices (off by default), and gives drafts (`newRigDraft(cameraFrom:)`, `rigDraft` via the new `EquipmentDraft.forRig`). The screen gains an Equipment card above the file's values: the outcome in plain words, the reasons, conflict switches, Open / New rig / New rig with a saved rig's camera specs. Every action goes through `showEquipmentEditor`, whose Save is the only write; the match refreshes after a save, and the planner rereads an edited rig. Wording is in `equipment_import_text.dart`. Fix: an untouched sensor field now compares with the rig's stored value, not the draft's first text (needed once a file value is taken). 7 review tests (a new rig only through Save, then matched; Cancel writes nothing; same rig keeps verified values by default and creates no duplicate; a taken value arrives with its origin; another module takes the saved camera; ambiguous; no evidence proposes nothing). The accessibility sweep now includes the review, with a file matching the seeded rig (light, dark, field; 100/200 %). `InMemoryEquipmentRepository` and `PlannerHarness(captureFiles:)` are in `test/support`. Still debug-only (S3.7). The owner's phone was connected but was not needed; nothing was installed. Gate green, 1150 + 1 skip + 2 E2E |

| 3 | S3.8 — Average RAW size from a DNG pick (ADR-018 §4, D4; C-13) | 2026-09-26 | `d21a326` | `EquipmentCandidate.fromReading(read, fileLengthBytes:)`; the ViewModel passes `MetadataSource.length` (the file is still never read whole). Only for a DNG: bytes ÷ 10⁶ = MB, `estimated`, source `metadata:dng:file-size`, `EquipmentLimits.rawFileSizeMB` bounds (outside is unknown, out of range). `rigDraft` pre-fills it on a matched rig that lacks one; the review says "Average RAW file size is unknown on this rig; the file suggests …". A saved value is only an ordinary conflict, kept by default. The editor note reads "Estimated from this one file's size (DNG)". 9 tests: DNG / JPEG / HEIC / no length / out of range; matcher fillable vs conflict; draft note; review fill-through-Save, keep-by-default, JPEG never. Gate green, 1159 + 1 skip + 2 E2E |

| 3 | S3.7 — Visibility, TD-066, the device check M4 (ADR-018 §7; RD-16) | 2026-09-26 | `2b045eb` | `FeatureScope.metadataImport` = true. `AppRouter.metadata` is the root route `/equipment/import` (was `/settings/metadata`, debug-only), and the Settings entry is removed. "Add from a photo" is a small button above "Add rig" on the equipment screen; the list and the planner's rig reload on return. The screen is retitled "Add from a photo", and its intro says nothing is saved until Save. Privacy policy and Data Safety notes gained a paragraph (nothing leaves the device; still "not collected"). TD-066 verified (host tests, and "≈1/50 s" on the device). Tests: a navigation test; Settings has no entry; the gate/route tests updated to the new route; 7 editor tests now tap "Add rig" by tooltip, since there are two buttons. **Device check M4 passed** on the owner's Xiaomi 14T Pro through a separate `.s2check` package (local build change reverted; uninstalled afterwards; the owner's app untouched, its install times 20:00/20:28 predate the check): a real DNG went through match → pre-filled editor (source notes, RAW size from one file, no D or tracking) → Save → "You already have this rig" → listed; the cache stayed 4 KB. **Found:** TD-068 (rounding conflicts on re-read; S3.9 proposed) and TD-069 (clipped sensor fields; Stage 5/7). Gate green, 1161 + 1 skip + 2 E2E |

| 3 | S3.9 — No rounding conflicts on re-reading an imported file (TD-068) | 2026-09-26 | `3f54432` | Owner: "fix the existing issues…" (E.1, "Stage 3 fixes before validation"). The candidate proposes estimates at the editor's stored precision, with one set of constants for both (`EquipmentCandidate.sensorDecimals`/`pixelPitchDecimals`/`rawSizeDecimals`: 0.01 mm, 0.001 µm, 0.1 MB); plausibility is checked before rounding (a 0.05 MB file stays out of range — caught by the existing test when a first version rounded first). Regression tests (`equipment_import_round_trip_test.dart`): a rig saved from a file through the real form model matches it with no differences (the M4 main DNG, the telephoto, a portrait JPEG), and a user-typed value is still a difference. All four failed before the fix. Five expectations updated to the rounded proposals (the unrounded CALC-40 values stay tested in the estimator's group). CALC-40 row noted; TD-068 resolved. Gate green, 1165 + 1 skip + 2 E2E |

| 3 | S3.10 — The editor readable on a phone (TD-069) | 2026-09-26 | `387e54b` | Owner-approved (E.1, "Stage 3 fixes before validation"). `equipment_editor_fit_test.dart` reproduces the device on a 375 dp view with Roboto loaded (the test font draws a full em per character): at 100 %, "9.89" needed 36 dp in an 18 dp box, exactly as on the phone. Fix: each W × H row's label moved above its fields. The same test at 130 % found the Tracking dropdown overflowing (present before Stage 3): now `isExpanded`. 4 tests (two drafts × 100/130 %); all failed before. Existing editor tests unchanged. Gate green, 1169 + 1 skip + 2 E2E |

| 3 | Independent Stage 3 validation (FAIL) | 2026-09-26 | `7f790df` | Committed as written by the owner's validation: S3V-01–S3V-06 blocking, S3V-07 non-blocking, S3V-08 unverified. Before committing, this session re-ran the archived probes at `387e54b`: 7 failures (P1–P5, P7, P8) and P6 passing, as reported |
| 3 | S3.V1 — A stale review never reverts newer rig edits (S3V-01) | 2026-09-26 | The S3.V1 commit* | Owner-approved (E.1, "Stage 3 validation failed: corrective Tasks"). The review is re-matched against the saved rigs when shown (post-frame) and right before Open or "New rig with the camera specs" (`currentMatchFor`). A "use the file's value" choice stores the saved value it was made against and is withdrawn if that value changed or the rig is gone; a deleted or no-longer-matching rig is not opened (a snackbar says so). 4 regression tests through real routes, real screens and SQLite (`metadata_import_stale_review_test.dart`): the validation's P8 sequence, a change while the review stays open, a withdrawn choice (then a fresh explicit choice does replace), and a deleted rig. All 4 failed before the fix. Gate green, 1173 + 1 skip + 2 E2E |

\* A file cannot contain its own commit hash. Find it with
`git log --format="%h %s" -1 -- docs/refinement/PROGRESS.md`; the next Task records it here.

## Relevant commits

- `becae04`: the last roadmap commit (TASK 16.3 documentation, 2026-09-24). Audits 01–07 were
  captured against it.
- `652ad80`: Stage 0, the refinement baseline.
- `1ec6e7a`: Stage 1 planning (the frozen sequence).
- `6a90347`: S1.1.
- `c449c03`: S1.2.
- `2007dc5`: S1.3.
- `db2702f`: S1.4.
- `07d55e2`: S1.5.
- `c0bfcb7`: S1.6.
- `20eff0e`: S1.7.
- `b03dda9`: S1.8.
- `705b764`: S1.9.
- `642b235`: S1.10.
- `b0998c6`: S1.11.
- `b6fb6c3`: S1.12.
- `f179013`: S1.13.
- `28aaa10`: S1.14 (deferred).
- `4e653fb`: S1.15.
- `723fd44`: same-session Stage 1 validation (preserved below).
- `db94aaf`: independent Stage 1 validation.
- `953c0d1`: S1.16 and S1.17.
- `3067658`, `b34c9ad`, `ed628f8`, `ea65231`: S1.V1–S1.V4.
- `c99bd7f`: the same-session re-check.
- `39392d9`: the repeat independent Stage 1 validation.
- The Stage 1 closure and Stage 2 planning: see the note under "Completed Tasks".

## Open research gates

All defined in `POST_ROADMAP_PLAN.md` §7.

| ID | Topic | Stage | Status |
| --- | --- | --- | --- |
| RG-01 | Metadata formats, libraries, file selection and samples (resolves PD-21) | 2 | **Decided** 2026-09-26 (ADR-017), **amended** the same day (the owner's priorities, ADR-017 §13). JPEG and HEIC samples exist (S2.8, S2.9); FITS, PNG and proprietary RAW still need samples, and are out of Stage 2 |
| RG-02 | Metadata → equipment identity, derivability, matching, provenance and conflicts | 3 | **Decided** 2026-09-26 (S3.D; ADR-018), after S3.R1 (`research/RG-02_EQUIPMENT_IDENTITY.md`) |
| RG-03 | Sourcing equipment specifications (catalog or none; licence; the verified-seed policy) | 3 (7) | **Deferred by the owner** 2026-09-26 (S3.D, D2): no source in Stage 3; may return through Stage 7 |
| RG-04 | Execution's role and how actuals are captured | 4 | Open |
| RG-05 | Home/Tonight hierarchy, drill-downs and a possible Analytics destination | 4 | Open |
| RG-06 | Basic/Advanced modes against progressive disclosure | 4 | Open |
| RG-07 | Target catalog expansion, names and search | 7 | Open |
| RG-08 | Site elevation: an automatic source, optional, or dropped | 7 | Open |
| RG-09 | Bortle/SQM sources, whether SQM stays a field, and the light-pollution map provider | 7 | Open |
| RG-10 | Calibration-frame workflows and inheritance | 7 | Open |
| RG-11 | Capture parameters (ISO or gain, binning, white balance, focus, interval) and their labels | 7 | Open |
| RG-12 | Licence requirements against GPL-3.0 | 9 | Open |
| RG-13 | Settings: real-world needs and where each setting belongs | 9 | Open |
| RG-14 | Proprietary RAW compatibility and libraries (no ad hoc parsers) | 2 (S2.R3) | **Decided** 2026-09-26 (DECISIONS E.1): none in Stage 2; per-format adapters later, with samples; `ExifInterface` and LibRaw rejected |

## Open owner decisions

All defined in `POST_ROADMAP_PLAN.md` §8.

| ID | Decision | Stage | Status |
| --- | --- | --- | --- |
| RD-01 | The GitHub account behind the app identity: `chacha12` or `Buffur` | Before any upload | Open |
| RD-02 | The TASK 0.3 holdovers (ADK skill, `skills-lock.json`, `docs/archive/`, `sqlite3_flutter_libs`) | 1 / 10 | Open |
| RD-03 | Wording rulings: the SCI-05 ISO label; the SCI-04 time-resolution caveat | 1 | **Resolved** 2026-09-25: a neutral label (S1.8); SCI-04 documented only (S1.13). DECISIONS E.1 |
| RD-04 | New-draft defaults and the example plan | 4 | Open |
| RD-05 | Drafts and "New session" semantics (Stage 1 may decide an interim safeguard) | 4 (1) | Open; **interim decided** 2026-09-25: confirm before replacing (S1.6) |
| RD-06 | The planner's section order; integrity text one tap away | 4 | Open |
| RD-07 | The Library's role and pickers; where Progress lives | 4 | Open |
| RD-08 | Tracking per rig or per session; the seeded rig's tracking | 7 (before Stage 6's capture-plan work) | Open |
| RD-09 | Destructive interactions: confirm or undo | 5 | Open |
| RD-10 | Ordering Tonight's candidates without a score | 6 | Open |
| RD-11 | Where the Moon and cloud gate controls live (TD-050) | 6 or 9 | Open |
| RD-12 | The resume prompt's Finish | 8 | Open |
| RD-13 | Provenance of an accepted estimate | 8 | Open |
| RD-14 | Vocabulary (rig or equipment; Sessions or Logbook; window names) | 4 | Open |
| RD-15 | A local diagnostics export for the beta | 11 | Open |
| RD-16 | When the metadata feature becomes visible (PD-06 gate) | 2 (3) | **Resolved** 2026-09-26 (S3.D, ADR-018 §7): visible at the end of Stage 3 (S3.7), as "Add from a photo" on the equipment screen. It stayed hidden throughout Stage 2 |
| RD-17 | Push the CI workflow to the remote and observe a first run | 1 (optional) / 11 | Open; **push deferred by the owner** when S1.14 ran (2026-09-25; the remote is public) |

Answered in part by Stage 0: the direction part of 07 §6 item 11 (the primary 1.0 user), in
`PRODUCT_DIRECTION.md` §2. Modes stay open as RG-06.

## Owner actions outstanding

These block a release, not refinement.

- TASK 16.2: create the upload key and `android/key.properties`; install the SDK cmdline-tools;
  build and check a signed bundle (`docs/RELEASE.md`).
- TASK 16.3: publish the privacy policy with the contact email filled in; confirm the URL is
  live; make the repository public; fill in the Data Safety form (`docs/COMPLIANCE.md`).
- OD-07: a formal trademark search before the first upload; RD-01.
- A device or emulator for the device rows (`TEST_PLAN.md` L1–L8, and the other checks in
  `POST_ROADMAP_PLAN.md` Appendix B).
- Stage 3: say which cameras and optics you use besides the phone (a DSLR/mirrorless JPEG, or a
  FITS file, would let Stage 3 check those classes on real files). The phone is needed for S3.7's
  device check M4.
  Samples for FITS, PNG, AVIF or RAW, when available, enable their readers later. The DNG,
  JPEG and HEIC samples stay outside Git.

## Known blockers

- **Stage 1 (closed by waiver):** X2 is done (S1.V6, 2026-09-26). TD-063 is in Stage 8. W1 is
  a proposed input to RD-05.
- **Stage 2 (closed by waiver):** nothing blocks. The carried items are listed under "Next
  allowed action".
- **Stage 3:** nothing blocks S3.1–S3.6 and S3.8. S3.7's device check M4 needs the owner's phone. Equipment identity for
  dedicated astro cameras needs a FITS sample (S2.6).
- **Device evidence:** M1 seekable providers and M2 non-backup/cancel paths were
  recorded at `360fd8f`. Native streaming and real-backup preview cancellation
  remain unverified on-device. S2.V3 adds host JVM streaming tests; these do not
  upgrade device evidence. Stage 11 lifecycle rows remain open.
- **Release:** RD-01; the 16.2 upload key; the 16.3 policy. These do not block refinement.

## Validation status

- **Stage 3 second planning pass**, 2026-09-26, at `0c4848b`: documentation only; the gate re-run
  green (Encoding; Format; Analyze; 1068 tests, 1 expected skip; 2 host E2E), and the local
  real-sample test passes (DNG 848/848, JPEG 843, HEIC 4,051 bytes).

- **Stage 2 closure**, 2026-09-26: by owner waiver after S2.V4/S2.V5, not by an independent
  pass (E.1). **Stage 3 planning**: documentation only, and the gate result at `d8e792c` still
  applies (no code changed since).

- **S2.V4/S2.V5 implementation verification**, 2026-09-26: Encoding; Format (349 files, 0 changed); Analyze (no issues); 1068 tests with 1 expected local-sample skip; 2 host E2E. The targeted metadata
  suites give 98 passed and 1 expected skip; the new bound tests fail on the old reader; the
  real samples are unchanged. This is self-verification, not independent Stage acceptance.

- **Repeat independent Stage 2 validation**, 2026-09-26, at `5d8bdbb`: **FAIL**
  (`STAGE_2_REVALIDATION.md`).
  - Passed:
    - the gate is green on the clean tree (Encoding; Format, 349 files, 0 changed; Analyze; 1062 tests, 1 expected local-sample skip; 2 host E2E);
    - the local real-sample test passes;
    - the 4 native JVM tests pass, re-run;
    - no test was weakened since `79f392c`.
  - Failed: S2R-01 (blocking, TD-067).
  - Low: S2R-02 (needs an owner ruling), S2R-03 and S2R-04.
  - No application, test or dependency change.

- **S2.V1–S2.V3 implementation verification**, 2026-09-26: full gate green
  (1052 tests, 1 expected skip, 2 host E2E); 4 native JVM tests pass; all three
  external samples pass unchanged; the two original failing semantic probes
  now pass. This supersedes the code failures below, not the independent Stage
  verdict or its unfinished research/decision gates.

- **Stage 2 independent validation**, 2026-09-26, at `79f392c`: **FAIL**.
  See `STAGE_2_VALIDATION.md` and `evidence/STAGE_2_VALIDATION_PROBES.md`.
  The full gate passes (1042 tests, 1 expected skip, 2 host E2E); the external
  real-sample test also passes (two DNGs and one JPEG). Two additional
  malformed-input acceptance probes fail (S2V-01 and S2V-02). S2V-03 records
  the non-seekable accounting/test gap; S2V-04 records the still-open S2.9
  disposition and S2.R3 gate. S2V-05 through S2V-08 distinguish documentation
  debt, unverified device paths, existing display debt and rejected concerns.
  No implementation or existing tests changed. The Stage remains in progress;
  proposed corrective Tasks in the report do not constitute owner approval.

- **Stage 0**, checked 2026-09-25 against the Stage 0 prompt's §22 review list:
  1. the three refinement documents were re-read;
  2. none claims metadata extraction is implemented (a gated prototype is recorded as
     non-production);
  3. metadata → equipment import is a separate Stage (3) after the metadata foundation (2);
  4. research hypotheses are gates (RG) or decisions (RD), not approved implementation;
  5. Execution is preserved as a supporting workflow, with its role pending Stage 4;
  6. the scientific-integrity principles are restated unchanged (`PRODUCT_DIRECTION.md` §6);
  7. no deferred or rejected feature became approved; each can return only through its gate
     and an owner decision (`PRODUCT_DIRECTION.md` §8);
  8. every section of 08 has a home (`POST_ROADMAP_PLAN.md` Appendix A);
  9. the Final Audit's confirmed engineering, scientific and runtime issues (07 §2, §3, §4.1)
     are all in Stage 1, RT-05/UX-12 as a decision checkpoint (`POST_ROADMAP_PLAN.md` §6.1);
  10. no application code changed (only `CLAUDE.md` and files under `docs/` are in the
      commit).

  The quality gate was green on the unchanged code.
- **Stage 1 planning**, 2026-09-25: every A–F candidate was re-verified against `652ad80`, and
  every mechanism still exists (none stale). Seven planning-time findings were placed into
  Tasks (`POST_ROADMAP_PLAN.md`, Stage 1 frozen sequence). Documentation only; no code
  changed, so the Stage 0 gate result still applies.
- **Stage 1 closure**, 2026-09-26: by owner decision after a failed validation (a waiver,
  not a pass; DECISIONS E.1).
- **S2.R1**, 2026-09-26: research only. Throwaway probes (scratchpad Python, and
  `tool/zz_probe_*.dart`) were deleted; no code, test or dependency changed. The gate result
  at `c99bd7f` still applies.
- **Stage 2 planning**, 2026-09-26, at `39392d9`: documentation only; TD-018 re-verified. The
  gate result at `c99bd7f` still applies (no code changed since).
- **Repeat independent Stage 1 validation**, 2026-09-26, against `c99bd7f`: **does not pass**.
  - The gate is green (963 tests, 2 E2E).
  - The first validation's six probes are regression tests now, and they pass.
  - S1.V1–S1.V4, S1.16 and S1.17 meet their acceptance.
  - Surviving: TD-063 (P2; a reopen from a detail page loaded before Start) and X2 (the
    registers were not updated after S1.V1–S1.V4). Low: W1, confirmed (for RD-05).
  - No application or test source was changed. The probes are kept as a patch, which was
    applied, ran (1 failure, 2 observations) and was reversed.
  - Details: `STAGE_1_REVALIDATION.md`.
- **Independent Stage 1 validation**, 2026-09-25, against `4e653fb`: **does not pass**.
  The baseline gate independently passed (948 + 2 E2E); six additional probes
  fail across TD-059–TD-062. S1.5 misses refusal through the production background
  connection, and retained preferences can suppress reset seeding. S1.6 loses
  protection after target/night-only edits followed by restart and on reopening
  stale detail data for the current session. See `STAGE_1_VALIDATION.md` for the
  acceptance matrix, reproduction patch, limitations and proposed S1.V1–S1.V4.
  No application/test source changed. The other session committed `723fd44`
  during this validation; its result below is preserved as prior evidence, but
  its passing verdict is superseded by these reproductions. Its three unknown
  probe files were created by this independent validation, removed by their
  author, and retained as `evidence/STAGE_1_VALIDATION_PROBES.patch`; no owner
  cleanup action remains. **Stages 2–11:** not started.
- **Stage 1 Tasks (prior implementation record):** S1.1–S1.13 and S1.15 reported
  done (gate green); S1.5/S1.6 now require follow-up. S1.14 deferred by the owner.
- **Stage 1 validation**, 2026-09-25, at `4e653fb`. **Not independent:** the owner asked for it
  in the implementing session instead of a fresh one (§9.1 step 11). It tried to disprove
  completion; no fix was made.
  - Evidence: a fresh gate on the clean tree (Encoding, Format, Analyze pass; 948 tests; E2E
    2); every A–F item traced to its Task, commit and tests; no test assertion removed
    (four were updated to changed wording, with the new wording asserted); `lib/domain` has
    no `DateTime.now()`; ViewModels within the 300-line cap (300, 297, 271); no colour
    literals, data imports or hard-coded app name in the new presentation files; every
    commit hash in this file exists and matches its Task; `CurrentSession`'s ordering
    re-read (a failed Save or Start keeps changes unsaved; later edits queue behind them).
  - Owner decisions during the Stage were respected: S1.4's corrected rule, S1.5's
    no-reset for newer databases (ADR-008 §2), S1.14's deferral.
  - **Verdict: passed.** Every A–D item is fixed with a regression test, documented, or
    moved with the owner's approval; the gate is green. Three low findings, none a
    regression or a failure of a Stage 1 item:
    - **V1 (docs convention):** the living registers cite no commit for Stage 1 work: 0 of 13
      `S1.x` stamps in `FEATURE_STATUS.md` (and the same in `ARCHITECTURE.md`), and TD-047's
      "FULLY RESOLVED (S1.5)" (`CLAUDE.md` asks for date and commit). The hashes are only in
      this file. **Proposed S1.16** (docs, S): backfill the hashes from "Completed Tasks".
    - **V2 (test coverage vs S1.6's acceptance):** the "Discard unsaved changes?" dialog is
      checked for tap targets, labels, contrast and overflow in light and dark only; S1.6
      named the sweep, which also covers the field theme. **Proposed S1.17** (test, S): add
      the field theme (without contrast, as in the sweep).
    - **V3 (behaviour consistency, S1.6):** confirmed by a throwaway probe (deleted). A site
      change on a saved plan turns the stored session into a draft ("Planned, unsaved
      changes", still listed, so nothing is lost), but it is not counted as an unsaved change
      while the app runs, so New does not ask; after a restart the same session counts as
      unsaved. Whether a site change edits a saved plan is a product question: **proposed:
      record it under RD-05 (Stage 4)** rather than fix it now.
  - Observations, no action proposed: `formatBudgetDuration` and `OpportunityText.duration`
    remain as one-line wrappers over `QuantityText.duration` (one rule, S1.7 met in
    substance); `WeatherText.ago` ("3 h ago") truncates, a relative-age phrase outside
    UX-19's scope; S1.2's E3 test covers the unreadable read, not a failed write, like the
    other preference repositories.
  - **Found during validation (not a Stage 1 finding):** three untracked files appeared in
    the working tree while it ran, `test/data/database/stage1_recovery_probe_test.dart`,
    `test/presentation/shared/stage1_reopen_probe_test.dart` and
    `test/presentation/viewmodels/stage1_restart_probe_test.dart` (copies of Stage 1 tests,
    written 19:38–19:39). This session did not create them; another local session
    ("Stage 0 refinement baseline") is the likely author. They were left untouched and not
    committed; the owner decides. **Stages 2–11:** not started.

## Next allowed action

**S3.V2 — preserve provenance (S3V-02)**, owner-approved (DECISIONS E.1): untouched legacy values
must not become attributed to the user merely because another field was edited. First a failing
regression test (the validation's P1 and P2, through the real repository), then only that fix,
then the gate, `PROGRESS.md`, one commit, and STOP. S3.V3, S3.V4 and S3.V5 follow, one at a time.
Then a fresh independent Stage 3 validation; do not start Stage 4.

Useful inputs:
- the local samples, `ASTROPLAN_METADATA_SAMPLES=C:/Users/zalub/AstroPlanSamples/metadata`
  (2 DNGs, a JPEG and a HEIC);
- `research/RG-01_METADATA_FORMATS.md` and `research/S2.R2_HEIF_METADATA.md` (identity
  evidence);
- ADR-008 §6, ADR-011 and ADR-017.

**Carried open items:**
- W1 (proposed input to RD-05);
- TD-063 (Stage 8);
- TD-057 and TD-058;
- RD-17 (the push is deferred);
- the S1.5 and S1.11 device checks (Stage 11);
- S2V-06's device checks (a non-seekable provider; a real backup's preview cancel): the next
  time the phone is connected, or Stage 11;
- TD-066 resolved 2026-09-26 (fractional exposure presentation; see amendment above);
- the stale id-holding preferences after a reset, `editedSessionId` included (with
  TD-056/ENG-14).

## Stage 0 notes

Thirteen discrepancies between the prompt, the documents and the repository are recorded in
`POST_ROADMAP_PLAN.md` §1.3. Among them:
- the prompt's location (item 1);
- undocumented manual device use (item 2);
- the `chacha12`/`Buffur` identity (item 3, RD-01);
- the licence requirements against PD-12 (item 4, RG-12).

## How to update this file

- **At the end of every Task:**
  - add a row to "Completed Tasks" (commit hash, and the finding IDs resolved);
  - update the current and next Task;
  - update the status of any RG or RD it touched (resolved: date, and where the decision is
    written);
  - record the validation result.
- **At every Stage boundary:**
  - update the Stage status table (dates, validation result);
  - update the next Stage and the next allowed action;
  - refresh "Known blockers".
- Keep it compact. Detail lives in commits, `POST_ROADMAP_PLAN.md` and the living registers.
