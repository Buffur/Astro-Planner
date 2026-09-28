# Stage 6 — bounded final validation

Date: 2026-09-28. Checkout: `6b50369`; application baseline: `d7e1477` (S6.16).
Validation only, under CLAUDE.md V1–V8 and the owner's supplied validation prompt.

## Frozen scope and validation matrix

Prepared from the current contract before inspecting implementation or running checks.
Authority: POST_ROADMAP_PLAN.md, Stage 6 frozen S6.1–S6.14, S6.16, S6.E and
Stage Exit; DECISIONS.md ADR-019 and E.1 (S4-DEF-04 = R, RD-08 = T3,
RD-10 = O1, RD-11 = S9, corrective-pass decision); DESIGN_SYSTEM.md.
S6.15 is excluded by RD-11. No Stage 7–9 work or new design requirement is included.
Saved snapshot integrity, D1, the tracker boundary, domain-authoritative calculations,
Unknown remaining Unknown and the relevant CLAUDE.md traps remain invariants.

This matrix was prepared with UNVERIFIED results before code inspection, then completed below.
TEST VERIFIED means inspected tests covered by the reusable full-gate PASS, except for the
explicitly identified fresh failing probe. DEVICE VERIFIED means the recorded S6.E observation
on its stated build and environment, not a new device run. Code/test evidence does not establish
independent human comprehension.

| Criterion | Evidence required | Current evidence | Result |
| --- | --- | --- | --- |
| S6.1 split, limits, unchanged assertions, memoization/lifecycle | Code, original split diff, rules tests, gate | CODE VERIFIED / TEST VERIFIED: E1 | PASS |
| S6.2 identity/actions, feedback, autosave races, interim tracker | Code, UI/race tests, E2E, accessibility | CODE VERIFIED / TEST VERIFIED: E2 | PASS |
| S6.3 Save/Discard/Cancel at four callers, restart, snapshots and counters | UI and real-SQLite tests | CODE VERIFIED / TEST VERIFIED: E3 | PASS |
| S6.4 draft rollover, saved-row invariant, queued edits, future night, candidates | Injected-clock and restart tests | CODE VERIFIED / TEST VERIFIED: E4 | PASS |
| S6.5 night/weather detail completeness, dark-limit vectors, states/routes | Domain, widget, accessibility tests | CODE VERIFIED / TEST VERIFIED: E5 | PASS |
| S6.6 answer first, first viewport, fit/budget values, neutral missing input | Three-theme viewport and state tests, code | CODE VERIFIED / TEST VERIFIED / DEVICE VERIFIED: E6 | PASS; human comprehension separate |
| S6.7 one-level disclosure, retained values, visible caveats, budget lines, restart | Disclosure and budget tests, code | CODE VERIFIED / TEST VERIFIED: E7 | PASS |
| S6.8 first run, empty plan, explicit examples, New defaults, restoration | Defaults, welcome and restore tests | CODE VERIFIED / TEST VERIFIED: E8; contradictory probe F1 | FAIL only for stale deletion Undo's example badge |
| S6.9 block identity/count/exposure/duration, editor, tracking, Delete + Undo | Widget/SQLite tests, 200% text, reduced motion | CODE VERIFIED / TEST VERIFIED: E9; contradictory probe F1 | PASS for immediate Undo and presentation; FAIL for stale deletion Undo |
| S6.10 budget outputs, known/unknown storage and invalidation, authoritative What fits | Domain/ViewModel/UI tests and trace | CODE VERIFIED / TEST VERIFIED: E10; TD-074 limits | PASS |
| S6.11 relative stacking gain, separate groups, domain points, labels and text alternative | Domain/widget tests, themes at 200% | CODE VERIFIED / TEST VERIFIED: E11 | PASS |
| S6.12 authoritative intervals/end, actual gaps, clock/zone/labels/bands/text alternative | Mapping/geometry tests and code | CODE VERIFIED / TEST VERIFIED: E12 | PASS |
| S6.13 Tonight order, picker autosave, dark/Moon rows, tracker access, site message | UI/domain tests, E2E, sweep | CODE VERIFIED / TEST VERIFIED / DEVICE VERIFIED: E13 | PASS |
| S6.14 usable-time/frame-fill/name order, unknowns last, batch parity | Domain and screen tests | CODE VERIFIED / TEST VERIFIED: E14 | PASS |
| S6.16 TD-075–078, amended order and core hierarchy/finish | Code, semantic/viewport/widget tests | CODE VERIFIED / TEST VERIFIED / DEVICE VERIFIED: E6, E11, E13, E16 | PASS |
| S6.16 TD-079 bounded recovery, stale Undo, saved snapshot, motion | Real-database harness tests and code | CODE VERIFIED / TEST VERIFIED: E16; TD-081 separate | PASS for its three operations; deletion is F1 |
| S6.16 TD-080 distinct target actions, no duplication | Widget tests and code | CODE VERIFIED / TEST VERIFIED / DEVICE VERIFIED: E13 | PASS |
| Stage Exit accessibility and regression | Light/Dark/Field, 100%/200%, semantics, targets, overflow, E2E, full gate | TEST VERIFIED: E15; recorded gate still valid | PASS for covered checks; F1 prevents Stage closure |
| Capture ends observation: meaning → calculation → label → contract | ADR-009/019, calculation and UI trace, existing vectors | CODE VERIFIED / TEST VERIFIED; DEVICE VERIFIED observation: C1 | PASS — A, within the frozen whole-night contract |
| S6.E independent five-second comprehension | Independent participant's verbatim answers | None; owner explicitly accepts the gap in this validation request | UNVERIFIED — no independent participant available |

## Evidence and passed criteria

**Gate reuse (V3):** full quality gate PASS on final S6.16 inputs, `d7e1477`:
Encoding; Format (439 files, zero changed); Analyze (no issues); 1,486 tests,
two expected skips (local samples and opt-in S5.9 render); two host E2E.
`git diff --stat d7e1477 HEAD -- . ':!docs' ':!CLAUDE.md'` was empty at `6b50369`,
and the working tree initially clean. Only documentation/evidence records changed here.
Source: [PROGRESS.md, reusable evidence](PROGRESS.md#reusable-validation-evidence) and
the S6.16 commit. This is reused recorded evidence, not a freshly run gate or remote CI.
The new failure below is an uncovered sequence; it does not falsify that recorded run.

Paths below are repository-relative. Each named test was inspected against its criterion;
its passing execution evidence comes from that gate.

- **E1 — S6.1:** `6834458` moves only test harness call sites; its test diff changes no
  assertions. Split outputs were 220/167 physical lines. Current `SessionPlanViewModel`
  and `PlanLifecycleViewModel` retain the split; later S6.16 explicitly records 296 lines
  for the former. `test/presentation/viewmodels/viewmodel_rules_test.dart` enforces the
  current 250 code / 300 physical-line rule. `planner_memoization_test.dart`,
  `test/lifecycle/lifecycle_matrix_test.dart` and host E2E remain covered.
- **E2 — S6.2:** `test/presentation/screens/home/plan_identity_actions_test.dart` checks
  target/night/state, menu eligibility, feedback and New/Copy races; `save_start_race_test.dart`
  and `test/domain/services/current_session_chain_test.dart` cover serialized writes.
  `home_screen.dart` keeps Save as the bottom primary action, Track live in the menu.
  The wrapping identity strip is the recorded implementation decision, not a truncated app-bar
  title. `integration_test/core_loop_test.dart` retains the interim route to results.
- **E3 — S6.3:** `test/presentation/shared/unsaved_plan_prompt_test.dart` covers the four
  callers and answers, dismiss, untouched replacement, restart, W1/V3 and refused revert.
  `test/data/repositories/drift_session_discard_test.dart` covers real-SQLite delete guards,
  restored values, unchanged snapshots/timestamps, unreadable/missing references and counters
  against replay. `saved_plan_reader_test.dart` and `current_session_switch_test.dart` cover
  the domain boundary. No saved historical snapshot is deleted by these paths.
- **E4 — S6.4:** `PlanLifecycleViewModel.followNight/load` restricts writes to never-saved
  drafts. `test/presentation/viewmodels/night_rollover_test.dart` covers mean-solar-noon
  rollover, saved rows unchanged, future and deliberately picked past nights, queued edits,
  restart and open candidates. D1 is preserved; saved-plan rollover redesign remains Stage 8.
- **E5 — S6.5:** `test/domain/services/dark_span_test.dart` compares −18°, −15°, −12° with
  opportunity results and astronomical twilight, including no darkness. `test/presentation/screens/details/detail_screens_test.dart` verifies detail navigation and retained twilight,
  Moon and weather information, refresh and unavailable states. `weather_forecast_widget_test.dart`
  remains the detailed weather coverage. Both new routes are in E15; no widget astronomy path.
- **E6 — S6.6 and S6.16 order/status:** `home_screen.dart` is status → framed context →
  target → rig → Capture plan → Tonight for this target → conditions. `planner_structure_test.dart`
  checks first viewport at 412 × 915 in three themes, fit/budget wording, missing inputs, exact
  vertical order and timeline mapping. `PlanStatus.missingInput` supplies the appropriate
  reason shared with Tonight; integration stays visible even when input is incomplete.
  S6.E's refreshed `.s2check` record confirms the first screens on Xiaomi 14T Pro,
  Android 16, dark theme, font scale 1.0. It does not cover all device themes/scales.
- **E7 — S6.7:** `planner_disclosure_test.dart` covers factual collapsed summaries, visible
  unknown/capability/constraint/unavailable states, ADR-009 E3/E4 budget lines and restart.
  `CaptureBudgetSummary`, `CaptureAssumptionsPanel`, rig Specifications and Sky disclosure
  retain their values one level down; opportunity windows/exclusions and detail screens retain
  deeper night/weather values. Stale forecast wording remains shared `WeatherText` coverage.
  No Basic/Advanced mode was introduced; retired labels are absent from these surfaces.
- **E8 — S6.8:** `planner_defaults_test.dart`, `equipment_example_test.dart`, the welcome
  tests in `tonight_home_screen_test.dart` and lifecycle restore tests support no automatic
  target/rig, empty capture plan, explicit example offer, retained selections and New keeping
  site/rig. The ordinary first-edit badge test passes, but F1 disproves the invariant after
  a later delete Undo. This is the sole failed part of this task.
- **E9 — S6.9:** `capture_blocks_test.dart` checks all four frame types, empty/long filter,
  200% text, ISO/binning absent from rows, calibration placement, immediate exact Delete + Undo
  through SQLite, timeout, edit and reduced-motion mark. `BlockText.row` reads
  `BlockBudget.exposureMs`; camera parameters remain in `capture_block_dialog.dart`.
  Known tracking warnings name the state; Unknown is neutral and retains "if untracked".
  `effectiveTracking` reads the rig default. The example seed is not asserted to be tracked.
  RD-08's nullable override and snapshot extension remain Stage 7. Stale delete recovery fails F1.
- **E10 — S6.10:** confirmed rig RAW size → `CaptureAnalysisViewModel._computeBudget` →
  `CaptureBudgetCalculator` block storage and total → `CaptureBudgetSummary`.
  `capture_outputs_test.dart` checks 50 MB × 30 frames = 1500 MB, estimated-source wording,
  unknown rig size and no rig; calculator tests exclude library frames and propagate null.
  Invalidation is CODE VERIFIED: rig editor/import return calls `refreshSelectedEquipment`,
  which reloads and notifies; analysis generation invalidates budget/fit/fill caches.
  Block, settings and night changes use the same invalidation path; refresh/memoization tests
  cover the mechanism. This is not claimed as a new end-to-end RAW-edit test.
  What fits uses `unplacedFramesByBlock` and `maxFramesForBlock` for the last light block;
  no widget scheduler or per-window placement. No budget bar implies continuous time.
- **E11 — S6.11/TD-076:** `StackingGainCurve` uses the existing domain √N function;
  `CaptureBudgetSummary` draws each compatible filter/exposure group separately.
  `stacking_gain_curve_test.dart` and `stacking_gain_graph_test.dart` check domain points,
  marked group value, separate groups, text alternative, Your plan/For comparison labels,
  absence of recommendation/SNR wording and three themes at 200%. The swatch uses the
  same painter as the planned dot. No physical SNR or image-quality prediction is introduced.
- **E12 — S6.12:** `TimelineData` maps domain samples/windows; `TimelinePainter` draws each
  actual interval separately and only the fit's end marker, never an invented placement.
  `timeline_test.dart` covers merged bands, gaps, whole-hour ticks, half-hour zones and DST,
  12/24-hour settings, labels outside the plot at both scales, field edges, compact density
  and text alternative. `planner_structure_test.dart` ties the rendered data to the live
  opportunity and fit. Supporting list keeps excluded-period reasons and zone text.
- **E13 — S6.13/TD-077/TD-080:** `tonight_home_screen_test.dart` covers the order, picker
  autosave, dark span at three limits, Moon wording, feedback, headline/header roles, framed
  context, `titleMedium` Your plan with `bodyLarge` target, primary Open planner with/without
  target, and distinct target-action descriptions shown once. `moon_during_dark_test.dart`
  supplies domain coverage. The existing run card still opens the tracker; site prompting and
  `location_picker_screen_test.dart` preserve the approved message behavior. Refreshed device
  observations confirm the concrete hierarchy, not independent comprehension.
- **E14 — S6.14:** `candidate_evaluator.dart` chains usable duration descending, frame fill
  descending with null last, then name. `candidate_evaluator_test.dart` includes tie-heavy
  fixtures, no promotion of shorter duration, and batch/single-target parity.
  `tonight_candidates_screen_test.dart` covers the named sort and other choices. No score.
- **E15 — accessibility/regression:** `test/presentation/accessibility_test.dart` sweeps
  Tonight, planner, candidates and new detail routes at 412 logical pixels, Light/Dark/Field,
  100%/200% text, including a full forecast and all planner disclosures open. It checks
  overflow exceptions, Android 48 px targets, labels, and light/dark contrast. Its tall view
  avoids clipped-target false positives; E6 separately tests the real first viewport.
  Semantic headings, icon tooltips, chart alternatives and text alongside color are supported
  by E6/E9/E11/E12/E13 and the sweep. `field_mode_darkness_test.dart` is automated palette
  evidence, not a physical darkness trial. Accepted Field contrast exceptions remain accepted.
- **E16 — S6.16 recovery and structure:** `capture_blocks_undo_test.dart` checks Fill, Trim,
  saved block edits and example-plan Undo, identical blocks/badge through SQLite, rejection
  after newer blocks, unchanged saved snapshot, and no change-mark motion when reduced.
  `BlocksEdit.isCurrent` checks content generation, session and exact block identities;
  no global history exists. TD-078's summary appears once in `detail_screens_test.dart`, with
  Sun/twilight and Moon headings and retained deeper values. TD-075–TD-080's recorded fixes
  remain supported within their scope. Deletion does not use `BlocksEdit`, which is F1.

## Unverified evidence

**UNVERIFIED — no independent participant available.** S6.E has no verbatim participant
answers. The owner explicitly accepted this gap in the current validation request; DECISIONS
E.1 corrective-pass item 7 and the amended S6.E allow it to be recorded under V7. It is not
the reason Stage 6 is blocked. Neither the owner manual review nor an agent's device work is
HUMAN VERIFIED independent comprehension. No device preparation was repeated.

Physical dark-adaptation and broader Android lifecycle/accessibility rows remain Stage 11
evidence gaps. The current device evidence is limited to the recorded S6.E build/environment.

## Non-blocking carried findings

- **DEFERRED:** TD-074, the known capacity API limits (joint filter allocation, other blocks,
  margin-aware maximum). Existing approved wording stays within the API; Stage 7 or 9 only
  if that domain extension is selected. No new requirement is created.
- **DEFERRED:** RD-08 override, calibration/ISO/gain/binning and source automation: Stage 7.
- **DEFERRED:** saved-plan working-copy/result behavior and tracker retirement: Stage 8
  (D1 and P8.1–P8.4); Sessions/export-all presentation: P8.7.
- **DEFERRED:** TD-050 gate controls: Stage 9 P9.3/RG-13; richer detail-screen presentation:
  Stage 9. TD-081's global snackbar motion: Stage 9 or 11 as already recorded. Stage 6's
  change marks honor `AppMotion`; its Undo uses the existing message pattern and adds no
  separate animation. This validation does not expand it into a global messenger redesign.

## Blocking finding F1 — S6V-01 / TD-082

**BLOCKER (V4 A/B), bounded presentation-state regression; no demonstrated frame loss.**
Owner: Stage 6 S6.9 deletion recovery, directly regressing S6.8's retained TASK 4.4 badge rule:
"shows its badge until the first edit". The supplied validation also requires stale Undo not
to overwrite newer state. S6.16's three guarded operations are not the failing path.

Reproduced against unchanged `d7e1477` application code, through `CapturePlanWidget` UI and
real in-memory SQLite, with the existing S6.9 harness:

1. Start from the example (three blocks, example badge true).
2. Delete its light block; the badge becomes false and Delete offers Undo.
3. Before it expires, Add capture block, exposure 60 seconds, count 7, Save.
4. Tap the still-visible deletion Undo.
5. The result has four blocks and retains the new seven-frame block, including in SQLite,
   but `isExampleCapturePlan` is **true**. The UI mislabels the edited plan as the example.

Fresh focused probe result: **FAIL**, exit 1, with:

```text
S6V observed: 4 blocks, last count 7, example badge true
Expected: false
  Actual: <true>
A newer user block must not be presented as the untouched shipped example.
```

Source: `lib/presentation/widgets/capture_plan_widget.dart`, `_BlockListState._delete`,
captures `wasExample` and calls unguarded `restoreCaptureBlock`; that method in
`lib/presentation/viewmodels/session_plan_viewmodel.dart` inserts the block and unconditionally
sets `_isExample = wasExample`. The newer block is not lost, but its resulting badge state is
overwritten. Existing delete coverage only tests immediate Undo and timeout, so a green gate
does not cover this sequence.

Reproduction artifact: [S6V_01_DELETE_UNDO_PROBE.patch](evidence/S6V_01_DELETE_UNDO_PROBE.patch),
an unapplied test-only patch over the existing S6.9 harness. `git apply --check` passes.
The equivalent test was executed from `%TEMP%/astro-stage6-validation/delete_undo_probe_test.dart`
using `flutter test --no-pub <absolute-probe-path> --reporter expanded`. The first draft of the
probe omitted the required exposure input and stopped before reproduction; that probe setup was
corrected, then the failure above was obtained. No existing test or application file was edited.

**Smallest corrective task: S6.V1 — make deletion Undo stale-safe.** Reuse the existing bounded
blocks-edit recovery (or an equivalent small guard) so a later block edit or plan replacement
cannot restore stale blocks/badge state. Keep immediate exact restoration, normal autosave,
unchanged historical snapshots, timeout and reduced-motion behavior. Add the concrete sequence
above as a regression and check stale recovery across plan replacement. No persistent/global
history, schema, scheduling or redesign. This task is recorded, not implemented here.

## C1 — Capture ends classification

**A — correct and sufficiently clear for the current frozen whole-night planning contract.**
This is a contract/code assessment; independent comprehension is still UNVERIFIED.

- **Domain meaning:** ADR-009 §§5–6 fits the plan into all windows of one `SessionNight`
  and reports the projected end. It is not a remaining-from-now calculation or an actual
  recorded completion. ADR-019 keeps the plan's selected night visible.
- **Calculation:** `FitAnalyzer.analyze` initializes `t = windows.first.start`, places atomic
  events in order across windows, and returns the last placed event's `endUtc`.
  `CaptureAnalysisViewModel._computeFit` passes the whole opportunity's windows. Current
  clock time is not a scheduling input. `fit_analyzer_test.dart` verifies explicit end instants,
  split windows/lost tails and outside-window calibration.
- **UI:** `PlanStatus` displays that exact end for Fits/Tight, formatted in the site's zone,
  beneath the plan's target / "Night of …" / saved-state strip. The framed context repeats
  the selected night and carries the zone rule. The timeline uses the same end and the actual
  imaging windows; its separate current-time dot does not move or reschedule the plan.
  "Capture ends" is also the label frozen in the Design System's timeline and S6.6 scope.
- **Observed interpretation:** at about 22:55, the saved Sep 28 plan still displays 22:21
  because its projected start is the first window of that selected night. This agrees with the
  approved planning calculation. No current UI promises "starting now" or says 8 h 35 min
  remain. The past timestamp alone is therefore not contradictory evidence or a correctness
  failure. There is no independent participant evidence establishing a misleading reading.

No new start-time input, clock-clipped fit or label requirement is invented by this validation.

## Verdict, documentation and Next Allowed Action

**Stage 6: BLOCKED — S6V-01 / TD-082.** All other technical criteria above keep their PASS;
S6.E remains **UNVERIFIED — no independent participant available**, explicitly accepted by
the owner. Stage 6 is not closed and Stage 7 is not started.

**Exact Next Allowed Action:** the bounded **S6.V1** deletion-Undo correction above, then V5
revalidation of S6V-01, the affected S6.8/S6.9 criteria and the correction's actual regression
surface. Preserve the other PASS results and the accepted human-evidence gap; do not rerun a
broad Stage audit. Verification for the future correction follows V1's actual cumulative diff.

Documentation only: this report and unapplied probe; `PROGRESS.md` result/next action;
`TECH_DEBT.md` TD-082; S6.E evidence-gap disposition. Frozen acceptance criteria and earlier
observations remain unchanged. References/IDs and whitespace are checked; no full gate rerun
is required for these records. The validation procedure requires one documentation commit.
Push remains deferred (RD-17). STOP after that commit.
