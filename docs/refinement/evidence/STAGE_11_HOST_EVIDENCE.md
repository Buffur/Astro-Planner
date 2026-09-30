# Stage 11 — host evidence (S11.2)

> TEST VERIFIED / CODE VERIFIED / DOCUMENTED evidence for the HOST rows of `STAGE_11_MATRIX.md`
> whose Task is S11.2. Recorded 2026-09-30. Evidence only: no application or test code was changed;
> the temporary probes below were run and deleted, never committed. S11.7 judges these rows (V4).

## Header

- **Date:** 2026-09-30. **Checkout:** `9698fd9` (S11.5, documentation only). **Application code,
  tests, dependencies and tooling:** as at `9668a13` (S11.C1).
- **Reused, not rerun (V3):** the full quality gate PASS at `9668a13` (S11.C1; Flutter 3.47.4):
  Encoding; Format; Analyze (no issues); 1,840 tests, 2 expected skips; host E2E
  `core_loop_test.dart` (2) and `perf_scenarios_test.dart` (1) (`PROGRESS.md`, "Reusable validation
  evidence"). `git diff --stat 9668a13 HEAD -- . ':!docs' ':!CLAUDE.md' ':!README.md'` is empty, so
  every committed test named below passed on the current inputs. The matrix's "gate S10.6" citations
  are superseded by this gate (it contains every S10.6 test plus S11.C1's and `1af00be`'s changes).
- **Reused Stage validations (V3, V6):** each "S*n* val." citation was checked against the report
  (`STAGE_6_VALIDATION.md` E1–E16 and its V5 revalidation; `STAGE_7_VALIDATION.md` rows and its V5
  revalidation; `STAGE_8_VALIDATION.md` T1–T9 and probes P1–P4; `STAGE_9_VALIDATION.md` C, T1–T9 and
  probes P1–P5; `STAGE_10_VALIDATION.md` T3–T5; `STAGE_3_FINAL_SIGNOFF.md`), and every test file those
  reports name still exists. Code changed after those validations was either covered by committed tests
  in the reused gate (`0f09608`: TD-089's probes committed, TD-090, TD-091; `84c9d4c` S10.3; `1117e41`
  S10.5; `9668a13` S11.C1) or is outside the rows. TD-087's and TD-089's probe-only checks are now
  committed tests (`live_runs_survive_test.dart`, the v23 → v24 statuses; `settings_rebuilt_test.dart`,
  `detail_screens_test.dart`, `twilight_bands_test.dart`, `library_manage_mode_test.dart`).
- **Scope.** The 70 rows with Env HOST and Task S11.2 (A1–A7, B1–B5, B7–B9, C1–C8, D1–D7, E1–E4,
  F1–F12, G1–G5, G8, G9, H1–H5, I1, J1–J4, K1, K2, L0, M2, N1, P1, P3). Not judged here: HOST rows of
  other Tasks (N3, done by S11.3; O6–O8, S11.4; P4, S11.3/S11.6; Q1, Q4, S11.7) and the HOST (web) rows
  N10, O5, Q2 (S11.4).

### Fresh evidence (this Task; Flutter 3.47.4; temporary test files, run, then deleted)

| Probe | What it establishes | Result |
| --- | --- | --- |
| P1 | F12, restart: a file database; a plan saved and named "Orion trip", two more saved for the same night; the process killed; after the night's dawn a new graph on the file: the name is there; Not done (clouds), Partly (7 frames) and Completed as planned recorded; killed again; a third graph: the name, status `abandoned` with reason `clouds`, `partly` with 7 counted from the events, `asPlanned`; the Logbook's search for "orion" finds exactly the named entry | **PASS** |
| P2 | F12, migration path: a v24 file with a Not done row (reason `clouds`) and an `asPlanned` row with a `reported` and a `framesConfirmed` event, opened by `AppDatabase` (v24 → v25): result kind, reason, the null name, both events and the replayed count (10) kept; the repository reads the reason back | **PASS** |
| P3 | J4, tiles: the map picker with every tile request answered 400 (flutter_test's HTTP), real time for the requests to fail, then coordinates typed through "Enter coordinates" → Use: no exception, the map and tile layer stay, the marker moves to the typed position. flutter_map's built-in tile cache calls `path_provider`, which has no host implementation; the probe mocked that channel with a temporary folder (a device has it) | **PASS** |
| P4 | H1/H3, the sweep's audit (`accessibility_test.dart`'s harness and `_audit`: overflow, 48 px targets, labels, AA contrast in light and dark) on what the committed sweep never opens: the rig editor (and its "More (optional)"), the target editor, the block editor as Light, Flat, Dark (and "Use other values"), and the Logbook's filter panel; light, dark, field × 100 % and 200 %, 412 px | **FAIL** for the rig editor (contrast, light and dark: S11H-01) and the target editor (overflow under the test font: S11H-04); the block editor and the filter panel pass in all six |
| P5 | The target editor with Roboto loaded (as `equipment_editor_fit_test.dart` does), 360 and 412 px × 100 %, 130 %, 200 % | **PASS**: no overflow; P4's overflow is the test font's full-em glyphs |
| P6 | The rig editor's contrast with Roboto loaded, light and dark | **FAIL**, confirming P4: the sensor size value 2.66:1 (light), 3.59:1 (dark) |

## Results

Legend: **val.** = the Stage validation report named; **gate** = the reused full gate at `9668a13`.

| Row | Result | Evidence | Level |
| --- | --- | --- | --- |
| A1 | PASS | S6 val. E6 (S6.6, S6.16): `planner_structure_test.dart` (the first viewport at 412 × 915 in three themes, the order, the fit and budget wording); gate | TEST VERIFIED |
| A2 | PASS | S6 val. E6, E8 and the V5 revalidation (S6.8, S6.16/TD-075): `planner_structure_test.dart` (missing inputs, integration visible), `planner_defaults_test.dart`; `PlanStatus.missingInput`; gate | TEST VERIFIED |
| A3 | PASS | S6 val. E7: `planner_disclosure_test.dart` (budget lines E3/E4, assumptions, rig specifications, sky detail, excluded-period reasons), `detail_screens_test.dart` (twilight names); gate | TEST VERIFIED |
| A4 | PASS | S6 val. E7: `planner_disclosure_test.dart` (factual collapsed summaries; unknown, stale/unavailable, capability and constraint states visible); gate | TEST VERIFIED |
| A5 | PASS | S6 val. E13; S9 val. C: `tonight_home_screen_test.dart`, `detail_screens_test.dart` ("Tonight's Night, Moon and Weather rows open the details"); no "Draft" or "Analytics" in `lib/presentation`; gate | TEST VERIFIED |
| A6 | PASS | S6 val. E2, E3: `plan_identity_actions_test.dart`, `unsaved_plan_prompt_test.dart`, `drift_session_discard_test.dart` (revert of Saved · changed, only a never-saved draft deleted); gate | TEST VERIFIED |
| A7 | PASS | S6 val. E14: `candidate_evaluator_test.dart` (usable time, frame fill with unknown last, name; batch parity), `tonight_candidates_screen_test.dart` (the header names the order, no score); gate | TEST VERIFIED |
| B1 | PASS | S6 val. E12: `timeline_test.dart` (separate intervals, gaps), `planner_structure_test.dart` (the drawn data equals the opportunity and the fit's end); gate | TEST VERIFIED |
| B2 | PASS | S6 val. E12: `timeline_test.dart` (whole-hour ticks, half-hour zone, DST, 12/24 h, labels outside the plot at 100 % and 200 %, field edges); gate | TEST VERIFIED |
| B3 | PASS | S6 val. E11, E12; S9 val. T6 (TD-089 now committed): `timeline_test.dart` and `accessibility_test.dart` (text alternatives), `stacking_gain_graph_test.dart`, `detail_screens_test.dart` (cloud bars, no bar for an unknown hour, no twilight bar without a sunset), `twilight_bands_test.dart`; gate | TEST VERIFIED |
| B4 | PASS | S6 val. E5, E13: `dark_span_test.dart` (−18°, −15°, −12°, no darkness), `tonight_home_screen_test.dart` (dark span at three limits); gate | TEST VERIFIED |
| B5 | PASS | S9 val. T4 and probe P2, now committed (TD-089): `settings_rebuilt_test.dart` (each gate on, its threshold changes the usable time), `imaging_opportunity_calculator_test.dart`; gate | TEST VERIFIED |
| B7 | PASS | `clock_test.dart` ("no DateTime.now() in lib/domain"); `session_night_resolver_test.dart` (T9–T16, I1–I10, a non-UTC now rejected); `night_time_formatter_zone_test.dart` (site zone, else the labelled device zone); gate. Code: the `.toLocal()` night fallbacks in `logbook_screen.dart`, `entry_share_text.dart`, `plan_lifecycle_viewmodel.dart`, `sessions_viewmodel.dart` apply only to legacy rows without a night key; the two `DateTime.now()` in presentation are date-picker bounds | TEST VERIFIED |
| B8 | PASS | S6 val. E5; S9 val. T6: `weather_forecast_widget_test.dart` (age, stale label, units, attribution), `detail_screens_test.dart` ("Tap to set location" never shown), `night_summary_text_test.dart` (no score, no good/bad word); gate | TEST VERIFIED |
| B9 | PASS | S9 val. T7: `sky_darkness_context_test.dart` (known, partly known, unknown with the way to set it, local date, no ISO date); no conversion or inference in code; gate | TEST VERIFIED |
| C1 | PASS | S6 val. E10; S7 val. T3b (E8, E8b, E8c independently derived): `capture_budget_calculator_test.dart`, `fit_analyzer_test.dart`, `in_camera_noise_reduction_test.dart`, `capture_outputs_test.dart`, `planner_structure_test.dart`; gate | TEST VERIFIED |
| C2 | PASS | S6 val. E7, E10; S7 val.: `planner_disclosure_test.dart` (every ADR-009 line), `capture_budget_calculator_test.dart` (calibration never integration, outside-window calibration outside the window load, library blocks take no time); gate | TEST VERIFIED |
| C3 | PASS | S6 val. E10 (TD-074 limits): `capture_outputs_test.dart` (`capture.whatFits`, from `maxFramesForBlock` / `unplacedFramesByBlock`); gate | TEST VERIFIED |
| C4 | PASS | S6 val. E11 (S6.11, S6.16/TD-076): `stacking_gain_curve_test.dart`, `stacking_gain_graph_test.dart` (√N per group, never combined, "Your plan" / "For comparison", no SNR or recommendation wording, text alternative, 200 %); no change to CALC-42 since; gate | TEST VERIFIED |
| C5 | PASS | S6 val. E10: `capture_outputs_test.dart` (a known RAW size with its unit; unknown with the reason and the way to supply it; no rig) | TEST VERIFIED |
| C6 | PASS | S7 val. T1: `test/domain/services/plan_tracking_test.dart`, `test/presentation/plan_tracking_test.dart` (effective tracking drives NPF and the maximum-exposure warning; unknown neutral; never blocks); gate | TEST VERIFIED |
| C7 | PASS | Tests: `tonight_candidates_screen_test.dart` (header, no score), `candidate_evaluator_test.dart` (plain sorts), `night_summary_text_test.dart` (no good/bad word), `planning_preferences_test.dart` (every threshold clamped to its range, unit-named fields); gate. Code: no "score" or "rating" string shown anywhere in `lib`; every "%" shown is a measured value (cloud, humidity, Moon illumination) or a preference, never a composite | TEST VERIFIED + CODE VERIFIED |
| C8 | **FINDING** | Tokens: `presentation_style_rules_test.dart` (no `Colors.`, no colour literal, no font under 12, no shrink-wrap), `app_theme_test.dart`; gate — PASS. `QuantityText`: no test enforces it (the matrix's "rule tests" cover tokens only); by code, "Altitude now" formats a signed degree by hand (S11H-02) and other quantities are hand-built with the same text (S11H-05). Calculations: none in widgets beyond the rig editor's f/D preview (S11H-05) | TEST VERIFIED (tokens); CODE VERIFIED (the rest) |
| D1 | PASS | S7 val. T2a, T2b: `light_block_form_test.dart` (each class at 200 %, hidden values kept and exported, no conversion), `camera_class_test.dart`; gate | TEST VERIFIED |
| D2 | PASS | S7 val. T2b: `light_block_form_test.dart` (the previous light block's values proposed and marked, stored only on Save; the interval's label and help only); gate | TEST VERIFIED |
| D3 | PASS | S7 val. T3a and the V5 revalidation (TD-083): `calibration_blocks_test.dart` (the matrix cell by cell, origin, "Use other values", one-tap fix and Undo), `calibration_match_test.dart`; gate | TEST VERIFIED |
| D4 | PASS | S7 val. T3a: `calibration_blocks_test.dart` (dark flat through SQLite, snapshot and export; tips hideable, warnings stay); gate | TEST VERIFIED |
| D5 | PASS | S7 val. T3b: `in_camera_noise_reduction_test.dart` (E8, E8b, E8c), `in_camera_noise_reduction_ui_test.dart` (the switch per class, off by default, fill count, "darks twice"); gate | TEST VERIFIED |
| D6 | PASS | S7 val. T6: `rig_form_test.dart`, `equipment_editor_fit_test.dart` (fits at 200 % with Roboto), `camera_class_test.dart` (the user's choice, never inferred); gate. (The rig editor's contrast: S11H-01, row H1) | TEST VERIFIED |
| D7 | PASS | S6 val. E9, E16 and the V5 revalidation (TD-082): `capture_blocks_test.dart` (rows, Delete + Undo), `capture_blocks_undo_test.dart` (Fill, Trim, the example plan, the exact deleted block); gate | TEST VERIFIED |
| E1 | PASS | S7 val. T4: `target_search_test.dart`, `catalog_aliases_test.dart` (designations, aliases, common names, offline; `catalogId` unchanged; deleted stays deleted; custom rows); gate | TEST VERIFIED |
| E2 | PASS | S7 val. T5 and the V5 revalidation (TD-084): `sites_screen_test.dart` (elevation null when unknown, GPS only on tap and only into the form, leave guard), `sky_darkness_context_test.dart`; gate | TEST VERIFIED |
| E3 | PASS | Stage 3 sign-off; S7 val. T2a; S8 val. T8: `metadata_import_review_test.dart`, `equipment_editor_prefill_test.dart`, `equipment_add_from_photo_test.dart`, `session_snapshot_builder_test.dart` (per-field provenance); gate | TEST VERIFIED |
| E4 | PASS | S7 val. T1, T2a: `equipment_example_test.dart`, `camera_class_test.dart` (seed Unknown), `plan_tracking_test.dart` (seed tracking Unknown); elevation null (T5); no default Bortle or file size (`sky_darkness_context_test.dart`, `capture_outputs_test.dart`); gate | TEST VERIFIED |
| F1 | PASS | S8 val. T1, T3 (TD-085, TD-086 since resolved): `saved_plan_transition_test.dart` (CALC-44, one copy, snapshot unchanged, restart twice), `drift_session_results_test.dart`; gate | TEST VERIFIED |
| F2 | PASS | S8 val. T2: `results_screen_test.dart` (each outcome, Saved and Saved · changed, review, Back, stale form, not before the night ends), `lifecycle_matrix_test.dart` L8 (a failed write keeps the input); gate | TEST VERIFIED |
| F3 | PASS | S8 val. T3: `saved_plan_transition_test.dart`, `tonight_home_screen_test.dart`; the E2E (`tonight.resultDue` gone after Save result); gate | TEST VERIFIED |
| F4 | PASS | S8 val. T4 and probe P2, now a committed test (TD-087): `live_runs_survive_test.dart`; no tracker route, screen or card in `lib`; gate | TEST VERIFIED |
| F5 | PASS | S8 val. T5: `logbook_screen_test.dart`; plus S11.C1's `logbook_comes_back_test.dart` (a plan saved while the Logbook was out of view is listed); gate | TEST VERIFIED |
| F6 | PASS | S8 val. T6: `schema_migration_test.dart` (v25 group), `session_detail_test.dart` (set, list, search, remove), `backup_restore_test.dart` (a named plan round trip); probe P1 (the name after kills); gate | TEST VERIFIED |
| F7 | PASS | S8 val. T7: `session_detail_test.dart`, `entry_share_text_test.dart` (five states, Old log); gate | TEST VERIFIED |
| F8 | PASS | S8 val. T7: `entry_share_text_test.dart` (no notes, no coordinates), the export's manifest unchanged (`session_manifest_codec_test.dart`; the E2E re-parses it); gate | TEST VERIFIED |
| F9 | PASS | S8 val. probe P1 (v23 → v25 byte-equal); `schema_migration_test.dart` (every version v8 → v25 equal to the snapshot; per-step preservation; refusal below v8 and above the app); gate | TEST VERIFIED |
| F10 | PASS | S8 val. T1, T6; S7 val. T1: `session_manifest_codec_test.dart` (the new keys, `reported`, a pre-S8.1 file, `manifest_version` 2); gate | TEST VERIFIED |
| F11 | PASS | S8 val. T9 and probe P4: `backup_restore_test.dart` (format 2 preferences, no transient position or plan ids or place-name opt-in, restore and reset clear plan ids, a version 1 archive); gate | TEST VERIFIED |
| F12 | PASS | Probes P1 and P2 (names and every result field survive two kills and v24 → v25); committed: `lifecycle_matrix_test.dart` L4 (a result recorded after a kill), `schema_migration_test.dart` v24 → v25 (`result_kind` kept), S8 val. P1; coverage gap: S11H-07 | TEST VERIFIED (probes) |
| G1 | PASS | S9 val. T1; TD-090 since resolved: `library_manage_mode_test.dart` (a tap opens, plan and active site unchanged; `/select/…` chooses; "Plan this target" under the guard; a site added in the Library is not made active); gate | TEST VERIFIED |
| G2 | PASS | S9 val. T1 and probe P1, now committed (TD-089): `library_manage_mode_test.dart` (rigs, targets and sites: visible Delete and swipe, one confirmation, a cancelled swipe returns the row, "Target deleted"); gate | TEST VERIFIED |
| G3 | PASS | S9 val. T2: `retired_terms_test.dart` (baseline empty), `secondary_forms_test.dart`; gate | TEST VERIFIED |
| G4 | PASS | S9 val. T4: `settings_rebuilt_test.dart`, `backup_section_test.dart` (Restore through `confirm.action`); gate | TEST VERIFIED |
| G5 | PASS | S9 val. T5: `about_screen_test.dart` (the author block first, Reddit the one filled button, GitHub, the version; each credit linked; source, project and policy links unchanged pending RD-01); gate | TEST VERIFIED |
| G8 | PASS | S9 val. T5 and G: `LICENSE` is GPL-3.0 (unchanged since `ddb12ed`); `about_screen_test.dart` ("states the GPL-3.0 licence"); `assets/catalog/OPENNGC_NOTICE.txt` shipped and registered in `main.dart`; gate | TEST VERIFIED |
| G9 | PASS | S9 val. T8; TD-091 since resolved: `app_messages_test.dart`, `file_names_test.dart` (local date, the zone in the share text), the messages' tests; gate | TEST VERIFIED |
| H1 | **FINDING** | `accessibility_test.dart` sweeps 23 routes plus Settings all on, the result form's Not done, the planner with every section open and a new plan (three themes × 100 %/200 %, 412 px); gate. It does not open the rig, target or block editors, the Logbook's filter panel or the map picker. Probe P4 audited them: the rig editor fails contrast in light and dark (S11H-01); the target editor overflows under the test font only (P5; S11H-04); the block editor and the filter panel pass | TEST VERIFIED (sweep and probes) |
| H2 | PASS | Code: all 15 `IconButton`s in `lib` have a `tooltip`; the two relabelling `Semantics(excludeSemantics: true)` buttons (`collapsible_section.dart`, `context_line.dart`) pass `onTap` and `enabled` (the other two are charts). Tests: `collapsible_section_test.dart`, `context_line_test.dart` (`hasTapAction`); the sweep's `labeledTapTargetGuideline`; gate | TEST VERIFIED + CODE VERIFIED |
| H3 | PASS | The sweep at 200 % raises no overflow on the planner, Settings, the Logbook, the result form and the entry; 200 % tests: `capture_blocks_test.dart` (block rows), `light_block_form_test.dart` and `calibration_blocks_test.dart` (the block editor), `equipment_editor_fit_test.dart` and `rig_form_test.dart` (the rig editor), `session_detail_test.dart` (planned against actual), `tonight_home_screen_test.dart`, `stacking_gain_graph_test.dart`; `timeline_test.dart` (compact density drops labels; every graphic has its text form); probe P4 (the filter panel and the block editor at 200 %). Code: no `maxLines` or ellipsis on the listed texts | TEST VERIFIED |
| H4 | PASS | S9 val. T8 (TD-081): `app_messages_test.dart` (under `disableAnimations` a message is in place at once); S6 val. E9, E16 (`capture_blocks_test.dart`, `capture_blocks_undo_test.dart`: no change mark when reduced); no action or startup awaits an animation (`main.dart`); gate | TEST VERIFIED |
| H5 | **FINDING** | Verdicts, warnings and stale states carry words (S1.9 status; `WeatherText`, `night_summary_text_test.dart`); selections carry an icon: rig and target pickers `Icons.check_circle`, sites a radio icon with "Active site", chips and segmented buttons their check marks, the tracking choice "Chosen". Exception: the time-zone picker marks the current zone by colour only (S11H-03) | CODE VERIFIED (+ the tests named) |
| I1 | PASS | `app_theme_test.dart` (every field token, scheme role and text red or black; the filter matrix), `field_mode_darkness_test.dart` (real pixels have no green or blue; survives a restart), `main.dart` wraps the app in `AppTheme.fieldFilter`; gate | TEST VERIFIED |
| J1 | PASS | `lifecycle_matrix_test.dart` L1 (offline: night, opportunity and plan work; the forecast is `NightWeatherUnavailable`), `weather_forecast_widget_test.dart` ("Couldn't load weather." with Retry; "Stale forecast: updated 15 h ago", never "Updated"), `night_weather_service_test.dart` (thresholds, offline cache with its age), `forecast_freshness_test.dart` (re-ages with the clock without a fetch; `NightClock` ticks and resumes); gate | TEST VERIFIED |
| J2 | PASS | `place_name_lookup_test.dart` (off by default; off sends nothing), `planner_location_test.dart` (a failed lookup leaves the name empty), `planner_sites_test.dart` (an active site is not geocoded), L1 (a failing geocoder blocks nothing); gate. Code: `SiteViewModel` never looks up the default position (`_usingDefaultLocation` guards) | TEST VERIFIED (+ CODE for the default position) |
| J3 | PASS | `planner_bootstrap_test.dart` (a failure sets `hasBootstrapError`; `retryBootstrap` recovers), `home_screen_test.dart` (the first screen renders before weather; weather loads after the first frame and fails; the retry view); L1 offline; gate. Code: `main.dart`'s startup path has no network call (backup staging, the schema probe, seeding, preferences) and `NightConditionsViewModel.begin` loads weather in a post-frame callback | TEST VERIFIED |
| J4 | PASS | `location_picker_screen_test.dart` (denied, denied forever, services off; typed coordinates), `sites_screen_test.dart` (the form usable without GPS), `target_search_test.dart` (pure, offline); probe P3 (tiles failing); coverage gap: S11H-06 | TEST VERIFIED |
| K1 | PASS | S8 val. I; S9 val. R: every changed write through `runWithFeedback` (Save plan, Save result with the input kept, deletes, settings, backup and restore staging, export, rename, applying imported metadata); `lifecycle_matrix_test.dart` L8 (SQLITE_FULL), `storage_failure_test.dart`, `failure_feedback_test.dart`, `settings_rebuilt_test.dart` (the shared failure text); S11.C1 added no write; gate | TEST VERIFIED |
| K2 | PASS | `no_empty_catch_test.dart`; `failure_feedback_test.dart` (`LoadFailureView`, no cause shown); no `Text` built from an error in `lib/presentation`; gate. One `print` outside a catch: S11H-08 | TEST VERIFIED |
| L0 | PASS | S8 val. T4: `lifecycle_matrix_test.dart` L1, L3–L6, L8 and `core_loop_test.dart` follow Save → result (no tracker step); snapshot, one copy and replay = counters asserted (L4, `saved_plan_transition_test.dart`, `drift_session_results_test.dart`); gate (host E2E 2) | TEST VERIFIED |
| M2 | PASS | S10 val. T3, T4, probe P1 (P3 the mutation): `planner_memoization_test.dart` (invalidation; tolerant benchmark), `candidate_evaluator_test.dart` (250 targets under 1 s), `rig_editor_rebuilds_test.dart`, `media_query_aspects_test.dart`; gate | TEST VERIFIED |
| N1 | PASS | `app_identity_test.dart` (Gradle, manifest, `MainActivity`), `release_config_test.dart` (`x.y.z+N`); `pubspec.yaml` `1.0.0+1` and `AppIdentity.version` `1.0.0`; gate | TEST VERIFIED |
| P1 | PASS (to be confirmed by S11.7) | The full gate at `9668a13`: 1,840 tests, 2 skips, host E2E 2 + 1; inputs unchanged to `9698fd9`. Any corrective code for S11H-01 to S11H-03 invalidates it (V3) | TEST VERIFIED |
| P3 | PASS | Corrected in this change: `TEST_PLAN.md` § End-to-end suite (Save plan → result; how the emulator ran it; the retired mutation check), § Lifecycle matrix (the header, L2's button, L7's schema v25), the TASK 15.3 and 12.4 owner checklists; `CLAUDE.md` traps 18 and 19 | DOCUMENTED |

**Counts.** 70 rows: 67 PASS, 3 FINDING (C8, H1, H5, a blocker each). F12, J4, K2 and H3 pass with
follow-ups (S11H-04 to S11H-08).

## Findings

### S11H-01 — BLOCKER (V4 A; H1): the rig editor's sensor size fails text contrast in light and dark

The auto-calculated sensor size (the read-only W × H fields, `equipment_editor.dart` lines 376–413,
styled `Theme.of(context).disabledColor` on a filled field) and its note "Auto-calculated from
Resolution × Pixel Size" (line 416, `onSurface.withAlpha(128)`) measure, with the sweep's
`textContrastGuideline` (P4, all four light and dark runs): values 2.66:1 (light) and 3.59:1 (dark),
the note 2.81:1 (light) and 4.32:1 (dark), against 4.5:1. P6 confirms the values with Roboto. H1
requires contrast in light and dark for the editors. The read-only value could be argued an inactive
component (WCAG's exception), but it is the rig's sensor size, information the user reads, and the
note is plain text. Not a regression: styled so since the editor's early form (`d0b737f`), kept by S3.5.
**Direction:** a palette text token with AA contrast for both (for example `textSecondary`), and the
rig editor added to the sweep. **Destination:** a corrective Task (S11.C2), then V5 revalidation of H1.

### S11H-02 — BLOCKER (V4 A; C8): "Altitude now" is a hand-formatted signed degree

`home_screen.dart` line 128 shows `'${conditionsVm.currentAltitude?.toStringAsFixed(1)}°'`. The target's
altitude now is negative whenever it is below the horizon, so the planner shows "-12.3°" with a
hyphen-minus, and can show "-0.0°"; `QuantityText.degrees(value, digits: 1)` gives "−12.3°" and never
"−0" (trap 13, S1.7). C8 requires signed degrees through `QuantityText`. Cosmetic; present since the
planner's first version (`66863af`), not a regression. **Direction:** `QuantityText.degrees(…, digits: 1)` with a test.
**Destination:** S11.C2.

### S11H-03 — BLOCKER (V4 A; H5): the time-zone picker marks the current zone by colour alone

`zone_picker_dialog.dart` lines 56 and 68 use `ListTile(selected: …)` with no icon or word; Material 3
changes only the text colour (no tile colour is themed), and in field mode that is red on red. Screen
readers do hear "selected". H5: colour never carries a selection alone. From TASK 7.3, not a
regression. **Direction:** a check icon (or "Current") on the current row, as the rig and target
pickers do. **Destination:** S11.C2.

S11H-01 to S11H-03 are each a small presentation change; one corrective Task can carry the three with
their tests. They are classified by V4 A because each contradicts a frozen matrix row as written; S11.7
makes the call.

### S11H-04 — FOLLOW-UP (H1, H3 coverage): the sweep never opens the editors, the filter panel or the map picker

`accessibility_test.dart` navigates routes; the rig, target and block editors, the Logbook's filter
panel and the map picker are dialogs, sheets or routes it never opens (TASK 15.3 already listed "dialogs,
the map picker" as not covered). P4 covered all but the map picker. Under the test font the target
editor's "Object type" dropdown overflows by 2.4 px at 100 % and 226 px at 200 % (412 px): the
`DropdownButtonFormField` has no `isExpanded` and sizes to "Globular Cluster". With Roboto (P5) it fits
at 360 and 412 px up to 200 %, so there is no failure on the Android default font; a wider OEM font
could clip the name. **Direction:** add these to the sweep (the target dropdown will need
`isExpanded: true` to pass under the test font). **Destination:** with S11.C2, or `TECH_DEBT.md`.

### S11H-05 — FOLLOW-UP (C8): quantities built by hand with the same text; no test holds trap 13

Besides S11H-02: percentages (`settings_screen.dart` 125, 461; `session_detail_screen.dart` 435–436;
`opportunity_text.dart`'s gate reasons and cloud ranges), durations (`settings_screen.dart` 142–295,
`capture_assumptions_panel.dart` 32–33), exposures (`capture_budget_summary.dart` 232;
`CapabilityText._seconds`, which writes "≈ 5.0 s" where `QuantityText.exposure` writes "5 s"), and
signed degrees (`opportunity_text.dart` and `altitude_chart_widget.dart` `_signed`, which can print
"−0°") are formatted locally, mostly with the same text as `QuantityText`. No rule test keeps them in
`QuantityText`. The rig editor also previews N = f / D in the widget (`deriveFocalRatio`); the saved
value is the domain's `resolveAperture`. **Destination:** `TECH_DEBT.md`.

### S11H-06 — FOLLOW-UP (J4 coverage): no committed test loads the map with failing tiles

The picker tests never let a tile request run. P3 had to mock `path_provider`, because flutter_map's
built-in tile cache calls `getApplicationCacheDirectory` (no host implementation). The emulator's J5 run
covers it at runtime. **Destination:** commit P3's shape (`TECH_DEBT.md`).

### S11H-07 — FOLLOW-UP (F12 coverage): names and result fields across a kill are established by probes

The lifecycle harness never kills after a rename or a result, and the v24 → v25 test keeps
`result_kind` but not `not_done_reason` or a `reported` event. P1 and P2 establish both. The same
pattern as TD-087 and TD-089. **Destination:** commit P1- and P2-shaped tests (`TECH_DEBT.md`).

### S11H-08 — FOLLOW-UP (K2): the v10 orphan cleanup logs with `print`

`app_database.dart` line 639 reports deleted orphan rows with `print` (`// ignore: avoid_print`), not
`AppLog`; trap 15 says never `print`. It is not an error path, and it predates `AppLog` (TASK 3.3).
**Destination:** `TECH_DEBT.md`.

### Notes (not findings)

- The matrix's L2 row and `TEST_PLAN.md`'s L2 steps named the services-off button "Open location
  settings"; the app says "Open settings" (tested; S11.3's observation). `TEST_PLAN.md` is corrected; the
  frozen matrix is not edited.
- The matrix's current-evidence column cites "gate S10.6"; the S11.C1 gate supersedes it with the same
  tests and more.
