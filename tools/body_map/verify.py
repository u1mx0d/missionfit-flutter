"""Maket varlıklarını doğrular: boyut, kimlik değerleri, ön/arka bölgeler.

  python3 tools/body_map/verify.py assets/body_map
"""

import json
import os
import sys

import numpy as np
from PIL import Image

LIMIT = 4 * 1024 * 1024


def main():
    root = sys.argv[1]
    man = json.load(open(os.path.join(root, "manifest.json")))
    regions = man["regions"]
    ok = True
    total = sum(os.path.getsize(os.path.join(root, f)) for f in os.listdir(root))
    print(f"boyut: {total} bayt ({total / 1048576:.2f} MB) sınır 4 MB -> {'OK' if total <= LIMIT else 'AŞTI'}")
    ok &= total <= LIMIT
    allowed = set(range(0, 256, 17))
    for f in range(man["frames"]):
        sh = Image.open(os.path.join(root, f"shade_{f:03d}.webp"))
        im = Image.open(os.path.join(root, f"id_{f:03d}.png"))
        if sh.size != (man["width"], man["height"]) or im.size != sh.size:
            print("boyut uyuşmuyor:", f)
            ok = False
        red = np.asarray(im.convert("RGB"))[..., 0]
        bad = set(np.unique(red).tolist()) - allowed
        if bad:
            print(f"id_{f:03d}: izinsiz değerler {sorted(bad)}")
            ok = False
    red0 = np.asarray(Image.open(os.path.join(root, "id_000.png")).convert("RGB"))[..., 0]
    print("id_000 benzersiz kırmızı:", sorted(np.unique(red0).tolist()))

    def visible(f):
        r = np.asarray(Image.open(os.path.join(root, f"id_{f:03d}.png")).convert("RGB"))[..., 0]
        ids, cnt = np.unique(r // 17, return_counts=True)
        return {regions[i - 1]: int(c) for i, c in zip(ids, cnt) if 1 <= i <= 14}

    half = man["frames"] // 2
    front, back = visible(0), visible(half)
    print("ön (000):", front)
    print(f"arka ({half:03d}):", back)
    for k in ("chest", "abs", "quads"):
        ok &= front.get(k, 0) > 200
    for k in ("lats", "glutes", "hamstrings"):
        ok &= back.get(k, 0) > 200
    for k in ("chest", "abs", "quads"):
        ok &= back.get(k, 0) < front.get(k, 0)
    print("SONUÇ:", "GEÇTİ" if ok else "KALDI")
    sys.exit(0 if ok else 1)


if __name__ == "__main__":
    main()
