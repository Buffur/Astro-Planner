# AstroPlan Decisions

This file records architectural and product decisions that affect future work.

## ADR-001: Use Flutter And Dart

Status: accepted

AstroPlan uses Flutter and Dart for a single cross-platform application codebase
with Android as the initial target and iOS as a future target.

## ADR-002: Use Provider And ViewModels

Status: accepted

AstroPlan starts with Provider and explicit ViewModels. Additional
state-management frameworks require a documented need and project-owner
approval.

## ADR-003: Use SQLite Via Drift

Status: accepted

AstroPlan uses SQLite for durable local storage and Drift for typed queries,
migrations, relationships, and testability.

## ADR-004: Keep AstroPlan Out Of Planetarium Scope

Status: accepted

AstroPlan is a planner and logbook. Full planetarium, AR sky navigation,
embedded Stellarium, live camera preview, and camera control are out of MVP
scope unless explicitly approved.

## ADR-005: Treat Scientific Calculations As Auditable

Status: accepted

Scientific and astrophotography calculations must document units, assumptions,
valid ranges, references, and tests. Relative stacking gain must not be labeled
as absolute SNR.

## Pending Decisions

- Whether to normalize the current flat equipment table into Device,
  CameraModule, and OpticalRig immediately or through a staged migration.
- Which astronomical engine/library/reference to use for future ephemeris work.
- How to store provenance for seeded target and equipment data.

## ADR-006: Hide Implemented Future-Phase Features Until Approval

Status: accepted

Several later-phase features already exist in source code. To avoid destructive
rollback while restoring roadmap discipline, they are hidden behind
`FeatureScope` gates until their phases are explicitly approved.

Initially disabled gates:

- field mode;
- light-pollution context and external map handoff;
- metadata import;
- logbook UI and save action.
