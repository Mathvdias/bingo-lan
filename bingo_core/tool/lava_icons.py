"""Ícones Lava do Bingo: still 3D -> cutout -> 48 quadros em loop -> bundle OpenLava.

Reaproveita o pipeline de `lava_flutter/tool` (animate_icon.py + relight_icon.py +
openlava_encode.py) sem alterá-lo: cada ícone é uma subclasse de `Subject` registrada aqui.

    LAVA_TOOL=~/Developer/portifolio/packages/lava_flutter/tool \
      python3 tool/lava_icons.py bingo_ball stills/bingo_ball.png frames/bingo_ball
    python3 $LAVA_TOOL/openlava_encode.py assets/lava/bingo_ball --webp 90 frames/bingo_ball/frame_*.png

Paleta do app (neo-brutalista pastel): amarelo #FFEB3B, azul #4FC3F7, verde #AED581, creme #FFFDF5,
contorno #121212. Movimentos são funções de sin(2*pi*t) para que metade dos quadros repita a outra
(o empacotador de tiles guarda cada pose uma vez só).
"""
import math
import os
import sys

import numpy as np
from PIL import Image, ImageDraw, ImageFilter

TOOL = os.environ.get(
    "LAVA_TOOL",
    os.path.expanduser("~/Developer/portifolio/packages/lava_flutter/tool"),
)
sys.path.insert(0, TOOL)
import animate_icon as ai  # noqa: E402
from relight_icon import key_backdrop  # noqa: E402

SS = ai.SS
YELLOW, BLUE, GREEN, CREAM, INK = (255, 235, 59), (79, 195, 247), (174, 213, 129), (255, 253, 245), (18, 18, 18)


def rock(t, deg, phase=0.0):
    return deg * math.sin(2 * math.pi * t + phase)


def lift(t):
    """0..1, duas subidas por volta e simétrico em t -> 0.5 - t (mesma pose que o balanço)."""
    return (1 - math.cos(4 * math.pi * t)) / 2


class BingoBall(ai.Subject):
    """Bola azul com o 7: balança e quica de leve; a sombra encolhe quando ela sobe."""
    fill = 0.78

    def motion(self, t):
        up = lift(t)
        return rock(t, 7.0), 0.0, -3.0 * up, 1 - 0.10 * up, 1 - 0.25 * up


class BingoCage(ai.Subject):
    """Globo de bingo: giro lento simulado por um balanço mais amplo e um leve tremor das bolas."""
    fill = 0.84

    def motion(self, t):
        return rock(t, 8.0), 0.0, 0.0, 1 + 0.03 * math.sin(2 * math.pi * t), 1.0


class PremiumBadge(ai.Subject):
    """Roseta com estrela: balanço + um brilho diagonal que varre a medalha uma vez por volta."""
    fill = 0.82
    SHINE = (0.55, 0.85)   # janela do brilho; fora dela o quadro é o still (tiles repetem)

    def __init__(self, obj):
        super().__init__(obj)
        self.base = ai.premul(np.array(obj))
        yy, xx = np.mgrid[0:self.oh, 0:self.ow]
        self.proj = (xx + yy) / math.sqrt(2)
        self.alpha = np.array(obj)[..., 3:4].astype(np.float32) / 255

    def layer(self, t):
        a, b = self.SHINE
        if not (a <= t <= b):
            return self.obj
        u = (t - a) / (b - a)
        lo, hi = self.proj.min(), self.proj.max()
        c = lo + (hi - lo) * u
        w = 0.07 * (hi - lo)
        k = np.exp(-((self.proj - c) / w) ** 2)[..., None] * math.sin(math.pi * u)
        rgb = np.array(self.obj).astype(np.float32)[..., :3]
        rgb = rgb + (255 - rgb) * 0.55 * k * (self.alpha > 0.5)
        out = np.dstack([np.clip(rgb, 0, 255), self.alpha * 255]).astype(np.uint8)
        return Image.fromarray(out)

    def motion(self, t):
        return rock(t, 5.0), 0.0, -1.5 * lift(t), 1.0, 1.0


class Trophy(ai.Subject):
    """Taça com confete da paleta caindo em volta (o confete do still é descartado pelo recorte)."""
    fill = 0.84
    PIECES = [  # (x0, fase, cor, largura, altura, giro, balanço)
        (0.08, 0.00, BLUE, 20, 12, 1.0, 0.04), (0.20, 0.35, GREEN, 16, 10, -1.3, 0.03),
        (0.30, 0.70, YELLOW, 18, 11, 0.8, 0.05), (0.42, 0.15, CREAM, 14, 9, -1.0, 0.03),
        (0.55, 0.50, BLUE, 16, 10, 1.4, 0.04), (0.66, 0.85, GREEN, 20, 12, -0.7, 0.05),
        (0.78, 0.25, CREAM, 14, 9, 1.1, 0.03), (0.90, 0.60, YELLOW, 18, 11, -1.2, 0.04),
        (0.14, 0.92, YELLOW, 14, 9, 0.9, 0.03), (0.86, 0.05, BLUE, 14, 9, -0.9, 0.04),
    ]

    @staticmethod
    def pad_cut(cut):
        h, w = cut.shape[:2]
        mx, mt = int(0.42 * w), int(0.22 * h)
        out = np.zeros((h + mt, w + 2 * mx, 4), np.uint8)
        out[mt:, mx:mx + w] = cut
        return out

    def _confetti(self, t, front):
        img = Image.new("RGBA", (self.ow, self.oh), (0, 0, 0, 0))
        d = ImageDraw.Draw(img)
        for i, (x0, ph, col, pw, ph_, spin, sway) in enumerate(self.PIECES):
            if (i % 2 == 0) != front:
                continue
            u = (t + ph) % 1.0
            x = (x0 + sway * math.sin(2 * math.pi * (2 * t + ph))) * self.ow
            y = u * self.oh * 0.92
            fade = min(1.0, u / 0.12, (1 - u) / 0.12)
            ang = 2 * math.pi * (spin * t + ph)
            # retângulo girando em torno de dois eixos (achata quando "vira" para a câmera)
            cw, chh = pw * SS / 4 * abs(math.cos(ang * 0.5)) + 2, ph_ * SS / 4
            ca, sa = math.cos(ang), math.sin(ang)
            pts = [(x + ca * dx - sa * dy, y + sa * dx + ca * dy)
                   for dx, dy in ((-cw, -chh), (cw, -chh), (cw, chh), (-cw, chh))]
            d.polygon(pts, fill=col + (int(255 * fade),), outline=INK + (int(255 * fade),), width=SS // 2)
        return img

    def layer(self, t):
        img = self._confetti(t, front=False)
        img.alpha_composite(self.obj)
        img.alpha_composite(self._confetti(t, front=True))
        return img

    def motion(self, t):
        return rock(t, 4.0), 0.0, -1.0 * lift(t), 0.62, 1.0


class CameraScan(ai.Subject):
    """Celular com QR: uma linha azul de leitura varre a tela de cima a baixo (cometa) e volta."""
    fill = 0.86

    def __init__(self, obj):
        super().__init__(obj)
        a = np.array(obj).astype(int)
        mn, ch = a[..., :3].min(axis=2), a[..., :3].max(axis=2) - a[..., :3].min(axis=2)
        pale = (a[..., 3] > 200) & (mn > 200) & (ch < 30)
        screen = ai.largest_component(pale)
        screen = ai.fill_holes(screen)
        # tira a borda creme do corpo: fica só o que está longe do contorno do aparelho
        screen = np.array(Image.fromarray(screen.astype(np.uint8) * 255).filter(ImageFilter.MinFilter(2 * (3 * SS) + 1))) > 0
        self.screen = screen
        ys = np.where(screen.any(axis=1))[0]
        self.y0, self.y1 = int(ys.min()), int(ys.max())

    def layer(self, t):
        # vai e volta: posição simétrica em t -> 1 - t, então metade dos quadros repete
        u = (1 - math.cos(2 * math.pi * t)) / 2
        y = self.y0 + (self.y1 - self.y0) * u
        yy = np.arange(self.oh, dtype=np.float32)[:, None]
        direction = 1.0 if math.sin(2 * math.pi * t) >= 0 else -1.0
        core = np.exp(-((yy - y) / (1.2 * SS)) ** 2)
        tail = np.exp(-np.clip(direction * (y - yy), 0, None) / (9 * SS)) * (direction * (y - yy) > 0)
        k = np.clip(core * 1.0 + tail * 0.45, 0, 1) * self.screen[..., None][..., 0]
        k = k[..., None]
        a = np.array(self.obj).astype(np.float32)
        rgb = a[..., :3] * (1 - k) + np.array(BLUE, np.float32) * k
        return Image.fromarray(np.dstack([np.clip(rgb, 0, 255), a[..., 3]]).astype(np.uint8))

    def motion(self, t):
        return rock(t, 4.0), 0.0, 0.0, 1.0, 1.0


class InfoBubble(ai.Subject):
    """Balão de informação flutuando: balanço e sobe-desce suaves."""
    fill = 0.84

    def motion(self, t):
        up = lift(t)
        return rock(t, 6.0), 0.0, -3.0 * up, 1 - 0.08 * up, 1 - 0.2 * up


SUBJECTS = {
    "bingo_ball": BingoBall,
    "bingo_cage": BingoCage,
    "premium_badge": PremiumBadge,
    "trophy": Trophy,
    "camera_scan": CameraScan,
    "info_bubble": InfoBubble,
}
# fundo branco com sombra assada: a sombra cinza neutra da metade de baixo vai junto com o fundo.
KEY = {
    "bingo_ball": dict(shadow_min=120),
    "premium_badge": dict(shadow_min=120),
    "trophy": dict(shadow_min=120),
}


def despill_cream(cut):
    """O corpo creme do celular reflete o fundo magenta (R e B acima de G): volta a ser creme.
    Só mexe em pixels rosados; o azul dos cantos (R < G) e o preto ficam como estão."""
    rgb = cut[..., :3].astype(int)
    r, g, b = rgb[..., 0], rgb[..., 1], rgb[..., 2]
    pink = (cut[..., 3] > 0) & (r > g) & (b > g - 6)
    r = np.where(pink, np.minimum(r, g + 3), r)
    b = np.where(pink, np.minimum(b, g - 2), b)
    return np.dstack([r, g, b, cut[..., 3]]).astype(np.uint8)
ai.SUBJECTS.update(SUBJECTS)


def main():
    kind, src, out_dir = sys.argv[1], sys.argv[2], sys.argv[3]
    n = int(sys.argv[4]) if len(sys.argv) > 4 else None
    img = Image.open(src)
    if img.mode == "RGBA" and np.array(img)[..., 3].min() < 250:
        cut = np.array(img)
    else:
        cut = np.clip(key_backdrop(img, **KEY.get(kind, {})), 0, 255).astype(np.uint8)
    if kind == "camera_scan":
        cut = despill_cream(cut)
    cut = ai.crop_to_alpha(cut)
    if kind == "trophy":
        cut = Trophy.pad_cut(cut)
    os.makedirs(out_dir, exist_ok=True)
    Image.fromarray(cut).save(os.path.join(os.path.dirname(out_dir.rstrip("/")) or ".", f"{kind}_cutout.png"))
    paths = ai.render(kind, cut, out_dir, n)
    print(f"{kind}: {len(paths)} frames -> {out_dir}")


if __name__ == "__main__":
    main()
