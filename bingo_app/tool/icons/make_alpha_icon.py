#!/usr/bin/env python3
"""Gera a arte do ícone do flavor alpha: o ícone atual com uma faixa "BETA".

Fonte: `assets/icon/adaptive_foreground.png` (a mesma do ícone de prod; o
fundo amarelo vem de `adaptive_icon_background`). Saídas em
`assets/icon/alpha/`:

- `adaptive_foreground.png`: foreground adaptativo com a faixa diagonal no
  canto inferior direito da bola, recortada ao disco da zona segura (66 dp
  centrais de 108 dp) para nenhuma máscara de launcher cortá-la.
- `launcher.png`: ícone legado (API 24/25, sem adaptive icon): fundo amarelo
  com o mesmo foreground reduzido na proporção do ícone de prod.

Uso (dentro de bingo_app/):

    python3 tool/icons/make_alpha_icon.py
    dart run flutter_launcher_icons -f flutter_launcher_icons-alpha.yaml

Requer Pillow: `python3 -m pip install --user pillow`.
"""

from __future__ import annotations

import argparse
import math
import pathlib
import sys

from PIL import Image, ImageDraw, ImageFont

APP_DIR = pathlib.Path(__file__).resolve().parents[2]
FOREGROUND_SRC = APP_DIR / "assets" / "icon" / "adaptive_foreground.png"
OUT_DIR = APP_DIR / "assets" / "icon" / "alpha"

SIZE = 1024
SCALE = 4  # supersampling: desenha em 4096 e reduz, para bordas lisas
BACKGROUND = (0xF6, 0xC7, 0x05, 255)  # #F6C705, igual ao colors.xml
RIBBON = (0xE5, 0x39, 0x35, 255)  # vermelho: contrasta com o azul e o amarelo
OUTLINE = (0x12, 0x12, 0x12, 255)  # contorno preto do design system
TEXT = (255, 255, 255, 255)

# Zona segura do ícone adaptativo em pixels da imagem de 1024: a imagem entra
# com inset de 16% (ocupa 68% dos 108 dp), e o disco seguro tem 33 dp de raio
# -> 33 / (108 * 0,68) * 1024 ≈ 460 px. 440 deixa folga.
SAFE_RADIUS = 440
# Faixa: distância do centro até o meio da faixa, largura e comprimento.
RIBBON_DISTANCE = 300
RIBBON_WIDTH = 150
RIBBON_LENGTH = 1100  # maior que o disco: o recorte circular define as pontas
RIBBON_BORDER = 8
LABEL = "BETA"
# Proporção da bola no ícone legado de prod (101/192) em relação ao
# foreground adaptativo (598/1024): ~0,9.
LEGACY_FOREGROUND_SCALE = 0.9

FONT_CANDIDATES = [
    "/System/Library/Fonts/Supplemental/Arial Bold.ttf",
    "/System/Library/Fonts/Supplemental/Arial Black.ttf",
    "/System/Library/Fonts/HelveticaNeue.ttc",
    "/Library/Fonts/Arial Bold.ttf",
    "/usr/share/fonts/truetype/dejavu/DejaVuSans-Bold.ttf",
    "/usr/share/fonts/truetype/liberation/LiberationSans-Bold.ttf",
]


def load_font(size: int, explicit: str | None) -> ImageFont.FreeTypeFont:
    candidates = ([explicit] if explicit else []) + FONT_CANDIDATES
    for path in candidates:
        if path and pathlib.Path(path).exists():
            try:
                return ImageFont.truetype(path, size)
            except OSError:
                continue
    sys.exit(
        "Nenhuma fonte TrueType encontrada; passe --font /caminho/fonte.ttf"
    )


def ribbon_layer(font_path: str | None) -> Image.Image:
    """Faixa diagonal (sobe para a direita) no canto inferior direito, já
    recortada ao disco da zona segura. Camada RGBA de SIZE x SIZE."""
    big = SIZE * SCALE
    center = big / 2
    layer = Image.new("RGBA", (big, big), (0, 0, 0, 0))
    draw = ImageDraw.Draw(layer)

    # Faixa horizontal abaixo do centro; a rotação de 45° (anti-horária, no
    # PIL) a leva para o canto inferior direito, subindo para a direita.
    half_len = RIBBON_LENGTH * SCALE / 2
    top = center + (RIBBON_DISTANCE - RIBBON_WIDTH / 2) * SCALE
    bottom = center + (RIBBON_DISTANCE + RIBBON_WIDTH / 2) * SCALE
    draw.rectangle(
        [center - half_len, top, center + half_len, bottom], fill=OUTLINE
    )
    border = RIBBON_BORDER * SCALE
    draw.rectangle(
        [center - half_len, top + border, center + half_len, bottom - border],
        fill=RIBBON,
    )

    font = load_font(int(RIBBON_WIDTH * 0.62 * SCALE), font_path)
    stroke = max(2, int(2.5 * SCALE))
    draw.text(
        (center, (top + bottom) / 2),
        LABEL,
        font=font,
        fill=TEXT,
        anchor="mm",
        stroke_width=stroke,
        stroke_fill=OUTLINE,
    )

    layer = layer.rotate(45, resample=Image.BICUBIC, center=(center, center))

    # Recorte ao disco seguro.
    mask = Image.new("L", (big, big), 0)
    r = SAFE_RADIUS * SCALE
    ImageDraw.Draw(mask).ellipse(
        [center - r, center - r, center + r, center + r], fill=255
    )
    clipped = Image.new("RGBA", (big, big), (0, 0, 0, 0))
    clipped.paste(layer, (0, 0), mask)
    return clipped.resize((SIZE, SIZE), Image.LANCZOS)


def build(font_path: str | None) -> None:
    if not FOREGROUND_SRC.exists():
        sys.exit(f"Fonte do ícone não encontrada: {FOREGROUND_SRC}")
    OUT_DIR.mkdir(parents=True, exist_ok=True)

    foreground = Image.open(FOREGROUND_SRC).convert("RGBA")
    if foreground.size != (SIZE, SIZE):
        foreground = foreground.resize((SIZE, SIZE), Image.LANCZOS)

    ribbon = ribbon_layer(font_path)
    alpha_foreground = Image.alpha_composite(foreground, ribbon)
    alpha_foreground.save(OUT_DIR / "adaptive_foreground.png", optimize=True)

    # Legado: fundo amarelo cheio + foreground (com faixa) reduzido.
    legacy = Image.new("RGBA", (SIZE, SIZE), BACKGROUND)
    small = int(SIZE * LEGACY_FOREGROUND_SCALE)
    scaled = alpha_foreground.resize((small, small), Image.LANCZOS)
    offset = (SIZE - small) // 2
    legacy.alpha_composite(scaled, (offset, offset))
    legacy.convert("RGB").save(OUT_DIR / "launcher.png", optimize=True)

    # Confere que a faixa ficou dentro do disco seguro (pixel opaco mais
    # distante do centro).
    alpha = ribbon.getchannel("A").load()
    farthest = max(
        (
            math.hypot(x - SIZE / 2, y - SIZE / 2)
            for y in range(0, SIZE, 2)
            for x in range(0, SIZE, 2)
            if alpha[x, y] > 0
        ),
        default=0.0,
    )
    print(f"faixa: pixel mais distante do centro = {farthest:.0f}px")
    if farthest > SAFE_RADIUS + 4:
        sys.exit("A faixa saiu da zona segura do ícone adaptativo.")
    print(f"gerado: {OUT_DIR / 'adaptive_foreground.png'}")
    print(f"gerado: {OUT_DIR / 'launcher.png'}")


def main() -> None:
    parser = argparse.ArgumentParser(description=__doc__.splitlines()[0])
    parser.add_argument("--font", help="TTF em negrito para o texto BETA")
    args = parser.parse_args()
    build(args.font)


if __name__ == "__main__":
    main()
