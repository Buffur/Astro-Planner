# AstroPlan — Refinement Progress

> The handoff contract for post-roadmap refinement: where work stands, what still binds it, what
> evidence can be reused, and the one next allowed action. Strategy lives in `POST_ROADMAP_PLAN.md`,
> direction in `PRODUCT_DIRECTION.md`, verification rules in `CLAUDE.md` ("Verification Policy"),
> and history in [`PROGRESS_HISTORY.md`](PROGRESS_HISTORY.md) and the `STAGE_N_*.md` reports.
> **Last updated:** 2026-09-27 (governance cleanup after the correction: M1/M2 commit fixed; CI filter
> made fail-safe; V1's shared-Task rule clarified).
> **Next:** S5.1 — foundation tokens, the gallery test and `docs/DESIGN_SYSTEM.md`. RD-09 is decided
> (M + S1).

## Current state

| Item | State |
| --- | --- |
| Phase | Post-roadmap refinement, Stages 0–11 (`POST_ROADMAP_PLAN.md`) |
| Current Stage | **Stage 5 — Design System Foundation: in progress** (planned at `38925dd`; S5.1–S5.9 frozen) |
| Current Task | None in progress |
| Next Task | S5.1 (frozen; the frozen sequence is the approval) |
| Code baseline | S3.V8 (`92ebf2a`). Every commit since changed only documentation (plus this correction's CI path filter). Not pushed (S1.14, RD-17) |
| Schema | v18 (S3.4) |

**Governance correction, 2026-09-27 (documentation, prompts and CI filter; the owner's request).**
- `CLAUDE.md` now holds the one canonical **Verification Policy** (V1–V8): verification by change
  class, broader-satisfies-narrower, evidence reuse, the frozen review surface and what may block,
  correction-scoped revalidation, PASS reopening, stop/convergence (two interpretation failures go
  to the owner), and what a fresh session reads.
- `.agents/rules/03-testing.md`, `CLAUDE.md` rules 13/16/17 and "Testing", and plan §9.1, §9.4 and
  §9.8 now refer to it instead of restating it. New prompts: `prompts/INDEPENDENT_STAGE_VALIDATION.md`
  and `prompts/CONTINUE_CURRENT_WORK.md` (neither existed before).
- CI skips the gate when only documentation changed (same paths as V1's documentation class).
- This file keeps only the handoff; the earlier entries are in `PROGRESS_HISTORY.md`, unchanged.
- No application code, test, tool, dependency, Stage scope or product decision changed.
- **Cleanup, 2026-09-27:** the M1/M2 device-check commit is `79f392c` (was misrecorded as
  `360fd8f`); the CI filter excludes only `docs/**.md` and `docs/**.patch` (not all of `docs/`), so
  any unknown file runs the gate; V1 now says a shared-behaviour Task ends with its affected
  regression checks and escalates to the full gate only when that set cannot be bounded or its
  Task/Stage gate requires it (high-risk Tasks still always end with the full gate). Verified by a
  YAML parse and a 22-case path simulation; the app gate was not rerun (no gate input changed).

**Stage 5 planning** (the entry as written at `a354032`):

**Stage 5 planning done, 2026-09-27 (documentation only).** Stage 5 is in progress.
- **Verified at `38925dd`** (§9.7), against the code:
  - the theme has no button, input or dialog theme, and no light or dark snackbar theme;
  - text roles are a convention, not tokens (08 §7);
  - fields use Material's default underline (08 §6);
  - UX-34's mechanism is as reported, and its primary action is already decided by ADR-019 §6;
  - `FitText.color` has no status tokens (UX-16);
  - the retired terms occur 16 times in 8 files of `lib/presentation`;
  - the delete paths are listed under RD-09;
  - New and Duplicate succeed silently (08 §5, §8).
- **The frozen sequence:**
  - S5.1: foundation tokens, the gallery test, `DESIGN_SYSTEM.md`;
  - S5.2: controls;
  - S5.3: the vocabulary (P5.1);
  - S5.4: status tokens, the status block and the state label (P5.4);
  - S5.5: the collapsible section (P5.2);
  - S5.6: the context line (P5.3);
  - S5.7: the detail-screen template (P5.5);
  - S5.8: confirmation, feedback and destructive patterns (P5.6), per RD-09 (M + S1);
  - S5.9: the adoption plan and rendered evidence.
- **The rule:** Stage 5 changes no screen's structure or wording. Theme tokens apply app-wide by
  design, and components are adopted in Stages 6–9.
- **RD-09 (owner): decided 2026-09-27, M + S1.** The options as prepared (plan §5, "RD-09 — confirm or undo"):
  - Q1: C, **M (recommended: undo for edits inside a plan, confirm for stored records)** or U;
  - Q2: **S1 (recommended: a visible Delete, swipe kept as a shortcut)** or S2.
- **No research gate.** The visual choices are this Stage's implementation decisions, with an
  optional owner review of S5.9's rendered sheets.
- **Baseline gate at `38925dd`: PASS** (Encoding; Format, 376 files, 0 changed; Analyze; 1,214
  tests, 1 expected skip; 2 host E2E).
- No application code or test changed.

## Reusable validation evidence

Per `CLAUDE.md`, Verification Policy V3: reuse while the inputs are unchanged.

| Evidence | Ran at | Still valid because |
| --- | --- | --- |
| **Full quality gate PASS**: Encoding; Format (376 files, 0 changed); Analyze; 1,214 tests, 1 expected skip (local real samples); 2 host E2E | `38925dd` (Stage 5 planning); the same result at `5ad69c4` and `92ebf2a` | `git diff --stat 92ebf2a HEAD -- . ':!docs' ':!CLAUDE.md'` shows only this correction's `.agents/rules/03-testing.md` (Markdown) and the `.github/workflows/ci.yml` path filter; neither is an input of the local gate. Invalidated by the first change to `lib/`, `test/`, `integration_test/`, `tool/`, `pubspec.*`, `assets/`, `analysis_options.yaml`, `build.yaml` or platform folders |
| Local real-sample metadata test PASS (DNG, JPEG, HEIC) | After S3.V4 (`2447962`) | Metadata code unchanged since; environment-dependent (the owner's sample folder) |
| Device checks M1–M4 PASS (owner's Xiaomi 14T Pro, `.s2check` build) | `79f392c`, `237c55f`, `2b045eb` | Device evidence; valid for the flows it covered until those flows change. S3V-08 and S2V-06's checks remain unverified |

## Stage status

Vocabulary: Not started · Planning · In progress · In validation · Complete.

| Stage | Name | Status | Opened | Closed | Stage validation |
| --- | --- | --- | --- | --- | --- |
| 0 | Refinement Baseline | Complete | 2026-09-25 | 2026-09-25 | Self-review against the Stage 0 prompt's §22 checklist (`PROGRESS_HISTORY.md`, "Validation status"). The prompt asks for no separate validation session |
| 1 | Verified Fixes & Clean Baseline | Complete (owner waiver) | 2026-09-25 | 2026-09-26 | **Did not pass**: independent validation failed at `4e653fb` (TD-059–TD-062, fixed), then at `c99bd7f` (TD-063, X2). The owner closed the Stage anyway: TD-063 goes to Stage 8; X2 and W1 are carried |
| 2 | Metadata Foundation | Complete (owner waiver) | 2026-09-26 | 2026-09-26 | **Did not pass independently**: it failed at `79f392c` (fixed, `ffaff57`) and at `5d8bdbb` (S2R-01/TD-067; fixed by S2.V4/S2.V5, `d8e792c`/`435b3ce`). The owner then waived a third validation (E.1, "Stage 2 closed by the owner") |
| 3 | Metadata → Equipment / Device Import | Complete | 2026-09-26 | 2026-09-27 | **Fresh-session final sign-off PASS** at `92ebf2a` (`STAGE_3_FINAL_SIGNOFF.md`; S3F-01, S3F-02 non-blocking). Before that: FAIL at `387e54b`; a same-chat technical PASS at `d5e2b60` (`STAGE_3_REVALIDATION.md`); a fresh-session FAIL at `74026ca` (`STAGE_3_SIGNOFF_VALIDATION.md`, fixed by S3.V7/S3.V8). Device recheck S3V-08 unverified |
| 4 | Product Flow & Information Architecture | Complete | 2026-09-27 | 2026-09-27 | **Final, bounded validation PASS** at `09a7f06` (`STAGE_4_FINAL_VALIDATION.md`; the owner's seven questions; run in the authoring session at the owner's request, disclosed). Before that: **FAIL** at `adb5d95` (`STAGE_4_VALIDATION.md`, S4V-01), corrected by S4.V1. The fresh-session revalidation **FAILED** at `5ad69c4` (`STAGE_4_REVALIDATION.md`): S4R-01 and S4R-02 blocking, S4R-03 and S4R-04 low, all addressed by S4.V2 (the owner's R2 + D1). S4.V3 bounded the final validation, which then passed. S4V-02 is non-blocking and S4V-03 unverified |
| 5 | Design System Foundation | In progress | 2026-09-27 | — | — (planned at `38925dd`: S5.1–S5.9 frozen; RD-09 decided M + S1) |
| 6 | Core Planner Redesign | Not started | — | — | — |
| 7 | Data Entry & Automation | Not started | — | — | — |
| 8 | Sessions / Execution / Actuals / Logbook | Not started | — | — | — |
| 9 | Secondary UX & Product Polish | Not started | — | — | — |
| 10 | Performance & Application Size | Not started | — | — | — |
| 11 | Full Validation & Beta Readiness | Not started | — | — | — |

## Open research gates

All defined in `POST_ROADMAP_PLAN.md` §7.

| ID | Topic | Stage | Status |
| --- | --- | --- | --- |
| RG-01 | Metadata formats, libraries, file selection and samples (resolves PD-21) | 2 | **Decided** 2026-09-26 (ADR-017), **amended** the same day (the owner's priorities, ADR-017 §13). JPEG and HEIC samples exist (S2.8, S2.9); FITS, PNG and proprietary RAW still need samples, and are out of Stage 2 |
| RG-02 | Metadata → equipment identity, derivability, matching, provenance and conflicts | 3 | **Decided** 2026-09-26 (S3.D; ADR-018), after S3.R1 (`research/RG-02_EQUIPMENT_IDENTITY.md`) |
| RG-03 | Sourcing equipment specifications (catalog or none; licence; the verified-seed policy) | 3 (7) | **Deferred by the owner** 2026-09-26 (S3.D, D2): no source in Stage 3; may return through Stage 7 |
| RG-04 | Execution's role and how actuals are captured | 4 | **Decided** 2026-09-27 (S4.R2; E.1): B, the Logbook first and the tracker optional; G2 post-session results |
| RG-05 | Home/Tonight hierarchy, drill-downs and a possible Analytics destination | 4 | **Decided** 2026-09-27 (S4.R4; E.1): Tonight plan-first with a context line; detail screens; no new tab |
| RG-06 | Basic/Advanced modes against progressive disclosure | 4 | **Decided** 2026-09-27 (S4.R4; E.1): progressive disclosure; no modes |
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
| RD-04 | New-draft defaults and the example plan | 4 | **Decided** 2026-09-27 (S4.R3; E.1): nothing preselected on the first run; New keeps the site and rig; an empty plan with "Start from the example plan" |
| RD-05 | Drafts and "New session" semantics (Stage 1 may decide an interim safeguard) | 4 (1) | **Decided** 2026-09-27 (S4.R3; E.1): L1 (Draft internal; Save explicit), Y2, U1. The S1.6 interim stands until Stage 6 builds U1. **Clarified** 2026-09-27 (S4.V2; E.1, "S4R-01 and S4R-02 decided"): saved snapshots are immutable per night; results without Save plan; Stage 8 delivers the saved-plan transition at once |
| RD-06 | The planner's section order; integrity text one tap away | 4 | **Decided** 2026-09-27 (S4.R4; E.1): answer first, decision order; detail one tap away |
| RD-07 | The Library's role and pickers; where Progress lives | 4 | **Decided** 2026-09-27 (S4.R5; E.1): the Library manages; choosing in context; Progress in the Logbook |
| RD-08 | Tracking per rig or per session; the seeded rig's tracking | 7 (before Stage 6's capture-plan work) | Open |
| RD-09 | Destructive interactions: confirm or undo | 5 | **Decided** 2026-09-27 (owner): **M + S1**, undo for edits inside a plan, confirm for stored records; a visible Delete with swipe as a shortcut (DECISIONS E.1, "RD-09 decided"; `IA_WIREFRAMES.md` §3 amended for plan edits). Built by S5.8 |
| RD-10 | Ordering Tonight's candidates without a score | 6 | Open |
| RD-11 | Where the Moon and cloud gate controls live (TD-050) | 6 or 9 | Open |
| RD-12 | The resume prompt's Finish | 8 | Open |
| RD-13 | Provenance of an accepted estimate | 8 | Open |
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

- **Stage 1 (closed by waiver):** X2 is done (S1.V6, 2026-09-26). TD-063 is in Stage 8. W1 is
  a proposed input to RD-05.
- **Stage 2 (closed by waiver):** nothing blocks. The carried items are listed under "Next
  allowed action".
- **Stage 3 (closed by the final sign-off PASS, 2026-09-27):** nothing blocks. Carried: S3V-08
  (device recheck, `.s2check` only), TD-072 with S3F-01, S3F-02, TD-070's Stage 8 remainder.
  Equipment identity for dedicated astro cameras still needs a FITS sample (S2.6).
- **Stage 4:**
  - **closed 2026-09-27** (the final, bounded validation passed). Carried to Stages 6 and 8:
    S4-DEF-01 to S4-DEF-08;
  - S4.E stays optional, and Stage 6 carries a five-second test;
  - S4V-02's script correction is separate and non-blocking, but it must precede Test A or C on the
    owner's install.
- **Stage 5 (in progress):** nothing blocks. RD-09 decided 2026-09-27 (M + S1).
- **Device evidence:** M1 seekable providers and M2 non-backup/cancel paths were
  recorded at `79f392c`. Native streaming and real-backup preview cancellation
  remain unverified on-device. S2.V3 adds host JVM streaming tests; these do not
  upgrade device evidence. Stage 11 lifecycle rows remain open.
- **Release:** RD-01; the 16.2 upload key; the 16.3 policy. These do not block refinement.

## Next allowed action

**S5.1 — Foundation tokens: type scale, text roles, surfaces and spacing; the gallery test;
`docs/DESIGN_SYSTEM.md`**, in a fresh chat where practical. It is frozen, and the frozen sequence is
the approval (§9.4: implement, test, document, commit, then STOP).
- **Definition:** `POST_ROADMAP_PLAN.md`, "Stage 5 — frozen Task sequence", S5.1, and the rules
  for every Stage 5 Task above it.
- **Read first:**
  - `lib/core/theme/` (`app_theme.dart`, `app_palette.dart`, `app_colors.dart`,
    `app_spacing.dart`);
  - `test/presentation/theme/`;
  - `test/presentation/accessibility_test.dart` (the guidelines to reuse);
  - ARCHITECTURE B16.
- **Then** S5.2 to S5.7 in order; S5.3 may run earlier.
- **RD-09 is decided** (M + S1; DECISIONS E.1), so S5.8 is no longer gated.

**Carried:**
- S4-DEF-01 to S4-DEF-08 (Stages 6 and 8);
- S4V-02 (correct the S4.E script before Test A or C runs on the owner's install);
- S3V-08: a device recheck of the corrected Stage 3 flow (unverified; separate);
- TD-072 (S3S-03, deferred by the owner) with its S3F-01 addendum; S3F-02 (a note on TD-071, no
  Task proposed);
- TD-070's remainder (per-field snapshot provenance; snapshots saved before S3.V7): Stage 8;
- W1 (proposed input to RD-05);
- TD-063 (Stage 8);
- TD-057 and TD-058;
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
