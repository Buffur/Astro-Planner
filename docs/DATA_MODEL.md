# AstroPlan Data Model

> **S7.1 (2026-09-29): schema v19** (RD-08 = T3). `session_logs.tracking_override` holds the plan's
> tracking override (NULL = the rig's default). A new plan snapshot gains `tracking` =
> {`effective`, `source` (`rig` | `plan`)}; `rig.tracking` stays the rig's default; an older
> snapshot without the key reads as the rig's default. `SavedPlanReader` restores the override
> for Discard. The export manifest's session gains `tracking_override`.

> **S6.3 (2026-09-28; S4-DEF-04 = R):** two `SessionRepository` writes, no schema change. `deleteDraft` deletes only a never-saved draft (`draft` without `planned_at_utc_ms`) with its blocks, and refuses any other row. `revertToSaved` turns a Saved · changed row (`draft` with `planned_at_utc_ms`) back to `planned`, rewriting its plan columns and blocks from `plan_snapshot`; `plan_snapshot` and `planned_at_utc_ms` are not written. A new lifecycle transition (ADR-014 §3 as amended in DECISIONS E.1).

> **S5.5 (2026-09-27):** display preferences (SharedPreferences, not the database) gain one boolean per collapsible section, under the key `section.<sectionKey>` (open = true). They stay on the device, like field mode; no schema change.

> **S3.V7 (2026-09-27):** a new session snapshot's rig provenance is the provenance every spec of a group shares, else null (never the group pair alone). No schema or snapshot-format change.

> **S3.V2 (2026-09-27):** an equipment spec's own pair may hold the source id `unknown` with NULL confidence: the field's origin is known to be unknown, and the group's provenance does not cover it. No schema change.

> **S3.4 (2026-09-26): schema v18.** It adds per-field equipment provenance and the metadata
> identity (ADR-018 §5), on `camera_modules` and `optical_rigs`. See the tables and the migration
> history below.

> **Superseded 2026-09-26 (S1.V6, finding X2):** S1.V1–S1.V4 (`3067658`, `b34c9ad`, `ed628f8`, `ea65231`) resolved TD-059–TD-062, confirmed by the repeat independent validation at `c99bd7f`. The note below is kept as history.
>
> **Independent Stage 1 validation, 2026-09-25, code `4e653fb`:** schema remains
> v17; no model or migration changed. S1.5's closure is contradicted by TD-059/060
> (background refusal type and seed state after reset); TD-061 records incomplete
> reconstruction of unsaved-plan state. See [validation](refinement/STAGE_1_VALIDATION.md).

> **Verification stamp:** verified against code at commit `900b82a` (2026-09-20),
> audited 2026-09-21. Application code changed since by TASKs 1.1–1.3 (no entity
> changes). **TASK 2.2 (2026-09-22):** three non-persisted domain types were added to
> B3 (`CalendarDate`, `SiteTimeContext`, `SessionNight`); no schema change. **TASK 3.1
> (2026-09-22, docs only):** ADR-008 decided the persistence baseline and the
> provenance convention; Part D rules 5 and 6 now point to it. B8 gained a note
> (v4–v7 never committed). No schema change. **TASK 2.3
> (2026-09-22, commit `de1792a`):** two more non-persisted types added
> (`NightTimeline`/`SunThresholdResult`, `AltitudeCurve`/`AltitudeSample`);
> `VisibilityWindow` gained two fields; no schema change. **TASK 2.4 (2026-09-22,
> commit `1e58fcf`):** `CalendarDate` and `SessionNight` are now used by the running
> app (`PlannerViewModel._pickedEveningDate`); still no schema change — a legacy
> `SessionLog.sessionDate` instant maps to its device-local evening date at read
> time (ADR-007 §10), it is not stored as a `CalendarDate` yet (G11, PD-18).
> **TASK 3.2 (2026-09-22, commit `3c25e8c`):** implements ADR-008's migration
> workflow — the v1–v7 upgrade steps are removed, replaced by a floor guard
> (v8) and a downgrade guard; Drift schema snapshots (`drift_schemas/`) and
> generated verification code (`lib/data/database/generated_migrations/`)
> exist for v8 and v9; a migration test suite covers the matrix in B8a below.
> `schemaVersion` stays at 9 — no table changed. TD-004 resolved; TD-047
> resolved for the app-database guard (the bootstrap-level reset UI is a
> separate, not-yet-scheduled follow-up). **TASK 3.3 (2026-09-22, commit
> `e580d03`):** `schemaVersion` is now **10**. `equipment_profiles` is
> dropped (Dart class and table); `camera_modules`/`optical_rigs`/
> `capture_blocks` are rebuilt with real `ON DELETE` actions and, for the
> first two, without the legacy `bit_depth`/`optical_multiplier` columns;
> foreign keys are enforced on every connection. TD-005 resolved; TD-026
> resolved in part (the unconditional-delete half). B2, B8 and DEV-D6
> updated below.
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
> **TASK 5.2 (2026-09-22):** planning preferences (`PlanningPreferences` + repository) and a Settings screen; the planner selection state moved behind `PlannerStateRepository`; `PlannerViewModel` no longer imports SharedPreferences. B6 keys and one B3 row added; no schema change.
> **TASK 5.3 (2026-09-22):** `CaptureBlock` validates at the domain boundary and gains a calibration policy and a typed, descriptive-only gain; schema v11 adds block `position`, `calibration_policy`, `gain_kind`/`gain_value` and drops the free-text `gain_iso` (owner-approved); migrations now use generated per-version step shapes (`schema_versions.dart`).
> **TASK 7.1 (2026-09-23):** site semantics in schema v12 (nullable Bortle with source and date, SQM, IANA zone, notes; default Bortle 4 cleared with a note); a map pick or GPS fix is a transient, remembered position that never writes into a saved site; the `timezone` package (0.11.1, BSD) backs an `IanaTimeContext`, so a site's zone drives its night (ADR-007 L1 fixed for sites with a zone) and the display.
> **TASK 7.3 (2026-09-23):** no schema change. Sites are now written only by the site editor (`LocationProfile.userEdit`): a Bortle/SQM value the user changed is stored with source `user` and the date; an unchanged value keeps its source and date; a cleared value loses both. Deleting the active site stores its coordinates as the transient position (`transientLatitude`/`transientLongitude` preferences) and clears `activeLocationId`. Elevation still cannot be unknown (non-null column), and nothing uses it.
> **TASK 7.4 (2026-09-23):** no schema change. `SkyDarkness` (domain) is a read-only view of a site's Bortle/SQM with their source and date (or unknown); no value is fetched or derived. PD-05 resolved (DECISIONS E.1).
> **TASK 8.1 (2026-09-23):** schema v13 — `astro_targets` + `epoch` (default `J2000`), `source`, `angular_size_arcmin`, `magnitude`; partial unique index on `catalog_id` for catalog entries. See B2 and B8.
> **TASK 8.2 (2026-09-23):** no schema change. Catalog rows carry `source = catalog:openngc@v20260501`; the applied catalog version is the preference `catalogSeedVersion` (int; 2 after this task; absent = never applied). The asset format (`assets/catalog/catalog_v2.json`: version, source, licence, epoch, objects with id, name, type, ra/dec degrees, sizeArcmin, vMag, since, and the OpenNGC name and original RA/Dec text) is documented in `lib/data/services/catalog_seeder.dart`.
> **TASK 8.3 (2026-09-23, documentation only):** ADR-011 decides the 1.0 equipment model: flat profile kept over the three tables; TASK 8.4 adds nullable `optical_rigs.aperture_diameter_mm` and `optical_rigs.max_exposure_s` (schema v14), reads `optical_rigs.aperture` as the focal ratio N, uses `tracking_state` for {untracked, tracked, guided, unknown}, and removes the dormant catalog repository. DEV-D2 updated.
> **TASK 8.4 (2026-09-23):** schema v14 (`optical_rigs` + `aperture_diameter_mm`, `max_exposure_s`); `EquipmentProfile` renamed to unit-explicit fields with tracking type and maximum exposure; the dormant domain models removed. See B2, B3, B8.
> **TASK 8.5 (2026-09-23):** schema v15 — `camera_modules` and `optical_rigs` + `source`, `confidence` (ADR-008 §6); legacy rows NULL. Seeded rows use source `seed:equipment@2`.
> **TASK 8.6 (2026-09-23):** no schema change. New preference `npfK` (double, 1–3, default 1; `SharedPrefsPlanningPreferencesRepository`).
> **TASK 9.2 (2026-09-23):** new domain `WeatherSnapshot` / `WeatherHour` (UTC, nullable per variable, provider/model/fetch time); not persisted yet (cache: TASK 9.3). `WeatherConditions` remains for the legacy path.
> **TASK 9.3 (2026-09-23):** weather snapshots are cached in SharedPreferences under `weather:<lat 2dp>:<lon 2dp>:<model>:<night start UTC ms>` (JSON format version 1: provider, model, fetch time and hour times as UTC epoch ms, nullable values). The legacy `weather_cache_<lat>_<lon>` keys remain until TASK 9.4.
> **TASK 9.4 (2026-09-23, commit `48d7a8c`):** `WeatherConditions`/`HourlyForecast` removed (owner decision) and the legacy `weather_cache_<lat>_<lon>` keys are no longer read or written (existing entries stay on upgraded devices, TD-049). New derived (not persisted) domain type `NightWeatherSummary` (interval, span kind, hourly slots with dew spread/risk, per-variable ranges).
> **TASK 10.2 (2026-09-23, commit `613b32f`):** no schema change. New preferences `moonGateEnabled` (bool, false), `moonGateMinIlluminationPct` (0–100, 50), `cloudGateEnabled` (bool, false), `cloudGateMaxPct` (0–100, 50). New derived (not persisted) domain `ImagingOpportunity` (C8 now Partial).
> **TASK 10.4 (2026-09-23, commit `6bb596f`):** no schema change. New derived (not persisted) domain types `TonightCandidate` and `MoonTrack`.
> **TASK 11.1 (2026-09-23, documentation only):** ADR-014 decides C4 Session, C9 ExecutionState and C10 LogbookEntry (see DECISIONS Part F for the entity diagram); no schema change yet (TASK 11.2 evolves `session_logs` in place).
> **TASK 11.2 (2026-09-23, commit `428f673`):** schema v16 (ADR-014 §5). `session_logs` evolved in place into the Session root: `status` (draft/planned/inProgress/completed/abandoned, CHECK, default draft), `legacy`, the night key (`evening_date`, `time_zone_id`), nullable references `site_id`/`target_id`/`rig_id` with ON DELETE SET NULL, UTC-ms lifecycle timestamps and two versioned JSON snapshot columns (`JsonMapConverter`); `capture_blocks` + `completed_frames`, `rejected_frames` (planned = `frame_count`); indexes on status, evening date and target id. Every existing log became a completed legacy session (no references guessed). `DriftLogbookRepository.updateLog` now writes only its own columns (a full-row replace would reset the v16 columns). No domain or repository API change.
> **TASK 11.3 (2026-09-23, commit `ad6609c`):** no schema change. New domain types `Session`, `SessionStatus`, `SessionPlan`, `SessionResults`, `SessionSnapshot` (versioned JSON, v1) and the pure `SessionSnapshotBuilder`; `SessionRepository` replaces `LogbookRepository`. New rows write display labels into the pre-v16 text columns (ADR-014 §10). DEV-D3 resolved for new sessions.
> **TASK 11.4 (2026-09-23, commit `628fda6`):** no schema change. The working plan and the selected target/rig ids moved from SharedPreferences (`captureBlocks`, `targetId`, `equipmentId`) into the current draft session (migrated once, then removed). DEV-D4 resolved for the plan; the active site id and the transient position stay in preferences by the TASK 7.1/7.3 owner decisions.
> **TASK 13.2 (2026-09-24, commit `14467e7`):** execution state machine and persistence (ADR-016). A pure `ExecutionMachine` (domain) validates every transition per phase (not started, running on a block, paused, finished, abandoned), folds a run's events into its state, measures running time from UTC timestamps, stamps an event taken with a clock behind the last one at that event and flags it, estimates frames (CALC-35) and detects a run past its night. Schema v17 adds the append-only `session_events` table. `SessionRepository.start` records the start on the first light block and refuses a second session in progress; `record` stores an event and its counter projection in one transaction; `complete`/`abandon` close the run with an event. A resume prompt at start (Tonight) offers keep going, pause now, finish or abandon (confirmed), flags a finished night and a clock that went back, and changes nothing without an answer. No tracking screen yet (TASK 13.3). TD-055 recorded.
> **TASK 13.3 (2026-09-24, commit `c8e2240`):** the tracking screen (`/session/:id/run`, ADR-016). The current block with confirmed and estimated counts; +1, −1, Reject, Accept estimate, Pause (plain or with a reason: clouds, wind, dew, equipment, other) / Resume, a block switcher and Finish / Abandon (confirmed) — all in the lower half, 56 dp, labelled for screen readers; countdowns to astronomical dawn, the target below its limit and moonrise; remaining window vs remaining plan (CALC-36). The tracker reads its night, target and Moon from the execution-start snapshot (`ExecutionOutlook`, pure), never from the planner. Owner decisions: Start is in the planner and on Tonight, with the same requirements as Save; after Start the planner goes on with a draft copy, and on a restart it resumes a copy when the most recent open session is running (TD-055 resolved). Tonight shows the run in progress; the resume prompt's Keep going opens the tracker. Opt-in keep-screen-on (off by default, persisted as `keepScreenOnWhileTracking`, only while the tracker is visible and a run is active) behind a `ScreenWake` interface, implemented with `wakelock_plus` 1.8.0 (BSD-3-Clause, verified on pub.dev; a screen wakelock only, no Android permission).
> **TASK 13.4 (2026-09-24, commit `c1e52ce`):** end-of-session reconciliation. A results page (`/session/:id/results`) with per-block confirmed and rejected steppers (each change a stored event), notes, optional conditions (temperature, humidity, cloud cover — empty means unknown, range-checked) and planned vs actual light integration (`SessionReconciliation`, CALC-37); Complete or Abandon. Owner decisions: the tracker's Finish opens this page and completes nothing by itself; after completion the counts may be corrected, each correction a timestamped confirm/reject event after `finished` (the only events allowed then; ADR-016 §11); Sessions shows planned vs actual integration and "Edit results" for completed sessions. `complete()` and every correction write the actual/rejected light-frame totals in the same transaction. No schema change (the condition columns existed). **Group G13 is complete.**
> **TASK 14.1 (2026-09-24, commit `e212f6a`):** Sessions list and detail. Filters by status (chips), target and site (pickers built from the saved sessions) and night date range, run in the query (`SessionRepository.list` gains `siteId`, `from`, `to`); legacy rows match a date range by their stored date and never a site or target filter, and carry a Legacy badge. Owner decisions: a tap opens the read-only detail (`/sessions/:id`); a started session shows its execution-start snapshot, a planned one its plan snapshot, labelled with when it was taken. The detail shows the night (window, zone, darkness limit, minimum altitude, usable time, windows), site (with Bortle/SQM), target, rig, budget, weather source, plan vs actual per block (CALC-37), notes and conditions, and the actions Open tracker / Edit results / Open in planner (a copy for frozen sessions) / Share. Legacy logs show their stored text only; a missing snapshot says so. Typed `SessionSnapshot` readers keep JSON out of widgets. No schema change.
> **TASK 14.3 (2026-09-24, commit `a234ff6`):** export manifest v2 (schema in `docs/EXPORT_MANIFEST.md`). `SessionManifestCodec` (data layer) writes UTC epoch-ms instants, the night key and zone, status, the snapshots as stored, blocks with confirmed/rejected counts replayed from the events, results and conditions, and the run's event log (owner decision); it reads v1 as a legacy log and refuses unknown versions. `ShareSessionExporter` shares a `.json` file plus a text summary; owner decision: Export file on a session's detail and Export all in the Sessions app bar. Import deferred. `AppIdentity.version` stays in step with `pubspec.yaml` (tested).
> **S1.5 (2026-09-25, Stage 1, commit `07d55e2`):** `refusedSchemaVersion` and `resetRefusedDatabase` (`app_database.dart`) wire the ADR-008 §2 reset into startup: below the floor only, after the user confirms, the file kept as `.v<N>.bak`; a newer database is never reset. No schema change.
> **TASK 14.4 (2026-09-24, commit `a847f87`):** backup and restore. Owner decisions: one `.astroplan` file (ZIP: header with format, schema and app version, time and session count; a consistent database copy made with `VACUUM INTO`; the v2 manifest) shared to a place the user picks; restore picked with `file_picker` 13.1.0 (MIT), checked (AstroPlan backup, header = the file's SQLite `user_version`, newer schema refused, below the v8 floor refused — older supported schemas are upgraded by the existing migrations), confirmed with a preview, staged, and applied at the next start before the database opens, the replaced database and its WAL kept as a safety copy. New dependencies `file_picker` 13.1.0 and `archive` 4.3.0 (both MIT, checked on pub.dev). Android Auto Backup: documented, not changed (owner decision). TD-056 recorded (preferences are not in the backup).

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

> **Status of those three Phase 0 issues on 2026-09-21 (1 updated 2026-09-22,
> TASK 3.3):**
> 1. Flat equipment table — **Partial**: normalized tables now exist and are
>    used (see DEV-D2), but the domain/UI model is still flat. The flat
>    `equipment_profiles` table itself is no longer orphaned in the schema —
>    it is dropped entirely (TASK 3.3, ADR-008 §5).
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
| Relational DB | SQLite via Drift; file `astroplan.sqlite` in the app documents directory, opened with `NativeDatabase.createInBackground` (`lib/data/database/app_database.dart`); **schema version 10** | Equipment (3 normalized tables), locations, targets, session logs, capture blocks | **TASK 3.3:** foreign keys are now enforced (`beforeOpen` sets `PRAGMA foreign_keys = ON` on every connection); `camera_modules.device_id`/`optical_rigs.camera_module_id` are `ON DELETE RESTRICT`, `capture_blocks.session_log_id` is `ON DELETE CASCADE` |
| Key-value | `shared_preferences` | Active plan, selections, thresholds, active-location pointer, weather cache | See B6. Accessed directly from `PlannerViewModel` and `OpenMeteoWeatherRepository` |
| In-memory | `PlannerViewModel` fields | Selected target/equipment, session date, lat/lon, Bortle, weather, capture blocks, active log | Lost on restart except what is mirrored to shared preferences |
| Files | — | None (no export files; picked images are read, never stored) | — |

## B2. Drift schema v10 (tables)

Generated code `lib/data/database/app_database.g.dart` was regenerated for the
v10 migration (TASK 3.3, commit `e580d03`). Drift row classes share names
with domain models (`SessionLog`, `AstroTarget`, `LocationProfile`), so
repositories import the domain classes `as domain` (naming-collision hazard,
TD-045).

| Table (Dart class) | Columns (type; `?` = nullable) | Status | Notes |
| --- | --- | --- | --- |
| `devices` (`Devices`) | id PK; name; manufacturer?; model?; notes? | **Actual**, used | One row is created per equipment profile; `name` = profile name |
| `camera_modules` (`CameraModules`) | id PK; device_id FK→devices **ON DELETE RESTRICT**; name; manufacturer?; model?; sensor_width_mm; sensor_height_mm; resolution_width_px; resolution_height_px; pixel_pitch_um; average_raw_file_size_mb?; **v15:** source?, confidence?; **v18:** resolution_source?, resolution_confidence?, pixel_pitch_source?, pixel_pitch_confidence?, sensor_size_source?, sensor_size_confidence?, raw_file_size_source?, raw_file_size_confidence?, metadata_make?, metadata_model? | **Actual**, used | **S3.4:** a spec's provenance is its own pair, else the group's `source`/`confidence`, else unknown (`EquipmentProfile.provenanceOf`). **S3.V2:** an own pair of source `unknown` (confidence NULL) reads as unknown whatever the group says. It is written for a legacy value left untouched while its group was edited, and for a value copied from a rig of unknown origin. `metadata_make`/`metadata_model` hold the raw identity of the file a rig was imported from (never serials). `name` is synthesized as `"<profile name> Camera"`. **TASK 3.3:** the legacy `bit_depth` column (present only on upgraded installs) is gone — the v10 migration rebuilds the table |
| `optical_rigs` (`OpticalRigs`) | id PK; name; camera_module_id FK→camera_modules **ON DELETE RESTRICT**; focal_length_mm; aperture (**focal ratio N**, ADR-011); tracking_state (text, default `'unknown'`; `untracked`/`tracked`/`guided`/`unknown`); rotation_degrees?; **v14:** aperture_diameter_mm? (mm); max_exposure_s? (s); **v15:** source?, confidence?; **v18:** focal_length_source?, focal_length_confidence?, focal_ratio_source?, focal_ratio_confidence? | **Actual**, used | **S3.4:** per-field provenance, as on `camera_modules`. The aperture diameter follows the optics group's pair. | *(Updated TASK 8.4)* all columns exposed by `EquipmentProfile`; an unrecognised `tracking_state` reads as unknown. **TASK 3.3:** the legacy `optical_multiplier` column is gone |
| `location_profiles` (`LocationProfiles`) | id PK; name; latitude; longitude; elevation; bortle_class (int, default 4) | **Actual**, used | Effectively one row (the "active" location) — see DEV-D4 |
| `astro_targets` (`AstroTargets`) | id PK; catalog_id; common_name?; right_ascension (**degrees**, J2000); declination (**degrees**); type (free text); **v13:** epoch (text, default `J2000`); source? (ADR-008 §6); angular_size_arcmin?; magnitude? | **Actual**, used | *(Updated TASK 8.1.)* Unique index `astro_targets_catalog_id_unique` on `catalog_id` **where** source is `seed:%` or `catalog:%` (user and legacy rows unconstrained). *(Was: no uniqueness; no epoch/source/magnitude/size.)* |
| `session_logs` (`SessionLogs`) | id PK; target_name; equipment_name; session_date (stored as epoch seconds; returned as local `DateTime`); location_name?; bortle_scale (real?); planned_light_frames; planned_dark_frames?; planned_flat_frames?; planned_bias_frames?; integration_time_seconds?; focal_length?; aperture?; temperature?; humidity?; cloud_cover (int?); actual_light_frames?; rejected_frames?; environmental_notes?; processing_notes? | **Partial** | Snapshot columns exist but Save Session never fills them (DEV-D3)  **Since v16 (TASK 11.2, ADR-014):** + status (CHECK, default draft), legacy (bool), evening_date, time_zone_id, site_id/target_id/rig_id (FK, ON DELETE SET NULL), created/updated/planned/started/completed_at_utc_ms, plan_snapshot and execution_start_snapshot (JSON text via `JsonMapConverter`; unreadable text reads as an empty map); indexes session_logs_status, _evening_date, _target_id; pre-v16 rows are completed + legacy. **v19 (S7.1, RD-08 = T3):** + tracking_override (text?, `untracked`/`tracked`/`guided`; NULL = the rig's default; a value the app does not know is logged and read as NULL). |
| `capture_blocks` (`CaptureBlocks`) | id PK; session_log_id FK→session_logs **ON DELETE CASCADE**; frame_type; filter_name?; exposure_time_seconds; frame_count; binning (default 1); gain_iso (text?) | **Actual**, used | No explicit sequence-position column (order relies on insertion order / id). A code comment says `LIGHT, DARK...` but the stored value is the lowercase enum name (`light`, `dark`, `flat`, `bias`)  **Since v16:** + completed_frames, rejected_frames (int, default 0; the planned count is frame_count; meaningless for legacy sessions). |
| `session_events` (`SessionEvents`) *(v17, TASK 13.2)* | id PK; session_log_id FK→session_logs **ON DELETE CASCADE**; seq (unique with session_log_id); at_utc_ms; kind (CHECK: started, blockSelected, paused, interrupted, resumed, framesConfirmed, framesRejected, finished, abandoned); block_id? FK→capture_blocks CASCADE; delta?; reason?; clock_adjusted (default false) | Append-only execution events (ADR-016 §4); the record of truth for `capture_blocks.completed_frames`/`rejected_frames`, which are written in the same transaction |

**REMOVED 2026-09-22 (TASK 3.3, ADR-008 §5):** `equipment_profiles`
(`EquipmentProfiles`) — the flat, orphaned table (id PK; name;
manufacturer?; camera_model?; sensor_width; sensor_height; pixel_pitch;
resolution_width; resolution_height; focal_length; aperture;
average_raw_file_size_mb?; rotation?). It was not read or written by any
application code; the v10 migration drops it (and the Dart class, and
`app_database_test.dart`'s test against it — see DEV-D2).

Other schema facts: no indexes beyond primary keys; no unique constraints;
`DateTime` columns use Drift's default (epoch seconds).

## B3. Domain models (`lib/domain/models/`)

| Model | Fields (unit) | Persisted in | Notes |
| --- | --- | --- | --- |
| `AstroTarget` | id; catalogId; commonName?; rightAscension (deg, J2000); declination (deg); type (free text); epoch (`J2000`); source?; angularSizeArcmin?; magnitude? | `astro_targets` | *(Updated TASK 8.1)* units documented on the class; `userEdit` keeps the catalog id and sets source `user` when data changes; moving types in `TargetTypes` (ADR-010 §3) |
| `EquipmentProfile` | id (**= `optical_rigs.id`**); name; manufacturer? (= device); cameraModel? (= camera module `model`); sensorWidthMm/sensorHeightMm; pixelPitchUm; resolutionWidthPx/HeightPx; focalLengthMm; focalRatio; apertureDiameterMm?; averageRawFileSizeMB?; rotationDeg?; trackingType; maxExposureS? | join of `optical_rigs` ⋈ `camera_modules` ⋈ `devices` | Flat **projection** (kept for 1.0, ADR-011). *(Updated TASK 8.4: unit-explicit names; `needsApertureReview` for N > 32.)* Does not expose module name, device model/notes |
| ~~`EquipmentDevice`, `CameraModule`, `OpticalRig`~~ | **Removed 2026-09-23 (TASK 8.4, ADR-011 §2)** with `EquipmentCatalogRepository` | — | *(Was: dormant mirrors of the three tables, used by nothing but their test.)* |
| `CaptureBlock` | id; sessionLogId; frameType (`light`/`dark`/`flat`/`bias`); filterName? (trimmed, ≤ 32); exposureTimeSeconds (s, (0, 3600]); frameCount ([1, 100 000]); binning ([1, 4]); gain (`CaptureGain`: kind iso/gain/unknown + value, descriptive only); calibrationPolicy (`inWindow`/`outsideWindow`/`library`; null for lights, default `outsideWindow`) | `capture_blocks` (logs, ordered by `position`); versioned JSON in shared preferences (active plan) | **Validated in a factory since TASK 5.3** — an invalid block cannot be constructed; loaders skip (and log) stored rows the domain rejects; id is `0` in the active plan |
| `SessionLog` | see `session_logs` + `captureBlocks` | `session_logs` + `capture_blocks` | Has `toShareableText()` (used by Logbook share) and `toJson()` / `fromJson()` "manifest v1" (used **only by tests**) |
| `LocationProfile` | id; name; latitude (deg); longitude (deg, east positive); elevation (**metres**); bortleClass (int 1–9 or **null = unknown**) + bortleSource + bortleDate; sqm (mag/arcsec², nullable) + sqmSource + sqmDate; timeZoneId (IANA, nullable); notes | `location_profiles` | **Since TASK 7.1 (v12):** validated in a factory; unknown stays null (SI-007); changed only by explicit user edits — a map/GPS position is transient (preferences), never written into a site |
| ~~`WeatherConditions`~~ **Removed (TASK 9.4)** | temperature (°C); cloudCover (%); humidity (%); dewPoint (°C); windSpeed (km/h, provider default); hourlyForecasts; lastUpdated (device clock) | shared preferences cache only | No provider/model, offset, validity window or staleness field. *(Legacy since TASK 9.2; replaced by `WeatherSnapshot` in 9.3–9.4.)* |
| `WeatherSnapshot` *(TASK 9.2)* | provider; model; fetchedAtUtc; latitude/longitude; hours: `WeatherHour` {timeUtc; cloud total/low/mid/high (%); precipitation probability (%); wind, gusts (km/h, gusts = preceding-hour max); temperature, dew point (°C); relative humidity (%); visibility (m, horizontal)} — every value nullable (unknown) | not persisted yet (TASK 9.3) | `source` = `provider:open-meteo/best_match` (ADR-008 §6) |
| `NightWeatherSummary` *(TASK 9.4)* | fromUtc/toUtc (sunset..sunrise, or the whole window); span (`sunsetToSunrise`/`midnightSun`/`polarNight`); slots: {timeUtc; `WeatherHour`? (null = no forecast); dewSpreadC (°C)?; dewRisk?}; dewMarginC; `WeatherRange` {min, max}? per ADR-012 variable and for the dew spread | derived, not persisted (`NightWeatherSummarizer`) | Ranges over covered hours only; null = no value in any covered hour, never 0 |
| ~~`HourlyForecast`~~ **Removed (TASK 9.4)** | time; temperature; cloudCover; dewPoint; humidity; precipitationProbability (%); windSpeed; isDaytime | inside the weather cache | `time` is a **naive site-local string parsed as device-local** (SI-010) |
| `PlanningPreferences` *(TASK 5.2)* | minAltitudeDeg; darknessLimit (enum, deg); feasibilityMarginPercent; dewMarginC; perFrameOverheadSeconds; optional overheads (nullable = off) | shared preferences (B6) | Clamped on construction; documented defaults are assumptions (`lib/domain/models/planning_preferences.dart`) |
| `VisibilityWindow` | start, end (UTC); clippedAtStart, clippedAtEnd (bool) *(fields added TASK 2.3)* | not persisted | `duration` getter; value equality (now includes the clip flags). A window is clipped when it touches a `SessionNight` boundary in polar night (ADR-007 §9); always `false` for windows from the legacy DateTime-based API path, though that path can itself produce a clipped window (verified) since clipping depends only on the astronomy, not on which API computed it |
| `NightTimeline` / `SunThresholdResult` *(TASK 2.3)* | night (`SessionNight`); four `SunThresholdResult` fields (sunriseSunset, civilTwilight, nauticalTwilight, astronomicalTwilight), each a `SunCrossing` (duskUtc?, dawnUtc?, belowAtStart, belowAtEnd), `SunNeverBelow` or `SunAlwaysBelow` | not persisted | Replaces the stringly-typed `Map<String, DateTime?>` (TD-024); "not reached" is never a bare null (SI-008). Built by `VisibilityCalculator.calculateNightTimelineForNight`; consumed by `sky_darkness_widget.dart` via sealed-class pattern matching *(wired TASK 2.4)* |
| `AltitudeCurve` / `AltitudeSample` *(TASK 2.3)* | night (`SessionNight`); samples: List of {instantUtc, sunAltitudeDeg, targetAltitudeDeg}, 5-minute grid, 289 points inclusive of both ends | not persisted | Built by `VisibilityCalculator.calculateAltitudeCurve`; consumed by `AltitudeChartWidget`, the only current caller |
| `CalendarDate` *(TASK 2.2)* | year; month; day (no time, no zone) | not persisted yet | Validated; ISO `YYYY-MM-DD` round trip; the intended persisted form of a night's evening date (ADR-007 §10, G11). **Wired TASK 2.4:** `PlannerViewModel._pickedEveningDate` and `NightTimeFormatter.eveningDate` |
| `SiteTimeContext` *(TASK 2.2)* | `id`; `offsetAt(utc)` | not persisted yet | `MeanSolarTimeContext` (id `solar`, offset `round(λ·240 000)` ms) and `FixedOffsetTimeContext` (id such as `UTC+14:00`); an IANA context arrives in TASK 7.1 |
| `SessionNight` *(TASK 2.2)* | eveningDate (`CalendarDate`); startUtc; endUtc (= start + 24 h); latitude, longitude (deg, λ normalized to (−180, 180]); timeContextId | not persisted | Built by `SessionNightResolver` (ADR-007); consumed by `PlannerViewModel.sessionNight` and the UI *(wired TASK 2.4)* |
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
| Timestamps in domain math | UTC (`AstronomicalEngine` throws if not UTC; `SessionNightResolver` and `FixedClock` reject non-UTC inputs) |
| Session-night evening date *(TASK 2.2; wired into the ViewModel TASK 2.4)* | Civil calendar date at the site (`CalendarDate`), never an instant (ADR-007) |
| Timestamps in DB | epoch seconds (Drift default), read back as local `DateTime` |
| Weather | Open-Meteo defaults: °C, %, km/h; hourly times are site-local naive strings |
| Elevation | Unit unspecified (assumed metres); not used in any calculation |

## B5. Relationships as actually implemented

```text
devices ──1:1── camera_modules ──1:1── optical_rigs        (by construction in DriftEquipmentRepository;
                                                            the schema itself allows 1:N; ON DELETE RESTRICT
                                                            from v10, TASK 3.3)
EquipmentProfile.id  ==  optical_rigs.id
session_logs ──1:N── capture_blocks                        (ON DELETE CASCADE and enforced from v10, TASK 3.3;
                                                            also still deleted manually in the repository)
session_logs.target_name    ~ astro_targets  (catalog_id / common_name)   soft link by display string
session_logs.equipment_name ~ optical_rigs.name                            soft link by display string
session_logs.location_name  — never populated by Save Session
location_profiles: the "active" row is referenced from SharedPreferences (activeLocationId)
```

**RESOLVED 2026-09-22 (TASK 3.3, commit `e580d03`).** *(Was: deleting a rig via
`DriftEquipmentRepository.deleteEquipment` also deleted its camera module and
device without checking whether other rigs reference them.)* `deleteEquipment`
now checks for other rigs on the camera module and other camera modules on the
device before deleting either, matching the `ON DELETE RESTRICT` the v10
migration added (a delete of a still-referenced row would otherwise throw). In
practice the counts are always 0 today, since the app only ever creates 1:1:1
chains, but the guard is in place for when equipment composition (PD-03)
allows reuse.

## B6. SharedPreferences contents

| Key | Type | Written by | Meaning |
| --- | --- | --- | --- |
| `activeLocationId` | int | `SharedPrefsPlannerStateRepository` | Pointer to the active saved site; **cleared when a transient position is chosen** (TASK 7.1) |
| `transientLatitude`, `transientLongitude` *(TASK 7.1)* | double | same | The transient current position (map pick or GPS fix), remembered across restarts; never written into a saved site |
| `captureBlocks` | JSON string | `SharedPrefsPlannerStateRepository` (from `_saveBlocks`) | The active capture plan. **Versioned since TASK 5.3:** `{"version": 2, "blocks": [...]}` with `gainKind`/`gainValue`/`calibrationPolicy`; the pre-5.3 bare list (v1, free-text `gainIso`) is still read, its gain as kind unknown. Moves to the database in TASK 11.4 |
| `targetId` | int | `SharedPrefsPlannerStateRepository` (from `setTarget`) | Selected target |
| `equipmentId` | int | `SharedPrefsPlannerStateRepository` (from `setEquipment`) | Selected rig (`optical_rigs.id`) |
| `editedSessionId` | int | `SharedPrefsPlannerStateRepository` (from `CurrentSession`, S1.V3) | The session holding plan edits not yet saved, so New/Duplicate/Open still ask after a restart; removed after a successful Save, Start, New or Open. Local only |
| `minAltitude` | double | `SharedPrefsPlanningPreferencesRepository` | Minimum usable altitude (deg); Settings screen; clamped to [5, 60] on load (TASK 5.2) |
| `dewPointThreshold` | double | `SharedPrefsPlanningPreferencesRepository` | Dew margin (°C); Settings screen; clamped to [0, 10] |
| `npfK` | double | `SharedPrefsPlanningPreferencesRepository` | NPF k (star-trail tolerance), Settings screen; clamped to [1, 3], default 1 *(TASK 8.6)* |
| `moonGateEnabled`, `cloudGateEnabled` *(TASK 10.2)* | bool | same | Optional opportunity gates (ADR-013 G4/G5); absent = off |
| `moonGateMinIlluminationPct`, `cloudGateMaxPct` *(TASK 10.2)* | double | same | Gate thresholds, %, clamped to [0, 100], default 50 |
| `darknessLimitDeg` *(TASK 5.2)* | double | same | Sun limit for windows: −18, −15 or −12 (anything else reads as −18) |
| `feasibilityMarginPercent` *(TASK 5.2)* | double | same | Tight-margin percent, default 15, range [0, 50] |
| `perFrameOverheadSeconds` *(TASK 5.2)* | double | same | Per-frame overhead (s), default 5 |
| `ditherEveryNFrames`, `ditherSettleSeconds`, `refocusEveryMinutes`, `refocusSeconds`, `filterChangeSeconds`, `meridianFlipSeconds`, `setupMinutes` *(TASK 5.2)* | int / double | same | Optional overheads (ADR-009 §4); an **absent key means off** ("not included"); stored, not yet consumed (TASK 5.4) |
| ~~`weather_cache_<lat.2dp>_<lon.2dp>`~~ **No longer used (TASK 9.4; entries remain on upgraded devices, TD-049)** | JSON string | `OpenMeteoWeatherRepository` | Last successful weather response for ~1.1 km cell; served when the network fails, with no staleness limit |

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

## B8a. Backup and restore (TASK 14.4)

- **Backup:** one `.astroplan` file — a ZIP with `backup.json` (format
  `astroplan-backup`, `format_version` 1, `schema_version`, `app_version`,
  `created_at_utc_ms`, `session_count`), `astroplan.sqlite` (a consistent copy made with
  `VACUUM INTO`) and `manifest.json` (export manifest v2, `docs/EXPORT_MANIFEST.md`).
- **Restore:** refused when the file is not a backup, when the header disagrees with the
  database's own `user_version`, when the schema is newer than the app's, or below the v8
  floor; otherwise confirmed, staged as `astroplan.restore.sqlite` and swapped in by
  `main.dart` before the database opens (`BackupStaging.apply`), the replaced file and its
  `-wal`/`-shm` renamed `*.before-restore-<time>.bak`, never deleted. An older supported
  schema is upgraded by the normal migrations when the database opens.
- **Not included:** SharedPreferences (TD-056).
- **Android Auto Backup (documented, not changed — owner decision; unverified on a
  device):** the manifest sets no `allowBackup`/backup rules, so Android's default
  applies: for apps targeting API 23+ Auto Backup is on, and it backs up the app's files,
  databases and shared preferences (up to 25 MB) to the user's Google Drive, roughly daily
  when idle, charging and on Wi-Fi, and restores them when the app is reinstalled with the
  same account. The database lives in the documents directory (`app_flutter`), which the
  default includes. None of this has been verified on a device; the manual backup is the
  supported path.

## B8. Schema and migration history (v1 → v10)

*(Superseded 2026-09-26, S1.V6/X2: S1.V1 `3067658` and S1.V2 `b34c9ad` resolved TD-059/060. Kept as history:)*
**Current validation correction (2026-09-25, `4e653fb`; TD-059/060):** the
S1.5 helpers and screen exist, but production's background connection delivers
`DriftRemoteException`, bypassing the typed refusal catch. The direct native
connection tests pass. Reset also retains the catalog version preference: if
already current, it suppresses seeding in the replacement database (0 targets
in the probe). The no-reset rule for newer databases remains in force. These
findings qualify the S1.5 completion note below; they change no schema policy.

| Version | Commit | What changed | Migration step | Notes |
| --- | --- | --- | --- | --- |
| 1 | `bb327e2` | `equipment_profiles`, `location_profiles`, `astro_targets` | `createAll` | Scaffold |
| 2 | `8070dd5` | + `session_logs` | `createTable(sessionLogs)` | Uses the *current* table definition |
| 3 | `5bc8ba6` | `equipment_profiles`: + manufacturer, camera_model, rotation (optical_multiplier existed) | 3 × `ALTER TABLE` | |
| 4 | `d0b737f` | + `devices`, `camera_modules`, `optical_rigs` | `createTable(...)` × 3 | Uses the *current* definitions |
| 5 | `d0b737f` | copy flat rows into the three tables | 3 × `INSERT … SELECT` | **References `optical_multiplier`** — see DEV-D1 |
| 6 | `d0b737f` | `location_profiles.bortle_class` | `addColumn` | |
| 7 | `d0b737f` | `session_logs` expanded (location, bortle, planned darks/flats/bias, integration, focal, aperture, weather snapshot) | `addColumn` × 11 | |
| 8 | `d0b737f` | + `capture_blocks` | `createTable` | Versions 4–8 all arrived in one commit. *Verified 2026-09-22 (TASK 3.1):* committed builds only ever created v1, v2, v3, v8 and v9; v4–v7 could exist only on a developer device from uncommitted builds |
| 9 | `900b82a` | + `average_raw_file_size_mb` on `equipment_profiles` and `camera_modules`. `optical_multiplier` (rigs, flat table) and `bit_depth` (camera modules) were **removed from the Drift definitions with no migration** | `addColumn` × 2 | Upgraded databases keep the legacy columns; fresh installs do not — schema drift between installs |
| 10 | `e580d03` | Orphan cleanup (`PRAGMA foreign_key_check`, delete + log); `camera_modules`/`optical_rigs`/`capture_blocks` rebuilt with real `ON DELETE` actions and without the legacy `bit_depth`/`optical_multiplier` columns; `equipment_profiles` dropped | `alterTable(TableMigration(...))` × 3, `deleteTable` | TASK 3.3, ADR-008 §4–§5. `beforeOpen` now sets `PRAGMA foreign_keys = ON` on every connection |
| 11 | TASK 5.3 | `capture_blocks`: + `position` (int, order within the session), + `calibration_policy` (text, NULL for lights), + `gain_kind` (text, default `unknown`), + `gain_value` (real); `gain_iso` **dropped** after conversion (owner-approved, ADR-008 §3); `frame_type` lower-cased | `alterTable(TableMigration(...))` with `newColumns` and a `columnTransformer`: position = id (keeps insertion order); policy = NULL for lights else `outsideWindow` (ADR-009 §3); gain kind = `unknown` (never guessed); gain value = the old text when it is a plain non-negative number, else NULL | Migrations since TASK 5.3 run through Drift's generated `migrationSteps` (`lib/data/database/schema_versions.dart`, `drift_dev schema steps`); every step, including the v9 and v10 ones, is written against its **own** version's table shapes, not the live tables (ADR-008 §3) |
| 15 | TASK 8.5 | `camera_modules` + `source`, `confidence`; `optical_rigs` + `source`, `confidence` (text, nullable; confidence ∈ `verified`/`reported`/`estimated`) | `addColumn` ×4 against the v15 step shape; legacy rows stay NULL (unknown, ADR-008 §6: never back-filled) | Tested: v8–v14 → v15 snapshot equality; a legacy phone row keeps its values (including the 10.5 % mismatch) with unknown provenance |
| 16 | TASK 11.2 | `session_logs` + status, legacy, evening_date, time_zone_id, site_id/target_id/rig_id (SET NULL), five UTC-ms timestamps, plan_snapshot, execution_start_snapshot; `capture_blocks` + completed_frames, rejected_frames; three indexes | Additive (`addColumn`); existing logs → `status = completed`, `legacy = 1`; nothing guessed | `schema_migration_test.dart` (v8–v15 → v16 exact; legacy rows kept and listed; SET NULL; JSON round trip; CHECK; updates keep v16 columns) |
| 19 | S7.1 | `session_logs` + `tracking_override` (text, nullable) | `addColumn` against the step's `schema.sessionLogs`; every existing plan keeps NULL (the rig's default, as before: no override existed) | `schema_migration_test.dart` (v8–v18 → v19 exact; a v18 plan, its snapshot and blocks kept, the override NULL) |
| 18 | S3.4 | `camera_modules` + resolution/pixel_pitch/sensor_size/raw_file_size `_source` and `_confidence`, + `metadata_make`, `metadata_model`; `optical_rigs` + focal_length/focal_ratio `_source` and `_confidence` (all text, nullable) | `addColumn` against the step's `schema.<table>` shapes; nothing back-filled (ADR-008 §6). Session snapshots carry no per-field provenance. **Since S3.V7 (2026-09-27)** a new snapshot's `cameraSource`/`cameraConfidence` and `opticsSource`/`opticsConfidence` are the provenance every spec of the group shares, else null; they are never the group pair alone. Snapshots saved earlier keep the group pair. Per-field snapshot provenance is Stage 8's (TD-070) |
| 17 | TASK 13.2 (`14467e7`) | new `session_events` (session_log_id FK CASCADE, seq unique per session, at_utc_ms, kind with CHECK, block_id FK CASCADE, delta, reason, clock_adjusted) | `createTable` + index; no existing row changes | `schema_migration_test.dart` (v8–v16 → v17 exact; data kept; CHECK; unique seq; cascade) |
| 14 | TASK 8.4 | `optical_rigs`: + `aperture_diameter_mm` (real, nullable), + `max_exposure_s` (real, nullable) | `addColumn` ×2 against the v14 step shape; every stored value kept (the `aperture` column is read as N; values above 32 are flagged in the UI, not converted; `tracking_state` unchanged) | Tested: v8–v13 → v14 snapshot equality; a v13 row with f/72 and tracking `tracking` stays 72 (flagged) and reads as tracking unknown |
| 13 | TASK 8.1 | `astro_targets`: + `epoch` (text, default `J2000`), + `source` (text), + `angular_size_arcmin` (real), + `magnitude` (real); + partial unique index `astro_targets_catalog_id_unique` (`catalog_id` where `source LIKE 'seed:%' OR source LIKE 'catalog:%'`) | `addColumn` ×4 and `create(index)` against the v13 step shape. Legacy rows: epoch `J2000` (the calculators have always treated every target as J2000), source NULL (seeded and user rows cannot be told apart, ADR-008 §6), size/magnitude NULL; the index cannot conflict with legacy rows | Tested: v8–v12 → v13 snapshot equality; data preservation including duplicate legacy ids; uniqueness only for catalog entries |
| 12 | TASK 7.1 | `location_profiles`: `bortle_class` becomes **nullable** (no default); + `bortle_source`, `bortle_date` (ISO date), `sqm` (mag/arcsec²), `sqm_source`, `sqm_date`, `time_zone` (IANA id), `notes`; elevation documented as metres | `alterTable(TableMigration(schema.locationProfiles, newColumns, columnTransformer))` against the v12 shape. **Owner decision:** a stored Bortle 4 (the app's default, never a measurement) becomes NULL, with a note in `notes`; any other stored value is kept with source `legacy` | Rows keep their coordinates and names; tested (v8–v11 → v12 snapshot equality, and legacy-row conversion) |

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

**RESOLVED 2026-09-22 (TASK 3.2, commit `3c25e8c`; suite 160/160).** *(Was the
above: v1–v7 steps written against current definitions, no snapshots, no
tests.)* Implements ADR-008 §2–§3:

- **The v1–v7 steps are deleted.** `onUpgrade` now has exactly one supported
  path (`from < 9`, i.e. v8 → v9: `addColumn` × 2, unchanged from before),
  guarded by two checks that run first and throw
  `UnsupportedSchemaVersionException` **before any statement executes**:
  - `from < kMinSupportedSchemaVersion` (8) — a below-floor database.
  - `from > to` — a downgrade: an older app build opened a newer database
    (TD-047; Drift calls `onUpgrade` whenever the stored version differs from
    `schemaVersion`, in either direction).
- **The v8 → v9 step runs inside `m.database.transaction(...)`.** Verified by a
  test that injects a failure between the two `addColumn` calls: the file is
  byte-identical afterwards, not left with only the first column added.
- **`resetUnsupportedDatabaseFile(File, {foundVersion})`** renames a
  below-floor file to `<name>.v<found>.bak` (never deletes it), so a fresh
  database can be created at the original path. *(Since S1.5, 2026-09-25: called
  through `resetRefusedDatabase` from the startup recovery screen, only after the
  user confirms, and only below the floor. The text that follows is the TASK 3.2
  state.)* **Not yet called from
  anywhere** — no bootstrap-level confirmation UI exists yet (ADR-008 says the
  rename must only happen "on the user's explicit confirmation"); wiring it in
  is a separate, not-yet-scheduled task.
- **Schema snapshots and generated verification** (Drift's documented
  tooling, `drift_dev schema dump` / `schema generate`, configured by the new
  `build.yaml`):
  - `drift_schemas/drift_schema_v8.json` — dumped from the `d0b737f` source
    (the table definitions were swapped in, dumped, then reverted; verified
    via `git diff` to leave no trace).
  - `drift_schemas/drift_schema_v9.json` — dumped from the current source.
  - `lib/data/database/generated_migrations/` (`schema.dart`,
    `schema_v8.dart`, `schema_v9.dart`) — drift_dev-generated `GeneratedHelper`
    and per-version `GeneratedDatabase` subclasses, used by
    `SchemaVerifier` in tests. Regenerate both steps after any schema change.
- **Test suite** (`test/data/database/schema_migration_test.dart`, 8 tests at
  the time): a fresh install matches its own declared schema (M1); v8 → v9
  matched the v9 snapshot **except** the three documented legacy columns; two
  data-preservation tests; the floor guard (M5); the downgrade guard (M7); the
  reset path (M6); the transaction-atomicity check (M11). M3/M4/M8–M10
  (foreign keys, the orphan table, v10) were TASK 3.3.

**Superseded 2026-09-22 (TASK 3.3, commit `e580d03`; suite 166/166).**
`onUpgrade` now has two staged steps under the same guards and the same outer
transaction, not one: `from < 9` (unchanged: `cameraModules` gains
`averageRawFileSizeMB`; the matching `equipmentProfiles` addColumn is gone —
that table is dropped by the very next step, so adding a column to it first
would be pure waste, and it can no longer be referenced now that
`EquipmentProfiles` isn't a declared table) and `from < 10` (ADR-008 §4–§5, see
the v10 row above). Kept staged, not merged, so a hypothetical device already
at v9 — none has ever existed for this pre-release app — would still upgrade
correctly. The "except the three documented legacy columns" schema mismatch
above is gone: a v8 → v10 (or v9 → v10) migration now matches the v10 snapshot
**exactly**, asserted by tests M3 and M4. The test suite grew to 14 tests in
this file, covering the full ADR-008 §7 matrix through M9 (M10 is the rest of
`flutter test`, not a dedicated test).

## B9. IMPLEMENTATION DEVIATIONS (data model)

### DEV-D1 — Migrations are untested and one upgrade path fails
- **Intended behavior:** "Add migrations for every schema-version bump. Add tests
  for migration behavior." (Migration Rules, Part A; ADR-003 "migrations … and
  testability".)
- **Actual behavior (historical):** No migration test existed. The v5 step
  referenced a column removed from the definitions in `900b82a`; v3 → v9 threw.
  FK enforcement was off.
- **RESOLVED 2026-09-22 (TASK 3.2; see B8 above).** The v1–v7 steps (including
  the broken v5 one) are deleted rather than repaired — ADR-008 §2 decided the
  upgrade floor is v8, and no installs below v8 need to be preserved (owner
  confirmed). Schema snapshots and generated verification now exist for v8 and
  v9, with a migration test suite (M1, M2, M5–M7, M11 of ADR-008 §7).
- **RESOLVED 2026-09-22 (TASK 3.3; see B8 above).** FK enforcement is on for
  every connection; see DEV-D6 below.
- **Consequence (historical, now moot).** Any database below v5 could not be
  upgraded. Fresh installs and v8 databases were unaffected. Work item:
  ~~TD-004~~ (resolved), ~~TD-005~~ (resolved).

### DEV-D2 — Equipment is normalized in storage but flat in the domain
- **Intended behavior:** Device, CameraModule and OpticalRig as first-class,
  composable entities (Phase 4 foundation; "Equipment profiles with device,
  camera module, sensor, optics, and tracking information" — PRODUCT_SPEC).
- **Actual behavior:** The three tables exist and are used, but always as a 1:1:1
  chain created by one insert. The UI and domain only see the flat
  `EquipmentProfile` (id = rig id). `EquipmentCatalogRepository` (implemented,
  tested) is unregistered. `trackingState` is stored and invisible.
- **RESOLVED 2026-09-22 in part (TASK 3.3, commit `e580d03`).** The orphaned
  `equipment_profiles` table is dropped (ADR-008 §5; B2 above), and
  `DriftEquipmentRepository.deleteEquipment` now checks for other references
  before deleting a shared camera module or device, matching the `ON DELETE
  RESTRICT` the v10 migration added.
- **Consequence:** Users cannot reuse one camera across rigs; the composability
  goal is unmet; `EquipmentCatalogRepository` stays dead code. Direction is open
  (PD-03).
- **Decision 2026-09-23 (ADR-011, TASK 8.3):** the flat profile is kept for 1.0 and
  composition is deferred; the dormant repository and its domain models are removed
  in TASK 8.4. The deviation remains, by decision, until a post-1.0 composition design.
  **Done (TASK 8.4):** the dormant code is removed and the tracking state is exposed.

### DEV-D3 — Session logs use display strings and record no snapshot
- **Intended behavior:** Stable relationships (Phase 0 "current issue" #2) and
  "a snapshot of the equipment, location, and capture plan at the time of the
  session".
- **Actual behavior:** Target and equipment are stored as name strings; Save
  Session fills only names, date, planned light frames and blocks. Location,
  Bortle, weather, focal length, aperture, integration time and planned
  darks/flats/bias stay null (verified in a widget run). The log has no
  coordinates or time zone. **Resolved 2026-09-22 (TASK 4.2):** saving twice
  used to insert two rows — `addLog` now returns the new id and
  `PlannerViewModel.markSessionSaved` tracks it, so a second Save updates the
  same row (TD-011, duplicate-save half only).
- **Consequence:** A logged session cannot be re-analysed or reproduced; renaming
  equipment breaks `loadSession` matching. TD-011 (snapshot half, still open).
- **Progress 2026-09-23 (TASK 11.2, schema v16):** the storage for stable references
  (SET NULL), the night key, status and versioned snapshots exists (ADR-014); nothing
  writes them yet (TASKs 11.3–11.4).
- **RESOLVED 2026-09-23 (TASK 11.3, commit `ad6609c`) for new sessions:** Save writes
  references, the night key, the status and a versioned plan snapshot; the Logbook and
  `openSession` read references by id. Legacy rows stay labels-only (owner decision).

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
- **RESOLVED 2026-09-23 (TASK 11.4, commit `628fda6`) for the plan:** the capture plan
  and the selected target and rig live in the current draft session in the database
  (autosaved; the preferences copy migrated once and removed). Sites are managed in
  `location_profiles` since TASK 7.3; the active-site id and the transient position
  stay in preferences as app-level state (TASK 7.1/7.3 owner decisions).

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
- **Actual behavior (historical):** `PRAGMA foreign_keys = 0`; an orphan
  `capture_blocks` row with a non-existent `session_log_id` was inserted
  successfully (verified). Deletes cascaded only through hand-written
  repository code.
- **RESOLVED 2026-09-22 (TASK 3.3, commit `e580d03`; suite 166/166).**
  `beforeOpen` sets `PRAGMA foreign_keys = ON` for every connection. The v10
  migration ran a one-time `PRAGMA foreign_key_check` first and deleted every
  flagged row (logging the count per table) before rebuilding
  `camera_modules`/`optical_rigs`/`capture_blocks` with real `ON DELETE`
  actions (`RESTRICT`/`RESTRICT`/`CASCADE`). Verified: an orphan insert now
  throws, a session delete cascades to its blocks, and deleting a device or
  camera module still referenced elsewhere is refused.
- **Consequence (historical, now moot).** Orphans were possible via any code
  path that bypassed the repositories. TD-005.

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
  (`_activeSessionLog`, `_pickedEveningDate`/`sessionNight`, selections) —
  **Partial**.
- **Gaps:** no stable references (DEV-D3); no coordinates/time zone; plan, execution
  and log are conflated in one row; no identity feedback after Save (duplicates).
- **Open decisions:** is Session the aggregate root; snapshot immutability;
  relation to CapturePlan and LogbookEntry. *(Decided 2026-09-23, ADR-014: Session is
  the root with status, night key, UTC timestamps, SET NULL references and versioned
  plan/execution-start snapshots; LogbookEntry = a completed Session; implemented in
  TASKs 11.2–11.4.)*
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
  the concept itself is **Missing**. *(Since TASK 10.2: `ImagingOpportunity` — windows
  with clip flags and max altitude, excluded segments with every failing gate, the
  no-window reason, per-window Moon and weather annotations, optional Moon/cloud gates
  (ADR-013) — **Partial**: no horizon, not yet presented.)*
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
  `rejectedFrames` are end-of-session fields with no entry UI.) *(Decided 2026-09-23,
  ADR-014: status + per-block planned/completed/rejected counters (TASK 11.2) + events
  (G13).)*
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
  time zone (SI-010; PD-01, PD-02). *Progress:* decided by ADR-007 (TASK 2.1) and
  implemented as a non-persisted domain type, used by the calculators, the
  altitude chart (TASK 2.2, 2.3) and now the ViewModel and UI (TASK 2.4; see Part
  B). **Still Missing:** persistence — the schema still stores a legacy instant,
  mapped to its evening date at read time, not a `CalendarDate` of its own (G11).
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
   schema snapshots before the next schema change (~~TD-004~~ resolved TASK 3.2).
   *Decided 2026-09-22 by ADR-008 (`docs/DECISIONS.md` Part F); the floor,
   snapshots, foreign keys and the orphan-table drop are all implemented
   (TASK 3.2, TASK 3.3, see B8 above):*
   - **Floor.** The upgrade floor is v8 — **implemented** as a guard in
     `onUpgrade`. Older databases are refused; `resetUnsupportedDatabaseFile`
     backs up and resets a file, but nothing calls it yet — the user
     confirmation UI is a separate, unscheduled follow-up. Newer databases are
     refused.
   - **Snapshots.** Snapshots live in `drift_schemas/` — **implemented**: v8
     exported from `d0b737f`, v9 and v10 from the current code at each task.
   - **Steps.** Each step is written against its own version's generated schema
     class — **not yet needed**: the two steps that exist (v8 → v9, v9 → v10)
     are still written directly against the live tables, since floor
     enforcement removed every step they would otherwise conflict with. Adopt
     the generated-schema-class approach for the *next* schema bump (5.3 or
     later).
   - **Tests.** Every bump has a data-preservation test and a schema-equality
     test — **implemented** for v8 → v9 → v10
     (`test/data/database/schema_migration_test.dart`).
   - **Foreign keys.** They are on for every connection from v10 —
     **implemented** (TASK 3.3): `beforeOpen` sets `PRAGMA foreign_keys = ON`;
     a one-time orphan cleanup runs first, then `camera_modules`/
     `optical_rigs`/`capture_blocks` are rebuilt with real `ON DELETE` actions.
   - **Orphan table.** `equipment_profiles` is dropped — **implemented**
     (TASK 3.3).
   - **Workflow.** The full workflow is documented here by TASK 3.2, extended
     by TASK 3.3.
6. **Provenance for external and scientific data** (Part A; DEV-D5). *Decided
   2026-09-22 by ADR-008 §6:*
   - **Columns.** Per-row nullable `source` (a namespaced id) and `confidence`
     (`verified` / `reported` / `estimated`), with per-field pairs where the origins
     differ.
   - **Timing.** Added by TASKs 7.1, 8.1 and 8.5.
   - **Legacy rows.** They stay NULL, meaning unknown, never guessed.
7. **Do not create the Part C concepts in code** without an approved design.
