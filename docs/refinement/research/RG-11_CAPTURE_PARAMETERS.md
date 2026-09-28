# RG-11 — Capture Parameters (S7.R1)

> **Status:** research, documentation only. Written 2026-09-29 at `main` @ `6c98b54` by the S7.R1
> session (`refinement/POST_ROADMAP_PLAN.md`, "Stage 7 — frozen Task sequence", S7.R1). No
> application code, test, asset or dependency changed, and no third-party data is committed.
>
> **Nothing is decided here.** Section 11 lists the owner's questions for RG-11. The answers go into
> DECISIONS E.1, and S7.D records them, with RG-10's, as ADR-020.

Evidence labels:
- **[verified]** read in the repository in this session;
- **[primary]** read today (2026-09-29) in a maker's manual, an API reference, a format specification,
  or the documentation of the software that takes the frames;
- **[secondary]** read today in a tutorial, a vendor article or a forum; used only where no primary
  source was found, and never alone for a claim a decision rests on;
- **[unverified]** believed, but no source was read; **[unknown]**.

Each conclusion is tagged **FACT**, **OWNER PREFERENCE** or **IMPLEMENTATION OPTION** (the Stage 7
rules).

## 1. The question

Which capture parameters matter to a light block for each supported camera class; which feed a
calculation and which are records only; who owns each (the rig, the plan or the block); how each is
labelled; and how the form can know which apply (RG-11, §7 of the plan). Tracking's ownership is
already decided (RD-08 = T3) and is only recorded here. The calibration frames are S7.R2's (RG-10).

## 2. What the repository has today [verified]

- **The block** (`CaptureBlock`): frame type, filter (lights and flats; a fixed list L, R, G, B, Ha,
  OIII, SII, OSC, None), exposure (s, (0, 3600]), count, binning (1–4), `CaptureGain` (ISO, camera
  gain or not recorded), calibration policy (calibration frames only). The dialog shows every field on
  every block; binning is a dropdown on each.
- **What reads them:**
  - exposure and count: the budget (CALC-25), the fit (CALC-26), √N per (filter, exposure) group
    (CALC-15/42), and the capability warning against the recommended maximum sub (CALC-31);
  - the filter: √N grouping and the filter-change overhead (ADR-009 §4);
  - **gain or ISO: nothing** (SI-004; "for your records", RD-03);
  - **binning: nothing.** Storage ignores it (ADR-009 L6). The pixel scale (`206.265 × pitch / f`)
    and NPF read the rig's `pixelPitchUm`, never the block.
- **The interval:** one global preference, "Per-frame overhead" (default 5 s; Settings: "Download or
  interval time added to every frame"), added to every acquired frame (ADR-009 §4). ADR-009 L1 notes
  it is pessimistic for phones (about 1 s). Dither, refocus, filter change, meridian flip and setup
  are separate, optional overheads, off by default.
- **No camera class** exists in the model, the schema or the import. **No white balance, focus,
  offset, readout mode, sensor temperature or in-camera noise reduction** is modelled.
- **Metadata** (ADR-017 §2) reads the exposure time and the sensitivity (ISO with its kind) from DNG,
  JPEG and HEIC; not white balance, binning, an interval or a temperature. ADR-018 §4: exposure and
  sensitivity never map to equipment. FITS is not read.
- **The phone** (RG-02 §3.2, §5): the owner's phone writes a 12.6 MP DNG from what public
  descriptions call a 50 MP sensor, so its default mode is probably 2 × 2 binned [unverified]; RG-02
  already treats each module × mode as its own flat rig, and CALC-40's pitch is "the pitch of the
  output mode" (ADR-018 §4).
- **The seed** is a ZWO ASI2600MC, a colour astro camera, verified against ZWO's page
  (`equipment_seeder.dart`).

## 3. Camera classes

`PRODUCT_DIRECTION.md` §2 names the users: a DSLR, mirrorless or astro camera on a tracker or a simple
mount, or a phone on a tripod, without a laptop automation stack. The evidence gives four classes
whose controls differ, plus "unknown".

| Class | How exposures are set | Sensitivity control | Binning | White balance | Focus | Between frames |
| --- | --- | --- | --- | --- | --- | --- |
| **Phone** | The camera app's manual ("Pro") mode, or a third-party app; the maximum exposure is the device's [secondary: about 30 s in common apps] | ISO: Android's `SENSOR_SENSITIVITY` is "the amount of gain applied to sensor data before processing", in ISO 12232 terms, with a separate maximum *analog* sensitivity [primary: Android `CaptureRequest`, `CameraCharacteristics`] | **A sensor mode, not a per-shot setting:** Android switches between a default mode and a maximum-resolution mode (`SENSOR_PIXEL_MODE`) [primary]; the output pixel count belongs to the mode, hence to the rig (RG-02 §5) | A capture setting (`CONTROL_AWB_MODE`) [primary]; in a DNG it is metadata (below) | Manual focus distance in diopters from the lens's front surface, possibly uncalibrated [primary: `LENS_FOCUS_DISTANCE`, `LENS_INFO_FOCUS_DISTANCE_CALIBRATION`] | The app's own timer or interval, if any [secondary] |
| **DSLR / mirrorless** | Manual exposure; bulb beyond 30 s; the built-in interval timer or an external intervalometer [primary: Canon] | ISO | No user binning of RAW frames found [unverified; reduced-size RAW modes exist on some bodies, and are not binning] | In the RAW file it is metadata (below) | Manual (live view, a Bahtinov mask) [secondary] | The interval timer: "Interval … [00:00:01]–[99:59:59]"; "shutter speeds longer than the shooting interval will prevent shooting at the specified interval" [primary: Canon EOS R6 manual]. **In-camera long-exposure noise reduction** (below) |
| **Astro camera, colour (OSC)** | Capture software (N.I.N.A., ASIAIR, others): "Take Exposure … exposure time, binning, gain and offset" [primary: N.I.N.A. docs] | **Gain and offset**, in the maker's own units [primary: N.I.N.A.; INDI ASI driver] | Per exposure, in the capture software; CMOS binning is mostly digital ("software") [secondary: ZWO]; binning a colour sensor ignores the Bayer matrix and gives a monochrome result [secondary: ZWO] | Not applied to raw data; colour is calibrated after stacking [primary: Siril] | Manual or motorised (autofocus runs, with triggers on time, temperature, filter change, HFR) [primary: N.I.N.A.] | Download time over USB ("USB bandwidth") [primary: INDI]; ASIAIR's "Interval is a delay between each frame in seconds" [secondary: ASIAIR guide]; N.I.N.A.'s "Wait For Time Span" instruction [primary] |
| **Astro camera, mono** | As above | Gain and offset | As above, without the Bayer loss | Not applicable (no colour on the sensor) | As above | As above |
| **Unknown** | — | Either | — | — | — | — |

**Modifiers, not classes:**
- **Cooled or not** (astro cameras): "a target temperature can be set" [primary: INDI]; N.I.N.A. has
  "Cool Camera" [primary]. It matters to darks (RG-10), not to a light block's form.
- **Readout mode / high-gain mode** (some astro cameras): N.I.N.A. has "Set Readout Mode" [primary].
  Not a planning value; recorded as not modelled.
- **FITS is not a class marker:** capture software can save a DSLR's frames as FITS [unverified], so a
  FITS file would not prove an astro camera even once FITS is readable.

**FACT:** the class decides which sensitivity term applies, whether binning is a per-block choice,
and whether white balance means anything to the data. **FACT:** no metadata AstroPlan can read says
which class a file came from (Make and Model are free text; a DNG comes from phones and cameras
alike), so a class can never be inferred (the Stage 7 rules; ADR-011 §5's spirit).

## 4. The parameters

### 4.1 Exposure and count
- **FACT:** required in every class; the block owns them; they feed the budget, the fit, √N and the
  capability warning. Units: seconds; frames.
- **FACT:** the maximum per class differs (a phone app's limit; bulb on a camera; up to an hour in
  capture software) and is not known to AstroPlan; the rig's own `maxExposureS` (ADR-011 §5) is the
  user's limit and already drives the warning. No change is needed.

### 4.2 ISO or gain (and offset)
- **FACT:** phones and DSLR/mirrorless cameras set ISO; astro cameras set gain and offset in the
  maker's units [primary]. The two are different controls, with no general conversion; AstroPlan must
  not invent one (SI-004).
- **FACT:** neither feeds any AstroPlan calculation, and ISO or gain never collects more light
  (SI-004; `PRODUCT_DIRECTION.md` §6).
- **FACT (purpose):** the recorded value is what darks and bias must match (dark frames "at the same
  exposure length, ISO and ambient temperature as the light frames" [secondary: Sky at Night]; RG-10
  will verify per class). So the record has a real use: S7.R2's inheritance.
- **FACT:** offset exists only on astro cameras; whether it must be recorded depends on whether
  calibration must match it (RG-10).
- **When shown:** ISO for phones and DSLR/mirrorless; gain for astro cameras; **both never on one
  block**; for an unknown class, the neutral choice of today ("Not recorded · ISO · Camera gain").
  **Neither is required** (a record).
- **Metadata:** a sample frame's ISO is already readable (ADR-017); a gain is not (FITS).

### 4.3 Binning
- **FACT:** on astro cameras binning is chosen per exposure in the capture software [primary:
  N.I.N.A.], mostly as digital binning on CMOS [secondary: ZWO]. It halves the pixel count per side at
  2 × 2 and doubles the effective pixel size ("3.76 µm becomes 7.52 µm"), and "file sizes shrink
  proportionally" [secondary: ZWO]. On a colour camera it drops the colour information [secondary:
  ZWO].
- **FACT:** on phones, binning is a sensor mode that fixes the output pixel count [primary: Android
  `SENSOR_PIXEL_MODE`]; AstroPlan already models a mode as its own rig with its own pitch (RG-02 §5;
  ADR-018 §4). A per-block binning on a phone rig would count the binning twice.
- **FACT:** no user-selectable binning of RAW frames was found for DSLR/mirrorless cameras
  [unverified].
- **FACT:** binning would change three calculations if AstroPlan used it: the pixel scale
  (× bin), NPF's pixel term (the effective pitch), and storage (÷ bin², approximately). Today none of
  them reads it (ADR-009 L6 says so for storage; the capability summary uses the rig's pitch). Using it
  would be a formula-input change: a DECISIONS entry, and a per-block capability instead of a per-rig
  one.
- **Metadata:** EXIF has no binning; FITS's `XBINNING` is not readable [documented, RG-01].
- **Conclusion (FACT):** binning is meaningful and user-controlled only for astro cameras; it is not
  applicable per block for phones (a rig property) or for DSLR/mirrorless cameras.

### 4.4 White balance
- **FACT:** in a DNG, white balance is metadata: `AsShotNeutral` "specifies the selected white
  balance at time of capture" and tells the developing software the gains; the raw values are not
  rebalanced on most cameras [primary: DNG specification 1.6; secondary: Adobe community,
  Megapixels]. Astro-processing software uses no white-balance information from raw camera data and
  calibrates colour photometrically after stacking [primary: Siril documentation].
- **FACT:** in a JPEG or HEIC, white balance is applied to the pixels. A JPEG-only capture is the one
  case where it changes the data. It never changes time, frames or storage.
- **FACT:** it feeds no AstroPlan calculation and has no planning consequence; it is not in the
  metadata contract.
- **Owner context:** 08 §15 lists WB among the owner's intended controls (a phone workflow). That is
  an OWNER PREFERENCE to weigh, not evidence of a planning use.

### 4.5 Focus
- **FACT:** focus is achieved at the telescope or the phone, by hand (live view, a Bahtinov mask
  [secondary]) or by a motorised autofocus run; capture software triggers refocusing on time,
  temperature change, filter change or a rising HFR [primary: N.I.N.A. triggers].
- **FACT:** a phone's manual focus distance is in diopters from the lens's front surface, and may be
  uncalibrated [primary: Android]; a DSLR lens's focus position is not a transferable number. A stored
  "focus" value would not reproduce focus on another night, lens or temperature [unverified as a
  general claim; follows from the calibration note].
- **FACT:** AstroPlan controls no focuser (excluded), and the only planning quantity tied to focus is
  already modelled: ADR-009's periodic refocus overhead (by accumulated time; L3 notes that
  temperature- and filter-triggered refocus are not modelled).
- **Conclusion (FACT):** no planning value exists for focus. 08 §15's slider would record a number
  with no calculation behind it and no reliable meaning between sessions.

### 4.6 The interval between frames
- **FACT — the word means two things:**
  - **a cadence, start to start:** a camera's interval timer; an exposure longer than the interval
    makes the camera skip shots, so fewer frames are taken [primary: Canon EOS R6 manual]. The gap
    after each frame is `interval − exposure`;
  - **a gap after each frame:** ASIAIR's "Interval is a delay between each frame in seconds"
    [secondary: ASIAIR guide]; N.I.N.A.'s "Wait For Time Span" [primary].
- **FACT:** besides a set delay, the time between frames holds the download (astro cameras over USB
  [primary: INDI "USB bandwidth"]) or the camera's processing and buffer write.
- **FACT:** ADR-009's per-frame overhead is exactly this gap ("download or interval gap"), charged
  once per acquired frame; dither, refocus, filter change and the meridian flip are separate events.
  So **the interval is already modelled, once**, as a global value.
- **FACT:** metadata cannot give it from one frame; the capture times of consecutive frames could
  estimate it, but AstroPlan reads one file at a time (batch reading is Stage 8's candidate, ADR-018
  §2).
- **Where it belongs (FACT with a preference):** it depends mostly on the camera and its controller
  (a phone ≈ 1 s per ADR-009 L1; a large astro camera's USB download is longer), then on the user's
  delay for the night. Today's global preference fits a user with one camera; a user with a phone and
  an astro camera would want it per rig (OWNER PREFERENCE).
- **Worked example:** §6.

### 4.7 In-camera long-exposure noise reduction (a finding)
- **FACT:** with Canon's long-exposure noise reduction on, "the noise reduction process may take the
  same amount of time as the exposure" [primary: Canon support, EOS 5D Mark III]: the camera takes a
  dark frame after each light and subtracts it [secondary: several]. A 30 × 60 s plan then takes about
  twice its exposure time.
- **FACT:** AstroPlan does not model it: the per-frame overhead is a fixed number of seconds, not a
  multiple of the exposure, so a user with it on gets a fit that is far too optimistic.
- **FACT:** it is a dark-frame workflow (in-camera darks), so its budget effect belongs with RG-10;
  RG-11 records it and hands it over. Phones' night modes may do similar processing [unverified].

### 4.8 Filter
- **FACT:** optional for every class; it feeds √N grouping and the filter-change overhead. A mono
  camera normally shoots through a filter; a colour camera and a phone usually do not, but may
  (dual-band or clip-in filters) [secondary]. The fixed list stays as today; its content is not
  RG-11's question.

### 4.9 Tracking (recorded, not reopened)
- Decided: RD-08 = T3, the rig's default with a per-plan override, built by S7.1. It feeds NPF and the
  capability warning (PD-11). Not a block parameter.

## 5. The light column of the parameter matrix

Classes (the register's): **required · optional · known automatically · context-dependent · not
applicable**. "Owner" is where the value lives. "Calc" names what reads it (none = a record).

| Parameter | Phone | DSLR / mirrorless | Astro, colour | Astro, mono | Unknown | Owner | Calc | Label, unit | Evidence |
| --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |
| Exposure | required | required | required | required | required | block | budget, fit, √N, capability warning | "Exposure", s | §4.1 [verified] |
| Count | required | required | required | required | required | block | budget, fit, √N, storage | "Frames" | §4.1 [verified] |
| ISO | optional | optional | not applicable | not applicable | context-dependent (the user's choice) | block | none (SI-004) | "ISO" | §4.2 [primary] |
| Gain | not applicable | not applicable | optional | optional | context-dependent | block | none (SI-004) | "Gain" (the camera's units) | §4.2 [primary] |
| Offset | not applicable | not applicable | optional, if RG-10 needs it | optional, if RG-10 needs it | not applicable | block | none | "Offset" (the camera's units) | §4.2 [primary]; RG-10 |
| Binning | not applicable (the rig's mode) | not applicable | optional (default 1 × 1) | optional (default 1 × 1) | optional | block (rig for phones) | none today; would change pixel scale, NPF, storage | "Binning" | §4.3 [primary + secondary] |
| Filter | optional | optional | optional | optional (usual) | optional | block | √N grouping, filter-change overhead | "Filter" | §4.8 [verified] |
| White balance | not applicable to planning (a capture setting) | not applicable to planning | not applicable | not applicable | not applicable | — | none | — | §4.4 [primary] |
| Focus | not applicable as a value | not applicable as a value | not applicable as a value | not applicable as a value | not applicable | — (the refocus overhead is a preference) | refocus overhead only | — | §4.5 [primary] |
| Interval (time between frames) | known automatically (the preference) | known automatically | known automatically | known automatically | known automatically | preference today (options §9) | budget, fit (per-frame overhead) | "Time between frames", s | §4.6, §6 |
| In-camera noise reduction | unknown [unverified] | context-dependent (a camera setting) | not applicable | not applicable | unknown | — (RG-10) | none today; would change the budget | — | §4.7 [primary] |
| Tracking | decided (T3) | decided | decided | decided | decided | rig default + plan override | NPF, capability | "Tracking for this plan" | RD-08 |
| Calibration policy | not applicable (lights) | not applicable | not applicable | not applicable | not applicable | — | — | — | ADR-009 §3 |

**What this means for the form (FACT, given a class):** a phone or DSLR light block asks for exposure
and count, offers ISO and filter, and shows no binning or gain; an astro-camera light block asks for
exposure and count, offers gain (and offset if decided), binning and filter, and shows no ISO; an
unknown class keeps today's neutral sensitivity choice and binning. White balance and focus appear in
no block. Stored values a class does not show stay stored (the Stage 7 rules).

## 6. The interval against ADR-009 §4: nothing counted twice

**The rule:** the time between two frames is charged once, as the per-frame overhead; a periodic event
(dither and settle, refocus, filter change, flip) is charged only on its own line.

**Example A — a gap (ASIAIR), no dither.** 20 × 120 s lights; the camera downloads in about 2 s
[assumed for the example]; ASIAIR's Interval is 10 s. The time between frames is 2 + 10 = 12 s, so the
per-frame overhead is **12 s**:
- integration = 20 × 120 = 2,400 s;
- acquisition = 20 × (120 + 12) = **2,640 s**.

**Example B — a cadence (camera interval timer).** 30 s exposures, interval timer 35 s (start to
start): the gap is 35 − 30 = **5 s**, so the per-frame overhead is 5 s. If the timer were 30 s or less,
the camera would skip shots [primary: Canon], and fewer frames than planned would be taken: the
planner's frame count would be wrong, not its time.

**Example C — the double count to avoid.** As A, plus dither every 3 frames with 20 s settle, on in
AstroPlan's preferences. Dither events follow frames 3, 6, 9, 12, 15 and 18 (only when another light
follows): 6 × 20 = 120 s, so acquisition = 2,640 + 120 = **2,760 s**. If the user had *also* raised
ASIAIR's Interval to 30 s "to let the guider settle" (the practice [secondary: ASIAIR guide] describes),
the per-frame overhead would be 32 s and the settle would be charged on every frame *and* on every
dither: 20 × 152 + 120 = 3,160 s, of which 400 s is double-counted settle. **The label and help must
say:** the time between frames is download plus any set delay; settling after a dither belongs to the
dither overhead, not both.

**Example D — in-camera noise reduction (§4.7, not modelled today).** 30 × 60 s, per-frame overhead
5 s: AstroPlan says 30 × 65 = 1,950 s; with the camera's noise reduction on, the camera needs about
30 × (60 + 60 + 5) = 3,750 s [primary: "may take the same amount of time as the exposure"]. RG-10
decides whether and how this is modelled.

## 7. Proposals: what the app could prefill

| ID | Proposal | Source | Evidence | Kind |
| --- | --- | --- | --- | --- |
| P1 | A new light block's exposure from the rig's recommended maximum sub | CALC-31 (min(NPF, the rig's maximum) or the rig's maximum) | The guidance exists [verified]; it is a ceiling, not an optimum, and must be labelled so | OWNER PREFERENCE |
| P2 | A new light block copies the previous light block's exposure, sensitivity (kind and value) and binning | The plan | Imagers usually repeat settings across filters [unverified]; no new data | IMPLEMENTATION OPTION |
| P3 | Exposure and ISO from a sample photo | The metadata contract already reads both | ADR-018 §4 keeps them out of equipment; a block is a different target; needs the picker again | OWNER PREFERENCE (a new use of metadata) |

A proposal is shown as a proposal and stored only by the user's Save (the Stage 7 rules). None is
"optimal"; no exposure optimisation is implied.

## 8. How the form can learn the class

| Option | What | Cost | Honesty |
| --- | --- | --- | --- |
| **C1** | A **camera class on the rig**: Phone · DSLR/mirrorless · Astro camera (colour) · Astro camera (mono) · Unknown (default). Chosen by the user in the rig editor; never inferred from a name or a file | A rig field, a migration (existing rigs: Unknown), the editor, the import review (asks, never guesses), the snapshot's rig keys | Unknown stays unknown; the form stays neutral until the user says |
| C2 | No class; the plan's first sensitivity choice (ISO or gain) is proposed to its later blocks | No schema change | Cannot hide binning for phone and DSLR rigs; decides per plan what is a property of the camera |
| C3 | Evidence from metadata where certain, with C1 or C2 as the fallback | Needs a certain signal | No such signal exists today (§3): DNG, JPEG and HEIC come from all classes, and FITS does not prove an astro camera |

**The seed (if C1):** the example rig's camera is a ZWO ASI2600MC, verified against the maker's page;
"Astro camera (colour)" follows from that cited source. Setting it is a seed update with provenance,
not an inference; leaving it Unknown is also honest. OWNER PREFERENCE.

## 9. Options and recommendations

**Class (C):** **recommend C1** (FACT-based: §3 and §5 show the class decides three of the form's
fields, and RG-10 will need it for calibration; C2 cannot express "no binning on a phone"; C3 has no
signal). Cost: one rig field and a migration, which makes S7.2 split per the plan's rule (the class on
the rig first, then the light-block form).

**Binning (B):**
- B1 — shown only for astro-camera classes and Unknown, default 1 × 1, a record;
- B1+ — as B1, and the pixel scale, NPF and storage use it (a formula-input change and a per-block
  capability);
- B2 — on every block, as today;
- B3 — never shown; stored values kept.

**Recommend B1** (FACT: only astro cameras bin per exposure; a phone's binning is its rig's mode).
Keep it out of calculations in Stage 7 (the limitation stays disclosed, ADR-009 L6), because B1+
changes CALC-31's and storage's inputs and makes the capability summary per block; it can be decided
separately if a need is shown.

**White balance (W):** W1 — not modelled; W2 — an optional record for phones and DSLR/mirrorless
cameras, with no calculation. **Recommend W1** (FACT: no planning consequence; RAW data are not
balanced; astro processing ignores it). W2 is harmless if the owner wants it for JPEG-only phone
users (OWNER PREFERENCE, 08 §15).

**Focus (F):** F1 — no field (the refocus overhead stays the only focus concept); F2 — a reminder, with
no value; F3 — a recorded value. **Recommend F1** (FACT: no planning value; a stored position does not
transfer, §4.5). F3 is not supported by the evidence; the slider (08 §15) is not recommended. F2 is a
checklist feature outside the planner's job (an OWNER PREFERENCE; a checklist is not in Stage 7's
areas).

**Interval (I):**
- I1 — the per-frame overhead stays the one interval concept, relabelled "Time between frames" with
  the definition of §6 (download plus any set delay; settle belongs to dither); no budget change;
- I2 — the time between frames per rig (it depends mostly on the camera), falling back to the global
  preference: a rig field and an ADR-009 §4 amendment;
- I3 — per plan (the night's intervalometer setting): a plan field and an amendment;
- I4 — per block: a block field and an amendment.

**Recommend I1** for Stage 7 (FACT: already modelled once; the gap in understanding is the label and
the double count of §6). I2 is the right next step if the owner uses cameras with very different
download times (OWNER PREFERENCE). Settings' layout stays P9.3's; I1 changes only the wording and help
of that one row, as the Stage 7 rules allow.

**Sensitivity (G):** ISO for phones and DSLR/mirrorless, gain for astro cameras, the neutral choice for
Unknown; never both; never required; no conversion (FACT, §4.2). Whether an astro camera's **offset**
is recorded waits for RG-10 (it matters only if darks and bias must match it).

**Proposals (P):** **recommend P2** (the previous light block), an IMPLEMENTATION OPTION with no new
data; P1 only if labelled as a ceiling (OWNER PREFERENCE); P3 not now (a new metadata use, and P2
covers repeated settings).

**Handed to RG-10:** in-camera noise reduction (§4.7) and offset; the cooled modifier.

## 10. Unknowns

- Whether the owner's phone's default mode is binned (RG-02 §3.2) [unverified]; it does not change the
  recommendation, because the mode is the rig either way.
- Whether any supported DSLR/mirrorless body offers true binning of RAW frames [unverified].
- Phones' maximum manual exposure and whether their night modes stack or subtract darks internally
  [unverified]; a phone rig's `maxExposureS` already lets the user state the limit.
- Whether capture software stores DSLR frames as FITS [unverified]; it matters only once FITS is read.
- Real download times per camera [unknown]; they are the user's to measure (ADR-009's "assumption —
  measure your rig").

## 11. The owner's questions (RG-11)

1. **Camera class:** C1 (a class on the rig, Unknown by default, never inferred; recommended), C2 or
   C3? If C1: set the example rig to "Astro camera (colour)" from its cited source, or leave it Unknown?
2. **Binning:** B1 (astro cameras only, a record; recommended), B1+ (also used in the pixel scale, NPF
   and storage), B2 (as today) or B3?
3. **White balance:** W1 (not modelled; recommended) or W2 (an optional record for phones and cameras)?
4. **Focus:** F1 (no field; recommended), F2 (a reminder) or F3 (a value)?
5. **Interval:** I1 (the per-frame overhead relabelled "Time between frames", with the no-double-count
   help; recommended), I2 (per rig), I3 (per plan) or I4 (per block)?
6. **Proposals:** P2 (copy the previous light block; recommended), and P1 and/or P3 as well, or none?

Not asked (decided or handed on): the sensitivity rule (§9, a fact); tracking (RD-08); offset,
in-camera noise reduction and cooling (RG-10, S7.R2).

## 12. What becomes frozen after the decision

In ADR-020 (S7.D): the class rule and the class list; the light column above with the decided rows;
the labels; the interval rule, and an ADR-009 amendment only if I2–I4 is chosen; the proposal rule.
Per the plan's "Order" rule, C1 splits S7.2 into the class on the rig (a schema change) and the
light-block form; I2–I4 would add a budget-input Task.

## Sources (read 2026-09-29)

**Primary**
- Canon, EOS R6 manual, "Interval Timer Shooting":
  https://cam.start.canon/en/C004/manual/html/UG-03_Shooting-1_0220.html
- Canon support, "Long Exposure Noise Reduction (EOS 5D Mark III)":
  https://support.usa.canon.com/kb/s/article/ART136863 (quoted through a search result; the page
  itself was not fetched)
- Nikon, D850 Digitutor, "Interval Timer Shooting":
  https://imaging.nikon.com/imaging/support/digitutor/d850/functions/intervaltimer.html
- N.I.N.A. documentation, advanced sequencer instructions and triggers:
  https://nighttime-imaging.eu/docs/master/site/sequencer/advanced/instructions/,
  https://nighttime-imaging.eu/docs/master/site/sequencer/advanced/triggers/
- INDI, ZWO ASI driver documentation: http://drivers.indilib.org/cameras/zwo/asi-ccd/asi-ccd/
- Android `CaptureRequest` keys (Java documentation mirrored by Microsoft Learn):
  `SENSOR_SENSITIVITY`, `SENSOR_PIXEL_MODE`, `LENS_FOCUS_DISTANCE`,
  https://learn.microsoft.com/en-us/dotnet/api/android.hardware.camera2.capturerequest.sensorsensitivity,
  …sensorpixelmode, …lensfocusdistance; the original:
  https://developer.android.com/reference/android/hardware/camera2/CaptureRequest
- Adobe, Digital Negative (DNG) Specification 1.6.0.0, `AsShotNeutral`:
  https://paulbourke.net/dataformats/dng/dng_spec_1_6_0_0.pdf (a mirror; quoted through a search
  result)
- Siril documentation, colour calibration:
  https://siril.readthedocs.io/en/latest/processing/color-calibration/pcc.html,
  https://siril.readthedocs.io/en/1.2/processing/colors.html

**Secondary**
- ZWO, "Everything you need to know about astrophotography pixel binning" (2020-06-11):
  https://www.zwoastro.com/2020/06/11/everything-you-need-to-know-about-astrophotography-pixel-binning-the-fundamentals/
- ASIAIR guide, "Using Autorun Mode": https://astroguide.starlust.de/html/UsingAutorunMode.html
- AAVSO, "Gain and Offset": https://archive.aavso.org/gain-and-offset
- Megapixels 2.0, DNG white balance: https://blog.brixit.nl/megapixels-2-0-dng-loading-and-whitebalancing/
- BBC Sky at Night, dark frames with a DSLR:
  https://www.skyatnightmagazine.com/astrophotography/astrophoto-tips/reducing-noise-in-dslr-images-via-dark-frame-subtraction
- Smartphone astrophotography guides (manual mode, 30 s limits):
  https://astrobackyard.com/smartphone-astrophotography/,
  https://skiesandscopes.com/samsung-expert-raw-astrophotography/
