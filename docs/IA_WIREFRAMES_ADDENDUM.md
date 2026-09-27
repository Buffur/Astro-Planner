# AstroPlan — Information architecture addendum (Stage 4)

> **Status:** accepted with ADR-019 (owner, 2026-09-27, S4.D). This is design intent, low fidelity
> only. It **adds to** `IA_WIREFRAMES.md` (ADR-015), which is not rewritten. Where the two differ,
> this addendum and ADR-019 win.
> **Not yet implemented:** Stages 5, 6, 8 and 9 build it (`refinement/POST_ROADMAP_PLAN.md`,
> S4.T). Until then the app behaves as `IA_WIREFRAMES.md` and the code describe. When the code
> differs, record an implementation deviation; do not rewrite this file to match it.
> **Sources:**
> - the decisions: DECISIONS E.1 and ADR-019;
> - the research: `refinement/research/` (S4.R1, RG-04, S4.R3, RG-05_06, S4.R5);
> - the words follow the glossary in `S4.R5_LIBRARY_AND_VOCABULARY.md` §5.
>
> **Visual design** (type, colour, spacing, icons) is Stage 5's. These drawings fix order, content
> and flow only.

## 1. What changes against `IA_WIREFRAMES.md`

| Area | `IA_WIREFRAMES.md` (ADR-015) | This addendum (ADR-019) |
| --- | --- | --- |
| Tabs | Tonight · Sessions · Library · Settings | The same four; the second is **labelled Logbook** |
| Tonight | A site and night header; night, Moon, weather; the current session; actions (New session, Start) | **The plan first**, under a site ▾ · night ▾ context line; the "how did it go?" line; the Night/Moon/Weather rows lead to **detail screens**; no Start |
| The planner | "Same sections as today's Home, in the same order"; app bar "M42 · Fri, Nov 13 · Draft ⋮" | **Answer first, then decision order**; the app bar shows target · night · **Not saved / Saved / Saved · changed**; detail one tap away |
| Execution | A full-screen tracker after Start | **Optional:** "Track live" on a saved plan; results are recorded afterwards on the Logbook entry |
| Sessions / Logbook | Open/Done groups; tap to open in the planner | **Upcoming / Past**; tap opens the **entry** (plan and result); **Record result**; **Progress by target** |
| Library | "Rig list + selection" | **Manage only;** choosing happens in context; **Plan this target** |
| New routes | — | Night & Moon detail; Weather detail (above the tabs) |

## 2. Route map delta (paths are internal; names in Stage 6 and 8)

```
StatefulShellRoute (unchanged: four branches)
├── /tonight, /tonight/candidates               (unchanged)
├── /sessions  → tab label "Logbook"            (label only)
│   ├── /sessions/:id        the entry          (plan + result)
│   └── (progress)           Progress by target (moved from /library/progress, Stage 8)
├── /library, /library/rigs|targets|sites       (manage mode; no selection)
└── /settings, /settings/about                  (unchanged)

Above the tabs
├── /session/:id             the planner        (answer-first order)
├── /session/:id/run         the tracker        (optional live mode)
├── /session/:id/results     the result form    (Completed as planned · Partly · Not done)
├── (night & moon detail)    new                (Stage 6)
├── (weather detail)         new                (Stage 6)
├── /select/target|rig|site  pickers            (the only place that chooses for the plan)
└── /equipment/import, /welcome, /site/…, /position   (unchanged)
```

## 3. Wireframes

### 3.1 Tonight (tab root, fixed view — PD-14)

```
┌──────────────────────────────────────┐
│ Tonight                     [red] ⋮  │
│ Ljubljana ▾ · Fri 14 Nov ▾           │  ← context line: site switcher + night picker
├──────────────────────────────────────┤
│ ● Tracking M31 · 2 h 10 min      ›   │  ← only during an optional live run
│ Last night: M42. How did it go?  ›   │  ← only when a saved night awaits a result
├──────────────────────────────────────┤
│ Your plan · M42 Orion Nebula         │
│ Saved · Refractor 400                │
│ Fits: 2 h 05 min needed of 4 h 20    │  ← verdict + reason (shared wording)
│ [          Open planner          ]   │
├──────────────────────────────────────┤
│ Night   dark 19:40 – 04:20        ›  │  → Night & Moon detail
│ Moon    32 % lit, sets 22:10      ›  │  → Night & Moon detail
│ Weather cloud 10–40 % · 2 h old   ›  │  → Weather detail
├──────────────────────────────────────┤
│ [What can I image tonight?] [New plan]│
└──────────────────────────────────────┘
```

**Variants:**
- No site: the site prompt replaces the context line and the rows (as today, TASK 12.5).
- No target: the plan card reads "No target chosen", with [Choose a target] and [What can I image
  tonight?].
- Another night picked: the context line shows its date, and the rows describe that night.

### 3.2 The planner (`/session/:id`)

```
┌──────────────────────────────────────┐
│ ←  M42 · Fri 14 Nov   Saved       ⋮  │  ⋮ New plan · Copy to another night ·
├──────────────────────────────────────┤    Track live (optional; saved plans)
│ Fits: 2 h 05 min needed of 4 h 20    │  STATUS
│ Capture ends 01:40 · Integration     │
│ 1 h 40 min · [Fill tonight's window] │
├──────────────────────────────────────┤
│ Ljubljana ▾ · Fri 14 Nov ▾           │  CONTEXT (same control as Tonight)
├──────────────────────────────────────┤
│ Target  M42 Orion Nebula         ›   │  TARGET + TONIGHT'S WINDOWS
│ [altitude chart]                     │
│ Imaging window 21:10 – 01:50         │
├──────────────────────────────────────┤
│ Capture plan                         │  CAPTURE PLAN
│  L 60 s × 100                   ≡    │
│  [+ Add block]                       │
│  Time needed 2 h 05 · Total 2 h 35   │
│  Budget details ▸                    │  ← each line of ADR-009 §2 inside
│  Relative stacking gain √N: L ×10 ⓘ  │
│  Storage 30 GB (estimate)            │
│  Assumptions ▸                       │
├──────────────────────────────────────┤
│ Night & Moon  dark 19:40–04:20   ›   │  CONDITIONS SUMMARY
│ Weather  cloud 10–40 %, dew 2 h  ›   │
│ Sky  Bortle 4 (you, 2026-08)     ›   │
├──────────────────────────────────────┤
│ Rig  Refractor 400                   │  RIG SUMMARY
│ FOV 3.4°×2.2° · 1.94″/px · 38 %  ›   │  → full rows (NPF, max sub, …)
├──────────────────────────────────────┤
│ [            Save plan            ]  │  primary action, lower half
└──────────────────────────────────────┘
```

**A new plan:**
- The capture plan starts empty, with [Start from the example plan].
- Without a target, the status reads "Needs a target", in neutral styling (S1.9).

### 3.3 The unsaved-changes prompt (New plan, Copy, Open)

```
┌──────────────────────────────────────┐
│ Unsaved changes                      │
│ "M42 · Fri 14 Nov" has changes that  │
│ are not saved.                       │
│        [Cancel]  [Discard]  [Save]   │  Discard deletes the unsaved plan
└──────────────────────────────────────┘
```

### 3.4 Night & Moon detail (new)

```
┌──────────────────────────────────────┐
│ ←  Night & Moon · Fri 14 Nov         │
├──────────────────────────────────────┤
│ Dark 19:40 – 04:20 (Sun below −18°)  │  ← the user's darkness limit
│ timeline: sunset 16:31 · civil dusk  │
│  17:03 · nautical dusk 17:39 ·       │  ← the standard twilight names, here only
│  astronomical dusk 18:15 … dawn      │
├──────────────────────────────────────┤
│ Moon 32 % lit (at midnight)          │
│ rises 11:20 · sets 22:10             │
│ Times in site zone Europe/Ljubljana  │  ← once
└──────────────────────────────────────┘
```

### 3.5 Weather detail (new)

```
┌──────────────────────────────────────┐
│ ←  Weather · Fri 14 Nov              │
├──────────────────────────────────────┤
│ Cloud 10–40 % · dew risk 2 h ·       │  summary (values, no verdict — ADR-012)
│ wind 2–5 m/s          2 h old        │  ← age always; "stale" labelled
├──────────────────────────────────────┤
│ All variables (ranges)               │
│ Hour strip (timeline; icons = values)│  ← the look is Stage 6
│ Model: open-meteo / best_match       │
│ Weather data by Open-Meteo.com       │  ← attribution
└──────────────────────────────────────┘
```

### 3.6 The Logbook (tab root, labelled "Logbook")

```
┌──────────────────────────────────────┐
│ Logbook                   [⚲] [≡] ⋮  │  search, a filter panel: 08 §24's proposals,
│                                      │  scope confirmed in Stage 8 planning
├──────────────────────────────────────┤
│ Upcoming                             │
│  Sat 15 Nov · M42 · Saved            │
│ Past                                 │
│  Fri 14 Nov · M42 · Record result ›  │  ← awaiting a result
│  Tue 11 Nov · M31 · Completed        │
│  Sun 09 Nov · M45 · Not done (clouds)│
│  Sep 12 · M31 · Old log              │
├──────────────────────────────────────┤
│ Progress by target               ›   │  ← moved from the Library
└──────────────────────────────────────┘
```

A tap opens the **entry**: its plan (from the snapshot), its result, and its actions (Record or Edit
result, Open plan or Plan again, Share, Export as file, Track live (optional, on its night)).

### 3.7 The result form (`/session/:id/results`)

```
┌──────────────────────────────────────┐
│ ←  How did it go? · M42 · Fri 14 Nov │
├──────────────────────────────────────┤
│ ( ) Completed as planned             │  → actual = plan, "reported as planned"
│ ( ) Partly                           │
│      L 60 s   [ 45 ] of 100          │  ← numbers, pre-filled, editable
│ ( ) Not done   reason [clouds ▾]     │
├──────────────────────────────────────┤
│ Notes (optional)                     │
│ Temperature · humidity · cloud (opt.)│
├──────────────────────────────────────┤
│ [          Save result          ]    │
└──────────────────────────────────────┘
```

The tracker's Finish opens this same form, pre-filled from the confirmed counts.

### 3.8 The Library (manage)

```
┌──────────────────────────────────────┐
│ Library                              │
├──────────────────────────────────────┤
│ Rigs      3   ›   (camera + lens or telescope)
│ Targets 164   ›                      │
│ Sites     2   ›                      │
└──────────────────────────────────────┘
Rigs:    tap = open/edit · [Add rig] · [Add from a photo]
Targets: tap = details (Progress for it) · [Plan this target] · edit custom targets
Sites:   tap = edit · [Add site] (the active site is chosen from the context line)
```

### 3.9 The first run (`/welcome`)

```
1. Your site     Not chosen   [Use current position] [Choose or add a site]
2. Your rig      Not chosen   [Choose a rig] [Add rig] [Add from a photo]
3. A target      Not chosen   [Choose a target] [What can I image tonight?]
[Done]   (nothing is preselected; the seeded rig is listed as an example)
```

## 4. Field constraints

`IA_WIREFRAMES.md` §3 is unchanged:
- targets of at least 48 dp;
- primary actions in the lower half (Save plan; Open planner inside the plan card);
- little typing;
- red mode one tap away;
- no destructive action without a confirmation;
- unknown shown as unknown.

The result form's numbers are typed only for "Partly". A normal night takes two taps.
