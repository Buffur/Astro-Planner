# AstroPlan — Stage 0: Post-Roadmap Refinement Baseline

You are working on an existing Flutter application called **AstroPlan / Astro Planner**.

This task is **documentation, context reconstruction, and strategic planning only**.

Do **not** modify application code.

Do **not** begin implementation of Stage 1 or any later stage.

Do **not** fix audit findings during this task.

Do **not** redesign screens during this task.

Your job is to establish the authoritative post-roadmap refinement framework that future Opus 5.5 sessions will use.

---

# 1. Working Method

Use this workflow:

**READ → VERIFY → SYNTHESIZE → STRUCTURE → REVIEW → DOCUMENT → COMMIT → STOP**

Do not stop after producing an internal plan.

Complete the documentation work, verify it against the repository sources, commit it, and then stop.

Before making any documentation change, verify the current repository state and the current contents of the referenced source-of-truth files.

If repository evidence contradicts anything in this prompt, do not silently choose one side. Record the discrepancy and preserve the repository evidence.

---

# 2. Read First

At minimum, read:

```text
CLAUDE.md

docs/MASTER_ROADMAP.md
docs/ROADMAP.md

docs/PRODUCT_SPEC.md
docs/PROJECT_HANDOFF.md
docs/ARCHITECTURE.md
docs/DATA_MODEL.md
docs/FEATURE_STATUS.md
docs/TECH_DEBT.md
docs/DECISIONS.md
docs/PROJECT_AUDIT.md
docs/SCIENTIFIC_INTEGRITY.md
docs/TEST_PLAN.md

docs/audit/01_ROADMAP_COMPLIANCE.md
docs/audit/02_ENGINEERING_AUDIT.md
docs/audit/03_SCIENTIFIC_AUDIT.md
docs/audit/04_RUNTIME_AUDIT.md
docs/audit/05_UI_UX_AUDIT.md
docs/audit/06_COUNTER_AUDIT.md
docs/audit/07_FINAL_AUDIT.md
docs/audit/08_MANUAL_DOGFOODING.md
```

If another file is directly referenced by those documents and is necessary to understand a decision, inspect it as well.

Do not perform a new repository-wide audit.

Use the existing audit evidence and verify only what is necessary to prevent stale or contradictory planning assumptions.

---

# 3. Evidence Hierarchy

Treat the audit documents differently.

## 3.1 AI audit reports

`01` through `07` were produced by an AI audit process.

Use them as structured technical evidence, but respect their classifications and counter-audit results.

Do not revive findings rejected by `06_COUNTER_AUDIT.md` unless new repository evidence proves the issue exists.

Do not automatically treat hypotheses or recommendations as confirmed defects.

## 3.2 Manual dogfooding report

`08_MANUAL_DOGFOODING.md` was written by the project owner after personally using the application.

Treat it as a distinct evidence source containing:

- human-observed usability symptoms;

- author/product intent;

- real-world astrophotography workflow observations;

- proposed solutions;

- preferences and open questions.

Do not treat every proposed solution in it as already approved architecture.

Separate:

```text
HUMAN OBSERVATION
AUTHOR / PRODUCT INTENT
PROPOSED SOLUTION
RESEARCH QUESTION
PREFERENCE / SUBJECTIVE
```

The owner observations must not be lost merely because the AI audit did not mention them.

---

# 4. Updated Core Product Direction

The previous roadmap remains valuable and its technical foundations must be preserved.

However, the product direction is now clarified as follows:

> **AstroPlan is primarily a user-friendly planner for upcoming astrophotography sessions.**

The application should help the user answer, with as little unnecessary friction as possible:

```text
What can I image?
When can I image it?
With which equipment?
How should I plan the capture?
Does the planned session realistically fit the available night?
```

The product should remain scientifically honest and technically transparent, but technical detail must support the planning task rather than dominate the user experience.

The existing domain, scientific, persistence, session, execution, and logbook foundations should not be removed merely to simplify the interface.

Instead:

- preserve correct functionality;

- improve its hierarchy;

- reduce unnecessary manual entry;

- eliminate duplicated or unclear workflows;

- use progressive disclosure where appropriate;

- automate trustworthy data acquisition where possible;

- keep unknown values unknown;

- preserve provenance;

- keep advanced information reachable.

---

# 5. Important Product Reframing

The old product loop emphasized:

```text
Plan → Execute → Log
```

For refinement planning, treat the product as:

```text
PLAN FIRST

Site / Equipment / Target
        ↓
Night & Imaging Opportunity
        ↓
Capture Plan
        ↓
Fit / Feasibility
        ↓
Saved Session
        ↓
Optional Execution / Tracking
        ↓
Actual Result / Logbook
```

Execution and logging remain valuable supporting workflows.

They must not dominate or unnecessarily complicate the core planning experience.

Do **not** remove Execution in this task.

Do **not** redesign it in this task.

Its future role will be decided in a later product-flow stage.

---

# 6. Non-Negotiable Existing Constraints

Preserve the following established principles unless a later explicit owner decision changes them:

- offline-first core;

- transparent calculations;

- no composite black-box Astro Score;

- thresholds are configurable preferences, not physical laws;

- unknown values stay unknown;

- no fabricated values;

- assumptions remain reachable;

- Relative stacking gain remains **√N vs one frame**, not physical SNR;

- scientific calculations are not silently changed;

- Provider architecture remains unless explicitly reconsidered later;

- no rewrite;

- no unnecessary dependency injection redesign;

- no uncontrolled scope expansion;

- deferred/rejected roadmap features remain deferred/rejected until explicitly reopened;

- web scraping remains rejected unless an explicit future owner decision changes that;

- external datasets/APIs require source, licence, reliability, and provenance review before implementation.

---

# 7. Critical Current-State Clarification: Metadata

Do not assume metadata extraction is implemented.

It is **not yet implemented as the new production-ready metadata foundation**.

The old roadmap's G17 remains useful as a dependency model:

```text
17.1 — safe bounded/header-only file access
17.2 — typed metadata + real sample verification
17.3 — metadata-assisted actuals
```

The first two concepts still need to be implemented.

Do not treat `17.3` as the immediate next step after extraction.

The updated refinement workflow introduces an important intermediate stage:

```text
Metadata Foundation
        ↓
Metadata → Equipment / Device Import
        ↓
Product Flow / IA Decisions
        ↓
Later metadata-assisted actuals / reconciliation
```

The metadata-to-equipment stage must be separate because reliable metadata extraction and equipment identity/specification mapping are different problems.

Do not silently write extracted metadata directly into Equipment until that mapping and provenance model has been researched and explicitly designed.

---

# 8. Research / Hypothesis Rule

Several owner observations are intentionally **not yet implementation decisions**.

Examples include:

- automatic Bortle/SQM retrieval;

- automatic elevation retrieval;

- large equipment databases;

- external camera/lens databases;

- metadata-derived equipment specifications;

- calibration-frame simplification;

- exact ISO/Gain/Binning/WB/Focus UI rules;

- final role of Execution;

- possible Analytics navigation;

- licence replacement;

- target catalog expansion strategy;

- Basic/Advanced UI modes.

These must first be handled through:

```text
RESEARCH
    ↓
EVIDENCE
    ↓
OPTIONS / TRADE-OFFS
    ↓
OWNER DECISION / ADR WHEN NEEDED
    ↓
IMPLEMENTATION
```

Do not convert research questions into implementation tasks without that gate.

---

# 9. Create a New Refinement Documentation Area

Create:

```text
docs/refinement/
```

and at minimum:

```text
docs/refinement/PRODUCT_DIRECTION.md
docs/refinement/POST_ROADMAP_PLAN.md
docs/refinement/PROGRESS.md
```

Do not create implementation files.

---

# 10. PRODUCT_DIRECTION.md

Create a concise but authoritative product-direction document.

It should define:

## 10.1 Primary product job

AstroPlan is a user-friendly planner for upcoming astrophotography sessions.

## 10.2 Primary users

Keep the existing manual / semi-automated imager focus, while acknowledging that the UI should not require expert-level manual data entry where trustworthy automation is possible.

Do not redefine AstroPlan as a beginner-only application.

Experienced astrophotographers must retain access to advanced information.

## 10.3 Primary workflow

Describe the planning-first workflow.

## 10.4 Supporting workflows

Execution, actuals, Logbook, export, backup.

## 10.5 Product principles

Include at least:

- answer-first;

- progressive disclosure;

- automate trustworthy inputs;

- advanced data remains reachable;

- preserve scientific honesty;

- reduce duplicated actions;

- minimize unnecessary manual input;

- clear state and feedback;

- field usability remains important;

- Notion-inspired visual identity remains a direction, not a restriction.

## 10.6 What should not happen

Explicitly protect against:

- deleting valid domain functionality simply because the current UI is poor;

- redesigning around raw domain entities;

- creating a black-box score;

- inventing missing values;

- turning the project into a planetarium or hardware-control suite;

- forcing users to manually enter data the application can reliably obtain itself.

---

# 11. POST_ROADMAP_PLAN.md

Create the strategic refinement plan using **Stages**, not a premature complete task list.

The plan should contain approximately the following structure, but refine names/descriptions if repository evidence suggests better wording.

---

## Stage 0 — Refinement Baseline

Purpose:

- establish new product direction;

- create refinement source-of-truth documents;

- define workflow rules;

- no application code changes.

---

## Stage 1 — Verified Fixes & Clean Baseline

Purpose:

Resolve surviving confirmed audit issues before structural feature and UX work.

Include the confirmed families of issues from the Final Audit and Counter-Audit, such as:

- forecast freshness / rollover;

- failed seed incorrectly marked applied;

- missing third-party User-Agent;

- siteless draft night-key issue;

- inconsistent duration formatting;

- unsupported/newer DB recovery UX;

- surviving scientific wording/documentation issues;

- visible trust-eroding UI text/format issues;

- accessibility overflow;

- test blind spots where relevant.

Do not invent new defects.

Do not revive rejected audit findings.

Mark this as primarily implementation, low research.

---

## Stage 2 — Metadata Foundation

Purpose:

Build the production-ready metadata extraction layer.

Preserve the dependency logic of old G17.1 and G17.2:

- safe file access;

- bounded/header-only parsing;

- supported format decision;

- FITS header reading;

- bounded EXIF/RAW metadata reading;

- I/O in the data layer;

- typed metadata;

- provenance;

- explicit unknowns;

- real owner-supplied samples;

- corrupted/missing-field cases;

- memory/resource validation.

Do not include Equipment persistence in this stage.

Do not include assisted actuals yet.

---

## Stage 3 — Metadata → Equipment / Device Import

Purpose:

Reduce manual equipment setup using verified metadata.

This Stage must start with a research and architecture gate.

Research should later determine:

- which metadata identifies camera/device reliably;

- Make/Model/LensModel semantics;

- FITS camera/instrument conventions;

- smartphone behaviour;

- manual lenses/telescopes;

- what cannot be derived;

- whether a sourced equipment catalog is needed;

- matching existing Equipment;

- provenance and confidence;

- conflicts between user data and imported data.

Expected design principle:

```text
Metadata
    ↓
Equipment Candidate
    ↓
Match / Enrich
    ↓
User Confirmation
    ↓
Persist
```

No silent writes.

Unknown specifications remain unknown.

---

## Stage 4 — Product Flow & Information Architecture

Purpose:

Resolve the user-facing relationship between:

- Tonight/Home;

- Planner;

- New Plan / New Session;

- internal Draft state;

- Saved Session;

- Start;

- Execution;

- Results;

- Sessions;

- Logbook;

- Library.

This Stage is primarily product/UX analysis and decision-making before implementation.

Use AI UX audit + counter-audit + manual dogfooding.

Do not preselect a solution simply because it appeared in an audit.

---

## Stage 5 — Design System Foundation

Purpose:

Create the reusable visual and interaction system before redesigning screens individually.

Include:

- typography hierarchy;

- primary/secondary/tertiary text;

- surfaces/cards;

- spacing;

- forms;

- buttons;

- icons;

- dividers;

- statuses;

- alerts;

- dialogs;

- destructive interactions;

- motion/feedback;

- accessibility;

- dark/red-mode constraints.

Preserve the Notion-inspired direction while allowing better patterns where needed.

---

## Stage 6 — Core Planner Redesign

Purpose:

Apply the approved IA/design system to the main planning experience.

Expected areas:

- Tonight/Home hierarchy;

- Planner identity/state;

- target/night/site context;

- Opportunity / Tonight for this Target;

- chart/timeline;

- Capture Plan;

- Capture outputs;

- Fit communication;

- Relative stacking gain presentation;

- technical assumptions;

- progressive disclosure.

Core principle:

```text
Primary answer
    ↓
Planning action
    ↓
Supporting detail
    ↓
Technical detail
```

---

## Stage 7 — Data Entry & Automation

Purpose:

Reduce unnecessary manual entry across:

- Targets;

- Sites;

- Equipment;

- Capture Plan fields;

- calibration frames;

- forms generally.

This Stage contains multiple research gates.

Do not assume reliable solutions already exist for:

- elevation;

- Bortle;

- SQM;

- equipment databases;

- target catalog expansion;

- calibration inheritance;

- ISO/Gain/Binning/WB/Focus rules.

Research first where external evidence is required.

---

## Stage 8 — Sessions / Execution / Actuals / Logbook

Purpose:

Refine supporting post-plan workflows after the planning experience is stable.

Revisit:

- optional vs primary role of Execution;

- tracker;

- Start semantics;

- reconciliation;

- planned vs actual;

- Logbook;

- session names;

- search;

- filters;

- share/export presentation.

Bring the old metadata-assisted actuals concept here, after the final workflow is known.

---

## Stage 9 — Secondary UX & Product Polish

Purpose:

Refine lower-priority but important areas, including:

- Settings;

- Library;

- About;

- authorship;

- sources/attribution;

- GitHub/Reddit links;

- licence research and later implementation;

- deletion interactions;

- animations;

- logo;

- splash screen;

- final visual consistency.

Do not implement a licence change without a dedicated legal/licensing research decision first.

---

## Stage 10 — Performance & Application Size

Purpose:

Measure first, optimize second.

Include:

- form/input lag profiling;

- rebuild analysis;

- keyboard interaction;

- Provider notification/rebuild behaviour;

- animation cost;

- release performance;

- app-size analysis;

- APK/AAB/install-size distinction;

- native libraries;

- assets;

- fonts;

- dependencies.

Do not treat the manually observed ~277 MB number as a confirmed production release-size defect until measured correctly.

---

## Stage 11 — Full Validation & Beta Readiness

Purpose:

Independent final validation.

Include:

- refinement-plan compliance;

- full test suite;

- Android emulator;

- physical devices;

- lifecycle;

- permissions;

- process death;

- offline behaviour;

- live provider behaviour;

- metadata formats;

- equipment import;

- backup/restore;

- 200% text;

- TalkBack;

- red mode in darkness;

- low-end performance;

- release build;

- signing;

- CI;

- compliance;

- manual owner dogfooding.

No release claim without the required evidence.

---

# 12. Stage Workflow Rules

Document the workflow every Stage should use.

Default:

```text
1. Fresh Opus 5.5 chat
2. Read current Stage and repository state
3. Verify prerequisites
4. Create Stage execution plan
5. Identify research gates and owner decisions
6. Freeze approved task sequence
7. Execute tasks sequentially
8. One coherent task per implementation session/chat where practical
9. Validate each task
10. Commit each completed task
11. Fresh independent Stage validation
12. Create focused fix tasks if validation finds issues
13. Close Stage
14. Update PROGRESS.md
15. Start next Stage in a fresh chat
```

---

# 13. Task Sizing Rules

Record the default task-sizing philosophy.

A good implementation task should normally have:

- one primary behavioural objective;

- one coherent scope;

- explicit dependencies;

- explicit out-of-scope;

- objective acceptance criteria;

- one complete validation loop.

Do not optimize for maximum lines changed.

Do not create artificially tiny tasks when one coherent behaviour spans several layers.

Cross-layer work is acceptable if every change supports the same behavioural objective.

A task should be decomposed if it combines multiple independent decisions or requires unresolved research.

As a rough continuity with the previous roadmap:

```text
S — focused/local task
M — one coherent cross-layer behaviour
L — usually decompose unless the work is highly cohesive
XL — do not use as an implementation task
```

---

# 14. Prompt / Context Rules for Future Sessions

Document these rules in the refinement plan.

Future implementation prompts should not paste the entire repository history or all audits.

Each prompt should identify:

```text
Task ID
Objective
Why
Read first
Important current-state facts
Scope
Out of scope
Constraints
Acceptance criteria
Required validation
Stop condition
```

Then allow Opus to inspect implementation files just-in-time.

Use repository documentation as persistent memory.

Do not repeatedly paste:

- the full Master Roadmap;

- all audit reports;

- old chat transcripts;

- large architecture summaries.

Refer to exact files and finding IDs instead.

---

# 15. Standard Implementation Workflow

Record this as the default execution loop:

```text
READ
→ VERIFY CURRENT STATE
→ PLAN
→ IMPLEMENT
→ TARGETED TESTS
→ REGRESSION / QUALITY GATE
→ SELF-REVIEW
→ UPDATE REQUIRED DOCS
→ COMMIT
→ STOP
```

The agent must not stop after planning if the approved task is implementable.

The agent must not begin the next task automatically.

---

# 16. Scope-Drift Rule

Add this rule explicitly:

> If an adjacent issue is discovered, document it but do not fix it unless fixing it is necessary to satisfy the current task's acceptance criteria.

Also:

> If the current task turns out to require a materially larger architectural change than its approved scope, stop before implementing the out-of-scope portion, document the reason, and propose a decomposition.

However, ordinary implementation complexity alone is **not** a reason to stop.

If the task is coherent and achievable within scope, complete it fully.

---

# 17. Stale-Finding Rule

Future fix tasks based on audit findings must first verify that the finding still exists in the current repository.

Record:

> Before modifying code for an audit finding, verify the cited mechanism still exists. If later changes already resolved or materially changed it, report the discrepancy rather than implementing an obsolete fix.

---

# 18. Research Workflow

Document the standard research flow:

```text
QUESTION
→ CURRENT CONSTRAINTS
→ PRIMARY / AUTHORITATIVE EVIDENCE
→ VERIFIED FACTS
→ UNKNOWNS
→ OPTIONS
→ TRADE-OFFS
→ RECOMMENDED DIRECTION
→ OWNER DECISION
→ ADR / SPEC IF NEEDED
→ IMPLEMENTATION TASKS
```

Research and implementation should normally happen in separate sessions.

Research should not silently modify production code.

---

# 19. Validation Model

Document two validation levels.

## Task validation

Performed within the implementation task:

- targeted tests;

- affected regression tests;

- analyzer / formatting;

- required quality gate;

- explicit acceptance-criteria verification.

## Stage validation

Performed in a fresh Opus 5.5 session.

The validator should attempt to disprove that the Stage is complete.

Default instruction:

```text
Do not implement fixes during validation.
Verify the Stage against its defined acceptance criteria.
Look for regressions, scope drift, incomplete tasks, stale assumptions,
architecture violations, scientific-integrity issues, and missing evidence.
```

If findings survive review, create focused fix tasks.

---

# 20. PROGRESS.md

Create a compact operational state document.

Include at least:

```text
Current strategic phase
Current Stage
Stage status
Current/next approved Task
Completed Tasks
Relevant commits
Open research gates
Open owner decisions
Known blockers
Validation status
Next allowed action
```

At the end of this task, Stage 0 should be marked complete.

Stage 1 should be listed as next.

Do not mark Stage 1 started.

---

# 21. Preserve Historical Documentation

Do not rewrite historical roadmap or audit documents to match the new direction.

The old roadmap remains historical evidence of how the current application was built.

The new `docs/refinement/` area is the source of truth for post-roadmap refinement.

Where the new direction supersedes an older product assumption, state that explicitly in the refinement documents instead of rewriting history.

---

# 22. Review Requirements Before Commit

Before committing:

1. Re-read the three new refinement documents.

2. Verify they do not claim metadata extraction is already implemented.

3. Verify metadata-to-equipment import is separate from metadata extraction.

4. Verify research hypotheses are not presented as approved implementation decisions.

5. Verify Execution is preserved but treated as a supporting workflow pending Stage 4.

6. Verify the scientific-integrity principles remain intact.

7. Verify no rejected/deferred feature has silently become approved.

8. Verify all major categories from `08_MANUAL_DOGFOODING.md` have a clear future home in the Stage structure.

9. Verify confirmed engineering/scientific/runtime issues from the Final Audit are represented in Stage 1.

10. Verify no application code has changed.

---

# 23. Commit

Create one documentation-only commit for Stage 0.

Use the repository's established commit style if one exists.

The commit should clearly communicate that this establishes the post-roadmap refinement baseline.

---

# 24. Final Response

At the end, report concisely:

- files created/updated;

- the finalized Stage structure;

- any material discrepancy found between this prompt and repository evidence;

- any unresolved owner decisions discovered;

- validation performed;

- commit hash;

- exact next allowed action.

Then **STOP**.

Do not begin Stage 1.

Do not propose implementation details for Stage 1 beyond what is documented in the strategic plan.
