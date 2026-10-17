"""Draws Culmina's PNG launcher icons (S13.3; the mark approved in S13.1,
`docs/refinement/evidence/identity/round5/R3-final-colour.svg`).

The adaptive icon (Android 8+) is the vector
android/app/src/main/res/drawable/ic_launcher_foreground.xml on the
ic_launcher_background colour; this script draws the same geometry as PNGs
for older Android (mipmap-*/ic_launcher.png, rounded square) and the 512 px
mark for the repository and release pages (assets/branding/icon_512.png,
full square).

Needs Pillow:  python tool/make_launcher_icons.py
Change the geometry here and in the vector together (trap 20).
"""

import math
from pathlib import Path

from PIL import Image, ImageDraw

ROOT = Path(__file__).resolve().parent.parent
RES = ROOT / 'android' / 'app' / 'src' / 'main' / 'res'

NAVY = (0x0B, 0x12, 0x30, 255)
ORBIT = (0xE6, 0xEB, 0xF7, 255)
INNER = (0x7F, 0x8D, 0xC0, 255)
STAR = (0x8C, 0xCB, 0xFF, 255)

# Geometry in the vector's 108-unit canvas: both orbits are centred on
# (54, 54); angles in degrees, counter-clockwise from east with y up, as in
# the vector's arcs (outer: 60.77,33.07 -> 75.79,50.96; inner: 53.06,40.83 ->
# 66.8,57.21).
CENTRE = (54.0, 54.0)
OUTER = (22.0, 72.07, 367.94, 6.0)    # radius, from, to, stroke width
INNER_ORBIT = (13.2, 94.08, 345.92, 2.4)
# The sparkle: four quadratic curves through a pinched centre.
STAR_PATH = [((70.85, 30.26), (72.39, 38.32), (80.45, 39.86)),
             ((80.45, 39.86), (72.39, 41.39), (70.85, 49.46)),
             ((70.85, 49.46), (69.32, 41.39), (61.25, 39.86)),
             ((61.25, 39.86), (69.32, 38.32), (70.85, 30.26))]


def arc_points(radius, start, end, steps=180):
    cx, cy = CENTRE
    return [(cx + radius * math.cos(math.radians(start + (end - start) * i / steps)),
             cy - radius * math.sin(math.radians(start + (end - start) * i / steps)))
            for i in range(steps + 1)]


def star_points(steps=24):
    pts = []
    for p0, p1, p2 in STAR_PATH:
        for i in range(steps):
            t = i / steps
            pts.append(((1 - t) ** 2 * p0[0] + 2 * (1 - t) * t * p1[0] + t * t * p2[0],
                        (1 - t) ** 2 * p0[1] + 2 * (1 - t) * t * p1[1] + t * t * p2[1]))
    return pts


def stroke(draw, points, width, colour, s):
    """A round-capped stroke drawn as a dense trail of discs (smooth joins,
    as the vector's round caps)."""
    r = width * s / 2
    pts = [(x * s, y * s) for x, y in points]
    for (x0, y0), (x1, y1) in zip(pts, pts[1:]):
        steps = max(1, int(((x1 - x0) ** 2 + (y1 - y0) ** 2) ** 0.5 / (r / 4)))
        for i in range(steps + 1):
            x = x0 + (x1 - x0) * i / steps
            y = y0 + (y1 - y0) * i / steps
            draw.ellipse([x - r, y - r, x + r, y + r], fill=colour)


def icon(size, rounded):
    """The icon at [size] px. A legacy icon shows the 108-unit canvas zoomed
    so the 66-unit safe zone fills most of it, as launchers did."""
    scale_up = 4  # draw large, then downsample for smooth edges
    big = size * scale_up
    img = Image.new('RGBA', (big, big), (0, 0, 0, 0))
    d = ImageDraw.Draw(img)
    radius = big * 0.18 if rounded else 0
    d.rounded_rectangle([0, 0, big - 1, big - 1], radius=radius, fill=NAVY)
    # Map the 108-unit canvas so that units 14..94 span the icon.
    s = big / 80
    offset = 14

    def shift(points):
        return [(x - offset, y - offset) for x, y in points]

    r, a0, a1, w = INNER_ORBIT
    stroke(d, shift(arc_points(r, a0, a1)), w, INNER, s)
    r, a0, a1, w = OUTER
    stroke(d, shift(arc_points(r, a0, a1)), w, ORBIT, s)
    d.polygon([(x * s, y * s) for x, y in shift(star_points())], fill=STAR)
    return img.resize((size, size), Image.LANCZOS)


def main():
    for folder, size in [('mipmap-mdpi', 48), ('mipmap-hdpi', 72),
                         ('mipmap-xhdpi', 96), ('mipmap-xxhdpi', 144),
                         ('mipmap-xxxhdpi', 192)]:
        icon(size, rounded=True).save(RES / folder / 'ic_launcher.png')
    store = ROOT / 'assets' / 'branding'
    store.mkdir(parents=True, exist_ok=True)
    icon(512, rounded=False).save(store / 'icon_512.png')


if __name__ == '__main__':
    main()
