# Project Handoff: AstroPlan

> **Read this first.** It is the entry point for any new agent or developer.
> **Verification stamp:** verified against code at commit `900b82a` (2026-09-20),
> audited and documented 2026-09-21. Application code changed since by TASK 1.1
> (commit `2357755`: `LocationService` seam, `PlannerViewModel.ready`, test harness)
> and TASK 1.2 (deterministic bootstrap: seeding awaited before `runApp`, weather off
> the startup path, `hasBootstrapError`/`retryBootstrap`, Home empty/error states).
> Work now follows `docs/MASTER_ROADMAP.md`; the current position is the "active
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

## 0. Start here (10-minute orientation)

1. Read this file, then `ARCHITECTURE.md` (Parts B–C), `FEATURE_STATUS.md`
   (summary table) and `TECH_DEBT.md` (Critical and High).
2. Baseline to expect: `flutter analyze` → no issues; `flutter test` → **83 pass,
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
for what remains open).)*

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

83 tests in 24 files: domain services (astronomy, optics, session feasibility,
visibility windows, metadata parsing, session log), Drift repositories and database,
the Open-Meteo repository (mocked client), form-validation widget tests for the
Equipment and Target screens, four ViewModel suites (session date, minimum altitude,
location, bootstrap), an app-boot widget test, one end-to-end flow, and a Home
widget-test suite (empty state, default-location banner, weather failure, bootstrap
failure). *(At the audit, 71 tests in 21 files, 1,757 lines; TASK 1.1 added the
location suite; TASK 1.2 added the bootstrap and Home suites.)*

- **Result:** 83 pass, 0 fail (three consecutive full runs after TASK 1.2). The
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
| Test | `flutter test --no-pub` | **Yes** — 83/83 (after TASK 1.2; was 70/71 at the audit) |
| Regenerate Drift code after changing tables | `dart run build_runner build --delete-conflicting-outputs` | **No** (standard `drift_dev` step; not run) |
| Run on Android | `flutter run` | **No** — no device/emulator run in the audit |
| Release build | `flutter build apk` | **No** — release signing currently uses the debug key |

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
- **Build/release:** release builds are signed with the debug key; no obfuscation.
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
| `docs/PRODUCT_SPEC.md`, `ROADMAP.md`, `TEST_PLAN.md` | Product intent, phases, test strategy (intent + baseline) |
| `.agents/rules/` | Governance, architecture, quality, testing, scientific, UI rules |
| `docs/archive/2026-09-21-previous-agent-audit/` | Superseded documents (historical only) |
