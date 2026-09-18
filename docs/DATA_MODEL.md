# AstroPlan Data Model

## Database Choice

AstroPlan uses SQLite via Drift. Schema changes must be additive or explicitly
migrated, with migration tests for non-trivial changes.

## Intended Phase 4 Foundation

The foundational schema should model these concepts first:

- Device
- CameraModule
- OpticalRig
- Target
- Location

Session entities should be introduced after these are stable.

## Conceptual Relationships

```text
Device
  -> CameraModule
  -> OpticalRig
       -> SessionPlan
            -> Target
            -> Location
            -> CaptureBlock[]
                 -> ExecutedSession
                      -> ProcessingLog
```

## Current Implementation Snapshot

Current Drift tables:

- `EquipmentProfiles`
- `LocationProfiles`
- `AstroTargets`
- `SessionLogs`

Current issue: `EquipmentProfiles` flattens device, camera module, and optics
into one table. This is convenient for a prototype but weaker than the planned
Phase 4 structure.

Current issue: `SessionLogs` stores target and equipment as display strings
rather than stable relationships. This should be revisited when session planning
and logbook schema are formally approved.

Current issue: active planner location is persisted through shared preferences
rather than the `LocationProfiles` table.

## Migration Rules

- Do not delete or recreate tables casually.
- Inspect current schema before changing it.
- Add migrations for every schema-version bump.
- Add tests for migration behavior.
- Avoid destructive migrations unless explicitly approved.

## Provenance

External or scientific data should preserve source information where practical:

- weather provider;
- target catalog source and version;
- sensor/equipment data source;
- light-pollution dataset;
- astronomical algorithm/library reference.
