"""Draws Astro Planner's PNG launcher icons (TASK 16.1).

The adaptive icon (Android 8+) is the vector
android/app/src/main/res/drawable/ic_launcher_foreground.xml on the
ic_launcher_background colour; this script draws the same geometry as PNGs
for older Android (mipmap-*/ic_launcher.png, rounded square) and the 512 px
store icon (assets/branding/icon_512.png, full square, as Google Play wants).

Needs Pillow:  python tool/make_launcher_icons.py
Change the geometry here and in the vector together.
"""

from pathlib import Path

from PIL import Image, ImageDraw

ROOT = Path(__file__).resolve().parent.parent
RES = ROOT / 'android' / 'app' / 'src' / 'main' / 'res'

NAVY = (0x0B, 0x12, 0x30, 255)
HORIZON = (0x6F, 0x7B, 0xA8, 255)
ARC = (0xE8, 0xEC, 0xF8, 255)
WINDOW = (0xFF, 0x4D, 0x3D, 255)
STAR = (0xFF, 0xFF, 0xFF, 255)

# Geometry in the vector's 108-unit canvas.
P0, P1, P2 = (28, 70), (54, 22), (80, 70)
STAR_POINTS = [(54, 24), (56, 29), (61, 31), (56, 33), (54, 38), (52, 33),
               (47, 31), (52, 29)]


def quad(t):
    x = (1 - t) ** 2 * P0[0] + 2 * (1 - t) * t * P1[0] + t ** 2 * P2[0]
    y = (1 - t) ** 2 * P0[1] + 2 * (1 - t) * t * P1[1] + t ** 2 * P2[1]
    return x, y


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
    """The icon at [size] px. A legacy icon shows the full 108-unit canvas
    zoomed so the 66-unit safe zone fills most of it, as launchers did."""
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

    stroke(d, shift([(26, 70), (82, 70)]), 3, HORIZON, s)
    stroke(d, shift([quad(i / 64) for i in range(65)]), 5, ARC, s)
    stroke(d, shift([quad(0.3 + 0.4 * i / 32) for i in range(33)]), 7,
           WINDOW, s)
    d.polygon([(x * s, y * s) for x, y in shift(STAR_POINTS)], fill=STAR)
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
