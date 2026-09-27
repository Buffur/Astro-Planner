# Stage 4 final validation — bounded

Date: 2026-09-27. **Verdict: PASS. Stage 4 is closed.**

This is the final, bounded Stage 4 validation. It is limited to the seven questions the owner froze
(DECISIONS E.1, "Bounded validation for analysis and decision Stages"; `POST_ROADMAP_PLAN.md`,
"S4.V3 — Bounded final validation"; `CLAUDE.md`, "Validation Rules"). A finding would block only if
it showed a direct contradiction with an approved owner decision or an explicit Stage 4 acceptance
criterion. No new requirement was created.

## Baseline and independence

- **Validated:** HEAD `09a7f06` on `main`; the tree was clean.
- **Code:** unchanged since `92ebf2a`. `git diff --name-only 92ebf2a..HEAD` over `lib`, `test`,
  `integration_test`, `android`, `tool`, `assets` and the pubspec files is empty.
- **Gate:** its last run was at `5ad69c4`, on identical code. It passed: Encoding; Format, 376
  files, 0 changed; Analyze; 1,214 tests with 1 expected skip; 2 host E2E. It was not re-run,
  because Stage 4 changed only documents.
- **Independence, disclosed:**
  - the owner asked for this validation in the session that wrote S4.V2 and S4.V3 and ran the
    revalidation (`750f0a7`), not in a fresh session;
  - the bounded scope keeps the checks to verifiable facts: that commits and entries exist, and
    that the decision records match ADR-019;
  - the owner may still ask for a fresh-session check.

## The seven questions

| # | Question | Result | Evidence |
| --- | --- | --- | --- |
| 1 | S4.R1–S4.R5 completed | **PASS** | Research files in `research/`: `S4.R1_FLOW_INVENTORY.md` (`e5fd240`), `RG-04_EXECUTION_ROLE.md` (`97ffab5`), `S4.R3_SESSION_LIFECYCLE.md` (`989a61e`), `RG-05_06_TONIGHT_AND_PLANNER.md` (`8578ab8`), `S4.R5_LIBRARY_AND_VOCABULARY.md` (`160ee37`). The two earlier validations also passed each research Task's acceptance |
| 2 | Every required gate has an explicit owner decision | **PASS** | E.1: RG-04 (`abca03d`); RD-05 and RD-04 (`8600a39`); RG-05, RD-06 and RG-06 (`0506b04`); RD-07 and RD-14 (`28857d8`); ADR-019 accepted (`f68e576`). Also the validation follow-ups: S4R-01/S4R-02 = R2 + D1 (`b9eed65`), and the bounded scope (`09a7f06`). All eight Stage 4 gates (RG-04 to RG-06, RD-04 to RD-07, RD-14) are decided |
| 3 | ADR-019 faithfully represents the decisions | **PASS** | Each decision was compared with its ADR section. **RG-04:** D1 → §2 and §4; D2 → §4's result form; D3 → §3's states and §4; D4 → §4 and §5.3. **RD-05/RD-04:** E1 → §3's states; E2 → §3.1; E3 → §3's defaults; E4 → §3's replacing rule. **RG-05/RD-06/RG-06:** F1 → §5's order; F2 → §5 and §9; F3 → §6's order; F4 → §7 and "no modes". **RD-07/RD-14:** H1 → §8; H2–H4 → §10 (the S4.R5 glossary made normative). **R2 + D1 and the owner's invariant** → §3.1, reduced by S4.V3 to exactly those statements. The amendment pointers are in place: ADR-009 §2, ADR-014 §3, ADR-015 and ADR-016. DEV-P9 records UX-04 and UX-11. The status line records S4.V1–S4.V3 and their validation reports |
| 4 | The wireframe addendum agrees with ADR-019 | **PASS** | Each addendum section matches its ADR section: §1 (tabs, flows); §2 → §9 (routes); §3.1 → §5; §3.2 → §6 and §7; §3.3 → §3 (U1); §3.4 and §3.5 → §5 and §9 (ADR-012 respected: values, age, attribution, no verdict); §3.6 → §2, §8 and §10; §3.7 → §4 and §3.1; §3.8 → §8; §3.9 → §3; §3.10 → §3.1. `IA_WIREFRAMES.md` is unchanged since `126d97f` |
| 5 | S4.T maps the design to later Stages | **PASS** | Stage 5: P5.1–P5.6 (§3, §5–§7, §9, §10). Stage 6: P6.0–P6.7 (§3, §3.1, §5–§7, §9). Stage 7: an explicit "no change" (RD-08 stays before Stage 6's capture-plan work). Stage 8: P8.1–P8.6 (§2–§4, §8, §10). Stage 9: P9.1–P9.2 (§8, §10). "Order across Stages" keeps a path to results and D1's single transition. §6.2 rows cite ADR-019 for UX-01–UX-14 and UX-24–UX-26; UX-27 is in Appendix C |
| 6 | No direct contradiction makes an approved core flow impossible | **PASS** | The core flows were checked across ADR-019, the addendum and the P-Tasks: plan → Save → Logbook → Record result; the optional Track live → Finish → the same form; Tonight plan-first; the Library manages; the next day. **Before Stage 8,** Start stays reachable as Track live in ⋮ (P6.1), so results are never cut off. **D1:** P6.7 changes only never-saved drafts, and P8.3 ships both sides of the saved-plan transition. §3.1's result flow needs no Save plan and no guard on the working copy, and P8.1 and P8.2 carry it |
| 7 | No Stage 4 acceptance criterion unmet | **PASS** | **Stage exit:** the decisions are in `DECISIONS.md`; every 08 flow question has an answer or an approved home (S4.R1 §9.1, Q1–Q22; Q8, Q14, Q15 and Q21 go to the Stages the owner approved at Stage 4 planning); `PROGRESS.md` is updated. **Output:** an ADR amending ADR-015 and ADR-016; the addendum; Tasks for Stages 5, 6, 8 and 9. **Per-Task acceptance:** S4.R1–S4.T are met (the earlier validations' Task tables, rechecked against the items above). **No code:** confirmed |

## Not blocking (recorded)

- **DEFERRED / IMPLEMENTATION DECISION:** S4-DEF-01 to S4-DEF-08 (plan, S4.V3), for Stages 6 and 8.
- **S4V-02 (unchanged):** the optional S4.E script calls Tests A and C read-only, although both
  change the current plan. S4.R1's acceptance ("the script can be run without the agent") is still
  met. Correct the wording before Test A or C runs on the owner's install.
- **S4V-03:** the owner-run usability and darkness tests are unrun, as the owner permitted; Stage 6
  carries the five-second test.
- **Observation:** ADR-019 §10's list of retired terms is an excerpt. The normative list is the
  S4.R5 §5 glossary, which §10 names; it also retires "Equipment", "Save Session" and "New
  Session". There is no contradiction. P5.1's retired-terms test takes the full glossary.

## Result

Stage 4 is **closed**. The next allowed action is **Stage 5 — Design System Foundation: Stage
planning**. That means verifying P5.1–P5.6 against the code, and then freezing the Task sequence,
with RD-09 as its decision gate. No application code is written before that planning is done.
