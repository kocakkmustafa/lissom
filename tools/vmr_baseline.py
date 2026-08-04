#!/usr/bin/env python3
"""§3.2b TABAN ölçümü — triyajın REDDETTİĞİ kliplerde VMR.

Protokol §3.2b: *"Taban (floor): triyajın REDDETTİĞİ kliplerde VMR.
Reddedilenler de %88 veriyorsa, B1'in %90'ı 'iyi koşul çalışıyor'u değil
**poz modelinin taban oranını** ölçüyor demektir — eşik hiçbir şeyi ayırt
etmez."*

**Kural (M-F-224):** bir orana "düşük/yüksek" demeden önce kontrol koşulu
ölçülür; taban ile B2 eşiği arasındaki mesafe B2'nin AYIRT EDİCİ GÜCÜdür.

⚠️ **BU BİR PROXY, ve öyle olduğu saklanmıyor.** Protokolün VMR tanımı
test-düzeyi (`geçerli_deneme / toplam_deneme`). Burada ölçülen KARE-düzeyi
metrik geçerliliği (`evaluate(...).valid` oranı). Deneme-düzeyi VMR için
girişim-kapısı + tutuş semantiği gerekir (`AssessmentEngine`); kare-düzeyi
oran onun ÜST SINIRIdır — bir metrik karelerin %20'sinde geçerliyse o testin
deneme-VMR'si %20'yi AŞAMAZ. Yani taban için muhafazakâr, doğru yönde bir
vekil: kare-tabanı yüksekse deneme-tabanı da yüksek OLABİLİR, ama kare-tabanı
düşükse deneme-tabanı kesinlikle düşüktür.

Her sayı **frameBasis etiketli** (anatomical birincil — M-F-224 şart 5;
camera deltası yanında).

Kullanım:
  python3 tools/vmr_baseline.py --reject <fixture...> --accept <fixture...>
"""
from __future__ import annotations

import json
import math
import os
import sys
from pathlib import Path

import numpy as np

REPO = Path(__file__).resolve().parent.parent
_DEFAULT_RIG = (REPO / "../../motion-core/lib/tools/fixture_pipeline").resolve()
MOCORE = Path(os.environ.get("MOCORE_RIG", str(_DEFAULT_RIG))).resolve()
HARVEST = Path.home() / "motion-harvest/lissom/landmarks"
if not MOCORE.exists():  # pragma: no cover
    sys.exit(f"rig bulunamadı: {MOCORE}")
sys.path.insert(0, str(MOCORE))

from mocore import geometry as geo  # noqa: E402
from mocore import measures as mz  # noqa: E402


def load_defs() -> dict[str, mz.MetricDef]:
    raw = json.loads((REPO / "config/metrics/lissom-metrics.v1.json").read_text())
    out: dict[str, mz.MetricDef] = {}
    for m in raw["metrics"]:
        d = mz.MetricDef.from_dict(m)
        out[d.id] = d
        if m.get("mirror"):
            mid = (m["id"].replace("_right", "_left") if "_right" in m["id"]
                   else m["id"].replace("_left", "_right"))
            out[mid] = d.mirrored(mid)
    return out


def frames_of(path: Path) -> list[geo.Frame]:
    data = json.loads(path.read_text())
    out: list[geo.Frame] = []
    for k in data["frames"]:
        if not k.get("detected"):
            continue
        w = k.get("world")
        if not w:
            continue
        lm = k["lm"]
        out.append(geo.Frame(
            xyz=np.asarray(w, dtype=float),
            visibility=np.asarray([p[3] for p in lm], dtype=float),
            presence=np.asarray([p[4] if len(p) > 4 else p[3] for p in lm],
                                dtype=float),
            t_ms=float(k["t"])))
    return out


def vmr_of(md: mz.MetricDef, frames: list[geo.Frame], anatomical: bool) -> float:
    if not frames:
        return float("nan")
    # `valid` OTORİTE (L-197): yan-kanal bayrağını okumayan kod çöpü ölçüm sanar.
    ok = sum(1 for fr in frames
             if mz.evaluate(md, fr, anatomical=anatomical).valid)
    return ok / len(frames)


def resolve(name: str) -> Path:
    return Path(name) if "/" in name else HARVEST / name


def main(argv: list[str]) -> int:
    if "--reject" not in argv or "--accept" not in argv:
        sys.exit(__doc__)
    ri, ai = argv.index("--reject"), argv.index("--accept")
    rejects = [resolve(a) for a in argv[ri + 1:ai if ai > ri else len(argv)]]
    accepts = [resolve(a) for a in argv[ai + 1:ri if ri > ai else len(argv)]]

    defs = load_defs()
    battery = json.loads(
        (REPO / "config/tests/lissom-assessment.v1.json").read_text())
    # Test-başına primary metrik (geometrik olanlar) — protokol VMR'yi
    # test düzeyinde tanımlıyor, o yüzden metrik listesi bataryadan gelir.
    tests: list[tuple[str, str]] = []
    for t in battery["tests"]:
        m = t["primaryMetric"].replace("{side}", "right")
        if m in defs:
            tests.append((t["id"], m))

    print(f"rig: {MOCORE}")
    print(f"§3.2b TABAN — RET n={len(rejects)} · KABUL(B1 örneklem) n={len(accepts)}")
    print("⚠️ kare-düzeyi geçerlilik oranı (deneme-VMR'nin ÜST SINIRI)\n")

    groups: dict[str, list[Path]] = {"RET": rejects, "KABUL": accepts}
    data: dict[str, dict[str, list[float]]] = {
        g: {m: [] for _, m in tests} for g in groups}

    for g, paths in groups.items():
        for p in paths:
            if not p.exists():
                print(f"  ATLANDI (yok): {p.name}")
                continue
            fr = frames_of(p)
            for _, m in tests:
                data[g][m].append(vmr_of(defs[m], fr, True))

    print(f"  {'test':28s} {'metrik':28s} "
          f"{'TABAN(ret)':>11s} {'B1(kabul)':>10s} {'ayrışma':>8s}")
    gaps: list[tuple[str, float, float, float]] = []
    for tid, m in tests:
        r = [v for v in data["RET"][m] if math.isfinite(v)]
        a = [v for v in data["KABUL"][m] if math.isfinite(v)]
        if not r or not a:
            continue
        rm, am = float(np.median(r)), float(np.median(a))
        gap = am - rm
        gaps.append((tid, rm, am, gap))
        mark = ""
        if gap <= 0:
            mark = "  ← RET ≥ KABUL: eşik AYIRT ETMİYOR"
        elif gap < 0.10:
            mark = "  ← ayrışma <0,10: zayıf"
        print(f"  {tid:28s} {m:28s} {rm:11.3f} {am:10.3f} {gap:+8.3f}{mark}")

    if not gaps:
        print("\n❌ hiç kıyas yapılamadı.")
        return 1

    print("\n=== TABAN HÜKMÜ ===")
    med_gap = float(np.median([g[3] for g in gaps]))
    neg = [g for g in gaps if g[3] <= 0]
    weak = [g for g in gaps if 0 < g[3] < 0.10]
    print(f"medyan ayrışma (KABUL − RET) : {med_gap:+.3f}")
    print(f"RET ≥ KABUL olan test         : {len(neg)}/{len(gaps)}")
    print(f"ayrışma <0,10 olan test       : {len(weak)}/{len(gaps)}")
    if neg:
        print("\n⚠️ Bu testlerde triyaj eşiği AYIRT ETMİYOR — reddedilen klipler "
              "kabul edilenler kadar (ya da daha fazla) geçerli ölçüm veriyor:")
        for tid, rm, am, gap in sorted(neg, key=lambda x: x[3]):
            print(f"    {tid:28s} ret={rm:.3f} kabul={am:.3f} ({gap:+.3f})")
    if med_gap < 0.10:
        print("\n❌ B1/B2 EŞİKLERİ TABAN-GÖRELİ OKUNAMAZ: medyan ayrışma "
              f"{med_gap:+.3f} < 0,10. M-F-224 gereği eşik ölçülmüş-taban × "
              "ölçülmüş-ayrışma-k formülünden TÜRETİLEMEZ → isimli dürüst "
              "kapanış: 'eşik türetilemez', kapı-tasarımı koordinatöre döner.")
        return 0
    print(f"\n✅ Ayrışma anlamlı (medyan {med_gap:+.3f}) — eşik türetimi "
          f"M-F-224 formülüyle YAPILABİLİR.")
    return 0


if __name__ == "__main__":
    raise SystemExit(main(sys.argv))
