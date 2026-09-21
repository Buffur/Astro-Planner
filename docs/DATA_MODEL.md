# AstroPlan Data Model

> **Verification stamp:** verified against code at commit `900b82a` (2026-09-20),
> audited 2026-09-21. Application code unchanged since.
>
> This document keeps **three things separate** on purpose:
> - **Part A — Design intent** (approved Phase 0 baseline, preserved verbatim).
> - **Part B — CURRENT ENTITIES** (what actually exists in code, verified).
> - **Part C — REQUIRED FUTURE DOMAIN CONCEPTS** (do **not** create in code
>   without a design review and owner approval).
>
> Status vocabulary: **Intended / Planned**, **Actual / Implemented**, **Partial**,
> **Broken**, **Missing**, **Deprecated**, **Unknown**.
> Where the implementation deviates from the approved design it is marked
> **IMPLEMENTATION DEVIATION** (intended behavior / actual behavior / consequence).

---

# Part A — Design intent (Phase 0 baseline, preserved verbatim)

*Source: `git show 900b82a:docs/DATA_MODEL.md`. Status of each item in this part:
see Part B and the deviation blocks.*

## Database Choice

AstroPlan uses SQLite via Drift. Schema changes must be additive or explicitly
migrated, with migration tests for non-trivial changes.

## Intended Phase 4 Foundation

The foundational schema should model these concepts first:

- Device
- CameraModule
- OpticalRig
- Target
- Location

Session entities should be introduced after these are stable.

## Conceptual Relationships

```text
Device
  -> CameraModule
  -> OpticalRig
       -> SessionPlan
            -> Target
            -> Location
            -> CaptureBlock[]
                 -> ExecutedSession
                      -> ProcessingLog
```

## Current Implementation Snapshot

*(Historical — this is the snapshot as written at Phase 0. It is superseded by
Part B; the original wording below is kept unchanged.)*

Current Drift tables:

- `EquipmentProfiles`
- `LocationProfiles`
- `AstroTargets`
- `SessionLogs`

Current issue: `EquipmentProfiles` flattens device, camera module, and optics
into one table. This is convenient for a prototype but weaker than the planned
Phase 4 structure.

Current issue: `SessionLogs` stores target and equipment as display strings
rather than stable relationships. This should be revisited when session planning
and logbook schema are formally approved.

Current issue: active planner location is persisted through shared preferences
rather than the `LocationProfiles` table.

> **Status of those three Phase 0 issues on 2026-09-21:**
> 1. Flat equipment table — **Partial**: normalized tables now exist and are used
>    (see DEV-D2), but the domain/UI model is still flat and the flat table is
>    orphaned.
> 2. Display strings instead of relationships — **Still open** (DEV-D3).
> 3. Active location in shared preferences — **Partially resolved**: coordinates
>    live in `location_profiles`; the *pointer* to the active row and several
>    other selections remain in shared preferences (DEV-D4).

## Migration Rules

- Do not delete or recreate tables casually.
- Inspect current schema before changing it.
- Add migrations for every schema-version bump.
- Add tests for migration behavior.
- Avoid destructive migrations unless explicitly approved.

## Provenance

External or scientific data should preserve source information where practical:

- weather provider;
- target catalog source and version;
- sensor/equipment data source;
- light-pollution dataset;
- astronomical algorithm/library reference.

---

# Part B — CURRENT ENTITIES (Actual, verified)

## B1. Persistence stores

| Store | Technology / location | Contents | Notes |
| --- | --- | --- | --- |
| Relational DB | SQLite via Drift; file `astroplan.sqlite` in the app documents directory, opened with `NativeDatabase.createInBackground` (`lib/data/database/app_database.dart`); **schema version 9** | Equipment (3 normalized tables + 1 orphan), locations, targets, session logs, capture blocks | Foreign keys are declared but **not enforced** (`PRAGMA foreign_keys = 0`, no `beforeOpen`) |
| Key-value | `shared_preferences` | Active plan, selections, thresholds, active-location pointer, weather cache | See B6. Accessed directly from `PlannerViewModel` and `OpenMeteoWeatherRepository` |
| In-memory | `PlannerViewModel` fields | Selected target/equipment, session date, lat/lon, Bortle, weather, capture blocks, active log | Lost on restart except what is mirrored to shared preferences |
| Files | — | None (no export files; picked images are read, never stored) | — |

## B2. Drift schema v9 (tables)

Generated code `lib/data/database/app_database.g.dart` was regenerated in the
latest schema-changing commit (`900b82a`); it was not re-generated during this
audit. Drift row classes share names with domain models (`SessionLog`,
`AstroTarget`, `LocationProfile`, `EquipmentProfile`), so repositories import the
domain classes `as domain` (naming-collision hazard, TD-045).

| Table (Dart class) | Columns (type; `?` = nullable) | Status | Notes |
| --- | --- | --- | --- |
| `devices` (`Devices`) | id PK; name; manufacturer?; model?; notes? | **Actual**, used | One row is created per equipment profile; `name` = profile name |
| `camera_modules` (`CameraModules`) | id PK; device_id FK→devices; name; manufacturer?; model?; sensor_width_mm; sensor_height_mm; resolution_width_px; resolution_height_px; pixel_pitch_um; average_raw_file_size_mb? | **Actual**, used | `name` is synthesized as `"<profile name> Camera"` |
| `optical_rigs` (`OpticalRigs`) | id PK; name; camera_module_id FK→camera_modules; focal_length_mm; aperture (**f-number**, SI-005); tracking_state (text, default `'unknown'`); rotation_degrees? | **Actual**, used | `tracking_state` is stored but not exposed by the domain `EquipmentProfile` or any UI |
| `equipment_profiles` (`EquipmentProfiles`) | id PK; name; manufacturer?; camera_model?; sensor_width; sensor_height; pixel_pitch; resolution_width; resolution_height; focal_length; aperture; average_raw_file_size_mb?; rotation? | **Deprecated / orphaned** | Not read or written by any application code. Still created by `createAll`, read by the v5 data-copy migration, and exercised by `app_database_test.dart` |
| `location_profiles` (`LocationProfiles`) | id PK; name; latitude; longitude; elevation; bortle_class (int, default 4) | **Actual**, used | Effectively one row (the "active" location) — see DEV-D4 |
| `astro_targets` (`AstroTargets`) | id PK; catalog_id; common_name?; right_ascension (**degrees**, J2000); declination (**degrees**); type (free text) | **Actual**, used | No uniqueness constraint; no epoch/source/magnitude/size |
| `session_logs` (`SessionLogs`) | id PK; target_name; equipment_name; session_date (stored as epoch seconds; returned as local `DateTime`); location_name?; bortle_scale (real?); planned_light_frames; planned_dark_frames?; planned_flat_frames?; planned_bias_frames?; integration_time_seconds?; focal_length?; aperture?; temperature?; humidity?; cloud_cover (int?); actual_light_frames?; rejected_frames?; environmental_notes?; processing_notes? | **Partial** | Snapshot columns exist but Save Session never fills them (DEV-D3) |
| `capture_blocks` (`CaptureBlocks`) | id PK; session_log_id FK→session_logs; frame_type; filter_name?; exposure_time_seconds; frame_count; binning (default 1); gain_iso (text?) | **Actual**, used | No explicit sequence-position column (order relies on insertion order / id). A code comment says `LIGHT, DARK...` but the stored value is the lowercase enum name (`light`, `dark`, `flat`, `bias`) |

Other schema facts: no indexes beyond primary keys; no unique constraints;
`DateTime` columns use Drift's default (epoch seconds).

## B3. Domain models (`lib/domain/models/`)

| Model | Fields (unit) | Persisted in | Notes |
| --- | --- | --- | --- |
| `AstroTarget` | id; catalogId; commonName?; rightAscension (deg, J2000); declination (deg); type (free text) | `astro_targets` | Units are documented nowhere in the class (SI-012) |
| `EquipmentProfile` | id (**= `optical_rigs.id`**); name; manufacturer? (= device); cameraModel? (= camera module `model`); sensorWidth/sensorHeight (mm); pixelPitch (µm); resolutionWidth/Height (px); focalLength (mm); aperture (f-number); averageRawFileSizeMB?; rotation? (deg) | join of `optical_rigs` ⋈ `camera_modules` ⋈ `devices` | Flat **projection**; unit-less field names (SI-005). Does not expose `trackingState`, module name, device model/notes |
| `EquipmentDevice`, `CameraModule`, `OpticalRig` | mirror the three normalized tables | `devices`, `camera_modules`, `optical_rigs` | **Dormant**: used only by `EquipmentCatalogRepository`, which is not registered in `main.dart` and not used by any ViewModel or screen |
| `CaptureBlock` | id; sessionLogId; frameType (`light`/`dark`/`flat`/`bias`); filterName?; exposureTimeSeconds (s); frameCount; binning; gainIso? (free text) | `capture_blocks` (logs); JSON in shared preferences (active plan) | No validation; id is `0` in the active plan |
| `SessionLog` | see `session_logs` + `captureBlocks` | `session_logs` + `capture_blocks` | Has `toShareableText()` (used by Logbook share) and `toJson()` / `fromJson()` "manifest v1" (used **only by tests**) |
| `LocationProfile` | id; name; latitude (deg); longitude (deg, east positive); elevation (unit unspecified); bortleClass (int) | `location_profiles` | No time zone; Bortle cannot be "unknown" (SI-007) |
| `WeatherConditions` | temperature (°C); cloudCover (%); humidity (%); dewPoint (°C); windSpeed (km/h, provider default); hourlyForecasts; lastUpdated (device clock) | shared preferences cache only | No provider/model, offset, validity window or staleness field |
| `HourlyForecast` | time; temperature; cloudCover; dewPoint; humidity; precipitationProbability (%); windSpeed; isDaytime | inside the weather cache | `time` is a **naive site-local string parsed as device-local** (SI-010) |
| `VisibilityWindow` | start, end (UTC) | not persisted | `duration` getter; value equality |
| `SessionFeasibility`, `FeasibilityState` | totals + `feasible`/`tight`/`infeasible` | not persisted | Defined in `session_calculator.dart` |
| `ImageMetadata` | all strings: make, model, focalLength, aperture, exposureTime, iso, dateTimeOriginal, rawTags | not persisted | Display-only |

## B4. Units and conventions (as implemented)

| Quantity | Convention |
| --- | --- |
| Right ascension / declination | Decimal **degrees**, J2000, no epoch stored |
| Latitude / longitude | Decimal degrees; longitude **east positive** |
| Focal length, sensor size | mm |
| Pixel pitch | µm |
| Aperture field | **f-number** (dimensionless) — one seed violates this (SI-005) |
| Exposure | seconds |
| Timestamps in domain math | UTC (`AstronomicalEngine` throws if not UTC) |
| Timestamps in DB | epoch seconds (Drift default), read back as local `DateTime` |
| Weather | Open-Meteo defaults: °C, %, km/h; hourly times are site-local naive strings |
| Elevation | Unit unspecified (assumed metres); not used in any calculation |

## B5. Relationships as actually implemented

```text
devices ──1:1── camera_modules ──1:1── optical_rigs        (by construction in DriftEquipmentRepository;
                                                            the schema itself allows 1:N)
EquipmentProfile.id  ==  optical_rigs.id
session_logs ──1:N── capture_blocks                        (FK declared, NOT enforced; deleted manually in the repository)
session_logs.target_name    ~ astro_targets  (catalog_id / common_name)   soft link by display string
session_logs.equipment_name ~ optical_rigs.name                            soft link by display string
session_logs.location_name  — never populated by Save Session
location_profiles: the "active" row is referenced from SharedPreferences (activeLocationId)
```

Deleting a rig via `DriftEquipmentRepository.deleteEquipment` also deletes its
camera module and device **without checking whether other rigs reference them**
(safe only because the app always creates 1:1:1 chains).

## B6. SharedPreferences contents

| Key | Type | Written by | Meaning |
| --- | --- | --- | --- |
| `activeLocationId` | int | `PlannerViewModel.setLocation` | Pointer to the active `location_profiles` row |
| `captureBlocks` | JSON string | `PlannerViewModel._saveBlocks` | The active capture plan (hand-serialized) |
| `targetId` | int | `setTarget` | Selected target |
| `equipmentId` | int | `setEquipment` | Selected rig (`optical_rigs.id`) |
| `minAltitude` | double | `setMinAltitude` | Minimum usable altitude (deg); no UI writes it; read without clamping |
| `dewPointThreshold` | double | `setDewPointThreshold` | Dew margin (°C); no UI writes it |
| `weather_cache_<lat.2dp>_<lon.2dp>` | JSON string | `OpenMeteoWeatherRepository` | Last successful weather response for ~1.1 km cell; served when the network fails, with no staleness limit |

## B7. Seed data

- **Targets** (`CatalogSeeder`): M31, M42, M45, M33, M8 — coordinates verified
  correct in degrees. Seeded only when the table is empty (re-seeds if a user
  deletes all targets).
- **Equipment** (`EquipmentSeeder`): iPhone 15 Pro Max (Main), Pixel 8 Pro (Main),
  Xiaomi 14 Ultra (Main), Vivo X100 Pro (Main), "ZWO ASI2600MC + 400mm (Telescope
  Stub)". None sets `averageRawFileSizeMB`; the ZWO record has `aperture: 72.0`;
  sensor sizes are inconsistent with resolution × pixel pitch for some records
  (SI-005, SI-011).
- Seeding is started unawaited in `main()` (race with the ViewModel's first read,
  TD-002).

## B8. Schema and migration history (v1 → v9)

| Version | Commit | What changed | Migration step | Notes |
| --- | --- | --- | --- | --- |
| 1 | `bb327e2` | `equipment_profiles`, `location_profiles`, `astro_targets` | `createAll` | Scaffold |
| 2 | `8070dd5` | + `session_logs` | `createTable(sessionLogs)` | Uses the *current* table definition |
| 3 | `5bc8ba6` | `equipment_profiles`: + manufacturer, camera_model, rotation (optical_multiplier existed) | 3 × `ALTER TABLE` | |
| 4 | `d0b737f` | + `devices`, `camera_modules`, `optical_rigs` | `createTable(...)` × 3 | Uses the *current* definitions |
| 5 | `d0b737f` | copy flat rows into the three tables | 3 × `INSERT … SELECT` | **References `optical_multiplier`** — see DEV-D1 |
| 6 | `d0b737f` | `location_profiles.bortle_class` | `addColumn` | |
| 7 | `d0b737f` | `session_logs` expanded (location, bortle, planned darks/flats/bias, integration, focal, aperture, weather snapshot) | `addColumn` × 11 | |
| 8 | `d0b737f` | + `capture_blocks` | `createTable` | Versions 4–8 all arrived in one commit |
| 9 | `900b82a` | + `average_raw_file_size_mb` on `equipment_profiles` and `camera_modules`. `optical_multiplier` (rigs, flat table) and `bit_depth` (camera modules) were **removed from the Drift definitions with no migration** | `addColumn` × 2 | Upgraded databases keep the legacy columns; fresh installs do not — schema drift between installs |

**Empirically verified (2026-09-21, throwaway tests):**
- A **v3 database → v9 fails**: `SqliteException(1): table optical_rigs has no
  column named optical_multiplier`.
- A **v8 database → v9 succeeds** and new equipment can still be inserted (the
  leftover `optical_multiplier` column is `NOT NULL DEFAULT 1.0`). A developer
  device already at v8 is therefore fine.
- Even with the fix for the v5 step, `from < 9` would fail for databases upgraded
  from below v4 because `createTable(cameraModules)` already creates
  `average_raw_file_size_mb` (duplicate-column risk); similarly `from < 2` followed
  by `from < 7`. These paths are reasoned from code, not executed.
- There are **no migration tests** and no schema snapshots/dumps.

## B9. IMPLEMENTATION DEVIATIONS (data model)

### DEV-D1 — Migrations are untested and one upgrade path fails
- **Intended behavior:** "Add migrations for every schema-version bump. Add tests
  for migration behavior." (Migration Rules, Part A; ADR-003 "migrations … and
  testability".)
- **Actual behavior:** No migration test exists. The v5 step still references a
  column removed from the definitions in `900b82a`; v3 → v9 throws. FK enforcement
  is off.
- **Consequence:** Any database below v5 cannot be upgraded; the first real
  release with an older beta install would crash on open. Fresh installs and v8
  databases are unaffected. Work item: TD-004, TD-005.

### DEV-D2 — Equipment is normalized in storage but flat in the domain
- **Intended behavior:** Device, CameraModule and OpticalRig as first-class,
  composable entities (Phase 4 foundation; "Equipment profiles with device,
  camera module, sensor, optics, and tracking information" — PRODUCT_SPEC).
- **Actual behavior:** The three tables exist and are used, but always as a 1:1:1
  chain created by one insert. The UI and domain only see the flat
  `EquipmentProfile` (id = rig id). `EquipmentCatalogRepository` (implemented,
  tested) is unregistered. The flat `equipment_profiles` table is orphaned.
  `trackingState` is stored and invisible.
- **Consequence:** Users cannot reuse one camera across rigs; the composability
  goal is unmet; dead code and an orphan table create confusion (the previous docs
  described the flat table as the live one). Direction is open (PD-03).

### DEV-D3 — Session logs use display strings and record no snapshot
- **Intended behavior:** Stable relationships (Phase 0 "current issue" #2) and
  "a snapshot of the equipment, location, and capture plan at the time of the
  session".
- **Actual behavior:** Target and equipment are stored as name strings; Save
  Session fills only names, date, planned light frames and blocks. Location,
  Bortle, weather, focal length, aperture, integration time and planned
  darks/flats/bias stay null (verified in a widget run). The log has no
  coordinates or time zone. Saving twice inserts two rows.
- **Consequence:** A logged session cannot be re-analysed or reproduced; renaming
  equipment breaks `loadSession` matching; duplicates accumulate. TD-011.

### DEV-D4 — Active planner state is split across three stores
- **Intended behavior:** Active location persisted in `LocationProfiles`, not
  shared preferences (Phase 0 "current issue" #3).
- **Actual behavior:** Coordinates are in `location_profiles`, but the pointer,
  selections, thresholds and the capture plan are in shared preferences, and
  `setLocation` **overwrites the coordinates of the active saved profile** (a saved
  "Backyard" is mutated when the user taps "current location"). There is no UI to
  list, name or switch locations, so the table holds effectively one row.
- **Consequence:** "Saved locations" (PRODUCT_SPEC MVP) is not delivered; state is
  hard to reason about and to test. TD-027.

### DEV-D5 — Provenance is not stored
- **Intended behavior:** Preserve source information for weather provider, target
  catalog source/version, sensor data source, light-pollution dataset, algorithm
  reference (Provenance, Part A).
- **Actual behavior:** Nothing is stored. Only a code comment in `EquipmentSeeder`
  and a hard-coded `models=icon_seamless` in the weather URL record sources.
- **Consequence:** Data cannot be traced or trusted; blocks SI-011 and SI-007
  remediation. TD-008, TD-017.

### DEV-D6 — Foreign keys and integrity are declared, not enforced
- **Intended behavior:** Relationships expressed through `references()` in the
  schema (ADR-003: "relationships").
- **Actual behavior:** `PRAGMA foreign_keys = 0`; an orphan `capture_blocks` row
  with a non-existent `session_log_id` was inserted successfully (verified).
  Deletes cascade only through hand-written repository code.
- **Consequence:** Orphans are possible via any code path that bypasses the
  repositories or future refactors. TD-005.

---

# Part C — REQUIRED FUTURE DOMAIN CONCEPTS

> **Rule:** the concepts below are **required by the product concept**
> (Site → Target → Astronomical Conditions → Weather → Equipment → Imaging
> Opportunity → Capture Plan → Execution → Logbook) but are **not to be created in
> code automatically**. Each needs a design review, the open decisions listed here
> (see `docs/DECISIONS.md` PD-xx), and owner approval. Current status of each is
> stated explicitly. Proposals here are **not approved**.

## C1. Site
- **Purpose:** the place where imaging happens: coordinates, elevation, time zone,
  optional horizon profile, sky darkness (Bortle/SQM) with source.
- **Nearest current equivalent:** `LocationProfile` + `PlannerViewModel`
  lat/lon/Bortle + `activeLocationId` — **Partial**.
- **Gaps:** no time zone (SI-010); Bortle default-as-fact and no unknown (SI-007);
  no horizon; single overwritten profile (DEV-D4); elevation unit unspecified;
  active-site state split across stores.
- **Open decisions:** time-zone strategy (PD-02); light-pollution source (PD-05);
  is the active site a global setting or a per-session snapshot?
- **Roadmap:** Phases 4, 8, 11.

## C2. Target
- **Purpose:** an imaging object with reliable coordinates and provenance.
- **Nearest:** `AstroTarget` — **Partial** (Prototype catalog of 5).
- **Gaps:** no epoch/source/magnitude/angular size/constellation/aliases; type is
  free text; moving objects unsupported though offered (SI-012); `(0,0)` sentinel;
  editing overwrites `catalogId`; no uniqueness.
- **Open decisions:** ephemeris/engine choice (PD-07); moving-object policy
  (PD-16); catalog source and size.
- **Roadmap:** Phase 7.

## C3. Equipment
- **Purpose:** composable Device → CameraModule → OpticalRig with tracking state,
  optical multipliers, filters and provenance.
- **Nearest:** `EquipmentProfile` projection over the normalized tables —
  **Partial** (DEV-D2).
- **Gaps:** camera reuse; tracking state not in domain; reducer/Barlow removed;
  aperture semantics (SI-005); provenance; RAW size unknown (SI-008); catalog
  repository dormant.
- **Open decisions:** PD-03 (keep flat projection vs expose composition), PD-10
  (aperture fields and migration policy).
- **Roadmap:** Phases 4, 6.

## C4. Session
- **Purpose:** the aggregate for one planned/executed imaging night: session
  night, site, target, equipment (stable references), capture plan, weather
  snapshot, opportunity, execution state, log.
- **Nearest:** `SessionLog` and the ViewModel's implicit "current session"
  (`_activeSessionLog`, `_sessionDate`, selections) — **Partial**.
- **Gaps:** no stable references (DEV-D3); no coordinates/time zone; plan, execution
  and log are conflated in one row; no identity feedback after Save (duplicates).
- **Open decisions:** is Session the aggregate root; snapshot immutability;
  relation to CapturePlan and LogbookEntry.
- **Roadmap:** Phase 9, 13.

## C5. CapturePlan
- **Purpose:** an ordered plan with explicit budget assumptions: light sequences,
  calibration-frame policy, overhead model, integration vs acquisition vs total
  session budget.
- **Nearest:** `List<CaptureBlock>` in the ViewModel (JSON in shared preferences)
  and `SessionLog.captureBlocks` — **Partial**.
- **Gaps:** no entity or id; not linked to target/equipment; budget conflates
  integration, acquisition and calibration (TD-022); overhead not modelled beyond a
  flat 5 s/frame; no calibration-frame scheduling; no stored assumptions.
- **Open decisions:** what counts against the night window (PD-08); overhead model;
  calibration policy.
- **Roadmap:** Phase 9 (central component).

## C6. CaptureBlock
- **Purpose:** one homogeneous set of frames.
- **Nearest:** `CaptureBlock` — **Partial**.
- **Gaps:** no validation (negatives/zero accepted); gain/ISO is free text (SI-004);
  filter is a string; no per-block execution counters; no explicit sequence column
  in the DB; no dither/overhead attributes; calibration frames not related to the
  lights they calibrate.
- **Roadmap:** Phase 9.

## C7. WeatherSnapshot
- **Purpose:** provider-isolated, time-stamped weather relevant to a session night.
- **Nearest:** `WeatherConditions` + `HourlyForecast` and the shared-preferences
  cache — **Partial**.
- **Gaps:** no provider/model/run time; no UTC offset (discarded); naive timestamps;
  no target date (always "now + 48 h", starting at local midnight); no staleness
  flag; no per-night summary (for example cloud during the dark window); not stored
  in the session (3 nullable columns never filled).
- **Open decisions:** PD-15 (provider/model, date alignment).
- **Roadmap:** Phase 10.

## C8. ImagingOpportunity
- **Purpose:** the transparent intersection of astronomical darkness, target
  visibility window, Moon conditions and weather over a session night for a given
  site/target/equipment; the input to the capture budget. Must **not** become an
  opaque "Astro Score" (product principle).
- **Nearest:** `List<VisibilityWindow>` (darkness ∩ altitude only) — **Partial**;
  the concept itself is **Missing**.
- **Gaps:** no Moon, weather, horizon; no typed result, uncertainty, or per-window
  annotations.
- **Open decisions:** which conditions gate vs annotate; thresholds and their
  configurability (SI-006).
- **Roadmap:** Phases 8–10 (integration).

## C9. ExecutionState
- **Purpose:** low-friction tracking of a session in progress (planned / started /
  paused / completed per block, frames captured/rejected, timestamps, interruption
  reasons) feeding the logbook. **No hardware control** (ASCOM/INDI are out of
  scope).
- **Nearest:** none — **Missing**. (`SessionLog.actualLightFrames`,
  `rejectedFrames` are end-of-session fields with no entry UI.)
- **Roadmap:** Phases 13, 15.

## C10. LogbookEntry
- **Purpose:** planned-versus-actual record with conditions, rejected frames,
  processing notes, attachments/metadata, export.
- **Nearest:** `SessionLog` (+ `toShareableText`, `toJson` manifest v1) —
  **Partial**.
- **Gaps:** plan/actual not separated; no entry UI for actuals; snapshots not
  filled; metadata import not connected; no processing-log entity (Phase 0
  `ProcessingLog`); manifest v1 lacks coordinates and time zone and has no import
  UI.
- **Roadmap:** Phases 13, 14.

## C11. Additional concepts identified by the audit (also **Missing**)
- **SessionNight / time context** — the site-local noon-to-noon window and its
  time zone (SI-010; PD-01, PD-02).
- **MoonConditions** — illumination, altitude, rise/set and separation over the
  window (SI-002).
- **Provenance record** — source, version, date, confidence (DEV-D5).
- **User thresholds / settings** — minimum altitude, darkness limit, overhead,
  feasibility margin, dew margin (SI-006).

---

# Part D — Data rules for future work

1. **Unknown is not zero and a default is not a measurement** (SI-008). Use
   nullable values with explicit UI states.
2. **Explicit units in names or documentation** for every physical quantity
   (SI-005).
3. **Store and compute in UTC**; store the site's time zone with the site;
   never derive a night from the UTC calendar date (SI-010).
4. **Stable identifiers, not display strings**, for cross-entity references
   (DEV-D3).
5. **Migrations follow the Phase 0 rules** (Part A) and add tests; adopt Drift
   schema snapshots before the next schema change (TD-004).
6. **Provenance for external and scientific data** (Part A; DEV-D5).
7. **Do not create the Part C concepts in code** without an approved design.
