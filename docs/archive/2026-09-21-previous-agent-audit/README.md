# ARCHIVE — Superseded documents (do not use as a source of truth)

**Status: Deprecated / historical record.**

These six files are the documents written by the previous AI agent's first
"as-is" audit, preserved **verbatim** (byte-identical copies) on 2026-09-21 just
before they were replaced by the reconciled documentation set in `docs/`.

They are kept because:

- they were never committed to Git, so this folder is their only copy;
- the project rule is not to delete information merely because it is
  inconvenient;
- they document what the previous audit believed, which explains several
  errors found later.

## Why they are superseded

A code-level re-audit on 2026-09-21 (commit `900b82a`) found statements in these
files that are **wrong or incomplete**. The full, evidence-backed list is in
[`docs/PROJECT_AUDIT.md`](../../PROJECT_AUDIT.md), section "Documentation
discrepancy log". Examples:

- The `integration_flow_test.dart` failure was blamed on an un-mocked HTTP client.
  The real cause is a test-harness async-zone problem plus an unguarded
  `Geolocator` call; HTTP is not involved.
- Equipment persistence was described as one flat table. It is actually a
  normalized Device → CameraModule → OpticalRig chain (1:1:1 per profile); the
  flat table is orphaned.
- Capture blocks were described as JSON inside Drift. They are a relational table.
- Light pollution was described as "brittle scraping". The request URL is never
  interpolated, so it can never succeed.
- Several features were labelled "Implemented" that do not fully work (logbook
  snapshots, dew warnings, configurable minimum altitude, metadata import).
- The committed design-intent content (layering rules, migration rules, ADR-006
  `FeatureScope` gating, pending decisions) had been overwritten by these files.
  That intent is restored in the current docs.

## Where the current truth lives

| Topic | Current document |
| --- | --- |
| Orientation for a new agent | `docs/PROJECT_HANDOFF.md` |
| Architecture (current vs target) | `docs/ARCHITECTURE.md` |
| Data model (current vs future) | `docs/DATA_MODEL.md` |
| Feature registry | `docs/FEATURE_STATUS.md` |
| Technical debt | `docs/TECH_DEBT.md` |
| Decisions / ADRs | `docs/DECISIONS.md` |
| Scientific issues | `docs/SCIENTIFIC_INTEGRITY.md` |
| Audit evidence | `docs/PROJECT_AUDIT.md` |

The Phase 0 originals of `ARCHITECTURE.md`, `DATA_MODEL.md` and `DECISIONS.md`
are also recoverable from Git history: `git show 900b82a:docs/<FILE>.md`.
