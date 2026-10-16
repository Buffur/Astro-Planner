# Stage 8 — Independent validation

Date: 2026-09-29. Reviewed baseline: `690b94a` (S8.9; clean working tree before validation).
Fresh session, separate from the one that built S8.1–S8.9; validation only, no application fixes.
Procedure: `prompts/INDEPENDENT_STAGE_VALIDATION.md`; `CLAUDE.md` V1–V8.

## Frozen acceptance surface

Frozen before reading the implementation, from `POST_ROADMAP_PLAN.md` ("Stage 8 — Sessions /
Execution / Actuals / Logbook": constraints and exit as amended 2026-09-27; "Stage 8 — frozen Task
sequence", S8.1–S8.9 with their rules), DECISIONS E.1 ("Stage 8 decisions": D8-1 to D8-4, I-1 to
I-10), ADR-019 §3, §3.1 and §4, ADR-014 §3 as amended, ADR-016 §4/§11 (and the retirement P8.4
asks for), ADR-018 §5 (TD-070), and the `CLAUDE.md` traps the Stage touches.

| ID | Criteria to judge |
| --- | --- |
| C | Stage constraints: run state only from the events (trap 14); snapshots immutable; one run in progress; a removed or changed workflow migrates its data without loss; no fabricated actuals (reported, or proposed from approved evidence and confirmed, else unknown); planned never becomes actual without the user; elapsed time never becomes frames; a passed night never marks a plan done; a run's events prove only what they record; ADR-019's states (Completed as planned · Partly · Not done; Old log), no new status. |
| X | Stage exit (validated against the approved lifecycle): a saved plan stays a trustworthy record of intent; an actual needs the user's confirmation or approved evidence; a result can be reported without live tracking; Completed as planned, Partly and Not done follow ADR-019; planned and actual stay distinguishable; legacy execution data stays readable; the tracker is needed nowhere; the Logbook's search and filters work together; a name stays optional; share and export stay distinct; progress comes from logged results; every existing record survives. |
| T1 | S8.1 acceptance 1–8: ended Saved entry → as planned, partly (0, fewer, more), Not done (with and without reason), no run, snapshot unchanged, replay = counters; refused before the night ends, nothing written; settle (unchanged entry + draft with every edit; second settle does nothing; unreadable keeps the row and still copies); run in progress finished with reported counts or Not done with a reason, earlier events kept; stale `expectedUpdatedAtUtc` refused; v23 → v24 keeps every row, event and counter (sessions in every status, events, legacy rows) and schema equality; export round-trips the new keys and `reported`, a pre-S8.1 file reads; CALC-44 tests pass, CALC-37/38 unchanged in value. |
| T2 | S8.2 acceptance 1–7: each outcome from the form for an ended Saved and an ended Saved · changed entry (its working copy survives as the planner's plan); the review shows the snapshot's plan after planner edits; Partly takes typed numbers per light block, as planned needs none; Back writes nothing, a stale form and a failed write change nothing and say so; no result before the night ends; the form in the accessibility sweep; the E2E passes with the form's keys. |
| T3 | S8.3 acceptance 1–6: Friday's dawn with the app open and after a restart (entry Saved on Friday, snapshot unchanged, exactly one working copy); Saved · changed moved to Saturday keeps Friday unchanged, edits in the copy; no second copy on a repeated restart, a storage failure loses nothing and retries; a never-saved past draft rolls forward, a run keeps its copy; Save before the night ends replaces the snapshot, a changed night included (D8-2); Tonight's line only when due, opens the form, gone after Save result. |
| T4 | S8.4 acceptance 1–4: no screen, route, menu item or card offers live tracking; a database with a run in progress, a completed live run with corrections and an abandoned run opens, lists, exports and backs up as before, and the in-progress run records both ways; the TD-063 regression test passes and fails on the old `openSession`; the E2E covers Save → result; the full gate passes without the dependency. Plus the A–E audit recorded, ADR-016 amendment, CALC-35/36 retired with history, UX-13/UX-26/TD-073 closed, TD-063 resolved. |
| T5 | S8.5: Upcoming/Past groups, search, filters in one panel (together and cleared, state survives navigation), delete with confirm, Progress's new place (Library entry and route gone, CALC-38 unchanged), retired terms, the sweep, the E2E's tab label. |
| T6 | S8.6: v24 → v25 migration tests; a named and an unnamed plan list, search, export and survive backup and restore; never asked at Save; not copied; not in the snapshot; the id never changes. |
| T7 | S8.7: the entry's order; each state's actions (I-6, never the tracker); Share text for completed, Partly, Not done, planned and Old log (no notes, no coordinates; D8-4); Export as file unchanged in content and distinct from Share; retired terms; the sweep. |
| T8 | S8.8: an imported rig's snapshot records its estimated and file-sourced fields per field; an old snapshot still reads; `v` stays 1; TD-070 resolved. |
| T9 | S8.9: the ENG-14 probe fails before and passes after; a round trip restores the preferences; a version 1 archive restores; a reset leaves no stale id; privacy documents checked. |
| D | D8-1 (dawn at the snapshot's limit, else the night's end, else a conservative end of the night key); D8-2 (Save before the night ends replaces the snapshot; after it Save only writes the working copy); D8-3 (Reported as planned; old estimates not relabelled; SCI-07 closed); D8-4 (Share without notes or coordinates); I-1 to I-10 as recorded. |
| I | Invariants: traps 14 (events, one transaction, replay = counters), 15 (errors through `runWithFeedback`/`AppLog`), 17 (sweep), 18 (writes report failure), 19 (E2E keys); the migration workflow (snapshot, generated steps, equality and preservation tests); export manifest v2 additive; `AppWords` and retired terms; ViewModel caps; privacy documents when something leaves the device. |
| E | Each Task's full gate after its last code change (Stage rule), plus the S8.1 and S8.6 migration tests. No device run or real-sample test is required by this Stage. |

## Evidence and judgments

**Outcome: PASS.** No V4 blocker. Three non-blocking findings (S8V-01 to S8V-03), recorded as
TD-085 to TD-087. No production code or test was changed.

**Gate reuse (V3):** full quality gate PASS on S8.9's final inputs (`690b94a`): Encoding; Format
(463 files, 0 changed); Analyze (no issues); 1,785 tests, 2 expected skips; 2 host E2E; Flutter
3.47.4. `git diff --stat 690b94a HEAD -- . ':!docs' ':!CLAUDE.md' ':!README.md'` is empty (checked
before and after the probes), so it is reused, not rerun. Each Task's commit records its own final
gate: S8.1 `ab59d21` (1,776), S8.2 `0e5b258` (1,781), S8.3 `8687def` (1,789), S8.4 `d249e16`
(1,750, the tracker's tests retired), S8.5 `477b9f7` (1,751), S8.6 `4c0505a` (1,773), S8.7 `aa0ea94`
(1,775), S8.8 `53c7c76` (1,778), S8.9 `690b94a` (1,785); each with 2 skips and 2 host E2E.

**Fresh evidence (this validation; temporary tests and mutations, run, then removed; nothing
committed to `lib/` or `test/`):**

| Probe | What it establishes | Result |
| --- | --- | --- |
| P1 | v23 → v25 through `AppDatabase`'s upgrade with a never-saved draft, a Saved row, a Saved · changed row, a completed, an abandoned and an in-progress run, and a legacy row, with blocks and events: every pre-existing column of every row, block and event is byte-equal after the upgrade; the new columns are null; replay = counters; statuses and Saved · changed read as before | **PASS** |
| P2 | S8.4 acceptance 2 on one database: an in-progress run, a completed live run with a correction after completion, and a live-abandoned run are listed (Past), offer Record/Edit result, the in-progress run is Tonight's due result; planned vs actual 7 of 24 with 1 rejected; the manifest round-trips every session and event byte-equal; a backup restored on a clean install is identical; the in-progress run then records as Partly on one copy and Not done (wind) on the restored copy, counters equal to the replay each time | **PASS** |
| P3 (mutation) | `openSession` with the re-read removed (the pre-S8.4 behaviour): `stale_detail_open_test.dart` — the "deleted meanwhile" case **fails** ("Expected: not <1>"); the "got a result meanwhile" case passes on both (S8.3's ended-plan rule also covers it, as the test's header says). Source restored with `git checkout` | Criterion met |
| P4 (mutation) | `BackupStaging.apply` without applying the staged settings: three S8.9 tests fail (round trip, ENG-14 probe, version 1 archive). Source restored | Criterion met |
| P5 | Save tapped after the saved night's dawn but before the next night check (`NightClock`'s minute tick): the ended entry's snapshot is replaced (same id, 3 → 4 blocks) | Reproduced; **S8V-01**, non-blocking (below) |

| Frozen item | Judgment | Evidence |
| --- | --- | --- |
| C: constraints | **PASS** | Counts are written only as events in `_appendEvent`, inside `_change`'s transaction, with the counters written from the same fold (`drift_session_repository.dart`); `recordResult`'s totals come from `_totals(replay)`. Snapshots are never written by `recordResult`, `settleSavedPlan` or `rename` (tests compare the JSON; P1). One run in progress: `start` still refuses a second, and the app no longer starts runs. No migration rewrites data (P1). No estimate or running-time code remains (`execution_machine.dart`, `execution_outlook.dart` removed); a passed night only changes what is current (S8.3) and leaves the entry `planned` (`saved_plan_transition_test.dart`). A new result preselects no outcome (`results_screen_test.dart`). `reported` proves only that a result was reported; its counts are `framesConfirmed`. `PlanState` gains Partly only (presentation of `completed` + `partly`); no stored status added. |
| X: Stage exit | **PASS** | Each item maps to a row below: intent (T1, T3, D8-2 and S8V-01's bounded window), confirmation (T2), no live tracking (T1, T2, T4), ADR-019 states (T1, T2), planned vs actual distinguishable (CALC-37, "Reported as planned" / "counted during a live run" wording in `EntryShareText.result` and the entry), legacy readable (P2, `session_detail_test.dart`), no tracker (T4), search + filters (T5), optional name (T6), share ≠ export (T7), progress from results (T5, CALC-38 unchanged), every record survives (P1, P2). |
| T1: S8.1 | **PASS** | `drift_session_results_test.dart` (17) covers 1–5 and 8 as written (as planned with `reported` + one `framesConfirmed` per light block; Partly 7/25 and 0; Not done with and without reason; refusal before dawn; settle, repeat, unreadable; in-progress Partly and Not done keeping `started`/`framesConfirmed`; stale refused; CALC-44 at Ljubljana, 60° N June, 89° N December, no snapshot → 00:00 UTC two days after, which is the latest possible end under ADR-007 §3). Acceptance 6: v8…v23 → v24 equality tests and a preservation test; the committed preservation test has no draft or planned row, so P1 supplies them (**S8V-03**, coverage only). Acceptance 7: the codec test and `EXPORT_MANIFEST.md` (additive, version 2). CALC-37/38 formulas untouched; notes added. |
| T2: S8.2 | **PASS** | `results_screen_test.dart` (11): run, validation, Not done; Saved before and after the night; as planned; Partly 0; Back; stale ("This entry changed since you opened it."); Saved · changed (the review shows only the saved `L` block, the planner keeps `L`+`Ha` on a copy, no dialog). A failed write: `lifecycle_matrix_test.dart` L8 (SQLITE_FULL: "Couldn't save the result", nothing written, the choice kept, a retry succeeds). The form is in the sweep (`AppRouter.results(app.running)`, three themes, 100/200 %); only its run state is swept (S8V-03). E2E in the gate. |
| T3: S8.3 | **PASS** | `saved_plan_transition_test.dart` (8) covers 1–3, 5 and 6 as written, including the restart twice and a storage failure retried; `night_rollover_test.dart` and `lifecycle_matrix_test.dart` L4 cover 4. Tonight's line reads `SessionsViewModel.dueResult` (`ResultAction.record`, newest night) with "Last night: …" or the dated form. |
| T4: S8.4 | **PASS** | `grep` over `lib` and `pubspec.yaml` finds no route, screen, menu item, card, `ScreenWake` or `wakelock_plus` left (comments only); `pubspec.lock` drops the package. P2 establishes acceptance 2 (no single committed test does: S8V-03). P3 shows the committed TD-063 test fails without the re-read. The E2E walks Save → the night (restart) → Tonight's line → result → export. Audit A–E in `ARCHITECTURE.md` (S8.4) and the commit; ADR-016 §13; CALC-35/36 marked retired with rows kept; TD-063, TD-073 resolved; lifecycle L4/L6/L8 replaced. |
| T5: S8.5 | **PASS** | `SessionsViewModel.grouped` (Upcoming = saved plans whose CALC-44 end is ahead), `searched` (name, target, site, both notes; in memory), `filter` held in the ViewModel; `logbook_screen.dart` Filters button with count, panel, Clear, `logbook.progress` row; `/sessions/progress`, no Library entry or `/library/progress`. `logbook_screen_test.dart` (5) and the updated filter/legacy/tab tests; retired-terms baseline lowered; the sweep lists `logbookProgress`. |
| T6: S8.6 | **PASS** | v25 group (every version → v25 equality; v24 → v25 preservation); `rename` trims, caps at 80, clears on empty, refuses legacy, never touches status or snapshot; the copy has no name; codec key `name`; the backup acceptance test carries a named plan; UI test (set, list, search, remove). |
| T7: S8.7 | **PASS** | `session_detail_screen.dart` order (identity, result, name, snapshot context, plan vs actual, notes, conditions, actions); actions by `ResultAction` and `isSavedPlan` per I-6, Old log Share and Export only; `EntryShareText` (pure) with `entry_share_text_test.dart` for the five states, asserting no notes and no coordinates; the export button is the unchanged one-entry manifest (`exportOne`), labelled Export as file. |
| T8: S8.8 | **PASS** | `SessionSnapshotBuilder._rig` adds `provenance` per valued spec from `groupProvenance`; `v` unchanged; `session_snapshot_builder_test.dart` +3 (imported estimates and file values, a typed rig with one unknown, an old snapshot read by `SavedPlanReader`). TD-070 resolved. |
| T9: S8.9 | **PASS** | `BackupPreferences` carries only the planning, display, active-site and first-run keys (all bool/int/double in their repositories); restore replaces them, clears plan ids; a version 1 archive keeps the device's settings and drops its active site; `confirmDatabaseReset` forgets stale ids. P4 shows the ENG-14 probe fails without the change. `docs/privacy/index.md` states that backups hold settings. |
| D: decisions | **PASS** | D8-1: `SavedNightEnd` (CALC-44) as registered. D8-2: tested before the night ends; after it the approved mechanism (minute and resume checks, S8.3's scope) leaves a window of at most one check (S8V-01). D8-3: CALC-37/38 notes; `ResultKind.asPlanned` shown as "reported as planned". D8-4: T7. I-1 to I-10 built as recorded (I-4: S8V-02). |
| I: invariants | **PASS** | Trap 14 (above); `runWithFeedback` on Save result, export, rename; `FailureText` maps `StaleResultForm` and `NightNotEnded`; the sweep and E2E in the gate; drift snapshots v24/v25, generated steps, `from23To24` rebuilding `session_events` with every row copied (P1); manifest additive; `viewmodel_rules_test.dart` in the gate (`sessions_viewmodel.dart` at 299 physical lines, under the 300 limit). |
| E: evidence | **PASS** | Every Task recorded a full gate after its last code change; the S8.1 and S8.6 migration groups are in the reused gate. No device or real-sample evidence is required by this Stage; the device rows of `TEST_PLAN.md` stay Stage 11's. |

## Findings

### S8V-01 / TD-085 — Save in the minute after a saved night ends rewrites its snapshot

**FOLLOW-UP** (not V4 A: S8.3's approved scope defines the transition as `load` plus
`followNight` on `NightClock`'s minute tick and on resume, and that mechanism is built and tested;
not B: no earlier behaviour regressed, since before S8.3 Save always rewrote a saved plan; not C:
the user's own explicit Save, no data lost).

P5: a plan saved for 10 Nov at Ljubljana, edited during the night (Saved · changed); the clock
passes CALC-44's dawn; before the next night check the user taps Save. `CurrentSession.save` →
`SessionRepository.savePlan` accepts it (`_requirePlanEditable` only), so the ended entry's snapshot
is replaced (3 → 4 blocks). D8-2 states that after its night a saved plan is never the planner's
plan, so Save writes only the working copy; here that holds from the next check, not from the
instant. Window: at most one minute with the app in the foreground across dawn.

Direction (for a later Task, not decided here): let Save run the transition first when the
current plan's saved night has ended (in the chain), or refuse `savePlan` on an ended saved plan in
the repository, with a regression test on P5's sequence.

### S8V-02 / TD-086 — The unreadable Saved · changed path (I-4) shows and times working state

**FOLLOW-UP** (the frozen text is followed: CALC-44's fallback uses "the row's evening date", and
I-4 allows only Not done).

For a Saved · changed row whose snapshot cannot be read, the row's night and blocks are the
working copy's, not the saved plan's:
- the result form's review says the saved plan "can't be read" and then lists the row's light
  blocks as "N planned", which are the working edits (`ResultsViewModel.lightBlocks` reads
  `session.blocks`);
- `SavedNightEnd.of` falls back to the latest end of the row's night key, the working night. If the
  working night was moved earlier than the saved one, the entry counts as ended, and can be
  recorded as Not done, before the saved night has ended.

Both need a corrupt or future-version snapshot plus later edits; no such row is known.

### S8V-03 / TD-087 — Three acceptance checks are established here, not by committed tests

**FOLLOW-UP** (coverage only; the behaviour passes):
- the v23 → v24 preservation test has no draft or planned row (S8.1 acceptance 6 says "sessions in
  every status"); P1 covers them;
- no committed test puts a run in progress, a corrected completed run and an abandoned run in one
  database and lists, exports and backs it up (S8.4 acceptance 2); P2 does;
- the accessibility sweep opens the result form only for a run in progress (Partly preselected);
  the Saved-plan states (no outcome yet, Not done's reason chips, the "not ended yet" text) are not
  swept.

The first TD-063 test ("got a result meanwhile") passes with or without the re-read, because
S8.3's rule already opens an ended plan as a copy; the second ("deleted meanwhile") is the
discriminating one (P3). This is disclosed in the test's header and is not a gap.

Direction: commit P1- and P2-shaped tests and add the Saved-plan result form to the sweep, in any
later Task that touches these areas.

## Handoff

**Stage 8 closes** (V7): every frozen item passes and no V4 blocker remains. Next allowed action:
**Stage 9 planning**. S8V-01 to S8V-03 are recorded as TD-085 to TD-087 and create no Stage 8
requirement. No push (RD-17); no owner decision needed.

Probes: two temporary test files (P1, P2 and P5) and two temporary one-line mutations (P3 in
`plan_lifecycle_viewmodel.dart`, P4 in `backup_staging.dart`) were run and removed or restored;
`git status` was clean afterwards and the code diff against `690b94a` empty. Documentation checks:
referenced files and IDs resolve; `git diff --check`.
