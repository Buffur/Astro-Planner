# RG-02 — Metadata → Equipment Identity (S3.R1)

> **Status:** research and planning, documentation only. Written 2026-09-26 at `main` @ `0c4848b`
> by the Stage 3 planning session. The owner's Stage 3 planning prompt asked every S3.R1
> question (identity, a field classification, device classes, matching, provenance and
> confirmation, research gates), so S3.R1 was carried out inside that planning session rather
> than as a separate session. No application code, test or dependency changed. The throwaway
> probe (a Python TIFF walker in the session scratchpad) printed only tag presence and pixel
> counts; it was deleted, and no sample bytes or new sample values are committed.
>
> **Decisions are not made here.** Section 12 lists what the owner decides at S3.D. ADR-018 is
> only outlined (section 11).

Evidence labels: **[verified]** read in the repository or the local samples in this session;
**[documented]** from a committed research note or standard, not re-checked here;
**[unverified]** believed, but no primary source was read; **[unknown]**.

## 1. The Stage 2 foundation, as verified

Stage 2 was closed by an owner waiver after S2.V4/S2.V5, not by a passing independent
validation (DECISIONS E.1, "Stage 2 closed by the owner"). This section checks what it delivered
against the code at `0c4848b`, not against the plans.

**Gate at `0c4848b` (this session):** Encoding, Format, Analyze (no issues), 1068 tests with 1
expected skip (the local real-sample test), 2 host E2E: green. The local real-sample test was run
with `ASTROPLAN_METADATA_SAMPLES` set and passes (section 1.6).

### 1.1 Formats [verified]

| Level (ADR-017 §13) | Formats | Where |
| --- | --- | --- |
| Read (extraction) | DNG (a TIFF with DNGVersion), JPEG (APP1 Exif), HEIF still images (brands `heic`, `heix`, `heim`, `heis`, `mif1`) | `CaptureMetadataReader.readers`: `DngMetadataReader`, `JpegMetadataReader`, `HeifMetadataReader` |
| Recognised only ("not supported yet") | plain TIFF without DNGVersion, AVIF, HEIF image sequences, PNG, FITS, XISF, CR2, CR3, RAF, RW2, ORF | `MetadataFormatRecognizer.fromHeader` |
| Unknown | everything else | `MetadataFormat.unknown` |

NEF and ARW start like a TIFF and have no DNGVersion, so they are recognised as `tiff` and are
unsupported. Real samples exist only for the owner's phone (2 DNG, 1 JPEG, 1 HEIC).

### 1.2 The typed model [verified]

- `CaptureMetadata` (`capture_metadata.dart`) has 11 fields: exposure (s), sensitivity (value
  plus kind; ISO kinds are never converted into gain), focal length (mm), 35 mm equivalent (mm,
  a separate field that is never used as a focal length), f-number, capture time, camera Make,
  Model, UniqueCameraModel, lens Make and lens Model. **There are no image dimensions**, no
  focal-plane resolution and no lens specification (min/max focal length).
- `MetadataReading` is one of `MetadataRead` (with `nothingFound`), `MetadataUnsupported`
  (`recognized` or not) or `MetadataUnreadable` (truncated, corrupt, over budget, I/O). The
  recognised format is carried on each.

### 1.3 Provenance [verified]

- Every value is `KnownValue` (value, raw text, `MetadataOrigin`), `AbsentValue`,
  `UnparseableValue` (raw and origin) or `AmbiguousValue` (all raw candidates).
- `MetadataOrigin` holds the format, the tag (for example `FocalLength (37386)`), the location
  (`IFD0`, `EXIF IFD`, `APP1 …`, `Exif item …`) and a `MetadataProvenance`: `captureDevice`
  (every current value) or `softwareSetting` (reserved for FITS).
- **There is no confidence on a metadata value.** Every value is "reported by the file", never
  a measurement. Confidence (`verified`/`reported`/`estimated`) exists only on stored equipment
  (ADR-008 §6). Stage 3 maps one to the other (section 7).

### 1.4 Bounded access [verified]

- `BudgetedMetadataSource`: 1 MiB per file, 64 KiB per read; the readers never read pixels,
  the GPS IFD, sub-IFDs or MakerNotes; the HEIF `iloc` work is bounded (16,384 extents, TD-067).
- Android reads the picked document in place through `MetadataDocumentChannel.kt` (no cache
  copy; device checks M1–M3 passed on the owner's phone). A non-seekable provider streams from
  the start within the budget; so a HEIC whose Exif item sits at 97 % of a 1.9 MB file is
  `overBudget` there (typed, never partial). That path has not been run on a device (S2V-06).
- `CaptureFile` exposes a name and `open()`; the file length is `MetadataSource.length` once
  opened.

### 1.5 Unknown handling [verified]

- Absent, unparseable and ambiguous values stay unknown; nothing defaults to 0.
- FocalLengthIn35mmFilm 0 is absent (EXIF defines 0 as unknown). A FocalLength or FNumber of 0
  is **unparseable** (the rule is "not positive"). A body with a manual lens often writes 0, so
  the import will see "unreadable value", not "not recorded"; either way it is unknown.
- A capture time without `OffsetTimeOriginal` is zone-unknown and has no UTC instant (the
  phone's DNGs); no zone is inferred.

### 1.6 Real-sample validation [verified]

- `test/data/metadata/real_samples_test.dart` with
  `ASTROPLAN_METADATA_SAMPLES=C:/Users/zalub/AstroPlanSamples/metadata` passes for all four owner
  files. The expected values live beside the samples, outside Git.
- This session's probe also looked at tags outside the contract (section 3.2).

### 1.7 Deferred formats and known limits

- **No reader:** FITS and XISF (no sample; this is what dedicated astro cameras write), PNG,
  AVIF, HEIF sequences, and every proprietary RAW (RG-14: adapters only with a real sample,
  RAF → CR2/NEF/ARW → ORF/RW2 → CR3).
- **Only one device class has real evidence:** a phone. DSLR, mirrorless and astro-camera
  behaviour is **[documented]** or **[unknown]**, not observed.
- **One file at a time;** there is no batch reading.
- The screen is hidden (`FeatureScope.metadataImport == false`; its route and the Settings entry
  are gated) and writes nothing.

### 1.8 Relevant debt and carried items

| Item | State | Stage 3 relevance |
| --- | --- | --- |
| TD-066 | Open | Sub-second exposures print as long decimals. Fix before the screen becomes visible |
| S2V-06 | Open | The non-seekable provider path and a real backup's preview cancel are unverified on a device. A cloud-backed pick may give "over budget" |
| TD-063, TD-057, TD-058, W1 | Open | Planner/session issues; not Stage 3 |
| RG-14 / S2.6 / S2.10 | Waiting for samples | Astro cameras (FITS) and system-camera RAW cannot be imported in Stage 3 without samples |

### 1.8a Discrepancies found

- `PROGRESS.md` cites "The Stage 3 planning commit*" without a hash. It is `0c4848b` (checked with
  `git log`). Recorded in this change.
- **No other discrepancy was found.** The nine planning facts in `POST_ROADMAP_PLAN.md` ("Verified
  at planning") still hold at `0c4848b` (sections 2 and 3). The Stage 2 claims in `PROGRESS.md`
  match the code.

**Verdict:** the foundation is sufficient for Stage 3 **for EXIF-bearing files (DNG, JPEG,
HEIC)**, with two gaps that Stage 3 must handle openly:
- the contract has no image geometry (section 4);
- dedicated astro cameras have no reader.
Stage 2's closure is a waiver, which the owner accepted. Stage 3 does not reopen any Stage 2
decision.

## 2. The equipment model today [verified]

- **Domain:** `EquipmentProfile` is flat (ADR-011 §2). It requires name, sensor width and height
  (mm), pixel pitch (µm), resolution (px), focal length (mm) and focal ratio N. Optional: aperture
  diameter (mm), average RAW size (MB), rotation, tracking type (default `unknown`) and maximum
  exposure. Manufacturer and camera model are optional labels.
- **Storage:** `devices` → `camera_modules` → `optical_rigs`, always created 1:1:1. The sensor,
  resolution and pixel-pitch columns are `NOT NULL`, and so are the focal length and `aperture`
  (= N). `devices.model` exists and is **never written** (the flat model's `cameraModel` goes to
  `camera_modules.model`).
- **Provenance:** per group, not per field. `camera_modules.source/confidence` covers sensor,
  pixels and RAW size; `optical_rigs.source/confidence` covers focal length and aperture.
  `withEditProvenance` marks a changed group `user`/`reported`, and an unchanged group keeps its
  provenance. Manufacturer, model and name carry no provenance.
- **ADR-008 §6 already has a rule for mixed rows:** "A row whose fields have different origins
  gets per-field pairs". It has never been needed for equipment.
- **ADR-011 §4:** entering N alone leaves D unknown, and **D is never back-filled**. ADR-011 §5:
  tracking is never inferred.
- **Editor** (`equipment_selection_screen.dart`, a 15-field dialog): resolution and pixel size are
  typed, and the sensor size is **computed in the widget** as resolution × pixel size (read-only).
  The profile, the aperture resolution and the provenance are built inside the Save button's
  handler. There is no form model to pre-fill from outside.
- **Consumers of the required specs:** `CapabilityCalculator` (FOV, frame fill, pixel scale,
  NPF), `CaptureAnalysisViewModel`, Home's rig card, `SessionSnapshotBuilder` (the rig in every
  session snapshot) and the storage estimate (`averageRawFileSizeMB`, already nullable).
- **One seed:** the ZWO ASI2600MC (verified) plus an example 72 mm f/5.6 optic (estimated).

## 3. What the metadata can say about equipment

### 3.1 Contract fields, classified [verified from code and samples]

Roles: **I** identifies directly · **N** narrows candidates · **P** populates an equipment field
· **S** supporting evidence only · **X** never maps to equipment.

| Field | Role | Why |
| --- | --- | --- |
| Make (271) | N, P (`manufacturer`) | A maker, not a device. Needs trimming and case folding |
| Model (272) | N, P (`cameraModel`) | A **body model**, not a unit. It is format-dependent (DNG `Xiaomi 14T Pro/2407FPN8EG`, JPEG/HEIC `Xiaomi 14T Pro`), identical across a phone's camera modules, and identical across two bodies of the same model (serials are never read, ADR-017 §3). **Never I alone** |
| UniqueCameraModel (50708) | N, S | DNG only; identical across the phone's modules. Useful to confirm "same body model" between DNGs |
| LensMake / LensModel | N, S (a rig-name suggestion) | Identifies a **lens model** on bodies that write it; absent on the phone. Absent or stale with adapted or manual lenses, and with in-camera lens profiles the user set. No `EquipmentProfile` field holds it |
| FocalLength (37386) | P (`focalLengthMm`), N | The focal length of **this frame**: a zoom's setting, a phone module's fixed value, or a user-typed "non-CPU lens" value on some bodies (the file cannot say which). Absent or 0 with a telescope. **Evidence, not an identifier** |
| FocalLengthIn35mmFilm (41989) | N, S (an estimate input, section 4) | Tells phone modules apart (60 vs 23 on the samples). Changes with digital zoom or crop modes while FocalLength stays the same. Never a focal length |
| FNumber (33437) | P (`focalRatio`), N | The aperture **as set for this frame**; on a phone, fixed per module. Absent with a telescope or manual lens |
| ExposureTime, sensitivity | X | Capture settings of one frame (Stage 8 actuals). A frame's exposure is not the rig's maximum exposure |
| DateTimeOriginal / offset | X | Not equipment. May be shown as context ("photographed …") only |

### 3.2 Facts outside the contract (this session's probe) [verified]

| Tag | DNG (both) | JPEG and HEIC (main camera) |
| --- | --- | --- |
| ImageWidth/ImageLength (IFD0) | present: the raw image, 4080 × 3072 (tele) and 4096 × 3072 (main), `NewSubfileType` 0 | present |
| DefaultCropOrigin/Size (DNG) | present | — |
| PixelXDimension/PixelYDimension (EXIF IFD) | — (no EXIF IFD) | present: the **same pixel count as the main DNG, width and height swapped** (a portrait capture) |
| FocalPlaneX/YResolution | **absent** | **absent** |
| LensSpecification (42034) | absent | absent |

Consequences:
- Image dimensions are available in all three formats, but **orientation swaps them**. Sensor
  geometry must use the long and short sides, never "width" as written.
- **Pixel pitch is not in any sample.** The focal-plane tags that could give it are absent.
- Whether 4096 × 3072 (12.6 MP) is the sensor's native pixel count or a binned output is **not
  stated in the files [unknown]**. Public descriptions of this phone give a 50 MP main sensor
  **[unverified: the maker's spec page returned HTTP 403 to this session]**, which would make
  it 2 × 2 binned. Either way, the pixel count of **the images the user takes in that mode** is
  what the planner's pixel scale needs.

### 3.3 FITS (no sample; documented only)

`INSTRUME` (camera driver name) would narrow the camera model. `TELESCOP` and `FOCALLEN` are
user-entered in the capture software (`softwareSetting` provenance). `XPIXSZ`/`YPIXSZ` (possibly
already including binning, depending on the software) and `NAXIS1`/`NAXIS2` would populate pixel
size and resolution **[documented, RG-01 §3.3]**. None of this can be claimed without a sample and
an ADR-017 amendment (S2.6).

## 4. Derivability matrix (every `EquipmentProfile` field)

"Contract" = available from the current contract. "Amendment" = needs a new kind of fact in the
contract (ADR-017 §13.3).

| Field | Source | Confidence if imported | Failure cases |
| --- | --- | --- | --- |
| `id` | — | — | — |
| `name` | Suggested from Make + Model (+ lens model or focal length) | a label, no provenance | Always editable |
| `manufacturer` | Make (contract) | label | Absent → empty |
| `cameraModel` | Model (contract) | label | Format-dependent string (§3.1) |
| `sensorWidthMm`, `sensorHeightMm` | **Not in the file.** An estimate: crop = f₃₅ / f; diagonal = 43.27 mm / crop; sides from the aspect ratio of the pixel dimensions (needs the amendment) | `estimated` | No 35 mm equivalent (most dedicated cameras and many bodies); the standard does not say whether the equivalent matches the diagonal or the width (about 4 % apart for a 4:3 sensor); f₃₅ is an integer (±0.5 mm, ±2 % at 23 mm); digital zoom and crop modes change it |
| `pixelPitchUm` | **Not in the file.** Estimate = long side (mm) / long side (px), the **effective** pitch of that output mode | `estimated` (compounds the above) | Binned vs full resolution gives 2× different values for one sensor; cropped modes |
| `resolutionWidthPx`, `resolutionHeightPx` | Image dimensions (amendment); long side as the width | `reported`, for **that capture mode** | Orientation; DNG raw size vs its default crop; a resized JPEG (edited or messenger-compressed files) gives a smaller, wrong size |
| `focalLengthMm` | FocalLength (contract) | `reported` | Absent/0 with a telescope or manual lens; a user-set lens profile; a zoom's momentary value |
| `focalRatio` | FNumber (contract) | `reported` | Absent with a telescope or manual lens; the set aperture, not the lens's maximum |
| `apertureDiameterMm` | **Never.** f / N could be computed, but ADR-011 §4 forbids back-filling D | — | — |
| `averageRawFileSizeMB` | The picked file's length, **only for a RAW (DNG) file** | `estimated` (one sample) | A JPEG/HEIC size is not a RAW size; compression varies; one file is one sample (the samples: 25.07 and 25.17 MB, [documented], RG-01) |
| `rotationDeg` | **Never** (Orientation is display rotation, not rotation on the sky) | — | — |
| `trackingType` | **Never** (ADR-011 §5) | — | — |
| `maxExposureS` | **Never** (a user limit, not one frame's exposure) | — | — |
| provenance fields | Written by the import (section 7) | — | — |

**Worked estimate** from committed sample values (RG-01), for illustration only:
- main camera: f = 6.57 mm, f₃₅ = 23, 4096 × 3072 → crop 3.50, diagonal 12.4 mm, sensor about
  9.9 × 7.4 mm, effective pitch about 2.4 µm (width-matched convention: 10.3 mm, 2.5 µm);
- telephoto: f = 8.8 mm, f₃₅ = 60, 4080 × 3072 → crop 6.8, diagonal 6.3 mm, sensor about 5.1 ×
  3.8 mm, effective pitch about 1.24 µm.

The estimate is plausible for FOV planning (a few per cent). It is still an estimate, and it
exists only for devices that write the 35 mm equivalent (phones and most compacts). **Whether to
offer it at all is an owner decision (D1).** It would be a new calculation (CALC-40) with its
assumptions in `SCIENTIFIC_INTEGRITY.md`.

## 5. Device classes

| Class | What metadata gives | What the user must add | Identity pitfalls |
| --- | --- | --- | --- |
| **Phone, several modules** | Make, Model; per module: f, N, f₃₅, pixel dimensions; no lens fields | Sensor and pixel size (or accept the estimate); tracking | Modules share Make/Model/UniqueCameraModel; the Model string differs by format; binned vs 50 MP modes and digital zoom change f₃₅ and dimensions for one module. **Each module × mode is a separate flat rig**; the tuple (f, N, f₃₅) separates the modules on the samples, but it is evidence, not an identifier |
| **DSLR/mirrorless, electronic lens** | Make, Model (the body); LensModel; f and N as set; pixel dimensions; often no f₃₅ | Sensor size and pixel size (the body's specs); tracking | Two bodies of one model are indistinguishable (no serials). A zoom gives a different f per frame → a rig per focal length used. Several lenses on one body = several flat rigs that repeat the camera specs (composition deferred, ADR-011 §2) |
| **DSLR/mirrorless on a telescope or a manual lens** | Make, Model, pixel dimensions; f and N absent, 0 or user-set in the body | Focal length and N from the telescope's specs; sensor/pixel; tracking | A body-menu lens profile writes a plausible but user-typed f, which the file reports as the device's own. Always shown for confirmation |
| **Dedicated astro camera** | Nothing in Stage 3: FITS/XISF have no reader | Everything (manual editor) | Waits for a FITS sample (S2.6). The FITS focal length would be a software setting, not hardware |
| **Proprietary RAW** | Nothing: recognised only (RG-14) | Everything | Waits for samples |

## 6. Matching, duplicates and conflicts

Matching is deterministic rules with stated reasons, never a score (the product's no-black-box
rule). Proposed outcomes:

| Outcome | Rule (sketch) | What the user sees |
| --- | --- | --- |
| **Same rig** | Normalised Make and Model equal, and f and N equal within a tolerance, and no other evidence differs (f₃₅, dimensions where stored) | "You already have this rig: <name>". Open it; no duplicate is created. Unknown optional fields may be offered for filling (for example the RAW size) |
| **Likely the same rig** | As above, but the models match only by the prefix rule (one model string is the other plus a separator and a suffix), or Make/Model are missing on the saved rig | The same, labelled "likely", with the differing strings shown |
| **Same camera, other optics** | Camera identity matches; f or N differ (another phone module, another lens or focal length) | "New rig for <camera>", with the saved rig's **camera specs offered** as a pre-fill (copied with their own provenance; not composition) |
| **Cropped or binned mode** | f and N match a saved rig, but f₃₅ or the pixel dimensions differ | "Same lens, different field of view or resolution". Never merged silently: a new rig, or the saved one unchanged |
| **Ambiguous** | Several saved rigs qualify (two identical bodies, or the user's duplicates) | The user chooses; nothing is chosen automatically |
| **No match** | — | "New rig" |

**Conflicts** (a match whose saved value differs from the imported value):
- they are shown side by side, with both values' provenance;
- **nothing is overwritten by default**, and a `verified` value is never replaced by a `reported`
  one without an explicit choice;
- the user picks, for each field: keep the saved value (the default), take the imported value
  (its provenance becomes the metadata source), or create a new rig instead;
- legacy rows (provenance NULL) are treated like user values;
- ambiguous or unparseable metadata values are never offered as replacements.

**Normalisation** (for comparison only; raw strings are kept): trim, collapse whitespace, case-fold;
Make equality ignores common corporate suffixes only if the ADR lists them explicitly (no
maker-specific hacks). **Tolerance** for f and N: a documented constant (proposed 1 %, enough for
a user's rounded "6.6" against 6.57), an assumption and not a physical law.

## 7. Provenance and confirmation

- **Source ids** (ADR-008 §6 style): `metadata:dng`, `metadata:jpeg`, `metadata:heif`; the
  tag/location go into the per-field origin. A derived estimate: `derived:calc-40(metadata:jpeg)`.
  A value copied from a saved rig keeps that rig's source.
- **Confidence:** a file value is `reported` (the device wrote it; nothing checked it). A
  derivation is `estimated`. **Never `verified`.** A user's edit becomes `user`/`reported`, as
  today.
- **Granularity:** an imported rig mixes origins in one group (resolution from the file,
  sensor/pitch estimated or typed, RAW size from the file length). Per-group provenance cannot say
  so, and ADR-008 §6 already prescribes per-field pairs for mixed rows. Proposed: per-field pairs
  for resolution, pixel pitch, sensor size, RAW size, focal length and focal ratio. A field
  without its own pair falls back to the group columns, then unknown, so legacy rows keep their
  meaning. Schema v18, additive.
- **Identity evidence:** store the normalised metadata identity (Make, Model, UniqueCameraModel;
  never serials) on the camera module, so a later import matches even after the user renames the
  labels. Proposed as a nullable column (the unused `devices.model` could hold the raw Model, but
  a dedicated column is clearer).
- **Confirmation:**
  - the reading becomes a candidate in memory only;
  - the review lists every proposed field with value, unit, source and confidence, and every
    unknown field with its reason;
  - the user edits, clears or accepts each field in the rig editor, pre-filled;
  - **nothing is written until Save**; Cancel writes nothing; there is no background or
    automatic write;
  - an edited field becomes `user`.

## 8. Storing unknown specifications (the central question)

The planning finding stands: the required specs are `NOT NULL`, and a phone file gives no sensor
or pixel size.

| Option | What it means | Cost | Planner effect |
| --- | --- | --- | --- |
| **A. Complete before saving** | The candidate pre-fills the editor; a rig is stored only when every required spec has a value from the file, an estimate the user accepted, the user's typing or a saved rig | No nullability change; per-field provenance (§7) | None: every stored rig stays complete |
| **A1.** A + the §4 estimate offered | Phones get a complete rig in one confirmation, with `estimated` sensor values | + contract amendment (image geometry) + CALC-40 | None |
| **A2.** A without the estimate | The user types sensor and pixel size (unknown to most phone users) | + contract amendment for resolution only | None |
| **B. Nullable specs** | A rig may be stored with unknown sensor, pixel or resolution | Schema v18 relaxing five columns; every consumer (capability, FOV, NPF, frame fill, Home card, snapshots, the manual editor) handles unknown | Large, cross-cutting; overlaps Stage 6/7; L–XL |
| **C. A candidate store** | Unconfirmed candidates persisted for later | A new table; persisting unconfirmed metadata | None, but adds a stored "pending" state with little gain |

**Recommendation: A1.** It keeps "unknown stays unknown" (an estimate is stored only when the
user accepts it, labelled `estimated`), gives the owner's own device class a real benefit, keeps
the planner untouched, and leaves B for later if the owner wants rigs with unknown FOV.

## 9. Visibility, RAW size and a specification source

- **RD-16 (visibility):** recommended visible **only when the confirm flow exists** (the last
  implementation Task), with one entry point next to "Add" on the equipment screen ("Add from a
  photo"). The read-only viewer in Settings goes away or stays hidden. Stage 4 may move the entry
  point. TD-066 is fixed before it becomes visible.
- **C-13 (average RAW size):** recommended, from a **DNG** (RAW) pick only, `estimated`, labelled
  "from one file", offered in the review and never overwriting a user's value. A JPEG/HEIC size is
  never used.
- **RG-03 (a specification source):** under A1 a phone needs none, and a DSLR or astro-camera user
  types the body's specs as today. **Recommended: defer S3.R2** (no source in Stage 3). Nothing
  leaves the device, and privacy and Data Safety do not change.

## 10. Unknowns

| Unknown | Effect | Resolves it |
| --- | --- | --- |
| Which cameras and optics the owner uses besides the phone | Which classes Stage 3 can check on real files | The owner's answer; samples |
| DSLR/mirrorless files (Make/Model/LensModel forms, f₃₅ presence, dimensions) | Class 2 and 3 rules rest on synthetic fixtures only | A sample JPEG from such a body (the JPEG reader already reads it) |
| Whether the 35 mm equivalent follows the diagonal or the width for a given maker | Up to about 4 % in the estimate | Accepted as the estimate's stated uncertainty, or a primary sensor spec per device |
| The phone's native vs binned pixel count | Only the explanatory text, not the effective pitch | A primary source; not needed for the rule |
| Non-seekable (cloud) providers on a device | An import may fail as "over budget" | S2V-06's device check |

## 11. Proposed ADR-018 outline (for S3.D)

1. Context: this note; the facts in §1–§3.
2. Flow: reading → `EquipmentEvidence` (level 3 of ADR-017 §13) → `EquipmentCandidate` (per-field
   value, source, confidence, reason) → match (§6) → review → pre-filled editor → user Save →
   repository. Pure domain up to the review; one write on Save.
3. The contract amendment: image dimensions (long/short side; DNG raw size vs default crop decided
   there), per ADR-017 §13.3, with synthetic fixtures and the local samples.
4. Derivations: none, or CALC-40 (option A1), with its uncertainty stated.
5. Storage: option A (complete before saving); per-field provenance and identity evidence (schema
   v18, additive), amending ADR-008 §6's equipment application; ADR-011 unchanged (flat profile,
   D never back-filled, tracking never inferred).
6. Matching outcomes, normalisation, tolerance, and the conflict rules (§6).
7. Confirmation: nothing written before Save; Cancel writes nothing.
8. Visibility (RD-16) and entry point; privacy (nothing leaves the device).
9. Out of scope: composition, batch import, FITS/RAW, a spec source, assisted actuals, and the
   Stage 7 editor redesign.

## 12. Owner decisions and questions (S3.D)

- **D1 (blocks freezing the Tasks):** how an import handles specs the file cannot give: A1
  (recommended), A2, B or C (§8).
- **D2:** a specification source: defer RG-03/S3.R2 (recommended), or research it now.
- **D3 (RD-16):** visible at the end of Stage 3 through "Add from a photo" (recommended), or kept
  hidden.
- **D4 (C-13):** the RAW size from a DNG pick as an estimate (recommended), or not.
- **Question:** which cameras and optics do you use besides the phone? A JPEG from a DSLR or
  mirrorless body, and a FITS file if you use an astro camera, would let Stage 3 check those
  classes on real files.
