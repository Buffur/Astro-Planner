# Stages 12–17 — final roadmap readiness review

> **Date:** 2026-10-17. **Baseline:** `e564ee7` (documentation; application code unchanged since
> `461e38c`). **Type:** a bounded completeness check of the approved Culmina roadmap
> (`POST_ROADMAP_PLAN.md` §5, "Stages 12–17", G3), requested by the owner. Documentation only: no
> application code, tests or gate runs (V1 documentation class).
> **Not reopened:** RA.R1, RA.R2, RA.D (ID-1 to ID-6, PD-02 to PD-22, Q1 to Q4), RA.P/G3, the
> GitHub-only distribution decision. No new functionality is proposed.
> **Sources read:** `CLAUDE.md`; `PROGRESS.md` (current state); `POST_ROADMAP_PLAN.md` §5 Stages 12–17
> and their traceability; DECISIONS E.1 (the RA.D, G3 and distribution records);
> `research/RA_D_ROUND2_PACKAGE.md` (Parts A–D); `research/RA_D_IDENTITY_TRANSITION.md`;
> `research/RA_R1_PHASE_A_ASSESSMENT.md` §3–§4 (the coverage matrix of the owner's review
> review-01.10.2026); `prompts/PRODUCT_REASSESSMENT.md`; `PRODUCT_DIRECTION.md`; `TECH_DEBT.md` and
> `SCIENTIFIC_INTEGRITY.md` (open items); `STAGE_11_MATRIX.md` (mandatory rows); code facts in
> `lib/data/backup/backup_archive.dart` and `lib/data/repositories/shared_prefs_weather_snapshot_store.dart`.
> **Applied 2026-10-17:** the owner approved C1–C6; they are applied in `POST_ROADMAP_PLAN.md` §5 and
> `PRODUCT_DIRECTION.md` §9 (DECISIONS E.1, "Stages 12–17 readiness review corrections approved").

## 1. Verdict

**The roadmap is complete in scope and approved-requirement coverage, with one execution-order defect
and four smaller gaps.** Every RA.D decision and every finding of the owner's review has a responsible
Task or an explicit exclusion. The corrections in §5 are minimal: dependency and acceptance wording
in Stages 14, 16 and 17 plus a documentation supersession note. None adds functionality or reopens a
decision. They need the owner's approval before they are applied, because they amend frozen Task
text (V4: a review does not add acceptance criteria by itself).

## 2. Coverage of the approved requirements

| Area | Approved requirement (source) | Stage / Task |
| --- | --- | --- |
| Capture Plan | Camera class first, example rig classed (PD-07) | S14.2; onboarding S16.1 |
| | Schema v26: WB, value sources, capture format/bits/compression (RA.D 2A "Data") | S14.1 design, S14.3 |
| | Metadata reuse: contract extension, no second parser (PD-11) | S14.4; FITS S14.5; "Take from a photo" S14.9 |
| | Provenance of proposed/inherited values; RA-F05 (PD-08) | S14.6 |
| | Storage evidence chain, binning rule (PD-06) | S14.1, S14.7 (S14.3–S14.5 inputs) |
| | White balance record (PD-09) | S14.8 (fields), S14.9 (proposal) |
| | Assisted calibration CAL-1 (PD-12) | S14.10 |
| | Relative improvement over integration time, never "SNR" (PD-05) | S14.11 |
| | Effective assumptions, focus reminder, K12, TD-074 (PD-14, PD-10) | S14.12 |
| | Example-plan action removed after PD-08/11/12 (PD-13) | S14.13 |
| | Interval stays global (PD-21) | Invariant; no Task needed |
| Screens | Onboarding O-2′, first-frame route RA-B01 (PD-02) | S16.1 |
| | Home H-W, no New plan (PD-03, Q1) | S16.2 |
| | Planner checklist, weather row, compact chart, TD-095 (PD-04, Q1) | S16.3 |
| | Weather: 16-night overview, details, seeing link (PD-16, Q3) | S15.4, S15.5 |
| | Moon: MF-c, moon-free hours, phase, calendar, night bar (Q2, PD-17) | S15.1, S15.2, S15.3, S15.6 |
| | Logbook/Library: Progress segment, visible Delete, Plan this target, stored forecast (PD-19) | S16.4 |
| | AstroBin acquisition CSV (Q4) | S16.5 |
| | Settings: Appearance, units, backup keys (PD-20) | S16.6 |
| Identity | Trademark check (recommended), policy text and URL transition | S12.2, S12.3 |
| | Logo sketches, review sheet, owner approval (ID-5, P9.4) | S13.1 |
| | Id `io.github.buffur.culmina`, name, URLs, TD-088/TD-093 (ID-1–ID-4) | S13.2 |
| | Launcher icon and animated splash S2 (ID-6) | S13.3 |
| Defects / debt | TD-104 | S12.1 (done) |
| | RA-B01, RA-F05, RA-G03, K12 (verify, then fix) | S16.1, S14.6, S16.4, S14.12 |
| | TD-049, 072, 074, 088, 093, 094–103, 038; re-check 020, 025, 031; TD-045 excluded | S15.4, S14.9, S14.12, S13.2, S16.3, S16.7, S16.8, S12.3 (TD-099) |
| | S11P-03 licence decision | S12.4 (→ S16.8 for option b) |
| Data | v26 migration and tests; manifest v2 additive; backup by table | S14.3 |
| | Backup and restore across ids | S13.2 (criteria 4–6) |
| | Weather cache migration, TD-049 (SharedPreferences, no schema) | S15.4 |
| | New preference keys in `BackupPreferences` | S16.6 |
| Science | ADR-021, ADR-022 with hand-computed vectors; SI-013, SI-014, SI-015; CALC-16/42/29/33/43 | S14.1, S14.7, S14.9, S14.11, S15.1–S15.3 |
| Quality | Owner render review, sweep, light/dark/field, 100/200 % (K14) | Shared UI rule; S16.7 |
| | Device checks on `.s2check`; TalkBack; darkness; perf; metadata; lifecycle | S13.2, S13.3, S14.9, S15.6, S17.5 |
| Release | Matrix re-baseline (Stage 11 folded in); host, emulator, providers | S17.1–S17.4 |
| | Signed APK, APK check, `RELEASE.md`, checksums, fingerprint | S17.6 |
| | Go/no-go; owner publishes the GitHub Release, downloaded APK verified | S17.7, S17.8 |

**The owner's review (RA-A … RA-I, K1–K14):** every finding in the RA.R1 matrix appears in the
roadmap's traceability table with a Task or a disposition (checked row by row). Two sub-points have
no explicit disposition (see G6).

## 3. Findings

| ID | Severity | Finding | Evidence |
| --- | --- | --- | --- |
| **G1** | **Order defect** | **S17.5 and S17.6 depend on each other.** S17.5 must install "the signed release APK from S17.6" (N5), while S17.6 depends on S17.2–S17.5. Also, S17.6 changes `tool/` (the APK check) and the release version in `pubspec.yaml` after S17.2's final gate and remote CI run, so no remote CI run covers the release commit, and the phone runs would test a build older than the released one (V3: both are gate inputs) | `POST_ROADMAP_PLAN.md` S17.5, S17.6 rows; CLAUDE.md V3 |
| **G2** | Gap (data) | **The real identity migration is not rehearsed on the final build.** S13.2 tests backup and restore across ids, but at that point both builds are schema v25. The owner's real path (S17.6 item 6) is old id at its shipped schema → new id at v26 or later. Restoring an older backup is supported by code (`backup_archive.dart`: refused only when newer or below the floor), but the cross-id and cross-schema combination is never run on test packages before the owner's data moves. RA.D Part D item 9 asked for "the identity migration's backup and restore" in the final phone runs; S17.5 does not list it | S13.2; S17.3 (same-id round trip only); S17.5; `RA_D_ROUND2_PACKAGE.md` A.4 last paragraph, Part D item 9 |
| **G3** | Gap (dependency) | **S14.9 does not depend on S14.7 or S14.8,** yet it proposes the white-balance mode into S14.8's fields and feeds "size and format evidence for S14.7". S14.7 (1) also mentions "a file picked for a block", which is S14.9's action: which Task builds the block-level pick, and whether a block's measured size is persisted (not in S14.3's column list), is unstated | S14.7, S14.8, S14.9 rows; S14.3 (1); RA.D Part D item 4 (order: storage → WB → Take from a photo) |
| **G4** | Gap (scope owner) | **S12.4 option (a) has no implementing Task for its About change.** Option (a) is "accept it and state it in COMPLIANCE and About"; About is application code, but S12.4 is classed "Owner decision; documentation" and S16.8 implements only option (b) | S12.4, S16.8 rows |
| **G5** | Gap (documentation) | **`PRODUCT_DIRECTION.md` still states the superseded direction.** It is precedence level 3 for implementing Tasks, yet: §8 defers "a theoretical storage payload" (superseded by PD-06, S14.7) and "localisation and unit preferences" (units superseded by PD-20, S16.6); §10 records RD-04's "Start from the example plan" (PD-13) and RG-05's plan-first Tonight (PD-03); §1 names "Astro Planner" (ID-1). Its last note says the reassessment approves nothing yet. An implementing session could stop on a false conflict | `PRODUCT_DIRECTION.md` header, §1, §8, §10; DECISIONS E.1 RA.D records |
| **G6** | Clarity (low) | Register and traceability omissions: (a) TD-002 is still listed open with a "still open" remainder in code that no longer exists (`PlannerViewModel` removed in 12.3), and no Task re-checks it; (b) TD-099 is planned in S12.3 but missing from the open-TD list; (c) RA-H03's "no language" and RA-C04's "light animations" have no explicit disposition (localisation is deferred in `PRODUCT_DIRECTION.md` §8; animations are not an RA.D decision beyond the splash) | `TECH_DEBT.md` TD-002; traceability table |

Checked and **not** gaps: the weather cache is SharedPreferences (S15.4 needs no schema step);
older-schema backups restore by design; CALC-28's rise and set already use h₀, so S15.2's list
(CALC-29/33/43) is consistent with Q2; the Stage 11 mandatory store-only rows (N7–N9, O10, O11, Q2)
are handled by S17.1 and S17.7 as DEFERRED; the S2V-06 and S3V-08 device items are in S17.5.

## 4. Dependencies, owner actions and risks

**Critical path:** S12.3 (owner: email, rename, Pages) → S13.2 → S13.3 (also needs S13.1's approved
artwork) · S14.1 (owner accepts ADR-021) → S14.3 → S14.4 → S14.7 → S14.8 → S14.9 → S14.10 → S14.13 ·
S15.1 (owner accepts ADR-022) → S15.2 → S15.3 → S16.2 · S14.12 → S16.3 · S16.1–S16.6 → S16.7 →
Stage 17. S13.1 depends only on ID-5 and can run while the owner works on S12.3.

**Owner actions that can block:** the contact email (S12.3); the repository rename and Pages
(S12.3, blocks S13.2); the S11P-03 choice (S12.4); the trademark check (S12.2, recommended); the logo
approval (S13.1 → S13.3); acceptance of ADR-021 and ADR-022; **a real astro-camera FITS file**
(S14.5, blocks Stage 14's close; the owner skipped FITS samples in S2.R2); render reviews in every UI
Task; phone availability (S13.2, S13.3, S14.9, S15.6, S17.5); human rows (TalkBack, darkness);
push authorizations for each required remote CI run; the release keystore (S17.6); go/no-go (S17.7);
publishing (S17.8).

**Main technical risks:** the id change (Gradle, Kotlin package, the metadata channel together); the
v26 migration and snapshot/manifest keys; MF-c re-deriving ADR-013's vectors; the 16-night cache
change; the release-key permanence from the first public release; volume (41 Tasks plus six Stage
validations).

## 5. Minimal corrections (approved and applied 2026-10-17)

| # | Fixes | Correction |
| --- | --- | --- |
| C1 | G1 | S17.6 depends on S17.1–S17.4 (not S17.5); S17.6 adds "a green remote CI run on the release commit" (the release version and the APK check are in it). S17.5 depends on S17.6 and runs N5 and the other phone rows on the signed release-candidate APK. S17.6 item (6) (the owner's data) moves after S17.5. S17.7 unchanged. No renumbering. Any application change after S17.6 rebuilds the APK and re-runs the affected rows (V3) |
| C2 | G2 | S17.5 adds: "the identity migration rehearsal on the release candidate: a backup from the old-id build at its shipped schema restored into the new-id build on test packages; counts and fields equal (`RA_D_IDENTITY_TRANSITION.md` §3, criteria 4–6); before S17.6's owner data step" |
| C3 | G3 | S14.9 depends on S14.7 and S14.8 as well. S14.7 (1) reads: "for the rig, or for a block once S14.9 provides the block's file". S14.1 states whether a block's measured size is persisted, and S14.3 (1) reads "the columns ADR-021 defines, including …" |
| C4 | G4 | S16.8 adds "S12.4 (a): the About statement, if chosen" beside option (b) |
| C5 | G5 | A dated supersession note in `PRODUCT_DIRECTION.md` (header and §9), pointing to DECISIONS E.1 for ID-1, PD-03, PD-06, PD-13, PD-20, Q1 and the GitHub-only distribution; historical text kept (documentation class) |
| C6 | G6 | S16.8's re-check list adds TD-002; the open-TD list adds TD-099 → S12.3; the traceability table records RA-H03 language as deferred (`PRODUCT_DIRECTION.md` §8) and RA-C04's small animations as "within `AppMotion` per UI Task; no separate Task" |

## 6. Next Task and remaining scope

- **Recommended next Task:** **S12.3** (policy text), once the owner supplies the contact email,
  with the owner's **S12.4** decision in the same exchange. If the email is not yet available,
  **S13.1** (logo sketches; depends only on ID-5) is the unblocked alternative. The corrections in §5
  can be applied in one documentation change before or alongside S12.3.
- **Remaining:** six Stages (Stage 12 in progress: S12.2–S12.4; then Stages 13–17), 41 Tasks.
