# RG-04 — Execution's role and how results are recorded

> **Task:** S4.R2 (Stage 4; `POST_ROADMAP_PLAN.md`, "S4.R2"). **Gate:** RG-04.
> **Kind:** research and decision preparation, documentation only. No application code, test or
> dependency changed.
> **Baseline:** `main` @ `e5fd240`; application code identical to `92ebf2a`. File and line
> references are at that code.
> **Inputs:** S4.R1 (`research/S4.R1_FLOW_INVENTORY.md`, including the owner's answers O1–O4 in
> §6.1); ADR-014; ADR-016; CALC-35 to CALC-38; 08 §3, §19, §24; 05 UX-25 to UX-28; 04 RT-10;
> MASTER_ROADMAP §3.2–3.3, G13, G14, TASK 17.3; `PRODUCT_DIRECTION.md` §3–§4.
> **Process note:** run in the same chat as S4.R1, at the owner's request, not in a fresh one.
> **Status:** the owner's decision is pending (§10). Nothing here is approved until it is recorded
> in DECISIONS E.1.

## Contents

1. The question
2. Evidence, kept apart: current behaviour, roadmap intent, the owner's report, the audits
3. What the Execution flow provides today
4. Constraints every option must keep
5. Unknowns
6. How much to record after a session (G1–G3)
7. Execution's role (A–D)
8. Trade-offs side by side
9. Recommended direction
10. Owner decisions
11. What Stage 8 would implement (sketch, not frozen)

---

## 1. The question

**What role should Execution play after a plan is made, and how much should the user record
after the session?** The aim is to keep the planned-vs-actual value without asking the user to
operate the app while imaging (the owner's O1 and O4).

The question has two parts, decided separately in §10:
- **G: what is recorded after the session.** This part is needed whatever happens to the tracker.
- **A–D: whether a live tracker exists, and where Start lives.**

## 2. Evidence, kept apart

### 2.1 Current behaviour (CODE VERIFIED at the baseline)

**Start.**
- Start is a primary button in two places: Tonight's session card (`tonight_home_screen.dart:391–400`)
  and the planner's bottom bar, beside Save (`home_screen.dart:355–362`).
- It needs a site, a target and a rig, and it does not need a prior Save.
- It takes the execution-start snapshot and opens the tracker.
- The planner then continues on a new draft copy (`current_session.dart:140–148`).
- Only one session may be in progress; a second Start is refused (`start_session.dart:29–43`).
- Nothing checks whether the night has already passed.

**The tracker** (`/session/:id/run`):
- controls: −1, +1, Reject, Accept N (the estimate), Pause with a reason (clouds, wind, dew,
  equipment, other) or Resume, Block, and More (`execution_screen.dart:366–420`);
- countdowns (CALC-36): dawn, the target dropping below its limit, moonrise, window left, plan
  left;
- keep-screen-on, opt-in (`:492`).

State is a fold over the persisted events (ADR-016). A process death shows the resume prompt on
Tonight (`resume_run_dialog.dart:82–144`), whose Finish completes at once (RT-10, UX-26).

**Finish** opens Results (`execution_screen.dart:505–515`). Results offers:
- per-block confirmed and rejected counts, ±1 only (`results_screen.dart:333–341`; UX-25);
- notes on conditions and processing, and optional temperature, humidity and cloud cover;
- "Complete session", or "Abandon session" (`:238–254`).

**After completion.**
- Counts can still be corrected, each correction a timestamped event (ADR-016 §11).
- The session detail shows the plan against the actual per block, and the light integration
  (CALC-37) (`session_detail_screen.dart:284–312`), plus its notes (`:326–346`).
- The Library's Progress sums confirmed light integration per target and filter over completed
  sessions (CALC-38; abandoned ones are excluded).

**What cannot be done today.**
- **There is no result without Start.**
  - ADR-014 §3 allows planned → completed only through inProgress.
  - The repository accepts count events only for a started run, or as corrections after Finish
    (`drift_session_repository.dart:156–167`; ADR-016 §9, §11).
  - The UI offers no way to mark a planned session "not done": the repository can abandon a
    draft or planned session (`:147–153`, no event), but no screen calls it for a never-started
    session.
  - S4.R1 §4 row 11: logging a saved plan after the night takes 6 taps plus 1 per frame, and the
    run is stamped with the time of logging.
- **A saved plan left from last night** reopens in the planner the next day as the current plan,
  with its night rolled forward to tonight (`session_plan_viewmodel.dart:118–133`; TASK 11.4).
  Nothing asks how it went.

**Where history reads from.** The session detail reads the execution-start snapshot, else the
plan snapshot (`session_detail_screen.dart:154–155`). So a session completed without a Start would
still show its full context from the plan snapshot.

**What the export carries.** The v2 manifest includes status, lifecycle instants, per-block
confirmed and rejected counts, results, both snapshots and the event list (`EXPORT_MANIFEST.md`).

### 2.2 Roadmap and ADR intent (historical, authoritative for what was built)

- **MASTER_ROADMAP §3.2:** "Plan → Execute → Log … The main bet. It must cost only a few taps per
  block."
  - The differentiation named there is a planned-vs-actual record, compared with Astro PM's
    planned, acquired and accepted counts.
  - Risk **R6** is "Execution friction (users won't tap in the dark)". Its mitigations: estimates
    from timestamps, a one-thumb UI, and metadata assistance in v1.1 (TASK 17.3: counts proposed
    from a batch of frames).
- **G13's goal:** "low-friction tracking of a running session without hardware control".
  **G14's goal:** "a planned-vs-actual record, per-target accumulation, export and backup".
- **ADR-016:** estimates are never written without the user; one run at a time; foreground only;
  no auto-finish.
- **Superseded as direction** (`PRODUCT_DIRECTION.md` §9): "Plan → Execute → Log is the main bet".
  Planning comes first. Execution is a supporting workflow whose role Stage 4 decides; until then
  it stays as built (§4).

### 2.3 The owner's evidence (08, and O1–O4 on 2026-09-27)

- **08 §3:** the owner sees little value in a separate execution page with +1, −1, Reject and Pause,
  because in a real session the user will not keep reporting. Proposed: plan, image, then mark the
  result in the Logbook as Completed or Not completed. The Logbook is a history, not a live report.
- **08 §19:** asks whether Progress duplicates Start.
- **08 §24:** opening a Logbook entry shows the tracker page again, which "is not particularly
  successful".
- **O1:** product feedback that questions whether Start → Tracker → Results should exist at all.
  It is not an instruction to delete.
- **O4:** only Completed / Not completed was proposed. Detailed actuals are options to evaluate,
  not requirements.
- **Evidence level:** one experienced user's dogfooding (HO/IN in Appendix A's key). Nobody else
  has been observed (05 §10).

### 2.4 Audit evidence

- **UX-25:** reconciling is ±1 per frame; a five-hour run of 60 s subs is 300 frames.
- **UX-26 / RT-10:** the resume prompt's Finish completes, while the tracker's opens Results.
- **UX-27:** the tracker gaps; the counter-audit (06) rejected "window opens in" as new scope.
- **UX-28:** the tracker's accessibility actions, fixed by S1.11; TalkBack is not yet run.
- **UX-13:** after Start, a second card offers a Start that will fail.
- **05 §0:** the tracker is "not a density problem"; its issues are specific.
- None of the audits observed a user at the telescope.

## 3. What the Execution flow provides today

Each capability, whether it needs a live run, and where else it could live. "Live" means it only
makes sense while imaging.

| # | Capability | Where today | Needs a live run? | Could live instead |
| --- | --- | --- | --- | --- |
| C1 | Freezing the plan that was actually used (execution-start snapshot) | Start | No | The plan snapshot taken at Save (already the fallback in history) |
| C2 | When imaging really started and ended (event instants) | Start, Finish | Yes, for accuracy | A time entered, or accepted, after the session; or unknown |
| C3 | Frame counting: +1, −1, Reject | Tracker | Yes | Numbers entered after the session (per block) |
| C4 | The frame estimate and Accept N (CALC-35) | Tracker | Yes | — (no post-session equivalent; only file metadata could count frames later, TASK 17.3) |
| C5 | Interruptions with a reason (clouds, wind, dew, equipment) | Tracker (Pause) | Yes, as it happens | A "what interrupted it" choice after the session |
| C6 | Countdowns at the telescope: dawn, target below its limit, moonrise, window and plan left (CALC-36) | Tracker | Yes | Tonight or the planner already show the night's times and windows as a timeline, not as countdowns |
| C7 | Keep the screen on | Tracker | Yes | — |
| C8 | Resume after a process death; one run at a time | Tonight, the repository | Only while live runs exist | — |
| C9 | Results: per-block counts, rejected frames, notes, temperature, humidity, cloud cover | Results (after Finish) | No | A result form on the Logbook entry |
| C10 | Planned vs actual (CALC-37) | Results, Sessions, detail | No, but it needs counts | Unchanged, from post-session counts |
| C11 | Progress per target and filter (CALC-38) | Library → Progress, detail | No, but it needs counts | Unchanged, from post-session counts |
| C12 | An auditable history of counts (events, exported) | Events | No | A single "result recorded" event per block, or per session |

**Reading:** everything the owner values after the session (C9–C11) depends on counts, not on
the tracker. The tracker's unique value is live (C3–C8), and that is exactly what the owner
questions.

## 4. Constraints every option must keep

- **No data loss.** Existing sessions, events, counts, snapshots and results stay readable and
  exportable. A session in progress at the upgrade can still be completed or abandoned.
- **Run state comes only from events** (trap 14), and the counters equal the replayed events. A
  post-session result that sets counts must do so through events (for example one "result recorded"
  event per block). Otherwise ADR-016 and the counters' invariant must be amended explicitly.
- **Snapshots stay immutable** (ADR-014 §4). Completing freezes the plan (ADR-014 §3).
- **Unknown stays unknown** (SI-008). A result with no counts has **unknown** actual integration,
  never zero and never "as planned" unless the user says so.
- **Honesty of reported values.** Counts are what the user reports (CALC-37 already says "not
  verified against files"). A one-tap "as planned" is also the user's report and must be labelled
  as one (see RD-13).
- **Export:** an incompatible manifest change bumps `manifest_version` (`EXPORT_MANIFEST.md`).
- **No notifications or background work** (ADR-016 §6); nothing leaves the device.
- **Stage 4 writes no code.** Stage 8 implements, with the core-loop end-to-end test updated
  (trap 19).

## 5. Unknowns

- **U1.** How often users (beyond the owner) want live countdowns or keep-screen-on at the
  telescope. There is no evidence either way; S4.E's darkness test (Test C) touches it only
  lightly.
- **U2.** How reliably users will return after the night to record a result. A quiet reminder
  (§10, D4) is the only lever without notifications.
- **U3.** Whether "Completed, as planned" will be tapped for nights that went partly. It is a
  wording risk, mitigated by a separate "Partly" choice.
- **U4.** When metadata-assisted counting (TASK 17.3) will exist. It depends on batch reading, which
  Stage 2 did not build. Today only one file at a time is read.

## 6. How much to record after a session (G1–G3)

This part applies to every option in §7.

| | G1 — outcome only | G2 — outcome, with numbers only when needed | G3 — full results (today's page) |
| --- | --- | --- | --- |
| **What the user enters** | Completed or Not completed; optional note | **Completed as planned** (one tap); **Partly** (numbers per light block, pre-filled with the plan and editable, entered as numbers, not ±1); **Not done** (optional reason). Optional notes, and optionally temperature, humidity, cloud | Per-block confirmed and rejected counts, notes, conditions, then Complete |
| **Taps for a normal night** | 2 (open the entry, Completed) | 2 (as planned); partly: 2 + a number per block | 3+ and one tap per frame today (UX-25) |
| **Planned vs actual (CALC-37)** | Status only; actual integration **unknown** | Actual = planned (reported "as planned"), or the entered numbers | Full, including rejected frames |
| **Progress per target (CALC-38)** | **Nothing to sum**: shows only sessions and nights, integration unknown | Works: as planned, or the entered numbers | Works |
| **Owner's stated minimum (O4)** | Exactly it | It, plus one optional step for partial nights | More than asked |
| **Honesty** | Clean: nothing is claimed | "As planned" is the user's statement and must be labelled so (e.g. "reported as planned") | User-confirmed counts |
| **Data change** | A result on a never-started session: planned → completed or abandoned without a run (ADR-014 §3 amendment) | The same, plus counts set after the session through events (ADR-016 amendment) | None new |

**Rejected frames** are kept for G3 only. In G2 the entered number means frames kept.

## 7. Execution's role (A–D)

Every option keeps C9–C12 on the Logbook entry. They differ in what happens during the night.

### A — As built
- **The night:** Start, then the tracker (+1, Accept N, Pause), then Finish, then Results, then
  Complete.
- **Start:** a primary button on Tonight and in the planner.
- **Stage 8 would fix:** UX-25 (number entry, show the estimate), UX-26/RD-12, UX-13 and TD-063.
- **Against the owner's evidence:** the app stays an at-the-telescope tool, and results still need
  Start (§2.1).

### B — Logbook first; the tracker optional
- **The night:** Save the plan, image, then open the entry in the Logbook (or a reminder on
  Tonight) and **record the result** (G).
- **Start:** leaves the primary path. It stays as "Track live (optional)" on the saved session's
  detail, and perhaps in the planner's overflow. Tonight and the planner lead with the plan, not
  Start.
- **The tracker:** kept for those who want countdowns, keep-screen-on or live counting. Its Finish
  leads to the same result form.
- **Data:** a never-started session can be completed or marked not done (ADR-014 §3 amendment).
  Post-session counts are written through events (ADR-016 amendment). Live runs work as today.
- **Removes from the main flow:** UX-13's duplicate Start card, the post-Start copy in normal use,
  and the resume prompt for most users.
- **Keeps:** everything in §3.

### C — Logbook only; the live tracker retired
- **The night:** as B. There is no live mode.
- **Start, the tracker, the resume prompt and keep-screen-on** leave the UI. A sub-choice:
  - **C-hidden:** behind a `FeatureScope` gate, with the code kept. Reversible, but carries dormant
    code.
  - **C-removed:** the UI code is deleted in Stage 8. Past data stays readable.
- **Existing sessions:** an in-progress session at the upgrade gets the result form, which
  completes or abandons it. Past events stay readable and exported.
- **Loses:** C3–C8 (live counting, the estimate, live interruption logging, countdowns,
  keep-screen-on, resume). CALC-35 and CALC-36 become unused (marked retired in the register,
  not deleted from history).
- **Simplifies:** one-run-at-a-time, the copy after Start, RD-12, the TD-063 path and UX-13 all go
  away for new sessions.

### D — A simplified tracker
- **The night:** "Begin" and "End" only (timestamps; optionally the countdowns and keep-screen-on).
  The result is recorded afterwards (G).
- **Removes:** +1, −1, Reject and Accept N. Pause stays only if interruptions stay live.
- **Keeps:** the real start and end times (C2) and the countdowns (C6).
- **Costs:** a new, reduced tracker design, and it still asks the user to touch the app at the
  start and end of the night.

## 8. Trade-offs side by side

| | A — as built | **B — Logbook first, tracker optional** | C — Logbook only | D — simplified tracker |
| --- | --- | --- | --- | --- |
| Matches the owner's flow (O1) | No | **Yes, by default** | Yes | Partly (Begin and End) |
| Live burden during imaging | High | **None unless chosen** | None | Low |
| Keeps valid existing functionality | All | **All (the tracker becomes secondary)** | Loses C3–C8 | Loses C3–C5 |
| Planned vs actual, Progress | Yes | **Yes (with G2 or G3)** | Yes (with G2 or G3) | Yes (with G2 or G3) |
| UI and state complexity | Highest (two paths to results, copy after Start, resume) | Medium (one main path; the live path kept) | **Lowest** | Medium |
| Data change | None | ADR-014 §3 and ADR-016 amendments (results without a run) | The same, plus retiring the live UI | The same, plus a new tracker model |
| Reversibility | — | **High**: it can later become C if the tracker goes unused | C-hidden high, C-removed low | Medium |
| Stage 8 size (estimate) | M (fix UX-25, RD-12, UX-13) | M–L | M | L (a new tracker) |
| Unknown U1 (live value) | Assumed high | **Left open safely** | Assumed low | Assumed partly |

## 9. Recommended direction

**B (Logbook first; the tracker optional) with G2 (outcome, with numbers only when needed).**

- **It makes the owner's flow the default:** Plan → Save → image → Logbook → record. It needs no
  interaction while imaging (O1), and a normal night costs about two taps afterwards (O4's
  minimum, plus "as planned").
- **It keeps the planned-vs-actual value** (CALC-37) **and Progress** (CALC-38). The alternative,
  G1, leaves both without data, because "Completed" alone does not say how much was captured, and
  "unknown stays unknown" forbids assuming it.
- **It removes nothing that works.** The tracker moves out of the main path instead of being
  deleted (`CLAUDE.md`, "Do not remove valid existing domain … functionality merely because its
  current presentation is complex"). U1 is unknown, so retiring the live mode now would be a guess.
- **It stays reversible.** If the tracker proves unused, it can later become C-hidden or C-removed
  at little cost. Going from C back to B means rebuilding.
- **What it does not solve:** B keeps the live path's complexity in the code (the one-run rule,
  resume, the copy after Start). **If the owner values simplicity over keeping the live mode, C
  (C-hidden) is the strong alternative;** it loses C3–C8 and keeps the data.

## 10. Owner decisions

- **D1 — Execution's role:** A, **B (recommended)**, C (C-hidden or C-removed), or D.
- **D2 — What is recorded after a session:** G1, **G2 (recommended)**, or G3. Under G2, whether the
  optional conditions (temperature, humidity, cloud) stay.
- **D3 — What "Not completed" means.** Recommended:
  - **"Not done"** maps to the existing `abandoned` status, with an optional reason (clouds, wind,
    dew, equipment, other), which reuses the interruption vocabulary;
  - **"Partly"** is completed with the numbers entered.

  The reason needs a storage decision in Stage 8 (a column or an event), without a new status.
- **D4 — After the night.** Should a saved plan whose night has passed be offered for a result:
  - only in the Logbook; or
  - **also as a quiet line on Tonight ("Last night: M42. How did it go?") (recommended)**?

  There are no notifications (ADR-016 §6). The line's placement is S4.R4's, and what happens to
  the plan in the planner the next day is S4.R3's (§2.1).

## 11. What Stage 8 would implement (sketch, not frozen)

Under B and G2, for Stage 8's planning. S4.T turns it into provisional Tasks.

1. **ADR-019** (S4.D) amends:
   - ADR-014 §3: a planned session can be completed or abandoned by a result, without a run;
   - ADR-016: post-session counts are written as result events, so the counters still equal the
     replay; the tracker becomes optional.
2. **A result form on the Logbook entry:** Completed as planned, Partly (numbers per light block),
   or Not done (a reason); notes; optional conditions. It replaces today's Results page as the
   single place. The tracker's Finish leads there too, which removes UX-26's second Finish (RD-12).
3. **Start leaves the primary path** (Tonight's card, the planner's bottom bar) and appears as
   "Track live (optional)" on the saved session. UX-13 is gone from the default flow.
4. **Planned vs actual and Progress** read the recorded result. "Reported as planned" is labelled
   (CALC-37 note; RD-13 decided alongside).
5. **Migration:** none destructive. In-progress sessions complete through the form; past events are
   exported unchanged. If the manifest gains a field, it is additive, so no version bump is
   expected; confirm in Stage 8.
6. **Tests:** the core-loop E2E test moves to Save → result (trap 19), with the live path tested
   separately.
7. **Later, not decided here:** "fill from photos" in the result form (TASK 17.3), once batch
   metadata reading exists.
