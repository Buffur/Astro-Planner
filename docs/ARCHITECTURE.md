# AstroPlan Architecture

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
> `SessionPlanViewModel` (listens to the site), `NightConditionsViewModel` (site + plan + settings),
> `CaptureAnalysisViewModel` (all four), `StartupViewModel` (load order: site, settings, plan,
> conditions), plus `GearViewModel`, `TargetsViewModel`, `SessionsViewModel` and `ThemeViewModel`.
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

> **Since TASK 12.3** `PlannerViewModel` no longer exists; the table below records what it
> owned. Where each responsibility went: bootstrap to `StartupViewModel`; location, sites,
> geocoding and Bortle to `SiteViewModel`; thresholds to `SettingsViewModel`; selection, night,
> sessions and the capture plan to `SessionPlanViewModel` (with `CurrentSession`,
> `SessionReferenceResolver`, `ExampleCapturePlan`); weather, timeline, Moon, opportunity and
> candidates to `NightConditionsViewModel`; budget, fit, capability and the Save snapshot to
> `CaptureAnalysisViewModel`. Tests build the same graph through `PlannerHarness`.

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
`PlannerViewModel` receives the first two as optional constructor arguments with
production defaults (the same seam pattern as `LocationService` and `Clock`). Details, keys and migration history:
`docs/DATA_MODEL.md` Part B.

## B10. External services and platform plugins

| Service | Purpose | Where | Key | Policy / risk notes | Failure behavior |
| --- | --- | --- | --- | --- | --- |
| Open-Meteo forecast API | Weather (current + hourly) | `OpenMeteoWeatherRepository`; `models=icon_seamless` hard-coded; `timezone=auto` | None | Free tier is intended for non-commercial use; verify terms before any commercial release. Live query checked 2026-09-21 (London): no nulls in the first 48 h; hourly arrays start at local midnight; `utc_offset_seconds` returned but discarded | Any error → falls back to cache → else `null` (silent) |
| Nominatim (OSM) | Reverse geocoding | `NominatimReverseGeocoder` behind `ReverseGeocoder` *(TASK 7.2)* | None (User-Agent `AstroPlan (com.astroplan.astroplan)`) | Usage policy followed: identifying UA, ≤ 1 request/s (queued), in-memory cache by coordinates rounded to 0.01° (the rounded point is what is sent), attribution shown with the name; no contact address in the UA (PD-12) | Typed `ReverseGeocodeFailed`, logged; name shown as unknown |
| ~~ClearOutside (HTML scrape)~~ **Removed (TASK 7.4)** | Bortle class | ~~`LightPollutionRepository`~~ (deleted) | None | Third-party scraping; ToS unknown; request URL is malformed so it never succeeds | Returns `null` |
| OSM tile server | Map picker tiles | `LocationPickerScreen` | None | *(Updated TASK 7.2)* attribution shown (`SimpleAttributionWidget`, links to the copyright page); UA uses the real `applicationId` `com.astroplan.astroplan`; whether a release may use the public tile servers is open (TD-031, PD-12) | Blank tiles; typed coordinates still work |
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

## D4. Work that cannot proceed until the time/site model and capture-budget model are settled

Imaging Opportunity; weather-window alignment and site-time-zone display; capture
planner redesign (integration vs acquisition vs budget); Logbook actuals, execution
state and export manifest changes (need a stable Session/Site shape); saved-location
management; equipment-composition UI; any schema migration before the persistence
baseline decision.
