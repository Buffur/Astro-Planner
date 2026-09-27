# Stage 3 fresh-session sign-off validation: FAIL

Date: 2026-09-27. Stage: **3 — Metadata → Equipment / Device Import**.
Validated: `74026ca`. Its application code is identical to `d5e2b60` (S3.V6); the only later
commit is the documentation of the repeat validation.

## Session, authority and method

- **A fresh session.** This is the §9.8 fresh-session validation that `PROGRESS.md` named as the
  next allowed action. The session started from the repository alone. It had no earlier chat
  context and did not write any Stage 3 code, report or probe.
- **Authority:** `CLAUDE.md`; Stage 3's exit and common rules and the frozen and corrective Task
  acceptance (`POST_ROADMAP_PLAN.md`, Stage 3); ADR-018 with its implementation notes; CALC-40.
  The earlier reports (`STAGE_3_VALIDATION.md`, `STAGE_3_REVALIDATION.md`) were read as evidence,
  not as conclusions.
- **Method:** read the Stage 3 code paths (candidate, CALC-40, matcher, provenance model,
  repository mapping, form model, review ViewModel and screen, editor). Then look for behaviour
  the earlier probes P1–P10 and R1 did not exercise, and reproduce it with new synthetic probes
  over a real in-memory SQLite database.
- **Nothing was fixed.** No application code, test, dependency or Android file changed. The one
  temporary probe file was removed after the run. Its source and output are preserved in
  [the evidence record](evidence/STAGE_3_SIGNOFF_PROBES.md).
- **Not reopened:** Stage 2's waiver, and the deferred FITS, proprietary RAW and specification-source
  work. No Stage 4 work.

## Executed verification

| Check | Result |
| --- | --- |
| `dart run tool/check.dart` at `74026ca` | **PASS**: encoding, format, analysis, **1,195 tests** (one expected local-sample skip), **2 host E2E tests** |
| `test/data/metadata/real_samples_test.dart` with `ASTROPLAN_METADATA_SAMPLES` set | **PASS**: 2 DNGs, the JPEG and the HEIC. Reads: 856 / 856 / 843 / 4,051 bytes in 12 / 12 / 16 / 17 ranges, as recorded before |
| `android/gradlew.bat :app:testDebugUnitTest --offline --rerun` (Android Studio JBR) | **PASS**: 4 `MetadataSequentialReaderTest` cases, 0 failures, 0 errors (fresh XML inspected) |
| New sign-off probes (`zz_stage3_signoff_test.dart`, 6 tests) | **6 pass**. Four pin defective behaviour (S3S-01 to S3S-03). Two positive checks found no defect |
| Device | **Not run.** No phone interaction in this session. S3V-08 stays unverified |

## What holds (confirmed independently)

- **Candidate and CALC-40:** pure domain code. The formula matches ADR-018 §4 and the CALC-40 row. The
  estimate is withheld when an input is unknown, ambiguous, f₃₅ ≤ f or out of limits. It is only
  ever `estimated`. D, rotation, tracking and exposure limit are never proposed. No network.
- **Matching:** stated rules with reasons, no score. Stored import identity is used before labels,
  with the prefix rule, the 1 % optics tolerance and the 10 % field-of-view tolerance. Ambiguity
  goes to the user. The matcher writes nothing.
- **Confirmation:** the only write is the editor's Save. The review re-matches on entry and before
  opening a rig (S3.V1, S3.V6). Choices made against since-changed values are withdrawn.
- **Storage:** v18 per-field pairs and the explicit unknown marker round-trip. A hand edit of an imported
  rig marks only the changed field `user` (positive probe). A likely-same open-and-save keeps the
  DNG identity and the per-field provenance (positive probe).
- **Regressions:** none found in the gate, the real samples or the native tests.

## Findings

### S3S-01 — BLOCKING: saved per-field provenance is shown and snapshotted as the user's own

- **Requirement.** ADR-018 §5: "A field's provenance is its own pair, else its group's existing pair".
  Stage 3's common rules: "no estimate passed off as a measured value", "unknown stays unknown".
  ADR-018 §4: CALC-40 is "only ever `estimated`".
- **Evidence (code).** The import saves a new rig through `withEditProvenance(null)`, so the group
  pairs are `user`/`reported`. The values' real origins sit in the per-field pairs. Two consumers
  still read only the group pairs:
  - the rig editor's provenance line, `_provenance(existing)` in `equipment_editor.dart:44–48`;
  - the session snapshot's rig, `session_snapshot_builder.dart:106–109`. Snapshots are embedded in
    exports as stored (`EXPORT_MANIFEST.md`).
- **Reproduction (F1a, F1b; TEST VERIFIED, real SQLite and the real editor).** Import a phone JPEG,
  accept the estimates, and save.
  - The database holds sensor size and pitch as `derived:calc-40/metadata:jpeg (estimated)`, and
    resolution and focal length as `metadata:jpeg (reported)`.
  - Reopening the rig in the editor shows **"Camera specs: reported (user) · Optics: reported (user)"**.
  - A session planned with this rig records `cameraSource: user`, `cameraConfidence: reported` in
    its snapshot.
- **Consequence.** In every normal import, the one place the app shows a saved rig's provenance
  attributes CALC-40 estimates and file values to the user's own entry. Sessions record the same
  attribution permanently.

  The inverse also happens (code inspection, not probed). Editing one spec of the verified seed makes the line say
  "reported (user)" for the whole camera, though its other specs stay verified per field.

  DATA_MODEL (v18 row) records that "session snapshots still carry the group provenance only". It
  does not record that, for imported rigs, the group pair is then wrong.
- **Not covered by the Task acceptance.** S3.4 required the manual editor's behaviour to be
  unchanged, and the editor line was left as it was. The defect is in the Stage's own provenance
  rule, not in a Task check. That is why earlier validations, which checked the Tasks, passed it.
- **Proposed focused Task (S3.V7).**
  - The editor states each saved spec's provenance through `provenanceOf`, so an estimate reads
    as estimated and an unknown as unknown.
  - **Owner choice for the snapshot:**
    - **(a)** Record per-field provenance in new rig snapshots, as an additive key under ADR-014 §4's
      snapshot format. The export codec and `EXPORT_MANIFEST.md` go in the same change, deciding
      whether `"v"` changes.
    - **(b)** Defer the snapshot to Stage 8 as recorded debt (TD-070 keeps it).
  - **Acceptance:** an imported rig's editor never says "user" for an untouched imported or
    estimated value. A verified value edited elsewhere in its group still reads verified. Under
    (a), a snapshot round-trip test.

### S3S-02 — BLOCKING (scientific integrity): a copied pixel pitch can belong to another output mode

- **Requirement.** ADR-018 §4 and CALC-40: pitch is "the pitch of the output mode (binned or full
  resolution), which is what the planner's pixel scale needs". ADR-018 §6: a different pixel count
  is another capture mode, "never merged silently". RG-02 §5: each module × mode is its own rig.
- **Evidence (code).** In "same camera, other optics", `EquipmentDraft.fromCandidate(c, cameraFrom:)`
  takes the file's own values first, including its pixel dimensions. It copies the saved rig's
  pitch and sensor size only where the file gives none (`equipment_draft.dart`, `fill(...,
  fallback:)`). Neither the matcher nor the draft compares the file's pixel count with the saved
  rig's in this outcome.
- **Reproduction (F3; TEST VERIFIED, real SQLite).** A hand-entered rig: 4096 × 3072 px, 2.414 µm,
  9.894 mm. A file of the same camera with other optics: a 2048 × 1536 output, no 35 mm equivalent,
  so no estimate. Choosing "New rig with the camera specs of …" and saving untouched gives
  2048 × 1536 px with a 2.414 µm pitch and a 9.894 mm sensor. Resolution × pitch = **4.944 mm, half
  the stored width**.
- **Consequence.** The planner's pixel scale and NPF use `pixelPitchUm`
  (`capability_calculator.dart`, `capture_analysis_viewmodel.dart`). For this rig the pixel scale
  is 2× too fine for the images actually recorded. The editor's notes say "From the file (JPEG)" and
  "From your saved rig", but nothing says the two describe different modes.

  The case needs a file with pixel dimensions but no usable 35 mm equivalent. That is a
  full-frame body (f₃₅ = f), a body that writes no equivalent, or a reduced-size JPEG. It is not the
  owner's phone path, where the estimate takes precedence.
- **Proposed focused Task (S3.V8), owner choice of rule.**
  - **(a) Recommended:** when the file's pixel count is known and differs from the saved rig's, do
    not copy pitch or sensor size. They stay empty for the user, with the reason shown. A binned
    mode changes the pitch and a crop mode changes the sensor size, and the file cannot say which.
  - **(b)** Copy them, but show a mismatch warning and require an explicit confirmation.
  - **Acceptance:** F3's scenario cannot save an inconsistent pitch without the user's own entry or
    explicit choice. The equal-pixel-count copy (R1's path) is unchanged.
  - Record the rule in `SCIENTIFIC_INTEGRITY.md` (SI-014) and ADR-018's notes.

### S3S-03 — NON-BLOCKING (low): a portrait-entered rig gets transposed "conflicts"

- **Evidence.** The mode check compares long and short sides, but `_conflicts` compares the saved
  `[width, height]` and `[sensorW, sensorH]` in stored order (`equipment_matcher.dart`, `compare`).
- **Reproduction (F2).** A rig typed as 3072 × 4096 px and 7.416 × 9.894 mm, against a landscape file of
  the same camera and optics: `sameRig`, with two "conflicts" that are the same values
  transposed.
- **Consequence.** A spurious "use the file's value" switch. Keep stays the default, so nothing
  changes unless it is chosen. Taking only one of the two would leave the rig with mixed
  orientation.
- **Direction.** Compare sizes orientation-free, as the mode check already does. It can be folded into
  S3.V8 or left as TD-072.

### S3V-08 — UNVERIFIED (carried)

No device interaction in this session. M4 (`2b045eb`) remains the recorded device evidence. A
recheck of the corrected flow and the final phone layout, through the separate `.s2check` package
only, stays a separate action.

## Task results

| Task | Result | Note |
| --- | --- | --- |
| S3.R1, S3.D | PASS (documented) | RG-02 and ADR-018 match the implementation |
| S3.1, S3.V4 | PASS | Real samples and dimension bounds rechecked |
| S3.2 | PASS | Formula and gating read against CALC-40; an estimate is never `verified` |
| S3.3 | PASS, with S3S-03 | The rules are as specified; conflicts are order-sensitive for sizes |
| S3.4, S3.V2 | PASS for storage; **S3S-01** in its consumers | Per-field pairs are correct in the database. The editor line and snapshots ignore them |
| S3.5, S3.V3 | PASS for pre-fill; **S3S-02** in the camera-copy rule | Exact values and notes hold. Copying across output modes is unguarded |
| S3.6, S3.V1, S3.V5, S3.V6 | PASS | Re-match on entry and before opening; Save is the only write; the real-database tests pass |
| S3.7, S3.8, S3.9, S3.10 | PASS (device limits as recorded) | Unchanged since the repeat validation |

## Verdict

**FAIL.** Two blocking findings survive, S3S-01 (provenance) and S3S-02 (scientific integrity).
Both are small, focused and reproducible. S3S-03 is non-blocking. S3V-08 stays unverified.

- Stage 3 is **not closed**. Stage 4 has not started.
- The owner decides:
  - whether to approve S3.V7 and S3.V8, with their options: snapshot (a/b) and copy rule (a/b);
  - whether S3S-03 joins S3.V8;
  - or whether to waive.
- After the fixes, a fresh-session validation, or the owner's waiver.
