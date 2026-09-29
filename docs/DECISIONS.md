# AstroPlan Decisions

> **RG-08 and RG-09 decided, 2026-09-29 (Stage 7):** E2 (elevation optional, Unknown by default), S3
> (Bortle and SQM optional in one collapsed section; no automatic source), M2 (the map link to
> lightpollutionmap.app) (E.1, "RG-08 and RG-09 decided"). Documentation only.
> **RG-07 decided, 2026-09-29 (Stage 7):** T1 only: searchable aliases from the pinned OpenNGC in
> their own table and a normalised search; no new objects, no online lookup (E.1, "RG-07
> decided"). Documentation only.
> **RG-10 decided and ADR-020 accepted, 2026-09-29 (Stage 7, S7.D):** L1, D1, T0, O0, N1, H1 (E.1,
> "RG-10 decided"); ADR-020 records RG-10 and RG-11 (camera class on the rig, light-block fields,
> "Time between frames", proposals, the calibration matrix, in-camera noise reduction). ADR-009 and
> ADR-011 carry amendment pointers. Documentation only.
> **RG-11 decided, 2026-09-29 (Stage 7):** C1 (a camera class on the rig, Unknown by default; the
> example rig stays Unknown), B1, W1, F1, I1 (relabel only; no budget change), P2 (E.1, "RG-11
> decided"). Recorded in ADR-020 at S7.D. Documentation only.
> **Stage 6 corrective pass decided, 2026-09-28 (the owner):** TD-075 to TD-080 fixed before the
> Stage 6 validation as one bounded Task (S6.16); ADR-019 §6's order amended (status, context,
> target, rig, capture plan, then the opportunity analysis and the conditions); the visual finish
> of Tonight and the planner stays in Stage 6 (E.1, "Stage 6 corrective pass decided"). Pointers
> under ADR-019 §5 and §6.
> **RD-10 and RD-11 decided, 2026-09-28 (Stage 6):** O1 (usable time, then frame fill, then the name) and S9 (the gate controls in Stage 9's Settings; no S6.15) (E.1, "RD-10 and RD-11 decided"). Documentation only.
> **S6.13, 2026-09-28:** DEV-P9 resolved (Tonight's context line with the night picker, after S6.2 and S6.6).
> **RD-08 decided, 2026-09-28 (Stage 6):** T3, tracking is the rig's default with a per-plan
> override; the snapshot keeps the effective value; Unknown stays possible (E.1, "RD-08 decided").
> Built in Stage 7; S6.9 shows the effective tracking. Pointer under ADR-011 §5. Documentation only.
> **S4-DEF-04 decided, 2026-09-28 (Stage 6):** R, Discard reverts a Saved · changed plan to its saved
> snapshot (E.1, "S4-DEF-04 decided"); ADR-014 §3 gains that transition, pointer under ADR-019 §3.
> Documentation only.
> **Stages 6–11 amended after Stage 5, 2026-09-27 (the owner's planning brief):** the dedicated
> tracker leaves the target product; Stage 8 retires it after a dependency audit, keeping the data
> (E.1, "Stages 6–11 amended after Stage 5"). ADR-019 (§2, §4) and ADR-016 carry pointers. RD-12
> lapses; RD-13 narrows. Documentation only.
> **RD-09 decided, 2026-09-27 (Stage 5):** M + S1 (E.1, "RD-09 decided"); ADR-015 carries an
> amendment pointer. Documentation only.
> **Governance correction, 2026-09-27:** one canonical Verification Policy in `CLAUDE.md`
> (E.1, "One canonical Verification Policy"). Process only.
> **S4.V3, 2026-09-27:** ADR-019 §3.1 was reduced to the owner's approved decisions. S4.V2's five
> inferred rules are withdrawn and listed as Stage 6/8 design questions. A bounded-validation rule
> now applies to analysis-and-decision Stages. See E.1, "Bounded validation for analysis and
> decision Stages". Documentation only.
> **S4.V2, 2026-09-27:** ADR-019 §3.1 revised to the owner's decision on S4R-01 (R2) and S4R-02
> (D1): a saved plan's snapshot is the immutable intent for its night; results are recorded against
> it without Save plan; Stage 8 delivers the saved-plan transition at once. See E.1, "S4R-01 and
> S4R-02 decided". Documentation only, not a new code-conformance claim.
> **S4.V1 clarification, 2026-09-27:** ADR-019 §3.1 closes the saved-and-edited lifecycle gap
> from S4V-01; see E.1. Documentation only, not a new code-conformance claim.

> **Verification stamp:** conformance checked against code at commit `900b82a`
> (2026-09-20), audited 2026-09-21. Application code has since been changed by
> TASKs 1.1–1.3 (`2357755`, `2e17093`, `94acd71`, `97924a0`); Part B was not re-audited
> as a whole after them.
> **Updated 2026-09-21 (TASK 0.2):** PD-06 resolved (E.1), PD-17–PD-21 registered,
> OD-06 recorded, DEV-P3 marked resolved. **TASK 0.3:** PD-13 resolved (E.1),
> DEV-P7 marked resolved. No ADR in Part A was changed.
> **Updated 2026-09-22 (TASK 2.1, documentation only, no code changed):** ADR-007
> (SessionNight and time-zone strategy) accepted in the new Part F; PD-01 and PD-02
> resolved (E.1). The time-handling code was re-read for this task
> (`visibility_calculator.dart`, `planner_viewmodel.dart`, `altitude_chart_widget.dart`,
> `sky_darkness_widget.dart`, `home_screen.dart`, `open_meteo_weather_repository.dart`,
> `session_log.dart`) at commit `56344e2`. **TASK 2.2 (2026-09-22):** ADR-007 status
> line updated (domain part implemented). **TASK 2.3 (2026-09-22, `de1792a`):**
> ADR-007 §8/§9 implemented (typed timeline, shared sampling grid, the altitude
> chart made render-only). **TASK 2.4 (2026-09-22, `1e58fcf`):** ADR-007 §5/§6
> implemented (`PlannerViewModel.sessionNight`, `NightTimeFormatter`); PD-01/PD-02
> now fully realized in the running app, not just the domain layer.
> **Updated 2026-09-22 (TASK 3.1, documentation only, no code changed):** ADR-008
> (persistence baseline, migration workflow, provenance) accepted in Part F; PD-04
> and PD-09 resolved (E.1). Checked against `app_database.dart`, the table
> definitions, the seeders, `drift_equipment_repository.dart`, the git history of
> the schema, and the Drift 2.35.0 source, at commit `33a212b`. **TASK 3.2
> (2026-09-22, commit `3c25e8c`):** ADR-008 §2–§3 implemented; status block updated.
> **TASK 3.3 (2026-09-22, commit `e580d03`):** ADR-008 sections 4-5 implemented
> (foreign keys, orphan cleanup, equipment_profiles dropped); PD-04's E.1 entry
> and the ADR-008 status block updated. **TASK 4.3 (2026-09-22, commit `576c069`):**
> PD-06's enforcement is implemented; DEV-P1 resolved; ADR-006's conformance
> row updated to Complies. **TASK 4.4 (2026-09-22, commit `514dcc5`):** DEV-P2
> resolved for the label half (ADR-005's "must not be labeled as absolute
> SNR" is now met); ADR-005's conformance row updated to Complies. The NPF
> formula/test deviation and undocumented-assumptions parts of DEV-P2 are
> unchanged (SI-001, SI-003, SI-009) — out of this task's scope.
> **Updated 2026-09-22 (TASK 5.1, documentation only, no code changed):** ADR-009
> (capture-budget semantics) accepted in Part F; PD-08 resolved (E.1). Checked
> against `planner_viewmodel.dart`, `session_calculator.dart`, `capture_block.dart`
> and `visibility_window.dart` at commit `f8e1a98`.
> **TASK 5.3 (2026-09-22):** ADR-009 status updated. ADR-008 §3 conformance improved: migration steps now run through Drift's generated per-version `migrationSteps` (`schema_versions.dart`), so no step rebuilds against the live tables any more; the owner approved dropping `capture_blocks.gain_iso` in v11.
> **TASK 5.5 (2026-09-22):** ADR-009 status updated; an erratum corrects the E1b fit vector to match §4/§6 (no semantic change).
> **TASK 5.6 (2026-09-22):** ADR-009 marked fully implemented (G5 complete).
> **TASK 6.1 (2026-09-22, documentation only, no code changed):** ADR-010 (ephemeris approach and moving objects) accepted in Part F; PD-07 and PD-16 resolved (E.1). Checked against `astronomical_engine.dart`, `visibility_calculator.dart` and `target_selection_screen.dart` at `a61459b`.
> **TASK 6.2 (2026-09-22):** ADR-010 gained the owner's precession (formula change: J2000 → date, Meeus ch. 21) and refraction (airless + −0.833°) decisions and the Sun measurements.
> **TASK 6.3 (2026-09-22):** ADR-010 status updated (Moon model implemented).
> **TASK 6.4 (2026-09-22):** ADR-010 status updated (MoonConditions; mean-phase model deleted with a note; mean solar midnight adopted as the night-level evaluation instant).
> **TASK 6.5 (2026-09-22):** SI-001 NPF formula-change record added (E.1).
> **TASK 7.1 (2026-09-23):** ADR-007 status updated (IANA zone per site; L1 fixed for sites with a zone; zone source = the TASK 7.3 picker). Owner decisions this task: legacy Bortle 4 → NULL with a note (others kept as `legacy`); add the `timezone` package now; map/GPS positions are transient and remembered.
> **TASK 7.3 (2026-09-23):** ADR-007 status updated (zone source implemented). Owner decisions this task: add `flutter_timezone` (Apache-2.0) so the zone picker defaults to the device zone; the first run shows a site prompt instead of a silent GPS request; deleting the active site keeps its position as the transient position. Implementation choice recorded: `IanaTimeContext` loads the `latest_all` data set (link zones).
> **TASK 7.4 (2026-09-23):** PD-05 resolved (E.1): manual Bortle/SQM (A) and the external map at the site (B) now; offline dataset (C) and licensed API (D) documented as deferred; scraper removed. PD-06: the light-pollution context became visible in its scheduled phase.
> **TASK 8.1 (2026-09-23):** ADR-010 §3 implemented (moving types hidden/labelled); ADR-008 §6 target `source` column added (v13). Implementation choices recorded here: a catalog entry is a row whose source starts with `seed:` or `catalog:` (unique per catalog id); an edit that changes coordinates, size or magnitude sets source `user`, a rename keeps it; a bare RA number is hours.
> **TASK 8.2 (2026-09-23):** owner decisions: bundle the OpenNGC-derived catalog under CC BY-SA 4.0 with attribution (About page, licence page, `OPENNGC_NOTICE.txt`); scope Messier + ~55 showpieces (164 objects); on upgrade, untouched old seed rows (id and exact coordinates) are updated in place and edited rows left alone. PD-12 remains open for the release-time review of all third-party terms.
> **TASK 8.3 (2026-09-23, documentation only, no code changed):** ADR-011 (equipment model and aperture semantics) accepted in Part F of DECISIONS; PD-03 and PD-10 resolved. Owner decisions: flat profile for 1.0 (composition deferred); required focal ratio plus optional diameter in mm (N = f/D, 1 % agreement); tracking type {untracked, tracked, guided, unknown} and an optional per-rig maximum exposure; existing rows never reinterpreted, N > 32 flagged for review; the dormant catalog repository is removed in TASK 8.4.
> **TASK 8.4 (2026-09-23):** ADR-011 implemented (schema v14; unit-explicit names; bounds in `EquipmentLimits`; `resolveAperture`; tracking type; maximum exposure; review flag; dormant repository removed). Implementation choice: in the form, a diameter makes the f/ field read-only and derived, so the two cannot disagree there; the 1 % rule is enforced by `resolveAperture` for any caller.
> **TASK 8.5 (2026-09-23):** ADR-008 §6 equipment provenance implemented (schema v15; per-row `source`/`confidence` on camera modules and optical rigs). Owner decisions: drop the unverified phone seeds; label the telescope optics an example (confidence `estimated`). Implementation choice: a user edit sets `user`/`reported` only on the group (camera or optics) whose specs changed.
> **TASK 8.6 (2026-09-23):** PD-11 resolved (E.1): NPF shown for untracked and ("if untracked") unknown-tracking rigs, at the field-minimum |δ|, with a k planning setting (default 1).
> **TASK 9.1 (2026-09-23, documentation only, no code changed):** ADR-012 (weather provider, variables, alignment and staleness) accepted in Part F of DECISIONS; PD-15 resolved. Owner decisions: Open-Meteo `best_match` with the model recorded and shown; staleness 3 h / 12 h; only the chosen night's hours are used, uncovered hours shown as "no forecast". Also decided: UTC (`timeformat=unixtime`), a horizon of at most 16 days, the variable list with visibility labelled horizontal visibility (not transparency), CC BY 4.0 attribution, seeing and transparency deferred, no weather score.
> **TASK 9.2 (2026-09-23):** ADR-012 §2–§5 implemented in the data layer (snapshot, UTC parsing, best_match, night-covering request, horizon cap). Implementation choice: time strings that are not epoch seconds are rejected as malformed (they would be naive local times).
> **TASK 9.3 (2026-09-23):** ADR-012 §6 implemented (freshness constants, cache keyed by site/model/night, failure states). Implementation choices: the cache key also includes the night's UTC start (a snapshot covers one night); a cached snapshot younger than 3 h is used without a request unless refresh is forced; an aging or stale one triggers a refresh and is shown only if that fails.
> **TASK 9.4 (2026-09-23, commit `48d7a8c`):** ADR-012 §3–§5 and §7 implemented in the UI; ADR-012 is fully implemented. Owner decisions (TASK 9.4): the weather card and summary cover **sunset to sunrise** of the chosen night (the whole 24 h window, labelled, for midnight sun or polar night); values are shown **neutrally** — the undocumented 20 % / 50 % cloud colour bands are dropped, only the dew-risk flag (the user's margin) is highlighted; the **legacy weather path is removed** now. Implementation choice: changing the evening date reuses a current cached forecast instead of forcing a refresh.
> **TASK 10.1 (2026-09-23, documentation only, no code changed):** ADR-013 (imaging-opportunity semantics) accepted in Part F of DECISIONS; PD-17 resolved. Owner decisions: gates are darkness and minimum altitude, with a horizon gate reserved (no horizon data in 1.0); the Moon and cloud only annotate by default, each with an optional user gate (off; thresholds 50 %); the fixed sky warning (Moon > 0.8 or Bortle ≥ 7) is replaced by annotations in TASK 10.2. Also decided: unknown never excludes, all failing reasons listed, max altitude inside windows, no composite score (ranking by usable time only); 12 worked examples as test vectors.
> **TASK 10.2 (2026-09-23, commit `613b32f`):** ADR-013 §2–§5 implemented in the domain (CALC-33). Corrections recorded in ADR-013 §10: the sky warning is removed in **TASK 10.3** (the roadmap puts that UI change there; §6/§9 said 10.2), and V12's in-window peak is at 03:00 (04:00 is outside the half-open window). Implementation choices: a sample's state holds until the next grid instant; a window that would start on the night's last instant is not created (the previous code produced a zero-length window there); the optional gates have no Settings control yet.
> **TASK 10.3 (2026-09-23, commit `e732a0e`):** ADR-013 §3–§6 presented: the sky warning is removed (as corrected in §10), windows are listed with their annotations and every excluded period with all its reasons. No decision changed.
> **TASK 10.4 (2026-09-23, commit `6bb596f`):** owner decisions: "Tonight's candidates" evaluates **all targets** with type and own-target filters (no favourites concept added), lives on a **new screen** opened from Home, and **hides targets without a window by default** (a toggle shows them with their reason). Sorting only (ADR-013 §5); implementation choice: evaluated on a background isolate.
> **TASK 10.5 (2026-09-23, owner decision, documentation only, no code changed):** CUT for 1.0. The owner kept the ADR-013 deferral: no azimuth, horizon profile, schema change or editor now; the horizon gate (G3) stays reserved and F-17 stays Missing (a documented limitation: the minimum altitude stands in for obstructions). Group G10 is closed at 10.4; the next task is TASK 11.1 (ADR: Session aggregate, PD-18).
> **TASK 11.1 (2026-09-23, documentation only, no code changed):** ADR-014 (Session aggregate, lifecycle and snapshots) accepted in Part F of DECISIONS with an entity diagram; PD-18 resolved. Session is the aggregate root (LogbookEntry = a completed Session; ExecutionState = status + block counters + events), with nullable SET NULL references, a night key, UTC timestamps and versioned JSON snapshots; `session_logs` evolves in place. Owner decisions: completed sessions keep only results and notes editable (no reopening; Duplicate instead); the plan snapshot is refreshed on each Save and the execution-start snapshot is frozen; the planner opens the most recent open session (no id in preferences); legacy logs become completed, read-only 'legacy' sessions with no references guessed from names.
> **TASK 11.2 (2026-09-23, commit `428f673`):** ADR-014 §5 and §7 implemented (schema v16). Implementation choices: the planned count per block is the existing `frame_count` (the new counters are completed and rejected); `status` has a CHECK constraint and defaults to `draft`; timestamps are UTC epoch ms; unreadable snapshot text reads as an empty map (no known `v` → "snapshot unavailable"); the optional `@DataClassName` renames (TD-045) were not done.
> **TASK 11.3 (2026-09-23, commit `ad6609c`):** ADR-014 §3–§4 implemented in the repository and the planner's Save. Owner decisions (TASK 11.3): the Logbook lists every non-draft session and the legacy logs with a status label; Save = planned + refreshed plan snapshot; new rows write display labels into the NOT NULL pre-v16 text columns (§10 correction below).
> **TASK 11.4 (2026-09-23, commit `628fda6`):** ADR-014 §3 and §6 implemented in the planner. Owner decisions (TASK 11.4): a resumed draft whose night has passed rolls forward to tonight (a future night is kept); a saved plan edited since its last Save is listed as "Planned, unsaved changes"; New = tonight + the example plan; opening a completed or legacy session copies it into a new draft. Implementation choice: autosaves are serialized so they reach the database in edit order.
> **TASK 12.1 (2026-09-23, documentation only, no code changed):** ADR-015 (information architecture) accepted in Part F of DECISIONS with low-fidelity wireframes and a route map in `docs/IA_WIREFRAMES.md`; PD-19 and PD-14 resolved. Owner decisions: bottom navigation Tonight · Sessions · Library · Settings; the session planner is one page opened from Tonight and from Sessions; sites live in Library with rigs and targets; PD-14 = a fixed Tonight view, no customizable dashboard. Execution is a full-screen route above the tabs (G13).
> **TASK 12.2 (2026-09-23, commit `aa748e6`):** ADR-015 §2–§3 implemented (navigation shell). Implementation notes recorded in ADR-015 §7.
> **TASK 12.3 (2026-09-24, commits `6c703f3`, `03c0b34`, `64caa58`):** the planner ViewModel is split into screen-scoped ViewModels over domain interfaces: `SiteViewModel` (sites, transient position, zone, place name, sky darkness), `SettingsViewModel` (planning preferences), `SessionPlanViewModel` (the current session: night, target, rig, blocks, autosave, open/new/duplicate/save), `NightConditionsViewModel` (weather, timeline, Moon, imaging opportunity, candidates), `CaptureAnalysisViewModel` (budget, fit, fill window, capability, the Save snapshot), `StartupViewModel` (load order, bootstrap error and retry), and `GearViewModel` / `TargetsViewModel` / `SessionsViewModel` for the Library and Sessions screens. Screens no longer call repositories (DEV-A2, except the gated metadata import screen, G17). `AppViewModels` composes the graph; `main.dart` is the only place that picks implementations (DEV-A1). `PlannerViewModel` is deleted; tests build the same graph through `PlannerHarness` (`test/support/`). Moved-out domain helpers: `CurrentSession`, `SessionReferenceResolver`, `ExampleCapturePlan`, `SessionNightResolver.resolve`. The block list is exposed read-only. A test enforces no HTTP / SharedPreferences / Drift / Geolocator / data-layer import in a ViewModel and at most 250 code lines (300 physical) per ViewModel. TD-019, TD-021 and TD-044 resolved (field-mode persistence stays with TASK 12.4); TD-053 still open. No user-visible behavior change.
> **TASK 12.4 (2026-09-24, commit `3c27b15`):** semantic theme tokens and complete red field mode. `AppPalette` (a `ThemeExtension`: muted, night events, altitude chart, Bortle scale) for light, dark and field; `lib/presentation` names no colour itself — the 52 `Colors.*`/colour literals found (not the ~100 the roadmap estimated) now read `ColorScheme` or `AppPalette`. The field theme sets every `ColorScheme` role and theme colour to red or black, so dialogs, date pickers, snackbars and menus stay red. Owner decisions: (1) in field mode the whole app also goes through a red colour filter (R' = R + 0.7152 G + 0.0722 B, G' = B' = 0; Rec. 709 luma weights; pure red unchanged), covering map tiles and anything a token misses; (2) the gate is lifted in this task after the automated darkness checks, and the on-device check in real darkness is an owner checklist item. Field mode is persisted (`DisplayPreferencesRepository`, SharedPreferences) and restored before the first frame; one tap from Tonight and the planner (`FieldModeButton`) and a switch in Settings. `FeatureScope.fieldMode` is `true` (PD-06 schedule). No text under 12 sp; the section header's action keeps its 48 dp tap target. Light and dark look as before, except swipe-to-delete and the map pin now use the scheme's error colour and chart labels are 12 sp. F-46 Implemented; TD-044 fully resolved.
> **TASK 12.5 (2026-09-24, commit `b13f7c7`):** Tonight dashboard and first-run setup. Tonight shows the site and night, the night (sunset to sunrise, dark with the Sun below −18°), the Moon (% lit, when it is up), the weather (cloud range and age, or why there is no forecast) and the current session (status, target, rig or "No rig chosen", fit label with its one-line reason, usable time); each row drills down into the planner or a picker. Without a site, a site prompt replaces the night rows. No new calculations: the wording is shared with the planner (`WeatherText`, `MoonText`, `FitText` in `presentation/shared/night_text.dart`, moved out of the weather, sky and budget widgets). First run (owner decisions): a full-screen page (`/welcome`, above the tabs) with site (the location-permission rationale comes before "Use current position"), rig and target steps reusing the pickers; offered once, only on a start without a site; Skip, Done and back close it for good (`FirstRunRepository`, `TonightViewModel`). TD-054 recorded.
> **TASK 13.2 (2026-09-24, commit `14467e7`):** execution state machine and persistence (ADR-016). A pure `ExecutionMachine` (domain) validates every transition per phase (not started, running on a block, paused, finished, abandoned), folds a run's events into its state, measures running time from UTC timestamps, stamps an event taken with a clock behind the last one at that event and flags it, estimates frames (CALC-35) and detects a run past its night. Schema v17 adds the append-only `session_events` table. `SessionRepository.start` records the start on the first light block and refuses a second session in progress; `record` stores an event and its counter projection in one transaction; `complete`/`abandon` close the run with an event. A resume prompt at start (Tonight) offers keep going, pause now, finish or abandon (confirmed), flags a finished night and a clock that went back, and changes nothing without an answer. No tracking screen yet (TASK 13.3). TD-055 recorded.
> **TASK 13.3 (2026-09-24, commit `c8e2240`):** the tracking screen (`/session/:id/run`, ADR-016). The current block with confirmed and estimated counts; +1, −1, Reject, Accept estimate, Pause (plain or with a reason: clouds, wind, dew, equipment, other) / Resume, a block switcher and Finish / Abandon (confirmed) — all in the lower half, 56 dp, labelled for screen readers; countdowns to astronomical dawn, the target below its limit and moonrise; remaining window vs remaining plan (CALC-36). The tracker reads its night, target and Moon from the execution-start snapshot (`ExecutionOutlook`, pure), never from the planner. Owner decisions: Start is in the planner and on Tonight, with the same requirements as Save; after Start the planner goes on with a draft copy, and on a restart it resumes a copy when the most recent open session is running (TD-055 resolved). Tonight shows the run in progress; the resume prompt's Keep going opens the tracker. Opt-in keep-screen-on (off by default, persisted as `keepScreenOnWhileTracking`, only while the tracker is visible and a run is active) behind a `ScreenWake` interface, implemented with `wakelock_plus` 1.8.0 (BSD-3-Clause, verified on pub.dev; a screen wakelock only, no Android permission).
> **TASK 13.4 (2026-09-24, commit `c1e52ce`):** end-of-session reconciliation. A results page (`/session/:id/results`) with per-block confirmed and rejected steppers (each change a stored event), notes, optional conditions (temperature, humidity, cloud cover — empty means unknown, range-checked) and planned vs actual light integration (`SessionReconciliation`, CALC-37); Complete or Abandon. Owner decisions: the tracker's Finish opens this page and completes nothing by itself; after completion the counts may be corrected, each correction a timestamped confirm/reject event after `finished` (the only events allowed then; ADR-016 §11); Sessions shows planned vs actual integration and "Edit results" for completed sessions. `complete()` and every correction write the actual/rejected light-frame totals in the same transaction. No schema change (the condition columns existed). **Group G13 is complete.**
> **TASK 14.1 (2026-09-24, commit `e212f6a`):** Sessions list and detail. Filters by status (chips), target and site (pickers built from the saved sessions) and night date range, run in the query (`SessionRepository.list` gains `siteId`, `from`, `to`); legacy rows match a date range by their stored date and never a site or target filter, and carry a Legacy badge. Owner decisions: a tap opens the read-only detail (`/sessions/:id`); a started session shows its execution-start snapshot, a planned one its plan snapshot, labelled with when it was taken. The detail shows the night (window, zone, darkness limit, minimum altitude, usable time, windows), site (with Bortle/SQM), target, rig, budget, weather source, plan vs actual per block (CALC-37), notes and conditions, and the actions Open tracker / Edit results / Open in planner (a copy for frozen sessions) / Share. Legacy logs show their stored text only; a missing snapshot says so. Typed `SessionSnapshot` readers keep JSON out of widgets. No schema change.
> **TASK 14.2 (2026-09-24, commit `4274175`):** integration so far per target (owner: build it, although it was a roadmap cut line). `TargetProgress` (pure, CALC-38) sums confirmed light frames × exposure of completed, non-legacy sessions with a target, per filter, with the last imaged night and the session count; Library → Progress (`/library/progress`) lists every target, newest first, and a session's detail shows "This target so far". No project goals (out of scope); no schema change.
> **TASK 14.3 (2026-09-24, commit `a234ff6`):** export manifest v2 (schema in `docs/EXPORT_MANIFEST.md`). `SessionManifestCodec` (data layer) writes UTC epoch-ms instants, the night key and zone, status, the snapshots as stored, blocks with confirmed/rejected counts replayed from the events, results and conditions, and the run's event log (owner decision); it reads v1 as a legacy log and refuses unknown versions. `ShareSessionExporter` shares a `.json` file plus a text summary; owner decision: Export file on a session's detail and Export all in the Sessions app bar. Import deferred. `AppIdentity.version` stays in step with `pubspec.yaml` (tested).
> **TASK 14.4 (2026-09-24, commit `a847f87`):** backup and restore. Owner decisions: one `.astroplan` file (ZIP: header with format, schema and app version, time and session count; a consistent database copy made with `VACUUM INTO`; the v2 manifest) shared to a place the user picks; restore picked with `file_picker` 13.1.0 (MIT), checked (AstroPlan backup, header = the file's SQLite `user_version`, newer schema refused, below the v8 floor refused — older supported schemas are upgraded by the existing migrations), confirmed with a preview, staged, and applied at the next start before the database opens, the replaced database and its WAL kept as a safety copy. New dependencies `file_picker` 13.1.0 and `archive` 4.3.0 (both MIT, checked on pub.dev). Android Auto Backup: documented, not changed (owner decision). TD-056 recorded (preferences are not in the backup).
> **TASK 15.1 (2026-09-24, commits `aac1c6a`, `0854d0a`):** error handling and diagnostics — no silent failures. `AppLog` (`lib/core/diagnostics/`, pure Dart) is a local debug logger: `dart:developer` plus a bounded in-memory buffer (200 entries); nothing is written to disk or sent anywhere, and crash reporting is deferred for privacy (roadmap). It replaces every `debugPrint`, and every catch that used to swallow an error now logs it. `StorageFailure` (`lib/domain/repositories/`) is the typed failure every repository throws when its store cannot be read or written: the Drift repositories get it from one `StorageFailureInterceptor` on the `AppDatabase` connection (opening and migrations are not intercepted), the SharedPreferences repositories from `guardStorage`; domain refusals (`SessionStateError`, `ExecutionError`, `ArgumentError`) pass through unchanged. Failures become UI states: save, delete, select and export actions (rigs, targets, sites, sessions, results, Save/Start, New/Duplicate) show a message through `runWithFeedback`/`FailureText` (`presentation/shared/failure_feedback.dart`; the cause goes to the log, never onto the screen); Equipment, Targets, Sessions, session detail, Progress and Tonight candidates show `LoadFailureView` (with a retry where the page can reload) instead of looking empty, "no longer exists" or spinning forever. A failed autosave no longer leaves `CurrentSession`'s write chain failed (which silently dropped every later edit): it is kept in `writeFailure`, the next edit retries the whole plan, and the planner shows a banner. In `main.dart` a failure restoring the backup/run state no longer stops the first frame. `empty_catches` is enabled in `analysis_options.yaml`, and a source-scan test also rejects `catch (_) {}` and comment-only catches (which the lint allows). TD-029 resolved; TD-038 progress. Test baseline 857.
> **TASK 15.2 (2026-09-24, commit `2e923e6`):** performance and caching, measured first (desktop test VM, JIT): one planner rebuild read about 2.5 ms of derived values recomputed on every read (night timeline 0.2 ms, capture budget 0.25 ms, fit 0.6 ms, fill count 1.6 ms); moon and opportunity were already cached; tonight's candidates (164 catalog targets, on a background isolate since TASK 10.4) took about 95 ms. Now `NightConditionsViewModel` caches `nightTimeline` per night and `nightWeatherSummary` per (night, forecast state, dew margin); `CaptureAnalysisViewModel` caches the target's transit per (night, target position) and the budget, fit and fill count until an input notifies or the night changes (a night can roll over with the clock alone). A cached rebuild reads about 0.08 ms. No new isolates — nothing else exceeds a frame. Profile traces on a low-end device were not taken (no Android run yet): an owner checklist item in `TEST_PLAN.md`. No calculation changed. Test baseline 864.
> **TASK 15.3 (2026-09-24, commit `c191eb4`):** accessibility pass, audited first with Flutter's guideline matchers (every main screen, scrolled, in the light, dark and field themes at 100 % and 200 % text, on a 412 px-wide phone). Fixed: screen-reader labels (tooltips) on the Rigs/Targets add buttons and the capture plan's add/delete icon buttons; tap targets — the planner's Save/Start were squeezed to 40 px by the `BottomAppBar`'s fixed 80 px (now an intrinsic-height bar), the Open-Meteo attribution link and the About notice are 48 px; overflow — the sky card (it overflowed a 412 px phone even at 100 % text), the altitude-chart legend, the candidates' dropdowns, the budget lines, the fit row and the Sequence Plan header now wrap or ellipsize; a text alternative on the altitude chart (number of windows and usable time; the window list below it has the details). Focus order follows the layout (no custom traversal). Red mode: primary red on black is 5.25:1 (passes WCAG AA); the secondary red #AA0000 is 2.71:1 and stays below AA by design (dark adaptation) — documented, not changed; contrast is asserted in the light and dark themes. A TalkBack walkthrough on a device is an owner checklist item (no Android run yet). Test baseline 871.
> **TASK 15.4 (2026-09-24, commit `323cc23`) — OPEN: host rows done, device rows not run.** No Android device or emulator exists on the development machine (no AVD, SDK cmdline-tools missing, licenses not accepted); owner decision: automate every row that can run on the host, write the scripted manual matrix (`TEST_PLAN.md` § Lifecycle matrix, rows L1–L8), and keep the task open until the device rows pass. Host: `test/lifecycle/lifecycle_matrix_test.dart` — a fresh offline install with location denied; a kill while planning and during a run (file database closed and reopened: plan, night, target, site, field mode, counts and running time restored); rotation, dark mode and field mode keep typed input and every screen lays out in landscape; a site/zone change during a run leaves the tracker unchanged; a full disk while planning and tracking is reported and recovers. Found and fixed: a full disk was silent in the tracker's actions (they caught only `StateError`), keep-screen-on, Abandon on the results page, the resume prompt's Abandon/Finish/Pause, first-run Done and the field-mode toggle — all now report through `runWithFeedback`. The Android build itself has still never been run. Test baseline 878.
> **TASK 15.5 (2026-09-24, commit `4ead647`) — OPEN: host and Windows runs green, emulator run not possible here.** `integration_test/core_loop_test.dart` drives the real UI through the core loop — a site typed in the Sites editor, target and rig through the planner's pickers, the night, forecast and opportunity, Save, Start and three frames, a process death (the SQLite file closed) and a restart 45 minutes later with the resume prompt, Finish and Complete, the Sessions log and detail, and Export (the manifest v2 re-parsed) — plus the time-zone cases (a site zone different from the device zone; a run across New York's DST end, two hours of running time, UTC instants stored with the zone). Real database; the forecast, GPS, device zone and share sheet are fakes. New dev dependency: the SDK package `integration_test`. The quality gate gains an "E2E (host)" step (`flutter test integration_test -d flutter-tester`); the suite also passes as a native Windows app (`flutter run -d windows integration_test/core_loop_test.dart`) — the first native build of the app. `flutter test integration_test -d windows` fails inside flutter_tools (the `integration_test` plugin has no Windows part), not in the app. The roadmap's acceptance, green on an Android emulator, waits for a device (same blocker as TASK 15.4).
> **TASK 16.1 (2026-09-24, commits `92afaa4`, `98045f7`):** app identity (owner decisions, OD-07). Name **Astro Planner** (`AppIdentity.appName`, the one place: launcher label, every text that names the app, the user agent); Android application id **`io.github.chacha12.astroplanner`** (namespace and `MainActivity` package moved; `com.astroplan.astroplan` is gone); a simple original icon — the target's altitude arc over the horizon with its imaging window in red and a star, on night navy — as an adaptive vector icon with a monochrome layer, legacy PNGs and a 512 px store icon drawn by `tool/make_launcher_icons.py`; the Android 12+ splash and the pre-12 launch background use the same navy and icon. Kept on purpose (file formats, not branding): the `.astroplan` backup extension, the manifest's `"app": "AstroPlan"` and v1 `app_name`, the Dart package name. A preliminary web search (not a trademark clearance) found the same name in use: "Astro Planner" on Google Play (`com.astronomia.astro_planner`) and the App Store, both astrophotography planners — the owner chose it knowing this; the display name can change after publishing, the application id cannot. The Android build and install (the roadmap's test) were not run — no Android toolchain. Test baseline 881.
> **TASK 16.2 (2026-09-24, commit `09f16bf`) — OPEN: the signed bundle and the install test wait for the owner's upload key.** Release signing reads the upload key from the gitignored `android/key.properties` (Flutter's deployment guide); without it the release build falls back to the debug key with a Gradle warning (Play rejects debug-signed bundles). Decisions: R8 on for release (the Flutter plugin's default; mapping and native symbols in `BUNDLE-METADATA`); Play App Signing (Google keeps the app signing key, the owner's key is the upload key); `minSdk` 24 / `targetSdk` 36 from Flutter 3.47.4 (Play requires target 36 for new apps and updates from 31 Aug 2026); `versionCode` = pubspec's `+N`, raised for every upload. `tool/check_bundle.dart` checks a bundle before upload (16 KB ELF alignment, no debug sections, not debug-signed); `docs/RELEASE.md` is the procedure. **Verified:** `flutter build appbundle --release` built a 66.5 MB bundle — id `io.github.chacha12.astroplanner`, label Astro Planner, target 36, min 24, versionCode 1; 15 native libraries (arm64-v8a, armeabi-v7a, x86_64) all aligned to 16 KB or 64 KB, symbols stripped into `BUNDLE-METADATA`, R8 mapping present — debug-signed, since no upload key exists yet. Flutter's own symbol check fails only because SDK cmdline-tools are missing. **Correction:** TASKs 15.4/15.5 said the Android build had never run; in fact the owner built a debug APK on 2026-09-24 and the release bundle above now builds — the app has still not been installed or run on an Android device. Found: `flutter build ... --no-pub` after a debug build fails the release compile (the plugin registrant still lists the dev-only `integration_test`); release builds must run without `--no-pub`. Test baseline 889.
> **TASK 16.3 (2026-09-24, commit `2521f42`) — OPEN until the policy URL is live.** PD-12 resolved (owner decisions, DECISIONS E.1): free with no ads or subscriptions (within Open-Meteo's free non-commercial tier); GPL-3.0 confirmed; the privacy policy on GitHub Pages (`docs/privacy/index.md` → https://chacha12.github.io/astro-planner/privacy/); place-name lookups opt-in. Code: `OptInReverseGeocoder` — nothing is sent to Nominatim unless the user switches "Look up place names" on (Settings, off by default, `PrivacyPreferencesRepository`); a saved site and the default position are never looked up; the identifying user agent `Astro Planner/<version> (+<project URL>; <id>)` now goes to the OSM tiles too (the tile policy asks for a contact); the About screen states GPL-3.0 with a source link, a privacy summary and the policy link. Terms re-checked 2026-09-24 and recorded in `docs/COMPLIANCE.md` with draft Play Data Safety answers and the permission review. Remaining gap (TD-031): a user who switches place names on still uses the built-in Nominatim endpoint (no remotely switchable endpoint). Owner steps before upload: publish the policy with the contact email filled in, make the repository public, fill in the Data Safety form. Test baseline 896.
> **TASK 13.1 (2026-09-24, documentation only, no code changed):** ADR-016 (execution model under Android constraints) accepted in Part F of DECISIONS with a state diagram and kill, reboot, clock and stale scenarios; PD-20 resolved. Owner decisions: opt-in keep-screen-on (a wakelock plugin approved for 13.3); one session in progress at a time; a session still in progress after its night ends gets a resume prompt and is never auto-finished; execution events in a new append-only `session_events` table (schema v17, TASK 13.2). Progress is derived from persisted UTC timestamps; estimated frames = running time ÷ (exposure + per-frame overhead), shown as an estimate and written only when the user confirms it; foreground only; no notifications, camera control, ASCOM or INDI.
> **Stage 1 planning (2026-09-25, documentation only, no code changed, verified at `652ad80`):** RD-03 resolved, the RD-05 interim safeguard decided and RD-17 included in Stage 1 (E.1, "Stage 1 planning decisions"). No ADR changed.
> **Stage 1 closure (2026-09-26, documentation only):** the owner closed Stage 1 after a failed repeat validation (a waiver); TD-063 moved to Stage 8 (E.1, "Stage 1 closed by the owner"). No ADR changed.
> **ADR-019 accepted (2026-09-27, S4.D, documentation only):** product flow and information architecture, recording the eight Stage 4 decisions; it amends ADR-009 §2 (display), ADR-014 §3, ADR-015 §2/route map/§7 and ADR-016 (pointers under each). DEV-P9 recorded (UX-04, UX-11). New `docs/IA_WIREFRAMES_ADDENDUM.md`. No code changed.
> **RD-07 and RD-14 decided (2026-09-27, S4.R5, documentation only):** the Library manages and never changes the plan; "Plan this target"; Progress moves to the Logbook; Rig, Plan and Logbook, and the glossary as proposed (E.1, "RD-07 and RD-14 decided"). No code changed.
> **RG-05, RD-06 and RG-06 decided (2026-09-27, S4.R4, documentation only):** Tonight plan-first with a site · night context line (T1); Night & Moon and Weather detail screens, no new tab (D-b); the planner answer-first in decision order (P-1, amends ADR-015 §2); detail one tap away with factual summaries, no modes (M0; ADR-009 §2's "own line" within the budget details) (E.1, "RG-05, RD-06 and RG-06 decided"). ADR text changes are left to ADR-019; no code changed.
> **RD-05 and RD-04 decided (2026-09-27, S4.R3, documentation only):** L1 (Draft internal; "Not saved / Saved / Saved · changed"; Save explicit), Y2 (yesterday's saved plan stays on its night; the planner continues on a copy), no preselection with an empty capture plan and "Start from the example plan", U1 (Save · Discard · Cancel) (E.1, "RD-05 and RD-04 decided"). No ADR changed yet; no code changed.
> **RG-04 decided (2026-09-27, S4.R2, documentation only):** Execution's role is B, the Logbook first and the tracker optional; the post-session result is G2 (Completed as planned, Partly with numbers, Not done → abandoned with a reason); a quiet "how did it go?" line on Tonight (E.1, "RG-04 decided"). ADR-014/016 amendments are left to ADR-019 (S4.D); no ADR changed yet; no code changed.
> **Stage 3 closed; Stage 4 planned (2026-09-27, documentation only):** the final sign-off passed (`126d97f`); Stage 4's Task sequence frozen, optional owner-run tests, decisions after each research step (E.1, "Stage 3 closed; Stage 4 planning decisions"). No ADR changed.
> **Stage 3 sign-off failed (2026-09-27):** corrective Tasks S3.V7 and S3.V8 approved by the owner, with a Stage-boundary adjustment for S3.V7; S3S-03 deferred (E.1, "Stage 3 sign-off failed: corrective Tasks"). **S3.V7 done (2026-09-27):** ADR-018 note below. **S3.V8 done (2026-09-27):** ADR-018 note below.
> **Stage 3 validation failed (2026-09-26):** corrective Tasks S3.V1–S3.V5 approved by the owner (E.1, "Stage 3 validation failed: corrective Tasks").
> **Stage 3 fixes (2026-09-26):** the owner approved S3.9 (TD-068) and S3.10 (TD-069) before the validation (E.1, "Stage 3 fixes before validation").
> **S3.7 (2026-09-26):** RD-16 implemented. The import is visible as "Add from a photo" (ADR-018 §7), and the Settings viewer entry is removed.
> **Stage 3 decisions (2026-09-26, S3.D, documentation only):** ADR-018 (metadata-assisted equipment import) accepted in Part F; RG-02 decided; RD-16 resolved; RG-03 deferred (E.1, "Stage 3 decisions (S3.D)").
> **Stage 2 closed by the owner (2026-09-26):** a waiver after S2.V4/S2.V5, without a third independent validation; Stage 3 planning starts (E.1, "Stage 2 closed by the owner").
> **Stage 2 repeat validation and S2.V4/S2.V5 (2026-09-26):** the repeat validation failed (`f137409`); the owner said "Do fix". HEIF `iloc` work is bounded (TD-067); AVIF and HEIF sequences are recognised only (the S2R-02 ruling, option (a)); ADR-017 note added (E.1, "Stage 2 repeat validation: fixes and the HEIF brand ruling").
> **RG-14 decided (2026-09-26):** no proprietary RAW in Stage 2; adapters per sample later; `ExifInterface` and LibRaw rejected (E.1).
> **Stage 2 format priorities (2026-09-26):** ADR-017 amended (§8 superseded by §13; layering); RG-14 registered (E.1, "Stage 2 format priorities and metadata layering").
> **Stage 2 decisions (2026-09-26):** ADR-017 accepted; PD-21 resolved; RD-16 resolved for Stage 2 (E.1, "Stage 2 decisions: RG-01, PD-21, RD-16").
>
> Structure:
> - **Part A** — accepted ADRs and pending decisions, preserved **verbatim** from
>   the Phase 0 baseline. Nothing in Part A has been edited or re-interpreted.
> - **Part B** — conformance audit: which decisions the implementation follows and
>   the **IMPLEMENTATION DEVIATIONS** where it does not.
> - **Part C** — owner directives recorded from this reconciliation.
> - **Part D** — behaviors *inferred* by the previous audit (not ADRs), corrected.
> - **Part E** — open decisions register (**Proposed / Pending — not accepted**).
> - **Part F** — ADRs accepted after the Phase 0 baseline (ADR-007 onwards).

---

# Part A — Accepted decisions (Phase 0 baseline, preserved verbatim)

*Source: `git show 900b82a:docs/DECISIONS.md` (the order of sections, including
"Pending Decisions" preceding ADR-006, is kept as committed).*

This file records architectural and product decisions that affect future work.

## ADR-001: Use Flutter And Dart

Status: accepted

AstroPlan uses Flutter and Dart for a single cross-platform application codebase
with Android as the initial target and iOS as a future target.

## ADR-002: Use Provider And ViewModels

Status: accepted

AstroPlan starts with Provider and explicit ViewModels. Additional
state-management frameworks require a documented need and project-owner
approval.

## ADR-003: Use SQLite Via Drift

Status: accepted

AstroPlan uses SQLite for durable local storage and Drift for typed queries,
migrations, relationships, and testability.

## ADR-004: Keep AstroPlan Out Of Planetarium Scope

Status: accepted

AstroPlan is a planner and logbook. Full planetarium, AR sky navigation,
embedded Stellarium, live camera preview, and camera control are out of MVP
scope unless explicitly approved.

## ADR-005: Treat Scientific Calculations As Auditable

Status: accepted

Scientific and astrophotography calculations must document units, assumptions,
valid ranges, references, and tests. Relative stacking gain must not be labeled
as absolute SNR.

## Pending Decisions

- Whether to normalize the current flat equipment table into Device,
  CameraModule, and OpticalRig immediately or through a staged migration.
- Which astronomical engine/library/reference to use for future ephemeris work.
- How to store provenance for seeded target and equipment data.

## ADR-006: Hide Implemented Future-Phase Features Until Approval

Status: accepted

Several later-phase features already exist in source code. To avoid destructive
rollback while restoring roadmap discipline, they are hidden behind
`FeatureScope` gates until their phases are explicitly approved.

Initially disabled gates:

- field mode;
- light-pollution context and external map handoff;
- metadata import;
- logbook UI and save action.

---

# Part B — Conformance audit (2026-09-21)

Status vocabulary: **Implemented / Partial / Broken / Missing / Deprecated /
Unknown** (see `docs/FEATURE_STATUS.md`). "Complies" = verified in code.

| ADR | Decision | Conformance | Detail |
| --- | --- | --- | --- |
| ADR-001 | Flutter and Dart | **Complies** | Flutter 3.47.4 / Dart 3.13.3. Android configured; iOS scaffold only (no location/photo usage strings); web/desktop folders are unverified scaffolds |
| ADR-002 | Provider and explicit ViewModels | **Partial** | Provider + `ChangeNotifier` only, no other framework. But only two ViewModels exist, one of which (`PlannerViewModel`) owns everything, and several screens bypass ViewModels — DEV-P5 → DEV-A1, DEV-A2 *(Updated 2026-09-24, TASK 12.3: screen-scoped ViewModels replace `PlannerViewModel` and reachable screens no longer bypass them; conforms except the gated metadata import screen, G17.)* |
| ADR-003 | SQLite via Drift ("typed queries, migrations, relationships, and testability") | **Partial** | Drift is used correctly for typed queries. Migrations are untested and one path fails; relationships are declared but not enforced — DEV-P4 → DEV-D1, DEV-D6 |
| ADR-004 | Out of planetarium scope | **Complies** | No planetarium, AR, embedded Stellarium, camera preview or camera control exists |
| ADR-005 | Scientific calculations are auditable; relative gain not labeled SNR | **Complies** *(label, TASK 4.4; the rest verified S1.15)* | DEV-P2 (resolved) |
| ADR-006 | Hide implemented future-phase features behind `FeatureScope` until approved | **Complies** *(TASK 4.3)* | DEV-P1 (resolved) |

## DEV-P1 — ADR-006 gating is only partly implemented
- **Intended behavior:** later-phase features already in the code are hidden behind
  `FeatureScope` gates — field mode; light-pollution context and external map
  handoff; metadata import; logbook UI and save action — until their phases are
  explicitly approved.
- **Actual behavior (historical)** (`lib/core/config/feature_scope.dart`,
  `lib/presentation/navigation/app_router.dart`, `home_screen.dart`,
  `sky_darkness_widget.dart`):
  - `fieldMode = false` was **defined but never read**; the field-mode toggle was live
    in Home's app bar.
  - `lightPollutionContext = false` gated only the Bortle badge. The **external map
    handoff card was ungated** and opened a URL with hard-coded Slovenia coordinates;
    `_fetchBortle` still runs on every location change.
  - `metadataImport = true` and `logbook = true`: the routes were enabled with no
    recorded approval (ADR-006 lists both as initially disabled).
  - Home's app-bar buttons pushed `/logbook` and `/metadata` unconditionally, so
    switching either gate off would have navigated to a route that did not exist.
- **RESOLVED 2026-09-22 (TASK 4.3, commit `576c069`; suite 201/201).**
  `FeatureScope.metadataImport` now reads `false`, matching ADR-006/PD-06
  (`fieldMode`/`lightPollutionContext` were already correctly `false`). Every entry
  point reads `FeatureScope` directly: Home's field-mode toggle, Import Metadata
  button and light-pollution map card are each wrapped in `if (FeatureScope.*)`,
  the same pattern `app_router.dart`'s route registration and
  `sky_darkness_widget.dart`'s Bortle badge already used. Verified by tests that a
  gated feature has no icon, tooltip, card or route.
- **Consequence (historical, now resolved).** The scope discipline the ADR was
  written to provide was not enforced; features from Phases 11–15 were
  user-visible with no record of approval (open decision PD-06, resolved E.1).
  TD-014.

## DEV-P2 — ADR-005 is not met (label half resolved TASK 4.4)
- **Intended behavior:** calculations document units, assumptions, valid ranges,
  references and tests; "Relative stacking gain must not be labeled as absolute SNR."
- **Actual behavior (historical):** the UI label was `Stacking Gain (Relative SNR)`
  (`capture_plan_widget.dart:215`, restored on purpose in commit `1baa514`).
- **RESOLVED 2026-09-22 (TASK 4.4, commit `514dcc5`), label only:** the label now
  reads "Relative stacking gain (√N vs one frame)"; the string "SNR" no longer
  appears anywhere in `lib/`. `optical_calculator.dart`'s doc comment already
  correctly described the metric as relative gain.
- **Still open (unchanged by TASK 4.4):** the NPF formula deviates from the
  published one and its test is circular; assumptions and references are mostly
  undocumented. Details: `docs/SCIENTIFIC_INTEGRITY.md` SI-001, SI-003, SI-009.
  TD-007, TD-036.
- **Correction and closure (S1.15, 2026-09-25; audit 01 TASK 4.4, 06 §2):** the
  sentence above that "SNR" no longer appears in `lib/` is not accurate: it appears in
  four doc comments, which either say the value is *not* an SNR or cite the SNR rule (`capture_block.dart`,
  `capture_budget_calculator.dart`, `optical_calculator.dart`,
  `capture_analysis_viewmodel.dart`); no user-facing text says SNR. The items still
  open then are resolved: the NPF formula follows Michaud with independent tests
  (TASK 6.5, SI-001), the √N assumptions are in the help text (TASK 5.6, SI-003), and
  the astronomy simplifications are documented and reference-tested (TASK 6.2,
  SI-009). **DEV-P2 is resolved.**

## DEV-P3 — No active roadmap phase is declared
- **Intended behavior:** "The active phase is the only approved scope unless the
  project owner explicitly approves a change" (`docs/ROADMAP.md`;
  `.agents/rules/00-project-governance.md`: "Treat the roadmap phase as the active
  scope").
- **Actual behavior:** the roadmap never names the active phase. The code contains
  work from Phase 10 (weather), 11 (light pollution — broken), 12 (metadata import),
  13 (logbook), 14 (export manifest) and 15 (field mode) while the Phase 4–9
  foundations (database, calculation engine, visibility, session planner) have the
  defects listed in this repository. The gate set in ADR-006 implies phases up to 10
  were treated as approved.
- **Consequence:** there is no authoritative basis for deciding what is in scope. The
  owner must declare the active phase (PD-06). TD-041.
- **Status: RESOLVED 2026-09-21 (TASK 0.2).** The owner adopted
  `docs/MASTER_ROADMAP.md` as the approved scope (OD-06) and decided PD-06 (E.1).
  The Phase 0–16 text above and in `docs/ROADMAP.md` is unchanged design intent. The
  *code* still shows the ahead-of-phase features ungated; that part is DEV-P1 / TD-014
  and stays open until TASK 4.3.

## DEV-P4 — ADR-003: migrations, relationships and testability
See DEV-D1 and DEV-D6 in `docs/DATA_MODEL.md` (no migration tests; v3 → v9 fails;
foreign keys not enforced).

## DEV-P5 — ADR-002: explicit ViewModels
See DEV-A1 and DEV-A2 in `docs/ARCHITECTURE.md` (one god ViewModel; screens bypass
ViewModels). *Both resolved 2026-09-24 (TASK 12.3); DEV-A2 except the gated metadata
import screen (G17).*

## DEV-P6 — PRODUCT_SPEC MVP scope not fully met
- **Intended behavior** (`docs/PRODUCT_SPEC.md` MVP Scope): equipment profiles with
  device, camera module, sensor, optics **and tracking**; saved locations;
  astronomical timeline with **moonrise, moonset**, phase and illumination;
  **Moon–target separation**; a curated target catalog; planner with feasibility;
  weather with provider-isolated variables; metadata import "where file-format
  behavior has been experimentally verified"; storage estimates distinguishing
  theoretical payload from empirical size; NPF labeled as a recommendation.
- **Actual behavior:** tracking state is stored but not exposed; saved-location
  management has no UI; moonrise/moonset and Moon–target separation do not exist;
  the catalog has 5 objects; no real sample files exist to verify metadata import;
  only the empirical storage figure exists (and shows 0.0 MB when unknown); NPF is
  not surfaced (and its formula deviates).
- **Consequence:** the MVP as specified is incomplete; see `docs/FEATURE_STATUS.md`
  for the per-feature status.

## DEV-P7 — Phase 0 deliverable `GEMINI.md`
- **Intended behavior:** `docs/ROADMAP.md` Phase 0 lists `GEMINI.md` as a deliverable.
- **Actual behavior:** `GEMINI.md` is listed in `.gitignore` and does not exist in
  the working tree; `CLAUDE.md` now serves as the agent-instruction document.
- **Consequence:** the Phase 0 exit criterion "AI rules exist" is met by
  `.agents/rules/` and `CLAUDE.md`, but the listed file is absent. Owner decision
  PD-13.
- **Status: RESOLVED 2026-09-21 (TASK 0.3).** The owner decided to drop `GEMINI.md`
  as a deliverable (PD-13, E.1). `CLAUDE.md` is the agent-instruction file, and the
  `GEMINI.md` ignore rule was removed (commit `714426d`). The Phase 0 deliverable
  list in `docs/ROADMAP.md` is annotated as amended; its original text is kept.

## DEV-P8 — The testing rule cannot currently be satisfied literally
- **Intended behavior:** `.agents/rules/03-testing.md`: "Run `flutter analyze` and
  `flutter test` before claiming a change is complete."
- **Actual behavior:** `flutter analyze` is clean, but `flutter test` exits non-zero
  because `test/integration_flow_test.dart` fails (pre-existing; root cause in
  TD-003).
- **Consequence:** until TD-003 is fixed, agents must report the failure as
  pre-existing and confirm that no *additional* test fails (recorded in `CLAUDE.md`).
- **Status: RESOLVED 2026-09-21 (TASK 1.1, commit `2357755`).** TD-003 is fixed and
  `flutter test` is green (73/73, three consecutive runs), so the rule can be
  satisfied literally again. Any failing test is now a regression; `CLAUDE.md` was
  updated.

## DEV-P9 — ADR-015's wireframes: the planner shows no state, and Tonight has no night picker
- **Intended behavior:** `IA_WIREFRAMES.md` §4 (ADR-015):
  - the planner's app bar reads "M42 · Fri, Nov 13 · Draft ⋮";
  - Tonight's header has a night picker ("Ljubljana ▾ · Fri, Nov 13").
  ADR-019 §5–§6 keeps both, with the state words of §3 and a shared site ▾ · night ▾ context line.
- **Actual behavior:**
  - the planner's title is "Session planner", with no target, night or state
    (`home_screen.dart:47`; UX-04);
  - the night is chosen only in the planner's third section, and Tonight's "Night of …" row opens
    the site picker (`tonight_home_screen.dart:142–166`; UX-11).
- **Consequence:**
  - the user cannot see whether the plan being edited is saved, or for which night;
  - planning another night from Tonight takes about five taps and scrolling (S4.R1 §4).
- **Status:** open. Recorded 2026-09-27 (S4.D). It is resolved when Stage 6 builds ADR-019 §5–§6.
  **First half built 2026-09-27 (S6.2):** the planner shows the target, the night and the plan's
  state in a strip under its app bar (titled "Plan"), with New plan, Copy to another night and
  Track live in ⋮. The strip sits under the bar, not in its title, because an app bar's title
  cannot wrap at 200 % text (the reason S5.7's detail header gave). The planner's context line
  (S6.6) and Tonight's night picker (S6.13) remain.
  **Resolved 2026-09-28 (S6.13),** with S6.2 and S6.6: the planner's context line (S6.6), and
  Tonight's site ▾ · night ▾ context line, whose night picker changes the current plan's night
  (UX-11). The planner's state is in the strip under its bar rather than in the title (above).

---

# Part C — Owner directives recorded (2026-09-21)

These are instructions given by the project owner in this reconciliation task, not
ADRs. They are recorded so later agents do not undo them.

| ID | Directive |
| --- | --- |
| OD-01 | The code is the source of truth for the **actual** state; design intent is preserved separately and never rewritten to match the code. |
| OD-02 | Source-of-truth documents **must be tracked by Git** (`CLAUDE.md`, `docs/PROJECT_HANDOFF.md`, `ARCHITECTURE.md`, `FEATURE_STATUS.md`, `DATA_MODEL.md`, `TECH_DEBT.md`, `DECISIONS.md`, `PROJECT_AUDIT.md`). The `.gitignore` rules that ignored them were removed. |
| OD-03 | Do not implement `SessionNight` or add new features until the documentation is reconciled and the Master Development Roadmap exists. *(Condition met 2026-09-21: the docs are reconciled and committed, and `docs/MASTER_ROADMAP.md` exists. Work order is now governed by OD-06.)* |
| OD-04 | Do not fix application code or scientific issues during documentation reconciliation; record them only. |
| OD-05 | Do not hide identified issues; do not label a feature "implemented" if it does not work, nor "missing" if it exists in code. |
| OD-06 | `docs/MASTER_ROADMAP.md` is the approved primary plan and the only approved scope (adopted 2026-09-21, TASK 0.2). Work proceeds in stages: **one roadmap TASK per cycle**, in roadmap order, as READ → VERIFY → PLAN → IMPLEMENT → TEST → REVIEW → COMMIT → STOP. Never start the next task on the agent's own initiative; do not change the roadmap without owner approval. Do not re-audit the whole repository; inspect the code only as far as the current task needs. |
| OD-07 | **App identity (TASK 16.1, 2026-09-24).** The app is called **Astro Planner**; its Android application id is **`io.github.chacha12.astroplanner`** (the reverse of the owner's GitHub Pages domain `chacha12.github.io`; the owner owns no other domain) — permanent from the first Play upload; the icon is a simple original one made in the repository (replaceable without code changes). Known risk, accepted by the owner: a preliminary web search (not a trademark clearance) found "Astro Planner" already used by an astrophotography app on Google Play (`com.astronomia.astro_planner`) and the App Store, "AstroPlan" by an iOS/Mac astrophotography planner, and "AstroPlanner" by iLanga's desktop software. A formal trademark search (USPTO, EUIPO) is the owner's to commission before an upload; the display name can change later, the id cannot. The GitHub handle `chacha12` is taken from the local git user; the owner should confirm it is their GitHub account before the first upload. |

---

# Part D — Behaviors inferred by the previous audit (not ADRs), corrected

The previous audit's `DECISIONS.md` listed the following as "decisions", noting they
were "inferred from the implementation". They are **not** approved decisions. Their
verified status:

| Previous statement | Verified status |
| --- | --- |
| Complement, not replace Stellarium (product) | **Consistent with ADR-004** |
| "The `SessionCalculator` strictly compares available darkness against capture block times plus a 15 % overhead" | **Incorrect.** The 15 % model is in `estimateTotalDuration`, which nothing calls. The live path is `PlannerViewModel.estimatedRequiredTime` (all frame types plus a flat 5 s per frame) compared with the visibility windows by `SessionCalculator.calculateFeasibility` |
| Storage uses empirical average RAW size | **True as implemented**, but PRODUCT_SPEC also requires distinguishing theoretical payload; seeds still carry no size, but as of TASK 4.4 the UI shows "Unknown" rather than a fabricated `0.0 MB` (SI-008, SI-013) |
| Relative gain presented as a statistical metric "explicitly avoiding … absolute SNR" | **True as of TASK 4.4.** The metric, doc comment and UI label are now all consistent (DEV-P2 label half resolved) |
| Flutter / Provider + ChangeNotifier / Drift | **Consistent with ADR-001/002/003** |
| Open-Meteo weather (no key) | **Implementation choice, consistent with ROADMAP Phase 10 ("initially using Open-Meteo")**; not an ADR |
| Nominatim reverse geocoding | **Implementation choice**; lives in the ViewModel (DEV-A1) |
| Offline-first: "external APIs use caching or are non-blocking" | **Partial.** Weather is cached, but startup awaits it (DEV-A5); light pollution never works |
| Astronomy calculated natively, "maintaining scientific accuracy" | **Overstated.** Adequate for planning; simplifications undocumented (SI-009) |
| UTC internally, local time in the UI | **Only partly true.** Mixed time bases produce a wrong default night (SI-010) |
| Configurable minimum altitude, default 20° | **Configurable in the ViewModel only**; no UI control (SI-006) |

---

# Part E — Open decisions register (Proposed / Pending — **NOT accepted**)

Nothing below is approved unless its row is marked **RESOLVED** (recorded in E.1).
Recommendations are proposals from the audit. Decisions that block the Master
Development Roadmap are marked **[roadmap-blocking]**. PD-17–PD-21 are placeholders
registered by TASK 0.2; each is decided in its own ADR task in `docs/MASTER_ROADMAP.md`.

| ID | Decision needed | Evidence | Options | Recommendation (proposal) | Blocks |
| --- | --- | --- | --- | --- | --- |
| PD-01 ~~[roadmap-blocking]~~ **RESOLVED 2026-09-22** | Session-night semantics and the default night rule | SI-010, TD-001 | (a) current night if the Sun is below −0.833°, otherwise the upcoming night; (b) always the next evening; (c) explicit date only with a "Tonight" button | **Resolved — see E.1 and ADR-007 (Part F):** civil evening date at the site; mean-solar-noon window; default = the window containing *now* (the roadmap rule, not option (a)). (Original proposal: (a): a site-local solar noon-to-noon window; the date picker means "the night beginning that evening". Proposed first implementation task once the roadmap is approved.) | Capture planner, Imaging Opportunity, weather alignment |
| PD-02 ~~[roadmap-blocking]~~ **RESOLVED 2026-09-22** | Site time-zone strategy | SI-010, TD-020 | (a) device zone (status quo); (b) provider offset stored per site (online); (c) bundled time-zone database + coordinate lookup (offline); (d) compute in solar/UTC time, display in a labelled zone | **Resolved — see E.1 and ADR-007 (Part F):** (d) now — compute in UTC through a `SiteTimeContext` seam with a mean-solar fallback; the site's IANA zone and the `timezone` package arrive in TASK 7.1, where (b)/(c) are evaluated as the zone source. (Original proposal: compute in UTC/solar time (no zone needed); choose the display zone explicitly; evaluate (d) with (b) as offline-first, (c) if civil clock times are required. DST must be tested.) | Weather alignment, log display, remote-site planning |
| PD-03 **RESOLVED 2026-09-23** | Equipment model direction (extends the Phase 0 pending decision "normalize … immediately or through a staged migration") | DEV-D2 | (a) keep the flat projection over 1:1:1 storage; (b) expose composition (reusable camera modules and rigs, tracking state); (c) collapse to flat | Decide before further equipment work; (b) matches the Phase 4 intent | Equipment UI, catalog work |
| PD-04 ~~[roadmap-blocking]~~ **RESOLVED 2026-09-22** | Persistence baseline and migration strategy | DEV-D1, DEV-D6, TD-004/005 | (a) repair the v5 step and test every upgrade path; (b) declare v9 the floor (no installs below v8 exist), drop legacy steps, add Drift schema snapshots + migration tests, enable foreign keys, retire the orphan table; (c) recreate the database | **Resolved — see E.1 and ADR-008 (Part F):** (b), with the floor at **v8**. (Original proposal: (b) **if** the owner confirms no external installs — destructive steps need explicit approval (Migration Rules).) | Any schema change |
| PD-05 **RESOLVED 2026-09-23** | Light-pollution / Bortle source and the "unknown" policy | SI-007, TD-006 | (a) manual Bortle/SQM entry with an unknown state; (b) offline artificial-sky-brightness dataset (licence and size to be evaluated); (c) keyed API (needs secret handling, rule 15); (d) keep scraping (not recommended) | (a) now, (b) later; remove the scraper | Phase 11 |
| PD-06 ~~[roadmap-blocking]~~ **RESOLVED 2026-09-21** | Declare the active roadmap phase; approve or gate the implemented-ahead features (field mode, light-pollution context, metadata import, logbook, export) and how gates are enforced | DEV-P1, DEV-P3, TD-014, TD-041 | Approve and document each, or hide them; enforce gates in routes **and** buttons | **Resolved — see E.1.** (Original proposal: owner declares the active phase; align `FeatureScope` with approvals.) | The whole roadmap |
| PD-07 **RESOLVED 2026-09-22** | Ephemeris / astronomical engine (Phase 0 pending decision) | SI-002, SI-009, SI-012 | Keep hand-written code (documented and validated); truncated series (Meeus) in-house; adopt a package | **Resolved — see E.1 and ADR-010:** in-house Meeus ch. 47 with the full tables. (Original: decide with the Moon-geometry requirement.) | Moon services, moving objects |
| PD-08 ~~[roadmap-blocking]~~ **RESOLVED 2026-09-22** | Capture-budget model: what counts against the night window; overhead model; calibration-frame policy | TD-022, DEV-A4 | Lights only vs all frames; per-frame vs per-N-frames vs per-filter-change vs per-hour overheads; darks/bias off-night, flats at twilight | **Resolved — see E.1 and ADR-009 (Part F).** (Original: owner product decision; configurable overhead.) | Capture planner (central component) |
| PD-09 **RESOLVED 2026-09-22** | Provenance storage (Phase 0 pending decision) | DEV-D5 | Per-row source columns vs a `data_sources` table; confidence field | **Resolved — see E.1 and ADR-008 §6:** per-row `source` + `confidence`, added by the owning tasks. (Original: decide with PD-04.) | SI-011, SI-007 fixes |
| PD-10 **RESOLVED 2026-09-23** | Aperture semantics, field naming and migration policy for user-entered rows | SI-005 | `focalRatio` and/or `apertureDiameterMm`; explicit unit suffixes | Owner decision; no silent guessing of existing rows | Equipment fixes, NPF |
| PD-11 **RESOLVED 2026-09-23** | Whether and how NPF is surfaced; default K | SI-001 | Hide; show as a labelled recommendation for untracked exposure; K = 1 or parameter | Not before the formula fix and independent tests | UI |
| PD-12 **RESOLVED 2026-09-24** | Licence intent (repository is GPL-3.0) and third-party terms (Open-Meteo, Nominatim, OSM tiles) for distribution | TD-031 | Confirm GPL-3.0; review store distribution and commercial-use terms | Owner decision before any release | Release |
| PD-13 **RESOLVED 2026-09-21** | `GEMINI.md` deliverable / agent-instruction file policy | DEV-P7 | Restore as tracked; drop from roadmap deliverables; keep ignored | **Resolved — see E.1.** (Original: owner decision.) | — |
| PD-14 **RESOLVED 2026-09-23** | "Custom Dashboard" scope | Listed by the previous audit as a next step; absent from PRODUCT_SPEC and ROADMAP | **Resolved by PD-19 / ADR-015:** a fixed Tonight view, no customizable dashboard | — | UI roadmap |
| PD-15 **RESOLVED 2026-09-23** | Weather provider/model and date alignment | TD-017 | Keep `icon_seamless`; make the model configurable; fetch by session date within the provider horizon | Decide with PD-02 | Phase 10 |
| PD-16 **RESOLVED 2026-09-22** | Moving-object target types (Planet, Moon, Comet, Asteroid) | SI-012 | Hide until an ephemeris exists; keep with a warning | **Resolved — see E.1 and ADR-010 §3:** hidden for new targets in 1.0; existing ones labelled, never deleted. (Original: hide until PD-07.) | Target UI |
| PD-17 **RESOLVED 2026-09-23** | Imaging-opportunity semantics: which conditions **gate** a window and which only **annotate** it | Fixed gates and a heuristic warning (Moon > 0.8 or Bortle ≥ 7); MASTER_ROADMAP TASK 10.1 | **Resolved — see E.1 and ADR-013.** | — | Opportunity calculator (10.2) |
| PD-18 **RESOLVED 2026-09-23** | Session aggregate, lifecycle and snapshots | `SessionLog` conflates plan and result; the "current session" is implicit ViewModel state; MASTER_ROADMAP TASK 11.1 | **Resolved — see E.1 and ADR-014.** | — | Session schema migration (11.2) |
| PD-19 **RESOLVED 2026-09-23** | Information architecture and navigation (also resolves PD-14) | A single scrolling page with icon entry points; MASTER_ROADMAP TASK 12.1 | **Resolved — see E.1 and ADR-015.** | — | Navigation shell (12.2), execution and logbook screens |
| PD-20 **RESOLVED 2026-09-24** | Execution model under Android constraints | No execution concept exists; timers die in the background; MASTER_ROADMAP TASK 13.1 | **Resolved — see E.1 and ADR-016.** | — | Execution tasks 13.2–13.4 |
| PD-21 *(placeholder, registered 2026-09-21; **RESOLVED 2026-09-26**: E.1 "Stage 2 decisions", ADR-017)* | Supported image-metadata formats for assisted logging | TD-018, F-45; MASTER_ROADMAP G17 | Decided in TASK 17.1, against real sample files | — | Metadata-assisted logging (G17, v1.1) |

## E.1 Resolved decisions

### PD-06 — Active scope and gating of features built ahead of their phase (RESOLVED 2026-09-21)

- **Decided by:** the project owner, in chat, on 2026-09-21: "Stick to the decision
  from the roadmap and move on to the next task" — i.e. the recommendation in
  MASTER_ROADMAP TASK 0.2 is adopted as written.
- **Active scope:** the tasks of `docs/MASTER_ROADMAP.md`, one per cycle in roadmap
  order (OD-06). No single "active phase" is named; the roadmap's current task is
  the active scope (line maintained in `docs/ROADMAP.md`, "Adopted plan").
- **Gate policy for features that already exist in the code:**
  - **Stay visible** (they are on the core path): the **logbook** and **text sharing**.
  - **Hidden** until their group: **metadata import** until G17 (v1.1); the
    **light-pollution map card** until TASK 7.4; the **field-mode toggle** until TASK 12.4.
    *(Field mode lifted 2026-09-24, TASK 12.4, commit `3c27b15`, on its schedule.)*
- **Enforcement — DONE 2026-09-22 (TASK 4.3, commit `576c069`):** every entry point
  (buttons, cards, routes) gated from one source (`FeatureScope`), with tests that
  a gated feature has no entry point. **This decision was recorded only when
  written; no code was changed by TASK 0.2 — TASK 4.3 implemented it.**
- **Consequence for the actual state (historical, resolved TASK 4.3):** the code
  used to disagree with the policy (`metadataImport = true`; field-mode toggle and
  map card ungated; Home pushed gated routes unconditionally). DEV-P1 / TD-014 are
  now resolved. DEV-P3 and TD-041 (no declared scope) are resolved by this decision.
- **Not decided here:** whether the manual Bortle badge and any other gated element
  change visibility — not addressed by the roadmap text; revisit in TASK 7.4.

### PD-13 — `GEMINI.md` and the agent-instruction file policy (RESOLVED 2026-09-21)

- **Decided by:** the project owner, in chat, on 2026-09-21 (TASK 0.3), choosing
  "Drop GEMINI.md" from three offered options (restore as tracked / drop / keep ignored).
- **Decision:** `GEMINI.md` is **not** a project deliverable. `CLAUDE.md` is the
  agent-instruction file; `.agents/rules/` holds the shared rules.
- **Actions taken:** the `GEMINI.md` line was removed from `.gitignore` (commit
  `714426d`); the Phase 0 deliverable list in `docs/ROADMAP.md` is annotated as
  amended (original text kept); DEV-P7 marked resolved.
- **Not changed:** the audited-status table in `docs/ROADMAP.md` (a snapshot) and the
  audit documents, which still describe `GEMINI.md` as "git-ignored and absent".

### PD-01 — Session-night semantics and the default night rule (RESOLVED 2026-09-22)

- **Decided by:** the project owner, in chat, on 2026-09-22 (TASK 2.1). They chose
  the recommended option for each of two questions:
  - **Identity:** "Civil date at site" over the roadmap's literal "mean-solar date".
  - **Default:** "Window containing now" (the MASTER_ROADMAP TASK 2.1 rule) over
    PD-01 option (a), the Sun-altitude rule.

  The owner's task brief also required that the selected calendar date means "the
  night starting on the evening of that date" and must not be replaced with
  solar-noon semantics.
- **Decision:** see **ADR-007** (Part F), §2–§5.
- **What this refines in documented intent (recorded, not rewritten):**
  - MASTER_ROADMAP TASK 2.1 says the window "needs no time zone". The window's
    *instants* still need none, but choosing *which* solar noon a civil date refers to
    needs a time context (ADR-007 §3). TASK 2.2's `forEveningDate(date, site)` and
    `resolveDefault(now, site)` therefore take a `SiteTimeContext` as well.
  - PD-01's original recommendation (a) is **not** adopted. Consequence, accepted by
    the owner: between sunrise and the next mean solar noon the default is the night
    that has just ended (ADR-007 §5, L4).
- **Not implemented.** The code still uses the UTC calendar date (TD-001, SI-010 remain
  open until TASKs 2.2–2.4).

### PD-02 — Site time-zone strategy (RESOLVED 2026-09-22)

- **Decided by:** the project owner, in chat, on 2026-09-22 (TASK 2.1), choosing
  "Defer to TASK 7.1" over "Add in 2.2" for the `timezone` package, together with the
  identity decision above.
- **Decision:** see **ADR-007** (Part F), §6–§7.
  - Computation is in UTC through a `SiteTimeContext`. The device zone is never used
    in computation.
  - Display uses the site's IANA zone when it is known, otherwise the device zone,
    always labelled.
  - Until TASK 7.1 stores a zone per site, every site uses the mean-solar context
    (known limitation L1).
- **Deferred to TASK 7.1** (not decided here): the source of a site's IANA zone,
  either the provider offset (option b) or a bundled database with a coordinate
  lookup (option c), and the `timezone` dependency itself.
- **Not implemented.**

### PD-04 — Persistence baseline and migration strategy (RESOLVED 2026-09-22)

- **Decided by:** the project owner, in chat, on 2026-09-22 (TASK 3.1). They chose
  the recommended option for three questions:
  - **Floor:** v8, with backup and reset for older databases, over repairing every
    path.
  - **v10 cleanup:** drop the orphan table and the legacy columns, over dropping the
    table only.
  - **Orphans:** delete them and log the counts, over aborting and leaving foreign
    keys off.

  The owner also confirmed that **no installs below v8 need to be preserved**.
- **Decision:** see **ADR-008** §2–§5 (Part F).
- **Refines the original option (b):** the floor is v8, not v9, because v8 → v9 is
  proven to work.
- **Destructive steps approved by this decision**, and only these:
  - renaming (not deleting) a below-floor database after user confirmation;
  - deleting the v1–v7 upgrade steps from the code;
  - in v10: dropping `equipment_profiles`, dropping `optical_multiplier` and
    `bit_depth` through table rebuilds, and deleting orphan rows found by
    `foreign_key_check`.
- **Implemented (TASK 3.2, TASK 3.3):** the floor guard, the file-rename half of
  the reset, the v1–v7 step deletion, and the v10 cleanup (dropping
  `equipment_profiles`, dropping `optical_multiplier`/`bit_depth` through
  table rebuilds, deleting orphan rows found by `foreign_key_check`).
  **Not implemented yet:** the reset path's user-confirmation UI.

### PD-09 — Provenance storage (RESOLVED 2026-09-22)

- **Decided by:** the project owner, in chat, on 2026-09-22 (TASK 3.1), choosing
  "Per-row source + confidence" over "Separate data_sources table".
- **Decision:** see **ADR-008** §6.
  - Nullable `source` and `confidence` columns, with per-field pairs where the
    origins differ.
  - Added by TASKs 7.1, 8.1 and 8.5, not in G3.
  - Legacy rows stay NULL, meaning unknown, never guessed.
- **Not implemented.**

### PD-08 — Capture-budget model (RESOLVED 2026-09-22)

- **Decided by:** the project owner, in chat, on 2026-09-22 (TASK 5.1). They chose
  the recommended option for each of four questions:
  - **Calibration:** the default policy for new calibration blocks is "outside the
    window".
  - **Overheads:** the optional overheads are off by default and labelled "not
    included".
  - **Per-frame overhead:** keep 5 s.
  - **Session budget:** it includes outside-window calibration and setup, each on its
    own line.
- **Decision:** see **ADR-009** (Part F).
  - Only lights and `inWindow` calibration are fitted.
  - Frames and overhead events are atomic and never straddle a gap.
  - The margin is configurable, with a default of 15 %.
- **Refines the roadmap:**
  - MASTER_ROADMAP TASK 5.1 defines the session budget as "acquisition + in-window
    calibration + setup". Outside-window calibration is now included as its own line.
  - Existing calibration blocks change from "counted against the window" to
    `outsideWindow` (ADR-009 §3).
- **Not implemented** (TASKs 5.2–5.6).

### PD-07 and PD-16 — Ephemeris approach and moving objects (RESOLVED 2026-09-22)

- **Decided by:** the project owner, in chat, on 2026-09-22 (TASK 6.1). They chose
  the recommended option for each of three questions:
  - **Engine:** in-house Meeus ch. 47, over adopting a Dart package.
  - **Series:** the full ch. 47 tables, over a short truncation.
  - **Moving types:** hidden for new targets, existing ones labelled; over hiding
    them entirely or keeping them with a warning.
- **Decision:** see **ADR-010** (Part F).
- **Not implemented** (TASKs 6.2–6.4 and 8.1).

### PD-03 and PD-10 — Equipment model and aperture semantics (RESOLVED 2026-09-23)

- **Decided by:** the project owner, in chat, on 2026-09-23 (TASK 8.3), choosing the
  roadmap's recommendation on each point. Recorded as **ADR-011** (Part F).
- **PD-03:** keep the flat profile for 1.0 over the existing Device → CameraModule →
  OpticalRig tables; camera reuse deferred; the dormant `EquipmentCatalogRepository`
  and its three domain models are removed in TASK 8.4.
- **PD-10:** required `focalRatio` (the existing `aperture` column, read as N) plus an
  optional `apertureDiameterMm`, each derivable via the focal length (1 % agreement
  when both are entered); unit-explicit names in Dart; existing rows never
  reinterpreted, N > 32 flagged for the user to review.
- **Also decided:** tracking type {untracked, tracked, guided, unknown} in the existing
  column (existing rows stay `unknown`); an optional per-rig maximum exposure in
  seconds; guidance never blocks.
- **Implementation:** TASK 8.4.

### PD-15 — Weather provider/model and date alignment (RESOLVED 2026-09-23)

- **Decided by:** the project owner, in chat, on 2026-09-23 (TASK 9.1), choosing the
  recommended option on each point. Recorded as **ADR-012** (Part F).
- **Provider/model:** Open-Meteo, `best_match`, with provider and model stored per fetch
  and shown.
- **Alignment:** UTC timestamps (`timeformat=unixtime`), sliced to the chosen
  `SessionNight`, up to the 16-day horizon; uncovered hours are "no forecast".
- **Staleness:** under 3 h current, 3–12 h aging, over 12 h stale (labelled, refresh
  offered); cached data never shown as current.
- **Implementation:** TASKs 9.2–9.4.

### PD-11 — How NPF is surfaced (RESOLVED 2026-09-23)

- **Decided by:** the project owner, in chat, on 2026-09-23 (TASK 8.6), choosing the
  recommended option on each point.
- **Where:** a labelled recommendation for rigs marked untracked; for rigs whose tracking
  is unknown it is shown too, marked "if untracked"; never for tracked or guided rigs.
- **Declination:** the field's minimum |δ|, per Michaud: the target's |δ| minus half the
  field diagonal (the field's rotation is unknown, so the diagonal is the conservative
  extent), floored at 0 when the field reaches the equator. The value used is shown.
- **k:** a planning setting, 1–3, default 1 (the source's range and default), always
  shown with the figure.
- **Use:** the recommended maximum sub is min(NPF, the rig's maximum exposure) when NPF
  applies, otherwise the rig's maximum exposure (ADR-011 §5); a longer light block gets
  a warning; guidance never blocks a plan.
- **Implementation:** TASK 8.6 (`CapabilityCalculator`, CALC-31).

### PD-05 — Light-pollution / Bortle source and the "unknown" policy (RESOLVED 2026-09-23)

- **Decided by:** the approved Master Development Roadmap (TASK 7.4 scope, which
  adopts the PD-05 recommendation "(a) now, (b) later; remove the scraper"),
  implemented on the owner's go-ahead for TASK 7.4 on 2026-09-23.
- **Now (implemented, TASK 7.4):**
  - **A — external map:** lightpollutionmap.info opened centred on the current
    position (`LightPollutionMapLink`); the app only links, it fetches nothing.
  - **B — manual entry:** Bortle (1–9) and/or SQM (mag/arcsec², 15–23) per site in
    the site editor, stored with source `user` and the date of the edit; unknown
    is the default and is shown as unknown.
  - The ClearOutside scraper (`LightPollutionRepository`) is deleted. The feature
    gate `FeatureScope.lightPollutionContext` is on (PD-06's schedule).
  - No Bortle↔SQM conversion unless a source for it is adopted.
- **Deferred (documented, not implemented):**
  - **C — offline dataset** (e.g. a world artificial-sky-brightness atlas bundled or
    downloaded). Before adoption: its licence (attribution, redistribution inside
    an app), its size on a phone, and the uncertainty of converting modelled zenith
    radiance to SQM or Bortle must be evaluated and documented, with a formula
    record here.
  - **D — licensed API**, only if a real service with acceptable terms is verified;
    it would need key handling that keeps secrets out of the code (rule 15) and
    must stay optional (offline-first).
- **Consequences:** TD-006 and SI-007 resolved; F-32 removed, F-33 and F-34
  implemented. The sky-warning thresholds are unchanged (SI-006, G10).

### SI-001 — NPF formula correction (formula change record, TASK 6.5, 2026-09-22)

- **Why this is recorded:** a formula change is never silent (rule 16;
  SCIENTIFIC_INTEGRITY Part C rule 2). The roadmap (TASK 6.5) required this entry.
- **Primary source, read 2026-09-22:** F. Michaud, "La Règle NPF" and "Les
  coulisses de la règle NPF", Société Astronomique du Havre
  (https://sahavre.fr/wp/regle-npf-rule/,
  https://sahavre.fr/wp/les-coulisses-de-la-regle-npf/). The older URL cited in
  SI-001 now returns "page unavailable".
- **Before:** `t = (16.856 N + 13.713 p + 90) / (f cos δ)`. The constant `90`
  replaced the focal-length term, giving 2.9× too long for phone lenses and 0.72×
  at 2000 mm. There was no k.
- **After:** `t = k · (16.8567 N + 0.099724 f + 13.713 p) / (f cos |δ|)`.
  - Each constant is computed in code from the source's own derivation: Airy
    4.47 · 550 nm, 3″ seeing, 2-pixel Bayer spread, 13713 ≈ 86164 s / 2π.
  - The published rounded form k(16.9 N + 0.10 f + 13.7 p)/(f cos δ) differs by
    under 0.2 %.
  - k defaults to 1 (round stars); values outside Michaud's 1–3 are rejected.
  - δ is, per the source, the **minimum** |declination| of the field, 0 when
    unknown. It is capped at 89.9°, as before.
- **Deviation from the roadmap wording:** the roadmap asked for "at least 3
  published examples". The primary source has no numeric worked examples in its
  text (its tables are images). The tests therefore use five examples computed
  independently from the source formula in a scratch script, cross-checked against
  the published rounded form. One is a phone lens.
- **Unchanged:** PD-11. NPF stays **hidden**, with no UI consumer. The ViewModel
  getter passes the target's centre declination, not the field's minimum. That must
  be revisited when PD-11 decides how NPF is surfaced.

---

### PD-17 — Imaging-opportunity semantics (RESOLVED 2026-09-23)

- **Decided by:** the project owner, in chat, on 2026-09-23 (TASK 10.1), choosing the
  recommended option on each point. Recorded as **ADR-013** (Part F).
- **Gates:** Sun ≤ the darkness limit and target ≥ the minimum altitude; a horizon gate
  is reserved with no data in 1.0 (the minimum altitude stands in).
- **Moon and cloud:** annotations by default; each has an optional user gate, off by
  default (Moon up and ≥ X % lit; cloud > Y %; X = Y = 50 % when enabled).
- **Sky warning:** the fixed Moon > 0.8 / Bortle ≥ 7 warning is replaced by annotations.
- **Also decided:** unknown never excludes; all failing reasons listed; max altitude
  inside windows; no composite score.
- **Implementation:** TASK 10.2.

### PD-18 — Session aggregate, lifecycle and snapshots (RESOLVED 2026-09-23)

- **Decided by:** the project owner, in chat, on 2026-09-23 (TASK 11.1), choosing the
  recommended option on each point. Recorded as **ADR-014** (Part F).
- **Aggregate:** Session is the root; LogbookEntry = a completed Session; references
  nullable with SET NULL; versioned JSON snapshots; `session_logs` evolves in place.
- **Completed sessions:** only results and notes stay editable; no reopening.
- **Snapshots:** the plan snapshot is refreshed on each Save; the execution-start
  snapshot is frozen.
- **Current session:** the most recently updated open session; no id in preferences.
- **Legacy logs:** completed, read-only, flagged legacy; no references guessed.
- **Implementation:** TASKs 11.2–11.4.

### PD-19 (and PD-14) — Information architecture (RESOLVED 2026-09-23)

- **Decided by:** the project owner, in chat, on 2026-09-23 (TASK 12.1), choosing the
  recommended option on each point. Recorded as **ADR-015** (Part F), wireframes and
  route map in `docs/IA_WIREFRAMES.md`.
- **Tabs:** Tonight · Sessions · Library · Settings; the session planner is one page
  opened from Tonight and Sessions; sites live in Library; execution is full screen.
- **PD-14:** a fixed Tonight view; no customizable dashboard.
- **Implementation:** TASKs 12.2, 12.3, 12.5; G13.

### PD-20 — Execution model under Android constraints (RESOLVED 2026-09-24)

- **Decided by:** the project owner, in chat, on 2026-09-24 (TASK 13.1), choosing the
  recommended option on each point. Recorded as **ADR-016** (Part F).
- **Keep screen on:** opt-in, off by default, only while tracking; a wakelock plugin is
  approved for TASK 13.3 (licence re-checked when added).
- **Concurrency:** one session in progress at a time.
- **Stale run:** a resume prompt after the night ends; never auto-finished.
- **Events:** a new append-only `session_events` table (schema v17).
- **Implementation:** TASKs 13.2–13.4.

### PD-12 — Licence intent and third-party terms (RESOLVED 2026-09-24)

- **Decided by:** the project owner, in chat, on 2026-09-24 (TASK 16.3).
- **Distribution:** free, with **no ads and no subscriptions** — within Open-Meteo's free,
  non-commercial tier. A paid or ad-supported version needs Open-Meteo's commercial plan
  (an API key held outside the code, ADR-012 §2) before it ships.
- **Licence:** **GPL-3.0** confirmed (the repository's `LICENSE`); the OpenNGC-derived
  catalog stays CC BY-SA 4.0 with its notice. The About screen states the licence and links
  the source (https://github.com/chacha12/astro-planner, to be made public by the owner).
- **Privacy policy:** hosted on GitHub Pages at
  https://chacha12.github.io/astro-planner/privacy/ (`docs/privacy/index.md`); the contact
  email is the owner's to fill in.
- **Nominatim:** place-name lookups are **opt-in, off by default** (its policy asks that
  apps can stop using it without an update). The residual gap — no remotely switchable
  endpoint once a user opts in — is recorded in TD-031.
- **OSM tiles:** kept, with the identifying user agent carrying the project URL as contact;
  the map picker stays optional (typed coordinates always work).
- Terms as checked, the Data Safety draft and the permission review: `docs/COMPLIANCE.md`
  (date-stamped; re-check before each release). Not legal advice.

### Stage 1 planning decisions: RD-03, RD-05 (interim), RD-17 (2026-09-25)

- **Decided by:** the project owner, in chat, on 2026-09-25, during Stage 1 planning
  (`docs/refinement/POST_ROADMAP_PLAN.md` §5, "Stage 1 — frozen Task sequence").
- **RD-03 (RESOLVED).**
  - SCI-05: the capture block's ISO/gain field gets the neutral label "ISO / gain (for your
    records)" in Stage 1 (S1.8). The value stays descriptive only (SI-004), and
    `SCIENTIFIC_INTEGRITY.md` Part C rule 6 is met. RG-11 (Stage 7) may still rework capture
    parameters.
  - SCI-04: the 5-minute grid's one-directional bias (crossings reported 0–5 min late,
    within CALC-08's [−2, +7] min tolerance) is **documented as accepted** in SI-009 and
    CALC-08 (S1.13). There is no UI note and no conservative edge rule. Changing either would
    be a new scientific decision.
- **RD-05 (interim only; the RD stays open for Stage 4).** New, Duplicate and opening a
  session ask for confirmation before switching away from a draft with unsaved changes
  (S1.6). Drafts are still not listed or cleaned up (TASK 11.3's decision stands), and what
  New and Duplicate create is unchanged.
- **RD-17 (included in Stage 1 as S1.14).** The CI workflow is pushed to
  `github.com/Buffur/Astro-Planner` and its first run recorded. The push itself is confirmed
  with the owner when S1.14 runs. RD-01 (the account behind the application id) is not
  decided by this.
- **`CLAUDE.md` device-use wording:** S1.15 may correct "never installed or run on an
  Android device". Manual installs have happened, but none is recorded
  (`POST_ROADMAP_PLAN.md` §1.3 item 2).
- **Not taken in Stage 1:** RD-02 stays open (Stage 10 for `sqlite3_flutter_libs`).
- **RD-17 deferred (owner, 2026-09-25, asked when S1.14 ran):** no push. The remote is public, so a push would publish 155 commits with the audit and refinement documents and the commit author email. RD-17 is open again (Stage 11 or on request).
- **S1.4 night key without a site (owner, 2026-09-25, during S1.4).** The planned
  device-zone rule conflicted with ADR-007 §6 and PD-02(a), so it was not built. Without a
  site, the draft's night key is the default night at the app's default position, resolved
  by `SessionNightResolver` (mean solar time), never from a date's Y/M/D (CLAUDE.md trap 2).
  There is still no `SessionNight` without a site (ADR-007 §9); the key is only the draft's
  label, and it is corrected by the first autosave after a site is set. Known limit: far east
  of Greenwich, in the morning, it can be a day off until then.

### Stage 1 closed by the owner (2026-09-26)

- **Decided by:** the project owner, in chat, on 2026-09-26 ("okey, lets go to stage 2"),
  after the repeat independent Stage 1 validation did not pass
  (`docs/refinement/STAGE_1_REVALIDATION.md`, commit `39392d9`).
- **Decision:** Stage 1 is closed and Stage 2 starts, without the proposed fix Tasks S1.V5 and
  S1.V6. Stage 1's exit criterion "validation passes in a fresh session" was **not met**; this
  is an owner waiver, not a pass.
- **What happens to the findings:**
  - **TD-063** (a detail page loaded before Start reopens the running session as the planner's
    plan) moves to **Stage 8** (Sessions / Execution). It predates Stage 1 (TASK 13.3).
  - **X2** (the registers still call S1.5 broken and S1.6 partial after S1.V1–S1.V4, and the
    S1.V stamps cite no commit) stays open as documentation debt. The fix is the proposed
    S1.V6; it runs when the owner asks, and at the latest in Stage 11's documentation check.
  - **W1** (a Duplicate counts as unsaved only after a restart) stays a proposed input to
    RD-05 (Stage 4). It is not yet recorded there.
- **Not changed:** every other carried item (TD-057, TD-058, RD-17, the Stage 11 device
  checks, the stale preferences with TD-056).

### Stage 2 decisions: RG-01, PD-21, RD-16 (2026-09-26)

- **Decided by:** the project owner, in chat, on 2026-09-26, after S2.R1
  (`docs/refinement/research/RG-01_METADATA_FORMATS.md`). The research direction is approved
  with the owner's constraints, recorded here and in ADR-017 (Part F).
- **PD-21 (RESOLVED).**
  - DNG is supported in Stage 2, on the two real samples.
  - FITS comes only after the owner supplies a real FITS sample.
  - JPEG, XISF, CR3 and every other format stay sample-driven and deferred.
  - No format is claimed without a representative real sample and tests.
- **Architecture (ADR-017, accepted):**
  - bounded, header-oriented reads; the whole capture file is never loaded;
  - recognition by signature;
  - only the approved contract's fields are parsed; missing or ambiguous values stay
    Unknown, and provenance is kept;
  - file I/O stays outside the domain.
  - Removing `exif` and `image_picker` needed to be **justified from the repository**, not
    assumed. ADR-017 §7 gives that justification.
- **Privacy:**
  - GPS, device serial numbers and observer identity are outside the contract and never
    extracted;
  - the time zone is never inferred: a capture time without one stays explicitly zone
    unknown.
- **Fixtures:** the owner's raw DNG slices are **not** committed; the real files stay outside
  the repository for local real-sample validation. Committed fixtures are minimal, sanitized
  and deterministic. A Xiaomi-specific structural fixture, if needed, is sanitized first.
  (This replaces S2.R1's recommended option C1.)
- **RD-16 (RESOLVED for Stage 2):** the metadata import UI stays hidden during Stage 2, and
  Stage 2 delivers and validates the foundation only. Nothing extracted goes into Equipment.
  Stage 3 defines `Metadata → EquipmentCandidate → Match/Enrich → User Confirmation →
  Persist`, and when anything becomes visible.
- **Stage 3 evidence (preserved for RG-02):** the owner's phone exposes its two camera modules
  (main and telephoto) with the **same** Make, Model and UniqueCameraModel. In the samples
  they are distinguishable only through optical metadata (focal length, 35 mm equivalent,
  f-number) and the image geometry. Focal length is **not** a universally reliable camera
  identifier: zoom lenses, user-entered software values and other devices break it.
- **Android picker and cache (TD-065 in Stage 2's scope):**
  - a bounded parser is not enough if the picker first copies the whole file;
  - metadata files are opened without a copy (ADR-017 §6), and cache ownership and cleanup
    are defined there;
  - no general file-management function is added.
  (This replaces S2.R1's recommended option B1.)
- **Blocker recorded, not decided:** the Android access path (ADR-017 §6) is native code, and
  this machine cannot run it. The SDK has the emulator binary but no system image and no
  virtual device, the cmdline-tools are missing (TASK 16.2's owner action), and no phone is
  connected. S2.4's acceptance needs a device check. The options are the owner's phone with
  USB debugging (`adb` is installed), or an emulator image installed by the owner.

### Stage 2 format priorities and metadata layering (2026-09-26)

- **Decided by:** the project owner, in chat, on 2026-09-26, after S2.1–S2.5. The review is
  in `docs/refinement/STAGE_2_ARCHITECTURE_REVIEW.md`.
- **Architecture:** priority goes to one common typed, provenance-aware extraction contract
  that supports many formats **without changing the domain model for every parser**. Three
  levels stay distinct:
  1. format recognition;
  2. metadata extraction;
  3. whether the evidence is enough to form an EquipmentCandidate (Stage 3, RG-02).
- **Format priorities (amends PD-21 and ADR-017 §8):**
  - **DNG:** primary; real samples exist.
  - **JPEG/JPG:** high priority.
  - **HEIC/HEIF:** a high-priority research and support target.
  - **FITS/FIT:** when a representative real sample exists.
  - **PNG:** where meaningful metadata exists; never assumed to identify equipment.
  - **Proprietary RAW** (CR2/CR3, NEF, ARW, RAF, RW2): **no ad hoc parsers.** A dedicated
    compatibility and library research task (RG-14).
  - **XISF and other specialised formats:** driven by samples and use cases.
  - **Primary focus:** RAW, DNG and JPEG; other formats can follow in later development.
- **Limits:** "support popular formats" is **not** permission to build image decoders or a
  universal RAW parsing framework. Missing metadata stays Unknown and is never guessed. The
  earlier rules stand: no support is claimed without a representative real sample and tests;
  ADR-017's privacy exclusions, bounded reads and Stage 3 boundary are unchanged.

### FITS and PNG skipped for now (2026-09-26)

- **Decided by:** the project owner, in chat, on 2026-09-26: "There won't be any FITS or PNG
  files for now. We'll skip them."
- **Consequence:** S2.6 (FITS) and S2.10 (PNG `eXIf`) leave Stage 2. They are carried as
  sample-driven later work. Both formats stay **recognised only** (ADR-017 §13), and G6 (a
  generic optics identity) waits with FITS. The Stage 2 exit no longer waits for them.
- **Samples supplied the same day:** a phone JPEG (`IMG_20260926_084535.jpg`) and a phone
  HEIC (`IMG_20260926_084557.HEIC`), kept outside the repository. S2.8 (JPEG) is unblocked;
  S2.R2 used the HEIC.

### RG-14 decided: proprietary RAW, and Stage 2 closes by validation (2026-09-26)

- **Decided by:** the project owner, in chat, on 2026-09-26, after S2.R3
  (`docs/refinement/research/S2.R3_RG14_PROPRIETARY_RAW.md`). The owner said "proceed with the
  second scenario and move on to the next stage", and then confirmed both points when asked
  which scenario was meant.
- **RG-14 (DECIDED):**
  - **Stage 2 closes without proprietary RAW support** (option D). CR2, CR3, RAF, RW2 and ORF
    stay recognised only; NEF and ARW read as TIFF, not supported.
  - **Afterwards, option A:** one small container adapter per format over the shared
    `ExifStructure` or `JpegMetadataReader`, **each only with a representative real sample**
    and the S2.8/S2.9 test pattern. The order is RAF, then CR2/NEF/ARW, then ORF/RW2, with
    CR3 last. No MakerNotes and no decoding.
  - **Rejected:** option B (AndroidX `ExifInterface`: its reads cannot be bounded or proven
    under ADR-017 §4, it parses GPS internally, and it would be a second extraction path)
    and option C (LibRaw: a decoder).
  - The owner has not yet said which RAW formats they shoot. Those adapters wait for samples.
- **Stage 2 closure:** the **repeat independent Stage 2 validation** runs first, in a fresh
  session; Stage 3 starts after it passes. This is not a waiver.

### Stage 2 repeat validation: fixes and the HEIF brand ruling (2026-09-26)

- **Context:** the repeat independent Stage 2 validation failed at `5d8bdbb`
  (`refinement/STAGE_2_REVALIDATION.md`, committed `f137409`). It proposed S2.V4 and S2.V5, and it
  asked for a ruling on S2R-02 with two options: (a) read only the HEIF still-image brands the
  evidence covers, and make the others recognised only; (b) accept AVIF as the same container.
- **Decided by:** the project owner, in chat, on 2026-09-26: "Do fix". This approves S2.V4 and
  S2.V5. The owner did not name an S2R-02 option. The implementing session took the reply as
  accepting the recommended option, **(a)**, which narrows a support claim rather than widening
  it. The owner can reverse it: the change is a recognition table.
- **S2R-02 ruling (a):**
  - **HEIF, read by `HeifMetadataReader`:** the major brands `heic`, `heix`, `heim` and `heis`
    (HEVC still images) and `mif1` (the generic image brand). The owner's HEIC is `heic`.
  - **`MetadataFormat.avif` (recognised only):** the major brands `avif` and `avis`. No AVIF
    sample exists (ADR-017 §13: support only with a real sample).
  - **`MetadataFormat.heifSequence` (recognised only):** the major brands `msf1`, `hevc`,
    `hevx`, `hevm` and `hevs`. A sequence may have no top-level `meta`, so reading one as a
    still image called valid files "corrupt".
  - The files come back as "not supported yet", with their own names ("AVIF", "HEIF image
    sequence"). A reader for either needs a sample and a Task, like the RAW adapters.
- **S2.V4 (TD-067):** the HEIF `iloc` parser accepts at most `maxExtents` = 16,384 extents over
  all items, which is what a 64 KiB `meta` holds with one 4-byte field per extent. Beyond that
  the reading is `corrupt`.
- **Stage 2 closure:** unchanged. Another independent validation in a fresh session, or an
  owner waiver.

### Stage 2 closed by the owner (2026-09-26)

- **Context:** S2.V4 and S2.V5 (`d8e792c`, `435b3ce`) fixed every finding of the repeat
  independent validation (S2R-01 to S2R-04). The Stage's exit still asked for another
  independent validation.
- **Asked** whether to run that validation in a fresh session or waive it, the owner chose
  **"Waive and go to Stage 3"**.
- **Recorded as a waiver, not a pass.** S2.V4 rests on its own tests (the bound test fails on
  the old reader), the local real-sample check and a green gate (1068 tests, 1 expected skip,
  2 host E2E). No fresh session has re-examined it.
- **Carried:**
  - S2V-06's device checks (a non-seekable provider; a real backup's preview cancel);
  - TD-066;
  - FITS, PNG, AVIF, HEIF sequences and proprietary RAW, each waiting for a sample.
- **Before Stage 3:** the Stage 1 X2 documentation debt was closed at the owner's request (S1.V6,
  `3dd2598`).
- Stage 3's planning starts next. Its implementation waits for RG-02, RG-03 and an ADR.

### Stage 3 decisions (S3.D) (2026-09-26)

- **Context:** the second Stage 3 planning pass (`4c46f8f`) did S3.R1
  (`refinement/research/RG-02_EQUIPMENT_IDENTITY.md`) and put decisions D1–D4 to the owner. D1
  blocked freezing the Tasks.
- **Decided by:** the project owner, in this session on 2026-09-26, choosing from explicit
  options. Each answer was the recommended option:
  - **D1 = A1:** an import pre-fills the rig editor, and a rig is saved only when complete. A
    sensor-size and pixel-pitch estimate from the 35 mm equivalent and the image dimensions
    (CALC-40, `estimated`) is offered and never applied silently. Nullable specs (B) and a
    candidate store (C) are rejected for Stage 3.
  - **D2:** no specification source in Stage 3. RG-03 and S3.R2 are deferred.
  - **D3 (RD-16):** the import becomes visible at the end of Stage 3 (S3.7), as "Add from a
    photo" on the equipment screen.
  - **D4 (C-13):** a DNG pick's file length may fill the average RAW size as an `estimated`
    value, "from one file". JPEG/HEIC sizes are never used.
- **Recorded:** ADR-018 (Part F), which amends ADR-017 §2 with image dimensions and applies
  ADR-008 §6 per field to equipment (schema v18). RG-02 is decided. RD-16 is resolved.
- **Frozen:** S3.1–S3.8 (`refinement/POST_ROADMAP_PLAN.md`, "Stage 3 — frozen Task sequence").
- **Implementation choices recorded in ADR-018 without a separate question:**
  - the 1 % f/N match tolerance;
  - the diagonal convention for CALC-40;
  - `DefaultCropSize` preferred for DNG;
  - the Settings viewer entry removed when the import becomes visible.
  Each is documented as an assumption, and the owner can change it.

### Stage 3 fixes before validation (2026-09-26)

- **Context:** device check M4 (S3.7) found two issues: TD-068 (a rig imported from a file showed
  rounding "differences" against that same file) and TD-069 (the editor's read-only sensor-size
  fields clip their text on a phone).
- **Decided by:** the project owner, in chat, 2026-09-26: "fix the existing issues. We shouldn't
  leave any gaps in the execution of the tasks." This approves two small Tasks before the Stage 3
  validation: **S3.9** (TD-068) and **S3.10** (TD-069).
- **S3.9's rule:** estimates are proposed at the precision the editor stores (sensor 0.01 mm,
  pixel 0.001 µm, RAW size 0.1 MB), one set of constants for both. Plausibility is checked before
  rounding, so rounding never makes a value plausible. CALC-40 itself is unchanged.

### Stage 3 validation failed: corrective Tasks (2026-09-26)

*(Added 2026-09-27.)* After S3.V5, re-running the archived probes found P5 still failing: S3V-01
was open at the ViewModel level. The owner approved **S3.V6** in chat ("let's move on to the next
task", in reply to the proposal) to close it the same way: no draft of a saved rig can be built
from a stale match.

- **Context:** the independent Stage 3 validation at `387e54b` failed (`refinement/STAGE_3_VALIDATION.md`,
  committed `7f790df` as written): S3V-01 to S3V-06 are blocking.
- **Decided by:** the project owner, in chat, 2026-09-26:
  - treat Stage 3 as failed, and do not start Stage 4;
  - commit the validation record alone;
  - then run S3.V1–S3.V5 one at a time. For each: a failing regression test first where
    practical, only that fix, the targeted tests and the gate, `PROGRESS.md`, one commit,
    and STOP.
- **Acceptance set by the owner:**
  - **S3.V1:** a stale review never silently reverts newer Equipment changes, unless the user
    explicitly chooses to replace them;
  - **S3.V2:** untouched legacy values are never attributed to the user because another field
    was edited;
  - **S3.V3:**
    - choosing the file's value applies the file's actual value;
    - persisted and verified values stay exact;
    - rounding only for explicitly estimated or display-only values;
  - **S3.V4:** image dimensions validated; impossible or absurd values rejected (S3.1's
    acceptance);
  - **S3.V5:** the required real-database review coverage, and stale documentation/status
    wording corrected.
- **Also decided:**
  - an Android or device recheck is kept separate from S3.V5, as its own validation action with
    a clear evidence level, unless the Stage 3 acceptance requires it;
  - the failed validation is never weakened or rewritten to fit the implementation;
  - after S3.V1–S3.V5, Stage 3 needs a fresh independent validation before Stage 4.

### Stage 3 sign-off failed: corrective Tasks (2026-09-27)

- **Context:** the fresh-session Stage 3 sign-off at `74026ca` failed
  (`refinement/STAGE_3_SIGNOFF_VALIDATION.md`, committed `d7dead0`). S3S-01 and S3S-02 are
  blocking; S3S-03 is low.
- **Decided by:** the project owner, in chat, 2026-09-27:
  - the two blocking findings are **not waived**, and Stage 3 stays open until they are corrected;
  - S3.V7 and S3.V8 run as separate corrective Tasks with separate commits. For each: the
    regression test first, only the approved behaviour, targeted and regression tests, the
    documents and `PROGRESS.md`, one commit, then STOP;
  - after both, a fresh Stage 3 sign-off. It verifies the original Stage 3 acceptance, every
    previous blocking finding, and regressions around the corrected areas. It does not add
    product requirements or an Equipment redesign;
  - Stage 4 stays blocked until Stage 3 receives a PASS.
- **S3.V7 (S3S-01), approved with a Stage-boundary adjustment:**
  - the Equipment editor uses the stored provenance of each value. A rig-wide `user` label must
    never present estimated or imported values as user-reported;
  - no session-snapshot provenance migration in Stage 3. For saved-session records without
    per-field provenance, the rig-wide source is never presented as every field's provenance:
    show only what the record supports, or omit it;
  - per-field session provenance, and the export or schema changes it needs, are deferred to
    Stage 8, where session and logbook semantics are redesigned;
  - **acceptance principle:** missing per-field provenance is never replaced with an invented
    `user` origin.
- **S3.V8 (S3S-02), option (a):**
  - when the photo's pixel dimensions differ from the matched saved rig's, pixel size and
    physical sensor size are not copied from that rig;
  - binning, ROI or cropping, resampling, another sensor mode or another configuration could
    explain the difference, and metadata cannot tell which. The relationship is not inferred;
  - the matched rig stays as evidence where valid; the affected values stay unknown until the
    user confirms or provides them.
- **S3S-03 (TD-072):** not part of S3.V8. It stays non-blocking, because the false transposed
  conflict never chooses a value silently and the saved value remains the default. It is
  deferred to a later Equipment or data-entry cleanup, unless new evidence shows it affects
  correctness.

### Stage 3 closed; Stage 4 planning decisions (2026-09-27)

- **Stage 3 closed** by its fresh-session final sign-off: PASS at `92ebf2a`, committed `126d97f`
  (`refinement/STAGE_3_FINAL_SIGNOFF.md`). Not a waiver. S3F-01 and S3F-02 are non-blocking and
  recorded (TD-072 addendum, TD-071 note); S3V-08 (device) stays unverified.
- **Stage 4 planning, decided by the owner in chat** (each the recommended option):
  - **The sequence is frozen as proposed** (`refinement/POST_ROADMAP_PLAN.md`, "Stage 4 — frozen
    Task sequence"): S4.R1 flow inventory; S4.R2 RG-04; S4.R3 RD-05 and RD-04; S4.R4 RG-05,
    RD-06 and RG-06; S4.R5 RD-07 and RD-14; S4.D ADR-019 and a wireframe addendum; S4.T the
    decisions as provisional Tasks for Stages 5, 6, 8 and 9.
  - **Owner-run quick tests (S4.E) are optional and non-blocking.** S4.R1 writes the script. If
    they are not run, S4.R4 states the evidence gap. A first-run test uses a separate install,
    never the owner's own app.
  - **Each gate is decided right after its research step,** so later steps build on settled
    answers (Execution's role first).
- **Unchanged:** Stage 4 writes no application code, and Execution stays as built until Stage 8
  (`PRODUCT_DIRECTION.md` §4). No ADR changed.
- **Process note:** the planning ran in the same chat as the Stage 3 sign-off, at the owner's
  request, not in a fresh one (§9.1 step 1).

### RG-04 decided: Execution's role and post-session results (S4.R2, 2026-09-27)

- **Context:**
  - the research is `refinement/research/RG-04_EXECUTION_ROLE.md` (committed `97ffab5`);
  - the owner's clarifications of 08 (O1–O4) are in `refinement/research/S4.R1_FLOW_INVENTORY.md`
    §6.1;
  - the key fact: everything valued after a session depends on counts, not on the live tracker,
    yet today a result can be recorded only through Start.
- **Decided by:** the project owner, in chat, choosing the recommended option on each question.
- **D1 — role: B, the Logbook first; the tracker optional.**
  - The default flow is Planner → Save → image → Logbook → record the result.
  - Start leaves the primary actions on Tonight and in the planner. It stays reachable as an
    optional live mode on a saved session ("Track live (optional)"; the wording is RD-14's, S4.R5).
  - The tracker's Finish leads to the same result form. Nothing is removed. The tracker may later
    be hidden or removed (option C) if it goes unused; that would be a new owner decision.
- **D2 — detail: G2, the outcome, with numbers only when needed.**
  - "Completed as planned" takes one tap; the actual equals the plan, labelled as reported by the
    user.
  - "Partly" takes numbers per light block: pre-filled with the plan, editable, entered as numbers
    rather than ±1.
  - "Not done" takes an optional reason.
  - Notes are optional. Temperature, humidity and cloud stay optional, as today (not asked
    separately; Stage 8 planning may revisit).
  - Rejected-frame counts are not asked in the default form. The existing counts stay readable.
- **D3 — "Not completed":**
  - "Not done" is the existing `abandoned` status, with an optional reason (clouds, wind, dew,
    equipment, other);
  - "Partly" is `completed` with the numbers entered;
  - no new status. How the reason is stored is Stage 8's decision.
- **D4 — after the night:**
  - the result is recorded from the Logbook entry;
  - Tonight shows a quiet line for a saved plan whose night has passed ("Last night: …. How did it
    go?");
  - no notifications (ADR-016 §6);
  - the line's placement is S4.R4's; what the planner does with yesterday's plan is S4.R3's.
- **Consequences, recorded by ADR-019 (S4.D) and implemented in Stage 8, not before:**
  - ADR-014 §3: a planned session may be completed or abandoned by a result, without a run;
  - ADR-016: post-session counts are written as events, so the counters still equal the replay;
    the live mode becomes optional;
  - CALC-37 and CALC-38: note the "reported as planned" provenance (with RD-13);
  - RD-12 (the resume prompt's Finish) is expected to fold into "Finish leads to the result form",
    decided in Stage 8;
  - the core-loop E2E test moves to Save → result (trap 19).
- **Unchanged until then:** Execution stays as built (`PRODUCT_DIRECTION.md` §4). No data is
  deleted; existing runs, events and results stay readable and exported.

### RD-05 and RD-04 decided: the session lifecycle and new-plan defaults (S4.R3, 2026-09-27)

- **Context:** the research is `refinement/research/S4.R3_SESSION_LIFECYCLE.md` (committed
  `989a61e`). A verified conflict with RG-04: yesterday's saved plan is resumed as the planner's
  current plan and rolled forward to tonight.
- **Decided by:** the project owner, in chat, choosing the recommended option on each question.
- **E1 — the draft model: L1.**
  - Draft stays an internal state. The user sees the plan's state as "Not saved", "Saved" or
    "Saved · changed"; the final words are RD-14's (S4.R5).
  - Save stays explicit and means "I plan to image this". Only saved plans enter the Logbook,
    where they later wait for a result (RG-04).
  - No data-model change.
- **E2 — the next day: Y2.**
  - A saved plan whose night has passed is not resumed as the planner's current plan. It stays on
    its night, awaiting its result (the Logbook, and Tonight's line, RG-04 D4).
  - The planner continues on a copy for tonight (the same target, rig and blocks; not saved).
  - A never-saved draft whose night has passed keeps TASK 11.4's roll-forward.
- **E3 — defaults and the example plan (RD-04):**
  - nothing is preselected on the first run: no target, no rig. The seeded rig stays in the list,
    labelled as an example;
  - New keeps the site and rig, and asks for the target;
  - the capture plan starts empty, with one tap to "Start from the example plan";
  - the first-run page lists nothing as chosen that the user did not choose.
- **E4 — unsaved plans: U1.**
  - Replacing a plan with unsaved changes (New, Duplicate, Open) asks **Save · Discard · Cancel**.
  - Discard deletes the discarded draft, and an untouched replaced draft is deleted too.
  - A site change on a saved plan, and a fresh Duplicate, count as unsaved (W1 and V3 resolved in
    principle).
  - Unsaved plans are not listed.
- **Decided with them, without alternatives** (the research's §8):
  - the planner's app bar shows the target, the night and the state (UX-04);
  - New, Duplicate and Open each confirm what happened;
  - no card offers a Start that must fail while a run is in progress (UX-13);
  - TD-058 and TD-057 are fixed where this is implemented;
  - placement on screens is S4.R4's.
- **Supersedes:**
  - TASK 11.4's "New = tonight + the example plan";
  - TASK 11.4's roll-forward, for **saved** plans only;
  - the S1.6 interim safeguard, which becomes U1 when implemented.
- **Stands:**
  - TASK 11.3: unsaved drafts are not listed;
  - TASK 4.4: the example plan never looks like the user's own;
  - ADR-014's aggregate and snapshots.
- **Consequences:**
  - ADR-019 (S4.D) amends ADR-014 §3's "Current session" rule (E2);
  - Stage 6 implements the planner parts;
  - Stage 8 implements E2's resume rule together with RG-04's result recording.
- No code changed.

### RG-05, RD-06 and RG-06 decided: Tonight, the planner's structure and disclosure (S4.R4, 2026-09-27)

- **Context:** the research is `refinement/research/RG-05_06_TONIGHT_AND_PLANNER.md` (committed
  `8578ab8`). The planner's verdict is on its last screen (05 §3), and only the assumptions panel
  collapses today. S4.E (owner-run tests) was not run; the gap is stated there.
- **Decided by:** the project owner, in chat, choosing the recommended option on each question.
- **F1 — Tonight (RG-05): T1, the plan first.**
  - A context line (site ▾ · night ▾) serves as the site switcher and night picker. It is the same
    control as the planner's, and the night picker changes the current plan's night (UX-11).
  - Then, in order: the live-run card (only during an optional run); the "how did it go?" line (only
    when due); **the current plan** (state, the fit with its reason and usable time, Open planner, or
    "Choose a target" / "What can I image tonight?" without one); the Night, Moon and Weather rows;
    the secondary actions (What can I image tonight?, New plan).
- **F2 — drill-downs (RG-05): D-b.**
  - New "Night & Moon" and "Weather" detail screens, opened from Tonight's rows and from the
    planner's condition summaries (UX-10, UX-03).
  - The target-specific chart stays in the planner.
  - No new tab: ADR-015's four tabs stand, and 08 §2's "Analytics" idea is met by the detail
    screens.
- **F3 — the planner (RD-06): P-1, answer first and then decision order.**
  - The order: the status (the verdict with its reason, time needed against usable time, when
    capture ends, total integration, fill or trim) → the context (site · night) → the target and
    tonight's windows → the capture plan → a conditions summary (to the detail screens) → a rig
    summary (to the full rows).
  - Save sits in the bottom bar.
  - This amends ADR-015 §2's "same sections and order" (UX-01, UX-02).
- **F4 — disclosure and modes (RD-06, RG-06): M0.**
  - **Always visible:** the verdict and its reason, usable time, time needed, when capture ends,
    total integration, the weather summary with its age and a "stale" label, the attribution, and
    unknowns.
  - **One tap away,** in collapsed sections whose summary states facts, not verdicts, and whose
    state is remembered:
    - the budget breakdown lines;
    - the √N help text (the √N values stay visible, labelled relative);
    - the assumptions panel;
    - every weather variable and the hour strip;
    - the rig's reference rows;
    - sky-darkness detail and the map link.
  - Zone captions appear once per section; the rule that every time names its zone stands.
  - **No Basic/Advanced modes,** and no density preference. Both stay possible later, only on new
    evidence.
- **Amendments approved here, recorded by ADR-019 (S4.D):**
  - ADR-015 §2: the planner's order, and two detail routes in the route map;
  - ADR-009 §2's "each shown on its own line": on its own line **within the budget details**, one
    tap away. Nothing is removed.
- **Unchanged:**
  - PD-14 (Tonight fixed, no customisable dashboard);
  - ADR-012 (no weather score or good/bad colouring; age and attribution shown);
  - ADR-013 (no score; reasons);
  - SI-003 (√N relative, never SNR);
  - SI-008;
  - every calculation.
- **Out of these decisions, with their homes** (the research's §8):
  - the chart's redesign, weather icons and a √N graph: Stage 6;
  - typography and the collapsed forms' look: Stage 5;
  - the map link: Stage 7;
  - "Fit tonight"'s wording: RD-14 (S4.R5).
- No code changed.

### RD-07 and RD-14 decided: the Library's role and the vocabulary (S4.R5, 2026-09-27)

- **Context:** the research is `refinement/research/S4.R5_LIBRARY_AND_VOCABULARY.md` (committed
  `160ee37`). Today the Library's rig and target lists are the planner's pickers: a tap changes the
  current plan (TD-053).
- **Decided by:** the project owner, in chat, choosing the recommended option on each question.
- **H1 — the Library (RD-07): LB1 + PR2.**
  - The Library manages the reusable things (rigs, targets, sites). A tap opens or edits and
    **never changes the plan**.
  - A rig, target or site is chosen for the plan only from the planner, Tonight's context line and
    the first run (the `/select/…` pickers).
  - A target has an explicit **"Plan this target"** action. It starts a new plan with it, and RD-05's
    guard applies.
  - **Progress moves to the Logbook**, as "Progress by target". It stays on an entry's detail and on
    a target's page.
  - "Add from a photo" stays on the rig list, in both the Library and the picker.
  - This resolves TD-053 when implemented, and amends ADR-015 §7.
- **H2 (RD-14):** **Rig** (a camera + lens or telescope). "Equipment" and "Equipment profile" are
  retired from the UI.
- **H3 (RD-14):**
  - the thing the user makes is a **Plan** ("New plan", "Save plan", "Your plan", "Copy to another
    night");
  - the tab is the **Logbook**: saved plans before their night, results after it;
  - "Session planner", "Save Session" and "New Session" are retired. "Session" stays a code term.
- **H4 (RD-14): the glossary is accepted as proposed** (the research's §5):
  - plan states: Not saved · Saved · Saved · changed;
  - result states: Tracking · Completed · Partly · Not done · Old log;
  - actions: Record result / Edit result; Track live (optional);
  - "Dark", with its limit beside the times. The standard civil, nautical and astronomical twilight
    names appear on the Night & Moon detail only. "True Night Window" and "Astro Dusk/Dawn" are
    retired;
  - the budget: Integration · Imaging time · Time needed · Total time. The calibration and setup
    lines stay inside Budget details. "Acquisition", "Window load" and "Session budget" are
    retired;
  - the verdict headline: Fits · Tight · Doesn't fit · No window · Needs a target / a block,
    followed by "tonight" or the date, as in "Fits: 2 h 05 min needed of 4 h 20 min usable";
  - "Export as file";
  - "Name (optional)" for the Stage 8 name field.
- **Kept as they are:** Site, Target, Library, Progress, Imaging window, Darkness limit, Relative
  stacking gain (√N vs one frame) (SI-003), and Red field mode.
- **Consequences:**
  - ADR-019 (S4.D) records the ADR-015 §7 amendment;
  - Stage 5 puts the vocabulary in one shared place, with a test that keeps retired terms out of
    `lib/presentation`;
  - Stages 6, 8 and 9 apply it with their screens;
  - the core-loop E2E test is updated with each renamed label (trap 19).
- No code changed.

### S4.V1 — saved-and-edited lifecycle clarification (2026-09-27)

*Its result guard and Stage 6/8 split are superseded by "S4R-01 and S4R-02 decided" (S4.V2) below. Kept as written.*

The owner requested the fix for S4V-01 after Stage 4 validation. This documentation correction
applies E2's saved-plan protection to both `planned` and `draft` with `plannedAtUtc`, as defined
in ADR-019 §3.1. It retains explicit Save and the existing snapshot-refresh rule; it does not
introduce a new status, automatic Save or automatic deletion. A result for an edited plan first
requires review and an explicit Save of that entry, or Cancel. The result then uses that saved
version. This is the conservative use of the existing Save behavior, not approval for automatic
reconciliation of two versions. Code implementation remains in Stages 6 and 8. Independent
Stage 4 revalidation is still required.

### ADR-019 accepted (S4.D, 2026-09-27)

- The owner accepted ADR-019 in chat. It records RG-04, RD-05, RD-04, RG-05, RD-06, RG-06, RD-07 and
  RD-14 as one design.
- It amends:
  - ADR-009 §2 (display only);
  - ADR-014 §3;
  - ADR-015 §2, §3's route map and §7;
  - ADR-016 §2 and §10.
- `docs/IA_WIREFRAMES_ADDENDUM.md` holds the low-fidelity screens. `IA_WIREFRAMES.md` stays as it
  is.
- DEV-P9 records UX-04 and UX-11 until Stage 6 builds them.
- Next: S4.T (provisional Tasks for Stages 5, 6, 8 and 9), then a fresh-session Stage 4 validation.

### S4R-01 and S4R-02 decided: saved plans are immutable references (S4.V2, 2026-09-27)

- **Context:** the fresh-session revalidation after S4.V1 (`refinement/STAGE_4_REVALIDATION.md`,
  `750f0a7`) failed on two S4.V1 rules that the owner had not approved:
  - S4R-01: a result for Saved · changed went through Review → Save → result, so it could be
    recorded against the re-saved working night;
  - S4R-02: Stage 6 would stop saved plans rolling forward before Stage 8 supplied the working
    copy.
- **Decided by:** the project owner, in chat: **R2 + D1, with a clarification.**
- **The invariant (owner):**
  - the **plan snapshot** is the immutable intent for the night it was saved for;
  - the **result** is the reported actual outcome for that same snapshot;
  - the **current working copy** is independent future planning state.

  Later edits in the planner never change the night, site, target, capture blocks or other saved
  context against which that night's result will be recorded. The owner's example: a plan is saved
  for Friday, then the working planner moves to Saturday and some fields change. Friday's saved plan
  stays Friday's and awaits Friday's result. The Saturday changes belong to the working copy and are
  never substituted into Friday's result.
- **S4R-01 = R2, as clarified:**
  - the flow is: saved plan → **Review saved plan** → report outcome → **Save result**. The review
    shows the saved snapshot for that completed night, never the planner's current state;
  - no Save plan is required to report a result. **Not done** is recorded directly against the
    saved plan, without saving the working copy;
  - for **Completed as planned** and **Partly**, the reported actuals belong to the result/log record
    and never change the saved snapshot;
  - no result is recorded for a planned night that has not ended;
  - opening an old saved plan to report its result never asks Save · Discard · Cancel about an
    unrelated working copy, which is kept as it is.
- **S4R-02 = D1:**
  - Stage 6 may fix the lifecycle and UX of never-saved drafts and working plans, but it does not
    partly change saved-plan rollover;
  - Stage 8 delivers the whole transition at once: a past saved plan stays on its original night,
    awaiting its result, and an independent working copy is available for the current planning
    night;
  - until then, saved plans keep today's behaviour. No intermediate state in which a saved plan stops
    rolling forward while no working copy exists.
- **Also by the owner:**
  - S4R-03: TD-057 must not propose writing or changing a saved plan at a rollover;
  - S4R-04: ADR-019 records its post-acceptance amendments (S4.V1, S4.V2) and their validation
    provenance.
- **Inferred by S4.V2: withdrawn by S4.V3.** S4.V2 listed five inferred rules:
  - a re-save policy;
  - Discard on a saved entry;
  - the working copy's night;
  - "ended" as the SessionNight end;
  - the live mode.

  The owner did not approve them as decisions. The first four are now Stage 6/8 design questions
  (`refinement/POST_ROADMAP_PLAN.md`, S4.V3, "Deferred / implementation decisions"). The live
  tracker stays supported, as ADR-019 §4 already decided. See "Bounded validation for analysis and
  decision Stages" below.
- **Superseded:** S4.V1's result guard (Review plan → Save plan → result), and its rule that Stage 6
  preserves saved plans in place before Stage 8.
- **Unchanged:** every other Stage 4 decision.
- **Records:** ADR-019 §3.1 as revised, with a provenance note on its status line; the ADR-014
  pointer; D5; addendum §3.10; research notes (S4.R3 §13, RG-04 §14); P6.1, P6.7, P8.1–P8.3 and the
  S4.V2 matrix; TD-057.
- Documentation only. Next: a fresh-session Stage 4 revalidation.

### Bounded validation for analysis and decision Stages; S4.V2's inferences withdrawn (S4.V3, 2026-09-27)

- **Context:** the owner saw a validation loop. Each documentation validation derived more
  lifecycle policy, turned it into requirements, then validated the larger specification. Stage 4
  is an analysis-and-decision Stage: its validation checks the approved scope and the owner's
  decisions, and does not go on designing the product.
- **Decided by:** the project owner, in chat.
- **1. S4.V2's inferred rules are not owner decisions.** Only behaviour that follows directly from
  an approved decision is kept. In particular:
  - **re-saving:** the detailed re-save policy (the same night and site, or a new saved plan) is
    not frozen in Stage 4. Save and version semantics are left to Stage 6/8 design;
  - **the working copy:** its rollover algorithm is not frozen beyond the approved E2, R2 and D1
    behaviour;
  - **when a result may be reported** is not derived from the SessionNight noon boundary.
    SessionNight defines night and time semantics for planning. It does not by itself decide when
    the user may report that an imaging session has finished;
  - **the optional live tracker** stays supported, as already decided (ADR-019 §4).

  Unresolved implementation-level cases are Stage 6/8 design questions, not Stage 4 blockers
  (`refinement/POST_ROADMAP_PLAN.md`, S4.V3, "Deferred / implementation decisions").
- **2. The Stage 4 validation scope is frozen.** The next independent validation is the final,
  bounded Stage 4 validation. It answers only whether:
  1. S4.R1–S4.R5 were completed;
  2. every research gate required by Stage 4 has an explicit owner decision;
  3. ADR-019 faithfully represents those approved decisions;
  4. the wireframe addendum is consistent with ADR-019;
  5. S4.T maps the approved design into the appropriate later implementation Stages;
  6. the documents contain no direct contradiction that makes an approved core flow impossible;
  7. no Stage 4 acceptance criterion remains unmet.

  A finding is **BLOCKING** only if it demonstrates a direct contradiction with an approved owner
  decision or an explicit Stage 4 acceptance criterion. These are **not** Stage 4 blockers:
  - an unspecified implementation detail;
  - a hypothetical edge case;
  - an alternative design;
  - a policy that can safely be decided during Stage 6/8 implementation.

  Record them as `DEFERRED / IMPLEMENTATION DECISION` if useful. A validation creates no new
  product requirements. It does not derive new owner decisions and then fail the Stage because
  those derived decisions are unspecified.
- **3. Convergence:**
  - if the bounded validation passes, Stage 4 closes and Stage 5 becomes the next allowed action;
  - if it fails, the report names only the exact approved decision, or Stage 4 acceptance
    criterion, that is contradicted, with evidence;
  - Stage 4's scope is not expanded.
- **For future Stages:** the bounded-validation rule applies to every analysis-and-decision Stage
  (`CLAUDE.md`, "Validation Rules" — since 2026-09-27 "Verification Policy (canonical)"; `refinement/POST_ROADMAP_PLAN.md` §9.8).
- **Records:**
  - ADR-019's status line and §3.1 (reduced to the approved decisions);
  - the ADR-014 pointer, §3's Discard line, addendum §3.10, S4.R3 §13;
  - P6.1, P6.7, P8.1–P8.3;
  - the plan's S4.V3 section (the deferred list and the bounded scope) and §9.8;
  - `CLAUDE.md`'s Validation Rules; `PROGRESS.md`.
- Documentation only. Next: the final, bounded, fresh-session Stage 4 validation.

### One canonical Verification Policy (governance correction, 2026-09-27)

- **Context:** Stages 1–4 each needed the owner after two failed validations. The causes were
  overlapping test rules (`CLAUDE.md`, `.agents/rules/03-testing.md`, plan §9.8, `TEST_PLAN.md`),
  no evidence-reuse rule (the full gate rerun on unchanged code), reviews widening their own
  acceptance surface, corrections triggering whole-Stage revalidation, and a `PROGRESS.md` that
  had grown into a history.
- **Decided by:** the project owner, in chat (a governance prompt).
- **Decision:** `CLAUDE.md`, "Verification Policy (canonical)", V1–V8, is the only statement of
  required verification by change class, evidence reuse, the frozen review surface and what may
  block, correction-scoped revalidation, PASS reopening, and stop/convergence. It generalises the
  bounded-validation rule above to every validation and keeps that rule verbatim for
  analysis-and-decision Stages. Other documents refer to it.
- **Records:** `CLAUDE.md` (the policy; rules 13, 16, 17; "Testing"); `.agents/rules/03-testing.md`;
  `TEST_PLAN.md` "Required Checks"; plan §9.1, §9.4, §9.8 and the Stage 5 validation;
  `refinement/prompts/INDEPENDENT_STAGE_VALIDATION.md` and `CONTINUE_CURRENT_WORK.md`;
  `.github/workflows/ci.yml` (documentation-only changes skip the gate); `PROGRESS.md`, reduced to
  the handoff, with its history moved verbatim to `PROGRESS_HISTORY.md`.
- Process only: no product, scientific or architecture decision changed.

### RD-09 decided: undo for edits inside a plan, confirm for stored records (Stage 5, 2026-09-27)

- **Context:** the options prepared in Stage 5 planning (`refinement/POST_ROADMAP_PLAN.md`, "RD-09
  — confirm or undo", `a354032`).
- **Decided by:** the project owner, in chat: **M + S1**, the recommended options.
- **Q1 = M:**
  - deleting a capture block (an edit inside a plan) happens at once, with an Undo message; the
    block is restored exactly;
  - deleting a stored record (a rig, a target, a site, a Logbook entry), Abandon, Restore and
    leaving unsaved changes keep a confirmation, in one shared style.
- **Q2 = S1:** every deletable item has a visible Delete; swipe stays as a shortcut to the same
  pattern, and a cancelled swipe returns the row.
- **Amends** `IA_WIREFRAMES.md` §3 ("no destructive action without a confirmation") for edits
  inside a plan only. "No silent loss" stands. ADR-015 carries the pointer.
- **Built by** S5.8 (the patterns). Adopted by Stage 6 (capture blocks), Stage 8 (the Logbook) and
  Stage 9 (the Library). Where a visible Delete sits is decided at adoption.
- No code changed.

### Stages 6–11 amended after Stage 5; the dedicated tracker leaves the target product (2026-09-27)

- **Context:** Stage 5 closed (`4a9d5c7`). The owner's planning brief,
  `refinement/prompts/AMEND_STAGES_6_11_AFTER_STAGE5.md`, amends the remaining Stages 6–11 from the
  manual dogfooding (08) and a post-Stage-5 UI/UX analysis. That analysis is not in the repository;
  its conclusions enter only through the brief. The brief amends the plan and does not replace it.
- **Decided by:** the project owner, through the brief (an owner-supplied planning prompt; `CLAUDE.md`,
  "Active Prompt Rule").
- **1. The dedicated tracker leaves the target product.**
  - The target flow is unchanged (ADR-019 §2): Planner → Save plan → imaging outside the app →
    Logbook → record the result (Completed as planned · Partly · Not done).
  - **The dedicated live tracker** (Track live, Start, the tracker screen and the workflow built
    only for it) **is no longer part of the target product, not even as an optional mode.**
    RG-04 D1 foresaw this: "The tracker may later be hidden or removed (option C) … that would be a
    new owner decision." This is that decision, for the UI.
  - **Supersedes:**
    - RG-04 D1's "the tracker optional" half;
    - ADR-019 §2's optional path and §4's "Track live (optional)";
    - S4.V3's "the optional live tracker stays supported";
    - P8.4, "The live mode as an option";
    - the "Track live" items of `IA_WIREFRAMES_ADDENDUM.md` §1–§3.
  - **Stage 8 retires it safely** (P8.4 in the plan): first a bounded dependency audit that sorts
    every tracker dependency into:
    - (A) UI that exists only for live tracking: removed;
    - (B) domain and data logic that keeps history trustworthy: kept or repurposed;
    - (C) persisted data: still read, exported and backed up, migrated only under the migration
      workflow;
    - (D) tests only of the removed UI: retired deliberately, each with its reason;
    - (E) tests of still-valid domain and history behaviour: kept.

    Then the result workflow (P8.1–P8.2), then the UI's removal. A run still in progress at the
    upgrade can still be finished or marked not done. **No data is deleted, and nothing is removed
    before P8.1–P8.2 exist.**
  - **Until then** the tracker stays as built. Stage 6 keeps it reachable off the primary path (P6.1's
    ⋮ entry, Tonight's run card), because Start is today's only way to record a result. Stage 6
    invests nothing in it: no redesign and no new dependence on it.
  - **Left to P8.4's audit, within this rule:**
    - which code, events and tests stay;
    - whether CALC-35 and CALC-36 are marked retired (never deleted from history);
    - the ADR-016 amendment text, recorded when P8.4 lands.
  - **Consequences:**
    - RD-12 lapses: the resume prompt goes with the tracker, and ADR-019 §4 already expected Finish to
      lead to the result form;
    - RD-13 narrows to existing accepted-estimate events and the "reported as planned" label;
    - UX-13 and UX-26 close when P8.4 lands, and TD-063 is re-verified against it;
    - the core-loop E2E test moves to Save → result, and the tracker's lifecycle rows (`TEST_PLAN.md`
      L4–L6, L8) are replaced deliberately.
- **2. Also recorded from the brief** (owner directions, not research results):
  - **the hierarchy:** the answer first, then compact context, then technical depth on demand.
    Disclosure never hides what materially changes the answer (`PRODUCT_DIRECTION.md` §5.2,
    clarified);
  - **ownership:** one owner per responsibility for Stages 6–11 (`refinement/POST_ROADMAP_PLAN.md`,
    "Stages 6–11: shared rules"). Stage 5 stays closed: no S5.10 and no second design system;
  - **a relative-stacking-gain graph is a Stage 6 deliverable** (P6.10): √N per (filter, exposure)
    group, never SNR (SI-003);
  - **optional plan names are kept** (P8.6; 08 §24);
  - **the author's own links** (https://github.com/Buffur and https://www.reddit.com/user/Buffur/)
    do not wait for RD-01. RD-01 still governs the project identity and its functional links;
  - **the logo** is chosen by the owner from alternatives (P9.4). **The licence** changes only after
    RG-12's research and an owner decision (P9.5).
- **Unchanged:**
  - every other Stage 4 and Stage 5 decision;
  - ADR-019's lifecycle (§3, §3.1), and §4's result form, count events and honesty rules;
  - RD-08 (open);
  - every calculation.
- **Records:**
  - `refinement/POST_ROADMAP_PLAN.md`: the header, §3, "Stages 6–11: shared rules", Stages 6–11,
    §6.2, §7, §8 and Appendices A–B;
  - `refinement/PRODUCT_DIRECTION.md` §3, §4, §5.2, §9 and §10;
  - ADR-019's status and pointers under §2 and §4, and a pointer under ADR-016;
  - the banner of `IA_WIREFRAMES_ADDENDUM.md`;
  - `refinement/PROGRESS.md`.
- Documentation only. No code changed.

### S4-DEF-04 decided: Discard reverts a changed saved plan to what was saved (Stage 6, 2026-09-28)

- **Context:** the options prepared in Stage 6 planning (`refinement/POST_ROADMAP_PLAN.md`, "Stage 6
  gates", `9e40b81`). ADR-019 §3 and §3.1 left open what Discard does with a Saved · changed plan's
  unsaved changes; the invariant says Discard never changes or removes a saved snapshot.
- **Decided by:** the project owner, in chat: **R**, the recommended option.
- **R:** Discard puts the entry back exactly as it was saved.
  - Its night, site, target, rig and blocks are read from its plan snapshot, and it becomes Saved
    (`planned`) again.
  - The snapshot and the saved time are not touched, and nothing is deleted.
  - If the snapshot is unreadable, or names a site, target or rig that no longer exists, nothing
    changes and the user is told (SI-008). The user can then Save or Cancel instead.
- **Amends** ADR-014 §3's lifecycle with one transition: Saved · changed (`draft` with
  `plannedAtUtc`) → Saved (`planned`), by Discard, restoring the plan from the unchanged snapshot.
  ADR-019 §3 carries the pointer.
- **Rejected:** K (keep the changes with the entry, the button reading "Keep changes"). Deleting the
  entry or its snapshot was never an option (the invariant).
- **Built by** S6.3 (2026-09-28). No code changed by this entry.

### RD-08 decided: tracking is the rig's default with a per-plan override (Stage 6, 2026-09-28)

- **Context:** the options prepared in Stage 6 planning (`refinement/POST_ROADMAP_PLAN.md`, "Stage 6
  gates", `9e40b81`): T1 per rig, T2 per plan, T3 the rig's default with a per-plan override. 08 §21:
  the same rig is used with and without a tracking mount.
- **Decided by:** the project owner, in chat: **T3**, the recommended option. The owner's reasons
  and conditions:
  - the user should not have to open the rig's settings to change tracking for one session;
  - the rig keeps its normal (default) tracking;
  - the planner lets the user change the **effective** tracking for the current plan without
    changing the reusable rig;
  - the plan (and its saved snapshot) keeps the effective value its calculations and history used;
  - **Unknown** stays possible where the rig's default is not known;
  - the shipped example rig's tracking is never turned into a confirmed real-world fact.
- **T3, as it applies to the current model** (verified at `822a16d` before recording):
  - **the default** is the rig's existing `trackingType` (`optical_rigs.tracking_state`,
    ADR-011 §5), with `unknown` for anything not declared. ADR-011 §5 and PD-11 are unchanged. The
    seeded rig declares none and stays `unknown` (the verified-seed policy; nothing infers tracking);
  - **the override** belongs to the plan: absent means "the rig's default". No existing field holds
    it. A plan's live state is kept in `session_logs` columns (night, site, target, rig) and
    `capture_blocks`, and a plan snapshot exists only once saved, and is immutable (ADR-019 §3.1),
    so it cannot carry a draft's choice. The smallest clean representation is **one nullable plan
    field** (a schema change with its migration test), as the prepared option says;
  - **the history** reuses the existing snapshot: the plan snapshot already records the rig's
    `tracking` (`SessionSnapshotBuilder`); it will record the effective value and where it came from
    (the rig's default or the plan), as keys of the existing JSON snapshot, not a new concept;
  - **calculations** (`CapabilityCalculator`, NPF and the maximum sub) read the effective value.
    Unknown keeps PD-11's "if untracked" guidance, shown as a missing input (S6.9);
  - an override never writes to the rig, and tracking never goes into global Settings (§8 of the
    plan); `Tracked` stays distinct from Track live.
- **Built by:** Stage 7 (the plan field, the planner's control, the snapshot keys and the effective
  value in the calculations), as the frozen plan already assigns a plan-level choice. **S6.9** (Stage
  6) shows the effective tracking where the warning needs it (today the rig's default) and unknown
  tracking as a missing input; it moves nothing.
- **Built by S7.1 (2026-09-29):** `session_logs.tracking_override` (v19), `EffectiveTracking.of`,
  `CapabilityCalculator.evaluate(tracking:)`, the planner's "Tracking for this plan", the snapshot's
  `tracking` {effective, source}, the lifecycle (Copy carries it, New starts without it, Discard
  restores it), and the export's `tracking_override`. The rig editor's field reads "Tracking
  (default for plans)".
- **Rejected:** T1 (the rig only; the inconvenience of 08 §21 stays) and T2 (the plan only; a rig
  that is always tracked would lose that fact, and every plan would have to answer it).
- Documentation only. No code changed.

### RD-10 and RD-11 decided: the candidates' order, and where the gate controls live (Stage 6, 2026-09-28)

- **Context:** the options prepared in Stage 6 planning (`refinement/POST_ROADMAP_PLAN.md`, "Stage 6
  gates", `9e40b81`).
- **Decided by:** the project owner, in chat, both the recommended options.
- **RD-10 = O1:** "What can I image tonight?" orders its candidates by default by usable time, then
  by frame fill (how much of the frame the target fills with the user's rig; unknown, as without a
  rig, sorts last), then by name. A chain of measured quantities, never combined into one number
  (ADR-013 §5: no composite score). The user's own sort choices stay, and the list header names the
  order ("Usable time, then frame fill"). Built by S6.14.
- **RD-11 = S9:** the Moon and cloud gate controls (ADR-013 G4/G5; TD-050) go to Settings in Stage 9
  (P9.3), where RG-13 decides once where each setting belongs. Until then the gates stay off and
  unreachable, and TD-050 stays open. **S6.15 does not exist.**
- **Rejected:** RD-10's O2 (usable time, then the maximum altitude) and O3 (thresholds and groups);
  RD-11's S6 (Settings now, as S6.15) and P (in the planner).
- Documentation only. No code changed.

### Stage 6 corrective pass decided: TD-075–TD-080, the planner's order, the core screens' finish (Stage 6, 2026-09-28)

- **Context:** the owner's manual UX review of the `.s2check` app
  (`refinement/evidence/STAGE_6_FIVE_SECOND_TEST.md`, `142341a`) recorded four current-stage issues
  (TD-075–TD-078), two new bounded follow-ups (TD-079, TD-080) and two questions for the owner: the
  planner's order (review item 5.1) and who owns the visual finish of Tonight and the planner (items
  1.1, 1.2, 3.2, 4.1, 6.1). `refinement/PROGRESS.md` listed them as the decisions before the Stage 6
  validation.
- **Decided by:** the project owner, in the session prompt of 2026-09-28: one final bounded Stage 6
  corrective Task before the validation (S6.16 in the plan).
- **1. TD-075 to TD-078 are fixed before the validation,** in that one Task. Stage 6's design is not
  reopened broadly and nothing is pulled forward from Stages 7–9.
  - **TD-075:** under "Needs a site" or "Needs a target", the reason matches the missing input,
    never the empty plan's "no light frames". Unknown and missing-input honesty stays, and a real
    capture-plan warning still shows once the planning context exists.
  - **TD-076:** the relative-stacking-gain graph and its √N meaning stay. The plan's own point is
    identifiable at once, visually and in words, and the comparison end never reads as a target or
    a recommendation. Unchanged: √N relative gain only, per compatible-frame group, no physical SNR,
    no image-quality prediction, a text alternative, Stage 5's visual and accessibility rules. The
    scientific model is not redesigned.
  - **TD-077:** "Your plan" is a card heading in the existing semantic heading role, with no ad hoc
    font size, and the card's target, rig and content no longer outrank it.
  - **TD-078:** the summary under Night & Moon's summary card is not repeated. Nothing useful is
    removed; one clear summary stays, with the deeper detail where it adds information. Not the
    Stage 9 richer-detail redesign.
- **2. The planner's order: ADR-019 §6 is amended.** Answer first stays: the practical status or
  verdict leads. Below it, the planning workflow follows this conceptual order:
  1. the plan's status, the practical answer;
  2. the date and the site;
  3. the target;
  4. the rig;
  5. the capture plan;
  6. the optional night and target-opportunity analysis;
  7. the supporting conditions, such as Weather and Night & Moon;
  8. deeper technical detail on demand.

  It is a conceptual order, not permission to duplicate information or to make a card of every item.
  The status keeps Stage 6's primary-answer requirements (fit, time needed, usable time,
  integration, the main blocker or reason, the saved or changed state) and never moves below the
  form content. **What it changes in §6:** the target's windows leave item 4 for the analysis after
  the capture plan; the rig moves above the capture plan; the conditions follow the analysis. Items
  1–3 and 8 of §6, and §7, stand. A pointer marks §6.
- **3. The visual finish of the core Tonight and planner screens stays in Stage 6,** and is not
  deferred to Stage 9, for the core-screen observations already recorded in the review:
  - **Tonight:** a stronger screen title in Stage 5's typography; the date and site as a
    deliberate, structured context area (a box or card is one option, not a requirement; the
    context line's approved meaning stays, without redundant information); "Your plan" (TD-077);
    Open planner reading as an intentional, important action; the distinct roles of Choose a target
    and What can I image tonight? kept, with TD-080's wording;
  - **the planner:** the status area finished as Stage 6's primary surface in the existing design
    system; the order above; the timeline and opportunity section as supporting analysis that does
    not interrupt building the plan; the recorded visual-integration issues of "Tonight for this
    target", without a new chart redesign beyond Stage 6's contract.

  **Stage 9 keeps:** secondary screens, global and secondary polish, Settings, the Library, the
  detail screens' richer presentation, branding and its other scope. No new design system, and no
  visual clone of another product.
- **4. TD-079 is fixed now as bounded recovery, never a global undo.** Stage 5's reversible-action
  patterns and the current planner state model come first. A clear way back for the confirmed
  cases: Fill or Trim, a capture-block edit already saved, and "Start from the example plan"; the
  mechanism may differ by operation where that is cleaner. The user can see how to recover right
  after the change; recovery restores the actual previous state; saved historical intent is never
  changed silently; no second planner-state architecture and no large persistent history for Undo;
  reduced motion is respected; focused tests. A case that cannot be made safely reversible without
  substantial new architecture is reported with its evidence, not built.
- **5. TD-080 is fixed now.** Both functions stay: one browses the whole target catalogue, the other
  lists the candidates for the current night and site. Wording, supporting copy or presentation
  tells them apart before a tap, concisely, with the existing vocabulary, and with no explanatory
  paragraphs on Tonight's primary surface.
- **6. Deferred, with their owners unchanged:**
  - Stage 7: binning; ISO and gain; calibration parameters' inheritance and ownership; darks, flats
    and bias; elevation and Bortle automation; SQM's ownership and source (RG-08 to RG-11);
  - Stage 8: result reporting; Completed, Partly and Not done; planned against actual; the Sessions
    and Logbook interaction; the Download (export-all) classification (P8.1, P8.2, P8.7);
  - Stage 9: the full Settings review; the detail screens' richer presentation; app-wide secondary
    polish; branding and the licence.
- **7. The five-second test:** the owner's review does not count as it. After S6.16 is verified,
  the separate `.s2check` app is rebuilt if the core screens changed, the owner's own app is left
  untouched and the prepared test plan stays equivalent; then, ideally, one independent participant
  who has not worked on the product answers, recorded word for word. Without one, the test stays
  UNVERIFIED and the Stage 6 validation records the gap (V7). No human evidence is fabricated, and
  an agent is never the participant.
- **Records:** ADR-019's status line and pointers under §5 and §6; `refinement/POST_ROADMAP_PLAN.md`,
  S6.16 (its acceptance criteria), Stage 6 validation's surface and Stage 9's scope note.
- **Built by** S6.16 (2026-09-28). No code is changed by this entry.

### RG-11 decided: camera classes and light-frame parameters (Stage 7, 2026-09-29)

- **Context:** S7.R1's research, `refinement/research/RG-11_CAPTURE_PARAMETERS.md` (`1fa3992`), with
  six questions (§11).
- **Decided by:** the project owner, in chat, choosing "accept all recommended": each question's
  recommended option, with the example rig left Unknown.
- **C1 — a camera class on the rig:** Phone · DSLR/mirrorless · Astro camera (colour) · Astro camera
  (mono) · Unknown (the default). Chosen by the user in the rig editor; never inferred from a name or
  a file; existing rigs read as Unknown. **The example rig stays Unknown** (the owner chose not to set
  it from its cited source).
- **B1 — binning:** offered only for the astro-camera classes and Unknown, default 1 × 1, as a record.
  No calculation reads it (ADR-009 L6 and the rig-pitch capability stay as they are); a phone's
  binning remains its rig's mode (RG-02 §5). Stored values on other classes are kept, not shown.
- **W1 — white balance:** not modelled.
- **F1 — focus:** no field; ADR-009's refocus overhead stays the only focus concept.
- **I1 — the interval:** the per-frame overhead stays the one interval concept, relabelled "Time
  between frames" with the definition of S7.R1 §6 (download plus any set delay; settling after a
  dither belongs to the dither overhead, never both). **No budget change**; ADR-009 is not amended.
  Only that Settings row's label and help change (P9.3 keeps Settings' layout).
- **P2 — proposals:** a new light block proposes the previous light block's exposure, sensitivity
  (kind and value) and binning, shown as a proposal and stored only by the user's Save. P1 (the rig's
  maximum sub) and P3 (from a photo) are not adopted.
- **Also recorded as facts (S7.R1 §9), not choices:** ISO for phones and DSLR/mirrorless, gain for
  astro cameras, the neutral choice for Unknown; never both on one block; never required; no
  conversion (SI-004).
- **Handed to RG-10 (S7.R2):** an astro camera's offset; in-camera long-exposure noise reduction;
  the cooled modifier.
- **Consequences:** ADR-020 (S7.D) records this with RG-10's decision. By the plan's "Order" rule, C1
  splits S7.2 into the class on the rig (a schema change) and the light-block form. No ADR-009 Task
  is added (I1).
- **Rejected:** C2, C3; B1+, B2, B3; W2; F2, F3; I2–I4; P1, P3.
- Documentation only. No code changed.

### RG-10 decided: calibration workflows (Stage 7, 2026-09-29)

- **Context:** S7.R2's research, `refinement/research/RG-10_CALIBRATION_WORKFLOWS.md` (`bae017e`),
  with six questions (§10).
- **Decided by:** the project owner, in chat, choosing "accept all recommended".
- **L1 — inheritance:** an inherited value is copied from a chosen light group when a calibration
  block is created, shown with its origin, and kept; a domain check warns (in words, never blocking)
  when the block matches no light group, with a one-tap fix.
- **D1 — dark flats:** a fifth frame type, optional for every class.
- **T0 — sensor temperature:** not modelled. **O0 — offset:** not modelled.
- **N1 — in-camera long-exposure noise reduction:** a camera switch shown for DSLR/mirrorless and
  Unknown rigs, off by default; when on, each light frame adds a dark of its own exposure to in-window
  calibration and to its atomic fit event. **Amends ADR-009** (§2, §4, §6), with new vectors.
- **H1 — tips:** a one-line tip per calibration frame type, hideable; warnings are never hidden.
- **Recorded as facts, not choices (RG-10 §4):** what darks, flats, bias and dark flats match; bias
  optional for every class; flats' exposure independent, with no target-level guidance.
- **Rejected:** L2, L3; D0; T1; O1; N0, N2; H2.
- **Recorded in** ADR-020 (Part F, S7.D, the same day), with RG-11. Documentation only.

### RG-07 decided: target names and search (Stage 7, 2026-09-29)

- **Context:** S7.R3's research, `refinement/research/RG-07_TARGET_CATALOG.md` (`cd248ce`), with
  three questions (§9).
- **Decided by:** the project owner, in chat: **T1 only**, the recommended option.
- **T1:** the bundled objects gain searchable aliases from the pinned OpenNGC v20260501 (the same
  source and CC BY-SA 4.0 licence): the NGC/IC designation of each Messier object, every OpenNGC
  common name, and the Caldwell and LBN numbers in its `Identifiers`. They live in their own table
  keyed by the catalog id and are rebuilt from the asset when the catalog version rises, so existing
  installs gain them without any user-edited row changing and deleted targets stay deleted. Search
  ignores case, spaces, hyphens and leading zeros in a designation's number, accepts "Messier" and
  "Caldwell" for "M" and "C", and keeps substring matching on names; results are ordered by how the
  query matches, then by the id, with no score (the research's §6 examples become tests).
- **Not adopted:** more objects (no T2 subset; the candidates list keeps its 164 catalog objects), another
  catalog (T3), and any online lookup (T4). Custom entry stays for objects in no bundled source.
- **Consequences:** S7.4 implements T1: `tool/build_catalog.dart` writes the aliases, the catalog
  version rises, a schema change adds the alias table; `OPENNGC_NOTICE.txt` and About say what is kept.
  Nothing leaves the device.
- Documentation only. No code changed.

### RG-08 and RG-09 decided: the site form (Stage 7, 2026-09-29)

- **Context:** S7.R4's research, `refinement/research/RG-08_09_SITE_AUTOMATION.md` (`3c70ac5`), with
  three questions (§8).
- **Decided by:** the project owner, in chat, choosing every recommended option.
- **E2 — elevation (RG-08):** optional and **Unknown by default**. The column becomes nullable; every
  stored value is kept exactly (ADR-011 §6's rule); a snapshot records null when unknown. It stays
  editable without prominence. No automatic source (E1 not adopted), no GPS altitude, never 0 m as a
  default.
- **S3 — Bortle and SQM (RG-09):** both stay manual, optional and Unknown by default, in one collapsed
  "Sky darkness (optional)" section of the site form, with its source and date shown when stored, and a
  link to look the value up on the light-pollution map at the site. No automatic source (none is
  acceptable: S7.R4 §4.2); no Bortle↔SQM conversion (PD-05 unchanged).
- **M2 — the map link (RG-09):** `lightpollutionmap.app`, opened at the site with its documented
  `?lat=…&lng=…&zoom=…` link; About's source line follows. Nothing is fetched; the coordinates leave
  the device only in the link the user taps, as today; the privacy policy's wording is checked.
- **Rejected:** E1, E1b, E3; S1, S4; M1, M3.
- **Consequences:** S7.5 implements them with its frozen scope (the editor's "Use current position",
  the discard guard). Documentation only.

# Part F — ADRs accepted after the Phase 0 baseline

*Part A stays verbatim. New ADRs are added here, numbered after ADR-006.*

## ADR-007: SessionNight and time-zone strategy

Status: accepted (owner, 2026-09-22, TASK 2.1). Resolves PD-01 and PD-02.
**Implementation:** partial.
- **Done (TASK 2.2, 2026-09-22):** §2–§6 and §11 in the pure domain
  (`SessionNight`, `CalendarDate`, `SiteTimeContext` with its mean-solar and
  fixed-offset contexts, `SessionNightResolver`, and a `Clock` in `lib/core/time/`),
  with the §12 matrix as tests. The formula is exactly as written in §3, with no
  deviation.
- **Done (TASK 2.3, 2026-09-22, commit `de1792a`):** §8 (typed per-threshold
  timeline, `NightTimeline`/`SunThresholdResult`) and §9 (shared 5-minute sampling
  grid; `AltitudeCurve`; visibility-window boundary clipping in polar night,
  `VisibilityWindow.clippedAtStart`/`clippedAtEnd`) in the pure domain, plus the
  altitude chart made render-only. The old DateTime-based `calculateNightTimeline`/
  `calculateVisibilityWindows` are now thin wrappers over the new API, so no caller
  needed to change.
- **Done (TASK 2.4, 2026-09-22, commit `1e58fcf`):** §5 (`PlannerViewModel.sessionNight`
  resolves the default night through the injectable `Clock`, and a picked
  `CalendarDate` through `forEveningDate`; `newSession()` clears back to the
  default instead of re-setting a fixed UTC `DateTime`) and §6 (one
  `NightTimeFormatter` — `home_screen.dart`, `sky_darkness_widget.dart` and
  `logbook_screen.dart` no longer call `.toLocal()` ad hoc; every instant is
  labelled "device zone, UTC±HH:MM" since the site's own zone is not available
  before TASK 7.1; times after midnight carry a "+1" marker). §9's "no site set"
  state is implemented (`sessionNight`/`eveningDate` return null without a site;
  Home shows a "No site set" subtitle and a placeholder card instead of the
  default London default). §9's Moon-illumination instant is used as an interim
  choice (`startUtc + 12h`) — **G6 has not formally decided it**, so this is
  recorded as provisional in `docs/SCIENTIFIC_INTEGRITY.md`, not as a closed
  decision.
- **Done (TASK 7.1, 2026-09-23):**
  - `IanaTimeContext` (`timezone` 0.11.1, BSD licence, 10-year data set);
  - a nullable IANA zone per site (schema v12);
  - `NightTimeFormatter` prefers the site's zone (`zoneCaption`, e.g. "site zone
    Europe/London, BST, UTC+01:00") and falls back to the labelled device zone.

  **L1 is fixed for sites that have a zone.** Sites without one, and transient
  positions, keep the mean-solar identity. The zone's *source* (PD-02, deferred to
  7.1) is the TASK 7.3 editor's zone picker, defaulting to the device zone. It is
  never inferred from the device in computation.
- **Done (TASK 7.3, 2026-09-23):** the zone's source is the site editor's picker
  (searchable IANA ids plus "Unknown"), pre-filled for a new site with the device
  zone from `flutter_timezone` behind the domain `DeviceTimeZone` seam — a pre-filled
  choice only, never an input to a computation. `IanaTimeContext` now loads the
  `timezone` package's `latest_all` data set instead of `latest_10y`: the 10-year set
  has only canonical ids, so link ids that devices report (`Europe/Ljubljana`,
  `Asia/Calcutta`, `UTC`) were rejected; a link resolves with its target's rules
  (tested). Canonical zones' current rules are unchanged.
- **Not done yet:** weather alignment (G9); persisting `SessionNight` itself instead of mapping legacy
  instant rows (G11, PD-18) — `home_screen.dart`'s Save Session still stores
  local midnight of the picked evening date, per §10's "legacy rows" proposal;
  `PlannerViewModel.currentAltitude`/`maxAltitude` still run their own
  JD/GMST/LST/LHA pipeline rather than consuming the `AltitudeCurve` (TD-023,
  out of TASK 2.4's roadmap scope).

### 1. Context

The product answers "what can I photograph tonight?", but the code has no definition
of "tonight". Four time bases are mixed (SI-010, TD-001, TD-020, TD-023; code re-read
at `56344e2`):

- **Default date.** `_sessionDate = DateTime.now().toUtc()`
  (`planner_viewmodel.dart:58`, repeated in `newSession()` at `:503`). This is the
  **UTC** calendar date.
- **Timeline and windows.** `calculateNightTimeline` and `calculateVisibilityWindows`
  (`visibility_calculator.dart`) read that `DateTime`'s Y/M/D as the **mean-solar**
  date and scan 24 h from `12:00Z − longitude/15 h`.
- **Date picker.** Supplies a **device-local midnight** `DateTime`
  (`home_screen.dart:129`). Its Y/M/D gets the same mean-solar reading.
- **Altitude chart.** Starts at **device-local** noon of the Y/M/D
  (`altitude_chart_widget.dart:137`). Its "now" dot uses the device clock (`:295`).
- **Night timeline display.** Printed in the **device** zone, with no label
  (`sky_darkness_widget.dart:178`).
- **Lunar illumination.** Evaluated at `_sessionDate` itself (`planner_viewmodel.dart:531`).
  That is "now" on the default path but local midnight after a pick, so the night has
  no defined evaluation instant.
- **Weather.** Requested with `timezone=auto`. Its naive site-local strings are parsed
  as device-local (`open_meteo_weather_repository.dart:66`), and the UTC offset is
  discarded.
- **Sessions.** Stored as an instant (`session_date` epoch), read back as local, and
  printed with a local date (`session_log.dart:65,215`).

Result, verified again for this ADR: at 18:30 PDT on 2026-09-21 in San Francisco,
and at 21:00 EDT on 2026-10-31 in New York, the old rule selects **the next day's**
night.

### 2. SessionNight identity

A SessionNight is identified by **(site, eveningDate)**.

- **eveningDate `D`.** A **civil calendar date at the site**: year, month and day, with
  no time of day and no zone. It is modelled as a date-only value, never as a
  `DateTime` instant.
- **Meaning shown to the user:** "the night that begins on the evening of D and
  continues past midnight into D + 1".
- **Site.** Latitude φ in degrees (north positive) and longitude λ in degrees (east
  positive), with λ normalized to the interval (−180°, 180°]. The site also carries a
  **time context** (§6).

### 3. Window: start and end instants

The window is the half-open UTC interval `[startUtc, endUtc)`.

- **Mean solar offset.** `s(λ) = round(λ × 240 000)` milliseconds. Since 1° equals
  4 min, this is integer arithmetic with an exact, deterministic result.
- **Mean solar noon of solar date d.** `N(d) = d 12:00:00.000Z − s(λ)`.
- **Civil noon of D.** `R = D 12:00` at the site, converted to UTC with the time
  context's offset at that instant. Civil noon never falls inside a DST transition
  under current tz rules, because transitions happen at night.
- **startUtc.** The `N(d)` with d ∈ {D − 1, D, D + 1} that is **nearest to R**. On an
  exact tie, the earlier one is taken; a tie requires the civil offset to differ from
  mean solar time by exactly 12 h, and no current zone does.
- **endUtc.** `startUtc + 24 h` exactly.

Why boundaries sit at **mean solar noon**:

- The Sun is near its daily maximum there. Every dusk that belongs to an evening, and
  the dawn that follows it, therefore falls inside one window.
- The window always contains the local evening.
- The window depends only on λ, D and the time context, **not on any astronomy
  model**. A later improvement to the Sun model can never move a stored night.

Why the **civil** date selects the noon, instead of using the solar date directly: in
date-line zones the solar date differs from the civil date by a day. At Kiritimati
(UTC+14, λ −157.4°), the civil evening of Sep 22 is on solar date Sep 21. Selecting by
civil noon keeps D equal to the user's calendar date everywhere (see T7 and T8).

### 4. Inverse mapping and storage units

- **labelOf(window).** The civil date of `startUtc` in the site's time context.
- **Bijection.** `labelOf(forEveningDate(D)) = D` holds for every D. It was checked over
  730 consecutive days in 13 contexts:
  - Los Angeles, Kiritimati, Tokyo, Berlin, Apia, Urumqi;
  - Asia/Shanghai at Kashgar's longitude, Adak, Tongatapu, Chatham;
  - mean-solar contexts at λ = 180°, −179.99° and 0°.

  The check found 0 violations (scratch script outside the repository, IANA tz data,
  2026-09-22).
- **Storage units.**
  - Instants: UTC, millisecond precision.
  - `eveningDate`: an ISO-8601 date string `YYYY-MM-DD`.

### 5. Default-night resolution

`resolveDefault(now, site)` returns **the window that contains `now`**
(`startUtc ≤ now < endUtc`). Its label is `labelOf(window)`.

- The window's instants depend only on `now` and λ. Only the label depends on the time
  context.
- `now` comes from an injectable `Clock` (TASK 2.2). `DateTime.now()` is not allowed in
  `lib/domain`.
- The default therefore switches exactly once per 24 h, at the site's mean solar noon:
  - After midnight (for example 02:00), the default stays on the night in progress.
  - From sunrise to solar noon it still shows the night that has just ended
    (limitation L4, accepted by the owner).
  - After solar noon, it shows tonight.
- The user can always pick another date.

### 6. Time context, storage and display zone

- **`SiteTimeContext`** is a pure-Dart seam (TASK 2.2) with two members:
  - `offsetAt(DateTime utc) → Duration`;
  - a stable `id`.
- **Implementations:**
  - **Before TASK 7.1:** `MeanSolarTimeContext(λ)` (offset = `s(λ)`, id `solar`) and a
    fixed-offset context. Tests also use a DST-transition fake from `test/support/`.
  - **In 7.1:** an IANA-zone context, added together with the `timezone` package.
- **Production before 7.1:** every site uses `MeanSolarTimeContext`. It agrees with the
  civil rule wherever the civil offset is within 12 h of mean solar time, which covers
  every zone except the date-line anomalies (L1).
- **The device zone is never used in computation.** It is not a time context.
- **Storage.** Every instant is stored in UTC.
- **Display zone.**
  - Use the site's IANA zone when it is known (7.1 onward). Otherwise use the device
    zone.
  - Every displayed time names its zone with an offset, for example
    `19:08 PDT (UTC−7)`.
  - When the display zone is the device zone rather than the site's zone, the UI says
    so.
  - Times after midnight carry a next-day marker. The header reads as a night (for
    example "Night of Mon 21 Sep → Tue 22 Sep").
  - Mean solar time is an identity fallback only and is never shown as a clock zone.
- **One formatter** handles all of this (TASK 2.4), with no ad-hoc `toLocal()`.

### 7. DST and the International Date Line

- **DST.**
  - A window is always exactly 24 h long. DST never changes its instants; it only
    changes how they are displayed. For example, Berlin on 2026-10-24 shows
    13:06 CEST → 12:06 CET.
  - In the fall-back night, the repeated hour is disambiguated by the offset label.
  - In the spring-forward night, the skipped hour simply does not appear.
  - Choosing the noon uses the offset at civil noon, which is never ambiguous.
- **Date line.**
  - λ = 180° and λ = −180° are the same site, so they give identical windows.
  - In a civil context, windows are continuous across the antimeridian: sites at
    179.99° and −179.99° that share a zone start 4.8 s apart.
  - In the mean-solar fallback, the *label* jumps by one day across the antimeridian.
    That is inherent to solar time, and it is why civil identity was chosen.
  - Zones whose civil offset differs from mean solar time by about 24 h are handled by
    §3 once the zone is known (7.1). Examples: Kiribati (Line and Phoenix Islands),
    Samoa, Tonga, Tokelau, Chatham.

### 8. Polar conditions and absence of darkness

- **The window is defined for every latitude and every date.** It is never null.
  Polar states are properties of the **darkness content** of a window, not of its
  existence.
- **Per-threshold result (TASK 2.3).** For each Sun-altitude threshold h (−0.833°,
  −6°, −12°, −18°, and the configurable darkness limit), the result is a typed value,
  never a bare `null`. It is one of:
  - **crossing:** a dusk instant and/or a dawn instant. An interval cut off at a window
    edge is flagged `belowAtStart` or `belowAtEnd`.
  - **neverBelow:** the Sun stays above h for the whole window. At h = −0.833° this is
    midnight sun. At h = −18° it means **no astronomical darkness**, as in London in
    June (T15).
  - **alwaysBelow:** the Sun stays below h for the whole window. At h = −0.833° this is
    polar night, and astronomical dusk and dawn can still exist (T14).
- **No fake values.** "Not reached" is never shown as a time, as zero, or as a default
  (SI-008).
- **Visibility windows when the darkness limit is `neverBelow`:** the list is empty,
  with the reason "no darkness at the chosen limit".

### 9. Relationships

- **Site.** A SessionNight exists only for a site.
  - When the site changes, the same D is re-resolved at the new site. The date is the
    user's intent; the instants are not.
  - When no site is set, there is no SessionNight. TASK 2.4 shows a "no site set" state
    instead of the silent London default.
- **Target visibility and the timeline (TASK 2.3, G10).**
  - The night timeline, visibility windows and altitude curve are all computed in the
    domain over `[startUtc, endUtc)`.
  - They share one sampling grid anchored at `startUtc`; the 5-minute step is kept
    (TASK 2.3).
  - A visibility window can touch a window boundary only when the Sun is below the
    limit at mean solar noon, that is in polar night. Such a window is clipped and
    flagged.
  - Night-level scalars, such as Moon illumination, are evaluated at a defined instant
    of the night. G6 chooses that instant; a candidate is mean solar midnight,
    `startUtc + 12 h`.
- **Weather (G9).**
  - Weather samples are keyed by UTC instants. Provider-local times are converted with
    the provider's offset, or UTC is requested.
  - A night's weather is the set of samples with `startUtc ≤ t < endUtc`, usually
    summarized over the darkness interval.
  - A night beyond the provider's horizon has **no forecast** (unknown), never zero.
  - Weather never defines or shifts the night.
  - The zone the provider reports is one candidate source for the site zone in 7.1
    (not decided here).
- **Capture budget and imaging opportunity (G5, G10).** These consume the darkness
  intervals of the SessionNight. Their rules are not decided here (PD-08, PD-17).

### 10. What is persisted and what is calculated

- **Persisted.** The schema itself is decided in G11 (PD-18).
  - `eveningDate` as `YYYY-MM-DD` text: never an instant or epoch.
  - The site: a reference plus a coordinate snapshot.
  - The `id` of the time context used to resolve the night.
  - Real event instants (created, started, ended, frame times), in UTC.
- **Calculated, never the stored source of truth.** `startUtc`/`endUtc` (pure
  arithmetic), the night timeline, darkness intervals, visibility windows and altitude
  curves. Result snapshots for logs are PD-18.
- **Legacy rows** (`session_date` as an instant). The mapping is decided in TASK 2.4 or
  G11. Proposal: take the device-local calendar date of the stored instant, which is
  what the old app displayed after a reload, and flag the row as legacy-mapped.

### 11. Invariants (TASK 2.2 must enforce and test all of them)

| # | Invariant |
| --- | --- |
| I1 | `endUtc − startUtc` = 86 400 000 ms exactly, on every date including DST transitions |
| I2 | `startUtc + s(λ)` has time of day exactly 12:00:00.000: every start is a mean solar noon of the site |
| I3 | Tiling: `forEveningDate(D + 1).startUtc == forEveningDate(D).endUtc`, with no gaps or overlaps |
| I4 | Bijection: `labelOf(forEveningDate(D)) == D`, and `forEveningDate(labelOf(w)) == w` |
| I5 | `resolveDefault(now)` contains `now`, with a half-open interval: `now == endUtc` belongs to the next night |
| I6 | Monotonic: `now₁ ≤ now₂` implies `default(now₁).startUtc ≤ default(now₂).startUtc`; the label changes exactly once per 24 h, at mean solar noon |
| I7 | 18:00 civil on D lies in the window of D whenever the context's offset is within 6 h of mean solar time, modulo 24 h (true for every current zone in the sweep) |
| I8 | The output depends only on (`now` or D, φ, λ, context), never on the host or device zone; tests pass under several host `TZ` values |
| I9 | A window exists for every φ ∈ [−90°, 90°] and every D; the resolver never returns null |
| I10 | λ is normalized to (−180°, 180°]; λ = 180° and λ = −180° give identical results |
| I11 | `startUtc` and `endUtc` are UTC (`isUtc`); `eveningDate` carries no time or zone |
| I12 | The window does not depend on any Sun or Moon model |

### 12. Test matrix (becomes the TASK 2.2 table)

**Test conditions:**
- **Expected values.** Window instants are exact arithmetic from §3. Offsets come from
  IANA tz data (2026 rules: EU DST 29 Mar–25 Oct, US DST 8 Mar–1 Nov).
- **Contexts in 2.2.** 2.2 has no `timezone` package, so it uses fixed-offset contexts
  or a DST-transition fake with those instants.
- **Darkness columns.** These are **indicative only**, for TASK 2.3. They come from an
  independent NOAA-algorithm scratch computation at 1-minute steps, with geometric
  altitude, and are expected to be within ±2 min. **2.3 must re-verify them against
  USNO or NOAA** and must not take them from the code under test.
- **"Old code" column.** The date the current implementation uses.

| # | Case | Site (φ, λ) · context | Input | Expected D | startUtc → endUtc | Site-local display | Indicative sunset · astro dusk / dawn | Old code |
| --- | --- | --- | --- | --- | --- | --- | --- | --- |
| T1 | San Francisco evening | 37.7749, −122.4194 · LA (PDT) | now 2026-09-21 18:30 PDT | 2026-09-21 | 2026-09-21T20:09:40.656Z → 09-22T20:09:40.656Z | 13:09 PDT → 13:09 PDT | 19:08 · 20:36 / 05:30 PDT | 09-22 ✗ |
| T2 | SF after midnight | same | now 2026-09-22 02:00 PDT | 2026-09-21 | = T1 | = T1 | = T1 | 09-22 ✗ |
| T3 | SF morning (L4) | same | now 2026-09-22 09:00 PDT | 2026-09-21 | = T1 | = T1 | = T1 | 09-22 (differs by rule) |
| T4 | SF after solar noon | same | now 2026-09-22 14:00 PDT | 2026-09-22 | 2026-09-22T20:09:40.656Z → 09-23T20:09:40.656Z | 13:09 PDT → 13:09 PDT | 19:06 · 20:34 / 05:30 PDT | 09-22 ✓ |
| T5 | Tokyo after midnight | 35.6762, 139.6503 · +9 | now 2026-09-22 02:00 JST | 2026-09-21 | 2026-09-21T02:41:23.928Z → 09-22T02:41:23.928Z | 11:41 JST → 11:41 JST | 17:41 · 19:06 / 04:04 JST | 09-21 ✓ |
| T6 | Tokyo morning | same | now 2026-09-22 10:00 JST | 2026-09-21 | = T5 | = T5 | = T5 | 09-22 (differs by rule) |
| T7 | Kiritimati (UTC+14) | 1.8721, −157.4278 · fixed +14 | now 2026-09-22 20:00 +14 | 2026-09-22 | 2026-09-21T22:29:42.672Z → 09-22T22:29:42.672Z | 12:29 → 12:29 (+14) | 18:26 · 19:34 / 05:10 | 09-22 ✓; mean-solar fallback labels 09-21 (L1) |
| T8 | Apia (UTC+13) | −13.8333, −171.7667 · fixed +13 | now 2026-09-22 21:00 +13 | 2026-09-22 | 2026-09-21T23:27:04.008Z → 09-22T23:27:04.008Z | 12:27 → 12:27 (+13) | 18:23 · 19:34 / 05:06 | fallback labels 09-21 (L1) |
| T9 | EU DST fall-back night | 52.52, 13.405 · Berlin (fake) | D = 2026-10-24 (and now 21:00 CEST) | 2026-10-24 | 2026-10-24T11:06:22.800Z → 10-25T11:06:22.800Z | 13:06 CEST → 12:06 CET | 17:53 CEST · 19:47 CEST / 04:55 CET | 10-24 ✓ |
| T10 | EU DST spring-forward night | same | D = 2026-03-28 | 2026-03-28 | 2026-03-28T11:06:22.800Z → 03-29T11:06:22.800Z | 12:06 CET → 13:06 CEST | 18:34 CET · 20:34 CET / 04:48 CEST | 03-28 ✓ |
| T11 | US DST fall-back night | 40.7128, −74.0060 · New York (fake) | now 2026-10-31 21:00 EDT | 2026-10-31 | 2026-10-31T16:56:01.440Z → 11-01T16:56:01.440Z | 12:56 EDT → 11:56 EST | 17:54 EDT · 19:26 EDT / 04:54 EST | 11-01 ✗ |
| T12 | US DST spring-forward night | same | now 2026-03-07 21:00 EST | 2026-03-07 | 2026-03-07T16:56:01.440Z → 03-08T16:56:01.440Z | 11:56 EST → 12:56 EDT | 17:55 EST · 19:26 EST / 05:49 EDT | 03-08 ✗ |
| T13 | Tromsø, midnight sun | 69.6492, 18.9553 · Oslo (CEST) | D = 2026-06-20 | 2026-06-20 | 2026-06-20T10:44:10.728Z → 06-21T10:44:10.728Z | 12:44 → 12:44 CEST | sunset **neverBelow** · astro **neverBelow**; no visibility windows | n/a |
| T14 | Tromsø, polar night | same · Oslo (CET) | D = 2026-12-20 | 2026-12-20 | 2026-12-20T10:44:10.728Z → 12-21T10:44:10.728Z | 11:44 → 11:44 CET | sunset **alwaysBelow** · astro dusk 16:56 / dawn 06:29 CET | n/a |
| T15 | No astronomical darkness | 51.5074, −0.1278 · London (BST) | D = 2026-06-20 | 2026-06-20 | 2026-06-20T12:00:30.672Z → 06-21T12:00:30.672Z | 13:00 → 13:00 BST | 21:21 / sunrise 04:43 BST · astro **neverBelow** | n/a |
| T16 | Antimeridian | λ = 180 and λ = −180 · mean-solar | D = 2026-09-22 | 2026-09-22 | both 2026-09-22T00:00:00.000Z → 09-23T00:00:00.000Z | — | — | — |
| T17 | Host-zone independence | T1 inputs | run with host `TZ` = UTC, Asia/Tokyo, America/Los_Angeles | identical to T1 | identical | — | — | — |

**Property tests (TASK 2.2):**
- **P1.** I1–I4 and I7 for every D over 730 days, in these contexts:
  - fixed +14, +13 and +9;
  - the LA and Berlin DST fakes;
  - mean-solar at λ ∈ {−180, −179.99, −122.42, 0, 13.4, 179.99, 180}.
- **P2.** At the T1 site, step `now` by 5 min across 48 h. The default label changes
  exactly twice, at the mean solar noons, and moves monotonically (I5, I6).
- **P3.** λ = 179.99° and −179.99° with the same fixed +12 context give starts less
  than 1 min apart.

**Acceptance for TASK 2.2:** T1, T2, T11 and T12 fail on the old code. That confirms
the regression is covered.

### 13. Alternatives considered

| Alternative | Verdict | Reason |
| --- | --- | --- |
| UTC calendar date (status quo) | Rejected | Off by 24 h west of UTC in the evening (verified: T1, T11, T12) |
| Device-local date, with a device-local noon-to-noon window (the chart's current base) | Rejected | Wrong for remote sites; depends on the host; DST makes the window 23 or 25 h long |
| Site civil noon-to-noon window (civil boundaries) | Rejected | Needs a zone even for the instants; DST gives 23 or 25 h windows; a boundary up to about 3 h from solar noon can split short polar-edge days |
| Mean-solar date and window (roadmap literal, zone-free) | **Fallback only** | Exact outside date-line anomalies; labels the night one day off at Kiritimati, Samoa and Tonga; conflicts with "the user's calendar date" |
| Apparent (true) solar noon or transit boundaries | Rejected | The identity would depend on the Sun model, and the window length would vary. The gain (up to about 16.5 min at the boundary) matters only on polar-edge days (L2) |
| Sunset-to-sunrise window | Rejected | Undefined in polar day and night; depends on the model; excludes twilight |
| PD-01 (a): Sun-altitude default | Rejected by the owner | Morning planning is better, but it depends on the model, and under midnight sun it always skips to the next window |
| PD-01 (b): always the next evening | Rejected | At 02:00 it skips the night in progress |
| PD-01 (c): explicit date only | Rejected | No default for "tonight" |
| PD-02 (a): device zone in computation | Rejected | Non-deterministic; wrong for remote sites. Kept as the **display** fallback only |
| `timezone` package in TASK 2.2 | Deferred to 7.1 (owner) | No coordinate-to-zone source exists before 7.1, so production would not change |

### 14. Known limitations and assumptions

- **L1 (until TASK 7.1).**
  - Every site uses the mean-solar context. In zones whose civil offset differs from
    mean solar time by 12 h or more (Kiribati Line and Phoenix Islands, Samoa, Tonga,
    Tokelau, Chatham), the night is labelled one day off.
  - The window instants are still correct.
  - Displayed times stay honestly labelled.
- **L2.** Boundaries sit at *mean*, not apparent, solar noon (up to about 16.5 min
  apart). A crossing can land in the neighbouring window, flagged as clipped (§8), on
  the few polar-edge days when the Sun's noon altitude is within a fraction of a degree
  of a threshold.
- **L3.** A historical zone discontinuity can leave a date with no civil noon; Samoa
  skipped 2011-12-30. The resolver returns an explicit error for such a date. The date
  picker's range (−1 to +5 years) makes this practically unreachable.
- **L4.** The default switches at mean solar noon. Between sunrise and noon it shows
  the night that has just ended (owner-accepted).
- **Assumptions:**
  - Civil noon is never inside a DST transition.
  - Every current zone is within 6 h of mean solar time modulo 24 h (sweep above).
  - Sun altitude thresholds stay the existing constants (−0.833°, −6°, −12°, −18°).
    Making the darkness limit configurable is TASK 2.3 or TD-043, not this ADR.

### 15. Consequences

- **TASK 2.2** implements §2–§6 and §11–§12 in pure Dart:
  - a `Clock`;
  - a `SiteTimeContext` with its mean-solar and fixed-offset implementations;
  - `SessionNight {eveningDate, startUtc, endUtc, latitude, longitude, timeContextId}`;
  - `forEveningDate(D, site, ctx)`, `resolveDefault(now, site, ctx)` and `labelOf`.

  The shape now includes the time context, which refines the roadmap's listed fields.
- **TASK 2.3** implements §8 and §9 (typed timeline, shared sampling grid, domain
  altitude curve).
- **TASK 2.4** implements the display rules in §6 and the ViewModel adoption.
- **TASK 7.1** adds the site IANA zone, its source, and the `timezone` dependency.
- **G9** aligns weather per §9. **G11** persists per §10.
- SI-010, TD-001, TD-020, TD-023 and TD-024 stay **open** until those tasks land. This
  ADR changes no code.

## ADR-008: Persistence baseline, migration workflow and provenance

Status: accepted (owner, 2026-09-22, TASK 3.1). Resolves PD-04 and PD-09. It also
answers the Phase 0 pending decision "How to store provenance for seeded target and
equipment data" (Part A, unchanged). **Implementation:** partial.
- **Done (TASK 3.2, 2026-09-22, commit `3c25e8c`):** §2 (the v8 floor and the
  downgrade guard, both implemented as `onUpgrade` checks that throw
  `UnsupportedSchemaVersionException` before any statement runs; the v1–v7
  steps are deleted) and §3 (schema snapshots in `drift_schemas/` for v8 and
  v9, `build.yaml` configuring `drift_dev`, generated verification code, and
  the migration test suite — M1, M2, M5–M7, M11 of §7). The v8→v9 step now
  runs inside a transaction, verified atomic by an injected-failure test
  (§3's "each upgrade runs as one unit", previously unverified).
  `resetUnsupportedDatabaseFile` implements the reset half of §2 as a pure
  file operation; **no caller exists yet** — the confirmation UI §2 requires
  is not built.
- **Done (TASK 3.3, 2026-09-22, commit `e580d03`):** §4 (a one-time
  `PRAGMA foreign_key_check` orphan cleanup — deleting and logging the count
  per table — followed by `Migrator.alterTable` rebuilds of
  `camera_modules`/`optical_rigs`/`capture_blocks` to add the real
  `RESTRICT`/`RESTRICT`/`CASCADE` `ON DELETE` actions §4 specifies, and a
  re-check before continuing; `beforeOpen` sets `PRAGMA foreign_keys = ON` on
  every connection; `DriftEquipmentRepository.deleteEquipment` now guards
  against deleting a still-referenced camera module or device) and §5
  (`equipment_profiles` is dropped, and the two legacy columns —
  `optical_multiplier` on `camera_modules`/`optical_rigs`,
  `bit_depth` on `camera_modules` — are gone from the rebuilt tables;
  `app_database_test.dart`'s equipment_profiles test is replaced, per §5's
  own instruction, and the reason is recorded there). The migration test
  suite now covers the full §7 matrix except the bootstrap-UI pieces of M6
  (M1–M4, M5–M9, M11).
- **Not implemented yet:** §6 (provenance columns — TASKs 7.1, 8.1, 8.5) and
  the bootstrap-level confirmation UI for the reset path (§2) and for a
  refused downgrade (TD-047's remaining half).

### 1. Context (verified for this ADR at commit `33a212b`)

- **Schema versions created by committed builds** (`git log` on
  `app_database.dart`):

  | Version | Commit |
  | --- | --- |
  | v1 | `bb327e2` |
  | v2 | `8070dd5` |
  | v3 | `5bc8ba6` |
  | v8 | `d0b737f` |
  | v9 | `900b82a` |

  **v4–v7 were never committed.** They arrived together in `d0b737f`, and could only
  exist on a developer device from uncommitted builds. Every committed build from
  `d0b737f` onwards creates v8 or later. `main` was pushed to `origin`
  (GitHub) at `a1bcbd9`, which contains all of these commits.
- **The upgrade chain** (`app_database.dart`, `onUpgrade`) is a sequence of
  `if (from < n)` steps. They are written against the **current** table
  definitions, not the definitions of their own version (the root cause of DEV-D1):
  - Every path from v1, v2 or v3 is **certain to fail**. `createTable(opticalRigs)`
    uses today's definition, which has no `optical_multiplier`, and then the v5
    `INSERT … SELECT` names that column. v3 → v9 was reproduced on 2026-09-21. v1
    and v2 go through the same step.
  - v8 → v9 works (reproduced 2026-09-21). It leaves **legacy columns** that fresh
    v9 installs lack: `optical_multiplier` (NOT NULL DEFAULT 1.0) on `optical_rigs`
    and `equipment_profiles`, and `bit_depth` (nullable) on `camera_modules`.
- **Downgrades are unguarded** (new finding, recorded as TD-047).
  - Drift calls `onUpgrade` whenever the stored version differs from
    `schemaVersion`, including when it is *higher*
    (`drift-2.35.0/lib/src/runtime/api/db_base.dart:131`,
    `hadUpgrade => versionBefore != versionNow`).
  - With the current `if (from < n)` chain, an older build would run no step and
    then open a newer database as if it matched.
- **Foreign keys are not enforced.**
  - No `beforeOpen` sets `PRAGMA foreign_keys`. An orphan `capture_blocks` insert
    succeeded (verified 2026-09-21).
  - Declared references: `capture_blocks.session_log_id → session_logs`,
    `camera_modules.device_id → devices`, and
    `optical_rigs.camera_module_id → camera_modules`. None has an `ON DELETE` clause.
  - Deletes are hand-written in the repositories. `deleteEquipment` deletes a rig's
    camera module and device without checking for other references.
- **Orphan table.** `equipment_profiles` is not read or written by any application
  code since v4. Only the v5 copy step, the v9 `addColumn` and `app_database_test`
  touch it.
- **No provenance is stored** (DEV-D5).
  - The seeders insert only into an empty table and do not mark their rows.
  - A seeded row therefore cannot be told apart from a user-entered or user-edited
    one after the fact.

### 2. Decision: upgrade floor v8

- **Supported:** databases at **v8 and v9** upgrade in place. Every later version
  must upgrade from v8.
- **Below v8** (`from < 8`): the database is **not migrated**.
  - The app shows a clear message: the database comes from a pre-release build and
    cannot be upgraded.
  - **On the user's explicit confirmation**, it renames the file to
    `astroplan.sqlite.v<from>.bak` (never deletes it) and creates a fresh database.
  - Without confirmation, nothing is touched.
- **Newer than the app** (`from > schemaVersion`): refused, with the same kind of
  message, and the file is left untouched (TD-047). Newer databases are never reset.
- **The legacy v1–v7 steps are removed** from `onUpgrade`.
- **Owner confirmation (2026-09-22):** no installs below v8 need to be preserved.
- **Refines PD-04 option (b):** that option said "declare v9 the floor (no installs
  below v8 exist)". The floor is **v8**, so both v8 and v9 databases are supported.

### 3. Decision: migration workflow (from TASK 3.2 onwards)

- **Tooling.** Use Drift's schema tooling (`drift_dev` 2.35, already a dev
  dependency).
  - A `build.yaml` database entry.
  - Versioned JSON snapshots in `drift_schemas/`: **v8 exported from `d0b737f`**,
    and **v9 from the current code**.
  - Generated `stepByStep` versioned schema classes, and generated
    schema-verification tests.
- **Every schema bump**, as one change:
  - a new snapshot;
  - a `from → to` step written **against the generated schema class of its own
    version**, never against the live table definitions (that is what broke
    DEV-D1);
  - a migration test with sample rows that checks the data survives;
  - a verification test that the upgraded schema equals the fresh schema.
- **Each upgrade runs as one unit.** If it fails, the file is left unchanged. 3.2
  must verify this, because Drift's transaction behaviour for `onUpgrade` is not
  assumed here.
- **Destructive steps** (drop table, drop column, table rebuild, row deletion) need
  explicit owner approval every time. Part A Migration Rules stay in force. This ADR
  approves exactly the destructive steps in §2, §4 and §5.
- **Documentation.** The workflow itself is documented in `DATA_MODEL.md` by TASK
  3.2.

### 4. Decision: foreign keys (TASK 3.3)

- **One-time cleanup in the v10 upgrade step,** with foreign keys **off**:
  1. Run `PRAGMA foreign_key_check`.
  2. **Delete orphan rows**, whose referenced parent does not exist. Log the count
     removed per table (owner decision).
  3. Re-run the check. The step fails if anything remains.
- **Every connection:** `beforeOpen` sets `PRAGMA foreign_keys = ON`.
- **Delete behaviour.** SQLite cannot alter a constraint, so these tables are rebuilt
  in v10:

  | Reference | On delete |
  | --- | --- |
  | `capture_blocks → session_logs` | `CASCADE` |
  | `camera_modules → devices` | `RESTRICT` |
  | `optical_rigs → camera_modules` | `RESTRICT` |

- **Guarded deletes.** Repository deletes of shared equipment rows are guarded: a
  camera module or device is deleted only when no other row references it.
- **Tests** run with foreign keys on, the same as production.

### 5. Decision: v10 cleanup scope (TASK 3.3)

- **Drop `equipment_profiles`.**
- **Rebuild `optical_rigs` and `camera_modules`** without the legacy columns
  `optical_multiplier` and `bit_depth`. Every install then has one schema, and
  snapshot validation is exact.
  - **Accepted data loss (owner):** a non-default multiplier on a developer
    database. The code has ignored the column since `900b82a` (CALC-14 is the
    identity).
- **One step.** The §4 rebuilds and this cleanup are the same v10 step, with one new
  snapshot.
- **Test code.** `app_database_test.dart`'s `equipment_profiles` test is replaced,
  because the table no longer exists. The reason is recorded; this is not a
  weakened test.

### 6. Decision: provenance (per row, PD-09)

**Applied per field to equipment by ADR-018 §5 (2026-09-26, S3.D):** schema v18 adds per-field pairs for the specs an import can mix. **Implemented 2026-09-26 (S3.4).**

- **Columns on tables that hold external or scientific data:**
  - `source`: nullable TEXT, a stable namespaced id. Examples: `user`,
    `seed:equipment@1`, `seed:catalog@1`, `catalog:openngc@<version>`,
    `provider:open-meteo/<model>`, `device:gps`, `geocoder:nominatim`, `exif`,
    `fits`.
  - `confidence`: nullable TEXT, one of:
    - `verified`: checked against a cited primary source;
    - `reported`: taken from a source that was not independently checked
      (manufacturer summary, provider, user entry);
    - `estimated`: derived or approximated, such as an empirical RAW size.
- **Per-field pairs.** A row whose fields have different origins gets per-field
  pairs, for example a site's `bortle_source` and `bortle_date` next to user-entered
  coordinates (TASK 7.1).
- **NULL means unknown.** Legacy rows keep NULL, displayed as "unknown". They are
  **never back-filled by guessing**: seeded rows cannot be identified reliably, and
  users may have edited them (PD-10 applies the same rule).
- **Never the reverse.** A default is never recorded as a measurement, and a NULL
  is never shown as a value (SI-008).
- **No `data_sources` table now.** Citation, licence and attribution text live with
  the asset and the About screen (TASK 8.2). A later `data_sources` table can be
  keyed by the same `source` ids without changing what existing rows mean.
- **Timing.** The columns are **not added in G3**. Each arrives in the additive
  migration of the task that owns its table:
  - 7.1: sites (Bortle/SQM source and date);
  - 8.1: targets (`source`);
  - 8.5: equipment specs (`source`, `confidence`). **Done 2026-09-23** (schema v15).

  Weather and session snapshots follow the same convention when they are persisted
  (G9, G11).

### 7. Test matrix (for TASKs 3.2 and 3.3)

| # | Case | Task | Expected |
| --- | --- | --- | --- |
| M1 | Fresh install | 3.2 | Schema equals the v9 snapshot (3.3: v10) |
| M2 | v8 (`d0b737f` snapshot) with sample rows → v9. Rows: device → module → rig chain, target, location, session with 2 blocks; `equipment_profiles` both empty and non-empty | 3.2 | All rows intact; new columns NULL; schema equals v9 apart from the documented legacy columns (until v10) |
| M3 | v9 → v10 | 3.3 | Orphan table and legacy columns gone; rows intact; `capture_blocks` cascades; schema equals the v10 snapshot exactly |
| M4 | v8 → v10, step by step | 3.3 | Same as M3 |
| M5 | Below floor: v1, v2 and v3 databases | 3.2 | Specific "unsupported version" error; no step runs; file byte-identical afterwards |
| M6 | Reset path after M5, confirmed | 3.2 | Old file renamed to `astroplan.sqlite.v<from>.bak` with content intact; fresh database at the current version |
| M7 | Downgrade: database stamped at schemaVersion + 1 | 3.2 | Refused; file and `user_version` unchanged (TD-047) |
| M8 | Orphans before v10: orphan block, rig with a missing module | 3.3 | Orphans deleted and counts logged; legitimate rows intact; `foreign_key_check` empty |
| M9 | FKs on after open | 3.3 | `PRAGMA foreign_keys` = 1; an orphan insert throws; deleting a session removes its blocks; deleting a device referenced by a module is refused |
| M10 | Existing repository and database tests | 3.3 | Green with FKs on |
| M11 | Failed upgrade (injected failure mid-step) | 3.2 | File unchanged (§3, one unit) |

### 8. Alternatives considered

| Alternative | Verdict | Reason |
| --- | --- | --- |
| Repair every path from v1 | Rejected (owner) | The v4–v7 schemas were never committed and can only be guessed; each path needs a historical schema and a test; no install needs it |
| Recreate the database on any failure (PD-04 c) | Rejected | Silent data loss on v8/v9 installs |
| Floor v9 (PD-04 b, literal) | Refined to v8 | v8 → v9 is proven to work; a floor of v9 would needlessly reset v8 installs |
| Keep legacy columns and whitelist them | Rejected (owner) | Two schemas forever; the validation cannot be exact |
| Leave FKs off when orphans exist | Rejected (owner) | Integrity would not be guaranteed on that install |
| `data_sources` table | Deferred | Joins and FKs for about 5 sources; can be added later, keyed by the same ids |

### 9. Consequences

- **TASK 3.2:**
  - the snapshots (v8 from `d0b737f`, v9);
  - generated verification;
  - floor and downgrade handling, plus the reset path and its UI message;
  - removal of the v1–v7 steps;
  - M1, M2, M5–M7 and M11;
  - the workflow in `DATA_MODEL.md`.
- **TASK 3.3:** the v10 step (§4, §5), `beforeOpen` with foreign keys on, guarded
  deletes, and M3, M4 and M8–M10.
- **Later tasks** add provenance columns according to §6.
- DEV-D1, DEV-D5, DEV-D6, TD-004, TD-005, TD-026 (partly) and TD-047 stay **open**
  until then. This ADR changes no code.

## ADR-009: Capture-budget semantics

> **Amended by ADR-020 (owner, 2026-09-29, S7.D):** in-camera long-exposure noise reduction (N1): when a DSLR/mirrorless or Unknown rig's switch is on, each light frame adds a dark of its own exposure to **in-window calibration** (§2) and to its atomic fit event (§4, §6); new vectors E8–E8c in ADR-020 §8. The per-frame overhead is relabelled "Time between frames" (§4; no arithmetic change). Built by S7.3b and S7.2b.

> **Amended by ADR-019 (owner, 2026-09-27, S4.D), display only:** §2's "each shown on its own line" is met **within the budget details**, one tap away (ADR-019 §7). The budget's definitions and calculations are unchanged.

Status: accepted (owner, 2026-09-22, TASK 5.1). Resolves PD-08. **Implemented:**
TASK 5.2, preferences (the margin, the per-frame overhead and the optional
overheads are stored `PlanningPreferences`, with the ADR's defaults); TASK 5.3,
block policy and order (`CalibrationPolicy` on `CaptureBlock`, default
`outsideWindow`; existing calibration rows migrated to `outsideWindow` in v11);
TASK 5.4, the budget calculator (`CaptureBudgetCalculator`, §2–§4 and §7,
E1–E7 reproduced exactly). **Dead-code note (TASK 5.4, as §11 required):**
`SessionCalculator.estimateTotalDuration` (the unsourced 15 % model, CALC-19)
was deleted together with its test; nothing called it, and ADR-009 replaces it.
TASK 5.5, the fit (`FitAnalyzer`, §5–§6; the superseded sum-of-windows
`SessionCalculator.calculateFeasibility`, CALC-18, was deleted with its tests).
TASK 5.6, the UI (every §2 line, the fit with its reason and end time, per-group
√N, storage or "Unknown", the assumptions panel, and a one-tap fill/trim action
built on a domain `FitAnalyzer.maxFramesForBlock`). **ADR-009 is fully
implemented** (G5 complete, 2026-09-22).

### 1. Context (verified for this ADR at commit `f8e1a98`)

- **The live "required time"** is `PlannerViewModel.estimatedRequiredTime`
  (`planner_viewmodel.dart:699`). It computes **Σ(exposure × count) over every
  block type**, including darks, flats and bias, plus **5 s × every frame** (CALC-20,
  TD-022, DEV-A4).
- **The fit** is `SessionCalculator.calculateFeasibility` (CALC-18). It compares that
  sum with the **sum** of the visibility windows:
  - `infeasible` if it is greater than the windows;
  - `tight` if it is greater than a **fixed** 85 % of them;
  - otherwise `feasible`.

  It ignores gaps between windows, so a frame is treated as if it could straddle one.
- **`SessionCalculator.estimateTotalDuration`** (CALC-19, the 15 % model) is dead
  code.
- **The block model.** A `CaptureBlock` has `frameType` (light, dark, flat, bias),
  `filterName`, `exposureTimeSeconds` (double), `frameCount`, `binning` and a
  free-text `gainIso`. It has no policy and no position.
- **The windows.** `visibilityWindows` is already a `List<VisibilityWindow>` of UTC
  intervals for the `SessionNight`, darkness ∩ altitude (CALC-23, ADR-007 §9).

### 2. Definitions

All arithmetic is in **integer milliseconds**:

- A frame lasts `round(exposure_s × 1000)` ms.
- A block total is `count × per-frame ms`, so no rounding drift accumulates.

| Quantity | Definition |
| --- | --- |
| **Integration** | Σ light exposure only: `Σ_light count × exposure`. The science quantity. |
| **Acquisition** | Integration + per-frame overhead on every light frame + the in-window overhead events (§4) |
| **In-window calibration** | Σ `count × (exposure + per-frame overhead)` over calibration blocks with policy `inWindow` |
| **Window load** | Acquisition + in-window calibration. **The only quantity fitted into the windows** (§6) |
| **Outside-window calibration** | Σ `count × (exposure + per-frame overhead)` over calibration blocks with policy `outsideWindow` (dusk or dawn flats, darks and bias after dawn). Reported, never fitted |
| **Setup** | A single duration (§4). Reported as "start setup by *first window start − setup*". Never fitted |
| **Session budget** | Window load + outside-window calibration + setup, **each shown on its own line** (owner decision). Refines the roadmap's wording "acquisition + in-window calibration + setup" |
| **Library calibration** | Blocks with policy `library` consume no time. They are listed as "from library" |

- **Lights are always in-window.** A light block has no policy.

### 3. Calibration policy per block (TASK 5.3 adds the field)

- **`inWindow`:** counts in the window load. Example: darks from an uncooled camera
  or a smartphone at ambient temperature.
- **`outsideWindow`:** counts in the session budget only. **This is the default for
  every new dark, flat and bias block** (owner decision).
- **`library`:** counts nowhere.
- **Existing blocks** have no stored policy. They read as `outsideWindow` until TASK
  5.3's migration writes one.

  Today, every existing block counts against the window. This is an intentional,
  recorded behaviour change: E7 goes from "infeasible" to "fits".

### 4. Overheads (defaults are assumptions, configurable in TASK 5.2)

| Overhead | Applies to | Default | Cost |
| --- | --- | --- | --- |
| Per-frame (download or interval gap) | Every acquired frame: lights and non-library calibration | **5 s** (the live value, kept so plans don't shift silently; owner decision) | Per frame |
| Dither + settle | After every N-th **light** frame, only if another light frame follows | **Off** | D per event |
| Refocus | At the first frame boundary where accumulated time *excluding refocus events* reaches k·T (k = 1, 2, …), only if another light frame follows | **Off** | R per event |
| Filter change | Between consecutive light blocks whose `filterName` differs | **Off** | F per change |
| Meridian flip | Once, if enabled and the target's upper transit falls inside an available window | **Off** | M, once |
| Setup | Once, before the first window | **Off** | S |

- **Why the optional overheads default to off** (owner decision): the app cannot know
  whether a rig guides, has an autofocuser or uses an equatorial mount. Default
  overheads would charge untracked and smartphone users for time they never spend.
- **An overhead that is off is never a hidden zero.** The assumptions panel lists it
  as **"not included"** (SI-008). Enabled values carry the label "assumption —
  measure your rig".
- **Meridian flip.**
  - The budget (TASK 5.4) counts it conservatively whenever the transit lies inside
    any window.
  - The fit (TASK 5.5) inserts it at the first event boundary at or after the
    transit.
  - If the placed plan ends before the transit, the fit drops it and says so.
- **One sequence.** Overhead events are part of **one ordered in-window event
  sequence**: the frames in block order, with the events inserted as above. The
  budget is the sum of that sequence, and the fit places the same sequence, so the
  two cannot disagree.

### 5. Available-time contract

The fit consumes `List<VisibilityWindow>` for one `SessionNight`:

- UTC instants;
- sorted and non-overlapping;
- each window inside `[startUtc, endUtc)`;
- the list may be empty.

Today the list is darkness ∩ altitude (CALC-23). **G10's Imaging Opportunity will
produce the same type, with no API change.** The budget (TASK 5.4) does not read
windows except for the meridian-flip condition.

### 6. Fit semantics (TASK 5.5)

- **Atomic events.** Every event (a frame plus its per-frame overhead, or an overhead
  event) is atomic. Events are placed in sequence order into the windows.
- **No straddling.** An event that does not fit in what remains of the current window
  moves to the start of the next one. The leftover tail is **lost** and reported.
  Nothing straddles a gap.
- **Result:**
  - **no window:** the list is empty. The reason comes from the night timeline, for
    example "no astronomical darkness" (ADR-007 §8).
  - **doesn't fit:** some events can't be placed. Reports the number of unplaced
    frames per block and the lost tails.
  - **tight:** everything is placed, but `window load > (1 − m) × Σ windows`.
  - **fits:** otherwise.
- **The margin `m`** defaults to **15 %**, the same as today's fixed 85 % threshold.
  It is **configurable** in TASK 5.2. The margin only labels the result; it never
  blocks placement.
- **Every result reports:** the projected end instant, the unused time, the lost
  tails, and a human-readable reason.
- **Inverse question:** the maximum number of frames of a given light block that can
  be **placed** (not "fit within the margin").
- **A plan with no light frames** has nothing to fit. The result states this and is
  not reported as "fits".

### 7. Storage and relative stacking gain (TASKs 5.4 and 5.6; not new formulas)

- **Storage:** per block, `count × averageRawFileSizeMB` over every acquired frame
  (library blocks excluded).
  - If the file size is unknown, storage is **unknown**, never 0 (SI-013, CALC-16).
  - Binning is ignored and labelled as an estimate.
- **Relative stacking gain:** `√N` is shown **per group of light frames with the same
  exposure and filter**. It is never summed across groups, and never called SNR
  (SI-003, CALC-15).

### 8. Worked examples = test vectors (TASK 5.4 budget, TASK 5.5 fit)

**How the vectors were produced:** computed 2026-09-22 with an independent scratch
model of §2–§6, in integer milliseconds, outside the repository. Every parameter is
stated in each row, so no example depends on a default except where noted.

**Windows used below:**

| Label | Window(s) |
| --- | --- |
| W1 | 21:00–03:00 |
| W2 | 22:00–23:30 and 01:00–04:00 |
| W3 | 22:10–02:40 |
| W4 | 21:30–04:30 |
| W5 | 22:00–00:00 |
| W7 | 21:00–00:30 |

- All times are UTC clock times on one night, and the margin is 15 %.
- A tail value is the unused remainder of a window, in seconds.

| # | Case | Plan and parameters | Windows | Integration | Acquisition | In-window cal | Window load | Outside cal | Setup | Session budget | Events | Fit result | End | Lost tails |
| --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |
| E1 | Guided cooled rig | Ha 90 × 120 s; per-frame 2 s; dither every 3 lights, 20 s; refocus every 3600 s, 120 s | W1 (21 600 s) | 10 800 s | 11 920 s | 0 | 11 920 s | 0 | 0 | 11 920 s | 29 dithers, 3 refocus | **fits** (≤ 18 360 s) | 00:18:40 | — |
| E1b | E1 + meridian flip | as E1, plus flip 300 s; transit 00:40 inside W1 | W1 | 10 800 s | 12 220 s | 0 | 12 220 s | 0 | 0 | 12 220 s | + 1 flip | **fits** | 00:23:40 | — |
| E2a | Split window | 40 × 300 s; per-frame 5 s | W2 (5 400 + 10 800 = 16 200 s) | 12 000 s | 12 200 s | 0 | 12 200 s | 0 | 0 | 12 200 s | — | **fits** (≤ 13 770 s) | 02:56:55 | 215 |
| E2b | Split window, inverse maximum | 52 × 300 s; per-frame 5 s | W2 | 15 600 s | 15 860 s | 0 | 15 860 s | 0 | 0 | 15 860 s | — | **tight**; 52 is the inverse answer (17 frames + 35 frames) | 03:57:55 | 215 |
| E2c | Split window, one frame too many | 53 × 300 s; per-frame 5 s | W2 | 15 900 s | 16 165 s | 0 | 16 165 s | 0 | 0 | 16 165 s | — | **doesn't fit**: 1 light frame unplaced, although 16 165 s ≤ 16 200 s (the sum-of-windows rule would say "tight") | — | 215, 125 |
| E3 | Untracked smartphone | 300 × 10 s lights; 30 × 10 s darks `inWindow`; per-frame 1 s; no other overheads | W3 (16 200 s) | 3 000 s | 3 300 s | 330 s | 3 630 s | 0 | 0 | 3 630 s | — | **fits** | 23:10:30 | — |
| E4 | Calibration outside the window, library, setup | L 60 × 180 s, then R 20 × 180 s; filter change 30 s; flats 30 × 2 s `outsideWindow`; darks 20 × 180 s `library`; bias 50 × 0.001 s `outsideWindow`; per-frame 3 s; setup 2 700 s | W4 (25 200 s) | 14 400 s | 14 670 s | 0 | 14 670 s | 300.05 s (flats 150 + bias 150.05) | 2 700 s | 17 670.05 s | 1 filter change | **fits**; "start setup by 20:45" | 01:34:30 | — |
| E5 | No window | 30 × 120 s; per-frame 2 s | none (e.g. no astronomical darkness) | 3 600 s | 3 660 s | 0 | 3 660 s | 0 | 0 | 3 660 s | — | **no window**, reason taken from the timeline | — | — |
| E6 | Margin boundary | n × 60 s; per-frame 0 s | W5 (7 200 s; limit 6 120 s) | n × 60 | same | 0 | same | 0 | 0 | same | — | see below | see below | see below |
| E7 | Old rule vs new rule | 24 × 300 s lights; 20 × 300 s darks at the **default** policy (`outsideWindow`); per-frame 5 s | W7 (12 600 s) | 7 200 s | 7 320 s | 0 | 7 320 s | 6 100 s | 0 | 13 420 s | — | **fits**; the current code rates it **infeasible** (13 420 s > 12 600 s) | 23:02:00 | — |

E6 results by frame count:

| Frames | Result | End | Lost tail |
| --- | --- | --- | --- |
| 102 | fits (exactly at the limit) | 23:42:00 | — |
| 103 | tight | 23:43:00 | — |
| 120 | tight (fills the window exactly) | 00:00:00 | — |
| 121 | doesn't fit, 1 frame unplaced | — | 0 |

**Erratum (TASK 5.5, 2026-09-22):** the E1b fit row above contradicted this ADR's own
normative rule (§4, §6: the flip is inserted at the first event boundary at or after
the transit, and dropped when the placed plan ends before the transit). With the
transit at 00:40 and the plan, without the flip, ending at 00:18:40, the flip is
**dropped**: the correct fit result is **fits, end 00:18:40, flip dropped**. The
TASK 5.1 scratch model had simply appended the flip at the end. The E1b *budget*
(acquisition 12 220 s, counted conservatively) is unchanged and correct. A variant
with the transit at 22:00 (mid-plan) applies the flip and ends at **00:23:40**. The
semantics (§4, §6) are unchanged; only the vector is corrected. Both cases are tests.

Tests in TASK 5.4 and TASK 5.5 must reproduce these to the millisecond. They must
not derive expected values from the implementation (SCIENTIFIC_INTEGRITY Part C
rule 3).

### 9. Alternatives considered

| Alternative | Verdict | Reason |
| --- | --- | --- |
| Keep "Σ every block + 5 s per frame" against Σ windows (today) | Rejected | Calibration competes for dark time it doesn't need; no gap handling (E2c); integration and acquisition are conflated (TD-022) |
| The 15 % model (`estimateTotalDuration`) | Rejected; deleted in TASK 5.4 | An unsourced flat percentage that doesn't scale with dither or refocus choices; dead code |
| Fit on the sum of windows | Rejected | Frames are atomic and cannot straddle a gap (E2c) |
| Typical guided-rig overheads on by default | Rejected (owner) | Overstates the load for untracked and smartphone users; the app can't know the rig |
| Darks in-window by default | Rejected (owner) | Wrong for cooled cameras; still available per block |
| Per-frame default of 2 s | Rejected (owner) | Would silently shorten existing plans |
| Session budget excluding outside-window calibration (roadmap literal) | Refined (owner) | Dawn flats are real session time; shown as their own line |
| Placement-dependent flip in the budget | Rejected | The budget must not depend on placement; conservative counting is used instead, and the fit refines it |

### 10. Limitations and assumptions

- **L1. Overhead defaults are assumptions.** Only the per-frame 5 s is on by default,
  and it is pessimistic for smartphones, which are closer to 1 s.
- **L2. One target per night.** Scheduling several targets is out of scope (TASK
  5.5).
- **L3. Refocus and dither are time- and count-based only.** Temperature-triggered
  refocus and refocus on filter change are not modelled.
- **L4. The meridian flip is a single fixed cost.** Nothing is modelled for
  counterweight-up imaging or for mounts that never flip.
- **L5. Outside-window calibration is not scheduled** into twilight. It is only
  totalled.
- **L6. Storage ignores binning and compression.**
- **Assumption:** the per-frame overhead also applies to calibration frames.

### 11. Consequences

- **TASK 5.2:** preferences for the margin, the per-frame overhead and the optional
  overheads (all off by default), each shown as a preference, not a law.
- **TASK 5.3:** `calibrationPolicy` on `CaptureBlock` (default `outsideWindow`), with
  its migration and snapshot, and a `position` column.
- **TASK 5.4:** `CaptureBudgetCalculator` implementing §2–§4 and §7, plus E1–E7 as
  tests. `estimateTotalDuration` is deleted, with a note here.
- **TASK 5.5:** the fit analyzer implementing §5–§6, plus E1–E7 as tests.
- **TASK 5.6:** the UI shows every line of §2 and the assumptions panel.
- **Still open until those tasks land:** CALC-18, CALC-19, CALC-20, TD-022 and
  DEV-A4. This ADR changes no code.

## ADR-010: Ephemeris approach and moving objects

Status: accepted (owner, 2026-09-22, TASK 6.1). Resolves PD-07 and PD-16. It also
answers the Phase 0 pending decision "Which astronomical engine/library/reference
to use for future ephemeris work" (Part A, unchanged). **Implemented:** TASK 6.3,
the Moon model per §2 (every §4 tolerance met; CALC-28). **Not implemented yet:**
TASK 8.1 for the target types. **TASK 6.4 (2026-09-22) implemented:**
- `MoonConditions`, with a topocentric Moon–target separation in the equinox of
  date, once the targets were precessed (TASK 6.2). Measured: within 0.05° of USNO
  and Horizons for 45 geocentric and 135 topocentric star pairs.
- **Deletion note (as §6 required):** the mean-synodic-month
  `VisibilityCalculator.calculateLunarIllumination` (CALC-09, up to 4.7 pp off) was
  deleted. Its four tests now assert the same new-moon and full-moon thresholds
  against `MoonCalculator.illuminatedFraction`.
- **Evaluation instant (ADR-007 §9 left this to G6):** night-level scalars, today
  the illuminated fraction, are evaluated at **mean solar midnight
  (`startUtc + 12 h`)**. Illumination changes by at most about 6 pp across a night.
- **The sky warning's thresholds are unchanged** (illumination > 0.8 or Bortle ≥ 7,
  SI-006). They now read the accurate illumination. Gating by Moon altitude or
  separation is PD-17 / G10, not this task.

**TASK 6.2 decisions (owner, 2026-09-22), recorded here as §2 required:**
- **Precession — formula change** (rule 16, never silent).
  - Fixed-target J2000.0 coordinates are now precessed to the date (Meeus ch. 21,
    IAU 1976, eq. 21.2 and 21.4). This happens in the single domain function
    `VisibilityCalculator.calculateTargetAltitude`, used by the altitude curve,
    windows, chart and the ViewModel's current and culmination altitude.
  - **Measured** against USNO computed altitudes of 9 stars at 3 sites: the maximum
    error falls from **0.32°** to **0.017°**.
  - **Effect:** windows can shift by up to about two minutes.
  - **Not included:** nutation, aberration, proper motion (about 20–40″).
  - This gives TASK 6.4's separation a shared (of-date) frame.
- **Refraction policy.** Altitudes stay **geometric (airless)**; sunrise and sunset
  keep the standard **−0.833°** (mean refraction plus semidiameter); twilight limits
  are geometric by definition.
  - **Rationale:** at imaging altitudes (≥ 5°, default 20°) refraction is
    0.05–0.16°, smaller than the minimum-altitude preference's own uncertainty.
  - No pressure or temperature assumptions are needed.
- **Measurements of the existing Sun formula (§4).**
  - Altitude is within **0.0097°** of JPL Horizons (375 samples).
  - Every sunset, sunrise and civil, nautical and astronomical twilight crossing
    falls **0.07 to 4.98 min** after Horizons' instant.
  - Every USNO rise/set and civil-twilight event falls within the [−2, +7] min grid
    tolerance.
  - The formula meets §4 and **stays unchanged**; no ch. 25 replacement is needed.

### 1. Context (verified for this ADR at commit `a61459b`)

- **Time functions.** `AstronomicalEngine` provides the Julian Date (from UTC), GMST
  and LST. UTC is used as UT1 (|UT1 − UTC| < 0.9 s). Milliseconds are ignored. No
  ΔT (TT − UT) is applied anywhere.
- **Sun.** `VisibilityCalculator.calculateSunAltitude` uses a low-precision,
  almanac-style solar formula: mean anomaly, a two-term equation of centre, and a
  linearly varying obliquity. There is no nutation or aberration, and its accuracy
  has not been measured (SI-009).
- **Moon.** Only `calculateLunarIllumination`, a mean-synodic-month phase model with
  up to **4.7 percentage points** of error (SI-002). There is **no** Moon position,
  altitude, rise/set or Moon–target separation, although all of these are in the
  PRODUCT_SPEC MVP.
- **Targets.** Every target is a fixed RA/Dec (J2000, with no precession applied,
  SI-012). `target_selection_screen.dart` nevertheless offers **Planet, Moon, Comet
  and Asteroid** as target types. These bodies move, so a fixed position is wrong
  for them by an amount that grows with time.
- **Excluded by the rules.** An online ephemeris is ruled out: core calculations
  must work offline (CLAUDE.md "Offline-First").

### 2. Decision: an in-house Moon from Meeus (owner)

- **Engine.** The Moon is computed in **pure Dart, offline and deterministically**,
  following Jean Meeus, *Astronomical Algorithms*, 2nd ed. (Willmann-Bell, 1998).

  | Chapter | Used for |
  | --- | --- |
  | 47 | Geocentric position (ELP-2000/82 main terms). **The full periodic-term tables** (owner): all the longitude/distance and latitude terms the chapter lists. The stated accuracy is about 10″ in longitude and 4″ in latitude |
  | 48 | Illuminated fraction, from the Sun–Moon elongation |
  | 40 | Topocentric correction (lunar parallax, up to about 1°) |
  | 13 | Conversion to altitude/azimuth |
  | 15 | Rise/set convention, with the Moon's h₀ = 0.7275 π − 0.5667°, π being the horizontal parallax |

- **Sun inside the Moon model.** The Moon's illumination and elongation need the
  Sun. TASK 6.3 uses a Sun position consistent with the Moon's frame, for example
  Meeus ch. 25 (low accuracy, about 0.01°), and cites it. The existing Sun-altitude
  function stays as it is until TASK 6.2 has measured it.
- **Constants.** Every constant is transcribed with its chapter and table cited in a
  doc comment. The tables live in one domain file; there are no Flutter imports.
- **Time scale.** Meeus ch. 47 is in Terrestrial Time (TT). The Moon code applies a
  **documented ΔT**, cited from a source, with its value and validity range
  recorded. An error of ±10 s in ΔT moves the Moon by less than 6″, which is inside
  the tolerances in §4. UTC is used as UT1.
- **Frame.** Moon positions are geocentric apparent coordinates in the equinox **of
  date**.
  - **Consequence:** Moon–target separation (TASK 6.4) and any comparison with
    J2000 target coordinates must first bring both into the same frame.
  - Target precession to date is the precession decision assigned to **TASK 6.2**.
  - Until that is decided, separation is not computed. Mixing frames would cost up
    to about 0.36° in 2026 (≈ 26 years × 50″ per year).

### 3. Decision: moving target types (owner)

- **Hidden for new targets in 1.0.** The target editor no longer offers Planet, Moon,
  Comet or Asteroid (implemented in TASK 8.1, where the roadmap already hides them).
- **Existing targets of those types stay usable** and carry a visible warning:
  "fixed coordinates — this object moves; positions are not tracked". They are
  **never deleted or retyped silently**.
- **No ephemerides for planets, comets or asteroids.** A Moon *target* type would
  need the Moon model *plus* a targets-as-ephemerides design. Both are outside 1.0.
- **Not affected:** the Moon as *night conditions* (TASKs 6.3 and 6.4).

### 4. Planning-grade tolerances (the TASK 6.3 acceptance criteria)

**References:**
- **JPL Horizons** (ssd.jpl.nasa.gov/horizons) for positions and illumination.
- **USNO Astronomical Applications Department** (aa.usno.navy.mil) for rise/set and
  phase events.

Each fixture records its query and retrieval date (TASK 6.2).

| Quantity | Tolerance vs reference | Note |
| --- | --- | --- |
| Geocentric Moon RA and Dec (of date) | ≤ 0.02° (72″) | Meeus ch. 47 is at arcsecond level; the margin covers the ΔT and frame conventions |
| Topocentric Moon altitude (airless) | ≤ 0.05° | Horizons topocentric, no refraction |
| Illuminated fraction | ≤ 1 percentage point | Today's mean-phase model errs by up to 4.7 pp (SI-002) |
| New, first-quarter, full and last-quarter instants (USNO) | ≤ 10 min | Derived from elongation |
| Moonrise and moonset within a night | reported − USNO ∈ [−2 min, +7 min] | Events are reported on the 5-minute night grid (ADR-007 §9), at the first sample after the crossing, which adds (0, 5] min; ±2 min covers model and convention differences |
| Moon–target separation (TASK 6.4) | ≤ 0.05° | Only once targets and the Moon share a frame (§2, TASK 6.2) |

- **Test scope (roadmap TASK 6.3):**
  - at least **20 reference instants**;
  - spread over at least **2 years** and **3 latitudes**, including one at 60° or
    above, where moonrise/moonset can be absent: a night with none reports that
    explicitly, never as null;
  - the USNO phase events of at least one full lunation.
- **The Sun is measured the same way in TASK 6.2** (USNO twilight and rise/set on
  the grid; tolerance [−2, +7] min).
  - If the current formula misses that tolerance, a **new decision** is needed to
    replace it with ch. 25.
  - The formula must never be changed silently (rule 16).

### 5. Alternatives considered

| Alternative | Verdict | Reason |
| --- | --- | --- |
| Online ephemeris (JPL/USNO API) | Rejected | Offline-first; network-dependent core math |
| Adopt a Dart package | Rejected for now (owner) | Needs a licence check against GPL-3.0 and an accuracy check before use; no candidate was evaluated. It can be revisited if the in-house model fails §4 |
| Short truncation of ch. 47 (about 20 terms) | Rejected (owner) | Error of a few arcminutes that would itself need measuring; the full tables remove that question |
| Keep the mean-phase model | Rejected | 4.7 pp error and no geometry (SI-002); retired in TASK 6.4 |
| Keep the moving types selectable with a warning | Rejected (owner) | Invites plans that cannot be right |
| Hide the moving types and hide existing targets of those types | Rejected (owner) | A user's saved target would vanish from the picker |

### 6. Consequences

- **TASK 6.2:**
  - reference fixtures for Sun events and deep-sky alt/az;
  - the **precession decision** (J2000 targets to date, or not), which §2's
    separation depends on;
  - the refraction decision;
  - measurement of the existing Sun formula against §4.
- **TASK 6.3:** the Moon ephemeris per §2, accepted against §4.
- **TASK 6.4:** `MoonConditions` (altitude, illumination, rise/set within the night,
  separation once frames match) as annotations only, with no "impact %". The
  mean-phase model is deleted, with a DECISIONS note.
- **TASK 8.1:** the moving types are hidden in the editor, and existing ones are
  labelled (§3). **Done 2026-09-23** (target list, editor and Home; an existing
  moving-type target keeps its type on edit).
- SI-002, SI-009, SI-012, TD-032 and TD-036 stay **open** until those tasks land.
  This ADR changes no code.

## ADR-011: Equipment model and aperture semantics (1.0)

> **Amended by ADR-020 (owner, 2026-09-29, S7.D):** two camera-module fields join §3: the camera class (Phone · DSLR/mirrorless · Astro camera (colour) · Astro camera (mono) · Unknown; Unknown by default, never inferred) and the in-camera noise-reduction switch (off by default). The flat profile (§2) is unchanged. Built by S7.2a and S7.3b.

Status: accepted (owner, 2026-09-23, TASK 8.3). Resolves PD-03 and PD-10. **Implemented
2026-09-23 by TASK 8.4** (domain and schema v14; commit `445c781`); used by TASKs 8.5 (seeds)
and 8.6 (capability summary and exposure guidance).

### 1. Context (verified for this ADR at commit `6d9a90e`)

- **Storage** is normalized: `devices` → `camera_modules` → `optical_rigs` (schema v13,
  foreign keys `ON DELETE RESTRICT`, ADR-008 §4). `DriftEquipmentRepository` always
  creates one device, one camera module and one rig together (1:1:1), and exposes them as
  one flat `EquipmentProfile` whose `id` is the rig id (CLAUDE.md trap 1).
- **Dormant code:** `EquipmentCatalogRepository` / `DriftEquipmentCatalogRepository` and
  the domain models `EquipmentDevice`, `CameraModule`, `OpticalRig` are implemented and
  tested but registered nowhere and used by no ViewModel or screen (TD-026, DEV-D2).
- **Aperture:** `EquipmentProfile.aperture`, `OpticalRig.aperture` and the column
  `optical_rigs.aperture` are used as an **f-number** everywhere: the editor label
  "Effective Aperture (f/)", Home's `f/…`, the NPF call (`apertureFNumber`), the session
  log (`aperture_f` in JSON, `session_logs.aperture`). The one seed that stored a 72 mm
  diameter was corrected in TASK 4.4 (SI-005). The editor only checks `> 0` and falls
  back to `0.0` on a parse failure.
- **Units:** the domain names carry none (`focalLength`, `aperture`, `pixelPitch`,
  `sensorWidth`, `rotation`); only some columns do (`focal_length_mm`, `pixel_pitch_um`,
  `sensor_width_mm`, `resolution_width_px`, `rotation_degrees`).
- **Tracking:** `optical_rigs.tracking_state` (text, default `'unknown'`) exists; nothing
  shows or edits it, so every row holds `unknown`.
- **Exposure limits:** no per-rig limit exists. A capture block's exposure is already
  bounded to (0, 3600] s (TASK 5.3); NPF is implemented but not shown (PD-11).

### 2. Decision: keep the flat profile for 1.0 (PD-03, owner)

- 1.0 keeps **one flat equipment profile** over the existing three tables, still created
  1:1:1. No table is restructured.
- **Reusing a camera across rigs (composition UI) is deferred** beyond 1.0. If it comes,
  it is designed fresh against the tables, with its own ADR.
- **The dormant repository is removed in TASK 8.4** (owner): `EquipmentCatalogRepository`,
  `DriftEquipmentCatalogRepository`, the domain models `EquipmentDevice`, `CameraModule`
  and `OpticalRig`, and their test. The tables stay; the flat repository uses them.
- **Consequence:** DEV-D2's intended composition stays unmet in 1.0, now by decision
  rather than by accident; F-23 is scoped down to the flat profile.

### 3. Decision: unit-explicit names (renames happen in Dart)

`EquipmentProfile` fields in TASK 8.4 (columns are renamed only if unavoidable; the
mapping lives in the repository):

| Field | Unit | Column (existing unless marked **new**) |
| --- | --- | --- |
| `focalLengthMm` | mm | `optical_rigs.focal_length_mm` |
| `focalRatio` | dimensionless N (f/N) | `optical_rigs.aperture` (meaning documented as N) |
| `apertureDiameterMm?` | mm | `optical_rigs.aperture_diameter_mm` — **new**, nullable |
| `sensorWidthMm`, `sensorHeightMm` | mm | `camera_modules.sensor_*_mm` |
| `pixelPitchUm` | µm | `camera_modules.pixel_pitch_um` |
| `resolutionWidthPx`, `resolutionHeightPx` | px | `camera_modules.resolution_*_px` |
| `averageRawFileSizeMB?` | MB (10⁶ bytes) | `camera_modules.average_raw_file_size_m_b` |
| `rotationDeg?` | degrees | `optical_rigs.rotation_degrees` |
| `trackingType` | enum (§5) | `optical_rigs.tracking_state` |
| `maxExposureS?` | s | `optical_rigs.max_exposure_s` — **new**, nullable |

The UI shows the unit next to every number (TASK 8.4 acceptance).

### 4. Decision: focal ratio plus an optional diameter (PD-10, owner)

- **`focalRatio` N is required**; it is what every formula uses (NPF, exposure
  guidance). The existing `aperture` column keeps its values unchanged and is read as N.
- **`apertureDiameterMm` D is optional.** The user may enter either:
  - entering D stores D and derives **N = focalLengthMm / D**;
  - entering N alone stores N and leaves D unknown (null) — D is never back-filled;
  - entering both: accepted only if they agree within **1 %** (|f/D − N| / N ≤ 0.01);
    otherwise the form rejects the save and says which values disagree.
- **When D is stored, N is re-derived from f / D on every save**, so a changed focal
  length cannot leave the two inconsistent. The form shows N as derived in that case.
- **Plausibility bounds for the form** (assumptions for input sanity, not physics;
  TASK 8.4 documents them in code and may refine them with a DECISIONS note):
  N 0.5–32; D 1–2000 mm; focal length 1–20 000 mm; pixel pitch 0.5–30 µm; sensor
  side 1–100 mm; resolution 100–30 000 px; maximum exposure 1–3600 s (the capture-block
  limit). A parse failure is an error, never a silent `0.0`.

### 5. Decision: tracking type and an optional maximum exposure (owner)

- **Tracking type** ∈ {`untracked`, `tracked`, `guided`, `unknown`}, stored in the
  existing `tracking_state` column. Existing rows stay **`unknown`**; nothing infers a
  type from a device name or focal length. Phones and tripods are not assumed untracked.
- **Maximum sub-exposure** `maxExposureS` (seconds, optional, null = no limit): a user
  setting per rig, from their own mount or guiding experience. It is **not** computed.
- **Use (TASK 8.6):** the recommended maximum sub is `min(NPF, maxExposureS)` for an
  untracked rig and `maxExposureS` otherwise, shown as guidance; a light block longer
  than the recommendation gets a warning. **Guidance never blocks** a plan. Showing NPF
  itself is PD-11, decided in TASK 8.6. **Implemented 2026-09-23 (TASK 8.6):** as above;
  for unknown tracking NPF applies too, marked "if untracked" (PD-11).
- **RD-08 (2026-09-28, the owner; E.1, "RD-08 decided"):** the rig's tracking type is the plan's
  **default**; a plan may override it without changing the rig, and the plan's snapshot keeps the
  effective value. This section is otherwise unchanged. Built by S7.1 (2026-09-29).

### 6. Decision: existing rows are never reinterpreted (PD-10 migration policy, owner)

- Every stored value is kept exactly; the migration only **adds** the two nullable
  columns (`aperture_diameter_mm`, `max_exposure_s`). No value is converted, and no row
  is classified as "diameter" or "f-number" by guessing (ADR-008 §6 applies).
- **Review flag:** a profile whose N is **above 32** (most likely a diameter typed into
  the f/ field) is shown with a "please review this value" prompt in the equipment list
  and the editor. The flag is **computed at display time** (no column). Saving through
  the editor clears it only by making N valid (≤ 32) or by entering D.
- Session logs keep their stored `aperture` values (already f-numbers, `aperture_f`);
  snapshots are G11's.

### 7. Alternatives considered

| Alternative | Decision | Reason |
| --- | --- | --- |
| Expose composition (reusable cameras and rigs) in 1.0 | Rejected (owner) | Larger scope and migration risk for a benefit most 1.0 users don't need |
| Collapse the three tables into one flat table | Rejected | Schema churn with no user benefit; the tables already work |
| f-ratio only, no diameter | Rejected (owner) | Telescope users know D; forcing a manual division invites errors |
| Store D and derive N always | Rejected | Phone and camera-lens specs are quoted as f-numbers; D is unknown for them |
| Auto-convert values > 32 into diameters | Rejected | Silent guessing (PD-10, ADR-008 §6) |
| Keep the dormant repository | Rejected (owner) | Dead, tested code with no caller under a flat model |
| Compute a maximum exposure from the mount | Rejected | No sourced model; the user knows their mount |

### 8. Consequences and follow-up

- **TASK 8.4:** the renames and bounds of §3–§4; schema v14 adding
  `aperture_diameter_mm` and `max_exposure_s`; tracking type and maximum exposure in the
  form; the review prompt of §6; the dormant repository removed; migration tests with
  sample rows (including a row with N = 72 that stays 72 and is flagged).
- **TASK 8.5:** seeds get sources and confidence; phone seeds may carry N only.
- **TASK 8.6:** capability summary and the §5 guidance; PD-11.
- SI-005 and TD-026 close with TASK 8.4; this ADR changes no code.

## ADR-012: Weather provider, variables, alignment and staleness

Status: accepted (owner, 2026-09-23, TASK 9.1). Resolves PD-15. **Implemented in part:**
TASK 9.2 (snapshot, UTC parsing, request; commit `b3dfc20`), TASK 9.3 (cache, freshness,
failure states; commit `6aedf1b`), TASK 9.4 (night indicators, dew heuristic, attribution,
legacy path removed; commit `48d7a8c`). **Fully implemented.** Checked against `open_meteo_weather_repository.dart` and
`weather_conditions.dart` at commit `975f11e`, and against Open-Meteo's own pages
(docs, terms, licence) read on 2026-09-23.

### 1. Context (verified)

- **Today:** `OpenMeteoWeatherRepository` requests `current` and `hourly` values with
  `timezone=auto` and `models=icon_seamless` hard-coded; keeps the first **48 hours from
  local midnight today**, whatever night is being planned; parses times as **naive local
  strings** and discards `utc_offset_seconds`; caches the last response in preferences
  per rounded coordinates with **no expiry**, returning it silently when the network
  fails; substitutes `0.0` for a missing wind value; records no provider or model
  (TD-017, SI-010 weather part, F-29–F-31).
- **Provider facts (Open-Meteo, 2026-09-23):**
  - forecast horizon: `forecast_days` 0–16 (default 7); `start_date`/`end_date` select
    an interval; `past_days` 0–92;
  - `timeformat=unixtime` returns every time as UNIX epoch seconds **in GMT+0**;
  - models: "Best match" is the default, alongside national models (DWD ICON, ECMWF,
    NOAA GFS, Météo-France, …);
  - terms: the free API is for **non-commercial** use, under 10 000 calls per day,
    5 000 per hour and 600 per minute; commercial use needs an API key (subscription);
  - licence: API data are **CC BY 4.0** — attribution required.

### 2. Decision: provider and model (owner)

- **Open-Meteo stays** as the only provider for 1.0, behind the existing
  `WeatherRepository` interface. Its non-commercial terms are recorded for the release
  review (PD-12, TD-031); a commercial release would need a key held outside the code
  (rule 15).
- **Model: `best_match`** (the provider's per-location choice), replacing the hard-coded
  `icon_seamless`. Every fetch stores the **provider and the model requested**
  (`provider:open-meteo/best_match`, ADR-008 §6 style) and the UI shows it. A user-chosen
  model can be added later without reopening this decision.

### 3. Decision: variables (hourly), meaning and limits

| Variable (Open-Meteo) | Unit | Meaning shown to the user | Limits stated in the app |
| --- | --- | --- | --- |
| `cloud_cover` | % | Total cloud cover | A model area fraction, not a sky view |
| `cloud_cover_low` / `_mid` / `_high` | % | Cloud below 3 km (incl. fog) / 3–8 km / above 8 km | High thin cloud matters for imaging even when total cover is low |
| `precipitation_probability` | % | Chance of precipitation | Not every model provides it — then **unknown**, never 0 |
| `wind_speed_10m` | km/h | Wind at 10 m | Site exposure differs |
| `wind_gusts_10m` | km/h | Maximum gust of the **preceding hour** | Labelled as a preceding-hour maximum |
| `temperature_2m` | °C | Air temperature | — |
| `dew_point_2m` | °C | Dew point (feeds the dew warning, PlanningPreferences) | — |
| `relative_humidity_2m` | % | Relative humidity | — |
| `visibility` | m | **Horizontal visibility** (viewing distance; low cloud, humidity, aerosols) | Labelled horizontal visibility — **not transparency** |

- **Not used:** `is_day` (darkness comes from the app's own Sun calculations, ADR-007).
- **Deferred:** seeing and transparency — no provider variable measures them; any future
  index needs its own source and ADR.
- **No weather score.** Indicators are shown per hour and summarised per night; nothing
  combines them into a single "good night" number (G9 purpose).
- **Missing values are unknown (null), never a default** (SI-008): a missing value
  never becomes 0 (as the current wind fallback does).

### 4. Decision: time alignment (UTC)

- Request `timeformat=unixtime`; store and compute **every timestamp in UTC**. The
  provider's `utc_offset_seconds`/`timezone` are kept only as metadata; display goes
  through `NightTimeFormatter` in the site's zone (ADR-007 §6).
- The forecast is **sliced to the chosen `SessionNight`** (`[startUtc, endUtc)`), not to
  "the next 48 hours from local midnight". The request covers that night
  (`forecast_days` or `start_date`/`end_date`), capped at the provider's 16-day horizon.

### 5. Decision: horizon and partial coverage (owner)

- Only hours inside the chosen night are used.
- Hours of the night beyond the horizon, or missing from the response, are shown as
  **"no forecast"** — never as zero cloud or a clear sky.
- A night entirely beyond 16 days shows **"no forecast yet"**; the planner works without
  weather (offline-first).

### 6. Decision: staleness and cache (owner)

- Each stored forecast keeps its **fetch time (UTC)**, provider, model and site
  coordinates.
- **Age thresholds** (assumptions, documented; configurable later):
  - under **3 h**: current;
  - **3–12 h**: "aging", shown with its age;
  - over **12 h**: "stale" — still shown, clearly labelled, with a refresh offered.

  Model runs update every few hours, so 3 h tracks them.
- A cached forecast is **never presented as current**: when a refresh fails, the cached
  data is shown with its age state, and the failure is shown (TD-029 style), not
  swallowed.
- The cache key includes the rounded coordinates and the model; data for another site is
  never shown.
- Fetching stays well inside the free limits: on site or night change and on explicit
  refresh, plus a refresh when the data is aging and the planner is opened.

### 7. Decision: attribution

"Weather data by Open-Meteo.com" (CC BY 4.0) is shown on the weather card and on the
About & data sources page (TASK 8.2 page), with a link.

### 8. Alternatives considered

| Alternative | Decision | Reason |
| --- | --- | --- |
| Keep `icon_seamless` | Rejected (owner) | Strong over Europe, coarser elsewhere; best_match adapts per location |
| User-chosen model now | Deferred (owner) | Adds a setting before there is a need; the stored model makes it easy later |
| All-or-nothing coverage | Rejected (owner) | Loses useful early-night hours near the horizon |
| Stricter 1 h / 6 h staleness | Rejected (owner) | More refreshes without a quality gain; model runs are hours apart |
| A combined weather score | Rejected | Hides which factor matters; G9 purpose: indicators, no score |
| Treat visibility as transparency | Rejected | Horizontal visibility near the ground is a different quantity |

### 9. Consequences and follow-up

- **TASK 9.2:** a `WeatherSnapshot` (UTC hourly values, nullable per variable, provider,
  model, fetch time, coordinates) and UTC parsing with `timeformat=unixtime`; tests with
  recorded responses, including missing variables.
- **TASK 9.3:** fetch and slice for the chosen night; horizon and partial coverage;
  staleness states and cache; failures shown.
- **TASK 9.4:** the night's weather indicators (per variable, no score) and the dew
  warning; attribution.
- TD-017 and the weather part of SI-010 close with those tasks; this ADR changes no
  code.

## ADR-013: Imaging-opportunity semantics (gates, annotations, no score)

Status: accepted (owner, 2026-09-23, TASK 10.1). Resolves PD-17. Documentation only;
implemented in TASK 10.2 (calculator) and later G10 tasks. Checked against
`visibility_calculator.dart` (CALC-23), `moon_calculator.dart` (CALC-28/29),
`night_weather_summarizer.dart` (CALC-32), `planning_preferences.dart` and
`PlannerViewModel.skyDarknessWarning` at commit `bc3a20c`.

### 1. Context (verified)

- **Today:** a visibility window is Sun ≤ the darkness limit ∩ target ≥ the minimum
  altitude on the night's 5-min grid (CALC-23; both limits are preferences since
  TASK 5.2). Nothing explains excluded time. "Max altitude" is the altitude at
  culmination, even when that is in daylight (CALC-20, TD-023).
- **The sky warning** is a fixed rule — Moon illumination > 0.8 **or** Bortle ≥ 7
  (`skyDarknessWarning`, TD-033, SI-006) — that ignores whether the Moon is up, the
  target, and the filters.
- **Available inputs:** Moon altitude per sample, rise/set, illumination at mean
  solar midnight and the closest approach to the target (CALC-28/29); the night's
  hourly weather with freshness (ADR-012, CALC-32); site sky darkness as Bortle/SQM
  or unknown (TASK 7.4). **No horizon data exists** (no terrain or obstruction model).

### 2. Decision: gates (owner)

A sample belongs to an imaging window only when **every enabled gate passes**:

| Gate | Passes when | Default |
| --- | --- | --- |
| G1 Darkness | Sun altitude ≤ the darkness limit (`PlanningPreferences.darknessLimit`: −18°, −15° or −12°) | always on |
| G2 Altitude | target altitude (J2000 → date, airless; CALC-07/27) ≥ `minAltitudeDeg` | always on |
| G3 Horizon | target altitude ≥ the site's horizon altitude at the target's azimuth | **reserved** — the input exists but is empty in 1.0; G2 stands in for it (owner) |
| G4 Moon *(optional)* | **not** (Moon altitude > 0° **and** illumination ≥ X %) | **off**; X is a user preference (owner) |
| G5 Cloud *(optional)* | the hour's total cloud cover ≤ Y %, or the hour has **no forecast** | **off**; Y is a user preference (owner) |

- Boundaries are inclusive in the passing direction (Sun = limit passes; altitude =
  minimum passes; cloud = Y passes; illumination = X fails the Moon gate).
- **Unknown never excludes:** an hour with no forecast, or a Moon value that cannot be
  computed, passes its optional gate and is annotated as unknown (SI-008).
- **Moon gate details:** Moon altitude is CALC-28's topocentric, airless altitude of the
  Moon's centre, per sample; illumination is the night's value at mean solar midnight
  (changes by ≤ about 0.13 per day — an accepted approximation, stated in the UI).
- **Cloud gate details:** an hourly value at hour H applies to `[H − 30 min, H + 30 min)`
  (Open-Meteo cloud cover is instantaneous at H); a forecast that is aging or stale still
  gates, and the window says so.
- Default thresholds when the user enables a gate: **X = 50 %**, **Y = 50 %** —
  assumptions, not physics; editable in Settings.

### 3. Decision: annotations (never exclude time)

Each window carries, for its own time span:

- **Moon:** time above the horizon inside the window, illumination, the minimum
  separation from the target while both are up (CALC-29) — or "Moon down".
- **Weather:** cloud total/low/mid/high ranges, the dew-risk hours (CALC-32 heuristic),
  and the forecast's age state; "no forecast" when uncovered.
- **Sky darkness:** the site's Bortle/SQM with source, or unknown (never a default).
- **Max altitude inside the window** (replacing the culmination value, TD-023 part) and
  whether the window is clipped at the night's edge (ADR-007 §9).

### 4. Decision: reasons for excluded time

- Every excluded segment of the night lists **all** gates that fail in it, not only the
  first (for example "Sun above −18°; target below 30°").
- Segments are merged when their set of failing gates is identical.
- A night with no window says why, per whole-night case: no darkness at this limit
  (ADR-007 T15), target never above the minimum altitude, target never above it during
  darkness, or (with optional gates on) excluded by the Moon/cloud gate.

### 5. Decision: no composite score; ranking

- **No composite or weighted score** combines Sun, altitude, Moon, cloud or darkness
  (G9, G10 purpose). The user's list may be **ranked by usable time** (the sum of
  window durations after enabled gates) — a measured quantity, not a score — with the
  annotations shown beside it.

### 6. Decision: the sky warning (owner)

- The fixed Moon > 0.8 / Bortle ≥ 7 warning is **removed in TASK 10.2** and replaced by
  the per-window Moon annotations and the site's sky-darkness context, with no
  threshold verdict. TD-033's sky-warning part closes with it.

### 7. Worked examples (test vectors)

Common inputs unless stated: a normal night; darkness limit −18°; Sun ≤ −18° during
`[20:00, 04:00)`; target ≥ 30° (the minimum) during `[22:00, 06:00)`; all times UTC on
the night's 5-min grid; boundaries fall on grid points.

| # | Case | Extra inputs | Windows | Excluded segments (reasons) | Annotations |
| --- | --- | --- | --- | --- | --- |
| V1 | Broadband, Moon down | Moon below the horizon all night | `[22:00, 04:00)` = 6 h | `[20:00, 22:00)` target below 30°; `[04:00, 06:00)` Sun above −18°; outside both: both reasons | Moon down |
| V2 | **Narrowband with the Moon up**, gate off | Moon up `[21:00, 02:00)`, 85 % lit, min separation 40° | `[22:00, 04:00)` = 6 h (unchanged) | as V1 | Moon up 4 h of the window (22:00–02:00), 85 %, ≥ 40° away |
| V3 | Moon gate on, X = 50 % | as V2 | `[02:00, 04:00)` = 2 h | adds `[22:00, 02:00)` Moon up and ≥ 50 % lit | as V2 |
| V4 | Moon gate on, faint Moon | as V2 but 30 % lit | `[22:00, 04:00)` = 6 h | as V1 | Moon up, 30 % |
| V5 | Boundary | Moon gate on, X = 50 %, illumination exactly 50 % | as V3 | as V3 (50 % fails the gate) | — |
| V6 | Cloud gate on, Y = 50 % | hourly cloud at 22:00 20 %, 23:00 70 %, 00:00 no forecast, 01:00–04:00 10 % | `[22:00, 22:30)`, `[23:30, 04:00)` = 5 h | adds `[22:30, 23:30)` cloud above 50 % | `[23:30, 00:30)` no forecast (not excluded) |
| V7 | Cloud gate off | as V6 | `[22:00, 04:00)` = 6 h | as V1 | cloud 10–70 %, one hour without forecast |
| V8 | No astronomical darkness (summer, high latitude) | Sun never ≤ −18°; ≤ −12° during `[23:00, 01:00)`; target always ≥ 30° | none at −18° | whole night: no darkness at −18° | — |
| V9 | Same, limit −12° | as V8 with darkness limit −12° | `[23:00, 01:00)` = 2 h | rest: Sun above −12° | — |
| V10 | Target never high enough | target max 25° | none | whole night: target never above 30° | max altitude inside darkness: n/a |
| V11 | Dew risk | spread ≤ margin at 02:00–04:00 | as V1 | as V1 | dew risk 2 h (heuristic) — never excludes |
| V12 | Max altitude | target culminates at 13:00 (daylight) at 70°; in the window it peaks at 55° at 04:00 | as V1 | as V1 | max altitude in window 55°, not 70° |

These vectors become unit tests in TASK 10.2 (synthetic sampled inputs, so each
expected value is exact).

### 8. Alternatives considered

| Alternative | Decision | Reason |
| --- | --- | --- |
| Weighted "imaging score" | Rejected | Hides which factor matters; thresholds become hidden physics |
| Moon always gates | Rejected (owner) | Narrowband imaging works with a bright Moon up (V2) |
| Cloud always gates | Rejected (owner) | Forecast uncertainty; a planner must work offline and beyond the horizon |
| A flat per-site horizon now | Deferred (owner) | Needs a schema change inside G10; the minimum altitude covers it for 1.0 |
| Keep the sky warning with configurable thresholds | Rejected (owner) | A verdict without Moon altitude, target or filter context; annotations say more |
| Unknown forecast excludes the hour | Rejected | Unknown is not bad weather (SI-008) |

### 9. Consequences and follow-up

- **TASK 10.2:** the `ImagingOpportunity` calculator (gates G1–G5, reasons,
  annotations, max altitude inside windows, V1–V12 as tests); the fit (CALC-26)
  consumes its windows; `skyDarknessWarning` removed.
- New `PlanningPreferences` fields: Moon gate on/off + X, cloud gate on/off + Y
  (defaults off, 50 %, 50 %), added with 10.2.
- A per-site horizon profile needs its own decision and data source (future work);
  G3 stays reserved.
- This ADR changes no code.

### 10. Implementation notes and corrections (TASK 10.2, commit `613b32f`)

- **Implemented** in `ImagingOpportunityCalculator` (CALC-33); V1–V12 are unit tests.
- **Correction (§6, §9):** the fixed sky warning is removed in **TASK 10.3**, not 10.2 —
  MASTER_ROADMAP puts "remove the heuristic warning" in 10.3's (UI) scope, and 10.2 is
  UI-free. The owner decision itself is unchanged.
- **Correction (V12):** the in-window peak is at **03:00** — 04:00 is the window's
  exclusive end, so a peak there would be outside it.
- **Grid semantics:** sample i's gate state holds for `[t_i, t_{i+1})`; the last grid
  instant (`night.endUtc`) only decides the end clip flag. The previous windows code
  could emit a zero-length window when a target became usable exactly at `endUtc`;
  the calculator does not.
- **G3 (horizon):** no input and no enum value until a horizon decision exists.
- **Preferences:** `moonGateEnabled`/`moonGateMinIlluminationPct`,
  `cloudGateEnabled`/`cloudGateMaxPct` (off; 50 %), persisted; no Settings control
  yet (recorded as TD-050).

## ADR-014: Session aggregate, lifecycle and snapshots

> **Amended by ADR-019 (owner, 2026-09-27, S4.D; §3.1 added by S4.V1 and revised by S4.V2 to the owner's R2 + D1):** §3 gains planned or Saved · changed (`draft` with `plannedAtUtc`) → completed or abandoned **by a recorded result, without a run and without Save plan**, never for a planned night that has not ended. A plan snapshot is the immutable intent for its night: results and working edits never change it, and working edits belong to an independent working copy. From Stage 8, a saved plan whose night has passed is not resumed as current; the planner continues on a copy for tonight, the independent working copy. Until then this section's "Current session" rule is unchanged (D1). Save and version semantics after a plan is saved are left to Stage 6/8 design (S4.V3). See ADR-019 §3.1.

Status: accepted (owner, 2026-09-23, TASK 11.1). Resolves PD-18. **Schema implemented in
TASK 11.2 (commit `428f673`, v16).** Implemented by TASKs 11.2 (schema), 11.3 (repository, snapshot builders) and 11.4
(planner on a persisted draft). Checked against `app_database.dart` (schema v15),
`session_log.dart`, `logbook_repository.dart`, `home_screen.dart` (Save Session) and
`PlannerStateRepository` at commit `7388b1c`.

### 1. Context (verified)

- `session_logs` stores one row per saved session with **display strings** for the
  target, rig and site (`target_name`, `equipment_name`, `location_name`), a
  `session_date` instant, planned/actual counts and three weather columns that are
  never filled (DEV-D3). Its blocks are in `capture_blocks` (`ON DELETE CASCADE`).
- The plan being edited lives elsewhere: the blocks as JSON and the selected
  target/equipment/site ids in SharedPreferences (`PlannerStateRepository`), the
  night and the "active log" in ViewModel memory (DEV-D4). Save Session copies the
  current state into a `SessionLog`; there is no status, no night key, no time zone
  and no snapshot.
- Everything a snapshot needs already exists as pure domain values: `SessionNight`
  (ADR-007), `LocationProfile` with zone and sky darkness, `AstroTarget` with
  provenance, `EquipmentProfile` (ADR-011), `PlanningPreferences`, `CaptureBudget`
  (ADR-009), `ImagingOpportunity` (ADR-013) and `WeatherSnapshot` (ADR-012).

### 2. Decision: the aggregate

```
                 ┌──────────────────────────────────────────────┐
                 │ Session  (root; table session_logs, evolved) │
                 │  id                                          │
                 │  status: draft | planned | inProgress |      │
                 │          completed | abandoned               │
                 │  legacy: bool                                │
                 │  night key: eveningDate + siteId? + zoneId   │
                 │  createdAt / updatedAt / plannedAt /         │
                 │  startedAt / completedAt   (UTC ms)          │
                 │  results: actual/rejected counts, notes      │
                 └───┬──────────────┬──────────────┬────────────┘
      references     │              │              │  owns
  (nullable, SET NULL│on delete)    │              │
        ┌────────────┴──┐   ┌───────┴──────┐   ┌───┴──────────────────────────┐
        │ Site (0..1)   │   │ Target (0..1)│   │ CaptureBlock (0..n, ordered)  │
        │ location_     │   │ astro_       │   │  frame type, filter, exposure,│
        │ profiles      │   │ targets      │   │  count, binning, gain, policy │
        └───────────────┘   └──────────────┘   │  planned / completed /        │
        ┌───────────────┐                      │  rejected counters            │
        │ Rig (0..1)    │                      └───────────────────────────────┘
        │ optical_rigs  │   ┌──────────────────────────────────────────────────┐
        └───────────────┘   │ SessionSnapshot (0..2, owned, versioned JSON)    │
                            │  kind: plan | executionStart                     │
                            │  v, takenAtUtc, site, target, rig, night,        │
                            │  preferences (assumptions), budget, opportunity  │
                            │  summary, weather summary + provenance           │
                            └──────────────────────────────────────────────────┘
```

- **Session is the aggregate root.** A plan, its execution and its log are one
  Session in different states. **LogbookEntry = a completed Session** (plus legacy
  rows, §7); there is no separate log entity.
- **ExecutionState = status + per-block counters + events.** The status and counters
  are columns (TASK 11.2); the event list (started, paused, block done, interrupted
  with a reason, …) is persisted by the execution group (G13), not in 11.2.
- **References** to site, target and rig are nullable foreign keys with
  `ON DELETE SET NULL`: deleting a source never deletes or blocks a session.
- **Night key** = evening date (`YYYY-MM-DD`, ADR-007) + site id (nullable) + the
  zone id used to resolve it. The night's UTC window is recomputed from the snapshot's
  site values, never from the live site. Several sessions may share a night key (two
  targets in one night); no uniqueness constraint.

### 3. Decision: lifecycle (owner)

| From → to | Allowed | Effect |
| --- | --- | --- |
| (new) → draft | yes | created by the planner or by Duplicate |
| draft → planned | Save | plan snapshot taken (replaces any earlier one) |
| planned → planned | Save again | plan snapshot **replaced** (owner: refreshed on Save) |
| planned → draft | edit after Save | the plan changes; the next Save re-takes the snapshot |
| draft/planned → inProgress | Start | executionStart snapshot taken — **never changed afterwards** (owner) |
| inProgress → completed | Finish | completedAt set; becomes a logbook entry |
| draft/planned/inProgress → abandoned | Abandon | kept, listed, not in the logbook's completed list |
| completed → any | **no** (owner) | only results and notes stay editable; the plan, references and snapshots are frozen |
| abandoned → draft | no | use Duplicate |
| any → (deleted) | with confirmation | cascades to blocks and snapshots |

- **Duplicate** copies the plan (blocks, references) into a new draft for another
  night; counters, results, snapshots and events are not copied.
- **Current session (owner):** the planner opens the most recently updated session
  whose status is draft, planned or inProgress; with none, it creates a draft. No
  "current id" is stored in SharedPreferences — the database alone decides (DEV-D4).

### 4. Decision: snapshots

- Stored as **versioned JSON** (`{"v": 1, ...}`) per snapshot kind, with UTC epoch
  milliseconds for instants and explicit unit-suffixed keys (`focalLengthMm`,
  `latitudeDeg`). Readers accept known versions and treat unknown ones as "snapshot
  unavailable", never as zeros (SI-008).
- **Contents v1:** site (name, latitude, longitude, elevation, zone id, Bortle/SQM
  with source and date); target (catalog id, name, type, RA/Dec J2000, size,
  source); rig (the `EquipmentProfile` fields with units, tracking, spec
  confidence/provenance); night (evening date, start/end UTC); preferences in force
  (darkness limit, minimum altitude, margins, overheads, gates, dew margin); budget
  totals (integration, acquisition, window load, session budget); opportunity
  summary (windows with max altitude, excluded reasons, usable time, Moon
  illumination); weather summary with provider, model, fetch time and age.
- **History reads snapshots, never live joins.** A completed or in-progress session
  is displayed from its snapshot; the references only offer "open the current
  site/target/rig" and may be null.
- Snapshots are built by **pure builders** in the domain from domain values (TASK
  11.3), not by widgets.

### 5. Decision: storage

- **Evolve `session_logs` in place** (roadmap recommendation): additive columns for
  status, legacy flag, night key, timestamps, reference ids (SET NULL) and the two
  snapshot JSON columns; `capture_blocks` gains planned/completed/rejected counters.
  Indexes on status, evening date and target id. Drift type converters for the JSON.
  Renaming the table or the row classes (TD-045) is optional in 11.2.
- The old denormalized columns (`target_name`, `equipment_name`, planned counts,
  weather columns) stay for legacy rows and are not written by new code; their
  removal is a later cleanup.

### 6. Decision: the plan's single source

- From TASK 11.4 the plan being edited **is** the current Session's blocks in the
  database (autosaved); the SharedPreferences plan JSON and selected ids are migrated
  once into a draft and then retired.

### 7. Decision: legacy rows (owner)

- Every existing `session_logs` row becomes a **completed, legacy** session:
  read-only, still listed and shareable, shown from its stored text columns, with no
  snapshot and **no references guessed from names** (names are not unique).

### 8. Alternatives considered

| Alternative | Decision | Reason |
| --- | --- | --- |
| Separate Plan, Execution and Log tables | Rejected | Three copies of one night's story; the roadmap's aggregate is simpler |
| Reopen completed sessions | Rejected (owner) | The log would drift from what happened; Duplicate covers "do it again" |
| Keep every plan snapshot version | Rejected (owner) | Storage and UI cost without a clear use; the execution-start snapshot is the frozen record |
| Current session id in preferences | Rejected (owner) | Re-creates split state (DEV-D4) |
| Relink legacy rows by name | Rejected (owner) | Wrong matches are worse than no link |
| Live joins for history | Rejected | Edited or deleted sources would rewrite history (DEV-D3) |
| New `sessions` table | Rejected | Evolving in place keeps legacy rows and the cascade; roadmap recommendation |

### 9. Consequences and follow-up

- **TASK 11.2:** schema v16 — the columns and indexes in §5, block counters, legacy
  rows marked (status completed, legacy true), SET NULL references; migration tests
  with legacy rows.
- **TASK 11.3:** `SessionRepository` (one transaction per aggregate write; status and
  night queries) and pure snapshot builders; replaces `LogbookRepository` usages.
- **TASK 11.4:** the planner works on the current Session; the preferences plan is
  migrated once.
- **G13:** execution events.
- This ADR changes no code.

### 10. Implementation notes and corrections (TASKs 11.2–11.3)

- **Schema (11.2, `428f673`):** as §5; the planned count per block is the existing
  `frame_count`.
- **Correction to §5 (owner, TASK 11.3):** `target_name`, `equipment_name`,
  `session_date` and `planned_light_frames` are NOT NULL, so new rows **do** write
  them — as display labels taken at save time (the target and rig names, UTC midnight
  of the evening date, the light-frame count). They are never used to resolve
  references; the night key is `evening_date`.
- **Rows without a night key** (saved between 11.2 and 11.3, TD-052) are read as
  legacy: read-only and never the planner's current session.
- **Repository (11.3, `ad6609c`):** `SessionRepository` replaces `LogbookRepository`;
  every write is one transaction and a forbidden write throws `SessionStateError`
  without changing anything. The execution-start snapshot is written once by `start`.
- **Logbook (owner, 11.3):** lists every non-draft session and the legacy logs with a
  status label, since no session can reach "completed" before execution (G13).
- **Planner (11.4, `628fda6`):** the current session is resumed at start (most recent
  open) or created; every plan edit is autosaved (serialized) before the edit returns;
  the preferences plan migrates once into a draft. Owner decisions: past nights roll
  forward to tonight on resume; an edited saved plan is listed as "Planned, unsaved
  changes"; New = tonight + example plan; opening a frozen session copies it into a
  new draft. The active site and the transient position remain app-level preferences.

## ADR-015: Information architecture and navigation

> **Amended by RD-09 (owner, 2026-09-27, Stage 5; E.1, "RD-09 decided"):** the wireframes' field constraint "no destructive action without a confirmation" no longer applies to edits inside a plan (a capture block is deleted with Undo). Stored records, Abandon, Restore and leaving unsaved changes keep a confirmation.
> **Amended by ADR-019 (owner, 2026-09-27, S4.D):** §2's "same sections and order" is replaced by the answer-first planner (ADR-019 §6). The route map gains a Night & Moon and a Weather detail (§9). §7's Library pages manage and never select (§8). The four tabs stand; the second is labelled Logbook (§10). See `docs/IA_WIREFRAMES_ADDENDUM.md`.

Status: accepted (owner, 2026-09-23, TASK 12.1). Resolves PD-19 and PD-14. Documentation
only; wireframes and the route map are in `docs/IA_WIREFRAMES.md`. Implemented by TASK
12.2 (navigation shell), 12.3 (screen-scoped ViewModels), 12.5 (Tonight dashboard) and
G13 (execution). Checked against `app_router.dart` and `home_screen.dart` at commit
`4c3bf69`.

### 1. Context (verified)

- One long Home page holds the planner (target, opportunity, equipment, capture plan,
  weather, sky darkness, Save) with about ten app-bar icons as entry points; every
  other screen is a flat `GoRoute` (`/target`, `/equipment`, `/location`,
  `/location/pick`, `/sites`, `/sites/edit`, `/about`, `/settings`, `/tonight`,
  `/logbook`, gated `/metadata`). There is no tab state and no place for sessions
  (G11) or execution (G13) to live.

### 2. Decision (owner)

- **Bottom navigation with four tabs:** **Tonight** (fixed dashboard, TASK 12.5) ·
  **Sessions** (every session: drafts, planned, in progress, completed, legacy) ·
  **Library** (rigs, targets, sites) · **Settings** (planning thresholds, gates, NPF k,
  field mode, about and data sources).
- **One session planner** (today's Home content, same sections and order) at
  `/session/:id`, above the tabs, opened from Tonight's current-session card and from
  the Sessions list.
- **Sites live in Library** with rigs and targets; the active site is switched from
  Tonight's header in one tap.
- **PD-14:** Tonight is a **fixed** view (night window, site, current session with its
  fit and reason, Moon, weather with its age, quick actions); **no customizable
  dashboard** in 1.0.
- **Execution** is a full-screen route `/session/:id/run` above the tabs (G13).
- **Tonight's candidates** (TASK 10.4) moves to `/tonight/candidates`.

### 3. Decision: navigation rules

- go_router `StatefulShellRoute` with one navigator per tab; each tab keeps its state.
- Android back pops within a tab; at a tab root it returns to Tonight; at Tonight's
  root it leaves the app. Pages above the shell return to the tab they came from.
- `FeatureScope` gates stay the only gate (metadata import under Settings until G17).
- Deep links are out of scope.

### 4. Decision: field constraints

Touch targets ≥ 48 dp; primary actions in the lower half; pickers over typing; red
field mode one tap away from Tonight and the planner, dialogs included; destructive
actions confirmed; unknown shown as unknown (SI-008). Details in `docs/IA_WIREFRAMES.md` §3.
*(Status 2026-09-24, TASK 12.4: red field mode is one tap from Tonight and the planner,
with dialogs, date pickers and snackbars included; tap targets keep 48 dp — the one
shrink-wrapped action was fixed and a test forbids new ones. "Primary actions in the
lower half" is not audited yet — TASK 12.5 designs the Tonight dashboard.)*

### 5. Alternatives considered

| Alternative | Decision | Reason |
| --- | --- | --- |
| Tonight · Plan · Logbook · More | Rejected (owner) | Splits one session's plan and log across tabs (ADR-014: one aggregate) |
| Three tabs (Tonight · Sessions · More) | Rejected (owner) | Library items are used often at planning time |
| Tonight tab = the full planner | Rejected (owner) | The dashboard question ("what can I image tonight?") gets buried again |
| Sites under Settings | Rejected (owner) | Sites are data the user builds up, like rigs and targets |
| Customizable dashboard (PD-14) | Rejected (owner) | Scope and testing cost without a demonstrated need |

### 6. Consequences

- **12.2:** the route map as specified; old routes redirect or are replaced; navigation
  and back-button tests.
- **12.3:** ViewModels split along these screens (Tonight, SessionPlan, Sessions, Gear,
  Sites).
- **12.5:** the Tonight dashboard and first-run flow.
- This ADR changes no code.

### 7. Implementation notes (TASK 12.2, commit `aa748e6`)

- **Pickers for the planner:** the planner (above the tabs) opens target, rig and
  site selection as root-navigator routes `/select/target`, `/select/rig`,
  `/select/site` (the same screens as the Library pages), so choosing returns to the
  planner instead of switching tabs.
- **Editors:** the site editor and the map pickers are root-navigator routes
  (`/site/edit`, `/site/pick`, `/position`) so both the Library and the planner can
  open them; the rig and target editors stay dialogs, so `/library/rigs/edit` and
  `/library/targets/edit` from the wireframes do not exist as routes.
- **Interim Tonight root:** site, night, current session (status, target, rig, usable
  time) and actions (Open planner, What can I image tonight?, New session) until the
  TASK 12.5 dashboard.
- **Settings from the planner:** "Change in Planning Settings" switches to the
  Settings tab (`go`), leaving the autosaved planner.

## ADR-016: Execution model under Android constraints

> **Amended by ADR-019 (owner, 2026-09-27, S4.D):** execution is **optional**, off the primary path ("Track live"). Results are recorded after the session, and their counts are written as events, so the counters still equal the replay. The tracker's Finish leads to the same result form (ADR-019 §4). §2–§6's model is unchanged for live runs.
> **Superseded in part by the owner (2026-09-27; E.1, "Stages 6–11 amended after Stage 5"):** the live mode leaves the target product. Stage 8 (P8.4) retires its UI after a dependency audit that decides what stays; existing runs, events and history stay readable, and a run in progress at the upgrade can still be finished or marked not done. This ADR describes the code until P8.4 records its amendment.

Status: accepted (owner, 2026-09-24, TASK 13.1). Resolves PD-20. **§2–§5 implemented in
TASK 13.2 (commit `14467e7`, schema v17); §6 in TASK 13.3 (commit `c8e2240`).** Documentation only —
this ADR changes no code. Checked against `session_repository.dart`, `session.dart`,
`app_database.dart` (schema v16: `capture_blocks.completed_frames` /
`rejected_frames`, `session_logs.started_at_utc_ms` / `completed_at_utc_ms` and the
execution-start snapshot column) and `capture_budget_calculator.dart` at commit
`a8ad5b5`.

### 1. Context (verified)

- ADR-014 already gives execution its frame: the `inProgress` status, **Start**
  (draft/planned → inProgress, taking the execution-start snapshot once, never
  changed afterwards), **Finish** (→ completed) and **Abandon**, each one transaction
  in `SessionRepository` (`start`, `complete`, `abandon`); per-block
  `completed_frames` / `rejected_frames` counters exist but nothing writes them; the
  plan cannot be edited once a session is in progress (`updatePlan` accepts draft and
  planned only).
- Nothing records *what happened during* a run: no running/paused state, no current
  block, no events (ADR-014 §2 left the event list to G13).
- **Android constraints.** A backgrounded app's Dart timers stop, and the process can
  be killed at any time without a callback; the phone can reboot; the wall clock can
  be changed by the user or by network time; a time-zone change does not change UTC.
  The app has no background service, and adding one (a foreground service with a
  permanent notification) is out of scope.
- The imaging itself happens on the user's camera or capture software; AstroPlan
  controls no hardware (no camera control, ASCOM or INDI — CLAUDE.md scope).

### 2. Decision: states

The session status stays ADR-014's. Inside `inProgress`, the execution state is
**running(block)** or **paused**:

```
  draft / planned ──Start──►┌──────────────────── inProgress ────────────────────┐
  (refused while another    │                                                    │
   session is in progress)  │   ┌──────────────┐   Pause / Interrupt(reason)     │
                            │   │ running(b)   │ ─────────────────────► ┌──────┐ │
                            │   │              │ ◄───────────────────── │paused│ │
                            │   └──────┬───────┘        Resume          └──────┘ │
                            │          │ Select block b' (running or paused)     │
                            │          ▼                                         │
                            │   running(b') …    Confirm / Reject frames on b    │
                            └──────┬───────────────────────────┬─────────────────┘
                                   │ Finish                    │ Abandon
                                   ▼                           ▼
                               completed                   abandoned
```

- **Start** puts the session in `running` on the first light block with frames left
  (or the one the user picks).
- **One session in progress at a time (owner).** Start is refused while another
  session is in progress; the app offers to open, finish or abandon that one. The
  repository enforces it (a `SessionStateError`, nothing written).
- Frames are **confirmed or rejected by the user** (+1, −1, "accept the estimate",
  reject) in either sub-state; counters never go below zero.
- Finish and Abandon are allowed from running or paused; ADR-014 §3 governs what
  stays editable afterwards (results and notes only).

### 3. Decision: progress comes from persisted UTC timestamps

- **No timer holds state.** Everything the execution screen shows is recomputed from
  the stored events and "now" (the injected `Clock`), so backgrounding, a kill or a
  reboot loses nothing: the screen is a pure function of the database and the clock.
- **Running time in the current block** = the sum of the running intervals since the
  block was selected, each from its event's UTC instant to the next event's (or now).
- **Estimated frames** = ⌊running time ÷ (exposure + per-frame overhead)⌋, with the
  per-frame overhead taken from the **execution-start snapshot's** preferences (frozen,
  so a Settings change mid-run does not move the estimate). Dither, refocus and
  meridian-flip time are **not** subtracted: the estimate is an upper-bound
  approximation, labelled "about N (estimated)", never shown as a count. It is capped
  at the block's frames left, with "plan reached" shown instead of a larger number.
- **Estimates are never written.** Only a user confirmation changes a counter;
  "accept the estimate" writes the estimate as a confirmation event, so the stored
  number is always one the user saw and accepted. (The formula is registered in
  `SCIENTIFIC_INTEGRITY.md`'s calculation register when TASK 13.2 implements it.)

### 4. Decision: every transition is persisted

- **Events, append-only (owner): a new `session_events` table** (schema v17): id,
  session id (`ON DELETE CASCADE`), a per-session sequence number (unique with the
  session id), `at_utc_ms`, kind, block id (nullable), an integer delta (confirm /
  reject), an interruption reason tag (nullable), and a clock-adjusted flag.
- **Kinds:** started, blockSelected, paused, interrupted (a pause with a reason:
  clouds, wind, dew, equipment, other), resumed, framesConfirmed, framesRejected,
  finished, abandoned.
- **One transaction per transition:** the event row plus its effects (status and
  timestamps on `session_logs`, the block counters on `capture_blocks`). The events
  are the source of truth; the counters are a projection kept in the same
  transaction, and replaying the events must reproduce them (a test in 13.2).
- The execution state is a **pure fold** over the events (domain, no Flutter), and
  each transition is a pure function that accepts or rejects an event for a state.

### 5. Decision: kill, reboot, clock and stale scenarios

| Scenario | Behaviour |
| --- | --- |
| App backgrounded, screen off | Nothing runs; on return the screen recomputes from the events and now. |
| Process killed while running | At the next start the in-progress session is found (`mostRecentOpen`) and a **resume prompt** shows the block, how long it has been running and the estimate. Options: continue (the time the app was closed counts — the camera may have kept shooting), pause now, finish, abandon. Counts stay as last confirmed until the user confirms more. |
| Process killed while paused | Resumes paused; the prompt says since when. |
| Phone rebooted | Same as a kill: stored UTC instants survive; no uptime counter is used. |
| Wall clock moved **back** (now earlier than the last event) | The current interval counts as zero; new events are stamped at the last event's instant and flagged `clockAdjusted`; the screen says the phone's clock changed and the estimate may be off. Event order is always by sequence number, never by time. |
| Wall clock moved **forward** | Indistinguishable from elapsed time; bounded by the cap on the estimate (frames left) and by the stale rule below. |
| Time-zone change or travel | No effect on progress (UTC); times are shown in the site's zone as everywhere else (ADR-007). |
| Night over (now after the night's end in the execution-start snapshot) | **Resume prompt, never auto-finish (owner):** continue, finish (confirm counts) or abandon. Nothing is completed or estimated into the counters without the user. |
| Start pressed while another session is in progress | Refused; offer to open, finish or abandon the running one (owner: one at a time). |

### 6. Decision: foreground only; what is not built

- **Foreground only.** No background or foreground service, no alarms, no
  notifications (deferred; a later ADR would cover them), no reminders.
- **Keep screen on (owner): opt-in**, off by default, a persisted display preference,
  active only while the execution screen is visible and a session is running. It needs
  a wakelock plugin (candidate: `wakelock_plus`, BSD-3-Clause — the licence and the
  Android permission are re-checked when TASK 13.3 adds it; the owner approved adding
  such a dependency for this purpose).
- **No hardware control:** no camera control, ASCOM, INDI or capture-software
  integration; the user reports frames.

### 7. Alternatives considered

| Alternative | Decision | Reason |
| --- | --- | --- |
| In-memory timer driving the counters | Rejected | Dies with the process or in the background; the state would be lost |
| Android foreground service with a notification | Rejected for 1.0 | Permissions, a permanent notification and platform code for little gain while the user is at the telescope with the app open |
| Auto-increment counters from the estimate | Rejected | The roadmap requires user confirmation; an estimate is not a count (dither, refocus, failed frames) |
| Monotonic uptime clock via a platform channel | Rejected for 1.0 | Lost on reboot and needs platform code; UTC wall clock with the guards in §5 covers the cases |
| Several sessions in progress | Rejected (owner) | Harder to reason about after a kill; one rig per session in 1.0 |
| Auto-finish when the night ends | Rejected (owner) | Would complete a log the user never confirmed |
| Events as a JSON list on the session | Rejected (owner) | Every transition would rewrite the whole list; a table appends one row and is easy to query |
| No keep-screen-on | Rejected (owner) | Opt-in keeps the tracker glanceable without changing the phone's settings |

### 8. Consequences

- **TASK 13.2:** schema v17 (`session_events`, migration and snapshot tests); the pure
  execution state machine (fold + transitions, the estimate); repository methods that
  append an event and apply its effects in one transaction, refuse a second in-progress
  session and replay events; the resume prompt at start. Tests: the transition table,
  a restart mid-block, clock jumps both ways, a replay equal to the counters.
- **TASK 13.3:** the execution screen (one-thumb, red-safe, large text); the opt-in
  keep-screen-on switch and the wakelock dependency.
- **TASK 13.4:** reconciliation from the confirmed counters into results; planned vs
  actual.
- This ADR changes no code.

### 9. Implementation notes (TASK 13.2, commit `14467e7`)

- **Status:** §2–§5 implemented in the domain, the repository and schema v17; the
  tracking screen (§6's keep-screen-on) is TASK 13.3.
- **Refinement of §3 (estimate):** the estimate subtracts the frames already confirmed
  or rejected since the block was selected, so accepting it twice never counts a frame
  twice; confirmed and rejected frames are separate counts (a rejected frame was
  captured).
- **Start:** records a `started` event in the same transaction as the status change;
  a plan without blocks cannot start.
- **Finish / Abandon:** `complete` and `abandon` append `finished` / `abandoned` for a
  session in progress; abandoning a draft or planned session records no event.
- **Events end with the run:** after `finished` or `abandoned` no event is accepted;
  editing results after completion goes through `updateResults` (ADR-014 §3; 13.4).
- **Resume prompt:** keep going (nothing written), pause now (a `paused` event), finish,
  abandon (after a confirmation); it is shown once per start, on Tonight.

### 10. Implementation notes (TASK 13.3, commit `c8e2240`)

- **Status:** §6 implemented (tracking screen, opt-in keep-screen-on); ADR-016 is
  implemented except reconciliation (TASK 13.4).
- **Owner decisions (TASK 13.3):** Start is in the planner and on Tonight's session card;
  it needs what Save needs (site, target, rig) and takes the execution-start snapshot
  itself (no prior Save). After Start the planner continues on a new draft copy of the
  plan; on a restart, when the most recent open session is in progress, the planner
  adopts a copy too — it never edits a run (TD-055 resolved).
- **The tracker reads the snapshot:** night, site, target and minimum altitude come from
  the execution-start snapshot; the timeline, the target's altitude curve and the Moon's
  rise/set are computed once from them (existing calculations CALC-22, CALC-24, CALC-28)
  and turned into countdowns by `ExecutionOutlook` (CALC-36). A later site or target
  change in the planner cannot move a run's countdowns.
- **Keep screen on:** `wakelock_plus` 1.8.0, licence verified on pub.dev (BSD-3-Clause),
  a screen wakelock only (no Android permission); behind the `ScreenWake` interface,
  off by default, persisted, enabled only while the tracker is visible and the run is
  running or paused.
- **Accept estimate** stores the shown estimate as confirmed frames (§3); Resume/Keep
  going in the resume prompt opens the tracker.

### 11. Amendment and implementation notes (TASK 13.4, commit `c1e52ce`)

- **Amendment to §9 ("events end with the run"), owner decision:** after `finished`,
  confirm/reject **corrections** are accepted — each a timestamped event after the
  `finished` event, so the counters still equal the replayed events and history shows
  when a count changed. Nothing else is accepted after `finished`, and nothing after
  `abandoned`.
- **Finish opens reconciliation (owner):** the tracker's Finish opens the results page;
  the session is completed only by Complete there (or ended by Abandon).
- **Result totals:** `complete()` and every correction write `actual_light_frames` and
  `rejected_frames` (light blocks only) from the counters in the same transaction; the
  results page saves notes and optional conditions (temperature, humidity, cloud
  cover — empty stays unknown). A notes-only edit is timestamped by the session's
  `updated_at`.
- **Planned vs actual (CALC-37):** light integration, planned (frames × exposure) vs
  confirmed; rejected frames and calibration are not integration. Shown on the results
  page and in Sessions (owner); the full session detail is TASK 14.1.
- **Status:** ADR-016 is implemented (TASKs 13.2–13.4); device checks are listed in
  `docs/TEST_PLAN.md`.

## ADR-017: Image metadata reading (Stage 2 foundation)

**Amended by ADR-018 §3 (2026-09-26, S3.D):** the contract (§2) gains image width and height (px). **Implemented 2026-09-26 (S3.1).**

**Corrective implementation note (2026-09-26, S2.V4, after the repeat validation):** the HEIF
`iloc` parser accepts at most 16,384 extents over all items (TD-067; an extent with all-zero
field sizes occupies no bytes, so the byte budget did not bound the work). The S2R-02 ruling
(E.1, "Stage 2 repeat validation: fixes and the HEIF brand ruling") narrows §13's HEIF entry:
- HEIF still images (`heic`, `heix`, `heim`, `heis`, `mif1`) are read;
- AVIF and HEIF image sequences are recognised only, until a sample exists.

**Corrective implementation note (2026-09-26, S2.V1–S2.V3):** the owner authorized
fixing the validation failures. Single-valued integer fields accept count 1;
unsupported arrays are unparseable, never interpreted as offsets or guessed.
An identified Exif APP1 with a short TIFF header is unreadable. Android returns
consumed-byte accounting (including streamed prefixes) to the serialized Dart
source; §4's per-file budget and §6's range bound both hold. Unknown consumption
after I/O failure prevents further reads on that source. This implements the
existing bounds/unknown rules; it does not approve HEIC, reopen visibility, or
close RG-14. See `refinement/STAGE_2_CORRECTIONS.md`.

Status: accepted (owner, 2026-09-26, after S2.R1; the constraints are in E.1, "Stage 2
decisions: RG-01, PD-21, RD-16"). Resolves PD-21. **Implementation:** partial.
- **Done:**
  - §4.1, §4.2 and §4.4 (S2.1, 2026-09-26, commit `a25398c`): `lib/domain/metadata/` and
    `lib/data/metadata/file_metadata_source.dart`, as specified;
  - §2's types and §5 (S2.2, 2026-09-26, commit `b8d626a`): `capture_metadata.dart` and
    `metadata_value.dart`. The conversion rules are recorded as CALC-39;
  - §2's extraction, §4.3, §8 (DNG only) and §9 (S2.3, 2026-09-26):
    `tiff_metadata_reader.dart` and `capture_metadata_reader.dart`, with synthetic
    fixtures and the local real-sample test (commit `59c9f03`);
  - §6 (S2.4, 2026-09-26, commit `26aff9a`): implemented and host-tested. **Accepted 2026-09-26:** device checks M1
    and M2 passed on the owner's phone (Android 16), with no cache copy. The non-seekable (cloud) path was not run;
  - §7 and §10 (S2.5, 2026-09-26, commit `a2f42a5`): `exif` and `image_picker` removed after a `grep`; the hidden screen reads the
    contract; `FeatureScope.metadataImport` stays false.
  - §13.2 and §13.3 (S2.7, 2026-09-26, commit `9a0432b`): layered readings, `MetadataFormatReader` dispatch, the shared
    `ExifStructure` with `MetadataSourceWindow`, and the recognition-only formats.
  - JPEG (S2.8, 2026-09-26, commit `360fd8f`): `jpeg_metadata_reader.dart`, verified on the owner's phone JPEG.
  - HEIF (S2.9, 2026-09-26, commit `bb28452`; approved by the owner): `heif_metadata_reader.dart`, as S2.R2 §7 recommends, verified locally on the
    owner's HEIC.
- **RG-14 decided 2026-09-26 (E.1):** no proprietary RAW in Stage 2; per-format adapters afterwards, only with real
  samples; `ExifInterface` and LibRaw rejected. Device check M3 (HEIC) passed 2026-09-26.
- **Open:** nothing within Stage 2. The RAW adapters are later sample-driven work. FITS and PNG are out of Stage 2 (owner).

### 1. Context (verified)

- **The prototype** (`metadata_extractor.dart`, F-45, TD-018):
  - reads whole files;
  - does its I/O in `lib/domain`;
  - returns string-only fields;
  - misreads FITS strings;
  - and, on the owner's real phone DNGs, finds none of the capture fields (TD-064).
- **Both pickers copy the whole file into the app cache before returning:**
  - `file_picker` 13.1.0 (`android_file_picker` 2.0.0, `FileUtils.kt` `openFileStream`);
  - `image_picker` 1.2.3 (`image_picker_android` 0.8.13+23, `FileUtils.java:63–90`), which
    also offers images only (the Photo Picker `ImageOnly`, or `image/*`).
  - Nothing clears the `file_picker` cache (TD-065).
- **Evidence:** `docs/refinement/research/RG-01_METADATA_FORMATS.md`.

### 2. Decision: the metadata contract

Stage 2 extracts **only** these fields, each as a typed value with provenance (§5):

| Field | Unit / form | DNG/TIFF source |
| --- | --- | --- |
| Exposure time | seconds | ExposureTime (33434) |
| Sensitivity | a value **and its kind**: ISO speed (kind unspecified unless SensitivityType says so) | ISOSpeedRatings (34855), SensitivityType (34864) |
| Focal length | mm | FocalLength (37386) |
| 35 mm-equivalent focal length | mm, **a separate field**, never used as the focal length | FocalLengthIn35mmFilm (41989) |
| f-number | dimensionless | FNumber (33437) |
| Capture time | the local wall-clock time as recorded, plus the offset **only if recorded**; otherwise explicitly **zone unknown** | DateTimeOriginal (36867), OffsetTimeOriginal (36881) |
| Camera identity (raw strings, for Stage 3) | text | Make (271), Model (272), UniqueCameraModel (50708) |
| Lens identity (raw strings, for Stage 3) | text | LensMake (42035), LensModel (42036) |

- Tags are looked up in IFD0 **and** the EXIF IFD (34665). A value found in both with
  different contents is **ambiguous**, and stays Unknown with both raw values kept.
- FITS fields are added to the contract, by amending this ADR, when a real FITS sample exists
  (§8). No other format is in the contract.

### 3. Decision: privacy exclusions

- **Never extracted:**
  - GPS or any location (the GPS IFD 34853; FITS `SITELAT`/`SITELONG`/`SITEELEV`; XISF
    `Observation:Location:*`);
  - serial numbers and unique ids (BodySerialNumber, CameraSerialNumber, LensSerialNumber,
    ImageUniqueID, RawDataUniqueID);
  - observer or owner identity (Artist, Copyright, `OBSERVER`).
- The reader does not follow the GPS IFD pointer at all.
- **No time zone is inferred** from anything: not the device, the site or the file name. A
  capture time without a recorded offset stays zone-unknown; Stage 8 may ask the user.

### 4. Decision: bounded access

1. **The domain interface** `MetadataSource` (pure Dart) offers `length` and
   `read(offset, count)`. It is wrapped by a **byte budget**: 1 MiB per file by default, with
   each read at most 64 KiB. A read beyond the end, or over the budget, is a typed failure,
   never a crash. Nothing ever reads the whole file.
2. **Recognition by signature**, never by name or picker filter:
   - TIFF: `II*\0` / `MM\0*`, with DNG identified by DNGVersion (50706);
   - FITS: `SIMPLE  =` in the first card. It is recognised but unsupported until §8.
   - Anything else is `unsupported(format)`.
3. **Readers** are pure Dart and in-house, over `MetadataSource`. The TIFF/EXIF IFD reader:
   - bounds-checks every offset and count;
   - guards against loops (visited offsets);
   - limits the number of IFD entries and chain length;
   - never reads strip or tile data.
4. **I/O lives in the data layer only.** A test forbids `dart:io`, the platform and parsing
   packages in the domain metadata code.

### 5. Decision: typed values and provenance

- **The reading is one of:**
  - `read(values)`;
  - `unsupported(format)`;
  - `unreadable(reason)` (truncated, corrupt, budget exceeded, I/O failure).
- **Each field is one of:**
  - `known(value, unit, source)`, where the source is the format, the tag or keyword, and
    the provenance "file metadata as written by the capture device or software";
  - `absent`;
  - `unparseable(raw)`;
  - `ambiguous(raws)`.
- Unknown stays Unknown: no default, no 0.
- Rationals are kept exactly until converted, with a zero denominator unparseable.

### 6. Decision: Android file access and cache ownership

1. **Metadata files are opened without a copy.** An in-app platform channel (Kotlin in
   `android/app`, no new dependency) handles:
   - **pick:** starts `ACTION_OPEN_DOCUMENT` (`*/*`, `CATEGORY_OPENABLE`) and returns the
     content URI, display name and size;
   - **reads:** serves `read(uri, offset, count)` through
     `ContentResolver.openFileDescriptor(uri, "r")` with a positioned read;
   - **non-seekable descriptors** (for example a streaming cloud provider): a sequential
     read from the start, allowed only while `offset + count` stays within the byte budget,
     otherwise a typed failure.
2. **The grant is transient.** No persistable URI permission is taken, and URIs are never
   stored.
3. **Cache ownership:**
   - the metadata path creates **no** cache files;
   - `file_picker`'s cache belongs to the flow that picked the file. The backup restore
     (TASK 14.4, which reads its file whole by design) clears it with
     `FilePicker.clearTemporaryFiles()` once the pick is consumed or abandoned (TD-065).
   - No other file-management behaviour is added.
4. **Host tests** exercise the Dart side through a fake channel and a file-backed
   `MetadataSource`. The Kotlin path needs a device check (see E.1).

### 7. Decision: dependencies

Justified by the current repository (`grep` at `565341b`):
- **`image_picker`** is used only by `metadata_import_screen.dart`. It copies the whole file
  and cannot offer FITS or other non-image files, so it cannot meet §4 or §6. It is removed
  when the screen moves to the new foundation.
- **`exif`** is used only by `metadata_extractor.dart`. Its public API accepts only a whole
  byte list or a `dart:io` `File` (with a content URI and no copy there is no `File`). It
  cannot take a budgeted random-access source, and it decodes far beyond the contract
  (MakerNotes, thumbnails). So it is removed with the prototype extractor.
- **`file_picker`** stays, for backup and restore only.

### 8. Decision: formats

- **Supported in Stage 2:** DNG, verified on the owner's two real samples, with an IFD0
  (TIFF/EP) layout. A claim of support for any other layout or maker needs a representative
  real sample and tests.
- **FITS:** only after the owner supplies a real FITS sample. Adding it amends §2 and §8.
- **Not supported, and sample-driven:** JPEG, XISF, CR3, CR2, NEF, ARW, RAF, ORF, RW2 and
  HEIC. A recognised but unsupported file gives `unsupported(format)`.

### 9. Decision: fixtures

- **The owner's real files stay outside the repository.** A local-only real-sample test
  reads them from a directory named by an environment variable, with expected values stored
  beside the samples (also outside the repository). It is skipped, with a clear message, when
  the variable is unset.
- **Committed fixtures are synthetic and deterministic.** They are built in code by a test
  helper, and **no bytes of the owner's files are committed**. They reproduce the structures
  the parser needs:
  - an IFD0-only DNG like the samples, including large rational denominators and no EXIF
    IFD, no offset and no GPS;
  - an EXIF-IFD variant;
  - corrupt, truncated, looping and oversized cases.
- The values are neutral (for example Make `TestMake`, a fixed synthetic timestamp); no
  device build string.

### 10. Decision: visibility and the Stage 3 boundary

- The metadata import UI stays hidden during Stage 2 (`FeatureScope.metadataImport` stays
  false).
- Nothing extracted is written to Equipment, sessions or any store.
- Stage 3 defines `Metadata → EquipmentCandidate → Match/Enrich → User Confirmation →
  Persist`.

### 11. Alternatives considered

- **Keeping `exif`,** reading a prefix of bytes. Rejected: no random access within a budget;
  it decodes beyond the contract.
- **`file_picker` for metadata,** reading the cached copy. Rejected by the owner: the whole
  file is copied before any bounded parsing.
- **Committing header slices of the owner's files.** Rejected by the owner: the repository is
  public.
- **A third-party SAF package.** Not evaluated: an in-app channel of about 100 lines needs no
  new dependency, licence review or maintenance risk.

### 12. Consequences

- About 100 lines of Kotlin enter `android/app`, and they are verified only on a device.
- `exif` and `image_picker` leave `pubspec.yaml`.
- F-45 stays hidden.
- TD-018, TD-064 and TD-065 are closed by Stage 2's Tasks.

### 13. Amendment (owner, 2026-09-26): format priorities and layering

Supersedes §8's list. Its rule stands: support is claimed only with a representative real
sample and tests. See E.1, "Stage 2 format priorities and metadata layering".

1. **Priorities:**
   - DNG (supported);
   - JPEG (high; S2.8 once a real sample exists);
   - HEIC/HEIF (high; research S2.R2 first, and a reader only with a sample and a decision);
   - FITS (on a sample, S2.6);
   - PNG (the `eXIf` chunk only, with a sample; never assumed to identify equipment);
   - proprietary RAW (CR2/CR3, NEF, ARW, RAF, RW2, ORF): **no ad hoc parsers**; RG-14 decides
     between a library, a platform facility or nothing;
   - XISF and others: sample and use-case driven.
2. **Three levels:**
   - **(a) recognition:** the container named from its signature, including recognition-only
     formats that have no reader;
   - **(b) extraction:** the contract's values, or "extracted, nothing found", or
     unreadable, or no reader for this format;
   - **(c) equipment evidence:** Stage 3's assessment over (b). Stage 2 never implies it.
3. **One contract, many containers.** EXIF-bearing containers (DNG/TIFF, JPEG APP1, HEIF
   `Exif` item, PNG `eXIf`) share **one** bounded EXIF-structure extractor, given a base
   offset and a container label. Format readers sit behind one interface. The contract
   (§2) changes only for a new *kind* of fact (for example a generic optics identity for
   FITS `TELESCOP`), never per parser.
4. **Not permitted:** image decoding, thumbnails or pixel access; a universal RAW parsing
   framework.

## ADR-018: Metadata-assisted equipment import (Stage 3)

Status: accepted (owner, 2026-09-26, S3.D). The owner chose the recommended option for each of
D1–D4 in `refinement/research/RG-02_EQUIPMENT_IDENTITY.md` §12 (E.1, "Stage 3 decisions (S3.D)").
It amends ADR-017 §2 (§3 below) and applies ADR-008 §6 per field to equipment (§5). ADR-011 is
unchanged. **Implementation:** §3 done (S3.1, 2026-09-26); §4 done as pure domain code (S3.2, 2026-09-26: `EquipmentCandidate`, CALC-40); §5 done (S3.4, 2026-09-26: schema v18); §6 done (S3.3, 2026-09-26: `EquipmentMatcher`, see the note below); the editor's form model and pre-fill done (S3.5, 2026-09-26); the review and confirmation flow done (S3.6, 2026-09-26; see the note below); the RAW size from a DNG done (S3.8, 2026-09-26: MB = bytes ÷ 10⁶, as ADR-011 §3 defines the unit); §7 done (S3.7, 2026-09-26: visible as "Add from a photo"; device check M4 passed). Every frozen Stage 3 Task is done; TD-068 was found at M4 (`refinement/POST_ROADMAP_PLAN.md`,
"Stage 3 — frozen Task sequence").

**Implementation note (S3.V8, 2026-09-27; S3S-02, TD-071, SI-014; owner option (a)):** this amends the S3.6 choice below ("takes those specs only where the file gives none").
- When the file's pixel dimensions are known and differ from the saved rig's resolution (compared long side to long side, so orientation does not count), "a new rig with the camera specs of" that rig does not copy its pixel size or sensor size. Binning, ROI or cropping, resampling, another sensor mode or another configuration could explain the difference, and metadata cannot tell which, so the relationship is not inferred.
- Those fields stay empty (unknown) and Save waits for the user's pixel size. The sensor size then follows from resolution × pixel size, as for any typed rig. The editor says why ("Pixel size not copied from …", with both pixel counts) while the field is empty.
- The match itself is unchanged. The saved rig stays the evidence for the camera identity, and its resolution is still copied when the file has none. The file's own values, including a CALC-40 estimate, come first as before. The equal-pixel-count copy is unchanged.
- One check serves both places: `EquipmentMatcher.samePixelCount`, used by the mode check too.

**Implementation note (S3.V7, 2026-09-27; S3S-01, TD-070):** a group's provenance is read per spec.
- `EquipmentProfile.groupProvenance` lists a group's valued specs with `provenanceOf`; the RAW size
  takes part only when set. `sharedProvenance` is the provenance all of them have, else null.
- The rig editor states one provenance for a group whose specs share it (a rig typed by hand reads
  as before), else one per spec. An imported rig's estimates read as estimated, and unknown as
  unknown. The group pair alone is never shown.
- A new session snapshot records a group's source and confidence only when every spec of the group
  shares them, else null. That keeps the snapshot format (`"v": 1`) and the export unchanged, and
  a snapshot never records an invented `user`.
- Per-field snapshot provenance, and snapshots already saved (which hold the group pair, `user`
  for a rig imported before this change), are Stage 8's (owner, E.1). No screen reads a
  snapshot's provenance; the export embeds snapshots as stored.

**Implementation note (S3.V4, 2026-09-27; S3V-05):** §3's dimensions have a sanity bound. A side over **65,535 px** is unparseable in every container (DNG IFD0 and DefaultCropSize, JPEG and HEIC EXIF), as S3.1's acceptance required. 65,535 is JPEG's own format limit and several times any camera sensor's long side. It is a metadata bound, deliberately wider than `EquipmentLimits.resolutionPx` (30,000), which the candidate applies later.

**Implementation note (S3.V3, 2026-09-27; S3V-03, S3V-04):**
- A pre-filled value is saved at its exact number while untouched; the editor's text is only its display.
- Choosing the file's value applies the file's value, even when it displays like the saved one.
- A copied saved value keeps its exact number with its provenance.
- Only estimates are rounded, and they are proposed rounded (S3.9's rule, unchanged).

**Implementation note (S3.V2, 2026-09-27; S3V-02):** §5's "else unknown" needs a way to say unknown per field. Otherwise an edit that makes the group `user`, or a new rig whose group is `user`, covers an untouched legacy value through the fallback. An own pair with the source id `unknown` and no confidence (`SpecProvenance.unknown`) records that the field's origin is known to be unknown. It reads as unknown before any fallback, needs no schema change, and follows ADR-008 §6's namespaced ids. It is used when a changed group's untouched field had unknown provenance, and for values copied from a legacy rig.

**Implementation note (S3.3, 2026-09-26):** choices made within §6.
- **The field of view has no stored f₃₅.** A file's f₃₅ is compared with the one a saved rig
  implies: f × 43.27 mm ÷ the rig's sensor diagonal.
  - They differ when they are more than **10 %** apart (`EquipmentMatcher.fieldOfViewTolerance`).
  - 10 % is wider than CALC-40's own uncertainty (about 2 % + 4 %), so only a real change of
    field of view (a 1.2× crop or more) counts as another mode.
  - A user's wrong sensor entry can wrongly flag a mode. The effect is only a question to the
    user; nothing is merged.
- **A saved rig with no model gives no camera match.** RG-02 §6 had suggested "likely" there;
  §6 above does not list it, so it is not applied.
- **Missing makes are not a disagreement.** When both makes are known they must be equal; when
  one is missing, the model decides.
- **A known limit of the prefix rule:** "Pro Max" against "Pro" is "likely", because a space is a
  separator. The user sees both strings and decides; nothing is merged.
- **S3.6 choices:**
  - taking the file's focal ratio for a saved rig clears that rig's diameter field, because a
    diameter would otherwise re-derive the ratio (ADR-011 §4). The switch says so, and D is never
    back-filled;
  - a new rig "with the camera specs" of a saved rig takes those specs only where the file gives
    none, so the file's own values come first.
- **Values within the 1 % tolerance but not equal** (a saved f/5.56 against a file's f/5.6) are
  the same optic, and the difference is listed as a conflict.

### 1. Context (verified at `0c4848b`; RG-02 §1–§5)

- The metadata contract (ADR-017 §2) reads DNG, JPEG and HEIC. It has identity strings, focal
  length, f-number and the 35 mm equivalent. It has no image dimensions and no pixel size.
- `EquipmentProfile` and its columns require sensor size, pixel pitch, resolution, focal length
  and focal ratio (`NOT NULL`). Provenance is kept per group (camera, optics).
- A phone's camera modules share Make, Model and UniqueCameraModel. The Model string differs by
  format. Serials are never read, so two identical bodies are indistinguishable.
- All four owner samples carry pixel dimensions (swapped in a portrait JPEG/HEIC). None carries
  focal-plane resolution.

### 2. Decision: the flow

```text
MetadataRead → EquipmentEvidence → EquipmentCandidate → Match → Review → pre-filled editor → Save
```

- Everything before Save is pure domain and in memory. Nothing is persisted for an unconfirmed
  candidate (no candidate store: option C rejected).
- **The only write is the user's Save** in the rig editor, through `runWithFeedback`. Cancel at
  any step writes nothing. There is no background, automatic or batch write.
- One file at a time. Batch import is out of scope.

### 3. Decision: image geometry in the contract (amends ADR-017 §2)

- `CaptureMetadata` gains **image width and height (px)**, a new kind of fact under ADR-017
  §13.3, with origin and the usual unknown states:
  - **DNG:** only from IFD0 when it is the main image (`NewSubfileType` absent or 0). Use
    `DefaultCropSize` when present and integral, else `ImageWidth`/`ImageLength`. Sub-IFDs stay
    unfollowed (ADR-017 §3's rule), so a DNG whose raw image sits in a sub-IFD gives absent
    dimensions;
  - **JPEG/HEIC:** `PixelXDimension`/`PixelYDimension` (EXIF IFD) and IFD0
    `ImageWidth`/`ImageLength`, combined; disagreement is ambiguous.
- **Orientation is not interpreted.** Equipment uses the long side as the width and the short
  side as the height.
- **Excluded, unchanged:** GPS, serials, observer identity. The byte budget is unchanged.

### 4. Decision: what an import may propose (D1 = A1)

| `EquipmentProfile` field | Proposed from | Source id | Confidence |
| --- | --- | --- | --- |
| `name` | Make + Model (+ lens model or focal length) | — (a label) | — |
| `manufacturer`, `cameraModel` | Make, Model (trimmed raw text) | — (labels) | — |
| `resolutionWidthPx/HeightPx` | Image dimensions (long/short) | `metadata:<format>` | `reported` |
| `focalLengthMm` | FocalLength | `metadata:<format>` | `reported` |
| `focalRatio` | FNumber | `metadata:<format>` | `reported` |
| `sensorWidthMm/HeightMm`, `pixelPitchUm` | **CALC-40 estimate** (below), offered, never silent | `derived:calc-40/metadata:<format>` | `estimated` |
| `averageRawFileSizeMB` | The file length of a **DNG** pick only (D4) | `metadata:dng:file-size` | `estimated` |
| `apertureDiameterMm` | **Never** (ADR-011 §4: D is never back-filled) | — | — |
| `rotationDeg`, `trackingType`, `maxExposureS` | **Never** (ADR-011 §5; a frame's exposure is not a limit) | — | — |

- `<format>` is `dng`, `jpeg` or `heif`. **No imported value is ever `verified`.**
- Exposure, sensitivity and capture time never map to equipment.
- An absent, unparseable or ambiguous value gives an unknown field with its reason. It is never
  a default.
- **CALC-40 (sensor geometry from the 35 mm equivalent):**
  - crop = f₃₅ / f;
  - diagonal = 43.27 mm / crop (the diagonal convention);
  - sides from the long:short pixel ratio;
  - effective pixel pitch = long side (mm) / long side (px) × 1000 µm.
  - It is produced only when f₃₅, f and both dimensions are known, f₃₅ > f, and every result is
    within `EquipmentLimits`.
  - **Stated uncertainty:** f₃₅ is an integer (±0.5 mm); the EXIF standard does not say whether
    the equivalent matches the diagonal or the width (about 4 % apart for 4:3).
  - The pitch is the pitch **of the output mode** (binned or full resolution), which is what the
    planner's pixel scale needs.
  - The formula and assumptions go into `SCIENTIFIC_INTEGRITY.md` with S3.2.
- **A rig is stored only when complete (option A).** Every required spec needs a value from the
  file, an estimate the user accepted, the user's typing, or a matched rig's camera specs.
  Nullable specs (option B) are rejected for Stage 3.

### 5. Decision: provenance per field (ADR-008 §6 applied to equipment)

- **Schema v18, additive:**
  - nullable `source`/`confidence` pairs for resolution, pixel pitch, sensor size and average
    RAW size (on `camera_modules`), and for focal length and focal ratio (on `optical_rigs`);
  - nullable `metadata_make` and `metadata_model` on `camera_modules`: the raw identity strings
    of the file the rig was imported from, kept for later matching. Never serials.
- **A field's provenance** is its own pair, else its group's existing pair, else unknown. Legacy
  and seeded rows read exactly as before. Nothing is back-filled.
- **An edit** marks only the changed fields `user`/`reported`. An untouched pre-filled field
  keeps its import provenance. A value copied from a saved rig keeps that rig's provenance.
- The group columns stay (they are not dropped). The manual editor's behaviour is unchanged.

### 6. Decision: matching and conflicts

- **Outcomes, by rules with stated reasons; never a score:**
  - same rig;
  - likely the same rig;
  - same camera, other optics;
  - cropped or binned mode;
  - ambiguous;
  - none.
- **Comparison:**
  - Make and Model are trimmed, whitespace-collapsed and case-folded;
  - "likely" when one Model is the other plus a separator (`/`, space, `-`, `_`) and a suffix;
  - no maker-specific rules;
  - stored `metadata_make`/`metadata_model` take precedence over the user-editable labels;
  - f and N are equal within **1 %**, a documented tolerance, not a physical law;
  - equal f and N with a different f₃₅ or different dimensions is a cropped or binned mode, never
    "same".
- **Ambiguous:** several qualifying rigs → the user chooses; nothing is chosen automatically.
- **Same rig:** no duplicate is created. The review offers to open it, and to fill its
  **unknown** optional fields (the RAW size) through the editor.
- **Same camera, other optics:** the new rig may take the saved rig's camera specs (copied, with
  their provenance). This is not composition (ADR-011 §2).
- **Conflicts:**
  - saved and imported values are shown side by side with their provenance;
  - keeping the saved value is the default;
  - the imported value replaces it only by the user's explicit choice for that field;
  - a `verified` value is never replaced by default;
  - legacy (NULL-provenance) values are treated like user values;
  - ambiguous or unparseable metadata is never offered as a replacement.

### 7. Decision: visibility (D3, RD-16) and privacy

*(Historical, superseded by S3.7 (`2b045eb`, 2026-09-26): the import is visible in every build as "Add from a photo" on the equipment screen, and the Settings viewer entry is removed. Marked by S3.V5 (S3V-07); the amendment is kept as written.)*

**Owner amendment, 2026-09-26:** enable the existing read-only Settings →
Import metadata viewer in debug builds now, to inspect Stage 2 output during
Stage 3 development. `FeatureScope.metadataImport = kDebugMode` gates both
the entry and route. Profile/release builds remain hidden. This does not
complete S3.7 or enable Equipment persistence; the public workflow below
still arrives in S3.7. A hot restart/relaunch is needed to rebuild the router.

- **Visible at the end of Stage 3** (S3.7), once the review and confirmation flow exists and
  TD-066 is fixed, as **"Add from a photo"** next to "Add" on the equipment screen (the one
  screen used by the planner and the Library). The Settings entry to the read-only viewer is
  removed. Stage 4 may move the entry point.
- **Android only**, as today. Elsewhere the action says the feature is not available.
- **Nothing leaves the device.** No network, no external dataset. The privacy policy and Data
  Safety are re-checked in S3.7 and are expected not to change.

### 8. Decision: no specification source in Stage 3 (D2)

RG-03 is deferred: no bundled or remote equipment database, and no scraping. S3.R2 and the old
S3.9 leave Stage 3. They can return only through RG-03 and an owner decision (Stage 7 lists
RG-03 too).

### 9. Out of scope

- Equipment composition (ADR-011 §2).
- Nullable required specs.
- Batch import.
- FITS, XISF and proprietary RAW (they wait for samples).
- Assisted actuals (Stage 8).
- The Stage 5/7 editor redesign beyond the form model needed for pre-fill.
- A specification source.

### 10. Alternatives considered

| Alternative | Decision | Reason |
| --- | --- | --- |
| A2: no estimate | Rejected (owner) | Phone users rarely know sensor or pixel size; the import would add little |
| B: nullable specs | Rejected for Stage 3 (owner) | Touches every consumer; overlaps Stages 6–7; L–XL |
| C: a candidate store | Rejected (owner) | Persists unconfirmed metadata for little gain |
| Per-group provenance only | Rejected | An imported rig mixes origins in one group; ADR-008 §6 requires per-field pairs |
| Make + Model as an identifier | Rejected | Identical across phone modules and identical bodies; format-dependent |
| Focal length as an identifier | Rejected | Evidence only: zooms, crop modes, user-set lens profiles, telescopes |
| An external spec database now | Deferred (owner, D2) | Needs RG-03's licence, provenance and coverage research |

### 11. Consequences

- **Tasks** (frozen with this ADR):
  - S3.1: the contract amendment;
  - S3.2: the candidate and CALC-40;
  - S3.3: matching;
  - S3.4: schema v18;
  - S3.5: the form model and pre-fill;
  - S3.6: the review flow;
  - S3.7: visibility, TD-066 and the device check M4;
  - S3.8: the RAW size.
- Only the phone class is validated on real files. DSLR/mirrorless behaviour rests on synthetic
  fixtures until the owner supplies a sample. Astro cameras wait for a FITS reader.
- This ADR changes no code.

## ADR-019: Product flow and information architecture (Stage 4)

Status: accepted (owner, 2026-09-27, S4.D). The owner accepted it in chat after S4.R1–S4.R5.

**Amended after acceptance (S4R-04):**
- **§3.1 was added by S4.V1**, a documentation correction for S4V-01
  (`refinement/STAGE_4_VALIDATION.md`, `4241502`). Its own rules were not owner-approved: a
  revalidation failed them (`refinement/STAGE_4_REVALIDATION.md`, `750f0a7`; S4R-01, S4R-02).
- **S4.V2 revised §3.1 and §3 to the owner's decision:** R2 + D1 with the saved-snapshot invariant
  (E.1, "S4R-01 and S4R-02 decided").
- **S4.V3 reduced §3.1 to the approved decisions** (E.1, "Bounded validation for analysis and
  decision Stages"). S4.V2's inferred rules are withdrawn and are now Stage 6/8 design questions.
- The final Stage 4 validation is bounded to the scope in that entry.
- **Superseded in part by the owner, 2026-09-27** (E.1, "Stages 6–11 amended after Stage 5"): §2's
  optional live path and §4's "Track live (optional)". The dedicated tracker leaves the target
  product, and Stage 8 retires it after a dependency audit (P8.4). The live-mode items that follow
  from them go the same way: §5's run card, §6's ⋮ item and §14's "Track live (optional)". §3's
  Tracking state remains for live runs until P8.4, and afterwards only for runs that already exist.
  The text below is kept as accepted; pointers mark §2 and §4.
- **Amended by the owner, 2026-09-28** (E.1, "Stage 6 corrective pass decided"): §6's order below
  the status (the rig above the capture plan; the target's windows and the conditions after it).
  The text below is kept as accepted; a pointer marks §6, and one under §5 records how S6.16 applied
  TD-080.

It records, as one design, the eight Stage 4 decisions the owner took in chat on 2026-09-27 (DECISIONS
E.1):
- RG-04 (S4.R2);
- RD-05 and RD-04 (S4.R3);
- RG-05, RD-06 and RG-06 (S4.R4);
- RD-07 and RD-14 (S4.R5).

It amends ADR-009 §2 (display only), ADR-014 §3, ADR-015 §2, §3's route map and §7, and ADR-016
§2 and §10. Low-fidelity screens are in `docs/IA_WIREFRAMES_ADDENDUM.md`; `docs/IA_WIREFRAMES.md`
stays as accepted.

Documentation only: **this ADR changes no code.** Stages 5, 6, 8 and 9 implement it, through the
provisional Tasks S4.T writes. Until each part is built, the application behaves as before, and
FEATURE_STATUS keeps describing the actual state.

### 1. Context (verified at `92ebf2a`'s code; `refinement/research/S4.R1_FLOW_INVENTORY.md`)

- **The planner.**
  - Its answer (the fit) is on its last screen (05 §3: y = 3,601 of 3,995; screen 11 at 200 %
    text).
  - The night is chosen below the chart and windows it drives.
  - It shows no target, night or state (UX-04, a wireframe deviation; DEV-P9).
  - Only the assumptions panel collapses.
- **Tonight.**
  - Its Night, Moon and Weather rows open the planner at its top (UX-10).
  - It has no night picker (UX-11, DEV-P9).
  - The site sits above the plan (08 §2, O2).
- **Recording a result.**
  - **A result can be recorded only through Start**, and nothing can mark an unstarted plan "not
    done".
  - The next day, yesterday's saved plan becomes the planner's current plan and rolls forward to
    tonight (TASK 11.4).
- **Drafts.** "Draft" is shown to users. Discard and a replaced untouched draft leave invisible
  rows. New keeps the old target and rig.
- **The Library.** Its rig and target lists are the planner's pickers: a tap changes the plan
  (TD-053).
- **Names.** One concept has several names (UX-18): rig or Equipment, Sessions or Logbook, five
  names for the dark period.
- **The owner's direction (08; O1–O4):**
  - plan → save → image → Logbook → record;
  - no reporting while imaging;
  - Draft may stay internal;
  - planning must lead the hierarchy.

### 2. Decision: the product flow

```
Site · Rig · Target ──► PLAN (planner) ──► Save ──► [the night: no app interaction needed] ──►
Logbook entry ──► Record result (Completed as planned · Partly · Not done) ──► Progress by target

Optional, off the primary path:  saved plan ──► Track live ──► tracker ──► Finish ──► the same result form
```

- **Planning is the primary job:** Tonight and the planner lead with the plan and its verdict.
- **Execution is optional** (RG-04). Nothing in the default flow asks the user to operate the app
  while imaging.

> **Superseded in part (owner, 2026-09-27; E.1, "Stages 6–11 amended after Stage 5"):** the
> optional path above leaves the target product. The primary flow is the only one; Stage 8 retires
> the tracker after a dependency audit (P8.4).

### 3. Decision: a plan's lifecycle and defaults (RD-05, RD-04; amends ADR-014 §3)

**User-facing states** (the stored statuses are unchanged):

| Stored (ADR-014) | Shown |
| --- | --- |
| `draft`, never saved | **Not saved** |
| `planned` | **Saved** |
| `draft` with `plannedAtUtc` (edited since saved) | **Saved · changed** |
| `inProgress` | **Tracking** (the optional live mode) |
| `completed`, as planned | **Completed** |
| `completed`, partial (the result form's "Partly") | **Partly** |
| `abandoned` | **Not done** |
| legacy rows | **Old log** |

**Amendments to ADR-014 §3's lifecycle table:**

| From → to | Allowed | Effect |
| --- | --- | --- |
| planned, or Saved · changed (`draft` with `plannedAtUtc`) → completed | **Record result:** Completed as planned, or Partly; never for a planned night that has not ended (§3.1) | No run and no Save plan. The plan snapshot is the record's plan (no execution-start snapshot) and is never changed. Counts are written as events against the snapshot's blocks (§4) |
| planned, or Saved · changed → abandoned | **Record result:** Not done, with an optional reason; never for a planned night that has not ended | Directly against the saved plan, without Save plan (§3.1). ADR-014 already allowed draft/planned → abandoned; live-run Abandon is unchanged |
| inProgress → completed | The tracker's Finish → the same result form | As before, but through the one form |

**Amendment to ADR-014 §3's "Current session" rule (S4.V1, revised by S4.V2; delivered by
Stage 8).** Saved (`planned`) and Saved · changed (`draft` with `plannedAtUtc`) are saved plans.
From Stage 8, once the saved night has passed (E2), automatic resume and rollover keep the entry
on its night, and the planner continues on a copy for tonight, the **independent working copy**. Only a never-saved draft
rolls forward in place. Until Stage 8, saved plans behave as today (D1). The complete rule is §3.1
below.

**Save** stays explicit and means "I plan to image this". Only saved plans are listed (TASK 11.3's
rule stands).

**New, Copy, Open:**
- **New plan** keeps the site and rig and asks for the target.
- **Copy to another night** is today's Duplicate: the same plan on a picked night, not saved.
- **Open** as before.
- Each confirms what happened, and the planner's app bar shows the target, the night and the state.

**Replacing unsaved changes.**
- The prompt asks **Save · Discard · Cancel**.
- Discard deletes the discarded draft, and a replaced untouched draft is deleted. Discard never
  changes or removes a saved plan's snapshot (§3.1's invariant). What it does with a Saved ·
  changed plan's unsaved changes is a Stage 6 design question (S4.V3).
- A site change on a saved plan, and a new copy, count as unsaved (W1, V3).
- This supersedes the S1.6 interim when built.

> **Decided 2026-09-28 (the owner; E.1, "S4-DEF-04 decided"):** on a Saved · changed plan, Discard
> reverts the entry to its saved snapshot (R): it becomes Saved again, the snapshot unchanged and
> nothing deleted; an unreadable snapshot or a reference that no longer exists changes nothing, and
> the user is told. This adds the transition Saved · changed → Saved to ADR-014 §3.

**Defaults (RD-04).**
- Nothing is preselected on the first run: no target, no rig. The seeded rig stays in the list,
  labelled as an example.
- The capture plan starts empty, with **"Start from the example plan"**.
- This supersedes TASK 11.4's "New = tonight + the example plan". TASK 4.4's rule that the example
  must not look like the user's own stands.

### 3.1 Saved plans and their night (E2, R2, D1)

> **Provenance:**
> - S4.V1 added this section.
> - S4.V2 revised it to the owner's R2 + D1 (E.1, "S4R-01 and S4R-02 decided").
> - S4.V3 reduced it to what those decisions state (E.1, "Bounded validation for analysis and
>   decision Stages"). Rules that S4.V1 and S4.V2 inferred beyond them are withdrawn. The open cases
>   are Stage 6/8 design questions (`refinement/POST_ROADMAP_PLAN.md`, S4.V3, "Deferred /
>   implementation decisions").

**The invariant (owner, R2):**
- the **plan snapshot** is the immutable intent for the night it was saved for;
- the **result** is the reported actual outcome for that same snapshot;
- the **current working copy** is independent future planning state.

Once a plan has been saved for a night, later edits in the planner do not change the night, site,
target, capture blocks or other saved context against which that night's result will be recorded.
They are working-copy state. For example: a plan is saved for Friday, then the working planner moves
to Saturday and some fields change. Friday's saved plan stays with Friday and awaits Friday's
result. The Saturday changes belong to the working copy and are never substituted into Friday's
result.

**Saved plans** (the states of §3, L1): **Saved** (`planned`) and **Saved · changed** (`draft`
with `plannedAtUtc`). A never-saved draft is `draft` without `plannedAtUtc`.

**The next day (E2; delivered by D1):**
- A saved plan whose night has passed is not resumed as the planner's current plan. It stays on its
  night, awaiting its result (in the Logbook, and on Tonight's line, §4).
- The planner continues on a copy for tonight: the same target, rig and blocks, not saved. Later
  edits belong to that working copy, never to the saved plan.
- A never-saved draft whose night has passed keeps TASK 11.4's roll-forward.
- **Delivery (D1):**
  - Stage 6 may fix the lifecycle and UX of never-saved drafts and working plans, but it does not
    partly change saved-plan rollover;
  - Stage 8 delivers both sides of the transition together: the saved plan stays on its night, and
    a working copy is available for the current planning night;
  - until then, saved plans keep today's behaviour. There is no intermediate state in which a saved
    plan stops rolling forward while no working copy exists.

**Recording a result (R2):** saved plan → **Review saved plan** → report outcome → **Save
result**.
- **The review** is based on the saved snapshot for that completed night, never the planner's
  current state.
- **Save plan is not required** to report a result.
- **Not done** is recorded directly against the saved plan, without saving the working copy.
- **Completed as planned and Partly:** the reported actuals belong to the result or log record.
  They never change the saved snapshot. Counts are written as events, so the counters equal the
  replay (§4).
- **No result is recorded for a planned night that has not ended.**
- **The working copy is left alone:** opening an old saved plan to report its result never asks
  Save · Discard · Cancel about an unrelated current working copy, which is kept independently.
- **The optional live tracker stays supported** as decided in §4.

**Left to Stage 6/8 design** (not decided here; see the plan's deferred list):
- save and version semantics after a plan is saved;
- when a saved night counts as passed for the next-day transition, and when a result may be
  reported. SessionNight defines planning semantics and does not by itself decide the second;
- the working copy's details and recovery;
- Discard on Saved · changed;
- result storage against the snapshot, and upgrading existing rows;
- missing snapshots;
- what else an opened entry offers;
- stale or cancelled result forms.

Existing rules apply meanwhile:
- unknown stays unknown (SI-008);
- the migration workflow;
- the serialized autosave chain (S1.12).

### 4. Decision: execution optional; results after the session (RG-04; amends ADR-016 §2, §10)

> **Superseded in part (owner, 2026-09-27; E.1, "Stages 6–11 amended after Stage 5"):** "Track live
> (optional)", the tracker and the workflow built only for it leave the target product. Stage 8
> (P8.4) retires their UI after a dependency audit, keeping the events, counts and history. The
> result form, its count events and the honesty rules below stand. Until P8.4, the tracker stays as
> built.

- **Start leaves the primary path** (Tonight's card and the planner's bottom bar). A saved plan
  offers **Track live (optional)**. The tracker, its events, the estimate (CALC-35), the countdowns
  (CALC-36), keep-screen-on, one run at a time and the resume prompt all stay as ADR-016 defines
  them, for users who choose the live mode.
- **When the live mode starts the planner's current plan,** the planner still continues on a copy
  (ADR-016 §10). No card offers a Start that must fail while a run is in progress (UX-13).
- **The result form** (RG-04 G2):
  - **Completed as planned** is one tap. The actual counts equal the saved snapshot's plan (§3.1),
    and they are labelled as reported by the user;
  - **Partly** takes numbers per light block of the saved snapshot, pre-filled from it and
    editable, entered as numbers rather than ±1;
  - **Not done** takes an optional reason (clouds, wind, dew, equipment, other);
  - optional notes; temperature, humidity and cloud stay optional;
  - rejected counts are not asked in the default form, and existing ones stay readable.
- **Counts through events.**
  - A result writes its counts as events, so the counters still equal the replayed events (trap 14;
    ADR-016 §4's invariant).
  - The event kind, and where "Not done"'s reason is stored, are Stage 8's implementation decisions
    within this rule.
  - ADR-016 §11's corrections after completion are unchanged.
- **Honesty.**
  - "Reported as planned" is a user statement, like every confirmed count today (CALC-37 is "not
    verified against files").
  - CALC-37 and CALC-38 gain that note; RD-13 (the estimate's provenance) is decided alongside, in
    Stage 8.
- **After the night:** a quiet line on Tonight ("Last night: M42. How did it go?") opens the result
  form. There are no notifications (ADR-016 §6).
- **RD-12** (the resume prompt's Finish) is expected to lead to the same result form. It is decided
  in Stage 8.

### 5. Decision: Tonight (RG-05)

The order, top to bottom:
1. **The context line**, site ▾ · night ▾: the site switcher and the night picker. It is the same
   control as the planner's, and the night picker changes the current plan's night (UX-11).
2. The live-run card, only during a live run.
3. "Last night: … How did it go?", only when due.
4. **Your plan:** the target and state; the verdict with its reason and usable time; **Open
   planner**. Without a target: **Choose a target** / **What can I image tonight?**
5. The Night, Moon and Weather rows, leading to the **Night & Moon** and **Weather** detail screens
   (§9).
6. Secondary actions: **What can I image tonight?** and **New plan**.

Tonight stays a fixed view (PD-14), with four tabs (ADR-015 §2). The detail screens meet 08 §2's
"Analytics" idea without a fifth tab.

> **As built by S6.16 (TD-080, 2026-09-28; within the owner's instruction in E.1, "Stage 6
> corrective pass decided", not a new decision):** without a target, Your plan offers Choose a
> target and What can I image tonight?, each with one short line saying what it offers, and the
> secondary actions do not repeat What can I image tonight?; with a target, it is in the secondary
> actions. Both functions stay. The order of items 1–6 is unchanged.

### 6. Decision: the planner (RD-06; amends ADR-015 §2's "same sections and order")

1. **App bar:** target · night · state; ⋮ holds New plan, Copy to another night, and Track live
   (optional, for a saved plan).
2. **Status:** the verdict and its reason, time needed against usable time, when capture ends, the
   total integration, fill or trim.
3. **Context:** site ▾ · night ▾, the same control as Tonight's.
4. **Target and tonight's windows:** the target (tap to change), the altitude chart, the windows.
5. **Capture plan:** blocks; time needed, total time; Budget details ▸; √N per group with its help
   ⓘ; storage; Assumptions ▸.
6. **Conditions summary:** Night & Moon ›, Weather ›, Sky ›, leading to the detail screens.
7. **Rig summary:** name, FOV, pixel scale, frame fill ›, leading to the full rows.
8. **Bottom bar:** **Save plan**, the primary action, in the lower half.

> **Amended (the owner, 2026-09-28; E.1, "Stage 6 corrective pass decided"):** below the status
> (item 2), the conceptual order is: the context (site ▾ · night ▾); the target; the rig (its
> summary, as item 7 describes); the capture plan (item 5); then the night and target-opportunity
> analysis (the chart and the windows, out of item 4); then the supporting conditions (item 6);
> deeper technical detail on demand throughout (§7). A conceptual order, not a card per item and no
> duplicated information. Items 1–3 and 8 stand, and the status never moves below the form
> content. Built by S6.16.

### 7. Decision: disclosure (RD-06, RG-06; amends ADR-009 §2's display wording)

| Always visible | One tap away, in a collapsed section whose summary states facts, with its state remembered |
| --- | --- |
| The verdict and reason; usable time; time needed; when capture ends; integration; fill or trim | The budget breakdown (acquisition, calibration inside and outside the window, setup), **each on its own line within Budget details**. This is ADR-009 §2's "each shown on its own line", now one tap away |
| The plan's target, night, site and state | The √N help text (the √N values stay visible and relative, SI-003) |
| The weather summary with its **age** and "stale" label; the attribution | Every weather variable, the hour strip, the model |
| Unknowns, as unknown (SI-008) | The assumptions panel; the rig's reference rows; sky-darkness detail and the map link |

- Zone captions appear once per section; the rule that every time names its zone stands.
- **No Basic/Advanced modes and no density preference** (RG-06). Both are possible later, only on
  new evidence.

### 8. Decision: the Library (RD-07; amends ADR-015 §7)

- **The Library manages:** rigs, targets and sites are opened, edited, added and deleted there. **A
  tap never changes the plan** (TD-053).
- **Choosing for the plan** happens only in the planner, Tonight's context line and the first run.
  The `/select/…` pickers are a picker mode of the same lists.
- A target offers **Plan this target**: a new plan with it, under §3's guard.
- **Add from a photo** stays on the rig list, in both modes.
- **Progress moves to the Logbook** as "Progress by target". It is also shown on an entry and on a
  target's page.

### 9. Decision: routes (amends ADR-015 §3's route map)

- **Added, above the tabs:** a Night & Moon detail and a Weather detail. Their paths are chosen in
  Stage 6 as `AppRouter` constants (trap 10).
- **Moved:** Progress from `/library/progress` to the Logbook branch (Stage 8).
- **Reused:** `/session/:id/results` becomes the result form (Stage 8).
- **Unchanged:** the four tabs, the pickers `/select/…`, `/equipment/import`. Paths are internal;
  only the tab's **label** becomes "Logbook" (§10).

### 10. Decision: vocabulary (RD-14)

- **The glossary** in `refinement/research/S4.R5_LIBRARY_AND_VOCABULARY.md` §5 is normative. The key
  terms:
  - **Rig**; **Plan** ("New plan", "Save plan", "Your plan", "Copy to another night");
  - **Logbook** (the tab);
  - the states in §3;
  - **Record result**; **Track live**;
  - **Dark**, with its limit (the standard twilight names only on the Night & Moon detail);
  - **Integration · Imaging time · Time needed · Total time**;
  - the verdict headline ("Fits: 2 h 05 min needed of 4 h 20 min usable");
  - **Export as file**; **Name (optional)**.
- **Retired from the UI:** "Equipment profile", "Session planner", "Draft", "Legacy", "True Night
  Window", "Astro Dusk/Dawn", "Window load", "Acquisition", "Session budget".
- The words live in one shared place (Stage 5), with a test that keeps retired terms out of
  `lib/presentation`.

### 11. Unchanged

- PD-14.
- ADR-012: no weather score or good/bad colouring; age and attribution shown.
- ADR-013: no score; reasons.
- SI-003 and SI-008.
- **Every calculation.**
- ADR-014's aggregate and immutable snapshots.
- ADR-016's event model and one-run rule, for live runs.
- Foreground only; no notifications.
- Offline-first.
- **No data is deleted by these decisions,** except a draft the user explicitly discards and an
  untouched replaced draft. Existing runs, events, results and exports stay readable.

### 12. Implementation deviations until built

- **DEV-P9** (Part B) records UX-04 and UX-11 against ADR-015's wireframes. It is resolved when
  Stage 6 builds §5 and §6.
- Every other section of this ADR is design intent until its Stage builds it. FEATURE_STATUS and
  ARCHITECTURE Part B keep describing the code.

### 13. Alternatives considered

| Question | Rejected | Reason (the research documents give the detail) |
| --- | --- | --- |
| Execution's role | A (as built), C (Logbook only, hidden or removed), D (a simplified tracker) | A keeps the burden the owner rejected. C removes working capability while its value (U1) is unknown. D needs a new tracker and still asks for taps |
| Post-session detail | G1 (outcome only), G3 (full results) | G1 leaves planned vs actual and Progress without data (unknown stays unknown). G3 keeps per-frame effort |
| The draft model | L2 (autosave = save), L0 (as today) | L2 fills the Logbook with plans never meant, and "how did it go?" would fire for them. L0 keeps the jargon |
| The next day | Y1 (roll forward), Y3 (a fresh plan) | Y1 detaches a plan from the night awaiting its result. Y3 loses multi-night continuity |
| Unsaved plans | U2 (list them) | It mixes intended sessions with plans only tried; it needs a cleanup rule |
| Tonight | T2 (tidied current order) | Planning stays below the conditions (O2) |
| Drill-downs | D-a (deep-link), D-c (a fifth tab) | D-a lands in a long page. D-c splits the conditions from the plan and changes the four tabs |
| The planner | P-0 (a status card only), P-2 (internal tabs) | P-0 leaves UX-02. P-2 hides half the planner |
| Disclosure | Only help texts collapse; Basic/Advanced modes | The first leaves the budget's length. Modes double the design and the tests, without evidence |
| The Library | LB2 (defaults), LB3 (as today with feedback); Progress kept in the Library | LB2 adds a "default" concept RD-04 made unnecessary. LB3 keeps the duplication. Progress is history |
| Names | "Equipment"; "Session" / "Sessions" | "Equipment" is uncountable and rarer in the UI. "Session" and "Sessions" do not follow the owner's plan → Logbook wording |

### 14. Consequences

- **S4.T** writes provisional Tasks, frozen by each Stage's own planning:
  - **Stage 5:**
    - the collapsible section with a factual summary;
    - the context line;
    - the status block;
    - the state label;
    - the detail-screen template;
    - the confirmation and feedback patterns (with RD-09);
    - the shared vocabulary and its test.
  - **Stage 6:**
    - Tonight (§5) and the planner (§6, §7);
    - the Night & Moon and Weather details (§9);
    - the lifecycle UI (§3: the app-bar state, New, Copy, the guard, the defaults, "Start from the
      example plan");
    - TD-057 and TD-058;
    - a five-second test of both first screens as acceptance evidence (S4.E was not run).
  - **Stage 8:**
    - the result form and its events (§4);
    - §3's lifecycle amendments and the resume rule;
    - Track live (optional); RD-12 and RD-13;
    - the Logbook: its label, Progress by target, the name field, "Export as file";
    - TD-063.
  - **Stage 9:** the Library's manage mode and "Plan this target" (§8).
- **Tests:**
  - the accessibility sweep gains each new screen (trap 17);
  - the core-loop E2E test moves to Save → result and follows renamed labels (trap 19);
  - the live mode is tested on its own path.
- **Export:** a result recorded without a run adds no new required field. Any incompatible change
  bumps `manifest_version` (`EXPORT_MANIFEST.md`), decided in Stage 8.

## ADR-020: Capture parameters and calibration workflows (Stage 7)

Status: accepted (owner, 2026-09-29, S7.D). It records the owner's RG-11 and RG-10 decisions (DECISIONS
E.1, "RG-11 decided" and "RG-10 decided"), each the recommended option of its research
(`refinement/research/RG-11_CAPTURE_PARAMETERS.md`, `refinement/research/RG-10_CALIBRATION_WORKFLOWS.md`).
It **amends ADR-009** (§2 and §4: in-camera noise reduction, §8 below) and **ADR-011** (§3: two camera
fields, §2 and §8 below). **Implementation:** Stage 7, S7.2a, S7.2b, S7.3a and S7.3b
(`refinement/POST_ROADMAP_PLAN.md`, "Stage 7 — frozen Task sequence"). This ADR changes no code.

### 1. Context (verified at `bae017e`)

- `CaptureBlock` has a frame type (light, dark, flat, bias), filter, exposure, count, binning (1–4),
  `CaptureGain` (ISO, gain or not recorded; a record, SI-004) and, for calibration frames, a policy
  (ADR-009 §3). Every block asks every field; nothing is inherited.
- The rig (`EquipmentProfile`) has no camera class. Nothing tells the form which parameters apply.
- ADR-009's per-frame overhead is the only "interval"; binning, white balance and focus feed no
  calculation, and in-camera long-exposure noise reduction is not modelled.

### 2. Decision: a camera class on the rig (RG-11, C1)

- **The classes:** Phone · DSLR/mirrorless · Astro camera (colour) · Astro camera (mono) · Unknown.
- A camera-module field, **Unknown by default**. Existing rigs read as Unknown; the migration adds the
  column only. **The example rig stays Unknown** (the owner's choice).
- Chosen by the user in the rig editor. **Never inferred** from a name, a Make or Model string, or a
  file's format; the import ("Add from a photo") proposes none and leaves it Unknown.
- The snapshot's rig records the class (an additive key).
- It decides what the capture-block editor shows (§3, §6). It feeds no calculation.

### 3. Decision: a light block's fields by class (RG-11)

| Field | Phone | DSLR/mirrorless | Astro camera (colour, mono) | Unknown |
| --- | --- | --- | --- | --- |
| Exposure, frames | required | required | required | required |
| ISO | optional | optional | not shown | the neutral choice: Not recorded · ISO · Camera gain |
| Gain | not shown | not shown | optional | (as above) |
| Binning (B1) | not shown (the rig's mode) | not shown | optional, 1 × 1 default | optional, 1 × 1 default |
| Filter | optional | optional | optional | optional |

- **ISO and gain** are never both on one block, never required, never converted (SI-004). Their
  record is what calibration matches (§6).
- **Binning is a record** (B1): no calculation reads it; ADR-009 L6 and the rig-pitch capability stay.
- **Not modelled:** white balance (W1), focus (F1; ADR-009's refocus overhead stays the only focus
  concept), offset (O0), sensor temperature (T0).
- **A value a class does not show is kept,** unchanged, in the store, the snapshot and the export,
  and never used to change a result.

### 4. Decision: the time between frames (RG-11, I1)

- ADR-009's per-frame overhead stays the one interval concept, **relabelled "Time between frames"**.
- **Definition** (for its help): the time from the end of one frame to the start of the next —
  download or processing plus any delay the capture device waits. A camera's interval timer counted
  start to start gives *interval − exposure*. Settling after a dither belongs to the dither overhead,
  never both (RG-11 §6's examples).
- No budget change: ADR-009 §4 is unchanged except for the label.

### 5. Decision: proposals (RG-11, P2)

- A new **light** block proposes the previous light block's exposure, sensitivity (kind and value) and
  binning. It is a proposal: shown as such, and stored only by the user's Save.
- Not adopted: the rig's maximum sub as a proposal (P1); values from a sample photo (P3).

### 6. Decision: calibration blocks (RG-10)

- **The matrix** is RG-10 §4 (darks, flats, bias, dark flats per class), frozen as written there with
  the options below: **inherited · prefilled and overridable · independent · not applicable**.
- **Inheritance (L1):** an inherited value is copied when the block is created, from the light group
  the user picks (the first light block's by default), shown with its origin, and stored in the block.
  It does not follow later light edits. "Use other values" makes the field independent for that block.
- **Match checks** (pure domain; warnings in words; **they never block a plan**):
  - a dark whose exposure, sensitivity and binning match no light block;
  - a flat whose filter no light block uses; a light filter without flats **when the plan has flats**;
    a flat whose binning matches no light block;
  - a bias whose sensitivity and binning match no light block;
  - a dark flat whose exposure, sensitivity and binning match no flat block;
  - in-camera noise reduction on (§8) together with a dark block that matches a light group (darks
    twice).
  - Unknown on either side never fails a check (a sensitivity "not recorded"; binning where the class
    does not show it). Exposures compare in ADR-009's integer milliseconds.
  - Each warning offers a one-tap "Match the lights" (or "Match the flats") that copies the values;
    the user may keep the mismatch.
- **Frame types (D1):** a fifth type, **dark flat**, optional for every class. Stored as text like the
  others (every reader, parser, export and filter accepts it); its policy is ADR-009 §3's, default
  outside the window.
- **Bias** stays optional for every class, never removed; for astro cameras its help names dark flats
  as the documented alternative.
- **The budget:** inherited and prefilled values are stored in the block, so `CaptureBudgetCalculator`
  reads them unchanged; every calibration block stays on its policy's line. Calibration never becomes
  integration.

### 7. Decision: tips (RG-10, H1)

- One line per calibration frame type in the block editor (RG-10 §6's candidates), more one tap away,
  and "Hide tips" remembered on the device.
- Hiding tips never hides a match warning, a validation or a budget line.

### 8. Decision: in-camera long-exposure noise reduction (RG-10, N1; amends ADR-009 §2 and §4)

- **A camera-module switch,** "In-camera noise reduction", shown for the DSLR/mirrorless and Unknown
  classes, **off by default**. It applies only while the class is one of those; for other classes a
  stored value is kept and ignored. The snapshot's rig records it (an additive key).
- **Budget (amends ADR-009 §2):** when it applies, **in-window calibration** gains Σ over light blocks
  of count × exposure (one in-camera dark per light, of the light's exposure). Integration,
  acquisition and √N are unchanged. The window load includes it.
- **Fit (amends ADR-009 §4 and §6):** each light frame's atomic event lasts exposure + in-camera dark
  + per-frame overhead; the dark is never split from its light.
- **Assumption (documented):** the processing takes the exposure's length (Canon: "may take the same
  amount of time as the exposure"); no extra per-frame overhead for it. It is the user's statement of
  a camera setting, never inferred.
- **When off,** the assumptions panel lists it as "not included" for those classes, as ADR-009 §4
  lists its other optional overheads.
- **New vectors** (computed by hand for this ADR; S7.3b's tests reproduce them and are derived
  independently of the implementation, SCIENTIFIC_INTEGRITY Part C rule 3). Window W5 is 22:00–00:00
  (7,200 s), margin 15 % (limit 6,120 s):

| # | Plan and parameters | Integration | Acquisition | In-window cal | Window load | Fit | End | Lost tail |
| --- | --- | --- | --- | --- | --- | --- | --- | --- |
| E8 | 30 × 60 s lights; per-frame 5 s; noise reduction on | 1,800 s | 1,950 s | 1,800 s | 3,750 s | fits | 23:02:30 | — |
| E8b | 60 × 60 s lights; per-frame 5 s; noise reduction on; events of 125 s | 3,600 s | 3,900 s | 3,600 s | 7,500 s | doesn't fit: 3 light frames unplaced (57 placed) | — | 75 s |
| E8c | E8b with noise reduction off | 3,600 s | 3,900 s | 0 | 3,900 s | fits | 23:05:00 | — |

- ADR-009's E1–E7 are unchanged (noise reduction off, or not applicable).

### 9. Out of scope

- Flat-exposure or target-level guidance; exposure optimisation; any "optimal" setting.
- A calibration library manager; scheduling calibration into twilight (ADR-009 L5).
- Binning in any calculation (B1+ rejected); offset, temperature, white balance and focus fields.
- Camera control of any kind.

### 10. Alternatives considered

| Alternative | Decision | Reason |
| --- | --- | --- |
| C2 (no class; the plan's first sensitivity choice) | Rejected (owner) | Cannot hide binning for phones and cameras; the class belongs to the camera |
| C3 (class from metadata) | Rejected (owner) | No certain signal in any readable format |
| B1+ (binning in pixel scale, NPF and storage) | Rejected (owner) | A formula-input change and a per-block capability, with no shown need |
| W2, F2, F3 | Rejected (owner) | No planning consequence; a focus position does not transfer |
| I2–I4 (the interval per rig, plan or block) | Rejected (owner) | Already modelled once; the problem was the label |
| L2 (a live link to the lights) | Rejected (owner) | A reference that deletion, reorder, Undo and Copy must keep valid (S6.V1) |
| L3 (proposals only) | Rejected (owner) | Does not answer 08 §16 |
| D0, T1, O1 | Rejected (owner) | See RG-10 §6 |
| N0, N2 (noise reduction not modelled; a global preference) | Rejected (owner) | N0 keeps a known optimistic fit; N2 charges it to every rig |
| H2 (tips hidden until asked) | Rejected (owner) | The tip belongs where the choice is made |

### 11. Consequences

- **Tasks** (the plan's S7.D split rule):
  - **S7.2a** — the camera class on the rig (schema, editor, import, snapshot);
  - **S7.2b** — the light-block form (§3, §4's label and help, §5);
  - **S7.3a** — calibration blocks (§6, §7; the dark-flat frame type);
  - **S7.3b** — in-camera noise reduction in the budget and the fit (§8; schema; E8–E8c).
- ADR-009 and ADR-011 carry pointers to this ADR. `SCIENTIFIC_INTEGRITY.md` records §8 as a CALC-25
  and CALC-26 input change when S7.3b lands.
