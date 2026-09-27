# Stage 4 revalidation — after S4.V1

Date: 2026-09-27. **Verdict: FAIL. S4V-01 is resolved as reported, but S4.V1 introduced two
blocking gaps in the rule it added (S4R-01, S4R-02).**

S4.V1 closes the gap S4V-01 named. Saved · changed is now classified as saved, and it is protected
at startup and at a live rollover. Research, the ADR-014 pointer, D5, the addendum and
P6.7/P8.1–P8.3 agree on that. However, two parts of ADR-019 §3.1 conflict with the owner's E2
decision:
- the result path for a Saved · changed entry;
- the delivery boundary between Stage 6 and Stage 8.

Neither choice has a recorded owner approval. The earlier report said that any choice beyond E2
belongs to the owner. Stage 5 stays blocked.

## Scope and baseline

- Repository: `C:\Users\zalub\OneDrive\Desktop\Astro Planner\Astro-Planner`, branch `main`.
- Validated HEAD: `5ad69c4401189c318a62013c621b134b28558680` (S4.V1). The previous validation is
  `4241502` (FAIL at `adb5d95`). The working tree was clean at entry.
- **Code:** unchanged since `92ebf2a`. `git diff --name-only 92ebf2a..HEAD` over `lib`, `test`,
  `integration_test`, `android`, `tool`, `assets` and the pubspec files is empty.
- **Independence:** this is a fresh session. It did not write Stage 4's research, ADR-019, S4.T,
  the first validation or S4.V1.
- **Sources:**
  - `CLAUDE.md`, `PROGRESS.md`, and `POST_ROADMAP_PLAN.md`'s Stage 4, §9 and P5–P9 sections;
  - `STAGE_4_VALIDATION.md` and the S4.V1 diff;
  - E.1 (the RD-05/RD-04 decision, E2);
  - ADR-019 in full, and the ADR-014 pointer;
  - D5, the addendum, research S4.R1 (§7, §9), S4.R3 (Q5, §6, §12) and RG-04 (§13), TD-057.
- **Code checked** (for the premises of §3.1):
  - `current_session.dart`;
  - `session_plan_viewmodel.dart:98–138`;
  - `drift_session_repository.dart` (`updatePlan`, `savePlan`, `_writePlan`, `mostRecentOpen`);
  - `session_snapshot_builder.dart`;
  - `capture_analysis_viewmodel.dart:233–254`;
  - `library_viewmodels.dart:140–154`;
  - `session_night.dart`.

## S4V-01 recheck: resolved as reported

| Check | Result | Evidence |
| --- | --- | --- |
| Saved · changed classified by save history | PASS | ADR-019 §3.1: `draft` with `plannedAtUtc`. This matches the code: an edit keeps `plannedAtUtc` (`updatePlan` writes only `status: draft`), and the Logbook lists such rows (`library_viewmodels.dart:153`) |
| The saved night comes from the snapshot, not the working row | PASS; the premise is verified | The plan snapshot stores the night's `eveningDate`, `startUtcMs`, `endUtcMs`, position, zone and blocks (`session_snapshot_builder.dart:36–51`). Save refuses without a site (`capture_analysis_viewmodel.dart:244–246`), so a saved snapshot always has a site-based night. "Passed" means the window's end, the next mean solar noon (`session_night.dart`, ADR-007), which is consistent |
| Startup and live rollover use one rule | PASS (as specification) | §3.1 bullet 2; the P8.3 acceptance; matrix rows 2–3 |
| Snapshot and working edits both preserved | PASS (as specification) | §3.1 table. The code confirms that nothing but an explicit Save rewrites `planSnapshot` |
| Missing context is never guessed | PASS | §3.1 paragraph 2; matrix row 5 |
| Idempotent, serialized adoption | PASS (as specification) | §3.1 bullet 2. A schema need is deferred to Stage 8 planning, with migration tests |
| Frozen and in-progress states unchanged | PASS | §3.1 table; ADR-016 kept |
| Agreement across the documents | PASS for classification and protection | ADR-014 pointer, D5, addendum §3.10, S4.R3 §12, RG-04 §13, P6.7, P8.1–P8.3. The S4.R3 Q5 shorthand is marked superseded |

## Findings

### S4R-01 — BLOCKING: the result for Saved · changed can be recorded against a different night

**Evidence: DOCUMENTED, with the code verified. A defect in the future-flow specification; no
runtime claim.**

ADR-019 §3.1 bullets 4–5 and addendum §3.10 define the only path to a result for Saved · changed:
1. Review plan;
2. explicit Save;
3. the result form.

"After that Save, Completed as planned, Partly, and Not done refer to the **newly saved version**."
A Save builds its snapshot from the **working** night and site
(`capture_analysis_viewmodel.dart:240–254`, `_plan.sessionNight`). The same section says that
Open "preserves that entry's working date". The owner's E2 decision says that the saved plan
"stays on its night, awaiting its result".

A reachable sequence:

1. Save the plan for Fri N. The row is `planned`; the snapshot's night is N.
2. On Fri afternoon the forecast is bad, and the user moves the plan to Sat N+1 (`setEveningDate`).
   The row is now `draft` with `plannedAtUtc` and working `eveningDate` N+1; the snapshot still
   says N (`_writePlan` writes `evening_date`, not the snapshot).
3. After N's end, §3.1 protects the entry, and the reminder "Last night: M42. How did it go?"
   refers to N.
4. Record result, then Review plan, then Save, as §3.1 requires. The snapshot is now N+1, and the
   entry becomes `planned` for N+1, which is tonight.
5. "Not done", or "Completed as planned", is then written against N+1: a night that has not
   happened, while N gets no result. Meanwhile the P8.3 continuation holds another plan for N+1.

A site change (W1/V3) behaves the same way: the result takes the working site, not the saved one.
No rule pins the night or site during the review, bars a result for a night that has not ended,
or states which date the Logbook and the form's header show.

**Also on this path:**
- **The guard collides with the continuation.** Review opens the original "under the existing
  guard for leaving the current plan". By §3.1 that current plan is the unsaved continuation, so
  U1 asks Save · Discard · Cancel about **tonight's** plan before the user can record **last
  night's** result.
- **Not done needs a Save as well.** It needs no counts, yet under §3.1 it waits for a Save of the
  edits.

S4.V1 made these rules. E.1 records the owner's request to fix S4V-01, not an approval of these
rules. S4.V1 describes the guard as "conservative use of the existing Save". That is partly
justified: counts are events on the working `capture_blocks` rows, and the snapshot's blocks carry
no ids (`session_snapshot_builder.dart:139–148`). But the night and site conflation above follows
from it.

**Required follow-up:** S4.V2 below, with an owner decision on the result rule.

### S4R-02 — BLOCKING: the Stage 6 delivery boundary resumes last night's plan as current

**Evidence: DOCUMENTED, with the code verified.**

§3.1's "Delivery boundary", and P6.7, say:
- Stage 6 "prevents in-place automatic re-dating of either saved state at startup and live
  rollover, leaving it on its existing night";
- the continuation comes only in P8.3 (Stage 8).

**Today** (`session_plan_viewmodel.dart:119–133`), the most recent open session is resumed. A past
night is displayed as tonight, and the next edit writes tonight's key into the row. To meet
P6.7's "preserve original id, night, snapshot and saved state" without a continuation, Stage 6 has
three ways to go:
- **Resume the entry as current on its past night.** This is the only literal reading. After
  every saved night, Tonight (plan first; P6.6's night picker is the plan's night) and the planner
  then open on last night's plan and night, until Stage 8.
- **Start a fresh plan.** That is Y3, which the owner rejected.
- **Keep today's behaviour.** P6.7 forbids it.

Either way, S4.V1 changed the delivery the owner decided:
- E.1: "Stage 8 implements E2's resume rule together with RG-04's result recording";
- E2: a saved plan past its night "is not resumed as the planner's current plan";
- Y2's "what the user sees", which the owner chose: "The planner shows tonight's copy".

The interim is not stated as a consequence anywhere. "Order across Stages for ADR-019" does not
cover it.

**Required follow-up:** S4.V2 below, with an owner decision on the delivery order.

### S4R-03 — LOW: TD-057's proposed direction contradicts §3.1

`TECH_DEBT.md` TD-057 still proposes "Write the plan at the rollover" for "the current draft". It
has no link to §3.1. Under §3.1, only a never-saved draft may be written, and a saved state never
is. P6.7 carries the rule, but the register does not. Fix it with S4.V2's documentation. It needs
no decision.

### S4R-04 — LOW: §3.1 reads as part of the owner-accepted ADR

ADR-019's status line is still "accepted (owner, 2026-09-27, S4.D)". §3.1 was added afterwards by
S4.V1, and it carries its own heading label ("S4.V1; normative clarification of E2"). The
difference is visible but easy to miss. The owner's decisions on S4R-01 and S4R-02 should be
recorded as the acceptance of §3.1 as amended, and the status line should say so.

### Carried findings, rechecked

- **S4V-02 (non-blocking): still open, and it applies to Test A too.** S4.R1 §7 still says "Tests
  A and C only look at the app". Test C step 2 Starts and abandons a plan. Test A step 1 ("Set up a
  normal plan for tonight") also autosaves into, or replaces, the owner's current plan. Correct
  both before they run on the owner's install.
- **S4V-03 (unverified):** unchanged. Five-second, first-run and darkness tests remain unrun; Stage
  6 carries the five-second test.

## Stage 4 exit criteria, rechecked

| Criterion | Result | Note |
| --- | --- | --- |
| Decisions recorded in `DECISIONS.md` | PASS, with S4R-04 | E.1 holds RG-04, RD-05/RD-04, RG-05/RD-06/RG-06 and RD-07/RD-14, ADR-019's acceptance and S4.V1 |
| Every 08 flow question has an answer or an owner deferral | PASS | S4.R1 §9.1, Q1–Q22. Q8, Q14, Q15 and Q21 are routed to the Stages the owner approved at Stage 4 planning. §9.2 covers UX-01–UX-14 and UX-24–UX-27 |
| An ADR amending ADR-015 (and ADR-016), with low-fidelity flows | PASS in structure; **FAIL in consistency** | S4R-01 and S4R-02 are in ADR-019 §3.1 and addendum §3.10 |
| An addendum; `IA_WIREFRAMES.md` not rewritten | PASS | `git diff 126d97f..HEAD -- docs/IA_WIREFRAMES.md` is empty |
| Tasks for Stages 5, 6, 8, 9; §6.2 traceability | PASS in coverage; P6.7 and P8.1–P8.3 carry S4R-01 and S4R-02 | §6.2 rows cite ADR-019 for UX-01–UX-14 and UX-24–UX-26. UX-27 is in Appendix C |
| `PROGRESS.md` updated | PASS | Updated by this report |
| No application code (Stage 4 rule) | PASS | The code is unchanged since `92ebf2a` |

Rejected, as before:
- the future screens are not built;
- S4.E did not run.

Stage 4 forbids the first, and the owner made S4.E non-blocking.

## Proposed follow-up: S4.V2 (documentation only; needs owner decisions)

1. **The result rule for Saved · changed (S4R-01).** The owner chooses one:
   - **R1:** a result is always for the saved night and the last saved version. Before the result
     is written, the unsaved edits move to an unsaved copy (never discarded), and the entry's
     blocks return to the snapshot's. There is no Save and no review, so this has the fewest
     taps. Stage 8 must restore the blocks from the snapshot.
   - **R2 (recommended; the smallest change to S4.V1):** keep Review, then Save, then the result,
     but pin the review to the saved night and site:
     - a working night or site that differs from the saved one cannot be saved into this entry,
       and is offered as a copy instead;
     - a result is never written for a night that has not ended;
     - Not done needs no Save;
     - the review does not force Save or Discard on tonight's continuation.
   - **R3:** another rule the owner states.
2. **The delivery order (S4R-02).** The owner chooses one:
   - **D1 (recommended; this is the order E.1 recorded):** P6.7 keeps only never-saved drafts and
     the candidates list (TD-057). Saved states keep today's behaviour until P8.3, which delivers
     the protection and the continuation together.
   - **D2:** move the continuation into Stage 6, alongside P6.7.
   - **D3:** accept the interim explicitly. Its consequence is that Tonight and the planner show
     last night's plan until Stage 8.
3. Align ADR-019 §3.1 (status line, S4R-04), addendum §3.10, S4.R3 §12, RG-04 §13, D5, the ADR-014
   pointer, P6.7, P8.1–P8.3, the S4.V1 matrix, "Order across Stages", TD-057 (S4R-03) and E.1.
4. Then a fresh-session Stage 4 revalidation. No application code in any of these steps.

## Executed verification

- **`dart run tool/check.dart` at `5ad69c4`, clean tree: PASS**, exit 0:
  - Encoding: pass;
  - Format: 376 files, 0 changed;
  - Analyze: no issues;
  - **1,214 tests passed, 1 expected skip** (`ASTROPLAN_METADATA_SAMPLES` not set);
  - host E2E: **2 passed** (the core loop with a restart; time zones across a DST change).

  The raw log is `%TEMP%\astro-stage4-reval-gate.log` (not committed). The existing tests pass;
  that says nothing about the future specification.
- `git diff --check 126d97f..HEAD`: PASS.
- No probe was written. Both blocking findings are specification conflicts, shown from the
  documents plus the cited code paths. No test, application file, dependency or device was
  touched.

## Next allowed action

The owner decides S4R-01 (R1, R2 or R3) and S4R-02 (D1, D2 or D3). Then S4.V2 aligns the
documents, and a fresh-session Stage 4 revalidation follows. Correct S4V-02 before Test A or C
runs on the owner's install. Stage 5 stays blocked. This validation changed only this report and
`PROGRESS.md`.
