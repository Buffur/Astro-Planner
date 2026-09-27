You are working on the existing AstroPlan post-roadmap refinement plan.

MODEL / ROLE

Use Claude Opus 5.5 for this planning correction.

This task is NOT application implementation.  
This task is NOT a new audit.  
This task is NOT a redesign session detached from the current repository.

The task is to carefully amend the CURRENT remaining post-roadmap plan based on:

- the current repository state;
- already approved owner decisions;
- Stage 4 Product Flow / IA decisions;
- the completed Stage 5 Design System foundation;
- Manual Dogfooding;
- current UI/UX findings;
- the product/scientific constraints already recorded in the repository;
- the planning corrections explicitly stated in this prompt.

The result must update the future stages without losing existing valid scope.

Do not implement application code in this task.

---

# 0. FIRST: reconstruct only the CURRENT planning state

Before changing any planning document:

Read the current canonical sources required for this task.

At minimum inspect:

- `CLAUDE.md`
- `docs/refinement/PROGRESS.md`
- `docs/refinement/POST_ROADMAP_PLAN.md`
- `docs/refinement/PRODUCT_DIRECTION.md`
- the current Stage 4 decisions / ADR-019 and directly related decision records
- `docs/DESIGN_SYSTEM.md`
- `docs/audit/08_MANUAL_DOGFOODING.md`
- the current dependency / research / decision register referenced by Stages 6–11
- any current source-of-truth document directly referenced by the Stage 6/7 tasks

Do NOT read `PROGRESS_HISTORY.md` by default.

Read it only if a current canonical document points to a historical fact that cannot otherwise be resolved.

Do not perform a repo-wide re-audit.

Do not reopen already closed work merely because a fresh context produces a different interpretation.

---

# 1. CURRENT STATE — MUST BE PRESERVED

Stage 5 — Design System Foundation — is CLOSED.

Treat the current repository record as authoritative for its completion.

Stage 5 already provides the visual/system foundation that later stages should consume.

Do NOT:

- reopen Stage 5;
- create S5.10;
- create a second design-system pass;
- redo Stage 5 validation;
- repeat its visual evidence work;
- create a parallel component system;
- move Stage 6 screen redesign back into Stage 5.

If Stage 6–9 reveal a concrete missing reusable primitive, that primitive may be added in the owning later stage only when a real screen requires it.

Do not modify historical Stage 5 records merely to make the new plan look cleaner.

---

# 2. CRITICAL PRESERVATION RULE — AMEND, DO NOT REPLACE

This prompt AMENDS the current Stages 6–11.

It does NOT replace them.

Before editing the plan, inventory every existing task, dependency and acceptance criterion in the affected future stages.

For each requested correction classify it internally as:

- ALREADY COVERED  
  → preserve the existing task;
- COVERED BUT UNDER-SPECIFIED  
  → clarify the existing task;
- MISSING  
  → add it to the most appropriate existing task, or create a bounded new task only if genuinely necessary;
- CONFLICTING  
  → identify the exact conflict before changing the plan;
- UNRELATED EXISTING SCOPE  
  → preserve unchanged.

Do not delete or silently narrow an existing future task merely because it is not mentioned in this prompt.

In particular, preserve unaffected existing scope around:

- target/catalog workflows;
- “What can I image tonight?”;
- site/location workflows;
- equipment and metadata;
- Library;
- Settings;
- Logbook;
- search/filter/share functionality already planned;
- planned-vs-actual handling;
- export/backup;
- Field Mode;
- accessibility;
- performance;
- application-size analysis;
- final validation.

The Manual Dogfooding file is a high-value source of:

- observed real-use problems;
- owner product intent;
- questions that require research.

However:

- an owner observation is evidence of the observed UX problem;
- an owner product direction should shape the plan;
- a proposed implementation idea in the audit is NOT automatically a final implementation requirement;
- an open question must not be silently converted into an answer.

Preserve the underlying problem even when the proposed solution remains open.

---

# 3. GLOBAL UI/UX DIRECTION FOR REMAINING STAGES

The main design principle for future UI work is:

> Primary answer visually first → supporting context second → technical depth on demand.

This does NOT mean removing AstroPlan's technical depth.

AstroPlan remains:

- scientifically honest;
- technically useful;
- transparent about assumptions;
- useful to experienced astrophotographers;
- explicit about Unknown values and provenance.

The correction is about INFORMATION HIERARCHY.

The interface should stop presenting:

- practical answers;
- supporting evidence;
- technical internals;
- long explanations

with approximately equal visual weight.

The user should understand the practical state first, and then be able to inspect the technical reasoning when needed.

---

# 4. INFORMATION-HIERARCHY CONTRACT

Use four conceptual information levels throughout future UI work.

## A. Primary / Decision information

Normally visible without expansion.

Examples:

- target;
- site;
- night;
- plan state;
- fit verdict;
- time needed;
- usable time;
- total integration;
- expected capture end;
- the main limiting reason;
- missing input that prevents a reliable answer;
- the next meaningful action.

## B. Supporting context

Visible in compact form.

Examples:

- Moon context;
- selected target window;
- concise weather state;
- estimated storage;
- selected rig identity;
- the few rig characteristics that materially affect this plan.

## C. Technical detail

Available through:

- disclosure;
- a clearly named detail action;
- an approved detail destination.

Examples:

- full budget ledger;
- setup/calibration/overhead breakdown;
- all cloud layers;
- complete hourly weather data;
- NPF derivation;
- full equipment specifications;
- detailed twilight terminology;
- interval-by-interval exclusion reasons;
- raw metadata.

## D. Integrity / Provenance information

May be one interaction away when it does not materially change the current interpretation.

Examples:

- formula explanation;
- assumptions;
- provider/model details;
- imported / reported / estimated provenance;
- scientific caveats.

However, NEVER hide a technical fact merely for visual cleanliness when it materially affects the current answer.

The following override progressive disclosure and remain visible when relevant:

- Unknown values that prevent or materially weaken a result;
- stale weather;
- unavailable weather;
- an active constraint;
- an assumption materially changing the result;
- a provenance conflict;
- a mismatch;
- a reason the result cannot be evaluated reliably;
- units necessary to interpret a value;
- a warning that changes what the user should understand about the plan.

---

# 5. PROGRESSIVE DISCLOSURE CONTRACT

Do NOT introduce a global Basic / Advanced mode as part of this correction.

Do NOT introduce a customizable dashboard.

Use local progressive disclosure over one underlying domain model.

Preferred depth:

Primary summary  
→ one clear disclosure or detail destination.

Avoid deep nested disclosure structures.

A collapsed section must still communicate useful information.

Prefer an informative entry such as conceptually:

`Budget details · 2 h 05 min needed`

over an ambiguous label such as:

`Advanced`

or a generic `More`.

Do not hide important information behind an unlabeled icon.

Tooltips are appropriate for short definitions.

Long explanations belong in:

- a disclosure;
- a detail screen;
- concise contextual help.

Essential information must never depend on discovering a tooltip.

---

# 6. VISUAL-COMMUNICATION CONTRACT

Do not replace text with graphics indiscriminately.

Use a visual component when it explains a relationship more clearly and more quickly than repeated prose.

Every proposed visualization must answer ONE explicit user question.

Examples:

- Night / Opportunity timeline  
  → “When can I image?”
- Capture Budget visualization  
  → “Where does the required time go?”
- Relative Stacking Gain visualization  
  → “How does relative √N gain change as frame count increases?”

Domain calculations remain authoritative.

UI graphics explain domain output.

Do NOT implement alternative scientific or planning logic inside widgets merely to drive a visual.

Every new chart/visualization must support:

- Unknown;
- empty states;
- errors where applicable;
- accessibility;
- a textual alternative where required.

Do not exchange textual overload for graphical overload.

---

# 7. VISUAL IDENTITY CONSTRAINT

Preserve AstroPlan's existing visual language and the completed Stage 5 foundation.

New work should remain recognizably AstroPlan.

Preserve the established direction:

- restrained typography;
- clear semantic hierarchy;
- quiet / restrained surfaces;
- thin borders where already appropriate;
- compact spacing;
- functional outlined icons where appropriate;
- dark-first readability;
- Field/red-mode compatibility;
- Stage 5 semantic tokens and states.

External references such as Stargazing Hub are references for:

- information hierarchy;
- temporal visualization;
- summary/detail patterns;
- interaction ideas.

They are NOT a visual template to copy.

Do not visually clone Stargazing Hub or any other product.

Do not introduce a different visual language merely because it is currently fashionable.

---

# 8. ICONS, COLOR AND MOTION

## Icons

Use icons primarily for:

- recognizable actions;
- familiar states;
- concise reinforcement of labelled information.

Do not replace domain concepts such as:

- calibration policy;
- NPF;
- pixel scale;
- relative stacking gain;
- provenance

with unexplained icon-only controls.

Technical concepts still need concise text.

## Color

Color is supplementary.

Do not rely on color alone for:

- Fits;
- Tight;
- Doesn't fit;
- warnings;
- stale state;
- selected state.

This is particularly important in Field/red mode.

Do not create a weather quality color score.

## Motion

Motion should explain state change, not decorate astronomy.

Appropriate examples:

- disclosure expansion/collapse;
- capture-block reordering;
- deletion + Undo;
- save-state feedback;
- brief emphasis on values recalculated after an edit;
- a clear transition when night/context changes.

Avoid:

- decorative moving stars;
- constantly animated gradients;
- decorative Moon animation;
- count-up animations that imply more certainty than the value has;
- motion that distracts during field use.

Reuse the completed Stage 5 motion/reduced-motion foundation rather than create a second motion system.

---

# STAGE 6 — CORE PLANNER REDESIGN

Stage 6 is the primary owner of the new information hierarchy.

Do NOT implement Stage 6 in this task.

Amend the CURRENT Stage 6 plan only.

Before editing it, read every current Stage 6 task and preserve its existing IDs where practical.

Do not invent replacement task numbering before inspecting the current plan.

The following requirements must be integrated into the current Stage 6 structure.

---

## Stage 6.A — Answer-first Planner

The Stage 4-approved product direction remains the baseline.

Do not reopen Stage 4 merely to redesign the page.

The Planner should prioritize the user's decision approximately as:

Plan identity / state  
→ practical fit answer  
→ time / opportunity context  
→ capture plan  
→ supporting conditions  
→ supporting rig context  
→ technical details on demand.

The exact final layout remains a Stage 6 design/implementation responsibility.

However, Stage 6 must NOT preserve the old order merely because the current implementation follows domain categories.

The user should not need to scroll through:

- complete weather detail;
- static equipment specifications;
- repeated astronomy explanations

before discovering whether the plan fits.

The Planner should make it immediately understandable:

1. what target/night/site/rig context is being planned;
2. whether the plan fits;
3. how much time is needed;
4. how much usable time is available;
5. how much real light integration is planned;
6. what the main limitation is;
7. what action is useful next.

Preserve the Stage 4 plan-state semantics.

Do not silently redesign saved/unsaved lifecycle semantics inside Stage 6.

---

## Stage 6.B — Practical verdict presentation

Do not make a technical label such as `Fit Tonight` carry the whole meaning.

The primary UI should communicate the relationship directly.

Conceptually:

`Fits · 2 h 05 min needed of 4 h 20 min usable`

or an equivalent concise presentation.

If the plan does not fit:

- show that clearly;
- show the key reason;
- preserve access to detailed reasoning;
- show a useful corrective action when the domain already supports one.

Do not introduce:

- a percentage score;
- a black-box Astro Score;
- a “good/bad plan” numerical rating.

The current transparent FitAnalyzer / planning result remains authoritative.

---

## Stage 6.C — Existing altitude/window chart vs new Night Timeline

Do NOT automatically add another large chart.

First inspect the current target-altitude / window visualization and determine what information it already communicates well.

Prefer:

- evolving it;
- composing with it;
- reusing its data;
- giving it a clearer summary/detail role

when that avoids duplication.

Do not create two competing visualizations that communicate the same night/target/window relationship.

A separate compact Night Timeline is justified only if it serves a distinct summary purpose.

The intended conceptual relationship is:

night state  
→ selected target visibility  
→ Imaging Opportunity  
→ planned capture interval.

Where relevant and already supported by reliable data, it may also communicate Moon context and current time.

The exact implementation must be determined from the current screen structure.

Do not invent unsupported astronomical inputs merely to fill the graphic.

---

## Stage 6.D — Night Timeline design direction

Stage 6 should plan a reusable Night / Opportunity temporal visualization.

Its purpose is:

> Show when the selected target can actually be imaged and how the current plan occupies that opportunity.

Potential layers, only where supported by current domain data, include:

- day/twilight/dark context;
- target visibility;
- applicable target threshold;
- Moon-related limitation/context;
- Imaging Opportunity;
- planned capture interval;
- current time when useful.

Do not force all layers into every version.

Use information density appropriate to context.

Possible roles:

- compact orientation on Tonight;
- planning-focused representation in Planner;
- richer astronomical representation in the approved Night & Moon detail destination.

Before committing to three separate renderings, determine whether shared primitives/data plus different levels of detail are sufficient.

Do not duplicate the same full chart across screens.

Do not add:

- planetarium functionality;
- sky map;
- 3D;
- Solar System dashboard;
- unrelated planet visibility;
- multi-target scheduling;
- Stargazing score.

This visualization exists to support AstroPlan's planning workflow.

---

## Stage 6.E — Capture Plan becomes a primary planning surface

The Manual Dogfooding review identified Capture Plan as one of the areas that requires significant redesign.

Do not treat this as a cosmetic card cleanup.

The current problem is the relationship between:

- inputs;
- resulting integration;
- real required time;
- usable opportunity;
- fit;
- technical details.

Stage 6 should make those relationships visually understandable.

Capture-block presentation should prioritize useful block identity and quantities.

A conceptual row may resemble:

`Ha · 60 s × 100 · 1 h 40 min`

but do not hard-code that exact format before reviewing:

- current frame types;
- current filter representation;
- accessibility;
- available width;
- camera-specific parameters.

Preserve edit/reorder functionality and existing valid domain semantics.

Do not make every technical parameter permanently visible in each row.

---

## Stage 6.F — Capture Plan Outputs redesign

The current Outputs area must be redesigned around the practical answer.

Primary information should make the following immediately understandable:

- Total Integration;
- Time Needed;
- Usable Time;
- Fits / Tight / Doesn't Fit;
- projected capture end where applicable;
- primary limiting reason.

Do not show every internal Capture Budget component with equal visual importance.

The complete calculation remains available.

Secondary/detail information may include:

- per-frame overhead;
- sequence intervals;
- periodic overhead;
- dithering where represented by the existing model;
- refocus overhead where represented by the existing model;
- in-window calibration;
- setup;
- other current budget components.

Do not delete these concepts from the domain model merely to simplify the screen.

Preserve the distinction:

Integration ≠ Acquisition ≠ Session Budget.

The UI may simplify presentation.

The calculation semantics must not be simplified incorrectly.

---

## Stage 6.G — Setup and calibration presentation

Manual Dogfooding questioned whether Setup / Calibration Time is useful as permanently visible output.

Treat this as a PRESENTATION question, not immediate evidence that the calculation should be deleted.

If setup/calibration affects the budget model:

- preserve it in the calculation;
- show it in Budget details;
- surface it in the primary view only when it materially explains the result.

Do not remove a real budget input merely because it is visually noisy.

Do not imply that outside-window calibration consumes the Imaging Opportunity when it does not.

---

## Stage 6.H — Capture Budget visualization

Evaluate a compact visual representation of time composition after the answer-first hierarchy is established.

A segmented duration representation is one possible direction, not a mandatory visual implementation.

Its purpose would be:

> Explain why required time differs from pure light integration.

If implemented, the visualization must preserve planning truth.

It must not imply:

- that split windows are continuous;
- that gaps are usable;
- that setup outside the usable window consumes Imaging Opportunity;
- that a plan fits merely because total duration is numerically less than total usable minutes.

The existing scheduling / FitAnalyzer logic remains authoritative.

Numeric values remain available.

If a graphic cannot represent the semantics honestly, prefer the clear numeric summary.

---

## Stage 6.I — Inverse frame-count / “What fits?” presentation

Preserve and expose the existing inverse planning capability if it is present in the current domain/API.

Do not reimplement the mathematics in UI code.

Stage 6 should make practical results discoverable, for example conceptually:

- `Up to N × 60 s fit tonight`
- `+N frames can still fit`
- `N frames do not fit`

Exact wording and placement must follow the current vocabulary system and available domain outputs.

Do NOT fabricate frame counts from simple division if the authoritative fit model has:

- split windows;
- ordering constraints;
- overhead;
- calibration policy;
- other budget rules.

Use the authoritative inverse/fit result.

If the current API cannot provide a required value honestly, record that limitation instead of inventing a UI calculation.

---

## Stage 6.J — Relative Stacking Gain

This requirement comes directly from owner Manual Dogfooding and should not disappear into generic “future visual polish”.

Stage 6 should own a compact visual presentation of the existing:

> Relative stacking gain (√N vs one compatible frame)

The visualization should answer:

> How does relative √N gain change as the compatible frame count increases?

This is NOT:

- physical SNR;
- Estimated SNR;
- a camera noise model;
- a prediction of final image quality;
- exposure optimization.

Do not rename it SNR.

Do not imply more scientific precision than √N provides.

The current value should remain numerically available.

A compact curve or another appropriate visualization may show:

- the current frame count;
- current relative √N gain;
- the shape of diminishing marginal improvement;
- possibly a small number of useful comparison points.

The exact graph design is a Stage 6 implementation/design decision.

Do not force a particular chart type before reviewing:

- available screen width;
- accessibility;
- Field Mode;
- compatible-frame grouping semantics.

Do not combine incompatible frame groups into one misleading physical measurement.

The long formula/explanation should not permanently occupy the primary Planner view.

Provide concise accessible help stating that this is relative statistical stacking gain, not physical SNR.

Physical / Estimated SNR remains outside current scope unless explicitly approved as a separate future feature.

---

## Stage 6.K — Estimated Storage: VERIFY BEFORE “FIXING”

Manual Dogfooding reports that Estimated Storage appears not to be calculated.

Do NOT convert that observation directly into:

“the storage formula is broken”.

Stage 6 must first verify the actual current pipeline.

Inspect:

equipment / metadata evidence  
→ per-file-size input  
→ CaptureBudgetCalculator  
→ per-block storage  
→ total estimated storage  
→ Planner presentation.

Classify the actual result.

### Case A — input exists and the calculator produces an incorrect result

This is a calculation defect.

Own the correction where the current architecture requires it and add/adjust the appropriate tests.

### Case B — calculator is correct but UI drops, hides or misrepresents the result

This is a presentation/wiring defect.

Stage 6 owns the Planner correction.

### Case C — file-size input is legitimately unknown

The correct value remains Unknown.

Improve the UX so the user understands why the estimate is unavailable.

Conceptually:

`Storage · UnknownFile size is not known`

with an appropriate path to supply/obtain the missing information if such a path exists.

### Case D — the current data-entry/equipment workflow rarely supplies reliable file size

Do not invent the value.

Create/retain a dependency for Stage 7 to investigate evidence-backed acquisition of the missing input.

Do not derive a theoretical RAW payload from:

resolution × bit depth

and present it as actual/expected file size unless a separately approved and scientifically honest model exists.

Preserve the existing deferred status of theoretical storage payload if it remains deferred in the current plan.

If current metadata/sample evidence provides actual file-size observations, preserve provenance and do not silently generalize one sample into a universal camera specification without an approved rule.

---

## Stage 6.L — Weather summary

The Planner should not permanently show every available weather variable with equal visual weight.

The primary Planner weather presentation should become a concise factual summary.

It should preserve, where relevant:

- forecast age;
- stale state;
- unavailable state;
- Unknown;
- the variables most relevant to the current planning context.

Detailed weather remains accessible through the already approved Weather detail destination.

Do not remove useful experienced-user data.

Move it to appropriate detail hierarchy.

Do not introduce:

- a composite weather score;
- Stargazing percentage;
- green/red “good night” judgement;
- a black-box recommendation.

Weather presentation remains factual.

Do not silently violate existing no-score decisions.

---

## Stage 6.M — Rig summary

The Planner should not permanently devote large vertical space to static equipment specifications that the user selected earlier.

Show:

- rig identity;
- only the few plan-relevant outputs required in the current context;
- active warnings when equipment capability affects the plan.

Possible relevant values include existing outputs such as:

- FOV;
- pixel scale;
- tracking-related exposure guidance.

Do not assume all of these must always be shown.

Determine the concise summary from current product logic.

Full equipment specifications and provenance remain accessible through detail/disclosure.

Do not remove them from Library/equipment records.

---

## Stage 6.N — Technical explanations

Reduce permanent explanatory prose where the practical value can stand on its own.

Candidates include:

- repeated √N explanation;
- repeated formula caveats;
- repeated provider/model descriptions;
- repeated technical astronomy terminology;
- assumptions that do not currently affect interpretation.

But scientific honesty must remain.

If a caveat materially changes interpretation, it remains visible.

Otherwise use:

- `ⓘ` / labelled help;
- disclosure;
- detail screen;
- contextual explanation.

Do not hide uncertainty.

Do not remove provenance simply to reduce text.

---

## Stage 6.O — Relationship between edit and result

Where practical, Stage 6 should make cause/effect easier to understand.

Examples of acceptable patterns:

- editing a block briefly emphasizes recalculated integration;
- changing frame count updates the relevant budget segment;
- selecting a window highlights the corresponding opportunity;
- a fit change becomes visually apparent.

This is a UX direction, not permission to add decorative animation.

Use existing Stage 5 motion principles.

Respect reduced-motion behavior.

Do not create additional calculation state in the widget solely for animation.

---

## Stage 6.P — Track Live boundary

Do not redesign or strengthen dedicated Track Live / Execution as the main continuation of Planner.

The owner product direction is that the target primary flow should be:

Planner  
→ Save Plan  
→ user performs imaging independently  
→ Logbook  
→ Completed / Partly / Not done.

Stage 6 must therefore NOT:

- add a new primary `Start` CTA that makes live tracking mandatory;
- organize Planner around a future live tracker;
- redesign the dedicated tracker as part of the core Planner work.

However:

Stage 6 must also NOT destructively delete existing tracker domain/data/history behavior.

Safe retirement and dependency handling belong to Stage 8.

Stage 6 should only avoid creating new dependence on that UI.

---

## Stage 6.Q — Stage 6 planning acceptance direction

When amending Stage 6, ensure its acceptance criteria eventually verify practical comprehension, not only widget existence.

Without creating a new validation loop, the Stage 6 plan should be capable of demonstrating that:

- plan identity/state is understandable;
- the fit answer is visible without traversing technical detail;
- total integration is easy to find;
- time needed and usable time are distinguishable;
- timeline/opportunity can be understood without reading duplicated paragraphs;
- technical detail remains discoverable;
- Unknown/stale/blocking states are not hidden;
- Storage behaves honestly;
- Relative Stacking Gain remains scientifically labelled;
- the main Planner remains usable in Dark/Field modes and large text according to existing project rules.

Use existing verification policy.

Do not invent a separate Stage 6 meta-validation framework.

---

# STAGE 7 — DATA ENTRY & AUTOMATION

Stage 7 should continue the same product principle:

> Do not ask the user to manually type technical information AstroPlan already knows or can reliably obtain.

But automation must remain evidence-based.

Do not replace manual input with guessed data.

Do not silently persist inferred technical values without the already established confirmation/provenance rules.

Before editing Stage 7:

- inspect every current Stage 7 task;
- preserve unaffected current scope;
- reuse existing research gates / decisions where they already exist;
- do not invent duplicate research IDs or owner decisions.

Stage 7 is broader than only Capture Plan forms.

It should cover the existing manual-entry problems across:

- sites;
- targets;
- equipment;
- capture-block parameters;
- calibration workflows;

where those problems are already within the current post-roadmap plan.

---

## Stage 7.A — Common automation rule

For every field currently entered by hand, ask in this order:

1. Does the application already know the value from the selected plan/rig/context?
2. Can it be inherited safely?
3. Can it be obtained from existing verified metadata?
4. Can it be obtained from a reliable existing catalog/provider whose use is already approved?
5. Can AstroPlan propose a value while preserving provenance and requiring confirmation?
6. If none applies, does the user genuinely need to enter it?
7. If the value is still unknown, can the application function honestly with Unknown?

Do not automate for the sake of appearing automated.

Do not add network providers merely because a field is inconvenient.

External data requires:

- source reliability;
- licensing/terms;
- provenance;
- offline/degradation behavior;
- privacy consideration where applicable.

---

## Stage 7.B — Preserve established metadata principles

Do not weaken the metadata architecture already established in previous completed stages.

Preserve the core flow conceptually:

Metadata Evidence  
→ Candidate / Match / Enrich  
→ User Confirmation  
→ Persist.

Do not silently write imported metadata into equipment records.

Unknown remains Unknown.

Do not infer timezone when metadata does not provide it.

Do not invent missing equipment specifications.

Do not treat Make + Model as universally sufficient identity when existing evidence says otherwise.

Do not erase field-level provenance where it already exists.

Stage 7 should use that foundation to reduce data entry, not replace it with a new import architecture.

---

## Stage 7.C — Target input / “What Can I Image Tonight?”

Manual Dogfooding identified the practical problem with requiring users to manually provide technical target data such as:

- names;
- coordinates;
- RA/Dec;
- other catalog-like information.

Preserve the usefulness of the target catalog.

Stage 7 should review the current target-entry workflow and reduce unnecessary technical entry through the existing catalog/data strategy.

Potential mechanisms to evaluate within existing scope:

- searchable catalog;
- autocomplete;
- aliases;
- selecting a known object rather than entering coordinates manually;
- automatically filling trusted catalog coordinates after selection;
- keeping manual/custom target entry only where it serves a real use case.

Do NOT assume arbitrary expansion to a huge catalog is approved.

Do NOT add moving-object support.

Do NOT silently trust unsourced object data.

Preserve source/provenance requirements.

The main UX goal is:

A normal user selecting a known target should not first have to search another application for RA/Dec just to use AstroPlan.

---

## Stage 7.D — Site / geolocation entry

Manual Dogfooding questioned why the user must manually provide site information that may be derivable from location/context.

Stage 7 should preserve/investigate the existing site-automation scope.

Review separately:

- coordinates;
- site name;
- elevation;
- Bortle / sky-darkness context;
- SQM where applicable;
- notes.

Do not assume one mechanism applies to all fields.

### Coordinates

Where the user explicitly uses device location and permission is available, reuse the existing approved location path.

Do not silently obtain location without user intent/permission.

### Site name

If reverse geocoding is already part of the approved project architecture, preserve its privacy/opt-in behavior.

Do not turn reverse geocoding into a mandatory network dependency.

### Elevation

Manual Dogfooding raised the question of automatic elevation.

Do not claim elevation can be automatically provided until the current plan identifies an approved reliable source/mechanism.

If the current domain now allows Unknown, preserve Unknown where reliable elevation is unavailable.

Do not invent `0 m`.

If elevation is not used by current calculations, do not give it false prominence.

### Bortle / sky darkness

Manual Dogfooding asks whether Bortle can be obtained automatically from location.

Treat this as a research/data-source question, not an assumed feature.

Do not:

- scrape websites;
- invent Bortle from coordinates;
- silently add an unlicensed dataset/API.

Preserve existing light-pollution provider/licensing decisions and deferred boundaries.

If reliable automatic Bortle remains unavailable under current approved constraints, keep the UI honest and manual/unknown as appropriate.

### SQM

Do not expose SQM simply because Bortle exists.

Review its actual purpose and whether current data has a reliable source.

Unknown must remain Unknown.

---

## Stage 7.E — Equipment entry

The owner wants less manual equipment entry.

Stage 7 should build on the completed metadata-assisted equipment work rather than create a parallel equipment database without evidence.

Review:

- which equipment values metadata can reliably provide;
- which values can be matched to an existing rig;
- which values require confirmation;
- which values are still manual;
- which fields can become optional/Unknown.

Do not silently copy specs from a “similar” device.

Do not invent sensor/pixel data.

Do not remove provenance.

If an external manufacturer/catalog source is proposed for additional specifications:

research it first for:

- coverage;
- correctness;
- licensing/terms;
- stable identifiers;
- offline behavior;
- conflict handling.

No new provider is approved merely by being convenient.

---

# Stage 7.F — Capture-block parameter model

Manual Dogfooding raised unresolved questions around:

- Binning;
- ISO vs Gain;
- White Balance;
- Focus;
- interval between exposures;
- repeated technical inputs in Dark / Flat / Bias.

Do NOT begin by redesigning widgets.

First determine the actual parameter semantics for the workflows AstroPlan supports.

Research the real supported astrophotography workflows before deciding:

- which fields exist;
- which are user-editable;
- which inherit;
- which are optional;
- which are not applicable;
- which affect calculations.

Do not treat all supported camera types as identical.

---

## Stage 7.G — Light frames

Review each current Light-block input.

Classify each parameter based on evidence as one of:

- required;
- optional;
- automatically known;
- context-dependent;
- not applicable.

Explicitly investigate the following Manual Dogfooding questions.

### Binning

Determine whether manual Binning selection is meaningful for each supported camera/workflow.

Do not expose it generically if the user cannot reasonably act on it.

Do not assume metadata can always determine it.

Do not assume all cameras expose binning in the same way.

### ISO vs Gain

Do not present both as interchangeable generic technical fields when only one is meaningful for a camera/workflow.

Determine how the selected camera/equipment type should affect:

- terminology;
- visibility;
- input.

Preserve the scientific rule that ISO does not increase photon collection.

### White Balance

The owner expects WB may be relevant for some intended workflows.

Do not add it unconditionally.

Research where White Balance is meaningful for the supported capture-planning workflow and where it is not.

Do not confuse:

- capture metadata;
- RAW processing settings;
- physical exposure.

### Focus

The owner proposed a slider as a possible idea.

This is NOT yet evidence that Focus should be represented by a slider.

First determine:

- what “Focus” would mean in AstroPlan;
- whether a meaningful planning value exists;
- whether it belongs in a capture block;
- whether it can be represented honestly without hardware control.

Only then choose a control.

Do not implement a slider merely because one was suggested.

### Interval between photos

Determine whether an interval belongs in the capture block for the supported workflow.

If it affects real acquisition duration, define its relationship to the existing Capture Budget model before finalizing UI.

Do not create a second interval/overhead concept that conflicts with the existing per-frame overhead semantics.

If the current model already represents the same physical time under another name, reconcile terminology rather than double-counting it.

---

# Stage 7.H — Calibration-frame workflow research

The current Dark / Flat / Bias forms must not be redesigned by simply copying the Light form and hiding random fields.

Research each calibration workflow separately.

The objective is:

> Ask the user only for values they genuinely need to control.

Do not assume every calibration type or every camera workflow uses the same settings.

The result of the research should be a parameter/workflow matrix before implementation.

---

## Stage 7.I — Cross-block parameter ownership model

For each relevant parameter, classify its ownership as one of four semantic categories.

### 1. Inherited

The value comes from the associated Light / rig / camera context and should not be redundantly typed.

If the workflow requires it to match, make that relationship explicit.

### 2. Prefilled / overridable

AstroPlan has a contextual value that is usually appropriate, but the workflow permits the user to change it.

The UI must make clear that it is a proposed/prefilled value rather than a measured truth.

### 3. Independent

The value genuinely belongs to that calibration block and must be specified separately.

### 4. Not applicable

The parameter has no useful meaning for this frame/workflow and should not be shown.

Do not force every parameter into one of these categories globally.

Classification may depend on supported camera/workflow type.

Preserve provenance where it matters.

Do not silently copy a value in a way that hides its source.

---

## Stage 7.J — Dark frames

Investigate which Dark-frame settings must correspond to the associated Light frames for the supported workflows.

Where a value is required to match and AstroPlan already knows it:

prefer inheritance over repeated user entry.

Determine separately which Dark values are:

- inherited and non-editable;
- inherited but overridable;
- independently configurable;
- not applicable.

The owner observation is that the current Dark form asks for too many parameters.

Do not jump from that observation to:

“Dark only needs frame count”

without workflow evidence.

The target UX may become conceptually concise, for example:

`Dark · matches Lights · 20 frames`

but only if the research demonstrates that this accurately represents the selected workflow.

If a mismatch would compromise calibration validity, the mismatch must remain visible.

---

## Stage 7.K — Flat frames

Research Flats as their own workflow.

Do not simply inherit the entire Light exposure block.

Determine the distinction between:

- optical/imaging-train properties that need consistency;
- camera configuration that may need consistency;
- exposure/illumination properties specific to Flats;
- parameters that AstroPlan does not need to model.

Expose only values the user can meaningfully control.

Do not invent a target ADU workflow or exposure recommendation unless such a model is separately researched and approved.

If current scope does not support such guidance, keep the plan within current scope.

---

## Stage 7.L — Bias frames

Research Bias separately.

Determine:

- whether Bias is meaningful for each supported camera/workflow;
- what camera settings need consistency;
- which values can be inherited;
- which, if any, require independent input.

Do not assume every user/session requires Bias.

Do not remove Bias globally without evidence or an owner decision if current supported workflows still use it.

---

## Stage 7.M — Calibration help / instructions

Manual Dogfooding asked for concise help around calibration-frame creation without turning the form into a large tutorial.

Plan for:

- short contextual explanation;
- more detail on demand where useful;
- ability to avoid repeatedly showing long instructional text.

Do not fill the UI with permanent multi-paragraph tutorials.

Do not let optional help obscure the actual parameters.

If a tip is hidden/disabled, required warnings and validation remain visible.

---

## Stage 7.N — Calibration workflow and Capture Budget

Any inheritance or form simplification must remain consistent with the domain calculation.

Do not create UI-only calibration behavior that disagrees with:

- block parameters;
- calibration policy;
- Capture Budget;
- fit.

If calibration consumes time inside the Imaging Opportunity, the authoritative calculator must receive the actual resulting parameters.

If calibration occurs outside the window according to the current policy, the UI must not imply otherwise.

Do not duplicate budget arithmetic inside the form.

---

## Stage 7.O — Storage input dependency from Stage 6

If Stage 6 finds that Estimated Storage is Unknown because reliable per-file size is usually missing:

Stage 7 should investigate whether that input can be reduced through existing evidence.

Potential evidence may include:

- actual metadata/imported sample information already supported;
- user-confirmed equipment data;
- other approved sources already in the product.

Do not invent a nominal file size from a camera model without provenance.

Do not turn a single imported frame into a universal expected file-size fact without an approved model.

If no reliable automatic source exists, preserve manual/Unknown behavior.

The goal is honest reduction of friction, not fake precision.

---

## Stage 7.P — Contextual forms

Apply the global progressive-disclosure principle to forms.

Do not render every possible technical field for every camera/frame type.

Show the parameters that are:

- required;
- currently relevant;
- actionable.

Keep optional/rare parameters discoverable.

Do not hide a required missing value.

Do not hide validation errors.

Do not use placeholder text as the only label.

Preserve units.

Preserve provenance/conflict indicators where relevant.

---

## Stage 7.Q — Form performance boundary

Manual Dogfooding reported noticeable lag when tapping/editing fields, especially device information.

Do not assume the cause.

Stage 7 owns the form/content simplification where appropriate.

Stage 10 owns the dedicated performance investigation and measurement unless the current plan already assigns a confirmed localized defect earlier.

Do not “solve” the observed lag by speculative rewrites during Stage 7.

If Stage 7 changes significantly reduce widget/form complexity, preserve the observation and still measure the result later.

---

## Stage 7.R — Do not narrow existing automation scope

When amending Stage 7, explicitly compare these corrections with the current Stage 7 tasks.

Do not accidentally remove existing valid work around:

- site automation;
- target input;
- equipment import;
- metadata confirmation;
- calibration research;
- contextual forms;
- any current approved automation task not restated here.

This prompt adds constraints and missing detail.

It is not permission to rewrite Stage 7 from scratch.

---

## Stage 7.S — Required research/decision discipline

Where Stage 7 requires factual workflow knowledge that the repository does not currently establish:

research first.

Examples include:

- real Dark workflow per supported camera class;
- real Flat workflow;
- real Bias applicability;
- Binning semantics;
- ISO vs Gain;
- WB relevance;
- Focus semantics;
- external data/provider feasibility.

Use reliable primary/technical sources where available.

Separate:

FACT  
from  
OWNER PREFERENCE  
from  
IMPLEMENTATION OPTION.

Do not convert a research finding into an owner decision unless a genuine product choice exists.

Do not ask the owner questions that can be answered by:

- current code;
- current docs;
- current approved decisions;
- reliable external evidence.

Only surface an OWNER DECISION when implementation cannot proceed correctly without choosing between materially different product behaviors.

---

# END OF CURRENT PART

For this planning-correction task:

Do not implement Stage 6 or Stage 7 code.

Modify only the planning/source-of-truth documents required by the current repository workflow.

Do not commit yet until the entire Stages 6–11 correction has been reconciled as one coherent planning change, unless the repository governance explicitly requires separate documentation commits.

Preserve all current completed-stage evidence.

Do not start a new validation loop.

# CROSS-STAGE CONSISTENCY NOTE BEFORE STAGE 8

Before amending Stage 8 and Stage 9, preserve all constraints established in the previous part of this planning correction.

In particular:

- Stage 5 remains CLOSED.
- Stage 6 owns the Core Planner redesign and answer-first planning hierarchy.
- Stage 7 owns data-entry reduction, evidence-based automation and capture/calibration workflow research.
- Stage 8 owns the saved-plan → actual-result → Logbook lifecycle and safe treatment of legacy execution/tracker functionality.
- Stage 9 owns secondary UX, Library/Settings refinement, secondary-screen adoption, branding and product polish unless the current plan already assigns a specific item elsewhere.
- Stage 10 remains the owner of dedicated performance/application-size investigation.
- Stage 11 remains the owner of bounded final validation.

Do not move work between stages merely to make this prompt appear cleaner.

Inspect the CURRENT plan first and preserve existing ownership when it is already coherent.

---

# IMPORTANT TERMINOLOGY DISTINCTION — `Tracked` IS NOT `Track Live`

Do not conflate two separate concepts:

1. `Tracked` / tracking-related plan or equipment behavior;
2. the dedicated Track Live / Execution workflow.

Manual Dogfooding separately questioned the ownership of `Tracked`, stating that a user should not have to repeatedly change a global device setting for a plan-specific/session-specific choice.

That is NOT the same question as whether the dedicated live execution screen should exist.

Before changing any `Tracked` persistence or ownership semantics:

- inspect the current Stage 4 decision/dependency record, including RD-08 or its current equivalent;
- preserve any already-approved plan/session override semantics;
- do not silently redefine an equipment property as a session property unless the current decision record authorizes it;
- if the exact persistence/override semantics remain formally unresolved, preserve that as a bounded dependency for the correct stage rather than inventing an answer.

Do not put `Tracked` back into global Settings merely for convenience.

Do not use the word `Tracked` as shorthand for Track Live.

---

# STAGE 8 — SAVED PLANS / ACTUAL RESULTS / LOGBOOK / EXECUTION RETIREMENT

Stage 8 should implement the product lifecycle already established by the approved product-flow work.

This stage is not primarily a redesign of a live execution dashboard.

Its central purpose is:

> Preserve the plan as intent, allow the user to report what actually happened, and make Logbook a useful historical record.

Before editing Stage 8:

- inspect every CURRENT Stage 8 task;
- inspect the approved Stage 4 lifecycle decision;
- inspect the current persistence/session/event model;
- inspect current Logbook/export dependencies;
- preserve current migration/backward-compatibility requirements;
- preserve unaffected existing Stage 8 tasks.

Do not invent new session semantics without reconciling the current approved lifecycle.

---

## Stage 8.A — Canonical product flow

The target primary flow is:

Planner  
→ Save Plan  
→ user performs the imaging session independently  
→ Logbook / saved-plan review  
→ user reports the result.

The dedicated live execution screen is NOT part of the target primary 1.0 workflow.

The plan must not require the user to repeatedly tap controls such as:

- `+1`;
- `1`;
- `Reject`;
- `Pause`;

during ordinary manual imaging in order for AstroPlan to remain useful.

Manual/semi-automated astrophotographers may use:

- camera intervalometers;
- mount software;
- camera controls;
- other external capture systems;

without AstroPlan controlling or tracking each exposure live.

AstroPlan remains a planner and record of intent/result.

Do not add hardware control.

Do not add native camera control.

---

## Stage 8.B — Saved Plan remains intent

Preserve the approved distinction between:

- the saved/planned state;
- later actual results.

Do not mutate the historical saved-plan intent merely because the user reports what happened.

The Stage 8 implementation must follow the current approved Stage 4 lifecycle exactly.

Before editing the task, verify the current source-of-truth decision for:

- saved-plan snapshot semantics;
- working-copy semantics;
- past-night handling;
- actual-result attachment/reconciliation.

Do not reconstruct those semantics from memory if the repository already records them.

At minimum preserve the core product invariant:

> Planned values do not become Actual values without explicit user confirmation.

Do not infer success merely because the planned night has passed.

Do not infer actual frames merely from planned frames.

Do not mark a plan Completed automatically based on time.

---

## Stage 8.C — Result states

Use the CURRENT approved result-state vocabulary from the Stage 4/product-flow decision.

The intended high-level concept is that the user can report whether the planned session was:

- completed;
- partially completed;
- not done / not completed;

if those are the current approved states.

Do not invent additional status categories unless the current source-of-truth plan already contains them.

Do not silently collapse an approved `Partly` state into a binary Completed / Not completed flow.

Conversely, do not create `Partly` solely from this prompt if the current approved Stage 4 decision uses different exact semantics.

Resolve the exact canonical labels from the current repository before editing UI acceptance criteria.

---

## Stage 8.D — Actuals entry should be lightweight

The post-session result workflow should minimize unnecessary work.

The user should not be forced to reproduce the entire saved Capture Plan manually.

Where the saved plan already provides known planned values, present them as context and ask only for meaningful actual differences/results.

Potential actual information already supported/planned may include:

- actual frame counts;
- rejected/usable frame counts where still in scope;
- achieved integration;
- notes;
- optional conditions;
- processing notes where already owned by Logbook;
- result status.

Do not add all of these merely because they are listed here.

First preserve the current Stage 8/Logbook model and existing approved scope.

The principle is:

> Reconcile planned vs actual with the fewest meaningful confirmations.

---

## Stage 8.E — Do not fabricate actuals

Actual data must be:

- explicitly reported by the user;
- imported/proposed from approved evidence and then confirmed by the user;
- or remain Unknown / not reported.

Do not derive Actual from Planned automatically.

Do not turn elapsed clock time into confirmed captured frames.

Do not treat a started historical execution event as proof that a planned exposure was successfully captured unless the current historical model explicitly records that event.

If later metadata-assisted actuals exist in the CURRENT plan, preserve their current owning stage/dependency.

Do not move metadata-assisted actuals into Stage 8 solely because they would be convenient.

If metadata assistance is already scheduled for a later stage/version, Stage 8 should remain compatible with it.

---

## Stage 8.F — Planned vs Actual presentation

Logbook detail should make the relationship between intent and result understandable without showing two giant duplicated forms.

Use the Stage 5 visual system and the global information-hierarchy contract.

Primary historical information should emphasize:

- what was planned;
- what actually happened;
- whether the session was completed/partial/not done;
- planned vs achieved integration;
- important deviations;
- notes/results.

Technical per-block comparison can remain accessible where useful.

Do not hide differences that materially affect historical interpretation.

Do not alter the saved plan in order to make Planned and Actual appear identical.

---

## Stage 8.G — Dedicated Track Live / Execution retirement

Owner product direction is now explicit:

> The dedicated Track Live / Execution screen is not part of the target primary product flow.

Stage 8 should NOT reopen the product question:

“Should Track Live remain as an optional primary feature?”

Instead, Stage 8 must perform a bounded implementation/dependency audit before removing or retiring UI.

The purpose of that audit is to determine which existing tracker-related implementation is still required for:

- persisted historical execution data;
- current database migrations;
- saved session/event compatibility;
- reconciliation logic;
- planned-vs-actual reconstruction where legitimate;
- exports;
- backups;
- tests;
- old records;
- any current repository invariant.

Distinguish:

### A. UI/workflow that exists only for dedicated live tracking

This can be retired/replaced if no longer needed.

### B. Domain/data logic that supports trustworthy historical records

Preserve or repurpose it where still needed.

### C. Legacy persisted data

Continue to read/migrate/render it safely according to the current compatibility policy.

### D. Tests written only around the obsolete UI

Replace or retire them deliberately when the UI is removed.

Do not delete tests merely to make the new implementation pass.

### E. Tests that verify still-valid domain/history behavior

Preserve them.

The intended transformation is:

audit dependencies  
→ preserve useful data/domain behavior  
→ implement approved result workflow  
→ remove unreachable/unnecessary dedicated live-tracker UI safely.

Do not perform:

delete tracker screen  
→ discover later that historical records no longer render.

---

## Stage 8.H — Existing execution data and legacy records

If historical records contain execution events from the existing tracker:

do not silently discard them.

Determine how current Logbook/history should represent them after the live UI is retired.

Possible outcomes must be driven by the CURRENT schema and approved migration policy, not guessed in this prompt.

Requirements:

- old records remain readable when current compatibility policy requires it;
- historical actual data must not be rewritten as planned data;
- no fabricated conversion;
- no silent loss of rejected/confirmed counts if they are currently persisted and meaningful.

If some execution-only field becomes obsolete:

document its compatibility treatment.

Do not introduce a migration only for cosmetic cleanup unless necessary.

---

## Stage 8.I — Logbook becomes the historical center

Logbook should be the primary place for:

- saved planned sessions;
- historical session results;
- planned-vs-actual review;
- session notes/results;
- search/filter/review;
- share/export entry points where currently approved.

Do not recreate a separate `Progress` destination if the same historical information naturally belongs to Logbook.

However, before removing any current Progress surface:

inspect its actual data and responsibilities.

If it contains information not represented by Logbook, explicitly migrate/rehome that responsibility instead of deleting it blindly.

---

## Stage 8.J — Optional session names

Manual Dogfooding explicitly requests optional custom session names.

Integrate this into the current Stage 8/Logbook model if it is not already covered.

Requirements:

- Name is optional.
- A session without a custom name must remain fully usable.
- Do not make naming a required step during Save Plan.
- Preserve useful automatic identity through night/target/date when no custom name exists.
- Do not replace stable internal identity with a mutable display name.

The exact fallback display format should use the current vocabulary/time formatting rather than a newly invented convention.

---

## Stage 8.K — Logbook search

Manual Dogfooding explicitly requests search.

Stage 8 should define search based on fields that actually exist and are useful.

Potential searchable fields may include current persisted/display data such as:

- optional session name;
- target;
- site;
- notes;

but do not promise all of these until the current data/query model is inspected.

Do not add a full-text-search dependency unless the actual dataset/requirements justify it.

Prefer the simplest correct search implementation for the expected local dataset.

Search must work together with current filters rather than creating separate incompatible result states.

---

## Stage 8.L — Logbook filters

Preserve existing useful filter semantics already present/planned, including current status/target/site/date filtering where applicable.

Manual Dogfooding reports that filters consume too much permanent space.

Stage 8 should redesign their PRESENTATION, not remove useful filtering.

Preferred direction:

- compact filter entry point;
- dedicated filter panel/sheet/menu where appropriate;
- visible indication when filters are active;
- clear/reset action;
- current filter state survives reasonable navigation according to existing app-state conventions.

Do not require all filter controls to occupy permanent horizontal/vertical space.

Do not hide the fact that filtering is active.

The exact component must use Stage 5 primitives where possible.

---

## Stage 8.M — Logbook detail hierarchy

Opening a Logbook entry should no longer route the user primarily into the dedicated tracker experience.

The detail page should focus on historical meaning.

Suggested information hierarchy, adapted to current data:

1. session identity / optional name;
2. night / target / site / rig snapshot;
3. result status;
4. planned vs actual summary;
5. per-block detail;
6. notes / processing notes if currently in scope;
7. conditions/context snapshot where currently persisted;
8. share/export and other secondary actions.

Do not assume every record has every field.

Legacy/older records must degrade honestly.

Do not fill missing historical fields with current equipment/site values.

History comes from persisted snapshots where the current model provides them.

---

## Stage 8.N — Logbook share

Manual Dogfooding reports that the current shared textual result appears visually flat and insufficiently structured.

Stage 8 should review the current share output.

The goal is not necessarily to generate an image/card.

First improve the INFORMATION STRUCTURE of the shared output.

A useful shared summary may distinguish:

- session identity;
- date/night;
- target;
- planned vs actual;
- integration;
- notable result/notes;

but only include fields supported by current data.

Preserve privacy considerations around:

- precise coordinates;
- private notes;
- other potentially sensitive local information.

Do not automatically share every persisted field.

Do not add social-network integrations.

The exact share format should remain portable and compatible with the product's offline/local-first direction.

---

## Stage 8.O — Export remains distinct from Share

Do not blur:

- Share summary;
- Export file/data.

If the current Stage 4/product plan says Export is a file, preserve that distinction.

Export is for portable user-owned data.

Share is for a human-readable presentation.

Do not introduce cloud sync.

Do not make social login a requirement.

Preserve current versioned export/backward-compatibility work.

---

## Stage 8.P — Ambiguous `Logo Download` action

Manual Dogfooding reports an action labelled or perceived as `Logo Download`, where the user cannot tell what is being downloaded.

Do not infer from the audit what the implementation actually does.

Stage 8 or Stage 9 — whichever CURRENT plan owns that surface — must first inspect:

- the actual visible label;
- the invoked action;
- the produced content/file;
- why the action exists.

Then classify it:

- useful but poorly named/presented;
- useful but in the wrong location;
- duplicate of Share/Export;
- obsolete.

Do not add a download-history feature merely because it was mentioned as a possibility in Manual Dogfooding.

`Download history` is an idea, not an approved requirement.

Only retain/add it if a concrete product need is established.

---

## Stage 8.Q — Logbook and target progress

Historical accumulation/progress should be based on Actual/logged results, not on planned exposure merely because it existed.

If the current plan already includes accumulated integration per target, preserve its existing semantics.

Do not create a new Project entity solely for progress.

Do not invent goal-tracking dashboards.

If Library currently shows a `Progress` section tied to the old Start/Execution workflow:

Stage 8/9 must determine whether that presentation should move to:

- Logbook;
- target detail;
- another already-approved historical view.

Do not maintain duplicate progress concepts.

---

## Stage 8.R — Assisted actuals dependency

Inspect the CURRENT future plan for metadata-assisted actuals.

If such functionality already exists as a later task/version:

preserve that ownership and ensure the Stage 8 actual-entry model can accept later evidence-assisted proposals.

The invariant must remain:

metadata/import may PROPOSE actual values  
→ user confirms  
→ actual record is persisted.

Never:

metadata/import  
→ silent historical rewrite.

Do not prematurely pull a later metadata task into Stage 8 unless the current plan explicitly requires it.

---

## Stage 8.S — Abandon / restore / destructive session actions

Use the completed Stage 5 destructive-action policy.

Do not invent a second delete/confirmation pattern.

Persistent/compound destructive actions such as:

- deleting a Logbook/session record;
- abandoning a meaningful saved plan;
- restoring/replacing significant persisted state;

should follow the current approved confirmation policy.

Cheap local reversible deletion should use the approved Undo pattern where that policy applies.

Preserve cancellation behavior.

Do not use a visually dramatic swipe animation that leaves the row in an ambiguous state.

Stage 9 will apply the same pattern across secondary surfaces.

---

## Stage 8.T — Stage 8 acceptance direction

When amending Stage 8 acceptance criteria, ensure the final implementation can demonstrate that:

- a saved plan remains a trustworthy record of intent;
- actual values require explicit confirmation/evidence;
- a user can report a result without using live per-frame tracking;
- Completed/partial/not-done semantics follow the approved lifecycle;
- planned and actual values remain distinguishable;
- legacy execution data remains readable according to compatibility policy;
- dedicated Track Live is no longer required in the primary flow;
- Logbook can search/filter useful records;
- optional names work without becoming required;
- share and export remain distinct;
- historical progress is based on actuals where appropriate;
- existing valid records survive the transition.

Do not create an open-ended UX audit as Stage 8 acceptance.

Use bounded evidence against the approved lifecycle.

---

# STAGE 9 — SECONDARY UX & PRODUCT POLISH

Stage 9 should apply the completed Stage 5 visual foundation and the Stage 6–8 product decisions to secondary surfaces.

It is NOT permission to redesign every screen from scratch.

It is also NOT a cosmetic-only stage.

The purpose is to remove remaining secondary-screen contradictions, duplicated workflows, unclear actions and unfinished interaction patterns after the core Planner/Logbook flow is stable.

Before editing Stage 9:

- inventory every current Stage 9 task;
- preserve unaffected scope;
- identify which Manual Dogfooding observations are already resolved by Stages 4–8;
- do not duplicate those tasks;
- use the current Design System rather than creating another one.

---

## Stage 9.A — Library has one clear role: manage reusable data

Preserve the approved product distinction:

> Library manages reusable entities.  
> Planner selects them for a plan.

Library should not silently change the current Planner selection merely because the user opens or edits an item.

Inspect the current Library behavior for:

- Rigs;
- Targets;
- Sites;
- Progress;
- any other current Library category.

Remove or clarify actions that duplicate Planner selection semantics.

Do not create hidden cross-screen side effects.

---

## Stage 9.B — Rig / Equipment in Library

Library should allow the user to:

- inspect;
- add;
- edit;
- delete/manage;

their reusable rigs/equipment according to the current data model.

Do not make a normal tap silently replace the rig of the current plan unless the current approved product decision explicitly says so.

If the product supports a default/preferred rig separately from current-plan selection:

use only the existing approved semantics.

Do not invent a new default-rig concept in Stage 9.

Planner remains responsible for selecting the rig for a specific plan.

---

## Stage 9.C — Targets in Library

Library should manage targets.

Do not make target management indistinguishable from plan selection.

If the approved Stage 4 flow contains an explicit action such as:

`Plan this target`

preserve that explicit intent.

Editing/viewing a target must not silently replace the Planner target.

Target detail may expose planning context/actions where already approved, but:

manage  
≠  
select into current plan.

Preserve target catalog/search/provenance work from Stage 7.

---

## Stage 9.D — Sites / Geo in Library

Manual Dogfooding considers geolocation/site management a reasonable Library responsibility.

Preserve site management here unless the current plan places it elsewhere.

Do not duplicate the entire Planner site-selection workflow inside Library.

Library owns reusable site records.

Planner owns selecting the site for the plan.

If current-position or GPS actions are available:

preserve permission/privacy behavior established earlier.

Do not silently change a saved historical site's snapshot when the reusable site record is edited later.

---

## Stage 9.E — Progress in Library

Manual Dogfooding questions the current `Progress` section because it is tied to the old Start workflow.

Do not preserve that UI solely because it already exists.

First inspect what `Progress` currently represents.

If it is:

- historical achieved integration;
- target history;
- logged session results;

prefer the Stage 8 Logbook/target-history model.

If it contains unique useful information:

rehome it deliberately.

Do not create two progress systems:

- one derived from legacy execution;
- another derived from Logbook actuals.

Do not delete useful historical data.

This is an information-architecture correction, not a data-destruction task.

---

## Stage 9.F — Settings requires its own bounded product review

Manual Dogfooding explicitly requires a comprehensive Settings review.

Do not treat Settings merely as another screen needing spacing/typography cleanup.

Review every CURRENT visible setting across four questions:

### 1. Practicality

Does this preference correspond to a real user need?

### 2. Clarity

Can the user understand:

- what it changes;
- where it applies;
- whether it affects calculations or only presentation?

### 3. Placement

Is it truly application-wide?

Or does it belong closer to:

- Planner;
- a specific plan;
- a rig;
- a site;
- a detail screen;
- another local context?

### 4. Real-world relevance

For astrophotography-specific preferences, verify the intended use against:

- the existing product model;
- reliable astrophotography sources where factual workflow knowledge is required.

Do not use anecdotal internet opinion as sole evidence for technical behavior.

Do not ask the owner to decide factual questions that reliable sources can answer.

---

## Stage 9.G — Settings classification

For every current Settings item, classify it before redesign as one of:

### A. Global application preference

Applies broadly across the app.

### B. Planning preference

Affects planning calculations or default plan behavior.

### C. Plan/session-specific choice

Should be selectable for one plan/session rather than changed globally.

### D. Entity-specific property

Belongs to Rig / Target / Site rather than Settings.

### E. Presentation/accessibility preference

Changes UI presentation rather than scientific calculation.

### F. Information/legal/about item

Not a user preference at all.

Do not force all existing settings to remain in Settings because that is where they currently live.

Do not move a setting merely to reduce the number of rows.

Placement should follow ownership and scope.

---

## Stage 9.H — Settings and technical consequences

If a setting changes calculations:

make that consequence understandable.

Do not let a user change a scientifically meaningful planning threshold through an unexplained generic toggle.

Preserve:

- units;
- current valid ranges;
- provenance/meaning where relevant;
- existing preferences-vs-laws principle.

Thresholds are user preferences, not universal laws.

Do not introduce hard-coded “recommended” values without evidence.

Do not introduce a black-box “optimal astrophotography settings” section.

---

## Stage 9.I — `Tracked` placement

As stated in the cross-stage note:

do not confuse plan-specific `Tracked` behavior with Track Live.

Manual Dogfooding specifically rejects forcing a user to repeatedly open global device settings for a session-specific choice.

Inspect the current RD-08/current decision before changing persistence.

If current approved semantics place a tracking override in Planner/session:

Stage 9 should ensure global Settings/Library no longer present contradictory ownership.

If semantics remain unresolved:

do not invent them in Stage 9.

Keep a bounded dependency on the existing owner decision/research record.

---

## Stage 9.J — Settings visual hierarchy

After ownership is correct, redesign Settings using the Stage 5 information hierarchy.

Avoid:

- large continuous text walls;
- equally weighted rows;
- long permanent explanations.

Prefer:

- clear sections;
- concise setting title;
- current value/state;
- short consequence/help where needed;
- deeper explanation on demand.

Do not hide important scientific consequences behind a tooltip.

Do not turn Settings into a dashboard.

---

## Stage 9.K — Night & Moon detail screen

Use the approved Stage 5 detail-screen template and the temporal system established in Stage 6.

Night & Moon may show richer detail than Planner.

Potential detail is limited to current supported data, such as:

- twilight/dark periods;
- Moon context;
- target/night relationship;
- relevant temporal intervals.

Do not invent new astronomy features merely because this is a detail screen.

Do not duplicate the entire Planner.

The detail screen should explain the context behind the Planner's concise summary.

Use consistent SessionNight/timezone semantics.

Do not compute night boundaries independently in presentation code.

---

## Stage 9.L — Weather detail screen

Weather detail may expose more data than the Planner summary.

Preserve factual weather values and current provider semantics.

Keep visible where relevant:

- forecast timestamp/age;
- stale state;
- unavailable/Unknown;
- units;
- provider attribution where required.

Do not introduce a quality score.

Do not present provider horizontal visibility as astronomical transparency if the current domain explicitly distinguishes them.

Use temporal visualization only where it genuinely improves hourly understanding.

Do not duplicate every weather value in both chart and prose unless accessibility requires an alternative representation.

---

## Stage 9.M — Sky Darkness / Light Pollution secondary UX

Preserve existing data-source and licensing constraints.

Manual Dogfooding questions the current Sky Darkness presentation and expressed interest in a light-pollution map reference/action.

Do not interpret that as automatic approval to:

- scrape a website;
- embed an unapproved third-party map;
- add an unlicensed light-pollution dataset;
- infer Bortle without evidence.

Inspect the CURRENT plan and current external-link/provider decisions.

If an external map link is already legally/technically approved:

make its purpose clear.

If it is not approved:

retain it as a research/decision dependency rather than silently implementing it.

The primary UX goal is to make:

- Bortle;
- SQM if available;
- source/provenance;
- Unknown;

understandable without a visually flat wall of data.

---

## Stage 9.N — Deletion interaction across secondary screens

Manual Dogfooding reports the current deletion interaction as visually unfinished:

- row slides/flings awkwardly;
- red block appears;
- confirmation remains awkwardly visible.

Do not invent a new pattern.

Apply the completed Stage 5 destructive-action policy consistently.

Preserve the approved distinction:

### Cheap/local/immediately reversible action

Use immediate action + Undo where Stage 5 policy says so.

### Persistent/compound destructive entity

Use confirmation.

For deletable entities such as:

- rigs/devices;
- targets;
- sites;
- Logbook/session entries;

use the approved persistent deletion pattern.

Where swipe is retained as a shortcut:

- cancelled swipe returns the row cleanly;
- the UI must not remain half-dismissed;
- confirmation must not appear visually detached from the object;
- deletion feedback should be clear.

Do not make animation longer or more dramatic merely to look modern.

---

## Stage 9.O — General success/action feedback

Manual Dogfooding notes insufficient feedback after user actions.

Audit secondary-screen actions for cases where the user cannot tell whether the action succeeded.

Use the existing Stage 5 feedback patterns.

Examples may include:

- saved;
- copied;
- exported;
- deleted + Undo;
- setting changed when consequence is not immediately visible;
- item added.

Do not display a snackbar for every tap.

Feedback should confirm meaningful state transitions.

Do not create redundant persistent banners when transient confirmation is sufficient.

---

## Stage 9.P — Forms: visual adoption only, performance remains Stage 10

Secondary forms should adopt the Stage 5 components and the contextual form rules established in Stage 7.

Do not reintroduce flat legacy forms after Stage 7 establishes contextual data entry.

However:

Manual Dogfooding also observed input lag.

Do not claim Stage 9 has fixed performance merely because the forms look better.

If a concrete localized regression is found while adopting shared components, fix it under current verification rules.

The dedicated investigation of:

- keyboard delay;
- rebuild cost;
- field-focus latency;
- screen-state overhead;

remains Stage 10 unless current plan explicitly assigns a confirmed defect earlier.

---

## Stage 9.Q — Logo redesign

Manual Dogfooding explicitly states:

- the idea of the vector logo is liked;
- the current implementation is not;
- alternatives should be analyzed before updating it.

Do NOT immediately generate and commit a new logo during the planning correction.

Stage 9 should include a bounded branding task:

1. inspect the current logo and its use at:
   - app icon;
   - adaptive icon if applicable;
   - splash/loading screen;
   - About/branding surfaces;
2. identify what in the current execution is not working visually;
3. propose a small number of coherent alternatives that preserve the existing conceptual direction unless a better justified direction emerges;
4. present the alternatives for owner selection;
5. only after owner selection, implement the chosen identity consistently.

Do not let an AI agent silently choose the final brand mark on behalf of the owner.

Do not replace the logo simply because another style is trendy.

---

## Stage 9.R — Splash / loading screen

Manual Dogfooding allows a subtle splash/loading animation.

Treat animation as an optional branding enhancement after the final logo direction is selected.

Requirements:

- subtle;
- short;
- consistent with AstroPlan visual identity;
- not distracting;
- does not fake application progress;
- respects platform constraints;
- does not create unnecessary startup delay.

Do not create an elaborate astronomical animation.

Do not block startup waiting for decorative animation to finish.

Respect reduced-motion/system behavior where technically applicable.

---

## Stage 9.S — Authorship

Owner intent is explicit:

authorship should be more prominent.

Stage 9 should inspect current:

- About;
- Sources;
- attribution;
- project links;
- author presentation.

Add/preserve the owner-specified links:

- GitHub: `https://github.com/Buffur`
- Reddit: `https://www.reddit.com/user/Buffur/`

Reddit is specifically important to the owner.

Do not substitute a different GitHub identity merely because older application identifiers or historical documents contain another username.

However:

before replacing repository/project URLs used for functional source links, inspect the CURRENT repository/remote/publication setup.

Distinguish:

- author profile link;
- source repository link;
- project website link.

They do not have to be the same URL.

Do not break functional repository links merely to make authorship more prominent.

---

## Stage 9.T — License review

Manual Dogfooding expresses explicit owner intent that:

- the application/project should be free;
- monetization should not be permitted;
- third-party modifications/alterations should not be permitted without explicit author permission.

Do NOT claim that the current GPL license satisfies these constraints.

Do NOT select a replacement license from memory.

This requires a dedicated legal/license research step.

Stage 9 planning should require:

1. inspect the current license and distribution model;
2. compare its actual permissions/obligations against the owner's stated intent;
3. clearly identify any incompatibility;
4. research legally appropriate licensing approaches using authoritative licensing/legal sources;
5. identify consequences for:
   - source availability;
   - redistribution;
   - modification;
   - commercial use;
   - dependency-license compatibility;
   - app-store distribution where relevant;
6. present viable alternatives/trade-offs to the owner;
7. require an explicit owner decision before changing the project's license.

Do not invent a custom license casually.

Do not write a new legal license text yourself as if it were validated legal advice.

Do not silently create conflicts with third-party dependency licenses.

The owner intent is a requirement to investigate and resolve licensing.

It is not evidence that a specific license is valid.

---

## Stage 9.U — Sources / attribution review

Manual Dogfooding also asks for the existing Sources section to be reviewed.

Stage 9 should verify:

- source links are current;
- attribution is accurate;
- provider/library attribution requirements are met;
- authorship is distinct from third-party attribution;
- source/provenance links are understandable to users.

Do not remove legally required attribution for visual cleanliness.

Do not expose technical provenance everywhere in the main UI if the requirement can be met in an appropriate detail/About/Sources location.

This review must remain consistent with existing compliance work.

---

## Stage 9.V — Share / export presentation polish

After Stage 8 establishes correct semantics, Stage 9 may apply visual polish to:

- human-readable shared summaries;
- export success feedback;
- file naming/presentation;
- action labels.

Do not change export schema semantics as part of visual polish unless a verified defect requires it.

Do not create image-based social cards as an automatic requirement.

If a richer share card is considered, treat it as an implementation option only after the structured text/file workflow is correct.

---

## Stage 9.W — Home / Tonight secondary consistency

Do not reopen the core Stage 4/6 information architecture.

After Stage 6 has established the final Planner hierarchy, ensure secondary entry points such as Tonight/Home are consistent with it.

Do not reintroduce:

- separate Draft-as-product concept;
- duplicate plan state;
- links that simply dump the user at the top of Planner when a specific approved detail destination exists.

Preserve current approved Stage 4 behavior.

If Night/Moon/Weather have dedicated detail destinations after Stage 6/9:

their entry points should lead to the intended context rather than an unrelated Planner location.

Do not create an `Analytics` tab unless the current approved product decision explicitly changed to require one.

The previous idea of an Analytics tab was an audit option, not automatically an approved requirement.

---

## Stage 9.X — Secondary-screen information hierarchy

Apply the same hierarchy contract consistently:

Primary answer/action  
→ compact supporting context  
→ technical/deeper detail.

Examples:

### Library item

identity + key distinguishing values  
→ manage/edit detail.

### Settings

setting + current value/consequence  
→ explanation.

### Night & Moon

relevant night summary  
→ detailed astronomy.

### Weather

factual current-night summary  
→ detailed hourly/model information.

### Logbook

result + planned-vs-actual  
→ per-block/detail/history.

Do not make every secondary screen look identical.

Consistency means shared hierarchy/patterns, not identical card layouts.

---

## Stage 9.Y — Typography and content density adoption

Manual Dogfooding reports that:

- primary and secondary information often have similar visual weight;
- text is too small in some areas;
- screens feel flat/noisy.

Do not create a new typography system.

Use Stage 5 semantic roles.

Stage 9 should remove remaining ad-hoc screen-level typography where the completed design system already provides the appropriate role.

Do not blindly increase all font sizes.

The objective is semantic contrast and readability.

Preserve compactness appropriate for a field planning application.

Large-text behavior is finally validated in Stage 11.

---

## Stage 9.Z — No feature creep during polish

Stage 9 must NOT become a miscellaneous backlog dump.

Do not add:

- customizable dashboard;
- social network;
- accounts;
- cloud sync;
- community feed;
- planetarium;
- 3D sky;
- AR;
- camera control;
- hardware control;
- black-box scores;
- Project entity;
- new statistics dashboard;

unless a separate approved change supersedes the current rejected/deferred scope.

Every Stage 9 addition must trace to:

- current plan;
- approved owner decision;
- Manual Dogfooding problem;
- a concrete usability inconsistency created by Stages 6–8.

---

# STAGE 8–9 CROSS-CHECK BEFORE EDITING DOCUMENTS

Before writing the planning changes, produce an internal reconciliation table:

Observation / approved decision  
→ already covered task  
→ owning stage  
→ required clarification/addition  
→ dependency  
→ whether owner decision is actually needed.

At minimum reconcile:

- dedicated Track Live retirement;
- legacy execution data;
- saved-plan vs actual separation;
- result-entry flow;
- session names;
- Logbook search;
- Logbook filters;
- Logbook share/export distinction;
- ambiguous `Logo Download`;
- target progress;
- Library manage-vs-select;
- Settings ownership;
- `Tracked` ownership;
- deletion interaction;
- Night & Moon detail;
- Weather detail;
- Sky Darkness/light-pollution presentation;
- logo/splash;
- authorship links;
- licensing;
- sources/attribution.

Do not create this as a permanent new document unless the current governance requires it.

Use it to prevent omissions and duplicated tasks.

---

# STAGE 8–9 DOCUMENT EDITING RULE

When amending the current roadmap:

prefer:

- clarifying an existing Stage 8/9 task;
- extending its acceptance criteria;
- adding an explicit dependency;

over creating many new task IDs.

Create a new bounded task only when the work has its own substantial:

- research;
- decision;
- implementation;
- verification lifecycle.

Likely examples that may justify distinct tasks, depending on the CURRENT plan:

- safe Track Live retirement/migration audit;
- Settings ownership review;
- logo/branding decision;
- license research/owner decision.

Do NOT create those task IDs until the current plan is inspected.

Do not renumber completed stages.

Do not rewrite historical audit files.

Do not rewrite Stage 4/5 history to pretend these decisions were always present.

Record superseding decisions explicitly where the current governance requires it.

---

# STAGE 8–9 VERIFICATION BOUNDARY

This planning correction itself remains documentation/planning work.

Do not run application-wide implementation gates merely for editing the plan unless current canonical verification policy requires them.

Verify:

- no contradiction with approved Stage 4 lifecycle;
- Stage 5 remains closed;
- Stage 6/7 ownership from the previous prompt remains intact;
- Stage 8 clearly owns actuals/Logbook/lifecycle;
- Stage 9 clearly owns secondary UX/polish;
- Track Live retirement does not imply destructive data deletion;
- `Tracked` is not confused with Track Live;
- Library no longer has silent Planner-selection semantics;
- Settings review does not invent astrophotography facts;
- license intent is treated as a research/decision problem, not solved by an invented license;
- branding requires owner selection;
- no rejected/deferred feature is silently reintroduced.

Do not run another broad independent UX audit.

Do not create a validation-after-validation loop.

# CROSS-STAGE CONSISTENCY NOTE BEFORE STAGE 10

Before amending Stage 10 and Stage 11, preserve every constraint established in the previous parts.

Current ownership remains:

- Stage 5 — CLOSED Design System foundation.
- Stage 6 — Core Planner redesign, answer-first hierarchy, timeline/opportunity presentation, Capture Plan outputs, storage verification, Relative Stacking Gain presentation.
- Stage 7 — evidence-based automation, contextual data entry, equipment/site/target input reduction, Light/Dark/Flat/Bias workflow research.
- Stage 8 — saved-plan → actual-result → Logbook lifecycle and safe retirement of dedicated Track Live UI.
- Stage 9 — secondary UX, Library, Settings, detail screens, deletion/feedback consistency, branding, authorship/licensing/polish.
- Stage 10 — measured technical optimization.
- Stage 11 — bounded final validation and beta readiness.

Do not move unresolved functional design from Stages 6–9 into Stage 10.

Stage 10 is not where product behavior should be redesigned merely to improve benchmark numbers.

Stage 11 is not where new product design should be invented.

---

# STAGE 10 — PERFORMANCE & APPLICATION SIZE

Stage 10 must be evidence-driven.

Manual Dogfooding observed:

- noticeable lag when entering/editing fields, especially device information;
- an application footprint reported at approximately 277 MB.

These are HUMAN OBSERVATIONS.

Do NOT convert either observation directly into an assumed root cause.

In particular:

- do not assume the 277 MB value is release APK size;
- do not assume it is AAB size;
- do not assume it is installed release footprint;
- do not assume it is caused by Flutter itself;
- do not assume field lag is caused by one specific ViewModel, animation, database operation or widget tree.

First determine what is actually being measured.

Before editing Stage 10:

- inspect every current Stage 10 task;
- preserve current performance budgets/checks already in the plan;
- inspect current build/release configuration;
- inspect current dependencies/assets only as needed;
- inspect current profiling/test infrastructure;
- preserve unaffected current scope.

Do not invent task IDs before reading the current plan.

---

## Stage 10.A — Establish reproducible performance baselines first

Stage 10 must begin with measurement, not optimization.

Define reproducible scenarios for the actual product flows changed by Stages 6–9.

At minimum consider current relevant flows such as:

- opening Planner;
- editing a capture block;
- changing frame count/exposure where calculations update;
- focusing/editing text fields;
- opening/editing equipment;
- switching plan context where timeline/opportunity updates;
- expanding/collapsing technical detail;
- opening Night & Moon / Weather detail;
- opening/searching/filtering Logbook;
- saving relevant forms.

Do not benchmark every screen merely for completeness.

Prioritize:

1. user-observed lag;
2. high-frequency interactions;
3. screens substantially changed in Stages 6–9;
4. expensive calculations/visualizations where measurement indicates a risk.

Record:

- device/build configuration;
- reproducible steps;
- observed metric;
- acceptable/current target where the repository already defines one.

Do not create arbitrary numeric performance budgets if the current plan does not define them.

If a numeric acceptance threshold is needed but unsupported by current evidence, classify it as needing an explicit engineering decision rather than inventing a number.

---

## Stage 10.B — Form input lag investigation

Manual Dogfooding reports noticeable lag when tapping/editing form fields, especially device information.

Treat this as a concrete investigation target.

Measure and isolate, where applicable:

- time to field focus;
- keyboard-open interaction;
- input responsiveness;
- rebuild scope/frequency;
- synchronous work triggered by focus or text change;
- validation/calculation work;
- state propagation;
- expensive layout/rendering;
- database or persistence work accidentally happening on the interaction path.

These are investigation categories, NOT assumed causes.

Do not rewrite state management merely because lag exists.

Do not replace Provider or introduce a new architecture unless a separately approved architectural decision explicitly requires it.

Preserve the current no-rewrite architecture constraints.

Optimize the verified bottleneck.

After any correction:

- repeat the same scenario;
- compare against baseline;
- verify behavior/data semantics are unchanged.

---

## Stage 10.C — Planner recalculation performance

Stage 6 introduces or expands reactive relationships between:

- capture block edits;
- Capture Budget;
- Fit;
- frame-count guidance;
- storage;
- timeline/opportunity;
- Relative Stacking Gain.

Measure whether edits produce unnecessary repeated work.

Inspect existing ViewModel/domain memoization before adding new caching.

Do not cache domain-derived values inside widgets.

Do not create duplicated calculation paths to make the UI feel faster.

If an expensive value is already memoized correctly, preserve that architecture.

Any new cache must have correct invalidation for every input affecting its output.

Do not trade correctness for responsiveness.

---

## Stage 10.D — Night Timeline / chart rendering

After Stage 6 implements temporal visualization, profile its real rendering behavior.

Measure:

- initial render;
- context/night changes;
- target changes;
- plan edits that affect overlays;
- selection/highlight interaction where implemented;
- redraw/repaint scope;
- large-text/layout effects where relevant.

Do not assume a chart is expensive because it is graphical.

Do not optimize before profiling.

Prefer reducing unnecessary recomputation/repaint over reducing scientifically meaningful sampling/data resolution without evidence.

Do not modify astronomy/time-grid semantics merely to improve rendering performance unless the domain owner explicitly approves a scientifically equivalent approach.

The authoritative SessionNight / Opportunity calculation remains unchanged unless a verified domain-performance problem requires separate work.

---

## Stage 10.E — Relative Stacking Gain visualization performance

The Stage 6 Relative Stacking Gain view is mathematically simple.

Do not introduce a heavy dependency or complex state architecture solely for this visualization without demonstrated need.

Profile it as part of the Planner.

If existing Flutter primitives or already-approved visualization infrastructure are sufficient, prefer them.

Do not optimize √N calculation itself unless profiling demonstrates an actual issue.

The scientific meaning remains unchanged:

Relative stacking gain = √N versus one compatible frame.

---

## Stage 10.F — Weather/detail rendering

If Stage 6/9 move dense weather data into detail views:

measure the actual detail-screen behavior before introducing virtualization or other complexity.

Potential areas to inspect only if observed:

- long hourly lists;
- charts/time axes;
- repeated formatting;
- unnecessary simultaneous widget construction.

Do not prematurely remove useful weather detail for performance.

Information hierarchy and rendering performance are separate questions.

---

## Stage 10.G — Logbook performance

After Stage 8 establishes search/filter/history behavior, evaluate performance using realistic local data volumes supported by the application.

Measure:

- initial list load;
- search;
- filter application;
- detail opening;
- planned-vs-actual rendering;
- target-progress aggregation if present.

Do not invent an unrealistically huge dataset merely to force database changes.

Do not introduce a remote backend or cloud index.

Keep the local-first architecture.

If SQL/query optimization is required, preserve history/snapshot semantics.

---

## Stage 10.H — Determine what the ~277 MB observation actually represents

Manual Dogfooding observed approximately 277 MB.

Before setting a reduction target, identify:

- where this number was observed;
- whether it is:
  - downloaded artifact size;
  - APK size;
  - AAB size;
  - extracted/native artifact size;
  - installed application footprint;
  - debug/profile/release build;
  - another platform measurement.

Do not compare unlike measurements.

For example:

debug installed footprint  
vs  
release AAB

is not a valid direct before/after comparison.

Record a reproducible baseline for the user-relevant release configuration.

If the original 277 MB measurement cannot be reproduced or its build type cannot be established:

record it as the original HUMAN observation,  
then create a new verified baseline rather than pretending both are directly comparable.

---

## Stage 10.I — Build-size analysis

Once the measurement type is known, analyze the release artifact/installed footprint with appropriate tooling available in the current Flutter/Android environment.

Break down size sufficiently to identify material contributors.

Inspect, where relevant:

- compiled application/runtime components;
- assets;
- images;
- fonts;
- native libraries;
- ABI-related contribution;
- packaged databases/data files if any;
- dependencies;
- symbols/resources included in the measured build.

Do not claim a contributor is large without measurement.

Do not delete components based only on package-name intuition.

The purpose is to answer:

> What actually accounts for the user-visible application size?

---

## Stage 10.J — Dependency review

Review dependencies for:

- actual production usage;
- release-size contribution where measurable;
- duplicate functionality;
- packages retained after old workflows were removed;
- dependencies made obsolete by Track Live retirement or other Stages 6–9 changes.

Do not remove a dependency only because it appears rarely in source search.

Check:

- runtime use;
- platform integration;
- build scripts;
- generated code;
- migration/export/backup paths;
- tests where relevant.

Do not replace a stable dependency with custom code unless the measured benefit justifies the maintenance cost.

Do not introduce new dependencies for charts/animation if existing tools satisfy the requirement.

---

## Stage 10.K — Asset review

Review current packaged assets.

Identify:

- unused assets;
- obsolete branding artifacts after Stage 9 logo work;
- duplicate images;
- unnecessarily large raster assets;
- unnecessary font weights/files;
- generated resources no longer referenced.

Do not remove an asset without verifying runtime/build references.

Do not degrade:

- launcher icon quality;
- splash quality;
- Field Mode;
- accessibility;
- required attribution/legal assets;

merely to reduce size.

If an asset can be represented more efficiently without visible/functional loss, document and verify the change.

---

## Stage 10.L — Build/release optimization

Inspect the CURRENT Flutter/Android release configuration before changing it.

Apply only optimizations appropriate to the current supported release workflow.

Do not copy generic Android/Flutter optimization flags blindly.

Every build optimization must be checked for:

- functionality;
- plugin compatibility;
- startup behavior;
- resource availability;
- release signing/build behavior;
- debugging/support implications where applicable.

Do not alter signing credentials or owner secrets.

Do not read, generate, print or commit private signing material.

If a build optimization changes generated artifacts or release process, update the current release documentation where required.

---

## Stage 10.M — Size goal

The product requirement is:

> Reduce application size where materially possible without sacrificing existing useful functionality or correctness.

Do NOT invent a target such as:

- “under 100 MB”;
- “50% smaller”;
- “match another Flutter app”

unless the owner or current roadmap already defines it.

Stage 10 acceptance should be based on:

- verified baseline;
- identified material contributors;
- justified changes;
- measured before/after result;
- zero functional regression.

If the verified release size is already reasonable and the 277 MB observation turns out to be a debug/install artifact:

record that fact honestly.

Do not perform harmful optimization simply to manufacture a dramatic percentage reduction.

---

## Stage 10.N — No functionality sacrifice

Size/performance optimization must not remove supported functionality simply to improve metrics.

Examples:

do not remove:

- offline data required by the product;
- accessibility resources;
- supported metadata parsing;
- export/backup capability;
- scientific reference data;
- Field Mode;
- required legal attribution;

without a separate product decision.

If a major feature is already formally retired in Stage 8/9, then obsolete implementation/resources may be removed as part of that approved retirement.

Distinguish:

approved dead code  
from  
working but infrequently used functionality.

---

## Stage 10.O — No architecture rewrite by default

Do not use Stage 10 as justification for:

- dependency-injection rewrite;
- Provider replacement;
- database rewrite;
- state-management migration;
- navigation rewrite;
- domain-layer rewrite.

A measured bottleneck may justify a focused architectural correction.

If the required correction is genuinely cross-layer/architectural and outside current decisions:

record the evidence and follow the current governance/ADR process.

Do not make a speculative “performance architecture” rewrite.

---

## Stage 10.P — Performance regression coverage

Where a deterministic automated check is practical and stable:

add appropriate regression coverage.

Do not create flaky timing tests that fail because CI/host speed varies.

Prefer:

- structural tests;
- rebuild/count instrumentation if stable;
- benchmark/profiling evidence;
- existing project performance-test patterns.

Use real-device profiling for behavior that cannot be meaningfully represented by host/widget tests.

Do not turn subjective smoothness into a fake deterministic unit-test threshold.

---

## Stage 10.Q — Stage 10 evidence deliverable

For each optimization, require:

Claim  
→ Evidence  
→ Change  
→ Before  
→ After  
→ Regression check.

Examples:

“Dependency X is unused”  
requires evidence.

“Field lag is caused by Y”  
requires profiling/reproduction.

“Size improved”  
requires equivalent build/measurement conditions.

Do not report:

“optimized performance”

without a measurable comparison.

---

## Stage 10.R — Stage 10 acceptance direction

The Stage 10 plan should be capable of demonstrating:

- the original ~277 MB observation has been classified or explicitly remains unreproducible;
- a reproducible release-size baseline exists;
- major size contributors are identified by evidence;
- safe size reductions are measured;
- existing useful functionality remains intact;
- form-input lag has been investigated from a reproducible scenario;
- verified performance bottlenecks have been corrected or explicitly documented;
- Planner timeline/chart interactions remain responsive on representative supported hardware;
- Logbook/search/filter performance remains practical;
- no new unnecessary visualization/animation dependency was introduced;
- the final state has measured evidence, not assumptions.

Do not require a particular percentage improvement unless current evidence/owner decision supplies it.

---

# STAGE 11 — FULL VALIDATION & BETA READINESS

Stage 11 is the final bounded validation of the product produced by Stages 6–10.

It is NOT:

- a new product-discovery phase;
- another open-ended UI audit;
- a chance to redesign Stage 6;
- a chance to reopen closed owner decisions;
- a new scientific research program.

The core rule is:

> Validate the frozen approved contract; do not continue designing during validation.

Before editing Stage 11:

- inspect every CURRENT Stage 11 task;
- inspect current verification policy in `CLAUDE.md`;
- inspect current TEST_PLAN / beta/release checklist;
- inspect current device/manual evidence;
- preserve existing release-validation work that remains applicable;
- update obsolete tests/checklists where previous Track Live workflow has been intentionally superseded.

Do not assume old audit evidence gaps are still current.

Verify the repository's CURRENT evidence first.

---

## Stage 11.A — Validation sources and evidence levels

Use the project's current evidence vocabulary.

Distinguish as appropriate:

- DOCUMENTED;
- CODE VERIFIED;
- TEST VERIFIED;
- RUNTIME VERIFIED;
- DEVICE VERIFIED;
- HUMAN VERIFIED;
- UNKNOWN.

Do not label a behavior device-verified because a widget test passed.

Do not label a usability conclusion test-verified because code exists.

Do not label old historical audit limitations as current facts without rechecking current evidence.

---

## Stage 11.B — Final validation is contract-based

Build the Stage 11 validation matrix from:

1. approved product decisions;
2. acceptance criteria of Stages 6–10;
3. existing regression/release requirements;
4. scientific/domain invariants;
5. accessibility rules;
6. real-device flows that cannot be proven on host.

Do not start from:

“find anything else that may be wrong”.

A newly exposed severe regression may still block release.

But speculative improvements or newly imagined features are:

- FOLLOW-UP;
- DEFERRED;
- IMPLEMENTATION DECISION;

according to the current verification policy.

They must not create an infinite final-audit loop.

---

## Stage 11.C — Core comprehension validation

Validate whether the redesigned product communicates its primary planning answer.

A user should be able to identify, without reading every technical detail:

- what target is being planned;
- for which site/night;
- the relevant time context;
- whether the plan fits;
- time needed;
- usable time;
- total integration;
- the main constraint/reason;
- the next useful action.

This validation concerns comprehension and hierarchy.

Do not require all technical details to be visible simultaneously.

Also verify that technical depth remains discoverable.

---

## Stage 11.D — Night / Opportunity comprehension

Validate that temporal visualization answers its intended question:

> When can I image this target, and how does the plan fit into that opportunity?

Check that users can distinguish, where represented:

- darkness/twilight;
- target visibility;
- usable Imaging Opportunity;
- planned capture;
- Moon-related limitation/context.

Do not validate a layer that the final approved implementation does not contain.

Check for misleading visual overlap.

The visualization must not imply continuous usable time across real gaps.

Verify textual/accessibility alternative.

---

## Stage 11.E — Capture Budget comprehension

Validate that the user can distinguish:

- Total Integration;
- required plan/session time as presented;
- usable opportunity;
- fit verdict.

Verify that progressive disclosure does not hide a materially important reason.

Check that the visual budget explanation agrees with authoritative calculation output.

Do not validate chart geometry as if it were the calculation.

The calculator remains authoritative.

---

## Stage 11.F — Relative Stacking Gain scientific honesty

Verify:

- label remains Relative Stacking Gain or current approved equivalent;
- value still represents √N relative to one compatible frame;
- it is not labelled SNR;
- graph/text does not imply physical camera SNR;
- incompatible groups are not misleadingly combined;
- text alternative explains the meaning;
- large explanatory prose is available but does not dominate the primary Planner.

Any deviation in scientific meaning is a blocking correctness issue, not cosmetic polish.

---

## Stage 11.G — Estimated Storage validation

Validate the behavior for both known and unknown file-size input.

Known:

- calculator value reaches UI correctly;
- units/rounding follow current conventions;
- no stale value after relevant input changes.

Unknown:

- UI shows Unknown rather than fabricated precision;
- reason/path to missing input is understandable where provided.

Do not require automatic storage estimation when evidence is legitimately unavailable.

Verify no theoretical RAW size has been silently introduced contrary to current scope.

---

## Stage 11.H — Capture/calibration workflow validation

After Stage 7 implementation, validate real workflows for supported camera/workflow classes.

Check:

- irrelevant fields are not unnecessarily exposed;
- inherited values are clear;
- prefills are distinguishable from confirmed facts where required;
- independent values remain editable;
- Not Applicable fields do not appear;
- required mismatches/warnings are visible.

Specifically review the final behavior around:

- Binning;
- ISO / Gain;
- White Balance where approved;
- Focus if it survived research and implementation;
- interval between exposures;
- Dark;
- Flat;
- Bias.

Do not validate an audit suggestion that Stage 7 research rejected.

Use the final approved Stage 7 specification as the contract.

---

## Stage 11.I — Automation honesty

Validate that automation introduced in Stage 7 does not fabricate data.

Check representative flows for:

- target/catalog selection;
- coordinates;
- site/geolocation;
- elevation if automated;
- Bortle/sky darkness if implemented;
- equipment metadata;
- file-size input if implemented.

Verify:

- source/provenance where required;
- user confirmation where required;
- Unknown fallback;
- offline/degraded state;
- no silent write where current metadata rules forbid it.

Do not penalize the product for leaving a value Unknown when no reliable source exists.

That is correct behavior.

---

## Stage 11.J — Saved Plan → Actual → Logbook validation

Validate the canonical primary workflow:

Planner  
→ Save Plan  
→ imaging happens independently  
→ Logbook/result entry  
→ Completed / Partly / Not done according to the final approved vocabulary.

Verify:

- Track Live is not required;
- planned values do not silently become actual;
- actuals require user confirmation/evidence;
- saved intent remains historically trustworthy;
- planned-vs-actual is understandable;
- legacy records still render according to current compatibility policy;
- optional session name remains optional;
- search and filters work together;
- progress/history uses appropriate actual data;
- share/export semantics remain distinct.

Do not require per-frame manual tracking.

---

## Stage 11.K — Legacy Track Live regression boundary

If the dedicated Track Live UI has been retired:

verify that its removal did not break:

- old persisted sessions;
- migrations;
- export;
- backup/restore;
- Logbook history;
- reconciliation of legitimate existing execution data;
- process-death recovery paths that remain relevant to the new product flow.

Remove/replace obsolete E2E steps deliberately.

Do not keep a test that forces the old product workflow solely because the test existed first.

At the same time, do not delete regression coverage for still-valid persistence/history behavior.

---

## Stage 11.L — Library / Settings validation

Validate the Stage 9 ownership model.

### Library

Confirm:

- Library manages reusable entities;
- opening/editing Library does not silently change the current plan;
- explicit plan actions remain explicit;
- Progress is not duplicated across incompatible models.

### Settings

Confirm:

- global settings are actually global;
- plan/session-specific choices are not unnecessarily buried in global Settings;
- scientific preferences explain their effect where needed;
- Settings remains scannable;
- technical help is accessible without becoming a permanent wall of text.

Do not reopen placement decisions that already passed Stage 9 acceptance unless there is a concrete contradiction/regression.

---

## Stage 11.M — Branding / authorship / legal validation

Validate the implemented Stage 9 outcome, not the earlier ideas.

Check:

- final owner-selected logo is applied consistently where intended;
- splash behavior is correct and does not delay startup unnecessarily;
- authorship presentation is present as approved;
- owner-specified GitHub/Reddit links resolve to the intended destinations;
- source repository/project links remain correct;
- required third-party attribution remains present.

For licensing:

validate only the final owner-approved/legal-research outcome.

Do not make a new license choice during Stage 11.

If legal/compliance owner actions remain externally required:

mark them according to current release/governance status rather than inventing completion.

---

## Stage 11.N — Accessibility matrix

Preserve and update the project's existing accessibility requirements.

At minimum ensure new/changed core screens are included in the existing accessibility coverage for:

- Light theme;
- Dark theme;
- Field/red mode;
- normal text;
- large/200% text where current project policy defines it;
- narrow supported device width used by current tests.

Verify:

- no unintended overflow;
- meaningful semantics/labels;
- minimum tap-target rules according to current project policy;
- icon-only actions have accessible labels/tooltips where required;
- text is not trapped in fixed-height containers;
- disclosure controls are discoverable;
- charts/timelines have textual alternatives.

Do not “fix” intentional Field Mode contrast exceptions that current architecture explicitly accepts without an owner decision.

Do not weaken Field Mode merely to satisfy a generic visual rule that conflicts with its approved night-use behavior.

---

## Stage 11.O — TalkBack / screen reader

Run/retain real screen-reader validation where current beta plan requires it.

Focus especially on newly changed flows:

- Planner primary answer;
- collapsible technical sections;
- capture-block editing;
- timeline/chart alternative;
- Logbook search/filter;
- result reporting;
- confirmation/Undo actions;
- Library management;
- Settings controls.

Do not require a screen reader user to infer information only from:

- color;
- chart position;
- animation;
- unlabeled icon.

If automated semantics tests pass but actual TalkBack behavior is unverified:

record the evidence as TEST VERIFIED / DEVICE UNVERIFIED according to current policy.

Do not upgrade evidence level.

---

## Stage 11.P — Reduced motion

Validate reduced-motion behavior for the final UI.

New motion introduced in Stages 6–9 should:

- become reduced/disabled where current system policy requires;
- never contain essential information available only through animation;
- not delay user actions;
- not block startup.

Examples:

- disclosure;
- reorder;
- save feedback;
- delete/Undo;
- recalculation emphasis;
- splash animation.

Do not require decorative animation to prove task completion.

---

## Stage 11.Q — Real device / field-mode validation

Use the CURRENT device evidence and beta checklist.

Do not assume the historical “no Android device” state is still true.

Where not yet verified, final beta readiness should include relevant real-device checks for changed workflows.

Examples may include:

- install/launch of the intended build;
- Planner interaction on representative Android hardware;
- keyboard/input responsiveness;
- location permission flows;
- actual share sheet;
- backup/file picker where still in scope;
- Field/red mode in dark conditions;
- TalkBack;
- orientation/process/lifecycle rows already required by the current TEST_PLAN;
- performance trace where Stage 10 acceptance requires device evidence.

Use the current TEST_PLAN rather than inventing a second device checklist.

Extend it only for genuinely new Stage 6–9 behavior.

---

## Stage 11.R — Field/red mode usability

Validate more than “red theme renders”.

Check practical readability of:

- fit/verdict states;
- warnings;
- secondary text;
- chart/timeline bands;
- selected states;
- buttons/outlined controls;
- Logbook/result entry.

Color must not be the sole carrier of status.

Do not require identical appearance to Dark mode.

Field Mode is a specialized night-use mode.

---

## Stage 11.S — Large-text / narrow-width behavior

The redesigned hierarchy must survive accessibility scaling.

Validate:

- Planner primary answer;
- verdict block;
- context line;
- capture-block rows;
- timeline/chart textual alternative;
- filters;
- dialogs;
- settings;
- Logbook result comparisons.

Do not preserve a compact one-line design by truncating essential meaning.

Allow:

- wrapping;
- vertical growth;
- responsive restructuring

according to Stage 5 rules.

If a compact graphic becomes unusable at large text:

provide the accessible textual representation rather than squeezing labels into unreadable space.

---

## Stage 11.T — Offline / degraded-state validation

Preserve AstroPlan's offline-first product constraint.

Validate relevant final behavior when services are unavailable.

Examples where currently applicable:

- weather unavailable/stale;
- reverse geocoding unavailable;
- external catalog/provider unavailable;
- any Stage 7 automation provider unavailable.

Core planning with already available local data must degrade honestly.

Do not turn an optional convenience provider into a mandatory startup dependency.

Unknown remains Unknown.

Do not silently reuse stale external data as fresh.

---

## Stage 11.U — Error handling / storage failure

Preserve current project-wide error-handling/storage-failure conventions.

For changed write actions in Stages 6–9:

verify:

- failures are surfaced;
- raw internal errors are not dumped to users;
- writes are not silently swallowed;
- partial destructive operations do not leave ambiguous UI state.

Relevant changed actions may include:

- Save Plan;
- result save;
- entity deletion;
- settings persistence;
- export/backup;
- metadata/equipment apply.

Use existing architecture/helpers rather than inventing a second error system.

---

## Stage 11.V — Process death / lifecycle

Update existing lifecycle/E2E paths to the final product flow.

If old tests currently depend on:

Start  
→ tracker  
→ per-frame actions  
→ Finish

and Track Live has been intentionally retired:

do not preserve that exact UI flow merely for test compatibility.

Replace it with coverage of the new approved lifecycle while preserving relevant persistence invariants.

Examples:

- unsaved/changed plan state;
- saved plan survival;
- Logbook/result state;
- interrupted writes;
- historical record integrity.

Use the existing lifecycle matrix as the base.

Do not create a parallel lifecycle test framework.

---

## Stage 11.W — Export / backup / restore

Preserve existing portability/user-ownership validation.

Verify changed session/logbook data survives:

- export where current schema requires it;
- backup;
- restore;
- app restart/process restart;
- current supported migration path.

If optional session names or new actual-result fields are persisted:

ensure existing versioning/schema tests cover them as required.

Do not silently change export schema during final validation.

A schema defect discovered here may block release, but the schema design belongs to the owning implementation task.

---

## Stage 11.X — Performance validation after Stage 10

Stage 11 should not repeat Stage 10 profiling from scratch.

Use Stage 10 baselines/results.

Perform final regression checks on representative final flows.

Confirm that late Stage 9/11 fixes did not regress:

- form responsiveness;
- Planner recalculation;
- timeline rendering;
- Logbook search/filter;
- release application size where relevant.

If a late change materially invalidates the Stage 10 baseline:

rerun the affected measurement only.

Do not reopen full performance research without evidence.

---

## Stage 11.Y — Scientific/domain regression

Final UX validation must not weaken already-verified scientific/domain behavior.

Preserve authoritative implementations for:

- SessionNight;
- Moon/time semantics;
- Imaging Opportunity;
- Capture Budget;
- Fit;
- NPF;
- optics;
- provenance;
- weather staleness;
- relative stacking gain semantics.

Do not accept a visual result merely because it “looks right” if it disagrees with domain output.

New visualizations must consume authoritative domain state.

Unknown remains Unknown.

Thresholds remain preferences, not laws.

No black-box score.

---

## Stage 11.Z — Real-world product comprehension check

The final product should be assessed against the owner’s Manual Dogfooding objective:

1. Are the retained features genuinely useful?
2. Has unnecessary manual data entry been reduced where reliable automation exists?
3. Is remaining information presented clearly, compactly and with appropriate technical depth?

This is a bounded comprehension/usability validation of the implemented product.

It is NOT permission to start another complete product redesign.

Use a small set of realistic scenarios representing the supported product segment.

Examples should be derived from the final supported workflows, such as:

- manual/semi-automated imager planning a target for tonight;
- adjusting a plan that does not fit;
- saving it;
- returning later to report actual results;
- reviewing history;
- managing equipment/site information.

Do not invent a new target user segment during validation.

Do not require novice-only simplification if that was not approved.

Do not require professional automation/hardware control that remains outside scope.

---

# STAGE 11 — BLOCKING VS NON-BLOCKING DISCIPLINE

Use the current Verification Policy.

A finding is BLOCKING only when it is supported by concrete evidence and represents, for example:

- an unmet frozen acceptance criterion;
- wrong scientific/planning output;
- data loss/corruption;
- broken primary workflow;
- inaccessible primary flow where accessibility acceptance requires it;
- serious regression introduced by Stages 6–10;
- release/compliance requirement that current release policy explicitly makes mandatory.

Do not block the stage for:

- a new aesthetic preference;
- an unspecified microinteraction;
- a hypothetical edge case without evidence;
- a newly imagined feature;
- an implementation detail never frozen in acceptance criteria;
- another evaluator preferring a different layout.

Classify those according to the current governance as:

- DEFERRED;
- FOLLOW-UP;
- IMPLEMENTATION DECISION;
- OWNER DECISION only when genuinely necessary.

Do not derive new owner decisions during validation and then fail the stage because the new decision had not previously been specified.

---

# STAGE 11 — FINAL VALIDATION PASS RULE

There should be ONE bounded final validation after the remaining stage work is complete.

Do not create:

validation  
→ redesign  
→ full validation  
→ new audit  
→ more design  
→ another full validation

as an automatic loop.

If validation finds a true blocking defect:

fix the defect in the appropriate owning scope  
→ run proportional verification for that defect  
→ rerun only the affected final criterion plus the final gate required by current policy.

Do not restart product discovery.

---

# STAGE 11 — BETA READINESS OUTPUT

At the end of Stage 11, produce a factual readiness record.

Separate:

## VERIFIED

Acceptance demonstrated by current evidence.

## UNVERIFIED

Implementation may exist, but required device/human/external evidence is missing.

## OWNER ACTION

Requires an owner-controlled action such as a release credential, legal publication, store action or other action the AI cannot perform.

## DEFERRED

Explicitly outside current release scope.

Do not convert UNVERIFIED into PASS.

Do not convert an owner-controlled release action into an implementation defect.

Do not claim beta/release readiness while a current mandatory release criterion remains unverified.

Use the repository's current exact status vocabulary where it differs from the conceptual grouping above.

---

# STAGE 10–11 CROSS-CHECK BEFORE DOCUMENT EDITING

Before updating the current plan, reconcile at minimum:

Performance / Size:

- ~277 MB observation and its unknown measurement context;
- release-size baseline;
- dependency contribution;
- asset contribution;
- form input lag;
- keyboard/focus responsiveness;
- rebuild/state-performance investigation;
- Planner/timeline/chart rendering;
- Logbook search/filter performance.

Final validation:

- Planner comprehension;
- timeline/opportunity comprehension;
- Capture Budget semantics;
- Relative Stacking Gain honesty;
- Storage known/unknown behavior;
- Light/Dark/Flat/Bias final workflow;
- automation provenance/Unknown;
- Saved Plan → Actual → Logbook;
- legacy Track Live records;
- Library manage-vs-select;
- Settings ownership;
- deletion/Undo/confirmation behavior;
- Night & Moon / Weather detail;
- branding/authorship/legal outcome;
- light/dark/field;
- large text;
- TalkBack;
- reduced motion;
- offline/degraded states;
- lifecycle/process death;
- export/backup/restore;
- final performance regression;
- scientific/domain regression.

For each item determine:

existing task  
→ whether clarification is needed  
→ owning stage  
→ exact acceptance impact.

Do not add duplicate tasks where current coverage is already sufficient.

---

# STAGE 10–11 DOCUMENT EDITING RULE

Prefer modifying existing Stage 10/11 tasks and acceptance criteria.

Create a new bounded task only if current plan genuinely lacks a substantial independently executable unit.

Do not create a task for every bullet in this prompt.

Do not renumber completed stages.

Do not rewrite historical audit documents.

Do not update historical evidence to pretend future work has already passed.

Do not start Stage 10 or Stage 11 implementation as part of this planning correction.

---

# STAGE 10–11 PLANNING VERIFICATION

For this documentation/planning amendment verify:

- Stage 10 begins with measurement rather than speculative optimization;
- the ~277 MB observation is not misrepresented as a known release size;
- no arbitrary size target was invented;
- form lag remains a measured investigation target;
- Stage 10 does not authorize architecture rewrite;
- Stage 11 validates the final contract rather than opening new product discovery;
- existing accessibility rules are preserved;
- new charts/timelines require textual alternatives;
- old Track Live tests are not allowed to freeze an intentionally superseded workflow;
- current evidence is checked before repeating historical “unverified” claims;
- device/human evidence is not conflated with host tests;
- Stage 11 has bounded blocker criteria;
- only one final validation cycle is planned.

Do not run another broad audit as part of this planning-only correction.

# FINAL SECTION — RECONCILE AND APPLY THE COMPLETE STAGES 6–11 CORRECTION

You have now received the complete planning correction covering:

- global information hierarchy and preservation rules;
- Stage 6 — Core Planner Redesign;
- Stage 7 — Data Entry & Automation;
- Stage 8 — Saved Plans / Actuals / Logbook / Track Live retirement;
- Stage 9 — Secondary UX & Product Polish;
- Stage 10 — Performance & Application Size;
- Stage 11 — Full Validation & Beta Readiness.

Do NOT begin editing immediately from the last section you read.

First reconcile the COMPLETE correction against the CURRENT repository plan.

The objective is not to replace the existing roadmap with this prompt.

The objective is:

> preserve valid current scope
> 
> - clarify under-specified work
> - add genuinely missing requirements
> - resolve contradictions where owner intent is now explicit
> - maintain clean stage ownership
> - keep the plan executable.

---

# 1. SOURCE-OF-TRUTH PRIORITY

Use current repository documents, not chat memory, for exact current task IDs, statuses and dependency names.

At minimum use the current versions of:

- `CLAUDE.md`
- `docs/refinement/PRODUCT_DIRECTION.md`
- `docs/refinement/POST_ROADMAP_PLAN.md`
- `docs/refinement/PROGRESS.md`
- `docs/DESIGN_SYSTEM.md`
- the current Stage 4 decision / ADR records
- current decision/research/dependency registers referenced by Stages 6–11
- `docs/audit/08_MANUAL_DOGFOODING.md`

Read other repository files only when needed to resolve a concrete planning conflict.

Do NOT perform another repository-wide audit.

Do NOT treat historical audit status as automatically current.

Do NOT rewrite historical audit documents.

---

# 2. CURRENT REPOSITORY STATE OVERRIDES OLD HISTORICAL STATUS

Where historical audit documents and CURRENT refinement documents disagree about completion state:

use the CURRENT refinement/source-of-truth state.

In particular:

Stage 5 is CLOSED.

Do not reopen it because an older audit described an earlier implementation state.

Similarly:

do not repeat old unresolved findings as current work if the current repository records them as resolved.

If uncertain:

verify the current source-of-truth record before adding a task.

---

# 3. BUILD A TEMPORARY COVERAGE MATRIX BEFORE EDITING

Before modifying the plan, create a temporary working matrix covering every substantive requirement in this prompt.

The matrix should contain:

| Requirement / problem | Current task coverage | Classification | Owning stage | Required plan change | Dependency / decision |
| --------------------- | --------------------- | -------------- | ------------ | -------------------- | --------------------- |

Use these classifications:

### ALREADY COVERED

The current plan already owns the requirement adequately.

Action:  
preserve it.  
Do not duplicate it.

### UNDER-SPECIFIED

The current plan owns the correct area, but important behavior/acceptance criteria from this correction are missing.

Action:  
clarify the existing task.

### MISSING

The requirement is genuinely absent.

Action:  
add it to the best existing task, or create a bounded task only when the work is independently substantial.

### SUPERSEDED

A previous planned behavior conflicts with an explicit later owner/product decision.

Action:  
record the superseding decision clearly and update future scope.

Do NOT erase historical records.

### CONFLICT

Two current source-of-truth requirements cannot both be satisfied.

Action:  
identify the exact conflict.

Resolve it from an already-recorded owner decision if possible.

Only request a new OWNER DECISION if no existing source resolves it and implementation genuinely cannot proceed safely.

### DEFERRED / REJECTED

The current product scope explicitly excludes it.

Action:  
preserve the boundary.

Do not quietly bring it back.

This matrix is working material.

Do not create a permanent document for it unless current governance requires one.

---

# 4. REQUIRED CROSS-STAGE OWNERSHIP CHECK

Before editing, confirm that each major responsibility has ONE clear primary owner.

The intended ownership after this correction is:

## Stage 6 — Core Planner

Owns:

- answer-first Planner hierarchy;
- practical fit presentation;
- existing altitude/window visualization vs Night Timeline reconciliation;
- Night / Opportunity temporal presentation;
- Capture Plan presentation;
- Capture Plan Outputs redesign;
- Capture Budget presentation;
- inverse frame-count / “what fits?” presentation;
- Relative Stacking Gain visualization;
- Estimated Storage pipeline verification and Planner presentation;
- concise Planner weather summary;
- concise Planner rig summary;
- technical-detail progressive disclosure;
- Planner cause/effect feedback.

Stage 6 does NOT own:

- broad data-entry automation;
- calibration workflow research;
- actual-result lifecycle;
- Logbook redesign;
- global Settings review;
- performance optimization;
- final product validation.

---

## Stage 7 — Data Entry & Automation

Owns:

- reduction of unnecessary manual input;
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
- reliable storage-input acquisition if Stage 6 identifies missing evidence.

Stage 7 does NOT invent data when no reliable source exists.

---

## Stage 8 — Actuals / Logbook lifecycle

Owns:

- saved intent → actual result;
- Planned vs Actual;
- lightweight result reporting;
- Completed / Partly / Not done according to current canonical vocabulary;
- safe retirement of dedicated Track Live / Execution UI;
- legacy execution-data compatibility;
- Logbook historical center;
- optional session names;
- Logbook search;
- Logbook filters;
- Logbook detail;
- share semantics;
- progress based on actual/logged results;
- compatibility with later evidence-assisted actuals.

Stage 8 does NOT require live per-frame reporting.

---

## Stage 9 — Secondary UX / Polish

Owns:

- Library role and manage-vs-select clarity;
- Settings comprehensive review;
- correct preference ownership/placement;
- secondary Night & Moon / Weather detail presentation;
- Sky Darkness / Light Pollution secondary UX within approved data/licensing constraints;
- consistent deletion/confirmation/Undo UX;
- action feedback;
- secondary form adoption;
- logo analysis/selection/implementation workflow;
- splash polish;
- authorship;
- sources/attribution;
- license research and owner decision;
- secondary-screen consistency;
- typography/content-density adoption.

Stage 9 does NOT become a miscellaneous feature backlog.

---

## Stage 10 — Technical Optimization

Owns:

- reproducible performance baseline;
- form-input lag investigation;
- Planner recalculation performance;
- timeline/chart rendering performance;
- Logbook query/search/filter performance;
- determining what the ~277 MB observation actually measures;
- release-size baseline;
- size contribution analysis;
- dependency review;
- asset review;
- safe release/build optimization;
- measured before/after evidence.

Stage 10 does NOT authorize an architecture rewrite by default.

---

## Stage 11 — Final Validation

Owns:

- frozen-contract validation;
- product comprehension;
- Planner answer visibility;
- timeline comprehension;
- Capture Budget correctness/presentation agreement;
- Relative Stacking Gain scientific honesty;
- Storage known/Unknown behavior;
- final calibration workflow;
- automation honesty/provenance;
- Saved Plan → Actual → Logbook flow;
- legacy-data compatibility;
- Library/Settings behavior;
- branding/authorship/legal result;
- accessibility;
- TalkBack;
- large text;
- reduced motion;
- Field/red mode;
- offline/degraded behavior;
- lifecycle/process death;
- export/backup/restore;
- final performance regression;
- scientific/domain regression;
- bounded beta-readiness record.

Stage 11 does NOT reopen product design without concrete blocking evidence.

---

# 5. EXPLICIT OWNER INTENT THAT MUST NOT BE LOST

When reconciling the current plan, preserve these owner directions.

## 5.1 Planner is the core product surface

AstroPlan is primarily a useful planner for upcoming astrophotography sessions.

Execution/logging support planning.

They should not dominate the product hierarchy.

---

## 5.2 Preserve useful functionality

Do not delete working useful functionality merely because the current UI presentation is poor.

First distinguish:

- useful functionality with poor presentation;
- duplicated workflow;
- genuinely obsolete workflow;
- internal/domain capability that should remain even if its current screen disappears.

---

## 5.3 Reduce unnecessary manual input

Where AstroPlan already knows a value or can reliably obtain it:

avoid forcing the user to re-enter it.

But:

automation without evidence is worse than honest Unknown.

---

## 5.4 Preserve technical depth without permanent technical overload

Do not remove useful expert information merely to simplify the interface.

Use:

summary  
→ context  
→ technical depth on demand.

---

## 5.5 Dedicated Track Live is superseded as the target product flow

Do not leave the future plan ambiguous on this product direction.

The target primary workflow is:

Planner  
→ Save Plan  
→ imaging occurs independently  
→ Logbook  
→ report actual outcome.

Stage 8 still owns safe dependency/data migration and retirement work.

Do not equate retirement of the dedicated UI with deletion of all execution-related domain/history logic.

---

## 5.6 Relative Stacking Gain remains √N

It is:

relative statistical stacking gain compared with one compatible frame.

It is NOT:

- physical SNR;
- Estimated SNR;
- final image-quality prediction.

Do not reintroduce SNR terminology.

---

## 5.7 No black-box score

Do not add:

- Astro Score;
- Stargazing Score;
- composite good/bad percentage;
- hidden recommendation formula.

Reasons and factual conditions remain transparent.

---

## 5.8 Unknown remains Unknown

Do not fabricate:

- storage;
- equipment specifications;
- Bortle;
- elevation;
- metadata values;
- actual results;
- weather;
- scientific values

merely to avoid an empty state.

---

## 5.9 Preserve AstroPlan visual identity

Use the completed Design System.

The redesign should be:

- clearer;
- more structured;
- less noisy;
- more visual where useful;
- more polished;

without becoming visually unrelated to AstroPlan.

External applications are pattern references, not templates.

---

# 6. DO NOT SILENTLY REINTRODUCE REJECTED / DEFERRED FEATURES

While editing Stages 6–11, check the CURRENT rejected/deferred scope.

Do not silently introduce, among other currently excluded concepts:

- planetarium;
- sky map;
- 3D;
- AR;
- hardware control;
- ASCOM / INDI / ASIAIR control;
- native camera control;
- cloud accounts;
- social network;
- backend;
- black-box score;
- physical SNR model without an approved camera-noise model;
- customizable dashboard;
- multi-target scheduling;
- Project entity;
- theoretical RAW storage model;
- moving-object support;
- unrelated advanced astronomy features.

If current repository decisions have since explicitly superseded any of these boundaries:

follow the CURRENT decision.

Do not infer supersession from this prompt unless explicitly stated.

---

# 7. PRESERVE EXISTING TASKS THAT THIS PROMPT DOES NOT DISCUSS

This prompt is intentionally focused on the newly analyzed product/UX direction.

It is NOT an exhaustive restatement of every future roadmap item.

Therefore:

absence from this prompt is NOT evidence that an existing task should be removed.

Before deleting or narrowing any existing future task, require one of:

- explicit owner supersession;
- a direct contradiction with an approved new direction;
- evidence that another task now fully owns the responsibility;
- current governance decision to remove it.

Otherwise preserve it.

---

# 8. TASK GRANULARITY RULE

Do not create dozens of new microtasks from the subsections in this prompt.

The subsections define requirements and acceptance constraints.

They are NOT automatically roadmap task boundaries.

Prefer:

existing task

- clearer Scope
- clearer Acceptance
- explicit Dependency

when possible.

Create a new task only when the work:

- has its own research/decision cycle;
- is independently implementable;
- is substantial enough that embedding it would make another task unbounded;
- has distinct verification/acceptance.

Maintain the project's current task-size discipline.

Do not create XL/open-ended tasks.

If one corrected task has become too large:

split it along a real dependency boundary rather than arbitrary UI sections.

---

# 9. RESEARCH TASK DISCIPLINE

Some future items require research before implementation.

Examples include:

- calibration workflow details;
- ISO/Gain/Binning/WB/Focus behavior;
- reliable Bortle/elevation sources;
- new external equipment/spec providers;
- license compatibility.

For those tasks preserve:

research  
→ evidence  
→ owner decision only if genuinely needed  
→ spec/ADR if required  
→ implementation  
→ verification.

Do not implement an answer while the factual premise remains unknown.

Do not create an OWNER DECISION for a question that can be answered from:

- current code;
- current docs;
- existing decision records;
- reliable technical sources.

Do not ask the owner to decide scientific facts.

---

# 10. OWNER DECISION DISCIPLINE

Only add a new OWNER DECISION when:

1. two or more materially different valid product choices remain;
2. no existing approved decision resolves them;
3. implementation would encode a product policy;
4. choosing automatically would exceed implementation discretion.

Do NOT make routine design details owner decisions.

Examples generally suitable for implementation discretion after the contract is fixed:

- exact card spacing;
- exact chart stroke thickness;
- exact icon choice among semantically equivalent approved icons;
- internal widget decomposition.

Examples that may require owner decision:

- final logo direction;
- final license selection after legal research;
- a true unresolved product-policy conflict.

Do not generate owner-decision debt unnecessarily.

---

# 11. ADR / DECISION RECORD RULE

Do not create a new ADR merely because UI changed.

Use the repository's current ADR policy.

Create/update a decision record when the correction changes:

- domain semantics;
- persistence ownership;
- lifecycle policy;
- architecture;
- product behavior requiring durable rationale;

according to current governance.

For purely presentational implementation choices:

use the relevant task/spec/design documentation instead.

When an older decision is superseded:

do not erase it.

Record:

- what supersedes it;
- why;
- date/current planning context;

using the repository's existing decision format.

---

# 12. TRACK LIVE SUPERSESSION RECORD

Because the target product direction has changed from the older execution-first concept:

inspect the current product-flow decision record.

If the current canonical decision still says that dedicated live tracking remains an optional target workflow:

update the appropriate decision/specification so it clearly records the newer owner direction:

> Dedicated Track Live / Execution is no longer part of the target primary product flow.

Primary flow:

Planner  
→ Save  
→ image independently  
→ Logbook  
→ actual outcome.

Do NOT rewrite historical documents to pretend this was always the decision.

Do NOT delete implementation in this planning task.

Record Stage 8 as the owner of safe implementation retirement / migration.

If the current repository already records this supersession correctly:

do not duplicate it.

---

# 13. MANUAL DOGFOODING TRACEABILITY

When amending the future plan, ensure the substantive Manual Dogfooding observations have an owner or explicit disposition.

At minimum trace:

- logo/splash;
- Home/Tonight hierarchy;
- Draft/Planner duplication;
- Night/Moon/Weather navigation;
- dedicated Start/Execution concern;
- What Can I Image Tonight manual target entry;
- session creation clarity;
- site/geolocation/elevation/Bortle questions;
- typography/hierarchy;
- target catalog;
- Conditions/Timeline presentation;
- equipment entry;
- Capture Plan redesign;
- Binning / ISO / Gain / WB / Focus / interval;
- Dark / Flat / Bias workflows;
- total integration / budget / fit;
- Relative Stacking Gain;
- Estimated Storage;
- assumptions/explanatory text;
- Settings;
- Library;
- deletion interaction;
- Tracked ownership;
- forms/performance;
- authorship/links/license;
- Logbook;
- application size/performance.

For every substantive observation determine:

- already resolved;
- owned by Stage 6–11;
- preserved as a research question;
- deferred/rejected by existing scope;
- requires owner decision.

Do not turn every suggested implementation from Manual Dogfooding into a requirement.

Preserve the underlying user problem.

---

# 14. CODEX UI/UX ANALYSIS TRACEABILITY

Use the previously supplied Codex analysis as supporting design input, not as an independent owner decision.

Preserve the useful conclusions that are consistent with current project decisions:

- decision-first hierarchy;
- progressive disclosure;
- concise weather and rig summaries;
- practical fit answer before technical detail;
- visual explanation of time/budget relationships;
- graphics should explain authoritative calculations;
- avoid replacing textual overload with graphical overload;
- preserve AstroPlan visual language;
- motion should communicate state;
- Stage 5 remains complete;
- Stage 6 is the primary screen-restructuring stage.

Where this correction intentionally strengthens a requirement beyond Codex's priority recommendation:

follow the owner-approved correction.

Example:

Relative Stacking Gain visualization is intentionally retained as a Stage 6 deliverable rather than being left as an indefinite lower-priority idea.

---

# 15. SCIENTIFIC / DOMAIN SAFETY CHECK

Before finalizing the amended plan, verify that no new UI requirement changes scientific meaning by implication.

Specifically check:

### Time

All night/timeline displays continue to use the authoritative SessionNight/time-context model.

### Opportunity

Imaging Opportunity remains transparent and reason-based.

Unknown data does not silently exclude time unless current domain policy explicitly requires it.

### Capture Budget

Preserve the defined distinctions:

- Integration;
- Acquisition;
- Session Budget.

### Fit

The authoritative fit/scheduling logic remains the source of truth.

### Relative gain

√N remains relative gain, not physical SNR.

### Weather

No composite score.

### Storage

Unknown input → Unknown estimate.

### Provenance

Imported / measured / estimated / reported values remain distinguishable where materially relevant.

Do not let presentation simplification collapse semantic distinctions.

---

# 16. ARCHITECTURE SAFETY CHECK

Ensure the amended plan does NOT authorize accidental architecture drift.

Preserve current principles unless a current approved decision says otherwise:

- Provider architecture stays;
- ViewModels stay;
- no DI-container rewrite;
- no application rewrite;
- authoritative domain calculations remain outside widgets;
- presentation does not become a second scientific-calculation layer;
- persistence rules remain transactional/currently approved;
- metadata proposals do not silently become persisted facts;
- core features remain offline-capable.

A later task may refactor locally when evidence justifies it.

Do not turn UI redesign into architecture replacement.

---

# 17. PLAN EDITING PROCEDURE

After the reconciliation matrix is complete:

## Step 1 — Update `POST_ROADMAP_PLAN.md`

Integrate the corrections into the CURRENT Stage 6–11 structure.

For each affected task ensure, where relevant:

- Goal;
- Why;
- Scope;
- Out of scope;
- Dependencies;
- Research/decision gate;
- Acceptance;
- verification expectations;

remain internally coherent with the repository's current task format.

Do not rewrite unrelated sections stylistically.

Do not renumber completed stages.

Preserve current identifiers where practical.

---

## Step 2 — Update durable product/decision documentation only where needed

If this correction formally supersedes a current durable product decision, update the appropriate current source.

Likely example:

- dedicated Track Live product-flow status.

Do not update decision records unnecessarily for visual implementation details.

Do not duplicate the same decision in several competing source-of-truth files.

---

## Step 3 — Update dependency / research / owner-decision registers

Where the current plan uses registers such as:

- RD;
- RG;
- owner decision;
- technical debt;
- other current equivalents;

update them consistently.

Do not invent a new register system.

Resolve entries that this planning correction has actually answered.

Preserve entries that remain legitimately open.

Do not mark research complete when no research was performed.

---

## Step 4 — Update `PRODUCT_DIRECTION.md` only if necessary

Do not rewrite it wholesale.

Update it only where a durable product-level direction has genuinely changed or needs explicit clarification.

Potential relevant durable direction:

- Planner-first product;
- Logbook-first post-session outcome;
- dedicated Track Live retirement from target product flow;
- decision-first / technical-depth-on-demand principle if this document is the correct canonical home for it.

First inspect the existing document.

Do not duplicate text that already exists adequately.

---

## Step 5 — Update `PROGRESS.md`

Keep `PROGRESS.md` concise.

Record:

- that Stages 6–11 planning was amended based on Manual Dogfooding + post-Stage-5 UI/UX analysis;
- that Stage 5 remains closed;
- which durable product decisions were superseded/clarified;
- genuine remaining owner decisions, if any;
- the new Next Allowed Action.

Do NOT paste the full plan into `PROGRESS.md`.

Do NOT turn it into history.

Use the current repository format.

---

# 18. NEXT ALLOWED ACTION

After this planning correction, do NOT automatically start implementation.

Set `Next Allowed Action` to the first legitimate Stage 6 implementation/planning task in the CURRENT amended roadmap.

Use the actual task ID/name from the repository after editing.

Do NOT invent a task ID from this prompt.

If Stage 6 still contains a required unresolved decision/research gate that must precede implementation:

set Next Allowed Action to that gate instead.

Otherwise:

set it to the first executable Stage 6 task.

The important rule is:

planning correction complete  
→ STOP  
→ owner reviews/approves  
→ later implementation begins.

Do not begin Stage 6 code in the same session unless explicitly instructed after the planning correction.

---

# 19. DO NOT RUN IMPLEMENTATION TESTS FOR A DOCS-ONLY CHANGE

This task is planning/documentation work.

Use the CURRENT canonical verification policy.

Run only proportional checks relevant to modified documentation, for example where applicable:

- formatting;
- markdown/reference consistency;
- repository-specific docs checks;
- whitespace/encoding;
- broken internal task references;
- duplicated task IDs;
- dependency/register consistency.

Do not run a full Flutter quality gate merely because the roadmap changed.

Do not build Android.

Do not run UI tests.

Do not claim application behavior was verified by this planning task.

---

# 20. DOCUMENT CONSISTENCY CHECK

Before committing, verify all of the following:

## Completion state

- Stage 5 remains CLOSED.
- Stage 6 remains the next implementation stage unless a real prerequisite says otherwise.

## No duplicated ownership

Each substantive correction has one primary owning stage.

## No lost future scope

Existing valid tasks not discussed by this prompt remain intact.

## No contradictions

Check:

- Stage 4 lifecycle decisions;
- Stage 5 Design System;
- Product Direction;
- Stage 6–11 plan;
- dependency/register entries;
- Progress Next Allowed Action.

## No reopened rejected scope

No black-box score, physical SNR, planetarium, hardware control, etc. was accidentally reintroduced.

## No scientific semantic drift

Timeline/budget/gain/storage language remains honest.

## No automation fabrication

Unknown remains Unknown.

## No validation loop

Stage 11 contains one bounded final validation strategy.

---

# 21. REQUIRED FINAL REPORT BEFORE COMMIT

Before committing, report the proposed planning result concisely but completely.

Use this structure:

## A. Current-state confirmation

State:

- Stage 5 status;
- Stage 6 status;
- documents inspected;
- whether any current source contradicted this prompt.

Do not claim more than repository evidence demonstrates.

## B. Coverage result

For each Stage 6–11 summarize:

- existing tasks modified;
- any new task added;
- why a new task was necessary;
- any existing task preserved unchanged despite being related.

Use actual task IDs from the current repository.

## C. Major product corrections

Explicitly report how the amended plan now handles:

1. answer-first Planner;
2. Night / Opportunity visualization;
3. Capture Plan / Outputs;
4. inverse frame-count / “what fits”;
5. Relative Stacking Gain graph;
6. Estimated Storage;
7. technical progressive disclosure;
8. target/site/equipment automation;
9. Light/Dark/Flat/Bias workflow research;
10. Saved Plan → Actual → Logbook;
11. dedicated Track Live retirement;
12. Library;
13. Settings;
14. logo/splash;
15. authorship/license;
16. form lag;
17. application size;
18. final accessibility/device/beta validation.

## D. Manual Dogfooding coverage

Identify any substantive Manual Dogfooding item that is NOT owned by Stages 6–11 after the amendment.

For each such item explain exactly why:

- already completed;
- already covered elsewhere;
- deferred;
- rejected;
- owner decision;
- unsupported by current evidence.

There should be no silent omission.

## E. Genuine owner decisions remaining

List ONLY real unresolved owner decisions.

Do not list implementation details.

For each state:

- why current repository evidence cannot resolve it;
- which task depends on it;
- whether implementation can proceed elsewhere without it.

If none remain immediately blocking Stage 6, state that explicitly.

## F. Scope preservation

Confirm that:

- existing unaffected tasks were not removed;
- completed stages were not reopened;
- rejected/deferred product boundaries remain intact.

## G. Verification performed

List only the documentation/planning checks actually run.

Do not report Flutter/application testing if it was not run.

## H. Proposed Next Allowed Action

State the exact current amended task ID/name that should run next.

Then wait for owner review before committing if current governance requires pre-commit approval.

If current governance authorizes this already-approved planning task through commit:

proceed with one documentation/planning commit.

Follow the repository's CURRENT approval rule rather than guessing.

---

# 22. COMMIT RULE

This entire planning correction should normally be ONE logical documentation/planning commit.

Do not create:

- one commit per stage;
- a separate cosmetic docs commit;
- implementation changes in the same commit.

The commit should contain only the source-of-truth planning/decision/progress changes required for this correction.

Use the repository's existing commit-message convention.

Do not amend unrelated commits.

Do not rebase/rewrite history.

---

# 23. POST-COMMIT REPORT

After the commit, provide:

- commit hash;
- files changed;
- short description of each changed source-of-truth document;
- Stage 6–11 ownership summary;
- remaining owner decisions;
- Next Allowed Action;
- confirmation that no application code was changed;
- confirmation that implementation was NOT started.

Do not automatically continue.

STOP.

---

# 24. ABSOLUTE STOP CONDITION

After the planning correction is committed:

STOP.

Do NOT:

- begin Stage 6 implementation;
- create UI mockups;
- modify Flutter code;
- start research tasks;
- run another audit;
- ask Codex for another validation;
- start the Next Allowed Action automatically.

The owner will review the amended plan first.

---

# 25. FINAL QUALITY BAR FOR THIS PLANNING TASK

This correction is successful only if the resulting roadmap is:

## Complete

The substantive owner observations and approved UI/UX conclusions have explicit ownership or disposition.

## Conservative

Existing valid scope is preserved.

## Non-duplicative

The same requirement is not implemented independently in several stages.

## Scientifically honest

No visual simplification changes domain meaning.

## Executable

Tasks have realistic boundaries, dependencies and acceptance criteria.

## Evidence-driven

Research questions remain research questions until evidence exists.

## Stable

Closed stages remain closed.

## Governed

The repository can resume from one clear Next Allowed Action without relying on this chat.

The final repository documentation — not this conversation — must be sufficient for the next fresh implementation session.
