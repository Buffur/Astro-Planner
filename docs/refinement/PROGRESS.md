# AstroPlan — Refinement Progress

> The handoff contract for post-roadmap refinement: where work stands, what still binds it, what
> evidence can be reused, and the one next allowed action. Strategy lives in `POST_ROADMAP_PLAN.md`,
> direction in `PRODUCT_DIRECTION.md`, verification rules in `CLAUDE.md` ("Verification Policy"),
> and history in [`PROGRESS_HISTORY.md`](PROGRESS_HISTORY.md) and the `STAGE_N_*.md` reports.
> **Last updated:** 2026-09-28 (**S6.14 done**: the candidates' default order; Stage 6's code Tasks
> are all done).
> **Next:** S6.E, the five-second test (owner-run; its first step is documentation an agent can do
> when asked), then Stage 6 validation in a fresh session.

## Current state

| Item | State |
| --- | --- |
| Phase | Post-roadmap refinement, Stages 0–11 (`POST_ROADMAP_PLAN.md`) |
| Current Stage | **Stage 6 — Core Planner Redesign: in progress** (Task sequence frozen 2026-09-27; S6.1–S6.14 done; S6.15 not built, RD-11 = S9) |
| Current Task | None in progress |
| Next Task | **S6.E — The five-second test** (owner-run) |
| Code baseline | S6.14 (this commit). Not pushed (S1.14, RD-17) |
| Schema | v18 (S3.4) |

**S6.14 done, 2026-09-28** (RD-10 = O1; UX-29): "What can I image tonight?" orders by usable time,
then frame fill (unknown last), then the name; the header names the order. Verification: the
Task's class, localized (targeted and candidates-screen tests, analyze, format, encoding), PASS;
every acceptance criterion checked.

**RD-10 and RD-11 decided, 2026-09-28 (the owner, in chat):** O1 (candidates by usable time, then
frame fill, then the name; the header names the order) and S9 (the Moon and cloud gate controls in
Stage 9's Settings, with RG-13; TD-050 stays open; S6.15 is not built). DECISIONS E.1, "RD-10 and
RD-11 decided".

**S6.13 done, 2026-09-28** (P6.6; UX-10, UX-11, UX-13, UX-17, UX-24; TD-054 resolved; TD-073's site
prompt decided; DEV-P9 resolved): Tonight leads with site ▾ · night ▾ (the night picker changes the
plan's night), the run card, Your plan with the planner's verdict, then the Night, Moon and Weather
rows and the secondary actions; no Start; the Dark row at the user's limit; the Moon row says what
the Moon does while it is dark (CALC-43). No compact timeline (recorded why). Verification: the full
gate after the last code change, PASS (below); every acceptance criterion checked.

**S6.12 done, 2026-09-28** (P6.11; UX-08): the altitude chart is evolved into the night and
opportunity timeline over one mapping: seamless bands with drawn edges (field mode), the windows,
the fit's end, whole-hour times in the device's 12/24-hour format, labels outside the plot at any
text size, a fuller text alternative, and a compact density for Tonight to consider. The inventory
is in ARCHITECTURE B4. Verification: the full gate after the last code change, PASS (below); every
acceptance criterion checked.

**S6.11 done, 2026-09-28** (P6.10; CALC-42): each light group has a compact graph of its relative
stacking gain from one frame to twice the planned count, the planned count marked; the figure and
the label stay (SI-003); a text alternative gives each group's value; the points come from the
domain. Verification: the full gate after the last code change, PASS (below); every acceptance
criterion checked.

**S6.10 done, 2026-09-28** (P6.9; 08 §17): Budget details' summary says "Time needed · Total time";
each row says what of it fits tonight, only from the fit's own outputs (TD-074 records what the fit
cannot answer); storage says what it rests on, or why it is unknown and how to supply it (the trace
re-verified: an unknown input, no defect); the status and the budget summary are briefly
highlighted when an edit changes them. No budget visual. Verification: the full gate after the last
code change, PASS (below); every acceptance criterion checked.

**S6.9 done, 2026-09-28** (P6.8; UX-09, UX-15 (1); 08 §14; RD-09; RD-08 = T3): each capture block's
row says what will be captured ("Ha · 60 s × 100 · 1 h 40 min"); one heading; Delete with Undo
that restores the identical block; a known tracking's exceedance keeps its warning and names the
tracking, while unknown tracking is a neutral missing input with a way to set it; Save is the
dialog's primary button; a changed row is briefly highlighted. The tracking used is the rig's
default until Stage 7 adds the plan's override. Verification: the full gate after the last code
change, PASS (below); every acceptance criterion checked.

**RD-08 decided, 2026-09-28 (the owner, in chat): T3.** Tracking is the rig's default with a
per-plan override; the plan changes the effective value without changing the rig; the snapshot keeps
the effective value; Unknown stays possible; the example rig's Unknown is never made a fact
(DECISIONS E.1, "RD-08 decided"; pointer under ADR-011 §5). Checked against the model first: the
rig's default and the snapshot's `tracking` exist; only the plan's override needs a new nullable
field, which Stage 7 builds with the planner's control. It unblocks S6.9, which shows the effective
tracking and moves nothing.

**S6.8 done, 2026-09-28** (P6.2, P6.1's New plan; RD-04; UX-24): nothing the user did not choose
looks chosen. A fresh install has no target, no rig and an empty capture plan with "Start from the
example plan"; New plan keeps the site and rig and asks for a target; a stored choice is still
restored; the shipped rig is labelled as an example where it is listed and chosen; the welcome page
marks nothing as done that the user did not do. Tests that relied on the old defaults choose their
plan explicitly (`PlannerHarness.choosePlan()`); the E2E chooses through the new path. **For the
owner:** "Example rig" is new wording beside RD-04's "Start from the example plan"; both are kept
out of `AppWords` (`DESIGN_SYSTEM.md` §7). Verification: the full gate after the last code change,
PASS (below); every acceptance criterion checked.

**S6.7 done, 2026-09-28** (P6.4; UX-05; ADR-019 §7): technical depth is one tap away behind
factual summaries, each section's state remembered: Budget details, the √N explanation,
Assumptions, the rig's Specifications and Sky darkness. The status, storage, the √N values, the
weather row, the capability warnings and every unknown stay visible; the status now shows the
integration in every state; the Conditions section names its zone once. The widened sweep (every
section open) found the Bortle badge failing tap-target and contrast checks, fixed here (a colour
swatch beside readable text, 48 dp). Verification: the full gate after the last code change, PASS
(below); every acceptance criterion checked.

**S6.6 done, 2026-09-28** (P6.3; UX-01 to UX-03, UX-07, UX-15 (3)): the planner answers first:
the status (verdict with time needed and usable time, reason, capture end, integration, fill or
trim), the context line (site ▾ · night ▾), then the target, the capture plan, the conditions and
the rig. No empty state: a missing site, target or rig is a neutral status with a way to choose.
**For the owner:** "Needs a site" and "Needs a rig" follow the glossary's "Needs a …" pattern but
are kept out of `AppWords` until you confirm them (`DESIGN_SYSTEM.md` §7). Verification: the full
gate after the last code change, PASS (below); every acceptance criterion checked.

**S6.5 done, 2026-09-28** (P6.5; UX-06, UX-10; TD-051 resolved; CALC-41): two detail screens above
the tabs, Night & Moon (`/night`: the dark span at the user's limit, the twilight names, the Moon,
the zone once) and Weather (`/weather`: the whole forecast, nothing lost), both on `DetailScaffold`
and in the sweep. The planner shows one factual row for each and keeps sky darkness; Tonight's
rows open the details. `tonightCandidates()` moved into `CandidatesViewModel` to keep
`NightConditionsViewModel` under the cap. Verification: the full gate after the last code change,
PASS (below); every acceptance criterion checked.

**S6.3 done, 2026-09-28** (P6.1's second half; U1, W1, V3, UX-12; S4-DEF-04 = R): leaving a plan
with unsaved changes asks Save · Discard · Cancel at New plan, Copy, Tonight's New and Open. Discard
deletes a never-saved plan and reverts a Saved · changed one to its snapshot (unchanged; nothing
deleted; refused with a message when the snapshot cannot be restored). An untouched never-saved draft
is deleted when replaced; a copy counts as unsaved; a site change on a saved plan is an edit. The
S1.6 guard is gone. Tests: 48 new or mapped (reader, repository, `CurrentSession`, the UI matrix);
four S6.2 tests changed deliberately (see the plan). Verification: the full gate after the last
code change, PASS (below); every acceptance criterion checked.

**S4-DEF-04 decided, 2026-09-28 (the owner, in chat): R.** Discard on a Saved · changed plan reverts it
to its saved snapshot; the snapshot is unchanged and nothing is deleted (DECISIONS E.1). It unblocks
S6.3.

**S6.4 done, 2026-09-28** (P6.7; TD-057 resolved): at the rollover (`NightClock` →
`PlanLifecycleViewModel.followNight`, every minute and on resume, before the forecast check) and at a
restart, a never-saved draft's night key is written through the autosave chain, not as an edit. A
picked night still ahead is kept; one no longer ahead rolls forward when tonight moves on, and a
past night picked meanwhile is not moved before then. A saved plan's row is never written (D1). The
planner notifies at a new night for any plan (S6.2's identity strip follows it), and the candidates
list re-evaluates. `night_rollover_test.dart` (8 tests). One existing test's steps are reordered
because it relied on the unwritten key (see the plan). Verification: the full gate after the last
code change, PASS (below); every acceptance criterion checked.

**S6.2 done, 2026-09-27** (P6.1's first half; TD-058 resolved; DEV-P9's first half): the planner is
titled "Plan", with a strip under its app bar showing the target, the night and the plan's state
(it wraps at 200 % text). ⋮ holds New plan, Copy to another night (`pickNight`) and, for a saved
plan, Track live (optional), which replaces the bottom bar's Start (interim until P8.4). Save plan
is the one primary button. Save, New plan, Copy and Open each say what happened (`showDone`).
`CurrentSession.startNew`/`adopt` run in the autosave chain; the new tests
(`current_session_chain_test.dart`, `plan_identity_actions_test.dart`) fail without the fix. Tests
and the E2E follow the renamed labels; two race tests make their edit through the ViewModel
because the closing menu covers the row (assertions unchanged). Tonight's Start and the S1.6 guard
stay until S6.13 and S6.3. Verification: the full gate after the last code change, PASS (below);
every acceptance criterion checked.

**S6.1 done, 2026-09-27** (P6.0; ENG-16 resolved): `SessionPlanViewModel` is split, with no behaviour
change. It keeps the plan's contents, edits, autosave and read-only state (220 lines). The new
`PlanLifecycleViewModel` restores, opens, starts new plans, copies, saves and starts runs (167
lines; a plain `Provider`, not a notifier). `AppViewModels` builds one `CurrentSession` for both.
Callers moved mechanically: `StartupViewModel`, `CaptureAnalysisViewModel` (Save and Start), four
screens and `PlannerHarness`. No test assertion changed. `CLAUDE.md` trap 11 and ARCHITECTURE B1/B4
updated. Verification: the full gate after the last code change, PASS (below); every acceptance
criterion checked.

**Stage 6 planned, 2026-09-27** (documentation only; the plan's "Stage 6 — frozen Task sequence"):
- **On the amended plan:** the owner started Stage 6 planning on the Stages 6–11 amendment
  (`783a723`), which closes the "owner reviews the amendment" step.
- **Verified against the code (§9.7):** the inputs of P6.0–P6.11, with their finding IDs. Notable:
  - `SessionPlanViewModel` is at 300 physical lines, exactly at the cap (ENG-16's "299" is stale);
  - the storage trace (P6.9) finds case (C), an unknown input: the seeded rig has no RAW size, and
    "Unknown" gives no reason. No calculation or wiring defect;
  - UX-08's 24-hour labels and labels over the curves, TD-051, TD-054, TD-057 and TD-058 are
    confirmed as recorded;
  - the core-loop E2E's first plan depends on the M42 default (S6.8 updates it).
- **Frozen:** S6.1–S6.14; S6.15 only if RD-11 chooses Stage 6; S6.E, the owner-run five-second
  test, with S4V-02's correction as its first step. P6.1 is split into S6.2 (the app bar, ⋮,
  feedback, TD-058) and S6.3 (Save · Discard · Cancel). No P-Task was dropped; the mapping is in the
  plan and in `DESIGN_SYSTEM.md` §9.
- **Gates, with options prepared (nothing decided):**
  - S4-DEF-04, Discard on Saved · changed: **R** revert to the saved plan (recommended) / K keep the
    changes with the entry. Blocks S6.3;
  - RD-08, tracking: T1 per rig / T2 per plan / **T3** the rig's default with a per-plan override
    (recommended). Blocks S6.9;
  - RD-10, the candidates' order: **O1** usable time, then frame fill (recommended) / O2 then the
    maximum altitude / O3 groups. Blocks S6.14;
  - RD-11, the gate controls: **S9** Settings in Stage 9 (recommended) / S6 now, as S6.15 / P the
    planner.
- **Allocated, not decided:** S4-DEF-01 (Save on Saved · changed) goes to Stage 8's planning, and
  Stage 6 keeps today's Save. The owner may move it back.
- **Verification:** the documentation class (V1): references and IDs resolve; `git diff --check`.
  No gate input changed, so Stage 5's closing gate is reused as Stage 6's baseline (below).
- The earlier entries (Stage 5, the governance correction, the Stages 6–11 amendment) moved verbatim
  to `PROGRESS_HISTORY.md`.

**Before this:** Stage 5 closed on 2026-09-27 at `178acbe` ([report](STAGE_5_VALIDATION.md)); its
adoption plan is `DESIGN_SYSTEM.md` §9. The Stages 6–11 amendment is DECISIONS E.1, "Stages 6–11
amended after Stage 5" (`783a723`). The Verification Policy is `CLAUDE.md`'s (V1–V8).

## Reusable validation evidence

Per `CLAUDE.md`, Verification Policy V3: reuse while the inputs are unchanged.

| Evidence | Ran at | Still valid because |
| --- | --- | --- |
| **Full quality gate PASS**: Encoding; Format (436 files, 0 changed); Analyze; 1,466 tests, 2 expected skips (the local real samples; the opt-in S5.9 render test); 2 host E2E | S6.13's final inputs (`6651cf7`) | Still valid except where S6.14 changed inputs (`candidate_evaluator.dart`, the candidates screen and their two tests); S6.14's localized checks PASS on its final inputs. Stage 6 validation decides whether it needs a fresh full gate (V3 (c)) |
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
| 5 | Design System Foundation | Complete | 2026-09-27 | 2026-09-27 | **FAIL** at `8a6c5d8` on one narrow blocker, S5V-01; S5.V1 (`178acbe`); **revalidation PASS** at `178acbe` ([report](STAGE_5_VALIDATION.md); same chat at the owner's request, disclosed) |
| 6 | Core Planner Redesign | In progress | 2026-09-27 | — | — (planned 2026-09-27: S6.1–S6.15 and S6.E frozen in the plan, "Stage 6 — frozen Task sequence"; four gates open) |
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
| RG-04 | Execution's role and how actuals are captured | 4 | **Decided** 2026-09-27 (S4.R2; E.1): B, the Logbook first and the tracker optional; G2 post-session results. Its optional tracker is **superseded** 2026-09-27 (the tracker leaves the target product; P8.4) |
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
| RD-01 | The GitHub account behind the app identity: `chacha12` or `Buffur` | Before any upload | Open (the author's own links do not wait for it, 2026-09-27) |
| RD-02 | The TASK 0.3 holdovers (ADK skill, `skills-lock.json`, `docs/archive/`, `sqlite3_flutter_libs`) | 1 / 10 | Open |
| RD-03 | Wording rulings: the SCI-05 ISO label; the SCI-04 time-resolution caveat | 1 | **Resolved** 2026-09-25: a neutral label (S1.8); SCI-04 documented only (S1.13). DECISIONS E.1 |
| RD-04 | New-draft defaults and the example plan | 4 | **Decided** 2026-09-27 (S4.R3; E.1): nothing preselected on the first run; New keeps the site and rig; an empty plan with "Start from the example plan" |
| RD-05 | Drafts and "New session" semantics (Stage 1 may decide an interim safeguard) | 4 (1) | **Decided** 2026-09-27 (S4.R3; E.1): L1 (Draft internal; Save explicit), Y2, U1. The S1.6 interim stands until Stage 6 builds U1. **Clarified** 2026-09-27 (S4.V2; E.1, "S4R-01 and S4R-02 decided"): saved snapshots are immutable per night; results without Save plan; Stage 8 delivers the saved-plan transition at once |
| RD-06 | The planner's section order; integrity text one tap away | 4 | **Decided** 2026-09-27 (S4.R4; E.1): answer first, decision order; detail one tap away |
| RD-07 | The Library's role and pickers; where Progress lives | 4 | **Decided** 2026-09-27 (S4.R5; E.1): the Library manages; choosing in context; Progress in the Logbook |
| RD-08 | Tracking per rig or per session; the seeded rig's tracking | 7 (before Stage 6's capture-plan work, P6.8 = S6.9) | **Decided** 2026-09-28 (owner): **T3**, the rig's default with a per-plan override; the seeded rig stays unknown (DECISIONS E.1, "RD-08 decided"). Built in Stage 7 |
| RD-09 | Destructive interactions: confirm or undo | 5 | **Decided** 2026-09-27 (owner): **M + S1**, undo for edits inside a plan, confirm for stored records; a visible Delete with swipe as a shortcut (DECISIONS E.1, "RD-09 decided"; `IA_WIREFRAMES.md` §3 amended for plan edits). Built by S5.8 |
| RD-10 | Ordering Tonight's candidates without a score | 6 (S6.14) | **Decided** 2026-09-28 (owner): **O1**, usable time, then frame fill, then the name (DECISIONS E.1). Built by S6.14 |
| RD-11 | Where the Moon and cloud gate controls live (TD-050) | 6 or 9 (S6.15 or P9.3) | **Decided** 2026-09-28 (owner): **S9**, Stage 9's Settings (P9.3, with RG-13); S6.15 not built (DECISIONS E.1) |
| RD-12 | The resume prompt's Finish | 8 | **Lapsed** 2026-09-27: the resume prompt goes with the tracker (E.1, "Stages 6–11 amended after Stage 5"); P8.4's audit covers a run still in progress at the upgrade |
| RD-13 | Provenance of an accepted estimate | 8 | Open; **narrowed** 2026-09-27 to existing accepted-estimate events and "reported as planned" (P8.1) |
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
  - S4V-02's script correction is non-blocking and must precede Test A or C on the owner's install;
    it is S6.E's first step.
- **Stage 5 (closed 2026-09-27):** nothing blocks.
  - Carried: TD-073 (two messages with an action persist: the site prompt's in S6.13, the Start
    message's in P8.4); UX-39's field-mode card borders (Stage 11 darkness test); `CLAUDE.md`'s
    stale test count.
  - Optional: the owner's review of the S5.9 images.
  - The adoption plan (`DESIGN_SYSTEM.md` §9) feeds Stages 6, 8 and 9.
- **Stage 6 (planned 2026-09-27):** every gate is decided: S4-DEF-04 (R), RD-08 (T3), RD-10 (O1) and
  RD-11 (S9, so no S6.15), all 2026-09-28. S6.E needs the owner to
  run it. The tracker stays as built until P8.4.
- **Device evidence:** M1 seekable providers and M2 non-backup/cancel paths were
  recorded at `79f392c`. Native streaming and real-backup preview cancellation
  remain unverified on-device. S2.V3 adds host JVM streaming tests; these do not
  upgrade device evidence. Stage 11 lifecycle rows remain open.
- **Release:** RD-01; the 16.2 upload key; the 16.3 policy. These do not block refinement.

## Next allowed action

**S6.E — The five-second test** (owner-run evidence; the plan's "S6.E"):
1. **S4V-02 first** (documentation; an agent can do it when asked): correct
   `research/S4.R1_FLOW_INVENTORY.md` §7's device rules, so Tests A and C can run without disturbing
   the owner's data;
2. the owner runs Test A on the planner's and Tonight's first screens (the `.s2check` package, or a
   plan they are happy to change; never reset or uninstall the owner's app);
3. the answers go into `evidence/STAGE_6_FIVE_SECOND_TEST.md`.
If it cannot be run, the Stage 6 validation records the gap and the owner decides (V7). Then
**Stage 6 validation**, in a fresh session (its frozen checks are in the plan, "Stage 6
validation").
- **Verification:** the full gate after the last code change (the Task's rule).
- Then commit and STOP.

**Carried:**
- S4-DEF-04 decided (R) and built by S6.3; S4-DEF-01 (allocated to Stage 8 at Stage 6 planning), S4-DEF-02,
  S4-DEF-03 and S4-DEF-05 to S4-DEF-08 (Stage 8);
- S4V-02 (correct the S4.E script before Test A or C runs on the owner's install): the first step of
  S6.E;
- S3V-08: a device recheck of the corrected Stage 3 flow (unverified; separate);
- TD-072 (S3S-03, deferred by the owner) with its S3F-01 addendum; S3F-02 (a note on TD-071, no
  Task proposed);
- TD-070's remainder (per-field snapshot provenance; snapshots saved before S3.V7): Stage 8;
- W1 (decided with RD-05's U1): built by S6.3;
- TD-063 (Stage 8);
- TD-057 and TD-058: resolved (S6.4, S6.2);
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
