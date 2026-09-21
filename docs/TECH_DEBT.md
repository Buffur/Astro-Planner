# AstroPlan Technical Debt Register

> **Verification stamp:** verified against code at commit `900b82a` (2026-09-20),
> audited 2026-09-21. Application code unchanged since.
> **No code defect listed here has been fixed.** One governance item, TD-041, was
> resolved on 2026-09-21 by TASK 0.2 (documentation only). Items marked *(verified)* were reproduced
> by executing code; *(code reading)* means inferred from source and not executed.
> Directions are **proposals** for the Master Development Roadmap, not approved
> work; size tags are rough estimates: [S] hours, [M] days, [L] a week or more.

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
| TD-001 | **Default session night is the UTC calendar date.** `_sessionDate = DateTime.now().toUtc()` (`planner_viewmodel.dart:36`) feeds `calculateNightTimeline` / `calculateVisibilityWindows` (`visibility_calculator.dart:85-90,139-151`), which read Y/M/D as the local solar date. *(verified)* At 18:30 PDT the app reports the next sunset 24.0 h late and the header shows tomorrow; Berlin is correct. No test covers a western longitude | The central question ("what can I photograph tonight?") is answered for the wrong night for evenings west of UTC, and after-midnight sessions in the Americas | Decide PD-01 and PD-02, then define the session night in the pure-Dart domain with regression tests (Americas evening, after-midnight, date line, DST, high latitude) [M]. **Proposed first implementation task once the roadmap is approved** | SI-010, F-09, F-10, PD-01, PD-02 |
| TD-002 | **Non-deterministic startup and Home dead-end.** Seeding is unawaited after `runApp` (`main.dart:53-60`); `_init()` is started from the constructor and awaits network weather (`planner_viewmodel.dart:123` before `:126`), with an unguarded `unawaited(useCurrentLocation())` (`:74`); Home's empty state offers no route to `/target` or `/equipment` (`home_screen.dart:54-70`). *(verified)* with zero event-loop turns the ViewModel read `target=null equipment=null`; the empty Home had only four app-bar icons | First launch can show a dead-end screen; a slow network blocks the first screen up to 10 s; GPS exceptions are unhandled. On-device timing unverified | Awaitable initialization; seeding complete before the first read; no network on the critical path; empty-state navigation; guarded location access [M] | DEV-A1, DEV-A5, F-05, TD-003 |
| TD-004 | **Migration chain untested and partly broken.** The v5 step references `optical_multiplier` (`app_database.dart:92-95`), removed from the definitions in `900b82a`; *(verified)* v3 → v9 throws `table optical_rigs has no column named optical_multiplier`; v8 → v9 works. No migration tests or schema snapshots; upgraded databases keep legacy columns that fresh installs lack | Databases below v5 cannot be opened; other old paths (`from < 2` then `< 7`; `from < 4` then `< 9`) look likely to fail *(code reading)*; schema drift between installs | Decide PD-04 (repair vs declare v9 the floor); adopt Drift schema snapshots + migration tests before any further schema change [M] | DEV-D1, F-02, PD-04 |
| TD-006 | **Light-pollution fetch can never succeed; silent Bortle default.** URL contains a literal `\${lat…}` (`light_pollution_repository.dart:8`); *(verified)*. Scrapes a third-party HTML page; not injectable, no interface, no tests. The Bortle badge is hidden (`sky_darkness_widget.dart:32`) so no path sets Bortle; default is 4 (`planner_viewmodel.dart:41`); `_fetchBortle` still runs on every location change | Bortle is never obtained; the Bortle half of the sky warning is unreachable; a failing request is made on each location change; ToS/fragility risk | Decide PD-05; remove or replace the scraper; represent unknown end-to-end [M] | SI-007, F-32, F-33, PD-05 |
| TD-007 | **NPF formula deviates from the published formula; the test is circular.** Constant `+ 90.0` replaces `0.1·F` (`optical_calculator.dart:87`); expected value in the test derives from the same constant. *(verified)* ratios 2.88 (phones) to 0.72 (2000 mm) | Wrong exposure recommendation if ever surfaced (currently unsurfaced) | SI-001 actions: confirm constants from the primary source, fix with citation, independent test values, K explicit, do not surface before then [S] | SI-001, F-26, PD-11 |
| TD-009 | **"Stacking Gain (Relative SNR)" label and ISO wording.** `capture_plan_widget.dart:215`; label restored on purpose in `1baa514`; gain ignores sub-exposure length. `gainIso` is free text | Violates CLAUDE.md rule 18, ADR-005 and PRODUCT_SPEC in user-facing text | Rename to "Relative stacking gain (√N)", document assumptions, avoid ISO-as-sensitivity wording [S] | SI-003, SI-004, DEV-P2, F-37 |

## High

| ID | Title and evidence | Impact | Direction (proposal) | Related |
| --- | --- | --- | --- | --- |
| TD-003 | **`integration_flow_test.dart` fails — root cause corrected.** *(verified)* The ViewModel is created in `setUp` outside the fake-async zone so `_init()` never advances; the spinner never settles and `pumpAndSettle` times out (`test/integration_flow_test.dart:99`). A second cause is an unhandled `MissingPluginException` from `Geolocator` (`planner_viewmodel.dart:74`). HTTP is **not** involved (weather is mocked) | Red suite; ambiguous signal on every run | Create/await the ViewModel inside `tester.runAsync` and inject a location interface. Do not delete the test [S–M] | DEV-A1, DEV-P8, F-48 |
| TD-005 | **Foreign keys not enforced; orphaned flat table.** *(verified)* `PRAGMA foreign_keys = 0`, orphan `capture_blocks` row inserted. `equipment_profiles` is read by nothing except a test | Orphans possible; dead schema | Enable FKs and retire/use the table as part of PD-04 [S–M] | DEV-D6, F-23, PD-04 |
| TD-008 | **Seed and equipment data errors.** ZWO seed `aperture: 72.0` in an f-number field (`equipment_seeder.dart:82`) shows `f/72.0` on Home; sensor sizes inconsistent with resolution × pitch (Xiaomi/Vivo −10.5 %); no `averageRawFileSizeMB`; unverified specs; provenance only in a comment | Visible wrong values; wrong NPF input; untraceable data | SI-005 and SI-011 actions; verify specs against primary sources; PD-09, PD-10 [M] | SI-005, SI-011, DEV-D5 |
| TD-010 | **Capture-block reorder-down is off by one.** `onReorderItem` passes an already-adjusted index but `reorderCaptureBlocks` still applies `newIndex -= 1` (`capture_plan_widget.dart:154`, `planner_viewmodel.dart:306-313`). *(verified)* callback `(0,2)` vs legacy `(0,3)`; `reorderCaptureBlocks(0,1)` left the list unchanged | Blocks dragged down land one slot short | Remove the extra adjustment and add a test [S] | F-35 |
| TD-011 | **Save Session creates duplicates and records no snapshot.** `home_screen.dart:201-247`; `addLog` returns `void` so the ViewModel never learns the id. *(verified)* two taps → two rows; location, temperature, focal length and integration stay null | Logbook fills with duplicates; sessions cannot be reproduced | Return the id / update state; fill snapshot fields; stable references (DEV-D3) [M] | DEV-D3, F-40 |
| TD-012 | **Capture-plan input validation.** Empty/invalid input becomes 60 s × 30 (`capture_plan_widget.dart:93-94`); negatives accepted; no edit UI (`updateCaptureBlock` unused); binning and gain not exposed | Corrupt totals; silent defaults | Validators, edit dialog [S–M] | SI-008, F-35 |
| TD-013 | **Unknown treated as zero / default as fact.** *(verified)* storage shows `0.0 MB` for all seeded gear; `null arcsec/px` (`home_screen.dart:104`); default plan and London shown as if user-chosen | Misleading numbers | Nullable values and explicit "unknown" UI (SI-008 rule) [M] | SI-008, SI-013, F-28 |
| TD-014 | **`FeatureScope` gating incomplete** (DEV-P1): `fieldMode` never read; map handoff ungated with hard-coded Slovenia coordinates (`home_screen.dart:172`); Home pushes gated routes unconditionally; `metadataImport` / `logbook` are `true` without a recorded approval | Scope discipline not enforced; wrong-location link | PD-06 (decided 2026-09-21, `DECISIONS.md` E.1), then enforce gates in routes **and** buttons [S] — **still Open; enforcement is roadmap TASK 4.3** | DEV-P1, F-04, F-34, F-46 |
| TD-017 | **Weather robustness and semantics.** Not date-aware; hourly array starts at local midnight; timestamps naive (`open_meteo_weather_repository.dart:47`), `utc_offset_seconds` discarded; cache has no staleness limit or indicator; parser assumes non-null arrays (fine for the live London query); model hard-coded (`:22`); no provenance; startup waits on it | Wrong-night/zone alignment; stale data shown as current | PD-02, PD-15; date-aware fetch; staleness indicator [M] | F-29, F-30, PD-15 |
| TD-019 | **`PlannerViewModel` is a 513-line multi-responsibility class that breaks layering** (DEV-A1): `http`, `geolocator`, `shared_preferences`, concrete `LightPollutionRepository`; un-awaitable constructor init; getters recompute on every access | Untestable, hard to change, defects cluster here | Extract only along seams created by TD-002/TD-022/TD-020 work; incremental, test-first; no big-bang rewrite [L] | DEV-A1, ARCHITECTURE D2 |
| TD-020 | **No site/time model.** Times shown in the device zone; naive weather times; no site time zone (`sky_darkness_widget.dart:137`) | Remote-site planning wrong; DST/zone bugs | PD-02; site time model in the domain [M] | SI-010, F-10 |
| TD-022 | **Capture budget conflates integration, acquisition, calibration and total session.** `estimatedRequiredTime` sums all block types plus 5 s/frame (`planner_viewmodel.dart:478-484`) against the night window; `SessionCalculator.estimateTotalDuration` (15 % model) is dead and inconsistent; overhead not configurable | The central component cannot answer "what fits tonight?" correctly | PD-08; pure-Dart budget service with tests [M–L] | DEV-A4, F-36, F-39, PD-08 |
| TD-025 | **Test gaps.** No tests for the live budget math, Home, Capture Plan, Sky, Weather, Altitude chart, Logbook, Location or Metadata screens; no migration tests; the NPF test mirrors the implementation; tested code (`estimateTotalDuration`, orphan table, catalog repository) is unused; ViewModel tests cover only the date and min-altitude setters | Regressions undetected | Reference-value tests; ViewModel/widget tests as areas are touched; see `docs/TEST_PLAN.md` [L] | F-48, TD-037 |
| TD-032 | **Moon precision and geometry.** Illumination error up to 4.7 pp shown to 0.1 %; no Moon altitude, rise/set or Moon–target separation (PRODUCT_SPEC MVP); warning ignores Moon altitude | Overstated precision; missing MVP feature | SI-002 actions; PD-07 [L] | SI-002, F-15, F-16, DEV-P6 |
| TD-041 | **RESOLVED 2026-09-21 (TASK 0.2; documentation only, no code change).** *(Was: no active roadmap phase is declared (DEV-P3) while Phases 10–15 features exist.)* | *(Was: no authoritative scope.)* | *Resolution:* the owner adopted `docs/MASTER_ROADMAP.md` as the approved scope (OD-06) and decided PD-06 (`DECISIONS.md` E.1). The gates in the code are still unenforced: TD-014, TASK 4.3 | DEV-P3, PD-06 |

## Medium

| ID | Title and evidence | Direction (proposal) | Related |
| --- | --- | --- | --- |
| TD-015 | **Mojibake** in `equipment_selection_screen.dart` (`Вµm` at `:49,193`, `В°` at `:363`, box-drawing comments) and one comment in `target_selection_screen.dart:322`; cause unknown (the patch scripts read/write UTF-8) | Correct the characters; check editor/tooling encoding [S] | F-22 |
| TD-016 | **Target model issues:** editing overwrites `catalogId` (`target_selection_screen.dart:175`); RA in degrees (`:130`); moving-object types offered (`:9-20`); no uniqueness/epoch/source/size/magnitude; `(0,0)` sentinel (`planner_viewmodel.dart:445,456`); `LIKE` wildcards not escaped | SI-012 actions; PD-07/PD-16 [M] | SI-012, F-19–F-21 |
| TD-018 | **Metadata import limits:** whole-file `readAsBytes` and `String.fromCharCodes` (`metadata_extractor.dart:8,47`); FITS unreachable via `image_picker`; `/` inside FITS string values truncates them; nothing stored or linked; no real sample files | Verify against real files before expanding (ROADMAP Phase 12) [M] | F-45 |
| TD-021 | **Screens bypass ViewModels** (DEV-A2) | Route through ViewModels when touched [M] | DEV-A2 |
| TD-023 | **Astronomy pipeline triplicated; logic inside `CustomPainter`** (DEV-A3) | One domain altitude function; chart consumes domain outputs [M] | DEV-A3, F-14 |
| TD-024 | **Stringly-typed night timeline** `Map<String, DateTime?>` (`visibility_calculator.dart:85`) | Typed value object [S–M] | F-12 |
| TD-026 | **Equipment model dormant/orphaned:** `EquipmentCatalogRepository` unused; `trackingState` invisible; rig deletion deletes camera and device unconditionally (`drift_equipment_repository.dart:98-117`) | PD-03 [M] | DEV-D2, F-23 |
| TD-027 | **Location handling:** `setLocation` overwrites the active saved profile (`planner_viewmodel.dart:216-255`); `_fetchBortle` reads `activeLocationId` while `setLocation` may still be inserting the row *(code reading)*; silent London default; no saved-location UI | Design saved locations with PD-02/PD-05 [M] | DEV-D4, F-06, F-07 |
| TD-028 | **Stale selection** after deleting the selected target/rig (ViewModel not notified) *(code reading)* | Notify or clear selection [S] | DEV-A2 |
| TD-029 | **Silent error swallowing / no error states:** reverse geocoding (`planner_viewmodel.dart:184`), weather (`open_meteo_weather_repository.dart:18,77,91`), metadata parsing (`metadata_extractor.dart:33,81`) and light pollution (`light_pollution_repository.dart:20`) all discard the error and return `null`/nothing; `_init` has no `try/catch` | Surface errors; add states [M] | F-29 |
| TD-031 | **Dependency, platform and legal risks:** `sqlite3_flutter_libs 0.6.0+eol` (verify on device); OSM tiles without attribution and with a mismatched user-agent (`location_picker_screen.dart:101-102`); Nominatim usage policy; Open-Meteo free tier is non-commercial (verify); iOS `Info.plist` lacks location/photo strings; release signing uses the debug key; `sdk: ^3.13.3`; repository is GPL-3.0 | PD-12; verify before any release [M] | F-50, PD-12 |
| TD-033 | **Hard-coded thresholds and the sky warning** (SI-006): Moon > 0.8 or Bortle ≥ 7; tight margin 85 %; overhead 5 s | Named, documented, configurable [M] | SI-006, F-18 |
| TD-036 | **Undocumented astronomy simplifications and quantization** (SI-009); stale "refine to 1-minute" comment (`visibility_calculator.dart:103`); no reference-ephemeris tests | Document bounds; add USNO/JPL reference tests [M] | SI-009 |
| TD-037 | **Test determinism:** real-time `Future.delayed(300 ms)` waits; static `AppRouter.router` singleton; tests need `activeLocationId` workaround to dodge Geolocator | Injectable clock/location; no sleeps [M] | DEV-A1 |
| TD-039 | **Logbook UX:** list unordered (oldest first); swipe-delete has no confirmation or undo (`logbook_screen.dart:54-66`) | Order, confirm/undo [S] | F-41 |
| TD-043 | **Threshold constants and settings** (SI-006): named constants; a settings screen for minimum altitude, darkness limit, overhead, margins, dew | Settings design [M] | SI-006 |
| TD-046 | **No CI configuration** exists in the repository | Add a minimal analyze + test workflow after TD-003 [S] | F-49 |

## Low

| ID | Title and evidence | Direction (proposal) | Related |
| --- | --- | --- | --- |
| TD-030 | **Repository hygiene:** five committed one-off patch scripts with hard-coded absolute paths (`fix_sensor_size.py`, `patch_bitdepth.py`, `patch_db.py`, `patch_equipment.py`, `patch_target.py`, commit `d0b737f`); empty `package-lock.json`; `skills-lock.json` and `.agents/skills/` (third-party Flutter/Dart skills and an unrelated Google ADK skill); empty untracked `bin/` | Remove with owner approval (do not delete unknown files without approval) [S] | — |
| TD-034 | **Decorative timeline bar:** a static gradient unrelated to the data (`sky_darkness_widget.dart:153-170`) contradicts `.agents/rules/05-ui-design.md` | Make data-driven or remove [S] | F-12 |
| TD-035 | **Seeding is not idempotent per row:** re-seeds all defaults if the user deletes everything | Track seeded state [S] | F-05 |
| TD-038 | **`analysis_options.yaml`** uses default `flutter_lints` only | Consider stricter rules (`unawaited_futures`, casts) [S] | — |
| TD-042 | **Stale/incorrect comments and artifacts:** reverse-geocode comment says "Open-Meteo" but uses Nominatim (`planner_viewmodel.dart:163`); `Earth\\'s` (`astronomical_engine.dart:38`); `frame_type` comment says uppercase but lowercase is stored (`app_database.dart:18`); unsourced "≥ 1 mag" rationale (`planner_viewmodel.dart:49-54`); `pubspec` description is the Flutter default | Correct with the related fix [S] | — |
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

## Cleanup candidates identified but **not touched** (need owner approval)

Patch scripts and lockfiles (TD-030); `docs/archive/` retention; the
`GEMINI.md` `.gitignore` entry (PD-13); the untracked, empty `bin/` directory.
