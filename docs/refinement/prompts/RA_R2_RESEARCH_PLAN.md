# RA.R2 → RA.D → RA.P — plan for the remaining product reassessment

> **Status: APPROVED by the owner 2026-10-17 (gate G0):** «Approve G0: make the two documentation commits as proposed, then run RA.R2 (R2a–R2d in parallel, then R2e) and stop at the decision package.» The optional permissions in §6 were not granted.
> Prepared 2026-10-17 after RA.R1
> ([Phase A report](../research/RA_R1_PHASE_A_ASSESSMENT.md)). Details RA.R2, RA.D and RA.P from
> [PRODUCT_REASSESSMENT.md](PRODUCT_REASSESSMENT.md); does not replace the active plan and does not change decisions.
> Verification rules are
> only in CLAUDE.md (V1–V8); they are not duplicated here.

## 1. What remains

RA.R1 closed the reconciliation: each of the 56 review findings (RA-A01…RA-I05) and 14 contradictions (K1…K14) has
an ID and a disposition. What remains:

1. **Research what the code cannot answer** (R1–R10 from Phase A): user expectations and comparable products,
   scientific and model options, weather sources and Moon presentation, identity. Then consolidate this into a
   package of product-direction options.
2. **Obtain the owner's decisions** (RA.D). The eight Phase A questions plus name and logo. Almost all of them
   reverse or change previously approved decisions: RD-04, ADR-019/RG-05, ADR-020 (P2, C1, W1/F1),
   SI-003, the Stage 11 row on theoretical size, OD-07 and the S9.10 deferral.
3. **Rebuild the roadmap to release** (RA.P), taking into account the open Stage 11, owner actions and
   TD-104.
4. **Close the Phase A loose ends:** documentation git checkpoint (§8), TD-104 (CI), confirmation of three
   candidate defects.

Not requiring new research, because it has already been researched and is reused:
- RG-10 and RG-11 — calibration and capture parameters; only the contested points are updated (W/F, P2, C1);
- S9.3 — settings;
- S9.10 — logo alternatives;
- S9.11 — licence;
- S9.12 — identity and app id;
- RG-05/06 — Tonight and the planner;
- the Phase A code audits — a repeat repository audit is not needed.

## 2. Structure: three reassessment Tasks plus one technical Task

```text
RA.R2  research and options (one approved Task, internal steps a–e)
  ├─ R2a  market and user expectations ───────┐
  ├─ R2b  science and Capture Plan model ─────┤  in parallel
  ├─ R2c  night conditions: weather and Moon ─┤
  ├─ R2d  identity: name, mark, splash        ┘ → may go to decision earlier (RA.D, round 1)
  └─ R2e  synthesis: product direction and decision package (depends on a–c, considers d)
          ── STOP: decision package to the owner ──
RA.D   owner decisions (round 1: identity after R2d; round 2: product after R2e)
          ── STOP ──
RA.P   roadmap Stages → Tasks to release (documents only)
          ── STOP: roadmap approval; implementation does not start ──

Separately, does not block RA.R2:  T-CI  TD-104 diagnosis (log needed)
```

Why five steps rather than ten: R1–R10 are grouped by shared sources and shared output.
- **R4** (onboarding), **R5** (Home and the planner flow), **R9** (records) and **R10** (settings) are a
  synthesis from the same inputs (comparable products, decisions, Phase A code), so they go into R2e.
- **R6** (parameters, SNR) and **R7** (size) rely on the same technical sources and change one
  domain (Capture Plan), so they go into R2b.
- **R2** (weather) and **R3** (Moon) are one screen and one set of providers, so they go into R2c.

## 3. Tasks

### R2a — Market and user expectations (R1)

- **Question:** which planning jobs comparable products address, how they present the capture plan, weather, Moon,
  onboarding and records, and what users actually value.
- **Coverage (≥ 8 products):**
  - Telescopius;
  - Astrospheric;
  - Clear Outside;
  - PhotoPills;
  - Stellarium Mobile;
  - Sky Tonight or SkySafari;
  - AstroPlanner (Rodman);
  - DarkScout;
  - the app from the reference `com.twtapp`;
  - the plan model in N.I.N.A. and ASIAIR — only as a capture plan example.
- **User reviews:** stores, Cloudy Nights, r/astrophotography. Anecdote and recurring theme
  are explicitly separated.
- **Output:** `research/RA_R2A_LANDSCAPE.md`. A "product × job" matrix. For each area RA-A…RA-H —
  "what users expect" and "how we differ or what we duplicate". Separately — a list of what it is reasonable
  **not to do** (duplicating a full planetarium or a weather app).
- **Done when:** each product has a primary source with an access date; each area
  RA-A…RA-H has at least one sourced conclusion; feature claims are separated into "confirmed"
  and "per description".
- **External search:** yes. Subagent — yes.

### R2b — Science and the Capture Plan model (R6, R7, scientific part of R3)

- **Questions:**
  1. Whether absolute SNR can be estimated honestly. The inputs needed (aperture, QE, sky brightness,
     target surface brightness) and the presentation of uncertainty. What the options are: relative
     √N only; √N along the integration-time axis; an optional CCD-equation model with explicit assumptions.
  2. Theoretical size (pixels × bit depth for RAW, DNG, FITS; compression) versus empirical, and how
     to label each.
  3. "Pro mode" fields by camera class:
     - phone (Camera2: ISO, exposure time, WB, focus);
     - DSLR;
     - astro cameras (gain, offset, temperature);
     - what to record, what to model. Revisiting W1/F1 → W2/F2, P2 (visually "proposed"), C1
       (how to obtain the camera class without inferring it "behind the user's back").
  4. Definition of "dark time without the Moon" (Moonlit: Sun ≤ −18° and the Moon's upper limb below
     the horizon) versus ADR-010 and CALC-43.
- **Output:** `research/RA_R2B_CAPTURE_SCIENCE.md`. For each option:
  - recommendation and a realistic alternative;
  - affected ADRs, SIs and CALCs;
  - data consequences (migration, snapshots, export v2, backup);
  - hand-computed reference vectors, if a new formula is proposed (SCIENTIFIC_INTEGRITY
    Part C).
- **Done when:** every proposal to change a calculation or model has a primary source,
  assumptions, vectors and data impact. Nothing is marked as decided.
- **External search:** yes (CCD-equation literature, DNG/FITS specifications, Android Camera2,
  camera documentation). Subagent — yes. The main agent verifies the key formulas itself.

### R2c — Night conditions: weather and Moon (R2, R3 — presentation)

- **Questions:**
  1. Which night parameters matter for capture, according to the sources and reviews from R2a.
  2. A multi-night overview from a single Open-Meteo request: volume, cache, freshness.
  3. Seeing and transparency sources (7Timer, Meteoblue and others): data, licence, terms,
     commercial restrictions, reliability, privacy, failure behavior.
  4. A mobile monthly Moon calendar following the Moonlit concept: what to show, the cost of computing
     30 nights offline. Only the concept is carried over: the Moonlit code has no licence.
- **Output:** `research/RA_R2C_NIGHT_CONDITIONS.md`. A provider matrix. The recommended composition
  of the "night summary" for Home and the detail screens, preserving ADR-012: no score and no "good/bad"
  colouring, freshness, "unknown, not 0".
- **Done when:** each proposed parameter and provider has a source, terms and
  failure behavior; the impact on privacy/COMPLIANCE is described (trap 22). A new provider — only as an
  option for RA.D.
- **External search:** yes. Subagent — yes.

### R2d — Identity (R8)

- **Questions:**
  1. 8–12 name candidates with collision screening: Google Play, App Store, WIPO Global Brand
     Database, EUIPO, USPTO, domain and GitHub. **This is not a legal opinion.**
  2. The fate of the app id: it is permanent after the first upload. Relationship to RD-01 and TD-088.
  3. Mark directions: reuse S9.10, adapt to the chosen name.
  4. Splash: AnimatedVectorDrawable in the Android 12+ system SplashScreen versus a Flutter animation,
     reduced motion, startup budget.
  5. Icon sets and animation packages: licence, GPL-3.0 compatibility, size.
- **Output:** `research/RA_R2D_IDENTITY.md` with shortlists to choose from. Only the owner chooses
  the final mark (P9.4).
- **Done when:** each name candidate has dated screening results; each
  library has a licence and a compatibility check.
- **External search:** yes. Subagent — yes. Independent of the rest: can go to decision
  (RA.D, round 1) immediately.

### R2e — Synthesis: product direction and decision package (R4, R5, R9, R10 + results of a–d)

- **Questions:**
  1. Minimal onboarding and permission requests.
  2. Home hierarchy: weather or plan first, site and night context.
  3. The planner chain and empty states.
  4. The Capture block by camera class.
  5. Assumptions.
  6. Logbook, Library, Settings.
  7. Product scope (RA-A06: candidates, altitude chart, detailed weather).
- **Visual baseline:**
  - screenshots of the current screens from the owner's phone — **preferred**, as it is a real
    device;
  - or temporary host renders (only with permission, §6).
- **Output:**
  - `research/RA_R2E_DIRECTION_OPTIONS.md`: for each RA.D question — recommendation, alternative,
    trade-offs, the decision being replaced, what requires approval;
  - wireframes of Welcome, Home, the planner, the Capture block, Logbook, Library and Settings —
    in Markdown following the `IA_WIREFRAMES` pattern, plus optional HTML mock-ups as a private Artifact for
    viewing;
  - **decision sheet** — a single document with options that the owner fills in.
- **Confirmation of candidate defects** (RA-F04 — Flat without a filter in the example, RA-F05 — exposure
  carried over on a type change, RA-G03 — no visible Delete): a probe, if permitted (§6); otherwise they
  go to RA.P as "verify, then fix" Tasks.
- **Done when:**
  - every RA-A…RA-H finding from Phase A has a recommendation in the package or an explicit "no change,
    because …";
  - every item requiring a decision names the decision being replaced and the consequences for data and tests;
  - there is no new UX recommendation without a source or justification.
- **External search:** targeted, only for R4: Material and Android guidance.

### RA.D — Owner decisions

- **Round 1:** name, app id and mark direction — after R2d.
- **Round 2:** product direction via the decision sheet — after R2e.
- **Recording:** only the owner's actual answers, in DECISIONS E.1. In the same place, amendments to ADR-019, ADR-020,
  SI-003 and the Stage 11 rows, or a new ADR-021 "Product direction 2026-10". An agent's recommendation
  is not a decision.
- **Done when:** each question on the sheet has an owner answer or an explicit deferral with a reason.

### RA.P — Roadmap to release

- **Contents:**
  - new Stages → Tasks: one objective, dependencies, exclusions, acceptance criteria, V1 verification class,
    stop condition;
  - each review finding mapped to a Task or an explicit deferral;
  - carry-over of everything that already exists:
    - S11.6 and S11.7;
    - Stage 11 rows invalidated by the redesign, and rows that keep their PASS (V3);
    - owner actions: signing, policy, RD-01, S11P-03, the specification, the Play closed test;
    - TD-104 and the deferred S9.10–S9.12.
- **Recommended principle (decided by RA.P):** UI changes first, then phone checks and
  readiness on the final build. Otherwise S11.6 will have to be repeated.
- **New UX acceptance criteria** (renders and owner review for UI Tasks — per K14) apply only to
  new changes and do not reopen past PASSes.
- **Output:** an amendment to `POST_ROADMAP_PLAN.md` and `PROGRESS.md`. Documents only.
- **STOP:** the owner approves the roadmap. Implementation — separate Tasks.

### T-CI — TD-104 diagnosis (separate technical track)

- **Needed:** the log of the failed job (you — signed in to GitHub, or an authorized `gh`).
- **Order:** identify the test, classify it (platform, environment or real defect), then
  propose a corrective Task.
- **Why it does not block RA.R2:** the local S11.C2 gate on Windows remains valid evidence
  on the same inputs (V3), and research does not change code. **It becomes a blocker** for any Stage 11
  row about CI and before the first store upload.

## 4. Phase A finding traceability

| Task | Findings |
| --- | --- |
| R2a | RA-A01, A06, A07, D05, E04, F01, G01, G02, G04, H03 (inputs); K4, K14 (context) |
| R2b | RA-A02, A03, A04, A08, F05, F06, F07, F08, F09, F10, F11, H02; scientific part of E01; K5, K6, K7 |
| R2c | RA-E01, E02, E03, E05, E06; weather part of D03 |
| R2d | RA-C01, C02, C03, C04, A09, part of I04 (name; licence — S9.11 is reused); K10 |
| R2e | RA-B01–B06, D01–D06, F01–F04, F09, G01–G05, H01–H03, A01, A05, A06, A08; K4, K8, K9, K11, K14; candidate defects F04, F05, G03 |
| RA.D | questions 1–8 from Phase A §5; name, app id and mark; licence (RG-12), if the owner wishes to revisit it |
| RA.P | RA-A10, I01, I03, I05, everything accepted in RA.D, K12, K13 |
| T-CI | RA-I02, K3 (TD-104) |
| Checkpoint (§8) | K1, K2, K3 (PROGRESS entries) |

Every Phase A finding appears in at least one row. Overlaps are intentional: R2e receives the conclusions
of the specialised steps and formulates them as decisions.

## 5. Approval gates

| Gate | What the owner approves | When |
| --- | --- | --- |
| G0 | This plan; git checkpoint (§8); optional permissions (§6) | Now |
| G1 | Name, app id, mark direction | After R2d |
| G2 | Product direction: scope, Home, planner flow, Capture fields, SNR, size, weather, Moon, providers, Settings | After R2e |
| G3 | Roadmap to release | After RA.P |
| G4+ | Each implementation Task or group of Tasks (as now) | After G3 |

The gates correspond to the list from the request: removal or change of features, scientific models, major
flows, providers, identity, the final direction and the roadmap. Research inside RA.R2 proceeds without
intermediate questions. The owner is asked only when research is
impossible without an answer (§7).

## 6. Optional permissions (they speed things up but are not required)

1. **Screenshots of the current screens from the phone** (Welcome, Home, the planner empty and filled, the block
   dialog, Logbook, Library, Settings) — the best visual baseline for R2e.
2. **Temporary probes:** files under `test/`, only to confirm RA-F04, F05, G03 and host renders
   of screens. Not committed and deleted afterwards; the result is recorded in one line with the starting
   state. Without this permission the candidate defects go to RA.P.
3. **CI log** (T-CI).

## 7. RA.R2 autonomy and stop conditions

- **Inside the approved RA.R2, without questions:** reading, web search, comparison, subagents for R2a–R2d,
  writing `research/RA_R2*.md` files.
- **Prohibited:**
  - application code, tests (except under permission §6.2), dependencies;
  - changing existing decisions and governance;
  - moving to RA.D or RA.P without a gate.
- **STOP conditions:**
  1. The R2e package is delivered; this is the normal end.
  2. A contradiction is found that makes further analysis impossible without an owner decision.
  3. An edit outside the permissions is needed.
- **An unavailable source or tool** is a recorded gap, not a reason to stop
  or guess.

## 8. Documentation, verification, git

- **V1 class:** "documentation". It is checked that links and IDs resolve, the text is consistent with
  the cited documents, and `git diff --check` is clean. The gate is not run.
- **Research claims:** URL, access date, fact or conclusion. Competitors — without
  copying their assets.
- **Privacy:** the repository is **public**. The owner's reference screenshots show his address and
  coordinates, so **do not commit them**; if needed — cropped copies without location.
  Answers K1: the review may be placed in `docs/refinement/owner-review/` only as text, without these
  images.
- **PROGRESS:** updated at the RA.R2, RA.D and RA.P boundaries, in one line, with approval.
- **Proposed checkpoint (G0)** — two documentation-only commits, without
  `macos/Flutter/GeneratedPluginRegistrant.swift` (it contains only a line-ending change):
  1. *docs: instruction correction and Product Reassessment scope (2026-10-17)*:
     - CLAUDE.md;
     - `.agents/rules/00`, `.agents/rules/05`, `.agents/skills/README.md`;
     - `docs/ENGINEERING_GUARDRAILS.md`;
     - `docs/archive/CLAUDE_2026-10-17_BEFORE_REASSESSMENT.md`;
     - DECISIONS, POST_ROADMAP_PLAN, PRODUCT_DIRECTION;
     - `prompts/PRODUCT_REASSESSMENT.md`.
  2. *docs: RA.R1 assessment, TD-104, RA.R2 plan proposal*:
     - `research/RA_R1_PHASE_A_ASSESSMENT.md`;
     - `TECH_DEBT.md` (TD-104);
     - this file;
     - PROGRESS with the K2/K3 corrections:
       - the RA.R1 report — in a file;
       - the Moonlit project is available;
       - code pushed by the owner, `origin/main` = `b1df679`, PR #1 2026-10-16;
       - the repository is public;
       - CI is red, TD-104;
       - RD-17 and «make the repository public» updated as facts, not decisions.
- **Push:** not included; requires a separate owner command. The CI filter would skip
  documentation-only changes anyway.

## 9. Recommended first step

After G0, run RA.R2 as one group: R2a, R2b, R2c and R2d in parallel (subagents; the main agent verifies the key
claims itself), then R2e. If the owner prefers a sequential
order, start with **R2a**: it feeds all the other conclusions about what the user needs.
R2d can be handed over for decision (G1) without waiting for R2e.

## 10. Governance clarification (minimal)

CLAUDE.md does not need to change: an approved grouped run with named steps and stop conditions
is already permitted («A grouped run must explicitly name its authorized Tasks and stop conditions»). One
clarification is needed in [PRODUCT_REASSESSMENT.md](PRODUCT_REASSESSMENT.md): the line «Outputs go in the chat
unless the active Task explicitly authorizes a report file» contradicts practice. The RA.R1 report was already
lost in the chat once. Proposed wording, after approval:

> RA.R2–RA.P write their reports to `docs/refinement/research/RA_R2*.md` (and RA.P to the plan and
> PROGRESS); the chat carries the summary.

Approval of this plan (G0) can be considered explicit permission for report files even without the text edit.
