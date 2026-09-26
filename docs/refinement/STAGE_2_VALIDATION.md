# Stage 2 independent validation — FAIL

Date: 2026-09-26. Stage: **2 — Metadata Foundation**.

## Repository state and scope

- HEAD: `79f392cecc34e494cfd93968e8b5109e543f83e8`.
- Stage starting point: `565341b` (Stage 1 closure and Stage 2 planning).
- Frozen implementation baseline: `96454d8` (RG-01 decision and ADR-017).
- Examined range: `565341b..79f392c`; implementation commits `a25398c`,
  `b8d626a`, `59c9f03`, `26aff9a`, `a2f42a5`, `9a0432b`, `360fd8f`.
- The working tree was clean on entry and after all execution checks. This
  validation adds only this record, probe evidence, and a PROGRESS validation entry.
- No application code, existing tests, dependencies, feature gates, or device
  installations were changed. No next-stage work was started.

This is a validation of the current Stage, not confirmation of a completed Stage:
PROGRESS explicitly requires S2.9 or its owner-approved deferral, and S2.R3,
before Stage validation. Neither is complete. This prompt does not itself resolve
those product/research decisions. S2.6 and S2.10 were removed from Stage 2 by the
owner; their missing readers are not defects.

## Validation performed

Read CLAUDE.md, PROGRESS, the current and superseding frozen Stage definitions,
ADR-017 and relevant owner decisions, relevant PRODUCT_DIRECTION constraints,
the S2.R1 and S2.R2 research records, the Stage 2 architecture review, and the
metadata portions of ARCHITECTURE, FEATURE_STATUS, SCIENTIFIC_INTEGRITY,
TECH_DEBT and TEST_PLAN. No AGENTS.md was found in the repository or its ancestors.

Inspected every Stage production change: domain sources, types, conversion,
recognition, dispatch, DNG/JPEG/EXIF parsing, native and Dart document access,
backup cleanup, ViewModel/screen, composition and gating. Inspected corresponding
unit/widget/real-file tests and synthetic fixtures. Compared the removed
prototype mechanisms with the replacement and checked dependency removal.

Ran the full gate, the local owner-sample test, two independent malformed-input
acceptance assertions, a parser-request accounting probe, and a before/after
DNG comparison. The latter used the pre-S2.7 reader from `a2f42a5` in temporary
storage, with import adaptation to the unchanged conversion API; production
files were not edited. Both IFD0-only and EXIF-IFD layouts retained identical
values and read logs (349 and 410 bytes respectively, excluding recognition).

## Task results

| Task | Result | Acceptance evidence and limits |
| --- | --- | --- |
| S2.R1 | PASS | DOCUMENTED: research questions, options, unknowns and the owner's superseding decisions are recorded. ADR-017, PD-21 and RD-16 agree. CODE/TEST VERIFIED: the implemented choices are bounded sources, local samples, synthetic committed fixtures, no picker copy and a hidden screen. Historical package/licence research was not independently repeated. |
| S2.1 | PASS | CODE/TEST VERIFIED: 4 GiB file test, typed range/size/I/O failures, cumulative Dart budget, domain import guard and its positive detection test. Native fallback accounting is a separate S2.4 failure. |
| S2.2 | PASS | CODE/TEST VERIFIED: all 11 fields default absent; typed units/provenance; rational/zero-denominator rules; conflicts; ISO kinds; separate 35 mm equivalent; capture time without an inferred zone. CALC-39 documents the rules. |
| S2.3 | FAIL | Real DNGs pass all 11 expected fields and the read limits; endian, IFD, conflict, privacy, truncation and loop tests pass. However an out-of-range integer-array pointer becomes a known ISO value (S2V-01), violating bounds and Unknown semantics. |
| S2.4 | FAIL | Range/channel and backup success/cancel/refusal/error tests pass. Prior M1/M2 seekable-device results are documented at unchanged code. The explicitly required non-seekable fallback test is missing; actual traversal is not cumulatively budgeted (S2V-03). |
| S2.5 | PASS | CODE/TEST VERIFIED: success, unsupported, unreadable, cancel, picker error, unknown zone, 200% accessibility, hidden gate, removal of prototype/dependencies, no persistence/network path, green gate. Prior device read-through is DOCUMENTED, not rerun here. Parser failures are assigned to S2.3/S2.8. |
| S2.6 | PASS (scope disposition only) | DOCUMENTED: owner removed FITS from this Stage. Recognition-only is correct; no implementation completion is claimed. |
| S2.7 | PASS | CODE/TEST VERIFIED: registered readers, separated recognition/extraction, embedded source window/provenance, every added signature and near-miss tests. Pre-existing tests changed only their import in this refactor. Independent DNG read-log/value comparison passed; local real DNGs still read 848 bytes. S2V-01 was inherited from S2.3, not introduced by the refactor. |
| S2.8 | FAIL | Real JPEG passes all 11 expected fields in 843 bytes; ordinary marker walking and GPS exclusion pass. A recognisable but incomplete EXIF segment becomes successful 'nothing found' (S2V-02). Shared integer decoding also carries S2V-01 into JPEG. |
| S2.R2 | UNVERIFIED (decision incomplete) | DOCUMENTED: sample evidence, bounded-access proposal, options and unknowns exist. Required owner decision remains pending; no independent HEIC extraction or provider test was performed here. |
| S2.9 | UNVERIFIED (awaiting decision) | Neither approved implementation nor explicit deferral is recorded. Its absence is not an unauthorized-implementation defect; the unresolved disposition prevents Stage closure (S2V-04). |
| S2.10 | PASS (scope disposition only) | DOCUMENTED: owner removed PNG from this Stage. It remains recognised only. |
| S2.R3 | FAIL (not completed) | Required research/recommendation/owner-decision output is absent; RG-14 is explicitly open (S2V-04). |

## Findings

### S2V-01 — BLOCKING: an integer pointer becomes reported metadata

**CODE and TEST VERIFIED.** `lib/domain/metadata/exif_structure.dart:290–317`
reads SHORT/LONG values directly from the four-byte value/offset slot whenever
count is positive, without validating the field's count or resolving an
out-of-line value. The production dispatcher accepts a synthetic 38-byte DNG
with tag 34855, SHORT count 3, pointer 60000 as **known ISO 60000**. There are no
value bytes at that address. The same helper serves sensitivity kind and
35 mm-equivalent focal length and is shared by DNG and JPEG.

Expected: validate counts and out-of-line ranges; malformed or unsupported
values remain unparseable/unknown. ADR-017 §§2, 4 and 5 and S2.3 explicitly
require this. Existing bad-count coverage checks rationals, not integer tags.
The fuzz tests accept any MetadataReading, including this incorrect success.

### S2V-02 — BLOCKING: damaged JPEG EXIF is reported as absent

**CODE and TEST VERIFIED.** `lib/domain/metadata/jpeg_metadata_reader.dart:62`
checks the Exif identifier only if APP1 length is at least 16. A complete APP1
segment containing `Exif\0\0` followed by only four TIFF-header bytes has length
12, is skipped, and reaches SOS as `MetadataRead(nothingFound: true)`.

Expected: after identifying Exif, an incomplete TIFF structure must yield a
typed truncated/corrupt result, not 'nothing found' (S2.8 malformed-input
acceptance; ADR-017 §5). The current corrupted-EXIF test supplies all eight
header bytes, so it does not exercise this branch.

### S2V-03 — BLOCKING: non-seekable budget and required test are incomplete

**CODE VERIFIED; host accounting probe only, not DEVICE VERIFIED.**
`MetadataDocumentChannel.kt:159–180` opens a new stream and skips from zero on
every range, checking only that that range ends within 1 MiB. Dart charges
only returned bytes (`metadata_source.dart`), so consumed/skipped bytes are
not accumulated across calls. A production DNG parser request log containing
seven value ranges at offset 900000 charges 365 bytes but requires 6,300,383
bytes of traversal on a stream that consumes its skipped prefix. Every range
passes the native per-range check. This is a calculated consequence of the
native algorithm, not a measured cloud-provider transfer.

S2.4 explicitly requires a host non-seekable fallback test. Its five channel
tests return random-access fixture slices; lines 78–80 merely assert that
`sequentialLimit` was sent. Neither a fallback nor cumulative traversal is
exercised. M1 explicitly did not run this path. Therefore S2.4 cannot be fully
accepted even though its seekable path passed.

Expected: enforce ADR-017 §4's per-file resource limit through the fallback,
while preserving §6's range-end limit, and add meaningful fallback tests.
Also retain an accurate budget-exceeded reason: the current native refusal
throws IOException and becomes `io`, while S2.R2 §4 currently promises
`overBudget` for this case. No cloud upload is necessary to test a synthetic
non-seekable provider.

### S2V-04 — BLOCKING: Stage completion gates remain open

**DOCUMENTED and repository VERIFIED.** PROGRESS lines 295–303 requires S2.9
or its deferral and S2.R3 before validation. ADR-017's open list agrees. The
S2.R2 decision is pending and RG-14 has no completed research record. These
are incomplete required work, not unknown execution results. The Stage is
honestly marked in progress; it cannot yet receive a PASS.

### S2V-05 — NON-BLOCKING: current documentation contradicts newer records

**DOCUMENTED and CODE VERIFIED.** PROGRESS's owner-actions/blockers section
still asks for a FITS sample and a device for S2.4, and says no device run is
recorded. The top of the same file records FITS removal and successful M1/M2.
F-45's 'Current implementation' still says only DNG is supported, and its
unqualified 'Known issues' retains the removed prototype and 'no real sample
files exist'. A later historical disclaimer says 'below' although the stale
list is above. Reconcile current statements; preserve clearly labelled history.

### S2V-06 — UNVERIFIED: remaining native/manual coverage

The existing TEST_PLAN records seekable M1 and M2 non-backup/cancel paths at
`360fd8f`; application/native code is identical at HEAD. These are accepted
as **DOCUMENTED prior device evidence**, not device runs performed in this
validation. Non-seekable provider behavior, real-backup preview cancellation,
and direct device byte-count instrumentation were not verified here. The M1
record documents values/cache size; the 848-byte measurements are host results.
No new HUMAN VERIFIED evidence is claimed.

### S2V-07 — NON-BLOCKING: existing short-exposure display debt

TD-066 remains: exact rational-derived exposure displays as a long decimal.
CODE VERIFIED: the formatter preserves the value and raw rational. This is
readability debt on a hidden screen, not fabricated precision in extraction;
the owner already assigned its presentation rule to later work.

### S2V-08 — REJECTED: deferred formats and prototype removal are regressions

No supporting evidence. FITS/PNG deferral is explicit; HEIF/RAW recognition
does not claim extraction. The old FITS parser is removed with the approved
prototype, not represented as repaired/supported. Dependency searches found
no remaining application uses of exif/image_picker. No Equipment/session
writes, inferred time zone, network submission or scientific planner change
was introduced by this Stage.

## Executed checks

| Command/check | Result |
| --- | --- |
| `dart run tool/check.dart` | PASS, exit 0: encoding; formatting (345 files, zero changes); analysis; 1042 tests, 1 expected local-sample skip; 2 host E2E tests. |
| `flutter test --no-pub test/data/metadata/real_samples_test.dart`, with the existing external `ASTROPLAN_METADATA_SAMPLES` directory | PASS, exit 0: one test covers two DNGs and one JPEG, all 11 expected fields per file. Reads: 848/848/843 bytes, 11/11/16 ranges. Private expected values and files remain outside Git. |
| Independent scratch Dart probes through `CaptureMetadataReader` | FAIL, exit 1: 2/2 acceptance assertions fail, reproducing S2V-01 and S2V-02. The separate traversal calculation supports S2V-03; it is not native execution. See `evidence/STAGE_2_VALIDATION_PROBES.md`. |
| Scratch comparison against the pre-S2.7 DNG reader at `a2f42a5` | PASS, exit 0: identical values/read logs for IFD0-only and EXIF-IFD layouts. |
| Git/dependency/documentation inspection | Clean application tree; prototype/dependencies removed; device-check code unchanged since `360fd8f`. |

## Verdict and required follow-up

**FAIL.** Passing ordinary samples and the full gate do not satisfy malformed
metadata semantics, the required fallback test, or the unfinished Stage gates.

Proposed focused corrective Tasks (not implemented or approved here):

1. **S2.V1:** correct integer count/offset handling in the shared EXIF reader;
   add invalid/multi-value/out-of-range integer coverage through DNG and JPEG.
2. **S2.V2:** distinguish short/damaged Exif APP1 payloads from absent Exif;
   assert the exact extraction outcome in boundary tests.
3. **S2.V3:** enforce and test non-seekable per-file resource accounting and
   error mapping, including a synthetic stream/provider that consumes skips.
4. Resolve **S2.R2/S2.9** by recorded owner decision (implement or defer), and
   complete **S2.R3/RG-14** as already scoped. No decision is inferred here.
5. Reconcile the current metadata/progress statements (S2V-05); retain TD-066
   and the remaining device/manual evidence limits.

Rerun affected tests, the quality gate and independent Stage validation after
the corrections and required gate dispositions. Stage 3 must not begin from
this FAIL verdict. STOP.
