# AstroPlan — Product Direction (post-roadmap refinement)

> **Status:** the authoritative product direction for post-roadmap refinement, set by
> **Stage 0 — Refinement Baseline** on 2026-09-25. Changing it needs the owner's approval.
> **Authority:** the owner's Stage 0 prompt
> (`docs/refinement/prompts/STAGE_0_REFINEMENT_BASELINE.md`, §4–§8 and §10) and the
> post-roadmap governance in `CLAUDE.md`.
> **Verified against:** `main` @ `becae04` (2026-09-24, the last roadmap commit). Audits
> 01–07 in `docs/audit/` were captured against that commit, and no application code has
> changed since.
> **Read with:** `POST_ROADMAP_PLAN.md` (Stages, gates, workflow rules) and `PROGRESS.md`
> (current state).
> **History is not rewritten.** Where this direction replaces an older product statement,
> §9 says so. The older documents stay unchanged as evidence of how the baseline was built.
> **Updated 2026-09-27 (S4.R2, owner-approved):** §4 records the RG-04 decision (Execution's
> role; post-session results). Nothing else changed.
> **Updated 2026-09-27 (S4.R3, owner-approved):** §10 notes the RD-05 and RD-04 decisions.
> **Updated 2026-09-27 (S4.R4, owner-approved):** §10 notes the RG-05, RD-06 and RG-06 decisions.

## 1. Primary product job

AstroPlan (shipped as **Astro Planner**, `AppIdentity.appName`) is primarily a
**user-friendly planner for upcoming astrophotography sessions**. It should answer these
questions with as little friction as possible:

1. What can I image?
2. When can I image it?
3. With which equipment, and from which site?
4. How should I plan the capture?
5. Does the planned session realistically fit the available night?

The central capability: **fit a realistic capture plan into the user's real imaging
opportunity, and explain the result transparently.**

AstroPlan complements Stellarium, Stargazing Hub, N.I.N.A., ASIAIR and dedicated
telescope-control software. It is not a planetarium, and it is not a hardware-control
suite.

## 2. Primary users

- The focus stays on **manual and semi-automated imagers** (MASTER_ROADMAP §3.1). That
  means a DSLR, mirrorless or astro camera on a tracker or a simple mount, or a smartphone on
  a tripod, without a laptop automation stack.
- AstroPlan is **not** redefined as a beginner-only app. Experienced astrophotographers
  keep access to every advanced value, assumption and calculation.
- The UI must not **require** expert-level manual entry where a trustworthy automated
  source exists, meaning a value with adequate evidence and provenance. Where no such
  source exists, the value stays user-entered, or unknown.
- This answers the direction part of the Final Audit's primary-user question
  (`docs/audit/07_FINAL_AUDIT.md` §6 item 11). The focus stays on manual and semi-automated
  imagers, and less experienced users are served by removing unnecessary expert entry, not
  by redefining the product. Whether separate Basic/Advanced modes are needed is still a
  research question (RG-06); progressive disclosure is tried first.

## 3. Primary workflow: planning first

```text
Site / Equipment / Target
        ↓
Night & Imaging Opportunity
        ↓
Capture Plan
        ↓
Fit / Feasibility
        ↓
Saved Session
        ↓
Optional Execution / Tracking      (supporting)
        ↓
Actual Result / Logbook            (supporting)
```

Each step maps onto foundations that already exist. This document introduces no new
domain concept.

| Step | Question it answers | Existing foundation (kept) |
| --- | --- | --- |
| Site / Equipment / Target | Where, with what, and what | Sites with an IANA zone (ADR-007, G7); a flat equipment profile with units and provenance (ADR-011, ADR-008 §6); a 164-object catalog plus custom targets (G8) |
| Night & Imaging Opportunity | When | `SessionNight` (ADR-007); the Moon (ADR-010); weather with freshness states (ADR-012); `ImagingOpportunity` gates, annotations and reasons, with no score (ADR-013); Tonight's candidates (TASK 10.4) |
| Capture Plan | How | Capture blocks with a calibration policy and a descriptive gain (TASK 5.3); the capture budget (ADR-009, CALC-25) |
| Fit / Feasibility | Does it fit? | `FitAnalyzer` (CALC-26): fits, tight, doesn't fit or no window, with a reason, an end time and a one-tap fill |
| Saved Session | Keep the plan | The Session aggregate, its lifecycle and snapshots (ADR-014) |
| Execution / tracking | *(supporting)* | ADR-016; `ExecutionMachine` (CALC-35, CALC-36) |
| Actual result / Logbook | *(supporting)* | Reconciliation (CALC-37); progress per target (CALC-38); the Sessions list and detail; export manifest v2; backup and restore |

## 4. Supporting workflows

Execution and tracking, actuals and reconciliation, the Logbook (the Sessions tab), export
and backup stay in the product. They must:

- preserve correct data and session state whenever they are used (the event log,
  snapshots and single-transaction writes of ADR-014 and ADR-016);
- not dominate or complicate the planning experience;
- not be removed or redesigned opportunistically. **Execution's final role** (primary,
  optional, simplified or post-session only) is an explicit product decision for Stage 4
  (RG-04), implemented in Stage 8. Until then Execution stays as built.

**RG-04 decided (owner, 2026-09-27; DECISIONS E.1):**
- The default flow after planning is **Save → image → Logbook → record the result**, with no
  interaction while imaging.
- The live tracker stays, but as an **optional** mode, off the primary path.
- A result is **"Completed as planned"** (one tap), **"Partly"** (numbers per light block) or
  **"Not done"** (a reason).
- Implemented in Stage 8. Execution stays as built until then.

## 5. Product principles

1. **Answer first.** Every screen leads with the answer to its question, then the planning
   action, then supporting detail, then technical detail. On the planner, the answer is
   whether the plan fits; on Tonight, what is possible tonight.
2. **Progressive disclosure.** Detail is layered, not deleted. Keep it to two levels where
   possible (05 §7, NN/g).
3. **Automate trustworthy inputs.** A value is retrieved or inferred only when its source
   has adequate evidence, licence or terms, provenance, privacy handling and failure
   behaviour (CLAUDE.md rule 28). The UI says where an automated value came from.
4. **Advanced data remains reachable.** Every calculated value, assumption, unit and source
   stays available to experienced users.
5. **Preserve scientific honesty.** Units are explicit, assumptions are documented,
   estimates are labelled as estimates, and no claim goes beyond its evidence
   (`SCIENTIFIC_INTEGRITY.md` Part C).
6. **Reduce duplicated actions.** Each action has one clear place and name (for example,
   new versus open session, and choosing a target or rig).
7. **Minimise manual input.** Ask only for what cannot be obtained or reasonably defaulted,
   and label defaults as defaults.
8. **Clear state and feedback.** The user always knows what they are editing (a draft or a
   saved plan, for which night), and every action confirms its result.
9. **Field usability remains important.** One-handed use with gloves, targets of at least
   48 dp, primary actions in the lower half, little typing, red mode one tap away, and no
   silent loss (`IA_WIREFRAMES.md` §3).
10. **The Notion-inspired visual identity is a direction, not a restriction.** Better
    interaction patterns may be adopted where they improve clarity.
    `.agents/rules/05-ui-design.md` still applies: clean, minimalist, information-dense
    and functional, with no decorative clutter and no excessive animation.
11. **Offline-first.** Planning works without a network; online services enrich it.
12. **Unknown stays unknown, with provenance.** A missing value is shown as unknown, never
    as zero or a silent default (SI-008).

## 6. Non-negotiable constraints

These hold until an explicit owner decision changes them:

- an offline-first core (CLAUDE.md, architectural rule 3; ARCHITECTURE Part A);
- transparent calculations (ADR-005; `SCIENTIFIC_INTEGRITY.md` Parts B and C);
- no composite black-box "Astro Score" (ADR-013 §5; ADR-012: no weather score or good/bad
  colouring);
- thresholds are configurable preferences, not physical laws (`PlanningPreferences`;
  SI-006);
- unknown values stay unknown and no value is fabricated; defaults are labelled (SI-008);
- assumptions remain reachable (ADR-009 §4; the assumptions panel of TASK 5.6);
- relative stacking gain is **√N versus one frame**, per (filter, exposure) group, and never
  physical SNR (SI-003, ADR-005). ISO or gain is never called "sensitivity" and is never
  claimed to collect more light (SI-004);
- scientific calculations are never changed silently (`SCIENTIFIC_INTEGRITY.md` Part C,
  rules 1–2);
- Provider and ViewModels stay (ADR-002): no rewrite and no redesign of dependency
  injection (ARCHITECTURE D3);
- no uncontrolled scope expansion: one approved Task at a time (`POST_ROADMAP_PLAN.md` §9);
- deferred and rejected features stay deferred or rejected until the owner explicitly
  reopens them (§8);
- web scraping stays rejected (PD-05; MASTER_ROADMAP §10). That includes extracting
  specifications from product web pages or links;
- every external dataset, API, catalog or enrichment source needs evidence on its source,
  licence or terms, reliability, provenance, privacy and failure behaviour before it is
  implemented. Anything new that leaves the device goes into `docs/privacy/index.md` and
  `docs/COMPLIANCE.md` in the same change (CLAUDE.md trap 22);
- the app stays free, with no ads or subscriptions (PD-12). Changing that needs the owner
  and Open-Meteo's commercial plan.

## 7. What must not happen

- Deleting valid domain or scientific functionality because its current presentation is
  poor. Improve its hierarchy instead.
- Redesigning screens around raw domain entities (sections by data type) instead of the
  user's planning questions.
- Creating a black-box score, or a good/bad verdict that hides its reasons.
- Inventing missing values to make the UI look complete: a guessed elevation, Bortle class,
  file size or equipment specification.
- Turning AstroPlan into a planetarium, a sky-map or framing tool, or a telescope or camera
  control suite.
- Forcing users to type data the app can reliably obtain itself (catalog coordinates, a GPS
  position, verified file metadata), or presenting an unreliable guess as fact.
- Treating an audit hypothesis or a dogfooding proposal as an approved decision.
- Writing extracted metadata into Equipment, or anywhere else, before the candidate → match
  → confirmation → persistence flow of Stage 3 has been designed and approved.

## 8. Scope boundaries carried forward

**Rejected** (MASTER_ROADMAP §10; ADR-004; PD-14):
- planetarium, sky map, 3-D sky, AR, FOV framing on sky imagery, mosaic planning;
- camera or telescope control, ASCOM, INDI, ASIAIR integration, live view;
- accounts, cloud sync, social features, a backend;
- a black-box score; absolute physical SNR or exposure optimisation;
- a customisable dashboard (Tonight is a fixed view);
- web scraping.

**Deferred** (MASTER_ROADMAP §10 and the ADRs):
- notifications and alarms; empirical overhead suggestions;
- XMP, XISF and CR3 until real samples verify them (RG-01 decides whether any is supported);
- an offline light-pollution dataset or a licensed light-pollution API (evaluated only
  through RG-09);
- seeing and transparency forecasts; moving objects (ADR-010 §3);
- multi-target night scheduling; a Project entity; an equipment composition UI (ADR-011 §2);
- azimuth and a horizon profile (TASK 10.5 cut; the ADR-013 horizon gate stays reserved);
- iOS; localisation and unit preferences; home-screen widgets and Wear OS; place search;
- a theoretical storage payload; precession and refraction refinements beyond the current
  policy; manifest import; crash reporting.

A deferred item comes back only through the research and decision gate
(`POST_ROADMAP_PLAN.md` §9.6) and an owner decision.

## 9. What this direction supersedes, and what it does not

**Superseded as current product direction** (the historical text is kept unchanged):

| Earlier statement | Where | Now |
| --- | --- | --- |
| "Plan → Execute → Log closes the loop"; the loop is "the main bet" | MASTER_ROADMAP §1, §3.1–3.2; PROJECT_HANDOFF §3; PRODUCT_SPEC "Core Workflow" | Planning comes first. Execution, actuals and the Logbook are supporting workflows (§3–§4), and Execution's role is decided in Stage 4 |
| "Metadata-assisted logging comes in v1.1 (G17), after Android 1.0" | MASTER_ROADMAP §1, G17, §6 | The metadata foundation (Stage 2) and metadata → equipment import (Stage 3) come before the product-flow work. Metadata-assisted actuals (the old TASK 17.3) move to Stage 8, once the workflow is known |
| "No visual redesign until the domain and Session are stable" | MASTER_ROADMAP §3.3 | The condition is met. UX refinement is planned through Stages 4–6 and 9, on a design system built first (Stage 5) |
| `MASTER_ROADMAP.md` is the approved scope, and `ROADMAP.md`'s active-task line is the current position (OD-06) | DECISIONS Part C; ROADMAP "Adopted plan"; PROJECT_HANDOFF header and §0 | After Stage 0, `POST_ROADMAP_PLAN.md` is the strategy and `PROGRESS.md` the state (CLAUDE.md). The roadmap's open items are carried (`POST_ROADMAP_PLAN.md` Appendix B) |

**Not superseded.** These stay in force until an explicit owner decision or ADR changes
them:
- every accepted ADR, ADR-001 to ADR-016. That includes ADR-015 §2 (the planner keeps its
  sections and order; Stage 4 may propose an amendment, RD-06) and ADR-016 (the execution
  model);
- the owner directives OD-01, OD-02, OD-04, OD-05 and OD-07;
- the PD-06 gate policy: metadata import stays hidden (`FeatureScope.metadataImport =
  false`) until its approved refinement stage lifts the gate (RD-16);
- PD-12 (free, GPL-3.0, place names opt-in). The owner's newer licence requirements (08
  §23) go through RG-12 first;
- the release checklist of MASTER_ROADMAP §9, for any release.

## 10. Questions this document leaves open

Each open question has an ID in `POST_ROADMAP_PLAN.md`: §7 for research gates (RG) and §8
for owner decisions (RD). The main ones:

- Execution's role (RG-04), the Home/Tonight structure and a possible Analytics destination
  (RG-05), and Basic/Advanced modes (RG-06);
- automation sources for targets, elevation and sky brightness (RG-07 to RG-09), and
  equipment specifications (RG-02, RG-03);
- calibration frames and capture parameters (RG-10, RG-11);
- the licence (RG-12);
- tracking per session (RD-08), drafts (RD-05), defaults (RD-04), and the planner's order
  and disclosure (RD-06).

**Decided since (owner, 2026-09-27; DECISIONS E.1):**
- **RG-04:** Execution is optional; results are recorded after the session (§4).
- **RD-05:**
  - Draft is internal; the plan's state reads "Not saved", "Saved" or "Saved · changed";
  - Save stays explicit;
  - yesterday's saved plan waits for its result, and the planner continues on a copy;
  - replacing unsaved changes asks Save · Discard · Cancel.
- **RD-04:**
  - nothing is preselected on the first run;
  - New keeps the site and rig and asks for the target;
  - the capture plan starts empty, with "Start from the example plan".
- **RG-05:**
  - Tonight puts the plan first, under a site · night context line;
  - the night, Moon and weather have their own detail screens, with no new tab.
- **RD-06:**
  - the planner answers "does it fit?" first, then follows the decision order;
  - detail is one tap away, with factual summaries.
- **RG-06:** no Basic/Advanced modes; progressive disclosure (principle 2).
