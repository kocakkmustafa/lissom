#!/usr/bin/env python3
"""Kaynak-başına hareket-kimliği incelemesi (M-F-71/L-151 adım 3).

Soru: 42-108°'lik anlaşmazlık ölçüm kusuru mu, yoksa kaynaklar GERÇEKTEN
farklı bir hareketi/varyantı mı gösteriyor? Pencereleme çözmedi (L-157) —
bu betik kaynak-başına sapma profili + kamera-açısı ölçümü + varyant adayı
üretir. Gravita G-069 emsali: dışlama SEBEBİ taşınır, sayı tek başına değil.

ÖLÇÜLEN, UYDURULMAYAN: her sayı fixture'dan çekirdek geometrisiyle okunur.
"""
import json
import sys
from pathlib import Path

sys.path.insert(0, "/Users/mustafakaankocak/Documents/YULAlab-AI/ventures/motion-core/lib/tools/fixture_pipeline")

import numpy as np
from mocore import geometry as geo
from mocore import measures as mz

LISSOM = Path("/Users/mustafakaankocak/Documents/YULAlab-AI/ventures/lissom/app")
METRICS = {m["id"]: m for m in json.loads(
    (LISSOM / "config/metrics/lissom-metrics.v1.json").read_text())["metrics"]}


def _mirror_raw(base: dict, target_id: str) -> dict:
    raw = dict(base)
    raw["id"] = target_id
    raw["points"] = [
        p.replace("RIGHT_", "§").replace("LEFT_", "RIGHT_").replace("§", "LEFT_")
        for p in base["points"]
    ]
    return raw


def metric_def(name: str) -> mz.MetricDef:
    base = METRICS.get(name)
    if base is None:
        for a, b in (("_left", "_right"), ("_right", "_left")):
            if name.endswith(a) and METRICS.get(name[: -len(a)] + b):
                base = _mirror_raw(METRICS[name[: -len(a)] + b], name)
                break
    if base is None:
        raise SystemExit(f"metrik config'te yok: {name}")
    return mz.MetricDef.from_dict(base)


def series(frames, md, anatomical=False):
    out = []
    for k in frames:
        if not k.get("detected"):
            continue
        world = k.get("world")
        if not world:
            continue
        lm = k["lm"]
        f = geo.Frame(
            xyz=np.asarray(world, dtype=float),
            visibility=np.asarray([p[3] for p in lm], dtype=float),
            presence=np.asarray([p[4] if len(p) > 4 else p[3] for p in lm], dtype=float),
            t_ms=float(k["t"]),
        )
        r = mz.evaluate(md, f, anatomical=anatomical)
        if r.valid and np.isfinite(r.value):
            out.append((f.t_ms, float(r.value)))
    return out


def pct(vals, p):
    if not vals:
        return float("nan")
    s = sorted(vals)
    i = max(0, min(len(s) - 1, int(round(p / 100 * (len(s) - 1)))))
    return s[i]


def profile(fixture: Path, metric_names: list[str], window_metric: str,
            window_op: str, window_value: float) -> dict:
    doc = json.loads(fixture.read_text())
    frames = doc["frames"]
    prov = doc.get("provenance", {})

    # Hareket penceresi: birincil metriğin eşiği aştığı kareler.
    wm = metric_def(window_metric)
    ws = series(frames, wm)
    if window_op == "gte":
        win = {t for t, v in ws if v >= window_value}
    else:
        win = {t for t, v in ws if v <= window_value}

    out = {
        "id": fixture.stem,
        "channel": prov.get("channel"),
        "frames": len(frames),
        "windowFrames": len(win),
        "metrics": {},
    }
    for name in metric_names:
        md = metric_def(name)
        s = series(frames, md)
        inwin = [v for t, v in s if t in win]
        out["metrics"][name] = {
            "n": len(inwin),
            "p05": round(pct(inwin, 5), 1),
            "median": round(pct(inwin, 50), 1),
            "p95": round(pct(inwin, 95), 1),
        } if inwin else {"n": 0}
    return out


if __name__ == "__main__":
    mode = sys.argv[1]
    if mode == "overhead_reach":
        ids = ["6u_rV3C80wU", "Igzmhbghcd4", "SfxyICleU4I", "T8KTiE9bTZI",
               "X2u_vGL0qJU", "gsz3BLAkkQ4"]
        metrics = ["shoulder_flexion_right", "shoulder_flexion_left",
                   "elbow_extension_right", "elbow_extension_left",
                   "trunk_lean", "shoulder_line_foreshortening"]
        wm, wop, wv = "shoulder_flexion_right", "gte", 140.0
    else:
        ids = ["TuQ4jYbazuw", "YG-iGrQvw44", "yWfMPZWHnVw", "U5qlAYuZzCg"]
        metrics = ["knee_flexion_right", "hip_flexion_right",
                   "tibia_inclination_right", "trunk_lean",
                   "shoulder_line_foreshortening"]
        wm, wop, wv = "knee_flexion_right", "lte", 110.0

    results = []
    for i in ids:
        p = Path.home() / "motion-harvest/lissom/landmarks" / f"{i}.full.json"
        if not p.exists():
            print(f"ATLANDI (dosya yok): {i}", file=sys.stderr)
            continue
        results.append(profile(p, metrics, wm, wop, wv))
    print(json.dumps({"movement": mode, "sources": results},
                     ensure_ascii=False, indent=1))
