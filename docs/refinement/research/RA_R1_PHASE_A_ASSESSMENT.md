# RA.R1 — Phase A: repository reconciliation and owner review

> **Status:** RA.R1 report (Phase A), completed 2026-10-17. Analysis only:
> application code, tests, existing governance documents and decisions were **not changed**. This is not an owner
> decision and not an implementation approval. The next step is RA.R2 (Phase B), on request only.
> **Date:** 2026-10-17. **Code:** `main` @ `b1df679` (= `origin/main`) plus the uncommitted
> documentation edit of 2026-10-17 (CLAUDE.md, PROGRESS, POST_ROADMAP_PLAN, DECISIONS,
> PRODUCT_DIRECTION, `.agents/rules`, `ENGINEERING_GUARDRAILS.md`, `prompts/PRODUCT_REASSESSMENT.md`).
> **Task specification:** `docs/refinement/prompts/PRODUCT_REASSESSMENT.md` (RA.R1). The path from the owner's
> request `docs/refinement/owner-review/PRODUCT_REASSESSMENT_TASK.md` **does not exist** (see K1).
> **Owner inputs:** `review-01 10 2026 ….md` and six images (folder `Desktop\52`, outside the repository),
> the `moonlit-main` project (same directory). All six images and the project were reviewed.

## 0. How to read

**Evidence levels** (Stage 11 vocabulary): `CODE` — read in the current code in this session (with `file:line`);
`DOC` — documentation/decision only; `WEB` — external source with access date; `OBS` — owner observation
on the device (not reproduced here); `HYP` — hypothesis/inference requiring verification;
`UNVERIFIED` — needs a phone or a person. Code is not evidence of usability (Stage 11).

**Finding statuses:** `CONFIRMED` (the code explains the observation) · `PARTIAL` · `BY DECISION` (behaviour
is intentional, per an approved decision; a change = an owner decision in RA.D) · `EXISTS, UX UNPROVEN` ·
`NOT IN PRODUCT` · `UNVERIFIED`.

**Not done:** full gate, tests, builds, on-device runs (per the RA.R1 specification). No
previously issued PASS is reopened (V3/V6); the new findings below are candidates, not Stage 11 blockers,
except the explicitly marked CI (K3).

Three read-only code audits were performed by separate subagents (onboarding/Home; planner/Capture;
weather/Moon/Logbook/Library/Settings); key claims were rechecked manually
(`tonight_home_screen.dart:51-56, 97-100`, `capture_block_dialog.dart:129-150`,
`example_capture_plan.dart:7-24`, `plan_status.dart:59-76`, `capture_assumptions_panel.dart:111-115`,
`open_meteo_forecast_parser.dart:15-27`).

---

## 1. Summary

1. **Functionally the product is nearly complete; visually and in hierarchy it is not.** Capture Plan, time
   budget, fit, √N, storage (conditionally), Logbook, Library, backup/export, weather and Moon exist
   (`CODE`). Usability has not been proven by a single independent human test (S6.E UNVERIFIED), and the owner
   is now for the third time (08 → review 2026-09-28 → review-01.10.2026) describing the same impression
   «сыро/плоско/перегружено» ["raw/flat/overloaded"]. The previous process mostly classified such remarks as
   "preference" or "belongs to a later Stage". This is the main systemic conclusion (K16).
2. **Most "bugs" from the review are previously approved decisions**, not defects: the example plan (RD-04),
   exposure proposed from the previous light block (ADR-020 P2), absence of WB/focus (ADR-020 W1/F1),
   Binning/ISO-gain with class Unknown (ADR-020 C1 + "example rig stays Unknown" by the owner's choice),
   the Home order "plan first" (ADR-019, RG-05 T1), the deferred logo (S9.10). Changing them requires
   explicit decisions in RA.D naming the decision being replaced.
3. **Problems actually confirmed by code:** a flash of Tonight before Welcome (push after the first frame);
   Skip = Done; an empty Home header with only the field mode icon; an almost empty planner top card that
   repeats "no target" three times; the example plan itself produces the warning "No flats for: L"
   (`HYP` from reading the code); when the block type is changed to Flat/Bias the light exposure remains (`HYP`);
   the outdated label "Change in Planning Settings"; in Library rigs/targets have no visible Delete button
   (contrary to the RD-09 rule).
4. **Scientific contradiction in the owner's wording:** «примерный уровень SNR» ["approximate SNR level"] and the concept chart with
   an absolute SNR = 10.1 contradict the CLAUDE.md invariant (√N is relative only). A decision and
   research are needed, not a UI edit.
5. **Operational contradiction:** PROGRESS says "not pushed", but `origin/main` = `b1df679`
   (PR #1 merged 2026-10-16), the repository is public, and **all 3 CI runs failed**; the latest:
   "1840 tests passed, 1 failed, 2 skipped" (`WEB`, GitHub API, 2026-10-17). The local gate of S11.C2
   was green on Windows.
6. **Sequencing before release:** a redesign will affect the UI-dependent Stage 11 rows (sweep, E2E keys,
   TalkBack, phone runs). It is reasonable to run the S11.6 phone checks **after** the accepted
   UI changes, otherwise they will have to be repeated (I05).

---

## 2. Verified baseline

| Item | Fact | Level |
| --- | --- | --- |
| Stages 0–10 | Closed (1 and 2 — owner waiver; 6 and 7 — V5 revalidation in the same chat) | `DOC` PROGRESS |
| Stage 11 | In progress: S11.1–S11.5, S11.C1, S11.C2 done; **S11.6 (phone) and S11.7 (readiness) open** | `DOC` |
| Code | `b1df679` = `origin/main` (merge PR #1 `develop` → `main`, 2026-10-16 23:32 +03:00); local `develop` is 49 behind | `CODE` git |
| Remote repository | `github.com/Buffur/Astro-Planner`, **public**, GPL-3.0 | `WEB` api.github.com, 2026-10-17 |
| CI | Runs #1 (`836bbdf`, 2026-09-29), #2 (PR), #3 (`b1df679`, 2026-10-16) — all **failure**; step `dart run tool/check.dart`; annotation "1840 passed, 1 failed, 2 skipped"; which test is unknown (logs require authentication). Also warnings: Node 20 deprecated; `ubuntu-latest` → Ubuntu 26 from 19.10.2026 | `WEB` |
| Last local gate | PASS at S11.C2 (1 844 tests, 2 skip; host E2E 2 + 1; Flutter 3.47.4, Windows) | `DOC` PROGRESS |
| Schema | v25 | `DOC` |
| Device | Phone: M1–M4 (early builds); emulator: L1–L6, L8 (S11.3). Core L10, TalkBack H6/H7, perf M3/M4, signed release N5 — **not performed** | `DOC` |
| Owner (blocks release) | upload key/signing (16.2); privacy policy 404 + contact (16.3, O9); RD-01/TD-088; S11P-03 (Play services location in a GPL app); formal trademark check (OD-07); Play closed test ≥12 testers for 14 days (Q2) | `DOC` |
| Deferred by owner | S9.10 logo, S9.11 licence (RG-12), S9.12 identity (RD-01) — 2026-09-30 | `DOC` |

---

## 3. Review coverage matrix

The "Proposal" column is the agent's recommendation for RA.R2/RA.D/RA.P, **not a decision**.

### RA-A — Product

| ID | Owner observation / proposal | Status | Evidence | Related decision | Proposal |
| --- | --- | --- | --- | --- | --- |
| RA-A01 | A lightweight planner-organizer; the features look raw/overcomplicated | EXISTS, UX UNPROVEN | The core exists (`CODE`, sections F, G); there is no human verification: S6.E UNVERIFIED (`evidence/STAGE_6_FIVE_SECOND_TEST.md`); three owner reviews with similar complaints | PRODUCT_DIRECTION §1, §5; ADR-019 | RA.R2: competitive analysis + visual quality criteria; RA.P: acceptance with screen renders that the owner reviews |
| RA-A02 | The main thing is the Capture Plan: the resulting integration | EXISTS | `CaptureBudgetCalculator` (ADR-009), `FitAnalyzer`; "Integration", "Capture ends" in `plan_status.dart` | ADR-009, CALC-25/26 | Keep; work on presentation only |
| RA-A03 | … «примерный уровень SNR» ["approximate SNR level"] | **BY DECISION / conflict** | Only the relative √N over light frames is shown; the help states explicitly that this is not the image SNR (`capture_budget_summary.dart:155-158`) | CLAUDE.md invariant; SI-003; Stage 11 "√N stays relative" | RA.R2: whether absolute SNR can be estimated honestly (which inputs: aperture, QE, sky brightness, target surface brightness) and how to present the uncertainty; RA.D: keep relative or add an optional model with explicit assumptions |
| RA-A04 | … «сколько это будет весить» ["how much it will weigh"] | PARTIAL | Empirical only: rig RAW size × frames; without a size — "Unknown" (`capture_budget_calculator.dart:290-295, 370-373`); size is manual input or one DNG | CLAUDE.md (distinguish theoretical payload from empirical size); **Stage 11: "no theoretical size introduced"**; SI-013 | RA.D: whether to allow a theoretical size (pixels × bit depth, explicitly labelled) as a fallback; this changes a frozen Stage 11 row |
| RA-A05 | … working with records and cataloguing | EXISTS, UX UNPROVEN | Logbook, Progress, Library (section G) | ADR-014, RD-07, RD-14 | See RA-G |
| RA-A06 | Detailed weather and object positions should not have been built — there are analogues | **Direction conflict** | Built per approved decisions: the Weather screen (P6.5), "What can I image tonight?" (RD-10), the altitude chart in the planner (ADR-013) | PRODUCT_DIRECTION §1 questions 1–2 ("What to shoot? When?"); ADR-019; RG-05 | RA.D: for each — keep, collapse into details or remove. Fact: the window and fit **require** target altitude — the calculation remains under any decision; only the presentation is disputed |
| RA-A07 | Analyse existing solutions, compare effectiveness | NO (not done) | Previous research contains no competitive comparison (mentions only in RG-07 and audit 05) | — | RA.R2-R1 (below) |
| RA-A08 | «Все нужные функции уже есть» ["All the needed features already exist"] (claim to verify) | PARTIAL | Almost everything exists. Missing: absolute SNR, WB/focus, a monthly Moon calendar, a multi-day weather overview, an animated splash, a new name/logo | — | Account for in RA.D as explicit additions, not "refinement" |
| RA-A09 | Don't be afraid to take existing solutions | — | Candidates: the Moonlit concept (code **without a licence** → idea only, see RA-E01); Astronomy Engine (MIT) used by Moonlit; icon and animation sets — check licences/GPL compatibility | AC7, COMPLIANCE.md, trap 22 | RA.R2-R8 |
| RA-A10 | Build a Stages→Tasks plan up to release | — | — | RA.P | After RA.D (section 6) |

### RA-B — Onboarding (Welcome)

| ID | Observation | Status | Evidence | Related decision | Proposal |
| --- | --- | --- | --- | --- | --- |
| RA-B01 | The main screen is visible for a second before Welcome | **CONFIRMED** (mechanism); duration UNVERIFIED | Welcome is pushed from Tonight's `build()` via `addPostFrameCallback` (`tonight_home_screen.dart:51-56`); there is no redirect to `/welcome` (`app_router.dart:84-86`); meanwhile `firstRun` is already loaded before `runApp` (`main.dart:160`). Additionally: after the native splash the window `NormalTheme` = `?android:colorBackground` (white/black) until the first Flutter frame | TASK 12.5 (first run), trap 13 | Candidate Task: choose the start route before the first frame (redirect/initialLocation). Low risk; affects the router and first-run tests |
| RA-B02 | Skip is not needed when there is Done | **CONFIRMED** | Skip, Done and system Back call the same `_close` (`welcome_screen.dart:20-29, 39-55`) | TASK 12.5 | Remove Skip (or rename the single button by state: "Later"/"Done") — a UX decision |
| RA-B03 | Larger title | CONFIRMED | Title in the AppBar: 18 sp w600 (`app_theme.dart:26-30`) | DESIGN_SYSTEM type scale | Move into the body in the headline role (as done for Tonight in S6.16) |
| RA-B04 | What to actually ask: geolocation +, device ±, target questionable | EXISTS (3 optional steps: site, rig, target) | `welcome_screen.dart:65-129` | TASK 7.3 (GPS only on tap — owner decision); RD-04 (nothing preselected) | RA.R2-R4; option: site required-in-spirit, instead of choosing a rig — the question "what do you shoot with?" (camera class, see RA-F06), remove target |
| RA-B05 | Simplify bulky descriptions | CONFIRMED | The site step description — 3 sentences with an explanation about the permission (`welcome_screen.dart:65-93`) | PD-12 / privacy (the justification for the permission request must be kept) | Shorten, keeping the meaning "permission only on tap" |
| RA-B06 | Revisit layout, text, colour, buttons | UNVERIFIED (visual) | One scrolling page, flat cards (`#F7F7F5`/`#E9E9E7`), three Outlined + Filled; the light theme by default follows the system (`main.dart:199`) | DESIGN_SYSTEM | Renders of the current screen are needed in RA.R2 (host/emulator) before deciding |

### RA-C — Name, logo, loading

| ID | Observation | Status | Evidence | Related decision | Proposal |
| --- | --- | --- | --- | --- | --- |
| RA-C01 | Similar names already exist — research and a new name are needed | CONFIRMED (collisions found; this is **not** a legal check) | **AstroPlanner** (Paul Rodman, Mac/Windows, a long-standing observation-planning product, >5 000 users per the Xojo case study); **Astro Planner: DarkScout** (iOS); the web tool **Astro Planner** (astro-planner.adfr.io, AstroBin); the Python package **astroplan**. `WEB`, 2026-10-17 | OD-07 (name "Astro Planner", formal trademark search before upload); app id `io.github.chacha12.astroplanner` is permanent after the first upload; RD-01/TD-088 | RA.R2-R8: name candidates + screening (Play, App Store, WIPO/EUIPO/USPTO); RA.D decides the name **and** the fate of the app id before the first upload |
| RA-C02 | The vector direction is liked, the execution is not | BY DECISION (deferred) | Current mark: horizon, altitude arc, red "window", star on `#0B1230` (`drawable/ic_launcher_foreground.xml`, `tool/make_launcher_icons.py`). S9.10 already prepared alternatives (`research/S9.10_LOGO.md`), the owner deferred 2026-09-30 | P9.4 ("the agent never chooses the final mark"); trap 20 | Reuse S9.10 after the name is chosen; final choice — owner |
| RA-C03 | Animated loading screen after the name and logo | NOT IN PRODUCT | Android 12+ splash — a static icon; in Flutter during loading — a bare `CircularProgressIndicator` (`tonight_home_screen.dart:71-72`); no animation packages (pubspec) | P9.4 (do not imitate progress, do not delay startup, reduced motion); `.agents/rules/05` (edit 2026-10-17) | RA.R2-R8: AnimatedVectorDrawable in the system splash vs Flutter animation; startup time budget |
| RA-C04 | Light animations and third-party icons | PARTIAL | Tokens `app_motion.dart` (150/250/1500 ms, 0 with reduced motion); animations in only 3 places; no Hero/AnimatedSwitcher | Same; AC7 licences | RA.R2-R8: icon sets (licence, GPL compatibility, weight) |

### RA-D — Home screen (Tonight)

| ID | Observation | Status | Evidence | Related decision | Proposal |
| --- | --- | --- | --- | --- | --- |
| RA-D01 | Empty top area with a single night mode icon | **CONFIRMED** | `AppBar(actions: [FieldModeButton()])` without a title; "Tonight" moved into the body for wrapping at 200 % (`tonight_home_screen.dart:93-100`) | S6.16 (owner's corrective pass) | Combine the title and the toggle in one body row or a large title, keeping text wrapping |
| RA-D02 | Why date and place first; this is in the planner | CONFIRMED (second block) | `_Context` (card "Site ▾ · night ▾") right after the title; the same `ContextLine` in the planner (`home_screen.dart:82-109`) | ADR-019 §5/§6 (order: status > context > …, owner decision 2026-09-28); the owner himself requested the card in the 2026-09-28 review (item 1.2) | RA.D: demote to a compact caption "for which place/night" (the answer's context must not be lost), selection — in the planner |
| RA-D03 | Weather on top, then the entry to the planner; in the planner remove/minimise weather | **BY DECISION / conflict** | Now: the plan card is above the night card; on Home weather = cloud cover + age (`tonight_home_screen.dart:485-498`); in the planner — a one-line Weather row + Night & Moon in "Conditions" (`home_screen.dart:240-293`) | ADR-019, RG-05 = T1 "Tonight plan-first" (owner decision) | RA.D. Important: cloud cover in imaging windows (ADR-013 annotations, cloud gate) is part of the answer, not a duplicate; only the duplicate row can be removed |
| RA-D04 | Remove "New session" at the bottom — it can be started in the planner | CONFIRMED (the "New plan" button) | `tonight.newSession`: Save/Discard/Cancel → new draft, reset of night/target/blocks, then opening the planner (`tonight_home_screen.dart:522-546`; `plan_lifecycle_viewmodel.dart:255-266`). The same exists in the planner's ⋮ (`home_screen.dart:582-645`) | RD-05 (U1), S6.3 | Removal from Home is functionally safe; affects tests (`tonight_home_screen_test`, `unsaved_plan_prompt_test`, `accessibility_test`) |
| RA-D05 | Required: entry to the planner, basic weather, Moon; what else is needed | EXISTS | Blocks: title, context, "How did it go?" (conditional), "Your plan" + Open planner, Night/Moon/Weather, "What can I image tonight?", New plan | ADR-019 §5 | RA.R2-R5 (synthesis from competitors) |
| RA-D06 | (implicit) "What can I image tonight?" on Home | BY DECISION | Button and candidates screen (`tonight_home_screen.dart:512-515`) | RD-10, RG-05 | Include in question RA-A06 |

### RA-E — Weather and Moon

| ID | Observation | Status | Evidence | Related decision | Proposal |
| --- | --- | --- | --- | --- | --- |
| RA-E01 | The Moon as in the Moonlit concept (mobile version) | NOT IN PRODUCT (data exists) | No phase name, no monthly calendar, no "moon-free hours" heading; there is `MoonDuringDark` (dark time and how long the Moon is above the horizon, CALC-43, `moon_conditions.dart:128-148`) — "dark hours without the Moon" are derivable; the twilight band has no Moon layer and no legend (`sky_darkness_widget.dart:340-400`). **Moonlit:** the repository has no licence for its own code (`WEB` github.com/mmilanta/moonlit, 2026-10-17; the archive contains only vendor licences: Astronomy Engine MIT, Leaflet BSD-2, tz-lookup CC0, GeoNames data CC BY 4.0) | ADR-010 (the Moon is a fact, not an "impact"), CALC-43, SI-009 | Transfer the **concept**, not the code. RA.R2-R3: reconcile definitions (Moonlit: Sun ≤ −18° and the Moon's upper limb below the horizon; AstroPlan: user darkness limit), cost of computing 30 nights |
| RA-E02 | A compact, understandable forecast for the night | PARTIAL | Plenty of data (11 hourly variables: total/low/mid/high cloud cover, precipitation %, wind, gusts, T, dew point, humidity, visibility — `open_meteo_forecast_parser.dart:15-27`), but **only the selected night** is requested (`open_meteo_weather_repository.dart:50-58`); no multi-day overview; the hourly strip — 5 rows | ADR-012 (no rating, no "good/bad" colouring; icons show values) | RA.R2-R2: multi-day "night" cards (cloud cover during darkness + Moon %) from one 16-day request — new requests to the same provider, privacy does not change |
| RA-E03 | Wind, humidity and other important parameters | PARTIAL | Wind, gusts, humidity, dew point, dew risk — in the details (`weather_forecast_widget.dart:319-410`), not on Home. Seeing/transparency absent altogether (Open-Meteo does not provide them) | ADR-012; trap 22 (new provider → privacy + COMPLIANCE) | RA.R2-R2: which parameters matter according to the data (apps + reviews); seeing/transparency sources (e.g. 7Timer, Meteoblue) — a new provider = owner decision |
| RA-E04 | Study apps and reviews | NO | Owner references: MIUI Weather (5 days, 24 h), the app `com.twtapp` (tabs ICON/7Timer/15 Days/Climate/Clear Outside; night cards "cloud cover % + Moon %"), Google Weather, Moonlit, an SNR concept (Instagram) | — | RA.R2-R1/R2 |
| RA-E05 | (invariant) Freshness, gaps, source | EXISTS | States Idle/Loading/OutOfRange/Unavailable/Available, age 3/12 h, cache when offline, "no forecast" for hours without data (`night_weather.dart`, `night_text.dart:25-40`) | ADR-012, `WeatherFreshness`, trap 8 | Any redesign must preserve this |
| RA-E06 | (side finding) The forecast saved in the plan snapshot is not shown anywhere in the Logbook | HYP/CODE | The snapshot stores hourly values (`session_snapshot_builder.dart:246-275`); the record shows only the source and time (`session_detail_screen.dart:333-344`) | ADR-014 | Candidate for RA-G (useful for the catalogue) |

### RA-F — Planner and Capture Plan

| ID | Observation | Status | Evidence | Related decision | Proposal |
| --- | --- | --- | --- | --- | --- |
| RA-F01 | Is the logical chain of building a plan understandable | EXISTS, UX UNPROVEN | Order: "Plan" header + identity strip → PlanStatus → Site·Night → Target → Rig (+Specifications, Tracking) → Capture plan (blocks, budget, √N, storage, assumptions) → "Tonight for this target" → Conditions → Sky darkness → Save plan (`home_screen.dart`) | ADR-019 §6 (order approved by the owner 2026-09-28), RD-06 | RA.R2-R5/R6: compare with step-by-step flows (N.I.N.A./ASIAIR plan, Telescopius) |
| RA-F02 | The planner's top block is empty | **CONFIRMED** (almost empty + repetitions) | `PlanStatus` is always built: "Needs a target" + one sentence + "Integration 0 min" (`plan_status.dart:59-76, 140-150`); "no target" is repeated again in the identity strip and in `_ChooseCard` | ADR-019 "answer first" | Candidate: the empty state as a step-by-step checklist, without zero integration |
| RA-F03 | The block content is run together and unclear | UNVERIFIED (visual) | Blocks are text rows in a column; budget/√N/storage/assumptions are collapsible sections | DESIGN_SYSTEM | Renders in RA.R2 |
| RA-F04 | Remove the example plan button | **BY DECISION** | "Start from the example plan" (`capture_plan_widget.dart:220-244`) inserts L 60 s × 100, Dark 60 s × 20, Flat 2 s × 20 (`example_capture_plan.dart:7-24`). **Defect candidate (`HYP`):** the Flat has no filter → the example itself triggers "No flats for: L" and "No light block uses this filter" (`calibration_match.dart:102-131`) | RD-04 (owner, 2026-09-27) | RA.D. Impact: `PlannerHarness.choosePlan()` uses the example (`test/support/planner_harness.dart:138-144`) — the domain fixture for tests can be kept |
| RA-F05 | When filling in, the exposure is already filled | BY DECISION + defect candidate | A new light block proposes the exposure, ISO/gain and binning of the **last light block** (ADR-020 §5, P2; `session_plan_viewmodel.dart:73-74`); the default filter is "L" (`capture_block_dialog.dart:134`). `HYP`: the exposure controller is filled before the type is chosen, so when switching to Flat/Bias 60 s remains (`capture_block_dialog.dart:139-141, 447-456`) | ADR-020 §5 (P2) | RA.D: keep the proposal, but visually distinguish "proposed" from "entered"; defect — confirm with a probe (permission for a temporary test is needed) |
| RA-F06 | Binning and the ISO/Gain choice remain | BY DECISION (root cause — class Unknown) | Binning is hidden for Phone and DSLR, shown for Astro and **Unknown**; the "ISO · Camera gain" choice — only for **Unknown** (`camera_class.dart:23-39`). The default class is Unknown and is never inferred; the example rig was left Unknown by the owner's choice | ADR-020 §2 (C1), §3 | RA.D: ask for the camera class when creating a rig/in onboarding, put the example rig in a concrete class; inferring the class from import with confirmation — a change to ADR-020 |
| RA-F07 | No focus slider and WB; «стягивать данные из про-режима камеры» ["pull data from the camera's pro mode"] | **BY DECISION / repeat of 08 §15** | No fields. ADR-020: W1 and F1 (not modelled), O0, T0. RG-11 rationale: WB in RAW is metadata, does not affect time/frames/size; focus position is not portable; the app controls nothing. Import from a photo reads exposure and ISO (ADR-017), proposing values from a photo (P3) was rejected | ADR-020 §3, §5; RG-11 §4.4–4.5 | RA.D: W2 (optional WB record for phone/DSLR, no calculation) and F2 (reminder) — low risk; F3/slider — no evidence of benefit. "Pro mode" = a set of record fields per class, not camera control |
| RA-F08 | Build calibration from the lights, do not enter everything again | EXISTS, UX UNPROVEN | L1 inheritance is implemented: Dark — only count and "when it is captured"; Dark flat — from flat; Bias — ISO/gain + binning; Flat — filter + binning (`calibration_match.dart:164-198`); mismatch warnings + "Match the lights" | ADR-020 §6 (RG-10 L1, D1, H1) | Check on the device why the owner perceives this as manual input (possibly the "Add block" path → the type is chosen after the form opens) |
| RA-F09 | Is all the data in Assumptions needed | PARTIAL | 10 rows; almost all mirror Settings; some apply not to all rigs (meridian flip — equatorial mounts, filter change — mono); the "Change in Planning Settings" button is outdated (the screen is called "Settings") (`capture_assumptions_panel.dart:111-115`) | ADR-009 §4; S9.3 | Candidate: show only enabled/affecting assumptions; fix the label |
| RA-F10 | SNR chart concept | **wording conflict** | Now: √N over the frame count (1…max(4, 2N)), without axis labels, per filter×exposure group (`stacking_gain_graph.dart`, `stacking_gain_curve.dart:39-51`). Concept: "SNR vs integration" over time and an absolute "SNR 10.1" | SI-003, CALC-42, Stage 11 | An integration-time axis (frames × exposure) is possible **without** changing the meaning; an absolute value — only through the RA-A03 decision |
| RA-F11 | Separate controls, metadata, input and device control | EXISTS (by decision) | The app does not control the camera/mount; ISO/gain — "for your records" | PRODUCT_DIRECTION §1; ADR-020 | Describe explicitly in RA.R2-R6 |

### RA-G — Logbook and Library

| ID | Observation | Status | Evidence | Related decision | Proposal |
| --- | --- | --- | --- | --- | --- |
| RA-G01 | Does the Logbook fulfil its function? | EXISTS, UX UNPROVEN | Upcoming/Past, search, filters (status, target, site, dates), Record/Edit result, Share, Progress by target, detail with snapshot and Plan vs actual (`logbook_screen.dart`, `session_detail_screen.dart`, `results_screen.dart`) | RG-04, RD-13, P8.5–P8.7 | Phone check L10/H7 (S11.6) after the UI decisions |
| RA-G02 | Does the Library fulfil its function? | EXISTS, UX UNPROVEN | Rigs/Targets/Sites tiles in management mode; search only for targets; "Plan this target" is hidden in the edit dialog (`target_selection_screen.dart:287-295`) | RD-07 | RA.R2-R9 |
| RA-G03 | (finding) No visible Delete button for rigs and targets in the list | HYP/CODE (possible rule violation) | Only swipe or inside the editor; the rule "a deletable item has a visible Delete" (`delete_patterns.dart:12-13`); sites have the button | RD-09 (M + S1) | Candidate corrective Task after confirmation |
| RA-G04 | (finding) Single-record export, Copy, Rename — only inside the detail; export of everything — only in ⋮ | CODE | `logbook_screen.dart:186-212` | P8.7 | RA.R2-R9 |
| RA-G05 | «Проведи тесты» ["Run tests"] | Not performed in this phase | The RA.R1 specification forbids running the gate; existing tests cover the flows on host | V1, PRODUCT_REASSESSMENT | Manual run on the phone — in RA.R2 with permission or in S11.6 |

### RA-H — Settings

| ID | Observation | Status | Evidence | Related decision | Proposal |
| --- | --- | --- | --- | --- | --- |
| RA-H01 | Relevance of the settings | EXISTS (as decided) | 17 rows: Imaging window (min. altitude, darkness limit, Moon gate, Cloud gate), Fit and capture time (margin, time between frames, dither, refocus, filter change, meridian flip, setup), Guidance (NPF k, dew margin), Display (field mode), Privacy (site names), Data (backup), About (`settings_screen.dart`) | S9.3 / D9-3 — **agent decisions under delegation; the owner can revisit any of them** | Revisiting is cheap from a governance standpoint |
| RA-H02 | What to remove | — | Overheads are global although they depend on the rig/mount (a phone's time between frames ≠ an astro camera's; meridian flip — GEM only) | ADR-009 §4 | RA.D: moving some to the rig = a data model change (migration) |
| RA-H03 | What to add | — | No theme choice (system only, `main.dart:199`; for an astro app, dark by default is a question), no units (°C, km/h fixed — `HYP`, to check), no language | — | RA.R2-R10 |

### RA-I — Release

| ID | Observation | Status | Evidence | Related decision | Proposal |
| --- | --- | --- | --- | --- | --- |
| RA-I01 | Reconcile old roadmaps with reality | Done (section 2) | MASTER_ROADMAP closed as a queue by Stage 0; POST_ROADMAP_PLAN + PROGRESS are current | Stage 0 | — |
| RA-I02 | CI | **PROBLEM** | 3/3 runs red; 1 test fails on Linux (K3). Since 2026-10-17 tracked as **TD-104** (`docs/TECH_DEBT.md`): the failure has existed since the first run (`836bbdf`, "1730 passed, 1 failed"), logs require GitHub sign-in | Stage 11 "CI (1.3)"; RD-17 | A separate diagnostic Task (logs needed: the owner can provide them or authorise `gh`) — before RA.P |
| RA-I03 | Owner actions | Open | See section 2 | 16.2, 16.3, OD-07, RD-01, S11P-03, Q2 | Carry into RA.P unchanged |
| RA-I04 | Deferred S9.10–S9.12 | Reopened by the review (name, logo); licence: the wish in 08 §23 «без модификации без разрешения» ["no modification without permission"] is incompatible with GPL-3.0 — unresolved | RG-12 | RA.D |
| RA-I05 | Order of work | — | UI changes invalidate part of the Stage 11 evidence (sweep, E2E keys `tonight.newSession`/`capturePlan.useExample`, TalkBack H6/H7, L10, M3) | V3 | RA.P: redesign → then S11.6/S11.7 on the final build; host rows not affected by the changes keep their PASS |

---

## 4. Contradictions

| ID | Contradiction | Sources | What is needed |
| --- | --- | --- | --- |
| K1 | The specification path from the request does not exist; the actual one is `prompts/PRODUCT_REASSESSMENT.md` (not committed); the review and images are outside the repository | owner request vs FS | Owner: whether to put the review/images into `docs/refinement/owner-review/` (images without personal data) |
| K2 | PROGRESS (uncommitted edit) already says "RA.R1 complete, report in the owner's chat", but this report is not saved in the repository; it also says "Moon concept source project unavailable" — now available | PROGRESS:7, 24 | Treat this document as RA.R1; update PROGRESS only with approval |
| K3 | PROGRESS "Not pushed", RD-17 "push deferred" and the owner action "make the repository public" vs fact: pushed, public, CI red | PROGRESS:18, RD-17; git; GitHub API | Update the records (with approval); CI diagnostics |
| K4 | The direction "no planetarium and no detailed weather" vs PRODUCT_DIRECTION §1 (questions 1–2), ADR-019, RD-10 | review; DOC | RA.D (RA-A06) |
| K5 | «Примерный SNR» ["approximate SNR"] / concept with absolute SNR vs the √N invariant | review; CLAUDE.md; SI-003 | RA.R2 + RA.D (RA-A03, RA-F10) |
| K6 | The expectation «сколько весит» ["how much it weighs"] always vs Stage 11 "no theoretical size introduced"; CLAUDE.md meanwhile permits a theoretical payload when explicitly distinguished | review; POST_ROADMAP_PLAN Stage 11; CLAUDE.md | RA.D (RA-A04) |
| K7 | WB/focus (08 §15 and now) vs ADR-020 W1/F1 | review; ADR-020 | RA.D (RA-F07) |
| K8 | Remove the example plan vs RD-04 | review; RD-04 | RA.D (RA-F04) |
| K9 | Weather first on Home vs ADR-019/RG-05 (plan first) and the owner's own request for a context card (2026-09-28) | review; ADR-019; S6 review | RA.D (RA-D02, RA-D03) |
| K10 | Logo/name: deferred by the owner 2026-09-30 vs requested now; OD-07 "Astro Planner" vs renaming | review; DECISIONS | RA.D (RA-C01, RA-C02) |
| K11 | RD-09 "visible Delete" vs swipe-only for rigs/targets | RD-09; CODE | Confirm, corrective Task |
| K12 | The label "Change in Planning Settings" vs the title "Settings" (S9.3 §4.1); an outdated comment in `example_capture_plan.dart:3` | CODE | Minor fix within a future Task |
| K13 | Table A.1 in POST_ROADMAP_PLAN calls the `pubspec.yaml` description a template — already fixed (`pubspec.yaml:2`) | DOC vs CODE | Historical record; do not rewrite |
| K14 | Systemic: three owner reviews → the same impression; there is no independent human UX verification | 08; review 2026-09-28; review | RA.P: visual acceptance criteria and owner review of renders as a mandatory step of UI Tasks |

---

## 5. Questions for the owner (for RA.D; Phase B can proceed without answers)

1. **Product scope (RA-A06):** the "What can I image tonight?" screens, the altitude chart, detailed weather — keep, collapse into details or remove?
2. **SNR (RA-A03):** only relative √N, or research an optional absolute SNR estimate with explicit assumptions?
3. **Size (RA-A04):** allow a theoretical size (labelled) when the RAW size is unknown?
4. **WB/focus (RA-F07):** revisit ADR-020 W1/F1 (for example, W2 + F2)?
5. **Name and app id (RA-C01):** rename before the first upload? Change the app id?
6. **Order (RA-I05):** do the redesign before the S11.6 phone checks?
7. **CI (RA-I02):** allow diagnostics (logs from you or `gh` sign-in)?
8. **New providers (RA-E03):** allow research of seeing/transparency sources?

---

## 6. Proposed Phase B scope (RA.R2)

Principles: only questions that change the recommendation; primary sources, URLs and dates; reuse
RG-10, RG-11, S9.3, S9.10, S9.12, RG-05/06; a competitive comparison grants no right to copy others' assets.

| # | Question | Closes | Sources / method |
| --- | --- | --- | --- |
| R1 | Competitive analysis: which planning tasks they solve and how they present them (Telescopius, Astrospheric, Clear Outside, PhotoPills, Stellarium Mobile, Sky Tonight, AstroPlanner (Rodman), DarkScout, the app `com.twtapp` from the reference, N.I.N.A. / ASIAIR for the capture plan model) + user reviews (Play/App Store, Cloudy Nights, r/astrophotography), separating anecdotes from data | RA-A01, A06, A07, D05, G01–G02 | Product websites, documentation, reviews |
| R2 | Night weather for astrophotography: which parameters matter; seeing/transparency — sources, licences, terms, reliability; multi-day presentation from one Open-Meteo request | RA-E02, E03, E04, D03 | Open-Meteo, 7Timer, Meteoblue documentation; Clear Outside/Astrospheric |
| R3 | Mobile Moon presentation per the Moonlit concept: reconciling definitions (darkness limit, upper limb, refraction) with ADR-010/CALC-43; cost of computing 30 nights; Moonlit licence (there is none for the code) | RA-E01 | Moonlit README/method, USNO RST defs, AstroPlan code |
| R4 | Minimal onboarding and permission requests (Material/Android guidance) | RA-B04–B06 | Android developers, Material 3 |
| R5 | Home hierarchy and the planner chain (synthesis of R1 + ADR-019) with 2–3 wireframe options | RA-D01–D05, F01–F03 | Synthesis; renders of the current screens (host) |
| R6 | Capture: "pro mode" fields by class (phone: ISO, shutter speed, WB, focus; DSLR; astro cameras: gain/offset/temp), what to record, what to model; honest absolute SNR models (CCD equation: required inputs, uncertainty); √N on a time axis | RA-A03, F05–F10 | Camera documentation/Android Camera2, RG-11, CCD equation literature |
| R7 | Size: theoretical payload by format (RAW bit depth, FITS 16 bit, compression) vs empirical; how competitors present it | RA-A04 | Format specifications (DNG, FITS), RG-01 |
| R8 | Identity: 8–12 name candidates with collision screening (Play, App Store, WIPO/EUIPO/USPTO — without a legal opinion); logo — reuse S9.10; splash (AnimatedVectorDrawable on Android 12+ vs Flutter), startup budget; icon/animation sets — licences and GPL compatibility | RA-C01–C04, A09 | Stores, trademark registries, Android SplashScreen docs |
| R9 | Records: Logbook/Library flows versus competitors + a manual pass on the phone (`.s2check`, with permission) | RA-G01–G04 | Device, R1 |
| R10 | Settings: global vs per-rig overheads; default theme (dark?); units | RA-H01–H03 | S9.3, N.I.N.A. docs |

Outside RA.R2 (separate tasks, your request is needed): CI diagnostics (RA-I02); probes of the defect candidates
RA-F04/F05/G03 (temporary tests = file changes, separate authorisation needed).

---

## 7. Handoff

- **Decisions:** none were made.
- **Evidence:** code `b1df679`; GitHub API and pages (2026-10-17): Actions runs #1–#3,
  `api.github.com/repos/Buffur/Astro-Planner`, `github.com/mmilanta/moonlit`; name collision search
  (xojo.com AstroPlanner case study; apps.apple.com DarkScout; app.astrobin.com topic 216286).
- **Unknown:** which test fails on CI; on-device behaviour (the flash, perception of calibration);
  the visual state of the screens (no renders were taken); the legal status of the name.
- **Coverage:** all 9 areas (RA-A…RA-I), every review observation has an ID and a disposition; visual
  comparisons with the references — at the description level (images reviewed), without renders of the current UI.
- **Next allowed action:** RA.R2 only on the owner's request; do not start implementation.
