# AstroPlan Product Specification

## Product Identity

AstroPlan is a mobile astrophotography session planner and computational
logbook. Its purpose is to help an astrophotographer decide what can be
captured with a selected rig, target, location, night conditions, and available
time.

AstroPlan complements astronomy and imaging tools. It is not intended to become
a full planetarium, AR sky-navigation app, camera live-view app, or camera
remote-control system.

## Core Workflow

```text
Equipment
  -> Target
  -> Location + Night Conditions
  -> Visibility / Feasibility
  -> Capture Plan
  -> Actual Session
  -> Logbook
  -> Processing Record
```

## MVP Scope

- Equipment profiles with device, camera module, sensor, optics, and tracking
  information.
- Saved locations and manually selected observing locations.
- Astronomical timeline: sunset, sunrise, twilight stages, moonrise, moonset,
  lunar phase, and lunar illumination.
- Target catalog focused first on a practical curated subset.
- Target visibility: altitude, rise/set, culmination, minimum altitude windows,
  and Moon-target separation.
- Session planner with capture blocks, frame accounting, integration time,
  estimated duration, storage estimates, and feasibility.
- Weather display using provider-isolated raw/normalized variables.
- Logbook for planned versus actual sessions.
- Metadata import where file-format behavior has been experimentally verified.

## Explicit Non-Goals For MVP

- Full planetarium or interactive sky browser.
- AR sky navigation.
- Camera live view or camera control.
- Embedded Stellarium.
- Advanced polar alignment.
- Advanced focus utility.
- Absolute physical SNR modeling.
- Massive astronomical catalogs.
- Social/cloud synchronization.

## Scientific Integrity

AstroPlan must distinguish measurements, calculations, estimates, and
user-provided assumptions. Scientific-looking numbers must not be presented
without model assumptions, units, input ranges, and tests.

Required calculation discipline:

- FOV and pixel scale must state input and output units.
- NPF, when implemented, must be labeled as a recommendation, not an absolute
  exposure limit.
- Relative stacking gain must be labeled as relative stacking gain, not
  absolute SNR.
- Storage estimates must distinguish theoretical pixel payload from empirical
  average frame-size estimates.
- Dew warning thresholds must not be presented as universal scientific truth.

## Current Implementation Note

The current repository already contains implementation for several later
roadmap areas, including weather, metadata import, logbook, light-pollution
handoff, field mode, and sharing. These features should be reviewed before
further expansion to decide whether they are approved scope or should be
temporarily hidden/rolled back.
