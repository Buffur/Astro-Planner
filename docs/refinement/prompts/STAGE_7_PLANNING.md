Work from the CURRENT repository state.

This is a fresh Stage 7 planning session.

Do not rely on prior chat history.

First read the current canonical project state:

- `CLAUDE.md`
- `docs/refinement/PROGRESS.md`
- `docs/refinement/POST_ROADMAP_PLAN.md`
- `docs/refinement/PRODUCT_DIRECTION.md`
- `docs/DESIGN_SYSTEM.md`
- the current Stage 7 section of the amended post-roadmap plan
- the current research-gate / owner-decision registers relevant to Stage 7
- the current metadata/equipment decisions from Stages 2–3
- the current Stage 4/6 decisions that constrain Planner behavior
- the current decision record for RD-08 = T3
- current TECH_DEBT / finding entries owned by Stage 7
- any Stage 7-specific specs or research files referenced by the plan

Read additional files only when they are directly required to understand or verify Stage 7 scope.

Treat the CURRENT repository as authoritative for:

- exact task IDs;
- exact Stage 7 task names;
- exact research-gate IDs;
- current decisions;
- current implementation state;
- current ownership boundaries.

Do NOT re-run the one-time Stages 6–11 amendment brief.

Do NOT reopen Stage 6.

Do NOT start Stage 7 implementation code in this session.

Do NOT run another broad audit.

Do NOT silently answer unresolved research questions.

---

# PURPOSE

Perform Stage 7 — Data Entry & Automation planning only.

The purpose of this session is to make Stage 7 executable and evidence-driven.

The core Stage 7 principle is:

> Reduce unnecessary manual input only where AstroPlan already knows a value or can obtain it reliably. Unknown remains Unknown.

Stage 7 must not replace honest missing data with guesses.

---

# STAGE 7 PRODUCT INTENT

Stage 7 owns:

- reduction of unnecessary manual entry;
- target/catalog entry improvements;
- site/location automation where reliable;
- evidence-backed elevation/Bortle investigation;
- equipment/metadata-assisted input;
- contextual forms;
- Light parameter research;
- Binning;
- ISO vs Gain;
- White Balance relevance;
- Focus semantics;
- interval-between-exposures semantics;
- Dark workflow;
- Flat workflow;
- Bias workflow;
- parameter inheritance / prefill / ownership matrix;
- calibration workflow integration with Capture Budget;
- reliable storage-input acquisition if needed;
- the per-plan tracking override required by RD-08 = T3.

Stage 7 does NOT own:

- Stage 6 visual redesign;
- Saved Plan → Actual → Logbook;
- Track Live retirement;
- Settings redesign;
- branding;
- global performance work;
- final beta validation.

Do not pull Stage 8–11 work forward.

---

# GLOBAL DATA-ENTRY RULE

For every Stage 7 field or parameter, use this decision order:

1. Known from the current plan / entity / device / existing state
2. Reliable imported metadata
3. Reliable approved external source
4. Safe proposal / prefill
5. Explicit user input
6. Unknown

Do not skip directly from “not known locally” to “guess”.

Do not silently persist inferred or proposed values as facts.

---

# PRESERVE METADATA FOUNDATION

Preserve the already-approved metadata principles from Stages 2–3.

The intended flow remains:

Metadata Evidence
→ EquipmentCandidate
→ Match / Enrich
→ User Confirmation
→ Persist

Preserve:

- per-field provenance;
- bounded parsing;
- Unknown values;
- no silent equipment writes;
- no guessed phone module;
- no inferred equipment specs without evidence;
- supported-format scope from current decisions;
- current excluded sensitive metadata such as GPS/serial/observer where applicable.

Do not redesign the metadata architecture.

---

# RD-08 = T3 — TRACKING OWNERSHIP

RD-08 is already decided:

- the rig stores its default tracking state;
- the plan may override it;
- the effective tracking used for calculations comes from:
  plan override, if present;
  otherwise rig default;
- the saved snapshot records the effective tracking value and its source;
- changing a reusable rig later must not rewrite historical saved-plan meaning;
- Unknown remains possible;
- the example rig must not be silently upgraded from Unknown into a claimed real-world fact.

Stage 7 planning must identify the exact owning task for:

- the nullable per-plan override;
- Planner control;
- persistence/migration if required;
- effective-value calculation;
- snapshot recording of value + source;
- tests proving calculations use the effective value.

Do not re-open RD-08.

Before planning implementation, inspect the CURRENT data model and reuse existing snapshot/override patterns where possible.

Do not invent a new persistence concept if the current model can represent this cleanly.

---

# RESEARCH-FIRST DISCIPLINE

Stage 7 contains questions that require research before UI implementation.

For each research gate:

research
→ evidence
→ owner decision only if genuinely needed
→ frozen spec
→ implementation task
→ verification

Do not code a UI answer while the underlying workflow is unresolved.

Do not ask the owner to decide factual/scientific questions that can be researched.

Do not create new owner decisions for routine implementation details.

---

# 1. TARGETS / CATALOG / “WHAT CAN I IMAGE TONIGHT?”

Inspect the current target model, catalogue, search, aliases, picker and Tonight candidate flow.

Stage 7 should reduce manual target entry.

The target experience should support:

- catalogue selection;
- useful search;
- aliases/common names;
- known coordinates from the catalogue;
- no manual RA/Dec requirement for known catalogue objects;
- explicit manual/custom target path only where genuinely needed.

Do not remove the existing “What can I image tonight?” candidate flow.

Preserve the distinction:

- `Choose a target` = browse/select the catalogue;
- `What can I image tonight?` = candidates for current site/night.

Research/planning should determine:

- catalogue coverage gaps;
- alias strategy;
- custom target workflow;
- provenance/source requirements;
- whether existing data is sufficient or Stage 7 needs an approved catalogue source.

Do not introduce moving-object ephemerides or a planetarium.

---

# 2. SITE / LOCATION AUTOMATION

Inspect the current site model and current geolocation/reverse-geocoding behavior.

Plan the safest automation for:

- coordinates;
- location/place name;
- elevation;
- Bortle / sky-darkness context;
- SQM.

Do not assume all of these can be automated.

For each field classify:

- can be obtained reliably;
- can be proposed with provenance;
- should remain manual/optional;
- should remain Unknown.

## Elevation

Research whether AstroPlan can obtain elevation from a reliable, legally usable source appropriate for the product.

Do not invent elevation from coordinates.

Do not scrape an unapproved website.

If no acceptable source is found:
keep elevation nullable/Unknown.

## Bortle

Research whether automatic Bortle assignment is technically and legally supportable.

Do not treat a rough coordinate-to-Bortle guess as a scientific fact unless the approved source/data actually supports it.

Document:

- source;
- license;
- spatial resolution;
- update cadence;
- offline implications;
- expected uncertainty;
- whether the value is direct data or derived classification.

If no acceptable source exists:
keep Bortle manual/Unknown.

## SQM

Inspect the CURRENT domain and confirm:

- what SQM represents in AstroPlan;
- where it is stored;
- where it is displayed;
- whether any calculation uses it;
- whether a normal user needs it.

Do not remove SQM merely because it is currently not used in calculations.

Stage 7 planning should decide whether it is:

- primary input;
- optional advanced field;
- imported/automatic where reliable;
- or simply stored observational metadata.

---

# 3. EQUIPMENT / DEVICE INPUT

Inspect current:

- rig editor;
- equipment entities;
- metadata import flow;
- seeded example rig;
- camera/lens/telescope fields;
- current manufacturer/model/spec handling.

The product goal is to avoid making users manually retype specifications that can be obtained safely.

Research possible reliable sources for equipment specifications.

Important:

Do NOT equate “external source” with “scraping”.

Evaluate separately:

- official APIs;
- structured catalogues;
- manufacturer-published machine-readable sources;
- approved third-party datasets;
- metadata;
- user-confirmed proposals.

Do not scrape arbitrary manufacturer web pages unless explicitly approved and legally appropriate.

For each proposed equipment source evaluate:

- provenance;
- license;
- coverage;
- stable identifiers;
- update model;
- offline implications;
- ambiguity handling;
- camera-body vs sensor-module ambiguity;
- whether a source value is authoritative or only a proposal.

Preserve the rule:
external data may propose;
the user confirms before persisted equipment facts are changed.

Do not silently overwrite user-edited equipment.

---

# 4. LIGHT CAPTURE PARAMETERS

Research the meaning and ownership of Light parameters for the supported product segment.

At minimum address:

- exposure time;
- frame count;
- ISO;
- Gain;
- Binning;
- White Balance;
- Focus;
- interval between exposures;
- tracking mode where relevant.

For each parameter determine:

- which camera/workflow types use it;
- whether it is required;
- whether it is optional;
- whether it can be inherited/prefilled;
- whether it should be hidden when not applicable;
- whether it affects any current calculation;
- whether it belongs to the plan, rig, block, or another entity.

Do not force a single DSLR/CMOS workflow onto every camera type.

---

# 5. BINNING

Research Binning specifically.

Determine:

- when the user actually controls it;
- whether it is camera-dependent;
- whether current hardware/workflow categories make it meaningful;
- whether it affects calculations in AstroPlan;
- whether the current field is required, optional, inherited, or not applicable.

Do not keep a manual Binning field solely because it already exists.

Do not remove it without understanding supported camera workflows.

---

# 6. ISO VS GAIN

Research ISO/Gain semantics across supported camera types.

The UI should not ask users for both when only one is relevant.

Determine:

- DSLR / mirrorless behavior;
- dedicated astronomy camera behavior;
- any supported hybrid cases;
- whether current model allows mutual applicability cleanly;
- whether unknown camera type requires neutral handling.

The final Stage 7 spec should clearly define when:

- ISO is shown;
- Gain is shown;
- both are valid;
- neither is required.

Do not invent cross-camera equivalence between ISO and Gain.

---

# 7. WHITE BALANCE

Research whether White Balance is useful for AstroPlan's planning purpose.

Determine whether it:

- affects Capture Budget;
- affects workflow guidance only;
- belongs only to certain camera types;
- should be optional;
- should be omitted from primary planning if it has no planning consequence.

Do not add WB merely because camera apps expose it.

---

# 8. FOCUS

The earlier focus-slider idea is only a proposal, not a requirement.

Research what “Focus” would mean in AstroPlan:

- a planning parameter;
- a checklist/reminder;
- a capture-state note;
- a meaningless manual field for this product.

Do not implement a focus slider unless the research demonstrates a real, useful workflow.

If focus has no meaningful numeric planning role:
do not invent one.

---

# 9. INTERVAL BETWEEN EXPOSURES

Research interval/delay semantics.

Determine:

- when a user controls it;
- whether it belongs in per-Light-block settings;
- how it contributes to Acquisition time;
- whether it should default to zero/Unknown/current value;
- whether metadata can supply it;
- whether it differs from existing overhead concepts.

Do not double-count interval and per-frame overhead.

Any Stage 7 implementation must preserve Capture Budget semantics.

---

# 10. CALIBRATION WORKFLOW RESEARCH

This is a major Stage 7 research area.

Do not redesign Dark / Flat / Bias forms before the workflow matrix exists.

For each calibration type determine real-world parameter ownership.

The final research result must produce a parameter matrix using these categories:

- Inherited
- Prefilled but overridable
- Independent
- Not applicable

Apply the matrix separately to:

- Darks
- Flats
- Bias

and to relevant fields such as:

- exposure;
- count;
- ISO;
- Gain;
- Binning;
- temperature if currently supported;
- filter;
- interval where relevant;
- other currently existing fields.

Do not assume all calibration frames inherit all Light values.

Do not assume each calibration frame must re-enter every Light field.

Do not simplify astrophotography workflow by guesswork.

Use reliable astrophotography/camera workflow sources where external research is required.

---

# 11. DARKS

Research the real supported Dark workflow.

Determine which fields must match Lights, which merely commonly match, and which are independent.

Preserve scientific honesty.

Do not hard-code “Dark only needs a count” unless evidence supports that workflow for the supported cameras.

---

# 12. FLATS

Research Flat workflow separately.

Do not assume Flat exposure equals Light exposure.

Determine:

- which acquisition settings match Lights;
- which fields are independent;
- whether exposure is determined separately;
- filter dependence;
- camera-specific considerations relevant to the current app scope.

Do not introduce exposure-optimization science outside current scope.

---

# 13. BIAS

Research Bias separately.

Determine:

- which fields matter;
- which are inherited;
- which are independent;
- whether current supported camera workflows make Bias optional or not applicable in some cases.

Do not universalize one camera workflow.

---

# 14. CALIBRATION → CAPTURE BUDGET

After the calibration parameter matrix is frozen, define how Stage 7 changes interact with the existing Capture Budget.

Preserve current budget semantics:

Integration
= Light exposure integration

Acquisition
= Integration + per-frame / periodic overhead

Session Budget
= Acquisition + setup / in-window calibration according to current rules

Do not silently convert calibration time into integration.

Do not change the authoritative calculator in presentation code.

If revised calibration ownership changes duration inputs:
plan the required domain/test updates explicitly.

---

# 15. STORAGE INPUT ACQUISITION

Stage 6 already verified the storage presentation pipeline.

Stage 7 may improve how a file-size input is obtained.

Inspect current sources:

- imported metadata;
- prior samples;
- equipment evidence;
- user input;
- Unknown.

Do not introduce a theoretical RAW-size formula.

Do not fabricate expected file size from resolution/bit depth unless an approved future model explicitly exists.

If reliable file-size evidence is unavailable:
Storage remains Unknown.

---

# 16. CONTEXTUAL FORMS

Plan how forms should respond to known context.

Examples:

- camera type determines ISO vs Gain relevance;
- known catalogue target supplies coordinates;
- known site supplies coordinates;
- rig defaults can prefill plan values;
- calibration fields inherit/prefill according to the frozen matrix.

Do not use a global Basic / Advanced mode.

Use local progressive/contextual disclosure.

Material warnings remain visible.

---

# 17. PERFORMANCE BOUNDARY

The owner observed lag in editable forms, especially device information.

Stage 7 may touch those forms, but the root cause remains a Stage 10 performance investigation unless a concrete Stage 7 change directly introduces or exposes a defect.

Do not turn Stage 7 planning into a performance rewrite.

Avoid knowingly adding unnecessary rebuild/state complexity.

Record any new concrete performance regression, but preserve Stage 10 ownership.

---

# RESEARCH GATES RG-07 TO RG-11

Inspect the CURRENT register and map each RG-07…RG-11 to the Stage 7 questions it actually owns.

Do not assume the numbering from memory.

For each gate produce:

## Question
The exact unresolved product/technical question.

## Why it matters
Which implementation tasks depend on it.

## Evidence already available
From current code, docs, decisions, metadata work and audits.

## Evidence still missing
What must be researched.

## Options
Only materially distinct valid choices.

## Recommendation
Only if the evidence is strong enough.

## Owner decision required?
Yes only if this is a genuine product policy choice.

## What becomes frozen after resolution
Exact behavior/ownership rule.

Do NOT ask the owner to decide until the research is sufficient.

---

# STAGE 7 TASK SEQUENCING

After inspecting the current plan and research gates, produce the executable Stage 7 sequence.

The sequence should respect dependencies.

A likely conceptual dependency order is:

foundation / research
→ parameter ownership
→ data-source decisions
→ tracking override model
→ contextual forms
→ target/site/equipment automation
→ calibration forms
→ budget/storage integration
→ verification

BUT:

use the CURRENT task IDs and current plan structure.

Do not invent a new numbering system merely because this conceptual order is convenient.

Preserve existing valid tasks.

Modify task boundaries only if the current plan is genuinely contradictory or unexecutable.

---

# TASK SIZE

Do not create a microtask for every bullet above.

Use the current project task-size discipline.

Prefer:

research gate
→ bounded specification
→ one coherent implementation task

rather than dozens of tiny tasks.

At the same time, do not create one giant “Automate everything” task.

Split only at real dependency boundaries.

---

# ACCEPTANCE CRITERIA

For every Stage 7 implementation task, freeze acceptance criteria during planning.

Where applicable, criteria should cover:

- provenance;
- Unknown behavior;
- no silent persistence;
- applicability by camera/workflow;
- contextual visibility;
- inheritance/prefill behavior;
- user override;
- snapshot/history semantics;
- offline/degraded behavior;
- accessibility;
- existing Capture Budget semantics;
- regression coverage.

Do not wait until implementation is complete to invent the acceptance criteria.

---

# WHAT NOT TO DO IN THIS SESSION

This is planning only.

Do NOT:

- edit application code;
- change database schema;
- implement the tracking override;
- add external providers;
- add catalogue data;
- change forms;
- redesign calibration UI;
- fetch and persist equipment specs;
- implement elevation/Bortle automation;
- start Stage 8 work;
- run Stage 7 validation.

Documentation/research planning files may be updated according to current governance.

---

# REQUIRED PLANNING OUTPUT

At the end of this session produce:

## 1. Current Stage 7 state

- exact Stage 7 task IDs/names;
- which are provisional;
- which are gated;
- which current findings feed Stage 7.

## 2. Research gate map

For RG-07 to RG-11:
- exact question;
- owning Stage 7 task(s);
- current evidence;
- missing evidence;
- whether external research is required;
- whether an owner decision will eventually be required.

## 3. RD-08 implementation placement

State exactly which Stage 7 task will implement:

- per-plan tracking override;
- effective-value calculation;
- persistence;
- snapshot source/value;
- Planner control;
- tests.

Do not re-open T3.

## 4. Parameter ownership matrix plan

Define how the Stage 7 research will produce the matrix for:

- Lights;
- Darks;
- Flats;
- Bias.

Do not invent the final values without research.

## 5. Target / Site / Equipment automation plan

For each:
- what can already be automated;
- what requires research;
- what must remain Unknown/manual until evidence exists.

## 6. Task sequence

Give the exact Stage 7 execution order using current task IDs.

Show dependencies explicitly.

## 7. Owner decisions

List ONLY genuine owner decisions.

If research must happen before the owner can choose, say so and do not ask for the decision yet.

## 8. Plan/document changes

Update the appropriate current planning/research/register documents as required.

Keep `PROGRESS.md` concise.

## 9. Next Allowed Action

Set it to the first legitimate Stage 7 research/planning task that can actually run next.

If a research gate must run before implementation:
the Next Allowed Action must point to that research task, not implementation.

---

# VERIFICATION FOR THIS PLANNING TASK

Use documentation/planning verification only.

Check:

- task IDs resolve;
- research-gate IDs resolve;
- no Stage 6 ownership was accidentally moved;
- no Stage 8–11 work was pulled forward;
- RD-08 remains T3;
- no rejected/deferred feature was reintroduced;
- no data source was assumed approved without research;
- Unknown remains Unknown;
- no physical SNR or black-box score was introduced;
- Stage 7 sequence is executable.

Do not run the Flutter quality gate for planning-only changes unless current governance explicitly requires it.

---

# COMMIT / STOP

If current governance authorizes this Stage 7 planning task through commit:

- make one logical documentation/planning commit;
- update `PROGRESS.md`;
- report the exact Next Allowed Action;
- STOP.

Do not start the first Stage 7 implementation/research task automatically in this same session unless the current repository's approved process explicitly treats Stage 7 planning and the first research gate as one task.

Prefer a fresh session for substantial Stage 7 research.

Final report must include:

- commit hash;
- files changed;
- Stage 7 task sequence;
- research gates RG-07…RG-11;
- owner decisions currently needed vs not yet ready;
- exact Next Allowed Action;
- confirmation that no application code was changed.

Then STOP.
