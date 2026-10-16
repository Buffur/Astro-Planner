# Stage 11 — Validation matrix (S11.1)

> **Purpose.** The frozen contract of Stage 11's one bounded final validation
> (`POST_ROADMAP_PLAN.md`, "Stage 11 — Full Validation & Beta Readiness", amended 2026-09-27, and
> "Stage 11 — frozen Task sequence", S11.1). S11.2–S11.6 collect evidence only for these rows, and
> S11.7 judges only these rows (V4). Nothing is added by searching for "anything else"; a newly exposed
> severe regression may still block (V4 C). Written 2026-09-30 at `b2e47e6`. Documentation only.

## 1. How to read this matrix

**Sources** (each row names its own): `POST_ROADMAP_PLAN.md` (Stage 11's Scope, "The contract", "What
it checks", "Accessibility and field use", "Degraded states", "Errors, lifecycle and portability",
"Performance", "The readiness record", the Exit; the frozen Task sequences and acceptance of Stages
6–10; "Stages 6–11: shared rules"; Appendix B); `DECISIONS.md` E.1 (D8-*, D9-*, D10-*, D11-1 to D11-6,
RD-08, RD-10, RD-11, S4-DEF-04, RG-03, RG-07 to RG-11, "Stage 6 corrective pass decided") and Part F
(ADR-009, ADR-012, ADR-013, ADR-018, ADR-019, ADR-020); `PROGRESS.md`; the Stage 6–10 validation
reports; `TEST_PLAN.md` (lifecycle L1–L8, metadata M1–M4, the end-to-end suite and the owner
checklists of TASKs 12.4, 12.5, 14.4, 15.2, 15.3, 16.1–16.3); `MASTER_ROADMAP.md` TASKs 2.4, 10.4,
12.4, 12.5, 14.4, 15.2–16.5, M3, AC7 and §9; `COMPLIANCE.md`; `RELEASE.md`; `DATA_MODEL.md` B7 (Auto
Backup); `evidence/STAGE_10_MEASUREMENTS.md`; `CLAUDE.md` traps 12–22 and the Verification Policy.
"11.Z" is the comprehension check of the owner's brief (`prompts/AMEND_STAGES_6_11_AFTER_STAGE5.md`,
"Stage 11.Z"), which S11.5 names.

**Evidence levels** (the plan's words; D11-1 by environment):

| Level | Meaning here |
| --- | --- |
| DOCUMENTED | A dated record exists (an owner action, a cited web page, a document check) |
| CODE VERIFIED | Established by reading the code or configuration |
| TEST VERIFIED | Host tests pass (the quality gate or a named test) |
| RUNTIME VERIFIED (emulator) | Observed on the development machine's emulator (Android 16, API 36, x86_64, Google Play image, user build); never DEVICE VERIFIED |
| DEVICE VERIFIED | Observed on a physical Android phone (the owner's Xiaomi 14T Pro through `.s2check`, D11-3), or a signed build installed from Play |
| HUMAN VERIFIED | A person's recorded observation or judgement (the owner or a participant; never an agent) |
| UNKNOWN | No evidence either way |

**Environments:** HOST (the development machine, tests and tools), EMULATOR (the AVD above; its settings
may be changed and are restored, S11.3), PHONE (the owner's phone over USB, `.s2check` only; no low-end
phone exists), HUMAN (the owner or a participant), OWNER (an action only the owner can take).

**Rules.**
- A row is judged **only at its stated level**. A host test never satisfies a DEVICE row, an emulator
  run never satisfies a DEVICE row (D11-1), and code is never usability evidence.
- **Mandatory for beta readiness** follows D11-2: the core loop on a physical phone, the lifecycle rows,
  TalkBack on the core flow, the signed bundle and its install, the policy live, no P0/P1 open and the
  owner's go/no-go, plus the other pre-upload requirements of TASKs 15.4–16.4 that name a source.
  **"No†"** means: not a D11-2 readiness row, but a failure is still a blocker when it shows an unmet
  frozen criterion, a regression, or a severe defect (V4 A–C). Readiness is not claimed while a
  mandatory row is not VERIFIED at its level (S11.7).
- **Current evidence** is filled only where a passed validation or a recorded run already holds the row
  at its level (reused, V3); S11.2–S11.6 confirm it is still valid. "gate S10.6" is the full quality
  gate PASS of `PROGRESS.md` ("Reusable validation evidence"), Stage 11's baseline per the plan.
  "S*n* val." is `STAGE_n_VALIDATION.md`'s PASS (after its V5 revalidation where one ran).
- **Task:** S11.2 host · S11.3 emulator · S11.4 providers and compliance · S11.5 runbook (PHONE, HUMAN,
  OWNER entries) · S11.6 phone runs · S11.7 the readiness record · HUMAN / OWNER.

## 2. The matrix

### A — Core planning answer and comprehension

| ID | Check | Source | Level needed | Env | Mandatory for beta readiness | Current evidence | Task |
| --- | --- | --- | --- | --- | --- | --- | --- |
| A1 | The planner's first screen (412 × 915; light, dark, field) shows, without scrolling past weather or rig detail: target, night, site and rig; the plan state; the verdict with its relationship ("Fits: … needed of … usable"); time needed; usable time; light integration; the main limiting reason; the next useful action | Stage 6 "Purpose" (seven points); S6.6, S6.16; E.1 "Stage 6 corrective pass decided" §2 | TEST VERIFIED | HOST | No† | S6 val. (S6.6, S6.16: E6) · gate S10.6 | S11.2 |
| A2 | A missing site, target or light block gives its own neutral reason in the status (never the empty plan's "no light frames"), and integration stays visible | S6.8; TD-075 (S6.16) | TEST VERIFIED | HOST | No† | S6 val. (S6.8, S6.16) · gate S10.6 | S11.2 |
| A3 | Every value reachable before Stage 6 is still reachable one level down: each ADR-009 budget line, the assumptions, the rig's full specifications and provenance, sky detail, twilight names, the reason for each excluded interval | Stage 6 Exit; S6.7; "What it checks" (depth reachable) | TEST VERIFIED | HOST | No† | S6 val. (S6.7: E7) · gate S10.6 | S11.2 |
| A4 | Disclosure is one level deep with factual summaries ("Budget details · 2 h 05 min needed"); the "never hidden" list (an unknown that weakens a result, stale or unavailable weather, an active constraint or capability warning, a provenance conflict) stays visible; nothing essential only in a tooltip | Shared rules "Disclosure", "The information hierarchy"; S6.7 | TEST VERIFIED | HOST | No† | S6 val. (S6.7) · gate S10.6 | S11.2 |
| A5 | Tonight leads with the current plan and its answer; its Night and Moon, Weather and result-line rows open their own destinations, never the planner's top; no "Draft" or "Analytics" | S6.13; Stage 9 scope ("Tonight and the other entry points"); ADR-019 §5 | TEST VERIFIED | HOST | No† | S6 val. (S6.13); S9 val. (C) · gate S10.6 | S11.2 |
| A6 | The app bar shows target · night · state; New plan, Copy, Open and Save confirm what happened; replacing a changed plan asks Save · Discard · Cancel; Discard reverts Saved · changed to its snapshot and deletes only a never-saved draft | S6.2, S6.3; RD-05 (U1, W1); S4-DEF-04 = R | TEST VERIFIED | HOST | No† | S6 val. (S6.2, S6.3) · gate S10.6 | S11.2 |
| A7 | "What can I image tonight?" orders by usable time, then frame fill (unknown last), then name; the header names the order; no score | RD-10 = O1; S6.14; ADR-013 §5 | TEST VERIFIED | HOST | No† | S6 val. (S6.14) · gate S10.6 | S11.2 |
| A8 | The five-second test (Stage 6 Test A) on the final build's Tonight and planner first screens, answered word for word by a participant who has not worked on the product | S6.E; Stage 6 Exit (comprehension); E.1 "Stage 6 corrective pass decided" §7 | HUMAN VERIFIED | HUMAN (PHONE) | No — S6.E's gap accepted by the owner (S6 val.); not in D11-2 | — (UNVERIFIED in S6 val.) | S11.5 / HUMAN |
| A9 | The owner runs the comprehension scenarios on the final build (plan tonight's target; adjust a plan that does not fit; save it; report the result later; review history; manage a rig or site) and records whether the retained features are useful, entry is reduced where evidence allows, and information is clear and compact | S11.5 ("the comprehension scenarios of 11.Z"); brief "Stage 11.Z" | HUMAN VERIFIED | HUMAN (PHONE) | No — not in D11-2 | — | S11.5 / HUMAN |
| A10 | The TASK 12.5 owner walkthrough: a fresh install shows the first-run page; a site set by GPS (the permission prompt only after the rationale) and by hand; skipped on a second fresh install; Tonight at large text | TASK 12.5 acceptance; `TEST_PLAN.md` 12.5 owner walkthrough; Appendix B 12.5 | HUMAN VERIFIED | HUMAN (PHONE) | No — not in D11-2 | — | S11.5 / HUMAN |

### B — Night, timeline and opportunity

| ID | Check | Source | Level needed | Env | Mandatory for beta readiness | Current evidence | Task |
| --- | --- | --- | --- | --- | --- | --- | --- |
| B1 | The timeline's drawn intervals equal `imagingOpportunity` and the fit's end; the planned capture is drawn only to the fit's end; no continuous time is drawn across a gap | S6.12; "What it checks" (timeline) | TEST VERIFIED | HOST | No† | S6 val. (S6.12: E12) · gate S10.6 | S11.2 |
| B2 | UX-08 as built: the axis follows the 12/24-hour setting and the site's zone with whole-hour ticks (half-hour zone, DST night), labels off the curves at 100 % and 200 %, no band seams, field-mode bands kept apart by drawn edges | S6.12; UX-08 | TEST VERIFIED | HOST | No† | S6 val. (S6.12) · gate S10.6 | S11.2 |
| B3 | Text alternatives: the timeline names the windows, usable time and capture end; the √N graph, Weather's cloud bars and Night & Moon's twilight timeline have theirs, with unknown and empty states | S6.12; S6.11; S9.6; trap 17; shared rules "Visualisations" | TEST VERIFIED | HOST | No† | S6 val. (S6.11, S6.12); S9 val. (S9.6) · gate S10.6 | S11.2 |
| B4 | The dark span and Tonight's Dark row use the user's darkness limit, not a fixed −18° (TD-051, TD-054) | S6.5, S6.13 | TEST VERIFIED | HOST | No† | S6 val. (S6.5: E5; S6.13) · gate S10.6 | S11.2 |
| B5 | Excluded periods keep their reasons; unknown data never excludes time; the Moon and cloud gates are off by default, set in Settings, and change the usable time when on | ADR-013 §2–§4; RD-11 = S9; S9.4 (TD-050) | TEST VERIFIED | HOST | No† | S9 val. (S9.4, probe P2) · gate S10.6 | S11.2 |
| B6 | TASK 2.4 on the emulator: zone America/Los_Angeles, clock 18:30 local, a site in that zone (and one without a zone, labelled as the device zone): Tonight and the planner show that evening as tonight, not the next day | TASK 2.4 acceptance; Appendix B 2.4; S11.3 | RUNTIME VERIFIED (emulator) | EMULATOR | No — not in D11-2 | RUNTIME VERIFIED (emulator) 2026-09-30, PASS: `evidence/STAGE_11_EMULATOR_RUNS.md` | S11.3 |
| B7 | Times come only from SessionNight with the zone rule (site's zone, else the labelled device zone); no `DateTime.now()` in `lib/domain`; no night derived from a `DateTime`'s Y/M/D | Shared rules "Science and architecture"; `CLAUDE.md` trap 2; ADR-007 | TEST VERIFIED | HOST | No† | gate S10.6 | S11.2 |
| B8 | The Weather detail keeps the age, stale label, unknowns, units, attribution and horizontal-visibility wording; no score or good/bad colour; "Tap to set location" never shown without an action | ADR-012; S6.5; S9.6 | TEST VERIFIED | HOST | No† | S6 val. (S6.5); S9 val. (S9.6) · gate S10.6 | S11.2 |
| B9 | Sky darkness reads value first (Bortle, SQM) with its source and a local date, unknown said as such with the way to set it, the map link's purpose stated; no inferred Bortle, no Bortle↔SQM conversion | S9.7; PD-05; trap 6 | TEST VERIFIED | HOST | No† | S9 val. (S9.7) · gate S10.6 | S11.2 |

### C — Budget, fit, √N and storage

| ID | Check | Source | Level needed | Env | Mandatory for beta readiness | Current evidence | Task |
| --- | --- | --- | --- | --- | --- | --- | --- |
| C1 | The status and outputs (integration, time needed, total time, usable time, verdict, capture end) equal `CaptureBudgetCalculator` and `FitAnalyzer` on ADR-009's vectors E1–E7 and E8, E8b, E8c; the chart geometry is not the calculation | S6.10 (P6.9 acceptance); S7.3b; ADR-009; "What it checks" (budget and fit) | TEST VERIFIED | HOST | No† | S6 val. (S6.10: E10); S7 val. (S7.3b) · gate S10.6 | S11.2 |
| C2 | Integration ≠ imaging time ≠ total time; Budget details holds every ADR-009 line; calibration never counts as integration; outside-window calibration never enters the window load; library blocks take no time | Shared rules "Science and architecture"; P6.9 notes; S7.3 acceptance | TEST VERIFIED | HOST | No† | S6 val. (S6.7, S6.10); S7 val. · gate S10.6 | S11.2 |
| C3 | "What fits" wording comes only from `maxFramesForBlock` and `unplacedFramesByBlock`; where the API cannot answer, the wording stays honest (TD-074 recorded) | P6.9 notes; S6.10; D9-6 | TEST VERIFIED | HOST | No† | S6 val. (S6.10) · gate S10.6 | S11.2 |
| C4 | Relative stacking gain stays √N versus one frame, per (filter, exposure) group, never combined, never labelled SNR or a quality prediction; the plan's point is identified in words and visually; the comparison end is never a target; a text alternative. A change of meaning is a blocking correctness issue | S6.11 (P6.10); TD-076 (S6.16); SI-003; CALC-42; "What it checks" (√N) | TEST VERIFIED | HOST | No† (a change of meaning blocks, V4 A) | S6 val. (S6.11, S6.16: E11) · gate S10.6 | S11.2 |
| C5 | Storage: a known RAW size reaches the planner with its unit; an unknown one reads "Unknown" with the reason and the way to supply it (the rig editor, a DNG pick); no theoretical RAW payload anywhere | P6.9 notes (C); S6.10; ADR-009 §7; SI-013; shared rules "Stay excluded" | TEST VERIFIED | HOST | No† | S6 val. (S6.10) · gate S10.6 | S11.2 |
| C6 | Capability guidance reads the plan's effective tracking (override, else the rig's default, else unknown): NPF guidance and the maximum-exposure warning follow it; unknown shows as a neutral missing input; guidance never blocks a plan | RD-08 = T3; S7.1; PD-11; trap 4 | TEST VERIFIED | HOST | No† | S7 val. (S7.1) · gate S10.6 | S11.2 |
| C7 | No composite score, percentage or good/bad rating anywhere; thresholds stay preferences with units and ranges | ADR-013 §5; SI-006; shared rules "Stay excluded"; P6.3 | TEST VERIFIED | HOST | No† | — | S11.2 |
| C8 | No planning or scientific calculation in widgets; displayed durations, exposures, signed degrees and percentages go through `QuantityText`; colours through tokens only | Traps 12, 13; shared rules "Visualisations" | TEST VERIFIED | HOST | No† | gate S10.6 (the rule tests) | S11.2 |

### D — Capture and calibration forms (Stage 7's approved matrix)

| ID | Check | Source | Level needed | Env | Mandatory for beta readiness | Current evidence | Task |
| --- | --- | --- | --- | --- | --- | --- | --- |
| D1 | A light block's fields follow the rig's camera class: ISO for Phone and DSLR/mirrorless, gain for astro cameras, one neutral choice for Unknown; binning only for astro classes and Unknown; a stored value the class hides is kept, named, snapshotted and exported; never converted | ADR-020 §3; RG-11 (B1, C1); S7.2b; SI-004 | TEST VERIFIED | HOST | No† | S7 val. (S7.2a, S7.2b) · gate S10.6 | S11.2 |
| D2 | A new light block proposes the previous light block's exposure, sensitivity and binning, marked as a proposal and stored only by the user's Save; "Time between frames" is the one interval (label and help only, no budget change) | ADR-020 §4–§5 (P2, I1); S7.2b | TEST VERIFIED | HOST | No† | S7 val. (S7.2b) · gate S10.6 | S11.2 |
| D3 | Calibration blocks: the matrix cell for cell per frame type and class; inherited values copied from a chosen light group with their origin; "Use other values" keeps independent input (TD-083); match warnings in words, never blocking, with a one-tap fix and Undo | ADR-020 §6; RG-10 (L1); S7.3a; S7.V1 | TEST VERIFIED | HOST | No† | S7 val. (V5 revalidation) · gate S10.6 | S11.2 |
| D4 | The dark-flat frame type round-trips through the store, snapshot and export; tips are one line, hideable, and hiding them hides no warning | RG-10 (D1, H1); S7.3a | TEST VERIFIED | HOST | No† | S7 val. (S7.3a) · gate S10.6 | S11.2 |
| D5 | In-camera noise reduction: a switch only for DSLR/mirrorless and Unknown, off by default; when on, E8, E8b, E8c hold, the fill count follows, "darks twice" is warned | ADR-020 §8 (N1); S7.3b | TEST VERIFIED | HOST | No† | S7 val. (S7.3b) · gate S10.6 | S11.2 |
| D6 | The rig form asks the pixel size once; maximum exposure, RAW size and rotation sit under "More (optional)"; the camera class is the user's choice, never inferred; nothing stored is lost; the editor fits at 200 % (`equipment_editor_fit_test.dart`) | S7.6; S7.2a; RG-03 = Q1; S3.10 | TEST VERIFIED | HOST | No† | S7 val. (S7.6) · gate S10.6 | S11.2 |
| D7 | Capture-plan rows lead with identity and quantities ("Ha · 60 s × 100 · 1 h 40 min"); delete offers Undo that restores exactly the deleted block (TD-082); Fill, Trim and "Start from the example plan" can be undone (TD-079) | S6.9; RD-09 = M + S1; S6.V1; S6.16 | TEST VERIFIED | HOST | No† | S6 val. (S6.9, S6.16, S6.V1 probe) · gate S10.6 | S11.2 |

### E — Automation honesty

| ID | Check | Source | Level needed | Env | Mandatory for beta readiness | Current evidence | Task |
| --- | --- | --- | --- | --- | --- | --- | --- |
| E1 | Target search finds objects by designation spellings, aliases and common names, offline; an edit never changes `catalogId`; deleted targets stay deleted; custom entry still works | RG-07 = T1; S7.4 | TEST VERIFIED | HOST | No† | S7 val. (T4) · gate S10.6 | S11.2 |
| E2 | The site form: elevation optional and null when unknown (never 0 m); GPS only on the user's tap and only into the form; a map pick or fix never enters a saved site without Save; Bortle and SQM manual and unknown by default; leaving with changes asks | RG-08 = E2; RG-09 = S3; S7.5; S7.V2; trap 2 | TEST VERIFIED | HOST | No† | S7 val. (V5 revalidation) · gate S10.6 | S11.2 |
| E3 | "Add from a photo" proposes values with per-field provenance and source notes, never a camera class; nothing is written before the user's Save; an existing rig is recognised; a snapshot records per-field provenance | ADR-018 §4–§7; S3.7; S7.2a; S8.8 | TEST VERIFIED | HOST | No† | Stage 3 sign-off; S7 val.; S8 val. (S8.8) · gate S10.6 | S11.2 |
| E4 | Unknown stays unknown: the example rig's tracking and camera class stay Unknown; no default elevation, Bortle or file size is filled | Trap 8; SI-008; RD-08; RG-11 C1; RG-08 | TEST VERIFIED | HOST | No† | S7 val. · gate S10.6 | S11.2 |
| E5 | M1–M3: a picked DNG, JPEG and HEIC are read in place, bounded, with no cache copy | `TEST_PLAN.md` M1–M3; ADR-017 §6 | DEVICE VERIFIED | PHONE | No — not in D11-2 | M1–M3 PASS 2026-09-26 (`360fd8f`, `3a23391`); metadata code unchanged since (`PROGRESS.md`) | reused |
| E6 | M4 on the final build (S3V-08): Library → Rigs → "Add from a photo" with a DNG and with a JPEG or HEIC, through the current rig form (S3.9, S3.10, S7.2a, S7.6), Save, "You already have this rig", no cache copy | `TEST_PLAN.md` M4; S3V-08; Stage 11 Scope (metadata and import on a device) | DEVICE VERIFIED | PHONE | No — not in D11-2 | — (M4 passed at `d21a326`, before the rig form changed) | S11.5 / S11.6 |
| E7 | S2V-06: a pick through a non-seekable (cloud) provider, and a real backup's restore preview cancelled, leave no picker copy — with no owner file uploaded | S2V-06; `TEST_PLAN.md` M1, M2 ("Not run"); D11-3 | DEVICE VERIFIED | PHONE | No — not in D11-2 | — | S11.5 / S11.6 |

### F — Saved plan → result → Logbook; legacy runs; portability

| ID | Check | Source | Level needed | Env | Mandatory for beta readiness | Current evidence | Task |
| --- | --- | --- | --- | --- | --- | --- | --- |
| F1 | A saved night ends at CALC-44 (dawn at the snapshot's darkness limit, else the night's end, else a conservative end); then the planner continues on exactly one working copy and the saved entry and snapshot are unchanged, with the app open and after a restart | D8-1, I-3; S8.1, S8.3; TD-086 | TEST VERIFIED | HOST | No† | S8 val. (T1, T3) · gate S10.6 | S11.2 |
| F2 | The result form records Completed as planned, Partly (typed counts per light block) and Not done (optional reason) for Saved and Saved · changed entries; it reviews the snapshot; Back writes nothing; a stale form and a failed write change nothing, say so and keep the input; no result before the night ends | S8.1, S8.2; I-2, I-4, I-7; S4-DEF-08 | TEST VERIFIED | HOST | No† | S8 val. (T1, T2) · gate S10.6 | S11.2 |
| F3 | Tonight's line ("Last night: M42. How did it go?", or with a date) appears only when due, opens the result form, and is gone after Save result | S8.3; I-8 | TEST VERIFIED | HOST | No† | S8 val. (T3) · gate S10.6 | S11.2 |
| F4 | No screen, route, menu or card offers live tracking; a database with a run in progress, a completed live run with corrections and an abandoned run opens, lists, exports and backs up; the in-progress run can be recorded both ways | S8.4 acceptance 1–2; ADR-016 §13; "What it checks" (tracker removal) | TEST VERIFIED | HOST | No† | S8 val. (T4, probe P2) · gate S10.6 | S11.2 |
| F5 | The Logbook: Upcoming and Past; search over name, target, site and notes; filters in one panel, combined with search, surviving navigation, cleared together; delete through a confirmation; Progress by target from recorded results (CALC-38) | S8.5; I-9; RD-07 | TEST VERIFIED | HOST | No† | S8 val. (T5) · gate S10.6 | S11.2 |
| F6 | An optional name is never asked at Save plan, not copied, not in the snapshot; it lists, is searched, exported, and survives backup and restore; the id never changes | S8.6; E.1 "Stages 6–11 amended" §2 (names kept) | TEST VERIFIED | HOST | No† | S8 val. (T6) · gate S10.6 | S11.2 |
| F7 | A Logbook entry shows identity, night, target, site, rig, result, planned against actual (CALC-37), blocks, notes, conditions; actions by state (Open/Copy; Record result/Copy; Edit result/Copy; Old log: Share and Export only); legacy rows degrade to "Old log — stored text only" | S8.7; I-6 (S4-DEF-07); CALC-37 | TEST VERIFIED | HOST | No† | S8 val. (T7) · gate S10.6 | S11.2 |
| F8 | Share is structured text with no notes and no coordinates; Export as file is the one-session manifest v2, unchanged in content and kept apart from Share | D8-4; S8.7; "What it checks" (share kept apart from export) | TEST VERIFIED | HOST | No† | S8 val. (T7) · gate S10.6 | S11.2 |
| F9 | Every supported schema (v8 → v25) upgrades keeping rows, events, counters and snapshots; below-floor and newer databases are refused before any statement | ADR-008 §2; S8.1 acceptance 6; S8.6; `CLAUDE.md` migration workflow | TEST VERIFIED | HOST | No† | S8 val. (probe P1, v23 → v25) · gate S10.6 | S11.2 |
| F10 | The export round-trips `result_kind`, `not_done_reason`, `reported`, `name` and `tracking_override`; a pre-S8.1 file still reads; `manifest_version` stays 2 | S8.1 acceptance 7; S8.6; S7.1; `EXPORT_MANIFEST.md` | TEST VERIFIED | HOST | No† | S8 val. · gate S10.6 | S11.2 |
| F11 | Backup format 2 carries the planning and display preferences, active site and first-run flag, not the transient position, plan ids or place-name opt-in; restore and reset clear plan ids; a version 1 archive restores | D8 I-10; S8.9 (TD-056, ENG-14) | TEST VERIFIED | HOST | No† | S8 val. (T9, probe P4) · gate S10.6 | S11.2 |
| F12 | Names and result fields survive a process restart (host lifecycle harness) and the migration path | "Errors, lifecycle and portability" (third bullet) | TEST VERIFIED | HOST | No† | — | S11.2 |
| F13 | TASK 14.4 round trip: with sessions (one named; each result kind), sites, rigs, targets and changed preferences, back up to Files, uninstall, reinstall, restore, reopen: everything is back; a backup from a newer build is refused | TASK 14.4 acceptance; `TEST_PLAN.md` 14.4 owner checklist; Appendix B 14.4; S11.3 | RUNTIME VERIFIED (emulator) | EMULATOR | No — not in D11-2 | RUNTIME VERIFIED (emulator) 2026-09-30, PASS: `evidence/STAGE_11_EMULATOR_RUNS.md` | S11.3 |
| F14 | Android Auto Backup behaves as `DATA_MODEL.md` B7 documents (on by default; database and preferences backed up; restored on reinstall), or it is recorded as UNVERIFIED with the reason if the emulator's Backup Manager cannot be used | TASK 14.4 scope; Appendix B 14.4; `DATA_MODEL.md` B7 | RUNTIME VERIFIED (emulator) | EMULATOR | No — documented, owner decision not to change it | RUNTIME VERIFIED (emulator) 2026-09-30, PASS: `evidence/STAGE_11_EMULATOR_RUNS.md` | S11.3 |
| F15 | On a Logbook entry, Share opens the system share sheet with the text (no notes, no coordinates) and Export as file hands over a `.json` file named in the local date | S8.7; D8-4; S9.8; contract "device flows the host cannot prove" (the E2E fakes the share sheet) | RUNTIME VERIFIED (emulator) | EMULATOR | No — not in D11-2 | RUNTIME VERIFIED (emulator) 2026-09-30, PASS: `evidence/STAGE_11_EMULATOR_RUNS.md` | S11.3 |
| F16 | The refused-database flow (S1.5): an older build installed over a newer database shows the explanation with no reset; a below-floor file asks for confirmation, keeps `.v<N>.bak`, and the app restarts on fresh, seeded data | Stage 11 Scope; S1.5; ADR-008 §2; `PROGRESS.md` Carried | RUNTIME VERIFIED (emulator) | EMULATOR | No — not in D11-2 | RUNTIME VERIFIED (emulator) 2026-09-30, PASS: `evidence/STAGE_11_EMULATOR_RUNS.md` | S11.3 |

### G — Library, Settings, About, branding, licence as decided

| ID | Check | Source | Level needed | Env | Mandatory for beta readiness | Current evidence | Task |
| --- | --- | --- | --- | --- | --- | --- | --- |
| G1 | In the Library a tap on a rig, target or site opens its editor and leaves the plan's rig and target and the active site unchanged; `/select/…` still chooses; "Plan this target" asks under the leave guard | D9-1; S9.1; RD-07 | TEST VERIFIED | HOST | No† | S9 val. (T1) · gate S10.6 | S11.2 |
| G2 | Rigs, targets and sites delete through a visible Delete and a swipe, one `confirmDestructive`; a cancelled swipe returns the row; `showDone` after; saved snapshots keep their values | D9-2; S9.1; RD-09 | TEST VERIFIED | HOST | No† | S9 val. (T1, probe P1) · gate S10.6 | S11.2 |
| G3 | The editors use `AppWords` labels and one primary Save; the retired-terms baseline is empty | S9.2 | TEST VERIFIED | HOST | No† | S9 val. (T2) · gate S10.6 | S11.2 |
| G4 | Settings: RG-13's sections; each row its value, unit and consequence; time between frames up to 120 s; optional overheads editable; the gates; every write through `runWithFeedback`; Restore through `confirmDestructive` | D9-3; S9.4 | TEST VERIFIED | HOST | No† | S9 val. (T4) · gate S10.6 | S11.2 |
| G5 | About: the author block first (Buffur; Reddit prominent; GitHub), the version; each third-party credit present and linked (OpenNGC with its notice, © OpenStreetMap contributors, Open-Meteo CC BY 4.0, lightpollutionmap.app); the source, project and policy links unchanged until RD-01 | D9-4; S9.5; TASK 16.3 acceptance (attributions in the app) | TEST VERIFIED | HOST | No† | S9 val. (T5) · gate S10.6 | S11.2 |
| G6 | From the emulator, About's author links and third-party links open their intended pages; the source, project and policy links' state is recorded (TD-088: they return 404 until RD-01 → OWNER, N7) | S9.5 ("a working link is never broken"); "What it checks" (the author's links); `TEST_PLAN.md` 16.3 owner checklist | RUNTIME VERIFIED (emulator) | EMULATOR | No — not in D11-2 (the policy URL is O9) | — | S11.4 |
| G7 | Branding as built: the launcher shows "Astro Planner" with today's icon (a themed icon on Android 13+), the splash is night navy with the icon, Settings → Apps lists `io.github.chacha12.astroplanner` | TASK 16.1 test; `TEST_PLAN.md` 16.1 owner checklist; trap 20; S9.10 deferred | RUNTIME VERIFIED (emulator) | EMULATOR | No — not in D11-2 | RUNTIME VERIFIED (emulator) 2026-09-30, PASS: `evidence/STAGE_11_EMULATOR_RUNS.md` | S11.3 |
| G8 | The licence as the owner decided: GPL-3.0 in `LICENSE` and About; the OpenNGC CC BY-SA 4.0 notice shipped and shown; nothing changed by an agent | RG-12 deferred by the owner (E.1 Stage 9 note); P9.5; "What it checks" (licence) | TEST VERIFIED | HOST | No† | S9 val. (T5) · gate S10.6 | S11.2 |
| G9 | Feedback: `showDone` after a rig, target or site save or delete, a backup, a staged or cancelled restore, a rename and an export; none for a setting whose effect shows on screen; backup and export names in the local date | D9-5; S9.8 | TEST VERIFIED | HOST | No† | S9 val. (T8) · gate S10.6 | S11.2 |

### H — Accessibility

| ID | Check | Source | Level needed | Env | Mandatory for beta readiness | Current evidence | Task |
| --- | --- | --- | --- | --- | --- | --- | --- |
| H1 | The sweep covers every new or changed screen (the planner with every section open, Night & Moon, Weather, the result form, the Logbook and its filters, the Library lists in both modes, the editors, Settings with every section, About) in light, dark and field × 100 % and 200 % at 412 px: no overflow, tap targets, labels, contrast in light and dark | "Accessibility and field use" (sweep); trap 17; TASK 15.3 | TEST VERIFIED | HOST | No† | S8 val., S9 val. (trap 17) · gate S10.6 | S11.2 |
| H2 | Every icon-only button has a tooltip; a relabelling `Semantics(excludeSemantics: true)` passes `onTap` and `enabled` | Trap 17; S1.11 (UX-28) | TEST VERIFIED | HOST | No† | — | S11.2 |
| H3 | At 200 % text the primary answer, verdict, context line, block rows, filters, dialogs (block and rig editors), Settings and the Logbook's planned-against-actual wrap and grow instead of truncating; a squeezed graphic gives way to its text form | "Accessibility and field use" (large text); Stage 9 scope ("Large text is validated in Stage 11") | TEST VERIFIED | HOST | No† | — | S11.2 |
| H4 | Reduced motion: under `disableAnimations` messages do not slide (TD-081), the change emphasis does not run, nothing essential is only in motion, and no action or startup waits for an animation | "Accessibility and field use" (reduced motion); S9.8; P6.9 notes | TEST VERIFIED | HOST | No† | S9 val. (T8) · gate S10.6 | S11.2 |
| H5 | Colour never carries a verdict, warning, stale state or selection alone (a word or icon goes with it) | Shared rules "Look, icons, colour, motion"; S7.1 acceptance | TEST VERIFIED | HOST | No† | — | S11.2 |
| H6 | TalkBack on the core flow, at the largest font size: first run → a site → Tonight → the planner's answer → a collapsible section → a target and a rig → add, edit and delete a block and Undo → the timeline's description → Save plan → (after the night) Tonight's line → the result form → Save result → the Logbook entry; nothing unlabelled, out of order or cut off; the core part repeated in field mode | TASK 15.3 acceptance (walkthrough recorded); D11-2 (TalkBack on the core flow); "Accessibility and field use" (TalkBack); UX-28 | DEVICE VERIFIED | PHONE | **Yes** — D11-2 | — | S11.5 / S11.6 |
| H7 | TalkBack on the other new flows: the Logbook's search and filters, delete confirmations, the Library's management, the Settings controls | "Accessibility and field use" (TalkBack) | DEVICE VERIFIED | PHONE | No — beyond D11-2's core flow | — | S11.5 / S11.6 |

### I — Field (red) mode

| ID | Check | Source | Level needed | Env | Mandatory for beta readiness | Current evidence | Task |
| --- | --- | --- | --- | --- | --- | --- | --- |
| I1 | Field-mode tokens are red or black only, the app is wrapped in `AppTheme.fieldFilter`, and field mode survives a restart | Trap 12; TASK 12.4 acceptance | TEST VERIFIED | HOST | No† | gate S10.6 (the token tests) | S11.2 |
| I2 | The TASK 12.4 darkness checklist in real darkness: Tonight, the planner, the date picker, a delete confirmation, a snackbar, the map picker, Settings, the result form and the Logbook show no non-red or bright pixel and no white flash on navigation or restart | TASK 12.4 test; `TEST_PLAN.md` 12.4 owner checklist; Appendix B 12.4 | HUMAN VERIFIED | HUMAN (PHONE) | No — not in D11-2 | — | S11.5 / HUMAN |
| I3 | Field mode is usable in real darkness: verdicts, warnings, secondary text, timeline bands (UX-08), selected states, outlined controls and card borders (UX-39) and the result form are readable, with colour never the only carrier; ARCHITECTURE B16's accepted contrast exceptions are noted, not "fixed" | "Accessibility and field use" (field mode); UX-39; S6.12 (the real-darkness check is Stage 11's) | HUMAN VERIFIED | HUMAN (PHONE) | No — not in D11-2 | — | S11.5 / HUMAN |

### J — Degraded and offline states

| ID | Check | Source | Level needed | Env | Mandatory for beta readiness | Current evidence | Task |
| --- | --- | --- | --- | --- | --- | --- | --- |
| J1 | With the weather unavailable, planning continues and the forecast says so with Retry and no number; a stale forecast is labelled stale with its age and re-ages with the clock (`WeatherFreshness`, `NightClock`); stale data is never shown as fresh | "Degraded states"; ADR-012 §6; S1.3 | TEST VERIFIED | HOST | No† | — | S11.2 |
| J2 | Place names off: nothing is sent; on and failing: the name stays empty and editable, nothing blocks; never a lookup for a saved site or the default position | "Degraded states"; PD-12; trap 22 | TEST VERIFIED | HOST | No† | — | S11.2 |
| J3 | Nothing optional blocks startup: no network on the startup path; weather loads after the first frame; a bootstrap failure offers retry | "Degraded states"; AC1; trap 5 | TEST VERIFIED | HOST | No† | — | S11.2 |
| J4 | Stage 7's inputs degrade honestly: GPS denied or off leaves the site form usable with typed coordinates or the map; target search works offline; missing tiles do not break the map picker | "Degraded states"; S7.4, S7.5 | TEST VERIFIED | HOST | No† | — | S11.2 |
| J5 | In airplane mode with existing data: Tonight, the planner (night, timeline, budget, fit), Save plan, a result, the Logbook and a backup work; the weather reads unavailable or stale with its age; the map picker shows no tiles without crashing | Stage 11 Scope (offline behaviour); "Degraded states"; MASTER_ROADMAP §9 (airplane mode) | RUNTIME VERIFIED (emulator) | EMULATOR | No — not in D11-2 (L1 is the mandatory offline row) | RUNTIME VERIFIED (emulator) 2026-09-30, PASS: `evidence/STAGE_11_EMULATOR_RUNS.md` | S11.3 |

### K — Errors and storage failure

| ID | Check | Source | Level needed | Env | Mandatory for beta readiness | Current evidence | Task |
| --- | --- | --- | --- | --- | --- | --- | --- |
| K1 | Every changed write reports its failure through `runWithFeedback` or `StorageFailure` with the shared failure text: Save plan, Save result (input kept), deletes of rigs, targets, sites and entries, settings, backup and restore staging, export, rename, applying imported metadata | "Errors, lifecycle and portability" (first bullet); traps 15, 18 | TEST VERIFIED | HOST | No† | S8 val., S9 val. (traps 15, 18) · gate S10.6 | S11.2 |
| K2 | No empty or comment-only `catch`; errors logged through `AppLog`; the UI never shows raw error text (`LoadFailureView`) | Trap 15 | TEST VERIFIED | HOST | No† | gate S10.6 (`no_empty_catch_test.dart`) | S11.2 |

### L — Lifecycle (L1–L8) and the end-to-end suite

| ID | Check | Source | Level needed | Env | Mandatory for beta readiness | Current evidence | Task |
| --- | --- | --- | --- | --- | --- | --- | --- |
| L0 | The host lifecycle rows (`lifecycle_matrix_test.dart` L1, L3–L6, L8) and `core_loop_test.dart` follow Save → result with no tracker step, and keep the persistence invariants (saved snapshot, one copy, replay equals counters) | "Errors, lifecycle and portability" (second bullet); S8.4 acceptance 4; trap 19 | TEST VERIFIED | HOST | No† | S8 val. (T4) · gate S10.6 | S11.2 |
| L1 | `TEST_PLAN.md` L1 device steps: a fresh install in airplane mode shows the first-run page; a typed site gives the night and the plan; the weather says no forecast with Retry; no crash or endless spinner | TASK 15.4; `TEST_PLAN.md` L1; D11-2 | RUNTIME VERIFIED (emulator) or DEVICE VERIFIED | EMULATOR | **Yes** — D11-2 (lifecycle rows) | RUNTIME VERIFIED (emulator) 2026-09-30, PASS: `evidence/STAGE_11_EMULATOR_RUNS.md` | S11.3 |
| L2 | L2: "Use current position" denied, denied forever ("Open settings" opens the app's page) and location services off ("Open location settings"): each explained after the rationale, the site unchanged | TASK 15.4; `TEST_PLAN.md` L2; `COMPLIANCE.md` (permissions); Stage 11 Scope (permissions) | RUNTIME VERIFIED (emulator) or DEVICE VERIFIED | EMULATOR | **Yes** — D11-2 | RUNTIME VERIFIED (emulator) 2026-09-30, PASS: `evidence/STAGE_11_EMULATOR_RUNS.md` | S11.3 |
| L3 | L3: with "Don't keep activities" on, and after `adb shell am kill`, the plan (target, night, a block), field mode and the screen are restored | TASK 15.4; `TEST_PLAN.md` L3 | RUNTIME VERIFIED (emulator) or DEVICE VERIFIED | EMULATOR | **Yes** — D11-2 | RUNTIME VERIFIED (emulator) 2026-09-30, L3: data restored, route not (follow-up): `evidence/STAGE_11_EMULATOR_RUNS.md` | S11.3 |
| L4 | L4: save a plan, kill the app during the night, reopen after dawn: Tonight shows "Last night: … How did it go?", the planner is on a copy, the saved plan is in the Logbook on its night; a second kill still leaves one copy | TASK 15.4; `TEST_PLAN.md` L4 (replaced S8.4) | RUNTIME VERIFIED (emulator) or DEVICE VERIFIED | EMULATOR | **Yes** — D11-2 | RUNTIME VERIFIED (emulator) 2026-09-30, PASS: `evidence/STAGE_11_EMULATOR_RUNS.md` | S11.3 |
| L5 | L5: rotating the planner, the site editor with typed text and the result form, switching system dark mode and toggling field mode loses nothing typed, cuts nothing off, keeps the form's choice | TASK 15.4; `TEST_PLAN.md` L5 | RUNTIME VERIFIED (emulator) or DEVICE VERIFIED | EMULATOR | **Yes** — D11-2 | RUNTIME VERIFIED (emulator) 2026-09-30, PASS: `evidence/STAGE_11_EMULATOR_RUNS.md` | S11.3 |
| L6 | L6: after the night, a device zone several hours away leaves the result form's night and times unchanged (the site's zone); a site without a zone shows the device zone, labelled | TASK 15.4; `TEST_PLAN.md` L6 (replaced S8.4) | RUNTIME VERIFIED (emulator) or DEVICE VERIFIED | EMULATOR | **Yes** — D11-2 | RUNTIME VERIFIED (emulator) 2026-09-30, PASS: `evidence/STAGE_11_EMULATOR_RUNS.md` | S11.3 |
| L7 | L7: install the beta, create sites, rigs, targets and plans with results, install the next build over it (`adb install -r`): everything kept | TASK 15.4; TASK 16.4 acceptance (migrations from all beta versions); `TEST_PLAN.md` L7 | DEVICE VERIFIED | PHONE | No — no beta has shipped (`TEST_PLAN.md` L7); required once one exists | — | S11.5 (when a beta exists) |
| L8 | L8: with the storage filled, editing a plan, Save, recording a result and a backup each say they could not be saved and nothing crashes; after the fill file is deleted the next edit and Save result work | TASK 15.4; `TEST_PLAN.md` L8 | RUNTIME VERIFIED (emulator) or DEVICE VERIFIED | EMULATOR | **Yes** — D11-2 | RUNTIME VERIFIED (emulator) 2026-09-30, PASS with notes: `evidence/STAGE_11_EMULATOR_RUNS.md` | S11.3 |
| L9 | The core-loop E2E (`integration_test/core_loop_test.dart`, both tests) passes on the emulator (`flutter test -d <emulator>`, or `flutter drive` where a Gradle argument is needed; the method is recorded) | TASK 15.5 acceptance ("green on the emulator"); Appendix B 15.5; S11.3 | RUNTIME VERIFIED (emulator) | EMULATOR | **Yes** — TASK 15.5 acceptance (D11-2's TASK range) | RUNTIME VERIFIED (emulator) 2026-09-30, PASS: `evidence/STAGE_11_EMULATOR_RUNS.md` | S11.3 |
| L10 | The core loop on the physical phone (`.s2check`): first run → a site → Tonight → the planner (target, rig, blocks) → Save plan → the Logbook → a result once the saved night has ended → the entry → Export as file | D11-2 (the core loop on a physical phone); MASTER_ROADMAP §9 | DEVICE VERIFIED | PHONE | **Yes** — D11-2 | — | S11.5 / S11.6 |

### M — Performance

| ID | Check | Source | Level needed | Env | Mandatory for beta readiness | Current evidence | Task |
| --- | --- | --- | --- | --- | --- | --- | --- |
| M1 | Stage 10's baselines stand: 24.8 MB arm64 release APK, 27.8 MB installed; the scenario numbers as corrected by S10.C1 (typing rows superseded; emulator numbers compare only within one session; seeding 6–8× faster with the transaction in both sessions); only a measurement a later change invalidated is rerun | "Performance"; D10-1, D10-3; S10.1–S10.5 | RUNTIME VERIFIED (emulator) | EMULATOR | No — D10-1 (indicative) | `STAGE_10_MEASUREMENTS.md` S10.1–S10.5, S10V-01; S10 val. PASS | reused (S11.3 only if invalidated) |
| M2 | The deterministic performance tests pass: planner memoization and invalidation, the tolerant candidates benchmark (under 1 s, host), the rig editor's rebuild counts, `MediaQuery` by aspect | Trap 16; S10.3, S10.4; D10-2 | TEST VERIFIED | HOST | No† | S10 val. (T3, T4) · gate S10.6 | S11.2 |
| M3 | Stage 10's scenario suite on the phone in profile mode (`perf_scenarios_test.dart`, the recorded command): the rig editor's focus and typing, the planner and timeline edits, the Logbook at 300 sessions, first-run seeding; frames against 16.7 ms as a reference | S10V-04; D10-1, D10-2; TASK 15.2; 08 §22 | DEVICE VERIFIED | PHONE | No — D10-1 leaves it UNVERIFIED until a phone run; not in D11-2 | — | S11.5 / S11.6 |
| M4 | Tonight's candidates for the whole catalog in under 1 s on the phone | TASK 10.4 acceptance; Appendix B 10.4; D10-2 | DEVICE VERIFIED | PHONE | No — not in D11-2 | — (emulator indicative only) | S11.5 / S11.6 |
| M5 | Profile traces with no jank on a low-end phone | TASK 15.2 acceptance; TASK 16.4 scope (a low-end phone); `TEST_PLAN.md` 15.2 owner checklist | DEVICE VERIFIED | PHONE (low-end; none exists) | No — D11-2 omits it; recorded UNVERIFIED (D10-1) | — | S11.5 (UNVERIFIED) |
| M6 | Play's reported download and install size after the first upload is recorded beside the Stage 10 baseline | `STAGE_10_MEASUREMENTS.md` (release baseline; S10V-03) | DOCUMENTED | OWNER | No — follows an upload | — | OWNER |

### N — Release, signing, install and identity

| ID | Check | Source | Level needed | Env | Mandatory for beta readiness | Current evidence | Task |
| --- | --- | --- | --- | --- | --- | --- | --- |
| N1 | `pubspec.yaml`'s `X.Y.Z+N` and `AppIdentity.version` agree; Gradle, the manifest and `MainActivity` agree with `AppIdentity` | Traps 20, 21; TASK 16.1, 16.2 tests | TEST VERIFIED | HOST | No† | gate S10.6 (`app_identity_test.dart`, `release_config_test.dart`) | S11.2 |
| N2 | A release build (debug-signed on this machine, measurement only) installs on the emulator and the core loop is walked once | TASK 16.1 test (build and install); `RELEASE.md` "Each release" 5; S11.3 | RUNTIME VERIFIED (emulator) | EMULATOR | No — the mandatory install is N5 | RUNTIME VERIFIED (emulator) 2026-09-30, PASS: `evidence/STAGE_11_EMULATOR_RUNS.md` | S11.3 |
| N3 | `dart run tool/check_bundle.dart` on a fresh release bundle: every native library 16 KB aligned, no debug sections; the signer check fails on the debug key, as designed | TASK 16.2; `RELEASE.md` "Each release" 4 | RUNTIME VERIFIED (host tool run) | HOST | No — the signed check is N4 | RUNTIME VERIFIED (emulator) 2026-09-30, PASS: `evidence/STAGE_11_EMULATOR_RUNS.md` | S11.3 |
| N4 | The owner creates the upload key and `key.properties`, builds the signed AAB, and `tool/check_bundle.dart` ends with "Bundle check passed" (signer not `CN=Android Debug`) | TASK 16.2 acceptance; `RELEASE.md` "One-time setup"; D11-2; trap 21 | DOCUMENTED (owner's recorded run) | OWNER | **Yes** — D11-2 (the signed bundle) | — | OWNER |
| N5 | The signed release installs on a physical phone (an internal testing track, or `flutter install` of the signed release) and runs the core loop once | TASK 16.2 test; `RELEASE.md` "Each release" 5; D11-2 (its install) | DEVICE VERIFIED | OWNER (PHONE) | **Yes** — D11-2 | — | OWNER / S11.6 |
| N6 | The Android SDK command-line tools are installed and `flutter doctor` shows no Android toolchain issue | `RELEASE.md` "One-time setup" 1; `PROGRESS.md` owner actions | DOCUMENTED | OWNER | No — the bundle builds without them (`RELEASE.md`) | — | OWNER |
| N7 | RD-01 decided (`chacha12` or `Buffur`) and TD-088 resolved, so the application id, policy, source and project URLs and user agent are final before any upload | TASK 16.1 acceptance ("final before any upload"); RD-01; TD-088; E.1 Stage 9 owner note | DOCUMENTED (owner decision) | OWNER | **Yes** — 16.1; no upload before it | — (deferred by the owner) | OWNER |
| N8 | A formal trademark search for the name before the first upload | OD-07; TASK 16.1 scope; Appendix B 16.1 | DOCUMENTED (owner) | OWNER | **Yes** — before the first upload | — | OWNER |
| N9 | A Play Console developer account and the app's entry exist, with Play App Signing kept at its default | `RELEASE.md` "One-time setup" 4 and "Each release" 6; S11.5 (OWNER list: the account) | DOCUMENTED (owner) | OWNER | **Yes** — no Play track without it | — | OWNER |
| N10 | Target API and native page-size requirements re-checked against Play's current policy, with the date and page cited | TASK 16.2 scope; `RELEASE.md` (target API 36 from 31 August 2026) | DOCUMENTED (cited, dated) | HOST (web) | **Yes** — 16.2; a non-compliant bundle cannot be released | — | S11.4 |

### O — Compliance, privacy, providers, AC7

| ID | Check | Source | Level needed | Env | Mandatory for beta readiness | Current evidence | Task |
| --- | --- | --- | --- | --- | --- | --- | --- |
| O1 | Open-Meteo live from the emulator: a site's forecast loads over HTTPS with `AppIdentity.userAgent`, the attribution shows, a refetch within the freshness window uses the cache | Stage 11 Scope (live providers); S11.4; ADR-012 §6–§7; trap 22; `COMPLIANCE.md` | RUNTIME VERIFIED (emulator) | EMULATOR | No — not in D11-2 | — | S11.4 |
| O2 | Nominatim live: nothing is sent while the opt-in is off; with it on, a user-chosen position gets a name with attribution, at most one request per second, with the user agent; never for a saved site | S11.4; PD-12; trap 22; `COMPLIANCE.md` | RUNTIME VERIFIED (emulator) | EMULATOR | No — not in D11-2 | — | S11.4 |
| O3 | OSM tiles live: the map picker loads tiles for the visible area with the attribution and user agent; no bulk or offline download | S11.4; `COMPLIANCE.md` (OSM tiles) | RUNTIME VERIFIED (emulator) | EMULATOR | No — not in D11-2 | — | S11.4 |
| O4 | The light-pollution link opens `lightpollutionmap.app` at the site's coordinates in the browser; the app fetches nothing from it | RG-09 = M2; S7.5; S11.4; `COMPLIANCE.md` | RUNTIME VERIFIED (emulator) | EMULATOR | No — not in D11-2 | — | S11.4 |
| O5 | The providers' terms (Open-Meteo free tier, OSM tile policy, Nominatim policy, lightpollutionmap.app) re-checked and date-stamped in `COMPLIANCE.md`, with its verification stamp refreshed | TASK 16.3 scope; `COMPLIANCE.md` "Before an upload" 4; S11.4 acceptance; MASTER_ROADMAP §9 | DOCUMENTED (cited, dated) | HOST (web) | **Yes** — required before an upload | — | S11.4 |
| O6 | AC7 dependency and licence audit: every runtime dependency's licence is recorded, compatible with GPL-3.0, and shown on the licence page | AC7; Appendix B (AC7 in Stage 11); S11.4 | CODE VERIFIED | HOST | No — not in D11-2 | — (S10.6 listed use, not licences) | S11.4 |
| O7 | AC7 secrets and HTTPS review: no API key, secret or signing material in the repository; signing files gitignored; every network call HTTPS | AC7; trap 21; `CLAUDE.md` rule 27; `COMPLIANCE.md` (encrypted in transit) | CODE VERIFIED | HOST | No† (a leaked secret or plain HTTP is a V4 C defect) | — | S11.4 |
| O8 | `COMPLIANCE.md` (Data Safety draft, permissions) and `docs/privacy/index.md` match the code: what leaves the device (a site's coordinates to Open-Meteo, tile areas, opt-in Nominatim, the map link on tap), no analytics or crash reporting, the manifest's permissions (fine and coarse location, internet; no background), backups holding settings | TASK 16.3; trap 22; S11.4 scope; D8 I-10 | CODE VERIFIED | HOST | **Yes** — the Data Safety form (O10) is drawn from it | — | S11.4 |
| O9 | The privacy policy is published at the policy URL with the contact email filled in, and the URL opens | TASK 16.3 acceptance; D11-2 (the policy live); `COMPLIANCE.md` "Before an upload" 1 | DOCUMENTED (owner) + RUNTIME VERIFIED (URL opens) | OWNER | **Yes** — D11-2 | — (404 today, TD-088) | OWNER / S11.4 |
| O10 | The Data Safety form is filled in from `COMPLIANCE.md` | TASK 16.3 scope; `COMPLIANCE.md` "Before an upload" 3; S11.5 OWNER list | DOCUMENTED (owner) | OWNER | **Yes** — required before an upload | — | OWNER |
| O11 | The source repository is public (the GPL-3.0 source offer that About links) | `COMPLIANCE.md` "Before an upload" 2; Appendix B 16.3 (public repository) | DOCUMENTED (owner) | OWNER | **Yes** — required before an upload | — | OWNER |

### P — CI and process

| ID | Check | Source | Level needed | Env | Mandatory for beta readiness | Current evidence | Task |
| --- | --- | --- | --- | --- | --- | --- | --- |
| P1 | The full quality gate (`dart run tool/check.dart`: encoding, format, analyze, every test, host E2E) passes on Stage 11's final inputs | TASK 16.4 tests ("full regression"); Verification Policy V1–V3; MASTER_ROADMAP §9 | TEST VERIFIED | HOST | **Yes** — TASK 16.4 | Baseline: gate S10.6 (1,838 tests, 2 skips; E2E 2 + 1), valid while its inputs are unchanged (V3) | S11.2 (S11.7 confirms) |
| P2 | RD-17: the CI workflow pushed and a first run observed | TASK 1.3; RD-17; D11-5; Appendix B 1.3 | DOCUMENTED | OWNER | No — deferred by the owner (D11-5) | — | OWNER |
| P3 | `TEST_PLAN.md`'s end-to-end section and trap 18 describe the current flow (Save → result) and the emulator | Stage 11 inputs table ("Test documentation drift"); S11.2 scope | DOCUMENTED | HOST | No — documentation drift | — | S11.2 |
| P4 | Every device and emulator run is recorded in `TEST_PLAN.md` with build, device, commit, date and result | Stage 11 Exit; Stage 11 rules ("One Task per commit") | DOCUMENTED | HOST | **Yes** — the Exit | — | S11.3, S11.6 |

### Q — Owner decisions and go/no-go

| ID | Check | Source | Level needed | Env | Mandatory for beta readiness | Current evidence | Task |
| --- | --- | --- | --- | --- | --- | --- | --- |
| Q1 | No P0 or P1 issue is open (V4 blockers of this validation included) | TASK 16.4 acceptance; Stage 11 Exit; D11-2 | DOCUMENTED | HOST | **Yes** — D11-2 | — | S11.7 |
| Q2 | Play's current closed-testing rules for a new personal account (testers, duration) re-verified from Google's help pages, cited with dates | TASK 16.4 scope; Stage 11 Scope (16.4); S11.4 | DOCUMENTED (cited, dated) | HOST (web) | **Yes** — TASK 16.4; the beta cannot be planned without it | — | S11.4 |
| Q3 | The owner's dogfooding on real nights is recorded with a go/no-go on the product's bet (the missing M3 record) | MASTER_ROADMAP M3; Appendix B (M3); Stage 11 Scope | HUMAN VERIFIED | OWNER | **Yes** — D11-2 (the owner's go/no-go); may be one record with Q5 | — | OWNER |
| Q4 | The readiness record exists in four groups (VERIFIED, UNVERIFIED, OWNER ACTION, DEFERRED); UNVERIFIED never counts as a pass; readiness is claimed only if every mandatory row is VERIFIED | "The readiness record"; S11.7 acceptance | DOCUMENTED | HOST | **Yes** — the Exit | — | S11.7 |
| Q5 | The owner's go/no-go for the beta is recorded in `STAGE_11_VALIDATION.md` | Stage 11 Exit; D11-2 | DOCUMENTED (owner) | OWNER | **Yes** — D11-2 | — | OWNER (S11.7 records) |

## 3. Coverage

### 3.1 Appendix B items with Stage 11 as a destination

| Appendix B item | Rows, or out of scope |
| --- | --- |
| 1.3 CI (RD-17; Stage 11) | P2 (OWNER ACTION, deferred by D11-5); the gate itself: P1 |
| 2.4 America/Los_Angeles emulator check | B6 |
| 10.4 candidates timing on a device (Stages 10–11) | M4; M1 (emulator, indicative); M2 (host budget) |
| 12.4 darkness checklist | I2, I3; I1 (host) |
| 12.5 owner walkthrough | A10 |
| 14.4 emulator round trip; Auto Backup | F13, F14; F11 (host) |
| 15.2 device profile traces (Stages 10–11) | M3, M5; M1, M2 |
| 15.3 TalkBack walkthrough (UX-28 verified in Stage 1) | H6, H7; H1–H5 (host guideline tests) |
| 15.4 device rows L1–L8 (L4–L6, L8 replaced with P8.4) | L1–L8; L0 (host) |
| 15.5 E2E on an emulator (moved to Save → result) | L9; L0 (host) |
| 16.1 install test; trademark search; account | N2, G7 (install and identity), N8 (trademark), N7 (RD-01, the account behind the identity), N9 (Play account) |
| 16.2 signed AAB; release install | N4, N5; N3, N6, N10 |
| 16.3 policy URL live, contact, Data Safety, public repository | O9, O10, O11; O5, O8; G5, G6 (attributions and links) |
| 16.4 beta and release QA | Q1, Q2, P1, L7, M5; the beta run itself: out of scope (§4) |
| 16.5 store listing and runbook | Out of scope: only if the owner decides to release (Appendix B; D11-6) |
| M3 dogfooding go/no-go | Q3 |
| AC1–AC7 records; milestone tags | AC7: O6, O7, and its "performance budgets" part M2, M4. AC1–AC6 and tags: out of scope ("others optional", Appendix B) |

### 3.2 Stage 11 "Scope" bullets

| Scope bullet | Rows, or out of scope |
| --- | --- |
| Compliance with this plan; the full test suite | P1; every row's Source |
| An Android emulator and physical devices | All EMULATOR rows; PHONE rows E5–E7, H6, H7, I2, I3, L7, L10, M3–M5, N5 |
| Lifecycle and process death (L1–L8; 15.4 open until then) | L0–L8 |
| Permissions; offline behaviour | L2; L1, J5; J1–J4 (host) |
| Live provider behaviour (Open-Meteo, Nominatim, OSM tiles, the light-pollution link) | O1–O4 |
| Metadata formats and equipment import on a device | E5, E6, E7; E3 (host) |
| Backup and restore, the emulator round trip and Auto Backup (14.4) | F13, F14; F11 |
| The refused-database flow of S1.5 on a device | F16 (emulator, as S11.3 plans; `main.dart`'s wiring is not host-testable) |
| 200 % text; TalkBack (15.3; UX-28); red mode in real darkness (12.4; UX-39) | H3, H6, H7; I2, I3 |
| Low-end performance (15.2, 10.4) | M3, M4, M5 |
| The release build and signing (16.2); CI (1.3) | N2–N6, N10; P2 |
| Compliance: 16.3 (policy URL and contact, Data Safety, `COMPLIANCE.md` re-check) and AC7 | O5–O11 |
| Manual owner dogfooding with a recorded go/no-go (M3) | Q3, Q5 |
| Carried: the 12.5 walkthrough, the 2.4 check, the 16.1 install and trademark search, the 15.5 emulator E2E, 16.4 beta QA (Play's closed-testing rules), L7 | A10, B6, N2 and N8, L9, Q2, L7 |
| 16.5, only if the owner decides to release | Out of scope (D11-6) |

### 3.3 Stage 11 "What it checks" and the amendment's sub-lists

| Bullet | Rows |
| --- | --- |
| The planner answers first (Stage 6's seven points); technical depth reachable | A1–A4, A8, A9 |
| The timeline: darkness, visibility, opportunity and plan; no continuity across a gap; text alternative | B1–B4 |
| Budget and fit read as the calculator says; chart geometry is not the calculation | C1–C3 |
| √N relative and labelled so; a change of meaning blocks | C4 |
| Storage known and unknown; no theoretical size | C5 |
| Capture and calibration forms against Stage 7's approved matrix | D1–D7 |
| Automation honest: sources, confirmation, unknown, offline, no silent write | E1–E4, J2, J4 |
| Save plan → result → Logbook without the tracker: legacy records, optional names, search with filters, progress from results, share apart from export | F1–F8, F15 |
| The tracker's removal broke nothing: old sessions, migrations, export, backup and restore, history | F4, F7, F9–F11 |
| The Library and Settings as Stage 9 placed them | G1–G4 |
| Branding, the author's links, attribution; the licence only as decided; publication an owner action | G5–G8; O9, O11 |
| Accessibility: the sweep (themes, 100/200 %, narrow width, overflow, labels, targets, tooltips, disclosure, chart alternatives) | H1–H3, A4, B3 |
| Accessibility: TalkBack on the new flows (DEVICE only on a device) | H6, H7 |
| Accessibility: reduced motion | H4 |
| Field mode in real darkness; colour never the only carrier; B16 exceptions kept | I1–I3, H5 |
| Large text wraps and grows; a squeezed graphic gives way to text | H3, A10 |
| Degraded states: weather unavailable or stale, place names off or failing, Stage 7 providers unavailable; nothing optional blocks startup; stale never shown as fresh | J1–J5 |
| Errors: every changed write reports failures (trap 15) | K1, K2 |
| Lifecycle and E2E follow the new flow; persistence invariants covered | L0–L9 |
| Names and new result fields survive export, backup, restore, a restart and the migration path | F6, F9–F13 |
| Performance: Stage 10's baselines reused; only an invalidated measurement rerun | M1, M2 (and M3–M5 for the carried phone runs) |
| One pass; corrections rechecked only where affected (V5, V7) | Process rule for S11.7 (Q4); not a check row |
| The readiness record (VERIFIED, UNVERIFIED, OWNER ACTION, DEFERRED) | Q4 |
| Exit: evidence recorded (device runs in `TEST_PLAN.md`); no P0/P1; the go/no-go | P4, Q1, Q5 |

## 4. Not in the contract

| Item | Why (source) |
| --- | --- |
| 16.5 store listing and post-release runbook | Only if the owner decides to release (Appendix B; D11-6) |
| 16.4's beta run itself (internal and closed testing tracks, Play vitals, triage) | Stage 11 checks its prerequisites (Q1, Q2, L7 once a beta exists); no S11 Task runs the beta (frozen Task sequence, S11.4 scope) |
| MASTER_ROADMAP §9's "at least 2 physical devices" and "a low-end phone" as readiness criteria | §9 is G16's 1.0 release checklist; beta readiness needs one physical phone (D11-2). The low-end row stays in the matrix as UNVERIFIED (M5; D10-1) |
| TD-074 ("What fits" for other blocks or joint shares) | Deferred to after Stage 11 (D9-6); C3 checks only that today's wording stays honest |
| RG-12 (a licence change), the logo and splash (S9.10), RD-01's choice itself | Deferred by the owner, 2026-09-30 (E.1 Stage 9 note); validated only as built (G5, G7, G8); RD-01 appears as the owner action N7 |
| RD-15 (a diagnostics export) | Not for the beta (D11-4) |
| RD-17 (push CI) as a blocker | Deferred by the owner (D11-5); recorded as OWNER ACTION P2 |
| RD-02's other holdovers (the ADK skill, `skills-lock.json`, `docs/archive/`) | Not Stage 11's (D10-5; `PROGRESS.md` RD-02) |
| TASK 10.5 azimuth and horizon | Cut; stays deferred (Appendix B) |
| TASK 17.3 assisted actuals; FITS, PNG, AVIF and proprietary RAW readers | Later candidates; formats wait for samples (Appendix B; RG-14; RG-01) |
| The tracker's device checks (TASK 13.2's lock, kill and resume prompt; keep-screen-on; S1.11's tracker under TalkBack) | The tracker left in S8.4 (ADR-016 §13); TalkBack covers the new flows (§6.2 UX-28 row); L4–L6, L8 were replaced (Appendix B 15.4) |
| TD-072 (with S3F-01), S3F-02; TD-085 to TD-087 | Deferred by the owner, or non-blocking follow-ups for a later Task (`PROGRESS.md` Carried) |
| AC1–AC6 records; milestone tags | Optional (Appendix B) |
| A size target; a new numeric performance threshold | None set (Stage 10 scope; D10-2) |
| New features, redesign, a new audit, a second full validation, any "anything else" finding that is not a V4 blocker | "The contract", "One pass" (Stage 11); V4, V7 — recorded as FOLLOW-UP, DEFERRED or IMPLEMENTATION DECISION |

**Documentation drift noticed while building rows** (recorded for S11.2, not fixed here): `TEST_PLAN.md`'s
lifecycle header still says no emulator exists, its L7 names the beta's schema as v17 (the schema is
v25), and its TASK 15.3 and 12.4 owner checklists still walk the tracker and predate the Stage 6–9
screens. H6, I2 and L7 above state the current steps.
