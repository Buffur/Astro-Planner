# AstroPlan — Refinement Progress

> The handoff contract for post-roadmap refinement: where work stands, what still binds it, what
> evidence can be reused, and the one next allowed action. Strategy lives in `POST_ROADMAP_PLAN.md`,
> direction in `PRODUCT_DIRECTION.md`, verification rules in `CLAUDE.md` ("Verification Policy"),
> and history in [`PROGRESS_HISTORY.md`](PROGRESS_HISTORY.md) and the `STAGE_N_*.md` reports.
> **Last updated:** 2026-09-29 (**Stage 8 planned**: S8.1–S8.9 frozen; decisions delegated by the owner).
> **Next:** S8.1 (results without a run: domain and data). The owner asked for the whole of Stage 8.

## Current state

| Item | State |
| --- | --- |
| Phase | Post-roadmap refinement, Stages 0–11 (`POST_ROADMAP_PLAN.md`) |
| Current Stage | **Stage 8 — Sessions / Execution / Actuals / Logbook: In progress** (planned 2026-09-29). Stage 7 closed 2026-09-29 ([report](STAGE_7_VALIDATION.md)) |
| Current Task | None in progress |
| Next Task | **S8.1** (below, "Next allowed action") |
| Code baseline | **`d28f5a8` (S7.V2)**; `21e9cb1` changed README only. Not pushed (S1.14, RD-17) |
| Schema | **v23** (S7.5) |

**Stage 8 planned, 2026-09-29** (documentation only; the plan's "Stage 8 — frozen Task sequence"):
- **Verified against the code at `836bbdf` (§9.7).** Notable: a result can be recorded only through the
  tracker (`complete` accepts `inProgress` only); no Partly, Not done reason or name is stored; snapshot
  blocks have no ids and `capture_blocks` are re-inserted on every plan write, but a Saved row's blocks
  equal its snapshot's; saved plans keep a past night in the row while the planner shows tonight (D1);
  TD-063's mechanism is still present; the backup holds no preferences.
- **Decisions:** the owner delegated them to the agent in chat ("do not ask me; decide yourself").
  D8-1 (S4-DEF-02): a saved night ends at dawn at its snapshot's darkness limit, else at the night's end
  (CALC-44). D8-2 (S4-DEF-01): Save again before the night ends. D8-3 (RD-13): "Reported as planned";
  old estimates not relabelled. D8-4: Share without notes or coordinates. I-1 to I-10: the `reported`
  event, `result_kind` and `not_done_reason` (v24), results for legacy runs, settlement of Saved ·
  changed rows, unreadable snapshots, entry actions, stale forms, Tonight's line, the Logbook, the
  backup (DECISIONS E.1, "Stage 8 decisions").
- **Frozen:** S8.1 → S8.2 → S8.3 → S8.4 → S8.5 → S8.6 → S8.7 → S8.8 → S8.9 → Stage 8 validation. No
  gate is open.
- Stage 7's "Current state" entries moved verbatim to `PROGRESS_HISTORY.md`.
- **Verification:** the documentation class (V1): references and IDs resolve; `git diff --check`. No
  gate input changed, so S7.V2's gate is Stage 8's baseline (below).

**Before this:** Stage 7 closed on 2026-09-29 at `21e9cb1` ([report](STAGE_7_VALIDATION.md)); its
entries, from its planning to its closure, are in `PROGRESS_HISTORY.md`.

## Reusable validation evidence

Per `CLAUDE.md`, Verification Policy V3: reuse while the inputs are unchanged.

| Evidence | Ran at | Still valid because |
| --- | --- | --- |
| **Full quality gate PASS**: Encoding; Format (461 files, 0 changed); Analyze (no issues); 1,734 tests, 2 expected skips (the local real samples; the opt-in S5.9 render test); 2 host E2E | **`d28f5a8`**, S7.V2's final inputs | Ran after S7.V2's last code change; covers both corrections. Reused by the V5 revalidation: `git diff --stat d28f5a8 HEAD -- . ':!docs' ':!CLAUDE.md' ':!README.md'` empty at `21e9cb1`. Supersedes S7.V1's gate at `46e7688` (1,719) and S7.6's at `d13fdab` (1,710) |
| **Pinned catalog regeneration PASS**: 164 objects (109 Messier), output matches committed text after line-ending normalization | Stage 7 validation at `d13fdab` | Tool/asset unchanged; temporary source CSVs removed, original asset bytes restored |
| **Six Stage 7 probes PASS** (FAIL at `d13fdab`): the two patches applied unchanged to the `099531b` test files, run against the corrected `lib/` | V5 revalidation at `21e9cb1` | Application code unchanged since `d28f5a8`; the same cases are committed tests in the gate above. Six fresh probes (V5-P1..P6) also PASS; temporary, removed |
| Local real-sample metadata test PASS (DNG, JPEG, HEIC) | After S3.V4 (`2447962`) | Metadata code unchanged since; environment-dependent (the owner's sample folder) |
| Device checks M1–M4 PASS (owner's Xiaomi 14T Pro, `.s2check` build) | `79f392c`, `237c55f`, `2b045eb` | Device evidence; valid for the flows it covered until those flows change. S3V-08 and S2V-06's checks remain unverified |
| **Focused probe PASS after S6.V1** (was FAIL at the validation, application code `d7e1477`): `evidence/S6V_01_DELETE_UNDO_PROBE.patch` applied unchanged, run (`--plain-name "S6V probe"`), then removed; "4 blocks, last count 7, example badge false" | S6.V1's final inputs | The same inputs as the gate above. Its sequence is also a committed test now (`capture_blocks_undo_test.dart`) |

## Stage status

Vocabulary: Not started · Planning · In progress · In validation · Complete.

| Stage | Name | Status | Opened | Closed | Stage validation |
| --- | --- | --- | --- | --- | --- |
| 0 | Refinement Baseline | Complete | 2026-09-25 | 2026-09-25 | Self-review against the Stage 0 prompt's §22 checklist (`PROGRESS_HISTORY.md`, "Validation status"). The prompt asks for no separate validation session |
| 1 | Verified Fixes & Clean Baseline | Complete (owner waiver) | 2026-09-25 | 2026-09-26 | **Did not pass**: independent validation failed at `4e653fb` (TD-059–TD-062, fixed), then at `c99bd7f` (TD-063, X2). The owner closed the Stage anyway: TD-063 goes to Stage 8; X2 and W1 are carried |
| 2 | Metadata Foundation | Complete (owner waiver) | 2026-09-26 | 2026-09-26 | **Did not pass independently**: it failed at `79f392c` (fixed, `ffaff57`) and at `5d8bdbb` (S2R-01/TD-067; fixed by S2.V4/S2.V5, `d8e792c`/`435b3ce`). The owner then waived a third validation (E.1, "Stage 2 closed by the owner") |
| 3 | Metadata → Equipment / Device Import | Complete | 2026-09-26 | 2026-09-27 | **Fresh-session final sign-off PASS** at `92ebf2a` (`STAGE_3_FINAL_SIGNOFF.md`; S3F-01, S3F-02 non-blocking). Before that: FAIL at `387e54b`; a same-chat technical PASS at `d5e2b60` (`STAGE_3_REVALIDATION.md`); a fresh-session FAIL at `74026ca` (`STAGE_3_SIGNOFF_VALIDATION.md`, fixed by S3.V7/S3.V8). Device recheck S3V-08 unverified |
| 4 | Product Flow & Information Architecture | Complete | 2026-09-27 | 2026-09-27 | **Final, bounded validation PASS** at `09a7f06` (`STAGE_4_FINAL_VALIDATION.md`; the owner's seven questions; run in the authoring session at the owner's request, disclosed). Before that: **FAIL** at `adb5d95` (`STAGE_4_VALIDATION.md`, S4V-01), corrected by S4.V1. The fresh-session revalidation **FAILED** at `5ad69c4` (`STAGE_4_REVALIDATION.md`): S4R-01 and S4R-02 blocking, S4R-03 and S4R-04 low, all addressed by S4.V2 (the owner's R2 + D1). S4.V3 bounded the final validation, which then passed. S4V-02 is non-blocking and S4V-03 unverified |
| 5 | Design System Foundation | Complete | 2026-09-27 | 2026-09-27 | **FAIL** at `8a6c5d8` on one narrow blocker, S5V-01; S5.V1 (`178acbe`); **revalidation PASS** at `178acbe` ([report](STAGE_5_VALIDATION.md); same chat at the owner's request, disclosed) |
| 6 | Core Planner Redesign | Complete | 2026-09-27 | 2026-09-28 | **BLOCKED** at `6b50369` on one blocker, S6V-01 / TD-082; S6.V1 (`da4c53d`); **V5 revalidation PASS** at `da4c53d` ([report](STAGE_6_VALIDATION.md); same chat at the owner's request, disclosed). S6.E UNVERIFIED, a gap the owner accepted |
| 7 | Data Entry & Automation | Complete | 2026-09-28 | 2026-09-29 | **BLOCKED** at `d13fdab` (fresh-session independent validation): S7V-01 / TD-083 and S7V-02 / TD-084; S7.V1 (`46e7688`) and S7.V2 (`d28f5a8`); **V5 revalidation PASS** at `21e9cb1` ([report](STAGE_7_VALIDATION.md); same chat at the owner's request, disclosed) |
| 8 | Sessions / Execution / Actuals / Logbook | In progress | 2026-09-29 | — | — |
| 9 | Secondary UX & Product Polish | Not started | — | — | — |
| 10 | Performance & Application Size | Not started | — | — | — |
| 11 | Full Validation & Beta Readiness | Not started | — | — | — |

## Open research gates

All defined in `POST_ROADMAP_PLAN.md` §7.

| ID | Topic | Stage | Status |
| --- | --- | --- | --- |
| RG-01 | Metadata formats, libraries, file selection and samples (resolves PD-21) | 2 | **Decided** 2026-09-26 (ADR-017), **amended** the same day (the owner's priorities, ADR-017 §13). JPEG and HEIC samples exist (S2.8, S2.9); FITS, PNG and proprietary RAW still need samples, and are out of Stage 2 |
| RG-02 | Metadata → equipment identity, derivability, matching, provenance and conflicts | 3 | **Decided** 2026-09-26 (S3.D; ADR-018), after S3.R1 (`research/RG-02_EQUIPMENT_IDENTITY.md`) |
| RG-03 | Sourcing equipment specifications (catalog or none; licence; the verified-seed policy) | 3 (7) | **Deferred by the owner** 2026-09-26 (S3.D, D2): no source in Stage 3. **Researched** 2026-09-29 (S7.R5, `research/RG-03_EQUIPMENT_SPECS.md`); **decided 2026-09-29: Q1** (no source; lensfun crop factors the candidate with RG-12, Stage 9) |
| RG-04 | Execution's role and how actuals are captured | 4 | **Decided** 2026-09-27 (S4.R2; E.1): B, the Logbook first and the tracker optional; G2 post-session results. Its optional tracker is **superseded** 2026-09-27 (the tracker leaves the target product; P8.4) |
| RG-05 | Home/Tonight hierarchy, drill-downs and a possible Analytics destination | 4 | **Decided** 2026-09-27 (S4.R4; E.1): Tonight plan-first with a context line; detail screens; no new tab |
| RG-06 | Basic/Advanced modes against progressive disclosure | 4 | **Decided** 2026-09-27 (S4.R4; E.1): progressive disclosure; no modes |
| RG-07 | Target catalog expansion, names and search | 7 | **Decided** 2026-09-29 (S7.R3; DECISIONS E.1, "RG-07 decided"): T1 only |
| RG-08 | Site elevation: an automatic source, optional, or dropped | 7 | **Decided** 2026-09-29 (S7.R4; DECISIONS E.1): E2, optional and Unknown by default |
| RG-09 | Bortle/SQM sources, whether SQM stays a field, and the light-pollution map provider | 7 | **Decided** 2026-09-29 (S7.R4; DECISIONS E.1): S3 (manual, optional, collapsed), M2 (lightpollutionmap.app) |
| RG-10 | Calibration-frame workflows and inheritance | 7 | **Decided** 2026-09-29 (S7.R2; DECISIONS E.1, "RG-10 decided"): L1, D1, T0, O0, N1, H1; ADR-020 |
| RG-11 | Capture parameters (ISO or gain, binning, white balance, focus, interval) and their labels | 7 | **Decided** 2026-09-29 (S7.R1; DECISIONS E.1, "RG-11 decided"): C1, B1, W1, F1, I1, P2; ADR-020 |
| RG-12 | Licence requirements against GPL-3.0 | 9 | Open |
| RG-13 | Settings: real-world needs and where each setting belongs | 9 | Open |
| RG-14 | Proprietary RAW compatibility and libraries (no ad hoc parsers) | 2 (S2.R3) | **Decided** 2026-09-26 (DECISIONS E.1): none in Stage 2; per-format adapters later, with samples; `ExifInterface` and LibRaw rejected |

## Open owner decisions

All defined in `POST_ROADMAP_PLAN.md` §8.

| ID | Decision | Stage | Status |
| --- | --- | --- | --- |
| RD-01 | The GitHub account behind the app identity: `chacha12` or `Buffur` | Before any upload | Open (the author's own links do not wait for it, 2026-09-27) |
| RD-02 | The TASK 0.3 holdovers (ADK skill, `skills-lock.json`, `docs/archive/`, `sqlite3_flutter_libs`) | 1 / 10 | Open |
| RD-03 | Wording rulings: the SCI-05 ISO label; the SCI-04 time-resolution caveat | 1 | **Resolved** 2026-09-25: a neutral label (S1.8); SCI-04 documented only (S1.13). DECISIONS E.1 |
| RD-04 | New-draft defaults and the example plan | 4 | **Decided** 2026-09-27 (S4.R3; E.1): nothing preselected on the first run; New keeps the site and rig; an empty plan with "Start from the example plan" |
| RD-05 | Drafts and "New session" semantics (Stage 1 may decide an interim safeguard) | 4 (1) | **Decided** 2026-09-27 (S4.R3; E.1): L1 (Draft internal; Save explicit), Y2, U1. The S1.6 interim stands until Stage 6 builds U1. **Clarified** 2026-09-27 (S4.V2; E.1, "S4R-01 and S4R-02 decided"): saved snapshots are immutable per night; results without Save plan; Stage 8 delivers the saved-plan transition at once |
| RD-06 | The planner's section order; integrity text one tap away | 4 | **Decided** 2026-09-27 (S4.R4; E.1): answer first, decision order; detail one tap away |
| RD-07 | The Library's role and pickers; where Progress lives | 4 | **Decided** 2026-09-27 (S4.R5; E.1): the Library manages; choosing in context; Progress in the Logbook |
| RD-08 | Tracking per rig or per session; the seeded rig's tracking | 7 (before Stage 6's capture-plan work, P6.8 = S6.9) | **Decided** 2026-09-28 (owner): **T3**, the rig's default with a per-plan override; the seeded rig stays unknown (DECISIONS E.1, "RD-08 decided"). Built in Stage 7 by **S7.1** (ungated) |
| RD-09 | Destructive interactions: confirm or undo | 5 | **Decided** 2026-09-27 (owner): **M + S1**, undo for edits inside a plan, confirm for stored records; a visible Delete with swipe as a shortcut (DECISIONS E.1, "RD-09 decided"; `IA_WIREFRAMES.md` §3 amended for plan edits). Built by S5.8 |
| RD-10 | Ordering Tonight's candidates without a score | 6 (S6.14) | **Decided** 2026-09-28 (owner): **O1**, usable time, then frame fill, then the name (DECISIONS E.1). Built by S6.14 |
| RD-11 | Where the Moon and cloud gate controls live (TD-050) | 6 or 9 (S6.15 or P9.3) | **Decided** 2026-09-28 (owner): **S9**, Stage 9's Settings (P9.3, with RG-13); S6.15 not built (DECISIONS E.1) |
| RD-12 | The resume prompt's Finish | 8 | **Lapsed** 2026-09-27: the resume prompt goes with the tracker (E.1, "Stages 6–11 amended after Stage 5"); P8.4's audit covers a run still in progress at the upgrade |
| RD-13 | Provenance of an accepted estimate | 8 | **Decided** 2026-09-29 (Stage 8 planning, delegated by the owner; E.1, "Stage 8 decisions", D8-3): "Reported as planned"; old estimates not relabelled. Built by S8.1 |
| RD-14 | Vocabulary (rig or equipment; Sessions or Logbook; window names) | 4 | **Decided** 2026-09-27 (S4.R5; E.1): Rig, Plan, Logbook; the glossary |
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
  device check M4. *(M4 passed at `2b045eb`; the phone is now needed only for the optional S3V-08
  recheck and S2V-06's checks. Noted at the Stage 3 final sign-off.)*
  Samples for FITS, PNG, AVIF or RAW, when available, enable their readers later. The DNG,
  JPEG and HEIC samples stay outside Git.

## Known blockers

- **Stage 1 (closed by waiver):** X2 is done (S1.V6, 2026-09-26). TD-063 is in Stage 8. W1 was
  decided with RD-05's U1, and S6.3 builds it.
- **Stage 2 (closed by waiver):** nothing blocks. The carried items are listed under "Next
  allowed action".
- **Stage 3 (closed by the final sign-off PASS, 2026-09-27):** nothing blocks. Carried: S3V-08
  (device recheck, `.s2check` only), TD-072 with S3F-01, S3F-02, TD-070's Stage 8 remainder.
  Equipment identity for dedicated astro cameras still needs a FITS sample (S2.6).
- **Stage 4:**
  - **closed 2026-09-27** (the final, bounded validation passed). Carried to Stages 6 and 8:
    S4-DEF-01 to S4-DEF-08;
  - S4.E stays optional; Stage 6 carries the five-second test as S6.E;
  - S4V-02's script correction: **done 2026-09-28** as S6.E's first step.
- **Stage 5 (closed 2026-09-27):** nothing blocks.
  - Carried: TD-073 (two messages with an action persist: the site prompt's in S6.13, the Start
    message's in P8.4); UX-39's field-mode card borders (Stage 11 darkness test); `CLAUDE.md`'s
    stale test count.
  - Optional: the owner's review of the S5.9 images.
  - The adoption plan (`DESIGN_SYSTEM.md` §9) feeds Stages 6, 8 and 9.
- **Stage 6 (closed 2026-09-28):** nothing blocks. S6V-01 / TD-082 was resolved by S6.V1 and its
  V5 revalidation passed ([report](STAGE_6_VALIDATION.md)). Product gates decided: S4-DEF-04 (R),
  RD-08 (T3, the override built in Stage 7), RD-10 (O1), RD-11 (S9).
  - Carried: S6.E UNVERIFIED (the owner accepts the missing independent participant); the tracker
    until P8.4; TD-074 (allocated to Stage 9's planning at Stage 7 planning); TD-050 (Stage 9,
    P9.3); TD-081 (Stage 9 or 11); the validation's DEFERRED items (Stage 7's are now in its frozen
    sequence; Stage 8: saved-plan working copy and results, P8.1–P8.4, P8.7; Stage 9: richer detail
    screens).
- **Stage 7 (closed 2026-09-29):** nothing blocks. S7V-01 / TD-083 and S7V-02 / TD-084 were
  resolved by S7.V1/S7.V2 and the V5 revalidation passed ([report](STAGE_7_VALIDATION.md)).
  Carried: TD-074 (Stage 9 planning); RG-03 = Q1 with lensfun as the RG-12 candidate (Stage 9);
  the device and real-sample gaps listed under "Carried". All Stage 7 research
  and owner gates are decided; no new decision blocks these corrections. Other criteria retain PASS.
- **Device evidence:** M1 seekable providers and M2 non-backup/cancel paths were
  recorded at `79f392c`. Native streaming and real-backup preview cancellation
  remain unverified on-device. S2.V3 adds host JVM streaming tests; these do not
  upgrade device evidence. Stage 11 lifecycle rows remain open.
- **Release:** RD-01; the 16.2 upload key; the 16.3 policy. These do not block refinement.

## Next allowed action

1. **S8.1 — Results without a run: domain and data** (`POST_ROADMAP_PLAN.md`, "Stage 8 — frozen
   Task sequence", S8.1; DECISIONS E.1, "Stage 8 decisions"). Ungated. Then S8.2 … S8.9 in the frozen
   order and the Stage 8 validation: the owner asked, in chat on 2026-09-29, for the whole of Stage 8,
   so each Task follows the previous one's commit without a new prompt.

No Stage 8 gate is open.

**Carried:**
- S4-DEF-04 decided (R) and built by S6.3; S4-DEF-01 to S4-DEF-03 and S4-DEF-05 to S4-DEF-08 decided
  at Stage 8 planning (E.1, "Stage 8 decisions") and built by S8.1–S8.7;
- S4V-02: done (S6.E step 1, 2026-09-28);
- S3V-08: a device recheck of the corrected Stage 3 flow (unverified; separate);
- TD-072 (S3S-03, deferred by the owner) with its S3F-01 addendum; S3F-02 (a note on TD-071, no
  Task proposed);
- TD-070's remainder (per-field snapshot provenance; snapshots saved before S3.V7): Stage 8;
- W1 (decided with RD-05's U1): built by S6.3;
- TD-063 (Stage 8);
- TD-057 and TD-058: resolved (S6.4, S6.2);
- TD-074: allocated to Stage 9's planning (not data entry); the owner may pull it into Stage 7;
- RD-17 (the push is deferred);
- the S1.5 and S1.11 device checks (Stage 11);
- S2V-06's device checks (a non-seekable provider; a real backup's preview cancel): the next
  time the phone is connected, or Stage 11;
- the stale id-holding preferences after a reset, `editedSessionId` included (with
  TD-056/ENG-14).

## History

Earlier current-state entries, the completed-Task table, relevant commits, validation-status
entries, superseded next actions and the Stage 0 notes are in
[`PROGRESS_HISTORY.md`](PROGRESS_HISTORY.md), verbatim. Stage validation detail is in the
`STAGE_N_*.md` reports; Task detail in commits and the living registers.

## How to update this file

- **Replace, don't append.** "Current state" and "Next allowed action" describe now. When they
  change, replace the old text; it survives in Git. Do not keep superseded entries here.
- **At the end of every Task:** one line under "Current state" (Task, commit, finding IDs
  resolved, verification per the policy or the reused evidence); update the next Task; update any
  RG or RD it touched (resolved: date, and where the decision is written); update "Reusable
  validation evidence" if a check ran or its inputs changed.
- **At every Stage boundary:** update the Stage status table (dates, validation result in one
  line, with a link to the report); set the next allowed action; refresh "Known blockers" and
  "Carried"; drop the closed Stage's detail from "Current state".
- **Validation results** go in the Stage's `STAGE_N_*.md` report; this file gets one line and the
  link. Record evidence reuse in one line (what, where it ran, why it still holds).
- Keep it short enough to read at the start of every session.
