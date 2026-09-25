# 07 — Final post-roadmap audit: the verified truth

> **Stage 7 (synthesis).** 2026-09-25, `main` @ `becae04`. No application code or
> source-of-truth document was changed; this file is the only one added.
>
> **Basis.** Audits 01–06. `docs/audit/00_CONTEXT_BASELINE.md` has never existed. Contradictions
> between stages are resolved by the counter-audit (06), which re-checked the cited evidence in
> the repository. No new findings are introduced here, and no new runtime runs were made.
>
> **How to read this report.**
> - **Facts** are statements backed by code, test output, git state or recorded probe output. They
>   are written plainly, with the stage that holds the evidence (e.g. "04/P1", "06 §3").
> - **Recommendations** are marked *Recommendation:* and are this report's judgement.
> - Ordering in sections 2–5 follows **reach** (how many users/sessions it affects) and **data
>   impact**, stated per row; there is no overall score.

---

## Answer in brief

| Question | Verified answer |
| --- | --- |
| What was implemented? | Every roadmap task from 0.1 to 16.3 has an implementation or an accepted decision, except TASK 10.5 (cut by the owner). Of the 60 tasks through 16.3, 43 meet their acceptance on host evidence; the rest are partial, unverified on a device, or waiting on the owner (§1) |
| What is correct? | The astronomy, time model, Moon, NPF, optics, capture budget, fit, opportunity, provenance and seeds match their documented definitions and independent reference tests (03 C-01…C-23; not contested by 06). 896 unit/widget tests and 2 E2E tests pass on the host; the E2E also passed as a native Windows app (04/R3) |
| What is broken? | No BROKEN task. Confirmed defects are all Low or Medium: frozen forecast freshness, a seed failure that is never retried, a missing user agent, a siteless draft date key, several visible text/format defects, a 200 %-text overflow and some UX defects (§2–§5) |
| What is uncertain? | Everything on Android: nothing has ever been installed or run on a device or emulator; no human has used the current build; red mode has never been seen in darkness; TalkBack was never run (§7) |
| What must the owner verify manually? | The device checklist in §7.1 |
| What should change after verification? | §9 (priority) and §10 (directions, not solutions) |

---

## 1. Roadmap completion truth (G0 → TASK 16.3)

Status of each task **as of this report**. "Host" means the evidence is the host test engine or
native Windows, not Android. Sources: 01 per task, with 06's adjustments.

| Task | Status | Basis |
| --- | --- | --- |
| 0.1 Commit reconciled docs | CONFIRMED | commit `34a7157` |
| 0.2 Adopt roadmap; PD-06 | CONFIRMED | `af076d9`; DECISIONS PD-06 |
| 0.3 Repository hygiene | PARTIAL + OWNER DECISION | ADK skill, `skills-lock.json`, archive retention, `sqlite3_flutter_libs` held for the owner; no device smoke run |
| 1.1 Test harness, platform seams | CONFIRMED | `LocationService`, `ready`; no sleeps |
| 1.2 Deterministic bootstrap | CONFIRMED (host) | seeding before `runApp`; error + retry. Seed-failure defect ENG-02 (§2) |
| 1.3 Quality gate and CI | PARTIAL | script works; the CI workflow commit is not on the remote, so CI has never run (06 re-checked) |
| 2.1 ADR SessionNight | CONFIRMED | ADR-007 |
| 2.2 SessionNight, resolver, Clock | CONFIRMED | T1–T17 tests |
| 2.3 Calculators consume SessionNight | CONFIRMED | |
| 2.4 Planner adopts SessionNight | UNVERIFIED (acceptance names an emulator in America/Los_Angeles); host equivalent CONFIRMED | |
| 3.1 ADR persistence baseline | CONFIRMED | ADR-008 |
| 3.2 Snapshots and migration tests | PARTIAL | tests pass; the reset/explanation UI of ADR-008 §2/§9 is not built (`resetUnsupportedDatabaseFile` has no caller) |
| 3.3 Foreign keys; drop orphan table | CONFIRMED | |
| 4.1 Capture-block editing defects | CONFIRMED | |
| 4.2 Save/selection/logbook consistency | CONFIRMED | |
| 4.3 Encoding fixes; gate enforcement | CONFIRMED | |
| 4.4 Honest numbers and labels | CONFIRMED in intent; literal acceptance ("SNR absent from lib/") not met by 4 negating comments — accepted by 06; DEV-P2's statement is inaccurate | |
| 5.1 ADR capture budget | CONFIRMED | ADR-009 |
| 5.2 Planning preferences, Settings | CONFIRMED | |
| 5.3 CaptureBlock model and schema | CONFIRMED | |
| 5.4 CaptureBudgetCalculator | CONFIRMED | |
| 5.5 Fit analysis | CONFIRMED | |
| 5.6 Capture planner UI | CONFIRMED | |
| 6.1 ADR ephemeris | CONFIRMED | ADR-010 |
| 6.2 Reference fixtures | PARTIAL | sourced fixtures exist; CALC-01/02/03/06 tests use canonical constants without citations (06: citation gap only) |
| 6.3 Moon ephemeris | CONFIRMED | Horizons/USNO references |
| 6.4 MoonConditions | CONFIRMED | |
| 6.5 Correct NPF | CONFIRMED | documented test-method deviation |
| 7.1 Site model and schema | CONFIRMED | |
| 7.2 Location and geocoding | CONFIRMED (host); device permission dialogs UNVERIFIED | |
| 7.3 Sites UI, first-run site | CONFIRMED | |
| 7.4 Light-pollution MVP | CONFIRMED | |
| 8.1 Target model hardening | CONFIRMED | |
| 8.2 Curated catalog | CONFIRMED | 164 objects |
| 8.3 ADR equipment model | CONFIRMED | ADR-011 |
| 8.4 Equipment domain and schema | CONFIRMED | |
| 8.5 Seed verification | CONFIRMED | |
| 8.6 Capability and NPF guidance | CONFIRMED | |
| 9.1 ADR weather | CONFIRMED | ADR-012 |
| 9.2 WeatherSnapshot, UTC parsing | CONFIRMED (recorded fixtures) | |
| 9.3 Caching and staleness | CONFIRMED (host) — with the freshness defect ENG-01 (§2) | ADR-012 §6 not met while the app stays alive |
| 9.4 Night-aligned weather UI | CONFIRMED | precipitation-time wording SCI-02 (§3) |
| 10.1 ADR opportunity | CONFIRMED | ADR-013 |
| 10.2 Opportunity calculator | CONFIRMED | |
| 10.3 Opportunity presentation | CONFIRMED | |
| 10.4 Tonight's candidates | UNVERIFIED (acceptance: < 1 s on a mid-range device); host < 1 s | |
| 10.5 Azimuth and horizon | DEFERRED (cut by owner) | |
| 11.1 ADR Session aggregate | CONFIRMED | ADR-014 |
| 11.2 Session schema migration | CONFIRMED | |
| 11.3 SessionRepository | CONFIRMED | |
| 11.4 Planner on a persisted draft | CONFIRMED (host); device force-stop UNVERIFIED | |
| 12.1 IA ADR | CONFIRMED | ADR-015 |
| 12.2 Navigation shell | CONFIRMED | |
| 12.3 ViewModel decomposition | CONFIRMED | `SessionPlanViewModel` at 299/300 lines |
| 12.4 Theme tokens; red mode | CONFIRMED (host); darkness checklist not done | |
| 12.5 Tonight dashboard, first run | PARTIAL | owner walkthrough not done (TEST_PLAN:753) |
| 13.1 ADR execution | CONFIRMED | ADR-016 |
| 13.2 Execution state machine | CONFIRMED (host); real process kill UNVERIFIED | |
| 13.3 Execution screen | CONFIRMED (host); device checklist not done | |
| 13.4 Reconciliation | CONFIRMED | resume-prompt Finish → OWNER DECISION (§6) |
| 14.1 Logbook list and detail | CONFIRMED | |
| 14.2 Integration per target | CONFIRMED | |
| 14.3 Export manifest v2 | CONFIRMED (share sheet faked) | |
| 14.4 Backup and restore | CONFIRMED (host); emulator round trip UNVERIFIED | |
| 15.1 Error handling | CONFIRMED | |
| 15.2 Performance and caching | PARTIAL | no device profile traces |
| 15.3 Accessibility pass | PARTIAL | no TalkBack walkthrough; forecast states not swept (UX-31/32) |
| 15.4 Lifecycle matrix | PARTIAL | device rows L1–L8 not run |
| 15.5 E2E suite | UNVERIFIED (acceptance: green on an emulator); green on host and native Windows | |
| 16.1 App identity | CONFIRMED (decision and code); install UNVERIFIED; trademark search OWNER DECISION | |
| 16.2 Release build and signing | PARTIAL + OWNER DECISION | no upload key, no signed AAB |
| 16.3 Legal and compliance | PARTIAL + OWNER DECISION | policy contact placeholder; URL live unknown; Data Safety not filed |

Milestones: **M0** partial (CI never ran); **M1, M4–M6** confirmed on host; **M2** partial (3.2,
4.4 wording); **M3** partial (no recorded dogfooding go/no-go). No milestone tag exists.
**BROKEN: none. NOT IMPLEMENTED: none** (10.5 is deferred by decision).

---

## 2. Confirmed engineering issues

Only issues that survived 06. Reach and impact stated per row.

| ID (duplicates) | Fact | Evidence | Reach / impact |
| --- | --- | --- | --- |
| ENG-01 (SCI-01, RT-01) | Forecast age class and "Updated N min ago" are computed once at load; nothing reloads on the clock, on resume, or when the night rolls over; the frozen class is written into snapshots | `night_weather_service.dart:89-100`; no lifecycle hook; 04/P1 reproduced | Any session where the app stays alive > 3 h; misleading freshness, ADR-012 §6 not met. **Frequency on Android unverified** |
| ENG-02 (RT-02) | A catalog seed whose inserts fail is recorded as applied and never retried | `catalog_seeder.dart:225-236`; 04/P2 | Rare trigger (store fails, prefs succeed); impact: catalog permanently empty on that install |
| ENG-03 (RT-07) | Open-Meteo requests carry no `AppIdentity.userAgent` | `open_meteo_weather_repository.dart:59-61` | Every forecast request; breaks CLAUDE.md trap 22 (a compliance rule) |
| ENG-05 (SCI-11, RT-06) | A draft without a site uses the UTC calendar date as its night key | `session_plan_viewmodel.dart:95,149` | Transient; corrected by the next autosave with a site |
| ENG-06 | Planned integration rounded in the planner, truncated elsewhere; a dead getter | `capture_budget_summary.dart:13-16` vs `opportunity_text.dart:9-14` | Cosmetic inconsistency (e.g. "1h 0m" vs "59 min") |
| 3.2 / RT-03 | A below-floor or newer database shows a generic error with a Retry that cannot succeed; no reset path | no caller of `resetUnsupportedDatabaseFile` | Downgrade/sideload only; data is safe |
| Test coverage (UX-32, ENG-04) | The accessibility sweep never renders a forecast; 25 planner test files use the preferences path production doesn't use | `accessibility_test.dart:33,87`; harness default | Tests over-state coverage; no user impact by itself |

---

## 3. Confirmed scientific and data issues

The calculations themselves are correct (03 §2). The surviving issues are labelling and
documentation.

| ID | Fact | Evidence | Impact |
| --- | --- | --- | --- |
| SCI-02 | "Chance of precipitation" is shown per hour, but Open-Meteo's value covers the *preceding* hour; CALC-32 says values are instantaneous except gusts | Open-Meteo docs (re-fetched in 06); `SCIENTIFIC_INTEGRITY.md:785` | Low: one-hour shift in a displayed probability |
| SCI-06 | Candidates say "fills N % of the frame" for a major-axis ÷ short-side ratio; the planner words it correctly | `tonight_candidates_screen.dart:239` | Low |
| SCI-03 (RT-09) | Two "Moon up" definitions differ by 5–10 min, undocumented as a difference | 04/P3 measured | Low |
| SCI-09 | Moon illumination is the value at mean solar midnight; the UI does not say so | ADR-013 §2 | Low (documented simplification) |
| SCI-10 + doc drift | Calculation docs contradict the code (NPF "not shown", √N "signal improvement", SI status mismatches, CALC-07 lists a removed function); DEV-P2 "SNR absent"; F-49/ROADMAP "no remote"; TEST_PLAN L3 old app id | cited lines in 03, 06 | Documentation accuracy only |
| UX-20 (data shown) | Session detail prints "f/5.555555555555555"; RA shown in degrees there vs h:m:s elsewhere | `session_detail_screen.dart:235-237` | Low; visible in the log |

Documented and acceptable (not defects): SCI-04 grid bias within its [−2, +7] min tolerance,
SCI-07 accepted estimates stored as confirmations (ADR-016), SCI-08 elevation (F-07), SCI-13
darkness limit (TD-051/054).

---

## 4. Runtime and functional issues

### 4.1 Confirmed failures (reproduced on host)

| Issue | Reproduction |
| --- | --- |
| ENG-01 forecast freshness | 04/P1: `age=current` 5 h after load; previous night's forecast kept after rollover |
| ENG-02 seed failure never retried | 04/P2: 164 failed inserts, version stored, next launch skips |
| RT-03 newer schema | 04/P5: generic error, Retry repeats the failure |
| RT-05 / UX-12 hidden drafts | 04/P4: 4 drafts stored, 0 listed; a replaced draft cannot be reopened |
| UX-31 200 % text | 05/U1: 12 overflows in the weather hour strip (fixed 130 px box) |

Nothing in the core loop failed in any run (plan → save → start → restart → finish → log →
export), on host or native Windows.

### 4.2 Untested behaviour (not failures)

- Everything on Android: install, cold start, permissions, GPS, back button, process death,
  reboot, keep-screen-on, share sheet, file picker, Auto Backup, R8 release build.
- Live services: Open-Meteo, Nominatim, OSM tiles.
- ENG-08 / RT-04 Save/Start racing an edit: reproduced **only with injected timing**.
- ENG-12 first-run seeding time on a slow phone (885 ms on host).
- ENG-14 restore with stale preference ids.
- Drift `LazyDatabase` retry after a failed open.

---

## 5. UX findings

Basis: 05's measurements (not disputed) and 06's reclassification. No user has been observed, so
even "confirmed" means *the mechanism is verified*, not *users were seen failing*.

### 5.1 Confirmed usability problems (mechanism verified)

| ID | Problem | Evidence |
| --- | --- | --- |
| UX-04 | The planner shows no target, night or saved/draft state (wireframe deviation) | `IA_WIREFRAMES.md`; `home_screen.dart` |
| UX-12 | "New session"/"Duplicate" leave the previous unsaved draft unreachable | 04/P4 |
| UX-15(2) | Tonight shows "No window" in error red before a target is chosen | `night_text.dart:68-73`; native render |
| UX-16 | "Tight" renders fainter (grey) than "Fits" (body white) | Flutter `tertiary` fallback; `app_colors.dart` |
| UX-18 / UX-19 | One concept, several names (rig/Equipment; Sessions/Logbook; two "Window" meanings); three duration formats | strings |
| UX-20 | Stale Settings text says optional overheads are not applied (they are); candidates footer mentions a non-existent "Home"; "Notes: Notes: none"; truncated helper | renders; cited lines |
| UX-25 | Results page corrects counts only ±1; the tracker's estimate is not shown there | `results_screen.dart:308-362` |
| UX-31 | Weather strip overflows at 200 % text; a label collides with its value | 05/U1 |

### 5.2 Likely problems (facts true; user impact inferred)

UX-01 (the planner's fit verdict is on its last screen — 5 of 5; Tonight shows it at 0 taps),
UX-03 (repeated night/Moon facts; zone captions partly mandated), UX-08 (24-hour chart axis on a
12-hour device; labels overlap curves), UX-09 (capture-plan card styling inconsistent), UX-10
(Tonight rows open the planner at its top), UX-11 (no night picker on Tonight; wireframe
deviation), UX-13 (after Start a second card offers a Start that will be refused), UX-17 (Moon
wording "from noon–…"), UX-22 (rig editor: duplicate pixel field, unused rotation field),
UX-29 (candidate list ties on long nights).

### 5.3 Subjective preferences (not defects)

UX-33 heading sizes, UX-35 icon-only app-bar actions (tooltips exist), UX-36 card affordance,
UX-37 white snackbar in dark mode, UX-40 top-of-screen toggle, UX-30 filter-bar size (filters are
required by TASK 14.1).

### 5.4 Requires human testing

UX-28 (tracker buttons expose no tap action to accessibility services — engine-level mechanism
verified; TalkBack not run), UX-39 and UX-08 bands (red mode in darkness), UX-07 (rig rows on every
visit), UX-21 (site editor discards on back), UX-22 hint legibility, UX-34 (which button is
primary), UX-38 (swipe-only delete), UX-01/UX-10 impact (time-to-verdict test).

---

## 6. Open decisions (owner only)

1. **Release identity steps:** upload key and `key.properties` (16.2); publish the privacy policy
   with a contact, confirm the URL, file Data Safety (16.3); formal trademark search and the
   `chacha12` account vs the `Buffur` remote (16.1).
2. **0.3 holdovers:** ADK skill, `skills-lock.json`, archive retention, `sqlite3_flutter_libs`.
3. **Resume-prompt Finish** completes without reconciliation, unlike the tracker (RT-10).
4. **Default selection:** should new drafts pre-select M42 and the first rig, and be labelled (ENG-15)?
5. **Seeded rig tracking:** leave "Unknown" (which triggers the NPF warning on the example plan) or declare it (UX-15(1))?
6. **Drafts:** should unsaved drafts be listed or cleaned up (UX-12, TASK 11.3 decision)?
7. **Planner order and integrity text:** may the planner's section order change (ADR-015), and may
   assumptions/√N/heuristic text be one tap away instead of always expanded (UX-02, UX-05, UX-06)?
8. **Wording rulings:** ISO "sensitivity setting" label (SCI-05); resolution caveat for times (SCI-04).
9. **Beta diagnostics:** is a local log export needed for 16.4 (ENG-13)?
10. **Moon/cloud gate UI** has no owning task (TD-050).
11. **Primary 1.0 user:** manual imagers only, or casual beginners too — this decides several UX directions (§10).

---

## 7. Evidence gaps

### 7.1 Needs real device testing (the owner's manual checklist)

- Install debug and signed release builds; cold start; first run offline (L1).
- Location permission: grant, deny, deny forever, settings deep link (L2).
- Force-stop / "Don't keep activities" while planning; process kill mid-run; reboot (L3, L4).
- Keep the app in the background > 3 h, resume: does the forecast still say "Updated just now"? (ENG-01)
- Cross mean solar noon with the app open: does the forecast reload?
- Red mode in real darkness: chart bands, button outlines, secondary text (TEST_PLAN:739).
- TalkBack: can +1, Pause, More → Finish be activated on the tracker? (UX-28)
- Candidates < 1 s on a mid-range phone (10.4); first-run seeding time (ENG-12); profile traces (15.2).
- America/Los_Angeles at 18:30 shows tonight (2.4).
- Share sheet, backup file picker, restore round trip after reinstall (14.4).
- E2E on an emulator (15.5).

### 7.2 Needs user testing

Whether the planner's length and order slow real users (UX-01/02/10); whether novices can create a
rig and site; whether "Tight", warnings and the NPF note are understood; whether Library-as-picker
surprises users; whether keep-screen-on is found.

### 7.3 Needs real astrophotography sessions

M3 dogfooding go/no-go; whether per-frame and optional overhead defaults match reality; whether the
estimate/Accept flow matches actual frame counts; whether the dew heuristic margin is useful.

### 7.4 Needs additional data

Android background-process lifetime (ENG-01 frequency); draft and weather-cache growth over a
season (ENG-09/10); logbook scale on a device (ENG-11); live Open-Meteo/Nominatim behaviour.

### 7.5 Needs product decisions

§6.

---

## 8. Deferred / post-1.0 (not incomplete implementation)

TASK 10.5 azimuth and horizon (cut); G17 metadata-assisted logging (v1.1); manifest import;
crash reporting (privacy); notifications and alarms; light-pollution options C/D; moving objects;
equipment composition UI; optional `@DataClassName` renames; seeing/transparency forecasts;
empirical overhead suggestions; multi-target nights; Project entity; iOS; localization and unit
preferences; widgets and Wear OS; place search; theoretical storage payload. TASKs 16.4 and 16.5
are future roadmap work, not gaps.

---

## 9. Dependency / priority map (recommendation)

Basis for each placement: **release** = blocks store submission or violates a stated compliance
rule; **before beta** = misleading output or data loss testers would hit; **post-roadmap** =
consistency/UX that needs verification first; **optional** = no user impact.

| Issue | Placement | Basis |
| --- | --- | --- |
| Upload key, signed AAB, policy URL + contact, Data Safety (16.2/16.3) | **Blocks release** | Store requirements |
| Any Android install/run (§7.1 core rows) | **Blocks release** | No device evidence at all |
| ENG-03 missing user agent | **Before release** | Written compliance rule (trap 22) |
| CI never run (1.3) | Before beta | Gate only runs locally |
| ENG-01 forecast freshness | **Before beta** | Misleading data; ADR-012 §6 |
| ENG-02 seed never retried | Before beta | Permanent silent data loss (rare) |
| UX-28 tracker accessibility | Before beta, after TalkBack confirms | Could block screen-reader users entirely |
| UX-31 200 % overflow | Before beta | Accessibility regression vs 15.3 |
| UX-20 visible defects (f/5.555…, stale Settings text, "Home") | Before beta | Visible, trust-eroding, trivial |
| UX-16 fit colours; UX-15(2) "No window" red | Before beta | Primary status wording/colour |
| UX-12 unreachable drafts | Before beta, after owner decision | Perceived data loss |
| SCI-02, SCI-06, SCI-10 + doc drift | Post-roadmap refinement | Labelling/docs |
| RT-03 reset path (3.2) | Post-roadmap | Downgrade-only trigger |
| UX-25 reconciliation ±1 | Post-roadmap (verify with real sessions) | Efficiency |
| UX-01…UX-11, UX-13, UX-17–19, UX-22, UX-29 | Post-roadmap refinement, after user testing | Impact unobserved |
| ENG-05, ENG-06, ENG-04, UX-32 | Optional / with nearby work | Transient or test-only |
| Preferences (§5.3) | Optional | No evidence of impact |

---

## 10. Product refinement candidates (directions, not solutions)

All are hypotheses to test after §7; none is chosen. Pattern references (P0–P10, R1–R13) are in 05 §7–§8.

| Problem statement (fact) | Possible directions |
| --- | --- |
| The planner's answer (fit) is on its last screen; sections follow data type, not decisions (UX-01/02) | A status summary at the top; re-order by decision flow (needs ADR-015 change); collapsible sections with factual summaries |
| Facts repeat across cards (UX-03) | Merge the sky card into the opportunity card; show zone captions once per card group; show the zone only when it differs from the device's |
| Tonight's rows open the planner at its top; no night picker (UX-10/11) | Deep-link to the section; dedicated detail screens; a night picker on Tonight as wireframed |
| Default state raises warnings and shows unchosen choices (UX-15, UX-24) | Declare the seed's tracking; label defaults as examples; neutral styling for "missing input" states |
| Status colours and wording inconsistent (UX-16–19) | A shared vocabulary and format layer; explicit status tokens |
| Drafts become unreachable (UX-12) | List drafts; confirm before replacing; auto-clean old drafts |
| After Start, a second actionable card appears (UX-13) | Hide or relabel Start on the copy while a run is in progress |
| Reconciliation needs one tap per frame (UX-25) | Numeric entry; show and accept the estimate on the results page |
| Rig/site setup is heavy for novices (UX-21/22) | Presets or a sourced camera list (policy decision); hide optional fields; nullable elevation |
| Candidate list ties on long nights (UX-29) | Secondary sort (frame fill, max altitude); thresholds; group ties |
| Weather card shows all variables equally (UX-06) | Summary + "all variables"; user-chosen variables (no score, per ADR-012) |
| Density for different users (§6 item 11) | Progressive disclosure first; settings-based density; a separate simple mode only if testing shows a need |
