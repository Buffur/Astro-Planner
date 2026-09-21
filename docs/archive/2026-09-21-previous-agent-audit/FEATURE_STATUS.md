# Feature Status

| Feature | Status | Files | Notes | Known Problems |
| --- | --- | --- | --- | --- |
| Date Selection | Implemented | `planner_viewmodel.dart` | Sets `sessionDate`, updates weather. | Handled via UTC internally, local in UI. |
| Target Management | Implemented | `drift_target_repository.dart` | Seeded via `CatalogSeeder`. Full CRUD supported. |
| Target Visibility | Implemented | `visibility_calculator.dart`, `astronomical_engine.dart` | Calculates altitude, visibility windows, and culmination. | Does not natively account for horizon obstacles, just flat min altitude (default 20°). |
| Equipment Management | Implemented | `drift_equipment_repository.dart` | Seeded via `EquipmentSeeder`. Handles cameras, telescopes as unified rigs. | Rigs are unified; no separate optical tube / camera combination builder. |
| Weather | Implemented | `open_meteo_weather_repository.dart` | Fetches from Open-Meteo API. Caches to SharedPreferences. | Forecast limited to 48h. |
| Night Timeline | Implemented | `astronomical_engine.dart`, `visibility_calculator.dart` | Calculates sunset, sunrise, lunar illumination, and civil/nautical/astronomical twilights. | None. |
| Light Pollution | Partial | `light_pollution_repository.dart` | Scrapes ClearOutside website via regex for Bortle class. | Highly brittle web scraping; might break if website DOM changes. |
| Capture Planner | Implemented | `planner_viewmodel.dart`, `capture_block.dart`, `session_calculator.dart` | Supports Light, Dark, Flat, Bias. Calculates total duration, storage. | Storage size uses empirical average. Capture time overhead logic is duplicated/inconsistent between `SessionCalculator` and `PlannerViewModel`. |
| Logbook | Implemented | `session_log.dart`, `drift_logbook_repository.dart` | Can load/save sessions, maintains snapshots of environments. | 
| Metadata Import | Implemented | `metadata_import_screen.dart`, `metadata_extractor.dart` | Supports extracting metadata from EXIF or FITS headers. | Robustness across various RAW/FITS files may vary. |
| Custom Dashboard | Prototype / Missing | UI layer | Not fully implemented, UI acts as a vertical scroll of blocks. |
| UI | Implemented | `lib/presentation/` | Follows a clean, dark mode preferred layout using `AppTheme`. |

**Legend:**
- *Implemented*: Feature exists and works according to code paths.
- *Partial*: Feature exists but has notable limitations.
- *Prototype*: Exists as a placeholder or very early version.
- *Broken*: Does not function properly.
- *Missing*: Not implemented.
- *Unknown*: Could not be definitively verified.
