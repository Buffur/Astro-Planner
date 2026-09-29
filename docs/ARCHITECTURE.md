# AstroPlan Architecture

> **S8.9, 2026-09-29:** `BackupPreferences` (`lib/data/backup/`) reads and restores the settings a backup carries, by the keys the SharedPreferences repositories expose (`SharedPrefsPlanningPreferencesRepository.keys`, `fieldModeKey`, `activeLocationIdKey`, `planIdKeys`, `doneKey`); `BackupArchive` (`format_version` 2) holds them as `preferences.json`; `BackupStaging.apply` restores them before the database swap (`restorePreferences`, default `BackupPreferences.restore`); `confirmDatabaseReset` calls `BackupPreferences.forgetStaleIds`. Data layer only; the backup ViewModel and screen are unchanged.

> **S8.7, 2026-09-29:** `session_detail_screen.dart` on `DetailScaffold` (`_Result` as the summary; `_Conditions` split from `_Notes`; `_Actions` by `ResultAction` and the saved night, I-6); `EntryShareText` (`presentation/shared/`, pure) is the Share text of both the entry and the Logbook row; `PlanLifecycleViewModel.openSession(copyTo:)` and `CurrentSession.adopt(unsaved:)` make Copy to another night; `SessionLog.toShareableText` removed.

> **S8.6, 2026-09-29:** `SessionRepository.rename` (trimmed, at most 80 characters, empty = none, legacy refused; a partial row write only); `Session.name`; `SessionsViewModel.rename` and `revision`/`markChanged` (bumped by a name, a deletion or a recorded result, which the Logbook watches to read its entries again); the entry's `_NameTile` and `_NameDialog` (the dialog owns its field). `entryTitle` is the name, else `targetAndNight`.

> **S8.5, 2026-09-29:** `SessionsViewModel` moved to `sessions_viewmodel.dart` (`library_viewmodels.dart` re-exports it) and holds the Logbook's `filter` and `query` (`setFilter`, `setQuery`), `searched` and `grouped` (Upcoming/Past through CALC-44). `logbook_screen.dart` is rebuilt on them: `entryTitle`, `deleteEntry` (`confirmDestructive`; also the entry's `DeleteButton`), `SwipeToDelete`, a `_FilterPanel` bottom sheet over the ViewModel. `AppRouter.logbookProgress` (`/sessions/progress`, before `:id`) replaces `libraryProgress`; `ProgressScreen` moved to `screens/logbook/`. The entry's status is a `PlanStateLabel`; `sessionStatusLabel` is gone.

> **S8.4, 2026-09-29: the live tracker retired (the owner, 2026-09-27; ADR-016 §13).** The dependency audit (P8.4's classes):
> - **(A) UI only for live tracking — removed:** `execution_screen.dart` and the `/session/:id/run` route (`AppRouter.run`); `ExecutionViewModel`; the resume prompt (`resume_run_dialog.dart`, `ResumeRunViewModel`); `start_session.dart` (TD-073's last message); the planner's ⋮ ""Track live (optional)""; Tonight's run card; the entry's ""Open tracker""; keep-screen-on (`ScreenWake`, `WakelockScreenWake`, `DisplayPreferencesRepository.load/saveKeepScreenOn`) and the `wakelock_plus` dependency (no Dart use left; `pubspec.lock` loses it and its platform interface); `CaptureAnalysisViewModel.startSession`, `PlanLifecycleViewModel.startPlan`, `CurrentSession.start`; `ExecutionOutlook` (CALC-36) and `ExecutionMachine.runningTime`/`estimate`/`clockBehind`/`isStale` with `FrameEstimate` (CALC-35).
> - **(B) kept:** `ExecutionMachine`'s fold and transitions (the replay that history, results, the export and progress use) and the counters' invariant; `SessionRepository.start`/`record`/`complete`/`abandon` as the stored-run API (no UI caller; the history tests create old runs through it, `test/support/legacy_run.dart`); the planner's copy rule for a run in progress; `recordResult`'s in-progress path (S8.1).
> - **(C) persisted data — unchanged:** every `session_events` row, counter, execution-start snapshot and completed or abandoned run; the export (manifest v2 with its events) and the backup. No migration. The orphaned `keepScreenOnWhileTracking` preference key is left in place (harmless; never read).
> - **(D) tests of the removed UI — retired:** `execution_screen_test.dart`, `resume_run_prompt_test.dart`, `execution_outlook_test.dart`; the estimate, running-time and staleness cases of `execution_machine_test.dart`; ""Start, then an edit"" (`save_start_race_test.dart`); the Track live menu case (now asserts its absence); the lifecycle rows L4, L6 and L8's tracker parts (replaced by the saved-night lifecycle); the E2E's tracker steps (replaced by Save → the night → result).
> - **(E) kept:** the fold, replay and correction tests; `drift_session_execution_test.dart`; reconciliation and progress tests.
> - A run still in progress from an older version is listed as Tracking, offered on Tonight's line and in the Logbook, and recorded through the result form. **TD-063:** `openSession` re-reads the session by id (`CurrentSession.stored`); a session deleted meanwhile opens as a copy.
> **S8.3, 2026-09-29:** the saved-plan transition: `CurrentSession.leaveEndedSavedPlan` (in the autosave chain: an untouched copy for a Saved plan, `settleSavedPlan` for a Saved · changed one; idempotent), called by `PlanLifecycleViewModel` at restore and in `followNight` (`NightClock`'s minute tick and resume), with the injected `Clock`; a failure is logged and retried at the next check. `openSession` opens an ended saved plan as a copy (`adopt(asCopy:)`). `PlanLifecycleViewModel.onNightChecked` and `ResultsViewModel`'s `onRecorded` call `SessionsViewModel.refreshDue`, which keeps `dueResult` for Tonight's `_ResultDue` line (`SessionsViewModel?` is also provided, for graphs without sessions). `PlanLifecycleViewModel` is at 300 physical lines.

> **S8.2, 2026-09-29:** the result form: `ResultsViewModel` (repository, clock, and `PlanLifecycleViewModel.settle` as a hook) loads an entry, settles a Saved · changed one through `CurrentSession.settle` (in the autosave chain; the planner's current session becomes the copy when it was the entry), and records a `ResultReport` with the entry's `updated_at` (stale → reload and rethrow). `ResultsScreen` holds the outcome, reason and counts as form state. `ResultAction.of` (domain, pure) says whether an entry offers Record result or Edit result; `SessionsViewModel.resultAction` applies it with the injected clock. `PlanState.from` returns Partly for a completed result reported as partly; `FailureText` words `StaleResultForm` and `NightNotEnded`.

> **S8.1, 2026-09-29:** results without a run (ADR-019 §4; DECISIONS E.1, "Stage 8 decisions"): `session_result.dart` (domain: `ResultKind`, `NotDoneReason`, `ResultNotes`, the sealed `ResultReport` — `CompletedAsPlanned`, `PartlyDone`, `NotDone` — and the refusals `StaleResultForm`, `NightNotEnded`); the pure `SavedNightEnd` (CALC-44); `ExecutionEventKind.reported` (not started → finished in `ExecutionMachine`); `SessionRepository.recordResult` (one transaction: the event, the counts as `framesConfirmed` corrections, the totals from the replay, the status, the result kind or reason, the notes) and `settleSavedPlan` (a Saved · changed plan → its saved entry plus a never-saved copy). `Session` gains `resultKind`, `notDoneReason`, `isSavedPlan`, `isSavedChanged`. No screen changed yet (S8.2).
> **S7.6, 2026-09-29:** the rig form (UX-22): `equipment_editor.dart` asks the pixel size once and puts the maximum exposure, RAW size and rotation in a `CollapsibleSection` (`rigEditorMoreSection`) in its new controlled use (`open`/`onToggle`, state in the dialog), its summary rebuilt by a `ListenableBuilder` over those three controllers only; `AppWords.editRig`. `EquipmentDraft` is unchanged.
> **S7.5, 2026-09-29:** the site form (RG-08 = E2, RG-09 = S3/M2, UX-21): `LocationProfile.elevation` is `double?`; `SiteEditorScreen` adds "Use current position" (`SiteViewModel.locateDevice`, filling only the form), the collapsed `CollapsibleSection` `sites.skyDarkness` with `SiteFormInput.mapLink`, and a `PopScope` using S5.8's `askUnsavedChanges`; `LightPollutionMapLink` targets lightpollutionmap.app.
> **S7.4, 2026-09-29:** target search and aliases (RG-07 = T1): `TargetAlias` (domain model) and the pure `TargetSearch` (`domain/services/target_search.dart`: designation keys, match kinds, reading-order ids); `DriftTargetRepository.searchTargets` runs it over every target and alias (no `LIKE`), plus `aliasCatalogVersion` / `replaceAliases` on `TargetRepository`; `CatalogSeeder._syncAliases` rebuilds the `target_aliases` table from the asset's `aliasIds`/`aliasNames` whenever its recorded version differs; `tool/build_catalog.dart` writes them (catalog version 3, `selectionSince` 2).
> **S7.V2, 2026-09-29:** the site editor's back guard (`SiteEditorScreen`) rebuilds its `PopScope` when any field starts or stops differing from the opened form (a flip-only listener on name, elevation and notes; coordinates and SQM already rebuild); state stays local, no ViewModel is touched (TD-084).
> **S7.V1, 2026-09-29:** `CalibrationMatch.takesExposure(FrameType)` and `takesSensitivity(FrameType)` state what a calibration block takes from its source; `matched` and the block dialog's "Use other values" both read them, so the dialog never overwrites a value the frame type leaves to the user (TD-083).
> **S7.3b, 2026-09-29:** in-camera noise reduction (ADR-020 §8): `EquipmentProfile.inCameraNoiseReduction` (stored on the camera module, v21) and `noiseReductionApplies` (with `CameraClass.offersInCameraNoiseReduction`); `CaptureOverheads.inCameraNoiseReduction` (`fromPreferences(p, inCameraNoiseReduction:)`), read by `CaptureBudgetCalculator` (each light's frame event carries its dark; `CaptureBudget.inCameraDarkMs`), so `FitAnalyzer`'s placement and fill searches follow without code of their own; `CaptureAnalysisViewModel._overheads` joins the settings and the rig (a rig edit notifies through `SessionPlanViewModel.refreshSelectedEquipment`, trap 16); `CalibrationMatch.ofPlan(blocks, rig)` adds `darksTwice` (`fixable` false); the rig editor's switch (`equipmentEditor.noiseReduction`), the assumptions row and the budget's "Of which in-camera darks".
> **S7.3a, 2026-09-29:** calibration blocks (ADR-020 §6–§7): `FrameType.darkFlat`; the pure `CalibrationMatch` (`domain/services/calibration_match.dart`: the match checks, `lightFiltersWithoutFlats`, `sourcesFor`, `defaultSource`, `matched`, the one-tap fix); `CalibrationText` (`presentation/shared/`: warnings, the inherited line, tips); `showCaptureBlockDialog(blocks:, tipsShown:, onTipsShown:)` copies a source's values at creation (L1) and applies the class's ISO/gain kind and binning to every frame type; `CaptureAnalysisViewModel.calibrationMismatches` / `lightFiltersWithoutFlats`; the tips' state is a `DisclosureViewModel` key (`tips.calibration`).
> **S7.2b, 2026-09-29:** the light-block form by camera class (ADR-020 §3–§5): `CameraClass.lightSensitivity` and `offersLightBinning` (domain) decide the fields; `showCaptureBlockDialog(cameraClass:, proposal:)`; `SessionPlanViewModel.lightProposal` (the last light block); the per-frame overhead reads "Time between frames" (Settings and the assumptions panel; no arithmetic change).
> **S7.2a, 2026-09-29:** the rig's camera class (ADR-020 §2): `CameraClass` (`domain/models/camera_class.dart`) on `EquipmentProfile`, carried by `EquipmentDraft` (`fromProfile`, `forRig`; `fromCandidate` always Unknown) and chosen in the rig editor ("Camera type"); the Library's rig list shows it once chosen. It feeds no calculation; S7.2b uses it for the light-block form.
> **S7.1, 2026-09-29:** B4 notes the plan's tracking override (RD-08 = T3) and `SiteViewModel.nightAt`.
> **S6.V1, 2026-09-28:** B4 notes that a delete's Undo owns only the deleted block (TD-082).
> **S6.16, 2026-09-28:** B4 notes the corrective pass: the planner's amended order, Tonight's finish, the missing inputs' reasons, the √N graph's labels, Night & Moon without repetition, and the blocks' Undo (`BlocksEdit`).
> **S6.14, 2026-09-28:** B4 notes the candidates' default order (RD-10 = O1).
> **S6.13, 2026-09-28:** B4 notes Tonight's plan-first order and where each value went.
> **S6.12, 2026-09-28:** B4 records the timeline's inventory and its evolution (`TimelineData`, `TimelinePainter`, densities).
> **S6.11, 2026-09-28:** B4 notes the stacking-gain graph.
> **S6.10, 2026-09-28:** B4 notes "what fits", the storage note and `ChangeMark`.
> **S6.9, 2026-09-28:** B4 notes the capture plan's rows (`BlockText`), Delete with Undo and the effective tracking.
> **S6.8, 2026-09-28:** B4 notes the new defaults (no preselection, an empty capture plan, New plan without a target, the example rig).
> **S6.7, 2026-09-28:** B4 notes the planner's collapsible sections (`PlannerSections`) and where each value went.
> **S6.6, 2026-09-28:** B4 notes the planner's answer-first structure (`PlanStatus`, the context line, the section order).
> **S6.5, 2026-09-28:** B4 notes the Night & Moon and Weather detail routes, the dark span at the user's limit and `CandidatesViewModel`.
> **S6.3, 2026-09-28:** B4 notes Save · Discard · Cancel, the replaced-draft deletion and the revert of a changed saved plan (S4-DEF-04 = R).
> **S6.4, 2026-09-28:** B11 notes the rollover rule for a never-saved draft (`PlanLifecycleViewModel.followNight`, TD-057).
> **S6.2, 2026-09-27:** B4 notes the planner's identity strip and ⋮ menu, and that `CurrentSession.startNew`/`adopt` run in the autosave chain (TD-058).
> **S6.1, 2026-09-27:** B1 and B4 record the split of `SessionPlanViewModel` into the plan's contents (`SessionPlanViewModel`) and its lifecycle (`PlanLifecycleViewModel`).
> **S5.9, 2026-09-27:** B17 points to the adoption plan (DESIGN_SYSTEM §9) and the opt-in render test.
> **S5.8, 2026-09-27:** B17 notes the confirmation, feedback and delete patterns (RD-09 = M + S1).
> **S5.7, 2026-09-27:** B17 notes the detail-screen template.
> **S5.6, 2026-09-27:** B17 notes the context line and `pickNight`.
> **S5.5, 2026-09-27:** B17 notes the collapsible section and `DisclosureViewModel`.
> **S5.4, 2026-09-27:** B17 notes the status tokens, `StatusBlock` and `PlanState`.
> **S5.3, 2026-09-27:** B17 notes the shared words (`AppWords`) and the retired-terms test.
> **S5.2, 2026-09-27:** B17 extended (component themes for the controls; `AppMotion`).
> **S5.1, 2026-09-27:** B17 added (the design system's foundation tokens and gallery test).
> **S4.V3, 2026-09-27:** D5's lifecycle bullets now state only the owner's approved decisions;
> the detailed rules are Stage 6/8 design questions. Documentation only; Part B unchanged.
> **S4.V2, 2026-09-27:** D5's lifecycle bullets follow ADR-019 §3.1 as revised to the owner's R2 +
> D1: an immutable saved snapshot per night, results without Save plan, Stage 8 delivering the
> saved-plan transition at once. Documentation only; Part B unchanged.
> **S4.V1 clarification, 2026-09-27:** D5 includes saved-and-edited plans at startup and
> rollover and the explicit-Save result guard (ADR-019 §3.1). Documentation only; Part B unchanged.

> **Direction update, 2026-09-27 (S4.D):** ADR-019 (product flow and information architecture) is
> approved design intent, not yet built; see D5. Part B still describes the code.

> **Metadata update, 2026-09-26 (S3.1):** the contract gains image dimensions (ADR-018 §3; B entry
> after S2.9).

> **Metadata update, 2026-09-26 (S2.V4, commit `d8e792c`):** HEIF `iloc` work bounded; AVIF and
> HEIF sequences recognised only (B entry after S2.9).

> **Metadata verification update, 2026-09-26 (S2.V1–S2.V3):** see
> `refinement/STAGE_2_CORRECTIONS.md`; historical entries below keep their dates.

> **Superseded 2026-09-26 (S1.V6, finding X2):** S1.V1–S1.V4 (`3067658`, `b34c9ad`, `ed628f8`, `ea65231`) resolved TD-059–TD-062, confirmed by the repeat independent validation at `c99bd7f`. The note below is kept as history.
>
> **Independent Stage 1 validation, 2026-09-25, code `4e653fb`:** the S1.5/S1.6
> completion claims below are qualified by reproduced TD-059–TD-062. No design
> decision or implementation changed. See [validation](refinement/STAGE_1_VALIDATION.md).

> **Verification stamp:** verified against code at commit `900b82a` (2026-09-20),
> audited 2026-09-21. Application code changed since by TASK 1.1 (commit `2357755`:
> `LocationService` seam, `PlannerViewModel.ready`) and TASK 1.2 (commit `2e17093`:
> deterministic bootstrap, `hasBootstrapError`/`retryBootstrap`, `isDefaultLocation`,
> `weatherError`, Home empty/error states); affected spots are marked
> *(updated TASK 1.1)*/*(updated TASK 1.2)*. TASK 2.2 (2026-09-22) added pure-domain
> time types, not yet used by the app; see B5 *(updated TASK 2.2)*. TASK 2.3
> (2026-09-22, commit `de1792a`) made the calculators and the altitude chart consume
> `SessionNight`; see B1, B2, DEV-A3 *(updated TASK 2.3)*. TASK 2.4 (2026-09-22,
> commit `1e58fcf`) made `PlannerViewModel` and the UI (`home_screen.dart`,
> `sky_darkness_widget.dart`, `altitude_chart_widget.dart`, `logbook_screen.dart`)
> consume `SessionNight` through one `NightTimeFormatter`; see B4, B5, B11
> *(updated TASK 2.4)*. Line references into `planner_viewmodel.dart` were taken at
> `900b82a` and are now off by more; several were replaced with getter names in
> TASK 2.4's edits. TASK 3.2 (2026-09-22, commit `3c25e8c`) rewrote `onUpgrade`'s
> migration steps and added schema snapshots; see B6. TASK 3.3 (2026-09-22,
> commit `e580d03`) enabled foreign keys, added the v10 orphan cleanup and table
> rebuilds, and dropped `equipment_profiles`; see B6. TASK 4.2 (2026-09-22, commit
> `7641d49`) added `PlannerViewModel.markSessionSaved`/`refreshSelectedTarget`/
> `refreshSelectedEquipment`; see DEV-A2.
>
> This document keeps three things separate on purpose:
> - **Part A — Design intent** (approved Phase 0 baseline, preserved verbatim).
> - **Part B — CURRENT ARCHITECTURE** (what the code actually is; not improved
>   or idealized).
> - **Part D — TARGET ARCHITECTURE / INTENDED DIRECTION** (what the design intent
>   and the audit point toward; items marked *Proposed* are **not approved**).
>
> Part C lists every **IMPLEMENTATION DEVIATION** between A and B.
> Status vocabulary: **Intended / Planned**, **Actual / Implemented**, **Partial**,
> **Broken**, **Missing**, **Deprecated**, **Unknown**.
> **TASK 5.2 (2026-09-22):** planning preferences (`PlanningPreferences` + repository) and a Settings screen; the planner selection state moved behind `PlannerStateRepository`; `PlannerViewModel` no longer imports SharedPreferences.
> **TASK 5.4 (2026-09-22):** `CaptureBudgetCalculator` (CALC-25) implements the ADR-009 budget; the ViewModel only delegates; feasibility now uses the window load (calibration outside the window no longer counts against dark time); the dead `estimateTotalDuration` (CALC-19) was deleted. DEV-A4 resolved.
> **TASK 5.5 (2026-09-22):** `FitAnalyzer` (CALC-26) places the ADR-009 event sequence atomically into the windows and reports fits / tight / does not fit / no window / nothing to fit with a reason, end time, lost tails, unplaced frames, the inverse maximum and a similar-nights hint; the sum-of-windows `SessionCalculator` (CALC-18) was deleted.
> **TASK 5.6 (2026-09-22):** the capture planner UI shows every ADR-009 line (integration, acquisition, calibration in/outside the window, setup, window load vs available, session budget), the fit with its reason and end time, a one-tap "fill / trim to tonight's window" action, √N per (filter, exposure) group with help text, storage or "Unknown", and an assumptions panel; the block editor sets the calibration policy, binning and a typed gain. `capture_plan_widget.dart` was split into `widgets/capture_plan/`. Group G5 is complete.
> **TASK 6.2 (2026-09-22):** independent reference fixtures (USNO events and celestial-navigation altitudes, JPL Horizons Sun elevations, SIMBAD J2000 star positions; `test/fixtures/astronomy/`) and tolerance tests; target coordinates are now precessed J2000 → date (Meeus ch. 21, owner decision) in the one domain target-altitude function; altitudes stay airless with the −0.833° sunrise/sunset convention (owner decision); source/units/error doc comments on the astronomy functions.
> **TASK 6.3 (2026-09-22):** a pure-domain Moon ephemeris (`MoonCalculator`, Meeus ch. 47 full tables in `moon_series.dart`, ADR-010) — position, topocentric altitude, illuminated fraction, phase longitude, rise/set on the night grid — verified against JPL Horizons and USNO well inside ADR-010 §4. **Not used by the app yet** (TASK 6.4 wires it and retires the mean-phase model).
> **TASK 6.4 (2026-09-22):** `MoonConditions` (Moon altitude, separation from the target, rise/set, illumination at mean solar midnight, closest approach while both are up) from `MoonCalculator`, shown on the sky card as annotations; the mean-phase `calculateLunarIllumination` was deleted.
> **TASK 6.5 (2026-09-22):** the NPF rule now follows F. Michaud's primary source (derivation on sahavre.fr), with an explicit k (default 1, range 1–3); the circular test is replaced by independent worked examples. Still hidden (PD-11). Group G6 is complete.
> **TASK 7.1 (2026-09-23):** site semantics in schema v12 (nullable Bortle with source and date, SQM, IANA zone, notes; default Bortle 4 cleared with a note); a map pick or GPS fix is a transient, remembered position that never writes into a saved site; the `timezone` package (0.11.1, BSD) backs an `IanaTimeContext`, so a site's zone drives its night (ADR-007 L1 fixed for sites with a zone) and the display. Presentation passes `vm.displayZoneId` to the one formatter; the ViewModel resolves the time context (IANA or mean solar), never the device zone.
> **TASK 7.2 (2026-09-23):** location and geocoding behind domain interfaces. `LocationService` reports each permission outcome (`LocationFound`, or `LocationUnavailable` with `serviceDisabled` / `permissionDenied` / `permissionDeniedForever`) and opens the matching settings page; the location picker explains each outcome (rationale text + "Open settings") and no longer calls Geolocator. A `ReverseGeocoder` interface with a `NominatimReverseGeocoder` (identifying user agent `AstroPlan (com.astroplan.astroplan)`, at most 1 request/s, in-memory cache by coordinates rounded to 0.01°, failures reported, not cached) replaces the ViewModel's inline HTTP; OpenStreetMap attribution on the map and next to place names; the tile user agent is the real app id; typed coordinate entry works offline. No `http`/`geolocator` import in presentation or domain (test-enforced).
> **TASK 7.3 (2026-09-23):** sites UI. A Sites screen (`/sites`) lists saved sites with the active one marked; sites can be selected, created, edited and deleted (with confirmation); "use current position" and "pick on map" set a transient position, which can be saved as a site. The site editor (`/sites/edit`) validates name, latitude/longitude (typed or picked on the map), elevation (m), an IANA zone picker defaulting to the device zone, and notes; Bortle/SQM with their source sit behind `FeatureScope.lightPollutionContext` until TASK 7.4. Owner decisions: `flutter_timezone` 5.1.0 (Apache-2.0) behind a domain `DeviceTimeZone` seam, only to pre-fill the zone picker; the first run shows a site prompt instead of a silent GPS request; deleting the active site keeps its position as the transient position. `IanaTimeContext` now loads the `latest_all` zone data set (the 10-year set has no link zones such as `Europe/Ljubljana`).
> **TASK 7.4 (2026-09-23):** light-pollution MVP (PD-05 resolved). The ClearOutside scraper (`LightPollutionRepository`) is deleted, with its ViewModel argument, provider and per-location-change call; a location change makes no network call beyond weather and the place name. Option A: the external light-pollution map opens centred on the current position (`LightPollutionMapLink`), only when one exists. Option B: manual Bortle and/or SQM in the site editor, stored as source `user` with the date. `FeatureScope.lightPollutionContext` is `true` (its PD-06 phase). The sky card shows the known values with their sources (`SkyDarkness`), "not saved" for a transient position, or "unknown"; Bortle and SQM are never converted into each other; the sky warning still uses a known Bortle class only. Options C (offline dataset) and D (licensed API) are documented as deferred. Group G7 is complete.
> **TASK 8.1 (2026-09-23):** target model hardening, schema v13. `astro_targets` gains `epoch` (default and only supported value `J2000`), `source` (ADR-008 §6: `user`, `seed:catalog@1`; NULL for legacy rows, never guessed), `angular_size_arcmin` and `magnitude` (unknown by default); a partial unique index makes catalog entries (`seed:`/`catalog:` sources) unique per catalog id. Pure parsers in `AstroMath` accept RA as h:m:s, `05h35m17s` or decimal hours (degrees only with a `°` suffix) and Dec as d:m:s, `−05°23′28″` or decimal degrees, the sign applying to the whole value (`−0°30′` works). The editor formats stored values, keeps an untouched field's exact value, never changes the catalog id (the repository no longer writes it on update), offers fixed-coordinate types only and labels existing moving-type targets (ADR-010 §3; also on Home); an edit of coordinates, size or magnitude makes the source `user`. Search escapes `LIKE` wildcards. G8 has started.
> **TASK 8.2 (2026-09-23):** curated target catalog. 164 targets from OpenNGC v20260501 (the 109 Messier objects it holds — M102 is a duplicate of M101 there — plus 55 owner-approved showpieces), each with J2000 coordinates, source `catalog:openngc@v20260501`, the OpenNGC major axis (all but M40 and M73) and V magnitude where available. The asset `assets/catalog/catalog_v2.json` is generated by `tool/build_catalog.dart` from the pinned release. Owner decisions: bundle it under CC BY-SA 4.0 with `OPENNGC_NOTICE.txt`, shown on a new About & data sources page and in the licence page; Messier + ~55 showpieces; on the first run after a pre-8.2 install, rows equal to the five old seeds (id and exact coordinates) are updated in place, edited rows left alone. Seeding is versioned (`catalogSeedVersion` in preferences) and never resurrects deleted targets.
> **TASK 8.4 (2026-09-23):** ADR-011 implemented, schema v14. `EquipmentProfile` fields carry units (`focalLengthMm`, `focalRatio`, `pixelPitchUm`, `sensorWidthMm`/`HeightMm`, `resolutionWidthPx`/`HeightPx`, `rotationDeg`) plus optional `apertureDiameterMm`, a `TrackingType` {untracked, tracked, guided, unknown} and an optional `maxExposureS`; `optical_rigs` gains nullable `aperture_diameter_mm` and `max_exposure_s`; the `aperture` column keeps every value, read as N. `EquipmentLimits` documents the plausibility bounds and `resolveAperture` the N = f / D rule (1 % agreement); the editor validates every field with units, derives a read-only f/ from a diameter, edits tracking and maximum exposure, and flags a stored ratio above f/32 for review (never converted). The dormant catalog repository and its three domain models are removed.
> **TASK 8.5 (2026-09-23):** equipment seeds verified, schema v15. Owner decisions: only the verified seed ships (the four phone profiles are dropped — their makers publish only megapixels, f-number and a 35 mm-equivalent focal length); the telescope optics are labelled an example. The seed "ZWO ASI2600MC + example 72 mm f/5.6 refractor" has camera specs verified against ZWO's product page (23.5 × 15.7 mm, 6248 × 4176 px, 3.76 µm; checked 2026-09-23) and estimated optics; RAW size unknown. `camera_modules` and `optical_rigs` gain `source` and `confidence` (ADR-008 §6; legacy rows NULL); a user edit makes a changed group of specs `user`/`reported`. `SectionHeader` titles now wrap instead of overflowing.
> **TASK 8.6 (2026-09-23):** capability summary and untracked exposure guidance; PD-11 resolved (owner): NPF is shown as a labelled recommendation for untracked rigs and, marked "if untracked", for rigs of unknown tracking (never for tracked/guided); it uses the field's minimum |δ| (target |δ| − half the field diagonal, floored at 0); k is a planning setting (1–3, default 1) shown with every figure. The pure `CapabilityCalculator` gives FOV, pixel scale, NPF, the ADR-011 §5 recommended maximum sub and the target's frame fill; Home's equipment card shows them and a light block longer than the recommendation gets a warning (guidance only). Group G8 is complete.
> **TASK 9.2 (2026-09-23):** `WeatherSnapshot` (provider, model, fetch time UTC, site, hourly `WeatherHour` values for the ADR-012 variables, each nullable) and a pure `OpenMeteoForecastParser` for `timeformat=unixtime` responses (GMT+0 epochs → UTC instants; nulls/short arrays → unknown; provider errors → typed failures). `WeatherRepository.fetchSnapshot` requests exactly the night's `[startUtc, endUtc)` with `best_match`, capped at the 16-day horizon. Tested on recorded fixtures. The current weather card still uses the legacy `getCurrentWeather` path until TASKs 9.3–9.4.
> **TASK 9.3 (2026-09-23):** weather caching, freshness and failure states. `NightWeatherService` (domain, Clock-driven) uses a cached snapshot younger than 3 h, otherwise fetches and caches; out of range is its own state; a failed refresh returns the cache with its age and the failure, or unavailable without a cache — cached data is never presented as current. Freshness constants `WeatherFreshness` (aging 3 h, stale 12 h); sealed `NightWeather` state; `WeatherSnapshotStore` (SharedPreferences in the data layer) keyed by rounded coordinates, model and night. `PlannerViewModel.nightWeather` loads on the existing weather triggers; the card still shows the legacy path until TASK 9.4.
> **TASK 9.4 (2026-09-23, commit `48d7a8c`):** night-aligned weather indicators and UI. `NightWeatherSummarizer` (pure, domain) slices the forecast to sunset..sunrise of the chosen night (the whole window, labelled, for midnight sun or polar night), one slot per UTC hour with "no forecast" gaps, per-variable ranges over the covered hours, and the dew spread (temperature − dew point) against the configured margin, labelled a heuristic (CALC-32). The weather card is rewritten on `vm.nightWeather` / `vm.nightWeatherSummary`: age and model, offline/stale labels, unavailable with retry, out of range, explicit units, hour strip in the site zone, no good/bad colour bands, Open-Meteo CC BY 4.0 attribution. Owner decisions: sunset to sunrise; neutral values; the legacy path removed (`getCurrentWeather`, `WeatherConditions`/`HourlyForecast`, the non-expiring cache, `currentWeather`/`weatherError`/`dewWarning`). **Group G9 is complete.**
> **TASK 10.1 (2026-09-23, documentation only, no code changed):** ADR-013 (imaging-opportunity semantics) accepted in Part F of DECISIONS; PD-17 resolved. Owner decisions: gates are darkness and minimum altitude, with a horizon gate reserved (no horizon data in 1.0); the Moon and cloud only annotate by default, each with an optional user gate (off; thresholds 50 %); the fixed sky warning (Moon > 0.8 or Bortle ≥ 7) is replaced by annotations in TASK 10.2. Also decided: unknown never excludes, all failing reasons listed, max altitude inside windows, no composite score (ranking by usable time only); 12 worked examples as test vectors. No status changed (F-17, F-18, F-38 are implemented in TASK 10.2).
> **TASK 10.2 (2026-09-23, commit `613b32f`):** `ImagingOpportunityCalculator` (pure, domain; CALC-33) implements ADR-013: gates per 5-min grid instant (darkness, minimum altitude, optional Moon and cloud gates), windows with night-edge clip flags, all failing reasons per excluded segment, why a night has no window, max altitude inside each window, Moon and weather annotations (a missing input is a missing annotation; unknown never excludes), and a `SunTrack` shared across targets. `PlanningPreferences` gained the optional gates (off; 50 % when enabled; persisted, no Settings UI yet). `vm.imagingOpportunity`; `vm.visibilityWindows` and so the budget fit now come from it (FitAnalyzer API unchanged; identical windows while the gates are off). Not yet shown in the UI (TASK 10.3).
> **TASK 10.3 (2026-09-23, commit `e732a0e`):** opportunity presentation. Home's "Tonight for this target" card shows the usable time, a chart (darkness bands at the user's limit, highlighted windows, target and Moon altitude, minimum altitude) and a text list (each window with times, duration, max altitude and Moon/forecast facts; every excluded period with all its reasons; the no-window reason), both rendered from `vm.imagingOpportunity`; wording in `OpportunityText`. Removed: the fixed sky warning (ADR-013 §6), the decorative gradient bar (TD-034), and the culmination-based "Max Altitude" (now "Max altitude in windows"; `calculateCulminationAltitude` removed with its last caller).
> **TASK 10.4 (2026-09-23, commit `6bb596f`):** tonight's candidates. `CandidateEvaluator` (domain) evaluates every target for the chosen night with the single-target opportunity calculator, sharing a `SunTrack` and a new `MoonTrack` (Moon once per night); rows give usable time, first window start / last window end, max altitude in windows, minimum Moon separation in windows, frame fill (CALC-31) and the no-window reason; `CandidateList` sorts by a chosen column (unknown last) and filters (with a window, type, own targets). No score. `vm.tonightCandidates()` runs it on a background isolate; the new "Tonight's candidates" screen (`/tonight`, Home app bar) lists it and a tap selects the target. Owner decisions: all targets with filters (no favourites concept), a new screen, targets without a window hidden by default with a toggle. **Group G10's scope through 10.4 is done** (10.5 is the cut line).
> **TASK 11.2 (2026-09-23, commit `428f673`):** schema v16 (ADR-014 §5). `session_logs` evolved in place into the Session root: `status` (draft/planned/inProgress/completed/abandoned, CHECK, default draft), `legacy`, the night key (`evening_date`, `time_zone_id`), nullable references `site_id`/`target_id`/`rig_id` with ON DELETE SET NULL, UTC-ms lifecycle timestamps and two versioned JSON snapshot columns (`JsonMapConverter`); `capture_blocks` + `completed_frames`, `rejected_frames` (planned = `frame_count`); indexes on status, evening date and target id. Every existing log became a completed legacy session (no references guessed). `DriftLogbookRepository.updateLog` now writes only its own columns (a full-row replace would reset the v16 columns). No domain or repository API change.
> **TASK 11.3 (2026-09-23, commit `ad6609c`):** `SessionRepository` (domain) / `DriftSessionRepository` (data): create, update plan, save plan (→ planned + plan snapshot), start (execution-start snapshot, frozen), complete, abandon, results, get, list by status/night/target, most recent open session, delete — one transaction per write, the ADR-014 lifecycle enforced (`SessionStateError`, nothing written). Pure `SessionSnapshotBuilder` (versioned, unit-keyed JSON of night, site, sky darkness, target, rig, preferences, blocks, budget, opportunity, weather) and `SessionSnapshot` (unknown version = unavailable). `LogbookRepository`/`DriftLogbookRepository` removed: Home's Save calls `vm.saveSession()`; the Logbook lists every non-draft session and the legacy logs with a status label; `vm.openSession` follows references by id (labels only for legacy rows). Owner decisions: the Logbook shows all saved sessions with their status; Save = planned + snapshot; new rows write display labels into the pre-v16 text columns.
> **TASK 11.4 (2026-09-23, commit `628fda6`):** the planner works on a persisted draft session (ADR-014 §3, §6). At start the most recent open session is resumed (or a draft is created); every plan edit (blocks, target, rig, night, site) is autosaved into it through a serialized `_autosave` before the edit call returns; a plan still in preferences moves once into a new draft and the preferences plan and selected target/rig ids are removed (`PlannerStateRepository.clearPlan`). New (tonight + example plan), Duplicate for another night (Home app bar) and Open (Logbook) create or resume drafts; Save moves the current session to planned with a fresh snapshot. Owner decisions: a draft whose night has passed resumes on tonight (a future night is kept); a saved plan edited since is listed as "Planned, unsaved changes"; New = tonight + example plan; opening a completed/legacy session copies it into a new draft. The site selection and the transient position stay app-level preferences (TASK 7.1/7.3 decisions). **Group G11 is complete.**
> **TASK 12.1 (2026-09-23, documentation only, no code changed):** ADR-015 (information architecture) accepted in Part F of DECISIONS with low-fidelity wireframes and a route map in `docs/IA_WIREFRAMES.md`; PD-19 and PD-14 resolved. Owner decisions: bottom navigation Tonight · Sessions · Library · Settings; the session planner is one page opened from Tonight and from Sessions; sites live in Library with rigs and targets; PD-14 = a fixed Tonight view, no customizable dashboard. Execution is a full-screen route above the tabs (G13).
> **TASK 12.2 (2026-09-23, commit `aa748e6`):** navigation shell (ADR-015). go_router `StatefulShellRoute` with four tabs (Tonight · Sessions · Library · Settings) and kept per-tab state; Android back pops within a tab, then returns to Tonight, and leaves the app from Tonight's root. Above the tabs: `/session/:id` (the planner — Home's content), `/select/target|rig|site` (the planner's pickers), `/site/edit`, `/site/pick`, `/position`. `/tonight` is an interim root until the TASK 12.5 dashboard; candidates are `/tonight/candidates`; a Library index; metadata import under Settings (still gated). Paths are `AppRouter` constants. TD-053 recorded.
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
> **S1.1 (2026-09-25, Stage 1, commit `6a90347`):** Open-Meteo forecast requests now carry `AppIdentity.userAgent`, like Nominatim and the OSM tiles (CLAUDE.md trap 22; audit ENG-03 = RT-07 resolved). Test baseline 897.
> **S1.2 (2026-09-25, Stage 1, commit `c449c03`):** a catalog seed whose inserts fail is no longer recorded as applied: `CatalogSeeder` skips ids a catalog row already holds (the partial unique index), treats any other insert failure as a failure, logs it and leaves the version unset, so the next launch retries (audit ENG-02 = RT-02 resolved). `EquipmentSeeder` re-checked: it stores no version and lets a failure propagate, so it already retries. `SharedPrefsPrivacyPreferencesRepository` has its failure-path test (01 §G.7). Test baseline 901.
> **S1.3 (2026-09-25, Stage 1, commit `2007dc5`):** the forecast's age follows the clock (ADR-012 §6): `NightWeatherAvailable.at(now)` re-ages it through `WeatherFreshness`; `NightConditionsViewModel.checkClock()` applies it (notifying only when the freshness wording changes) and follows a default night that rolls over; `resumed()` reloads an outdated forecast (`NightWeather.isOutdated`: aging, stale or unavailable). A `NightClock` widget at the app root drives both (a one-minute tick and an `AppLifecycleListener`), so the timer stops with the tree; a snapshot re-ages the forecast before it is built, so it records the age at saving. The summary and opportunity caches now key on the forecast's snapshot (and age) instead of the state object. Audit ENG-01 = SCI-01 = RT-01 resolved. Test baseline 908.
> **S1.4 (2026-09-25, Stage 1, commit `db2702f`):** without a site, a draft's night key is the default night at the default position (`SessionNightResolver`, mean solar time), no longer the UTC calendar date; `SessionPlanViewModel.today` removed (owner decision, DECISIONS E.1; the planned device-zone rule would have broken ADR-007 §6). Audit ENG-05 = SCI-11 = RT-06 resolved. Test baseline 909.
> **S1.5 (2026-09-25, Stage 1, commit `07d55e2`):** a database this build cannot open is detected at startup, before anything reads it (`refusedSchemaVersion`), and the app shows `UnsupportedDatabaseApp` instead of a generic error with a Retry that could not succeed. Newer data: "install the latest version", nothing changed, never reset (ADR-008 §2). Below the floor: "start with fresh data" after an explicit confirmation; `resetRefusedDatabase` closes the database, keeps the file as `astroplan.sqlite.v<N>.bak`, and `main.dart` runs the bootstrap again on a fresh file. A failed reset is reported (`runWithFeedback`). TASK 3.2's UI half and audit RT-03 resolved; TD-047 fully resolved. Test baseline 919.
> **S1.6 (2026-09-25, Stage 1; RD-05 interim, commit `c0bfcb7`):** New (the planner's "+" and Tonight's "New session"), Duplicate and "Open in planner" on another session ask "Discard unsaved changes?" when the current plan has changes that are not saved (`confirmLeavingUnsavedPlan`, `lib/presentation/shared/unsaved_plan_guard.dart`). `CurrentSession.hasUnsavedChanges` tracks plan edits since the session was created, opened or saved (a site change is not an edit; a failed Save or Start keeps them unsaved); a resumed draft counts as edited unless it is the untouched example plan. Tonight's "New session" and "Open in planner" now go through `runWithFeedback` (trap 18). Drafts are still not listed or cleaned up (TASK 11.3's decision; RD-05 stays open for Stage 4). Audit RT-05/UX-12 mitigated (interim), the UX half of ENG-09. Test baseline 929.
> **S1.7 (2026-09-25, Stage 1, commit `20eff0e`):** one written form per quantity: `QuantityText` (`lib/core/utils/quantity_text.dart`, used by the domain's fit reasons and the presentation) — durations rounded to the nearest minute ("5 h 35 min", "45 min", "30 s" under a minute), exposures without a trailing .0 ("60 s", "2.5 s"; exposures were rounded to whole seconds in the tracker, results, detail and resume prompt), degrees and signed values with the typographic minus, percentages as "3 %". `OpportunityText.duration`, `formatBudgetDuration` and `FitAnalyzer`'s reason durations delegate to it; the dead `totalIntegrationTime` is removed. The session detail shows RA/Dec as h:m:s / d:m:s like the target editor. Not changed: the chart's 24-hour axis (Stage 6, UX-08) and the share text (Stage 8). Audit ENG-06 and UX-19 (the IA-independent formats) resolved. Test baseline 935.
> **S1.8 (2026-09-25, Stage 1, commit `b03dda9`):** visible text defects fixed (UX-20): the session detail's focal ratio as "f/5.6" (not the raw double), "None recorded." instead of "Notes: none", and its noon-to-noon night key labelled "Night span" instead of "Window" (UX-18, the IA-independent part); Settings no longer says optional overheads are not applied; the candidates footer no longer names a "Home"; the add-block helper wraps; the sky card's unknown text names both Bortle entry points (the card's picker and the site editor; none removed). SCI-06: the candidates' frame fill uses the planner's wording. SCI-05 (RD-03): "ISO / gain (for your records)". Test baseline 936.
> **S1.9 (2026-09-25, Stage 1, commit `705b764`):** fit status colours. "Tight" uses a new `AppPalette.caution` token (light #9A5B00, AA on white and the surface; dark orange.shade300; field mode the primary red, so it is as bright as "Fits") instead of `scheme.tertiary`, which fell back to secondary grey (UX-16). A new `FitState.needsInput` — `FitAnalyzer.analyze(inputMissing: true)`, set by `CaptureAnalysisViewModel` when the site or target is missing — is drawn in the neutral outline colour; a real no-window night stays in the error colour (UX-15(2)). The label stays "No window" (state wording is Stage 5/6). Systematic status tokens remain Stage 5. Test baseline 943.
> **S1.10 (2026-09-25, Stage 1, commit `642b235`):** the accessibility sweep now serves a full synthetic forecast (every variable, whole UTC hours), so the weather card, its ranges and the hour strip are swept in every theme at 100 % and 200 % (UX-32; a test keeps the forecast on screen). It caught the 200 % overflow (94 px per hour column, 222 px in the legend), fixed: the hour strip has no fixed 130 px height any more (it takes its text's height, `IntrinsicHeight` in a horizontal scroll) and its columns widen with the text size; a range's value keeps an 8 px gap from its label (UX-31). Test baseline 944.
> **S1.11 (2026-09-25, Stage 1, commit `b0998c6`):** UX-28 confirmed on the host and fixed: the tracker's seven controls wrapped the Material button in `Semantics(button: true, label, excludeSemantics: true)` with no tap action and no enabled state, so on Android a screen reader could not press them. The wrapper now declares `enabled` and passes the button's `onPressed` as `onTap`. A semantics test checks every control (tap action exactly when it can be pressed, button, enabled state) and that a semantics tap confirms a frame; it failed before. TalkBack on a device stays a Stage 11 check. Test baseline 945.
> **S1.12 (2026-09-25, Stage 1, commit `b6fb6c3`):** ENG-08 (= RT-04) decided with a UI-driven test (`save_start_race_test.dart`, the real app and database, no injected delays). Save, then an edit: **did not reproduce** (Drift runs the writes in the order issued; the stored session matches the planner and the edit counts as unsaved), kept as a regression test. Start, then an edit: **reproduced** — the edit landed in the session being started, so the run's blocks no longer matched its start snapshot (the planner edited a run, CLAUDE.md trap 14). Fixed: Save and Start run inside the autosave chain (`CurrentSession._inChain`), so an edit made meanwhile is written after them, to the planner's copy. The same pattern in New/Duplicate/Open is recorded as TD-058. Test baseline 947.
> **S1.13 (2026-09-25, Stage 1, commit `f179013`):** scientific labels: "Chance of precipitation (preceding hour)" and a note under the hour strip (SCI-02); night-level Moon illumination "at midnight" on Tonight, the sky card and window annotations (SCI-09). Documentation only for SCI-03 and SCI-04 (`SCIENTIFIC_INTEGRITY.md`). Test baseline 948.
> **S1.V1 (2026-09-25, Stage 1 validation fix, commit `3067658`):** TD-059 fixed. On the app's own connection (`LazyDatabase` + `NativeDatabase.createInBackground`) Drift delivers the schema refusal wrapped in a `DriftRemoteException` whose `remoteCause` is the typed `UnsupportedSchemaVersionException` (a same-group isolate, not serialized); `refusedSchemaVersion` now unwraps it, so `main.dart` shows the S1.5 recovery screen instead of falling through to the normal bootstrap. A cause that is not that type stays an error; nothing is parsed from text. The connection builder is shared (`openDatabaseConnection`) and the tests use it: v7 and v18 refused and typed, bytes unchanged, a current file opens, an unrelated failure still fails, a reset works on that connection. Test baseline 954.
> **S1.V2 (2026-09-25, Stage 1 validation fix, commit `b34c9ad`):** TD-060 fixed. The confirmed reset is one function, `confirmDatabaseReset` (`lib/data/database/database_reset.dart`), which `main.dart` runs: a newer database is refused before anything changes; the catalog seed marker (`catalogSeedVersion`, `CatalogSeeder.forgetAppliedVersion`) is forgotten, since it describes the old file and made the seeder skip the new, empty one (0 targets instead of 164); then the old file is kept as `.v<N>.bak`. Every other preference is kept; an ordinary start still never brings back deleted catalog targets. Not changed: other preferences holding database ids (selected target, rig, site) survive a reset and may match different rows in the new database, the same class as TD-056/ENG-14 (Stage 8). Test baseline 957.
> **S1.V3 (2026-09-25, Stage 1 validation fix, commit `ed628f8`):** TD-061 fixed without a schema change. `CurrentSession` remembers the id of the session holding unsaved plan edits through `PlannerStateRepository.getEditedSessionId`/`setEditedSessionId` (preference `editedSessionId`, local only): set when an edit is written, removed after a successful Save, Start, New or Open, kept after a failed Save or Start, not set by a site change (S1.6's exception). A resumed draft counts as unsaved when it carries that mark, or by the earlier content rule. So a target-, rig-, night- or block-only edit still makes New/Duplicate/Open ask after a restart; an untouched draft still does not. The dialog's Cancel closes it and leaves the user where they were (on Tonight, Tonight), matching its text "cancel and save the plan first" — clarified, not changed (validation note). Test baseline 962.
> **S1.V4 (2026-09-25, Stage 1 validation fix, commit `ea65231`):** TD-062 fixed. `SessionPlanViewModel.openSession` leaves the current session as it is live when asked to open it again while it is still editable, so the session detail's cached copy can no longer replace the planner's edits (the reproduced case reverted a 7-frame block to 20 and cleared the unsaved flag). A completed or running session with the current id still opens as a copy in a new draft (caught by two existing tests during the Task); another session's Open still asks first. Test baseline 963.
> **S2.1 (2026-09-26, Stage 2, commit `a25398c`):** the bounded metadata source (ADR-017 §4). `lib/domain/metadata/`: `MetadataSource` (length and `read(offset, count)`); `BudgetedMetadataSource` (1 MiB per file, 64 KiB per read, with a read log); typed `MetadataReadException` (`outOfRange`, `readTooLarge`, `overBudget`, `io`); `MetadataFormatRecognizer`, which recognises TIFF, FITS, XISF and JPEG from at most 16 bytes, never from a name. `lib/data/metadata/file_metadata_source.dart`: positioned `RandomAccessFile` reads (serialized, short reads typed). A test forbids `dart:io`, `dart:ffi`, `flutter/services`, `exif`, `image_picker` and `file_picker` in `lib/domain`; the prototype extractor is the only allowed exception, until S2.5. Tests: a real 4 GiB file is recognised and read at both ends with ≤ 64 KiB read. No parser and no UI yet; the prototype is unchanged.
> **S2.2 (2026-09-26, Stage 2, commit `b8d626a`):** the metadata contract as typed values (ADR-017 §2, §5; CALC-39), pure Dart in `lib/domain/metadata/`. `MetadataValue<T>` is `KnownValue` (value, raw text, `MetadataOrigin`: format, tag or keyword, location, provenance), `AbsentValue`, `UnparseableValue` or `AmbiguousValue`; `combine` keeps agreeing values and marks conflicts ambiguous. `CaptureMetadata` holds the 11 contract fields, all absent by default. `MetadataReading` is `MetadataRead` | `MetadataUnsupported` | `MetadataUnreadable` (truncated, corrupt, overBudget, io). `ExifValues` converts EXIF values:
>   - exact rationals; `/0` and non-positive values unparseable;
>   - a 35 mm-equivalent of 0 is absent;
>   - sensitivity with its kind (EXIF SensitivityType 1–3, otherwise unspecified; 0 and 65535 unparseable; never converted to gain);
>   - capture time as local wall-clock plus an offset only if one is recorded, otherwise zone unknown with no UTC instant.
> Nothing reads a file yet (S2.3).
> **S2.3 (2026-09-26, Stage 2, commit `59c9f03`):** the DNG reader (ADR-017 §2, §4.3, §8, §9). `TiffMetadataReader` reads only IFD0 and the EXIF IFD, and only the contract's tags (plus DNGVersion and the EXIF pointer):
>   - the GPS IFD, sub-IFDs, MakerNotes, serial numbers and pixel data are never followed or decoded;
>   - every offset and count is bounds-checked; more than 1,024 entries, a repeated tag or an EXIF loop is corrupt; a structure past the end is truncated;
>   - one bad value (past the end, the wrong type or count, `/0`) makes only that field unparseable;
>   - a TIFF without DNGVersion is `MetadataUnsupported(tiff)`: no support is claimed for other TIFF-based RAWs.
> `CaptureMetadataReader` recognises the format, then dispatches; everything else is unsupported (FITS waits for S2.6). A new `MetadataFormat.dng` is decided by the reader only. The fixtures are synthetic (`test/support/tiff_fixture.dart`, including a sanitized layout like the owner's phone files). The real samples are checked by a local-only test (`ASTROPLAN_METADATA_SAMPLES`; skipped otherwise): both owner DNGs matched every expected value, with 848 bytes read out of about 25 MB each.
> **S2.4 (2026-09-26, Stage 2, commit `26aff9a`; device checks M1 and M2 passed 2026-09-26):** Android document access without a copy (ADR-017 §6).
>   - **Kotlin:** `MetadataDocumentChannel.kt` (registered by `MainActivity`) runs `ACTION_OPEN_DOCUMENT` (`*/*`, openable) and returns the URI, name and size. It serves `read(uri, offset, count)` with a positioned read on the provider's file descriptor. A descriptor that cannot seek is read from the start, only within the 1 MiB budget. It works on a background thread, takes no persistable grant, and writes nothing to the cache.
>   - **Dart:** the domain `CaptureFileAccess`/`CaptureFile`, and the data-layer `AndroidCaptureFileAccess` plus `ContentUriMetadataSource`, with typed failures (cancel = null; a revoked grant, I/O, short answers and an unknown size are `io`).
>   - **TD-065:** `FileBackupService.pick` always calls `FilePicker.clearTemporaryFiles()` (consumed, cancelled or refused; a failed cleanup is logged, never masking the result). Picking is injectable for tests.
>   - **Verification:** the debug APK builds (the Kotlin compiles). Device rows M1 and M2 in `TEST_PLAN.md` are not run.
> **S2.5 (2026-09-26, Stage 2, commit `a2f42a5`; hidden; device check M1 passed 2026-09-26):** the metadata screen on the new foundation (ADR-017 §7, §10).
>   - **The screen:** `MetadataImportViewModel` (domain `CaptureFileAccess` only) picks and reads through `CaptureMetadataReader`. `MetadataImportScreen` shows every contract row with its unit and source, and "Not in the file", "Unreadable value" or "conflicting values" otherwise. Wording is in `presentation/shared/metadata_text.dart`. A picker failure goes through `runWithFeedback`.
>   - **Wiring:** `main.dart` passes `AndroidCaptureFileAccess` on Android only. Elsewhere the ViewModel is null and the screen says metadata import is unavailable.
>   - **Removed:** the prototype `metadata_extractor.dart`, `image_metadata.dart` and their test (2 tests of removed code). `exif` and `image_picker` left `pubspec.yaml` after a `grep` showed no other use; the lockfile only lost those two and their 13 transitive packages, and the desktop registrants lost `file_selector`. The domain purity test now allows no exception.
>   - **Unchanged:** `FeatureScope.metadataImport` stays false (RD-16). The privacy and Data Safety texts are checked and need no change, since nothing leaves the device.
> **S2.7 (2026-09-26, Stage 2, commit `9a0432b`):** layered recognition and a reusable EXIF extractor (ADR-017 §13; review gaps G1–G5). This is a refactor: the DNG read log is byte-identical to before, and the real samples still read 848 bytes.
>   - **`ExifStructure`** (`exif_structure.dart`): IFD0 plus the EXIF IFD, with the same bounds, loop, privacy and budget rules. It works on any `MetadataSource`, so an embedded structure is handed over as a `MetadataSourceWindow` (new: offsets stay relative to the structure; the budget's log sees absolute offsets). Origins are labelled by the container (`APP1 IFD0`, say).
>   - **`DngMetadataReader`:** a thin container (the DNGVersion gate at base 0).
>   - **`MetadataFormatReader`:** the interface; `CaptureMetadataReader.readers` dispatches by registration.
>   - **Level 1 (recognition)** is `MetadataReading.format` on every outcome, and **level 2 (extraction)** is the subclass: `MetadataRead` (with `nothingFound`), `MetadataUnsupported` (`recognized` or not) and `MetadataUnreadable` (with what was recognised).
>   - **Recognition-only formats:** HEIF (ISO-BMFF HEIF/AVIF major brands), PNG, CR2 (TIFF + `CR`, version 2), CR3 (`crx `), RAF, RW2 and ORF; no parser for any of them.
>   - **`ExifRational`/`ExifValues`** moved to `exif_values.dart`.
>   - `tiff_metadata_reader.dart` is replaced by the above.
> **S2.8 (2026-09-26, Stage 2, commit `360fd8f`):** the JPEG reader (ADR-017 §13). `JpegMetadataReader` walks the marker segments from SOI to the first SOS:
>   - fill bytes are allowed; SOS or EOI ends the walk; a bad marker, a zero length, a second SOI or more than 128 segments is corrupt; a segment past the end is truncated;
>   - the APP1 `Exif\0\0` segment goes to the shared `ExifStructure` through a `MetadataSourceWindow` (origin "APP1 IFD0" or "APP1 EXIF IFD"); every other segment is skipped by its length;
>   - the scan data is never read; a JPEG without Exif is "extracted, nothing found".
> Registered in `CaptureMetadataReader.readers`. The owner's phone JPEG (a local check) gives every contract value, including a UTC capture time from `OffsetTimeOriginal`, reading 843 bytes of 4.7 MB. The synthetic fixture is `test/support/jpeg_fixture.dart`.
> **S3.V6 (2026-09-27; S3V-01 at the ViewModel level):** `MetadataImportViewModel` no longer builds a draft of a saved rig from a match a caller holds. `rigDraft(rigId)` and `newRigDraftWithCameraOf(rigId)` are async and read the saved rigs again first (`_currentMatchFor`, now private); they return null for a rig deleted or no longer matching. `newRigDraft()` (from the file alone) reads no saved rig. The screen's `_openCurrent` takes these calls.
> **S3.V3 (2026-09-27; S3V-03, S3V-04):** `PrefilledSpec.values` holds the exact numbers behind a pre-fill's texts: a file value, an estimate, a saved rig's copied value, or a chosen conflict value. `EquipmentDraft.build` saves those exact values while the texts are unchanged, before the stored-sensor rule and before parsing text. Rounding therefore stays display-only, except for estimates, which are proposed rounded (S3.9). Copied pixel and RAW sizes also display unrounded.
> **S3.V2 (2026-09-27; S3V-02):** `SpecProvenance.unknown` (source `unknown`, no confidence) marks a field whose origin is known to be unknown. `provenanceOf` returns null for it before any group fallback. `withEditProvenance` pins it on untouched fields of a changed group whose old provenance was unknown. `EquipmentDraft` keeps it for values copied from a legacy rig. So editing one field, or copying legacy specs, never attributes the other values to the user.
> **S3.10 (2026-09-26):** `_StellariumRow` (`equipment_editor.dart`) is a label above a W × H row (TD-069); the Tracking dropdown is `isExpanded`. A clipped `TextField` raises no layout error, so `equipment_editor_fit_test.dart` measures text against box widths with Roboto loaded.
> **S3.7 (2026-09-26, Stage 3; ADR-018 §7):**
>   - `FeatureScope.metadataImport` is true.
>   - `AppRouter.metadata` is now `/equipment/import`, a root-navigator route (it was `/settings/metadata` under the Settings branch, debug-only). The Settings entry is removed.
>   - `EquipmentSelectionScreen` shows a small "Add from a photo" button (`rigs.addFromPhoto`) above "Add rig". It pushes the import, then reloads the list and the planner's selected rig on return.
>   - The metadata screen's title and intro changed to match.
> **S3.8 (2026-09-26, Stage 3; ADR-018 §4, D4):** `EquipmentCandidate.fromReading(read, fileLengthBytes:)`. The ViewModel passes the picked file's length (`MetadataSource.length`; the file is still never read whole). Only for a DNG does it become `averageRawFileSizeMB` (bytes ÷ 10⁶, `estimated`, source `metadata:dng:file-size`, within `EquipmentLimits.rawFileSizeMB`). `rigDraft` pre-fills it on a matched rig that lacks one (the matcher's `fillable`); a saved value is only ever an ordinary conflict, kept by default.
> **S3.6 (2026-09-26, Stage 3; ADR-018 §2, §6):** the import review.
>   - `MetadataImportViewModel(captureFiles, equipment)` builds the `EquipmentCandidate` after a read, matches it against the saved rigs (`EquipmentMatcher`), keeps the user's per-field "use the file's value" choices (off by default), and hands out drafts: `newRigDraft(cameraFrom:)` and `rigDraft(match)`, which uses `EquipmentDraft.forRig`.
>   - `MetadataImportScreen` shows an Equipment card (outcome, reasons, conflict switches, Open / New rig actions) above the file's values. Wording is in `equipment_import_text.dart`.
>   - Every action opens `showEquipmentEditor`, and its Save is the only write. After a save the match is refreshed, and after editing a saved rig the planner rereads the selected rig (TD-028).
>   - Reachable only through the debug-build Settings entry until S3.7.
> **S3.5 (2026-09-26, Stage 3):** the rig editor's value building moved out of the widget.
>   - `EquipmentDraft` (`presentation/shared/equipment_draft.dart`, pure) holds the initial texts, the pre-filled specs (`PrefilledSpec`: provenance, texts, whether copied from a saved rig) and the metadata identity. `build(texts, tracking)` is the one place a profile is made: parsing, `resolveAperture`, an untouched sensor text keeping the exact stored value, and `withEditProvenance`. A pre-filled value keeps its origin only while its text is unchanged.
>   - The dialog moved to `showEquipmentEditor(context, existing:, draft:)` (`screens/equipment/equipment_editor.dart`), which returns whether it saved. It shows a note under each pre-filled field (`PrefillText`).
>   - `EquipmentSelectionScreen` calls it; Add/Edit look and behave as before.
> **S3.3 (2026-09-26, Stage 3; ADR-018 §6):** `EquipmentMatcher.match(candidate, rigs)` (pure) gives an `EquipmentMatch`: an outcome (`MatchKind`: same rig, likely, same camera with other optics, cropped or binned mode, ambiguous, none) and the related `RigMatch`es, each with `MatchReason`s, per-field `FieldConflict`s (saved and imported values with both provenances; `savedIsVerified`) and `fillable` unknown specs. Nothing is merged or written.
> **S3.4 (2026-09-26, Stage 3; ADR-018 §5; schema v18):** per-field equipment provenance. `EquipmentSpec` names the six specs that carry their own pair, and `SpecProvenance` is the pair (`spec_provenance.dart`). `EquipmentProfile` gains `specProvenance`, `metadataMake`/`metadataModel` and `provenanceOf`. In `withEditProvenance`, a changed spec becomes `user`; when its group changes, an untouched spec keeps the group's old provenance as its own pair; a pair given with the edit is kept; the identity is kept. `DriftEquipmentRepository` maps the new columns. The manual editor's behaviour is unchanged.
> **S3.2 (2026-09-26, Stage 3; ADR-018 §4):** `lib/domain/equipment_import/` (pure Dart), level 3 of ADR-017 §13. `EquipmentCandidate.fromReading(MetadataRead)` gives, per `EquipmentProfile` field, a `CandidateField`: `ProposedField` (value, source id, `SpecConfidence`, origins) or `UnknownField` (a `CandidateGap`). It also carries `EquipmentEvidence` (the raw identity strings, f₃₅ and dimensions) for S3.3's matching. `SensorGeometryEstimate` is CALC-40. Nothing here is persisted.
> **S3.1 (2026-09-26, Stage 3; ADR-018 §3):** `CaptureMetadata.imageDimensions` (`ImageDimensions`: width and height as stored, plus long/short sides). `ExifStructure` keeps six more tags: NewSubfileType, ImageWidth, ImageLength and DefaultCropSize in IFD0; PixelXDimension/PixelYDimension in the EXIF IFD. The rule depends on the format label: a DNG uses IFD0's main image only (`DefaultCropSize` first); JPEG/HEIC combine IFD0 with the EXIF IFD. Sub-IFDs, the GPS IFD and pixel data are still never followed.
> **S2.9 (2026-09-26, Stage 2, commit `bb28452`):** the HEIF/HEIC reader (ADR-017 §13; S2.R2 §7, approved by the owner). `HeifMetadataReader` walks the top-level ISO-BMFF boxes by header, reads `meta` once (≤ 64 KiB), parses `pitm`, `iinf`/`infe`, `iloc` (v0–2, construction methods 0 and 1) and `iref cdsc`, picks the Exif item linked to the primary item, honours `exif_tiff_header_offset`, and hands the TIFF structure to the shared `ExifStructure`. No image data is read. The owner's HEIC (a local check) gives every contract value with its offset, reading 4,051 bytes. Device check M3 passed on the owner's phone the same day.
> **S2.V4 (2026-09-26, Stage 2, commit `d8e792c`), after the repeat independent validation:**
>   - the HEIF `iloc` parser accepts at most `HeifMetadataReader.maxExtents` (16,384) extents over all items, and beyond that it is `corrupt` (TD-067). Extents with all-zero field sizes occupy no bytes, so the byte budget alone did not bound the work;
>   - recognition splits the ISO-BMFF image brands three ways:
>     - `heif`, read: `heic`, `heix`, `heim`, `heis`, `mif1`;
>     - `avif`, recognised only: `avif`, `avis`;
>     - `heifSequence`, recognised only: `msf1`, `hevc`, `hevx`, `hevm`, `hevs`;
>   - this follows the owner's S2R-02 ruling (DECISIONS E.1).

---

# Part A — Design intent (Phase 0 baseline, preserved verbatim)

*Source: `git show 900b82a:docs/ARCHITECTURE.md`.*

## Selected Stack

- Flutter / Dart
- Provider and ChangeNotifier ViewModels
- go_router for centralized navigation
- SQLite via Drift
- Android-first implementation with later iOS support

## Layering

AstroPlan should keep a conservative architecture:

```text
Presentation
  -> ViewModels
  -> Repositories
  -> Services / Data Sources / Local DB / APIs
```

Domain calculations should remain independent from Flutter UI code. Platform
specific behavior should be isolated behind interfaces or adapters.

## Source Layout

The current source tree uses:

- `lib/core/` for shared utilities and theme primitives.
- `lib/domain/` for models, repositories, and services.
- `lib/data/` for Drift database, concrete repositories, and seeders.
- `lib/presentation/` for navigation, screens, widgets, and ViewModels.
- `test/` for unit, repository, database, and widget tests.

This broadly follows the intended architecture, but feature boundaries are not
yet fully aligned with the roadmap phases.

## Navigation

Navigation should remain centralized in `lib/presentation/navigation/`.
Screens should not create scattered, arbitrary navigation flows.

## State Management

Use Provider and explicit ViewModels. Do not introduce Riverpod, Bloc, Redux, or
another state-management ecosystem unless a documented need emerges and the
project owner approves the architectural change.

## Database Boundary

Drift tables and generated Drift row classes belong in the data layer. Widgets
and ViewModels should depend on repository interfaces and domain models, not
directly on Drift APIs.

## Scientific Calculation Boundary

Calculation services should be pure Dart where practical and must include:

- input units;
- output units;
- formula/reference;
- assumptions;
- valid input ranges;
- edge-case handling;
- tests.

## Scope Guardrails

Do not introduce full planetarium, AR sky navigation, camera control, live
camera preview, or heavy GPU rendering into the core app without explicit
approval.

## Additional architectural rules in force (from `.agents/rules/01-architecture.md` and `CLAUDE.md`)

- Keep Flutter UI separate from ViewModels, repositories, data sources, and
  domain calculations.
- Keep Drift APIs in the data layer; expose domain models through repository
  interfaces.
- Keep astronomical and astrophotography calculations independent from Flutter
  widgets.
- Keep platform-specific code behind interfaces/adapters.
- Use Provider/ViewModels unless a documented architectural decision approves a
  different approach.
- Offline-first: core features (equipment, targets, calculations, logs) must work
  offline; external APIs (weather, geocoding) enrich but are not strictly required.
- Do not place non-trivial astronomy or capture calculations directly inside
  widgets; business logic must be deterministic and testable.

---

# Part B — CURRENT ARCHITECTURE (Actual, verified)

## B1. Overview and data flow

> **Since TASK 12.3 (commits `6c703f3`, `03c0b34`, `64caa58`)** the diagram below is historical. Screens and widgets watch
> screen-scoped ViewModels (`lib/presentation/viewmodels/`): `SiteViewModel`, `SettingsViewModel`,
> `SessionPlanViewModel` (listens to the site), `PlanLifecycleViewModel` (S6.1: restore, open,
> new, copy, save, start; not a notifier), `NightConditionsViewModel` (site + plan + settings),
> `CaptureAnalysisViewModel` (all four; Save and Start through the lifecycle), `StartupViewModel`
> (load order: site, settings, plan through the lifecycle, conditions), plus `GearViewModel`, `TargetsViewModel`, `SessionsViewModel` and `ThemeViewModel`.
> They take domain interfaces only; `AppViewModels` (`lib/presentation/app_view_models.dart`)
> composes them and `main.dart` passes the concrete repositories and services (the only
> place that knows SharedPreferences, HTTP, Geolocator and the time-zone plugin). No screen
> calls a repository any more, except the gated metadata import screen (G17).

```text
                     ┌────────────────────────────────────────────────────────────┐
  Screens/Widgets ──►│ PlannerViewModel  (513 lines; ChangeNotifier)              │
  (Home, Sky, Chart, │  selection · session date · location · weather · plan ·    │
   Weather, Plan)    │  thresholds · derived calculations · session load          │
        │            └───────┬───────────┬───────────────┬──────────────┬─────────┘
        │                    │           │               │              │
        │              domain services  repository     SharedPreferences  direct: http (Nominatim),
        │              (pure Dart)      interfaces      (plan, ids, keys)  (GPS: LocationService), concrete
        │                    │           │                                LightPollutionRepository
        │                    │           ▼
        │                    │     Drift repositories ──► SQLite (schema v9)
        │                    │     OpenMeteoWeatherRepository ──► Open-Meteo + prefs cache
        │
        ├─► Equipment / Target screens ─► repository interfaces directly (no ViewModel)
        ├─► Logbook screen, Home "Save Session" ─► LogbookRepository directly
        │   *(since TASK 11.3: Save → `PlannerViewModel.saveSession` → `SessionRepository`; the Logbook reads `SessionRepository`)*
        ├─► Location picker ─► PlannerViewModel + Geolocator directly + OSM tiles
        ├─► AltitudeChartWidget ─► VisibilityCalculator.calculateAltitudeCurve directly
        │   (target/lat/lon/date passed in from Home; no PlannerViewModel reference,
        │   no CustomPainter astronomy) *(updated TASK 2.3)*
        └─► Metadata screen ─► ImagePicker + MetadataExtractor (domain service) directly
```

## B2. Source layout and size

| Area | Files | Lines (non-generated) | Contents |
| --- | --- | --- | --- |
| `lib/core/` | 5 | 222 | `lib/core/config/feature_scope.dart`, theme (`AppTheme`, `AppColors`, `AppSpacing`), `lib/core/utils/astro_math.dart` |
| `lib/domain/` | 22 | 1,162 | models (11), repository interfaces (6), services (5) |
| `lib/data/` | 14 | 1,079 | Drift database + 4 table files, 7 repositories (5 Drift, 1 Open-Meteo HTTP, 1 concrete `LightPollutionRepository`), 2 seeders |
| `lib/presentation/` | 16 | 3,224 | navigation, 6 screens, 5 widgets, 2 shared widgets, 2 ViewModels |
| `lib/main.dart` | 1 | 79 | composition root |
| `lib/data/database/app_database.g.dart` | 1 | 7,919 | generated (Drift) |
| `test/` | 21 | 1,757 | 71 tests |

The largest files are `equipment_selection_screen.dart` (591), `planner_viewmodel.dart`
(513), `target_selection_screen.dart` (336) and `altitude_chart_widget.dart` (311).

## B3. Composition root and dependency injection (`lib/main.dart`)

*(Superseded 2026-09-26, S1.V6/X2: S1.V1 `3067658` and S1.V2 `b34c9ad` resolved TD-059/060; S1.5 is complete. Kept as history:)*
**Validation correction (2026-09-25, `4e653fb`; TD-059/060):** startup's new
refusal branch exists, but the production background Drift connection wraps the
exception, bypassing `refusedSchemaVersion`'s typed catch. The generic bootstrap
failure remains reachable instead of recovery. A replacement database can also
miss its catalog when preferences retain the applied seed version. Intended:
ADR-008 recovery with a working seeded replacement. Actual: the independent
probes fail; S1.5 is not complete. See proposed S1.V1/S1.V2 in the validation.

- `main()` constructs `AppDatabase`, five Drift/HTTP repositories, and
  `LightPollutionRepository` **by hand** (no DI container), then `runApp`s a
  `MultiProvider`.
- Registered providers: `Provider<AppDatabase>` (**never read anywhere** in `lib/`
  or `test/`), `Provider<TargetRepository>`, `Provider<EquipmentRepository>`,
  `Provider<WeatherRepository>`, `Provider<LogbookRepository>` *(replaced by `Provider<SessionRepository>`, TASK 11.3)*,
  `Provider<LocationRepository>`, `Provider<LightPollutionRepository>` (concrete
  type), `ChangeNotifierProvider(PlannerViewModel)`, `ChangeNotifierProvider(ThemeViewModel)`.
- `EquipmentCatalogRepository` is **not** registered.
- `PlannerViewModel` is built with positional arguments
  `(TargetRepository, EquipmentRepository, WeatherRepository, LocationRepository,
  LightPollutionRepository)`; `ChangeNotifierProvider(create:)` is lazy, so it is
  constructed on the first `context.watch` (the first frame).
- **Seeding** (`CatalogSeeder`, `EquipmentSeeder`) runs in `Future.microtask`
  *after* `runApp`, unawaited (`main.dart:53-60`); nothing orders it before the
  ViewModel's first database read (DEV-A5, TD-002).
- No dependency-injection framework is needed or justified (CLAUDE.md rule 6).
  (The previous audit suggested `get_it`; that is **not** recommended.)

## B4. State management (Provider / ChangeNotifier)

*(Superseded 2026-09-26, S1.V6/X2: S1.V3 `ed628f8` and S1.V4 `ea65231` resolved TD-061/062; TD-063 is separate, in Stage 8. Kept as history:)*
**Validation correction (2026-09-25, `4e653fb`; TD-061/062):** S1.6's dirty flag
is in memory; restart infers it from saved status/example blocks, missing a
never-saved draft edited only in target/night. Same-ID Open also bypasses the
guard while reapplying cached detail data and clearing the flag. Intended:
preserve unsaved edits on replacement. Actual: these two paths evade the
interim safeguard. The normal guard and Save/Start ordering remain implemented.

> **Since TASK 12.3** `PlannerViewModel` no longer exists; the table below records what it
> owned. Where each responsibility went: bootstrap to `StartupViewModel`; location, sites,
> geocoding and Bortle to `SiteViewModel`; thresholds to `SettingsViewModel`; selection, night,
> sessions and the capture plan to `SessionPlanViewModel` (with `CurrentSession`,
> `SessionReferenceResolver`, `ExampleCapturePlan`); weather, timeline, Moon, opportunity and
> candidates to `NightConditionsViewModel`; budget, fit, capability and the Save snapshot to
> `CaptureAnalysisViewModel`. Tests build the same graph through `PlannerHarness`.

> **Since S6.1 (2026-09-27)** the plan's responsibilities are split in two (ENG-16: the ViewModel
> had reached its 300-line cap), with no behaviour change:
> - **`SessionPlanViewModel`** owns the plan's **contents**: the night, target, rig and blocks, their
>   edits, the site listener and the autosave (`CurrentSession.write`), and the read-only state the
>   screens watch (`activeSession`, `hasUnsavedChanges`, `autosaveFailure`, `idle`). It gives the
>   lifecycle a narrow seam: `currentPlan()`, `nightKey`, `replaceContents`, `replaceNight`,
>   `restoring` (a restore or open is not a plan edit) and `markChanged`.
> - **`PlanLifecycleViewModel`** owns **which plan** the planner works on: `load` (restore, the
>   defaults, resume, adopting a copy of a run), `openSession`, `newSession`, `duplicateForNight`,
>   `savePlan` and `startPlan`, with `SessionReferenceResolver` and `ExampleCapturePlan`. It holds no
>   state of its own and does not notify; the plan notifies for it. It is provided with a plain
>   `Provider`; screens `context.read` it for New, Duplicate and Open.
> - **`CurrentSession`** is created once in `AppViewModels` and shared by both (it was built inside
>   the plan ViewModel). `StartupViewModel` loads through the lifecycle, and
>   `CaptureAnalysisViewModel.saveSession`/`startSession` save and start through it.
> - Sizes after the split: 220 and 167 physical lines (the cap is 300; S6.1's target was 250).

> **Since S6.2 (2026-09-27)** the planner (`home_screen.dart`) is titled "Plan"; `_PlanIdentity`, a
> strip under the app bar, shows the target, the night and `PlanStateLabel` and wraps at large text.
> `_PlanMenu` (⋮, `planner.menu`) holds New plan, Copy to another night (`pickNight`) and, for a saved
> plan with a site, target and rig, Track live (`planner.start`, interim until P8.4). The bottom bar
> holds only Save plan (`planner.save`). `CurrentSession.startNew` and `adopt` run inside `_inChain`,
> so every switch of the current session (New, Copy, Open, Save, Start) is serialized with the
> autosaves (TD-058 resolved).

> **Since S6.3 (2026-09-28; U1, W1, V3; S4-DEF-04 = R)** leaving a plan asks Save · Discard · Cancel
> (`askBeforeLeavingPlan`, `lib/presentation/shared/unsaved_plan_prompt.dart`, over S5.8's
> `askUnsavedChanges`; the S1.6 guard is gone). New plan, Copy, Tonight's New and Open pass the
> answer to `PlanLifecycleViewModel` as `discard:`. In `CurrentSession`:
> - every switch goes through `_switch`, in the autosave chain. The replaced session, when it is a
>   never-saved draft, is deleted (`SessionRepository.deleteDraft`) if the user discarded it or
>   never edited it; a saved plan is never deleted there;
> - `revertSavedChanges()` runs first on Discard: a Saved · changed plan goes back to its plan
>   snapshot (`SessionRepository.revertToSaved`, through the pure `SavedPlanReader`); the snapshot
>   and `plannedAtUtc` are unchanged. It is refused with `SavedPlanUnavailable` (nothing changes, and
>   `FailureText` says why) when the snapshot is unreadable or names a site, target or rig that no
>   longer exists;
> - `startNew(unsaved: true)` marks a copy as unsaved (W1). `SessionPlanViewModel` writes a site
>   change as an edit on a saved plan (V3), not on a never-saved draft.

> **Since S6.5 (2026-09-28)** two detail routes sit above the tabs, `AppRouter.nightMoon` (`/night`,
> `NightMoonScreen`) and `AppRouter.weather` (`/weather`, `WeatherDetailScreen`), both on
> `DetailScaffold` and in the accessibility sweep. The planner's full weather card and the night and
> Moon parts of `SkyDarknessWidget` moved there (`NightTimelineSection`, `MoonSection`,
> `WeatherForecastWidget` unchanged); the planner keeps a summary row for each (`NightSummary`,
> `WeatherText.summary`) and `SkyDarknessWidget` keeps only Bortle and SQM. The night timeline now
> carries the dark span at the user's limit (`NightTimeline.darkAtLimit`, CALC-41), built by
> `NightConditionsViewModel.nightTimeline` and cached per night and limit. **`CandidatesViewModel`**
> (a plain `Provider`) took `tonightCandidates()` out of `NightConditionsViewModel`, which reads the
> forecast for it through the public `opportunityWeather`; the conditions ViewModel is 274 lines.

> **Since S6.6 (2026-09-28; ADR-019 §6)** the planner's body is one list, never an empty-state page:
> `PlanStatus` (`widgets/plan_status.dart`: `StatusBlock` over `fitAnalysis` and `captureBudget`,
> with `FillWindowAction` moved out of the budget summary), `ContextLine` with `pickNight`, the
> target and `TonightOpportunityWidget`, `CapturePlanWidget` (its outputs no longer show the fit),
> the conditions rows, and the rig card. A missing site, target or rig gives a neutral status and a
> `_ChooseCard` in its section. `InfoRow` uses the text roles. Where each value went: the fit, its
> reason, its end and fill/trim → the status; "Session Date" → the context line; the rest stays in
> its section (the rig's rows reordered, "Current Altitude" renamed "Altitude now").

> **Since S6.7 (2026-09-28; ADR-019 §7)** the planner's technical depth is in `CollapsibleSection`s
> keyed by `PlannerSections` (remembered by `DisclosureViewModel`). Where each value went: the
> budget's lines → Budget details (`CaptureBudgetSummary`, keyed `budget.*`); the √N help → its own
> section above the √N values, which stay visible; the assumptions → a section instead of the
> `ExpansionTile`; the rig's focal length, focal ratio, sensor and tracking → Specifications, below
> the card's tappable part (`PlannerSummaryCard.below`); Bortle, SQM and the map link →
> `SkyDarknessWidget`'s section (the map link moved out of `home_screen.dart`). Storage, the
> capability warnings and every "never hidden" item stay visible; the status shows the integration
> in every state. Summaries are pure static functions beside their widgets.

> **Since S6.8 (2026-09-28; RD-04, ADR-019 §3 "Defaults")** `PlanLifecycleViewModel.load()` selects
> only a stored target and rig (no M42 or first-rig fallback) and leaves the capture plan empty;
> `newSession()` keeps the site and the rig, clears the target and starts with no blocks.
> `SessionPlanViewModel.useExamplePlan()` is "Start from the example plan" (an edit; the example
> badge until the next block edit). `CurrentSession.resume()` treats an empty draft like the
> untouched example: not edited. `EquipmentProfile.isExample` recognises the shipped rig (every
> optics spec's provenance still `seed:`); `ExampleText` (`presentation/shared/example_text.dart`)
> words the examples. Tests choose their plan through `PlannerHarness.choosePlan()` (the same three
> edits a user makes).

> **Since S6.9 (2026-09-28; RD-09 M + S1, RD-08 T3)** capture-block rows are worded by the pure
> `BlockText` (`presentation/shared/block_text.dart`) from the block and its `BlockBudget`; Delete
> goes through `DeleteButton` and `showUndo`, and Undo calls `SessionPlanViewModel.restoreCaptureBlock`
> (the identical block at its index). *Since S6.V1 (TD-082)* the delete runs through
> `deleteBlockWithUndo` (`widgets/capture_plan/blocks_undo.dart`), which records it as a `BlocksEdit`:
> the Undo owns that block only, so edits made since stay; the example badge returns only while
> `BlocksEdit.isCurrent` holds, and a replaced plan (`BlocksEdit.inPlan` fails) is left alone with
> "Not undone". `SessionPlanViewModel.effectiveTracking`
> is the tracking the guidance uses: the rig's default until Stage 7 adds the plan's override; the
> rows read unknown tracking from `RigCapability.recommendationIsConditional`. *Since S7.1
> (RD-08 = T3)* the plan holds `trackingOverride` (a plan edit, autosaved in
> `session_logs.tracking_override`; never written to the rig). The pure `EffectiveTracking.of`
> (`domain/models/tracking_type.dart`) gives the effective value and its source: the override, else
> the rig's default, else unknown. `CaptureAnalysisViewModel.rigCapability` passes it to
> `CapabilityCalculator.evaluate(tracking:)`; the snapshot builder records it
> (`tracking` = {effective, source}); `SavedPlanReader` restores it; `PlanLifecycleViewModel._apply`
> reads a session's own; Copy and Track live's copy carry it; New plan starts without it. The
> planner's `PlanTrackingRow` (under the rig card) and S6.9's "Set the tracking for this plan"
> open `pickPlanTracking` (`widgets/plan_tracking.dart`). The night resolution moved into
> `SiteViewModel.nightAt` (the site owns position, zone and clock) to keep `SessionPlanViewModel`
> under its cap. Where each value
> went: the "Inputs", "Outputs" and "Sequence Plan" headings are gone (the planner's "Capture plan"
> header remains); the row's frame type, filter, count, exposure and calibration placement are in
> its text; the capability warning stays on its row.

> **Since S6.10 (2026-09-28; P6.9)** "what fits" on a row comes from `FitResult.unplacedFramesByBlock`,
> `CaptureAnalysisViewModel.fillWindowFrameCount` (`FitAnalyzer.maxFramesForBlock`) and the new
> `fillWindowSpareFrames` (that count minus the planned one), worded by `BlockText.whatFits`; nothing
> is shown unless the fit measured the plan. Storage's note is `CaptureBudgetSummary.storageNote`
> (the rig, and its RAW size's per-field provenance). `ChangeMark` (shared) marks the status and
> Budget details' summary when their values change. The storage trace (case C, an unknown input)
> was re-verified: the rig's RAW size reaches `CaptureBudgetCalculator` unchanged; no calculation or
> wiring defect.

> **Since S6.11 (2026-09-28; P6.10, CALC-42)** each light group's graph reads `LightGroup.gainCurve`
> (`StackingGainCurve`, pure domain) from the ViewModel's budget; `StackingGainGraph` and its
> `StackingGainPainter` only draw those points. No new dependency.

> **S6.12 (2026-09-28; P6.11, UX-08): the night and opportunity timeline.**
> *Inventory first* (the chart and window list at `ea899a6`): **kept**, because they work: one
> `ImagingOpportunity` renders both the chart and the list, so they cannot disagree; the darkness
> bands come from the opportunity's own Sun samples at the user's limit; the windows, the target's
> and Moon's altitude, the minimum altitude and "now" come from the domain; there is a text
> alternative and a legend; the window list keeps every excluded period with its reasons. **Fixed**
> (UX-08): hand-formatted 24-hour `HH:mm` labels at odd minutes (the night starts at mean solar
> noon); altitude and time labels painted over the curves; 288 per-sample rectangles leaving seams;
> field mode's near-identical band reds; no sign of the planned capture. **Kept as a trade-off**:
> the noon-to-noon span (ADR-007's night; the audit calls it context vs focus).
> *Evolved, not joined by a second chart:* `AltitudeChartWidget` is the one primitive, over one
> mapping, `TimelineData` (`widgets/timeline_data.dart`): the bands merged from the samples (no
> seams) with their edges drawn (distinguishable in field mode), the windows exactly as the
> opportunity's (no time across a gap), the fit's end (`FitResult.endUtc`, only when the fit
> measured the plan; no per-window placement is drawn, since the fit does not expose one), "now"
> inside the night, and whole-hour ticks on the site's wall clock (`hourTicks`, half-hour zones and
> DST included), labelled by `NightTimeFormatter.clockTime` (the device's 12- or 24-hour setting).
> `TimelinePainter.geometry` puts the altitude labels in a left gutter and the time labels below the
> plot, choosing every 1, 2, 3, 4, 6 or 12 hours so they never touch, at any text size. A
> `TimelineDensity` (`full` in the planner, `compact` for a summary; S6.13 decides whether Tonight
> uses it). The text alternative names the windows with their times, the usable time and the
> capture's end.

> **Since S6.13 (2026-09-28; ADR-019 §5)** Tonight is `_Context` (`ContextLine` + `pickNight` →
> `SessionPlanViewModel.setEveningDate`) → `_RunCard` → (Stage 8's slot) → `_PlanCard` (`StatusBlock`
> fed by `PlanStatus.missingInput`, now shared with the planner, and `fitAnalysis`; `PlanStateLabel`)
> → `_NightCard` (the Dark row from `NightTimeline.darkAtLimit`; the Moon row from
> `NightConditionsViewModel.moonDuringDark`, CALC-43) → the secondary actions. Where each value went:
> the site card → the context line; "Night of …" → the context line's night; Tonight's status words →
> `PlanStateLabel`; "Fits"/reason/"Usable time tonight" → the `StatusBlock` headline and reason; the
> rig line stays (with the example label), "Choose rig" → the status's Choose a rig; Start → gone
> (Track live in the planner's ⋮); the Moon's up-intervals → Night & Moon only. The compact timeline
> is not used here (the choice and its reason are in `tonight_home_screen.dart`).

> **Since S6.14 (2026-09-28; RD-10 = O1)** `CandidateList.sort`'s `usableTime` order breaks ties by
> `frameFillFraction` (descending, unknown last) before the name; every other order is unchanged.
> The candidates header names the order in use (`_orderLabels`).

> **Since S6.16 (2026-09-28; the owner's corrective pass, DECISIONS E.1 "Stage 6 corrective pass
> decided"; ADR-019 §6 as amended)** the planner's list is `PlanStatus` → `ContextLine(framed)`
> (`planner.context`) → the target card (`planner.target`) → the rig card (`planner.rig`) →
> `CapturePlanWidget` → "Tonight for this target" (`TonightOpportunityWidget`, its heading now the
> planner's section heading, shown with a site and a target, or the no-site card) → the conditions
> (Night & Moon, Weather, the zone rule, `SkyDarknessWidget`). Where each value went: the chart and
> the windows moved from under the target to after the capture plan; the rig moved from last to
> above the capture plan; nothing else moved or was removed. The section headings use the scale's
> `titleMedium`. `PlanStatus.missingInput` returns a `MissingInput` record with the input's own
> reason (TD-075), shared by the planner and Tonight; the status card carries a status-colour edge
> (`planner.statusMark`) and `StatusBlock`'s key numbers are label-over-value pairs. Tonight: the
> page's own title (`tonight.title`, `headlineSmall`; the app bar keeps the actions), the context
> on a card, `_PlanCard` with "Your plan" in `titleMedium` (TD-077), Open planner always its
> `FilledButton`, and, without a target, the two target rows with a line each (TD-080; the
> secondary actions then leave out What can I image tonight?). The √N graph labels the plan's point
> and the comparison end (`StackingGainGraph.planLabel`/`comparisonLabel`, `PlanPointSwatch`;
> TD-076). Night & Moon's sections no longer repeat the summary: `NightTimelineSection` ("Sun and
> twilight") without the dark span, `MoonSection` ("Moon") without the up-times (TD-078).
> **Undo for one-tap block changes (TD-079):** `SessionPlanViewModel.recordBlocksEdit` runs a change
> and returns a `BlocksEdit` (`viewmodels/blocks_edit.dart`: the blocks and example badge before, the
> block instances after, the lifecycle's contents generation and the session);
> `undoBlocksEdit` restores them through the normal autosave only while `BlocksEdit.isCurrent`
> holds. `editBlocksWithUndo` (`widgets/capture_plan/blocks_undo.dart`) wraps Fill/Trim, a block
> edit and "Start from the example plan" with S5.8's `showUndo`; nothing outlives the message. The
> block dialog (`showCaptureBlockDialog`) now returns the block and changes nothing itself.

Two `ChangeNotifier`s exist: `PlannerViewModel` and `ThemeViewModel`
(`isFieldMode` boolean, in memory only, not persisted). Screens also keep local
`StatefulWidget` state (lists loaded from repositories, dialog controllers).

### `PlannerViewModel` — actual responsibilities
(`lib/presentation/viewmodels/planner_viewmodel.dart`, 513 lines)

| # | Responsibility | Where |
| --- | --- | --- |
| 1 | **Bootstrap / hydration** in `_init()`/`_loadInitialState()`, started from the constructor, awaitable via `ready` *(updated TASK 1.1)*: reads shared preferences, active location, capture plan, thresholds, selected target/equipment; a failure sets `hasBootstrapError` (retry via `retryBootstrap()`) instead of throwing unguarded; weather is **not** awaited here any more — it loads after the first frame *(updated TASK 1.2)*; fires reverse geocoding | `:81-172` |
| 2 | **Selection state** — target and equipment, mirrored to shared preferences | `:330-342` |
| 3 | **Session night** and **session loading** *(updated TASK 2.4)*: `sessionNight` resolves a `SessionNight` (default via `SessionNightResolver.resolveDefault(_clock.nowUtc(), ...)`, or a picked `CalendarDate` via `.forEveningDate(...)`; null without a site, ADR-007 §9); `setEveningDate`, `newSession` (clears the pick), `loadSession` (maps a legacy instant to its device-local evening date), `_activeSessionLog`; target/equipment re-matched from a log by **name** | `:sessionNight/eveningDate/setEveningDate/loadSession/newSession` |
| 4 | **Location** — coordinates; `setLocation` (persists, and overwrites the active saved profile); `useCurrentLocation` (through the injected `LocationService`; *updated TASK 1.1*); default London until a position is obtained | `:216-280` |
| 5 | **Reverse geocoding** — *(updated TASK 7.2)* `_reverseGeocode` calls the injected `ReverseGeocoder` (default `NominatimReverseGeocoder`); a failure leaves `locationName` null and is logged; an answer for a position the user has left is ignored; `locationNameAttribution` carries the required attribution. *(Was: raw `http.get` to Nominatim, errors swallowed.)* | `:_reverseGeocode` |
| 6 | **Light pollution / Bortle** — `_fetchBortle` (calls the concrete repository), `setBortleClass`, default 4 | `:189-214,344-364` |
| 7 | **Weather** — fetch and refresh via a shared `_fetchWeather()`; loaded post-first-frame, not on the bootstrap path; `weatherError` set on failure *(updated TASK 1.2)*. *(Since TASK 9.4: `_fetchWeather()` loads only `nightWeather` through `NightWeatherService`; failures are `NightWeather` states; `currentWeather`/`weatherError` removed.)* | `:279,324-335` |
| 8 | **Capture plan** — add/update/remove/reorder blocks; hand-written JSON persistence; default 3-block plan | `:287-328` |
| 9 | **Thresholds** — minimum altitude (clamped 5–60°), dew-point margin, both persisted | `:151-161,366-371` |
| 10 | **Derived calculations exposed to the UI** (recomputed on every access, no caching): `nightTimeline`, `visibilityWindows`, `lunarIllumination`, `skyDarknessWarning` *(removed TASK 10.3)*, `dewWarning` *(removed TASK 9.4; replaced by `nightWeatherSummary`)*, `imagingOpportunity` *(TASK 10.2; cached per input; `visibilityWindows` derives from it)*, `tonightCandidates()` *(TASK 10.4; async, background isolate)*, `currentAltitude`, `maxAltitude` *(removed TASK 10.3; see `imagingOpportunity`)*, `npfExposure` (unused), `totalIntegrationTime`, `estimatedRequiredTime`, `sessionFeasibility`, `estimatedStorageMB`, `relativeStackingGain`, `pixelScale` | `:413-512` |

State fields: `_isLoading`, `_bootstrapError`, `_usingDefaultLocation` *(both added
TASK 1.2)*, `_selectedTarget`, `_selectedEquipment`, `_currentWeather`,
`_weatherError` *(added TASK 1.2)*, `_locationName`, `_pickedEveningDate`
(a `CalendarDate?`, replacing `_sessionDate`; null = use the default night,
*updated TASK 2.4*), `_clock` (a `Clock`, default `SystemClock`; *added TASK 2.4*),
`_latitude`/`_longitude` (default London), `_captureBlocks`, `_bortleClass`
(default 4), `_dewPointThreshold` (default 2.0), `_activeSessionLog`, `_minAltitude`
(default 20.0). The `captureBlocks` getter exposes the internal mutable list.

*(Updated TASK 7.2: `package:http` is no longer imported; the concrete
`NominatimReverseGeocoder` is built as the constructor default for the injected
`ReverseGeocoder`, like `GeolocatorLocationService`.)* Direct imports that skip the intended layers: `package:http`,
`package:shared_preferences`, the concrete
`lib/data/repositories/light_pollution_repository.dart`, and the concrete
`lib/data/services/geolocator_location_service.dart` (used only as the constructor
default for the injected `LocationService`) (DEV-A1). `package:geolocator` itself is
no longer imported by the ViewModel *(updated TASK 1.1)*.

## B5. Domain layer (`lib/domain/`)

**Metadata (S2.1, ADR-017):** `lib/domain/metadata/` holds the bounded source interface, its byte budget and format recognition, in pure Dart. Since S2.7 it has a layered shape: recognition (`metadata_format.dart`) → a `MetadataFormatReader` per container (`dng_metadata_reader.dart`) → the shared `ExifStructure` → the contract (`capture_metadata.dart`). A new EXIF-bearing format is one container reader. Its only data-layer implementation so far is `lib/data/metadata/file_metadata_source.dart`; the Android content-URI source comes in S2.4. The prototype `services/metadata_extractor.dart` still does its own I/O until S2.5 removes it (test-enforced allowance).

**Services (calculation logic; no Flutter imports):**
`AstronomicalEngine` (JD, GMST, LST), `VisibilityCalculator` (LHA, altitude, Sun
altitude, lunar illumination, night timeline, visibility windows),
`OpticalCalculator` (EFL identity, pixel scale, FOV, relative stacking gain,
storage, NPF), `SessionCalculator` (feasibility; plus **dead** `estimateTotalDuration`),
`MetadataExtractor` (EXIF/FITS; imports `dart:io` and `package:exif`, so it is
platform-touching, not pure). `lib/core/utils/astro_math.dart` holds angle helpers.
Per-function documentation: `docs/SCIENTIFIC_INTEGRITY.md` Part B.

**Models:** see `docs/DATA_MODEL.md` Part B3.

**Repository interfaces (6):** `TargetRepository`, `EquipmentRepository`,
`EquipmentCatalogRepository` (**unused**), `LocationRepository`, `LogbookRepository` *(removed TASK 11.3; `SessionRepository`, ADR-014)*,
`WeatherRepository`. *(Updated TASK 8.4: `EquipmentCatalogRepository` is removed, ADR-011 §2; the planner-state, planning-preferences and other seams added since TASK 5.2 are described in their sections.)*

**Abstracted (TASK 1.1):** device location for the ViewModel — the pure-Dart
`LocationService` interface (`lib/domain/services/location_service.dart`),
implemented by `GeolocatorLocationService` (`lib/data/services/`) and replaced by
`FakeLocationService` in tests (`test/support/`).

**Abstracted (TASK 7.3):** the device's IANA zone — `DeviceTimeZone`
(`lib/domain/services/device_time_zone.dart`), implemented by
`FlutterTimezoneDeviceTimeZone` (`lib/data/services/`, `flutter_timezone`), replaced by
`FakeDeviceTimeZone` in tests. It only pre-fills the site editor's zone picker; it is
never used in a computation (ADR-007 §6).

**Abstracted (TASK 7.2):** `LocationService` returns a sealed `LocationResult`
(`LocationFound` / `LocationUnavailable(LocationFailure)`) and opens the location or app
settings; the location picker uses it through the ViewModel. Reverse geocoding is the
`ReverseGeocoder` interface (`lib/domain/services/reverse_geocoder.dart`, sealed
`ReverseGeocodeResult`), implemented by `NominatimReverseGeocoder`
(`lib/data/services/`) and replaced by `FakeReverseGeocoder` in tests. The app's
identity for third-party services is `AppIdentity` (`lib/core/config/`). A test fails
if `lib/presentation` or `lib/domain` imports `package:http` or `package:geolocator`.

**Not abstracted (no interface exists):** light pollution (concrete class in the
data layer), reverse geocoding (inline HTTP in the ViewModel), device location in
`LocationPickerScreen` (still calls Geolocator inline), key-value preferences
(inline), current time in the ViewModel and widgets (`DateTime.now()` inline).

**Added, not yet wired (TASK 2.2, 2026-09-22; ADR-007)** *(updated TASK 2.2)*:
- **Current time:** a `Clock` seam (`lib/core/time/clock.dart`: `SystemClock`,
  `FixedClock`). Its only production use so far is `SessionLog.fromJson`'s fallback;
  `lib/domain` no longer calls `DateTime.now()`.
- **Session night:** `SessionNight` and `CalendarDate`
  (`lib/domain/models/`), the `SiteTimeContext` seam with `MeanSolarTimeContext` and
  `FixedOffsetTimeContext` (`lib/domain/models/site_time_context.dart`), and the
  static, pure `SessionNightResolver` (`lib/domain/services/`).
- **Wired (TASK 2.3, TASK 2.4):** the calculators, the altitude chart and now
  `PlannerViewModel`/`home_screen.dart`/`sky_darkness_widget.dart`/
  `logbook_screen.dart` all consume `SessionNight`. B11 below is updated to match.

## B6. Data layer (`lib/data/`)

- **Drift `AppDatabase`** (schema 10; 7 tables). **TASK 3.2:** `onUpgrade`
  guards every upgrade with a floor check and a downgrade check that both
  throw `UnsupportedSchemaVersionException` before any statement runs, and
  the old v1–v7 raw-SQL steps are deleted. **TASK 3.3:** foreign keys are
  now enforced — `beforeOpen` sets `PRAGMA foreign_keys = ON` on every
  connection; the v9 → v10 step runs a one-time `PRAGMA foreign_key_check`
  orphan cleanup (deleting and logging flagged rows), then rebuilds
  `camera_modules`/`optical_rigs`/`capture_blocks` via `Migrator.alterTable`
  to add real `ON DELETE RESTRICT`/`RESTRICT`/`CASCADE` actions (SQLite can't
  alter a foreign key's action in place) and to drop the legacy
  `bit_depth`/`optical_multiplier` columns an addColumn-only upgrade left
  behind; the orphaned `equipment_profiles` table is dropped entirely, not
  just deprecated. Every step runs inside one transaction. Checked against
  Drift schema snapshots (`drift_schemas/`) via generated verification code
  and a migration test suite. See `docs/DATA_MODEL.md` B8.
- **Repositories:** `DriftTargetRepository`, `DriftEquipmentRepository` (reads and
  writes the normalized Device → CameraModule → OpticalRig chain and projects it to
  the flat `EquipmentProfile`; **TASK 3.3:** `deleteEquipment` now checks for other
  references before deleting a shared camera module or device, since a `RESTRICT`
  violation would otherwise throw), `DriftEquipmentCatalogRepository` (dormant),
  `DriftLocationRepository`, `DriftLogbookRepository` *(removed TASK 11.3; replaced by `DriftSessionRepository`: lifecycle, one transaction per write, partial row writes)* (session rows plus a separate
  `capture_blocks` table, joined in memory; manual cascade on delete, now backed by
  a real `ON DELETE CASCADE` too),
  `OpenMeteoWeatherRepository` (HTTP + shared-preferences cache; `http.Client`
  injectable), `LightPollutionRepository` (concrete; static `http.get`; not
  injectable; **cannot succeed**, SI-007).
- **Seeders:** `CatalogSeeder` (5 targets), `EquipmentSeeder` (5 profiles).

## B7. Routing (go_router)

> **Since TASK 12.2 (commit `aa748e6`, ADR-015)** the table below is historical. The
> router is a `StatefulShellRoute` with four branches — `/tonight` (+ `candidates`),
> `/sessions`, `/library` (+ `rigs`, `targets`, `sites`), `/settings` (+ `about`,
> gated `metadata`) — shown by `AppShell` (bottom `NavigationBar`, back to Tonight
> from a tab root). Root-navigator routes above the tabs: `/session/:id` (the planner;
> `current` or a stored id), `/select/target`, `/select/rig`, `/select/site`,
> `/site/edit`, `/site/pick`, `/position`. `/` redirects to `/tonight`. Paths are
> `AppRouter` constants; `docs/IA_WIREFRAMES.md` §2 is the intent.

`AppRouter.router` is a **static final** `GoRouter` (a process-wide singleton) in
`lib/presentation/navigation/app_router.dart`, `initialLocation: '/'`.

| Path | Screen | Gate |
| --- | --- | --- |
| `/` | `HomeScreen` | — |
| `/target` | `TargetSelectionScreen` | — |
| `/equipment` | `EquipmentSelectionScreen` | — |
| `/location` | `LocationPickerScreen` | — |
| `/location/pick` | `LocationPickerScreen(pickOnly: true)` — returns the point to the site editor *(TASK 7.3)* | — |
| `/sites` | `SitesScreen` *(TASK 7.3)* | — |
| `/about` | `AboutScreen` — data sources and licences *(TASK 8.2)* | — |
| `/sites/edit` | `SiteEditorScreen` (`extra`: `SiteEditorArgs`) *(TASK 7.3)* | — |
| `/metadata` | `MetadataImportScreen` | `FeatureScope.metadataImport` (currently `false`, TASK 4.3) |
| `/logbook` | `LogbookScreen` | `FeatureScope.logbook` (currently `true`) |

Navigation uses `context.push` / `context.pop`; the Logbook uses `context.go('/')`
after loading a session. **TASK 4.3:** Home's app-bar buttons now read
`FeatureScope` too (they used to push `/logbook` and `/metadata` unconditionally,
DEV-P1 — resolved).

## B8. Presentation inventory and where logic lives

| Screen / widget | Reads | Notes |
| --- | --- | --- |
| `HomeScreen` | `PlannerViewModel`, `ThemeViewModel`, `FeatureScope`; `LogbookRepository` for Save | Empty state has **no navigation** to Target/Equipment. **TASK 4.3:** field-mode toggle and light-pollution map card are now gated (`FeatureScope`, DEV-P1 resolved); the map link's coordinates are still hard-coded Slovenia (F-34, TASK 7.4's job) |
| `TargetSelectionScreen` | `TargetRepository` (direct), VM for selection | Add/edit dialog with validation; no ViewModel for CRUD |
| `EquipmentSelectionScreen` | `EquipmentRepository` (direct), VM for selection | 260-line dialog with validation; contains mojibake strings |
| `SitesScreen` *(TASK 7.3)* | VM (`sites`, `activeSite`, `selectSite`, `deleteSite`, `useCurrentLocation`) | Goes through the ViewModel, not the repository (unlike the Target/Equipment screens, DEV-A2) |
| `SiteEditorScreen` *(TASK 7.3)* | VM (`saveSite`, `deviceZoneId`, `today`), `LocationProfile.userEdit` | Validators in `site_form_input.dart` / `coordinate_input.dart`; Bortle/SQM behind `FeatureScope.lightPollutionContext` |
| `LocationPickerScreen` | VM (`locateDevice`, `open*Settings`, `setLocation`) + `flutter_map` | *(Updated TASK 7.2)* explains each permission outcome; typed coordinate entry; OSM attribution; no Geolocator call |
| `LogbookScreen` | `LogbookRepository` (direct), VM `loadSession`, `share_plus` | Swipe-delete without confirmation |
| `MetadataImportScreen` | `image_picker`, `MetadataExtractor` | Display-only |
| `CapturePlanWidget` | VM | Add dialog; reorder; outputs |
| `AltitudeChartWidget` | `VisibilityCalculator.calculateAltitudeCurve`, called once from `build()` *(updated TASK 2.3)* | Render-only; `_AltitudeChartPainter` no longer computes astronomy (DEV-A3 resolved for the widget) |
| `SkyDarknessWidget` | VM | Static gradient bar unrelated to data |
| `WeatherForecastWidget` | weather model, VM | 48 h strip from local midnight |
| `PlannerSummaryCard`, `InfoRow`, `SectionHeader` | — | Presentational |

Theming: `AppTheme.light`, `AppTheme.dark`, `AppTheme.fieldTheme`; `MaterialApp.router`
uses `ThemeMode.system`, but field mode overrides both light and dark with the field
theme.

> **Since TASK 12.4 (commit `3c27b15`):** colours are tokens. `ColorScheme` roles cover the
> generic ones (error, primary, outline); `AppPalette` (`lib/core/theme/app_palette.dart`, a
> `ThemeExtension`, read with `AppPalette.of(context)`) covers the rest: muted text, the
> night's events, the altitude chart and the Bortle scale. `lib/presentation` names no
> colour and sets no font under 12 sp (test-enforced). The field theme's colour scheme and
> theme colours are all red or black; in field mode `AstroPlanApp`'s `builder` wraps the
> navigator in `ColorFiltered(AppTheme.fieldFilter)` (owner decision), keeping the app's
> state through a `GlobalKey` when the filter is added or removed. `ThemeViewModel` is part
> of `AppViewModels`, persists through `DisplayPreferencesRepository`, and `main.dart`
> awaits `theme.load()` before `runApp`.

> **Since TASK 12.5 (commit `b13f7c7`):** `TonightViewModel` (in `AppViewModels`) holds only the
> first-run state (`FirstRunRepository`, loaded before `runApp` like the theme); the Tonight
> screen reads everything else from the Site, SessionPlan, NightConditions and
> CaptureAnalysis ViewModels. `/welcome` is a root-navigator route. Shared wording for
> weather, Moon and fit lives in `presentation/shared/night_text.dart`.

> **Since TASK 13.2 (commit `14467e7`):** execution (ADR-016) is a pure domain state machine
> (`ExecutionMachine`: transitions, fold over events, running time, estimate) with the
> events in `session_events`; `DriftSessionRepository` appends an event and its counter
> projection in one transaction. `ResumeRunViewModel` (in `AppViewModels`, loaded before
> `runApp`) drives the resume prompt shown by the Tonight screen.

> **Since TASK 13.3 (commit `c8e2240`):** `/session/:id/run` (root navigator) is the tracking
> screen. `ExecutionViewModel` (in `AppViewModels`, `loadActive()` before `runApp`) re-reads
> the run from its events after every action and computes the night's timeline, the target's
> curve and the Moon's rise/set once from the execution-start snapshot; `ExecutionOutlook`
> (domain, pure) turns them into countdowns. The screen's 30-second timer only redraws.
> Keep-screen-on goes through the `ScreenWake` interface (`WakelockScreenWake` in the data
> layer, `FakeScreenWake` in tests). Start (`startSessionWithFeedback`) goes through
> `CaptureAnalysisViewModel.startSession` → `CurrentSession.start`.

> **Since TASK 13.4 (commit `c1e52ce`):** `/session/:id/results` (root navigator) is the
> reconciliation page, driven by `ResultsViewModel` (in `AppViewModels`); planned vs actual
> comes from the pure `SessionReconciliation`. `SessionsViewModel.reconciliations` feeds the
> Sessions list. The repository writes the result totals with `complete()` and with every
> correction.

> **Since TASK 14.1 (commit `e212f6a`):** `/sessions/:id` (inside the Sessions branch) is the
> read-only session detail, built from `SessionsViewModel.detail` (session + CALC-37) and
> typed `SessionSnapshot` readers; the list's `SessionFilter` maps to
> `SessionRepository.list(statuses, targetId, siteId, from, to)`.

## B9. Persistence

Drift (relational) + shared preferences (active plan, selections, thresholds,
active-location pointer, weather cache). *(updated TASK 5.2)* Shared preferences
are accessed only by data-layer repositories: `SharedPrefsPlanningPreferencesRepository`
(thresholds and overheads, `PlanningPreferences`), `SharedPrefsPlannerStateRepository`
(selections and the capture plan) and `OpenMeteoWeatherRepository` (cache).
*(S1.15: the forecast cache is `SharedPrefsWeatherSnapshotStore` since TASK 9.3, and the
planner ViewModels are split since TASK 12.3; see B15 and `CLAUDE.md` trap 11.)*
`PlannerViewModel` receives the first two as optional constructor arguments with
production defaults (the same seam pattern as `LocationService` and `Clock`). Details, keys and migration history:
`docs/DATA_MODEL.md` Part B.

## B10. External services and platform plugins

**Metadata document channel (S2.V3):** Dart serializes each source's reads and
passes its remaining 1 MiB budget. Native replies include bytes and consumed
cost. Seekable reads charge returned bytes; the pure Kotlin streaming helper
also consumes and charges the prefix on every reopened stream, refusing before
opening it if the traversal exceeds the remainder. Budget refusal maps to
`overBudget`. An I/O failure with unknown consumption exhausts that source's
budget; another file-open starts a new read operation. No cache or URI persistence.
The production helper is covered by host JVM tests in addition to Dart channel tests.

**The app's own platform channel (S2.4, ADR-017 §6):** `io.github.chacha12.astroplanner/metadata_document` (`MetadataDocumentChannel.kt`, `android_capture_file_access.dart`). Picking goes through the system document picker, and bytes are read in place; no network, no copy, no persistable grant. Android only; desktop and host have no implementation (S2.5 wires the platform choice).

| Service | Purpose | Where | Key | Policy / risk notes | Failure behavior |
| --- | --- | --- | --- | --- | --- |
| Open-Meteo forecast API | The night's hourly forecast (ADR-012) | `OpenMeteoWeatherRepository.fetchSnapshot`: `models=best_match`, `timeformat=unixtime` (UTC hours), `start_hour`/`end_hour` covering the night, capped at the 16-day horizon *(corrected S1.15; until TASK 9.2 `icon_seamless` and `timezone=auto`)* | None (User-Agent `AppIdentity.userAgent` since S1.1) | Free, non-commercial tier (PD-12; `docs/COMPLIANCE.md`) | Typed `WeatherFetchFailed`; `NightWeatherService` serves the cached snapshot with its age and the failure, or "unavailable" / "out of range", never presented as current (ADR-012 §6) |
| Nominatim (OSM) | Reverse geocoding | `NominatimReverseGeocoder` behind `ReverseGeocoder` *(TASK 7.2)*, wrapped by `OptInReverseGeocoder` (off by default, TASK 16.3) | None (User-Agent `AppIdentity.userAgent`, which carries the project URL as a contact; corrected S1.15, until TASK 16.1 it was `AstroPlan (com.astroplan.astroplan)`) | Usage policy followed: opt-in, identifying UA, ≤ 1 request/s (queued), in-memory cache by coordinates rounded to 0.01° (the rounded point is what is sent), attribution shown with the name (PD-12 resolved) | Typed `ReverseGeocodeFailed`, logged; name shown as unknown |
| ~~ClearOutside (HTML scrape)~~ **Removed (TASK 7.4)** | Bortle class | ~~`LightPollutionRepository`~~ (deleted) | None | Third-party scraping; ToS unknown; request URL is malformed so it never succeeds | Returns `null` |
| OSM tile server | Map picker tiles | `LocationPickerScreen` | None | *(Updated TASK 7.2)* attribution shown (`SimpleAttributionWidget`, links to the copyright page); the tile requests carry `AppIdentity.userAgent` and the package name `AppIdentity.packageName` *(corrected S1.15; until TASK 16.1 `com.astroplan.astroplan`)*; kept for release by PD-12, with the remaining endpoint risk in TD-031 | Blank tiles; typed coordinates still work |
| lightpollutionmap.info | External map link via `url_launcher` | `HomeScreen` (`LightPollutionMapLink`) | None | *(Updated TASK 7.4)* opens centred on the current position; hidden without one. *(Was: hard-coded Slovenia coordinates.)* | — |
| Geolocator (GPS) | Device location | `GeolocatorLocationService` only (behind `LocationService`; the picker goes through the VM since TASK 7.2) | — | Permissions declared for Android; iOS `Info.plist` has no location usage strings | Platform errors still unhandled on the VM startup path |
| `image_picker`, `share_plus` | Gallery pick; share sheet | Metadata screen; Logbook screen | — | `image_picker` cannot select FITS files | — |

## B11. Time handling as built

*(Table rewritten TASK 2.4 — the ViewModel and UI now go through `SessionNight`;
see ADR-007 for the design.)*

| Component | Time base |
| --- | --- |
| `PlannerViewModel.sessionNight` | Default: `SessionNightResolver.resolveDefault(_clock.nowUtc(), ...)` — the window containing "now", via an injectable `Clock` (`SystemClock` in production). Picked: `.forEveningDate(_pickedEveningDate!, ...)`. Both use `MeanSolarTimeContext(_longitude)` (no IANA zone before TASK 7.1). Null without a site (ADR-007 §9) |
| `calculateNightTimeline` / `calculateVisibilityWindows` | Deprecated DateTime-based wrappers (TASK 2.3); no longer called by the app. `PlannerViewModel` now calls `calculateNightTimelineForNight`/`calculateVisibilityWindowsForNight` directly with the resolved `SessionNight` |
| `AstronomicalEngine.calculateJulianDate` | Requires UTC (throws otherwise) |
| `AltitudeChartWidget` | Takes the ViewModel's `SessionNight` directly (constructor changed, TASK 2.4) — no longer resolves its own |
| `NightTimeFormatter` (new, TASK 2.4) | The one formatter for night-related instants (`home_screen.dart`, `sky_darkness_widget.dart`, `logbook_screen.dart`): every instant is converted with `.toLocal()` exactly once, inside the formatter, and labelled "device zone, UTC±HH:MM" (the site's own zone is not available before TASK 7.1); times after midnight carry a "+1" marker |
| `PlannerViewModel.currentAltitude`/`maxAltitude` | Still call `_clock.nowUtc()` directly and run their own JD/GMST/LST/LHA pipeline, not the `AltitudeCurve` (TD-023, unresolved — out of TASK 2.4's roadmap scope) |
| Weather | `timezone=auto` → naive site-local strings parsed as **device-local**; offset discarded; `lastUpdated` uses the device clock (unaffected by TASK 2.4; G9) |
| Sessions | Stored as epoch seconds, read back as local `DateTime` (unchanged schema — G11/PD-18 decide persistence of `SessionNight` itself). `loadSession`/Save Session and `LogbookScreen` now map that legacy instant to its device-local evening date via `CalendarDate.fromDateTimeFields` at the same place, instead of three divergent ad-hoc `.toLocal()` calls (ADR-007 §10 "legacy rows") |

Consequence: the default night defect (SI-010 / TD-001) is **fixed** as of TASK 2.4.

> **Since S6.4 (2026-09-28; TD-057; ADR-019 §3.1, D1)** the plan follows the rollover. `NightClock`
> calls `PlanLifecycleViewModel.followNight()` every minute and on resume, before
> `NightConditionsViewModel.checkClock()`. Only a never-saved draft (`draft`, `plannedAtUtc == null`)
> moves. When tonight has moved on since the last check (`_tonight`, set by `load` and each check), a
> picked night no longer ahead rolls forward to tonight (`_keptNight`, the same rule as the restore);
> a night picked in the past meanwhile stays until then. A changed night key is written through `CurrentSession.write(edit: false)`, in the
> autosave chain and not as an edit. `load()` writes it at a restart too. A saved plan's row is never
> written (D1); the planner notifies its listeners whenever the night key changes, for any plan. The
> candidates screen re-evaluates when `sessionNight` changes. **Testing:** a fake-time tick across
> the rollover with a database-backed plan starts a Drift write that cannot finish inside the test
> zone, and awaiting the autosave chain then hangs. Test the write by calling `followNight` in real
> async, and the tick's wiring with a preferences-backed plan (`night_rollover_test.dart`).
There is still no notion of the **site's** time zone anywhere (TASK 7.1); every
displayed time is the device's.

## B12. Test architecture

`flutter_test` + Drift `NativeDatabase.memory()` + hand-written mocks (no mocking
package). ViewModel tests inject `FakeLocationService` (`test/support/`) and wait on
`vm.ready`; the end-to-end test builds the ViewModel inside `tester.runAsync`
*(updated TASK 1.1; the 300 ms sleeps and the `activeLocationId` workaround are
gone)*. `AppRouter.router` is a static singleton shared by widget tests in a file. No
CI configuration exists in the repository. Details and gaps: `docs/TEST_PLAN.md`, `docs/PROJECT_HANDOFF.md`.

## B13. Architectural concerns (carried forward and corrected)

1. **ViewModel bloat** — Confirmed and extended: it is also un-substitutable and
   un-awaitable (DEV-A1, TD-019).
2. **Reverse geocoding in the ViewModel** — Confirmed (Nominatim, silent failure).
   Note: a `LocationRepository` exists but manages *saved profiles*, a different
   responsibility.
3. **Manual repository instantiation** — Not a defect; no DI container is required.
4. **`LightPollutionRepository` HTML regex** — Confirmed brittle **and** found
   non-functional (malformed URL) (TD-006).

## B14. Error handling and diagnostics (TASK 15.1)

- **Repositories throw `StorageFailure`** (`lib/domain/repositories/storage_failure.dart`;
  `action` + `cause`) when their store cannot be read or written; each interface says so.
  Drift: `StorageFailureInterceptor` (`lib/data/database/`) wraps every statement of the
  `AppDatabase` connection (constructor), so a raw SQLite error never leaves the data
  layer; opening and migrations are not intercepted and keep their own exceptions
  (`UnsupportedSchemaVersionException`). SharedPreferences: each method runs inside
  `guardStorage` (`lib/data/repositories/storage_guard.dart`), which also turns an
  unreadable stored value (wrong type, bad JSON) into the failure. Domain refusals
  (`SessionStateError`, `ExecutionError`, `ArgumentError`) are not storage failures and
  pass through unchanged. The weather repository keeps its typed results
  (`WeatherFetchFailed`), the reverse geocoder its `ReverseGeocodeFailed`.
- **Logging:** `AppLog` (`lib/core/diagnostics/app_log.dart`, pure Dart, usable from the
  domain) with levels info/warning/error and a scope; output to `dart:developer` and a
  200-entry in-memory buffer (`AppLog.recent`). Local only — no file, no network; crash
  reporting is deferred for privacy. Nothing in `lib` calls `debugPrint` any more.
- **UI states:** one-shot actions go through `runWithFeedback(context, action, run)`, which
  logs and shows `FailureText.message(action, error)` (the cause is never shown);
  pages that load a list show `LoadFailureView` on an error. The planner shows a banner
  while `SessionPlanViewModel.autosaveFailure` (`CurrentSession.writeFailure`) is set; a
  failed autosave never blocks later writes.
- **Deliberate fallbacks** (logged, documented where they happen): an unreadable
  weather-cache entry is absent; an unreadable JSON snapshot column reads as unavailable
  (`JsonMapConverter`); an invalid stored capture block is skipped; unreadable display or
  first-run settings fall back to their defaults; a missing wakelock or device zone is
  tolerated.
- **Enforced:** `empty_catches` (`analysis_options.yaml`) and
  `test/core/diagnostics/no_empty_catch_test.dart` (also rejects `catch (_) {}` and
  comment-only bodies).

## B15. Derived-value caching (TASK 15.2)

Widgets read the ViewModels' derived values several times per frame, so the costly ones
are memoized in the ViewModel (never in a widget):

| Value | Owner | Cached per |
| --- | --- | --- |
| `nightTimeline` | `NightConditionsViewModel` | night (`SessionNight` equality) |
| `nightWeatherSummary` | `NightConditionsViewModel` | night, forecast snapshot (identity; S1.3), dew margin |
| `moonConditions` *(TASK 6.4)* | `NightConditionsViewModel` | night, target RA/Dec |
| `imagingOpportunity` *(TASK 10.2)* | `NightConditionsViewModel` | night, target RA/Dec, preferences, forecast state (snapshot and age class when available; S1.3), site, Bortle |
| target transit (altitude curve) | `CaptureAnalysisViewModel` | night, target RA/Dec |
| `captureBudget`, `fitAnalysis`, `fillWindowFrameCount` | `CaptureAnalysisViewModel` | an input generation (bumped when the plan, settings or conditions notify) and the night |

The generation cache relies on every input change notifying — the plan's edits, the
settings and the conditions already do. A night that rolls over with the clock alone is
caught by the night in the key; since S1.3 `NightClock` also makes the conditions notify
at the rollover, and re-ages the forecast every minute (a new state object only when the
freshness wording changes, which the snapshot-based keys above do not recompute for).
`currentAltitude` (clock-dependent, 0.6 µs) is not
cached. Tonight's candidates run on a background isolate (TASK 10.4); nothing else was
measured above a frame. Measurements: `docs/TEST_PLAN.md` (TASK 15.2).

## B16. Accessibility (TASK 15.3)

- **Enforced by `test/presentation/accessibility_test.dart`:** every main screen (Tonight,
  candidates, Sessions and a session's detail, the Library and its lists, Progress,
  Settings, About, the planner, the site editor, the tracker, the results page, the
  first-run page), in the light, dark and field themes at 100 % and 200 % text, on a
  412 px-wide view: no layout exception, Android's 48 px tap targets, a label on every
  tappable element, and WCAG AA text contrast in the light and dark themes. The view is
  as tall as a page so no node is clipped by scrolling (a clipped node reports a false
  tap-target size). Since S1.10 its weather fake serves a full forecast, so the weather
  card is swept too (before, it rendered no forecast and missed UX-31).
- **Not covered by it:** dialogs (block, rig and target editors, the zone picker), the map
  picker (`/site/pick`, `/position`; tiles are third-party), the hidden metadata import.
- **Labels:** icon-only buttons carry a `tooltip` (it is their screen-reader label). A
  `Semantics(excludeSemantics: true)` that relabels a button must also give `onTap` and
  `enabled`, or the node has no tap action (S1.11; the sweep's guidelines only examine
  nodes that have one, so they cannot catch this). The
  altitude chart has a text alternative (`AltitudeChartWidget.semanticsLabel`: number of
  windows and usable time); the window list under it gives the details, so the chart and
  its text come from the same `ImagingOpportunity`. A `Card` merges its content into one
  screen-reader node, so the chart's label is read with the card.
- **Large text:** rows that hold text wrap (`Wrap`, `Flexible`, `Expanded`) or ellipsize
  rather than assume a width; a fixed-height container around text (such as
  `BottomAppBar`'s 80 px) is avoided.
- **Focus order** follows the layout; there is no custom traversal.
- **Red (field) mode limit:** primary text `fieldTextPrimary` #FF0000 on black is 5.25:1
  (WCAG AA); secondary text `fieldTextSecondary` #AA0000 is 2.71:1, below AA on purpose —
  field mode is an opt-in for dark-adapted eyes, and AA would need about #EB0000,
  erasing the dim/bright distinction. Contrast is therefore not asserted in field mode.

## B17. Design system (Stage 5; S5.1)

- **Documented in `docs/DESIGN_SYSTEM.md`** (living): tokens, type scale, text roles, surfaces,
  spacing, radius, and from S5.2 on the controls, components and patterns.
- **Code:** `lib/core/theme/`. `AppColors` holds the raw values; `AppPalette` (a `ThemeExtension`)
  the semantic tokens, including the text roles `textPrimary`, `textSecondary`, `textTertiary`,
  `textDisabled`, `surfaceRaised` and `border` (S5.1); `AppTypography.scale` the one type scale,
  merged into every theme's text theme; `AppSpacing` and `AppRadius` the spacing and radius
  scales. The colour scheme follows the roles (`onSurface`, `onSurfaceVariant`, `secondary`,
  `surfaceContainerHigh`).
- **Tests:** `test/core/theme/design_tokens_test.dart` (AA contrast of the roles on every surface
  in light and dark, the 1.3× step, field-mode brightness order, the scheme wiring, the scale, the
  radius) and the gallery, `test/presentation/design_system/`, which audits shared components in
  the three themes at 100 % and 200 % text, including ones no route uses yet and dialogs (B16's
  gap).
- **Controls (S5.2):** `AppTheme._withControls` sets the button, input, dialog, bottom-sheet,
  menu and snackbar themes from the tokens, so existing controls follow them without screen edits.
  `colorScheme.outline` is `AppPalette.controlBorder` (Material otherwise draws field underlines
  in `onBackground`). `AppButtonStyles` adds the destructive role. `AppMotion` holds the motion
  scale and turns motion off under the platform's reduced-motion setting. Tested by
  `test/core/theme/controls_theme_test.dart` and the gallery, which also opens a dialog, a message
  and a menu.
- **Words (S5.3):** `lib/presentation/shared/app_words.dart` (`AppWords`) holds the RD-14
  glossary's user-facing words. `test/presentation/shared/retired_terms_test.dart` keeps the
  retired terms out of `lib/presentation`'s string literals, against a baseline that only
  shrinks (DESIGN_SYSTEM §7).
- **Status (S5.4):**
  - `AppPalette` status and state tokens: `statusFits`, `statusTight`, `statusDoesNotFit`,
    `statusNoWindow`, `statusNeutral`, `stateUnsaved`, `stateSettled`, `stateQuiet`. `FitText.color`
    reads them, with the same values as before;
  - `lib/presentation/shared/status_block.dart` (`StatusBlock`: the verdict headline, reason, key
    numbers, action; plain values in);
  - `lib/presentation/shared/plan_state.dart` (`PlanState`, the pure mapping from stored fields,
    and `PlanStateLabel`). Not yet on a screen.
- **Disclosure (S5.5):** `lib/presentation/shared/collapsible_section.dart` (`CollapsibleSection`)
  and `DisclosureViewModel` (`AppViewModels.disclosure`, loaded in `main.dart` before the first
  frame). The open state is stored per section key through `DisplayPreferencesRepository`
  (`loadSectionStates`, `saveSectionState`; guarded by `guardStorage`, trap 15). A failed read or
  write is logged and never blocks the section. Not yet on a screen.
- **Context (S5.6):** `lib/presentation/shared/context_line.dart`:
  - `ContextLine`: site ▾ · night ▾ and the zone rule; plain values in, taps reported by callbacks;
  - `pickNight`: the shared, themed date picker returning a `CalendarDate`.

  Not yet on a screen.
- **Detail screens (S5.7):** `lib/presentation/shared/detail_scaffold.dart` (`DetailScaffold`):
  a header (title, context, the zone rule once), a summary card, then sections. Stage 6's Night &
  Moon and Weather details (P6.5) are built on it; their routes join the accessibility sweep.
  Not yet on a screen.
- **Confirming, reporting and deleting (S5.8; RD-09 = M + S1):**
  - `lib/presentation/shared/confirmation_patterns.dart`: `askUnsavedChanges` (Save · Discard ·
    Cancel) and `confirmDestructive`;
  - `showDone` beside `runWithFeedback` in `failure_feedback.dart`;
  - `lib/presentation/shared/delete_patterns.dart`: `showUndo` (exactly one outcome;
    `persist: false`), `DeleteButton`, and `SwipeToDelete` (a swipe calls the visible Delete's
    handler and the row springs back).

  Not yet on a screen.
- **Adoption (S5.9):** DESIGN_SYSTEM §9 maps each screen to the parts it adopts, the Stage 6/8/9
  Task that does it, and the retired terms it removes. The gallery's content is shared
  (`test/presentation/design_system/gallery_entries.dart`) by the gallery test and the opt-in render
  test (`render_gallery_test.dart`, `ASTROPLAN_RENDER_GALLERY`; skipped in the gate), whose images
  are in `docs/refinement/evidence/stage5/`.
- Screens adopt the roles and components in Stages 6–9; until then most keep their explicit
  styles (DESIGN_SYSTEM §8).

---

# Part C — IMPLEMENTATION DEVIATIONS (architecture)

## DEV-A1 — The ViewModel is not isolated from data, network and platform code
- **Intended behavior:** "Widgets and ViewModels should depend on repository
  interfaces and domain models"; "Platform specific behavior should be isolated
  behind interfaces or adapters" (Part A; `.agents/rules/01-architecture.md`).
- **Actual behavior:** `PlannerViewModel` imports `http`, `geolocator`,
  `shared_preferences` and the concrete `LightPollutionRepository`, performs HTTP
  and GPS calls itself, and starts an un-awaitable `_init()` in its constructor.
- **Consequence:** it cannot be tested without platform channels (this is the real
  cause of the red `integration_flow_test.dart`); the other ViewModel tests need
  workarounds and real-time sleeps; startup depends on the network; it is hard to
  split safely. TD-003, TD-019.
- **Status update (2026-09-21, TASK 1.1, commit `2357755`): PARTLY RESOLVED.**
  `geolocator` was removed from the ViewModel (device location is behind
  `LocationService`); `_init()` is awaitable via `PlannerViewModel.ready`; the
  ViewModel tests need no workaround or sleep any more. **Still open:** `http`
  (Nominatim), `shared_preferences` and the concrete `LightPollutionRepository` in the
  ViewModel; the default `GeolocatorLocationService()` is built inside the ViewModel
  constructor (a presentation → data import); `LocationPickerScreen` still calls
  Geolocator directly; startup still waits on the network (DEV-A5, TASK 1.2).
- **Status update (2026-09-23, TASK 7.2):** `http` is gone from the ViewModel
  (reverse geocoding is behind `ReverseGeocoder`) and `LocationPickerScreen` no
  longer calls Geolocator. **Still open:** the concrete `LightPollutionRepository`
  (TASK 7.4) and the default implementations built in the ViewModel constructor.
- **Status update (2026-09-23, TASK 7.4):** `LightPollutionRepository` is deleted;
  the ViewModel's constructor takes repository interfaces plus optional seams.
  **Still open:** default implementations (Geolocator, Nominatim, flutter_timezone,
  SharedPreferences) are built inside the ViewModel constructor.
- **Status: RESOLVED 2026-09-24 (TASK 12.3, commits `6c703f3`, `03c0b34`, `64caa58`).** The ViewModels take
  domain interfaces only; `main.dart` builds them through `AppViewModels` with the
  concrete implementations. A test fails if a ViewModel imports `http`,
  `shared_preferences`, `drift`, `geolocator` or the data layer.

## DEV-A2 — Presentation bypasses ViewModels
- **Intended behavior:** `Presentation -> ViewModels -> Repositories`.
- **Actual behavior:** the Equipment, Target and Logbook screens and Home's Save
  button call repositories directly; the Metadata screen calls a domain service and
  `ImagePicker` directly; the Location picker duplicates the Geolocator flow.
- **Consequence:** state ownership is inconsistent; cross-cutting concerns such
  as error states have no home. TD-021. *Resolved for one symptom (TASK 4.2):*
  deleting or editing the selected target/rig used to leave a stale selection in
  the ViewModel (TD-028) — the screens now call `PlannerViewModel.refreshSelectedTarget`/
  `refreshSelectedEquipment` afterward, a targeted fix on top of the deviation
  rather than a fix to the deviation itself.
- **Status: RESOLVED 2026-09-24 (TASK 12.3, commits `6c703f3`, `03c0b34`, `64caa58`)** for every reachable screen:
  the Equipment, Target and Sessions screens use `GearViewModel`, `TargetsViewModel` and
  `SessionsViewModel`; Save goes through `CaptureAnalysisViewModel`; the location picker
  goes through `SiteViewModel`. **Still open:** the metadata import screen (gated until
  G17) calls `ImagePicker` and `MetadataExtractor` directly.

## DEV-A3 — Astronomy is computed inside a widget, and the pipeline is triplicated
- **Intended behavior:** "Do not place non-trivial astronomy or capture calculations
  directly inside widgets"; "Keep astronomical calculations independent from Flutter
  widgets."
- **Actual behavior:** `_AltitudeChartPainter.paint` runs the Sun and target altitude
  pipeline (JD → GMST → LST → LHA → altitude) 97 times per repaint; the same pipeline
  exists in `PlannerViewModel.currentAltitude` and in
  `VisibilityCalculator.calculateVisibilityWindows`. The chart also uses a different
  24 h window (device-local noon) than the windows/timeline.
- **Consequence:** untestable, inconsistent time windows, three places to fix any
  astronomy change. TD-023.
- **Status: RESOLVED for the widget 2026-09-22 (TASK 2.3, commit `de1792a`).** The
  chart no longer computes astronomy: `AltitudeChartWidget.build()` resolves one
  `SessionNight` and calls the new `VisibilityCalculator.calculateAltitudeCurve`
  once; `_AltitudeChartPainter` only maps the resulting samples to pixels and
  imports no astronomy code. The chart and the calculators now share one window
  (same `SessionNight`, same 5-minute grid) instead of diverging. **Still open:**
  `PlannerViewModel.currentAltitude`/`maxAltitude` still run their own copy of the
  pipeline directly in the ViewModel — not a widget, so outside this deviation's
  original scope, but still a second copy of the pipeline (TASK 2.4). TD-023.

## DEV-A4 — Capture/session budget logic lives in the ViewModel, not the domain — **RESOLVED 2026-09-22 (TASK 5.4)**

*Resolution:* the budget is computed by the pure domain `CaptureBudgetCalculator`
(ADR-009, CALC-25; tested against ADR-009's vectors E1–E7). The ViewModel's
`captureBudget` getter only supplies its inputs, and `estimatedRequiredTime`,
`totalIntegrationTime`, `estimatedStorageMB` and `relativeStackingGain` read its
result. The dead `estimateTotalDuration` was deleted. *(Original record below.)*

- **Intended behavior:** "Business logic must be deterministic and testable";
  the capture planner is the central component.
- **Actual behavior:** `estimatedRequiredTime` (all frame types plus a flat 5 s per
  frame), `totalIntegrationTime`, storage and gain are computed in the ViewModel;
  the domain `SessionCalculator.estimateTotalDuration` (15 % model) is dead code.
  Neither integration, acquisition nor total session budget is modelled separately.
- **Consequence:** the central component has **no tests** for its live math, and the
  tested code is unused. TD-022, TD-025.

## DEV-A5 — Offline-first is not honoured at startup
- **Intended behavior:** "Core features … must work offline. External APIs … enrich
  but aren't strictly required."
- **Actual behavior:** `_init()` awaits `getCurrentWeather` (10 s timeout) before
  clearing `isLoading`; `setLocation` awaits weather before notifying; seeding is
  unawaited and races the ViewModel's first read; on failure the Home screen shows a
  dead-end message with no navigation.
- **Consequence:** the first screen can be blocked by the network, or (racing) empty
  with no way forward. TD-002.
- **Status: RESOLVED for the startup path 2026-09-21 (TASK 1.2).** `main.dart` awaits
  seeding before `runApp`; `_init()`/`ready` no longer waits on weather, which loads
  after the first frame (`SchedulerBinding.addPostFrameCallback`) and sets
  `weatherError` on failure instead of throwing into the void; a bootstrap failure
  sets `hasBootstrapError`, surfaced by Home with a retry view, instead of an
  unguarded exception; the empty state has actions. **Not part of this fix:**
  `setLocation()` — a user-initiated action, not the startup path — still awaits its
  own weather fetch before returning; the silent first-launch
  `unawaited(useCurrentLocation())` still has no try/catch around an unexpected
  platform exception (only denial/disabled-service, which return `null`, are
  handled). TD-002.

## DEV-A6 — Scientific calculation boundary is only partly documented and tested
- **Intended behavior:** every calculation service documents input/output units,
  formula/reference, assumptions, valid ranges, edge cases, and has tests.
- **Actual behavior:** unit and formula comments exist for most functions, but
  references and assumptions are largely missing, several calculations have no
  independent reference-value tests, and the NPF test is circular.
- **Consequence:** silent scientific errors survive (SI-001). See
  `docs/SCIENTIFIC_INTEGRITY.md`. TD-007, TD-036.

## What complies with the design intent (verified)
- Provider + `ChangeNotifier` only; no other state-management library.
- go_router with routes centralized in `lib/presentation/navigation/`.
- Drift APIs are confined to the data layer: no `lib/presentation` or `lib/domain`
  file imports Drift or the database (only `main.dart` wires it).
- Domain services and `core/utils` import no Flutter packages.
- Scope guardrails respected: no planetarium, AR, camera control, live view or GPU
  rendering; the map picker is a 2-D tile map.

---

# Part D — TARGET ARCHITECTURE / INTENDED DIRECTION

## D1. Approved direction (from the design intent)

The Phase 0 baseline (Part A) remains the approved target: layered
Presentation → ViewModels → Repositories → Services/Data; pure-Dart, unit-tested,
documented calculation services; Provider/ViewModels; centralized go_router; Drift
behind repository interfaces; offline-first; scope guardrails. No architectural
change is approved beyond this.

## D2. Proposed seams and changes (audit recommendations — **not approved**)

Each item needs owner approval (`.agents/rules/00-project-governance.md`) and is
listed with its work item.

| # | Proposal | Purpose | Work item |
| --- | --- | --- | --- |
| P1 | Pure-Dart **time and site model** ("session night", site time zone) in `domain/` | Correct "tonight"; one time base for timeline, windows, chart, weather, log | TD-001, TD-020 (PD-01, PD-02) |
| P2 | **Interfaces for platform/IO**: device location, reverse geocoding, light-pollution source, key-value preferences, clock | Testability; remove `http`/`geolocator`/`shared_preferences` from the ViewModel | TD-019, TD-003 *(device location: done in TASK 1.1; reverse geocoding and permission states: TASK 7.2; light pollution open — TASK 7.4)* |
| P3 | **Deterministic bootstrap**: awaitable initialization; seeding completed before the first read; no network on the critical path; visible error/empty states with navigation | Startup robustness; offline-first | TD-002 |
| P4 | **Capture-budget domain service** (pure Dart) separating integration, acquisition, calibration and total session budget, with configurable overhead | Central product component; testable | TD-022 (PD-08) |
| P5 | **Typed value objects** for the night timeline and windows; one shared altitude function used by ViewModel, windows and chart | Remove triplication and stringly-typed maps | TD-023, TD-024 |
| P6 | **Decompose `PlannerViewModel` only along the seams P2–P4 create** (for example site/weather, plan, selection); incremental and test-first; no big-bang rewrite | Reduce blast radius | TD-019 |
| P7 | **Route screens through ViewModels** when they are next modified | Consistent state ownership | TD-021 |
| P8 | **Persistence governance**: Drift schema snapshots + migration tests, FK enforcement, retire or use the orphan table, decide the equipment model | Safe schema evolution | TD-004, TD-005, TD-026 (PD-03, PD-04) |
| P9 | **Represent unknown explicitly** (nullable values, UI states) across the domain | Scientific integrity | SI-008, TD-013 |
| P10 | **Test architecture**: injectable clock, no real-time sleeps, widget tests for the main screens, independent reference values for calculations | Reliability | TD-025, TD-037 |

## D3. Guardrails for any future architectural work

- No new state-management framework, no DI container, no wholesale rewrite
  (CLAUDE.md rules 5–6; ADR-002).
- Keep the domain pure and deterministic; do not add Flutter imports to `domain/`.
- Do not build a planetarium engine, 3-D sky, hardware control, ASCOM/INDI, social,
  authentication or cloud features unless explicitly requested.
- Multi-file, architectural, database or scope-affecting work: inspect, report a
  plan, and wait for approval before implementing.
- Every schema change adds a migration **and** a migration test.

## D5. Approved product flow and information architecture (ADR-019, Stage 4) — not yet built

Owner-approved on 2026-09-27; implemented by Stages 5, 6, 8 and 9. The architectural effects:
- **Session lifecycle** (ADR-014 §3 amended):
  - a saved plan's snapshot is the immutable intent for its night. Results and working edits never
    change it, and working edits belong to an independent working copy;
  - a recorded result completes or abandons a saved plan (Saved or Saved · changed) without a run
    and without Save plan, and never for a planned night that has not ended;
  - its counts are written as events against the snapshot's blocks, so the counters equal the
    replay (trap 14);
  - from Stage 8, a saved plan whose night has passed stays on that night, and the planner
    continues on a copy for tonight, the independent working copy. Only never-saved drafts roll forward in place. Until Stage 8,
    saved plans behave as today (D1). ADR-019 §3.1 is normative (S4.V1, revised by S4.V2).
- **Execution** (ADR-016 amended): optional ("Track live"); the event model is unchanged for live
  runs.
- **Navigation** (ADR-015 amended):
  - the four tabs stay (the second labelled Logbook);
  - the planner's order is answer-first;
  - a Night & Moon and a Weather detail are added;
  - the Library lists manage and never select, and choosing happens only through `/select/…`;
  - Progress moves to the Logbook branch.
- **Presentation:**
  - collapsible sections with factual summaries (ADR-009 §2's lines within the budget details);
  - one shared vocabulary (RD-14), with a test against retired terms.
- **Unchanged:**
  - every calculation, and the domain boundaries (D1, D3);
  - the four-tab shell;
  - Provider and screen-scoped ViewModels (the 250-line limit, trap 11).

See `docs/IA_WIREFRAMES_ADDENDUM.md` and DECISIONS ADR-019.

## D4. Work that cannot proceed until the time/site model and capture-budget model are settled

Imaging Opportunity; weather-window alignment and site-time-zone display; capture
planner redesign (integration vs acquisition vs budget); Logbook actuals, execution
state and export manifest changes (need a stable Session/Site shape); saved-location
management; equipment-composition UI; any schema migration before the persistence
baseline decision.
