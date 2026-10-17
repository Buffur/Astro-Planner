# RA.R2e — Product direction: options and recommendations

> **Status:** outcome of RA.R2 (step R2e), 2026-10-17. This is the options package for gate G2 (RA.D, round 2) and
> the input for round 1 (identity). **Nothing is decided:** the agent's recommendation is not an owner
> decision. Code, tests and existing decisions were not changed.
> **Inputs:** [Phase A](RA_R1_PHASE_A_ASSESSMENT.md) · [R2a market](RA_R2A_LANDSCAPE.md) ·
> [R2b science and Capture](RA_R2B_CAPTURE_SCIENCE.md) · [R2c weather and Moon](RA_R2C_NIGHT_CONDITIONS.md) ·
> [R2d identity](RA_R2D_IDENTITY.md) · ADR-019 §5–§6, ADR-020, RD-04, S9.3.
> **Answer sheet:** [RA_D_DECISION_SHEET.md](RA_D_DECISION_SHEET.md).
> **Onboarding (R4):** Android, "Request runtime permissions"
> (developer.android.com/training/permissions/requesting) and NN/g, "Mobile-App Onboarding"
> (nngroup.com/articles/mobile-app-onboarding/). Both accessed 2026-10-17.

## 0. How to read this

- **Every block has the same structure:** problem (ID from Phase A), recommendation, realistic
  alternative, superseded decision, data and test impact, whether a gate is needed.
- **Principles used to choose the recommendations:**
  1. The owner's direction — a lightweight planner-organizer with the Capture Plan at its center.
  2. The evidence from R2a–R2d.
  3. Minimum cost before release.
  4. CLAUDE.md invariants are not violated: unknown ≠ 0, √N is relative, no night score, provenance.
- **Visual baseline — gap.** Screenshots and renders of the current screens were not provided (the §6
  permissions of the plan were not granted). The wireframes below therefore fix order, content and flow, but not appearance.
  Visual design belongs to the implementation Tasks, with owner review of renders (K14).

## 1. Main conclusion

**R2a:** none of the mobile planners found answers, before leaving home, the question "frames ×
exposures → integration, storage, does it fit in the night". This is AstroPlan's niche (conclusion based on store descriptions).
The closest analogues of this logic are N.I.N.A. and ASIAIR, but they work at the telescope, not during
planning.

Hence the recommended position:

> **AstroPlan — a planner and log for the Capture Plan.** Night conditions (weather, Moon, darkness) are
> compact context for the answer "does my plan fit tonight", not a separate weather product.

What this requires:
- **Nothing useful is removed.** Duplicates are removed, secondary items are lowered in the hierarchy,
  detail screens remain.
- **Mandatory changes fall in four places:** the Capture block, empty states, Home and
  onboarding.
- **Scientific invariants are preserved.** The wish for «примерного SNR» [an approximate SNR] is met through the shape of the chart
  (a curve over integration time), but without an absolute number (§4.1).

## 2. Product scope (RA-A06, K4)

| | Recommendation **S-A: demote, do not remove** | Alternative S-B: remove | Alternative S-C: "all-in-one" |
| --- | --- | --- | --- |
| "What can I image tonight?" | Secondary text button on Home; the screen remains | Remove the screen and the button | Expand |
| Altitude chart in the planner | Remains. The imaging window and fit are impossible without target altitude; more compact presentation | Window list only | — |
| Weather screen (details) | Remains. Gains a nights overview (§5) | Replace with a link to an external app | Add seeing and more |
| What not to do (R2a §5.8) | Planetarium and AR, framing and mosaics, own seeing, light-pollution maps, community, night score index, hardware control | — | — |

- **Why S-A.**
  - The features are already built and verified (Stages 6–10).
  - Removal costs work, tests and migration of habits, and gives the user nothing.
  - The owner called them «сырыми» [raw], not unnecessary.
  - R2a: some users value "all-in-one" (T8), so full removal is a risk with no gain.
- **What changes:** PRODUCT_DIRECTION §1 — wording clarification (questions 1–2 become
  supporting). No data impact.

## 3. Onboarding and launch (RA-B01–B06, RA-C03)

### 3.1 Recommendation O-2′: short Welcome — site + rig

- **Flash (B01).** The route is chosen **before the first frame**: redirect on the already loaded flag
  `firstRun` (`main.dart:160`). Today Welcome is pushed from Tonight's `build()`. This fix
  is needed under any option.
- **Title (B03).** A large title in the body, in the headline role; one subtitle line.
- **Steps (B04).**
  - **"Where do you shoot?"** Two buttons: "Use current position" and "Choose on map or list".
    The permission rationale is one line: "Location is asked only when you tap".
  - **"What do you shoot with?"** Camera class choice (Phone · Camera · Astro camera colour · mono · Not sure),
    then "Choose a rig" or "Add rig" with the class already selected. This is C1-b from R2b §4.6.
  - **The "target" step is removed.** A target is a task, not context. NN/g: onboarding should contain only what
    the app cannot work without or what depends on the user's context.
- **Buttons (B02).** One primary button "Start planning", no Skip. Its role is played by the system Back,
  which now works as "later". Choices are saved immediately.
- **Copy (B05).** No longer than a line; the privacy meaning is preserved (PD-12).
- **Alternative O-1: no Welcome.** The app opens Home directly with a "Set your site" card.
  - This already exists on Tonight; DarkScout and Clear Outside do this (R2a).
  - Less code. But the place for the branded first impression the owner wants is lost.
- **Superseded decisions:** TASK 12.5 (first-run composition). TASK 7.3 ("GPS only on tap")
  is respected.
- **Data:** none. **Tests:** first run, `welcome_screen` tests, `core_loop_test` (first-run step),
  sweep.

### 3.2 Loading screen

Option D6 from R2d, recommendation **S2**:
- AnimatedVectorDrawable of the chosen mark in the Android 12+ system splash, no longer than 1 000 ms
  (developer.android.com, checked 2026-10-17).
- Then, in Flutter, the same mark is shown **exactly as long as the real loading takes**:
  no fake progress, static under reduced motion.
- No new packages needed. Depends on the mark choice (round 1).

## 4. Planner and Capture Plan (RA-F01–F11)

### 4.1 Scientific questions (owner decision required)

| Question | Recommendation | Alternative | Supersedes | Data |
| --- | --- | --- | --- | --- |
| **SNR** (A03, F10, K5) | **O2:** the same √N curve, but on the **integration time** axis and normalized to the plan (√(T/T_plan)): "×1.41 when time doubles". This is the form of the owner's concept without an absolute number | O4 (after 1.0): minimum-exposure hint for astro cameras when read noise is entered | Presentation of CALC-42; SI-003 is preserved | No schema; CALC-42 tests |
| **Absolute SNR** | **Do not introduce.** R2b §2: requires QE, read noise, dark current, filter bandwidth and target surface brightness. None of these is in the model, RG-03 ruled out external specifications, and ±0.5 mag of the target gives a result from 6.9 to 16.3 | O3 with explicit assumptions — not recommended | — | — |
| **Storage** (A04, K6) | **ST3 + ST2-lite.** Size from **any** rig file (currently DNG only). If the size is unknown — an estimate "pixels × 2 bytes, as uncompressed 16-bit DNG or FITS" with this label. Measured size always takes precedence | ST2 full: format and bit-depth fields, migration v26 | Stage 11 line "no theoretical size introduced"; SI-013; ADR-009 §7 | ST2-lite: no schema (pixel dimensions are already stored, `equipment_profile.dart:33-34`). ST2: v26 |
| **Moon-free dark time** (E01) | **MF-b:** darkness ∩ (Moon below the horizon per the displayed rise and set). Matches Moonlit and USNO at −18° | MF-a: as is, with the label "Moon up = center above 0°" | New derived quantity. The Moon gate of ADR-013 is not touched | No schema |

**Incidental finding** (R2b §5.2, verified against code): "Moon above the horizon" in CALC-29/33/43 is
the Moon's center above 0° without atmosphere (`moon_conditions.dart:95`), while the displayed rise and set are computed
with Meeus h₀ (`moon_calculator.dart:408-417`). The discrepancy is 5–10 minutes per event.
Recommended to record as an SI finding. Option MF-c (a single h₀ everywhere) is high risk, owner
decision only.

### 4.2 Capture block

| Item | Recommendation | Alternative | Supersedes | Data |
| --- | --- | --- | --- | --- |
| **Camera class** (F06) | **C1-b + C1-d.** Class is the first question when creating a rig and in onboarding; the example rig gets its class from the cited ZWO page. This also removes Binning and the ISO/Gain choice for phone and DSLR | C1-c: class proposed from metadata with a reason and explicit confirmation | C1-d: the owner's choice "example rig stays Unknown" (ADR-020 §2); C1-c — also "never inferred" | C1-d: seed, new installs only |
| **Prefill** (F05) | **P2b:** each proposed field carries the marker "from block Ha · 300 s ×"; "proposed" style until the field is touched. Default filter by class: None for Phone and DSLR | P2c: empty field with a hint and a "Use" button | Presentation of ADR-020 §5 (within its bounds) | None |
| **WB** (F07) | **W2:** optional record for Phone and DSLR, no calculation, labeled "for your records" | W1: as now | ADR-020 W1 | Block column, v26 |
| **Focus** (F07) | **F2:** reminder "Focus before the first frame" plus the existing refocus in assumptions. A slider (F3) is not supported by evidence: the position does not transfer | F1: as now | ADR-020 F1 | None |
| **«Данные из про-режима»** [data from pro mode] (F07) | **P3′ after 1.0:** "Take from a photo" fills exposure and ISO from metadata with a source marker. The import infrastructure already exists | P3′ in 1.0 | ADR-020 P3 (rejected) | No schema |
| **Calibration** (F08) | **CAL-1:** a single action "Build calibration from lights" — a dark block for each triple (exposure, sensitivity, binning) and a flat block per filter, with suggested counts | CAL-0: UX check on device first | None (within L1) | None |
| **Example plan** (F04, K8) | **Remove the button.** CAL-1 and P2b cover the same "quick start" need. The domain fixture stays for tests (`PlannerHarness.choosePlan`). The "Flat without filter" defect disappears with the button | Move to ⋮ "Fill with an example" and fix the Flat filter | RD-04 (the "Start from the example plan" part) | None; tests with key `capturePlan.useExample` |
| **Time between frames** (H02) | **I1:** global, as now. Moving it to the rig risks double counting (RG-11 §6) | I2: per rig, v26 | — | — |
| **Assumptions** (F09) | Show only **enabled and effective** items plus "Change in Settings" (fix the stale label) | As now | None | None |

### 4.3 Flow and empty states (F01–F03)

**Recommendation.** The conceptual order of ADR-019 §6 is preserved (status → context → target → rig →
plan → windows → conditions), but what fills the screen while there is no plan yet changes:

- **While inputs are missing** — instead of the "Needs a target · Integration 0 min" card and three
  repeats, a **checklist** is shown: ✓ Site · ○ Target · ○ Rig · ○ Capture blocks. Each
  item leads to the relevant choice. The status with a verdict appears once it can be computed.
- **The identity strip** shows the target and night once; the "No target" repeat is removed.
- **"Conditions"** — the duplicate weather row is removed. The cloud annotations in the windows (part of the
  answer) and a single "Night & Moon · Weather" link remain.

**Alternative — step-by-step wizard.** Not recommended: slows editing, and modes were rejected by RG-06.

**Supersedes:** ADR-019 §6 — not the order, but the composition of the empty state; RD-06 ("answer first")
is preserved. **Data:** none.

## 5. Home and night conditions (RA-D01–D06, RA-E01–E06)

**Recommendation H-W: conditions first, plan directly below** (wireframe §8.2):

1. **Header.** "Tonight" plus the subtitle "Kryvyi Rih · Fri 17 Oct ▾" — compact, tap to
   choose site and night. The field mode toggle is on the same row; the empty AppBar is removed.
   The answer's context is not lost.
2. **Night card** (R2c §6):
   - dark window;
   - Moon: phase, %, **Moon-free dark hours in large type** (MF-b) and window type ↘/↗/•;
   - cloud cover (range) with freshness;
   - values row: precipitation (maximum), gusts (maximum), dew hours;
   - → details.
   No verdict and no "good/bad" color (ADR-012).
3. **"Your plan" card:** target, verdict, "Open planner" (primary button).
4. Secondary text button "What can I image tonight?".
5. **"New plan" is removed** from Home (D04). It remains in the planner's ⋮.

**Alternative H-P:** plan first (as now, ADR-019 §5, RG-05 T1), with a more compact night card
placed second. The argument for H-P is "answer first" for a user with a ready plan. The argument for H-W is the owner's direct
wish and the practice of analogues (DarkScout, Clear Outside start with night conditions).

**Supersedes:** ADR-019 §5 (order), RG-05 T1. **Data:** none. **Tests:** Tonight, sweep,
`core_loop_test`.

**Night details** (R2c §7):

| Item | Recommendation | Alternative | Supersedes | Privacy |
| --- | --- | --- | --- | --- |
| **Nights overview (W1)** | One 16-day Open-Meteo request per site. A strip of night cards: cloud cover during dark time, Moon % and Moon-free dark hours, wind, dew | No overview | ADR-012 §4, §6 (cache key) | Same recipient. Update privacy and COMPLIANCE wording |
| **Card composition (W2)** | As above; unknown — "—" | Minimum: cloud cover and Moon | — | — |
| **Monthly Moon calendar (M2)** | In "Night & Moon" details, offline, `Isolate.run` + per-month cache. No "good" highlighting. Time on the phone is an acceptance criterion | Only 7 nights in the overview | — (scope) | None |
| **Night band (M3)** | Moon layer and legend in the twilight band, text alternative | — | — | None |
| **Seeing and transparency (W3, W4)** | **Not in 1.0.** An honest "not forecast here" line and a link the user opens themselves (Clear Outside) | 7Timer ASTRO as opt-in: 72 h, non-commercial, new recipient | ADR-012 §2 and §3 under the alternative | Link: section "Links you open yourself". 7Timer: new recipient |
| **Weather in Logbook (E06)** | Show the night forecast saved in the snapshot in the entry (as a summary) | — | — | None |

## 6. Records (RA-G01–G05)

R2a, theme T1 (≥ 4 sources): users want to see **total integration per target across several
nights** and today track it in spreadsheets. AstroPlan already has "Progress by target" — this is a differentiator
worth showing.

Recommendations:
1. Progress — a **"By target" segment at the top of Logbook**, not a tile (G01).
2. **Visible Delete** for rigs and targets in Library (G03; consistent with RD-09). Confirm first.
3. "Plan this target" — in the target row (menu), not only in the edit dialog (G02).
4. Night forecast in the entry (E06).
5. **After 1.0:** export to AstroBin CSV — reuse of a standard (R2a, F 38). Requires a decision on the
   export format (EXPORT_MANIFEST).

**Alternative:** leave as is. **Data:** none, except item 5 (after 1.0).

## 7. Settings (RA-H01–H03)

1. The S9.3 structure remains: it is logical, and R2a found no better model.
2. **"Appearance":** System · Light · Dark plus field mode. Today the theme is system-only
   (`main.dart:199`); astro apps are usually dark.
3. **Units** (°C/°F, km/h/mph) — after 1.0, if a US English-speaking audience is needed.
4. Overheads — global (I1).

**Alternative:** no changes. **Data:** item 2 — one display setting
(`DisplayPreferencesRepository`, backup key).

## 8. Wireframes (order and content, not appearance)

### 8.1 Welcome (O-2′)

```
┌──────────────────────────────────┐
│ [mark]                           │
│ Plan your night's capture        │  ← headline
│ Two quick things, both optional. │
│                                  │
│ Where do you shoot?              │
│ [◎ Use current position]         │
│ [⌖ Choose on map or list]        │
│ Location is asked only when you  │
│ tap.                             │
│                                  │
│ What do you shoot with?          │
│ (Phone)(Camera)(Astro colour)    │
│ (Astro mono)(Not sure)           │
│ [Choose or add a rig]            │
│                                  │
│ [      Start planning      ]     │
└──────────────────────────────────┘
```

### 8.2 Home (H-W)

```
Tonight                         [☾]
Kryvyi Rih · Fri 17 Oct ▾
┌ Night ───────────────────────────┐
│ Dark 19:42–05:31 (−18°)          │
│ ◐ Waxing crescent 33 %           │
│ Moon-free 8 h 31 min ↗ morning   │
│ Cloud 10–45 % · updated 2 h ago  │
│ Rain ≤ 10 % · gusts ≤ 9 km/h ·   │
│ dew 2 of 9 h          Details ›  │
└──────────────────────────────────┘
┌ Your plan ───────────────────────┐
│ M42 · Saved                      │
│ Fits · 3 h 20 min of 6 h usable  │
│ [        Open planner        ]   │
└──────────────────────────────────┘
What can I image tonight? ›
```

### 8.3 Planner: empty state

```
Plan                             ⋮
Getting started
 ✓ Site       Kryvyi Rih
 ○ Target     Choose a target ›
 ○ Rig        Choose a rig ›
 ○ Capture    Add light frames ›
```

### 8.4 Capture block (DSLR, proposed)

```
Light frames
Filter         None ▾
Exposure (s)   [300]  from Ha · 300 s ×
Frames         [   ]  e.g. 30
ISO            [800]  from Ha · ×   (for your records)
White balance  [Daylight ▾]          (for your records)
──────────────
[Build calibration from lights]   (at plan level)
```

### 8.5 Night & Moon: month

```
October 2026          ‹  ›
Mo Tu We Th Fr Sa Su
          1  2  3  4
          ↘0:25 ↘1:27 …
…
16 ◑ ↗ 8 h 31 min (selected)
[band: day|twilight|Moon|dark]  + text alternative
```

## 9. Identity (round 1, R2d summary)

- **Renaming before the first upload is recommended.** The name "Astro Planner" is taken many times over,
  checked 2026-10-17: "Astro Planner: Night Sky Photo", "AstroPlanner", "AstroPlan" (iOS,
  2026), AstroPlanner (Rodman).
- **R2d shortlist** (screening, not a legal opinion): **Culmina**, **AltArc**, **Astrarc**,
  **Arcwindow**; reserve — Noctarc, PhotonPlan. The owner chooses the name.
- **App id** — agent recommendation I-2 `io.github.buffur.<name>` together with RD-01 = B (Buffur is the
  account where the repository actually lives). Consequence: on the owner's phone the app will install
  separately; data is transferred via backup and restore.
- **Mark** — the S9.10 directions, adapted to the name. Chosen by the owner only (P9.4).
- **Splash** — S2 (§3.2). **Icons** — Material; a targeted set for weather and Moon only if
  metaphors are lacking (round 2).

## 10. Sequence before release (input for RA.P; I05, TD-104)

Recommended order (decided in RA.P):
1. **TD-104 (CI) — first.** A green CI must guard the redesign. A log is needed (owner).
2. **Identity:** name, app id, mark, splash. Changing the id affects Kotlin, Gradle, tests and data
   on the phone — better before the rest of the UI work.
3. **Redesign:**
   - onboarding and Home;
   - planner and Capture;
   - night conditions;
   - records and settings.
   Each item — with owner review of renders (K14).
4. **A single v26 migration,** if W2, ST2 or I2 is chosen.
5. **Stage 11 on the final build:** S11.6 (phone, TalkBack, perf), S11.7 (readiness); host rows
   not touched by the changes keep their PASS (V3).
6. **Owner actions:** signing, policy at the new URL, trademark search, Play closed test (≥ 12
   testers, 14 days).

## 11. Traceability

| Phase A findings | Where in this document |
| --- | --- |
| RA-A01, A05, A06, A07, A08, A09, K4 | §1, §2 (A09 — §9, R2d §7) |
| RA-A02, A03, A04, K5, K6 | §4.1 |
| RA-A10, I01, I03, I05, K12, K13 | §10 → RA.P |
| RA-B01–B06 | §3.1 |
| RA-C01–C04, I04, K10 | §3.2, §9 (details — R2d) |
| RA-D01–D06, K9 | §5 |
| RA-E01–E06 | §4.1 (MF-b), §5 |
| RA-F01–F03 | §4.3 |
| RA-F04, K8 | §4.2 (example plan) |
| RA-F05–F11, H02, K7 | §4.1, §4.2 |
| RA-G01–G05, K11 | §6 (G05 — device checks in RA.P) |
| RA-H01–H03 | §7 |
| RA-I02, K3 | §10 (TD-104) |
| K1, K2 | closed by checkpoint `333e1e8` |
| K14 | §0, §10 (render review criterion) |

**Candidate defects without a probe** (permission was not granted) move to RA.P as "verify,
then fix" tasks:
- RA-F05 — exposure carried over when the type changes;
- RA-G03 — no visible Delete;
- K12 — stale label.

RA-F04 is withdrawn when the example button is removed.
