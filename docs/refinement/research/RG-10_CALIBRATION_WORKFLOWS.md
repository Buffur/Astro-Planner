# RG-10 — Calibration Workflows (S7.R2)

> **Status:** research, documentation only. Written 2026-09-29 at `main` @ `1a2a69b` by the S7.R2
> session (`refinement/POST_ROADMAP_PLAN.md`, "Stage 7 — frozen Task sequence", S7.R2), on RG-11's
> decision (DECISIONS E.1, "RG-11 decided": the camera classes C1, binning B1). No application code,
> test, asset or dependency changed, and no third-party data is committed.
>
> **Nothing is decided here.** Section 10 lists the owner's questions for RG-10. The answers go into
> DECISIONS E.1, and S7.D records them, with RG-11's, as ADR-020.

Evidence labels as in `research/RG-11_CAPTURE_PARAMETERS.md`: **[verified]** the repository;
**[primary]** read today (2026-09-29) in the documentation of the software that calibrates the frames,
or a maker's manual; **[secondary]** a tutorial, vendor article or forum; **[unverified]**;
**[unknown]**. Conclusions are tagged **FACT**, **OWNER PREFERENCE** or **IMPLEMENTATION OPTION**.

## 1. The question

How manual and semi-automated imagers take darks, flats, bias frames and dark flats with each camera
class of RG-11's decision; which parameters must match the lights, which commonly match, and which
are independent; each one's effect on the capture budget; and how to explain it briefly, with tips
that can be hidden (RG-10, §7 of the plan). The output is the calibration columns of the parameter
matrix; it is proposed here, not applied.

## 2. What the repository has today [verified]

- **Frame types:** light, dark, flat, bias. No dark flat.
- **A calibration block** asks for the same fields as a light block: exposure, count, binning, ISO or
  gain (a record), and a filter for flats only; plus its **calibration policy** (ADR-009 §3): in the
  window (counts in the window load), outside it (the session budget only; **the default**), or from a
  library (no time). Nothing is inherited or proposed from the lights.
- **The budget** (ADR-009 §2): in-window calibration = Σ count × (exposure + per-frame overhead) over
  `inWindow` blocks; outside-window calibration the same over `outsideWindow` blocks; library blocks
  take none. Calibration never enters integration. E3 (a phone's darks in the window) and E4 (flats and
  bias outside it, darks from a library) are the reference vectors.
- **RG-11 decided:** classes Phone · DSLR/mirrorless · Astro camera (colour) · Astro camera (mono) ·
  Unknown on the rig; binning offered only for astro cameras and Unknown (a record); ISO for phones and
  cameras, gain for astro cameras; no white balance or focus field; the interval is the per-frame
  overhead. **Handed here:** an astro camera's offset; in-camera long-exposure noise reduction; cooling.

## 3. The workflows, from the sources

### 3.1 Darks
- **FACT:** "Dark frames are made at the same exposure time and ISO/Gain than the subject light frames
  but with the shutter closed", and "should be made at approximately the same temperature as the light
  frames, this is the reason why we make dark frames at the end, or in the middle of the imaging
  session" [primary: Siril, Calibration]. DeepSkyStacker: darks "must be created with the exposure
  time, temperature and ISO speed of the light frames" [primary: DSS FAQ, quoted through a search
  result; the page refused this session's connection].
- **FACT:** calibration software needs binning, gain and offset compatible between the lights and
  their calibration frames, and builds a separate master dark per exposure time [secondary: PixInsight
  WBPP guides, two sources].
- **FACT (uncooled cameras):** DSLRs and uncooled astro cameras drift in temperature, so the lights and
  darks rarely match exactly; Siril recommends dark optimisation, which scales the master dark
  [primary: Siril]. This is why darks are taken during or right after the session (ADR-009 §3's
  "in the window" example for phones). Scaling does not handle amp glow well on some CMOS sensors
  [secondary: AAVSO].
- **FACT (cooled astro cameras):** the sensor is held at a set temperature ("a target temperature can
  be set" [primary: INDI]), which makes a reusable dark library practical [secondary: common practice;
  unverified as a rule] — ADR-009's `library` policy.
- **FACT (in-camera darks):** a DSLR's long-exposure noise reduction takes a dark after each light, and
  "the noise reduction process may take the same amount of time as the exposure" [primary: Canon
  support]. It replaces separate darks for those frames and roughly doubles each light's time.
- **FACT:** a filter is irrelevant to a dark: no light reaches the sensor.

### 3.2 Flats
- **FACT:** flats correct vignetting, dust and pixel-to-pixel sensitivity in the optical train, so the
  train must not change between the lights and the flats: "it is very important to not remove your
  camera from your telescope before taking them (including not changing the focus)" [primary: DSS
  FAQ, quoted through a search result]. Rotation belongs to the same rule [unverified as a quote; it
  follows from the dust pattern].
- **FACT:** the flat's exposure is set by the light source to give a "homogeneous and unsaturated"
  frame, with pixels "below 80%" [primary: Siril]. **It is not the lights' exposure.** AstroPlan gives
  no exposure or target-level guidance (the Stage 7 rules).
- **FACT:** dust on a filter is part of the pattern, so flats are taken per filter [secondary: WBPP
  groups flats by filter; unverified as a primary quote].
- **FACT:** binning, gain and offset are kept compatible with the lights within one calibration run
  [secondary: PixInsight guides]; the gain is usually the lights' [secondary].
- **FACT:** flats need their own dark signal removed: by the bias, by dark flats, or by a synthetic
  offset (Siril accepts "=64*$OFFSET") [primary: Siril].
- **FACT (colour sensors):** Siril's "Equalize CFA" option handles colour-sensor flats [primary]; the
  capture itself does not change.

### 3.3 Bias
- **FACT:** "The bias frame must be taken with the shutter closed and the shortest possible exposure
  time" [primary: Siril]; "The bias frames must be create[d] with the ISO speed of the light frames.
  The temperature is not important" [primary: DSS FAQ, through a search result].
- **FACT:** AstroPlan cannot know a camera's shortest exposure (1/4000 s to 1/8000 s on cameras
  [primary: DSS, through a search result]; other values elsewhere) [unknown per camera].
- **FACT (some CMOS astro cameras):** short exposures behave unstably on some models, and makers and
  users advise dark flats instead of bias for them; newer models calibrate well with bias [secondary:
  ZWO forum statements relayed on AstroBin, Cloudy Nights; model-dependent]. **So bias is optional,
  never "not applicable":** it stays offered for every class (the plan's rule), with dark flats as the
  documented alternative.
- **FACT:** Siril can replace a master bias by a constant offset value [primary], which is a processing
  choice, not a capture one.

### 3.4 Dark flats
- **FACT:** dark flats are darks taken at the flats' exposure and gain or ISO, and replace bias for
  cameras whose short exposures are unreliable [secondary: DSS-related sources, AstroBin; the primary
  DSS page lists "dark flat frames" as a type (through a search result)].
- **FACT:** they match the flats, not the lights; a filter is irrelevant.

### 3.5 Phones [secondary and unverified]
- Darks with the lens covered at the lights' ISO and exposure, flats against an evenly lit screen, as
  for cameras [secondary: smartphone guides]. A phone's DNG records its black level in metadata (the
  DNG `BlackLevel` tag) [unverified for the owner's files], which is what a bias frame measures; whether
  a bias frame adds anything for a phone is [unknown], so bias stays optional.

## 4. The calibration columns of the matrix

Classes (the prompt's four): **inherited** (a required match with the lights, the rig or the camera,
made explicit) · **prefilled and overridable** (a proposal, not a measured fact) · **independent** ·
**not applicable** (not shown; stored values kept). A value marked "inherited" still needs a way to
depart from it (dark optimisation, a library at another exposure); §6 recommends how.

Class abbreviations: **P** phone, **D** DSLR/mirrorless, **AC** astro camera (colour), **AM** astro
camera (mono), **U** unknown.

### 4.1 Darks

| Parameter | P | D | AC | AM | U | Budget effect (ADR-009) | Mismatch warning | Evidence |
| --- | --- | --- | --- | --- | --- | --- | --- | --- |
| Exposure | inherited (a light group's exposure) | inherited | inherited | inherited | inherited | count × (exposure + overhead), on the block's policy's line | yes: a dark exposure that matches no light group | Siril, DSS [primary] |
| Count | independent | independent | independent | independent | independent | as above | — | — |
| ISO | inherited | inherited | — | — | inherited (as the lights' kind) | none | yes | Siril, DSS [primary] |
| Gain | — | — | inherited | inherited | inherited (as the lights' kind) | none | yes | Siril [primary], WBPP [secondary] |
| Offset | — | — | not modelled (§6, O) | not modelled | — | none | — | WBPP [secondary] |
| Binning | not applicable (the rig's mode) | not applicable | inherited | inherited | inherited | none | yes | WBPP [secondary] |
| Filter | not applicable | not applicable | not applicable | not applicable | not applicable | none (no filter change charged) | — | FACT (no light) |
| Sensor temperature | not modelled (§6, T) | not modelled | not modelled | not modelled | not modelled | none | — | Siril [primary] |
| Calibration policy | independent (default outside the window) | independent | independent | independent | independent | selects the line | — | ADR-009 §3 [verified] |

### 4.2 Flats

| Parameter | P | D | AC | AM | U | Budget effect | Mismatch warning | Evidence |
| --- | --- | --- | --- | --- | --- | --- | --- | --- |
| Exposure | independent | independent | independent | independent | independent | count × (exposure + overhead) | — (no target-level guidance) | Siril [primary] |
| Count | independent | independent | independent | independent | independent | as above | — | — |
| ISO | prefilled from the lights | prefilled | — | — | prefilled (the lights' kind) | none | — | secondary |
| Gain | — | — | prefilled from the lights | prefilled | prefilled | none | — | secondary |
| Binning | not applicable | not applicable | inherited | inherited | inherited | none | yes | WBPP [secondary] |
| Filter | inherited (one of the lights' filters; "None" when they have none) | inherited | inherited | inherited | inherited | none (no filter-change overhead: calibration blocks are not light blocks) | yes: a flat filter no light uses, or a light filter without flats | secondary (per filter) |
| Optical train, focus, rotation | a reminder in the help, not a field | reminder | reminder | reminder | reminder | none | — | DSS [primary] |
| Calibration policy | independent (default outside the window) | independent | independent | independent | independent | selects the line | — | ADR-009 §3 |

### 4.3 Bias

| Parameter | P | D | AC | AM | U | Budget effect | Mismatch warning | Evidence |
| --- | --- | --- | --- | --- | --- | --- | --- | --- |
| Offered | optional | optional | optional (dark flats as the alternative) | optional (same) | optional | — | — | §3.3 |
| Exposure | independent ("the shortest your camera allows") | independent | independent | independent | independent | count × (exposure + overhead); the overhead dominates | — | Siril, DSS [primary] |
| Count | independent | independent | independent | independent | independent | as above | — | — |
| ISO / gain | inherited (the lights') | inherited | inherited | inherited | inherited | none | yes | DSS [primary] |
| Binning | not applicable | not applicable | inherited | inherited | inherited | none | yes | WBPP [secondary] |
| Temperature | not applicable ("not important") | not applicable | not applicable | not applicable | not applicable | none | — | DSS [primary] |
| Filter | not applicable | not applicable | not applicable | not applicable | not applicable | none | — | FACT |
| Calibration policy | independent (default outside the window) | independent | independent | independent | independent | selects the line | — | ADR-009 §3 |

### 4.4 Dark flats (a new frame type, if decided: §6, D)

| Parameter | P | D | AC | AM | U | Budget effect | Mismatch warning | Evidence |
| --- | --- | --- | --- | --- | --- | --- | --- | --- |
| Offered | optional | optional | optional | optional | optional | — | — | §3.4 [secondary] |
| Exposure | inherited (a flat block's exposure) | inherited | inherited | inherited | inherited | count × (exposure + overhead) | yes: matches no flat | secondary |
| Count | independent | independent | independent | independent | independent | as above | — | — |
| ISO / gain | inherited (the flats') | inherited | inherited | inherited | inherited | none | yes | secondary |
| Binning | not applicable | not applicable | inherited | inherited | inherited | none | yes | secondary |
| Filter | not applicable | not applicable | not applicable | not applicable | not applicable | none | — | FACT |
| Calibration policy | independent (default outside the window) | independent | independent | independent | independent | selects the line | — | ADR-009 §3 |

**Every cell's budget effect stays inside ADR-009's existing lines** (in-window calibration,
outside-window calibration, library): inherited and prefilled values are stored in the block, so
`CaptureBudgetCalculator` reads them as today. Nothing becomes integration. The one exception is
in-camera noise reduction (§5), which is not a block.

**"A dark needs only a count" (08 §16):** true for the fields the user types, if the inheritance is
built: a dark block would ask for its count and its policy, and show its exposure, ISO or gain and
binning as taken from a light group. It is not true that the other values do not exist; they are
required matches, shown.

## 5. In-camera long-exposure noise reduction and the budget

- **FACT:** each light is followed by a dark of about the same length [primary: Canon], taken inside
  the imaging window. Example (RG-11 §6, D): 30 × 60 s with a 5 s overhead is 1,950 s in AstroPlan
  today, and about 3,750 s with the camera's noise reduction on.
- **FACT:** the time is calibration, not integration: it belongs on the **in-window calibration**
  line. √N and integration are unchanged.
- **Options (N):**
  - N0 — not modelled; the limitation is documented (the assumptions panel says in-camera noise
    reduction is not included);
  - N1 — a switch on the rig (DSLR/mirrorless and Unknown classes only), off by default and listed as
    "not included" when off, as ADR-009 §4 lists its other optional overheads. When on, each light frame
    adds its own exposure to in-window calibration and is placed right after it by the fit. An
    ADR-009 amendment with new vectors;
  - N2 — N1 as a planning preference (global), like ADR-009's other overheads.
- **A check either way:** with the switch on and a separate dark block for the same lights, the plan
  takes darks twice; a warning says so (IMPLEMENTATION OPTION).

## 6. Options and recommendations

**Inheritance (L):**
- L1 — inherited values are copied when the block is created (from the light group the user picks,
  the first by default), shown with their origin, and kept; a domain check warns when a calibration
  block matches no light group, with a one-tap "match the lights" fix;
- L2 — the block links to a light group and follows it (a stored reference; a light edit updates the
  darks);
- L3 — nothing is inherited; values are proposed each time.

**Recommend L1** (IMPLEMENTATION OPTION backed by FACT): the required matches of §4 become visible
without a new reference between blocks; the budget reads stored values as today; S6.V1's lesson (a
restored or reordered block must not change meaning) argues against a link. L2 automates more but adds
a reference that deletions, reorders, Undo and Copy must all keep valid. L3 does not answer 08 §16.

**Departing from an inherited value:** "Use other values" makes the field independent for that block
(dark optimisation, a library at another exposure), and the mismatch warning then stays visible, in
words. OWNER PREFERENCE on the wording only.

**Dark flats (D):** D1 — a fifth frame type, "Dark flat", offered for every class (§4.4); D0 — none
(users add a dark at the flats' exposure, which the check would flag as matching no light). **Recommend
D1** (FACT: a documented workflow with its own match rule; D0 would make a correct plan look wrong).
The frame type is stored as text, so no column changes, but the export, the snapshot readers and the
filters must accept it.

**Sensor temperature (T):** T0 — not modelled; T1 — an optional set-point record for astro cameras
(a plan or block field; the classes have no cooled flag). **Recommend T0** (FACT: matching happens in
the capture software and the dark library, which AstroPlan does not manage; temperature feeds no
calculation; the help says darks match the lights' temperature).

**Offset (O):** O0 — not modelled; O1 — an optional offset beside the gain for astro cameras,
inherited like the gain. **Recommend O0** for the same reason as T0; the gain alone is enough to find
the matching light group in a plan. OWNER PREFERENCE if the owner wants the record.

**Bias per class:** optional for every class; never removed; for astro cameras the help names dark
flats as the documented alternative (FACT, §3.3). Not a choice to decide, recorded here as the rule.

**In-camera noise reduction (N):** **recommend N1** (FACT: a primary source; the error is material
for the fit, AstroPlan's central answer; it is a camera setting, so it belongs with the rig, and only
the classes that have it show it). N0 keeps a known optimistic error; N2 is simpler but charges it to a
phone or astro rig in the same plan list.

**Help (H):** H1 — a one-line tip per frame type in the block editor ("Darks: lens covered, same
exposure, ISO or gain and binning as your lights, at the same temperature"), with more one tap away,
and "Hide tips" remembered; H2 — tips hidden until asked. **Recommend H1**: the tip is where the
decision is made, and hiding it is one tap (08 §16: "allow these tips to be disabled"). A mismatch
warning or a validation is never hidden by either.

**Candidate tips** (one line each; the detail one tap away):
- Dark: "Lens or scope covered; the same exposure, ISO or gain and binning as the lights, at a similar
  temperature."
- Flat: "Evenly lit, not saturated; same focus, camera position and filter as the lights."
- Bias: "Covered, the shortest exposure; the same ISO or gain as the lights."
- Dark flat: "Covered; the same exposure and ISO or gain as your flats."

## 7. Effect on S7.3 (and the split rule)

- L1 and D1 need no schema change (frame types are text; the policy exists); S7.3 adds the domain
  match check, the prefill, the help and the block editor's calibration fields per §4.
- N1 adds a rig field (a schema change) and an ADR-009 amendment with vectors computed independently:
  by the plan's rule it is its own Task, after the class on the rig (both touch the rig).
- T1 or O1, if chosen, add block fields (a schema change).

## 8. Unknowns

- Which astro-camera models need dark flats instead of bias [model-dependent; secondary only].
- Whether phones' DNG black level makes a bias frame redundant [unknown].
- Whether phones or mirrorless cameras other than Canon's apply in-camera dark subtraction, and how
  long it takes on each [unverified]; N1's switch is the user's statement, not an inference.
- The DSS FAQ's exact wording was read through a search result only (the site refused the
  connection); the Siril statements were read directly.

## 9. What becomes frozen after the decision

In ADR-020 (S7.D): the calibration columns of §4 with the decided options; the inheritance mechanism;
the match checks and their words; the frame types; the help and its default; and, if N1 or N2, the
ADR-009 amendment with its vectors.

## 10. The owner's questions (RG-10)

1. **Inheritance:** L1 (copied when created, with a mismatch warning and a one-tap fix; recommended),
   L2 (a live link to the lights) or L3 (proposals only)?
2. **Dark flats:** D1 (a new frame type, optional for every class; recommended) or D0?
3. **Sensor temperature:** T0 (not modelled; recommended) or T1 (an optional set-point record)?
4. **Offset:** O0 (not modelled; recommended) or O1 (an optional record beside the gain)?
5. **In-camera noise reduction:** N1 (a switch on DSLR/mirrorless and Unknown rigs, off by default,
   counted as in-window calibration; recommended), N2 (a global preference) or N0 (not modelled,
   documented)?
6. **Tips:** H1 (a one-line tip per frame type, hideable; recommended) or H2 (hidden until asked)?

Not asked (facts from the sources): which values darks, flats, bias and dark flats match (§4); bias
stays optional for every class; flats' exposure is independent, with no target-level guidance.

## Sources (read 2026-09-29)

**Primary**
- Siril documentation, "Calibration":
  https://siril.readthedocs.io/en/stable/preprocessing/calibration.html
- DeepSkyStacker FAQ: http://deepskystacker.free.fr/english/faq.htm (quoted through a search result;
  the site refused this session's connection)
- Canon support, "Long Exposure Noise Reduction (EOS 5D Mark III)":
  https://support.usa.canon.com/kb/s/article/ART136863 (through a search result)
- INDI, ZWO ASI driver: http://drivers.indilib.org/cameras/zwo/asi-ccd/asi-ccd/

**Secondary**
- PixInsight WeightedBatchPreprocessing guides:
  https://starfieldview.com/imaging-and-processing/weightedbatchpreprocessing-script-in-pixinsight/,
  https://chaoticnebula.com/pixinsight-weighted-batch-preprocessing-script/
- AAVSO, "Bias frames and CMOS cameras (scaled and unscaled darks)":
  https://www.aavso.org/bias-frames-and-cmos-cameras-scaled-and-unscaled-darks
- AstroBin, "Which calibration frames to use on CMOS and WHY?":
  https://www.astrobin.com/forum/post/31629/
- Cloudy Nights, "DSS Dark Flat Frame question":
  https://www.cloudynights.com/forums/topic/288273-dss-dark-flat-frame-question/
- BBC Sky at Night, dark frames with a DSLR:
  https://www.skyatnightmagazine.com/astrophotography/astrophoto-tips/reducing-noise-in-dslr-images-via-dark-frame-subtraction
