# AstroPlan Feature Status

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
| F-07 | Saved locations management | Partial | 4 |
| F-08 | Session date selection (picker) | Partial | 8 |
| F-09 | Default "tonight" resolution | Implemented *(fixed TASK 2.4)* | 8 |
| F-10 | Site time-zone handling | Partial | 8 |
| F-11 | Astronomy core (JD, GMST, LST, altitude) | Implemented | 5 |
| F-12 | Sun altitude and night timeline | Partial | 8 |
| F-13 | Target visibility windows | Partial | 8 |
| F-14 | Altitude chart | Implemented | 8 |
| F-15 | Lunar illumination | Partial | 8 |
| F-16 | Moon position, rise/set, Moon–target separation | Missing | 8 |
| F-17 | Horizon / obstruction model | Missing | 8 |
| F-18 | Sky-darkness warning | Prototype | 11 |
| F-19 | Target selection, search, custom target CRUD | Implemented | 7 |
| F-20 | Curated target catalog with provenance | Prototype | 7 |
| F-21 | Moving-object targets | Missing | 7 |
| F-22 | Equipment profile CRUD | Implemented | 6 |
| F-23 | Equipment composition (Device / Camera / Rig) | Partial | 4 |
| F-24 | Pixel scale | Implemented | 6 |
| F-25 | Field of view (FOV) | Partial | 6 |
| F-26 | NPF exposure recommendation | **Broken** | 6 |
| F-27 | Optical multipliers (reducer / Barlow) | Prototype | 6 |
| F-28 | Storage estimate | Partial | 9 |
| F-29 | Weather fetch and offline cache | Partial | 10 |
| F-30 | Weather forecast display | Partial | 10 |
| F-31 | Dew warning | Prototype | 10 |
| F-32 | Light-pollution auto-fetch (Bortle) | **Broken** | 11 (ahead) |
| F-33 | Manual Bortle entry | Prototype | 11 (ahead) |
| F-34 | External light-pollution map handoff | **Broken** | 11 (ahead) |
| F-35 | Capture plan editor (blocks) | Partial | 9 |
| F-36 | Session duration and feasibility | Partial | 9 |
| F-37 | Integration time and relative stacking gain | Partial | 9 |
| F-38 | Imaging Opportunity | Missing | 8–10 |
| F-39 | Calibration-frame planning | Missing | 9 |
| F-40 | Save session (planned) | Partial | 13 (ahead) |
| F-41 | Logbook list / reload / delete / share | Partial | 13 (ahead) |
| F-42 | Planned-versus-actual logging | Partial | 13 (ahead) |
| F-43 | Session execution mode | Missing | 13, 15 |
| F-44 | Export / interoperability manifest | Prototype | 14 (ahead) |
| F-45 | Metadata import (EXIF / FITS) | Prototype | 12 (ahead) |
| F-46 | Field mode | Prototype | 15 (ahead) |
| F-47 | Custom dashboard | Missing | not in roadmap |
| F-48 | Automated tests | Partial | 1, 16 |
| F-49 | CI / build automation | Missing | 1, 16 |
| F-50 | Platform support | Partial | 1, 16 |

Counts (50 features): Implemented 8 · Partial 21 · Prototype 8 · Broken 4 ·
Missing 9 · Deprecated 0 · Unknown 0. (The orphaned `equipment_profiles` table
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
- **Status:** Partial
- **Current implementation:** schema v10, 7 tables, repositories with in-memory-DB tests. **TASK 3.2:** the v1–v7 raw-SQL steps are gone; every upgrade is behind a floor guard and a downgrade guard, runs inside a transaction, and is checked against Drift schema snapshots (`drift_schemas/`) with a generated-verification migration test suite (`test/data/database/schema_migration_test.dart`). **TASK 3.3:** foreign keys are enforced on every connection; the v9 → v10 step cleans up pre-existing orphans, rebuilds `camera_modules`/`optical_rigs`/`capture_blocks` with real `ON DELETE` actions, and drops `equipment_profiles`.
- **Relevant files:** `lib/data/database/*`, `lib/data/database/generated_migrations/*`, `drift_schemas/`, `build.yaml`, `lib/data/repositories/drift_*`.
- **Known issues:** the below-floor reset path exists (`resetUnsupportedDatabaseFile`) but nothing calls it — no bootstrap confirmation UI; a real downgrade just throws with no UI handling it either (TD-047's remaining half). *Resolved (TASK 3.2):* v3 → v9 throwing (TD-004); no migration tests or schema snapshots; the unguarded schema downgrade (TD-047, app-database half). *Resolved (TASK 3.3):* foreign keys not enforced (TD-005); orphaned `equipment_profiles`; upgraded databases keeping legacy columns (`optical_multiplier` ×2, `bit_depth`) that fresh installs lacked — the v10 migration rebuilds the affected tables and drops the orphan (DEV-D1, DEV-D6).
- **Dependencies:** drift, sqlite3, `sqlite3_flutter_libs` (`0.6.0+eol`), path_provider.
- **Roadmap relevance:** Phase 4; Phase 16 (migration testing). ~~Decision PD-04~~ (resolved, ADR-008).

## F-03 — Preference persistence (active plan, selections, thresholds)
- **Status:** Implemented
- **Current implementation:** shared-preferences keys `captureBlocks`, `targetId`, `equipmentId`, `activeLocationId`, `minAltitude`, `dewPointThreshold` (see `docs/DATA_MODEL.md` B6).
- **Relevant files:** `lib/presentation/viewmodels/planner_viewmodel.dart`.
- **Known issues:** persistence code lives in the ViewModel (DEV-A1); `minAltitude` is read without clamping; capture plan is hand-serialized JSON. *Resolved (TASK 4.2):* the deleted selected target/equipment used to stay selected until restart — `refreshSelectedTarget`/`refreshSelectedEquipment` now clear it live, called from the target/equipment screens after an edit or delete (TD-028).
- **Dependencies:** shared_preferences.
- **Roadmap relevance:** Phase 2/4.

## F-04 — Feature gating (`FeatureScope`)
- **Status:** Implemented *(TASK 4.3)*
- **Current implementation:** four flags, all read from the one source and matching PD-06 E.1 exactly: `fieldMode`/`lightPollutionContext`/`metadataImport` are `false` (hidden), `logbook` is `true` (stays visible). Every entry point reads it — the field-mode toggle and Import Metadata buttons and the light-pollution map card in `home_screen.dart` (previously ungated), the Bortle badge in `sky_darkness_widget.dart`, and route registration in `app_router.dart`.
- **Relevant files:** `lib/core/config/feature_scope.dart`, `app_router.dart`, `sky_darkness_widget.dart`, `home_screen.dart`.
- **Known issues:** none open. *Resolved (TASK 4.3):* `fieldMode` was never read; the map handoff was ungated; Home's buttons pushed gated routes unconditionally; `metadataImport` was `true` with no recorded approval (DEV-P1; TD-014).
- **Dependencies:** decision PD-06 (resolved 2026-09-21: `DECISIONS.md` E.1); enforced by roadmap TASK 4.3, with a test that a gated feature has no entry point (`feature_scope_test.dart`, `app_router_test.dart`, `home_screen_test.dart`).
- **Roadmap relevance:** governance (ADR-006).

## F-05 — Seed data and first-run bootstrap
- **Status:** Partial *(bootstrap ordering fixed TASK 1.2)*
- **Current implementation:** `main.dart` now awaits `CatalogSeeder` (5 targets) and `EquipmentSeeder` (5 profiles) before `runApp`, so the ViewModel's first read always sees seeded data (`2357755` established the seam; the ordering fix itself is a later TASK 1.2 commit — recorded here). Home's empty state (target/equipment still null, e.g. a seeding failure) now offers "Choose a Target" / "Choose Equipment" actions instead of a dead end.
- **Relevant files:** `lib/main.dart`, `lib/data/services/*.dart`, `planner_viewmodel.dart:81-172`, `home_screen.dart` (`_EmptyStateView`).
- **Known issues:** seeders re-seed if the user deletes everything; seed data errors (SI-005, SI-011); no `averageRawFileSizeMB` in any seed (TD-008, TD-035). *Resolved (TASK 1.2):* the DB-before-seeding race (TD-002) and the Home dead-end.
- **Dependencies:** F-02, F-19, F-22.
- **Roadmap relevance:** Phases 4, 7.

# Site, time and astronomy

## F-06 — Active location (GPS, map picker, reverse geocoding)
- **Status:** Partial
- **Current implementation:** `useCurrentLocation` (through the injected `LocationService`, implemented by `GeolocatorLocationService`; *updated TASK 1.1*), a `flutter_map` picker with a marker and "Current Location" button, Nominatim reverse geocoding for a place name; defaults to London until a location is set.
- **Relevant files:** `planner_viewmodel.dart:163-280`, `lib/presentation/screens/location/location_picker_screen.dart`.
- **Known issues:** unhandled platform-location exceptions on the startup path (`unawaited`, no `try/catch`); silent London default; geocoding failures swallowed; Geolocator flow duplicated in the picker; `setLocation` overwrites the active saved profile; OSM tiles shown without attribution and with a mismatched user-agent; not run on a device in this audit (TD-002, TD-027, TD-031).
- **Dependencies:** geolocator, flutter_map, latlong2, http, network.
- **Roadmap relevance:** Phase 8 (location + visibility).

## F-07 — Saved locations management
- **Status:** Partial
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
- **Known issues:** simplifications undocumented (no precession, refraction; UTC ≈ UT1) (SI-009; TD-036); a stray escaped apostrophe in a comment (`astronomical_engine.dart:38`).
- **Dependencies:** none (pure Dart).
- **Roadmap relevance:** Phase 5. Tests: J2000 JD/GMST, LST, culmination altitude.

## F-12 — Sun altitude and night timeline
- **Status:** Partial
- **Current implementation:** low-precision Sun altitude; sunset, civil/nautical/astronomical dusk and dawn, sunrise on a 5-minute scan. **New (TASK 2.3):** a `SessionNight`-based `calculateNightTimelineForNight` returns a typed `NightTimeline` (`SunCrossing`/`SunNeverBelow`/`SunAlwaysBelow` per threshold, never a bare null); the old `Map<String, DateTime?>`-returning `calculateNightTimeline` is now a thin wrapper over it. UI (`sky_darkness_widget.dart`) still shows sunset, astro dusk/dawn, sunrise and a "True Night Window" from the old wrapper, unchanged.
- **Relevant files:** `visibility_calculator.dart`, `lib/domain/models/night_timeline.dart`, `lib/presentation/widgets/sky_darkness_widget.dart`.
- **Known issues:** 5-minute quantization (TD-036); the gradient bar is decorative and unrelated to the data. *Resolved (TASK 2.3):* the stale "refine to 1-minute" comment is gone with the scan loop it was attached to (TD-024). *Resolved (TASK 2.4):* wrong night by default (F-09); `sky_darkness_widget.dart` now consumes the typed `NightTimeline?` directly (sealed-class pattern matching, `null` when there is no site) instead of the deprecated `Map<String, DateTime?>` wrapper; times are labelled with the device zone via `NightTimeFormatter` instead of printed bare.
- **Dependencies:** F-11, F-09.
- **Roadmap relevance:** Phase 8.

## F-13 — Target visibility windows
- **Status:** Partial
- **Current implementation:** windows where the Sun is below −18° (configurable) and the target is above a minimum altitude (default 20°); feeds feasibility. Handles multiple segments and high latitudes. **New (TASK 2.3):** a `SessionNight`-based `calculateVisibilityWindowsForNight`, sharing the 5-minute grid with the timeline and the altitude curve; a window touching the SessionNight boundary in polar night is flagged `clippedAtStart`/`clippedAtEnd` (ADR-007 §9, verified for both the new API and the legacy wrapper). The old `calculateVisibilityWindows` is now a thin wrapper over it.
- **Relevant files:** `visibility_calculator.dart`, `lib/domain/models/visibility_window.dart`, `planner_viewmodel.dart:419-428`.
- **Known issues:** no Moon, weather or horizon; 5-minute quantization; J2000 coordinates; the minimum altitude and Sun limit have no UI control; "culmination" is only max altitude at LHA = 0, not a culmination time and not restricted to the night (SI-006, SI-009). *Resolved (TASK 2.4):* wrong night by default (F-09) — `PlannerViewModel.visibilityWindows` now resolves a real `SessionNight` and returns `[]` without a site instead of silently using default London coordinates (SI-008).
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
- **Status:** Partial
- **Current implementation:** mean-synodic-month model; shown as `Moon Illumination: NN.N%`, or `--` when there is no site; feeds the sky warning.
- **Relevant files:** `visibility_calculator.dart:70-81`, `sky_darkness_widget.dart:15`, `planner_viewmodel.dart` (`lunarIllumination` getter).
- **Known issues:** error up to 4.7 percentage points vs USNO 2025; displayed to 0.1 %; evaluated at one instant, not the imaging window (SI-002; TD-032). **TASK 2.4:** `lunarIllumination` is now `double?`, evaluated at `sessionNight.startUtc + 12h` (mean solar midnight — ADR-007 §9's candidate instant) and `null` without a site; the canonical evaluation instant for night-level scalars is not yet formally decided (G6) — see `docs/SCIENTIFIC_INTEGRITY.md`.
- **Dependencies:** F-09 for the evaluation instant (resolved: now always the current `SessionNight`'s window, pending G6's final instant choice).
- **Roadmap relevance:** Phase 8. Tests: 3 coarse tests (pure calculator) plus ViewModel null-without-site coverage.

## F-16 — Moon position, rise/set, Moon–target separation
- **Status:** Missing
- **Current implementation:** none.
- **Relevant files:** —
- **Known issues:** required by the PRODUCT_SPEC MVP; the sky warning ignores whether the Moon is up (SI-002).
- **Dependencies:** decision PD-07.
- **Roadmap relevance:** Phase 8.

## F-17 — Horizon / obstruction model
- **Status:** Missing
- **Current implementation:** a single flat minimum altitude.
- **Relevant files:** —
- **Known issues:** trees, buildings and terrain are not modelled (documented limitation).
- **Dependencies:** F-13.
- **Roadmap relevance:** Phase 8 (optional).

## F-18 — Sky-darkness warning
- **Status:** Prototype
- **Current implementation:** an orange card on Home when Moon illumination > 0.8 or Bortle ≥ 7.
- **Relevant files:** `planner_viewmodel.dart:434-436`, `home_screen.dart:147-166`.
- **Known issues:** hard-coded thresholds; ignores Moon altitude and target; the Bortle half is unreachable (F-32, F-33); message asserts targets "will wash out" (SI-006; TD-033).
- **Dependencies:** F-15, F-33.
- **Roadmap relevance:** Phase 11 (ahead of phase).

# Targets

## F-19 — Target selection, search, custom target CRUD
- **Status:** Implemented
- **Current implementation:** searchable list (`LIKE`), add/edit/delete with validation (RA 0–360°, Dec ±90°), selection stored in preferences.
- **Relevant files:** `lib/presentation/screens/target/target_selection_screen.dart`, `lib/data/repositories/drift_target_repository.dart`.
- **Known issues:** editing overwrites `catalogId` with the name; RA entered in degrees; no uniqueness; calls the repository directly (DEV-A2); `LIKE` wildcards not escaped (TD-016, TD-021). *Resolved (TASK 4.2):* stale selection after deleting or editing the selected target — the screen now calls `PlannerViewModel.refreshSelectedTarget()` after its dialog closes and after a swipe-delete (TD-028).
- **Dependencies:** F-02.
- **Roadmap relevance:** Phase 7. Tests: 5 form-validation widget tests, 1 repository test.

## F-20 — Curated target catalog with provenance
- **Status:** Prototype
- **Current implementation:** 5 seeded objects (M31, M42, M45, M33, M8).
- **Relevant files:** `lib/data/services/catalog_seeder.dart`.
- **Known issues:** no provenance, epoch, magnitude, size or constellation; too small to be useful (SI-012; TD-016).
- **Dependencies:** decision PD-09.
- **Roadmap relevance:** Phase 7.

## F-21 — Moving-object targets
- **Status:** Missing
- **Current implementation:** none, yet the type list offers Planet, Moon, Comet, Asteroid.
- **Relevant files:** `target_selection_screen.dart:9-20`.
- **Known issues:** such targets would be modelled as fixed coordinates and silently mis-plotted (SI-012).
- **Dependencies:** decisions PD-07, PD-16.
- **Roadmap relevance:** Phase 7 (out of MVP scope for now).

# Equipment and optics

## F-22 — Equipment profile CRUD
- **Status:** Implemented
- **Current implementation:** list, add, edit, delete (with confirmation), selection; form validates required numeric fields; sensor size is auto-derived from resolution × pixel pitch.
- **Relevant files:** `lib/presentation/screens/equipment/equipment_selection_screen.dart`, `lib/data/repositories/drift_equipment_repository.dart`.
- **Known issues:** RAW size accepts negatives; seeded data errors (SI-005, SI-011); repository called directly (DEV-A2). *Resolved (TASK 4.2):* deleting or editing the selected rig used to leave a stale selection — the screen now calls `PlannerViewModel.refreshSelectedEquipment()` after its dialog closes and after a swipe-delete (TD-028). *Resolved (TASK 4.3):* mojibake in strings (`Вµm`, `В°`, box-drawing comments), now correct (`µm`, `°`) and checked by `tool/check_encoding.dart` (TD-015).
- **Dependencies:** F-02, F-23.
- **Roadmap relevance:** Phase 6. Tests: 4 form-validation widget tests, 1 encoding test, 2 repository tests.

## F-23 — Equipment composition (Device / Camera module / Optical rig)
- **Status:** Partial
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
- **Status:** Partial
- **Current implementation:** `2·atan(d/2f)` implemented and unit-tested.
- **Relevant files:** `optical_calculator.dart:30-37`.
- **Known issues:** **never used or displayed** anywhere in the app; no target-size or framing comparison (targets have no size) (TD-016).
- **Dependencies:** F-22, F-20.
- **Roadmap relevance:** Phase 6.

## F-26 — NPF exposure recommendation
- **Status:** Broken
- **Current implementation:** `calculateNPFExposure` and a ViewModel getter `npfExposure`; **no UI consumer**.
- **Relevant files:** `optical_calculator.dart:59-88`, `planner_viewmodel.dart:461-469`.
- **Known issues:** formula uses a constant `90.0` instead of `0.1·F` (2.9× too long for phones, 0.72× for 2000 mm); circular unit test; no K factor; not labelled as a recommendation; throws on invalid input (SI-001; TD-007).
- **Dependencies:** decisions PD-10, PD-11.
- **Roadmap relevance:** Phase 6 ("later NPF recommendations").

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
- **Status:** Partial
- **Current implementation:** Open-Meteo forecast (`icon_seamless`, 48 hourly entries, current values); cached in shared preferences per ~1.1 km cell; falls back to cache on any failure.
- **Relevant files:** `lib/data/repositories/open_meteo_weather_repository.dart`, `lib/domain/models/weather_conditions.dart`.
- **Known issues:** not date-aware (always "now"); arrays start at local midnight; timestamps naive; offset discarded; cache has no staleness limit or indicator; parser assumes non-null arrays (worked for the live London query); no provenance; startup awaits it (DEV-A5); errors silent (TD-017, TD-029).
- **Dependencies:** http, shared_preferences; decisions PD-02, PD-15.
- **Roadmap relevance:** Phase 10 ("without breaking offline"). Tests: 3 repository tests with a mocked client.

## F-30 — Weather forecast display
- **Status:** Partial
- **Current implementation:** summary (temperature, cloud, wind) and a horizontal 48-hour strip (cloud, temperature, precipitation probability, humidity, wind).
- **Relevant files:** `lib/presentation/widgets/weather_forecast_widget.dart`.
- **Known issues:** strip begins at local midnight, not "now" or the imaging night; no highlight or summary of the dark window; dew point not shown; colour bands hard-coded (SI-006); no widget test.
- **Dependencies:** F-29.
- **Roadmap relevance:** Phase 10.

## F-31 — Dew warning
- **Status:** Prototype
- **Current implementation:** `dewWarning` getter (temperature − dew point ≤ threshold, default 2.0 °C) and a persisted threshold.
- **Relevant files:** `planner_viewmodel.dart:366-371,438-441`.
- **Known issues:** **never displayed**; no UI to change the threshold; uses current weather, not the forecast for the session (SI-006).
- **Dependencies:** F-29.
- **Roadmap relevance:** Phase 10.

## F-32 — Light-pollution auto-fetch (Bortle)
- **Status:** Broken
- **Current implementation:** `LightPollutionRepository.fetchBortleClass` scrapes ClearOutside with a regex.
- **Relevant files:** `lib/data/repositories/light_pollution_repository.dart`.
- **Known issues:** the URL is never interpolated (`\${…}`), so it can never succeed; scraping a third-party site; not injectable, no interface, no tests; still invoked on every location change (SI-007; TD-006).
- **Dependencies:** decision PD-05.
- **Roadmap relevance:** Phase 11 (ahead of phase).

## F-33 — Manual Bortle entry
- **Status:** Prototype
- **Current implementation:** a `Bortle 1–9` dropdown badge in the sky card, persisted to the active location.
- **Relevant files:** `sky_darkness_widget.dart:32-40,65-126`, `planner_viewmodel.dart:344-364`.
- **Known issues:** hidden by `FeatureScope.lightPollutionContext = false`, so **no user path sets Bortle**; default 4 and no "unknown" state (SI-007).
- **Dependencies:** F-04, decision PD-05.
- **Roadmap relevance:** Phase 11.

## F-34 — External light-pollution map handoff
- **Status:** Broken
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
- **Known issues:** binning and gain/ISO not exposed in the UI (fields exist on the model, default to 1/null). *Resolved (TASK 4.1):* dragging a block **down** used to under-move by one (`newIndex -= 1` applied on top of `onReorderItem`'s own adjustment, TD-010); invalid or empty input used to silently become 60 s × 30 with negatives accepted, and there was no edit UI (TD-012, partially — binning/gain exposure was out of this task's scope). *Resolved (TASK 4.4):* the default plan used to be shown with no distinction from the user's own plan (SI-008; TD-013).
- **Dependencies:** F-03.
- **Roadmap relevance:** Phase 9 (central component).

## F-36 — Session duration and feasibility
- **Status:** Partial
- **Current implementation:** `estimatedRequiredTime` (all frames' exposure + 5 s per frame) compared with the summed visibility windows by `SessionCalculator.calculateFeasibility` → Feasible / Tight (> 85 %) / Infeasible.
- **Relevant files:** `planner_viewmodel.dart:478-491`, `lib/domain/services/session_calculator.dart:51-80`.
- **Known issues:** conflates integration, acquisition, calibration and total budget; compares calibration-frame time with the night window; wrong night by default (F-09); no Moon/weather; the live math has **no tests** while the dead `estimateTotalDuration` does (DEV-A4; TD-022, TD-025).
- **Dependencies:** F-13; decision PD-08.
- **Roadmap relevance:** Phase 9.

## F-37 — Integration time and relative stacking gain
- **Status:** Partial
- **Current implementation:** integration time = Σ light exposure × count; relative gain = √(light frames), shown as `10.0x` labeled "Relative stacking gain (√N vs one frame)" (TASK 4.4).
- **Relevant files:** `planner_viewmodel.dart:471-476,502-504`, `optical_calculator.dart:44-47`, `capture_plan_widget.dart:206-218`.
- **Known issues:** gain ignores sub-exposure length (100×60 s ≠ 20×300 s in the display though both are 6000 s) (SI-003). *Resolved (TASK 4.4):* the UI label used to say "Relative SNR" (ADR-005 deviation; TD-009).
- **Dependencies:** F-35.
- **Roadmap relevance:** Phase 9.

## F-38 — Imaging Opportunity
- **Status:** Missing
- **Current implementation:** none; the nearest equivalent is the darkness ∩ altitude window list (F-13).
- **Relevant files:** —
- **Known issues:** the central product concept (darkness, visibility, Moon and weather combined) does not exist; it must be a transparent model, not a black-box score.
- **Dependencies:** F-09, F-10, F-13, F-15, F-16, F-29.
- **Roadmap relevance:** Phases 8–10.

## F-39 — Calibration-frame planning
- **Status:** Missing
- **Current implementation:** dark/flat/bias blocks can be listed, but nothing schedules or relates them to the lights.
- **Relevant files:** `capture_block.dart`, `capture_plan_widget.dart`.
- **Known issues:** calibration time is counted against the night window (F-36).
- **Dependencies:** decision PD-08.
- **Roadmap relevance:** Phase 9.

# Session and logbook

## F-40 — Save session (planned)
- **Status:** Partial
- **Current implementation:** a "Save Session" button writes target name, equipment name, date, planned light frames and blocks; updates instead if a session was loaded or already saved this session (**TASK 4.2:** `addLog` now returns the new id and `PlannerViewModel.markSessionSaved` records it, so a second tap updates instead of duplicating).
- **Relevant files:** `home_screen.dart`, `lib/data/repositories/drift_logbook_repository.dart`, `lib/presentation/viewmodels/planner_viewmodel.dart` (`markSessionSaved`).
- **Known issues:** location, Bortle, weather, focal length, aperture, integration time and planned calibration counts stay null (verified); the widget calls the repository directly (DEV-A2, DEV-D3). *Resolved (TASK 4.2):* tapping twice used to insert two rows (TD-011).
- **Dependencies:** F-35, F-41.
- **Roadmap relevance:** Phase 13 (ahead of phase).

## F-41 — Logbook list / reload / delete / share
- **Status:** Partial
- **Current implementation:** list of sessions, newest-saved first (**TASK 4.2**); tap reloads a session into the planner; swipe deletes with a confirmation dialog (**TASK 4.2**, matching the equipment/target screens' pattern); share sends `toShareableText()`.
- **Relevant files:** `lib/presentation/screens/logbook/logbook_screen.dart`, `session_log.dart`.
- **Known issues:** no undo after delete; reload re-matches target/equipment **by name**; the loaded date becomes a local `DateTime`. *Resolved (TASK 4.2):* unordered (oldest first); swipe-delete had no confirmation; no widget test (TD-039).
- **Dependencies:** F-40; gate `FeatureScope.logbook`.
- **Roadmap relevance:** Phase 13 (ahead of phase).

## F-42 — Planned-versus-actual logging
- **Status:** Partial
- **Current implementation:** the model and database hold `actualLightFrames`, `rejectedFrames`, environmental and processing notes; the list displays them when set.
- **Relevant files:** `session_log.dart`, `drift_logbook_repository.dart`, `logbook_screen.dart:86-91`.
- **Known issues:** **no UI anywhere sets them**, so the values are always null.
- **Dependencies:** F-41.
- **Roadmap relevance:** Phase 13.

## F-43 — Session execution mode
- **Status:** Missing
- **Current implementation:** none.
- **Relevant files:** —
- **Known issues:** the "Execution" step of the product workflow does not exist (hardware control is out of scope).
- **Dependencies:** F-42.
- **Roadmap relevance:** Phases 13, 15.

## F-44 — Export / interoperability manifest
- **Status:** Prototype
- **Current implementation:** `SessionLog.toJson()` / `fromJson()` (manifest v1) with tests; text sharing is live (F-41).
- **Relevant files:** `lib/domain/models/session_log.dart`, `test/domain/models/session_log_test.dart`.
- **Known issues:** JSON path is used only by tests; manifest lacks coordinates and time zone; no import UI; `cloud_cover_percent` cast fails on a non-integer JSON number.
- **Dependencies:** F-42.
- **Roadmap relevance:** Phase 14 (ahead of phase).

## F-45 — Metadata import (EXIF / FITS)
- **Status:** Prototype
- **Current implementation:** gallery picker → `MetadataExtractor` → read-only cards and a raw tag list.
- **Relevant files:** `lib/presentation/screens/metadata/metadata_import_screen.dart`, `lib/domain/services/metadata_extractor.dart`.
- **Known issues:** `image_picker` gallery cannot select FITS, so FITS is unreachable on a device; reads whole files into memory; FITS `/` inside string values truncates them; nothing is stored or connected to sessions or equipment; **no real sample files exist**, which the ROADMAP requires before this phase; only synthetic-input unit tests (TD-018).
- **Dependencies:** image_picker, exif; gate `FeatureScope.metadataImport`.
- **Roadmap relevance:** Phase 12 (ahead of phase).

## F-46 — Field mode
- **Status:** Prototype, now hidden *(TASK 4.3)*
- **Current implementation:** an app-bar toggle switches to `AppTheme.fieldTheme` (in-memory). **TASK 4.3:** the toggle button is gated behind `FeatureScope.fieldMode` (hidden until TASK 12.4), so it has no entry point at all — the underlying `ThemeViewModel`/`AppTheme` code is unchanged and unreachable rather than removed.
- **Relevant files:** `theme_viewmodel.dart`, `main.dart`, `home_screen.dart`, `lib/core/config/feature_scope.dart`.
- **Known issues:** not persisted; no checklist or other field utilities (DEV-P1). *Resolved (TASK 4.3):* ungated despite ADR-006 (TD-014).
- **Dependencies:** decision PD-06 (resolved 2026-09-21: `DECISIONS.md` E.1); enforced by roadmap TASK 4.3.
- **Roadmap relevance:** Phase 15 (ahead of phase).

## F-47 — Custom dashboard
- **Status:** Missing
- **Current implementation:** none; the Home screen is a fixed vertical list of cards.
- **Relevant files:** `home_screen.dart`.
- **Known issues:** listed as a next step by the previous audit but **absent from PRODUCT_SPEC and ROADMAP** (PD-14).
- **Dependencies:** decision PD-14.
- **Roadmap relevance:** not in the roadmap.

# Quality and platform

## F-48 — Automated tests
- **Status:** Partial
- **Current implementation:** 147 tests in 29 files; all pass, three consecutive full runs (`dart run tool/check.dart` after TASK 2.3; 135 in 27 files after TASK 2.2, 83 in 24 files after TASK 1.2). New (TASK 2.3): `visibility_calculator_session_night_test.dart` (9 tests: the ADR-007 polar cases, exact agreement between the new SessionNight-based API and the legacy wrappers, clip-flag behavior in both) and `altitude_chart_widget_test.dart` (3 tests, the chart's first widget test: a normal night, a polar-night site, a date far from "now"). New (TASK 2.2): `session_night_resolver_test.dart` (the ADR-007 matrix and invariants), `calendar_date_test.dart`, `clock_test.dart` (which includes a guard that `lib/domain` has no `DateTime.now()`), plus one `SessionLog.fromJson` clock-fallback test. Earlier: `flutter analyze` clean. Location is injected (`FakeLocationService` in `test/support/`) and the ViewModel is awaited with `vm.ready`. New (TASK 1.2): `planner_bootstrap_test.dart` (seeding-before-first-read, bootstrap-failure/retry, `isDefaultLocation`) and `home_screen_test.dart` (empty-state actions, default-location banner, weather-failure/retry, bootstrap-failure/retry), using a `FlakyTargetRepository` test double (`test/support/`).
- **Relevant files:** `test/` (see `docs/TEST_PLAN.md`).
- **Known issues:** no test for the live capture-budget math, Capture Plan, Sky, Logbook, Location or Metadata screens; no migration tests; some tests mirror the implementation (NPF); `AppRouter.router` is a shared static — `home_screen_test.dart` resets it in `setUp()` to avoid cross-test navigation leaks, a workaround, not a fix; Nominatim and light-pollution HTTP are not injectable (TD-025, TD-037). *Resolved 2026-09-21 (TASK 1.1, `2357755`):* the red `integration_flow_test.dart` (TD-003), the 300 ms sleeps, and GPS access in tests. *Resolved 2026-09-22 (TASK 2.3):* no widget test for the altitude chart.
- **Dependencies:** —
- **Roadmap relevance:** Phases 1, 16.

## F-49 — CI / build automation
- **Status:** Partial *(was Missing; TASK 1.3, commit `97924a0`)*
- **Current implementation:** `tool/check.dart` (`dart run tool/check.dart`) runs `dart format --set-exit-if-changed`, `flutter analyze --no-pub` and `flutter test --no-pub` — all three regardless of an earlier failure, then a pass/fail summary, exiting non-zero on any failure. `.github/workflows/ci.yml` runs it on push to `main` and on pull requests.
- **Relevant files:** `tool/check.dart`, `.github/workflows/ci.yml`.
- **Known issues:** no Git remote is configured, so the workflow has never actually run (untested in the real GitHub Actions environment); stricter lints (TD-038) and device tests remain out of scope by design.
- **Dependencies:** —
- **Roadmap relevance:** Phases 1, 16.

## F-50 — Platform support
- **Status:** Partial
- **Current implementation:** Android is configured (`com.astroplan.astroplan`, location and internet permissions, Java 17); iOS, web, Windows, Linux and macOS folders are Flutter scaffolds.
- **Relevant files:** `android/`, `ios/`, `pubspec.yaml`.
- **Known issues:** no Android build or device run was performed in this audit (Unknown); release signing uses the debug key; iOS `Info.plist` lacks location and photo usage strings; `dart:io` file access makes the web target unsupported; `sdk: ^3.13.3` is a very tight Dart constraint (TD-031).
- **Dependencies:** —
- **Roadmap relevance:** Phases 1, 16 (ADR-001: Android first).
