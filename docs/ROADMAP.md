# AstroPlan Roadmap

Development should proceed in small phases. The active phase is the only
approved scope unless the project owner explicitly approves a change.

## Phase 0 - Project Governance

Objective: create repository documentation and AI-development rules before
significant implementation.

Deliverables:

- `README.md`
- `GEMINI.md` *(amended 2026-09-21, PD-13: dropped as a deliverable; `CLAUDE.md` is
  the agent-instruction file — original entry kept for history)*
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

**Active phase: not declared — RESOLVED 2026-09-21.** *(Audit finding, kept for
history.)* This roadmap says the active phase is the only approved scope but never
names it. The `FeatureScope` gates (ADR-006) imply phases up to 10 were treated as
approved and 11–15 as gated, but the gates are only partly enforced and two of them
are now `true`. **Resolution:** the owner adopted `docs/MASTER_ROADMAP.md` as the
approved scope and decided PD-06 (`docs/DECISIONS.md` PD-06 and E.1; `TECH_DEBT.md`
TD-041). See "Adopted plan" at the end of this file. The table below records the
audited status at commit `900b82a`; it is not updated by later tasks.

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

---

## Adopted plan: Master Development Roadmap (adopted 2026-09-21, TASK 0.2)

*The Phase 0–16 definitions above remain the **design intent** and are unchanged.
The detailed, approved work plan is `docs/MASTER_ROADMAP.md` (groups G0–G17, tasks
0.1–17.3, milestones M0–M7). Design intent is amended only by owner approval, never
rewritten to match the code.*

### Approved scope and active task

- **Approved scope:** the tasks of `docs/MASTER_ROADMAP.md`, executed **one task per
  cycle, in roadmap order**, each only after the owner's explicit go-ahead. The
  agent never starts the next task on its own (`docs/DECISIONS.md` OD-06). Any work
  outside the current task needs owner approval (`.agents/rules/00-project-governance.md`).
- **Active task line** *(update this line at the end of every task)*:
  - Completed (all 2026-09-21): **TASK 0.1** (`34a7157`); **TASK 0.2** (`af076d9`);
    **TASK 0.3** (`ef20670`, `c8ad208`, `714426d`, plus the docs commit that records them).
    Group G0 is complete. **TASK 1.1** (`2357755`); **TASK 1.2** (`2e17093`); **TASK 1.3**
    (`94acd71` whole-tree format, `97924a0` quality-gate script and CI — the CI workflow
    was owner-approved before committing, plus the docs commit that records this task).
    Group G1 is complete. **Milestone M0 is met on this branch**, except that CI has
    never actually run: no Git remote is configured yet, so `.github/workflows/ci.yml`
    is untested against real GitHub Actions.
  - Completed 2026-09-22: **TASK 2.1** — ADR-007, SessionNight and time-zone strategy
    (`docs/DECISIONS.md` Part F). PD-01 and PD-02 were resolved by the owner.
    Documentation only.
  - Completed 2026-09-22: **TASK 2.2** — pure-domain `SessionNight`, `CalendarDate`,
    `SiteTimeContext`, `SessionNightResolver` and `Clock`, with the ADR-007 test matrix
    (135 tests green). Not yet used by the app.
  - **Next: TASK 2.3 — Calculators consume SessionNight.** Not started; it begins only
    on the owner's go-ahead.

### Phase → group map

The master roadmap is ordered foundation-first, so groups do not follow phase order
(for example the capture budget, Phase 9, comes before weather, Phase 10). This maps
each design-intent phase to the group(s) that deliver it.

| Phase (design intent) | Delivered by (group · tasks) |
| --- | --- |
| 0 Project governance | G0 · 0.1–0.3 |
| 1 Environment validation | G1 · 1.1, 1.3 (harness, CI); Android run verification in 0.3 and 16.4 |
| 2 Architecture skeleton | G1 · 1.1–1.2 (platform seams, bootstrap); G12 · 12.2–12.3 (navigation shell, ViewModel decomposition) |
| 3 Design system | G12 · 12.4 (semantic theme tokens) |
| 4 Local database and domain models | G3 · 3.1–3.3; schema tasks 7.1, 8.4, 11.2 |
| 5 Astronomical engine | G2 · 2.2–2.3; G6 · 6.2–6.4 |
| 6 Equipment and optical calculator | G6 · 6.5 (NPF); G8 · 8.3–8.6 |
| 7 Target catalog | G8 · 8.1–8.2 |
| 8 Night timeline and visibility | G2 (SessionNight); G10 · 10.2–10.5 |
| 9 Session planner | G5 (capture budget); G11 (Session aggregate) |
| 10 Weather | G9 |
| 11 Light pollution and sky darkness | G7 · 7.4 |
| 12 Metadata import | G17 (v1.1, after Android 1.0) |
| 13 Logbook | G13 · 13.4; G14 · 14.1–14.2 |
| 14 Export and interoperability | G14 · 14.3–14.4 |
| 15 Field mode | G12 · 12.4 (red mode); G13 (execution) |
| 16 Hardening and beta | G15, G16 |
| *Cross-cutting* | G4 (correctness and honesty fixes); G7 · 7.1–7.3 (sites) and G12 · 12.5 (Tonight dashboard) serve several phases |

### Gate policy for features built ahead of their phase (PD-06, resolved 2026-09-21)

Decision recorded in `docs/DECISIONS.md` E.1. **Enforcement is not part of this task:
the code does not yet match this policy** (`FeatureScope.metadataImport` is `true`;
the field-mode toggle and the map card are ungated — TD-014, DEV-P1). Enforcement is
**TASK 4.3**.

| Feature | Decision | Visible again / lifted by |
| --- | --- | --- |
| Logbook (F-40–F-42) | Stays visible (on the core path) | — |
| Text sharing (F-44) | Stays visible (on the core path) | — |
| Metadata import (F-45) | Hidden | G17 (v1.1) |
| Light-pollution map card | Hidden | TASK 7.4 |
| Field-mode toggle (F-46) | Hidden | TASK 12.4 |
