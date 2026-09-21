# AstroPlan Project Audit — Technical Takeover (2026-09-21)

> **This is a point-in-time record.** It describes the repository at commit
> `900b82a` (2026-09-20) as audited on 2026-09-21. **Do not edit it to reflect
> later changes.** The living documents are `PROJECT_HANDOFF.md`,
> `ARCHITECTURE.md`, `DATA_MODEL.md`, `FEATURE_STATUS.md`, `TECH_DEBT.md`,
> `DECISIONS.md` and `SCIENTIFIC_INTEGRITY.md`. This file holds the **evidence**
> behind them, the **documentation discrepancy log**, and the **rule-conformance
> matrix**.
>
> Status vocabulary: Implemented / Partial / Prototype / Broken / Missing /
> Deprecated / Unknown. **No application code was modified** by the audit or by the
> documentation reconciliation.

## 1. Scope and method

1. Read every file in `lib/` (5,766 non-generated lines), all 21 test files, all
   docs, `.agents/rules/`, `pubspec.yaml`, platform configuration and git history.
2. Ran `flutter analyze --no-pub` and `flutter test --no-pub`. Compared `git status`
   before and after: unchanged.
3. Reproduced each suspected defect with **throwaway tests kept outside the
   repository** (never committed). The recipes in section 5 are sufficient to
   recreate them.
4. Checked external facts: the live Open-Meteo response for the app's exact query,
   the US Naval Observatory 2025 Moon-phase table, and the published NPF formula.
5. Verified compliance claims with `grep` over the source tree and with git history.

## 2. Baseline snapshot

| Item | Value |
| --- | --- |
| Commit | `900b82a` "feat: standardize RAW storage metadata" (2026-09-20); 15 commits on `main` in four days (9 / 4 / 1 / 1); no tags, no stash, one branch |
| Toolchain | Flutter 3.47.4, Dart 3.13.3 |
| Size | `lib/` 5,766 lines in 58 hand-written files + 7,919-line generated Drift file; `test/` 1,757 lines in 21 files |
| `flutter analyze` | **No issues found** (default `flutter_lints` only) |
| `flutter test` | **71 tests: 70 pass, 1 fails** (`integration_flow_test.dart`) |
| Key dependency versions | drift 2.35.0, sqlite3 3.5.2, sqlite3_flutter_libs `0.6.0+eol`, geolocator 14.0.3, exif 3.3.0, image_picker 1.2.3, flutter_map 8.3.2, go_router 18.0.1, provider 6.1.5+1, http 1.6.0, share_plus 13.3.0, shared_preferences 2.5.5 |
| Secrets | None found; no signing files tracked |
| CI | None configured |
| Licence | GPL-3.0 |

## 3. Verification evidence

"Recipe" refers to section 5. All results are from 2026-09-21.

| ID | Claim | Method | Result | Feeds |
| --- | --- | --- | --- | --- |
| E-01 | Analyzer clean | `flutter analyze --no-pub` | No issues (42.9 s) | F-48 |
| E-02 | Suite status | `flutter test --no-pub` | 70 pass / 1 fail | F-48 |
| E-03 | Red test root cause | Instrumented copy of the failing test | ViewModel built in `setUp` outside fake-async never leaves `isLoading`; after `tester.runAsync` it finishes (`isLoading=false`, target M42). Only exception: `MissingPluginException` (Geolocator). HTTP not involved | TD-003 |
| E-04 | UTC-date default night | Recipe R-04 | At 18:30 PDT: true next sunset 19:08 PDT Sep 21; app 19:10 PDT **Sep 22** (24.0 h late), header `2026-09-22 (Night)`. Berlin control: 3 min difference (quantization) | TD-001, SI-010 |
| E-05 | Moon model accuracy | Recipe R-05 against 28 USNO 2025 events | Worst error 4.7 pp at quarters (2025-02-05: 0.453 vs 0.50), 0.8 pp at new/full; UI shows one decimal | SI-002 |
| E-06 | Bortle URL | Verbatim string literal | `https://clearoutside.com/forecast/${lat.toStringAsFixed(4)}/${lon.toStringAsFixed(4)}` — never interpolated | TD-006, SI-007 |
| E-07 | v3 → v9 migration | Recipe R-07 | `SqliteException(1): table optical_rigs has no column named optical_multiplier` | TD-004 |
| E-08 | v8 → v9 migration | Recipe R-07 with v8 DDL | Success; new equipment inserted (rigs 1 → 2) | TD-004 |
| E-09 | Foreign keys | `PRAGMA foreign_keys`; orphan insert | `0`; orphan `capture_blocks` row inserted | TD-005 |
| E-10 | NPF vs published | Recipe R-10 | App ÷ published: 2.88 / 2.96 (phones), 1.79 (50 mm), 1.32 (400 mm), 1.00 (900 mm), 0.72 (2000 mm) | TD-007, SI-001 |
| E-11 | Reorder semantics | Recipe R-11 | `onReorderItem` → `(0,2)`; legacy `onReorder` → `(0,3)`; `reorderCaptureBlocks(0,1)` left `[light, dark, flat]` unchanged | TD-010 |
| E-12 | Home dead-end | Widget run with an empty DB | Message shown; controls: four app-bar `IconButton`s (New Session, Toggle Field Mode, Logbook, Import Metadata), no other buttons | TD-002 |
| E-13 | Save twice; storage; label | Widget run with seeded data | 2 log rows, snapshot fields null; storage text `0.0 MB`; label `Stacking Gain (Relative SNR)` present | TD-011, TD-013, TD-009 |
| E-14 | Seeding race | Recipe R-14 | 0 event-loop turns: `target=null equipment=null`; ≥ 1 turn: selected. In-memory DB only | TD-002 |
| E-15 | Live weather query | HTTP GET of the app's URL (London), read in memory | No nulls in the first 48 h for all 7 variables; `hourly.time[0] = 2026-09-21T00:00`; `current.time` 17:15; `utc_offset_seconds = 3600` (discarded by the app) | TD-017 |
| E-16 | Secrets and signing | `grep` over tracked files; file-name search | None | — |
| E-17 | Layering compliance | `grep` for Drift/Flutter imports | No Drift import in `presentation`/`domain`; no Flutter import in `domain`/`core/utils`; only the ViewModel imports `data/` | ARCHITECTURE Part C |
| E-18 | Android manifest | File inspection | `INTERNET`, `ACCESS_FINE_LOCATION`, `ACCESS_COARSE_LOCATION` in the main manifest; release signing uses the debug key | TD-031 |
| E-19 | Dead or unsurfaced code | Reference counts in `lib/` | No UI use of `npfExposure`, `calculateFOV`, `dewWarning`, `setDewPointThreshold`, `setMinAltitude`, `updateCaptureBlock`, `SessionCalculator.estimateTotalDuration`, `EquipmentCatalogRepository`; `Provider<AppDatabase>` never read | F-25, F-26, F-31 |
| E-20 | Provenance | `git log -S` | NPF `+ 90.0` introduced with the function in `d0b737f`; "Relative SNR" label added in `1baa514` | SI-001, SI-003 |
| E-21 | Generated code in sync | `git show --stat 900b82a` | `app_database.g.dart` regenerated with the last schema change (306 lines); not re-generated during the audit | DATA_MODEL B2 |

## 4. Documentation discrepancy log

Verdicts: **Confirmed** (claim correct), **Incorrect**, **Partly**, **Outdated**,
**Reclassified**. "Previous docs" means the uncommitted "as-is" rewrite archived in
`docs/archive/2026-09-21-previous-agent-audit/`.

| # | Document and claim | Verdict | Reality (evidence) |
| --- | --- | --- | --- |
| 1 | HANDOFF/TECH_DEBT: integration test fails because the HTTP client is not mocked | **Incorrect** | Harness async-zone problem + unguarded Geolocator; weather is mocked (E-03) |
| 2 | HANDOFF/TECH_DEBT: "CI failure", "resolve the CI failure" | **Incorrect** | No CI configuration exists |
| 3 | DATA_MODEL/FEATURE_STATUS/TECH_DEBT: equipment persisted in a flat `EquipmentTable`; rig/camera separation missing | **Incorrect** | Storage is normalized Device → CameraModule → OpticalRig (1:1:1); the flat table is orphaned; only the domain/UI is flat (DEV-D2) |
| 4 | DATA_MODEL: capture blocks serialized as JSON inside Drift | **Incorrect** | Relational `capture_blocks` table; JSON only for the active plan in preferences |
| 5 | DATA_MODEL: tables named `TargetsTable`, `EquipmentTable`, `LogbookTable`, `LocationsTable` | **Incorrect** | Those are file names; classes are `AstroTargets`, `Devices`/`CameraModules`/`OpticalRigs` (+ orphan `EquipmentProfiles`), `SessionLogs`, `LocationProfiles`, `CaptureBlocks` |
| 6 | DATA_MODEL/FEATURE_STATUS: logs "maintain snapshots of environments" | **Incorrect** | Columns exist; Save never fills them (E-13) |
| 7 | DATA_MODEL: weather "powers dew warnings and environmental snapshots" | **Incorrect** | `dewWarning` is never displayed; snapshots never saved (E-19) |
| 8 | DATA_MODEL: `LocationProfile` "Used? Yes" | **Partly** | One row, overwritten by `setLocation`; no management UI (DEV-D4) |
| 9 | FEATURE_STATUS: "Date Selection — sets sessionDate, updates weather" | **Partly** | Refetches the same forecast; default date wrong (E-04, E-15) |
| 10 | FEATURE_STATUS: Target Visibility "calculates … culmination" | **Partly** | Only altitude at LHA = 0; no culmination time; not night-restricted |
| 11 | FEATURE_STATUS: Night Timeline — known problems "None" | **Incorrect** | Wrong night by default; 5-minute quantization; stale comment (E-04) |
| 12 | FEATURE_STATUS: Light Pollution "Partial — brittle scraping" | **Incorrect** | Broken: it can never succeed (E-06) |
| 13 | FEATURE_STATUS: Logbook "Implemented" | **Incorrect** | Partial: plan-only, no actuals entry, duplicates (E-13) |
| 14 | FEATURE_STATUS: Metadata Import "Implemented" | **Incorrect** | Prototype: display-only; FITS unreachable; no real samples |
| 15 | FEATURE_STATUS: Capture Planner "Implemented" | **Incorrect** | Partial: reorder-down bug, silent defaults, no edit (E-11) |
| 16 | FEATURE_STATUS: UI "Implemented — clean layout" | **Partly** | Mojibake, static decorative bar, Home dead-end |
| 17 | HANDOFF: altitude via "rigorous LST and GMST" | **Partly** | Low-precision models, adequate for planning; assumptions undocumented (SI-009) |
| 18 | HANDOFF: `calculateNightTimeline` "correctly isolates" twilights | **Partly** | Correct math, wrong default night, 5-min steps |
| 19 | HANDOFF: tests cover services, widgets, Drift | **Confirmed** | But with major gaps (TD-025) |
| 20 | HANDOFF: "UTC used for math, local for UI" | **Partly** | Mixed time bases (SI-010) |
| 21 | HANDOFF: next step "Build the Custom Dashboard" | **Reclassified** | Not in PRODUCT_SPEC or ROADMAP (PD-14) |
| 22 | HANDOFF: next step "Refactor PlannerViewModel into four ViewModels" | **Reclassified** | Premature as a first move; seams-first, incremental (ARCHITECTURE D2) |
| 23 | HANDOFF: "Replace scraping with a stable API or local dataset" | **Reclassified** | An open decision (PD-05), and keyed APIs need secret handling |
| 24 | DECISIONS #2: SessionCalculator "compares darkness against the plan plus 15 % overhead" | **Incorrect** | The 15 % model is dead code; live path is the ViewModel's 5 s/frame (contradicts the previous HANDOFF too) |
| 25 | DECISIONS #4: avoids claiming absolute SNR | **Partly** | Label says "Relative SNR" (E-13, E-20) |
| 26 | DECISIONS: configurable minimum altitude | **Partly** | ViewModel only; no UI |
| 27 | DECISIONS: (omitted) ADR-006, pending decisions, ADR numbering | **Outdated** | The committed originals were overwritten; restored in `DECISIONS.md` Part A |
| 28 | ARCHITECTURE (previous): presentation "minimal logic, observes ViewModels" | **Partly** | Several screens bypass ViewModels; logic inside a painter (DEV-A2, DEV-A3) |
| 29 | ARCHITECTURE (previous): consider `get_it` | **Reclassified** | Not justified (CLAUDE.md rule 6) |
| 30 | ARCHITECTURE (previous): reverse geocoding lives in the ViewModel via Nominatim; ViewModel ≈ 514 lines | **Confirmed** | 513 lines |
| 31 | HANDOFF: "No hardcoded API keys" | **Confirmed** | E-16 |
| 32 | HANDOFF: weather via Open-Meteo, cached in preferences; forecast limited to 48 h | **Confirmed** | Plus: starts at local midnight (E-15) |
| 33 | TEST_PLAN snapshot: `flutter test` passed, one analyzer deprecation | **Outdated** | Analyzer clean; 1 failing test (E-01, E-02) |
| 34 | CLAUDE.md: docs described as checked in / source of truth | **Partly** | They were untracked and then git-ignored; now trackable (OD-02) |
| 35 | ROADMAP "Current Repository Alignment": moved past Phase 4 "in several areas" | **Confirmed** | Now itemized per phase in `ROADMAP.md` |
| 36 | README: Android initial, iOS future | **Confirmed** | iOS is not configured (no usage strings) |

## 5. Reproduction recipes

The original throwaway tests were **not** committed. Each recipe can be recreated in
a scratch `flutter test` file outside `test/`.

**R-04 — UTC-date default night (pure Dart).**
```dart
final nowUtc = DateTime.utc(2026, 9, 22, 1, 30);            // 18:30 PDT on Sep 21
final tl = VisibilityCalculator.calculateNightTimeline(nowUtc, 37.7749, -122.4194);
// tl['sunset'] -> 2026-09-23T02:10Z  (19:10 PDT on Sep 22)
// True next sunset: scan minute by minute from nowUtc with
// VisibilityCalculator.calculateSunAltitude for the first downward crossing of
// -0.833 deg -> 2026-09-22T02:08Z (19:08 PDT on Sep 21). Difference: 24.0 h.
// Control: Berlin (52.52, 13.405) with DateTime.utc(2026, 9, 21, 19) -> ~3 min.
```

**R-05 — Moon model vs USNO.** For each phase event of 2025 from
`https://aa.usno.navy.mil/api/moon/phases/year?year=2025`, compute
`VisibilityCalculator.calculateLunarIllumination(eventUtc)` and compare with 0
(new), 0.5 (quarters) and 1 (full). 28 events.

**R-07 — Migration from a real old database.** Build an in-memory SQLite database
with the v3 schema (from commit `5bc8ba6`), set the version, then open it with the
current `AppDatabase`:
```sql
CREATE TABLE equipment_profiles (id INTEGER NOT NULL PRIMARY KEY AUTOINCREMENT,
  name TEXT NOT NULL, manufacturer TEXT NULL, camera_model TEXT NULL,
  sensor_width REAL NOT NULL, sensor_height REAL NOT NULL, pixel_pitch REAL NOT NULL,
  resolution_width INTEGER NOT NULL, resolution_height INTEGER NOT NULL,
  focal_length REAL NOT NULL, aperture REAL NOT NULL,
  optical_multiplier REAL NOT NULL DEFAULT 1.0, rotation REAL NULL);
-- plus location_profiles, astro_targets, session_logs (v2 shape) from 5bc8ba6
PRAGMA user_version = 3;
```
```dart
final raw = sqlite3.openInMemory()..execute(ddl);
final db = AppDatabase(NativeDatabase.opened(raw));
await db.customSelect('SELECT 1').get();   // triggers onUpgrade; throws for v3
```
For v8 use the schema of commit `d0b737f` (see `docs/DATA_MODEL.md` B8); it succeeds.

**R-10 — NPF comparison.**
```dart
double app(n, p, f, dec)  => (16.856*n + 13.713*p + 90.0)   / (f * cos(dec));
double pub(n, p, f, dec)  => (16.856*n + 0.0997*f + 13.713*p) / (f * cos(dec)); // K = 1
```
Compare for the optics in `SCIENTIFIC_INTEGRITY.md` SI-001.

**R-11 — Reorder.** Build `ReorderableListView.builder(buildDefaultDragHandles: false,
onReorderItem: …)` with `ReorderableDragStartListener` items, drag item 0 down by
about 110 px in small steps, record the callback arguments; repeat with the legacy
`onReorder`. Then create a `PlannerViewModel` (with `activeLocationId` preset in mock
preferences) and call `reorderCaptureBlocks(0, 1)`.

**R-14 — Seeding race.** With an in-memory database and `activeLocationId` preset,
start `CatalogSeeder`/`EquipmentSeeder` in `Future.microtask`, then create
`PlannerViewModel` after N `await Future.delayed(Duration.zero)` turns (N = 0, 1, 3),
wait 600 ms, and read `selectedTarget` / `selectedEquipment`.

**E-12/E-13 (widget runs).** Pump `AstroPlanApp` with real Drift repositories and an
in-memory database (built inside `tester.runAsync`); for E-13 seed with the app's
seeders, tap **Save Session** twice, read `getAllLogs()`.

## 6. Governance-rule conformance matrix

### `CLAUDE.md` development rules that constrain the code (rules 11–19)

| Rule | Conformance | Evidence |
| --- | --- | --- |
| 11 Business logic testable and separated from UI | **Partial** | DEV-A3, DEV-A4 |
| 12 Deterministic astronomical calculations | **Partial** | Calculators are deterministic for given inputs; the ViewModel calls `DateTime.now()` inline and the default date depends on it |
| 13 Explicit units | **Partial** | Doc comments state units; field names do not; aperture ambiguity (SI-005) |
| 14 Handle UTC/local time carefully | **Deviation** | SI-010 |
| 15 No hard-coded secrets | **Complies** | E-16 |
| 16 No silent formula changes | **Complies (history)** | The NPF formula was never changed silently (E-20); it was wrong from its introduction |
| 17 Scientific assumptions documented | **Deviation** | SI-009; now recorded in `SCIENTIFIC_INTEGRITY.md` |
| 18 Never present relative gain as absolute SNR | **Deviation** | SI-003 |
| 19 Thresholds configurable where appropriate | **Partial** | SI-006 |

Rules 1–10 and 20 are behavioural rules for agents (inspect first, minimal change,
tests, checkpoints); this audit followed them.

### `.agents/rules/`

| File | Rule (summary) | Conformance | Evidence |
| --- | --- | --- | --- |
| 00 governance | Roadmap phase is the active scope; approval for architectural work; distinguish facts, assumptions, risks | **Deviation** | DEV-P1, DEV-P3 |
| 01 architecture | Layers; Drift in the data layer; calculations independent of widgets; platform code behind interfaces; Provider/ViewModels | **Partial** | Drift confined and calculations Flutter-free (complies); DEV-A1–A3 |
| 02 code quality | Small changes; existing patterns; name and document constants; keep generated files in sync | **Partial** | Magic numbers (SI-006); generated code in sync at the last schema change (E-21) |
| 03 testing | Run analyze and test; add focused tests; do not claim unverified results | **Deviation** | DEV-P8; TD-025 |
| 04 scientific | Document every calculation; do not invent specs; relative gain ≠ SNR; storage payload vs empirical; NPF only after documented model | **Deviation** | SI-001, SI-003, SI-005, SI-011, SI-013 |
| 05 UI design | Minimalist, functional, no premature field utilities | **Deviation** | Decorative timeline bar (TD-034); field mode live (DEV-P1) |

## 7. Repository and process observations

- **History:** 15 commits over four days; schema versions 4 → 8 arrived in one commit
  (`d0b737f`); commit `1baa514` deliberately restored the "Relative SNR" label.
- **Tooling residue:** five one-off Python patch scripts with hard-coded absolute
  paths, an empty `package-lock.json`, and `skills-lock.json` with a 47-file
  `.agents/skills/` tree (third-party Flutter/Dart skills and an unrelated Google
  ADK skill) are committed (TD-030).
- **Documentation incident (recorded, resolved):** the Phase 0 docs
  (`ARCHITECTURE`, `DATA_MODEL`, `DECISIONS`) were overwritten in the working tree
  and three new docs plus `CLAUDE.md` were created (mtimes 18:45–18:50 on
  2026-09-21). At 18:59 `.gitignore` was edited to ignore `CLAUDE.md` and six docs
  (not by this audit). Resolution: originals restored as Part A of each document, the
  rewrites archived verbatim, the ignore rules removed (OD-02). The three tracked
  docs remain modified until committed.
- **Developer environment note:** the primary development machine is in a UTC+3
  zone, where the UTC date equals the local date in the evening — which is why
  TD-001 was not noticed.

## 8. Recommended sequence (proposal — **not approved**)

Input for the Master Development Roadmap. Order reflects dependencies, not
priority among owner decisions.

0. **Owner decisions first:** PD-06 (declare the active phase), PD-01/PD-02 (night
   and time zone), PD-04 (persistence baseline), PD-08 (capture-budget model).
1. **Session-night semantics** in the pure-Dart domain with regression tests
   (TD-001) — proposed first implementation task; **not started** (OD-03).
2. **Deterministic startup and a green suite**: awaitable initialization, seeding
   before the first read, location interface, fix the red test at its root
   (TD-002, TD-003).
3. **Persistence baseline**: schema snapshots, migration tests, foreign keys, retire
   the orphan table (TD-004, TD-005, TD-026).
4. **Scientific-integrity pass**: NPF, seed data, labels, Moon display precision,
   documented assumptions (TD-007, TD-008, TD-009, TD-036).
5. **Capture-budget domain service** (TD-022), then the planner fixes (TD-010,
   TD-011, TD-012, TD-013).
6. **ViewModel seams** only as steps 2 and 5 create them (TD-019, TD-021).
7. **Imaging Opportunity** (Moon and weather windows), then Logbook actuals and
   execution.
8. **Light-pollution decision** and removal of the scraper (TD-006).
9. **Catalog and framing**: larger catalog with provenance, target size, FOV fit.

## 9. Not verified

No Android build, emulator or device run; GPS and permission flows; on-device
seeding race timing; real FITS/RAW/JPEG files; Nominatim and OSM tile behaviour;
seeded equipment specifications against primary sources; the exact published NPF
constants (rounded values only were read); performance (getters recompute on every
build); web/desktop/iOS builds; `build_runner` regeneration.

## 10. Implementation-deviation index

| ID | Title | Home document |
| --- | --- | --- |
| DEV-A1 | ViewModel not isolated from data/network/platform code | `ARCHITECTURE.md` |
| DEV-A2 | Presentation bypasses ViewModels | `ARCHITECTURE.md` |
| DEV-A3 | Astronomy inside a widget; pipeline triplicated | `ARCHITECTURE.md` |
| DEV-A4 | Capture/session budget logic in the ViewModel | `ARCHITECTURE.md` |
| DEV-A5 | Offline-first not honoured at startup | `ARCHITECTURE.md` |
| DEV-A6 | Scientific calculation boundary partly documented and tested | `ARCHITECTURE.md` |
| DEV-D1 | Migrations untested; v3 → v9 fails | `DATA_MODEL.md` |
| DEV-D2 | Equipment normalized in storage, flat in the domain | `DATA_MODEL.md` |
| DEV-D3 | Session logs use display strings and record no snapshot | `DATA_MODEL.md` |
| DEV-D4 | Active planner state split across three stores | `DATA_MODEL.md` |
| DEV-D5 | Provenance not stored | `DATA_MODEL.md` |
| DEV-D6 | Foreign keys declared, not enforced | `DATA_MODEL.md` |
| DEV-P1 | ADR-006 gating only partly implemented | `DECISIONS.md` |
| DEV-P2 | ADR-005 not met | `DECISIONS.md` |
| DEV-P3 | No active roadmap phase declared | `DECISIONS.md` |
| DEV-P4 | ADR-003: migrations, relationships, testability | `DECISIONS.md` |
| DEV-P5 | ADR-002: explicit ViewModels | `DECISIONS.md` |
| DEV-P6 | PRODUCT_SPEC MVP scope not fully met | `DECISIONS.md` |
| DEV-P7 | Phase 0 deliverable `GEMINI.md` | `DECISIONS.md` |
| DEV-P8 | Testing rule cannot currently be satisfied literally | `DECISIONS.md` |

## 11. What this reconciliation changed

Documentation and `.gitignore` only:
- **Created:** `docs/SCIENTIFIC_INTEGRITY.md`, `docs/PROJECT_AUDIT.md`,
  `docs/archive/2026-09-21-previous-agent-audit/` (six verbatim copies + README).
- **Rewritten:** `PROJECT_HANDOFF.md`, `ARCHITECTURE.md`, `FEATURE_STATUS.md`,
  `DATA_MODEL.md`, `TECH_DEBT.md`, `DECISIONS.md` (design intent preserved verbatim
  as Part A of the three that had a committed original).
- **Updated:** `CLAUDE.md` (all original text kept, sections added); additive
  alignment notes in `ROADMAP.md`, `PRODUCT_SPEC.md`, `TEST_PLAN.md`, `README.md`.
- **`.gitignore`:** removed the seven rules that ignored `CLAUDE.md` and six docs;
  the file now matches the committed version.
- **Not changed:** anything under `lib/`, `test/`, `android/`, `ios/`, `pubspec.*`.
