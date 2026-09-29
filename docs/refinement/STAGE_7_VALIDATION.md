# Stage 7 — Independent validation

Date: 2026-09-29. Reviewed baseline: `d13fdab` (clean working tree before validation).
Fresh session, independent of implementation; validation only, no application fixes.
Procedure: `prompts/INDEPENDENT_STAGE_VALIDATION.md`; `CLAUDE.md` V1–V8.

## Frozen acceptance surface

Frozen before implementation inspection, from `POST_ROADMAP_PLAN.md`, Stage 7's rules,
S7.1–S7.6 (including S7.D's split), and "Stage 7 validation":

| ID | Criteria to judge |
| --- | --- |
| R | S7.R1–R5 completed with evidence, unknowns and options distinguished; explicit owner decisions; ADR-020 faithfully records RG-11/RG-10; implementation after each gate. RD-08=T3; RG-11=C1/B1/W1/F1/I1/P2; RG-10=L1/D1/T0/O0/N1/H1; RG-07=T1; RG-08=E2; RG-09=S3/M2; RG-03=Q1. No unapproved source. |
| T1 | S7.1: v18→v19 equality/preservation and null override; effective tracking drives guidance and warnings without editing the rig; seed Unknown; Save records value/source, Discard restores, Copy carries, New clears, Open reads, rig changes keep override; old snapshots default honestly and saved snapshots remain unchanged; export with/without key, backup migration; 200% control, no colour-only meaning, ViewModel cap, required documentation. |
| T2a | S7.2a: five user-selected classes, Unknown default/seed/import; migration equality and preservation; no name/file inference; snapshot independence; editor sweep and field fit. |
| T2b | S7.2b: light fields by class including Unknown at 200%; hidden values preserved/reachable/exported/snapshotted without changing calculations; no unapproved fields or ISO/gain conversion; previous-light proposal labelled and saved only on confirmation; interval label/help only; E1–E7 unchanged. |
| T3a | S7.3a: RG-10 §4 matrix by frame/class; copy on creation with origin and independent override; no following later edits; domain match checks positive/negative/unknown, words and one-tap repair; dark flat through storage/snapshot/export/readers; hideable remembered tips never hide warnings; independent budget vectors; policy lines, integration and existing snapshots preserved. |
| T3b | S7.3b: E8/E8b/E8c independently derived to milliseconds, E1–E7 unchanged; noise reduction defaults off, applies only to DSLR/mirrorless and Unknown; preserved otherwise; migration equality/preservation; atomic event and memoization; assumption/snapshot/double-dark warning. |
| T4 | S7.4: research alias examples and match-kind/id ordering, offline; pinned generated catalog, version/since/deleted-target protection, notices; no new objects or online lookup; immutable catalog ids/custom rows/plan references, migration; candidates semantics and before/after host timing. |
| T5 | S7.5: optional unknown elevation stays null with migration preservation and honest snapshots; GPS only on tap and saved only by Save; offline/manual path; opt-in names; manual unknown Bortle/SQM, no conversion, remembered disclosure with source/date; map at typed coordinates, same-commit privacy/compliance; back guard with/without changes. |
| T6 | S7.6: pixel size once; every former value editable/preserved; rare fields one tap away; draft/import tests and example provenance preserved; primary Save/glossary; 200% sweep/field fit; local form state without extra planner recomputation; no specification source. |
| X | Shared invariants: ADR-009 budget lines/units/no score or physical SNR; ADR-017/018 import confirmation/provenance/privacy; ADR-019 §3.1 saved snapshots; nullable unknowns, explicit edits, schema/export/backup compatibility, layered architecture/ViewModel caps, accessible forms and visible errors/warnings; no adjacent Stage implementation. |
| E | Every implementation Task's final full-gate evidence plus named migration/vector/catalog checks; reuse unchanged inputs under V3. No fresh device or real-sample run is required by this Stage. Exit: every area implemented after its gate or explicitly deferred. |

## Evidence and judgments

**Outcome: BLOCKED.** Two reproduced blockers, S7V-01 / TD-083 and S7V-02 / TD-084.
No owner decision is needed; both contradict existing criteria. No production code was changed.

**Gate reuse (V3):** the recorded S7.6 full gate PASS at `d13fdab` remains valid for its
committed tests: Encoding; Format (461 files, 0 changed); Analyze (no issues); 1,710 tests,
2 expected skips; 2 host E2E. `git diff --stat d13fdab -- . ':!docs' ':!CLAUDE.md'`
is empty after removing the temporary probes and restoring the catalog's original bytes.
The new failing probes expose coverage gaps; they do not invalidate the recorded run or turn
that run into Stage acceptance. No full gate, analyzer, existing suite or real-sample test was
rerun solely for a new session.

The implementation commits record their final gates: S7.1 `99f0677` (1,527 tests), S7.2a
`59aff50` (1,547), S7.2b `14b079d` (1,559), S7.3a `d4dbd24` (1,605), S7.3b `763f11c`
(1,642), S7.4 `037f687` (1,675), S7.5 `3d54a4c` (1,702), S7.6 `d13fdab` (1,710);
each records 2 expected skips and 2 host E2E. These are repository-recorded results reused
under V3, not fresh runs claimed by this validator.

| Frozen item | Judgment | Evidence and practical limits |
| --- | --- | --- |
| R: research and decisions | **PASS** | Five dated research reports in `research/RG-11_CAPTURE_PARAMETERS.md`, `RG-10_CALIBRATION_WORKFLOWS.md`, `RG-07_TARGET_CATALOG.md`, `RG-08_09_SITE_AUTOMATION.md`, `RG-03_EQUIPMENT_SPECS.md`; each distinguishes evidence/unknowns/options and records sources. DECISIONS E.1 explicitly decides each gate; ADR-020 matches RG-10/RG-11. Git order puts decisions before their affected implementation; S7.1 was already authorized by T3. Q1 adopts no equipment source, T1 no online resolver or new objects, E2/S3 no automatic elevation/sky brightness. This bounded validation does not re-research rejected providers or treat historical research unknowns as confirmed facts. |
| T1: tracking | **PASS** | `EffectiveTracking.of`, `CapabilityCalculator.evaluate(tracking:)`, plan notifications/cache invalidation, repository create/write/read, lifecycle `_apply`/Copy/New, `SavedPlanReader` and `SessionSnapshotBuilder`, manifest codec. Domain `plan_tracking_test.dart`, presentation `plan_tracking_test.dart` (real SQLite, Save/Discard, Copy/New/Open, rig isolation, 200% control), migration and export tests cover the specified cases. Snapshot keys are additive; rig default remains separate; example seed unchanged. Required documentation is present. |
| T2a: camera class | **PASS** | `CameraClass`, `EquipmentDraft`, equipment repository and snapshot builder; `camera_class_test.dart` explicitly checks Unknown seed/import, preservation on edit, SQLite and snapshot independence. v19→v20 preservation/equality cases. No name/format inference path added. |
| T2b: light form | **PASS** | `capture_block_dialog.dart`, class applicability, last-light proposal in `SessionPlanViewModel`, `light_block_form_test.dart` (each class at 200%, hidden-value preservation, explicit replacement without conversion, proposal cancellation); Settings/assumptions label diff. Budget/fit do not read block binning or gain. Snapshot/export retain block values. No added white balance, focus, offset or temperature field. E1–E7's inputs/tests unchanged. |
| T3a: calibration inheritance and independent edits | **FAIL — S7V-01** | The unlock/source-change paths overwrite independent exposure or edited flat gain. Three new widget probes fail; details below. |
| T3a: remaining matrix, matching, frame type, policies and tips | **PASS** | `CalibrationMatch` resolves required matches in the domain, unknown sensitivity/binning rules, millisecond exposures, missing-flat and double-dark warnings; `CalibrationText`, `capture_plan_widget.dart` repair/Undo and remembered tips. `calibration_match_test.dart` covers positive/negative/unknown and independent budget expectations; `calibration_blocks_test.dart` covers the 20 frame/class combinations, dark-flat SQLite/snapshot/export, mismatch repairs and hidden tips. Stored blocks are copies without a source link, so later light edits do not rewrite them. Dark-flat parsers and exhaustive labels updated; no budget arithmetic added to widgets. Passing creation cases do not cover the failed transition above. |
| T3b: noise reduction | **PASS** | `CaptureOverheads` and `CaptureBudgetCalculator` add the dark inside the light event and calibration line; `FitAnalyzer` consumes that sequence unchanged. Independently checked E8: 30×(60+60+5)=3,750 s, integration 1,800 s, acquisition 1,950 s; E8b: floor(7,200/125)=57 frames, 3 unplaced, 75 s tail; E8c: 60×65=3,900 s. These match integer-ms assertions in `in_camera_noise_reduction_test.dart`. UI tests cover rig-edit invalidation of cached budget/fit/fill, per-class switch preservation, snapshot, assumptions and double-dark warning. v20→v21 equality/preservation covered. |
| T4: targets and catalog | **PASS** | Pure `TargetSearch`, alias table/repository/seeder and catalog tool inspected; `target_search_test.dart` / `catalog_aliases_test.dart` cover research examples, ordering, deletion, renamed/custom rows and restore/rebuild. v21→v22 preserves rows/references. Fresh pinned-source regeneration matched the committed catalog (line endings normalized), 164 objects / 109 Messier; original asset bytes restored. Version 3, all existing `since=2`; no new object. Notices updated. Candidates evaluator unchanged; recorded host median 53.4 ms before / 52.7 ms after at `037f687`, not a device performance claim. |
| T5: site discard guard | **FAIL — S7V-02** | Name-only, elevation-only and notes-only edits each leave without the required prompt in new widget probes. |
| T5: remaining site criteria | **PASS** | Nullable elevation and `LocationProfile.userEdit`, v22→v23 table rebuild preserving values and site references, null snapshot test; GPS only in the tap callback, form-only assignment until Save, failure test, existing opt-in name path; manual Bortle/SQM, remembered section and hidden-invalid-SQM validation; typed-coordinate link test. `3d54a4c` contains About, privacy and COMPLIANCE changes together. No automatic provider or conversion added. |
| T6: rig form | **PASS** | One pixel field; controlled optional disclosure, invalid-value reopening, imported RAW provenance visible; `rig_form_test.dart`, editor prefill/fit and import-review tests. S7.6 leaves `EquipmentDraft` and the example seed unchanged. Controllers/draft remain local until Save; no extra planner recomputation per keystroke. Save/glossary and retired-term baseline updated. Gate includes sweep/field-fit evidence at 200%. |
| X: shared invariants | **FAIL only for the edit-preservation/guard defects above; remaining checks PASS** | Domain calculations remain outside widgets; gain/binning descriptive, no physical SNR or score; no parser/import architecture or provider expansion; additive snapshots and compatible manifest keys; v8→v23 equality plus per-step preservation tests inspected. Gate covers architecture/ViewModel limits, encoding, accessibility and E2E. Tracker/result changes are exhaustive dark-flat labels, not Stage 8 implementation. Saved-plan working-copy work remains explicitly Stage 8. |
| E: verification and exit | **Verification evidence PASS; Stage exit FAIL** | Reused gates plus fresh catalog check and six failing probes. Every area followed its gate, but S7.3a/S7.5 are not fully correct. Existing device/real-sample gaps carried by PROGRESS remain unchanged; none becomes a new Stage 7 device requirement. |

### S7V-01 / TD-083 — Calibration controls overwrite independent input

**BLOCKER (V4 A/B), priority P1.** Contradicts S7.3's independent-field rules and matrix,
RG-10 §4.2/§4.3, ADR-020 §6 and the Stage rule, "A proposal never overwrites the user's edit."

At `lib/presentation/widgets/capture_plan/capture_block_dialog.dart:226`, `_useOtherValues`
unconditionally assigns the source exposure (line 231) and sensitivity (line 233). A flat's
exposure and a bias's exposure were already independent. `_prefillFlatGain` (204–207), called
on every source choice (401–402), also replaces an already edited flat gain.

Reproduced through the real dialog at 200% text, with a 300 s light as source:

| Interaction | Expected submitted block | Actual |
| --- | --- | --- |
| New flat, enter 2 s, then Use other values, Add | exposure 2 s | **300 s** |
| New bias, enter 0.001 s, then Use other values, Add | exposure 0.001 s | **300 s** |
| New flat, enter gain 77, choose another light source with gain 120, Add | gain 77 | **120** |

The exposure substitution materially changes the calibration budget (20 flats become 6,000 s
of exposure instead of 40 s; 20 bias frames become 6,000 s instead of 0.02 s). No formula
change is needed: the form submits the wrong input. Existing tests check initial inheritance
and dark unlocking, but not flat/bias unlocking after independent entry or edited-gain source changes.

Evidence: [`S7V_01_CALIBRATION_PROBE.patch`](evidence/S7V_01_CALIBRATION_PROBE.patch),
three failing cases. Correction: **S7.V1** in the plan.

**Correction state (S7.V1, 2026-09-29):** implemented; the three cases pass as permanent tests in `calibration_blocks_test.dart` (they fail on the `d13fdab` dialog); full gate PASS with 1,719 tests. Awaits the bounded V5 revalidation after S7.V2; this report's judgment is not changed by the correction itself.

### S7V-02 / TD-084 — Site guard misses edits to three fields

**BLOCKER (V4 A/B), priority P2.** Contradicts S7.5's "back with changes asks; back without
changes leaves" and UX-21's explicit no-loss objective.

`lib/presentation/screens/sites/site_editor_screen.dart:117` listens only to latitude,
longitude and SQM. The parent `PopScope` receives `canPop: _leaving || !_changed` (285)
only when rebuilt. Editing name, elevation or notes alone does not refresh that parent, so
its original `canPop=true` allows Back; the callback sees `didPop=true` and never asks.

Each probe opens an existing site, changes exactly one of Name / Elevation / Notes, settles,
and taps Back. All three fail: **zero "Unsaved changes" prompts** instead of one. No Save
occurred. The existing guard test fills coordinates too, which triggers a parent rebuild and
masks this defect. No device-specific assumption is needed for this reproduced AppBar Back path.

Evidence: [`S7V_02_SITE_GUARD_PROBE.patch`](evidence/S7V_02_SITE_GUARD_PROBE.patch),
three failing cases. Correction: **S7.V2** in the plan.

**Correction state (S7.V2, 2026-09-29):** implemented; the three cases pass as permanent tests in `sites_screen_test.dart`, for existing and new sites and app-bar and system Back (they fail on the `d13fdab` editor); full gate PASS with 1,734 tests. Awaits the bounded V5 revalidation; this report's judgment is not changed by the correction itself.

### Fresh checks and probe reproduction

On `d13fdab`, apply both patches, then run:

```powershell
git apply docs/refinement/evidence/S7V_01_CALIBRATION_PROBE.patch
git apply docs/refinement/evidence/S7V_02_SITE_GUARD_PROBE.patch
flutter test --no-pub test/presentation/widgets/calibration_blocks_test.dart test/presentation/screens/sites/sites_screen_test.dart --plain-name 'S7V probe' --reporter expanded
```

Observed: **0 passed, 6 failed**, exit 1; failures are the exact assertions above, not harness
errors. Both patches were then reversed and the two test files restored to HEAD. The patches
are retained unapplied under `docs/`; `git apply --check` passes for each.

Catalog check: downloaded only `database_files/NGC.csv` and `addendum.csv` from the pinned
OpenNGC `v20260501` tag to a temporary directory, ran `dart run tool/build_catalog.dart`
with those paths, compared generated and committed text after CRLF normalization: **PASS**.
Downloaded files removed, original catalog bytes restored. This fills the explicit regeneration
check without rerunning unrelated passing evidence.

Documentation checks: referenced files and finding/Task IDs checked; `git diff --check`.
No source, tests, assets or dependencies remain changed.

## Handoff

Stage 7 stays **In validation**. Next allowed action: **S7.V1**, then STOP; a later cycle may
perform S7.V2, then a V5 revalidation of the two findings, touched criteria and corrections'
regression surfaces. Every other PASS above stands unless V6 brings contradictory evidence.
No Stage 8 work and no push (RD-17). No new owner decision.

Documentation drift corrected: PROGRESS's Stage 7 blockers still said research/decisions were
pending despite its current state recording them all decided; the S7.R5 table row also still
said RG-03 awaited the owner. Git and DECISIONS E.1 confirm Q1 in `9363ff5` before S7.6.
These stale handoff lines were corrected, with no reopening of the decisions.
