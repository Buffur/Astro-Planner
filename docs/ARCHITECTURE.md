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
  `Provider<WeatherRepository>`, `Provider<LogbookRepository>`,
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
| 5 | **Reverse geocoding** — raw `http.get` to Nominatim, errors swallowed (the doc comment still says "Open-Meteo") | `:163-187` |
| 6 | **Light pollution / Bortle** — `_fetchBortle` (calls the concrete repository), `setBortleClass`, default 4 | `:189-214,344-364` |
| 7 | **Weather** — fetch and refresh via a shared `_fetchWeather()`; loaded post-first-frame, not on the bootstrap path; `weatherError` set on failure *(updated TASK 1.2)* | `:279,324-335` |
| 8 | **Capture plan** — add/update/remove/reorder blocks; hand-written JSON persistence; default 3-block plan | `:287-328` |
| 9 | **Thresholds** — minimum altitude (clamped 5–60°), dew-point margin, both persisted | `:151-161,366-371` |
| 10 | **Derived calculations exposed to the UI** (recomputed on every access, no caching): `nightTimeline`, `visibilityWindows`, `lunarIllumination`, `skyDarknessWarning`, `dewWarning`, `currentAltitude`, `maxAltitude`, `npfExposure` (unused), `totalIntegrationTime`, `estimatedRequiredTime`, `sessionFeasibility`, `estimatedStorageMB`, `relativeStackingGain`, `pixelScale` | `:413-512` |

State fields: `_isLoading`, `_bootstrapError`, `_usingDefaultLocation` *(both added
TASK 1.2)*, `_selectedTarget`, `_selectedEquipment`, `_currentWeather`,
`_weatherError` *(added TASK 1.2)*, `_locationName`, `_pickedEveningDate`
(a `CalendarDate?`, replacing `_sessionDate`; null = use the default night,
*updated TASK 2.4*), `_clock` (a `Clock`, default `SystemClock`; *added TASK 2.4*),
`_latitude`/`_longitude` (default London), `_captureBlocks`, `_bortleClass`
(default 4), `_dewPointThreshold` (default 2.0), `_activeSessionLog`, `_minAltitude`
(default 20.0). The `captureBlocks` getter exposes the internal mutable list.

Direct imports that skip the intended layers: `package:http`,
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
`EquipmentCatalogRepository` (**unused**), `LocationRepository`, `LogbookRepository`,
`WeatherRepository`.

**Abstracted (TASK 1.1):** device location for the ViewModel — the pure-Dart
`LocationService` interface (`lib/domain/services/location_service.dart`),
implemented by `GeolocatorLocationService` (`lib/data/services/`) and replaced by
`FakeLocationService` in tests (`test/support/`).

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
  `DriftLocationRepository`, `DriftLogbookRepository` (session rows plus a separate
  `capture_blocks` table, joined in memory; manual cascade on delete, now backed by
  a real `ON DELETE CASCADE` too),
  `OpenMeteoWeatherRepository` (HTTP + shared-preferences cache; `http.Client`
  injectable), `LightPollutionRepository` (concrete; static `http.get`; not
  injectable; **cannot succeed**, SI-007).
- **Seeders:** `CatalogSeeder` (5 targets), `EquipmentSeeder` (5 profiles).

## B7. Routing (go_router)

`AppRouter.router` is a **static final** `GoRouter` (a process-wide singleton) in
`lib/presentation/navigation/app_router.dart`, `initialLocation: '/'`.

| Path | Screen | Gate |
| --- | --- | --- |
| `/` | `HomeScreen` | — |
| `/target` | `TargetSelectionScreen` | — |
| `/equipment` | `EquipmentSelectionScreen` | — |
| `/location` | `LocationPickerScreen` | — |
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
| `LocationPickerScreen` | VM + Geolocator + `flutter_map` | Duplicates the ViewModel's Geolocator flow |
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
| Nominatim (OSM) | Reverse geocoding | `PlannerViewModel._reverseGeocode` | None (User-Agent `AstroPlan/1.0`) | Usage policy (rate limit, identifying UA, caching); called on each location change | Silent |
| ClearOutside (HTML scrape) | Bortle class | `LightPollutionRepository` | None | Third-party scraping; ToS unknown; request URL is malformed so it never succeeds | Returns `null` |
| OSM tile server | Map picker tiles | `LocationPickerScreen` | None | Tile usage policy requires attribution (none shown) and an accurate UA (`com.example.astroplan` ≠ real `applicationId` `com.astroplan.astroplan`) | Blank tiles |
| lightpollutionmap.info | External map link via `url_launcher` | `HomeScreen` | None | Opens a URL with **hard-coded** Slovenia coordinates | — |
| Geolocator (GPS) | Device location | `GeolocatorLocationService` (behind `LocationService`, used by the VM) and `LocationPickerScreen` | — | Permissions declared for Android; iOS `Info.plist` has no location usage strings | Platform errors still unhandled on the VM startup path |
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
| P2 | **Interfaces for platform/IO**: device location, reverse geocoding, light-pollution source, key-value preferences, clock | Testability; remove `http`/`geolocator`/`shared_preferences` from the ViewModel | TD-019, TD-003 *(device location: done in TASK 1.1; the rest is open)* |
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
