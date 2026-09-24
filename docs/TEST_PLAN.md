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

### Current baseline (2026-09-22, after TASK 2.3, commit `de1792a`)

| Check | Result |
| --- | --- |
| `flutter analyze --no-pub` | No issues |
| `flutter test --no-pub` | **808 tests: 808 pass, 0 fail** (`dart run tool/check.dart`, after TASK 14.1) |
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

**Added by TASK 2.3** (calculators and the altitude chart consume SessionNight),
12 tests:
- **`test/domain/services/visibility_calculator_session_night_test.dart`** (9 tests):
  the ADR-007 polar cases restated as typed-result assertions (T13 midnight sun,
  T14 polar night with a separate astronomical-twilight crossing, T15 no
  astronomical darkness); exact numeric agreement between the new
  `calculateNightTimelineForNight`/`calculateVisibilityWindowsForNight` and the
  legacy DateTime-based wrappers for a normal London winter night; a visibility
  window spanning a polar night flagged `clippedAtStart`/`clippedAtEnd` through
  both the new API and, separately, the legacy wrapper (the flag depends on the
  astronomy, not on which API computed it — an assumption this second test proves
  rather than just documents); the altitude curve's grid spacing/count and its
  agreement with the timeline on the darkness-crossing instant.
- **`test/presentation/widgets/altitude_chart_widget_test.dart`** (3 tests, the
  chart's first widget test): renders for a normal night; renders for a
  polar-night site without throwing; renders for a session date far from "now" so
  the now-dot branch is exercised with nothing to draw.

Total after TASK 2.3: 29 test files, 147 tests.

**Still open** (`docs/TECH_DEBT.md` TD-025, TD-037): no tests for the live capture
budget math, Capture Plan, Sky, Logbook, Location or Metadata
screens; no migration tests; the NPF test is circular; `AppRouter.router` is a
shared static (worked around above, not fixed); Nominatim and the light-pollution
HTTP client are not injectable (tests only avoid the real network because the
widget-test HTTP binding answers with 400); no CI.

Any test failure from here on is a regression, not a known pre-existing issue
(`docs/DECISIONS.md` DEV-P8, resolved).

**Added by TASK 5.2** (planning preferences), 24 tests:
- `test/domain/models/planning_preferences_test.dart`: the documented defaults equal
  the pre-5.2 values; clamping of every field, including non-finite input;
  `DarknessLimit.fromDegrees`; toggling the optional overheads.
- `test/data/repositories/shared_prefs_planning_repositories_test.dart`: round trips
  for both repositories; the pre-5.2 keys are read, so saved values survive; an off
  overhead removes its key; a corrupt saved plan throws.
- `test/presentation/viewmodels/planner_preferences_test.dart`: the darkness limit and
  the minimum altitude change the windows (London, M42, 2026-03-01, fixed clock); the
  per-frame overhead feeds the required time; preferences survive a new ViewModel; a
  source guard that no ViewModel imports SharedPreferences.
- `test/presentation/screens/settings/settings_screen_test.dart`: defaults and
  "Not included" rendering; a slider drag persists the value; choosing −12° and
  switching dither on.
- `test/domain/services/session_calculator_test.dart`: the configurable margin
  (default 15 %; 30 % turns a plan tight; 0 % boundary).

**Added by TASK 5.3** (CaptureBlock model and schema), 20 tests:
- `test/domain/models/capture_block_test.dart`: validation bounds (exposure, count,
  binning, filter), `copyWith` validates, the calibration-policy invariant (none for
  lights, default `outsideWindow`), `CaptureGain` ranges and `fromStored`,
  case-insensitive frame-type parsing that never defaults to light, and the manifest
  round trip plus legacy `gain_iso` reading.
- `test/data/database/schema_migration_test.dart`: v8, v9 and v10 → v11 each match
  the v11 snapshot exactly; v10 → v11 converts rows (frame type lower-cased, order
  kept as `position = id`, calibration `outsideWindow`, `gain_iso` → kind unknown
  with the numeric value only, `gain_iso` column gone).
- `test/data/repositories/drift_logbook_repository_test.dart`: order, policy and
  gain survive save and a reordering update; a row the domain rejects is skipped,
  not read as a light.
- `test/data/repositories/shared_prefs_planning_repositories_test.dart`: the plan
  JSON is written as version 2; a pre-5.3 v1 list still loads, and an invalid block
  in it is skipped without losing the rest.

**Changed by TASK 5.4** (capture budget), +20 −1 tests:
- `test/domain/services/capture_budget_calculator_test.dart` (new, 20): ADR-009 §8
  vectors E1, E1b, E2 (40/52/53 frames), E3, E4, E5, E6 (102/103/120/121), E7 to the
  millisecond; flip not counted without a transit; edge cases (empty plan, no
  dither after the last light, unknown storage is null and library excluded,
  overheads from preferences); `transitFallsInWindows`.
- Removed: `session_calculator_test.dart`'s `estimateTotalDuration` test, with the
  dead function itself (ADR-009 §11; recorded in `DECISIONS.md`).
- Updated with its reason: `planner_preferences_test.dart` "per-frame overhead
  feeds the required time" now counts only in-window frames (the example plan's
  darks and flats are outside the window under ADR-009 §3).

**Changed by TASK 5.5** (fit analysis), +21 −7 tests:
- `test/domain/services/fit_analyzer_test.dart` (new, 21): ADR-009 §8 fit results —
  E1; E1b per the erratum (flip dropped) and its mid-plan-transit variant (flip
  applied, ends 00:23:40); E2a/b/c including E2c's "does not fit although the sums
  would say tight", lost tails and the 2-nights hint; the E2 inverse (52); E3; E4; E5
  no window; E6 at 102/103/120/121; E7 — all to the second; margin configuration;
  nothing to fit; inverse edge cases; no-window reasons from a real London-June
  timeline (−18° never reached; at −12° the target is the reason).
- Removed with the deleted `SessionCalculator` (CALC-18): `session_calculator_test.dart`
  (7 tests of the sum-of-windows rule, superseded by the fit tests above).

**Added by TASK 5.6** (capture planner UI), 9 tests:
- `test/presentation/widgets/capture_plan_fill_test.dart` (new, 2): the acceptance
  test — against real windows (London, M42, 2026-03-01, fixed clock) a 500 × 300 s
  plan shows "Doesn't fit" with its reason and a similar-nights hint, and one tap on
  the trim action makes it fit and shows the end time; a short plan offers "Fill
  tonight's window" instead.
- `capture_plan_widget_test.dart` (+2): the dialog saves a calibration policy and an
  ISO gain; the breakdown lines, per-group √N row, gain help text and the
  assumptions panel ("Not included" × 6, 5 s, 15 %) render. Its harness now wraps
  the card in a `SingleChildScrollView`, as Home's `ListView` does, because the card
  outgrew the 800×600 test surface.
- `fit_analyzer_test.dart` (+5): `maxFramesForBlock` (alone = the inverse answer;
  keeps the rest of the plan; non-light → null; no windows → 0), light grouping,
  `setupStartUtc`.

**Added by TASK 6.2** (independent astronomy references), 8 tests and 3 fixtures:
- **Fixtures** in `test/fixtures/astronomy/`. Each file records its source, the
  exact queries and the retrieval date, and none contains values computed by the
  app:
  - `usno_sun_moon_events.json`: USNO rstt/oneday, 3 sites × 5 nights × 2 UTC
    dates; the Moon events are kept for TASK 6.3.
  - `horizons_sun.json`: JPL Horizons airless Sun elevation at 1-min steps.
    Threshold crossings are linearly interpolated between samples; hourly spot
    values are kept unmodified.
  - `usno_celnav_stars.json`: USNO celnav computed altitudes of 9 stars at 3 sites
    and 3 instants, with SIMBAD J2000 inputs.
- **`test/domain/services/astronomy_reference_test.dart`:**
  - Sun altitude ≤ 0.02°;
  - every Horizons crossing reported within [−2, +7] min on the grid;
  - polar thresholds typed as never below / always below;
  - every USNO rise/set and civil-twilight event within [−2.5, +7.5] min (USNO
    rounds to the minute);
  - stars within 0.05° with precession;
  - precessed Dec within 0.03° of USNO's Dec of date;
  - a regression guard that the unprecessed error exceeds 0.2°;
  - precession is the identity at J2000.0.

**Added by TASK 6.3** (Moon ephemeris), 10 tests and 1 fixture:
- **`test/fixtures/astronomy/horizons_moon.json`:**
  - JPL Horizons Moon geocentric apparent RA/Dec, illuminated fraction, range and
    ecliptic-of-date longitude/latitude at 32 instants (559 h apart, 2026–2027);
  - topocentric airless elevation at London, Tokyo and Tromsø;
  - the USNO phases for 2026–2027.

  Source, queries and retrieval date are inside the file.
- **`test/domain/services/moon_calculator_test.dart`** (ADR-010 §4 tolerances):
  - RA/Dec and ecliptic coordinates ≤ 0.02°; distance ≤ 100 km; illumination ≤ 1 pp;
  - topocentric altitude ≤ 0.05° at 3 sites including 69.65°N;
  - all USNO phase instants ≤ 10 min (bisection on the Moon − Sun longitude);
  - moonrise/moonset matched one-to-one with USNO on 15 site-nights within
    [−2.5, +7.5] min (USNO minute rounding included);
  - no-event nights are typed;
  - ΔT plausibility.

**Added by TASK 6.4** (MoonConditions), 10 tests and 1 fixture:
- **`test/fixtures/astronomy/moon_separation.json`:**
  - USNO celnav GHA and declination of date for the Moon, 9 stars and Aries at 5
    instants (responses from several sites merged, since the API omits objects
    below the local horizon);
  - JPL Horizons topocentric apparent Moon RA/Dec at 3 sites.
- **`test/domain/services/moon_conditions_test.dart`** (9 tests):
  - geocentric separation ≤ 0.05° against USNO (45 pairs);
  - topocentric ≤ 0.05° against Horizons + USNO (135 pairs);
  - separation identities;
  - grid coverage and illumination at mean solar midnight;
  - the closest approach counts only instants when both are up;
  - a never-rising target → null, not 0;
  - no target → no separation;
  - up intervals follow rise/set;
  - below-horizon samples.
- **`test/presentation/widgets/sky_darkness_moon_test.dart`** (1): the sky card
  shows the illumination (no "approx."), "Moon up …", the closest approach, and no
  "impact".
- **Updated:** the four illumination tests in `visibility_calculator_test.dart` and
  `planner_session_date_test.dart` now call `MoonCalculator.illuminatedFraction`,
  with the same instants and thresholds; the mean-phase function they tested was
  deleted.

**Changed by TASK 6.5** (NPF), +9 −1 tests, in `optical_calculator_test.dart`:
- **Removed:** the circular NPF test, whose expected value was derived from the
  implementation's own wrong `+ 90` constant (SI-001, TD-007).
- **Added: five worked examples,** computed independently from Michaud's derivation
  in a scratch script and each checked to within 0.2 % of his published rounded
  formula:
  - a phone lens (iPhone 15 Pro Max main);
  - APS-C 24 mm;
  - 400 mm at δ 0° and 60°;
  - full frame 50 mm at δ 45° with k = 2.
- **Also added:**
  - the coefficients against the derivation;
  - k is linear and limited to 1–3;
  - |δ| is symmetric and capped near the pole;
  - invalid optics are rejected.

**Added by TASK 7.1** (site model and schema v12), 20 tests:
- **Schema (`schema_migration_test.dart`):** v8–v11 → v12 match the snapshot; v11 →
  v12 turns the default Bortle 4 into NULL with a note and keeps another value as
  `legacy`, leaving coordinates untouched.
- **Repository (`drift_location_repository_test.dart`):** the new fields round
  trip; unknown stays null; `LocationProfile` rejects out-of-range values.
- **Zone model (`iana_time_context_test.dart`):**
  - unknown ids give null;
  - the LA PDT→PST transition;
  - hourly agreement with the IANA-derived DST fakes (Berlin, LA, NY, London) over
    2026–2027;
  - Kiritimati now gets the civil evening date (ADR-007 L1 fixed).
- **Formatter (`night_time_formatter_zone_test.dart`):** wall-clock conversion
  through a zone (DST-aware); captions "site zone …" and the device fallback; the
  "+1" marker in the site zone.
- **ViewModel (`planner_site_test.dart`), the acceptance tests:**
  - a spy repository proves that a map pick, GPS on first launch and the online
    Bortle result write nothing into a site;
  - an explicit Bortle edit is the one write, with source `user` and the date;
  - the site's zone drives `displayZoneId` and the night;
  - with Bortle unknown, only the Moon can trigger the sky warning.
- **Updated, with its reason:** `planner_location_test.dart`'s GPS test used to
  assert that the fix overwrote the saved site (the defect TD-027). It now asserts
  the transient, remembered position and an untouched site.

**Added by TASK 7.2** (location and geocoding services), 32 tests:
- **Geocoder (`nominatim_reverse_geocoder_test.dart`, `MockClient`, manual clock):**
  - a found name carries the OpenStreetMap attribution;
  - the identifying user agent and the rounded coordinates are sent;
  - nearby coordinates and "no name here" are answered from the cache;
  - HTTP error, offline, malformed body and timeout are reported as failures and
    not cached (a later call retries);
  - three simultaneous lookups go out one at a time, at least 1 s apart; no wait
    when the last request is older; a queued duplicate hits the cache.
- **Helpers (`location_input_test.dart`):** each permission outcome's text and
  settings target; coordinate parsing and range validation.
- **ViewModel (`planner_location_test.dart`):**
  - a fake for each permission state — every failure is reported and changes
    nothing, a grant is used;
  - `locateDevice` previews without using; settings open through the service;
  - a place name comes with its attribution;
  - a failed lookup leaves the name unknown, not stale;
  - an answer for a position the user has left is ignored;
  - no `http`/`geolocator` import in `lib/presentation` or `lib/domain` (the
    acceptance test).
- **Picker (`location_picker_screen_test.dart`):**
  - denied forever / services off show the explanation, and "Open settings" opens
    the right page;
  - a plain denial has no settings action;
  - a fix moves the marker without changing the ViewModel;
  - typed coordinates are validated and move the marker;
  - the OSM attribution and the real tile user agent.

**Added by TASK 7.3** (sites UI and first-run site setup), 25 tests:
- **Domain (`location_profile_user_edit_test.dart`):** what a user edit writes —
  new sites get user-sourced values dated today; unchanged values keep their
  source and date; changed ones become `user`; cleared ones lose both; range
  errors.
- **Zones (`iana_time_context_test.dart`, +1):** link ids devices report
  (`Europe/Ljubljana`, `Asia/Calcutta`, `UTC`) resolve with their target's rules.
- **Validators (`site_form_input_test.dart`):** name, elevation, SQM, notes.
- **ViewModel (`planner_sites_test.dart`):**
  - the acceptance test: switching sites changes all night times (window,
    astronomical dusk, display zone);
  - the selection persists across a restart;
  - a new site becomes active; editing the active site applies at once; editing
    another site leaves the active one;
  - deleting the active site keeps its position as transient (and persists it);
    deleting another site changes nothing else;
  - an active site shows its own name without reverse geocoding;
  - the device zone is passed through.
- **Screens (`sites_screen_test.dart`):**
  - the active site is marked and tapping another selects it;
  - deleting the active site (confirmed) leaves an unsaved current position;
  - the editor rejects missing and out-of-range values;
  - a new site defaults to the device zone and becomes active;
  - "Save as site" starts from the current position;
  - editing keeps the unchanged fields.
- **Home:** the first-run prompt offers "Use current position".
- **Updated, with its reason:** `planner_location_test.dart` asserted that
  startup asked the location service once; since the owner's TASK 7.3 decision
  startup asks nothing, and the test asserts that. Its controlled-geocoder helper
  no longer skips a startup lookup, since a first run makes none.

**Added by TASK 7.4** (light-pollution MVP; scraper removed), 16 tests:
- **No network, no scraper (`planner_sky_darkness_test.dart`):** two location
  changes create no `HttpClient` (counted through `HttpOverrides`; checked to
  count a real request); no `lib/` file contains scraping code.
- **Unknown vs known (`sky_darkness_test.dart`, `planner_sky_darkness_test.dart`):**
  - nothing entered is unknown, with no default;
  - a site's values carry source and date;
  - Bortle and SQM are never derived from each other;
  - unknown cannot warn; a known Bortle 7 warns; a bright SQM alone does not;
  - Bortle for a transient position is marked "not saved" and goes with it.
- **Map link (`light_pollution_map_link_test.dart`):** centred on the position;
  the hard-coded Slovenia coordinates are gone.
- **Sky card (`sky_darkness_context_test.dart`):** "unknown" with how to add it;
  known values with their sources; an SQM reading not turned into a Bortle class.
- **Editor (`sites_screen_test.dart`, +2):** Bortle and SQM entered are stored as
  `user` with the date; an out-of-range SQM is rejected.
- **Updated, with their reasons:** `feature_scope_test.dart` now expects
  `lightPollutionContext` to be `true` (its PD-06 phase); the Home gated-feature
  test now expects the map card with a site; `planner_site_test.dart`'s map-pick
  test used a fake scraper answering 5 and now expects an unknown Bortle class.
  The scraper argument was removed from every `PlannerViewModel(...)` call in the
  tests (a mechanical change, no assertion weakened).

**Added by TASK 8.1** (target model hardening, schema v13), 31 tests:
- **Parsers (`astro_math_coordinates_test.dart`, hand-computed values):**
  - the acceptance example `05h35m17s` / `−05°23′28″` → 83.820833° / −5.391111°,
    in six RA and five Dec spellings;
  - `−0°30′` in three spellings is −0.5°;
  - decimal hours and seconds, `h m`, explicit degrees with `°`/`deg`/`d`;
  - a bare `83.82` is rejected (hours > 24);
  - out-of-range and malformed input rejected;
  - format output, and format → parse round trips within the display resolution.
- **Domain (`astro_target_user_edit_test.dart`):** a new target's catalog id and
  source; edits keep the catalog id; rename/retype keep the source; data edits
  make it `user`; what counts as a catalog entry; moving types not selectable.
- **Repository (`drift_target_repository_test.dart`, +5):** new fields round-trip;
  an update never changes the catalog id; catalog entries unique, user rows not;
  `%`/`_` searched literally; seeds carry `seed:catalog@1`.
- **Migration (`schema_migration_test.dart`, +7):** v8–v12 → v13 snapshot
  equality; v12 → v13 preserves data (including duplicate legacy ids) with epoch
  J2000 and unknown source/size/magnitude; the partial unique index.
- **Screen (`target_selection_screen_test.dart`):** the acceptance example is
  stored as the correct degrees; moving types not offered; an edit keeps the
  catalog id and a moving type (with its warning); a rename keeps the exact
  coordinates and the source (this caught a real rounding bug before commit).
- **Rewritten, with the reason recorded in the file:** the four dialog tests that
  typed bare degrees and expected "Must be a number" / "Must be 0.0 to 360.0" now
  check the same rules in the new input format.

**Added by TASK 8.2** (curated OpenNGC catalog), 12 tests:
- **Asset (`catalog_seeder_test.dart`):** 164 objects, 109 Messier (M102 absent
  as an OpenNGC duplicate), unique ids, version/source/epoch; size for all but
  M40/M73; only fixed-coordinate types; every object's degrees equal its OpenNGC
  text parsed; 7 independent position spot checks (M31, M1, M42, M13, M51,
  ω Cen, Helix) within 0.02°; the notice credits OpenNGC and CC BY-SA 4.0.
- **Seeding:** a fresh install gets the catalog and re-running changes nothing;
  a deleted target (or all of them) is never resurrected; a newer catalog adds
  only its new entries; the pre-8.2 upgrade updates untouched old seeds in place
  (same row id) and leaves an edited M31 and a custom target alone; without
  preferences a non-empty table is left alone.
- **About page (`about_screen_test.dart`):** the notice and other credits.
- **Updated, with its reason:** `drift_target_repository_test.dart`'s seeding
  test pinned the old `seed:catalog@1` source and M42 position; it now checks the
  catalog's.

**Added by TASK 8.4** (equipment domain and schema v14), 21 tests (the removed
`drift_equipment_catalog_repository_test.dart` had 1):
- **Migration (`schema_migration_test.dart`, +7):** v8–v13 → v14 snapshot
  equality; a v13 rig with `aperture` 72 and `tracking_state` `tracking` keeps
  every value, reads as f/72 flagged for review and tracking unknown.
- **Repository (+2):** diameter, tracking type, maximum exposure and rotation
  round-trip (N stored in `aperture`); a new profile's tracking is unknown.
- **Domain (`equipment_limits_test.dart`, 8):** `resolveAperture` (N only, D only,
  1 % agreement both ways, missing and out-of-range cases including a derived
  f/40); the review flag at f/32; tracking storage; validator messages with units.
- **Editor (`equipment_selection_screen_test.dart`, +4):** a diameter derives the
  f/ (read-only) and saves D, tracking and maximum exposure; f/72 typed in is
  rejected; a stored f/72 shows the review prompt and is fixed by entering the
  diameter; every number's label carries its unit.
- **Updated, with their reasons:** two editor tests (the "> 0" message became the
  range message; the f/ field is now labelled "Focal ratio (f/)"); constructor
  arguments renamed across 7 test files (mechanical).

**Added by TASK 8.5** (equipment seeds and provenance, schema v15), 17 tests:
- **Seeder (`equipment_seeder_test.dart`, now 3):** one seed with the ZWO page's
  values, confidences and N = f / D; every seed's sensor size = resolution ×
  pitch within 2 %; a non-empty table is left alone. *(Rewritten, with the reason
  in the file: the old test found the stub by "400mm" in its former name.)*
- **Migration (+8):** v8–v14 → v15 snapshot equality; a legacy phone row keeps its
  values with unknown provenance.
- **Repository (+1):** camera and optics provenance round-trip per row.
- **Domain (`equipment_provenance_test.dart`, 5):** new profile → user/reported;
  rename or tracking keeps both; a camera or optics change affects only its group;
  confidence storage.
- **Editor (+1):** saving a verified seed unchanged keeps it verified (guards the
  2-decimal sensor display), and the provenance caption shows.

**Added by TASK 8.6** (capability summary and untracked guidance), 11 tests:
- **Domain (`capability_calculator_test.dart`, 8; reference values computed in the
  test):** ASI2600MC at 400 mm FOV 3.3652° × 2.2486° and pixel scale; NPF only for
  untracked/unknown (unknown marked conditional); field-minimum |δ| (southern
  target; floored at 0 near the equator); k scales NPF linearly; recommendation =
  min(NPF, max exposure) / max exposure / none; warning boundary (equal is fine);
  frame fill; a tripod phone's NPF of a few seconds warns a 30 s sub.
- **Widget (`capture_plan_widget_test.dart`, +2):** the roadmap acceptance — a
  phone with a 30 s light block shows the warning (the 2 s block does not) and the
  plan keeps both blocks; a guided rig without a maximum exposure gets no warning.
- **Preferences (+1):** `npfK` default, round trip and clamping.
- *Caught while writing:* two hand-typed FOV reference constants were off in the
  fourth decimal; the formula-based assertions next to them were already correct.

**Added by TASK 9.2** (WeatherSnapshot and UTC parsing), 10 tests in
`open_meteo_forecast_test.dart`, on fixtures recorded from api.open-meteo.com on
2026-09-23 (`test/fixtures/weather/`: a real `best_match` response for Ljubljana with
the ADR-012 variables, and a real out-of-range error):
- **Parser:** the recorded response (15 UTC hours, every variable); instants are UTC
  and independent of the device zone (the acceptance test); a site in another zone
  (Los Angeles) keeps its UTC instants; nulls, short arrays and missing variables are
  unknown; the recorded out-of-range error, other errors and malformed bodies
  (including naive ISO time strings) are typed failures.
- **Request:** the night's `[start, end)` becomes `start_hour`/`end_hour` in GMT with
  `best_match` and `timeformat=unixtime`; the end is capped at the 16-day horizon; a
  night beyond it fails as out of range without a request; non-200, offline and garbage
  responses.
- Test doubles of `WeatherRepository` got the new method through a shared
  `NoSnapshotWeather` mixin (20 files, mechanical).

**Added by TASK 9.3** (weather caching, freshness, failure states), 14 tests:
- **Service (`night_weather_service_test.dart`, 10; controllable clock):** age
  thresholds at 2 h 59 m / 3 h / 11 h 59 m / 12 h; a first load fetches and caches;
  a current cache is used without a request; an aging cache is refreshed; the
  acceptance — offline, the cached forecast is shown with its age (aging at 5 h,
  stale at 15 h) and the failure; offline without a cache is unavailable; out of
  range; a forced refresh; another site never gets this site's cache; the key
  separates site, model and night.
- **Store (`shared_prefs_weather_snapshot_store_test.dart`, 2):** round trip keeps
  UTC instants, the fetch time and nulls; missing, unreadable and unknown-version
  entries read as absent.
- **ViewModel (`planner_night_weather_test.dart`, 2):** idle without a site (no
  request); with a site the night forecast loads, then comes from the cache with its
  age when offline.

**Changed by TASK 9.4** (night-aligned weather indicators and UI), +15 / −3 tests (547):
- **Summary (`night_weather_summarizer_test.dart`, 10):** slots cover every UTC hour
  overlapping sunset..sunrise; ranges use only covered hours inside the night and
  ignore missing values (never 0); missing hours are "no forecast"; dew spread flagged
  at the margin boundary (spread = margin is a risk), unknown without both values; the
  configured margin is used; span: normal night, a window edge standing in for a
  missing sunset, midnight sun and polar night (whole window, labelled), a real
  Ljubljana night; the acceptance — a night 5 days ahead shows its own hours, and
  another night's hours never stand in for it.
- **Card (`weather_forecast_widget_test.dart`, 5):** sunset-to-sunrise label, zone
  caption, age, model, ranges with units, "no forecast" for unknown variables, dew
  heuristic with the margin, attribution; offline with a 15 h cache is "Stale" and
  "Offline, showing the cached forecast", never "Updated"; unavailable with Retry;
  out of range; the acceptance — a night 5 days ahead shows its own hours, or "No
  forecast for these hours."
- **Home (`home_screen_test.dart`):** the weather-failure test now uses a saved site
  and a failing `fetchSnapshot` (the forecast needs a night).
- **Removed:** `open_meteo_weather_repository_test.dart` (3 tests of the legacy
  `getCurrentWeather` and its cache), deleted with that code by owner decision; the
  new path is covered by `open_meteo_forecast_test.dart` and the service/store tests.

**Added by TASK 10.2** (ImagingOpportunity calculator), 25 tests (572):
- **Calculator (`imaging_opportunity_calculator_test.dart`, 23):** ADR-013 vectors
  V1–V12 on synthetic samples (exact windows, all failing reasons, Moon and weather
  annotations, the 50 % boundary, cloud hour neighbourhoods and "no forecast" hours,
  no darkness at −18° but a window at −12°, max altitude inside the window);
  equality limits; exclusion only by optional gates; missing inputs give no
  annotations and exclude nothing; mismatched Moon grid rejected; real sky —
  agreement with the previous windows (M42), polar night (one window clipped at
  both ends), midnight sun, a never-rising target, a circumpolar dip split at lower
  culmination, a shared Sun track, MoonCalculator input.
- **Preferences (`shared_prefs_planning_repositories_test.dart`, 1):** the optional
  gates default off, round-trip and clamp.
- **ViewModel (`planner_preferences_test.dart`, 1):** the acceptance — enabling the
  Moon gate on a moonlit March night shortens the windows, and the fit's available
  time equals the gated windows.

**Changed by TASK 10.3** (opportunity presentation), +6 / −1 tests (577):
- **List and wording (`tonight_opportunity_widget_test.dart`, 6):** durations;
  reasons list every failing gate in a fixed order; Moon and forecast annotations
  (no verdict); every no-window reason has its own sentence; the acceptance — every
  excluded period is listed with its reasons (ADR-013 V3); a night without a window
  says why.
- **Chart (`altitude_chart_widget_test.dart`):** renders an `ImagingOpportunity`
  (legend shows the darkness limit and the window swatch), including polar night.
- **Home (`home_screen_test.dart`):** the "Tonight for this target" card is shown,
  no "Sky Warning", no culmination "Max Altitude"; two tests now scroll to what they
  check (the list builds lazily and the new card is taller).
- **Sky darkness (`planner_sky_darkness_test.dart`):** the warning tests became
  "Bortle and SQM are context only: no verdict, same windows"; the Moon/Bortle
  warning test in `planner_site_test.dart` was removed with the warning (owner
  decision, ADR-013 §6).

**Added by TASK 10.4** (tonight's candidates), 7 tests (584):
- **Evaluator (`candidate_evaluator_test.dart`, 4):** the acceptance — every batch row
  equals the single-target view (with `MoonCalculator.conditionsForNight`), with the
  optional gates off and on, a forecast and equipment; the acceptance — 250 targets
  in under 1 s (test machine, JIT warmed up; no device run); each sort column with
  unknown values last and name ties; filters (with a window, type, own targets).
- **Screen and ViewModel (`tonight_screen_test.dart`, 3):** the ViewModel evaluates
  every catalog target and the selected target's row equals Home's opportunity; no
  site gives nothing; the screen sorts by usable time, the "without a window" toggle
  widens the list, and a tap selects the target and returns.

**Added by TASK 11.2** (schema v16), in `schema_migration_test.dart`:
- v8, v9 … v15 → v16 each match the v16 snapshot exactly (8 tests).
- The acceptance: legacy logs (with blocks) become completed legacy sessions, keep
  every stored value, get no references or snapshot, and are still listed by the
  logbook repository.
- On a fresh v16 database: a new row is a non-legacy draft with zero block counters;
  an unknown status is rejected (CHECK); deleting a site, target or rig clears only
  that reference and keeps the session (SET NULL); snapshots round-trip as JSON and
  unreadable text reads as an empty map; a logbook `updateLog` keeps the v16 columns.

**Changed by TASK 11.3** (SessionRepository, snapshot builders), 613 tests:
- **Repository (`drift_session_repository_test.dart`, 12; replaces the 5
  `drift_logbook_repository_test.dart` tests with their order, block-fidelity and
  rejected-row checks):** create; newest-updated order and filters; blocks through
  update; save → planned and snapshot replaced, edit → draft; lifecycle (start freezes
  the plan and the execution-start snapshot, completed keeps results/notes editable);
  forbidden transitions; **rollback** of a failing write (blocks restored); legacy and
  night-key-less rows read-only; most recent open session; delete; the acceptance —
  editing a rig after saving leaves the saved snapshot unchanged.
- **Snapshot (`session_snapshot_builder_test.dart`, 4):** deterministic and unchanged
  by a JSON round trip; unit-keyed contents; missing inputs null; unknown version
  unavailable.
- **ViewModel (`planner_session_save_test.dart`, 3):** Save creates a planned session
  with references and a snapshot and updates it on the next Save; a completed session
  is never modified; opening follows references by id.
- **Logbook screen (4, was 3):** saved sessions and legacy logs listed with status,
  drafts hidden; delete confirmation (on a real in-memory repository).
- Updated: integration flow (Save → Logbook shows "Planned"; double Save = one
  session with a snapshot), Home and app-boot providers, the legacy-date `openSession`
  test, and the v16 migration tests (legacy rows listed by `SessionRepository`).

**Added by TASK 11.4** (planner on a persisted draft), 7 tests (620):
- **`planner_draft_session_test.dart` (7):** a first run creates one draft with the
  example plan and a restart resumes it; the acceptance — every edit is in the database
  when the call returns and a rebuilt ViewModel (restart) shows the same plan; the
  preferences plan moves once into a draft and is removed; duplicate for another night
  gets a new night key and leaves the original unchanged; a past night rolls forward
  on resume, a future one is kept; New = tonight + example plan; editing after Save
  gives "unsaved changes", and opening a completed session copies it into a new draft.
- **Updated:** `planner_session_save_test.dart` (two expectations follow the 11.4
  owner decisions: a frozen session opens as a copy; a new draft before changing the
  target) and `integration_flow_test.dart` (edits and Save run inside
  `tester.runAsync`, since they now write to the database).

**Added by TASK 12.2** (navigation shell), 5 tests (625):
- **`app_shell_navigation_test.dart` (5):** the app opens on Tonight with four tabs;
  the acceptance — every route in the map opens its screen (and the old flat routes
  are gone); back pops within a tab, then returns to Tonight; each tab keeps its
  place; the planner opens above the tabs and back returns to Tonight.
- **Kept:** `app_router_test.dart`'s two gating tests, now on the nested paths
  (`/settings/metadata` absent while gated; `/sessions` present) via
  `support/route_paths.dart`.
- **Updated:** Home tests start at `/session/current`; app boot expects Tonight; the
  E2E test reaches the logbook through `/sessions`; the Sites test uses the new
  editor path; the candidates test file follows its screen's rename.

**Added by TASK 12.3** (ViewModel decomposition), 6 tests (631):
- **`viewmodel_rules_test.dart` (4):** the ViewModels directory is not empty; no
  ViewModel imports `http`, `shared_preferences`, `drift`, `geolocator` or the data
  layer; none is over 250 code lines (300 physical); `planner_viewmodel.dart` is gone.
- **`session_night_resolver_test.dart` (+2):** `resolve` is the default night without a
  picked date and the picked night with one.
- **Updated:** the former `PlannerViewModel` tests run on `PlannerHarness`
  (`test/support/planner_harness.dart`), which builds the real `AppViewModels` graph and
  provides every ViewModel; tests that cleared `captureBlocks` directly now remove blocks
  through the API (the list is read-only); the Equipment, Target and Logbook screen tests
  mock `SessionPlanViewModel` instead of the planner.

**Added by TASK 12.4** (theme tokens, red field mode), 20 tests (651):
- **`core/theme/app_theme_test.dart` (9):** every field palette token, `ColorScheme` role,
  theme colour and text colour is red or black; every theme carries its palette; no
  theme text style is under 12 sp (after localisation); the field filter keeps green and
  blue at zero, leaves pure red unchanged, keeps brightness order and passes alpha.
- **`presentation/theme/presentation_style_rules_test.dart` (3):** no `Colors.` or
  `Color(0x…)` in `lib/presentation`; no font size under 12; no shrink-wrapped tap target.
- **`viewmodels/theme_viewmodel_test.dart` (3):** off by default; a toggle is saved and
  restored by a new ViewModel (a restart); an unreadable store leaves it off.
- **`presentation/theme/field_mode_darkness_test.dart` (5), the automated darkness
  checklist:** real pixels (`RenderRepaintBoundary.toImage`) have zero green and blue on
  Tonight, the planner, the date picker, a dialog and a snackbar in field mode; one tap on
  Tonight turns it on and saves it; a restart comes back in field mode; the Settings switch
  works; a sanity test sees colour outside field mode.
- **Updated:** `feature_scope_test.dart` (field mode is visible since TASK 12.4, on the
  PD-06 schedule); Home's gating test expects the planner's field-mode button.
- **Owner checklist (manual, not yet done):** on an Android device in real darkness, with
  field mode on, go through Tonight, the planner, the date picker, a delete confirmation,
  a snackbar, the site map picker and Settings; look for any non-red or bright pixel and
  any white flash on navigation or restart. The status and navigation bars are the
  system's and are out of scope (no system-brightness control).

**Added by TASK 12.5** (Tonight dashboard, first run), 14 tests (665):
- **`screens/tonight/tonight_home_screen_test.dart` (14):** no site (site prompt, no night
  or fit rows); with a site (night, dark, Moon rows); no forecast ("No forecast", no
  number); no rig (says so, opens the rig picker); a small plan fits (label, reason,
  usable time); a huge plan doesn't fit (label, reason); no overflow at 200 % text on a
  360 × 640 dp phone for the dashboard with and without a site and for the first-run
  page; the first run is offered without a site and Skip or Done store it as done, a step
  opens its picker and comes back, and it is not offered with a site or once done.
- **Owner walkthrough (manual, not yet done):** on a device, a fresh install shows the
  setup; set a site by GPS (the permission prompt appears only after the rationale) and
  by hand; skip it on a second fresh install; check Tonight at large text sizes.

**Added by TASK 13.2** (execution engine, schema v17), 95 tests (760):
- **`domain/services/execution_machine_test.dart` (62):** the full transition table (5
  phases × 9 event kinds, 45 cases); interruption needs a reason; unknown blocks; counts
  never below zero; sequence order; fold equals step-by-step; running time across pauses,
  block changes and a restart; clock behind (event stamped at the last one, flagged;
  interval counted as zero), clock far ahead (capped); the estimate formula, reported
  frames, a paused run, a non-positive cycle; staleness.
- **`data/repositories/drift_session_execution_test.dart` (11):** start on the first light
  block; one session in progress; no blocks, no start; counters written with each event
  and equal to the replayed events; a refused event rolls back; events only while in
  progress; finish/abandon events; **acceptance: a kill mid-block on a file database
  restores the exact state**; clock set back; delete cascades; snapshot accessors.
- **`schema_migration_test.dart` (+13):** v8–v16 → v17 exact; v16 data kept, no events;
  kind CHECK; unique seq per session; cascade on delete.
- **`screens/tonight/resume_run_prompt_test.dart` (9):** the prompt with running time and
  estimate; keep going writes nothing; pause now; finish; abandon asks first; a past night
  is flagged and not finished; a paused run; a clock behind; no prompt without a run.

**Added by TASK 13.3** (tracking screen, Start), 20 tests (780):
- **`domain/services/execution_outlook_test.dart` (7):** CALC-36 — dawn ahead or passed;
  the target's next crossing and "below now"; the Moon up/down and next rise; window
  left; plan left (lights and in-window calibration, minus confirmed); nothing guessed
  without inputs; the snapshot accessors (night, zone, limit, target, windows).
- **`screens/execution/execution_screen_test.dart` (13):** Start runs the plan and the
  planner goes on with a draft copy; a second Start is refused; TD-055 after a restart
  (the run is never edited); the running screen with counts and outlook; +1, −1, Reject;
  Accept estimate after time passes; Pause with a reason and Resume; the block switcher;
  Finish with confirmation; keep-screen-on opt-in and released on leaving; **acceptance:
  every action in the lower half, ≥ 48 dp and labelled**; no overflow at 200 % text on
  360 × 640 dp; Start on Tonight opens the tracker and Tonight shows the run.
- **Updated:** `theme_viewmodel_test.dart`'s broken store implements the new
  keep-screen-on methods.
- **Owner checklist (manual, not yet done):** on an Android device, start a session, lock
  and unlock the phone, kill the app mid-block and reopen it (resume prompt, exact
  counts), and check keep-screen-on keeps the screen awake only on the tracker.

**Added by TASK 13.4** (reconciliation), 15 tests (795):
- **`domain/services/session_reconciliation_test.dart` (4):** CALC-37 — planned light
  integration; actual integration excludes rejected frames and calibration; more than
  planned; no fraction without lights.
- **`drift_session_execution_test.dart` (+5):** complete writes the light totals; a
  correction after completion is a timestamped event after `finished` and updates the
  counters, totals and `updated_at`; no pause after completion; no correction after
  abandoning; optional conditions stored, empty stays unknown.
- **`screens/execution/results_screen_test.dart` (6):** the page's summary and counts; a
  stepper stores an event; out-of-range conditions refused; Complete stores notes and
  conditions; Abandon asks first; **acceptance: a completed session shows planned vs
  actual in Sessions, and Edit results corrects it with a timestamped event**.
- **Updated (owner decisions):** the transition table allows confirm/reject after
  `finished`; the tracker's Finish test now expects the results page (the run is completed
  only by Complete).

**Added by TASK 14.1** (Sessions filters and detail), 13 tests (808):
- **`data/repositories/session_list_filter_test.dart` (5):** the query filters — no
  filter, status, target and site (never a legacy row), an inclusive night range with a
  legacy row matched by its stored date, and combined filters.
- **`screens/logbook/session_detail_test.dart` (8):** the Completed chip and Clear; the
  target picker; the Legacy badge and tap → detail; **acceptance: a completed run renders
  from its execution-start snapshot (night with zone, rig, target, plan vs actual, notes,
  conditions) and a legacy log renders its stored text**; a planned session from its plan
  snapshot; a session without a snapshot says so; 200 % text on a phone.
- **Updated:** the Sessions and E2E tests look for the row's "Planned" status inside the
  list (a "Planned" filter chip now exists).
