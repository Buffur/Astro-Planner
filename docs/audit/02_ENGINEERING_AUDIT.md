# 02 — Engineering and architecture audit

> **Audit stage 2.** Captured 2026-09-24 against `main` @ `becae04` (working tree clean except
> the untracked `docs/audit/`). Audit only: no application code or source-of-truth document
> was changed.
>
> **Inputs.**
>
> - `docs/audit/00_CONTEXT_BASELINE.md` **still does not exist** in the repository. The Stage 0
>   baseline from this session and `docs/audit/01_ROADMAP_COMPLIANCE.md` were used instead.
> - The source-of-truth documents listed in the brief were read.
> - The findings rest on source inspection of `lib/` and `test/`.
> - Two full test runs earlier today (896 unit/widget tests and 2 E2E, all green on the host)
>   are the runtime baseline.
> - No Android device was available.

## 0. Method and classification

- **Scope.** Only problems backed by repository evidence (a file, a symbol or a line) are
  reported. The roadmap-compliance topics already covered in 01 are not repeated, except where
  the engineering mechanism adds something new.
- **Classification.** Each finding carries one of these:

  | Classification | Meaning |
  | --- | --- |
  | CONFIRMED ISSUE | Code evidence shows the defect directly |
  | POTENTIAL RISK | The mechanism is present in code; impact depends on usage or scale not yet observed |
  | DOCUMENTED TECH DEBT | Already recorded in TECH_DEBT, DECISIONS or ARCHITECTURE; re-verified here |
  | REQUIRES VERIFICATION | The evidence points to a problem, but a runtime check or an owner ruling is needed to decide |

- **Severity** describes the impact on users or data, or the cost to future development, if the
  issue occurs:

  | Severity | Meaning |
  | --- | --- |
  | High | Data loss, or a wrong primary answer |
  | Medium | Misleading output or persistent degradation |
  | Low | Limited, recoverable or cosmetic |
  | Info | Constraint worth knowing |

  Likelihood is stated separately where it matters.

### What was checked and found sound

These points were checked against code and need no action:

- **Dependency direction:**
  - `lib/presentation`, `lib/domain` and `lib/core` import nothing from `lib/data`;
  - `lib/domain` imports no `package:flutter/` (grep);
  - no ViewModel imports I/O packages (`viewmodel_rules_test.dart:21`).
- **Composition:** one composition root (`lib/main.dart:67-114`); ViewModels receive domain interfaces only (`lib/presentation/app_view_models.dart:41-58`).
- **Persistence:**
  - every Session write is one transaction (`DriftSessionRepository._change`, `drift_session_repository.dart:310-320`);
  - execution events are append-only, with `seq` from a fold inside the same transaction and a unique `(session, seq)` index (`:194-239`; schema v17 index `session_events_session_seq`).
- **Threading:**
  - the database runs on a background isolate (`NativeDatabase.createInBackground`, `app_database.dart:536`);
  - tonight's candidates run in `Isolate.run` with plain values only (`night_conditions_viewmodel.dart:229-251`).
- **Memoization keys** use value equality where it matters: `SessionNight ==` compares the evening date, instants, coordinates and `timeContextId` (`session_night.dart:62-72`); `PlanningPreferences` has `==` (`planning_preferences.dart:281`).
- **Stale answers are dropped:**
  - weather requests carry a request counter (`night_conditions_viewmodel.dart:93-113`);
  - reverse geocoding ignores answers for a position the user has left (`site_viewmodel.dart:239-241`);
  - Nominatim calls are serialized, rate-limited and cached (`nominatim_reverse_geocoder.dart:61-104`).
- **Error mapping:** storage errors become `StorageFailure` in a single place (`storage_failure_interceptor.dart`, `storage_guard.dart`); the UI never shows raw error text (`failure_feedback.dart:8-16`).
- **Restore:** it is staged and applied before the database opens, and the old WAL and SHM are set aside (`backup_staging.dart:31-49`; `main.dart:54-66`).

---

## 1. Findings

### ENG-01 — Weather freshness is frozen at load time; nothing reloads the forecast on the clock or on resume
- **Severity:** Medium · **Classification:** CONFIRMED ISSUE (mechanism); runtime frequency REQUIRES VERIFICATION
- **Claim:**
  - The forecast's age class (`current`/`aging`/`stale`) and its "updated N min ago" text are computed once, when the forecast is loaded.
  - They are never recomputed while the app stays alive: in the foreground, or resumed from the background without being killed.
  - A night that rolls over at mean solar noon (with no picked date) also does not trigger a forecast reload.
  - So a forecast fetched in the afternoon can still read "Updated just now" (class `current`) that night.
  - That frozen class is also written into Save/Start snapshots.
- **Evidence:**
  - `NightWeatherService._available` computes `age` and `ageDuration` from `nowUtc` at load time (`lib/domain/services/night_weather_service.dart:89-100`). `NightWeatherAvailable` stores them as final fields (`lib/domain/models/night_weather.dart:44-64`).
  - `WeatherText.freshness` renders `state.ageDuration` and `state.age` as stored (`lib/presentation/shared/night_text.dart:21-28`). Used by the weather card (`weather_forecast_widget.dart:255`) and Tonight (`tonight_home_screen.dart:297`).
  - Reloads happen only from `begin()`, from `_onInputsChanged()` when the (night, lat, lon) key changes on a listener notification, and from a manual `refreshWeather()` (`night_conditions_viewmodel.dart:68-89`). The key reads `_plan.sessionNight`, which changes with the clock alone (`session_plan_viewmodel.dart:84-92`), but nothing re-evaluates it without a notification.
  - There is no lifecycle hook or timer: `grep AppLifecycle|WidgetsBindingObserver|didChangeAppLifecycleState` finds nothing in `lib`. The only `Timer.periodic` is the tracker's 30 s redraw (`execution_screen.dart:44`).
  - The snapshot persists the frozen class (`'age': w.age.name`, `session_snapshot_builder.dart:215`, and the summary `:177`).
- **Why it is a real issue:** ADR-012 §6 and CLAUDE.md say cached data is never presented as current. The freshness bands (3 h / 12 h, `night_weather.dart:18-19`) are only applied at load time. Android commonly keeps the process alive in the background, so an afternoon plan and an evening check can share one load.
- **Affected area:** weather and caching; Tonight and the planner; immutable session snapshots.
- **Requirement:** ADR-012 §6; CLAUDE.md trap 4 ("never an ad-hoc age check", "freshness only via `WeatherFreshness`").
- **Confidence:** High for the mechanism; Medium for how often it happens in the field.
- **Verification required:** a device test. Load a forecast, background the app for more than 3 h, resume: the card should show "Aging". Separately, cross mean solar noon with the app open and check the forecast reloads for the new night.

### ENG-02 — Catalog seeding swallows every insert failure, then marks the catalog as applied
- **Severity:** Medium (impact) · likelihood low · **Classification:** CONFIRMED ISSUE
- **Claim:**
  - `CatalogSeeder._insert` catches any exception and logs "Skipped".
  - `seedIfNeeded` then stores `catalogSeedVersion`.
  - A first-run insert failure caused by the store (a full disk, I/O error) therefore marks the catalog as seeded. Later launches return early and never seed again.
  - The comment in `main.dart` claims the opposite.
- **Evidence:**
  - `lib/data/services/catalog_seeder.dart:228-236` (`catch (e)` around `insertTarget`, meant for the unique-index duplicate).
  - `:225` `await prefs?.setInt(versionKey, catalog.version)` runs unconditionally after the loop.
  - `:191-192` returns early when `applied >= catalog.version`.
  - All Drift errors, including a unique violation, arrive as the same `StorageFailure` (`storage_failure_interceptor.dart:15-24`), so the catch cannot tell a duplicate from a real failure.
  - `lib/main.dart:77-80`: "a failure here is safe to retry on the next launch".
  - No catalog-seeder failure test exists (`test/data/services/catalog_seeder_test.dart` covers the asset, idempotency and upgrade, not failure).
- **Why it is a real issue:** it causes permanent, silent loss of the bundled 164-object catalog on that install. There is no reseed path in the UI. The version marker lives in SharedPreferences while the rows live in SQLite, so the two can disagree. The same split means a future database-only reset, such as the unwired `resetUnsupportedDatabaseFile`, would leave the marker and never reseed.
- **Affected area:** bootstrap and seeding; persistence consistency across two stores.
- **Requirement:** TASK 1.2 ("idempotent seeding"); CLAUDE.md trap 15 ("never swallow an error").
- **Confidence:** High for the logic; Low for the likelihood of the trigger.
- **Verification required:** a unit test that injects failing inserts and checks whether the version is stored.

### ENG-03 — Open-Meteo requests carry no identifying User-Agent
- **Severity:** Low · **Classification:** CONFIRMED ISSUE
- **Claim:** the weather request is sent with `http.Client`'s default user agent. The project rule says every third-party request carries `AppIdentity.userAgent`.
- **Evidence:**
  - `lib/data/repositories/open_meteo_weather_repository.dart:59-61` calls `_client.get(uri)` with no headers.
  - Compare `nominatim_reverse_geocoder.dart:115` (`headers: {'User-Agent': AppIdentity.userAgent}`) and `location_picker_screen.dart:132` (tiles).
  - CLAUDE.md trap 22: "Every request to a third party carries `AppIdentity.userAgent`."
- **Why it is a real issue:** it breaks an explicit project rule introduced with TASK 16.3. The service cannot identify or contact the app.
- **Affected area:** networking boundary; compliance.
- **Requirement:** CLAUDE.md trap 22; TASK 16.3.
- **Confidence:** High.
- **Verification required:** none for the code fact. Whether Open-Meteo's terms require it is an owner check (COMPLIANCE.md does not claim it).

### ENG-04 — Most ViewModel and widget tests run a persistence path the production app never uses
- **Severity:** Low · **Classification:** CONFIRMED ISSUE (testability)
- **Claim:**
  - `PlannerHarness` passes `sessions: null` by default.
  - `SessionPlanViewModel` then persists plan edits, the target and the rig to SharedPreferences (the pre-TASK 11.4 path).
  - `main.dart` always passes a `SessionRepository`, so production always autosaves to the database.
  - 24 test files build the harness without `sessionRepository:`. Their plan-edit, selection and restart assertions therefore exercise the preferences branch.
- **Evidence:**
  - The harness default: `test/support/planner_harness.dart:82,120`.
  - The branch: `session_plan_viewmodel.dart:38-40` (`_current` is null without a repository), `:55-57` ("null only in tests…"), and `:178-185` (`_edited()` writes blocks, target and rig to `_stateRepository`).
  - Production: `lib/main.dart:113` (`sessions: sessionRepo`).
  - Test files without a session repository include `planner_capture_blocks_test.dart` (TASK 4.1 reorder acceptance), `planner_selection_refresh_test.dart:204` ("a new PlannerHarness does not resurrect a deleted target/equipment id", a restart test through preferences), `planner_preferences_test.dart`, `capture_plan_widget_test.dart` and 20 more (grep: `PlannerHarness(` without `sessionRepository:`).
  - Nullable test-only types leak into the production provider tree: `ChangeNotifierProvider<ResumeRunViewModel?>`, `<BackupViewModel?>`, `<ExecutionViewModel?>`, `<ResultsViewModel?>` (`app_view_models.dart:103-111,153-156`).
- **Why it is a real issue:** passing tests over-state coverage of the production autosave path. The production path is covered separately by `planner_draft_session_test.dart`, the lifecycle matrix and E2E, but not for the specific behaviours above.
- **Affected area:** testability; state ownership.
- **Requirement:** `.agents/rules/03-testing.md` and CLAUDE.md trap 11 ("tests use `PlannerHarness` which builds the real graph").
- **Confidence:** High.
- **Verification required:** none for the fact. Whether the covered behaviours differ under the database path is unknown until the tests run with a session repository.

### ENG-05 — A draft without a site takes the UTC calendar date as its night key
- **Severity:** Low · **Classification:** CONFIRMED ISSUE
- **Claim:**
  - Without a site, `_plan()` falls back to `today`.
  - `today` is `CalendarDate.fromDateTimeFields(_clock.nowUtc())`: the UTC year, month and day.
  - It is written as the draft's `evening_date`, and `load()` compares it for the roll-forward rule.
- **Evidence:** `session_plan_viewmodel.dart:95` (`today`), `:149` (`eveningDate ?? _pickedEveningDate ?? today`), `:126` (roll-forward comparison).
- **Why it is a real issue:** CLAUDE.md trap 2 says "Never derive a night from a `DateTime`'s Y/M/D". The impact is limited: the key is corrected by the next autosave once a site exists (`_onSiteChanged`, `:170-176`), and Save/Start require a site (`:280-287`).
- **Affected area:** time handling; draft persistence.
- **Requirement:** ADR-007 §2 and §5; CLAUDE.md trap 2.
- **Confidence:** High.
- **Verification required:** none.

### ENG-06 — The same duration is formatted two ways; one ViewModel formatter is dead
- **Severity:** Low · **Classification:** CONFIRMED ISSUE
- **Claim:** planned light integration is rounded to minutes in the planner but truncated on the results page and in Sessions.
  - Example: 20 × 179 s = 59.67 min shows as "1h 0m" in the planner and "59 min" on the results page.
  - `CaptureAnalysisViewModel.totalIntegrationTime` has no caller.
- **Evidence:**
  - `formatBudgetDuration` rounds (`widgets/capture_plan/capture_budget_summary.dart:13-16`).
  - `OpportunityText.duration` truncates via `inMinutes`/`inHours` (`presentation/shared/opportunity_text.dart:9-14`), used for planned integration at `results_screen.dart:304-305` and in `progress_screen.dart`, `session_detail_screen.dart` and `execution_screen.dart`.
  - `capture_analysis_viewmodel.dart:116-119` is unused (grep: no reference outside its definition).
- **Why it is a real issue:** one quantity is shown with two values across screens. CLAUDE.md trap 13 asks for shared wording so that screens "word things the same way".
- **Affected area:** duplicated presentation logic.
- **Requirement:** CLAUDE.md trap 13.
- **Confidence:** High.
- **Verification required:** none.

### ENG-07 — Registered repository providers that nothing reads
- **Severity:** Info · **Classification:** CONFIRMED ISSUE. DOCUMENTED TECH DEBT for `AppDatabase` only.
- **Claim:** `main.dart` registers `Provider<AppDatabase>`, `<TargetRepository>`, `<EquipmentRepository>`, `<WeatherRepository>`, `<SessionRepository>` and `<LocationRepository>`. No widget or test reads any of them.
- **Evidence:** `lib/main.dart:132-137`; `grep "read<…Repository>|watch<…Repository>|Provider.of<…Repository"` over `lib` and `test` returns nothing. CLAUDE.md trap 10 documents only `AppDatabase`.
- **Why it is a real issue:** these providers put repositories within reach of any widget, against trap 11 ("screens never call a repository"). Nothing uses them today.
- **Affected area:** layer boundaries (latent).
- **Requirement:** ADR-015 / TASK 12.3 ("screens no longer call repositories").
- **Confidence:** High.
- **Verification required:** none.

### ENG-08 — Save, Start and New do not join the autosave chain, so edits can interleave
- **Severity:** Low (a lost edit in a narrow window) · **Classification:** POTENTIAL RISK / REQUIRES VERIFICATION
- **Claim:**
  - `CurrentSession.write` serializes autosaves by extending `_chain`.
  - `save`, `start` and `startNew` only `await _chain` once and never extend it.
  - An edit made while Save or Start is in flight therefore runs its `updatePlan` concurrently. Drift orders the transactions, so the final database state depends on which transaction starts first.
  - Save's plan is captured before its awaits (`c.save(_plan(), snapshot)`). If the edit's transaction runs first, `savePlan` writes the older plan over it and marks the session planned, while the UI shows the edit. A later edit repairs it.
  - The Save and Start buttons have no busy state, so a double-tap on Start runs `updatePlan` twice and then refuses the second `start` with an error message.
- **Evidence:**
  - `lib/domain/services/current_session.dart:37-40` (`startNew`), `:51-66` (`write` extends `_chain`), `:72-81` (`start`) and `:85-92` (`save`): these only `await _chain`.
  - `session_plan_viewmodel.dart:272-291` evaluates `_plan()` when Save is pressed.
  - No busy or disabled state guards the buttons (`home_screen.dart:329,351`, `tonight_home_screen.dart:386`; grep finds no `_saving`/`_busy`).
- **Why it matters:** CLAUDE.md trap 11 says every edit autosaves "through the serialized `_autosave`". Save and Start sit outside that serialization.
- **Affected area:** concurrency; state ownership; persistence.
- **Requirement:** TASK 11.4 ("force-stopping the app never loses edits"); ADR-014 §3.
- **Confidence:** Medium. The interleaving is real in code; whether the UI allows an edit inside the window is unverified.
- **Verification required:** a test that starts `save()`, applies an edit before it resolves, and checks the stored plan and status.

### ENG-09 — Unsaved drafts pile up unseen and cannot be deleted
- **Severity:** Low · **Classification:** POTENTIAL RISK
- **Claim:**
  - Every Start, New, Duplicate-for-night and open-of-a-frozen-session creates a new draft row with its blocks.
  - Drafts never saved are hidden from the Sessions list.
  - No code removes them, and no UI path can.
  - `mostRecentOpen()` loads every draft, planned and in-progress session, with all their blocks, on each start.
- **Evidence:**
  - Drafts are created at `current_session.dart:39` (`startNew`), `:45` (`adopt` copies a frozen session) and `:79` (a new draft after every Start).
  - Hidden: `SessionsViewModel.saved` filter (`library_viewmodels.dart:153`).
  - No deletion: the only delete is a user action on listed sessions (`library_viewmodels.dart:226-229`); grep finds no draft cleanup in `lib/data` or `lib/domain`.
  - The full load: `drift_session_repository.dart:484-494` via `list` (`:418-481`, blocks for all rows `:496-513`).
  - Not recorded in TECH_DEBT (grep "draft" + "accumul/orphan": no match).
- **Why it matters:** the database and the startup query grow without bound, invisibly to the user. The rows also land in backups (`file_backup_service.dart:51`).
- **Affected area:** persistence; startup performance (long-term).
- **Requirement:** none explicit. ADR-014 defines the lifecycle but no retention.
- **Confidence:** High for the mechanism; Low for impact at realistic volumes.
- **Verification required:** count draft rows after a season of use; time `mostRecentOpen()` with, for example, 500 drafts.

### ENG-10 — The weather cache in SharedPreferences is never evicted
- **Severity:** Low · **Classification:** POTENTIAL RISK
- **Claim:**
  - Each (rounded site, model, night start) forecast is stored as its own JSON entry and never removed.
  - Android SharedPreferences loads the whole file into memory.
  - TD-049 covers only the pre-TASK 9.4 keys; the current cache has the same property.
- **Evidence:** `shared_prefs_weather_snapshot_store.dart:15-38` (read and write only); the key includes the night start (`weather_snapshot_store.dart:16-23`); grep finds no `remove(` for weather keys in `lib/data`.
- **Why it matters:** the growth is unbounded and on the startup path (`SharedPreferences.getInstance`). Each entry holds about 24 hourly rows.
- **Affected area:** caching; SharedPreferences usage.
- **Requirement:** ADR-012 §6 defines freshness but no retention.
- **Confidence:** High for the mechanism; Low for impact.
- **Verification required:** measure the preferences file size after months of use.

### ENG-11 — N+1 queries in Sessions, session detail and Progress
- **Severity:** Low · **Classification:** POTENTIAL RISK (scaling; unmeasured)
- **Claim:**
  - Each Sessions-list load runs `saved()`, then `execution(id)` per completed session, then `saved()` again for the filter options.
  - `execution(id)` re-reads the session and its blocks, then its events: several queries per session.
  - Opening one session's detail calls `targetProgress()`, which folds the events of every completed session.
- **Evidence:**
  - `logbook_screen.dart:60-62`
  - `library_viewmodels.dart:141-155` (`saved`), `:159-169` (`filterOptions`), `:175-191` (`detail` → `targetProgress`), `:195-204` (`reconciliations`), `:207-224` (`targetProgress`)
  - `drift_session_repository.dart:266-271` (`execution` → `get` + `events`)
  - TASK 15.2 measured only the planner and the candidates (TEST_PLAN § 15.2)
- **Why it matters:** latency grows linearly with the logbook; the Sessions tab and detail are core-loop screens. The roadmap's 14.2 direction ("a SQL aggregate") was not followed; see 01.
- **Affected area:** performance-sensitive paths; repository boundaries.
- **Requirement:** TASK 15.2 ("smooth on low-end devices").
- **Confidence:** Medium.
- **Verification required:** time the Sessions tab and a session detail with about 200 completed sessions on a low-end device.

### ENG-12 — First-run catalog seeding is 164 individual autocommit inserts before `runApp`
- **Severity:** Low · **Classification:** POTENTIAL RISK (startup latency; unmeasured)
- **Claim:** on a fresh install, `main()` awaits 164 separate `insertTarget` calls before the first frame. There is no transaction or batch, so each insert commits on its own.
- **Evidence:** `main.dart:81-83` (awaited before `runApp`, `:129`); `catalog_seeder.dart:206-209` (loop), `:228-236` (`_insert`); `drift_target_repository.dart:51-66` (a single `insert`, no transaction; grep finds no `transaction`/`batch` in either file).
- **Why it matters:** the first launch shows only the splash until seeding ends. On slow storage, per-row commits add up. It is not measured anywhere, since there has been no device run.
- **Affected area:** lifecycle and startup; performance.
- **Requirement:** TASK 1.2 ("first screen never blocks…"); TASK 15.2.
- **Confidence:** Medium.
- **Verification required:** measure time to first frame on a clean install on a low-end device.

### ENG-13 — Diagnostics cannot be retrieved in a release build; uncaught errors bypass `AppLog`
- **Severity:** Low · **Classification:** POTENTIAL RISK (partly a documented decision)
- **Claim:**
  - `AppLog` keeps a 200-entry in-memory buffer, but nothing in the app reads it.
  - Its only other output is `dart:developer`.
  - No `FlutterError.onError` or `PlatformDispatcher.instance.onError` handler routes uncaught errors to it.
  - A beta tester's failure therefore leaves no trace the app can show or export.
- **Evidence:** `lib/core/diagnostics/app_log.dart:40-100` (`recent` getter); grep finds no reference to `AppLog.recent` in `lib` (tests only) and no match for `FlutterError.onError|PlatformDispatcher|runZonedGuarded`. ARCHITECTURE B14 and TASK 15.1 record "crash reporting deferred for privacy".
- **Why it matters:** TASK 16.4 (beta QA, triage) will need evidence. Play vitals cover crashes and ANRs only, not handled failures.
- **Affected area:** error handling and diagnostics.
- **Requirement:** TASK 15.1 ("a debug logger"); TASK 16.4 triage (future).
- **Confidence:** High.
- **Verification required:** owner decision on whether beta QA needs a local log export. Not a defect against the current scope.

### ENG-14 — A restore replaces the database but keeps preferences that point into it
- **Severity:** Low · **Classification:** POTENTIAL RISK (extends DOCUMENTED TECH DEBT TD-056)
- **Claim:**
  - A same-device restore swaps `astroplan.sqlite` but leaves SharedPreferences untouched.
  - `activeLocationId` then resolves against the restored database's ids, which may be a different site or none.
  - The transient position, first-run flag and `catalogSeedVersion` also carry over.
  - TD-056 describes only the new-phone case ("thresholds … are defaults; the active site must be picked again").
- **Evidence:** `backup_staging.dart:31-49` (only database files are swapped); `site_viewmodel.dart:107-111` (the active id is looked up in the database; a missing row leaves the default location and does not clear the stale id); TD-056 row in `TECH_DEBT.md`.
- **Why it matters:** after a restore, the planner can silently open on another saved site. The site name is shown, so it is visible, not hidden.
- **Affected area:** persistence across two stores; backup and restore.
- **Requirement:** TASK 14.4 ("a restore reproduces all sessions"); ADR-008.
- **Confidence:** Medium.
- **Verification required:** back up with site A active, restore a backup whose site ids differ, and restart.

### ENG-15 — New drafts pick M42 and the first rig automatically, without the "example" label
- **Severity:** Low · **Classification:** REQUIRES VERIFICATION (owner intent)
- **Claim:**
  - With no stored selection, `load()` picks `searchTargets('M42').first` and the first rig.
  - The seeded plan is badged "Example plan" (TASK 4.4), but these defaults are shown as the session's own target and rig, for example on Tonight's current-session row.
- **Evidence:** `session_plan_viewmodel.dart:109-114`; the M42 default dates from `66863af` (initial planner) and is not described in FEATURE_STATUS, DECISIONS or ARCHITECTURE (grep "M42" with "default/first/select": no match); TASK 4.4's `isExampleCapturePlan` covers only the blocks (`:63-75`).
- **Why it may matter:** SI-008 and TD-013 ("default presented as the user's") were resolved for the plan, not for the selection.
- **Affected area:** state defaults; honest presentation.
- **Requirement:** SI-008; CLAUDE.md trap 8.
- **Confidence:** Medium.
- **Verification required:** owner ruling on whether the default selection is intended and should be labelled.

### ENG-16 — `SessionPlanViewModel` is at 299 of 300 allowed physical lines
- **Severity:** Info · **Classification:** POTENTIAL RISK (future development)
- **Claim:** the ViewModel size gate caps files at 300 physical lines or 250 code lines. `session_plan_viewmodel.dart` has 299 physical and 229 code lines, so almost any change to it will fail the quality gate.
- **Evidence:** `test/presentation/viewmodels/viewmodel_rules_test.dart:38-53`; line counts (`wc -l` 299; 229 non-blank, non-comment).
- **Why it matters:** the next change to the planner's core ViewModel must split it, or trim documentation, first. That cost should be planned rather than discovered.
- **Affected area:** ViewModel structure; maintainability.
- **Requirement:** TASK 12.3 acceptance / AC6.
- **Confidence:** High.
- **Verification required:** none.

---

## 2. Documented technical debt, re-verified in code

| Ref | Item | Code evidence today | Status |
| --- | --- | --- | --- |
| TD-047 / 3.2 | Below-floor or newer-than-app database: no explanation and no reset path | `UnsupportedSchemaVersionException` is thrown in `onUpgrade` (`app_database.dart:263-279`) and passes the interceptor unchanged (`storage_failure_interceptor.dart:9-10`). In `main.dart` the first query (seeding) fails and is logged (`:84-85`). `StartupViewModel` then shows the generic "Couldn't load your data." with a Retry that repeats the same failure (`startup_viewmodel.dart:39-58`; `tonight_home_screen.dart:65-75`). `resetUnsupportedDatabaseFile` has no caller (`app_database.dart:540-557`). | Still open. Whether Drift's `LazyDatabase` retries the open after a failure is **REQUIRES VERIFICATION** |
| TD-037 | Static router singleton | `AppRouter.router` and `rootNavigatorKey` are `static final` (`app_router.dart:33,73`) | Open |
| TD-038 | `unawaited_futures` not enabled | `analysis_options.yaml` lists only `empty_catches`. Seven deliberate `unawaited(...)` calls exist (grep), and several fire-and-forget calls are not marked, for example `resume_run_dialog.dart:32` `loadActive()` inside a void callback | Open |
| TD-045 | Drift/domain class name collisions | `import … as domain` in `drift_session_repository.dart:6,9` and `drift_equipment_repository.dart:4` | Open |
| TD-050 / 051 / 054 | Darkness limit applied inconsistently | Tonight "Dark" row and sky card fixed at −18° (TD-051/054). The tracker's dawn countdown is also fixed at −18° (CALC-36 row, SCIENTIFIC_INTEGRITY). The optional gates have no Settings UI | Open |
| TD-056 | Preferences not in the backup | `backup_staging.dart` swaps only database files; see ENG-14 for the same-device case | Open |
| TD-049 | Legacy weather keys left behind | No cleanup code (grep) | Open; see ENG-10 for the current cache |
| TD-018 / G17 | Metadata import in the domain uses `dart:io` and `exif` | `lib/domain/services/metadata_extractor.dart:1-3`; the screen calls `image_picker` directly (`metadata_import_screen.dart:1-7`); route gated off | Open, deferred to G17 |
| TD-035 | Equipment reseeds when the table is empty | `equipment_seeder.dart:55-60` | Open |
| TD-053 | Library pages select for the current session | Matches the IA wireframe ("Rig list + selection", `IA_WIREFRAMES.md:29`) | Open (UX) |
| TD-031 | Nominatim endpoint cannot be switched remotely | `nominatim_reverse_geocoder.dart:107` is a hard-coded host | Open (owner) |
| AC5 exception | Site selection and transient position kept in SharedPreferences | `shared_prefs_planner_state_repository.dart:16-58` | Owner decision (TASK 11.4) |

---

## 3. Architecture checkpoints AC1–AC7 (engineering view)

| Checkpoint | Engineering evidence | Assessment |
| --- | --- | --- |
| AC1 — platform behind interfaces; awaitable bootstrap; no network on the startup path | `LocationService`, `ReverseGeocoder`, `DeviceTimeZone`, `ScreenWake`, `BackupService` and `SessionExporter` interfaces. `StartupViewModel.ready`. Weather waits for the first frame (`night_conditions_viewmodel.dart:68-74`). No network before `runApp` (`main.dart:44-129`). Exception: the gated metadata screen uses `image_picker` directly | **Holds** (the exception is gated and documented) |
| AC2 — no `DateTime.now()` in the domain; one night source; no astronomy in widgets | `clock_test.dart:19` passes. Astronomy imports in presentation are only in ViewModels. `DateTime.now()` in presentation is limited to date-picker bounds (`home_screen.dart:64,183`; `logbook_screen.dart:385`). **But** a UTC-date night key is used for drafts without a site (ENG-05) | **Holds, with ENG-05** |
| AC3 — migration workflow; foreign keys on; snapshot and test per bump | Snapshots v8–v17; per-version migration groups; `beforeOpen` sets `PRAGMA foreign_keys = ON` (`app_database.dart:502`) | **Holds**; the TD-047 UI gap remains |
| AC4 — pure, deterministic domain; units; thresholds from preferences; no score | The domain has no Flutter imports; thresholds come from `PlanningPreferences`; "score" appears only in "no score" comments | **Holds** |
| AC5 — immutable snapshots; nullable references; no domain state in preferences | SET NULL references; the execution-start snapshot is frozen (`drift_session_repository.dart:90-111`). **But** snapshots can persist a frozen, wrong weather age class (ENG-01). Site selection and the transient position stay in preferences (owner decision) | **Partly holds** (ENG-01; owner exception) |
| AC6 — no http, SharedPreferences, Drift or geolocator in presentation; Provider only; VMs about ≤ 250 lines | Grep is clean; no other state library; the size test passes, with `SessionPlanViewModel` at the cap (ENG-16). Repository providers are registered but unused (ENG-07) | **Holds** (ENG-07 is latent) |
| AC7 — dependency and licence audit; secrets and HTTPS; performance budgets | HTTPS only (`Uri.https` everywhere; no `Uri.http(`). No secrets in `lib` (no API keys used). No dependency-licence audit record. `sqlite3_flutter_libs ^0.6.0+eol` is still declared (0.3 holdover). Performance budgets are unmeasured on a device (ENG-11, ENG-12). One outbound request lacks the identifying user agent (ENG-03) | **Not evidenced** |

---

## 4. Summary

### Confirmed blockers

**None** at engineering level. No finding shows data loss or a wrong primary answer on the
normal path. The release blockers already recorded in 01 (no device run, no signed bundle,
policy not live) are process blockers, not engineering defects.

### Confirmed non-blocking issues

| ID | Severity | Issue |
| --- | --- | --- |
| ENG-01 | Medium | Weather freshness frozen at load time; no clock-driven or resume reload; a wrong age persisted in snapshots |
| ENG-02 | Medium impact, low likelihood | Catalog seeding swallows insert failures and still marks the catalog seeded |
| ENG-03 | Low | Open-Meteo request without the identifying user agent (CLAUDE.md trap 22) |
| ENG-04 | Low | Most planner tests use the preferences persistence path, which production doesn't use |
| ENG-05 | Low | A draft without a site takes the UTC date as its night key (CLAUDE.md trap 2) |
| ENG-06 | Low | The same duration is rounded in one place and truncated in another; a dead `totalIntegrationTime` |
| ENG-07 | Info | Unused repository providers in the widget tree |

### Potential risks

| ID | Severity | Risk |
| --- | --- | --- |
| ENG-08 | Low | Save, Start and New race with autosave; double-tap Start |
| ENG-09 | Low | Unbounded, invisible, undeletable drafts |
| ENG-10 | Low | Unbounded weather cache in SharedPreferences |
| ENG-11 | Low | N+1 queries in Sessions, detail and Progress |
| ENG-12 | Low | 164 autocommit inserts before the first frame on a fresh install |
| ENG-13 | Low | No retrievable diagnostics; uncaught errors bypass `AppLog` |
| ENG-14 | Low | A same-device restore keeps stale preference pointers |
| ENG-16 | Info | `SessionPlanViewModel` at the size-gate limit |

### Already-known / documented issues

TD-047 (with its runtime path described in §2), TD-037, TD-038, TD-045, TD-049, TD-050,
TD-051, TD-054, TD-053, TD-056, TD-018 (G17), TD-035, TD-031 and the AC5 owner exception.
All re-verified in code (§2).

### Findings that should NOT be acted on

The following were looked at and are either deliberate, documented, or have no demonstrated impact:

- **ViewModel-to-ViewModel dependencies** (Plan → Site; Conditions → Site, Plan and Settings; Analysis → all four). The accepted TASK 12.3 design (ARCHITECTURE B1). The notification fan-out was measured acceptable in TASK 15.2.
- **The single `print` in the one-time v10 orphan cleanup** (`app_database.dart:524-528`, `// ignore: avoid_print`). It runs only during a historical migration.
- **`DateTime.now()` in date-picker bounds** (`home_screen.dart`, `logbook_screen.dart`). These are UI limits, not night computation.
- **The deprecated `calculateNightTimeline` wrapper** still present (`visibility_calculator.dart:132`). Harmless, and allowed by TASK 2.3.
- **Weather requests send full-precision coordinates.** Declared in COMPLIANCE.md (Data Safety: precise location).
- **`ResultsViewModel.save` writes results and completes in two transactions.** `complete()` recomputes the totals itself, so a partial failure is recoverable by retrying.
- **Trimming comments** to keep `SessionPlanViewModel` under the gate (ENG-16): it would defeat the purpose of the gate.
- **The resume prompt's direct Finish.** Already raised as an owner question in 01; not an engineering defect.

### Areas where evidence is insufficient

- **Android runtime behaviour:** how long the process is kept in the background (ENG-01), lifecycle restore, and plugin behaviour (`file_picker`, `share_plus`, `wakelock_plus`, `flutter_timezone`, `geolocator`).
- **Drift `LazyDatabase` after a failed open:** whether it retries on the next query. This decides the Retry-loop behaviour under TD-047.
- **Real performance:** first-launch seeding (ENG-12), the Sessions list and detail at scale (ENG-11), `mostRecentOpen` with many drafts (ENG-09), and SharedPreferences growth (ENG-10). Only JIT host measurements exist, from TASK 15.2.
- **Whether the UI lets an edit land inside a Save or Start** (ENG-08).
- **Real third-party behaviour:** Open-Meteo, Nominatim and OSM tiles against live services (only fixtures and mocked clients are tested).
- **Release-build effects:** R8 minification and the `sqlite3_flutter_libs` EOL package on a real device.
- **Owner intent:** the M42 and first-rig default (ENG-15), and whether beta QA needs a log export (ENG-13).
