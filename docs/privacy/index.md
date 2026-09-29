---
title: Astro Planner — Privacy policy
---

# Astro Planner — Privacy policy

*Effective 24 September 2026; updated 26 September 2026 ("Add from a photo"). Applies to
Astro Planner for Android
(`io.github.chacha12.astroplanner`).*

Astro Planner is a free, open-source planner and logbook for astrophotography. It has
**no account, no advertising, no analytics and no tracking**, and it contains no
third-party advertising or analytics code.

## What stays on your device

Your observing sites, equipment, targets, capture plans, sessions and their results,
notes and settings are stored **only on your device**, in the app's private storage. The
developer has no server and receives none of it.

- A **backup** or an **export** is created only when you ask for one, and goes only where
  you send it (for example a file location or an app you choose in the share sheet).
- Android's own device backup may include the app's data, according to your device's
  backup settings.
- Uninstalling the app, or clearing its data in Android's settings, deletes everything it
  stored.
- **Add from a photo** reads a few kilobytes of the header of a photo or RAW file you pick,
  on the device, to suggest a rig. The file is not copied or uploaded. Nothing is saved
  unless you save the rig, and then only the camera's make and model and the optical
  values are kept. The file's location data and serial numbers are never read.

## Location

The app asks for location permission **only when you choose "use current position"**,
and only while you use the app (never in the background). You can instead type
coordinates or pick a point on the map; the app works without the permission. A position
you choose is kept on your device.

## What is sent over the internet, and to whom

The app works offline. When it is online it contacts these services directly from your
device, over encrypted connections (HTTPS). Each receives your device's IP address, as
any internet request does.

| Service | When | What it receives |
| --- | --- | --- |
| **Open-Meteo** (open-meteo.com), weather forecasts | when a site is set and the forecast for a night is loaded or refreshed | the site's latitude and longitude, and the night's hours. Open-Meteo states that it keeps IP addresses in server logs for 90 days, not linked to identities ([terms](https://open-meteo.com/en/terms)). |
| **OpenStreetMap tile servers** (tile.openstreetmap.org), map images | while you look at the map to pick a position | the map tiles for the area on screen ([policy](https://operations.osmfoundation.org/policies/tiles/), [privacy](https://osmfoundation.org/wiki/Privacy_Policy)) |
| **OpenStreetMap Nominatim** (nominatim.openstreetmap.org), place names | **only if you switch on "Look up place names" in Settings** (off by default) | the chosen position, rounded to about 1 km ([policy](https://operations.osmfoundation.org/policies/nominatim/), [privacy](https://osmfoundation.org/wiki/Privacy_Policy)) |

Links you open yourself (the light-pollution map at lightpollutionmap.app, which receives the
site's or the typed coordinates in the link; the data sources' pages; this policy) open in your
browser; the site you visit then receives what your browser sends.

Requests identify the app by name and version (its "user agent"), as these services ask.
They carry no account, advertising or device identifier.

## Children

The app is not directed at children and collects no personal information from anyone.

## Changes

A change to this policy is published on this page with a new effective date.

## Contact

Questions about this policy: **&lt;CONTACT EMAIL&gt;**

Source code (GPL-3.0): <https://github.com/chacha12/astro-planner>
