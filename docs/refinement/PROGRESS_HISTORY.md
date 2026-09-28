# AstroPlan — Refinement Progress: history

> **Historical record, not current state.** Moved verbatim from `PROGRESS.md` on 2026-09-27 by the
> governance correction, so that `PROGRESS.md` is a short handoff. Nothing here was rewritten. Newer
> entries are not added here as a matter of course: a Stage's validation detail lives in its
> `STAGE_N_*.md` report, and a Task's in its commit and the living registers. The current state,
> reusable evidence and next action are in `PROGRESS.md`. **Exception, 2026-09-27 (Stage 6
> planning):** the Stage 5, governance-correction and amendment entries were moved here verbatim,
> because some of their facts are recorded nowhere else.
> **Exception, 2026-09-28 (Stage 7 planning):** Stage 6's entries were moved here verbatim in the
> same way.

## Earlier "Current state" entries (newest first, up to Stage 7 planning)

*Moved verbatim from `PROGRESS.md` on 2026-09-28 at Stage 7 planning: Stage 6's entries, from its
planning to its closure, and the "Before this" pointer that followed them. The Stage 6 planning
batch follows them.*

**Stage 6 closed, 2026-09-28** ([report](STAGE_6_VALIDATION.md), "Revalidation of S6V-01 /
TD-082 (V5)"): the V5 revalidation passed at `da4c53d`. Run in the chat that wrote S6.V1, at the
owner's request, so **not independent** (disclosed). Scope: F1, S6.8's badge rule, S6.9's Delete +
Undo, stale recovery and S6.V1's regression surface; every other PASS stands (V6). Evidence: the
full gate and the recorded probe reused (V3); the five committed regression tests; four fresh
adversarial probes, all PASS (a target change keeps the badge; a reorder, a second delete and Copy
behave; temporary, not committed). No blocker; one observation (after a reorder the block returns
at its old index, as S6.9 specifies). S6.E stays **UNVERIFIED — no independent participant
available**, the gap the owner accepted. Verification: documentation class. The Stage 6 entries
below stay here until Stage 7 planning moves them verbatim to `PROGRESS_HISTORY.md`, as Stage 6
planning did for Stage 5's.

**S6.V1 done, 2026-09-28** (`da4c53d`; S6V-01 / TD-082 resolved; the owner's S6.V1 prompt; the plan's
"Stage 6 validation" table): a delete's Undo owns only the deleted block.
- **Root cause:** `_BlockListState._delete` kept the example badge as it was at the delete, and
  `restoreCaptureBlock` wrote it back unconditionally. Add shows no message of its own, so the
  delete's Undo stays up after it, and tapping it relabelled the edited plan as the untouched
  example. A plan replaced meanwhile (New, Copy, Open, Track live) would also have received the
  old block.
- **Fix:** Delete runs through `deleteBlockWithUndo` (`widgets/capture_plan/blocks_undo.dart`),
  which records the delete as S6.16's `BlocksEdit`, with the session read after its autosave.
  `SessionPlanViewModel.restoreCaptureBlock(index, block, deletion:)` puts the identical block
  back at its index and keeps every edit made since. It restores the badge only while
  `BlocksEdit.isCurrent` holds (nothing changed since the delete). When `BlocksEdit.inPlan` fails
  (the plan was replaced), it is refused with S6.16's "Not undone" message. No history, no schema
  or persistence change. The removal is still immediate; its Undo message now appears once the
  delete's autosave has finished, as S6.16's messages do.
- **Tests:** five in `capture_blocks_undo_test.dart` ("Delete with Undo owns only the deleted
  block (TD-082)"): the exact sequence; a block edited since; Undo at once restores the example
  with its badge; a replaced plan; a saved plan's snapshot unchanged. The first, second and fourth
  fail on the old code. The recorded probe (`evidence/S6V_01_DELETE_UNDO_PROBE.patch`, applied
  temporarily, then removed) passes. S6.9's and S6.16's tests are unchanged and pass.
- **Verification:** class shared behaviour (a ViewModel and a shared helper). The full gate ran
  once, after the last code change, because the Stage Exit's gate must hold on the final inputs:
  PASS (below). Every acceptance criterion of the prompt checked. Stage 6 is **not** closed.

**Stage 6 validation, 2026-09-28: BLOCKED** ([report](STAGE_6_VALIDATION.md)). S6V-01 /
TD-082 reproduced: Delete from the example → Add a block → old Undo preserves the new block
but falsely restores the example badge. S6.8's badge rule and stale recovery fail; the other
technical criteria pass. S6.16's full gate reused under V3 (no changed inputs); one fresh focused
probe fails on the uncovered sequence. No code or existing tests changed. The past Capture ends
observation agrees with the selected whole-night contract (classification A, report C1).
S6.E is **UNVERIFIED — no independent participant available**, explicitly accepted by the owner;
that gap does not block closure. Stage 7 remains unstarted.

**S6.E device refreshed, 2026-09-28, 22:52–22:55** (documentation only; details in
`evidence/STAGE_6_FIVE_SECOND_TEST.md`): the separate `.s2check` app is now a debug build of
`d7e1477` (S6.16), built in a detached worktree with the local application-id suffix (reverted,
never committed) and installed as an update. The owner's app was not touched (last update 22:44:13
before and after; that update came from an Android Studio `flutter run` session, not this setup). A
new saved test plan (Test site, M31, the example rig and plan, night of Mon, Sep 28) reads "Fits: 1 h
48 min needed of 8 h 35 min usable"; the owner's review plan stays in Sessions. Both test screens
render; no device defect prevents the test. TD-080's two target actions are approved by the owner as
built. The five questions still need an independent participant.

**S6.16 done, 2026-09-28** (the owner's corrective pass; DECISIONS E.1, "Stage 6 corrective pass
decided"): TD-075–TD-080 resolved; ADR-019 §6 amended and built (status → site and night → target →
rig → capture plan → "Tonight for this target" → conditions); the core screens' finish (Tonight's
page title, context card, "Your plan" heading, Open planner always primary, the target rows; the
planner's status card and section headings); Undo for Fill/Trim, a saved block edit and the example
plan (no global undo). TD-081 recorded (messages slide even with reduced motion; not fixed).
The `.s2check` build was refreshed from S6.16's commit afterwards (above). Verification: the full gate
after the last code change, PASS (below); every acceptance criterion checked.

**Owner decisions, 2026-09-28 (in the session prompt):** the corrective pass above, the planner's
order (ADR-019 §6 amended), the visual finish of Tonight and the planner in Stage 6 (Stage 9 keeps the
secondary screens), TD-079 as bounded recovery, TD-080's wording, and the five-second test's rule
(an independent participant, or UNVERIFIED and recorded by the validation; never the owner's review
or an agent). DECISIONS E.1, "Stage 6 corrective pass decided".

**Owner manual UX review, 2026-09-28** (HUMAN / OWNER MANUAL UX REVIEW, **not** a five-second
result; `evidence/STAGE_6_FIVE_SECOND_TEST.md`): 22 observations on the `.s2check` app, each
classified against this plan. No regression. **Current-stage issues** (small, Stage 6's own):
TD-075 (the status's reason vs a missing-input headline), TD-076 (the stacking-gain graph does not
label the planned point), TD-077 ("Your plan" heading in the button text role), TD-078 (Night &
Moon repeats its summary). **New bounded follow-ups:** TD-079 (no way back from Fill/Trim, a saved
block edit, the example plan), TD-080 (Tonight's two target actions look alike). **Owner
decisions raised:** the planner's order (would amend ADR-019 §6); who owns the visual finish of
Tonight and the planner. **Owned later, as planned:** Stage 7 (binning, ISO/gain, calibration
frames: RG-10, RG-11; elevation, Bortle, SQM: RG-08, RG-09), Stage 8 (results and the export action:
P8.1, P8.2, P8.7), Stage 9 (detail screens' presentation, typography consistency, Tonight's rows,
Settings: P9.3). **The five-second test stays UNVERIFIED.** Verification: documentation class.

**S6.E device first set up, 2026-09-28** (superseded by the refresh above): a `.s2check` build of
`f19aef7`'s code, used by the owner's review. Found while setting up: TD-075 (since resolved by
S6.16).

**S6.E step 1 done, 2026-09-28** (S4V-02 corrected; documentation only):
`research/S4.R1_FLOW_INVENTORY.md` §7's device rules now say that no test only looks (the plan
autosaves; Save plan and Track live store records), how to run Test A on the owner's app without
losing anything (Save plan, then ⋮ → New plan), and that Tests B and C belong on `.s2check`; Tests A–C
follow the current app (an empty new plan, Save plan and Track live in the planner, the timeline).
`evidence/STAGE_6_FIVE_SECOND_TEST.md` is prepared for the answers, not yet run. Verification: the
documentation class (references resolve; `git diff --check`).

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

*Moved verbatim from `PROGRESS.md` on 2026-09-27 at Stage 6 planning: Stage 5's entries, the
governance correction and the Stages 6–11 amendment. Some of their facts (the owner's debug build,
the CI filter cleanup) are recorded nowhere else. The Stage 4 entries follow them.*

**Stages 6–11 amended after Stage 5, 2026-09-27** (planning and documentation only; the owner's
brief `prompts/AMEND_STAGES_6_11_AFTER_STAGE5.md`):
- **Amended, not replaced,** from the manual dogfooding (08) and the owner's post-Stage-5 UI/UX
  analysis:
  - new "Stages 6–11: shared rules" in the plan: one owner per responsibility, the answer-first
    hierarchy with a "never hidden" list, disclosure, visualisation, look, words, exclusions;
  - **Stage 6** gains P6.8 (the capture plan's blocks), P6.9 (outputs, "what fits", storage
    verified first), P6.10 (the √N graph) and P6.11 (the night and opportunity timeline). P6.1 and
    P6.3–P6.6 are clarified;
  - **Stage 7:** its areas and RG-07 to RG-11 gain their required outputs (the automation order;
    the calibration and capture-parameter matrices);
  - **Stage 8:** P8.4 becomes the tracker's safe retirement, P8.5 is split into the list and P8.7
    (the entry), and P8.6 (optional names) is kept;
  - **Stage 9** gains P9.3 (Settings), P9.4 (logo and splash) and P9.5 (licence);
  - **Stages 10 and 11** are clarified: measure first; one bounded final validation.
- **Superseded (the owner):** the dedicated tracker leaves the target product (DECISIONS E.1,
  "Stages 6–11 amended after Stage 5"; ADR-019 §2 and §4; RG-04's optional tracker;
  `PRODUCT_DIRECTION.md` §3–§4). Stage 8 retires it after a dependency audit, and nothing is
  deleted before that. RD-12 lapses; RD-13 narrows.
- **Clarified:** `PRODUCT_DIRECTION.md` §5.2 (what disclosure never hides).
- Stage 5 stays closed. No application code, test, tool or frozen Task changed. Verification: the
  documentation class (V1).

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

**Stage 5** (plan: "Stage 5 — frozen Task sequence"; planned at `a354032`):
- **RD-09 decided** 2026-09-27 by the owner: M + S1 (`9640915`; DECISIONS E.1, "RD-09 decided").
- **S5.1 done** 2026-09-27 (`49344c9`): the text roles (`AppPalette.textPrimary`/`Secondary`/
  `Tertiary`/`Disabled`), the raised surface and border tokens, `AppTypography.scale`, `AppRadius`,
  the documented `AppSpacing`; the colour scheme follows the roles; the gallery test
  (`test/presentation/design_system/`); `docs/DESIGN_SYSTEM.md`; ARCHITECTURE B17. The first gate
  run caught a light-theme regression (black on the darker secondary in a selected segment,
  2.99:1), fixed with an explicit selected container and a guarding test. Verification: shared
  behaviour (the theme reaches every screen) and the Task's "gate green": the full gate after the
  last code change, PASS (below). Every acceptance criterion checked.
- **S5.2 done** 2026-09-27 (`6363727`): component themes for the controls (`AppTheme._withControls`):
  - one button hierarchy (primary filled, secondary outlined, tertiary text, destructive via
    `AppButtonStyles`, flat elevated = secondary), 48 dp, a 16 % pressed overlay;
  - a quiet field underline: `colorScheme.outline` = `AppPalette.controlBorder` (3:1). Material
    had drawn it black or white (08 §6); in field mode it is `#880000` (UX-39);
  - text-role labels and hints; dialogs, sheets, menus and light/dark messages themed; dark
    error `#F28B82` (AA on the raised surface);
  - `AppMotion` (reduced motion honoured); an icon set;
  - `FitText`'s neutral moved to `textSecondary`, since `outline` is no longer AA as text.

  The gallery now holds every control in its states and opens a dialog, a message and a menu. New
  `controls_theme_test.dart`. Verification: shared behaviour and the Task's "gate green": the full
  gate after the last code change, PASS (below). Every acceptance criterion checked.
- **S5.3 done** 2026-09-27 (`0343962`): the glossary's words once, in
  `lib/presentation/shared/app_words.dart` (`AppWords`), pinned to the glossary by
  `app_words_test.dart`. `retired_terms_test.dart` scans `lib/presentation`'s string literals
  (imports, `Key` values, comments and identifiers exempt) against an explicit baseline: 16
  occurrences in 8 files at `38925dd`. A new occurrence or a stale entry fails, and its own cases
  show both. No existing string was renamed. Verification: the Task's "gate green", the full gate
  after the last code change, PASS (below). Every acceptance criterion checked.
- **S5.4 done** 2026-09-27 (`3e9a487`):
  - **status and state tokens** in `AppPalette`, in the three themes (UX-16). `FitText.color`
    reads them, with the same values as before;
  - **`StatusBlock`** (`lib/presentation/shared/status_block.dart`): the verdict headline in the
    glossary's words ("Fits: … needed of … usable"; the word alone when a duration is unknown;
    Needs a target / a block neutral), the reason, key numbers and an action slot; plain values
    in;
  - **`PlanState`** (`plan_state.dart`): the pure mapping from stored status, `plannedAtUtc` and
    legacy (every combination tested; Partly waits for Stage 8), and `PlanStateLabel`;
  - both in the gallery; no screen changed.

  Verification: the Task's "gate green", the full gate after the last code change, PASS (below).
  Every acceptance criterion checked.
- **S5.5 done** 2026-09-27 (`2e8b95f`):
  - **`CollapsibleSection`:** a 48 dp header with the title, a factual summary that stays
    visible, and a turning chevron; the content opens below it. It is one semantics button with
    its expanded state, hint and tap action;
  - **remembered per section key:** `DisclosureViewModel` (in `AppViewModels`, loaded in
    `main.dart` before the first frame) stores it through `DisplayPreferencesRepository`
    (`section.<key>`; `guardStorage`). A broken store is logged and the section still works;
  - **tested:** restart restores the state, keys are independent, a broken store is handled,
    reduced motion is honoured, and the gallery includes it;
  - **a bug found and fixed:** the reduced-motion test showed that `AnimatedSize` with a zero
    duration throws a layout assertion. The section now leaves it out under reduced motion, and
    `DESIGN_SYSTEM.md` §6.2 records the rule.

  Verification: the full gate after the last `lib` change PASSED its tests (1,292, 1 skip) and
  host E2E, but Analyze flagged one deprecated matcher in the new test. That test file was fixed,
  then re-verified per V3: `flutter analyze` on the whole project, that file's tests, format and
  encoding, all clean. No other input changed. Every acceptance criterion checked.
- **S5.6 done** 2026-09-27 (`52631f6`):
  - **`ContextLine`** (`lib/presentation/shared/context_line.dart`): site ▾ · night ▾, each a 48 dp
    labelled button reporting its tap. The zone rule is shown once: the site's zone, or the
    labelled device zone. Without a site there is no night and no rule;
  - **`pickNight`:** the shared, themed date picker, returning a `CalendarDate` (null when
    cancelled). Its pixel test shows it red or black in field mode by its theme alone, without the
    app filter, plus a sanity run in light;
  - in the gallery; no screen changed.

  Verification: the Task's "gate green", the full gate after the last code change, PASS (below).
  Every acceptance criterion checked.
- **S5.7 done** 2026-09-27 (`c9f2deb`): `DetailScaffold` (`lib/presentation/shared/detail_scaffold.dart`):
  - a header with the title (a semantic header), its context and the zone rule exactly once, all
    wrapping at 200 % text. The title is in the page header because an app bar's cannot wrap; the
    app bar keeps back and the actions;
  - a summary card, then the sections separated by dividers;
  - the gallery sweeps a sample Night & Moon page on it (`pumpGalleryPage`), and a template test
    checks the order, the single zone rule and the wrapping.

  Verification: the Task's "gate green", the full gate after the last code change, PASS (below).
  Every acceptance criterion checked.
- **S5.8 done** 2026-09-27 (`99e60af`), per RD-09 = M + S1:
  - **confirmations** (`confirmation_patterns.dart`): `askUnsavedChanges` (Cancel · Discard ·
    Save; dismiss = Cancel) and `confirmDestructive` (true only on its verb);
  - **success** (`failure_feedback.dart`): `showDone`, beside `runWithFeedback`;
  - **deleting** (`delete_patterns.dart`): `showUndo` (exactly one outcome, undone or committed),
    `DeleteButton` (the visible Delete, S1), and `SwipeToDelete` (a swipe calls the same handler
    and the row springs back, 08 §20);
  - **tested:** every way out of each prompt; the undo outcomes on Undo, time-out, replacement
    and removal; the swipe; red or black in field mode without the app filter; all in the gallery;
  - **found:** Flutter keeps a message with an action on screen unless `persist: false`, so Undo
    would never have committed. `showUndo` sets it (tested), and two existing messages with
    actions are recorded as **TD-073** (not fixed);
  - no screen changed.

  Verification: the Task's "gate green", the full gate after the last code change, PASS (below).
  Every acceptance criterion checked.
- **S5.9 done** 2026-09-27 (`8a6c5d8`):
  - **the adoption plan:** `docs/DESIGN_SYSTEM.md` §9 maps each screen to the parts it adopts and
    the P-Task (P6.1–P6.6, the Stage 6 capture-plan work, P8.2, P8.4, P8.5, P9.1, P9.2, Stage 9
    Settings). Every Stage 5 part has at least one adopter, and every retired-terms baseline entry
    has its Stage (§9.3). The provisional Stage 6, 8 and 9 tables gain adoption notes, still not
    frozen;
  - **the rendered evidence:** 15 host-rendered images in `docs/refinement/evidence/stage5/`: the
    gallery in light, dark and field at 100 % and 200 %, plus the sample detail page, a
    confirmation and an undo message in each theme. Real fonts; field mode through the app's
    filter. See `evidence/STAGE_5_RENDERS.md`. They come from the opt-in
    `render_gallery_test.dart` (`ASTROPLAN_RENDER_GALLERY`; skipped in the gate), and the
    gallery's content now lives in `gallery_entries.dart`, shared by both tests;
  - **a render bug fixed before committing:** the first run kept a dialog open into the next
    image; each image now starts from an empty tree.

  Verification: test-only changes, and the Task's "gate green": the full gate after the last code
  change, PASS (below). Every acceptance criterion checked. The optional owner review of the
  images is non-blocking.
- **Stage 5 validation, 2026-09-27: FAIL at `8a6c5d8`, one narrow blocker**
  ([report](STAGE_5_VALIDATION.md); run in this chat at the owner's request, so **not independent**,
  disclosed).
  - Every frozen item passes except **S5V-01**: S5.5's "a test rebuilds the graph on the same
    store" has no committed graph-level test. The behaviour is correct (a probe through
    `PlannerHarness` passes).
  - Not blocking: TD-073 (predates Stage 5); UX-39's card borders in field mode (S5.2's documented
    choice); `CLAUDE.md`'s stale test count (outside Stage 5).
  - **The owner's question, answered in the report's §6.** The debug build looks unchanged
    because the new components are on no screen yet (by design; Stage 6 adopts them), and the
    theme changes are subtle: 1–10 % of pixels per screen in before/after renders
    (`evidence/stage5_before_after/`). Where to look is listed there. If even those are missing,
    the installed build predates `49344c9`.
- **S5.V1 done** 2026-09-27 (`178acbe`), S5V-01: `disclosure_viewmodel_test.dart` gains "a restart
  of the whole ViewModel graph on the same store keeps a section open". It builds two
  `PlannerHarness` graphs on one display store, the second loading as `main.dart` does. Test-only.
  Verification: the full gate after the change, PASS (below).
- **Revalidation of S5V-01 (V5), 2026-09-27: PASS** at `178acbe`. The test exists, goes through
  `AppViewModels`, and passes. The gate is reused (V3). **Stage 5 is closed**
  ([report §7](STAGE_5_VALIDATION.md)).
- **The owner's debug build, checked 2026-09-27 (read-only):**
  - the phone runs exactly the current build (installed-APK SHA-1 `8debc76c…` equals the local
    `app-debug.apk`, built after `178acbe`);
  - the build contains Stages 1, 3 and 5 (markers found in its Dart kernel);
  - the phone reports the app was first installed at 19:11 today, so earlier on-device data is not
    on it unless restored.

  Little looks different because Stages 1–5 changed little of the main screens' look. Stage 6
  does that.

---

**Final, bounded Stage 4 validation, 2026-09-27: PASS** at `09a7f06`
([report](STAGE_4_FINAL_VALIDATION.md)). **Stage 4 is closed.**
- **All seven frozen questions pass:**
  - research done;
  - every gate owner-decided;
  - ADR-019 faithful to each decision;
  - the addendum consistent;
  - S4.T maps §2–§10 to Stages 5–9;
  - no direct contradiction in the core flows;
  - no acceptance criterion unmet.
- **Not blocking:**
  - S4-DEF-01 to S4-DEF-08 (deferred to Stages 6 and 8);
  - S4V-02 (correct the S4.E script before Test A or C);
  - S4V-03 (unrun owner tests);
  - one observation: §10's list of retired terms is an excerpt of the normative glossary.
- **Independence, disclosed:** the owner asked for this validation in the session that wrote S4.V2
  and S4.V3; it was not a fresh session.
- **The code is unchanged** since `92ebf2a`, and the gate at `5ad69c4` (1,214 tests, 1 skip, 2
  host E2E) applies.

**S4.V3 complete, 2026-09-27 (documentation and governance only; the owner's instruction).**
- **The loop it stops:** each documentation validation derived more lifecycle policy, then
  validated it. The owner stopped that. S4.V2's five inferred rules (re-save, Discard on a saved
  entry, the working copy's night, "ended" as the SessionNight end, the live mode) are **not owner
  decisions**.
- **ADR-019 §3.1 now states only E2, R2 (with the owner's invariant) and D1.** The same reduction
  was applied to the ADR-014 pointer, §3's Discard line, D5, addendum §3.10, S4.R3 §13, TD-057,
  P6.1, P6.7 and P8.1–P8.3.
- **The open implementation cases** are S4-DEF-01 to S4-DEF-08, `DEFERRED / IMPLEMENTATION
  DECISION`, for Stage 6 or 8 (plan, S4.V3). They are not Stage 4 blockers.
- **The final Stage 4 validation is bounded to seven questions.** Only a direct contradiction with
  an approved decision or a Stage 4 acceptance criterion blocks. A pass closes Stage 4 and makes
  Stage 5 next.
- **The rule for future Stages:** the bounded-validation rule for analysis-and-decision Stages is
  in `CLAUDE.md` ("Validation Rules"), plan §9.8 and E.1.
- No application code or test changed.

**S4.V2 complete, 2026-09-27 (documentation only; the owner decided R2 + D1).**
- **The owner's invariant:** the plan snapshot is the immutable intent for its night; the result is
  the reported outcome for that snapshot; the working copy is independent. Recorded in E.1, "S4R-01
  and S4R-02 decided", and in ADR-019 §3.1 as revised.
- **S4R-01:**
  - the result flow is saved plan → Review saved plan (the snapshot) → report outcome → Save result;
  - there is no Save plan, and Not done is direct;
  - actuals go in the result record, never the snapshot;
  - no result before the saved night ends;
  - no guard about the working copy.
- **S4R-02:**
  - Stage 6 changes only never-saved drafts and working plans (P6.1, P6.7), and saved plans behave
    as today;
  - Stage 8 (P8.3) delivers the saved night and the independent working copy together.
- **S4R-03:** TD-057 is limited to never-saved drafts.
- **S4R-04:** ADR-019's status line records the S4.V1/S4.V2 amendments and their validation reports.
- **Derived rules**, listed in E.1 for the revalidation (the owner may override them):
  - "Save again" only for the same night before it ends; from Stage 8, a Save for another night or
    site creates a new plan;
  - Discard never deletes a saved entry;
  - the working copy keeps a working night that has not ended;
  - "ended" is the SessionNight end (the next mean solar noon);
  - the live Finish is unchanged.
- **Aligned:** the ADR-014 pointer, D5, addendum §3.7/§3.10, `PRODUCT_DIRECTION.md` §10, S4.R3 §13,
  RG-04 §14, and the plan's S4.V2 section and matrix (superseding S4.V1's), with P6.1, P6.7,
  P8.1–P8.3 and "Order across Stages".
- No application code or test changed; the gate result at `5ad69c4` still applies.
- S4V-02 (script setup, Tests A and C) is still open and non-blocking.

**Fresh-session Stage 4 revalidation, 2026-09-27: FAIL** at `5ad69c4`
([report](STAGE_4_REVALIDATION.md)). Validation only: no fix was made.
- **S4V-01 is resolved as reported.** Saved · changed is classified by save history and protected
  at startup and at a live rollover. The saved night comes from the snapshot (verified: it stores
  the night's bounds, zone and blocks). The documents agree on this protection.
- **S4R-01 (blocking):** §3.1's result path for Saved · changed is Review → Save → result, and the
  result "refers to the newly saved version". A Save snapshots the **working** night and site. So
  when a saved plan is moved to another night before its night ends (Save for N, move to N+1), the
  result is recorded against N+1, which has not happened. N gets no result, which contradicts E2's
  "stays on its night, awaiting its result". Also:
  - Review passes through U1's guard on tonight's continuation;
  - Not done waits for a Save.
- **S4R-02 (blocking):** the delivery boundary (P6.7 in Stage 6, with the continuation only in
  P8.3) makes Stages 6–7 resume last night's saved plan as current on its past night, or start a
  fresh plan (Y3, rejected). Either contradicts E2 and E.1's "Stage 8 implements E2's resume rule",
  and the interim is not stated anywhere.
- **Low:**
  - S4R-03: TD-057's direction ("write the plan at the rollover") ignores §3.1;
  - S4R-04: §3.1 was added after the owner accepted ADR-019, and the status line does not say so.
- **Neither blocking choice has a recorded owner approval;** E.1 records only the request to fix
  S4V-01. The owner's options: R1/R2/R3 for S4R-01, D1/D2/D3 for S4R-02 (the report's §"Proposed
  follow-up").
- **Carried:**
  - S4V-02 is still open. It now also covers Test A, whose step 1 changes the owner's current plan;
  - S4V-03 is unverified.
- **Gate re-run at `5ad69c4`: PASS** (Encoding; Format, 376 files, 0 changed; Analyze; 1,214
  tests, 1 expected skip; 2 host E2E). The code is unchanged since `92ebf2a`.

**S4.V1 complete, 2026-09-27 (documentation only; owner requested the fix).**
- **S4V-01 corrected, pending independent revalidation:** ADR-019 §3.1 protects both `planned`
  and `draft` + `plannedAtUtc` (Saved · changed) at startup and live rollover. It preserves
  saved context and working edits, defines the unsaved continuation, and distinguishes
  explicit historical review from automatic resume.
- Results for an edited saved entry require review and explicit Save, or Cancel. The result
  uses the explicitly saved version; a stale form must not mix working and snapshot values.
- Research, ADR-014's amendment pointer, D5, addendum and P6.7/P8.1–P8.3 are aligned.
  The plan's S4.V1 section carries a ten-case future acceptance matrix. P6.7 protects saved
  entries in place before Stage 8 adds continuations and the new result form.
- The validation **FAIL at `adb5d95`** remains historical (`STAGE_4_VALIDATION.md`); this
  correction is not an independent Stage PASS.
- **S4V-02, non-blocking:** the optional darkness script calls Test C read-only even though it
  starts and abandons a run. Correct the setup before running it.
- **S4V-03, unverified/non-blocking:** owner usability/darkness tests remain unrun, as permitted.
- No application code changed. Stage 5 stays blocked until Stage 4 passes.

**Historical completion record before validation:**
**S4.T done, 2026-09-27: every Stage 4 Task is done; Stage 4 is in validation.**
- **Provisional Tasks from ADR-019,** not frozen, were added to the Stage sections of
  `POST_ROADMAP_PLAN.md`:
  - **Stage 5**, P5.1–P5.6: the shared vocabulary with a retired-terms test; the collapsible
    section; the context line; the status block and state label; the detail-screen template; the
    confirmation and feedback patterns;
  - **Stage 6**, P6.0–P6.7: splitting `SessionPlanViewModel`; the lifecycle UI with Track live in
    ⋮; the defaults and first run; the planner's structure; disclosure; the detail screens; Tonight
    plan-first; TD-057. Also a five-second test as acceptance evidence;
  - **Stage 7:** none from ADR-019; RD-08 still comes before Stage 6's capture-plan work;
  - **Stage 8**, P8.1–P8.6: results without a run; the result form; the next-day rule and Tonight's
    line; the live mode as an option; the Logbook with Progress; an optional name;
  - **Stage 9**, P9.1–P9.2: the Library manages; the vocabulary completed.
- **The order across Stages:** keep a path to results at every step (Stage 6 moves Start into ⋮;
  it never removes it before Stage 8's result form). Progress leaves the Library only after it is in
  the Logbook.
- **§6.2's rows** for UX-01 to UX-14, UX-24, UX-25 and UX-26 point to ADR-019 and the P-Tasks.
  UX-27 is unchanged (Appendix C).
- Each Stage's own planning re-verifies, freezes and renumbers its Tasks (P-IDs are never reused).
- No code changed.

**S4.D done, 2026-09-27: ADR-019 accepted** (the owner, in chat).
- **ADR-019, "Product flow and information architecture"** (DECISIONS Part F), records the eight
  Stage 4 decisions as one design.
- **It amends:**
  - ADR-009 §2 (display only: the budget lines within Budget details);
  - ADR-014 §3 (results without a run; yesterday's saved plan is not resumed);
  - ADR-015 §2, the route map and §7 (the answer-first planner; the Night & Moon and Weather
    details; the Library manages);
  - ADR-016 (execution optional; post-session counts as events).

  Each amended ADR carries an "Amended by ADR-019" pointer.
- **`docs/IA_WIREFRAMES_ADDENDUM.md`:** low-fidelity Tonight, the planner, the unsaved-changes
  prompt, the Night & Moon and Weather details, the Logbook, the result form, the Library and the
  first run. `IA_WIREFRAMES.md` is unchanged.
- **DEV-P9** (DECISIONS Part B) records UX-04 and UX-11 until Stage 6 builds them.
- **ARCHITECTURE D5** points to the direction.
- **S4.R1 §9** answers every matrix question: Q1–Q22 and the UX findings. Q8, Q14, Q15 and Q21 go
  to other Stages per the plan.
- No code changed.

**RD-07 and RD-14 decided, 2026-09-27 (S4.R5 done). Every Stage 4 gate is now decided.** Research:
[`research/S4.R5_LIBRARY_AND_VOCABULARY.md`](research/S4.R5_LIBRARY_AND_VOCABULARY.md)
(`160ee37`). The owner chose the recommended option on each question (DECISIONS E.1, "RD-07 and
RD-14 decided"):
- **H1:**
  - the Library manages rigs, targets and sites, and a tap never changes the plan (TD-053, when
    built);
  - choosing happens in the planner, Tonight's context line and the first run;
  - "Plan this target";
  - Progress moves to the Logbook.
- **H2:** Rig.
- **H3:** Plan + Logbook.
- **H4:** the glossary as proposed:
  - the states and results;
  - "Dark" with its limit;
  - the budget: Integration · Imaging time · Time needed · Total time;
  - the verdict headline;
  - "Export as file";
  - "Name (optional)".
- Next: S4.D records all of it in ADR-019, with a wireframe addendum. No code changed.

**RG-05, RD-06 and RG-06 decided, 2026-09-27 (S4.R4 done).** Research:
[`research/RG-05_06_TONIGHT_AND_PLANNER.md`](research/RG-05_06_TONIGHT_AND_PLANNER.md)
(`8578ab8`). The owner chose the recommended option on each question (DECISIONS E.1, "RG-05, RD-06
and RG-06 decided"):
- **F1 = T1:** Tonight plan-first, under a site ▾ · night ▾ context line. The night picker (UX-11)
  changes the current plan's night.
- **F2 = D-b:** Night & Moon and Weather detail screens, from Tonight and the planner; no new tab.
- **F3 = P-1:** the planner answers first (the verdict, reason and key numbers), then follows the
  decision order: context → target and windows → capture plan → conditions summary → rig summary.
  This amends ADR-015 §2.
- **F4 = M0:** the budget breakdown, √N help, assumptions, every weather variable and the rig's rows
  one tap away, behind factual summaries; ADR-009 §2's "own line" within the budget details; no
  modes.
- **Evidence gap:** S4.E not run; Stage 6's acceptance is to include a five-second test.
- ADR-019 (S4.D) records the amendments. No code changed.

**RD-05 and RD-04 decided, 2026-09-27 (S4.R3 done).** Research:
[`research/S4.R3_SESSION_LIFECYCLE.md`](research/S4.R3_SESSION_LIFECYCLE.md) (`989a61e`). Verified
conflict: yesterday's saved plan is resumed and rolled forward to tonight, which RG-04 cannot keep.
The owner chose the recommended option on each question (DECISIONS E.1, "RD-05 and RD-04
decided"):
- **E1 = L1:** Draft is internal; the plan's state reads "Not saved", "Saved" or
  "Saved · changed"; Save stays explicit, and only saved plans enter the Logbook.
- **E2 = Y2:** a saved plan whose night has passed waits for its result; the planner continues on a
  copy for tonight.
- **E3 (RD-04):** nothing preselected on the first run; New keeps the site and rig and asks for the
  target; an empty capture plan with "Start from the example plan".
- **E4 = U1:** Save · Discard · Cancel; Discard deletes; a site change and a Duplicate count as
  unsaved (W1, V3).
- **Also decided:** the planner's app bar shows the target, night and state (UX-04); feedback after
  New, Duplicate and Open; no failing Start (UX-13); TD-057 and TD-058 fixed where this is built.
- **Supersedes:** TASK 11.4's "New = tonight + the example plan", and its roll-forward for saved
  plans; the S1.6 interim.
- ADR-019 (S4.D) amends ADR-014 §3. Stage 6 and Stage 8 implement. No code changed.

**RG-04 decided, 2026-09-27 (S4.R2 done).** The owner chose the recommended option on each
question (DECISIONS E.1, "RG-04 decided"):
- **D1 = B:** the Logbook first; the tracker optional, off the primary path.
- **D2 = G2:** "Completed as planned" in one tap; "Partly" with numbers per light block; "Not done"
  with a reason. Conditions stay optional.
- **D3:** "Not done" → `abandoned`, with a reason; "Partly" → `completed`.
- **D4:** a quiet "how did it go?" line on Tonight, plus the Logbook.
- ADR-019 (S4.D) records the ADR-014 and ADR-016 amendments; Stage 8 implements. Execution stays as
  built until then.
- `PRODUCT_DIRECTION.md` §4 notes the decision.

**S4.R2 research done, 2026-09-27 (documentation only):**
[`research/RG-04_EXECUTION_ROLE.md`](research/RG-04_EXECUTION_ROLE.md), at `e5fd240`. The owner
accepted S4.R1 and answered O1–O4 (recorded in S4.R1 §6.1). The key points: no practical reason
is seen for Start → Tracker → Results; the intended flow is plan → save → image → Logbook →
record; only Completed / Not completed was proposed; detailed actuals are options, not
requirements.
- **Evidence** is kept apart: current behaviour, roadmap intent, the owner's report and the audits.
- **Capabilities today, C1–C12:** everything valued after the session (results, planned vs actual,
  Progress) depends on counts, not on the tracker.
- **Verified:** there is no result without Start (ADR-014 §3; events only for a started run), and
  no UI to mark an unstarted plan "not done".
- **Options:**
  - what is recorded after a session: G1 outcome only; G2 outcome, with numbers only when needed;
    G3 full results;
  - Execution's role: A as built; B Logbook first, tracker optional; C Logbook only (hidden or
    removed); D simplified tracker.
- **Recommended:** B with G2. C (hidden) is the strong alternative if simplicity outweighs keeping
  the live mode.
- **Owner decisions pending:**
  - D1: the role;
  - D2: how much is recorded;
  - D3: "Not done" maps to abandoned, with a reason;
  - D4: a quiet "How did it go?" line on Tonight.
- No code changed.

**S4.R1 done, 2026-09-27 (research, documentation only):**
[`research/S4.R1_FLOW_INVENTORY.md`](research/S4.R1_FLOW_INVENTORY.md), at `2a26185`.
- The routes against the wireframes: 3 deviations recorded in ADR-015 §7, 1 by ADR-018 §7 (the
  import route), and the content deviations UX-04, UX-11 and the Sessions tab's missing "+" and
  grouping.
- Every session action, with its entry points, confirmation, feedback and effect. Notable:
  - New keeps the target and rig and resets the night and blocks;
  - after Start the planner continues on a copy, and Tonight offers that copy's Start;
  - **a result can be recorded only through Start**, so a plan logged after the night gets a run
    stamped "now", an estimate of about zero, and +1 per frame. This is an RG-04 input.
- Session states on each screen (the planner shows none; pure drafts are not listed).
- Taps per core task, re-measured from the code: 16 rows, 2 new (a result after the night: 6 taps
  plus 1 per frame; a rig from a photo: about 5).
- The question matrix: 22 questions from 08 (each with a home; 7 outside Stage 4) and 18 UX
  findings (all current, UX-12 mitigated by S1.6).
- Four owner clarifications (O1–O4; not decisions), and the S4.E script with a record table.
- No code changed; the gate result at `92ebf2a` still applies. Run in the same chat as Stage 4
  planning, at the owner's request.

**Stage 4 planning, 2026-09-27 (documentation only), at `126d97f`.** Stage 4 — Product Flow &
Information Architecture — is **in progress**. Its Task sequence is frozen
(`POST_ROADMAP_PLAN.md`, "Stage 4 — frozen Task sequence"; DECISIONS E.1, "Stage 3 closed;
Stage 4 planning decisions"). The owner chose the recommended option on each question:
- **the sequence:** S4.R1 → S4.R2 (RG-04) → S4.R3 (RD-05, RD-04) → S4.R4 (RG-05, RD-06, RG-06) →
  S4.R5 (RD-07, RD-14) → S4.D (ADR-019, wireframe addendum) → S4.T (provisional Tasks for
  Stages 5, 6, 8, 9) → a fresh-session Stage 4 validation;
- **owner-run quick tests (S4.E):** optional and non-blocking; S4.R1 writes the script;
- **decisions:** after each research step.

Every Stage 4 input was re-verified against the code (§9.7); none is stale (UX-04, UX-10, UX-11,
UX-12, UX-13, UX-14/TD-053, UX-25, RD-04, RD-14). Planned in the same chat as the Stage 3
sign-off, at the owner's request, not a fresh one. No code changed, so the gate result at
`92ebf2a` still applies.

**Stage 3 final sign-off, 2026-09-27: PASS** at `92ebf2a`, in a fresh session. See
[the report](STAGE_3_FINAL_SIGNOFF.md) and [probe evidence](evidence/STAGE_3_FINAL_SIGNOFF_PROBES.md).
Stage 3 is **closed**.
- **Freshly executed, all pass:**
  - the full gate (Encoding; Format, 376 files, 0 changed; Analyze; 1,214 tests, one expected
    skip; 2 host E2E);
  - the Stage 3 targeted suites (352 tests, one expected skip);
  - the four real samples (856 / 856 / 843 / 4,051 bytes, unchanged);
  - the four native JVM tests;
  - the archived probes P1–P10, R1, F1a, F2 and both P+; F1b and F3, which pinned S3S-01 and
    S3S-02, now fail as expected;
  - 13 new probes (G1–G6 for S3.V7, H1–H7 for S3.V8 and the paths next to it).
- **Resolved and re-verified:** S3V-01 to S3V-07, S3S-01, S3S-02.
- **Non-blocking, recorded, not fixed:** S3F-01 (a portrait-entered rig's sensor size is copied
  transposed; addendum to TD-072); S3F-02 (the RAW size is still copied across pixel counts; a
  note on TD-071, no Task proposed). S3S-03 (TD-072) stays deferred.
- **Unverified:** S3V-08 (device). No device interaction; M4 stays the recorded device evidence.
- No application code, test or dependency changed.

**S3.V8 done, 2026-09-27 (S3S-02; TD-071 and SI-014 resolved; owner option (a)).**
- "New rig with the camera specs of" a saved rig no longer copies its pixel size or sensor size
  when the file's pixel count differs from that rig's (compared orientation-free).
- Those fields stay empty, and Save waits for the user's pixel size; the sensor size follows from
  it. The editor says why, giving both pixel counts.
- The match, the equal-pixel-count copy and the file's own estimate are unchanged.
- **Next:** a fresh-session Stage 3 sign-off. It checks the original Stage 3 acceptance, every
  previous blocking finding (S3V-01 to S3V-06, S3S-01, S3S-02), and regressions around the
  corrected areas.

**S3.V7 done, 2026-09-27 (S3S-01, TD-070 partly resolved).** The owner approved S3.V7 and S3.V8
as separate Tasks, and deferred S3S-03 (DECISIONS E.1, "Stage 3 sign-off failed: corrective
Tasks").
- The rig editor now states a saved rig's provenance per spec. An imported rig's estimates read
  as estimated and its file values as from the file; a rig typed by hand reads as before.
- A new session snapshot records a group's provenance only when every spec shares it, else null.
  It never records an invented `user`.
- Per-field snapshot provenance, and snapshots already saved, are Stage 8's.
- **Next: S3.V8.** Then a fresh-session Stage 3 sign-off.

**Fresh-session Stage 3 sign-off, 2026-09-27: FAIL** at `74026ca`. Its code is identical to `d5e2b60`.
See [the sign-off report](STAGE_3_SIGNOFF_VALIDATION.md) and
[probe evidence](evidence/STAGE_3_SIGNOFF_PROBES.md).

- **Freshly executed, all pass:**
  - the full gate (1,195 tests, one expected skip, 2 host E2E);
  - the four real samples;
  - the four native JVM tests;
  - six new synthetic probes over real SQLite.
- **Blocking:**
  - **S3S-01 (TD-070):** the rig editor's provenance line and the session snapshot read only the
    group pairs, which an import saves as `user`/`reported`. An imported rig's CALC-40 estimates
    are therefore shown as "Camera specs: reported (user)".
  - **S3S-02 (TD-071, SI-014):** "New rig with the camera specs of …" copies the saved pitch and
    sensor size into a file of another pixel count. F3 stores half-consistent geometry, and the
    pixel scale is 2× off.
- **Non-blocking:** S3S-03 (TD-072), transposed size "conflicts" for a portrait-entered rig.
- **Unchanged:** everything the earlier reports checked still holds, and no application code
  changed. S3V-08 (device) stays unverified.

The repeat PASS below remains a record of what it checked. It did not exercise these paths.

**Repeat Stage 3 validation, 2026-09-27: PASS** at `d5e2b60`.
See [the repeat report](STAGE_3_REVALIDATION.md) and
[probe evidence](evidence/STAGE_3_REVALIDATION_PROBES.md). Freshly executed:
the full gate (1,195 tests, one expected skip, 2 host E2E), all ten archived
probes plus one additional camera-copy probe (11 pass), all four real metadata
samples, and all four native JVM tests. All prior blockers are resolved.
No application code changed in this validation. Fresh phone testing is not
claimed; S3V-08 and the previously carried device checks remain unverified.
The fresh-session validation requirement in §9.8 is not fulfilled by this
same-chat repeat. Formal Stage closure remains pending that check or an explicit
owner waiver; no waiver is inferred from the request to revalidate.

The failed validation below remains historical evidence; its findings were
corrected by S3.V1–S3.V6 and rechecked by the repeat report.

**Stage 3 validation, 2026-09-26: FAIL.** See [the report](STAGE_3_VALIDATION.md)
and [reproducible probes](evidence/STAGE_3_VALIDATION_PROBES.md). Baseline gate:
1,169 tests, one expected skip, 2 host E2E; four real metadata samples and four
native JVM tests pass. Independent probes reproduce stale-review data loss,
invented provenance, ineffective sensor conflict replacement, rounding of copied
saved values, and absurd dimensions accepted as known. Required real-database
review behavior tests are also missing. No application fixes were made. Stage 4
has not started. This was a validation-only follow-up in the existing chat;
the report discloses its earlier debug/exposure contributions and device limits.

Current visibility is **Add from a photo on Equipment in all build modes**;
the two debug/exposure amendments below are historical and superseded by S3.7.

*(Historical as to visibility and M4; superseded by S3.7 (`2b045eb`, 2026-09-26): the import is visible in every build as "Add from a photo" on the equipment screen, and the Settings viewer entry is removed. TD-066's formatting itself stands. Marked by S3.V5, S3V-07.)*
**Exposure formatting amendment, 2026-09-26 (owner, TD-066):** brought forward
from S3.7 after enabling the debug viewer. Shared `QuantityText.exposure` uses
integer reciprocal fractions within 0.5% relative error, with ≈ for approximation
(1e-12 tolerance for floating-point noise). Thus 0.04005 s → ≈1/25 s and
0.02 s → 1/50 s. Original metadata, raw rationals and calculations are unchanged.
The public workflow and M4 still belong to S3.7. Targeted formatter, metadata-row
and metadata-screen tests: 20 pass. Full quality gate passes: encoding, format,
analysis, 1,094 unit/widget tests (one expected local-sample skip) and 2 host E2E
tests. This run also includes the concurrent S3.2 tests present in the workspace.

*(Historical; superseded by S3.7 (`2b045eb`, 2026-09-26): the import is visible in every build as "Add from a photo" on the equipment screen, and the Settings viewer entry is removed. Marked by S3.V5, S3V-07.)*
**Debug access amendment, 2026-09-26 (owner):** Settings → Import metadata is
enabled in debug builds for Stage 3 development (`FeatureScope.metadataImport`
uses `kDebugMode`). Profile/release visibility and the planned Equipment
"Add from a photo" workflow still wait for S3.7 (ADR-018 §7). This does not
change the Stage 3 Task order or mark any import/persistence Task complete.
Verification: `dart run tool/check.dart` passes after updating the existing
visibility assertions: encoding, format, analysis, 1082 tests (1 expected
local-sample skip) and 2 host E2E tests. Hot restart/relaunch is required for
an already-running debug app to register the route.

| Item | State |
| --- | --- |
| Current strategic phase | **Post-roadmap refinement** (Stages 0–11, `POST_ROADMAP_PLAN.md`). The Master Development Roadmap is closed as a task queue; its open items are carried (`POST_ROADMAP_PLAN.md` Appendix B) |
| Current Stage | **Stage 5 — Design System Foundation: Not started** (planning is next). Stage 4 closed 2026-09-27: the final, bounded validation passed at `09a7f06` (`STAGE_4_FINAL_VALIDATION.md`) |
| Next Stage | Stage 6 — Core Planner Redesign: Not started |
| Current approved Task | None in progress |
| Next approved Task | None. Next: Stage 5 planning (verify the provisional P5.1–P5.6 against the code; RD-09; freeze the Task sequence). No implementation before that |
| Code baseline | S3.V8 (`92ebf2a`). Not pushed (S1.14) |
| Quality gate at the baseline | **Green at the Stage 4 revalidation**, 2026-09-27, re-run at `5ad69c4` on a clean tree (code unchanged since `92ebf2a`): Encoding, Format (376 files, 0 changed), Analyze, 1214 tests with 1 expected skip, 2 host E2E. Earlier, **green at the Stage 3 final sign-off**, 2026-09-27, re-run at `92ebf2a` on a clean tree: Encoding, Format (376 files, 0 changed), Analyze, 1214 tests with 1 expected skip, 2 host E2E. Earlier, **green after S3.V8**, 2026-09-27: Encoding, Format, Analyze, 1214 tests with 1 expected skip, 2 host E2E. Earlier, **green after S3.V7**, 2026-09-27: Encoding, Format, Analyze, 1208 tests with 1 expected skip, 2 host E2E. Earlier, **green after S3.V6**, 2026-09-27: Encoding, Format, Analyze, 1195 tests with 1 expected skip, 2 host E2E; archived probes P1–P10 pass. Earlier, **green after S3.V5**, 2026-09-27: Encoding, Format, Analyze, 1191 tests with 1 expected skip, 2 host E2E. Earlier, **green after S3.V4**, 2026-09-27: Encoding, Format, Analyze, 1186 tests with 1 expected skip, 2 host E2E; the local real-sample test passes. Earlier, **green after S3.V3**, 2026-09-27: Encoding, Format, Analyze, 1182 tests with 1 expected skip, 2 host E2E. Earlier, **green after S3.V2**, 2026-09-27: Encoding, Format, Analyze, 1177 tests with 1 expected skip, 2 host E2E. Earlier, **green after S3.V1**, 2026-09-26: Encoding, Format, Analyze, 1173 tests with 1 expected skip, 2 host E2E. Earlier, **green after S3.10**, 2026-09-26: Encoding, Format, Analyze, 1169 tests with 1 expected skip, 2 host E2E. Earlier, **green after S3.9**, 2026-09-26: Encoding, Format, Analyze, 1165 tests with 1 expected skip, 2 host E2E. Earlier, **green after S3.7**, 2026-09-26: Encoding, Format, Analyze, 1161 tests with 1 expected skip, 2 host E2E. Earlier, **green after S3.8**, 2026-09-26: Encoding, Format, Analyze, 1159 tests with 1 expected skip, 2 host E2E. Earlier, **green after S3.6**, 2026-09-26: Encoding, Format, Analyze, 1150 tests with 1 expected skip, 2 host E2E. Earlier, **green after S3.5**, 2026-09-26: Encoding, Format, Analyze, 1143 tests with 1 expected skip, 2 host E2E. Earlier, **green after S3.3**, 2026-09-26: Encoding, Format, Analyze, 1130 tests with 1 expected skip, 2 host E2E. Earlier, **green after S3.4**, 2026-09-26: Encoding, Format, Analyze, 1115 tests with 1 expected skip, 2 host E2E. Earlier, **green after S3.2**, 2026-09-26: Encoding, Format, Analyze, Test, E2E (host). The run included another session's uncommitted TD-066 edits (1094 tests); The committed state after both sessions has 1094 + 1 skip. Earlier, **green after S3.1**, 2026-09-26: Encoding, Format, Analyze; 1082 tests with 1 expected local-sample skip; 2 host E2E; the local real-sample test passes (DNG 856/856, JPEG 843, HEIC 4,051 bytes). Earlier: **green**, re-run at `0c4848b` on 2026-09-26 by the Stage 3 planning pass (same result; the local real-sample test also passes). First recorded after S2.V4, 2026-09-26: Encoding; Format (349 files, 0 changed); Analyze (no issues); 1068 tests with 1 expected local-sample skip; 2 host E2E; the local real-sample test passes (DNG 848/848, JPEG 843, HEIC 4,051 bytes); no Kotlin change since the native tests were re-run (4 pass) |
| Schema | **v18** (S3.4) |

## Completed Tasks

**Stage 5 planning (documentation only)**, 2026-09-27, this commit: S5.1–S5.9 frozen, with S5.8
gated on RD-09 (its options prepared). The inputs P5.1–P5.6, UX-16, UX-18, UX-34, UX-38, UX-39 and
08 §5–§8, §14, §20, §22 were re-verified at `38925dd`. Baseline gate PASS. No application or test
change.

**Final, bounded Stage 4 validation (validation and closeout only)**, 2026-09-27, this commit:
**PASS** at `09a7f06`, and Stage 4 is closed. The report is `STAGE_4_FINAL_VALIDATION.md`. No
application, test or design-document change.

**S4.V3 — bounded Stage 4 scope and validation rule**, 2026-09-27, `09a7f06`. Documentation and
governance only, on the owner's instruction:
- S4.V2's inferred rules are withdrawn, and are now S4-DEF-01 to S4-DEF-08;
- the final validation is bounded;
- the rule is recorded in `CLAUDE.md` and plan §9.8.

**S4.V2 — saved plans as immutable references**, 2026-09-27, `b9eed65`. Documentation only,
authorized by the owner's R2 + D1 decision with the saved-snapshot invariant. Resolves S4R-01 to
S4R-04 in the design documents; a fresh revalidation must confirm it. No application or test
changes.

**Stage 4 revalidation after S4.V1 (validation only)**, 2026-09-27, `750f0a7`: **FAIL** at
`5ad69c4`. `STAGE_4_REVALIDATION.md` holds S4R-01 to S4R-04, with S4.V2 proposed. The gate re-ran
green. No application, test or design-document change: only the report and this file.

**S4.V1 — saved-and-edited lifecycle clarification**, 2026-09-27, this correction commit.
Documentation only, authorized by the owner's request to fix S4V-01. ADR-019 §3.1 is normative;
research, architecture, wireframe addendum and future Task acceptance are aligned. No application
or test changes. Independent Stage 4 revalidation remains next.

**2026-09-26 — S2.V1–S2.V3 (this corrective commit):** owner-authorized fixes
for S2V-01/02/03; current-state documentation debt S2V-05 reconciled. See
`STAGE_2_CORRECTIONS.md` for implementation and complete verification results.
No visibility change; S2V-04 gates and device verification limits remain open.

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
| 1 | S1.16 — Commit hashes in the registers (V1) and S1.17 — the field theme in the dialog's accessibility check (V2); V3 recorded under RD-05 | 2026-09-25 | `953c0d1` | Owner: "apply fixes for the remaining items to complete Stage 1". 37 `S1.x` stamps in `ARCHITECTURE.md`, `DATA_MODEL.md`, `FEATURE_STATUS.md` and `SCIENTIFIC_INTEGRITY.md`, TD-047, TD-057 and TD-058 cite their commits; the "Discard unsaved changes?" dialog is checked in the light, dark and field themes (contrast not in field, as in the sweep); V3 added to RD-05 (`POST_ROADMAP_PLAN.md` §8). Gate green, 949 + 2 E2E |
| 1 | S1.V1 — Recognize refusal through the production database connection (TD-059) | 2026-09-25 | `3067658` | `refusedSchemaVersion` unwraps `DriftRemoteException` (its `remoteCause` is the typed refusal on the same-group background isolate); the connection builder is shared (`openDatabaseConnection`). 5 tests through that connection; the refusal tests failed before the fix (the exception escaped). Gate green, 954 + 2 E2E |
| 1 | S1.V2 — Seed the replacement database after a confirmed reset (TD-060) | 2026-09-25 | `b34c9ad` | `confirmDatabaseReset` (refuse newer, forget only the catalog seed marker, keep the old file) replaces the bare rename in `main.dart`. 3 tests through the production connection, with and without the marker, other preferences kept; with the S1.5 behaviour the with-marker test gave 0 targets instead of 164. Stale id-holding preferences after a reset left with TD-056/ENG-14. Gate green, 957 + 2 E2E |
| 1 | S1.V3 — Keep the unsaved-plan safeguard across a restart (TD-061) | 2026-09-25 | `ed628f8` | `CurrentSession` remembers the edited session id through `PlannerStateRepository` (preference `editedSessionId`; no schema change; a site change still not an edit). 5 new tests plus a restart check on the failed-Save test: target-, rig-, night- and block-only edits protected after a restart (target, rig and night failed before), Save clears it, an untouched draft never asks. Cancel's navigation clarified (closes the dialog, stays put). Gate green, 962 + 2 E2E |
| 1 | S1.V4 — Reopening the current session keeps its live plan (TD-062) | 2026-09-25 | `ea65231` | `openSession` returns early for the current, editable session. The validation's probe as a UI test through the detail page, a Save and a restart (20 instead of 7 frames before the fix). A first version also skipped frozen sessions; two existing tests caught it and the guard was narrowed to editable sessions. Gate green, 963 + 2 E2E |
| 1 | Fast re-validation after S1.V1–S1.V4 (same session, owner's request; **not independent**) | 2026-09-26 | `c99bd7f` | At `ea65231`: gate green (963 + 2 E2E), clean tree. Throwaway probes: the reset as `main.dart` runs it with a leftover marker → 164 targets, 1 rig, `.bak` kept; edit → New → restart and edit → Start → restart leave nothing unsaved and the run untouched. One low finding **W1**: a Duplicate of an edited plan counts as saved in-session but unsaved after a restart, so New right after Duplicate replaces the copy without asking (the saved original remains; only the copy's night is lost). Proposed: record under RD-05, like V3. Stage 1 still needs an **independent** validation to close |
| 1 | Repeat independent Stage 1 validation (documentation and probe evidence only) | 2026-09-26 | `39392d9` | Fresh session at `c99bd7f`: gate green (963 + 2 E2E); S1.V1–S1.V4 and S1.16/S1.17 pass their acceptance; no test weakened; no scope drift. **Does not pass:** TD-063 was reproduced through the UI (a detail page loaded before Start reopens the running session as the planner's plan, and every autosave is then refused), and X2 (the registers still say S1.5/S1.6 are broken, and the S1.V stamps cite no commit). W1 confirmed. Proposed S1.V5 and S1.V6. See `STAGE_1_REVALIDATION.md` and `evidence/STAGE_1_REVALIDATION_PROBES.patch` |
| 1–2 | Stage 1 closed by the owner, and Stage 2 planning (documentation only) | 2026-09-26 | `565341b` | The owner said "lets go to stage 2" after the re-validation failed. Recorded as a waiver (DECISIONS E.1): TD-063 moved to Stage 8, X2 and W1 carried. Stage 2: TD-018's mechanisms were re-verified at `39392d9` (all still present); six planning-time findings were placed; S2.R1 is frozen and S2.1–S2.6 are provisional (`POST_ROADMAP_PLAN.md`) |
| 2 | S2.R1 — RG-01: formats, libraries, file selection, fixtures (research, documentation only) | 2026-09-26 | `d4b2be4` | The owner's two phone DNGs (Xiaomi, DNG 1.4, 25 MB each; kept outside the repository) were inspected. All their metadata sits in IFD0 within the first 6.7 KB. They have no GPS and no time offset, and the same Model for both cameras (input for RG-02). The prototype finds 0 of 5 capture fields in them (TD-064). Sources read: `exif` 3.3.0 (MIT; TIFF, JPEG and HEIC; no byte-budget API); `file_picker` 13.1.0 / `android_file_picker` 2.0.0 (copies every file whole into the cache; the extension filter drops unknown MIME types; TD-065); the FITS 4.0 standard (`CONTINUE` is standard, `''` escapes, `DATE-OBS` is UTC at the start); XISF 1.0 (focal length in metres, gain in e⁻/DN); N.I.N.A.'s documented keywords (FOCALLEN is user-entered). Recommended: DNG/TIFF now, FITS on a sample, in-house bounded readers, the `exif` and `image_picker` dependencies removed, no GPS or serials, header-only fixtures with consent, the feature hidden until Stage 3. Proposed ADR-017 |
| 2 | RG-01 decided by the owner; ADR-017; Stage 2 frozen (documentation only) | 2026-09-26 | `96454d8` | The owner approved the direction with constraints. Decided: DNG only, and FITS only with a real sample; bounded reads recognised by signature; the approved contract's fields only; Unknown and provenance kept; no GPS, serials or observer; no inferred zone; the owner's slices never committed (synthetic, sanitized fixtures; the real files stay local); the UI hidden in Stage 2; no Equipment writes; TD-065 is in scope. ADR-017 written (Part F), including the justified removal of `exif` and `image_picker` (both copy or read whole files; each has one use). Verified: `image_picker_android` 0.8.13+23 also copies every pick into the cache, and offers images only. Stage 3 evidence recorded (identical Model across the phone's cameras). S2.1–S2.6 frozen. New blocker: no Android device or emulator can run S2.4's native path |
| 2 | S2.1 — Bounded metadata source and format recognition | 2026-09-26 | `a25398c` | `lib/domain/metadata/`: `MetadataSource`, `BudgetedMetadataSource` (1 MiB per file, 64 KiB per read, a read log, refused reads cost nothing), typed `MetadataReadException`, and `MetadataFormatRecognizer` (TIFF, FITS, XISF and JPEG by signature, ≤ 16 bytes). `lib/data/metadata/file_metadata_source.dart`: positioned, serialized reads, with short reads typed. 17 tests: the budget, limits and ranges, wrapping and short reads; signatures and near misses; a real 4 GiB file recognised and read at both ends with ≤ 64 KiB read; the domain purity check, which fails on a domain `dart:io` import (demonstrated with a temporary file, removed) and allows only the prototype until S2.5. Gate green, 980 + 2 E2E |
| 2 | S2.2 — The metadata contract as typed values with provenance | 2026-09-26 | `b8d626a` | Pure Dart. `MetadataValue<T>`: `KnownValue` (value, raw text, origin with format, tag, location and provenance), `AbsentValue`, `UnparseableValue` and `AmbiguousValue`; `combine` keeps agreeing values and marks conflicts ambiguous. `CaptureMetadata` has the 11 contract fields, all absent by default. `MetadataReading`, with its unreadable reasons. `ExifValues`: exact rationals; the 35 mm equivalent kept separate (0 = absent); sensitivity with its kind (SensitivityType 1–3, otherwise unspecified; 0 and 65535 unparseable); capture time as local wall-clock plus an offset only if recorded, otherwise zone unknown with no instant. CALC-39 and an SI-004 note were added. The tests use synthetic timestamps only. 15 tests. Gate green, 995 + 2 E2E |
| 2 | S2.3 — DNG/TIFF reader, with synthetic fixtures and local real-sample validation | 2026-09-26 | `59c9f03` | `TiffMetadataReader`: IFD0 and the EXIF IFD, contract tags only; the GPS IFD, sub-IFDs, MakerNotes, serials and pixels are never followed. Bounds, entry, repeat and loop checks; one bad value makes only that field unparseable; no DNGVersion → unsupported. `CaptureMetadataReader` recognises, then dispatches; `MetadataFormat.dng` added. Synthetic fixture builder, including a sanitized layout like the phone files. 13 reader tests: phone-style, big-endian, EXIF-IFD with an offset, agreement and ambiguity, GPS and serials never read (read log), non-DNG, other formats, truncated, corrupt, budget, bad single values, every truncation up to 1,200 bytes plus 500 seeded corruptions. **Real samples (local, `ASTROPLAN_METADATA_SAMPLES`):** both owner DNGs gave every expected contract value, reading 848 bytes in 11 reads of about 25 MB each (values kept outside the repository). Gate green, 1008 + 1 skipped (the real-sample test) + 2 E2E |
| 2 | S2.4 — Android document access without a copy; picker cache ownership (TD-065) | 2026-09-26 | `26aff9a` | **Implemented, not accepted (device check pending).** `MetadataDocumentChannel.kt` (registered in `MainActivity`): `ACTION_OPEN_DOCUMENT` with no copy; positioned reads on the provider's descriptor; a sequential fallback within 1 MiB for descriptors that cannot seek; a background thread; no persistable grant. Domain `CaptureFileAccess`/`CaptureFile`; data `AndroidCaptureFileAccess` and `ContentUriMetadataSource` with typed failures. TD-065: `FileBackupService.pick` always clears the picker cache (it is injectable; a failed cleanup is logged). 8 tests (5 channel tests against a host stand-in, 3 cleanup tests). The debug APK builds (the Kotlin compiles). TEST_PLAN gains device rows M1 and M2, not run. Gate green, 1016 + 1 skipped + 2 E2E |
| 2 | S2.5 — The hidden import screen on the foundation; the prototype, `exif` and `image_picker` removed | 2026-09-26 | `a2f42a5` | **Implemented; device check M1 pending (with S2.4).** `MetadataImportViewModel` (domain `CaptureFileAccess` only) → `CaptureMetadataReader`; the screen shows every contract row with its unit and source, and unknown, unreadable or conflicting values as such (`metadata_text.dart`). `main.dart` wires Android only; elsewhere "not available". The prototype extractor, `ImageMetadata` and their 2 tests are removed (plus the purity test's allowance test); `exif` and `image_picker` were removed after a `grep` showed no other use (the lock lost 15 packages, nothing else changed; the desktop registrants lost `file_selector`). The gate stays hidden. Privacy and Data Safety were checked: no change (nothing leaves the device). 11 tests (6 screen tests, including a11y at 200 %; 5 wording tests). The debug APK builds. TD-018 and TD-064 resolved. Gate green, 1024 + 1 skipped + 2 E2E |
| 2 | Review of S2.1–S2.5 against the owner's format priorities (documentation only) | 2026-09-26 | `9f7310d` | The owner's direction: one common typed, provenance-aware contract for many formats; the priorities DNG, JPEG, HEIC/HEIF, FITS on a sample, PNG where meaningful, proprietary RAW through research only (no ad hoc parsers), XISF sample-driven; three distinct levels (recognition, extraction, equipment evidence); no decoders or RAW framework. Review (`STAGE_2_ARCHITECTURE_REVIEW.md`): the contract, values, provenance, bounds, privacy and no-write rules already fit; no defect. Gaps: G1 EXIF parsing fused with the DNG container (header at byte 0, format hardcoded); G2 closed dispatch; G3 recognition and extraction share one result; G4 HEIF, PNG, CR2, CR3, RAF, RW2 and ORF are not recognised; G5 EXIF conversions in the contract file; G6 no generic optics identity (for FITS). Recorded: DECISIONS E.1 and ADR-017 §13 (supersedes the §8 list); RG-14; S2.7, S2.8, S2.R2, S2.R3 frozen; S2.9 and S2.10 conditional; the Stage 2 exit amended |
| 2 | S2.7 — Layered recognition and a reusable EXIF extractor | 2026-09-26 | `9a0432b` | A refactor, closing review gaps G1–G5. `ExifStructure` (IFD0 + the EXIF IFD, the same rules), used on any source; `MetadataSourceWindow` for embedded structures; origins labelled by container; `DngMetadataReader` as a thin container; `MetadataFormatReader` with dispatch by registration; recognition (`reading.format`) kept apart from extraction (the subclass), with `nothingFound`, `recognized` and the format on unreadable readings; recognition-only HEIF, PNG, CR2, CR3, RAF, RW2 and ORF; `ExifValues` moved to `exif_values.dart`. **No DNG behaviour change:** every existing metadata test passes with its assertions unchanged (one import added), the synthetic read log is byte-identical to a baseline captured before the change, and the real samples still read 848 bytes. 10 new tests. Gate green, 1034 + 1 skipped + 2 E2E |
| 2 | S2.R2 — HEIC/HEIF metadata research (documentation only), and the owner's FITS/PNG skip | 2026-09-26 | `5cc23a8` | The owner supplied a phone HEIC and JPEG (outside the repository) and skipped FITS and PNG (DECISIONS E.1): S2.6 and S2.10 leave Stage 2, and both formats stay recognised only. HEIC findings (`research/S2.R2_HEIF_METADATA.md`): `meta` in the first 3.2 KB; the Exif item (linked to the primary by `iref cdsc`) sits at the **end** of the file (97 %), so random access is needed and a non-seekable provider hits the budget (typed); its payload skips a JPEG APP1 header through `exif_tiff_header_offset` = 10; the same EXIF structure as the JPEG, with `OffsetTimeOriginal` +03:00; no GPS, no serials. JPEG: APP1 Exif at byte 2, the metadata within 1.8 KB, SOS at 1.3 %. Stage 3 evidence: Model differs by format for the same phone (DNG `…/2407FPN8EG`, JPEG/HEIC `Xiaomi 14T Pro`); the offset is recorded in JPEG/HEIC, not DNG. Recommended: option A, an in-house box walker → `ExifStructure` (S2.9 defined in §7). Owner decision pending |
| 2 | S2.8 — JPEG reader | 2026-09-26 | `360fd8f` | `JpegMetadataReader`: a bounded marker walk (fill bytes; stops at SOS or EOI; a bad marker, a zero length, a second SOI or more than 128 segments is corrupt) → the APP1 `Exif` segment → the shared `ExifStructure` through a window (origins "APP1 …"); no scan data read; no Exif = "nothing found". Registered in `readers`. Synthetic `jpeg_fixture.dart`; 8 tests (phone-style values with the offset, bounded reads, the GPS IFD never followed, segments before Exif, no Exif, truncated and corrupt, a corrupt EXIF inside APP1, every third truncation plus 500 seeded corruptions). One earlier assertion ("JPEG is unsupported") became a HEIF case, since JPEG now has a reader. **Real sample (local):** the owner's phone JPEG gives every expected value, including a UTC time, reading 843 bytes of 4.7 MB; the DNGs are unchanged (848). Gate green, 1042 + 1 skipped + 2 E2E |
| 2 | Device checks M1 and M2 (S2.4 and S2.5 accepted) | 2026-09-26 | `79f392c` | On the owner's Xiaomi 14T Pro (Android 16, API 36), over USB, at `360fd8f`. A separate debug package (`…astroplanner.s2check`) was used; the gate flip and application id suffix were local and reverted, so the owner's installed app and data were untouched. **M1:** both DNGs and the phone JPEG, picked through the system picker, gave every expected value; the HEIC said "not supported yet"; the app cache stayed empty (4 KB) after every pick; a cancel changed nothing. **M2:** a 25 MB DNG through Restore was refused with its message, and the cache was empty right after; so was a cancelled restore. Not run: the non-seekable (cloud) path, which would need uploading owner files; a real backup's preview cancel. Found: TD-066 (a 1/100 s exposure prints as "0.009987236 s"). Afterwards the test package, the copied DNGs and the UI dump were removed from the phone. An Android device is now available, including for Stage 11's device rows |
| 2 | Independent Stage 2 validation (another session) and S2.V1–S2.V3 corrections | 2026-09-26 | `ffaff57` | Validation at `79f392c` **failed** (`STAGE_2_VALIDATION.md`): S2V-01 (a SHORT/LONG pointer reported as a value), S2V-02 (a short JPEG EXIF reported as nothing found), S2V-03 (non-seekable reads not charged cumulatively), S2V-04 (S2.9/S2.R3 open), S2V-05 (stale docs). The owner authorized S2.V1–S2.V3 (`STAGE_2_CORRECTIONS.md`): strict integer counts, the Exif id checked as soon as it fits, and streaming budgets charged natively (`MetadataSequentialReader`, 4 JVM tests). Gate green, 1052 + 1 skipped + 2 E2E (row added by S2.9, which found it recorded only in prose) |
| 2 | S2.9 — HEIC/HEIF reader | 2026-09-26 | `bb28452` | The owner approved S2.R2 §7 ("You can"). `HeifMetadataReader`: walks the top-level boxes by header only; reads `meta` once (≤ 64 KiB, else overBudget); parses `pitm`, `iinf`/`infe` (v2–3), `iloc` (v0–2; field sizes 0/4/8; construction methods 0 and 1; another file never followed) and `iref cdsc`, each bounded by its box; takes the Exif item linked to the primary item, else the only one, else combines all (conflicts ambiguous); honours `exif_tiff_header_offset` (Xiaomi's APP1 prefix) and hands the rest to the shared `ExifStructure` (origin "Exif item …"); refuses several extents or method 2 as corrupt; an extent or TIFF past its end is truncated, never "nothing found"; no image data is read. Registered in `readers`. Synthetic `heif_fixture.dart`; 10 tests (phone layout with the APP1 prefix, six variants, item choice, no Exif, truncated/corrupt/oversized cases, a truncation sweep proving a cut file never reads complete, 500 seeded corruptions). Two earlier cases that listed HEIF as reader-less now use CR3. **Real sample (local):** the owner's HEIC gives every expected value with its UTC offset, reading 4,051 bytes of 1.9 MB; DNG/JPEG unchanged (848, 848, 843). The device check M3 could not run (the phone disconnected; the local test package changes were reverted unused). Gate green, 1062 + 1 skipped + 2 E2E |
| 2 | Device check M3 (HEIC on the phone) | 2026-09-26 | `237c55f` | At `3a23391`, on the owner's Xiaomi 14T Pro (Android 16), through a separate `.s2check` debug package (local changes reverted before install; package removed afterwards): the HEIC gave every expected value with UTC+03:00; the JPEG, re-read under the S2.V3 channel protocol (`ffaff57`), was unchanged; the cache stayed empty. Observed, not caused by this check: the owner's own `io.github.chacha12.astroplanner` shows lastUpdateTime 2026-09-26 09:24:47 (it was 2026-09-25 16:18 earlier the same day); this session installed only `.s2check` |
| 2 | S2.R3 — RG-14: proprietary RAW compatibility and library research (documentation only) | 2026-09-26 | `e444bfa` | `research/S2.R3_RG14_PROPRIETARY_RAW.md`. Verified: AndroidX `ExifInterface` reads DNG, CR2, NEF, NRW, ARW, RW2, ORF, PEF, SRW and RAF (not CR3), with no documented read bound and its own GPS parsing; LibRaw is a decoder (LGPL-2.1/CDDL-1.0). Documented by reverse engineering: RAF's header points to an embedded JPEG holding the EXIF (libopenraw); CR3 keeps IFD0 and the EXIF IFD as TIFF structures in `moov`/`uuid` CMT1/CMT2, with GPS in CMT4 (lclevy). No proprietary RAW sample exists. Recommended: D (recognised only) to close Stage 2; A (container adapters over the shared extractor, one per format, only with a real sample: RAF, then CR2/NEF/ARW, ORF/RW2, CR3 last) afterwards; reject B (`ExifInterface`: unbounded and unprovable reads, a second path) and C (LibRaw: a decoder). Owner decision pending |
| 2 | RG-14 decided by the owner; Stage 2 ready for validation (documentation only) | 2026-09-26 | `5d8bdbb` | The owner chose the recommendation, when asked which "second scenario" was meant: no proprietary RAW in Stage 2 (D); afterwards, per-format adapters over the shared extractor, each only with a real sample (A, in the order RAF → CR2/NEF/ARW → ORF/RW2 → CR3); `ExifInterface` (B) and LibRaw (C) rejected. Stage 2 closes by the repeat independent validation, not a waiver (the owner's choice). The owner's RAW formats are still unknown. Recorded in DECISIONS E.1, ADR-017's status and the plan's post-Stage-2 list |

| 2 | Repeat independent Stage 2 validation (documentation and probe evidence only) | 2026-09-26 | `f137409` | A fresh session at `5d8bdbb`: the gate is green on the clean tree; the real samples pass (DNG 848/848, JPEG 843, HEIC 4,051 bytes); the native JVM tests were re-run (4 pass). S2V-01 to S2V-04 are resolved, and HEIF inherits the fixes (probes P2–P4). **Fails on S2R-01 (TD-067):** a crafted `iloc` with zero-size fields makes the HEIF reader allocate about 1.7 GB in 9–17 s from an 8 KB `meta`, on the UI isolate (probe P1). Low: S2R-02 (AVIF and sequence brands go to the HEIF reader without a sample, and a sequence-only file reads as "corrupt"), S2R-03 (stale F-45 and `TEST_PLAN.md` text), S2R-04 (HEIF test gaps). No code or test changed; the probes were deleted, and their code is in `evidence/STAGE_2_REVALIDATION_PROBES.md`. See `STAGE_2_REVALIDATION.md` |

| 2 | S2.V4 — Bound the HEIF `iloc` work; AVIF and HEIF sequences recognised only; HEIF test gaps | 2026-09-26 | `d8e792c` | The owner said "Do fix"; S2R-02 was taken as the recommended option (a) (DECISIONS E.1). **TD-067 resolved:** `maxExtents` = 16,384 over all items → `corrupt`. New `MetadataFormat.avif` and `heifSequence`, both recognised only and named in `MetadataText`. There are 6 new HEIF tests: the bound (fails on the old reader), the limit, GPS never read, S2V-01, S2V-02, and the brands. One assertion in `metadata_layers_test.dart` changed because of the ruling (`avif` and `msf1` were HEIF). The real samples are unchanged. Gate green (Encoding; Format (349 files, 0 changed); Analyze (no issues); 1068 tests with 1 expected local-sample skip; 2 host E2E). See `STAGE_2_CORRECTIONS.md` |
| 2 | S2.V5 — Documentation reconciliation (S2R-03) | 2026-09-26 | `435b3ce` | F-45's current-implementation and known-issues text, and `TEST_PLAN.md`'s "no device" note, are corrected with the old text quoted. Also updated: `ARCHITECTURE.md` B, ADR-017's note, E.1, TD-067, `POST_ROADMAP_PLAN.md` (the corrective-Task table) and this file |

| 1 | S1.V6 — Stage 1 registers brought up to date (X2; documentation only) | 2026-09-26 | `3dd2598` | Run at the owner's request ("wrap up the important issues" before Stage 3). The validation banners and notes that called S1.5 broken and S1.6 partial are marked superseded, with the old text kept: `FEATURE_STATUS.md` (banner, F-02, F-40), `ARCHITECTURE.md` (banner, B3, B4), `DATA_MODEL.md` (banner, B8) and `TECH_DEBT.md` (banners). TD-047 is closed again. The S1.V1–S1.V4 stamps (8) and TD-059–TD-062 cite `3067658`, `b34c9ad`, `ed628f8` and `ea65231` (each checked with `git log`). No code changed. TD-063 stays in Stage 8, and W1 stays with RD-05 |

| 2–3 | Stage 2 closed by the owner, and Stage 3 planning (documentation only) | 2026-09-26 | `0c4848b` | Asked to choose between a fresh-session validation and a waiver, the owner chose "Waive and go to Stage 3". Recorded as a waiver (E.1). Stage 3 planning at `3dd2598` verified nine facts (`POST_ROADMAP_PLAN.md`, "Verified at planning"). The key one: `EquipmentProfile` and its columns require sensor size, resolution, pixel pitch, focal length and focal ratio, and the metadata contract has no image dimensions, so an import cannot store a rig without invented values. Frozen: S3.R1 (RG-02), S3.R2 (RG-03), S3.D (decisions, ADR-018). Provisional: S3.1–S3.6 |

| 3 | Stage 3 second planning pass, including S3.R1 (RG-02) (documentation only) | 2026-09-26 | `4c46f8f` | From the owner's Stage 3 planning prompt. Verified the Stage 2 foundation at `0c4848b` (gate green; the local real samples pass; no stale claim, except this file's missing `0c4848b`). `research/RG-02_EQUIPMENT_IDENTITY.md`: field classification, derivability matrix, device classes, matching and conflict outcomes, provenance and confirmation, storage options, decisions D1–D4. A throwaway probe (deleted) found that the pixel dimensions are in all four samples (swapped in the portrait JPEG/HEIC) and that no focal-plane tags exist. Refined sequence S3.1–S3.9, provisional; recommended D1 = A1 (complete before saving, with an estimate offered) |

| 3 | S3.D — owner decisions D1–D4; ADR-018; Stage 3 frozen (documentation only) | 2026-09-26 | `792b295` | The owner chose the recommended option for each decision (asked in this session): **D1 = A1** (the import pre-fills the editor, a rig is saved only when complete, and the CALC-40 sensor/pixel estimate is offered as `estimated`); **D2**: RG-03 deferred (S3.R2 and S3.9 leave Stage 3); **D3**: visible at the end of Stage 3, as "Add from a photo" on the equipment screen (RD-16 resolved); **D4**: a DNG pick's file length as the estimated RAW size. ADR-018 accepted: it amends ADR-017 §2 with image dimensions and applies ADR-008 §6 per field to equipment (schema v18). DECISIONS E.1 "Stage 3 decisions (S3.D)". S3.1–S3.8 frozen |

| 3 | S3.1 — Image geometry in the metadata contract (ADR-018 §3) | 2026-09-26 | `60ec4db` | `CaptureMetadata.imageDimensions` (`ImageDimensions`, with long/short sides; orientation not interpreted). `ExifStructure` reads it: DNG from IFD0's main image only (`NewSubfileType` 0 or absent; `DefaultCropSize` when whole, else `ImageWidth`/`ImageLength`; sub-IFDs never followed); JPEG/HEIC from `PixelX/YDimension` combined with IFD0 (disagreement ambiguous). The hidden screen gains an "Image size" row. 14 new tests (`image_dimensions_test.dart`: the DNG rules, crop types, fallbacks, malformed values, a preview IFD0, the JPEG/HEIC rules, wrong-IFD tags, and GPS never read; `metadata_text_test.dart`: the row, and the row count now follows the contract, 11 → 12). **Local real samples:** the DNG crop sizes (checked against an independent Python walk, deleted), and the JPEG/HEIC portrait sizes, were added to `expected.json` outside Git and pass. Each DNG reads 856 bytes (+8). CALC-39, F-45, ARCHITECTURE B, ADR-017/018 status updated. Gate green, 1082 + 1 skip + 2 E2E |

| 3 | S3.2 — Equipment evidence and candidate, with CALC-40 (ADR-018 §4) | 2026-09-26 | **`7560df2`** (the content) and `e9a9d87` (empty) | **Where it landed:** the concurrent TD-066 session committed the shared index while S3.2's files were staged, so S3.2's code, tests and docs are in `7560df2` ("fix: format short exposures as shutter fractions"). `e9a9d87` carries the S3.2 message with no changes. No history was rewritten; the content was checked to be complete in HEAD. Pure domain code in `lib/domain/equipment_import/`, with no UI and no write. `EquipmentCandidate.fromReading`: per field, `ProposedField` (value, source `metadata:<format>` or `derived:calc-40/metadata:<format>`, `reported`/`estimated`, origins) or `UnknownField` (not in file, unreadable, conflicting, out of range, not estimable, never from metadata). Labels come from Make/Model; resolution uses the long side as the width; the aperture diameter, rotation, tracking and maximum exposure are never proposed; the RAW size waits for S3.8. It also carries a suggested name, `EquipmentEvidence` for S3.3, and `hasEnoughEvidence`. `SensorGeometryEstimate` is CALC-40, registered in `SCIENTIFIC_INTEGRITY.md`. As the ADR requires, there is no estimate when f₃₅ ≤ f, so full-frame bodies get none. 11 tests, with expected values computed independently. **Concurrent work noticed:** another session committed `23b962c` (the owner's debug-build metadata viewer) during this Task, and left TD-066 edits uncommitted; S3.2 commits only its own changes. Gate green |

| 3 | S3.4 — Per-field provenance and identity evidence, schema v18 (ADR-018 §5) | 2026-09-26 | `1af68e4` | 14 additive nullable columns: source/confidence pairs for resolution, pixel pitch, sensor size and RAW size, plus `metadata_make` and `metadata_model`, on `camera_modules`; pairs for focal length and focal ratio on `optical_rigs`. Nothing is back-filled. The Drift workflow was followed (v18 snapshot, generated verification and steps; `from17To18` against the step's shapes). Domain: `EquipmentSpec` and `SpecProvenance`; `EquipmentProfile.specProvenance`, `metadataMake/Model` and `provenanceOf` (own pair → group → unknown); `withEditProvenance` per field, which pins the group's old provenance on untouched specs when their group changes (a verified value stays verified), keeps given pairs, and keeps the identity. The repository maps the new columns. The manual editor is unchanged (its tests are not modified). 21 new tests: every version v8–v17 → v18 against the snapshot; v17 → v18 keeps values and group provenance with no own pairs; a legacy rig stays unknown; 8 domain rules; a repository round-trip through a manual edit. **Four existing tests changed** only because they hardcoded the current schema: the backup header now expects 18, and the "newer than the app" example is 19. Session snapshots keep only group provenance. Gate green, 1115 + 1 skip + 2 E2E |

| 3 | S3.3 — Matching saved rigs, with conflicts (ADR-018 §6) | 2026-09-26 | `0e5b93e` | `EquipmentMatcher` is pure domain code with no write. It gives six outcomes (`MatchKind`) with `MatchReason`s, per-field `FieldConflict`s (both provenances; `savedIsVerified`) and `fillable` unknown specs. The stored import identity wins over the labels; comparison is normalised; the prefix rule uses `/`, space, `-` and `_`; f and N use a 1 % tolerance. The capture mode differs when the pixel count differs, or when the file's f₃₅ is more than 10 % from the one the rig implies (f × 43.27 ÷ the sensor diagonal; recorded as an S3.3 implementation choice in ADR-018's note, with the "Pro Max" prefix limit and the no-model rule). 15 tests, one per scenario: none; same; likely (DNG vs JPEG); normalised labels; the stored identity over renamed labels; makes; two identical bodies (ambiguous); the other phone module; a telescope body; digital zoom; a full-resolution mode; the tolerance; verified vs legacy conflicts; the seeded camera. Gate green, 1130 + 1 skip + 2 E2E |

| 3 | S3.5 — A form model for the rig editor, and pre-fill | 2026-09-26 | `9675854` | The editor's value building moved into the pure `EquipmentDraft` (`presentation/shared/equipment_draft.dart`): `fromProfile` (Add/Edit, as before), `fromCandidate` (file values, the CALC-40 estimate, or a saved rig's camera specs as `cameraFrom`), and `build` (the Save logic, moved unchanged, plus per-field provenance: a pre-filled value keeps its origin only while its text is untouched). The dialog moved from the 791-line screen into `showEquipmentEditor` (`equipment_editor.dart`, 578 lines; the screen is now 218). It shows a note under each pre-filled field; D, tracking, rotation and maximum exposure are never pre-filled. The 10 existing editor tests pass unmodified. 13 new tests: 8 form-model tests and 5 widget tests (notes shown and cleared; saved untouched keeps its origin and identity; edited pixel size and derived sensor become the user's; Cancel writes nothing; missing values block Save). `phoneCandidate` in `test/support/metadata_candidates.dart`. No entry point yet (S3.6/S3.7). Gate green, 1143 + 1 skip + 2 E2E |

| 3 | S3.6 — The import review and confirmation flow (ADR-018 §2, §6) | 2026-09-26 | `f230e6b` | `MetadataImportViewModel` now takes the `EquipmentRepository`: after a read it builds the candidate, matches it, keeps the per-field "use the file's value" choices (off by default), and gives drafts (`newRigDraft(cameraFrom:)`, `rigDraft` via the new `EquipmentDraft.forRig`). The screen gains an Equipment card above the file's values: the outcome in plain words, the reasons, conflict switches, Open / New rig / New rig with a saved rig's camera specs. Every action goes through `showEquipmentEditor`, whose Save is the only write; the match refreshes after a save, and the planner rereads an edited rig. Wording is in `equipment_import_text.dart`. Fix: an untouched sensor field now compares with the rig's stored value, not the draft's first text (needed once a file value is taken). 7 review tests (a new rig only through Save, then matched; Cancel writes nothing; same rig keeps verified values by default and creates no duplicate; a taken value arrives with its origin; another module takes the saved camera; ambiguous; no evidence proposes nothing). The accessibility sweep now includes the review, with a file matching the seeded rig (light, dark, field; 100/200 %). `InMemoryEquipmentRepository` and `PlannerHarness(captureFiles:)` are in `test/support`. Still debug-only (S3.7). The owner's phone was connected but was not needed; nothing was installed. Gate green, 1150 + 1 skip + 2 E2E |

| 3 | S3.8 — Average RAW size from a DNG pick (ADR-018 §4, D4; C-13) | 2026-09-26 | `d21a326` | `EquipmentCandidate.fromReading(read, fileLengthBytes:)`; the ViewModel passes `MetadataSource.length` (the file is still never read whole). Only for a DNG: bytes ÷ 10⁶ = MB, `estimated`, source `metadata:dng:file-size`, `EquipmentLimits.rawFileSizeMB` bounds (outside is unknown, out of range). `rigDraft` pre-fills it on a matched rig that lacks one; the review says "Average RAW file size is unknown on this rig; the file suggests …". A saved value is only an ordinary conflict, kept by default. The editor note reads "Estimated from this one file's size (DNG)". 9 tests: DNG / JPEG / HEIC / no length / out of range; matcher fillable vs conflict; draft note; review fill-through-Save, keep-by-default, JPEG never. Gate green, 1159 + 1 skip + 2 E2E |

| 3 | S3.7 — Visibility, TD-066, the device check M4 (ADR-018 §7; RD-16) | 2026-09-26 | `2b045eb` | `FeatureScope.metadataImport` = true. `AppRouter.metadata` is the root route `/equipment/import` (was `/settings/metadata`, debug-only), and the Settings entry is removed. "Add from a photo" is a small button above "Add rig" on the equipment screen; the list and the planner's rig reload on return. The screen is retitled "Add from a photo", and its intro says nothing is saved until Save. Privacy policy and Data Safety notes gained a paragraph (nothing leaves the device; still "not collected"). TD-066 verified (host tests, and "≈1/50 s" on the device). Tests: a navigation test; Settings has no entry; the gate/route tests updated to the new route; 7 editor tests now tap "Add rig" by tooltip, since there are two buttons. **Device check M4 passed** on the owner's Xiaomi 14T Pro through a separate `.s2check` package (local build change reverted; uninstalled afterwards; the owner's app untouched, its install times 20:00/20:28 predate the check): a real DNG went through match → pre-filled editor (source notes, RAW size from one file, no D or tracking) → Save → "You already have this rig" → listed; the cache stayed 4 KB. **Found:** TD-068 (rounding conflicts on re-read; S3.9 proposed) and TD-069 (clipped sensor fields; Stage 5/7). Gate green, 1161 + 1 skip + 2 E2E |

| 3 | S3.9 — No rounding conflicts on re-reading an imported file (TD-068) | 2026-09-26 | `3f54432` | Owner: "fix the existing issues…" (E.1, "Stage 3 fixes before validation"). The candidate proposes estimates at the editor's stored precision, with one set of constants for both (`EquipmentCandidate.sensorDecimals`/`pixelPitchDecimals`/`rawSizeDecimals`: 0.01 mm, 0.001 µm, 0.1 MB); plausibility is checked before rounding (a 0.05 MB file stays out of range — caught by the existing test when a first version rounded first). Regression tests (`equipment_import_round_trip_test.dart`): a rig saved from a file through the real form model matches it with no differences (the M4 main DNG, the telephoto, a portrait JPEG), and a user-typed value is still a difference. All four failed before the fix. Five expectations updated to the rounded proposals (the unrounded CALC-40 values stay tested in the estimator's group). CALC-40 row noted; TD-068 resolved. Gate green, 1165 + 1 skip + 2 E2E |

| 3 | S3.10 — The editor readable on a phone (TD-069) | 2026-09-26 | `387e54b` | Owner-approved (E.1, "Stage 3 fixes before validation"). `equipment_editor_fit_test.dart` reproduces the device on a 375 dp view with Roboto loaded (the test font draws a full em per character): at 100 %, "9.89" needed 36 dp in an 18 dp box, exactly as on the phone. Fix: each W × H row's label moved above its fields. The same test at 130 % found the Tracking dropdown overflowing (present before Stage 3): now `isExpanded`. 4 tests (two drafts × 100/130 %); all failed before. Existing editor tests unchanged. Gate green, 1169 + 1 skip + 2 E2E |

| 3 | Independent Stage 3 validation (FAIL) | 2026-09-26 | `7f790df` | Committed as written by the owner's validation: S3V-01–S3V-06 blocking, S3V-07 non-blocking, S3V-08 unverified. Before committing, this session re-ran the archived probes at `387e54b`: 7 failures (P1–P5, P7, P8) and P6 passing, as reported |
| 3 | S3.V1 — A stale review never reverts newer rig edits (S3V-01) | 2026-09-26 | `62a79af` | Owner-approved (E.1, "Stage 3 validation failed: corrective Tasks"). The review is re-matched against the saved rigs when shown (post-frame) and right before Open or "New rig with the camera specs" (`currentMatchFor`). A "use the file's value" choice stores the saved value it was made against and is withdrawn if that value changed or the rig is gone; a deleted or no-longer-matching rig is not opened (a snackbar says so). 4 regression tests through real routes, real screens and SQLite (`metadata_import_stale_review_test.dart`): the validation's P8 sequence, a change while the review stays open, a withdrawn choice (then a fresh explicit choice does replace), and a deleted rig. All 4 failed before the fix. Gate green, 1173 + 1 skip + 2 E2E |

| 3 | S3.V2 — Untouched legacy values keep unknown provenance (S3V-02) | 2026-09-27 | `edbb2a7` | `SpecProvenance.unknown` (own pair, source `unknown`, no confidence) reads as unknown before any group fallback. It is pinned on untouched fields of an edited group whose old provenance was unknown, and kept for values copied from a legacy rig (it was dropped before, so the new rig's `user` group covered it). No schema change; ADR-018 implementation note. Regression tests through the real Drift repository with rereads (`equipment_provenance_persistence_test.dart`): the validation's P2 (edit one legacy field) and P1 (copy legacy camera specs) failed before the fix; a copied value then edited becomes the user's; a rig typed by hand stays wholly the user's (control). One existing test, which the validation named as encoding the defect (`equipment_provenance_test.dart`, untouched legacy field read as `user`), was corrected to the contract with a note. Gate green, 1177 + 1 skip + 2 E2E |

| 3 | S3.V3 — Numeric fidelity (S3V-03, S3V-04) | 2026-09-27 | `18873ad` | `PrefilledSpec.values` carries the exact numbers behind pre-filled texts; `EquipmentDraft.build` saves them while the texts are unchanged (before the stored-sensor rule and before parsing). Copied pixel and RAW sizes display unrounded; the sensor display stays at 2 decimals (display-only). Regression tests through the real Drift repository with rereads (`equipment_numeric_fidelity_test.dart`): the validation's P3 (a chosen file sensor size applies the file's value, and the difference disappears) and P4 (copied 9.894 mm, 2.414123 µm and 30.04 MB stay exact and verified) failed before the fix, with a copied-then-retyped case; controls: estimates stay rounded, and an untouched open-and-save of a saved rig stays exact. No existing test changed. Gate green, 1182 + 1 skip + 2 E2E |

| 3 | S3.V4 — Absurd image dimensions are unparseable (S3V-05) | 2026-09-27 | `2447962` | `ExifValues.dimensions` rejects a side over `maxImageSidePx` = 65,535 (JPEG's format limit; a metadata sanity bound, deliberately wider than `EquipmentLimits.resolutionPx`); the shared conversion covers DNG IFD0 and DefaultCropSize, JPEG and HEIC. 4 regression tests in `image_dimensions_test.dart`: the validation's P7 (4,294,967,295 × 4,294,967,295 JPEG EXIF), a DNG width and crop over the bound, a HEIC side over it, and the boundary (65,535 known, 65,536 not); all failed before the fix. CALC-39 and an ADR-018 note updated. The local real samples still give their expected dimensions. Gate green, 1186 + 1 skip + 2 E2E |

| 3 | S3.V5 — Real-database review coverage and stale wording (S3V-06, S3V-07) | 2026-09-27 | `51f53cf` | `metadata_import_review_db_test.dart` runs S3.6's acceptance through the real screens and routes with a real in-memory SQLite database (only the file picker is fake), counting rows in `devices`, `camera_modules` and `optical_rigs`. The cases: Cancel at every step writes nothing (picker, leaving the review, Cancel in each editor); a new rig is written once, only by Save, then matched, with no duplicate on Open and Save; a difference is kept by default, a verified value survives, and only an explicit choice replaces it; another module adds a rig with the saved camera specs; navigation and re-entry. These are acceptance tests for behaviour already fixed by S3.V1–S3.V3 (S3V-06 was a coverage gap), so they pass; nothing to reproduce first. The list-fake tests are kept. S3V-07: the debug-only visibility wording in ADR-018 §7, the two `PROGRESS.md` amendments and F-45's "current visibility" bullet are marked superseded by S3.7, with their text kept verbatim. **Archived probes re-run (`evidence/STAGE_3_VALIDATION_PROBES.md`, recreated then deleted): P1–P4 and P6–P10 pass; P5 still fails (45 → 30.04 MB).** P5 calls `vm.rigDraft(vm.match!.rigs.single)` on a match kept from before an external edit, with no refresh. S3.V1 closed the screen paths (refresh on entry and before Open; P8 passes) but not this ViewModel API. Recorded; not fixed here (outside S3.V5's scope). Gate green, 1191 + 1 skip + 2 E2E |

| 3 | S3.V6 — No stale drafts from the import ViewModel (S3V-01, ViewModel level) | 2026-09-27 | `d5e2b60` | Owner-approved after S3.V5's probe re-run found P5 failing. `rigDraft(rigId)` and `newRigDraftWithCameraOf(rigId)` are async and read the saved rigs again before building a draft (the match lookup is now private); they return null for a rig deleted or no longer matching. The synchronous `rigDraft(RigMatch)` and `newRigDraft(cameraFrom:)` are gone, so no caller can build from a stale match. The screen calls the new methods. `metadata_import_viewmodel_stale_test.dart` (real Drift): P5 restated against the new API, a fresh camera copy, a withdrawn choice, a deleted rig; it could not compile against the old API, and the archived P5 failed on it. **All archived probes re-run: P1–P10 pass** (P5 with its one call restated; the evidence file unchanged). Gate green, 1195 + 1 skip + 2 E2E |

| 3 | S3.V7 — Per-field provenance in the rig editor; no invented `user` in new snapshots (S3S-01, TD-070) | 2026-09-27 | `1166986` | Owner-approved with a Stage-boundary adjustment (E.1). `EquipmentProfile.groupProvenance` lists a group's valued specs with `provenanceOf` (the RAW size only when set); `sharedProvenance` is the one they all have, else null. The editor's provenance line (keyed `editor.provenance`) gives one phrase for a group that shares a provenance, else one per spec; it never shows the group pair alone. `SessionSnapshotBuilder` writes a group's source/confidence only when shared, else null (snapshot `"v": 1` and export unchanged). Regression tests first (they failed before the fix): `equipment_shared_provenance_test.dart` (6), `equipment_editor_provenance_test.dart` (4: imported, hand-typed unchanged, edited verified seed, edited legacy), and 3 snapshot cases in `session_snapshot_builder_test.dart`. Existing tests unchanged. Deferred to Stage 8: per-field snapshot provenance and snapshots already saved. Gate green, 1208 + 1 skip + 2 E2E |

| 3 | S3.V8 — No camera-spec copy across pixel counts (S3S-02, TD-071, SI-014) | 2026-09-27 | `92ebf2a`* | Owner-approved, option (a) (E.1). `EquipmentDraft.fromCandidate(c, cameraFrom:)` does not copy the saved rig's pixel size or sensor size when the file's pixel dimensions are known and differ from its resolution (`EquipmentMatcher.samePixelCount`, orientation-free, also used by the mode check). It records them in `withheldFromSavedRig`, and the editor shows `PrefillText.withheld` (keyed `editor.withheld`) while the pixel field is empty. Resolution and RAW size fallbacks, the file's own values and estimates, and the equal-count copy are unchanged. Regression tests first (they failed before the fix, the real-database one with the saved 1.25 µm copied): `equipment_camera_copy_mode_test.dart` (5), and one real-database case in `metadata_import_review_db_test.dart` (Save waits for the user's pixel size; then one new chain; the saved rig unchanged). `phoneCandidate` in `test/support` gained `dims` and `focalLengthMm` parameters (defaults unchanged). Existing tests unchanged. Gate green, 1214 + 1 skip + 2 E2E |

| 3 | Stage 3 final sign-off, fresh session (validation and closeout documentation only) | 2026-09-27 | `126d97f`\*\* | **PASS** at `92ebf2a`; Stage 3 closed. Gate green (1214 + 1 skip + 2 E2E); targeted Stage 3 suites 352 + 1 skip; real samples, 4 native JVM tests; archived probes re-run (F1b and F3 now fail, as their defects are fixed); 13 new probes. S3S-01 and S3S-02 resolved; S3F-01 (TD-072 addendum) and S3F-02 (TD-071 note) non-blocking; S3V-08 unverified. See `STAGE_3_FINAL_SIGNOFF.md` |

| 4 | Stage 4 planning (documentation only) | 2026-09-27 | `2a26185` | Every Stage 4 input re-verified at `126d97f` (none stale). Frozen: S4.R1–S4.R5, S4.D, S4.T; S4.E optional. Owner: the recommended option on each planning question (E.1, "Stage 3 closed; Stage 4 planning decisions"). `POST_ROADMAP_PLAN.md`, "Stage 4 — frozen Task sequence" |

| 4 | S4.R1 — Flow inventory and question matrix (research, documentation only) | 2026-09-27 | `e5fd240` | `research/S4.R1_FLOW_INVENTORY.md` at `2a26185`: routes against the wireframes, every session action, states per screen, 16 re-measured tap counts, a 22 + 18 row question matrix, owner clarifications O1–O4, the S4.E script. Key RG-04 input: a result can be recorded only through Start |

| 4 | S4.R2 — RG-04 research: Execution's role and post-session results (documentation only) | 2026-09-27 | `97ffab5` | `research/RG-04_EXECUTION_ROLE.md` at `e5fd240`: evidence kept apart; capabilities C1–C12; G1–G3 × A–D; recommended B + G2; D1–D4 for the owner. S4.R1 §6.1 records the owner's O1–O4 answers |

| 4 | RG-04 decided (the owner's D1–D4; documentation only) | 2026-09-27 | `abca03d` | D1 = B, D2 = G2, D3 and D4 as recommended (E.1, "RG-04 decided"). Recorded in the research's §12, `PRODUCT_DIRECTION.md` §4 and the RG register. ADR changes are left to S4.D |

| 4 | S4.R3 — Session lifecycle research (documentation only) | 2026-09-27 | `989a61e` | `research/S4.R3_SESSION_LIFECYCLE.md`: verified lifecycle, the roll-forward conflict with RG-04, options L0–L2, n1–n3, U1–U2, Y1–Y3, the defaults; low-fi flows |

| 4 | RD-05 and RD-04 decided (the owner's E1–E4; documentation only) | 2026-09-27 | `8600a39` | L1, Y2, no preselection with an empty plan and "Start from the example plan", U1 (E.1). Recorded in the research's §11, `PRODUCT_DIRECTION.md` §10 and the RD register |

| 4 | S4.R4 — Tonight and planner research (documentation only) | 2026-09-27 | `8578ab8` | `research/RG-05_06_TONIGHT_AND_PLANNER.md`: current structure, measurements, binding rules, a visible vs one-tap-away rule, options T1–T2, D-a–D-c, P-0–P-2, M0–M2, low-fi wireframes |

| 4 | RG-05, RD-06 and RG-06 decided (the owner's F1–F4; documentation only) | 2026-09-27 | `0506b04` | T1, D-b, P-1 (amends ADR-015 §2), M0 (ADR-009 §2's "own line" within the budget details); no modes (E.1). Recorded in the research's §11, `PRODUCT_DIRECTION.md` §10 and the registers |

| 4 | S4.R5 — Library and vocabulary research (documentation only) | 2026-09-27 | `160ee37` | `research/S4.R5_LIBRARY_AND_VOCABULARY.md`: the Library's current behaviour (TD-053), a string inventory, options LB1–LB3 and PR1–PR2, naming principles, a glossary |

| 4 | RD-07 and RD-14 decided (the owner's H1–H4; documentation only) | 2026-09-27 | `28857d8` | LB1 + PR2; Rig; Plan + Logbook; the glossary as proposed (E.1). Recorded in the research's §9, `PRODUCT_DIRECTION.md` §10 and the RD register. Every Stage 4 gate is decided |

| 4 | S4.D — ADR-019 and the wireframe addendum (decision record, documentation only) | 2026-09-27 | `f68e576` | ADR-019 accepted by the owner; it amends ADR-009 §2 (display), ADR-014 §3, ADR-015 §2/route map/§7, ADR-016. `docs/IA_WIREFRAMES_ADDENDUM.md`; DEV-P9 (UX-04, UX-11); ARCHITECTURE D5; S4.R1 §9 answers |

| 4 | S4.T — the decisions as provisional Tasks for Stages 5–9 (planning, documentation only) | 2026-09-27 | `adb5d95`\*\*\* | P5.1–P5.6, P6.0–P6.7, P8.1–P8.6 and P9.1–P9.2 (not frozen), with the order across Stages; §6.2 rows updated. Every Stage 4 Task is done |

\* A file cannot contain its own commit hash; S3.V8's (`92ebf2a`) was recorded by the Stage 3
final sign-off.
\*\* Likewise for the sign-off (`126d97f`), recorded by Stage 4 planning.
\*\*\* Likewise for S4.T (`adb5d95`), recorded by the Stage 4 revalidation.

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
- `db94aaf`: independent Stage 1 validation.
- `953c0d1`: S1.16 and S1.17.
- `3067658`, `b34c9ad`, `ed628f8`, `ea65231`: S1.V1–S1.V4.
- `c99bd7f`: the same-session re-check.
- `39392d9`: the repeat independent Stage 1 validation.
- The Stage 1 closure and Stage 2 planning: see the note under "Completed Tasks".

## Validation status

- **Stage 5 baseline**, 2026-09-27, at `38925dd`: the quality gate **PASS** (Encoding; Format,
  376 files, 0 changed; Analyze; 1,214 tests, 1 expected skip; 2 host E2E). The Stage 5 validation
  (fresh session, implementation model) comes after S5.9.
- **Final, bounded Stage 4 validation**, 2026-09-27, at `09a7f06`: **PASS**
  (`STAGE_4_FINAL_VALIDATION.md`). Stage 4 is closed.
  - The seven owner-frozen questions all pass.
  - Nothing blocks: the S4-DEF items are deferred, and S4V-02, S4V-03 and one observation are
    recorded.
  - Run in the authoring session at the owner's request (disclosed).
  - The code is unchanged since `92ebf2a`, and the gate at `5ad69c4` applies.

- **S4.V3 task self-review**, 2026-09-27. Documentation and governance only.
  - Searched the current documents (DECISIONS, ARCHITECTURE, the addendum, the plan,
    PRODUCT_DIRECTION, TECH_DEBT, the research notes) for S4.V2's inferred rules. They remain only
    in S4.V2's matrix, which is labelled superseded and non-normative. ADR-007's own solar-noon text
    is unrelated.
  - `git diff --check` passed. The code is unchanged, so the gate at `5ad69c4` still applies.
  - This is not a Stage validation.

- **S4.V2 task self-review**, 2026-09-27. Documentation only.
  - Every current document that stated S4.V1's Review → Save → result guard or its Stage 6/8 split
    was rewritten or marked superseded (searched: DECISIONS, ARCHITECTURE, the addendum, the plan,
    PRODUCT_DIRECTION, TECH_DEBT and the research notes).
  - The S4.V1 matrix and E.1 entry are kept, labelled superseded.
  - `git diff --check` passed.
  - The code is unchanged, so the gate at `5ad69c4` (1,214 tests, 1 skip, 2 host E2E) still
    applies.
  - This is not independent Stage revalidation.

- **Stage 4 revalidation (fresh session)**, 2026-09-27, at `5ad69c4`: **FAIL**
  (`STAGE_4_REVALIDATION.md`).
  - **Resolved:** S4V-01, as reported. The claims were checked against the code:
    - `updatePlan` keeps `plannedAtUtc` and the snapshot;
    - the snapshot stores the night's bounds, zone and blocks;
    - Save needs a site;
    - a night ends at the next mean solar noon.
  - **Blocking:**
    - S4R-01: a result for Saved · changed follows the re-saved working night or site;
    - S4R-02: the Stage 6/8 delivery split resumes last night's plan as current, against E2 and
      E.1.
  - **Low:** S4R-03 (TD-057's direction), S4R-04 (§3.1 has no acceptance record).
  - **Carried:** S4V-02 (now also Test A); S4V-03 unverified.
  - **Gate: PASS**, exit 0 (Encoding; Format, 376 files, 0 changed; Analyze; 1,214 tests, 1
    expected skip; 2 host E2E).
  - No probe; no code, test or design document changed.

- **S4.V1 task self-review**, 2026-09-27: the ten-case specification matrix covers saved states,
  startup/live rollover, snapshot/working-date differences, explicit review, result cancellation,
  stale edits and storage failure. Only documentation changed. Encoding and `git diff --check`
  **passed**. The existing-code full gate passed at `adb5d95` (1,214 tests,
  1 expected skip, 2 host E2E); no code changed since, so it is not rerun for this correction.
  This is not independent Stage revalidation.

- **Stage 4 independent validation**, 2026-09-27, at `adb5d95`: **FAIL**
  (`STAGE_4_VALIDATION.md`). One blocking specification gap (S4V-01); one optional-script issue
  (S4V-02); human/device usability unverified (S4V-03). No production changes since `92ebf2a`.
  - Full gate re-run: **PASS**, exit 0; Encoding; Format (376 files, 0 changed); Analyze (no
    issues); **1,214 tests, 1 expected local-sample skip; 2 host E2E**. Passing existing-code
    tests does not resolve the future lifecycle specification gap.

- **Stage 4 planning**, 2026-09-27, at `126d97f`: documentation only; every Stage 4 input
  re-verified against the code (none stale). No code changed, so the gate result at `92ebf2a`
  still applies.

- **Stage 3 final sign-off (fresh session)**, 2026-09-27, at `92ebf2a`: **PASS**
  (`STAGE_3_FINAL_SIGNOFF.md`). Stage 3 closed.
  - Passed: the gate (Encoding; Format, 376 files, 0 changed; Analyze; 1,214 tests, 1 expected
    skip; 2 host E2E); the targeted Stage 3 suites (352, 1 skip); the real samples; the 4 native
    JVM tests; every archived probe that asserts required behaviour; 13 new probes.
  - Resolved: S3V-01 to S3V-07, S3S-01, S3S-02.
  - Non-blocking: S3F-01, S3F-02; S3S-03 deferred.
  - Unverified: S3V-08 (device). Nothing is claimed as device verified.
  - Validation only: no application, test or dependency change; the probe files were removed.

- **Fresh-session Stage 3 sign-off**, 2026-09-27, at `74026ca`: **FAIL**
  (`STAGE_3_SIGNOFF_VALIDATION.md`).
  - Passed: the gate (Encoding; Format; Analyze; 1,195 tests, 1 expected skip; 2 host E2E); the
    real samples; the 4 native JVM tests; two positive probes.
  - Failed: S3S-01 and S3S-02 (blocking).
  - Low: S3S-03.
  - Validation only: no application, test or dependency change; the probe file was removed.

- **Stage 3 second planning pass**, 2026-09-26, at `0c4848b`: documentation only; the gate re-run
  green (Encoding; Format; Analyze; 1068 tests, 1 expected skip; 2 host E2E), and the local
  real-sample test passes (DNG 848/848, JPEG 843, HEIC 4,051 bytes).

- **Stage 2 closure**, 2026-09-26: by owner waiver after S2.V4/S2.V5, not by an independent
  pass (E.1). **Stage 3 planning**: documentation only, and the gate result at `d8e792c` still
  applies (no code changed since).

- **S2.V4/S2.V5 implementation verification**, 2026-09-26: Encoding; Format (349 files, 0 changed); Analyze (no issues); 1068 tests with 1 expected local-sample skip; 2 host E2E. The targeted metadata
  suites give 98 passed and 1 expected skip; the new bound tests fail on the old reader; the
  real samples are unchanged. This is self-verification, not independent Stage acceptance.

- **Repeat independent Stage 2 validation**, 2026-09-26, at `5d8bdbb`: **FAIL**
  (`STAGE_2_REVALIDATION.md`).
  - Passed:
    - the gate is green on the clean tree (Encoding; Format, 349 files, 0 changed; Analyze; 1062 tests, 1 expected local-sample skip; 2 host E2E);
    - the local real-sample test passes;
    - the 4 native JVM tests pass, re-run;
    - no test was weakened since `79f392c`.
  - Failed: S2R-01 (blocking, TD-067).
  - Low: S2R-02 (needs an owner ruling), S2R-03 and S2R-04.
  - No application, test or dependency change.

- **S2.V1–S2.V3 implementation verification**, 2026-09-26: full gate green
  (1052 tests, 1 expected skip, 2 host E2E); 4 native JVM tests pass; all three
  external samples pass unchanged; the two original failing semantic probes
  now pass. This supersedes the code failures below, not the independent Stage
  verdict or its unfinished research/decision gates.

- **Stage 2 independent validation**, 2026-09-26, at `79f392c`: **FAIL**.
  See `STAGE_2_VALIDATION.md` and `evidence/STAGE_2_VALIDATION_PROBES.md`.
  The full gate passes (1042 tests, 1 expected skip, 2 host E2E); the external
  real-sample test also passes (two DNGs and one JPEG). Two additional
  malformed-input acceptance probes fail (S2V-01 and S2V-02). S2V-03 records
  the non-seekable accounting/test gap; S2V-04 records the still-open S2.9
  disposition and S2.R3 gate. S2V-05 through S2V-08 distinguish documentation
  debt, unverified device paths, existing display debt and rejected concerns.
  No implementation or existing tests changed. The Stage remains in progress;
  proposed corrective Tasks in the report do not constitute owner approval.

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
- **Stage 1 closure**, 2026-09-26: by owner decision after a failed validation (a waiver,
  not a pass; DECISIONS E.1).
- **S2.R1**, 2026-09-26: research only. Throwaway probes (scratchpad Python, and
  `tool/zz_probe_*.dart`) were deleted; no code, test or dependency changed. The gate result
  at `c99bd7f` still applies.
- **Stage 2 planning**, 2026-09-26, at `39392d9`: documentation only; TD-018 re-verified. The
  gate result at `c99bd7f` still applies (no code changed since).
- **Repeat independent Stage 1 validation**, 2026-09-26, against `c99bd7f`: **does not pass**.
  - The gate is green (963 tests, 2 E2E).
  - The first validation's six probes are regression tests now, and they pass.
  - S1.V1–S1.V4, S1.16 and S1.17 meet their acceptance.
  - Surviving: TD-063 (P2; a reopen from a detail page loaded before Start) and X2 (the
    registers were not updated after S1.V1–S1.V4). Low: W1, confirmed (for RD-05).
  - No application or test source was changed. The probes are kept as a patch, which was
    applied, ran (1 failure, 2 observations) and was reversed.
  - Details: `STAGE_1_REVALIDATION.md`.
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

## Superseded "Next allowed action" entries (newest first)

*Superseded by the Stage 5 planning (kept as written):*

**Stage 5 — Design System Foundation: Stage planning**, in a fresh chat where practical (§9.1).
- Read Stage 5's section and its provisional Tasks P5.1–P5.6 (from ADR-019).
- Re-verify them against the code (§9.7).
- Identify gates: RD-09 (confirm or undo for destructive actions) is Stage 5's.
- Freeze a Task sequence with scope, acceptance and validation.
- Update the documents, commit, and STOP before implementation.

**Carried:**
- S4-DEF-01 to S4-DEF-08 (Stages 6 and 8);
- S4V-02 (correct the S4.E script before Test A or C runs on the owner's install);
- the earlier carried items below.

*Superseded by the Stage 4 closure (kept as written):*

**The final, bounded, fresh-session Stage 4 validation** (plan, "S4.V3 — Bounded final
validation"; `CLAUDE.md`, "Validation Rules"; E.1, "Bounded validation for analysis and decision
Stages").

**It answers only whether:**
1. S4.R1–S4.R5 were completed;
2. every research gate required by Stage 4 has an explicit owner decision;
3. ADR-019 faithfully represents those approved decisions;
4. the wireframe addendum is consistent with ADR-019;
5. S4.T maps the approved design into the appropriate later implementation Stages;
6. the documents contain no direct contradiction that makes an approved core flow impossible;
7. no Stage 4 acceptance criterion remains unmet.

**Blocking and outcome:**
- **BLOCKING:** only a direct contradiction with an approved owner decision or an explicit Stage 4
  acceptance criterion.
- **Not blocking:** S4-DEF-01 to S4-DEF-08 and any other open implementation detail. These are
  `DEFERRED / IMPLEMENTATION DECISION`.
- **No new requirements:** the validation creates none.
- **If it passes:** close Stage 4 and set Stage 5 (Design System Foundation, planning) as the next
  allowed action.
- **If it fails:** name the exact decision or criterion contradicted, with evidence. Do not expand
  Stage 4.

S4.E remains optional. S4V-02 must be corrected before Test A or Test C runs on the owner's
install, but it does not block Stage 4.

*Superseded by S4.V3 (kept as written):*

**Fresh-session Stage 4 revalidation after S4.V2** (§9.8).
- **Check ADR-019 §3.1 as revised against the owner's invariant and R2 + D1** (E.1, "S4R-01 and
  S4R-02 decided"):
  - no path changes a saved snapshot, or moves it to another night, except "Save again" for the
    same night;
  - results are recorded against the snapshot without Save plan, and not before the night ends;
  - the working copy is never forced through a guard;
  - Stage 6 leaves saved plans as today, and Stage 8 delivers the saved night and the working copy
    together.
- **Challenge the derived rules** listed in that entry.
- **Check consistency:**
  - the ADR-014 pointer, D5, the addendum and the research notes;
  - P6.1, P6.7, P8.1–P8.3, the S4.V2 matrix, "Order across Stages" and TD-057.
- **Recheck Stage 4's exit criteria.**

Stage 5 stays blocked until Stage 4 passes. S4.E remains optional. Correct S4V-02 before Test A or
Test C runs on the owner's install.

*Superseded by S4.V2 (kept as written):*

**Owner decisions for the Stage 4 revalidation's blocking findings** (`STAGE_4_REVALIDATION.md`):
- **S4R-01, the result rule for Saved · changed:**
  - **R1:** always record for the saved night and the saved version, with the edits kept as an
    unsaved copy;
  - **R2 (recommended):** keep Review → Save, but pin the review to the saved night and site;
    never record a night that has not ended; Not done needs no Save; do not force Save or Discard
    on tonight's continuation;
  - **R3:** another rule.
- **S4R-02, the delivery order:**
  - **D1 (recommended; E.1's order):** P6.7 covers only never-saved drafts and the candidates
    list; saved plans keep today's behaviour until P8.3 delivers the protection and the
    continuation together;
  - **D2:** the continuation moves into Stage 6;
  - **D3:** accept the interim explicitly.

Then **S4.V2** (documentation only) aligns:
- ADR-019 §3.1 and its status line (S4R-04);
- addendum §3.10, S4.R3 §12, RG-04 §13, D5 and the ADR-014 pointer;
- P6.7, P8.1–P8.3, the S4.V1 matrix and "Order across Stages";
- TD-057 (S4R-03) and E.1.

After that, a **fresh-session Stage 4 revalidation**. Stage 5 stays blocked until Stage 4 passes.
S4.E remains optional. Correct S4V-02 before Test A or Test C runs on the owner's install: both
change persisted session state.

The separate S3V-08 device recheck, if the owner wants it, is its own action through `.s2check`,
never the owner's installed app.

**Carried open items:**
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
- TD-066 resolved 2026-09-26 (fractional exposure presentation; see amendment above);
- the stale id-holding preferences after a reset, `editedSessionId` included (with
  TD-056/ENG-14).

## Stage 0 notes

Thirteen discrepancies between the prompt, the documents and the repository are recorded in
`POST_ROADMAP_PLAN.md` §1.3. Among them:
- the prompt's location (item 1);
- undocumented manual device use (item 2);
- the `chacha12`/`Buffur` identity (item 3, RD-01);
- the licence requirements against PD-12 (item 4, RG-12).
