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
