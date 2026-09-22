# AstroPlan — Scientific Integrity Register

> **Verification stamp:** verified against code at commit `900b82a` (2026-09-20),
> audited 2026-09-21. Application code changed since only by TASK 1.1 (commit
> `2357755`); the only spot it touches here is the integration-test RA fixture
> below. TASKs 1.2–1.3 changed application code without touching any calculation
> recorded here. **2026-09-22 (TASK 2.1):** SI-010 gained a decision note (ADR-007);
> no calculation changed. **TASK 2.2:** new calculation CALC-21 (the session-night
> window), which is not yet used by the app; SI-010 progress noted. **TASK 2.3
> (commit `de1792a`):** CALC-10/CALC-11 reimplemented as wrappers over new
> calculations CALC-22/CALC-23/CALC-24 (SessionNight-based timeline, windows,
> altitude curve); same formulas, not yet used by the app either; SI-010 progress
> extended. **TASK 2.4 (2026-09-22, commit `1e58fcf`):** SI-010 resolved — the
> ViewModel now resolves a real `SessionNight` (see `docs/TECH_DEBT.md` TD-001).
> `PlannerViewModel.lunarIllumination` (CALC-09's caller) now evaluates at
> `sessionNight.startUtc + 12h` (mean solar midnight) instead of the old
> `_sessionDate`; this is ADR-007 §9's suggested **candidate** instant for
> night-level scalars, used here as an interim, documented choice — **G6 has not
> formally decided the canonical evaluation instant**, so this is not a closed
> scientific decision. See SI-002's update below. **TASK 4.1 (2026-09-22, commit
> `f5b29cc`):** the "Invalid capture-block input" SI-008 evidence row below is
> resolved — no calculation changed.
> **Nothing in this document has been fixed.** It records issues and the
> required future action for each. See `docs/TECH_DEBT.md` for the work items.

## Purpose and authority

This register is the single place where scientific and astrophotography-model
issues are recorded. It exists because the project rules require it:

- `CLAUDE.md` rules 12–19 (deterministic calculations, explicit units, no silent
  formula changes, documented assumptions, never present relative stacking gain
  as absolute SNR, configurable thresholds).
- `.agents/rules/04-scientific-calculations.md` (every non-trivial calculation
  must document purpose, inputs, units, formula, assumptions, output, valid
  range, edge cases, reference/source, and tests).
- `docs/DECISIONS.md` ADR-005 (scientific calculations are auditable) and
  `docs/PRODUCT_SPEC.md` "Scientific Integrity".

Status vocabulary: **Implemented / Partial / Prototype / Broken / Missing /
Deprecated / Unknown** (definitions in `docs/FEATURE_STATUS.md`).

Issue format used below (as required): **Scientific Issue → Current Behavior →
Correct Interpretation → Required Future Action.**

## Index

| ID | Topic | Status of the underlying feature | Work item |
| --- | --- | --- | --- |
| SI-001 | NPF exposure formula deviates from the published formula | Broken (not surfaced in UI) | TD-007 |
| SI-002 | Moon: mean-phase precision limit, no Moon geometry | Partial | TD-032, TD-033 |
| SI-003 | Relative stacking gain (√N) vs physical SNR | Partial (label deviates) | TD-009 |
| SI-004 | ISO / gain limitations | Prototype (descriptive text only) | TD-009 |
| SI-005 | Aperture semantics and unit problem | Broken (seed data), Partial (model) | TD-008 |
| SI-006 | Hard-coded astronomy and planning thresholds | Partial | TD-033, TD-043 |
| SI-007 | Bortle default vs unknown | Broken (fetch), Partial (manual, hidden) | TD-006 |
| SI-008 | Unknown treated as zero / default presented as fact | Partial | TD-013 |
| SI-009 | Undocumented astronomical model simplifications | Implemented (adequate for planning, undocumented) | TD-036 |
| SI-010 | "Night" definition and date/time-zone semantics | Resolved (default path; TASK 2.4) — site-zone display still open | TD-020 |
| SI-011 | Seed equipment data provenance and internal consistency | Unknown / Partial | TD-008 |
| SI-012 | Target coordinates, epoch and object types | Partial | TD-016 |
| SI-013 | Storage estimate assumptions | Partial | TD-013 |

---

# Part A — Scientific Issue Register

## SI-001 — NPF exposure formula deviates from the published formula

**Scientific Issue**
`OpticalCalculator.calculateNPFExposure` replaces the focal-length-proportional
term of the complete NPF formula with the constant `90.0`.

**Current Behavior**
- Implemented as `t = (16.856·N + 13.713·p + 90.0) / (f · cos δ)`
  (`lib/domain/services/optical_calculator.dart:87`), where N = f-number,
  p = pixel pitch (µm), f = focal length (mm), δ = declination.
- The published *complete* NPF formula (F. Michaud) has the form
  `t = K · (16.856·N + 0.0997·F + 13.713·p) / (F · cos δ)`; the source cited
  below prints the constants rounded (16.9, 0.1, 13.7). The un-rounded constants
  must be confirmed against Michaud's original document before any fix.
- **Provenance (git):** the function was introduced in commit `d0b737f`
  (2026-09-18) already using `+ 90`; no earlier NPF version exists. It is an
  original error, not a regression or a silent change of a prior formula.
- The two agree only near F ≈ 903 mm. Measured on 2026-09-21 (K = 1, δ = 0,
  published form computed with 0.0997):

  | Optics | App | Published | App ÷ Published |
  | --- | --- | --- | --- |
  | iPhone 15 Pro Max main (f/1.78, 1.22 µm, 6.86 mm) | 19.93 s | 6.91 s | 2.88 |
  | Pixel 8 Pro main (f/1.68, 1.20 µm, 6.9 mm) | 19.53 s | 6.59 s | 2.96 |
  | 50 mm f/2.8, 4.0 µm | 3.84 s | 2.14 s | 1.79 |
  | ASI2600MC, 400 mm f/4 (the unit-test case) | 0.52 s | 0.40 s | 1.32 |
  | ASI2600MC, 900 mm f/6 | 0.27 s | 0.27 s | 1.00 |
  | ASI2600MC, 2000 mm f/8 | 0.14 s | 0.19 s | 0.72 |

- The unit test asserts `0.522 s` for the 400 mm case, and its comment derives the
  expected value from the same `+ 90` constant, so the test confirms the code
  rather than an independent reference
  (`test/domain/services/optical_calculator_test.dart`).
- Not displayed anywhere: `PlannerViewModel.npfExposure` has no UI consumer, so
  users are not currently affected. There is no K (tolerance) parameter. The
  function throws `ArgumentError` for `f ≤ 0` or `N ≤ 0`; a UI getter that calls
  it without a guard would throw during `build`.

**Correct Interpretation**
NPF is a *recommendation* (rule of thumb) for the longest **untracked** exposure
before star trailing becomes visible. It depends on a tolerance factor K and on
declination. It does not apply to tracked or guided exposures, which is the main
astrophotography use case. The simplified form is `(35·N + 30·p) / F`.
`PRODUCT_SPEC.md` requires NPF, when implemented, to be labeled as a
recommendation and not an absolute exposure limit.

**Required Future Action**
1. Obtain the primary reference and confirm the constants.
2. Correct the formula, citing the reference in the doc comment (CLAUDE.md
   rule 16: do not silently change formulas — record the change in
   `docs/DECISIONS.md`).
3. Replace the circular test with independent reference values.
4. State K explicitly (K = 1 default or a parameter).
5. Do not surface NPF in the UI until 1–4 are done and the wording is labeled a
   recommendation for untracked exposures.

**Sources:** complete formula — https://mypetstars.com/glossary/npf-formula ;
simplified formula — https://www.npfcalculator.com/ .
**Status:** Broken (unsurfaced). **Work item:** TD-007.

---

## SI-002 — Moon: mean-phase precision limit and missing Moon geometry

**Scientific Issue**
Lunar illumination is derived from a mean synodic month and one epoch; the
result is presented with more precision than the model has, and no Moon
geometry exists.

**Current Behavior**
- `VisibilityCalculator.calculateLunarIllumination`
  (`lib/domain/services/visibility_calculator.dart:70-81`):
  `0.5·(1 − cos(2π·phase))`, phase from a new-moon epoch of
  2024-01-11 11:57 UTC and a fixed synodic month of 29.530588 days.
- **Measured against the US Naval Observatory 2025 phase table** (28 events:
  4 quarter events + 24 new/full events; source
  `https://aa.usno.navy.mil/api/moon/phases/year?year=2025`):
  - worst error at quarter phases: **4.7 percentage points**
    (2025-02-05 first quarter: model 0.453 vs 0.50);
  - worst error at new/full: **0.8 percentage points**.
- `SkyDarknessWidget` prints one decimal (e.g. `Moon Illumination: 45.3%`)
  (`lib/presentation/widgets/sky_darkness_widget.dart:15`).
- Illumination is evaluated at one instant of the `SessionNight`, not over the
  imaging window. **Updated TASK 2.4 (2026-09-22, commit `1e58fcf`):** that
  instant is now `sessionNight.startUtc + 12h` (mean solar midnight), ADR-007
  §9's candidate for night-level scalars — chosen as a documented interim value,
  not a formal decision (G6 owns that decision). Before TASK 2.4 it was whatever
  `_sessionDate` held (now, or the picked date at local midnight); `null` when
  there is no site (SI-008), instead of silently evaluating at the default
  London coordinates.
- There is **no** Moon altitude, moonrise/moonset, or Moon–target angular
  separation anywhere in the code (all are in the `PRODUCT_SPEC.md` MVP scope).
- `PlannerViewModel.skyDarknessWarning` uses `illumination > 0.8` regardless of
  whether the Moon is above the horizon
  (`lib/presentation/viewmodels/planner_viewmodel.dart:435`).

**Correct Interpretation**
Illuminated fraction is a coarse proxy for sky-brightness impact. The real
effect depends on Moon altitude, phase, angular distance to the target, target
altitude, atmospheric conditions and bandpass (narrowband vs broadband). A bright
Moon below the horizon has no effect. Displayed precision must not exceed model
accuracy (≈ ±5 percentage points measured on 2025 samples; a multi-year error
scan has not been done).

**Required Future Action**
1. Round the display and state the approximation, or replace the model with a
   documented lunar ephemeris (for example a truncated series from Meeus,
   *Astronomical Algorithms*, ch. 47) validated against USNO/JPL data.
2. Add Moon altitude, rise/set and Moon–target separation as pure-Dart domain
   services (PRODUCT_SPEC MVP).
3. Evaluate illumination and Moon altitude over the imaging window.
4. Make the Moon warning threshold configurable and documented (see SI-006).
   The ephemeris choice is already an open decision in `docs/DECISIONS.md`
   (PD-07).

**Status:** Partial. **Work items:** TD-032, TD-033.

---

## SI-003 — Relative stacking gain (√N) vs physical SNR

**Scientific Issue**
The UI labels a √N statistic "Relative SNR", and the statistic depends only on
frame count, so it cannot compare plans with different sub-exposure lengths.

**Current Behavior**
- `OpticalCalculator.calculateRelativeStackingGain(N) = √N`, computed from the
  **light-frame count only** (`optical_calculator.dart:44-47`;
  `planner_viewmodel.dart:502-504`).
- The UI label is `Stacking Gain (Relative SNR)`, value shown as e.g. `10.0x`
  (`lib/presentation/widgets/capture_plan_widget.dart:215`).
- The doc comment correctly says "relative gain, not absolute SNR", but the label
  contains the word SNR. This conflicts with CLAUDE.md rule 18, ADR-005 and
  `PRODUCT_SPEC.md` ("must be labeled as relative stacking gain, not absolute
  SNR"). The label was deliberately restored in commit `1baa514`
  ("restore SNR").
- Example of the limitation: 100 × 60 s and 20 × 300 s are both 6000 s of
  integration, yet the app shows gain 10.0 and 4.5 respectively.
- No sky background, read noise, dark current, signal rate, or rejection model
  exists.

**Correct Interpretation**
For N independent, identically distributed frames with uncorrelated noise,
averaging improves SNR by √N **relative to a single frame of the same exposure**.
It is a statistical approximation, not a physical SNR. Comparing different
sub-exposure lengths requires a noise model (signal rate, sky rate, read noise,
dark current) that the app does not have and has no data to build.

**Required Future Action**
1. Rename the UI label to "Relative stacking gain (√N vs one frame)".
2. Document the assumptions in the doc comment and in a UI help text.
3. Make total integration time the primary comparison figure; do not compare gain
   across different sub-exposure lengths.
4. Do not introduce a physical SNR model without an approved ADR and per-camera
   gain/read-noise data.

**Status:** Partial (metric acceptable, label deviates). **Work item:** TD-009.

---

## SI-004 — ISO / gain limitations

**Scientific Issue**
ISO/gain must never be presented as increasing photon collection, and the app has
no sensor-specific gain model.

**Current Behavior**
- `CaptureBlock.gainIso` is a free-text `String?`
  (`lib/domain/models/capture_block.dart`); the DB column is text.
- The Add Capture Block dialog does not expose it. No calculation uses it.
- `MetadataExtractor` reads `ISOSpeedRatings` / `GAIN` / `ISOSPEED` as strings
  for display only.
- No ISO-dependent calculation, wording or recommendation exists today.

**Correct Interpretation**
ISO (or camera gain) sets analog/digital amplification of the recorded signal. It
does **not** increase the number of photons collected; photon count depends on
aperture, exposure time, quantum efficiency and the source. Changing ISO changes
read noise relative to signal, saturation level in ADU and dynamic range, in a
sensor-specific way (dual-gain and ISO-invariant sensors behave differently).

**Required Future Action**
1. Keep ISO/gain descriptive only until a per-camera gain / read-noise dataset
   exists.
2. Ensure no UI text says ISO "increases sensitivity" or "collects more light".
3. If a future feature uses ISO/gain in a calculation, require a documented
   sensor-specific model and an ADR first.
4. Consider a typed gain field with units (ISO vs camera gain units) instead of
   free text.

**Status:** Prototype. **Work item:** TD-009 (tracked together with SI-003).

---

## SI-005 — Aperture semantics and unit problem

**Scientific Issue**
The field named `aperture` means *focal ratio (f-number)* in the UI and formulas,
but seed data stores a diameter in one record, and field names carry no units.

**Current Behavior**
- `EquipmentProfile.aperture`, `OpticalRig.aperture` and the DB column `aperture`
  are treated as an **f-number**: UI label `Effective Aperture (f/)`
  (`equipment_selection_screen.dart:325`), Home shows `f/<value>`
  (`home_screen.dart:105`), NPF takes `apertureFNumber`, and the shareable log
  text prints `f/$aperture` (`session_log.dart:71`).
- The seeded record "ZWO ASI2600MC + 400mm (Telescope Stub)" stores
  `aperture: 72.0` (`lib/data/services/equipment_seeder.dart:82`), which is a
  72 mm *diameter* (400/72 ≈ f/5.6), displayed as `f/72.0`. With N = 72 the NPF
  function returns 3.39 s, versus ≈ 0.46 s from the published formula with
  N ≈ 5.56.
- Field names are unit-less in the domain model (`focalLength`, `aperture`,
  `pixelPitch`, `sensorWidth`); only the foundation tables use unit suffixes
  (`focalLengthMm`, `pixelPitchUm`), and `aperture` has none there either.
- Validation only requires `> 0`.

**Correct Interpretation**
"Aperture" can mean entrance-pupil diameter (mm) or focal ratio N = f / D. Mixed
semantics break every downstream formula. Each field must hold one unambiguous
quantity with an explicit unit.

**Required Future Action**
1. Define canonical fields (for example `focalRatio` dimensionless and, optionally,
   `apertureDiameterMm`, with one derived from the other via focal length).
2. Rename fields with explicit units; add plausible-range validation.
3. Correct the seed record.
4. Decide a migration policy for user-entered rows — they cannot be auto-classified
   without guessing, and silent guessing is prohibited (owner decision PD-10).
5. Add tests.

**Status:** Broken (seed), Partial (model). **Work item:** TD-008.

---

## SI-006 — Hard-coded astronomy and planning thresholds

**Scientific Issue**
Several arbitrary values act as if they were universal, are not configurable by
the user, or are undocumented (CLAUDE.md: "Do not treat arbitrary thresholds as
universal scientific laws"; rule 19; `.agents/rules/02-code-quality.md`: name and
document constants).

**Current Behavior — full inventory**

| Threshold | Value | Location | User-configurable? | Interpretation |
| --- | --- | --- | --- | --- |
| Minimum usable target altitude | default 20°, clamp [5°, 60°] | `planner_viewmodel.dart:55,156-161` | In ViewModel and persisted (`minAltitude`), **no UI control calls it** | Planning preference (airmass, obstructions, site). The doc comment claims "≥ 1 mag attenuation" below 20°; this is unsourced and site/band dependent |
| "Astronomical darkness" Sun limit | −18° | `visibility_calculator.dart:145` (default parameter) | No | Conventional twilight definition; whether −12° suffices is a user/filter choice (a unit test exercises −12° but no UI exists) |
| Sunset / civil / nautical / astronomical Sun altitudes | −0.833°, −6°, −12°, −18° | `visibility_calculator.dart:109-118` | No | Conventional definitions; acceptable as definitions, but undocumented in code |
| Sky warning | Moon illumination > 0.8 **or** Bortle ≥ 7 | `planner_viewmodel.dart:435` | No | Heuristic; ignores Moon altitude, target, filters; the warning text claims targets "will wash out" |
| Feasibility "tight" margin | required > 85 % of available | `session_calculator.dart:68` | No | Arbitrary safety margin |
| Per-frame overhead | 5.0 s flat (live path) | `planner_viewmodel.dart:482` | No | Unsourced; real overhead includes download, dither/settle, autofocus, filter change, meridian flip |
| Dead overhead model | 15 % of light time; flats 5 s; bias 1 s | `session_calculator.dart:30-48` | No | Unused by the app (see TD-022) |
| Dew-point margin | default 2.0 °C | `planner_viewmodel.dart:42` | In ViewModel and persisted (`dewPointThreshold`), no UI; result not shown anywhere | Dew risk depends on optics surface temperature, wind and heaters, not ambient − dew point alone |
| Cloud-cover colour bands | ≤ 20 green, ≤ 50 orange, else red | `weather_forecast_widget.dart:150-154` | No | Display heuristic only; not used in any calculation |
| Weather horizon | first 48 hourly entries | `open_meteo_weather_repository.dart:44` | No | Data-window choice |
| Default Bortle class | 4 | `planner_viewmodel.dart:41`; DB default; `LocationProfile` default | Hidden (see SI-007) | See SI-007 |
| Default location | London 51.5072, −0.1276 | `planner_viewmodel.dart:37-38` | Only via GPS/map | Used silently until GPS/permission succeeds (see SI-008) |
| Time scan steps | 5 min (timeline, windows); 15 min (chart) | `visibility_calculator.dart:104,156`; `altitude_chart_widget.dart:132` | No | Quantization (see SI-009) |

**Correct Interpretation**
Definitions (twilight limits) are conventions and may be constants if documented.
Preferences and heuristics (minimum altitude, warning limits, margins, overhead,
dew margin) are user/site dependent and must be configurable where scientifically
appropriate, named, documented, and never phrased as physical laws.

**Required Future Action**
1. Move each value to a named, documented constant or a setting.
2. Expose user-meaningful ones in a settings UI (minimum altitude, darkness Sun
   limit, overhead, tight margin, dew margin).
3. Remove or soften claims embedded in UI text and comments.
4. Record each rationale/source in this register when it is chosen.

**Status:** Partial. **Work items:** TD-033, TD-043.

---

## SI-007 — Bortle default vs unknown

**Scientific Issue**
Bortle class defaults to 4 everywhere, "unknown" cannot be represented, and no
working path sets it.

**Current Behavior**
- `PlannerViewModel._bortleClass = 4` (`planner_viewmodel.dart:41`);
  `LocationProfile.bortleClass` defaults to 4; the DB column defaults to 4;
  `setLocation` stores the current value on a new `Custom Location`.
- `LightPollutionRepository.fetchBortleClass` **can never succeed**: the request
  URL contains a literal `\${lat.toStringAsFixed(4)}` because the `$` is escaped
  (`lib/data/repositories/light_pollution_repository.dart:8`); reproduced on
  2026-09-21. The class is also a raw HTML scraper of a third-party site.
- The manual Bortle badge is hidden by `FeatureScope.lightPollutionContext = false`
  (`lib/presentation/widgets/sky_darkness_widget.dart:32`), so **no user path sets
  Bortle at all**. The Bortle half of the sky warning (≥ 7) is unreachable.
- `SessionLog.bortleScale` is `double?` while `LocationProfile.bortleClass` is
  `int`; Save Session never populates it.
- `PlannerViewModel._fetchBortle` is still invoked on every location change.

**Correct Interpretation**
The Bortle class is a coarse, partly subjective 1–9 scale. A site's class must be
user-provided or sourced from a dataset with attribution and uncertainty
(ROADMAP Phase 11: "source attribution and uncertainty"). "Unknown" is a valid
state and must not be silently replaced by a typical value.

**Required Future Action**
1. Represent unknown end-to-end (domain, DB, UI, warnings).
2. Record the source (manual / dataset / other) and date with each value.
3. Decide the data source (offline dataset vs manual Bortle/SQM entry; PD-05).
4. Remove or replace the scraper; until then keep the `FeatureScope` gate.

**Status:** Broken (fetch); Partial (manual entry, hidden). **Work item:** TD-006.

---

## SI-008 — Unknown treated as zero / default presented as fact

**Scientific Issue**
Absence of data is repeatedly displayed as a real value. This is a cross-cutting
integrity problem.

**Current Behavior**
| Situation | What the user sees |
| --- | --- |
| `averageRawFileSizeMB` is null (all 5 seeded profiles) | `Estimated Storage 0.0 MB` — `estimateStorageRequirement` does `(x ?? 0.0) * n` and the ViewModel returns a non-null number, so the `N/A` branch is unreachable (verified in a widget run) |
| Bortle never set | Bortle 4 used silently (SI-007) |
| GPS unavailable/denied on first launch | London coordinates used silently |
| Equipment `pixelScale` null | Text `null arcsec/px` (`home_screen.dart:104`) |
| Invalid capture-block input | **RESOLVED 2026-09-22 (TASK 4.1, commit `f5b29cc`).** *(Was: silently became 60 s × 30 frames.)* Now rejected by `Form` validators (exposure > 0, frame count ≥ 1) instead of defaulted |
| Fresh install | A default plan of 100×60 s lights, 20×60 s darks, 20×2 s flats is shown as the user's plan |

**Correct Interpretation**
Missing data is *unknown*; defaults are *assumptions*. Neither may masquerade as a
measurement or user input.

**Required Future Action**
Adopt and enforce the rule "no domain default may masquerade as a measurement":
nullable values with explicit UI states, and labelled assumptions. Record it as a
decision in `docs/DECISIONS.md` when approved.

**Status:** Partial. **Work item:** TD-013 (and SI-007).

---

## SI-009 — Undocumented astronomical model simplifications

**Scientific Issue**
The astronomy layer is adequate for planning but its simplifications and error
bounds are not documented, as rule 04 requires.

**Current Behavior**
- Target coordinates are used as J2000 without precession, nutation or aberration
  (≈ 0.36° of precession accumulated by 2026).
- Target altitude is geometric: no atmospheric refraction (refraction appears only
  inside the −0.833° Sun definition).
- The Sun uses low-precision solar coordinates (mean anomaly / longitude with a
  two-term equation of centre). The constants match the USNO "Approximate Solar
  Coordinates" formulas; the code does not cite them and no test compares against
  reference values.
- GMST uses the linear term of Meeus eq. 12.4; UTC is treated as UT1
  (difference up to 0.9 s ≈ 13.5″ of sidereal angle).
- `calculateJulianDate` ignores fractional seconds.
- Timeline events and visibility windows are quantized to 5 minutes; an event is
  reported at the **first sample after** the crossing (up to 5 min late). A
  source comment promises refinement to 1 minute that does not exist
  (`visibility_calculator.dart:103`). A control run for Berlin measured a 3-minute
  difference against a 1-minute scan.
- No topocentric parallax, elevation, horizon profile or obstruction model.

**Correct Interpretation**
For planning, arc-minute-level accuracy and 5-minute quantization are acceptable,
provided they are stated. They must not be presented as ephemeris-grade.

**Required Future Action**
Document each assumption and its error bound next to the calculation (see
Part B); add tests against an independent reference ephemeris (USNO / JPL Horizons)
for Sun altitude, twilight times and target altitude; decide whether refraction
should be included; correct the stale comment.

**Status:** Implemented (undocumented). **Work item:** TD-036.

---

## SI-010 — "Night" definition and date/time-zone semantics

**Scientific Issue**
The app's central question ("what can I photograph tonight?") depends on a
correct definition of *which night*, and the default is wrong in part of the
world.

**Current Behavior**
- `calculateNightTimeline` and `calculateVisibilityWindows` treat the year/month/day
  of the `date` argument as the **site-local solar date** and scan from
  12:00 UTC of that date minus `longitude/15` hours
  (`visibility_calculator.dart:85-90,139-151`).
- The ViewModel's default is `DateTime.now().toUtc()` — the **UTC** calendar date
  (`planner_viewmodel.dart:36`). The date picker supplies a **local** calendar date
  (correct semantics).
- **Verified 2026-09-21:** at 18:30 PDT on Sep 21 (San Francisco) the true next
  sunset is 19:08 PDT Sep 21; the app reports 19:10 PDT **Sep 22** — 24.0 h later —
  and the Home header reads `2026-09-22 (Night)`. Berlin (evening) is correct
  (3-minute quantization difference only). The primary developer's machine is in a
  UTC+3 zone, where UTC date equals local date in the evening, which is why it went
  unnoticed.
- Other components use other time bases: the altitude chart starts at **device-local**
  noon (`altitude_chart_widget.dart:131`); timeline times are printed in
  **device-local** time (`sky_darkness_widget.dart:137`); weather hourly times are
  naive site-local strings parsed as device-local (`open_meteo_weather_repository.dart:47`)
  and `utc_offset_seconds` is discarded; saved sessions round-trip through epoch
  seconds and return as local `DateTime`.

**Correct Interpretation**
An imaging "night" is the site-local noon-to-noon window that contains the evening
being planned (or the night currently in progress). The default must be resolved
from the current instant and the site, not from the UTC calendar date. All
consumers must share one time base, and display in a stated time zone.

**Required Future Action**
Owner decisions PD-01 (default-night rule) and PD-02 (site time-zone strategy),
then a pure-domain session-night definition with regression tests (Americas
evening, after-midnight, date line, DST, high latitude).

**Update 2026-09-22 (TASK 2.1, decision only — no code changed):** PD-01 and PD-02
are resolved by **ADR-007** (`docs/DECISIONS.md` Part F). This refines the "Correct
Interpretation" above without replacing it:
- **Identity:** a night is identified by the site plus its **civil** evening date D.
- **Window:** the window is `[startUtc, startUtc + 24 h)`, where `startUtc` is the
  site's mean solar noon (`12:00Z − round(λ·240 000) ms`) nearest to civil noon of D.
- **Default:** the default is the window that contains *now*.
- **Time context:** computation is in UTC through a time context. The context is mean
  solar until TASK 7.1 adds the site's IANA zone. The device zone is never used.
- **Polar states:** these are typed results, never nulls.

The assumptions, limitations (L1–L4), invariants (I1–I12) and the 17-case test matrix
are in ADR-007 §11–§14.

**Progress 2026-09-22 (TASK 2.2):** the ADR-007 window and default rule are
implemented in the pure domain as CALC-21 (`SessionNightResolver`) and tested against
the ADR matrix: 11 default-night cases and 9 chosen-date cases, 730-day invariant
sweeps in 13 contexts, and a 48-hour monotonicity walk. The expected instants were
computed independently of the code. **The app does not use it yet**: the default path
is still Broken until TASK 2.4, and the calculators take a `SessionNight` in TASK
2.3.

**Progress 2026-09-22 (TASK 2.3, commit `de1792a`):** CALC-10 and CALC-11 are no
longer independent implementations — both are now thin wrappers over the new,
`SessionNight`-based CALC-22/CALC-23 (plus CALC-24, the altitude curve), resolving
the input date through a `MeanSolarTimeContext`. Verified to agree exactly with the
pre-2.3 scan for a normal night, including that a window can be
`clippedAtStart`/`clippedAtEnd` through either path in polar night. The altitude
chart now consumes CALC-24 instead of computing astronomy itself (TD-023). **The
default path is still Broken**: nothing in the app resolves a real `SessionNight`
yet — `PlannerViewModel.sessionDate` is still the UTC calendar date, and both
CALC-10/CALC-11's wrapper and the chart derive their window from that same wrong
date. TASK 2.4 is what fixes the default itself.

**RESOLVED 2026-09-22 (TASK 2.4, commit `1e58fcf`):** `PlannerViewModel.sessionNight`
now calls `SessionNightResolver.resolveDefault(_clock.nowUtc(), ...)` for the
default (or `.forEveningDate(...)` for a picked date) — CALC-21 directly, not the
legacy UTC-date path. Verified against the ADR-007 T1 case (San Francisco,
18:30 PDT on 2026-09-21) by both a ViewModel test and a Home widget test: the
resolved evening date is 2026-09-21, not the 22nd. `home_screen.dart`,
`sky_darkness_widget.dart`, `altitude_chart_widget.dart` and `logbook_screen.dart`
all consume the same `SessionNight`/`NightTimeFormatter` (§6's "one formatter"),
so the chart, timeline, header and logbook can no longer diverge from each other.
Still device-zone display only (no site IANA zone; TASK 7.1) — that part of
SI-010 stays open under TD-020.

**Status:** Resolved (default path; TASK 2.4). **Open remainder:** site
time-zone display (TD-020, TASK 7.1). **Work items:** ~~TD-001~~ (resolved),
TD-020.

---

## SI-011 — Seed equipment data provenance and internal consistency

**Scientific Issue**
Seeded sensor/optics specifications lack stored provenance and are not internally
consistent.

**Current Behavior**
- `EquipmentSeeder` carries a comment claiming manufacturer specs and GSMArena
  (secondary) sources for phones and official ZWO documentation for the
  ASI2600MC; nothing is stored in the database.
- Sensor size vs resolution × pixel pitch:

  | Profile | Stored sensor (mm) | Resolution × pitch (mm) | Difference |
  | --- | --- | --- | --- |
  | Xiaomi 14 Ultra / Vivo X100 Pro | 13.2 × 8.8 | 13.11 × 9.83 | height −10.5 % |
  | Pixel 8 Pro | 9.6 × 7.2 | 9.79 × 7.37 | −1.9 % / −2.3 % |
  | iPhone 15 Pro Max | 9.8 × 7.3 | 9.84 × 7.38 | −0.4 % / −1.1 % |
  | ASI2600MC | 23.5 × 15.7 | 23.49 × 15.70 | consistent |

- `manufacturer` semantics are inconsistent (device brand for Apple; "Google /
  Samsung"; sensor maker "Sony" for Xiaomi/Vivo).
- Sensor model codes for phones (for example `IMX903`) are community-reported, not
  published by the phone maker; **this audit did not verify any seeded
  specification against a primary source.**
- The equipment form auto-derives sensor size from resolution × pixel pitch, so
  editing a seeded profile silently changes the stored size.
- `averageRawFileSizeMB` is absent from every seed (SI-008).

**Correct Interpretation**
`.agents/rules/04-scientific-calculations.md`: do not invent sensor
specifications. Every spec needs a source and confidence.

**Required Future Action**
Verify each spec against primary sources; store provenance and confidence
(DATA_MODEL "Provenance"); resolve the inconsistencies; define `manufacturer`
semantics (device vs sensor vendor); decide whether sensor size is stored or derived.

**Status:** Unknown / Partial. **Work item:** TD-008.

---

## SI-012 — Target coordinates, epoch and object types

**Scientific Issue**
Fixed J2000 RA/Dec is only valid for deep-sky objects, yet the UI offers moving
object types and inconsistent RA units appear in tests.

**Current Behavior**
- Coordinates are decimal **degrees** (RA 0–360, Dec ±90). The five seeded targets
  were checked and are correct (`catalog_seeder.dart`, via
  `AstroMath.raToDecimalDegrees`).
- The custom-target dialog takes RA in **degrees** (label explicit,
  `target_selection_screen.dart:130`); astronomers usually quote RA in hours.
- The integration test seeded Orion with `rightAscension: 5.59` (hours) in the
  degrees domain; **fixed 2026-09-21 (roadmap TASK 1.1, commit `2357755`)** to
  `83.85` (= 5.59 h × 15) (`test/integration_flow_test.dart`).
- `_kObjectTypes` offers `Planet`, `Moon`, `Comet`, `Asteroid`
  (`target_selection_screen.dart:9-20`); these move, and cannot be represented by a
  fixed RA/Dec.
- `currentAltitude` / `maxAltitude` treat `(RA, Dec) == (0, 0)` as "unset"
  (`planner_viewmodel.dart:445,456`).
- No epoch, source, magnitude, angular size or constellation is stored.

**Correct Interpretation**
J2000 coordinates are adequate for deep-sky planning at this precision. Solar-system
bodies need an ephemeris (an open decision in the Phase 0 `DECISIONS.md`: "Which
astronomical engine/library/reference to use for future ephemeris work").

**Required Future Action**
Block or hide moving-object types until the ephemeris decision (PD-07/PD-16); store
epoch and source; add an hours/HMS input option or clear unit affordance; remove
the `(0, 0)` sentinel; add angular size for FOV-fit.

**Status:** Partial. **Work item:** TD-016.

---

## SI-013 — Storage estimate assumptions

**Scientific Issue**
`PRODUCT_SPEC.md` requires storage estimates to distinguish theoretical pixel
payload from empirical average frame size; only the empirical value exists and its
unknown state shows as zero.

**Current Behavior**
`estimateStorageRequirement = averageRawFileSizeMB × totalFrames` over **all**
frame types (`optical_calculator.dart:52-57`; `planner_viewmodel.dart:493-500`).
It ignores differing calibration-frame sizes, compression variance and stacked
outputs. Bit depth was removed from the model in commit `900b82a`, so a
theoretical payload cannot currently be computed. Null renders as `0.0 MB` (SI-008).

**Correct Interpretation**
An empirical average per RAW file is a reasonable planning estimate when the user
supplies it; it is an estimate, and unknown must stay unknown.

**Required Future Action**
Label the value as an estimate; show "unknown" when no size is set; decide whether
a second, theoretical value is wanted (requires bit depth and sensor geometry).

**Status:** Partial. **Work item:** TD-013.

---

# Part B — Calculation Register

Documents each domain calculation as required by
`.agents/rules/04-scientific-calculations.md`. "Doc" = whether the code comment
already carries purpose/units/assumptions. All times are UTC unless noted.

| ID | Function (file) | Inputs → output (units) | Method / reference | Known limits and edge cases | Tests | Doc |
| --- | --- | --- | --- | --- | --- | --- |
| CALC-01 | `AstroMath.raToDecimalDegrees` (`lib/core/utils/astro_math.dart`) | h, m, s → degrees | `(h + m/60 + s/3600)·15` | No range validation | 1 | Good |
| CALC-02 | `AstroMath.decToDecimalDegrees` | d, m, s, isNegative → degrees | sign × (abs(d) + m/60 + s/3600) | A negative value with `d = 0` requires `isNegative: true` (−0°30′) | 2 | Good |
| CALC-03 | `AstroMath.normalizeDegrees` | deg → [0, 360) | modulo | — | indirect | Fair |
| CALC-04 | `AstronomicalEngine.calculateJulianDate` | UTC `DateTime` → JD | Meeus ch. 7, Gregorian | Throws `ArgumentError` if not UTC; ignores sub-second | J2000 | Good |
| CALC-05 | `calculateGMST` | JD → degrees | Meeus eq. 12.4 linear term | UTC ≈ UT1 (≤ 0.9 s) | J2000 | Fair |
| CALC-06 | `calculateLST` | GMST°, longitude° (east +) → degrees | GMST + λ | — | 1 | Good |
| CALC-07 | `VisibilityCalculator.calculateLHA`, `calculateAltitude` | LST°, RA°, Dec°, lat° → altitude° | `sin a = sin δ sin φ + cos δ cos φ cos H` | Geometric altitude, no refraction | culmination case | Good |
| CALC-08 | `calculateSunAltitude` | UTC, lat°, lon° → degrees | Low-precision solar coordinates (USNO "Approximate Solar Coordinates") | See SI-009; no direct reference-value test | indirect | Fair |
| CALC-09 | `calculateLunarIllumination` | UTC → 0–1 | Mean synodic month from an epoch | SI-002 (≤ 4.7 pp error on 2025 samples) | 3 coarse | Fair |
| CALC-10 | `calculateNightTimeline` | date (Y/M/D used as local solar date), lat, lon → `Map<String, DateTime?>` | Sun crossings −0.833/−6/−12/−18° on a 5-min scan | SI-009, SI-010; nulls at high latitude; first crossing only. *(TASK 2.3: now a thin wrapper over CALC-22, resolving the date through a `MeanSolarTimeContext`; numerically verified to agree exactly with the pre-2.3 scan for a normal night.)* | solstice comparison | Fair |
| CALC-11 | `calculateVisibilityWindows` | date, lat, lon, target, minAltitude°, sunLimit° (−18) → list of UTC windows | Sun ≤ limit **and** target ≥ minAltitude, 5-min steps | Quantized; no Moon/weather/horizon; J2000 coordinates. *(TASK 2.3: now a thin wrapper over CALC-23; can report `clippedAtStart`/`clippedAtEnd` in polar night, verified.)* | 4 | Fair |
| CALC-12 | `OpticalCalculator.calculatePixelScale` | pitch µm, EFL mm → arcsec/px | `206.265·p/f` | Returns 0.0 if EFL ≤ 0 | 1 | Good |
| CALC-13 | `calculateFOV` | sensor dimension mm, EFL mm → degrees | `2·atan(d / 2f)` | Returns 0.0 if EFL ≤ 0; **not surfaced in UI** | 1 | Good |
| CALC-14 | `calculateEffectiveFocalLength` | native FL mm → mm | Identity (no reducer/Barlow) | Optical multipliers removed in the latest commit | 1 | Fair |
| CALC-15 | `calculateRelativeStackingGain` | light frames N → factor | `√N` | SI-003 | 1 | Good (UI label deviates) |
| CALC-16 | `estimateStorageRequirement` | avg file MB?, frames → MB | product | SI-008, SI-013 | 1 | Fair |
| CALC-17 | `calculateNPFExposure` | N, p µm, f mm, δ° → s | Deviates from published (SI-001) | Clamps abs(δ) to 89.9°; throws for f ≤ 0 or N ≤ 0; **not surfaced** | 1 (circular) | Fair |
| CALC-18 | `SessionCalculator.calculateFeasibility` | windows, required duration → state + totals | Sum of windows; infeasible if required > available; tight if > 85 % | Arbitrary margin (SI-006); no Moon/weather | 5 | Fair |
| CALC-19 | `SessionCalculator.estimateTotalDuration` | frame counts, exposure s → Duration | 15 % overhead on lights; flats 5 s; bias 1 s | **Dead code** — nothing calls it | 1 | Good (but unused) |
| CALC-21 *(TASK 2.2)* | `SessionNightResolver.forEveningDate` / `resolveDefault` | civil `CalendarDate` or UTC instant, lat°, lon° (east +), `SiteTimeContext` → `SessionNight` | start = mean solar noon `D 12:00Z − round(λ·240 000) ms` nearest civil noon of D; end = start + 24 h; default = window containing now (ADR-007) | Mean, not apparent, noon (ADR-007 L2); mean-solar context until TASK 7.1 (L1); no Sun model involved | ADR-007 matrix (T1–T16), P1–P3, input validation | Good — consumed by `PlannerViewModel.sessionNight` (TASK 2.4) |
| CALC-20 | `PlannerViewModel` derived getters | plan + site → various | `estimatedRequiredTime` = Σ(exposure×count over **all** block types) + 5 s × frames; `totalIntegrationTime` = Σ lights only; `maxAltitude` = altitude at LHA = 0 | Not restricted to the night; conflates integration, acquisition and calibration (TD-022) | **none** | Poor |
| CALC-22 *(TASK 2.3)* | `VisibilityCalculator.calculateNightTimelineForNight` | `SessionNight` → `NightTimeline` | Same Sun-crossing scan as CALC-10, on `[night.startUtc, night.endUtc]` at the shared 5-min step; typed per threshold (`SunCrossing`/`SunNeverBelow`/`SunAlwaysBelow`), never a bare null (SI-008) | Same as CALC-10 (SI-009); first crossing only per threshold | ADR-007 T13–T15 (polar cases), exact agreement with CALC-10 for a normal night | Good — consumed by `sky_darkness_widget.dart` via `PlannerViewModel.nightTimeline` (TASK 2.4) |
| CALC-23 *(TASK 2.3)* | `VisibilityCalculator.calculateVisibilityWindowsForNight` | `SessionNight`, target, minAltitude°, darknessLimitDeg° (−18) → list of `VisibilityWindow` | Same rule as CALC-11 (Sun ≤ limit and target ≥ minAltitude), sampled via CALC-24; a window touching the `SessionNight` boundary in polar night is flagged `clippedAtStart`/`clippedAtEnd` (ADR-007 §9) | Same as CALC-11 | polar clip case (Tromsø circumpolar target), exact agreement with CALC-11 for a normal night | Good — consumed by `PlannerViewModel.visibilityWindows` (TASK 2.4) |
| CALC-24 *(TASK 2.3)* | `VisibilityCalculator.calculateAltitudeCurve` | `SessionNight`, target → `AltitudeCurve` (289 samples) | Sun and target altitude (CALC-07, CALC-08) on the shared 5-min grid, `night.startUtc` to `night.endUtc` inclusive | Same simplifications as CALC-07/CALC-08 (no refraction, low-precision Sun) | grid spacing/count, agreement with CALC-22's crossing instant | Good — consumed by `AltitudeChartWidget`, the only current caller |

---

# Part C — Working rules for future scientific changes

1. Every new or changed calculation is documented in Part B *in the same change*
   (purpose, inputs and units, formula and reference, assumptions, valid range,
   edge cases, tests).
2. A formula change is never silent: record it in `docs/DECISIONS.md` and update
   the relevant SI entry.
3. Tests must use **independent** reference values (published tables, USNO/JPL
   output, worked examples), never values derived from the implementation.
4. Unknown data stays unknown (SI-008). Defaults are labelled assumptions.
5. Thresholds are named constants with a documented rationale; user-meaningful ones
   are configurable (SI-006).
6. Relative gain is never shown as SNR (SI-003); ISO is never shown as
   sensitivity (SI-004).
7. Time handling: store and compute in UTC; define the site time base explicitly;
   never derive a night from the UTC calendar date (SI-010).
