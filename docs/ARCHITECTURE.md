# AstroPlan Architecture

## Selected Stack

- Flutter / Dart
- Provider and ChangeNotifier ViewModels
- go_router for centralized navigation
- SQLite via Drift
- Android-first implementation with later iOS support

## Layering

AstroPlan should keep a conservative architecture:

```text
Presentation
  -> ViewModels
  -> Repositories
  -> Services / Data Sources / Local DB / APIs
```

Domain calculations should remain independent from Flutter UI code. Platform
specific behavior should be isolated behind interfaces or adapters.

## Source Layout

The current source tree uses:

- `lib/core/` for shared utilities and theme primitives.
- `lib/domain/` for models, repositories, and services.
- `lib/data/` for Drift database, concrete repositories, and seeders.
- `lib/presentation/` for navigation, screens, widgets, and ViewModels.
- `test/` for unit, repository, database, and widget tests.

This broadly follows the intended architecture, but feature boundaries are not
yet fully aligned with the roadmap phases.

## Navigation

Navigation should remain centralized in `lib/presentation/navigation/`.
Screens should not create scattered, arbitrary navigation flows.

## State Management

Use Provider and explicit ViewModels. Do not introduce Riverpod, Bloc, Redux, or
another state-management ecosystem unless a documented need emerges and the
project owner approves the architectural change.

## Database Boundary

Drift tables and generated Drift row classes belong in the data layer. Widgets
and ViewModels should depend on repository interfaces and domain models, not
directly on Drift APIs.

## Scientific Calculation Boundary

Calculation services should be pure Dart where practical and must include:

- input units;
- output units;
- formula/reference;
- assumptions;
- valid input ranges;
- edge-case handling;
- tests.

## Scope Guardrails

Do not introduce full planetarium, AR sky navigation, camera control, live
camera preview, or heavy GPU rendering into the core app without explicit
approval.
