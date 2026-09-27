# Stage 3 final sign-off validation: PASS

Date: 2026-09-27. Stage: **3 — Metadata → Equipment / Device Import**.
Validated: `92ebf2a` (S3.V8). The tree was clean on entry and is clean after the probes were removed.

## Session, authority and method

- **A fresh session.** This is the fresh-session sign-off that `PROGRESS.md` named as the next
  allowed action after S3.V7 and S3.V8 (§9.8; owner, DECISIONS E.1, "Stage 3 sign-off failed:
  corrective Tasks"). The session started from the repository. It had no earlier chat context,
  and it wrote none of the Stage 3 code, reports or probes it checked. (The assistant's local
  memory index, a one-line summary of progress, was loaded as background; every conclusion here
  rests on the repository and on commands run in this session.)
- **Authority:** `CLAUDE.md`; Stage 3's purpose, rules, exit and frozen and corrective Task
  acceptance (`POST_ROADMAP_PLAN.md`, Stage 3); ADR-018 and its implementation notes; the owner's
  S3.V7/S3.V8 acceptance (DECISIONS E.1); CALC-40 and SI-014. The earlier reports
  (`STAGE_3_VALIDATION.md`, `STAGE_3_REVALIDATION.md`, `STAGE_3_SIGNOFF_VALIDATION.md`) were read
  as evidence, not as conclusions.
- **Method:** read the S3.V7 and S3.V8 diffs and every consumer of the rig provenance (editor,
  snapshot builder, export codec, screens); re-run every archived probe; write new probes against
  the corrected areas and the paths next to them, over a real in-memory SQLite database; run the
  full gate, the Stage 3 targeted suites, the local real samples and the native JVM tests.
- **Nothing was fixed.** No application code, test, dependency or Android file changed. The
  temporary probe files were removed after the run; their source and output are in
  [the evidence record](evidence/STAGE_3_FINAL_SIGNOFF_PROBES.md).
- **Not reopened:** Stage 2's waiver; the deferred FITS, proprietary RAW and specification-source
  work; S3S-03 (TD-072, deferred by the owner); per-field snapshot provenance (TD-070, Stage 8).
  No new product requirement and no Stage 4 work.

## Executed verification

| Check | Result |
| --- | --- |
| `dart run tool/check.dart` at `92ebf2a`, clean tree | **PASS**: Encoding; Format (376 files, 0 changed); Analyze (no issues); **1,214 tests**, 1 expected local-sample skip; **2 host E2E tests**. The probes were added only after this run |
| Stage 3 targeted suites (metadata readers and samples test, equipment import, candidate, matcher, provenance and shared provenance, numeric fidelity, limits, schema migrations, equipment repository, snapshot builder, draft, camera-copy mode, round trip, editor, review with and without SQLite, stale-review VM, accessibility sweep) | **PASS**: 352 tests, 1 expected skip |
| `test/data/metadata/real_samples_test.dart` with `ASTROPLAN_METADATA_SAMPLES` set | **PASS**: 2 DNGs, the JPEG and the HEIC give every expected contract value. Reads 856 / 856 / 843 / 4,051 bytes in 12 / 12 / 16 / 17 ranges, unchanged |
| `android/gradlew.bat :app:testDebugUnitTest --offline --rerun` (Android Studio JBR) | **PASS**: 4 `MetadataSequentialReaderTest` cases, 0 failures, 0 errors (fresh XML inspected) |
| Archived probes P1–P10, R1, F1a, F1b, F2, F3, P+ (×2) | **15 pass, 2 fail as expected**: F1b and F3 pinned the S3S-01 and S3S-02 defects, and now fail because the defects are gone |
| New probes G1–G6, H1–H7 | **13 pass** (H4 is an observation) |
| Test integrity | S3.V7 and S3.V8 remove no assertion: their only changed lines in existing test files are a helper's parameter (`session_snapshot_builder_test.dart`) and new optional parameters with unchanged defaults (`test/support/metadata_candidates.dart`) |
| Device | **Not run.** No phone interaction in this session |

## Previous blocking findings

| Finding | Result | Evidence |
| --- | --- | --- |
| S3V-01 — a stale review reverts newer rig edits | **PASS** | P5 (ViewModel) and P8 (real routes and SQLite) pass: 45 MB stays 45 MB. H7: a cropped or binned file offers no conflict, and Open then Save leaves the saved rig exactly as it was |
| S3V-02 — invented `user` provenance | **PASS** | P1 and P2 pass. G4: a legacy rig still reads "source unknown" |
| S3V-03 — a chosen sensor size keeps the old number | **PASS** | P3 stores 9.89 × 7.42 mm with the estimate's provenance |
| S3V-04 — copied saved values rounded | **PASS** | P4 keeps 9.894 mm, 2.414123 µm and 30.04 MB, verified; H2 keeps the exact copy |
| S3V-05 — absurd image dimensions are known | **PASS** | P7 is unparseable; the real samples still give their dimensions |
| S3V-06 — no real-database review coverage | **PASS** | The SQLite review suite passes, including S3.V8's new case (Save waits for the user's pixel size, then writes one chain; the saved rig is unchanged) |
| S3V-07 — stale visibility wording (non-blocking) | **PASS** | Unchanged since S3.V5; the historical amendments stay marked |
| **S3S-01** — per-field provenance shown and snapshotted as the group's | **PASS** | See below |
| **S3S-02** — pixel pitch copied into another output mode | **PASS** | See below |

### S3S-01 (S3.V7, `1166986`): PASS

The owner's acceptance: the editor uses each value's stored provenance, and a rig-wide `user`
never presents estimated or imported values as the user's; no snapshot migration, but a
saved-session record never presents the rig-wide source as every field's; missing per-field
provenance is never replaced with an invented `user`.

- **Editor.** `_provenance` now reads `EquipmentProfile.groupProvenance`, which asks `provenanceOf`
  for each valued spec; the group pair is never shown alone. G1: an imported rig reread from
  SQLite reads "Resolution: reported (metadata:jpeg) · Pixel size: estimated
  (derived:calc-40/metadata:jpeg) · Sensor size: estimated (…) · Optics: reported
  (metadata:jpeg)", with no "user". G2 covers the inverse case the earlier report found by
  inspection: the verified seed with only its pixel size edited still reads verified for the
  untouched specs and user for the edited one. G3: a hand-typed rig reads exactly as before. G4:
  a legacy rig reads unknown. G5: the longer line does not overflow at 375 dp and 200 % text.
- **Snapshot.** `SessionSnapshotBuilder._rig` writes a group's pair only when every valued spec
  shares it, else null. G6 saves sessions through the real planner graph and rereads them from
  SQLite: the imported rig's plan snapshot has camera `null`/`null` and optics
  `metadata:jpeg`/`reported`; a hand-typed rig's has `user`. `"v": 1` is unchanged.
- **Other consumers.** No screen reads a snapshot's provenance, and the export codec reads only the
  rig's label from it. Snapshots saved before S3.V7 keep the group pair; that, and per-field
  snapshot provenance, are Stage 8's by the owner's decision (TD-070 stays partly resolved).

### S3S-02 (S3.V8, `92ebf2a`): PASS

The owner's option (a): when the photo's pixel dimensions differ from the saved rig's, its pixel
size and sensor size are not copied; they stay unknown until the user provides them; the
relationship is not inferred.

- H1 restates F3: a 2048 × 1536 file against a 4096 × 3072 rig leaves the pitch and both sensor
  sides empty, withholds exactly those two specs, keeps the file's resolution, and the editor
  says why with both pixel counts. The archived F3 now fails, because the untouched draft has no
  pixel size (the form's validator blocks Save in the UI; the committed SQLite review test shows
  it).
- H6: once the user types a pixel size, the pitch and the derived sensor size are the user's,
  the resolution stays the file's, resolution × pitch equals the sensor width, and the saved rig
  is untouched.
- Unchanged, as required: the equal-count copy (H2, exact, with the saved provenance), the
  orientation-free comparison (H3), the file's own CALC-40 estimate taking precedence even at
  another pixel count (H5, self-consistent), the no-geometry copy (R1) and the match itself.
- `EquipmentMatcher.samePixelCount` is shared by the mode check and the draft, so the two cannot
  disagree. SI-014, TD-071 and ADR-018's S3.V8 note record the rule.

## Original Stage 3 acceptance

| Task | Result | Basis |
| --- | --- | --- |
| S3.R1, S3.D | **PASS (documented)** | RG-02 and ADR-018 still match the implementation, including the S3.V7 and S3.V8 notes |
| S3.1, S3.V4 | **PASS** | Dimension rules and the 65,535 px bound (P7, targeted suites); the real samples unchanged |
| S3.2 | **PASS** | CALC-40 gating and precision unchanged by S3.V7/S3.V8 (targeted suites; H5 self-consistent); never `verified` |
| S3.3 | **PASS**, S3S-03 deferred | The mode check now calls `samePixelCount` with the same logic as before; F2 still shows the deferred order-sensitive conflict |
| S3.4, S3.V2 | **PASS** | v18 migrations and per-field storage (targeted suites; P1, P2, P9, P10, P+) |
| S3.5, S3.V3 | **PASS** | Exact values and notes (P3, P4, H2); the withheld rule (H1, H6) |
| S3.6, S3.V1, S3.V5, S3.V6 | **PASS** | Save is the only write; re-match on entry and before Open (P5, P8, H7); the SQLite review suite and the accessibility sweep pass |
| S3.7 | **PASS, with the recorded device evidence** | Visibility and routes unchanged; M4 (`2b045eb`) is the recorded device evidence |
| S3.8, S3.9, S3.10 | **PASS** | Unchanged since the earlier reports; their tests pass in the gate |
| S3.V7, S3.V8 | **PASS** | Above |

**Stage exit (`POST_ROADMAP_PLAN.md`, Stage 3):** the ADR is accepted; the import proposes
candidates with provenance and confidence; the user confirms before anything is stored; tests
cover conflicts; no external source is used (nothing leaves the device; S3.7 updated the privacy
and Data Safety notes anyway); and this validation passes. **All met.**

## Findings

### S3F-01 — NON-BLOCKING: a portrait-entered rig's sensor size is copied transposed

- **Evidence (H4).** A saved rig typed in portrait (3072 × 4096 px, 7.416 × 9.894 mm). A landscape
  file of the same camera and pixel count, other optics, no 35 mm equivalent. "New rig with the
  camera specs of" gives 4096 × 3072 px with a 7.416 × 9.894 mm sensor.
- **Consequence.** Only the orientation is mixed. The pitch is right, so the pixel scale and NPF
  are right, and so are the diagonal FOV and the NPF's declination. The FOV's width and height
  are swapped. It needs a rig entered in portrait.
- **Why not blocking.** It is the same root cause as S3S-03 (TD-072: sizes handled in stored
  order), which the owner deferred "unless new evidence shows it affects correctness"; this case
  changes no computed quantity except the FOV's orientation. It is not a regression: before
  S3.V8 the copy happened in the same way, and S3.V8's orientation-free check is what the
  mode check already did.
- **Recorded** as an addendum to TD-072, for the same later Equipment or data-entry cleanup.

### S3F-02 — NON-BLOCKING (observation): the RAW size is still copied across pixel counts

- **Evidence (code).** In the same "another pixel count" case, `EquipmentDraft.fromCandidate`
  still copies the saved rig's average RAW size (`rawFileSize` fallback), labelled "From your saved
  rig". Option (a) names only the pixel size and the sensor size, and S3.V8's commit states that the
  RAW size fallback is unchanged.
- **Consequence.** A storage estimate, shown with its origin and editable; no astronomical quantity
  depends on it.
- **No Task proposed.** It is within the owner's decision as written. Recorded in the report and
  as a note on TD-071, for the owner to rule on if wanted.

### Carried, unchanged

- **S3S-03 (TD-072)** — NON-BLOCKING, deferred by the owner; F2 still reproduces it.
- **TD-070 (remainder)** — per-field snapshot provenance and snapshots saved before S3.V7: Stage 8,
  by the owner's decision.
- **S3V-08** — UNVERIFIED: see below.

### S3V-08 — UNVERIFIED (carried, device)

No device interaction in this session, so nothing here is DEVICE VERIFIED. The recorded device
evidence for Stage 3 is M4 (`2b045eb`, a real DNG through match → pre-filled editor → Save on the
owner's phone, through the separate `.s2check` package), plus M1–M3 for the readers. A recheck of
the corrected flow (S3.V1–S3.V8), JPEG/HEIC through import-save, and the final phone layout, and
S2V-06's carried checks (a non-seekable provider; a real backup's preview cancel), stay a separate
device action through `.s2check` only, never the owner's installed app. The corrective-Task table
left this "not decided; kept apart", and S3.7's own acceptance (M4) is met, so it does not block
the Stage.

## Verdict

**PASS.** Every original Stage 3 Task and every corrective Task (S3.V1–S3.V8) meets its acceptance
on executed evidence; all previous blocking findings (S3V-01 to S3V-06, S3S-01, S3S-02) are
resolved and their reproductions pass; no regression was found around per-field provenance,
saved-session snapshots, stale review state, numeric fidelity, the camera-spec copy or the real
database. Two new findings are non-blocking and recorded; S3V-08 stays unverified at the device
level.

- Stage 3 is **closed** with this sign-off.
- **Next allowed action: Stage 4 planning** (Product Flow & Information Architecture). No Stage 4
  Task is started by this validation.
