# Stage 5 — Validation (Design System Foundation)

> **Validated:** `main` @ `8a6c5d8` (S5.9), 2026-09-27.
> **Procedure:** `prompts/INDEPENDENT_STAGE_VALIDATION.md` under `CLAUDE.md`, Verification Policy
> V4–V8. Validation only: nothing was fixed. Probes were written in the scratch area and deleted,
> never committed.
> **Independence: NOT independent.** The owner asked for this validation in the chat that planned
> and built Stage 5. The same author judged its own work, a known weakness (Stage 1's same-session
> validation passed where an independent one found four defects). To offset it, every criterion was
> judged on fresh evidence (diffs, probes, renders), not on the Task notes.
> **Result: FAIL, one narrow blocker (S5V-01).** Every other frozen item passes. The blocker's
> behaviour is correct (a probe proves it); the committed test the criterion names is missing. A
> focused corrective Task, S5.V1, is proposed. Then revalidation of S5V-01 only (V5).

## 1. The frozen acceptance surface (listed before judging)

1. **The plan's "Stage 5 validation" checks:**
   - (a) the tokens and components exist, are tested (style rules, the gallery's accessibility
     checks, red mode) and are documented;
   - (b) no screen's wording or structure changed, other than through the theme tokens;
   - (c) nothing regressed (the accessibility sweep, the darkness test, the E2E, the gate);
   - (d) the adoption plan is complete;
   - (e) RD-09 is recorded and built as decided (M + S1).
2. **The Stage definition's exit:** tokens and components exist, are tested (style rules,
   accessibility, red mode) and documented.
3. **S5.1–S5.9's acceptance criteria**, as frozen in `POST_ROADMAP_PLAN.md`.
4. **The rules for every Stage 5 Task:**
   - tokens only (trap 12);
   - 48 dp, 200 % text, labels and AA in light and dark for every component;
   - no calculation in widgets (trap 13);
   - the gallery; documentation; glossary words;
   - existing tests pass, and changed expectations are justified;
   - no schema change, new dependency or external service;
   - S5.5's preference through `DisplayPreferencesRepository` with `guardStorage` (trap 15);
   - one Task per commit.
5. **Invariants cited:**
   - trap 2 (the zone rule), trap 11 (ViewModels: domain interfaces, size), trap 12, trap 13,
     trap 15, trap 17 (semantics), trap 22 (nothing leaves the device);
   - SI-003 (√N never SNR), SI-008 (unknown never shown as a value).
6. **Required evidence:** the full gate (each Task's "gate green"). No device rows.

## 2. Evidence

- **The gate, reused (V3):** full gate PASS on S5.9's final inputs, at `8a6c5d8` (Encoding;
  Format, 404 files; Analyze; 1,319 tests, 2 expected skips; 2 host E2E). HEAD is `8a6c5d8`, so no
  input changed.
- **What Stage 5 changed in code:** `git diff --stat 38925dd 8a6c5d8 -- lib`:
  - `lib/core/theme/` (8 files);
  - the display-preferences interface and its SharedPreferences implementation;
  - `main.dart` (+3: the section states load before `runApp`);
  - `app_view_models.dart` (+6);
  - `night_text.dart` (`FitText`'s colours, +14/−);
  - `failure_feedback.dart` (+12, `showDone`);
  - nine new files in `lib/presentation/shared/` and `viewmodels/`.

  **Zero changes** under `lib/presentation/screens/` or `lib/presentation/widgets/`. No change to
  `pubspec.*`, `lib/data/database/`, `assets/`, `android/`, `tool/`, `analysis_options.yaml` or
  `build.yaml`.
- **Where the new components are used:** no screen imports `collapsible_section`,
  `confirmation_patterns`, `context_line`, `delete_patterns`, `detail_scaffold`, `plan_state` or
  `status_block`. Only other shared files and `app_view_models.dart` do. Adoption is Stage 6–9's,
  by design.
- **Before and after on real screens:** a throwaway probe rendered the real app (Tonight, the
  planner, the site editor, Settings, a Logbook entry; light and dark) at `38925dd` and at
  `8a6c5d8`, in scratch worktrees, with real fonts. **1.0–10.5 % of pixels differ per screen. No
  text changed and nothing was added, removed or reordered;** elements shift by a few pixels where
  line heights now follow the type scale. Three comparisons are kept, before on the left and after on the
  right: `evidence/stage5_before_after/` (`planner_light.png`, `site_editor_dark.png`,
  `settings_light.png`). The black bars in their app bars are the test engine's placeholder for a
  style that names no font; they are not in the app.
- **Probe for S5.5, through the composed graph:** two `PlannerHarness` graphs (`AppViewModels`) on
  one in-memory display store. The first opens a section; the second, "a new app start", loads as
  `main.dart` does. The section is open: **PASS**. The first run of the probe failed on the probe's
  own missing test binding; after fixing the probe it passed. `main.dart` loads the states before
  `runApp` (read: line 160).

## 3. Judgement

| # | Item | Verdict | Evidence |
| --- | --- | --- | --- |
| 1a | Tokens and components exist, tested, documented | PASS | `design_tokens_test`, `controls_theme_test`, the gallery (every component in three themes × 100/200 %, with dialogs, messages and menus), the pattern and component tests, the style-rules test (in the gate); `docs/DESIGN_SYSTEM.md` §1–§9; ARCHITECTURE B17 |
| 1b | No screen's wording or structure changed except through the theme | PASS | No diff under `screens/` or `widgets/`; the only shared presentation edits are `FitText.color`'s source (identical values since S5.4, and the neutral changed to the secondary role in S5.2) and additive helpers; the renders show the same texts and elements in the same order (a few pixels of line-height shift) |
| 1c | Nothing regressed | PASS | Gate PASS at `8a6c5d8`, including the accessibility sweep, the darkness test, the E2E and `equipment_editor_fit_test` |
| 1d | The adoption plan is complete | PASS | DESIGN_SYSTEM §9.1 (by screen), §9.2 (every S5.x part has an adopter), §9.3 (all 15 baseline entries have a removing Task); the adoption notes under the Stage 6, 8 and 9 tables |
| 1e | RD-09 recorded and built as decided | PASS | DECISIONS E.1, "RD-09 decided"; the plan's RD-09 row; `IA_WIREFRAMES.md` §3 and ADR-015 amendment notes. Built: `showUndo` for plan edits (M), `confirmDestructive` for stored records (M), `DeleteButton` with `SwipeToDelete` calling the same handler, the row springing back (S1); tests for each |
| 2 | Stage exit | PASS | As 1a |
| 3 | S5.1 | PASS | Roles AA on every surface with the 1.3× step; field roles red; the scale in all three themes; documented; gate green. The first S5.1 gate caught a light selected-segment regression, fixed and guarded by a test before commit |
| 3 | S5.2 | PASS | The gallery covers every button role, a field in each state, a dialog, a message and a menu (three themes × two scales); every component theme red or black in field mode (test); the darkness test, sweep, E2E and fit test pass |
| 3 | S5.3 | PASS | `AppWords` pinned to the glossary; the retired-terms test fails on an added term and on a stale entry (its own cases); baseline 16 in 8 files |
| 3 | S5.4 | PASS | Every `FitState` and plan state has its word and token in three themes; neutral versus error kept; mapping tested for every stored combination (legacy too); gallery at 200 % |
| 3 | S5.5 | **FAIL (S5V-01)** | The criterion reads "the state survives a restart (a test rebuilds the graph on the same store)". The committed test rebuilds a new `DisclosureViewModel` and the widget on the same store, **not the app's graph** (`PlannerHarness` / `AppViewModels`). The behaviour is correct: the probe proves it through the composed graph. The other S5.5 criteria (independent keys, a broken store logged and still working, semantics, gallery, gate) pass |
| 3 | S5.6 | PASS | Callbacks; the zone rule with and without a zone; no site, no night; the picker returns the evening, cancels to null, and is red or black in field mode without the filter; gallery |
| 3 | S5.7 | PASS | The zone rule exactly once; title and context wrap at 200 % (measured); the sample page passes the gallery in three themes |
| 3 | S5.8 | PASS | Each pattern in three themes × two scales (gallery overlays); a confirmation cannot be dismissed into a delete; the undo reports exactly one outcome (Undo, time-out, replacement, removal); red or black in field mode without the filter |
| 3 | S5.9 | PASS | Every component has an adopter; every baseline entry has a Stage; 15 sheets exist (`evidence/stage5/`, `evidence/STAGE_5_RENDERS.md`); gate green |
| 4 | The Task rules | PASS | Style-rules test; the gallery; no calculation in the new widgets (formatting only, `QuantityText`); glossary words; the one changed expectation (`fit_status_test`'s neutral, S5.2) is justified in its commit and strengthened (AA added); no dependency, schema or service; `guardStorage` in the new repository methods; one Task per commit |
| 5 | Invariants | PASS | Trap 2 (the zone rule in `ContextLine`/`DetailScaffold`); trap 11 (`DisclosureViewModel` takes the domain interface; the ViewModel rules test passes); trap 13; trap 15 (no empty catch: failures are logged); trap 17 (every `excludeSemantics` has `onTap` and `enabled`); trap 22 (nothing new leaves the device); SI-003 (`AppWords` test: no "SNR"); SI-008 (the headline shows the word alone when a duration is unknown) |
| 6 | Required evidence | PASS | The gate, reused |

## 4. Findings

### S5V-01 — BLOCKER (V4 A): S5.5's graph-level restart test is missing

- **Criterion:** S5.5's acceptance, "the state survives a restart (a test rebuilds the graph on the
  same store)". In this repository "the graph" is the composed ViewModel graph (`PlannerHarness`
  "builds the real graph"; trap 18's restart "boots a new graph").
- **Evidence:**
  - `collapsible_section_test.dart`, "it opens as the user left it after a restart", builds a
    fresh `DisclosureViewModel` directly;
  - `disclosure_viewmodel_test.dart` does the same;
  - no committed test goes through `AppViewModels` or `PlannerHarness`.
- **Impact:** none today. The behaviour is correct: the probe shows the composed graph restores
  the state, and `main.dart` loads it before `runApp`. The gap is regression protection: a change
  to the composition (another store passed, the load dropped from the harness path) would not be
  caught.
- **Proposed corrective Task S5.V1** (test-only, S): add the committed graph-level test, two
  `PlannerHarness` graphs on one display store, with the second loading as `main.dart` does. Then
  record the result and revalidate S5V-01 only (V5). No other criterion reopens (V6).

### Not blocking

- **FOLLOW-UP — TD-073** (recorded in S5.8): two existing messages with an action persist until
  dismissed under Flutter's `persist` default. The behaviour predates Stage 5, and Stage 5 did not
  cause it. Adopters are named in DESIGN_SYSTEM §9.1.
- **FOLLOW-UP — UX-39, card borders:** in field mode, cards keep the dim `border` token (`#330000`),
  while controls moved to the brighter `controlBorder`. This is S5.2's documented choice; the
  darkness test in real darkness is Stage 11's.
- **FOLLOW-UP — documentation drift outside Stage 5:** `CLAUDE.md`'s "Current Baseline" still says
  1,195 tests (stale since S3.V7; today 1,319 with 2 skips). `PROGRESS.md`'s reusable-evidence
  table is current.

## 5. Outcome

**Stage 5 does not close yet.** One narrow blocker, S5V-01, needs one committed test.

Next allowed action: **S5.V1**, then a V5 revalidation limited to S5V-01. When it passes, Stage 5
closes and Stage 6 planning is next.

## 6. The owner's question: why the debug build looks unchanged

Manually, the debug build looks almost the same as before. That is expected, for three reasons.

1. **Most of Stage 5 is not on any screen yet, by design.** Stage 5 built the shared parts and
   "changes no screen's structure or wording" (its frozen rule):
   - the status block, the plan-state label, the collapsible section, the context line, the
     detail-screen template, the confirmation, undo and success messages, and the delete
     patterns;
   - no screen imports any of them (section 2);
   - Stage 6 puts them on the planner and Tonight, and Stages 8–9 on the Logbook and the Library
     (DESIGN_SYSTEM §9).

   What exists now can be seen only in the gallery renders (`evidence/stage5/`).
2. **What does apply app-wide is the theme (S5.1, S5.2), and on most screens it is subtle.** The
   planner and Tonight set most of their own colours and sizes, which Stage 5 did not touch, and in
   light mode the primary colour those screens use for values did not change (`#37352F` before and
   after). The renders
   measure 1–10 % of pixels different per screen. Where to look on the phone:
   - **the site or rig editor in dark mode:** field lines and labels were white; they are now a
     quiet grey (`site_editor_dark.png`);
   - **Settings, "Darkness limit":** the selected segment was dark grey with black text; it is now
     light grey (`settings_light.png`). Descriptions are a lighter grey;
   - **the planner's "Save Session":** it was a pill-shaped button; it is now a flat outlined
     button with a small radius (bottom of `planner_light.png`);
   - **dialogs:** a thin border and a smaller title;
   - **dark mode generally:** body text is off-white (`#EBEBEA`), "Doesn't fit" is a lighter red,
     and titles are bolder.
3. **If even these are missing on the phone, the installed build is older than Stage 5.** A debug
   build shows these only when it is built from `49344c9` (S5.1) or later. The Android app is not
   built by the quality gate, and no device run of Stage 5 is recorded. Rebuilding from `main` and
   installing the separate `.s2check` debug package, as the project's device checks do, never the
   owner's own installed app, would show the list above. Those are device observations; the
   renders here are host evidence only.
