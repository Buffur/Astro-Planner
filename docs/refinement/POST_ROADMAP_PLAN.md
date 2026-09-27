# AstroPlan — Post-Roadmap Refinement Plan

> **Status:** the active strategic plan for post-roadmap refinement, set by **Stage 0 —
> Refinement Baseline** on 2026-09-25. Changing a Stage's definition, the Stage order or a
> gate needs the owner's approval. Each Stage's planning session turns its candidate work
> into an approved, frozen Task sequence (§9.1). **This is not a complete task list.**
> **Authority:** the owner's Stage 0 prompt
> (`docs/refinement/prompts/STAGE_0_REFINEMENT_BASELINE.md`) and the post-roadmap governance
> in `CLAUDE.md`.
> **Verified against:** `main` @ `becae04`. The quality gate was re-run for Stage 0 on
> 2026-09-25 and passed (§1.1).
> **Read with:** `PRODUCT_DIRECTION.md` (what and why) and `PROGRESS.md` (where things stand).
> **Updated 2026-09-25 (Stage 1 planning, verified at `652ad80`):** Stage 1's Task sequence is
> frozen (§5, "Stage 1 — frozen Task sequence"); RD-03 resolved; the RD-05 interim decided;
> RD-17 included in Stage 1. No other Stage changed.
> **Updated 2026-09-26 (Stage 3, second planning pass, verified at `0c4848b`):** S3.R1 done
> (`research/RG-02_EQUIPMENT_IDENTITY.md`); the refined Stage 3 sequence S3.1–S3.9 is provisional
> until S3.D (owner decisions D1–D4, ADR-018). No other Stage changed.
> **Updated 2026-09-26 (S3.D):** the owner decided D1–D4 (each the recommended option); ADR-018
> accepted; RG-02 decided; RG-03 deferred; RD-16 resolved; S3.1–S3.8 frozen ("Stage 3 — frozen
> Task sequence").
> **Updated 2026-09-27 (Stage 3 final sign-off, verified at `92ebf2a`):** Stage 3 passed its
> fresh-session sign-off and is closed; Stage 4 planning is next. No Stage definition changed.
> **Updated 2026-09-27 (Stage 4 planning, verified at `126d97f`):** Stage 4's Task sequence is
> frozen ("Stage 4 — frozen Task sequence"): S4.R1–S4.R5, S4.D, S4.T, and the optional S4.E. No
> other Stage changed.
> **Updated 2026-09-27 (S4.R2):** RG-04 decided (E.1); S4.R1 and S4.R2 done.
> **Updated 2026-09-27 (S4.R3):** RD-05 and RD-04 decided (E.1); S4.R3 done.
> **Updated 2026-09-27 (S4.R4):** RG-05, RD-06 and RG-06 decided (E.1); S4.R4 done.
> **Updated 2026-09-27 (S4.R5):** RD-07 and RD-14 decided (E.1); S4.R5 done. Every Stage 4 gate
> is decided.
> **Updated 2026-09-27 (S4.D):** ADR-019 accepted; `docs/IA_WIREFRAMES_ADDENDUM.md` added; S4.D done.
> **Updated 2026-09-27 (S4.T):** provisional Tasks from ADR-019 added to Stages 5–9 (not frozen);
> §6.2 rows updated. Every Stage 4 Task is done; Stage 4 awaits its fresh-session validation.

## Contents

1. Baseline at Stage 0
2. Evidence base and how to weigh it
3. Stage overview
4. Dependency order
5. Stage definitions (Stages 0–11)
6. Traceability: audit findings → Stages
7. Research gate register (RG)
8. Owner decision register (RD)
9. Workflow rules
10. Relationship to historical documents
- Appendix A — Manual dogfooding report (08) → Stages
- Appendix B — Carried roadmap work
- Appendix C — Findings rejected or accepted as documented

**Identifiers.**
- **Stage N** (S0–S11) is a refinement Stage.
- **RG-##** is a research gate; **RD-##** is an owner decision raised by refinement. Both are
  stable and never renumbered. A resolved RG or RD keeps its ID and records the outcome, the
  date, and where the decision is written (an ADR or entry in `DECISIONS.md`).
- **ENG-##, SCI-##, RT-##, UX-##** are findings in `docs/audit/02`–`05`, as judged by
  `docs/audit/06_COUNTER_AUDIT.md`. **"08 §N"** is a section of
  `docs/audit/08_MANUAL_DOGFOODING.md`.
- The existing IDs (F-, TD-, SI-, CALC-, PD-, OD-, ADR-, DEV-) keep their meaning.

---

## 1. Baseline at Stage 0

### 1.1 Verified state (2026-09-25)

| Area | State |
| --- | --- |
| Code | `main` @ `becae04` (TASK 16.3 documentation, 2026-09-24). No commit since, and no change under `lib/`, `test/`, `integration_test/`, `tool/`, `android/` or `pubspec.yaml`. Audits 01–07 were captured against `becae04` |
| Quality gate | `dart run tool/check.dart`, re-run for Stage 0 on 2026-09-25: Encoding, Format and Analyze (no issues) pass; Test: 896 passed; E2E on the host: 2 passed. **Passed** |
| Schema | v17 |
| Android build | A debug APK and a release AAB build (the AAB is 66.5 MB, three ABIs, debug-signed because no upload key exists; TASK 16.2) |
| Roadmap | Tasks 0.1–16.3 are implemented or decided, except 10.5 (cut by the owner). **Open:** 15.4 (device rows), 15.5 (emulator run), 16.2 (signed bundle: owner's upload key) and 16.3 (policy URL live, contact email, Data Safety: owner). **Not started:** 16.4, 16.5 and G17 (17.1–17.3). Final Audit: no task is broken; confirmed defects are Low or Medium (07, "Answer in brief") |
| Device and human evidence | No `TEST_PLAN.md` device row is recorded as run. The owner's dogfooding report (08) describes hands-on use; see §1.3 item 2 |
| Metadata | A **gated prototype** exists: F-45 (Prototype); `lib/domain/services/metadata_extractor.dart` does file I/O and EXIF parsing in the domain; `metadata_import_screen.dart` uses `image_picker`; `FeatureScope.metadataImport = false`; TD-018 is open. It is **not** the production-ready metadata foundation (Stage 2) |

### 1.2 Open items carried from the roadmap

See Appendix B. In short: device and owner checks (12.4, 12.5, 15.2–15.5, 16.1), release
steps (16.2, 16.3, 16.4, 16.5), G17 (split between Stages 2, 3 and 8), and process gaps: CI
has never run, and there is no M3 go/no-go record.

### 1.3 Discrepancies found at Stage 0 (prompt or documents vs repository evidence)

Recorded rather than silently resolved:

1. **Prompt location.** The owner named `docs/refinement/prompts/STAGE_0_REFINEMENT_BASELINE.md`.
   The file existed only as the untracked `docs/STAGE_0_REFINEMENT_BASELINE.md`. It was moved,
   unchanged, to the named path and committed as Stage 0's scope record.
2. **Device and human use.** `CLAUDE.md` ("never installed or run on an Android device"),
   07 ("no human has used the current build") and `TEST_PLAN.md` ("no device row has been
   run") conflict with 08. 08 reports lag when tapping text fields, keyboard delays and an
   installed size of about 277 MB. 05 §1.2 also notes Android screenshots of an older build
   (old package id, dated 2026-09-21) on the development machine. So manual installs have
   happened, but **none is recorded**: build type, device, commit and date are unknown, and
   every acceptance that needs device evidence is still unmet. The `CLAUDE.md` wording is
   the owner's to confirm (Stage 1, B5).
3. **Project identity.** The application id `io.github.chacha12.astroplanner`, the source
   and privacy-policy URLs on `chacha12` and the user agent follow the local git user
   `ChaCha12` (OD-07 asked the owner to confirm the account before the first upload). The
   remote is `github.com/Buffur/Astro-Planner`, and the owner's links in 08 §23 are
   `github.com/Buffur`. See RD-01; the application id is permanent once published.
4. **Licence.** PD-12 confirmed GPL-3.0 on 2026-09-24. The owner's later requirements in 08
   §23 are no monetisation and no modification without the author's permission. GPL-3.0
   lets recipients modify and redistribute the software, including for a fee, so it does not
   provide those restrictions by itself. See RG-12: no licence change happens before that
   research and an owner decision (this is not legal advice).
5. **Metadata.** The prompt says extraction "is not yet implemented as the new
   production-ready metadata foundation". This agrees with the repository: a gated,
   non-production prototype exists (§1.1). Stage 2 decides whether to evolve or replace it.
6. **Catalog search.** 08 §4 and §9 ask for search by common name. The target search already
   matches the catalog id and the common name by substring ("Andromeda" finds M31). The gaps:
   97 of 164 catalog objects have no common name in the OpenNGC-derived asset; OpenNGC
   designations (for example NGC numbers of Messier objects) are not stored on the target, so
   they cannot be searched; there are no suggestions; and the catalog holds 164 objects. See
   RG-07.
7. **Storage estimate.** 08 §17 says storage "does not appear to be calculated". By design it
   shows "Unknown" when the rig's average RAW file size is unknown (03 C-13, SI-008), and the
   seeded rig has none (C-18). This is not a formula defect. See Stages 3, 6 and 7.
8. **Light-pollution map.** The external map is `lightpollutionmap.info` (PD-05 option A,
   credited on the About screen). 08 §13 asks for `lightpollutionmap.app`. See RG-09.
9. **"Only ZWO".** 08 §11 notes only a ZWO rig is offered. That follows TASK 8.5's owner
   decision to ship only the verified seed (the phone seeds were dropped because their makers
   publish only megapixels, f-number and a 35 mm-equivalent focal length). See RG-03.
10. **Site fields.** No calculation reads elevation, Bortle or SQM (only models and the
    snapshot builder mention them). This answers part of 08 §6. See RG-08 and RG-09.
11. **Documentation drift noticed while reading** (to re-verify in Stage 1, B5):
    - `FEATURE_STATUS.md`'s summary rows disagree with their sections (F-46 "Prototype"
      against Implemented; F-49 "Missing" against Partial);
    - F-50 still names `com.astroplan.astroplan`;
    - `PROJECT_HANDOFF.md`'s header and §0 still name `MASTER_ROADMAP.md` as the scope.
12. **Placement of the database recovery UX.** 07 §9 placed the below-floor/newer-database
    reset path "post-roadmap". The owner's Stage 0 prompt puts it in Stage 1, so this plan
    follows the prompt (Stage 1, A6).
13. **Audit ordering.** 06 and 07 were finished after 08 was written, and neither references
    it. 08 is therefore mapped independently (Appendix A).

---

## 2. Evidence base and how to weigh it

| Source | Nature | How to use it |
| --- | --- | --- |
| `docs/audit/01`–`05` | AI audit stages: roadmap compliance, engineering, scientific, runtime, UI/UX (2026-09-24/25, at `becae04`) | Structured technical evidence. Their classifications are inputs, not verdicts |
| `docs/audit/06_COUNTER_AUDIT.md` | AI adversarial re-check of 01–05 | Settles disputes between 01–05. **A finding 06 rejected is not revived** unless new repository evidence proves it (Appendix C) |
| `docs/audit/07_FINAL_AUDIT.md` | Synthesis of 01–06 | Its confirmed issues (§2, §3, §4.1) feed Stage 1. Its priority map (§9) and refinement candidates (§10) are recommendations and hypotheses, not decisions |
| `docs/audit/08_MANUAL_DOGFOODING.md` | The owner's hands-on report | Distinct evidence. Appendix A separates **human observation, author/product intent, proposed solution, research question and preference**. Proposed solutions are not approved architecture, and no observation may be lost because the AI audits did not mention it |
| Source-of-truth documents | Living registers and ADRs | Current state and accepted decisions. The audits are snapshots and are never edited |

**Limits of the evidence** (06 §D): no Android device or emulator run, no TalkBack walkthrough,
no darkness test, no user study; the audit probes were deleted after their runs. Every
finding is re-verified before it is fixed (§9.7).

---

## 3. Stage overview

Stages run in order. A Stage starts after the previous one is closed, unless the owner approves
an overlap. Research gates may run earlier than their Stage (§4).

| Stage | Name | Primary kind | Gates and decisions | Depends on |
| --- | --- | --- | --- | --- |
| 0 | Refinement Baseline | Documentation | — | — |
| 1 | Verified Fixes & Clean Baseline | Implementation, low research | RD-03; optional RD-02, RD-05 (interim), RD-17 | 0 |
| 2 | Metadata Foundation | Implementation after a research gate | RG-01; RD-16 | 1 |
| 3 | Metadata → Equipment / Device Import | Research and architecture gate, then implementation | RG-02, RG-03 | 2 |
| 4 | Product Flow & Information Architecture | Product/UX analysis and owner decisions | RG-04 to RG-06; RD-04 to RD-07, RD-14 | 3 |
| 5 | Design System Foundation | Implementation | RD-09 | 4 |
| 6 | Core Planner Redesign | Implementation | RD-06, RD-10, RD-11; RD-08 before capture-plan work | 4, 5 |
| 7 | Data Entry & Automation | Research gates, then implementation | RG-07 to RG-11; RD-08 | 3, 5, 6 |
| 8 | Sessions / Execution / Actuals / Logbook | Implementation after Stage 4's decisions | RD-12, RD-13 | 4, 6 (2 for assisted actuals) |
| 9 | Secondary UX & Product Polish | Implementation, plus licence research | RG-12, RG-13; RD-01, RD-11 | 5 (and 4 for the Library) |
| 10 | Performance & Application Size | Measurement first, then optimisation | RD-02 (dependency) | 6–9 |
| 11 | Full Validation & Beta Readiness | Independent validation | RD-15; owner actions | 1–10 |

Current status of each Stage: `PROGRESS.md`.

---

## 4. Dependency order

The order is the owner's (Stage 0 prompt §11). The reasoning:

- **Stage 1 first.** Confirmed defects are fixed before structural work, so later Stages do not
  build on known-wrong outputs (such as a frozen forecast age) and later validation is not
  confounded by them.
- **Stages 2 and 3 before Stage 4.** Flow and IA decisions depend on which inputs can be
  automated reliably, equipment from metadata in particular. Metadata extraction and
  equipment identity mapping are different problems, so they are separate Stages, and Stage 3
  opens with a research and architecture gate.
- **Stage 4 before Stages 5–9.** Decide the flow and structure before building patterns into
  screens and redesigning them. No audit pattern (05 P0–P10, 07 §10) is preselected.
- **Stage 5 before Stage 6.** One reusable visual and interaction system instead of fixes
  screen by screen (08 §27, "Design System").
- **Stage 6 before Stages 7 and 8.** Planning is the primary job.
- **Research may run early.** Stage 7's gates shape the planner (RD-08 tracking, RG-10
  calibration, RG-11 capture parameters). Their research sessions may run during Stages 4–6,
  and RD-08 should be decided before Stage 6 reworks the capture plan. Implementation stays in
  its own Stage unless the owner moves it. In general, research may precede its implementation
  Stage; implementation never precedes its gate.
- **Stage 8 after the planning experience is stable** and after Stage 4 has decided Execution's
  role. Metadata-assisted actuals (the old 17.3) also need Stage 2.
- **Stage 10 measures after the main UI changes,** so optimisation is not wasted.
  Measurement-only work (for example, what the ~277 MB figure actually is) may run earlier.
- **Stage 11 is last and independent.**
- **Owner actions that block release, not refinement,** can happen at any time: RD-01 (the
  account behind the app identity), the upload key (16.2), publishing the privacy policy
  (16.3), and a device or emulator for testing.

---

## 5. Stage definitions

Each Stage lists its purpose, entry criteria, candidate work (refined and frozen in the
Stage's planning session), gates, what is out of scope, and exit criteria. "Candidate" means
*not yet approved as a Task*.

### Stage 0 — Refinement Baseline *(complete)*

- **Purpose:** set the new product direction; create the refinement source-of-truth documents;
  define the workflow rules. No application code changes.
- **Deliverables:** `PRODUCT_DIRECTION.md`, this plan and `PROGRESS.md`. The Stage 0 prompt is
  archived in `docs/refinement/prompts/`. The owner's post-roadmap `CLAUDE.md` governance and
  the audit reports 01–08 are committed with them.
- **Exit:** one documentation-only commit; `PROGRESS.md` shows Stage 0 complete and Stage 1
  next, not started.

### Stage 1 — Verified Fixes & Clean Baseline

- **Purpose:** resolve the surviving confirmed audit issues before structural feature and UX
  work. Primarily implementation; little research.
- **Entry:** Stage 0 committed. A Stage 1 planning session re-verifies every item against the
  current code (§9.7) and freezes the Task sequence with the owner.
- **Candidate work.** Each item cites its evidence; grouping into Tasks happens in planning.

**A. Confirmed engineering and runtime defects**

| # | Finding | Evidence | Notes |
| --- | --- | --- | --- |
| A1 | **ENG-01** (= SCI-01, RT-01): the forecast's age class and "Updated N min ago" are computed once at load. Nothing reloads on the clock, on resume or at the night rollover, and the frozen class is written into snapshots | 07 §2, §4.1; 04 P1 | Medium. ADR-012 §6 ("cached data is never presented as current"); freshness only through `WeatherFreshness`; snapshots stay versioned (ADR-014) |
| A2 | **ENG-02** (= RT-02): a catalog seed whose inserts failed is recorded as applied and never retried | 07 §2; 04 P2 | Add the missing seeder failure-path test |
| A3 | **ENG-03** (= RT-07): Open-Meteo requests carry no `AppIdentity.userAgent` | 07 §2; CLAUDE.md trap 22 | Nominatim and the OSM tiles already send it |
| A4 | **ENG-05** (= SCI-11, RT-06): a draft without a site takes the UTC calendar date as its night key | 07 §2; CLAUDE.md trap 2 | Low; it self-corrects once a site exists |
| A5 | **ENG-06** (with UX-19, durations): one duration is rounded in the planner and truncated elsewhere; `totalIntegrationTime` is dead | 07 §2 | Shared formatting (CLAUDE.md trap 13) |
| A6 | **TASK 3.2 / RT-03 / TD-047** (its UI half): a below-floor or newer database shows a generic error and a Retry that cannot succeed; there is no explanation and no reset path (`resetUnsupportedDatabaseFile` has no caller) | 07 §2, §4.1; 04 P5 | Build ADR-008's message and confirmed reset path (§2, §9). First verify Drift's `LazyDatabase` retry behaviour (06 §D.5) |
| A7 | **RT-05 / UX-12** (the UX half of ENG-09): an unsaved draft replaced by New or Duplicate becomes unreachable | 07 §4.1; 04 P4 | Mechanism confirmed; the fix depends on the draft model (RD-05, Stage 4). **Decision checkpoint:** Stage 1 planning asks the owner whether an interim safeguard is wanted now, or whether this waits for Stage 4 |

**B. Scientific wording and documentation (surviving)**

| # | Finding | Evidence | Notes |
| --- | --- | --- | --- |
| B1 | **SCI-02:** "Chance of precipitation" is shown for the hour itself, but Open-Meteo's value covers the preceding hour. CALC-32's statement is wrong | 07 §3; 06 §4 | UI label plus a CALC-32 correction |
| B2 | **SCI-06:** the candidates list says "fills N % of the frame" for a major axis ÷ short side ratio | 07 §3 | Reuse the planner's wording (`capability_text.dart`) |
| B3 | **SCI-03:** two definitions of "Moon up" (h₀ rise/set against topocentric altitude > 0°) differ by 5–10 min, and nothing says so | 07 §3; 04 P3 | Documentation, and wording if needed. No formula change outside `SCIENTIFIC_INTEGRITY.md` Part C |
| B4 | **SCI-09:** night-level Moon illumination is shown without its instant (mean solar midnight) | 07 §3 | Low value; optional |
| B5 | **SCI-10 and documentation drift:** `optical_calculator.dart` doc comments (NPF "not shown in the UI"; √N "signal improvement"); SI section statuses against the index (SI-001, 002, 003, 008, 009); CALC-07 lists a removed function; CALC-17 and CALC-28 say "not surfaced / not used"; DEV-P2 says "SNR" no longer appears in `lib/`; F-49, TD-046 and ROADMAP say "no remote"; `TEST_PLAN.md` L3 uses the old app id | 07 §3; 06 §2, §4 | Also re-verify the Stage 0 observations in §1.3 item 11, and the `CLAUDE.md` "never installed" wording (§1.3 item 2, the owner's file). `PROJECT_HANDOFF.md` is a living document: add a pointer to `docs/refinement/`. `ROADMAP.md` stays historical |
| B6 | **TASK 6.2 citation gap:** the tests of CALC-01, 02, 03 and 06 cite no source | 06 §2 (partially confirmed) | Citations only; the values are canonical constants |
| B7 | **RD-03 wording rulings:** the ISO/gain "Sensitivity setting" label (SCI-05); a resolution caveat for times on the 5-minute grid (SCI-04) | 07 §6 item 8 | The owner rules. SCI-05 may be superseded by RG-11 (Stage 7) |

**C. Visible, trust-eroding text and format defects**

| # | Finding | Evidence | Notes |
| --- | --- | --- | --- |
| C1 | **UX-20:** the session detail prints "f/5.555555555555555"; Settings says optional overheads are not applied yet (they are, since TASK 5.4); the candidates footer names a "Home" that does not exist; "Notes: Notes: none" | 07 §5.1; 06 §6 | 05 also lists a truncated helper in the add-block dialog and two Bortle entry points on the sky card: re-verify those |
| C2 | **UX-19**, format inconsistencies that do not depend on IA: RA in degrees in the session detail but h:m:s elsewhere; "60.0s" against "60 s"; ASCII against typographic minus; "3%" against "3 % lit" | 07 §5.1 | The chart's 24-hour axis goes with the chart work (Stage 6, UX-08) |
| C3 | **UX-16:** "Tight" is drawn weaker than "Fits" (the tertiary colour falls back to grey). **UX-15(2):** "No window" is shown in the error colour before a target is chosen | 07 §5.1, §9 | A minimal fix with existing tokens; systematic status tokens come in Stage 5 |
| C4 | **UX-18**, the IA-independent part: the session detail labels the noon-to-noon night key "Window", next to the imaging "Window 1" | 07 §5.1 | Names that depend on IA (rig or equipment; Sessions or Logbook) wait for RD-14 (Stage 4) |

**D. Accessibility**

| # | Finding | Evidence | Notes |
| --- | --- | --- | --- |
| D1 | **UX-31:** at 200 % text the weather hour strip overflows (a fixed 130 px box), and a label runs into its value | 07 §4.1; 05 U1 | CLAUDE.md trap 17 |
| D2 | **UX-32:** the accessibility sweep never renders a forecast | 07 §2 | The test blind spot that hid D1 |
| D3 | **UX-28**, verification first: the tracker's controls expose no tap action to accessibility services | 06 §6 (requires verification; high-confidence mechanism) | Verify with a host semantics test and fix if confirmed. TalkBack confirmation stays in Stage 11 |

**E. Test blind spots,** added with the fixes above where relevant: E1, a catalog-seeder
failure path (A2); E2, weather refresh on the clock, on resume and at rollover (A1); E3, a
failure-path test for `SharedPrefsPrivacyPreferencesRepository` (01 §G.7); E4, optional:
ENG-04's coverage caveat (most planner tests use the preferences path production does not
use); E5, optional: the G5 property tests (01, partially confirmed, low risk).

**F. Verification only:** ENG-08 / RT-04, Save and Start outside the autosave chain (reproduced
only with injected timing). A UI-driven test decides it; fix only if it reproduces.

**G. Baseline hygiene needing the owner (optional in Stage 1):** RD-02, the TASK 0.3 holdovers
(the ADK skill, `skills-lock.json`, `docs/archive/` retention; `sqlite3_flutter_libs` is
reviewed in Stage 10); RD-17, pushing the CI workflow and observing a first run (TASK 1.3),
subject to RD-01 and the repository's visibility.

- **Out of scope:** UX-01 to UX-11, UX-13, UX-17, UX-22, UX-25 and UX-29 (Stages 4 and 6–8);
  anything needing a product or data-model decision (drafts beyond an interim safeguard,
  defaults, tracking); new features; redesign; metadata.
- **Exit:** every A–D item is fixed with a regression test, or re-verified as already
  resolved or materially changed (and reported), or moved with the owner's approval. The
  quality gate is green. The living registers are updated with the audit ID (§9.9). Stage 1
  validation passes in a fresh session. `PROGRESS.md` is updated.

#### Stage 1 — frozen Task sequence (planning, 2026-09-25)

Frozen by the Stage 1 planning session at `main` @ `652ad80`. Every A–F candidate above was
re-verified against the code in that session (§9.7), and **each mechanism still exists as the
audits describe it**; none was stale. Owner decisions taken in planning (DECISIONS E.1,
"Stage 1 planning decisions"):
- **RD-03:** SCI-05, the ISO/gain field gets a neutral label now (S1.8); SCI-04, documentation
  only, with no UI and no formula change (S1.13).
- **RD-05, interim only:** confirm before an unsaved draft is replaced (S1.6). The draft model
  itself stays with Stage 4.
- **RD-17:** included in Stage 1 (S1.14).
- **`CLAUDE.md` wording** on device use: may be corrected in S1.15.
- **Not taken:** RD-02 stays open (Stage 10 for the dependency). E4 and E5 (optional test
  depth) are not Stage 1 Tasks; they stay optional, for Stage 11 or an owner request.

Findings added in planning, and placed in the Tasks below:
- `ARCHITECTURE.md:495,497` (the Part B external-services table) still gives the old user
  agent and `com.astroplan.astroplan` (S1.15);
- the comment on `resetUnsupportedDatabaseFile` still says it "creates a fresh v9 database"
  (S1.5);
- Tonight's "New session" button calls `newSession()` without `runWithFeedback`, against
  CLAUDE.md trap 18 (S1.6);
- opening a saved session from Sessions also replaces the current draft (`CurrentSession.adopt`),
  just like New and Duplicate (S1.6);
- a draft with no site takes the UTC date, and the default night itself moves on with the clock
  without notifying anything, so nothing reloads at rollover (S1.3, S1.4);
- in Drift 2.35.0, `LazyDatabase` keeps the opened `NativeDatabase` and the version refusal is
  thrown from that database's own `ensureOpen`. So every Retry reruns the refused upgrade, and a
  reset must close the database and rebuild the graph (answers 06 §D.5; S1.5);
- "No window" with no target or no site is `FitState.noWindow`, the same state as a real
  no-window night. Only the reason text differs (S1.9).

**Common validation for every Task:**
- targeted tests for the new behaviour, plus the affected regression tests;
- `dart run tool/check.dart` green. The baseline is 896 unit and widget tests plus 2 E2E tests
  on the host; the count only grows;
- each acceptance criterion checked explicitly;
- the living registers updated with the audit IDs (§9.9), with verification stamps refreshed;
- a `PROGRESS.md` row;
- one commit per Task, then STOP (never start the next Task automatically).

**Constraints across the Stage:**
- CLAUDE.md traps 2, 11–19 and 22;
- `SessionPlanViewModel` is at 299 of its 300-line cap (ENG-16). S1.4, S1.6 and S1.12 must
  stay under the cap, moving logic into the domain or a helper where needed, never raising the
  cap;
- no scientific formula changes;
- no schema change is expected in any Task. If one proves necessary, stop and report (§9.5).

| Task | Title | Items | Size | Depends on |
| --- | --- | --- | --- | --- |
| S1.1 | Open-Meteo user agent | A3 | S | — |
| S1.2 | Seeding and preference failure paths | A2, E1, E3 | S | — |
| S1.3 | Forecast freshness over time, resume and rollover | A1, E2 | M | — |
| S1.4 | Night key without a site | A4 | S | — |
| S1.5 | Unsupported-database recovery | A6 | M | — |
| S1.6 | Confirm before replacing an unsaved draft (interim) | A7 | M | S1.4 |
| S1.7 | One format for durations and numbers | A5, C2 | S–M | — |
| S1.8 | Visible text defects and labels | C1, C4, B2, B7 (SCI-05) | S | S1.7 |
| S1.9 | Fit status colours and the missing-input state | C3 | S | — |
| S1.10 | Weather strip at 200 % text; forecast in the sweep | D1, D2 | S | — |
| S1.11 | Tracker controls expose a tap action | D3 | S | — |
| S1.12 | Save/Start against the autosave chain | F | S | S1.6 |
| S1.13 | Scientific labels and documentation | B1, B3, B4, B6, B7 (SCI-04) | S | S1.10 |
| S1.14 | Push CI and observe a first run | RD-17 | S | S1.1–S1.13 |
| S1.15 | Documentation drift | B5, the new drift above | S | S1.14 (done or deferred) |

The order is the execution order. Tasks without a dependency may be reordered only with the
owner's approval.

**Added after validation (owner-approved 2026-09-25, "apply fixes for the remaining items to
complete Stage 1"):** S1.16 (commit hashes in the registers, V1) and S1.17 (the field theme in
the unsaved-changes dialog's accessibility check, V2) from the same-session review; S1.V1–S1.V4
(TD-059–TD-062) from the independent validation, defined with their acceptance in
`STAGE_1_VALIDATION.md`. V3 goes to RD-05. A repeat independent validation follows S1.V4.

**Stage 1 closed by the owner, 2026-09-26 (DECISIONS E.1, "Stage 1 closed by the owner").** The
repeat independent validation (`STAGE_1_REVALIDATION.md`, `39392d9`) did not pass: TD-063 and
X2 survived. The owner waived the exit criterion and moved on. TD-063 goes to Stage 8. X2 (the
proposed S1.V6, documentation only) stays open for an owner request or Stage 11. W1 stays a
proposed input to RD-05. The proposed S1.V5 was not run.

##### S1.1 — Open-Meteo user agent (A3; ENG-03, RT-07)
- **Objective:** every Open-Meteo request carries `AppIdentity.userAgent` (CLAUDE.md trap 22).
- **Scope:** `open_meteo_weather_repository.dart` (and its client construction in `main.dart`
  if needed); a `MockClient` test asserting the header.
- **Out of scope:** other providers (they already send it); `docs/privacy` (no new data leaves
  the device; the header is identification only). Re-check `docs/COMPLIANCE.md` and update its
  Open-Meteo row if it describes the headers.
- **Acceptance:** a test fails without the header; forecast parsing is unchanged; TD/F entries
  cite ENG-03.

##### S1.2 — Seeding and preference failure paths (A2, E1, E3; ENG-02, RT-02)
- **Objective:** a catalog seed whose inserts fail is not recorded as applied and is retried on
  the next launch; the privacy preferences repository has its failure-path test.
- **Scope:** `CatalogSeeder`: tell the expected duplicate (the unique index, "already
  present") apart from a `StorageFailure`, and do not store the version when any insert failed
  for another reason (or fail the seed as a whole). Check `EquipmentSeeder` for the same
  pattern and apply the same rule if it is present. Correct the `main.dart` comment if it
  still over-claims. Add `SharedPrefsPrivacyPreferencesRepository` to `storage_failure_test.dart`.
- **Out of scope:** wrapping seeding in one transaction (ENG-12 performance, Stage 10);
  changing the catalog asset.
- **Acceptance:** a test reproduces 04/P2 (every insert throws `StorageFailure`) and shows the
  version unset and a second run inserting everything; a duplicate insert still counts as
  success; an upgrade seed (`since` entries) follows the same rule; the E3 test fails on an
  unguarded read or write.

##### S1.3 — Forecast freshness over time, resume and rollover (A1, E2; ENG-01, SCI-01, RT-01)
- **Objective:** the forecast's age class and "Updated N ago" follow the injected clock; the
  forecast is reloaded on app resume when it is no longer current, and follows the default
  night when it rolls over; a saved snapshot records the age at the time of saving (ADR-012 §6).
- **Scope:** the presentation state for the forecast (`NightConditionsViewModel`,
  `NightWeatherService` or the `NightWeather` model as the design requires); a testable
  re-evaluation trigger driven by the `Clock` (for example a periodic tick in the presentation
  layer, never `DateTime.now()` in the domain); an app-lifecycle resume hook; rollover
  detection for the default night (the planner's night must notify when it changes); the age
  passed to `SessionSnapshotBuilder` computed at save time.
- **Out of scope:** new freshness thresholds (still `WeatherFreshness`); changing the cache
  policy or the provider; the tracker's own tick.
- **Constraints:** freshness only through `WeatherFreshness` (CLAUDE.md's weather rules; ADR-012
  §6; no ad-hoc age check); memoization keys (trap 16): every cache that depends on the forecast state must
  invalidate when the age class changes; an in-flight load for an old night is still dropped.
- **Acceptance:** the 04/P1 probe steps become tests with a fake clock: 5 h after load the class
  is `aging` and the text is updated without any input change; after resume past a threshold a
  reload happens; after the night rolls over, the forecast covers the new night; a snapshot
  saved 5 h after load records `aging`, not `current`; no periodic work runs once the
  ViewModel is disposed.

##### S1.4 — Night key without a site (A4; ENG-05, SCI-11, RT-06)
- **Correction (owner, 2026-09-25, during S1.4):** the device-zone rule below conflicts with
  ADR-007 §6 ("the device zone is never used in computation"; PD-02(a) rejected). The owner
  chose instead: without a site, the key is the **default night at the default position**,
  resolved by `SessionNightResolver` like a site's (mean solar time), never from Y/M/D. Users
  far east of Greenwich can still get a day off in their morning until a site is set, and the
  key self-corrects then (DECISIONS E.1).
- **Objective (as planned, superseded by the correction):** without a site, the draft's night
  key is the evening date in the device's zone under the ADR-007 rules, never the UTC calendar
  date (trap 2).
- **Scope:** `SessionPlanViewModel.today` and the `_plan()` fallback, through `SessionNightResolver`
  or `CalendarDate` helpers with the device zone (`DeviceTimeZone` / `IanaTimeContext`); the
  "a past night rolls forward" comparison in `load()` uses the same date.
- **Out of scope:** changing the no-site state (ADR-007 §9: no astronomy without a site).
- **Acceptance:** the 04/P4 case (01:30 UTC, device in America/Los_Angeles, no site) stores
  2026-09-21; a site still overrides it; the VM stays under its line cap.

##### S1.5 — Unsupported-database recovery (A6; TASK 3.2, RT-03, TD-047)
- **Correction (during S1.5, 2026-09-25):** ADR-008 §2 says "newer databases are never
  reset". So the reset below is offered **only below the floor**; a newer database gets the
  explanation alone. The acceptance line on a `user_version` 18 file therefore checks that it
  is left unchanged and cannot be reset. Detection moved to before the graph is built
  (`main.dart` probes the database first), which also makes "rebuild the graph" a rerun of the
  bootstrap.
- **Objective:** a database below the floor or newer than the app shows ADR-008's explanation
  (§2, §9) instead of a generic error, and offers a confirmed reset that keeps the old file.
- **Scope:** the startup path (`main.dart`, `StartupViewModel`, the bootstrap error view on
  Tonight and the planner) recognises `UnsupportedSchemaVersionException` and says which case it
  is (newer: "made by a newer version of the app", with installing that version as the first
  remedy; older: below the supported floor). A reset after explicit confirmation calls
  `resetUnsupportedDatabaseFile` (the file is renamed to `.v<N>.bak`, never deleted), closes the
  open database, and rebuilds the app graph on a fresh file. Correct the function's comment
  ("fresh v9").
- **Out of scope:** exporting or migrating the refused file; a downgrade migration.
- **Constraints:** without confirmation nothing is touched (ADR-008); errors go through
  `AppLog`; a failed rename is reported, never swallowed (trap 15).
- **Acceptance:** host tests with a `user_version` 18 file and a below-floor file: the specific
  message; Cancel leaves the file byte-for-byte unchanged; Confirm leaves a `.bak` with the
  original bytes and a working empty database, with seeding done; a Retry that cannot succeed
  is no longer the only action; TD-047 resolved with the commit.

##### S1.6 — Confirm before replacing an unsaved draft (A7, interim; RT-05, UX-12, ENG-09 UX half)
- **Objective:** an action that switches the planner away from a draft with user changes asks
  first, so a plan is never silently made unreachable (IA_WIREFRAMES §3).
- **Scope:** New (the planner's "+" and Tonight's "New session"), Duplicate, and opening a
  session from Sessions. When the current session is a draft that differs from an untouched
  new draft (the example plan, never edited), or a saved plan with unsaved edits, show a
  confirmation ("Discard unsaved changes?" with Cancel, which returns to the planner where Save
  is, and Discard). The detection lives in the domain or the ViewModel, not the widget. Tonight's
  "New session" goes through `runWithFeedback` (trap 18).
- **Out of scope** (RD-05, Stage 4): listing, deleting or cleaning up drafts; changing what New
  or Duplicate create; schema changes. A discarded draft stays stored as today.
- **Acceptance:** widget tests: an untouched draft, no prompt; an edited draft, a prompt;
  Cancel changes nothing; Discard behaves as before; the same for Duplicate and Open; the E2E
  suite is updated if its flow meets the prompt (trap 19); the accessibility sweep covers the
  dialog; UX-12/RT-05 are recorded as mitigated (interim), still open for RD-05.

##### S1.7 — One format for durations and numbers (A5, C2; ENG-06, UX-19)
- **Objective:** a quantity reads the same wherever it appears.
- **Scope:** one shared duration formatter (one rounding rule, documented), used by the
  capture budget, the fit reason, the opportunity text and the session detail; remove the dead
  `totalIntegrationTime` (and its harness getter); exposure as "60 s" everywhere; RA/Dec in the
  session detail in the same h:m:s / d:m:s form as the target editor; the typographic minus in
  the session detail and Settings; percentages in one form ("3 % lit" style).
- **Out of scope:** the chart's 24-hour axis (Stage 6, UX-08); vocabulary (RD-14).
- **Acceptance:** unit tests for the formatter's boundaries (59 s, 59.5 min, whole hours); no
  second duration formatter remains in `lib/presentation` (grep); the widget tests assert the
  new strings; E2E keys unchanged.

##### S1.8 — Visible text defects and labels (C1, C4, B2, B7/SCI-05; UX-20, UX-18 part, SCI-06)
- **Objective:** remove the trust-eroding text defects.
- **Scope:**
  - the session detail's focal ratio formatted like the rig's (no raw double);
  - "Notes: none" not doubled;
  - Settings no longer says optional overheads are not applied;
  - the candidates footer describes what a tap does (sets the plan's target) without naming a
    "Home";
  - the add-block helper wraps instead of truncating;
  - the sky card's text consistent with its two existing Bortle entry points (no entry point
    removed; Stage 6/7);
  - the session detail's noon-to-noon night key no longer labelled "Window" (C4);
  - the candidates list says "% of the frame's short side" through `CapabilityText` (SCI-06);
  - the ISO/gain field labelled "ISO / gain (for your records)", its helper still "recorded
    only" (RD-03; SCIENTIFIC_INTEGRITY Part C rule 6; SI-004 note).
- **Out of scope:** rig/equipment and Sessions/Logbook naming (RD-14); the Bortle entry-point
  structure.
- **Acceptance:** a widget test per string; `SCIENTIFIC_INTEGRITY.md` records SCI-05 and SCI-06
  resolved; no remaining "sensitivity" wording for ISO or gain in `lib/presentation`.

##### S1.9 — Fit status colours and the missing-input state (C3; UX-16, UX-15(2))
- **Objective:** "Tight" is at least as prominent as "Fits" and reads as a caution; a fit that
  is missing an input (no site, no target) is neutral, not an error. A real no-window night stays
  an error.
- **Scope:** `FitText.color` and the colours it reads (a token in all three palettes if one is
  needed, trap 12); a way to tell a missing input from a real no-window (a `FitState` value or an
  equivalent flag from `CaptureAnalysisViewModel`, the smallest correct change), used by Tonight
  and the planner.
- **Out of scope:** the systematic status tokens (Stage 5); wording of the states.
- **Acceptance:** tests on the state for no site, no target and a real no-window; the colours
  differ as required in light and dark; field tokens stay red or black (tested); the
  accessibility sweep's contrast checks pass.

##### S1.10 — Weather strip at 200 % text; a forecast in the sweep (D1, D2; UX-31, UX-32)
- **Objective:** the forecast card has no overflow at 200 % text, and the accessibility sweep
  renders a forecast so it would catch one.
- **Scope:** `weather_forecast_widget.dart` (the fixed 130 px strip; the range label running into
  its value); the sweep's fake weather returns a full synthetic forecast for the planner and
  Tonight.
- **Out of scope:** redesigning the weather card (Stage 6, RD-06/UX-06).
- **Acceptance:** the sweep fails on the current code (demonstrated) and passes after the fix in
  the light, dark and field themes at 100 % and 200 %; no text in a fixed-height box (trap 17).

##### S1.11 — Tracker controls expose a tap action (D3; UX-28)
- **Objective:** each tracker control is activatable by accessibility services.
- **Scope:** a host semantics test asserting a tap action and a label on each of the seven
  controls; if it confirms the defect, fix the `Semantics` wrappers in `execution_screen.dart`.
- **Out of scope:** TalkBack on a device (Stage 11).
- **Acceptance:** the test fails before and passes after (or, if the mechanism does not
  reproduce, it is kept as a regression test and the finding is reported as not reproduced);
  existing label tests still pass; E2E keys unchanged.

##### S1.12 — Save/Start against the autosave chain (F; ENG-08, RT-04)
- **Objective:** decide ENG-08 with a UI-driven test, and fix it only if it reproduces.
- **Scope:** a widget test that edits the plan and taps Save (and Start) while the edit's
  autosave is pending, with no injected delay in the repository. If the older plan wins, queue
  Save and Start on the write chain, capturing the plan when their turn comes
  (`CurrentSession`, `SessionPlanViewModel`).
- **Out of scope:** a busy state on the Save button (Stage 5/6), unless the fix requires it.
- **Acceptance:** either the test shows no reproduction and is kept as a regression test, with
  ENG-08 recorded as not reproducible through the UI, or it fails before and passes after the
  fix; the lifecycle matrix and E2E suite still pass.

##### S1.13 — Scientific labels and documentation (B1, B3, B4, B6, B7/SCI-04)
- **Objective:** the surviving scientific wording and documentation issues are closed.
- **Scope:**
  - B1 (SCI-02): precipitation probability labelled as covering the preceding hour, and CALC-32
    corrected;
  - B3 (SCI-03): `SCIENTIFIC_INTEGRITY.md` states that the rise/set events (h₀) and the "Moon
    up" gate (topocentric altitude > 0°) differ by 5–10 min, and why; UI wording only if a
    displayed text claims they coincide;
  - B4 (SCI-09): night-level Moon illumination labelled as the value at midnight;
  - B6: sources cited in the tests of CALC-01, 02, 03 and 06;
  - SCI-04 (RD-03): the direction of the grid bias documented in SI-009 and CALC-08 as
    accepted.
- **Out of scope:** any formula change; a conservative edge rule; a UI resolution note.
- **Acceptance:** the SI and CALC entries are updated; the widget tests assert the labels; no
  numeric test changes.

##### S1.14 — Push CI and observe a first run (RD-17; TASK 1.3, F-49)
- **Deferred by the owner, 2026-09-25 (asked immediately before the push).** Checked then:
  `origin/main` = `a1bcbd9`, `main` 155 commits ahead as a fast-forward; the repository
  `github.com/Buffur/Astro-Planner` is **public** (HTTP 200 without credentials), so a push
  publishes every commit, the audit and refinement documents and the commit author email;
  no key, keystore or secret file is tracked; the workflow pins Flutter 3.47.4, the local
  version. Nothing was pushed. RD-17 stays open (Stage 11, or when the owner asks); S1.15
  records CI as not yet run.
- **Objective:** the quality-gate workflow runs on the remote, and its first result is recorded.
- **Scope:** confirm with the owner at execution time before any push (pushing publishes the
  history to `github.com/Buffur/Astro-Planner`), then push `main` and observe the workflow run.
  If the remote environment fails for an environment reason (for example the E2E step on the
  runner), fix the workflow within `.github/workflows/ci.yml` and `tool/check.dart` only.
- **Out of scope:** RD-01 (the account behind the app id); repository visibility; branch
  protection.
- **Acceptance:** a green run, with its URL and date recorded in F-49, TD-046 and `PROGRESS.md`,
  or a recorded failure with a follow-up Task proposal.

##### S1.15 — Documentation drift (B5; SCI-10 docs)
- **Objective:** the living documents match the code at the end of Stage 1.
- **Scope:**
  - `optical_calculator.dart` doc comments (NPF "not shown in the UI"; √N "signal
    improvement");
  - SI section statuses against the index (SI-001, 002, 003, 008, 009);
  - CALC-07 (the removed function);
  - CALC-17 and CALC-28 ("not surfaced / not used");
  - DEV-P2 ("SNR" appears only in negating comments);
  - F-49 and TD-046 (a remote exists; the S1.14 result);
  - the `FEATURE_STATUS.md` summary rows against their sections (F-46, F-49), and F-50's app
    id;
  - `TEST_PLAN.md` L3's app id;
  - `ARCHITECTURE.md:494,495,497` (494: the Open-Meteo row still names `icon_seamless` and
    `timezone=auto`; found in S1.1), and F-29's body (it still describes the removed legacy
    weather path);
  - `PROJECT_HANDOFF.md`'s header and §0, with a pointer to `docs/refinement/`;
  - the `CLAUDE.md` device-use wording ("never installed or run": manual installs have
    happened but none is recorded; owner-approved in planning).
- **Out of scope:** `ROADMAP.md`, `MASTER_ROADMAP.md`, `docs/audit/*`, `PROJECT_AUDIT.md` and
  `docs/archive/` (historical, §9.9).
- **Acceptance:** each listed item is corrected or recorded as intentionally unchanged; the
  encoding check passes; no application behaviour changes.

### Stage 2 — Metadata Foundation

- **Purpose:** build the production-ready metadata extraction layer, keeping the dependency
  logic of the old TASKs 17.1 (safe, bounded file access) and 17.2 (typed metadata and real
  samples).
- **Entry:** Stage 1 closed; RG-01 decided (formats, libraries, file selection; this resolves
  PD-21); **owner-supplied real sample files available** (17.2 requires them, and no
  copyrighted third-party files go into the repository).
- **Candidate work:**
  - safe file access in the data layer, behind a domain interface. Today
    `metadata_extractor.dart` does I/O in the domain (TD-018);
  - bounded, header-only parsing: FITS headers in 2,880-byte blocks up to `END`; bounded
    EXIF and TIFF-based RAW reads. Never read a whole file (today: `readAsBytes`);
  - the supported-format decision (RG-01). The old TASK 17.1 proposed JPEG, DNG and
    TIFF-based RAW where the library works, plus FITS, with XISF, CR3 and XMP deferred until
    samples verify them; RG-01 confirms or changes that;
  - selecting non-media files. `image_picker` cannot select FITS; `file_picker` 13.1.0 has
    been a dependency since TASK 14.4, and reusing it is part of RG-01;
  - typed metadata with units: exposure in seconds; ISO or gain with its kind; focal length
    in mm (nullable for manual lenses and telescopes); f-number (nullable); capture time with
    its offset when present, otherwise "zone unknown"; FITS `DATE-OBS` as UTC; the camera and
    instrument identifiers kept as raw strings with provenance, for Stage 3;
  - provenance and confidence per value (the ADR-008 §6 convention); unknowns explicit;
    never a default for a missing value;
  - fixtures: real owner samples per format; corrupted, truncated and missing-field cases;
    large-file memory and resource tests;
  - known prototype defects, such as a `/` inside a FITS string value truncating it (TD-018).
- **Owner decision:** RD-16, whether and where a user-visible entry point appears at the end
  of Stage 2 (the PD-06 gate), or whether the feature stays hidden until Stage 3.
- **Out of scope:** writing anything to Equipment; matching devices; assisted actuals; plate
  solving; image display; file management.
- **Exit:** the format decision is recorded; each supported format is parsed from a real
  sample; tests show bounded reads; I/O is out of the domain; unknowns are explicit; TD-018,
  F-45 and PD-21 are updated; Stage 2 validation passes.

#### Stage 2 — Task sequence (planning, 2026-09-26)

Planned at `main` @ `39392d9`, just after the owner closed Stage 1. The Stage's entry
conditions are **not yet met**: RG-01 is undecided, and no owner sample files exist. So only the
research Task S2.R1 is frozen. S2.1–S2.6 are **provisional**: S2.R1's decision confirms,
changes or removes them, and the owner freezes them then (§9.1 step 6).

**Verified at planning (§9.7):** every TD-018 mechanism still exists.
- `metadata_extractor.dart:11` reads the whole file (`readAsBytes`).
- `:14` and `:63` turn the bytes into a string, and the FITS path does this for the **whole
  file**.
- `:72` cuts every value at the first `/`, so quoted strings containing `/` are truncated.
- The import screen picks with `image_picker`'s `pickImage` (`metadata_import_screen.dart:24`),
  so FITS and RAW files cannot be chosen.
- File I/O (`dart:io`) and `package:exif` are imported by `lib/domain`.
- Every field of `ImageMetadata` is a `String?`.
- The extractor returns null both for "no metadata" and for "unreadable".
- F-45 is still Prototype, hidden (`FeatureScope.metadataImport == false`), and has no real
  sample.

Found in planning, placed in the Tasks below:
- The FITS parser treats any card containing `=` as a keyword (COMMENT and HISTORY text
  included), and ignores FITS quote escapes (`''`).
- The FITS parser maps `GAIN` into the `iso` field, conflating gain with ISO (SI-004's
  descriptive-only rule).
- EXIF `DateTimeOriginal` is kept without its offset tags, so the zone is silently unknown.
- `test/domain/services/metadata_extractor_test.dart` writes `test_dummy.fit` into the working
  directory, not a temporary one.
- `image_picker` is used only by the metadata screen, and `exif` only by the extractor. If
  RG-01 replaces them, both dependencies can go (Stage 10 relevance).
- `file_picker` 13.1.0 (TASK 14.4) is used by backup, which reads the whole picked file
  (`xFile.readAsBytes()`; a restore file is read whole on purpose).

**Common rules for every Task:**
- the workflow and validation of §9.4 and §9.8, one commit per Task, then STOP;
- nothing is written to Equipment, sessions or any other store (Stage 3 and Stage 8 own that);
- no metadata leaves the device;
- unknown stays unknown: no default values;
- the feature stays hidden unless RD-16 says otherwise;
- no copyrighted third-party file is committed, and no owner sample is committed without the
  owner's explicit consent to its contents (the remote is **public**, see S1.14): EXIF and FITS
  headers can hold GPS positions, serial numbers and names.

| Task | Title | Kind | Size | Depends on | State |
| --- | --- | --- | --- | --- | --- |
| S2.R1 | RG-01: formats, libraries, file selection, fixtures | Research (docs only) | M | — | **Done 2026-09-26**; decided the same day (ADR-017) |
| S2.1 | Bounded file access behind a domain interface | Implementation | M | S2.R1 decided | Provisional |
| S2.2 | Typed metadata with units, provenance and explicit unknowns | Implementation | M | S2.1 | Provisional |
| S2.3 | FITS header reader | Implementation | M | S2.2, FITS samples | Provisional |
| S2.4 | EXIF / TIFF-based RAW reader | Implementation | M | S2.2, samples per format | Provisional |
| S2.5 | Further formats (XISF, CR3, others), only if RG-01 includes them | Implementation | S–M | S2.2, samples | Conditional |
| S2.6 | File selection and the read-only import screen | Implementation | M | S2.3, S2.4 (S2.5); RD-16 | Provisional |

Then comes Stage 2 validation in a fresh session.

##### S2.R1 — RG-01: formats, libraries, file selection, fixtures (research; resolves PD-21)

- **Result (2026-09-26):** `docs/refinement/research/RG-01_METADATA_FORMATS.md`, with a proposed
  ADR-017 and five owner questions (§9 there). It was done with the owner's two phone DNGs
  (kept outside the repository). The recommendation changes the provisional Tasks:
  - S2.4 becomes an in-house TIFF/EXIF reader (DNG first) and can run with those samples;
  - S2.3 (FITS) waits for a real FITS sample;
  - S2.5 applies only to XISF, and only if the owner uses it.
  The Tasks stay provisional until the owner decides.

- **Objective:** decide, with evidence, which metadata formats Stage 2 supports, how each is read
  in a bounded way, how the user selects the files, and how real samples become test fixtures.
  The workflow is §9.6's. No production code changes.
- **Questions:**
  1. **Real workflows.** Which files does the owner produce: cameras, phones, and capture
     software (for example N.I.N.A., ASIAIR, SharpCap, a phone app)? Which formats and
     keywords do those write? The owner's answers are evidence; audit hypotheses are not.
  2. **Where the metadata lives, per format, and whether a bounded read reaches it.** Examples:
     FITS primary header blocks; the XISF XML header and its length field; JPEG APP1; TIFF,
     DNG, CR2, NEF and ARW IFDs, which sit at offsets anywhere in the file (random access, not
     just a prefix); CR3's ISO-BMFF boxes; HEIC.
  3. **Libraries.**
     - `exif` 3.3.0: formats, licence against GPL-3.0, maintenance, and whether it can read
       from a random-access source or needs the whole file in memory;
     - alternatives, or an in-house TIFF/IFD and FITS reader, with its test cost;
     - whether `image_picker` and `exif` can be removed.
  4. **File selection on Android.**
     - Does `file_picker` 13.1.0 copy picked files into the cache: time and storage for a
       50 MB RAW, and cleanup?
     - Can `XFile.openRead(start, end)` read a content URI in bounded ranges?
     - Selecting several files (the later batch use, Stage 8).
     - Type filters for FITS and XISF, which have no registered MIME type.
     - Permissions.
     - Whether Android's photo picker redacts GPS.
  5. **Fixtures for a public repository.** Options: header-only derivatives (the FITS header
     blocks; the byte ranges of a RAW that its IFDs need); samples kept outside Git, with
     tests that skip or fail clearly when they are absent; scrubbing (GPS, serial numbers,
     `OBSERVER`, `SITELAT`); size limits; the owner's consent.
  6. **Field semantics and units** for the typed model:
     - `EXPTIME` or `EXPOSURE` in seconds;
     - `GAIN` and `ISOSPEED` (a gain unit specific to the vendor, never ISO);
     - `FOCALLEN` in mm, and what capture software actually writes there;
     - `DATE-OBS`: UTC, and whether it is the start of the exposure;
     - EXIF `OffsetTimeOriginal`;
     - camera and instrument identifiers kept raw for Stage 3.
     Each field gets provenance and confidence (ADR-008 §6).
- **Evidence rules:**
  - primary sources: the FITS 4.0 standard, the EXIF/TIFF/DNG specifications, the XISF
    specification, and the package sources and changelogs on pub.dev;
  - verified facts, unknowns and assumptions are kept apart;
  - every claim about a sample is checked on the file itself.
- **Samples:**
  - the owner supplies at least one real file per candidate format they actually use, kept
    **outside the repository** until S2.R1 decides the fixture policy;
  - without samples, S2.R1 still completes the evidence and options, and ends at the owner
    decision with the sample request open;
  - no format is decided as supported without a real sample (Stage 2 exit).
- **Output:**
  - `docs/refinement/research/RG-01_METADATA_FORMATS.md`: the evidence and a recommended
    format set with the reading method and library for each;
  - a proposed **ADR-017, "Image metadata reading"**: bounded access behind a domain
    interface; the typed value model with units, provenance and unknowns; the supported
    formats; the fixture policy;
  - the S2.1–S2.6 definitions confirmed or amended.
- **Owner decisions at the end:** PD-21 / RG-01 (the format set and ADR-017), the fixture
  policy, and **RD-16** (whether a visible entry point appears at the end of Stage 2 or waits
  for Stage 3). Then STOP.
- **Out of scope:**
  - any change to `lib`, `test` or `pubspec`;
  - equipment identity and matching (RG-02, Stage 3);
  - assisted actuals (Stage 8).
- **Acceptance:** each question is answered or explicitly marked unknown with what would
  resolve it; each recommendation cites its evidence; the owner decisions are asked in one
  message.

##### S2.1 — Bounded file access behind a domain interface (provisional)
- **Objective:** file I/O leaves `lib/domain`. A data-layer reader gives parsers bounded,
  random-access reads with a byte budget, and never loads a whole file (TD-018).
- **Scope:**
  - a domain interface for a readable source (length and range reads, as ADR-017 defines);
  - a data-layer implementation over a picked file;
  - the existing extractor moved behind it, with its behaviour unchanged except for the
    bounded reads;
  - a test that forbids `dart:io` and parsing packages in the metadata domain.
- **Acceptance:**
  - a multi-gigabyte sparse file is inspected with a small, asserted number of bytes read;
  - a read past the end or over the budget is a typed failure, not a crash;
  - the domain has no I/O.

##### S2.2 — Typed metadata with units, provenance and explicit unknowns (provisional)
- **Objective:** replace the string-only `ImageMetadata` with ADR-017's typed values:
  - exposure in seconds;
  - ISO **or** gain with its kind (SI-004);
  - focal length in mm, nullable;
  - f-number, nullable;
  - capture time as UTC with its offset, or local with "zone unknown";
  - raw identifiers with provenance.
  "Absent", "unparseable" and "unreadable file" are distinct results.
- **Acceptance:** pure-Dart unit tests for every field's units, for unknowns and for
  conflicting duplicates; nothing defaults a missing value; `SCIENTIFIC_INTEGRITY.md` records
  any unit conversion.

##### S2.3 — FITS header reader (provisional)
- **Objective:** read the primary header in 2,880-byte blocks up to `END`, with a block limit.
- **Scope:**
  - FITS 4.0 card rules: keyword columns 1–8 and the value indicator in columns 9–10; quoted
    strings, including `/` and `''`; logical, integer and real values; comment cards ignored;
  - HIERARCH and CONTINUE only as RG-01 decides;
  - the typed mapping (S2.2).
- **Acceptance:**
  - real owner samples, per the fixture policy, parse to the expected values;
  - corrupted, truncated, missing-`END` and oversized-header cases fail typed;
  - a large file reads only its header blocks;
  - the TD-018 `/` defect is fixed and tested.

##### S2.4 — EXIF / TIFF-based RAW reader (provisional)
- **Objective:** a bounded read of the formats RG-01 selects (for example JPEG, DNG and a
  TIFF-based RAW), through the library or in-house reader it chooses.
- **Scope:** the typed mapping, the offset tags for time zones, and the maker-independent fields
  only (MakerNotes only if ADR-017 says so).
- **Acceptance:**
  - a real sample per supported format;
  - corrupt and truncated IFD chains and offset loops are handled;
  - bounded reads are asserted;
  - a format that is not supported gives a typed "unsupported" result, never a guess.

##### S2.5 — Further formats (conditional)
- Only if RG-01 includes them (for example XISF or CR3), with a real sample. The same
  acceptance applies as in S2.3 and S2.4.

##### S2.6 — File selection and the read-only import screen (provisional)
- **Objective:** the user picks one supported file with a document picker (RG-01's choice) and
  sees the typed values with units, provenance and explicit unknowns. Nothing is stored.
- **Scope:**
  - the picker, filtered to the supported formats;
  - the existing screen reworked to use the new model, with its errors shown through
    `LoadFailureView` / `runWithFeedback`;
  - `image_picker` (and `exif`, if replaced) removed when no longer used;
  - the gate as RD-16 decides, and, if the screen becomes visible, the accessibility sweep,
    `docs/privacy` (nothing leaves the device) and the F-45 status.
- **Acceptance:**
  - widget tests for success, unsupported, unreadable and cancelled;
  - if visible: the sweep passes in the three themes at 100 % and 200 %;
  - TD-018, F-45 and PD-21 are updated (Stage 2 exit).

#### Stage 2 — frozen Task sequence (2026-09-26)

**Frozen 2026-09-26** after the owner's RG-01 decisions (DECISIONS E.1, "Stage 2 decisions:
RG-01, PD-21, RD-16"; ADR-017). These definitions replace the provisional S2.1–S2.6 above,
which are kept for history.

| Task | Title | Size | Depends on | Host-testable | State |
| --- | --- | --- | --- | --- | --- |
| S2.1 | Bounded metadata source and format recognition | S–M | ADR-017 | yes | **Frozen; next** |
| S2.2 | The metadata contract as typed values with provenance | M | S2.1 | yes (pure) | Frozen |
| S2.3 | DNG/TIFF reader, with synthetic fixtures and local real-sample validation | M | S2.2 | yes | Frozen |
| S2.4 | Android document access without a copy; picker cache ownership (TD-065) | M | S2.1 | Dart side only | Frozen; **device check needed** |
| S2.5 | The hidden import screen on the foundation; the prototype, `exif` and `image_picker` removed | S–M | S2.3, S2.4 | yes, plus a device check | Frozen |
| S2.6 | FITS reader | M | S2.2, **a real FITS sample** | yes | **Out of Stage 2** (owner, 2026-09-26: no FITS files for now) |

Then comes Stage 2 validation (fresh session). **The Stage 2 exit is adjusted** by ADR-017 §8:
"each supported format is parsed from a real sample" means DNG. If no FITS sample exists by
then, S2.6 moves to a later Stage by owner decision, and the FITS keyword ("recognised,
unsupported") stays.

**Common rules for S2.1–S2.6** (in addition to those above):
- ADR-017 is binding: the contract fields only; no location, serials or observer; no inferred
  zone; bounded reads; I/O in the data layer;
- nothing is persisted, and the UI stays hidden;
- no bytes of the owner's files are committed;
- each Task updates F-45, TD-018/064/065 as they resolve, and ADR-017's implementation notes.

##### S2.1 — Bounded metadata source and format recognition
- **Objective:** the domain has a `MetadataSource` (length; `read(offset, count)`) wrapped by
  a byte budget (1 MiB per file, reads of at most 64 KiB), and a signature recognizer. The data
  layer has a file-backed source (`RandomAccessFile`; host, tests, desktop).
- **Scope:**
  - the interface, the budget wrapper and the typed read failures (past the end, over budget,
    I/O);
  - recognition of TIFF (with DNG through DNGVersion, read in S2.3), FITS (recognised,
    unsupported) and unknown;
  - the file source;
  - an architecture test: no `dart:io`, platform or parsing packages in the domain metadata
    code.
- **Out of scope:** parsing fields (S2.3); Android (S2.4); the old extractor stays untouched
  until S2.5.
- **Acceptance:**
  - a 4 GiB sparse file is recognised with an asserted number of bytes read (≤ 64 KiB);
  - every failure is typed;
  - the budget is enforced across reads;
  - the architecture test fails on a domain `dart:io` import.

##### S2.2 — The metadata contract as typed values with provenance
- **Objective:** ADR-017 §2 and §5 in pure Dart:
  - the readings `read`, `unsupported` and `unreadable`;
  - the field values `known` (value, unit, source), `absent`, `unparseable` and `ambiguous`;
  - exposure in seconds from exact rationals;
  - the sensitivity value with its kind;
  - focal length and its 35 mm equivalent as separate fields;
  - the capture time as local wall-clock with an optional recorded offset, or explicitly zone
    unknown.
- **Out of scope:** formats (S2.3); conversions between ISO and gain (never).
- **Acceptance:**
  - unit tests for each field's parsing and units, zero denominators, the conflict between
    IFD0 and EXIF (`ambiguous`), and a time without an offset;
  - no default for any missing value;
  - `SCIENTIFIC_INTEGRITY.md` records the rational-to-seconds and 35 mm-equivalent rules.

##### S2.3 — DNG/TIFF reader, with synthetic fixtures and local real-sample validation
- **Objective:** read ADR-017 §2's fields from a DNG through `MetadataSource`: IFD0 and the
  EXIF IFD, never the GPS IFD, never pixel data.
- **Scope:**
  - **The reader:** bounds checks, loop and entry limits, little- and big-endian;
  - **the fixture builder:** synthetic and deterministic, built in code (no binary files and
    no owner bytes), with these cases:
    - an IFD0-only layout like the owner's DNGs (rationals such as 3750000000/125000000; no
      EXIF IFD, no offset, no GPS);
    - an EXIF-IFD layout;
    - a GPS IFD present, to prove it is never read (and never followed);
    - truncated, looping, out-of-range and oversized cases;
  - **the real-sample test:** local only, with `ASTROPLAN_METADATA_SAMPLES` naming a directory
    outside the repository that holds the files and an expected-values JSON. It is skipped
    with a message when unset. The implementing session sets it up with the owner's two DNGs
    and records the result in `PROGRESS.md`, never the values.
- **Out of scope:** other TIFF-based RAWs and JPEG (ADR-017 §8), MakerNotes.
- **Acceptance:**
  - both real DNGs give the expected contract values locally;
  - for the telephoto sample, 30 s, ISO 50 (kind unspecified), 8.8 mm, 60 mm equivalent,
    f/2.0 and a zone-unknown time;
  - the bytes read per sample are asserted to be ≤ 64 KiB;
  - every synthetic case passes;
  - the GPS pointer is never followed (asserted through the source's read log).

##### S2.4 — Android document access without a copy; picker cache ownership (TD-065)
- **Objective:** ADR-017 §6. A metadata file is picked and read in bounded ranges straight
  from its content URI, with no cache copy. `file_picker`'s cache is cleared by its owning
  flow.
- **Scope:**
  - **the channel (Kotlin, `android/app`):**
    - pick: `ACTION_OPEN_DOCUMENT`, `*/*`, openable; returns the URI, name and size;
    - read: `openFileDescriptor` with a positioned read;
    - the sequential fallback for non-seekable descriptors, within the budget;
    - no persistable grant;
  - **the Dart side:** a `MetadataSource` over the channel (the data layer), with typed errors
    for a cancel, a revoked grant or an I/O failure;
  - **the backup restore:** calls `FilePicker.clearTemporaryFiles()` once its pick is
    consumed or abandoned (TD-065).
- **Out of scope:** batch selection (Stage 8); browsing, listing or managing files; a visible
  entry point.
- **Acceptance:**
  - host tests over a fake channel (range reads, budget, a non-seekable fallback, errors) and
    for the backup cleanup;
  - **a device check:** on a real Android device, picking each owner DNG reads ≤ 64 KiB and
    creates nothing under the app's cache.
  - Until the device check passes, S2.4 is recorded as implemented but **not accepted**. This
    is the blocker in E.1.

##### S2.5 — The hidden import screen on the foundation; the prototype, `exif` and `image_picker` removed
- **Objective:** the hidden screen (`FeatureScope.metadataImport` stays false) picks through
  S2.4 and shows ADR-017's typed values: units, source, and Unknown / ambiguous. It is the
  harness for S2.4's device check. The prototype extractor and the old `ImageMetadata` go.
- **Scope:**
  - rework the screen, with its errors through `LoadFailureView` / `runWithFeedback`;
  - delete `metadata_extractor.dart` and its test (replaced by the S2.1–S2.3 tests);
  - remove `exif` and `image_picker` from `pubspec.yaml` after a `grep` shows no other use
    (ADR-017 §7);
  - `docs/privacy` and `COMPLIANCE.md`: no change needed, since nothing leaves the device —
    confirm this.
- **Out of scope:** making the screen visible; persisting anything.
- **Acceptance:**
  - widget tests for success, unsupported, unreadable, cancelled and zone unknown;
  - the gate test still shows the feature hidden;
  - the quality gate is green;
  - the device check (a local, uncommitted flip of the gate in a debug build) reads both
    owner DNGs.

##### S2.6 — FITS reader (gated on a real FITS sample)
- Starts only after the owner supplies a real FITS file. Then:
  - ADR-017 §2 and §8 are amended with the FITS fields, following RG-01 §3.3 and §3.6. The
    rules stay the same: `EXPTIME`/`EXPOSURE` in seconds; the gain setting as its own kind;
    `FOCALLEN` with its "software setting" provenance; `DATE-OBS`/`DATE-UTC` as UTC per the
    sample; no `SITE*` or `OBSERVER`;
  - the reader follows the FITS 4.0 card rules (2,880-byte blocks to `END` with a block limit;
    commentary records; `''` escapes; `CONTINUE`);
  - the fixtures are synthetic, plus a local real-sample test;
  - the TD-018 `/` defect is covered by a test.

#### Stage 2 — added Tasks after the owner's format priorities (2026-09-26)

Decided by the owner on 2026-09-26 (DECISIONS E.1, "Stage 2 format priorities and metadata
layering"; ADR-017 §13). The review of S2.1–S2.5 is in `STAGE_2_ARCHITECTURE_REVIEW.md`: no
defect, and six extensibility gaps (G1–G6). S2.1–S2.5 stand as done. S2.6 (FITS) is unchanged
and still gated on a sample.

| Task | Title | Kind | Size | Depends on | State |
| --- | --- | --- | --- | --- | --- |
| S2.7 | Layered recognition and a reusable EXIF extractor | Implementation (refactor, no DNG behaviour change) | M | S2.5 | **Frozen; next** |
| S2.8 | JPEG reader (the APP1 `Exif` segment) | Implementation | S–M | S2.7, **a real JPEG sample** | **Done 2026-09-26** |
| S2.R2 | HEIC/HEIF metadata research | Research (docs only) | S–M | S2.7 | **Done 2026-09-26** (`research/S2.R2_HEIF_METADATA.md`); owner decision pending |
| S2.9 | HEIC/HEIF reader | Implementation | M | S2.R2 decided, **a real HEIC sample** | **Done 2026-09-26** (approved by the owner) |
| S2.10 | PNG `eXIf` | Implementation | S | S2.7, **a real PNG carrying eXIf** | **Out of Stage 2** (owner, 2026-09-26: no PNG files for now) |
| S2.R3 | RG-14: proprietary RAW compatibility and library research | Research (docs only) | M | S2.7 | **Done 2026-09-26; decided** (DECISIONS E.1, "RG-14 decided") |

**The Stage 2 exit, amended:** the foundation is validated; DNG is supported. Every other
format is either supported on a real sample with tests, or recorded as recognised-only with
its gate. Formats that still wait for samples can move to a later Stage by owner decision.

##### S2.7 — Layered recognition and a reusable EXIF extractor
- **Objective:** close the review's gaps G1–G5, so a new EXIF-bearing format needs only a
  container reader, with no change to the contract.
- **Scope:**
  - **The reading reports both levels:** the recognised format (recognition), and an
    extraction outcome — values, "extracted, nothing found", unreadable, or no reader for this
    format;
  - **format readers behind one interface,** listed in `CaptureMetadataReader`;
  - **the EXIF-structure extractor** (IFD0 + the EXIF IFD, with the bounds, loop, privacy and
    budget rules of S2.3) takes a **base offset** and a container label; the DNG reader
    becomes a thin container over it (DNGVersion gate, base 0);
  - **recognition-only signatures:** HEIF (ISO-BMFF `ftyp` with a HEIF brand), PNG, CR2 (TIFF
    plus `CR`), CR3 (`ftyp crx `), RAF, RW2 and ORF, and their names in `MetadataText`;
  - **`ExifRational`/`ExifValues`** move beside the extractor.
- **Out of scope:** any new parser (JPEG is S2.8); any change to the contract; level (c).
- **Acceptance:**
  - every existing metadata test passes with its assertions unchanged (only imports and
    renamed types may change);
  - the DNG read log is unchanged (the same reads and bytes);
  - the local real-sample test still passes (848 bytes);
  - a test reads an EXIF structure at a non-zero base offset;
  - each new signature is recognised, with near misses rejected;
  - a recognised format without a reader reads "no reader", not "unrecognised";
  - the gate is green.

##### S2.8 — JPEG reader (gated on a real JPEG sample)
- **Objective:** read the contract from a JPEG's APP1 `Exif\0\0` segment through the S2.7
  extractor, with no decoding.
- **Scope:**
  - a bounded marker walk from SOI: segment lengths checked; stops at SOS or EOI; ignores
    APP1 XMP and every other segment; a segment-count limit;
  - base offset = the APP1 payload + 6;
  - "no EXIF" gives "extracted, nothing found";
  - synthetic fixtures built in code, plus a local real-sample entry in `expected.json`.
- **Samples:** the owner's phone JPEG (ideally the same scene as a DNG, for cross-checking),
  and a DSLR or mirrorless JPEG where possible. They stay outside the repository.
- **Acceptance:**
  - the real samples give their expected values within the budget;
  - truncated, looping and oversized segment cases are typed;
  - the GPS IFD is never read (read log);
  - the Data Safety and privacy texts are unchanged (nothing leaves the device).

##### S2.R2 — HEIC/HEIF metadata research
- **Questions:**
  - the ISO-BMFF structure (`ftyp` brands; `meta` with `hdlr`, `iinf`, `iloc`, `idat`); where
    the `Exif` item lives, and its 4-byte TIFF-header offset;
  - whether a bounded read reaches it in real files;
  - multi-image and burst files;
  - what Android document providers deliver for HEIC;
  - licences (reading the container is unencumbered; decoding is out of scope anyway);
  - the candidate libraries (with S2.R3).
- **Output:** a research note and an owner decision; S2.9 is defined only with a real HEIC
  sample.

##### S2.R3 — RG-14: proprietary RAW compatibility and library research
- **Questions:**
  - which RAW formats owners actually use;
  - per format, whether the contract's EXIF values are reachable in a bounded way (TIFF-based
    CR2, NEF and ARW; ORF and RW2 with their variant headers; RAF's header with an embedded
    JPEG and TIFF; CR3 as ISO-BMFF);
  - the **libraries and platform facilities** against ADR-017 (bounded I/O on a content URI,
    privacy exclusions, licence against GPL-3.0, size, maintenance). For example AndroidX
    `ExifInterface`, which documents RAW and HEIF support. That is an **unverified
    candidate**;
  - what each option means for tests and fixtures.
- **Out of scope:** writing any RAW parser.
- **Output:** a research note, a recommendation and an owner decision.

##### S2.9 and S2.10 (conditional)
- **S2.9, a HEIC reader:** defined after S2.R2's decision, with a real HEIC sample.
- **S2.10, PNG `eXIf`:** reuses the S2.7 extractor, with a real PNG carrying `eXIf`; low
  priority.

#### Stage 2 — corrective Tasks after validation (2026-09-26)

These follow the two independent validations. Both reports are kept as written.

| Task | From | Scope | State |
| --- | --- | --- | --- |
| S2.V1–S2.V3 | `STAGE_2_VALIDATION.md` (S2V-01 to S2V-03, 05) | Integer counts; short Exif APP1; streaming budgets | Done, `ffaff57` |
| S2.V4 | `STAGE_2_REVALIDATION.md` (S2R-01, 02, 04) | Bound the HEIF `iloc` work (TD-067); AVIF and HEIF sequences recognised only (the owner's S2R-02 ruling, option (a)); HEIF test gaps | Done 2026-09-26 (`STAGE_2_CORRECTIONS.md`) |
| S2.V5 | `STAGE_2_REVALIDATION.md` (S2R-03) | F-45 and `TEST_PLAN.md` current-state text | Done 2026-09-26 |

Stage 2 then closes through another independent validation in a fresh session, or an owner
waiver.

#### After Stage 2: sample-driven metadata format adapters (RG-14, decided 2026-09-26)

These are not a Stage and not frozen Tasks. Each becomes a Task when the owner supplies a
representative real sample of that format. Each follows the S2.8/S2.9 pattern: a container
reader over the shared extractor, synthetic fixtures, a local real-sample check, a device
check, and no decoding and no MakerNotes.
1. RAF: its header gives the embedded JPEG, which `JpegMetadataReader` reads through a window.
2. CR2, NEF, ARW: TIFF; NEF and ARW are told apart by IFD0 `Make`.
3. ORF, RW2: TIFF-like, with their magic accepted.
4. CR3: its `moov`/`uuid` CMT1 and CMT2 boxes (CMT4, the GPS, never read). Last, because its
   layout is known only from reverse engineering.

FITS (S2.6) and PNG (S2.10) wait for samples in the same way (owner, 2026-09-26).
So do AVIF and HEIF image sequences (the S2R-02 ruling, 2026-09-26): a reader for either is a
small change over `HeifMetadataReader`, once a real sample exists.

### Stage 3 — Metadata → Equipment / Device Import

- **Purpose:** reduce manual equipment setup using verified metadata.
- **Entry:** Stage 2 validated; RG-02 and RG-03 decided; an ADR approved by the owner that
  designs candidate, match, enrichment, confirmation and persistence, with provenance,
  confidence and conflict semantics (amending ADR-011 and ADR-008 where needed).
- **Design principle:**

  ```text
  Metadata → Equipment Candidate → Match / Enrich → User Confirmation → Persist
  ```

- **Questions for the gate (RG-02, RG-03):**
  - which metadata identifies the camera, device and optics reliably: EXIF `Make`, `Model`
    and `LensModel`; FITS keywords such as `INSTRUME`, `TELESCOP`, `FOCALLEN` and pixel-size
    keywords, and which capture software writes them;
  - smartphone behaviour (35 mm-equivalent focal lengths, binned versus full resolution).
    **Evidence (S2.R1, owner's samples, 2026-09-26):** both camera modules of one phone share
    Make, Model and UniqueCameraModel, and only the optical metadata (focal length, 35 mm
    equivalent, f-number) and the image geometry tell them apart. Focal length is not a
    universally reliable identifier (DECISIONS E.1, "Stage 2 decisions"). **More (S2.R2):** the same
    phone writes Model `Xiaomi 14T Pro/2407FPN8EG` in DNG but `Xiaomi 14T Pro` in JPEG and HEIC, and
    records a time offset in JPEG/HEIC but not in DNG. Matching must not rely on exact Model equality
    across formats;
  - manual lenses and telescopes (no lens data, so the value stays unknown);
  - what cannot be derived (for example pixel pitch, sensor size, tracking), and whether a
    sourced equipment catalog is needed (TASK 8.5's verified-seed policy; "reported"
    provenance);
  - matching existing equipment (the flat profile, ADR-011; `withEditProvenance`);
  - conflicts between user-entered and imported values (never overwrite silently);
  - whether real files can provide an average RAW file size for the storage estimate (08 §17,
    C-13).
- **Rules:** no silent writes; unknown specifications stay unknown. No scraping of product
  pages, which is what extracting specifications "from links" (08 §11) would be, unless the
  owner reopens that rejection for a verified, licensed, structured source.
- **Out of scope:** assisted actuals (Stage 8); an equipment composition UI unless the ADR
  approves it (deferred by ADR-011 §2).
- **Exit:** the ADR is accepted; import proposes candidates with provenance and confidence;
  the user confirms before anything is stored; tests cover conflicts; the privacy and
  compliance documents are updated if any external source is used; Stage 3 validation passes.

#### Stage 3 — Task sequence (planning, 2026-09-26)

Planned at `main` @ `3dd2598`, just after the owner closed Stage 2 by waiver (DECISIONS E.1,
"Stage 2 closed by the owner"). **The entry conditions are not met:** RG-02 and RG-03 are
undecided, and no ADR exists. So only the two research Tasks and their decision step are
frozen. S3.1–S3.6 are **provisional**; the owner freezes them with the ADR (§9.1 step 6).

**Verified at planning (§9.7):**
1. **A rig cannot hold unknown specifications.**
   - `EquipmentProfile` requires `sensorWidthMm`, `sensorHeightMm`, `pixelPitchUm`,
     `resolutionWidthPx`, `resolutionHeightPx`, `focalLengthMm` and `focalRatio` (non-null).
   - The columns behind them are `NOT NULL` too: `camera_modules` (sensor, resolution, pixel
     pitch) and `optical_rigs` (focal length, `aperture` = N), in
     `equipment_foundation_tables.dart`.
   - A phone JPEG gives focal length, f-number, the 35 mm equivalent and make/model, but no
     sensor size, resolution or pixel pitch. **An import cannot create a stored rig without
     inventing values**, which "unknown stays unknown" forbids.
   - This is the central data-model question for RG-02 and the ADR.
2. **The metadata contract (ADR-017 §2) has no image dimensions** (ImageWidth,
   PixelXDimension) and no focal-plane resolution tags. Deriving resolution or pixel pitch
   would need a contract amendment for a new kind of fact (ADR-017 §13.3), backed by sample
   evidence. Phone sensors that bin their output (quad-Bayer) make "resolution" ambiguous.
3. **Provenance is per group, not per field.** The model has `cameraSource`/`cameraConfidence`
   and `opticsSource`/`opticsConfidence`, with confidence `verified`/`reported`/`estimated`
   (`spec_confidence.dart`; ADR-008 §6). `withEditProvenance` marks an edited group as
   `'user'`/`reported`. A group mixing imported and typed values has no way to say so.
4. **Only one seed exists:** ZWO ASI2600MC plus an example 72 mm f/5.6 refractor
   (`seed:equipment@2`; camera verified against the manufacturer's page, optics an example). The
   verified-seed policy (TASK 8.5) explains 08 §11's "only ZWO".
5. **The rig editor still has six required inputs:** name, resolution width and height, pixel
   size, focal length, and focal ratio or diameter (`equipment_selection_screen.dart:223–428`).
   UX-22's friction is current.
6. **Identity evidence from Stage 2 (owner samples):**
   - both camera modules of one phone share Make, Model and UniqueCameraModel;
   - Model differs by format (DNG `…/2407FPN8EG`, JPEG/HEIC `Xiaomi 14T Pro`);
   - serials are never extracted (ADR-017 §3), so two identical bodies are indistinguishable.
7. **The file length is known at read time** (`MetadataSource.length`), a possible input to
   the average RAW size (C-13). One file is one sample, and size varies with compression.
8. **The metadata screen is hidden** (`FeatureScope.metadataImport == false`); RD-16 leaves
   visibility to Stage 3.
9. **"Extract specifications from links" (08 §11) is product-page scraping**, which is rejected
   unless the owner reopens it for a verified, licensed, structured source.

**Carried from Stage 2:** TD-066 (sub-second exposure display, before the screen is visible);
S2V-06's device checks; FITS, PNG, AVIF, HEIF sequences and proprietary RAW wait for samples.
The dedicated astro cameras the product targets write FITS, so equipment identity for them
waits on a FITS sample (S2.6).

**Common rules for every Task:**
- the workflow and validation of §9.4 and §9.8, one commit per Task, then STOP;
- nothing is written to Equipment before the ADR defines confirmation, and the user confirms
  every write;
- unknown stays unknown: no default, no invented specification, and no estimate passed off as
  a measured value;
- nothing leaves the device unless an approved source says so, and then privacy and Data
  Safety are updated in the same change (CLAUDE.md trap 22);
- no scraping; any external dataset passes CLAUDE.md rule 28 (reliability, licence,
  provenance, privacy, failure behaviour) before use;
- owner samples stay outside Git.

| Task | Title | Kind | Size | Depends on | State |
| --- | --- | --- | --- | --- | --- |
| S3.R1 | RG-02: metadata → equipment identity, derivability, storage of unknowns, matching, provenance and conflicts | Research (docs only) | M | — | **Done 2026-09-26** inside the second planning pass (below); `research/RG-02_EQUIPMENT_IDENTITY.md` |
| S3.R2 | RG-03: sourcing equipment specifications (none, curated verified seeds, or a licensed dataset) | Research (docs only) | M | S3.R1's derivability matrix | Frozen; **deferral recommended** (RG-02 §9, decision D2) |
| S3.D | Owner decisions: RG-02, RG-03, RD-16 (visibility); ADR-018 (candidate → match/enrich → confirm → persist); Stage 3 frozen | Decision (docs only) | S | S3.R1, S3.R2 (or D2's deferral) | Frozen (gate); **next** |

*The six provisional rows below are superseded by the refined sequence of the second planning
pass (below), which reuses the IDs S3.1–S3.9 with new meanings. They are kept as written.*

| Task | Title | Kind | Size | Depends on | State |
| --- | --- | --- | --- | --- | --- |
| S3.1 | Equipment candidate from a metadata reading (pure domain: derivable fields, provenance, confidence, unknowns) | Implementation | M | S3.D | Provisional |
| S3.2 | Matching candidates to existing rigs, with conflicts detected, never merged silently | Implementation | M | S3.1 | Provisional |
| S3.3 | Persisting confirmed values: per the ADR, possibly schema v18 (nullable specs or per-field provenance) | Implementation | M | S3.2, S3.D | Provisional |
| S3.4 | Review-and-confirm flow on the import screen; visibility per RD-16 | Implementation | M | S3.3 | Provisional |
| S3.5 | A specification source, only if RG-03 approves one | Implementation | M | S3.D | Conditional |
| S3.6 | Average RAW size from picked files (C-13), only if RG-02 approves it | Implementation | S | S3.3 | Conditional |

Then comes Stage 3 validation in a fresh session.

##### S3.R1 — RG-02: metadata → equipment identity (research)
- **Objective:** decide, with evidence, what a metadata reading can say about equipment, and
  how that becomes a confirmed rig without invented values.
- **Questions:**
  1. **Identity:** which contract fields identify the body or device, the camera module and the
     optics, per format (DNG, JPEG, HEIC now; FITS `INSTRUME`/`TELESCOP` only as documented
     evidence until a sample exists). How Make/Model are normalised across formats (the Xiaomi
     case), and what cannot be told apart (phone modules, identical bodies without serials).
  2. **A derivability matrix** for every `EquipmentProfile` field, each with its source,
     confidence (`verified`/`reported`/`estimated`) and failure cases:
     - direct values (focal length, f-number);
     - derived values (aperture diameter = f / N; a sensor diagonal from the 35 mm equivalent);
     - values that need a contract amendment (image dimensions; focal-plane resolution);
     - values that are never derivable (tracking, maximum exposure).
     Binned output (quad-Bayer phones) and cropped modes are explicit cases.
  3. **Storing unknowns (the planning finding):** compare
     - (a) a transient candidate that is stored only once the user completes the required
       fields (the editor pre-filled, with provenance);
     - (b) nullable specifications (schema v18), with every calculator that uses them
       (FOV, pixel scale, NPF, storage) showing "unknown";
     - (c) a separate candidate store.
     Cost, the migration, and the effect on the planner for each.
  4. **Matching:** what counts as the same camera or optic as an existing rig (normalised
     identity, focal length, f-number); the confidence levels; one camera with several optics
     (ADR-011's flat model over normalised storage); what the user sees on a partial match.
  5. **Provenance and conflicts:** a source form for imported values (for example
     `metadata:<format>:<tag>`); whether per-group provenance suffices or per-field is needed
     (ADR-008 §6 amendment); what happens when an imported value differs from a user-entered
     or verified one (shown side by side, never overwritten).
  6. **Visibility (RD-16):** when the import screen becomes visible, and where its entry
     points sit (with Stage 4's information architecture in mind).
  7. **The average RAW size (C-13):** whether picked files' sizes may feed it, and with what
     provenance.
- **Inputs:** the owner's local samples (DNG, JPEG, HEIC); the S2.R1/S2.R2 notes; ADR-008 §6,
  ADR-011, ADR-017; the code named in "Verified at planning". It is worth asking the owner which
  cameras and optics they actually use (still unknown).
- **Output:** `docs/refinement/research/RG-02_EQUIPMENT_IDENTITY.md` (facts, unknowns,
  options, trade-offs, a recommendation); a proposed ADR-018 outline; the owner's questions.
- **Out of scope:** production code (throwaway probes only, deleted); choosing a spec source
  (S3.R2).
- **Acceptance:** every question above is answered or explicitly left unknown with a reason;
  the matrix covers every `EquipmentProfile` field; the claims about samples are reproducible
  locally without committing sample values.

##### S3.R2 — RG-03: sourcing equipment specifications (research)
- **Objective:** decide whether a specification source is needed for what S3.R1 finds
  underivable (sensor size, pixel pitch, resolution), and which source, if any, is acceptable.
- **Questions:**
  - Options:
    - (a) no source, so the user enters what metadata cannot give;
    - (b) a larger curated set of verified seeds under the TASK 8.5 policy, each citing a
      primary source (the maintenance cost, and which cameras);
    - (c) an existing open dataset.
  - Candidates for (c) are to be evaluated, and **all are unverified today**: for example
    lensfun's database, or camera lists in raw-processing projects. For each:
    - licence against GPL-3.0 (with RG-12);
    - provenance granularity;
    - coverage of astro cameras, not only consumer cameras;
    - offline size;
    - update policy.
  - What "reported" versus "verified" means for dataset values, and how a dataset value
    appears next to a user's entry.
  - Whether anything would leave the device (it should not: bundled data only, unless the
    owner decides otherwise).
- **Output:** `docs/refinement/research/RG-03_EQUIPMENT_SPECS.md` with a recommendation and the
  owner's questions.
- **Out of scope:** scraping; bundling any data before the decision.

##### S3.D — Decisions and ADR-018 (gate)
- The owner decides RG-02, RG-03 and RD-16.
- ADR-018 records the flow `Metadata → Equipment Candidate → Match / Enrich → User
  Confirmation → Persist`, with provenance, confidence and conflict rules, amending ADR-011
  and ADR-008 §6 where needed.
- S3.1–S3.6 are then confirmed, changed or removed, and frozen.

#### Stage 3 — second planning pass and refined Task sequence (2026-09-26)

Run at `0c4848b` from the owner's Stage 3 planning prompt, which asked the S3.R1 questions
itself. So S3.R1 was done inside this pass: `research/RG-02_EQUIPMENT_IDENTITY.md`, with the
Stage 2 foundation re-verified (§1; gate green, 1068 + 1 skip + 2 E2E; local real samples pass),
the field classification (§3), the derivability matrix (§4), device classes (§5), matching and
conflicts (§6), provenance and confirmation (§7), the storage options (§8), and the decisions
D1–D4 (§12). Documentation only.

**Findings that shape the sequence:**
- Image dimensions are in all three sample formats but outside the contract, and orientation
  swaps them (JPEG/HEIC portrait). Pixel pitch is in none (no focal-plane tags).
- A phone's modules are told apart only by (f, N, f₃₅); each module × capture mode is its own
  flat rig. Model strings differ by format.
- ADR-011 §4 forbids back-filling D, so an import never sets the aperture diameter.
- The editor computes the sensor size and builds the profile and its provenance inside the
  widget; an import cannot pre-fill it without a small form model.
- ADR-008 §6 already requires per-field provenance pairs for rows with mixed origins, which an
  imported rig has.
- Dedicated astro cameras (FITS) and system-camera RAW cannot be imported in Stage 3 (no
  readers); DSLR/mirrorless JPEGs are read, but only synthetic fixtures cover them.

**The blocking decision is D1** (how specs the file cannot give are handled). The sequence below
assumes the recommendation, **A1**: complete before saving, with an estimate offered. It stays
**provisional until S3.D** records D1–D4 and ADR-018. Under A2, S3.2 loses its estimate. Under B,
S3.4 becomes a nullable-spec migration touching every consumer (an L Task, to be re-planned).

**Common rules:** those of the first pass (above), plus:
- the pure domain up to the review;
- one repository write, on the user's Save;
- no maker-specific string hacks;
- new calculations registered in `SCIENTIFIC_INTEGRITY.md`;
- `SessionPlanViewModel`'s line cap and trap 11's 250-line ViewModel limit respected.

| Task | Title | Kind | Size | Depends on | State |
| --- | --- | --- | --- | --- | --- |
| S3.D | Owner decisions D1–D4; ADR-018; freeze this table | Decision (docs) | S | this pass | **Next** |
| S3.1 | Image geometry in the metadata contract (ADR-017 §13.3 amendment) | Implementation | S–M | S3.D | Provisional |
| S3.2 | Equipment evidence and candidate (pure domain), with CALC-40 under A1 | Implementation | M | S3.1 | Provisional |
| S3.3 | Matching saved rigs, with conflicts (pure domain) | Implementation | M | S3.2 | Provisional |
| S3.4 | Per-field provenance and identity evidence in storage (schema v18) | Implementation | M | S3.D | Provisional (can run before S3.2/S3.3) |
| S3.5 | A form model for the rig editor, and pre-fill | Implementation | M | S3.4 | Provisional |
| S3.6 | The import review and confirmation flow | Implementation | M | S3.3, S3.5 | Provisional |
| S3.7 | Visibility (RD-16), TD-066, the device check M4 | Implementation | S | S3.6 | Provisional |
| S3.8 | Average RAW size from a DNG pick (C-13) | Implementation | S | S3.6 | Conditional on D4 |
| S3.9 | A specification source | Implementation | M | S3.R2 | Conditional on D2 (deferral recommended) |

Then Stage 3 validation in a fresh session.

*The table above is the provisional state before S3.D, kept as written. The frozen sequence
follows.*

#### Stage 3 — frozen Task sequence (S3.D, 2026-09-26)

The owner chose the recommended option for each of D1–D4 (DECISIONS E.1, "Stage 3 decisions
(S3.D)"), and ADR-018 records the design. Changes from the provisional table:
- S3.9 and S3.R2 leave Stage 3 (D2: RG-03 deferred);
- S3.8 stays in (D4);
- the Task definitions below are ADR-018's decisions.

One Task per commit, then STOP (§9.4). Never start the next Task automatically.

| Task | Title | Size | Depends on | State |
| --- | --- | --- | --- | --- |
| S3.D | Owner decisions D1–D4; ADR-018; this table | S | the second pass | **Done 2026-09-26** |
| S3.1 | Image geometry in the metadata contract (ADR-018 §3) | S–M | S3.D | **Done 2026-09-26** |
| S3.2 | Equipment evidence and candidate, with CALC-40 (ADR-018 §4) | M | S3.1 | **Done 2026-09-26** |
| S3.3 | Matching saved rigs, with conflicts (ADR-018 §6) | M | S3.2, S3.4 (for the stored identity) | **Done 2026-09-26** |
| S3.4 | Per-field provenance and identity evidence, schema v18 (ADR-018 §5) | M | S3.D | **Done 2026-09-26** |
| S3.5 | A form model for the rig editor, and pre-fill | M | S3.4 | **Done 2026-09-26** |
| S3.6 | The import review and confirmation flow | M | S3.3, S3.5 | **Done 2026-09-26** |
| S3.7 | Visibility (ADR-018 §7), TD-066, the device check M4 | S | S3.6 | **Done 2026-09-26** (M4 passed; TD-066 verified on the device) |
| S3.9 | No rounding conflicts between a rig and the file it was imported from (TD-068) | S | S3.7 | **Done 2026-09-26** (owner-approved, E.1 "Stage 3 fixes before validation") |
| S3.10 | The editor's sensor-size fields readable on a phone (TD-069) | S | S3.9 | **Done 2026-09-26** (with the Tracking dropdown overflow its test found) |

#### Stage 3 — corrective Tasks after the failed validation (2026-09-26)

The independent validation at `387e54b` failed (`STAGE_3_VALIDATION.md`, `7f790df`). The owner
approved these Tasks, one at a time, each ending in a commit and a STOP (DECISIONS E.1, "Stage 3
validation failed: corrective Tasks"). Then a fresh independent validation; Stage 4 waits.

| Task | Finding | Acceptance (owner) | State |
| --- | --- | --- | --- |
| S3.V1 | S3V-01 | A stale review never silently reverts newer Equipment changes, unless the user explicitly chooses to replace them | **Done 2026-09-26** |
| S3.V2 | S3V-02 | Untouched legacy values are never attributed to the user because another field was edited | **Done 2026-09-27** |
| S3.V3 | S3V-03, S3V-04 | The file's value, when chosen, is the value applied; persisted and verified values stay exact; rounding only for estimated or display-only values | **Done 2026-09-27** |
| S3.V4 | S3V-05 | Image dimensions validated; impossible or absurd values rejected (S3.1's acceptance) | **Done 2026-09-27** |
| S3.V5 | S3V-06, S3V-07 | The required real-database review coverage; stale documentation and status wording corrected | **Done 2026-09-27** |
| S3.V6 | S3V-01 (ViewModel level; probe P5 still fails after S3.V1–S3.V5) | No draft of a saved rig can be built from a stale match: the ViewModel re-reads the saved rigs before handing one out | **Done 2026-09-27** (owner-approved) |
| (separate) | S3V-08 | A device recheck, as its own validation action with its evidence level, if the Stage 3 acceptance requires it | Not decided; kept apart from S3.V5 |
| S3.V7 | S3S-01 (TD-070), fresh-session sign-off `d7dead0` | The Equipment editor uses each value's stored provenance; a rig-wide `user` never presents estimated or imported values as user-reported. No snapshot provenance migration: a saved-session record never presents the rig-wide source as every field's; per-field session provenance and its export/schema changes go to Stage 8. Missing per-field provenance is never replaced with an invented `user` | **Done 2026-09-27** (owner-approved, E.1 "Stage 3 sign-off failed: corrective Tasks") |
| S3.V8 | S3S-02 (TD-071, SI-014) | Option (a): when the photo's pixel dimensions differ from the matched saved rig's, pixel size and physical sensor size are not copied; they stay unknown until the user confirms or provides them; the relationship is not inferred | **Done 2026-09-27** |
| — | S3S-03 (TD-072) | Not part of S3.V8; deferred to a later Equipment/data-entry cleanup (owner) | Deferred |
| Sign-off | S3V-01–S3V-06, S3S-01, S3S-02, and the original Stage 3 acceptance | A fresh-session sign-off (§9.8) | **PASS 2026-09-27** at `92ebf2a` (`STAGE_3_FINAL_SIGNOFF.md`); **Stage 3 closed**. Non-blocking: S3F-01 (TD-072 addendum), S3F-02 (TD-071 note). S3V-08 stays unverified |
| S3.8 | Average RAW size from a DNG pick (ADR-018 §4, D4) | S | S3.6 | **Done 2026-09-26** |

Order: S3.1 → S3.2 → S3.4 → S3.3 → S3.5 → S3.6 → S3.8 → S3.7. S3.7 goes last because it makes
the flow visible. Then Stage 3 validation in a fresh session.

##### S3.1 — Image geometry in the metadata contract
- **Objective:** read the pixel dimensions of the captured image as a typed, provenanced
  contract fact.
- **Scope:**
  - ADR-017 §2/§13.3 amended by ADR-018;
  - `CaptureMetadata` gains image width and height (px) with origin;
  - DNG: IFD0 only, for the main image (`NewSubfileType` absent or 0): `DefaultCropSize` when
    present and integral, else `ImageWidth`/`ImageLength`; sub-IFDs are not followed
    (ADR-018 §3);
  - JPEG/HEIC: `PixelXDimension`/`PixelYDimension` in the EXIF IFD, through the shared
    `ExifStructure`;
  - disagreeing sources are ambiguous (the existing `combine`);
  - `MetadataText` rows on the hidden screen.
- **Out of scope:** Orientation interpretation (the candidate uses long/short sides); pixel
  pitch; any new format.
- **Acceptance:**
  - synthetic fixtures for each format, including a portrait JPEG, a missing tag, SHORT vs LONG
    types and a zero or absurd value (unparseable);
  - the GPS and serial exclusions still hold (read log);
  - the byte budget is unchanged;
  - the local samples give the expected dimensions, added to `expected.json` outside Git;
  - gate green.

##### S3.2 — Equipment evidence and candidate
- **Objective:** turn a `MetadataRead` into an `EquipmentCandidate`: per `EquipmentProfile`
  field a proposed value with source, confidence and origin, or unknown with a reason (level 3
  of ADR-017 §13).
- **Scope:**
  - pure Dart in `lib/domain`;
  - the §3/§4 mapping: Make/Model → labels; f → focal length; N → focal ratio; dimensions →
    resolution (long side = width);
  - under A1, CALC-40 (sensor size and effective pixel pitch from f₃₅, f and the dimensions),
    `estimated`, with its assumptions and uncertainty in `SCIENTIFIC_INTEGRITY.md`, and never
    produced when an input is unknown, ambiguous or outside `EquipmentLimits`;
  - D, rotation, tracking and maximum exposure are always unknown;
  - exposure, sensitivity and time are ignored;
  - a name suggestion;
  - "not enough evidence" when neither identity nor optics is known.
- **Out of scope:** matching; persistence; UI.
- **Acceptance:** tests for each device class of RG-02 §5 with synthetic readings:
  - a phone module (with the committed RG-01 values as a worked case);
  - a body with an electronic lens;
  - a body on a telescope (f/N absent or 0);
  - absent, unparseable and ambiguous inputs → unknown with reasons;
  - no field ever `verified`;
  - the estimate's formula tested against hand-computed values.
- **Validation:** the domain purity tests; gate green.

##### S3.3 — Matching saved rigs, with conflicts
- **Objective:** compare a candidate with the saved rigs and return an outcome with reasons and
  per-field conflicts, never a score (RG-02 §6).
- **Scope:**
  - pure domain;
  - normalisation (trim, whitespace, case) and the prefix-at-separator "likely" rule;
  - a documented f/N tolerance constant (proposed 1 %);
  - outcomes: same, likely, same camera (other optics), cropped or binned mode, ambiguous, none;
  - conflicts listed with both provenances;
  - verified values flagged as never replaced by default;
  - stored identity evidence (S3.4) used when present.
- **Out of scope:** merging or writing.
- **Acceptance:** one test per RG-02 §6 scenario, including:
  - the Xiaomi DNG-vs-JPEG model strings;
  - two identical saved bodies (ambiguous);
  - a legacy rig with NULL provenance;
  - the seeded verified camera;
  - a phone's two modules (different optics);
  - a digital-zoom capture (same f/N, other f₃₅).

##### S3.4 — Per-field provenance and identity evidence (schema v18)
- **Objective:** store which source gave each spec, as ADR-008 §6 requires for mixed rows,
  plus the metadata identity for later matching.
- **Scope:**
  - additive nullable columns (ADR-018 §5):
    - source/confidence pairs for resolution, pixel pitch, sensor size and RAW size on
      `camera_modules`, and for focal length and focal ratio on `optical_rigs`;
    - `metadata_make` and `metadata_model` (raw strings) on `camera_modules`;
  - the resolution rule: a field's own pair, else its group's, else unknown;
  - `EquipmentProfile` and `withEditProvenance` per field (an edit marks only the changed field
    `user`);
  - the repository mapping;
  - the Drift workflow (snapshot, generated steps, `from17To18`, a schema-equality test and a
    data-preservation test);
  - backup/restore and the export manifest checked (no manifest change expected; if one is
    needed, `EXPORT_MANIFEST.md` and `SessionManifestCodec` in the same change).
- **Out of scope:** nullable required specs (option B); composition.
- **Acceptance:**
  - legacy and seeded rows read exactly as before;
  - the manual editor's behaviour is unchanged (its existing tests pass unmodified);
  - migration tests pass;
  - `DATA_MODEL.md` Part B updated.

##### S3.5 — A form model for the rig editor, and pre-fill
- **Objective:** let the editor start from a candidate without moving logic into widgets.
- **Scope:**
  - extract the editor's value building (parsing, `resolveAperture`, sensor-size computation,
    provenance) into a pure form model (a draft) that both "Add"/"Edit" and the import use;
  - the editor accepts an initial draft with per-field provenance, and shows each pre-filled
    value's source and confidence (an "estimated" or "from file" note);
  - editing a field makes it `user`.
- **Out of scope:** the Stage 5/7 editor redesign (layout, styling, UX-22's duplicate pixel
  field), unless needed for a pre-filled field to be correct.
- **Acceptance:**
  - existing editor tests pass unchanged;
  - new tests: a pre-filled draft saves with per-field provenance; an untouched pre-filled
    field keeps its provenance; an edited one becomes `user`; required unknowns block Save;
  - D is never pre-filled.

##### S3.6 — The import review and confirmation flow
- **Objective:** Metadata → candidate → match → review → pre-filled editor → Save, with nothing
  written before Save.
- **Scope:**
  - the metadata screen (or its successor) shows the candidate and the match outcome in plain
    words;
  - actions: open the matching rig; new rig (pre-filled, optionally with a matched rig's
    camera specs); for a conflict, per-field keep/use-imported with keep as the default;
  - the file's unreadable/unsupported states unchanged;
  - `runWithFeedback` for the write;
  - a ViewModel within the size limits, domain interfaces only.
- **Out of scope:** batch import; FITS/RAW; assisted actuals (Stage 8).
- **Acceptance:** widget tests with a fake `CaptureFileAccess` and a real in-memory database:
  - Cancel at every step writes nothing (row counts unchanged);
  - a duplicate is not created for "same rig";
  - a conflict never overwrites unless chosen;
  - a verified value survives;
  - the accessibility sweep covers the review (light, dark, field; 100/200 %);
  - no colour literals.

##### S3.7 — Visibility, TD-066, the device check M4
- **Objective:** make the flow reachable per D3, safely.
- **Scope:**
  - `FeatureScope.metadataImport` true, with "Add from a photo" next to "Add" on the equipment
    screen; the Settings entry to the read-only viewer removed (ADR-018 §7);
  - TD-066 (sub-second exposures as a fraction or a documented rounding in `QuantityText`);
  - privacy and Data Safety re-checked (expected: no change, nothing leaves the device);
  - `FEATURE_STATUS.md` F-45/F-23;
  - `TEST_PLAN.md` row M4: an import on the owner's phone through the separate `.s2check`
    package, never touching the owner's installed app;
  - S2V-06's non-seekable check, if the phone is connected.
- **Acceptance:** the E2E suite is unchanged or updated with the screen; the sweep passes; M4
  passes, or the Task stays open for it, like 15.4.

##### S3.8 — Average RAW size from a DNG pick (conditional on D4)
- The file length of a DNG pick is offered as `estimated`, "from one file", in the review.
- Never from JPEG/HEIC; never overwrites a user value.
- Tests for each rule.

##### S3.9 — A specification source (conditional on D2)
- Only after S3.R2 recommends a source and the owner approves it (CLAUDE.md rule 28, RG-12
  licence, privacy).
- Not planned further while deferral is recommended.
- **Removed from Stage 3 by D2 (S3.D, 2026-09-26):** RG-03 is deferred.

### Stage 4 — Product Flow & Information Architecture

- **Purpose:** resolve the user-facing relationship between Tonight/Home, the Planner, New Plan
  or New Session, the internal draft state, the saved session, Start, Execution, Results,
  Sessions, the Logbook and the Library.
- **Kind:** product and UX analysis, and owner decisions, before any implementation. No
  application code.
- **Inputs:** 05 (measurements; UX-01 to UX-40; patterns P0–P10, as hypotheses only); 06 §6;
  07 §5 and §10; 08 §2, §3, §5, §14, §19, §24, §25, §27 and §28; ADR-014, ADR-015 and ADR-016;
  `IA_WIREFRAMES.md`.
- **Gates and decisions:**
  - RG-04, Execution's role and the post-plan workflow;
  - RG-05, the Home/Tonight hierarchy, the drill-downs and a possible Analytics destination;
  - RG-06, Basic/Advanced modes against progressive disclosure;
  - RD-04, defaults and the example plan;
  - RD-05, drafts and what New Session means;
  - RD-06, the planner's section order and integrity text one tap away;
  - RD-07, the Library's role;
  - RD-14, vocabulary.
- **Must consider:**
  - the wireframe deviations UX-04 (the planner shows no identity or state) and UX-11 (no night
    picker on Tonight);
  - UX-10 (drill-downs land at the top of the planner) and UX-13 (a second, actionable card
    after Start);
  - how the way actuals are captured affects planned-versus-actual (CALC-37) and progress per
    target (CALC-38);
  - the field constraints (`IA_WIREFRAMES.md` §3);
  - cheap owner-run evidence first (05 §8): a five-second test of Tonight and the planner, a
    first-run test, and a darkness test.
- **Output:**
  - an owner-approved ADR amending ADR-015, and ADR-016 if Execution's role changes, with
    low-fidelity flows;
  - a new wireframe document or an addendum (`IA_WIREFRAMES.md` is not rewritten);
  - the implementation decomposed into Tasks for Stages 5, 6, 8 and 9.
- **Out of scope:** code; visual design details (Stage 5).
- **Exit:** the decisions are recorded in `DECISIONS.md`; Stage 4 validation confirms every 08
  flow question has an answer or an owner deferral; `PROGRESS.md` is updated.

#### Stage 4 — frozen Task sequence (planning, 2026-09-27)

Planned at `main` @ `126d97f`, right after Stage 3 closed. **Process note:** planned in the same
chat as the Stage 3 final sign-off, because the owner asked to move on there, not in a fresh chat
(§9.1 step 1). The owner chose the recommended option on each planning question (DECISIONS E.1,
"Stage 4 planning decisions"):
- the sequence below is frozen as proposed;
- the owner-run quick tests (S4.E) are optional and non-blocking;
- each gate is decided right after its research step, not all at the end.

**Verified at planning (§9.7), all still current:**
1. **UX-10.** Tonight's Night, Moon and Weather rows all call `openPlanner`, which opens the
   planner at its top (`tonight_home_screen.dart:219–266`).
2. **UX-11.** Tonight has no night picker; the "Night of …" row opens the site picker
   (`tonight_home_screen.dart:148–165`).
3. **UX-13.** The current-session card offers Start whenever a night, target and rig exist, with
   no check for a session already in progress. The run card sits above it
   (`tonight_home_screen.dart:110–136, 390–400`). The repository refuses the second start
   (ADR-016 §2).
4. **UX-04, ADR-015 §2.**
   - The planner's title is "Session planner". It names no target, night or status.
   - Its app bar holds "+" (New Session), Duplicate and the field-mode button
     (`home_screen.dart:45–93`).
   - The sections run Target / What → Equipment / How → Conditions & Timeline / When → Capture
     Plan (`home_screen.dart:113–301`).
5. **RD-04.** A new draft gets M42 (`searchTargets('M42')`) and the example capture plan
   (`session_plan_viewmodel.dart:108–112, 255–259`).
6. **RD-05, UX-12.**
   - Pure drafts are not listed in Sessions (`library_viewmodels.dart:153`).
   - S1.6 and S1.V3 confirm before unsaved changes are replaced.
   - W1 and V3 are recorded inputs to RD-05.
   - TD-058 (New, Duplicate and Open outside the autosave chain) is open.
7. **RD-07, UX-14.** Library lists Rigs, Targets, Sites and Progress (`library_screen.dart`). The
   rig and target pages still select for the current session (TD-053, open). "Add from a photo"
   sits on the rig list (S3.7).
8. **After the plan.**
   - The session detail offers "Open tracker" (in progress), "Edit results" (completed), "Open in
     planner" or "Plan again (copy)", Share and Export file (`session_detail_screen.dart:364–424`).
   - The results page corrects counts only by ±1 (`results_screen.dart:335–341`; UX-25).
   - The resume prompt offers Continue, Pause now, Finish and Abandon (`resume_run_dialog.dart`).
   - 08 §24's "opening a Logbook entry shows the tracker again" fits "Open tracker" (in progress)
     or the results page (completed); S4.R1 asks the owner which was meant.
9. **RD-14.**
   - The tabs are Tonight · Sessions · Library · Settings (`app_shell.dart`), yet the save
     confirmation still says "Session saved to Logbook!".
   - The Library says "Rigs", while the editors and pickers say "Equipment" ("Add Equipment
     Profile", "Select Equipment").

**Carried in as inputs, not as Tasks:**
- W1 and V3 (RD-05);
- TD-057 and TD-058 (context for RD-05; their fixes belong to the implementing Stage);
- TD-063 (Stage 8);
- UX-25, UX-26, RD-12 and RD-13 (Execution context). RD-12 and RD-13 are decided in Stage 8, but
  RG-04 may reshape them;
- TD-050, TD-051 and TD-054 (presentation context for Stage 6);
- Stage 3's "Add from a photo" entry point, which is kept or explicitly moved.

**Common rules for every Task:**
- documentation and research only: no application code, test or dependency change. Throwaway
  probes or renders are allowed and deleted, as in S2.R1;
- the research workflow of §9.6. Each document gives options with trade-offs and a recommendation,
  ends with the owner's questions, and the owner decides before the next step;
- nothing is removed. Every current value, calculation, assumption and data path stays reachable in
  every option (`PRODUCT_DIRECTION.md` §5, §7). An option that retires a screen says what happens to
  its data;
- the constraints stand:
  - no score and no good/bad colouring (ADR-012, ADR-013);
  - no customisable dashboard (PD-14);
  - the field constraints (`IA_WIREFRAMES.md` §3);
  - offline-first; unknown stays unknown (SI-008);
  - ADR-014's session aggregate and ADR-016's events and snapshots, unless the ADR amends them;
- Execution stays as built until Stage 8 (`PRODUCT_DIRECTION.md` §4);
- low fidelity only (text or simple diagrams); visual design is Stage 5's;
- the audit patterns (05 §8 P0–P10), 07 §10's directions and 08's proposals are options, not
  decisions;
- `IA_WIREFRAMES.md` is not rewritten; new flows go into an addendum;
- one commit per Task, then STOP.

| Task | Title | Kind | Size | Depends on | Gates | State |
| --- | --- | --- | --- | --- | --- | --- |
| S4.R1 | Flow inventory and question matrix | Research (docs) | M | — | — | **Done 2026-09-27** (`research/S4.R1_FLOW_INVENTORY.md`) |
| S4.R2 | RG-04: Execution's role and how actuals are recorded | Research (docs) | M | S4.R1 | RG-04 | **Done 2026-09-27**; RG-04 decided (B + G2; E.1) |
| S4.R3 | Session lifecycle, state display, defaults and the example plan | Research (docs) | M | S4.R2's decision | RD-05, RD-04 | **Done 2026-09-27**; RD-05 and RD-04 decided (L1, Y2, no preselection, U1; E.1) |
| S4.R4 | Tonight, the planner's structure, and disclosure | Research (docs) | M–L (one cohesive question) | S4.R2 and S4.R3 decisions; S4.E if run | RG-05, RD-06, RG-06 | **Done 2026-09-27**; RG-05, RD-06 and RG-06 decided (T1, D-b, P-1, M0; E.1) |
| S4.R5 | The Library's role and the vocabulary | Research (docs) | S | S4.R2–S4.R4 decisions | RD-07, RD-14 | **Done 2026-09-27**; RD-07 and RD-14 decided (LB1 + PR2; Rig, Plan, Logbook; the glossary; E.1) |
| S4.D | ADR-019 and the wireframe addendum | Decision (docs) | M | S4.R1–S4.R5 | records all | **Done 2026-09-27**; ADR-019 accepted; `docs/IA_WIREFRAMES_ADDENDUM.md` |
| S4.T | The decisions as provisional Tasks for Stages 5, 6, 8 and 9 | Planning (docs) | M | S4.D | — | **Done 2026-09-27** (provisional Tasks P5.x–P9.x in each Stage's section) |
| S4.E | Owner-run quick tests | Owner evidence | S | S4.R1's script | feeds S4.R4 | Optional, non-blocking |

Then a fresh-session Stage 4 validation. It checks the Stage exit: every 08 flow question has an
answer or an owner deferral.

##### S4.R1 — Flow inventory and question matrix
- **Objective:** one factual baseline, so the later steps do not re-read the code.
- **Scope:**
  1. the routes and screens today, against `IA_WIREFRAMES.md`'s route map, with every deviation;
  2. every action that creates, opens, replaces, saves, starts, finishes, abandons or deletes a
     session: its entry points, its confirmation and its feedback;
  3. the session states, and how each screen shows them;
  4. taps per core task, re-measured on the current code (05 §5.4);
  5. **the question matrix:** each flow question of 08 (§2, §3, §5, §8, §14's example plan, §19,
     §24's naming and "opening an entry", §25, §27's critical list, §28), and UX-01 to UX-14 and
     UX-24 to UX-27. For each: the current fact and the S4 step that answers it;
  6. the S4.E script (below).
- **Output:** `research/S4.R1_FLOW_INVENTORY.md`.
- **Out of scope:** options and recommendations.
- **Acceptance:**
  - every 08 flow question has a home in the matrix;
  - every entry point is cited to a file and line at `126d97f` or later;
  - the route deviations are listed;
  - the script can be run without the agent.

##### S4.R2 — RG-04: Execution's role and how actuals are recorded
- **Question:** what role Execution plays after a plan is made, and how actual results are
  recorded without frame-by-frame reporting (08 §3).
- **Options to evaluate, at least:**
  - (A) as built: Start opens the tracker;
  - (B) the tracker optional: planning ends at Save; results are recorded after the night by
    default, and the tracker stays for those who want it;
  - (C) after the session only: no live tracker; a result form (completed, partly or not; frames
    or integration per block, perhaps pre-filled from the plan);
  - (D) a simplified tracker.
- **For each option:**
  - what the user does during and after the night, and where Start lives;
  - the effect on planned against actual (CALC-37) and progress per target (CALC-38);
  - ADR-016's events, the one-session-in-progress rule and the resume prompt (RD-12);
  - the estimate's provenance (RD-13); UX-13, UX-25, UX-26 and TD-063;
  - the Android constraints;
  - what happens to existing sessions and events (never deleted; still readable);
  - what Stage 8 would implement.
- **Output:** `research/RG-04_EXECUTION_ROLE.md`, with the owner's questions.
- **Out of scope:** metadata-assisted actuals (Stage 8; mentioned only as a later option); code.
- **Acceptance:**
  - every option keeps existing session data readable;
  - the consequences for each CALC and ADR are stated;
  - a recommendation with reasons;
  - the owner's decision recorded in E.1.

##### S4.R3 — Session lifecycle, state display, defaults and the example plan
- **Questions:**
  1. Does the user need a visible draft state, or is the planner simply "the current plan"
     (08 §2)?
  2. What New Session, "+", Duplicate and Open mean; where each lives (one place per action,
     principle 6); and the feedback after each (08 §5, §8).
  3. Are drafts listed, confirmed before replacement, or cleaned up (UX-12)? The S1.6 interim
     stands until then. Inputs: W1, and V3 (does a site change edit a saved plan?).
  4. How the planner shows its identity and state (UX-04; the wireframe's "M42 · Fri, Nov 13 ·
     Draft").
  5. The copy the planner continues on after Start, and its card on Tonight (UX-13; follows
     RG-04).
  6. RD-04: the new draft's defaults (M42, the first rig); whether the example plan adds value
     and how it is labelled (08 §14); the first run (UX-24; P9 as one option).
- **Output:** `research/S4.R3_SESSION_LIFECYCLE.md`, with low-fidelity lifecycle flows.
- **Acceptance:**
  - each owned 08 question is answered with options;
  - the effect on ADR-014's lifecycle is stated; a schema or data change is flagged for its own
    decision;
  - RD-05 (final) and RD-04 decided and recorded.

##### S4.R4 — Tonight, the planner's structure, and disclosure
- **RG-05 (Tonight):**
  - its order (08 §2: the site near the top, the planner near the bottom);
  - where Night, Moon and Weather lead: a planner section, detail screens (P4) or an "Analytics"
    destination, weighed against PD-14 and ADR-015's four tabs;
  - a night picker (UX-11);
  - the run card and the post-Start card (from S4.R2 and S4.R3).
- **RD-06 (the planner):**
  - an order that follows the decision (P2);
  - an answer-first status (P1);
  - repeated facts (UX-03);
  - what may be one tap away (P3); integrity text stays reachable (ADR-009 §4, SI-003);
  - the rig card on every visit (UX-07);
  - the weather card's priority without a score (UX-06).
- **RG-06:** progressive disclosure first; modes (P6) or a density preference (P7) only if the
  evidence asks for them; experts keep full access.
- **Inputs:** 05 §3 (measurements) and §8; 07 §10; 08 §2, §8, §10, §12, §13 and §17; S4.E's
  results, if run.
- **Output:** `research/RG-05_06_TONIGHT_AND_PLANNER.md`, with low-fidelity wireframes of the
  options.
- **Out of scope:**
  - visual design, typography and colour (Stage 5);
  - the capture plan's inner redesign and the chart (Stage 6), beyond their placement.
- **Acceptance:**
  - every option keeps all current content within two levels;
  - each drill-down has a named destination;
  - integrity text complies with ADR-005 and ADR-009 §4, or the document asks the owner to
    amend them;
  - RG-05, RD-06 and RG-06 decided.

##### S4.R5 — The Library's role and the vocabulary
- **RD-07:**
  - should the Library lists select for the plan (TD-053)?
  - is target selection kept there?
  - where does Progress live (08 §19; it depends on RG-04, because Progress is built from actuals)?
  - where does "Add from a photo" sit?
- **RD-14:**
  - one name per concept: rig or equipment; Sessions or Logbook; the dark-window names; the night
    key;
  - how optional custom session names are worded (08 §24; the field itself is Stage 8's).
- **Output:** `research/S4.R5_LIBRARY_AND_VOCABULARY.md`, with a proposed glossary.
- **Acceptance:**
  - the glossary covers every term in UX-18 and 08;
  - RD-07 and RD-14 decided.

##### S4.D — ADR-019 and the wireframe addendum
- ADR-019, "Product flow and information architecture", records the decisions on RG-04, RG-05,
  RG-06, RD-04 to RD-07 and RD-14.
- It amends ADR-015 (§2's section order, the tabs if they change, §7's pickers), and ADR-016 if
  Execution's role changes.
- A new low-fidelity document, `docs/IA_WIREFRAMES_ADDENDUM.md`. `IA_WIREFRAMES.md` stays as it
  is.
- UX-04 and UX-11 recorded as implementation deviations until they are built.
- **Acceptance:**
  - every Stage 4 gate is decided, or deferred by the owner;
  - S4.R1's question matrix is updated with each answer.

##### S4.T — The decisions as provisional Tasks for Stages 5, 6, 8 and 9
- Provisional Task lists go into the Stage 5, 6, 8 and 9 sections (and Stage 7's, where a decision
  touches data entry). Each Task names:
  - the decision it implements;
  - its dependencies;
  - an acceptance sketch.
- Stage 5 gets what the flows need from the design system: state labels, feedback, confirmations
  (with RD-09).
- Those Stages are not frozen here; each Stage's own planning freezes it.
- **Acceptance:**
  - every decision maps to at least one provisional Task, or to an explicit "no change";
  - the §6.2 traceability rows for UX-01 to UX-14 and UX-24 to UX-27 are updated.

##### S4.E — Owner-run quick tests (optional, non-blocking)
- Run from S4.R1's script, whenever the owner can, and before S4.R4 if possible:
  - a five-second look at Tonight and at the planner's first screen ("what is the plan's state?");
  - a first-run try by someone new (a site, a rig, a first plan);
  - red mode in real darkness, including the chart and the tracker.
- A first-run test needs a separate install: the `.s2check` debug package, or another phone.
  Never reset or uninstall the owner's own app.
- Results go into S4.R1's document, or a short evidence note. No personal data about the people
  who try it.
- If they are not run, S4.R4 proceeds on the audit evidence and states the gap (05 §10).

### Stage 5 — Design System Foundation

- **Purpose:** create the reusable visual and interaction system before screens are redesigned
  one by one.
- **Scope:**
  - typography hierarchy and primary/secondary/tertiary text (08 §7);
  - surfaces and cards; spacing;
  - forms (08 §6 underline styling; 08 §22);
  - buttons (UX-34, the button hierarchy, needs verification);
  - icons (08 §14); dividers;
  - statuses: explicit status tokens for the fit states and a neutral "missing input" state
    (UX-16);
  - alerts and dialogs;
  - destructive interactions (RD-09: confirm or undo, including capture-block delete (08 §14)
    and swipe delete (08 §20, UX-38));
  - motion and feedback (08 §5 and §8, feedback on buttons; 08 §20 animations; kept subtle per
    `.agents/rules/05-ui-design.md`);
  - accessibility (at least 48 dp, 200 % text, contrast in light and dark, labels);
  - dark and red-mode constraints (field tokens red or black only; the whole-app red filter;
    ARCHITECTURE B16).
- **Builds on** the `AppPalette` tokens and the presentation style-rules test (TASK 12.4), and
  keeps the Notion-inspired direction while allowing better patterns.
- **Output:**
  - a documented system (tokens, type scale, components, interaction patterns);
  - shared widgets with tests;
  - an adoption plan for Stages 6–9. Stage 5 does not rebuild every screen.
- **Out of scope:** screen redesigns; new product flows.
- **Exit:** the tokens and components exist and are tested (style rules, accessibility, red
  mode) and documented; Stage 5 validation passes.

#### Stage 5 — provisional Tasks from ADR-019 (S4.T, 2026-09-27)

*Provisional (S4.T, 2026-09-27). These come from ADR-019; they are not frozen. This Stage's own
planning re-verifies them against the code (§9.7), then confirms, changes, merges or drops each, and
gives the frozen Tasks their S-IDs. The P-IDs are placeholders and are never reused as S-IDs. Each
Task adopts the RD-14 glossary for the screens it touches.*

| P-ID | Task | ADR-019 | Depends on | Acceptance sketch | Size |
| --- | --- | --- | --- | --- | --- |
| P5.1 | **The shared vocabulary**, in one place like `QuantityText`, with a test against retired terms | §10 | — | The glossary's user-facing words are defined once. A test fails on a retired term ("Equipment profile", "Session planner", "Draft", "Legacy", "True Night Window", "Astro Dusk/Dawn", "Window load", "Acquisition", "Session budget") in `lib/presentation`, against an explicit baseline of today's occurrences that later Stages shrink to empty. Code identifiers are exempt | S |
| P5.2 | **A collapsible section with a factual summary**, its state remembered | §7 | — | The summary states facts, never verdicts. Open or closed is persisted per section key (a display preference, like `ThemeViewModel`). 48 dp; 200 % text; light, dark and field themes; semantics announce the state | S–M |
| P5.3 | **The context line**, site ▾ · night ▾ | §5, §6 | — | One widget for Tonight and the planner. It opens the site picker and the night picker. It shows the site zone rule. Accessible at 200 %; red mode | S |
| P5.4 | **The status block and the state label** | §3, §6 | P5.1 | The verdict headline (Fits · Tight · Doesn't fit · No window · Needs a target / a block) with its reason and key numbers. Explicit status tokens (UX-16, beyond S1.9). The plan-state label (Not saved · Saved · Saved · changed; Tracking · Completed · Partly · Not done · Old log). Field mode red only | S–M |
| P5.5 | **The detail-screen template** | §9 | P5.2 | A title with the context (night, site), a summary block, then the full content. The zone caption once. It is added to the accessibility sweep's pattern | S |
| P5.6 | **Confirmation and feedback patterns** | §3 | RD-09 (decided in this Stage) | The three-way prompt (Save · Discard · Cancel). A short message naming what happened after New, Copy, Open and Save. Confirm or undo for destructive actions, per RD-09. Red mode, no white flash | S–M |

### Stage 6 — Core Planner Redesign

- **Purpose:** apply the approved IA and design system to the main planning experience.
- **Principle:** primary answer → planning action → supporting detail → technical detail.

| Area | Inputs |
| --- | --- |
| Tonight/Home hierarchy | 08 §2; UX-10, UX-11, UX-13, UX-17 (Moon wording); RG-05's outcome |
| Planner identity and state | UX-04 (a wireframe deviation); 08 §8 (the title is truncated, "+" gives no feedback, the date control is unclear); RD-05 |
| Target, night and site context | UX-02; UX-03 (repetition; zone captions are partly required, since every displayed time names its zone); RD-06 |
| Opportunity, "Tonight for this target", chart and timeline | 08 §10, §12; UX-08 (a 24-hour axis on 12-hour devices, labels over the curves, band seams, red-mode bands); ADR-013 (a reason for every excluded period) |
| Conditions and weather presentation | 08 §12 (a compact timeline and weather icons; Stargazing Hub is the owner's reference); UX-06; ADR-012 (no weather score, no good/bad colouring) |
| Sky darkness | 08 §13 (presentation); TD-051 and TD-054 (a darkness row fixed at −18° while the opportunity uses the user's limit) |
| Rig reference | UX-07 |
| Capture Plan | 08 §14 (overload, icons, the example plan per RD-04, deletion per RD-09); UX-09; UX-15(1) after RD-08 |
| Capture outputs | 08 §17: total time and time including intervals stay (the owner's intent). Open for Stage 6: whether integration becomes prominent; what setup/calibration time and "Fit tonight" mean to the user; how an "Unknown" storage estimate is explained (C-13). Assumptions stay reachable |
| Fit communication | UX-01; UX-16 beyond the Stage 1 fix |
| Relative stacking gain | 08 §17 asks for a compact graph. It must stay √N versus one frame per (filter, exposure) group, never physical SNR (SI-003), with its help text reachable |
| Assumptions and progressive disclosure | UX-05; RD-06 (08 §16–§17 lean toward collapsible, on-tap explanations) |
| "What can I image tonight?" (candidates) | UX-29, ties in the default order: RD-10, sorting only, no score |

- **Constraints:**
  - no calculation in widgets (CLAUDE.md trap 13);
  - memoization keys (trap 16);
  - `SessionPlanViewModel` is at 299 of 300 lines (ENG-16), so plan its split before adding
    to it;
  - the E2E keys (trap 19) and the accessibility-sweep routes (trap 17);
  - tokens (trap 12);
  - ADR-015 §2 (sections and order) holds unless RD-06 amends it. *(RD-06 decided 2026-09-27:
    ADR-019 §6 amends it; see the provisional Tasks below. S4.T.)*
- **Out of scope:** new data sources (Stage 7); execution and the Logbook (Stage 8); Settings,
  Library and About (Stage 9).
- **Exit:** each planning screen leads with its answer; every value that was reachable before
  still is; widget, accessibility and E2E tests are updated; Stage 6 validation passes.

#### Stage 6 — provisional Tasks from ADR-019 (S4.T, 2026-09-27)

*Provisional (S4.T, 2026-09-27). These come from ADR-019; they are not frozen. This Stage's own
planning re-verifies them against the code (§9.7), then confirms, changes, merges or drops each, and
gives the frozen Tasks their S-IDs. The P-IDs are placeholders and are never reused as S-IDs. Each
Task adopts the RD-14 glossary for the screens it touches.*

| P-ID | Task | ADR-019 | Depends on | Acceptance sketch | Size |
| --- | --- | --- | --- | --- | --- |
| P6.0 | **Split `SessionPlanViewModel`** before adding to it (ENG-16; trap 11's cap) | — | — | A behaviour-preserving split; every existing test passes unchanged; each ViewModel within the limit | S–M |
| P6.1 | **The plan's lifecycle in the planner** | §3 | P6.0, P5.4, P5.6 | The app bar shows target · night · state (UX-04; DEV-P9's first half). ⋮ holds New plan, Copy to another night, and **Track live (optional)**, which moves Start there so results stay reachable until Stage 8. New plan keeps the site and rig and asks for the target. Each action confirms what happened. Save · Discard · Cancel: Discard deletes; an untouched replaced draft is deleted; a site change and a copy count as unsaved (W1, V3). TD-058 fixed (New, Copy and Open inside the autosave chain). UI-driven tests for each guard path | M |
| P6.2 | **Defaults and the first run** (RD-04) | §3 | P6.1 | Nothing preselected on a fresh install. The seeded rig is labelled as an example. The capture plan starts empty, with "Start from the example plan" (TASK 4.4's badge rule kept). The first-run page is honest (UX-24). "Needs a target / a block" is neutral. The tests that relied on the M42 default are updated deliberately, not weakened | S–M |
| P6.3 | **The planner's structure** | §6 | P5.3, P5.4, P6.1 | Answer-first order: status → context → target and windows → capture plan → conditions summary → rig summary → Save plan (UX-01, UX-02; ADR-015 §2 as amended). Start leaves the bottom bar. Every value that was reachable before still is. The sweep and E2E are updated | M–L |
| P6.4 | **Disclosure in the planner** | §7 | P5.2, P6.3 | Budget details (each ADR-009 line on its own line), the √N help, the assumptions, the rig's rows and sky-darkness detail sit behind factual summaries. The verdict, key numbers, weather age, attribution and unknowns stay visible. Zone captions once per section (the zone rule kept). No modes | M |
| P6.5 | **The Night & Moon and Weather detail screens** | §5, §9 | P5.5 | Two root-navigator routes (`AppRouter` constants), opened from Tonight's rows and the planner's summaries (UX-10). The Weather detail keeps ADR-012: age, stale label, attribution, no score or good/bad colour. The standard twilight names appear only there. Both are in the sweep | M |
| P6.6 | **Tonight, plan first** | §5 | P5.3, P5.4, P6.5 | The context line with a night picker that changes the current plan's night (UX-11; DEV-P9's second half). Then the run card, "Your plan", the rows to the details, and secondary actions. No Start on the card, and no failing Start while a run is in progress (UX-13). A slot for Stage 8's "how did it go?" line | M |
| P6.7 | **The night key at the rollover** (TD-057) | §3 (Y2 depends on correct night keys) | — | The current draft's night key is written at mean solar noon. An open candidates list re-evaluates on a new night | S |
| — | **Acceptance evidence for Stage 6** | §14 | P6.3, P6.6 | A five-second test of Tonight's and the planner's first screens (S4.E's script), recorded as evidence, because S4.E was not run in Stage 4 | — |

These sit alongside, not inside: the chart redesign, the weather timeline and icons, a √N graph,
sky darkness (TD-051, TD-054), the candidates' order (RD-10) and the capture plan's visuals (RD-09).
They stay Stage 6 candidates from its table above.

### Stage 7 — Data Entry & Automation

- **Purpose:** reduce unnecessary manual entry for targets, sites, equipment, capture-plan
  fields and calibration frames, and in forms generally. Several research gates come first.

| Area | Current fact (verified 2026-09-25) | Gate |
| --- | --- | --- |
| Targets | 164 objects from OpenNGC v20260501 (CC BY-SA 4.0). Search matches the catalog id and the common name by substring. 97 objects have no common name; OpenNGC designations are not stored. A custom target needs RA and Dec typed in (08 §4, §9) | RG-07 |
| Sites | Name; latitude and longitude (GPS and map exist; a GPS fix is transient and never written into a saved site without explicit action). Elevation is required but no calculation uses it (SCI-08, F-07). Bortle and SQM are optional, and no calculation uses them. Notes. Place names come only from opt-in Nominatim (PD-12), so naming a site automatically (08 §6) would use that opt-in lookup; changing its default is the owner's privacy decision. The site editor has no discard prompt (UX-21, needs verification). The map is lightpollutionmap.info; the owner asks for lightpollutionmap.app (08 §13) | RG-08, RG-09 |
| Equipment | One verified seed (TASK 8.5). The rig editor is one dialog with 15 fields; pixel size appears twice on one controller; rotation is asked but used by nothing (UX-22). Automation comes from Stage 3 | RG-03; Stage 3 |
| Capture-plan fields | Gain or ISO is descriptive only ("for your records"; SI-004). Binning is validated. The per-frame overhead is a planning preference (ADR-009 §4). White balance and focus are not modelled. The SCI-05 label | RG-11 |
| Calibration frames | A calibration policy per block (in the window, outside it, or from a library; ADR-009 §3). Every block asks for its full parameters (08 §16) | RG-10 |
| Tracking | Tracking type is per rig (ADR-011 §5), and NPF guidance keys on it (PD-11). The seed's tracking is "unknown", so the example plan shows a warning (UX-15(1)) | RD-08 |
| Forms generally | Typing-heavy dialogs (UX-23); the visual styling comes from Stage 5 | — |

- **Rules:**
  - automation only with evidence, licence, provenance and known failure behaviour;
  - privacy documents updated in the same change (trap 22);
  - no scraping; unknown stays unknown;
  - schema changes follow the migration workflow;
  - a new external service needs the owner's approval.
- **Exit:** each area is implemented after its gate, or explicitly deferred by the owner;
  Stage 7 validation passes.

#### Stage 7 — from ADR-019 (S4.T, 2026-09-27)

No provisional Task comes from ADR-019. RD-08 (tracking per rig or per plan) is still decided before
Stage 6's capture-plan work. The site and rig forms adopt the glossary when this Stage touches them.

### Stage 8 — Sessions / Execution / Actuals / Logbook

- **Purpose:** refine the supporting post-plan workflows once the planning experience is stable.
- **Inputs:**
  - Stage 4's ADR on Execution's role; 08 §3, §19 and §24;
  - UX-13; UX-25; UX-26 / RT-10 (RD-12); UX-28, if not closed in Stage 1;
  - UX-27 (rejected as a defect; new scope only if the owner asks); UX-30 (an owner preference
    in 08 §24);
  - SCI-07 (RD-13);
  - TD-056 and ENG-14 (backup and restore with preferences: verify, then fix);
  - TD-063 (moved from Stage 1 by the owner, 2026-09-26): a session detail loaded before Start
    reopens the running session as the planner's plan. The proposed fix (S1.V5 in
    `STAGE_1_REVALIDATION.md`): opening a session uses its current stored state, with a
    UI-driven regression test;
  - the old TASK 17.3, metadata-assisted actuals, once the workflow is known (needs Stage 2).
- **Candidate work:**
  - Execution as optional or primary, per Stage 4; the tracker; what Start means;
  - reconciliation (UX-25: today it corrects counts only ±1 per frame, and the tracker's
    estimate is not shown on the results page);
  - planned versus actual;
  - the Logbook, from the owner's proposals in 08 §24, with scope confirmed in Stage 8
    planning: optional session names (no name field exists today, so this is a schema
    change), search, filters in a panel, a better-structured share output, a clearer "Export
    file" action, and what opening an entry shows. 08 §24's "download" is most likely the
    session detail's Export file button (a download icon that exports the v2 JSON manifest);
    confirm with the owner;
  - where progress per target (CALC-38) lives, per Stage 4;
  - export compatibility: bump `manifest_version` for any incompatible change
    (`docs/EXPORT_MANIFEST.md`).
- **Constraints:** run state only from the events (CLAUDE.md trap 14); snapshots stay immutable;
  one run in progress at a time; any removed or changed workflow migrates its data without loss.
- **Exit:** the Stage 4 decisions are implemented with the data preserved; tests pass;
  Stage 8 validation passes.

#### Stage 8 — provisional Tasks from ADR-019 (S4.T, 2026-09-27)

*Provisional (S4.T, 2026-09-27). These come from ADR-019; they are not frozen. This Stage's own
planning re-verifies them against the code (§9.7), then confirms, changes, merges or drops each, and
gives the frozen Tasks their S-IDs. The P-IDs are placeholders and are never reused as S-IDs. Each
Task adopts the RD-14 glossary for the screens it touches.*

| P-ID | Task | ADR-019 | Depends on | Acceptance sketch | Size |
| --- | --- | --- | --- | --- | --- |
| P8.1 | **Results without a run: domain and data** | §3, §4 | — | ADR-014 §3 as amended: planned → completed ("Completed as planned" or "Partly") and draft/planned → abandoned ("Not done", with a reason). Counts are written as events, so the counters equal the replay (trap 14; ADR-016 §4); the event kind is chosen here. Where "Not done"'s reason lives (column or event; any schema change follows the migration workflow). "Reported as planned" provenance (CALC-37 and CALC-38 notes; RD-13 decided alongside). The export is checked (`manifest_version` bumped only if incompatible). Tests: replay equals counters; old sessions unchanged | M–L |
| P8.2 | **The result form** | §4 | P8.1, P5.6 | `/session/:id/results` becomes "How did it go?": Completed as planned (one tap) · Partly (numbers per light block, pre-filled, not ±1; UX-25) · Not done (reason); optional notes and conditions. The tracker's Finish opens it pre-filled from the confirmed counts. RD-12 decided (the resume prompt's Finish; UX-26). The core-loop E2E test moves to Save → result (trap 19); the live path is tested on its own | M |
| P8.3 | **The next day: the resume rule and Tonight's line** | §3, §4 | P8.1, P6.6, P6.7 | A planned session whose night has passed is not resumed as current; the planner continues on a copy for tonight, not saved. A never-saved draft still rolls forward (TASK 11.4). Tonight's "Last night: …. How did it go?" line opens the result form. No notifications | M |
| P8.4 | **The live mode as an option** | §4 | P6.1 | "Track live (optional)" on a saved plan's entry (and the planner's ⋮, from P6.1). No failing Start (UX-13). TD-063 fixed (opening uses the session's current stored state). The resume prompt, one-run rule and keep-screen-on unchanged | S–M |
| P8.5 | **The Logbook** | §2, §8, §10 | P8.2 | The tab labelled Logbook. Upcoming and Past groups. An entry opens its plan and result. "Export as file". **Progress by target** moved in from the Library (RD-07). The 08 §24 proposals (search, a filter panel, the share output) are scoped by this Stage's planning, not by ADR-019 | M |
| P8.6 | **An optional plan name** (08 §24), if this Stage's planning keeps it | §10 | P8.5 | "Name (optional)"; the Logbook shows the name, else target · night. A schema change with its migration and tests; the export updated | S–M |

### Stage 9 — Secondary UX & Product Polish

- **Scope:**
  - Settings (08 §18; RG-13), including the TD-050 Moon and cloud gate controls unless RD-11
    places them earlier;
  - the Library (08 §19, as decided in Stage 4);
  - About: more prominent authorship and GitHub/Reddit links (08 §23; RD-01 first);
  - a review of sources and attribution (OpenNGC, Open-Meteo, OSM, Nominatim, the
    light-pollution map), consistent with `docs/COMPLIANCE.md` and the privacy policy;
  - licence research (RG-12), implemented only after an owner decision;
  - deletion interactions and animations (08 §20, using Stage 5's patterns);
  - the logo (08 §1). OD-07 says the icon can be replaced; redraw it in both
    `drawable/ic_launcher_foreground.xml` and `tool/make_launcher_icons.py` (trap 20);
  - the splash screen (08 §1), with subtle animation only (`.agents/rules/05-ui-design.md`);
  - final visual consistency.
- **Exit:** the areas above are done or deferred by the owner; Stage 9 validation passes.

#### Stage 9 — provisional Tasks from ADR-019 (S4.T, 2026-09-27)

*Provisional (S4.T, 2026-09-27). These come from ADR-019; they are not frozen. This Stage's own
planning re-verifies them against the code (§9.7), then confirms, changes, merges or drops each, and
gives the frozen Tasks their S-IDs. The P-IDs are placeholders and are never reused as S-IDs. Each
Task adopts the RD-14 glossary for the screens it touches.*

| P-ID | Task | ADR-019 | Depends on | Acceptance sketch | Size |
| --- | --- | --- | --- | --- | --- |
| P9.1 | **The Library manages** (RD-07; TD-053) | §8 | P8.5 (Progress moved out first), P6.1 (the guard) | A tap on a rig, target or site opens or edits, and never changes the plan. Choosing happens only through `/select/…` (a picker mode of the same lists). "Plan this target" starts a new plan under the guard. "Add from a photo" stays in both modes. The Progress row is gone. ADR-015 §7 as amended. UI tests: browsing the Library leaves the plan unchanged | M |
| P9.2 | **The vocabulary completed** | §10 | P5.1 | The remaining screens (Settings, About, Library, the rig editor's "Equipment" labels) use the glossary. The retired-terms baseline from P5.1 is empty | S |

#### Order across Stages for ADR-019 (S4.T)

- **Keep a path to results at every step.** Stage 6 moves Start into ⋮ as "Track live (optional)"
  (P6.1). It never removes Start before Stage 8's result form (P8.1–P8.2) exists.
- **P6.6 leaves a slot** for Tonight's "how did it go?" line; P8.3 fills it.
- **The Library's Progress row goes** (P9.1) only after P8.5 has moved Progress into the Logbook.
- **P5.1's retired-terms baseline** shrinks with each Stage (6, 8, 9) and ends empty at P9.2.
- **Every Stage updates the core-loop E2E test** with the labels it renames (trap 19), and the
  accessibility sweep with the screens it adds (trap 17).

### Stage 10 — Performance & Application Size

- **Principle:** measure first, optimise second.
- **Scope:**
  - profiling form and input lag (08 §22, §26: lag when tapping text fields, especially in the
    rig editor);
  - rebuild analysis; keyboard interaction; Provider notification and rebuild behaviour (the
    memoization rules, trap 16); animation cost;
  - release-mode performance on a low-end device (TASK 15.2's traces were never taken);
  - app size: the difference between APK, AAB, install and download size. The release AAB is
    66.5 MB with three ABIs (TASK 16.2). The ~277 MB in 08 §26 is unmeasured: the build type
    and what was measured are unknown, so **do not treat it as a release-size defect until it
    is measured**;
  - native libraries, assets, fonts and dependencies (including
    `sqlite3_flutter_libs ^0.6.0+eol`, RD-02);
  - device timings for ENG-11 (the Sessions N+1 queries), ENG-12 (first-run seeding) and
    TASK 10.4 (candidates in under 1 s).
- **Exit:** measurements are recorded (method, device, build mode); every optimisation shows
  before-and-after evidence; no functionality is lost.

### Stage 11 — Full Validation & Beta Readiness

- **Purpose:** independent final validation. **No release claim without the required
  evidence.**
- **Scope:**
  - compliance with this plan; the full test suite;
  - an Android emulator and physical devices;
  - lifecycle and process death (`TEST_PLAN.md` L1–L8; TASK 15.4 stays open until then);
  - permissions; offline behaviour;
  - live provider behaviour (Open-Meteo, Nominatim, OSM tiles, the light-pollution map link);
  - metadata formats and equipment import on a device;
  - backup and restore, including the emulator round trip and Auto Backup (TASK 14.4);
  - the refused-database flow of S1.5 on a device: install an older build over a newer
    database (the explanation, no reset), and a below-floor file (confirm, `.bak` kept, the
    app restarts on fresh data). `main.dart`'s wiring is not host-testable;
  - 200 % text; TalkBack (15.3; UX-28); red mode in real darkness (12.4; UX-39);
  - low-end performance (15.2, 10.4);
  - the release build and signing (16.2, the owner's upload key); CI (1.3);
  - compliance: 16.3 (the policy URL live with a contact, Data Safety, a re-check of
    `COMPLIANCE.md`) and AC7 (a dependency, licence, HTTPS and secrets review);
  - manual owner dogfooding with a recorded go/no-go (the missing M3 record);
  - the carried items: the 12.5 owner walkthrough, the 2.4 America/Los_Angeles check, the 16.1
    install and trademark search, the 15.5 emulator E2E, 16.4 beta QA (re-verify Play's
    closed-testing rules), and L7 (upgrade from the beta schema);
  - 16.5 (store listing and runbook), only if the owner decides to release.
- **Exit:** the evidence is recorded (device runs in `TEST_PLAN.md`); no P0/P1 issue is open;
  the owner's go/no-go is recorded.

---

## 6. Traceability: audit findings → Stages

### 6.1 Final Audit confirmed issues → Stage 1

| 07 section | Items | Stage 1 |
| --- | --- | --- |
| §2 Engineering | ENG-01, ENG-02, ENG-03, ENG-05, ENG-06, TASK 3.2 / RT-03; test coverage UX-32 and ENG-04 | A1, A2, A3, A4, A5, A6; D2, E4 |
| §3 Scientific and data | SCI-02, SCI-06, SCI-03, SCI-09, SCI-10 and documentation drift; UX-20 (the data shown) | B1, B2, B3, B4, B5; C1, C2 |
| §4.1 Runtime (reproduced) | ENG-01, ENG-02, RT-03, RT-05 / UX-12, UX-31 | A1, A2, A6, A7 (decision checkpoint), D1 |
| §4.2 Untested behaviour | ENG-08 / RT-04; ENG-12; ENG-14; Drift `LazyDatabase` retry | F; Stage 10; Stage 8; within A6 |
| §9 "before beta" | CI; UX-28; UX-20; UX-16 and UX-15(2) | RD-17; D3; C1; C3 |

### 6.2 Other audit items → Stages

| Finding | 06 verdict | Destination |
| --- | --- | --- |
| UX-01 answer on the planner's last screen | Partially confirmed | Stage 6 (RD-06); **S4.T:** ADR-019 §6 → P6.3 |
| UX-02 section order | Owner decision | RD-06 (Stage 4); **S4.T:** decided (ADR-019 §6) → P6.3 |
| UX-03 repeated facts | Partially confirmed | Stage 6; **S4.T:** ADR-019 §5, §7 → P6.4, P6.5 |
| UX-04 no identity or state in the planner | Confirmed (wireframe deviation) | Stage 6, after Stage 4; **S4.T:** ADR-019 §3 (DEV-P9) → P6.1 |
| UX-05 always-expanded explanations; UX-06 weather card | Documented / owner decision | RD-06, then Stage 6 (within ADR-012); **S4.T:** decided (ADR-019 §7) → P6.4, P6.5 |
| UX-07 rig rows on every visit | Requires verification | Stage 6; **S4.T:** ADR-019 §6–§7 → P6.3, P6.4 |
| UX-08 chart | Partially confirmed | Stage 6; the red-mode bands in Stage 11; **S4.T:** placement ADR-019 §6 (P6.3); the redesign stays a Stage 6 candidate |
| UX-09 capture-plan visuals and delete | Partially confirmed / owner decision | Stages 5–6 (RD-09); **S4.T:** RD-09 (Stage 5) → P5.6; visuals a Stage 6 candidate |
| UX-10 drill-downs; UX-11 night picker | Partially confirmed | Stage 4, then Stage 6; **S4.T:** decided (ADR-019 §5, §9; DEV-P9) → P6.5, P6.6 |
| UX-12 unreachable drafts | Confirmed mechanism / owner decision | A7 checkpoint; RD-05 (Stage 4); Stages 6 and 8; **S4.T:** decided (ADR-019 §3) → P6.1 |
| UX-13 second card after Start | Partially confirmed | Stages 4 and 8; **S4.T:** decided (ADR-019 §4) → P6.6, P8.4 |
| UX-14 Library lists act as pickers (TD-053) | Documented | RD-07 (Stage 4), then Stage 9; **S4.T:** decided (ADR-019 §8) → P9.1 |
| UX-15(1) NPF warning on the seeded rig | Owner decision | RD-08 (Stage 7, decided before Stage 6's capture-plan work) |
| UX-17 Moon wording | Partially confirmed | Stage 6 |
| UX-18 terminology | Confirmed | C4 (IA-independent part); RD-14 (Stage 4); Stage 5 shared vocabulary |
| UX-19 formats | Confirmed | A5, C2; the chart axis in Stage 6 |
| UX-21 site editor | Elevation documented; discard requires verification | Stage 7 (RG-08); Stage 5 form patterns |
| UX-22 rig editor | Partially confirmed | Stage 7 (with Stage 3 import) |
| UX-23 typing | Documented | Stage 7 |
| UX-24 first-run prefill (= ENG-15, SCI-12) | Owner decision | RD-04 (Stage 4); **S4.T:** decided (ADR-019 §3) → P6.2 |
| UX-25 reconciliation ±1 | Confirmed | Stage 8; **S4.T:** decided (ADR-019 §4) → P8.2 |
| UX-26 resume prompt (= RT-10) | Owner decision | RD-12 (Stage 8); **S4.T:** ADR-019 §4; RD-12 decided in P8.2 |
| UX-28 tracker semantics | Requires verification | D3 (verify first); Stage 11 TalkBack |
| UX-29 ties among candidates | Partially confirmed / owner decision | RD-10 (Stage 6) |
| UX-30 Sessions filter bar | Documented (a preference) | Stage 8, as the owner's preference (08 §24) |
| UX-34 button hierarchy; UX-38 swipe-only delete | Requires verification | Stage 5 (RD-09); Stage 11 |
| UX-39 red-mode outlines and bands | Documented; requires verification | Stage 5 constraints; Stage 11 darkness test |
| ENG-04 planner tests on the preferences path | Partially confirmed | E4 (optional) |
| ENG-08 Save/Start race | Requires verification | F (Stage 1) |
| ENG-09 accumulating drafts | Partially confirmed (the UX half) | as UX-12 |
| ENG-11 N+1; ENG-12 first-run seeding | Rejected as a defect / requires verification | Stage 10 (device timing) |
| ENG-13 no retrievable diagnostics | Documented / owner decision | RD-15 (Stage 11) |
| ENG-14 restore keeps stale preferences | Partially confirmed; requires verification | Stage 8 |
| ENG-15 default selection (= SCI-12, UX-24) | Owner decision | RD-04 |
| ENG-16 `SessionPlanViewModel` at its size cap | Documented | A planning note for Stage 6 |
| SCI-04 grid resolution; SCI-05 ISO label | Documented / owner decision | RD-03 (Stage 1); SCI-05 also RG-11 |
| SCI-07 accepted estimates stored as confirmations | Documented | RD-13 (Stage 8) |
| SCI-08 elevation cannot be unknown | Documented | RG-08 (Stage 7) |
| SCI-13 darkness limit (TD-051, TD-054) | Documented | Stage 6 |
| 01: TASK 0.3 holdovers | Owner decision | RD-02 |
| 01: TASK 1.3 CI never ran | Confirmed (process) | RD-17; Stage 11 |
| 01: TASK 6.2 citations | Partially confirmed | B6 |
| 01: G5 property tests | Partially confirmed | E5 (optional) |
| 01: manual checks 12.4, 12.5, 15.2–15.4 | Confirmed (outstanding) | Stage 11 |
| 01: TASK 16.2 and 16.3 owner steps | Owner decision | Owner actions; Stage 11 |
| 01: M3 go/no-go record | Confirmed (absent) | Stage 11 |
| 01: AC7 review | Confirmed (no record) | Stage 11 |
| 01: TD-050 gate UI has no owning task | Confirmed | RD-11 |

Findings 06 rejected or accepted as documented are listed in Appendix C. *(S4.T, 2026-09-27: UX-27,
listed there, is unchanged by ADR-019. The optional live mode keeps today's tracker, and new
countdowns stay new scope.)*

---

## 7. Research gate register (RG)

A gate follows the research workflow (§9.6). Research sessions do not modify production code.
Each gate ends in an owner decision, plus an ADR or specification where one is needed, before
any implementation Task is created.

| ID | Question | Evidence and reason | Stage | Constraints |
| --- | --- | --- | --- | --- |
| RG-01 | **DECIDED 2026-09-26 (S2.R1; ADR-017; DECISIONS E.1).** Which metadata formats are supported, with which libraries and which file-selection path, verified on which real samples? (Resolves PD-21) | TD-018, F-45; MASTER_ROADMAP 17.1–17.2; Stage 0 prompt §7 | 2 (entry) | Header-only, bounded reads; I/O in the data layer; library licences; owner samples only |
| RG-02 | Which metadata identifies the camera, device and optics reliably; what cannot be derived; how are candidates matched to existing equipment, with provenance, confidence and conflict rules? | 08 §11; Stage 0 prompt §7 and §11 | 3 (entry) | No silent writes; unknown stays unknown; ADR-011, ADR-008 §6. **Decided 2026-09-26 (S3.D, ADR-018)** after S3.R1 (`research/RG-02_EQUIPMENT_IDENTITY.md`) |
| RG-03 | Is a sourced catalog of equipment specifications needed, and which source is acceptable (licence, provenance, offline size) under the verified-seed policy? | 08 §11 ("only ZWO"; from the device name or links); UX-22; 05 R13/P8; TASK 8.5 | 3 (informs 7) | No scraping; "reported" provenance; licence terms. **Deferred by the owner 2026-09-26 (S3.D, D2; ADR-018 §8)** |
| RG-04 | **DECIDED 2026-09-27 (S4.R2; DECISIONS E.1): B, the Logbook first and the tracker optional; G2 results after the session.** What role should Execution play (primary, optional, simplified or post-session only), and how are actuals captured without frame-by-frame reporting? | 08 §3, §19, §24; UX-25, UX-27; ADR-016; CALC-37 and CALC-38 | 4 | Keep data and event history; nothing removed before the decision; Android constraints (ADR-016) |
| RG-05 | **DECIDED 2026-09-27 (S4.R4; DECISIONS E.1): Tonight plan-first with a site · night context line; Night & Moon and Weather detail screens; no new tab.** How should Home/Tonight be ordered, where should the Night, Moon and Weather drill-downs lead, and is a separate "Analytics" destination warranted? | 08 §2; UX-10, UX-11; 05 P1/P4 | 4 | PD-14 (no customisable dashboard); no score |
| RG-06 | **DECIDED 2026-09-27 (S4.R4; DECISIONS E.1): progressive disclosure (one tap away, factual summaries); no modes, no density preference for now.** Are separate Basic/Advanced modes needed, or does progressive disclosure suffice? | 05 P6/P7 and §8 decision 1; 07 §10; Stage 0 prompt §8 | 4 | Integrity text reachable in every mode; experts keep access |
| RG-07 | How should the target catalog expand and search improve: sources and licences, common names, cross-identifiers, size on the device, suggestions; an offline catalog or an online name resolver? | 08 §4, §9 | 7 | Offline-first; CC BY-SA handling; the catalog is generated by `tool/build_catalog.dart` and versioned, never hand-edited, and deleted targets must not come back; no scraping |
| RG-08 | Should elevation be retrieved automatically (source, accuracy, licence, privacy), made optional, or dropped, given that no calculation uses it? | 08 §6; SCI-08; UX-21; F-07 | 7 | Unknown is not 0; privacy (a position leaves the device) |
| RG-09 | Can Bortle or SQM be obtained reliably (a dataset or API; the uncertainty of conversions)? Does SQM need to be a user field at all? Should the external map move to lightpollutionmap.app? | 08 §6, §13; PD-05 options C and D (deferred); SI-007 | 7 | No scraping; no Bortle↔SQM conversion without a cited source; secrets outside the code (PD-05 D); privacy and compliance documents updated |
| RG-10 | How do manual imagers actually take darks, flats, bias frames and dark flats; what can inherit from the light frames; how can it be explained briefly, with tips that can be dismissed? | 08 §16; ADR-009 §3; F-39 | 7 | ADR-009's budget semantics stand unless the owner amends them |
| RG-11 | Which capture parameters matter for each camera type (ISO or gain, binning, white balance, focus, interval); which feed a calculation and which are records only; how are they labelled? | 08 §15; SI-004; SCI-05 | 7 | ISO or gain is never "sensitivity"; no camera control; descriptive fields stay descriptive unless a formula is documented |
| RG-12 | Does GPL-3.0 meet the owner's new requirements (free; no monetisation; no modification without the author's permission)? If not, which licence would, and what follows for the bundled CC BY-SA 4.0 data, the dependencies' licences, the store listing and copies already shared? | 08 §23; PD-12 (GPL-3.0 confirmed 2026-09-24); TASK 16.3 | 9 | A dedicated legal/licensing research decision; no change before the owner decides; not legal advice |
| RG-13 | Which settings match real amateur and professional needs, are they understandable, and does each belong in Settings or in context? | 08 §18; TD-050 | 9 | Thresholds stay configurable; no score |
| RG-14 | **DECIDED 2026-09-26 (DECISIONS E.1):** none in Stage 2; per-format adapters afterwards, only with samples; `ExifInterface` and LibRaw rejected. Proprietary RAW (CR2/CR3, NEF, ARW, RAF, RW2, ORF): which formats matter, whether their EXIF values are reachable in a bounded way, and which library or platform facility (if any) meets ADR-017 instead of ad hoc parsers? | Owner, 2026-09-26 (DECISIONS E.1, "Stage 2 format priorities"); `STAGE_2_ARCHITECTURE_REVIEW.md` | 2 (S2.R3) | No ad hoc parsers; bounded I/O; privacy exclusions; licence against GPL-3.0; no image decoding |

---

## 8. Owner decision register (RD)

| ID | Decision | Evidence and known options | Stage | Blocks |
| --- | --- | --- | --- | --- |
| RD-01 | Which GitHub account carries the project identity: `chacha12` (the application id `io.github.chacha12.astroplanner`, the `AppIdentity` source and policy URLs, the user agent, the git user) or `Buffur` (the remote `github.com/Buffur/Astro-Planner`; the owner's links in 08 §23)? | OD-07 asked for confirmation before the first upload; the application id is permanent once published | Before any store upload; before Stage 9's About and links | Upload; privacy-policy URL; About links; the CI remote |
| RD-02 | The TASK 0.3 holdovers: the Google ADK skill and `skills-lock.json`; retaining `docs/archive/`; `sqlite3_flutter_libs ^0.6.0+eol` | 01 TASK 0.3; `TECH_DEBT.md`'s cleanup list | 1 (hygiene); 10 (the dependency, with a device check) | — |
| RD-03 | **RESOLVED 2026-09-25 (Stage 1 planning; DECISIONS E.1).** SCI-05: neutral label "ISO / gain (for your records)" now (S1.8). SCI-04: documentation only (S1.13). *(Was: wording rulings: the ISO/gain "Sensitivity setting" label (SCI-05); a resolution caveat for times on the 5-minute grid (SCI-04).)* | 07 §6 item 8 | 1 | B7 |
| RD-04 | **DECIDED 2026-09-27 (S4.R3; DECISIONS E.1): nothing preselected on the first run; New keeps the site and rig and asks for the target; an empty capture plan with "Start from the example plan".** New-draft defaults: should a new draft pre-select M42 and the first rig, and how are defaults and the "Example plan" labelled or offered? 08 §14 asks whether the example plan adds value | ENG-15, SCI-12, UX-24; TASK 4.4 | 4 | Stage 6 |
| RD-05 | **DECIDED 2026-09-27 (S4.R3; DECISIONS E.1): L1 (Draft internal; Not saved / Saved / Saved · changed; Save explicit), Y2 (yesterday's saved plan stays on its night; the planner continues on a copy), U1 (Save · Discard · Cancel; Discard deletes; V3 and W1 count as unsaved).** Drafts and "New session": is a separate draft stage needed (08 §2)? Are unsaved drafts listed, confirmed before being replaced, or cleaned up (UX-12)? What do "+", New Session and Duplicate do, and how is the state shown (08 §5)? | TASK 11.3's owner decision (drafts are not listed); ADR-014. **Interim decided 2026-09-25 (Stage 1 planning):** confirm before a draft with unsaved changes is replaced (S1.6); the rest stays open for Stage 4. **Input from Stage 1 validation (V3, owner, 2026-09-25):** a site change on a saved plan turns the stored session into a draft ("Planned, unsaved changes", still listed) but does not count as unsaved while the app runs, so New does not ask; after a restart it does. Decide whether a site change edits a saved plan | 4 (an interim safeguard can be decided in Stage 1) | A7; Stage 6 |
| RD-06 | **DECIDED 2026-09-27 (S4.R4; DECISIONS E.1): answer first, then decision order (amends ADR-015 §2); the budget breakdown, √N help, assumptions, weather variables and rig rows one tap away (ADR-009 §2's "own line" within the budget details).** May the planner's section order change (ADR-015 §2)? May assumptions, the √N help and heuristic notes be one tap away instead of always expanded? | UX-02, UX-05, UX-06; 08 §16–§17 prefer collapsible, on-tap explanations | 4 | Stage 6 |
| RD-07 | **DECIDED 2026-09-27 (S4.R5; DECISIONS E.1): the Library manages (a tap never changes the plan; "Plan this target"); choosing happens in the planner, Tonight's context line and the first run; Progress moves to the Logbook.** The Library's role: should its lists select for the current plan (TD-053), keep target selection, and where does Progress live (08 §19)? | ADR-015 §7; TASK 14.2 | 4 | Stages 6 and 9 |
| RD-08 | Tracking per rig (ADR-011 §5) or per plan/session (08 §21)? What does the seeded rig declare (UX-15(1))? | PD-11: NPF guidance keys on the rig's tracking | 7, decided before Stage 6's capture-plan work | Stage 6 capture plan; Stage 7 |
| RD-09 | Destructive interactions: confirm or undo, including deleting a capture block and swipe-to-delete | UX-09, UX-38; 08 §14, §20; `IA_WIREFRAMES.md` §3 (no destructive action without confirmation) | 5 | Stages 6–9 |
| RD-10 | Ordering Tonight's candidates without a score: a secondary sort, thresholds, or grouping of ties | UX-29; ADR-013 §5 | 6 | — |
| RD-11 | Where the ADR-013 optional Moon and cloud gate controls live (TD-050): in Settings (Stage 9) or earlier, in the planner | 01; 07 §6 item 10 | 6 or 9 | — |
| RD-12 | Should the resume prompt's Finish complete the session at once, or open reconciliation like the tracker's Finish? | RT-10, UX-26; ADR-016 §11 | 8 | — |
| RD-13 | Should an accepted frame estimate carry "estimated" provenance (ADR-008 §6) instead of being stored as a confirmation (ADR-016 §3)? | SCI-07 | 8 | — |
| RD-14 | **DECIDED 2026-09-27 (S4.R5; DECISIONS E.1): Rig; Plan; Logbook; the glossary in `research/S4.R5_LIBRARY_AND_VOCABULARY.md` §5.** Vocabulary: rig or equipment; Sessions or Logbook; the names of the dark window and the night key | UX-18; 08 uses "Logbook" and "Planner" | 4 | Stage 5's shared vocabulary; limits C4 |
| RD-15 | Does the beta need a local diagnostics export (`AppLog`)? | ENG-13; crash reporting is deferred for privacy | 11 (planning) | Beta triage |
| RD-16 | **RESOLVED (owner, 2026-09-26, S3.D; ADR-018 §7):** visible at the end of Stage 3 (S3.7), as "Add from a photo" on the equipment screen. Earlier: **resolved for Stage 2 (owner, 2026-09-26):** hidden throughout Stage 2; Stage 3 decides visibility. *(Was: when and where the metadata feature becomes visible (the PD-06 gate): at the end of Stage 2, or Stage 3.)* | PD-06; `FeatureScope` | 2 (3) | — |
| RD-17 | Push the CI workflow to the remote and observe a first run (TASK 1.3), given RD-01 and the repository's visibility. **Included in Stage 1 (owner, 2026-09-25) as S1.14**; **the push was deferred by the owner when S1.14 ran (2026-09-25)**: open again, for Stage 11 or an owner request | 06 §2; 07 §9 | 1 (optional) or 11 | — |

**Answered in part by Stage 0:** the direction part of 07 §6 item 11 (the primary 1.0 user),
in `PRODUCT_DIRECTION.md` §2. The focus stays on manual and semi-automated imagers, and less
experienced users are served by removing unnecessary expert entry. The question of separate
modes stays open as RG-06.

**Owner actions** (not decisions; they block release, not refinement; tracked in
`PROGRESS.md`):
- the upload key, `key.properties` and SDK cmdline-tools (16.2);
- the privacy policy published with a contact email and its URL live, the repository made
  public, the Data Safety form (16.3);
- a formal trademark search (OD-07);
- a device or emulator for Stage 11, and earlier where useful;
- real metadata sample files (Stage 2).

---

## 9. Workflow rules

These rules restate the post-roadmap governance in `CLAUDE.md` for Stage work. Where the two
differ, `CLAUDE.md` wins.

### 9.1 Stage workflow (default)

```text
1. Fresh Opus 5.5 chat
2. Read the current Stage and the repository state
3. Verify the prerequisites
4. Create the Stage execution plan
5. Identify research gates and owner decisions
6. Freeze the approved Task sequence
7. Execute the Tasks sequentially
8. One coherent Task per implementation session or chat, where practical
9. Validate each Task
10. Commit each completed Task
11. Fresh, independent Stage validation
12. Create focused fix Tasks if validation finds issues
13. Close the Stage
14. Update PROGRESS.md
15. Start the next Stage in a fresh chat
```

### 9.2 Task sizing

A good implementation Task normally has one primary behavioural objective, one coherent
scope, explicit dependencies, an explicit out-of-scope list, objective acceptance criteria,
and one complete validation loop.

- Do not optimise for the most lines changed.
- Do not create artificially tiny Tasks when one coherent behaviour spans several layers.
  Cross-layer work is acceptable when every change serves the same behavioural objective.
- Decompose a Task that combines several independent decisions or needs unresolved research.
- As a rough continuity with the previous roadmap: **S**, a focused, local Task; **M**, one
  coherent cross-layer behaviour; **L**, usually decomposed unless highly cohesive; **XL**,
  never an implementation Task.

### 9.3 Prompts and context for future sessions

Prompts do not paste the entire repository history or all the audits. Each prompt names:

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

The agent then inspects implementation files just in time. The repository documentation is the
persistent memory. Do not repeatedly paste the full Master Roadmap, all the audit reports, old
chat transcripts or large architecture summaries; refer to exact files and finding IDs instead.
Owner-supplied prompt files are kept in `docs/refinement/prompts/`. A prompt is the scope of its
own session only.

### 9.4 Standard implementation workflow

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

The agent does not stop after planning if the approved Task can be implemented, and does not
begin the next Task automatically.

### 9.5 Scope-drift rule

> If an adjacent issue is discovered, document it but do not fix it unless fixing it is
> necessary to satisfy the current task's acceptance criteria.

> If the current task turns out to require a materially larger architectural change than its
> approved scope, stop before implementing the out-of-scope portion, document the reason, and
> propose a decomposition.

Ordinary implementation complexity alone is **not** a reason to stop. If the Task is coherent
and achievable within scope, complete it fully.

### 9.6 Research workflow

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

Research and implementation normally happen in separate sessions. Research does not silently
modify production code. A hypothesis does not become an implementation Task because one
solution looks practical.

### 9.7 Stale-finding rule

> Before modifying code for an audit finding, verify the cited mechanism still exists. If later
> changes already resolved or materially changed it, report the discrepancy rather than
> implementing an obsolete fix.

### 9.8 Validation model

**Task validation,** inside the implementation Task: targeted tests; the affected regression
tests; analyzer and formatting; the quality gate (`dart run tool/check.dart`); and explicit
verification of each acceptance criterion.

**Stage validation,** in a fresh session after the Stage's Tasks are complete. The validator
tries to disprove that the Stage is complete. Default instruction:

```text
Do not implement fixes during validation.
Verify the Stage against its defined acceptance criteria.
Look for regressions, scope drift, incomplete tasks, stale assumptions,
architecture violations, scientific-integrity issues, and missing evidence.
```

Findings that survive review become focused fix Tasks.

### 9.9 Documentation duties

- After every Task, update `PROGRESS.md`: the Task, its commit, and the finding IDs it resolved.
- Keep the living registers current, as `CLAUDE.md`'s conventions require:
  - `FEATURE_STATUS.md`;
  - `TECH_DEBT.md` (mark items resolved with the date and commit; never delete them);
  - `ARCHITECTURE.md` and `DATA_MODEL.md` Part B;
  - `SCIENTIFIC_INTEGRITY.md` for any calculation;
  - `DECISIONS.md` for any formula, architecture or product decision, including resolved RG
    and RD items.
- When a Task takes an audit finding, record the audit ID in the relevant living register.
- Never edit `docs/audit/*`, `PROJECT_AUDIT.md`, `MASTER_ROADMAP.md`, `ROADMAP.md`'s history or
  `docs/archive/`.

### 9.10 Reading older governance after Stage 0

- `.agents/rules/00-project-governance.md` says "treat the roadmap phase as the active scope".
  After Stage 0 that means the approved refinement Stage and Task.
- OD-06's "one roadmap TASK per cycle" continues as "one approved refinement Task per cycle".
- Approval follows `CLAUDE.md`: an owner-supplied implementation Task prompt approves that
  Task completely. A new, unresolved architecture, data-model, scientific, product,
  external-provider, licensing or scope decision still needs its gate and the owner.

---

## 10. Relationship to historical documents

- **Historical, preserved and not rewritten:** `MASTER_ROADMAP.md`; `ROADMAP.md` (its "Active
  task line" stays frozen at "Next: TASK 16.4"); `PRODUCT_SPEC.md` (design intent);
  `IA_WIREFRAMES.md` (ADR-015 intent); `PROJECT_AUDIT.md`; `docs/audit/*`; `docs/archive/`.
- **Living, updated by refinement Tasks under `CLAUDE.md`'s conventions:**
  `PROJECT_HANDOFF.md`; Parts B and C of `ARCHITECTURE.md` and `DATA_MODEL.md`;
  `FEATURE_STATUS.md`; `TECH_DEBT.md`; `DECISIONS.md`; `SCIENTIFIC_INTEGRITY.md`;
  `TEST_PLAN.md`; `EXPORT_MANIFEST.md`; `COMPLIANCE.md`; `RELEASE.md`; `docs/privacy/`.
- **Superseded as operational guidance:** see `PRODUCT_DIRECTION.md` §9 (the roadmap as the
  task queue; Plan → Execute → Log as the central loop; G17's timing).

---

## Appendix A — Manual dogfooding report (08) → Stages

Classification key: **HO** human observation · **IN** author/product intent · **PS** proposed
solution · **RQ** research question · **PR** preference or subjective. A proposed solution is
recorded, not approved.

| 08 § | Topic | Classification: content | Current repository fact | Home | Gate |
| --- | --- | --- | --- | --- | --- |
| Intro | General objective | IN: reconsider the app's logic, remove unnecessary actions, automate data retrieval, keep the Notion direction without being constrained by it | — | `PRODUCT_DIRECTION.md`; Stages 4–9 | — |
| 1 | Logo and loading screen | PR: dislikes the logo's execution. PS: propose alternatives, choose a direction. PS: a subtle animated splash | The icon is original and replaceable (OD-07), drawn in two places (trap 20); `.agents/rules/05`: no excessive animation | Stage 9 | — |
| 2 | Home screen | HO: Geolocation sits near the top and the Planner near the bottom. RQ: is a separate Draft needed? HO: Night, Moon and Weather open the planner at its top (= UX-10). PS: deep-link to the section; an "Analytics" tab; rethink their purpose | Tonight rows call `openPlanner` (UX-10); drafts are hidden by owner decision (TASK 11.3) | Stage 4, then Stage 6 | RG-05, RD-05 |
| 3 | Start / execution | IN/HO: in a real session users will not report each frame. PS: simplify or remove; mark the result in the Logbook as Completed or Not completed | ADR-016 execution; CALC-37 and CALC-38 depend on confirmed counts; not removed in Stage 0 | Stage 4 (decision), then Stage 8 | RG-04 |
| 4 | "What can I image tonight?" | IN: the catalog is useful. HO: typing degrees, names and coordinates is inconvenient, and the values must be looked up elsewhere. PS: expand the catalog; full search, autocomplete, intelligent search, search by common name | Substring search on the catalog id and common name already exists; 97 of 164 objects have no name; no cross-identifiers; 164 objects (§1.3 item 6); UX-29 ties | Stage 7; the candidates list in Stage 6 | RG-07; RD-10 |
| 5 | New Session | HO: its purpose is unclear; new and existing are not distinguished; "+" gives no feedback. RQ: define the difference. PS: show the state; give feedback | "+" (New Session) and Duplicate are icon-only app-bar actions (UX-35 was rejected as a preference; 08 now supplies human evidence); UX-04; UX-12 | Stages 4, 5 and 6 | RD-05 |
| 6 | Geolocation (site form) | HO: too many fields; users don't know elevation, Bortle or SQM. PS: name the site automatically from the location; fill coordinates automatically. RQ: elevation automatic or not required; Bortle automatic; is SQM needed; are notes needed. PR: field underlines too prominent | No calculation uses elevation, Bortle or SQM (§1.3 item 10); place names are opt-in (PD-12); GPS and map picking exist (transient) | Stage 7; field styling in Stage 5 | RG-08, RG-09 |
| 7 | Typography and hierarchy | HO: nearly all text is white, and secondary information weighs as much as primary. PS: a full typography audit | UX-16 confirmed; UX-33 rejected as a defect (a preference), and the owner's intent drives this as design-system work | Stage 5 | — |
| 8 | Planner | HO: the title is truncated ("Session plan…"); "+" gives no feedback; the date icon is not intuitive | The app bar holds "Session planner", "+", Duplicate and the field-mode button; UX-04 | Stage 6 (with Stage 5 feedback patterns) | RD-05 |
| 9 | Targets | HO: the same catalog problem; adding a target requires RA and Dec. PS: expand; intelligent search; common names. RQ: what must the user enter, and what can come from a catalog? | Every calculation needs coordinates; automation means a catalog lookup (offline) or a name resolver (online, behind a gate) | Stage 7 | RG-07 |
| 10 | Tonight for this target | HO: the graph is unattractive and not intuitive; the information block is overloaded. PS: most important first, details second | UX-08, UX-03, UX-17; ADR-013 reasons | Stage 6 | — |
| 11 | Equipment | HO: flat; only ZWO is offered; too many required fields. RQ: why only ZWO; retrieve specifications automatically, from the device name, from links, from metadata | TASK 8.5 verified-seed policy (§1.3 item 9); "from links" would be scraping, which is rejected; UX-22 | Stage 3; forms in Stage 7 | RG-02, RG-03 |
| 12 | Conditions & timeline | HO: flat, continuous text, weak hierarchy, unclear relationships. PS: study Stargazing Hub (a concise timeline, visualisation, weather icons) | ADR-012: no weather score, no good/bad colouring (icons show values, not verdicts); UX-06 | Stage 6 (icons from Stage 5) | — |
| 13 | Sky darkness & timeline | RQ: can Bortle be automatic? HO: flat and overloaded. PS: point the map link to lightpollutionmap.app | The link goes to lightpollutionmap.info (PD-05 option A); TD-051, TD-054 | Stage 7 (source and link); Stage 6 (presentation) | RG-09 |
| 14 | Capture plan | HO: flat and overloaded. RQ: what does the example plan add? PR/HO: the drag-handle and delete icons. HO: deletion is immediate. PS: a safer deletion flow | The "Example plan" badge (TASK 4.4); block delete has no confirmation or undo (UX-09) | Stage 6; Stage 5 (deletion); Stage 4 (example plan) | RD-04, RD-09 |
| 15 | Capture-plan parameters | RQ: why type binning; can it be detected? RQ: why choose between ISO and gain? IN: the intended controls are ISO, white balance, focus and an optional interval. PS: a focus slider | Gain/ISO is descriptive only (SI-004); white balance and focus are not modelled; the interval corresponds to the per-frame overhead preference (ADR-009 §4); no camera control | Stage 7 | RG-11 |
| 16 | Dark, flat, bias | PS: inherit from the light frames (darks need only a count). RQ: research real flat and bias workflows. PS/PR: short explanations that can be turned off, not a tutorial | A calibration policy per block (ADR-009 §3); F-39 | Stage 7 | RG-10 |
| 17 | Capture-plan outputs | HO: visual noise; everything the same colour; small text; weak hierarchy. IN: keep total time and time including intervals. RQ: is setup/calibration time needed; should integration be prominent; what does "Fit tonight" mean; what is Assumptions for? IN: √N is a core feature. PS: a compact graph. PS/PR: the explanation collapsible, on tap, or optional. HO: storage is not calculated | Storage shows "Unknown" by design (§1.3 item 7); √N must stay relative (SI-003); setup and outside-window calibration belong to ADR-009's session budget; assumptions must stay reachable | Stage 6 | RD-06 |
| 18 | Settings | RQ: practicality, clarity and real-world needs, from reliable sources; which settings belong in context | TD-050 (no gate controls); the stale overhead text is UX-20 (Stage 1, C1) | Stage 9 | RG-13, RD-11 |
| 19 | Library | RQ: why select a device here (it duplicates the planner)? What is target selection for? Does Progress duplicate Start? HO: Geo makes sense here | Library pickers select for the current session (TD-053, ADR-015 §7); Progress = integration per target from completed sessions (CALC-38) | Stage 4, then Stage 9 | RD-07 |
| 20 | Deletion and animations | HO: the item slides away, a red block appears, the confirmation lingers; it feels unfinished. PS: redesign the animation and the confirmation | Swipe-to-delete with a confirmation dialog (UX-38, needs verification) | Stage 5; Stage 9 | RD-09 |
| 21 | Tracked | PS: tracking belongs to the plan or session, not the device | Tracking is per rig (ADR-011 §5); NPF guidance keys on it (PD-11) | Stage 7 (decide before Stage 6's capture-plan work) | RD-08 |
| 22 | Forms and data entry | HO: forms feel flat; noticeable lag when tapping a text field, especially in the device form. PS: investigate performance, the keyboard, rebuilds, animations, state management, component count and keyboard delay | The rig editor is one dialog with 15 text fields (05 §3.1); no device profile exists (TASK 15.2 measured the host only) | Stage 5 (forms); Stage 10 (measure) | — |
| 23 | Authorship and links | IN: authorship more prominent; GitHub `Buffur` and Reddit links, Reddit being important. IN/RQ: licence requirements (free; no monetisation; no modification without permission); verify the current licence; propose an alternative; review Sources | GPL-3.0 confirmed (PD-12); About states GPL-3.0 with a `chacha12` source link; the remote is Buffur (§1.3 items 3 and 4) | Stage 9 | RG-12, RD-01 |
| 24 | Logbook | PS: optional custom session names; search; filters behind a panel; a better-structured share output. RQ: what does the "download" action download; a download history? HO: opening an entry shows the tracker again | No session-name field; Export file (a download icon) writes the v2 JSON manifest; share is plain text; the filters follow TASK 14.1 (UX-30 is a preference) | Stage 8 (naming via RD-14 in Stage 4) | RD-14 |
| 25 | Overall UI/UX | IN: a major standalone task; the listed problems; keep the Notion identity without being constrained by it; aim for clear, lightweight, structured, practical, modern, uncluttered | Density is concentrated in the planner (05 §0) | `PRODUCT_DIRECTION.md`; Stages 4–6 and 9 | — |
| 26 | Performance and size | HO: about 277 MB. PS: analyse and reduce without losing functionality. HO: lag while entering data | Release AAB 66.5 MB (TASK 16.2); the 277 MB figure's build type is unknown | Stage 10 | — |
| 27 | Task priorities | IN: the critical list (manual entry, duplicated workflows, the Planner/Start/New Session logic, location automation, the overloaded capture plan, presentation, form lag, deletion, `Tracked`), a redesign list, automation, a design system, technical optimisation | — | Informs Stages 3–10; the order follows the Stage 0 prompt, which is later | — |
| 28 | Final objective | IN: which features are useful; which data can be automated; how to present the rest; propose an updated structure | — | `PRODUCT_DIRECTION.md`; Stage 4's output | — |

---

## Appendix B — Carried roadmap work

| Item | State at Stage 0 | Destination |
| --- | --- | --- |
| 0.3 hygiene holdovers | Partial; owner decision | RD-02 |
| 1.3 CI | The script works; the workflow has never run | RD-17; Stage 11 |
| 2.4 America/Los_Angeles emulator check | Unverified on a device | Stage 11 |
| 3.2 reset path (TD-047, UI half) | Partial | Stage 1, A6 |
| 4.4 DEV-P2 statement | Documentation error | Stage 1, B5 |
| 6.2 citations; G5 property tests | Partial | Stage 1, B6 and E5 |
| 10.4 candidates timing on a device | Unverified | Stages 10–11 |
| 10.5 azimuth and horizon | Cut (deferred) | Stays deferred |
| 12.4 darkness checklist | Owner checklist | Stage 11 |
| 12.5 owner walkthrough | Owner checklist (08 is dogfooding, not this recorded walkthrough) | Stage 11 |
| 14.4 emulator round trip; Auto Backup | Unverified | Stage 11 |
| 15.2 device profile traces | Partial | Stages 10–11 |
| 15.3 TalkBack walkthrough | Partial | Stage 11 (UX-28 verified in Stage 1) |
| 15.4 device rows L1–L8 | **Open** | Stage 11 |
| 15.5 E2E on an emulator | **Open** | Stage 11 |
| 16.1 install test; trademark search; account | Unverified; owner | Stage 11; RD-01 |
| 16.2 signed AAB; release install | **Open** (owner's upload key) | Owner action; Stage 11 |
| 16.3 policy URL live, contact, Data Safety, public repository | **Open** (owner) | Owner action; Stage 11 |
| 16.4 beta and release QA | Not started | Stage 11 |
| 16.5 store listing and runbook | Not started | After Stage 11, only if the owner decides to release |
| 17.1, 17.2 | Not started | Stage 2 |
| 17.3 assisted actuals | Not started | Stage 8 |
| PD-21 metadata formats | Resolved 2026-09-26 (ADR-017: DNG now, FITS on a sample) | RG-01 (decided) |
| M3 dogfooding go/no-go | No record | Stage 11 |
| AC1–AC7 records; milestone tags | No records | AC7 in Stage 11; others optional |
| TD-018, TD-020, TD-025, TD-037, TD-038, TD-045, TD-049, TD-051, TD-053, TD-054, TD-056 | Open in `TECH_DEBT.md` | TD-018 in Stage 2; TD-051 and TD-054 in Stage 6; TD-053 via RD-07; TD-056 in Stage 8; the others only alongside related work |
| TD-050 | Open | RD-11 |

---

## Appendix C — Findings rejected or accepted as documented

None of these is scheduled as a defect. Findings 06 rejected are not revived without new
repository evidence (§2). Findings 06 accepted as documented are handled only where the last
column says so.

| Finding | 06 verdict | Condition for reopening, or where it is handled |
| --- | --- | --- |
| ENG-07 unused repository providers | Rejected (no rule broken) | A tidy-up only alongside related work |
| ENG-09, its performance half | Rejected (no evidence at realistic volumes) | A measurement in Stage 10 |
| ENG-10 weather cache never evicted | Rejected | A measurement of the preferences file's size (Stage 10) |
| ENG-11 N+1 queries, as a defect | Rejected (host: 198 ms for 200 sessions) | A device timing (Stage 10) |
| UX-15(3) "Current Altitude −27.5°" | Rejected (the label says "current") | — |
| UX-27 "window opens in" countdown | Rejected (outside TASK 13.3's scope) | Only as new scope requested by the owner (Stage 8) |
| UX-33 heading inflation | Rejected (a preference) | Typography is Stage 5 design work driven by 08 §7, not a revived defect |
| UX-35 icon-only app-bar actions | Rejected (a preference) | 08 §5 and §8 supply human evidence about "+"; handled in Stages 4 and 6 as owner-observed UX |
| UX-36 card affordance; UX-37 white snackbar; UX-40 top-of-screen toggle | Rejected (preferences) | New evidence only |
| SCI-04 grid bias | Documented and acceptable | Only its wording (RD-03) |
| SCI-07 accepted estimates | Documented (ADR-016 §3) | RD-13 |
| SCI-08 elevation | Documented (F-07) | RG-08 |
| SCI-13 darkness limit | Documented (TD-051, TD-054) | Stage 6 presentation |
| UX-14 Library lists act as pickers | Documented (TD-053) | RD-07 |
| UX-23 typing in plan editing | Documented (a trade-off) | Stage 7 forms |
| UX-30 Sessions filter bar | Documented (required by TASK 14.1) | The owner's 08 §24 preference, Stage 8 |
| UX-39 red-mode limits | Documented (ARCHITECTURE B16) | Stage 11 darkness test |
| ENG-16 ViewModel at its size cap | Documented | A Stage 6 planning note |
| AC5 preferences exception | Documented (the owner's TASK 11.4 decision) | — |
