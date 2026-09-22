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

## Current Baseline and Known Traps (as of 2026-09-22, after TASK 2.2)

**Commands** (prefer `--no-pub` to avoid unintended `pubspec.lock` changes):

- **`dart run tool/check.dart`** — the quality gate: `dart format --set-exit-if-changed`, `flutter analyze --no-pub`, `flutter test --no-pub` (all scoped to `lib`/`test`), in one command. Runs all three regardless of an earlier failure, then prints a pass/fail summary and exits non-zero if any failed. Run this before calling a change complete (TASK 1.3, TD-046).
- `flutter analyze --no-pub` — expected: no issues.
- `flutter test --no-pub` — expected: **135 pass, 0 fail** (green since TASK 1.1; `TD-003` resolved; 83 → 135 in TASK 2.2). A failing test is now a regression.
- `dart format lib test` — expected: no changes (the whole tree was formatted once, TASK 1.3). Formatting is not yet enforced in CI; `tool/check.dart` is the only current gate.
- After changing Drift tables: `dart run build_runner build --delete-conflicting-outputs` (standard step; not exercised in the audit). Every schema change needs a migration **and** a migration test.
- Android build/run was **not** verified.

**Testing rule:** `.agents/rules/03-testing.md` can be satisfied literally again (`DEV-P8` resolved 2026-09-21). Investigate any failure as a regression; do not delete or weaken a test.

**Owner directives currently in force** (`docs/DECISIONS.md` Part C):

- **Scope = `docs/MASTER_ROADMAP.md`** (approved 2026-09-21, OD-06). Work one roadmap TASK per cycle, in order: READ → VERIFY → PLAN → IMPLEMENT → TEST → REVIEW → COMMIT → STOP. Never start the next task on your own; do not change the roadmap without owner approval; do not re-audit the whole repository. The current position is the "active task" line in `docs/ROADMAP.md` ("Adopted plan").
- OD-03 (no new feature, specifically not `SessionNight`, before the docs are reconciled and the roadmap exists) has its condition met; `SessionNight` is roadmap group G2 and starts only when the roadmap reaches it and the owner gives the go-ahead.
- Do not fix application code or scientific issues as part of documentation tasks; record them (OD-04).
- Multi-file, architectural, database, or scope-affecting work: inspect, report a plan, wait for approval (`.agents/rules/00-project-governance.md`).
- **`PD-06` resolved 2026-09-21** (`docs/DECISIONS.md` E.1): the logbook and text sharing stay visible; metadata import is hidden until G17, the light-pollution map card until TASK 7.4, the field-mode toggle until TASK 12.4. **The code does not enforce this yet** (`TD-014`); enforcement is TASK 4.3. Do not extend these ahead-of-phase features.

**Traps that will bite (all verified):**

1. `EquipmentProfile.id` is an **optical-rig id**; storage is normalized (Device → CameraModule → OpticalRig) but the domain/UI model is flat. The `equipment_profiles` table is orphaned.
2. The default `sessionDate` is the **UTC** calendar date (wrong night for evenings west of UTC); the picker and loaded logs use **local** dates (`TD-001`). The correct model now exists but is **not wired**: `SessionNightResolver` / `SessionNight` / `SiteTimeContext` in `lib/domain` and `Clock` in `lib/core/time` (ADR-007, TASK 2.2). Use them; never derive a night from a `DateTime`'s Y/M/D, and never call `DateTime.now()` in `lib/domain` (a test enforces this).
3. `aperture` means **f-number**; one seed stores a diameter (`SI-005`). Field names carry no units.
4. Relative stacking gain is √N of light frames only; the UI label still says "Relative SNR" (`TD-009`). NPF exists but is wrong and not shown (`TD-007`).
5. `PlannerViewModel` starts `_init()` from its constructor; await it with `vm.ready` (TASK 1.1). Seeding no longer races it — `main.dart` awaits both seeders before `runApp` (TASK 1.2). A bootstrap failure sets `hasBootstrapError` (retry via `retryBootstrap()`) instead of throwing unguarded; weather loads after the first frame, not as part of `ready`, and a failure sets `weatherError` rather than blocking or throwing (TASK 1.2). It still calls HTTP (Nominatim) and SharedPreferences directly; GPS goes through the injected `LocationService`, so tests must pass a `FakeLocationService` (`test/support/`), or they will reach the real plugin. The silent first-launch `unawaited(useCurrentLocation())` still has no try/catch around an unexpected platform exception.
6. `LightPollutionRepository` can never succeed (malformed URL); Bortle defaults to 4; the Bortle badge is hidden by `FeatureScope.lightPollutionContext`.
7. `FeatureScope.fieldMode` is defined but never read; the map handoff and field-mode toggle are ungated (`TD-014`).
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
