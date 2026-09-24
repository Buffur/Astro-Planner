# Project Handoff: AstroPlan

> **Read this first.** It is the entry point for any new agent or developer.
> **Verification stamp:** verified against code at commit `900b82a` (2026-09-20),
> audited and documented 2026-09-21. Application code changed since by TASK 1.1
> (commit `2357755`: `LocationService` seam, `PlannerViewModel.ready`, test harness)
> and TASK 1.2 (deterministic bootstrap: seeding awaited before `runApp`, weather off
> the startup path, `hasBootstrapError`/`retryBootstrap`, Home empty/error states).
> TASK 1.3 added the quality gate and CI. TASK 2.1 accepted ADR-007 (SessionNight),
> TASK 2.2 (2026-09-22) implemented its pure-domain part, and TASK 2.3 (`de1792a`)
> made the calculators and the altitude chart consume it, via deprecated wrappers so
> no other caller needed to change — the ViewModel still isn't wired (TASK 2.4). Work
> now follows `docs/MASTER_ROADMAP.md`; the current position is the "active
> task" line in `docs/ROADMAP.md`.
>
> **The code is the source of truth for the ACTUAL state.** Design intent is kept
> separately (in `PRODUCT_SPEC.md`, `ROADMAP.md`, `DECISIONS.md` Part A and Part A of
> `ARCHITECTURE.md` / `DATA_MODEL.md`) and is **never** rewritten to match the code.
> Where they differ the documents say **IMPLEMENTATION DEVIATION**.
>
> Status vocabulary: **Intended / Planned**, **Implemented**, **Partial**,
> **Prototype**, **Broken**, **Missing**, **Deprecated**, **Unknown**
> (definitions: `FEATURE_STATUS.md`).
> **TASK 5.2 (2026-09-22):** planning preferences (`PlanningPreferences` + repository) and a Settings screen; the planner selection state moved behind `PlannerStateRepository`; `PlannerViewModel` no longer imports SharedPreferences. Test baseline 229.
> **TASK 5.3 (2026-09-22):** `CaptureBlock` validates at the domain boundary and gains a calibration policy and a typed, descriptive-only gain; schema v11 adds block `position`, `calibration_policy`, `gain_kind`/`gain_value` and drops the free-text `gain_iso` (owner-approved); migrations now use generated per-version step shapes (`schema_versions.dart`). Test baseline 249; schema v11.
> **TASK 5.4 (2026-09-22):** `CaptureBudgetCalculator` (CALC-25) implements the ADR-009 budget; the ViewModel only delegates; feasibility now uses the window load (calibration outside the window no longer counts against dark time); the dead `estimateTotalDuration` (CALC-19) was deleted. Test baseline 268.
> **TASK 5.5 (2026-09-22):** `FitAnalyzer` (CALC-26) places the ADR-009 event sequence atomically into the windows and reports fits / tight / does not fit / no window / nothing to fit with a reason, end time, lost tails, unplaced frames, the inverse maximum and a similar-nights hint; the sum-of-windows `SessionCalculator` (CALC-18) was deleted. Test baseline 282.
> **TASK 5.6 (2026-09-22):** the capture planner UI shows every ADR-009 line (integration, acquisition, calibration in/outside the window, setup, window load vs available, session budget), the fit with its reason and end time, a one-tap "fill / trim to tonight's window" action, √N per (filter, exposure) group with help text, storage or "Unknown", and an assumptions panel; the block editor sets the calibration policy, binning and a typed gain. `capture_plan_widget.dart` was split into `widgets/capture_plan/`. Group G5 is complete. Test baseline 291.
> **TASK 6.2 (2026-09-22):** independent reference fixtures (USNO events and celestial-navigation altitudes, JPL Horizons Sun elevations, SIMBAD J2000 star positions; `test/fixtures/astronomy/`) and tolerance tests; target coordinates are now precessed J2000 → date (Meeus ch. 21, owner decision) in the one domain target-altitude function; altitudes stay airless with the −0.833° sunrise/sunset convention (owner decision); source/units/error doc comments on the astronomy functions. Test baseline 299.
> **TASK 6.3 (2026-09-22):** a pure-domain Moon ephemeris (`MoonCalculator`, Meeus ch. 47 full tables in `moon_series.dart`, ADR-010) — position, topocentric altitude, illuminated fraction, phase longitude, rise/set on the night grid — verified against JPL Horizons and USNO well inside ADR-010 §4. **Not used by the app yet** (TASK 6.4 wires it and retires the mean-phase model). Test baseline 309.
> **TASK 6.4 (2026-09-22):** `MoonConditions` (Moon altitude, separation from the target, rise/set, illumination at mean solar midnight, closest approach while both are up) from `MoonCalculator`, shown on the sky card as annotations; the mean-phase `calculateLunarIllumination` was deleted. Test baseline 319.
> **TASK 6.5 (2026-09-22):** the NPF rule now follows F. Michaud's primary source (derivation on sahavre.fr), with an explicit k (default 1, range 1–3); the circular test is replaced by independent worked examples. Still hidden (PD-11). Group G6 is complete. Test baseline 327.
> **TASK 7.1 (2026-09-23):** site semantics in schema v12 (nullable Bortle with source and date, SQM, IANA zone, notes; default Bortle 4 cleared with a note); a map pick or GPS fix is a transient, remembered position that never writes into a saved site; the `timezone` package (0.11.1, BSD) backs an `IanaTimeContext`, so a site's zone drives its night (ADR-007 L1 fixed for sites with a zone) and the display. Test baseline 347; schema v12.
> **TASK 7.2 (2026-09-23):** location and geocoding behind domain interfaces. `LocationService` reports each permission outcome (`LocationFound`, or `LocationUnavailable` with `serviceDisabled` / `permissionDenied` / `permissionDeniedForever`) and opens the matching settings page; the location picker explains each outcome (rationale text + "Open settings") and no longer calls Geolocator. A `ReverseGeocoder` interface with a `NominatimReverseGeocoder` (identifying user agent `AstroPlan (com.astroplan.astroplan)`, at most 1 request/s, in-memory cache by coordinates rounded to 0.01°, failures reported, not cached) replaces the ViewModel's inline HTTP; OpenStreetMap attribution on the map and next to place names; the tile user agent is the real app id; typed coordinate entry works offline. No `http`/`geolocator` import in presentation or domain (test-enforced). Test baseline 379.
> **TASK 7.3 (2026-09-23):** sites UI. A Sites screen (`/sites`) lists saved sites with the active one marked; sites can be selected, created, edited and deleted (with confirmation); "use current position" and "pick on map" set a transient position, which can be saved as a site. The site editor (`/sites/edit`) validates name, latitude/longitude (typed or picked on the map), elevation (m), an IANA zone picker defaulting to the device zone, and notes; Bortle/SQM with their source sit behind `FeatureScope.lightPollutionContext` until TASK 7.4. Owner decisions: `flutter_timezone` 5.1.0 (Apache-2.0) behind a domain `DeviceTimeZone` seam, only to pre-fill the zone picker; the first run shows a site prompt instead of a silent GPS request; deleting the active site keeps its position as the transient position. `IanaTimeContext` now loads the `latest_all` zone data set (the 10-year set has no link zones such as `Europe/Ljubljana`). Test baseline 404.
> **TASK 7.4 (2026-09-23):** light-pollution MVP (PD-05 resolved). The ClearOutside scraper (`LightPollutionRepository`) is deleted, with its ViewModel argument, provider and per-location-change call; a location change makes no network call beyond weather and the place name. Option A: the external light-pollution map opens centred on the current position (`LightPollutionMapLink`), only when one exists. Option B: manual Bortle and/or SQM in the site editor, stored as source `user` with the date. `FeatureScope.lightPollutionContext` is `true` (its PD-06 phase). The sky card shows the known values with their sources (`SkyDarkness`), "not saved" for a transient position, or "unknown"; Bortle and SQM are never converted into each other; the sky warning still uses a known Bortle class only. Options C (offline dataset) and D (licensed API) are documented as deferred. Group G7 is complete. Test baseline 420.
> **TASK 8.1 (2026-09-23):** target model hardening, schema v13. `astro_targets` gains `epoch` (default and only supported value `J2000`), `source` (ADR-008 §6: `user`, `seed:catalog@1`; NULL for legacy rows, never guessed), `angular_size_arcmin` and `magnitude` (unknown by default); a partial unique index makes catalog entries (`seed:`/`catalog:` sources) unique per catalog id. Pure parsers in `AstroMath` accept RA as h:m:s, `05h35m17s` or decimal hours (degrees only with a `°` suffix) and Dec as d:m:s, `−05°23′28″` or decimal degrees, the sign applying to the whole value (`−0°30′` works). The editor formats stored values, keeps an untouched field's exact value, never changes the catalog id (the repository no longer writes it on update), offers fixed-coordinate types only and labels existing moving-type targets (ADR-010 §3; also on Home); an edit of coordinates, size or magnitude makes the source `user`. Search escapes `LIKE` wildcards. G8 has started. Test baseline 451; schema v13.
> **TASK 8.2 (2026-09-23):** curated target catalog. 164 targets from OpenNGC v20260501 (the 109 Messier objects it holds — M102 is a duplicate of M101 there — plus 55 owner-approved showpieces), each with J2000 coordinates, source `catalog:openngc@v20260501`, the OpenNGC major axis (all but M40 and M73) and V magnitude where available. The asset `assets/catalog/catalog_v2.json` is generated by `tool/build_catalog.dart` from the pinned release. Owner decisions: bundle it under CC BY-SA 4.0 with `OPENNGC_NOTICE.txt`, shown on a new About & data sources page and in the licence page; Messier + ~55 showpieces; on the first run after a pre-8.2 install, rows equal to the five old seeds (id and exact coordinates) are updated in place, edited rows left alone. Seeding is versioned (`catalogSeedVersion` in preferences) and never resurrects deleted targets. Test baseline 463.
> **TASK 8.4 (2026-09-23):** ADR-011 implemented, schema v14. `EquipmentProfile` fields carry units (`focalLengthMm`, `focalRatio`, `pixelPitchUm`, `sensorWidthMm`/`HeightMm`, `resolutionWidthPx`/`HeightPx`, `rotationDeg`) plus optional `apertureDiameterMm`, a `TrackingType` {untracked, tracked, guided, unknown} and an optional `maxExposureS`; `optical_rigs` gains nullable `aperture_diameter_mm` and `max_exposure_s`; the `aperture` column keeps every value, read as N. `EquipmentLimits` documents the plausibility bounds and `resolveAperture` the N = f / D rule (1 % agreement); the editor validates every field with units, derives a read-only f/ from a diameter, edits tracking and maximum exposure, and flags a stored ratio above f/32 for review (never converted). The dormant catalog repository and its three domain models are removed. Test baseline 483; schema v14.
> **TASK 8.5 (2026-09-23):** equipment seeds verified, schema v15. Owner decisions: only the verified seed ships (the four phone profiles are dropped — their makers publish only megapixels, f-number and a 35 mm-equivalent focal length); the telescope optics are labelled an example. The seed "ZWO ASI2600MC + example 72 mm f/5.6 refractor" has camera specs verified against ZWO's product page (23.5 × 15.7 mm, 6248 × 4176 px, 3.76 µm; checked 2026-09-23) and estimated optics; RAW size unknown. `camera_modules` and `optical_rigs` gain `source` and `confidence` (ADR-008 §6; legacy rows NULL); a user edit makes a changed group of specs `user`/`reported`. `SectionHeader` titles now wrap instead of overflowing. Test baseline 500; schema v15.
> **TASK 8.6 (2026-09-23):** capability summary and untracked exposure guidance; PD-11 resolved (owner): NPF is shown as a labelled recommendation for untracked rigs and, marked "if untracked", for rigs of unknown tracking (never for tracked/guided); it uses the field's minimum |δ| (target |δ| − half the field diagonal, floored at 0); k is a planning setting (1–3, default 1) shown with every figure. The pure `CapabilityCalculator` gives FOV, pixel scale, NPF, the ADR-011 §5 recommended maximum sub and the target's frame fill; Home's equipment card shows them and a light block longer than the recommendation gets a warning (guidance only). Group G8 is complete. Test baseline 511.
> **TASK 9.2 (2026-09-23):** `WeatherSnapshot` (provider, model, fetch time UTC, site, hourly `WeatherHour` values for the ADR-012 variables, each nullable) and a pure `OpenMeteoForecastParser` for `timeformat=unixtime` responses (GMT+0 epochs → UTC instants; nulls/short arrays → unknown; provider errors → typed failures). `WeatherRepository.fetchSnapshot` requests exactly the night's `[startUtc, endUtc)` with `best_match`, capped at the 16-day horizon. Tested on recorded fixtures. The current weather card still uses the legacy `getCurrentWeather` path until TASKs 9.3–9.4. Test baseline 521.
> **TASK 9.3 (2026-09-23):** weather caching, freshness and failure states. `NightWeatherService` (domain, Clock-driven) uses a cached snapshot younger than 3 h, otherwise fetches and caches; out of range is its own state; a failed refresh returns the cache with its age and the failure, or unavailable without a cache — cached data is never presented as current. Freshness constants `WeatherFreshness` (aging 3 h, stale 12 h); sealed `NightWeather` state; `WeatherSnapshotStore` (SharedPreferences in the data layer) keyed by rounded coordinates, model and night. `PlannerViewModel.nightWeather` loads on the existing weather triggers; the card still shows the legacy path until TASK 9.4. Test baseline 535.
> **TASK 9.4 (2026-09-23, commit `48d7a8c`):** night-aligned weather indicators and UI. `NightWeatherSummarizer` (pure, domain) slices the forecast to sunset..sunrise of the chosen night (the whole window, labelled, for midnight sun or polar night), one slot per UTC hour with "no forecast" gaps, per-variable ranges over the covered hours, and the dew spread (temperature − dew point) against the configured margin, labelled a heuristic (CALC-32). The weather card is rewritten on `vm.nightWeather` / `vm.nightWeatherSummary`: age and model, offline/stale labels, unavailable with retry, out of range, explicit units, hour strip in the site zone, no good/bad colour bands, Open-Meteo CC BY 4.0 attribution. Owner decisions: sunset to sunrise; neutral values; the legacy path removed (`getCurrentWeather`, `WeatherConditions`/`HourlyForecast`, the non-expiring cache, `currentWeather`/`weatherError`/`dewWarning`). **Group G9 is complete.** Test baseline 547.
> **TASK 10.1 (2026-09-23, documentation only, no code changed):** ADR-013 (imaging-opportunity semantics) accepted in Part F of DECISIONS; PD-17 resolved. Owner decisions: gates are darkness and minimum altitude, with a horizon gate reserved (no horizon data in 1.0); the Moon and cloud only annotate by default, each with an optional user gate (off; thresholds 50 %); the fixed sky warning (Moon > 0.8 or Bortle ≥ 7) is replaced by annotations in TASK 10.2. Also decided: unknown never excludes, all failing reasons listed, max altitude inside windows, no composite score (ranking by usable time only); 12 worked examples as test vectors. No status changed (F-17, F-18, F-38 are implemented in TASK 10.2).
> **TASK 10.2 (2026-09-23, commit `613b32f`):** `ImagingOpportunityCalculator` (pure, domain; CALC-33) implements ADR-013: gates per 5-min grid instant (darkness, minimum altitude, optional Moon and cloud gates), windows with night-edge clip flags, all failing reasons per excluded segment, why a night has no window, max altitude inside each window, Moon and weather annotations (a missing input is a missing annotation; unknown never excludes), and a `SunTrack` shared across targets. `PlanningPreferences` gained the optional gates (off; 50 % when enabled; persisted, no Settings UI yet). `vm.imagingOpportunity`; `vm.visibilityWindows` and so the budget fit now come from it (FitAnalyzer API unchanged; identical windows while the gates are off). Not yet shown in the UI (TASK 10.3). Test baseline 572.
> **TASK 10.3 (2026-09-23, commit `e732a0e`):** opportunity presentation. Home's "Tonight for this target" card shows the usable time, a chart (darkness bands at the user's limit, highlighted windows, target and Moon altitude, minimum altitude) and a text list (each window with times, duration, max altitude and Moon/forecast facts; every excluded period with all its reasons; the no-window reason), both rendered from `vm.imagingOpportunity`; wording in `OpportunityText`. Removed: the fixed sky warning (ADR-013 §6), the decorative gradient bar (TD-034), and the culmination-based "Max Altitude" (now "Max altitude in windows"; `calculateCulminationAltitude` removed with its last caller). Test baseline 577.
> **TASK 10.4 (2026-09-23, commit `6bb596f`):** tonight's candidates. `CandidateEvaluator` (domain) evaluates every target for the chosen night with the single-target opportunity calculator, sharing a `SunTrack` and a new `MoonTrack` (Moon once per night); rows give usable time, first window start / last window end, max altitude in windows, minimum Moon separation in windows, frame fill (CALC-31) and the no-window reason; `CandidateList` sorts by a chosen column (unknown last) and filters (with a window, type, own targets). No score. `vm.tonightCandidates()` runs it on a background isolate; the new "Tonight's candidates" screen (`/tonight`, Home app bar) lists it and a tap selects the target. Owner decisions: all targets with filters (no favourites concept), a new screen, targets without a window hidden by default with a toggle. **Group G10's scope through 10.4 is done** (10.5 is the cut line). Test baseline 584.
> **TASK 10.5 (2026-09-23, owner decision, documentation only, no code changed):** CUT for 1.0. The owner kept the ADR-013 deferral: no azimuth, horizon profile, schema change or editor now; the horizon gate (G3) stays reserved and F-17 stays Missing (a documented limitation: the minimum altitude stands in for obstructions). Group G10 is closed at 10.4; the next task is TASK 11.1 (ADR: Session aggregate, PD-18).
> **TASK 11.1 (2026-09-23, documentation only, no code changed):** ADR-014 (Session aggregate, lifecycle and snapshots) accepted in Part F of DECISIONS with an entity diagram; PD-18 resolved. Session is the aggregate root (LogbookEntry = a completed Session; ExecutionState = status + block counters + events), with nullable SET NULL references, a night key, UTC timestamps and versioned JSON snapshots; `session_logs` evolves in place. Owner decisions: completed sessions keep only results and notes editable (no reopening; Duplicate instead); the plan snapshot is refreshed on each Save and the execution-start snapshot is frozen; the planner opens the most recent open session (no id in preferences); legacy logs become completed, read-only 'legacy' sessions with no references guessed from names. No status changed.
> **TASK 11.2 (2026-09-23, commit `428f673`):** schema v16 (ADR-014 §5). `session_logs` evolved in place into the Session root: `status` (draft/planned/inProgress/completed/abandoned, CHECK, default draft), `legacy`, the night key (`evening_date`, `time_zone_id`), nullable references `site_id`/`target_id`/`rig_id` with ON DELETE SET NULL, UTC-ms lifecycle timestamps and two versioned JSON snapshot columns (`JsonMapConverter`); `capture_blocks` + `completed_frames`, `rejected_frames` (planned = `frame_count`); indexes on status, evening date and target id. Every existing log became a completed legacy session (no references guessed). `DriftLogbookRepository.updateLog` now writes only its own columns (a full-row replace would reset the v16 columns). No domain or repository API change. Test baseline 598.
> **TASK 11.3 (2026-09-23, commit `ad6609c`):** `SessionRepository` (domain) / `DriftSessionRepository` (data): create, update plan, save plan (→ planned + plan snapshot), start (execution-start snapshot, frozen), complete, abandon, results, get, list by status/night/target, most recent open session, delete — one transaction per write, the ADR-014 lifecycle enforced (`SessionStateError`, nothing written). Pure `SessionSnapshotBuilder` (versioned, unit-keyed JSON of night, site, sky darkness, target, rig, preferences, blocks, budget, opportunity, weather) and `SessionSnapshot` (unknown version = unavailable). `LogbookRepository`/`DriftLogbookRepository` removed: Home's Save calls `vm.saveSession()`; the Logbook lists every non-draft session and the legacy logs with a status label; `vm.openSession` follows references by id (labels only for legacy rows). Owner decisions: the Logbook shows all saved sessions with their status; Save = planned + snapshot; new rows write display labels into the pre-v16 text columns. Test baseline 613.
> **TASK 11.4 (2026-09-23, commit `628fda6`):** the planner works on a persisted draft session (ADR-014 §3, §6). At start the most recent open session is resumed (or a draft is created); every plan edit (blocks, target, rig, night, site) is autosaved into it through a serialized `_autosave` before the edit call returns; a plan still in preferences moves once into a new draft and the preferences plan and selected target/rig ids are removed (`PlannerStateRepository.clearPlan`). New (tonight + example plan), Duplicate for another night (Home app bar) and Open (Logbook) create or resume drafts; Save moves the current session to planned with a fresh snapshot. Owner decisions: a draft whose night has passed resumes on tonight (a future night is kept); a saved plan edited since is listed as "Planned, unsaved changes"; New = tonight + example plan; opening a completed/legacy session copies it into a new draft. The site selection and the transient position stay app-level preferences (TASK 7.1/7.3 decisions). **Group G11 is complete.** Test baseline 620.
> **TASK 12.1 (2026-09-23, documentation only, no code changed):** ADR-015 (information architecture) accepted in Part F of DECISIONS with low-fidelity wireframes and a route map in `docs/IA_WIREFRAMES.md`; PD-19 and PD-14 resolved. Owner decisions: bottom navigation Tonight · Sessions · Library · Settings; the session planner is one page opened from Tonight and from Sessions; sites live in Library with rigs and targets; PD-14 = a fixed Tonight view, no customizable dashboard. Execution is a full-screen route above the tabs (G13).
> **TASK 12.2 (2026-09-23, commit `aa748e6`):** navigation shell (ADR-015). go_router `StatefulShellRoute` with four tabs (Tonight · Sessions · Library · Settings) and kept per-tab state; Android back pops within a tab, then returns to Tonight, and leaves the app from Tonight's root. Above the tabs: `/session/:id` (the planner — Home's content), `/select/target|rig|site` (the planner's pickers), `/site/edit`, `/site/pick`, `/position`. `/tonight` is an interim root until the TASK 12.5 dashboard; candidates are `/tonight/candidates`; a Library index; metadata import under Settings (still gated). Paths are `AppRouter` constants. TD-053 recorded. Test baseline 625.
> **TASK 12.3 (2026-09-24, commits `6c703f3`, `03c0b34`, `64caa58`):** the planner ViewModel is split into screen-scoped ViewModels over domain interfaces: `SiteViewModel` (sites, transient position, zone, place name, sky darkness), `SettingsViewModel` (planning preferences), `SessionPlanViewModel` (the current session: night, target, rig, blocks, autosave, open/new/duplicate/save), `NightConditionsViewModel` (weather, timeline, Moon, imaging opportunity, candidates), `CaptureAnalysisViewModel` (budget, fit, fill window, capability, the Save snapshot), `StartupViewModel` (load order, bootstrap error and retry), and `GearViewModel` / `TargetsViewModel` / `SessionsViewModel` for the Library and Sessions screens. Screens no longer call repositories (DEV-A2, except the gated metadata import screen, G17). `AppViewModels` composes the graph; `main.dart` is the only place that picks implementations (DEV-A1). `PlannerViewModel` is deleted; tests build the same graph through `PlannerHarness` (`test/support/`). Moved-out domain helpers: `CurrentSession`, `SessionReferenceResolver`, `ExampleCapturePlan`, `SessionNightResolver.resolve`. The block list is exposed read-only. A test enforces no HTTP / SharedPreferences / Drift / Geolocator / data-layer import in a ViewModel and at most 250 code lines (300 physical) per ViewModel. TD-019, TD-021 and TD-044 resolved (field-mode persistence stays with TASK 12.4); TD-053 still open. No user-visible behavior change. Test baseline 631.
> **TASK 12.4 (2026-09-24, commit `3c27b15`):** semantic theme tokens and complete red field mode. `AppPalette` (a `ThemeExtension`: muted, night events, altitude chart, Bortle scale) for light, dark and field; `lib/presentation` names no colour itself — the 52 `Colors.*`/colour literals found (not the ~100 the roadmap estimated) now read `ColorScheme` or `AppPalette`. The field theme sets every `ColorScheme` role and theme colour to red or black, so dialogs, date pickers, snackbars and menus stay red. Owner decisions: (1) in field mode the whole app also goes through a red colour filter (R' = R + 0.7152 G + 0.0722 B, G' = B' = 0; Rec. 709 luma weights; pure red unchanged), covering map tiles and anything a token misses; (2) the gate is lifted in this task after the automated darkness checks, and the on-device check in real darkness is an owner checklist item. Field mode is persisted (`DisplayPreferencesRepository`, SharedPreferences) and restored before the first frame; one tap from Tonight and the planner (`FieldModeButton`) and a switch in Settings. `FeatureScope.fieldMode` is `true` (PD-06 schedule). No text under 12 sp; the section header's action keeps its 48 dp tap target. Light and dark look as before, except swipe-to-delete and the map pin now use the scheme's error colour and chart labels are 12 sp. F-46 Implemented; TD-044 fully resolved. Test baseline 651.
> **TASK 12.5 (2026-09-24, commit `b13f7c7`):** Tonight dashboard and first-run setup. Tonight shows the site and night, the night (sunset to sunrise, dark with the Sun below −18°), the Moon (% lit, when it is up), the weather (cloud range and age, or why there is no forecast) and the current session (status, target, rig or "No rig chosen", fit label with its one-line reason, usable time); each row drills down into the planner or a picker. Without a site, a site prompt replaces the night rows. No new calculations: the wording is shared with the planner (`WeatherText`, `MoonText`, `FitText` in `presentation/shared/night_text.dart`, moved out of the weather, sky and budget widgets). First run (owner decisions): a full-screen page (`/welcome`, above the tabs) with site (the location-permission rationale comes before "Use current position"), rig and target steps reusing the pickers; offered once, only on a start without a site; Skip, Done and back close it for good (`FirstRunRepository`, `TonightViewModel`). TD-054 recorded. Test baseline 665. **Group G12 is complete.**
> **TASK 13.1 (2026-09-24, documentation only, no code changed):** ADR-016 (execution model under Android constraints) accepted in Part F of DECISIONS with a state diagram and kill, reboot, clock and stale scenarios; PD-20 resolved. Owner decisions: opt-in keep-screen-on (a wakelock plugin approved for 13.3); one session in progress at a time; a session still in progress after its night ends gets a resume prompt and is never auto-finished; execution events in a new append-only `session_events` table (schema v17, TASK 13.2). Progress is derived from persisted UTC timestamps; estimated frames = running time ÷ (exposure + per-frame overhead), shown as an estimate and written only when the user confirms it; foreground only; no notifications, camera control, ASCOM or INDI.
> **TASK 13.2 (2026-09-24, commit `14467e7`):** execution state machine and persistence (ADR-016). A pure `ExecutionMachine` (domain) validates every transition per phase (not started, running on a block, paused, finished, abandoned), folds a run's events into its state, measures running time from UTC timestamps, stamps an event taken with a clock behind the last one at that event and flags it, estimates frames (CALC-35) and detects a run past its night. Schema v17 adds the append-only `session_events` table. `SessionRepository.start` records the start on the first light block and refuses a second session in progress; `record` stores an event and its counter projection in one transaction; `complete`/`abandon` close the run with an event. A resume prompt at start (Tonight) offers keep going, pause now, finish or abandon (confirmed), flags a finished night and a clock that went back, and changes nothing without an answer. No tracking screen yet (TASK 13.3). TD-055 recorded. Test baseline 760; schema v17.
> **TASK 13.3 (2026-09-24, commit `c8e2240`):** the tracking screen (`/session/:id/run`, ADR-016). The current block with confirmed and estimated counts; +1, −1, Reject, Accept estimate, Pause (plain or with a reason: clouds, wind, dew, equipment, other) / Resume, a block switcher and Finish / Abandon (confirmed) — all in the lower half, 56 dp, labelled for screen readers; countdowns to astronomical dawn, the target below its limit and moonrise; remaining window vs remaining plan (CALC-36). The tracker reads its night, target and Moon from the execution-start snapshot (`ExecutionOutlook`, pure), never from the planner. Owner decisions: Start is in the planner and on Tonight, with the same requirements as Save; after Start the planner goes on with a draft copy, and on a restart it resumes a copy when the most recent open session is running (TD-055 resolved). Tonight shows the run in progress; the resume prompt's Keep going opens the tracker. Opt-in keep-screen-on (off by default, persisted as `keepScreenOnWhileTracking`, only while the tracker is visible and a run is active) behind a `ScreenWake` interface, implemented with `wakelock_plus` 1.8.0 (BSD-3-Clause, verified on pub.dev; a screen wakelock only, no Android permission). Test baseline 780.
> **TASK 13.4 (2026-09-24, commit `c1e52ce`):** end-of-session reconciliation. A results page (`/session/:id/results`) with per-block confirmed and rejected steppers (each change a stored event), notes, optional conditions (temperature, humidity, cloud cover — empty means unknown, range-checked) and planned vs actual light integration (`SessionReconciliation`, CALC-37); Complete or Abandon. Owner decisions: the tracker's Finish opens this page and completes nothing by itself; after completion the counts may be corrected, each correction a timestamped confirm/reject event after `finished` (the only events allowed then; ADR-016 §11); Sessions shows planned vs actual integration and "Edit results" for completed sessions. `complete()` and every correction write the actual/rejected light-frame totals in the same transaction. No schema change (the condition columns existed). **Group G13 is complete.** Test baseline 795.
> **TASK 14.1 (2026-09-24, commit `e212f6a`):** Sessions list and detail. Filters by status (chips), target and site (pickers built from the saved sessions) and night date range, run in the query (`SessionRepository.list` gains `siteId`, `from`, `to`); legacy rows match a date range by their stored date and never a site or target filter, and carry a Legacy badge. Owner decisions: a tap opens the read-only detail (`/sessions/:id`); a started session shows its execution-start snapshot, a planned one its plan snapshot, labelled with when it was taken. The detail shows the night (window, zone, darkness limit, minimum altitude, usable time, windows), site (with Bortle/SQM), target, rig, budget, weather source, plan vs actual per block (CALC-37), notes and conditions, and the actions Open tracker / Edit results / Open in planner (a copy for frozen sessions) / Share. Legacy logs show their stored text only; a missing snapshot says so. Typed `SessionSnapshot` readers keep JSON out of widgets. No schema change. Test baseline 808.
> **TASK 14.2 (2026-09-24, commit `4274175`):** integration so far per target (owner: build it, although it was a roadmap cut line). `TargetProgress` (pure, CALC-38) sums confirmed light frames × exposure of completed, non-legacy sessions with a target, per filter, with the last imaged night and the session count; Library → Progress (`/library/progress`) lists every target, newest first, and a session's detail shows "This target so far". No project goals (out of scope); no schema change. Test baseline 814.
> **TASK 14.3 (2026-09-24, commit `a234ff6`):** export manifest v2 (schema in `docs/EXPORT_MANIFEST.md`). `SessionManifestCodec` (data layer) writes UTC epoch-ms instants, the night key and zone, status, the snapshots as stored, blocks with confirmed/rejected counts replayed from the events, results and conditions, and the run's event log (owner decision); it reads v1 as a legacy log and refuses unknown versions. `ShareSessionExporter` shares a `.json` file plus a text summary; owner decision: Export file on a session's detail and Export all in the Sessions app bar. Import deferred. `AppIdentity.version` stays in step with `pubspec.yaml` (tested). Test baseline 822.
> **TASK 14.4 (2026-09-24, commit `a847f87`):** backup and restore. Owner decisions: one `.astroplan` file (ZIP: header with format, schema and app version, time and session count; a consistent database copy made with `VACUUM INTO`; the v2 manifest) shared to a place the user picks; restore picked with `file_picker` 13.1.0 (MIT), checked (AstroPlan backup, header = the file's SQLite `user_version`, newer schema refused, below the v8 floor refused — older supported schemas are upgraded by the existing migrations), confirmed with a preview, staged, and applied at the next start before the database opens, the replaced database and its WAL kept as a safety copy. New dependencies `file_picker` 13.1.0 and `archive` 4.3.0 (both MIT, checked on pub.dev). Android Auto Backup: documented, not changed (owner decision). TD-056 recorded (preferences are not in the backup). Test baseline 835.
> **TASK 15.1 (2026-09-24, commits `aac1c6a`, `0854d0a`):** error handling and diagnostics — no silent failures. `AppLog` (`lib/core/diagnostics/`, pure Dart) is a local debug logger: `dart:developer` plus a bounded in-memory buffer (200 entries); nothing is written to disk or sent anywhere, and crash reporting is deferred for privacy (roadmap). It replaces every `debugPrint`, and every catch that used to swallow an error now logs it. `StorageFailure` (`lib/domain/repositories/`) is the typed failure every repository throws when its store cannot be read or written: the Drift repositories get it from one `StorageFailureInterceptor` on the `AppDatabase` connection (opening and migrations are not intercepted), the SharedPreferences repositories from `guardStorage`; domain refusals (`SessionStateError`, `ExecutionError`, `ArgumentError`) pass through unchanged. Failures become UI states: save, delete, select and export actions (rigs, targets, sites, sessions, results, Save/Start, New/Duplicate) show a message through `runWithFeedback`/`FailureText` (`presentation/shared/failure_feedback.dart`; the cause goes to the log, never onto the screen); Equipment, Targets, Sessions, session detail, Progress and Tonight candidates show `LoadFailureView` (with a retry where the page can reload) instead of looking empty, "no longer exists" or spinning forever. A failed autosave no longer leaves `CurrentSession`'s write chain failed (which silently dropped every later edit): it is kept in `writeFailure`, the next edit retries the whole plan, and the planner shows a banner. In `main.dart` a failure restoring the backup/run state no longer stops the first frame. `empty_catches` is enabled in `analysis_options.yaml`, and a source-scan test also rejects `catch (_) {}` and comment-only catches (which the lint allows). TD-029 resolved; TD-038 progress. Test baseline 857.
> **TASK 15.2 (2026-09-24, commit `2e923e6`):** performance and caching, measured first (desktop test VM, JIT): one planner rebuild read about 2.5 ms of derived values recomputed on every read (night timeline 0.2 ms, capture budget 0.25 ms, fit 0.6 ms, fill count 1.6 ms); moon and opportunity were already cached; tonight's candidates (164 catalog targets, on a background isolate since TASK 10.4) took about 95 ms. Now `NightConditionsViewModel` caches `nightTimeline` per night and `nightWeatherSummary` per (night, forecast state, dew margin); `CaptureAnalysisViewModel` caches the target's transit per (night, target position) and the budget, fit and fill count until an input notifies or the night changes (a night can roll over with the clock alone). A cached rebuild reads about 0.08 ms. No new isolates — nothing else exceeds a frame. Profile traces on a low-end device were not taken (no Android run yet): an owner checklist item in `TEST_PLAN.md`. No calculation changed. Test baseline 864.
> **TASK 15.3 (2026-09-24, commit `c191eb4`):** accessibility pass, audited first with Flutter's guideline matchers (every main screen, scrolled, in the light, dark and field themes at 100 % and 200 % text, on a 412 px-wide phone). Fixed: screen-reader labels (tooltips) on the Rigs/Targets add buttons and the capture plan's add/delete icon buttons; tap targets — the planner's Save/Start were squeezed to 40 px by the `BottomAppBar`'s fixed 80 px (now an intrinsic-height bar), the Open-Meteo attribution link and the About notice are 48 px; overflow — the sky card (it overflowed a 412 px phone even at 100 % text), the altitude-chart legend, the candidates' dropdowns, the budget lines, the fit row and the Sequence Plan header now wrap or ellipsize; a text alternative on the altitude chart (number of windows and usable time; the window list below it has the details). Focus order follows the layout (no custom traversal). Red mode: primary red on black is 5.25:1 (passes WCAG AA); the secondary red #AA0000 is 2.71:1 and stays below AA by design (dark adaptation) — documented, not changed; contrast is asserted in the light and dark themes. A TalkBack walkthrough on a device is an owner checklist item (no Android run yet). Test baseline 871.
> **TASK 15.4 (2026-09-24, commit `323cc23`) — OPEN: host rows done, device rows not run.** No Android device or emulator exists on the development machine (no AVD, SDK cmdline-tools missing, licenses not accepted); owner decision: automate every row that can run on the host, write the scripted manual matrix (`TEST_PLAN.md` § Lifecycle matrix, rows L1–L8), and keep the task open until the device rows pass. Host: `test/lifecycle/lifecycle_matrix_test.dart` — a fresh offline install with location denied; a kill while planning and during a run (file database closed and reopened: plan, night, target, site, field mode, counts and running time restored); rotation, dark mode and field mode keep typed input and every screen lays out in landscape; a site/zone change during a run leaves the tracker unchanged; a full disk while planning and tracking is reported and recovers. Found and fixed: a full disk was silent in the tracker's actions (they caught only `StateError`), keep-screen-on, Abandon on the results page, the resume prompt's Abandon/Finish/Pause, first-run Done and the field-mode toggle — all now report through `runWithFeedback`. The Android build itself has still never been run. Test baseline 878.
> **TASK 15.5 (2026-09-24, commit `4ead647`) — OPEN: host and Windows runs green, emulator run not possible here.** `integration_test/core_loop_test.dart` drives the real UI through the core loop — a site typed in the Sites editor, target and rig through the planner's pickers, the night, forecast and opportunity, Save, Start and three frames, a process death (the SQLite file closed) and a restart 45 minutes later with the resume prompt, Finish and Complete, the Sessions log and detail, and Export (the manifest v2 re-parsed) — plus the time-zone cases (a site zone different from the device zone; a run across New York's DST end, two hours of running time, UTC instants stored with the zone). Real database; the forecast, GPS, device zone and share sheet are fakes. New dev dependency: the SDK package `integration_test`. The quality gate gains an "E2E (host)" step (`flutter test integration_test -d flutter-tester`); the suite also passes as a native Windows app (`flutter run -d windows integration_test/core_loop_test.dart`) — the first native build of the app. `flutter test integration_test -d windows` fails inside flutter_tools (the `integration_test` plugin has no Windows part), not in the app. The roadmap's acceptance, green on an Android emulator, waits for a device (same blocker as TASK 15.4).
> **TASK 16.1 (2026-09-24, commits `92afaa4`, `98045f7`):** app identity (owner decisions, OD-07). Name **Astro Planner** (`AppIdentity.appName`, the one place: launcher label, every text that names the app, the user agent); Android application id **`io.github.chacha12.astroplanner`** (namespace and `MainActivity` package moved; `com.astroplan.astroplan` is gone); a simple original icon — the target's altitude arc over the horizon with its imaging window in red and a star, on night navy — as an adaptive vector icon with a monochrome layer, legacy PNGs and a 512 px store icon drawn by `tool/make_launcher_icons.py`; the Android 12+ splash and the pre-12 launch background use the same navy and icon. Kept on purpose (file formats, not branding): the `.astroplan` backup extension, the manifest's `"app": "AstroPlan"` and v1 `app_name`, the Dart package name. A preliminary web search (not a trademark clearance) found the same name in use: "Astro Planner" on Google Play (`com.astronomia.astro_planner`) and the App Store, both astrophotography planners — the owner chose it knowing this; the display name can change after publishing, the application id cannot. The Android build and install (the roadmap's test) were not run — no Android toolchain. Test baseline 881.
> **TASK 16.2 (2026-09-24, commit `09f16bf`) — OPEN: the signed bundle and the install test wait for the owner's upload key.** Release signing reads the upload key from the gitignored `android/key.properties` (Flutter's deployment guide); without it the release build falls back to the debug key with a Gradle warning (Play rejects debug-signed bundles). Decisions: R8 on for release (the Flutter plugin's default; mapping and native symbols in `BUNDLE-METADATA`); Play App Signing (Google keeps the app signing key, the owner's key is the upload key); `minSdk` 24 / `targetSdk` 36 from Flutter 3.47.4 (Play requires target 36 for new apps and updates from 31 Aug 2026); `versionCode` = pubspec's `+N`, raised for every upload. `tool/check_bundle.dart` checks a bundle before upload (16 KB ELF alignment, no debug sections, not debug-signed); `docs/RELEASE.md` is the procedure. **Verified:** `flutter build appbundle --release` built a 66.5 MB bundle — id `io.github.chacha12.astroplanner`, label Astro Planner, target 36, min 24, versionCode 1; 15 native libraries (arm64-v8a, armeabi-v7a, x86_64) all aligned to 16 KB or 64 KB, symbols stripped into `BUNDLE-METADATA`, R8 mapping present — debug-signed, since no upload key exists yet. Flutter's own symbol check fails only because SDK cmdline-tools are missing. **Correction:** TASKs 15.4/15.5 said the Android build had never run; in fact the owner built a debug APK on 2026-09-24 and the release bundle above now builds — the app has still not been installed or run on an Android device. Found: `flutter build ... --no-pub` after a debug build fails the release compile (the plugin registrant still lists the dev-only `integration_test`); release builds must run without `--no-pub`. Test baseline 889.

## 0. Start here (10-minute orientation)

1. Read this file, then `ARCHITECTURE.md` (Parts B–C), `FEATURE_STATUS.md`
   (summary table) and `TECH_DEBT.md` (Critical and High).
2. Baseline to expect: `flutter analyze` → no issues; `flutter test` → **147 pass,
   0 fail** (green since TASK 1.1; TD-003 resolved). Treat any failure as a
   regression.
3. **Scope is `docs/MASTER_ROADMAP.md`** (approved 2026-09-21, OD-06): one roadmap
   task per cycle, in order, each only after the owner's go-ahead. The condition of
   OD-03 (docs reconciled, roadmap exists) is met; `SessionNight` is group G2 and
   starts when the roadmap reaches it. Multi-file, architectural, database or
   scope-affecting work outside the current task requires a plan and approval first
   (`.agents/rules/00-project-governance.md`).
4. Traps that will bite (all verified):
   - `EquipmentProfile.id` is an **optical-rig id**, not a profile id.
   - The default `sessionDate` is the **UTC** calendar date; the picker and loaded
     logs use **local** dates (TD-001).
   - The `aperture` field means **f-number**, but one seed stores a diameter (SI-005).
   - `Provider<AppDatabase>` is registered but never read; `EquipmentCatalogRepository`
     is implemented but not registered; the `equipment_profiles` table is orphaned.
   - Do not trust the archived documents in `docs/archive/` (known inaccuracies).
   - `light_pollution_repository.dart` can never succeed; the Bortle badge is hidden
     by a feature gate; `fieldMode` gate is defined but never read.
5. Owner decisions that block the roadmap: PD-01, PD-02, PD-04, PD-08
   (`DECISIONS.md` Part E). PD-06 was resolved on 2026-09-21 (E.1).

## 1. What the project is

AstroPlan is a Flutter/Dart **mobile application for astrophotographers** that helps
plan, execute and document imaging sessions by combining equipment profiles, target
visibility, weather, Moon conditions and capture planning. Package `astroplan`,
Android application id `com.astroplan.astroplan`, version `1.0.0+1`, licence GPL-3.0.
Android is the initial platform; iOS is a future platform (ADR-001). It is a
**planner and logbook**, not a planetarium and not telescope-control software.

## 2. Why it exists

To answer one question: **"What can I realistically photograph during the available
night, with my current equipment?"** It complements tools such as Stellarium and
Stargazing Hub rather than replacing them (ADR-004). Scope that must **not** be built
unless explicitly requested: planetarium engines, 3-D sky simulation, telescope
hardware control, ASCOM/INDI, social features, authentication, cloud infrastructure
(`CLAUDE.md`).

## 3. Current product concept

**Workflow (Intended):**
Site → Target → Astronomical Conditions → Weather → Equipment → Imaging Opportunity →
Capture Plan → Execution → Logbook.

**Central idea (Intended):** available imaging opportunity → capture budget →
concrete exposure plan → session execution → automatic/low-friction logbook. The
**Capture Planner / Session Budget is the central component.**

**Concepts that must stay distinct** (CLAUDE.md) and their actual status:

| Concept | Status in code |
| --- | --- |
| Astronomical darkness | **Partial** — Sun ≤ −18°, evaluated for the wrong night by default |
| Target visibility window | **Partial** — altitude ≥ a minimum; no horizon, no Moon |
| Environmental conditions | **Partial** — weather displayed, not combined with anything |
| Imaging Opportunity | **Missing** |
| Integration time | **Partial** — sum of light exposures |
| Acquisition time | **Missing** as a separate concept (folded into one number) |
| Total session budget | **Partial** — one number that mixes all frame types plus a flat overhead |

Product principles to preserve: no arbitrary black-box "Astro Score" — any scoring
must be a transparent model; sqrt(N) is a *relative stacking-gain* approximation and
never physical SNR; ISO is never presented as increasing photon collection;
thresholds are not universal laws.

## 4. Actual architecture

Summary (full detail, diagrams and deviations: `ARCHITECTURE.md`):

- *(Since TASK 12.3 the two bullets below are historical. Screens watch screen-scoped
  ViewModels (Site, Settings, SessionPlan, NightConditions, CaptureAnalysis, Startup,
  Gear, Targets, Sessions) over domain interfaces; `main.dart` composes them through
  `AppViewModels`; tests use `PlannerHarness`. DEV-A1 and DEV-A2 resolved.)*
- **MVVM-style with Provider.** `Presentation → PlannerViewModel → repositories →
  Drift/HTTP`, but several screens call repositories directly and the ViewModel
  itself calls HTTP and SharedPreferences; GPS is behind the injected
  `LocationService` since TASK 1.1 (DEV-A1, DEV-A2).
- **`PlannerViewModel`** (513 lines) owns bootstrap, selection, session date,
  location, reverse geocoding, Bortle, weather, the capture plan, thresholds and ten
  derived calculations. It is started from the constructor and cannot be awaited.
- **Domain** (`lib/domain/`, pure Dart except `MetadataExtractor`): astronomy and
  optics calculators, models, repository interfaces. **Data** (`lib/data/`): Drift
  database (schema v9), repositories, seeders, an HTTP weather repository, and a
  concrete, non-functional `LightPollutionRepository`.
- **Routing:** static go_router with six routes (two gated by `FeatureScope`).
- **Composition root:** `main.dart`, manual wiring, seeding unawaited after `runApp`.

## 5. Actual technology stack

Flutter 3.47.4 / Dart 3.13.3 (`sdk: ^3.13.3`); Provider + `ChangeNotifier`; go_router
18; Drift 2.35 over SQLite (sqlite3 3.5.2); shared_preferences; http; geolocator;
flutter_map + latlong2; image_picker + exif; share_plus; url_launcher. Details in
section 21.

## 6. Current features (Implemented — verified working)

App shell, DI and routing; preference persistence; astronomy core (JD, GMST, LST,
altitude); altitude chart; target selection/search/custom-target CRUD; equipment
profile CRUD; pixel scale. (7 of 50 features; full list: `FEATURE_STATUS.md`.)

## 7. Partial features

Drift persistence and migrations; feature gating; seed data/bootstrap; active
location; saved locations (storage only); session-date picker; Sun/night timeline;
visibility windows; lunar illumination; equipment composition; FOV (computed, never
shown); storage estimate; weather fetch/cache and display; capture-plan editor;
session duration and feasibility; integration time and stacking gain; save session;
logbook list/reload/share; planned-vs-actual fields (no entry UI); tests; platform
support. (22 features.)

## 8. Broken features

- **Default "tonight" resolution** (F-09): the UTC calendar date is used, so evening
  planning west of UTC shows the next night — verified (TD-001).
- **NPF exposure** (F-26): formula deviates from the published one; not shown in the
  UI (TD-007).
- **Light-pollution auto-fetch** (F-32): the request URL is malformed; it can never
  succeed (TD-006).
- **External light-pollution map link** (F-34): opens hard-coded Slovenia
  coordinates (TD-014).

Known **defects inside Partial features:** capture-block reorder-down off by one;
Save Session duplicates and stores no snapshot; storage shows `0.0 MB` when unknown;
a v3 → v9 migration throws (TD-004, TD-010, TD-011, TD-013). *(At the audit: also
the integration test failing (TD-003, resolved TASK 1.1) and a first-launch seeding
race with a Home dead-end (TD-002, largely resolved TASK 1.2 — see `TECH_DEBT.md`
for what remains open).)* *(Since resolved: TD-004 TASK 3.2; TD-010 and the
duplicate-save half of TD-011 TASK 4.1/4.2 — see `TECH_DEBT.md`.)*

## 9. Missing features

Site time-zone handling; Moon position, rise/set and Moon–target separation; horizon
model; moving-object targets; **Imaging Opportunity**; calibration-frame planning;
session execution mode; custom dashboard (not in the roadmap); CI. (9 features.)
Prototypes (8): sky-darkness warning, curated catalog, optical multipliers, dew
warning, manual Bortle entry, export manifest, metadata import, field mode.

## 10. Data model

Full detail: `DATA_MODEL.md`.

- **Stores:** Drift SQLite `astroplan.sqlite` (schema **9**, 8 tables), shared
  preferences (six keys + weather cache), in-memory ViewModel state.
- **Tables:** `devices`, `camera_modules`, `optical_rigs` (equipment, always 1:1:1),
  `equipment_profiles` (**orphaned/Deprecated**), `location_profiles`, `astro_targets`,
  `session_logs`, `capture_blocks`. Foreign keys declared but **not enforced**.
- **Domain models:** `AstroTarget`, `EquipmentProfile` (flat projection of rig +
  camera + device), `CaptureBlock`, `SessionLog`, `LocationProfile`,
  `WeatherConditions`/`HourlyForecast`, `VisibilityWindow`, `ImageMetadata`,
  plus dormant `EquipmentDevice`, `CameraModule`, `OpticalRig`.
- **Migration status:** fresh installs and v8 → v9 work; v3 → v9 throws; no migration
  tests (DEV-D1).
- **Future concepts (do not create without design review):** Site, Target, Equipment,
  Session, CapturePlan, CaptureBlock, WeatherSnapshot, ImagingOpportunity,
  ExecutionState, LogbookEntry (`DATA_MODEL.md` Part C).

## 11. Astronomy logic

`lib/domain/services/{astronomical_engine,visibility_calculator}.dart`,
`lib/core/utils/astro_math.dart`. Per-function register with units, method,
assumptions and tests: `SCIENTIFIC_INTEGRITY.md` Part B.

- Julian date (Meeus), linear GMST, LST, geometric altitude, low-precision Sun.
- Night timeline: Sun crossings −0.833°, −6°, −12°, −18° on a **5-minute** scan.
- Visibility windows: Sun ≤ −18° **and** target ≥ minimum altitude (default 20°).
- Coordinates: J2000 RA/Dec in **degrees**; no precession/refraction (SI-009).
- Lunar illumination: mean-synodic model, ≤ 4.7 pp error against USNO 2025 (SI-002).
- **Time base is inconsistent** (SI-010): UTC default date, local solar date inside
  the calculators, device-local noon in the chart, device-local display.
- Deterministic and unit-tested for core routines, but the Sun model and window
  logic have no reference-ephemeris tests.

## 12. Weather

Open-Meteo forecast API (no key; `models=icon_seamless` hard-coded; `timezone=auto`);
`OpenMeteoWeatherRepository` returns current values plus 48 hourly entries and
caches the last result per ~1.1 km cell in shared preferences, falling back to it
silently on any error.

Issues (TD-017): not date-aware (always "now"); hourly arrays start at local
midnight; timestamps are naive site-local strings parsed as device-local;
`utc_offset_seconds` discarded; no staleness limit or indicator; no provenance;
startup waits on it. The live query for London returned no nulls (checked
2026-09-21). Dew warning logic exists but is never shown.

## 13. Location

Active location comes from GPS (`geolocator`) or a `flutter_map` picker; the ViewModel
defaults to **London** until one is set and reverse-geocodes via Nominatim (HTTP call
inside the ViewModel, errors swallowed). `setLocation` **overwrites the coordinates of
the single active saved profile**; there is no UI to list or switch saved locations.
No time zone is stored. Bortle defaults to 4 with no "unknown" state; automatic Bortle
lookup is broken and the manual badge is hidden (SI-007). OSM tiles are used without
attribution. iOS location permission strings are missing.

## 14. Equipment

Profiles are created/edited/deleted in `EquipmentSelectionScreen` (validated form;
sensor size auto-derived from resolution × pixel pitch). Persistence is normalized
(Device → CameraModule → OpticalRig, one of each per profile); the UI and domain see
a flat `EquipmentProfile`. Tracking state is stored but not exposed; optical
multipliers were removed; `EquipmentCatalogRepository` is unused. **Five seeded
profiles** (four phones, one ASI2600MC "telescope stub") — the ZWO seed has
`aperture: 72.0` in an f-number field and no seed has a RAW size; specs are
unverified (SI-005, SI-011). Pixel scale is shown; FOV and NPF are computed but not
shown.

## 15. Capture planner

`CapturePlanWidget` + ViewModel. Blocks: frame type (light/dark/flat/bias), filter,
exposure, count (binning and gain/ISO exist in the model but not in the UI). Default
plan 100×60 s lights, 20×60 s darks, 20×2 s flats, persisted as JSON in preferences.
Outputs: **Session Duration** (all exposures + 5 s per frame), **Feasibility**
(Feasible / Tight above 85 % / Infeasible vs summed visibility windows),
**Integration Time** (lights only), **Stacking Gain (Relative SNR)** (√ light frames —
label deviates from ADR-005), **Estimated Storage** (empirical size × frames; `0.0 MB`
when unknown). Defects: reorder-down off by one; silent defaults on invalid input;
no edit UI; budget conflates integration, acquisition and calibration; the live math
has no tests (TD-010, TD-012, TD-022, TD-025).

## 16. Session

There is no separate Session entity. The "session" is the ViewModel's implicit state
(selected target/equipment, `sessionDate`, location, plan) plus an optional loaded
`SessionLog`. **Execution mode does not exist.** New Session resets the loaded log
and date but keeps the plan (`DATA_MODEL.md` C4).

## 17. Logbook

`SessionLog` rows + `capture_blocks`. **Save Session** stores names, date, planned
light frames and blocks (twice-tap = duplicate; snapshot fields stay null). The
Logbook lists sessions (unordered), reloads one into the planner (re-matching target
and equipment **by name**), deletes by swipe (no confirmation) and shares plain text.
Fields for actual frames, rejected frames and notes exist but **no UI sets them**.
A JSON manifest v1 exists and is used only by tests. Gated by `FeatureScope.logbook`
(currently `true`; ahead of its roadmap phase).

## 18. Metadata

Gallery picker → `MetadataExtractor` (EXIF via the `exif` package; a hand-written FITS
header parser) → read-only cards. **Prototype:** FITS cannot be selected through the
gallery picker; whole files are read into memory; nothing is stored or linked to
equipment/sessions; only synthetic-input unit tests exist; ROADMAP Phase 12 requires
verification against real sample files, which the repository lacks (TD-018).

## 19. Tests

147 tests in 29 files: domain services (astronomy, optics, session feasibility,
visibility windows plus the new SessionNight-based timeline/windows/altitude-curve
suite, metadata parsing, session log, the session-night resolver and its
ADR-007 matrix, calendar date, clock), Drift repositories and database,
the Open-Meteo repository (mocked client), form-validation widget tests for the
Equipment and Target screens, four ViewModel suites (session date, minimum altitude,
location, bootstrap), an app-boot widget test, one end-to-end flow, a Home
widget-test suite (empty state, default-location banner, weather failure, bootstrap
failure), and the altitude chart's first widget test (normal night, polar-night
site, no-"now"-dot case). *(At the audit, 71 tests in 21 files, 1,757 lines; TASK 1.1
added the location suite; TASK 1.2 added the bootstrap and Home suites; TASK 2.2
added 52 session-night, calendar-date and clock tests; TASK 2.3 added 12 more —
9 SessionNight-based calculator tests, 3 altitude-chart widget tests.)*

- **Result:** 665 pass, 0 fail (`dart run tool/check.dart` after TASK 12.5; 651 after TASK 12.4; 631 after TASK 12.3; 625 after TASK 12.2; 620 after TASK 11.4; 613 after TASK 11.3; 598 after TASK 11.2; 584 after TASK 10.4; 577 after TASK 10.3; 572 after TASK 10.2; 547 after TASK 9.4; 535 after TASK 9.3; 521 after TASK 9.2; 511 after TASK 8.6; 500 after TASK 8.5; 483 after TASK 8.4; 463 after TASK 8.2; 451 after TASK 8.1; 420 after TASK 7.4; 404 after TASK 7.3; 379 after TASK 7.2; 347 after TASK 7.1; 327 after TASK 6.5; 319 after TASK 6.4; 309 after TASK 6.3; 299 after TASK 6.2; 291 after TASK 5.6; 282 after TASK 5.5; 268 after TASK 5.4; 249 after TASK 5.3; 229 after TASK 5.2; 147
  after TASK 2.3; 135 after TASK 2.2; 83 after TASK 1.2). The
  audit's red `integration_flow_test.dart` (TD-003) was repaired, not weakened.
- **Gaps:** no tests for the live budget math, Capture Plan, Sky, Altitude chart,
  Logbook, Location or Metadata screens; no migration tests; the NPF test is
  circular; `AppRouter.router` is a shared static (the new Home tests reset it in
  `setUp()` to avoid cross-test leaks — a workaround, not a fix); no CI. See
  `TEST_PLAN.md`.

## 20. Build

| Task | Command | Verified? |
| --- | --- | --- |
| Install dependencies | `flutter pub get` | Yes (implicitly) |
| Analyze | `flutter analyze --no-pub` | **Yes** — clean |
| Test | `flutter test --no-pub` | **Yes** — 147/147 (after TASK 2.3; 135 after TASK 2.2; 83 after TASK 1.2; was 70/71 at the audit) |
| Regenerate Drift code after changing tables | `dart run build_runner build --delete-conflicting-outputs` | **No** (standard `drift_dev` step; not run) |
| Run on Android | `flutter run` | **No** — no device/emulator run in the audit |
| Release build | `flutter build appbundle --release` (without `--no-pub`), then `dart run tool/check_bundle.dart` | **Builds** (2026-09-24, TASK 16.2) — debug-signed until the owner creates the upload key and `android/key.properties`; procedure in `docs/RELEASE.md` |

Notes: Windows development machine; `core.autocrlf=true` (line-ending warnings are
normal); prefer `--no-pub` to avoid unintended `pubspec.lock` changes; `sdk: ^3.13.3`
requires a very recent Dart.

## 21. Dependencies

| Package | Constraint | Used for | Notes |
| --- | --- | --- | --- |
| provider | ^6.1.5+1 | State management / DI | — |
| go_router | ^18.0.1 | Routing | Static singleton router |
| drift, drift_dev, build_runner | ^2.35.0 / ^2.35.0 / ^2.16.1 | Database + codegen | Generated file committed |
| sqlite3_flutter_libs | ^0.6.0+eol | Native SQLite | **EOL marker**; not imported; confirm the bundled SQLite on a device (resolved `sqlite3` 3.5.2) |
| path_provider, path | ^2.1.6, ^1.9.1 | DB file location | — |
| http | ^1.6.0 | Weather, Nominatim, ClearOutside | Used inline in the ViewModel and repositories |
| shared_preferences | ^2.5.5 | Plan, ids, thresholds, weather cache | Used inline |
| geolocator | ^14.0.3 | GPS | `GeolocatorLocationService` (behind `LocationService`, used by the ViewModel) and the picker |
| flutter_map, latlong2 | ^8.3.2, ^0.10.1 | Map picker | OSM tiles, no attribution |
| image_picker, exif | ^1.2.3, ^3.3.0 | Metadata import | Gallery only; no FITS |
| share_plus | ^13.3.0 | Share log text | — |
| url_launcher | ^6.3.2 | External map link | — |
| cupertino_icons | ^1.0.8 | — | **Unused** (template leftover) |
| flutter_lints | ^6.0.0 | Lints | Default rule set only |

`.agents/skills/` holds third-party agent skills (from `flutter/skills` via
`skills-lock.json`, plus an unrelated Google ADK skill); they are not project logic.

## 22. Technical debt

46 tracked items in `TECH_DEBT.md` (6 Critical, 15 High, 17 Medium, 7 Low, at the
audit), plus a carry-forward map from the previous register. Critical: TD-001 UTC
default night; TD-002 non-deterministic startup and Home dead-end (**largely
resolved 2026-09-21, TASK 1.2** — see `TECH_DEBT.md` for what is still open);
TD-004 migrations; TD-006 dead light-pollution fetch;
TD-007 NPF formula; TD-009 "Relative SNR" label. Also resolved since the audit:
TD-003 (TASK 1.1), TD-041 (TASK 0.2).

## 23. Scientific risks

Register with the required format (Scientific Issue / Current Behavior / Correct
Interpretation / Required Future Action): `SCIENTIFIC_INTEGRITY.md`.

| ID | Risk |
| --- | --- |
| SI-001 | NPF formula constant 90 vs published `0.1·F`; circular test |
| SI-002 | Moon: mean-phase (≤ 4.7 pp), shown to 0.1 %; no Moon geometry |
| SI-003 | √N gain labelled "Relative SNR"; ignores sub-exposure length |
| SI-004 | ISO/gain must stay descriptive; never "sensitivity" |
| SI-005 | `aperture` = f-number but one seed is a diameter; unit-less names |
| SI-006 | Hard-coded thresholds (20°, −18°, 0.8, Bortle 7, 85 %, 5 s, 2.0 °C) |
| SI-007 | Bortle defaults to 4; no unknown state; no working source |
| SI-008 | Unknown shown as zero/default (`0.0 MB`, Bortle 4, London) |
| SI-009 | Simplifications undocumented (J2000, no refraction, 5-min steps) |
| SI-010 | Night/date/time-zone semantics wrong by default |
| SI-011–013 | Seed provenance; target units/moving objects; storage assumptions |

## 24. Security concerns

- **Secrets:** none in the repository; no API keys are needed by any current service
  (a keyed light-pollution API would require secret handling — never hard-code).
- **Privacy:** precise GPS coordinates are sent to Open-Meteo and Nominatim; the
  weather cache key stores rounded coordinates in unencrypted preferences; the
  database is unencrypted in the app documents directory; no analytics or crash
  reporting exists.
- **Permissions:** Android declares fine/coarse location and internet (verified).
  iOS `Info.plist` declares no location or photo usage strings.
- **Untrusted input:** user-selected images are read entirely into memory and parsed
  by `exif` and a hand-written FITS parser (memory/robustness risk, TD-018); remote
  HTML is regex-parsed (dead path).
- **Build/release:** *(updated TASK 16.2)* release builds take the owner's upload key from `android/key.properties` (debug key only as a fallback); R8 shrinking on; see `docs/RELEASE.md`.
- **Third-party terms:** scraping ClearOutside; OSM tile and Nominatim usage
  policies; Open-Meteo's free tier is for non-commercial use — review before any
  distribution (PD-12). The repository is GPL-3.0; confirm intent for store
  distribution.

## 25. Known inconsistencies (code vs code, code vs docs)

1. `EquipmentProfile.id` is a rig id; flat model over normalized storage.
2. `SessionLog.bortleScale` is `double?`; `LocationProfile.bortleClass` is `int`.
3. `capture_blocks.frame_type` comment says uppercase; the stored value is lowercase.
4. `sessionDate`: UTC (default) vs local (picker, loaded log, DB read-back).
5. `aperture` semantics vs the ZWO seed; `manufacturer` means device brand for some
   seeds and sensor vendor for others.
6. Reverse-geocode comment says Open-Meteo; the code calls Nominatim.
7. `FeatureScope` says `fieldMode`, map handoff and Bortle are gated; only the Bortle
   badge is; `metadataImport`/`logbook` are `true` although ADR-006 lists them as
   initially disabled.
8. `SessionCalculator.estimateTotalDuration` and `calculateFOV` are tested but unused;
   `app_database_test` exercises the orphaned table; `EquipmentCatalogRepository` is
   tested but unregistered.
9. The integration test seeds Orion with RA `5.59` (hours) in a degrees domain.
10. Drift row classes share names with domain models (`import … as domain` workarounds).
11. `ROADMAP.md` lists `GEMINI.md` (git-ignored, absent); `CLAUDE.md` is the agent file.
12. `pubspec.yaml` description is the Flutter default; `cupertino_icons` is unused.
13. The archived previous documents contradict the code on 20+ points
    (`PROJECT_AUDIT.md` §4).

## 26. Git and repository state (2026-09-21)

- `main` at `900b82a`, 15 commits, no tags, no stash; remote `origin/main`.
- Documentation edits from this reconciliation are **uncommitted** and ready to
  commit (`.gitignore` no longer ignores any source-of-truth document; verified with
  `git check-ignore --no-index` and `git add --dry-run`).
- Working-tree changes are documentation and `.gitignore` only; nothing under `lib/`,
  `test/`, `android/`, `ios/` or `pubspec.*` differs from `HEAD`.
- Committed but junk-like files (patch scripts, empty lockfile) are listed in
  TD-030 and were **not** removed.

## 27. Open decisions and proposed next steps

Open decisions (owner): `DECISIONS.md` Part E — especially **PD-01/PD-02** (night
and time zone), **PD-04** (persistence baseline), **PD-08** (capture-budget model).
(PD-06, the active scope, was resolved 2026-09-21.)

Proposed sequence for the Master Development Roadmap (**not approved**):
`PROJECT_AUDIT.md` §8 and `TECH_DEBT.md` dependency notes. In short: settle the time
and site model → deterministic startup and a green suite → persistence baseline →
scientific-integrity pass → capture-budget domain → seams in the ViewModel →
Imaging Opportunity → logbook actuals → light-pollution decision → catalog and
framing.

## 28. Document map

| Document | Contains |
| --- | --- |
| `CLAUDE.md` | Agent rules, doc map, conventions, baseline |
| `docs/PROJECT_HANDOFF.md` | This file |
| `docs/ARCHITECTURE.md` | Design intent · **current** architecture · deviations · **target** direction |
| `docs/DATA_MODEL.md` | Design intent · **current** entities · deviations · **future** concepts |
| `docs/FEATURE_STATUS.md` | 50-feature registry with status and known issues |
| `docs/TECH_DEBT.md` | 46-item debt register (TD-###) |
| `docs/DECISIONS.md` | ADRs (verbatim) · conformance · owner directives · open decisions (PD-##) |
| `docs/SCIENTIFIC_INTEGRITY.md` | Scientific issue register (SI-###) and calculation register |
| `docs/PROJECT_AUDIT.md` | Point-in-time audit, evidence, discrepancy log, rule matrix |
| `docs/IA_WIREFRAMES.md` | Information architecture (ADR-015): tabs, route map, field constraints, low-fidelity wireframes *(TASK 12.1)* |
| `docs/PRODUCT_SPEC.md`, `ROADMAP.md`, `TEST_PLAN.md` | Product intent, phases, test strategy (intent + baseline) |
| `.agents/rules/` | Governance, architecture, quality, testing, scientific, UI rules |
| `docs/archive/2026-09-21-previous-agent-audit/` | Superseded documents (historical only) |
