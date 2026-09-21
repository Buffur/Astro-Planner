# AstroPlan Decisions

> **Verification stamp:** conformance checked against code at commit `900b82a`
> (2026-09-20), audited 2026-09-21. Application code unchanged since.
> **Updated 2026-09-21 (TASK 0.2):** PD-06 resolved (E.1), PD-17–PD-21 registered,
> OD-06 recorded, DEV-P3 marked resolved. No ADR in Part A was changed.
>
> Structure:
> - **Part A** — accepted ADRs and pending decisions, preserved **verbatim** from
>   the Phase 0 baseline. Nothing in Part A has been edited or re-interpreted.
> - **Part B** — conformance audit: which decisions the implementation follows and
>   the **IMPLEMENTATION DEVIATIONS** where it does not.
> - **Part C** — owner directives recorded from this reconciliation.
> - **Part D** — behaviors *inferred* by the previous audit (not ADRs), corrected.
> - **Part E** — open decisions register (**Proposed / Pending — not accepted**).

---

# Part A — Accepted decisions (Phase 0 baseline, preserved verbatim)

*Source: `git show 900b82a:docs/DECISIONS.md` (the order of sections, including
"Pending Decisions" preceding ADR-006, is kept as committed).*

This file records architectural and product decisions that affect future work.

## ADR-001: Use Flutter And Dart

Status: accepted

AstroPlan uses Flutter and Dart for a single cross-platform application codebase
with Android as the initial target and iOS as a future target.

## ADR-002: Use Provider And ViewModels

Status: accepted

AstroPlan starts with Provider and explicit ViewModels. Additional
state-management frameworks require a documented need and project-owner
approval.

## ADR-003: Use SQLite Via Drift

Status: accepted

AstroPlan uses SQLite for durable local storage and Drift for typed queries,
migrations, relationships, and testability.

## ADR-004: Keep AstroPlan Out Of Planetarium Scope

Status: accepted

AstroPlan is a planner and logbook. Full planetarium, AR sky navigation,
embedded Stellarium, live camera preview, and camera control are out of MVP
scope unless explicitly approved.

## ADR-005: Treat Scientific Calculations As Auditable

Status: accepted

Scientific and astrophotography calculations must document units, assumptions,
valid ranges, references, and tests. Relative stacking gain must not be labeled
as absolute SNR.

## Pending Decisions

- Whether to normalize the current flat equipment table into Device,
  CameraModule, and OpticalRig immediately or through a staged migration.
- Which astronomical engine/library/reference to use for future ephemeris work.
- How to store provenance for seeded target and equipment data.

## ADR-006: Hide Implemented Future-Phase Features Until Approval

Status: accepted

Several later-phase features already exist in source code. To avoid destructive
rollback while restoring roadmap discipline, they are hidden behind
`FeatureScope` gates until their phases are explicitly approved.

Initially disabled gates:

- field mode;
- light-pollution context and external map handoff;
- metadata import;
- logbook UI and save action.

---

# Part B — Conformance audit (2026-09-21)

Status vocabulary: **Implemented / Partial / Broken / Missing / Deprecated /
Unknown** (see `docs/FEATURE_STATUS.md`). "Complies" = verified in code.

| ADR | Decision | Conformance | Detail |
| --- | --- | --- | --- |
| ADR-001 | Flutter and Dart | **Complies** | Flutter 3.47.4 / Dart 3.13.3. Android configured; iOS scaffold only (no location/photo usage strings); web/desktop folders are unverified scaffolds |
| ADR-002 | Provider and explicit ViewModels | **Partial** | Provider + `ChangeNotifier` only, no other framework. But only two ViewModels exist, one of which (`PlannerViewModel`) owns everything, and several screens bypass ViewModels — DEV-P5 → DEV-A1, DEV-A2 |
| ADR-003 | SQLite via Drift ("typed queries, migrations, relationships, and testability") | **Partial** | Drift is used correctly for typed queries. Migrations are untested and one path fails; relationships are declared but not enforced — DEV-P4 → DEV-D1, DEV-D6 |
| ADR-004 | Out of planetarium scope | **Complies** | No planetarium, AR, embedded Stellarium, camera preview or camera control exists |
| ADR-005 | Scientific calculations are auditable; relative gain not labeled SNR | **Deviation** | DEV-P2 |
| ADR-006 | Hide implemented future-phase features behind `FeatureScope` until approved | **Deviation** | DEV-P1 |

## DEV-P1 — ADR-006 gating is only partly implemented
- **Intended behavior:** later-phase features already in the code are hidden behind
  `FeatureScope` gates — field mode; light-pollution context and external map
  handoff; metadata import; logbook UI and save action — until their phases are
  explicitly approved.
- **Actual behavior** (`lib/core/config/feature_scope.dart`,
  `lib/presentation/navigation/app_router.dart`, `home_screen.dart`,
  `sky_darkness_widget.dart`):
  - `fieldMode = false` is **defined but never read**; the field-mode toggle is live
    in Home's app bar (`home_screen.dart:37`).
  - `lightPollutionContext = false` gates only the Bortle badge
    (`sky_darkness_widget.dart:32`). The **external map handoff card is ungated** and
    opens a URL with hard-coded Slovenia coordinates (`home_screen.dart:172`);
    `_fetchBortle` still runs on every location change.
  - `metadataImport = true` and `logbook = true`: the routes are enabled with no
    recorded approval (ADR-006 lists both as initially disabled).
  - Home's app-bar buttons push `/logbook` and `/metadata` unconditionally, so
    switching either gate off would navigate to a route that does not exist.
- **Consequence:** the scope discipline the ADR was written to provide is not
  enforced. Features from Phases 11–15 are user-visible, and there is no record of
  whether they are approved (open decision PD-06). TD-014.

## DEV-P2 — ADR-005 is not met
- **Intended behavior:** calculations document units, assumptions, valid ranges,
  references and tests; "Relative stacking gain must not be labeled as absolute SNR."
- **Actual behavior:** the UI label is `Stacking Gain (Relative SNR)`
  (`capture_plan_widget.dart:215`, restored on purpose in commit `1baa514`); the NPF
  formula deviates from the published one and its test is circular; assumptions and
  references are mostly undocumented.
- **Consequence:** an accepted ADR is violated in user-facing text and in the
  calculation register. Details: `docs/SCIENTIFIC_INTEGRITY.md` SI-001, SI-003,
  SI-009. TD-007, TD-009, TD-036.

## DEV-P3 — No active roadmap phase is declared
- **Intended behavior:** "The active phase is the only approved scope unless the
  project owner explicitly approves a change" (`docs/ROADMAP.md`;
  `.agents/rules/00-project-governance.md`: "Treat the roadmap phase as the active
  scope").
- **Actual behavior:** the roadmap never names the active phase. The code contains
  work from Phase 10 (weather), 11 (light pollution — broken), 12 (metadata import),
  13 (logbook), 14 (export manifest) and 15 (field mode) while the Phase 4–9
  foundations (database, calculation engine, visibility, session planner) have the
  defects listed in this repository. The gate set in ADR-006 implies phases up to 10
  were treated as approved.
- **Consequence:** there is no authoritative basis for deciding what is in scope. The
  owner must declare the active phase (PD-06). TD-041.
- **Status: RESOLVED 2026-09-21 (TASK 0.2).** The owner adopted
  `docs/MASTER_ROADMAP.md` as the approved scope (OD-06) and decided PD-06 (E.1).
  The Phase 0–16 text above and in `docs/ROADMAP.md` is unchanged design intent. The
  *code* still shows the ahead-of-phase features ungated; that part is DEV-P1 / TD-014
  and stays open until TASK 4.3.

## DEV-P4 — ADR-003: migrations, relationships and testability
See DEV-D1 and DEV-D6 in `docs/DATA_MODEL.md` (no migration tests; v3 → v9 fails;
foreign keys not enforced).

## DEV-P5 — ADR-002: explicit ViewModels
See DEV-A1 and DEV-A2 in `docs/ARCHITECTURE.md` (one god ViewModel; screens bypass
ViewModels).

## DEV-P6 — PRODUCT_SPEC MVP scope not fully met
- **Intended behavior** (`docs/PRODUCT_SPEC.md` MVP Scope): equipment profiles with
  device, camera module, sensor, optics **and tracking**; saved locations;
  astronomical timeline with **moonrise, moonset**, phase and illumination;
  **Moon–target separation**; a curated target catalog; planner with feasibility;
  weather with provider-isolated variables; metadata import "where file-format
  behavior has been experimentally verified"; storage estimates distinguishing
  theoretical payload from empirical size; NPF labeled as a recommendation.
- **Actual behavior:** tracking state is stored but not exposed; saved-location
  management has no UI; moonrise/moonset and Moon–target separation do not exist;
  the catalog has 5 objects; no real sample files exist to verify metadata import;
  only the empirical storage figure exists (and shows 0.0 MB when unknown); NPF is
  not surfaced (and its formula deviates).
- **Consequence:** the MVP as specified is incomplete; see `docs/FEATURE_STATUS.md`
  for the per-feature status.

## DEV-P7 — Phase 0 deliverable `GEMINI.md`
- **Intended behavior:** `docs/ROADMAP.md` Phase 0 lists `GEMINI.md` as a deliverable.
- **Actual behavior:** `GEMINI.md` is listed in `.gitignore` and does not exist in
  the working tree; `CLAUDE.md` now serves as the agent-instruction document.
- **Consequence:** the Phase 0 exit criterion "AI rules exist" is met by
  `.agents/rules/` and `CLAUDE.md`, but the listed file is absent. Owner decision
  PD-13.

## DEV-P8 — The testing rule cannot currently be satisfied literally
- **Intended behavior:** `.agents/rules/03-testing.md`: "Run `flutter analyze` and
  `flutter test` before claiming a change is complete."
- **Actual behavior:** `flutter analyze` is clean, but `flutter test` exits non-zero
  because `test/integration_flow_test.dart` fails (pre-existing; root cause in
  TD-003).
- **Consequence:** until TD-003 is fixed, agents must report the failure as
  pre-existing and confirm that no *additional* test fails (recorded in `CLAUDE.md`).

---

# Part C — Owner directives recorded (2026-09-21)

These are instructions given by the project owner in this reconciliation task, not
ADRs. They are recorded so later agents do not undo them.

| ID | Directive |
| --- | --- |
| OD-01 | The code is the source of truth for the **actual** state; design intent is preserved separately and never rewritten to match the code. |
| OD-02 | Source-of-truth documents **must be tracked by Git** (`CLAUDE.md`, `docs/PROJECT_HANDOFF.md`, `ARCHITECTURE.md`, `FEATURE_STATUS.md`, `DATA_MODEL.md`, `TECH_DEBT.md`, `DECISIONS.md`, `PROJECT_AUDIT.md`). The `.gitignore` rules that ignored them were removed. |
| OD-03 | Do not implement `SessionNight` or add new features until the documentation is reconciled and the Master Development Roadmap exists. *(Condition met 2026-09-21: the docs are reconciled and committed, and `docs/MASTER_ROADMAP.md` exists. Work order is now governed by OD-06.)* |
| OD-04 | Do not fix application code or scientific issues during documentation reconciliation; record them only. |
| OD-05 | Do not hide identified issues; do not label a feature "implemented" if it does not work, nor "missing" if it exists in code. |
| OD-06 | `docs/MASTER_ROADMAP.md` is the approved primary plan and the only approved scope (adopted 2026-09-21, TASK 0.2). Work proceeds in stages: **one roadmap TASK per cycle**, in roadmap order, as READ → VERIFY → PLAN → IMPLEMENT → TEST → REVIEW → COMMIT → STOP. Never start the next task on the agent's own initiative; do not change the roadmap without owner approval. Do not re-audit the whole repository; inspect the code only as far as the current task needs. |

---

# Part D — Behaviors inferred by the previous audit (not ADRs), corrected

The previous audit's `DECISIONS.md` listed the following as "decisions", noting they
were "inferred from the implementation". They are **not** approved decisions. Their
verified status:

| Previous statement | Verified status |
| --- | --- |
| Complement, not replace Stellarium (product) | **Consistent with ADR-004** |
| "The `SessionCalculator` strictly compares available darkness against capture block times plus a 15 % overhead" | **Incorrect.** The 15 % model is in `estimateTotalDuration`, which nothing calls. The live path is `PlannerViewModel.estimatedRequiredTime` (all frame types plus a flat 5 s per frame) compared with the visibility windows by `SessionCalculator.calculateFeasibility` |
| Storage uses empirical average RAW size | **True as implemented**, but PRODUCT_SPEC also requires distinguishing theoretical payload; seeds carry no size so the UI shows `0.0 MB` (SI-008, SI-013) |
| Relative gain presented as a statistical metric "explicitly avoiding … absolute SNR" | **Partly.** The metric and doc comment are correct; the UI label says "Relative SNR" (DEV-P2) |
| Flutter / Provider + ChangeNotifier / Drift | **Consistent with ADR-001/002/003** |
| Open-Meteo weather (no key) | **Implementation choice, consistent with ROADMAP Phase 10 ("initially using Open-Meteo")**; not an ADR |
| Nominatim reverse geocoding | **Implementation choice**; lives in the ViewModel (DEV-A1) |
| Offline-first: "external APIs use caching or are non-blocking" | **Partial.** Weather is cached, but startup awaits it (DEV-A5); light pollution never works |
| Astronomy calculated natively, "maintaining scientific accuracy" | **Overstated.** Adequate for planning; simplifications undocumented (SI-009) |
| UTC internally, local time in the UI | **Only partly true.** Mixed time bases produce a wrong default night (SI-010) |
| Configurable minimum altitude, default 20° | **Configurable in the ViewModel only**; no UI control (SI-006) |

---

# Part E — Open decisions register (Proposed / Pending — **NOT accepted**)

Nothing below is approved unless its row is marked **RESOLVED** (recorded in E.1).
Recommendations are proposals from the audit. Decisions that block the Master
Development Roadmap are marked **[roadmap-blocking]**. PD-17–PD-21 are placeholders
registered by TASK 0.2; each is decided in its own ADR task in `docs/MASTER_ROADMAP.md`.

| ID | Decision needed | Evidence | Options | Recommendation (proposal) | Blocks |
| --- | --- | --- | --- | --- | --- |
| PD-01 **[roadmap-blocking]** | Session-night semantics and the default night rule | SI-010, TD-001 | (a) current night if the Sun is below −0.833°, otherwise the upcoming night; (b) always the next evening; (c) explicit date only with a "Tonight" button | (a): a site-local solar noon-to-noon window; the date picker means "the night beginning that evening". Proposed first implementation task once the roadmap is approved | Capture planner, Imaging Opportunity, weather alignment |
| PD-02 **[roadmap-blocking]** | Site time-zone strategy | SI-010, TD-020 | (a) device zone (status quo); (b) provider offset stored per site (online); (c) bundled time-zone database + coordinate lookup (offline); (d) compute in solar/UTC time, display in a labelled zone | Compute in UTC/solar time (no zone needed); choose the display zone explicitly; evaluate (d) with (b) as offline-first, (c) if civil clock times are required. DST must be tested | Weather alignment, log display, remote-site planning |
| PD-03 | Equipment model direction (extends the Phase 0 pending decision "normalize … immediately or through a staged migration") | DEV-D2 | (a) keep the flat projection over 1:1:1 storage; (b) expose composition (reusable camera modules and rigs, tracking state); (c) collapse to flat | Decide before further equipment work; (b) matches the Phase 4 intent | Equipment UI, catalog work |
| PD-04 **[roadmap-blocking]** | Persistence baseline and migration strategy | DEV-D1, DEV-D6, TD-004/005 | (a) repair the v5 step and test every upgrade path; (b) declare v9 the floor (no installs below v8 exist), drop legacy steps, add Drift schema snapshots + migration tests, enable foreign keys, retire the orphan table; (c) recreate the database | (b) **if** the owner confirms no external installs — destructive steps need explicit approval (Migration Rules) | Any schema change |
| PD-05 | Light-pollution / Bortle source and the "unknown" policy | SI-007, TD-006 | (a) manual Bortle/SQM entry with an unknown state; (b) offline artificial-sky-brightness dataset (licence and size to be evaluated); (c) keyed API (needs secret handling, rule 15); (d) keep scraping (not recommended) | (a) now, (b) later; remove the scraper | Phase 11 |
| PD-06 ~~[roadmap-blocking]~~ **RESOLVED 2026-09-21** | Declare the active roadmap phase; approve or gate the implemented-ahead features (field mode, light-pollution context, metadata import, logbook, export) and how gates are enforced | DEV-P1, DEV-P3, TD-014, TD-041 | Approve and document each, or hide them; enforce gates in routes **and** buttons | **Resolved — see E.1.** (Original proposal: owner declares the active phase; align `FeatureScope` with approvals.) | The whole roadmap |
| PD-07 | Ephemeris / astronomical engine (Phase 0 pending decision) | SI-002, SI-009, SI-012 | Keep hand-written code (documented and validated); truncated series (Meeus) in-house; adopt a package | Decide with the Moon-geometry requirement | Moon services, moving objects |
| PD-08 **[roadmap-blocking]** | Capture-budget model: what counts against the night window; overhead model; calibration-frame policy | TD-022, DEV-A4 | Lights only vs all frames; per-frame vs per-N-frames vs per-filter-change vs per-hour overheads; darks/bias off-night, flats at twilight | Owner product decision; configurable overhead | Capture planner (central component) |
| PD-09 | Provenance storage (Phase 0 pending decision) | DEV-D5 | Per-row source columns vs a `data_sources` table; confidence field | Decide with PD-04 | SI-011, SI-007 fixes |
| PD-10 | Aperture semantics, field naming and migration policy for user-entered rows | SI-005 | `focalRatio` and/or `apertureDiameterMm`; explicit unit suffixes | Owner decision; no silent guessing of existing rows | Equipment fixes, NPF |
| PD-11 | Whether and how NPF is surfaced; default K | SI-001 | Hide; show as a labelled recommendation for untracked exposure; K = 1 or parameter | Not before the formula fix and independent tests | UI |
| PD-12 | Licence intent (repository is GPL-3.0) and third-party terms (Open-Meteo, Nominatim, OSM tiles) for distribution | TD-031 | Confirm GPL-3.0; review store distribution and commercial-use terms | Owner decision before any release | Release |
| PD-13 | `GEMINI.md` deliverable / agent-instruction file policy | DEV-P7 | Restore as tracked; drop from roadmap deliverables; keep ignored | Owner decision | — |
| PD-14 | "Custom Dashboard" scope | Listed by the previous audit as a next step; absent from PRODUCT_SPEC and ROADMAP | Add to the roadmap with a phase; drop | Owner decision | UI roadmap |
| PD-15 | Weather provider/model and date alignment | TD-017 | Keep `icon_seamless`; make the model configurable; fetch by session date within the provider horizon | Decide with PD-02 | Phase 10 |
| PD-16 | Moving-object target types (Planet, Moon, Comet, Asteroid) | SI-012 | Hide until an ephemeris exists; keep with a warning | Hide until PD-07 | Target UI |
| PD-17 *(placeholder, registered 2026-09-21)* | Imaging-opportunity semantics: which conditions **gate** a window and which only **annotate** it | Fixed gates and a heuristic warning (Moon > 0.8 or Bortle ≥ 7); MASTER_ROADMAP TASK 10.1 | Decided in TASK 10.1. Roadmap's proposed starting point (not accepted): gates = Sun ≤ the darkness limit, target ≥ the minimum altitude, the horizon; annotations = Moon altitude, illumination and separation, cloud, dew; optional user-enabled Moon or cloud gates; explicitly no composite score | — | Opportunity calculator (10.2) |
| PD-18 *(placeholder, registered 2026-09-21)* | Session aggregate, lifecycle and snapshots | `SessionLog` conflates plan and result; the "current session" is implicit ViewModel state; MASTER_ROADMAP TASK 11.1 | Decided in TASK 11.1, before any migration | — | Session schema migration (11.2), information architecture (12.1) |
| PD-19 *(placeholder, registered 2026-09-21)* | Information architecture and navigation (also resolves PD-14) | A single scrolling page with icon entry points; MASTER_ROADMAP TASK 12.1 | Decided in TASK 12.1. Roadmap's candidate (not accepted): bottom navigation Tonight · Sessions · Gear & Targets · Settings; execution as a full-screen route; PD-14 resolved as a fixed Tonight view, not a customizable dashboard | — | Navigation shell (12.2), execution and logbook screens |
| PD-20 *(placeholder, registered 2026-09-21)* | Execution model under Android constraints | No execution concept exists; timers die in the background; MASTER_ROADMAP TASK 13.1 | Decided in TASK 13.1. Roadmap's candidate (not accepted): foreground only; progress derived from persisted UTC timestamps; every transition persisted; notifications deferred; no camera control, ASCOM or INDI. A wakelock dependency for keep-screen-on would need separate approval | — | Execution tasks 13.2–13.4 |
| PD-21 *(placeholder, registered 2026-09-21)* | Supported image-metadata formats for assisted logging | TD-018, F-45; MASTER_ROADMAP G17 | Decided in TASK 17.1, against real sample files | — | Metadata-assisted logging (G17, v1.1) |

## E.1 Resolved decisions

### PD-06 — Active scope and gating of features built ahead of their phase (RESOLVED 2026-09-21)

- **Decided by:** the project owner, in chat, on 2026-09-21: "Stick to the decision
  from the roadmap and move on to the next task" — i.e. the recommendation in
  MASTER_ROADMAP TASK 0.2 is adopted as written.
- **Active scope:** the tasks of `docs/MASTER_ROADMAP.md`, one per cycle in roadmap
  order (OD-06). No single "active phase" is named; the roadmap's current task is
  the active scope (line maintained in `docs/ROADMAP.md`, "Adopted plan").
- **Gate policy for features that already exist in the code:**
  - **Stay visible** (they are on the core path): the **logbook** and **text sharing**.
  - **Hidden** until their group: **metadata import** until G17 (v1.1); the
    **light-pollution map card** until TASK 7.4; the **field-mode toggle** until TASK 12.4.
- **Enforcement:** by TASK 4.3 — every entry point (buttons, cards, routes) gated
  from one source (`FeatureScope`), with a test that a gated feature has no entry
  point. **This decision is recorded only; no code was changed by TASK 0.2.**
- **Consequence for the actual state:** the code still disagrees with the policy
  (`metadataImport = true`; field-mode toggle and map card ungated; Home pushes
  gated routes unconditionally). That remains DEV-P1 / TD-014, **open** until 4.3.
  DEV-P3 and TD-041 (no declared scope) are resolved by this decision.
- **Not decided here:** whether the manual Bortle badge and any other gated element
  change visibility — not addressed by the roadmap text; revisit in TASK 7.4.
