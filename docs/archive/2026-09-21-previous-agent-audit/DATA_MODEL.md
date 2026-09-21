# Data Model

The data model is well separated between Domain Models (used in business logic/UI) and Drift Data Classes (used for persistence).

## Core Entities

### Target
- **File:** `lib/domain/models/astro_target.dart`
- **Fields:** `id`, `catalogId`, `commonName`, `rightAscension`, `declination`, `type`.
- **Persistence:** `TargetsTable` in Drift.
- **Relationships:** Used independently. Session Logs store the `targetName` rather than a hard foreign key to allow flexibility.
- **Used?** Yes, heavily used in visibility calculations and session planning.

### Equipment Profile
- **File:** `lib/domain/models/equipment_profile.dart`
- **Fields:** `id`, `name`, `manufacturer`, `cameraModel`, `sensorWidth`, `sensorHeight`, `pixelPitch`, `resolutionWidth`, `resolutionHeight`, `focalLength`, `aperture`, `averageRawFileSizeMB`, `rotation`.
- **Persistence:** `EquipmentTable` in Drift.
- **Relationships:** Independent.
- **Used?** Yes, used to calculate FOV, pixel scale, NPF exposure, and storage estimates.

### Capture Block
- **File:** `lib/domain/models/capture_block.dart`
- **Fields:** `id`, `sessionLogId`, `frameType` (enum: light, dark, flat, bias), `filterName`, `exposureTimeSeconds`, `frameCount`, `binning`, `gainIso`.
- **Persistence:** Serialized to JSON via SharedPreferences for the active plan; serialized as JSON inside Drift for SessionLogs.
- **Used?** Yes, core to estimating total integration time and storage.

### Session Log
- **File:** `lib/domain/models/session_log.dart`
- **Fields:** `id`, `targetName`, `equipmentName`, `sessionDate`, `locationName`, `bortleScale`, `captureBlocks`, `plannedLightFrames`, `integrationTimeSeconds`, `focalLength`, `aperture`, `temperature`, `humidity`, `cloudCover`, `actualLightFrames`, `rejectedFrames`, `environmentalNotes`, `processingNotes`.
- **Persistence:** `LogbookTable` in Drift.
- **Relationships:** Contains a snapshot of the equipment, location, and capture plan at the time of the session.
- **Used?** Yes, it is the primary entity for the Logbook screen. Contains serialization logic `toShareableText` and `toJson`.

### Weather Conditions
- **File:** `lib/domain/models/weather_conditions.dart`
- **Fields:** `temperature`, `humidity`, `dewPoint`, `cloudCover`, `windSpeed`, `hourlyForecasts`, `lastUpdated`.
- **Persistence:** Cached via SharedPreferences in `OpenMeteoWeatherRepository`.
- **Used?** Yes, powers dew warnings and environmental snapshots in session logs.

### Location Profile
- **File:** `lib/domain/models/location_profile.dart`
- **Fields:** `id`, `name`, `latitude`, `longitude`, `elevation`, `bortleClass`.
- **Persistence:** `LocationsTable` in Drift.
- **Used?** Yes.

## Missing/Future Entities
- **Camera/Lens/Telescope isolation:** Currently lumped into a singular `EquipmentProfile` which represents an entire "Rig". The system does not natively separate optical tubes from cameras as individual entities that combine into rigs.
