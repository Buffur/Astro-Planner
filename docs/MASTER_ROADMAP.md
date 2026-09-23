# AstroPlan — Master Development Roadmap

**Baseline.** `main` is at commit `900b82a`, and today's documentation reconciliation sits on top of it, uncommitted. I didn't run any code or change the repository. The one file I touched is my own memory note, which lives outside the repo.

- **Test and analyzer results** come from this morning's audit of the same commit. `git` confirms nothing under `lib/`, `test/`, `android/`, `ios/` or `pubspec.*` has changed since then.
- **Docs changed while I worked.** A parallel session rewrote them between 20:04 and 20:19. I re-read all of them and compared them with the code, and they agree. This roadmap uses their IDs: F-## (features), TD-### (tech debt), SI-### (scientific issues), DEV-\* (deviations), PD-## (open decisions), OD-## (owner directives).
- **Competitor facts** come from store listings and vendor documentation. I haven't used the apps myself.

---

# 1. Executive summary

- **Where it stands.** AstroPlan is a real Flutter/Drift prototype: 5,766 hand-written lines in `lib/` and 71 tests. It has a working planner, equipment and target management, and adequate core astronomy. The central answer is not trustworthy yet:
  - the default "tonight" is 24 h late for evening users west of UTC;
  - there is no Moon position, rise/set or Moon–target separation;
  - the capture budget lumps light frames, calibration frames and overhead into one number;
  - saved sessions keep no context and can be duplicated.
- **Docs.** They are now accurate but uncommitted. Five owner decisions block the roadmap: PD-06, PD-01, PD-02, PD-04 and PD-08.
- **Strategy.** Incremental, foundation-first, no rewrite. The order is:
  1. governance and a green test suite;
  2. one time model;
  3. a safe persistence baseline;
  4. honest outputs;
  5. **the capture budget, early**;
  6. conditions (Moon, sites, targets and equipment, weather) feeding a transparent Imaging Opportunity;
  7. a persisted Session;
  8. navigation and a field-safe UI;
  9. execution, then the logbook;
  10. hardening, then Android 1.0.
  
  Metadata-assisted logging comes in v1.1.
- **Shape.** 18 groups, 77 tasks, none larger than L, and 8 milestones. 13 tasks need Opus; the other 64 are for Sonnet.
- **Most important foundation.** A pure-Dart `SessionNight` used by every consumer. It covers solar noon to solar noon at the site, computed in UTC, and every displayed time names its zone.
- **Core feature.** The capture budget fitted into the night's real windows: "this plan fits / doesn't fit / this fits instead". Plan → Execute → Log closes the loop.
- **Differentiation check.** Each of the five candidate differentiators already exists somewhere (Astro PM, Telescopius, Sidereal, NINA Target Scheduler, PhotoPills). The bet is the combination: an offline, transparent, single-night budget loop for manual imagers who don't run a laptop automation stack.
- **Next single task: TASK 0.1** — commit the reconciled docs. This is a checkpoint the owner must approve.

# 2. Current state (verified)

| Area | State at `900b82a` |
|---|---|
| Code and tests | 5,766 hand-written lines in `lib/` plus 7.9k generated (Drift); 71 tests (1,757 lines); **70 pass, 1 fails** (`integration_flow_test`: the test's async zone plus an unguarded Geolocator call, not HTTP); `flutter analyze` clean |
| Architecture | Layered folders. One 513-line `PlannerViewModel` does HTTP (Nominatim), GPS, SharedPreferences and the derived astronomy, and it depends on a concrete data-layer class. Astronomy is computed inside the chart's `CustomPainter`. Three screens bypass ViewModels. (DEV-A1…A6) |
| Time | The default night uses the UTC calendar date, so evenings in the Americas show tomorrow (reproduced). The chart uses device-local noon, and weather times are naive strings parsed as device time (SI-010) |
| Astronomy | Sun and target math is adequate but has no reference tests. The Moon model is mean-phase only (up to 4.7 pp error, shown to 0.1 %). There is no Moon geometry, and the NPF formula is wrong (not shown in the UI) |
| Weather | Open-Meteo: first 48 h from local midnight, `icon_seamless` hard-coded, no staleness limit, and startup waits on it |
| Planner | Frame types light/dark/flat/bias; overhead of 5 s per frame across all block types; fixed 85 % "tight" margin; √N labelled "Relative SNR"; storage shows "0.0 MB" when the file size is unknown; reorder bug; no block editing; invalid input silently replaced |
| Logbook | Repeated taps on Save create duplicate rows; snapshot columns are never filled; records reference target and equipment by name string; swipe-delete has no confirmation |
| Sites and light pollution | One location row, overwritten by "current location"; no time zone; Bortle defaults to 4 and is presented as fact; the scraper can never work; the map link opens fixed Slovenia coordinates |
| Equipment and targets | A flat profile over normalized 1:1:1 tables plus an orphaned table. `aperture` means f-number, but one seed stores 72 (a diameter in mm). Tracking type is stored but hidden. 5 targets; moving object types offered |
| Persistence | Schema v9; upgrading a v3 database throws; no migration tests; foreign keys not enforced |
| Field mode and UI | The field-mode toggle is visible even though its gate is off; the mode isn't persisted; about 100 hard-coded `Colors.*` uses break red-only mode; mojibake in the equipment screen |
| Release | Release builds are signed with the debug key; placeholder labels; no OpenStreetMap attribution and a `com.example` tile user agent; iOS `Info.plist` lacks location and photo permission strings; the repository licence is GPL-3.0 |
| Docs | Reconciled: 50 features (7 Implemented, 22 Partial, 8 Prototype, 4 Broken, 9 Missing), 46 tech-debt items (6 Critical), 13 scientific issues, 16 open decisions, 5 owner directives. **Uncommitted** |

**Where docs and code still disagree, or where I found something new:**

1. The design-intent documents (PRODUCT_SPEC MVP, the ROADMAP phases, ADR-006 gates) differ from the code. This is already recorded as DEV-P1, DEV-P3 and DEV-P6.
2. New: editing the selected rig or target leaves stale values in the planner. TD-028 covers deletion only.
3. New: the test `sessionDate defaults to today (UTC)` asserts the TD-001 defect. It has to be replaced deliberately; that is not the same as weakening it.
4. The docs are not in Git yet (OD-02).

# 3. Core strategic direction

**3.1 Product bet and principles**
- **The bet.** Take tonight's real opportunity, fit a plan to it with explicit assumptions, track it in the field with minimal taps, and log planned vs actual. All of it works offline, with reasons instead of scores.
- **Primary segment.** Manual and semi-automated imagers without a NINA/ASIAIR automation stack: DSLR, mirrorless or astro camera on a tracker or simple mount, and smartphone users on a tripod.
- **Principles.**
  - Foundations before features: time → persistence → honesty → budget → conditions → opportunity → session → execution → log.
  - An ADR before every new domain concept (DATA_MODEL Part C).
  - Unknown values stay unknown.
  - Thresholds are user preferences, not laws.
  - No composite "astro score".
  - Provider and ViewModels stay; no DI container and no rewrite (ADR-002, ARCHITECTURE D3).

**3.2 Competitive differentiation check**

| Candidate | Already covered by | Verdict | Strategy |
|---|---|---|---|
| Capture Budget | Astro PM (per-filter exposure plans; planned, acquired and accepted counts; usable hours); Photon Hunter (per-filter plans, planned vs actual; platform unverified); NINA Target Scheduler (automated rigs) | Partly covered | Keep it as the core, positioned as an *explicit* budget (integration vs acquisition vs total, assumptions visible) fitted to one real night, offline on a phone |
| Imaging Opportunity | Telescopius (filters for altitude, hours visible and Moon distance; weather); DarkScout (score plus horizon obstructions); Astrophotography Planner (visibility and season score); Astro PM (dark and moon-safe windows) | Largely covered | Don't compete on discovery or scores. Make it transparent (a reason for every window) and use it only as the budget's input |
| Plan → Execute → Log | NINA, ASIAIR and APT (automated rigs); Sidereal (interval timer, checklist); Astro PM (logging); Meridian (macOS archive) | Covered for automated rigs; partial for manual users | The main bet. It must cost only a few taps per block |
| Mobile field-first | Sidereal (dark-first UI, Wear OS); Stargazing Hub and DarkScout (red mode) | Covered | A quality bar, not a selling point |
| Smartphone support | PhotoPills (NPF); Sidereal (500/NPF, interval timer) | Partly covered | A supported equipment type with honest NPF, exposure-cap and storage guidance; no camera control |

**Resulting strategy changes:**
- The budget moves to M3, so the bet can be tested on real nights before any investment in conditions breadth.
- There is no recommendation engine. The app only ranks the user's own target list by usable minutes.
- Execution is designed for minimal taps, with metadata assistance in v1.1.
- M3 includes a go/no-go review against Astro PM and Telescopius.

**3.3 Platform and UX stance**
- **Android constraints.**
  - Foreground-only execution.
  - State is persisted on every change, and progress is derived from timestamps, never from running timers.
  - Notifications and alarms are deferred: POST_NOTIFICATIONS, exact-alarm limits and battery optimisation make them costly.
  - Location permission states are surfaced to the user.
  - Core features work offline.
  - No native camera control.
- **UI.** No visual redesign until the domain and Session are stable (G12). Feature tasks make only the UI changes they need. Notion is a visual reference only.

# 4. Master roadmap

| Group | Title | Milestone |
|---|---|---|
| G0 | Governance: doc checkpoint, roadmap adoption, hygiene | M0 |
| G1 | Testability and deterministic startup | M0 |
| G2 | Time foundation: SessionNight | M1 |
| G3 | Persistence baseline | M2 |
| G4 | Correctness and scientific-honesty fixes | M2 |
| G5 | Capture Budget (core) | M3 |
| G6 | Astronomical conditions | M4 |
| G7 | Sites and location | M4 |
| G8 | Targets and equipment | M4 |
| G9 | Weather | M4 |
| G10 | Imaging Opportunity | M4 |
| G11 | Session aggregate and persistence | M5 |
| G12 | UX foundation and navigation | M5 |
| G13 | Execution (field tracker) | M6 |
| G14 | Logbook | M6 |
| G15 | Quality hardening | M7 |
| G16 | Release preparation (Android 1.0) | M7 |
| G17 | Metadata-assisted logging | v1.1 |

---

## G0 — Governance: doc checkpoint, roadmap adoption, hygiene
- **Purpose:** turn today's reconciliation into a committed baseline and make this roadmap the approved scope.
- **Why it exists:** the source-of-truth docs are uncommitted (OD-02), no active scope is declared (PD-06, TD-041), and agents need one authoritative plan.
- **Problems solved:** unprotected docs, undeclared scope, no gate policy, repository residue.
- **Requires:** — · **Enables:** all groups.
- **Done when:** docs are committed; `docs/ROADMAP.md` holds this plan with an "active task" line; PD-06 is recorded; approved hygiene is done.

### TASK 0.1 — Commit the reconciled documentation
- **Goal:** a Git checkpoint of the source-of-truth documents.
- **Current problem:** CLAUDE.md, FEATURE_STATUS, TECH_DEBT, PROJECT_AUDIT, PROJECT_HANDOFF, SCIENTIFIC_INTEGRITY and `docs/archive/` are untracked, and 7 tracked files are modified.
- **Why now:** every later task reads these files (OD-02).
- **Dependencies:** owner reviews the diff.
- **Scope:** review the diff and untracked files; decide on the `.gitignore` change (line endings only); commit as one docs checkpoint.
- **Out of scope:** content rewrites; code.
- **Affected areas:** `CLAUDE.md`, `README.md`, `docs/**`, `.gitignore`.
- **Direction:** a single commit with the repo's attribution lines.
- **Tests:** none.
- **Acceptance:** docs clean in `git status`; the commit exists.
- **Risk · Complexity · Model:** Low · S · Sonnet

### TASK 0.2 — Adopt this roadmap; resolve PD-06
- **Goal:** this plan becomes the approved scope, and the fate of the features built ahead of their phase is decided.
- **Current problem:** no active phase is named (DEV-P3); features from phases 10–15 are live; gates are only partly enforced (DEV-P1, TD-014, TD-041).
- **Why now:** governance rule: "the active phase is the only approved scope".
- **Dependencies:** 0.1.
- **Scope:**
  - Keep the Phase 0–16 list as design intent and add the master roadmap, a phase→group map and an "active task" line.
  - Record PD-06. Recommendation: keep the logbook and text sharing visible (they are on the core path); hide metadata import (until G17), the light-pollution map card (until 7.4) and the field-mode toggle (until 12.4).
  - Register placeholders for new decisions PD-17 to PD-21.
- **Out of scope:** implementing the gates (that is 4.3).
- **Affected areas:** `docs/ROADMAP.md`, `docs/DECISIONS.md` Part E, the baseline section of `CLAUDE.md`.
- **Direction:** design intent is amended only by owner approval, never rewritten to match the code.
- **Tests:** n/a.
- **Acceptance:** owner-approved; PD-06 and TD-041 marked resolved with a date.
- **Risk · Complexity · Model:** Low · S · Sonnet

### TASK 0.3 — Repository hygiene
- **Goal:** remove leftovers that mislead agents.
- **Current problem (TD-030, part of TD-031, PD-13):**
  - 5 patch scripts with absolute Windows paths;
  - an empty `package-lock.json` and an empty `bin/`;
  - an unrelated Google ADK skill;
  - an ignore entry for `GEMINI.md`;
  - `cupertino_icons` unused;
  - `sqlite3_flutter_libs 0.6.0+eol` alongside `sqlite3 3.5.2`.
- **Why now:** cheap, and it stops agents from running stale scripts.
- **Dependencies:** 0.1; explicit owner approval for each item.
- **Scope:** delete or relocate the approved items; decide PD-13; check current drift/sqlite3 docs to see whether `sqlite3_flutter_libs` can go, then do a device smoke run.
- **Out of scope:** dependency upgrades.
- **Affected areas:** repo root, `.agents/`, `pubspec.yaml`, `.gitignore`.
- **Direction:** one commit per category; update the TD status lines.
- **Tests:** suite result unchanged.
- **Acceptance:** the root holds only project files.
- **Risk · Complexity · Model:** Low · S · Sonnet

## G1 — Testability and deterministic startup
- **Purpose:** a green, deterministic suite and a startup that never hangs or dead-ends.
- **Why it exists:** the red test masks regressions (DEV-P8); the ViewModel needs platform channels to run; startup races seeding and waits on the network (DEV-A5).
- **Problems solved:** TD-002, TD-003, part of TD-037, TD-046.
- **Requires:** G0 · **Enables:** all implementation work. 2.4 needs 1.1; 2.1–2.3 are pure domain and don't.
- **Done when:** tests pass three runs in a row without sleeps; cold start is deterministic offline; CI runs.

### TASK 1.1 — Repair the test harness; add platform seams
- **Goal:** `integration_flow_test` passes, and no test touches GPS or the network.
- **Current problem (TD-003, TD-037):**
  - the ViewModel is built in `setUp`, outside the fake-async zone;
  - `useCurrentLocation()` throws `MissingPluginException` in tests;
  - tests wait with 300 ms sleeps;
  - the fixture's RA of 5.59 is in hours but stored in a degrees field.
- **Why now:** a red suite hides regressions in every later task.
- **Dependencies:** none.
- **Scope:** a `LocationService` interface, with the Geolocator implementation outside the presentation layer, injected into the ViewModel; an awaitable `ready` future; tests create the ViewModel inside `tester.runAsync`; remove the sleeps; fix the fixture.
- **Out of scope:** Clock (2.2); ViewModel split (12.3).
- **Affected areas:** `planner_viewmodel.dart`, `main.dart`, new location service, `test/integration_flow_test.dart`, ViewModel tests.
- **Direction:** constructor injection with production defaults.
- **Tests:** the repaired end-to-end test; a permission-denied ViewModel test.
- **Acceptance:** green three runs in a row; no `Future.delayed` waits left in tests.
- **Risk · Complexity · Model:** Low · S · Sonnet

### TASK 1.2 — Deterministic bootstrap and empty states
- **Goal:** the first screen never blocks on the network, races seeding, or dead-ends.
- **Current problem (TD-002, DEV-A5):** seeding runs unawaited; `_init()` awaits weather (10 s timeout) and has no error handling; Home has no navigation when target or equipment is null; London is used silently.
- **Why now:** correctness on first run.
- **Dependencies:** 1.1.
- **Scope:** bootstrap in order (open DB → idempotent seeding → ViewModel init); load weather after the first frame; an error state with retry; empty-state actions; a "default location — set your site" banner.
- **Out of scope:** sites (G7); onboarding (12.5).
- **Affected areas:** `main.dart`, `planner_viewmodel.dart`, `home_screen.dart`, seeders.
- **Direction:** no new packages; failures become UI states.
- **Tests:** seeding completes before the first read (with fakes); error and empty-state widget tests; start with weather failing.
- **Acceptance:** a fresh install shows seeded data without a restart; a repository failure shows the error UI.
- **Risk · Complexity · Model:** Low · M · Sonnet

### TASK 1.3 — Quality gate and CI
- **Goal:** one command, also run by CI, for format, analyze and test.
- **Current problem (TD-046, F-49):** no CI; formatting is not enforced.
- **Why now:** a cheap guard on every AI-generated change.
- **Dependencies:** 1.1.
- **Scope:** a script running `dart format --set-exit-if-changed`, `flutter analyze --no-pub` and `flutter test --no-pub`; the one-time whole-tree format in its own commit; a minimal GitHub Actions workflow (owner approval).
- **Out of scope:** stricter lints (TD-038); device tests.
- **Affected areas:** `tool/`, `.github/workflows/`, `CLAUDE.md`.
- **Direction:** a thin wrapper over the standard commands.
- **Tests:** n/a.
- **Acceptance:** CI goes red on any failure; the script is documented.
- **Risk · Complexity · Model:** Low · S · Sonnet

## G2 — Time foundation: SessionNight
- **Purpose:** one deterministic, site-based definition of "the night" and one time base for every consumer.
- **Why it exists:** the product answers "tonight", yet the default night is 24 h late west of UTC, and four components use four different time bases.
- **Problems solved:** TD-001, TD-020 (computation part), TD-023, TD-024; SI-010.
- **Requires:** G0 (2.4 also needs 1.1) · **Enables:** G5, G6, G9, G10, G11, G13.
- **Done when:** every night-dependent output comes from one `SessionNight`; the regression matrix passes (Americas evening, after midnight, date line, DST, high latitude and polar); every displayed time names its zone.

### TASK 2.1 — ADR: SessionNight and time-zone strategy (PD-01, PD-02)
- **Goal:** an approved written definition before any code.
- **Current problem:** there is no definition. The UTC date, the local solar date, device-local noon and naive weather strings are all mixed.
- **Why now:** every downstream model depends on it.
- **Dependencies:** 0.2.
- **Scope:** decide:
  - **Window:** mean local solar noon to the next solar noon, derived from longitude. This needs no time zone.
  - **Identity:** the site-local evening date plus the site.
  - **Default rule:** the night that contains *now* until the next solar noon; after that, the upcoming night.
  - **Storage:** UTC.
  - **Display zone:** the site's IANA zone when known, otherwise the device zone, always labelled.
  - **Polar states:** explicit results for no astronomical darkness, midnight sun and polar night.
  - **Timing:** whether the `timezone` package comes in now or with 7.1.
- **Out of scope:** implementation.
- **Affected areas:** DECISIONS, SI-010.
- **Direction:** worked examples: San Francisco 18:30 PDT, Tokyo 02:00, Kiritimati (UTC+14), an EU DST night and a US DST night, Tromsø in June and December.
- **Tests:** the examples become the 2.2 test table.
- **Acceptance:** owner-approved, with at least 10 cases and expected windows.
- **Risk · Complexity · Model:** Low · S · Opus

### TASK 2.2 — SessionNight type, resolver and Clock
- **Goal:** a pure-Dart `SessionNight` and resolver, plus an injectable "now".
- **Current problem:** `_sessionDate = DateTime.now().toUtc()`, and `DateTime.now()` is scattered through the ViewModel and widgets.
- **Why now:** this is the foundation.
- **Dependencies:** 2.1.
- **Scope:**
  - (a) a `Clock` abstraction (system and fixed);
  - (b) `SessionNight {eveningDate, startUtc, endUtc, latitude, longitude}` with invariants;
  - (c) `resolveDefault(now, site)` and `forEveningDate(date, site)`;
  - (d) doc comments with units and assumptions.
- **Out of scope:** calculators (2.3); UI (2.4).
- **Affected areas:** new `lib/domain/models/session_night.dart`, a resolver service, a clock in `lib/core/`.
- **Direction:** the device time zone is never used in computation.
- **Tests:** the ADR table; the window always contains the evening; the resolver is monotonic across a simulated day; longitude ±180°.
- **Acceptance:** all cases pass (the San Francisco case fails on the old code); no `DateTime.now()` left in `lib/domain`.
- **Risk · Complexity · Model:** Medium · M · Opus

### TASK 2.3 — Calculators consume SessionNight
- **Goal:** the timeline, visibility windows and altitude curve are all computed in the domain for a given SessionNight.
- **Current problem (TD-023, TD-024):**
  - calculators treat a `DateTime`'s year/month/day as the local solar date;
  - the chart samples astronomy inside its painter, starting at device-local noon;
  - the timeline is `Map<String, DateTime?>`;
  - a code comment promises a 1-minute refinement that doesn't exist;
  - polar cases return bare nulls.
- **Why now:** removes the divergent time bases.
- **Dependencies:** 2.2.
- **Scope:** SessionNight-based APIs; a typed timeline result with "not reached" reasons; a domain `AltitudeCurve` sampler; the chart becomes render-only; the darkness limit becomes a parameter; the 5-minute step is kept and documented.
- **Out of scope:** Moon (G6); gates (G10).
- **Affected areas:** `visibility_calculator.dart`, new result types, `altitude_chart_widget.dart`, tests.
- **Direction:** keep deprecated wrappers until 2.4 lands.
- **Tests:** existing window tests adapted (±5 min); polar tests; chart and timeline share their instants.
- **Acceptance:** no astronomy imports in widgets; European results unchanged within the 5-minute quantization.
- **Risk · Complexity · Model:** Medium · M · Sonnet

### TASK 2.4 — Planner and UI adopt SessionNight
- **Goal:** the correct night everywhere, with labelled time zones.
- **Current problem (TD-001, F-08, F-09):** Home shows the UTC date with "(Night)"; the date picker means something different from the default; times are printed without a zone; `newSession()` repeats the bug; one test asserts the defect.
- **Why now:** completes the foundation.
- **Dependencies:** 2.3, 1.1.
- **Scope:** the ViewModel holds a SessionNight (resolver plus Clock); the picker selects the evening date; a formatter shows the zone and respects the 24-hour setting; a "no site set" state replaces London; the defect-asserting test is replaced, with the reason recorded; loaded sessions map to their night.
- **Out of scope:** storing the site's zone (7.1); weather alignment (G9).
- **Affected areas:** `planner_viewmodel.dart`, `home_screen.dart`, `sky_darkness_widget.dart`, `altitude_chart_widget.dart`, `logbook_screen.dart`, tests.
- **Direction:** one formatter; no ad-hoc `toLocal()`.
- **Tests:** fixed-clock ViewModel tests (San Francisco at 18:30 PDT → the evening of Sep 21); a header widget test; a load round trip.
- **Acceptance:** an emulator set to America/Los_Angeles at 18:30 shows tonight.
- **Risk · Complexity · Model:** Medium · M · Sonnet

## G3 — Persistence baseline
- **Purpose:** make schema evolution safe before the next schema change.
- **Why it exists:** upgrading from v3 throws, there are no migration tests, foreign keys are off, and one table is orphaned (DEV-D1, DEV-D6).
- **Problems solved:** TD-004, TD-005, part of TD-026; PD-04; the PD-09 approach.
- **Requires:** G0, 1.1 · **Enables:** every schema change (5.3, 7.1, 8.1, 8.4, 10.5, 11.2).
- **Done when:** supported upgrade paths are tested against schema snapshots; foreign keys are enforced; the orphan table is retired; the workflow is documented.

### TASK 3.1 — ADR: persistence baseline and provenance (PD-04, PD-09)
- **Goal:** decide the upgrade floor, the migration workflow, the foreign-key policy, the orphan table, and how provenance is stored.
- **Current problem:** the historical migration steps reuse *current* table definitions, so repairing every path is expensive, and no provenance is stored anywhere (DEV-D5).
- **Why now:** blocks all schema work.
- **Dependencies:** 0.2.
- **Scope:** recommend:
  - **Upgrade floor v8.** Every build since `d0b737f` creates v8 or later; the owner confirms no older installs exist. Older databases get a clear message and a reset path.
  - **Workflow:** Drift schema snapshots and step-by-step migrations from now on.
  - **Foreign keys:** turned on after a one-time integrity check.
  - **Orphan table:** drop `equipment_profiles`.
  - **Provenance:** per-row `source` and `confidence` columns rather than a separate `data_sources` table.
- **Out of scope:** implementation.
- **Affected areas:** DECISIONS; DATA_MODEL (migration rules).
- **Direction:** destructive steps only with explicit approval.
- **Tests:** defines the 3.2 test matrix.
- **Acceptance:** owner-approved.
- **Risk · Complexity · Model:** Medium · S · Opus

### TASK 3.2 — Schema snapshots and migration tests
- **Goal:** supported upgrades are verified, and every future change is tested the same way.
- **Current problem (TD-004):** no snapshots or tests; the v5 step references a removed column.
- **Why now:** the next schema change is 5.3.
- **Dependencies:** 3.1.
- **Scope:**
  - (a) export the v9 snapshot and the v8 one (from `d0b737f`);
  - (b) generated schema-verification tests;
  - (c) a v8→v9 data-preservation test;
  - (d) floor handling per 3.1, or repair the v5 step if the owner rejects the floor;
  - (e) document the workflow in DATA_MODEL.
- **Out of scope:** new columns.
- **Affected areas:** `app_database.dart`, new `drift_schemas/`, `test/data/database/`, `docs/DATA_MODEL.md`.
- **Direction:** Drift's documented migration tooling.
- **Tests:** the migration tests themselves.
- **Acceptance:** a v8 database with sample rows upgrades intact.
- **Risk · Complexity · Model:** Medium · M · Sonnet

### TASK 3.3 — Enforce foreign keys; retire the orphan table
- **Goal:** referential integrity and no dead schema.
- **Current problem (TD-005, TD-026):** foreign keys are off (an orphan insert was verified); deleting a rig removes its camera and device without checking references; `equipment_profiles` is unused.
- **Why now:** the Session aggregate depends on relationships.
- **Dependencies:** 3.2.
- **Scope:** in `beforeOpen`, an integrity check, logged orphan cleanup, then foreign keys on; blocks cascade with their session; guarded deletes of shared rows; drop the orphan table in a tested migration; update `app_database_test`.
- **Out of scope:** new relationships.
- **Affected areas:** `app_database.dart`, Drift repositories, tests.
- **Direction:** one migration step with an updated snapshot.
- **Tests:** an orphan insert fails; deleting a session cascades; the migration test passes.
- **Acceptance:** tests confirm foreign keys are on.
- **Risk · Complexity · Model:** Medium · S · Sonnet

## G4 — Correctness and scientific-honesty fixes
- **Purpose:** fix the verified visible defects and misleading outputs that don't need new models.
- **Why it exists:** today users see wrong block order, duplicate logs, stale selections, mojibake, "SNR", "0.0 MB" and "f/72".
- **Problems solved:**
  - TD-008 (the seed), TD-009, TD-010, TD-011 (duplicate saves), TD-012, TD-013, TD-014, TD-015, TD-028, TD-039, TD-042;
  - SI-002 (display precision), SI-003 (label), SI-005 (seed), SI-008.
- **Requires:** G1, 0.2 · **Enables:** G5 (4.1 must come before 5.6).
- **Done when:** those items are marked resolved; the string "SNR" doesn't appear in `lib/`; unknown values are shown as unknown.

### TASK 4.1 — Capture-block editing defects
- **Goal:** blocks reorder correctly, can be edited, and reject invalid input.
- **Current problem (TD-010, TD-012):** a block dragged down lands one slot short; list keys are built from hashCode and index; invalid input silently becomes 60 s × 30; there is no edit UI.
- **Why now:** the planner is the core surface.
- **Dependencies:** 1.1.
- **Scope:** fix the index handling; stable keys; validators (exposure > 0, count ≥ 1); an edit dialog.
- **Out of scope:** model or schema changes (5.3).
- **Affected areas:** `capture_plan_widget.dart`, `planner_viewmodel.dart`.
- **Direction:** follow the `onReorderItem` contract.
- **Tests:** reorder up, down, to first and to last; invalid input rejected; editing updates the block.
- **Acceptance:** all reorder cases produce the expected order.
- **Risk · Complexity · Model:** Low · S · Sonnet

### TASK 4.2 — Save, selection and logbook consistency
- **Goal:** saves, selections and deletions stay consistent.
- **Current problem (TD-011, TD-028, TD-039, plus a new finding):**
  - a second tap on Save inserts a second row;
  - deleting *or editing* the selected rig or target leaves stale state in the planner;
  - the logbook is unordered, and swipe-delete has no confirmation.
- **Why now:** data integrity before sessions are built on top.
- **Dependencies:** 1.1.
- **Scope:** `addLog` returns the id and the ViewModel tracks it; the selection is refreshed or cleared after an edit or delete; newest-first ordering; delete confirmation (or undo); record the edit-staleness finding in TECH_DEBT.
- **Out of scope:** snapshots (11.3).
- **Affected areas:** logbook repository, ViewModel, Home, equipment, target and logbook screens.
- **Direction:** re-read selections by id.
- **Tests:** two saves produce one row; deleting the selected rig clears it (also after a restart); delete requires confirmation.
- **Acceptance:** those tests pass.
- **Risk · Complexity · Model:** Low · S · Sonnet

### TASK 4.3 — Encoding fixes and gate enforcement
- **Goal:** correct text, and the PD-06 gate policy enforced everywhere.
- **Current problem (TD-015, TD-014):** mojibake (`Вµm`, `В°`, broken box-drawing comments); the field-mode toggle ignores its gate; the map card is ungated; Home pushes gated routes unconditionally.
- **Why now:** cheap, and it removes misleading UI.
- **Dependencies:** 0.2.
- **Scope:** fix encodings and add a UTF-8 check; gate every entry point (buttons, cards, routes) from one place; the map card uses the site's coordinates or stays hidden.
- **Out of scope:** the gated features themselves.
- **Affected areas:** `home_screen.dart`, `sky_darkness_widget.dart`, `app_router.dart`, `feature_scope.dart`, equipment and target screens.
- **Direction:** gates read from a single source.
- **Tests:** a gated feature has no entry point; labels render "µm" and "°".
- **Acceptance:** grep finds no mojibake; the gates match DECISIONS.
- **Risk · Complexity · Model:** Low · S · Sonnet

### TASK 4.4 — Honest numbers and labels
- **Goal:** no misleading figure or claim in the current UI.
- **Current problem (TD-009, TD-013, TD-008, TD-033, TD-042):**
  - the "Relative SNR" label (restored on purpose in `1baa514`, against CLAUDE.md rule 18);
  - Moon illumination shown to 0.1 %;
  - "0.0 MB" and "null arcsec/px";
  - RA/Dec (0,0) used as an "unset" sentinel;
  - the default plan looks like the user's;
  - the "will wash out" warning;
  - the seeded "f/72";
  - an unsourced "≥1 mag" comment.
- **Why now:** credibility, cheaply.
- **Dependencies:** the owner explicitly settles the SNR-label conflict.
- **Scope:**
  - rename the label to "Relative stacking gain (√N vs one frame)";
  - show illumination as a whole percentage marked approximate;
  - show "unknown" where there is no value;
  - remove the (0,0) sentinel;
  - label the default as an "Example plan";
  - make the warning text neutral;
  - change the seed to f/5.6 (400/72);
  - fix the related comments;
  - record everything in DECISIONS and the SI register.
- **Out of scope:** the Moon model (G6); the budget (G5).
- **Affected areas:** planner and sky widgets, Home, ViewModel, `optical_calculator.dart` (storage returns null when unknown), `equipment_seeder.dart`.
- **Direction:** unknown values are null in the domain.
- **Tests:** unknown storage in → null out; label text; the seed's focal ratio is plausible.
- **Acceptance:** "SNR" is absent from `lib/`.
- **Risk · Complexity · Model:** Low · S · Sonnet

## G5 — Capture Budget (core product feature)
- **Purpose:** turn the available windows into a realistic plan: integration vs acquisition vs total budget, calibration policy, fit analysis, and "what fits instead".
- **Why it exists:** the current math conflates everything; overhead is unsourced; the margin is fixed; the √N gain is mislabelled; unknown storage shows as zero.
- **Problems solved:** TD-022, TD-043, DEV-A4; SI-004, SI-006 (planning part), SI-013; F-35–F-39; PD-08.
- **Requires:** G2 (windows), G3 (schema), 4.1 · **Enables:** G10 (the fit input becomes the opportunity), G11, G13, G14.
- **Done when:** every budget number comes from one tested domain calculator with visible assumptions, and the fit uses the night's windows.

### TASK 5.1 — ADR: capture-budget semantics (PD-08)
- **Goal:** one definition of what consumes the night.
- **Current problem:** the "required time" is Σ(every block's exposure) + 5 s per frame; the 15 % model is dead code; calibration frames always count against the dark window; the margin is fixed at 85 %.
- **Why now:** gates all of G5.
- **Dependencies:** 2.1.
- **Scope:** define:
  - **Integration:** Σ light exposure.
  - **Acquisition:** integration + per-frame overhead (download or interval) + periodic overhead (dither every N frames plus settle, refocus every T, meridian flip).
  - **Session budget:** acquisition + in-window calibration + setup.
  - **Available-time contract:** a list of UTC windows for a SessionNight. It starts as darkness ∩ altitude and later becomes the Imaging Opportunity output, with no API change.
  - **Calibration policy per block:** in-window, outside the window, or from a library.
  - **Margin:** configurable.
- **Out of scope:** implementation.
- **Affected areas:** DECISIONS; new CALC entries in SCIENTIFIC_INTEGRITY.
- **Direction:** at least 5 worked examples, including a split window, an untracked smartphone plan, calibration outside the window, and a night with no window.
- **Tests:** the examples become test vectors.
- **Acceptance:** owner-approved.
- **Risk · Complexity · Model:** Medium · S · Opus

### TASK 5.2 — Planning preferences and a minimal Settings screen
- **Goal:** user-meaningful thresholds are named, documented and configurable.
- **Current problem (TD-043, SI-006):** minimum altitude and dew margin are persisted but have no UI; the darkness limit is fixed at −18°; the ViewModel touches SharedPreferences directly.
- **Why now:** the budget and windows read these values.
- **Dependencies:** 5.1.
- **Scope:** a `PlanningPreferences` value type and repository covering minimum altitude, darkness limit (−18/−15/−12°), feasibility margin, overhead defaults and dew margin; a Settings screen explaining each as a preference, not a law.
- **Out of scope:** units; theme.
- **Affected areas:** domain and data preference files, a settings screen, the router, the ViewModel.
- **Direction:** defaults are documented assumptions.
- **Tests:** round trip and clamping; a slider persists its value.
- **Acceptance:** no SharedPreferences imports in ViewModels; changing a threshold updates the windows.
- **Risk · Complexity · Model:** Low · M · Sonnet

### TASK 5.3 — CaptureBlock model and schema
- **Goal:** blocks carry their order, calibration policy and a typed gain, and invalid blocks cannot exist.
- **Current problem (SI-004):** no position column; gain/ISO is free text; no validation.
- **Why now:** the budget calculator needs policy and order.
- **Dependencies:** 5.1, 3.2.
- **Scope:** domain validation; a `position` column; a `calibrationPolicy`; a typed gain {iso | gain | unknown, value}, descriptive only; the migration and snapshot; a versioned plan JSON until 11.4.
- **Out of scope:** execution counters (11.2).
- **Affected areas:** `capture_block.dart`, the `CaptureBlocks` table, repositories, ViewModel serialization.
- **Direction:** validation in factories, not widgets.
- **Tests:** validation; migration; order preserved.
- **Acceptance:** invalid values are rejected at the domain boundary.
- **Risk · Complexity · Model:** Low · M · Sonnet

### TASK 5.4 — CaptureBudgetCalculator
- **Goal:** one pure calculator for integration, acquisition, session budget and storage.
- **Current problem (TD-022, DEV-A4, SI-013):** the live math lives in the ViewModel and has no tests; `estimateTotalDuration` is dead code.
- **Why now:** this is the core feature.
- **Dependencies:** 5.3, 5.2.
- **Scope:**
  - (a) overhead parameters with defaults labelled "assumption — measure your rig";
  - (b) a per-block and total breakdown object;
  - (c) per-block storage, "unknown" when the file size is missing, labelled as an estimate;
  - (d) delete the dead code, with a DECISIONS note.
- **Out of scope:** fit (5.5).
- **Affected areas:** `session_calculator.dart` → `capture_budget_calculator.dart`, the ViewModel.
- **Direction:** returns typed values, never strings.
- **Tests:** the ADR vectors exactly; zero and edge cases.
- **Acceptance:** no budget arithmetic left in ViewModels.
- **Risk · Complexity · Model:** Low · M · Sonnet

### TASK 5.5 — Fit analysis
- **Goal:** tell the user whether and how the plan fits the night.
- **Current problem (F-36):** a single sum-of-windows comparison; a fixed 85 % margin; no end time; no inverse answer.
- **Why now:** this is the product's answer.
- **Dependencies:** 5.4, 2.3.
- **Scope:** place in-window blocks, in order, into the windows, respecting gaps; report fits / tight / doesn't fit with a reason, the projected end time, unused time, and the frames that don't fit; the inverse question (maximum frames of exposure X that fit); a text hint for how many similar nights are needed.
- **Out of scope:** scheduling several targets in one night.
- **Affected areas:** a domain fit analyzer; the ViewModel.
- **Direction:** every result carries a human-readable reason.
- **Tests:** single, split and zero windows; the exact-fit boundary; margin configuration.
- **Acceptance:** the vectors pass.
- **Risk · Complexity · Model:** Medium · M · Sonnet

### TASK 5.6 — Capture planner UI
- **Goal:** inputs → outputs, with the assumptions visible.
- **Current problem (F-35–F-37, SI-003):** one conflated "Session Duration"; hard-coded colours.
- **Why now:** surfaces 5.4 and 5.5.
- **Dependencies:** 5.5, 4.1.
- **Scope:** a block editor (policy, typed gain); outputs for integration, acquisition and total vs available time, the fit with its reason and end time; √N shown per light block of a single exposure length, with help text; storage or "unknown"; a "fill the window" action; an assumptions panel.
- **Out of scope:** execution.
- **Affected areas:** `capture_plan_widget.dart`, split into smaller widgets.
- **Direction:** no calculations in widgets.
- **Tests:** breakdown rendering; unknown storage; help text.
- **Acceptance:** a user can see why a plan doesn't fit and fix it with one action.
- **Risk · Complexity · Model:** Low · M · Sonnet

## G6 — Astronomical conditions
- **Purpose:** reference-tested Sun and target math, a real Moon model, and a corrected NPF.
- **Why it exists:** the Moon is in the MVP scope and missing; there are no reference tests; the NPF formula is wrong.
- **Problems solved:** TD-007, TD-032, TD-036; SI-001, SI-002, SI-009; PD-07, PD-16; F-15, F-16.
- **Requires:** G2 · **Enables:** G8 (moving types, NPF), G10.
- **Done when:** every astronomy function states its units, source, assumptions and error bound and is tested against independent references; MoonConditions exist for each night and target.

### TASK 6.1 — ADR: ephemeris approach and moving objects (PD-07, PD-16)
- **Goal:** decide how the Moon is computed and what stays out of scope.
- **Current problem:** undecided since Phase 0; the UI offers Planet, Moon, Comet and Asteroid, which a fixed RA/Dec cannot represent.
- **Why now:** blocks 6.3 and 8.1.
- **Dependencies:** 2.1.
- **Scope:** choose between (A) a pure-Dart Meeus ch. 47/48 truncated series (recommended: offline, deterministic, consistent with the existing Meeus-based code), (B) a Dart package after licence and accuracy checks, or (C) an online ephemeris (rejected: offline-first). Hide moving objects in 1.0. Set planning-grade tolerances and name the references (USNO, JPL Horizons).
- **Out of scope:** implementation.
- **Affected areas:** DECISIONS; the SI register.
- **Direction:** tolerances for position, rise/set and illumination.
- **Tests:** sets the 6.3 acceptance criteria.
- **Acceptance:** owner-approved.
- **Risk · Complexity · Model:** Low · S · Opus

### TASK 6.2 — Independent reference fixtures; document simplifications
- **Goal:** astronomy validated against published sources, not against itself.
- **Current problem (TD-036, SI-009):** undocumented simplifications — J2000 without precession (~0.36°), geometric altitude, UTC ≈ UT1, 5-minute quantization; tests are sanity checks or circular.
- **Why now:** must come before any formula change.
- **Dependencies:** 2.3, 6.1.
- **Scope:** fixture files with cited values (USNO Sun and Moon events; JPL Horizons altitude/azimuth for 2–3 deep-sky objects at 3 sites); tolerance tests; doc comments for each CALC entry; record the precession and refraction decision.
- **Out of scope:** formula changes.
- **Affected areas:** `test/fixtures/astronomy/`, doc comments, SI Part B.
- **Direction:** each fixture records its source, query and retrieval date.
- **Tests:** the fixtures themselves.
- **Acceptance:** CALC-01 to CALC-11 each have a sourced test.
- **Risk · Complexity · Model:** Low · M · Sonnet

### TASK 6.3 — Moon ephemeris
- **Goal:** topocentric Moon position, altitude, illuminated fraction, and rise/set within a night.
- **Current problem (TD-032, F-16):** a mean-phase model only; no Moon geometry.
- **Why now:** the Imaging Opportunity needs Moon context.
- **Dependencies:** 6.1, 6.2.
- **Scope:** geocentric position from the truncated series → RA/Dec → topocentric correction (parallax up to about 1°) → altitude/azimuth; illumination from the Sun–Moon elongation; rise/set on the night grid; cited constants.
- **Out of scope:** planets; eclipses.
- **Affected areas:** new `moon_calculator.dart` and models.
- **Direction:** reuse the `AstronomicalEngine` time functions; no Flutter imports.
- **Tests:** at least 20 reference instants across at least 2 years and 3 latitudes; USNO phase events.
- **Acceptance:** within the ADR tolerances; measured error recorded in SI-002.
- **Risk · Complexity · Model:** Medium · M · Opus

### TASK 6.4 — MoonConditions; retire the mean-phase model
- **Goal:** Moon context for each night and target.
- **Current problem (SI-002, F-15):** illumination is evaluated at a single instant; the warning ignores Moon altitude.
- **Why now:** makes 6.3 visible to users.
- **Dependencies:** 6.3, 2.3.
- **Scope:** a `MoonConditions` value (altitude, illumination and separation samples; rise/set within the window; minimum separation while both are up); the UI shows when the Moon is up and its separation; delete the old model with a DECISIONS entry.
- **Out of scope:** gating (10.x).
- **Affected areas:** domain; the sky widget; the ViewModel.
- **Direction:** annotations only, no "impact %".
- **Tests:** separation vs a reference; Moon below the horizon.
- **Acceptance:** the old model is removed.
- **Risk · Complexity · Model:** Low · M · Sonnet

### TASK 6.5 — Correct NPF (still hidden)
- **Goal:** NPF per the primary source, with an explicit tolerance factor K.
- **Current problem (TD-007, SI-001):** a constant `+90` replaces the focal-length term; phone results are about 2.9× too long; the test is circular.
- **Why now:** needed for untracked and smartphone guidance (8.6).
- **Dependencies:** 6.1.
- **Scope:** confirm the constants from Michaud's primary document; add a K parameter (default 1); document how declination is handled; independent worked examples; a DECISIONS entry; PD-11 stays "hidden".
- **Out of scope:** UI.
- **Affected areas:** `optical_calculator.dart` and its test.
- **Direction:** follows rule 04 (document formula, source, assumptions).
- **Tests:** at least 3 published examples, including a phone lens.
- **Acceptance:** SI-001 marked "fixed, unsurfaced".
- **Risk · Complexity · Model:** Low · S · Opus

## G7 — Sites and location
- **Purpose:** saved sites with a time zone and honest sky-darkness data, and location and geocoding behind interfaces.
- **Why it exists:** saved locations are MVP scope but not delivered; `setLocation` overwrites the saved profile; Bortle 4 is presented as fact.
- **Problems solved:** TD-006, TD-020 (display part), TD-027, TD-031 (OpenStreetMap part); SI-007; DEV-D4; PD-05; F-06, F-07, F-10, F-32–F-34.
- **Requires:** G3, 2.4 · **Enables:** G9, 10.5, G11.
- **Done when:** users manage and switch sites; the current position never mutates a saved site; "unknown" is representable; the site's zone drives the display.

### TASK 7.1 — Site model and schema
- **Goal:** Site semantics on top of `location_profiles`.
- **Current problem (TD-027, SI-007):** Bortle is an int that can't be unknown; no time zone; elevation unit unspecified; the active site is a pointer in SharedPreferences.
- **Why now:** sessions and weather need a stable site.
- **Dependencies:** 3.2, 2.4.
- **Scope:** an additive migration with nullable Bortle plus its source and date, optional SQM (mag/arcsec²), elevation in metres, a nullable IANA zone and notes; the current position stays transient unless saved; the formatter prefers the site's zone; the legacy Bortle value of 4 becomes null with a "legacy default" note (owner decision).
- **Out of scope:** UI; horizon.
- **Affected areas:** locations table and snapshot, domain model, repository, ViewModel.
- **Direction:** additive only.
- **Tests:** migration with legacy rows; CRUD; the formatter uses the site's zone.
- **Acceptance:** no code path writes into a saved site without explicit user action.
- **Risk · Complexity · Model:** Medium · M · Sonnet

### TASK 7.2 — Location and geocoding services
- **Goal:** isolate platform and network calls and make permission outcomes understandable.
- **Current problem (TD-019 part, TD-029, TD-031):** Geolocator is called from the ViewModel and a screen; Nominatim is called with an empty catch and no cache; there is no OpenStreetMap attribution; the tile user agent is `com.example.astroplan`.
- **Why now:** prerequisite for 7.3, and a compliance issue.
- **Dependencies:** 1.1.
- **Scope:** `LocationService` states (disabled, denied, denied forever, granted) with rationale text and "open settings"; a `ReverseGeocoder` with a Nominatim implementation (identifying user agent, at most 1 request per second, cache by rounded coordinates, attribution); map attribution; the real app id as user agent; manual coordinate entry offline.
- **Out of scope:** place search.
- **Affected areas:** domain interfaces, data services, the ViewModel, the location picker.
- **Direction:** interfaces in the domain, implementations in the data layer.
- **Tests:** a fake for each permission state; geocoder cache and failure.
- **Acceptance:** no `http` or `geolocator` imports in presentation or domain.
- **Risk · Complexity · Model:** Low · M · Sonnet

### TASK 7.3 — Sites UI and first-run site setup
- **Goal:** list, create, edit, delete and select sites; the first run asks for one.
- **Current problem:** a map picker only; no names; effectively a single row.
- **Why now:** makes 7.1 usable.
- **Dependencies:** 7.1, 7.2.
- **Scope:** a sites list with the active one marked; an editor (validated latitude/longitude, elevation, a zone picker defaulting to the device zone, Bortle/SQM with source); "use current position" (transient) and "save as site"; a first-run prompt.
- **Out of scope:** navigation redesign.
- **Affected areas:** new `screens/sites/`, picker, router, ViewModel.
- **Direction:** reuse the existing form validators.
- **Tests:** validation; the selection persists; deleting the active site.
- **Acceptance:** switching sites changes all night times.
- **Risk · Complexity · Model:** Low · M · Sonnet

### TASK 7.4 — Light-pollution MVP; remove the scraper (PD-05)
- **Goal:** honest sky-darkness input without brittle or assumed sources.
- **Current problem (TD-006, F-32–F-34):** the scraper can never work (its URL is never interpolated) and carries terms-of-service risk; it runs on every location change.
- **Why now:** closes SI-007 with the cheapest safe option.
- **Dependencies:** 7.1, 7.3.
- **Scope:**
  - **A (MVP):** open the external map at the site's coordinates.
  - **B (MVP):** manual Bortle and/or SQM entry with source "user" and a date.
  - Delete `LightPollutionRepository`; sky context becomes unknown-aware.
  - Document **C** (an offline dataset: licence, size, and the uncertainty of converting radiance to SQM) and **D** (a licensed API, only if a real one with acceptable terms is verified) as deferred.
- **Out of scope:** datasets and APIs.
- **Affected areas:** the repository (deleted), ViewModel, `main.dart`, site editor, feature gates.
- **Direction:** no Bortle↔SQM conversion unless it is sourced.
- **Tests:** no network call on a location change; logic for unknown vs known values.
- **Acceptance:** no scraping code remains.
- **Risk · Complexity · Model:** Low · S · Sonnet

## G8 — Targets and equipment
- **Purpose:** trustworthy target and equipment data with explicit units, provenance and capability figures.
- **Why it exists:** mixed aperture semantics, unit-less fields, hidden tracking type, unverified seeds, 5 targets.
- **Problems solved:** TD-008, TD-016, TD-026, TD-035; SI-005, SI-011, SI-012; PD-03, PD-10, PD-11; F-20, F-23, F-25, F-26.
- **Requires:** G3, G6 (6.1, 6.5), 5.6 · **Enables:** 10.4, G11.
- **Done when:** fields have units and validation; tracking type is visible; seeds are sourced; the catalog is licence-compliant.

### TASK 8.1 — Target model hardening
- **Goal:** fixed-coordinate targets with provenance and sensible input.
- **Current problem (TD-016, SI-012):**
  - moving object types are offered;
  - RA can only be entered in degrees;
  - editing overwrites the catalog ID;
  - no uniqueness, epoch or source;
  - `LIKE` wildcards in search aren't escaped.
- **Why now:** Opportunity and FOV fit need clean targets.
- **Dependencies:** 6.1, 3.2.
- **Scope:** hide moving types; accept RA as h:m:s or hours and Dec as d:m:s; additive columns (epoch defaulting to J2000, source, angular size in arcmin, magnitude); edits keep the catalog ID; uniqueness for catalog entries; escape search wildcards.
- **Out of scope:** catalog import.
- **Affected areas:** targets table and snapshot, model, repository, target screen, `AstroMath` parsers.
- **Direction:** parsing is pure; the UI only formats.
- **Tests:** HMS/DMS parsing (including −0°30′); migration; edits keep the id.
- **Acceptance:** "05h35m17s / −05°23′28″" is stored as the correct degrees.
- **Risk · Complexity · Model:** Low · M · Sonnet

### TASK 8.2 — Curated catalog with provenance (cut line: Messier only)
- **Goal:** a practical imaging list (Messier plus selected NGC/IC showpieces).
- **Current problem (F-20, TD-035):** 5 seeded targets; the seeder resurrects deleted defaults.
- **Why now:** the candidates list (10.4) needs targets.
- **Dependencies:** 8.1.
- **Scope:** candidate source OpenNGC (verify its licence — CC BY-SA 4.0 at last check — and compatibility with the repo's GPL-3.0, PD-12); a versioned asset; versioned seeding that never resurrects deletions; attribution in About.
- **Out of scope:** online search; images.
- **Affected areas:** `assets/catalog/`, `catalog_seeder.dart`, `pubspec.yaml`.
- **Direction:** the seed version is stored in preferences.
- **Tests:** parsing; spot checks against the source; idempotency.
- **Acceptance:** 110–250 objects with epoch, source and size.
- **Risk · Complexity · Model:** Low · M · Sonnet

### TASK 8.3 — ADR: equipment model and aperture semantics (PD-03, PD-10)
- **Goal:** decide the 1.0 equipment model.
- **Current problem (DEV-D2):** rigid 1:1:1 tables behind a flat profile; a dormant catalog repository; `aperture` means f-number but one seed stores a diameter.
- **Why now:** blocks 8.4 and the snapshots.
- **Dependencies:** 0.2.
- **Scope:** recommend:
  - keep the flat profile for 1.0 (camera reuse UI deferred);
  - unit-explicit names;
  - focal ratio plus an optional diameter in mm, each derivable from the other;
  - tracking type {untracked, tracked, guided, unknown} using the existing column;
  - an optional maximum exposure;
  - user rows are never auto-reinterpreted — values above f/32 are flagged for review;
  - remove or keep the dormant repository.
- **Out of scope:** implementation.
- **Affected areas:** DECISIONS; DATA_MODEL.
- **Direction:** minimal schema churn.
- **Tests:** n/a.
- **Acceptance:** owner-approved.
- **Risk · Complexity · Model:** Low · S · Opus

### TASK 8.4 — Equipment domain and schema
- **Goal:** implement 8.3.
- **Current problem (TD-026, SI-005):** the tracking column is invisible; validation only checks "> 0".
- **Why now:** planner guidance needs tracking type and maximum exposure.
- **Dependencies:** 8.3, 3.3.
- **Scope:** domain renames (`focalLengthMm`, `focalRatio`, `pixelPitchUm`, …); documented plausibility ranges; tracking type, maximum exposure and optional diameter; updated form; a review prompt for flagged rows.
- **Out of scope:** composition UI.
- **Affected areas:** equipment tables and snapshot, model, repository, screen, ViewModel.
- **Direction:** renames happen in Dart; columns change only when necessary.
- **Tests:** migration with sample rows; validation bounds; mapping.
- **Acceptance:** every equipment number carries a unit in code and in the UI.
- **Risk · Complexity · Model:** Medium · M · Sonnet

### TASK 8.5 — Seed verification and provenance
- **Goal:** every seeded spec has a primary source and a confidence level, or is removed.
- **Current problem (TD-008, SI-011):**
  - phone specs are unverified;
  - the Xiaomi and Vivo sensor heights differ from resolution × pitch by 10.5 %;
  - `manufacturer` means the device brand in some seeds and the sensor vendor in others;
  - no RAW file sizes;
  - phone pixel pitch is ambiguous (full resolution vs binned).
- **Why now:** capability figures are only as good as the seeds.
- **Dependencies:** 8.4, 3.1 (PD-09).
- **Scope:** verify against manufacturer pages; store source and confidence; decide whether sensor size is stored or derived; profile the phone RAW mode people actually use, or ship fewer phone seeds.
- **Out of scope:** device databases.
- **Affected areas:** the seeder (or an asset); provenance docs.
- **Direction:** fewer correct seeds beat many unverified ones.
- **Tests:** stored sensor size matches resolution × pitch within 2 % unless documented.
- **Acceptance:** SI-011 closed or explicitly limited.
- **Risk · Complexity · Model:** Low · M · Sonnet

### TASK 8.6 — Capability summary and untracked/smartphone guidance
- **Goal:** show what the rig can do, and give realistic sub-exposure guidance for tripod and phone users.
- **Current problem (F-25, F-26, PD-11):** FOV is computed but unused; NPF isn't shown; the planner doesn't link tracking type to exposure.
- **Why now:** needs 6.5, 8.4 and the planner UI.
- **Dependencies:** 6.5, 8.4, 8.1, 5.6.
- **Scope:** FOV (width × height in degrees); pixel scale ("/px); an NPF recommendation for untracked rigs (showing K and the target's declination); recommended maximum sub = min(NPF, maximum exposure); FOV-fit ratio; a planner warning when a light block exceeds the recommendation; decide PD-11.
- **Out of scope:** seeing-based advice; camera control.
- **Affected areas:** domain capability service, ViewModel, equipment and planner UI.
- **Direction:** guidance never blocks the user.
- **Tests:** reference FOV values; NPF shown only when untracked; warning boundaries.
- **Acceptance:** a phone with a 30 s block shows the NPF value and a warning.
- **Risk · Complexity · Model:** Low · S · Sonnet

## G9 — Weather
- **Purpose:** provider-isolated, UTC-aligned, staleness-aware indicators for the chosen night, with no score.
- **Why it exists:** the forecast is always "now + 48 h"; times are naive; the cache never expires; the model is hard-coded; the dew warning is never shown.
- **Problems solved:** TD-017; SI-010 (weather part); PD-15; F-29–F-31.
- **Requires:** G2, 5.2 · **Enables:** G10, G11, G13.
- **Done when:** hourly data is stored in UTC with provider and model metadata, sliced to the night, with visible states.

### TASK 9.1 — ADR: provider, variables, alignment, staleness (PD-15)
- **Goal:** decisions before the rewrite.
- **Current problem:** implicit choices (`icon_seamless`, 48 h, `timezone=auto`).
- **Why now:** blocks 9.2–9.4.
- **Dependencies:** 2.1.
- **Scope:**
  - Open-Meteo stays, pending verification of its terms (PD-12);
  - `best_match` vs a fixed or user-chosen model;
  - variables: cloud cover (total/low/mid/high), precipitation probability, wind and gusts, temperature, dew point, relative humidity, and visibility — labelled horizontal visibility, **not** transparency;
  - UTC/unixtime timestamps;
  - a horizon of at most 16 days, with "no forecast" beyond it;
  - staleness thresholds;
  - attribution;
  - seeing and transparency deferred.
- **Out of scope:** implementation.
- **Affected areas:** DECISIONS.
- **Direction:** document each variable's meaning and limits.
- **Tests:** n/a.
- **Acceptance:** owner-approved.
- **Risk · Complexity · Model:** Low · S · Sonnet

### TASK 9.2 — WeatherSnapshot and UTC parsing
- **Goal:** a typed, UTC-aligned snapshot.
- **Current problem (TD-017):** naive times; a fixed 48 entries; `lastUpdated` in device time; no metadata; the parser assumes arrays contain no nulls.
- **Why now:** everything downstream consumes it.
- **Dependencies:** 9.1.
- **Scope:** `WeatherSnapshot {provider, model, fetchedAtUtc, lat, lon, hourly (UTC, nullable fields)}`; request a date range that covers the night; nulls become unknown.
- **Out of scope:** caching; UI.
- **Affected areas:** weather model and repository, interface, tests.
- **Direction:** parsing only in the data layer.
- **Tests:** recorded fixtures (normal, nulls, short arrays, error, non-200); a site in a different zone from the test machine.
- **Acceptance:** the device time zone doesn't change parsed instants.
- **Risk · Complexity · Model:** Low · M · Sonnet

### TASK 9.3 — Caching, staleness and failure states
- **Goal:** offline-friendly weather that never pretends to be fresh.
- **Current problem:** a per-cell cache served forever; a failed forced refresh is silent.
- **Why now:** offline-first requirement.
- **Dependencies:** 9.2, 2.2.
- **Scope:** cache keyed by rounded coordinates and model, with the fetch time; freshness levels as named constants; expired data is not shown as a forecast; states for loading, fresh, stale (with age), offline-cached, unavailable and out of range.
- **Out of scope:** background refresh.
- **Affected areas:** repository, ViewModel.
- **Direction:** driven by the Clock.
- **Tests:** a fake clock across the thresholds; failure with and without a cache.
- **Acceptance:** airplane mode shows cached data with its age.
- **Risk · Complexity · Model:** Low · M · Sonnet

### TASK 9.4 — Night-aligned indicators and UI
- **Goal:** show only what matters for the chosen night, transparently.
- **Current problem (F-30, F-31):** a 48-hour strip from local midnight; undocumented colour bands; the dew warning is unused.
- **Why now:** Opportunity annotations and the dashboard need it.
- **Dependencies:** 9.3, 2.4.
- **Scope:** slice to the night; per-hour indicators; dew-point spread vs the configured margin, labelled as a heuristic; the night summary shown as ranges; explicit units; attribution; times labelled with their zone.
- **Out of scope:** gating; unit preferences.
- **Affected areas:** `weather_forecast_widget.dart` (rewritten), domain summary.
- **Direction:** the summary is a pure function.
- **Tests:** summary math; stale, unavailable and out-of-range states.
- **Acceptance:** a night 5 days ahead shows its own hours, or "no forecast".
- **Risk · Complexity · Model:** Low · M · Sonnet

## G10 — Imaging Opportunity
- **Purpose:** compute and explain when a target can be imaged: gates (darkness, altitude, optional horizon) plus annotations (Moon, weather), with reasons and no score.
- **Why it exists:** today it is only darkness ∩ altitude; "max altitude" is taken at culmination even in daylight.
- **Problems solved:** TD-033, TD-034; SI-006; F-17, F-18, F-38.
- **Requires:** G5, G6, G7, G8 (8.1), G9 · **Enables:** G11, G12, G13.
- **Done when:** one calculator returns windows, reasons and annotations; the budget fit consumes them; the user's list can be ranked by usable time.

### TASK 10.1 — ADR: opportunity semantics (PD-17, new)
- **Goal:** decide which conditions gate and which only annotate.
- **Current problem:** fixed gates and a heuristic warning (Moon > 0.8 or Bortle ≥ 7).
- **Why now:** gates 10.2.
- **Dependencies:** 5.1, 6.1, 9.1.
- **Scope:** gates are Sun ≤ the darkness limit, target ≥ the minimum altitude, and the horizon; annotations cover Moon altitude, illumination and separation, cloud, and dew; optional user-enabled Moon or cloud gates; explicitly "no composite score".
- **Out of scope:** implementation.
- **Affected areas:** DECISIONS; the SI register.
- **Direction:** worked examples, including narrowband imaging with the Moon up.
- **Tests:** test vectors.
- **Acceptance:** owner-approved.
- **Risk · Complexity · Model:** Low · S · Opus

### TASK 10.2 — ImagingOpportunity calculator
- **Goal:** deterministic windows, reasons and annotations.
- **Current problem (F-38):** visibility windows only.
- **Why now:** this is the budget's real input.
- **Dependencies:** 10.1, 6.4, 9.4, 5.5.
- **Scope:**
  - (a) inputs: night, site, target, preferences, and optionally Moon, weather and horizon;
  - (b) gate state per sample;
  - (c) UTC windows with annotations;
  - (d) reasons for excluded segments;
  - (e) totals, plus maximum altitude *inside* the dark windows;
  - (f) Sun samples shared across targets;
  - (g) switch the 5.5 fit input to these windows (no API change).
- **Out of scope:** UI.
- **Affected areas:** new calculator and models; the fit analyzer wiring.
- **Direction:** missing inputs mean missing annotations, never zeros.
- **Tests:** ADR vectors; polar night and midnight sun; a target that never rises; a circumpolar dip.
- **Acceptance:** the vectors pass; the fit uses the opportunity windows.
- **Risk · Complexity · Model:** Medium · M · Opus

### TASK 10.3 — Opportunity presentation
- **Goal:** one "tonight for this target" view, with reasons.
- **Current problem (TD-034, F-18):** a decorative gradient bar; separate cards with inconsistent inputs; a heuristic warning.
- **Why now:** users need to see why time is available or not.
- **Dependencies:** 10.2.
- **Scope:** a timeline (darkness bands, target altitude, Moon altitude, highlighted windows); a text list of windows with annotations; remove the heuristic warning.
- **Out of scope:** the dashboard.
- **Affected areas:** chart, sky widget, Home.
- **Direction:** the chart and the list render the same result object.
- **Tests:** list text; the no-window reason.
- **Acceptance:** every excluded period shows its reason.
- **Risk · Complexity · Model:** Low · M · Sonnet

### TASK 10.4 — Tonight's candidates
- **Goal:** answer "what can I photograph tonight" across the user's list, without a score.
- **Current problem:** only one target can be evaluated at a time.
- **Why now:** this is the literal core question, and cheap once 10.2 exists.
- **Dependencies:** 10.2, 8.2.
- **Scope:** usable minutes, window start and end, maximum altitude, minimum Moon separation and FOV fit for each target; sort and filter by a user-chosen column; batch work off the UI thread if needed.
- **Out of scope:** recommendations; discovery.
- **Affected areas:** a batch evaluator, a list UI, the ViewModel.
- **Direction:** sorting only.
- **Tests:** results equal the single-target view; a 250-target performance test.
- **Acceptance:** under 1 s for 250 targets on a mid-range device.
- **Risk · Complexity · Model:** Low · M · Sonnet

### TASK 10.5 — Azimuth and horizon profile (cut line)
- **Status (2026-09-23): CUT for 1.0 by the owner** (keeps the ADR-013 horizon deferral; the gate stays reserved). Not implemented.
- **Goal:** real obstructions act as a gate.
- **Current problem (F-17):** azimuth isn't computed anywhere; the horizon is assumed flat.
- **Why now:** the biggest practical constraint for backyard imagers, and small once 10.2 exists.
- **Dependencies:** 10.2, 7.1.
- **Scope:** azimuth (documented convention: N = 0°, E = 90°); a per-site horizon of 16 sectors (migration); a simple editor; gating in the calculator.
- **Out of scope:** AR or camera-based horizon capture.
- **Affected areas:** calculators, sites schema and editor.
- **Direction:** linear interpolation between sectors, documented.
- **Tests:** azimuth references; a window shrinks behind an obstruction.
- **Acceptance:** a 40° obstruction in the east removes the low eastern part of the window.
- **Risk · Complexity · Model:** Low · M · Sonnet

## G11 — Session aggregate and persistence
- **Purpose:** one persisted Session (plan → execution → log) with stable references and immutable snapshots; retire the plan stored in SharedPreferences.
- **Why it exists:** state is split across three stores (DEV-D4); logs are string-referenced and have no snapshots (DEV-D3).
- **Problems solved:** TD-011 (snapshots and references), TD-045 (optional); DEV-D3, DEV-D4.
- **Requires:** G3, G5, G7, G8, G9, G10 · **Enables:** G12–G14, G17.
- **Done when:** sessions can be created, saved, reopened and duplicated; they survive a restart; they keep their context after the source site, target or rig is edited or deleted.

### TASK 11.1 — ADR: Session aggregate, lifecycle and snapshots (PD-18, new)
- **Goal:** decide the aggregate before migrating.
- **Current problem:** `SessionLog` conflates plan and result; the "current session" is implicit ViewModel state.
- **Why now:** gates 11.2 and 12.1.
- **Dependencies:** 10.1, 9.1, 8.3, 7.1.
- **Scope:**
  - **Root:** id, night key (evening date + site), status {draft, planned, in-progress, completed, abandoned}, UTC timestamps.
  - **References:** nullable site, target and equipment references.
  - **Snapshots:** versioned JSON of site, target, rig, plan assumptions, opportunity and weather, taken at plan save and at execution start.
  - **LogbookEntry** = a completed Session, not a separate entity.
  - **ExecutionState** = status + block counters + events.
  - **Storage:** evolve `session_logs` in place (recommended).
- **Out of scope:** implementation.
- **Affected areas:** DECISIONS; DATA_MODEL.
- **Direction:** history reads snapshots, never live joins.
- **Tests:** n/a.
- **Acceptance:** approved, with an entity diagram.
- **Risk · Complexity · Model:** Medium · S · Opus

### TASK 11.2 — Session schema migration
- **Goal:** the storage side of 11.1.
- **Current problem (DEV-D3):** string references; no status, night or time zone.
- **Why now:** the repository depends on it.
- **Dependencies:** 11.1, 3.3, 5.3.
- **Scope:**
  - (a) additive columns: references (SET NULL on delete), night key, status, timestamps, snapshot JSON with a version;
  - (b) planned, completed and rejected counters on blocks;
  - (c) legacy rows marked "legacy";
  - (d) indexes;
  - (e) optionally, `@DataClassName` renames (TD-045).
- **Out of scope:** repository API.
- **Affected areas:** `app_database.dart` and snapshot, tests.
- **Direction:** Drift type converters for JSON.
- **Tests:** migration with legacy rows; SET NULL behaviour; JSON round trip.
- **Acceptance:** legacy logs are still listed.
- **Risk · Complexity · Model:** High · M · Sonnet (with Opus review)

### TASK 11.3 — SessionRepository and snapshot builders
- **Goal:** transactional persistence and pure snapshot creation.
- **Current problem:** add/update replaces all blocks; there are no status queries.
- **Why now:** needed by the planner and by execution.
- **Dependencies:** 11.2.
- **Scope:** create, update plan, change status, list by status, night or target; get a session with its blocks; pure builders from Site, Target, Equipment, Opportunity, Weather and Budget; replace the LogbookRepository usages.
- **Out of scope:** UI.
- **Affected areas:** domain and data repositories.
- **Direction:** one transaction per aggregate write.
- **Tests:** rollback on failure; a snapshot is unchanged after its source is edited.
- **Acceptance:** editing a rig after saving leaves the saved snapshot intact.
- **Risk · Complexity · Model:** Medium · M · Sonnet

### TASK 11.4 — Planner works on a persisted draft session
- **Goal:** the active plan lives in the database.
- **Current problem (DEV-D4):** the plan JSON and the selected ids live in SharedPreferences.
- **Why now:** removes split-brain state before execution.
- **Dependencies:** 11.3.
- **Scope:** a draft is created or resumed at start; autosave; New, Duplicate for another night, and Open; a one-time migration of the preferences plan; Save moves the session to planned and takes a snapshot.
- **Out of scope:** execution; navigation.
- **Affected areas:** ViewModel, Home, logbook screen, `main.dart`.
- **Direction:** the database is the single source of truth.
- **Tests:** rebuild the ViewModel from the database (restart simulation); a duplicate gets a new night key; the preferences migration.
- **Acceptance:** force-stopping the app never loses edits.
- **Risk · Complexity · Model:** Medium · M · Sonnet

## G12 — UX foundation and navigation
- **Purpose:** once the domain is stable, define navigation, split the ViewModel along real screens, and build a semantic, field-safe theme.
- **Why it exists:** one long Home screen can't host sessions, execution and the logbook; about 100 hard-coded colours; a 513-line ViewModel.
- **Problems solved:** TD-019, TD-021, TD-044; F-46, F-47 (PD-14); DEV-A1, DEV-A2.
- **Requires:** G11 · **Enables:** G13–G15.
- **Done when:** a navigation shell exists; ViewModels are screen-scoped; there are no hard-coded colours; red mode is complete and persisted; the Tonight dashboard is live.

### TASK 12.1 — Information architecture ADR (PD-19, new; resolves PD-14)
- **Goal:** an approved information architecture with wireframes.
- **Current problem:** a single scrolling page with icon entry points.
- **Why now:** the execution and logbook screens should be built once.
- **Dependencies:** 11.1.
- **Scope:** candidate bottom navigation: Tonight · Sessions · Gear & Targets · Settings; execution as a full-screen route; field constraints (one hand, gloves, ≥48 dp targets, little typing); resolve PD-14 as a fixed Tonight view, not a customizable dashboard.
- **Out of scope:** code.
- **Affected areas:** DECISIONS; wireframes in `docs/`.
- **Direction:** low-fidelity wireframes plus a route map.
- **Tests:** n/a.
- **Acceptance:** owner-approved.
- **Risk · Complexity · Model:** Low · S · Sonnet

### TASK 12.2 — Navigation shell
- **Goal:** implement the route map.
- **Current problem:** flat routes; no tab state.
- **Why now:** G13 and G14 plug into it.
- **Dependencies:** 12.1.
- **Scope:** go_router `StatefulShellRoute`; gate-aware routes; correct Android back behaviour.
- **Out of scope:** deep links.
- **Affected areas:** `app_router.dart`, screen scaffolds.
- **Direction:** centralized navigation.
- **Tests:** navigation and back-button tests.
- **Acceptance:** every screen is reachable per the map.
- **Risk · Complexity · Model:** Low · M · Sonnet

### TASK 12.3 — Complete the PlannerViewModel decomposition
- **Goal:** small, screen-scoped ViewModels over domain services; Provider stays.
- **Current problem (TD-019, TD-021, TD-044):** one ViewModel owns everything, and screens bypass it.
- **Why now:** the seams from G1, G2, G5, G7 and G9 now exist.
- **Dependencies:** 12.2.
- **Scope:** Tonight, SessionPlan, Sessions, Gear and Sites ViewModels; shared state through repositories and streams; screens go through their ViewModels; the mutable list is no longer exposed.
- **Out of scope:** features.
- **Affected areas:** `presentation/viewmodels/`, screens, providers, tests.
- **Direction:** move code rather than rewrite it; one ViewModel per commit.
- **Tests:** adapted ViewModel tests; the end-to-end test stays green throughout.
- **Acceptance:** no ViewModel over about 250 lines; no HTTP, SharedPreferences, Drift or Geolocator imports in ViewModels.
- **Risk · Complexity · Model:** Medium · L · Opus

### TASK 12.4 — Semantic theme tokens; complete red field mode
- **Goal:** colours and typography come from tokens; field mode is truly red-only and persisted.
- **Current problem (F-46, TD-044):** about 100 `Colors.*` uses; field mode is held in memory only.
- **Why now:** execution happens in the dark.
- **Dependencies:** 12.2.
- **Scope:** tokens for light, dark and field themes (charts included); readable typography; ≥48 dp targets; persist field mode; lift the gate after a darkness checklist (dialogs, date picker and snackbars included).
- **Out of scope:** controlling system brightness.
- **Affected areas:** `core/theme/`, all widgets.
- **Direction:** replace colours file by file.
- **Tests:** a test that fails on any `Colors.` in `lib/presentation`; an on-device darkness checklist.
- **Acceptance:** field mode survives a restart, with no non-red pixels.
- **Risk · Complexity · Model:** Low · M · Sonnet

### TASK 12.5 — Tonight dashboard and first-run flow
- **Goal:** a minimal entry screen that answers "what can I capture tonight".
- **Current problem:** stacked cards; no onboarding.
- **Why now:** composes the results of G5–G11.
- **Dependencies:** 12.3, 12.4, 10.3, 10.4, 9.4.
- **Scope:** the night window, the site, the session's fit and reason, the Moon, a weather summary with its age; quick actions; a first run of site → rig → target (skippable) with permission rationale.
- **Out of scope:** home-screen widgets; wearables.
- **Affected areas:** a dashboard screen and ViewModel.
- **Direction:** a summary that drills down, with no new calculations.
- **Tests:** states for no site, no rig, no forecast, fits and doesn't fit.
- **Acceptance:** no overflow at 200 % text size; owner walkthrough.
- **Risk · Complexity · Model:** Low · M · Sonnet

## G13 — Execution (field tracker)
- **Purpose:** low-friction tracking of a running session without hardware control, robust to the Android lifecycle.
- **Why it exists:** there is no ExecutionState (F-43); Android kills background apps.
- **Requires:** G11, 12.2, 12.4 · **Enables:** G14, G17.
- **Done when:** a session can be started, paused, resumed after process death and completed; nothing is lost.

### TASK 13.1 — ADR: execution model under Android constraints (PD-20, new)
- **Goal:** a design that survives the platform.
- **Current problem:** no concept exists; timers die in the background.
- **Why now:** gates 13.2–13.4.
- **Dependencies:** 11.1.
- **Scope:** foreground only; progress derived from persisted UTC timestamps; every transition persisted; estimated frames = elapsed / (exposure + per-frame overhead), confirmed by the user; opt-in keep-screen-on (needs approval for a wakelock dependency); notifications deferred; no camera control, ASCOM or INDI.
- **Out of scope:** code.
- **Affected areas:** DECISIONS.
- **Direction:** a state diagram plus kill, reboot and clock-change scenarios.
- **Tests:** n/a.
- **Acceptance:** approved.
- **Risk · Complexity · Model:** Low · S · Opus

### TASK 13.2 — Execution state machine and persistence
- **Goal:** a pure-domain state machine, persisted.
- **Current problem (F-43):** none exists.
- **Why now:** the screen depends on it.
- **Dependencies:** 13.1, 11.3.
- **Scope:** planned → running(block) ⇄ paused → completed | abandoned; per-block counters; events; invalid transitions rejected; a resume prompt at startup.
- **Out of scope:** UI.
- **Affected areas:** a domain execution service; the repository.
- **Direction:** transitions are pure functions.
- **Tests:** the transition table; a restart in the middle of a block; clock jumps.
- **Acceptance:** killing the app mid-block restores the exact state.
- **Risk · Complexity · Model:** Medium · M · Sonnet

### TASK 13.3 — Execution screen
- **Goal:** a large, glanceable, red-safe tracker.
- **Current problem:** doesn't exist.
- **Why now:** closes the field loop.
- **Dependencies:** 13.2, 12.4.
- **Scope:** the current block with estimated vs confirmed counts; big +1, −1, reject and pause buttons; countdowns (astronomical dawn, target below its limit, moonrise); remaining window vs remaining plan; interruption tags.
- **Out of scope:** notifications.
- **Affected areas:** an execution screen and ViewModel.
- **Direction:** one-thumb layout; no typing.
- **Tests:** states; semantics; large text.
- **Acceptance:** every action reachable with one thumb.
- **Risk · Complexity · Model:** Low · M · Sonnet

### TASK 13.4 — End-of-session reconciliation
- **Goal:** turn an execution into a trustworthy log entry.
- **Current problem (F-42):** fields for actuals exist but nothing fills them.
- **Why now:** feeds the logbook.
- **Dependencies:** 13.2.
- **Scope:** confirm actual counts per block, rejected frames, notes and optional conditions; complete or abandon; a planned-vs-actual summary.
- **Out of scope:** metadata assistance.
- **Affected areas:** the execution flow; the repository.
- **Direction:** edits after completion are allowed and timestamped.
- **Tests:** reconciliation math.
- **Acceptance:** a completed session shows planned vs actual integration.
- **Risk · Complexity · Model:** Low · M · Sonnet

## G14 — Logbook
- **Purpose:** a planned-vs-actual record, per-target accumulation, export and backup.
- **Why it exists:** today the logbook is a list of strings plus share text, and there is no cloud by design.
- **Requires:** G11, G13 · **Enables:** G17.
- **Done when:** users can review, filter, annotate, export and back up everything.

### TASK 14.1 — Logbook list and detail
- **Goal:** useful review of past and planned sessions.
- **Current problem (F-41):** only the date, target and frame count are shown.
- **Why now:** the loop's last step.
- **Dependencies:** 13.4.
- **Scope:** filters by status, target, site and date; a detail view with snapshots (including zone), plan vs actual per block, notes and processing notes; a "legacy" badge for old records.
- **Out of scope:** statistics dashboards.
- **Affected areas:** logbook screens and ViewModel; queries.
- **Direction:** history comes from snapshots.
- **Tests:** widget tests and query tests.
- **Acceptance:** legacy and new sessions both render.
- **Risk · Complexity · Model:** Low · M · Sonnet

### TASK 14.2 — Accumulated integration per target (cut line)
- **Goal:** multi-night progress without a Project entity.
- **Current problem:** no aggregation exists.
- **Why now:** cheap once sessions exist.
- **Dependencies:** 14.1.
- **Scope:** Σ achieved integration per target (and per filter), last imaged date, session count.
- **Out of scope:** project goals.
- **Affected areas:** a query; target detail.
- **Direction:** a SQL aggregate.
- **Tests:** aggregate math.
- **Acceptance:** target detail shows the total logged integration.
- **Risk · Complexity · Model:** Low · S · Sonnet

### TASK 14.3 — Export manifest v2
- **Goal:** a portable, versioned export.
- **Current problem (F-44):** manifest v1 is used only by tests; it has no coordinates, zone or night key; `fromJson` converts to local time.
- **Why now:** users own their data without a cloud.
- **Dependencies:** 14.1.
- **Scope:** a documented v2 schema (UTC instants plus zone id, snapshots, units, app version); share a file plus a text summary; read v1; import deferred.
- **Out of scope:** an import UI.
- **Affected areas:** a data-layer mapper, share code, docs.
- **Direction:** the schema document lives in `docs/`.
- **Tests:** round trip; versioning.
- **Acceptance:** an exported file re-parses identically.
- **Risk · Complexity · Model:** Low · M · Sonnet

### TASK 14.4 — Backup and restore
- **Goal:** data survives a phone change.
- **Current problem:** none exists; Android Auto Backup behaviour is unverified.
- **Why now:** offline-first means the user holds the only copy.
- **Dependencies:** 14.3, 3.2.
- **Scope:** a consistent database copy plus the manifest, saved to a user-chosen location; restore with a schema-version check and confirmation; document how Auto Backup behaves.
- **Out of scope:** sync.
- **Affected areas:** a backup service; Settings.
- **Direction:** refuse backups from a newer schema.
- **Tests:** round trip on an emulator.
- **Acceptance:** a restore on a clean install reproduces all sessions.
- **Risk · Complexity · Model:** Medium · M · Sonnet

## G15 — Quality hardening
- **Purpose:** reliability, performance, accessibility, offline robustness and regression protection.
- **Requires:** G12–G14 · **Enables:** G16.
- **Done when:** there are no silent failures; performance budgets are met on a low-end device; accessibility and offline checks pass; the end-to-end suite is green.

### TASK 15.1 — Error handling and diagnostics
- **Goal:** no silent failures.
- **Current problem (TD-029, TD-038):** empty or swallowing `catch` blocks.
- **Why now:** release quality.
- **Dependencies:** G14.
- **Scope:** typed failures from repositories; user-facing messages; a debug logger; enable the `empty_catches` lint; crash reporting deferred for privacy.
- **Out of scope:** remote logging.
- **Affected areas:** repositories, ViewModels, `analysis_options.yaml`.
- **Direction:** failures become UI states.
- **Tests:** a failure-path test per repository.
- **Acceptance:** no empty catch blocks remain.
- **Risk · Complexity · Model:** Low · M · Sonnet

### TASK 15.2 — Performance and caching
- **Goal:** smooth on low-end devices.
- **Current problem:** getters recompute astronomy on every rebuild.
- **Why now:** the candidates list and the dashboard multiply the cost.
- **Dependencies:** 12.3, 10.4.
- **Scope:** memoize per (night, site, target, preferences); profile traces; isolates if a frame budget is exceeded.
- **Out of scope:** micro-optimizations.
- **Affected areas:** ViewModels; batch evaluators.
- **Direction:** measure first.
- **Tests:** memoization tests; a tolerant benchmark.
- **Acceptance:** no jank in traces; candidates in under 1 s.
- **Risk · Complexity · Model:** Low · M · Sonnet

### TASK 15.3 — Accessibility pass
- **Goal:** usable with large text, screen readers and every theme.
- **Current problem:** never assessed; red mode has inherently low contrast.
- **Why now:** a release requirement.
- **Dependencies:** 12.4, 12.5.
- **Scope:** semantics labels; 200 % text; contrast (with red-mode limits documented); focus order; text alternatives for charts; tap targets.
- **Out of scope:** localization.
- **Affected areas:** all screens.
- **Direction:** Flutter's guideline matchers.
- **Tests:** tap-target, label and contrast guideline tests; text scale 2.0.
- **Acceptance:** guideline tests pass; a TalkBack walkthrough is recorded.
- **Risk · Complexity · Model:** Low · M · Sonnet

### TASK 15.4 — Lifecycle, process-death and offline matrix
- **Goal:** proven robustness on real devices.
- **Current problem:** unverified; the Android build has never been run.
- **Why now:** before the beta.
- **Dependencies:** 13.2, 14.4.
- **Scope:** a fresh install while offline; permission denied and denied forever; "Don't keep activities"; rotation and theme changes; a time-zone change during execution; an upgrade from the beta database; low storage.
- **Out of scope:** iOS.
- **Affected areas:** fixes as they are found; `TEST_PLAN.md`.
- **Direction:** a scripted manual matrix, automated where feasible.
- **Tests:** the matrix itself.
- **Acceptance:** passed and recorded.
- **Risk · Complexity · Model:** Medium · M · Sonnet

### TASK 15.5 — End-to-end regression suite
- **Goal:** automated protection of the core loop.
- **Current problem (F-48):** only one widget-level flow test.
- **Why now:** before the beta.
- **Dependencies:** G14.
- **Scope:** `integration_test` on an emulator: site → target → rig → night → opportunity → plan → save → execute (with a restart) → complete → log → export; time-zone cases.
- **Out of scope:** device farms.
- **Affected areas:** `integration_test/`.
- **Direction:** fake the network, use the real database.
- **Tests:** the suite itself.
- **Acceptance:** green on the emulator.
- **Risk · Complexity · Model:** Low · M · Sonnet

## G16 — Release preparation (Android 1.0)
- **Purpose:** ship a compliant, signed, tested release with honest positioning.
- **Requires:** G15 · **Enables:** post-1.0 work.
- **Done when:** every item in the release checklist (§9) is checked.

### TASK 16.1 — App identity
- **Goal:** final name, id and icon.
- **Current problem:** `com.astroplan.astroplan` becomes permanent once published; the label is "astroplan"; default icons; similarly named products exist ("AstroPlanner" desktop software, "Astro Planner" apps).
- **Why now:** irreversible, and can be decided early.
- **Dependencies:** none technical.
- **Scope:** an owner name and trademark search; decide the id, label, icon and splash screen.
- **Out of scope:** marketing.
- **Affected areas:** Android config; assets.
- **Direction:** record the decision in DECISIONS.
- **Tests:** build and install.
- **Acceptance:** final before any upload.
- **Risk · Complexity · Model:** Medium · S · Sonnet

### TASK 16.2 — Release build and signing
- **Goal:** reproducible signed builds.
- **Current problem:** release builds use the debug key.
- **Why now:** required by Play.
- **Dependencies:** 16.1.
- **Scope:** an upload key created by the owner (never in the repo; the agent never handles passwords); a gitignored `key.properties`; Play App Signing; versioning; target SDK and native-library page-size requirements checked against current Play policy; an R8 decision; an AAB build.
- **Out of scope:** signing in CI.
- **Affected areas:** `android/app/build.gradle.kts`, `.gitignore`.
- **Direction:** follow Flutter's deployment guide.
- **Tests:** a release build installs.
- **Acceptance:** a signed AAB builds locally.
- **Risk · Complexity · Model:** Medium · S · Sonnet

### TASK 16.3 — Legal and compliance (PD-12)
- **Goal:** legally publishable.
- **Current problem (TD-031):** no privacy policy; no attributions; licence intent and third-party terms unconfirmed.
- **Why now:** Play and the API terms require it.
- **Dependencies:** 7.2, 8.2, 9.1.
- **Scope:** a privacy policy (location use, on-device storage, calls to Open-Meteo, Nominatim and OSM tiles; no accounts or analytics); the Data Safety form; attribution and licence screens; re-verify the terms (the Open-Meteo free tier is non-commercial; Nominatim and tile policies); confirm GPL-3.0 intent; permission rationale texts.
- **Out of scope:** legal advice.
- **Affected areas:** About screen, docs, store console.
- **Direction:** date-stamp every terms check.
- **Tests:** an attribution widget test.
- **Acceptance:** the policy URL is live; attributions appear in the app.
- **Risk · Complexity · Model:** Medium · M · Sonnet

### TASK 16.4 — Beta and release QA
- **Goal:** an evidence-based release decision.
- **Current problem:** no testers and no device matrix.
- **Why now:** the final gate.
- **Dependencies:** 16.2, 16.3, G15.
- **Scope:** internal testing, then closed testing (verify Play's current tester and duration rules for new personal accounts); a device matrix including a low-end phone; migration from every beta schema; Play vitals; triage.
- **Out of scope:** paid acquisition.
- **Affected areas:** Play Console; docs.
- **Direction:** exit criteria fixed before the beta starts.
- **Tests:** full regression plus the matrix.
- **Acceptance:** no open P0/P1 issues; migrations from all beta versions pass.
- **Risk · Complexity · Model:** Medium · M · Sonnet

### TASK 16.5 — Store listing and post-release runbook
- **Goal:** an honest listing and a maintenance routine.
- **Current problem:** neither exists.
- **Why now:** launch.
- **Dependencies:** 16.4.
- **Scope:** a listing with no "only app that…", SNR or ISO-sensitivity claims; screenshots in light and red modes; a runbook covering hotfixes, migration discipline, dependency updates and the feedback channel.
- **Out of scope:** campaigns.
- **Affected areas:** the store console; `docs/`.
- **Direction:** review the copy against SCIENTIFIC_INTEGRITY.
- **Tests:** n/a.
- **Acceptance:** the listing is approved; the runbook is in the docs.
- **Risk · Complexity · Model:** Low · S · Sonnet

## G17 — Metadata-assisted logging (v1.1)
- **Purpose:** use EXIF/FITS metadata as assisting data to prefill actuals, always with user verification.
- **Why it exists:** today's import is an unconnected viewer that reads whole files and cannot reach FITS files.
- **Problems solved:** TD-018; F-45; PD-21 (new: supported formats).
- **Requires:** G13, G14 · **Enables:** post-1.0 insights.
- **Done when:** supported formats are tested on real samples; batch import proposes counts that the user confirms.

### TASK 17.1 — File access and header-only parsing
- **Goal:** bounded, safe reads.
- **Current problem (TD-018):** `readAsBytes()` reads the whole file, and FITS parsing turns the whole file into a string; `pickImage` can't select FITS; file I/O lives in the domain; a `/` inside a FITS string value truncates it.
- **Why now:** prerequisite for the rest of the group.
- **Dependencies:** G14.
- **Scope:** decide the formats (JPEG, DNG and TIFF-based RAW where `exif` works, FITS; XISF, CR3 and XMP deferred until samples verify them); a document picker for non-media files (dependency approval); read FITS headers in 2880-byte blocks up to `END`; bounded EXIF reads; I/O moves to the data layer.
- **Out of scope:** image display.
- **Affected areas:** the extractor, a data-layer reader, the import screen, `pubspec.yaml`.
- **Direction:** stream, don't load.
- **Tests:** a large file is not fully read; a multi-block FITS header.
- **Acceptance:** memory stays flat on large files.
- **Risk · Complexity · Model:** Low · M · Sonnet

### TASK 17.2 — Typed metadata and real-sample fixtures
- **Goal:** typed values with provenance and explicit unknowns.
- **Current problem:** every field is a string.
- **Why now:** assisted actuals need reliable values.
- **Dependencies:** 17.1.
- **Scope:** exposure in seconds; ISO or gain with its kind; focal length (nullable for manual lenses and telescopes); f-number (nullable); capture time plus offset when present, otherwise "zone unknown"; FITS DATE-OBS in UTC; source and confidence; owner-supplied samples (no copyrighted third-party files in the repo).
- **Out of scope:** writing metadata.
- **Affected areas:** `image_metadata.dart`, the parser, fixtures.
- **Direction:** never default a missing value.
- **Tests:** fixtures per format; missing-field cases.
- **Acceptance:** each supported format is parsed from a real sample.
- **Risk · Complexity · Model:** Low · M · Sonnet

### TASK 17.3 — Assisted actuals from a batch of frames
- **Goal:** fewer taps to a correct log.
- **Current problem:** metadata isn't connected to sessions.
- **Why now:** reduces execution friction (risk R6).
- **Dependencies:** 17.2, 13.4.
- **Scope:** group many frames by exposure, ISO or gain → propose counts per block and the time span; warn on a camera mismatch or frames outside the night; the user confirms; only summaries are stored.
- **Out of scope:** plate solving; file management.
- **Affected areas:** the import flow; the reconciliation UI.
- **Direction:** proposals only, never silent writes.
- **Tests:** grouping; EXIF local time vs the session night.
- **Acceptance:** 100 sample frames yield the correct counts for a two-block session.
- **Risk · Complexity · Model:** Medium · M · Sonnet

---

# 5. Dependency order

**5.1 Group graph**
```
G0 ─► G1 ─► G2 SessionNight ─► G3 Persistence ─► G4 Fixes
              │  (2.1–2.3 are pure domain; only 2.4 needs 1.1)
              ▼
        G5 Capture Budget ── uses darkness∩altitude windows until G10
              │
   ┌──────────┼──────────────┬──────────────┐
   ▼          ▼              ▼              ▼
 G6 Astro   G7 Sites     G8 Targets/Gear   G9 Weather
 (Moon,NPF) (tz, LP)     (needs 6.5, 5.6)  (UTC, staleness)
   └──────────┴──────┬───────┴──────────────┘
                     ▼
            G10 Imaging Opportunity ──► fit input switches (10.2g)
                     ▼
            G11 Session aggregate
                     ▼
            G12 UX foundation / VM split
                     ▼
   G13 Execution ─► G14 Logbook ─► G15 Quality ─► G16 Release 1.0 ─► G17 (v1.1)
```

**5.2 Critical path.** 0.1 → 0.2 → 1.1 → 2.1 → 2.2 → 2.3 → 2.4 → 3.1 → 3.2 → 5.1 → 5.3 → 5.4 → 5.5 → 6.1 → 6.2 → 6.3 → 6.4 → 10.1 → 10.2 → 11.1 → 11.2 → 11.3 → 11.4 → 12.1 → 12.2 → 12.3 → 13.1 → 13.2 → 13.4 → 14.1 → G15 → G16.

Where the order is flexible:
- G3 and G4 can run in either order.
- G7, G8 and G9 can run alongside G6.
- 16.1 can be decided at any time.
- If the owner wants SessionNight first (as today's audit proposes), 2.1–2.3 can start right after 0.2.

**5.3 Data-model formation (only real entities)**

| Concept | Form | Formed in | Depends on |
|---|---|---|---|
| SessionNight | Value type; persisted only as night key + UTC window inside Session | 2.2 | Site coordinates only |
| PlanningPreferences | Key-value store behind a repository | 5.2 | — |
| CaptureBlock | `capture_blocks` table (+ position, policy, typed gain; counters in 11.2) | 5.3 / 11.2 | Session |
| CapturePlan | **No table.** Ordered blocks plus budget assumptions owned by the Session | 5.x → 11.x | Blocks, preferences |
| MoonConditions | Computed value | 6.4 | Night, site, target |
| Site | `location_profiles` extended (zone, nullable sky darkness + source, metres; horizon in 10.5) | 7.1 | — |
| Target | `astro_targets` extended (epoch, source, size, magnitude) | 8.1 | — |
| Equipment | Existing tables behind a flat profile (units, tracking type, maximum exposure) | 8.4 | — |
| WeatherSnapshot | Value; cached JSON; its summary stored in the Session snapshot | 9.2 → 11.3 | Coordinates, night window |
| OpportunityWindow | Computed inside ImagingOpportunity; its summary stored in the snapshot | 10.2 → 11.3 | Night, site, target, preferences, Moon, weather?, horizon? |
| Session | Aggregate root = evolved `session_logs` | 11.2 | Site, Target, Equipment, CapturePlan, snapshots |
| ExecutionState | Session status + block counters + event list | 13.2 | Session |
| LogbookEntry | **Not an entity**: a completed Session | 14.1 | Session |
| Project (multi-night) | **Not created**: an aggregate query | 14.2 | Sessions |
| ImageMetadata | Transient; only summaries become actuals | 17.x | Session |

**5.4 When each decision is needed.**
- PD-06 → 0.2; PD-13 → 0.3
- PD-01 and PD-02 → 2.1
- PD-04 and PD-09 → 3.1
- PD-08 → 5.1
- PD-07 and PD-16 → 6.1
- PD-05 → 7.4
- PD-03 and PD-10 → 8.3; PD-11 → 8.6
- PD-15 → 9.1
- PD-17 (new) → 10.1
- PD-18 (new) → 11.1
- PD-19 (new) and PD-14 → 12.1
- PD-20 (new) → 13.1
- PD-12 → 16.3
- PD-21 (new) → 17.1

# 6. Milestones

| Milestone | Objective | Groups | Definition of done |
|---|---|---|---|
| **M0 Governed, testable baseline** | Trustworthy context and suite | G0, G1 | Docs committed; roadmap adopted and PD-06 recorded; all tests green without sleeps; deterministic offline start; CI running |
| **M1 Correct night** | One time model | G2 | SessionNight regression matrix green; chart, timeline and windows share one source; zone labels everywhere; TD-001 resolved |
| **M2 Safe and honest** | Protect data and credibility | G3, G4 | Migration tests and snapshots; foreign keys on; orphan table gone; G4 defects resolved; no "SNR"; unknowns shown as unknown |
| **M3 Core answer v0** | The product's answer exists | G5 | Integration / acquisition / total budget fitted to the night's windows, with reasons and "what fits". **Owner dogfoods on real nights and makes a go/no-go call on the bet** |
| **M4 Complete conditions** | Honest inputs and a transparent opportunity | G6–G10 | Moon model within tolerances; sites with zones; units and provenance for gear and targets; UTC weather with staleness; Opportunity with reasons; candidates list |
| **M5 Sessions and structure** | Durable sessions and app skeleton | G11, G12 | Draft, planned and duplicate sessions with snapshots; navigation shell; ViewModel split; complete red mode; Tonight dashboard |
| **M6 Field loop closed (feature-complete 1.0)** | Plan → Execute → Log | G13, G14 | Execution survives process death; planned vs actual in the logbook; export v2; backup and restore |
| **M7 Android 1.0 released** | Production | G15, G16 | Quality matrix passed; §9 checklist complete; published |

After release: v1.1 = G17, plus selected deferred items (§10).

# 7. Architecture checkpoints

These are short Opus reviews based on diffs, not a re-audit of the whole repo.
- **AC1 (after G1).** Platform code sits behind interfaces; the bootstrap is awaitable; no network on the startup path.
- **AC2 (after G2).** No `DateTime.now()` in the domain; one night source; no astronomy in widgets (`grep` astronomy imports in `lib/presentation`).
- **AC3 (after G3).** The migration workflow works; foreign keys are on; every schema change comes with a snapshot and a test.
- **AC4 (after G5 and G10).** The domain core is pure and deterministic; units appear in names or docs; thresholds come from preferences; there is no score anywhere.
- **AC5 (after G11).** Snapshots are immutable; references are nullable; no domain state remains in SharedPreferences.
- **AC6 (after G12).** Layering holds: no `http`, `shared_preferences`, `drift` or `geolocator` imports in presentation (checked with grep); only Provider; no ViewModel over about 250 lines.
- **AC7 (before G16).** Dependency and licence audit; secrets and HTTPS review; performance budgets.

# 8. Testing checkpoints

Tests ship inside every task. These checkpoints add gates on top of that.

| When | Gate |
|---|---|
| G1 | Suite green 3 times in a row; no real-time sleeps; startup determinism test |
| G2 | Time matrix: Americas evening, after midnight, ±180° longitude, Kiritimati, EU and US DST nights, polar day and night. Tests must not depend on the host time zone |
| G3 and every later schema change | Snapshot-based migration test plus data preservation |
| G5 | ADR worked examples exactly; property tests (more frames never take less time; windows stay inside the night) |
| G6 | Reference fixtures with sources and tolerances (USNO, JPL); no circular expectations |
| G9 | Recorded parser fixtures (nulls, zones); staleness tested with a fake clock |
| G10 | Opportunity vectors; the candidates list equals the single-target results |
| G11 and G13 | Transactional rollback; snapshot immutability; process-death restore |
| G14 | Export round trip; backup and restore |
| G15 | Accessibility guideline tests; offline and lifecycle matrix; end-to-end `integration_test` |
| G16 | Full regression on the device matrix; upgrades from every beta schema |

Rule: a test is only replaced with a recorded justification. The 2.4 replacement of the UTC-default test is the example.

# 9. Release checklist

- [ ] No open P0/P1 issues; FEATURE_STATUS, TECH_DEBT and SCIENTIFIC_INTEGRITY are current.
- [ ] Format, analyze, unit, widget and E2E tests green on an emulator and at least 2 physical devices.
- [ ] Migration tests from every beta schema pass; backup and restore verified.
- [ ] Time regression matrix and astronomy reference tests green.
- [ ] Every calculation is documented. No "SNR" or ISO-sensitivity wording. NPF is labelled as a recommendation. Unknowns are shown as unknown. Thresholds are configurable.
- [ ] Core features work in airplane mode from a fresh install; weather, geocoding and tiles degrade gracefully.
- [ ] Permission rationale is shown, and the denial paths are usable.
- [ ] Red mode verified in real darkness; keep-screen-on only when opted in.
- [ ] Accessibility checks pass; performance budgets are met on a low-end phone.
- [ ] Privacy policy URL, Data Safety form, and attributions (OSM, Open-Meteo, catalog source, Nominatim); licences page.
- [ ] Terms re-verified and date-stamped: Open-Meteo tier, Nominatim and tile policies, identifying user agent; GPL-3.0 intent confirmed.
- [ ] Final id and name; icon; versioning; upload key with Play App Signing; target SDK and native page-size compliance checked.
- [ ] Closed-testing requirement met; honest store listing.
- [ ] Docs updated; Git tag created.

# 10. Deferred and rejected features

**Rejected:**
- Planetarium, sky map, 3D sky, AR, FOV framing on sky imagery, mosaic planning (Stellarium, Telescopius and Stargazing Hub cover these).
- Camera or telescope control, ASCOM, INDI, ASIAIR integration, live view.
- Accounts, cloud sync, social features, backend.
- A black-box "astro score".
- Absolute physical SNR or exposure optimisation (no per-camera noise data).
- A customizable dashboard (PD-14 → a fixed Tonight view).
- Web scraping.

**Deferred, with the trigger for revisiting:**
- Event notifications and alarms: v1.1, after the exact-alarm and permission work.
- Empirical overhead suggestions from logged sessions: v1.1, once enough completed sessions exist. This is a strong differentiator candidate.
- Metadata import: G17.
- XMP, XISF, CR3: after verifying with samples.
- Offline light-pollution dataset: after a licence, size and accuracy evaluation.
- Licensed light-pollution API: only once a real API with acceptable terms is verified.
- Seeing and transparency forecasts.
- Moving objects: after 1.0, with PD-07.
- Multi-target night scheduling.
- A Project entity.
- Equipment composition UI (PD-03).
- iOS (the `Info.plist` strings are missing).
- Localization and unit preferences.
- Home-screen widgets and Wear OS.
- Place search.
- Theoretical storage payload (needs bit depth).
- Precession and refraction refinements (only if the reference tests show a need).

# 11. Major risks

| # | Risk | Mitigation |
|---|---|---|
| R1 | Time-model errors (DST, date line) | ADR 2.1, injected Clock, regression matrix, tests independent of the host zone |
| R2 | Scope creep toward a planetarium, automation or weather modelling | Active-task rule (0.2), the rejected list, ADR gates |
| R3 | Weak differentiation (Astro PM, Sidereal, Telescopius) | Budget early (M3) plus the dogfooding go/no-go; focus on the manual-imager loop |
| R4 | Data loss through migrations | G3 snapshots, backup (14.4), upgrade floor |
| R5 | Wrong scientific numbers | Reference tests, the SI register, labels, no silent formula changes |
| R6 | Execution friction (users won't tap in the dark) | Estimates derived from timestamps, one-thumb UI, metadata assistance in v1.1 |
| R7 | Android lifecycle and background limits | Foreground-only design, persisting every transition |
| R8 | Third-party terms or availability (Open-Meteo, Nominatim, OSM) | Offline-first, provider isolation, attribution, a terms check before release |
| R9 | AI-agent drift and repeated re-analysis | Docs updated in the same change, small tasks, ADR-first, stable IDs |
| R10 | Solo developer with limited Claude usage | Cut lines (5.2 catalog breadth, 10.5, 14.2, G17), Sonnet by default |
| R11 | Irreversible identity choices | 16.1 decided early, with a name-collision check |
| R12 | Dependency drift (Flutter 3.47, drift/sqlite3, EOL packages) | Toolchain documented (0.3); upgrade windows only between milestones |

# 12. Model and resource strategy

- **Opus (13 tasks):** 2.1, 2.2, 3.1, 5.1, 6.1, 6.3, 6.5, 8.3, 10.1, 10.2, 11.1, 12.3, 13.1. Opus also reviews 11.2 and the AC checkpoints.
- **Sonnet:** the other 64 tasks.
- **Escalate to Opus** only after two failed Sonnet attempts on the same failure, or when a cross-layer question isn't covered by an ADR.
- **Complexity scale:**
  - **S:** at most one focused session, roughly 200 changed lines.
  - **M:** 1–2 sessions, roughly 600 lines.
  - **L:** 3 or more sessions, or cross-cutting.
  - No XL tasks.
- **Context pack for each task:** `CLAUDE.md`, the task's roadmap entry, its ADR, and the files listed in "Affected areas". No repo-wide re-audit.
- **End of every task:** update FEATURE_STATUS, TECH_DEBT and SI (per CLAUDE.md conventions), make one commit, and tag at each milestone.

# 13. Red-team corrections applied

1. **Capture Budget moved to G5.** It was after all the conditions groups. It only needs the night windows, and early placement tests the product bet sooner. This also matches the PROJECT_AUDIT §8 order.
2. **UX and navigation (G12) placed after Session but before Execution.** At the end of the plan, the execution and logbook screens would have been built twice.
3. **The ViewModel split moved to 12.3.** The seams are created incrementally in G1, G2, G5, G7 and G9, matching ARCHITECTURE D2-P6.
4. **The preferences store moved into G5 (5.2).** The budget needs it; it had been planned with Opportunity.
5. **Entities cut.** LogbookEntry, the CapturePlan table, Project, the OpportunityWindow table and the WeatherSnapshot table were all dropped.
6. **"Repair every historical migration" replaced by an upgrade-floor decision.** The old steps reuse current table definitions, so repairing them is expensive.
7. **Added 10.4 Tonight's candidates.** Without it, the plan answered "can I image X?" but not "what can I image?".
8. **Added the "no site yet" state (2.4, 7.3).** The default night depends on the site, so a silent London default computes the wrong night.
9. **Relabelled Open-Meteo "visibility"** as horizontal visibility, not astronomical transparency.
10. **Removed a false dependency.** The weather cache is keyed by coordinates, not by site id.
11. **Demoted two differentiators.** Field-first and smartphone support are now a quality bar and an equipment type, not selling points.
12. **Flagged two owner calls.** The SNR label conflicts with commit `1baa514`, and the UTC-default test must be replaced deliberately.
13. **Moved to cut line or v1.1:** notifications, horizon, catalog breadth, per-target totals, metadata.
14. **Unverified assumptions, each checked in its task:**
    - no installs below v8 (3.1);
    - Open-Meteo and OSM terms (9.1, 16.3);
    - the OpenNGC licence (8.2);
    - Play policies (16.2, 16.4);
    - `sqlite3_flutter_libs` redundancy (0.3);
    - Meeus accuracy (6.3);
    - NPF constants (6.5);
    - EXIF support per format (17.1);
    - competitor features, which come from listings and not hands-on use.

---

## Final answers

- **What must NOT be touched yet?**
  - Any code before this roadmap and PD-06 are approved (OD-03, OD-04).
  - The schema, until 3.2 exists.
  - UI or navigation redesign, until G11 is done.
  - The ViewModel split, before 12.2.
  - Showing NPF, before 6.5 and 8.6.
  - Any astronomy formula, before 6.2's reference tests.
  - The equipment table structure, before 8.3.
  - The orphan table, before 3.1.
  - Gated features, until their group's DoD.
  - Design-intent docs are never rewritten to match the code.
- **Single most important architectural foundation:** the pure-Dart **SessionNight time model**. It is site-based (solar noon to solar noon), stored in UTC, displayed with an explicit zone, and it is the only source for the timeline, windows, chart, weather alignment, sessions and logs.
- **Core product feature:** the **Capture Budget fitted to the night's Imaging Opportunity**: integration vs acquisition vs total budget against the real windows, with reasons and "what fits instead". It sits inside a low-friction Plan → Execute → Log loop.
- **What should stay deliberately simple:**
  - weather: one provider, raw indicators, no score;
  - light pollution: manual entry plus an external map;
  - equipment: a flat profile;
  - catalog: a curated list;
  - the overhead model: a few explicit parameters;
  - execution: a manual tracker;
  - metadata: header-only and assistive;
  - storage: one SQLite database with JSON snapshots;
  - state management: Provider.
- **What could make the project fail through scope creep:**
  - a sky map, FOV-on-imagery or mosaics;
  - a target-discovery or score engine;
  - hardware and automation integration;
  - cloud, accounts or social features;
  - seeing or noise modelling (physical SNR);
  - processing light-pollution datasets;
  - iOS or wearables before Android 1.0;
  - background notification machinery;
  - moving objects and big catalogs.
- **What "finished" means:** Android 1.0 in production where a manual imager can do all of the following offline, with honest and tested science:
  - pick a site (with its zone) and a rig (with units);
  - see tonight's correct window, the Moon and aged weather;
  - get a transparent opportunity and a budget that says whether the plan fits;
  - save it as a session;
  - track it in red mode through app kills;
  - log planned vs actual, then export and back it up.
  
  The release also requires tested migrations, current docs, completed compliance, and no open P0/P1 issues. Metadata assistance (v1.1) and iOS come after "finished".

**Next step:** approve TASK 0.1 (commit the docs) and decide PD-06. If you'd like, I can also save this roadmap as `docs/ROADMAP.md` (TASK 0.2) or publish it as a shareable page.

**Sources (competitor research):**
- [Telescopius — App Store](https://apps.apple.com/us/app/telescopius/id6479415751) · [RASC Hamilton guide to Telescopius](https://www.hamiltonrasc.ca/exploring-the-cosmos-with-telescopius-a-comprehensive-guide-for-astrophotographers/)
- [Stargazing Hub](https://stargazinghub.com/) · [Stargazing Hub — App Store](https://apps.apple.com/us/app/stargazing-hub-sky-live/id1478601599)
- [AstroTool Free](https://apkpure.com/astrotool-free/com.diablocode.astrophotographytool)
- [Sidereal — Google Play](https://play.google.com/store/apps/details?id=com.orbital.sidereal&hl=en)
- [Astrophotography Planner — App Store](https://apps.apple.com/us/app/astrophotography-planner/id1661476234)
- [Astro PM — project management](https://astro-pm.com/project-management/)
- [DarkScout](https://darkscout.app/) · [DarkHours](https://darkhours.app/)
- [NINA Target Scheduler](https://tcpalmer.github.io/nina-scheduler/)
- [ASIAIR Plan Mode guide](https://astroguide.starlust.de/html/UsingPlanMode.html)
- [PhotoPills Spot Stars (NPF)](https://www.photopills.com/calculators/spotstars)
- [Meridian (Mac Observatory)](https://www.macobservatory.com/meridian-deep-sky-imaging-catalog)
- [Photon Hunter](https://photonhunter.space/)
