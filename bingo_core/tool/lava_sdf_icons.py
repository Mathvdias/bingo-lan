"""Ícones Lava procedurais do Bingo (ray marcher SDF de `lava_flutter/tool/lava_sdf.py`).

Cada cena é um objeto 3D de verdade, então ele pode GIRAR no próprio eixo, virar uma página ou
rolar um dado - coisa que o still + balanço de `lava_icons.py` não faz. Formas gordas e poucas
(os ícones aparecem com 28 a 120 px), paleta do app.

    LAVA_TOOL=~/Developer/portifolio/packages/lava_flutter/tool
    python3 tool/lava_sdf_icons.py globe --still 0.1 preview.png          # look-dev (~3 s)
    python3 tool/lava_sdf_icons.py globe frames/globe                      # todos os quadros
    python3 $LAVA_TOOL/openlava_encode.py assets/lava/globe --fps 24 --webp 88 frames/globe/frame_*.png
    python3 tool/lava_sdf_icons.py --oneshot assets/lava/dice              # manifest "loop": false
    python3 tool/lava_sdf_icons.py --sheet frames/globe sheet.png 8        # folha de contato
    python3 tool/lava_sdf_icons.py --keys assets/lava all_keys.png         # primeiro quadro de cada bundle

Loops: todo movimento é múltiplo inteiro de 2*pi*t, o último quadro emenda no primeiro. `dice` e
`pencil` são "one-shot" (ícones de aba, tocados uma vez): começam numa pose e terminam noutra.
"""
import json
import math
import os
import sys
import tempfile
from multiprocessing import Pool

import numpy as np
from PIL import Image

TOOL = os.environ.get(
    "LAVA_TOOL",
    os.path.expanduser("~/Developer/portifolio/packages/lava_flutter/tool"),
)
sys.path.insert(0, TOOL)
if "--scale" in sys.argv:
    os.environ["LAVA_SCALE"] = sys.argv[sys.argv.index("--scale") + 1]
import lava_sdf as sdf  # noqa: E402
from lava_sdf import F, Material, Scene, srgb, v3  # noqa: E402
from sdf_scenes import LavaKey  # noqa: E402

TAU = 2.0 * math.pi
YELLOW, BLUE, GREEN = srgb(255, 235, 59), srgb(79, 195, 247), srgb(174, 213, 129)
CREAM, PINK, INK = srgb(255, 253, 245), srgb(255, 138, 128), srgb(26, 26, 30)
SKIN = srgb(255, 226, 196)


# --------------------------------------------------------------------------------------------
# Helpers that lava_sdf does not have
# --------------------------------------------------------------------------------------------
def rot_z(p, angle):
    c, s = math.cos(angle), math.sin(angle)
    out = p.copy()
    out[:, 0] = c * p[:, 0] - s * p[:, 1]
    out[:, 1] = s * p[:, 0] + c * p[:, 1]
    return out


def sd_box(p, c, half, rounding=0.0):
    q = np.abs(p - c) - (np.asarray(half, F) - rounding)
    return (sdf.length(np.maximum(q, 0.0)) + np.minimum(q.max(-1), 0.0)) - rounding


def sd_torus_z(p, c, R, r):
    """Ring in the xy plane (axis z)."""
    q = p - c
    return np.sqrt((np.sqrt(q[:, 0] ** 2 + q[:, 1] ** 2) - R) ** 2 + q[:, 2] ** 2) - r


def sd_torus_x(p, c, R, r):
    """Ring in the yz plane (axis x)."""
    q = p - c
    return np.sqrt((np.sqrt(q[:, 1] ** 2 + q[:, 2] ** 2) - R) ** 2 + q[:, 0] ** 2) - r


def sd_disc_z(p, c, r, half, rounding=0.0):
    """Puck facing the camera (axis z)."""
    q = p - c
    q = np.stack([q[:, 0], q[:, 2], q[:, 1]], -1)
    return sdf.sd_cylinder(q, v3(0, -half, 0), r, 2 * half, rounding)


def extrude(d2, z, half, rounding=0.0):
    dz = np.abs(z) - half
    return (np.minimum(np.maximum(d2, dz), 0.0)
            + np.sqrt(np.maximum(d2, 0.0) ** 2 + np.maximum(dz, 0.0) ** 2) - rounding)


def sd_spheres(p, centres, radii):
    d = np.sqrt(((p[:, None, :] - centres[None]) ** 2).sum(-1)) - radii[None]
    return d.min(1)


def nearest(p, centres):
    return ((p[:, None, :] - centres[None]) ** 2).sum(-1).argmin(1)


def mix(a, b, k):
    return a + (b - a) * k[:, None]


def ease(k):
    k = min(max(k, 0.0), 1.0)
    return k * k * (3.0 - 2.0 * k)


def lift(t):
    return (1 - math.cos(TAU * t)) / 2


def const(colour, p):
    return np.broadcast_to(colour, p.shape).copy()


# --------------------------------------------------------------------------------------------
class Globe(Scene):
    """Desk globe: blue sphere with bold green continents turning on its tilted axis, black
    meridian arc and stand. One turn per loop."""

    frames, fps = 48, 24
    view_height, look_at, pitch = 3.15, (0.0, 1.32, 0.0), 14.0
    bound_radius = 2.2
    shadow_strength = 0.30
    TILT = math.radians(23.0)
    CENTRE = (-0.12, 1.46, 0.0)
    ARC_R = 1.15
    # (lat, lon, cap radius) in degrees; overlapping caps make each continent's silhouette
    BLOBS = [(22, 0, 27), (-8, 16, 21), (38, 28, 15),
             (-24, 118, 25), (2, 140, 17),
             (42, -112, 23), (10, -96, 19), (-30, -82, 16),
             (-60, 40, 13)]

    def __init__(self):
        dirs, cos_r = [], []
        for lat, lon, r in self.BLOBS:
            la, lo = math.radians(lat), math.radians(lon)
            dirs.append([math.cos(la) * math.sin(lo), math.sin(la), math.cos(la) * math.cos(lo)])
            cos_r.append(math.cos(math.radians(r)))
        self.dirs, self.cos_r = np.array(dirs, F), np.array(cos_r, F)
        self.materials = (
            Material(self.surface, spec=0.45, shininess=40.0, rim=0.22),
            Material(INK, spec=0.5, shininess=40.0, rim=0.12),
        )

    def frame(self, p):
        return rot_z(p - np.asarray(self.CENTRE, F), -self.TILT)

    def land(self, q, t):
        """0..1 land mask from the direction of q in the turning sphere's frame."""
        d = sdf.rot_y(q, -TAU * t)
        d = d / np.maximum(sdf.length(d)[:, None], 1e-6)
        dots = d @ self.dirs.T
        k = sdf.smoothstep(self.cos_r[None] - 0.012, self.cos_r[None] + 0.012, dots)
        return k.max(1)

    def parts(self, p, t):
        q = self.frame(p)
        globe = sdf.sd_sphere(q, v3(0, 0, 0), 1.0) - 0.03 * self.land(q, t)
        arc = sd_torus_z(q, v3(0, 0, 0), self.ARC_R, 0.055)
        arc = np.maximum(arc, q[:, 0] - 0.0)
        knobs = sd_spheres(q, np.array([[0, self.ARC_R, 0], [0, -self.ARC_R, 0]], F), np.full(2, 0.11, F))
        foot = rot_z(np.array([[0.0, -self.ARC_R, 0.0]], F), self.TILT)[0] + np.asarray(self.CENTRE, F)
        base_c = v3(foot[0] - 0.08, 0.0, 0.0)
        stem = sdf.sd_capsule(p, foot, base_c + v3(0, 0.08, 0), 0.075)
        base = sdf.sd_cylinder(p, base_c, 0.52, 0.15, rounding=0.06)
        stand = np.minimum.reduce([arc, knobs, stem, base])
        return [(globe, 0), (stand, 1)]

    def surface(self, scene, p, n, t):
        k = self.land(self.frame(p), t)
        col = mix(const(BLUE, p), GREEN, k)
        r = 2.0 * (n @ scene.eye)[:, None] * n - scene.eye
        return col + (0.05 * sdf.smoothstep(0.35, 0.85, r[:, 1]))[:, None]


# --------------------------------------------------------------------------------------------
class OpenBook(Scene):
    """Open book: blue covers, cream page blocks, one page flips from right to left."""

    frames, fps = 40, 24
    view_height, look_at, pitch = 2.55, (0.0, 0.42, 0.0), 56.0
    bound_radius = 1.9
    shadow_strength = 0.28
    V = math.radians(13.0)
    COVER, PAGES, PAGE = (0.72, 0.06, 0.60), (0.64, 0.14, 0.54), (0.64, 0.012, 0.54)
    REST0, REST1 = 0.10, 0.85

    def __init__(self):
        self.materials = (
            Material(BLUE, spec=0.35, shininess=30.0, rim=0.18),
            Material(CREAM, spec=0.12, shininess=12.0, rim=0.10),
        )

    def angle(self, t):
        k = ease((t - self.REST0) / (self.REST1 - self.REST0))
        return self.V + (math.pi - 2 * self.V) * k

    def half(self, p, sign):
        q = rot_z(p - v3(0, 0.04, 0), -sign * self.V)
        c = self.COVER
        cover = sd_box(q, v3(sign * c[0], 0.0, 0.0), c, 0.03)
        g = self.PAGES
        pages = sd_box(q, v3(sign * (g[0] + 0.03), c[1] + g[1], 0.0), g, 0.02)
        return cover, pages

    def page(self, p, t):
        th = self.angle(t)
        q = rot_z(p - v3(0, 0.04 + self.COVER[1] + 2 * self.PAGES[1], 0), -th)
        x = q[:, 0]
        bow = 0.30 * math.sin(th) ** 2 * np.sin(np.pi * np.clip(x / (2 * self.PAGE[0]), 0.0, 1.0))
        q[:, 1] -= bow
        h = self.PAGE
        return sd_box(q, v3(h[0] + 0.02, 0.0, 0.0), h, 0.01) * 0.75

    def parts(self, p, t):
        lc, lp = self.half(p, -1.0)
        rc, rp = self.half(p, 1.0)
        spine = sd_box(p, v3(0, 0.07, 0), (0.14, 0.07, 0.60), 0.03)
        return [(np.minimum.reduce([lc, rc, spine]), 0), (np.minimum.reduce([lp, rp, self.page(p, t)]), 1)]


# --------------------------------------------------------------------------------------------
class BingoCage(Scene):
    """Bingo cage: a yellow ball of thick ribs turning on a horizontal axle over a black stand,
    four coloured balls tumbling inside. The ribs repeat every 30 degrees, so a 120 degree turn
    per loop is seamless."""

    frames, fps = 48, 24
    view_height, look_at, pitch = 3.35, (0.0, 1.30, 0.0), 14.0
    bound_radius = 2.4
    shadow_strength = 0.30
    CENTRE = (0.0, 1.38, 0.0)
    YAW = math.radians(-28.0)
    TURN = math.radians(120.0)
    R, RIB = 1.0, 0.085
    BALLS = [(-0.42, 0.00, BLUE), (-0.12, 0.33, GREEN), (0.18, 0.66, PINK), (0.46, 0.17, CREAM)]

    def __init__(self):
        self.ball_col = np.array([c for _, _, c in self.BALLS], F)
        self.materials = (
            Material(YELLOW, spec=0.55, shininess=45.0, rim=0.20),
            Material(INK, spec=0.45, shininess=36.0, rim=0.12),
            Material(self.ball_paint, spec=0.7, shininess=60.0, rim=0.25),
        )

    def frame_a(self, p):
        return sdf.rot_y(p - np.asarray(self.CENTRE, F), -self.YAW)

    def balls(self, t):
        out = []
        for x, ph, _ in self.BALLS:
            a = -0.5 * math.pi + 0.55 * math.sin(TAU * (t + ph))
            r = 0.64 - 0.16 * max(0.0, math.sin(TAU * (t + ph) + 1.2))
            out.append([x + 0.05 * math.sin(TAU * (t + ph) * 1.0), r * math.sin(a), r * math.cos(a)])
        return np.array(out, F)

    def parts(self, p, t):
        a = self.frame_a(p)
        c = sdf.rot_x(a, -self.TURN * t)
        ribs = None
        for k in range(6):
            rib = sd_torus_z(sdf.rot_x(c, k * math.pi / 6), v3(0, 0, 0), self.R, self.RIB)
            ribs = rib if ribs is None else np.minimum(ribs, rib)
        ribs = np.minimum(ribs, sd_torus_x(c, v3(0, 0, 0), self.R, self.RIB))
        side = math.sqrt(self.R ** 2 - 0.58 ** 2)
        for sx in (-0.58, 0.58):
            ribs = np.minimum(ribs, sd_torus_x(c, v3(sx, 0, 0), side, self.RIB))
        axle = sdf.sd_capsule(a, v3(-1.32, 0, 0), v3(1.32, 0, 0), 0.07)
        crank = np.minimum(sdf.sd_capsule(c, v3(1.28, 0, 0), v3(1.28, 0.40, 0), 0.06),
                           sdf.sd_capsule(c, v3(1.28, 0.40, 0), v3(1.62, 0.40, 0), 0.08))
        feet = [sdf.rot_y(np.array([[sx, 0.0, 0.0]], F), self.YAW)[0] + np.asarray(self.CENTRE, F) for sx in (-1.32, 1.32)]
        posts = np.minimum.reduce([sdf.sd_capsule(p, f, v3(f[0], 0.12, f[2]), 0.10) for f in feet])
        bar = sdf.sd_capsule(p, v3(feet[0][0], 0.13, feet[0][2]), v3(feet[1][0], 0.13, feet[1][2]), 0.13)
        stand = np.minimum.reduce([axle, crank, posts, bar])
        balls = sd_spheres(a, self.balls(t), np.full(4, 0.24, F))
        return [(ribs, 0), (stand, 1), (balls, 2)]

    def ball_paint(self, scene, p, n, t):
        return self.ball_col[nearest(self.frame_a(p), self.balls(t))]


# --------------------------------------------------------------------------------------------
class HelpBubble(Scene):
    """Yellow speech bubble with a bold black '?': it tilts side to side like a shrug and hops."""

    frames, fps = 48, 30
    view_height, look_at, pitch = 3.1, (0.0, 1.32, 0.0), 10.0
    bound_radius = 2.0
    shadow_strength = 0.28
    HALF = 0.22

    def __init__(self):
        self.materials = (
            Material(YELLOW, spec=0.5, shininess=42.0, rim=0.22),
            Material(INK, spec=0.4, shininess=30.0, rim=0.10),
        )

    def frame(self, p, t):
        c = v3(0.10, 1.36 + 0.07 * lift(t), 0.0)
        q = sdf.rot_y(p - c, -math.radians(9.0) * math.sin(TAU * t + 0.5 * math.pi))
        return rot_z(q, -math.radians(11.0) * math.sin(TAU * t))

    def glyph2d(self, x, y):
        y = y - 0.05
        cx, cy, R, th = 0.0, 0.27, 0.33, 0.10
        phi = np.degrees(np.arctan2(y - cy, x - cx)) % 360.0
        ring = np.abs(np.sqrt((x - cx) ** 2 + (y - cy) ** 2) - R) - th
        gap = (phi > 195.0) & (phi < 272.0)
        ends = np.array([[cx + R * math.cos(math.radians(a)), cy + R * math.sin(math.radians(a))] for a in (195.0, 272.0)], F)
        cap = np.sqrt((x[:, None] - ends[None, :, 0]) ** 2 + (y[:, None] - ends[None, :, 1]) ** 2).min(1) - th
        hook = np.where(gap, cap, ring)
        sx, sy = ends[1]
        stem = sdf.sd_capsule(np.stack([x, y, np.zeros_like(x)], -1), v3(sx, sy, 0), v3(sx, -0.24, 0), th)
        dot = np.sqrt((x - sx) ** 2 + (y + 0.56) ** 2) - 0.135
        return np.minimum.reduce([hook, stem, dot])

    def parts(self, p, t):
        q = self.frame(p, t)
        body = sd_disc_z(q, v3(0, 0, 0), 1.0, self.HALF, 0.17)
        tail = extrude(LavaKey.sd_polygon(q[:, 0], q[:, 1], [(-0.45, -0.70), (-0.98, -1.22), (-0.15, -0.88)]),
                       q[:, 2], self.HALF - 0.06, 0.07)
        body = sdf.smin(body, tail, 0.12)
        glyph = extrude(self.glyph2d(q[:, 0], q[:, 1]), q[:, 2] - (self.HALF + 0.05), 0.08, 0.03)
        return [(body, 0), (glyph, 1)]


# --------------------------------------------------------------------------------------------
class Players(Scene):
    """Two chunky round-headed figures side by side; the right one waves."""

    frames, fps = 48, 30
    view_height, look_at, pitch = 3.3, (0.0, 1.25, 0.0), 12.0
    bound_radius = 2.2
    shadow_strength = 0.30
    FIGURES = [(-0.66, 0.12, BLUE, 0.0), (0.62, -0.30, GREEN, 0.5)]   # x, z, shirt, bob phase

    def __init__(self):
        self.materials = (
            Material(self.shirt, spec=0.3, shininess=24.0, rim=0.18),
            Material(SKIN, spec=0.25, shininess=28.0, rim=0.16),
            Material(INK, spec=0.5, shininess=40.0, rim=0.0),
        )

    def figure(self, p, t, x, z, phase, waving):
        bob = 0.05 * math.sin(TAU * (t + phase))
        q = p - v3(x, bob, z)
        q = sdf.rot_y(q, math.radians(5.0) * math.sin(TAU * (t + phase)))
        body = sdf.sd_round_cone(q, v3(0, 0.30, 0), 0.50, 0.36, 0.75)
        head = sdf.sd_sphere(q, v3(0, 1.55, 0), 0.42)
        eyes = sd_spheres(q, np.array([[-0.15, 1.60, 0.37], [0.15, 1.60, 0.37]], F), np.full(2, 0.065, F))
        arm_l = sdf.sd_capsule(q, v3(-0.42, 1.02, 0.05), v3(-0.62, 0.45, 0.15), 0.13)
        if waving:
            sh = v3(0.44, 1.05, 0.05)
            el = sh + v3(0.36, 0.30, 0.10)
            swing = math.radians(28.0) * math.sin(TAU * 2 * t)
            hand = el + v3(0.42 * math.sin(swing) * -1.0 + 0.10, 0.52 * math.cos(swing), 0.05)
            arm_r = np.minimum(sdf.sd_capsule(q, sh, el, 0.13), sdf.sd_capsule(q, el, hand, 0.12))
            palm = sdf.sd_sphere(q, hand, 0.16)
        else:
            arm_r = sdf.sd_capsule(q, v3(0.42, 1.02, 0.05), v3(0.62, 0.45, 0.15), 0.13)
            palm = sdf.sd_sphere(q, v3(0.62, 0.45, 0.15), 0.15)
        hands = np.minimum(palm, sdf.sd_sphere(q, v3(-0.62, 0.45, 0.15), 0.15))
        return np.minimum.reduce([body, arm_l, arm_r]), np.minimum(head, hands), eyes

    def parts(self, p, t):
        shirts, skins, eyes = [], [], []
        for i, (x, z, _, ph) in enumerate(self.FIGURES):
            s, k, e = self.figure(p, t, x, z, ph, waving=(i == 1))
            shirts.append(s), skins.append(k), eyes.append(e)
        return [(np.minimum.reduce(shirts), 0), (np.minimum.reduce(skins), 1), (np.minimum.reduce(eyes), 2)]

    def shirt(self, scene, p, n, t):
        centres = np.array([[x, 0.6, z] for x, z, _, _ in self.FIGURES], F)
        cols = np.array([c for _, _, c, _ in self.FIGURES], F)
        return cols[nearest(p, centres)]


# --------------------------------------------------------------------------------------------
class Dice(Scene):
    """One-shot: a chunky cream die hops, tumbles a quarter turn on two axes and lands showing
    a new face, with a little squash on landing."""

    frames, fps = 30, 30
    view_height, look_at, pitch = 2.9, (0.0, 0.85, 0.0), 22.0
    bound_radius = 2.0
    shadow_strength = 0.34
    H = 0.56
    PIPS = {1: [(0, 0)], 2: [(-1, -1), (1, 1)], 3: [(-1, -1), (0, 0), (1, 1)],
            4: [(-1, -1), (1, -1), (-1, 1), (1, 1)], 5: [(-1, -1), (1, -1), (0, 0), (-1, 1), (1, 1)],
            6: [(-1, -1), (1, -1), (-1, 0), (1, 0), (-1, 1), (1, 1)]}

    def __init__(self):
        pts = []
        s, h = 0.30, self.H
        faces = [(1, (0, 1, 0)), (6, (0, -1, 0)), (2, (0, 0, 1)), (5, (0, 0, -1)), (3, (1, 0, 0)), (4, (-1, 0, 0))]
        for value, normal in faces:
            nx, ny, nz = normal
            if ny != 0:
                u, v = (1, 0, 0), (0, 0, 1)
            elif nz != 0:
                u, v = (1, 0, 0), (0, 1, 0)
            else:
                u, v = (0, 0, 1), (0, 1, 0)
            for a, b in self.PIPS[value]:
                pts.append([h * nx + s * (a * u[0] + b * v[0]), h * ny + s * (a * u[1] + b * v[1]),
                            h * nz + s * (a * u[2] + b * v[2])])
        self.pips = np.array(pts, F)
        self.materials = (
            Material(CREAM, spec=0.35, shininess=30.0, rim=0.18),
            Material(INK, spec=0.4, shininess=30.0, rim=0.0),
        )

    def pose(self, t):
        k = min(t / 0.78, 1.0)
        e = ease(k)
        hop = 1.05 * math.sin(math.pi * k)
        settle = max(0.0, (t - 0.78) / 0.22)
        squash = 0.12 * math.sin(math.pi * settle) if settle > 0 else 0.0
        return e, hop, squash

    def frame(self, p, t):
        e, hop, squash = self.pose(t)
        c = v3(-0.55 + 1.1 * e, self.H + hop, 0.0)
        q = p - c
        q[:, 1] /= (1.0 - squash)
        q[:, 0] *= (1.0 - squash * 0.5)
        q[:, 2] *= (1.0 - squash * 0.5)
        q = sdf.rot_y(q, -math.radians(32.0))
        q = sdf.rot_x(q, -0.5 * math.pi * e)
        q = rot_z(q, 0.5 * math.pi * e)
        return q

    def parts(self, p, t):
        q = self.frame(p, t)
        cube = sd_box(q, v3(0, 0, 0), (self.H, self.H, self.H), 0.16)
        pips = sd_spheres(q, self.pips, np.full(len(self.pips), 0.105, F))
        return [(cube, 0), (pips * 0.9, 1)]


# --------------------------------------------------------------------------------------------
class Pencil(Scene):
    """One-shot: a fat yellow pencil writes a short wavy stroke from left to right."""

    frames, fps = 30, 30
    view_height, look_at, pitch = 3.1, (0.05, 0.95, 0.0), 30.0
    bound_radius = 2.2
    shadow_strength = 0.30
    DIR = (0.42, 0.84, -0.30)
    R, LEN = 0.17, 1.55

    def __init__(self):
        d = np.asarray(self.DIR, F)
        self.d = d / np.linalg.norm(d)
        n = 32
        u = np.linspace(0.0, 1.0, n + 1, dtype=F)
        self.path = np.stack([-0.72 + 1.24 * u, np.full_like(u, 0.03), 0.22 * np.sin(TAU * 1.5 * u)], 1)
        self.materials = (
            Material(self.paint, spec=0.45, shininess=40.0, rim=0.20),
            Material(INK, spec=0.3, shininess=20.0, rim=0.0),
        )

    def progress(self, t):
        return ease(t / 0.92)

    def tip(self, t):
        k = self.progress(t) * (len(self.path) - 1)
        i = min(int(k), len(self.path) - 2)
        return self.path[i] + (self.path[i + 1] - self.path[i]) * (k - i)

    def axial(self, p, t):
        """(distance from the axis, height along the pencil from the tip)."""
        q = p - self.tip(t)
        h = q @ self.d
        return sdf.length(q - h[:, None] * self.d), h

    def parts(self, p, t):
        rad, h = self.axial(p, t)
        tip_len = 0.42
        cone = sdf.sd_round_cone(np.stack([rad, h, np.zeros_like(h)], -1), v3(0, 0.0, 0), 0.015, self.R, tip_len)
        dy = np.abs(h - (tip_len + self.LEN * 0.5)) - self.LEN * 0.5
        dx = rad - self.R
        body = np.minimum(np.maximum(dx, dy), 0.0) + np.sqrt(np.maximum(dx, 0.0) ** 2 + np.maximum(dy, 0.0) ** 2) - 0.04
        pencil = sdf.smin(cone, body, 0.02)
        k = int(self.progress(t) * (len(self.path) - 1))
        if k >= 1:
            a, b = self.path[:k], self.path[1:k + 1]
            pa = p[:, None, :] - a[None]
            ba = b - a
            hh = np.clip((pa * ba[None]).sum(-1) / (ba * ba).sum(-1)[None], 0.0, 1.0)
            seg = sdf.length(pa - hh[..., None] * ba[None]).min(1)
            stroke = seg - 0.075
            stroke = np.maximum(stroke, -p[:, 1] - 0.0)
        else:
            stroke = np.full(p.shape[0], 9.0, F)
        return [(pencil, 0), (stroke, 1)]

    def paint(self, scene, p, n, t):
        _, h = self.axial(p, t)
        col = const(YELLOW, p)
        col = mix(col, CREAM, 1.0 - sdf.smoothstep(0.40, 0.46, h))
        col = mix(col, INK, 1.0 - sdf.smoothstep(0.17, 0.21, h))
        back = 0.42 + self.LEN
        col = mix(col, INK, sdf.smoothstep(back - 0.34, back - 0.31, h) * (1.0 - sdf.smoothstep(back - 0.25, back - 0.22, h)))
        col = mix(col, PINK, sdf.smoothstep(back - 0.25, back - 0.22, h))
        return col


SCENES = {"globe": Globe, "open_book": OpenBook, "bingo_cage": BingoCage, "help_bubble": HelpBubble,
          "players": Players, "dice": Dice, "pencil": Pencil}
ONESHOT = {"dice", "pencil"}


def _render(job):
    name, index, total, ss, path = job
    scene = SCENES[name]()
    # one-shot icons end on their last pose: phase runs 0..1 inclusive
    t = index / (total - 1) if name in ONESHOT else index / total
    Image.fromarray(sdf.render_frame(scene, t, ss)).save(path)
    return path


def contact_sheet(frames_dir, out, count=8):
    paths = sorted(os.path.join(frames_dir, f) for f in os.listdir(frames_dir) if f.startswith("frame_"))
    picks = [paths[int(i * (len(paths) - 1) / (count - 1))] for i in range(count)]
    ims = [Image.open(p).convert("RGBA") for p in picks]
    w, h = ims[0].size
    sheet = Image.new("RGBA", (w * count, h), (255, 253, 245, 255))
    for i, im in enumerate(ims):
        sheet.alpha_composite(im, (i * w, 0))
    sheet.convert("RGB").save(out)


def keys_strip(assets_dir, out):
    names = sorted(d for d in os.listdir(assets_dir) if os.path.exists(os.path.join(assets_dir, d, "image_1.webp")))
    ims = [Image.open(os.path.join(assets_dir, n, "image_1.webp")).convert("RGBA").resize((180, 162)) for n in names]
    sheet = Image.new("RGBA", (180 * len(ims), 162 + 18), (255, 253, 245, 255))
    from PIL import ImageDraw
    d = ImageDraw.Draw(sheet)
    for i, (n, im) in enumerate(zip(names, ims)):
        sheet.alpha_composite(im, (i * 180, 0))
        d.text((i * 180 + 4, 164), n, fill=(18, 18, 18, 255))
    sheet.convert("RGB").save(out)


def mark_oneshot(bundle_dir):
    path = os.path.join(bundle_dir, "manifest.json")
    m = json.load(open(path))
    m["loop"] = False
    json.dump(m, open(path, "w"), separators=(",", ":"))


def main(argv):
    if argv[0] == "--sheet":
        return contact_sheet(argv[1], argv[2], int(argv[3]) if len(argv) > 3 else 8)
    if argv[0] == "--keys":
        return keys_strip(argv[1], argv[2])
    if argv[0] == "--oneshot":
        return mark_oneshot(argv[1])
    name = argv[0]
    scene = SCENES[name]()
    if "--still" in argv:
        at = argv.index("--still")
        Image.fromarray(sdf.render_frame(scene, float(argv[at + 1]), 3)).save(argv[at + 2])
        return
    frames_dir = argv[1]
    os.makedirs(frames_dir, exist_ok=True)
    jobs = [(name, i, scene.frames, 3, os.path.join(frames_dir, f"frame_{i:03d}.png")) for i in range(scene.frames)]
    with Pool(max(1, (os.cpu_count() or 2) - 2)) as pool:
        paths = pool.map(_render, jobs)
    print(f"{name}: {len(paths)} frames @ {scene.fps} fps -> {frames_dir}")


if __name__ == "__main__":
    main(sys.argv[1:])
