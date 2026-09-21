# Project Handoff: AstroPlan

## Project Overview
AstroPlan is a Flutter/Dart mobile application designed to help astrophotographers plan, execute, and document their sessions. The core question it answers is: **"What can I realistically photograph during the available night, with my current equipment?"**

It integrates location, weather, target visibility, and equipment specifications to generate feasible capture plans. It is explicitly scoped as a planner and logbook—it is **not** a full planetarium like Stellarium, and it does not control hardware.

## Product Goal
Unify the workflow of astrophotography planning:
Location/Site -> Astronomical Conditions -> Target -> Weather -> Equipment -> Capture Plan -> Actual Session -> Logbook.

## Current State
The project has moved beyond Phase 0. A robust Domain layer exists with scientific calculations implemented natively in Dart. The Data layer uses SQLite (via Drift) for persistence and Open-Meteo for weather. A Presentation layer (UI) exists using Provider and ViewModels, providing a functional baseline for planning, equipment selection, target search, and logging sessions.

## Current Architecture
- **Framework:** Flutter / Dart
- **Pattern:** MVVM (Model-View-ViewModel) via Provider.
- **Data Persistence:** SQLite (Drift).
- **Navigation:** `go_router`
See [ARCHITECTURE.md](ARCHITECTURE.md) for deeper details.

## Important Files
- `lib/main.dart` - Entry point & dependency injection.
- `lib/presentation/viewmodels/planner_viewmodel.dart` - The core state machine of the app.
- `lib/domain/services/astronomical_engine.dart` - Native Dart astronomy math (Julian Date, LST, GMST).
- `lib/domain/services/visibility_calculator.dart` - Computes target altitude and night timeline.
- `lib/domain/services/session_calculator.dart` - Estimates physical time required for capture blocks.
- `lib/domain/services/metadata_extractor.dart` - Extracts metadata (EXIF/FITS) from image files.
- `lib/domain/models/session_log.dart` - Represents an executed or planned session.

## Feature Overview
- **Implemented:** Target management, Equipment CRUD, Capture Planner (Lights, Darks, Flats, Bias), Astronomical Calculations (Altitude, Visibility Windows, explicit Twilights), Weather (Open-Meteo), Session Logbook, Metadata Import (EXIF & FITS via ImagePicker).
- **Partial:** Light Pollution (using fragile web scraping from ClearOutside). 
- **Unknown/Missing:** Customizable UI dashboard (it acts as a vertical scroll of static cards right now).
See [FEATURE_STATUS.md](FEATURE_STATUS.md) for full breakdown.

## Data Model
Core Entities: `AstroTarget`, `EquipmentProfile`, `SessionLog`, `CaptureBlock`, `LocationProfile`, `WeatherConditions`, `ImageMetadata`.
See [DATA_MODEL.md](DATA_MODEL.md).

## Core Calculations
- NPF Exposure & Stacking Gain: Handled in `OpticalCalculator`.
- Capture Session Duration Overhead: `SessionCalculator` contains a 15% overhead logic for estimation, BUT `PlannerViewModel` calculates overhead as a flat `5.0` seconds per frame instead. (This is a bug/inconsistency).
- Altitude: Computed via rigorous LST and GMST functions in `AstronomicalEngine`.
- Twilight boundaries: `VisibilityCalculator.calculateNightTimeline` correctly isolates sunrise, sunset, and civil/nautical/astronomical twilights.

## APIs & Storage
- **Weather:** Open-Meteo (No API key). Cached via SharedPreferences.
- **Geocoding:** Nominatim (No API key).
- **Storage:** Drift (SQLite).

## Testing
- Includes unit tests for core services (astronomical engine, optical calculator, session calculator, visibility calculator), widget tests, and drift database tests.
- **Failed Test:** `integration_flow_test.dart` is currently failing (`pumpAndSettle` timeout) due to an un-mocked HTTP client call (Geocoding/Weather in `PlannerViewModel` during initialization).

## Known Problems & Technical Debt
- `PlannerViewModel` is a god-class and manages too many concerns.
- Capture plan overhead logic is duplicated/inconsistent between `SessionCalculator` and `PlannerViewModel`.
- Web scraping for light pollution is fragile.
- See [TECH_DEBT.md](TECH_DEBT.md) for a prioritized list.

## Security Concerns
- No hardcoded API keys were found in the codebase. Both external APIs used are free, keyless endpoints.

## Recommended Next Steps
1. **Fix `integration_flow_test.dart`:** Mock HTTP dependencies appropriately to resolve the CI failure.
2. **Refactor PlannerViewModel:** Break it down into specific ViewModels (`TargetViewModel`, `EquipmentViewModel`, `WeatherViewModel`, `CapturePlanViewModel`). Resolve the duplicated capture plan overhead calculation.
3. **Fix Light Pollution:** Replace web scraping with a stable API or local dataset.
4. **Build the Custom Dashboard:** Finalize the UI into the intended customizable blocks.

## Facts Verified From Code
- Drift is actively used for local DB.
- Target visibility explicitly uses GMST/LST math in `AstronomicalEngine`.
- `VisibilityCalculator` properly calculates and isolates twilight boundaries.
- Metadata Import EXIF/FITS parsing is implemented and functionally wired via `MetadataExtractor`.
- Open-Meteo is the weather API.
- ClearOutside is scraped via Regex for Bortle scale.
- UTC is used for math, Local time for UI.
- `averageRawFileSizeMB` is used for storage math.
- `integration_flow_test.dart` currently fails due to un-mocked HTTP calls causing timeouts.
- Capture plan duration calculation in `PlannerViewModel` does NOT use `SessionCalculator.estimateTotalDuration`, but instead hardcodes an overhead of 5s per frame.

## Assumptions / Not Verified
- Robustness of SharedPreferences weather caching across complex offline scenarios.
- Reliability of custom FITS parsing across all possible raw FITS file flavors.
