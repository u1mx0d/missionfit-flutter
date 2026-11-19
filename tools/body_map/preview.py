"""Maket karelerinin önizlemesi (Pillow + numpy).

  python3 tools/body_map/preview.py --assets assets/body_map --frames 0,18,36 \
      --mode overlay|mono|glow --out OUT.png

overlay: her bölgeyi ayrı renkle gösterir (sınır ayarı için).
mono:    Nothing tarzı nokta-matris (kırmızı #d71921, siyah zemin, ekran ızgarası).
glow:    Canlı tarzı parlayan heykel (yeşil #1ed760, #121212 zemin).
Örnek yoğunluk (0–3) --levels ile verilir; varsayılan görevdeki örnek haftadır.
"""

import argparse
import json
import os

import numpy as np
from PIL import Image, ImageDraw, ImageFilter

REGIONS = [
    "chest", "shoulders", "biceps", "triceps", "forearms", "abs", "obliques",
    "traps", "lats", "lower_back", "glutes", "quads", "hamstrings", "calves",
]
SAMPLE = {"chest": 3, "lats": 3, "quads": 3, "hamstrings": 3, "shoulders": 2,
          "traps": 1, "abs": 1}
PALETTE = [
    (230, 25, 75), (60, 180, 75), (255, 225, 25), (0, 130, 200), (245, 130, 48),
    (145, 30, 180), (70, 240, 240), (240, 50, 230), (210, 245, 60), (250, 190, 212),
    (0, 128, 128), (220, 190, 255), (170, 110, 40), (128, 0, 0),
]


def load(assets, f):
    shade = np.asarray(Image.open(os.path.join(assets, f"shade_{f:03d}.webp")).convert("RGBA"),
                       np.float32) / 255.0
    ids = np.asarray(Image.open(os.path.join(assets, f"id_{f:03d}.png")).convert("RGB"))[..., 0]
    return shade, (ids.astype(np.int32) // 17)


def overlay(shade, ids):
    lum = shade[..., 0]
    rgb = np.stack([lum] * 3, -1) * 255
    for i in range(14):
        m = ids == i + 1
        rgb[m] = rgb[m] * 0.45 + np.array(PALETTE[i]) * 0.55
    a = shade[..., 3:4]
    bg = np.array([32, 32, 32])
    return (rgb * a + bg * (1 - a)).clip(0, 255).astype(np.uint8)


def level_map(ids, levels):
    lv = np.zeros(16, np.float32)
    for k, v in levels.items():
        lv[REGIONS.index(k) + 1] = v
    return lv[ids]


def mono(shade, ids, levels, scale=3, pitch=8):
    """Ekran ızgarası: her hücrede bir nokta (adım = pitch/scale kaynak piksel).
    Nokta boyutu ve parlaklığı ışıklı görüntünün parlaklığı × bölge seviyesinden,
    rengi bölgeden gelir; böylece kas kabartması noktalarda da okunur."""
    h, w = ids.shape
    lum = shade[..., 0]
    alpha = shade[..., 3]
    lv = level_map(ids, levels)
    img = Image.new("RGB", (w * scale, h * scale), (0, 0, 0))
    dr = ImageDraw.Draw(img)
    red = np.array([215, 25, 33], np.float32)
    step = pitch / scale
    for y in np.arange(step / 2, h, step):
        for x in np.arange(step / 2, w, step):
            iy, ix = int(y), int(x)
            if alpha[iy, ix] < 0.5:
                continue
            l = float(lum[iy, ix]) ** 1.3
            k = float(lv[iy, ix]) / 3.0
            if k > 0:
                r = pitch * (0.10 + 0.34 * l * (0.55 + 0.45 * k))
                c = red * (0.35 + 0.75 * l) * (0.7 + 0.3 * k)
            else:
                r = pitch * (0.06 + 0.26 * l)
                g = 30 + 200 * l
                c = np.array([g, g, g])
            cx, cy = x * scale, y * scale
            dr.ellipse([cx - r, cy - r, cx + r, cy + r], fill=tuple(int(min(255, v)) for v in c))
    return np.asarray(img)


def glow(shade, ids, levels):
    """Vurgu rengi ışıklı görüntünün parlaklığıyla çarpılır (kabartma korunur),
    üstüne seviyeyle artan yumuşak bir ışıma eklenir."""
    lum = shade[..., 0][..., None]
    a = shade[..., 3][..., None]
    t = (level_map(ids, levels) / 3.0)[..., None]
    bg = np.array([18, 18, 18], np.float32)
    green = np.array([30, 215, 96], np.float32)
    stone = np.array([205, 208, 206], np.float32) * lum * 0.8
    lit = green * (0.12 + 1.05 * lum ** 1.6) * (0.8 + 0.25 * t)
    col = stone * (1 - np.minimum(1.0, t * 1.6)) + lit * np.minimum(1.0, t * 1.6)
    col = col * a + bg * (1 - a)
    em = (t[..., 0] * shade[..., 0] * shade[..., 3])
    halo = np.asarray(Image.fromarray((em * 255).astype(np.uint8))
                      .filter(ImageFilter.GaussianBlur(7)), np.float32)[..., None] / 255.0
    col = col + green * halo * 0.3
    return col.clip(0, 255).astype(np.uint8)


def main():
    p = argparse.ArgumentParser()
    p.add_argument("--assets", required=True)
    p.add_argument("--frames", default="0,18,36")
    p.add_argument("--mode", default="overlay")
    p.add_argument("--levels", default="")
    p.add_argument("--out", required=True)
    a = p.parse_args()
    levels = json.loads(a.levels) if a.levels else SAMPLE
    tiles = []
    for f in [int(x) for x in a.frames.split(",")]:
        shade, ids = load(a.assets, f)
        if a.mode == "overlay":
            t = overlay(shade, ids)
        elif a.mode == "mono":
            t = mono(shade, ids, levels)
        else:
            t = glow(shade, ids, levels)
        tiles.append(t)
    out = np.concatenate(tiles, 1)
    Image.fromarray(out).save(a.out)


if __name__ == "__main__":
    main()
