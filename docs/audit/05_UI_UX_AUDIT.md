# 05 — UI/UX audit: information density and UX complexity

> **Audit stage 5.** Run on 2026-09-25 against `main` @ `becae04`. This is an audit and research
> task: **no application code or source-of-truth document was changed.** This file is the only
> file added to the repository.
>
> **Inputs.** `docs/audit/00_CONTEXT_BASELINE.md` **still does not exist** (as audits 01 and 04
> also recorded). I used `docs/audit/01_ROADMAP_COMPLIANCE.md`, `docs/audit/04_RUNTIME_AUDIT.md`,
> `CLAUDE.md`, `docs/PRODUCT_SPEC.md`, `docs/IA_WIREFRAMES.md`, `docs/MASTER_ROADMAP.md`, ADR-015 and
> ADR-016 (`docs/DECISIONS.md`), `.agents/rules/05-ui-design.md`, and the whole of `lib/presentation`
> (about 12,000 lines).
>
> **Screenshots and recordings.** None were attached to the request and none are in the
> repository. I therefore produced my own runtime evidence (section 1.2): phone-sized renders of
> every main screen from the real widget tree, and native renders of the key screens. Android
> screenshots named for the old package id (`com.astroplan.astroplan`, dated 2026-09-21) exist
> elsewhere on this machine; they predate the current UI (TASK 12.x onwards) and were not used.
>
> **The question.** The suspected problem is information density and UX complexity. This audit
> does not assume a redesign, a Basic/Advanced mode, or removal of functionality. It asks whether
> the problem exists, where, and why, and ends with solution *hypotheses* that are deliberately not
> ranked or chosen. No overall score is given.

---

## 0. The answer in brief

**Does the problem exist?** Yes — but it is **concentrated, not app-wide.**

| Where | Verdict | Key evidence (section 3) |
| --- | --- | --- |
| **Session planner** (`/session/:id`) | **Real, and the dominant problem.** The page is 5.1 screens long with the default plan (6.2 with an LRGB plan, 11.6 at 200 % text), carries 660–793 words, and puts its own answer — "does the plan fit tonight?" — on the **last** screen. Facts are repeated across cards, and sections are ordered by data type, not by the user's decision. | §3.1, §3.2, §3.3; UX-01 to UX-04 |
| **Defaults and warnings** | **Real.** On a fresh install the default plan opens with a red "stars may trail" warning, and Tonight shows "No window" in red before any target is chosen. These are not density in themselves, but they add alarm to an already dense page and teach users to ignore warnings. | UX-15, UX-16 |
| **Terminology and formatting** | **Real, moderate.** The same concept has up to five names (e.g. the dark window), and three duration formats sit on one card. This raises cognitive load without adding information. | UX-18, UX-19 |
| **Sessions list, rig editor, first run** | **Real, secondary.** A fixed seven-chip filter bar sits above a one-item list; the rig editor needs sensor specs a casual user may not know; the first run shows an example target and rig as if already chosen. | UX-30, UX-22, UX-24 |
| **Tonight dashboard** | **Not a density problem.** 1.1 screens, 110 words; the fit, its reason and Start are on the first screen. Its issues are specific: drill-downs land at the wrong place, Moon wording, no night picker, a duplicate card after Start. | UX-10, UX-11, UX-13, UX-17 |
| **Tracker** (`/session/:id/run`) | **Not a density problem.** One screen, 96 words, seven 56 dp controls in the bottom 204 px. Its issues are specific: an accessibility mechanism, a hidden keep-screen-on, missing "window opens in". | UX-27, UX-28 |

**Why it happens (root causes, not symptoms):**

1. **The planner kept the pre-navigation Home page by decision.** ADR-015 §2 and `IA_WIREFRAMES.md`
   specify "one session planner (today's Home content, same sections and order)". The Tonight
   dashboard was added in front of it (TASK 12.5), but the planner itself was never re-ordered.
2. **Accretion without an owner of the whole page.** Each roadmap task added its required output as
   another card or row (§3.4): G5 the budget breakdown, G6 the Moon lines, G7 sky darkness, G8 the
   capability rows, G9 the weather table, G10 the opportunity list. Each acceptance criterion required
   visibility; no task owned the page's hierarchy after TASK 12.1.
3. **Honesty rules implemented as "always expanded".** The scientific-integrity rules (unknown stays
   unknown, assumptions visible, √N labelled as relative, no score) are sound. The implementation
   meets "visible" by showing every explanation inline, at full length, every time.
4. **Structure mirrors the domain model.** Sections are "Target / What", "Equipment / How",
   "Conditions & Timeline / When", "Capture Plan" — data categories, not the order in which a user
   answers "can I, when, and with what plan?".
5. **Seeded defaults create warnings.** The seeded rig's tracking is "Unknown", so NPF guidance treats
   it as possibly untracked and flags every light sub longer than 0.5 s — in practice all of them; M42 and the example plan are pre-selected.
6. **No shared vocabulary or format layer.** Wording and number formats are written per widget.

**What this audit does not conclude:** which solution to adopt (section 8 lists hypotheses), or how
real users behave. There is no human or device evidence (section 10); several findings are marked
REQUIRES USER TESTING for that reason.

---

## 1. Inputs, method and evidence

### 1.1 What was read

- The audit inputs named in the brief (00 is missing), the product and IA intent, the roadmap's
  G12/G13 tasks and its rejected/deferred list.
- Every screen and widget in `lib/presentation`, the theme (`lib/core/theme`), and the shared wording
  helpers (`night_text.dart`, `opportunity_text.dart`, `capability_text.dart`).
- The accessibility sweep `test/presentation/accessibility_test.dart` and the harness
  `test/support/planner_harness.dart`, to see what is and is not covered.
- Selected Flutter SDK and engine sources, to verify two mechanisms (colour-role fallback; how Android
  accessibility exposes a tappable node).

### 1.2 Runtime evidence produced for this audit

No screenshots were provided, so I rendered the real app. Two temporary probes were written, run
and **deleted**; copies are kept outside the repository (Appendix B). `git status` afterwards shows
only `docs/audit/`.

| Run | What | Result |
| --- | --- | --- |
| U1 | **Host renders** (`flutter test`, `flutter-tester`). The real ViewModel graph (`PlannerHarness`), an in-memory SQLite database with the real catalog and rig seeds, a site (Ljubljana, `Europe/Ljubljana`), a fixed clock (2026-11-10 17:00 UTC), and a **synthetic forecast with every variable filled** (the existing sweep's fake returns no forecast). Viewport **412 × 915 dp** (a common large-phone size), real Roboto and Material Icons fonts. Three scenarios: first run without a site (p0), planning (p1), tracking and logging (p2). 61 PNGs. | Passed. Every page was also laid out on a tall view to measure its **exact** content height (summing the viewport's sliver extents), words and tap actions (from the semantics tree), and the **official Android tap-target guideline**. Overflows were captured per screen instead of failing the run. |
| U2 | **Native renders** (`flutter run -d windows`, Impeller). The same scenario for Tonight, the planner and its sections, red field mode, light theme, the tracker and the candidates list. 13 PNGs (one from the first, failed attempt: the no-target state). | Passed. In host renders, text styles **without a font family** (app-bar titles, the chart's axis labels) render as solid blocks — a test-engine font limitation. U2 renders them correctly and confirms everything else in U1. |

**Hygiene.** A first U2 attempt showed that `CatalogSeeder` reads its "already seeded" flag from the
**real** Windows preferences store (left by earlier desktop runs). The probe was fixed to use mock
preferences *before* seeding. The real store (`%APPDATA%\com.astroplan\astroplan\shared_preferences.json`)
was last written 2026-09-24 09:23:57, **before** these runs, so no user data was changed. (The
underlying seeding design is already covered by 04/RT-02.)

### 1.3 Evidence levels and classification

| Evidence level | Meaning here |
| --- | --- |
| CODE VERIFIED | Read in source |
| RENDER VERIFIED | Seen or measured in U1 (host) or U2 (native Windows) renders of the real widget tree |
| DEVICE VERIFIED | On Android: **none** |
| HUMAN VERIFIED | Observed with real users: **none** |

| Classification (as requested) | Used when |
| --- | --- |
| **CONFIRMED UX PROBLEM** | The mechanism is verified in code or renders, and it directly obstructs a task the product exists for |
| **LIKELY UX PROBLEM** | The mechanism is verified, but its impact depends on behaviour not observed here |
| **DESIGN TRADE-OFF** | The cost is real but buys something the product has decided to value (usually an ADR or integrity rule) |
| **PREFERENCE / SUBJECTIVE** | Reasonable people would disagree; no task is obstructed |
| **REQUIRES USER TESTING** | Only observation of users (or a device in real darkness) can decide it |

Each finding also states its **reach**: *every session*, *first run*, *occasional* — this is not a score.

### 1.4 Limits

- **No users.** The three perspectives in section 5 are expert review plus measurement, not research.
- **No device, no darkness, no TalkBack.** DPI, OLED black, red-mode adaptation and real touch are unobserved.
- **One viewport and locale** (412 × 915 dp, en-US with a 12-hour clock). Smaller phones (360 dp)
  will be longer; this was not measured.
- **Synthetic data.** The forecast is invented (plausible, varying); the night is one date and site.
- **Word counts** come from the semantics tree (what a screen reader reads). They approximate visible
  text and include a few non-visual labels (the planner's chart description adds about 25 words).

---

## 2. Constraints any change must respect

These decisions shape what "reducing density" may mean. They are not findings.

| Constraint | Source | Implication |
| --- | --- | --- |
| The UI should be **"clean, minimalist, information-dense"** | `.agents/rules/05-ui-design.md` | Density is intended. The goal is density *with hierarchy*, not sparseness |
| **No composite score**; no good/bad colouring of weather | MASTER_ROADMAP §3.1, §10; ADR-012 / TASK 9.4 | Traffic-light summaries (a common pattern, R11) conflict; candidates cannot be ranked by a score |
| **Unknown stays unknown** (never 0 or a default) | SI-008 | "Unknown" rows stay; they may move, not disappear |
| **Assumptions visible**; √N labelled relative *with help text*; NPF as guidance | ADR-009 §4, TASK 5.6, PRODUCT_SPEC | Must stay reachable. Whether "visible" can mean "one tap away" is an **owner decision** |
| **Field constraints**: ≥ 48 dp, primary actions in the lower half, little typing, red mode one tap away, no silent loss | `IA_WIREFRAMES.md` §3, ADR-015 §4 | Apply to every screen used at the telescope |
| **Tonight is a fixed view**; customizable dashboard rejected | PD-14, ADR-015 §5 | User-customizable summaries (R4, R10) conflict *for Tonight* |
| Planner keeps **"same sections, same order"** | ADR-015 §2, `IA_WIREFRAMES.md` | Re-ordering the planner changes approved design intent: owner approval |
| Seeds only with **verified specs** | TASK 8.5, CLAUDE.md | A camera/lens database (R13) needs a sourcing policy |

---

## 3. The density map (measurements)

### 3.1 Length, words and tap targets per screen (U1, 412 × 915 dp)

"Screens" = scroll content ÷ the visible list height (the viewport between the app bar and any bottom bar).

| Screen and state | Scroll content | Screens | Words (whole page) | Tap targets (page) |
| --- | --- | --- | --- | --- |
| Tonight — first run, no site | 544 px | 0.70 | 74 | 11 |
| **Tonight — site, forecast, draft plan** | 872 px | **1.12** | **110** | 13 |
| Tonight — a run in progress | 968 px | 1.24 | 122 | 14 |
| Tonight — 200 % text | 1,624 px | 2.08 | 110 | 13 |
| Planner — no site | 2,571 px | 3.42 | 283 | 18 |
| **Planner — default example plan (3 blocks)** | **3,995 px** | **5.05** | **660** (201 on the first screen) | 22 |
| Planner — LRGB + Ha plan (10 blocks) | 4,875 px | 6.16 | 793 | 36 |
| **Planner — 200 % text** | **8,500 px** | **11.63** | 660 | 22 |
| Tonight's candidates (119 of 164 with a window) | 11,878 px | 20.1 | 2,964 (304 on the first screen) | 129 |
| **Tracker** | 360 px + fixed controls | 0.55 | **96** | 1 † |
| Tracker — 200 % text | 784 px + fixed controls | 1.20 | 96 | 1 † |
| Results (reconciliation) | 1,072 px | 1.25 | 69 | 14 |
| Sessions — one session | 316 px (viewport only 619 px) | 0.51 | 66 | 14 |
| Session detail | 1,688 px | 2.17 | 198 | 8 |
| Settings | 1,784 px | 2.29 | 298 | 15 |
| About | 1,404 px | 1.80 | 335 | 8 |
| Welcome (first run) | 896 px | 1.04 | 137 | 6 |
| Library | 296 px | 0.38 | 44 | 8 |
| Site editor | 680 px | 0.79 | 38 | 10 |
| Rig editor (dialog) | 15 text fields + 1 dropdown in one dialog | — | — | — |
| Capture-block dialog | 4 dropdowns + 2 text fields (+1 when a gain is recorded) | — | — | — |

† The tracker's seven buttons expose **no tap action** to accessibility services; see UX-28.
The official Android tap-target guideline **passed on every screen**, including with a forecast.

### 3.2 Where the planner's answer sits (default plan, U1)

The list starts at y = 56 and each screen is 791 px tall.

| Element | y (px) | Screen |
| --- | --- | --- |
| "Target / What" section | 96 | 1 |
| Usable time; altitude chart | 444; 476–676 | 1 |
| Imaging windows; excluded time | 734; 842 | 1 |
| "Equipment / How" (9 rows) | 1,026 | 2 |
| **Session Date** (drives the chart and windows above it) | **1,712** | **3** |
| Night weather: ranges, dew, hour strip | 1,806–2,354 | 3 |
| Sky Darkness & Timeline | 2,458 | 4 |
| Light-pollution map card | 2,792 | 4 |
| Capture Plan: inputs, add-block button | 2,908; 3,002 | 4 |
| Outputs: six budget lines | 3,351 | 5 |
| **"Fit tonight: Fits / Tight / Doesn't fit"** | **3,601** | **5 (the last)** |
| √N, help text, storage, assumptions | 3,745–3,987 | 5 |

With the LRGB plan the fit moves to y = 4,361 (screen 6 of 6); at 200 % text to y = 7,466
(screen 11 of 12).

### 3.3 Repetition inside the planner (U1, default plan, whole page)

| Repeated content | Count | Where |
| --- | --- | --- |
| Time-zone caption "site zone Europe/Ljubljana, CET, UTC+01:00" | 5 (+1 on Tonight, +1 on candidates) | Three "Times in …" lines (window list, Moon lines, weather card), inside "True Night Window", and inside the fit's "Capture ends at" |
| Next-day marker "(+1)" | 9 | Everywhere a time crosses midnight |
| Text mentioning the Moon | 5 | Chart legend, window annotation, sky card (illumination, up-times, separation) |
| Dark-window limit "−18°" | 4 | Chart legend and three excluded-time lines (the sky card and assumptions say it again as "Astro Dusk" and "-18°") |
| Sunset/sunrise and darkness times | 3 cards | Chart bands, the sky card's four time points plus "True Night Window", and the weather card's "Sunset to sunrise" (plus Tonight's Night row) |
| "(heuristic)" dew wording | 2 | Window annotation, weather card |

### 3.4 How the planner grew (each card traces to a task whose acceptance required it)

| Planner element | Added or required by |
| --- | --- |
| Target card: current altitude, max altitude in windows | Pre-roadmap; TASK 10.3 |
| "Tonight for this target" chart + window list | TASK 10.3 |
| Equipment card: FOV, NPF, max sub, target size, tracking | TASK 8.4, 8.6 |
| Session Date card | TASK 2.4 |
| Night weather: ranges, dew heuristic, hour strip, freshness, model, attribution | TASK 9.3, 9.4 |
| Sky darkness: Bortle/SQM line and badge; Moon up-times and separation | TASK 7.4, 6.4 |
| Light-pollution map card | TASK 7.4 |
| Capture plan: breakdown, fit, fill, √N with help, storage, assumptions; sub warning | TASK 5.6, 8.6 |

---

## 4. Findings

Substantive findings use the six requested elements. Minor ones are grouped in tables with the same
fields, abbreviated.

### 4.1 Session planner: hierarchy and density

#### UX-01 — The planner's own answer is on its last screen
**CONFIRMED UX PROBLEM** · reach: every session · all three perspectives

- **User is trying to:** check whether tonight's plan works, or adjust it until it does.
- **Interface presents:** four screens of supporting data (target facts, chart, rig specs, date,
  weather table, sky card, map link) before the capture plan; within the capture plan, six budget
  lines before the verdict.
- **Friction:** the verdict ("Fits", its reason, the end time, the one-tap fill) sits at y = 3,601 of
  3,995 (screen 5 of 5); with a realistic multi-filter plan, screen 6 of 6; at 200 % text, screen 11.
  Editing a block (screen 4) and seeing its effect means scrolling between inputs and outputs.
- **Evidence:** RENDER VERIFIED (§3.2); CODE VERIFIED (`home_screen.dart:102-296`,
  `capture_budget_summary.dart:51-137`).
- **Why real:** the planner is where users change plans, and it is the only place where the fit
  meets the blocks that cause it. Tonight shows the fit, but the planner — opened from Tonight's
  "Open planner" — does not repeat it at the top.
- **Competing for attention:** nine rig-spec rows, an 11-row weather table, the sky card, and six
  budget totals rendered in the same weight as the verdict.

#### UX-02 — Section order does not follow the decision, and "When" is split
**CONFIRMED UX PROBLEM** · reach: every session

- **User is trying to:** pick a night, see what the target does that night, then plan.
- **Interface presents:** the night-dependent chart and windows on screen 1, under "Target / What";
  the **Session Date** that determines them on screen 3, under "Conditions & Timeline / When",
  together with weather and the sky card.
- **Friction:** changing the date means scrolling past the results it changes; the timeline (the
  chart) and "Timeline" (the sky card) are two sections apart.
- **Evidence:** RENDER VERIFIED (§3.2); CODE VERIFIED (`home_screen.dart:105-294`).
- **Why real:** a dependency is placed below what depends on it. The order is inherited by decision
  (ADR-015: "same sections and order"), so changing it needs the owner.
- **Competing for attention:** the rig card sits between the chart and the date.

#### UX-03 — The same facts appear in several cards, in different words
**CONFIRMED UX PROBLEM** · reach: every session

- **User is trying to:** read tonight's conditions once.
- **Interface presents:** night times in 3 cards (4 with Tonight), the Moon 5 times, the zone caption
  5 times, "(+1)" 9 times (§3.3), each phrased differently (UX-18).
- **Friction:** repeated facts take space and force the reader to check whether two differently
  named values are the same.
- **Evidence:** RENDER VERIFIED (counts in §3.3); CODE VERIFIED (`sky_darkness_widget.dart`,
  `tonight_opportunity_widget.dart`, `weather_forecast_widget.dart`).
- **Why real:** measured repetition on the page users scroll most.
- **Competing for attention:** the sky card's timeline duplicates the chart's bands.

#### UX-04 — The planner does not say which session, which night, or its state
**CONFIRMED UX PROBLEM** (deviation from `IA_WIREFRAMES.md`) · reach: every session

- **User is trying to:** know what they are editing (a draft? a saved plan? which night?).
- **Interface presents:** the title "Session planner"; no status anywhere on the page. The wireframe's
  app bar was "M42 · Fri, Nov 13 · Draft ⋮".
- **Friction:** "Save Session" gives no sign whether the plan is already saved or has unsaved changes;
  that status ("Draft", "Planned, unsaved changes") appears only on Tonight and in Sessions.
- **Evidence:** CODE VERIFIED (`home_screen.dart:45-87` has no status); RENDER VERIFIED (U2).
- **Why real:** an unmarked difference between saved and unsaved work, on the page that autosaves.
- **Competing for attention:** two icon-only app-bar actions (UX-35).

#### UX-05 — Explanations are always expanded
**DESIGN TRADE-OFF** · reach: every session

- **User is trying to:** read the numbers.
- **Interface presents:** a five-line √N explanation under every plan; "Horizontal visibility (not
  transparency)"; "Model: open-meteo / best_match"; dew as a three-line sentence; "(heuristic)" twice;
  "Preferences, not laws — measure your rig"; long help texts under every setting.
- **Friction:** experienced users re-read the same caveats every session; novices meet caveats before
  they know what the number is for.
- **Evidence:** RENDER VERIFIED; CODE VERIFIED (`capture_budget_summary.dart:152-159`).
- **Why a trade-off:** these texts implement integrity rules the product rightly values (SI rules,
  TASK 4.4, 5.6). The cost is length; the benefit is honesty. Whether "visible" may mean "one tap
  away" (the assumptions panel already works that way) is an owner decision.
- **Competing for attention:** the numbers the caveats explain.

#### UX-06 — The weather card shows every variable at once, with no priority
**DESIGN TRADE-OFF** (for experienced users) · **LIKELY UX PROBLEM** (for novices) · reach: every session

- **User is trying to:** decide whether clouds, dew or wind threaten tonight's window.
- **Interface presents:** freshness, model, span and zone; 11 range rows (total/low/mid/high cloud,
  precipitation, wind, gusts, temperature, dew point, humidity, horizontal visibility); a red
  three-line dew sentence; a 5-row hour strip; attribution — about 600 px.
- **Friction:** the variables that decide imaging (total cloud, dew spread, wind) have the same weight
  as horizontal visibility or humidity. ADR-012 forbids good/bad colouring, so the card cannot rank by
  colour.
- **Evidence:** RENDER VERIFIED (U1 `p1_planner_dark_sec_night_weather`).
- **Why a trade-off:** cloud layers are genuinely valuable to experienced imagers (high cloud matters),
  and "no score" is a product decision. For a novice the card is a wall of numbers.
- **Competing for attention:** the capture plan below it.

#### UX-07 — The rig's nine reference rows are shown on every visit
**LIKELY UX PROBLEM** · reach: every session

- **User is trying to:** plan tonight with a rig they chose weeks ago.
- **Interface presents:** pixel scale, FOV, NPF, max sub, target size, focal length, focal ratio,
  sensor, tracking — about 630 px (screen 2).
- **Friction:** static specs push the plan down on every visit. Target size and FOV fit matter per
  target; the rest rarely change between sessions.
- **Evidence:** RENDER VERIFIED (U1 section shot); CODE VERIFIED (`home_screen.dart:138-168`).
- **Why only likely:** some users may consult pixel scale or NPF each time; unobserved.
- **Competing for attention:** the plan and its fit.

#### UX-08 — The altitude chart: format, overlap, span and red mode
Mixed · reach: every session

| Aspect | Classification | Evidence |
| --- | --- | --- |
| Axis labels always use a **24-hour** clock ("20:01"); every other time on the page follows the device setting, so on a 12-hour device the page mixes "20:01" with "10:46 PM"; ticks fall on odd minutes (the night starts at mean solar noon) | CONFIRMED | U2 native render; `altitude_chart_widget.dart:273-286` hand-formats HH:mm |
| Labels are drawn over the curves ("Horizon (0°)" over the Moon line; "20:01" over the target curve) | CONFIRMED | U2 native render |
| Hairline seams stripe the Day and Dark bands (288 adjacent rectangles) | CONFIRMED on host and native Impeller; device UNVERIFIED | U1, U2 |
| The axis spans noon to noon, so sunset to sunrise occupies about 60 % of the width on this November night (less in summer) | DESIGN TRADE-OFF (context vs focus) | U2; ADR-007's night definition |
| In red mode the Day, Twilight and Dark bands become near-identical dark reds; only the window and target curve stay distinct | REQUIRES USER TESTING (real darkness) | U2 `n_planner_field_fold` |

#### UX-09 — The capture plan's visual structure
**CONFIRMED UX PROBLEM** (consistency) · **LIKELY** (delete) · reach: every plan edit

- **Interface presents:** four stacked heading levels ("Capture Plan" 22 sp bold → "Inputs" 18 sp →
  "Sequence Plan" 16 sp → block rows); a card with its own margin (16 px inset) and radius (16) unlike
  every other card (radius 6, no inset); uppercase types ("LIGHT [L]"); "100x 60.0s" with a decimal
  where the rest of the app writes "60 s"; a red delete icon on every row, with no confirmation or undo.
- **Friction:** heading inflation without added structure; the red icons are the most salient items in
  the card; one mistap deletes a block irrecoverably.
- **Evidence:** RENDER VERIFIED; CODE VERIFIED (`capture_plan_widget.dart:27-186`).
- **Why real:** measurable inconsistency. The delete is minor data loss, and IA §3 asks for no silent
  loss; the impact frequency is unobserved.

### 4.2 Navigation and information architecture

#### UX-10 — Tonight's drill-downs land at the top of a five-screen page
**CONFIRMED UX PROBLEM** · reach: every session

- **User is trying to:** see the weather (or Moon, or night) details behind Tonight's one-line summary.
- **Interface presents:** Night, Moon and Weather rows with chevrons; each opens the planner **at its
  top**. The weather card is at y = 1,806 (screen 3), the sky card at screen 4.
- **Friction:** the chevron promises "more about this"; it delivers a different page and two to three
  screens of scrolling.
- **Evidence:** CODE VERIFIED (`tonight_home_screen.dart:216`, all three rows call `openPlanner`);
  RENDER VERIFIED (§3.2).
- **Why real:** a broken information scent on the main entry screen.

#### UX-11 — Tonight cannot change the night
**CONFIRMED UX PROBLEM** (deviation from `IA_WIREFRAMES.md` §4) · reach: occasional (planning ahead)

- **User is trying to:** look at tomorrow or next weekend.
- **Interface presents:** "Night of Tue, Nov 10" on the site card, which opens the site list. The date
  picker exists only in the planner (screen 3). The wireframe had a night picker in Tonight's header.
- **Friction:** Open planner → scroll two screens → Session Date → pick → OK → back to Tonight (five
  taps plus scrolling) to see another night's summary.
- **Evidence:** CODE VERIFIED (`tonight_home_screen.dart:139-166`); `IA_WIREFRAMES.md` §4.

#### UX-12 — A replaced draft becomes unreachable
**CONFIRMED UX PROBLEM** · reach: occasional, but silent

- **User is trying to:** start a fresh plan, or duplicate this one for another night.
- **Interface presents:** "New session" (Tonight, and "+" in the planner's app bar) and "Duplicate for
  another night" start a new draft immediately, without a prompt. Pure drafts are never listed in
  Sessions (owner decision, TASK 11.3), so the previous unsaved draft cannot be reopened.
- **Friction:** from the user's view, the old plan is gone — a silent loss IA §3 rules out.
- **Evidence:** CODE VERIFIED (`session_plan_viewmodel.dart:255-268`; `library_viewmodels.dart:141-153`);
  TEST VERIFIED at the data level by 04/RT-05 (4 drafts stored, 0 listed).

#### UX-13 — After Start, Tonight shows the run and a second, identical-looking session
**CONFIRMED UX PROBLEM** · reach: every run

- **User is trying to:** glance at Tonight during a run.
- **Interface presents:** the "In progress: Great Orion Nebula" card, then — further down — a "Draft"
  card for the same target, with "Fits", "Open planner" and **Start** (the planner continues on a copy,
  ADR-016 §10). Pressing that Start is refused ("Another session is in progress").
- **Friction:** two cards about the same target, one of which offers an action that will fail; nothing
  explains that the second is a copy for later.
- **Evidence:** RENDER VERIFIED (U1 `p2_tonight_run_dark`); CODE VERIFIED (`start_session.dart:29-43`).

#### UX-14 — Library lists double as pickers
**LIKELY UX PROBLEM** · reach: occasional

- **User is trying to:** browse or manage targets and rigs in the Library.
- **Interface presents:** Library → Targets opens the same screen as the planner's picker ("Select
  Target"); tapping a row **sets it as the current plan's target** and leaves the screen. Editing is a
  small pencil icon.
- **Friction:** browsing changes the plan; a planned session becomes "Planned, unsaved changes".
- **Evidence:** CODE VERIFIED (`app_router.dart:126-128`; `target_selection_screen.dart:355-358`,
  `equipment_selection_screen.dart:677-680`); documented in ADR-015 §7.
- **Why only likely:** whether users expect "tap = choose for tonight" in the Library is unobserved.

### 4.3 Status, warnings and states

#### UX-15 — The default state raises false alarms
**CONFIRMED UX PROBLEM** · reach: first run and every plan with the seeded rig

- **User is trying to:** see a first plan.
- **Interface presents:**
  1. The seeded rig's tracking is "Unknown", so NPF treats it as possibly untracked: the default
     example plan's LIGHT block shows, in red, "Longer than the recommended max sub (0.5 s if
     untracked) — stars may trail". The LRGB plan shows the same three-line warning on **all six**
     light blocks. The rig editor defaults tracking to "Unknown" too.
  2. With no target, Tonight shows **"No window" in the error colour** ("Choose a target to see
     tonight's windows").
  3. "Current Altitude −27.5°": the target's altitude **now**, not on the planned night, and negative
     rather than "below the horizon".
- **Friction:** red is used for a missing input and for an assumption the user never made. Users learn
  that red means "ignore", which weakens the real warnings (dew, doesn't fit, stale forecast).
- **Evidence:** RENDER VERIFIED (U1, U2); CODE VERIFIED (`capability_calculator.dart:106-126`;
  `night_text.dart:68-73`; `night_conditions_viewmodel.dart:254-262`, which uses `_clock.nowUtc()`).
- **Why real:** a fresh install hits all three.

#### UX-16 — "Tight" is drawn weaker than "Fits"
**CONFIRMED UX PROBLEM** · reach: every plan

- **User is trying to:** notice when the plan is marginal.
- **Interface presents:** `FitText.color` maps Fits → `primary`, Tight → `tertiary`, Doesn't fit / No
  window → `error`. In this theme `primary` is the body-text colour (white, or #37352F in light), and
  Flutter's `tertiary` falls back to `secondary` — grey #9B9B9B.
- **Friction:** the warning state is **less** prominent than the success state; the success state is
  indistinguishable from body text.
- **Evidence:** CODE VERIFIED (`night_text.dart:68-73`; `app_colors.dart`; Flutter
  `color_scheme.dart:1139` `tertiary => _tertiary ?? secondary`); RENDER VERIFIED (U2: "Fits" in plain white).

#### UX-17 — Moon wording hides the useful fact
**CONFIRMED UX PROBLEM** · reach: every session

- **Interface presents:** Tonight: "Moon up from noon–4:46 PM, 9:31 AM (+1)–noon." The planner's
  window list already says the clear thing: "Moon down (3 % lit)".
- **Friction:** the useful fact — the Moon is down during the dark hours — must be inferred from two
  daytime intervals whose "noon" ends are artefacts of the noon-to-noon night.
- **Evidence:** RENDER VERIFIED; CODE VERIFIED (`night_text.dart:47-56`).

**State coverage (reviewed, no separate finding):** loading (spinners, "Loading forecast…"), error
(`LoadFailureView` with retry; bootstrap retry), empty (planner, Sessions, candidates, sites) and
unknown ("Unknown", "no forecast", "—") states exist and are worded consistently with SI-008. The gaps
are the ones above and 04/RT-03 (a newer-schema database gives a generic error).

### 4.4 Terminology, labels and formatting

#### UX-18 — One concept, several names
**CONFIRMED UX PROBLEM** · reach: every session

| Concept | Names in the UI |
| --- | --- |
| The rig | "rig" (Library, Welcome, tooltips, errors); "Equipment" (planner section, picker title "Select Equipment"); "Equipment profile" (empty state, "Add Equipment Profile") |
| The dark period | "Dark (Sun below −18°)" (Tonight); "Dark (Sun ≤ −18°)" (chart); "Astro Dusk / Astro Dawn" and "True Night Window" (sky card); "Darkness limit" (settings) |
| Time the plan needs in the window | "Time needed in window" (planner); "Window load" (session detail) |
| "Window" | the imaging window (planner) **and** the noon-to-noon night key "Window: 12:01 PM – 12:01 PM (+1)" (session detail, next to "Window 1") |
| The log | tab "Sessions"; snackbar "Session saved to Logbook!" |

- **Evidence:** CODE VERIFIED (string grep of `lib/presentation`); RENDER VERIFIED.
- **Why real:** readers cannot tell that differently named values are the same; the noon-to-noon
  "Window" exposes an internal concept (ADR-007's night key) as if it were an imaging window.

#### UX-19 — Numbers and times in three formats
**CONFIRMED UX PROBLEM** · reach: every session

| Quantity | Formats seen on screen |
| --- | --- |
| Durations | "1h 40m" (budget), "4 h 42 min" (fit reason), "6 h 30 min" (usable) — on one card |
| Percent | "Moon Illumination: 3%" vs "3 % lit" |
| Exposure | "60.0s" (block list) vs "60 s" (elsewhere) |
| Clock | 12-hour text vs 24-hour chart axis (UX-08) |
| Right ascension | h:m:s in the target editor; degrees ("83.819°") in the session detail |
| Minus sign | "−18°" (typographic) vs "-18°" (ASCII, session detail and settings) |

#### UX-20 — Visible content defects
**CONFIRMED UX PROBLEM** · reach: varies

| Defect | Where | Evidence |
| --- | --- | --- |
| "Focal ratio: f/5.555555555555555" (an unformatted double) | Session detail | U1 render; `session_detail_screen.dart:235-237` |
| "Optional overheads are saved now and will be applied to the capture plan in a later update." — they **are** applied since TASK 5.4 | Settings | U1 render; `settings_screen.dart:189-193` vs `capture_budget_calculator.dart:287-336` |
| "Tap a target to open its night on Home." — there is no Home; a tap sets the current plan's target and returns to Tonight | Candidates footer | U1 render; `tonight_candidates_screen.dart:260-262` |
| Helper text truncated: "Recorded only; it does not change the …" | Add-block dialog | U1 render |
| "Notes: Notes: none" | Session detail | U1 render; `session_detail_screen.dart:340` |
| Two sources of truth in one card: an inline "Bortle ?" dropdown next to "add Bortle or SQM in the site editor" | Sky card | U1 render; `sky_darkness_widget.dart:48-59,119-122` |

### 4.5 Forms and data entry

#### UX-21 — The site editor requires an unused number and can discard silently
**CONFIRMED UX PROBLEM** (elevation) · **LIKELY** (discard) · reach: first run

- **User is trying to:** add their observing site by hand.
- **Interface presents:** name, latitude, longitude, **elevation (required)**, time zone, Bortle, SQM,
  notes; Save is a check icon at the top right; back leaves without a prompt.
- **Friction:** elevation feeds no calculation (it is stored in snapshots only), yet the form cannot be
  saved without it; a novice may not know it. Back after typing discards the site.
- **Evidence:** CODE VERIFIED (`site_form_input.dart:10-20`; grep: no domain service reads elevation);
  CODE VERIFIED (`site_editor_screen.dart` has no `PopScope`).
- **Why it matters:** friction with no payoff on the first-run path. Elevation being required is an
  existing data-model decision (FEATURE_STATUS F-07).

#### UX-22 — The rig editor is the steepest step for a casual user
**LIKELY UX PROBLEM** (novice) · **DESIGN TRADE-OFF** (verified-specs policy) · reach: first run

- **User is trying to:** add their own camera and lens.
- **Interface presents:** one dialog with 15 text fields and one dropdown. Six are required (name,
  resolution W and H, pixel size, focal length, focal ratio or diameter). Hint values ("6248",
  "4176", "3.76") render almost as bright as entered values, so the empty form looks pre-filled. Pixel
  size appears as **two fields bound to one controller**. Rotation is asked but used by no calculation.
  Tracking defaults to "Unknown", which later triggers UX-15.
- **Friction:** a casual user must look up pixel pitch and resolution; there is no camera or lens list.
- **Evidence:** RENDER VERIFIED (U1 `p1_rig_editor_fold`); CODE VERIFIED
  (`equipment_selection_screen.dart:124-619`; grep: `rotationDeg` only stored).
- **Why a trade-off:** the specs are genuinely needed for FOV and pixel scale, and the project ships
  only verified seeds (TASK 8.5). The friction is real; its size for real users is unobserved.

#### UX-23 — Plan editing needs typing
**DESIGN TRADE-OFF** · reach: every plan edit

- The add-block dialog asks for exposure and count as typed text, and shows binning and a
  "sensitivity setting (for your records)" on every add. IA §3 prefers pickers and steppers "at the
  telescope". Planning is often done indoors, which makes this a trade-off rather than a defect; at
  night it means a keyboard in red mode.

### 4.6 First run and onboarding

#### UX-24 — The first run shows choices the user never made
**CONFIRMED UX PROBLEM** (target) · **LIKELY** (rig) · reach: first run

- **User is trying to:** set up site, rig and target.
- **Interface presents:** the Welcome page lists "2. Your rig: ZWO ASI2600MC + example 72 mm f/5.6
  refractor" and "3. A target: Great Orion Nebula" as already set — the app pre-selected them. Tonight
  shows two separate site prompts ("No site set" and "Set up your observing site…").
- **Friction:** steps look complete; the user may plan with a rig that is not theirs. The rig's name
  says "example"; the target has no such label (02/ENG-15).
- **Evidence:** RENDER VERIFIED (U1 `p0_welcome_fold`, `p0_tonight_nosite_fold`).

### 4.7 Execution and reconciliation

#### UX-25 — Reconciling counts is one tap per frame, and the estimate is not shown
**CONFIRMED UX PROBLEM** · reach: every completed run

- **User is trying to:** log how many frames were actually taken.
- **Interface presents:** per block, "Confirmed: 12" and "Rejected: 0" with −/+ buttons; no number
  entry; no mention of the tracker's estimate ("About 52 more"). "Complete session" is below the fold
  (y = 1,000–1,056 on a 915 px view).
- **Friction:** if Finish was tapped without "Accept 52", logging those frames takes 52 taps; the user
  may complete with 12 without realising.
- **Evidence:** CODE VERIFIED (`results_screen.dart:308-362`); RENDER VERIFIED (U1 `p2_results_dark`).
- **Why real:** long runs mean large counts — five hours of 60 s subs is 300 frames — and the ±1
  path scales with them.

#### UX-26 — The resume prompt: four stacked actions, and a different "Finish"
**CONFIRMED UX PROBLEM** (inconsistency) · reach: after an app restart during a run

- **Interface presents:** Abandon (first), Finish, Pause now, Keep going, stacked vertically. This
  Finish completes the session at once; the tracker's Finish opens reconciliation (04/RT-10).
- **Friction:** the same label does two different things; the destructive option is listed first.
- **Evidence:** RENDER VERIFIED (U1 `p2_resume_prompt_fold`); CODE VERIFIED (`resume_run_dialog.dart:79-151`).
  Whether this is intended is an open owner question (01 §F item 7).

#### UX-27 — Tracker: what is missing at the moment of need
**LIKELY UX PROBLEM** · **REQUIRES USER TESTING** (keep-screen-on) · reach: every run

- **Interface presents:** a clear count and estimate, and an outlook: astronomical dawn, "Target below
  its limit: now", moonrise (here at 9:31 AM, after dawn), window left, plan left.
- **Friction:** when a run starts before the window (the app allows it), the user sees "below its limit:
  now" as one plain line, but not **when** the target rises above it (the window opens at 10:46 PM).
  Keep-screen-on is off by default and sits under "More" (an owner decision: opt-in); whether field
  users find it before the screen sleeps is unobserved.
- **Evidence:** RENDER VERIFIED (U1/U2 tracker); CODE VERIFIED (`execution_screen.dart:233-258`, `:478-498`).

#### UX-28 — The tracker's buttons expose no tap action to accessibility services
**LIKELY UX PROBLEM** (mechanism verified; TalkBack behaviour UNVERIFIED) · reach: screen-reader users, every run

- **Interface presents:** each of the seven controls is wrapped in `Semantics(button: true, label: …,
  excludeSemantics: true)` with no `onTap`. Excluding the child removes the button's own tap action.
- **Friction:** the semantics tree of the whole tracker page contains **one** tap action (U1). On
  Android, Flutter marks a node clickable (`ACTION_CLICK`) only if it has a tap action
  (`BaseRoleConfigurator.configureTappable`), so TalkBack's double-tap is likely to do nothing on +1,
  Pause, Finish.
- **Evidence:** CODE VERIFIED (`execution_screen.dart:333-350`; engine
  `BaseRoleConfigurator.java:103-114`); RENDER VERIFIED (U1 semantics count). The existing tests check
  labels only (`execution_screen_test.dart:301`), and the sweep's guidelines only examine nodes that
  have a tap action, so neither can catch this. The recorded TalkBack walkthrough (TASK 15.3) is still
  outstanding.

### 4.8 Sessions, logbook and candidates

#### UX-29 — "What can I image tonight?" ties at the top
**CONFIRMED UX PROBLEM** (on the audited night) · **PREFERENCE** ("(no score)") · reach: every use

- **User is trying to:** pick a target for tonight.
- **Interface presents:** 119 of 164 targets, sorted by usable time. On the audited night all six
  visible rows read "10 h 55 min" (the whole dark window), so the top of the list is effectively
  alphabetical. Rows are three lines ("Nebula · 6:21 PM – 5:16 AM (+1) · max 84° · Moon down in the
  windows · fills 1 % of the frame"). The header ends "(no score)", a developer-facing assurance.
- **Friction:** the default order does not discriminate on a long winter night; frame fill — a strong
  discriminator for the user's rig — is buried mid-row.
- **Evidence:** RENDER VERIFIED (U1, U2); CODE VERIFIED (`tonight_candidates_screen.dart`).
- **Why real:** the list exists to answer the question the ties leave open. The degree varies with
  season and latitude.

#### UX-30 — Sessions: the filter bar outweighs the list
**CONFIRMED UX PROBLEM** (minor) · reach: every visit

- **Interface presents:** seven chips on three rows (160 px, fixed above the list) — shown even with
  one session — then cards of six to eight lines ("Equipment: …", "Site: …", "Planned Frames: 100",
  "Actual Frames: 12", "Integration: …", "Edit results").
- **Evidence:** RENDER VERIFIED (list starts at y = 216 vs 56 on other tabs); CODE VERIFIED
  (`logbook_screen.dart:99-266`). The wireframe's "Open / Done" grouping was not built.

### 4.9 Visual design, typography, buttons and accessibility (compact)

| ID | Finding | Class | Evidence |
| --- | --- | --- | --- |
| UX-31 | **200 % text:** the weather hour strip overflows (12 RenderFlex overflows: the legend column by 62 px, each hour column by 94 px, inside a fixed 130 px box); a range label runs into its value ("Low cloud (below 3 km)3–18 %"); the planner becomes 11.6 screens; Tonight's session card and Start move to screen 2 | CONFIRMED | U1 run log; `weather_forecast_widget.dart:404-445`, `:320-332` |
| UX-32 | The accessibility sweep never renders a forecast (its fake returns none), so UX-31 was invisible to it — a test-coverage gap, reported here because it hides a UX defect | CONFIRMED | `accessibility_test.dart:33,87` |
| UX-33 | **Heading inflation:** section headers (22 sp bold) outrank the app-bar title (18 sp, w600) and card titles; four heading levels in the capture plan | CONFIRMED | Code; U2 renders |
| UX-34 | **Button hierarchy:** on Tonight "Open planner" is filled and **Start** outlined; in the planner's bottom bar "Save Session" has almost no visible boundary next to the bright Start pill (native render) | REQUIRES USER TESTING (which action is primary); LIKELY (Save affordance) | U1/U2 renders |
| UX-35 | **Icon-only app-bar actions** in the planner: "+" (new session, no prompt — easily read as "add block") and a copy icon (duplicate for another night) | LIKELY | Code; renders |
| UX-36 | **Tappable summary cards** (target, rig) have no chevron or edit icon; the date card has a pencil | LIKELY | Renders |
| UX-37 | The save **snackbar** is a bright white bar in the dark theme (red in field mode) | LIKELY (night use outside field mode) | U1 `p1_planner_saved_snackbar_fold` |
| UX-38 | **Swipe-only delete** (sessions, targets, rigs) — confirmed by a dialog, but not discoverable | REQUIRES USER TESTING | Code |
| UX-39 | **Red mode:** outlined buttons (#660000) and card borders (#330000) on black are near-invisible; the chart's bands collapse; secondary red is below WCAG AA (documented, ARCHITECTURE B16) | DESIGN TRADE-OFF + REQUIRES USER TESTING (darkness) | U2 renders |
| UX-40 | The red-mode toggle and the planner's actions sit at the top of the screen (hard one-handed reach); red mode is toggled rarely, so this may be acceptable | PREFERENCE / REQUIRES USER TESTING | Renders |

---

## 5. Three perspectives

### 5.1 Novice or casual astrophotographer

- **Goal:** "What can I photograph tonight, and how?" with the gear they own.
- **What works:** the Welcome page explains why the site matters and asks for location permission
  only on request; Tonight's summary is short; "What can I image tonight?" exists; every excluded
  period has a plain-language reason.
- **Where it breaks down:**
  - **Set-up is the steepest part.** A site typed by hand needs an elevation that changes nothing
    (UX-21); the rig needs pixel pitch and resolution with no camera list (UX-22); and the first run
    pre-selects a target and an example rig, so steps look done (UX-24).
  - **The first plan greets them with red.** "0.5 s … stars may trail" on a 400 mm refractor whose
    tracking they never set (UX-15).
  - **The planner's vocabulary:** integration vs acquisition vs time needed in window vs session budget;
    NPF with "|δ| 3°"; pixel scale; √N; Bortle and SQM; T − Td; "Horizontal visibility (not transparency)".
    Each is labelled honestly; together they are a lot to meet on one page (UX-05).
  - **Choosing a target:** 119 candidates with the same usable time at the top (UX-29).
- **Net:** density matters most for this user in the **planner**, and complexity in **set-up**.

### 5.2 Experienced astrophotographer

- **Goal:** fit a multi-filter plan into tonight's real window, run it with few taps, log it accurately.
- **What works:** transparent budget with assumptions; atomic placement and a reason for every
  outcome; the one-tap "Fill tonight's window"; cloud layers; the tracker's estimate and "Accept N";
  immutable snapshots; export.
- **Where it breaks down:**
  - **Every visit scrolls past reference data** to reach the plan (UX-01, UX-07); the verdict is at the bottom.
  - **Multi-block plans get noisy:** one warning per light block (UX-15); typed dialogs for each block
    and no templates (UX-23; see pattern P8).
  - **Logging accuracy costs taps:** ±1 reconciliation (UX-25).
  - **Trust erodes on small defects:** "f/5.5555…" and RA in degrees in their log (UX-19, UX-20);
    Settings saying overheads are not applied when they are (UX-20).
  - **Missing control:** the optional Moon and cloud gates have no Settings UI (TD-050, from audit 01).
- **Net:** this user tolerates — and values — density. The problem for them is **order, repetition
  and taps**, not the amount of information.

### 5.3 Operating outside at night

- **Goal:** start, glance, confirm frames, pause for clouds, finish — one-handed, maybe gloved, in red.
- **What works:** red mode reaches dialogs, sheets and snackbars and survives a restart; the tracker
  is one screen with a 36 sp count and seven 56 dp controls in the bottom 204 px; Save/Start stay in a
  bottom bar in the planner; every target passes the 48 dp guideline.
- **Where it breaks down:**
  - **Scrolling a five-screen planner in the dark** to change a block (UX-01).
  - **Red mode loses the chart's darkness bands and most outlines** (UX-08, UX-39) — needs a darkness test.
  - **Keep-screen-on** is opt-in under "More" (UX-27); **"window opens in"** is missing when a run starts early.
  - **Finishing:** More → Finish → scroll → Complete; counts ±1 (UX-25).
  - **Typing** exposure and count in red mode (UX-23).
  - **Screen readers:** tracker buttons likely not activatable (UX-28).
- **Net:** the field screens are mostly right; the gaps are specific and testable.

### 5.4 Taps per core action (from code; typing and scrolling noted separately)

| Core action | Path | Taps | Also needs |
| --- | --- | --- | --- |
| Start tonight's ready plan | Tonight → Start | **1** | — |
| See whether the plan fits | Tonight (card) | **0** | — (planner: scroll 4 screens) |
| Pick a suggested target, then start | Tonight → What can I image tonight? → row → Start | 3 | Scanning a 20-screen list |
| Pick a named target | Tonight → Open planner → target card → search → row → Start | 5 | Typing |
| Plan another night | Tonight → Open planner → (scroll) Session Date → day → OK | 4 | Scroll 2 screens |
| Add a capture block | Open planner → (scroll) + → exposure → count → Add | 5 | Scroll 4 screens; typing |
| See tonight's weather detail | Tonight → Weather row | 1 | Scroll 2 screens to the card |
| Confirm frames | +1 per frame, or Accept N | 1 per frame, or 1 | — |
| Pause with a reason | Pause → reason | 2 | — |
| Finish and log | More → Finish → (scroll) Complete session | 3 | ±1 per corrected frame |
| Red mode | App-bar icon (Tonight, planner, tracker) | 1 | — |
| First site by hand | Set site → Add site → name, lat, lon, elevation → Save | 7 | Typing; knowing elevation |
| Add own rig | Library → Rigs → + → ~6 required fields → Save | ~10 | Typing; knowing sensor specs |

---

## 6. What works and should be preserved

These results come from the same evidence and should constrain any change.

- **Tonight is a real summary**: 1.1 screens and 110 words, with the fit, its reason, usable time and
  Start on the first screen at 100 % text.
- **The tracker is glanceable and thumb-first**: one primary action (+1), estimate plus "Accept N",
  every control 56 dp in the lower quarter, complete in red.
- **Honesty is visible and consistent**: unknowns say unknown, no scores, a reason for every excluded
  period and for "no window"; assumptions are one tap away; the forecast states its age and offline
  state. Experienced users rely on this for trust.
- **Recovery paths exist**: "Fill tonight's window", retry on load failures, confirmations on
  destructive deletes and abandon, autosave with a failure banner.
- **The four-tab architecture** (Tonight · Sessions · Library · Settings) is simple, keeps state per
  tab, and matches the product's loop.
- **Tap targets**: the Android 48 dp guideline passes on every screen, including states the existing
  sweep does not cover.

---

## 7. External references

Each reference is a product with a documented or observable mechanism for handling complex
information while keeping the primary workflow simple. Claims come from the cited vendor
documentation; none is called "successful" — only the mechanism is described. All text is
paraphrased.

### R1 — N.I.N.A. (astrophotography acquisition suite)
| Field | |
| --- | --- |
| **Pattern** | Separate simple and advanced modes over **one engine**, with a one-way conversion and templates |
| **Problem it solves** | Most users need "target + exposures per filter"; a minority need loops, conditions and triggers |
| **Mechanism** | The legacy "Simple Sequencer" is a UI wrapped around the same engine as the "Advanced Sequencer"; a button converts a simple sequence into an advanced one; in the simple UI, autofocus options sit in expandable groups showing a summary; saved sequences can be set as a template that pre-populates new sequences |
| **Evidence** | N.I.N.A. docs: "From Legacy To Advanced" and "Simple Sequencer overview" (fetched); the template behaviour from a search excerpt of the docs' sequencer pages — Appendix C |
| **Why it may apply** | Same domain and user split. Shows a mode split need not fork the logic (AstroPlan's domain is already UI-independent) |
| **Downside / risk** | Two UIs to design, test and document; users may not discover the advanced one; N.I.N.A.'s conversion overwrites existing advanced content; AstroPlan's honesty rules would have to hold in both modes |

### R2 — Android for Cars (Android Auto / Automotive app quality guidelines)
| Field | |
| --- | --- |
| **Pattern** | An explicit **attention budget** for constrained contexts |
| **Problem** | Interaction while attention belongs elsewhere (the road) |
| **Mechanism** | Task flows are capped at five steps, with three or fewer recommended; showing a new template or new content counts as a step, a refresh does not; long list-based chains are discouraged |
| **Evidence** | Android Developers, "Plan task flows" (Cars UX requirements) |
| **Why it may apply** | At the telescope attention is on the rig and the sky. A written step budget for the field screens (tracker, Tonight in red mode) would make "glanceable" testable |
| **Downside / risk** | Driving is a far stricter context; copying the numbers blindly could over-simplify tasks that are legitimately longer (reconciliation) |

### R3 — ForeFlight (aviation flight planning)
| Field | |
| --- | --- |
| **Pattern** | Order by **consequence**, with translated and raw views |
| **Problem** | Pilots face long weather and NOTAM briefings where the critical item can be buried |
| **Mechanism** | The graphical briefing is split into sections navigated in a standard sequence that starts with adverse conditions, then synopsis, current conditions and forecasts; translated text is offered alongside the raw text |
| **Evidence** | ForeFlight product page "Briefing" (fetched); the Pilot's Guide was found but not read |
| **Why it may apply** | AstroPlan's planner could lead with what can break tonight (doesn't fit, dew, clouds in the window, stale forecast) instead of by data type (UX-01, UX-02, UX-06); "translated vs raw" parallels "summary vs all variables" |
| **Downside / risk** | "Adverse first" implies a severity ordering — close to the good/bad judgement ADR-012 avoids. It would need facts-only triggers (e.g. "hours with dew spread ≤ margin", which the app already computes) |

### R4 — Apple Health
| Field | |
| --- | --- |
| **Pattern** | A **user-pinned summary**, highlights, and a separate place for all data |
| **Problem** | Hundreds of data types; each user cares about a few |
| **Mechanism** | The Summary tab shows categories the user pinned, then highlights; tapping one drills into that category; all data is reachable through Browse |
| **Evidence** | Apple Support, "Use the Health app on your iPhone or iPad" |
| **Why it may apply** | Weather variables and rig specs: a short, chosen set in the planner, the rest one tap away (UX-06, UX-07) |
| **Downside / risk** | Personalisation conflicts with PD-14 for Tonight (a fixed view by decision); defaults still have to be good for users who never customise |

### R5 — iPhone Camera, Night mode
| Field | |
| --- | --- |
| **Pattern** | **Conditional disclosure**: a control or value appears when conditions make it relevant |
| **Problem** | Advanced options clutter the common case |
| **Mechanism** | Night mode turns on automatically when the camera detects low light, and its icon indicates the state; the user can adjust or override it |
| **Evidence** | Apple Support, "Use Night mode on your iPhone" |
| **Why it may apply** | AstroPlan already does this for NPF (only for untracked or unknown rigs). The same rule could hide the zone caption when the site zone equals the device zone, show a moonrise countdown only before dawn, or show "current altitude" only for tonight (UX-03, UX-15, UX-27) |
| **Downside / risk** | Content that appears and disappears can surprise; the rule must be predictable and documented |

### R6 — Halide Mark II (pro camera app, Lux)
| Field | |
| --- | --- |
| **Pattern** | **Automatic by default, manual on demand**, within thumb reach |
| **Problem** | Pro controls overwhelm casual use; hiding them frustrates experts |
| **Mechanism** | The viewfinder defaults to automatic; manual exposure is revealed by an edge swipe or a mode icon; the design principles stress staying out of the way and keeping controls within thumb reach |
| **Evidence** | Lux blog, "Pro. Camera. Action. Introducing Halide Mark II" |
| **Why it may apply** | The capture plan could default to "fill tonight" (the app already computes it) with block-level detail on demand; thumb reach matches IA §3 |
| **Downside / risk** | Gesture-revealed controls are hard to discover; a camera viewfinder is a single task, the planner is several |

### R7 — Binance Lite / Pro (finance)
| Field | |
| --- | --- |
| **Pattern** | A **self-selected simplified mode** |
| **Problem** | Beginners and active traders need very different amounts of information |
| **Mechanism** | Lite shows less information on the main page and basic features; Pro adds advanced tools; users can switch between them at any time |
| **Evidence** | Binance blog, "Unpacking Binance Lite and Pro" |
| **Why it may apply** | Evidence that a Basic/Advanced split is used in data-heavy consumer apps |
| **Downside / risk** | The vendor page describes the modes, not their outcomes. Users may pick the wrong mode or not know the other exists; two modes double the test surface. For AstroPlan, hiding assumptions in a "basic" mode would clash with the integrity rules |

### R8 — Microsoft 365 Simplified Ribbon
| Field | |
| --- | --- |
| **Pattern** | **Collapsible density** with a persistent toggle and escape hatches |
| **Problem** | A full command surface costs space; most sessions use few commands |
| **Mechanism** | The simplified ribbon shows the most-used commands in one line; a caret switches to the classic ribbon; hidden commands stay reachable through dropdowns, an overflow menu and command search |
| **Evidence** | Microsoft Support, "Use the Simplified Ribbon" |
| **Why it may apply** | A planner "compact / full" toggle that keeps everything reachable (overflow) rather than removed |
| **Downside / risk** | A setting many users never find; the product must still work well in its default |

### R9 — Things 3 (task manager, Cultured Code)
| Field | |
| --- | --- |
| **Pattern** | **Details tucked away until needed** |
| **Problem** | Optional metadata (tags, checklist, dates) clutters a simple item |
| **Mechanism** | An opened to-do shows only its text; the extra fields sit in a corner until the user asks for them |
| **Evidence** | Cultured Code, Things features page |
| **Why it may apply** | The add-block dialog (binning, gain "for records"), the rig editor's optional fields (RAW size, rotation), the site editor's notes (UX-22, UX-23) |
| **Downside / risk** | Hidden optional fields are filled less often — acceptable for records, not for inputs that change results |

### R10 — Apple Watch Workout views
| Field | |
| --- | --- |
| **Pattern** | **Few metrics per in-activity view**, more views on demand |
| **Problem** | Glanceability while moving |
| **Mechanism** | Each workout view shows a small set of metrics (four by default on Ultra, a fifth optional); users choose which views are included and their order (Apple Support); further views are reached by swiping or the Digital Crown (third-party guide, search excerpt) |
| **Evidence** | Apple Support, "Customize workout views on Apple Watch" |
| **Why it may apply** | Supports keeping the tracker to a few large values; a per-view metric budget could guide the tracker's outlook card (UX-27) |
| **Downside / risk** | Customisation adds settings; defaults must be right for the field |

### R11 — Clear Outside (astronomy weather, First Light Optics)
| Field | |
| --- | --- |
| **Pattern** | **Summary row above detailed rows**, hour by hour |
| **Problem** | Astronomers need cloud layers, but a quick read first |
| **Mechanism** | Hourly columns with a traffic-light indicator, total/low/mid/high cloud rows, other weather rows, and a drop-down for more detail |
| **Evidence** | First Light Optics blog on Clear Outside; clearoutside.com |
| **Why it may apply** | Same domain and variables as AstroPlan's weather card (UX-06); the hour-by-hour grid parallels the hour strip |
| **Downside / risk** | **Conflicts with ADR-012** (no good/bad colouring, no score). Only the structure — summary row, layers below — transfers; the colours do not |

### R12 — Telescopius (target planning)
| Field | |
| --- | --- |
| **Pattern** | **Threshold filters plus a non-ranked selection** — choice support without a score |
| **Problem** | Many targets qualify; a ranking implies a judgement the tool cannot make for every user |
| **Mechanism** | Search filters such as "at least N hours above X° between astronomical dusk and dawn"; saved equipment profiles; the "What's in the Sky Tonight" list is a **random** pick among objects meeting fixed thresholds (e.g. at least 30° for an hour, size limits per type, Moon distance), because staff state preferences cannot be predicted |
| **Evidence** | Telescopius forum (staff answer on "What's in the Sky Tonight"; filter walkthrough); RASC Hamilton guide |
| **Why it may apply** | Directly addresses UX-29's ties within the no-score rule: thresholds on usable minutes, size and frame fill, then an order that makes ties obvious |
| **Downside / risk** | Random order is non-deterministic, which CLAUDE.md asks to avoid in calculations (a UI order is not a calculation, but tests need a seed); thresholds are more controls |

### R13 — PhotoPills (photography planner)
| Field | |
| --- | --- |
| **Pattern** | **Swipeable information panels** over a primary view; **equipment from a model list** |
| **Problem** | Many astronomical facts, one phone screen |
| **Mechanism** | The Planner has top panels (swipe between them) over a map with a time bar; each panel carries one topic (Sun/Moon position, Milky Way, shadows, …). The NPF calculator ("Spot Stars") lets the user choose a camera make and model and fills sensor data |
| **Evidence** | PhotoPills User Guide (search excerpt; direct fetch refused with HTTP 403); Fstoppers article on the NPF rule |
| **Why it may apply** | Panels: one topic at a time instead of stacked cards. A camera list: the rig editor's biggest barrier (UX-22) |
| **Downside / risk** | Panels hide all but one topic (discoverability); a camera database conflicts with the verified-seed policy (TASK 8.5) unless sourced and marked "reported" |

### Principles (not products)
- **Nielsen Norman Group, progressive disclosure:** put what users frequently need in the initial view,
  decide the split from task analysis or usage data, label the way to the secondary level clearly, and
  avoid more than two levels — deeper designs are typically hard to navigate.
- **Apple HIG, disclosure controls:** use disclosure controls and indicators to reveal related content,
  and hint that more exists instead of hiding it without trace.

---

## 8. Candidate solution patterns (hypotheses — not chosen)

These are directions to test, not recommendations. They combine; several could apply to different
screens. The table after the list maps each to the findings it touches. "Removal" appears in none of
them: every item currently shown would remain reachable.

**P0 — Consistency and defect pass, no structural change.** Show the session's identity and state in
the planner (UX-04); chart axis format and label overlap (UX-08); capture-plan visual consistency
(UX-09); no Start on the copy while a run is in progress (UX-13); default tracking and the
"No window" state (UX-15); fit colours (UX-16); Moon wording (UX-17); vocabulary and formats
(UX-18/19); visible defects (UX-20); form defects — duplicated pixel field, hint contrast, truncated
helper (UX-22/23); tracker semantics (UX-28); 200 % overflow (UX-31). *Risk:* low; does not touch
UX-01/02/03. *Tests:* regression plus a 200 % sweep with a forecast. *Constraint check:* none.

**P1 — Answer first (summary → details).** A compact status at the top of the planner (or pinned
under the app bar): night, fit, usable time, end time, the one blocking reason, and the session's
state. Everything below it becomes supporting detail. *Refs:* R3, R4. *Risk:* one more element if
nothing below shrinks. *Tests:* first-click and time-to-verdict tests. *Constraint check:* compatible.

**P2 — Re-order the planner by decision flow.** Night and site → target and opportunity → plan and
fit → conditions detail → rig reference. *Refs:* R3. *Risk:* changes ADR-015's "same sections, same
order" — owner approval. *Tests:* A/B of two orders; card sorting.

**P3 — Collapsible technical sections with informative summaries.** For example: weather collapsed to
total cloud, dew hours and wind range with "All variables"; the rig card to name, FOV and pixel scale;
the √N help behind an info button; the sky card merged into the opportunity card. Summaries must
state facts, not verdicts. *Refs:* R8, R9, NN/g (at most two levels). *Risk:* hidden content is found
less; collapsed state must persist per user. *Constraint check:* owner decision on whether "visible"
integrity text may be one tap away (section 2).

**P4 — Detail screens instead of stacked cards (drill-down).** Weather, Night & Moon and Rig get their
own screens; Tonight's rows and the planner's summaries link to them. Fixes UX-10 directly. *Refs:* R4,
R13 (panels are a variant). *Risk:* more navigation; context switches in the dark. *Tests:* tree test
of where users expect each fact.

**P5 — Contextual disclosure by rule.** Show an item only when its condition holds: zone caption only if
the site zone differs from the device zone; moonrise only before dawn; dew line only with risk hours;
"current altitude" only for tonight; "window opens in" only before the window. *Refs:* R5. *Risk:*
unpredictable if rules are unclear. *Tests:* scenario walkthroughs across states.

**P6 — Separate Basic and Advanced modes.** Two presentations over the same ViewModels. *Refs:* R1, R7.
*Risk:* high: two UIs to design and test; users in the wrong mode; honesty rules must hold in both;
the evidence here shows the problem is concentrated in one screen, which argues for a narrower fix
first. *Tests:* only after P0–P5 are measured.

**P7 — Settings-based visibility (a density preference).** A compact/full toggle for the planner, or
user-chosen weather variables. *Refs:* R8, R10, R4. *Risk:* many users never change settings;
conflicts with PD-14 if applied to Tonight. *Tests:* default-only usability.

**P8 — Presets and templates.** Capture-plan templates (e.g. OSC one filter; LRGB; narrowband), a
"duplicate block" action, and rig creation from a camera/lens list. *Refs:* R1 (templates), R13
(camera list), R12 (equipment profiles). *Risk:* a spec database needs sourcing and provenance (TASK
8.5); templates can encode wrong assumptions. *Tests:* time-to-first-plan for novices; plan-edit time
for experts.

**P9 — Experience-aware onboarding.** Ask at first run whether the rig tracks, and how the user images
(camera and lens on a tripod, tracker, guided mount), to set defaults (tracking, template, which
sections start expanded). *Refs:* R7 (self-selection). *Risk:* wrong self-classification; defaults must
be easy to change later. *Tests:* first-run study with novices.

**P10 — An attention budget for field screens.** A written limit (steps per task, items per screen)
for the tracker and red-mode Tonight, checked in review and tests. *Refs:* R2, R10. *Risk:* rigid rules
may block legitimate tasks (reconciliation). *Tests:* field test in darkness, with gloves.

| Finding cluster | P0 | P1 | P2 | P3 | P4 | P5 | P6 | P7 | P8 | P9 | P10 |
| --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |
| Answer buried, order, repetition (UX-01–03) | | ● | ● | ● | ● | ◐ | ◐ | ◐ | | | |
| No status or identity in the planner (UX-04) | ● | ● | | | | | | | | | |
| Drill-down, night picker (UX-10, UX-11) | | ◐ | | | ● | | | | | | |
| Drafts, duplicate card, Library pickers (UX-12–14) | ◐ | | | | ◐ | | | | | | |
| False alarms, fit colours (UX-15, UX-16) | ● | ◐ | | | | ◐ | | | | ◐ | |
| Always-on explanations, weather, rig card (UX-05–07) | | | | ● | ● | ● | ● | ● | | ◐ | |
| Chart, capture-plan visuals (UX-08, UX-09) | ◐ | | | | | | | | ◐ | | |
| Vocabulary, formats, defects (UX-17–20) | ● | | | | | | | | | | |
| Forms and set-up (UX-21–24) | ◐ | | | ◐ | | | | | ● | ● | |
| Tracker and reconciliation (UX-25–28) | ◐ | | | | | ◐ | | | | | ◐ |
| Candidates, Sessions (UX-29, UX-30) | ◐ | | | ◐ | | | | | | | |
| Accessibility and red mode (UX-31–40) | ◐ | | | | | | | | | | ◐ |

● addresses directly · ◐ addresses in part

**Decisions the owner must make before choosing:**
1. Who is the primary user for 1.0 — the manual imager of MASTER_ROADMAP §3.1, or also the casual
   beginner? P6 and P9 only make sense for the second.
2. May integrity text (assumptions, √N help, heuristics) be one tap away rather than always expanded?
   This decides P3.
3. May the planner's section order change (ADR-015)? This decides P2.
4. Is a sourced "reported" camera/lens list acceptable under TASK 8.5? This decides part of P8.
5. Should Tonight get the wireframe's night picker (UX-11), and should the planner show the session's
   state as the wireframe did (UX-04)?

**What to test first (cheap, before any structural change):** a five-second test of Tonight and of the
planner's first screen ("what is the plan's status?"); a first-run study with two or three novices (set
up site, rig, first plan); a darkness test of red mode, including the chart and the tracker; the TalkBack
walkthrough already required by TASK 15.3 (UX-28).

---

## 9. Items to record in the source-of-truth documents (not done here)

Per CLAUDE.md ("record, don't fix"), these should be entered by the task that takes them; this audit
changed no source-of-truth document.

| Item | Suggested register |
| --- | --- |
| Settings copy says optional overheads are not yet applied (they are, since TASK 5.4); `DATA_MODEL.md` B-table line for the optional overheads says "stored, not yet consumed" | TECH_DEBT (content); DATA_MODEL Part B correction |
| `f/5.555555555555555` and RA in degrees in the session detail | TECH_DEBT |
| Weather hour strip overflows at 200 % text; the accessibility sweep does not cover forecast states | TECH_DEBT; TEST_PLAN § 15.3 |
| Tracker controls expose no tap action to accessibility services | TECH_DEBT (accessibility); TEST_PLAN TalkBack row |
| Tonight has no night picker; the planner shows no session state — deviations from `IA_WIREFRAMES.md` | DECISIONS (implementation deviation under ADR-015) |
| Candidates footer refers to "Home" | TECH_DEBT (content) |
| Fit-state colours (Tight rendered weaker than Fits) | TECH_DEBT |
| Replaced drafts unreachable (UX view of 04/RT-05); duplicate session card after Start | FEATURE_STATUS known issues |

---

## 10. Evidence gaps

1. **No human evidence.** No novice, experienced or field user was observed; every perspective is an
   expert review with measurements.
2. **No device evidence.** Renders are host and native Windows; DPI, OLED black, touch, TalkBack and
   Android system dialogs (location permission, date picker) are unobserved.
3. **No darkness test.** Red-mode legibility of the chart, outlines and secondary text is unverified.
4. **One viewport and locale.** 412 × 915 dp, en-US with a 12-hour clock; 360 dp phones, 24-hour
   locales and non-English text were not measured.
5. **Synthetic forecast and one night.** Candidate ties (UX-29) depend on season and latitude.
6. **No analytics.** Which planner sections users actually read is unknown — NN/g's advice to split by
   frequency needs data the app does not collect (by design: no analytics).
7. **One reference could not be fetched directly** (PhotoPills, HTTP 403); its mechanism is taken from
   the vendor's search excerpt and a third-party article.

---

## Appendix A — Screen inventory (as rendered)

| Screen | Purpose | Main content | Primary action (placement) |
| --- | --- | --- | --- |
| Tonight | "What can I image tonight, is my plan ready?" | Run card (when running); site and night; Night / Moon / Weather rows; session card with fit, reason, usable time; two quick actions | "Open planner" (filled, mid-screen); "Start" (outlined) |
| Candidates | Choose a target for tonight | Sort and type dropdowns; two filter chips; 3-line rows with usable time | Tap a row (sets the current plan's target, returns to Tonight) |
| Session planner | Build and check the plan | Eight sections, 5–6 screens (§3.2) | Save / Start (bottom bar) |
| Tracker | Track a run | Phase, block, count, estimate, outlook | +1 (filled, bottom); six more controls; More sheet: keep-screen-on, Finish, Abandon |
| Results | Reconcile and complete | Planned vs actual; ±1 per block; notes; optional conditions | Complete session (below the fold) |
| Sessions | Every saved session | Seven filter chips; cards of 6–8 lines; swipe to delete | Tap a card (detail) |
| Session detail | One session's record | Snapshot sections (night, site, target, rig, budget, weather), plan vs actual, notes, progress | Edit results / Open tracker; Plan again; Share; Export |
| Library | Reusable things | Rigs, Targets, Sites, Progress | — |
| Rigs / Targets | Manage and select | Cards with specs or type; pencil to edit; swipe to delete | Tap = select for the current plan |
| Sites | Manage sites | Current position; use GPS / map; saved sites with radio, edit and delete | Add site (FAB) |
| Site editor | Create or edit a site | Name, lat, lon, elevation (required), zone, Bortle, SQM, notes | Save (check icon, top right) |
| Settings | Planning preferences | Sliders with help; darkness limit; optional overheads; red mode; place names; backup; About | — |
| Welcome | First run | Three steps (site, rig, target), each skippable | Done (bottom) / Skip (top) |

## Appendix B — Probe scenario and reproduction

- **Probes (deleted from the repository; copies kept outside it):**
  `%TEMP%\claude\C--Users-zalub-OneDrive-Desktop-Astro-Planner-Astro-Planner\9c4df79a-9103-4875-9edd-f5504a6a6795\scratchpad\ui_audit\probes\`
  — `ui_render_probe_test.dart` (U1; place under `test/` to run with `flutter test --no-pub`) and
  `native_render_probe_test.dart` (U2; place under `integration_test/` and run with
  `flutter run --no-pub -d windows <file>`). The renders and `metrics.txt` are in the sibling
  `shots\` and `native\` folders. The scratchpad is session storage and may not persist.
- **Scenario:** Ljubljana (46.05° N, 14.51° E, 300 m, `Europe/Ljubljana`); clock 2026-11-10 17:00 UTC
  (18:00 local); the real 164-object catalog and the seeded rig; the default draft (M42, example plan
  L 60 s × 100, darks 60 s × 20, flats 2 s × 20); a synthetic forecast on whole UTC hours with every
  variable present. Tracking scenario: saved, started at 19:30 UTC, 12 frames confirmed, viewed at
  20:40 UTC. LRGB scenario: 7 blocks added (L/R/G/B 120 s, Ha 300 s, darks from library, flats outside
  the window).
- **Measurements:** exact content height by summing the main viewport's sliver extents on a
  412 × 14,000 view; words and tap actions from the semantics tree (merged nodes counted once); the
  Android tap-target guideline from `flutter_test`; element positions from the laid-out tree.

## Appendix C — Sources

In-repository: `docs/audit/01_ROADMAP_COMPLIANCE.md`, `docs/audit/04_RUNTIME_AUDIT.md`, `CLAUDE.md`,
`docs/PRODUCT_SPEC.md`, `docs/IA_WIREFRAMES.md`, `docs/MASTER_ROADMAP.md`, `docs/DECISIONS.md`
(ADR-015, ADR-016), `.agents/rules/05-ui-design.md`, `lib/presentation/**`, `lib/core/theme/**`,
`test/presentation/accessibility_test.dart`. Flutter SDK `material/color_scheme.dart`; engine
`shell/platform/android/io/flutter/view/BaseRoleConfigurator.java`, `AccessibilityBridge.java`.

External (retrieved 2026-09-25):
- N.I.N.A. — [From Legacy To Advanced](https://nighttime-imaging.eu/docs/master/site/sequencer/advanced/simpletoadvanced/); [Simple Sequencer overview](https://nighttime-imaging.eu/docs/master/site/sequencer/simple/simple/); [Advanced Sequencer overview](https://nighttime-imaging.eu/docs/master/site/sequencer/advanced/advanced/)
- Android Developers — [Plan task flows (Cars)](https://developer.android.com/design/ui/cars/guides/ux-requirements/plan-task-flows)
- ForeFlight — [Briefing](https://foreflight.com/products/foreflight-mobile/weather/briefing/)
- Apple Support — [Use the Health app](https://support.apple.com/en-us/104997); [Use Night mode on your iPhone](https://support.apple.com/en-us/102519); [Customize workout views on Apple Watch](https://support.apple.com/guide/watch/customize-workout-views-apd6b0679060/watchos)
- Lux — [Introducing Halide Mark II](https://www.lux.camera/pro-camera-action-introducing-halide-mark-ii/)
- Binance — [Unpacking Binance Lite and Pro](https://www.binance.com/en/blog/markets/unpacking-binance-lite-and-pro-which-app-mode-is-for-you-1745375179341051400)
- Microsoft Support — [Use the Simplified Ribbon](https://support.microsoft.com/en-us/office/use-the-simplified-ribbon-44bef9c3-295d-4092-b7f0-f471fa629a98)
- Cultured Code — [Things features](https://culturedcode.com/things/features/)
- First Light Optics — [Clear Outside weather forecasts for astronomers](https://www.firstlightoptics.com/blog/clear-outside-weather-forecasts-for-astronomers.html); [clearoutside.com](https://clearoutside.com/)
- Telescopius — [What's in the Sky Tonight parameters (forum)](https://forum.telescopius.com/t/what-are-the-parameters-for-whats-in-the-sky-tonight/855); [Finding targets (forum)](https://forum.telescopius.com/t/finding-targets-to-get-enough-subs-for-astrophotography/17); [RASC Hamilton guide](https://www.hamiltonrasc.ca/exploring-the-cosmos-with-telescopius-a-comprehensive-guide-for-astrophotographers/)
- PhotoPills — [User Guide](http://www.photopills.com/user-guide) (search excerpt; fetch refused); Fstoppers — [Using the NPF rule](https://fstoppers.com/apps/using-npf-rule-photographing-night-skies-504525)
- Nielsen Norman Group — [Progressive Disclosure](https://www.nngroup.com/articles/progressive-disclosure/)
- Apple Developer — [HIG: Disclosure controls](https://developer.apple.com/design/human-interface-guidelines/disclosure-controls)
