# AstroPlan Test Plan

## Required Checks

For meaningful implementation changes, run:

```text
flutter analyze
flutter test
```

For release or platform-sensitive changes, also run the relevant Android build
and device/emulator verification.

## Unit Tests

Use unit tests for:

- domain calculations;
- unit conversions;
- repositories;
- parsers;
- validation;
- data mapping.

Calculation tests must include input units, expected output, tolerance, and a
reference/source when the result is scientific or astronomical.

## Database Tests

Use database tests for:

- table creation;
- repository CRUD behavior;
- constraints;
- migrations;
- preservation of existing data after schema upgrades.

## Widget Tests

Use widget tests for:

- app boot;
- important screen states;
- reusable UI components;
- critical interaction flows where practical.

## Future Integration Tests

Eventually test the core scenario:

```text
Create/select equipment
  -> Create/select target
  -> Select location/date
  -> Create capture block
  -> Calculate integration/storage/relative stacking gain
  -> Save session
  -> Retrieve session/log
```

## Current Verification Snapshot

At the time these docs were created, `flutter test` passed. `flutter analyze`
reported one deprecated API usage in the target selection screen. This snapshot
is informational and should be rechecked after each change.
