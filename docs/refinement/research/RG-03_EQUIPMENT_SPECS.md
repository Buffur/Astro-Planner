# RG-03 — Equipment Specification Sources (S7.R5)

> **Status:** research, documentation only. Written 2026-09-29 at `main` @ `b242846` by the S7.R5
> session (`refinement/POST_ROADMAP_PLAN.md`, "Stage 7 — frozen Task sequence", S7.R5). RG-03 was
> deferred by the owner at S3.D (D2, ADR-018 §8); the owner's Stage 7 planning prompt asked for this
> research. **Nothing is adopted.** Two candidate files (openMVG's sensor CSV and one lensfun XML) were
> downloaded into the session's scratch folder to count and inspect, then deleted; no data is
> committed. No application code, test, asset or dependency changed.
>
> Section 8 lists the owner's questions. The answer goes into DECISIONS E.1 and completes S7.6's
> source path (or leaves it empty).

Evidence labels as in `research/RG-11_CAPTURE_PARAMETERS.md`: **[verified]** the repository, or the
downloaded files inspected in this session; **[primary]** read today (2026-09-29) from the dataset's
own repository or documentation; **[secondary]**; **[unverified]**; **[unknown]**. Conclusions are
tagged **FACT**, **OWNER PREFERENCE** or **IMPLEMENTATION OPTION**.

## 1. The question

RG-03: is a sourced catalog of equipment specifications needed, and which source, if any, is
acceptable under the verified-seed policy (TASK 8.5)? S3.R2's questions stand: coverage of the cameras
AstroPlan's users have (astro cameras, not only consumer cameras), licence against GPL-3.0, provenance
granularity, offline size, update policy, and how a dataset value appears next to a user's entry.

## 2. What the app has today [verified]

- **What a rig needs** (ADR-011; ADR-018 §4, "complete before save"): the sensor size, pixel pitch and
  resolution (the camera), and the focal length and focal ratio (the optics).
- **Where values come from:**
  - the user's typing;
  - "Add from a photo" (DNG, JPEG, HEIC): the resolution, focal length and focal ratio (`reported`),
    the sensor size and pitch from CALC-40 (f₃₅ with the image dimensions; `estimated`), and a DNG's
    file length as the RAW size (`estimated`). Everything is a proposal the user confirms;
  - one verified seed (a ZWO ASI2600MC with an illustrative refractor), citing the maker's page.
- **What metadata cannot give** (RG-02 §4, §5): pixel pitch and sensor size without f₃₅; a camera
  body's specs from a phone-module-style ambiguity; anything for astro cameras until FITS is read
  (S2.6, waiting for a sample). DSLR and mirrorless files often have no f₃₅ [documented, RG-02 §5],
  so CALC-40 cannot run for them.
- **The rules:** no scraping, product pages or links included (`PRODUCT_DIRECTION.md` §6); an external
  value is a proposal with provenance, confirmed by the user, never replacing a `verified` or a user's
  value by default (ADR-018 §6); no specification copied from a "similar" device.

## 3. The sources, by class

### 3.1 Official APIs
- **FACT:** none found for camera specifications from the makers of DSLRs, mirrorless cameras, phones
  or astro cameras [unknown whether private ones exist]. Astro-camera SDKs and drivers report a
  connected camera's pixel size and resolution to capture software (for example the INDI driver's
  controls [primary, RG-11]), which AstroPlan does not connect to (camera control is excluded).

### 3.2 Structured open datasets

| Dataset | Licence | Fields | Coverage (inspected) | Provenance | Update | Verdict |
| --- | --- | --- | --- | --- | --- | --- |
| **openMVG CameraSensorSizeDatabase** (`sensor_database_detailed.csv`) | **MIT** [primary] | maker, model, a sensor description, sensor width and height (mm), width and height (px) [primary] | **3,633 rows** [verified]; consumer cameras up to about 2016 (EOS 5D Mark IV present; **no Canon EOS R mirrorless**; **no ZWO, QHY or other astro cameras; no Xiaomi or Google phones**) [verified]; sizes of small sensors are nominal ("1/2.5" (~ 5.75 x 4.32 mm)") [verified] | Contributed by openMVG and "Gregor Brdnik, the creator of digicamdb.com" [primary]; per-row sources not given | Community pull requests [primary]; no recent release found [unverified] | Wrong population for AstroPlan's users; stale; nominal small-sensor sizes |
| **OpenSfM sensor data** | Simplified BSD [primary] | model → sensor width (mm); a detailed file [primary] | "~3600 digital cameras", from the same origin [primary] | As above | Community | As above |
| **lensfun database** | **CC BY-SA 3.0** for the data (LGPL-3.0 for the library) [primary] | per camera: maker, model (EXIF strings), mount, **crop factor only** [primary: the file format; verified: `slr-canon.xml`] | 102 Canon camera entries in one file, including 38 "EOS R…" lines [verified]; other makers' files not counted; no astro cameras [unverified; not expected] | Community measurements; keyed on the EXIF Make and Model strings by design [primary] | Maintained; an update script exists [primary] | The most current consumer source, but gives only a crop factor (see §4) |
| **open-product-data/digital-cameras** | **not found** [unknown] | not documented on its page [unknown] | "Dating back to 1994" [primary] | "maintained by the community" [primary] | — | Cannot be evaluated without a licence |
| **pixelpitch lists** (for example letmaik/pixelpitch) | — | pixel pitch | Aggregated from retailer and review sites [secondary] | **Derived from scraping** | — | Excluded (the scraping rule applies to what a dataset is made from) |
| **digicamdb.com** | Not an open licence [unverified] | sensor and pixel data | ~3,700 cameras [secondary] | A website | — | Excluded (a website, not a dataset with terms) |

### 3.3 Manufacturers' machine-readable data
- **FACT:** none found. Makers publish HTML product pages (the seed's source is one); extracting from
  them is scraping and is rejected. A person reading a maker's page and citing it (the TASK 8.5 seed
  policy) is not scraping.

### 3.4 Metadata
- **FACT:** already used, under ADR-017 and ADR-018. The next gain is FITS (`XPIXSZ`, `NAXIS1/2`,
  `INSTRUME`), which would give an astro camera's pixel size and resolution from the user's own frame
  [documented, RG-02 §3.3], once a FITS sample exists (S2.6). It is the only path found that covers
  astro cameras with provenance.

### 3.5 Proposals the user confirms
- **FACT:** the import review (S3.6) is already this pattern: a proposal, its provenance, the user's
  confirmation, no silent write. Any adopted dataset would feed the same review, never a separate path.

## 4. What a dataset value would be

- **openMVG/OpenSfM:** a sensor size, and with the pixel count a pitch (sensor width ÷ pixels), for a
  Make and Model match. Provenance `dataset:openmvg` with confidence `reported` at best; small-sensor
  rows are nominal, so `estimated` is more honest for them. A match on the model string is the
  identity problem RG-02 warns about (a phone's modules share a Model; bodies differ by region names).
- **lensfun:** a crop factor. With the file's pixel dimensions, it gives a sensor size and pitch by
  CALC-40's own geometry (diagonal = 43.27 mm ÷ crop), **exactly where DSLR and mirrorless files lack
  f₃₅**. It would be an estimate (`derived:calc-40/lensfun`), shown as such. Its CC BY-SA 3.0 terms
  beside the app's GPL-3.0 and the bundled CC BY-SA 4.0 catalog are RG-12's question (Stage 9)
  [unknown]; CC declared only its 4.0 licence one-way compatible with GPL-3.0 [unverified for 3.0].
- **Body against sensor module:** a dataset row describes a camera body; for phones the rig is a
  module × mode (RG-02 §5), which no dataset inspected describes.

## 5. Offline and size
- openMVG's detailed CSV is 243 KB [verified]; a lensfun camera subset would be small (crop factors
  only) [estimate]. Either would be bundled, generated by a tool like the target catalog, versioned,
  with its notice; nothing would leave the device.

## 6. Options

- **Q1 — no source:** the user, the file's metadata (with CALC-40) and the verified seed, as today; FITS
  when a sample exists (S2.6). Nothing to maintain; unknown values stay unknown.
- **Q2 — more curated seeds:** each seed read by a person from the maker's page and cited (TASK 8.5).
  Fits astro cameras, but a seed is a whole rig (camera and optics) in the flat model (ADR-011 §2), so
  "start from a known camera" would be a new concept close to the deferred composition; and each seed
  must be kept current by hand. OWNER PREFERENCE.
- **Q3a — lensfun crop factors as a CALC-40 input** for DSLR and mirrorless files without f₃₅: an
  estimate shown in the import review, matched on the file's Make and Model; after RG-12 clears CC BY-SA
  3.0.
- **Q3b — openMVG sensor sizes** as proposals: MIT-licensed, but the wrong population (no astro cameras,
  no current phones, no recent mirrorless) and nominal small-sensor sizes.
- **Q4 — an online source:** none with an API and terms was found.

## 7. Recommendation

**Recommend Q1 for Stage 7** (FACT: no dataset found covers astro cameras or current phones, the users
`PRODUCT_DIRECTION.md` §2 names; the one current consumer source gives only a crop factor under terms
RG-12 has not cleared; makers publish no machine-readable data). **Record Q3a as the candidate to
revisit** with RG-12 in Stage 9, or when a DSLR or mirrorless sample shows the gap in practice; and FITS
(S2.6) as the path for astro cameras. Q2 is the owner's preference if a short list of popular astro
cameras matters more than the maintenance.

## 8. The owner's question (RG-03)

1. **A specification source:** Q1 (none for now; lensfun crop factors recorded as the candidate for
   Stage 9 with RG-12; recommended), Q2 (curated, cited seeds for a named list of cameras — which?),
   Q3a now (subject to RG-12), or Q3b?

If Q1: S7.6 has no source path, and RG-03 stays open only as the recorded candidate.

## Sources (read 2026-09-29)

**Primary**
- openMVG, CameraSensorSizeDatabase: https://github.com/openMVG/CameraSensorSizeDatabase (and the
  `sensor_database_detailed.csv` file, inspected, not committed)
- OpenSfM, `sensor_data.readme.txt`:
  https://github.com/mapillary/OpenSfM/blob/main/opensfm/data/sensor_data.readme.txt
- lensfun: https://github.com/lensfun/lensfun; database file format:
  https://lensfun.github.io/manual/v0.3.2/dbformat.html (and `data/db/slr-canon.xml`, inspected, not
  committed)
- open-product-data, digital-cameras: https://github.com/open-product-data/digital-cameras

**Secondary**
- letmaik/pixelpitch: https://github.com/letmaik/pixelpitch
- DigiCamDB (via the search results; not opened)
