# AstroPlan — AI Engineering Guidelines

## Project Purpose

AstroPlan is a mobile application for astrophotographers whose **primary product job is user-friendly planning of upcoming astrophotography sessions**.

It helps the user determine:

- what can be imaged;
- when it can be imaged;
- which site and equipment apply;
- how to construct a realistic capture plan;
- whether that plan fits the available astronomical opportunity.

Execution, actuals, Logbook, export, and backup remain important supporting workflows, but they must not unnecessarily dominate or complicate the planning experience.

AstroPlan complements tools such as Stellarium, Stargazing Hub, N.I.N.A., ASIAIR, and dedicated telescope-control software; it is not intended to replace a planetarium or become a telescope/camera-control suite.

## Tech Stack

- **Framework**: Flutter
- **Language**: Dart
- **State Management**: Provider with ViewModels
- **Database**: SQLite (via Drift)
- **Navigation**: go_router

## Main Architectural Rules

1. **Separation of Concerns**: Presentation -> ViewModels -> Repositories -> Data Sources/Services.
2. **Domain Isolation**: Astronomy calculations must remain independent from Flutter UI code (pure Dart preferred).
3. **Offline-First**: Core features (equipment, targets, calculations, logs) must work offline. External APIs (weather, geocoding) enrich but aren't strictly required.

## Source-of-Truth Documents

Read the relevant source-of-truth documents before architectural, scientific, product, or feature changes.

### Implementation and historical design sources

- `docs/PROJECT_HANDOFF.md`: Entry point. Current project state (actual vs intended), traps, build/test baseline, document map.
- `docs/ARCHITECTURE.md`: Design intent (Part A), current architecture (Part B), implementation deviations (Part C), target direction (Part D).
- `docs/DATA_MODEL.md`: Design intent (Part A), current entities and migration history (Part B), required future domain concepts (Part C).
- `docs/FEATURE_STATUS.md`: Per-feature status (Implemented / Partial / Prototype / Broken / Missing / Deprecated / Unknown) with known issues.
- `docs/TECH_DEBT.md`: Debt register (`TD-###`) with evidence and proposed directions.
- `docs/DECISIONS.md`: Accepted ADRs (verbatim), conformance audit, owner directives, open decisions (`PD-##`).
- `docs/SCIENTIFIC_INTEGRITY.md`: Scientific issue register (`SI-###`) and calculation register.
- `docs/EXPORT_MANIFEST.md`: export manifest v2 schema; change it with `SessionManifestCodec`, and bump `manifest_version` for any incompatible change.
- `docs/PROJECT_AUDIT.md`: point-in-time audit evidence and discrepancy log. It is a snapshot; do not edit it to track later changes.
- `docs/PRODUCT_SPEC.md`, `docs/ROADMAP.md`, `docs/MASTER_ROADMAP.md`, `docs/TEST_PLAN.md`, `docs/IA_WIREFRAMES.md`, and `.agents/rules/`: historical product intent, implementation roadmap, test intent, and project rules.

`docs/archive/` holds superseded documents. They are historical only and are known to be inaccurate; never use them as current source of truth.

### Post-roadmap refinement sources

After **Stage 0 — Refinement Baseline** is committed, the active post-roadmap source of truth is:

- `docs/refinement/PRODUCT_DIRECTION.md` — current product intent and product-level constraints.
- `docs/refinement/POST_ROADMAP_PLAN.md` — active strategic refinement Stages and dependency order.
- `docs/refinement/PROGRESS.md` — current Stage, current/next approved Task, completed work, research gates, owner decisions, blockers, validation state, and next allowed action.
- An explicitly supplied planning/research/implementation/validation prompt file — the active scope for the current agent session.

The original roadmaps and audit reports remain authoritative historical evidence for the work that produced the current baseline. They are **not** the active post-roadmap task queue once Stage 0 is complete.

Until Stage 0 is committed, the existing roadmap governance remains in force.

## Important Development Rules for Future Claude Agents

1. **Inspect before modifying.**

2. **Never guess about existing code or current repository state.**

3. **Read the active prompt and relevant source-of-truth documents before making architectural, scientific, or product claims.**

4. **Verify audit findings against the current repository before fixing them.** If later changes already resolved or materially changed a finding, report the discrepancy rather than implementing an obsolete fix.

5. **Prefer the smallest complete change that satisfies the approved Task.**

6. **Avoid unnecessary rewrites.** Do not rewrite working systems without a demonstrated reason.

7. **Do not introduce new architecture without an approved reason or decision.**

8. **Do not add features outside the active Task.**

9. **Do not silently change working product behavior.**

10. **Record adjacent findings; do not fix them on the way** unless the current Task requires the fix to satisfy its acceptance criteria.

11. **If the Task requires a materially larger architecture/product/scope change than approved, stop before the out-of-scope implementation, explain why, and propose a decomposition.**

12. **Ordinary implementation difficulty is not a reason to stop.** If the approved Task is coherent and achievable within scope, carry it through to completion.

13. **For an approved implementation Task use:** `READ → VERIFY → PLAN → IMPLEMENT → TARGETED TESTS → REGRESSION / QUALITY GATE → SELF-REVIEW → DOCS → COMMIT → STOP`.

14. **Do not stop after planning when the implementation Task is already approved.**

15. **Never start the next Task or Stage automatically.**

16. **Run appropriate targeted tests after changes.**

17. **Run analyzer/formatter and the repository quality gate where applicable before calling an implementation Task complete.**

18. **Do not remove or weaken tests merely to make a change pass.**

19. **Keep business logic deterministic, testable, and separated from UI.**

20. **Keep astronomical/domain calculations independent from Flutter UI code.**

21. **Use explicit units for scientific and equipment values.**

22. **Handle UTC, local time, time zones, DST, and SessionNight semantics through the established abstractions.**

23. **Never silently change scientific formulas or assumptions.** Scientific assumptions must remain documented.

24. **Never present relative stacking gain as absolute physical SNR.**

25. **Unknown values remain unknown; never fabricate data merely to simplify the UI.**

26. **User-facing scientific thresholds should remain configurable where scientifically appropriate.**

27. **Never hardcode external API secrets.**

28. **External APIs, datasets, catalogs, or enrichment sources require evidence for reliability, licence/terms, provenance, privacy, and failure behavior before implementation.**

29. **Preserve Git checkpoints and keep completed Tasks independently understandable from their commit and documentation.**
    
    ## Documentation Conventions (added 2026-09-21)
- **The code is the source of truth for the ACTUAL state.** Design intent (`PRODUCT_SPEC.md`, `ROADMAP.md`, ADRs, Part A of `ARCHITECTURE.md` and `DATA_MODEL.md`) is kept separately and is **never rewritten to match the code**. Where the two differ, record an **IMPLEMENTATION DEVIATION** with: intended behavior, actual behavior, consequence.
- **Status vocabulary:** *Intended / Planned*, *Implemented*, *Partial*, *Prototype*, *Broken*, *Missing*, *Deprecated*, *Unknown*. Do not call a feature Implemented if it does not work, and do not call it Missing if code for it exists. Do not hide identified issues.
- **Stable IDs** are used across documents: `F-##` (features), `TD-###` (tech debt), `SI-###` (scientific issues), `DEV-A/D/P#` (implementation deviations), `PD-##` (open decisions), `OD-##` (owner directives). Reference them; never renumber.
- **When a code change alters the actual state**, update in the same change: `FEATURE_STATUS.md`, `TECH_DEBT.md` (mark items resolved with date and commit — do not delete them), Part B of `ARCHITECTURE.md` / `DATA_MODEL.md`, `SCIENTIFIC_INTEGRITY.md` for any calculation, and `DECISIONS.md` for any formula or architectural decision. Refresh the verification stamp at the top of each file you touch.
- **Record, don't fix on the way.** New findings go into `TECH_DEBT.md` / `SCIENTIFIC_INTEGRITY.md`; do not expand the current task to fix them (rule 7).
- **Source-of-truth documents must be tracked by Git.** Never add `CLAUDE.md` or anything under `docs/` to `.gitignore` (owner directive OD-02).
- **Prior documents are preserved, not deleted.** Superseded material goes to `docs/archive/` with a banner.

## Post-Roadmap Workflow Governance

### Active Prompt Rule

When the owner explicitly provides a planning, research, implementation, or validation prompt file:

1. Read it completely before making changes.
2. Treat it as the active scope for that session.
3. Resolve references through the repository rather than asking the owner to paste source material into chat.
4. Do not start another Task or Stage after completing it.
5. If the prompt conflicts with current repository evidence, verify and report the discrepancy instead of silently following stale assumptions.
6. A supplied **implementation Task prompt constitutes owner approval to execute that Task completely** through implementation, testing, documentation, review, and commit. Do not request a second approval merely because the Task touches multiple files or layers.
7. Owner approval is still required before materially expanding scope, making a new unresolved architecture/product/scientific/data-model decision, or implementing work explicitly marked as a research/owner-decision gate.

### Context Discipline

Use the repository as persistent project memory. Prefer high-signal, just-in-time context:

- read the active prompt;
- read the documents, ADRs, and finding IDs it references;
- inspect the relevant implementation and tests;
- inspect adjacent code only as necessary to complete the Task correctly.

Do not perform a repository-wide re-audit for every Task.

Do not require old chat transcripts when the necessary state is recorded in Git and project documentation.

A fresh chat is expected at clean boundaries, especially:

- after a completed Task and commit;
- after a completed research decision;
- before independent Stage validation;
- when moving to a new Stage;
- when the previous conversation context has become unnecessarily large.

### Task Sizing

A good implementation Task normally has:

- one primary behavioral objective;
- one coherent scope;
- explicit dependencies;
- explicit out-of-scope boundaries;
- objective acceptance criteria;
- one complete validation loop.

Cross-layer work is acceptable when every change serves the same behavioral objective.

Use the previous roadmap's sizing philosophy as guidance, not a hard line-count quota:

- **S** — focused/local task;
- **M** — one coherent cross-layer behavior;
- **L** — usually decompose unless highly cohesive;
- **XL** — do not use as an implementation Task.

### Research and Decision Rules

Research is required when implementation depends on an external fact or unresolved product/domain decision the repository cannot establish.

Typical examples include metadata format/library capabilities, metadata-to-equipment identification, equipment databases, target catalog sources, elevation/Bortle/SQM sources, calibration-frame workflows, licensing, third-party provider terms, and major product-flow decisions.

Use:

`QUESTION → CURRENT CONSTRAINTS → AUTHORITATIVE EVIDENCE → VERIFIED FACTS → UNKNOWNS → OPTIONS → TRADE-OFFS → RECOMMENDED DIRECTION → OWNER DECISION → ADR / SPEC IF NEEDED → IMPLEMENTATION TASKS`

Research sessions normally do not modify production application code.

Do not convert a research hypothesis into implementation merely because one solution appears practical.

### Validation Rules

Validation exists at two levels.

**Task validation** is part of the implementation Task and must include the applicable targeted tests, relevant regression tests, analyzer/formatter, quality gate, and explicit acceptance-criteria verification. A Task is not complete merely because code was written.

**Stage validation** is performed in a fresh independent session after the Stage's implementation Tasks are complete. The validator should attempt to disprove that the Stage is complete, checking for regressions, scope drift, incomplete work, stale assumptions, architecture/scientific-integrity violations, and missing evidence. Validation-only sessions do not silently implement fixes; surviving findings become focused follow-up Tasks.

## Current Baseline and Known Traps (as of 2026-09-24, TASKs 15.4 and 15.5 open until a device run; TASK 10.5 cut)

**Commands** (prefer `--no-pub` to avoid unintended `pubspec.lock` changes):

- **`dart run tool/check.dart`** — the quality gate: an encoding check (`tool/check_encoding.dart`), `dart format --set-exit-if-changed`, `flutter analyze --no-pub`, `flutter test --no-pub` (format/analyze/test scoped to `lib`/`test`), and since TASK 15.5 the end-to-end suite on the host (`flutter test --no-pub integration_test -d flutter-tester`; plain `flutter test integration_test` asks for a device), in one command. Runs all steps regardless of an earlier failure, then prints a pass/fail summary and exits non-zero if any failed. Run this before calling a change complete (TASK 1.3, TD-046; encoding step added TASK 4.3, TD-015).
- `flutter analyze --no-pub` — expected: no issues.
- `flutter test --no-pub` — expected: **1177 pass, 0 fail** (green since TASK 1.1; `TD-003` resolved; 83 → 135 in TASK 2.2 → 147 in TASK 2.3 → 152 in TASK 2.4 → 160 in TASK 3.2 → 166 in TASK 3.3 → 179 in TASK 4.1 → 193 in TASK 4.2 → 201 in TASK 4.3 → 205 in TASK 4.4 → 229 in TASK 5.2 → 249 in TASK 5.3 → 268 in TASK 5.4 → 282 in TASK 5.5 → 291 in TASK 5.6 → 299 in TASK 6.2 → 309 in TASK 6.3 → 319 in TASK 6.4 → 327 in TASK 6.5 → 347 in TASK 7.1 → 379 in TASK 7.2 → 404 in TASK 7.3 → 420 in TASK 7.4 → 451 in TASK 8.1 → 463 in TASK 8.2 → 483 in TASK 8.4 → 500 in TASK 8.5 → 511 in TASK 8.6 → 521 in TASK 9.2 → 535 in TASK 9.3 → 547 in TASK 9.4 → 572 in TASK 10.2 → 577 in TASK 10.3 → 584 in TASK 10.4 → 598 in TASK 11.2 → 613 in TASK 11.3 → 620 in TASK 11.4 → 625 in TASK 12.2 → 631 in TASK 12.3 → 651 in TASK 12.4 → 665 in TASK 12.5 → 760 in TASK 13.2 → 780 in TASK 13.3 → 795 in TASK 13.4 → 808 in TASK 14.1 → 814 in TASK 14.2 → 822 in TASK 14.3 → 835 in TASK 14.4 → 857 in TASK 15.1 → 864 in TASK 15.2 → 871 in TASK 15.3 → 878 in TASK 15.4 → 881 in TASK 16.1 → 889 in TASK 16.2 → 896 in TASK 16.3 → 897 in S1.1 → 901 in S1.2 → 908 in S1.3 → 909 in S1.4 → 919 in S1.5 → 929 in S1.6 → 935 in S1.7 → 936 in S1.8 → 943 in S1.9 → 944 in S1.10 → 945 in S1.11 → 947 in S1.12 → 948 in S1.13 → 949 in S1.17 → 954 in S1.V1 → 957 in S1.V2 → 962 in S1.V3 → 963 in S1.V4 → 980 in S2.1 → 995 in S2.2 → 1008 in S2.3 → 1016 in S2.4 → 1024 in S2.5 → 1034 in S2.7 → 1042 in S2.8 → 1052 in S2.V1–S2.V3 → 1062 in S2.9 → 1068 in S2.V4 → 1082 in S3.1 → 1093 in S3.2 → 1094 with TD-066's exposure test → 1115 in S3.4 → 1130 in S3.3 → 1143 in S3.5 → 1150 in S3.6 → 1159 in S3.8 → 1161 in S3.7 → 1165 in S3.9 → 1169 in S3.10 → 1173 in S3.V1 → 1177 in S3.V2). A failing test is now a regression.
- **Metadata real samples (S2.3, ADR-017 §9):** `test/data/metadata/real_samples_test.dart` is skipped unless `ASTROPLAN_METADATA_SAMPLES` names a directory outside the repository holding `expected.json` (the owner's machine: `C:\Users\zalub\AstroPlanSamples\metadata`). Never commit the owner's files, slices of them or their values; committed fixtures are synthetic (`test/support/tiff_fixture.dart`).
- `dart run tool/check_encoding.dart` — expected: no issues. Every `lib`/`test` `.dart` file must be valid UTF-8 and contain no Cyrillic character (U+0400–U+04FF); this codebase is English-only, so any Cyrillic is almost certainly mojibake (UTF-8 text misread as a single-byte codepage, then re-saved as UTF-8) — this is what TD-015's `Вµm`/`В°`/box-drawing corruption looked like. Do not write a literal mojibake string (even in a test asserting it's absent, or in a comment) — the checker will flag it; describe the character instead.
- `dart format lib test` — expected: no changes (the whole tree was formatted once, TASK 1.3). Formatting is not yet enforced in CI; `tool/check.dart` is the only current gate.
- **After changing Drift tables (TASK 3.2 workflow, `build.yaml` configures it):** dump a new snapshot with `dart run drift_dev schema dump lib/data/database/app_database.dart drift_schemas/`, regenerate verification code with `dart run drift_dev schema generate drift_schemas/ lib/data/database/generated_migrations/ --no-data-classes --no-companions`, regenerate the step shapes with `dart run drift_dev schema steps drift_schemas/ lib/data/database/schema_versions.dart` (TASK 5.3), add the new `fromNToM` step to the `migrationSteps(...)` call in `onUpgrade` — written against the step's own `schema.<table>` shapes, **never** the live tables, and add a migration test in `test/data/database/schema_migration_test.dart` (schema-equality + a data-preservation test). The floor is v8 (`kMinSupportedSchemaVersion`); `onUpgrade` throws `UnsupportedSchemaVersionException` for anything below it or newer than the app, before any statement runs; since S1.5 `main.dart` probes the database first (`refusedSchemaVersion`) and shows `UnsupportedDatabaseApp` instead of the app — a confirmed reset (`resetRefusedDatabase`, file kept as `.v<N>.bak`) only below the floor, never for a newer database (ADR-008 §2). To change a foreign key's `ON DELETE` action or drop a column, use `Migrator.alterTable(TableMigration(table))` (SQLite can't alter either in place) — pass the step's versioned shape (`schema.captureBlocks`), and list a brand-new column in `newColumns: [...]` (with a `columnTransformer` for its value), or the copy will try to select a column the old table doesn't have. Schema is **v18 since S3.4** (per-field equipment provenance and the metadata identity, ADR-018 §5: a spec's provenance is its own pair, else its group's; edit rigs through `withEditProvenance`, which keeps untouched verified values verified). Before that: v16 since TASK 11.2 (ADR-014: `session_logs` is the Session root — status, legacy, night key, SET NULL references, UTC-ms timestamps, JSON snapshots via `JsonMapConverter`; update session rows with a partial `write(companion)`, never a full-row `replace`, or the v16 columns are reset; pre-v16 rows are legacy and read-only; since TASK 11.3 sessions go only through `SessionRepository` — lifecycle enforced, one transaction per write, snapshots built by the pure `SessionSnapshotBuilder`; `LogbookRepository` is gone; the planner saves with `vm.saveSession()` and opens with `vm.openSession()` (since S1.6, a button that replaces the current session — New, Duplicate, Open — first calls `confirmLeavingUnsavedPlan`, and a site-change autosave passes `edit: false`), and a ViewModel that saves needs `sessionRepository:`; since TASK 11.4 the plan lives in the current draft session and every edit autosaves through the serialized `_autosave` — with a `sessionRepository` never write the plan or selected target/rig to preferences, and in widget tests run edits and Save inside `tester.runAsync` (Drift needs the real event loop)), v15 since TASK 8.5 (v14 in TASK 8.4, v13 in TASK 8.1, v12 in TASK 7.1). Equipment edits must go through `EquipmentProfile.withEditProvenance(original)`, and the rig editor is `showEquipmentEditor` over the pure `EquipmentDraft` form model (S3.5): never build a profile in the widget; only add a seed whose specs are verified against a primary source (cite it in `equipment_seeder.dart`). Target RA/Dec entered by a user go through `AstroMath.parseRightAscension`/`parseDeclination` (a bare RA number is **hours**) — never `double.parse`; an edit must never change `catalogId` (the repository ignores it on update). Weather (ADR-012): the only path is `WeatherRepository.fetchSnapshot` (UTC `WeatherSnapshot`, nullable values — never default a missing value to 0); the legacy `getCurrentWeather`/`WeatherConditions` were removed in TASK 9.4. The card reads `vm.nightWeatherSummary` (`NightWeatherSummarizer`, pure: sunset to sunrise, ranges, dew heuristic) — no weather arithmetic or good/bad thresholds in widgets, and no score. The night forecast state is `vm.nightWeather` (`NightWeatherService`: cache → fetch → typed states; freshness only via `WeatherFreshness`, never an ad-hoc age check); since S1.3 the age follows the clock — `NightClock` at the app root calls `checkClock()` every minute and `resumed()` on resume, and a snapshot re-ages first; never age a forecast anywhere else; tests inject `nightWeatherService:` with an in-memory store. Test doubles of `WeatherRepository` mix in `NoSnapshotWeather` (`test/support/`); a fake that serves hours must put them on whole UTC hours, as the provider does (the night starts at mean solar noon, not on the hour). The target catalog is generated — change `tool/build_catalog.dart` and regenerate `assets/catalog/catalog_v2.json` from the pinned OpenNGC release, never hand-edit it; a new catalog must bump `version` and mark new entries' `since`, or deleted targets could come back. The asset is CC BY-SA 4.0: keep `OPENNGC_NOTICE.txt` and the About page in sync.
- Android: a debug APK and a release bundle **build** (2026-09-24, TASK 16.2); **no install or run on an Android device is recorded**: manual installs of some builds have happened (the owner's dogfooding, `docs/audit/08`), but no build, device, commit or date was recorded, so every acceptance that needs device evidence is still unmet (wording corrected S1.15 with the owner's approval; `POST_ROADMAP_PLAN.md` §1.3 item 2). Release builds: `flutter build appbundle --release` **without** `--no-pub` (with it, after a debug build, the release compile fails on the dev-only `integration_test` plugin), then `dart run tool/check_bundle.dart`; procedure in `docs/RELEASE.md`.

**Testing rule:** `.agents/rules/03-testing.md` can be satisfied literally again (`DEV-P8` resolved 2026-09-21). Investigate any failure as a regression; do not delete or weaken a test.

**Owner directives currently in force** (`docs/DECISIONS.md` Part C plus post-roadmap refinement governance):

- Historical roadmap directives remain valid for the work they governed and remain evidence of prior owner decisions.
- **Before Stage 0 is committed:** scope remains `docs/MASTER_ROADMAP.md` under the existing roadmap governance.
- **After Stage 0 is committed:** active strategic scope is `docs/refinement/POST_ROADMAP_PLAN.md`; current operational state is `docs/refinement/PROGRESS.md`; current session scope is the explicitly approved planning/research/implementation/validation prompt.
- Work one coherent implementation Task per cycle unless the approved prompt explicitly defines a smaller grouped operation.
- Never start the next Task or Stage automatically.
- An implementation prompt explicitly supplied by the owner is authorization to execute that Task completely. Do not require another approval merely because implementation is multi-file, architectural, database-related, or cross-layer **when those changes are already within the approved Task scope**.
- A **new unresolved** architecture, data-model, scientific, product, external-provider, licensing, or scope decision still requires the appropriate research/decision gate and owner approval.
- Documentation-only Tasks must not silently fix application code or scientific issues; record them (OD-04).
- Research-only Tasks must not silently become implementation Tasks.
- Validation-only Tasks must not silently fix findings.
- Preserve historical roadmap/audit documents rather than rewriting them to reflect refinement.
- Keep `docs/refinement/PROGRESS.md` current at Task/Stage boundaries once it exists.
- OD-03's prerequisite condition has been met historically; do not use it to block already-approved post-roadmap work.
- **`PD-06` historical gating remains relevant to the baseline:** the logbook and text sharing stay visible; metadata import is visible since S3.7 ("Add from a photo" on the equipment screen, ADR-018 §7; `AppRouter.metadata` is the root route `/equipment/import`); feature entry points continue to use `FeatureScope` rather than ad-hoc duplicate gating.
  **Traps that will bite (all verified):**
1. `EquipmentProfile.id` is an **optical-rig id**; storage is normalized (Device → CameraModule → OpticalRig) but the domain/UI model is flat — kept flat for 1.0 by ADR-011; the dormant catalog repository is gone and the tracking type is visible (TASK 8.4). **RESOLVED (TASK 3.3):** the `equipment_profiles` table is dropped entirely (not just orphaned) and foreign keys are enforced on every connection (`beforeOpen` sets `PRAGMA foreign_keys = ON`); `camera_modules.device_id`/`optical_rigs.camera_module_id` are `ON DELETE RESTRICT`, `capture_blocks.session_log_id` is `ON DELETE CASCADE`; `DriftEquipmentRepository.deleteEquipment` checks for other references before deleting a shared camera module or device. Migrations are guarded and snapshot-tested (TASK 3.2/3.3, ADR-008): the floor is v8, `onUpgrade` refuses anything below it or newer than the app before touching the file, the v8→v9 and v9→v10 steps are staged and run inside one transaction, and the v9→v10 step also runs a one-time orphan cleanup (`PRAGMA foreign_key_check`, delete + log) before rebuilding the three tables above and dropping `equipment_profiles`. Schema is now v10; the legacy `bit_depth`/`optical_multiplier` columns upgraded databases used to carry are gone too.
2. **RESOLVED (TASK 2.4).** `PlannerViewModel.sessionNight` now resolves a real `SessionNight` — `SessionNightResolver.resolveDefault(_clock.nowUtc(), ...)` by default, `.forEveningDate(...)` for a picked `CalendarDate` — instead of the old `_sessionDate = DateTime.now().toUtc()` (`TD-001`, resolved). `home_screen.dart`, `sky_darkness_widget.dart`, `altitude_chart_widget.dart` and `logbook_screen.dart` all consume it, through one `NightTimeFormatter` (`lib/presentation/shared/`) with no ad-hoc `.toLocal()` elsewhere. `sessionNight`/`eveningDate` are `null` without a site — Home shows a "No site set" state instead of the silent default-London astronomy (ADR-007 §9, SI-008). Since TASK 10.2 imaging windows come from `vm.imagingOpportunity` (`ImagingOpportunityCalculator`, ADR-013: gates, reasons, annotations, no score) — `vm.visibilityWindows` and the fit derive from it; never compute windows or reasons elsewhere, and never let unknown data exclude time. Home renders it through `TonightOpportunityWidget` (chart + list from the same object, wording in `OpportunityText`); there is no sky warning or culmination "max altitude" any more (ADR-013 §6). Many targets go through `CandidateEvaluator` (shared `SunTrack`/`MoonTrack`, same calculator — keep the batch equal to the single-target view; a test enforces it); `vm.tonightCandidates()` runs it with `Isolate.run`, so pass only plain values into the closure, never `this`, and widget tests must wait for it with `tester.runAsync`. Since TASK 6.2 every target altitude goes through `VisibilityCalculator.calculateTargetAltitude` (J2000 → date precession, airless) — never compute a target's altitude from its raw J2000 RA/Dec; since TASK 7.1 a site's IANA zone (`LocationProfile.timeZoneId`, `IanaTimeContext`) drives the night and the display — pass `vm.displayZoneId` to `NightTimeFormatter`; without a zone, times are labelled as the device zone. **A map pick or GPS fix is transient** (remembered in preferences) and must never be written into a saved site; only explicit user edits change sites. Never derive a night from a `DateTime`'s Y/M/D, and never call `DateTime.now()` in `lib/domain` (a test enforces this) — use the injected `Clock` instead.
3. **RESOLVED (TASK 8.4, ADR-011).** Equipment fields carry units (`focalLengthMm`, `focalRatio`, `pixelPitchUm`, …); the DB column `optical_rigs.aperture` holds the focal ratio N — never reinterpret stored values; N > 32 is flagged for review (`needsApertureReview`). Aperture input goes through `resolveAperture` (N = f / D), bounds through `EquipmentLimits`.
4. **The capture budget lives in `CaptureBudgetCalculator` (ADR-009, TASK 5.4)** — never add budget arithmetic to a ViewModel; `vm.captureBudget` exposes the whole breakdown and `vm.fitAnalysis` (`FitAnalyzer`, TASK 5.5) the fit — placement is atomic, so never compare sums of windows, and `estimatedRequiredTime` is the **window load** (lights + in-window calibration), not the whole session. Relative stacking gain is √N of light frames only; the UI label still says "Relative SNR" (`TD-009`). NPF follows Michaud's primary source since TASK 6.5 (explicit k) and is shown since TASK 8.6 per PD-11 — only through `vm.rigCapability` (`CapabilityCalculator`: field-minimum |δ|, k from `PlanningPreferences.npfK`, untracked or "if untracked"); exposure guidance never blocks a plan.
5. **Planning thresholds live in `PlanningPreferences` (TASK 5.2)** — read `vm.planningPreferences`, change them with `vm.setPlanningPreferences(...)`; never add a SharedPreferences call to a ViewModel (a test enforces this). Persistence goes through `PlanningPreferencesRepository` / `PlannerStateRepository` (optional constructor arguments, SharedPreferences-backed by default, same keys as before). `PlannerViewModel` starts `_init()` from its constructor; await it with `vm.ready` (TASK 1.1). Seeding no longer races it — `main.dart` awaits both seeders before `runApp` (TASK 1.2). A bootstrap failure sets `hasBootstrapError` (retry via `retryBootstrap()`) instead of throwing unguarded; weather loads after the first frame, not as part of `ready`, and a failure sets `weatherError` rather than blocking or throwing (TASK 1.2). GPS goes through the injected `LocationService` (a sealed `LocationResult`: found, or unavailable with `serviceDisabled`/`permissionDenied`/`permissionDeniedForever`) and place names through the injected `ReverseGeocoder` (TASK 7.2; default `NominatimReverseGeocoder`, rate-limited and cached — never import `package:http` or `package:geolocator` in presentation/domain, a test enforces it), so tests must pass a `FakeLocationService` (`test/support/`), or they will reach the real plugin; pass a `FakeReverseGeocoder` to keep a test off the network. Since TASK 7.3 startup never asks for GPS (owner decision): the first run shows a site prompt, and sites are managed through `vm.sites`/`selectSite`/`saveSite`/`deleteSite` — screens must not call `LocationRepository` directly. Pass a `FakeDeviceTimeZone` (`test/support/`) in tests; the real one is a platform plugin. `IanaTimeContext` uses the `latest_all` data set on purpose (device link zones such as `Europe/Ljubljana`); do not switch back to `latest_10y`.
6. **RESOLVED (TASK 7.4, PD-05).** The light-pollution scraper is deleted (a test fails if scraping code or a network call on a location change comes back). Sky darkness is user-entered Bortle and/or SQM with source and date, read through `vm.skyDarkness`, or unknown — never a default, and never converted Bortle↔SQM. The external map link is `LightPollutionMapLink.at(lat, lon)`.
7. **RESOLVED (TASK 4.3).** `FeatureScope.fieldMode`/`metadataImport` are `false` and `lightPollutionContext` is `true` since TASK 7.4, matching PD-06's schedule; `logbook` stays `true`. Every entry point reads it — Home's field-mode toggle, Import Metadata button and light-pollution map card, plus `app_router.dart`'s route registration and `sky_darkness_widget.dart`'s Bortle badge (`TD-014`, DEV-P1 resolved). The map card's coordinates are still hard-coded Slovenia (F-34) — fixing that is TASK 7.4's job, out of 4.3's scope. **Since TASK 12.4** `fieldMode` is `true` too (lifted on its schedule); `metadataImport` stayed hidden until S3.7 made it visible (ADR-018 §7).
8. Unknown data must not be shown as zero or a default (`SI-008`).
9. Drift row classes share names with domain models; repositories import domain classes `as domain`.
10. `AppRouter.router` is a static singleton; `Provider<AppDatabase>` is registered but never read. Since TASK 12.2 it is a `StatefulShellRoute` (ADR-015): use the `AppRouter` path constants, never string literals; pages that must cover the tabs (planner, pickers opened from it, editors) are root-navigator routes; a pushed page does not change `routerDelegate.currentConfiguration.uri`, so tests assert on visible app-bar titles; Home tests start at `AppRouter.session()`.
11. **Since TASK 12.3 there is no `PlannerViewModel`.** In the traps above, `vm.<member>` now means the screen-scoped ViewModel that owns it: `SiteViewModel` (sites, position, zone, sky darkness), `SettingsViewModel` (`planningPreferences`), `SessionPlanViewModel` (night, target, rig, blocks, sessions, `idle`), `NightConditionsViewModel` (weather, timeline, Moon, `imagingOpportunity`, `tonightCandidates`), `CaptureAnalysisViewModel` (budget, fit, capability, `saveSession`), `StartupViewModel` (`ready`, bootstrap error), and `GearViewModel`/`TargetsViewModel`/`SessionsViewModel` for the Library and Sessions screens. Widgets `context.watch` the one they need; screens never call a repository. ViewModels take domain interfaces only — `main.dart` composes them through `AppViewModels` and is the only place that picks implementations (a test forbids `http`/`shared_preferences`/`drift`/`geolocator`/data-layer imports in a ViewModel, and more than 250 code lines). Tests use `PlannerHarness` (`test/support/`), which builds the real graph and exposes `providers`; wrap widgets in `MultiProvider(providers: vm.providers, ...)`.
12. **Colours are tokens (TASK 12.4).** In `lib/presentation` never write `Colors.*`, a `Color(0x…)` literal, a font size under 12 or `MaterialTapTargetSize.shrinkWrap` (a test enforces all four): use `Theme.of(context).colorScheme` for generic roles and `AppPalette.of(context)` (`lib/core/theme/app_palette.dart`) for the rest — add a token to all three palettes (light, dark, field) rather than a local colour. Field-mode tokens must be red or black only (tested). In field mode the whole app is also wrapped in `AppTheme.fieldFilter`; do not rely on it to excuse a non-red token. `ThemeViewModel` lives in `AppViewModels` and persists through `DisplayPreferencesRepository`; tests get an in-memory one from `PlannerHarness` (`InMemoryDisplayPreferences`).
13. **Tonight and first run (TASK 12.5).** Tonight is a summary: no calculation in the screen — add a value to a ViewModel or the domain, and reuse `WeatherText`/`MoonText`/`FitText` (`presentation/shared/night_text.dart`) so Tonight and the planner word things the same way. Since S1.7 every duration, exposure, signed degree and percentage shown goes through `QuantityText` (`lib/core/utils/quantity_text.dart`) — never format one by hand. The first-run page (`/welcome`) is offered once, only on a start without a site; `TonightViewModel.load()` runs before `runApp`, and until it has run `firstRunDue` is false (tests pass `firstRun:` to `PlannerHarness`, default not done but never loaded unless the test calls `vm.tonight.load()`).
14. **Execution (TASK 13.2, ADR-016, schema v17).** A run's state is `ExecutionMachine.fold` over its `session_events` — never keep run state in a ViewModel or a timer; recompute from the events and the injected `Clock`. Write events only through `SessionRepository.start`/`record`/`complete`/`abandon` (one transaction: the event plus the `capture_blocks` counters, which must always equal the replayed events); order by `seq`, never by time. The estimate (CALC-35) is shown as an estimate and stored only when the user accepts it. At most one session is in progress (the repository refuses a second). The planner never edits a run: after Start (`CurrentSession.start`) it continues on a draft copy (since S1.12 Save and Start run inside the autosave chain, `_inChain`, so an edit tapped meanwhile goes to the copy; New/Duplicate/Open do not yet, TD-058), and on a restart it adopts a copy when the most recent open session is in progress (TD-055 resolved, TASK 13.3). The tracker (`/session/:id/run`, `ExecutionViewModel`) reads night, target and Moon from the execution-start snapshot, never from the planner; countdowns go through `ExecutionOutlook` (CALC-36). Keep-screen-on goes through `ScreenWake` (tests: `FakeScreenWake`, the harness default). Since TASK 13.4 the tracker's Finish opens `/session/:id/results` (`ResultsViewModel`); only Complete there completes. After `finished`, confirm/reject corrections are the only events accepted (ADR-016 §11); `complete()` and corrections write the light totals; planned vs actual goes through `SessionReconciliation` (CALC-37).
15. **Errors (TASK 15.1).** Never swallow an error: a `catch` handles it, logs it through `AppLog` (`lib/core/diagnostics/`; never `debugPrint`/`print`) or rethrows — `empty_catches` and `test/core/diagnostics/no_empty_catch_test.dart` reject empty and comment-only catches, `catch (_) {}` included. Repositories throw `StorageFailure` for a store they cannot read or write (Drift through `StorageFailureInterceptor` on `AppDatabase`, preferences through `guardStorage`; a new repository method needs the same); domain refusals keep their own types. In the UI, run a user action through `runWithFeedback` and show a load error with `LoadFailureView` — never the raw error text. `CurrentSession.write` never throws; its failure is `writeFailure` (the planner's banner). Tests that simulate a database failure wrap `NativeDatabase.memory()` with a `QueryInterceptor` (see `storage_failure_test.dart`).
16. **Caching (TASK 15.2).** The planner's costly derived values are memoized in their ViewModel (`ARCHITECTURE.md` B15): `NightConditionsViewModel` keys its caches on explicit inputs (night, target RA/Dec, preferences, forecast state); `CaptureAnalysisViewModel` caches the budget, fit and fill count per input generation (bumped when the plan, settings or conditions notify) and night. A new input to those values must either notify or join the key, or it will be served stale; never cache in a widget. `test/presentation/viewmodels/planner_memoization_test.dart` holds the invalidation cases and the tolerant benchmark.
17. **Accessibility (TASK 15.3).** `test/presentation/accessibility_test.dart` sweeps every main screen in the light, dark and field themes at 100 % and 200 % text on a 412 px-wide view (tap targets, labels, contrast in light/dark, no overflow): a new screen goes into its route list; its weather fake serves a full forecast (S1.10), so keep new data-dependent cards populated in the sweep, or it cannot see them. A clipped `TextField` raises no error, so the sweep cannot see it: `equipment_editor_fit_test.dart` measures text width against the box with Roboto loaded (S3.10). Give every icon-only button a `tooltip`; a `Semantics(excludeSemantics: true)` that relabels a button must also pass `onTap` and `enabled` (S1.11), or screen readers cannot press it; let text in a `Row` wrap (`Flexible`/`Expanded`/`Wrap`) and never put text in a fixed-height box; a new chart needs a text alternative. Field mode's secondary red is below WCAG AA on purpose (ARCHITECTURE B16) — do not "fix" it without the owner.
18. **Lifecycle (TASK 15.4).** A process death is simulated by closing the database file and booting a new graph on it (`test/lifecycle/lifecycle_matrix_test.dart`); a full disk by a `QueryInterceptor` throwing SQLITE_FULL. Every user action that writes must go through `runWithFeedback` (or catch `StorageFailure`) — a new button that writes without it is a silent failure. TASK 15.4 stays **open** until the device rows of `TEST_PLAN.md` § Lifecycle matrix pass: there is no Android device or emulator on the development machine.
19. **End-to-end (TASK 15.5).** `integration_test/core_loop_test.dart` walks the core loop through the real UI with a real SQLite file and a restart; it finds widgets by the keys and labels the screens use (`tonight.openPlanner`, `planner.start`, `run.plus`, `run.more`, `run.finish`, `results.save`, `detail.export`, 'Save Session', 'Add site', 'Save site', …) — renaming one breaks it, so update the suite with the screen. It is in the quality gate (host). A snackbar can cover a bottom button: wait it out rather than tapping through it.
20. **App identity (TASK 16.1, OD-07).** The name is "Astro Planner" and the id `io.github.chacha12.astroplanner`: name the app only through `AppIdentity.appName` (and the manifest label), never a literal; `app_identity_test.dart` keeps Dart, Gradle, the manifest and `MainActivity` in step. `.astroplan`, the manifest's `"app": "AstroPlan"` and the Dart package `astroplan` are file formats/internals and stay. Redraw the icon in both `drawable/ic_launcher_foreground.xml` and `tool/make_launcher_icons.py`.
21. **Signing (TASK 16.2).** The upload key, its `.jks` and `android/key.properties` belong to the owner: never create, read, print or commit them, and never ask for their passwords. The release build falls back to the debug key only when `key.properties` is absent; `tool/check_bundle.dart` refuses a debug-signed bundle. Every upload needs a higher `versionCode` (pubspec `+N`); keep `AppIdentity.version` equal to `X.Y.Z`.
22. **Privacy and third parties (TASK 16.3, PD-12).** The app is free with no ads (Open-Meteo's free tier) — adding ads or subscriptions needs the owner and Open-Meteo's commercial plan. Place names are opt-in (`OptInReverseGeocoder`, off by default): never send a position to Nominatim otherwise, and never look up a saved site or the default position. Every request to a third party carries `AppIdentity.userAgent`. Anything new that leaves the device (a service, a data field) must be added to `docs/privacy/index.md` and `docs/COMPLIANCE.md` (Data Safety) in the same change.

# Project Instructions

## Project

Flutter/Dart mobile application for planning upcoming astrophotography sessions.

### Primary Product Job

AstroPlan is primarily a **user-friendly astrophotography session planner**.

Its main job is to help the user determine:

- what they can image;
- when they can image it;
- which site and equipment apply;
- how to construct a realistic capture plan;
- whether the plan fits the available astronomical opportunity.

The planning-first conceptual flow is:

`Site / Equipment / Target → Night & Astronomical Conditions → Imaging Opportunity → Capture Plan → Fit / Feasibility → Saved Session`

Execution, actuals, Logbook, export, and backup are important supporting workflows. They must preserve correct data and state when used, but they must not unnecessarily dominate or complicate the planning experience.

The application is not intended to replace Stellarium, Stargazing Hub, N.I.N.A., ASIAIR, or dedicated telescope-control software.

### Product Refinement Principle

Do not remove valid existing domain or scientific functionality merely because its current presentation is complex.

Prefer:

- better information hierarchy;
- answer-first presentation;
- progressive disclosure;
- trustworthy automation of manual inputs;
- clear state and feedback;
- reduced duplicated actions;
- advanced information remaining reachable.

The Notion-inspired visual direction is a design influence, not a constraint that prevents better interaction patterns.

## Development Philosophy

Inspect first. Verify second. Plan third. Implement fourth. Validate before completion.

Prefer the smallest **complete** correct change.

Do not rewrite working systems without a demonstrated reason.

Do not add speculative abstractions or features.

Do not modify unrelated files.

Do not silently change product behavior.

For an approved implementation Task, finish the full Task rather than stopping after an internal plan.

## Architecture

Keep astronomical/domain calculations separate from UI.

Business logic must be deterministic and testable.

Do not place non-trivial astronomy or capture calculations directly inside widgets.

Use explicit units for astronomy and equipment calculations.

Be careful with UTC, local time, time zones, DST, and SessionNight semantics.

Preserve Provider/ViewModel architecture unless an explicitly approved future decision changes it.

## Product Constraints

The central product capability is:

> **Fit a realistic Capture Plan into the user's real Imaging Opportunity and explain the result transparently.**

Important concepts include:

- SessionNight;
- Astronomical Darkness;
- Target Visibility Window;
- Environmental Conditions;
- Imaging Opportunity;
- Integration Time;
- Acquisition Time;
- Total Session Budget;
- Fit / Feasibility;
- explicit assumptions and reasons.

The UI should translate these concepts into practical planning answers instead of exposing the raw domain model with equal visual weight everywhere.

Do not treat arbitrary thresholds as universal scientific laws.

Do not use a composite black-box Astro Score.

Unknown data must remain unknown.

Automation may reduce user input only when the retrieved or inferred value has adequate evidence and provenance.

Execution and logging must preserve correct session state and data when used, but their final UX prominence is an explicit product decision, not something to change opportunistically.

## Metadata and Equipment Import

Do not assume the new production-ready metadata extraction foundation is already implemented until the refinement plan records it as completed and validated.

Keep these concerns separate:

`safe metadata extraction → typed/provenanced metadata → equipment/device candidate mapping → matching/enrichment → user confirmation → persistence`

Do not silently write extracted metadata into Equipment or related entities before the mapping, confidence, provenance, conflict, and confirmation semantics have been explicitly designed and approved.

Metadata-assisted actuals/reconciliation is a later workflow concern and must not be used to skip the metadata foundation or equipment-import decision stages.

## SNR

`sqrt(N)` may be used as a relative statistical stacking-gain approximation.

Do not represent relative stacking gain as absolute physical SNR.

Do not claim that ISO increases photon collection.

Document assumptions behind scientific calculations.

## Scope Control

Do not implement unless explicitly approved through the active refinement scope:

- planetarium engines;
- 3D sky simulation;
- sky-map/FOV imagery or mosaic-planning scope that the project has rejected/deferred;
- telescope or camera hardware control;
- ASCOM/INDI integration;
- social features;
- authentication;
- cloud infrastructure;
- black-box recommendation/scoring engines;
- web scraping;
- deferred external datasets/APIs before their research/licence/provenance gate.

Do not interpret a manual dogfooding proposal or audit hypothesis as approved implementation automatically.

## Testing

After modifying business logic or user-visible behavior:

- run relevant unit tests;
- run `flutter analyze --no-pub` where applicable;
- run relevant widget/integration tests;
- run `dart run tool/check.dart` before calling an implementation Task complete unless the active Task explicitly documents why the full gate cannot run.

Do not remove or weaken tests merely to make a Task pass.

A failing previously-green test is a regression until investigated.

## Git

Keep changes small, coherent, and reversible.

Prefer one logical Task per commit/checkpoint unless the approved Task explicitly requires an internally staged sequence.

Create meaningful checkpoints.

Never use destructive commands such as:

- `git reset --hard`;
- force push;
- deleting unknown user files;

without explicit owner approval.

## Source of Truth

The repository is the source of truth for implementation state.

Before major architectural/scientific/product decisions, read the relevant documents listed under **Source-of-Truth Documents** above.

If documentation and implementation disagree, investigate instead of guessing.

The code is the source of truth for the **actual implementation state**; design intent is preserved separately. Never rewrite historical design intent merely to match code. Record an `IMPLEMENTATION DEVIATION` where required.

After Stage 0 is committed, use `docs/refinement/PRODUCT_DIRECTION.md`, `docs/refinement/POST_ROADMAP_PLAN.md`, and `docs/refinement/PROGRESS.md` for post-roadmap product direction, strategic scope, and operational state.
