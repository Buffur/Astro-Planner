# AstroPlan — Information architecture: wireframes and route map

> **Status:** accepted with ADR-015 (owner, 2026-09-23, TASK 12.1). Design intent —
> low-fidelity only; the navigation shell is implemented in TASK 12.2, the Tonight
> dashboard in TASK 12.5 and execution in G13. When the code differs, record an
> implementation deviation; do not rewrite this file to match it.

## 1. Tabs (bottom navigation)

| Tab | Purpose | Root screen |
| --- | --- | --- |
| **Tonight** | "What can I image tonight, and is my plan ready?" | Tonight dashboard (fixed, not customizable — PD-14) |
| **Sessions** | Every session: drafts, planned, in progress, completed and legacy logs | Sessions list (today's Logbook, widened) |
| **Library** | Reusable things: rigs, targets, sites | Library index |
| **Settings** | Planning thresholds, gates, NPF k, about and data sources | Settings |

The **Session planner** (today's long Home page) is one page opened from Tonight *and*
from Sessions. **Execution** (G13) is a full-screen route above the tabs.

## 2. Route map

```
/                                   → redirect to /tonight
StatefulShellRoute (bottom navigation, one navigator per tab, state kept per tab)
├── /tonight                        Tonight dashboard                         (12.5)
│   └── /tonight/candidates         Tonight's candidates (today's /tonight)   (10.4)
├── /sessions                       Sessions list (today's /logbook)          (11.3–11.4)
├── /library                        Library index
│   ├── /library/rigs               Rig list + selection (today's /equipment)
│   │   └── /library/rigs/edit      Rig editor
│   ├── /library/targets            Target list + search (today's /target)
│   │   └── /library/targets/edit   Target editor
│   └── /library/sites              Sites (today's /sites)
│       ├── /library/sites/edit     Site editor (today's /sites/edit)
│       └── /library/sites/pick     Map coordinate picker (today's /location/pick)
└── /settings                       Settings (today's /settings)
    ├── /settings/about             About & data sources (today's /about)
    └── /settings/metadata          Metadata import — gated until G17 (FeatureScope)

Routes above the shell (no bottom bar; back returns to the tab they came from)
├── /session/:id                    Session planner (today's Home content)
├── /session/:id/run                Execution, full screen (G13)
└── /position                       Transient position: map pick or GPS (today's /location)
```

**Old → new:** `/` (Home) → `/tonight` + `/session/:id`; `/tonight` → `/tonight/candidates`;
`/logbook` → `/sessions`; `/equipment` → `/library/rigs`; `/target` →
`/library/targets`; `/sites`, `/sites/edit` → `/library/sites…`; `/location` →
`/position`; `/location/pick` → `/library/sites/pick`; `/about` → `/settings/about`;
`/metadata` → `/settings/metadata` (still gated).

**Back behaviour (Android):** back pops within the current tab; at a tab's root it
returns to Tonight; at Tonight's root it leaves the app. Pages above the shell pop to
the tab they were opened from. Deep links are out of scope (TASK 12.2).

## 3. Field constraints (every screen)

- One-handed use with gloves: touch targets **≥ 48 dp**, primary actions in the lower
  half, no small icon-only actions for anything frequent.
- Little typing: pickers and steppers over text fields; nothing essential needs the
  keyboard at the telescope.
- Dark: red field mode reachable in **one tap** from Tonight and the planner (G12.4),
  dialogs, date pickers and snackbars included; no white flashes.
- No destructive action without a confirmation (delete, abandon); no silent loss —
  every plan edit autosaves (TASK 11.4). *(Amended by RD-09, owner, 2026-09-27: edits inside a
  plan, such as deleting a capture block, use Undo instead of a confirmation; DECISIONS E.1,
  "RD-09 decided".)*
- Unknown values say "unknown" or "no forecast", never 0 (SI-008).

## 4. Wireframes (low fidelity)

### Tonight (tab root, fixed view — PD-14)

```
┌──────────────────────────────────────┐
│ Tonight            [red mode] [⚙]    │
│ Ljubljana ▾ · Fri, Nov 13            │  ← site switcher sheet; night picker
├──────────────────────────────────────┤
│ Night  18:02 – 05:41  (dark ≤ −18°)  │
│ Moon   32 % lit, sets 22:10          │
│ Weather  cloud 10–40 % · 2 h old     │  ← age always shown; "no forecast" if none
├──────────────────────────────────────┤
│ Current session              Draft   │
│ M42 Orion Nebula · Refractor 400     │
│ Fits · 4 h 20 min usable             │  ← fit state + one-line reason
│ [ Open planner ]                     │
├──────────────────────────────────────┤
│ [ What can I image tonight? ]        │  ← /tonight/candidates
│ [ New session ]   [ Start ] (G13)    │
├──────────────────────────────────────┤
│ Tonight │ Sessions │ Library │ Settings│
└──────────────────────────────────────┘
```

No site → the site prompt (first run, TASK 12.5) instead of the night rows.

### Session planner (`/session/:id`, above the tabs)

```
┌──────────────────────────────────────┐
│ ←  M42 · Fri, Nov 13        Draft ⋮  │  ⋮ = Duplicate for another night, New
├──────────────────────────────────────┤
│ Target / What        (tap to change) │
│ Tonight for this target  (chart+list)│
│ Equipment / How      (tap to change) │
│ Capture plan  (blocks, budget, fit)  │
│ Night weather                        │
│ Sky darkness & Moon                  │
├──────────────────────────────────────┤
│ [          Save session          ]   │
└──────────────────────────────────────┘
```

Same sections as today's Home, in the same order; autosaved; Save = planned + snapshot.

### Sessions (tab root)

```
┌──────────────────────────────────────┐
│ Sessions                     [ + ]   │
├──────────────────────────────────────┤
│ Open                                 │
│  Fri Nov 13 · M42 · Draft            │
│  Sat Nov 14 · M31 · Planned          │
│  Tue Nov 10 · M45 · Planned, unsaved │
│ Done                                 │
│  Nov 02 · NGC 7000 · Completed  [↗]  │  ← share
│  Sep 12 · M31 · Legacy log      [↗]  │
└──────────────────────────────────────┘
```

Tap → `/session/:id` (a completed or legacy session opens as a copy in a new draft,
TASK 11.4); swipe → delete with confirmation.

### Library (tab root)

```
┌──────────────────────────────────────┐
│ Library                              │
├──────────────────────────────────────┤
│ Rigs      3   ›                      │
│ Targets 164   ›                      │
│ Sites     2   ›   (active: Ljubljana)│
└──────────────────────────────────────┘
```

### Settings (tab root)

```
┌──────────────────────────────────────┐
│ Settings                             │
├──────────────────────────────────────┤
│ Planning: darkness limit, min alt,   │
│   margins, overheads, dew margin     │
│ Imaging gates: Moon, cloud (TD-050)  │
│ Exposure guidance: NPF k             │
│ Field mode                           │
│ About & data sources   ›             │
└──────────────────────────────────────┘
```

### Execution (`/session/:id/run`, G13 — placeholder only)

Full screen, no bottom bar, large controls; designed in TASK 13.1.
