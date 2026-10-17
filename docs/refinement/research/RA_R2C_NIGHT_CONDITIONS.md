# RA.R2c — Night conditions: weather and Moon (R2, R3 — presentation)

> Research for RA.R2, step R2c ([plan](../prompts/RA_R2_RESEARCH_PLAN.md) §3 "R2c"), 2026-10-17.
> Coverage: RA-E01, E02, E03, E05, E06 and the weather part of RA-D03 ([Phase A](RA_R1_PHASE_A_ASSESSMENT.md)).
> **Research only.** Nothing here is decided. Every option in §7 is an input to RA.D. A new
> provider is possible only as an option for the owner's decision (ADR-012 §2, trap 22).
> Labels: **FACT** — verified against a primary source or a measurement (URL or `file:line`, access
> date 2026-10-17); **INFERENCE** — the agent's conclusion; **AS DESCRIBED** — a secondary source or
> forum, not confirmed.

## 1. Method

- **The code baseline was not fully re-verified.** The Phase A rows RA-E01…E06 and D03 were taken as given.
  Only the places needed for the estimates were read selectively:
  - `lib/data/repositories/open_meteo_weather_repository.dart` — the request (`start_hour..end_hour`
    of one night, `models=best_match`, 16-day horizon);
  - `lib/data/services/open_meteo_forecast_parser.dart:15-27` — 11 hourly variables;
  - `lib/domain/repositories/weather_snapshot_store.dart` — cache key: site, model and night;
  - `lib/domain/models/night_weather.dart:17-27` — `WeatherFreshness` 3 h / 12 h;
  - `lib/domain/services/moon_calculator.dart:410-470` — 5-min grid, rise/set, `conditionsForNight`;
  - `lib/domain/services/moon_calculator.dart:385-390` — `phaseLongitudeDeg` already exists;
  - `lib/domain/models/moon_conditions.dart:80-148` — `MoonDuringDark`, CALC-43;
  - `lib/domain/services/visibility_calculator.dart:171` — `sampleStep` 5 min;
  - `lib/domain/models/session_night.dart:37` — night length 24 h;
  - `lib/presentation/viewmodels/night_conditions_viewmodel.dart:180-192` — the Moon is computed
    synchronously in the ViewModel and cached by key;
  - `lib/presentation/viewmodels/candidates_viewmodel.dart:40` — the `Isolate.run` pattern.
- **Decisions:** ADR-010, ADR-012 and ADR-013 (`docs/DECISIONS.md`). CALC-32 and CALC-43, as well as the
  S1.13 / SCI-03 entry (`docs/SCIENTIFIC_INTEGRITY.md`). Privacy and COMPLIANCE. Trap 22
  (`docs/ENGINEERING_GUARDRAILS.md`).
- **Provider measurements (FACT, 2026-10-17):** several manual `curl` HTTP requests were made
  to public APIs. Coordinates: the neutral Greenwich point (51.48, 0.0), not user data.
  Responses were kept in the session's temporary directory and did not enter the repository. No build, tests or
  application code were run.
- **Moonlit:** only `README.md`, `index.html`, fragments of `app.js` and `astronomy.js`, and the
  `vendor/` listing were read. Nothing was executed. There is no licence file at the root (FACT: `ls` of the root; there
  is only `vendor/*-LICENSE.txt`). **Only the concept** is carried over.
- **Web:** WebSearch and WebFetch. Quotes are shorter than 15 words. Reviews and forums are marked as anecdotal.

## 2. Significant night parameters

| Parameter | Why it matters for imaging | Source | Present in AstroPlan now |
| --- | --- | --- | --- |
| **Total cloud cover** | The main "can I image" factor. A modelled area fraction, not the look of the sky. Accuracy drops with lead time: for CMC, "mostly clear" forecasts are ≈80 % correct up to 12 h and ≈76 % at 36–48 h; beyond 48 h the accuracy is unknown (FACT, Clear Sky Chart key) | [CSC key](https://www.cleardarksky.com/c/WAkey.html); [Open-Meteo docs](https://open-meteo.com/en/docs) | Yes; on Home — range and age |
| **Cloud cover by layer** (low < 3 km, mid 3–8 km, high > 8 km) | Thin high clouds spoil an image even at low total cloud cover (ADR-012 §3). Partial cloud in two layers can cover the whole sky (FACT, meteoblue) | [Open-Meteo docs](https://open-meteo.com/en/docs); [meteoblue seeing help](https://content.meteoblue.com/en/private-customers/website-help/outdoor-and-sports/astronomy-seeing) | Yes, in details |
| **Precipitation** (probability) | Risk to equipment. In Open-Meteo this is the probability of > 0.1 mm over the **preceding** hour. The value always comes from ensembles (GFS, ICON, IFS) (FACT) | [Open-Meteo docs](https://open-meteo.com/en/docs) | Yes |
| **Wind and gusts** | Wind does not decide whether observing is possible, but long-focal-length imaging needs light wind (FACT, CSC). In practice wind breaks guiding and shakes the guide scope and cables (AS DESCRIBED: AstroBin forums, [astropix](https://astropix.com/html/astrophotography/phd2_autoguiding.html)). A gust in Open-Meteo is the maximum over the preceding hour | [CSC key](https://www.cleardarksky.com/c/WAkey.html); [AstroBin](https://app.astrobin.com/forum/topic/84913/phd2-not-giving-sufficient-corrections-causing-severe-star-trails) | Yes, in details |
| **Humidity and dew point** | Risk of dew on optics. Dew is more likely with clear sky, falling temperature and light wind, and it does not reduce to humidity alone (FACT, CSC). In AstroPlan this is the CALC-32 heuristic: T − Td ≤ margin. Labelled as a heuristic | [CSC key](https://www.cleardarksky.com/c/WAkey.html); CALC-32 | Yes, in details |
| **Temperature** | Cooling of thick mirrors and tube currents; battery capacity in the cold (FACT, CSC). Focus drift with temperature change: N.I.N.A. users set refocusing at ΔT ≈ 1 °C but themselves call the threshold arbitrary (AS DESCRIBED, [AstroBin](https://app.astrobin.com/forum/topic/186916/autofocus-questions)) | [CSC key](https://www.cleardarksky.com/c/WAkey.html) | Yes |
| **Seeing** (turbulence, ″) | Limits fine detail. Weakly related to water vapour, so good seeing often coincides with poor transparency (FACT, CSC). The CSC scale is calibrated for 11–14″ instruments. **INFERENCE:** scale = 206,265 × pixel (µm) / focal length (mm). For a phone (≈6.5 mm, 1.2 µm) ≈38″/px, for a DSLR with a 50 mm lens and a 4.3 µm pixel ≈18″/px. Both are much larger than 1–3″ seeing. Seeing matters only for long focal lengths: at 500 mm and a 4 µm pixel it is ≈1.7″/px | [CSC key](https://www.cleardarksky.com/c/WAkey.html); [meteoblue](https://content.meteoblue.com/en/private-customers/website-help/outdoor-and-sports/astronomy-seeing) | **No:** no Open-Meteo variable provides it (ADR-012 §3) |
| **Transparency** (column transparency) | Depth and contrast of the image. CSC computes transparency from total water vapour, without smoke. At cloud cover > 30 % CSC does not forecast it (FACT) | [CSC key](https://www.cleardarksky.com/c/WAkey.html) | **No.** Horizontal visibility is deliberately not presented as transparency (ADR-012 §8) |
| **Smoke and aerosol (AOD)** | Any smoke other than "no smoke" probably reduces transparency (FACT, CSC: the Smoke row, FireWork model). In Astrospheric smoke is part of Transparency, sourced from the RAP model (FACT) | [CSC key](https://www.cleardarksky.com/c/WAkey.html); [Astrospheric](https://www.astrospheric.com/DynamicContent/astrospheric.php) | No |
| **Jet stream** (wind at ≈ 200–250 hPa) | An indicator of poor seeing. According to meteoblue, poor seeing usually occurs at speeds > 35 m/s and < 5 m/s. This is the provider's empirical rule, not a physical threshold | [meteoblue](https://content.meteoblue.com/en/private-customers/website-help/outdoor-and-sports/astronomy-seeing) | No |
| **Lifted index / CAPE** | Atmospheric instability: convection, thunderstorms. Part of 7Timer ASTRO. Secondary for night imaging (INFERENCE) | [7Timer doc](https://www.7timer.info/doc.php?lang=en) | No |
| **Moon** | Illumination and time above the horizon during the dark period. This is a fact, not an "impact" (ADR-010) | CALC-28 and CALC-43 | Yes: "Moon up X of Y dark" |

**Conclusion (INFERENCE).** AstroPlan already has all the "ground-level" parameters that Clear
Outside and Clear Sky Chart show:
- cloud cover by layer;
- precipitation;
- wind and gusts;
- temperature, dew point and humidity;
- visibility.

Clear Outside shows the same set of rows (FACT, [clearoutside.com/forecast](https://clearoutside.com/forecast/51.48/0.00)).
The gap is not in the data but in the presentation. Data are requested for one night only, and of these only
cloud cover is visible on Home (RA-E02, E03).

What is missing entirely: seeing, transparency, smoke and AOD. Seeing matters only for long-focal-length
setups. For the "phone/DSLR wide-field" class it is secondary (INFERENCE, scale above).

## 3. Provider matrix

| Provider | Data | Licence and terms | Cost | Attribution | Privacy (what leaves the device) | Failure behaviour and reliability |
| --- | --- | --- | --- | --- | --- | --- |
| **Open-Meteo Forecast** (current) | The 11 ADR-012 variables, hourly, up to 16 days, `best_match`. **Available without a new provider** (FACT, measurement 2026-10-17, 384 h): `total_column_integrated_water_vapour`, `wind_speed_250hPa` and `wind_speed_200hPa`, `cape`, `boundary_layer_height`. `lifted_index` for `best_match` at the measurement point — all 384 values null. No seeing or transparency | Free for non-commercial use. Definition — "no subscriptions and no ads". Limits: < 10,000 per day, 5,000 per hour, 600 per minute, 300,000 per month. A request with > 10 variables or > 2 weeks is counted fractionally, e.g. 1.5 calls (FACT, [terms](https://open-meteo.com/en/terms), [pricing](https://open-meteo.com/en/pricing)) | 0 under the current model (free, no ads) | CC BY 4.0, "Weather data by Open-Meteo.com" is already shown | Site coordinates and time interval. IP addresses and coordinates are kept in logs for 90 days (FACT, terms) | No SLA: uptime is not guaranteed, abuse is blocked (FACT, terms). Failures are already handled: Unavailable, Malformed, OutOfRange, cache with age (RA-E05) |
| **Open-Meteo Air Quality** (same operator, different host `air-quality-api.open-meteo.com`) | `aerosol_optical_depth` (550 nm) and `dust` from CAMS global: 0.4° (≈45 km), 3-hourly step, 5-day forecast, updated every 12 h (FACT, [docs](https://open-meteo.com/en/docs/air-quality-api)). Measurement: 168 h in the response, the last 35 null (≈5 days) | Same Open-Meteo terms | 0 | **CAMS** attribution and a link to Open-Meteo required (FACT, docs) | Same coordinates, but a **new host and a new field** → update privacy and COMPLIANCE (trap 22) | As for Open-Meteo. The 5-day horizon is shorter than 16 → "no data" for the remaining nights |
| **7Timer! ASTRO** | Cloud cover, seeing and transparency (codes 1–8; seeing < 0.5″ … > 2.5″; transparency in mag/airmass), lifted index, RH, 10 m wind, precipitation type, T. Model — GFS, updated 4 times a day (FACT, [doc](https://www.7timer.info/doc.php?lang=en)). **Measurement:** 3 h step, 24 points = 72 h; `init` field = run time (UTC); response 5.3 KB; HTTPS works; no key needed | Data are free; use and redistribution are permitted for **non-commercial** purposes. Developers are asked to notify the operator. Use is at one's own risk (FACT, doc) | 0 | Operator: Shanghai Astronomical Observatory, CAS. No formal attribution string; citing "7Timer!" is reasonable (INFERENCE) | **New recipient** (China): coordinates to 0.001° and IP. The operator's privacy policy could not be found (evidence gap) | No SLA. There have been multi-day "frozen" data: disk and firewall failures (AS DESCRIBED: [2014 forum](https://www.iceinspace.com.au/forum/showthread.php?p=1059455), [operator blog](https://y234.cn/?p=508)). The tracker has 2 open issues, the latest from 2020 (FACT, [GitHub](https://github.com/Yeqzids/7timer-issues/issues)). No independent validation of seeing and transparency was found. Freshness must be computed from `init`, not from download time (INFERENCE) |
| **Meteoblue** | Seeing in ″, Seeing indices 1/2, "bad layers" (gradient > 0.5 K per 100 m), jet stream, clouds in three layers (FACT, [help](https://content.meteoblue.com/en/private-customers/website-help/outdoor-and-sports/astronomy-seeing)). Free on the website for 3 days, with point+ for 7 days | **No seeing package found** in the API. Free Weather API: 10 million credits per year, ≈2,500 calls, commercial use permitted; packages Basic, Air (CAPE, LI), Clouds/Trend; the Sun & Moon package is unavailable (FACT, [free API](https://business.meteoblue.com/products/weather-apis/free-weather-api)). Paid APIs from €2,400 per year (FACT, [pricing](https://business.meteoblue.com/pricing)). Seeing is available in the consumer point+ and in the iframe widget | Paid for seeing | meteoblue link in the widget; terms not read | Coordinates and API key. The iframe widget would require a WebView and third-party requests | Not applicable: seeing via the API is not confirmed |
| **Astrospheric** | Cloud cover, transparency with smoke (RAP), seeing from the Rahill model, dew point. As described — CMC/RDPS models (North America) | API only with **Astrospheric Professional**. The page has a banner about non-production endpoints; "All rights reserved" (FACT, [api info](https://www.astrospheric.com/dynamiccontent/api_info.php)) | User subscription | — | Key and coordinates | Not applicable: paid subscription key and unclear terms |
| **ECCC / CMC (RDPS)**: seeing and transparency, the source of Clear Sky Chart and Photo Ephemeris | Seeing and sky transparency indices: GRIB2, 10 km, hourly up to 84 h, on the rotated RDPS grid (AS DESCRIBED: [MSC Datamart mailing list](https://comm.collab.science.gc.ca/mailman3/hyperkitty/list/dd_info@comm.collab.science.gc.ca/thread/BH3KXVL63I2TJJCQYJUQVRITVGPY7NCO/)). Coverage: North America and northern Europe (AS DESCRIBED, [Photo Ephemeris](https://photoephemeris.com/articles/new-seeing-and-transparency-forecasts)) | ECCC Data Server End-use Licence, commercial use permitted, attribution mandatory (FACT, [licence](https://eccc-msc.github.io/open-data/licence/readme_en/)) | 0 | "Data Source: Environment and Climate Change Canada" | Whole GRIB2 files are downloaded: there is no point API | Not applicable without an own server. Coverage is not global |
| **MET Norway Locationforecast** | Global 9-day forecast (FACT, [docs](https://api.met.no/weatherapi/locationforecast/2.0/documentation)). No seeing | CC BY 4.0, mandatory User-Agent, ≤ 20 requests/s. Browsers and mobile apps are advised to use **their own proxy** (FACT, [ToS](https://api.met.no/doc/TermsOfService)) | 0 | CC BY 4.0 | — | Not directly applicable: a proxy is needed, and AstroPlan has no backend |
| **Clear Outside** (link only) | 7 days hourly: cloud layers, visibility, fog, precipitation, wind, dew point, humidity, Moon. Powered by the "Meteosource Weather API" (FACT, [forecast page](https://clearoutside.com/forecast/51.48/0.00)). Experimental seeing comes from 7Timer (AS DESCRIBED, [SGL](https://stargazerslounge.com/topic/340555-clear-outside-update)) | No public API | — | — | Only when the user opens the link themselves. Coordinates go into the URL, as with lightpollutionmap.app | Failure — the external page did not open; the app is unaffected |

**Conclusion (INFERENCE).**
- **Open-Meteo remains the only realistic source** for a multi-day overview: nothing
  changes in licence, privacy or cost.
- **The only free point JSON source of seeing and transparency** with global coverage is
  7Timer!. Its limitations:
  - 72 h horizon, 3 h step;
  - coarse GFS-based codes;
  - the "non-commercial use" condition;
  - no SLA and no privacy policy found;
  - no independent validation.
- Meteoblue, Astrospheric, ECCC and MET Norway drop out on terms, price or architecture: no
  backend, key or point API.

## 4. Multi-day overview

### 4.1. One request for 16 days (FACT, measurement 2026-10-17)

| Request (same 11 variables, `best_match`, `timeformat=unixtime`) | Response | gzip | Hours | Trailing nulls |
| --- | --- | --- | --- | --- |
| One night (`start_hour..end_hour`, as now) | 1,539 B | — | ≈16 | — |
| `forecast_days=16` | **21,878 B** | **6,181 B** | 384 | 9 h for most variables; `precipitation_probability` — 21 h (from hour 363); `visibility` — 11 h |

- **Call accounting:** under the Open-Meteo rule, 11 variables over 16 days ≈ 11/10 × 16/14 ≈ **1.26
  calls** (INFERENCE from [pricing](https://open-meteo.com/en/pricing)). Currently a night costs 1.1
  calls, and changing the night triggers a new request. With the overview, changing the night within the horizon does not
  require a request, so the total number of calls **decreases** (INFERENCE).
- **Compression:** `autoUncompress` in `dart:io` defaults to `true` (FACT,
  [api.dart.dev](https://api.dart.dev/dart-io/HttpClient/autoUncompress.html)). Whether the client
  sends `Accept-Encoding: gzip` by default is not confirmed (INFERENCE; verify during
  implementation).
- **Horizon tail:** the last hours arrive as null. The existing parser already turns them into
  unknown, not 0 (SI-008, `open_meteo_forecast_parser.dart`). The "no forecast" presentation is preserved
  (ADR-012 §5).

### 4.2. Night card: values without a verdict (compatible with ADR-012)

The interval is the same as CALC-32's (sunset…sunrise, h = −0.833°). No new computed interval is needed.
An option of "only the dark span at the user's limit" would mean changing CALC-32,
and that is the owner's decision.

| Field | Value | Presentation |
| --- | --- | --- |
| Date and weekday | "Sat 18 Oct" in the site's zone | `NightTimeFormatter` (ADR-007) |
| Cloud cover | **Range** of total cloud cover min–max, in % | The icon is only a visual class of the value; the number is always beside it. Colour does not mean "good/bad". If only some hours are known — "known N of M h" |
| Precipitation | Maximum probability, % | When the model lacks it — "—, unknown", never 0 |
| Wind | Maximum wind and gusts, km/h | Gust — maximum of the preceding hour (label as now) |
| Dew | Hours with dew risk, "N of M h" | "heuristic" label (CALC-32) |
| Temperature | min–max, °C | — |
| Moon | Illumination %, **moon-free dark hours** and window type (↘ evening / ↗ morning / • all night / none) | Computed offline. Shown also beyond the 16-day horizon |

- **Do not show:**
  - verbal verdicts ("excellent night");
  - "best night first" sorting;
  - a suitability colour scale;
  - a composite index.

  All of these are prohibited by ADR-012 §3 and §8 and by CLAUDE.md ("no black-box Astro Score").
- **A condition word**, as in the `com.twtapp` reference ("Clear", "Cloudy"), is a cloud-cover
  boundary invented by the app (INFERENCE: an arbitrary threshold). The alternative is the provider's
  `weather_code` (WMO). That is a 12th variable and an amendment to ADR-012 §3, and it describes
  weather in general, not astronomical conditions. Recommendation: no word; number and icon.
- **Lead time:** CMC itself does not know its accuracy beyond 48 h ([CSC key](https://www.cleardarksky.com/c/WAkey.html)).
  Therefore for distant nights a factual label "forecast N days ahead" is appropriate instead of a reliability
  estimate (INFERENCE). Open-Meteo ensemble spread is a possible extension, outside 1.0.

### 4.3. Cache and freshness

- **One snapshot per site:** a key from coordinates rounded to 0.01°, the model and the request **range**,
  not a single night. This is an amendment to `WeatherSnapshotStore.keyFor` and ADR-012 §4/§6. Nights are
  slices of this snapshot by `[startUtc, endUtc)`. The rule "another site's data are never
  shown" is preserved.
- **Freshness:**
  - all nights share one `fetchedAt`, hence one `WeatherFreshness` state for the whole overview:
    current < 3 h, aging 3–12 h, stale ≥ 12 h (`night_weather.dart:18-19`);
  - the freshness label appears once in the overview header and is repeated in the selected night's card;
  - a stale cache is never presented as current; a refresh error is shown (ADR-012 §6).
- **Cadence:** refresh on site change, on explicit Refresh and when the app returns with aging
  or stale data, as now. Changing the night within the horizon no longer makes a request. A night beyond the
  horizon is "no forecast yet", while the Moon is computed for it.
- **Plan snapshot (ADR-014):** when saving to a plan, as now, the slice of the selected
  night is written, not all 16 days. RA-E06 (show this slice in the Logbook) does not depend on the overview and is passed
  to R2e.
- **Storage volume:** ≈22 KB of JSON per site in SharedPreferences (INFERENCE from the measurement). It is reasonable to
  keep snapshots for the N most recent sites. To be decided during implementation.

## 5. Moon: mobile presentation, calendar, computation cost

### 5.1. What to show (Moonlit concept, without its code)

| Element | Source in AstroPlan | Note |
| --- | --- | --- |
| **Phase name** | `MoonCalculator.phaseLongitudeDeg` already computes the longitude difference: 0 — new moon, 90 — first quarter, 180 — full moon, 270 — last quarter (`moon_calculator.dart:385-390`, Meeus ch. 49) | Sector boundaries are a **naming convention**, not physics. In Moonlit the quarters span ±5°. The convention must be documented (SCIENTIFIC_INTEGRITY) and chosen (RA.D or R2b) |
| **Illumination** | CALC-28, at mean solar noon + 12 h, label "at midnight" (SCI-09) | Unchanged |
| **Moon-free dark hours** (large) | dark − moonUp from `MoonDuringDark` (CALC-43) | The definition of "Moon above the horizon" and the darkness limit are a question for R2b §4. The only requirement here: **the calendar, the night card and the strip use one definition and one 5-min grid**. Moonlit does this, and otherwise the numbers diverge |
| **Window type and time** (↘ evening: twilight→moonrise; ↗ morning: moonset→dawn; • all night) | A new output is needed: **intervals** of "dark ∧ Moon not above the horizon" from the same samples, not just totals. This is a new CALC | The symbol always comes with text ("evening", "morning"), not just an arrow |
| **Moonrise and moonset** | `riseSetForNight` (h₀ per Meeus) | Already documented: h₀ and "Moon up" (centre > 0°) differ by 5–10 min (SCI-03, S1.13). If windows show rise time by h₀ and duration by the centre, the ends may not match the duration. This is presented as in SCI-03 or unified by an R2b decision |

**Do not carry over from Moonlit:** highlighting a day as "good" at ≥ 4 h without the Moon (`app.js:147`,
`styles.css:66`). This is a fixed threshold verdict, and it is prohibited by CLAUDE.md ("no arbitrary
universal scientific thresholds") and ADR-010 ("fact, not impact").

### 5.2. Monthly calendar (mobile)

- **Grid:** 7 columns, cell ≥ 48 dp (DESIGN_SYSTEM: field use). In a cell:
  - the day of the month;
  - a mini phase as an image without its own semantics;
  - "3h 20m" and the window symbol.

  Empty days — "0 h" with the reason in the cell's semantics: "The Sun does not go below the limit" or
  "The Moon is above the horizon for the whole dark period" (as Moonlit does). At 200 % text or on a narrow
  screen — **a week instead of a month**; Moonlit does the same on short screens.
- **Tap:** selects the night. This is the same `SessionNight` as night selection in the planner. Beyond the
  16-day weather horizon the calendar shows only the Moon. Weather values for nights
  1–16 can be overlaid in a row below. Whether to merge the calendar with the §4 overview is a question for RA.D.
- **Accessibility:**
  - each cell has one semantic label: "18 October: waxing gibbous, 72 % illuminated,
    3 h 20 min moon-free dark, evening window";
  - colour is not the only carrier of meaning: symbol + word + number;
  - **field mode (red):** differences only by brightness and shape, no hue, all roles
    red or black (DESIGN_SYSTEM §Field mode). Strip segments differ by fill and
    hatching; the legend has text.

### 5.3. Night strip (noon→noon)

- **Segments:** day, twilight at the −0.833° / −6° / −12° / −18° thresholds, "Moon above the horizon"
  over the dark part, "moon-free". The data already exist: `NightTimeline` and the Moon samples. The current
  `sky_darkness_widget.dart:340-400` has no Moon layer and no legend (RA-E01).
- **Text alternative:** one line, for example "Noon to noon: 9 h 50 min dark at −18°;
  6 h 30 min moon-free, 23:10–05:40". This is how Moonlit's `aria-label` works. A visible legend
  is mandatory.

### 5.4. Cost of computing 30 nights offline

- **Per night now** (FACT, code):
  - Sun — 289 samples (24 h / 5 min + 1), low-accuracy formula;
  - Moon — 289 topocentric positions (Meeus ch. 47 with the full tables of periodic terms,
    plus nutation and parallax);
  - `riseSetForNight` — another 289 geocentric positions.

  All synchronous, in `NightConditionsViewModel.moonConditions`, with a keyed cache
  (`night_conditions_viewmodel.dart:180-192`).
- **Indirect measurement** (FACT, `docs/refinement/evidence/STAGE_10_MEASUREMENTS.md:170`): "Planner:
  night change", x86_64 emulator, profile — worst build frame **9 and 14 ms**, no frames longer than
  16.7 ms. **INFERENCE:** if the Moon and Sun recomputation for the night happens in this build (the getters
  are lazy and read during build), a full night recomputation with a target costs ≤ ≈14 ms on the emulator.
  Computation without a target is cheaper.
- **Estimate for 30 nights (INFERENCE):** ≤ ≈30 × 14 ms ≈ **0.3–0.4 s on the emulator** in the worst case. On a
  modern phone probably less, but not measured. This exceeds the frame budget (16.7 ms),
  therefore:
  1. **Off the UI thread.** `Isolate.run` — the same pattern as `candidates_viewmodel.dart:40`.
  2. **Cache.** Key: site (0.01°), darkness limit, zone, month. The result is deterministic and does not
     depend on the network. Recompute only on key change. The adjacent month can be precomputed
     after the first frame.
  3. **The same 5-min grid**, without coarsening. Coarsening to 10–15 min with event refinement by
     bisection would give a 2–3× speed-up. But then the calendar would diverge from the night card by
     minutes, and Moonlit specifically requires a single classification. Recommendation: do not coarsen
     until a measurement shows the need.
  4. **Measurement on a phone** is an acceptance criterion of a future Task, not an assumption of this report.
- **16 nights of weather:** folding 384 hours into nights — microseconds (INFERENCE). It needs the
  Sun for 16 nights (the CALC-32 interval), which can be taken from the same calendar cache.

## 6. Recommended night summary: Home and details

**Home — one "Tonight" card** (INFERENCE; the order of cards on Home is decided by RA.D per K9 and
RA-D03, together with R2e):

1. **Darkness:** "Dark 19:42–05:31 (−18°)". This is the time at the user's limit (CALC-41).
2. **Moon:** phase name, illumination %, "moon-free 3 h 20 min · evening ↘ 19:42–23:02". When
   there is none: "Moon up all dark" or "no darkness at −18°".
3. **Cloud cover:** range "Cloud 10–45 %" and freshness ("updated 2 h ago" or "stale"). Without
   data: "no forecast yet".
4. **Value row:** maximum precipitation %, gusts (maximum), dew-risk hours "2 of 9 h". Minimum
   temperature — optional. Only when data are available; unknown — "—".
5. "Night details" link, Open-Meteo attribution (already present).

**In details** ("Night & Moon" and "Weather"):
- **hourly band** (5 rows now): cloud cover by layer, precipitation, wind and gusts,
  T/Td/RH, visibility, dew. Format per the owner's references: a 24-hour strip with icons and
  wind (MIUI, Google);
- **16-night overview** (§4.2), as a horizontal band or a list;
- **monthly Moon calendar** (§5.2) and **night strip** (§5.3);
- **seeing and transparency** — only if RA.D chooses a provider (§7, W4).

**What is removed from Home:** nothing from the answer. Cloud cover within windows (ADR-013 annotations, cloud gate)
remains part of the planner's answer, not a duplicate (RA-D03). Only the **duplicate weather row** in the
planner can be removed, if Home and details cover it. That is a decision for R2e and RA.D.

## 7. Options for RA.D

| ID | Question | Recommendation | Alternative | Trade-offs | Superseded decision | Privacy/COMPLIANCE (trap 22) | Approval needed |
| --- | --- | --- | --- | --- | --- | --- | --- |
| **W1** | Multi-day overview | One Open-Meteo `forecast_days=16` request per site. Nights are slices. One cache and one freshness | Keep the one-night request; no overview | ≈22 KB (6 KB gzip) instead of 1.5 KB. Fewer requests on night change. The cache key must be migrated | ADR-012 §4 ("the request covers this night"), §6 (per-night cache key); `WeatherSnapshotStore.keyFor` | Same recipient and data (coordinates and time). **Wording must be updated:** privacy `docs/privacy/index.md:50` ("the night's hours" → "the next 16 days") and COMPLIANCE `docs/COMPLIANCE.md:42` (cadence "one request per site and night"). The Data Safety category does not change | Yes (ADR-012 amendment) |
| **W2** | Night card content | §4.2: cloud cover (range), precipitation (maximum), wind and gusts (maximum), dew hours, T, Moon (%, moon-free, window type). No verdicts, suitability colour or sorting | Minimum as in `com.twtapp`: cloud cover % + Moon % | More values — more density. The minimum is simpler but hides wind and dew (RA-E03) | None (within ADR-012). Interval — CALC-32 | None | Yes (product) |
| **W3** | New variables from the **same** Open-Meteo | Do not add in 1.0. Record as future options: TCWV (raw transparency input, following CSC), 250 hPa wind (jet stream), AOD from the Air Quality API | Add TCWV and 250 hPa wind to details as **raw values** with the note "proxy, not seeing/transparency". No thresholds: the meteoblue > 35 / < 5 m/s rule is a provider heuristic | Useful for long focal lengths but easily mistaken for an index. Needs copy and an SI entry. AOD — only 5 days and separate CAMS attribution | ADR-012 §3 (variable table; "Deferred: seeing and transparency") | TCWV and 250 hPa: no new data leaving the device; only an ADR amendment. **AOD:** new host `air-quality-api.open-meteo.com` and CAMS attribution → privacy, COMPLIANCE and About in the same change | Yes (ADR) |
| **W4** | Seeing and transparency | **Do not introduce a provider in 1.0.** State honestly: "seeing/transparency not forecast here". Optionally — a link the user opens themselves (Clear Outside or the 7Timer page), following lightpollutionmap.app (M2, RG-08/09) | **7Timer! ASTRO** as opt-in, following Nominatim (off by default), only in details, labelled "7Timer! (GFS), 3-hourly, 72 h". Freshness from `init`. Coordinates coarsened to 0.1° (INFERENCE: the GFS grid is coarse anyway). Notify the operator | 7Timer: 72 h, coarse codes, no SLA or validation, non-commercial use, new recipient in China. Little benefit for phone and DSLR (§2). Link: zero code and risk, but the data stay outside the app | ADR-012 §2 ("Open-Meteo stays the only provider for 1.0"), §3 Deferred | **Opt-in 7Timer:** new recipient (coordinates and IP) → privacy, COMPLIANCE (Data Safety: location shared; new recipient), About, attribution, a toggle in Settings. The operator's policy could not be found. **Link:** add to privacy, section "Links you open yourself" | Yes (new provider or link) |
| **M1** | Moon on Home and in the night card | Phase name + illumination + **large "moon-free dark hours"** + window type with time | Keep "Moon up X of Y dark" and add the phase | A new CALC is needed: moon-free intervals and their classification. Definition — from R2b §4 | ADR-010 is preserved (fact). CALC-43 is extended | None (offline) | Yes (product; definition — R2b) |
| **M2** | Monthly calendar | Offline, in "Night & Moon" details. A week at large text. No "good" highlighting. `Isolate.run` + per-month cache. Phone measurement is an acceptance criterion | Only a 7-day Moon band in the W1 overview | A month covers planning beyond the weather horizon; the cost is a new screen and ≈0.3–0.4 s of computation (emulator, estimate) off the UI thread | None. A scope question for RA-A06 | None (offline) | Yes (scope) |
| **M3** | Noon→noon night strip | Moon layer and legend in `sky_darkness_widget`, text alternative, hatching for field mode | A separate Moon strip below the twilight strip | One strip is clearer but denser at 200 % text | None | None | Yes (UI, together with R2e) |
| **H1** | Home summary | §6: darkness, Moon, cloud cover with freshness, value row | Only cloud cover and Moon | See K9 and RA-D03: card order is a question for R2e | ADR-019 §5/§6, RG-05 T1 (order) — only if the order changes | None | Yes (R2e, RA.D) |
| **L1** | Weather in the Logbook (RA-E06) | Pass to R2e. The snapshot already stores the hours (`session_snapshot_builder.dart:246-275`) | — | — | ADR-014 (display) | None | R2e |

**Not subject to change under any choice** (RA-E05, ADR-012):
- the Idle, Loading, OutOfRange, Unavailable, Available states;
- the 3 h / 12 h age;
- "no forecast" instead of 0;
- attribution;
- unknown ≠ 0;
- no score and no "good/bad" colouring.

## 8. Sources

All sources accessed on 2026-10-17.

**Primary and official**
- Open-Meteo Forecast API docs: <https://open-meteo.com/en/docs>
- Open-Meteo Terms: <https://open-meteo.com/en/terms>
- Open-Meteo Pricing (call counting): <https://open-meteo.com/en/pricing>
- Open-Meteo Air Quality API (CAMS, AOD): <https://open-meteo.com/en/docs/air-quality-api>
- Measurements of `api.open-meteo.com/v1/forecast` responses (1 night and 16 days, 11 variables; pressure-level
  variables, TCWV, CAPE, LI) and `air-quality-api.open-meteo.com/v1/air-quality` (AOD, dust):
  point 51.48, 0.0; files in the session's temporary directory, not in the repository
- 7Timer! documentation: <https://www.7timer.info/doc.php?lang=en>
- Measurement of `https://www.7timer.info/bin/api.pl?...&product=astro&output=json`
- 7Timer issues: <https://github.com/Yeqzids/7timer-issues/issues>
- Clear Sky Chart, legend (key): <https://www.cleardarksky.com/c/WAkey.html>
- meteoblue, Astronomy Seeing help: <https://content.meteoblue.com/en/private-customers/website-help/outdoor-and-sports/astronomy-seeing>
- meteoblue Free Weather API: <https://business.meteoblue.com/products/weather-apis/free-weather-api>
- meteoblue Pricing: <https://business.meteoblue.com/pricing>
- meteoblue Astronomy Seeing Widget: <https://business.meteoblue.com/products/plug-and-play-visuals/astronomy-seeing-widget>
- Astrospheric API info: <https://www.astrospheric.com/dynamiccontent/api_info.php>
- Astrospheric, main page: <https://www.astrospheric.com/DynamicContent/astrospheric.php>
- Astrospheric, transparency page: <https://www.astrospheric.com/dynamiccontent/education/ed_transparency_en.html>
- ECCC open data licence: <https://eccc-msc.github.io/open-data/licence/readme_en/>
- MET Norway Terms of Service: <https://api.met.no/doc/TermsOfService>
- MET Norway Locationforecast docs: <https://api.met.no/weatherapi/locationforecast/2.0/documentation>
- Clear Outside, forecast page: <https://clearoutside.com/forecast/51.48/0.00>
- Dart `HttpClient.autoUncompress`: <https://api.dart.dev/dart-io/HttpClient/autoUncompress.html>
- Meeus J., *Astronomical Algorithms*, 2nd ed., ch. 47–49 (via code and ADR-010)

**Secondary, forums, anecdotes**
- MSC Datamart, mailing list on RDPS seeing and transparency: <https://comm.collab.science.gc.ca/mailman3/hyperkitty/list/dd_info@comm.collab.science.gc.ca/thread/BH3KXVL63I2TJJCQYJUQVRITVGPY7NCO/>
- Photo Ephemeris, seeing and transparency (ECCC): <https://photoephemeris.com/articles/new-seeing-and-transparency-forecasts>
- Stargazers Lounge, Clear Outside update: <https://stargazerslounge.com/topic/340555-clear-outside-update>
- IceInSpace, 7Timer data "froze": <https://www.iceinspace.com.au/forum/showthread.php?p=1059455>
- 7Timer operator's blog on outages: <https://y234.cn/?p=508>
- AstroBin: wind and guiding: <https://app.astrobin.com/forum/topic/84913/phd2-not-giving-sufficient-corrections-causing-severe-star-trails>
- AstroBin: temperature-based refocusing: <https://app.astrobin.com/forum/topic/186916/autofocus-questions>
- Astropix, PHD2 and wind: <https://astropix.com/html/astrophotography/phd2_autoguiding.html>

**Local**
- Moonlit (concept, no licence for its own code): `C:\Users\zalub\OneDrive\Desktop\52\moonlit-main\README.md`,
  `index.html`, `app.js:147`, `astronomy.js:120-129`, `vendor/`
- AstroPlan code and documents: `file:line` references in §1–§7
