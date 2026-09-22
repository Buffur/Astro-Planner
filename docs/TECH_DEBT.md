# AstroPlan Technical Debt Register

> **Verification stamp:** verified against code at commit `900b82a` (2026-09-20),
> audited 2026-09-21. Application code changed since by TASK 1.1 (commit `2357755`:
> `LocationService` seam, `PlannerViewModel.ready`, test harness), TASK 1.2 (commit
> `2e17093`: deterministic bootstrap, Home empty/error states), and TASK 1.3 (commits
> `94acd71` whole-tree format, `97924a0` quality-gate script and CI). **TASK 2.2
> (2026-09-22):** a pure-domain `SessionNight` resolver, `SiteTimeContext` and `Clock`
> were added (progress on TD-001, TD-020 and TD-037; none resolved). **TASK 2.3
> (2026-09-22, commit `de1792a`):** the calculators and the altitude chart consume
> `SessionNight`, resolving TD-023 and TD-024; the ViewModel and `sky_darkness_widget.dart`
> still use the deprecated DateTime-based wrappers (TASK 2.4). **TASK 2.4
> (2026-09-22, commit `1e58fcf`):** the ViewModel resolves a real `SessionNight`
> (default = the window containing "now", via an injectable `Clock`), resolving
> TD-001; `sky_darkness_widget.dart` consumes the typed `NightTimeline?` from TASK
> 2.3 instead of the deprecated wrapper. **TASK 3.1 (2026-09-22, docs only):** ADR-008
> decides the direction for TD-004, TD-005 and TD-026 (floor v8, snapshots, FKs, v10
> cleanup) and adds TD-047 (unguarded downgrade); nothing resolved. **TASK 3.2
> (2026-09-22, commit `3c25e8c`):** implements ADR-008's floor and downgrade guards,
> transactional migrations, schema snapshots and a migration test suite; resolves
> TD-004 and the app-database half of TD-047 (the bootstrap-UI half stays open).
> **TASK 3.3 (2026-09-22, commit `e580d03`):** implements ADR-008 §4–§5 — the v10
> migration cleans up orphans, rebuilds `camera_modules`/`optical_rigs`/`capture_blocks`
> with real `ON DELETE` actions, and drops `equipment_profiles`; `beforeOpen` turns
> foreign keys on for every connection. Resolves TD-005 and part of TD-026 (the
> unconditional-delete half; `EquipmentCatalogRepository`/`trackingState` stay open).
> **TASK 4.1 (2026-09-22, commit `f5b29cc`):** removes the doubled reorder-index
> adjustment, adds Form validators and an edit dialog to the capture-plan widget,
> and replaces the position-dependent list key with `ObjectKey`. Resolves TD-010
> and part of TD-012 (binning/gain exposure stays open).
> **TASK 4.2 (2026-09-22, commit `7641d49`):** `addLog` returns the new row's id
> and `markSessionSaved` tracks it so a second Save updates instead of
> duplicating; `refreshSelectedTarget`/`refreshSelectedEquipment` clear or pick
> up a stale selection; the logbook orders newest-first and confirms before
> deleting. Resolves TD-028, the duplicate-save half of TD-011, and the
> order/confirmation half of TD-039 (undo stays open).
> **TASK 4.3 (2026-09-22, commit `576c069`):** fixes seven mojibake spots and
> adds `tool/check_encoding.dart` to the quality gate; `FeatureScope.metadataImport`
> now matches PD-06, and Home's field-mode toggle/Import Metadata button/
> light-pollution map card each read `FeatureScope`. Resolves TD-014 and TD-015.
> **TASK 4.4 (2026-09-22, commit `514dcc5`):** renames the stacking-gain label,
> makes `estimateStorageRequirement` return null (not 0.0) when the average RAW
> size is unknown, renders unknown pixel scale as "Unknown", removes the RA/Dec
> `(0, 0)` unset sentinel, labels the seeded plan "Example plan" until edited,
> neutralizes the sky-warning wording, and fixes the seeded telescope stub's
> aperture and the unsourced "≥1 mag" comment. Resolves TD-009 and TD-013;
> partially resolves TD-008 (seed value only) and TD-042 (the "≥1 mag" item
> only).
> **TASK 5.1 (2026-09-22, docs only):** ADR-009 decides the direction for TD-022
> (capture-budget semantics); nothing resolved.
> **Resolved so far (2026-09-21–22):** TD-001 (TASK 2.4), TD-004 (TASK 3.2), TD-005
> (TASK 3.3), TD-009, TD-010 (TASK 4.1), TD-013, TD-014, TD-015 (TASK 4.3),
> TD-028 (TASK 4.2),
> TD-041 (TASK 0.2), TD-003 (TASK 1.1), TD-046 (TASK 1.3), TD-023, TD-024
> (TASK 2.3), and largely TD-002 (TASK 1.2), TD-047 (TASK 3.2), TD-026 (TASK 3.3),
> TD-012 (TASK 4.1), TD-011, TD-039 (TASK 4.2), TD-008, TD-042 (TASK 4.4, partially), and parts of TD-019, TD-037
> (TASK 1.1) and TD-030, TD-031
> (TASK 0.3). Every other item
> is still Open. Items marked
> *(verified)* were reproduced
> by executing code; *(code reading)* means inferred from source and not executed.
> Directions are **proposals** for the Master Development Roadmap, not approved
> work; size tags are rough estimates: [S] hours, [M] days, [L] a week or more.
> **TASK 5.2 (2026-09-22):** planning preferences (`PlanningPreferences` + repository) and a Settings screen; the planner selection state moved behind `PlannerStateRepository`; `PlannerViewModel` no longer imports SharedPreferences. TD-043 resolved; TD-033 partly; DEV-A1 partly (persistence out of the ViewModel).

## How to read this register

- **ID** is stable and referenced by other documents (`TD-###`). Scientific issues
  are `SI-###` in `docs/SCIENTIFIC_INTEGRITY.md`; implementation deviations are
  `DEV-###` in their home documents; open decisions are `PD-##` in
  `docs/DECISIONS.md`; features are `F-##` in `docs/FEATURE_STATUS.md`.
- **Severity**
  - **Critical** — wrong answers on the product's core path, data loss/crash risk,
    or breach of an accepted scientific-integrity rule.
  - **High** — user-visible defect, blocked foundation, or missing safety net.
  - **Medium** — maintainability, robustness, or partial-feature gaps.
  - **Low** — hygiene and polish.
- Status of every item below is **Open** unless stated.

---

## Critical

| ID | Title and evidence | Impact | Direction (proposal) | Related |
| --- | --- | --- | --- | --- |
| TD-001 | **RESOLVED 2026-09-22 (TASK 2.4, commit `1e58fcf`; suite 152/152).** *(Was: default session night is the UTC calendar date.)* `_sessionDate = DateTime.now().toUtc()` (`planner_viewmodel.dart:36`) fed `calculateNightTimeline` / `calculateVisibilityWindows`, which read Y/M/D as the local solar date; at 18:30 PDT the app reported the next sunset 24.0 h late and the header showed tomorrow. *Done:* `PlannerViewModel.sessionNight` now resolves through `SessionNightResolver.resolveDefault(_clock.nowUtc(), ...)` (default) or `.forEveningDate(...)` (picked); `newSession()` clears the picked date back to the default instead of re-setting a fixed UTC `DateTime`. Verified by a ViewModel test and a Home widget test, both using the ADR-007 T1 case (San Francisco, 18:30 PDT on 2026-09-21 = 2026-09-22 01:30 UTC): `eveningDate == CalendarDate(2026, 9, 21)`, not the 22nd. The old defect-asserting test ('sessionDate defaults to today (UTC)') is replaced, with the reason recorded in the test file's header comment | Done; see above | SI-010, F-09, F-10, PD-01, PD-02 |
| TD-002 | **Non-deterministic startup and Home dead-end.** Seeding is unawaited after `runApp` (`main.dart:53-60`); `_init()` is started from the constructor and awaits network weather (`planner_viewmodel.dart:123` before `:126`), with an unguarded `unawaited(useCurrentLocation())` (`:74`); Home's empty state offers no route to `/target` or `/equipment` (`home_screen.dart:54-70`). *(verified)* with zero event-loop turns the ViewModel read `target=null equipment=null`; the empty Home had only four app-bar icons. **Progress 2026-09-21 (TASK 1.1, `2357755`):** `_init()` is awaitable via `PlannerViewModel.ready` and location access goes through an injectable `LocationService`. **RESOLVED 2026-09-21 (TASK 1.2):** `main.dart` now awaits both seeders before `runApp` (idempotent, so a failure is safe to retry next launch); weather loads after the first frame via `SchedulerBinding.addPostFrameCallback`, so it is off `_init()`/`ready` and can no longer block the first screen; a bootstrap failure sets `hasBootstrapError` (surfaced with a retry view) instead of leaving the DB/prefs reads unguarded; Home's empty state now offers "Choose a Target" / "Choose Equipment" buttons. **Still open:** the startup `unawaited(useCurrentLocation())` still has no try/catch around an unexpected (not just denied) platform exception; `setLocation()` (a user-initiated action, not the bootstrap path) still awaits its own weather fetch before returning. On-device timing unverified | First launch can show a dead-end screen; a slow network blocks the first screen up to 10 s; GPS exceptions are unhandled. On-device timing unverified | Awaitable initialization; seeding complete before the first read; no network on the critical path; empty-state navigation; guarded location access [M] | DEV-A1, DEV-A5, F-05, TD-003 |
| TD-004 | **RESOLVED 2026-09-22 (TASK 3.2, commit `3c25e8c`; suite 160/160).** *(Was: the v5 step referenced `optical_multiplier`, removed from the definitions in `900b82a`; verified v3 → v9 threw `table optical_rigs has no column named optical_multiplier`; no migration tests or schema snapshots.)* *Done:* the v1–v7 steps are deleted (ADR-008 §2: floor v8, no installs below v8 need preserving, owner-confirmed); `onUpgrade` now has exactly one supported path (v8 → v9) behind a floor guard and a downgrade guard (TD-047) that both throw `UnsupportedSchemaVersionException` before any statement runs; that one step runs inside `m.database.transaction(...)`, verified atomic by a test that injects a mid-step failure. Drift schema snapshots exist for v8 (dumped from `d0b737f`) and v9, with generated verification code and an 8-test migration suite (`test/data/database/schema_migration_test.dart`) covering a fresh install, v8→v9 data preservation (device/module/rig chain, target, location, session + blocks, `equipment_profiles` empty and non-empty), the floor guard, the downgrade guard, the reset path, and the transaction-atomicity check. **Still open:** the reset path's file rename is implemented (`resetUnsupportedDatabaseFile`) but nothing calls it — no bootstrap confirmation UI exists yet, so a real below-floor install still just gets a thrown exception, not a guided reset; the leftover legacy columns (`optical_multiplier` ×2, `bit_depth`) are untouched — dropping them is TASK 3.3 | Done; see above | DEV-D1, F-02, PD-04 |
| TD-006 | **Light-pollution fetch can never succeed; silent Bortle default.** URL contains a literal `\${lat…}` (`light_pollution_repository.dart:8`); *(verified)*. Scrapes a third-party HTML page; not injectable, no interface, no tests. The Bortle badge is hidden (`sky_darkness_widget.dart:32`) so no path sets Bortle; default is 4 (`planner_viewmodel.dart:41`); `_fetchBortle` still runs on every location change | Bortle is never obtained; the Bortle half of the sky warning is unreachable; a failing request is made on each location change; ToS/fragility risk | Decide PD-05; remove or replace the scraper; represent unknown end-to-end [M] | SI-007, F-32, F-33, PD-05 |
| TD-007 | **NPF formula deviates from the published formula; the test is circular.** Constant `+ 90.0` replaces `0.1·F` (`optical_calculator.dart:87`); expected value in the test derives from the same constant. *(verified)* ratios 2.88 (phones) to 0.72 (2000 mm) | Wrong exposure recommendation if ever surfaced (currently unsurfaced) | SI-001 actions: confirm constants from the primary source, fix with citation, independent test values, K explicit, do not surface before then [S] | SI-001, F-26, PD-11 |
| TD-009 | **RESOLVED 2026-09-22 (TASK 4.4, commit `514dcc5`) for the label.** *(Was: "Stacking Gain (Relative SNR)" label, `capture_plan_widget.dart:215`, restored on purpose in `1baa514`.)* The label is now "Relative stacking gain (√N vs one frame)"; "SNR" no longer appears in `lib/`. **Still open:** gain ignores sub-exposure length; assumptions are not documented in a UI help text; `gainIso` is still free text and ISO-as-sensitivity wording is not otherwise addressed | Gain-across-exposure-length and ISO wording remain open in user-facing text | Document assumptions; avoid ISO-as-sensitivity wording [S] | SI-003, SI-004, DEV-P2, F-37 |

## High

| ID | Title and evidence | Impact | Direction (proposal) | Related |
| --- | --- | --- | --- | --- |
| TD-003 | **RESOLVED 2026-09-21 (TASK 1.1, commit `2357755`; suite 73/73, three consecutive green runs).** *(Was:)* **`integration_flow_test.dart` fails — root cause corrected.** *(verified)* The ViewModel is created in `setUp` outside the fake-async zone so `_init()` never advances; the spinner never settles and `pumpAndSettle` times out (`test/integration_flow_test.dart:99`). A second cause is an unhandled `MissingPluginException` from `Geolocator` (`planner_viewmodel.dart:74`). HTTP is **not** involved (weather is mocked) | Red suite; ambiguous signal on every run | *Done:* the ViewModel is built and awaited (`ready`) inside `tester.runAsync`; device location is injected through `LocationService`; the test was repaired, not weakened, and its RA fixture (hours in a degrees field) was fixed [S–M] | DEV-A1, DEV-P8, F-48 |
| TD-005 | **RESOLVED 2026-09-22 (TASK 3.3, commit `e580d03`; suite 166/166).** *(Was: `PRAGMA foreign_keys = 0`; an orphan `capture_blocks` row was inserted successfully; `equipment_profiles` read by nothing but a test.)* *Done (ADR-008 §4–§5):* the v10 migration step runs `PRAGMA foreign_key_check`, deletes every flagged row (logging the count per table), rebuilds `camera_modules`/`optical_rigs`/`capture_blocks` via `Migrator.alterTable` to add real `ON DELETE RESTRICT`/`RESTRICT`/`CASCADE` actions (SQLite can't alter a foreign key's action in place), and drops `equipment_profiles`. `beforeOpen` now sets `PRAGMA foreign_keys = ON` for every connection, not just upgraded ones. `DriftEquipmentRepository.deleteEquipment` checks for other rigs/modules referencing a row before deleting it, since a RESTRICT violation would otherwise throw. Verified by tests: an orphan insert throws, deleting a session cascades to its blocks, deleting a referenced device is refused, and a pre-existing orphan (an optical rig pointing at a missing camera module, and a capture block pointing at a missing session — the exact case this item verified) is cleaned up during the v10 migration itself | Done; see above | DEV-D6, F-23, PD-04 |
| TD-008 | **Seed and equipment data errors.** **RESOLVED 2026-09-22 (TASK 4.4, commit `514dcc5`) for the aperture value only:** ZWO seed `aperture` is now `400.0 / 72.0` (f/5.6), not `72.0` in the f-number field. **Still open:** sensor sizes inconsistent with resolution × pitch (Xiaomi/Vivo −10.5 %); no `averageRawFileSizeMB`; unverified specs; provenance only in a comment | Visible wrong values; wrong NPF input; untraceable data | SI-005 and SI-011 actions; verify specs against primary sources; PD-09, PD-10 [M] | SI-005, SI-011, DEV-D5 |
| TD-010 | **RESOLVED 2026-09-22 (TASK 4.1, commit `f5b29cc`; suite 179/179).** *(Was: `onReorderItem` passes an already-adjusted index but `reorderCaptureBlocks` still applied `newIndex -= 1`, so blocks dragged down landed one slot short.)* *Done:* the extra adjustment is removed; `reorderCaptureBlocks` now uses `newIndex` exactly as `onReorderItem` provides it. Verified by 6 ViewModel tests covering every reorder direction (down one slot, down to the end, up one slot, up to the start, and a middle-to-end case) plus the `notifyListeners()` call | Done; see above | F-35 |
| TD-011 | **RESOLVED 2026-09-22 (TASK 4.2, commit `7641d49`; suite 193/193) for the duplicate-save half.** *(Was: `addLog` returned `void` so the ViewModel never learned the id; verified two taps → two rows.)* *Done:* `addLog` returns the new row's id; `PlannerViewModel.markSessionSaved` records it as the active session (on both the insert and the update path), so a second Save tap updates the same row instead of inserting another. Verified by a widget test that taps Save twice and asserts one row. **Still open:** no snapshot — location, temperature, focal length and integration stay null; stable references (DEV-D3) — both out of TASK 4.2's roadmap scope (deferred to 11.3) | Fill snapshot fields; stable references (DEV-D3) [M] | DEV-D3, F-40 |
| TD-012 | **Resolved in part 2026-09-22 (TASK 4.1, commit `f5b29cc`; suite 179/179).** *(Was: empty/invalid input became 60 s × 30; negatives accepted; no edit UI, `updateCaptureBlock` unused.)* *Done:* the add/edit dialog now runs through a `Form` with validators (exposure must parse as a positive number, frame count must parse as a whole number ≥ 1) that block submission instead of silently defaulting; tapping a block opens the same dialog pre-filled, calling the previously-unreachable `updateCaptureBlock`. **Still open:** binning and gain/ISO are not exposed in the UI — out of TASK 4.1's roadmap scope | Users cannot record a non-default binning or gain/ISO for a block | Expose binning and gain/ISO fields in the dialog [S] | SI-008, F-35 |
| TD-013 | **RESOLVED 2026-09-22 (TASK 4.4, commit `514dcc5`) for storage, pixel scale, the default plan and the RA/Dec sentinel.** *(Was, verified: storage showed `0.0 MB` for all seeded gear; `null arcsec/px` (`home_screen.dart:104`); default plan shown as if user-chosen; RA/Dec `(0, 0)` used as an "unset" sentinel.)* `estimateStorageRequirement` now returns null when unknown and the UI shows "Unknown"; pixel scale shows "Unknown" when null; the Sequence Plan header carries an "Example plan" badge until edited; the `(0, 0)` sentinel is removed from `currentAltitude`/`maxAltitude` and the target edit dialog. **Still open:** the default London location is shown silently until a real site is set (unrelated to the "unknown vs default" numbers issue; see SI-008's GPS-default-location case) | Misleading numbers | Nullable values and explicit "unknown" UI (SI-008 rule) [M] | SI-008, SI-013, F-28 |
| TD-014 | **RESOLVED 2026-09-22 (TASK 4.3, commit `576c069`; suite 201/201).** *(Was: `fieldMode` never read; map handoff ungated with hard-coded Slovenia coordinates; Home pushed gated routes unconditionally; `metadataImport`/`logbook` were `true` without a recorded approval.)* *Done:* `FeatureScope.metadataImport` now reads `false`, matching PD-06 (`fieldMode`/`lightPollutionContext` were already correctly `false`). Home's field-mode toggle, Import Metadata button and light-pollution map card are each wrapped in `if (FeatureScope.*)`, matching the pattern `app_router.dart` (route registration) and `sky_darkness_widget.dart` (Bortle badge) already used — one source, checked everywhere. Verified by tests that a gated feature has no icon/tooltip/card/route while the still-visible logbook keeps its. The map's hard-coded Slovenia coordinates stay wrong (F-34) — that's TASK 7.4's job, not this one's | Done; see above | DEV-P1, F-04, F-34, F-46 |
| TD-017 | **Weather robustness and semantics.** Not date-aware; hourly array starts at local midnight; timestamps naive (`open_meteo_weather_repository.dart:47`), `utc_offset_seconds` discarded; cache has no staleness limit or indicator; parser assumes non-null arrays (fine for the live London query); model hard-coded (`:22`); no provenance; startup waits on it | Wrong-night/zone alignment; stale data shown as current | PD-02, PD-15; date-aware fetch; staleness indicator [M] | F-29, F-30, PD-15 |
| TD-019 | **`PlannerViewModel` is a 513-line multi-responsibility class that breaks layering** (DEV-A1): `http`, `geolocator`, `shared_preferences`, concrete `LightPollutionRepository`; un-awaitable constructor init; getters recompute on every access. **Progress 2026-09-21 (TASK 1.1, `2357755`):** `geolocator` is no longer imported by the ViewModel (device location is behind `LocationService`) and init is awaitable via `ready`; `http`, `shared_preferences` and the concrete `LightPollutionRepository` remain | Untestable, hard to change, defects cluster here | Extract only along seams created by TD-002/TD-022/TD-020 work; incremental, test-first; no big-bang rewrite [L] | DEV-A1, ARCHITECTURE D2 |
| TD-020 | **No site/time model.** Times shown in the device zone; naive weather times; no site time zone (`sky_darkness_widget.dart:137`). *Progress 2026-09-22 (TASK 2.2): a domain `SiteTimeContext` seam exists (mean-solar and fixed-offset contexts, ADR-007 §6), unused by the app; the per-site zone is TASK 7.1* | Remote-site planning wrong; DST/zone bugs | PD-02; site time model in the domain [M] | SI-010, F-10 |
| TD-022 | *(Direction decided 2026-09-22: ADR-009 — integration / acquisition / window load / session budget, a calibration policy per block, a sequence-based fit; implementation TASKs 5.2–5.6.)* **Capture budget conflates integration, acquisition, calibration and total session.** `estimatedRequiredTime` sums all block types plus 5 s/frame (`planner_viewmodel.dart:478-484`) against the night window; `SessionCalculator.estimateTotalDuration` (15 % model) is dead and inconsistent; overhead not configurable | The central component cannot answer "what fits tonight?" correctly | PD-08; pure-Dart budget service with tests [M–L] | DEV-A4, F-36, F-39, PD-08 |
| TD-025 | **Test gaps.** No tests for the live budget math, Home, Capture Plan, Sky, Weather, Altitude chart, Logbook, Location or Metadata screens; no migration tests; the NPF test mirrors the implementation; tested code (`estimateTotalDuration`, orphan table, catalog repository) is unused; ViewModel tests cover only the date and min-altitude setters | Regressions undetected | Reference-value tests; ViewModel/widget tests as areas are touched; see `docs/TEST_PLAN.md` [L] | F-48, TD-037 |
| TD-032 | **Moon precision and geometry.** Illumination error up to 4.7 pp shown to 0.1 %; no Moon altitude, rise/set or Moon–target separation (PRODUCT_SPEC MVP); warning ignores Moon altitude | Overstated precision; missing MVP feature | SI-002 actions; PD-07 [L] | SI-002, F-15, F-16, DEV-P6 |
| TD-041 | **RESOLVED 2026-09-21 (TASK 0.2; documentation only, no code change).** *(Was: no active roadmap phase is declared (DEV-P3) while Phases 10–15 features exist.)* | *(Was: no authoritative scope.)* | *Resolution:* the owner adopted `docs/MASTER_ROADMAP.md` as the approved scope (OD-06) and decided PD-06 (`DECISIONS.md` E.1). The gates in the code are still unenforced: TD-014, TASK 4.3 | DEV-P3, PD-06 |

## Medium

| ID | Title and evidence | Direction (proposal) | Related |
| --- | --- | --- | --- |
| TD-015 | **RESOLVED 2026-09-22 (TASK 4.3, commit `576c069`; suite 201/201).** *(Was: mojibake in `equipment_selection_screen.dart` (`Вµm`, `В°`, box-drawing comments) and one comment in `target_selection_screen.dart`; cause unknown, the patch scripts read/write UTF-8.)* *Done:* all seven spots corrected to `µm`/`°`/`—`/`─`. `tool/check_encoding.dart` was added to the quality gate (`dart run tool/check.dart`): every `lib`/`test` `.dart` file must be valid UTF-8 and contain no Cyrillic character (U+0400–U+04FF) — a reliable, low-noise signal for this exact corruption pattern (UTF-8 text misread as a single-byte codepage, then re-saved as UTF-8) in an English-only codebase; verified it actually fails by injecting a probe file with the same character before removing it. The root cause (which editor/tool produced the corruption) is still unknown — only the ongoing detection net was added, not a fix at the source | Done; see above | F-22 |
| TD-016 | **Target model issues:** editing overwrites `catalogId` (`target_selection_screen.dart:175`); RA in degrees (`:130`); moving-object types offered (`:9-20`); no uniqueness/epoch/source/size/magnitude; `(0,0)` sentinel (`planner_viewmodel.dart:445,456`); `LIKE` wildcards not escaped | SI-012 actions; PD-07/PD-16 [M] | SI-012, F-19–F-21 |
| TD-018 | **Metadata import limits:** whole-file `readAsBytes` and `String.fromCharCodes` (`metadata_extractor.dart:8,47`); FITS unreachable via `image_picker`; `/` inside FITS string values truncates them; nothing stored or linked; no real sample files | Verify against real files before expanding (ROADMAP Phase 12) [M] | F-45 |
| TD-021 | **Screens bypass ViewModels** (DEV-A2) | Route through ViewModels when touched [M] | DEV-A2 |
| TD-023 | **RESOLVED 2026-09-22 (TASK 2.3, commit `de1792a`).** *(Was: astronomy pipeline triplicated; logic inside `CustomPainter` (DEV-A3).)* The chart's `_AltitudeChartPainter` no longer imports `astronomical_engine.dart` or calls `VisibilityCalculator`'s raw math; `AltitudeChartWidget.build()` resolves one `SessionNight` and calls the new `VisibilityCalculator.calculateAltitudeCurve` once, and the painter only maps samples to pixels. The chart and the calculators now share one window (same `SessionNight`, same 5-minute grid) instead of the chart's own device-local-noon window. **Still not fully consolidated (2026-09-22, after TASK 2.4):** `PlannerViewModel.currentAltitude`/`maxAltitude` still run their own copy of the JD/GMST/LST/LHA pipeline against `_clock.nowUtc()` rather than the `AltitudeCurve`; TASK 2.4's roadmap scope did not include this consolidation, so it remains open, not scheduled to a specific task | Done; see above | DEV-A3, F-14 |
| TD-024 | **RESOLVED 2026-09-22 (TASK 2.3, commit `de1792a`).** *(Was: stringly-typed night timeline `Map<String, DateTime?>` (`visibility_calculator.dart:85`).)* `NightTimeline` (`lib/domain/models/night_timeline.dart`) is a typed value object: each of the four thresholds is a `SunCrossing`/`SunNeverBelow`/`SunAlwaysBelow`, never a bare null. `VisibilityCalculator.calculateNightTimelineForNight` returns it. **The old `Map<String, DateTime?>`-returning `calculateNightTimeline` still exists**, now as a thin wrapper, since `PlannerViewModel`/`sky_darkness_widget.dart` aren't migrated to the typed version yet (TASK 2.4) | Done; see above | F-12 |
| TD-026 | **Equipment model dormant/orphaned:** `EquipmentCatalogRepository` unused; `trackingState` invisible. *Resolved in part (TASK 3.3, commit `e580d03`):* rig deletion no longer deletes a shared camera module or device unconditionally — `deleteEquipment` now checks for other references first, matching the `ON DELETE RESTRICT` added to `camera_modules.device_id`/`optical_rigs.camera_module_id`. **Still open:** `EquipmentCatalogRepository` unused, `trackingState` invisible | PD-03 [M] | DEV-D2, F-23 |
| TD-027 | **Location handling:** `setLocation` overwrites the active saved profile (`planner_viewmodel.dart:216-255`); `_fetchBortle` reads `activeLocationId` while `setLocation` may still be inserting the row *(code reading)*; silent London default; no saved-location UI | Design saved locations with PD-02/PD-05 [M] | DEV-D4, F-06, F-07 |
| TD-028 | **RESOLVED 2026-09-22 (TASK 4.2, commit `7641d49`; suite 193/193).** *(Was: stale selection after deleting **or editing** the selected target/rig — the ViewModel was never notified.)* *Done:* `PlannerViewModel.refreshSelectedTarget()`/`refreshSelectedEquipment()` re-read the selection by id (null if deleted, updated if edited); called from the target/equipment screens after their edit dialog closes and after a swipe-delete. The "also after a restart" case needed no new code — bootstrap already falls back when a saved selection id no longer resolves, verified directly rather than assumed | Done; see above | DEV-A2 |
| TD-029 | **Silent error swallowing / no error states:** reverse geocoding (`planner_viewmodel.dart:184`), weather (`open_meteo_weather_repository.dart:18,77,91`), metadata parsing (`metadata_extractor.dart:33,81`) and light pollution (`light_pollution_repository.dart:20`) all discard the error and return `null`/nothing; `_init` has no `try/catch` | Surface errors; add states [M] | F-29 |
| TD-031 | **Dependency, platform and legal risks:** `sqlite3_flutter_libs 0.6.0+eol` (verify on device) *(2026-09-21 finding, TASK 0.3, recorded only — not changed: pub.dev marks 0.6.0+eol an end-of-life stub that "no longer does anything" and says it can be removed with `sqlite3` 3.x, locked at 3.5.2; removal deferred until an Android build and device smoke run are verified, G1/G16; the drift setup guide now lists `drift_flutter` for Flutter apps, not evaluated)*; `material_ui 1.3.0` reported as *retracted* by `pub get` (transitive, not investigated); the unused `cupertino_icons` dependency was **removed 2026-09-21** (commit `c8ad208`; analyze clean, tests 70/1 as baseline); OSM tiles without attribution and with a mismatched user-agent (`location_picker_screen.dart:101-102`); Nominatim usage policy; Open-Meteo free tier is non-commercial (verify); iOS `Info.plist` lacks location/photo strings; release signing uses the debug key; `sdk: ^3.13.3`; repository is GPL-3.0 | PD-12; verify before any release [M] | F-50, PD-12 |
| TD-033 | **Hard-coded thresholds and the sky warning** (SI-006): Moon > 0.8 or Bortle ≥ 7; ~~tight margin 85 %; overhead 5 s~~ *(margin and per-frame overhead configurable since TASK 5.2; the sky-warning thresholds remain hard-coded)* | Named, documented, configurable [M] | SI-006, F-18 |
| TD-036 | **Undocumented astronomy simplifications and quantization** (SI-009); stale "refine to 1-minute" comment (`visibility_calculator.dart:103`); no reference-ephemeris tests | Document bounds; add USNO/JPL reference tests [M] | SI-009 |
| TD-037 | **Test determinism — PARTLY RESOLVED 2026-09-21 (TASK 1.1, `2357755`).** *Done:* the real-time `Future.delayed(300 ms)` waits are gone (`await vm.ready`), and location is injectable, so tests no longer need the `activeLocationId` workaround to dodge Geolocator. **Progress 2026-09-22 (TASK 2.2):** an injectable `Clock` exists (`lib/core/time/clock.dart`: `SystemClock`, `FixedClock`), and `lib/domain` no longer calls `DateTime.now()`, which a test guards. **Still open:** the static `AppRouter.router` singleton; the ViewModel and widgets still call `DateTime.now()` inline (TASK 2.4); the Nominatim call and `LightPollutionRepository` are not injectable (they only avoid the real network because the test binding answers HTTP with 400) | Remaining: use the clock in the ViewModel and widgets (TASK 2.4); injectable router [S–M] | DEV-A1 |
| TD-039 | **RESOLVED 2026-09-22 (TASK 4.2, commit `7641d49`; suite 193/193) for order and confirmation.** *(Was: list unordered (oldest first); swipe-delete had no confirmation or undo.)* *Done:* `getAllLogs` now orders newest-saved first (`ORDER BY id DESC`); `LogbookScreen`'s `Dismissible` gained a `confirmDismiss` dialog matching the equipment/target screens' existing pattern. **Still open:** no undo after a confirmed delete | Add undo (e.g. a SnackBar action) [S] | F-41 |
| TD-043 | **RESOLVED 2026-09-22 (TASK 5.2).** *(Was: threshold constants and settings (SI-006): named constants; a settings screen for minimum altitude, darkness limit, overhead, margins, dew.)* Now `PlanningPreferences` (named, documented, clamped defaults) with a Settings screen for minimum altitude, darkness limit (−18/−15/−12°), feasibility margin, dew margin, per-frame overhead and the optional overheads (off = "not included"). The optional overheads are stored but not yet consumed (TASK 5.4) | — | SI-006 |
| TD-046 | **RESOLVED 2026-09-21 (TASK 1.3, commit `97924a0`).** *(Was: no CI configuration exists in the repository.)* `.github/workflows/ci.yml` runs `dart run tool/check.dart` (format check, analyze, test) on push to `main` and on pull requests. **Not yet exercised:** no Git remote is configured, so the workflow has not actually run. Also new: the whole tree was run through `dart format` once (commit `94acd71`); formatting itself is not yet enforced in CI, only the local `--set-exit-if-changed` check inside `tool/check.dart` | Done; see above | F-49 |
| TD-047 | **RESOLVED 2026-09-22 (TASK 3.2, commit `3c25e8c`; suite 160/160) for the app-database guard.** *(Was: schema downgrade is not guarded — Drift calls `onUpgrade` whenever the stored version differs from `schemaVersion`, including when it is higher, and the old `if (from < n)` chain then ran nothing, opening a newer database as if it matched.)* *Done:* `onUpgrade` now checks `from > to` first and throws `UnsupportedSchemaVersionException(isNewerThanApp: true)` before any statement runs; verified by test M7 (`schema_migration_test.dart`) that the file and `user_version` are byte-identical afterwards. **Still open:** nothing surfaces this to the user yet — no bootstrap-level "this app is out of date" message exists; a real downgrade today just throws during database open with no UI handling it | Add a bootstrap-level message for `UnsupportedSchemaVersionException` (both directions) [S] | ADR-008, TD-004 |

## Low

| ID | Title and evidence | Direction (proposal) | Related |
| --- | --- | --- | --- |
| TD-030 | **Repository hygiene — PARTLY RESOLVED 2026-09-21 (TASK 0.3).** *Removed, owner-approved (commit `ef20670`):* the five one-off patch scripts with hard-coded absolute paths (`fix_sensor_size.py`, `patch_bitdepth.py`, `patch_db.py`, `patch_equipment.py`, `patch_target.py`; recoverable from `d0b737f`), the empty `package-lock.json` and the empty untracked `bin/`. **Still open — not approved for removal:** `skills-lock.json` and `.agents/skills/` (third-party Flutter/Dart skills and an unrelated Google ADK skill, `google-agents-cli-adk-code`, referenced only by `skills-lock.json`) | Remove the remaining items only with owner approval (do not delete unknown files without approval) [S] | — |
| TD-034 | **Decorative timeline bar:** a static gradient unrelated to the data (`sky_darkness_widget.dart:153-170`) contradicts `.agents/rules/05-ui-design.md` | Make data-driven or remove [S] | F-12 |
| TD-035 | **Seeding is not idempotent per row:** re-seeds all defaults if the user deletes everything | Track seeded state [S] | F-05 |
| TD-038 | **`analysis_options.yaml`** uses default `flutter_lints` only | Consider stricter rules (`unawaited_futures`, casts) [S] | — |
| TD-042 | **Stale/incorrect comments and artifacts.** **RESOLVED 2026-09-22 (TASK 4.4, commit `514dcc5`) for the "≥1 mag" item only:** the `_minAltitude` doc comment no longer states a specific, unsourced attenuation figure. **Still open:** reverse-geocode comment says "Open-Meteo" but uses Nominatim (`planner_viewmodel.dart:163`); `Earth\\'s` (`astronomical_engine.dart:38`); `frame_type` comment says uppercase but lowercase is stored (`app_database.dart:18`); `pubspec` description is the Flutter default | Correct with the related fix [S] | — |
| TD-044 | **ViewModel API hazards:** `captureBlocks` getter exposes the mutable list; `loadSession` matches by lower-cased name; `setSessionDate` fires `_refreshWeather()` un-awaited; field mode not persisted | Address with TD-019 [S] | DEV-A1 |
| TD-045 | **Name collisions** between Drift row classes and domain models (`SessionLog`, `AstroTarget`, `LocationProfile`, `EquipmentProfile`), worked around with `import … as domain` | Consider Drift `@DataClassName` renames [S] | — |

## Recorded / resolved

| ID | Item | Status |
| --- | --- | --- |
| TD-040 | **Source-of-truth docs were overwritten and then git-ignored.** The Phase 0 design-intent docs were replaced by an "as-is" rewrite; `.gitignore` gained rules ignoring `CLAUDE.md` and six docs | **Resolved 2026-09-21** by this reconciliation: design intent restored in Part A of each doc; the rewrites archived verbatim in `docs/archive/2026-09-21-previous-agent-audit/`; the `.gitignore` rules removed (OD-02) |

---

## Carry-forward map from the previous `TECH_DEBT.md`

| Previous item | Verified verdict | Now |
| --- | --- | --- |
| Failing integration test "because the HTTP client isn't mocked" | **Incorrect diagnosis** | TD-003 |
| ViewModel bloat | **Confirmed, extended** | TD-019 |
| Light-pollution scraping is brittle | **Understated** — it is non-functional | TD-006 |
| Inconsistent capture-overhead math | **Confirmed** | TD-022 |
| Weather repository offline handling | **Confirmed, extended** | TD-017 |
| Geocoding in the ViewModel | **Confirmed** | TD-019 (part of DEV-A1), TD-029 |
| Unified equipment rigs | **Incorrect premise** — storage is already normalized | TD-026 |
| Empty states / custom dashboard | **Reclassified**: dashboard is not in the roadmap (PD-14); the real empty-state defect is the Home dead-end | TD-002, PD-14 |
| Hard-coded error fallbacks (`catch (_)`) | **Confirmed** | TD-029 |

## Dependency notes for roadmap sequencing (proposal)

```text
PD-06 (declare active phase) [resolved 2026-09-21] ───► every roadmap decision
PD-01 + PD-02 ─► TD-001 / TD-020 ─► TD-036 reference tests ─► Imaging Opportunity (F-38)
PD-08 ─► TD-022 ─► capture-planner redesign (F-35..F-39)
TD-002 + TD-003 ─► TD-019 (ViewModel seams) ─► TD-021, TD-028, TD-037
PD-04 ─► TD-004 / TD-005 / TD-026 ─► any schema change (TD-011 stable references, F-42 actuals)
PD-05 ─► TD-006 (Bortle) ─► sky-darkness features
SI-005 + PD-10 ─► TD-008 ─► NPF surfaced only after TD-007
```

## Cleanup candidates (status after TASK 0.3, 2026-09-21)

**Done, owner-approved:** patch scripts, empty `package-lock.json` and empty `bin/`
(`ef20670`); the `GEMINI.md` `.gitignore` entry (`714426d`, PD-13); `cupertino_icons`
(`c8ad208`). **Not touched (need owner approval):** the Google ADK skill and its
`skills-lock.json` entry; `docs/archive/` retention; `sqlite3_flutter_libs` (TD-031).
