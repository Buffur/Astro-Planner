# General Objective

A comprehensive audit of the application is required from the perspective of UI/UX, user-flow logic, feature practicality, and technical optimization.

At the moment, many parts of the application still feel unfinished: the interface is visually flat, there is a lot of visual noise, elements often lack clear hierarchy, some screens are overloaded with information, and certain workflows require too much manual input from the user.

The goal is not simply to make cosmetic UI changes, but to reconsider the application's logic, remove unnecessary actions, automate the retrieval of data wherever possible, and make the overall experience clearer and more practical.

At the same time, the application's core visual direction, inspired by Notion, should be preserved. However, this does not mean we should become constrained by the current concept. New solutions and proven patterns from other popular applications can be introduced where they improve the UX without breaking the core design language.

---

# 1. Logo and Loading Screen

## Logo

I like the idea behind the vector design, but I do not like its current implementation.

We need to:

- analyze the current logo;

- propose several possible alternatives;

- choose a direction and then update the logo accordingly.

## Loading Screen

The loading/splash screen could be animated.

We should consider a subtle animation that matches the application's visual style without feeling excessive or distracting.

---

# 2. Home Screen

The placement of elements on the home screen and the overall user flow need to be reconsidered.

### Current Element Priority

Why is Geolocation positioned almost as the first element, while Planner is located near the bottom?

The visual and functional hierarchy of the home screen should be reconsidered based on which actions are actually the most important to the user.

### Draft / Planner

Why is a separate Draft necessary, followed by a suggestion to open Planner, when the user could simply open Planner directly and see essentially the same information?

We should determine whether Draft genuinely needs to exist as a separate stage or whether its functionality should be integrated directly into Planner.

### Night / Moon / Weather

Currently, tapping `Night`, `Moon`, or `Weather` redirects the user to the Planner page.

This does not feel particularly logical.

Possible approaches to consider:

- redirect the user directly to the corresponding section inside Planner;

- move these blocks into a separate tab, such as `Analytics`;

- reconsider their purpose on the home screen entirely.

We need to determine which approach produces the most logical user flow.

---

# 3. Start / Plan Execution

When the user taps `Start`, a separate page opens for executing the plan.

I do not see much value in having an entire dedicated tab/page for this workflow, especially considering the manual controls such as:

`-1`, `+1`, `Reject`, `Pause`, etc.

In a real observing or imaging session, the user is unlikely to continuously report the completion of individual actions through the application.

### Proposed Direction

This workflow should either be significantly simplified or removed.

For example:

- Planner creates the plan;

- the user carries out the session;

- after the session, or at a later time, the user opens Logbook;

- the result can then be marked as:
  
  - `Completed`
  
  - `Not completed`

The main purpose of Logbook should be to maintain a history of created events/sessions rather than forcing the user to continuously report every action during the session itself.

This workflow should be analyzed to determine how it can be simplified.

---

# 4. What Can I Image Tonight?

The idea itself is interesting, but the current implementation does not feel practical.

Having an object catalog is extremely useful. However, requiring users to manually enter:

- degrees;

- names;

- coordinates;

- other technical parameters

is inconvenient.

The main problem is that users first have to search elsewhere for most of this information.

## Proposed Solution

Consider significantly expanding the catalog.

Ideally, it should include:

- full search functionality;

- autocomplete suggestions;

- intelligent search.

Search should work not only by an object's catalog designation but also by its common name.

For example:

`M31` → `Andromeda Galaxy`

The same principle should apply to the object catalog inside Planner.

---

# 5. New Session

What is the purpose of the `New Session` button if the user can already enter Planner from the home screen?

The button itself may have a valid purpose, but the application currently does not clearly communicate whether the user is creating a new session or opening an existing one.

Planner also contains a `+` button that provides no clear feedback when the user interacts with it.

We need to:

- clearly define the difference between opening an existing plan and creating a new session;

- visually communicate the current state to the user;

- provide clear feedback after tapping `+` or `New Session`.

---

# 6. Geolocation

Currently, when selecting or creating a location, the application requires:

- Name

- Coordinates

- Elevation

- Bortle

- SQM

- Notes

Each field should be reconsidered individually.

## Name

The location name should be determined automatically from geolocation data while still allowing the user to edit it manually.

## Coordinates

Coordinates should be determined automatically.

## Elevation

Why is this a required field?

Most users simply do not know the elevation of their current location.

We should either:

- retrieve it automatically;

- or avoid requiring the user to provide it at all.

## Bortle

Can the Bortle value be obtained automatically based on the selected location?

If there is a reliable source, API, or another method for retrieving this value automatically, manual input should be removed.

## SQM

Why do we need this information?

If SQM is required for calculations:

- why should the user enter it manually?

- how is an average user supposed to know this value?

- can it be retrieved or estimated automatically?

- if it cannot be obtained automatically, should this field even be exposed to the user?

The actual necessity of SQM needs to be determined.

## Notes

Why are notes necessary specifically for a location?

If they are genuinely useful, they can remain, but their visual implementation should be improved.

The underline/divider beneath the field should also be fixed or repositioned.

More generally, the underline styling used for input fields should be reconsidered. At the moment, these lines are too visually prominent.

Review:

- thickness;

- contrast;

- spacing;

- whether the lines are necessary at all.

---

# 7. Typography and Visual Hierarchy

There is a broader issue with text hierarchy throughout the application.

In many places, nearly all text is white, which causes:

- elements to blend together;

- secondary information to appear just as important as primary information;

- screens to feel visually overloaded.

A full typography audit is needed, including:

- primary / secondary / tertiary text;

- contrast;

- font sizes;

- font weights;

- spacing;

- visual hierarchy;

- information grouping.

The goal is to make the interface significantly easier to scan and understand without moving away from the application's overall visual style.

---

# 8. Planner

## Title

The title does not fit properly and is truncated:

`Session plan...`

This needs to be fixed.

## `+` Button

The button currently provides insufficient visual feedback when pressed.

Clear interaction feedback should be added.

## Date Selection

The current date-selection icon is not intuitive.

A clearer solution should be considered.

---

# 9. Targets

The same catalog problem appears here.

We should:

- expand the available object pool;

- introduce intelligent search;

- support searches by both catalog designation and common object name.

For example:

`M31` → `Andromeda`

## Adding a Target

The application currently asks the user for too much information.

This is especially problematic with required fields such as:

- Right Ascension (J2000)

- Declination (J2000)

The user has to search for these values elsewhere before they can add the object.

We need to determine which data actually needs to be entered by the user and which information can be retrieved automatically from the catalog.

---

# 10. Tonight for This Target

The current implementation feels unfinished and visually flat.

## Graph

The graph itself is:

- visually unattractive;

- not sufficiently intuitive;

- not effective at helping the user quickly evaluate the situation.

## Information Block

There is either too much information or the information is not sufficiently separated visually.

Currently, the block feels:

- overloaded;

- poorly structured;

- difficult to understand at a glance.

The information should be redesigned around the principle:

**most important information first → details second.**

---

# 11. Equipment / How

Visually, this section feels unfinished and flat.

When opening the section, only `ZWO` appears to be offered.

We need to investigate:

- why only ZWO is available;

- whether equipment information can be retrieved automatically;

- whether specifications can be identified from the device name;

- whether data can be extracted from links;

- whether metadata or other available sources can be used.

Currently, the user is expected to manually enter too much information, and the large number of mandatory fields is particularly problematic.

Manual input should be reduced as much as reasonably possible.

---

# 12. Conditions & Timeline / How

The current screen looks extremely flat.

Almost everything is presented as continuous text despite the amount of information being displayed.

`Stargazing Hub` is a good example of a more effective approach. It uses:

- a concise timeline;

- clear visualization;

- weather icons;

- only the necessary information;

- strong visual hierarchy.

Similar solutions should be studied to determine how our data can be presented more clearly and compactly.

Currently, the screen combines:

- too much information;

- insufficient visualization;

- weak hierarchy;

- unclear relationships between different pieces of information.

---

# 13. Sky Darkness & Timeline

The same Bortle-related problem appears here.

Can Bortle information be obtained automatically based on location?

The information screen also feels:

- flat;

- overloaded;

- visually poorly structured.

It needs to become significantly easier to understand.

## Light Pollution Map

The redirect for the light pollution map currently points to a different source.

It should use:

[https://lightpollutionmap.app/](https://lightpollutionmap.app/)

---

# 14. Capture Plan

This is one of the sections that requires particularly significant redesign.

At the moment, it feels flat and overloaded. The amount of information creates visual clutter rather than helping the user.

## Example Plan

Why do we need an `Example Plan` with elements already inserted?

We need to determine whether this information actually provides value to the user in its current form.

## Icons

The following should be reconsidered:

- the icon with two horizontal lines;

- the delete icon.

The current delete icon does not feel particularly appropriate, and deletion happens immediately.

A safer and more intuitive deletion flow should be implemented.

---

# 15. Capture Plan Parameters

## Binning

Why does the user need to manually enter `Binning`?

Many users will not know their binning setting without searching for additional information.

We need to determine whether this parameter genuinely needs to be exposed in the interface and whether it can be detected automatically or removed from manual input.

## ISO / Gain

Why does the user have to choose between ISO and GAIN?

The actual requirements need to be determined.

For our intended workflow, the relevant controls are expected to include:

- ISO

- WB

- FOCUS

- interval between photos (optional)

For `FOCUS`, a slider could potentially be considered instead of standard numerical input.

---

# 16. Dark / Flat / Bias

Currently, when selecting `Dark`, the application asks for too many parameters.

Many of these values can already be inherited from `Light`.

Therefore, for Dark frames, it may be sufficient to specify only:

- the number of frames.

The same should be investigated for:

- Flat;

- Bias.

The actual real-world workflows for creating Flat and Bias frames should be researched.

Based on that research:

1. expose only the parameters that users genuinely need to control;

2. provide a short explanation of how these calibration frames are created;

3. allow these tips/instructions to be disabled.

The interface should not turn into a large tutorial occupying half of the screen.

---

# 17. Outputs in Capture Plan

The `Outputs` block currently feels like visual noise:

- almost everything uses the same color;

- the text is small;

- too much information is displayed;

- hierarchy is weak.

The presentation should be redesigned.

## Total Time

Useful and should remain.

## Time Including Intervals Within the Sequence

Useful and should remain.

## Setup / Calibration Time

Why is this value needed?

We need to determine whether it provides genuinely useful information to the user.

## Total Integration Time

Should we calculate the final integration time?

If so, it should be clear and visually prominent.

## Fit Tonight

What exactly does this mean?

What practical value does this metric provide to the user?

Its purpose needs to be determined and, if it remains, communicated clearly.

## Relative Stacking Gain

This appears to be one of the core useful features.

Essentially, it represents the efficiency/benefit of stacking.

I would like this section to include a:

- visually appealing;

- compact;

- easy-to-understand graph;

rather than relying only on textual values.

### Large Information Tip

The current explanation takes up too much space.

It would be better to make it:

- collapsible;

- available on tap;

- or optional.

## Estimated Storage

Currently, this does not appear to be calculated at all.

The calculation needs to be fixed.

## Assumptions

We need to determine:

What exactly is this section supposed to provide to the user?

At the moment, it blends into the rest of the content and creates additional visual noise.

---

# 18. Settings

A separate, comprehensive audit of Settings is required.

We need to evaluate:

### Practicality

How well do the available customization options correspond to real-world usage?

### Clarity

How clearly can users understand what each setting actually does?

### Visual Presentation

How easily can users scan and understand the information?

### Real-World Needs

How closely do the available settings match the actual needs of amateur and professional users?

This analysis should be informed by the real-world experience of amateur and professional astrophotographers and supported by reliable sources.

We should also determine whether the current Settings section adequately covers application-wide settings or whether some settings would be more appropriate directly within their respective sections.

---

# 19. Library

Visually, Library is interesting, but its practical purpose needs to be evaluated.

### Equipment

Why can the user select their device here?

If this is intended to define the user's primary/default device for Planner, that could make sense.

However, Planner itself also allows the user to select equipment.

We should consider whether this workflow is unnecessarily duplicated and determine what the intended data model should be.

### Target

Why is Target selection available in Library?

The practical purpose of this action needs to be determined.

### Geo

Geolocation makes sense here.

### Progress

Progress is connected to the separate `Start` workflow, whose overall logic has already been questioned above.

We need to determine whether this is another unnecessary duplication.

---

# 20. Object Deletion and Animations

In Devices, Objects, Logbook, and generally everywhere deletion is available, the current animation does not look correct.

Currently:

- the object flies/slides to the right;

- a red block appears;

- a deletion confirmation remains visible afterward.

The entire interaction feels unfinished.

We need to:

- redesign the deletion animation;

- make the interaction feel more natural;

- redesign the confirmation UI.

The deletion confirmation itself also looks visually unfinished.

---

# 21. Tracked

`Tracked` should not be a global device setting.

It should instead be a selectable option directly inside Planner.

The reason is that if a user wants to change this parameter for a specific session, forcing them to repeatedly open the device settings is inconvenient.

The setting should therefore belong to a specific plan/session rather than to the global equipment configuration.

---

# 22. Forms and Data Entry

Most forms throughout the application feel visually flat and unfinished.

There is also a technical performance issue:

the application noticeably lags when the user taps into editable text fields.

This is particularly noticeable when entering device information.

The following should be investigated separately:

- form performance;

- keyboard handling;

- unnecessary rebuilds;

- animations;

- screen state management;

- number of simultaneously rendered components;

- delays when opening the keyboard.

---

# 23. Authorship and Links

I want my authorship to be displayed more prominently.

The following links should be added:

GitHub:  
https://github.com/Buffur

Reddit:  
https://www.reddit.com/user/Buffur/

Reddit is particularly important.

The current license also needs to be reviewed.

Requirements:

- the application is free;

- monetization is not permitted;

- third-party modifications/alterations to the project are not permitted without the author's explicit permission.

We need to:

- verify whether the current license actually satisfies these requirements;

- propose an appropriate alternative if necessary;

- review the existing `Sources` section again for correctness;

- verify that links, attribution, and source information are properly presented.

---

# 24. Logbook

Logbook also requires redesign.

## Session Names

Add the ability to give sessions custom names.

This field should be optional.

## Search

Add search functionality.

## Filters

The current filters occupy too much space.

They should preferably be grouped under a dedicated filter icon/panel instead of displaying many separate buttons.

## Share

When the user taps `Share`, the textual information looks too flat.

We should consider how the shared output can be made more visually appealing and better structured.

## Download Logo

When the user taps `Logo Download`, it is unclear:

**What exactly are we downloading?**

The content/action should either:

- be clearly identified;

- or the functionality should be reconsidered.

A download history could also potentially be considered.

## Opening a Logbook Entry

When opening an entry in Logbook, the `Open-traker` tab/page appears again.

This page is not particularly successful in its current form and should be redesigned according to the broader UX and workflow requirements described above.

---

# 25. Overall UI/UX Audit

This should be treated as a major standalone task rather than as a collection of minor visual fixes.

The following problems are currently noticeable throughout the application:

- unfinished UI;

- overly flat components;

- excessive visual noise;

- weak visual hierarchy;

- too much information displayed at once;

- text that is too small in some areas;

- primary and secondary information often having the same visual weight;

- insufficient feedback after user actions;

- too much manual data entry;

- unnecessarily complicated workflows;

- duplication of functionality in several areas.

We need to systematically study and apply good interface design principles across the project.

At the same time, it is important to:

**Preserve the application's core visual identity and its Notion-inspired concept.**

However:

**We should not become constrained by the existing design.**

We can:

- introduce new UI patterns;

- adopt successful solutions from popular applications;

- improve visual hierarchy;

- use more modern component patterns;

- redesign entire screens where the current concept is not working effectively.

The main goal is to make the interface:

- clear;

- lightweight;

- visually structured;

- practical;

- modern;

- uncluttered.

---

# 26. Performance and Application Size

The application currently takes up approximately **277 MB**.

We need to analyze its size and determine:

- what accounts for most of the application size;

- which assets can be optimized;

- whether there are unused dependencies;

- whether the Flutter application size can be reduced;

- whether images, fonts, and other resources can be optimized;

- whether unnecessary libraries are included;

- whether appropriate release/build optimizations can be applied.

The primary requirement is:

**Reduce the application size without sacrificing existing functionality.**

The existing UI and form performance issues should also be investigated separately, especially lag during data entry, since this is not only a UX problem but also a performance issue.

---

# 27. Task Priorities

The entire audit should preferably be divided into several levels.

## Critical Issues

Issues that directly affect usability:

- excessive manual data entry;

- duplicated workflows;

- unclear Planner / Start / New Session logic;

- lack of location-data automation;

- overloaded Capture Plan;

- poor information presentation;

- form lag;

- deletion UX issues;

- incorrect placement/logic of `Tracked`.

## UI / UX Redesign

- Home screen;

- Planner;

- Targets;

- Conditions & Timeline;

- Sky Darkness;

- Capture Plan;

- Logbook;

- Settings;

- Library;

- forms;

- typography;

- visual hierarchy;

- animations and interaction feedback.

## Automation

Reduce manual input as much as possible through automatic retrieval or detection of:

- geolocation data;

- Bortle;

- elevation;

- object names;

- coordinates;

- equipment specifications;

- other information that can reasonably be obtained from catalogs, APIs, metadata, or other reliable sources.

## Design System

A consistent set of rules should be established for:

- typography;

- colors;

- spacing;

- cards;

- forms;

- buttons;

- icons;

- dividers;

- alerts;

- dialogs;

- animations;

- feedback states.

These rules should then be applied throughout the application rather than fixing each screen independently.

## Technical Optimization

- performance;

- form lag;

- Flutter build optimization;

- asset optimization;

- reducing the current ~277 MB application size;

- dependency review.

---

# 28. Final Objective

The goal is not simply to fix the individual visual issues listed above, but to perform a comprehensive application audit centered around three main questions:

1. **Which features are genuinely useful to the user?**

2. **Which data can the application retrieve automatically instead of requiring manual input?**

3. **How can the remaining information be presented in the clearest, most compact, and visually polished way possible?**

After the analysis, an updated application structure should be proposed, followed by a gradual redesign of the interface and UX while preserving the project's core concept and Notion-inspired visual identity.

All decisions should be based primarily on real-world usage scenarios for amateur and professional astrophotography/observing users, rather than simply keeping features for the sake of having them.
