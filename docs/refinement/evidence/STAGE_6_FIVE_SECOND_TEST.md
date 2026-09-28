# Stage 6 — the five-second test (S6.E)

> **Final-validation disposition, 2026-09-28:** **UNVERIFIED — no independent participant
> available**. The owner explicitly accepts this evidence gap for now in the validation request.
> No participant answers have been supplied or inferred. The [Stage 6 validation](../STAGE_6_VALIDATION.md)
> records the gap as non-blocking under the existing S6.E decision and V7; its BLOCKED result
> concerns the separate deletion-Undo finding S6V-01 / TD-082. The past Capture ends observation
> is classified in that report (C1) as correct selected-whole-night planning semantics.
> The earlier setup and owner-review observations below are preserved as evidence.

> **Task:** S6.E, owner-run evidence (`POST_ROADMAP_PLAN.md`, "S6.E"). It answers the Stage 6 Exit's
> comprehension points: can a person tell, in five seconds, what the first screens say?
> **Script:** Test A, `research/S4.R1_FLOW_INVENTORY.md` §7.1, with its device rules as corrected on
> 2026-09-28 (S6.E step 1, S4V-02).
> **App state:** the code at `d7e1477` (S6.16; Stage 6's code Tasks done), on `.s2check` since the
> refresh of 2026-09-28 (Setup, below). The owner's review below used the first setup's `f19aef7`
> code.
> **Privacy:** no personal data about the people who try it; a role is enough ("owner", "friend, no
> astro experience").
> **Status:** the five-second test is **UNVERIFIED**: the refreshed device and the test plan are set
> up (2026-09-28, by an agent over USB), but no independent participant has answered the five
> questions. An **owner manual UX review** was recorded on 2026-09-28 (below); it is a different
> kind of evidence and does not stand in for the test.
> **Build refreshed after S6.16 (2026-09-28, 22:52):** the owner's corrective pass (DECISIONS E.1,
> "Stage 6 corrective pass decided") changed both first screens (Tonight's title, context card,
> "Your plan" card and target actions; the planner's status card and its order below the status),
> so the `.s2check` app was rebuilt from S6.16's commit and an equivalent test plan was made and
> saved (Setup, below). S6.16 changes no calculation: for the night of Mon, Sep 28 the plan's verdict
> and numbers are the same as at the first setup. **If the test runs on a later night,** prepare the
> plan for that night first (in `.s2check`: ⋮ → New plan, Andromeda Galaxy, "Start from the example
> plan", Save plan) and re-record the true answers before asking. The participant must be someone
> who has not worked on the product; an agent is never the participant (item 7 of the owner's
> decision).

## How to run it

1. **Where:** the separate `.s2check` debug package (an agent installs it when you ask), or your own
   app after **Save plan** on your current plan and **⋮ → New plan** for the test plan (the device
   rules). Never reset, clear or uninstall your own app.
2. **The test plan:** tonight, a site, a target and a rig, with blocks (or "Start from the example
   plan"). Save it if you want the "Is it saved?" question to have the answer "Saved"; leave it
   unsaved for "Not saved". Note which you chose.
3. **Tonight:** show the Tonight tab for five seconds, hide it, and ask the three Tonight questions.
4. **The planner:** tap Open planner, show its first screen (without scrolling) for five seconds,
   hide it, and ask the two planner questions.
5. Write the answers word for word, and whether each was right. One block per person.

## Setup

| Item | Value |
| --- | --- |
| Date | 2026-09-28: first setup 19:05; **refreshed 22:52–22:55** (the build and plan this test uses) |
| Build (`.s2check` or own app; commit if known) | `io.github.chacha12.astroplanner.s2check`, a debug build of **`d7e1477`** (S6.16). Built in a separate, detached Git worktree of that commit with a local `applicationIdSuffix = ".s2check"`, reverted before the worktree was removed and never committed; the main working tree was not changed. Before install, `aapt2` showed the package `io.github.chacha12.astroplanner.s2check` and `apksigner` the Android debug certificate (APK SHA-256 `7e0ba4229ef31eb5069e4fb4adc082e955cebd6922fed9954d7944767ea7b89f`). Installed with `adb install -r` as an update of the existing `.s2check` package, so its data was kept. **The owner's app was not touched:** `io.github.chacha12.astroplanner`'s last update time (2026-09-28 22:44:13) and code path were the same before and after. That 22:44:13 update was not this setup's: when the setup began, a `flutter run` debug session from Android Studio on this machine was attached to the owner's app, and the separate worktree kept this build away from it. *First setup (superseded; the owner's review used it):* a debug build of `934fb1a` (application code identical to `f19aef7`), installed at 19:05; the owner's app's last update time then (19:02:04) was unchanged by it |
| Phone | The owner's Xiaomi 14T Pro (Android 16), over USB; the system's dark theme (the app followed it), font scale 1.0 |
| Plan: site, target, rig | "Test site" at 50.45° N, 30.52° E (public city coordinates, 180 m, zone Europe/Kiev as the phone's); Andromeda Galaxy (M31); the example rig (ZWO ASI2600MC + example 72 mm f/5.6 refractor); the example plan (L 60 s × 100, 20 darks, 20 flats); night of Mon, Sep 28. **Refresh:** made again through the app: ⋮ → New plan (it kept the site and rig), Andromeda Galaxy chosen from the catalogue, "Start from the example plan", Save plan |
| Plan saved before the test? | Yes: Save plan was tapped, so the state is **Saved** |
| The true answers (fits / tight / doesn't fit; the night; saved or not) | **Tonight:** it can be imaged: "Fits: 1 h 48 min needed of 8 h 35 min usable"; to change the plan, **Open planner** (the site ▾ · night ▾ context card changes the site or night); **Saved**. **Planner:** Andromeda Galaxy, the night of Mon, Sep 28, Saved; it fits (1 h 48 min of 8 h 35 min; capture ends 22:21). *Re-checked on the refreshed build at 22:54–22:55: both screens display exactly these values; valid for the night of Mon, Sep 28 only* |

## Answers

### Person 1 — role:

| Screen | Question | Answer (word for word) | Right? |
| --- | --- | --- | --- |
| Tonight | Can this plan be imaged tonight? | | |
| Tonight | What would you tap to change the plan? | | |
| Tonight | Is the plan saved? | | |
| Planner | Which target, which night, and is it saved? | | |
| Planner | Does the plan fit the night? | | |

Notes (hesitation, what they looked at first, anything they misread):

### Person 2 — role (optional):

| Screen | Question | Answer (word for word) | Right? |
| --- | --- | --- | --- |
| Tonight | Can this plan be imaged tonight? | | |
| Tonight | What would you tap to change the plan? | | |
| Tonight | Is the plan saved? | | |
| Planner | Which target, which night, and is it saved? | | |
| Planner | Does the plan fit the night? | | |

Notes:

## Observations while setting up (by the agent; not test answers)

What the agent saw on the device while it built the test plan through the app's own screens. These
are observations for the Stage 6 validation to weigh; they are not the five-second answers. The
first list is the first setup (19:05, `f19aef7`'s code); the second is the refresh on S6.16's build.

- Both first screens show, without scrolling on this phone (1220 × 2712 px): **Tonight** the site ▾
  · night ▾ line, "Your plan" with the target, the "Saved" label, the rig (marked "example rig"),
  the verdict with time needed and usable time, its reason and Open planner; **the planner** the
  target, night and state strip, the verdict, reason, integration, capture end, the fill action and
  the site ▾ · night ▾ line.
- The steps read as intended: without a site "Needs a site", then "Needs a target", "Needs a rig",
  "Needs a block", and finally "Fits"; "Start from the example plan" filled three rows reading
  "L · 60 s × 100 · 1 h 40 min", "Dark · 60 s × 20 · 20 min" and "Flat · 2 s × 20 · 40 s"; the
  light row said "+375 frames still fit tonight" and gave the unknown-tracking note neutrally.
- **Found (recorded as TD-075, not fixed):** while a site or a target is missing, the status's
  reason line under "Needs a site" / "Needs a target" read "The plan has no light frames, so there
  is nothing to fit." (the fit's own reason for an empty plan), which does not match the headline.
- The weather row said "No forecast. Offline or the service did not answer." during setup (the
  forecast did not load on the phone at the time); this does not affect the five questions.

### The refresh on S6.16's build (2026-09-28, 22:52–22:55; by the agent; not test answers)

- **Before:** the `.s2check` app's current plan was the owner's review plan, saved at 475 light
  frames and reading "Tight: 8 h 35 min needed of 8 h 35 min usable". It was not changed or deleted:
  Sessions lists it beside the new test plan (both "Mon, Sep 28 - Andromeda Galaxy", Planned, 475 and
  100 planned frames).
- **The steps read as S6.16 intends:** after New plan, "Needs a target" with "Choose a target to
  see tonight's windows." (TD-075's own reason); after M31, "Needs a block" with the fit's reason;
  "Start from the example plan" filled the same three rows and showed "Started from the example
  plan" with Undo (TD-079; not tapped); Save plan turned the strip to "Saved".
- **Both first screens render without scrolling** on this phone. **Tonight:** the "Tonight" page
  title; the context card (Test site ▾ · Mon, Sep 28 ▾, the zone line); "Your plan" with Saved,
  Andromeda Galaxy, the rig marked "(example rig)", the verdict "Fits: 1 h 48 min needed of 8 h 35
  min usable", its reason "Everything fits with 6 h 47 min of window time to spare." and the filled
  Open planner; below them, the Night and Moon rows. Further down (scrolled): the Weather row
  ("Cloud 0–70 %"; the forecast loaded this time), "What can I image tonight?" once and New plan.
  **The planner:** the strip (Andromeda Galaxy · Night of Mon, Sep 28 · Saved); the status card
  with the same verdict and reason, Integration 1 h 40 min, Capture ends 22:21 and "Fill tonight's
  window: L 60 s × 475"; the context card; the start of the Target section; Save plan at the bottom.
- **The time of day:** the refresh ended at about 22:55, after the capture end the screens show
  (22:21). The screens' figures cover the whole night of Mon, Sep 28, not only the part still
  ahead. Recorded as a fact for the validation; not classified here.
- No crash, error message or layout defect was seen; nothing on the device prevents the test.

## Owner manual UX review (2026-09-28)

> **Evidence type: HUMAN / OWNER MANUAL UX REVIEW.** It is **not** an independent five-second test:
> the owner knows the product, looked at the screens broadly and deliberately, and did not answer
> the five questions under the five-second conditions. The five-second test above therefore stays
> **UNVERIFIED**.
> **Reviewer:** the owner. **Build:** the `.s2check` app set up above (application code of
> `f19aef7`). **Recorded by:** an agent, in the owner's words condensed; each item keeps apart the
> observed problem, the owner's possible solution, and what the plan already assigns.
> **Checked against:** the amended Stages 6–11 plan (`POST_ROADMAP_PLAN.md`), ADR-019, `DESIGN_SYSTEM.md`
> and the code at `f19aef7`. Items marked *verified* were checked in the code or on the phone.

**Classes:** CURRENT STAGE ISSUE (Stage 6 created it and owns it) · LATER STAGE ALREADY OWNS ·
REGRESSION (something that worked before Stage 6 no longer does) · CONFIRMS EXISTING PROBLEM ·
NEW BOUNDED FOLLOW-UP (a real problem with no owner yet; bounded) · OWNER PREFERENCE / POSSIBLE
SOLUTION · UNVERIFIED / RESEARCH REQUIRED.

**No REGRESSION was found.** Nothing that worked before Stage 6 stopped working.

### 1. Tonight

| # | Observation (the owner) | Class | Where it belongs, and why |
| --- | --- | --- | --- |
| 1.1 | The "Tonight" title could be larger or more prominent (use Stage 5's typography, no new system) | OWNER PREFERENCE / POSSIBLE SOLUTION; LATER STAGE ALREADY OWNS | *Verified:* it is the app bar's standard title, the same on all four tabs, so changing Tonight alone would break consistency. Stage 9's "final visual consistency" owns the text roles app-wide |
| 1.2 | Site and date are no longer grouped in a box, as "Your plan" is; the context feels less structured (a card is one possible solution) | OWNER PREFERENCE / POSSIBLE SOLUTION | *Verified:* S6.13 replaced Tonight's site card with the shared site ▾ · night ▾ line, as ADR-019 §5 and S5.6's `ContextLine` specify. The approved design is met, so it is not a regression. The underlying problem (not separated enough) belongs to the visual finish of Tonight and the planner, whose owner is an open question (see "For the owner" below); any change applies to `ContextLine` on both screens |
| 1.3 | Inside "Your plan", the heading is much smaller than the target, rig and text below it; it looks unfinished | **CURRENT STAGE ISSUE** (TD-077) | *Verified:* S6.13 set the heading in `labelLarge`, which `DESIGN_SYSTEM.md`'s type scale reserves for buttons; card headings are `titleMedium`, which the target below it uses. A departure from Stage 5's roles introduced by Stage 6 |

### 2. Night, Moon and Weather: the previews and the detail screens

| # | Observation (the owner) | Class | Where it belongs, and why |
| --- | --- | --- | --- |
| 2.1 | The detail screens work but look unfinished: raw templates, too much plain text, little visual explanation, unfinished colours, spacing and hierarchy, weak grouping | LATER STAGE ALREADY OWNS | S6.5 built them as structural screens on S5.7's `DetailScaffold`. Stage 6 explicitly excludes "the detail screens' secondary presentation", which Stage 9 owns: richer Night & Moon detail on P6.11's primitive, and Weather's hourly visual and icons |
| 2.2 | Headings appear too close to, or under, the back arrow | LATER STAGE ALREADY OWNS | *Verified on the phone:* no overlap. The heading sits in the page header just under the app bar, where S5.7's template puts it so that it can wrap at 200 % text. The spacing is presentation (Stage 9). Not a structural defect |
| 2.3 | In Night & Moon, one information box is followed by other information that blends into the text around it | **CURRENT STAGE ISSUE** (the repetition, TD-078); LATER STAGE ALREADY OWNS (the grouping) | *Verified on the phone:* the summary card's two lines ("Dark (Sun below −18°): …" and "Moon up …") are repeated just below it, the first as the timeline's bold heading and the second in the Moon section, a repetition S6.5 created. The sections' visual grouping is Stage 9's presentation |
| 2.4 | The Night, Moon and Weather rows on Tonight feel monotonous: one tone, small text, weak hierarchy | LATER STAGE ALREADY OWNS; OWNER PREFERENCE / POSSIBLE SOLUTION | Stage 9 owns Tonight's entry points' consistency with the planner, and the weather icons. To consider there |

### 3. Actions on Tonight

| # | Observation (the owner) | Class | Where it belongs, and why |
| --- | --- | --- | --- |
| 3.1 | "Choose a target" and "What can I image tonight?" look duplicated; their relationship is not clear (do not remove either before checking their roles) | NEW BOUNDED FOLLOW-UP (TD-080) | *Verified:* both are approved, with distinct roles (ADR-019 §5). Choose a target picks any target from the catalogue; What can I image tonight? lists the candidates for this night and site, by usable time, then frame fill (RD-10). Without a target, the second appears twice (in Your plan and in the secondary actions), because ADR-019 §5 lists it in both places. Nothing says how they differ: a wording or label fix, not a removal |
| 3.2 | "Open planner" looks under-designed for its importance: weak action hierarchy | OWNER PREFERENCE / POSSIBLE SOLUTION | *Verified:* with a target it is the card's filled primary button (Stage 5's `FilledButton`); without one it is a text button below Choose a target (S6.13's choice). Part of the visual-finish question below |

### 4. The planner: status and undo

| # | Observation (the owner) | Class | Where it belongs, and why |
| --- | --- | --- | --- |
| 4.1 | The status is a good direction, but its visual implementation feels unfinished | OWNER PREFERENCE / POSSIBLE SOLUTION | It is Stage 5's `StatusBlock` (S5.4) as S6.6 adopted it; no specific defect is named. Part of the visual-finish question below |
| 4.2 | Changes in the planner feel final: there is no obvious way back (not a request for a global undo) | NEW BOUNDED FOLLOW-UP (TD-079) | *Verified, by kind of change:* **covered:** deleting a block (Delete + Undo, S6.9, RD-09), leaving a plan with changes (Save · Discard · Cancel, S6.3; Discard puts a saved plan back to its snapshot), and the block dialog's Cancel. **Undone by choosing again** (the value stays in view): the target, rig, site, night and the order of blocks. **No recovery, where a bounded Undo would help:** "Fill tonight's window" / "Trim" (one tap rewrites a block's frame count), a block edit once saved (the previous values are gone), and "Start from the example plan" (removable only row by row). **Not justified:** a global undo stack (every edit autosaves; RD-09 set Undo for deleting inside a plan). RD-09's own scope is met |

### 5. The planner's order

| # | Observation (the owner) | Class | Where it belongs, and why |
| --- | --- | --- | --- |
| 5.1 | The blocks do not yet feel like one planning workflow. A natural order: site and date → target → rig → capture plan, then supporting analysis (where the target is during the night, Weather, Night & Moon). Keep answer-first | OWNER PREFERENCE / POSSIBLE SOLUTION (needs an owner decision) | The current order is approved: ADR-019 §6 (RD-06), frozen in S6.6: the status → site ▾ · night ▾ → the target and its windows → the capture plan → the conditions → the rig. The owner's order keeps the status first but moves the rig above the capture plan, and the night timeline and conditions after it. Changing it amends ADR-019 §6, so it needs the owner's decision; then it is a bounded Stage 6 change (the order only). Not a regression |

### 6. "Tonight for this target"

| # | Observation (the owner) | Class | Where it belongs, and why |
| --- | --- | --- | --- |
| 6.1 | The section still looks unfinished: the graph and its mostly white text feel raw and are not visually integrated (keep the graph) | CONFIRMS EXISTING PROBLEM | 08 §10 ("unattractive and not intuitive"). S6.12 met its frozen criteria (UX-08's points; the intervals from the domain), but visual integration was not one of them. The planner's timeline is Stage 6's; Stage 9's timeline work is Night & Moon's. Part of the visual-finish question below |

### 7. The capture plan

| # | Observation (the owner) | Class | Where it belongs, and why |
| --- | --- | --- | --- |
| 7.1 | Why must the user choose binning by hand? | LATER STAGE ALREADY OWNS; UNVERIFIED / RESEARCH REQUIRED | Stage 7, RG-11 (which capture parameters matter per camera type, which feed a calculation, which are records only) |
| 7.2 | ISO / gain do not feel right across camera workflows | LATER STAGE ALREADY OWNS; UNVERIFIED / RESEARCH REQUIRED | Stage 7, RG-11 (SI-004: gain is descriptive only today) |
| 7.3 | Calibration frames repeat information that should come from the lights; do not copy every light value; use the planned ownership model | LATER STAGE ALREADY OWNS; UNVERIFIED / RESEARCH REQUIRED | Stage 7, RG-10: per workflow and camera class, its output is the parameter matrix (inherited · prefilled and overridable · independent · not applicable, with the budget effect) before any form changes |
| 7.4 | The relative-stacking-gain graph: keep it, but the current planned point cannot be identified; mostly a value is seen, and a "potential" point is shown (keep the √N meaning) | **CURRENT STAGE ISSUE** (TD-076) | *Verified:* S6.11 marks the planned count with a dot and a guide line but gives it no label; the only labelled value is the curve's end ("200 frames · 14.1x", at twice the planned count), which reads as a target or potential. The planned value is only in the line above. Relative √N, not SNR, is unchanged |

### 8. Sessions (the Logbook)

| # | Observation (the owner) | Class | Where it belongs, and why |
| --- | --- | --- | --- |
| 8.1 | The "Download" action produces a file whose nature and purpose are unclear, with or without plans (download history was only an interpretation, not a requirement) | LATER STAGE ALREADY OWNS; CONFIRMS EXISTING PROBLEM | *Verified:* the icon is "Export all sessions" (tooltip only; TASK 14.3). It shares every saved session, legacy logs included, as one manifest v2 file through the system share sheet, with no word on what the file is, and nothing stops it on an empty list. P8.7 owns exactly this: "the download action is inspected (label, action, produced file, purpose) and classified … No download history unless a need is shown" |
| 8.2 | Opening a past plan does not let the owner record the result (completed or not, how much), or use planned against actual | LATER STAGE ALREADY OWNS; CONFIRMS EXISTING PROBLEM | Stage 8: P8.1 (results without a run), P8.2 (the result form), P8.7 (the entry, planned against actual). *Verified:* today a result can be recorded only after a run started with Track live (the tracker's Finish); a saved plan without a run cannot record one. It confirms Stage 8's problem statement and is not a Stage 6 regression |

### 9. Sites

| # | Observation (the owner) | Class | Where it belongs, and why |
| --- | --- | --- | --- |
| 9.1 | Elevation and Bortle still have to be looked up outside the app; automate only from a reliable, legally usable source; otherwise unknown or manual | LATER STAGE ALREADY OWNS; UNVERIFIED / RESEARCH REQUIRED | Stage 7: RG-08 (elevation: automatic, optional or dropped) and RG-09 (Bortle and SQM sources). *Verified:* the site editor asks for elevation, but no calculation uses it (SCI-08); Bortle is optional and no calculation uses it. No source is approved, and there is no scraping |
| 9.2 | What is SQM for in AstroPlan, why would a user need it, what uses it, and does an ordinary user need to enter it? (do not remove it just because its purpose is unclear) | LATER STAGE ALREADY OWNS; UNVERIFIED / RESEARCH REQUIRED | *Verified facts:* SQM is a Sky Quality Meter reading, the night sky's brightness at the zenith in mag/arcsec² (higher is darker). A site stores it with its source and date; the planner's Sky darkness section and the Logbook entry show it, and a saved plan's snapshot records it. **No calculation uses it**, and it is never converted to or from Bortle (SI-007). It is optional; an ordinary user does not need it. Whether it stays a user field is RG-09's own question (Stage 7) |

### 10. Settings

| # | Observation (the owner) | Class | Where it belongs, and why |
| --- | --- | --- | --- |
| 10.1 | Settings still needs the planned analysis: which settings a simple plan needs; app-wide, per plan, per rig or site; advanced but useful; which need explaining. No Basic/Advanced mode without evidence | LATER STAGE ALREADY OWNS | Stage 9, P9.3 with RG-13: every visible setting classed (A) app-wide, (B) a planning preference, (C) a choice for one plan, (D) a rig, target or site property, (E) display, (F) information, then moved to its owner. No modes (RG-06) |

### What this means for Stage 6

- **The five-second test stays UNVERIFIED.** This review does not replace it. S6.E's rule applies: a
  separate participant runs it (the phone is set up), or the Stage 6 validation records the gap and
  the owner decides (V7).
- **Current-stage issues** (Stage 6 created them; each is small and bounded): TD-075 (found at setup),
  TD-076 (item 7.4), TD-077 (item 1.3), TD-078 (item 2.3). None fails a frozen
  acceptance criterion as written; they are evidence the validation will weigh against Stage 6's
  own objectives (the Exit's comprehension points).
- **For the owner:**
  1. whether the planner's order changes (item 5.1 amends ADR-019 §6);
  2. who owns the visual finish of Tonight and the planner (items 1.2, 3.2, 4.1, 6.1): the plan gives
     Stage 9 the text roles app-wide and the detail screens, but its "same hierarchy" pass names the
     secondary screens, while the planner and Tonight are Stage 6's. A bounded Stage 6 follow-up
     now, or an explicit line in Stage 9's scope;
  3. whether the new bounded follow-ups (TD-079 recovery for Fill/Trim and a saved block edit;
     TD-080 the two target actions' wording) are done before Stage 6 closes or later.
- **Deferred as planned:** Stage 7 (items 7.1–7.3, 9.1, 9.2), Stage 8 (items 8.1, 8.2), Stage 9
  (items 1.1, 2.1, 2.2, 2.3's grouping, 2.4, 10.1).

## Summary (filled in after the run)

- Questions answered right: __ of __ (**not run**: the five-second test is UNVERIFIED as of
  2026-09-28; the owner's review above is not a five-second result).
- What was misread, if anything, and where it points (for the Stage 6 validation to weigh; this
  document records evidence and proposes no change).
