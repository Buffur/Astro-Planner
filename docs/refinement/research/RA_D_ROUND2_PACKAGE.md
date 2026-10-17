# RA.D round 2 — Capture Plan requirements and the remaining product decisions

> **Status:** 2026-10-17.
> - **Part A** records the owner's approved round 2A Capture Plan requirements and turns them into
>   constraints for RA.P.
> - **Part B** resolves the round 2B and 2C items that the owner's own direction already settles.
> - **Part C** lists the four decisions still open for the owner.
> - **Part D** fixes what RA.P must contain.
>
> **No application code changes.** Implementation needs the approved RA.P roadmap (gate G3).
>
> **Records:** DECISIONS E.1:
> - "RA.D — release scope principle (owner clarification)";
> - "RA.D round 2A — Capture Plan";
> - "RA.D round 2B/2C — resolved from the owner's direction".
>
> **Evidence:** RA.R1 ([Phase A](RA_R1_PHASE_A_ASSESSMENT.md)); RA.R2 ([R2a](RA_R2A_LANDSCAPE.md),
> [R2b](RA_R2B_CAPTURE_SCIENCE.md), [R2c](RA_R2C_NIGHT_CONDITIONS.md), [R2e](RA_R2E_DIRECTION_OPTIONS.md));
> the code facts cited below, read 2026-10-17.

## 0. The owner's scope principle (2026-10-17)

The reassessment produces a complete, technically grounded roadmap for a **fully functional release**:

- **Do not minimise scope** to shorten the path to 1.0.
- **Do not defer essential Capture Plan functionality** because it needs implementation work,
  migrations or tests.
- **Do not expand** into unrelated products.
- **Priorities:** completeness, usability, scientific correctness, maintainability.

Earlier recommendations that deferred work "for release scope" are re-read under this principle:
PD-09 and PD-11 are now in the release.

## Part A — Round 2A: approved Capture Plan requirements

### A.1 Decisions (owner, 2026-10-17)

| ID | Approved direction | Supersedes |
| --- | --- | --- |
| PD-05 | **O2b:** relative stacking improvement plotted against integration time, normalised to the plan (√(T/T_plan)); never an absolute physical SNR | CALC-42's axis and normalisation (presentation); SI-003 holds |
| PD-06 | **A complete storage workflow:** actual file-size evidence first; format-aware, scientifically justified estimates where the format is evidenced; Unknown when no reliable estimate exists. **Camera class alone is never evidence** of format, compression or bit depth | The Stage 11 row "storage … with no theoretical size introduced" (`POST_ROADMAP_PLAN.md`, Stage 11); the deferrals in PRODUCT_DIRECTION §8 and POST_ROADMAP_PLAN on a theoretical payload; SI-013 (to be amended); ADR-009 §7 / L6 (to be amended); ADR-018 D4 (extended from DNG to every readable format) |
| PD-07 | **C1-b + C1-d:** camera class chosen explicitly (rig creation, onboarding); the example rig gets a class from its cited source | ADR-020 §2's owner choice "the example rig stays Unknown". "Never inferred" stands |
| PD-08 | **P2b:** visible provenance for every suggested or inherited parameter | ADR-020 §5's presentation (the proposal itself stays) |
| PD-09 | **W2, in the release:** white balance is recorded so a capture's settings can be repeated, without claiming that metadata guarantees identical output | ADR-020 §3 W1 and §10 ("W2 … rejected") |
| PD-10 | **F2:** focus guidance; no numeric focus value or slider | ADR-020 F1 (extended by a reminder) |
| PD-11 | **Metadata-assisted Capture Plan population, in the release,** reusing the existing metadata foundation (no second parser) | ADR-020 §5's rejection of P3 |
| PD-12 | **CAL-1:** assisted generation of calibration blocks from the light blocks — inheritance, a preview, user confirmation, scientific constraints | — (within ADR-020 §6 L1) |
| PD-13 | **Remove the example-plan action** once its replacement workflows (PD-08, PD-11, PD-12) are implemented and verified; keep the test fixtures | RD-04 ("an empty plan with Start from the example plan") |
| PD-14 | **Effective assumptions shown; advanced controls still reachable** | — |
| PD-21 | **I1:** the time between frames stays a global preference unless implementation evidence shows a concrete need for another model | — |

### A.2 Reusing the metadata foundation (PD-06, PD-09, PD-11)

**What exists** (code, 2026-10-17):
- **Readers:**
  - TIFF/DNG, JPEG (APP1 EXIF) and HEIC are read by `dng_metadata_reader.dart`,
    `jpeg_metadata_reader.dart` and `heif_metadata_reader.dart`, through the reader registry and
    `MetadataSourceWindow` (ADR-017, S2.7–S2.9).
  - FITS, XISF, PNG, AVIF, CR2/CR3, RAF, RW2 and ORF are **recognised only** (`metadata_format.dart`).
- **The contract:** `CaptureMetadata` (`capture_metadata.dart:8-51`) carries:
  - `exposureSeconds`;
  - `sensitivity` (ISO and its kind);
  - `focalLengthMm`, `focalLength35mmEquivalentMm`, `fNumber`;
  - `captureTime`;
  - camera and lens make and model, `uniqueCameraModel`;
  - `imageDimensions`.
  Each value is a `MetadataValue` with its tag provenance. **Not in the contract:** white balance,
  bits per sample, compression, binning, gain, sensor temperature.
- **File access:** `CaptureFileAccess` (Android SAF, no copy; ADR-017) gives the picked file's length.
  Equipment import turns a **DNG's** length into the rig's `averageRawFileSizeMB` as an estimate
  (`equipment_candidate.dart:126-131, 234`; ADR-018 D4).
- **Rules that carry over unchanged** (ADR-018 §4, §6; trap 2):
  - exposure and sensitivity **never** map to equipment;
  - a value from a file is a proposal with its source, stored only by the user's Save;
  - unknown stays unknown.

**What each target field can get** (FACT where cited; INFERENCE marked):

| Field | From a DNG | From a JPEG/HEIC | From FITS (needs a FITS reader) | Never from metadata |
| --- | --- | --- | --- | --- |
| Exposure (s) | ExposureTime, reliable | ExposureTime, reliable | EXPTIME/EXPOSURE (common keywords; INFERENCE until a sample) | — |
| ISO | ISO with kind, reliable (SI-004: a record) | the same | — | Gain on DSLR/phone files |
| Gain, offset | — | — | GAIN, OFFSET (driver keywords, vendor-specific; INFERENCE) | — |
| Binning | — | — | XBINNING/YBINNING (INFERENCE) | Phone/DSLR files (the rig's mode) |
| White balance | **AsShotNeutral** (a neutral vector, not Kelvin; R2b §4.2) | **EXIF WhiteBalance (41987): Auto/Manual only**; LightSource (37384) on some cameras (INFERENCE) | — | The **Kelvin value** a user set, unless the camera writes it in a maker note (not read) |
| Focus | — | — | — | Any transferable value (R2b §4.3) |
| Pixel dimensions | ImageWidth/Length, reliable | reliable (the processed image) | NAXIS1/NAXIS2 | — |
| Format, compression, bits per sample | **BitsPerSample (258), Compression (259)** in the TIFF structure; **not yet in the contract** | Lossy by definition: no theoretical size | BITPIX, NAXIS; header blocks of 2,880 bytes (FITS standard) | Compressed RAW's actual ratio |
| File size | The picked file's length, reliable for **that** file | the same | the same | — |
| Camera class | — | — | — | **Never inferred** (ADR-020 §2); a later proposal with explicit confirmation would need its own decision |

### A.3 Requirements and constraints for RA.P

**PD-05 — relative improvement over integration time**
- **Formula:** CALC-42's √N, plotted per group against T = N · t and normalised to the planned point
  (√(T/T_plan)).
- **Wording:** never "SNR". The help keeps SI-003's text.
- **Tests:** reference vectors R2b R-O2 (0.5 → 0.7071, 1 → 1, 2 → 1.4142).

**PD-06 — storage evidence chain.** The value per frame is taken from the first source that applies:
1. **Measured** — the size of a file of that capture format, from the rig or from a file picked for
   the block. Any readable format, not only DNG (extends ADR-018 D4). Labelled with its source.
2. **Format-aware theoretical:**
   - only when the format is **evidenced**:
     - an uncompressed DNG with Compression = 1 and its BitsPerSample read from a file;
     - a FITS file's BITPIX and NAXIS;
     - or a format the user explicitly declares and confirms, labelled "declared by you";
   - computed as W × H × bits-per-sample ÷ 8, plus the container's known overhead (FITS: 2,880-byte
     records);
   - labelled "theoretical, uncompressed …".
3. **Unknown** — compressed RAW without a measured file, JPEG/HEIC without a measured file, or no
   evidence. The action is "pick one file".

Constraints:
- **Camera class never selects a branch.**
- **Binning:** whether a binned capture's theoretical size divides by the bin factor is a scientific
  rule to settle in the Task's ADR, with vectors. ADR-020 B1 says binning feeds no calculation, so
  the ADR amends B1 **for storage only** if adopted.
- **Tests:** vectors S1–S4 (R2b §3.2), plus the compressed-format → Unknown boundary.

**PD-07 — camera class**
- The rig editor asks the class first.
- Onboarding asks it (Part B, PD-02).
- The seed sets the example rig's class from its cited source (`equipment_seeder.dart` policy:
  verified seeds only) for new installs; existing rows are never reinterpreted.
- The block form shows only the class's fields (ADR-020 §3).

**PD-08 — provenance of proposed values**
- Every proposed or inherited field shows its origin until the user changes it ("from the Ha block ·
  300 s", "from IMG_0845.dng", "inherited from lights").
- Whether origins are **persisted** with the block is an RA.P design choice. **Recommended:**
  persist a per-field source for metadata-populated values and white balance (reproducibility;
  CLAUDE.md "preserve provenance") in the v26 migration.
- The filter default follows the class.
- The defect candidate RA-F05 (a light's exposure kept after switching the type) is verified first,
  then fixed.

**PD-09 — white balance record**
- **The model:**
  - mode: Auto · a named preset (Daylight, Cloudy, Shade, Tungsten, Fluorescent, Flash) · Kelvin
    value · Custom;
  - an optional tint;
  - the source: entered, or a proposal from a file — JPEG/HEIC give Auto/Manual only, a DNG's
    AsShotNeutral is stored as read and not converted to Kelvin.
- **Classes:** Phone, DSLR/mirrorless and Unknown; hidden for astro cameras, where colour balance is a
  processing step (RG-11 §4.4).
- **Wording:** "Recorded to repeat your settings; it does not change the plan or guarantee identical
  colours" — RAW keeps the sensor data, and JPEG output depends on the camera's processing.
- **Data:** the v26 migration: nullable block columns; additive snapshot and export keys; backup
  by table; legacy rows read as unrecorded.

**PD-10 — focus guidance**
- A reminder in the plan: focus on a star, and recheck after a filter or temperature change.
- The existing refocus overhead stays the only timing concept.
- No value, no slider.

**PD-11 — metadata-assisted block population**
- A "Take from a photo" action in the light-block editor, through `CaptureFileAccess` and the reader
  registry. It is the same path as "Add from a photo"; no new parser.
- **Proposes:** exposure, ISO (kind preserved), white-balance mode (A.2), and the file's size and
  format evidence for PD-06.
- **Contract extension (ADR-017 amendment):**
  - DNG BitsPerSample, Compression and AsShotNeutral;
  - EXIF WhiteBalance and LightSource;
  - each with tag provenance;
  - the real-sample test and the synthetic fixtures extended.
- **FITS:** a FITS header reader is in scope when a FITS sample is available (an owner's file, or a
  public sample whose licence allows it as a test fixture). Until then FITS stays recognised only,
  and PD-06 falls back to "declared by you" for FITS.
- **Rules:** every value is a proposal with its source, saved only by Save (P2b markers). Exposure and
  ISO never touch the rig (ADR-018 §4). A file whose pixel count differs from the rig's is flagged,
  not merged (SI-014).
- **V1 class:** metadata parsing and provenance are high-risk, so the full gate is required, plus
  the local real-sample test and a device check (M1/M4).

**PD-12 — assisted calibration**
- "Build calibration from lights" opens a **preview** before anything is added:
  - one dark block per distinct (exposure, sensitivity, binning) triple of the light blocks;
  - one flat block per filter;
  - bias and dark flats offered per class, not added by default (RG-10 matrix).
- **Constraints:**
  - with in-camera noise reduction on (ADR-020 §8), no darks are proposed;
  - "darks twice" is prevented;
  - counts are proposals (P2b);
  - every block is stored only on confirmation;
  - existing calibration blocks that already match are not duplicated (`CalibrationMatch`);
  - the budget reads the blocks unchanged (calibration never becomes integration).
- **Data:** no schema. **Tests:** a dark per triple, a flat per filter, the noise-reduction case, the
  no-duplicate case.

**PD-13 — example plan**
- The UI action is removed only after PD-08, PD-11 and PD-12 pass their acceptance.
- `ExampleCapturePlan` stays as a test fixture (`PlannerHarness.choosePlan`).
- Tests that use the `capturePlan.useExample` key move to the replacement flows.

**PD-14 — assumptions**
- The panel shows the assumptions that affect the current result (enabled overheads, the darkness
  limit, the minimum altitude, the margin), with a "Change in Settings" link. The stale "Planning
  Settings" label (K12) is fixed.
- Settings keep every control.

**PD-21 — interval**
- `PlanningPreferences`' time between frames stays global (ADR-020 I1).
- Reopen only on implementation evidence.

### A.4 Schema migration v26 (one migration, high-risk class)

| Table | New nullable columns (proposal for RA.P) | Purpose |
| --- | --- | --- |
| `capture_blocks` | white-balance mode, Kelvin, tint, source; a per-field value-source map for metadata-populated fields (PD-08, recommended) | PD-09, PD-08, PD-11 |
| `camera_modules` | capture container/format, bits per sample, compression, each with provenance | PD-06 |

**Requirements:**
- additive rig and block snapshot keys (old snapshots read as unknown);
- export manifest v2 additive (`EXPORT_MANIFEST.md`);
- backup by table;
- `drift_schemas` snapshot, the generated steps and a `from25To26` step;
- schema-equality and data-preservation tests;
- the pinned versions in `backup_restore_test` and `unsupported_database_test` updated;
- the full gate.

The identity Task's backup and restore across application ids (`RA_D_IDENTITY_TRANSITION.md` §3)
must run on the **same** schema version on both sides, so its order relative to v26 is set in RA.P.

## Part B — Rounds 2B and 2C: resolved from the owner's direction

Each item below is settled by the owner's own words — the live-test review (2026-10-01) or the
scope principle (§0) — together with RA.R2 evidence. They are recorded as decisions; the owner may
still object.

| ID | Resolution | The owner's direction | Supersedes | Constraints for RA.P |
| --- | --- | --- | --- | --- |
| PD-02 | **O-2′ onboarding:** one screen — site (GPS on tap, or choose) and "What do you shoot with?" (camera class → rig), both optional; no target step; one "Start planning" button, no Skip; a large title; short texts; the route chosen before the first frame (RA-B01) | The review: «Нам не нужна кнопка Skip» ["we don't need a Skip button"]; «Геолокация +, устройство +-, Таргет под большим вопросом» ["location yes, device maybe, target very doubtful"]; «Тайтл … можно сделать больше» ["the title can be bigger"] | TASK 12.5's first-run content | TASK 7.3 kept (GPS only on tap); PD-12 privacy line kept; the first-run tests and `core_loop_test` updated |
| PD-03 | **H-W Home:** the night card first (dark window, Moon with moon-free hours, cloud and freshness, the values row), then "Your plan" with Open planner; no "New plan" on Home (it stays in the planner's ⋮); site and night as a compact subtitle; the field-mode toggle in the title row (no empty app bar) | The review: «переместить погодные условия на верх, а следующим блоком переход на астро планнер» ["move the weather to the top, the planner entry next"]; «кнопка "New session" … Стоит убрать» ["the New session button should go"]; date and site are not the priority | ADR-019 §5's order; RG-05 T1 (plan-first) | ADR-012: values, no verdict, freshness; the context of the answer stays visible; ADR-019 §5 amended in the record |
| PD-04 | **Planner empty state:** a checklist (site · target · rig · capture) instead of the near-empty status, with no repeated "No target"; the duplicated weather row removed from the planner (window cloud annotations stay) | The review: «Верхний блок планнера пустует — ошибка» ["the planner's top block is empty — a mistake"]; weather in the planner «убрать либо минимизировать» ["remove or minimise"] | ADR-019 §6's contents (order kept) | RD-06 "answer first" kept once the answer exists |
| PD-16 | **A 16-night forecast overview** from one Open-Meteo request per site; per-night cards (cloud in the dark span, precipitation, wind, dew, Moon) | The review's references (multi-day forecasts) and «полезную информацию о погоде на ночь» ["useful information about the night's weather"] | ADR-012 §4 (request scope) and §6 (cache key per night) | The same provider and data: the privacy and COMPLIANCE wording updated in the same change (trap 22); freshness states unchanged; no score |
| PD-17 | **A monthly Moon calendar** in Night & Moon (the Moonlit concept, not its code), offline, in an isolate, cached per month; a combined night bar with a Moon layer, a legend and a text alternative | The review: «стоит интегрировать это для мобильной версии» ["it should be integrated for mobile"] | — | Its definition follows Part C, Q2; timing on the phone is an acceptance criterion; no "good night" highlight (fixed thresholds) |
| PD-19 | **Records:** Progress by target as a Logbook segment; a visible Delete for rigs and targets (RD-09 compliance, after verification); "Plan this target" on the target row; the stored night forecast shown in the entry | The review: Logbook and Library — «дай идеи всё ли с ними нормально» ["give ideas whether they are fine"] | — | RD-07 roles kept: the Library manages, the Logbook records; no schema |
| PD-20 | **Settings:** an Appearance control (System · Light · Dark) beside field mode; a units preference (°C/°F, km/h/mph or m/s) through `QuantityText`; overheads stay global (PD-21) | The review: «что реально нужно там, что стоит убрать\добавить» ["what is really needed, what to remove or add"]; §0 completeness | — | New preference keys join the backup (`BackupPreferences`, trap 5); the sweep covers the changed screens |
| PD-22 | **Order:** set in RA.P (Part D) and approved with the roadmap at G3 | §0 | — | — |

## Part C — Decisions still open for the owner

> **Answered by the owner, 2026-10-17:** Q1 keep all three, demoted; Q2 MF-c; Q3 no provider, a link only; Q4 include the AstroBin CSV export (DECISIONS E.1, "RA.D — Q1 to Q4").

Four decisions remain. Each changes established functionality, a scientific model, an external
provider or the release scope, so none of them may be settled by the agent.

| # | Question | ★ Recommendation | Alternative | Why it needs the owner |
| --- | --- | --- | --- | --- |
| **Q1** (PD-01) | Product scope: "What can I image tonight?" (candidates), the planner's altitude chart, the Weather detail screen | **Keep all three, demoted:** candidates as a secondary action, the altitude chart compact (windows and the fit need the target's altitude), the Weather screen as the details of the night card. The review asks for completeness and calls the functions raw, not useless | **Remove the candidates screen** (the review: «не должны были реализовывать … расположение объектов» ["should not have built … object positions"]) | Removing established functionality is an owner gate; the review states both directions |
| **Q2** (PD-15; SI-015) | Moon-up definition | **MF-c:** one definition everywhere — the Moon is up while its upper limb is above the horizon with standard refraction (h₀, as the displayed rise and set) — for the moon-free hours, the Moon gate (ADR-013 G4) and CALC-29/33/43. One meaning, consistent with Moonlit and USNO; the full gate and new vectors | **MF-b:** the new moon-free hours use h₀, the existing predicates stay (centre above 0°, airless), and the 5–10 min difference is documented | A scientific-model change (ADR-013, CALC-29/33/43). Under §0 correctness is preferred over avoiding work |
| **Q3** (PD-18) | Seeing and transparency | **No provider in the release;** the Weather details say "Seeing and transparency are not forecast here" and offer a link the user opens (Clear Outside). For phone and DSLR focal lengths the pixel scale (18–38″) far exceeds seeing (1–3″) | **7Timer! ASTRO as an opt-in** (72 h, 3-hourly, coarse GFS codes, non-commercial, a new recipient of coordinates) | Adopting a provider is an owner gate (privacy, terms) |
| **Q4** | Export a Logbook entry in AstroBin's acquisition CSV format | **Include:** cataloguing is core («работать с этими записями, и каталогизировать» ["work with these records and catalogue them"]); AstroBin is the community's de-facto log; the data exist in the snapshot; a new export format, versioned (`EXPORT_MANIFEST.md`) | Leave out (the existing JSON export and text share remain) | Adds an external format contract to the release |

## Part D — What RA.P must contain

RA.P amends `POST_ROADMAP_PLAN.md` and `PROGRESS.md` with new Stages and Tasks. Each Task has:
- one objective;
- dependencies and exclusions;
- acceptance criteria;
- its V1 verification class;
- a stop condition.

It must include:

1. **Reconciliation.** Stages 0–10 closed. Stage 11 open:
   - S11.6, phone runs;
   - S11.7, readiness;
   - which host rows keep PASS (V3) and which the redesign invalidates.
2. **CI first.** TD-104 needs the log; the failing test is identified, then fixed. A green remote run
   becomes a release prerequisite.
3. **Identity.** The trademark search for "Culmina" before the id change (`RA_D_IDENTITY_TRANSITION.md`),
   then the id, name, URLs, logo review and splash.
4. **Capture Plan** (Part A), in dependency order:
   1. camera class (PD-07);
   2. v26 with the metadata contract extension (PD-06, PD-09, PD-11);
   3. provenance markers (PD-08);
   4. the storage chain (PD-06);
   5. white balance (PD-09);
   6. "Take from a photo" (PD-11);
   7. CAL-1 (PD-12);
   8. O2b (PD-05);
   9. assumptions and focus (PD-14, PD-10);
   10. then the example action's removal (PD-13).
5. **Screens:** onboarding and the first-frame route, Home, the planner's empty state, Records,
   Settings (Part B).
6. **Night conditions:** the 16-night overview, the Moon calendar and night bar; Q2's definition;
   Q3's link.
7. **Defect candidates:** RA-F05, RA-G03, K12 — verify, then fix. TD-100 to TD-103 are scheduled
   where their Task touches the area.
8. **Design quality (K14).** Every UI Task has rendered screens reviewed by the owner before
   acceptance, plus the accessibility sweep (light, dark, field; 100 % and 200 %).
9. **Release.** The full gate on the final inputs; S11.6 on the final build:
   - the core loop;
   - TalkBack;
   - perf;
   - lifecycle;
   - the signed release;
   - the identity migration's backup and restore.

   Then the owner's actions: signing, the privacy policy live, Data Safety, the trademark search, the
   Play closed test (≥ 12 testers, 14 days). Then S11.7 readiness and the owner's go/no-go.
10. **Traceability.** Every Phase A finding (RA-A01…RA-I05, K1…K14) maps to a Task or a justified
    exclusion.
11. **One starting implementation Task.**
