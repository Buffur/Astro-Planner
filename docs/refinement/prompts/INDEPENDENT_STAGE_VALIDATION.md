# Prompt — Independent Stage validation

> A reusable session prompt (created 2026-09-27, governance correction). The rules it applies are
> `CLAUDE.md`, "Verification Policy (canonical)", V1–V8; this file is only the procedure. Where the
> two differ, `CLAUDE.md` wins.

Validate **Stage N** (named by `PROGRESS.md`, "Next allowed action"). Validation only: do not fix
anything you find.

## 1. Freeze the acceptance surface first (V4)

Before reading any code, list — from `POST_ROADMAP_PLAN.md`, the Stage's section, and the ADRs and
owner decisions it cites:
- the Stage's and each Task's acceptance criteria;
- the approved owner decisions the Stage delivers;
- the explicit invariants that apply (the `CLAUDE.md` traps and ADRs the Stage touches);
- the evidence the Stage requires (full gate, device rows, real samples), if any.

That list is the whole surface. For an analysis-and-decision Stage it is the bounded list in the
policy. Do not add to it during the validation.

If this is a **revalidation after a correction** (V5), the surface is only: the original blocking
findings, the criteria the correction touches, and the correction's own regression surface. Every
other criterion keeps its earlier PASS unless V6 applies.

## 2. Reconstruct only what you need (V8)

Read `PROGRESS.md` (current state, reusable evidence, Next allowed action), the sources the frozen
criteria reference, and the code those criteria concern. Do not reread historical audits or earlier
validation reports unless a criterion references them.

## 3. Evidence (V2, V3)

- Reuse the recorded gate result if its inputs are unchanged since it ran: check with
  `git diff --stat <commit> HEAD -- . ':!docs' ':!CLAUDE.md'`. Record the one-line reuse note.
- Rerun a check only if an input changed since the last pass, the last run is invalid or
  incomplete, or the Stage's own criteria require a fresh run. A fresh session is not a reason.
- Write a probe test only to establish evidence for a specific criterion; do not commit probes to
  `lib/` or `test/`.

## 4. Judge each criterion

For each frozen item: **PASS**, **FAIL** (with evidence: a failing test, a reproduced defect, or a
quoted contradiction), or **UNVERIFIED** (the evidence cannot be produced here, for example a
device row; say what would produce it).

Classify every finding:
- **BLOCKER** only if it is V4 A (a frozen criterion, decision or invariant not met), B (a
  regression caused by the Stage) or C (a severe correctness, data-integrity, privacy or safety
  defect exposed by the Stage, with its concrete failure);
- otherwise **FOLLOW-UP**, **DEFERRED / IMPLEMENTATION DECISION** or **OWNER DECISION**. These do
  not block and create no requirement for this Stage.

Once every frozen item is judged, stop looking. Do not continue open-ended exploration.

## 5. Outcome (V7)

- **No blockers:** the Stage closes. Record the result in the Stage's validation report and
  `PROGRESS.md`, and set the Next allowed action to the next Stage's planning.
- **Blockers:** name each one against the exact criterion, decision or invariant, with evidence,
  and propose one focused corrective Task per blocker. Do not implement them.
- **The second consecutive failure on interpretation or scope** (not on new contradictory
  evidence): stop, record the disagreement, and ask the owner to resolve the scope. No further
  automatic revalidation.

Commit the report and the `PROGRESS.md` update as one documentation commit, then STOP.
