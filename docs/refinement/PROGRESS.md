# AstroPlan — Refinement Progress

> The compact operational state of post-roadmap refinement. Update it at every Task and Stage
> boundary (see "How to update this file" at the end). Strategy lives in
> `POST_ROADMAP_PLAN.md`, direction in `PRODUCT_DIRECTION.md`.
> **Last updated:** 2026-09-25, after S1.3.

## Current state

| Item | State |
| --- | --- |
| Current strategic phase | **Post-roadmap refinement** (Stages 0–11, `POST_ROADMAP_PLAN.md`). The Master Development Roadmap is closed as a task queue; its open items are carried (`POST_ROADMAP_PLAN.md` Appendix B) |
| Current Stage | **Stage 1 — Verified Fixes & Clean Baseline: In progress** (planning done 2026-09-25; the Task sequence is frozen, S1.1–S1.15, in `POST_ROADMAP_PLAN.md` §5) |
| Next Stage | Stage 2 — Metadata Foundation: Not started |
| Current approved Task | None in progress |
| Next approved Task | **S1.4 — Night key without a site** (A4; ENG-05, SCI-11, RT-06). Approved by the frozen sequence |
| Code baseline | `main` after S1.3 (see "Completed Tasks") |
| Quality gate at the baseline | **Green**, S1.3, 2026-09-25: Encoding, Format, Analyze pass; Test (908 passed); E2E on the host (2 passed) |
| Schema | v17 |

## Stage status

Vocabulary: Not started · Planning · In progress · In validation · Complete.

| Stage | Name | Status | Opened | Closed | Stage validation |
| --- | --- | --- | --- | --- | --- |
| 0 | Refinement Baseline | Complete | 2026-09-25 | 2026-09-25 | Self-review against the Stage 0 prompt's §22 checklist (below). The prompt asks for no separate validation session |
| 1 | Verified Fixes & Clean Baseline | In progress (sequence frozen) | 2026-09-25 | — | — |
| 2 | Metadata Foundation | Not started | — | — | — |
| 3 | Metadata → Equipment / Device Import | Not started | — | — | — |
| 4 | Product Flow & Information Architecture | Not started | — | — | — |
| 5 | Design System Foundation | Not started | — | — | — |
| 6 | Core Planner Redesign | Not started | — | — | — |
| 7 | Data Entry & Automation | Not started | — | — | — |
| 8 | Sessions / Execution / Actuals / Logbook | Not started | — | — | — |
| 9 | Secondary UX & Product Polish | Not started | — | — | — |
| 10 | Performance & Application Size | Not started | — | — | — |
| 11 | Full Validation & Beta Readiness | Not started | — | — | — |

## Completed Tasks

| Stage | Task | Date | Commit | Result |
| --- | --- | --- | --- | --- |
| 0 | Stage 0 — Refinement Baseline (documentation only) | 2026-09-25 | `652ad80` | Created `PRODUCT_DIRECTION.md`, `POST_ROADMAP_PLAN.md` and `PROGRESS.md`; archived the Stage 0 prompt in `docs/refinement/prompts/`; committed the audit reports 01–08 and the owner's post-roadmap `CLAUDE.md` governance with them |
| 1 | Stage 1 planning (documentation only): every A–F candidate re-verified at `652ad80` (none stale); RD-03 resolved; RD-05 interim decided; RD-17 included; the Task sequence S1.1–S1.15 frozen | 2026-09-25 | `1ec6e7a` | `POST_ROADMAP_PLAN.md` §5 and §8; DECISIONS E.1 "Stage 1 planning decisions" |
| 1 | S1.1 — Open-Meteo user agent (A3) | 2026-09-25 | `6a90347` | Open-Meteo requests carry `AppIdentity.userAgent`; a `MockClient` test (fails without the fix). Resolves ENG-03 = RT-07. Gate green, 897 + 2 E2E. Found: `ARCHITECTURE.md:494` and F-29's body are stale, added to S1.15 |
| 1 | S1.2 — Seeding and preference failure paths (A2, E1, E3) | 2026-09-25 | `c449c03` | `CatalogSeeder` skips ids a catalog row already holds and leaves the version unrecorded when any other insert fails, so the next launch retries (3 tests, failing before the fix); `EquipmentSeeder` re-checked, already retries; the privacy preferences failure-path test. Resolves ENG-02 = RT-02, 01 §G.7. Gate green, 901 + 2 E2E |
| 1 | S1.3 — Forecast freshness over time, resume and rollover (A1, E2) | 2026-09-25 | The S1.3 commit* | `NightWeatherAvailable.at` and `NightWeather.isOutdated` (domain); `NightConditionsViewModel.checkClock()`/`resumed()`; a `NightClock` widget at the app root (one-minute tick, `AppLifecycleListener`); a snapshot re-ages first; summary/opportunity caches keyed on the snapshot. 7 tests, the 04/P1 steps (the snapshot test fails without the fix). Resolves ENG-01 = SCI-01 = RT-01. Found and recorded: TD-057 (the draft's night key and an open candidates list do not follow a rollover). Gate green, 908 + 2 E2E |

\* A file cannot contain its own commit hash. Find it with
`git log --format="%h %s" -1 -- docs/refinement/PROGRESS.md`; the next Task records it here.

## Relevant commits

- `becae04`: the last roadmap commit (TASK 16.3 documentation, 2026-09-24). Audits 01–07 were
  captured against it.
- `652ad80`: Stage 0, the refinement baseline.
- `1ec6e7a`: Stage 1 planning (the frozen sequence).
- `6a90347`: S1.1.
- `c449c03`: S1.2.
- S1.3: see the note under "Completed Tasks".

## Open research gates

All defined in `POST_ROADMAP_PLAN.md` §7.

| ID | Topic | Stage | Status |
| --- | --- | --- | --- |
| RG-01 | Metadata formats, libraries, file selection and samples (resolves PD-21) | 2 | Open |
| RG-02 | Metadata → equipment identity, derivability, matching, provenance and conflicts | 3 | Open |
| RG-03 | Sourcing equipment specifications (catalog or none; licence; the verified-seed policy) | 3 | Open |
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
| RD-16 | When the metadata feature becomes visible (PD-06 gate) | 2 | Open |
| RD-17 | Push the CI workflow to the remote and observe a first run | 1 (optional) / 11 | Open; **included in Stage 1** as S1.14 (the push is confirmed with the owner when it runs) |

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
- Real metadata sample files for Stage 2 (RG-01).

## Known blockers

- **Stage 1:** none for S1.1–S1.13 and S1.15. S1.14 needs the owner's go-ahead at the moment of the push.
- **Stage 2:** owner-supplied real metadata samples, and RG-01.
- **Device evidence:** no Android device or emulator run is recorded (`TEST_PLAN.md` device
  rows), so TASKs 15.4 and 15.5 stay open. The owner's dogfooding (08) shows manual use of
  some build, but no build, device or commit is recorded (`POST_ROADMAP_PLAN.md` §1.3 item 2).
- **Release:** RD-01; the 16.2 upload key; the 16.3 policy. These do not block refinement.

## Validation status

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
- **Stage 1 Tasks:** S1.1–S1.3 done (gate green). **Stages 2–11:** not started.

## Next allowed action

Run **S1.4 — Night key without a site** (`POST_ROADMAP_PLAN.md` §5, Stage 1 frozen
sequence), preferably in a fresh session. The frozen sequence is the approval: no separate prompt
file is needed (CLAUDE.md governance; an owner-supplied prompt may still narrow or override
a Task). That session:
- reads `CLAUDE.md`, this file and the S1.4 entry, plus the files it names;
- follows READ → VERIFY → PLAN → IMPLEMENT → TESTS → GATE → SELF-REVIEW → DOCS → COMMIT →
  STOP;
- records the S1.3 commit hash and its own commit here, then stops. It does not start S1.5.

Then S1.5 … S1.15 in order, one Task per session. After S1.15, run Stage 1 validation in a
fresh session (§9.8).

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
