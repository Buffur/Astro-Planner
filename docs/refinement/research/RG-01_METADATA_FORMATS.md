# RG-01 — Image metadata: formats, libraries, file selection, fixtures

> **Task:** S2.R1 (Stage 2, research; documentation only; resolves PD-21 once the owner
> decides). **Date:** 2026-09-26. **Repository:** `main` @ `565341b`. No application code
> changed.
> **Status: evidence complete for what the samples allow. Owner decisions pending** (§9).
> The workflow is `POST_ROADMAP_PLAN.md` §9.6. Facts are marked **[verified]** with their
> evidence, **[unknown]** with what would resolve them, or **[assumption]**.

## 1. Question

Which image-metadata formats does Stage 2 support? How is each read in a bounded way, and
through which library? How does the user select the files on Android? How do real samples
become test fixtures in a public repository? And which semantics and units does each field
carry?

## 2. Current constraints

- **Header-only, bounded reads.** No whole-file reads, and file I/O in the data layer
  (TD-018; Stage 2 candidate work).
- **Honest values.** Unknown stays unknown; no default is invented for a missing value. Units
  are explicit, and each value carries its provenance (ADR-008 §6).
- **Nothing is persisted in Stage 2.** No write to Equipment or sessions (Stage 3, Stage 8).
- **Privacy.** Nothing leaves the device. The remote `github.com/Buffur/Astro-Planner` is
  public, so anything committed is published.
- **Licences.** The app is GPL-3.0 (PD-12). Dependencies need compatible licences.

## 3. Evidence

### 3.1 The owner's samples

Two files were supplied on 2026-09-26. They stay **outside the repository**, in the owner's
Downloads folder:

- `IMG_20260924_233845.dng`, 25,074,220 bytes;
- `IMG_20260924_233923.dng`, 25,172,524 bytes.

They were inspected with a throwaway TIFF walker (Python, in the session scratchpad, which
prints no private values) and with the `exif` 3.3.0 package (throwaway `tool/zz_probe_*.dart`
scripts, deleted afterwards).

| | `…233845.dng` | `…233923.dng` |
| --- | --- | --- |
| Container | TIFF, little-endian, magic 42, one IFD (IFD0) | same |
| DNG version | 1.4.0.0 | 1.4.0.0 |
| Make / Model | `Xiaomi` / `Xiaomi 14T Pro/2407FPN8EG` | **identical** |
| UniqueCameraModel | `2407FPN8EG-Xiaomi-Xiaomi` | **identical** |
| Software | the MIUI/HyperOS build string | same |
| ExposureTime | 3750000000/125000000 = **30 s** | 30 s |
| FNumber | 200/100 = f/2.0 | 160/100 = f/1.6 |
| ISOSpeedRatings (34855) | 50 (no SensitivityType tag) | 50 |
| FocalLength | 880/100 = **8.8 mm** | 657/100 = **6.57 mm** |
| FocalLengthIn35mmFilm | **60** | **23** |
| Which camera | telephoto (60 mm equivalent) | main (23 mm equivalent) |
| Image size | 4080 × 3072, CFA, 16 bits/sample, uncompressed | 4096 × 3072 |
| White level | 1023 (10-bit data) | 16383 (14-bit data) |
| DateTimeOriginal | `2026:09:24 23:38:46` | `2026:09:24 23:39:23` |
| OffsetTimeOriginal, SubSecTime | **absent** | absent |
| EXIF IFD (34665), GPS IFD (34853) | **absent** | absent |
| Serial numbers, unique image IDs | absent. Copyright is present but empty (1 byte) | same |
| LensModel / LensMake | absent | absent |
| Where the metadata ends | byte **6,700** (0.03 % of the file). The pixels run from 6,700 to the end | same |

Findings from the samples **[verified]**:

1. **Everything needed sits in the first 6.7 KB.** The capture fields are directly in IFD0
   (the TIFF/EP style DNG allows), not in an EXIF sub-IFD. A bounded read reaches all of it.
2. **`exif` reads the files correctly from a prefix alone.** `readExifFromBytes` on only the
   first 4,096, 8,192 or 65,536 bytes returns the same 60 tags and identical values as a
   whole-file read.
3. **The current prototype finds none of the capture fields in these files.** `exif` names
   IFD0 tags `Image ExposureTime`, `Image FNumber` and so on. `metadata_extractor.dart:31–45`
   looks only for `EXIF …` keys: 0 of 5 found in either file (probe output). Only Make and
   Model would appear. This is a real-sample defect beyond TD-018 (recorded as TD-064).
4. **The two cameras of one phone are indistinguishable by Make, Model or
   UniqueCameraModel.** Only the focal length, f-number, 35 mm-equivalent focal length, image
   width and CFA phase differ. This is input for RG-02 (Stage 3): a phone's "camera" is not
   identified by its model string.
5. **The capture time is local wall-clock time with no offset.** The zone is unknown from the
   file itself, which matches the "zone unknown" requirement.
6. **Phone sensitivity:** ISO 50 at 30 s, with no SensitivityType, so the kind of ISO value
   (standard output sensitivity, recommended exposure index, …) is unspecified.
7. **No GPS in these files.** This may be the camera app's setting, or the files may have been
   stripped. **[unknown]** which, because the files went through Telegram, sent as files.

### 3.2 The `exif` package (3.3.0, currently a dependency)

Read from its source in the pub cache **[verified]**:

- **Licence:** MIT (compatible with GPL-3.0). Maintained: 3.3.0 added WebP; the changelog
  shows steady small releases.
- **Formats recognised** (`read_exif.dart`, `readExifFromFileReader`):
  - TIFF by magic `II*\0` / `MM\0*`, which covers DNG, CR2, NEF, ARW and most TIFF-based RAWs;
  - HEIC and AVIF (`ftypheic` / `ftypavif` only);
  - JPEG, PNG and WebP.
  - **Not recognised:** CR3 (ISO-BMFF with a `crx` brand), RAF (`FUJIFILMCCD-RAW`), ORF
    (`IIRO`), RW2 (`IIU\0`), FITS and XISF.
- **API:** only `readExifFromBytes(List<int>)` and `readExifFromFile(File)` are exported.
  - `readExifFromFile` does random-access reads through a `RandomAccessFile`, so it is
    memory-bounded but needs a real `dart:io` file path.
  - The pluggable `FileReader` interface is under `src/`, not exported, so a byte-budgeted
    source cannot be plugged in without importing private files or vendoring.
- **What it does beyond reading tags:** with `details: true` (the default) it decodes
  MakerNotes (Canon, Nikon, Olympus, Fujifilm, Casio, Apple) and extracts thumbnails. XMP
  parsing is debug-only.
- **Key naming:** it prefixes names by IFD (`Image …`, `EXIF …`, `GPS …`). A reader must look
  in both IFD0 and the EXIF IFD, which the prototype does not (finding 3).

### 3.3 FITS (Standard 4.0, IAU FITS Working Group, 2016-07-22)

Read from the PDF at `fits.gsfc.nasa.gov/standard40/fits_standard40aa-le.pdf` **[verified]**:

- **Structure:** the header is a sequence of 2,880-byte blocks of 36 records, each record 80
  bytes; the header ends with `END`, in the last 2,880-byte block of the header. Only ASCII
  32–126 is allowed.
- **Records:**
  - the keyword name is in bytes 1–8 (§4.1.2.1);
  - the value indicator `= ` is in bytes 9–10 (§4.1.2.2);
  - a record without `= ` in bytes 9–10 has no value. COMMENT, HISTORY and blank records are
    commentary, even when their text contains `=`.
- **Strings:** a string is in single quotes. A literal quote is written as **two successive
  single quotes** (`O''HARA`), and a `/` inside quotes is part of the value. The prototype's
  `split('/')` and quote handling break both.
- **Long strings:** the `CONTINUE` long-string convention is **part of the standard** since 4.0
  (§4.2.1.2): `&` at the end of a substring, continued by `CONTINUE` records.
- **Dates:** `DATE-OBS` defaults to UTC (four-digit years) and "shall be assumed to refer to
  the start of an observation, unless another interpretation is clearly explained in the
  comment field" (§4.4.2.2). `DATE-BEG`, `DATE-AVG` and the net exposure `XPOSURE` exist in
  the time section (§9).
- **Not in the standard:** `EXPTIME` (§9 names `XPOSURE`); `EXPTIME` is a widespread
  convention and appears only as an example. `HIERARCH` does not appear at all; it is an ESO
  convention.
- **Bounded reading:** reading block by block until `END` gives a natural bound. A limit on
  the number of header blocks is still needed against malformed files.

**What capture software writes.** N.I.N.A.'s documentation
(`nighttime-imaging.eu/docs/master/site/advanced/file_formats/fits/`, fetched 2026-09-26)
**[verified as documented; not verified on a file]**:

- `EXPOSURE` and `EXPTIME`: "Exposure duration in seconds";
- `DATE-LOC`: "Locale time at exposure start";
- `DATE-UTC`: "UTC time at exposure start". The page names `DATE-UTC`, not `DATE-OBS`;
  **[unknown]** what the files actually carry, until a sample is read;
- `INSTRUME`: "Name of camera";
- `GAIN` and `OFFSET` (camera settings), and `EGAIN`: "Electrons per A/D unit";
- `XPIXSZ`/`YPIXSZ` and `XBINNING`/`YBINNING`;
- `TELESCOP`, and **`FOCALLEN` and `FOCRATIO` "taken from equipment options"** — values the
  user typed into N.I.N.A., not measured ones;
- `SITELAT`, `SITELONG` and `SITEELEV` (a position — privacy);
- `OBJECT`, `IMAGETYP` and `FILTER`, plus focuser, rotator and weather keywords.

**[unknown]:** what ASIAIR, SharpCap, Seestar, Dwarf and the owner's own tools write. This is
resolved only by samples.

### 3.4 XISF 1.0 (PixInsight)

From `pixinsight.com/doc/docs/XISF-1.0-spec/XISF-1.0-spec.html`, fetched 2026-09-26
**[verified]**:

- **Layout of a monolithic file:**
  - the signature `XISF0100` (8 bytes);
  - the header length as an unsigned 32-bit little-endian integer;
  - 4 reserved zero bytes;
  - then the UTF-8 XML header, starting at byte 16.

  The header is length-prefixed, so it can be read in a bounded way.
- **Embedded FITS keywords** appear as
  `<FITSKeyword name="EXPTIME" value="300" comment="…"/>`.
- **Native properties, whose units differ from the FITS conventions** — a trap:
  - `Instrument:ExposureTime` is in seconds;
  - `Instrument:Telescope:FocalLength` is in **metres**, not mm;
  - `Instrument:Camera:Gain` is in **electrons per data number**, the physical gain, not the
    camera's gain setting that N.I.N.A.'s FITS `GAIN` carries;
  - `Instrument:Camera:ISOSpeed` (Int32), `Instrument:Camera:Name` and
    `Observation:Time:Start` (a TimePoint, UTC).
- **Terms:** "free, open format … anyone shall be able to use or implement XISF freely
  without any monetary cost for any purpose"; the document is © Pleiades Astrophoto.

### 3.5 File selection on Android

Package sources read: `file_picker` 13.1.0 with its federated implementation
`android_file_picker` 2.0.0 **[verified]**. Both are MIT.

- **Every picked file is copied in full** into `cacheDir/file_picker/<timestamp>/<name>`
  before the picker returns (`FileUtils.kt` `openFileStream`, an 8 KB buffered stream, so the
  copy uses disk, not memory). No option skips the copy. The SAF options only add a URI handle
  (`addFile` always calls `openFileStream`).
  - **Consequence:** a 25 MB DNG costs 25 MB of cache and a full sequential read before any
    parsing. Memory stays bounded, and parsing the cached copy can use random access
    (`RandomAccessFile`).
  - **For a later batch import** (Stage 8), 100 frames would copy about 2.5 GB. This needs
    re-evaluation then (for example a small platform channel over
    `ContentResolver.openFileDescriptor`).
- **Cleanup:** `FilePicker.clearTemporaryFiles()` deletes the cache folder. **No code in
  `lib` calls it**, so today's restore file (TASK 14.4) stays in the cache until Android clears
  it (recorded as TD-065).
- **The extension filter is a trap.** With `FileType.custom`, each extension is mapped through
  Android's `MimeTypeMap`:
  - an extension without a known MIME type is skipped, with only a log warning;
  - the picker falls back to `*/*` only when **none** is known.

  So `['dng', 'fits']` would most likely offer only DNG files and hide FITS **[assumption]**.
  Whether `MimeTypeMap` knows `fits` and `xisf` on a given Android version is **[unknown]**.
  **Robust approach:** `FileType.any`, then recognise the format from its first bytes (magic
  numbers), never from the name.
- **`image_picker`** (the prototype's picker) serves the photo gallery, so it cannot reach
  FITS or XISF files, and it may not offer DNG **[unknown]**, pending a device check. It is
  used nowhere else, so it can be removed once the metadata screen changes.
- **GPS redaction:** Android redacts location metadata from media shared without
  `ACCESS_MEDIA_LOCATION`. Whether this applies to a DNG picked through SAF is **[unknown]**.
  It does not matter if Stage 2 never reads GPS (recommended, §7).
- The app declares no media permissions, and SAF picking needs none **[verified: the
  manifest has no media permission]**.

### 3.6 Field semantics for the typed model

| Field | EXIF / DNG | FITS (as N.I.N.A. documents it) | XISF | Model rule |
| --- | --- | --- | --- | --- |
| Exposure | ExposureTime, a rational in s | `EXPTIME` / `EXPOSURE` in s (convention; the standard has `XPOSURE`) | `Instrument:ExposureTime` in s | seconds, keeping the source keyword |
| Sensitivity | ISOSpeedRatings, with SensitivityType if present | `GAIN` (camera setting units, vendor-specific), `EGAIN` in e⁻/ADU | `Instrument:Camera:ISOSpeed`; `Instrument:Camera:Gain` in e⁻/DN | ISO **or** gain setting **or** e⁻/ADU as separate kinds; never convert between them (SI-004) |
| Focal length | FocalLength in mm; FocalLengthIn35mmFilm | `FOCALLEN` in mm, **user-entered in the capture software** | `…:Telescope:FocalLength` in **m** | mm, with its provenance ("reported by software settings" versus "from the lens"); the 35 mm equivalent kept separately, never used as the real focal length |
| f-number | FNumber | `FOCRATIO` (user-entered) | — | nullable |
| Capture time | DateTimeOriginal, local; OffsetTimeOriginal if present | `DATE-OBS` / `DATE-UTC`: UTC, at exposure start; `DATE-LOC`: local | `Observation:Time:Start`, UTC | UTC when the source says so; otherwise local with "zone unknown" |
| Camera and optics identity | Make, Model, UniqueCameraModel, LensModel | `INSTRUME`, `TELESCOP` | `Instrument:Camera:Name`, `…:Telescope:Name` | raw strings with their source, for RG-02 (Stage 3) |
| Frame type, filter, object | — | `IMAGETYP`, `FILTER`, `OBJECT` | properties or FITS keywords | raw, optional (useful for Stage 8) |
| Position, serials, observer | GPS IFD, BodySerialNumber | `SITELAT`, `SITELONG`, `OBSERVER` | `Observation:Location:*` | **not read** (§7) |

## 4. Verified facts (summary)

- DNG from the owner's phone: all capture metadata is in IFD0 within the first 6.7 KB. A
  bounded read is sufficient and simple.
- The prototype misses every capture field in these real files (TD-064).
- `exif` 3.3.0 (MIT) reads TIFF-based formats, JPEG and HEIC. It cannot accept a
  byte-budgeted source through its public API, and it does not read CR3, RAF, ORF, RW2, FITS
  or XISF.
- FITS 4.0: fixed 80-byte records in 2,880-byte blocks; `CONTINUE` is standard; quote escapes
  are `''`; `DATE-OBS` is UTC at the start by default.
- XISF: a length-prefixed XML header at byte 16. Its focal length is in metres and its gain in
  e⁻/DN.
- Android `file_picker` copies every picked file whole into the cache. Its custom extension
  filter silently drops unknown MIME types.
- N.I.N.A. writes the focal length and focal ratio from the user's equipment settings, not
  from measurements.

## 5. Unknowns and how to resolve them

| Unknown | Resolves it |
| --- | --- |
| Which formats the owner produces besides phone DNG (a dedicated astro camera? a DSLR or mirrorless? which capture software?) | The owner's answer (§9, question 1) |
| What real FITS files from the owner's software contain (`DATE-OBS` versus `DATE-UTC`, `GAIN` semantics, `HIERARCH`, `CONTINUE`) | A real FITS sample (and XISF if used) |
| A camera JPEG or RAW with a real EXIF IFD and MakerNotes (for example CR2 or NEF) | A sample, only if the owner uses one |
| Whether `MimeTypeMap` knows `fits`/`xisf`; whether `image_picker` offers DNG; GPS redaction through SAF | A device check (no device or emulator is available; Stage 11). The recommended design avoids depending on any of them |
| Whether the missing GPS in the DNGs is the camera setting or Telegram | The owner. Irrelevant if GPS is never read |
| The cost of the cache copy on a real phone (time for 25 MB) | A device check; not blocking for single files |

## 6. Options and trade-offs

**A. Readers**

| Option | For | Against |
| --- | --- | --- |
| A1. Keep `exif` for TIFF/JPEG (reading the cached copy with `readExifFromFile`, or a bounded prefix with `readExifFromBytes`); add an in-house FITS reader | Little new code for EXIF; MakerNotes available | No byte budget through the public API (only a prefix works, and a prefix fails when a RAW places IFDs late); MakerNote decoding and thumbnail extraction are not needed; a second key-naming layer (`Image`/`EXIF`) to map |
| **A2. An in-house, bounded TIFF/EXIF IFD reader** (IFD0, the EXIF IFD, value offsets; only the ~15 tags in §3.6; loop and bounds checks) plus an in-house FITS reader, **both behind one domain interface over a byte-budgeted random-access source**; `exif` removed, or kept only as a test-time cross-check | Full control of bounds and budget; one typed mapping; small code (TIFF IFDs and FITS cards are simple, well-specified structures); drops a dependency (Stage 10) | More code to test. Real samples are needed anyway, and the owner's DNGs already cover the IFD0 layout |
| A3. Vendor a copy of `exif` | Keeps its breadth | MIT allows it, but it means maintaining foreign code; still broader than needed |

**B. File selection:** B1, `file_picker` with `FileType.any` and content sniffing, clearing
temporary files after reading (**recommended for Stage 2**, single files); B2, a native
channel over `ContentResolver` with no copy (deferred to the batch work of Stage 8, if the
copy proves costly); B3, keep `image_picker` (it cannot reach FITS: rejected).

**C. Fixtures in a public repository:**
- **C1. Header-only derivatives, committed with the owner's written consent.** Examples: the
  first 6,700 bytes of each DNG, which is complete metadata with the pixels cut; the header
  blocks of a FITS file. Any position, serial or name is scrubbed, and each edit is
  documented next to the fixture. They are tiny, real and reproducible.
- **C2. Samples only outside Git,** with tests that are skipped when the samples are absent.
  Nothing is published, but CI and other contributors cannot run the tests.
- **C3. Synthetic files only.** This fails the Stage 2 exit ("parsed from a real sample").

  **Recommended: C1, plus synthetic cases** for corrupt, truncated and huge files. The DNG
  derivatives contain Make, Model, the OS build string and the capture time: no GPS and no
  serial.

**D. RD-16 (visibility):**
- **D1. Hidden until Stage 3** (recommended): a read-only viewer alone gives the planner
  little. Its value comes with equipment candidates (Stage 3) and assisted actuals (Stage 8),
  and a visible screen needs accessibility, privacy text and design work now.
- **D2. A visible read-only "file info" screen** at the end of Stage 2.

## 7. Recommended direction

1. **Formats for Stage 2 (PD-21):**
   - **DNG and other TIFF-based files: supported now.** DNG is verified on the owner's real
     samples.
   - **FITS:** supported **when the owner supplies a real sample**. It is central to
     astrophotography; without a sample, S2.3 waits.
   - **JPEG:** only if a real camera JPEG is supplied (its EXIF sits in APP1, the same TIFF
     structure).
   - **XISF:** only if the owner uses it and supplies a sample.
   - **Deferred:** CR3, RAF, ORF, RW2 and HEIC (no sample, and not needed by a known owner
     workflow).
2. **Readers:** option **A2**. `exif` stops being a runtime dependency. It may stay as a
   dev-only oracle in one test, if the owner prefers a cross-check.
3. **File selection:** option **B1**. `image_picker` is removed in S2.6.
4. **Privacy by design:** Stage 2 never reads GPS or location keywords, serial numbers,
   observer names or site coordinates. Nothing is stored and nothing leaves the device.
5. **Fixtures:** option **C1** with consent; the full samples stay outside the repository.
6. **RD-16:** **D1**, hidden until Stage 3.
7. **Types:** the model follows §3.6. Every value records its source and keyword. The
   35 mm-equivalent focal length is never used as a focal length. Gain kinds are never merged
   with ISO. "Zone unknown" is explicit.

**Consequence for the provisional Tasks:**
- S2.1, S2.2 and S2.6 stand as planned.
- S2.4 becomes "the in-house TIFF/EXIF reader (DNG first)" and can run now.
- S2.3 (FITS) waits for a FITS sample.
- S2.5 is only for XISF, and only if the owner uses it.

## 8. Proposed ADR-017 — Image metadata reading (*proposed, not accepted*)

- **Context:** TD-018, F-45 and PD-21; this research.
- **Decision (proposed):**
  1. **Access.** A domain interface, `MetadataSource`: its length and bounded range reads,
     with a per-file byte budget (by default 1 MiB, far above the 6.7 KB DNG and a typical
     FITS header). The data layer implements it over a local file (the picker's cached copy).
     Exceeding the budget or reading past the end is a typed failure.
  2. **Recognition** by magic bytes (TIFF `II*\0`/`MM\0*`; FITS `SIMPLE  =`; XISF
     `XISF0100`; JPEG `FF D8`), never by extension.
  3. **Readers.** Pure Dart and in-house: a TIFF/EXIF IFD reader (IFD0 plus the EXIF IFD,
     with loop and bounds checks) and a FITS 4.0 header reader (block limit; commentary
     records ignored; `''` escapes; `CONTINUE` per §4.2.1.2). XISF only if decided.
  4. **Typed result.** `ImageMetadataReading` = `read(values)` | `unsupported(format)` |
     `unreadable(reason)`. Each value is one of:
     - `known(value, unit, source keyword, provenance)`;
     - `absent`;
     - `unparseable(raw)`.
     Provenance is "file metadata" or "software setting", per §3.6.
  5. **Excluded fields:** location, serial numbers, observer identity.
  6. **Persistence:** none in Stage 2. Stage 3's ADR decides what becomes an equipment
     candidate.
- **Consequences:**
  - `exif` and `image_picker` are removed from the runtime;
  - `lib/domain` has no I/O, enforced by a test;
  - FITS support needs a real sample.

## 9. Owner decisions requested (one message)

1. **Your files.** Besides the phone DNGs: do you shoot with a dedicated astro camera,
   through capture software (N.I.N.A., ASIAIR, SharpCap, Seestar or Dwarf apps), or with a
   DSLR or mirrorless camera? Please supply one real file for each format you use. FITS
   matters most. Keep them outside the repository, as you did.
2. **PD-21, the format set:** accept §7.1 (DNG/TIFF now; FITS on a sample; JPEG and XISF only
   with a sample; the rest deferred)?
3. **ADR-017 as proposed in §8:** in-house bounded readers, `exif` and `image_picker` removed,
   no GPS, serials or observer fields.
4. **Fixture policy C1:** may header-only derivatives of your samples be committed to the
   public repository (for the DNGs, the first 6,700 bytes: Make, Model, the OS build string,
   the capture time, no GPS, no serial)?
5. **RD-16:** keep the metadata feature hidden until Stage 3 (recommended), or show a
   read-only screen at the end of Stage 2?
