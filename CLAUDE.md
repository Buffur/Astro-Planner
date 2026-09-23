# AstroPlan — AI Engineering Guidelines

## Project Purpose

AstroPlan is a mobile application for astrophotographers. It helps users plan, execute, and document sessions by combining equipment profiles, target visibility, weather, moon conditions, and capture planning. It is designed to complement tools like Stellarium, not replace them (e.g., it is a planner/logbook, not a full planetarium).

## Tech Stack

- **Framework**: Flutter
- **Language**: Dart
- **State Management**: Provider with ViewModels
- **Database**: SQLite (via Drift)
- **Navigation**: go_router

## Main Architectural Rules

1. **Separation of Concerns**: Presentation -> ViewModels -> Repositories -> Data Sources/Services.
2. **Domain Isolation**: Astronomy calculations must remain independent from Flutter UI code (pure Dart preferred).
3. **Offline-First**: Core features (equipment, targets, calculations, logs) must work offline. External APIs (weather, geocoding) enrich but aren't strictly required.

## Source-of-Truth Documents

Read these before architectural or feature changes:

- `docs/PROJECT_HANDOFF.md`: Entry point. Current project state (actual vs intended), traps, build/test baseline, document map.
- `docs/ARCHITECTURE.md`: Design intent (Part A), current architecture (Part B), implementation deviations (Part C), target direction (Part D).
- `docs/DATA_MODEL.md`: Design intent (Part A), current entities and migration history (Part B), required future domain concepts (Part C).
- `docs/FEATURE_STATUS.md`: Per-feature status (Implemented / Partial / Prototype / Broken / Missing / Deprecated / Unknown) with known issues.
- `docs/TECH_DEBT.md`: Debt register (`TD-###`) with evidence and proposed directions.
- `docs/DECISIONS.md`: Accepted ADRs (verbatim), conformance audit, owner directives, open decisions (`PD-##`).
- `docs/SCIENTIFIC_INTEGRITY.md`: Scientific issue register (`SI-###`) and calculation register.
- `docs/PROJECT_AUDIT.md`: Point-in-time audit evidence, documentation discrepancy log, rule-conformance matrix. A snapshot: do not edit it to track later changes.

Product intent and process (also read): `docs/PRODUCT_SPEC.md`, `docs/ROADMAP.md`, `docs/TEST_PLAN.md`, `.agents/rules/`.

`docs/archive/` holds superseded documents. They are historical only and are known to be inaccurate; never use them as a source of truth.

## Important Development Rules for Future Claude Agent

1. **Inspect before modifying.**
2. **Never guess about existing code.**
3. **Read relevant files before making architectural claims.**
4. **Prefer minimal changes.**
5. **Avoid unnecessary rewrites.**
6. **Do not introduce new architecture without justification.**
7. **Do not add features outside the current task.**
8. **Do not change working functionality without reason.**
9. **Run appropriate tests after changes.**
10. **Run analyzer/formatter after Dart changes where appropriate.**
11. **Keep business logic testable and separated from UI.**
12. **Keep astronomical calculations deterministic.**
13. **Use explicit units for astronomy calculations.**
14. **Handle UTC/local time carefully.**
15. **Never hardcode external API secrets.**
16. **Do not silently change formulas.**
17. **Scientific assumptions must be documented.**
18. **Never present relative stacking gain as absolute physical SNR.**
19. **User-facing thresholds should be configurable where scientifically appropriate.**
20. **Preserve Git checkpoints.**

## Documentation Conventions (added 2026-09-21)

- **The code is the source of truth for the ACTUAL state.** Design intent (`PRODUCT_SPEC.md`, `ROADMAP.md`, ADRs, Part A of `ARCHITECTURE.md` and `DATA_MODEL.md`) is kept separately and is **never rewritten to match the code**. Where the two differ, record an **IMPLEMENTATION DEVIATION** with: intended behavior, actual behavior, consequence.
- **Status vocabulary:** *Intended / Planned*, *Implemented*, *Partial*, *Prototype*, *Broken*, *Missing*, *Deprecated*, *Unknown*. Do not call a feature Implemented if it does not work, and do not call it Missing if code for it exists. Do not hide identified issues.
- **Stable IDs** are used across documents: `F-##` (features), `TD-###` (tech debt), `SI-###` (scientific issues), `DEV-A/D/P#` (implementation deviations), `PD-##` (open decisions), `OD-##` (owner directives). Reference them; never renumber.
- **When a code change alters the actual state**, update in the same change: `FEATURE_STATUS.md`, `TECH_DEBT.md` (mark items resolved with date and commit — do not delete them), Part B of `ARCHITECTURE.md` / `DATA_MODEL.md`, `SCIENTIFIC_INTEGRITY.md` for any calculation, and `DECISIONS.md` for any formula or architectural decision. Refresh the verification stamp at the top of each file you touch.
- **Record, don't fix on the way.** New findings go into `TECH_DEBT.md` / `SCIENTIFIC_INTEGRITY.md`; do not expand the current task to fix them (rule 7).
- **Source-of-truth documents must be tracked by Git.** Never add `CLAUDE.md` or anything under `docs/` to `.gitignore` (owner directive OD-02).
- **Prior documents are preserved, not deleted.** Superseded material goes to `docs/archive/` with a banner.

## Current Baseline and Known Traps (as of 2026-09-23, after TASK 10.4; TASK 10.5 cut)

**Commands** (prefer `--no-pub` to avoid unintended `pubspec.lock` changes):

- **`dart run tool/check.dart`** — the quality gate: an encoding check (`tool/check_encoding.dart`), `dart format --set-exit-if-changed`, `flutter analyze --no-pub`, `flutter test --no-pub` (format/analyze/test scoped to `lib`/`test`), in one command. Runs all steps regardless of an earlier failure, then prints a pass/fail summary and exits non-zero if any failed. Run this before calling a change complete (TASK 1.3, TD-046; encoding step added TASK 4.3, TD-015).
- `flutter analyze --no-pub` — expected: no issues.
- `flutter test --no-pub` — expected: **584 pass, 0 fail** (green since TASK 1.1; `TD-003` resolved; 83 → 135 in TASK 2.2 → 147 in TASK 2.3 → 152 in TASK 2.4 → 160 in TASK 3.2 → 166 in TASK 3.3 → 179 in TASK 4.1 → 193 in TASK 4.2 → 201 in TASK 4.3 → 205 in TASK 4.4 → 229 in TASK 5.2 → 249 in TASK 5.3 → 268 in TASK 5.4 → 282 in TASK 5.5 → 291 in TASK 5.6 → 299 in TASK 6.2 → 309 in TASK 6.3 → 319 in TASK 6.4 → 327 in TASK 6.5 → 347 in TASK 7.1 → 379 in TASK 7.2 → 404 in TASK 7.3 → 420 in TASK 7.4 → 451 in TASK 8.1 → 463 in TASK 8.2 → 483 in TASK 8.4 → 500 in TASK 8.5 → 511 in TASK 8.6 → 521 in TASK 9.2 → 535 in TASK 9.3 → 547 in TASK 9.4 → 572 in TASK 10.2 → 577 in TASK 10.3 → 584 in TASK 10.4). A failing test is now a regression.
- `dart run tool/check_encoding.dart` — expected: no issues. Every `lib`/`test` `.dart` file must be valid UTF-8 and contain no Cyrillic character (U+0400–U+04FF); this codebase is English-only, so any Cyrillic is almost certainly mojibake (UTF-8 text misread as a single-byte codepage, then re-saved as UTF-8) — this is what TD-015's `Вµm`/`В°`/box-drawing corruption looked like. Do not write a literal mojibake string (even in a test asserting it's absent, or in a comment) — the checker will flag it; describe the character instead.
- `dart format lib test` — expected: no changes (the whole tree was formatted once, TASK 1.3). Formatting is not yet enforced in CI; `tool/check.dart` is the only current gate.
- **After changing Drift tables (TASK 3.2 workflow, `build.yaml` configures it):** dump a new snapshot with `dart run drift_dev schema dump lib/data/database/app_database.dart drift_schemas/`, regenerate verification code with `dart run drift_dev schema generate drift_schemas/ lib/data/database/generated_migrations/ --no-data-classes --no-companions`, regenerate the step shapes with `dart run drift_dev schema steps drift_schemas/ lib/data/database/schema_versions.dart` (TASK 5.3), add the new `fromNToM` step to the `migrationSteps(...)` call in `onUpgrade` — written against the step's own `schema.<table>` shapes, **never** the live tables, and add a migration test in `test/data/database/schema_migration_test.dart` (schema-equality + a data-preservation test). The floor is v8 (`kMinSupportedSchemaVersion`); `onUpgrade` throws `UnsupportedSchemaVersionException` for anything below it or newer than the app, before any statement runs. To change a foreign key's `ON DELETE` action or drop a column, use `Migrator.alterTable(TableMigration(table))` (SQLite can't alter either in place) — pass the step's versioned shape (`schema.captureBlocks`), and list a brand-new column in `newColumns: [...]` (with a `columnTransformer` for its value), or the copy will try to select a column the old table doesn't have. Schema is v15 since TASK 8.5 (v14 in TASK 8.4, v13 in TASK 8.1, v12 in TASK 7.1). Equipment edits must go through `EquipmentProfile.withEditProvenance(original)`; only add a seed whose specs are verified against a primary source (cite it in `equipment_seeder.dart`). Target RA/Dec entered by a user go through `AstroMath.parseRightAscension`/`parseDeclination` (a bare RA number is **hours**) — never `double.parse`; an edit must never change `catalogId` (the repository ignores it on update). Weather (ADR-012): the only path is `WeatherRepository.fetchSnapshot` (UTC `WeatherSnapshot`, nullable values — never default a missing value to 0); the legacy `getCurrentWeather`/`WeatherConditions` were removed in TASK 9.4. The card reads `vm.nightWeatherSummary` (`NightWeatherSummarizer`, pure: sunset to sunrise, ranges, dew heuristic) — no weather arithmetic or good/bad thresholds in widgets, and no score. The night forecast state is `vm.nightWeather` (`NightWeatherService`: cache → fetch → typed states; freshness only via `WeatherFreshness`, never an ad-hoc age check); tests inject `nightWeatherService:` with an in-memory store. Test doubles of `WeatherRepository` mix in `NoSnapshotWeather` (`test/support/`); a fake that serves hours must put them on whole UTC hours, as the provider does (the night starts at mean solar noon, not on the hour). The target catalog is generated — change `tool/build_catalog.dart` and regenerate `assets/catalog/catalog_v2.json` from the pinned OpenNGC release, never hand-edit it; a new catalog must bump `version` and mark new entries' `since`, or deleted targets could come back. The asset is CC BY-SA 4.0: keep `OPENNGC_NOTICE.txt` and the About page in sync.
- Android build/run was **not** verified.

**Testing rule:** `.agents/rules/03-testing.md` can be satisfied literally again (`DEV-P8` resolved 2026-09-21). Investigate any failure as a regression; do not delete or weaken a test.

**Owner directives currently in force** (`docs/DECISIONS.md` Part C):

- **Scope = `docs/MASTER_ROADMAP.md`** (approved 2026-09-21, OD-06). Work one roadmap TASK per cycle, in order: READ → VERIFY → PLAN → IMPLEMENT → TEST → REVIEW → COMMIT → STOP. Never start the next task on your own; do not change the roadmap without owner approval; do not re-audit the whole repository. The current position is the "active task" line in `docs/ROADMAP.md` ("Adopted plan").
- OD-03 (no new feature, specifically not `SessionNight`, before the docs are reconciled and the roadmap exists) has its condition met; `SessionNight` is roadmap group G2 and starts only when the roadmap reaches it and the owner gives the go-ahead.
- Do not fix application code or scientific issues as part of documentation tasks; record them (OD-04).
- Multi-file, architectural, database, or scope-affecting work: inspect, report a plan, wait for approval (`.agents/rules/00-project-governance.md`).
- **`PD-06` resolved 2026-09-21** (`docs/DECISIONS.md` E.1): the logbook and text sharing stay visible; metadata import is hidden until G17, the light-pollution map card until TASK 7.4, the field-mode toggle until TASK 12.4. **Enforced since TASK 4.3** (`TD-014` resolved): every entry point reads `FeatureScope` — flip the flag there, never gate the same feature a second way at the call site. Do not extend these ahead-of-phase features.

**Traps that will bite (all verified):**

1. `EquipmentProfile.id` is an **optical-rig id**; storage is normalized (Device → CameraModule → OpticalRig) but the domain/UI model is flat — kept flat for 1.0 by ADR-011; the dormant catalog repository is gone and the tracking type is visible (TASK 8.4). **RESOLVED (TASK 3.3):** the `equipment_profiles` table is dropped entirely (not just orphaned) and foreign keys are enforced on every connection (`beforeOpen` sets `PRAGMA foreign_keys = ON`); `camera_modules.device_id`/`optical_rigs.camera_module_id` are `ON DELETE RESTRICT`, `capture_blocks.session_log_id` is `ON DELETE CASCADE`; `DriftEquipmentRepository.deleteEquipment` checks for other references before deleting a shared camera module or device. Migrations are guarded and snapshot-tested (TASK 3.2/3.3, ADR-008): the floor is v8, `onUpgrade` refuses anything below it or newer than the app before touching the file, the v8→v9 and v9→v10 steps are staged and run inside one transaction, and the v9→v10 step also runs a one-time orphan cleanup (`PRAGMA foreign_key_check`, delete + log) before rebuilding the three tables above and dropping `equipment_profiles`. Schema is now v10; the legacy `bit_depth`/`optical_multiplier` columns upgraded databases used to carry are gone too.
2. **RESOLVED (TASK 2.4).** `PlannerViewModel.sessionNight` now resolves a real `SessionNight` — `SessionNightResolver.resolveDefault(_clock.nowUtc(), ...)` by default, `.forEveningDate(...)` for a picked `CalendarDate` — instead of the old `_sessionDate = DateTime.now().toUtc()` (`TD-001`, resolved). `home_screen.dart`, `sky_darkness_widget.dart`, `altitude_chart_widget.dart` and `logbook_screen.dart` all consume it, through one `NightTimeFormatter` (`lib/presentation/shared/`) with no ad-hoc `.toLocal()` elsewhere. `sessionNight`/`eveningDate` are `null` without a site — Home shows a "No site set" state instead of the silent default-London astronomy (ADR-007 §9, SI-008). Since TASK 10.2 imaging windows come from `vm.imagingOpportunity` (`ImagingOpportunityCalculator`, ADR-013: gates, reasons, annotations, no score) — `vm.visibilityWindows` and the fit derive from it; never compute windows or reasons elsewhere, and never let unknown data exclude time. Home renders it through `TonightOpportunityWidget` (chart + list from the same object, wording in `OpportunityText`); there is no sky warning or culmination "max altitude" any more (ADR-013 §6). Many targets go through `CandidateEvaluator` (shared `SunTrack`/`MoonTrack`, same calculator — keep the batch equal to the single-target view; a test enforces it); `vm.tonightCandidates()` runs it with `Isolate.run`, so pass only plain values into the closure, never `this`, and widget tests must wait for it with `tester.runAsync`. Since TASK 6.2 every target altitude goes through `VisibilityCalculator.calculateTargetAltitude` (J2000 → date precession, airless) — never compute a target's altitude from its raw J2000 RA/Dec; since TASK 7.1 a site's IANA zone (`LocationProfile.timeZoneId`, `IanaTimeContext`) drives the night and the display — pass `vm.displayZoneId` to `NightTimeFormatter`; without a zone, times are labelled as the device zone. **A map pick or GPS fix is transient** (remembered in preferences) and must never be written into a saved site; only explicit user edits change sites. Never derive a night from a `DateTime`'s Y/M/D, and never call `DateTime.now()` in `lib/domain` (a test enforces this) — use the injected `Clock` instead.
3. **RESOLVED (TASK 8.4, ADR-011).** Equipment fields carry units (`focalLengthMm`, `focalRatio`, `pixelPitchUm`, …); the DB column `optical_rigs.aperture` holds the focal ratio N — never reinterpret stored values; N > 32 is flagged for review (`needsApertureReview`). Aperture input goes through `resolveAperture` (N = f / D), bounds through `EquipmentLimits`.
4. **The capture budget lives in `CaptureBudgetCalculator` (ADR-009, TASK 5.4)** — never add budget arithmetic to a ViewModel; `vm.captureBudget` exposes the whole breakdown and `vm.fitAnalysis` (`FitAnalyzer`, TASK 5.5) the fit — placement is atomic, so never compare sums of windows, and `estimatedRequiredTime` is the **window load** (lights + in-window calibration), not the whole session. Relative stacking gain is √N of light frames only; the UI label still says "Relative SNR" (`TD-009`). NPF follows Michaud's primary source since TASK 6.5 (explicit k) and is shown since TASK 8.6 per PD-11 — only through `vm.rigCapability` (`CapabilityCalculator`: field-minimum |δ|, k from `PlanningPreferences.npfK`, untracked or "if untracked"); exposure guidance never blocks a plan.
5. **Planning thresholds live in `PlanningPreferences` (TASK 5.2)** — read `vm.planningPreferences`, change them with `vm.setPlanningPreferences(...)`; never add a SharedPreferences call to a ViewModel (a test enforces this). Persistence goes through `PlanningPreferencesRepository` / `PlannerStateRepository` (optional constructor arguments, SharedPreferences-backed by default, same keys as before). `PlannerViewModel` starts `_init()` from its constructor; await it with `vm.ready` (TASK 1.1). Seeding no longer races it — `main.dart` awaits both seeders before `runApp` (TASK 1.2). A bootstrap failure sets `hasBootstrapError` (retry via `retryBootstrap()`) instead of throwing unguarded; weather loads after the first frame, not as part of `ready`, and a failure sets `weatherError` rather than blocking or throwing (TASK 1.2). GPS goes through the injected `LocationService` (a sealed `LocationResult`: found, or unavailable with `serviceDisabled`/`permissionDenied`/`permissionDeniedForever`) and place names through the injected `ReverseGeocoder` (TASK 7.2; default `NominatimReverseGeocoder`, rate-limited and cached — never import `package:http` or `package:geolocator` in presentation/domain, a test enforces it), so tests must pass a `FakeLocationService` (`test/support/`), or they will reach the real plugin; pass a `FakeReverseGeocoder` to keep a test off the network. Since TASK 7.3 startup never asks for GPS (owner decision): the first run shows a site prompt, and sites are managed through `vm.sites`/`selectSite`/`saveSite`/`deleteSite` — screens must not call `LocationRepository` directly. Pass a `FakeDeviceTimeZone` (`test/support/`) in tests; the real one is a platform plugin. `IanaTimeContext` uses the `latest_all` data set on purpose (device link zones such as `Europe/Ljubljana`); do not switch back to `latest_10y`.
6. **RESOLVED (TASK 7.4, PD-05).** The light-pollution scraper is deleted (a test fails if scraping code or a network call on a location change comes back). Sky darkness is user-entered Bortle and/or SQM with source and date, read through `vm.skyDarkness`, or unknown — never a default, and never converted Bortle↔SQM. The external map link is `LightPollutionMapLink.at(lat, lon)`.
7. **RESOLVED (TASK 4.3).** `FeatureScope.fieldMode`/`metadataImport` are `false` and `lightPollutionContext` is `true` since TASK 7.4, matching PD-06's schedule; `logbook` stays `true`. Every entry point reads it — Home's field-mode toggle, Import Metadata button and light-pollution map card, plus `app_router.dart`'s route registration and `sky_darkness_widget.dart`'s Bortle badge (`TD-014`, DEV-P1 resolved). The map card's coordinates are still hard-coded Slovenia (F-34) — fixing that is TASK 7.4's job, out of 4.3's scope.
8. Unknown data must not be shown as zero or a default (`SI-008`).
9. Drift row classes share names with domain models; repositories import domain classes `as domain`.
10. `AppRouter.router` is a static singleton; `Provider<AppDatabase>` is registered but never read.

# Project Instructions

## Project

Flutter/Dart mobile application for astrophotography session planning.

The product is centered around:

Site → Target → Astronomical Conditions → Weather → Equipment → Imaging Opportunity → Capture Plan → Execution → Logbook.

The application is not intended to replace Stellarium, Stargazing Hub, or dedicated telescope-control software.

## Development Philosophy

Inspect first. Plan second. Implement third. Verify fourth.

Prefer the smallest correct change.

Do not rewrite working systems without a demonstrated reason.

Do not add speculative abstractions or features.

Do not modify unrelated files.

Do not silently change product behavior.

## Architecture

Keep astronomical/domain calculations separate from UI.

Business logic must be deterministic and testable.

Do not place non-trivial astronomy or capture calculations directly inside widgets.

Use explicit units for astronomy calculations.

Be careful with UTC, local time, time zones, and DST.

## Product Constraints

The central product concept is the connection between:

available astronomical opportunity

and

realistic image-capture execution.

Important concepts:

- Astronomical Darkness

- Target Visibility Window

- Environmental Conditions

- Imaging Opportunity

- Integration Time

- Acquisition Time

- Total Session Budget

Do not treat arbitrary thresholds as universal scientific laws.

## SNR

sqrt(N) may be used as a relative statistical stacking-gain approximation.

Do not represent relative stacking gain as absolute physical SNR.

Do not claim that ISO increases photon collection.

Document assumptions behind scientific calculations.

## Scope Control

Do not implement:

- planetarium engines;

- 3D sky simulation;

- telescope hardware control;

- ASCOM/INDI integration;

- social features;

- authentication;

- cloud infrastructure;

unless explicitly requested.

## Testing

After modifying business logic:

- run relevant unit tests;

- run flutter analyze;

- run relevant widget/integration tests when applicable.

Do not remove tests merely to make a task pass.

## Git

Keep changes small and reversible.

Create meaningful checkpoints.

Never use destructive commands such as:

- git reset --hard

- force push

- deleting unknown user files

without explicit approval.

## Source of Truth

Read these files before making major architectural decisions:

- docs/PROJECT_HANDOFF.md

- docs/ARCHITECTURE.md

- docs/FEATURE_STATUS.md

- docs/DATA_MODEL.md

- docs/TECH_DEBT.md

- docs/DECISIONS.md

- docs/SCIENTIFIC_INTEGRITY.md

- docs/PROJECT_AUDIT.md

The repository is the source of truth for implementation.

If documentation and implementation disagree, investigate and update the documentation rather than guessing.

Design intent is preserved separately from the actual state: never rewrite intent to match the code; record an IMPLEMENTATION DEVIATION instead.
