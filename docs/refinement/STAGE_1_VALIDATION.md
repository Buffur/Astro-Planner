# Stage 1 independent validation

> **Date:** 2026-09-25. **Baseline:** `main` @ `4e653fb` (S1.15), initially clean.
> **Result: does not pass.** S1.5 and S1.6 have surviving defects. Stage 1 stays
> in validation; Stage 2 has not started. No implementation fixes were made.
> **Authority:** `CLAUDE.md`, `PRODUCT_DIRECTION.md`, `POST_ROADMAP_PLAN.md`
> Stage 1 / §9.8, and `PROGRESS.md`'s next allowed action.

## Scope and method

Reviewed the frozen S1.1–S1.15 sequence and its A–F coverage, the Stage commits
from `1ec6e7a` through `4e653fb`, relevant implementation and tests, referenced
audit mechanisms, ADR-007/008/012/014, and the living-register changes. Git
history was inspected; unrelated historical roadmaps were not re-audited.

During this pass another session committed `723fd44`, a same-session validation
summary in `PROGRESS.md`, against the same application baseline. That report and
its proposed S1.16/S1.17 and V3 decision are preserved. The independent failures
here supersede its passing verdict. The three untracked probes it observed were
created by this validation; their author removed them after retaining the patch.

Owner changes were applied as recorded: S1.4 uses the default position's mean
solar night without a site; S1.5 never resets newer databases; S1.14's push is
deferred. RD-03's wording and grid-bias decisions stand. TD-057, TD-058, device
checks and optional E4/E5 coverage remain outside this validation's fix queue.

The Stage changes do not alter schema v17, dependencies, ephemeris formulas,
capture-budget arithmetic or scientific reference expectations. Provider /
ViewModel separation and the enforced ViewModel line caps pass the existing
architecture checks. Historical audit/archive/roadmap files are unchanged.

## Verification results

Windows host, Flutter 3.47.4, Dart 3.13.3, resolved Drift 2.35.0.

| Check | Result |
| --- | --- |
| `dart run tool/check.dart` on the committed baseline | PASS: Encoding, Format, Analyze, 948 unit/widget tests, 2 host E2E tests |
| Additional validation probes | 6 expected-behavior assertions fail, establishing the 4 findings below |
| Retained probe patch | Applied, ran all 6 probes, reproduced all 6 failures, then reversed; tracked application and test sources unchanged |
| Android device/emulator | Not run; no device result inferred from host tests |
| Remote CI | Not run or pushed, per RD-17 deferral |

The green baseline suite does not cover the failed paths. The probe failures are
additional evidence, not failures in the original 948-test suite.

## Surviving findings and proposed fix Tasks

These Tasks are **proposals, not a newly approved implementation sequence**.
Each requires the targeted regression tests, the full quality gate, review,
updated registers and progress, one commit, then STOP. No Task authorizes a
schema change or a new product decision without the existing decision gate.

### S1.V1 — Recognize refusal through the production database connection

**TD-059; P1; S1.5 / A6 / RT-03 / TD-047.**

`app_database.dart:533–536` opens through `LazyDatabase` and
`NativeDatabase.createInBackground`. `refusedSchemaVersion` catches only
`UnsupportedSchemaVersionException` (`:548–556`). Drift's remote channel wraps
the migration callback error in `DriftRemoteException`; its `toString()` still
prints the original exception, concealing the different runtime type.

Both real-file probes (schema 7 and 18), using that production connection
composition, threw `DriftRemoteException` rather than returning a refusal. The
file bytes remained unchanged. Consequently `main.dart:80–101` logs a generic
open error and falls through to normal bootstrap instead of showing the
recovery screen. The S1.5 tests use direct `NativeDatabase(file)` and miss this.
This is host-reproduced; Android startup itself was not run.

**Task scope:** preserve/classify the refusal across the background connection
at the data/bootstrap boundary, with tests using the actual connection shape.
Do not infer a version by parsing exception text, reinterpret arbitrary I/O
failures as schema refusals, change migration semantics, or reset newer data.

**Acceptance:** v7 returns the below-floor refusal and v18 returns the newer
refusal through `LazyDatabase` + background native connection; the corresponding
startup branch is selected; refusal leaves bytes unchanged; confirmation and
Cancel retain their S1.5 behavior; unrelated open failures remain failures.

### S1.V2 — Seed the replacement database independently of old seed markers

**TD-060; P2, conditional; S1.5 / A6. Depends on S1.V1 for the reachable UI.**

The confirmed reset renames the database and reruns `_start`, retaining
SharedPreferences (`main.dart:92–94`). `CatalogSeeder.seedIfNeeded` returns
immediately when the stored version is already 2 (`catalog_seeder.dart:192`),
before checking the replacement database. With that marker retained, the real
reset + fresh-database + seeder probe produces **0 targets, expected 164**.
The existing test resets mock preferences to an empty map; production does not.

This finding requires an already populated seed marker alongside the refused
file. It does not claim every original pre-v8 installation has that marker.
It is a confirmed missing recovery case, currently also masked by TD-059.

**Task scope:** make confirmed database replacement initialize catalog-seeding
state consistently for the new database, while preserving unrelated preferences
and the normal rule against resurrecting catalog entries the user deleted.
Do not clear all preferences or redesign backup/restore.

**Acceptance:** with and without an existing applied-version marker, confirmed
reset preserves the refused file and creates a working, seeded database; Cancel
changes neither file nor preferences; failures remain retryable; ordinary
startup still respects intentional catalog deletions.

### S1.V3 — Preserve the unsaved-plan safeguard across restart

**TD-061; P2; S1.6 / A7 / RT-05 / UX-12 / RD-05 interim.**

`CurrentSession.resume` (`current_session.dart:42–48`) recognizes a draft as
edited only if it was previously saved or its blocks differ from the example.
A never-saved draft with only a target or night edit retains example blocks and
has no `plannedAtUtc`. The tests independently change only the target or only
the night, await autosave, then rebuild the real ViewModel graph. The same draft
resumes, but **`hasUnsavedChanges` changes from true to false**. New/Duplicate/
Open therefore bypass the confirmation, leaving that draft unlisted.

**Task scope:** retain reliable knowledge of relevant plan edits across restart
through the existing persistence abstractions. Keep the owner-approved site
exception and untouched-draft behavior. No draft listing/cleanup or defaults
redesign. If exact persistence needs a schema or product decision, report that
decision before implementation; this validation does not choose it.

**Acceptance:** separate target-only, equipment-only, night-only and block-only
edits remain protected after restart; each replacement action asks; Cancel
preserves the plan; an untouched draft still does not ask; successful Save
clears the flag and a failed Save/Start does not. The current probes establish
target/night failures; equipment is an additional required regression case.

### S1.V4 — Reopen the current planner without replacing it from stale detail data

**TD-062; P2; S1.6 / A7 / RT-05 / UX-12.**

The detail page loads its `Session` once (`session_detail_screen.dart:39–50`).
Its Open action skips the guard for the current ID but still calls
`plan.openSession(s)` (`:388–398`), reapplying that cached session and clearing
the edited flag through `CurrentSession.adopt`.

**UI reproduction, no injected timing:** save; open its detail; Open in planner;
add a block with 7 frames; go Back to the existing detail; Open in planner again.
There is no warning. The planner reverts to the old example blocks (last block
20 frames) and `hasUnsavedChanges` becomes false. Probe output:

```text
Expected: {'lastCount': 7, 'unsaved': true}
Actual:   {'lastCount': 20, 'unsaved': false}
```

The autosaved edit is initially still in SQLite; this is an immediate rollback
of the displayed plan and its protection. A subsequent whole-plan write can
persist the stale content. This is independent of TD-058's rapid-tap race:
every step above was awaited before the next action.

**Task scope:** opening an already-current session must preserve its live plan
and unsaved state; prevent stale detail data from being reapplied. Retain the
guard for another session and the copy behavior for frozen sessions.

**Acceptance:** the reproduction keeps the added block and edited flag without
an unnecessary prompt, including after another Save/restart; another session's
Open still supports Cancel/Discard; completed sessions still open as copies.

## Acceptance review by original Task

| Task / items | Assessment and evidence |
| --- | --- |
| S1.1 / A3 | PASS: identifying header and MockClient regression; parsing unchanged |
| S1.2 / A2, E1, E3 | Catalog failure/retry, partial retry and upgrade paths pass; duplicates skipped; equipment already retries. Privacy read-failure test passes; write-path guarding is present in code but the new E3 test exercises only the read |
| S1.3 / A1, E2 | PASS for approved freshness/resume/weather-rollover behavior: fake-clock tests and snapshot-at-save; timer teardown test; caches key on snapshot/age. TD-057 remains recorded, outside this fix queue |
| S1.4 / A4 | PASS under owner correction: default-position resolver, no astronomy without a site, explicit picked date preserved, line cap enforced |
| S1.5 / A6 | FAIL: direct-connection and standalone UI tests pass, production-shaped connection fails (TD-059); retained seed marker exposes TD-060 |
| S1.6 / A7 | FAIL: ordinary New/Duplicate/Open guards and dialog accessibility pass; restart and same-session reopening bypass protection (TD-061/062) |
| S1.7 / A5, C2 | PASS: shared quantity formatting, boundary tests, updated widgets, dead getter removed. Remaining minute/hour conversions in presentation are relative forecast age and timezone offsets, not competing budget-duration formatters |
| S1.8 / C1, C4, B2, SCI-05 | PASS: focal ratio, notes, overhead text, footer, wrapping helper, Bortle explanation, night-span label, frame-fill wording and neutral ISO/gain label checked against code/tests |
| S1.9 / C3 | PASS: missing-input vs real no-window states, light/dark caution and contrast, red/black field tokens |
| S1.10 / D1, D2 | PASS: populated forecast in accessibility sweep; dynamic strip height/scaled widths and label gap; all six theme/text-scale sweeps pass |
| S1.11 / D3 | PASS on host: all seven control semantics expose enabled state and tap actions; semantics tap changes a frame count. TalkBack remains Stage 11 |
| S1.12 / F | PASS for serialized Save/Start and the UI regression cases; lifecycle/E2E pass. Current tests cover Save/Start followed immediately by an edit; TD-058 remains separate |
| S1.13 / B1, B3, B4, B6, SCI-04 | PASS: precipitation and midnight labels, CALC-28/29/32 notes, accepted grid caveat, source citations and added normalization test; existing numeric expectations unchanged |
| S1.14 / RD-17 | DEFERRED by owner; not a validation failure |
| S1.15 / B5 | Listed corrections verified: optical comments, SI statuses, CALC-07/13/17/28, DEV-P2, feature/CI/app-ID entries, external services, handoff pointer and device wording. New validation findings supersede S1.5/S1.6 completion claims in living registers |

Minor scope/evidence differences: S1.6's text says Cancel returns to the planner,
but Tonight's test explicitly keeps Tonight visible and the dialog merely
closes. Record that navigation mismatch for clarification in S1.V3; this report
does not redefine Cancel. The privacy write-failure assertion noted above and
S1.12's edit-before-Save/Start ordering are additional test-depth gaps, not
reproduced defects. Historical before-fix failure claims were inspected in the
Task record; this pass did not rerun every old commit.

## Reproducing the additional probes

The [retained patch](evidence/STAGE_1_VALIDATION_PROBES.patch) adds assertions to
the existing test fixtures; it changes no production code and removes no tests.
It is evidence, intentionally outside the default test discovery path. On a
clean checkout of `4e653fb` (or this documentation-only validation commit):

```text
git apply --check docs/refinement/evidence/STAGE_1_VALIDATION_PROBES.patch
git apply docs/refinement/evidence/STAGE_1_VALIDATION_PROBES.patch
flutter test --no-pub test/data/database/unsupported_database_test.dart test/presentation/viewmodels/planner_draft_session_test.dart test/presentation/shared/unsaved_plan_guard_test.dart --plain-name "validation:" --reporter expanded
git apply --reverse docs/refinement/evidence/STAGE_1_VALIDATION_PROBES.patch
```

Expected at the validated baseline: 6 failures, 0 passes: background v7/v18,
retained seed marker, target-only/night-only restart, and same-session reopen.
The reverse command was run after validation; no failing probe was left in the
ordinary test suite. Review the patch again before applying it to later code.

## Next allowed action

Owner review of S1.V1–S1.V4 and the noted acceptance differences, alongside the
earlier S1.16/S1.17 proposals and V3 decision; select one
focused fix Task. Do not implement a fix or start Stage 2 in this validation
session. After approved fixes, repeat independent Stage 1 validation. RD-17,
TD-057, TD-058, Stage 11 device evidence and Stage 2's RG-01/sample requirements
remain as previously recorded.
