# Technical & Product Decisions

*Note: Many of these are inferred from the implementation and stated product goals.*

## Product
1. **Complement, Not Replace:** AstroPlan is explicitly NOT a Stellarium clone or a full planetarium. It is a planner and a logbook. (Stated in constraints).
2. **Session Feasibility:** The core of the product answers "What can I realistically photograph?". The `SessionCalculator` strictly compares available darkness against capture block times plus a 15% overhead. (Inferred from implementation).
3. **Storage Estimation:** Uses empirical average RAW file size (`averageRawFileSizeMB`) rather than theoretical bit-depth math for storage estimations, which is more accurate for compressed raw files. (Implemented in recent git commits).
4. **Relative Stacking Gain:** Presented as a statistical efficiency metric (`sqrt(N)`), explicitly avoiding claims of "true absolute SNR". (Inferred from constraints and `OpticalCalculator.calculateRelativeStackingGain`).

## Architecture & Tech Stack
1. **Framework:** Flutter / Dart.
2. **State Management:** MVVM using `Provider` + `ChangeNotifier`.
3. **Database:** SQLite using `Drift` for robust typing.
4. **Offline First:** Local DB holds equipment, targets, logs, and locations. External APIs (Weather, Light Pollution) use caching or are non-blocking.
5. **Weather API:** Open-Meteo (No API Key required).
6. **Geocoding:** Nominatim / OpenStreetMap (No API Key required).

## Domain Logic
1. **Astronomy Engine:** Calculates Julian dates, GMST, LST, and Altitude natively in Dart, maintaining scientific accuracy without heavy third-party dependencies.
2. **Time Handling:** UTC is used internally for all astronomical calculations, while the UI converts to Local time.
3. **Minimum Altitude:** Configurable minimum altitude (default 20°) is used for visibility windows.
