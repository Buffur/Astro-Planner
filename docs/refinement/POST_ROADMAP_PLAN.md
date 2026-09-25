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
  - smartphone behaviour (35 mm-equivalent focal lengths, binned versus full resolution);
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
  - ADR-015 §2 (sections and order) holds unless RD-06 amends it.
- **Out of scope:** new data sources (Stage 7); execution and the Logbook (Stage 8); Settings,
  Library and About (Stage 9).
- **Exit:** each planning screen leads with its answer; every value that was reachable before
  still is; widget, accessibility and E2E tests are updated; Stage 6 validation passes.

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

### Stage 8 — Sessions / Execution / Actuals / Logbook

- **Purpose:** refine the supporting post-plan workflows once the planning experience is stable.
- **Inputs:**
  - Stage 4's ADR on Execution's role; 08 §3, §19 and §24;
  - UX-13; UX-25; UX-26 / RT-10 (RD-12); UX-28, if not closed in Stage 1;
  - UX-27 (rejected as a defect; new scope only if the owner asks); UX-30 (an owner preference
    in 08 §24);
  - SCI-07 (RD-13);
  - TD-056 and ENG-14 (backup and restore with preferences: verify, then fix);
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
| UX-01 answer on the planner's last screen | Partially confirmed | Stage 6 (RD-06) |
| UX-02 section order | Owner decision | RD-06 (Stage 4) |
| UX-03 repeated facts | Partially confirmed | Stage 6 |
| UX-04 no identity or state in the planner | Confirmed (wireframe deviation) | Stage 6, after Stage 4 |
| UX-05 always-expanded explanations; UX-06 weather card | Documented / owner decision | RD-06, then Stage 6 (within ADR-012) |
| UX-07 rig rows on every visit | Requires verification | Stage 6 |
| UX-08 chart | Partially confirmed | Stage 6; the red-mode bands in Stage 11 |
| UX-09 capture-plan visuals and delete | Partially confirmed / owner decision | Stages 5–6 (RD-09) |
| UX-10 drill-downs; UX-11 night picker | Partially confirmed | Stage 4, then Stage 6 |
| UX-12 unreachable drafts | Confirmed mechanism / owner decision | A7 checkpoint; RD-05 (Stage 4); Stages 6 and 8 |
| UX-13 second card after Start | Partially confirmed | Stages 4 and 8 |
| UX-14 Library lists act as pickers (TD-053) | Documented | RD-07 (Stage 4), then Stage 9 |
| UX-15(1) NPF warning on the seeded rig | Owner decision | RD-08 (Stage 7, decided before Stage 6's capture-plan work) |
| UX-17 Moon wording | Partially confirmed | Stage 6 |
| UX-18 terminology | Confirmed | C4 (IA-independent part); RD-14 (Stage 4); Stage 5 shared vocabulary |
| UX-19 formats | Confirmed | A5, C2; the chart axis in Stage 6 |
| UX-21 site editor | Elevation documented; discard requires verification | Stage 7 (RG-08); Stage 5 form patterns |
| UX-22 rig editor | Partially confirmed | Stage 7 (with Stage 3 import) |
| UX-23 typing | Documented | Stage 7 |
| UX-24 first-run prefill (= ENG-15, SCI-12) | Owner decision | RD-04 (Stage 4) |
| UX-25 reconciliation ±1 | Confirmed | Stage 8 |
| UX-26 resume prompt (= RT-10) | Owner decision | RD-12 (Stage 8) |
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

Findings 06 rejected or accepted as documented are listed in Appendix C.

---

## 7. Research gate register (RG)

A gate follows the research workflow (§9.6). Research sessions do not modify production code.
Each gate ends in an owner decision, plus an ADR or specification where one is needed, before
any implementation Task is created.

| ID | Question | Evidence and reason | Stage | Constraints |
| --- | --- | --- | --- | --- |
| RG-01 | Which metadata formats are supported, with which libraries and which file-selection path, verified on which real samples? (Resolves PD-21) | TD-018, F-45; MASTER_ROADMAP 17.1–17.2; Stage 0 prompt §7 | 2 (entry) | Header-only, bounded reads; I/O in the data layer; library licences; owner samples only |
| RG-02 | Which metadata identifies the camera, device and optics reliably; what cannot be derived; how are candidates matched to existing equipment, with provenance, confidence and conflict rules? | 08 §11; Stage 0 prompt §7 and §11 | 3 (entry) | No silent writes; unknown stays unknown; ADR-011, ADR-008 §6 |
| RG-03 | Is a sourced catalog of equipment specifications needed, and which source is acceptable (licence, provenance, offline size) under the verified-seed policy? | 08 §11 ("only ZWO"; from the device name or links); UX-22; 05 R13/P8; TASK 8.5 | 3 (informs 7) | No scraping; "reported" provenance; licence terms |
| RG-04 | What role should Execution play (primary, optional, simplified or post-session only), and how are actuals captured without frame-by-frame reporting? | 08 §3, §19, §24; UX-25, UX-27; ADR-016; CALC-37 and CALC-38 | 4 | Keep data and event history; nothing removed before the decision; Android constraints (ADR-016) |
| RG-05 | How should Home/Tonight be ordered, where should the Night, Moon and Weather drill-downs lead, and is a separate "Analytics" destination warranted? | 08 §2; UX-10, UX-11; 05 P1/P4 | 4 | PD-14 (no customisable dashboard); no score |
| RG-06 | Are separate Basic/Advanced modes needed, or does progressive disclosure suffice? | 05 P6/P7 and §8 decision 1; 07 §10; Stage 0 prompt §8 | 4 | Integrity text reachable in every mode; experts keep access |
| RG-07 | How should the target catalog expand and search improve: sources and licences, common names, cross-identifiers, size on the device, suggestions; an offline catalog or an online name resolver? | 08 §4, §9 | 7 | Offline-first; CC BY-SA handling; the catalog is generated by `tool/build_catalog.dart` and versioned, never hand-edited, and deleted targets must not come back; no scraping |
| RG-08 | Should elevation be retrieved automatically (source, accuracy, licence, privacy), made optional, or dropped, given that no calculation uses it? | 08 §6; SCI-08; UX-21; F-07 | 7 | Unknown is not 0; privacy (a position leaves the device) |
| RG-09 | Can Bortle or SQM be obtained reliably (a dataset or API; the uncertainty of conversions)? Does SQM need to be a user field at all? Should the external map move to lightpollutionmap.app? | 08 §6, §13; PD-05 options C and D (deferred); SI-007 | 7 | No scraping; no Bortle↔SQM conversion without a cited source; secrets outside the code (PD-05 D); privacy and compliance documents updated |
| RG-10 | How do manual imagers actually take darks, flats, bias frames and dark flats; what can inherit from the light frames; how can it be explained briefly, with tips that can be dismissed? | 08 §16; ADR-009 §3; F-39 | 7 | ADR-009's budget semantics stand unless the owner amends them |
| RG-11 | Which capture parameters matter for each camera type (ISO or gain, binning, white balance, focus, interval); which feed a calculation and which are records only; how are they labelled? | 08 §15; SI-004; SCI-05 | 7 | ISO or gain is never "sensitivity"; no camera control; descriptive fields stay descriptive unless a formula is documented |
| RG-12 | Does GPL-3.0 meet the owner's new requirements (free; no monetisation; no modification without the author's permission)? If not, which licence would, and what follows for the bundled CC BY-SA 4.0 data, the dependencies' licences, the store listing and copies already shared? | 08 §23; PD-12 (GPL-3.0 confirmed 2026-09-24); TASK 16.3 | 9 | A dedicated legal/licensing research decision; no change before the owner decides; not legal advice |
| RG-13 | Which settings match real amateur and professional needs, are they understandable, and does each belong in Settings or in context? | 08 §18; TD-050 | 9 | Thresholds stay configurable; no score |

---

## 8. Owner decision register (RD)

| ID | Decision | Evidence and known options | Stage | Blocks |
| --- | --- | --- | --- | --- |
| RD-01 | Which GitHub account carries the project identity: `chacha12` (the application id `io.github.chacha12.astroplanner`, the `AppIdentity` source and policy URLs, the user agent, the git user) or `Buffur` (the remote `github.com/Buffur/Astro-Planner`; the owner's links in 08 §23)? | OD-07 asked for confirmation before the first upload; the application id is permanent once published | Before any store upload; before Stage 9's About and links | Upload; privacy-policy URL; About links; the CI remote |
| RD-02 | The TASK 0.3 holdovers: the Google ADK skill and `skills-lock.json`; retaining `docs/archive/`; `sqlite3_flutter_libs ^0.6.0+eol` | 01 TASK 0.3; `TECH_DEBT.md`'s cleanup list | 1 (hygiene); 10 (the dependency, with a device check) | — |
| RD-03 | Wording rulings: the ISO/gain "Sensitivity setting" label (SCI-05); a resolution caveat for times on the 5-minute grid (SCI-04) | 07 §6 item 8 | 1 | B7 |
| RD-04 | New-draft defaults: should a new draft pre-select M42 and the first rig, and how are defaults and the "Example plan" labelled or offered? 08 §14 asks whether the example plan adds value | ENG-15, SCI-12, UX-24; TASK 4.4 | 4 | Stage 6 |
| RD-05 | Drafts and "New session": is a separate draft stage needed (08 §2)? Are unsaved drafts listed, confirmed before being replaced, or cleaned up (UX-12)? What do "+", New Session and Duplicate do, and how is the state shown (08 §5)? | TASK 11.3's owner decision (drafts are not listed); ADR-014 | 4 (an interim safeguard can be decided in Stage 1) | A7; Stage 6 |
| RD-06 | May the planner's section order change (ADR-015 §2)? May assumptions, the √N help and heuristic notes be one tap away instead of always expanded? | UX-02, UX-05, UX-06; 08 §16–§17 prefer collapsible, on-tap explanations | 4 | Stage 6 |
| RD-07 | The Library's role: should its lists select for the current plan (TD-053), keep target selection, and where does Progress live (08 §19)? | ADR-015 §7; TASK 14.2 | 4 | Stages 6 and 9 |
| RD-08 | Tracking per rig (ADR-011 §5) or per plan/session (08 §21)? What does the seeded rig declare (UX-15(1))? | PD-11: NPF guidance keys on the rig's tracking | 7, decided before Stage 6's capture-plan work | Stage 6 capture plan; Stage 7 |
| RD-09 | Destructive interactions: confirm or undo, including deleting a capture block and swipe-to-delete | UX-09, UX-38; 08 §14, §20; `IA_WIREFRAMES.md` §3 (no destructive action without confirmation) | 5 | Stages 6–9 |
| RD-10 | Ordering Tonight's candidates without a score: a secondary sort, thresholds, or grouping of ties | UX-29; ADR-013 §5 | 6 | — |
| RD-11 | Where the ADR-013 optional Moon and cloud gate controls live (TD-050): in Settings (Stage 9) or earlier, in the planner | 01; 07 §6 item 10 | 6 or 9 | — |
| RD-12 | Should the resume prompt's Finish complete the session at once, or open reconciliation like the tracker's Finish? | RT-10, UX-26; ADR-016 §11 | 8 | — |
| RD-13 | Should an accepted frame estimate carry "estimated" provenance (ADR-008 §6) instead of being stored as a confirmation (ADR-016 §3)? | SCI-07 | 8 | — |
| RD-14 | Vocabulary: rig or equipment; Sessions or Logbook; the names of the dark window and the night key | UX-18; 08 uses "Logbook" and "Planner" | 4 | Stage 5's shared vocabulary; limits C4 |
| RD-15 | Does the beta need a local diagnostics export (`AppLog`)? | ENG-13; crash reporting is deferred for privacy | 11 (planning) | Beta triage |
| RD-16 | When and where the metadata feature becomes visible (the PD-06 gate): at the end of Stage 2, or Stage 3 | PD-06; `FeatureScope` | 2 | — |
| RD-17 | Push the CI workflow to the remote and observe a first run (TASK 1.3), given RD-01 and the repository's visibility | 06 §2; 07 §9 | 1 (optional) or 11 | — |

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
| PD-21 metadata formats | Placeholder | RG-01 |
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
