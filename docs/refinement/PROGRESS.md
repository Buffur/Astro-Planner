# AstroPlan — Refinement Progress

> The handoff contract for post-roadmap refinement: where work stands, what still binds it, what
> evidence can be reused, and the one next allowed action. Strategy lives in `POST_ROADMAP_PLAN.md`,
> direction in `PRODUCT_DIRECTION.md`, verification rules in `CLAUDE.md` ("Verification Policy"),
> and history in [`PROGRESS_HISTORY.md`](PROGRESS_HISTORY.md) and the `STAGE_N_*.md` reports.
> **Last updated:** 2026-09-29 (**S9.10–S9.12 prepared**: the logo, the licence and the identity await the owner).
> **Next:** the Stage 9 validation of S9.1–S9.9; the owner's three decisions (S9.10–S9.12). The owner asked for the next Stage once Stage 8's findings were fixed.

## Current state

| Item | State |
| --- | --- |
| Phase | Post-roadmap refinement, Stages 0–11 (`POST_ROADMAP_PLAN.md`) |
| Current Stage | **Stage 9 — Secondary UX & Product Polish: In progress** (planned 2026-09-29). Stage 8 closed 2026-09-29 ([report](STAGE_8_VALIDATION.md)) |
| Current Task | None in progress |
| Next Task | **S9.9** (below, "Next allowed action") |
| Code baseline | **S9.9** (its commit). Not pushed: the owner asked for commits only (2026-09-29) |
| Schema | **v25** (S8.6) |
| Toolchain | Flutter **3.47.4** (the CI's pinned version; Dart 3.13.3) at `C:\tools\flutter-3.47.4`, put first on `PATH` for the gate. This machine's default Flutter 3.44.2 is below the project's SDK constraint (`^3.13.3`) |

**S9.10–S9.12 prepared, 2026-09-29** (owner gates; documentation only):
- **S9.10** (`research/S9.10_LOGO.md`): where the icon appears; five problems with today's execution
  (the star floats above the arc, three stroke weights, the themed icon is the colour drawing tinted,
  the mark sits high, error red); four alternatives that keep the concept (A corrected, B the window as
  an area, C minimal, D today's with its defects fixed), each checked against the 66 dp safe zone; a
  dedicated themed layer; a splash proposal that never delays startup. **The owner chooses.**
- **S9.11** (`research/S9.11_LICENCE.md`, RG-12): from the GPL FAQ, the Open Source Definition, the
  CC BY-SA 4.0 legal code and the PolyForm texts: GPL-3.0 meets "free" but not "no monetisation" or
  "no modification without permission", and no open-source licence can; the options (keep GPL; PolyForm
  Noncommercial; PolyForm Strict; all rights reserved), and what follows (earlier copies stay GPL, every
  copyright holder must agree, the catalog stays CC BY-SA 4.0, the dependencies are permissive). Not
  legal advice. **The owner decides.**
- **S9.12** (`research/S9.12_PROJECT_IDENTITY.md`, RD-01): the app's source and privacy-policy links
  (`chacha12`) return 404 while the public repository is `Buffur/Astro-Planner`; recorded as **TD-088**
  (a blocker for any store upload, not for Stage 9). Options C, B and B′. **The owner decides.**
- **Verification:** the documentation class (V1): references resolve; `git diff --check`.

**S9.9 done, 2026-09-29** (final visual consistency): the secondary screens use the text roles and
spacing tokens only (list titles `titleSmall`, "Saved sites" a header, every numeric inset a token;
12 became `md`). `secondary_consistency_test.dart` (2) keeps ad hoc styles out of the thirteen files;
the sweep covers them in every theme at 100 % and 200 %. No content changed. Also corrected: S9.8's
FEATURE_STATUS banner named F-42 for backups (F-42 is planned-versus-actual logging).
- **Verification:** shared behaviour (thirteen presentation files): the full gate after the last code
  change, **PASS** (1,825 tests, 2 skips; 2 host E2E; Flutter 3.47.4).

**S9.8 done, 2026-09-29** (D9-5; TD-081 resolved): feedback, messages and export polish.
- `showDone` after a rig, target or site saved, a name saved or removed, an export or backup file
  created, a restore prepared or cancelled (deletes since S9.1). None for settings (visible in place).
- **TD-081:** every message through `AppMessages.showMessage` with `AppMotion`'s style; none slides
  under reduced motion. A test keeps `showSnackBar` out of the rest of `lib/presentation`.
- File names in local time (`astroplan-entry-…`, `astroplan-logbook-…`, `astroplan-backup-…`), the
  backup's share text with its UTC offset; "Export all as file" a labelled item in the Logbook's menu.
- **Tests:** `app_messages_test.dart` (3; the reduced-motion case mutation-checked),
  `file_names_test.dart` (3), the new messages in the library, detail and backup tests; the Export
  all test goes through the menu.
- **Verification:** shared behaviour (every message, two data-layer file names): the full gate after
  the last code change, **PASS** (1,823 tests, 2 skips; 2 host E2E; Flutter 3.47.4).

**S9.7 done, 2026-09-29** (08 §13): sky darkness made readable.
- Each value first, its source and a readable date under it (`NightTimeFormatter.recordedDate`,
  "Aug 1, 2026"); "Unknown" with the way to set it; "Not saved" for a transient position. The map
  link names lightpollutionmap.app and what to do there, in the text roles. The site editor's captions
  use the same date. No inference, no conversion (trap 6).
- **Tests:** `sky_darkness_context_test.dart` updated deliberately (the new readings by key, no ISO
  date, the link's words); the formatter's date (+1); the planner and disclosure tests' link text.
- **Verification:** shared behaviour (the planner's sky detail, the site editor, a formatter): the
  full gate after the last code change, **PASS** (1,816 tests, 2 skips; 2 host E2E; Flutter
  3.47.4).

**S9.6 done, 2026-09-29** (the detail screens' secondary presentation; 08 §12): Weather and Night & Moon.
- Night & Moon: a twilight bar from sunset to sunrise (`TwilightBands`, pure, from the domain's
  crossings; bands shaded by depth), above the unchanged table of times, which is its text.
- Weather: a cloud-cover bar under each hour's number (unknown draws nothing); dew-risk hours marked
  by an icon as well as colour; "Tap to set location" gone where nothing can be tapped. Age, stale
  state, unknowns, units, attribution and the horizontal-visibility wording unchanged (ADR-012).
- **Tests:** `twilight_bands_test.dart` (5: a mid-latitude night, no astronomical darkness, no
  sunset, clipping, and the calculator's real night); `detail_screens_test.dart` +2 (cloud bars at
  40 %, the dew icon, no "Tap to set location"; the bar's seven bands). The sweep already opens both
  details with a full forecast.
- **Verification:** shared behaviour (two detail screens, a shared helper): the full gate after the
  last code change, **PASS** (1,815 tests, 2 skips; 2 host E2E; Flutter 3.47.4).

**S9.5 done, 2026-09-29** (08 §23; D9-4): About.
- An author block first: the app, its version, "Made by Buffur" (the owner's public handle from 08
  §23; the git history records two author names, so no personal name is inferred), Reddit as the
  prominent button and the GitHub profile. Then each data source's credit with its link (OpenNGC,
  openstreetmap.org/copyright, open-meteo.com, lightpollutionmap.app), privacy, the licence.
  Source-code and policy links unchanged pending RD-01. `pubspec.yaml`'s template description
  replaced. `COMPLIANCE.md` noted; the privacy policy needs no change (nothing new leaves the device).
- **Tests:** `about_screen_test.dart` +2 (the author block first with both links and the version;
  every source linked); two counts relaxed deliberately (the catalog's credit now appears in the
  notice and in its linked line).
- **Verification:** localized plus `pubspec.yaml` (a gate input): the full gate, **PASS** (1,808
  tests, 2 skips; 2 host E2E; Flutter 3.47.4).

**S9.4 done, 2026-09-29** (P9.3; RD-11 = S9; TD-050 resolved; D9-3): Settings rebuilt.
- "Settings", in RG-13's sections: Imaging window (minimum altitude, darkness limit, **Moon gate**,
  **cloud gate**), Fit and capture time (margin, time between frames now to the model's 120 s, the
  optional overheads with editable values), Guidance (NPF k, dew margin), Display, Privacy, Data,
  About; each row value-first with its consequence. No default and no meaning changed.
- Every setting write, Back up, preparing and cancelling a restore through `runWithFeedback`;
  Restore through `confirmDestructive`; a pick error through `showFailure`.
- **Tests:** `settings_rebuilt_test.dart` (5: the sections in order; the Moon gate at 0 % shrinks the
  usable time on a full-Moon night and both gates persist; 120 s reached; an overhead's steppers
  persist, change the budget and stop at the floor; a failed save says so); the sweep adds Settings
  with every gate and overhead on; titles and dialog keys updated deliberately in the navigation,
  settings and backup tests.
- **Verification:** shared behaviour (Settings, preferences feeding every planner value): the full
  gate after the last code change, **PASS** (1,806 tests, 2 skips; 2 host E2E; Flutter 3.47.4).

**S9.3 done, 2026-09-29** (RG-13 answered; documentation only): `research/S9.3_SETTINGS.md`.
- Every visible setting classed (A–F), with what it changes, its unit, range and default, the need
  (N.I.N.A. and PHD2 documentation for dithering, refocus and meridian-flip practice; CALC-17 for
  NPF; the twilight definitions), and where it belongs. The Moon and cloud gates are placed in
  Settings (RD-11 = S9). Decisions for S9.4 recorded in E.1 (D9-3).
- Found: the "Time between frames" slider stops at 60 s while the model allows 120 s (fixed in S9.4).
- **Verification:** the documentation class (V1): references resolve; `git diff --check`. The S9.2
  gate stays the baseline (V3).

**S9.2 done, 2026-09-29** (P9.2): secondary forms and the vocabulary completed.
- The rig, target and site editors: sentence-case titles and labels from `AppWords`, one primary
  `FilledButton` Save (the target editor's `ElevatedButton` replaced; the site editor's app-bar check
  replaced by "Save site" at its foot); `AppSpacing` in the lists and the site form; the site editor's
  ad hoc SnackBars through the new `showFailure`. "No equipment profiles found." → "No rigs yet."
- **The retired-terms baseline is empty**, and a test now requires it (P9.2's acceptance).
- **Tests:** `secondary_forms_test.dart` (3); labels updated deliberately in the rig, target, site,
  metadata, camera-class and noise-reduction tests and the E2E ("Save Changes" → "Save", "Target Name *"
  → "Name *", the site editor's Save by key `siteEditor.save`).
- **Verification:** shared behaviour (three editors, a shared helper): the full gate after the last
  code change, **PASS** (1,801 tests, 2 skips; 2 host E2E; Flutter 3.47.4).

**S9.1 done, 2026-09-29** (P9.1; RD-07, TD-053 resolved; D9-1, D9-2): the Library manages.
- `ListMode` (manage in the Library, choose from `/select/…`): a Library tap opens the rig, target or
  site and never changes the plan or the active site; choosing is unchanged. Titles by mode ("Rigs",
  "Choose a rig", …); no plan highlight in the Library; the Library tab describes itself.
- **Plan this target** in a target opened from the Library: the leave guard, a new plan with the
  target, "New plan for …", the planner.
- Rigs, targets and sites: a visible Delete (rig and target editors, the site row) and a swipe, both
  through `confirmDestructive` (one message shape), then "Rig deleted" etc. The ad hoc dialogs and raw
  `Dismissible`s are gone. Acceptance (4)'s "refusal for a rig in use" was dropped: no such refusal
  exists (saved plans keep their snapshots).
- **Tests:** `library_manage_mode_test.dart` (6; mutation-checked: with the Library routes in choose
  mode four fail); the sweep adds `/select/rig`, `/select/target`, `/select/site`; titles and tooltips
  updated deliberately in the navigation, Tonight, planner, metadata, target, sites and E2E tests
  ("Select Equipment" → "Choose a rig", "Select Target" → "Choose a target", "Edit" → "Edit rig" /
  "Edit target", the site dialog's wording).
- **Verification:** shared behaviour (three lists, the router, the editors): the full gate after the
  last code change, **PASS** (1,797 tests, 2 skips; 2 host E2E; Flutter 3.47.4).

**Stage 9 planned, 2026-09-29** (documentation only; the plan's "Stage 9 — frozen Task sequence"):
- Inputs verified against the code at `b378f16` (§9.7). Most important: the Library still chooses for
  the plan and the active site (TD-053); the Moon and cloud gates have no control anywhere (TD-050);
  About has no authorship; `AppIdentity` names `chacha12` while the remote is `Buffur` (RD-01); rigs,
  targets, sites and Restore confirm with ad hoc dialogs.
- **Frozen:** S9.1 → S9.9, then the Stage 9 validation. S9.10 (logo), S9.11 (licence, RG-12) and S9.12
  (identity, RD-01) are **owner gates**: the agent prepares them, the owner decides.
- Decisions D9-1 to D9-6 (E.1, "Stage 9 decisions (delegated by the owner)"); TD-074 deferred to
  after Stage 11 (D9-6).
- **Verification:** the documentation class (V1): references and IDs resolve; `git diff --check`.
  The TD-087 fix's gate is Stage 9's baseline (V3).

**TD-087 fixed, 2026-09-29** (S8V-03; tests only): the three Stage 8 acceptance checks the
validation established by probes are committed tests.
- S8.1 acceptance 6: `schema_migration_test.dart`'s v23 → v24 test adds a never-saved draft, a
  Saved and a Saved · changed plan with blocks.
- S8.4 acceptance 2: `live_runs_survive_test.dart` (new; the shape of the validation's P2).
- S8.2 and trap 17: the accessibility sweep opens the Saved plan's result form before its night
  ends, after it with no outcome chosen, and with Not done's reason chips (all three themes, 100 %
  and 200 %).
- **Verification:** test code only: the full gate after the change, **PASS** (1,791 tests, 2
  skips; 2 host E2E; Flutter 3.47.4).

**TD-086 fixed, 2026-09-29** (S8V-02; the owner asked in chat to fix every Stage 8 finding; I-4,
CALC-44, SI-008): the unreadable Saved · changed path.
- `ResultsViewModel.savedPlanUnreadable`: the form's review lists no planned blocks and shows the
  night and target as unknown, instead of the working row's (only Not done is offered, as before).
- CALC-44's fallback takes the later of the row's night key and the evening date the unreadable
  snapshot still names (`Session.unreadableSnapshotNight`, read by `DriftSessionRepository`): a
  working night moved earlier no longer lets Not done be recorded before the saved night can have
  ended. Only ever later; never shown. No schema change.
- **Tests:** `results_unreadable_plan_test.dart` (new), `drift_session_results_test.dart` +2; both
  mutation-checked (each fails without its half of the fix).
- **Verification:** high-risk (time and night semantics, CALC-44): the full gate after the change,
  **PASS** (1,790 tests, 2 skips; 2 host E2E; Flutter 3.47.4).

**TD-085 fixed, 2026-09-29** (S8V-01; the owner asked in chat; D8-2): Save no longer rewrites a
saved plan whose night ended since the last night check.
- `CurrentSession.save` takes the time (`PlanLifecycleViewModel.savePlan` passes the clock) and,
  inside its step of the autosave chain, never saves over a saved plan whose night has ended
  (CALC-44): a Saved one stays as it was and the plan is saved as a new one; a Saved · changed one is
  settled first (`settleSavedPlan`, as S8.3's transition does) and its copy is saved. The ended entry
  keeps its snapshot, blocks and night. No repository or schema change.
- A first attempt ran the night check (`followNight`) before Save; the gate's S1.12 race test
  (`save_start_race_test.dart`) caught that an edit tapped right after Save then landed before it,
  so the decision moved into the chain, where the snapshot and plan of the tap are kept.
- **Tests:** `saved_plan_transition_test.dart` +2 (P5's sequence for a Saved and a Saved · changed
  plan: after dawn, no tick, Save → the entry unchanged, a new saved plan from the working copy);
  both failed before the fix.
- **Verification:** shared behaviour (`CurrentSession` and a ViewModel's Save, used by the planner and the E2E):
  the full gate after the change, **PASS** (1,787 tests, 2 skips; 2 host E2E; Flutter 3.47.4).
  It does not reopen the Stage 8 PASS (V6): it resolves a recorded FOLLOW-UP.

**Stage 8 validation PASS, 2026-09-29** (a separate agent in the implementing session, without its context; [report](STAGE_8_VALIDATION.md)):
- Every frozen item passes (the Stage's constraints and exit, S8.1–S8.9's acceptance, D8-1 to D8-4,
  I-1 to I-10, the traps it touches). No V4 blocker; **Stage 8 closed**.
- Gate reused (V3): S8.9's full gate at `690b94a` (1,785 tests, 2 skips; 2 host E2E); the code diff
  since is empty. Fresh evidence: probes P1 (v23 → v25 keeps rows in every status), P2 (S8.4
  acceptance 2: an in-progress, a corrected completed and an abandoned run list, export, back up
  and record) and two mutations (P3: the TD-063 test fails without the re-read; P4: three S8.9 tests
  fail without the settings restore); all temporary and removed.
- Non-blocking findings recorded, not fixed: S8V-01 / **TD-085** (Save in the minute after a saved
  night ends rewrites its snapshot; reproduced by P5), S8V-02 / **TD-086** (the unreadable Saved ·
  changed path shows and times working state), S8V-03 / **TD-087** (three acceptance checks rest on
  the validation's probes, not committed tests).
- **Verification:** documentation class (V1): references and IDs resolve; `git diff --check`.

**S8.9 done, 2026-09-29** (TD-056 and ENG-14 resolved; I-10): preferences in the backup; stale ids.
- **Probe first:** ENG-14 reproduced on the host before any change: a staged restore applied as
  `main.dart` runs it left `activeLocationId` 7 and the plan ids in place (FAIL). The same probe,
  unchanged, passes after the change; it is now a committed test in `backup_restore_test.dart`.
- The archive is `format_version` 2: `preferences.json` (`BackupPreferences`) holds the planning
  preferences, the display preferences (field mode, section states), `activeLocationId` and
  `firstRunDone`, grouped by type; never the transient position, the catalog seed marker, the plan
  ids or the place-name opt-in. A version 2 file must carry readable settings; only carried keys
  are ever read from it. Staged beside the database and applied just before the swap (redone if a
  start is interrupted): the carried keys are replaced as a whole. A version 1 archive still
  restores; it keeps the device's settings but drops its active site. A restore and a confirmed
  reset clear `targetId`, `equipmentId` and `editedSessionId`; the reset drops the active site too.
- The repositories expose their keys (`keys`, `fieldModeKey`, `activeLocationIdKey`, `planIdKeys`,
  `doneKey`) so the backup never restates them. CLAUDE.md trap 5 notes it.
- Privacy: the backup stays a local file the user shares; the policy now says it holds the
  settings too. The Data Safety draft (`COMPLIANCE.md`) is unchanged: nothing leaves the device
  except where the user sends it.
- **Tests:** `backup_restore_test.dart` +7 (what is carried, by type; a round trip; the ENG-14
  probe; a version 1 archive restores; staging and cancel of the settings; a version 2 without or
  with bad settings refused; uncarried keys never applied) and the setup's in-memory preferences;
  `unsupported_database_test.dart`: a reset leaves no stale id. Mutation-checked: without the
  restore hook three tests fail.
- **Verification:** high-risk (backup format, persistence): the full gate after the last code
  change, **PASS** (1,785 tests, 2 skips; 2 host E2E; Flutter 3.47.4).
**S8.8 done, 2026-09-29** (TD-070 resolved; ADR-018 §5): per-field provenance in new snapshots.
- `SessionSnapshotBuilder` adds `rig.provenance`: each valued spec (`EquipmentSpec` name; the RAW
  size only when set) → `{source, confidence}` from `provenanceOf`, or null when unknown. The group
  pairs (S3.V7) stay; `v` stays 1; an older snapshot has no key and reads as stored. Nothing is
  recorded as `user` unless it was typed; an explicitly unknown field stays null. The export embeds
  snapshots as stored (manifest unchanged). No screen change.
- **Tests:** `session_snapshot_builder_test.dart` +3 (an imported rig's estimates and file values; a
  typed rig per field with one explicitly unknown field; a snapshot without the key still reads,
  `SavedPlanReader` included); the legacy case now pins every field null.
- **Verification:** high-risk (snapshot, provenance): the full gate after the last code change,
  **PASS** (1,778 tests, 2 skips; 2 host E2E; Flutter 3.47.4).
**S8.7 done, 2026-09-29** (P8.7; D8-4, I-6; 08 §24): the Logbook entry, Share and Export as file.
- The entry is a `DetailScaffold`: the identity (name, or target · night) with the site and zone;
  the result first (state, how it was reported, planned against actual, or when a result can be
  recorded); the name; the night, site, target and rig from the snapshot (budget words: Integration,
  Time needed, Total time); planned against actual per block; notes; conditions; then the actions
  its state allows (Open in planner before the night ends; Record result after it; Edit result with
  a result; Copy to another night for all but an old log), Share and Export as file. An old log
  offers Share and Export only. No tracker anywhere.
- Share (`EntryShareText`, pure; entry and list row): structured, only what the entry holds, never
  the notes or the coordinates. The download action is the one-entry manifest v2 export, kept and
  named Export as file. `SessionLog.toShareableText` removed with its two tests.
- The entry's retired terms are gone (the baseline lowered).
- **Tests:** `entry_share_text_test.dart` (3); Copy to another night (VM); the entry's actions by
  state; two detail assertions updated deliberately (the result summary repeats the integration;
  notes and conditions are two sections; Copy replaces ""Plan again (copy)"").
- **Verification:** shared behaviour (the entry, the list, a ViewModel): the full gate after the
  last code change, **PASS** (1,775 tests, 2 skips; 2 host E2E; Flutter 3.47.4).
**S8.6 done, 2026-09-29** (08 §24; P8.6): an optional plan name.
- Schema v25: `session_logs.name` (nullable). `SessionRepository.rename` (trimmed, up to 80
  characters, empty removes it; legacy refused; the plan, status and snapshot never change). Never
  asked at Save plan; set on the entry (""Name (optional)""); the Logbook shows it, else target ·
  night, and searches it; a working copy never takes it. Export key `name` (additive); the backup
  keeps it.
- Found on the way: the name dialog disposed its field while closing (fixed: the dialog owns it); the
  open Logbook did not re-read an entry changed elsewhere (fixed: `SessionsViewModel.revision`).
- **Tests:** the v25 migration group; `rename` and copy cases; the export round trip; the backup
  acceptance with a named plan; a UI test (set, list, search, remove). Pins v24 → v25 moved
  deliberately.
- **Verification:** high-risk (schema): the full gate after the last code change, **PASS** (1,773
  tests, 2 skips; 2 host E2E; Flutter 3.47.4).
**S8.5 done, 2026-09-29** (ADR-019 §2, §8, §10; UX-30; RD-07; I-9): the Logbook list.
- The tab and screen are Logbook; Upcoming (saved plans whose night has not ended) and Past; rows
  with the identity (target · night), `PlanStateLabel`, rig and site, planned against actual,
  Record result or Edit result. Search over the target, site and notes (in memory). Filters in one
  panel with a count, held by `SessionsViewModel` (survive navigation), combining with the search.
  Delete: swipe or the entry's visible Delete, after `confirmDestructive`. Progress by target moved
  from the Library to the Logbook (`/sessions/progress`). The list's retired terms are gone.
- `SessionsViewModel` moved to its own file (re-exported); `ProgressScreen` moved to the Logbook.
- **Tests:** `logbook_screen_test.dart` rewritten (5: listing and groups, search, the filter panel
  with search and persistence, delete cancel and confirm); the filter, legacy-row, tab-label and
  route tests updated deliberately (the chips, ""Sessions"", ""Legacy log"" and ""Planned"" are what
  S8.5 changes).
- **Verification:** shared behaviour (the router, a ViewModel, several screens): the full gate after
  the last code change, **PASS** (1,751 tests, 2 skips; 2 host E2E; Flutter 3.47.4).
**S8.4 done, 2026-09-29** (the owner's direction of 2026-09-27; ADR-016 §13): the live tracker retired.
- **The audit (A–E)** is in `ARCHITECTURE.md` (S8.4). Removed (A): the tracker screen and route, its
  ViewModel, the resume prompt, Start/Track live, Tonight's run card, the entry's Open tracker,
  keep-screen-on and the `wakelock_plus` dependency (no Dart use; the lockfile loses two packages),
  CALC-35 and CALC-36. Kept (B, C): the events, the fold and the counters' invariant, the
  repository's stored-run API, every stored run, the export and the backup; no migration.
- A run left in progress by an older version is offered on Tonight's line and in the Logbook and is
  recorded through the result form. **TD-063 resolved:** `openSession` re-reads the session; one
  deleted meanwhile opens as a copy (`stale_detail_open_test.dart`, fails on the old code).
  **TD-073 resolved** (the Start message left). **UX-13 and UX-26 closed.**
- Found and fixed on the way (S8.2's own acceptance, I-7): after a failed result write the form kept
  no choice; it now reloads only for a stale entry and otherwise keeps the input.
- **Tests (D, E):** retired with their reasons in the audit (the tracker's screen, prompt, outlook,
  estimate and running-time cases, Start-then-edit, the Track live menu case); lifecycle rows L4, L6,
  L8 replaced by the saved-night lifecycle; the E2E is Save → the night (a restart) → Tonight's line
  → result → export, and records a result across a DST change.
- **Verification:** a dependency change (high-risk): the full gate after the last code change,
  **PASS** (1,750 tests, 2 skips — fewer because the tracker's tests were retired; 2 host E2E;
  Flutter 3.47.4).
**S8.3 done, 2026-09-29** (ADR-019 §3.1, D1 delivered; D8-1, D8-2, I-3, I-8): the saved-plan
transition and Tonight's line.
- Once a saved plan's night has ended (CALC-44), it stays on its night with its snapshot, and the
  planner continues on one working copy, with the app open (`NightClock`) and at a restart
  (`CurrentSession.leaveEndedSavedPlan`): an untouched copy for Saved, a settlement for Saved ·
  changed (the edits in the copy, unsaved). The copy's night is the working night if still ahead,
  else tonight. Idempotent; a failure is logged and retried at the next check. A never-saved draft
  still rolls forward; a run keeps its copy rule. Opening an ended saved plan opens a copy.
- D8-2 tested: Save before the night ends replaces the snapshot, a changed night included.
- Tonight's line (`_ResultDue`): ""Last night: M42. How did it go?"" or the entry's date, from
  `SessionsViewModel.dueResult` (refreshed after each night check and each recorded result).
- **Tests:** `saved_plan_transition_test.dart` (8); two S6.4 rollover tests updated deliberately
  (their D1 ""saved plan stays current"" expectation is what S8.3 changes).
- **Verification:** time and night semantics (high-risk): the full gate after the last code change,
  **PASS** (1,789 tests, 2 skips; 2 host E2E; Flutter 3.47.4).
**S8.2 done, 2026-09-29** (ADR-019 §3.1, §4; UX-25 resolved; I-6, I-7): the result form.
- `/session/:id/results` is ""How did it go?"": the saved plan's review (snapshot night, target, site,
  rig, planned light blocks), Completed as planned · Partly (typed counts per light block) · Not done
  (optional reason), notes, conditions, Save result (`showDone`). Nothing preselected for a new
  result; a tracker run opens as Partly with its confirmed counts; an edit opens with its outcome.
- Back writes nothing; a stale form is refused and reloaded; a night not yet ended offers no result
  and says when it can. A Saved · changed entry is settled first (`CurrentSession.settle`); the
  planner keeps its edits on the copy with no prompt.
- The Logbook row and entry offer Record result (`ResultAction`, CALC-44) and Edit result. The
  tracker's Abandon became Not done in the form. `PlanState` shows Partly.
- **Tests:** `results_screen_test.dart` rewritten (11: run, checks, Not done, not yet, as planned,
  Partly with 0, Back, stale, Saved · changed, Record result, Edit result); the E2E's Finish step now
  saves through the form (""Result saved."").
- **Verification:** shared behaviour on the E2E path: the full gate after the last code change,
  **PASS** (1,781 tests, 2 skips; 2 host E2E; Flutter 3.47.4).
**S8.1 done, 2026-09-29** (ADR-019 §3.1, §4; D8-1, D8-3, I-1 to I-5, I-7): results without a run,
domain and data.
- **CALC-44** `SavedNightEnd`: a saved night ends at dawn at its snapshot's darkness limit, else at
  the night's end; without a readable snapshot, at the latest end of its night key.
- **Schema v24:** `session_logs.result_kind` and `not_done_reason`; `session_events` rebuilt to
  accept the `reported` kind (every event kept). `ExecutionMachine`: `reported` ends a run that
  never started.
- `SessionRepository.recordResult` (Completed as planned · Partly · Not done, for a Saved plan after
  its night, a run in progress and an edit of a result; stale forms refused) and `settleSavedPlan`
  (a Saved · changed plan → its saved entry plus a never-saved copy; idempotent).
- The export carries `result_kind`, `not_done_reason` and `reported` (manifest v2, additive).
- RD-13 built as notes on CALC-37/38. No screen changed (the form is S8.2).
- **Tests:** 17 repository tests (`drift_session_results_test.dart`), 2 machine tests, the v24
  migration group (16 schema tests and a data-preservation test), a manifest round trip. Deliberate
  changes: the backup and unsupported-database pins move from v23 to v24.
- **Verification:** high-risk (schema, persistence, a calculation): the full gate after the last code
  change, **PASS** (below).
**Stage 8 planned, 2026-09-29** (documentation only; the plan's "Stage 8 — frozen Task sequence"):
- **Verified against the code at `836bbdf` (§9.7).** Notable: a result can be recorded only through the
  tracker (`complete` accepts `inProgress` only); no Partly, Not done reason or name is stored; snapshot
  blocks have no ids and `capture_blocks` are re-inserted on every plan write, but a Saved row's blocks
  equal its snapshot's; saved plans keep a past night in the row while the planner shows tonight (D1);
  TD-063's mechanism is still present; the backup holds no preferences.
- **Decisions:** the owner delegated them to the agent in chat ("do not ask me; decide yourself").
  D8-1 (S4-DEF-02): a saved night ends at dawn at its snapshot's darkness limit, else at the night's end
  (CALC-44). D8-2 (S4-DEF-01): Save again before the night ends. D8-3 (RD-13): "Reported as planned";
  old estimates not relabelled. D8-4: Share without notes or coordinates. I-1 to I-10: the `reported`
  event, `result_kind` and `not_done_reason` (v24), results for legacy runs, settlement of Saved ·
  changed rows, unreadable snapshots, entry actions, stale forms, Tonight's line, the Logbook, the
  backup (DECISIONS E.1, "Stage 8 decisions").
- **Frozen:** S8.1 → S8.2 → S8.3 → S8.4 → S8.5 → S8.6 → S8.7 → S8.8 → S8.9 → Stage 8 validation. No
  gate is open.
- Stage 7's "Current state" entries moved verbatim to `PROGRESS_HISTORY.md`.
- **Verification:** the documentation class (V1): references and IDs resolve; `git diff --check`. No
  gate input changed, so S7.V2's gate is Stage 8's baseline (below).

**Before this:** Stage 7 closed on 2026-09-29 at `21e9cb1` ([report](STAGE_7_VALIDATION.md)); its
entries, from its planning to its closure, are in `PROGRESS_HISTORY.md`.

## Reusable validation evidence

Per `CLAUDE.md`, Verification Policy V3: reuse while the inputs are unchanged.

| Evidence | Ran at | Still valid because |
| --- | --- | --- |
| **Full quality gate PASS** (S8.9): Encoding; Format (463 files, 0 changed); Analyze (no issues); 1,785 tests, 2 expected skips; 2 host E2E | **`690b94a`**, S8.9's final inputs, on Flutter 3.47.4 | Ran after S8.9's last code change, the last code change of Stage 8; supersedes S8.1–S8.8's gates. Reused by the Stage 8 validation: `git diff --stat 690b94a HEAD -- . ':!docs' ':!CLAUDE.md' ':!README.md'` empty. Reusable while that diff stays empty. Supersedes S7.V2's gate at `d28f5a8` (1,734), kept below as Stage 7's closing evidence |
| **Full quality gate PASS**: Encoding; Format (461 files, 0 changed); Analyze (no issues); 1,734 tests, 2 expected skips (the local real samples; the opt-in S5.9 render test); 2 host E2E | **`d28f5a8`**, S7.V2's final inputs | Ran after S7.V2's last code change; covers both corrections. Reused by the V5 revalidation: `git diff --stat d28f5a8 HEAD -- . ':!docs' ':!CLAUDE.md' ':!README.md'` empty at `21e9cb1`. Supersedes S7.V1's gate at `46e7688` (1,719) and S7.6's at `d13fdab` (1,710) |
| **Stage 8 validation probes PASS**: P1 (v23 → v25 preservation, every status), P2 (S8.4 acceptance 2), P3 and P4 (mutations: the TD-063 and ENG-14 tests fail without their fixes) | Stage 8 validation at `690b94a` | Temporary, removed; application code unchanged since. P5 reproduced TD-085 (not a pass) |
| **Pinned catalog regeneration PASS**: 164 objects (109 Messier), output matches committed text after line-ending normalization | Stage 7 validation at `d13fdab` | Tool/asset unchanged; temporary source CSVs removed, original asset bytes restored |
| **Six Stage 7 probes PASS** (FAIL at `d13fdab`): the two patches applied unchanged to the `099531b` test files, run against the corrected `lib/` | V5 revalidation at `21e9cb1` | Application code unchanged since `d28f5a8`; the same cases are committed tests in the gate above. Six fresh probes (V5-P1..P6) also PASS; temporary, removed |
| Local real-sample metadata test PASS (DNG, JPEG, HEIC) | After S3.V4 (`2447962`) | Metadata code unchanged since; environment-dependent (the owner's sample folder) |
| Device checks M1–M4 PASS (owner's Xiaomi 14T Pro, `.s2check` build) | `79f392c`, `237c55f`, `2b045eb` | Device evidence; valid for the flows it covered until those flows change. S3V-08 and S2V-06's checks remain unverified |
| **Focused probe PASS after S6.V1** (was FAIL at the validation, application code `d7e1477`): `evidence/S6V_01_DELETE_UNDO_PROBE.patch` applied unchanged, run (`--plain-name "S6V probe"`), then removed; "4 blocks, last count 7, example badge false" | S6.V1's final inputs | The same inputs as the gate above. Its sequence is also a committed test now (`capture_blocks_undo_test.dart`) |

## Stage status

Vocabulary: Not started · Planning · In progress · In validation · Complete.

| Stage | Name | Status | Opened | Closed | Stage validation |
| --- | --- | --- | --- | --- | --- |
| 0 | Refinement Baseline | Complete | 2026-09-25 | 2026-09-25 | Self-review against the Stage 0 prompt's §22 checklist (`PROGRESS_HISTORY.md`, "Validation status"). The prompt asks for no separate validation session |
| 1 | Verified Fixes & Clean Baseline | Complete (owner waiver) | 2026-09-25 | 2026-09-26 | **Did not pass**: independent validation failed at `4e653fb` (TD-059–TD-062, fixed), then at `c99bd7f` (TD-063, X2). The owner closed the Stage anyway: TD-063 goes to Stage 8; X2 and W1 are carried |
| 2 | Metadata Foundation | Complete (owner waiver) | 2026-09-26 | 2026-09-26 | **Did not pass independently**: it failed at `79f392c` (fixed, `ffaff57`) and at `5d8bdbb` (S2R-01/TD-067; fixed by S2.V4/S2.V5, `d8e792c`/`435b3ce`). The owner then waived a third validation (E.1, "Stage 2 closed by the owner") |
| 3 | Metadata → Equipment / Device Import | Complete | 2026-09-26 | 2026-09-27 | **Fresh-session final sign-off PASS** at `92ebf2a` (`STAGE_3_FINAL_SIGNOFF.md`; S3F-01, S3F-02 non-blocking). Before that: FAIL at `387e54b`; a same-chat technical PASS at `d5e2b60` (`STAGE_3_REVALIDATION.md`); a fresh-session FAIL at `74026ca` (`STAGE_3_SIGNOFF_VALIDATION.md`, fixed by S3.V7/S3.V8). Device recheck S3V-08 unverified |
| 4 | Product Flow & Information Architecture | Complete | 2026-09-27 | 2026-09-27 | **Final, bounded validation PASS** at `09a7f06` (`STAGE_4_FINAL_VALIDATION.md`; the owner's seven questions; run in the authoring session at the owner's request, disclosed). Before that: **FAIL** at `adb5d95` (`STAGE_4_VALIDATION.md`, S4V-01), corrected by S4.V1. The fresh-session revalidation **FAILED** at `5ad69c4` (`STAGE_4_REVALIDATION.md`): S4R-01 and S4R-02 blocking, S4R-03 and S4R-04 low, all addressed by S4.V2 (the owner's R2 + D1). S4.V3 bounded the final validation, which then passed. S4V-02 is non-blocking and S4V-03 unverified |
| 5 | Design System Foundation | Complete | 2026-09-27 | 2026-09-27 | **FAIL** at `8a6c5d8` on one narrow blocker, S5V-01; S5.V1 (`178acbe`); **revalidation PASS** at `178acbe` ([report](STAGE_5_VALIDATION.md); same chat at the owner's request, disclosed) |
| 6 | Core Planner Redesign | Complete | 2026-09-27 | 2026-09-28 | **BLOCKED** at `6b50369` on one blocker, S6V-01 / TD-082; S6.V1 (`da4c53d`); **V5 revalidation PASS** at `da4c53d` ([report](STAGE_6_VALIDATION.md); same chat at the owner's request, disclosed). S6.E UNVERIFIED, a gap the owner accepted |
| 7 | Data Entry & Automation | Complete | 2026-09-28 | 2026-09-29 | **BLOCKED** at `d13fdab` (fresh-session independent validation): S7V-01 / TD-083 and S7V-02 / TD-084; S7.V1 (`46e7688`) and S7.V2 (`d28f5a8`); **V5 revalidation PASS** at `21e9cb1` ([report](STAGE_7_VALIDATION.md); same chat at the owner's request, disclosed) |
| 8 | Sessions / Execution / Actuals / Logbook | Complete | 2026-09-29 | 2026-09-29 | **PASS** at `690b94a` (fresh-session independent validation, [report](STAGE_8_VALIDATION.md)); no blocker; S8V-01 to S8V-03 recorded as TD-085 to TD-087 (non-blocking) |
| 9 | Secondary UX & Product Polish | In progress (planned; S9.1 next) | 2026-09-29 | — | — |
| 10 | Performance & Application Size | Not started | — | — | — |
| 11 | Full Validation & Beta Readiness | Not started | — | — | — |

## Open research gates

All defined in `POST_ROADMAP_PLAN.md` §7.

| ID | Topic | Stage | Status |
| --- | --- | --- | --- |
| RG-01 | Metadata formats, libraries, file selection and samples (resolves PD-21) | 2 | **Decided** 2026-09-26 (ADR-017), **amended** the same day (the owner's priorities, ADR-017 §13). JPEG and HEIC samples exist (S2.8, S2.9); FITS, PNG and proprietary RAW still need samples, and are out of Stage 2 |
| RG-02 | Metadata → equipment identity, derivability, matching, provenance and conflicts | 3 | **Decided** 2026-09-26 (S3.D; ADR-018), after S3.R1 (`research/RG-02_EQUIPMENT_IDENTITY.md`) |
| RG-03 | Sourcing equipment specifications (catalog or none; licence; the verified-seed policy) | 3 (7) | **Deferred by the owner** 2026-09-26 (S3.D, D2): no source in Stage 3. **Researched** 2026-09-29 (S7.R5, `research/RG-03_EQUIPMENT_SPECS.md`); **decided 2026-09-29: Q1** (no source; lensfun crop factors the candidate with RG-12, Stage 9) |
| RG-04 | Execution's role and how actuals are captured | 4 | **Decided** 2026-09-27 (S4.R2; E.1): B, the Logbook first and the tracker optional; G2 post-session results. Its optional tracker is **superseded** 2026-09-27 (the tracker leaves the target product; P8.4) |
| RG-05 | Home/Tonight hierarchy, drill-downs and a possible Analytics destination | 4 | **Decided** 2026-09-27 (S4.R4; E.1): Tonight plan-first with a context line; detail screens; no new tab |
| RG-06 | Basic/Advanced modes against progressive disclosure | 4 | **Decided** 2026-09-27 (S4.R4; E.1): progressive disclosure; no modes |
| RG-07 | Target catalog expansion, names and search | 7 | **Decided** 2026-09-29 (S7.R3; DECISIONS E.1, "RG-07 decided"): T1 only |
| RG-08 | Site elevation: an automatic source, optional, or dropped | 7 | **Decided** 2026-09-29 (S7.R4; DECISIONS E.1): E2, optional and Unknown by default |
| RG-09 | Bortle/SQM sources, whether SQM stays a field, and the light-pollution map provider | 7 | **Decided** 2026-09-29 (S7.R4; DECISIONS E.1): S3 (manual, optional, collapsed), M2 (lightpollutionmap.app) |
| RG-10 | Calibration-frame workflows and inheritance | 7 | **Decided** 2026-09-29 (S7.R2; DECISIONS E.1, "RG-10 decided"): L1, D1, T0, O0, N1, H1; ADR-020 |
| RG-11 | Capture parameters (ISO or gain, binning, white balance, focus, interval) and their labels | 7 | **Decided** 2026-09-29 (S7.R1; DECISIONS E.1, "RG-11 decided"): C1, B1, W1, F1, I1, P2; ADR-020 |
| RG-12 | Licence requirements against GPL-3.0 | 9 | Open |
| RG-13 | Settings: real-world needs and where each setting belongs | 9 | Open |
| RG-14 | Proprietary RAW compatibility and libraries (no ad hoc parsers) | 2 (S2.R3) | **Decided** 2026-09-26 (DECISIONS E.1): none in Stage 2; per-format adapters later, with samples; `ExifInterface` and LibRaw rejected |

## Open owner decisions

All defined in `POST_ROADMAP_PLAN.md` §8.

| ID | Decision | Stage | Status |
| --- | --- | --- | --- |
| RD-01 | The GitHub account behind the app identity: `chacha12` or `Buffur` | Before any upload | Open (the author's own links do not wait for it, 2026-09-27) |
| RD-02 | The TASK 0.3 holdovers (ADK skill, `skills-lock.json`, `docs/archive/`, `sqlite3_flutter_libs`) | 1 / 10 | Open |
| RD-03 | Wording rulings: the SCI-05 ISO label; the SCI-04 time-resolution caveat | 1 | **Resolved** 2026-09-25: a neutral label (S1.8); SCI-04 documented only (S1.13). DECISIONS E.1 |
| RD-04 | New-draft defaults and the example plan | 4 | **Decided** 2026-09-27 (S4.R3; E.1): nothing preselected on the first run; New keeps the site and rig; an empty plan with "Start from the example plan" |
| RD-05 | Drafts and "New session" semantics (Stage 1 may decide an interim safeguard) | 4 (1) | **Decided** 2026-09-27 (S4.R3; E.1): L1 (Draft internal; Save explicit), Y2, U1. The S1.6 interim stands until Stage 6 builds U1. **Clarified** 2026-09-27 (S4.V2; E.1, "S4R-01 and S4R-02 decided"): saved snapshots are immutable per night; results without Save plan; Stage 8 delivers the saved-plan transition at once |
| RD-06 | The planner's section order; integrity text one tap away | 4 | **Decided** 2026-09-27 (S4.R4; E.1): answer first, decision order; detail one tap away |
| RD-07 | The Library's role and pickers; where Progress lives | 4 | **Decided** 2026-09-27 (S4.R5; E.1): the Library manages; choosing in context; Progress in the Logbook |
| RD-08 | Tracking per rig or per session; the seeded rig's tracking | 7 (before Stage 6's capture-plan work, P6.8 = S6.9) | **Decided** 2026-09-28 (owner): **T3**, the rig's default with a per-plan override; the seeded rig stays unknown (DECISIONS E.1, "RD-08 decided"). Built in Stage 7 by **S7.1** (ungated) |
| RD-09 | Destructive interactions: confirm or undo | 5 | **Decided** 2026-09-27 (owner): **M + S1**, undo for edits inside a plan, confirm for stored records; a visible Delete with swipe as a shortcut (DECISIONS E.1, "RD-09 decided"; `IA_WIREFRAMES.md` §3 amended for plan edits). Built by S5.8 |
| RD-10 | Ordering Tonight's candidates without a score | 6 (S6.14) | **Decided** 2026-09-28 (owner): **O1**, usable time, then frame fill, then the name (DECISIONS E.1). Built by S6.14 |
| RD-11 | Where the Moon and cloud gate controls live (TD-050) | 6 or 9 (S6.15 or P9.3) | **Decided** 2026-09-28 (owner): **S9**, Stage 9's Settings (P9.3, with RG-13); S6.15 not built (DECISIONS E.1) |
| RD-12 | The resume prompt's Finish | 8 | **Lapsed** 2026-09-27: the resume prompt goes with the tracker (E.1, "Stages 6–11 amended after Stage 5"); P8.4's audit covers a run still in progress at the upgrade |
| RD-13 | Provenance of an accepted estimate | 8 | **Decided** 2026-09-29 (Stage 8 planning, delegated by the owner; E.1, "Stage 8 decisions", D8-3): "Reported as planned"; old estimates not relabelled. Built by S8.1 |
| RD-14 | Vocabulary (rig or equipment; Sessions or Logbook; window names) | 4 | **Decided** 2026-09-27 (S4.R5; E.1): Rig, Plan, Logbook; the glossary |
| RD-15 | A local diagnostics export for the beta | 11 | Open |
| RD-16 | When the metadata feature becomes visible (PD-06 gate) | 2 (3) | **Resolved** 2026-09-26 (S3.D, ADR-018 §7): visible at the end of Stage 3 (S3.7), as "Add from a photo" on the equipment screen. It stayed hidden throughout Stage 2 |
| RD-17 | Push the CI workflow to the remote and observe a first run | 1 (optional) / 11 | Open; **push deferred by the owner** when S1.14 ran (2026-09-25; the remote is public) |

Answered in part by Stage 0: the direction part of 07 §6 item 11 (the primary 1.0 user), in
`PRODUCT_DIRECTION.md` §2. Modes stay open as RG-06.

## Owner actions outstanding

These block a release, not refinement.

- TASK 16.2: create the upload key and `android/key.properties`; install the SDK cmdline-tools;
  build and check a signed bundle (`docs/RELEASE.md`).
- TASK 16.3: publish the privacy policy with the contact email filled in; confirm the URL is
  live; make the repository public; fill in the Data Safety form (`docs/COMPLIANCE.md`).
- OD-07: a formal trademark search before the first upload; RD-01.
- A device or emulator for the device rows (`TEST_PLAN.md` L1–L8, and the other checks in
  `POST_ROADMAP_PLAN.md` Appendix B).
- Stage 3: say which cameras and optics you use besides the phone (a DSLR/mirrorless JPEG, or a
  FITS file, would let Stage 3 check those classes on real files). The phone is needed for S3.7's
  device check M4. *(M4 passed at `2b045eb`; the phone is now needed only for the optional S3V-08
  recheck and S2V-06's checks. Noted at the Stage 3 final sign-off.)*
  Samples for FITS, PNG, AVIF or RAW, when available, enable their readers later. The DNG,
  JPEG and HEIC samples stay outside Git.

## Known blockers

- **Stage 1 (closed by waiver):** X2 is done (S1.V6, 2026-09-26). TD-063 is in Stage 8. W1 was
  decided with RD-05's U1, and S6.3 builds it.
- **Stage 2 (closed by waiver):** nothing blocks. The carried items are listed under "Next
  allowed action".
- **Stage 3 (closed by the final sign-off PASS, 2026-09-27):** nothing blocks. Carried: S3V-08
  (device recheck, `.s2check` only), TD-072 with S3F-01, S3F-02, TD-070's Stage 8 remainder.
  Equipment identity for dedicated astro cameras still needs a FITS sample (S2.6).
- **Stage 4:**
  - **closed 2026-09-27** (the final, bounded validation passed). Carried to Stages 6 and 8:
    S4-DEF-01 to S4-DEF-08;
  - S4.E stays optional; Stage 6 carries the five-second test as S6.E;
  - S4V-02's script correction: **done 2026-09-28** as S6.E's first step.
- **Stage 5 (closed 2026-09-27):** nothing blocks.
  - Carried: TD-073 (two messages with an action persist: the site prompt's in S6.13, the Start
    message's in P8.4); UX-39's field-mode card borders (Stage 11 darkness test); `CLAUDE.md`'s
    stale test count.
  - Optional: the owner's review of the S5.9 images.
  - The adoption plan (`DESIGN_SYSTEM.md` §9) feeds Stages 6, 8 and 9.
- **Stage 6 (closed 2026-09-28):** nothing blocks. S6V-01 / TD-082 was resolved by S6.V1 and its
  V5 revalidation passed ([report](STAGE_6_VALIDATION.md)). Product gates decided: S4-DEF-04 (R),
  RD-08 (T3, the override built in Stage 7), RD-10 (O1), RD-11 (S9).
  - Carried: S6.E UNVERIFIED (the owner accepts the missing independent participant); the tracker
    until P8.4; TD-074 (allocated to Stage 9's planning at Stage 7 planning); TD-050 (Stage 9,
    P9.3); TD-081 (Stage 9 or 11); the validation's DEFERRED items (Stage 7's are now in its frozen
    sequence; Stage 8: saved-plan working copy and results, P8.1–P8.4, P8.7; Stage 9: richer detail
    screens).
- **Stage 7 (closed 2026-09-29):** nothing blocks. S7V-01 / TD-083 and S7V-02 / TD-084 were
  resolved by S7.V1/S7.V2 and the V5 revalidation passed ([report](STAGE_7_VALIDATION.md)).
  Carried: TD-074 (Stage 9 planning); RG-03 = Q1 with lensfun as the RG-12 candidate (Stage 9);
  the device and real-sample gaps listed under "Carried". All Stage 7 research
  and owner gates are decided; no new decision blocks these corrections. Other criteria retain PASS.
- **Stage 8 (closed 2026-09-29):** nothing blocks. Validation PASS ([report](STAGE_8_VALIDATION.md)).
  Carried: TD-085, TD-086, TD-087 (non-blocking follow-ups); the lifecycle device rows L1–L8 (Stage 11).
- **Device evidence:** M1 seekable providers and M2 non-backup/cancel paths were
  recorded at `79f392c`. Native streaming and real-backup preview cancellation
  remain unverified on-device. S2.V3 adds host JVM streaming tests; these do not
  upgrade device evidence. Stage 11 lifecycle rows remain open.
- **Release:** RD-01; the 16.2 upload key; the 16.3 policy. These do not block refinement.

## Next allowed action

1. **Stage 9 validation of S9.1–S9.9** against the frozen Stage 9 acceptance and D9-1 to D9-6, in a
   separate agent (reuse the S9.9 gate, V3). The Stage closes only when S9.10–S9.12 are decided and
   built, or deferred by the owner (the Stage's exit).
2. **The owner's decisions:** S9.10 (choose a logo option), S9.11 (RG-12: the licence), S9.12 (RD-01:
   the identity; TD-088). and the Stage 9 validation: the owner
   asked, in chat on 2026-09-29, for the next Stage as a whole, so each Task follows the previous one's
   commit without a new prompt.
2. **Owner gates, prepared by the agent:** S9.10 (the logo: the owner chooses), S9.11 (the licence,
   RG-12: the owner decides), S9.12 (the project identity, RD-01: the owner decides).

Stage 8 is closed. Stage 9's open gates: S9.10–S9.12 (the owner's).

**Carried:**
- S4-DEF-04 decided (R) and built by S6.3; S4-DEF-01 to S4-DEF-03 and S4-DEF-05 to S4-DEF-08 decided
  at Stage 8 planning (E.1, "Stage 8 decisions") and built by S8.1–S8.7;
- S4V-02: done (S6.E step 1, 2026-09-28);
- S3V-08: a device recheck of the corrected Stage 3 flow (unverified; separate);
- TD-072 (S3S-03, deferred by the owner) with its S3F-01 addendum; S3F-02 (a note on TD-071, no
  Task proposed);
- TD-070: resolved (S8.8); snapshots saved before S8.8 keep their group pairs and are read as stored;
- W1 (decided with RD-05's U1): built by S6.3;
- TD-063: resolved (S8.4);
- TD-057 and TD-058: resolved (S6.4, S6.2);
- TD-074: allocated to Stage 9's planning (not data entry); the owner may pull it into Stage 7;
- RD-17 (the push is deferred);
- the S1.5 and S1.11 device checks (Stage 11);
- S2V-06's device checks (a non-seekable provider; a real backup's preview cancel): the next
  time the phone is connected, or Stage 11;
- the stale id-holding preferences after a reset: resolved with TD-056/ENG-14 (S8.9);
- TD-085, TD-086, TD-087: the Stage 8 validation's non-blocking follow-ups, for a later Task that
  touches the saved-plan boundary, the result form or these tests.

## History

Earlier current-state entries, the completed-Task table, relevant commits, validation-status
entries, superseded next actions and the Stage 0 notes are in
[`PROGRESS_HISTORY.md`](PROGRESS_HISTORY.md), verbatim. Stage validation detail is in the
`STAGE_N_*.md` reports; Task detail in commits and the living registers.

## How to update this file

- **Replace, don't append.** "Current state" and "Next allowed action" describe now. When they
  change, replace the old text; it survives in Git. Do not keep superseded entries here.
- **At the end of every Task:** one line under "Current state" (Task, commit, finding IDs
  resolved, verification per the policy or the reused evidence); update the next Task; update any
  RG or RD it touched (resolved: date, and where the decision is written); update "Reusable
  validation evidence" if a check ran or its inputs changed.
- **At every Stage boundary:** update the Stage status table (dates, validation result in one
  line, with a link to the report); set the next allowed action; refresh "Known blockers" and
  "Carried"; drop the closed Stage's detail from "Current state".
- **Validation results** go in the Stage's `STAGE_N_*.md` report; this file gets one line and the
  link. Record evidence reuse in one line (what, where it ran, why it still holds).
- Keep it short enough to read at the start of every session.
