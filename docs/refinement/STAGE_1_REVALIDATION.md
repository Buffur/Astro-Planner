# Stage 1 repeat independent validation

> **Date:** 2026-09-26. **Baseline:** `main` @ `c99bd7f` (code as of `ea65231`, S1.V4), clean tree.
> **Result: does not pass.** S1.V1–S1.V4 hold, but one reproduced defect in S1.V4's area
> survives (TD-063), and the living registers still describe S1.5/S1.6 as broken (X2).
> Stage 1 stays in validation; Stage 2 has not started. No application or test source was
> changed.
> **Authority:** `CLAUDE.md`, `POST_ROADMAP_PLAN.md` Stage 1 and §9.8, `PROGRESS.md`'s next
> allowed action, and the first validation's acceptance in
> [`STAGE_1_VALIDATION.md`](STAGE_1_VALIDATION.md), which stays as it is.

## Scope and method

This was a fresh session, not the one that implemented S1.V1–S1.V4. It covered:

- the four fix commits (`3067658`, `b34c9ad`, `ed628f8`, `ea65231`) and S1.16/S1.17
  (`953c0d1`), checked against the acceptance in `STAGE_1_VALIDATION.md`;
- the code diff from `4e653fb` to `c99bd7f` in `lib`, `test`, `integration_test`, `tool`,
  `android` and `pubspec`;
- the living registers these commits touched.

S1.1–S1.15 were not re-audited beyond that diff. They passed the first independent
validation, and no later commit touches their code.

The retained probe patch from the first validation no longer applies (the S1.V tests
changed the same fixtures), as `PROGRESS.md` expected. Its six cases are now regression tests in
the suite, and they pass.

New throwaway probes were written, run and removed. They are kept in
[`evidence/STAGE_1_REVALIDATION_PROBES.patch`](evidence/STAGE_1_REVALIDATION_PROBES.patch),
which adds two separate test files and changes no existing file.

## Verification results

Windows host, Flutter 3.47.4.

| Check | Result |
| --- | --- |
| `dart run tool/check.dart` at `c99bd7f` | PASS: Encoding, Format, Analyze, 963 tests, 2 host E2E tests |
| Tests removed or weakened since `4e653fb` | None. The only removed lines are one unused import and the two-theme dialog loop, which S1.17 replaced with a three-theme loop that keeps the light/dark contrast assertion |
| Scope of the code diff since `4e653fb` | Only the files S1.V1–S1.V4 name. No schema, dependency, formula or Android change. `SessionPlanViewModel` is at 300 lines, within its cap (enforced) |
| New probes | 1 of 3 fails (TD-063). W1 confirmed. A stale unsaved-changes mark on a fresh database: not reproduced |
| Android device or emulator; remote CI | Not run (no device; RD-17 push deferred) |

## Acceptance of the fix Tasks

| Task | Assessment |
| --- | --- |
| S1.V1 / TD-059 | **PASS.** Refusals of v7 and v18 are typed through `openDatabaseConnection`, the production shape. A non-refusal cause is rethrown, and the bytes stay unchanged. The `main.dart` branch itself is not host-testable (Stage 11 device check, as recorded) |
| S1.V2 / TD-060 | **PASS.** `confirmDatabaseReset` refuses newer databases first and forgets only the catalog seed marker. It is tested with and without the marker. Cancel never reaches it, and an ordinary start keeps the marker |
| S1.V3 / TD-061 | **PASS.** Target-, rig-, night- and block-only edits stay protected after a restart. Save clears the mark, a failed Save keeps it, and an untouched draft never asks. On a fresh database a leftover mark is cleared by the first `startNew` (probe) |
| S1.V4 / TD-062 | **PASS for its acceptance** (the same-session reopen through the detail page, a Save and a restart). **Its scope is not fully met:** "prevent stale detail data from being reapplied" still fails when the session's status changed after the detail loaded (TD-063 below) |
| S1.16 | PASS for the stamps it covered. The S1.V stamps written after it repeat the gap (X2) |
| S1.17 | PASS: the dialog check runs in the light, dark and field themes |

## Surviving findings

### TD-063 — reopening from a detail page loaded before Start adopts the running session

**P2; reproduced through the UI; present since TASK 13.3, not a Stage 1 regression.** It falls
inside S1.V4's stated scope, not its acceptance. It uses the same mechanism as TD-062.

**How it happens:**

1. The detail page keeps the `Session` it loaded (`session_detail_screen.dart:37–50`), and its
   Open action passes that copy to `openSession` (`:384–398`).
2. S1.V4's guard (`session_plan_viewmodel.dart:242`) only covers the session that is still
   current.
3. After Start, the planner has moved to a new copy, so the stale `planned` object goes to
   `CurrentSession.adopt`, which makes it current without re-reading it
   (`current_session.dart:102–105`).

**Reproduction, every step awaited, no injected timing:**

1. Save the plan.
2. Open its detail.
3. Tap "Open in planner".
4. Tap `planner.start`. The run page opens.
5. Go Back to the planner, then Back again to the detail. The detail still offers "Open in
   planner".
6. Tap "Open in planner".
7. Add a block.

Probe output:

```text
active=1 started=1 copy=2 liveStatus=inProgress activeStatusSeen=planned
failure=Bad state: The plan of a inProgress session is frozen.
```

The planner now works on the running session, and every autosave is refused, so no later edit
persists and Save fails. The untouched copy it had moved to is left unlisted. The run itself is
unchanged, because the repository enforces the lifecycle. The ADR-016 rule "the planner never
edits a run" therefore holds only in the repository.

**Proposed S1.V5** (S; fix):

- **Scope:** opening a session uses its current stored state rather than the detail page's
  cached copy, so a session that became frozen opens as a copy. For example, `openSession` or
  `adopt` re-reads it by id; the smallest correct change is chosen in the Task.
- **Tests:** a UI-driven regression test with the reproduction above.
- **Keep:** S1.V4's same-session behaviour and S1.6's Cancel/Discard.
- **Out of scope:** refreshing the detail page in general (Stage 8), and TD-058.
- **Acceptance:**
  - the reproduction ends on an editable draft, with no write failure;
  - the running session is unchanged;
  - the existing S1.6/S1.V4 tests pass;
  - `SessionPlanViewModel` stays within its 300-line cap.

### X2 — living registers still say S1.5/S1.6 are broken

**Documentation; convention (`CLAUDE.md`: mark items resolved with date and commit; refresh
the stamps of the files touched).** After S1.V1–S1.V4 the following still stand:

- **Banners and notes that call S1.5 broken or S1.6 partial,** without a note that S1.V1–S1.V4
  resolved them:
  - the validation banners at the top of `FEATURE_STATUS.md`, `ARCHITECTURE.md` and
    `DATA_MODEL.md`;
  - `FEATURE_STATUS.md` F-02 ("Broken") and F-40 ("Partial");
  - `ARCHITECTURE.md` B3 ("S1.5 is not complete") and the TD-061/062 note in the section that
    follows it;
  - `DATA_MODEL.md` (the TD-059/060 correction);
  - `TECH_DEBT.md`'s first banner and TD-047's "UI closure REOPENED".
- **Resolutions and stamps without commits:** the S1.V1–S1.V4 stamps in `FEATURE_STATUS.md` and
  `ARCHITECTURE.md` (8 stamps), and TD-059–TD-062's "RESOLVED 2026-09-25 (S1.V*)", cite no commit.
  S1.16 fixed the same gap for S1.1–S1.15.

**Proposed S1.V6** (S; documentation only):

- mark each note above as superseded by S1.V1–S1.V4, keeping the old text;
- close TD-047 again, citing its commit;
- add the commits `3067658`, `b34c9ad`, `ed628f8` and `ea65231` to the stamps and TD rows, and
  S1.V5's commit once it exists.

This validation only added its own banner to `TECH_DEBT.md` with TD-063; the older banners were
left as they are.

## Lower findings (no fix proposed)

- **W1, confirmed.** It was found by the same-session re-check on 2026-09-26 and is now
  reproduced independently. A Duplicate of an edited, saved plan counts as unedited in the same
  run (`inSession=false`) but as unsaved after a restart (`afterRestart=true`, the same draft).
  The cause is `resume()`'s content rule, which counts any non-example copy as edited. "Plan
  again (copy)" follows the same rule. Nothing is lost that the user saved: at worst, one extra
  prompt, or one missing prompt for a copy's night. **Proposed:** the owner records it under
  RD-05 (Stage 4), next to V3; it was not recorded there yet.
- **Observation.** `editedSessionId` is kept when the database is reset or restored. It can
  cause one unneeded prompt, and only if the resumed draft of the replacing database has the
  same id; a fresh database clears it on its first draft (probe). This belongs with the stale
  preferences already carried with TD-056/ENG-14. No action.

## Next allowed action

The owner decides between two options:

- **Approve S1.V5 and S1.V6** (proposed order: S1.V5 then S1.V6, one commit each), followed by
  another independent validation. Because the rest of the Stage passed twice, that validation
  may be limited to S1.V5, S1.V6 and a green gate.
- **Move TD-063 to Stage 8** (Sessions / Execution), since it predates Stage 1, and close
  Stage 1 after S1.V6 alone.

The owner also decides whether W1 is recorded under RD-05. Do not start Stage 2 before this.
RD-17, TD-057, TD-058, the Stage 11 device checks and Stage 2's RG-01/samples remain as
recorded.
