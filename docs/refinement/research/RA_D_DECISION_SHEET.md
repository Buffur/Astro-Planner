# RA.D — Owner decision sheet

> Prepared 2026-10-17 from the results of RA.R2; translated into English 2026-10-17 (CLAUDE.md
> language policy). The reasoning is in [RA_R2E_DIRECTION_OPTIONS.md](RA_R2E_DIRECTION_OPTIONS.md)
> and the R2a–R2d reports.
> **★ = the agent's recommendation; it is not a decision.** The "Source" column says which report
> the recommendation comes from. Where R2e's synthesis differs from a research step, both are
> shown.
>
> **How to answer:** name the ID and the option in the chat, for example "ID-1 Culmina, ID-3 I-2,
> PD-03 H-P", or "★ for everything except …". Only the owner's answers are recorded in DECISIONS
> E.1. An item without an answer stays open, or is deferred with a reason.

## Round 1 — identity (gate G1)

| ID | Question | Options | Source | Your answer |
| --- | --- | --- | --- | --- |
| ID-1 | The app's name | Culmina · AltArc · Astrarc · Arcwindow · Noctarc · PhotonPlan · your own (then screened as in R2d §1) · keep "Astro Planner" (high collision risk). No ★: the owner chooses | [R2d](RA_R2D_IDENTITY.md) §2–§3 (screening, not legal advice) | **Culmina** — the owner, 2026-10-17 (DECISIONS E.1, "RA.D — ID-1"); pending formal trademark clearance before store publication; "Culmina: Astrophoto Planner" is a provisional descriptor only. No code renamed |
| ID-2 | The project's account (RD-01) | ★ B — Buffur · B′ — Buffur links, id under chacha12 · C — chacha12 | ★ from R2e §9; R2d §8 and S9.12 list the options without a recommendation | |
| ID-3 | App id | ★ I-2 `io.github.buffur.<name>` · I-1 keep `io.github.chacha12.astroplanner` · I-3 `io.github.chacha12.<name>` | ★ from R2e §9; consequences in R2d §4 (on the owner's phone the new id installs separately; data moves by backup and restore) | |
| ID-4 | Repository name and policy URL | Keep `Astro-Planner` · rename to the brand (the GitHub Pages URL changes) | R2d §4, §8 (D4) | |
| ID-5 | Logo direction | A · B · C · D (S9.10) · E (monogram) · a mix. Sketches for the chosen name come after the answer; only the owner chooses the final mark (P9.4) | R2d §5, S9.10 | |
| ID-6 | Loading screen | ★ S2 (an animated mark in the system splash + the mark in Flutter for the real loading time only) · S1 (system splash only) · S0 (as now) · S3 (Lottie/Rive, a new dependency) | R2d §6, §8 (D6); R2e §3.2 | |

## Round 2 — product direction (gate G2)

| ID | Question | Options | Supersedes | Source | Your answer |
| --- | --- | --- | --- | --- | --- |
| PD-01 | Product scope | ★ S-A demote, do not remove · S-B remove "What can I image tonight?" and the detailed weather · S-C "all in one" | PRODUCT_DIRECTION §1 (clarification) | R2a §5.1; R2e §2 | |
| PD-02 | Onboarding | ★ O-2′ (site + camera class/rig, no target step, one button, no Skip) · O-1 (no Welcome; a site card on Home). The flash is fixed under either option | TASK 12.5 | R2a §4 (RA-B); R2e §3.1 | |
| PD-03 | Home order | ★ H-W (the night first, then the plan, no "New plan", context as a subtitle) · H-P (the plan first, the night second) | ADR-019 §5, RG-05 T1 | R2c §6; R2e §5 | |
| PD-04 | Planner empty state and the duplicated weather | ★ a checklist instead of the empty status; the duplicated weather row removed · as now | ADR-019 §6 (contents) | R2e §4.3 | |
| PD-05 | SNR | ★ O2 (√N over integration time, relative) · O1 (as now) · O4 after 1.0 (a sub-exposure hint for astro cameras) · absolute SNR — not recommended | CALC-42 (presentation); SI-003 stays | R2b §2, §6 (D-SNR) | |
| PD-06 | Storage | ★ ST3 + ST2-lite (size from any file; without one, an estimate labelled "16-bit uncompressed", no schema change) · ST3 + ST2 full (format and bit-depth fields, migration v26; R2b's recommendation) · ST3 only | The Stage 11 line "no theoretical size", SI-013 | R2b §3, §6 (D-STO) recommends ST3 + ST2; ST2-lite is R2e §4.1's lower-cost variant | |
| PD-07 | Camera class | ★ C1-b + C1-d (ask explicitly; the example rig gets a class) · C1-c (proposed from metadata with confirmation) · as now | ADR-020 §2 | R2b §4.6 | |
| PD-08 | Prefilled values | ★ P2b (a "from block …" marker on each field; filter default by class) · P2c · P0 (no proposals) | ADR-020 §5 (presentation) | R2b §4.5 | |
| PD-09 | White balance | ★ W2 (a record, no calculation; v26) · W1 | ADR-020 W1 | R2b §4.2 | |
| PD-10 | Focus | ★ F2 (a reminder) · F1 · F3 (a slider — not recommended) | ADR-020 F1 | R2b §4.3 | |
| PD-11 | "Take from a photo" in the block | ★ after 1.0 · in 1.0 · never | ADR-020 P3 | R2b §4.4 leaves it to the owner without a recommendation; ★ from R2e §4.2 (release scope) | |
| PD-12 | Calibration | ★ CAL-1 (one action, "Build calibration from lights") · CAL-0 | — | R2b §4.7 | |
| PD-13 | The example plan | ★ remove the button · move it to ⋮ and fix it | RD-04 | R2e §4.2 | |
| PD-14 | Assumptions | ★ only the enabled items · as now | — | R2e §4.2 | |
| PD-15 | Moon: moon-free dark time | ★ MF-b (by the displayed rise and set) · MF-a (as is, with a label) · MF-c (one h₀ everywhere, high risk) | CALC-43 (a new derived quantity) | R2b §5.3 | |
| PD-16 | Night overview (16 days, one request) | ★ yes · no | ADR-012 §4, §6; the privacy wording | R2c §7 (W1) | |
| PD-17 | Monthly Moon calendar | ★ yes, in the details · only 7 nights | — | R2c §7 (M2) | |
| PD-18 | Seeing and transparency | ★ not in 1.0 + a link the user opens themselves · 7Timer opt-in · nothing | ADR-012 §2/§3 (with 7Timer) | R2c §7 (W4) | |
| PD-19 | Records | ★ Progress as a Logbook segment, a visible Delete, "Plan this target" on the row, the forecast in the entry; AstroBin CSV after 1.0 · no change | — | R2a §5.6; R2e §6 | |
| PD-20 | Settings | ★ add Appearance (System/Light/Dark); units after 1.0; overheads stay global · no change | — | R2a §5.7; R2e §7 | |
| PD-21 | Time between frames | ★ I1 global · I2 per rig (v26) | — | R2b §4.8 | |
| PD-22 | Order of work to release | ★ CI → identity → redesign → v26 (if needed) → Stage 11 on the final build · another order | Input to RA.P | R2e §10 | |

## Needed from the owner, outside the decisions

- **The failed CI run's log** (TD-104), or permission to sign in with `gh`.
- **Optional:** screenshots of the current screens from the phone, for the redesign's visual tasks.
- **Licence (RG-12):** stays GPL-3.0 unless the owner wants to revisit it.
