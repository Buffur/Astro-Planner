# AstroPlan Feature Status

> **Independent Stage 1 validation, 2026-09-25, code `4e653fb`:** S1.5 recovery
> is broken on the production background connection (TD-059), with a conditional
> reset-seeding gap (TD-060). S1.6's safeguard is partial (TD-061/062).
> This supersedes their earlier closure claims below; no code changed. See
> [Stage 1 validation](refinement/STAGE_1_VALIDATION.md).

> **Verification stamp:** verified against code at commit `900b82a` (2026-09-20),
> audited 2026-09-21. Application code changed since by TASK 1.1 (commit `2357755`),
> TASK 1.2 (`2e17093`: deterministic bootstrap, Home empty/error states) and TASK 1.3
> (`94acd71` whole-tree format, `97924a0` quality-gate script and CI); affected
> entries are F-05, F-06, F-48 and F-49. **TASK 2.2 (2026-09-22):** new pure-domain
> `SessionNight` resolver and `Clock`, not yet used by the app; affected entries are
> F-09, F-10 and F-48. **TASK 2.3 (2026-09-22, commit `de1792a`):** the calculators
> and the altitude chart consume `SessionNight`; affected entries are F-12, F-13,
> F-14 and F-48. **TASK 2.4 (2026-09-22, commit `1e58fcf`):** the ViewModel resolves
> a real `SessionNight` (default = the window containing "now", via an injectable
> `Clock`) instead of `DateTime.now().toUtc()`, and Home, the sky-darkness timeline,
> the altitude chart and the logbook consume it through one shared
> `NightTimeFormatter`; affected entries are F-08, F-09, F-12, F-13, F-14, F-15.
> **TASK 3.2 (2026-09-22, commit `3c25e8c`):** migration floor/downgrade guards,
> transactional migrations, schema snapshots and a migration test suite;
> affected entry is F-02. **TASK 3.3 (2026-09-22, commit `e580d03`):** foreign
> keys enforced, orphan cleanup, `equipment_profiles` dropped; affected
> entries are F-02 and F-23. **TASK 4.1 (2026-09-22, commit `f5b29cc`):**
> capture-block reorder fixed, an edit dialog added, invalid input rejected
> by validators, and stable list-item keys; affected entry is F-35.
> **TASK 4.2 (2026-09-22, commit `7641d49`):** `addLog` returns the new row's
> id so a second Save updates instead of duplicating; target/equipment
> selections refresh after an edit or delete; the logbook orders
> newest-first and confirms before deleting; affected entries are F-03,
> F-19, F-22, F-40, F-41. **TASK 4.3 (2026-09-22, commit `576c069`):**
> mojibake fixed and an encoding check added to the quality gate;
> `FeatureScope.metadataImport` now matches PD-06, and every entry point
> (Home's field-mode toggle, Import Metadata button, light-pollution map
> card) reads it; affected entries are F-04, F-22, F-34, F-46. **TASK 4.4
> (2026-09-22, commit `514dcc5`):** stacking-gain label corrected, storage
> and pixel-scale unknowns render as "Unknown" instead of `0.0`/`null`, the
> RA/Dec `(0, 0)` sentinel removed, the default plan labeled "Example plan",
> the sky warning reworded, and the seeded telescope aperture corrected;
> affected entries are F-28, F-35, F-37. Statuses
> were assigned from the code and from executed reproductions, not from
> earlier documentation.
> **TASK 5.2 (2026-09-22):** planning preferences (`PlanningPreferences` + repository) and a Settings screen; the planner selection state moved behind `PlannerStateRepository`; `PlannerViewModel` no longer imports SharedPreferences. Affected entries: F-03, F-13, F-31, F-48.
> **TASK 5.3 (2026-09-22):** `CaptureBlock` validates at the domain boundary and gains a calibration policy and a typed, descriptive-only gain; schema v11 adds block `position`, `calibration_policy`, `gain_kind`/`gain_value` and drops the free-text `gain_iso` (owner-approved); migrations now use generated per-version step shapes (`schema_versions.dart`). Affected entries: F-35, F-39, F-48.
> **TASK 5.4 (2026-09-22):** `CaptureBudgetCalculator` (CALC-25) implements the ADR-009 budget; the ViewModel only delegates; feasibility now uses the window load (calibration outside the window no longer counts against dark time); the dead `estimateTotalDuration` (CALC-19) was deleted. Affected entries: F-36, F-39, F-48.
> **TASK 5.5 (2026-09-22):** `FitAnalyzer` (CALC-26) places the ADR-009 event sequence atomically into the windows and reports fits / tight / does not fit / no window / nothing to fit with a reason, end time, lost tails, unplaced frames, the inverse maximum and a similar-nights hint; the sum-of-windows `SessionCalculator` (CALC-18) was deleted. Affected entries: F-36, F-48.
> **TASK 5.6 (2026-09-22):** the capture planner UI shows every ADR-009 line (integration, acquisition, calibration in/outside the window, setup, window load vs available, session budget), the fit with its reason and end time, a one-tap "fill / trim to tonight's window" action, √N per (filter, exposure) group with help text, storage or "Unknown", and an assumptions panel; the block editor sets the calibration policy, binning and a typed gain. `capture_plan_widget.dart` was split into `widgets/capture_plan/`. Group G5 is complete. F-35 and F-37 → Implemented; F-39 Missing → Partial; F-36 and F-48 updated.
> **TASK 6.2 (2026-09-22):** independent reference fixtures (USNO events and celestial-navigation altitudes, JPL Horizons Sun elevations, SIMBAD J2000 star positions; `test/fixtures/astronomy/`) and tolerance tests; target coordinates are now precessed J2000 → date (Meeus ch. 21, owner decision) in the one domain target-altitude function; altitudes stay airless with the −0.833° sunrise/sunset convention (owner decision); source/units/error doc comments on the astronomy functions. Affected entries: F-11, F-13, F-14, F-48.
> **TASK 6.3 (2026-09-22):** a pure-domain Moon ephemeris (`MoonCalculator`, Meeus ch. 47 full tables in `moon_series.dart`, ADR-010) — position, topocentric altitude, illuminated fraction, phase longitude, rise/set on the night grid — verified against JPL Horizons and USNO well inside ADR-010 §4. **Not used by the app yet** (TASK 6.4 wires it and retires the mean-phase model). F-16 Missing → Partial; F-48 updated.
> **TASK 6.4 (2026-09-22):** `MoonConditions` (Moon altitude, separation from the target, rise/set, illumination at mean solar midnight, closest approach while both are up) from `MoonCalculator`, shown on the sky card as annotations; the mean-phase `calculateLunarIllumination` was deleted. F-15 and F-16 → Implemented; F-48 updated.
> **TASK 6.5 (2026-09-22):** the NPF rule now follows F. Michaud's primary source (derivation on sahavre.fr), with an explicit k (default 1, range 1–3); the circular test is replaced by independent worked examples. Still hidden (PD-11). Group G6 is complete. F-26 Broken → Partial (correct but hidden); F-48 updated.
> **TASK 7.1 (2026-09-23):** site semantics in schema v12 (nullable Bortle with source and date, SQM, IANA zone, notes; default Bortle 4 cleared with a note); a map pick or GPS fix is a transient, remembered position that never writes into a saved site; the `timezone` package (0.11.1, BSD) backs an `IanaTimeContext`, so a site's zone drives its night (ADR-007 L1 fixed for sites with a zone) and the display. Affected entries: F-06, F-07, F-10, F-33, F-48.
> **TASK 7.2 (2026-09-23):** location and geocoding behind domain interfaces. `LocationService` reports each permission outcome (`LocationFound`, or `LocationUnavailable` with `serviceDisabled` / `permissionDenied` / `permissionDeniedForever`) and opens the matching settings page; the location picker explains each outcome (rationale text + "Open settings") and no longer calls Geolocator. A `ReverseGeocoder` interface with a `NominatimReverseGeocoder` (identifying user agent `AstroPlan (com.astroplan.astroplan)`, at most 1 request/s, in-memory cache by coordinates rounded to 0.01°, failures reported, not cached) replaces the ViewModel's inline HTTP; OpenStreetMap attribution on the map and next to place names; the tile user agent is the real app id; typed coordinate entry works offline. No `http`/`geolocator` import in presentation or domain (test-enforced). F-06 updated (still Partial).
> **TASK 7.3 (2026-09-23):** sites UI. A Sites screen (`/sites`) lists saved sites with the active one marked; sites can be selected, created, edited and deleted (with confirmation); "use current position" and "pick on map" set a transient position, which can be saved as a site. The site editor (`/sites/edit`) validates name, latitude/longitude (typed or picked on the map), elevation (m), an IANA zone picker defaulting to the device zone, and notes; Bortle/SQM with their source sit behind `FeatureScope.lightPollutionContext` until TASK 7.4. Owner decisions: `flutter_timezone` 5.1.0 (Apache-2.0) behind a domain `DeviceTimeZone` seam, only to pre-fill the zone picker; the first run shows a site prompt instead of a silent GPS request; deleting the active site keeps its position as the transient position. `IanaTimeContext` now loads the `latest_all` zone data set (the 10-year set has no link zones such as `Europe/Ljubljana`). F-07 Partial → Implemented; F-06 and F-10 updated.
> **TASK 7.4 (2026-09-23):** light-pollution MVP (PD-05 resolved). The ClearOutside scraper (`LightPollutionRepository`) is deleted, with its ViewModel argument, provider and per-location-change call; a location change makes no network call beyond weather and the place name. Option A: the external light-pollution map opens centred on the current position (`LightPollutionMapLink`), only when one exists. Option B: manual Bortle and/or SQM in the site editor, stored as source `user` with the date. `FeatureScope.lightPollutionContext` is `true` (its PD-06 phase). The sky card shows the known values with their sources (`SkyDarkness`), "not saved" for a transient position, or "unknown"; Bortle and SQM are never converted into each other; the sky warning still uses a known Bortle class only. Options C (offline dataset) and D (licensed API) are documented as deferred. Group G7 is complete. F-32 Broken → Deprecated (removed); F-33 Prototype → Implemented; F-34 Broken → Implemented; F-04 updated.
> **TASK 8.1 (2026-09-23):** target model hardening, schema v13. `astro_targets` gains `epoch` (default and only supported value `J2000`), `source` (ADR-008 §6: `user`, `seed:catalog@1`; NULL for legacy rows, never guessed), `angular_size_arcmin` and `magnitude` (unknown by default); a partial unique index makes catalog entries (`seed:`/`catalog:` sources) unique per catalog id. Pure parsers in `AstroMath` accept RA as h:m:s, `05h35m17s` or decimal hours (degrees only with a `°` suffix) and Dec as d:m:s, `−05°23′28″` or decimal degrees, the sign applying to the whole value (`−0°30′` works). The editor formats stored values, keeps an untouched field's exact value, never changes the catalog id (the repository no longer writes it on update), offers fixed-coordinate types only and labels existing moving-type targets (ADR-010 §3; also on Home); an edit of coordinates, size or magnitude makes the source `user`. Search escapes `LIKE` wildcards. G8 has started. F-19 updated (stays Implemented); F-20 and F-21 updated.
> **TASK 8.2 (2026-09-23):** curated target catalog. 164 targets from OpenNGC v20260501 (the 109 Messier objects it holds — M102 is a duplicate of M101 there — plus 55 owner-approved showpieces), each with J2000 coordinates, source `catalog:openngc@v20260501`, the OpenNGC major axis (all but M40 and M73) and V magnitude where available. The asset `assets/catalog/catalog_v2.json` is generated by `tool/build_catalog.dart` from the pinned release. Owner decisions: bundle it under CC BY-SA 4.0 with `OPENNGC_NOTICE.txt`, shown on a new About & data sources page and in the licence page; Messier + ~55 showpieces; on the first run after a pre-8.2 install, rows equal to the five old seeds (id and exact coordinates) are updated in place, edited rows left alone. Seeding is versioned (`catalogSeedVersion` in preferences) and never resurrects deleted targets. F-20 Prototype → Implemented.
> **TASK 8.3 (2026-09-23, documentation only, no code changed):** ADR-011 (equipment model and aperture semantics) accepted in Part F of DECISIONS; PD-03 and PD-10 resolved. Owner decisions: flat profile for 1.0 (composition deferred); required focal ratio plus optional diameter in mm (N = f/D, 1 % agreement); tracking type {untracked, tracked, guided, unknown} and an optional per-rig maximum exposure; existing rows never reinterpreted, N > 32 flagged for review; the dormant catalog repository is removed in TASK 8.4. No status changed (F-23 is scoped to the flat profile for 1.0).
> **TASK 8.4 (2026-09-23):** ADR-011 implemented, schema v14. `EquipmentProfile` fields carry units (`focalLengthMm`, `focalRatio`, `pixelPitchUm`, `sensorWidthMm`/`HeightMm`, `resolutionWidthPx`/`HeightPx`, `rotationDeg`) plus optional `apertureDiameterMm`, a `TrackingType` {untracked, tracked, guided, unknown} and an optional `maxExposureS`; `optical_rigs` gains nullable `aperture_diameter_mm` and `max_exposure_s`; the `aperture` column keeps every value, read as N. `EquipmentLimits` documents the plausibility bounds and `resolveAperture` the N = f / D rule (1 % agreement); the editor validates every field with units, derives a read-only f/ from a diameter, edits tracking and maximum exposure, and flags a stored ratio above f/32 for review (never converted). The dormant catalog repository and its three domain models are removed. F-22 and F-23 updated.
> **TASK 8.5 (2026-09-23):** equipment seeds verified, schema v15. Owner decisions: only the verified seed ships (the four phone profiles are dropped — their makers publish only megapixels, f-number and a 35 mm-equivalent focal length); the telescope optics are labelled an example. The seed "ZWO ASI2600MC + example 72 mm f/5.6 refractor" has camera specs verified against ZWO's product page (23.5 × 15.7 mm, 6248 × 4176 px, 3.76 µm; checked 2026-09-23) and estimated optics; RAW size unknown. `camera_modules` and `optical_rigs` gain `source` and `confidence` (ADR-008 §6; legacy rows NULL); a user edit makes a changed group of specs `user`/`reported`. `SectionHeader` titles now wrap instead of overflowing. F-05 updated.
> **TASK 8.6 (2026-09-23):** capability summary and untracked exposure guidance; PD-11 resolved (owner): NPF is shown as a labelled recommendation for untracked rigs and, marked "if untracked", for rigs of unknown tracking (never for tracked/guided); it uses the field's minimum |δ| (target |δ| − half the field diagonal, floored at 0); k is a planning setting (1–3, default 1) shown with every figure. The pure `CapabilityCalculator` gives FOV, pixel scale, NPF, the ADR-011 §5 recommended maximum sub and the target's frame fill; Home's equipment card shows them and a light block longer than the recommendation gets a warning (guidance only). Group G8 is complete. F-25 and F-26 Partial → Implemented.
> **TASK 9.1 (2026-09-23, documentation only, no code changed):** ADR-012 (weather provider, variables, alignment and staleness) accepted in Part F of DECISIONS; PD-15 resolved. Owner decisions: Open-Meteo `best_match` with the model recorded and shown; staleness 3 h / 12 h; only the chosen night's hours are used, uncovered hours shown as "no forecast". Also decided: UTC (`timeformat=unixtime`), a horizon of at most 16 days, the variable list with visibility labelled horizontal visibility (not transparency), CC BY 4.0 attribution, seeing and transparency deferred, no weather score. No status changed (F-29–F-31 are implemented in 9.2–9.4).
> **TASK 9.2 (2026-09-23):** `WeatherSnapshot` (provider, model, fetch time UTC, site, hourly `WeatherHour` values for the ADR-012 variables, each nullable) and a pure `OpenMeteoForecastParser` for `timeformat=unixtime` responses (GMT+0 epochs → UTC instants; nulls/short arrays → unknown; provider errors → typed failures). `WeatherRepository.fetchSnapshot` requests exactly the night's `[startUtc, endUtc)` with `best_match`, capped at the 16-day horizon. Tested on recorded fixtures. The current weather card still uses the legacy `getCurrentWeather` path until TASKs 9.3–9.4. F-29 updated (still Partial).
> **TASK 9.3 (2026-09-23):** weather caching, freshness and failure states. `NightWeatherService` (domain, Clock-driven) uses a cached snapshot younger than 3 h, otherwise fetches and caches; out of range is its own state; a failed refresh returns the cache with its age and the failure, or unavailable without a cache — cached data is never presented as current. Freshness constants `WeatherFreshness` (aging 3 h, stale 12 h); sealed `NightWeather` state; `WeatherSnapshotStore` (SharedPreferences in the data layer) keyed by rounded coordinates, model and night. `PlannerViewModel.nightWeather` loads on the existing weather triggers; the card still shows the legacy path until TASK 9.4. F-29 updated (still Partial until the UI uses it).
> **TASK 9.4 (2026-09-23, commit `48d7a8c`):** night-aligned weather indicators and UI. `NightWeatherSummarizer` (pure, domain) slices the forecast to sunset..sunrise of the chosen night (the whole window, labelled, for midnight sun or polar night), one slot per UTC hour with "no forecast" gaps, per-variable ranges over the covered hours, and the dew spread (temperature − dew point) against the configured margin, labelled a heuristic (CALC-32). The weather card is rewritten on `vm.nightWeather` / `vm.nightWeatherSummary`: age and model, offline/stale labels, unavailable with retry, out of range, explicit units, hour strip in the site zone, no good/bad colour bands, Open-Meteo CC BY 4.0 attribution. Owner decisions: sunset to sunrise; neutral values; the legacy path removed (`getCurrentWeather`, `WeatherConditions`/`HourlyForecast`, the non-expiring cache, `currentWeather`/`weatherError`/`dewWarning`). **Group G9 is complete.** F-29, F-30, F-31 now Implemented.
> **TASK 10.1 (2026-09-23, documentation only, no code changed):** ADR-013 (imaging-opportunity semantics) accepted in Part F of DECISIONS; PD-17 resolved. Owner decisions: gates are darkness and minimum altitude, with a horizon gate reserved (no horizon data in 1.0); the Moon and cloud only annotate by default, each with an optional user gate (off; thresholds 50 %); the fixed sky warning (Moon > 0.8 or Bortle ≥ 7) is replaced by annotations in TASK 10.2. Also decided: unknown never excludes, all failing reasons listed, max altitude inside windows, no composite score (ranking by usable time only); 12 worked examples as test vectors. No status changed (F-17, F-18, F-38 are implemented in TASK 10.2).
> **TASK 10.2 (2026-09-23, commit `613b32f`):** `ImagingOpportunityCalculator` (pure, domain; CALC-33) implements ADR-013: gates per 5-min grid instant (darkness, minimum altitude, optional Moon and cloud gates), windows with night-edge clip flags, all failing reasons per excluded segment, why a night has no window, max altitude inside each window, Moon and weather annotations (a missing input is a missing annotation; unknown never excludes), and a `SunTrack` shared across targets. `PlanningPreferences` gained the optional gates (off; 50 % when enabled; persisted, no Settings UI yet). `vm.imagingOpportunity`; `vm.visibilityWindows` and so the budget fit now come from it (FitAnalyzer API unchanged; identical windows while the gates are off). Not yet shown in the UI (TASK 10.3). F-38 Missing → Partial.
> **TASK 10.3 (2026-09-23, commit `e732a0e`):** opportunity presentation. Home's "Tonight for this target" card shows the usable time, a chart (darkness bands at the user's limit, highlighted windows, target and Moon altitude, minimum altitude) and a text list (each window with times, duration, max altitude and Moon/forecast facts; every excluded period with all its reasons; the no-window reason), both rendered from `vm.imagingOpportunity`; wording in `OpportunityText`. Removed: the fixed sky warning (ADR-013 §6), the decorative gradient bar (TD-034), and the culmination-based "Max Altitude" (now "Max altitude in windows"; `calculateCulminationAltitude` removed with its last caller). F-18 Deprecated (removed); F-38 presented, still Partial (TD-050, no horizon).
> **TASK 10.4 (2026-09-23, commit `6bb596f`):** tonight's candidates. `CandidateEvaluator` (domain) evaluates every target for the chosen night with the single-target opportunity calculator, sharing a `SunTrack` and a new `MoonTrack` (Moon once per night); rows give usable time, first window start / last window end, max altitude in windows, minimum Moon separation in windows, frame fill (CALC-31) and the no-window reason; `CandidateList` sorts by a chosen column (unknown last) and filters (with a window, type, own targets). No score. `vm.tonightCandidates()` runs it on a background isolate; the new "Tonight's candidates" screen (`/tonight`, Home app bar) lists it and a tap selects the target. Owner decisions: all targets with filters (no favourites concept), a new screen, targets without a window hidden by default with a toggle. **Group G10's scope through 10.4 is done** (10.5 is the cut line). New F-51 (Implemented).
> **TASK 10.5 (2026-09-23, owner decision, documentation only, no code changed):** CUT for 1.0. The owner kept the ADR-013 deferral: no azimuth, horizon profile, schema change or editor now; the horizon gate (G3) stays reserved and F-17 stays Missing (a documented limitation: the minimum altitude stands in for obstructions). Group G10 is closed at 10.4; the next task is TASK 11.1 (ADR: Session aggregate, PD-18).
> **TASK 11.1 (2026-09-23, documentation only, no code changed):** ADR-014 (Session aggregate, lifecycle and snapshots) accepted in Part F of DECISIONS with an entity diagram; PD-18 resolved. Session is the aggregate root (LogbookEntry = a completed Session; ExecutionState = status + block counters + events), with nullable SET NULL references, a night key, UTC timestamps and versioned JSON snapshots; `session_logs` evolves in place. Owner decisions: completed sessions keep only results and notes editable (no reopening; Duplicate instead); the plan snapshot is refreshed on each Save and the execution-start snapshot is frozen; the planner opens the most recent open session (no id in preferences); legacy logs become completed, read-only 'legacy' sessions with no references guessed from names. No status changed.
> **TASK 11.2 (2026-09-23, commit `428f673`):** schema v16 (ADR-014 §5). `session_logs` evolved in place into the Session root: `status` (draft/planned/inProgress/completed/abandoned, CHECK, default draft), `legacy`, the night key (`evening_date`, `time_zone_id`), nullable references `site_id`/`target_id`/`rig_id` with ON DELETE SET NULL, UTC-ms lifecycle timestamps and two versioned JSON snapshot columns (`JsonMapConverter`); `capture_blocks` + `completed_frames`, `rejected_frames` (planned = `frame_count`); indexes on status, evening date and target id. Every existing log became a completed legacy session (no references guessed). `DriftLogbookRepository.updateLog` now writes only its own columns (a full-row replace would reset the v16 columns). No domain or repository API change. No feature status changed (the storage is not used yet).
> **TASK 11.3 (2026-09-23, commit `ad6609c`):** `SessionRepository` (domain) / `DriftSessionRepository` (data): create, update plan, save plan (→ planned + plan snapshot), start (execution-start snapshot, frozen), complete, abandon, results, get, list by status/night/target, most recent open session, delete — one transaction per write, the ADR-014 lifecycle enforced (`SessionStateError`, nothing written). Pure `SessionSnapshotBuilder` (versioned, unit-keyed JSON of night, site, sky darkness, target, rig, preferences, blocks, budget, opportunity, weather) and `SessionSnapshot` (unknown version = unavailable). `LogbookRepository`/`DriftLogbookRepository` removed: Home's Save calls `vm.saveSession()`; the Logbook lists every non-draft session and the legacy logs with a status label; `vm.openSession` follows references by id (labels only for legacy rows). Owner decisions: the Logbook shows all saved sessions with their status; Save = planned + snapshot; new rows write display labels into the pre-v16 text columns. F-40 and F-41 progress.
> **TASK 11.4 (2026-09-23, commit `628fda6`):** the planner works on a persisted draft session (ADR-014 §3, §6). At start the most recent open session is resumed (or a draft is created); every plan edit (blocks, target, rig, night, site) is autosaved into it through a serialized `_autosave` before the edit call returns; a plan still in preferences moves once into a new draft and the preferences plan and selected target/rig ids are removed (`PlannerStateRepository.clearPlan`). New (tonight + example plan), Duplicate for another night (Home app bar) and Open (Logbook) create or resume drafts; Save moves the current session to planned with a fresh snapshot. Owner decisions: a draft whose night has passed resumes on tonight (a future night is kept); a saved plan edited since is listed as "Planned, unsaved changes"; New = tonight + example plan; opening a completed/legacy session copies it into a new draft. The site selection and the transient position stay app-level preferences (TASK 7.1/7.3 decisions). **Group G11 is complete.** F-40 Implemented; F-41 progress.
> **TASK 12.1 (2026-09-23, documentation only, no code changed):** ADR-015 (information architecture) accepted in Part F of DECISIONS with low-fidelity wireframes and a route map in `docs/IA_WIREFRAMES.md`; PD-19 and PD-14 resolved. Owner decisions: bottom navigation Tonight · Sessions · Library · Settings; the session planner is one page opened from Tonight and from Sessions; sites live in Library with rigs and targets; PD-14 = a fixed Tonight view, no customizable dashboard. Execution is a full-screen route above the tabs (G13). No status changed (F-47 dashboard decided; implemented in TASK 12.5).
> **TASK 12.2 (2026-09-23, commit `aa748e6`):** navigation shell (ADR-015). go_router `StatefulShellRoute` with four tabs (Tonight · Sessions · Library · Settings) and kept per-tab state; Android back pops within a tab, then returns to Tonight, and leaves the app from Tonight's root. Above the tabs: `/session/:id` (the planner — Home's content), `/select/target|rig|site` (the planner's pickers), `/site/edit`, `/site/pick`, `/position`. `/tonight` is an interim root until the TASK 12.5 dashboard; candidates are `/tonight/candidates`; a Library index; metadata import under Settings (still gated). Paths are `AppRouter` constants. TD-053 recorded. F-47 decided (fixed Tonight view, ADR-015).
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
> **S1.V1 (2026-09-25, Stage 1 validation fix):** TD-059 fixed. On the app's own connection (`LazyDatabase` + `NativeDatabase.createInBackground`) Drift delivers the schema refusal wrapped in a `DriftRemoteException` whose `remoteCause` is the typed `UnsupportedSchemaVersionException` (a same-group isolate, not serialized); `refusedSchemaVersion` now unwraps it, so `main.dart` shows the S1.5 recovery screen instead of falling through to the normal bootstrap. A cause that is not that type stays an error; nothing is parsed from text. The connection builder is shared (`openDatabaseConnection`) and the tests use it: v7 and v18 refused and typed, bytes unchanged, a current file opens, an unrelated failure still fails, a reset works on that connection. Test baseline 954.
> **S1.V2 (2026-09-25, Stage 1 validation fix):** TD-060 fixed. The confirmed reset is one function, `confirmDatabaseReset` (`lib/data/database/database_reset.dart`), which `main.dart` runs: a newer database is refused before anything changes; the catalog seed marker (`catalogSeedVersion`, `CatalogSeeder.forgetAppliedVersion`) is forgotten, since it describes the old file and made the seeder skip the new, empty one (0 targets instead of 164); then the old file is kept as `.v<N>.bak`. Every other preference is kept; an ordinary start still never brings back deleted catalog targets. Not changed: other preferences holding database ids (selected target, rig, site) survive a reset and may match different rows in the new database, the same class as TD-056/ENG-14 (Stage 8). Test baseline 957.
> **S1.V3 (2026-09-25, Stage 1 validation fix):** TD-061 fixed without a schema change. `CurrentSession` remembers the id of the session holding unsaved plan edits through `PlannerStateRepository.getEditedSessionId`/`setEditedSessionId` (preference `editedSessionId`, local only): set when an edit is written, removed after a successful Save, Start, New or Open, kept after a failed Save or Start, not set by a site change (S1.6's exception). A resumed draft counts as unsaved when it carries that mark, or by the earlier content rule. So a target-, rig-, night- or block-only edit still makes New/Duplicate/Open ask after a restart; an untouched draft still does not. The dialog's Cancel closes it and leaves the user where they were (on Tonight, Tonight), matching its text "cancel and save the plan first" — clarified, not changed (validation note). Test baseline 962.
> **S1.V4 (2026-09-25, Stage 1 validation fix):** TD-062 fixed. `SessionPlanViewModel.openSession` leaves the current session as it is live when asked to open it again while it is still editable, so the session detail's cached copy can no longer replace the planner's edits (the reproduced case reverted a 7-frame block to 20 and cleared the unsaved flag). A completed or running session with the current id still opens as a copy in a new draft (caught by two existing tests during the Task); another session's Open still asks first. Test baseline 963.
> **S2.1 (2026-09-26, Stage 2, commit `a25398c`):** the bounded metadata source (ADR-017 §4). `lib/domain/metadata/`: `MetadataSource` (length and `read(offset, count)`); `BudgetedMetadataSource` (1 MiB per file, 64 KiB per read, with a read log); typed `MetadataReadException` (`outOfRange`, `readTooLarge`, `overBudget`, `io`); `MetadataFormatRecognizer`, which recognises TIFF, FITS, XISF and JPEG from at most 16 bytes, never from a name. `lib/data/metadata/file_metadata_source.dart`: positioned `RandomAccessFile` reads (serialized, short reads typed). A test forbids `dart:io`, `dart:ffi`, `flutter/services`, `exif`, `image_picker` and `file_picker` in `lib/domain`; the prototype extractor is the only allowed exception, until S2.5. Tests: a real 4 GiB file is recognised and read at both ends with ≤ 64 KiB read. No parser and no UI yet; the prototype is unchanged.
> **S2.2 (2026-09-26, Stage 2; its commit is recorded by S2.3):** the metadata contract as typed values (ADR-017 §2, §5; CALC-39), pure Dart in `lib/domain/metadata/`. `MetadataValue<T>` is `KnownValue` (value, raw text, `MetadataOrigin`: format, tag or keyword, location, provenance), `AbsentValue`, `UnparseableValue` or `AmbiguousValue`; `combine` keeps agreeing values and marks conflicts ambiguous. `CaptureMetadata` holds the 11 contract fields, all absent by default. `MetadataReading` is `MetadataRead` | `MetadataUnsupported` | `MetadataUnreadable` (truncated, corrupt, overBudget, io). `ExifValues` converts EXIF values:
>   - exact rationals; `/0` and non-positive values unparseable;
>   - a 35 mm-equivalent of 0 is absent;
>   - sensitivity with its kind (EXIF SensitivityType 1–3, otherwise unspecified; 0 and 65535 unparseable; never converted to gain);
>   - capture time as local wall-clock plus an offset only if one is recorded, otherwise zone unknown with no UTC instant.
> Nothing reads a file yet (S2.3).
> **TASK 13.1 (2026-09-24, documentation only, no code changed):** ADR-016 (execution model under Android constraints) accepted in Part F of DECISIONS with a state diagram and kill, reboot, clock and stale scenarios; PD-20 resolved. Owner decisions: opt-in keep-screen-on (a wakelock plugin approved for 13.3); one session in progress at a time; a session still in progress after its night ends gets a resume prompt and is never auto-finished; execution events in a new append-only `session_events` table (schema v17, TASK 13.2). Progress is derived from persisted UTC timestamps; estimated frames = running time ÷ (exposure + per-frame overhead), shown as an estimate and written only when the user confirms it; foreground only; no notifications, camera control, ASCOM or INDI.

## Status legend

| Status | Meaning |
| --- | --- |
| **Implemented** | Exists and works as intended for its scope. Known issues may still be listed. |
| **Partial** | Exists and works in part; a notable piece is missing or wrong. |
| **Prototype** | Placeholder or early version; not a dependable feature yet. |
| **Broken** | Exists but does not function correctly. |
| **Missing** | No implementation in the code. |
| **Deprecated** | Exists but should not be used or extended. |
| **Unknown** | Could not be verified. |

Rules applied: a feature is not "Implemented" unless it works; it is not "Missing"
if code for it exists. Design intent lives in `docs/PRODUCT_SPEC.md`,
`docs/ROADMAP.md` and `docs/DECISIONS.md` (Part A); this file records only what
exists. Roadmap phases refer to `docs/ROADMAP.md`. "Ahead of phase" means the
feature exists although its roadmap phase has not been reached in
`docs/MASTER_ROADMAP.md` (see DEV-P1; the active-scope question DEV-P3 was resolved
2026-09-21, PD-06).

## Summary

| ID | Feature | Status | Roadmap phase |
| --- | --- | --- | --- |
| F-01 | App shell, DI, routing, theming | Implemented | 2, 3 |
| F-02 | Local persistence (Drift) and migrations | Partial | 4 |
| F-03 | Preference persistence (plan, selections, thresholds) | Implemented | 2 |
| F-04 | Feature gating (`FeatureScope`) | Implemented *(TASK 4.3)* | governance |
| F-05 | Seed data and first-run bootstrap | Partial *(bootstrap ordering fixed TASK 1.2)* | 4, 7 |
| F-06 | Active location (GPS, map, reverse geocoding) | Partial | 8 |
| F-07 | Saved locations management | Implemented | 4 |
| F-08 | Session date selection (picker) | Partial | 8 |
| F-09 | Default "tonight" resolution | Implemented *(fixed TASK 2.4)* | 8 |
| F-10 | Site time-zone handling | Partial | 8 |
| F-11 | Astronomy core (JD, GMST, LST, altitude) | Implemented | 5 |
| F-12 | Sun altitude and night timeline | Partial | 8 |
| F-13 | Target visibility windows | Partial | 8 |
| F-14 | Altitude chart | Implemented | 8 |
| F-15 | Lunar illumination | Implemented | 8 |
| F-16 | Moon position, rise/set, Moon–target separation | Implemented | 8 |
| F-17 | Horizon / obstruction model | Missing | 8 |
| F-18 | Sky-darkness warning | Deprecated | 11 |
| F-19 | Target selection, search, custom target CRUD | Implemented | 7 |
| F-20 | Curated target catalog with provenance | Implemented | 7 |
| F-21 | Moving-object targets | Missing | 7 |
| F-22 | Equipment profile CRUD | Implemented | 6 |
| F-23 | Equipment composition (Device / Camera / Rig) | Partial | 4 |
| F-24 | Pixel scale | Implemented | 6 |
| F-25 | Field of view (FOV) | Implemented | 6 |
| F-26 | NPF exposure recommendation | Implemented | 6 |
| F-27 | Optical multipliers (reducer / Barlow) | Prototype | 6 |
| F-28 | Storage estimate | Partial | 9 |
| F-29 | Weather fetch and offline cache | Implemented | 10 |
| F-30 | Weather forecast display | Implemented | 10 |
| F-31 | Dew warning | Implemented | 10 |
| F-32 | Light-pollution auto-fetch (Bortle) | Deprecated (removed, TASK 7.4) | 11 (ahead) |
| F-33 | Manual Bortle entry | Implemented | 11 (ahead) |
| F-34 | External light-pollution map handoff | Implemented | 11 (ahead) |
| F-35 | Capture plan editor (blocks) | Implemented | 9 |
| F-36 | Session duration and feasibility | Partial | 9 |
| F-37 | Integration time and relative stacking gain | Implemented | 9 |
| F-38 | Imaging Opportunity | Partial | 8–10 |
| F-39 | Calibration-frame planning | Partial | 9 |
| F-40 | Save session (planned) | Implemented | 13 (ahead) |
| F-41 | Logbook list / reload / delete / share | Implemented *(filters and detail, TASK 14.1)* | 13 (ahead) |
| F-42 | Planned-versus-actual logging | Implemented *(TASK 13.4)* | 13 (ahead) |
| F-43 | Session execution mode | Implemented *(TASKs 13.2–13.4; device checks pending)* | 13, 15 |
| F-44 | Export / interoperability manifest | Implemented *(v2 export; import deferred, TASK 14.3)* | 14 (ahead) |
| F-45 | Metadata import (EXIF / FITS) | Prototype | 12 (ahead) |
| F-46 | Field mode | Implemented *(TASK 12.4; summary corrected S1.15)* | 15 (ahead) |
| F-47 | Custom dashboard | Missing by decision *(the fixed Tonight view that replaces it is Implemented, TASK 12.5)* | 12.5 |
| F-48 | Automated tests | Partial | 1, 16 |
| F-49 | CI / build automation | Partial *(summary corrected S1.15)* | 1, 16 |
| F-50 | Platform support | Partial | 1, 16 |
| F-51 | Tonight's candidates (all targets for one night) *(new, TASK 10.4)* | Implemented | 8–10 |

Counts (50 features): Implemented 14 · Partial 18 · Prototype 6 · Broken 2 ·
Missing 9 · Deprecated 1 · Unknown 0. (The orphaned `equipment_profiles` table
recorded under F-23 was dropped entirely in TASK 3.3, not merely deprecated —
see DATA_MODEL.md B2/B8.)

---

# Foundation

## F-01 — App shell, dependency injection, routing, theming
- **Status:** Implemented
- **Current implementation:** `main()` wires an `AppDatabase`, repositories and two `ChangeNotifier`s into a `MultiProvider`; `MaterialApp.router` with a static go_router; `AppTheme` light/dark/field themes.
- **Relevant files:** `lib/main.dart`, `lib/presentation/navigation/app_router.dart`, `lib/core/theme/*`.
- **Known issues:** `Provider<AppDatabase>` is registered but never read; `EquipmentCatalogRepository` is not registered; `AppRouter.router` is a process-wide singleton (test-isolation hazard, TD-037); app label is `astroplan` and `pubspec` description is the Flutter default.
- **Dependencies:** provider, go_router.
- **Roadmap relevance:** Phases 2–3 (architecture skeleton, design system).

## F-02 — Local persistence (Drift) and migrations
- **Independent validation (2026-09-25, `4e653fb`):** S1.5's recovery path is **Broken** with the production background connection (TD-059; TD-047 UI closure reopened). Confirmed reset also needs seed-state handling when the applied-version preference already exists (TD-060). The refusal guards still preserve unsupported files; the earlier UI closure claim below is superseded.
- **S1.5 (2026-09-25, commit `07d55e2`):** the refused-database UI exists: explanation per case, a confirmed reset below the floor only, the old file kept (RT-03, TD-047 resolved; `unsupported_database_test.dart`, `unsupported_database_screen_test.dart`). The "Known issues" line below about the missing reset UI is superseded.
- **Status:** Partial
- **Current implementation:** schema v10, 7 tables, repositories with in-memory-DB tests. **TASK 3.2:** the v1–v7 raw-SQL steps are gone; every upgrade is behind a floor guard and a downgrade guard, runs inside a transaction, and is checked against Drift schema snapshots (`drift_schemas/`) with a generated-verification migration test suite (`test/data/database/schema_migration_test.dart`). **TASK 3.3:** foreign keys are enforced on every connection; the v9 → v10 step cleans up pre-existing orphans, rebuilds `camera_modules`/`optical_rigs`/`capture_blocks` with real `ON DELETE` actions, and drops `equipment_profiles`.
- **Relevant files:** `lib/data/database/*`, `lib/data/database/generated_migrations/*`, `drift_schemas/`, `build.yaml`, `lib/data/repositories/drift_*`.
- **Known issues:** the below-floor reset path exists (`resetUnsupportedDatabaseFile`) but nothing calls it — no bootstrap confirmation UI; a real downgrade just throws with no UI handling it either (TD-047's remaining half). *Resolved (TASK 3.2):* v3 → v9 throwing (TD-004); no migration tests or schema snapshots; the unguarded schema downgrade (TD-047, app-database half). *Resolved (TASK 3.3):* foreign keys not enforced (TD-005); orphaned `equipment_profiles`; upgraded databases keeping legacy columns (`optical_multiplier` ×2, `bit_depth`) that fresh installs lacked — the v10 migration rebuilds the affected tables and drops the orphan (DEV-D1, DEV-D6).
- **Dependencies:** drift, sqlite3, `sqlite3_flutter_libs` (`0.6.0+eol`), path_provider.
- **Roadmap relevance:** Phase 4; Phase 16 (migration testing). ~~Decision PD-04~~ (resolved, ADR-008).

## F-03 — Preference persistence (active plan, selections, thresholds)
- **Status:** Implemented
- **Current implementation:** shared-preferences keys `captureBlocks`, `targetId`, `equipmentId`, `activeLocationId`, `minAltitude`, `dewPointThreshold`, plus (TASK 5.2) the new planning-preference keys (see `docs/DATA_MODEL.md` B6). **Since TASK 5.2** they are read and written only by two data-layer repositories, `SharedPrefsPlanningPreferencesRepository` and `SharedPrefsPlannerStateRepository`, behind domain interfaces; the keys and the plan JSON shape are unchanged, so existing installs keep their state.
- **Relevant files:** `lib/data/repositories/shared_prefs_planning_preferences_repository.dart`, `lib/data/repositories/shared_prefs_planner_state_repository.dart`, `lib/domain/repositories/planning_preferences_repository.dart`, `lib/domain/repositories/planner_state_repository.dart`.
- **Known issues:** capture plan is still hand-serialized JSON (moves to the database in TASK 11.4). *Resolved (TASK 5.2):* persistence code no longer lives in the ViewModel (DEV-A1 partly); `minAltitude` is clamped on load. *Resolved (TASK 4.2):* the deleted selected target/equipment used to stay selected until restart — `refreshSelectedTarget`/`refreshSelectedEquipment` now clear it live, called from the target/equipment screens after an edit or delete (TD-028).
- **Dependencies:** shared_preferences.
- **Roadmap relevance:** Phase 2/4.

## F-04 — Feature gating (`FeatureScope`)
- **Status:** Implemented *(TASK 4.3)*
- **TASK 7.4:** `lightPollutionContext` is now `true` (its PD-06 phase); `fieldMode` and `metadataImport` stay `false`.
- **Current implementation:** four flags, all read from the one source and matching PD-06 E.1 exactly: `fieldMode`/`lightPollutionContext`/`metadataImport` are `false` (hidden), `logbook` is `true` (stays visible). Every entry point reads it — the field-mode toggle and Import Metadata buttons and the light-pollution map card in `home_screen.dart` (previously ungated), the Bortle badge in `sky_darkness_widget.dart`, and route registration in `app_router.dart`.
- **Relevant files:** `lib/core/config/feature_scope.dart`, `app_router.dart`, `sky_darkness_widget.dart`, `home_screen.dart`.
- **Known issues:** none open. *Resolved (TASK 4.3):* `fieldMode` was never read; the map handoff was ungated; Home's buttons pushed gated routes unconditionally; `metadataImport` was `true` with no recorded approval (DEV-P1; TD-014).
- **Dependencies:** decision PD-06 (resolved 2026-09-21: `DECISIONS.md` E.1); enforced by roadmap TASK 4.3, with a test that a gated feature has no entry point (`feature_scope_test.dart`, `app_router_test.dart`, `home_screen_test.dart`).
- **Roadmap relevance:** governance (ADR-006).

## F-05 — Seed data and first-run bootstrap
- **TASK 12.5 (commit `b13f7c7`):** a first-run setup page (`/welcome`) with site, rig and target steps, each skippable, reusing the pickers; the location-permission rationale is shown before "Use current position". Offered once, only on a start without a site (owner decisions); Skip, Done and back store that it is done.
- **TASK 8.5:** equipment seeding ships one profile (verified ZWO camera + example optics) with stored provenance; the four phone profiles are no longer seeded. The equipment seeder still re-seeds when the equipment table is empty (TD-035, equipment part).
- **Status:** Partial *(bootstrap ordering fixed TASK 1.2)*
- **Current implementation:** `main.dart` now awaits `CatalogSeeder` (5 targets) and `EquipmentSeeder` (5 profiles) before `runApp`, so the ViewModel's first read always sees seeded data (`2357755` established the seam; the ordering fix itself is a later TASK 1.2 commit — recorded here). Home's empty state (target/equipment still null, e.g. a seeding failure) now offers "Choose a Target" / "Choose Equipment" actions instead of a dead end.
- **Relevant files:** `lib/main.dart`, `lib/data/services/*.dart`, `planner_viewmodel.dart:81-172`, `home_screen.dart` (`_EmptyStateView`).
- **Known issues:** seeders re-seed if the user deletes everything; seed data errors (SI-005, SI-011); no `averageRawFileSizeMB` in any seed (TD-008, TD-035). *Resolved (TASK 1.2):* the DB-before-seeding race (TD-002) and the Home dead-end.
- **Dependencies:** F-02, F-19, F-22.
- **Roadmap relevance:** Phases 4, 7.

# Site, time and astronomy

## F-06 — Active location (GPS, map picker, reverse geocoding)
- **Status:** Partial
- **TASK 7.3:** the first run shows a site prompt on Home ("Use current position" / "Set site") instead of a silent GPS request, so the permission is asked only when the user chooses (owner decision; this also removes the unguarded startup location call). Home's location and weather cards open `/sites`. An active site shows its own name and is not reverse-geocoded. Still Partial: without any site or position, weather still loads for the default London coordinates (the prompt says so); not run on a device.
- **TASK 7.2:** each permission outcome (location services off, denied, denied forever, granted) is reported by `LocationService` and explained in the picker, with "Open settings" for the first and third; the picker goes through the ViewModel (no Geolocator call); reverse geocoding goes through `ReverseGeocoder` / `NominatimReverseGeocoder` (identifying user agent, ≤ 1 request/s, cache by rounded coordinates, failure → name unknown and logged, stale answers ignored); "© OpenStreetMap contributors" is shown on the map and with a place name; the tile user agent is `com.astroplan.astroplan`; coordinates can be typed (validated, offline). **Still open:** the startup `unawaited(useCurrentLocation())` has no `try/catch` for an unexpected platform exception (TD-002); silent London default and the sites UI (TASK 7.3); not run on a device.
- **TASK 7.1:** a GPS fix or map pick is now a **transient** position, remembered across restarts (preferences) and never written into a saved site; it deselects the active site. The first-launch GPS lookup no longer creates a "Custom Location" row.
- **Current implementation:** `useCurrentLocation` (through the injected `LocationService`, implemented by `GeolocatorLocationService`; *updated TASK 1.1*), a `flutter_map` picker with a marker and "Current Location" button, Nominatim reverse geocoding for a place name; defaults to London until a location is set.
- **Relevant files:** `planner_viewmodel.dart:163-280`, `lib/presentation/screens/location/location_picker_screen.dart`.
- **Known issues:** unhandled platform-location exceptions on the startup path (`unawaited`, no `try/catch`); silent London default; geocoding failures swallowed; Geolocator flow duplicated in the picker; `setLocation` overwrites the active saved profile; OSM tiles shown without attribution and with a mismatched user-agent; not run on a device in this audit (TD-002, TD-027, TD-031).
- **Dependencies:** geolocator, flutter_map, latlong2, http, url_launcher, network (optional: typed coordinates work offline).
- **Roadmap relevance:** Phase 8 (location + visibility).

## F-07 — Saved locations management
- **Status:** Implemented *(was Partial; TASK 7.3, 2026-09-23)*
- **TASK 7.3:** `SitesScreen` (`/sites`) lists, selects, creates, edits and deletes sites (active marked; delete confirmed); `SiteEditorScreen` (`/sites/edit`) validates name, latitude/longitude (typed, or picked on the map via `/location/pick`), elevation in metres, the IANA zone (searchable picker, new sites pre-filled with the device zone via `DeviceTimeZone`/`flutter_timezone`) and notes; Bortle/SQM fields keep provenance (`LocationProfile.userEdit`: changed → `user` + date, unchanged → kept) and are hidden with the light-pollution context until TASK 7.4. A new site becomes active; the selection persists; deleting the active site keeps its position as the transient position (owner decision). The earlier known issues below are resolved except: elevation cannot be unknown (the model requires a number) and is unused by any calculation; not run on a device.
- **TASK 7.1:** sites carry nullable Bortle with source and date, SQM, an IANA zone and notes (schema v12); nothing writes into a site except an explicit user edit (the Bortle edit writes source `user` and the date). Still no UI to list, create or switch sites (TASK 7.3).
- **Current implementation:** `LocationProfile` table, `LocationRepository` (CRUD, tested), one "active" row referenced from preferences.
- **Relevant files:** `lib/data/repositories/drift_location_repository.dart`, `lib/domain/repositories/location_repository.dart`.
- **Known issues:** no UI to list, name, switch or delete locations; only one row ever exists; elevation unit unspecified and unused; `_fetchBortle` reads the active id concurrently with `setLocation` inserting the row (race, from code reading, not reproduced) (DEV-D4; TD-027).
- **Dependencies:** F-06.
- **Roadmap relevance:** Phase 4 (Location entity); PRODUCT_SPEC MVP "saved locations".

## F-08 — Session date selection (picker)
- **Status:** Partial
- **Current implementation (TASK 2.4):** the date picker sets `PlannerViewModel._pickedEveningDate` (a `CalendarDate`, not a `DateTime`); `viewModel.setEveningDate()` re-resolves the `SessionNight` through `SessionNightResolver.forEveningDate`. The Session Date subtitle reads "Night of <date>" via `NightTimeFormatter`, or "No site set" when there is no site (ADR-007 §9).
- **Relevant files:** `home_screen.dart` (Session Date `ListTile`), `planner_viewmodel.dart` (`eveningDate`, `setEveningDate`).
- **Known issues:** "updates weather" only refetches the same "now + 48 h" forecast (weather itself is still not date-aware, TD-017); picker range is −1 to +5 years (weather is meaningless beyond ~2 days); the picked date is not itself zone-labelled (only the resulting night's instants are, via `NightTimeFormatter`). *Resolved (TASK 2.4):* the default and the picked date used to go through inconsistent UTC/local `DateTime` paths — both now go through `CalendarDate` and one resolver.
- **Dependencies:** F-12.
- **Roadmap relevance:** Phase 8.

## F-09 — Default "tonight" resolution
- **Status:** Implemented *(fixed TASK 2.4, 2026-09-22, commit `1e58fcf`)*
- **Current implementation:** `PlannerViewModel.sessionNight` calls `SessionNightResolver.resolveDefault(_clock.nowUtc(), ...)` when no evening date has been picked; `_clock` is an injectable `Clock` (`SystemClock` in production, `FixedClock` in tests), never `DateTime.now()` directly.
- **Relevant files:** `planner_viewmodel.dart` (`sessionNight` getter), `lib/domain/services/session_night_resolver.dart`, `lib/core/time/clock.dart`.
- **Verified:** a ViewModel test (`planner_session_date_test.dart`, San Francisco, `FixedClock(2026-09-22T01:30Z)` = 18:30 PDT on 2026-09-21) asserts `eveningDate == CalendarDate(2026, 9, 21)` — the night containing "now", not the UTC calendar date the old rule gave (2026-09-22). A matching Home widget test asserts the same case end-to-end through the "Night of ..." subtitle text.
- **Known issues:** none open for this feature; the limitation at L4 (ADR-007 §5: from sunrise to solar noon the default still shows the night that just ended) is an accepted owner-approved behavior, not a defect.
- **Dependencies:** ~~decisions PD-01, PD-02~~ (resolved); ~~TASKs 2.3 and 2.4~~ (done).
- **Roadmap relevance:** Phase 8; unblocks Phases 9–10.

## F-10 — Site time-zone handling
- **Status:** Partial *(was Missing; TASK 2.2, 2026-09-22)*
- **TASK 7.3:** the zone can now be set per site (the editor's picker, new sites pre-filled with the device zone; "Unknown" allowed). `IanaTimeContext` loads `latest_all`, so link ids reported by devices (e.g. `Europe/Ljubljana`, `Asia/Calcutta`) resolve. Still Partial: weather timestamps stay naive (G9).
- **TASK 7.1:** an active site with an IANA zone uses it for the night identity (`IanaTimeContext`; ADR-007 L1 fixed) and for display — `NightTimeFormatter.zoneCaption` labels "site zone Europe/London, BST, UTC+01:00"; the altitude chart's axis also goes through the formatter now. Without a zone (or for a transient position) the mean-solar identity and labelled device zone remain. No UI to set a zone yet (TASK 7.3).
- **Current implementation:** the domain has a `SiteTimeContext` seam
  (`lib/domain/models/site_time_context.dart`), with a mean-solar fallback and a
  fixed-offset implementation (ADR-007 §6), used by `SessionNightResolver`. **TASK
  2.4:** all night-related times are now shown through one `NightTimeFormatter`,
  labelled as the **device** zone (`deviceZoneCaption`, e.g. "device zone,
  UTC−07:00") since the site's own zone is not available before TASK 7.1; times
  after midnight carry a "+1" marker (ADR-007 §6). There is still no per-site zone.
  Weather timestamps remain naive and the provider's `utc_offset_seconds` is
  discarded (unaffected by this task; G9).
- **Relevant files:** `lib/presentation/shared/night_time_formatter.dart`, `sky_darkness_widget.dart`, `open_meteo_weather_repository.dart:47`.
- **Known issues:** remote-site planning shows the device's clock times, not the site's; weather and timeline can disagree by the zone difference (SI-010; TD-020).
- **Dependencies:** decision PD-02.
- **Roadmap relevance:** Phase 8, 10.

## F-11 — Astronomy core (JD, GMST, LST, altitude)
- **Status:** Implemented
- **Current implementation:** Meeus-based Julian date, linear GMST, LST, LHA, geometric altitude; RA/Dec helpers.
- **Relevant files:** `lib/domain/services/astronomical_engine.dart`, `visibility_calculator.dart`, `lib/core/utils/astro_math.dart`.
- **TASK 6.2:** J2000 → date precession (Meeus ch. 21) in the single target-altitude function; reference-tested against USNO/JPL Horizons/SIMBAD fixtures (Sun ≤ 0.0097°, stars ≤ 0.017°); every simplification documented on its function.
- **Known issues:** none open. *Resolved (TASK 6.2):* undocumented simplifications and missing precession (SI-009, TD-036); the stray escaped apostrophe in the GMST comment.
- **Dependencies:** none (pure Dart).
- **Roadmap relevance:** Phase 5. Tests: J2000 JD/GMST, LST, culmination altitude.

## F-12 — Sun altitude and night timeline
- **Status:** Partial
- **Current implementation:** low-precision Sun altitude; sunset, civil/nautical/astronomical dusk and dawn, sunrise on a 5-minute scan. **New (TASK 2.3):** a `SessionNight`-based `calculateNightTimelineForNight` returns a typed `NightTimeline` (`SunCrossing`/`SunNeverBelow`/`SunAlwaysBelow` per threshold, never a bare null); the old `Map<String, DateTime?>`-returning `calculateNightTimeline` is now a thin wrapper over it. UI (`sky_darkness_widget.dart`) still shows sunset, astro dusk/dawn, sunrise and a "True Night Window" from the old wrapper, unchanged.
- **Relevant files:** `visibility_calculator.dart`, `lib/domain/models/night_timeline.dart`, `lib/presentation/widgets/sky_darkness_widget.dart`.
- **Known issues:** 5-minute quantization (TD-036); ~~the gradient bar is decorative and unrelated to the data~~ *(removed TASK 10.3, TD-034; data-driven darkness bands are in the opportunity chart)*; the "True Night Window" line always uses astronomical twilight, not the user's darkness limit (TD-051). *Resolved (TASK 2.3):* the stale "refine to 1-minute" comment is gone with the scan loop it was attached to (TD-024). *Resolved (TASK 2.4):* wrong night by default (F-09); `sky_darkness_widget.dart` now consumes the typed `NightTimeline?` directly (sealed-class pattern matching, `null` when there is no site) instead of the deprecated `Map<String, DateTime?>` wrapper; times are labelled with the device zone via `NightTimeFormatter` instead of printed bare.
- **Dependencies:** F-11, F-09.
- **Roadmap relevance:** Phase 8.

## F-13 — Target visibility windows
- **Status:** Partial
- **TASK 5.2:** the minimum altitude and the Sun darkness limit (−18/−15/−12°) are user preferences, editable in Settings, and feed the windows.
- **Current implementation:** windows where the Sun is below −18° (configurable) and the target is above a minimum altitude (default 20°); feeds feasibility. Handles multiple segments and high latitudes. **New (TASK 2.3):** a `SessionNight`-based `calculateVisibilityWindowsForNight`, sharing the 5-minute grid with the timeline and the altitude curve; a window touching the SessionNight boundary in polar night is flagged `clippedAtStart`/`clippedAtEnd` (ADR-007 §9, verified for both the new API and the legacy wrapper). The old `calculateVisibilityWindows` is now a thin wrapper over it.
- **Relevant files:** `visibility_calculator.dart`, `lib/domain/models/visibility_window.dart`, `planner_viewmodel.dart:419-428`.
- **Known issues:** no Moon, weather or horizon; 5-minute quantization; J2000 coordinates; "culmination" is only max altitude at LHA = 0, not a culmination time and not restricted to the night (SI-006, SI-009). *Resolved (TASK 2.4):* wrong night by default (F-09) — `PlannerViewModel.visibilityWindows` now resolves a real `SessionNight` and returns `[]` without a site instead of silently using default London coordinates (SI-008).
- **Dependencies:** F-11, F-12.
- **Roadmap relevance:** Phase 8. Tests: 4 legacy window tests (UTC dates only) plus the TASK 2.3 SessionNight suite (polar cases, clip flags, exact agreement with the legacy wrapper).

## F-14 — Altitude chart
- **Status:** Implemented
- **Current implementation:** `CustomPaint` chart of target altitude over 24 h with day/twilight/night bands, a minimum-altitude line and a "now" marker. **TASK 2.3:** render-only — `build()` calls `VisibilityCalculator.calculateAltitudeCurve` once; the painter only maps the resulting samples (5-minute grid, 289 points, up from the old ad-hoc 96) to pixels, and no longer imports `astronomical_engine.dart` or calls raw astronomy. **TASK 2.4:** the widget takes a `SessionNight` directly (constructor changed: `night` replaces `latitude`/`longitude`/`sessionDate`) instead of resolving its own from raw coordinates and a `DateTime` — it now shares the exact `SessionNight` the ViewModel resolves, and `home_screen.dart` shows a "Set your site to see tonight's altitude chart." placeholder card instead of the chart when there is no site.
- **Relevant files:** `lib/presentation/widgets/altitude_chart_widget.dart`, `lib/domain/models/altitude_curve.dart`, `home_screen.dart` (`_NoSiteCard`).
- **Known issues:** none open for the wrong-night defect. *Resolved (TASK 2.3):* astronomy inside the painter and the device-local-noon divergence from the windows/timeline (DEV-A3, TD-023). *Resolved (TASK 2.4):* wrong night by default (F-09) and the interim self-resolved `SessionNight` from TASK 2.3. Widget tests updated to build a `SessionNight` via `SessionNightResolver.forEveningDate` and pass it in (3 tests: a normal night, a polar-night site, and a date with no "now" dot).
- **Dependencies:** F-11, F-13.
- **Roadmap relevance:** Phase 8.

## F-15 — Lunar illumination
- **Status:** Implemented *(TASK 6.4)*
- **Current implementation:** Meeus ch. 48 illuminated fraction from the ADR-010 Moon (`MoonCalculator`, 0.008 pp against JPL Horizons), evaluated at mean solar midnight of the night and shown as `Moon Illumination: NN%` (whole percent), or `--` without a site; feeds the sky warning.
- **Relevant files:** `lib/domain/services/moon_calculator.dart`, `lib/domain/models/moon_conditions.dart`, `sky_darkness_widget.dart`, `planner_viewmodel.dart` (`moonConditions`, `lunarIllumination`).
- **Known issues:** one value per night (it varies by up to about 6 pp across a night). The warning threshold (> 0.8) is still fixed (SI-006). *Resolved (TASK 6.4):* the mean-phase model, up to 4.7 pp off, is deleted.
- **Dependencies:** F-16.
- **Roadmap relevance:** Phase 8.

## F-16 — Moon position, rise/set, Moon–target separation
- **Status:** Implemented *(TASK 6.3–6.4)*
- **Current implementation:** `MoonConditions` for the night and the selected target: Moon altitude on the 5-minute grid, moonrise/moonset, the intervals when the Moon is up, and the closest Moon–target approach while both are above the horizon. The sky card shows "Moon up …" or "Moon up all night / below the horizon all night" and "Closest to the target while both are up: N° at HH:MM", or that they are never up together. These are annotations only, with no "impact %".
- **Relevant files:** `lib/domain/services/moon_calculator.dart`, `lib/domain/models/moon_conditions.dart`, `sky_darkness_widget.dart`.
- **Known issues:** the Moon does not yet gate or annotate imaging windows (PD-17 / G10). Times are labelled in the device zone until TASK 7.1.
- **Dependencies:** ADR-010.
- **Roadmap relevance:** Phase 8.

## F-17 — Horizon / obstruction model
- **TASK 10.5 cut for 1.0 (owner, 2026-09-23):** stays Missing by decision; the opportunity calculator reserves the horizon gate (ADR-013 G3) for a later release.
- **Status:** Missing
- **Current implementation:** a single flat minimum altitude.
- **Relevant files:** —
- **Known issues:** trees, buildings and terrain are not modelled (documented limitation).
- **Dependencies:** F-13.
- **Roadmap relevance:** Phase 8 (optional).

## F-18 — Sky-darkness warning
- **Status:** Deprecated — **removed 2026-09-23 (TASK 10.3, ADR-013 §6, owner decision)**. The fixed Moon > 0.8 / Bortle ≥ 7 card and `skyDarknessWarning` are gone; the Moon (per window) and sky darkness (Bortle/SQM with source) are shown as facts, with no threshold verdict. The text below describes the removed card.
- **Current implementation:** an orange card on Home when Moon illumination > 0.8 or Bortle ≥ 7.
- **Relevant files:** `planner_viewmodel.dart:434-436`, `home_screen.dart:147-166`.
- **Known issues:** hard-coded thresholds; ignores Moon altitude and target; the Bortle half is unreachable (F-32, F-33); message asserts targets "will wash out" (SI-006; TD-033).
- **Dependencies:** F-15, F-33.
- **Roadmap relevance:** Phase 11 (ahead of phase).

# Targets

## F-19 — Target selection, search, custom target CRUD
- **Status:** Implemented
- **TASK 8.1:** RA is entered as h:m:s / `05h35m17s` / decimal hours (degrees need `°`), Dec as d:m:s / `−05°23′28″` / decimal degrees (pure `AstroMath` parsers; the editor shows stored values formatted and keeps an untouched field exact); optional apparent size (arcmin) and magnitude; edits never change the catalog id (shown read-only); only fixed-coordinate types are offered; search escapes `%`/`_`; catalog entries are unique per catalog id. The known issues below are resolved except: the screen still calls the repository directly (DEV-A2, TD-021). *(Resolved TASK 12.3: through `TargetsViewModel`.)*
- **Current implementation:** searchable list (`LIKE`), add/edit/delete with validation (RA 0–360°, Dec ±90°), selection stored in preferences.
- **Relevant files:** `lib/presentation/screens/target/target_selection_screen.dart`, `lib/data/repositories/drift_target_repository.dart`.
- **Known issues:** editing overwrites `catalogId` with the name; RA entered in degrees; no uniqueness; calls the repository directly (DEV-A2); `LIKE` wildcards not escaped (TD-016, TD-021). *Resolved (TASK 4.2):* stale selection after deleting or editing the selected target — the screen now calls `PlannerViewModel.refreshSelectedTarget()` after its dialog closes and after a swipe-delete (TD-028).
- **Dependencies:** F-02.
- **Roadmap relevance:** Phase 7. Tests: 5 form-validation widget tests, 1 repository test.

## F-20 — Curated target catalog with provenance
- **S1.2 (2026-09-25, commit `c449c03`):** failed inserts leave the catalog version unrecorded, so seeding is retried on the next launch without duplicating rows already in (ENG-02/RT-02 resolved; `catalog_seeder_test.dart`, "failed inserts"). A target the user deletes between a failed seed and its retry comes back with the retry.
- **Status:** Implemented *(TASK 8.2, 2026-09-23)*
- **TASK 8.2:** 164 OpenNGC objects (109 Messier + 55 showpieces) with J2000 coordinates, source, size (all but M40/M73) and V magnitude where available; CC BY-SA 4.0 notice on the About page; versioned seeding that never resurrects deletions; pre-8.2 seed rows upgraded in place when untouched. Relevant files: `assets/catalog/`, `tool/build_catalog.dart`, `lib/data/services/catalog_seeder.dart`, `lib/presentation/screens/about/`. **Still open:** no constellation or alternate designations stored (e.g. M31's NGC 224 is not searchable); not run on a device. The text below describes the state before 8.2.
- **TASK 8.1:** the schema now holds epoch, source, size and magnitude; newly seeded rows carry source `seed:catalog@1` (legacy rows: unknown). The seeds are still 5 unverified objects with no size or magnitude — the curated catalog is TASK 8.2.
- **Current implementation:** 5 seeded objects (M31, M42, M45, M33, M8).
- **Relevant files:** `lib/data/services/catalog_seeder.dart`.
- **Known issues:** no provenance, epoch, magnitude, size or constellation; too small to be useful (SI-012; TD-016).
- **Dependencies:** decision PD-09.
- **Roadmap relevance:** Phase 7.

## F-21 — Moving-object targets
- **Status:** Missing
- **TASK 8.1 (ADR-010 §3):** Planet, Moon, Comet and Asteroid are no longer offered for new targets; an existing target of those types keeps its type (never retyped or deleted silently) and shows "Fixed coordinates — this object moves; positions are not tracked" in the target list, the editor and on Home. No ephemerides (out of 1.0).
- **Current implementation:** none, yet the type list offers Planet, Moon, Comet, Asteroid.
- **Relevant files:** `target_selection_screen.dart:9-20`.
- **Known issues:** such targets would be modelled as fixed coordinates and silently mis-plotted (SI-012).
- **Dependencies:** decisions PD-07, PD-16.
- **Roadmap relevance:** Phase 7 (out of MVP scope for now).

# Equipment and optics

## F-22 — Equipment profile CRUD
- **Status:** Implemented
- **TASK 8.4:** every field is validated against documented bounds with its unit in the label and message (no silent 0; RAW size can no longer be negative); focal ratio or aperture diameter (the f/ then derived and read-only); tracking type and maximum sub-exposure; a stored ratio above f/32 shows "please review" in the list, the editor and on Home. Still open: seed data (SI-011, TASK 8.5); the screen calls the repository directly (DEV-A2). *(Resolved TASK 12.3: through `GearViewModel`.)*
- **Current implementation:** list, add, edit, delete (with confirmation), selection; form validates required numeric fields; sensor size is auto-derived from resolution × pixel pitch.
- **Relevant files:** `lib/presentation/screens/equipment/equipment_selection_screen.dart`, `lib/data/repositories/drift_equipment_repository.dart`.
- **Known issues:** RAW size accepts negatives; seeded data errors (SI-005, SI-011); repository called directly (DEV-A2). *Resolved (TASK 4.2):* deleting or editing the selected rig used to leave a stale selection — the screen now calls `PlannerViewModel.refreshSelectedEquipment()` after its dialog closes and after a swipe-delete (TD-028). *Resolved (TASK 4.3):* mojibake in strings (`Вµm`, `В°`, box-drawing comments), now correct (`µm`, `°`) and checked by `tool/check_encoding.dart` (TD-015).
- **Dependencies:** F-02, F-23.
- **Roadmap relevance:** Phase 6. Tests: 4 form-validation widget tests, 1 encoding test, 2 repository tests.

## F-23 — Equipment composition (Device / Camera module / Optical rig)
- **Status:** Partial
- **TASK 8.4 (ADR-011 §2):** 1.0 keeps the flat profile by decision; camera reuse is deferred beyond 1.0. The dormant `EquipmentCatalogRepository`, its Drift implementation and the `EquipmentDevice`/`CameraModule`/`OpticalRig` models are removed (the files listed below no longer exist); `trackingState` is now visible and editable as the tracking type. Status stays Partial because composition itself is not built.
- **Current implementation:** storage is normalized (Device → CameraModule → OpticalRig) and used, always 1:1:1; the UI/domain use a flat `EquipmentProfile` (id = rig id). `EquipmentCatalogRepository` exists and is tested but is registered nowhere. **TASK 3.3:** the flat `equipment_profiles` table is gone (dropped in the v10 migration, ADR-008 §5), not just deprecated; `camera_modules.device_id`/`optical_rigs.camera_module_id` are `ON DELETE RESTRICT`.
- **Relevant files:** `lib/data/database/tables/equipment_foundation_tables.dart`, `drift_equipment_repository.dart`, `drift_equipment_catalog_repository.dart`, `lib/domain/models/{equipment_profile,equipment_device,camera_module,optical_rig}.dart`.
- **Known issues:** no camera reuse; `trackingState` stored but invisible (DEV-D2; TD-026 — both still open). *Resolved (TASK 3.3):* deleting a rig used to delete its camera module and device unconditionally; `deleteEquipment` now checks for other references first, matching the new `RESTRICT` constraint.
- **Dependencies:** decision PD-03.
- **Roadmap relevance:** Phase 4 (foundation), 6.

## F-24 — Pixel scale
- **Status:** Implemented
- **Current implementation:** `206.265 · pitch(µm) / EFL(mm)` arcsec/px, shown on Home.
- **Relevant files:** `optical_calculator.dart:18-24`, `planner_viewmodel.dart:506-512`, `home_screen.dart:104`.
- **Known issues:** prints `null arcsec/px` when unavailable; not re-derived for effective multipliers.
- **Dependencies:** F-22.
- **Roadmap relevance:** Phase 6. Tests: ASI2600MC reference case.

## F-25 — Field of view (FOV)
- **Status:** Implemented *(TASK 8.6, 2026-09-23)*
- **TASK 8.6:** `CapabilityCalculator` gives width × height (and diagonal) in degrees, shown on Home's equipment card with the pixel scale, and the target's frame fill (angular size over the field's short side) when the target's size is known. The known issues below are resolved.
- **Current implementation:** `2·atan(d/2f)` implemented and unit-tested.
- **Relevant files:** `optical_calculator.dart:30-37`.
- **Known issues:** **never used or displayed** anywhere in the app; no target-size or framing comparison (targets have no size) (TD-016).
- **Dependencies:** F-22, F-20.
- **Roadmap relevance:** Phase 6.

## F-26 — NPF exposure recommendation
- **Status:** Implemented *(TASK 8.6, 2026-09-23; was Broken, then Partial after TASK 6.5)*
- **TASK 8.6 (PD-11 resolved):** shown on Home as "NPF (untracked)" with k and the |δ| used, for untracked rigs and — marked "if untracked" — for unknown tracking; the field-minimum declination replaces the centre declination; k is a planning setting (1–3); the recommended maximum sub = min(NPF, the rig's maximum exposure); a longer light block is warned, never blocked. The `npfExposure` getter is replaced by `rigCapability`.
- **Current implementation:** `calculateNPFExposure` follows Michaud's complete NPF rule from the primary source, with an explicit k (default 1, range 1–3) and |δ| as the field's minimum declination (0 if unknown). A ViewModel getter `npfExposure` exists; **no UI consumer** (PD-11: hidden).
- **Relevant files:** `lib/domain/services/optical_calculator.dart`, `planner_viewmodel.dart` (`npfExposure`).
- **Known issues:** not shown (by decision, PD-11). The getter passes the target's centre declination rather than the field minimum, to be revisited when it is surfaced. *Resolved (TASK 6.5):* the `+ 90` constant (2.9× too long for phones), the circular test and the missing k (SI-001, TD-007).
- **Dependencies:** PD-11 to surface it.
- **Roadmap relevance:** Phase 6.

## F-27 — Optical multipliers (reducer / Barlow)
- **Status:** Prototype
- **Current implementation:** `calculateEffectiveFocalLength` is an identity function; the `optical_multiplier` column was removed in the latest commit.
- **Relevant files:** `optical_calculator.dart:8-12`.
- **Known issues:** effective focal length must be entered by the user; the seam exists but does nothing.
- **Dependencies:** decision PD-03.
- **Roadmap relevance:** Phase 6 ("optical multipliers").

## F-28 — Storage estimate
- **Status:** Partial
- **Current implementation:** `averageRawFileSizeMB × total frames (all types)`, shown as `Estimated Storage`. **TASK 4.4:** `estimateStorageRequirement` returns `null` (not `0.0`) when the average size is unknown, and the widget shows "Unknown".
- **Relevant files:** `optical_calculator.dart:52-57`, `planner_viewmodel.dart:493-500`, `capture_plan_widget.dart:223-225`.
- **Known issues:** no theoretical payload figure; bit depth no longer stored (SI-013). *Resolved (TASK 4.4):* used to show a fabricated **`0.0 MB`** when the size was unknown (all seeds) (SI-008; TD-013).
- **Dependencies:** F-22.
- **Roadmap relevance:** Phase 9.

# Weather and sky conditions

## F-29 — Weather fetch and offline cache
- **Current state (S1.15, 2026-09-25): Implemented.** `OpenMeteoWeatherRepository.fetchSnapshot` fetches the night's hours in UTC (`best_match`, the ADR-012 variables, a 16-day horizon) with the app's user agent; `NightWeatherService` caches a snapshot per site, model and night (`SharedPrefsWeatherSnapshotStore`) and returns typed states (current / aging / stale, offline-cached, unavailable, out of range) whose age follows the clock (S1.3). Files: `open_meteo_weather_repository.dart`, `open_meteo_forecast_parser.dart`, `night_weather_service.dart`, `shared_prefs_weather_snapshot_store.dart`. Known limits: no cache eviction (ENG-10, rejected as a current defect); live-service behaviour is fixture-tested only (Stage 11). The **Status**, **Current implementation**, **Relevant files** and **Known issues** lines further down describe the legacy path removed in TASK 9.4 and are kept as history.
- **S1.1 (2026-09-25, commit `6a90347`):** requests carry the identifying user agent (`AppIdentity.userAgent`; ENG-03/RT-07 resolved, tested with a `MockClient`).
- **TASK 9.4 (Implemented):** the card displays the night forecast (`vm.nightWeather`); the legacy `getCurrentWeather` path, its non-expiring cache and `WeatherConditions` are removed (owner decision). The known issues below describe the removed legacy path.
- **TASK 9.3:** the night forecast is cached per site, model and night with its fetch time; freshness states (current / aging after 3 h / stale after 12 h), offline-cached, unavailable and out of range are modelled and tested (`NightWeatherService`, `vm.nightWeather`). Still Partial: not displayed until TASK 9.4 (the card shows the legacy path).
- **TASK 9.2:** the night-aligned, UTC `fetchSnapshot` exists and is tested (recorded Open-Meteo fixtures; typed failures; horizon cap). Not yet used by the ViewModel or UI, and not cached — TASKs 9.3–9.4.
- **Status:** Partial
- **Current implementation:** Open-Meteo forecast (`icon_seamless`, 48 hourly entries, current values); cached in shared preferences per ~1.1 km cell; falls back to cache on any failure.
- **Relevant files:** `lib/data/repositories/open_meteo_weather_repository.dart`, `lib/domain/models/weather_conditions.dart`.
- **Known issues:** not date-aware (always "now"); arrays start at local midnight; timestamps naive; offset discarded; cache has no staleness limit or indicator; parser assumes non-null arrays (worked for the live London query); no provenance; startup awaits it (DEV-A5); errors silent (TD-017, TD-029).
- **Dependencies:** http, shared_preferences; decisions PD-02, PD-15.
- **Roadmap relevance:** Phase 10 ("without breaking offline"). Tests: 3 repository tests with a mocked client.

## F-30 — Weather forecast display
- **S1.3 (2026-09-25, commit `2007dc5`):** "Updated N ago" and the aging/stale wording follow the clock while the app runs, an outdated forecast is reloaded when the app returns to the foreground, and the card follows the night when it rolls over (ENG-01/RT-01 resolved; `forecast_freshness_test.dart`).
- **TASK 9.4 (Implemented):** "Night weather" card on `vm.nightWeather`: sunset to sunrise of the chosen night (whole window, labelled, for midnight sun or polar night), times in the site zone with a caption; per-hour strip (cloud %, precipitation chance %, wind km/h, temperature °C, dew spread °C) with "no forecast" hours; night ranges for every ADR-012 variable with units (visibility labelled horizontal, not transparency; gusts as the preceding-hour maximum); age and model; offline/aging/stale labels; unavailable with retry; out of range; no good/bad colour bands; Open-Meteo CC BY 4.0 attribution with a link. Widget-tested. The issues below are resolved by this rewrite.
- **Status:** Implemented (was Partial)
- **Current implementation:** summary (temperature, cloud, wind) and a horizontal 48-hour strip (cloud, temperature, precipitation probability, humidity, wind).
- **Relevant files:** `lib/presentation/widgets/weather_forecast_widget.dart`.
- **Known issues:** strip begins at local midnight, not "now" or the imaging night; no highlight or summary of the dark window; dew point not shown; colour bands hard-coded (SI-006); no widget test.
- **Dependencies:** F-29.
- **Roadmap relevance:** Phase 10.

## F-31 — Dew warning
- **TASK 9.4 (Implemented):** shown on the weather card per hour and for the night: hours whose temperature − dew point spread is at or below the Settings margin, labelled a heuristic (CALC-32); unknown when either value is missing. The `dewWarning` getter below is removed.
- **Status:** Implemented (was Prototype)
- **Current implementation (before TASK 9.4):** `dewWarning` getter (temperature − dew point ≤ threshold, default 2.0 °C) and a persisted threshold.
- **Relevant files:** `planner_viewmodel.dart:366-371,438-441`.
- **Known issues:** **never displayed**; uses current weather. *Resolved (TASK 5.2):* the margin is editable in Settings, not the forecast for the session (SI-006).
- **Dependencies:** F-29.
- **Roadmap relevance:** Phase 10.

## F-32 — Light-pollution auto-fetch (Bortle)
- **Status:** Deprecated — **removed 2026-09-23 (TASK 7.4, PD-05)**. The scraper and its call on every location change are deleted; a test checks that no scraping code remains and that a location change makes no network call. An automatic source is deferred (PD-05 options C/D, DECISIONS E.1). The text below describes the removed code.
- **Current implementation:** `LightPollutionRepository.fetchBortleClass` scrapes ClearOutside with a regex.
- **Relevant files:** `lib/data/repositories/light_pollution_repository.dart`.
- **Known issues:** the URL is never interpolated (`\${…}`), so it can never succeed; scraping a third-party site; not injectable, no interface, no tests; still invoked on every location change (SI-007; TD-006).
- **Dependencies:** decision PD-05.
- **Roadmap relevance:** Phase 11 (ahead of phase).

## F-33 — Manual Bortle entry
- **Status:** Implemented *(TASK 7.4)*
- **TASK 7.4:** visible (`FeatureScope.lightPollutionContext = true`). Bortle and/or SQM are entered in the site editor (stored as source `user` with the date; unchanged values keep their source) or, for Bortle, on the sky card's badge (for a transient position: in memory, labelled "not saved"). The sky card shows the values with their sources or says sky darkness is unknown (`SkyDarkness`). No Bortle↔SQM conversion; the sky warning uses a known Bortle class only (thresholds are G10's). The known issues below are resolved.
- **Current implementation:** a `Bortle 1–9` dropdown badge in the sky card, persisted to the active location.
- **Relevant files:** `sky_darkness_widget.dart:32-40,65-126`, `planner_viewmodel.dart:344-364`.
- **Known issues:** hidden by `FeatureScope.lightPollutionContext = false`, so **no user path sets Bortle**; default 4 and no "unknown" state (SI-007).
- **Dependencies:** F-04, decision PD-05.
- **Roadmap relevance:** Phase 11.

## F-34 — External light-pollution map handoff
- **Status:** Implemented *(TASK 7.4)*
- **TASK 7.4:** the Home card opens lightpollutionmap.info centred on the current position (`LightPollutionMapLink.at`, zoom 10), with a hint to enter the value read there as Bortle or SQM; it is visible (gate on) and shown only when a position exists (not for the London default). The hard-coded Slovenia coordinates are gone (DEV-P1's remaining part). Not run on a device.
- **Current implementation:** a Home card that opens lightpollutionmap.info in the browser. **TASK 4.3:** the card is now gated behind `FeatureScope.lightPollutionContext` (hidden until TASK 7.4) rather than shown unconditionally — its hard-coded coordinates make a real gate pointless before 7.4 fixes them.
- **Relevant files:** `home_screen.dart`, `lib/core/config/feature_scope.dart`.
- **Known issues:** the URL hard-codes lat 45.872, lon 14.547 (Slovenia), not the user's site (DEV-P1; still open, TASK 7.4's job). *Resolved (TASK 4.3):* the card was ungated (TD-014).
- **Dependencies:** url_launcher.
- **Roadmap relevance:** Phase 11 (ahead of phase).

# Planning

## F-35 — Capture plan editor (blocks)
- **Status:** Partial
- **Current implementation:** add, edit, delete, reorder (light/dark/flat/bias with a filter list); default plan 100×60 s lights, 20×60 s darks, 20×2 s flats; persisted in preferences. **TASK 4.1:** the add dialog is shared with a new edit dialog (opened by tapping a block), reachable at `updateCaptureBlock` for the first time; both reject invalid input (exposure > 0, frame count ≥ 1) via `Form` validators instead of silently defaulting; list items key on `ObjectKey(block)` instead of a hashCode+index combination that changed on every reorder. **TASK 4.4:** the Sequence Plan header carries an "Example plan" badge while the seeded default is unmodified, clearing on the first add/edit/remove/reorder or on loading a saved session.
- **Relevant files:** `lib/presentation/widgets/capture_plan_widget.dart`, `planner_viewmodel.dart` (`reorderCaptureBlocks`, `updateCaptureBlock`, `isExampleCapturePlan`), `lib/domain/models/capture_block.dart`.
- **TASK 5.3:** blocks are validated in the domain (exposure (0, 3600] s, count 1–100 000, binning 1–4); the dialog's validators match these bounds; order is persisted (`position`); each calibration block has a policy (default outside the window) and each block a typed gain.
- **TASK 5.6:** the editor also sets binning, the calibration policy ("When is it taken?") and a typed sensitivity setting (ISO / camera gain / not recorded, labelled "recorded only"); list rows show each calibration block's policy; split into `lib/presentation/widgets/capture_plan/` (`capture_block_dialog.dart`, `capture_budget_summary.dart`, `capture_assumptions_panel.dart`).
- **Known issues:** none specific to the editor. *Resolved (TASK 5.6):* binning, gain and the calibration policy were not exposed in the UI. *Resolved (TASK 4.1):* dragging a block **down** used to under-move by one (`newIndex -= 1` applied on top of `onReorderItem`'s own adjustment, TD-010); invalid or empty input used to silently become 60 s × 30 with negatives accepted, and there was no edit UI (TD-012, partially — binning/gain exposure was out of this task's scope). *Resolved (TASK 4.4):* the default plan used to be shown with no distinction from the user's own plan (SI-008; TD-013).
- **Dependencies:** F-03.
- **Roadmap relevance:** Phase 9 (central component).

## F-36 — Session duration and feasibility
- **Status:** Partial
- **Current implementation:** **since TASK 5.4** `estimatedRequiredTime` is the ADR-009 window load from `CaptureBudgetCalculator` (lights and in-window calibration, per-frame and enabled optional overheads), compared with the summed visibility windows by `SessionCalculator.calculateFeasibility` → Feasible / Tight (configurable margin, TASK 5.2) / Infeasible. The Home line is relabelled "Time needed in window" (it was "Session Duration", which is no longer what it shows).
- **Relevant files:** `planner_viewmodel.dart:478-491`, `lib/domain/services/session_calculator.dart:51-80`.
- **TASK 5.5:** the fit is `FitAnalyzer` — the plan's event sequence placed atomically into the windows; the Home row reads "Fit tonight" (Fits / Tight / Doesn't fit / No window / Nothing to fit) with its reason underneath (for example "1 frame don't fit tonight … About 2 similar nights are needed").
- **Known issues:** the full breakdown (integration, acquisition, session budget, end time, the inverse answer, the assumptions panel) is not shown yet (TASK 5.6); no Moon/weather. *Resolved (TASK 5.5):* frames could "straddle" a gap between windows under the old sum-of-windows rule (ADR-009 E2c). *Resolved (TASK 5.4):* conflation of integration, acquisition, calibration and total budget (DEV-A4, TD-022).
- **Dependencies:** F-13; decision PD-08.
- **Roadmap relevance:** Phase 9.

## F-37 — Integration time and relative stacking gain
- **Status:** Partial
- **Current implementation:** integration from `CaptureBudgetCalculator`; **since TASK 5.6** √N is shown **per group of light frames with the same filter and exposure** (e.g. "Ha · 300 s × 20 — 4.5x") under the heading "Relative stacking gain (√N vs one frame)", with help text saying it is not a signal-to-noise ratio of the image and only applies within a group (ADR-009 §7).
- **Relevant files:** `planner_viewmodel.dart:471-476,502-504`, `optical_calculator.dart:44-47`, `capture_plan_widget.dart:206-218`.
- **Known issues:** none known. *Resolved (TASK 5.6):* gain used to pool all light frames regardless of sub-exposure length and filter (SI-003). *Resolved (TASK 4.4):* the UI label used to say "Relative SNR" (ADR-005 deviation; TD-009).
- **Dependencies:** F-35.
- **Roadmap relevance:** Phase 9.

## F-38 — Imaging Opportunity
- **TASK 10.3:** presented on Home as "Tonight for this target" (chart + list from the same result; every excluded period with its reasons). Still Partial: the optional Moon/cloud gates have no Settings control (TD-050); no horizon input (F-17).
- **TASK 10.2 (Partial):** `ImagingOpportunityCalculator` (ADR-013) computes gated windows, reasons for excluded time, the no-window reason, max altitude inside windows and Moon/weather annotations; the budget fit consumes its windows. Still Partial: not presented (TASK 10.3); the optional Moon/cloud gates have no Settings control yet; no horizon input (reserved, F-17).
- **Status:** Partial (was Missing)
- **Current implementation:** none; the nearest equivalent is the darkness ∩ altitude window list (F-13).
- **Relevant files:** —
- **Known issues:** the central product concept (darkness, visibility, Moon and weather combined) does not exist; it must be a transparent model, not a black-box score.
- **Dependencies:** F-09, F-10, F-13, F-15, F-16, F-29.
- **Roadmap relevance:** Phases 8–10.

## F-39 — Calibration-frame planning
- **Status:** Partial *(was Missing; TASK 5.3)*
- **Current implementation:** each dark/flat/bias block now carries a calibration policy (`inWindow` / `outsideWindow` / `library`, default `outsideWindow`, ADR-009 §3), persisted in the database and the plan JSON. Nothing uses it yet: the live required time still counts every block against the window until TASK 5.4, and there is no UI to change it until TASK 5.6.
- **Relevant files:** `capture_block.dart`, `capture_plan_widget.dart`.
- **TASK 5.6:** the policy is editable per block and drives the budget: "Calibration during the window" and "Calibration outside the window" are separate lines, library blocks are listed as needing no time.
- **Known issues:** outside-window calibration is only totalled, not scheduled into twilight (ADR-009 L5). *Resolved (TASK 5.4–5.6):* calibration time was counted against the night window regardless of policy.
- **Dependencies:** decision PD-08.
- **Roadmap relevance:** Phase 9.

# Session and logbook

## F-40 — Save session (planned)
- **Independent validation (2026-09-25, `4e653fb`):** the S1.6 replacement safeguard is **Partial**: target/night-only changes lose protection after restart (TD-061); reopening the same session from stale detail data rolls back the displayed plan and clears the flag (TD-062). Save/Start serialization tests still pass. Proposed S1.V3/S1.V4.
- **S1.6 (2026-09-25, commit `c0bfcb7`):** replacing a plan with unsaved changes (New, Duplicate, opening another session) asks first; an untouched draft is replaced silently as before (`unsaved_plan_guard_test.dart`). Interim safeguard; the draft model is RD-05 (Stage 4).
- **TASK 11.4 (Implemented):** the plan lives in the current draft session and is autosaved on every edit (a force-stop loses nothing); New, Duplicate for another night and Open manage drafts; Save moves the session to planned with a fresh snapshot.
- **TASK 11.3:** Save stores a **planned session** through `SessionRepository` with stable references (site, target, rig), the night key and a versioned plan snapshot (site, target, rig, preferences, blocks, budget, windows, weather); saving again updates the same open session; a completed, abandoned or legacy session is never modified (a new one is created). The known issues below (null snapshot fields, direct repository calls) are resolved by this. Still Partial: autosave and drafts are TASK 11.4.
- **Status:** Partial
- **Current implementation:** a "Save Session" button writes target name, equipment name, date, planned light frames and blocks; updates instead if a session was loaded or already saved this session (**TASK 4.2:** `addLog` now returns the new id and `PlannerViewModel.markSessionSaved` records it, so a second tap updates instead of duplicating).
- **Relevant files:** `home_screen.dart`, `lib/data/repositories/drift_logbook_repository.dart`, `lib/presentation/viewmodels/planner_viewmodel.dart` (`markSessionSaved`).
- **Known issues:** location, Bortle, weather, focal length, aperture, integration time and planned calibration counts stay null (verified); the widget calls the repository directly (DEV-A2, DEV-D3). *Resolved (TASK 4.2):* tapping twice used to insert two rows (TD-011).
- **Dependencies:** F-35, F-41.
- **Roadmap relevance:** Phase 13 (ahead of phase).

## F-41 — Logbook list / reload / delete / share
- **TASK 14.2 (commit `4274175`):** integration so far per target (per filter, last night, session count) in Library → Progress and on each session's detail (CALC-38).
- **TASK 14.1 (commit `e212f6a`, Implemented):** filters by status, target, site and night date (in the query); a Legacy badge; a tap opens the read-only detail from the session's snapshot (execution-start for started sessions, plan for planned ones — owner decision) with plan vs actual per block, notes and conditions; the planner opens from the detail (a copy for frozen sessions). Remaining: no undo after delete; accumulated integration per target is TASK 14.2.
- **TASK 11.4:** a saved plan edited since its last Save stays listed as "Planned, unsaved changes"; opening a completed or legacy session copies it into a new draft (owner decisions).
- **TASK 11.3:** reads `SessionRepository`: every non-draft session (planned, in progress, completed, abandoned) and the legacy logs, newest-updated first, each with a status label (owner decision); tap opens the session in the planner following its references **by id** (legacy rows still match by label); swipe-delete keeps its confirmation.
- **Status:** Partial
- **Current implementation:** list of sessions, newest-saved first (**TASK 4.2**); tap reloads a session into the planner; swipe deletes with a confirmation dialog (**TASK 4.2**, matching the equipment/target screens' pattern); share sends `toShareableText()`.
- **Relevant files:** `lib/presentation/screens/logbook/logbook_screen.dart`, `session_log.dart`.
- **Known issues:** no undo after delete; reload re-matches target/equipment **by name**; the loaded date becomes a local `DateTime`. *Resolved (TASK 4.2):* unordered (oldest first); swipe-delete had no confirmation; no widget test (TD-039).
- **Dependencies:** F-40; gate `FeatureScope.logbook`.
- **Roadmap relevance:** Phase 13 (ahead of phase).

## F-42 — Planned-versus-actual logging
- **TASK 13.4 (commit `c1e52ce`):** the results page fills the actual and rejected light-frame totals (from the run's counters), notes and optional conditions; planned vs actual light integration is shown on the page and in Sessions; completed sessions can be corrected (timestamped events). The known issue below is resolved for sessions tracked since TASK 13.2; legacy logs keep their stored values.
- **Status:** Implemented *(TASK 13.4; was Partial)*
- **Current implementation:** the model and database hold `actualLightFrames`, `rejectedFrames`, environmental and processing notes; the list displays them when set.
- **Relevant files:** `session_log.dart`, `drift_logbook_repository.dart`, `logbook_screen.dart:86-91`.
- **Known issues:** **no UI anywhere sets them**, so the values are always null.
- **Dependencies:** F-41.
- **Roadmap relevance:** Phase 13.

## F-43 — Session execution mode
- **Decided 2026-09-24 (TASK 13.1, ADR-016):** foreground-only tracking derived from persisted UTC timestamps; append-only events (`session_events`, v17); estimated frames shown, counts only by user confirmation; one session in progress at a time; resume prompt after a kill or when the night has ended, never auto-finished; opt-in keep-screen-on. Implementation: TASKs 13.2–13.4.
- **TASK 13.2 (commit `14467e7`):** the execution engine exists: pure `ExecutionMachine` (transitions, fold, running time, frame estimate, staleness), the append-only `session_events` table (v17), repository methods (`start` on the first light block, `record`, `complete`/`abandon` with events, `inProgress`, one session in progress at a time), and a resume prompt at start. There is no tracking screen yet, so nothing in the app starts a session (TASK 13.3).
- **TASK 13.3 (commit `c8e2240`):** a session can be started (planner and Tonight) and tracked on a full-screen, one-thumb, red-safe screen: confirmed and estimated counts, +1/−1/Reject/Accept estimate, pause with a reason, resume, block switcher, finish/abandon, countdowns (dawn, target below its limit, moonrise), remaining window vs plan, opt-in keep-screen-on. Still missing: reconciliation into results (13.4).
- **TASK 13.4 (commit `c1e52ce`):** Finish opens reconciliation; Complete or Abandon ends the run there; corrections after completion. F-43 is Implemented; the Android device checks in TEST_PLAN are still pending.
- **Status:** Implemented *(TASKs 13.2–13.4)*
- **Current implementation:** `lib/presentation/screens/execution/execution_screen.dart`, `results_screen.dart`, `ResultsViewModel`, `SessionReconciliation`, `ExecutionViewModel`, `ExecutionOutlook`, `lib/domain/services/execution_machine.dart`, `lib/domain/models/execution.dart`, `DriftSessionRepository` (events), `ResumeRunViewModel` + `resume_run_dialog.dart`.
- **Relevant files:** see above.
- **Known issues:** no screen to start or track a run (13.3); reconciliation (13.4); TD-055. The "Execution" step of the product workflow does not exist (hardware control is out of scope).
- **Dependencies:** F-42.
- **Roadmap relevance:** Phases 13, 15.

## F-44 — Export / interoperability manifest
- **TASK 14.3 (commit `a234ff6`):** manifest v2 (`docs/EXPORT_MANIFEST.md`) exported per session and for all sessions as a shared `.json` file with a text summary; v1 still readable; tested round trip. Import is deferred (roadmap).
- **Status:** Implemented *(export; was Prototype)*
- **Current implementation:** `SessionLog.toJson()` / `fromJson()` (manifest v1) with tests; text sharing is live (F-41).
- **Relevant files:** `lib/domain/models/session_log.dart`, `test/domain/models/session_log_test.dart`.
- **Known issues:** JSON path is used only by tests; manifest lacks coordinates and time zone; no import UI; `cloud_cover_percent` cast fails on a non-integer JSON number.
- **Dependencies:** F-42.
- **Roadmap relevance:** Phase 14 (ahead of phase).

## F-45 — Metadata import (EXIF / FITS)
- **S2.2 (2026-09-26):** the contract's typed values with provenance and explicit unknowns exist (`capture_metadata.dart`, `metadata_value.dart`). No reader yet, and still hidden.
- **S2.1 (2026-09-26):** the bounded source, byte budget and signature recognition exist (`lib/domain/metadata/`, `lib/data/metadata/`). The screen and the prototype are unchanged, and the feature is still hidden.
- **Decided 2026-09-26 (ADR-017; DECISIONS E.1):** Stage 2 rebuilds the foundation (bounded reads, signature recognition, a typed contract, no GPS/serial/observer, Android access without a copy); DNG only, FITS on a sample; the screen stays hidden during Stage 2 (S2.1–S2.6).
- **S2.R1 (2026-09-26, research; no code changed):** the owner supplied two real phone DNGs, kept outside the repository. On them, the prototype finds none of the capture fields: it reads only `EXIF …` keys, while these files keep the tags in IFD0 (TD-064). The recommended formats, readers and fixture policy are in `refinement/research/RG-01_METADATA_FORMATS.md`, pending the owner's decision (PD-21, proposed ADR-017). The status is still Prototype.
- **Status:** Prototype
- **Current implementation:** gallery picker → `MetadataExtractor` → read-only cards and a raw tag list.
- **Relevant files:** `lib/presentation/screens/metadata/metadata_import_screen.dart`, `lib/domain/services/metadata_extractor.dart`.
- **Known issues:** `image_picker` gallery cannot select FITS, so FITS is unreachable on a device; reads whole files into memory; FITS `/` inside string values truncates them; nothing is stored or connected to sessions or equipment; **no real sample files exist**, which the ROADMAP requires before this phase; only synthetic-input unit tests (TD-018).
- **Dependencies:** image_picker, exif; gate `FeatureScope.metadataImport`.
- **Roadmap relevance:** Phase 12 (ahead of phase).

## F-46 — Field mode
- **TASK 12.4 (Implemented, commit `3c27b15`):** red field mode is visible (`FeatureScope.fieldMode = true`), one tap from Tonight and the planner (`FieldModeButton`) and a switch in Settings (`FieldModeTile`); persisted through `DisplayPreferencesRepository` and restored before the first frame. Every field-theme colour is red or black, and the whole app goes through a red colour filter in field mode (owner decision), so dialogs, date pickers, snackbars and map tiles are red too. Automated darkness checks pass (pixel tests); the check in real darkness on a device is an owner checklist item, not yet done.
- **Status:** Implemented *(TASK 12.4; was Prototype, hidden since TASK 4.3)*
- **Current implementation:** an app-bar toggle switches to `AppTheme.fieldTheme` (in-memory). **TASK 4.3:** the toggle button is gated behind `FeatureScope.fieldMode` (hidden until TASK 12.4), so it has no entry point at all — the underlying `ThemeViewModel`/`AppTheme` code is unchanged and unreachable rather than removed.
- **Relevant files:** `theme_viewmodel.dart`, `main.dart`, `home_screen.dart`, `lib/core/config/feature_scope.dart`.
- **Known issues:** not persisted; no checklist or other field utilities (DEV-P1). *Resolved (TASK 4.3):* ungated despite ADR-006 (TD-014).
- **Dependencies:** decision PD-06 (resolved 2026-09-21: `DECISIONS.md` E.1); enforced by roadmap TASK 4.3.
- **Roadmap relevance:** Phase 15 (ahead of phase).

## F-47 — Custom dashboard
- **TASK 12.5 (commit `b13f7c7`):** the fixed Tonight view is Implemented: site and night, the night's dark window, the Moon, the weather with its age, and the current session's fit with its reason; each row drills down. A customizable dashboard stays out of scope (PD-14).
- **Decided 2026-09-23 (PD-14 via ADR-015):** no customizable dashboard; a fixed Tonight view instead. **TASK 12.2:** the Tonight tab exists with an interim root (site, night, current session, quick actions); the dashboard itself is TASK 12.5.
- **Status:** Missing
- **Current implementation:** none; the Home screen is a fixed vertical list of cards.
- **Relevant files:** `home_screen.dart`.
- **Known issues:** listed as a next step by the previous audit but **absent from PRODUCT_SPEC and ROADMAP** (PD-14).
- **Dependencies:** decision PD-14.
- **Roadmap relevance:** not in the roadmap.

# Quality and platform

## F-48 — Automated tests
- **Status:** Partial *(TASK 15.5, 2026-09-24: an end-to-end suite of the core loop,
  `integration_test/core_loop_test.dart`, runs in the quality gate on the host and passes as a
  native Windows app; still Partial until it is green on an Android emulator — none is
  available on the development machine. 878 unit/widget tests + 2 end-to-end.)*
- **Current implementation:** 147 tests in 29 files; all pass, three consecutive full runs (`dart run tool/check.dart` after TASK 2.3; 135 in 27 files after TASK 2.2, 83 in 24 files after TASK 1.2). New (TASK 2.3): `visibility_calculator_session_night_test.dart` (9 tests: the ADR-007 polar cases, exact agreement between the new SessionNight-based API and the legacy wrappers, clip-flag behavior in both) and `altitude_chart_widget_test.dart` (3 tests, the chart's first widget test: a normal night, a polar-night site, a date far from "now"). New (TASK 2.2): `session_night_resolver_test.dart` (the ADR-007 matrix and invariants), `calendar_date_test.dart`, `clock_test.dart` (which includes a guard that `lib/domain` has no `DateTime.now()`), plus one `SessionLog.fromJson` clock-fallback test. Earlier: `flutter analyze` clean. Location is injected (`FakeLocationService` in `test/support/`) and the ViewModel is awaited with `vm.ready`. New (TASK 1.2): `planner_bootstrap_test.dart` (seeding-before-first-read, bootstrap-failure/retry, `isDefaultLocation`) and `home_screen_test.dart` (empty-state actions, default-location banner, weather-failure/retry, bootstrap-failure/retry), using a `FlakyTargetRepository` test double (`test/support/`).
- **Relevant files:** `test/` (see `docs/TEST_PLAN.md`).
- **Known issues:** no test for the live capture-budget math, Capture Plan, Sky, Logbook, Location or Metadata screens; no migration tests; some tests mirror the implementation (NPF); `AppRouter.router` is a shared static — `home_screen_test.dart` resets it in `setUp()` to avoid cross-test navigation leaks, a workaround, not a fix; Nominatim and light-pollution HTTP are not injectable (TD-025, TD-037). *Resolved 2026-09-21 (TASK 1.1, `2357755`):* the red `integration_flow_test.dart` (TD-003), the 300 ms sleeps, and GPS access in tests. *Resolved 2026-09-22 (TASK 2.3):* no widget test for the altitude chart.
- **Dependencies:** —
- **Roadmap relevance:** Phases 1, 16.

## F-49 — CI / build automation
- **Status:** Partial *(was Missing; TASK 1.3, commit `97924a0`)*
- **Current implementation:** `tool/check.dart` (`dart run tool/check.dart`) runs `dart format --set-exit-if-changed`, `flutter analyze --no-pub` and `flutter test --no-pub` — all three regardless of an earlier failure, then a pass/fail summary, exiting non-zero on any failure. `.github/workflows/ci.yml` runs it on push to `main` and on pull requests.
- **Relevant files:** `tool/check.dart`, `.github/workflows/ci.yml`.
- **Known issues:** *(corrected S1.15, 2026-09-25: a remote exists, `github.com/Buffur/Astro-Planner`, public, but `main` has not been pushed since `a1bcbd9`, before TASK 1.3, so the workflow has never run; the owner deferred the push in S1.14, RD-17. The original wording follows.)* No Git remote is configured, so the workflow has never actually run (untested in the real GitHub Actions environment); stricter lints (TD-038) and device runs remain out of scope by design (since TASK 15.5 the gate runs the end-to-end suite on the host test device); since TASK 15.1 `empty_catches` is enabled and the gate's test step includes a no-empty-catch scan.
- **Dependencies:** —
- **Roadmap relevance:** Phases 1, 16.

## F-50 — Platform support
- **Status:** Partial
- **Current implementation:** Android is configured (`io.github.chacha12.astroplanner` since TASK 16.1; corrected S1.15, it read `com.astroplan.astroplan`; location and internet permissions, Java 17); iOS, web, Windows, Linux and macOS folders are Flutter scaffolds.
- **Relevant files:** `android/`, `ios/`, `pubspec.yaml`.
- **Known issues:** *(updated TASK 16.2, 2026-09-24: a debug APK and a release bundle build on the development machine; the release build is signed with the owner's upload key from `android/key.properties` when present — not created yet — and the app has not been installed or run on an Android device.)* no Android build or device run was performed in this audit (Unknown); release signing uses the debug key; iOS `Info.plist` lacks location and photo usage strings; `dart:io` file access makes the web target unsupported; `sdk: ^3.13.3` is a very tight Dart constraint (TD-031).
- **Dependencies:** —
- **Roadmap relevance:** Phases 1, 16 (ADR-001: Android first).

## F-51 — Tonight's candidates (all targets for one night)
- **Status:** Implemented (TASK 10.4, commit `6bb596f`)
- **Current implementation:** `CandidateEvaluator` evaluates every target in the database for the chosen night with the same rules and inputs as Home's opportunity card (ADR-013: darkness, minimum altitude, optional Moon/cloud gates, forecast), sharing the Sun and Moon samples; `TonightScreen` (`/tonight`, Home app bar) sorts by usable time (default), window start, max altitude, Moon separation, frame fill or name, filters by type / own targets, hides targets without a window unless toggled (each then shows its reason), and a tap selects the target. Runs on a background isolate. No score or recommendation.
- **Relevant files:** `lib/domain/services/candidate_evaluator.dart`, `lib/presentation/screens/tonight/tonight_screen.dart`, `planner_viewmodel.dart` (`tonightCandidates`).
- **Known issues:** the list is not re-evaluated automatically when preferences or the night change (a refresh button re-runs it); 250 targets take about 0.1–0.2 s on the development machine — the mid-range-device figure in the acceptance is **not verified** (no device run, like all Android behaviour); frame fill needs selected equipment and a known target size.
- **Dependencies:** F-38, F-19 (targets), F-22 (equipment).
- **Roadmap relevance:** MASTER_ROADMAP TASK 10.4.
