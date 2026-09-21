# Architecture Overview

## ACTUAL ARCHITECTURE

The project implements a straightforward, highly decoupled MVVM (Model-View-ViewModel) architecture tailored for Flutter, heavily leaning on `Provider` for dependency injection and state management.

### Layer 1: Presentation (UI)
- **Framework:** Flutter Widgets
- **Location:** `lib/presentation/`
- **Routing:** `go_router` (configured in `lib/presentation/navigation/app_router.dart`).
- **Characteristics:** Minimal logic. Observes ViewModels via `context.watch` or `Consumer`.

### Layer 2: State Management (ViewModels)
- **Framework:** `ChangeNotifier` + `Provider`
- **Location:** `lib/presentation/viewmodels/` (e.g., `planner_viewmodel.dart`)
- **Characteristics:** Acts as the glue between UI and the Domain layer. Holds the UI state, orchestrates business logic by calling Domain Services, and exposes formatted data to the UI.

### Layer 3: Domain Services & Models
- **Location:** `lib/domain/services/`, `lib/domain/models/`, `lib/domain/repositories/`
- **Characteristics:** Pure Dart classes. Contains the core astronomical algorithms (`astronomical_engine.dart`, `visibility_calculator.dart`), optical math (`optical_calculator.dart`), and domain interfaces (abstract Repositories).
- **Core Entities:** `AstroTarget`, `EquipmentProfile`, `SessionLog`, `CaptureBlock`, `WeatherConditions`.

### Layer 4: Data / Infrastructure (Repositories)
- **Location:** `lib/data/repositories/`, `lib/data/database/`, `lib/data/services/`
- **Characteristics:** Implements domain repository interfaces. Handles external APIs and local persistence.
- **Persistence:** SQLite managed via `Drift` (`AppDatabase`).
- **External Services:** 
  - Open-Meteo for weather (`OpenMeteoWeatherRepository`).
  - Clear Outside for Light Pollution (Bortle scale) (`LightPollutionRepository`).
  - OpenStreetMap (Nominatim) for reverse geocoding in `PlannerViewModel`.

## ARCHITECTURAL CONCERNS

1. **ViewModel Bloat:** `PlannerViewModel` is quite large (~514 lines). It manages equipment selection, target selection, weather state, capture blocks, reverse geocoding, and exposes numerous computed properties (astronomical logic). This violates the Single Responsibility Principle and could be split into smaller, domain-specific ViewModels (e.g., `CapturePlanViewModel`, `VisibilityViewModel`).
2. **Reverse Geocoding in ViewModel:** The HTTP call to Nominatim OSM is performed directly inside `PlannerViewModel._reverseGeocode` rather than abstracting it into a `LocationRepository` or dedicated `GeocodingService`.
3. **Repository Instantiation:** Repositories are instantiated in `main.dart` and injected via `Provider`, which is fine, but they could also be bundled in a more formal DI container like `get_it` if the app scales.
4. **LightPollutionRepository Parsing:** `LightPollutionRepository` fetches HTML from `clearoutside.com` and parses it with a Regex to find the Bortle class. This is brittle to web layout changes.
