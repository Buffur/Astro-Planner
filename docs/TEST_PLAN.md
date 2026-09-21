# AstroPlan Test Plan

## Required Checks

For meaningful implementation changes, run:

```text
flutter analyze
flutter test
```

For release or platform-sensitive changes, also run the relevant Android build
and device/emulator verification.

## Unit Tests

Use unit tests for:

- domain calculations;
- unit conversions;
- repositories;
- parsers;
- validation;
- data mapping.

Calculation tests must include input units, expected output, tolerance, and a
reference/source when the result is scientific or astronomical.

## Database Tests

Use database tests for:

- table creation;
- repository CRUD behavior;
- constraints;
- migrations;
- preservation of existing data after schema upgrades.

## Widget Tests

Use widget tests for:

- app boot;
- important screen states;
- reusable UI components;
- critical interaction flows where practical.

## Future Integration Tests

Eventually test the core scenario:

```text
Create/select equipment
  -> Create/select target
  -> Select location/date
  -> Create capture block
  -> Calculate integration/storage/relative stacking gain
  -> Save session
  -> Retrieve session/log
```

## Current Verification Snapshot

At the time these docs were created, `flutter test` passed. `flutter analyze`
reported one deprecated API usage in the target selection screen. This snapshot
is informational and should be rechecked after each change.

*(The paragraph above is the Phase 0 snapshot, kept for the record. It is
**outdated**: see the audited baseline below.)*

### Audited baseline (2026-09-21, commit `900b82a`)

| Check | Result |
| --- | --- |
| `flutter analyze --no-pub` | No issues (default `flutter_lints` only) |
| `flutter test --no-pub` | **71 tests: 70 pass, 1 fails** |
| Failing test | `test/integration_flow_test.dart` "E2E Flow: Planner -> Save -> Logbook" — `pumpAndSettle timed out` at its first call. Root cause (verified): the ViewModel is created in `setUp` outside the fake-async zone so its initialization never advances; an unhandled `MissingPluginException` from `Geolocator` is the only exception. **Not an HTTP problem** (weather is mocked). See `docs/TECH_DEBT.md` TD-003 |
| CI | None configured |
| Android build / device run | Not verified |

Tests per area (total 71): domain services 27 (astronomy 6, optics 6,
session/feasibility 6, visibility 3 + 4, metadata 2) · domain models 3 · Drift
repositories and database 8 (including `repository_bug_test`) · Open-Meteo
repository 3 · Equipment/Target form-validation widget tests 9 · ViewModel suites
19 (of which 5 in `planner_session_date_test.dart` exercise the pure
`VisibilityCalculator` with UTC dates, not the ViewModel) · app boot 1 ·
end-to-end 1 (failing).

**Known gaps** (`docs/TECH_DEBT.md` TD-025, TD-037): no tests for the live capture
budget math in `PlannerViewModel`; no widget tests for Home, Capture Plan, Sky,
Weather, Altitude chart, Logbook, Location or Metadata screens; no migration tests;
no direct reference-value tests for the Sun model, night timeline or Moon model;
the NPF test derives its expected value from the implementation (circular); tests
of unused code (`SessionCalculator.estimateTotalDuration`, the orphaned
`equipment_profiles` table, `EquipmentCatalogRepository`); ViewModel tests rely on
`Future.delayed(300 ms)` and on pre-setting `activeLocationId` to avoid Geolocator;
`AppRouter.router` is a shared static.

**Proposed additions** (not approved; map to the debt register): reference-value
tests using independent sources (USNO/JPL, published formulas) — SI-001, SI-002,
SI-009; regression tests for the session night in western longitudes, after
midnight, the date line, DST and high latitude — TD-001; migration tests for every
supported upgrade path — TD-004; ViewModel and widget tests for the capture planner
and save flow — TD-010, TD-011, TD-012; a startup determinism test (seeding before
the first read) — TD-002; an injectable clock and location interface so no test needs
real-time sleeps — TD-037.

Note: until TD-003 is fixed, the "run `flutter analyze` and `flutter test` before
claiming completion" rule cannot be satisfied literally; report the failure as
pre-existing and confirm no additional test fails (`docs/DECISIONS.md` DEV-P8).
