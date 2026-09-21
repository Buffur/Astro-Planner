# Technical Debt

## High Priority
- **Failing Integration Test:** `integration_flow_test.dart` is currently failing with a `pumpAndSettle` timeout because the HTTP client isn't mocked. This affects CI/CD and needs immediate attention.
- **ViewModel Bloat:** `PlannerViewModel` handles too many responsibilities (location/geocoding, equipment state, target state, weather caching, capture block management, and complex property derivation).
- **Light Pollution Scraping:** `LightPollutionRepository` fetches HTML from `clearoutside.com` and parses it via Regex. If the layout changes, Bortle class fetching will break silently. Needs a stable API or robust fallback.
- **Inconsistent Capture Overhead Math:** `SessionCalculator.estimateTotalDuration` calculates overhead as 15% of light duration, but is completely unused. `PlannerViewModel.estimatedRequiredTime` manually adds 5s overhead per frame. This logic should be unified and deduplicated.
- **Weather Repository Offline Handling:** The `OpenMeteoWeatherRepository` logic can fall out of sync or fail to cache if HTTP timeouts occur during unexpected times. The caching logic relies on SharedPreferences but doesn't handle all edge cases of stale data.

## Medium Priority
- **Geocoding in ViewModel:** `_reverseGeocode` in `PlannerViewModel` makes a direct HTTP call to Nominatim. It should be moved to a `LocationRepository` or an external service class.
- **Unified Equipment Rigs:** `EquipmentProfile` combines camera and optics into one entity. In reality, astrophotographers swap cameras and lenses/telescopes. The domain model does not yet cleanly allow composing a "Rig" from separate optical and sensor components natively.

## Low Priority
- **Empty States / UI Placeholders:** While the UI is mostly implemented, the Custom Dashboard is partially missing or implicit (it behaves just as a vertical scroll of static cards right now).
- **Hardcoded Error Fallbacks:** Many catch blocks in `PlannerViewModel` simply silently fail rather than surfacing useful diagnostics to the user (e.g. `try { ... } catch (_) {}` in `_reverseGeocode`).
