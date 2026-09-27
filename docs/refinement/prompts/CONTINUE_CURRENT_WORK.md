# Prompt — Continue the current work

> A reusable session prompt (created 2026-09-27, governance correction). The rules are
> `CLAUDE.md` ("Post-Roadmap Workflow Governance", including the Verification Policy); this file is
> only the procedure.

1. Read `docs/refinement/PROGRESS.md`: current state, reusable validation evidence, blockers and
   the **Next allowed action**. That action is the whole scope of this session.
2. Read only what that action names: its definition in `POST_ROADMAP_PLAN.md`, the ADRs, finding
   IDs and files it references, then the relevant code and tests. Do not re-audit the repository
   or reread earlier Stages' history.
3. If the action is a frozen Task, the frozen sequence is the approval: `READ → VERIFY → PLAN →
   IMPLEMENT → VERIFY → SELF-REVIEW → DOCS → COMMIT → STOP`. Verify by change class and reuse
   valid evidence (Verification Policy V1–V3); a Task that changed shared or high-risk code ends
   with one full-gate pass after its last code change.
4. If the action is a research or owner-decision gate, do not implement; prepare the decision.
5. If the action is a Stage validation, use `INDEPENDENT_STAGE_VALIDATION.md`.
6. Update `PROGRESS.md` by its "How to update this file" rules, commit once, and STOP. Never start
   the next Task or Stage.
