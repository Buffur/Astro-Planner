# Stage 3 validation: FAIL

Date: 2026-09-26. Stage: **3 — Metadata → Equipment / Device Import**.

## Repository state and method

- Validated HEAD: `387e54b` (S3.10); clean tracked and untracked tree on entry.
- Examined Stage range: `0c4848b..387e54b`, from the Stage 2 owner waiver through
  research, decisions, S3.1–S3.10 and the debug/exposure amendments. Implementation
  commits are listed below. The earlier provisional S3.9 (external specification
  source) was removed; the completed S3.9 is the later TD-068 fix.
- Authority: the owner's independent-validation prompt, `CLAUDE.md`, the frozen
  Task acceptance in `POST_ROADMAP_PLAN.md:1352`, ADR-018, RG-02, CALC-40 and M4.
  Stage 2's waiver and the deferred FITS/RAW/catalog work were respected.
- This is a validation-only follow-up in the existing chat, **not a fresh chat**.
  This chat previously contributed the debug viewer and TD-066 formatting; the
  main Stage 3 implementation was evaluated anew from repository evidence.
- No application code, existing tests, Android configuration or dependencies were
  changed. Temporary synthetic probes were run, archived verbatim in
  [the evidence record](evidence/STAGE_3_VALIDATION_PROBES.md), then removed.
  Only this report, its evidence and the progress record are delivery changes.
- Evidence labels below distinguish code inspection, host tests and documented
  historical device results. Host tests are not device verification.

## Executed validation

| Command / check | Result |
| --- | --- |
| `dart run tool/check.dart` on the entry baseline | **PASS**: encoding, format, analysis, 1,169 unit/widget tests, one expected local-sample skip, 2 host E2E tests. Probes were created only after the unit suite had been enumerated; none appears in this baseline count |
| `flutter test --no-pub test/data/metadata/real_samples_test.dart`, with `ASTROPLAN_METADATA_SAMPLES` set to the owner's local sample directory | **PASS**, all expected contract fields including dimensions for 2 DNGs, JPEG and HEIC. Reads: 856, 856, 843, 4,051 bytes; 12, 12, 16, 17 ranges. No sample bytes or private metadata were committed |
| `android/gradlew.bat :app:testDebugUnitTest --offline --rerun` (Android Studio JBR) | **PASS**, 4 native `MetadataSequentialReaderTest` cases, no failures/errors; XML result inspected |
| `flutter test --no-pub test/zz_stage3_validation_test.dart` | **1 pass, 6 failures**: P1–P5 and P7 reproduce the findings below; P6 confirms ordinary import → real SQLite → rematch works |
| `flutter test --no-pub test/zz_stage3_widget_validation_test.dart` | **1 failure**: P8 reproduces stale-review data loss through the real screens and a real in-memory SQLite database |
| `flutter test --no-pub test/zz_stage3_storage_validation_test.dart` | **2 pass**: P9 preserves v18 provenance/identity through the production backup/stage/restore path; P10 proves failed inserts roll back the entire device/camera/rig chain |
| `adb devices -l` | Owner's Xiaomi phone is connected. Read-only inventory only; no app was installed, launched, changed or removed during this validation |
| Existing test assertions and production paths | Inspected metadata dimensions, candidates/CALC-40, matching, provenance, repository mapping, v8–v17 → v18 migrations, editor, review, routing, accessibility/phone-width tests and backup/export |

The baseline gate is green, but the independent probes demonstrate missing behavior.
Seven probe failures represent five application findings (some have multiple reproductions).

## Task results and acceptance

| Task | Result | Evidence and acceptance assessment |
| --- | --- | --- |
| S3.R1 — Equipment identity research | **PASS (DOCUMENTED / CODE VERIFIED)** | `4c46f8f`; RG-02 distinguishes device classes, identity ambiguity, derivability, confidence, confirmation and deferred formats. Local samples reproduce the available geometry; external standards were not independently re-researched |
| S3.D — Owner decisions and freeze | **PASS (DOCUMENTED)** | `792b295`; DECISIONS E.1 records D1=A1, D2=defer RG-03, D3=visible at S3.7, D4=DNG size estimate. ADR-018 and the frozen sequence agree |
| S3.1 — Image geometry | **FAIL** | `60ec4db`; DNG main IFD/crop rules, JPEG/HEIC EXIF dimensions, portrait geometry, ambiguity, GPS exclusion, unchanged budgets and local samples pass. The explicit absurd-value → unparseable acceptance is not implemented or tested: S3V-05 |
| S3.2 — Candidate and CALC-40 | **PASS (CODE / TEST VERIFIED)** | Landed partly in `7560df2`, followed by `e9a9d87`/`fdd00a5`. Formula and hand-computed tests agree; dimensions use long/short sides; unknown/conflicting inputs do not yield estimates; results are bounded and only estimated; no D, tracking, rotation or exposure-limit inference; no network or persistence. Synthetic phone/body/telescope/unknown scenarios are covered |
| S3.3 — Matching | **PASS (CODE / TEST VERIFIED)** | `0e5b93e`; normalization, separator-prefix rule, 1% optics and documented 10% FOV tolerances, ambiguous bodies, modules, crop/bin modes, verified/legacy conflicts and default-keep behavior exist. Matcher itself performs no writes. Lifecycle failures occur in the review's retained snapshot, not these pure rules |
| S3.4 — Schema/provenance | **FAIL** | `1af68e4`; additive v18 migration, schema equality for every supported prior version, legacy/seed data preservation, repository mapping and backup preservation pass. Editing a legacy field fabricates provenance for untouched fields: S3V-02 |
| S3.5 — Editor draft/pre-fill | **FAIL** | `9675854`; required unknowns block Save, D remains empty and ordinary per-field edits pass. Copied unknown provenance, saved-value precision and explicit sensor conflict application fail: S3V-02/03/04 |
| S3.6 — Review and confirmation | **FAIL** | `f230e6b`; ordinary import/Save/rematch and default-keep verified-value cases pass. Re-entering review can undo a later edit (S3V-01); conflict application has S3V-03; required behavioral widget tests use a fake repository rather than the stipulated real database (S3V-06). Review accessibility is exercised with a real database in the existing sweep, but that does not cover save/cancel semantics |
| S3.7 — Visibility, TD-066, M4 | **PASS with device limits** | `2b045eb`; flag is true, Equipment has Add from a photo, Settings entry removed, non-Android unavailable state remains, exposure fractions are tested. Privacy/Data Safety were updated and no import network path exists. M4 is **DOCUMENTED historical device verification** at `d21a326` plus S3.7 changes, not independently rerun here; see S3V-08 |
| S3.8 — DNG RAW-size estimate | **PASS (CODE / TEST VERIFIED)** | `d21a326`; decimal MB, from-one-file estimate, DNG only, unknown optional field filling, existing RAW value kept by default. JPEG/HEIC sizes are not proposed as RAW sizes |
| S3.9 — TD-068 rounding fix | **PASS for its defined new-import round trip** | `3f54432`; candidate estimates and editor share precision constants, limits checked before rounding; main DNG/tele DNG/portrait JPEG round-trip tests and P6 pass. Existing-rig conflict application and copying saved values have separate failures S3V-03/04 |
| S3.10 — TD-069 phone editor fit | **PASS (CODE / TEST VERIFIED)** | `387e54b`; labels above numeric rows and expanded Tracking dropdown; Roboto tests at 375 dp and 100/130% verify complete numeric text width, not merely absence of overflow. Device recheck of this final change is UNVERIFIED here |

## Findings

### S3V-01 — BLOCKING: a retained import review overwrites newer rig edits

- **Requirement:** ADR-018 §6 keeps saved values unless explicitly replaced; Stage validation
  must cover lifecycle, stale state and persistence.
- **Evidence:** `app_view_models.dart:116` retains one metadata VM; the stateless review has
  no entry refresh (`metadata_import_screen.dart:20`). `rigDraft` builds from the old
  `RigMatch.rig` (`metadata_import_viewmodel.dart:107`). Match refresh occurs after a pick
  or a save from the review, not after edits made elsewhere before re-entry.
- **Reproduction P8 (TEST VERIFIED, real widgets + SQLite):** import JPEG → return to Equipment
  → edit RAW size from 30 to 45 MB → reopen Add from a photo without picking again → Open
  existing rig → Save Changes. Database value becomes **30 MB**. No imported RAW value was
  selected (JPEG proposes none). P5 independently reproduces this through VM/draft/repository.
- **Conclusion:** a normal navigation sequence loses a newer user value. Refresh/reconcile
  current persisted rigs before presenting/opening the retained review and reset/revalidate
  conflict choices against that state. Add the real navigation regression.

### S3V-02 — BLOCKING: unknown provenance becomes user/reported without user input

- **Requirement:** ADR-018 §5: only changed fields become user/reported; copied values keep
  their saved provenance; unknown provenance must not be invented.
- **P1:** new rig with camera specs copied from a legacy rig whose provenance is NULL → Save
  → SQLite reread. Untouched sensor size becomes **user (reported)** instead of unknown.
  `equipment_draft.dart:150` creates an unknown prefill, then `:421` drops it; the new profile's
  user group supplies invented provenance.
- **P2:** edit just a legacy rig's pixel pitch → Save. Untouched resolution becomes
  **user (reported)**. `equipment_profile.dart:153` omits an unknown old group while `:186`
  marks the new group user; `provenanceOf` falls back to it.
- **TEST VERIFIED** through the real repository. The committed test
  `equipment_provenance_test.dart:156` actually expects this promotion; it checks the
  implementation's group fallback rather than the frozen per-field requirement.
- **Conclusion:** preserve unknown field provenance during copy/edit and reconcile the
  group-summary fallback with the explicit per-field contract. Test both routes after reload.

### S3V-03 — BLOCKING: choosing imported sensor size can retain the old number

- **Requirement:** an explicit per-field choice must apply the imported value and its origin.
- **P3:** saved sensor 9.894 × 7.416 mm, file proposes 9.89 × 7.42 mm. Choose the sensor-size
  conflict and Save. SQLite still contains **9.894 × 7.416**, but its source is now the file's
  estimate. Both pairs round to the same text.
- **Mechanism:** `equipment_draft.dart:402` decides whether a field is untouched by comparing
  text with the old value formatted to two decimals, including when `forRig` explicitly took
  the imported value. It preserves the old number; provenance is taken from the new prefill.
- **TEST VERIFIED.** This also leaves a conflict on the next read. Preserve exact saved values
  only for fields actually kept, not explicitly replaced.

### S3V-04 — BLOCKING: copying camera specs rounds saved values but keeps their provenance

- **Requirement:** ADR-018 §5/§6 copies saved camera specs with their provenance. S3.9's rounding
  decision is for **estimates**, not an instruction to modify all saved camera values.
- **P4:** choose a new rig with camera specs from a saved rig, with no file geometry/estimate.
  An untouched saved width **9.894 mm becomes 9.89 mm**, still marked **verified**. The same
  formatter path reduces copied pixel pitch to 0.001 µm and RAW size to 0.1 MB.
- **Mechanism:** `equipment_draft.dart:143` uses the estimate-display formatter for fallback
  values too (`:183`, `:190`, `:214`); a new draft has no original profile from which to restore
  the exact copied value. **TEST VERIFIED** through SQLite.
- **Conclusion:** keep copied numeric values separately from display text and preserve them
  when untouched. Apply estimate rounding only to imported estimates.

### S3V-05 — BLOCKING: absurd image dimensions remain known metadata

- **Requirement:** frozen S3.1 acceptance (`POST_ROADMAP_PLAN.md:1396`) explicitly requires
  zero or absurd dimensions to be unparseable, with a synthetic regression.
- **P7:** JPEG EXIF dimensions **4,294,967,295 × 4,294,967,295** return `KnownValue`, not
  `UnparseableValue`. `exif_values.dart:172` only rejects missing/non-positive dimensions.
- **TEST VERIFIED.** The candidate rejects them using `EquipmentLimits`, so this probe does
  **not** show they can be saved as equipment. It does show incorrect metadata classification
  and a missing explicit acceptance case. Define the metadata sanity bound and test the shared
  path without confusing equipment limits with all possible valid image dimensions.

### S3V-06 — BLOCKING: required real-database review behavior coverage is missing

- **Requirement:** S3.6 acceptance (`POST_ROADMAP_PLAN.md:1498`) specifies widget tests with
  fake file access **and a real in-memory database**, covering cancellation at every step,
  row counts, no duplicate, conflict choices and verified-value preservation.
- **Evidence:** `metadata_import_review_test.dart:78,275` uses
  `InMemoryEquipmentRepository` (a list fake). Its cancel case only checks `inserted` after
  dialog Cancel. `equipment_add_from_photo_test.dart` replaces the destination with an
  `Import stand-in` that directly inserts into the fake repository.
- The accessibility sweep uses real Drift and renders the review, and separate repository
  tests exist; neither executes the required review write/cancel assertions on SQLite.
  P8 supplies independent failure evidence, not a permanent replacement for this acceptance.
- **Conclusion:** add the required integrated widget cases, including real table counts and
  navigation/re-entry. Keep fake-based tests where useful; do not weaken their assertions.

### S3V-07 — NON-BLOCKING: current-state records retain superseded debug-only wording

- `PROGRESS.md`'s Current state still says visibility and M4 wait for S3.7; ADR-018 §7's owner
  amendment (`DECISIONS.md:3235`) still says kDebugMode and hidden release builds without
  explicitly marking that paragraph historical. Current code is unconditionally visible.
- Later completion records are correct, but the competing wording can recreate the user's
  earlier confusion. Mark the debug amendment superseded and make current visibility explicit;
  preserve the historical decision. This report records the discrepancy, without rewriting ADRs.

### S3V-08 — UNVERIFIED: device coverage beyond the recorded M4

- M4 records one DNG import on the Xiaomi phone in a separate `.s2check` package, no cache copy,
  and TD-066 on-device. M1/M3 cover JPEG/HEIC extraction, not the complete new import workflow.
- This validation reran host and native tests only. No fresh phone run of final S3.9/S3.10,
  JPEG/HEIC import-save flow, or a non-seekable provider was performed. Connection alone is not
  verification. Recheck the corrected flow in `.s2check`; never use the owner's installed app.
- The cloud-provider and real-backup preview-cancel checks remain the explicitly carried
  S2V-06 work; they are not reopened here as new Stage 3 blockers.

## Suspicions rejected / boundaries verified

- **REJECTED:** v18 migration loses old equipment or seeded provenance. Existing migration
  tests cover v8–v17 schema equality and v17 seeded/legacy values; they passed.
- **REJECTED:** backup drops new provenance or metadata identity. P9 restores these fields
  unchanged through the production backup path. Manifest v2 is session-oriented and unchanged;
  equipment persistence is in the database copy, not a newly omitted manifest field.
- **REJECTED:** an insertion failure leaves orphan equipment rows. P10 injects an SQLite
  trigger failure at rig insertion; device, camera and rig tables are all empty afterwards.
- **REJECTED:** TD-068 still affects the ordinary fresh-import round trip. Existing S3.9
  regressions and P6 pass; S3V-03 is the distinct existing-rig conflict path.
- **REJECTED:** CALC-40 was silently promoted to verified or frame exposure became an
  equipment limit. Candidate and form tests retain estimated provenance and leave D, rotation,
  tracking and exposure limit unknown; no external specification source was added.

## Verdict and required follow-up

**FAIL. Stage 3 must remain in validation.** Six blocking findings remain: five behavior/data
integrity defects and one explicit regression-coverage requirement. The green existing gate
does not override the reproduced failures. No fixes were implemented and Stage 4 was not started.

Proposed focused corrective Tasks (not started or marked owner-approved):

1. **S3.V1:** refresh retained import state before re-entry/open/save; protect later rig edits
   and deleted rigs; add real-route SQLite regressions (S3V-01).
2. **S3.V2:** preserve unknown/copied per-field provenance without inventing a user source;
   replace the contradictory legacy test with contract assertions (S3V-02).
3. **S3.V3:** distinguish kept values, explicit imported replacements and copied saved values;
   preserve exact saved numbers and make conflict replacement effective (S3V-03/04).
4. **S3.V4:** enforce/document sensible metadata-dimension validation and add absurd cases
   across the shared extraction path (S3V-05).
5. **S3.V5:** complete the stipulated real-database widget acceptance matrix; reconcile
   current-state visibility wording, rerun all probes/gates and perform the device recheck
   where practical (S3V-06/07/08). Then repeat Stage validation, preferably in a fresh chat.
