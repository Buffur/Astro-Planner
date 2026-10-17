# RA.R2b — Capture Plan science and model (R6, R7, scientific part of R3)

> **Status:** research, 2026-10-17. Step R2b of the approved plan
> `refinement/prompts/RA_R2_RESEARCH_PLAN.md` §3. **Nothing here is decided:** every option is
> only an input to RA.D. Code, schema, tests and other documents were not changed.
>
> **RA.R1 rows:** RA-A02, A03, A04, A08, F05–F11, H02, scientific part of E01; conflicts K5, K6, K7
> (`RA_R1_PHASE_A_ASSESSMENT.md`).
>
> **Labels:** **FACT** — a source, code (`file:line`) or a calculation from the stated inputs.
> **INFERENCE** — the author's conclusion. **UNKNOWN** — not established.

## 1. Method

- **Read in the repository** (selectively, without a repeat audit):
  - the R2b plan;
  - the RA.R1 rows listed above;
  - ADR-009 §7 and §10 L6, ADR-010 (refraction policy, Moon), ADR-020 in full;
  - RG-11 §3–§8 and RG-10 §4 (reused; only the disputed points were refreshed);
  - SCIENTIFIC_INTEGRITY: SI-003, SI-004, SI-013, Part B (CALC-15, 16, 28, 29, 33, 41, 42, 43),
    Part C;
  - the exclusions in `PRODUCT_DIRECTION.md` §8 and `POST_ROADMAP_PLAN.md` (lines 2617–2619, 4004,
    5767–5769);
  - code: rig model, site, target, budget, √N curve, Moon, metadata contract, block dialog,
    example rig seed.
- **Moonlit** (`C:\Users\zalub\OneDrive\Desktop\52\moonlit-main`): `README.md` and
  `astronomy.js` were read as untrusted data. The code was not run and is not being ported: Moonlit
  has no licence for its own code (RA-E01).
- **Web:** WebSearch/WebFetch; the access date of every link is 2026-10-17 (§7).
  - **Did not load:**
    - USNO «RST definitions» (ECONNRESET, two attempts). The moonrise definition is taken from
      Meeus ch. 15, already checked by ADR-010 against USNO.
    - Craig Stark's articles on stark-labs.com (403).
    - Sheffield PHY241 lecture (404 after a redirect). The Dhillon lecture (Sheffield PHY217),
      with the same form of the equation, was used instead.
    - Android `ImageFormat` reference page: the navigation is too large to read.
      The AOSP `DngCreator` source and a secondary mirror were used.
  - **Not found:** documentation for the Telescopius and astronomy.tools calculators. Judging by the
    astronomy.tools navigation, it has no SNR or exposure calculator; this is a conclusion **from the
    description**, not a confirmation.
  - **Not available online:** Howell, «Handbook of CCD Astronomy». The book is cited as a reference, and
    the form of the equation was checked against the Dhillon lecture. The Merline & Howell (1995) paper
    was confirmed via its DOI; its text was not read.
- **Calculations:** formulas were written out by hand. Numbers were checked with a one-off calculator
  in the session scratchpad, without project code (Part C rule 3: values independent of the implementation).
- **The owner's samples were not re-read.** Dimensions, pixel count and DNG bit depth are taken from
  the recorded RG-01 (lines 39–41, 60–61). No other files in «Downloads» were opened.

## 2. Q1 — Absolute SNR

### 2.1 What exists today (FACT)

- **√N is relative and computed per group.** CALC-15: `√N` over the light frames of one group
  (filter × exposure); CALC-42 draws the √n curve for n from 1 to max(4, 2N).
- **The UI help states explicitly that this is not SNR.** Text: «is not a signal-to-noise ratio of your
  image», and the model ignores sky, target and camera
  (`lib/presentation/widgets/capture_plan/capture_budget_summary.dart:154-157`).
- **Inputs that are already stored:**
  - rig (`lib/domain/models/equipment_profile.dart`):
    - sensor size (26–27);
    - pixel pitch (30);
    - pixel count (33–34);
    - focal length (37);
    - f/N (40);
    - aperture diameter, nullable (44);
    - maximum exposure (55);
  - site: Bortle and SQM, nullable, with source and date (`location_profile.dart:94, 101`);
  - target: visual magnitude and major axis, both nullable (`astro_target.dart:30-33`).
- **What is nowhere in the model:**
  - QE and optical transmission;
  - read noise (it depends on gain/ISO);
  - dark current (depends on temperature);
  - gain in e⁻/ADU and full well;
  - filter bandpasses;
  - target surface brightness;
  - sky brightness with the Moon.
- **There is no external source of specifications.** RG-03 was decided as Q1 (`DECISIONS`, 9363ff5).
  All missing inputs would have to be entered by the user.
- **Prohibitions in force:**
  - `PRODUCT_DIRECTION.md:222` excludes «absolute physical SNR or exposure optimisation»;
  - `POST_ROADMAP_PLAN.md:2617` excludes «physical or estimated SNR», `:5767` requires that
    «√N stays relative»;
  - ADR-020 §9 excludes «exposure optimisation; any "optimal" setting»;
  - SI-003, action 4: a physical SNR model only through an ADR and per-camera gain/read noise
    data.

### 2.2 Physics (FACT from sources)

- **CCD equation** (Mortara & Fowler 1981; Howell 1989/2006; form per Dhillon, PHY217):
  `SNR = S·t·QE / √(S·t·QE + n_pix·(S_sky·t·QE + D·t + R²))`.
  - S — object photons per second;
  - S_sky — sky photons per second per pixel;
  - D — dark current, e⁻/s/pixel;
  - R — read noise, e⁻ (not Poissonian, hence squared);
  - n_pix — number of object pixels.
- **For an extended object**, per pixel (n_pix = 1, all signals already in e⁻):
  `SNR₁ = s·t / √(s·t + b·t + D·t + R²)`.
- **Regimes:**
  - background- or object-limited: SNR ∝ √t;
  - read-noise-limited: SNR ∝ t.
- **Stack of N identical subs with uncorrelated noise:** `SNR_N = √N·SNR₁`. Hence the
  relative √N is **exact as a ratio within a group** and says nothing about the absolute value (SI-003).
- **Exposure that "swamps" read noise.** The noise of a stack of N subs of length t with total time T = N·t
  grows relative to the ideal (no read noise) by a factor of `√(1 + R²/(P·t))`, where P is the background in
  e⁻/pixel/s. If a noise increase by a fraction E is allowed:
  `t_min = k·R²/P`, where `k = 1/((1+E)² − 1)`.
  - E = 5 % → k = 9.756 (hence the empirical «10·R²/P»);
  - E = 10 % → k = 4.762.
  - The derivation of the formula is an **INFERENCE** from the noise model above. It agrees with SharpCap: the optimal
    exposure is «proportional to the square of the read noise», and the 10 % limit is described there as a noise
    increase «from 10 to 11» (SharpCap 4.0, Smart Histogram). Robin
    Glover gives the rule «10 × R² / sky rate» in his post of 2022-09-18.
- **Converting SQM to background, e⁻/pixel/s** (INFERENCE: standard magnitude conversion; zero point
  — FACT per CfA and Bessell):
  `P = F₀ · Δλ · 10^(−0.4·SQM) · (π/4) · (206265 · p / N)² · η`.
  - F₀ ≈ 1000 photon·s⁻¹·cm⁻²·Å⁻¹ for V = 0. This is derived from 3640 Jy (Bessell 1979, CfA
    page); 1 Jy = 1.51·10⁷ photons (same page).
  - Δλ — bandpass in Å.
  - p — pixel in cm, N — f/N.
  - η = QE × transmission.
  - Aperture area × pixel solid angle = (π/4)·(206265·p/N)² cm²·arcsec², so the
    result depends on f/N and the pixel, not on the aperture alone.
- **Cross-check against Glover's post** (FACT for the post's numbers; the comparison is an INFERENCE):
  - post: Bortle 7, f/10, 6 µm pixel, QE 80 %, 3 nm filter → 0.14 e⁻/pixel/s;
  - with the formula above (Δλ = 30 Å, η = 0.8) the coefficient is 2.887·10⁶, and 0.14 is obtained at
    SQM ≈ 18.29, i.e. under a bright suburban-to-urban sky;
  - the correspondence to Bortle class 7 was not checked.
  - His own examples: at R = 6.5 e⁻ «about 3200s», at R = 1.5 e⁻ «170s or so». The formula
    10·R²/P gives 3017.9 s and 160.7 s: the discrepancy lies within his rounding.
- **Sky brightness depends on the Moon and the target's altitude** (SharpCap advises measuring the sky while pointed at the
  target). The site SQM is the moonless zenith. A model with the Moon (e.g. Krisciunas & Schaefer) is yet another
  input, and it conflicts with ADR-010: the Moon is a fact, not an "impact" (UNKNOWN for AstroPlan).

### 2.3 Options

| | O1 — relative √N (as now) | O2 — √N on an integration-time axis, still relative | O3 — SNR estimate from the CCD equation (optional) | O4 — minimum sub hint (read-noise swamping) |
| --- | --- | --- | --- | --- |
| **What it shows** | √N of a group relative to one of its frames | **O2a:** X axis — the group's integration time T = N·t, Y axis — √N. **O2b:** Y = √(T/T_plan), i.e. 1.00 at the plan, ×1.41 when doubled, ×0.71 when halved | A post-stack per-pixel SNR number, with a range | «Subs no shorter than ≈ X s, so that read noise adds ≤ E % noise» |
| **Required inputs** | N | N, t | s (target), b (sky), D, R, t, N, and for s and b also F₀, Δλ, η, p, f/N, SQM and target μ | R (at the chosen gain), P (from SQM, f/N, p, η, Δλ, or measured), E |
| **Available in AstroPlan** | yes | yes | p, f/N; SQM sometimes (nullable). No η, R, D, Δλ, target μ. Mean surface brightness from V and major axis is a rough estimate: no minor axis, nebulae often have no V (RG-07) | p, f/N; SQM sometimes. No R, η, Δλ |
| **Uncertainty** | none (exact statistics within a group) | none (same formula) | Large. ±0.5 mag SQM gives SNR from 8.8 to 12.8; ±0.5 mag of the target — from 6.9 to 16.3 (vectors R-SNR); combined — a spread of more than 2×. On top of that: sky spectrum, Bayer, extinction, Moon, vignetting | Moderate. A factor of about 1.5–2 from P (SQM, Δλ, η) and from R at a given gain (ASI2600: 0.9–4.2 e⁻ by gain, ZWO) |
| **Integrity risk** | low | low, if the label says «relative to your plan» | **high:** a precise-looking number built from guesses; temptation to read it as «image quality» | moderate: looks like an «optimum», which is explicitly excluded (ADR-020 §9) |
| **Wording constraints** | in force now (SI-003, Part C rule 6) | never «SNR». For example, «noise relative to plan», «√2 when time doubles». One curve for any group with a fixed exposure (√(N/N_plan) = √(T/T_plan)) | «model estimate», range only, all assumptions visible, no words «quality» or «enough», no colour rating (ADR-012) | «no shorter than», not «optimal»; only for a class and gain with an entered R; state explicitly that the target does not enter the calculation |
| **ADR / SI / CALC** | — | CALC-42 (axis and normalisation; same formula), ADR-009 §7, Stage 11 (√N stays relative — respected) | new CALC, new ADR, SI-003 action 4, SI-004 (gain as input), ADR-010 (Moon), lifting the exclusions in PRODUCT_DIRECTION §8 and POST_ROADMAP_PLAN:2617 | new CALC, ADR-020 §9 (lift the exclusion for this case), PRODUCT_DIRECTION §8, SI-004 |
| **Data and schema** | — | none | New camera fields: η, R(gain), D(T). Filter field: Δλ. Target field: μ. Migration; rig snapshot keys (additive); export v2 additive; backup — whole tables | Camera fields R and η; filter Δλ (or an assumption). Migration; additive snapshot and export keys |

### 2.4 Reference vectors (computed by hand; for O2, O3, O4)

**Common assumptions of the vectors** (all are explicit assumptions, not facts about the sky):
- F₀ = 1000 photon·s⁻¹·cm⁻²·Å⁻¹;
- Δλ = 1000 Å (one Bayer channel);
- η = 0.5.

**Rig** — the seed's example rig (`lib/data/services/equipment_seeder.dart:35-48`):
- ZWO ASI2600MC, p = 3.76 µm;
- 72 mm, f = 400 mm, N = 5.5556.

**Derived quantities:**
- scale = 206.265·3.76/400 = 1.938891″/pixel;
- Ω = 3.759298 arcsec²;
- aperture area = π·3.6² = 40.71504 cm².

| ID | Inputs | Expected result |
| --- | --- | --- |
| R-SKY-1 | SQM 20.0 | P = 1000·1000·10⁻⁸·40.71504·3.759298·0.5 = **0.765300 e⁻/pixel/s** |
| R-SKY-2 | SQM 21.5 | P = **0.192235 e⁻/pixel/s** (= R-SKY-1 × 10^(−0.6)) |
| R-SKY-G | Glover: Δλ 30 Å, η 0.8, N 10, p 6 µm | coefficient 2.887053·10⁶; P = 0.14 ⇔ SQM = **18.286** |
| R-SUB-1 | R-SKY-1, R = 1.5 e⁻, E = 5 % (k = 9.756098) | t_min = 9.756098·2.25/0.765300 = **28.68 s** (by the 10·R²/P rule: 29.40 s) |
| R-SUB-2 | R-SKY-1, R = 1.5 e⁻, E = 10 % (k = 4.761905) | **14.00 s** |
| R-SUB-3 | R-SKY-1, R = 3.5 e⁻, E = 5 % | **156.16 s** |
| R-SUB-4 | R-SKY-2, R = 1.5 e⁻, E = 5 % | **114.19 s** |
| R-SUB-5 | R-SKY-2, R = 3.5 e⁻, E = 5 % | **621.70 s** |
| R-SNR-1 | SQM 20.0; target μ 22.0 mag/arcsec²; D = 0.002 e⁻/s; R = 1.5 e⁻; t = 60 s; N = 120 | s·t = 7.2775, b·t = 45.9180, D·t = 0.12, R² = 2.25; σ = √55.5655 = 7.4543; SNR₁ = 0.97629; **SNR₁₂₀ = 10.695** |
| R-SNR-2 | as R-SNR-1, but μ = 21.5 | **16.336** |
| R-SNR-3 | as R-SNR-1, but μ = 22.5 | **6.917** |
| R-SNR-4 | as R-SNR-1, but SQM 19.5 / 20.5 / 21.5 | **8.781 / 12.828 / 17.322** |
| R-SNR-5 | as R-SNR-1, but t = 300 s, N = 24 (same 2 h) | s·t = 36.388, b·t = 229.590; SNR₁ = 2.2193; **SNR₂₄ = 10.872** |
| R-O2-1 | O2b, plan 120 × 60 s (T_plan = 2 h) | T = 1 h → **0.7071**; 2 h → **1.0000**; 4 h → **1.4142** |
| R-O2-2 | O2a, same group | N = 120 → √N = **10.954**; N = 240 → **15.492** (= √2·10.954, as in CALC-42) |

**What the vectors show:**
- **(FACT, from the numbers):** at the same T = 2 h, 60 s and 300 s subs give almost the same SNR
  (10.695 and 10.872): the sky dominates, and total time decides.
- **(FACT, from the numbers):** yet the relative √N for the same plans shows 10.95 and 4.90. This is
  the SI-003 limitation, and it is exactly why O2b normalises to the plan rather than to a single frame.
- **(FACT, from the numbers):** the absolute value changes by a factor of 2.4 (from 6.9 to 16.3) from ±0.5 mag
  of the target's surface brightness alone.

### 2.5 Recommendation and alternative (Q1)

- **Recommendation: O2, specifically O2b with the time axis from O2a.** The meaning of O1 is preserved.
  - This gives the shape of the owner's «SNR vs integration» concept: a time axis and a flattening curve.
  - No absolute number, no new inputs, no new formula. CALC-42 changes only its axis and
    normalisation.
  - Neither PRODUCT_DIRECTION §8 nor the Stage 11 row «√N stays relative» is violated.
  - The label cannot contain «SNR» (Part C rule 6).
- **Realistic alternative: O4** as optional reference information, only for the «Astro camera» class
  and only when the user has entered R themselves (at their gain) and an SQM or a measured background exists.
  - Requires the owner to lift the exclusions: «exposure optimisation» (PRODUCT_DIRECTION §8,
    ADR-020 §9) and SI-003 action 4.
  - Requires a new ADR and CALC with vectors R-SKY and R-SUB.
  - Gives a useful answer («subs no shorter than …») without claiming an absolute SNR.
- **O3 is not recommended** (INFERENCE). The uncertainty of the inputs exceeds the result itself (R-SNR-2,
  3, 4). Five of the six inputs would have to be entered by hand without a source (RG-03 = Q1). If
  the owner nevertheless chooses O3, then only as a range with a list of assumptions. A point value,
  as in the concept («SNR 10.1») — no.

## 3. Q2 — Storage volume

### 3.1 What the rig model stores (FACT)

- **Pixel count is required:**
  - `resolutionWidthPx`, `resolutionHeightPx` (`equipment_profile.dart:33-34`);
  - NOT NULL columns (`equipment_foundation_tables.dart:23-24`).
- **Average RAW size is optional:** `averageRawFileSizeMB` nullable (`equipment_profile.dart:47`;
  `equipment_foundation_tables.dart:26`), with per-field provenance (schema v18).
- **There is no bit depth, file format or compression.** Bit depth was removed in `900b82a` (SI-013).
- **Budget:** block size = `averageRawFileSizeMB × frameCount`, and without a size — null, i.e.
  «Unknown», never 0 (`capture_budget_calculator.dart:290-294, 370-373`; CALC-16, CALC-25).
  Binning and compression are ignored (ADR-009 L6).
- **The empirical path already exists:** choosing a DNG fills `averageRawFileSizeMB` with the file length as
  `estimated` (S3.8; ADR-018 D4; `DECISIONS.md:4350`). For JPEG, HEIC and FITS — no.
- **The metadata contract does not read BitsPerSample (258) and Compression (259)**
  (`lib/domain/metadata/exif_structure.dart:161-168`).
- **The schema is currently v25** (`app_database.dart:270`).

### 3.2 Theoretical versus empirical volume

- **Theoretical CFA-RAW volume** = W × H × b / 8 bytes, where **b is bits per sample in the container,
  not the ADC bit depth** (FACT):
  - The owner's samples (RG-01, lines 39–41, 60–61): 16 bits per sample, uncompressed, at white level 1023
    (10-bit data) and 16383 (14-bit).
  - The length of each file = W × H × 2 + exactly **6 700 bytes** (vector S1).
  - AOSP `DngCreator` writes BitsPerSample = 16 and Compression = 1 («uncompressed») and creates no
    EXIF sub-IFD: everything is in IFD0, as in the owner's samples. That the Xiaomi camera writes through
    `DngCreator` is an INFERENCE from the matching structure.
- **Android RAW10/RAW12** are packed 10- and 12-bit formats. `RAW_SENSOR` stores a sample in
  16 bits. FACT per a secondary documentation mirror and the AOSP source.
- **DNG can be compressed in general** (FACT, ExifTool, DNG 1.7):
  - Compression 7 — lossless JPEG for raw;
  - 34892 — lossy JPEG;
  - 52546 — JPEG XL (DNG 1.7, 2023).
  - The formula is exact only for Compression = 1.
- **DSLR/mirrorless.** Nikon D850 (manual): lossless compression reduces a NEF by roughly
  20–40 %, «compressed» by 35–55 %. For such a RAW the formula gives only an upper bound (FACT).
  - An uncompressed 14-bit file can sit in a 16-bit container. A user measured 97 MB for a
    D850 at 45.4 MP × 2 B = 90.9 MB, the rest being the preview. The measurement is the user's; the conclusion is an
    INFERENCE.
- **FITS** (FACT, the FITS standard per STScI and HEASARC):
  - data = |BITPIX|/8 × NAXIS1 × NAXIS2;
  - both header and data are multiples of a 2880-byte record;
  - BITPIX 16 — 16-bit integer, −32 — float (twice as large; usually stacks).
  - The ASI2600 has a 16-bit ADC (ZWO). The ZWO overview states about 50 MB per 1 × 1 frame.
- **JPEG/HEIC.** Lossy compression depends on content. A theoretical volume makes no sense;
  only an empirical one is possible (INFERENCE).

**Storage vectors** (computed by hand; MB = 10⁶ bytes, as in ADR-011 §3):

| ID | Inputs | Expected result |
| --- | --- | --- |
| S1 | Owner's phone DNG: 4096 × 3072, 16 bits, uncompressed; file length 25 172 524 B (RG-01) | data 25 165 824 B; difference **6 700 B** (0.027 %). Telephoto 4080 × 3072: 25 067 520 B versus 25 074 220 B — also **6 700 B** |
| S2 | FITS, ASI2600MC 6248 × 4176, BITPIX 16, one header block | data 52 183 296 B → padded 52 185 600 B; + 2 880 B header = **52 188 480 B ≈ 52.19 MB = 49.77 MiB** (ZWO: about 50 MB) |
| S3 | S2 × 230 frames (120 light + 30 dark + 30 flat + 50 bias, no library) | **≈ 12 003 MB ≈ 12.0 GB** |
| S4 | DSLR 6000 × 4000, 14 bits | dense packing 42.0 MB; in a 16-bit container 48.0 MB; lossless (−20…−40 %) — **unknown**, range only |

### 3.3 Document conflict (FACT)

- **CLAUDE.md** permits a theoretical payload when it is explicitly distinguished from the empirical one.
  `PRODUCT_SPEC.md:68` requires distinguishing them.
- **Deferred:**
  - `PRODUCT_DIRECTION.md:235` defers «a theoretical storage payload»;
  - `POST_ROADMAP_PLAN.md:2619` and `:4004` exclude it.
- **Stage 11 row** `POST_ROADMAP_PLAN.md:5769`: «storage, known and unknown, with no theoretical
  size introduced».
- **Return procedure:** per PRODUCT_DIRECTION §8, a deferred item returns only through
  research and an owner decision; this research is the input for such a decision.
- **If a theoretical volume is approved** (INFERENCE): the Stage 11 row becomes replaced by a new
  RA.D decision. It is recorded as superseded, not rewritten retroactively.

### 3.4 Options (Q2)

| | ST0 — empirical only (as now) | ST1 — labelled theoretical volume when no empirical one exists | ST2 — capture format on the rig, theoretical only for exact formats | ST3 — empirical from any chosen file |
| --- | --- | --- | --- | --- |
| **What** | `averageRawFileSizeMB` × frames, otherwise «Unknown» | W × H × b/8 × frames labelled «theoretical, uncompressed» | The rig stores the format: FITS 16 / FITS 32 / uncompressed DNG / compressed RAW / JPEG·HEIC. The theoretical value is shown only where it is exact (FITS, DNG with Compression = 1) | file length of JPEG/HEIC/FITS/DNG → `averageRawFileSizeMB` as `estimated` (currently DNG only) |
| **Accuracy** | empirical (real file length) | exact for uncompressed formats; for compressed ones — only an upper bound | exact where shown; for compressed ones — «Unknown» or a range | empirical; compression varies between frames |
| **Integrity risk** | none | medium: can be mistaken for the real size of a compressed RAW | low | none |
| **ADR / SI / CALC** | — | ADR-009 §7 and L6, SI-013, CALC-16/25, new CALC; lifting the exclusions PRODUCT_DIRECTION §8 and POST_ROADMAP_PLAN:2619; Stage 11 line 5769 | same as ST1 | ADR-018 D4 (extend from DNG to other formats), ADR-017 (not needed: file length is not a tag) |
| **Data and schema** | — | bit-depth column on the camera (int, nullable) with provenance; v26; additive rig snapshot keys, export v2 additive, backup per table; metadata contract + tags 258/259 (ADR-017) | format column (text, nullable) + bit depth; v26; additive snapshot and export keys | none |
| **Binning** | ignored (L6) | for accuracy it would have to divide by bin²: conflicts with ADR-020 B1 («binning feeds no calculation») | same | — |

- **Recommendation: ST3 + ST2**, provided the owner brings back the deferred item.
  - The empirical size is always primary.
  - The theoretical value is shown only for formats where it is exact, and only with a label, for example
    «≈ 12.0 GB (theoretical: 6248 × 4176 × 16 bits, uncompressed FITS; the real file size is
    unknown)».
  - For compressed RAW and JPEG there is no theoretical value: «Unknown — choose one file to
    find out the size».
  - Covers the owner's wish «всегда знать вес» [“always know the size”] where this is honest, and ST3 covers
    the rest with a single file choice.
- **Alternative: ST3 only.** The Stage 11 row stays untouched and the schema does not change, but
  «Unknown» remains until the first file is chosen.
- **Tests:** vectors S1–S3 (S1 is arithmetic without the owner's bytes, allowed in the repository);
  the boundary «compressed format → no theoretical value».

## 4. Q3 — "Pro mode" fields by camera class

### 4.1 Parameter matrix

**Legend:** «Calculation» — whether any AstroPlan formula reads it; «Metadata» — where
it can be read from; «Now» — its state in AstroPlan (ADR-020 §3).

| Parameter | Phone (Camera2) | DSLR/mirrorless | Astro camera | Calculation | Metadata | Now |
| --- | --- | --- | --- | --- | --- | --- |
| Exposure | `SENSOR_EXPOSURE_TIME`, ns | manual / bulb | in the capture software | **yes** (budget, window, √N, NPF warning) | DNG/JPEG/HEIC ExposureTime (read, CALC-39); FITS EXPTIME (FITS not read) | required |
| ISO | `SENSOR_SENSITIVITY` | ISO | — | no (SI-004) | ISOSpeedRatings (read) | optional, «for the record» |
| Gain, offset | — | — | GAIN, OFFSET in manufacturer units | no | FITS GAIN/OFFSET (N.I.N.A.) | gain optional; offset not modelled (O0) |
| White balance | `CONTROL_AWB_MODE` (presets); API 36: `COLOR_CORRECTION_MODE_CCT` + `COLOR_CORRECTION_COLOR_TEMPERATURE`/`_TINT` (Kelvin) | preset / K | not applied to RAW (Siril, RG-11 §4.4) | **no** (in RAW it is metadata; in JPEG it changes pixels, but time and frames do not depend on it) | DNG: `AsShotNeutral`, a neutral vector, not Kelvin (AOSP writes it for Bayer); EXIF `WhiteBalance` 0xA403 = only 0 Auto / 1 Manual; no Kelvin in any contract tag | no (W1) |
| Focus | `LENS_FOCUS_DISTANCE`, dioptres, possibly uncalibrated (`LENS_INFO_FOCUS_DISTANCE_CALIBRATION`) | manual, Bahtinov | manual / autofocus runs | no; only refocus overhead (ADR-009 §4) | AOSP `DngCreator` does not write SubjectDistance; EXIF SubjectDistance 0x9206 possible in some manufacturers' JPEGs (UNKNOWN for the owner's phone) | no (F1) |
| Binning / pixel mode | `SENSOR_PIXEL_MODE` — a rig property (RG-02 §5) | no user RAW binning (not checked) | per frame | no (B1) | FITS XBINNING | Astro and Unknown only (`camera_class.dart:32-33`) |
| Format / bit depth | RAW_SENSOR (16), RAW10/12, JPEG, HEIC | RAW 12/14, compression | FITS 16/32 | storage (§3) | BitsPerSample/Compression (not read) | no |
| Temperature / cooling | — | — | SET-TEMP, CCD-TEMP | no (affects dark matching) | FITS | not modelled (T0) |
| Interval between frames | app timer | intervalometer | download + delay | **yes** (per-frame overhead) | not from a single file | global setting (I1) |
| In-camera noise reduction | unknown | camera setting | — | **yes** (ADR-020 §8) | no | rig toggle (N1) |
| Filter | rarely | rarely | usually (mono) | **yes** (√N groups, filter change) | FITS FILTER (not read) | optional |

- **Conclusion (INFERENCE):** "pro mode" for AstroPlan is a **set of fields for the record** per class, not
  camera control (RA-F11, PRODUCT_DIRECTION §1).
- **What can be «стянуть» [“pulled”] from a photo today** (FACT): exposure and ISO. WB mode (Auto/Manual) — only
  from JPEG/HEIC and only if the tag is present. Kelvin and focus are not in the available metadata. DNG has
  `AsShotNeutral`, but converting to Kelvin requires DNG colour matrices (INFERENCE: substantial work,
  outside the ADR-017 contract).

### 4.2 White balance (W)

| | W1 — not modelled (ADR-020) | W2 — optional WB record | W2m — W2 + Auto/Manual mode from JPEG/HEIC |
| --- | --- | --- | --- |
| What | nothing | a light-block field for Phone, DSLR and Unknown: «Auto» or K; record only, not used in calculation | W2 plus a mode proposal from the chosen file |
| For | no field without a calculation | the owner's wish (08 §15); helps repeat settings; in JPEG capture WB changes pixels | less manual entry |
| Against | the owner's wish is not met | a field with no planning consequence | the tag gives no K; a new use of metadata (P3 rejected in ADR-020 §5) |
| Data | — | block column (text/int, nullable); v26; additive snapshot and export keys | same + tag 41987 in the contract (ADR-017) |

**Recommendation: W2** — record only, labelled «Recorded only; it does not change the plan», like
ISO. **Alternative: W1.** Supersedes ADR-020 §3 (W1) and the §10 line «W2, F2, F3 rejected».

### 4.3 Focus (F)

| | F1 — not modelled | F2 — reminder | F3 — value (slider) |
| --- | --- | --- | --- |
| What | refocus overhead only | a checklist line in the plan or block (for example, «focus on a star; recheck after a filter or temperature change») without a value | a focus number in the block |
| Evidence | RG-11 §4.5 | N.I.N.A. triggers (time, temperature, filter, HFR) | `LENS_FOCUS_DISTANCE` in dioptres, possibly uncalibrated; not written into DNG; the position does not carry over between nights |
| Risk | — | low | high: a «slider» looks like camera control that does not exist |
| Data | — | none (static text) or a «hide hints» setting (like H1) | block column; v26 |

**Recommendation: F2. Alternative: F1.** F3 is not recommended: there is no data it would rely on.

### 4.4 «Стянуть данные про-режима» [“Pull the pro-mode data”] (P3′)

- **Option P3′:** a «Take from a photo» button in the light block.
  - Fills exposure and ISO, and with W2m also the WB mode.
  - Values are marked «from file …» and are saved only on Save.
  - This brings back P3, rejected in ADR-020 §5.
- **Data:** the schema does not change if provenance is not stored. Storing it in the block is a new column.
- **Owner decision:** yes.

### 4.5 P2 proposals: "proposed" versus "entered"

- **Now** (FACT):
  - a single line «Proposed from your last light block: …» above the form
    (`capture_block_dialog.dart:326-333`);
  - the fields themselves are filled with the values as plain text (`capture_block_dialog.dart:130-142`),
    so they look entered;
  - the filter defaults to «L» (`:134`).
- **Defect candidate RA-F05** (exposure is kept when switching to Flat or Bias) was not
  checked: it is a separate corrective task.

| | P2a — as now | P2b — a mark on each field | P2c — hint instead of value | P0 — no proposals |
| --- | --- | --- | --- | --- |
| What | a shared line | under each proposed field «from block Ha · 300 s» and ×; «proposed» style until the field is touched | the field is empty, hint «300 s, as in the previous block» and a «Use» button | empty form |
| Honesty | medium | high (like the calibration's «shown with its origin», ADR-020 §6) | maximum | high |
| Speed | one tap | one tap | +1 tap per field | slow |
| Data | — | none (form state) | none | none |

**Recommendation: P2b. Alternative: P2c.** Stays within ADR-020 §5 («shown as such»); only the
presentation changes. The default filter «L» should be reconsidered at the same time: for Phone and DSLR one would expect
«None» (INFERENCE).

### 4.6 Camera class (C1): how to obtain it without inference "behind the user's back"

- **Root of RA-F06** (FACT): the default class is Unknown
  (`equipment_foundation_tables.dart:55`). Unknown shows both binning and the ISO/gain choice
  (`camera_class.dart:23-33`). The example rig was left Unknown by the owner's choice.
- **There is no reliable class indicator in the metadata** (FACT, RG-11 §3): DNG, JPEG and HEIC come from
  all classes, and FITS does not prove an astro camera.
- **Strong indirect phone indicators** (INFERENCE): f < 10 mm together with
  FocalLengthIn35mmFilm at crop > 3.

| | C1-a as now | C1-b ask explicitly | C1-c propose from metadata with confirmation | C1-d class on the example rig |
| --- | --- | --- | --- | --- |
| What | Unknown by default | the first choice when creating a rig («What do you shoot with?»: Phone · Camera · Astro camera colour · mono · Don't know) and the same question in onboarding (RA-B04) | the «Add from a photo» import proposes a class with a reason («looks like a phone: f 6.57 mm, 23 mm equiv.»), the user confirms | «Astro camera (colour)» per the cited ZWO page (RG-11 §8) |
| ADR | — | none (ADR-020 §2: «chosen by the user» — respected) | **changes ADR-020 §2** («never inferred … import proposes none») | seed change with provenance; ADR-020 §2 records the owner's choice «stays Unknown» |
| Risk | the form stays neutral and overloaded | an extra step | a habitual «OK» on a wrong proposal | none |
| Data | — | none (the field exists, v20) | none | new installs only: the seeder seeds an empty table, existing rows are not reinterpreted |

**Recommendation: C1-b + C1-d. Alternative: C1-c** (only as a proposal with a reason and explicit
confirmation; requires amending ADR-020 §2).

### 4.7 Calibration from lights (RA-F08): model or presentation?

- **What RG-10 has already established and what is built** (FACT, RG-10 §4; ADR-020 §6):
  - **darks** inherit exposure, ISO/gain and binning; only count and policy are entered;
  - **flats** inherit filter and binning, ISO/gain are proposed, exposure is independent (ADU guidance
    is excluded);
  - **bias** inherits ISO/gain and binning;
  - **dark flats** inherit from flats.
- **There is one model gap** (INFERENCE): inheritance comes from **one** chosen light group.
  - A plan with several exposures or filters needs one block per group.
  - The owner probably expects a single «calibration for all lights» action.
- **Option CAL-1:** a «Build calibration from lights» action creates one dark block per
  unique triple (exposure, sensitivity, binning) and one flat block per filter.
  - Uses the existing `CalibrationMatch`.
  - The schema does not change; default frame counts are proposals (P2b).
- **Alternative CAL-0:** only an on-device UX check (RA.R1: the type is chosen after the form
  opens).

### 4.8 Interval between frames per rig (RA-H02, briefly)

- **I1 (as now):** one global setting.
- **I2 (per rig):** rig column, migration v26, snapshot key. ADR-020 rejected I2 because of the risk
  of counting the interval twice (RG-11 §6, example C).
- **Owner decision:** yes.

## 5. Q4 — "Moon-free dark time"

### 5.1 Definitions

- **Moonlit** (FACT: `README.md`, section «What a night means»; `astronomy.js:71-77, 131-155`):
  - darkness: the Sun's geometric centre ≤ −18° (`SearchAltitude`, no refraction);
  - the Moon is «above the horizon» while its **apparent upper limb** is above the horizon: disc radius,
    topocentric parallax and standard 34′ refraction with a site-elevation correction are taken into account;
  - instants are found by root search (seconds);
  - a night runs from local noon to local noon;
  - illumination is taken at local midnight.
- **AstroPlan** (FACT):
  - Darkness — CALC-41 `darkAtLimit` at a **user** limit of −18°, −15° or −12°:
    Sun without atmosphere, 5-minute grid.
  - The displayed moonrise and moonset — CALC-28 `riseSetForNight` with h₀ = 0.7275π − 0.5667°
    (geocentric: upper limb, refraction and parallax per Meeus ch. 15)
    (`lib/domain/services/moon_calculator.dart:408-417`).
  - «Moon above the horizon» in CALC-29, CALC-33 (the ADR-013 Moon gate) and CALC-43 is the
    **topocentric altitude of the centre without atmosphere > 0°**:
    - `moon_conditions.dart:16-17` and `:95`;
    - `imaging_opportunity_calculator.dart:175`.
  - The `MoonConditions.upIntervals` intervals are already built from h₀ (`moon_conditions.dart:64-76`).
  - Site elevation is not taken into account in refraction.

### 5.2 Equivalence

- **Darkness at −18°: equivalent** (FACT). Both definitions use the Sun's centre without refraction.
  The only difference is resolution: ±5 min in AstroPlan (SCI-04) versus seconds in Moonlit.
- **Moon: not equivalent** (FACT per CALC-28, note SCI-03).
  - The Moon's centre crosses 0° topocentrically about 5–10 min **later** than the h₀ rise and
    5–10 min **earlier** than the h₀ set. This is a lift of ~0.83° (semi-diameter ~0.25° + refraction ~0.57°).
  - Therefore CALC-43's «dark − moonUp» is **not less** than Moonlit's «moon-free». It overstates
    moon-free time by about 5–10 min for each moonrise or moonset inside the dark
    interval, plus ±5 min of grid at each edge.
  - The CALC-43 summary and the moonrise and moonset shown next to it can therefore differ by
    5–10 minutes (INFERENCE).
- **Night boundary** (INFERENCE): in AstroPlan the boundary is the SessionNight mean solar noon
  (ADR-007), in Moonlit it is civil noon. This barely affects the dark interval; exceptions
  are possible only in polar cases.

**Synthetic vector** — for the intersection logic, not for astronomy:
- **given:** dark interval 20:00–04:00 UTC; h₀ rise — 22:53, centre above 0° — from 23:00;
  no set within the night;
- **Moonlit/MF-b:** moon-free darkness = 20:00–22:53 = **2 h 53 min**;
- **CALC-43:** on the grid 20:00–23:00 = **3 h 00 min**;
- **difference:** 7 min.

### 5.3 Options for the monthly «moon-free hours» calendar

| | MF-a — CALC-43 as is | MF-b — darkness ∩ (Moon below the horizon by h₀) | MF-c — a single h₀ everywhere |
| --- | --- | --- | --- |
| What | dark − moonUp; label «Moon above the horizon = centre above 0°» | `darkAtLimit` intervals minus `upIntervals` (the same instants the UI shows); a new CALC — interval intersection | MF-b, and CALC-29/33/43 together with the ADR-013 gate switch to h₀ |
| Agreement with the displayed rise and set | no (5–10 min) | yes | yes |
| Agreement with Moonlit/USNO | no | yes at −18° (at the 5-minute grid resolution) | yes |
| Scientific change | none | a new derived quantity without new astronomy | a predicate change in a high-risk area: ADR-013, vectors V1–V12, CALC-29/33 |
| Data | none (computed) | none | no schema; Moon gate tests |

- **Recommendation: MF-b** for the calendar, and also for the «moon-free dark time» row on Tonight and in
  Night & Moon.
  - The darkness limit is the user's, with a label; at −18° it matches Moonlit.
  - The CALC-43 predicate and the ADR-013 gate remain until the owner chooses MF-c.
- **Alternative: MF-a** — no change to calculations, label only.
- **Cost of 30 nights:** about 30 × (289 Moon samples + 289 for rise and set + Sun). By
  estimate this is acceptable offline, but it was not measured (INFERENCE). This is a question for R2c and implementation.

## 6. Summary of options for RA.D

No option is decided. Every change requires an owner decision, because it changes an accepted
decision, an exclusion or a presentation approved by Stage 6/7/11.

| ID | Recommended | Alternative | Trade-offs | Decision replaced | Data / migration / tests | Owner approval needed |
| --- | --- | --- | --- | --- | --- | --- |
| D-SNR (K5; RA-A03, F10) | **O2** (O2b with a time axis) | O4 only for astro cameras with an entered R | O2 is honest but gives no absolute number; O4 is useful but opens «exposure optimisation» | O2: CALC-42 presentation. O4: PRODUCT_DIRECTION §8, ADR-020 §9, SI-003 item 4 | O2: no schema; CALC-42 tests (R-O2-1/2). O4: fields R, η (+Δλ), v26, additive snapshot and export keys, new CALC with R-SKY and R-SUB | yes |
| D-STO (K6; RA-A04) | **ST3 + ST2** (theoretical only for exact formats, labelled) | ST3 only | ST2 gives the «size» before the first file but adds a format field | PRODUCT_DIRECTION:235, POST_ROADMAP_PLAN:2619/4004, Stage 11 row :5769 (superseded), ADR-009 §7/L6, SI-013, ADR-018 D4 (ST3) | ST2: format and bit-depth columns, v26, snapshot and export additive, tags 258/259 (ADR-017); vectors S1–S3 | yes |
| D-WB (K7; RA-F07) | **W2** (record only) | W1 | the owner's wish versus a field without a calculation | ADR-020 §3 W1, §10 | block column, v26, snapshot and export additive | yes |
| D-FOC (K7) | **F2** (reminder) | F1 | — | ADR-020 §3 F1, §10 | none (or a «hide hints» flag) | yes |
| D-PRO (RA-F07) | P3′ — at the owner's choice | do not do it | less entry versus a new use of metadata | ADR-020 §5 (P3 rejected) | no schema (or a provenance column) | yes |
| D-P2 (RA-F05) | **P2b** | P2c | visibility versus an extra tap | ADR-020 §5 presentation (within «shown as such») | no schema; widget tests; separately — a probe for the RA-F05 defect | yes |
| D-CLS (RA-F06) | **C1-b + C1-d** | C1-c with confirmation | an extra step versus a wrong proposal | C1-d: the owner's choice «example rig stays Unknown» (ADR-020 §2); C1-c: «never inferred» (ADR-020 §2) | C1-b: no schema. C1-d: seed (new installs only). C1-c: no schema | yes |
| D-CAL (RA-F08) | **CAL-1** «Build calibration from lights» | CAL-0 (first an on-device UX probe) | — | none (within ADR-020 §6 L1) | no schema; tests: one dark per triple, one flat per filter | yes |
| D-INT (RA-H02) | I1 (as now) | I2 per rig | accuracy for several cameras versus double counting | ADR-020 I1 | I2: rig column, v26, snapshot key | yes |
| D-MOON (RA-E01) | **MF-b** | MF-a | accuracy versus a new CALC; MF-c — high risk | MF-b: none. MF-c: ADR-013, CALC-29/33/43 | no schema; intersection tests (synthetic vector §5.2) | yes |

**Common data consequences** (INFERENCE):
- The options with a new column (O4, ST2, W2, I2) are conveniently combined into **one** v26 migration.
  - Rig and block snapshot keys are additive: old snapshots read as «unknown».
  - Export v2 — additive fields, compatible (`EXPORT_MANIFEST.md` versions only
    incompatible changes).
  - Backup copies whole tables.
- Under CLAUDE.md V1 this is a high-risk task: full gate, migration tests and
  `backup_restore_test`/`unsupported_database_test` with pinned versions.

## 7. Sources

All accessed **2026-10-17**.

**Primary and official**
- Merline, W. J.; Howell, S. B. (1995), «A realistic model for point-sources imaged on array
  detectors», *Experimental Astronomy* 6, 163–210 — https://doi.org/10.1007/BF00421131 (bibliography
  confirmed; text not read).
- Howell, S. B., *Handbook of CCD Astronomy*, 2nd ed. (2006), §4.4 — reference by citation; not checked
  online.
- V. Dhillon, Sheffield PHY217, «The CCD equation» —
  https://vikdhillon.staff.shef.ac.uk/teaching/phy217/detectors/phy217_det_ccdeqn.html (form
  of the equation, √t and t regimes).
- CfA, «Astronomical Magnitude Systems» (V = 0: 3640 Jy, Bessell 1979; 1 Jy = 1.51·10⁷ photons) —
  https://lweb.cfa.harvard.edu/~dfabricant/huchra/ay145/mags.html
- SharpCap 4.0, Smart Histogram — https://docs.sharpcap.co.uk/4.0/15_SmartHistogram.htm
- R. Glover (SharpCap developer), post in the «optimum sub exposure time» thread, 2022-09-18 —
  https://forums.sharpcap.co.uk/viewtopic.php?p=31946 (0.14 e⁻/pixel/s, the 10·R²/P rule,
  ~3200 s and ~170 s).
- ZWO, ASI2600MC/MM Duo (6248 × 4176, 3.76 µm, 16 bits, read noise 0.9–4.2 e⁻, QE 80 %, 50 ke⁻;
  no dark current figure) — https://www.zwoastro.com/product/asi2600mc-duo/
- ZWO, ASI2600MC Pro overview («about 50 MB» per 1 × 1 frame; 16 bits) —
  https://www.zwoastro.com/product/asi2600mc-pro/
- AOSP `android_hardware_camera2_DngCreator.cpp` (BitsPerSample 16, Compression 1, AsShotNeutral,
  no WhiteBalance or SubjectDistance, IFD0 only) —
  https://raw.githubusercontent.com/aosp-mirror/platform_frameworks_base/master/core/jni/android_hardware_camera2_DngCreator.cpp
- Android API 36: `COLOR_CORRECTION_MODE_CCT`, `COLOR_CORRECTION_COLOR_TEMPERATURE` —
  https://developer.android.com/sdk/api_diff/36/changes/android.hardware.camera2.CameraMetadata ;
  https://developer.android.com/reference/android/hardware/camera2/CaptureRequest
- ExifTool, EXIF Tags (WhiteBalance 0xA403: 0 Auto, 1 Manual; SubjectDistance 0x9206; Compression 1,
  7, 34892, 52546; AsShotNeutral 0xC628) — https://exiftool.org/TagNames/EXIF.html
- FITS standard (2880-byte records; BITPIX) — https://archive.stsci.edu/fits/fits_standard/node11.html ;
  https://heasarc.gsfc.nasa.gov/docs/heasarc/fits_overview.html
- N.I.N.A., FITS keywords (EXPTIME, GAIN, OFFSET, XBINNING, SET-TEMP, CCD-TEMP) —
  https://nighttime-imaging.eu/docs/master/site/advanced/file_formats/fits
- Nikon D850 Online Manual (lossless about −20…−40 %, compressed about −35…−55 %) —
  https://chsv-origin-onlinemanual.nikonimglib.com/d850/en/18_menu_guide_03_11.html (from a search
  result; the page was not loaded).
- Moonlit, `README.md` and `astronomy.js` (local copy, untrusted data; code without a licence) —
  `C:\Users\zalub\OneDrive\Desktop\52\moonlit-main`.
- USNO, «Rise, Set, and Twilight Definitions» — https://aa.usno.navy.mil/faq/RST_defs (**did not
  load**: ECONNRESET; the definition is taken from Meeus ch. 15, checked by ADR-010).

**Secondary (from description)**
- Xamarin mirror of `ImageFormat.RawSensor` («16 bits of precision») —
  https://developer.xamarin.com/api/field/Android.Graphics.ImageFormat.RawSensor/ (search
  result).
- DNG 1.7 and JPEG XL (52546) — https://exiftool.org/forum/index.php?msg=82342
- PixLS, D850 versus Z7 II, uncompressed RAW sizes (user measurements) —
  https://discuss.pixls.us/t/nikon-z7ii-files-smaller-than-d850/23181
- SharpCap forum, «SQM/Bortle relation and optimal sub-exposure» (2021-05-03) —
  https://forums.sharpcap.co.uk/viewtopic.php?p=21663
- astronomy.tools, list of calculators (no SNR or exposure calculator; the page returned 404 with navigation) —
  https://astronomy.tools/calculators/

**Repository documents** (as cited above):
- `docs/DECISIONS.md`: ADR-009, ADR-010, ADR-018, ADR-020;
- `docs/SCIENTIFIC_INTEGRITY.md`;
- `docs/refinement/research/`: RG-01, RG-02, RG-03, RG-07, RG-10, RG-11, RA_R1_PHASE_A_ASSESSMENT;
- `docs/refinement/PRODUCT_DIRECTION.md`;
- `docs/refinement/POST_ROADMAP_PLAN.md`.
