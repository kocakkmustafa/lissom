#!/usr/bin/env python3
"""§3.2b TAVAN ölçümü — sentetik ground-truth kliplerde VMR.

Protokol §3.2b: *"Tavan (ceiling): sentetik ground-truth kliplerde VMR.
%100'e ulaşılamıyorsa fark koşuldan değil **hattın kendisinden** gelir;
B1/B2 arasındaki boşluk o kaybı da içerir."*

Sentetik iskelet KUSURSUZ: `confidence=1.0`, gürültü yok, landmark'lar
kinematik zincirden türetiliyor. O hâlde VMR **%100 olmalı.** Olmuyorsa kayıp
hattın kendisindedir ve bu araç kaybın NEREDE olduğunu isimle söyler —
`evaluate`'in kendi `reason` alanı üzerinden (düşük güven · dejenere ·
fiziksel-aralık dışı). "Tavan %94" demek yetmez; %6'nın adı olmalı.

İKİ SENARYO ölçülür:

  **T-A (yaw=0)**   ideal kadraj. Buradaki kayıp SAF hat kaybıdır.
  **T-B (yaw=±30)** özne kameraya göre dönük. M-F-54'ün iddiası burada
                    sınanır: anatomik mod yaw'ı temizlemeli, kamera modu
                    temizlememeli. Lissom'un 12 testinden 8'i kullanıcıya
                    "yandan dur" dediği için bu senaryo süs değil.

Her sayı **frameBasis etiketli** (anatomical | camera) ve kilit
karşılaştırmalarda iki-mod deltası raporlanır (koordinatör zeyli, şart 2-3).

⚠️ TEST→POZ EŞLEMESİ BİR TASARIM KARARIDIR, ölçüm değil. `Pose` yalnız
sagittal açıları + lateral_bend + heel_lift taşıyor, config'ten otomatik
türetilemez. Her eşleme aşağıda GEREKÇELİ; eşleme yanlışsa tavan da yanlış
olur, o yüzden gizli bırakılmıyor.

Kullanım:
  python3 tools/synthetic_ceiling.py
"""
from __future__ import annotations

import json
import math
import sys
from collections import Counter
from pathlib import Path

import numpy as np

REPO = Path(__file__).resolve().parent.parent
MOCORE = (REPO / "../../motion-core/lib/tools/fixture_pipeline").resolve()
if not MOCORE.exists():  # pragma: no cover
    sys.exit(f"kanonik yorumlayıcı bulunamadı: {MOCORE}")
sys.path.insert(0, str(MOCORE))

from mocore import measures as mz  # noqa: E402
from mocore import synth  # noqa: E402

#: Kaç kare üretilir — hareketin tamamı boyunca ramp.
N_FRAMES = 60

#: T-B senaryosunun yaw açıları (derece).
YAWS = (-30.0, 30.0)


def P(**kw) -> synth.Pose:
    return synth.Pose(**kw)


#: test id → (başlangıç poz, hedef poz, gerekçe)
#:
#: Gerekçeler `Pose` docstring'inin konvansiyonuna göre yazıldı:
#: shoulder_flex 0=kol yanda · hip_flex 0=ayakta · knee_flex 0=düz bacak ·
#: trunk_lean 0=dik · heel_lift metre.
SCENARIOS: dict[str, tuple[synth.Pose, synth.Pose, str]] = {
    # Kol yandan baş üstüne. 170 (180 değil) — tam 180 dejenere kol-gövde
    # doğrusallığı üretip açıyı sayısal olarak kırılgan yapıyor.
    "overhead_reach": (P(), P(shoulder_flex=170.0),
                       "kol yandan baş üstüne (0→170°)"),
    # Çömelme: kalça ve diz BİRLİKTE bükülür. Yalnız birini sürmek
    # anatomik olarak imkânsız bir duruş üretir ve `range` süzgecine takılır.
    "deep_squat": (P(), P(hip_flex=110.0, knee_flex=120.0),
                   "kalça+diz birlikte (0→110°/120°)"),
    # ⚠️ İlk senaryom `trunk_lean`i HİÇ sürmüyordu ve bu testin primary
    # metriği TAM ODUR — VMR %100 çıkıyordu ama değer 60 karede sabit 0,00°
    # kalıyordu, yani tavan hiçbir şey kanıtlamıyordu (L-183 vacuous-geçiş
    # sınıfı, varyans kapısı yakaladı). Gerçek overhead squat'ta gövde de
    # öne eğilir; senaryo düzeltildi.
    "overhead_squat": (P(shoulder_flex=170.0),
                       P(shoulder_flex=170.0, hip_flex=110.0, knee_flex=120.0,
                         trunk_lean=25.0),
                       "kollar baş üstü SABİT; kalça+diz+GÖVDE birlikte "
                       "(trunk_lean primary metrik)"),
    # Tibia eğimi ayrı parametre DEĞİL (Pose docstring'i): kinematik zincirden
    # (hip_flex − knee_flex) türüyor. Bu yüzden diz üzerinden sürülüyor.
    "ankle_dorsiflexion": (P(), P(knee_flex=40.0, hip_flex=20.0),
                           "diz-duvara: tibia eğimi zincirden türer"),
    # Hamstring: kalça bükülür, diz DÜZ kalır (guard `knee_flexion < 165`
    # tam bunu koruyor).
    "hamstring_reach": (P(), P(hip_flex=90.0),
                        "kalça 0→90°, diz DÜZ (guard'ın koruduğu hâl)"),
    "hip_hinge": (P(), P(trunk_lean=80.0), "gövde 0→80° öne"),
    "lateral_bend": (P(), P(lateral_bend=40.0), "gövde 0→40° yana"),
    "forward_lunge": (P(), P(hip_flex=60.0, knee_flex=90.0),
                      "hamle: knee_height zincirden türer"),
    "active_straight_leg_raise": (P(), P(hip_flex=80.0),
                                  "bacak düz kalkar (diz DÜZ)"),
    # thoracic_rotation'ın metriği `shoulder_line_foreshortening` ve o
    # ROTASYON ölçüyor — `Pose`'da transvers rotasyon YOK, bu yüzden
    # senaryo `synth.yaw` ile kurulur (aşağıda özel yol).
}

#: Geometrik OLMAYAN primary metrik taşıyan testler — tavan bu araçla
#: ölçülemez ve bu SESSİZCE atlanmaz.
NON_GEOMETRIC = {"single_leg_balance": "hold_duration",
                 "plank_hold": "hold_duration"}


def load() -> tuple[dict, dict[str, mz.MetricDef]]:
    battery = json.loads(
        (REPO / "config/tests/lissom-assessment.v1.json").read_text())
    raw = json.loads(
        (REPO / "config/metrics/lissom-metrics.v1.json").read_text())
    defs: dict[str, mz.MetricDef] = {}
    for m in raw["metrics"]:
        d = mz.MetricDef.from_dict(m)
        defs[d.id] = d
        if m.get("mirror"):
            mid = (m["id"].replace("_right", "_left") if "_right" in m["id"]
                   else m["id"].replace("_left", "_right"))
            defs[mid] = d.mirrored(mid)
    return battery, defs


def vmr(md: mz.MetricDef, frames: list, anatomical: bool) -> dict:
    """VMR + geçersizlik sebebi kırılımı. Sebep isimsiz kalmaz."""
    valid = 0
    reasons: Counter[str] = Counter()
    vals: list[float] = []
    for fr in frames:
        r = mz.evaluate(md, fr, anatomical=anatomical)
        if r.valid and math.isfinite(r.value):
            valid += 1
            vals.append(float(r.value))
        else:
            reasons[r.reason or "reason-YOK"] += 1
    a = np.asarray(vals, dtype=float)
    return dict(
        n=len(frames), valid=valid,
        vmr=valid / len(frames) if frames else float("nan"),
        med=float(np.median(a)) if a.size else float("nan"),
        lo=float(a.min()) if a.size else float("nan"),
        hi=float(a.max()) if a.size else float("nan"),
        reasons=reasons,
    )


def build(test_id: str, yaw_deg: float | None) -> list:
    start, end, _ = SCENARIOS[test_id]
    frames = synth.sequence(synth.ramp(start, end, N_FRAMES))
    if yaw_deg is not None:
        frames = [synth.yaw(f, yaw_deg) for f in frames]
    return frames


def build_rotation(extra_yaw: float) -> list:
    """thoracic_rotation: yaw'ı RAMP eder — rotasyonun kendisi hareket.

    ⚠️ İlk sürüm SABİT bir yaw uyguluyordu ve `shoulder_line_foreshortening`
    60 kare boyunca kıpırdamıyordu (0,80 → yaw=0'da; 0,69 → yaw=±30'da).
    VMR %100 çıkıyordu ama hiçbir şey ölçülmemişti — varyans kapısı yakaladı,
    tam L-183'ün vacuous-geçiş sınıfı. Bu testin ÖLÇTÜĞÜ ŞEY rotasyon, yani
    senaryoda rotasyon DEĞİŞMELİ; `extra_yaw` T-B'nin kamera-yönelimini
    üstüne bindiren sabit ofsettir, hareketin kendisi 0→60° rampası.
    """
    frames = synth.sequence([synth.Pose()] * N_FRAMES)
    return [synth.yaw(f, extra_yaw + 60.0 * i / max(1, N_FRAMES - 1))
            for i, f in enumerate(frames)]


def report(label: str, rows: list[tuple]) -> None:
    print(f"\n=== {label} ===")
    print(f"  {'test':28s} {'metrik':28s} "
          f"{'VMR(anat)':>9s} {'VMR(cam)':>9s} {'Δ':>7s} "
          f"{'med(anat)':>10s} {'med(cam)':>10s} {'aralık(anat)':>13s}")
    for t, m, a, c in rows:
        span = a["hi"] - a["lo"] if math.isfinite(a["hi"]) else float("nan")
        # ⚠️ VMR %100 ama metrik SABİT ise tavan hiçbir şey kanıtlamaz:
        # senaryo o metriği hiç sürmüyor demektir (L-183 vacuous-geçiş sınıfı).
        dead = "  ← SABİT: senaryo bu metriği SÜRMÜYOR" if (
            math.isfinite(span) and span < 1e-6) else ""
        print(f"  {t:28s} {m:28s} "
              f"{a['vmr']:9.3f} {c['vmr']:9.3f} {c['vmr'] - a['vmr']:+7.3f} "
              f"{a['med']:10.2f} {c['med']:10.2f} {span:13.3f}{dead}")
        for mode, r in (("anat", a), ("cam", c)):
            if r["reasons"]:
                detail = " · ".join(f"{k}×{v}" for k, v in r["reasons"].items())
                print(f"      ↳ {mode} geçersiz: {detail}")


def main() -> int:
    battery, defs = load()
    specs = {t["id"]: t for t in battery["tests"]}

    print("§3.2b TAVAN ÖLÇÜMÜ — sentetik ground-truth")
    print(f"kare/senaryo: {N_FRAMES} · yaw senaryosu: {YAWS} derece")
    print(f"batarya {battery['version']} · sentetik iskelet confidence=1.0, "
          f"gürültü YOK")

    for tid, why in NON_GEOMETRIC.items():
        print(f"ATLANDI (geometrik değil): {tid} → primaryMetric `{why}` "
              f"süre ölçüyor, tavanı bu araçla ölçülemez")

    missing = set(specs) - set(SCENARIOS) - set(NON_GEOMETRIC) - {
        "thoracic_rotation"}
    if missing:
        print(f"\n❌ SENARYOSU OLMAYAN TEST: {sorted(missing)} — sessizce "
              f"atlanmıyor, senaryo eklenmeli")

    # ---- T-A: ideal kadraj -------------------------------------------------
    rows_a: list[tuple] = []
    for tid, spec in specs.items():
        if tid in NON_GEOMETRIC:
            continue
        metric_name = spec["primaryMetric"].replace("{side}", "right")
        md = defs.get(metric_name)
        if md is None:
            print(f"  {tid}: `{metric_name}` config'te TANIMSIZ — atlandı")
            continue
        frames = (build_rotation(0.0) if tid == "thoracic_rotation"
                  else build(tid, None) if tid in SCENARIOS else None)
        if frames is None:
            continue
        rows_a.append((tid, metric_name,
                       vmr(md, frames, True), vmr(md, frames, False)))
    report("T-A · ideal kadraj (yaw=0) — buradaki kayıp SAF hat kaybı", rows_a)

    # ---- T-B: dönük özne ---------------------------------------------------
    for y in YAWS:
        rows_b: list[tuple] = []
        for tid, spec in specs.items():
            if tid in NON_GEOMETRIC:
                continue
            metric_name = spec["primaryMetric"].replace("{side}", "right")
            md = defs.get(metric_name)
            if md is None:
                continue
            frames = (build_rotation(y) if tid == "thoracic_rotation"
                      else build(tid, y) if tid in SCENARIOS else None)
            if frames is None:
                continue
            rows_b.append((tid, metric_name,
                           vmr(md, frames, True), vmr(md, frames, False)))
        report(f"T-B · dönük özne (yaw={y:+.0f}°) — M-F-54 iddiası burada "
               f"sınanır", rows_b)

    # ---- hüküm ------------------------------------------------------------
    print("\n\n=== TAVAN HÜKMÜ ===")
    dead_rows = [t for t, _, a, _ in rows_a
                 if math.isfinite(a["hi"]) and (a["hi"] - a["lo"]) < 1e-6]
    perfect = [t for t, _, a, _ in rows_a if a["vmr"] >= 0.999]
    lossy = [(t, a["vmr"]) for t, _, a, _ in rows_a if a["vmr"] < 0.999]
    print(f"T-A (ideal) tavanı %100 olan test : {len(perfect)}/{len(rows_a)}")
    if lossy:
        print("⚠️ TAVAN %100'ÜN ALTINDA — kayıp KOŞULDAN değil HATTAN "
              "geliyor; B1/B2 boşluğu bu kaybı da içerir:")
        for t, v in sorted(lossy, key=lambda x: x[1]):
            print(f"    {t:28s} VMR(anat)={v:.3f}")
        print("  → B1 (%90) / B2 (%75) bu testlerde tavan-göreli okunmalı; "
              "ham eşik karşılaştırması hattın kaybını koşula yazar.")
    else:
        print("✅ Tüm testlerde ideal tavan %100 — B1/B2 boşluğu saf koşul "
              "etkisi olarak okunabilir (hat kaybı sıfır).")
    if dead_rows:
        print(f"\n❌ TAVAN GEÇERSİZ ({len(dead_rows)} test): metrik senaryo "
              f"boyunca SABİT kaldı, yani senaryo o metriği sürmüyor. VMR %100 "
              f"burada 'hat kayıpsız' DEĞİL 'hiçbir şey ölçülmedi' demektir "
              f"(L-183 vacuous-geçiş sınıfı):")
        for t in dead_rows:
            print(f"    {t}")
        return 1
    print("\n✅ VARYANS KAPISI: her testin primary metriği senaryo boyunca "
          "gerçekten HAREKET ETTİ — tavan %100'ü anlamlı.")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
