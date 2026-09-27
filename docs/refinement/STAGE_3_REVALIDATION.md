# Stage 3 repeat validation: PASS

Date: 2026-09-27. Stage: **3 — Metadata → Equipment / Device Import**.
Validated code: `d5e2b6058d92cee0852a8b1769ce0821fc1ad6fc` (S3.V6).

## Scope and repository state

- The tree was clean on entry. Reviewed the original Stage 3 scope and the corrective
  range `387e54b..d5e2b60`, particularly the six implementation commits below.
- Authority: the owner's validation prompt, frozen Stage 3 acceptance, ADR-018,
  the first validation, and the owner-approved corrective acceptance in DECISIONS E.1.
- This is a repeat validation in the existing chat, **not a fresh-chat validation**.
  The validator previously wrote the failed report and contributed debug access/TD-066;
  it did not implement S3.V1–S3.V6. The corrective claims were independently checked
  against code, unchanged archived expectations, real SQLite and the current gate.
- No application code, existing tests, dependencies or Android configuration changed.
  Temporary probes were removed after execution. This delivery changes only the new
  report/evidence and `PROGRESS.md`. The first failed report and its evidence are preserved.
- Stage 2's waiver and deferred catalog, FITS/proprietary RAW and cloud-provider work
  were not reopened. No Stage 4 work was performed.

## Executed verification

| Check | Result |
| --- | --- |
| `dart run tool/check.dart` | **PASS**: encoding, formatting, static analysis, **1,195 unit/widget tests**, one expected local-sample skip, **2 host E2E tests**. Run began on the clean baseline; temporary probes were created after the normal unit suite had been enumerated and are not in that count |
| Archived P1–P10 plus new R1, in one `flutter test --no-pub` invocation | **11 pass, zero failures**. Restored the original Dart blocks from `STAGE_3_VALIDATION_PROBES.md`. Only P5's call changed to the new asynchronous `rigDraft(rigId)` API; assertions were unchanged |
| Real sample test with `ASTROPLAN_METADATA_SAMPLES` set | **PASS**: both DNGs, JPEG and HEIC give all expected contract fields, including dimensions. Reads remain **856 / 856 / 843 / 4,051 bytes**, in 12 / 12 / 16 / 17 ranges |
| `android/gradlew.bat :app:testDebugUnitTest --offline --rerun`, Android Studio JBR | **PASS**: four native streaming-reader tests, zero failures/errors; fresh XML result inspected |
| Code and test review | Candidate/CALC-40 and matching contracts; dimension bounds; exact-value and provenance handling; async draft creation; real-route review tests; migrations, backup/restore, failure rollback, accessibility and phone-width regressions |

The commands, P5 adaptation, new R1 source and probe output are in
[the repeat evidence record](evidence/STAGE_3_REVALIDATION_PROBES.md).

## Previous findings rechecked

| Finding | Current result | Evidence |
| --- | --- | --- |
| S3V-01 — stale review overwrites newer rig edits | **Resolved; CODE / TEST VERIFIED** | `62a79af` refreshes review and withdraws choices made against changed values; `d5e2b60` removes the synchronous stale-match draft APIs. `rigDraft(id)` and `newRigDraftWithCameraOf(id)` reread saved rigs. Archived P5 and real-widget/SQLite P8 pass: 45 MB stays 45 MB. Permanent tests cover re-entry, edits while review is open, withdrawn choices and deleted rigs |
| S3V-02 — invented provenance | **Resolved; CODE / TEST VERIFIED** | `edbb2a7` adds an explicit unknown marker in existing nullable source/confidence columns; it blocks group fallback. Unchanged legacy and copied fields stay unknown, edited fields become user/reported. P1/P2 and persistence tests pass; the contradictory legacy assertion was corrected to the frozen contract |
| S3V-03 — explicit sensor choice retains old number | **Resolved; CODE / TEST VERIFIED** | `18873ad` stores exact numbers separately from displayed text. P3 now saves **9.89 × 7.42 mm** with the chosen estimate provenance, replacing 9.894 × 7.416. The permanent test also verifies the conflict disappears |
| S3V-04 — copied saved values are rounded | **Resolved; CODE / TEST VERIFIED** | Same commit; P4 preserves **9.894 mm, 2.414123 µm and 30.04 MB**, with verified provenance. Estimates still use S3.9 precision; user edits save typed numbers |
| S3V-05 — absurd dimensions remain known | **Resolved; CODE / TEST VERIFIED** | `2447962` applies the documented 65,535 px per-side metadata sanity bound through the shared conversion. P7 passes; committed tests cover DNG width/crop, JPEG, HEIC and 65,535/65,536 boundary behavior. Candidate equipment limits remain separate |
| S3V-06 — missing SQLite-backed review behavior tests | **Resolved; CODE / TEST VERIFIED** | `51f53cf` adds actual Equipment/review/editor routes over real in-memory Drift. Tests inspect all three equipment table counts: picker/review/editor cancellation, one new chain on Save, no duplicate on Open/Save, kept verified values, explicit replacement, another module and re-entry. The existing accessibility sweep still passes |
| S3V-07 — stale debug-only visibility wording | **Resolved; DOCUMENTED / CODE VERIFIED** | S3.V5 labels the old amendments historical in ADR-018, Feature Status and Progress; current visibility is Add from a photo on Equipment, all build modes. No contradictory current gate remains |
| S3V-08 — fresh device recheck | **UNVERIFIED, carried separately** | No device interaction was performed in this revalidation. Historical M4 remains the recorded DNG end-to-end device evidence. The owner explicitly kept a further Android/device recheck separate from S3.V5; it is not silently counted as completed here |

## Original Task acceptance

| Task | Result | Basis |
| --- | --- | --- |
| S3.R1 — identity research | **PASS (DOCUMENTED)** | RG-02 supplies the device classes, identity limits, derivability and decisions used by the implementation. No new external specification claim is made by this revalidation |
| S3.D — decisions/freeze | **PASS (DOCUMENTED)** | ADR-018 and owner D1–D4 remain authoritative; deferred external catalogs/extra formats stay out |
| S3.1 — geometry | **PASS** | Main-image DNG/crop rules, EXIF geometry, malformed/ambiguous/absurd cases, portrait handling, exclusions and budgets; current real samples pass |
| S3.2 — candidate/CALC-40 | **PASS** | Pure domain mapping, bounded estimate with stated uncertainty, unknown reasons, device-class and hand-computed cases; never verified and no inference of diameter, tracking, rotation or exposure limit |
| S3.3 — matching | **PASS** | Identity normalization/prefix rule, documented optics/FOV tolerances, ambiguity and capture modes, conflict provenance and default-keep semantics; no writes in matcher |
| S3.4 — persistence/provenance | **PASS** | v18 migrations and existing values preserved; all supported version schema checks pass; per-field and unknown marker persistence tests pass; P9 backup/restore and P10 transaction rollback pass |
| S3.5 — draft/editor | **PASS** | Required unknowns block Save; exact chosen/copied values and provenance survive; changed values are user-owned; ordinary Add/Edit behavior remains covered |
| S3.6 — review/confirmation | **PASS** | Real-database acceptance matrix now exists and passes; no write before Save, no automatic replacement or duplicate, stale state refreshed, planner refresh remains wired, accessibility sweep passes |
| S3.7 — visibility/TD-066/M4 | **PASS with recorded device limits** | Equipment entry and route enabled, Settings entry removed, non-Android unavailable state, fractional exposure display, local-only privacy behavior. M4 remains documented historical device evidence; a fresh device recheck is not claimed |
| S3.8 — DNG size | **PASS** | One-file decimal-MB estimate, DNG only, no JPEG/HEIC RAW-size proposal, saved value kept unless explicitly chosen |
| S3.9 — new-import rounding conflicts | **PASS** | Shared estimate precision and unchanged plausibility checks; DNG/JPEG round-trip regressions plus archived P6 pass |
| S3.10 — phone editor fit | **PASS (CODE / TEST VERIFIED)** | Roboto numeric-width checks at 375 dp/100–130%, expanded Tracking dropdown and accessibility coverage pass. Fresh physical-device confirmation remains part of S3V-08 |

## Corrective Task acceptance

| Task / commit | Result | Acceptance checked |
| --- | --- | --- |
| S3.V1 / `62a79af` | **PASS together with V6** | Reopening the review cannot restore a pre-edit rig snapshot; newer values withdraw older conflict choices |
| S3.V2 / `edbb2a7` | **PASS** | Only changed fields become user/reported; untouched legacy/copied unknowns survive repository reread |
| S3.V3 / `18873ad` | **PASS** | Explicit replacement applies the chosen number; untouched saved/verified values stay exact; estimates alone are proposed rounded |
| S3.V4 / `2447962` | **PASS** | Absurd dimensions rejected in shared parsing, with documented bound and cross-format regressions |
| S3.V5 / `51f53cf` | **PASS** | Required real-database review assertions are present and passing; obsolete visibility wording is explicitly historical |
| S3.V6 / `d5e2b60` | **PASS** | No public draft API consumes a retained `RigMatch`; current rigs are fetched for both existing-rig and camera-copy drafts; deleted/no-longer-related rigs yield no draft |

### Additional adversarial check

**R1 — PASS:** the file has no image geometry/35 mm equivalent and uses different optics,
so it must copy the saved camera rather than using its own estimate. After the review is
created, change the saved pixel pitch to **2.56789 µm**, then request a new rig with that
camera. SQLite contains the new exact pitch with user provenance; copied unknown sensor
provenance remains unknown; sensor width stays exact; focal length comes from the file.
This checks the actual fallback branch, which the existing V6 test's file-supplied estimate
does not exercise. No application defect was found.

## Verdict and remaining limits

**PASS.** All original Stage 3 Tasks and S3.V1–S3.V6 satisfy their defined implementation
acceptance on the available evidence. Every previous blocker is resolved and the independent
reproductions pass. No new blocking finding was established.

- **UNVERIFIED:** fresh Android recheck of the corrected flow and final phone layout,
  JPEG/HEIC through the complete import-save workflow, and the already-carried non-seekable
  provider/backup-preview device checks. Host/native JVM tests do not replace these.
- **Process disclosure:** this repeat occurred in the same chat at the user's request;
  it is not evidence of a new validator session. The main corrective implementation was
  performed elsewhere and its results were rerun here. The repository's §9.8 fresh-session
  sign-off requirement therefore remains pending; the request to revalidate is not recorded
  as an owner waiver. This is a technical PASS, not a claim of formal Stage closure.
- No application fixes or further Stage work were performed. Stage progression is subject
  to the remaining fresh-session sign-off or an explicit owner decision; Stage 4 was not started.
