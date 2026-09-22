# AstroPlan Decisions

> **Verification stamp:** conformance checked against code at commit `900b82a`
> (2026-09-20), audited 2026-09-21. Application code has since been changed by
> TASKs 1.1–1.3 (`2357755`, `2e17093`, `94acd71`, `97924a0`); Part B was not re-audited
> as a whole after them.
> **Updated 2026-09-21 (TASK 0.2):** PD-06 resolved (E.1), PD-17–PD-21 registered,
> OD-06 recorded, DEV-P3 marked resolved. **TASK 0.3:** PD-13 resolved (E.1),
> DEV-P7 marked resolved. No ADR in Part A was changed.
> **Updated 2026-09-22 (TASK 2.1, documentation only, no code changed):** ADR-007
> (SessionNight and time-zone strategy) accepted in the new Part F; PD-01 and PD-02
> resolved (E.1). The time-handling code was re-read for this task
> (`visibility_calculator.dart`, `planner_viewmodel.dart`, `altitude_chart_widget.dart`,
> `sky_darkness_widget.dart`, `home_screen.dart`, `open_meteo_weather_repository.dart`,
> `session_log.dart`) at commit `56344e2`. **TASK 2.2 (2026-09-22):** ADR-007 status
> line updated (domain part implemented). **TASK 2.3 (2026-09-22, `de1792a`):**
> ADR-007 §8/§9 implemented (typed timeline, shared sampling grid, the altitude
> chart made render-only). **TASK 2.4 (2026-09-22, `1e58fcf`):** ADR-007 §5/§6
> implemented (`PlannerViewModel.sessionNight`, `NightTimeFormatter`); PD-01/PD-02
> now fully realized in the running app, not just the domain layer.
> **Updated 2026-09-22 (TASK 3.1, documentation only, no code changed):** ADR-008
> (persistence baseline, migration workflow, provenance) accepted in Part F; PD-04
> and PD-09 resolved (E.1). Checked against `app_database.dart`, the table
> definitions, the seeders, `drift_equipment_repository.dart`, the git history of
> the schema, and the Drift 2.35.0 source, at commit `33a212b`. **TASK 3.2
> (2026-09-22, commit `3c25e8c`):** ADR-008 §2–§3 implemented; status block updated.
> **TASK 3.3 (2026-09-22, commit `e580d03`):** ADR-008 sections 4-5 implemented
> (foreign keys, orphan cleanup, equipment_profiles dropped); PD-04's E.1 entry
> and the ADR-008 status block updated. **TASK 4.3 (2026-09-22, commit `576c069`):**
> PD-06's enforcement is implemented; DEV-P1 resolved; ADR-006's conformance
> row updated to Complies. **TASK 4.4 (2026-09-22, commit `514dcc5`):** DEV-P2
> resolved for the label half (ADR-005's "must not be labeled as absolute
> SNR" is now met); ADR-005's conformance row updated to Complies. The NPF
> formula/test deviation and undocumented-assumptions parts of DEV-P2 are
> unchanged (SI-001, SI-003, SI-009) — out of this task's scope.
>
> Structure:
> - **Part A** — accepted ADRs and pending decisions, preserved **verbatim** from
>   the Phase 0 baseline. Nothing in Part A has been edited or re-interpreted.
> - **Part B** — conformance audit: which decisions the implementation follows and
>   the **IMPLEMENTATION DEVIATIONS** where it does not.
> - **Part C** — owner directives recorded from this reconciliation.
> - **Part D** — behaviors *inferred* by the previous audit (not ADRs), corrected.
> - **Part E** — open decisions register (**Proposed / Pending — not accepted**).
> - **Part F** — ADRs accepted after the Phase 0 baseline (ADR-007 onwards).

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
| ADR-005 | Scientific calculations are auditable; relative gain not labeled SNR | **Complies** *(label, TASK 4.4)* | DEV-P2 (partially resolved) |
| ADR-006 | Hide implemented future-phase features behind `FeatureScope` until approved | **Complies** *(TASK 4.3)* | DEV-P1 (resolved) |

## DEV-P1 — ADR-006 gating is only partly implemented
- **Intended behavior:** later-phase features already in the code are hidden behind
  `FeatureScope` gates — field mode; light-pollution context and external map
  handoff; metadata import; logbook UI and save action — until their phases are
  explicitly approved.
- **Actual behavior (historical)** (`lib/core/config/feature_scope.dart`,
  `lib/presentation/navigation/app_router.dart`, `home_screen.dart`,
  `sky_darkness_widget.dart`):
  - `fieldMode = false` was **defined but never read**; the field-mode toggle was live
    in Home's app bar.
  - `lightPollutionContext = false` gated only the Bortle badge. The **external map
    handoff card was ungated** and opened a URL with hard-coded Slovenia coordinates;
    `_fetchBortle` still runs on every location change.
  - `metadataImport = true` and `logbook = true`: the routes were enabled with no
    recorded approval (ADR-006 lists both as initially disabled).
  - Home's app-bar buttons pushed `/logbook` and `/metadata` unconditionally, so
    switching either gate off would have navigated to a route that did not exist.
- **RESOLVED 2026-09-22 (TASK 4.3, commit `576c069`; suite 201/201).**
  `FeatureScope.metadataImport` now reads `false`, matching ADR-006/PD-06
  (`fieldMode`/`lightPollutionContext` were already correctly `false`). Every entry
  point reads `FeatureScope` directly: Home's field-mode toggle, Import Metadata
  button and light-pollution map card are each wrapped in `if (FeatureScope.*)`,
  the same pattern `app_router.dart`'s route registration and
  `sky_darkness_widget.dart`'s Bortle badge already used. Verified by tests that a
  gated feature has no icon, tooltip, card or route.
- **Consequence (historical, now resolved).** The scope discipline the ADR was
  written to provide was not enforced; features from Phases 11–15 were
  user-visible with no record of approval (open decision PD-06, resolved E.1).
  TD-014.

## DEV-P2 — ADR-005 is not met (label half resolved TASK 4.4)
- **Intended behavior:** calculations document units, assumptions, valid ranges,
  references and tests; "Relative stacking gain must not be labeled as absolute SNR."
- **Actual behavior (historical):** the UI label was `Stacking Gain (Relative SNR)`
  (`capture_plan_widget.dart:215`, restored on purpose in commit `1baa514`).
- **RESOLVED 2026-09-22 (TASK 4.4, commit `514dcc5`), label only:** the label now
  reads "Relative stacking gain (√N vs one frame)"; the string "SNR" no longer
  appears anywhere in `lib/`. `optical_calculator.dart`'s doc comment already
  correctly described the metric as relative gain.
- **Still open (unchanged by TASK 4.4):** the NPF formula deviates from the
  published one and its test is circular; assumptions and references are mostly
  undocumented. Details: `docs/SCIENTIFIC_INTEGRITY.md` SI-001, SI-003, SI-009.
  TD-007, TD-036.

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
- **Status: RESOLVED 2026-09-21 (TASK 0.3).** The owner decided to drop `GEMINI.md`
  as a deliverable (PD-13, E.1). `CLAUDE.md` is the agent-instruction file, and the
  `GEMINI.md` ignore rule was removed (commit `714426d`). The Phase 0 deliverable
  list in `docs/ROADMAP.md` is annotated as amended; its original text is kept.

## DEV-P8 — The testing rule cannot currently be satisfied literally
- **Intended behavior:** `.agents/rules/03-testing.md`: "Run `flutter analyze` and
  `flutter test` before claiming a change is complete."
- **Actual behavior:** `flutter analyze` is clean, but `flutter test` exits non-zero
  because `test/integration_flow_test.dart` fails (pre-existing; root cause in
  TD-003).
- **Consequence:** until TD-003 is fixed, agents must report the failure as
  pre-existing and confirm that no *additional* test fails (recorded in `CLAUDE.md`).
- **Status: RESOLVED 2026-09-21 (TASK 1.1, commit `2357755`).** TD-003 is fixed and
  `flutter test` is green (73/73, three consecutive runs), so the rule can be
  satisfied literally again. Any failing test is now a regression; `CLAUDE.md` was
  updated.

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
| Storage uses empirical average RAW size | **True as implemented**, but PRODUCT_SPEC also requires distinguishing theoretical payload; seeds still carry no size, but as of TASK 4.4 the UI shows "Unknown" rather than a fabricated `0.0 MB` (SI-008, SI-013) |
| Relative gain presented as a statistical metric "explicitly avoiding … absolute SNR" | **True as of TASK 4.4.** The metric, doc comment and UI label are now all consistent (DEV-P2 label half resolved) |
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
| PD-01 ~~[roadmap-blocking]~~ **RESOLVED 2026-09-22** | Session-night semantics and the default night rule | SI-010, TD-001 | (a) current night if the Sun is below −0.833°, otherwise the upcoming night; (b) always the next evening; (c) explicit date only with a "Tonight" button | **Resolved — see E.1 and ADR-007 (Part F):** civil evening date at the site; mean-solar-noon window; default = the window containing *now* (the roadmap rule, not option (a)). (Original proposal: (a): a site-local solar noon-to-noon window; the date picker means "the night beginning that evening". Proposed first implementation task once the roadmap is approved.) | Capture planner, Imaging Opportunity, weather alignment |
| PD-02 ~~[roadmap-blocking]~~ **RESOLVED 2026-09-22** | Site time-zone strategy | SI-010, TD-020 | (a) device zone (status quo); (b) provider offset stored per site (online); (c) bundled time-zone database + coordinate lookup (offline); (d) compute in solar/UTC time, display in a labelled zone | **Resolved — see E.1 and ADR-007 (Part F):** (d) now — compute in UTC through a `SiteTimeContext` seam with a mean-solar fallback; the site's IANA zone and the `timezone` package arrive in TASK 7.1, where (b)/(c) are evaluated as the zone source. (Original proposal: compute in UTC/solar time (no zone needed); choose the display zone explicitly; evaluate (d) with (b) as offline-first, (c) if civil clock times are required. DST must be tested.) | Weather alignment, log display, remote-site planning |
| PD-03 | Equipment model direction (extends the Phase 0 pending decision "normalize … immediately or through a staged migration") | DEV-D2 | (a) keep the flat projection over 1:1:1 storage; (b) expose composition (reusable camera modules and rigs, tracking state); (c) collapse to flat | Decide before further equipment work; (b) matches the Phase 4 intent | Equipment UI, catalog work |
| PD-04 ~~[roadmap-blocking]~~ **RESOLVED 2026-09-22** | Persistence baseline and migration strategy | DEV-D1, DEV-D6, TD-004/005 | (a) repair the v5 step and test every upgrade path; (b) declare v9 the floor (no installs below v8 exist), drop legacy steps, add Drift schema snapshots + migration tests, enable foreign keys, retire the orphan table; (c) recreate the database | **Resolved — see E.1 and ADR-008 (Part F):** (b), with the floor at **v8**. (Original proposal: (b) **if** the owner confirms no external installs — destructive steps need explicit approval (Migration Rules).) | Any schema change |
| PD-05 | Light-pollution / Bortle source and the "unknown" policy | SI-007, TD-006 | (a) manual Bortle/SQM entry with an unknown state; (b) offline artificial-sky-brightness dataset (licence and size to be evaluated); (c) keyed API (needs secret handling, rule 15); (d) keep scraping (not recommended) | (a) now, (b) later; remove the scraper | Phase 11 |
| PD-06 ~~[roadmap-blocking]~~ **RESOLVED 2026-09-21** | Declare the active roadmap phase; approve or gate the implemented-ahead features (field mode, light-pollution context, metadata import, logbook, export) and how gates are enforced | DEV-P1, DEV-P3, TD-014, TD-041 | Approve and document each, or hide them; enforce gates in routes **and** buttons | **Resolved — see E.1.** (Original proposal: owner declares the active phase; align `FeatureScope` with approvals.) | The whole roadmap |
| PD-07 | Ephemeris / astronomical engine (Phase 0 pending decision) | SI-002, SI-009, SI-012 | Keep hand-written code (documented and validated); truncated series (Meeus) in-house; adopt a package | Decide with the Moon-geometry requirement | Moon services, moving objects |
| PD-08 **[roadmap-blocking]** | Capture-budget model: what counts against the night window; overhead model; calibration-frame policy | TD-022, DEV-A4 | Lights only vs all frames; per-frame vs per-N-frames vs per-filter-change vs per-hour overheads; darks/bias off-night, flats at twilight | Owner product decision; configurable overhead | Capture planner (central component) |
| PD-09 **RESOLVED 2026-09-22** | Provenance storage (Phase 0 pending decision) | DEV-D5 | Per-row source columns vs a `data_sources` table; confidence field | **Resolved — see E.1 and ADR-008 §6:** per-row `source` + `confidence`, added by the owning tasks. (Original: decide with PD-04.) | SI-011, SI-007 fixes |
| PD-10 | Aperture semantics, field naming and migration policy for user-entered rows | SI-005 | `focalRatio` and/or `apertureDiameterMm`; explicit unit suffixes | Owner decision; no silent guessing of existing rows | Equipment fixes, NPF |
| PD-11 | Whether and how NPF is surfaced; default K | SI-001 | Hide; show as a labelled recommendation for untracked exposure; K = 1 or parameter | Not before the formula fix and independent tests | UI |
| PD-12 | Licence intent (repository is GPL-3.0) and third-party terms (Open-Meteo, Nominatim, OSM tiles) for distribution | TD-031 | Confirm GPL-3.0; review store distribution and commercial-use terms | Owner decision before any release | Release |
| PD-13 **RESOLVED 2026-09-21** | `GEMINI.md` deliverable / agent-instruction file policy | DEV-P7 | Restore as tracked; drop from roadmap deliverables; keep ignored | **Resolved — see E.1.** (Original: owner decision.) | — |
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
- **Enforcement — DONE 2026-09-22 (TASK 4.3, commit `576c069`):** every entry point
  (buttons, cards, routes) gated from one source (`FeatureScope`), with tests that
  a gated feature has no entry point. **This decision was recorded only when
  written; no code was changed by TASK 0.2 — TASK 4.3 implemented it.**
- **Consequence for the actual state (historical, resolved TASK 4.3):** the code
  used to disagree with the policy (`metadataImport = true`; field-mode toggle and
  map card ungated; Home pushed gated routes unconditionally). DEV-P1 / TD-014 are
  now resolved. DEV-P3 and TD-041 (no declared scope) are resolved by this decision.
- **Not decided here:** whether the manual Bortle badge and any other gated element
  change visibility — not addressed by the roadmap text; revisit in TASK 7.4.

### PD-13 — `GEMINI.md` and the agent-instruction file policy (RESOLVED 2026-09-21)

- **Decided by:** the project owner, in chat, on 2026-09-21 (TASK 0.3), choosing
  "Drop GEMINI.md" from three offered options (restore as tracked / drop / keep ignored).
- **Decision:** `GEMINI.md` is **not** a project deliverable. `CLAUDE.md` is the
  agent-instruction file; `.agents/rules/` holds the shared rules.
- **Actions taken:** the `GEMINI.md` line was removed from `.gitignore` (commit
  `714426d`); the Phase 0 deliverable list in `docs/ROADMAP.md` is annotated as
  amended (original text kept); DEV-P7 marked resolved.
- **Not changed:** the audited-status table in `docs/ROADMAP.md` (a snapshot) and the
  audit documents, which still describe `GEMINI.md` as "git-ignored and absent".

### PD-01 — Session-night semantics and the default night rule (RESOLVED 2026-09-22)

- **Decided by:** the project owner, in chat, on 2026-09-22 (TASK 2.1). They chose
  the recommended option for each of two questions:
  - **Identity:** "Civil date at site" over the roadmap's literal "mean-solar date".
  - **Default:** "Window containing now" (the MASTER_ROADMAP TASK 2.1 rule) over
    PD-01 option (a), the Sun-altitude rule.

  The owner's task brief also required that the selected calendar date means "the
  night starting on the evening of that date" and must not be replaced with
  solar-noon semantics.
- **Decision:** see **ADR-007** (Part F), §2–§5.
- **What this refines in documented intent (recorded, not rewritten):**
  - MASTER_ROADMAP TASK 2.1 says the window "needs no time zone". The window's
    *instants* still need none, but choosing *which* solar noon a civil date refers to
    needs a time context (ADR-007 §3). TASK 2.2's `forEveningDate(date, site)` and
    `resolveDefault(now, site)` therefore take a `SiteTimeContext` as well.
  - PD-01's original recommendation (a) is **not** adopted. Consequence, accepted by
    the owner: between sunrise and the next mean solar noon the default is the night
    that has just ended (ADR-007 §5, L4).
- **Not implemented.** The code still uses the UTC calendar date (TD-001, SI-010 remain
  open until TASKs 2.2–2.4).

### PD-02 — Site time-zone strategy (RESOLVED 2026-09-22)

- **Decided by:** the project owner, in chat, on 2026-09-22 (TASK 2.1), choosing
  "Defer to TASK 7.1" over "Add in 2.2" for the `timezone` package, together with the
  identity decision above.
- **Decision:** see **ADR-007** (Part F), §6–§7.
  - Computation is in UTC through a `SiteTimeContext`. The device zone is never used
    in computation.
  - Display uses the site's IANA zone when it is known, otherwise the device zone,
    always labelled.
  - Until TASK 7.1 stores a zone per site, every site uses the mean-solar context
    (known limitation L1).
- **Deferred to TASK 7.1** (not decided here): the source of a site's IANA zone,
  either the provider offset (option b) or a bundled database with a coordinate
  lookup (option c), and the `timezone` dependency itself.
- **Not implemented.**

### PD-04 — Persistence baseline and migration strategy (RESOLVED 2026-09-22)

- **Decided by:** the project owner, in chat, on 2026-09-22 (TASK 3.1). They chose
  the recommended option for three questions:
  - **Floor:** v8, with backup and reset for older databases, over repairing every
    path.
  - **v10 cleanup:** drop the orphan table and the legacy columns, over dropping the
    table only.
  - **Orphans:** delete them and log the counts, over aborting and leaving foreign
    keys off.

  The owner also confirmed that **no installs below v8 need to be preserved**.
- **Decision:** see **ADR-008** §2–§5 (Part F).
- **Refines the original option (b):** the floor is v8, not v9, because v8 → v9 is
  proven to work.
- **Destructive steps approved by this decision**, and only these:
  - renaming (not deleting) a below-floor database after user confirmation;
  - deleting the v1–v7 upgrade steps from the code;
  - in v10: dropping `equipment_profiles`, dropping `optical_multiplier` and
    `bit_depth` through table rebuilds, and deleting orphan rows found by
    `foreign_key_check`.
- **Implemented (TASK 3.2, TASK 3.3):** the floor guard, the file-rename half of
  the reset, the v1–v7 step deletion, and the v10 cleanup (dropping
  `equipment_profiles`, dropping `optical_multiplier`/`bit_depth` through
  table rebuilds, deleting orphan rows found by `foreign_key_check`).
  **Not implemented yet:** the reset path's user-confirmation UI.

### PD-09 — Provenance storage (RESOLVED 2026-09-22)

- **Decided by:** the project owner, in chat, on 2026-09-22 (TASK 3.1), choosing
  "Per-row source + confidence" over "Separate data_sources table".
- **Decision:** see **ADR-008** §6.
  - Nullable `source` and `confidence` columns, with per-field pairs where the
    origins differ.
  - Added by TASKs 7.1, 8.1 and 8.5, not in G3.
  - Legacy rows stay NULL, meaning unknown, never guessed.
- **Not implemented.**

---

# Part F — ADRs accepted after the Phase 0 baseline

*Part A stays verbatim. New ADRs are added here, numbered after ADR-006.*

## ADR-007: SessionNight and time-zone strategy

Status: accepted (owner, 2026-09-22, TASK 2.1). Resolves PD-01 and PD-02.
**Implementation:** partial.
- **Done (TASK 2.2, 2026-09-22):** §2–§6 and §11 in the pure domain
  (`SessionNight`, `CalendarDate`, `SiteTimeContext` with its mean-solar and
  fixed-offset contexts, `SessionNightResolver`, and a `Clock` in `lib/core/time/`),
  with the §12 matrix as tests. The formula is exactly as written in §3, with no
  deviation.
- **Done (TASK 2.3, 2026-09-22, commit `de1792a`):** §8 (typed per-threshold
  timeline, `NightTimeline`/`SunThresholdResult`) and §9 (shared 5-minute sampling
  grid; `AltitudeCurve`; visibility-window boundary clipping in polar night,
  `VisibilityWindow.clippedAtStart`/`clippedAtEnd`) in the pure domain, plus the
  altitude chart made render-only. The old DateTime-based `calculateNightTimeline`/
  `calculateVisibilityWindows` are now thin wrappers over the new API, so no caller
  needed to change.
- **Done (TASK 2.4, 2026-09-22, commit `1e58fcf`):** §5 (`PlannerViewModel.sessionNight`
  resolves the default night through the injectable `Clock`, and a picked
  `CalendarDate` through `forEveningDate`; `newSession()` clears back to the
  default instead of re-setting a fixed UTC `DateTime`) and §6 (one
  `NightTimeFormatter` — `home_screen.dart`, `sky_darkness_widget.dart` and
  `logbook_screen.dart` no longer call `.toLocal()` ad hoc; every instant is
  labelled "device zone, UTC±HH:MM" since the site's own zone is not available
  before TASK 7.1; times after midnight carry a "+1" marker). §9's "no site set"
  state is implemented (`sessionNight`/`eveningDate` return null without a site;
  Home shows a "No site set" subtitle and a placeholder card instead of the
  default London default). §9's Moon-illumination instant is used as an interim
  choice (`startUtc + 12h`) — **G6 has not formally decided it**, so this is
  recorded as provisional in `docs/SCIENTIFIC_INTEGRITY.md`, not as a closed
  decision.
- **Not done yet:** the IANA zone and per-site display zone (TASK 7.1); weather
  alignment (G9); persisting `SessionNight` itself instead of mapping legacy
  instant rows (G11, PD-18) — `home_screen.dart`'s Save Session still stores
  local midnight of the picked evening date, per §10's "legacy rows" proposal;
  `PlannerViewModel.currentAltitude`/`maxAltitude` still run their own
  JD/GMST/LST/LHA pipeline rather than consuming the `AltitudeCurve` (TD-023,
  out of TASK 2.4's roadmap scope).

### 1. Context

The product answers "what can I photograph tonight?", but the code has no definition
of "tonight". Four time bases are mixed (SI-010, TD-001, TD-020, TD-023; code re-read
at `56344e2`):

- **Default date.** `_sessionDate = DateTime.now().toUtc()`
  (`planner_viewmodel.dart:58`, repeated in `newSession()` at `:503`). This is the
  **UTC** calendar date.
- **Timeline and windows.** `calculateNightTimeline` and `calculateVisibilityWindows`
  (`visibility_calculator.dart`) read that `DateTime`'s Y/M/D as the **mean-solar**
  date and scan 24 h from `12:00Z − longitude/15 h`.
- **Date picker.** Supplies a **device-local midnight** `DateTime`
  (`home_screen.dart:129`). Its Y/M/D gets the same mean-solar reading.
- **Altitude chart.** Starts at **device-local** noon of the Y/M/D
  (`altitude_chart_widget.dart:137`). Its "now" dot uses the device clock (`:295`).
- **Night timeline display.** Printed in the **device** zone, with no label
  (`sky_darkness_widget.dart:178`).
- **Lunar illumination.** Evaluated at `_sessionDate` itself (`planner_viewmodel.dart:531`).
  That is "now" on the default path but local midnight after a pick, so the night has
  no defined evaluation instant.
- **Weather.** Requested with `timezone=auto`. Its naive site-local strings are parsed
  as device-local (`open_meteo_weather_repository.dart:66`), and the UTC offset is
  discarded.
- **Sessions.** Stored as an instant (`session_date` epoch), read back as local, and
  printed with a local date (`session_log.dart:65,215`).

Result, verified again for this ADR: at 18:30 PDT on 2026-09-21 in San Francisco,
and at 21:00 EDT on 2026-10-31 in New York, the old rule selects **the next day's**
night.

### 2. SessionNight identity

A SessionNight is identified by **(site, eveningDate)**.

- **eveningDate `D`.** A **civil calendar date at the site**: year, month and day, with
  no time of day and no zone. It is modelled as a date-only value, never as a
  `DateTime` instant.
- **Meaning shown to the user:** "the night that begins on the evening of D and
  continues past midnight into D + 1".
- **Site.** Latitude φ in degrees (north positive) and longitude λ in degrees (east
  positive), with λ normalized to the interval (−180°, 180°]. The site also carries a
  **time context** (§6).

### 3. Window: start and end instants

The window is the half-open UTC interval `[startUtc, endUtc)`.

- **Mean solar offset.** `s(λ) = round(λ × 240 000)` milliseconds. Since 1° equals
  4 min, this is integer arithmetic with an exact, deterministic result.
- **Mean solar noon of solar date d.** `N(d) = d 12:00:00.000Z − s(λ)`.
- **Civil noon of D.** `R = D 12:00` at the site, converted to UTC with the time
  context's offset at that instant. Civil noon never falls inside a DST transition
  under current tz rules, because transitions happen at night.
- **startUtc.** The `N(d)` with d ∈ {D − 1, D, D + 1} that is **nearest to R**. On an
  exact tie, the earlier one is taken; a tie requires the civil offset to differ from
  mean solar time by exactly 12 h, and no current zone does.
- **endUtc.** `startUtc + 24 h` exactly.

Why boundaries sit at **mean solar noon**:

- The Sun is near its daily maximum there. Every dusk that belongs to an evening, and
  the dawn that follows it, therefore falls inside one window.
- The window always contains the local evening.
- The window depends only on λ, D and the time context, **not on any astronomy
  model**. A later improvement to the Sun model can never move a stored night.

Why the **civil** date selects the noon, instead of using the solar date directly: in
date-line zones the solar date differs from the civil date by a day. At Kiritimati
(UTC+14, λ −157.4°), the civil evening of Sep 22 is on solar date Sep 21. Selecting by
civil noon keeps D equal to the user's calendar date everywhere (see T7 and T8).

### 4. Inverse mapping and storage units

- **labelOf(window).** The civil date of `startUtc` in the site's time context.
- **Bijection.** `labelOf(forEveningDate(D)) = D` holds for every D. It was checked over
  730 consecutive days in 13 contexts:
  - Los Angeles, Kiritimati, Tokyo, Berlin, Apia, Urumqi;
  - Asia/Shanghai at Kashgar's longitude, Adak, Tongatapu, Chatham;
  - mean-solar contexts at λ = 180°, −179.99° and 0°.

  The check found 0 violations (scratch script outside the repository, IANA tz data,
  2026-09-22).
- **Storage units.**
  - Instants: UTC, millisecond precision.
  - `eveningDate`: an ISO-8601 date string `YYYY-MM-DD`.

### 5. Default-night resolution

`resolveDefault(now, site)` returns **the window that contains `now`**
(`startUtc ≤ now < endUtc`). Its label is `labelOf(window)`.

- The window's instants depend only on `now` and λ. Only the label depends on the time
  context.
- `now` comes from an injectable `Clock` (TASK 2.2). `DateTime.now()` is not allowed in
  `lib/domain`.
- The default therefore switches exactly once per 24 h, at the site's mean solar noon:
  - After midnight (for example 02:00), the default stays on the night in progress.
  - From sunrise to solar noon it still shows the night that has just ended
    (limitation L4, accepted by the owner).
  - After solar noon, it shows tonight.
- The user can always pick another date.

### 6. Time context, storage and display zone

- **`SiteTimeContext`** is a pure-Dart seam (TASK 2.2) with two members:
  - `offsetAt(DateTime utc) → Duration`;
  - a stable `id`.
- **Implementations:**
  - **Before TASK 7.1:** `MeanSolarTimeContext(λ)` (offset = `s(λ)`, id `solar`) and a
    fixed-offset context. Tests also use a DST-transition fake from `test/support/`.
  - **In 7.1:** an IANA-zone context, added together with the `timezone` package.
- **Production before 7.1:** every site uses `MeanSolarTimeContext`. It agrees with the
  civil rule wherever the civil offset is within 12 h of mean solar time, which covers
  every zone except the date-line anomalies (L1).
- **The device zone is never used in computation.** It is not a time context.
- **Storage.** Every instant is stored in UTC.
- **Display zone.**
  - Use the site's IANA zone when it is known (7.1 onward). Otherwise use the device
    zone.
  - Every displayed time names its zone with an offset, for example
    `19:08 PDT (UTC−7)`.
  - When the display zone is the device zone rather than the site's zone, the UI says
    so.
  - Times after midnight carry a next-day marker. The header reads as a night (for
    example "Night of Mon 21 Sep → Tue 22 Sep").
  - Mean solar time is an identity fallback only and is never shown as a clock zone.
- **One formatter** handles all of this (TASK 2.4), with no ad-hoc `toLocal()`.

### 7. DST and the International Date Line

- **DST.**
  - A window is always exactly 24 h long. DST never changes its instants; it only
    changes how they are displayed. For example, Berlin on 2026-10-24 shows
    13:06 CEST → 12:06 CET.
  - In the fall-back night, the repeated hour is disambiguated by the offset label.
  - In the spring-forward night, the skipped hour simply does not appear.
  - Choosing the noon uses the offset at civil noon, which is never ambiguous.
- **Date line.**
  - λ = 180° and λ = −180° are the same site, so they give identical windows.
  - In a civil context, windows are continuous across the antimeridian: sites at
    179.99° and −179.99° that share a zone start 4.8 s apart.
  - In the mean-solar fallback, the *label* jumps by one day across the antimeridian.
    That is inherent to solar time, and it is why civil identity was chosen.
  - Zones whose civil offset differs from mean solar time by about 24 h are handled by
    §3 once the zone is known (7.1). Examples: Kiribati (Line and Phoenix Islands),
    Samoa, Tonga, Tokelau, Chatham.

### 8. Polar conditions and absence of darkness

- **The window is defined for every latitude and every date.** It is never null.
  Polar states are properties of the **darkness content** of a window, not of its
  existence.
- **Per-threshold result (TASK 2.3).** For each Sun-altitude threshold h (−0.833°,
  −6°, −12°, −18°, and the configurable darkness limit), the result is a typed value,
  never a bare `null`. It is one of:
  - **crossing:** a dusk instant and/or a dawn instant. An interval cut off at a window
    edge is flagged `belowAtStart` or `belowAtEnd`.
  - **neverBelow:** the Sun stays above h for the whole window. At h = −0.833° this is
    midnight sun. At h = −18° it means **no astronomical darkness**, as in London in
    June (T15).
  - **alwaysBelow:** the Sun stays below h for the whole window. At h = −0.833° this is
    polar night, and astronomical dusk and dawn can still exist (T14).
- **No fake values.** "Not reached" is never shown as a time, as zero, or as a default
  (SI-008).
- **Visibility windows when the darkness limit is `neverBelow`:** the list is empty,
  with the reason "no darkness at the chosen limit".

### 9. Relationships

- **Site.** A SessionNight exists only for a site.
  - When the site changes, the same D is re-resolved at the new site. The date is the
    user's intent; the instants are not.
  - When no site is set, there is no SessionNight. TASK 2.4 shows a "no site set" state
    instead of the silent London default.
- **Target visibility and the timeline (TASK 2.3, G10).**
  - The night timeline, visibility windows and altitude curve are all computed in the
    domain over `[startUtc, endUtc)`.
  - They share one sampling grid anchored at `startUtc`; the 5-minute step is kept
    (TASK 2.3).
  - A visibility window can touch a window boundary only when the Sun is below the
    limit at mean solar noon, that is in polar night. Such a window is clipped and
    flagged.
  - Night-level scalars, such as Moon illumination, are evaluated at a defined instant
    of the night. G6 chooses that instant; a candidate is mean solar midnight,
    `startUtc + 12 h`.
- **Weather (G9).**
  - Weather samples are keyed by UTC instants. Provider-local times are converted with
    the provider's offset, or UTC is requested.
  - A night's weather is the set of samples with `startUtc ≤ t < endUtc`, usually
    summarized over the darkness interval.
  - A night beyond the provider's horizon has **no forecast** (unknown), never zero.
  - Weather never defines or shifts the night.
  - The zone the provider reports is one candidate source for the site zone in 7.1
    (not decided here).
- **Capture budget and imaging opportunity (G5, G10).** These consume the darkness
  intervals of the SessionNight. Their rules are not decided here (PD-08, PD-17).

### 10. What is persisted and what is calculated

- **Persisted.** The schema itself is decided in G11 (PD-18).
  - `eveningDate` as `YYYY-MM-DD` text: never an instant or epoch.
  - The site: a reference plus a coordinate snapshot.
  - The `id` of the time context used to resolve the night.
  - Real event instants (created, started, ended, frame times), in UTC.
- **Calculated, never the stored source of truth.** `startUtc`/`endUtc` (pure
  arithmetic), the night timeline, darkness intervals, visibility windows and altitude
  curves. Result snapshots for logs are PD-18.
- **Legacy rows** (`session_date` as an instant). The mapping is decided in TASK 2.4 or
  G11. Proposal: take the device-local calendar date of the stored instant, which is
  what the old app displayed after a reload, and flag the row as legacy-mapped.

### 11. Invariants (TASK 2.2 must enforce and test all of them)

| # | Invariant |
| --- | --- |
| I1 | `endUtc − startUtc` = 86 400 000 ms exactly, on every date including DST transitions |
| I2 | `startUtc + s(λ)` has time of day exactly 12:00:00.000: every start is a mean solar noon of the site |
| I3 | Tiling: `forEveningDate(D + 1).startUtc == forEveningDate(D).endUtc`, with no gaps or overlaps |
| I4 | Bijection: `labelOf(forEveningDate(D)) == D`, and `forEveningDate(labelOf(w)) == w` |
| I5 | `resolveDefault(now)` contains `now`, with a half-open interval: `now == endUtc` belongs to the next night |
| I6 | Monotonic: `now₁ ≤ now₂` implies `default(now₁).startUtc ≤ default(now₂).startUtc`; the label changes exactly once per 24 h, at mean solar noon |
| I7 | 18:00 civil on D lies in the window of D whenever the context's offset is within 6 h of mean solar time, modulo 24 h (true for every current zone in the sweep) |
| I8 | The output depends only on (`now` or D, φ, λ, context), never on the host or device zone; tests pass under several host `TZ` values |
| I9 | A window exists for every φ ∈ [−90°, 90°] and every D; the resolver never returns null |
| I10 | λ is normalized to (−180°, 180°]; λ = 180° and λ = −180° give identical results |
| I11 | `startUtc` and `endUtc` are UTC (`isUtc`); `eveningDate` carries no time or zone |
| I12 | The window does not depend on any Sun or Moon model |

### 12. Test matrix (becomes the TASK 2.2 table)

**Test conditions:**
- **Expected values.** Window instants are exact arithmetic from §3. Offsets come from
  IANA tz data (2026 rules: EU DST 29 Mar–25 Oct, US DST 8 Mar–1 Nov).
- **Contexts in 2.2.** 2.2 has no `timezone` package, so it uses fixed-offset contexts
  or a DST-transition fake with those instants.
- **Darkness columns.** These are **indicative only**, for TASK 2.3. They come from an
  independent NOAA-algorithm scratch computation at 1-minute steps, with geometric
  altitude, and are expected to be within ±2 min. **2.3 must re-verify them against
  USNO or NOAA** and must not take them from the code under test.
- **"Old code" column.** The date the current implementation uses.

| # | Case | Site (φ, λ) · context | Input | Expected D | startUtc → endUtc | Site-local display | Indicative sunset · astro dusk / dawn | Old code |
| --- | --- | --- | --- | --- | --- | --- | --- | --- |
| T1 | San Francisco evening | 37.7749, −122.4194 · LA (PDT) | now 2026-09-21 18:30 PDT | 2026-09-21 | 2026-09-21T20:09:40.656Z → 09-22T20:09:40.656Z | 13:09 PDT → 13:09 PDT | 19:08 · 20:36 / 05:30 PDT | 09-22 ✗ |
| T2 | SF after midnight | same | now 2026-09-22 02:00 PDT | 2026-09-21 | = T1 | = T1 | = T1 | 09-22 ✗ |
| T3 | SF morning (L4) | same | now 2026-09-22 09:00 PDT | 2026-09-21 | = T1 | = T1 | = T1 | 09-22 (differs by rule) |
| T4 | SF after solar noon | same | now 2026-09-22 14:00 PDT | 2026-09-22 | 2026-09-22T20:09:40.656Z → 09-23T20:09:40.656Z | 13:09 PDT → 13:09 PDT | 19:06 · 20:34 / 05:30 PDT | 09-22 ✓ |
| T5 | Tokyo after midnight | 35.6762, 139.6503 · +9 | now 2026-09-22 02:00 JST | 2026-09-21 | 2026-09-21T02:41:23.928Z → 09-22T02:41:23.928Z | 11:41 JST → 11:41 JST | 17:41 · 19:06 / 04:04 JST | 09-21 ✓ |
| T6 | Tokyo morning | same | now 2026-09-22 10:00 JST | 2026-09-21 | = T5 | = T5 | = T5 | 09-22 (differs by rule) |
| T7 | Kiritimati (UTC+14) | 1.8721, −157.4278 · fixed +14 | now 2026-09-22 20:00 +14 | 2026-09-22 | 2026-09-21T22:29:42.672Z → 09-22T22:29:42.672Z | 12:29 → 12:29 (+14) | 18:26 · 19:34 / 05:10 | 09-22 ✓; mean-solar fallback labels 09-21 (L1) |
| T8 | Apia (UTC+13) | −13.8333, −171.7667 · fixed +13 | now 2026-09-22 21:00 +13 | 2026-09-22 | 2026-09-21T23:27:04.008Z → 09-22T23:27:04.008Z | 12:27 → 12:27 (+13) | 18:23 · 19:34 / 05:06 | fallback labels 09-21 (L1) |
| T9 | EU DST fall-back night | 52.52, 13.405 · Berlin (fake) | D = 2026-10-24 (and now 21:00 CEST) | 2026-10-24 | 2026-10-24T11:06:22.800Z → 10-25T11:06:22.800Z | 13:06 CEST → 12:06 CET | 17:53 CEST · 19:47 CEST / 04:55 CET | 10-24 ✓ |
| T10 | EU DST spring-forward night | same | D = 2026-03-28 | 2026-03-28 | 2026-03-28T11:06:22.800Z → 03-29T11:06:22.800Z | 12:06 CET → 13:06 CEST | 18:34 CET · 20:34 CET / 04:48 CEST | 03-28 ✓ |
| T11 | US DST fall-back night | 40.7128, −74.0060 · New York (fake) | now 2026-10-31 21:00 EDT | 2026-10-31 | 2026-10-31T16:56:01.440Z → 11-01T16:56:01.440Z | 12:56 EDT → 11:56 EST | 17:54 EDT · 19:26 EDT / 04:54 EST | 11-01 ✗ |
| T12 | US DST spring-forward night | same | now 2026-03-07 21:00 EST | 2026-03-07 | 2026-03-07T16:56:01.440Z → 03-08T16:56:01.440Z | 11:56 EST → 12:56 EDT | 17:55 EST · 19:26 EST / 05:49 EDT | 03-08 ✗ |
| T13 | Tromsø, midnight sun | 69.6492, 18.9553 · Oslo (CEST) | D = 2026-06-20 | 2026-06-20 | 2026-06-20T10:44:10.728Z → 06-21T10:44:10.728Z | 12:44 → 12:44 CEST | sunset **neverBelow** · astro **neverBelow**; no visibility windows | n/a |
| T14 | Tromsø, polar night | same · Oslo (CET) | D = 2026-12-20 | 2026-12-20 | 2026-12-20T10:44:10.728Z → 12-21T10:44:10.728Z | 11:44 → 11:44 CET | sunset **alwaysBelow** · astro dusk 16:56 / dawn 06:29 CET | n/a |
| T15 | No astronomical darkness | 51.5074, −0.1278 · London (BST) | D = 2026-06-20 | 2026-06-20 | 2026-06-20T12:00:30.672Z → 06-21T12:00:30.672Z | 13:00 → 13:00 BST | 21:21 / sunrise 04:43 BST · astro **neverBelow** | n/a |
| T16 | Antimeridian | λ = 180 and λ = −180 · mean-solar | D = 2026-09-22 | 2026-09-22 | both 2026-09-22T00:00:00.000Z → 09-23T00:00:00.000Z | — | — | — |
| T17 | Host-zone independence | T1 inputs | run with host `TZ` = UTC, Asia/Tokyo, America/Los_Angeles | identical to T1 | identical | — | — | — |

**Property tests (TASK 2.2):**
- **P1.** I1–I4 and I7 for every D over 730 days, in these contexts:
  - fixed +14, +13 and +9;
  - the LA and Berlin DST fakes;
  - mean-solar at λ ∈ {−180, −179.99, −122.42, 0, 13.4, 179.99, 180}.
- **P2.** At the T1 site, step `now` by 5 min across 48 h. The default label changes
  exactly twice, at the mean solar noons, and moves monotonically (I5, I6).
- **P3.** λ = 179.99° and −179.99° with the same fixed +12 context give starts less
  than 1 min apart.

**Acceptance for TASK 2.2:** T1, T2, T11 and T12 fail on the old code. That confirms
the regression is covered.

### 13. Alternatives considered

| Alternative | Verdict | Reason |
| --- | --- | --- |
| UTC calendar date (status quo) | Rejected | Off by 24 h west of UTC in the evening (verified: T1, T11, T12) |
| Device-local date, with a device-local noon-to-noon window (the chart's current base) | Rejected | Wrong for remote sites; depends on the host; DST makes the window 23 or 25 h long |
| Site civil noon-to-noon window (civil boundaries) | Rejected | Needs a zone even for the instants; DST gives 23 or 25 h windows; a boundary up to about 3 h from solar noon can split short polar-edge days |
| Mean-solar date and window (roadmap literal, zone-free) | **Fallback only** | Exact outside date-line anomalies; labels the night one day off at Kiritimati, Samoa and Tonga; conflicts with "the user's calendar date" |
| Apparent (true) solar noon or transit boundaries | Rejected | The identity would depend on the Sun model, and the window length would vary. The gain (up to about 16.5 min at the boundary) matters only on polar-edge days (L2) |
| Sunset-to-sunrise window | Rejected | Undefined in polar day and night; depends on the model; excludes twilight |
| PD-01 (a): Sun-altitude default | Rejected by the owner | Morning planning is better, but it depends on the model, and under midnight sun it always skips to the next window |
| PD-01 (b): always the next evening | Rejected | At 02:00 it skips the night in progress |
| PD-01 (c): explicit date only | Rejected | No default for "tonight" |
| PD-02 (a): device zone in computation | Rejected | Non-deterministic; wrong for remote sites. Kept as the **display** fallback only |
| `timezone` package in TASK 2.2 | Deferred to 7.1 (owner) | No coordinate-to-zone source exists before 7.1, so production would not change |

### 14. Known limitations and assumptions

- **L1 (until TASK 7.1).**
  - Every site uses the mean-solar context. In zones whose civil offset differs from
    mean solar time by 12 h or more (Kiribati Line and Phoenix Islands, Samoa, Tonga,
    Tokelau, Chatham), the night is labelled one day off.
  - The window instants are still correct.
  - Displayed times stay honestly labelled.
- **L2.** Boundaries sit at *mean*, not apparent, solar noon (up to about 16.5 min
  apart). A crossing can land in the neighbouring window, flagged as clipped (§8), on
  the few polar-edge days when the Sun's noon altitude is within a fraction of a degree
  of a threshold.
- **L3.** A historical zone discontinuity can leave a date with no civil noon; Samoa
  skipped 2011-12-30. The resolver returns an explicit error for such a date. The date
  picker's range (−1 to +5 years) makes this practically unreachable.
- **L4.** The default switches at mean solar noon. Between sunrise and noon it shows
  the night that has just ended (owner-accepted).
- **Assumptions:**
  - Civil noon is never inside a DST transition.
  - Every current zone is within 6 h of mean solar time modulo 24 h (sweep above).
  - Sun altitude thresholds stay the existing constants (−0.833°, −6°, −12°, −18°).
    Making the darkness limit configurable is TASK 2.3 or TD-043, not this ADR.

### 15. Consequences

- **TASK 2.2** implements §2–§6 and §11–§12 in pure Dart:
  - a `Clock`;
  - a `SiteTimeContext` with its mean-solar and fixed-offset implementations;
  - `SessionNight {eveningDate, startUtc, endUtc, latitude, longitude, timeContextId}`;
  - `forEveningDate(D, site, ctx)`, `resolveDefault(now, site, ctx)` and `labelOf`.

  The shape now includes the time context, which refines the roadmap's listed fields.
- **TASK 2.3** implements §8 and §9 (typed timeline, shared sampling grid, domain
  altitude curve).
- **TASK 2.4** implements the display rules in §6 and the ViewModel adoption.
- **TASK 7.1** adds the site IANA zone, its source, and the `timezone` dependency.
- **G9** aligns weather per §9. **G11** persists per §10.
- SI-010, TD-001, TD-020, TD-023 and TD-024 stay **open** until those tasks land. This
  ADR changes no code.

## ADR-008: Persistence baseline, migration workflow and provenance

Status: accepted (owner, 2026-09-22, TASK 3.1). Resolves PD-04 and PD-09. It also
answers the Phase 0 pending decision "How to store provenance for seeded target and
equipment data" (Part A, unchanged). **Implementation:** partial.
- **Done (TASK 3.2, 2026-09-22, commit `3c25e8c`):** §2 (the v8 floor and the
  downgrade guard, both implemented as `onUpgrade` checks that throw
  `UnsupportedSchemaVersionException` before any statement runs; the v1–v7
  steps are deleted) and §3 (schema snapshots in `drift_schemas/` for v8 and
  v9, `build.yaml` configuring `drift_dev`, generated verification code, and
  the migration test suite — M1, M2, M5–M7, M11 of §7). The v8→v9 step now
  runs inside a transaction, verified atomic by an injected-failure test
  (§3's "each upgrade runs as one unit", previously unverified).
  `resetUnsupportedDatabaseFile` implements the reset half of §2 as a pure
  file operation; **no caller exists yet** — the confirmation UI §2 requires
  is not built.
- **Done (TASK 3.3, 2026-09-22, commit `e580d03`):** §4 (a one-time
  `PRAGMA foreign_key_check` orphan cleanup — deleting and logging the count
  per table — followed by `Migrator.alterTable` rebuilds of
  `camera_modules`/`optical_rigs`/`capture_blocks` to add the real
  `RESTRICT`/`RESTRICT`/`CASCADE` `ON DELETE` actions §4 specifies, and a
  re-check before continuing; `beforeOpen` sets `PRAGMA foreign_keys = ON` on
  every connection; `DriftEquipmentRepository.deleteEquipment` now guards
  against deleting a still-referenced camera module or device) and §5
  (`equipment_profiles` is dropped, and the two legacy columns —
  `optical_multiplier` on `camera_modules`/`optical_rigs`,
  `bit_depth` on `camera_modules` — are gone from the rebuilt tables;
  `app_database_test.dart`'s equipment_profiles test is replaced, per §5's
  own instruction, and the reason is recorded there). The migration test
  suite now covers the full §7 matrix except the bootstrap-UI pieces of M6
  (M1–M4, M5–M9, M11).
- **Not implemented yet:** §6 (provenance columns — TASKs 7.1, 8.1, 8.5) and
  the bootstrap-level confirmation UI for the reset path (§2) and for a
  refused downgrade (TD-047's remaining half).

### 1. Context (verified for this ADR at commit `33a212b`)

- **Schema versions created by committed builds** (`git log` on
  `app_database.dart`):

  | Version | Commit |
  | --- | --- |
  | v1 | `bb327e2` |
  | v2 | `8070dd5` |
  | v3 | `5bc8ba6` |
  | v8 | `d0b737f` |
  | v9 | `900b82a` |

  **v4–v7 were never committed.** They arrived together in `d0b737f`, and could only
  exist on a developer device from uncommitted builds. Every committed build from
  `d0b737f` onwards creates v8 or later. `main` was pushed to `origin`
  (GitHub) at `a1bcbd9`, which contains all of these commits.
- **The upgrade chain** (`app_database.dart`, `onUpgrade`) is a sequence of
  `if (from < n)` steps. They are written against the **current** table
  definitions, not the definitions of their own version (the root cause of DEV-D1):
  - Every path from v1, v2 or v3 is **certain to fail**. `createTable(opticalRigs)`
    uses today's definition, which has no `optical_multiplier`, and then the v5
    `INSERT … SELECT` names that column. v3 → v9 was reproduced on 2026-09-21. v1
    and v2 go through the same step.
  - v8 → v9 works (reproduced 2026-09-21). It leaves **legacy columns** that fresh
    v9 installs lack: `optical_multiplier` (NOT NULL DEFAULT 1.0) on `optical_rigs`
    and `equipment_profiles`, and `bit_depth` (nullable) on `camera_modules`.
- **Downgrades are unguarded** (new finding, recorded as TD-047).
  - Drift calls `onUpgrade` whenever the stored version differs from
    `schemaVersion`, including when it is *higher*
    (`drift-2.35.0/lib/src/runtime/api/db_base.dart:131`,
    `hadUpgrade => versionBefore != versionNow`).
  - With the current `if (from < n)` chain, an older build would run no step and
    then open a newer database as if it matched.
- **Foreign keys are not enforced.**
  - No `beforeOpen` sets `PRAGMA foreign_keys`. An orphan `capture_blocks` insert
    succeeded (verified 2026-09-21).
  - Declared references: `capture_blocks.session_log_id → session_logs`,
    `camera_modules.device_id → devices`, and
    `optical_rigs.camera_module_id → camera_modules`. None has an `ON DELETE` clause.
  - Deletes are hand-written in the repositories. `deleteEquipment` deletes a rig's
    camera module and device without checking for other references.
- **Orphan table.** `equipment_profiles` is not read or written by any application
  code since v4. Only the v5 copy step, the v9 `addColumn` and `app_database_test`
  touch it.
- **No provenance is stored** (DEV-D5).
  - The seeders insert only into an empty table and do not mark their rows.
  - A seeded row therefore cannot be told apart from a user-entered or user-edited
    one after the fact.

### 2. Decision: upgrade floor v8

- **Supported:** databases at **v8 and v9** upgrade in place. Every later version
  must upgrade from v8.
- **Below v8** (`from < 8`): the database is **not migrated**.
  - The app shows a clear message: the database comes from a pre-release build and
    cannot be upgraded.
  - **On the user's explicit confirmation**, it renames the file to
    `astroplan.sqlite.v<from>.bak` (never deletes it) and creates a fresh database.
  - Without confirmation, nothing is touched.
- **Newer than the app** (`from > schemaVersion`): refused, with the same kind of
  message, and the file is left untouched (TD-047). Newer databases are never reset.
- **The legacy v1–v7 steps are removed** from `onUpgrade`.
- **Owner confirmation (2026-09-22):** no installs below v8 need to be preserved.
- **Refines PD-04 option (b):** that option said "declare v9 the floor (no installs
  below v8 exist)". The floor is **v8**, so both v8 and v9 databases are supported.

### 3. Decision: migration workflow (from TASK 3.2 onwards)

- **Tooling.** Use Drift's schema tooling (`drift_dev` 2.35, already a dev
  dependency).
  - A `build.yaml` database entry.
  - Versioned JSON snapshots in `drift_schemas/`: **v8 exported from `d0b737f`**,
    and **v9 from the current code**.
  - Generated `stepByStep` versioned schema classes, and generated
    schema-verification tests.
- **Every schema bump**, as one change:
  - a new snapshot;
  - a `from → to` step written **against the generated schema class of its own
    version**, never against the live table definitions (that is what broke
    DEV-D1);
  - a migration test with sample rows that checks the data survives;
  - a verification test that the upgraded schema equals the fresh schema.
- **Each upgrade runs as one unit.** If it fails, the file is left unchanged. 3.2
  must verify this, because Drift's transaction behaviour for `onUpgrade` is not
  assumed here.
- **Destructive steps** (drop table, drop column, table rebuild, row deletion) need
  explicit owner approval every time. Part A Migration Rules stay in force. This ADR
  approves exactly the destructive steps in §2, §4 and §5.
- **Documentation.** The workflow itself is documented in `DATA_MODEL.md` by TASK
  3.2.

### 4. Decision: foreign keys (TASK 3.3)

- **One-time cleanup in the v10 upgrade step,** with foreign keys **off**:
  1. Run `PRAGMA foreign_key_check`.
  2. **Delete orphan rows**, whose referenced parent does not exist. Log the count
     removed per table (owner decision).
  3. Re-run the check. The step fails if anything remains.
- **Every connection:** `beforeOpen` sets `PRAGMA foreign_keys = ON`.
- **Delete behaviour.** SQLite cannot alter a constraint, so these tables are rebuilt
  in v10:

  | Reference | On delete |
  | --- | --- |
  | `capture_blocks → session_logs` | `CASCADE` |
  | `camera_modules → devices` | `RESTRICT` |
  | `optical_rigs → camera_modules` | `RESTRICT` |

- **Guarded deletes.** Repository deletes of shared equipment rows are guarded: a
  camera module or device is deleted only when no other row references it.
- **Tests** run with foreign keys on, the same as production.

### 5. Decision: v10 cleanup scope (TASK 3.3)

- **Drop `equipment_profiles`.**
- **Rebuild `optical_rigs` and `camera_modules`** without the legacy columns
  `optical_multiplier` and `bit_depth`. Every install then has one schema, and
  snapshot validation is exact.
  - **Accepted data loss (owner):** a non-default multiplier on a developer
    database. The code has ignored the column since `900b82a` (CALC-14 is the
    identity).
- **One step.** The §4 rebuilds and this cleanup are the same v10 step, with one new
  snapshot.
- **Test code.** `app_database_test.dart`'s `equipment_profiles` test is replaced,
  because the table no longer exists. The reason is recorded; this is not a
  weakened test.

### 6. Decision: provenance (per row, PD-09)

- **Columns on tables that hold external or scientific data:**
  - `source`: nullable TEXT, a stable namespaced id. Examples: `user`,
    `seed:equipment@1`, `seed:catalog@1`, `catalog:openngc@<version>`,
    `provider:open-meteo/<model>`, `device:gps`, `geocoder:nominatim`, `exif`,
    `fits`.
  - `confidence`: nullable TEXT, one of:
    - `verified`: checked against a cited primary source;
    - `reported`: taken from a source that was not independently checked
      (manufacturer summary, provider, user entry);
    - `estimated`: derived or approximated, such as an empirical RAW size.
- **Per-field pairs.** A row whose fields have different origins gets per-field
  pairs, for example a site's `bortle_source` and `bortle_date` next to user-entered
  coordinates (TASK 7.1).
- **NULL means unknown.** Legacy rows keep NULL, displayed as "unknown". They are
  **never back-filled by guessing**: seeded rows cannot be identified reliably, and
  users may have edited them (PD-10 applies the same rule).
- **Never the reverse.** A default is never recorded as a measurement, and a NULL
  is never shown as a value (SI-008).
- **No `data_sources` table now.** Citation, licence and attribution text live with
  the asset and the About screen (TASK 8.2). A later `data_sources` table can be
  keyed by the same `source` ids without changing what existing rows mean.
- **Timing.** The columns are **not added in G3**. Each arrives in the additive
  migration of the task that owns its table:
  - 7.1: sites (Bortle/SQM source and date);
  - 8.1: targets (`source`);
  - 8.5: equipment specs (`source`, `confidence`).

  Weather and session snapshots follow the same convention when they are persisted
  (G9, G11).

### 7. Test matrix (for TASKs 3.2 and 3.3)

| # | Case | Task | Expected |
| --- | --- | --- | --- |
| M1 | Fresh install | 3.2 | Schema equals the v9 snapshot (3.3: v10) |
| M2 | v8 (`d0b737f` snapshot) with sample rows → v9. Rows: device → module → rig chain, target, location, session with 2 blocks; `equipment_profiles` both empty and non-empty | 3.2 | All rows intact; new columns NULL; schema equals v9 apart from the documented legacy columns (until v10) |
| M3 | v9 → v10 | 3.3 | Orphan table and legacy columns gone; rows intact; `capture_blocks` cascades; schema equals the v10 snapshot exactly |
| M4 | v8 → v10, step by step | 3.3 | Same as M3 |
| M5 | Below floor: v1, v2 and v3 databases | 3.2 | Specific "unsupported version" error; no step runs; file byte-identical afterwards |
| M6 | Reset path after M5, confirmed | 3.2 | Old file renamed to `astroplan.sqlite.v<from>.bak` with content intact; fresh database at the current version |
| M7 | Downgrade: database stamped at schemaVersion + 1 | 3.2 | Refused; file and `user_version` unchanged (TD-047) |
| M8 | Orphans before v10: orphan block, rig with a missing module | 3.3 | Orphans deleted and counts logged; legitimate rows intact; `foreign_key_check` empty |
| M9 | FKs on after open | 3.3 | `PRAGMA foreign_keys` = 1; an orphan insert throws; deleting a session removes its blocks; deleting a device referenced by a module is refused |
| M10 | Existing repository and database tests | 3.3 | Green with FKs on |
| M11 | Failed upgrade (injected failure mid-step) | 3.2 | File unchanged (§3, one unit) |

### 8. Alternatives considered

| Alternative | Verdict | Reason |
| --- | --- | --- |
| Repair every path from v1 | Rejected (owner) | The v4–v7 schemas were never committed and can only be guessed; each path needs a historical schema and a test; no install needs it |
| Recreate the database on any failure (PD-04 c) | Rejected | Silent data loss on v8/v9 installs |
| Floor v9 (PD-04 b, literal) | Refined to v8 | v8 → v9 is proven to work; a floor of v9 would needlessly reset v8 installs |
| Keep legacy columns and whitelist them | Rejected (owner) | Two schemas forever; the validation cannot be exact |
| Leave FKs off when orphans exist | Rejected (owner) | Integrity would not be guaranteed on that install |
| `data_sources` table | Deferred | Joins and FKs for about 5 sources; can be added later, keyed by the same ids |

### 9. Consequences

- **TASK 3.2:**
  - the snapshots (v8 from `d0b737f`, v9);
  - generated verification;
  - floor and downgrade handling, plus the reset path and its UI message;
  - removal of the v1–v7 steps;
  - M1, M2, M5–M7 and M11;
  - the workflow in `DATA_MODEL.md`.
- **TASK 3.3:** the v10 step (§4, §5), `beforeOpen` with foreign keys on, guarded
  deletes, and M3, M4 and M8–M10.
- **Later tasks** add provenance columns according to §6.
- DEV-D1, DEV-D5, DEV-D6, TD-004, TD-005, TD-026 (partly) and TD-047 stay **open**
  until then. This ADR changes no code.
