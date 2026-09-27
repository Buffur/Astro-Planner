# Stage 4 validation — Product Flow & Information Architecture

Date: 2026-09-27. **Verdict: FAIL — one blocking design gap (S4V-01).**

Stage 4 produced the required research, owner decisions, ADR, wireframe addendum and
provisional Tasks. It did not implement those future flows. Most acceptance criteria are met,
but the saved-and-edited state is missing from the next-day lifecycle decision. Stage 5 stays
blocked pending a focused documentation correction and independent revalidation.

## Scope and baseline

- Repository: `C:\Users\zalub\OneDrive\Desktop\Astro Planner\Astro-Planner`.
- Branch: `main`; validated HEAD `adb5d9506a7ab12f01c24659484cc66c6ae48967`.
- Stage 3 closure: `126d97f`; Stage 4 planning: `2a26185`.
- Implementation source baseline: `92ebf2a`. All subsequent differences through validated HEAD
  are documentation. The working tree was clean at entry.
- Validator did not participate in Stage 4's planning, research or decision-writing session.
  This chat previously validated Stage 3; it is separate from the Stage 4 authoring chat.
- Governing sources: the supplied independent-validation prompt, `CLAUDE.md`,
  `POST_ROADMAP_PLAN.md` Stage 4 and governance, `PRODUCT_DIRECTION.md`, and `PROGRESS.md`.
  Cross-checked audit 08's flow questions, UX-18 and the relevant audit 05 measurements,
  ADR-014/015/016 and their ADR-019 amendments, all five research documents, the addendum,
  ARCHITECTURE D5 and the provisional Stage 5/6/7/8/9 sections.
- No production code, tests, dependencies, original wireframes or accepted decisions changed
  during validation. No device or installed application was modified.

## Task acceptance

| Task | Result | Evidence and limit |
| --- | --- | --- |
| S4.R1 — inventory and matrix | PASS, with S4V-02 | Routes, actions, state display, code-based tap estimates, Q1–Q22 and UX mapping are present. Rechecked the current planner/launch, Tonight, Library, import and session-detail paths against code. The owner-run script is self-contained, but inaccurately describes Test C as read-only. |
| S4.R2 — Execution and actuals | PASS | A–D and G1–G3 compare effects on CALC-35–38, events, snapshots, existing runs, Android/foreground constraints, resume and export. B + G2 and D3/D4 are recorded in E.1. RD-12/13 remain assigned to Stage 8. No live functionality was removed. |
| S4.R3 — lifecycle and defaults | FAIL on completeness | L1, Y2, U1 and RD-04 are recorded with alternatives, flows and future work. However, Y2 does not define the saved-and-edited draft case (S4V-01). |
| S4.R4 — Tonight, planner, disclosure | PASS | T1, D-b, P-1 and M0 are decided. Named Night & Moon / Weather destinations, answer-first ordering, one-tap details, scientific constraints and the ADR-009 display amendment are recorded. S4.E's absence is explicit; Stage 6 carries the five-second test. |
| S4.R5 — Library and vocabulary | PASS | LB1 + PR2, Rig, Plan, Logbook and the glossary are recorded. UX-18 concepts are covered. Stage 3's photo import is retained in both rig-list modes. |
| S4.D — ADR and addendum | FAIL on consistency | All eight gates are recorded, amendment pointers exist, DEV-P9 is recorded, the original wireframes are unchanged, and the matrix has answers/homes. ADR-019 narrows the owner's saved-plan protection to stored `planned`, omitting `Saved · changed` (S4V-01). |
| S4.T — provisional Tasks | FAIL on completeness | Decision references, dependencies and acceptance sketches exist across P5/P6/P8/P9; Stage 7's no-change statement and UX traceability are present. However, P8.3 carries the same lifecycle gap and P6.7 says to roll the current draft forward without distinguishing saved-and-edited drafts (S4V-01). |
| S4.E — owner quick tests | OPTIONAL / UNVERIFIED | Not run. Owner explicitly made this non-blocking. No usability or darkness success is inferred from automated tests. |

Research/decision commits, in order: R1 `e5fd240`; R2 `97ffab5` / `abca03d`;
R3 `989a61e` / `8600a39`; R4 `8578ab8` / `0506b04`; R5 `160ee37` / `28857d8`;
D `f68e576`; T `adb5d95`. Each research step precedes its recorded owner decision.

## Findings

### S4V-01 — BLOCKING: next-day protection excludes a saved-and-edited plan

**Evidence: DOCUMENTED + CODE VERIFIED; existing regression tests also exercise the state.**
This is a defect in the future-flow specification, not a claim that Stage 4 introduced a
runtime regression.

The owner's E2 decision says a **saved plan** whose night has passed stays on that night awaiting
its result; only a **never-saved** draft rolls forward (`DECISIONS.md:1119–1122`). The same
document explicitly recognizes `draft` with `plannedAtUtc` as **Saved · changed**
(`DECISIONS.md:3730`). But ADR-019's actual resume exception is only for a **`planned`**
session (`DECISIONS.md:3745–3748`). P8.3 repeats that narrower condition
(`POST_ROADMAP_PLAN.md:2020`), while P6.7 calls for writing the current draft's new night key
at rollover (`:1939`). There is no owner deferral for this state.

The state is ordinary and reachable:

1. Save a plan for night N.
2. Change a block, target, rig or site without pressing Save again.
3. The same aggregate is now `draft`, with a non-null `plannedAtUtc` and its saved snapshot.
   It remains listed in the Logbook.
4. Reopen after night N, or keep the application open across the rollover.

`drift_session_repository.dart:61–69` sets `draft` on edit without clearing the saved marker;
`library_viewmodels.dart:153` includes these rows. The existing test at
`test/presentation/viewmodels/planner_draft_session_test.dart:298–307` checks exactly this
saved-to-draft transition and retained marker. `CurrentSession.resume` (`:48–57`) and
`SessionPlanViewModel.load` (`:118–133`) show why the unchanged general resume path remains
relevant when the new exception does not match.

| State at end of night N | Approved future behavior |
| --- | --- |
| Never-saved draft | Roll forward |
| `planned` | Preserve N; continue on a new copy |
| `draft` + `plannedAtUtc` (Saved · changed) | **Not specified by the exception or the rollover Task** |
| Live run | Existing run/events preserved; planner works on a copy |
| Completed/abandoned/legacy | Existing frozen/history behavior retained |

Implementing the written exception literally leaves the third row on the old resume path,
allowing its night to roll forward and a later autosave to detach it from the night awaiting
a result. Merely requiring Save again is not the recorded E2 rule. The result transition
table also only adds `planned → completed`: the treatment of this listed edited plan and
which saved/edited version supplies its results must be made explicit.

**Required follow-up, proposed S4.V1 (documentation only):** complete the lifecycle matrix for
never-saved, saved and saved-and-edited plans, including startup and a live rollover. Define
preservation of the original night/snapshot and unsaved edits, plus the route to recording
results for the edited case. Align the research conclusion, ADR-019 and its pointer, D5,
addendum and P6.7/P8.1/P8.3. Include future regression acceptance for Save → edit → next night
through both restart and an app kept open. Any choice beyond the existing E2 preservation
decision belongs to the owner; this validation does not choose it or change code.

### S4V-02 — NON-BLOCKING: Test C is described as read-only but starts a run

**Evidence: DOCUMENTED.** `S4.R1_FLOW_INVENTORY.md` §7's device rules say Tests A and C
"only look at the app" and permit the owner's install. Test C §7.3 step 2 instructs the owner
to Start a test plan and then abandon it. Start persists a run and replaces the planner's
current plan with a copy; this is not a read-only check. The script does not first establish
a disposable plan or account for an existing live run.

Before running this optional test, correct its setup to use a disposable plan and separate
test install, or clearly describe and guard the mutations. This does not block the design
stage because S4.E was explicitly optional and was not executed here.

### S4V-03 — UNVERIFIED, non-blocking: human/physical usability

Five-second comprehension, first-run observation and real-darkness/glove use remain unrun.
Stage 6 already carries the five-second acceptance evidence. Existing host accessibility tests
cannot establish those outcomes. Prior-stage device checks remain separate carried items.

## Cross-task checks and rejected findings

- All 22 matrix questions and the required UX rows have answers or explicit later-stage homes.
  Search/filter/share, chart/capture visuals, automation, settings, performance and tracking
  placement retain their existing gates; they are not silently declared implemented.
- No new provider, dependency, schema, formula, notification system, fifth tab or score was
  introduced. Counts remain event-derived; old runs, snapshots and exports remain readable
  requirements. Metadata batch actuals remain later work, not a Stage 2 capability claim.
- Stage 6 preserves a path to results through Track live until Stage 8's result form exists.
  Progress remains reachable while moving from Library to Logbook. P-IDs are expressly
  provisional and future planning must reverify them.
- **REJECTED:** the new screens are absent from the running app, therefore Stage 4 failed.
  Stage 4 explicitly forbids application implementation; those screens belong to later Stages.
- **REJECTED:** unrun S4.E alone prevents closure. The owner explicitly waived it as a blocker.
- **REJECTED:** 250 versus 300 in the ViewModel constraints is an architecture conflict.
  `viewmodel_rules_test.dart:38–49` enforces 250 code lines and 300 physical lines.

## Executed verification

- `git diff --name-only 92ebf2a..adb5d95`: documentation only; no application, test,
  dependency, platform, asset or tool change.
- `git diff --check 126d97f..adb5d95`: PASS.
- `git diff 126d97f..adb5d95 -- docs/IA_WIREFRAMES.md`: empty, as required.
- `dart run tool/check.dart`: **PASS, exit 0**, run against `adb5d95`:
  - encoding passed;
  - format: 376 files, 0 changed;
  - analyzer: no issues;
  - unit/widget suite: **1,214 passed, 1 expected skip** (local metadata samples were not
    supplied via `ASTROPLAN_METADATA_SAMPLES`);
  - host E2E: **2 passed**.
  Local raw output: `%TEMP%\astro-stage4-validation-gate.log` (not committed).
- No new probe is needed to demonstrate a missing specification branch; no tests were
  weakened or created to assert an invented future implementation. The existing SQLite-backed
  lifecycle regressions are part of the full gate.
- No Android/device run, network research or release claim was needed for this docs-only Stage.

## Next allowed action

Propose/approve and complete the focused S4.V1 documentation follow-up, then independently
revalidate Stage 4. Correct S4V-02 before Test C is used. Do not start Stage 5 or implement the
future application flows as part of this validation. Only this report and PROGRESS are changed.
