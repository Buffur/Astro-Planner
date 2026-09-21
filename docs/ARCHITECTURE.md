# AstroPlan Architecture

> **Verification stamp:** verified against code at commit `900b82a` (2026-09-20),
> audited 2026-09-21. Application code unchanged since.
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
        │              (pure Dart)      interfaces      (plan, ids, keys)  Geolocator, concrete
        │                    │           │                                LightPollutionRepository
        │                    │           ▼
        │                    │     Drift repositories ──► SQLite (schema v9)
        │                    │     OpenMeteoWeatherRepository ──► Open-Meteo + prefs cache
        │
        ├─► Equipment / Target screens ─► repository interfaces directly (no ViewModel)
        ├─► Logbook screen, Home "Save Session" ─► LogbookRepository directly
        ├─► Location picker ─► PlannerViewModel + Geolocator directly + OSM tiles
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
| 1 | **Bootstrap / hydration** in `_init()`, started from the constructor, not awaitable: reads shared preferences, active location, capture plan, thresholds, selected target/equipment, then **awaits network weather** before clearing `isLoading`; fires reverse geocoding | `:61-128` |
| 2 | **Selection state** — target and equipment, mirrored to shared preferences | `:330-342` |
| 3 | **Session date** and **session loading** (`setSessionDate`, `newSession`, `loadSession`, `_activeSessionLog`); target/equipment re-matched from a log by **name** | `:137-141,373-411` |
| 4 | **Location** — coordinates; `setLocation` (persists, and overwrites the active saved profile); `useCurrentLocation` (Geolocator); default London until GPS succeeds | `:216-280` |
| 5 | **Reverse geocoding** — raw `http.get` to Nominatim, errors swallowed (the doc comment still says "Open-Meteo") | `:163-187` |
| 6 | **Light pollution / Bortle** — `_fetchBortle` (calls the concrete repository), `setBortleClass`, default 4 | `:189-214,344-364` |
| 7 | **Weather** — fetch and refresh; state | `:123,219,282-285` |
| 8 | **Capture plan** — add/update/remove/reorder blocks; hand-written JSON persistence; default 3-block plan | `:287-328` |
| 9 | **Thresholds** — minimum altitude (clamped 5–60°), dew-point margin, both persisted | `:151-161,366-371` |
| 10 | **Derived calculations exposed to the UI** (recomputed on every access, no caching): `nightTimeline`, `visibilityWindows`, `lunarIllumination`, `skyDarknessWarning`, `dewWarning`, `currentAltitude`, `maxAltitude`, `npfExposure` (unused), `totalIntegrationTime`, `estimatedRequiredTime`, `sessionFeasibility`, `estimatedStorageMB`, `relativeStackingGain`, `pixelScale` | `:413-512` |

State fields: `_isLoading`, `_selectedTarget`, `_selectedEquipment`,
`_currentWeather`, `_locationName`, `_sessionDate` (default `DateTime.now().toUtc()`,
`:36`), `_latitude`/`_longitude` (default London), `_captureBlocks`, `_bortleClass`
(default 4), `_dewPointThreshold` (default 2.0), `_activeSessionLog`, `_minAltitude`
(default 20.0). The `captureBlocks` getter exposes the internal mutable list.

Direct imports that skip the intended layers: `package:http`, `package:geolocator`,
`package:shared_preferences`, and the concrete
`lib/data/repositories/light_pollution_repository.dart` (DEV-A1).

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

**Not abstracted (no interface exists):** light pollution (concrete class in the
data layer), reverse geocoding (inline HTTP in the ViewModel), device location
(Geolocator called inline in the ViewModel and in `LocationPickerScreen`),
key-value preferences (inline), current time (`DateTime.now()` inline).

## B6. Data layer (`lib/data/`)

- **Drift `AppDatabase`** (schema 9; 8 tables) with hand-written, raw-SQL
  `onUpgrade` steps; no `beforeOpen`; foreign keys not enforced. See
  `docs/DATA_MODEL.md`.
- **Repositories:** `DriftTargetRepository`, `DriftEquipmentRepository` (reads and
  writes the normalized Device → CameraModule → OpticalRig chain and projects it to
  the flat `EquipmentProfile`), `DriftEquipmentCatalogRepository` (dormant),
  `DriftLocationRepository`, `DriftLogbookRepository` (session rows plus a separate
  `capture_blocks` table, joined in memory; manual cascade on delete),
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
| `/metadata` | `MetadataImportScreen` | `FeatureScope.metadataImport` (currently `true`) |
| `/logbook` | `LogbookScreen` | `FeatureScope.logbook` (currently `true`) |

Navigation uses `context.push` / `context.pop`; the Logbook uses `context.go('/')`
after loading a session. Home's app-bar buttons push `/logbook` and `/metadata`
**unconditionally**, so turning a gate off would navigate to a missing route
(DEV-P1).

## B8. Presentation inventory and where logic lives

| Screen / widget | Reads | Notes |
| --- | --- | --- |
| `HomeScreen` | `PlannerViewModel`, `ThemeViewModel`; `LogbookRepository` for Save | Empty state has **no navigation** to Target/Equipment; ungated field-mode toggle and light-pollution map link (hard-coded coordinates) |
| `TargetSelectionScreen` | `TargetRepository` (direct), VM for selection | Add/edit dialog with validation; no ViewModel for CRUD |
| `EquipmentSelectionScreen` | `EquipmentRepository` (direct), VM for selection | 260-line dialog with validation; contains mojibake strings |
| `LocationPickerScreen` | VM + Geolocator + `flutter_map` | Duplicates the ViewModel's Geolocator flow |
| `LogbookScreen` | `LogbookRepository` (direct), VM `loadSession`, `share_plus` | Swipe-delete without confirmation |
| `MetadataImportScreen` | `image_picker`, `MetadataExtractor` | Display-only |
| `CapturePlanWidget` | VM | Add dialog; reorder; outputs |
| `AltitudeChartWidget` | domain services **inside `CustomPainter.paint`** | Astronomy computed in the widget (DEV-A3) |
| `SkyDarknessWidget` | VM | Static gradient bar unrelated to data |
| `WeatherForecastWidget` | weather model, VM | 48 h strip from local midnight |
| `PlannerSummaryCard`, `InfoRow`, `SectionHeader` | — | Presentational |

Theming: `AppTheme.light`, `AppTheme.dark`, `AppTheme.fieldTheme`; `MaterialApp.router`
uses `ThemeMode.system`, but field mode overrides both light and dark with the field
theme.

## B9. Persistence

Drift (relational) + shared preferences (active plan, selections, thresholds,
active-location pointer, weather cache). Details, keys and migration history:
`docs/DATA_MODEL.md` Part B.

## B10. External services and platform plugins

| Service | Purpose | Where | Key | Policy / risk notes | Failure behavior |
| --- | --- | --- | --- | --- | --- |
| Open-Meteo forecast API | Weather (current + hourly) | `OpenMeteoWeatherRepository`; `models=icon_seamless` hard-coded; `timezone=auto` | None | Free tier is intended for non-commercial use; verify terms before any commercial release. Live query checked 2026-09-21 (London): no nulls in the first 48 h; hourly arrays start at local midnight; `utc_offset_seconds` returned but discarded | Any error → falls back to cache → else `null` (silent) |
| Nominatim (OSM) | Reverse geocoding | `PlannerViewModel._reverseGeocode` | None (User-Agent `AstroPlan/1.0`) | Usage policy (rate limit, identifying UA, caching); called on each location change | Silent |
| ClearOutside (HTML scrape) | Bortle class | `LightPollutionRepository` | None | Third-party scraping; ToS unknown; request URL is malformed so it never succeeds | Returns `null` |
| OSM tile server | Map picker tiles | `LocationPickerScreen` | None | Tile usage policy requires attribution (none shown) and an accurate UA (`com.example.astroplan` ≠ real `applicationId` `com.astroplan.astroplan`) | Blank tiles |
| lightpollutionmap.info | External map link via `url_launcher` | `HomeScreen` | None | Opens a URL with **hard-coded** Slovenia coordinates | — |
| Geolocator (GPS) | Device location | VM and `LocationPickerScreen` | — | Permissions declared for Android; iOS `Info.plist` has no location usage strings | Exceptions unhandled in the VM path |
| `image_picker`, `share_plus` | Gallery pick; share sheet | Metadata screen; Logbook screen | — | `image_picker` cannot select FITS files | — |

## B11. Time handling as built

| Component | Time base |
| --- | --- |
| `_sessionDate` default | **UTC** (`DateTime.now().toUtc()`); the date picker yields a **local-midnight** non-UTC `DateTime` |
| `calculateNightTimeline` / `calculateVisibilityWindows` | Uses Y/M/D of the input as a *local solar date*; scans from 12:00 UTC minus longitude/15 h; returns UTC |
| `AstronomicalEngine.calculateJulianDate` | Requires UTC (throws otherwise) |
| `AltitudeChartWidget` | Starts at **device-local** noon of the input's Y/M/D; converts each step to UTC for math; x-axis labels device-local |
| `SkyDarknessWidget` | Prints `dt.toLocal()` (**device** time zone) |
| Weather | `timezone=auto` → naive site-local strings parsed as **device-local**; offset discarded; `lastUpdated` uses the device clock |
| Sessions | Stored as epoch seconds, read back as local `DateTime`; `toJson` writes UTC ISO-8601; `toShareableText` prints local date |

Consequence (verified): the default night is wrong for evenings west of UTC — see
SI-010 / TD-001. There is no notion of the **site's** time zone anywhere.

## B12. Test architecture

`flutter_test` + Drift `NativeDatabase.memory()` + hand-written mocks (no mocking
package). ViewModel tests avoid Geolocator by pre-setting `activeLocationId` in mock
preferences and wait with `Future.delayed(300 ms)`. `AppRouter.router` is a static
singleton shared by widget tests in a file. No CI configuration exists in the
repository. Details and gaps: `docs/TEST_PLAN.md`, `docs/PROJECT_HANDOFF.md`.

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

## DEV-A2 — Presentation bypasses ViewModels
- **Intended behavior:** `Presentation -> ViewModels -> Repositories`.
- **Actual behavior:** the Equipment, Target and Logbook screens and Home's Save
  button call repositories directly; the Metadata screen calls a domain service and
  `ImagePicker` directly; the Location picker duplicates the Geolocator flow.
- **Consequence:** state ownership is inconsistent (deleting the selected target or
  rig leaves a stale selection in the ViewModel, TD-028); cross-cutting concerns such
  as error states have no home. TD-021.

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

## DEV-A4 — Capture/session budget logic lives in the ViewModel, not the domain
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
| P2 | **Interfaces for platform/IO**: device location, reverse geocoding, light-pollution source, key-value preferences, clock | Testability; remove `http`/`geolocator`/`shared_preferences` from the ViewModel | TD-019, TD-003 |
| P3 | **Deterministic bootstrap**: awaitable initialization; seeding completed before the first read; no network on the critical path; visible error/empty states with navigation | Startup robustness; offline-first | TD-002 |
| P4 | **Capture-budget domain service** (pure Dart) separating integration, acquisition, calibration and total session budget, with configurable overhead | Central product component; testable | TD-022 (PD-08) |
| P5 | **Typed value objects** for the night timeline and windows; one shared altitude function used by ViewModel, windows and chart | Remove triplication and stringly-typed maps | TD-023, TD-024 |
| P6 | **Decompose `PlannerViewModel` only along the seams P2–P4 create** (for example site/weather, plan, selection); incremental and test-first; no big-bang rewrite | Reduce blast radius | TD-019 |
| P7 | **Route screens through ViewModels** when they are next modified | Consistent state ownership | TD-021, TD-028 |
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
