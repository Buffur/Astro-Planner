# AstroPlan — Refinement Progress

> The compact operational state of post-roadmap refinement. Update it at every Task and Stage
> boundary (see "How to update this file" at the end). Strategy lives in
> `POST_ROADMAP_PLAN.md`, direction in `PRODUCT_DIRECTION.md`.
> **Last updated:** 2026-09-25, independent Stage 1 validation of `4e653fb` did not pass:
> four reproduced findings (TD-059–TD-062). The earlier same-session review is preserved below.

## Current state

| Item | State |
| --- | --- |
| Current strategic phase | **Post-roadmap refinement** (Stages 0–11, `POST_ROADMAP_PLAN.md`). The Master Development Roadmap is closed as a task queue; its open items are carried (`POST_ROADMAP_PLAN.md` Appendix B) |
| Current Stage | **Stage 1 — Verified Fixes & Clean Baseline: In validation** (independent validation failed on S1.5/S1.6 paths; S1.14 deferred) |
| Next Stage | Stage 2 — Metadata Foundation: Not started |
| Current approved Task | None in progress |
| Next approved Task | **S1.V1 — Recognize refusal through the production database connection** (TD-059). The owner approved the remaining fixes (2026-09-25): S1.V1 → S1.V2 → S1.V3 → S1.V4, one commit each, then a repeat independent validation |
| Code baseline | `4e653fb` (S1.15); `723fd44` and this validation change documentation/evidence only; not pushed (S1.14) |
| Quality gate at the baseline | **Green** after S1.16/S1.17, 2026-09-25: Encoding, Format, Analyze pass; Test (949 passed); E2E on the host (2 passed). The validation's six probe assertions (retained patch) are still expected to fail until S1.V1–S1.V4 |
| Schema | v17 |

## Stage status

Vocabulary: Not started · Planning · In progress · In validation · Complete.

| Stage | Name | Status | Opened | Closed | Stage validation |
| --- | --- | --- | --- | --- | --- |
| 0 | Refinement Baseline | Complete | 2026-09-25 | 2026-09-25 | Self-review against the Stage 0 prompt's §22 checklist (below). The prompt asks for no separate validation session |
| 1 | Verified Fixes & Clean Baseline | In validation | 2026-09-25 | — | **Independent validation does not pass** at `4e653fb`: TD-059–TD-062. Earlier same-session review retained below |
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
| 1 | S1.16 — Commit hashes in the registers (V1) and S1.17 — the field theme in the dialog's accessibility check (V2); V3 recorded under RD-05 | 2026-09-25 | The S1.16 commit* | Owner: "apply fixes for the remaining items to complete Stage 1". 37 `S1.x` stamps in `ARCHITECTURE.md`, `DATA_MODEL.md`, `FEATURE_STATUS.md` and `SCIENTIFIC_INTEGRITY.md`, TD-047, TD-057 and TD-058 cite their commits; the "Discard unsaved changes?" dialog is checked in the light, dark and field themes (contrast not in field, as in the sweep); V3 added to RD-05 (`POST_ROADMAP_PLAN.md` §8). Gate green, 949 + 2 E2E |

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
- Independent Stage 1 validation: see the note under "Completed Tasks".

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
- Real metadata sample files for Stage 2 (RG-01).

## Known blockers

- **Stage 1:** TD-059–TD-062 survive independent validation. Proposed fix Tasks
  S1.V1–S1.V4 await review (`STAGE_1_VALIDATION.md`), alongside the earlier
  S1.16/S1.17 proposals and V3 decision. S1.14's push stays deferred (RD-17 open).
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

The owner approved the remaining Stage 1 fixes (2026-09-25: "apply fixes for the remaining
items to complete Stage 1"). S1.16, S1.17 and the V3 decision are done. Next, in order, one
commit each, as defined in `STAGE_1_VALIDATION.md`:
1. **S1.V1** — recognize refusal through the production connection (TD-059);
2. **S1.V2** — seed the replacement database after a confirmed reset (TD-060);
3. **S1.V3** — keep the unsaved-plan safeguard across a restart (TD-061), through the
   existing persistence abstractions; stop and report if it needs a schema or product
   decision;
4. **S1.V4** — reopening the current session keeps its live plan (TD-062).

Each Task's acceptance includes turning its probe from the retained patch
(`evidence/STAGE_1_VALIDATION_PROBES.patch`) into a passing regression test. After S1.V4,
repeat **independent** Stage 1 validation in a fresh session; only then close Stage 1 and
consider Stage 2 planning (RG-01 and the owner's metadata samples).

Carried open items that are not Stage 1 failures: TD-057, TD-058, RD-17 (push deferred), the
S1.5 and S1.11 device checks (Stage 11).

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
