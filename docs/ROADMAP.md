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
