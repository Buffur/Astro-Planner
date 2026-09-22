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

*(Superseded by TASK 1.1 below; kept for the record.)*

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

### Current baseline (2026-09-22, after TASK 2.2)

| Check | Result |
| --- | --- |
| `flutter analyze --no-pub` | No issues |
| `flutter test --no-pub` | **135 tests: 135 pass, 0 fail** (`dart run tool/check.dart`) |
| CI | None configured (TD-046; roadmap TASK 1.3) |
| Android build / device run | Not verified |

**Resolved by TASK 1.1 (commit `2357755`):** the red `integration_flow_test.dart`
(TD-003) — repaired, not weakened: the ViewModel is now built and awaited (`ready`)
inside `tester.runAsync`, and its RA fixture (5.59, hours, in a degrees field) was
fixed to 83.85°. Device location goes through an injectable `LocationService`
(`lib/domain/services/location_service.dart`), implemented by
`GeolocatorLocationService` in production and `FakeLocationService`
(`test/support/`) in tests. The two `Future.delayed(300 ms)` waits and the
`activeLocationId` GPS-avoidance workaround are gone (`await vm.ready` instead);
new suite `planner_location_test.dart` covers permission-denied and
position-granted paths (2 tests).

**Added by TASK 1.2** (deterministic bootstrap and Home empty/error states):
- `planner_bootstrap_test.dart` (5 tests) — seeding completes before the ViewModel's
  first read (mirrors `main.dart`'s fixed order); a repository failure during the
  initial load sets `hasBootstrapError` instead of hanging; `retryBootstrap()`
  recovers once the repository stops failing; `isDefaultLocation` before/after a
  saved location loads. Uses a new `FlakyTargetRepository` test double
  (`test/support/`) that wraps a real Drift-backed repository and can be told to
  throw, so the failure and its recovery are both tested against a real store.
- `home_screen_test.dart` (5 tests) — the empty state's "Choose a Target" /
  "Choose Equipment" actions; the default-location banner shown/hidden; a weather
  repository that throws shows a retry card without hanging the first screen, and
  the retry button calls it again; a bootstrap failure shows the error view, and
  retrying with a repository that has recovered clears it. These tests discovered
  and work around two things, both pre-existing:
  - `AppRouter.router`'s static-singleton state leaks navigation between tests in
    the same file (TD-037) — worked around with `AppRouter.router.go('/')` in
    `setUp()`, not fixed.
  - a plain `ListView(children: [...])`'s off-screen children are not built until
    scrolled into view (a Flutter sliver-list behavior, not a bug), so the weather
    test uses the same taller test surface `integration_flow_test.dart` already
    uses for the same reason.

Total after TASK 1.2: 24 test files, 83 tests.

**Added by TASK 2.2** (SessionNight domain, ADR-007), 52 tests:
- **`test/domain/services/session_night_resolver_test.dart`** holds the ADR-007 §12
  matrix:
  - default night from "now" (T1–T9, T11, T12);
  - chosen evening dates, including the DST nights with site-local display
    (T9–T16);
  - the L1 fallback;
  - P1, the §11 invariants over 730 dates in 13 contexts;
  - P2, a 48-hour monotonicity walk;
  - P3, antimeridian continuity;
  - input validation.

  Each "now" case also records whether it discriminates against the old UTC-date
  rule: T1, T2, T3, T6, T11 and T12 do. DST is tested without the `timezone` package
  through `test/support/dst_time_context.dart`, whose 2026–2027 transition instants
  come from the IANA database. All inputs are UTC, so no test depends on the host
  zone (T17 is enforced structurally: non-UTC inputs are rejected).
- **`test/domain/models/calendar_date_test.dart`:** `CalendarDate` and the
  time-context ids.
- **`test/core/time/clock_test.dart`:** `FixedClock` and `SystemClock`, plus a
  source guard that `lib/domain` has no `DateTime.now()`.
- **`session_log_test.dart`:** a `fromJson` clock-fallback test.

Total after TASK 2.2: 27 test files, 135 tests.

**Still open** (`docs/TECH_DEBT.md` TD-025, TD-037): no tests for the live capture
budget math, Capture Plan, Sky, Altitude chart, Logbook, Location or Metadata
screens; no migration tests; the NPF test is circular; `AppRouter.router` is a
shared static (worked around above, not fixed); Nominatim and the light-pollution
HTTP client are not injectable (tests only avoid the real network because the
widget-test HTTP binding answers with 400); no CI.

Any test failure from here on is a regression, not a known pre-existing issue
(`docs/DECISIONS.md` DEV-P8, resolved).
