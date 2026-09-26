# Stage 2 — review of S2.1–S2.5 against the owner's format priorities

> **Date:** 2026-09-26. **Code reviewed:** `main` @ `2bfccc2` (S2.1–S2.5). Documentation only;
> no code changed.
> **Trigger:** the owner's direction of 2026-09-26 (DECISIONS E.1, "Stage 2 format
> priorities"): a common typed, provenance-aware extraction contract for many formats; new
> format priorities; three levels kept apart (recognition, extraction, equipment evidence);
> no image decoders and no universal RAW framework.

## 1. The direction, restated

**Format priorities:**
- **DNG:** primary; real samples exist.
- **JPEG/JPG:** high priority.
- **HEIC/HEIF:** a high-priority research and support target.
- **FITS/FIT:** when a representative real sample exists.
- **PNG:** where meaningful metadata exists (never assumed to identify equipment).
- **Proprietary RAW** (CR2/CR3, NEF, ARW, RAF, RW2): no ad hoc parsers; a dedicated
  compatibility and library research task.
- **XISF and other specialised formats:** driven by samples and use cases.

**Primary focus:** RAW, DNG and JPEG.

**Rules that stand:**
- no support is claimed without a representative real sample and tests;
- unknown stays unknown;
- ADR-017's privacy exclusions and bounded reads apply.

## 2. What already fits (verified in the code)

| Area | Evidence | Verdict |
| --- | --- | --- |
| Common contract | `CaptureMetadata` (`capture_metadata.dart:8`) names quantities, not tags: exposure (s), sensitivity with its kind, focal length and 35 mm equivalent (mm), f-number, capture time with an optional offset, and the camera and lens identity strings | **Format-agnostic.** JPEG, HEIC and PNG carry EXIF and map onto it unchanged |
| Values and provenance | `MetadataValue` (known, absent, unparseable, ambiguous) and `MetadataOrigin` (format, field, location, provenance) in `metadata_value.dart` | **Format-agnostic.** A JPEG value would read "JPEG · APP1 IFD0 · ExposureTime (33434)" |
| Bounded access | `MetadataSource` and `BudgetedMetadataSource`; the Android channel reads any document type (`*/*`) in place | **Fits every format**, since container parsers only need range reads |
| Privacy exclusions | The GPS IFD is never followed; serials and Artist are never decoded (tested with a read log) | **Holds** for any EXIF container |
| Unknown ≠ zero | Absent defaults; no defaulting anywhere; the screen prints "Not in the file" | **Holds** |
| No equipment write | Nothing persists; the screen is hidden | **Holds**; level 3 (equipment evidence) does not exist, correctly |
| Proprietary RAW | A TIFF without DNGVersion gives `MetadataUnsupported(tiff)`: no ad hoc CR2/NEF/ARW support is claimed | **Consistent** with "no ad hoc parsers" |

## 3. Gaps against the direction

| # | Gap | Evidence | Consequence |
| --- | --- | --- | --- |
| G1 | **The EXIF/TIFF parsing is fused with the DNG container.** The TIFF header is assumed at byte 0 (`tiff_metadata_reader.dart:39`), the origin's format is hardcoded to DNG (`:199`), and the DNGVersion gate is at the top (`:49`) | JPEG (the APP1 `Exif\0\0` segment), HEIC (the `Exif` item) and PNG (the `eXIf` chunk) each embed the **same** TIFF structure at a non-zero base offset | Each new format would duplicate the IFD parser or fork it. A reusable EXIF-structure extractor, given a base offset, is needed |
| G2 | **Dispatch is a closed switch** (`capture_metadata_reader.dart:15`) | Adding a format edits the domain dispatcher | Minor. A list of format readers behind one interface keeps each format self-contained, and the contract and the dispatcher stay unchanged |
| G3 | **Recognition and extraction share one result type.** `MetadataUnsupported(unknown)` means "not recognised", while `MetadataUnsupported(tiff)` means "recognised, no reader". A successful read that found nothing is only visible as all-absent fields | `capture_metadata.dart:48–95` | The direction asks for three distinct levels. The reading should state the recognised format separately from the extraction outcome, and "extracted, but nothing found" should be explicit |
| G4 | **The recognition vocabulary is too small.** HEIC/HEIF (ISO-BMFF `ftyp` brands), PNG, CR3 (`ftyp crx `), RAF (`FUJIFILMCCD-RAW`), RW2 (`IIU\0`) and ORF (`IIRO`/`IIRS`/`MMOR`) come out as "an unrecognised format"; CR2 (TIFF plus `CR` at byte 8) comes out as "TIFF (not a DNG)" | `metadata_format.dart:38–62` | The user is told "unrecognised" for files the app can name. Recognition-only signatures are cheap and honest; **no parser is implied** |
| G5 | **EXIF-specific conversions live in the generic contract file.** `ExifRational` and `ExifValues` sit in `capture_metadata.dart` | `capture_metadata.dart:200–353` | A placement issue. They belong beside the EXIF extractor, which the JPEG, HEIC and PNG readers will reuse |
| G6 | **The contract has no generic optics identity.** FITS `TELESCOP` and XISF `Instrument:Telescope:Name` have no field | ADR-017 §2 | A future amendment for FITS (S2.6) adds one identity field, not a model per parser. Recorded now, so the FITS amendment does not fork the model |

**No regression, and no violation of ADR-017 or the owner's constraints, was found.** The
gaps are about extensibility for the new priorities, not defects in shipped behaviour.

## 4. Level 3: equipment evidence (Stage 3 boundary)

Deciding whether the extracted values are **enough to form an EquipmentCandidate** is RG-02's
question (Stage 3). The owner's own samples show why it cannot be answered by extraction:
both of the phone's camera modules report the same Make, Model and UniqueCameraModel, and
focal length is not a universally reliable identifier.

- **Stage 2 must:** keep the level separate. No field, flag or wording in Stage 2 may imply
  candidacy (for example "camera identified"). Keep every identity string raw, with its
  provenance.
- **Stage 3:** defines an `EquipmentEvidence` assessment that consumes `CaptureMetadata`
  (RG-02, its ADR). Nothing in Stage 2 anticipates its rules.

## 5. Recommended changes (the Tasks in `POST_ROADMAP_PLAN.md`)

1. **S2.7 — Layered recognition and a reusable EXIF extractor** (host; a refactor with no
   behaviour change for DNG). It covers G1–G5:
   - the reading reports the recognition level separately from the extraction outcome, with
     an explicit "extracted, nothing found";
   - format readers sit behind one interface;
   - the EXIF-structure extractor takes a base offset and a container label;
   - recognition-only signatures for HEIF, PNG, CR2, CR3, RAF, RW2 and ORF;
   - the EXIF conversions move beside the extractor.
2. **S2.8 — JPEG reader** (the APP1 `Exif` segment through the S2.7 extractor; a bounded
   marker walk that stops at SOS; no decoding). **Gated on a real JPEG sample:** the owner's
   phone JPEG, and a DSLR or mirrorless JPEG where possible.
3. **S2.R2 — HEIC/HEIF research:**
   - ISO-BMFF `meta`, `iinf`, `iloc` and the `Exif` item, and whether the items sit early
     enough for a bounded read;
   - the `ftyp` brands;
   - what Android pickers deliver for HEIC;
   - the candidate libraries (see RG-14).
   It ends in an owner decision; then a reader Task (S2.9) exists **only with a real HEIC
   sample.**
4. **S2.10 — PNG `eXIf`:** only with a real PNG that carries it; low priority, and PNG is
   never assumed to identify equipment.
5. **RG-14 — proprietary RAW compatibility and library research** (S2.R3; documentation
   only). CR2/CR3, NEF, ARW, RAF, RW2 and ORF: evaluate libraries or platform facilities
   against ADR-017's bounded reads, privacy and licence rules, instead of writing ad hoc
   parsers. For example, AndroidX `ExifInterface` lists many RAW formats and HEIF. That is
   an **unverified candidate** for the research, not a decision.
6. **S2.6 — FITS** stays gated on a real sample. G6 (a generic optics identity field)
   becomes part of its ADR amendment.
7. **XISF:** unchanged (sample and use-case driven).

## 6. What this does not do

- No image decoding, thumbnails or pixel access.
- No universal RAW framework.
- No format marked supported without a real sample and tests.
- No change to the approved privacy exclusions, the byte budget or the Stage 3 boundary.
