# 03 — Scientific correctness and data-integrity audit

> **Audit stage 3.** Captured 2026-09-24 against `main` @ `becae04`. Audit only: no application
> code or source-of-truth document was changed.
>
> **Inputs:**
> - `docs/audit/00_CONTEXT_BASELINE.md` **still does not exist** in the repository. The
>   Stage 0 baseline from this session was used instead, together with
>   `docs/audit/01_ROADMAP_COMPLIANCE.md` and `docs/audit/02_ENGINEERING_AUDIT.md`.
> - The calculation code in `lib/domain` and the user-facing wording in `lib/presentation`
>   were read directly.
> - One external definition was checked on 2026-09-24: Open-Meteo's hourly-variable
>   documentation (<https://open-meteo.com/en/docs>).
> - Runtime evidence is limited to today's two green host test runs (896 plus 2 E2E). The
>   reference tests are cited by name.
>
> **Rules applied:**
> - A simplified model is not called wrong when the project defines and labels it (for
>   example the dew heuristic, the 5-minute grid, and the airless altitudes).
> - A finding names the exact formula, parameter, assumption or documented requirement it
>   concerns.

**Status vocabulary:**

| Status | Meaning |
| --- | --- |
| CORRECT | Implementation matches the documented definition and the reference evidence |
| INCORRECT | It contradicts a stated definition or requirement |
| MISLEADING | The value is computed correctly, but its label or wording claims more, or something different |
| UNDER-SPECIFIED | The definition or labelling leaves a material ambiguity |
| UNKNOWN | Not determinable from the evidence |

**Severity** is the impact on a user's decision or on stored data: High, Medium, Low.

---

## 1. Findings that are not CORRECT

### SCI-01 — Forecast freshness is presented as current after the data has aged
- **Exact claim:** the weather card and Tonight say "Updated just now" / "Updated N min ago" with age class `current`. Window annotations omit the "aging/stale forecast" note while the class is `current`. Save/Start snapshots record `"age": "current"`.
- **Concept:** data age, measured from the forecast's fetch time. ADR-012 §6: under 3 h current, 3–12 h aging, 12 h and over stale.
- **Actual implementation:**
  - `age` and `ageDuration` are computed once, at load, from `nowUtc` (`night_weather_service.dart:89-100`) and stored as final fields (`night_weather.dart:44-64`).
  - The UI renders these stored values (`night_text.dart:21-28`).
  - The opportunity annotation copies the class (`imaging_opportunity_calculator.dart:330-338`; `opportunity_text.dart:105-110`).
  - The snapshot persists it (`session_snapshot_builder.dart:177,215`).
  - Nothing reloads the forecast while the app stays alive (no lifecycle hook or timer; see 02 / ENG-01).
- **Expected:** ADR-012 §6 and CLAUDE.md: "cached data is never presented as current".
- **Status:** **MISLEADING** · **Severity:** Medium · **Confidence:** High for the mechanism, Medium for how often it occurs.
- **Required verification:** on a device, background the app for more than 3 h after a load and check the label. In a snapshot, check whether `fetchedAtUtcMs` against `takenAtUtc` contradicts the stored `age`.

### SCI-02 — "Chance of precipitation" is shown for the hour itself, but the provider's value covers the preceding hour
- **Exact claim:**
  - The hour strip shows "precip. %" in the slot for hour H (`weather_forecast_widget.dart:394,488`).
  - The night summary shows "Chance of precipitation" (`:301-302`).
  - CALC-32 (SCIENTIFIC_INTEGRITY Part B) states that the "hourly values are instantaneous except gusts (preceding-hour max)".
- **Concept:** the time support of a forecast variable. Open-Meteo documents `precipitation_probability` as the "Probability of precipitation with more than 0.1 mm of the **preceding hour**" (docs retrieved 2026-09-24). `cloud_cover`, `temperature_2m`, `dew_point_2m`, `wind_speed_10m` and `visibility` are instantaneous; `wind_gusts_10m` is a preceding-hour maximum.
- **Actual implementation:**
  - The value at hour H is placed in the slot for hour H with no qualifier.
  - The night range (`night_weather_summarizer.dart:123`) takes every hour that overlaps sunset..sunrise, so its first value refers to the hour *before* the slot.
  - ADR-012 §3 (`DECISIONS.md:1891-1905`) gives "Chance of precipitation" with no time support. Gusts, by contrast, are correctly labelled "(max of preceding hour)" (`weather_forecast_widget.dart:305`).
- **Expected:** the variable's time support stated as gusts' is. CALC-32's statement is contradicted by the provider's definition.
- **Status:** **MISLEADING** (UI). The CALC-32 documentation statement is **INCORRECT**. · **Severity:** Low · **Confidence:** High.
- **Required verification:** none for the definition. An owner decision on wording.

### SCI-03 — Two definitions of "Moon up" are used side by side
- **Exact claim:**
  - "Moon up …" intervals and moonrise/moonset (sky card, Tonight `MoonText.up`, tracker "Moonrise") use one definition.
  - "Moon up N min of it" in windows, the optional Moon gate, and "Closest to the target while both are up" use another.
- **Concept:** a horizon-crossing convention. Meeus ch. 15: geocentric altitude h₀ = 0.7275 π − 0.5667°, which is apparent upper limb with refraction. The alternative is a topocentric, airless centre altitude above 0°.
- **Actual implementation:**
  - Rise/set and `upIntervals` use h₀ (`moon_calculator.dart:410-436`; `moon_conditions.dart:62-76`).
  - Window up-time and the gate use `moon.altitudesDeg[k] > 0`, the topocentric airless centre (`imaging_opportunity_calculator.dart:175,292`).
  - Closest approach uses `moonAlt > 0 && targetAlt > 0` (`moon_calculator.dart:473`).
  - A topocentric centre altitude of 0° is roughly 0.8° above the h₀ threshold in geocentric altitude (π ≈ 0.95°). The window's "Moon up" therefore starts a few minutes after the displayed moonrise and ends a few minutes before moonset, of the same order as the 5-minute grid.
- **Expected:** each definition is documented in its own place (CALC-28 h₀; CALC-29/CALC-33 "altitude > 0°"). Nothing states that the two differ, or which one "Moon up" means in the UI.
- **Status:** **UNDER-SPECIFIED** · **Severity:** Low · **Confidence:** High for the code; Medium for the size estimate (it varies with latitude and declination).
- **Required verification:** compare the displayed moonrise with the first window sample flagged "Moon up" on a few reference nights.

### SCI-04 — Times are shown to the minute on a 5-minute grid; the error runs in one direction
- **Exact claim:** sunset, dusk, dawn, sunrise, moonrise/set and window start/end are shown as HH:MM ("Capture ends at …", "max 55° at 01:20") with no resolution note.
- **Concept:** sampling quantization. The crossing is reported at the first grid sample *after* it (`visibility_calculator.dart:196-205`; `moon_calculator.dart:424-429`). A sample's state holds for `[t_i, t_{i+1})` (`imaging_opportunity_calculator.dart:75-78,199-207`).
- **Actual implementation:**
  - Every reported crossing is late by 0–5 min.
  - For windows the effect is asymmetric:
    - Dusk and target-rise edges start late (conservative).
    - The dawn edge and the target-setting edge end late. A window can include up to 5 min in which the Sun is already above the darkness limit, or the target is already below the minimum altitude.
  - That time counts as available time in the fit (`capture_analysis_viewmodel.dart:152`).
  - The reference tests accept a [−2, +7] min tolerance against USNO and Horizons (CALC-08; `astronomy_reference_test.dart:71-123`).
- **Expected:** SI-009 and CALC-10/22/33 document "5-min quantization / resolution". Neither the direction of the bias nor any resolution caveat reaches the UI.
- **Status:** **UNDER-SPECIFIED** · **Severity:** Low · **Confidence:** High.
- **Required verification:** none for the mechanism. Whether a caveat or a conservative edge rule is wanted is an owner question; see §3.

### SCI-05 — ISO and camera gain are labelled a "Sensitivity setting"
- **Exact claim:** the block editor's field reads "Sensitivity setting (for your records)", with the helper "Recorded only; it does not change the plan." (`widgets/capture_plan/capture_block_dialog.dart:256-257`).
- **Concept:** ISO and gain set amplification; they do not raise photon collection (SI-004 "Correct Interpretation").
- **Actual implementation:** the value is descriptive only and used by no calculation (`CaptureGain`; SI-004 progress for TASK 5.3/5.6). No text claims that ISO collects more light.
- **Expected:** SCIENTIFIC_INTEGRITY Part C rule 6 and CLAUDE.md say "ISO is never shown as sensitivity (SI-004)". SI-004's TASK 5.6 progress note records the label without flagging the conflict.
- **Status:** **MISLEADING** (terminology against a written project rule) · **Severity:** Low · **Confidence:** High.
- **Required verification:** owner or maintainer ruling on whether "sensitivity setting" is acceptable wording under rule 6.

### SCI-06 — "Fills X % of the frame" is a ratio of the major axis to the short side, not an area
- **Exact claim:** Tonight's candidates show "fills 80 % of the frame" (`screens/tonight/tonight_candidates_screen.dart:239`).
- **Concept:** CALC-31 frame fill = the target's angular size (OpenNGC **major axis**, arcmin) ÷ (60 × the shorter FOV side, degrees) (`capability_calculator.dart:139-153`). It is a linear ratio. It ignores the minor axis and orientation, and it can exceed 100 %.
- **Actual implementation:** the planner words the same value precisely ("% of the frame's short side", `presentation/shared/capability_text.dart:31-35`). The candidates list does not.
- **Expected:** the CALC-31 definition ("size over the shorter side of the field").
- **Status:** **MISLEADING** (candidates wording only) · **Severity:** Low · **Confidence:** High.
- **Required verification:** none.

### SCI-07 — An accepted frame estimate is stored exactly like counted frames
- **Exact claim:** "Accept the estimate of N frames" (`execution_screen.dart:388-389`) turns an estimate into confirmed frames. Those frames then feed "actual integration" (CALC-37) and per-target progress (CALC-38).
- **Concept:** provenance of a measured versus an estimated quantity. CALC-35 is explicitly an **upper bound**: dither, refocus, flips and failed frames are not subtracted.
- **Actual implementation:**
  - `acceptEstimate()` calls `confirm(n)` (`execution_viewmodel.dart:156-160`), which writes a plain `framesConfirmed` event.
  - `ExecutionEventKind` has no estimate kind or flag (`domain/models/execution.dart:3-14`).
  - Once stored, accepted estimates cannot be told apart from frames the user counted.
  - The UI word is "About N more (estimated)" (`execution_screen.dart:150-156`) for a value the domain defines as an upper bound (`execution_machine.dart:178`).
- **Expected:** ADR-016 §3 (owner decision, `DECISIONS.md:2447-2462`) decided both points: "labelled 'about N (estimated)'", and "accept the estimate writes the estimate as a confirmation event". The behaviour therefore follows the ADR. The tension is with ADR-008 §6's provenance convention (`estimated` versus `reported`) and with CALC-37 presenting the result as "actual".
- **Status:** **UNDER-SPECIFIED** (an accepted design with a provenance gap; see §3) · **Severity:** Low · **Confidence:** High.
- **Required verification:** owner decision. Do not change this speculatively.

### SCI-08 — Site elevation cannot be unknown, so an invented number is stored as a fact
- **Exact claim:** "Elevation (m)" is required (`presentation/shared/site_form_input.dart:10-13`). The domain rejects anything outside −500..9000 m but has no null (`domain/models/location_profile.dart:16,36-37`).
- **Concept:** unknown versus default (SI-008; ADR-008 §6 "NULL means unknown").
- **Actual implementation:**
  - Elevation is used by no calculation. Altitudes are computed at sea level (`moon_calculator.dart:249-250`, "site on the ellipsoid at sea level"), with no horizon dip.
  - The value is still copied into every snapshot (`session_snapshot_builder.dart:63`, `elevationM`) and into exports.
  - A user who does not know the elevation must type something, which is then recorded without provenance.
- **Expected:** SI-008 ("unknown data must not be shown as zero or a default"). FEATURE_STATUS F-07 already lists "elevation cannot be unknown … unused by any calculation".
- **Status:** **UNDER-SPECIFIED** · **Severity:** Low · **Confidence:** High.
- **Required verification:** none.

### SCI-09 — Night-level Moon illumination is shown without the instant it applies to
- **Exact claim:** "N % lit" (Tonight, window notes) and "Moon Illumination: N%" (sky card).
- **Concept:** illuminated fraction at one instant. The app uses mean solar midnight, `startUtc + 12 h` (`moon_calculator.dart:492-494`). It changes by up to about 6 percentage points across a night (`moon_conditions.dart` doc; F-15).
- **Actual implementation:** correct to 0.008 pp against Horizons (CALC-28). The value is whole-percent rounded. The optional Moon gate compares the gate threshold against this single midnight value (ADR-013 §2).
- **Expected:** the definition is documented in ADR-013 §2 and CALC-33. The UI does not say "at midnight".
- **Status:** **UNDER-SPECIFIED** (labelling) · **Severity:** Low · **Confidence:** High.
- **Required verification:** none.

### SCI-10 — The calculation documentation contradicts the code and itself
- **Exact claims and actual state:**
  - `OpticalCalculator.calculateNPFExposure` doc says NPF is "not shown in the UI" (`optical_calculator.dart:63`). NPF has been shown since TASK 8.6 (`home_screen.dart:149-150`).
  - `calculateRelativeStackingGain` doc says "multiplier of signal improvement" (`optical_calculator.dart:42`). √N is a noise and SNR ratio under i.i.d. noise, not a signal gain. The UI help text is correct (`capture_budget_summary.dart:~155`: "compares the random noise of a stack").
  - CALC-17 says "not surfaced" and CALC-28 says "not yet used by the app"; both are superseded. CALC-07 lists `calculateCulminationAltitude`, which is absent from `lib` (grep).
  - SI section statuses contradict the index:
    - SI-001 section "Broken (unsurfaced)" (`SCIENTIFIC_INTEGRITY.md:167`) versus index "Resolved" (`:89`).
    - SI-002 section "Partial" (`:230`) versus index "Resolved" (`:90`).
    - SI-003 says no UI help text exists (`:266-267`), but its own TASK 5.6 progress note (`:273`) and the code show there is one.
    - SI-008 says "GPS-default-location case remains open" (`:485`), but the default position no longer drives any night: `sessionNight` is null while `isDefaultLocation` (`session_plan_viewmodel.dart:84-92`).
    - SI-009 says "Implemented (undocumented)" (`:528`), but TD-036 is resolved and the functions carry source, units and error comments (`astronomical_engine.dart`, `visibility_calculator.dart`).
- **Concept:** ADR-005 (calculations are auditable) and SCIENTIFIC_INTEGRITY Part C rule 1.
- **Status:** **MISLEADING** (documentation) · **Severity:** Low · **Confidence:** High.
- **Required verification:** none. These are documentation facts.

### SCI-11 — A draft without a site takes the UTC calendar date as its night key
- **Exact claim:** a draft's `evening_date` is the night key (ADR-014).
- **Concept:** ADR-007 §2 night identity; CLAUDE.md trap 2 ("never derive a night from a DateTime's Y/M/D").
- **Actual implementation:** without a site, `_plan()` uses `today = CalendarDate.fromDateTimeFields(_clock.nowUtc())` (`session_plan_viewmodel.dart:95,149`). The key is corrected by the next autosave once a site exists. Save and Start require a site (`:280-287`).
- **Expected:** a night key only from `SessionNightResolver`.
- **Status:** **INCORRECT** (against the rule; limited to transient siteless drafts) · **Severity:** Low · **Confidence:** High. Same as 02 / ENG-05.
- **Required verification:** none.

### SCI-12 — New drafts default to M42 and the first rig without an "example" label
- **Exact claim:** Tonight and the planner show M42 and the seeded rig as the session's own target and rig.
- **Concept:** a default presented as the user's choice (SI-008; the TASK 4.4 "Example plan" precedent).
- **Actual implementation:** `session_plan_viewmodel.dart:109-114` (`searchTargets('M42').first`; first rig). Only the blocks carry an example flag (`:63-75`).
- **Status:** **UNDER-SPECIFIED** · **Severity:** Low · **Confidence:** Medium. Same as 02 / ENG-15.
- **Required verification:** owner intent.

### SCI-13 — Already documented: the darkness limit is applied inconsistently
- **Exact claims:**
  - The sky card's "True Night Window" always uses −18° (`sky_darkness_widget.dart:299`; TD-051).
  - Tonight's "Dark (Sun below −18°)" (`tonight_home_screen.dart:234`; TD-054).
  - The tracker's "Astronomical dawn" countdown (`execution_outlook.dart:60`; CALC-36).
  - Windows, the fit and "Window left" use the user's limit (−18, −15 or −12°).
- **Status:** "True Night Window" is **MISLEADING** when the limit is not −18° (documented). The other two are labelled with −18° or "astronomical", so they are accurate but inconsistent. · **Severity:** Low · **Confidence:** High.
- **Required verification:** none; already recorded.

---

## 2. Verified CORRECT

In every row below, the implementation matches its documented definition, and where a reference
test exists it passed in today's runs (host).

| ID | Claim / quantity | Concept and definition | Implementation evidence | Supporting test | Conf. |
| --- | --- | --- | --- | --- | --- |
| C-01 | JD, GMST, LST | Meeus ch. 7 and eq. 12.4 (linear term), UT1 ≈ UTC, mean sidereal time; all documented | `astronomical_engine.dart:17-67` | J2000 JD and GMST values (`astronomical_engine_test.dart:24-38`); end to end via USNO star altitudes | High |
| C-02 | Target altitude | J2000 precessed to the date (Meeus 21.2/21.4); geometric (airless) by stated policy; no nutation or aberration (20–40″, documented) | `visibility_calculator.dart:50-71`; `astronomical_engine.dart:81-111` | 67 USNO altitudes ≤ 0.017° (`astronomy_reference_test.dart:178-195`) | High |
| C-03 | Sun altitude, twilights | USNO low-precision Sun; thresholds −0.833 / −6 / −12 / −18°; polar states typed (`SunNeverBelow`/`SunAlwaysBelow`), never a bare null | `visibility_calculator.dart:85-124,176-229` | Horizons ≤ 0.0097°; USNO events within [−2, +7] min (`astronomy_reference_test.dart:54-123`) | High |
| C-04 | SessionNight | Window from mean solar noon to mean solar noon (λ × 240 000 ms); identity = civil evening date in the site's zone; default = the window containing now; UTC integer ms; L4 (the morning shows the night just ended) accepted by the owner (ADR-007) | `session_night_resolver.dart:20-160`; `site_time_context.dart:18-52` | ADR-007 matrix T1–T17, P1–P3 (`session_night_resolver_test.dart`); DST cases T9–T12; E2E DST run | High |
| C-05 | Displayed zones | Site IANA zone when known, else the labelled device zone; 12/24-hour setting respected | `night_time_formatter.dart:11-101`; `iana_time_context.dart` (`latest_all`) | `night_time_formatter_zone_test.dart` | High |
| C-06 | Moon position, illumination, rise/set | Meeus ch. 47 full tables, ch. 22 nutation, ch. 40 topocentric, ch. 48 illumination; ΔT = 69.2 s documented with a revisit note | `moon_calculator.dart:67-436` | 32 Horizons instants (RA·cosδ 7.5″, illumination 0.008 pp); 99 USNO phases ≤ 10 min; rise/set vs USNO (`moon_calculator_test.dart`) | High |
| C-07 | Moon–target separation | Topocentric Moon versus the target precessed to the date; vector form of Meeus ch. 17 | `moon_calculator.dart:304-346,452-477` | ≤ 0.05° vs USNO and Horizons (`moon_conditions_test.dart:35-68`) | High |
| C-08 | NPF | t = k(16.8567 N + 0.099724 f + 13.713 p)/(f cos\|δ\|); constants derived from Michaud's stated physics (Airy 4.47 λN at 550 nm, 3″ seeing, 2p Bayer, 13713 s/rad); k 1–3; \|δ\| = the field minimum (the target's \|δ\| minus half the diagonal, floored at 0); shown only for untracked rigs, and marked "if untracked" when tracking is unknown; displayed with "≈", k and \|δ\| | `optical_calculator.dart:90-129`; `capability_calculator.dart:106-163`; `capability_text.dart:15-28` | 5 independent examples incl. a phone lens (`optical_calculator_test.dart:67-136`); `capability_calculator_test.dart:63-158` | High |
| C-09 | Pixel scale, FOV | 206.265 · p[µm] / f[mm] ″/px; FOV = 2 atan(d / 2f) | `optical_calculator.dart:16-36` | ASI2600MC reference (`capability_calculator_test.dart:53`) | High |
| C-10 | Relative stacking gain | √N per (filter, exposure) group, never pooled; the help text says it is not the image's SNR and ignores sky, target and camera (SI-003, ADR-009 §7); "SNR" appears in no user-visible string | `capture_budget_calculator.dart:89`; `capture_budget_summary.dart` (gain lines and help text) | `capture_plan_widget_test.dart:178,243` | High |
| C-11 | Capture budget | Integration, acquisition, window load and session budget in integer ms; overheads labelled "assumption — measure your rig"; off overheads shown as "Not included", never 0 | `capture_budget_calculator.dart:7-64,212+`; `capture_assumptions_panel.dart:17-52` | ADR-009 E1–E7 exact (`capture_budget_calculator_test.dart:35-170`) | High |
| C-12 | Fit and "similar nights" | Atomic placement in order; tight margin; "About N similar nights" labelled as an assumption of identical nights (CALC-26) | `fit_analyzer.dart:83-341` | E1–E7, margins, inverse (`fit_analyzer_test.dart`) | High |
| C-13 | Storage estimate | Average RAW MB × frames; null (shown "Unknown") when the size is unknown; labelled an estimate that ignores binning and compression | `optical_calculator.dart:52-58`; `capture_budget_summary.dart` (storage lines) | `capture_plan_widget_test.dart:189`; `capture_budget_calculator_test.dart:214` | High |
| C-14 | Imaging opportunity | Gates are darkness and minimum altitude, plus optional Moon and cloud gates; unknown never excludes; every failing reason listed; maximum altitude inside the windows; no score | `imaging_opportunity_calculator.dart:134-268`; `opportunity_text.dart` | ADR-013 V1–V12, polar and circumpolar cases (`imaging_opportunity_calculator_test.dart`); candidates equal the single-target view | High |
| C-15 | Weather variables and dew | UTC unix-time parsing; missing values unknown ("no forecast", never 0); visibility labelled "Horizontal visibility (not transparency)"; gusts "(max of preceding hour)"; dew risk labelled "(heuristic)" against a user margin | `open_meteo_forecast_parser.dart`; `weather_forecast_widget.dart:301-358`; `night_weather_summarizer.dart:53-82` | `open_meteo_forecast_test.dart:56-111`; `night_weather_summarizer_test.dart` | High (see SCI-01, SCI-02) |
| C-16 | Bortle / SQM provenance | Nullable; source and date per field; the legacy default 4 became NULL with a note; other legacy values marked `legacy`; no Bortle↔SQM conversion; a transient Bortle is marked "not saved" | `from11To12` (`app_database.dart`); `sky_darkness.dart`; `site_viewmodel.dart:72-85`; `sky_darkness_widget.dart:120-130` | `schema_migration_test.dart:626`; `planner_sky_darkness_test.dart:115-164` | High |
| C-17 | Equipment parameters | N stored (`optical_rigs.aperture`); an optional D with N = f/D within 1 %; N above 32 flagged for review, never converted; units in every label; plausibility bounds documented as input-sanity assumptions | `equipment_limits.dart:1-58`; `drift_equipment_repository.dart:30-31` | `equipment_limits_test.dart`; `equipment_selection_screen_test.dart:330,379`; v13→v14 migration test | High |
| C-18 | Seeded equipment | ASI2600MC: 23.5 × 15.7 mm, 6248 × 4176 px, 3.76 µm (6248 × 3.76 = 23.49 mm; 4176 × 3.76 = 15.70 mm); camera `verified` with a manufacturer URL; optics "example", `estimated`; RAW size unknown | `equipment_seeder.dart:12,30-51` | `equipment_seeder_test.dart:60,84` (within 2 %) | High |
| C-19 | Target catalog | OpenNGC v20260501, J2000, source stored; size = OpenNGC major axis (unknown for M40 and M73); V magnitude where available (25 unknown), never a default | `assets/catalog/catalog_v2.json` (checked: 164 objects) | `catalog_seeder_test.dart:27-93` | High |
| C-20 | Coordinate entry | A bare RA number is hours, degrees need "°"; the Dec sign applies to the whole value (−0°30′) | `astro_math.dart:81+` (CALC-30) | `astro_math_coordinates_test.dart:15-135` | High |
| C-21 | Execution arithmetic | Running time from UTC events; a clock behind the last event counts zero and is flagged; the estimate is capped and shown as estimated (wording per ADR-016 §3; see SCI-07); the remaining plan is labelled an estimate without dither, refocus or flips | `execution_machine.dart`; `execution_outlook.dart`; `execution_screen.dart:150-156,283-286` | `execution_machine_test.dart`; `execution_outlook_test.dart`; E2E DST run (2 h across fall-back) | High |
| C-22 | Planned vs actual; progress | Integration = exposure time only; rejected frames and calibration excluded; no fraction when nothing is planned; progress only from completed, non-legacy sessions with a target | `session_reconciliation.dart`; `target_progress.dart` | `session_reconciliation_test.dart`; `target_progress_test.dart` | High |
| C-23 | Unknown handling (general) | Storage, size, magnitude, Bortle/SQM, weather values, NPF without a target, frame fill without a size: each is null or "Unknown", never 0 | as cited in the rows above | as cited | High (exceptions: SCI-08, SCI-12) |

---

## 3. Scientific questions that should stay open

These are legitimate, documented uncertainties. None should be "fixed" speculatively. Each needs
an owner decision or new evidence first.

1. **The horizon and local obstructions** (TASK 10.5 cut; ADR-013 G3 reserved). The minimum altitude stands in for obstructions. No azimuth or horizon model should appear without the deferred task.
2. **Comparing stacks across sub-exposure lengths.** √N applies only within a (filter, exposure) group. A comparison across exposures needs a noise model (sky, read noise, dark current, QE) and per-camera data; SI-003 action 4 requires an ADR first.
3. **Bortle ↔ SQM conversion, and any automatic sky-brightness source** (PD-05 options C and D deferred). No conversion without a cited source and an ADR record.
4. **Seeing and transparency** (ADR-012 §3, deferred). No provider variable measures them. Horizontal visibility must stay labelled as not transparency.
5. **Dew on optics.** T − Td against a user margin is a labelled heuristic. Real dew depends on surface temperature, wind and heaters, which the app does not know.
6. **Night-level Moon illumination** at mean solar midnight, and the Moon gate's use of it (ADR-013 §2). This is a documented simplification (up to about 6 pp of change within a night). Only the labelling is open (SCI-09).
7. **Grid resolution and edge bias** (SCI-04). Whether window edges should round conservatively, or the UI should state a resolution, is a product decision. The 5-minute grid itself is documented and reference-tested.
8. **Provenance of accepted estimates** (SCI-07). ADR-016 §3 deliberately stores an accepted estimate as a confirmation. Whether it should also carry "estimated" provenance (ADR-008 §6) is for the owner.
9. **ΔT** is fixed at 69.2 s and documented to be revisited when leaving 2020–2035. No action before then.
10. **NPF assumptions.** 3″ seeing, 550 nm, a Bayer sensor (the 2p term), a moderately aberrated lens. The equipment model does not record mono versus Bayer. Changing the term would need Michaud's source guidance and an ADR, not a guess.
11. **Per-frame overhead default** of 5 s, and the other overhead defaults. These are labelled assumptions; empirical suggestions from logged sessions are deferred to v1.1 (MASTER_ROADMAP §10).
12. **Moving objects** (planets, comets). Excluded from 1.0 by ADR-010 §3. Existing rows are labelled "Fixed coordinates — this object moves".
13. **Elevation** (SCI-08). Whether to make it nullable, or to use it at all (horizon dip, topocentric height), is a model decision. It has no effect on any current calculation.

---

## 4. Summary

| Status | Findings |
| --- | --- |
| INCORRECT | SCI-11 (the siteless draft night key; limited impact). The CALC-32 documentation statement under SCI-02 |
| MISLEADING | SCI-01 (Medium: freshness presented as current); SCI-02, SCI-05, SCI-06, SCI-10, SCI-13 (Low) |
| UNDER-SPECIFIED | SCI-03, SCI-04, SCI-07, SCI-08, SCI-09, SCI-12 (Low) |
| CORRECT | C-01 to C-23: the core astronomy, time model, Moon, NPF, optics, budget and fit, opportunity, provenance and seeds are consistent with their documented definitions and supported by independent reference tests |
| UNKNOWN | None at the formula level. Device and live-service behaviour stays unverified (01 and 02) |

**Answers to the brief's specific checks:**
- **Unknown values stay unknown:** yes, except elevation (SCI-08) and the default target and rig (SCI-12).
- **Approximate values are labelled:** mostly. The exceptions are forecast age (SCI-01), grid resolution (SCI-04) and the instant for Moon illumination (SCI-09).
- **Formulas have documented assumptions:** yes. Some documentation of those formulas has drifted out of date (SCI-10).
- **UI terminology matches the calculations:** mostly. The exceptions are SCI-02, SCI-05, SCI-06 and SCI-13.
- **Reference tests support the claims:** yes for the astronomy, Moon, NPF and budget. No reference test covers the weather-variable time semantics (SCI-02).
- **Nothing is described more strongly than the evidence supports,** except the forecast "Updated just now" (SCI-01) and the "About N" wording for a value the domain defines as an upper bound (SCI-07, per ADR-016).
