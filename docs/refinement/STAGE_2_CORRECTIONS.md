# Stage 2 validation corrections — S2.V1–S2.V3

Date: 2026-09-26. Based on `79f392c` and `STAGE_2_VALIDATION.md`.
The owner requested fixing the failures after that validation. This authorizes
the corrective implementation and tests; it does not decide the pending HEIC
scope or enable metadata import in ordinary builds.

## Changes

- **S2.V1 / S2V-01:** the shared EXIF reader accepts one SHORT/LONG value only.
  Zero, multiple and oversized counts are unparseable; an offset cannot become
  a reported number. An invalid SensitivityType also leaves sensitivity
  unparseable rather than falsely labelling it. Multi-valued integer extraction
  is unsupported, not guessed. Tests cover ISO, sensitivity kind and 35 mm
  equivalent through both DNG and JPEG dispatch.
- **S2.V2 / S2V-02:** APP1's Exif identifier is checked as soon as those six bytes
  fit. The shared extractor then reports incomplete TIFF headers as truncated.
  A regression test checks every header length from zero through seven bytes.
- **S2.V3 / S2V-03:** each Android source serializes reads and retains a remaining
  budget. The native reply carries the returned bytes and consumed-byte cost.
  Seekable reads charge their count; streaming reads also charge their prefix,
  including repeated prefixes. The production `MetadataSequentialReader`
  refuses over-budget traversal before opening a stream, handles partial reads,
  rejects stalled/short streams and always closes them. Native budget refusals
  retain the `overBudget` reason in Dart. Unknown consumption after I/O failure
  exhausts the source instead of guessing its remaining budget.
- **S2V-05:** current PROGRESS and F-45 statements now distinguish actual DNG/JPEG
  support, prior device evidence, prototype history and deferred FITS/PNG work.
  The original independent FAIL report remains unchanged as historical evidence.

No extraction field, scientific formula, timezone inference, persistence,
network submission, or image-decoding capability was added. The channel wire
format changes together on its Dart and Kotlin sides; debug testing therefore
needs a full rebuild/restart, not hot reload alone.

## Why the metadata entry disappeared during debugging

`FeatureScope.metadataImport` remains false for both debug and release builds.
The device-check session at `360fd8f` temporarily changed it to true in a
separate debug package, then reverted the flag and removed that test package
(TEST_PLAN M1/M2). The reader and screen are still implemented; the entry and
route are gated. RD-16 and ADR-017 §10 keep them hidden during Stage 2. The
owner's question here does not itself request a visibility-policy change.

## Verification

- Targeted `flutter test --no-pub test/domain/metadata test/data/metadata`:
  **76 pass, 1 expected local-sample skip**.
- External real-sample test: **pass**, two DNGs and one JPEG, all 11 expected
  fields unchanged; reads remain **848, 848, 843 bytes**. No owner files or
  expected values were committed.
- Original independent malformed-input probes: **0/2 assertions fail** now
  (previously 2/2). The old third probe is only a request-cost calculation;
  the new production-native tests verify refusal under that cumulative cost.
- `android/gradlew.bat :app:testDebugUnitTest --offline`: **pass**, Kotlin
  compiles; **4 JVM tests, 0 failures/errors/skips**. These execute the actual
  streaming helper, not a reimplementation. JUnit 4.13.2 is test-only.
- `dart run tool/check.dart`: **pass**, encoding, formatting (346 files,
  zero changes), analysis, **1052 tests with 1 expected skip**, and **2 host
  E2E tests**. No new device run was performed.

This is implementation self-verification, not fresh independent Stage
acceptance or a new device run. S2V-04 remains open: S2.R2/S2.9 requires an
owner decision and S2.R3/RG-14 requires its scoped research. S2V-06's native
device/backup-preview limits and TD-066 remain recorded. Stage 2 stays in
progress; Stage 3 has not started.

---

# Repeat-validation corrections: S2.V4 and S2.V5

Date: 2026-09-26. Based on `5d8bdbb` and `STAGE_2_REVALIDATION.md` (committed `f137409`).
The owner said "Do fix", which approves S2.V4 and S2.V5. The owner named no S2R-02 option,
so the recommended one, (a), was taken (DECISIONS E.1, "Stage 2 repeat validation: fixes and
the HEIF brand ruling").

## S2.V4 (code, commit `d8e792c`)

- **S2R-01 / TD-067:** `HeifMetadataReader.maxExtents` = 16,384 `iloc` extents over all items,
  which is what a 64 KiB `meta` holds with one 4-byte field per extent. Beyond that the reading
  is `corrupt`, before any extent record is built. The owner's HEIC has 50.
- **S2R-02, ruling (a):** recognition now names three formats:
  - `MetadataFormat.heif`: `heic`, `heix`, `heim`, `heis`, `mif1`, read as before;
  - `MetadataFormat.avif`: `avif`, `avis`, recognised only;
  - `MetadataFormat.heifSequence`: `msf1`, `hevc`, `hevx`, `hevm`, `hevs`, recognised only.

  `MetadataText` names the two new formats ("AVIF", "HEIF image sequence"). A sequence file is
  no longer called "corrupt".
- **S2R-04:** the HEIF tests now cover:
  - the GPS IFD never read (the read log);
  - S2V-01 (an integer array stays unparseable);
  - S2V-02 (an Exif item with 0–7 TIFF bytes is `truncated`).
- **Tests:** 6 new in `heif_metadata_reader_test.dart`:
  - the work bound (P1's shape and 1 × 65,535; a 2 s ceiling);
  - the exact limit;
  - the three S2R-04 cases;
  - AVIF and sequences (unsupported, 16 bytes read).

  `metadata_layers_test.dart` gained the two signatures. One assertion changed by the ruling:
  `avif` and `msf1` were expected to be HEIF, and are now `avif` and `heifSequence`.

## S2.V5 (documentation)

- **F-45:** the current-implementation and known-issues text is corrected, with the old text
  quoted.
- **`TEST_PLAN.md`:** the "no device" note is corrected, and the old text is quoted.
- **Also updated:** `ARCHITECTURE.md` B, ADR-017's implementation note, DECISIONS E.1,
  TD-067 and `PROGRESS.md`.

## Verification

- **Before the fix:** with the pre-S2.V4 reader restored in place, both bound tests fail (the
  reading is not `corrupt`, and it takes seconds). With the fix they pass.
- **Targeted:** `flutter test --no-pub test/domain/metadata test/data/metadata
  test/presentation/shared/metadata_text_test.dart` gives 98 passed and 1 expected skip.
- **Real samples (local):** unchanged. DNG 848/848, JPEG 843, HEIC 4,051 bytes, every expected
  field.
- **`dart run tool/check.dart`:** Encoding; Format (349 files, 0 changed); Analyze (no issues); 1068 tests with 1 expected local-sample skip; 2 host E2E.
- **Not run:** no device run was made. The change is pure Dart, reached through the same
  channel that M3 exercised.

Stage 2 stays **in validation**. It closes after another independent validation in a fresh
session, or an owner waiver.
