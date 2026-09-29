# Astro Planner (AstroPlan)

Astro Planner is an Android-focused Flutter/Dart application for planning
astrophotography sessions. It helps you choose a target, night, site and rig,
build a realistic capture plan, and understand whether it fits the available
imaging opportunity.

Core planning works offline. Weather and location services enrich the plan,
while calculations, assumptions, units and data provenance remain visible.

## Current status

**As of 2026-09-29:** the project is in post-roadmap refinement, with substantial
working application code. Stages 0–6 are closed; **Stage 7 — Data Entry &
Automation is in validation**. Closure history, including earlier owner waivers,
is recorded in [Refinement Progress](docs/refinement/PROGRESS.md).

Stage 7's original implementation tasks are committed. Independent validation
found two form defects: calibration controls overwriting independent input, and
the site editor missing the discard prompt for some single-field edits.
Both corrections are committed: **S7.V1** at `46e7688` and **S7.V2** at `d28f5a8`.
The next allowed action is **bounded Stage 7 revalidation**; the stage has not
yet closed. See the [Stage 7 validation report](docs/refinement/STAGE_7_VALIDATION.md).

Release readiness is not complete. Later stages cover the result/Logbook workflow,
secondary UX, performance and beta validation. Device checks and release-owner
actions remain tracked in the progress document. This README describes committed
milestones; that document is the ongoing handoff for the next allowed action.

## What the application includes

- **Planning:** a fit-first planner, night selection with time-zone handling,
  target visibility, darkness, Moon and imaging-opportunity calculations,
  plus weather freshness and missing-data states.
- **Targets:** an offline catalog of 164 objects from OpenNGC, designation and
  common-name search with aliases, and custom targets.
- **Sites and rigs:** saved sites, explicit GPS/map selection, optional elevation
  and manual Bortle/SQM; camera types, equipment specifications and a per-plan
  tracking override that preserves the rig's default.
- **Capture plans:** light, dark, flat, bias and dark-flat blocks; contextual
  ISO/gain and binning fields; calibration inheritance and mismatch warnings;
  overheads, calibration policies and applicable in-camera noise reduction in
  the budget and fit.
- **Metadata-assisted rig entry:** "Add from a photo" for supported DNG, JPEG
  and HEIC files, with provenance, review and confirmation before saving.
- **Supporting workflows:** saved-plan snapshots, the existing execution/results
  workflow, Logbook, portable session export, and local backup/restore.
- **Presentation:** light, dark and red field themes, progressive disclosure,
  and automated accessibility/layout checks.

The approved product direction is:

```text
Site / Rig / Target → Night & Opportunity → Capture Plan → Fit → Save
                                                               ↓
                                              Image outside the app → Result / Logbook
```

The dedicated live tracker still exists in the current implementation. Stage 8
will retire its UI after the replacement result workflow is available, preserving
existing records. See [Product Direction](docs/refinement/PRODUCT_DIRECTION.md).

Scientific outputs keep their limits explicit: unknown values remain unknown,
thresholds are preferences, and √N describes relative stacking gain rather than
absolute physical SNR. The product has no composite sky score, planetarium,
sky-navigation or camera/mount-control scope.

## Development

The repository's CI configuration pins **Flutter 3.47.4**;
[pubspec.yaml](pubspec.yaml) requires **Dart ^3.13.3**. Use the Android toolchain
and a connected Android device or emulator to run the application. iOS is deferred.

```sh
flutter pub get
flutter devices
flutter run -d <device-id>
```

The application uses Provider with screen-scoped ViewModels, `go_router`, and
SQLite through Drift (**schema v23**). Presentation, domain logic and data access
are separated; astronomy calculations remain independent of Flutter UI code.

Run the full quality gate with:

```sh
dart run tool/check.dart
```

It checks encoding, formatting, static analysis, unit/widget tests and host E2E.
Device validation and opt-in real metadata samples are separate evidence; a host
pass does not substitute for them. Current results and their limitations live in
[Refinement Progress](docs/refinement/PROGRESS.md). Verification requirements and
evidence-reuse rules are defined in [CLAUDE.md](CLAUDE.md).

For Android signing, bundles and release checks, follow
[RELEASE.md](docs/RELEASE.md).

## Documentation

Start with the active refinement sources:

- [Progress](docs/refinement/PROGRESS.md) — current stage, blockers, validation
  evidence and next allowed action.
- [Post-roadmap plan](docs/refinement/POST_ROADMAP_PLAN.md) — stages, frozen tasks
  and research/owner-decision gates.
- [Product direction](docs/refinement/PRODUCT_DIRECTION.md) — planning-first
  workflow and product constraints.

Supporting references:

- [Feature status](docs/FEATURE_STATUS.md), [architecture](docs/ARCHITECTURE.md)
  and [data model](docs/DATA_MODEL.md).
- [Decisions](docs/DECISIONS.md), [scientific integrity](docs/SCIENTIFIC_INTEGRITY.md)
  and [technical debt](docs/TECH_DEBT.md).
- [Design system](docs/DESIGN_SYSTEM.md) and [test plan](docs/TEST_PLAN.md).
- [Privacy policy](docs/privacy/index.md), [compliance](docs/COMPLIANCE.md),
  [license](LICENSE) and [catalog attribution](assets/catalog/OPENNGC_NOTICE.txt).

Earlier roadmaps and audits are historical evidence, not the active task queue.
Agent guidance is in [CLAUDE.md](CLAUDE.md), with supporting rules and skills in
`.agents/`.
