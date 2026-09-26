# Stage 2 repeat independent validation: FAIL

Date: 2026-09-26. Stage: **2, Metadata Foundation**. Validator: a fresh session. It did not
build the Tasks, and it did not rely on earlier chat transcripts.

## Repository state and scope

- HEAD: `5d8bdbb`, with a clean tree on entry. The first independent validation ran at
  `79f392c`; this run covers `79f392c..5d8bdbb` (`ffaff57` S2.V1–S2.V3, `bb28452` S2.9,
  `237c55f` M3, `e444bfa` S2.R3, `5d8bdbb` RG-14) and re-checks the whole Stage against its
  amended exit (`POST_ROADMAP_PLAN.md`, "The Stage 2 exit, amended").
- Nothing in `lib/`, `test/`, `android/` or the dependencies was changed. The probes were
  throwaway files under `test/zz_probe/`. They were run and then deleted; their code is in
  `evidence/STAGE_2_REVALIDATION_PROBES.md`. The fixtures are synthetic; no owner bytes were
  used or committed.
- This session adds only this report, the evidence file, TD-067 (recorded, not fixed) and
  the `PROGRESS.md` state.

## Executed checks

| Check | Result |
| --- | --- |
| `dart run tool/check.dart` on the clean tree | **PASS**, re-run after the probes were deleted: Encoding; Format (349 files, 0 changed); Analyze (no issues); 1062 tests with 1 expected local-sample skip; 2 host E2E. A first run, started before the probes existed, passed all five steps; its test step also picked up probe P1 (1063 = 1062 + 1), so it is not used as the count |
| `flutter test --no-pub test/data/metadata/real_samples_test.dart` with `ASTROPLAN_METADATA_SAMPLES` set | **PASS**: 2 DNGs, the JPEG and the HEIC give every expected field. Reads: 848, 848, 843 and 4,051 bytes (11, 11, 16 and 17 ranges). Unchanged from the recorded values |
| `gradlew :app:testDebugUnitTest --offline --rerun` | **PASS**: `MetadataSequentialReaderTest`, 4 tests, 0 failures (a fresh run, 10:34 UTC) |
| Probe P1: HEIF `iloc` with zero-size extent fields | **FAIL**: see S2R-01 |
| Probe P2: S2V-01 through HEIF (an ISO SHORT with count 3 pointing at 60000) | PASS: unparseable |
| Probe P3: S2V-02 through HEIF (an Exif item with 0–7 TIFF bytes) | PASS: all are `truncated` |
| Probe P4: the GPS IFD inside a HEIF Exif item | PASS: never read (checked in the read log) |
| Probe P5: sequence and AVIF brands | Observation: see S2R-02 |
| Test diffs since `79f392c` | Three assertion edits, none weakened (details below) |

## Acceptance against the amended exit

| Exit item | Result | Evidence |
| --- | --- | --- |
| The foundation is validated | **FAIL** | The byte budgets hold everywhere. The HEIF reader's **work** is unbounded, though (S2R-01) |
| DNG is supported on real samples, with tests | PASS | Real samples; the synthetic suite; the regression tests from S2.V1 |
| JPEG is supported on a real sample, with tests | PASS | Real sample; the S2.V2 regression tests |
| HEIF is supported on a real sample, with tests | **FAIL** (S2R-01); the scope is open (S2R-02) | Real sample, and M3 passed on a device. The inherited S2V-01/02 fixes hold (P2, P3), and GPS is never read (P4) |
| Every other format is recognised only, with its gate | PASS | FITS (S2.6) and PNG (S2.10) are out by the owner. Proprietary RAW is recognised only (RG-14 decided) |
| I/O is out of the domain; the domain purity test holds | PASS | `metadata_domain_purity_test.dart` is in the gate |
| Unknown stays unknown; no defaults | PASS | `exif_values.dart` was re-read: a 0 denominator, 0/65535 ISO, a 0 35 mm equivalent and a blank time are unparseable or absent; no zone is inferred |
| Privacy: no GPS, serials or observer | PASS | Only `_contractTags` are kept; the GPS pointer (34853) is not among them. P4 covers HEIF; DNG and JPEG have tests |
| The hidden gate | PASS | `FeatureScope.metadataImport => false`; the router and Settings check it |
| No persistence and no network | PASS | The ViewModel only reads; `main.dart` wires `AndroidCaptureFileAccess` alone |

## The first validation's findings, re-checked

| ID | Now | Evidence |
| --- | --- | --- |
| S2V-01 | Fixed | `_singleInteger` accepts count 1 only; `validation_regressions_test.dart` covers DNG and JPEG; P2 covers HEIF |
| S2V-02 | Fixed | APP1 is identified at `length >= 8`; the header-length sweep test covers JPEG; P3 covers HEIF |
| S2V-03 | Fixed on the host | The Dart source carries `remainingBudget` and `consumed`; `MetadataSequentialReader` charges the skipped prefix (4 JVM tests re-run). On a device only the seekable path is exercised (M3). The non-seekable provider remains unverified on a device (S2V-06) |
| S2V-04 | Closed | S2.9 is approved and done; M3 passed; S2.R3 is done; RG-14 is decided |
| S2V-05 | **Recurred in new places** | See S2R-03 |
| S2V-06 | Unchanged | No non-seekable provider or real-backup preview cancel has run on a device. No new device run was made here |
| S2V-07 (TD-066) | Unchanged | Display debt on a hidden screen |

**Test edits since `79f392c`,** each checked against the code:
1. `metadata_layers_test.dart` skips HEIF in its "no reader" loop, because HEIF gained a
   reader.
2. `tiff_metadata_reader_test.dart` uses CR3 instead of HEIF as its "recognised, no reader"
   case, for the same reason.
3. `android_capture_file_access_test.dart`:
   - `sequentialLimit` became `remainingBudget`, which is the protocol change;
   - the short-read assertion runs on a fresh source, because an I/O failure now correctly
     exhausts its source's budget;
   - three tests were added.

No assertion was weakened.

## Findings

### S2R-01 (BLOCKING): the HEIF reader's work is not bounded by its input (TD-067)

**Code and probe verified.** `_MetaItems._parseIloc` (`heif_metadata_reader.dart:277–307`)
allows every field size to be 0 (`offset_size`, `length_size`, `base_offset_size` and
`index_size`, all permitted values). An extent then consumes **no bytes**, but it still
appends one record. `extent_count` can be 65,535 per item, and extents are recorded for
every item, not only Exif items. So each 8-byte item entry costs 65,535 records.

| `meta` size | Items | Time | Peak RSS growth | Bytes read |
| --- | --- | --- | --- | --- |
| 2,448 B | 300 | 3.0–3.4 s | about +0.8 GB | 2,448 |
| 8,048 B | 1,000 | 9.3–16.7 s | about +1.7 GB | 8,048 |

The cost is linear in the number of items. The accepted 64 KiB `meta` limit allows about
8,190 items. Extrapolated, that is about 14 GB and more than 75 s: an out-of-memory kill on
any phone. `MetadataImportViewModel._readFile` runs the reader on the UI isolate, so it also
freezes the app first.

Byte reads stay within the budget, so the budget does not catch it. The 500 random
corruptions in the robustness test never produce this shape.

This breaks ADR-017 §4.1 ("a typed failure, never a crash") and S2.9's "each bounded by its
box". The screen is hidden, so no user is exposed today. It still blocks accepting the
foundation, as S2V-01 and S2V-02 did for malformed input.

**Proposed S2.V4** (S, owner approval needed):
- bound the `iloc` work, for example by a limit on the total number of extents or by refusing
  extents that occupy no bytes; beyond the limit the reading is `corrupt`, typed;
- add a regression test that asserts the outcome and a time or allocation ceiling on this
  input.

### S2R-02 (LOW; needs an owner ruling): HEIF brands beyond the sample evidence

**Probe verified.** `MetadataFormatRecognizer.heifBrands` includes `avif`, `avis`, `msf1`,
`hevs` and the other sequence brands, and every one goes to `HeifMetadataReader`:
- An AVIF with an Exif item is read, and its values are labelled "HEIF". No AVIF sample
  exists, and ADR-017 §13 claims support only with a real sample.
- A sequence-only file (`ftyp` + `moov`, with no top-level `meta`) reads as **`corrupt`**,
  which is a false statement about a file that may be valid.

The owner's HEIC (brand `heic`) is unaffected.

**Options:**
- (a) Keep the reader for still-image brands backed by the evidence (for example `heic`,
  `heix` and `mif1`), and make the others recognised only (unsupported), like the RAW
  formats.
- (b) Accept AVIF as the same container, and report "no meta box" as unsupported or nothing
  found rather than corrupt.

Either choice can join S2.V4.

### S2R-03 (NON-BLOCKING): current-state documentation contradicts newer records

**Documentation verified.** The S2V-05 pattern has recurred after S2.9, S2.R3 and the RG-14
decision:
- `FEATURE_STATUS.md` F-45:
  - "Current implementation (S2.8 plus S2.V1–S2.V3) … (DNG and JPEG)" leaves out HEIF;
  - "Known issues now: HEIC decision and RAW research remain open" is stale;
- `TEST_PLAN.md`, the metadata section: "No device or emulator is available on the
  development machine (2026-09-26)", although M1–M3 passed on the owner's phone.

The same kind of stale statements in `PROGRESS.md` ("Owner actions outstanding", "Known
blockers", the RG-01 row, the missing hash of the RG-14 commit) were brought up to date by
this session. Keeping the Stage state current is a duty of `PROGRESS.md` at a Stage boundary.

**Proposed S2.V5** (documentation only, S): correct F-45 and `TEST_PLAN.md`, and keep the
history.

### S2R-04 (LOW): HEIF test coverage lags the shared-extractor guarantees

The HEIF suite has no read-log GPS assertion, and no S2V-01/S2V-02 cases through its
container, although its fixture carries a GPS IFD. Probes P2–P4 show that the behaviour is
correct today. **Proposed:** add these three cases as tests with S2.V4.

### Not findings

- **No scope drift.** There is no Equipment write, persistence, network call, decoding,
  MakerNote or inferred zone. RAW stays recognition only.
- **`getUint64` sizes in HEIF can overflow `start + length`.** Checked by reading the code:
  the resulting negative window length is refused by `MetadataSourceWindow` as `truncated`.
  That is typed, not a crash.
- A file cut before `meta` reads as `corrupt` ("no meta box") rather than `truncated`. It is
  still typed, and it never reads as complete (the sweep test covers this).

## Verdict

**FAIL.** DNG, JPEG, the Android channel, the privacy rules, unknowns and the hidden gate all
meet the exit. The first validation's S2V-01 to S2V-04 are resolved. The HEIF reader can be
driven to unbounded memory and time by a small crafted file (S2R-01), so the foundation
cannot be accepted yet.

**Proposed follow-up (not implemented; each needs the owner):**
1. S2.V4: bound the HEIF `iloc` work (S2R-01), with the S2R-04 tests, and the S2R-02 ruling
   if the owner makes it;
2. S2.V5: documentation reconciliation (S2R-03).

Then Stage 2 needs either another independent validation or an owner waiver. Stage 3 does
not start from this verdict.
