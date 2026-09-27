# AstroPlan — Scientific Integrity Register

> **S3.V8 (2026-09-27):** SI-014 resolved (no camera-spec copy across pixel counts). No formula changed.

> **Stage 3 sign-off validation (2026-09-27):** SI-014 recorded (a copied pixel pitch can belong to another output mode; S3S-02, TD-071). No formula changed.

> **S3.V4 (2026-09-27):** CALC-39's image dimensions have a sanity bound: a side over 65,535 px is unparseable (S3V-05). No formula changed.

> **S3.9 (2026-09-26):** CALC-40's proposed values are rounded to the editor's precision (TD-068). The formula is unchanged.

> **S3.2 (2026-09-26):** CALC-40 added. It is a new estimate of sensor geometry from the 35 mm
> equivalent (ADR-018 §4), with its assumptions and limits in its row. No existing formula changed.

> **S3.1 (2026-09-26):** CALC-39 gains the image-dimension conversion (ADR-018 §3). It is a copy of
> stored pixel counts, not a calculation. No formula changed.

> **Metadata verification, 2026-09-26 (S2.V1):** CALC-39's formulas and units
> are unchanged. Shared EXIF extraction now refuses unsupported integer counts
> and malformed sensitivity-kind tags as unparseable; no pointer is presented
> as ISO or focal length. DNG/JPEG regression and external sample tests pass.
> See `refinement/STAGE_2_CORRECTIONS.md`.

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
> resolved — no calculation changed. **TASK 4.4 (2026-09-22, commit
> `514dcc5`):** SI-003's label, SI-005's seed value, and several SI-008 UI
> presentation cases (storage, pixel scale, example plan, RA/Dec sentinel) are
> resolved; SI-006's sky-warning wording is resolved (its thresholds are not).
> No calculation formula changed — only labels, seed data and a null-vs-zero
> return-value fix in `estimateStorageRequirement`. **TASK 5.1 (2026-09-22, docs
> only):** ADR-009 defines the capture-budget semantics. Planned calculations
> CALC-25 (budget) and CALC-26 (fit) were registered; CALC-18, CALC-19 and CALC-20
> are marked for replacement. No calculation changed.
> **Nothing else in this document has been fixed.** It records issues and the
> required future action for each. See `docs/TECH_DEBT.md` for the work items.
> **TASK 5.2 (2026-09-22):** SI-006 progress (thresholds are preferences); CALC-18 takes a configurable margin (default unchanged). No formula changed.
> **TASK 5.3 (2026-09-22):** SI-004 progress (typed, descriptive-only gain). No calculation changed.
> **TASK 5.4 (2026-09-22):** CALC-25 implemented and verified against ADR-009 E1–E7; CALC-19 deleted; CALC-20 budget part replaced; SI-013 progress. The budget semantics are ADR-009, not a silent formula change.
> **TASK 5.5 (2026-09-22):** CALC-26 implemented; CALC-18 deleted. The E1b vector erratum is recorded in ADR-009 §8.
> **TASK 5.6 (2026-09-22):** SI-003 and SI-004 progress (per-group √N with help text; descriptive-only gain in the editor). No calculation changed.
> **TASK 6.1 (2026-09-22, docs only):** ADR-010 decision notes on SI-002, SI-009 and SI-012. No calculation changed.
> **TASK 6.2 (2026-09-22):** CALC-07/CALC-08 now reference-tested; new CALC-27 (precession) — a recorded formula change (ADR-010, TASK 6.2 decisions); SI-009 and SI-012 progress.
> **TASK 6.3 (2026-09-22):** new CALC-28 (Moon, ADR-010) with reference results; SI-002 progress. No existing calculation changed.
> **TASK 6.4 (2026-09-22):** CALC-09 deleted, new CALC-29 (MoonConditions and separation, reference-tested); SI-002 resolved for precision and geometry.
> **TASK 6.5 (2026-09-22):** CALC-17 corrected to the primary source (recorded formula change); SI-001 resolved for the formula (still hidden).
> **TASK 7.1 (2026-09-23):** SI-007 and SI-010 progress (unknown Bortle; IANA site zone). No calculation formula changed.
> **TASK 7.3 (2026-09-23):** SI-010 progress: a site's IANA zone is set in the editor (device zone pre-filled, "Unknown" allowed, then mean solar time). The zone data set is now `latest_all` (includes link ids; canonical zones' rules unchanged). No formula changed.
> **TASK 7.4 (2026-09-23):** SI-007 resolved: no scraper, no default; Bortle/SQM are user-entered with source and date, or unknown; no Bortle↔SQM conversion (none is sourced); the sky warning uses a known Bortle class only.
> **TASK 8.1 (2026-09-23):** SI-012 largely resolved: epoch stored (J2000 only), source stored, moving types hidden/labelled, RA/Dec entered in sexagesimal or hours through pure, tested parsers (CALC-30). No formula changed.
> **TASK 8.2 (2026-09-23):** SI-012 progress: the seeded targets are now sourced (OpenNGC v20260501, per-object original text kept in the asset; every object's degrees re-derived from its text in tests; 7 independent spot checks within 0.02°) and carry size and magnitude. No formula changed.
> **TASK 8.3 (2026-09-23, documentation only):** SI-005 decided by ADR-011 (implemented in TASK 8.4): required focal ratio N plus optional diameter D in mm, N = f/D, 1 % agreement; existing values never reinterpreted, N > 32 flagged for review.
> **TASK 8.4 (2026-09-23):** SI-005 resolved (ADR-011 implemented: unit-explicit names, focal ratio N plus optional diameter D with N = f / D and 1 % agreement, bounds, review flag for N > 32; no stored value changed).
> **TASK 8.5 (2026-09-23):** SI-011 resolved for shipped seeds: one seed, camera specs verified against ZWO's page, optics labelled estimated, provenance stored per row; unverified phone seeds dropped (existing rows untouched, provenance unknown).
> **TASK 8.6 (2026-09-23):** SI-001 fully resolved (NPF surfaced per PD-11, at the field-minimum |δ|); new CALC-31 (capability summary). No existing formula changed; the NPF call now receives the field-minimum declination instead of the target's centre (a decided input change, DECISIONS PD-11).
> **TASK 9.1 (2026-09-23, documentation only):** ADR-012 decides the weather part of SI-010 (UTC timestamps sliced to the chosen night) and the variable semantics (visibility is horizontal visibility, not transparency; gusts are a preceding-hour maximum; missing values unknown). Implementation: TASKs 9.2–9.4.
> **TASK 9.2 (2026-09-23):** SI-010 (weather part) progress: forecast instants are now parsed as UTC from GMT+0 epoch seconds in the new snapshot path; the display still uses the legacy path until TASK 9.4.
> **TASK 9.3 (2026-09-23):** no calculation changed; forecast age is computed from UTC instants with the injected Clock (freshness thresholds documented as assumptions, ADR-012 §6).
> **TASK 9.4 (2026-09-23, commit `48d7a8c`):** CALC-32 registered (night weather summary and dew-spread heuristic). SI-010 weather part resolved (UTC hours sliced to the night, shown in the site zone). SI-006: the cloud colour bands are removed and the weather horizon is the night within 16 days; the dew margin is now shown in use.
> **TASK 10.1 (2026-09-23, documentation only):** ADR-013 decides the opportunity semantics: the sky-warning thresholds of SI-006 (Moon > 0.8 or Bortle ≥ 7) are to be replaced by annotations (TASK 10.2); optional Moon/cloud gates have user thresholds (assumptions, default 50 %); the culmination-based max altitude (TD-023 part) is replaced by the maximum inside the windows. No formula changed.
> **TASK 10.2 (2026-09-23, commit `613b32f`):** CALC-33 registered (imaging opportunity). Windows are identical to CALC-23 while the optional gates are off (tested); max altitude inside the windows is now computed (CALC-20's culmination value remains in the UI until TASK 10.3). No existing formula changed.
> **TASK 10.3 (2026-09-23, commit `e732a0e`):** SI-006's sky warning is removed (its thresholds with it); CALC-20's culmination-based `maxAltitude` is removed — the UI shows CALC-33's max altitude inside the windows. CALC-33 is now shown. No formula changed.
> **TASK 10.4 (2026-09-23, commit `6bb596f`):** CALC-34 registered (batch candidates). It reuses CALC-33 per target with shared Sun and Moon samples; results equal the single-target view exactly (tested). No formula changed.
> **TASK 13.2 (2026-09-24, commit `14467e7`):** execution state machine and persistence (ADR-016). A pure `ExecutionMachine` (domain) validates every transition per phase (not started, running on a block, paused, finished, abandoned), folds a run's events into its state, measures running time from UTC timestamps, stamps an event taken with a clock behind the last one at that event and flags it, estimates frames (CALC-35) and detects a run past its night. Schema v17 adds the append-only `session_events` table. `SessionRepository.start` records the start on the first light block and refuses a second session in progress; `record` stores an event and its counter projection in one transaction; `complete`/`abandon` close the run with an event. A resume prompt at start (Tonight) offers keep going, pause now, finish or abandon (confirmed), flags a finished night and a clock that went back, and changes nothing without an answer. No tracking screen yet (TASK 13.3). TD-055 recorded.
> **TASK 13.3 (2026-09-24, commit `c8e2240`):** the tracking screen (`/session/:id/run`, ADR-016). The current block with confirmed and estimated counts; +1, −1, Reject, Accept estimate, Pause (plain or with a reason: clouds, wind, dew, equipment, other) / Resume, a block switcher and Finish / Abandon (confirmed) — all in the lower half, 56 dp, labelled for screen readers; countdowns to astronomical dawn, the target below its limit and moonrise; remaining window vs remaining plan (CALC-36). The tracker reads its night, target and Moon from the execution-start snapshot (`ExecutionOutlook`, pure), never from the planner. Owner decisions: Start is in the planner and on Tonight, with the same requirements as Save; after Start the planner goes on with a draft copy, and on a restart it resumes a copy when the most recent open session is running (TD-055 resolved). Tonight shows the run in progress; the resume prompt's Keep going opens the tracker. Opt-in keep-screen-on (off by default, persisted as `keepScreenOnWhileTracking`, only while the tracker is visible and a run is active) behind a `ScreenWake` interface, implemented with `wakelock_plus` 1.8.0 (BSD-3-Clause, verified on pub.dev; a screen wakelock only, no Android permission).
> **TASK 13.4 (2026-09-24, commit `c1e52ce`):** end-of-session reconciliation. A results page (`/session/:id/results`) with per-block confirmed and rejected steppers (each change a stored event), notes, optional conditions (temperature, humidity, cloud cover — empty means unknown, range-checked) and planned vs actual light integration (`SessionReconciliation`, CALC-37); Complete or Abandon. Owner decisions: the tracker's Finish opens this page and completes nothing by itself; after completion the counts may be corrected, each correction a timestamped confirm/reject event after `finished` (the only events allowed then; ADR-016 §11); Sessions shows planned vs actual integration and "Edit results" for completed sessions. `complete()` and every correction write the actual/rejected light-frame totals in the same transaction. No schema change (the condition columns existed). **Group G13 is complete.**
> **TASK 14.2 (2026-09-24, commit `4274175`):** integration so far per target (owner: build it, although it was a roadmap cut line). `TargetProgress` (pure, CALC-38) sums confirmed light frames × exposure of completed, non-legacy sessions with a target, per filter, with the last imaged night and the session count; Library → Progress (`/library/progress`) lists every target, newest first, and a session's detail shows "This target so far". No project goals (out of scope); no schema change.
> **S1.3 (2026-09-25, Stage 1, commit `2007dc5`):** audit SCI-01 (= ENG-01, RT-01) resolved: the forecast's age class is recomputed against the clock through `WeatherFreshness` (thresholds unchanged: aging after 3 h, stale after 12 h, ADR-012 §6), and a snapshot records the age at the time of saving. No calculation changed.
> **S1.13 (2026-09-25, Stage 1, commit `f179013`):** labels and documentation, no calculation changed. SCI-02: CALC-32 corrected (precipitation probability covers the preceding hour) and the weather card says so. SCI-03: CALC-28/CALC-29 state that the displayed rise/set (h₀) and the "Moon up" of windows and the Moon gate (topocentric > 0°) differ by 5–10 min; no displayed text claims they coincide, so no UI change. SCI-09: night-level illumination is labelled "at midnight" (Tonight, the sky card, window annotations). SCI-04 (RD-03): the grid bias is accepted as documented (SI-009, CALC-08). TASK 6.2 citation gap: the tests of CALC-01 to CALC-06 cite their sources, and CALC-03 has a direct test.
> **S1.9 (2026-09-25, Stage 1, commit `705b764`):** CALC-26 (fit) gains the state `needsInput` for a plan with no site or target (the same empty-window path as `noWindow`, flagged by the caller); no placement or margin arithmetic changed.
> **S1.8 (2026-09-25, Stage 1, commit `b03dda9`):** audit SCI-05 resolved (the ISO/gain label, RD-03; SI-004 progress) and SCI-06 resolved (Tonight's candidates word the CALC-31 frame fill as "% of the frame's short side", like the planner, through `CapabilityText.frameFillOf`). No calculation changed.
> **S1.4 (2026-09-25, Stage 1, commit `db2702f`):** audit SCI-11 (= ENG-05, RT-06) resolved: without a site the draft's night key comes from `SessionNightResolver` at the default position, not the UTC date (CALC-21 unchanged; owner decision in DECISIONS E.1).

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
| SI-001 | NPF exposure formula deviates from the published formula | **Resolved** (formula TASK 6.5; surfaced per PD-11 in TASK 8.6) | TD-007 (resolved) |
| SI-002 | Moon: mean-phase precision limit, no Moon geometry | **Resolved 2026-09-22 (TASK 6.3–6.4)** for precision and geometry; the sky warning's use of it stays with SI-006 / G10 | TD-032 (resolved), TD-033 |
| SI-003 | Relative stacking gain (√N) vs physical SNR | **Resolved** (label TASK 4.4; per-group √N with its assumptions in the help text, TASK 5.6; index corrected S1.15); the principle stays in force (Part C) | TD-009 |
| SI-004 | ISO / gain limitations | Prototype (descriptive text only) | TD-009 |
| SI-005 | Aperture semantics and unit problem | Partial (seed value fixed TASK 4.4; field-naming/unit model still open) | TD-008 |
| SI-006 | Hard-coded astronomy and planning thresholds | Partial (sky warning removed TASK 10.3; planning thresholds are preferences since TASK 5.2; the conventional twilight altitudes remain fixed definitions) | TD-033, TD-043 |
| SI-007 | Bortle default vs unknown | **Resolved** (TASK 7.4) | TD-006 |
| SI-008 | Unknown treated as zero / default presented as fact | **Largely resolved** (TASK 4.4 cases; the default position became a "no site" state, TASK 7.3; Bortle is never defaulted, TASK 7.4; corrected S1.15). Open: elevation cannot be recorded as unknown (SCI-08, RG-08) | TD-013 |
| SI-009 | Astronomical model simplifications | **Resolved** (documented on each function and reference-tested, TASK 6.2; the grid bias accepted as documented, S1.13; corrected S1.15) | TD-036 (resolved) |
| SI-010 | "Night" definition and date/time-zone semantics | Resolved (default path; TASK 2.4; weather part TASK 9.4) — site-zone display still open | TD-020 |
| SI-011 | Seed equipment data provenance and internal consistency | **Resolved** for shipped seeds (TASK 8.5) | TD-008 |
| SI-012 | Target coordinates, epoch and object types | **Largely resolved** (TASK 8.1) | TD-016 |
| SI-013 | Storage estimate assumptions | Partial | TD-013 |
| SI-014 | Camera specs copied into another output mode (equipment import) | **Resolved 2026-09-27 (S3.V8)** | TD-071 (resolved) |

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
**Resolved 2026-09-22 (TASK 6.5):** actions 1–4 are done. (1) The primary source was read on sahavre.fr (the older URL is dead), and its derivation gives the unrounded constants 16.8567, 0.099724 and 13.713. (2) The formula is corrected, with the citation in the doc comment and a formula-change record in `docs/DECISIONS.md` E.1. (3) The circular test is replaced by five independent worked examples; the source has no numeric examples in its text. (4) k is explicit (default 1, range 1–3). Action 5 stands: NPF stays hidden until PD-11 decides how to surface it as a recommendation for untracked exposures.

**Status:** **Resolved** *(corrected S1.15, 2026-09-25: the formula follows Michaud since TASK 6.5 and NPF is shown per PD-11 since TASK 8.6; was "Broken (unsurfaced)")*. **Work item:** TD-007 (resolved).

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

**Decision 2026-09-22 (TASK 6.1):** ADR-010 decides the Moon model: in-house Meeus ch. 47 (full tables), ch. 48 illumination, ch. 40 parallax, with cited constants and a documented ΔT; the acceptance tolerances (illumination ≤ 1 pp, position ≤ 0.02°, rise/set on the grid [−2, +7] min) are in ADR-010 §4. The mean-phase model is retired in TASK 6.4. Not implemented.

**Progress 2026-09-22 (TASK 6.3):** the ADR-010 Moon model exists in the domain (CALC-28) and meets every ADR-010 §4 tolerance with wide margins (illumination 0.008 pp vs the mean-phase model's 4.7 pp). The app still shows the mean-phase value until TASK 6.4 switches it and deletes the old model.

**Resolved 2026-09-22 (TASK 6.4):** the app now shows the ADR-010 Moon (illumination 0.008 pp against Horizons; when the Moon is up; its closest approach to the target while both are up), and the mean-phase model is deleted. The illumination is still one value per night, at mean solar midnight (documented), and the sky warning still uses the fixed > 0.8 threshold (SI-006).

**Status:** **Resolved** *(corrected S1.15, 2026-09-25: Meeus-based Moon since TASK 6.3–6.4, TD-032 resolved; the sky warning removed in TASK 10.3, TD-033 resolved; was "Partial")*. **Work items:** TD-032, TD-033 (both resolved).

---

## SI-003 — Relative stacking gain (√N) vs physical SNR

**Scientific Issue**
The UI labels a √N statistic "Relative SNR", and the statistic depends only on
frame count, so it cannot compare plans with different sub-exposure lengths.

**Current Behavior**
- `OpticalCalculator.calculateRelativeStackingGain(N) = √N`, computed from the
  **light-frame count only** (`optical_calculator.dart:44-47`;
  `planner_viewmodel.dart:502-504`).
- **RESOLVED 2026-09-22 (TASK 4.4, commit `514dcc5`), label only.** *(Was: the
  UI label was `Stacking Gain (Relative SNR)`, value shown as e.g. `10.0x`
  (`lib/presentation/widgets/capture_plan_widget.dart:215`); it conflicted with
  CLAUDE.md rule 18, ADR-005 and `PRODUCT_SPEC.md`, having been deliberately
  restored in commit `1baa514` ("restore SNR").)* The label is now "Relative
  stacking gain (√N vs one frame)"; the string "SNR" no longer appears in
  `lib/`.
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
1. ~~Rename the UI label to "Relative stacking gain (√N vs one frame)".~~ Done
   (TASK 4.4).
2. Document the assumptions in the doc comment and in a UI help text (still
   open — the doc comment is brief; no UI help text exists).
3. Make total integration time the primary comparison figure; do not compare gain
   across different sub-exposure lengths.
4. Do not introduce a physical SNR model without an approved ADR and per-camera
   gain/read-noise data.

**Progress 2026-09-22 (TASK 5.6):** √N is now shown per group of light frames with the same filter and exposure (never pooled across groups), with help text stating that it compares random noise with one frame of the same group, is not a signal-to-noise ratio of the image, and ignores sky brightness, the target and the camera (ADR-009 §7).

**Status:** **Resolved** *(corrected S1.15, 2026-09-25: the assumptions are documented in the help text since TASK 5.6. Was: Partial, metric acceptable; label now correct as of TASK 4.4, assumption
documentation still open.)* **Work item:** TD-009 (resolved for the label).

---

## SI-004 — ISO / gain limitations

> **S2.2 (2026-09-26):** the new metadata contract keeps a sensitivity value with its kind (`SensitivityKind`; CALC-39). Gain kinds are added only with FITS (S2.6), as separate kinds, and ISO and gain are never converted into each other. The prototype `MetadataExtractor` (below) read them as strings; S2.5 (2026-09-26) removed it.

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

**Progress 2026-09-22 (TASK 5.3):** action 4 done in the model — `CaptureGain`
(kind iso / gain / unknown + value), documented as descriptive only and used by no
calculation. Legacy free text was migrated as kind "unknown" (never guessed as ISO
or gain). Not yet editable or shown in the UI (TASK 5.6).

**Progress 2026-09-22 (TASK 5.6):** the sensitivity setting is editable as ISO / camera gain / not recorded, labelled "for your records" with the helper "Recorded only; it does not change the plan." No text claims ISO or gain collects more light.

**Progress 2026-09-25 (S1.8; audit SCI-05, owner ruling RD-03):** the field is labelled "ISO / gain (for your records)"; the word "sensitivity" no longer appears for ISO or gain in the UI (Part C rule 6). Still descriptive only; RG-11 (Stage 7) may rework capture parameters.

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
- **RESOLVED 2026-09-22 (TASK 4.4, commit `514dcc5`), seed only.** *(Was: the
  seeded record "ZWO ASI2600MC + 400mm (Telescope Stub)" stored
  `aperture: 72.0` (`lib/data/services/equipment_seeder.dart:82`), which is a
  72 mm *diameter* (400/72 ≈ f/5.6), displayed as `f/72.0`. With N = 72 the NPF
  function returned 3.39 s, versus ≈ 0.46 s from the published formula with
  N ≈ 5.56.)* The seed now stores `aperture: 400.0 / 72.0` (f/5.56, displayed
  as f/5.6).
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
3. ~~Correct the seed record.~~ Done (TASK 4.4).
4. Decide a migration policy for user-entered rows — they cannot be auto-classified
   without guessing, and silent guessing is prohibited (owner decision PD-10).
5. Add tests.

**Decision 2026-09-23 (ADR-011, TASK 8.3):** actions 1, 2 and 4 are decided — `focalRatio` (required, the existing column read as N) plus optional `apertureDiameterMm` with N = focalLengthMm / D (1 % agreement when both are entered; N re-derived when D is stored); unit-explicit names; plausibility bounds (N 0.5–32); existing rows kept exactly, N > 32 flagged for the user. Implementation and tests: TASK 8.4.

**Resolved 2026-09-23 (TASK 8.4):** implemented as decided. `EquipmentProfile.focalRatio` (column `optical_rigs.aperture`) and optional `apertureDiameterMm` (new column); `resolveAperture` derives N = f / D and rejects a disagreement above 1 %; `EquipmentLimits.focalRatio` = f/0.5–f/32; a stored value above f/32 is shown for review and never converted (a migration test keeps a legacy f/72 as 72 and flagged). The telescope seed stores its 72 mm diameter.

**Status:** Resolved. **Work item:** TD-008 (naming part resolved; seeds → TASK 8.5).

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
| Minimum usable target altitude | default 20°, clamp [5°, 60°] | `planner_viewmodel.dart:55,156-161` | In ViewModel and persisted (`minAltitude`), **no UI control calls it** | Planning preference (airmass, obstructions, site). **RESOLVED 2026-09-22 (TASK 4.4, commit `514dcc5`):** the doc comment no longer claims a specific "≥ 1 mag attenuation" figure (unsourced, site/band dependent); it now states the qualitative rationale only |
| "Astronomical darkness" Sun limit | −18° | `visibility_calculator.dart:145` (default parameter) | No | Conventional twilight definition; whether −12° suffices is a user/filter choice (a unit test exercises −12° but no UI exists) |
| Sunset / civil / nautical / astronomical Sun altitudes | −0.833°, −6°, −12°, −18° | `visibility_calculator.dart:109-118` | No | Conventional definitions; acceptable as definitions, but undocumented in code |
| Sky warning | Moon illumination > 0.8 **or** Bortle ≥ 7 | `planner_viewmodel.dart:435` | No | Heuristic; ignores Moon altitude, target, filters. **RESOLVED 2026-09-22 (TASK 4.4, commit `514dcc5`), wording only:** the warning text no longer asserts an outcome ("will wash out"); it now describes reduced contrast. The thresholds themselves are still hard-coded (unchanged). **RESOLVED 2026-09-23 (TASK 10.3, ADR-013 §6):** the warning is removed; per-window Moon facts and sky darkness replace it |
| Feasibility "tight" margin | required > 85 % of available | `session_calculator.dart:68` | No | Arbitrary safety margin |
| Per-frame overhead | 5.0 s flat (live path) | `planner_viewmodel.dart:482` | No | Unsourced; real overhead includes download, dither/settle, autofocus, filter change, meridian flip |
| Dead overhead model | 15 % of light time; flats 5 s; bias 1 s | `session_calculator.dart:30-48` | No | Unused by the app (see TD-022) |
| Dew-point margin | default 2.0 °C | `planner_viewmodel.dart:42` | In ViewModel and persisted (`dewPointThreshold`), no UI; result not shown anywhere | Dew risk depends on optics surface temperature, wind and heaters, not ambient − dew point alone. *(Editable in Settings since TASK 5.2; **shown since TASK 9.4** per hour and per night, labelled a heuristic — CALC-32.)* |
| Cloud-cover colour bands | ≤ 20 green, ≤ 50 orange, else red | `weather_forecast_widget.dart:150-154` | No | Display heuristic only; not used in any calculation. **RESOLVED 2026-09-23 (TASK 9.4, owner decision):** removed; values are shown neutrally |
| Weather horizon | first 48 hourly entries | `open_meteo_weather_repository.dart:44` | No | Data-window choice. **RESOLVED 2026-09-23 (TASKs 9.2–9.4):** the chosen night, sunset to sunrise, within the provider's 16-day horizon (ADR-012) |
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

**Progress 2026-09-22 (TASK 5.2):** minimum altitude, the darkness Sun limit
(−18/−15/−12°), the feasibility margin, the dew margin, the per-frame overhead and
the optional overheads are named, documented, clamped preferences
(`PlanningPreferences`) with a Settings screen whose text calls them preferences,
not laws (actions 1–2 for these values). Defaults are unchanged (20°, −18°, 15 %,
2 °C, 5 s), so no result shifted. Still hard-coded: the sky-warning thresholds
(Moon > 0.8, Bortle ≥ 7).

**Status:** Partial. **Work items:** TD-033 (open), TD-043 (resolved TASK 5.2).

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

**Progress 2026-09-23 (TASK 7.1):** Bortle is nullable end to end (schema v12, domain, ViewModel, the hidden badge offers "unknown"); the default 4 was cleared from stored rows with a note (owner decision); an unknown Bortle no longer counts toward the sky warning. The scraper itself remains until TASK 7.4.

**Resolved 2026-09-23 (TASK 7.4, PD-05):** all four required actions are done. (1) Unknown is represented end to end and shown as "Sky darkness unknown" (`SkyDarkness`). (2) Each value carries its source and date (`user` + the edit date; unchanged values keep theirs; `legacy` rows from 7.1 keep theirs). (3) PD-05 decided: manual Bortle/SQM now, an offline dataset later (deferred, with its licence, size and radiance→SQM uncertainty to be evaluated first). (4) The scraper is deleted. Bortle and SQM are kept as separate scales with no conversion, because none is sourced for this app; an SQM reading alone therefore never triggers the sky warning, whose Bortle ≥ 7 threshold is itself unsourced and stays as it was until G10 (SI-006). `SessionLog.bortleScale` is still not populated at save (G11).

**Status:** Resolved. **Work item:** TD-006 (resolved).

---

## SI-008 — Unknown treated as zero / default presented as fact

**Scientific Issue**
Absence of data is repeatedly displayed as a real value. This is a cross-cutting
integrity problem.

**Current Behavior**
| Situation | What the user sees |
| --- | --- |
| `averageRawFileSizeMB` is null (all 5 seeded profiles) | **RESOLVED 2026-09-22 (TASK 4.4, commit `514dcc5`).** *(Was: `Estimated Storage 0.0 MB` — `estimateStorageRequirement` did `(x ?? 0.0) * n`, so the `N/A` branch was unreachable.)* `estimateStorageRequirement` now returns `null` when the average size is unknown, and the capture-plan widget renders "Unknown" |
| Bortle never set | Bortle 4 used silently (SI-007) |
| GPS unavailable/denied on first launch | London coordinates used silently |
| Equipment `pixelScale` null | **RESOLVED 2026-09-22 (TASK 4.4, commit `514dcc5`).** *(Was: text `null arcsec/px`, `home_screen.dart:104`.)* Home now renders "Unknown" |
| Invalid capture-block input | **RESOLVED 2026-09-22 (TASK 4.1, commit `f5b29cc`).** *(Was: silently became 60 s × 30 frames.)* Now rejected by `Form` validators (exposure > 0, frame count ≥ 1) instead of defaulted |
| Fresh install | **RESOLVED 2026-09-22 (TASK 4.4, commit `514dcc5`).** *(Was: a default plan of 100×60 s lights, 20×60 s darks, 20×2 s flats shown with no distinction from a user's own plan.)* The Sequence Plan header now carries an "Example plan" badge until the user adds, edits, removes or reorders a block, or loads a saved session |
| Target with RA/Dec at exactly (0, 0) | **RESOLVED 2026-09-22 (TASK 4.4, commit `514dcc5`).** *(Was: `PlannerViewModel.currentAltitude`/`maxAltitude` treated `(0, 0)` as an "unset" sentinel and returned null even for a target genuinely at that coordinate; the target edit dialog used the same check to decide whether to pre-fill RA/Dec.)* RA/Dec are required fields with no real "unset" state, so the sentinel was removed from both call sites |

**Correct Interpretation**
Missing data is *unknown*; defaults are *assumptions*. Neither may masquerade as a
measurement or user input.

**Required Future Action**
Adopt and enforce the rule "no domain default may masquerade as a measurement":
nullable values with explicit UI states, and labelled assumptions. Record it as a
decision in `docs/DECISIONS.md` when approved.

**Status:** **Largely resolved** *(corrected S1.15, 2026-09-25: the default position became a "no site" state in TASK 7.3 and Bortle is never defaulted since TASK 7.4, SI-007; open: elevation cannot be recorded as unknown, SCI-08, RG-08. Was: Partial, Bortle default and GPS-default-location cases remain open.)* **Work item:** TD-013 (resolved; and SI-007).

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

**Decision 2026-09-25 (S1.13; audit SCI-04, RT-08; owner ruling RD-03):** the grid's one-directional bias (crossings 0–5 min late; a window's dawn and target-setting edges can include up to 5 min beyond the limit, measured 10–200 s) is accepted as documented (CALC-08). No UI resolution note and no conservative edge rule; either would be a new scientific decision.

**Decision 2026-09-22 (TASK 6.1):** ADR-010 §4 sets the measurement for the existing Sun formula (TASK 6.2, USNO events, [−2, +7] min on the 5-min grid); replacing it would need a new decision, never a silent change. Not implemented.

**Progress 2026-09-22 (TASK 6.2):** Reference-tested against independent sources (USNO, JPL Horizons, SIMBAD; `test/fixtures/astronomy/`, each with source, query and retrieval date): Sun altitude ≤ 0.0097°, every twilight crossing within the grid tolerance, star altitudes ≤ 0.017°. The simplifications are now documented on each function (UTC ≈ UT1, mean sidereal time, airless altitudes, the −0.833° convention, the 5-minute grid). Precession is now applied (owner decision).

**Status:** **Resolved** *(corrected S1.15, 2026-09-25: documented and reference-tested since TASK 6.2, TD-036 resolved; grid bias accepted, S1.13; was "Implemented (undocumented)")*. **Work item:** TD-036 (resolved).

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

**Progress 2026-09-23 (TASK 7.1):** the active site's IANA zone now drives the night identity (`IanaTimeContext`) and the display, fixing ADR-007 L1 for sites that have a zone; the IANA offsets agree hourly with the IANA-derived test fakes over 2026–2027.

**Progress 2026-09-23 (TASK 9.4, commit `48d7a8c`):** the weather part is resolved — forecast hours are UTC instants (TASK 9.2), sliced to the chosen night (sunset to sunrise) and shown in the site zone with a caption; the legacy naive-time weather path is removed.

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

**Resolved 2026-09-23 (TASK 8.5), limited to what ships:**
- One seed ships: "ZWO ASI2600MC + example 72 mm f/5.6 refractor". Camera specs **verified** against ZWO's product page (https://www.zwoastro.com/product/asi2600mc-duo/, "ASI2600MC Pro" column: Sony IMX571, APS-C 23.5 × 15.7 mm, 6248 × 4176 px, 3.76 µm; checked 2026-09-23); resolution × pitch = 23.49 × 15.70 mm (within 0.1 %). Optics **estimated**: a generic 400 mm / 72 mm refractor, named as an example.
- The four phone seeds are **dropped** (owner decision). Their makers publish only megapixels, f-number and a 35 mm-equivalent focal length (e.g. Apple: "48MP Main: 24 mm, ƒ/1.78"); real focal length, sensor size and pixel pitch were community figures, and the pitch depends on the RAW mode (48/50 MP native vs binned).
- `manufacturer` ambiguity no longer applies to shipped seeds (ZWO is both brand and camera maker).
- RAW size is left **unknown** rather than estimated (it depends on the capture format).
- Provenance is stored per row (`camera_modules`/`optical_rigs`.`source`, `confidence`; ADR-008 §6). **Limitation:** installs seeded before TASK 8.5 keep their phone rows unchanged with provenance unknown (never back-filled), including the Xiaomi/Vivo 10.5 % sensor-height mismatch; the editor shows "source unknown" for them.
- The "stored size vs resolution × pitch within 2 %" check is a test over every seed.

**Status:** Resolved for shipped seeds; limited for legacy rows (above). **Work item:** TD-008.

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

**Decision 2026-09-22 (TASK 6.1):** ADR-010 §3: the moving types (Planet, Moon, Comet, Asteroid) are hidden for new targets in 1.0 and existing ones are labelled "fixed coordinates — this object moves" (TASK 8.1). ADR-010 §2 also makes the J2000-vs-of-date frame explicit: separation waits for the TASK 6.2 precession decision. Not implemented.

**Progress 2026-09-22 (TASK 6.2):** J2000 target coordinates are now precessed to the date (Meeus ch. 21, owner decision; 0.32° → 0.017° against USNO). Epoch is still not stored per target (TASK 8.1); the moving types are still offered (TASK 8.1).

**Resolved in large part 2026-09-23 (TASK 8.1):** moving types are hidden for new targets and labelled "Fixed coordinates — this object moves; positions are not tracked" when they exist (ADR-010 §3); every target stores its epoch (`J2000`, the only value the calculators support — they precess J2000 to the date, TASK 6.2) and its source (legacy rows: unknown); angular size (arcmin) and magnitude can be stored; RA is entered in hours or h:m:s and Dec in d:m:s, parsed by `AstroMath.parseRightAscension`/`parseDeclination` (CALC-30: RA° = 15 × (h + m/60 + s/3600); Dec° = sign × (d + m/60 + s/3600), the sign applying to the whole value so −0°30′ = −0.5°; a bare RA number is hours, degrees need a `°` suffix). The `(0,0)` sentinel was already removed. **Still open:** no constellation. *(TASK 8.2, 2026-09-23: the seeds are replaced by 164 OpenNGC-sourced objects with size and V magnitude where OpenNGC has them; M40 and M73 have no size.)*

**Status:** Largely resolved. **Work item:** TD-016 (resolved).

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

**Progress 2026-09-22 (TASK 5.4):** storage is computed per block by CALC-25 over every frame taken (library calibration excluded); unknown file size stays unknown (null), never zero. Still an estimate: binning and compression are ignored (ADR-009 L6).

**Status:** Partial. **Work item:** TD-013.

---

## SI-014 — Camera specs copied into another output mode

**Scientific Issue**
A pixel pitch describes one output mode: binning doubles it, and a crop mode changes the sensor
area instead (CALC-40, ADR-018 §4). ADR-018 §6 treats a different pixel count as another capture
mode, never merged silently.

**Current Behavior**
In "same camera, other optics", `EquipmentDraft.fromCandidate(c, cameraFrom:)` takes the file's
pixel dimensions and copies the saved rig's pitch and sensor size where the file gives none. It
does not compare the pixel counts. Probe F3 (`refinement/evidence/STAGE_3_SIGNOFF_PROBES.md`)
saves 2048 × 1536 px with a 4096 × 3072 rig's 2.414 µm pitch, so resolution × pitch is half the
stored sensor width. The pixel scale and NPF then use a pitch 2× too small for the images recorded.

**Correct Interpretation**
A saved rig's pitch and sensor size apply to a file only when the file records the same pixel
count. Otherwise the file cannot say whether the difference is binning or a crop, so the value
is unknown until the user supplies it.

**Required Future Action**
S3.V8 (proposed, owner's choice of rule): do not copy pitch or sensor size when the pixel counts
differ (recommended), or warn and require an explicit confirmation. Record the rule in ADR-018's
notes.

**Resolved 2026-09-27 (S3.V8, owner option (a)):** a saved rig's pixel size and sensor size are not copied into a file with another pixel count (compared orientation-free, `EquipmentMatcher.samePixelCount`). They stay unknown until the user enters the pixel size, and the editor says why. The equal-pixel-count copy and the file's own estimate are unchanged. No formula changed.

**Status:** Resolved. **Work item:** TD-071 (resolved).

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
| CALC-07 | `VisibilityCalculator.calculateLHA`, `calculateAltitude`, `calculateTargetAltitude` *(TASK 6.2)*; ~~`calculateCulminationAltitude`~~ *(removed with its last caller in TASK 10.3; corrected S1.15)* | LST°, RA°, Dec°, lat° → altitude°; targets: J2000 RA/Dec, UTC, lat°, lon° | `sin a = sin δ sin φ + cos δ cos φ cos H` (Meeus eq. 13.6); **targets precessed J2000 → date first (CALC-27)** | Geometric altitude, no refraction (TASK 6.2 policy) | **reference:** 67 USNO computed star altitudes, max error 0.017° (tolerance 0.05°); without precession 0.32° | Good |
| CALC-08 | `calculateSunAltitude` | UTC, lat°, lon° → degrees | Low-precision solar coordinates (USNO "Approximate Solar Coordinates") | Airless; no nutation/aberration; UTC ≈ UT1; on the 5-min grid every crossing is reported at the first sample after it, so 0–5 min late and one-directional (a window's dawn edge can include up to 5 min above the darkness limit; measured 10–200 s, 04/P3) — **accepted as documented** (owner, RD-03, S1.13; SCI-04), no UI note | **reference:** 375 JPL Horizons airless elevations, max error 0.0097° (tolerance 0.02°); timeline crossings within [−2, +7] min of Horizons and USNO (TASK 6.2) | Good |
| CALC-09 | ~~`calculateLunarIllumination`~~ **Deleted 2026-09-22 (TASK 6.4)** | UTC → 0–1 | Mean synodic month from an epoch | Up to 4.7 pp error (SI-002); replaced by CALC-28 (`MoonCalculator.illuminatedFraction`, 0.008 pp) | — | Deprecated (removed) |
| CALC-10 | `calculateNightTimeline` | date (Y/M/D used as local solar date), lat, lon → `Map<String, DateTime?>` | Sun crossings −0.833/−6/−12/−18° on a 5-min scan | SI-009, SI-010; nulls at high latitude; first crossing only. *(TASK 2.3: now a thin wrapper over CALC-22, resolving the date through a `MeanSolarTimeContext`; numerically verified to agree exactly with the pre-2.3 scan for a normal night.)* | solstice comparison | Fair |
| CALC-11 | `calculateVisibilityWindows` | date, lat, lon, target, minAltitude°, sunLimit° (−18) → list of UTC windows | Sun ≤ limit **and** target ≥ minAltitude, 5-min steps | Quantized; no Moon/weather/horizon; J2000 coordinates. *(TASK 2.3: now a thin wrapper over CALC-23; can report `clippedAtStart`/`clippedAtEnd` in polar night, verified.)* | 4 | Fair |
| CALC-12 | `OpticalCalculator.calculatePixelScale` | pitch µm, EFL mm → arcsec/px | `206.265·p/f` | Returns 0.0 if EFL ≤ 0 | 1 | Good |
| CALC-13 | `calculateFOV` | sensor dimension mm, EFL mm → degrees | `2·atan(d / 2f)` | Returns 0.0 if EFL ≤ 0; *(corrected S1.15: surfaced through the rig capability summary, CALC-31, since TASK 8.6)* | 1 | Good |
| CALC-14 | `calculateEffectiveFocalLength` | native FL mm → mm | Identity (no reducer/Barlow) | Optical multipliers removed in the latest commit | 1 | Fair |
| CALC-15 | `calculateRelativeStackingGain` | light frames N → factor | `√N` | SI-003 | 1 | Good (UI label corrected TASK 4.4) |
| CALC-16 | `estimateStorageRequirement` | avg file MB?, frames → MB? | product, or null if avg file size unknown (TASK 4.4) | SI-008, SI-013 | 1 | Fair |
| CALC-17 | `calculateNPFExposure` | N, p µm, f mm, δ° (field minimum \|δ\|, 0 if unknown), k (1–3, default 1) → s | **Since TASK 6.5:** Michaud's complete NPF rule, `k(16.8567N + 0.099724f + 13.713p)/(f cos\|δ\|)`, constants computed from his derivation (sahavre.fr) | Assumes 3″ seeing, 550 nm, Bayer sensor, a moderately aberrated lens; \|δ\| capped at 89.9°; **not surfaced** (PD-11) *(stale: shown per PD-11 through `vm.rigCapability`, CALC-31, since TASK 8.6; corrected S1.15)* | 5 independent worked examples incl. a phone lens (≤ 1e-5 s; within 0.2 % of the published rounding) | Good *(shown since TASK 8.6; was "hidden", corrected S1.15)* |
| CALC-18 | ~~`SessionCalculator.calculateFeasibility`~~ **Deleted 2026-09-22 (TASK 5.5)** | windows, required duration → state + totals | Sum of windows vs required time with a margin | Could not see gaps between windows (ADR-009 E2c); replaced by CALC-26; its tests removed with it | — | Deprecated (removed) |
| CALC-19 | ~~`SessionCalculator.estimateTotalDuration`~~ **Deleted 2026-09-22 (TASK 5.4)** | frame counts, exposure s → Duration | 15 % overhead on lights; flats 5 s; bias 1 s | Was dead code; replaced by CALC-25 (ADR-009); its test was removed with it | — | Deprecated (removed) |
| CALC-21 *(TASK 2.2)* | `SessionNightResolver.forEveningDate` / `resolveDefault` | civil `CalendarDate` or UTC instant, lat°, lon° (east +), `SiteTimeContext` → `SessionNight` | start = mean solar noon `D 12:00Z − round(λ·240 000) ms` nearest civil noon of D; end = start + 24 h; default = window containing now (ADR-007) | Mean, not apparent, noon (ADR-007 L2); mean-solar context until TASK 7.1 (L1); no Sun model involved | ADR-007 matrix (T1–T16), P1–P3, input validation | Good — consumed by `PlannerViewModel.sessionNight` (TASK 2.4) |
| CALC-20 | `PlannerViewModel` derived getters *(budget part replaced by CALC-25 in TASK 5.4)* | plan + site → various | **Since TASK 5.4:** `estimatedRequiredTime` = CALC-25 window load; `totalIntegrationTime`, `estimatedStorageMB`, `relativeStackingGain` read CALC-25's result (no arithmetic in the ViewModel). Unchanged: `maxAltitude` = altitude at LHA = 0 *(removed TASK 10.3: replaced by CALC-33's max altitude inside the windows)* | ~~`maxAltitude` not restricted to the night (TD-023 part)~~ resolved TASK 10.3 | via CALC-25 | Fair |
| CALC-22 *(TASK 2.3)* | `VisibilityCalculator.calculateNightTimelineForNight` | `SessionNight` → `NightTimeline` | Same Sun-crossing scan as CALC-10, on `[night.startUtc, night.endUtc]` at the shared 5-min step; typed per threshold (`SunCrossing`/`SunNeverBelow`/`SunAlwaysBelow`), never a bare null (SI-008) | Same as CALC-10 (SI-009); first crossing only per threshold | ADR-007 T13–T15 (polar cases), exact agreement with CALC-10 for a normal night | Good — consumed by `sky_darkness_widget.dart` via `PlannerViewModel.nightTimeline` (TASK 2.4) |
| CALC-23 *(TASK 2.3)* | `VisibilityCalculator.calculateVisibilityWindowsForNight` | `SessionNight`, target, minAltitude°, darknessLimitDeg° (−18) → list of `VisibilityWindow` | Same rule as CALC-11 (Sun ≤ limit and target ≥ minAltitude), sampled via CALC-24; a window touching the `SessionNight` boundary in polar night is flagged `clippedAtStart`/`clippedAtEnd` (ADR-007 §9) | Same as CALC-11 | polar clip case (Tromsø circumpolar target), exact agreement with CALC-11 for a normal night | Good — consumed by `PlannerViewModel.visibilityWindows` (TASK 2.4) |
| CALC-24 *(TASK 2.3)* | `VisibilityCalculator.calculateAltitudeCurve` | `SessionNight`, target → `AltitudeCurve` (289 samples) | Sun and target altitude (CALC-07, CALC-08) on the shared 5-min grid, `night.startUtc` to `night.endUtc` inclusive | Same simplifications as CALC-07/CALC-08 (no refraction, low-precision Sun) | grid spacing/count, agreement with CALC-22's crossing instant | Good — consumed by `AltitudeChartWidget`, the only current caller |
| CALC-25 *(ADR-009; implemented TASK 5.4)* | `CaptureBudgetCalculator.calculate` (`lib/domain/services/capture_budget_calculator.dart`) | blocks (type, filter, exposure s, count, calibration policy), overhead parameters (per-frame s; optional dither N and s, refocus T and s, filter change s, flip s, setup s), "transit in a window" flag → breakdown | Integration = Σ light exposure; acquisition = integration + per-frame × lights + in-window overhead events (one ordered sequence); window load = acquisition + in-window calibration; session budget = window load + outside-window calibration + setup; integer ms | Overhead defaults are assumptions (per-frame 5 s on; the rest off, shown as "not included"); ADR-009 L1–L6 | ADR-009 E1–E7 (independent scratch model) | Good — E1–E7 reproduced to the millisecond (`capture_budget_calculator_test.dart`) |
| CALC-26 *(ADR-009; implemented TASK 5.5)* | `FitAnalyzer.analyze` / `maxPlaceableFrames` / `noWindowReason` (`lib/domain/services/fit_analyzer.dart`) | the CALC-25 event sequence, `List<VisibilityWindow>`, margin m (default 15 %), transit instant → fits / tight / does not fit / no window / nothing to fit, reason, end instant, unused time, lost tails, unplaced frames per block, flip applied/dropped, similar-nights hint; inverse maximum | Atomic events placed in order; an event that doesn't fit moves to the next window and the tail is lost; the flip is placed at the first boundary at/after transit or dropped if the plan ends first; tight if placed time > (1 − m) × Σ windows; nights = ⌈window load ÷ placed⌉ | One target per night; the margin labels only; transit to 5-min resolution | ADR-009 E1–E7 (E1b per the TASK 5.5 erratum), margin, inverse, no-window reasons | Good |
| CALC-27 *(TASK 6.2)* | `AstronomicalEngine.precessJ2000ToDate` | J2000 RA°, Dec°, JD → RA°, Dec° of date | Meeus ch. 21, eq. 21.2 (IAU 1976 ζ, z, θ) and 21.4 (rigorous) | Mean equinox of date; no nutation, aberration or proper motion (about 20–40″) | identity at J2000.0; precessed Dec within 0.03° of USNO Dec of date for all 67 observations | Good |
| CALC-28 *(TASK 6.3)* | `MoonCalculator.position` / `topocentricAltitude` / `illuminatedFraction` / `phaseLongitudeDeg` / `riseSetForNight` (`lib/domain/services/moon_calculator.dart`, tables in `moon_series.dart`) | UTC (as UT1), lat°, lon°, `SessionNight` | Meeus ch. 47 full ELP-2000/82 tables (+ additive terms), ch. 22 nutation (4 terms) and obliquity, ch. 13 transforms, ch. 40 topocentric parallax, ch. 25 Sun (low accuracy), ch. 48 illumination, ch. 15 rise/set h₀ = 0.7275π − 0.5667°; ΔT = 69.2 s | Airless altitudes; rise/set on the 5-min grid; ΔT constant (±10 s ≈ 6″); the displayed moonrise/moonset use h₀ (upper limb, refraction), while the "Moon up" of CALC-29 and the ADR-013 Moon gate use topocentric airless altitude > 0° of the centre, so windows count the Moon up from about 5 min after the displayed rise to 5–10 min before the displayed set (04/P3; SCI-03, documented S1.13) | **reference (ADR-010 §4):** 32 Horizons instants over 2026–27: RA·cosδ 7.5″, Dec 2.3″, λ 7.4″, β 1.8″ (tolerance 72″); illumination 0.008 pp (≤ 1 pp); topocentric altitude 0.0016° at 3 sites incl. 69.65°N (≤ 0.05°); all 99 USNO phases ≤ 10 min; USNO moonrise/moonset on 15 site-nights matched one-to-one within [−2, +7] min | Good *(used by CALC-29 and the UI since TASK 6.4; corrected S1.15)* |
| CALC-29 *(TASK 6.4)* | `MoonCalculator.conditionsForNight`, `separationFromTarget`, `angularSeparationDeg`; `MoonConditions` | `SessionNight`, optional target (J2000) | On the night's 5-min grid: topocentric Moon altitude (CALC-28); target precessed to date (CALC-27) and its altitude (CALC-07); topocentric separation by the vector form of Meeus ch. 17; closest approach where both altitudes > 0°; illumination at mean solar midnight | Target nutation/aberration ignored (20–40″); 5-min grid; annotations only; "Moon up" is topocentric airless altitude > 0° of the centre, not CALC-28's h₀ rise/set (differs by 5–10 min, SCI-03); the night's illumination is the value at mean solar midnight, labelled "at midnight" in the UI since S1.13 (SCI-09) | **reference:** separation within 0.05° of USNO (45 geocentric Moon–star pairs) and Horizons + USNO (135 topocentric pairs at 3 sites) | Good |
| CALC-30 *(TASK 8.1)* | `AstroMath.parseRightAscension` / `parseDeclination` / `formatRightAscension` / `formatDeclination` | typed text → RA° [0, 360) / Dec° [−90, 90], or null; degrees → display text | RA° = 15·(h + m/60 + s/3600) (a bare number is hours; degrees need a `°`/`deg`/`d` suffix); Dec° = sign·(d + m/60 + s/3600), the sign applying to the whole value | Only the last field may be fractional; minutes/seconds < 60; RA < 24 h; \|Dec\| ≤ 90°; display resolution 0.1 s (RA) and 1″ (Dec), so the editor keeps an untouched field's stored value | `astro_math_coordinates_test.dart` (hand-computed values, round trips) | Good |
| CALC-31 *(TASK 8.6)* | `CapabilityCalculator.evaluate` / `fieldMinimumDeclinationDeg` (`lib/domain/services/capability_calculator.dart`) | rig (mm, µm, N, tracking, max exposure s), optional target (δ°, size ′), k → FOV W/H/diag (°), pixel scale (″/px), NPF (s) with the |δ| used, recommended max sub (s), frame fill (fraction) | FOV = 2·atan(s/2f) (CALC for FOV); scale = 206.265·p/f; NPF per CALC (Michaud, SI-001) at |δ|min = max(0, |δ| − diag/2); recommendation = min(NPF, max exposure) when NPF applies (untracked, or unknown marked "if untracked"), else max exposure; fill = size / (60 · min(FOV W, H)) | Field rotation unknown → diagonal used (conservative); no refraction or atmospheric terms; guidance only | `capability_calculator_test.dart` (independent reference values), `capture_plan_widget_test.dart` (acceptance) | Good |
| CALC-32 *(TASK 9.4)* | `NightWeatherSummarizer.spanOf` / `summarize` (`lib/domain/services/night_weather_summarizer.dart`) | `NightTimeline` (h = −0.833°), `WeatherSnapshot` (UTC hours), dew margin °C → interval, hourly slots, ranges | Interval = sunset..sunrise (window edge when outside the window; whole window for midnight sun / polar night); one slot per whole UTC hour overlapping it, matched to the forecast hour at the same instant (else "no forecast"); range = min/max over covered hours with a value; dew spread = T − Td (°C), risk when spread ≤ margin | The dew rule is a **heuristic**: dew on optics depends on surface temperature, wind and heaters, not ambient T − Td alone; the margin is a user preference (default 2 °C, an assumption); hourly values are instantaneous except gusts (preceding-hour maximum) and precipitation probability (the preceding hour; corrected S1.13, SCI-02 — the UI labels it so) | `night_weather_summarizer_test.dart` (hand-built vectors, boundary spread = margin, a real Ljubljana night, a night 5 days ahead) | Good |
| CALC-33 *(TASK 10.2)* | `ImagingOpportunityCalculator.calculate` / `fromSamples` (`lib/domain/services/imaging_opportunity_calculator.dart`) | `SessionNight`, target (J2000), darkness limit °, minimum altitude °, optional gates (Moon X %, cloud Y %), optional Moon samples (CALC-28/29) and forecast (ADR-012) → windows, excluded segments with reasons, no-window reason, max altitude per window, annotations | Per 5-min grid instant: fail darkness if Sun > limit; altitude if target < minimum; Moon if gate on and Moon altitude > 0° and illumination ≥ X; cloud if gate on and the nearest hour's cloud > Y (hour H covers [H − 30 min, H + 30 min)); a sample's state holds to the next instant; runs with identical failing sets merge | Airless altitudes; night illumination at mean solar midnight; unknown data never excludes; 5-min resolution; no horizon (reserved) | ADR-013 V1–V12 (exact, synthetic), boundary rules, polar night, midnight sun, never-rising and circumpolar-dip targets, agreement with CALC-23 (M42) | Good (shown since TASK 10.3) |
| CALC-34 *(TASK 10.4)* | `CandidateEvaluator.evaluate` / `MoonTrack` / `CandidateList` (`lib/domain/services/candidate_evaluator.dart`) | night, targets, CALC-33 inputs, optional equipment → per target: usable time, window span, max altitude and min Moon separation in windows, frame fill, no-window reason | CALC-33 per target; the Sun (CALC-07) and the Moon's topocentric RA/Dec/altitude (CALC-28) computed once per night; separation per instant = CALC-29's precession + angular distance; frame fill = CALC-31; sorting by one column, unknown values last | Same as CALC-33; sorting only, no weighting | batch = single-target view exactly (gates off/on, weather, equipment); 250 targets < 1 s on the test machine | Good |
| CALC-35 *(TASK 13.2)* | `ExecutionMachine.runningTime` / `estimate` (`lib/domain/services/execution_machine.dart`) | the run's events (UTC ms), now (UTC), exposure s, per-frame overhead s (from the execution-start snapshot), planned frames → running time in the current block; estimated unreported frames, capped | Running time = sum of running intervals since the block was selected (a clock behind an interval's start counts it as zero). Estimate = ⌊running ms ÷ round((exposure + overhead) × 1000)⌋ − frames confirmed or rejected since selection, clamped to [0, planned − confirmed] (ADR-016 §3) | An **upper bound**: dither, refocus, meridian flip, failed or aborted frames and time the camera was not shooting are not known and not subtracted; a clock set forward is indistinguishable from elapsed time (bounded by the cap). Shown as "about N (estimated)" and never stored unless the user accepts it | `execution_machine_test.dart` (formula, reported frames, pauses, cap, clock back, non-positive cycle) | Good |
| CALC-36 *(TASK 13.3)* | `ExecutionOutlook.compute` (`lib/domain/services/execution_outlook.dart`) | now (UTC); the run's blocks and confirmed counts; per-frame overhead s; the snapshot's planned windows (UTC); the night timeline (CALC-22), the target's altitude curve (CALC-24) and minimum altitude °, the Moon's rise/set (CALC-28) → next astronomical dawn, when the target next drops below the limit, next moonrise and whether the Moon is up, remaining window time, remaining plan time | Dawn = the timeline's −18° dawn if still ahead. Target = the first 5-minute sample after now below the limit (or "below now"). Moon = last event at or before now decides up/down; the first rise after now. Remaining window = Σ max(0, end − max(start, now)). Remaining plan = Σ over light and in-window calibration blocks of max(0, planned − confirmed) × (exposure + per-frame overhead) | Dawn is always −18°, not the user's darkness limit (as TD-054). The target and Moon times are on the 5-minute grid (first sample after a crossing). The remaining plan excludes dither, refocus, filter changes and flips — an estimate, labelled so. Unknown inputs give null, never a guessed time | `execution_outlook_test.dart` (dawn, crossing, below now, Moon up/down and next rise, window left, plan left with and without confirmations, nothing guessed) | Good |
| CALC-37 *(TASK 13.4)* | `SessionReconciliation.of` (`lib/domain/services/session_reconciliation.dart`) | the session's blocks (frame type, exposure s, planned frames) and the run's confirmed/rejected counts → per block planned/confirmed/rejected; planned and actual light integration; actual and rejected light-frame totals; actual ÷ planned | Planned integration = Σ over light blocks of planned × exposure; actual = Σ confirmed × exposure; totals = Σ over light blocks. Rejected frames and calibration blocks are not integration | Integration here is exposure time only (no SNR claim, SI-003); counts are what the user confirmed, not verified against files (metadata assistance is G17). Fraction is null when nothing is planned, never a division by zero; more than planned is shown as it is | `session_reconciliation_test.dart`; `drift_session_execution_test.dart` (totals on completion and correction) | Good |
| CALC-38 *(TASK 14.2)* | `TargetProgress.of` (`lib/domain/services/target_progress.dart`) | completed sessions with their run states → per target id: Σ confirmed light frames × exposure, per filter ("No filter" when unset), last imaged night, session count | Sum over completed, non-legacy sessions with a target of CALC-37's actual light integration, keyed by the block's filter name | Exposure time only (no SNR); counts are user-confirmed; legacy logs and sessions without a target are excluded (their targets are not reliable, ADR-014 §7); abandoned sessions are excluded even if frames were confirmed; filter names are matched as typed (trimmed) | `target_progress_test.dart` | Good |
| CALC-39 *(S2.2)* | `ExifValues` (`lib/domain/metadata/exif_values.dart`; in `capture_metadata.dart` until S2.7) | EXIF/TIFF values from a capture file → contract values: exposure (s), f-number, focal length (mm), 35 mm-equivalent (mm, a separate field), sensitivity (value and kind), capture time (local wall-clock, offset only if recorded) | Exposure, f-number and focal length are exact rationals in the units EXIF stores (s, dimensionless, mm), divided once. The 35 mm equivalent is copied as written and never used as a focal length. Sensitivity kind follows EXIF 2.3 SensitivityType: 1 SOS, 2 REI, 3 ISO speed, anything else unspecified. The capture time's offset comes only from OffsetTimeOriginal; no zone is ever inferred (ADR-017 §3) | A zero denominator, 0 or a negative value is unparseable; 35 mm = 0 is absent (EXIF: unknown); sensitivity 0 or 65535 ("65535 or more") is unparseable; a blank or all-zero time is absent; an invalid date, or a time without its seconds, is unparseable; an invalid offset leaves the zone unknown. ISO is never converted to gain (SI-004). **Image dimensions (S3.1, ADR-018 §3):** stored pixel counts copied as a width/height pair. DNG: IFD0's main image only, `DefaultCropSize` if whole, else `ImageWidth`/`ImageLength`. JPEG/HEIC: `PixelX/YDimension` and IFD0, combined. A missing side, a zero or a malformed value is unparseable. **S3.V4 (S3V-05):** so is a side over 65,535 px (`ExifValues.maxImageSidePx`: JPEG's format limit, far beyond any camera sensor). That is a metadata sanity bound, not an equipment limit. Orientation is not interpreted. Applied by the shared `ExifStructure` (S2.7; `TiffMetadataReader` in S2.3), for DNG, JPEG (S2.8) and HEIF (S2.9) | `capture_metadata_test.dart`, `tiff_metadata_reader_test.dart`, the local `real_samples_test.dart` | Yes |
| CALC-40 *(S3.2)* | `SensorGeometryEstimate.of` (`lib/domain/equipment_import/sensor_geometry_estimate.dart`), used by `EquipmentCandidate.fromReading` | focal length f (mm), 35 mm-equivalent f₃₅ (mm), the image's long and short sides (px) → sensor width and height (mm), effective pixel pitch (µm), crop factor | crop = f₃₅ / f; diagonal = 43.27 mm (the 36 × 24 mm frame) / crop; the sides split the diagonal in the long:short pixel ratio; pitch = long side (mm) / long side (px) × 1000. ADR-018 §4 | **An estimate, only ever `estimated`, offered and never applied silently.** Assumes f₃₅ is the diagonal equivalent: EXIF does not say whether it matches the diagonal or the width, which differ by about 4 % for a 4:3 sensor. f₃₅ is a whole number (±0.5 mm, about ±2 % at 23 mm). The pitch is that **of the output mode** (binned or full resolution), which is what the pixel scale needs, not necessarily the sensor's native pitch. No estimate when f₃₅ ≤ f: full-frame and larger bodies get none, and their users type the specs. No estimate when an input is not positive, long < short, or a result is outside `EquipmentLimits` (sensor side 1–100 mm, pitch 0.5–30 µm); never a partial estimate. **S3.9 (TD-068):** the candidate proposes the results rounded to 0.01 mm and 0.001 µm, the precision the editor stores. That is far below the estimate's uncertainty, so a rig saved from a file matches the file exactly; the calculation itself is unrounded | `equipment_candidate_test.dart`: expected values computed independently from the formula (the owner phone's committed RG-01 values, and a round case) | Yes |

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
