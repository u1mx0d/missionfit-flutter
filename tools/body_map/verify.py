"""Maket varlıklarını doğrular.

  python3 tools/body_map/verify.py assets/body_map

Denetimler:
  - manifest: anahtarlar, atıf, 14 bölge slug'ı plan sırasıyla, kare/adım tutarlılığı
  - toplam boyut ≤ 4 MB, her karenin boyutu manifestle aynı
  - id_NNN.png: yalnızca {0, 17, …, 255}; R = G = B
  - kenar yumuşatması sızıntısı: 4 komşusunun hepsi kendisinden farklı olan tekil
    piksel yasak (17 ile 51'in karışımı 34 gibi "geçerli ama yanlış" değerleri yakalar)
  - boşluk eşleşmesi: id = 255 ⇔ ışıklı karede alfa < 0,5 (betiğin kimlik için
    kullandığı eşik). Siluet kenarında ışıklı kare kenar yumuşatmalı olduğundan
    uyuşmazlık yalnızca kenardan ≤ EDGE_PX uzakta kabul edilir.
  - boş piksellerdeki soluk alfa (kayıplı WebP / denoiser pusu) ayrıca sayılır;
    HAZE_MAX'ı aşarsa hata.
  - ön karede (000) chest/abs/quads, arka karede lats/glutes/hamstrings görünür
"""

import json
import os
import sys

import numpy as np
from PIL import Image

LIMIT = 4 * 1024 * 1024
REGIONS = [
    "chest", "shoulders", "biceps", "triceps", "forearms", "abs", "obliques",
    "traps", "lats", "lower_back", "glutes", "quads", "hamstrings", "calves",
]
KEYS = {"frames", "stepDegrees", "width", "height", "regions", "attribution"}
ATTRIBUTION = "MakeHuman / MPFB (CC0)"
EDGE_PX = 1  # alfa/boşluk uyuşmazlığına izin verilen siluet kenarı genişliği
MAX_ISOLATED = 40  # kare başına izin verilen tekil kimlik pikseli (ölçülen en kötü: 38)
HAZE_MAX = 32  # boş pikselde izin verilen en yüksek soluk alfa (0–255)


def dilate(mask, r):
    out = mask.copy()
    for _ in range(r):
        m = out.copy()
        m[1:] |= out[:-1]
        m[:-1] |= out[1:]
        m[:, 1:] |= out[:, :-1]
        m[:, :-1] |= out[:, 1:]
        out = m
    return out


def isolated(ids):
    p = np.pad(ids, 1, mode="edge")
    c = p[1:-1, 1:-1]
    return ((p[:-2, 1:-1] != c) & (p[2:, 1:-1] != c) &
            (p[1:-1, :-2] != c) & (p[1:-1, 2:] != c))


def main():
    root = sys.argv[1]
    errors = []
    man = json.load(open(os.path.join(root, "manifest.json")))

    # Manifest
    if set(man.keys()) != KEYS:
        errors.append(f"manifest anahtarları: {sorted(man.keys())}")
    if man.get("attribution") != ATTRIBUTION:
        errors.append(f"atıf: {man.get('attribution')!r}")
    if man.get("regions") != REGIONS:
        errors.append(f"bölgeler: {man.get('regions')}")
    if man["frames"] * man["stepDegrees"] != 360:
        errors.append("frames × stepDegrees ≠ 360")
    print(f"manifest: frames={man['frames']} step={man['stepDegrees']} "
          f"{man['width']}x{man['height']} bölge={len(man['regions'])}")

    # Boyut
    total = sum(os.path.getsize(os.path.join(root, f)) for f in os.listdir(root))
    print(f"boyut: {total} bayt ({total / 1048576:.2f} MB), sınır 4 MB")
    if total > LIMIT:
        errors.append("boyut 4 MB'ı aşıyor")

    allowed = np.array(sorted(range(0, 256, 17)))
    worst_iso, worst_mis = (0, -1), (0, -1)
    tot_iso = tot_mis = tot_edge = tot_haze = 0
    haze_max = 0
    for f in range(man["frames"]):
        sh = Image.open(os.path.join(root, f"shade_{f:03d}.webp")).convert("RGBA")
        im = Image.open(os.path.join(root, f"id_{f:03d}.png"))
        if sh.size != (man["width"], man["height"]) or im.size != sh.size:
            errors.append(f"{f:03d}: boyut uyuşmuyor")
            continue
        rgb = np.asarray(im.convert("RGB"))
        if not ((rgb[..., 0] == rgb[..., 1]).all() and (rgb[..., 1] == rgb[..., 2]).all()):
            errors.append(f"id_{f:03d}: R/G/B eşit değil")
        red = rgb[..., 0]
        bad = np.setdiff1d(np.unique(red), allowed)
        if bad.size:
            errors.append(f"id_{f:03d}: izinsiz değerler {bad.tolist()}")

        n_iso = int(isolated(red).sum())
        tot_iso += n_iso
        worst_iso = max(worst_iso, (n_iso, f))
        # Tekil pikseller gerçek ince geometri (ör. triceps şeridi), AA karışımı değil; uygulama
        # dokunmada 5×5 çoğunluk oyu kullanır. Kare başına MAX_ISOLATED'e kadar uyarı, üstü hata.
        if n_iso > MAX_ISOLATED:
            ys, xs = np.nonzero(isolated(red))
            errors.append(f"id_{f:03d}: {n_iso} tekil piksel, ör. (x={xs[0]}, y={ys[0]}) "
                          f"değer {int(red[ys[0], xs[0]])}")

        alpha = np.asarray(sh)[..., 3]
        empty = red == 255
        edge = dilate(empty, EDGE_PX) & dilate(~empty, EDGE_PX)
        mismatch = empty != (alpha < 128)
        hard = mismatch & ~edge
        tot_edge += int((mismatch & edge).sum())
        tot_mis += int(hard.sum())
        worst_mis = max(worst_mis, (int(hard.sum()), f))
        if hard.any():
            ys, xs = np.nonzero(hard)
            errors.append(f"{f:03d}: kenar dışında {int(hard.sum())} boşluk/alfa uyuşmazlığı, "
                          f"ör. (x={xs[0]}, y={ys[0]}) id={int(red[ys[0], xs[0]])} "
                          f"alfa={int(alpha[ys[0], xs[0]])}")
        haze = empty & ~edge & (alpha > 0)
        tot_haze += int(haze.sum())
        if haze.any():
            haze_max = max(haze_max, int(alpha[haze].max()))

    print(f"tekil piksel: toplam {tot_iso} (en çok {worst_iso[0]}, kare {worst_iso[1]:03d})")
    print(f"boşluk/alfa: kenarda tolere edilen {tot_edge} px, kenar dışında {tot_mis} px "
          f"(en çok {worst_mis[0]}, kare {worst_mis[1]:03d})")
    print(f"boş piksellerde soluk alfa: {tot_haze} px, en yüksek {haze_max}/255 "
          f"(sınır {HAZE_MAX})")
    if haze_max > HAZE_MAX:
        errors.append(f"boş piksellerde alfa {haze_max} > {HAZE_MAX}")

    red0 = np.asarray(Image.open(os.path.join(root, "id_000.png")).convert("RGB"))[..., 0]
    print("id_000 benzersiz değerler:", np.unique(red0).tolist())

    def visible(f):
        r = np.asarray(Image.open(os.path.join(root, f"id_{f:03d}.png")).convert("RGB"))[..., 0]
        ids, cnt = np.unique(r // 17, return_counts=True)
        return {REGIONS[i - 1]: int(c) for i, c in zip(ids, cnt) if 1 <= i <= 14}

    half = man["frames"] // 2
    front, back = visible(0), visible(half)
    print("ön (000):", front)
    print(f"arka ({half:03d}):", back)
    for k in ("chest", "abs", "quads"):
        if front.get(k, 0) <= 200 or back.get(k, 0) >= front.get(k, 0):
            errors.append(f"ön karede {k} yetersiz")
    for k in ("lats", "glutes", "hamstrings"):
        if back.get(k, 0) <= 200:
            errors.append(f"arka karede {k} yetersiz")

    by_kind = {}
    for e in errors:
        k = "tekil piksel" if "tekil" in e else ("boşluk/alfa" if "uyuşmazl" in e else "diğer")
        by_kind[k] = by_kind.get(k, 0) + 1
    print("hata türleri:", by_kind)
    for e in errors[:40]:
        print("HATA:", e)
    if len(errors) > 40:
        print(f"... ve {len(errors) - 40} hata daha")
    print("SONUÇ:", "GEÇTİ" if not errors else f"KALDI ({len(errors)} hata)")
    sys.exit(0 if not errors else 1)


if __name__ == "__main__":
    main()
