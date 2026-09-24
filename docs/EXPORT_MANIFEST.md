# AstroPlan export manifest — version 2

> **Verification stamp:** written 2026-09-24 for TASK 14.3 (commit recorded in
> `docs/ROADMAP.md`), against `lib/data/export/session_manifest_codec.dart`.
> The codec is the source of truth; this document describes it.

A manifest is a UTF-8 JSON file (`astroplan-sessions-<UTC date and time>.json`)
shared from a session's detail (**Export file**, one session) or the Sessions tab
(**Export all**, every saved session, legacy logs included). Import is deferred.

## Conventions

- **Instants** are UTC epoch milliseconds (`…_utc_ms`); never local time.
- **Night key**: `evening_date` (`YYYY-MM-DD`, ADR-007) with `time_zone_id` (IANA,
  or null for mean solar time). The night's UTC window is in the snapshots.
- **Units** are in the key (`exposure_s`, `temperature_c`, `humidity_pct`,
  `focal_length_mm`, …).
- **Unknown is null**, never 0 or a default (SI-008).
- **Snapshots** (`plan_snapshot`, `execution_start_snapshot`) are embedded exactly as
  stored (their own versioned format, `"v": 1`, ADR-014 §4).

## Top level

| Key | Type | Meaning |
| --- | --- | --- |
| `manifest_version` | int | `2` |
| `app` | string | `"AstroPlan"` |
| `app_version` | string | `pubspec.yaml` version without the build number |
| `exported_at_utc_ms` | int | when the file was written |
| `sessions` | array | one object per session, below |

## Session

| Key | Type | Meaning |
| --- | --- | --- |
| `id` | int | the session's id on the exporting device |
| `status` | string | `draft`, `planned`, `inProgress`, `completed`, `abandoned` |
| `legacy` | bool | saved before v16 (or without a night key): stored text only |
| `evening_date`, `time_zone_id` | string? | the night key |
| `site_id`, `target_id`, `rig_id` | int? | references on the exporting device (may be null) |
| `created_at_utc_ms` … `completed_at_utc_ms` | int? | lifecycle instants (`created`, `updated`, `planned`, `started`, `completed`) |
| `labels` | object | `target`, `rig`, `site`, `session_date_utc_ms` — display labels, never used to resolve references |
| `blocks` | array | `id`, `frame_type`, `filter_name`, `exposure_s`, `frame_count`, `binning`, `gain_kind`, `gain_value`, `calibration_policy`, `confirmed_frames`, `rejected_frames` (counts replayed from `events`; null when the events do not replay) |
| `results` | object | `planned_light_frames`, `actual_light_frames`, `rejected_frames`, `environmental_notes`, `processing_notes`, `temperature_c`, `humidity_pct`, `cloud_cover_pct` |
| `legacy_values` | object | pre-v16 columns kept for legacy logs: `bortle_scale`, `focal_length_mm`, `aperture_f` (focal ratio), `integration_time_s`, `planned_dark_frames`, `planned_flat_frames`, `planned_bias_frames` |
| `plan_snapshot`, `execution_start_snapshot` | object? | the stored snapshots |
| `events` | array | the run's append-only events (ADR-016 §4), by `seq`: `seq`, `at_utc_ms`, `kind`, `block_id`, `delta`, `reason`, `clock_adjusted` |

## Versions

- **v2** (TASK 14.3): this document.
- **v1** (before TASK 14.3; `SessionLog.toJson`): one session, local-time based, no
  status, night key, zone or snapshot. Still readable; it is read as one completed
  **legacy** log.
- Any other version is refused (`FormatException`), never guessed.

## Guarantees (tested)

- An exported file re-parses identically: encode → JSON text → decode → encode gives
  the same JSON (`test/data/export/session_manifest_codec_test.dart`).
