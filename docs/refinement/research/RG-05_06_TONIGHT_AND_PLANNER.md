# RG-05 / RD-06 / RG-06 — Tonight, the planner's structure, and disclosure

> **Task:** S4.R4 (Stage 4; `POST_ROADMAP_PLAN.md`, "S4.R4"). **Gates:** RG-05, RD-06, RG-06.
> **Kind:** research and decision preparation, documentation only. No application code, test or
> dependency changed.
> **Baseline:** `main` @ `8600a39`; application code identical to `92ebf2a`. File and line
> references are at that code.
> **Builds on:**
> - RG-04: Save → image → Logbook → record; the tracker optional; a quiet "how did it go?" line on
>   Tonight;
> - RD-05 and RD-04: state in the app bar; yesterday's saved plan waits while the planner continues
>   on a copy; nothing preselected; an empty plan with "Start from the example plan";
> - the owner's O2: the hierarchy must reflect how important planning is, and the order is this
>   step's decision, not a prescribed layout.
>
> **Process note:** run in the same chat as S4.R1–S4.R3, at the owner's request. S4.E
> (owner-run tests) was not run; the evidence gap is stated in §5.
> **Status:** the owner's decision is pending (§9).

## Contents

1. The questions
2. Evidence: current structure, measurements, the owner's report, the audits, binding rules
3. What must stay visible, and what may be one tap away
4. Options and trade-offs
5. Unknowns and the evidence gap
6. Low-fidelity wireframes (recommended)
7. Recommended direction
8. Out of scope here, with its home
9. Owner decisions
10. What Stages 5, 6 and 9 would implement (sketch, not frozen)

---

## 1. The questions

- **RG-05 (Tonight):**
  - In what order should Tonight show its content, so that planning leads (O2, 08 §2)?
  - Where should Night, Moon and Weather lead (UX-10)? A planner section, detail screens, or an
    "Analytics" destination?
  - Should Tonight have a night picker (UX-11)?
  - Where do the run card, the "how did it go?" line and New sit?
- **RD-06 (the planner):**
  - May the section order change from ADR-015 §2's "same sections and order"?
  - Should the answer (the fit) come first (UX-01, UX-02)?
  - Which explanations and reference data may be one tap away (UX-05, UX-06, UX-07; 08 §17)?
    How are repeated facts reduced (UX-03)?
- **RG-06:** Are Basic/Advanced modes needed, or is progressive disclosure enough?

## 2. Evidence

### 2.1 Current structure (CODE VERIFIED)

**Tonight** (`tonight_home_screen.dart:85–94`), from top to bottom:
1. the run card (only during a live run);
2. the site card: the site name and "Night of …"; a tap opens the site picker (`:142–166`);
3. the night card: Night, Moon and Weather rows, **each opening the planner at its top**
   (`:173–306`, `:219–266`);
4. the current-plan card: the state, target, rig, fit and reason, usable time, **Open planner**
   and **Start** (`:307–400`);
5. quick actions: "What can I image tonight?" and "New session" (`:410–446`).

The app bar holds the title and the red-mode button.

**The planner** (`home_screen.dart:113–362`):

| # | Section | Content |
| --- | --- | --- |
| 1 | **Target / What** | The target card: type, current altitude, max altitude in windows. The opportunity chart and the window list (`TonightOpportunityWidget`) |
| 2 | **Equipment / How** | Nine rig rows: pixel scale, FOV, NPF, max sub, target size, focal length, focal ratio, sensor, tracking (`:146–175`) |
| 3 | **Conditions & Timeline / When** | Session Date (`:177–220`); weather: ranges, dew, hour strip, age, model, attribution; sky darkness and its timeline (Bortle/SQM, Moon); the light-pollution map card (`:222–300`) |
| 4 | **Capture Plan** | Inputs (blocks); Outputs: six budget lines, **Fit tonight**, fill or trim, √N per group with its help text, storage, **the assumptions panel** (`capture_plan_widget.dart:37–186`; `capture_budget_summary.dart`) |
| — | Bottom bar | Save Session, Start |

**Only the assumptions panel is collapsible** (`capture_assumptions_panel.dart:56`, an
`ExpansionTile`). Everything else is always expanded.

### 2.2 Measurements (05 §3; host renders at 412 dp, not re-rendered)

The order they depend on is re-verified above.
- **Tonight:** 1.1 screens, 110 words; the fit on screen 1.
- **The planner:**
  - with the default plan: 5.05 screens and 660 words. **The fit sits at y = 3,601 of 3,995, on the
    last screen**;
  - with an LRGB plan: 6.16 screens, the fit on screen 6;
  - at 200 % text: 11.6 screens, the fit on screen 11.
- **The night is chosen in section 3** (y = 1,712), below the chart and windows it drives (y =
  444–842).
- **Repetition:** the zone caption 5 times; "(+1)" 9 times; the Moon 5 times; the −18° limit 4
  times; sunset, sunrise and darkness times in 3 cards.

### 2.3 The owner's report and clarification

- **08 §2 and O2:** the site sits near the top and the planner near the bottom. The hierarchy does
  not reflect planning's importance. Night, Moon and Weather open the planner. Options named:
  deep-link, an "Analytics" tab, or rethink.
- **08 §8:** the planner's title is truncated; the date icon is not intuitive.
- **08 §10:** the target chart is not intuitive; the information block is overloaded. "Most
  important information first → details second".
- **08 §12, §13:** conditions and sky darkness are flat, continuous text with weak hierarchy. Study
  Stargazing Hub: a concise timeline, visualisation, weather icons, only the necessary information.
- **08 §17:**
  - total time and time including intervals: keep;
  - is setup/calibration time needed?
  - integration: prominent;
  - "Fit tonight": what does it mean?
  - √N: a core feature, wanted as a compact graph, with the help collapsible, on tap or optional;
  - storage: "not calculated";
  - assumptions: what are they for? They blend in.
- **Evidence level:** one experienced user. Nobody else observed; S4.E not run.

### 2.4 Audits

- **UX-01, UX-02:** the answer is last; the night sits below what it drives.
- **UX-03:** repetition.
- **UX-05:** explanations always expanded (a trade-off).
- **UX-06:** the weather card gives every variable equal weight.
- **UX-07:** the rig rows are shown on every visit.
- **UX-10:** drill-downs land at the top.
- **UX-11:** there is no night picker, although the wireframe had one.
- **05 §0:** density is concentrated in the planner. Tonight is not a density problem.
- **05 §8 patterns** (hypotheses):
  - P1: answer first;
  - P2: reorder by decision;
  - P3: collapsible sections with factual summaries;
  - P4: detail screens;
  - P5: contextual disclosure;
  - P6: modes;
  - P7: a density preference.
- **05's owner questions:** Is integrity text allowed one tap away? May the order change? A night
  picker and a state on the planner?
- **06:** UX-02 and UX-05 are owner decisions. The zone captions are partly mandated ("every
  displayed time names its zone", MASTER_ROADMAP).

### 2.5 Binding rules (unchanged unless the owner amends them)

- **PD-14 / ADR-015 §2:** Tonight is a fixed view, and there is no customisable dashboard. There
  are four tabs.
- **ADR-015 §2:** the planner keeps "today's Home content, same sections and order". **RD-06
  exists to decide whether this changes.**
- **ADR-012 (weather):**
  - no score and no good/bad colouring;
  - the age is always shown;
  - "stale" is labelled;
  - the attribution appears on the weather card and on About.
- **ADR-013 (opportunity):** no composite score; reasons for excluded time; usable time is the
  measured quantity.
- **ADR-009 §2, §4 and TASK 5.6:** "the UI shows every line" of the budget. The session budget has
  window load, outside-window calibration and setup "each shown on its own line" (owner). The
  assumptions panel lists every overhead, and an overhead that is off is never a hidden zero.
- **SI-003 / Part C rule 6:** √N is labelled relative and never called SNR; its help text states
  its assumptions.
- **SI-008:** unknown stays unknown.
- **The field constraints** (`IA_WIREFRAMES.md` §3): targets of at least 48 dp; primary actions in
  the lower half; red mode one tap away.
- **CLAUDE.md trap 13:** Tonight is a summary with no calculation in the screen, and it reuses the
  shared wording.

## 3. What must stay visible, and what may be one tap away

"One tap away" means under a control whose collapsed form states **facts, not verdicts** (05 P3),
at most two levels deep (`PRODUCT_DIRECTION.md` §5.2). The proposed rule:

| Always visible | One tap away (collapsed with a factual summary) |
| --- | --- |
| The fit's verdict **and its reason**; usable time; time needed; when capture ends; the one-tap fill or trim | The budget breakdown lines (acquisition, calibration inside and outside the window, setup), each still on its own line when opened |
| Total light integration (08 §17: "prominent") | The √N help text (the √N values stay visible, labelled relative) |
| The plan's target, night, site and state | The assumptions panel (collapsible already) |
| Weather: the night's cloud range, dew-risk hours, wind; **its age** and a "stale" label; the attribution line | Weather: every variable, the hour strip, the model |
| Unknown values, as unknown | The rig's reference rows (NPF, max sub, focal length, ratio, sensor, tracking) |
| The zone once per screen section (the mandated rule, fewer repetitions) | Sky darkness detail (Bortle/SQM with its source, the Moon's times and separation, the map link) |

**Amendment this implies:** ADR-009 §2's "each shown on its own line" is read as *on its own line
in the budget details*. **That needs the owner's approval (§9, F4).** Nothing is hidden behind
more than one tap, and nothing is removed.

## 4. Options and trade-offs

### 4.1 Tonight's order (RG-05)

| | **T1 — plan first (recommended)** | T2 — as today, tidied |
| --- | --- | --- |
| **Order** | A context line (site ▾ · night ▾) → the run card, if live → "Last night: … How did it go?", if due → **Your plan** (target · state; the fit with its reason and usable time; **Open planner**, or "Choose a target" / "What can I image tonight?" without one) → Conditions (Night, Moon, Weather rows) → secondary actions (What can I image tonight?, New plan) | Site card → conditions → the plan card → actions, with Start removed (RG-04) and the new lines added |
| **O2** | Planning leads; the site shrinks to a context control | Planning still sits below the conditions |
| **Night picker (UX-11)** | In the context line, as wireframed. It changes the current plan's night, like the planner's (the same control) | Separate, or none |
| **Cost** | A reordered screen; the context line is a new shared component | Small |

### 4.2 Where Night, Moon and Weather lead (RG-05)

| | D-a — deep-link into the planner's section | **D-b — detail screens, no new tab (recommended)** | D-c — a new "Conditions" or "Analytics" tab |
| --- | --- | --- | --- |
| **Destination** | The planner, scrolled to the card | "Night & Moon" and "Weather" screens, opened from Tonight's rows **and** from the planner's summaries. The target-specific chart stays in the planner | A fifth tab holding the night, Moon, weather and sky darkness |
| **UX-10** | Fixed, but it lands in a long page | Fixed; one place per fact | Fixed |
| **The planner's length** | Unchanged | **Shorter**: conditions become summaries | Shorter |
| **Rules** | — | Two routes added to ADR-015's map (S4.D) | ADR-015's four tabs change (owner); the conditions move away from the plan they explain; PD-14 is not broken (a fixed tab), but a tab adds a destination to learn |
| **08 §2's "Analytics" idea** | No | **Met without a tab**: the detail screens are that analysis, reachable from both places | Met literally |

### 4.3 The planner's structure (RD-06)

| | P-0 — keep the order; add a status card | **P-1 — answer first, then decision order (recommended)** | P-2 — two tabs inside the planner (Plan / Conditions) |
| --- | --- | --- | --- |
| **Order** | A new status card on top, then the ADR-015 order unchanged | See §6: status → context (site · night) → target and tonight's windows → capture plan → conditions summary → rig summary | Plan: status, target, capture plan. Conditions: night, weather, sky |
| **UX-01** | Fixed (the verdict on screen 1) | Fixed | Fixed |
| **UX-02** (the night below what it drives) | **Not fixed** | Fixed: the night sits above the windows | Partly |
| **UX-03** (repetition) | Unchanged | Reduced: the conditions become summaries; zone captions once per section | Reduced |
| **ADR-015 §2** | Kept | **Amended** (owner) | Amended |
| **Risk** | The same length plus one card | More reading of the new order for existing users (only the owner, today) | A hidden second tab; context switches in the dark |

### 4.4 Disclosure (RD-06) and modes (RG-06)

| | **M0 — progressive disclosure per §3; no modes (recommended)** | M1 — M0 plus a "compact / full" preference | M2 — Basic and Advanced modes |
| --- | --- | --- | --- |
| **What experts keep** | Everything, one tap away at most | Everything, and "full" shows it all expanded | Everything, in Advanced |
| **Cost** | Collapsible sections that remember their state | M0 plus a setting and a second layout to test | Two presentations to design and test; every integrity rule must hold in both (05 P6: high risk) |
| **Evidence** | The problem is concentrated in one screen (05 §0), which argues for the narrow fix first | No evidence that users change such settings (05 P7) | No evidence; `PRODUCT_DIRECTION.md` §2: "progressive disclosure is tried first" |
| **Later** | M1 and M2 stay possible if evidence after Stage 6 asks for them | — | — |

## 5. Unknowns and the evidence gap

- **No user has been observed.** S4.E (the five-second, first-run and darkness tests) was not run.
  The recommendation rests on 05's measurements, 08's human evidence and the rules. S4.E can still
  be run before Stage 6 builds the result. Stage 6's acceptance should include a five-second test
  of the new first screen.
- **Unknown:** whether a pinned status (always on screen) or a status card that scrolls away works
  better at 200 % text. Stage 6 decides with a test; either meets P-1.
- **Unknown:** how often the rig's reference rows are actually read (UX-07, "requires
  verification"). Keeping them one tap away is reversible.

## 6. Low-fidelity wireframes (recommended: T1 + D-b + P-1 + M0)

```text
TONIGHT (tab root)
┌──────────────────────────────────────┐
│ Tonight                    [red] ⋮   │
│ Ljubljana ▾ · Fri 14 Nov ▾           │  ← context line: site switcher, night picker
├──────────────────────────────────────┤
│ ● Tracking M31 — 2 h 10 min   ›      │  ← only during an optional live run
│ Last night: M42. How did it go?  ›   │  ← only when a saved night awaits a result
├──────────────────────────────────────┤
│ Your plan · M42 Orion Nebula         │
│ Saved · Refractor 400                │
│ Fits · 3 h 10 min of 4 h 20 min      │  ← verdict + reason (shared wording)
│ [        Open planner        ]       │
├──────────────────────────────────────┤
│ Night   18:02 – 05:41 (dark ≤ −18°) ›│  ← Night & Moon detail
│ Moon    32 % lit, sets 22:10        ›│  ← Night & Moon detail
│ Weather cloud 10–40 % · 2 h old     ›│  ← Weather detail
├──────────────────────────────────────┤
│ [ What can I image tonight? ] [New plan]│
└──────────────────────────────────────┘
No target: the plan card says "No target chosen" → [Choose a target] [What can I image tonight?]

PLANNER (/session/:id)
┌──────────────────────────────────────┐
│ ←  M42 · Fri 14 Nov    Saved     ⋮   │  ⋮ = New plan, Duplicate for another night,
├──────────────────────────────────────┤      Track live (optional, when saved)
│ Fits · 3 h 10 min needed of 4 h 20   │  ← STATUS: verdict, reason, capture ends 01:40,
│ Integration 1 h 40 min · [Fill]      │     total integration, fill/trim
├──────────────────────────────────────┤
│ Ljubljana ▾ · Fri 14 Nov ▾           │  ← CONTEXT (same control as Tonight)
├──────────────────────────────────────┤
│ Target  M42 Orion Nebula        ›    │  ← TARGET + TONIGHT'S WINDOWS
│ [altitude chart] windows 21:10–01:50 │     (the chart's redesign is Stage 6)
├──────────────────────────────────────┤
│ Capture plan                         │  ← CAPTURE PLAN
│  L 60 s × 100   ≡                    │
│  [+ Add block]  [Start from example] │
│  Time needed 2 h 05 · Session 2 h 35 │
│  Budget details ▸                    │  ← breakdown lines, each on its own line
│  Relative stacking gain √N: L ×10 ⓘ  │  ← help on tap
│  Storage 30 GB (estimate) · Assumptions ▸│
├──────────────────────────────────────┤
│ Conditions                           │  ← CONDITIONS SUMMARY
│  Night & Moon  dark 19:40–04:20   ›  │     → Night & Moon detail
│  Weather  cloud 10–40 %, dew 2 h  ›  │     → Weather detail (age shown)
│  Sky  Bortle 4 (you, 2026-08)     ›  │     → sky darkness detail + map link
├──────────────────────────────────────┤
│ Rig  Refractor 400 · FOV 3.4°×2.2°   │  ← RIG SUMMARY (pixel scale, frame fill)
│      1.94″/px · M42 fills 38 %   ›   │     → full rig rows (NPF, max sub, …)
├──────────────────────────────────────┤
│ [              Save              ]   │  ← primary action, lower half
└──────────────────────────────────────┘

NIGHT & MOON DETAIL (new, above the tabs)     WEATHER DETAIL (new, above the tabs)
 timeline: sunset → twilights → dark → dawn     summary (cloud, dew, wind), age, model
 Moon: illumination, rise/set, up-times         every variable, hour strip, attribution
 zone caption once                              "no forecast" / stale states as today
```

## 7. Recommended direction

**T1 + D-b + P-1 + M0, with §3's disclosure rule.**
- **Planning leads on both screens (O2).**
  - Tonight's plan card comes before the conditions.
  - The planner answers "does it fit?" first (UX-01).
  - The planner puts the night above what it drives (UX-02).
- **One place per fact, with no fifth tab.**
  - The night, Moon and weather live on detail screens, reachable from Tonight and the planner
    (UX-10, UX-03).
  - This meets 08 §2's "Analytics" idea without splitting the conditions from the plan.
- **One context control (site ▾ · night ▾) on both screens.** It gives Tonight the wireframe's
  night picker (UX-11) and fixes the unintuitive date icon (08 §8).
- **Detail stays one tap away:**
  - the budget breakdown, the √N help, the assumptions, every weather variable, the rig's rows;
  - their collapsed forms state facts, and their state is remembered;
  - experts lose nothing (principle 4), and there are no modes (RG-06).
- **Amendments the owner approves here:**
  - ADR-015 §2 (the planner's order; two detail routes);
  - ADR-009 §2's "own line" read as within the budget details.

  ADR-019 (S4.D) records them.

## 8. Out of scope here, with its home

These are listed in the matrix (S4.R1 §5); none of them is an S4.R4 flow decision:
- the altitude chart's redesign (08 §10, UX-08) — Stage 6;
- a weather timeline with icons (08 §12). Icons may show values, never verdicts (ADR-012) —
  Stage 6, with icons from Stage 5;
- a compact √N graph (08 §17), with the "relative" label kept (SI-003) — Stage 6;
- "Fit tonight"'s wording (08 §17): P-1 makes it the headline ("Fits · 3 h 10 min needed of 4 h 20
  min usable"); the words are RD-14's (S4.R5), and Stage 6 applies them;
- storage shown as "unknown" (08 §17): it is unknown by design without a RAW size. Stage 6/7 adds
  an action to fill it (S3.8 can take it from a DNG);
- the light-pollution map link (08 §13) — Stage 7 (RG-09);
- typography, colour and the look of the collapsed forms — Stage 5;
- the Moon and cloud gate controls (TD-050, RD-11) — Stage 6 or 9.

## 9. Owner decisions

- **F1 — Tonight's order (RG-05):** **T1 (recommended)**, with the context line (site ▾ · night ▾,
  the night picker changing the current plan's night); or T2.
- **F2 — where Night, Moon and Weather lead (RG-05):**
  - **D-b (recommended):** detail screens, no new tab;
  - D-a: a deep-link into the planner;
  - D-c: a new Conditions/Analytics tab.
- **F3 — the planner's structure (RD-06):**
  - **P-1 (recommended):** answer first, decision order, which amends ADR-015 §2;
  - P-0: a status card only;
  - P-2: tabs inside the planner.
- **F4 — disclosure and modes (RD-06, RG-06):**
  - **M0 with §3's rule (recommended):** the budget breakdown, the √N help, the assumptions, every
    weather variable and the rig's rows one tap away; ADR-009 §2's "own line" means within the
    budget details; no modes;
  - or only the help texts collapse, with the budget lines staying expanded;
  - or Basic/Advanced modes.

## 10. What Stages 5, 6 and 9 would implement (sketch, not frozen)

S4.T turns this into provisional Tasks.
- **Stage 5:**
  - the collapsible section with a factual summary;
  - the context line (site ▾ · night ▾);
  - the status block (verdict, reason, key numbers);
  - the state label (RD-05);
  - the detail-screen template.
- **Stage 6:**
  - Tonight in T1's order;
  - the planner in P-1's order, with the status block and summaries;
  - the Night & Moon and Weather detail screens (new routes, ADR-019);
  - the collapsed defaults and remembered state;
  - zone captions once per section;
  - tests: the accessibility sweep's route list gains the new screens (trap 17); a five-second test
    of both first screens (S4.E-style) as acceptance evidence.
- **Stage 9:** the Settings side of anything that moves out of context (RG-13).
- **Unchanged calculations:** none are touched. Only placement and disclosure change, and every
  value stays reachable.
