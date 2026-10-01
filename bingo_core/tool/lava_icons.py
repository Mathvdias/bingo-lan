"""Ícones Lava do Bingo: still 3D -> cutout -> 48 quadros em loop -> bundle OpenLava.

Reaproveita o pipeline de `lava_flutter/tool` (animate_icon.py + relight_icon.py +
openlava_encode.py) sem alterá-lo: cada ícone é uma subclasse de `Subject` registrada aqui.

    LAVA_TOOL=~/Developer/portifolio/packages/lava_flutter/tool \
      python3 tool/lava_icons.py bingo_ball stills/bingo_ball.png frames/bingo_ball
    python3 $LAVA_TOOL/openlava_encode.py assets/lava/bingo_ball --webp 90 frames/bingo_ball/frame_*.png
    python3 tool/lava_icons.py repack assets/lava/wifi_table frames/wifi_table   # 360x324 -> 270x243, 24 q @ 15 fps

Ícones que precisam girar de verdade (livro, dado, lápis) são cenas 3D em `lava_sdf_icons.py`. A gaiola
de bingo passou por lá e voltou: a cena SDF (hastes de tubo amarelo girando) parecia plástico e a emenda
do loop aparecia; o still de hastes gordas com as bolas repintadas e pulando (`BingoCage`) ficou melhor.

    LAVA_SCALE=2 python3 tool/lava_icons.py bingo_cage stills/cage.png frames/bingo_cage   # 360x324
    python3 $LAVA_TOOL/openlava_encode.py assets/lava/bingo_cage --fps 24 --webp 88 --density 4 frames/bingo_cage/frame_*.png

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


class BingoSubject(ai.Subject):
    """Base dos ícones do app: objeto um pouco menor e mais alto no canvas para a sombra de
    contato (desfocada) caber inteira em vez de ser cortada na borda de baixo."""
    fill = 0.72
    base_y = 0.80


def rock(t, deg, phase=0.0):
    return deg * math.sin(2 * math.pi * t + phase)


def lift(t):
    """0..1, duas subidas por volta e simétrico em t -> 0.5 - t (mesma pose que o balanço)."""
    return (1 - math.cos(4 * math.pi * t)) / 2


class BingoBall(BingoSubject):
    """Bola azul com o 7: balança e quica de leve; a sombra encolhe quando ela sobe."""
    fill = 0.70

    def motion(self, t):
        up = lift(t)
        return rock(t, 7.0), 0.0, -3.0 * up, 1 - 0.10 * up, 1 - 0.25 * up


class BingoCage(BingoSubject):
    """Gaiola de bingo (sala do host, 120 px): o still de uma gaiola de poucas hastes gordas com
    quatro bolas pastel dentro. O corpo só balança 3 graus, sem subir; as bolas do still são
    apagadas da camada e redesenhadas por trás dela (as hastes da frente que as cruzam ficam
    no still, então a oclusão sai certa) e cada uma pula no seu próprio compasso, com um balanço
    lateral pequeno. Nenhum giro falso: a gaiola parece viva sem emenda no loop."""
    fill = 0.76
    LIGHT = (-0.40, -0.48)     # direção do brilho nas bolas, em raios (luz do alto à esquerda)
    # (x, y, raio, cor, fase, pulos por volta) em unidades do raio da esfera a partir do centro
    # dela, de trás para a frente, medidos no still (as bolas do still são apagadas, estas são
    # pintadas no lugar). Fases 0 / 0.5 e pulos pares deixam o quadro t igual ao 0.5 - t, como o
    # balanço: metade dos quadros repete e o atlas cai pela metade.
    BALLS = [(0.38, 0.50, 0.19, (255, 250, 236), 0.5, 4), (-0.13, 0.70, 0.21, GREEN, 0.0, 2),
             (-0.40, 0.58, 0.21, BLUE, 0.5, 2), (0.26, 0.64, 0.21, (255, 172, 166), 0.0, 4)]

    def __init__(self, obj):
        super().__init__(obj)
        a = np.array(obj).astype(int)
        r, g, b, al = a[..., 0], a[..., 1], a[..., 2], a[..., 3]
        solid = al > 128
        # hastes: amarelo e o laranja sombreado delas (vermelho acima do verde, azul bem abaixo)
        rib = solid & (r > g + 10) & (b < 0.62 * g + 10) & (r - b > 40)
        bright = solid & (r > 150) & (g > 110) & (b < 120) & (r - b > 80)
        ys, xs = np.where(bright)
        self.cage_r = 0.5 * (xs.max() - xs.min())
        self.cage_c = (0.5 * (xs.max() + xs.min()), ys.min() + self.cage_r)
        yy, xx = np.mgrid[0:self.oh, 0:self.ow]
        self.inside = (xx - self.cage_c[0]) ** 2 + (yy - self.cage_c[1]) ** 2 < (0.97 * self.cage_r) ** 2
        # só a faixa das bolas: acima dela estão o eixo e os reflexos quase brancos das hastes,
        # que passariam no teste de "creme" e levariam a borda iluminada do eixo junto
        lower = yy > self.cage_c[1] + 0.26 * self.cage_r
        # preto do eixo e da base: só os blocos grandes (a sombra escura na borda das bolas não)
        dark = np.zeros((self.oh, self.ow), bool)
        for m in component_masks(solid & (a[..., :3].max(axis=2) < 80), min_px=int(0.05 * self.cage_r ** 2)):
            dark |= m
        # com a borda iluminada (cinza) do eixo junto: ela não é bola
        dark = np.array(Image.fromarray(dark.astype(np.uint8) * 255).filter(ImageFilter.MaxFilter(4 * SS + 1))) > 0
        # as bolas do still: os pixels pastel da metade de baixo da esfera e, à volta deles, tudo
        # que não é haste nem preto (a sombra escura na borda de cada bola)
        chroma = a[..., :3].max(axis=2) - a[..., :3].min(axis=2)
        pastel = ((b > r + 30) & (b > 150)) | ((g > r + 15) & (g > b + 15) & (g > 140)) | \
                 ((r > g + 25) & (b > g - 20) & (r > 190) & (g > 120)) | ((a[..., :3].min(axis=2) > 185) & (chroma < 45))
        seed = solid & self.inside & lower & ~rib & ~dark & pastel
        near = np.array(Image.fromarray(seed.astype(np.uint8) * 255).filter(ImageFilter.MaxFilter(6 * SS + 1))) > 0
        ball_px = solid & self.inside & lower & ~rib & ~dark & near
        # o topo das bolas coloridas sobe acima da faixa: azul, verde e rosa não existem em mais
        # nada da gaiola, então saem em toda a metade de baixo (o creme ficaria com os reflexos)
        tinted = ((b > r + 30) & (b > 150)) | ((g > r + 12) & (g > b + 12) & (g > 85)) | \
                 ((r > g + 25) & (b > g - 20) & (r > 190) & (g > 120))
        ball_px |= solid & self.inside & (yy > self.cage_c[1]) & tinted & ~rib
        ball_px = np.array(Image.fromarray(ball_px.astype(np.uint8) * 255).filter(ImageFilter.MaxFilter(3 * SS + 1))) > 0
        ball_px &= ~dark
        body = np.array(obj).astype(np.float32)
        body[..., 3] *= ~ball_px
        self.body = Image.fromarray(body.astype(np.uint8))

    def _ball(self, layer, cx, cy, rad, col):
        """Esfera pintada fosca: lambert suave, brilho largo e discreto, borda um pouco mais escura."""
        x0, y0 = int(cx - rad - 2), int(cy - rad - 2)
        x1, y1 = int(cx + rad + 3), int(cy + rad + 3)
        x0, y0, x1, y1 = max(x0, 0), max(y0, 0), min(x1, self.ow), min(y1, self.oh)
        yy, xx = np.mgrid[y0:y1, x0:x1]
        dx, dy = (xx - cx) / rad, (yy - cy) / rad
        d2 = dx * dx + dy * dy
        cover = np.clip((1.0 - np.sqrt(d2)) * rad + 0.5, 0.0, 1.0)      # borda antisserrilhada
        nz = np.sqrt(np.clip(1.0 - d2, 0.0, 1.0))
        lx, ly = self.LIGHT
        ln = math.sqrt(lx * lx + ly * ly + 0.75 ** 2)
        lamb = np.clip((dx * lx + dy * ly + nz * 0.75) / ln, 0.0, 1.0)
        shade = 0.72 + 0.30 * lamb
        spec = np.exp(-((dx - lx * 0.6) ** 2 + (dy - ly * 0.6) ** 2) / 0.16) * 0.16
        rgb = np.asarray(col, np.float32)[None, None, :] * shade[..., None] + 255.0 * spec[..., None]
        rgb = rgb * (0.88 + 0.12 * nz)[..., None]
        alpha = cover * self.inside[y0:y1, x0:x1]
        dst = layer[y0:y1, x0:x1]
        a = alpha[..., None]
        dst[..., :3] = rgb * a + dst[..., :3] * (1 - a)
        dst[..., 3] = alpha * 255 + dst[..., 3] * (1 - alpha)

    def fold(self, t):
        """Fase dentro da meia-volta, quantizada na grade de quadros: o quadro i sai bit a bit igual
        ao i + n/2 (sin(4*pi*t) avaliado em t e t + 0.5 difere por ruído de float e o empacotador
        guardaria cada tile duas vezes)."""
        n = self.n_frames
        return (round(t * n) % (n // 2)) / n

    def layer(self, t):
        t = self.fold(t)
        balls = np.zeros((self.oh, self.ow, 4), np.float32)
        cx0, cy0, R = self.cage_c[0], self.cage_c[1], self.cage_r
        for bx, by, br, col, ph, beats in self.BALLS:
            hop = abs(math.sin(math.pi * beats * (t + ph)))
            rad = br * R
            x = cx0 + bx * R + 0.06 * rad * math.sin(2 * math.pi * (t + ph))
            y = cy0 + by * R - (0.22 if beats == 2 else 0.14) * rad * hop
            self._ball(balls, x, y, rad, col)
        img = Image.fromarray(np.clip(balls, 0, 255).astype(np.uint8))
        img.alpha_composite(self.body)
        return img

    def motion(self, t):
        # duas oscilações por volta, como os pulos: o quadro i é igual ao i + 24 e o atlas cabe
        # em 450 KB com WebP 88 (uma só oscilação dava 26 poses únicas e 518 KB)
        t = self.fold(t)
        return rock(2 * t, 3.0), 0.0, 0.0, 1 + 0.02 * math.sin(4 * math.pi * t), 1.0


class PremiumBadge(BingoSubject):
    """Roseta com estrela: balanço + um brilho diagonal que varre a medalha uma vez por volta."""
    fill = 0.74
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


class Trophy(BingoSubject):
    """Taça com confete da paleta caindo em volta (o confete do still é descartado pelo recorte)."""
    fill = 0.76
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


class CameraScan(BingoSubject):
    """Celular com QR: uma linha azul de leitura varre a tela de cima a baixo (cometa) e volta."""
    fill = 0.77

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


class InfoBubble(BingoSubject):
    """Balão de informação flutuando: balanço e sobe-desce suaves."""
    fill = 0.76

    def motion(self, t):
        up = lift(t)
        return rock(t, 6.0), 0.0, -3.0 * up, 1 - 0.08 * up, 1 - 0.2 * up


def component_masks(mask, min_px):
    """Componentes conexos de `mask` (bool), como máscaras, do maior para o menor."""
    img = Image.fromarray(mask.astype(np.uint8) * 255).copy()
    out = []
    ys, xs = np.where(mask)
    for y, x in zip(ys[::7], xs[::7]):
        if img.getpixel((int(x), int(y))) != 255:
            continue
        ImageDraw.floodfill(img, (int(x), int(y)), 128)
        comp = np.array(img) == 128
        ImageDraw.floodfill(img, (int(x), int(y)), 64)
        if comp.sum() >= min_px:
            out.append(comp)
    return sorted(out, key=lambda m: -m.sum())


class WarningSign(BingoSubject):
    """Placa de aviso: balança e sobe-desce de leve."""
    fill = 0.74

    def motion(self, t):
        up = lift(t)
        return rock(t, 5.0), 0.0, -2.0 * up, 1 - 0.06 * up, 1 - 0.15 * up


class OpenBook(BingoSubject):
    """Livro aberto: só o balanço (as páginas são o still)."""
    fill = 0.70

    def motion(self, t):
        return rock(t, 5.0), 0.0, -1.0 * lift(t), 1.0, 1.0


class Globe(BingoSubject):
    """Globo de mesa ao lado do título "Idioma": só um balanço discreto de 4 graus, sem subir nem
    girar (um globo rodando no canto de um título puxava o olho; 48 quadros, --webp 88)."""
    fill = 0.76

    def motion(self, t):
        return rock(t, 4.0), 0.0, 0.0, 1.0, 1.0


class WifiRouter(BingoSubject):
    """Roteador com bolas: os arcos azuis do sinal acendem um a um (3 níveis discretos, de
    dentro para fora) e o conjunto balança de leve."""
    fill = 0.76
    LEVELS = (0.55, 0.78, 1.0)

    def __init__(self, obj):
        super().__init__(obj)
        a = np.array(obj).astype(int)
        r, g, b = a[..., 0], a[..., 1], a[..., 2]
        blue = (a[..., 3] > 128) & (b > r + 70) & (b > 150) & (g > 120)
        comps = component_masks(blue, min_px=200 * SS)
        # arcos ordenados pela altura do topo: o mais baixo é o mais próximo do roteador
        comps = sorted(comps, key=lambda m: -np.where(m.any(axis=1))[0].min())
        self.arcs = comps[:3]
        self.base = np.array(obj).astype(np.float32)

    def layer(self, t):
        n = len(self.arcs)
        if n == 0:
            return self.obj
        # onda que atravessa os arcos: cada um fica num de 3 níveis
        a = self.base.copy()
        for i, m in enumerate(self.arcs):
            ph = (t - i / (n + 1)) % 1.0
            k = (1 - math.cos(2 * math.pi * ph)) / 2
            lvl = self.LEVELS[min(2, int(k * 3))]
            rgb = a[..., :3][m]
            # escurece para o cinza-azulado quando "apagado"
            a[..., :3][m] = rgb * lvl + np.array([200, 215, 225], np.float32) * (1 - lvl) * 0.5
        return Image.fromarray(np.clip(a, 0, 255).astype(np.uint8))

    def motion(self, t):
        return rock(t, 4.0), 0.0, 0.0, 1.0, 1.0


SUBJECTS = {
    "bingo_ball": BingoBall,
    "bingo_cage": BingoCage,
    "premium_badge": PremiumBadge,
    "trophy": Trophy,
    "camera_scan": CameraScan,
    "info_bubble": InfoBubble,
    "warning_sign": WarningSign,
    "open_book": OpenBook,
    "globe": Globe,
    "wifi_table": WifiRouter,
}
# fundo branco com sombra assada: a sombra cinza neutra da metade de baixo vai junto com o fundo.
KEY = {
    "bingo_ball": dict(shadow_min=120),
    # as hastes fecham células em 2D: o branco preso dentro da esfera não tem caminho até a borda
    "bingo_cage": dict(shadow_min=120, neutral_pockets=225, pocket_chroma=14),
    "premium_badge": dict(shadow_min=120),
    "trophy": dict(shadow_min=120),
}


def despill_magenta(cut, k=2.0):
    """Luz magenta refletida pelo fundo no corpo branco e nas bolas (R e B acima de G): tira
    `k` vezes o excesso, mais forte que o despill padrão do key_backdrop."""
    rgb = cut[..., :3].astype(np.float32)
    m = np.clip(np.minimum(rgb[..., 0], rgb[..., 2]) - rgb[..., 1], 0, None)
    rgb[..., 0] -= k * m
    rgb[..., 2] -= k * m
    return np.dstack([np.clip(rgb, 0, 255).astype(np.uint8), cut[..., 3]])


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


def repack(bundle_dir, out_dir):
    """Reduz um bundle já codificado: metade dos quadros (um loop sin-simétrico aguenta 15 fps) e
    270x243 (density 3), para o roteador de 220 px ficar abaixo de 250 KB. Depois:
    openlava_encode.py <bundle> --fps 15 --webp 85 --density 3 <out_dir>/frame_*.png"""
    from openlava_encode import decode_frames
    frames, _ = decode_frames(bundle_dir)
    os.makedirs(out_dir, exist_ok=True)
    for i, f in enumerate(frames[::2]):
        Image.fromarray(f).resize((270, 243), Image.LANCZOS).save(os.path.join(out_dir, f"frame_{i:03d}.png"))
    print(f"{bundle_dir}: {len(frames)} -> {len(frames) // 2} frames em {out_dir}")


def main():
    if sys.argv[1] == "repack":
        return repack(sys.argv[2], sys.argv[3])
    kind, src, out_dir = sys.argv[1], sys.argv[2], sys.argv[3]
    n = int(sys.argv[4]) if len(sys.argv) > 4 else None
    img = Image.open(src)
    if img.mode == "RGBA" and np.array(img)[..., 3].min() < 250:
        cut = np.array(img)
    else:
        cut = np.clip(key_backdrop(img, **KEY.get(kind, {})), 0, 255).astype(np.uint8)
    if kind == "camera_scan":
        cut = despill_cream(cut)
    if kind == "wifi_table":
        cut = despill_cream(despill_magenta(cut, 2.0))
    cut = ai.crop_to_alpha(cut)
    if kind == "trophy":
        cut = Trophy.pad_cut(cut)
    os.makedirs(out_dir, exist_ok=True)
    Image.fromarray(cut).save(os.path.join(os.path.dirname(out_dir.rstrip("/")) or ".", f"{kind}_cutout.png"))
    paths = ai.render(kind, cut, out_dir, n)
    print(f"{kind}: {len(paths)} frames -> {out_dir}")


if __name__ == "__main__":
    main()
