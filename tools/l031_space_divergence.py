#!/usr/bin/env python3
"""L-031 ölçümü: Dart canlı yol ↔ normatif Python yorumlayıcısı.

L-031 defterde "uzay farkı sistematik sapma ÜRETEBİLİR" diye kayıtlıydı —
bir olasılık olarak. Bu araç onu SAYIYA çevirir: aynı fixture'ın aynı
karelerinde iki hattı yan yana koşturur ve eşleştirilmiş farkı raporlar.

Üç hesap kıyaslanır:
  HAM  Dart, ham anizotropik `lm`            (J-028 düzeltmesi ÖNCESİ davranış)
  İZO  Dart, `toIsotropic` sonrası           (şimdiki kod)
  REF  Python, `world` 3D + config frameRef  (NORMATİF — çekirdek doktrini:
       "when the two disagree, this package is right by definition")

Karşılaştırmanın Python tarafında olması kasıtlı: hakemi taraflardan biri
yapmamak için.

Kullanım (iki adım):
  cd packages/lissom_engine && dart run tool/dump_angles.dart /tmp/dart.json
  python3 tools/l031_space_divergence.py /tmp/dart.json
"""
from __future__ import annotations

import json
import sys
from pathlib import Path

import numpy as np

REPO = Path(__file__).resolve().parent.parent
PIPE = (REPO / "../../motion-core/lib/tools/fixture_pipeline").resolve()
HARVEST = Path.home() / "motion-harvest/lissom/landmarks"

if not PIPE.exists():  # pragma: no cover
    sys.exit(f"normatif yorumlayıcı bulunamadı: {PIPE}")
sys.path.insert(0, str(PIPE))

from mocore import geometry as geo  # noqa: E402
from mocore import measures as ms  # noqa: E402


def load_defs() -> dict[str, ms.MetricDef]:
    raw = json.loads((REPO / "config/metrics/lissom-metrics.v1.json").read_text())
    out: dict[str, ms.MetricDef] = {}
    for m in raw["metrics"]:
        d = ms.MetricDef.from_dict(m)
        out[d.id] = d
        if m.get("mirror"):
            mid = (m["id"].replace("_right", "_left")
                   if "_right" in m["id"] else m["id"].replace("_left", "_right"))
            out[mid] = d.mirrored(mid)
    return out


def stat(d: np.ndarray) -> dict | None:
    d = np.asarray(d, dtype=float)
    d = d[np.isfinite(d)]
    if d.size == 0:
        return None
    a = np.abs(d)
    return dict(n=int(d.size), med=float(np.median(a)),
                p95=float(np.percentile(a, 95)), mx=float(a.max()),
                bias=float(np.median(d)))


def fmt(s: dict | None) -> str:
    if s is None:
        return "ölçülemedi (n=0)"
    return (f"med={s['med']:6.2f}° p95={s['p95']:6.2f}° "
            f"max={s['mx']:7.2f}° bias={s['bias']:+6.2f}° n={s['n']}")


def main(argv: list[str]) -> int:
    if len(argv) != 2:
        sys.exit(__doc__)
    dart = json.loads(Path(argv[1]).read_text())
    defs = load_defs()
    rows: list[tuple] = []

    for fid, block in dart.items():
        path = HARVEST / f"{fid}.full.json"
        if not path.exists():
            print(f"ATLANDI (fixture yok): {fid}")
            continue
        recs = [r for r in json.loads(path.read_text())["frames"]
                if r.get("detected")]
        # Eşleştirme geçersizse SESSİZCE kıyaslamak en kötüsü olur.
        n_dart = len(next(iter(block["raw"].values())))
        if len(recs) != n_dart:
            print(f"⚠️ {fid}: kare sayısı uyuşmuyor "
                  f"(Dart {n_dart} / Python {len(recs)}) — ATLANDI")
            continue
        frames = [
            geo.Frame(
                xyz=np.array(r["world"], dtype=float),
                visibility=np.array(r["lm"], dtype=float)[:, 3],
                presence=np.array(r["lm"], dtype=float)[:, 4],
                t_ms=float(r["t"]),
            )
            for r in recs
        ]
        print(f"\n=== {fid}  {block['resolution']} "
              f"(aspect {block['aspect']:.3f})  {len(recs)} kare ===")
        for metric in block["raw"]:
            md = defs.get(metric)
            if md is None:
                print(f"  {metric}: config'te TANIMSIZ — atlandı")
                continue
            # ⚠️ `valid` OTORİTE, `isfinite` DEĞİL (L-197, ölçülmüş kusur):
            # rig'in `mask_invalid` varsayılanından ÖNCE geçersiz ölçümler
            # `value` alanında HAM/ÇÖP sayı taşıyordu, yalnız `valid=False`
            # yan-kanal bayrağıyla işaretli. Bu döngü bayrağı okumuyordu, yani
            # REF serisi geçersiz ölçümlerle KİRLENİYORDU ve L-187'nin sapma
            # sayıları o kirlilikle raporlanmıştı. Geçersizi NaN'a çevirmek
            # aşağı akıştaki `isfinite` süzgeciyle onu dürüstçe DIŞLAR.
            ref = np.array(
                [(m.value if m.valid else np.nan)
                 for m in (ms.evaluate(md, fr, anatomical=True)
                           for fr in frames)],
                dtype=float)
            raw = np.array([np.nan if v is None else v
                            for v in block["raw"][metric]], dtype=float)
            iso = np.array([np.nan if v is None else v
                            for v in block["iso"][metric]], dtype=float)
            s_raw, s_iso, s_gain = stat(raw - ref), stat(iso - ref), stat(iso - raw)
            print(f"  {metric}")
            print(f"    HAM↔REF   {fmt(s_raw)}")
            print(f"    İZO↔REF   {fmt(s_iso)}")
            print(f"    İZO−HAM   {fmt(s_gain)}  <- J-028 düzeltmesinin etkisi")
            if s_raw and s_iso:
                rows.append((fid, metric, s_raw["med"], s_iso["med"],
                             s_raw["p95"], s_iso["p95"]))

    if not rows:
        print("\nHİÇ kıyas yapılamadı — rapor üretilmedi.")
        return 1

    print("\n\n=== ÖZET (medyan ve p95 |sapma|, HAM → İZO) ===")
    print(f"{'fixture':14s} {'metrik':26s} {'medHAM':>7s} {'medİZO':>7s} "
          f"{'p95HAM':>7s} {'p95İZO':>7s}")
    for fid, m, mr, mi, pr, pi in rows:
        print(f"{fid:14s} {m:26s} {mr:7.2f} {mi:7.2f} {pr:7.2f} {pi:7.2f}")
    mr, mi = np.mean([r[2] for r in rows]), np.mean([r[3] for r in rows])
    pr, pi = np.mean([r[4] for r in rows]), np.mean([r[5] for r in rows])
    print(f"\n{'ORTALAMA':14s} {'':26s} {mr:7.2f} {mi:7.2f} {pr:7.2f} {pi:7.2f}")
    print(f"\nmedyan: {mr:.2f}° → {mi:.2f}°  ({(mi - mr) / mr * 100:+.1f}%)")
    print(f"p95   : {pr:.2f}° → {pi:.2f}°  ({(pi - pr) / pr * 100:+.1f}%)")
    print(f"\nKALAN sapma (İZO↔REF) L-031'in gerçek kapsamıdır: "
          f"medyan {mi:.2f}°, p95 {pi:.2f}°.")
    return 0


if __name__ == "__main__":
    raise SystemExit(main(sys.argv))
