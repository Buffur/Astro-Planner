# 06 — Counter-audit of audit stages 01–05

> **Audit stage 6 (adversarial verification).** Run on 2026-09-25 against `main` @ `becae04`.
> No application code or source-of-truth document was changed; this file is the only one added.
>
> **Purpose.** Not to find new problems, but to test whether the findings of
> `01_ROADMAP_COMPLIANCE.md`, `02_ENGINEERING_AUDIT.md`, `03_SCIENTIFIC_AUDIT.md`,
> `04_RUNTIME_AUDIT.md` and `05_UI_UX_AUDIT.md` are justified.
>
> **Inputs.** `docs/audit/00_CONTEXT_BASELINE.md` **does not exist** (every stage recorded this).
> The counter-audit therefore rests on audits 01–05, `CLAUDE.md`, `docs/MASTER_ROADMAP.md`,
> `docs/DECISIONS.md`, `docs/SCIENTIFIC_INTEGRITY.md`, `docs/TECH_DEBT.md`, `docs/FEATURE_STATUS.md`,
> `docs/TEST_PLAN.md`, `docs/IA_WIREFRAMES.md` and the code.
>
> **Independence caveat.** Audit 05 was written by the same agent earlier in this session. Its
> findings were given the same scrutiny as the others, and several are downgraded or rejected
> below. Readers should still weigh this section with that in mind.

## 0. Method

**What was re-checked in this stage (all on 2026-09-25):**

| Check | How |
| --- | --- |
| Every cited code fact that a verdict depends on | Read or grepped at the cited location (sections 2–6 list the result) |
| Counter-evidence in the roadmap and decisions | Task scopes (MASTER_ROADMAP §4), ADRs, TECH_DEBT, TEST_PLAN, CLAUDE.md traps |
| One external definition (SCI-02) | Open-Meteo docs re-fetched |
| Git state (01 / TASK 1.3) | `git ls-remote origin`, `git merge-base --is-ancestor 97924a0 origin/main` (exit 1: not on the remote), `git tag` (0 tags) |
| Runtime reproductions | **Not re-run.** The probes of 04 (P1–P5) and 05 (U1, U2) were deleted after their runs; their recorded outputs are relied on. This is a limitation (§D) |

**Verdicts (as requested):**

| Verdict | Meaning here |
| --- | --- |
| **CONFIRMED** | Claim, evidence and severity all hold |
| **PARTIALLY CONFIRMED** | The fact holds, but the framing, severity, scope or a sub-claim does not |
| **REJECTED** | Not a defect: wrong, out of scope, a preference, or impact unevidenced where evidence cuts the other way |
| **REQUIRES VERIFICATION** | Mechanism plausible or shown, but the claimed effect needs device, human or runtime evidence |
| **DOCUMENTED BUT ACCEPTABLE** | Real, but already recorded as a decision, accepted debt or documented simplification |
| **OWNER DECISION** | Only the owner can decide whether it is a defect |

---

## 1. Duplicates: one issue, several IDs

Several findings are the same issue reported by more than one stage. They are judged once, under
the first ID, and should be counted once.

| Issue | IDs | Judged under |
| --- | --- | --- |
| Forecast freshness frozen at load; no reload on clock or resume | ENG-01, SCI-01, RT-01 | ENG-01 |
| Catalog seed failure marked as done | ENG-02, RT-02 | ENG-02 |
| Open-Meteo request without the identifying user agent | ENG-03, RT-07 | ENG-03 |
| Siteless draft uses the UTC date as night key | ENG-05, SCI-11, RT-06 | ENG-05 |
| Save/Start/New outside the autosave chain | ENG-08, RT-04 | ENG-08 |
| Unsaved drafts accumulate and are unreachable | ENG-09, RT-05, UX-12 | ENG-09 / UX-12 |
| Default M42 and first rig not labelled as defaults | ENG-15, SCI-12, UX-24 | ENG-15 |
| Grid-edge bias (5-min grid) | SCI-04, RT-08 | SCI-04 |
| Two "Moon up" definitions | SCI-03, RT-09 | SCI-03 |
| Resume-prompt Finish skips reconciliation | 01 §F-7, RT-10, UX-26 | RT-10 |
| Newer/below-floor database: generic error, no reset | 01 TASK 3.2, RT-03, TD-047 | 01 TASK 3.2 |
| Elevation required but unused | SCI-08, UX-21, F-07 | SCI-08 |
| Library pages select for the current plan | UX-14, TD-053 | UX-14 |
| Duration formats differ | ENG-06, UX-19 (durations row) | ENG-06 |

---

## 2. Audit 01 — roadmap compliance

01 is a status report per task. Its CONFIRMED rows were spot-checked (2.2, 3.3, 4.2, 5.4, 12.3,
13.2) and hold. The table covers every non-CONFIRMED status and every gap claim.

| 01 item | 01 status | Counter-audit | Reason / retained evidence |
| --- | --- | --- | --- |
| 0.3 hygiene holdovers | PARTIAL + OWNER | **OWNER DECISION** | TECH_DEBT lines 239-244 record the held items as owner-approval items; nothing is broken |
| 1.3 CI | UNVERIFIED | **CONFIRMED** | `origin/main` = `a1bcbd9`; `97924a0` is not its ancestor (re-run). The workflow has never executed |
| 2.4, 10.4, 15.5, 16.1 install | UNVERIFIED | **REQUIRES VERIFICATION** | The acceptance texts literally name an emulator/device; host equivalents pass. Correctly classified |
| 3.2 reset UI | PARTIAL | **CONFIRMED** | `resetUnsupportedDatabaseFile` has no caller (only its definition and comments, `app_database.dart:21,56,550`). Same as RT-03/TD-047 |
| 4.4 "SNR absent from lib/" | PARTIAL | **DOCUMENTED BUT ACCEPTABLE** (acceptance) · **CONFIRMED** (doc error) | The 4 occurrences are comments that *negate* SNR (re-grepped); the user-facing intent is met. But DECISIONS DEV-P2 (line 223) says the string no longer appears — that statement is false and should be corrected |
| 6.2 sourced tests for CALC-01–06 | PARTIAL | **PARTIALLY CONFIRMED** | True that `astronomical_engine_test.dart` cites no source. But the values (J2000 JD 2451545.0; GMST 280.4606°) are canonical published constants, not implementation-derived; "hand-written values" overstates it. Gap = missing citations only |
| 12.5, 15.3, 15.4, 15.2 manual checks | PARTIAL | **CONFIRMED** | TEST_PLAN lines 753, 902, 924-929, 883 say "not yet done" / "Not run" |
| 16.2 signed AAB; 16.3 policy | PARTIAL + OWNER | **OWNER DECISION** | `key.properties` absent (existence only); `docs/privacy/index.md:62` still `<CONTACT EMAIL>` (re-checked) |
| M3 dogfooding / go-no-go | PARTIAL | **CONFIRMED** | No record in `docs/` outside the audits (re-grepped) |
| No milestone tags; no AC records | gap | **CONFIRMED** (process) | `git tag` = 0; no AC review record outside MASTER_ROADMAP/audits. Process gap, not a product defect |
| AC5 preferences exception | PARTIAL | **DOCUMENTED BUT ACCEPTABLE** | Owner decision in TASK 11.4 |
| AC7 not evidenced | UNVERIFIED | **CONFIRMED** (absence of record) | No dependency-licence or perf-budget record exists; not evidence of a defect |
| G5 property tests absent | PARTIAL | **PARTIALLY CONFIRMED** | No property-style test found (re-grepped); E1–E7 exact vectors exist. A test-depth gap, low risk |
| TD-050 gate UI unowned | cross-task gap | **CONFIRMED** | Settings has no Moon/cloud gate controls (`settings_screen.dart`); IA_WIREFRAMES lists "Imaging gates: Moon, cloud (TD-050)" |
| Stale docs: F-49/ROADMAP "no remote", TEST_PLAN L3 old app id | evidence gap | **CONFIRMED** | `FEATURE_STATUS.md:641`, `ROADMAP.md:194` vs `git remote -v`; `TEST_PLAN.md:926` contains `com.astroplan.astroplan` |

**Overreach in 01:** minimal. Its only framing issue is 6.2 (above). It correctly separated
"not verified on a device" from "broken" and found no BROKEN task.

---

## 3. Audit 02 — engineering

| ID | 02 class / severity | Counter-audit | Reason / retained evidence |
| --- | --- | --- | --- |
| ENG-01 | CONFIRMED · Medium | **CONFIRMED** (mechanism) · frequency **REQUIRES VERIFICATION** | `night_weather_service.dart:89-100` computes `age` once; no lifecycle observer or timer besides the tracker's (`grep` re-run: only `execution_screen.dart:44`). Reproduced by 04/P1. Contradicts ADR-012 §6. Medium is justified *if* Android keeps the process alive for hours — unmeasured |
| ENG-02 | CONFIRMED · Medium impact, low likelihood | **CONFIRMED** | `catalog_seeder.dart:225-236` stores the version after swallowed inserts; `main.dart:77-80` comment claims retry-safety. Reproduced by 04/P2. Severity framing is fair |
| ENG-03 | CONFIRMED · Low | **CONFIRMED** | `open_meteo_weather_repository.dart:59-61` `get(uri)` without headers; `main.dart:70` uses the default client; CLAUDE.md trap 22 is explicit. Whether Open-Meteo *requires* it is not claimed |
| ENG-04 | CONFIRMED · Low | **PARTIALLY CONFIRMED** | Fact holds (25 files, not 24, build the harness without `sessionRepository:`). But the preferences path is a documented test mode (`session_plan_viewmodel.dart:55-57`), and the production path has its own tests (draft-session tests, lifecycle matrix, E2E). A coverage caveat, not a defect |
| ENG-05 | CONFIRMED · Low | **CONFIRMED** (low) | `session_plan_viewmodel.dart:95,149`; violates CLAUDE.md trap 2; self-corrects on the next autosave with a site; Save/Start need a site |
| ENG-06 | CONFIRMED · Low | **CONFIRMED** (low) | `formatBudgetDuration` rounds, `OpportunityText.duration` truncates (re-read). `totalIntegrationTime` is referenced only by a harness getter that no test calls — dead in effect |
| ENG-07 | CONFIRMED · Info | **REJECTED as a defect** | Fact true (`main.dart:132-137`; no reader). But trap 11 forbids *screens calling* repositories, and none do. No impact; an architecture preference. Optional tidy-up |
| ENG-08 | POTENTIAL RISK | **REQUIRES VERIFICATION** | The code does await `_chain` without extending it (`current_session.dart:72-92`, re-read). 04 reproduced it **only with injected timing**. A hypothetical race until a UI path that lands an edit inside Save is shown |
| ENG-09 | POTENTIAL RISK | **PARTIALLY CONFIRMED** | Accumulation and invisibility reproduced (04/P4: 4 stored, 0 listed). The **performance** part ("grow without bound", startup cost) is unevidenced at realistic volumes → rejected as stated. The UX part survives as UX-12 |
| ENG-10 | POTENTIAL RISK | **REJECTED as a current defect** | No eviction is true (store has only get/set). Growth is one small entry per night viewed per rounded site; no size measured, no rule broken. "Could become a problem" without evidence |
| ENG-11 | POTENTIAL RISK | **REJECTED as a current defect** · device timing **REQUIRES VERIFICATION** | The N+1 pattern exists, but 04/P4 measured 200 completed sessions in 198 ms on the host. No evidence of user-visible latency |
| ENG-12 | POTENTIAL RISK | **REQUIRES VERIFICATION** | 164 autocommit inserts before `runApp` (no transaction in `catalog_seeder.dart` or `drift_target_repository.dart`, re-grepped). Host first run 885 ms (04/P2) — plausible on a slow phone, unmeasured |
| ENG-13 | POTENTIAL RISK | **DOCUMENTED BUT ACCEPTABLE** / **OWNER DECISION** | Crash reporting deferred for privacy (ARCHITECTURE B14, TASK 15.1). Whether beta needs log export is an owner call for 16.4 |
| ENG-14 | POTENTIAL RISK | **PARTIALLY CONFIRMED** · outcome **REQUIRES VERIFICATION** | `backup_staging.dart` swaps only database files (re-read). Whether a stale `activeLocationId` lands on a *different* site depends on id reuse; untested. Extends TD-056 |
| ENG-15 | REQUIRES VERIFICATION | **OWNER DECISION** | `session_plan_viewmodel.dart:109-114` picks M42 and the first rig; intent undocumented |
| ENG-16 | POTENTIAL RISK · Info | **DOCUMENTED BUT ACCEPTABLE** | 299 lines is a fact and the gate is deliberate; a planning note, not a defect |
| §2 TD re-verification rows | DOCUMENTED | **DOCUMENTED BUT ACCEPTABLE** | Already in TECH_DEBT |

**Overreach in 02:** ENG-07, ENG-10, ENG-11 and the performance half of ENG-09 are "could
become a problem" items without evidence; ENG-08 is a hypothetical race.

---

## 4. Audit 03 — scientific

| ID | 03 status | Counter-audit | Reason / retained evidence |
| --- | --- | --- | --- |
| SCI-01 | MISLEADING · Medium | = ENG-01 | Duplicate |
| SCI-02 | MISLEADING (UI) / INCORRECT (CALC-32 text) · Low | **CONFIRMED** (low) | Open-Meteo docs (re-fetched): `precipitation_probability` is a *preceding-hour* value; CALC-32 (`SCIENTIFIC_INTEGRITY.md:785`) says values are instantaneous except gusts |
| SCI-03 | UNDER-SPECIFIED · Low | **PARTIALLY CONFIRMED** | Two definitions exist (h₀ vs topocentric > 0°) and 04/P3 measured 5–10 min differences. Each is documented in its own CALC entry; the gap is only that nothing states they differ |
| SCI-04 | UNDER-SPECIFIED · Low | **DOCUMENTED BUT ACCEPTABLE** · caveat wording **OWNER DECISION** | The 5-min grid and its tolerance ([−2, +7] min) are documented and reference-tested; 04/P3 measured values inside the tolerance. The one-directional bias is real but minor |
| SCI-05 | MISLEADING · Low | **PARTIALLY CONFIRMED** / **OWNER DECISION** | Rule 6 exists (`SCIENTIFIC_INTEGRITY.md:806-808`), but the citation to CLAUDE.md is **wrong** (CLAUDE.md only says ISO does not increase photon collection). The label makes no physical claim, and SI-004's TASK 5.6 note records it deliberately |
| SCI-06 | MISLEADING · Low | **CONFIRMED** (low) | `tonight_candidates_screen.dart:239` "fills N % of the frame" vs `capability_text.dart` "% of the frame's short side" |
| SCI-07 | UNDER-SPECIFIED | **DOCUMENTED BUT ACCEPTABLE** | ADR-016 §3 owner decision; 03 itself says not to change it speculatively |
| SCI-08 | UNDER-SPECIFIED · Low | **DOCUMENTED BUT ACCEPTABLE** | FEATURE_STATUS F-07 already records it |
| SCI-09 | UNDER-SPECIFIED · Low | **PARTIALLY CONFIRMED** | Documented simplification (ADR-013 §2, CALC-33); only the UI label lacks "at midnight". Low value |
| SCI-10 | MISLEADING (docs) · Low | **CONFIRMED** (docs) | `optical_calculator.dart:42` ("signal improvement") and `:63` ("not shown in the UI") re-read; SI index vs section statuses differ (`SCIENTIFIC_INTEGRITY.md:89-90` vs `:167`, `:230`); CALC-07 lists `calculateCulminationAltitude`, absent from `lib` |
| SCI-11 | INCORRECT | = ENG-05 | Duplicate |
| SCI-12 | UNDER-SPECIFIED | = ENG-15 | Duplicate |
| SCI-13 | MISLEADING (documented) | **DOCUMENTED BUT ACCEPTABLE** | TD-051 / TD-054 |
| C-01…C-23 (CORRECT) | — | **Not contested** | Spot-checked C-08 (NPF only for untracked/unknown: `capability_calculator.dart:106-126`) and C-18 (seed specs) |

**Overreach in 03:** little. SCI-05's CLAUDE.md citation is inaccurate; SCI-09 and SCI-04 are
labelling points on documented simplifications.

---

## 5. Audit 04 — runtime

| ID | Counter-audit | Reason |
| --- | --- | --- |
| RT-01 | = ENG-01 (**CONFIRMED** mechanism; frequency unverified) | Probe P1 output is specific and consistent with the code |
| RT-02 | = ENG-02 (**CONFIRMED**) | Probe P2 |
| RT-03 | = 01 TASK 3.2 (**CONFIRMED**; Low) | Downgrade-only trigger; data untouched |
| RT-04 | = ENG-08 (**REQUIRES VERIFICATION**) | Injected timing only |
| RT-05 | = ENG-09 / UX-12 | See those |
| RT-06 | = ENG-05 (**CONFIRMED**, low) | |
| RT-07 | = ENG-03 (**CONFIRMED**) | |
| RT-08 | = SCI-04 (**DOCUMENTED BUT ACCEPTABLE**) | Within documented tolerance |
| RT-09 | = SCI-03 (**PARTIALLY CONFIRMED**) | |
| RT-10 | **OWNER DECISION** | ADR-016 §11 names only the tracker's Finish; the prompt's Finish may be intended |

**Overreach in 04:** none material. It labelled RT-04's dependence on injected timing honestly.

---

## 6. Audit 05 — UI/UX

05's measurements (page lengths, marker positions, counts) are not disputed. The question here is
whether its *interpretations* are defects, trade-offs or opinions. Several were over-classified.

| ID | 05 class | Counter-audit | Reason / retained evidence |
| --- | --- | --- | --- |
| UX-01 answer on last screen | CONFIRMED | **PARTIALLY CONFIRMED** | Measurement holds (fit at y 3,601 of 3,995). But Tonight shows the same fit and reason with 0 taps, and the planner order is an ADR-015 decision. Impact on users is inferred, not observed |
| UX-02 order vs dependency | CONFIRMED | **OWNER DECISION** | ADR-015 §2 fixes "same sections and order" |
| UX-03 repetition | CONFIRMED | **PARTIALLY CONFIRMED** | Counts hold. Counter-evidence: "every displayed time names its zone" is a roadmap done-criterion (MASTER_ROADMAP:33, :237; DECISIONS:868), so zone captions are partly mandated. Cross-card duplication of night/Moon facts stands |
| UX-04 no identity/state in planner | CONFIRMED | **CONFIRMED** (roadmap/wireframe deviation) | `IA_WIREFRAMES.md` app bar "M42 · Fri, Nov 13 · Draft"; `home_screen.dart` shows none. Impact claim is heuristic |
| UX-05 explanations expanded | TRADE-OFF | **DOCUMENTED BUT ACCEPTABLE** / **OWNER DECISION** | Integrity rules require the text |
| UX-06 weather card | TRADE-OFF / LIKELY | **OWNER DECISION** | ADR-012 (no score); TASK 9.4 required the ranges |
| UX-07 rig rows every visit | LIKELY | **REQUIRES VERIFICATION** | No evidence of user cost; TASK 8.6 required the capability rows |
| UX-08 chart | mixed | **PARTIALLY CONFIRMED** | 24-hour axis on a 12-hour device and label overlap are shown in native renders (`altitude_chart_widget.dart:273-286`). Band seams: host/Windows only → **REQUIRES VERIFICATION** on Android. Span: trade-off |
| UX-09 capture-plan visuals | CONFIRMED / LIKELY | **PARTIALLY CONFIRMED** | Margin/radius inconsistency and "60.0s" are facts. "Heading inflation" is opinion. Block delete without undo: IA §3 names "delete, abandon" — whether a draft block counts is **OWNER DECISION** |
| UX-10 drill-down lands at top | CONFIRMED | **PARTIALLY CONFIRMED** | Drilling into the planner is the documented design (`tonight_home_screen.dart:28-32`). Landing at the top, not the section, is the fact; friction is inferred |
| UX-11 no night picker on Tonight | CONFIRMED | **PARTIALLY CONFIRMED** (wireframe deviation) | Wireframe shows one; TASK 12.5's scope does not list it. Deviation from design intent, not from acceptance |
| UX-12 replaced draft unreachable | CONFIRMED | **CONFIRMED** (mechanism) / listing drafts **OWNER DECISION** | 04/P4; drafts excluded by owner decision (TASK 11.3). The silent-loss effect conflicts with IA §3 |
| UX-13 duplicate card after Start | CONFIRMED | **PARTIALLY CONFIRMED** | The copy and the refusal are ADR-016 §10 owner decisions; showing an actionable Start that must fail is the only defect-like part |
| UX-14 Library pickers | LIKELY | **DOCUMENTED BUT ACCEPTABLE** | TD-053; matches the wireframe ("Rig list + selection"); ADR-015 §7 |
| UX-15 default false alarms | CONFIRMED | **PARTIALLY CONFIRMED** | (1) NPF warning on the seeded rig: follows PD-11 ("if untracked" when unknown) and the seed's unset tracking (`equipment_profile.dart:71` default `unknown`) → **OWNER DECISION**. (2) "No window" in error red with no target: **CONFIRMED** (native render; `night_text.dart:68-73`). (3) "Current Altitude −27.5°": **REJECTED** — the label says *current* and the value is correct |
| UX-16 Tight weaker than Fits | CONFIRMED | **CONFIRMED** (low) | `tertiary => _tertiary ?? secondary` (Flutter `color_scheme.dart:1139`); `app_colors.dart` |
| UX-17 Moon wording | CONFIRMED | **PARTIALLY CONFIRMED** | The text is accurate; readability is the claim. Low |
| UX-18 terminology | CONFIRMED | **CONFIRMED** (low) | Strings re-grepped (rig/Equipment, Sessions/Logbook, two "Window" meanings in the detail) |
| UX-19 formats | CONFIRMED | **CONFIRMED** (low) | Durations = ENG-06; the others are facts |
| UX-20 content defects | CONFIRMED | **CONFIRMED** | `session_detail_screen.dart:235-237` prints the raw double; `settings_screen.dart:189-193` stale vs `capture_budget_calculator.dart:287-336`; candidates footer "Home"; "Notes: Notes: none" |
| UX-21 elevation / discard | CONFIRMED / LIKELY | = SCI-08 (**DOCUMENTED BUT ACCEPTABLE**); discard **REQUIRES VERIFICATION** | No `PopScope` in the site editor is a fact; user impact unobserved |
| UX-22 rig editor | LIKELY / TRADE-OFF | **PARTIALLY CONFIRMED** | Two fields on one controller and the unused rotation field are facts. Hint brightness and "steepest step" are opinions → **REQUIRES VERIFICATION**. Verified-seed policy (TASK 8.5) is a decision |
| UX-23 typing | TRADE-OFF | **DOCUMENTED BUT ACCEPTABLE** | Planning is not the field tracker |
| UX-24 first-run prefill | CONFIRMED | = ENG-15 (**OWNER DECISION**) | Duplicate |
| UX-25 reconciliation ±1 | CONFIRMED | **CONFIRMED** (low–medium) | `results_screen.dart:308-362` offers only ±1; the estimate is not shown there. Mitigation exists (Accept N in the tracker) |
| UX-26 resume prompt | CONFIRMED | = RT-10 (**OWNER DECISION**) | |
| UX-27 tracker gaps | LIKELY / REQUIRES USER TESTING | **REJECTED** ("window opens in") · keep-screen-on **DOCUMENTED BUT ACCEPTABLE** | TASK 13.3's scope lists exactly the countdowns implemented (MASTER_ROADMAP:1102). A new countdown is new scope. Opt-in keep-screen-on is ADR-016 §6 (owner) |
| UX-28 tracker semantics | LIKELY | **REQUIRES VERIFICATION** (high-confidence mechanism) | `execution_screen.dart:333-336` `Semantics(button: true, excludeSemantics: true)` without `onTap`; engine `BaseRoleConfigurator.java:103-114` marks a node clickable only with a tap action. TalkBack not run |
| UX-29 candidate ties | CONFIRMED | **PARTIALLY CONFIRMED** / **OWNER DECISION** | Ties were seen on one November night; ranking by usable minutes without a score is MASTER_ROADMAP §3.2's decision, and other sorts exist |
| UX-30 Sessions filter bar | CONFIRMED | **DOCUMENTED BUT ACCEPTABLE** | TASK 14.1 scope requires these filters (MASTER_ROADMAP:1134). Bar size is a preference |
| UX-31 200 % overflow | CONFIRMED | **CONFIRMED** | 12 overflows logged in 05's U1 run; `weather_forecast_widget.dart:404-445` fixed 130 px; breaks CLAUDE.md trap 17 |
| UX-32 a11y sweep blind spot | CONFIRMED | **CONFIRMED** | `accessibility_test.dart:33,87` fake returns no forecast |
| UX-33 heading inflation | CONFIRMED | **REJECTED** (preference) | Sizes are facts; the judgement is aesthetic |
| UX-34 button hierarchy | REQUIRES USER TESTING / LIKELY | **REQUIRES VERIFICATION** | |
| UX-35 icon-only actions | LIKELY | **REJECTED** (preference) | Both have tooltips; misreading "+" is speculation |
| UX-36 card affordance | LIKELY | **REJECTED** (preference) | No evidence users miss it |
| UX-37 white snackbar | LIKELY | **REJECTED** (preference) | Field mode (red snackbar) is the product's night mode |
| UX-38 swipe-only delete | REQUIRES USER TESTING | **REQUIRES VERIFICATION** | |
| UX-39 red mode outlines/bands | TRADE-OFF / REQUIRES USER TESTING | **DOCUMENTED BUT ACCEPTABLE** + darkness test **REQUIRES VERIFICATION** | ARCHITECTURE B16; TEST_PLAN:739 owner checklist |
| UX-40 top-of-screen toggle | PREFERENCE | **REJECTED** (preference) | |

**Overreach in 05:** it classified several heuristic judgements as CONFIRMED UX PROBLEMS without
user evidence (UX-01, UX-10, UX-13), missed roadmap context in three places (UX-27 scope, UX-30
scope, UX-03 zone rule), duplicated documented items (UX-14, UX-21, UX-24), and kept five
preferences in the findings list (UX-33, UX-35, UX-36, UX-37, UX-40). Its central conclusion —
that density is concentrated in the planner rather than app-wide — is supported by its
measurements, but "problem" there remains an expert judgement, not an observed user failure.

---

## A. Findings that survive scrutiny

Counted once per issue (duplicates in §1).

| Finding | Severity (as justified) | Retained evidence |
| --- | --- | --- |
| ENG-01 forecast freshness frozen (SCI-01, RT-01) | Medium mechanism; frequency unverified | `night_weather_service.dart:89-100`; no lifecycle hook; 04/P1 |
| ENG-02 failed seed marked done (RT-02) | Medium impact, low likelihood | `catalog_seeder.dart:225-236`; 04/P2 |
| ENG-03 Open-Meteo without user agent (RT-07) | Low | `open_meteo_weather_repository.dart:59-61`; trap 22 |
| ENG-05 siteless draft UTC key (SCI-11, RT-06) | Low | `session_plan_viewmodel.dart:95,149` |
| ENG-06 / UX-19 duration formats; dead getter | Low | `capture_budget_summary.dart:13-16` vs `opportunity_text.dart:9-14` |
| 01 TASK 3.2 / RT-03 no reset path | Low | no caller of `resetUnsupportedDatabaseFile` |
| 01 TASK 1.3 CI never ran | Process | git ancestry check |
| 01 manual checks outstanding (12.5, 15.2–15.4) | Process | TEST_PLAN "not yet done" rows |
| 01 TD-050 gate UI unowned | Low | `settings_screen.dart` |
| Stale docs: DEV-P2 "SNR", F-49/ROADMAP "no remote", TEST_PLAN L3 id, SCI-10 doc drift | Low (docs) | cited lines |
| SCI-02 precipitation time support | Low | Open-Meteo docs; CALC-32 |
| SCI-06 candidates "fills % of the frame" | Low | `tonight_candidates_screen.dart:239` |
| UX-04 planner shows no identity/state (wireframe deviation) | Low | `IA_WIREFRAMES.md`; `home_screen.dart` |
| UX-12 replaced draft unreachable (UX view of RT-05) | Low–medium | 04/P4; `library_viewmodels.dart:141-153` |
| UX-15(2) "No window" in error colour before a target is chosen | Low | `night_text.dart:68-73`; native render |
| UX-16 "Tight" weaker than "Fits" | Low | `color_scheme.dart:1139`; `app_colors.dart` |
| UX-18 terminology; UX-20 visible content defects | Low | strings; `session_detail_screen.dart:235-237`; `settings_screen.dart:189-193` |
| UX-25 reconciliation ±1 only | Low–medium | `results_screen.dart:308-362` |
| UX-31 200 % overflow; UX-32 sweep blind spot | Low–medium (accessibility) | 05 U1 log; `accessibility_test.dart:33,87` |

Partially confirmed (fact holds, framing reduced): 01-6.2, 01-G5 property tests, ENG-04, ENG-09
(invisibility only), ENG-14, SCI-03, SCI-05, SCI-09, UX-01, UX-03, UX-08, UX-09, UX-10, UX-11,
UX-13, UX-17, UX-22, UX-29.

## B. Findings that should be rejected

| Finding | Why rejected |
| --- | --- |
| ENG-07 unused repository providers | No reader, no rule broken (trap 11 concerns screens calling repositories); architecture preference |
| ENG-09 performance half ("grows without bound", startup cost) | No evidence at realistic volumes |
| ENG-10 weather cache never evicted | Small per-entry growth, no measurement, no rule broken — "could become a problem" |
| ENG-11 N+1 queries (as a defect) | Host measurement 198 ms for 200 sessions (04/P4) contradicts the implied latency; device check optional |
| UX-15(3) "Current Altitude −27.5°" | Label says *current*; value correct |
| UX-27 "window opens in" missing | Outside TASK 13.3's approved scope (countdowns listed exactly) |
| UX-33, UX-35, UX-36, UX-37, UX-40 | Preferences presented as findings; no task obstructed and no evidence |

## C. Findings that need human or runtime verification

| Finding | What would decide it |
| --- | --- |
| ENG-01 frequency | Device: background > 3 h, resume; cross mean solar noon with the app open |
| ENG-08 / RT-04 | A UI-driven test landing an edit inside Save/Start, or a device observation |
| ENG-12 | Time to first frame on a clean install, low-end phone |
| ENG-14 outcome | Restore a backup with different site ids and restart |
| UX-28 tracker semantics | TalkBack walkthrough (TASK 15.3's outstanding row) |
| UX-08 band seams; UX-39 red mode | Android render; darkness checklist (TEST_PLAN:739) |
| UX-07, UX-21 discard, UX-22 hint legibility, UX-34, UX-38 | Short usability sessions |
| UX-01 / UX-10 impact | A first-click / time-to-verdict test on the planner |
| 01: 2.4, 10.4, 15.5, 16.1 | The emulator/device runs their acceptance names |

Owner decisions: 0.3 holdovers; 16.2/16.3 steps; ENG-13 (beta log export); ENG-15/UX-24 (default
selection); RT-10/UX-26 (prompt Finish); SCI-04 caveat; SCI-05 label; UX-02 (planner order);
UX-05/UX-06 (always-on integrity text, weather detail); UX-12 (list drafts?); UX-15(1) (seed
tracking); UX-29 (secondary ordering without a score); UX-09 (does block delete need confirm/undo).

## D. Material uncertainties

1. **No runtime reproduction in this stage.** The 04 and 05 probes were deleted after their runs;
   this counter-audit relies on their recorded outputs (consistent with the code, but not re-run).
2. **Independence.** Audit 05 and this counter-audit share an author; 05's verdicts may still be
   judged too leniently despite the downgrades above.
3. **No Android, device or human evidence exists for any stage.** Every severity that depends on
   process lifetime, device performance, TalkBack or darkness is provisional.
4. **Owner intent is undocumented** for the default selection (M42, first rig), the resume-prompt
   Finish, and whether drafts should be reachable; these decide several verdicts.
5. **Drift `LazyDatabase` after a failed open** (02 §2, TD-047) remains unknown and decides whether
   the Retry loop can ever succeed.
6. **Live third-party behaviour** (Open-Meteo, Nominatim, OSM) is fixture-tested only.
7. **`00_CONTEXT_BASELINE.md` has never existed**, so no stage could be checked against the
   baseline the briefs assumed.
