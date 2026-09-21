# AstroPlan Roadmap

Development should proceed in small phases. The active phase is the only
approved scope unless the project owner explicitly approves a change.

## Phase 0 - Project Governance

Objective: create repository documentation and AI-development rules before
significant implementation.

Deliverables:

- `README.md`
- `GEMINI.md`
- `docs/PRODUCT_SPEC.md`
- `docs/ROADMAP.md`
- `docs/ARCHITECTURE.md`
- `docs/DATA_MODEL.md`
- `docs/TEST_PLAN.md`
- `docs/DECISIONS.md`
- `.agents/rules/`
- `.agents/skills/`

Exit criteria:

- Repository exists.
- Git is initialized.
- Documentation structure exists.
- AI rules exist.
- Product scope is explicitly frozen.

## Phase 1 - Environment Validation

Objective: establish a reproducible Flutter/Android development environment.

Exit criteria:

- `flutter doctor` reviewed.
- `flutter analyze` passes.
- `flutter test` passes.
- Android build/run path is verified by the developer.

## Phase 2 - Architecture Skeleton

Objective: app shell, theme, routing, dependency injection, feature folders,
ViewModel structure, repository interfaces, and test structure without product
feature depth.

## Phase 3 - Design System

Objective: create the minimalist, information-dense, Notion-inspired visual
language before feature screens become complex.

## Phase 4 - Local Database And Domain Models

Objective: introduce the first persistent data.

Initial entities:

- Device
- CameraModule
- OpticalRig
- Target
- Location

Session entities should be added later, after the foundational schema is
stable.

## Phase 5 - Astronomical Calculation Engine

Objective: pure Dart astronomy/calculation layer with reference cases, input
units, output units, tolerances, and sources.

## Phase 6 - Equipment And Optical Calculator

Objective: useful optical calculations: FOV, pixel scale, optical multipliers,
and later NPF recommendations.

## Phase 7 - Target Catalog

Objective: searchable curated target catalog with reliable coordinates and
source/provenance information.

## Phase 8 - Night Timeline And Visibility

Objective: combine astronomy engine, location, target, Moon context, and
visibility windows.

## Phase 9 - Session Planner

Objective: central planner with capture blocks, integration, duration, storage,
relative stacking gain, and feasibility.

## Phase 10 - Weather

Objective: provider-isolated weather data, initially using Open-Meteo, without
breaking offline functionality when the API is unavailable.

## Phase 11 - Light Pollution And Sky Darkness

Objective: add Bortle classification and sky-darkness context with source
attribution and uncertainty.

## Phase 12 - Metadata Import

Objective: import representative image metadata after behavior is verified
against real sample files.

## Phase 13 - Logbook

Objective: planned versus actual session records, rejected frames, conditions,
and processing notes.

## Phase 14 - Export And Interoperability

Objective: session manifests and handoff/export workflows.

## Phase 15 - Field Mode

Objective: night-use ergonomics such as red-light mode and checklists.

## Phase 16 - Hardening And Beta

Objective: reliability, migration testing, usability checks, accessibility, and
release readiness.

## Current Repository Alignment

The current implementation has moved past Phase 4 in several areas. Before new
feature work, align the database model, documentation, and currently visible UI
with the approved phase boundaries.

### Audited alignment (2026-09-21, commit `900b82a`) — actual status per phase

*The phase definitions above are the design intent and are unchanged. This table
records what exists in the code. Status vocabulary: Implemented / Partial /
Prototype / Broken / Missing (definitions in `docs/FEATURE_STATUS.md`).*

**Active phase: not declared.** This roadmap says the active phase is the only
approved scope but never names it. The `FeatureScope` gates (ADR-006) imply phases
up to 10 were treated as approved and 11–15 as gated, but the gates are only
partly enforced and two of them are now `true`. The owner must declare the active
phase (`docs/DECISIONS.md` PD-06; `TECH_DEBT.md` TD-041).

| Phase | Actual status | Notes (feature IDs → `docs/FEATURE_STATUS.md`) |
| --- | --- | --- |
| 0 Project governance | Partial | Docs and `.agents/rules/` exist; the listed `GEMINI.md` is git-ignored and absent (DEV-P7); `CLAUDE.md` added; docs reconciled 2026-09-21; the "scope frozen" exit criterion is not in effect because no phase is declared |
| 1 Environment validation | Partial | `flutter analyze` clean; `flutter test` 70/71; Android build/run unverified; no CI (F-48–F-50) |
| 2 Architecture skeleton | Implemented | With deviations DEV-A1/DEV-A2 (F-01, F-03) |
| 3 Design system | Partial | Light/dark/field themes; hard-coded colours in widgets; mojibake strings; a decorative bar |
| 4 Database and domain models | Partial | Schema v9; normalized equipment storage but flat domain (DEV-D2); migrations untested and one path fails (DEV-D1); session entities introduced ahead of the foundation being stable (F-02, F-23) |
| 5 Astronomical engine | Partial | Core routines implemented and tested; references, assumptions and reference-value tests missing (SI-009) (F-11) |
| 6 Equipment and optical calculator | Partial | Pixel scale implemented; FOV computed but not shown; multipliers are an identity seam; **NPF broken** and not surfaced (F-24–F-27) |
| 7 Target catalog | Prototype | 5 targets, no provenance (F-19–F-21) |
| 8 Night timeline and visibility | Partial | Math implemented, **default night wrong** (F-09); no Moon geometry, no time zone (F-10, F-12–F-17) |
| 9 Session planner | Partial | Blocks, duration, feasibility, gain, storage; budget conflates integration, acquisition and calibration (F-35–F-39) |
| 10 Weather | Partial | Open-Meteo + cache; not date- or zone-aware (F-29–F-31) |
| 11 Light pollution and sky darkness | Broken / Prototype | Auto-fetch can never succeed; manual badge hidden; **ahead of phase** (F-32–F-34) |
| 12 Metadata import | Prototype | Display-only; no real sample files; **ahead of phase** (F-45) |
| 13 Logbook | Partial | Plan-only; no actuals entry; **ahead of phase** (F-40–F-42) |
| 14 Export and interoperability | Prototype | JSON manifest v1 only in tests; text sharing live; **ahead of phase** (F-44) |
| 15 Field mode | Prototype | Theme toggle, ungated; **ahead of phase** (F-46) |
| 16 Hardening and beta | Missing | No migration tests, no CI, no accessibility or usability checks |

Items that appear in the code or earlier notes but **not** in this roadmap: a
"Custom Dashboard" (PD-14).
