# Product Reassessment — AstroPlan

> Prepared 2026-10-17 from the owner's review titled review-01.10.2026 and the instruction to amend the repository plan and model instructions. This defines analysis/planning scope; it does not approve a redesign implementation. The earlier ChatGPT Product Reassessment answer was unavailable, so this is not asserted to reproduce it verbatim.

## Objective and boundaries

Reassess AstroPlan as a light astrophotography planner/organizer centered on Capture Plan, integration time, scientifically honest stacking-gain estimates, storage and useful saved records. Compare actual behavior, prior decisions and the owner's live-test observations; propose a complete, prioritized route to release.

Keep current behavior and data intact during reassessment. Prior product choices may be challenged with evidence, including removal or reduced prominence of features. Explicitly name the superseded decision and migration/data implications before asking the owner to adopt a replacement. Do not equate a UX proposal with an approved scientific or data-model change.

Do not run the full gate for this analysis. Use code/test inspection and bounded read-only probes only where they answer an actual question; obtain a separate scoped authorization for any probe requiring edits. Missing physical-device evidence stays unverified. Do not inspect keys or private user data.

## Required inputs and economical reading order

1. CLAUDE.md, the current summary and next action in PROGRESS.md, and this prompt.
2. Relevant PRODUCT_DIRECTION sections and the existing decision/research records for each question; especially ADR-019, ADR-020, RG-11 capture parameters and RG-10 calibration workflows. Resolve their actual paths through the repository.
3. Relevant screens, ViewModels, domain calculations and tests; engineering guardrails/rules only for touched topics.
4. Old roadmap/audit sections only when needed to trace an unresolved requirement. Do not reconstruct the whole project history.

The review originally included six image references and mentioned a separate Moon concept project. Those assets and the old generated prompt are not stored by this amendment. If unavailable in the next session, mark visual comparison/project inspection UNVERIFIED and proceed with the textual coverage below; never invent their details. The owner can provide them before visual decisions are frozen.

## Mandatory review coverage

Each row must be split into individual observations/proposals in the assessment. Give every item a stable RA finding ID, evidence/status, recommendation, related old decision, and proposed Task or reason for deferral. Check every semicolon-separated concern, not merely the screen as a whole.

| Area | Owner observations and proposals to evaluate |
| --- | --- |
| RA-A Product | Light planner/organizer; existing functions feel raw/complex; Capture Plan is central; integration, honest gain estimates, storage and cataloguing records; avoid duplicating full planetarium/weather products; compare real alternatives and relevant user feedback; reuse appropriate established solutions. “All necessary functions exist” is an assertion to verify. |
| RA-B Onboarding | Main-screen flash before Welcome; Skip versus Done; larger welcome title; minimum useful first-run questions; location, optional equipment, doubtful target selection; simplify option descriptions and review layout/text/colors/buttons. |
| RA-C Identity/startup | Research name collision and rename options without claiming legal clearance; revisit vector logo; branded animated loading experience after name/logo direction; purposeful small animations and suitable external icons, with licence/accessibility/reduced-motion/performance checks. |
| RA-D Home | Empty top space/isolated field-mode icon; useful minimum summary; planner entry; priority and duplication of date/site; weather-first proposal; minimize repeated weather inside planner; duplicate New session entry. Preserve necessary context even if inputs move. |
| RA-E Weather/Moon | Compact mobile Moon presentation and supplied reference; concise forecast for the relevant night; wind, humidity and other evidenced imaging-relevant conditions; review reference applications and feedback; preserve freshness, missing-data behavior and provenance. |
| RA-F Planner/Capture | Logical planning sequence and empty upper area; visually merged block content; remove-example proposal; unexpected default exposures; camera-class relevance of Binning and ISO/Gain; requested focus/WB and actual platform/input availability; calibration workflow and safe inheritance from lights; useful Assumptions; graph presentation without implying absolute SNR. Distinguish controls, metadata, user inputs and actual device-control scope. |
| RA-G Records | Logbook and Library: whether saved plans/results/equipment/targets are discoverable and useful; inspect representative flows and propose only evidenced changes. |
| RA-H Settings | Current settings: keep/remove/add recommendations based on actual workflow, ownership and duplication, not aesthetic preference alone. |
| RA-I Release | Reconcile old roadmaps with current implementation; account for Stage 11, physical-device/human evidence, signing, privacy/publication, owner gates and deferred S9 work; propose Stages → Tasks all the way to release without marking unmet checks passed. |

## Research and decisions

Research only external questions that can change a recommendation. Use available search and page-reading tools under session permissions, primary technical/provider sources, URLs and access dates. Separate product evidence from anecdotal feedback. Reuse RG-10/RG-11 and other existing research unless a specific assumption needs refreshing. A missing tool/source is an evidence gap, not permission to guess.

For each disputed decision give the recommended option, a realistic alternative, trade-offs, existing decision affected and what needs owner approval. A comparison with another app does not authorize copying proprietary assets or adding its full feature set.

## Sequence and deliverables

- **RA.R1 — Repository and review assessment:** coverage matrix for every concern; verified facts versus observations/hypotheses; bounded code evidence; current-flow gaps; instruction conflicts; missing reference assets. Stop with the report and proposed research questions. No UI implementation.
- **RA.R2 — Decision-relevant research and options:** resolve RA.R1's external unknowns; compare selected relevant products/flows, reuse existing domain research, and recommend product direction. Depends on RA.R1; begin only when explicitly requested.
- **RA.D — Owner decisions:** record only actual owner choices, including how they affect prior ADRs, deferred identity/logo work and Stage 11 readiness. An agent recommendation is not an owner decision.
- **RA.P — Release-plan amendment:** after RA.D, translate accepted choices into Stages → Tasks with one objective, dependencies, exclusions, acceptance criteria, verification class and stop condition each. Include release prerequisites and map every review item to a Task or explicit deferral. Implementation Tasks remain unstarted.

The owner may explicitly authorize a bounded group of these Tasks; otherwise stop after the named Task. Do not ask again merely because the approved analysis spans several files.

Outputs go in the chat unless the active Task explicitly authorizes a report file. The plan amendment RA.P authorizes updating the affected planning/decision records, not application code. End each Task with a compact handoff: decisions, evidence/source locations, remaining unknowns, coverage status and next allowed action.

## Acceptance of the reassessment package

- Every concern above has a disposition; unavailable visuals and device checks are explicit gaps.
- Claims about existing behavior cite current code or a recorded run; research claims cite sources and dates.
- Observations, recommendations, accepted decisions and implementation approval are distinguishable.
- Scientific honesty, data integrity, offline behavior and current release blockers remain accounted for.
- Accepted decisions map to a coherent release plan; rejected/deferred ideas retain reasons.
- Prior PASS remains valid on unchanged relevant inputs; new UX criteria apply prospectively to changed work. Verification requirements come from CLAUDE.md, not a duplicated policy here.
- No application changes, speculative feature additions, automatic Stage progression or unsupported readiness claims.
