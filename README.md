# AstroPlan

AstroPlan is a Flutter/Dart mobile application for astrophotography session
planning and computational logging.

The product is scoped as a planner and logbook, not a full planetarium, AR
sky-navigation app, or camera-control application. It should complement tools
such as Stellarium rather than replace them.

Core workflow:

```text
Equipment -> Target -> Location + Conditions -> Visibility -> Capture Plan -> Actual Session -> Logbook
```

## Technical Baseline

- Framework: Flutter
- Language: Dart
- State management: Provider with ViewModels
- Navigation: go_router
- Database: SQLite via Drift
- Initial platform: Android
- Future platform: iOS

## Project Documentation

The baseline project documents live in `docs/`:

- `docs/PRODUCT_SPEC.md`
- `docs/ROADMAP.md`
- `docs/ARCHITECTURE.md`
- `docs/DATA_MODEL.md`
- `docs/TEST_PLAN.md`
- `docs/DECISIONS.md`

The AI collaboration structure lives in `.agents/`.

## Current Status

The repository already contains product code beyond the original Phase 0
documentation milestone. Before additional feature work, the implementation
should be reconciled with the roadmap, database model, and scientific-integrity
rules documented in this repository.
