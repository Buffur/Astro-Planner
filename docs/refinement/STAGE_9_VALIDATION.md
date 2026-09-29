# Stage 9 — Independent validation (S9.1–S9.9)

Date: 2026-09-29. Reviewed baseline: `8e53479` (S9.10–S9.12 prepared; application code as at S9.9,
`0a0c95e`; clean working tree before validation). Fresh session, separate from the one that built
S9.1–S9.9; validation only, no application fixes. Procedure: `prompts/INDEPENDENT_STAGE_VALIDATION.md`;
`CLAUDE.md` V1–V8.

**Scope of this validation.** The built Tasks S9.1–S9.9. S9.10 (the logo), S9.11 (the licence,
RG-12) and S9.12 (the project identity, RD-01) are owner gates: only their preparation is checked
(each prepared as its frozen scope says, and nothing built that depends on the owner's answer). The
Stage's exit ("the areas above are done or deferred by the owner") cannot be met until the owner
decides or defers those three.

## Frozen acceptance surface

Frozen before reading the implementation, from `POST_ROADMAP_PLAN.md` ("Stage 9 — Secondary UX &
Product Polish": scope, "No feature creep", exit; "Stage 9 — frozen Task sequence (planning,
2026-09-29)": the rules for every Task and S9.1–S9.12 with their scope and acceptance, the
implementer's *(Built by …)* / *(Corrected at …)* annotations judged separately), "Stages 6–11:
shared rules", DECISIONS E.1 ("Stage 9 decisions": D9-1 to D9-6; RD-07; RD-09 = M + S1; RD-11 = S9),
RG-13 (answered by `research/S9.3_SETTINGS.md`), ADR-019 §8, and the `CLAUDE.md` traps the Stage
touches.

| ID | Criteria to judge |
| --- | --- |
| C | Stage scope and exit: Settings (RG-13, the TD-050 gates); the Library; About (authorship, Reddit prominent, the author's links not waiting for RD-01; the source, project and policy links follow RD-01 and are never broken); sources and attribution consistent with `COMPLIANCE.md` and the privacy policy, no required credit removed; deletion interactions (cancelled swipe returns the row, confirmation attached, entities with records confirm); final visual consistency; the detail screens' secondary presentation (domain times only, no planner duplication; Weather keeps age, stale, unknowns, units, attribution, horizontal-visibility wording, no score); sky darkness readable, no inference or unapproved map; feedback through `showDone`, not for every tap; secondary forms on Stage 5's components; share and export polish (no schema change, no image card); Tonight's entry points; no feature creep; exit: done or deferred by the owner. |
| R | Rules for every Task: presentation only (no schema change, no calculation in a widget, no formula change); every user write through `runWithFeedback`; every stored record deleted through `confirmDestructive` with a visible Delete and a swipe shortcut; new screens or states in the sweep; renamed labels in the E2E; the retired-terms baseline only shrinks; documents in the same change; one Task per commit; the full gate after each Task's last code change. |
| T1 | S9.1 acceptance 1–5: a Library tap on a rig, target and site opens it and leaves the plan's rig, target and the active site unchanged; `/select/…` still chooses; "Plan this target" asks when the plan has unsaved changes and starts a new plan with it; each delete asks through `confirmDestructive` and a cancelled swipe returns the row; TD-053 resolved; the sweep covers the three lists in both modes. |
| T2 | S9.2: the retired-terms baseline empty and a test requiring it; the editors' labels and Save buttons in a widget test; `equipment_editor_fit_test.dart` and the sweep pass; no saved value changes (existing editor tests unchanged in substance). |
| T3 | S9.3: every setting in the verified inputs has a class, an effect and a placement; factual claims cite sources; the owner asked nothing; the placements in E.1 (D9-3). |
| T4 | S9.4 acceptance 1–6: each gate on, its threshold set, the opportunity changes through the ViewModel (calculator tests unchanged); the per-frame slider reaches 120 s; an overhead value persists and changes the budget; a failed save shows the shared failure text; Restore through `confirmDestructive`; TD-050 resolved and the sweep covers every section. |
| T5 | S9.5: the author block and both profile links and each attribution in a widget test; `COMPLIANCE.md` and the privacy policy checked; no third-party credit removed; source, project and policy links unchanged pending RD-01; `pubspec.yaml`'s template description replaced. |
| T6 | S9.6: widget tests for the visuals' unknown, empty and available states with text alternatives; no computation in widgets; the sweep covers both screens with a full forecast. |
| T7 | S9.7: widget tests for known, partly known and unknown; no raw ISO date; no inference, no Bortle ↔ SQM conversion; the sweep passes. |
| T8 | S9.8: tests for each new message; TD-081 resolved with a test under `disableAnimations`; the file-name tests; the E2E updated if a label changes. |
| T9 | S9.9: the test forbidding ad hoc styles on the secondary screens; the sweep in every theme at 100 % and 200 %; no screen's content changes. |
| G | S9.10–S9.12 (owner gates): each document prepared per its frozen scope; no mark, licence text or identity chosen; nothing in `android/`, `tool/`, `LICENSE`, `AppIdentity` or the privacy policy changed in anticipation. |
| D | D9-1 (two modes; the active site chosen only where a site is chosen for planning; "Plan this target" under the guard); D9-2 (visible Delete and swipe through `confirmDestructive`); D9-3 (RG-13's placements; the gates as a switch and a threshold; the overheads editable within the model's ranges; no default changes); D9-4 (author block first, apart from third-party credit; links until RD-01); D9-5 (feedback, none for a setting visible in place; TD-081); D9-6 (TD-074 not in Stage 9). RD-07, RD-09 = M + S1, RD-11 = S9. |
| S | Shared rules (Stages 6–11): ownership (Stage 9 owns the secondary screens, not the planner or Tonight); hierarchy and one level of disclosure; visualisations draw domain output with unknown/empty states and a text alternative; colour never carries a state alone, field mode red only, no weather score; motion honours reduced motion; `Tracked` not back in Settings; exclusions; science unchanged. |
| I | Invariants: traps 12 (tokens), 13 (no calculation in screens; `QuantityText`), 15 (errors), 17 (sweep), 18 (writes report failure), 19 (E2E keys), 22 (nothing new leaves the device), trap 20 untouched (no icon change before the owner). |
| E | Each Task's full gate after its last code change; no device run or real-sample test is required by this Stage. |

## Evidence and judgments

**Outcome: S9.1–S9.9 PASS.** No V4 blocker. Three non-blocking findings (S9V-01 to S9V-03),
recorded as TD-089 to TD-091, and three notes on the implementer's annotations (below). No
production code or test was changed. **Stage 9 does not close yet:** its exit waits for the owner's
decisions on S9.10–S9.12.

**Gate reuse (V3):** full quality gate PASS on S9.9's final inputs (`0a0c95e`): 1,825 tests, 2
expected skips; 2 host E2E; Flutter 3.47.4. `git diff --stat 0a0c95e HEAD -- . ':!docs'
':!CLAUDE.md' ':!README.md'` is empty (checked before and after the probes); `8e53479` changed
documentation only. Reused, not rerun. Each Task's commit records its own final gate: S9.1
`dfe2ce1` (1,797), S9.2 `867699a` (1,801), S9.4 `68cbf45` (1,806), S9.5 `343e9c5` (1,808), S9.6
`f49057b` (1,815), S9.7 `c4815b2` (1,816), S9.8 `01608e2` (1,823), S9.9 `0a0c95e` (1,825); S9.3 is
documentation only.

**Fresh evidence (this validation; one temporary test file, run on Flutter 3.47.4, then deleted;
nothing committed to `lib/` or `test/`):**

| Probe | What it establishes | Result |
| --- | --- | --- |
| P1 | Library targets: a swipe on M31 opens "Delete this target?", Cancel returns the row; the target editor's Delete confirms, deletes, says "Target deleted" and the row goes. Library sites: a swipe on a site opens "Delete this site?", Cancel returns the row and both sites remain | **PASS** |
| P2 | Settings with an 80 % cloud forecast: the cloud gate switched on (50 %) cuts the usable time the ViewModel computes from 6 h 30 min to 0; its threshold dragged to 100 % restores 6 h 30 min | **PASS** |
| P3 | Weather with cloud unknown on odd UTC hours: 15 hours shown (dew icons 7 even, 8 odd), 7 cloud bars, one per known value; unknown hours draw no bar | **PASS** |
| P4 | Night & Moon at 70° N on 21 June (the Sun never sets): the timeline section and its table show, no twilight bar | **PASS** |
| P5 | Night & Moon at 59.9° N on 21 June (no astronomical darkness): the bar shows bands of depth 1, 2, 1 only; no astronomical or dark band | **PASS** |

The rig's choose mode (S9.1 acceptance 2) needs no probe: the host E2E (`core_loop_test.dart`,
`chooseTargetAndRig`) chooses the rig from `/select/rig` ("Choose a rig") and continues with it, in
the reused gate.

| Frozen item | Judgment | Evidence |
| --- | --- | --- |
| C: scope and exit | **PASS** (exit pending the owner) | Each area maps to a Task below; sources: About keeps every credit it had at `b378f16` (OpenNGC notice, OSM with Nominatim, Open-Meteo CC BY 4.0, lightpollutionmap.app) and turns each into a link; `COMPLIANCE.md` notes the change, and nothing new leaves the device. Tonight's rows open their details (`detail_screens_test.dart`, "Tonight's Night, Moon and Weather rows open the details"); no "Draft" or "Analytics" string in `lib/presentation`. No feature beyond the plan's items (steppers for the overheads, a twilight bar, cloud bars, the author block, the Library's modes). Share and export: no schema or manifest change, no image card (TD-091 for the export's share text). The exit needs S9.10–S9.12 decided or deferred by the owner. |
| R: Task rules | **PASS** | `lib/domain` and `lib/data/database` untouched between `b378f16` and `0a0c95e`; the data layer changed only two file-name helpers. Writes: target and site saves, deletes, site selection, Plan this target, every setting, Back up, preparing and cancelling a restore, exports and renames go through `runWithFeedback`. Deletes: rigs and targets (editor Delete + swipe), sites (row Delete + swipe), all `confirmDestructive`. Sweep: `/select/rig|target|site` added, Settings with every gate and overhead on. E2E: `siteEditor.save`, "Choose a target", "Choose a rig". Retired terms: empty. One Task per commit, each with `FEATURE_STATUS`, `ARCHITECTURE` Part B, `DESIGN_SYSTEM`/`TECH_DEBT`/`COMPLIANCE` where it applied, and `PROGRESS`. |
| T1: S9.1 | **PASS** | `ListMode` on the three lists; the Library routes pass `manage`, `/select/…` default to `choose` (`app_router.dart`). `library_manage_mode_test.dart` (6): a rig tap opens "Edit rig", the plan keeps its rig; a target tap opens "Edit target", the plan keeps M42, Plan this target asks (Save · Discard · Cancel) and starts a plan with M31; a site tap never changes the active site, `/select/site` does; `/select/target` chooses; a rig's cancelled swipe returns the row and the editor's Delete deletes. Target and site delete paths beyond these: P1 (TD-089). TD-053 resolved; the sweep lists the three lists in both modes. |
| T2: S9.2 | **PASS** | `retired_terms_test.dart`: `baseline` is empty and a test requires it. `secondary_forms_test.dart` (3): "Add rig" / "Add a target" / "Edit site", one `FilledButton` Save each, no `ElevatedButton`, no app-bar Save. Existing editor tests changed only labels and finders ("Save Changes" → "Save", "Target Name *" → "Name *", tooltip → `siteEditor.save`); no expected value changed. `equipment_editor_fit_test.dart` and the sweep in the gate. |
| T3: S9.3 | **PASS** | `research/S9.3_SETTINGS.md` §3: a row for every setting in the verified inputs (minimum altitude, darkness limit, dew margin, NPF k, margin, time between frames, the five overheads, field mode, place names, Backup/Restore, About) plus the two gates, each with class, effect, unit/range/default and placement; sources in §5 (N.I.N.A., PHD2, CALC-17, the twilight definitions, ADR-013/009). Placements in E.1 D9-3. |
| T4: S9.4 | **PASS** | `settings_rebuilt_test.dart` (5): sections in order; the Moon gate on and at 0 % shrinks the usable time, both gates persist; 120 s reached; dither steppers persist, change the budget's window load and stop at the floor; a broken store shows "Couldn't save the setting". The cloud gate's threshold → opportunity: P2 (TD-089). `backup_section_test.dart`: Restore through `confirm.action`. Defaults and toggle-on values identical to `b378f16`; ranges are `PlanningPreferences`'. Title "Settings"; `Tracked` absent. TD-050 resolved; the sweep opens Settings with every section and value. |
| T5: S9.5 | **PASS** | `about_screen_test.dart`: the author card first ("Made by Buffur", Reddit as the only `FilledButton`, GitHub, the version) and a link button in each of the four source entries; the old credits still asserted. `AppIdentity` unchanged (source, project, policy). `pubspec.yaml` description replaced. `COMPLIANCE.md` banner; the privacy policy unchanged (nothing new leaves the device). The displayed name: note N2. |
| T6: S9.6 | **PASS** | Night & Moon: the summary (dark span, then the Moon's up-times) first, then the twilight bar above the unchanged table (its text alternative; the bar is `ExcludeSemantics`), then the Moon's illumination and closest approach. `TwilightBands` maps `NightTimeline`'s crossings to bands and computes nothing from the Sun (`twilight_bands_test.dart`, 5, including the calculator's real night). Weather: a cloud bar under each hour's number, `ExcludeSemantics`, nothing for an unknown value; dew risk also an icon with a semantic label; no "Tap to set location". Widget tests cover the available states; the unknown and empty states: P3–P5 (TD-089). The sweep opens both details with a full forecast. |
| T7: S9.7 | **PASS** | `sky_darkness_context_test.dart`: known (Bortle and SQM, each value then "Source: … · Sep 23, 2026"), partly known (SQM only, no Bortle reading, "Bortle ?"), unknown ("Unknown — pick a Bortle class above, …"); `find.textContaining('2026-0')` finds nothing. No `toIso8601String` left in `lib/presentation`; the site editor uses the same `recordedDate`. No conversion or inference added. |
| T8: S9.8 | **PASS** | New messages tested: rig, target, site saved; rig and site deleted; name saved and removed; export created (entry, and Export all through the new `logbook.menu`); backup created; restore ready and cancelled. "Target deleted": P1 (TD-089). `app_messages_test.dart`: `showSnackBar` only in `app_messages.dart`; under `disableAnimations` the message is in place at once, otherwise it slides (TD-081 resolved). `file_names_test.dart` (3). The E2E's labels unchanged by S9.8. The export's share text: TD-091. |
| T9: S9.9 | **PASS** | `secondary_consistency_test.dart`: no hand-built `TextStyle(` and no numeric `EdgeInsets` in the thirteen secondary files (stricter than the frozen "`fontSize:`"; the annotation records it), with a self-test. The S9.9 commit replaces styles and insets only (bold `TextStyle`s → `titleSmall`, radii → `AppRadius.large`, "Saved sites" gains header semantics); no text changed. The sweep in the gate (three themes, 100 % and 200 %). |
| G: owner gates | **PASS** (prepared; awaiting the owner) | S9.10: where the icon appears, five execution problems, four alternatives A–D as SVG previews checked against the safe zone, a dedicated themed layer, a splash proposal that never delays startup; "the owner chooses". S9.11: sources are the GPL FAQ, the OSD, the CC BY-SA 4.0 legal code and the PolyForm texts; options G, N, S, P with their consequences (earlier copies stay GPL, every copyright holder, the catalog, the dependencies, the store); "not legal advice", no licence chosen or text written. S9.12: options C, B, B′, what each changes before the first upload, which URLs resolve (TD-088). `git diff --stat b378f16 HEAD -- android tool LICENSE lib/core/config/app_identity.dart docs/privacy assets` is empty. |
| D: decisions | **PASS** | D9-1: T1 (and TD-090 for the Library's other site actions). D9-2: T1 and R (site Delete placement: note N1). D9-3: T3, T4. D9-4: T5. D9-5: T8; Settings shows no success message. D9-6: TD-074 untouched. RD-07 (ADR-019 §8): manage vs choose, Plan this target, Add from a photo in both modes, Progress already in the Logbook. RD-09: confirmation for stored records and Restore; Undo only inside the plan. RD-11: the gates in Settings. |
| S: shared rules | **PASS** | `screens/home` and `screens/tonight` untouched; shared widgets changed only for the sections Stage 9 owns (sky darkness, the weather card, the Night & Moon sections) and for the app-wide message rule (TD-081: `blocks_undo.dart` and three other callers now use `showMessage`). The bars draw domain output with text alternatives; unknown draws nothing (P3). Cloud bars are neutral (`muted`), no weather score; dew risk not by colour alone. Twilight shading lerps between two palette tokens (red/black in field mode by the palette test). Messages honour reduced motion. Science untouched. |
| I: invariants | **PASS** | Trap 12: the token tests in the gate. 13: values from ViewModels and `QuantityText`; new helpers (`TwilightBands`, `recordedDate`, file stamps) are formatting or arrangement. 15: `showFailure` and `FailureText`, no raw error. 17, 18, 19: under R. 20: no icon file changed. 22: links open only on tap; privacy documents unchanged and not needed. |
| E: evidence | **PASS** | Every code Task recorded a full gate after its last code change; the gate at `0a0c95e` is reused (above). No device or real-sample evidence is required by this Stage. |

## Findings

### S9V-01 / TD-089 — Four acceptance checks are established here, not by committed tests

**FOLLOW-UP** (coverage only; the behaviour passes, P1–P5; the same pattern as TD-087):
- S9.4 acceptance 1 says a widget test turns **each** gate on, sets its threshold and sees the
  opportunity change; the committed test does this for the Moon gate only; the cloud gate is switched
  on and persisted with no forecast, so nothing can change (P2 supplies it);
- S9.6 asks for widget tests of the unknown and empty states: the widget tests cover the available
  states; the empty night is covered only by the pure `TwilightBands` tests, and an hour with unknown
  cloud by nothing (P3–P5 supply them);
- S9.1 acceptance 4 is tested for rigs and for a site's visible Delete, not for a target's Delete and
  swipe or a site's cancelled swipe (P1);
- S9.8's "Target deleted" message is untested (P1).

Direction: commit P1–P5-shaped tests in a later Task that touches these screens.

### S9V-02 / TD-090 — The Library's Sites still has actions that change the active site

**FOLLOW-UP / DEFERRED (implementation decision)** (not V4 A: S9.1's acceptance, "tapping … a site
in the Library opens its editor and leaves … the active site unchanged", is met and tested; not B:
these actions behaved the same before Stage 9; not C: no data lost).

In manage mode, "Use current position" and "Pick on map" set a transient position, which deselects
the active site (`SiteViewModel.setLocation`), and "Add site" makes the new site active (`saveSite`,
TASK 7.3's rule). D9-1 says the active site is chosen "only where a site is chosen for planning …
never by browsing"; these are explicit actions rather than browsing, but nothing on the Library's
screen says they change the site used for planning.

Direction: keep them there and say what they change, or offer them only when choosing, with adding a
site in manage mode leaving the active site as it is.

### S9V-03 / TD-091 — An export's share text does not state its file stamp's zone

**FOLLOW-UP** (not in S9.8's acceptance, whose file-name tests pass). S9.8's scope asks for local
file stamps "the stamp's zone stated in the share text". The backup does ("(UTC+hh:mm)"); the
Logbook and entry exports reuse `ShareSessionExporter.summary`, which does not. The manifest inside
records `exportedAtUtc`, so nothing is ambiguous in the data.

### Notes on the implementer's annotations (not findings)

- **N1 — S9.1: the site's visible Delete sits in the row, not the editor.** D9-2 (delegated) says
  "a visible Delete in their editor"; RD-09 (the owner's) says "where a visible Delete sits is decided
  at adoption", and S1 (a visible Delete plus a swipe) is met. Faithful to the owner's decision;
  **DEFERRED / IMPLEMENTATION DECISION**. D9-2's own wording was not amended in E.1. The dropped "refusal
  for a rig in use" clause is a faithful correction: `deleteEquipment`, `deleteTarget` and
  `deleteLocation` refuse nothing (saved plans keep their snapshots, ADR-014 §4). The Library tiles'
  descriptions instead of counts are an implementation decision outside the acceptance.
- **N2 — S9.5: the author is shown as "Buffur".** The frozen scope says "the author's name as the
  git history records it"; the history records "ChaCha12" (most commits) and "Serhii Zhovtyi". The
  implementer used the owner's public handle from 08 §23, the same as the profile links, and did not
  pick between the two names. The acceptance (author block, both links) is met. **OWNER DECISION
  (optional):** confirm the displayed name, perhaps with RD-01 (S9.12).
- **N3 — S9.9: the test is stricter than frozen** (every hand-built `TextStyle(`, not only
  `fontSize:`). Faithful.

TD-088 (the source and privacy-policy links answer 404) predates Stage 9 (TASK 16.3), was not caused
or worsened by it (S9.5 left the links unchanged, as the scope requires), and waits for RD-01; it
blocks a store upload, not this Stage.

## Handoff

**S9.1–S9.9 PASS** (V7 for the built part): every frozen item passes and no V4 blocker remains.
**Stage 9 stays open** until the owner decides or defers S9.10 (the logo), S9.11 (RG-12, the
licence) and S9.12 (RD-01, the identity; TD-088); each decision then gets its implementing Task,
validated at its own V1 class (V5: only the new Task's criteria and regression surface; S9.1–S9.9
keep their PASS). If the owner defers all three, Stage 9 closes on this report. S9V-01 to S9V-03
are recorded as TD-089 to TD-091 and create no Stage 9 requirement. No push (RD-17).

Probes: one temporary test file (`test/presentation/zz_s9v_probe_test.dart`, P1–P5) was run and
deleted; no mutation. `git status` was clean afterwards and the code diff against `0a0c95e` empty.
Documentation checks: referenced files and IDs resolve; `git diff --check`.
