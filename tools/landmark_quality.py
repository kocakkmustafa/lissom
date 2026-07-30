#!/usr/bin/env python3
"""Landmark KALİTESİ ölçer — triyaj eşiklerinin dayanağını sınamak için.

Neden var (L-171): `lr3_bA48EBM` netlik 37,8 ile reddedildi, eşik 40. Sınır
vakası bir "böksek mi" sorusu değil, eşiğin TEMELİNİ türetme tetiğidir
(koordinatör hükmü M-F-173). Bir eşik neyi koruyorsa, ONUNLA ilişkisi
ölçülebilir olmalı — netlik eşiği "kullanılabilir landmark"ı korur, o hâlde
sorulacak soru: netlik landmark kalitesini öngörüyor mu?

Ölçtüğü dört büyüklük — hepsi landmark'tan, hiçbiri metadata'dan:
  * tespit oranı        — kaç karede iskelet bulundu
  * görünürlük ort/p10  — 12 gövde landmark'ının güveni (p10 = kötü kuyruk)
  * kadraj-içi oran     — tüm gövde landmark'ları [0,1] içinde mi
  * jitter/saniye       — kare-arası kayma, SANİYE-normalize (M-O-23: kare
                          cinsinden jitter fps ile ölçeklenir, kıyas bozulur)

⚠️ Kullanım disiplini: reddedilmiş bir klip ölçülecekse KARANTİNADA
çıkarılır (kütüphane/kuyruk DIŞINDA). Ölçmek kapıyı gevşetmek değildir;
karıştırmak gevşetmektir.
"""

from __future__ import annotations

import argparse
import json
import statistics as st
from pathlib import Path

import numpy as np

#: Gövde landmark'ları — yüz/parmak hariç (gürültülü ve hareketi tarif etmiyor).
BODY = [11, 12, 13, 14, 15, 16, 23, 24, 25, 26, 27, 28]


def quality(path: str | Path) -> dict | None:
    doc = json.loads(Path(path).read_text(encoding="utf-8"))
    frames = doc["frames"]
    det = [f for f in frames if f.get("detected")]
    if not det:
        return None
    vis: list[float] = []
    jit: list[float] = []
    in_frame = 0
    prev = None
    for f in det:
        lm = f["lm"]
        vis.append(sum(lm[i][3] for i in BODY) / len(BODY))
        if all(0.0 <= lm[i][0] <= 1.0 and 0.0 <= lm[i][1] <= 1.0 for i in BODY):
            in_frame += 1
        cur = np.array([[lm[i][0], lm[i][1]] for i in BODY])
        if prev is not None:
            jit.append(float(np.abs(cur - prev).mean()))
        prev = cur
    fps = float(doc.get("recordingMeta", {}).get("fps") or 30)
    svis = sorted(vis)
    return {
        "frames": len(frames),
        "detected": len(det),
        "detRate": round(len(det) / len(frames), 3),
        "visMean": round(st.mean(vis), 3),
        "visP10": round(svis[int(0.10 * len(svis))], 3),
        "inFrameRate": round(in_frame / len(det), 3),
        # SANİYE-normalize: kare cinsinden jitter fps'le ölçeklenir ve
        # 24fps ile 60fps kaynak kıyaslanamaz hâle gelir.
        "jitterPerSec": round(st.median(jit) * fps, 4) if jit else None,
        "fps": round(fps, 2),
    }


def pearson(a: list[float], b: list[float]) -> float:
    n = len(a)
    if n < 3:
        return float("nan")
    ma, mb = st.mean(a), st.mean(b)
    sa = (sum((x - ma) ** 2 for x in a) / n) ** 0.5
    sb = (sum((x - mb) ** 2 for x in b) / n) ** 0.5
    if sa < 1e-9 or sb < 1e-9:
        return float("nan")
    return sum((x - ma) * (y - mb) for x, y in zip(a, b)) / (n * sa * sb)


def main() -> int:
    ap = argparse.ArgumentParser()
    ap.add_argument("fixtures", nargs="+", help="landmark JSON yolları")
    ap.add_argument("--vs-sharpness", action="store_true",
                    help="kütüphanedeki tüm kaynaklar için netlik↔kalite ilişkisi")
    args = ap.parse_args()

    for p in args.fixtures:
        q = quality(p)
        print(json.dumps({"fixture": Path(p).name, **(q or {"error": "tespit yok"})},
                         ensure_ascii=False))

    if args.vs_sharpness:
        lib = Path.home() / "motion-harvest/lissom"
        rows = []
        for m in sorted((lib / "manifests").glob("*.json")):
            d = json.loads(m.read_text(encoding="utf-8"))
            vid = d.get("video_id") or m.stem
            sharp = None
            for s in d.get("stages", []):
                if s["stage"] == "triage":
                    sharp = s.get("detail", {}).get("sharpness")
            lm = lib / "landmarks" / f"{vid}.full.json"
            if sharp is None or not lm.exists():
                continue
            q = quality(lm)
            if q and q["jitterPerSec"] is not None:
                rows.append((sharp, q))
        if len(rows) < 3:
            print(json.dumps({"note": "ilişki için yetersiz örnek",
                              "n": len(rows)}, ensure_ascii=False))
            return 0
        sh = [r[0] for r in rows]
        out = {
            "n": len(rows),
            "sharpnessRange": [round(min(sh), 1), round(max(sh), 1)],
            "r_sharpness_detRate": round(pearson(sh, [r[1]["detRate"] for r in rows]), 3),
            "r_sharpness_visMean": round(pearson(sh, [r[1]["visMean"] for r in rows]), 3),
            "r_sharpness_jitter": round(pearson(sh, [r[1]["jitterPerSec"] for r in rows]), 3),
            "note": "jitter için NEGATİF r beklenir (net video = az kayma). "
                    "Pozitif çıkarsa eşiğin öncülü ölçümle desteklenmiyor.",
            "limit": "ARALIK KISITLAMASI: yalnız kabul edilmiş (eşiği geçmiş) "
                     "kaynaklar ölçülebilir; eşik altı için kanıt YOK.",
        }
        print(json.dumps(out, ensure_ascii=False, indent=1))
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
