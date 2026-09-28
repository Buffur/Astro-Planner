# Stage 6 — the five-second test (S6.E)

> **Task:** S6.E, owner-run evidence (`POST_ROADMAP_PLAN.md`, "S6.E"). It answers the Stage 6 Exit's
> comprehension points: can a person tell, in five seconds, what the first screens say?
> **Script:** Test A, `research/S4.R1_FLOW_INVENTORY.md` §7.1, with its device rules as corrected on
> 2026-09-28 (S6.E step 1, S4V-02).
> **App state:** the code at `f19aef7` (Stage 6's code Tasks done). Record the build you used below.
> **Privacy:** no personal data about the people who try it; a role is enough ("owner", "friend, no
> astro experience").
> **Status:** the device and the test plan are **set up** (2026-09-28, by an agent over USB); the
> questions are **not yet asked**. A person must look and answer: the agent does not answer them.

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
| Date | 2026-09-28 (setup) |
| Build (`.s2check` or own app; commit if known) | `io.github.chacha12.astroplanner.s2check`, a debug build of `934fb1a` (application code identical to `f19aef7`), with a local application-id suffix that was reverted before install. The owner's app was not touched (its last update time, 2026-09-28 19:02:04, was the same before and after) |
| Phone | The owner's Xiaomi 14T Pro (Android 16), over USB |
| Plan: site, target, rig | "Test site" at 50.45° N, 30.52° E (public city coordinates, 180 m, zone Europe/Kiev as the phone's); Andromeda Galaxy (M31); the example rig (ZWO ASI2600MC + example 72 mm f/5.6 refractor); the example plan (L 60 s × 100, 20 darks, 20 flats); night of Mon, Sep 28 |
| Plan saved before the test? | Yes: Save plan was tapped, so the state is **Saved** |
| The true answers (fits / tight / doesn't fit; the night; saved or not) | **Tonight:** it can be imaged: "Fits: 1 h 48 min needed of 8 h 35 min usable"; to change the plan, **Open planner** (the site ▾ · night ▾ line changes the site or night); **Saved**. **Planner:** Andromeda Galaxy, the night of Mon, Sep 28, Saved; it fits (1 h 48 min of 8 h 35 min; capture ends 22:21) |

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
are observations for the Stage 6 validation to weigh; they are not the five-second answers.

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

## Summary (filled in after the run)

- Questions answered right: __ of __.
- What was misread, if anything, and where it points (for the Stage 6 validation to weigh; this
  document records evidence and proposes no change).
