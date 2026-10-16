# AstroPlan — AI Engineering Guidelines

> Updated 2026-10-17: concise entry point; current status is in `docs/refinement/PROGRESS.md`. The prior file is preserved in `docs/archive/CLAUDE_2026-10-17_BEFORE_REASSESSMENT.md` as historical evidence only.

## Product and architecture

- AstroPlan is a planning-first Flutter/Dart astrophotography organizer: construct a realistic Capture Plan, understand integration time, acquisition/session time, storage and fit within an imaging opportunity, then save and organize the result.
- Weather, Moon, execution history, Logbook, export and backup support planning. Do not turn the app into a planetarium or telescope/camera controller.
- Preserve useful scientific capabilities through clear hierarchy and progressive disclosure. An explicitly approved reassessment may propose removal or changed prominence; implementation still needs the resulting product decision.
- Use Provider/ViewModels, go_router and Drift/SQLite. Keep presentation → ViewModels → repositories → data/services, with astronomy and capture calculations independent of Flutter.
- Core planning, equipment, targets and records work offline; external services enrich the experience.
- Unknown stays unknown. Use explicit units and established UTC/zone/DST/SessionNight abstractions. Never present √N stacking gain as absolute physical SNR or claim ISO increases photon collection. Distinguish theoretical payload from empirical file size.
- No arbitrary universal scientific thresholds or black-box Astro Score. Preserve provenance, documented assumptions, user confirmation and data integrity.

## Sources and instruction precedence

1. Follow the owner's current explicit scope; an implementation prompt authorizes the complete named Task. Report conflicts with older decisions; do not silently invent approval for unrelated work.
2. `docs/refinement/PROGRESS.md`: current work, blockers, evidence and next allowed action. Read the current summary and next action first, not its whole history.
3. `docs/refinement/PRODUCT_DIRECTION.md`: accepted product direction; `docs/refinement/POST_ROADMAP_PLAN.md`: Stage dependencies and approved scope; the named session prompt: Task boundaries and acceptance criteria.
4. Code is evidence of actual behavior. ADRs and approved decisions define intended behavior. Record implementation deviations; never rewrite historical intent to match code.
5. Relevant `.agents/rules/*.md` supplement this file. This file's scope/approval rules and canonical Verification Policy resolve conflicting older generic rules or skills. Do not assume `.agents/rules` or `.agents/skills` are automatically loaded by Claude Code: explicitly read only the relevant files.
6. Auto-memory and old chat summaries are navigation hints, not current task authority. Verify remembered stages, test counts and next actions against PROGRESS and code; do not let stale memory restart a completed Stage.
7. Historical roadmaps, audits and `docs/archive/` are evidence of their dated baseline, never the current task queue. `docs/PROJECT_HANDOFF.md` is an orientation/history source; use refinement documents for current work.

Read on demand:
- `docs/ENGINEERING_GUARDRAILS.md`: required relevant traps before changing persistence, lifecycle, time, weather, metadata, UI, tests, privacy, signing or release. “CLAUDE.md trap N” in older documents resolves there, with numbering preserved.
- `docs/ARCHITECTURE.md`, `docs/DATA_MODEL.md`, `docs/DECISIONS.md`: relevant architecture, schema and accepted ADR sections.
- `docs/FEATURE_STATUS.md`, `docs/TECH_DEBT.md`, `docs/SCIENTIFIC_INTEGRITY.md`: relevant feature/finding/calculation IDs.
- `docs/DESIGN_SYSTEM.md`: UI tokens, accessibility and interaction patterns; `docs/EXPORT_MANIFEST.md`: export contract, updated with SessionManifestCodec and versioned for incompatible changes.
- `docs/refinement/prompts/PRODUCT_REASSESSMENT.md`: bounded reassessment scope and complete review coverage, when that Task is active.

## Post-Roadmap Workflow Governance

### Active scope and completion

- Inspect and verify current code before modifying it or acting on an old finding.
- Read the active prompt completely and resolve referenced files yourself. Read adjacent code only as needed; do not re-audit the repository for every Task.
- Prefer the smallest complete change. Preserve existing patterns; no unrelated refactors, speculative abstractions, destructive commands, or reversal of user changes.
- Approved implementation: READ → VERIFY → PLAN → IMPLEMENT → VERIFY → SELF-REVIEW → DOCS → COMMIT → STOP, subject to the owner's Git instructions. Multi-file or cross-layer work inside that scope needs no second approval.
- A new unresolved product/scientific/architecture/provider decision or material scope expansion needs the appropriate decision gate. Ordinary implementation difficulty does not justify stopping.
- Research, planning and validation do not authorize application changes. Record adjacent findings without opportunistic fixes. Reassessment may challenge past product choices without reopening unrelated passed criteria.
- Do not start another Task/Stage automatically. A grouped run must explicitly name its authorized Tasks and stop conditions. Closing a Task and advancing the next-action record is not authorization to execute it.
- Each Task has one behavioral objective, dependencies, exclusions, acceptance criteria and a complete validation loop. Decompose incoherent large tasks; no line-count quotas.
- Never remove or weaken tests to force a pass. Verification requirements are defined below, not duplicated in prompts or skills.

### Research and context discipline

- Research external facts that code cannot establish and that affect a decision. Use available WebSearch/WebFetch tools without requiring a separate request per query, within configured permissions; prefer primary sources, record URLs, access date, verified facts and unknowns.
- Never claim browsing happened when tools were unavailable. Report the evidence gap; a Markdown instruction cannot enable tools or override managed permissions.
- External APIs/datasets require evidence of reliability, terms/licence, provenance, privacy and failure behavior before adoption. Do not hardcode secrets or silently persist inferred metadata.
- Read relevant skills only when needed; generic setup recipes do not authorize replacing working project architecture or dependencies.
- Use a fresh session at completed Task boundaries and for independent validation where practical. Handoff only decisions, scope, changed files, acceptance evidence, unknowns and the next allowed action; do not require old chats.
- Avoid unconditional imports of detailed guides/history: imports load their content too. Use topic references and selective reads.
- Reuse existing research while its relevant facts remain current; refresh only facts that could change the decision. Do not use a full quality-gate run merely to investigate a documentation claim.

### Documentation and Git

- Update only documents whose statements the change invalidates; record stable finding/decision IDs without renumbering. Keep intent separate from actual state and preserve superseded history.
- A code change may require FEATURE_STATUS/TECH_DEBT, architecture/data-model actual-state sections, scientific assumptions or ADRs; update the relevant ones in the same change, not every register indiscriminately.
- Keep CLAUDE.md and docs tracked. Record resolved findings with date and available commit evidence, never fabricate a future hash.
- Keep commits coherent. Never reset --hard, force push, delete unknown user files, or access signing secrets without the required explicit owner authorization. Push/publication requires explicit authorization; read current restrictions from PROGRESS.
- Signing keys/passwords are owner-managed: never create, read, print, commit or request them. Do not commit private real metadata samples or their values.
- Update privacy/compliance documents when adding data leaving the device. New providers, monetization, hardware control, cloud/auth/social features, scraping, or deferred sky-map/mosaic scope need explicit approved scope.
- State test/build/device/CI results accurately, identifying reused evidence and unverified surfaces. Historical test counts are not permanent acceptance criteria.

### Verification Policy (canonical)

This section is the **only** statement of what verification a change needs, when evidence may be reused, what a review may block on, and when work stops. Every other file (`.agents/rules/03-testing.md`, `POST_ROADMAP_PLAN.md` §9, `PROGRESS.md`, the prompts in `docs/refinement/prompts/`) refers here instead of restating it; where any of them differs, this section wins. Generic skills under `.agents/skills/` describe how to run a tool, not when this repository requires it. (Owner, 2026-09-27, the governance correction after Stages 1–4.)

**Principle:** verification is proportional to what changed and to what evidence the change could have invalidated. Rigor is kept where the risk is; repetition that cannot change the answer is removed.

**V1 — Required verification by change class.** Classify by the files actually changed; the highest class present wins.

| Change class | Required verification |
| --- | --- |
| **Documentation / governance only**: only Markdown (`.md`) files under `docs/` or `.agents/`, the probe `.patch` files under `docs/`, `CLAUDE.md` or `README.md`. Any other file, of any type or location, is not in this class (the analyzer reads every `.dart` file in the package, the `.agents/skills` examples included) | References and IDs resolve; the changed text is consistent with the documents it cites; `git diff --check` (whitespace). No application test, analyzer or gate run. |
| **Localized code change** (one feature area, no shared contract) | Targeted tests for the changed behaviour (new or updated), the tests of the touched files' area, `flutter analyze --no-pub`, `dart format` on the changed files, and `dart run tool/check_encoding.dart`. |
| **Shared behaviour** (a ViewModel, shared widget, theme, router, repository interface, or anything several screens use) | The above, plus the regression tests of every affected area. Run the full gate when the affected set cannot be listed with confidence. |
| **High-risk surface**: schema/migrations, persistence and data integrity, scientific calculations, time/night semantics (UTC, zones, DST, SessionNight), metadata parsing and provenance, backup/export formats, dependencies/lockfiles, build or test tooling (`tool/`, `analysis_options.yaml`, `build.yaml`, CI steps or the CI Flutter version) | **The full quality gate** (`dart run tool/check.dart`), plus the domain probes the Task names (migration tests, the local real-sample test for metadata, reference fixtures for calculations). A CI change that only filters *when* the gate runs needs its syntax and path logic checked, not a gate run. |
| **Correction after a review** | See V5: the original finding(s), the criteria the correction touches, and the correction's own regression surface, at the class of the files it changes. |
| **Task completion** (any code) | The class above for the Task's cumulative diff, run **after the last code change**, plus an explicit check of each acceptance criterion. A high-risk Task ends with one full-gate pass. A shared-behaviour Task ends with its affected regression checks, and escalates to the full gate only when that set cannot be bounded with confidence or its Task or Stage gate explicitly requires it. |
| **Stage / release gate** | Exactly the frozen Stage or release acceptance checks. The full gate or device evidence only where that gate requires it, and V3 applies to both. |

**V2 — A broader check satisfies a narrower one.** The full gate contains the encoding check, format, `flutter analyze`, all unit/widget tests and the host E2E suite. After it passes on the final inputs, do not rerun any of those separately. Targeted tests during development are for fast feedback; they are not required again after a passing broader run on unchanged inputs.

**V3 — Evidence reuse.** Passing evidence stays valid while the inputs relevant to it are unchanged. The inputs of the full gate are: application code (`lib/`, `assets/`, `android/`, `ios/`, other platform folders), test code (`test/`, `integration_test/`), dependencies (`pubspec.yaml`, `pubspec.lock`), and tooling (`tool/`, `analysis_options.yaml`, `build.yaml`, the Flutter version in `.github/workflows/ci.yml`); for an environment-dependent result (device, platform, real samples), also that environment.
- A new commit hash, a new chat or session, a changed review document or a changed `PROGRESS.md` does **not** invalidate evidence.
- Do not rerun a check to obtain a newer timestamp or hash. Rerun it only when (a) a relevant input changed, (b) the previous run is known to be invalid or incomplete, or (c) the acceptance gate being judged explicitly requires a fresh run.
- To reuse, record one line: the result, the commit or state it ran on, and why nothing since invalidates it (for example: `git diff --stat <commit> HEAD -- . ':!docs' ':!CLAUDE.md'` is empty).

**V4 — The acceptance surface is frozen before a review starts.** A Task review, Stage validation or sign-off judges only: the approved Task or Stage acceptance criteria; the approved owner decisions; the explicit invariants (the relevant traps in `docs/ENGINEERING_GUARDRAILS.md`, ADRs); and the verification this policy requires. A finding is a **BLOCKER** only if it shows:
- A. evidence that one of those criteria, decisions or invariants is not met;
- B. a regression caused by the work under review; or
- C. a severe correctness, data-loss, data-integrity, privacy or safety defect exposed by the work (state the concrete failure, not a hypothetical).

Everything else — a hypothetical edge case, an alternative design, an unspecified implementation detail, a preference, a newly invented policy — is recorded as `FOLLOW-UP`, `DEFERRED / IMPLEMENTATION DECISION` or `OWNER DECISION` (or in `TECH_DEBT.md` / `SCIENTIFIC_INTEGRITY.md`), and does not block. A review never adds acceptance criteria to the work it is judging, and never presents an inferred rule as an owner decision.

**V5 — Revalidation after a correction.** After a corrective Task fixes a blocker, the next validation checks only:
1. the original blocking finding(s);
2. the acceptance criteria the correction touches;
3. regressions plausibly caused by the correction (its own diff, at its V1 class).

It does not restart open exploration of the Stage; everything else keeps its PASS. A complete Stage revalidation is chosen only when the correction changes the Stage's approved design or acceptance contract, or touches enough of the implementation that the earlier evidence is invalid under V3. Whoever chooses it records why in one line.

**V6 — When a PASS may reopen.** Only on (a) new contradictory evidence (a failing test, a reproduced defect, a quoted contradiction), (b) a change to a relevant input under V3, or (c) an approved change to the criterion. A new session is not evidence; a different validator's reading of the same evidence is not by itself evidence.

**V7 — Stop and converge.**
- When every frozen criterion passes and no V4 blocker remains, the Task or Stage **closes**: record it and advance the Next Allowed Action. Do not validate the validation.
- If two consecutive validations of the same Task or Stage fail on interpretation or scope (findings that restate or reinterpret criteria already judged, rather than new contradictory evidence under V6), stop automatic revalidation. Record the disagreement and ask the owner to resolve the scope. (Stages 1–4 each needed the owner after two failed validations.)
- Validation-only sessions never fix what they find; surviving blockers become focused corrective Tasks.

**V8 — Fresh sessions.** Stage validation runs in a fresh session where practical, for independent reasoning. A fresh session reconstructs state from `PROGRESS.md` (its Next Allowed Action and reusable evidence), the frozen criteria and the sources they reference. It does not rerun tests whose inputs are unchanged (V3), reread historical audits or validation reports beyond those referenced, reopen passed criteria (V6), or reconstruct project history.

**Analysis-and-decision Stages** (research, owner decisions, ADRs and provisional Tasks; no
application code) are validated against a **bounded scope** — the V4 surface for such a Stage. The validation checks only:
- that the Stage's research Tasks were completed;
- that every required research gate has an explicit owner decision;
- that the ADR or specification faithfully records those decisions;
- that companion documents (wireframes, addenda) are consistent with it;
- that the decisions are mapped to later implementation Stages;
- that no direct contradiction makes an approved core flow impossible;
- that no Stage acceptance criterion is unmet.

A finding is blocking only when it demonstrates a direct contradiction with an approved owner
decision or an explicit Stage acceptance criterion. These are recorded as `DEFERRED /
IMPLEMENTATION DECISION`, not as blockers:
- an unspecified implementation detail;
- a hypothetical edge case;
- an alternative design;
- a policy that can safely be decided in the implementing Stage.

Neither a validation nor its corrective Task creates new product requirements, or presents inferred
rules as owner decisions. If the bounded validation passes, the Stage closes. If it fails, the
report names only the exact approved decision or acceptance criterion that is contradicted, with
evidence, and the Stage's scope is not expanded. (Owner, 2026-09-27; DECISIONS E.1, "Bounded
validation for analysis and decision Stages".)


## Commands and operational state

- Full gate when V1 requires it: `dart run tool/check.dart` (encoding, format, package analysis, unit/widget tests and per-file host E2E).
- Documentation-only: reference/ID consistency and `git diff --check`; no application gate.
- Use the toolchain recorded in PROGRESS; the machine default may be too old. Prefer `--no-pub` where the documented procedure permits it; release-build exception is in the engineering guide and RELEASE.md.
- CI configuration is in `.github/workflows/ci.yml`; verify actual remote runs before asserting success. Do not infer CI state from a historical “not pushed” note.
