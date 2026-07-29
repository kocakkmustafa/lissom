#!/usr/bin/env python3
"""Fixture HAREKETİ içeriyor mu — hasat hattının eksik kapısı.

Neden gerekli: triyaj kadrajı ölçer, dedup kopyayı, netlik kaliteyi. Hiçbiri
"bu klipte hareket VAR MI" sorusunu sormuyordu. `overhead_reach` için toplanan
4 fixture'ın 3'ü bu yüzden hareketi içermiyordu — kol hiç ~90°'yi geçmiyor,
birinde kareler %69 oranında dik duruş bile değil (klinik muayene videosu:
pasif/dirençli ROM, ya da izlenen kişi hastanın değil klinisyenin ta kendisi).
4 bağımsız kanal vardı ama kullanılabilir kaynak sayısı 1'di (L-092).

Bu sınırı pencere ölçütünü yazarken kendim not etmiştim — "pencere GÖRÜNÜRLÜK
garantisi verir, tekrarın gerçekleştiğini DEĞİL" — ama kapıya çevirmemiştim.
Yazılı ama uygulanmayan sınır, olmayan sınır kadar tehlikeli (L-093).

ÖLÇÜT: birincil metrik, eşiği KESİNTİSİZ olarak testin kendi `holdSeconds`
değerinin yarısı kadar aşmalı. Kümülatif kare sayısı YETMEZ: gürültü ve kısa
pasif hareketler toplamda kolayca eşiği geçiyor ama tutuş üretmiyor.
"""

from __future__ import annotations

import json
import math
import sys
from pathlib import Path

ROOT = Path(__file__).resolve().parent.parent
METRICS = ROOT / "config/metrics/lissom-metrics.v1.json"
BATTERY = ROOT / "config/tests/lissom-assessment.v1.json"

BLAZEPOSE_INDEX = {
    "NOSE": 0, "LEFT_SHOULDER": 11, "RIGHT_SHOULDER": 12, "LEFT_ELBOW": 13,
    "RIGHT_ELBOW": 14, "LEFT_WRIST": 15, "RIGHT_WRIST": 16, "LEFT_HIP": 23,
    "RIGHT_HIP": 24, "LEFT_KNEE": 25, "RIGHT_KNEE": 26, "LEFT_ANKLE": 27,
    "RIGHT_ANKLE": 28, "LEFT_HEEL": 29, "RIGHT_HEEL": 30,
    "LEFT_FOOT_INDEX": 31, "RIGHT_FOOT_INDEX": 32,
}
#: Sanal landmark'lar gerçek noktaların orta noktasıdır (metrik config'i
#: bunları doğrudan kullanıyor: trunk_lateral_tilt = MID_HIP -> MID_SHOULDER).
VIRTUAL = {
    "MID_HIP": ("LEFT_HIP", "RIGHT_HIP"),
    "MID_SHOULDER": ("LEFT_SHOULDER", "RIGHT_SHOULDER"),
    "MID_KNEE": ("LEFT_KNEE", "RIGHT_KNEE"),
    "MID_ANKLE": ("LEFT_ANKLE", "RIGHT_ANKLE"),
}
MIN_VISIBILITY = 0.5


def _angle3(a, b, c) -> float | None:
    """b köşesindeki açı, görüntü düzleminde (derece)."""
    v1 = (a[0] - b[0], a[1] - b[1])
    v2 = (c[0] - b[0], c[1] - b[1])
    n1, n2 = math.hypot(*v1), math.hypot(*v2)
    if n1 < 1e-9 or n2 < 1e-9:
        return None
    d = max(-1.0, min(1.0, (v1[0] * v2[0] + v1[1] * v2[1]) / (n1 * n2)))
    return math.degrees(math.acos(d))


def _angle_vertical(p_from, p_to) -> float:
    """`p_from -> p_to` vektörünün DİKEYDEN sapması (derece).

    Görüntü koordinatlarında y aşağı büyür; dik duruşta gövde vektörü yukarı
    bakar. 0° = tam dik, büyüdükçe yana eğilme.
    """
    dx = p_to[0] - p_from[0]
    dy = p_to[1] - p_from[1]
    return abs(math.degrees(math.atan2(dx, -dy)))


def _resolve(points: list[str]) -> list[tuple[int, ...]]:
    """Her noktayı, ortalaması alınacak gerçek landmark indekslerine çevirir."""
    out: list[tuple[int, ...]] = []
    for name in points:
        parts = VIRTUAL.get(name, (name,))
        missing = [q for q in parts if q not in BLAZEPOSE_INDEX]
        if missing:
            raise SystemExit(f"BlazePose sözlüğünde olmayan landmark: {missing}")
        out.append(tuple(BLAZEPOSE_INDEX[q] for q in parts))
    return out


def _series(frames: list[dict], points: list[str], kind: str = "angle3"):
    """(t_ms, açı) dizisi — yalnız tüm noktaları güvenle görünen kareler.

    `kind` metriğin türünü izler: `angle3` üç noktalı eklem açısı,
    `angle_vertical` iki noktalı gövde/uzuv eğimi. Türü yok saymak sessizce
    YANLIŞ sayı üretir — iki noktalı bir metriği angle3 sanmak çöker ya da
    anlamsız açı verir.
    """
    groups = _resolve(points)
    out: list[tuple[float, float]] = []
    for k in frames:
        if not k.get("detected"):
            continue
        lm = k["lm"]
        if any(lm[i][3] < MIN_VISIBILITY for g in groups for i in g):
            continue
        pts = [(sum(lm[i][0] for i in g) / len(g),
                sum(lm[i][1] for i in g) / len(g)) for g in groups]
        if kind == "angle_vertical":
            if len(pts) != 2:
                raise SystemExit(f"angle_vertical iki nokta ister, {len(pts)} geldi")
            val = _angle_vertical(*pts)
        else:
            if len(pts) != 3:
                raise SystemExit(f"angle3 üç nokta ister, {len(pts)} geldi")
            val = _angle3(*pts)
        if val is not None:
            out.append((k["t"], val))
    return out


def longest_hold_s(series, op: str, value: float) -> float:
    """Eşiğin KESİNTİSİZ aşıldığı en uzun süre (sn)."""
    best = 0.0
    run_start: float | None = None
    prev_t: float | None = None
    for t, v in series:
        holds = v >= value if op == "gte" else v <= value
        # Kare arası boşluk büyükse (landmark kayboldu) dizi kopar.
        broken = prev_t is not None and (t - prev_t) > 250.0
        if holds and not broken:
            if run_start is None:
                run_start = t
            best = max(best, (t - run_start) / 1000.0)
        else:
            run_start = t if holds else None
        prev_t = t
    return best


def check(fixture: Path, test_id: str) -> tuple[bool, str]:
    battery = json.loads(BATTERY.read_text(encoding="utf-8"))
    metrics = {m["id"]: m for m in json.loads(METRICS.read_text(encoding="utf-8"))["metrics"]}
    test = next((t for t in battery["tests"] if t["id"] == test_id), None)
    if test is None:
        raise SystemExit(f"bataryada test yok: {test_id}")

    mp = test.get("movementPresence")
    if mp is None:
        raise SystemExit(
            f"{test_id}: `movementPresence` BEYAN EDİLMEMİŞ. Beyansız test için "
            "fixture doğrulanamaz — sessizce geçirmek, kapının hiç olmaması "
            "demektir (L-093). Bataryaya ekleyin."
        )

    mid = mp["metric"]
    # `{side}` / `{opposite}` yer tutucuları iki tarafa açılır; hangi taraf
    # hareket ediyorsa o sayılır (klip tek taraflı olabilir).
    if "{side}" in mid or "{opposite}" in mid:
        cands = [mid.replace("{side}", a).replace("{opposite}", b)
                 for a, b in (("right", "left"), ("left", "right"))]
    else:
        cands = [mid]
        for a, b in (("_right", "_left"), ("_left", "_right")):
            if mid.endswith(a):
                cands.append(mid[: -len(a)] + b)

    doc = json.loads(fixture.read_text(encoding="utf-8"))
    frames = doc["frames"]
    need_s = mp.get("minHoldS") or max(1.0, test.get("holdSeconds", 2) / 2)

    best = 0.0
    for cand in cands:
        base = metrics.get(cand)
        if base is None:
            # Ayna metrik config'te tek tanımla durur — karşı tarafı üret.
            for a, b in (("_left", "_right"), ("_right", "_left")):
                if cand.endswith(a) and metrics.get(cand[: -len(a)] + b):
                    base = metrics[cand[: -len(a)] + b]
                    break
        if base is None:
            raise SystemExit(f"{test_id}: metrik config'te yok — {cand}")
        pts = list(base["points"])
        if cand != base["id"]:
            pts = [p.replace("RIGHT_", "§").replace("LEFT_", "RIGHT_").replace("§", "LEFT_")
                   for p in pts]
        best = max(best, longest_hold_s(
            _series(frames, pts, base.get("kind", "angle3")),
            mp["op"], mp["value"]))

    ok = best >= need_s
    return ok, (f"en uzun tutuş {best:.1f}sn "
                f"({mp['metric']} {mp['op']} {mp['value']}) · gereken {need_s:.1f}sn")


def main() -> int:
    if len(sys.argv) < 3:
        print("kullanım: fixture_check.py <fixture.json> <testId> [...]")
        return 2
    test_id = sys.argv[-1]
    bad = 0
    for f in sys.argv[1:-1]:
        ok, why = check(Path(f), test_id)
        print(f"  {'✅' if ok else '❌'} {Path(f).name:<28} {why}")
        bad += not ok
    print(f"\n{len(sys.argv) - 2 - bad}/{len(sys.argv) - 2} fixture hareketi içeriyor")
    return 1 if bad else 0


if __name__ == "__main__":
    raise SystemExit(main())
