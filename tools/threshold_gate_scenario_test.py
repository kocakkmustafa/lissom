#!/usr/bin/env python3
"""L-135 kabul kanıtı: "eşik-altı kullanıcı ne görüyor" senaryo testi.

M-F-71 kararının 3 testte (overhead_reach, ankle_dorsiflexion, lateral_bend)
uygulanışını, gerçek `peak_hold.enter` koşulunu ESKİ ve YENİ hâliyle senkron
kareler üzerinde koşturarak kanıtlıyor:

  ESKİ (M-F-71 öncesi, burada literal olarak sabitlendi — L-135'in bulduğu
  kusur budur): `all(delta<15°/s, metric>=eski-eşik)`. Eski eşiğin altında
  kalan bir kullanıcı bu koşulu hiç sağlamaz → `raising`/`bending` kendi
  `timeoutMs`'inde sessizce düşer, HİÇBİR ölçüm üretilmez.

  YENİ (canlı config'ten OKUNUR, sabitlenmez — kaynak değişirse test onunla
  birlikte değişsin diye): yalnız `delta`. Aynı kullanıcı artık ölçülür.

SINIR: bu betik gerçek çekirdek `PhaseStateMachine`'i çalıştırmıyor (o henüz
yazılmadı — motion-core M-F-42 notu: "Evaluator sonraki artırım"). Kendi
minimal koşul-yorumlayıcısı ile yalnız `conditionGrammar`'ın burada kullanılan
alt kümesini (`metric`/`delta`/`all`/`any`) değerlendirir; kare-başı `delta`
hesaplaması 200ms'lik geriye-bakan bir pencereyle YAKLAŞIKTIR, çekirdeğin
gerçek türev algoritmasıyla bire bir aynı olduğu iddia edilmez. Kanıtlamak
istediği tek şey: konfigürasyondaki koşul MANTIĞI, gerçek bir "hareket etti
ama eski eşiğe ulaşmadı" izinde farklı sonuç üretiyor mu.
"""

from __future__ import annotations

import json
from pathlib import Path

ROOT = Path(__file__).resolve().parent.parent
PHASES = ROOT / "config/phases/lissom-phases.v1.json"
BATTERY = ROOT / "config/tests/lissom-assessment.v1.json"

FPS = 30
DT_MS = 1000.0 / FPS
DELTA_WINDOW_MS = 200.0  # ~6 kare geriye bakan türev penceresi

# M-F-71 öncesi peak_hold.enter — L-135'in bulduğu kusurlu hâl, KASITLI
# olarak burada literal tutuluyor (canlı config'ten silindiği için oradan
# okunamaz; bu testin var olma sebebi tam bu karşılaştırma).
OLD_PEAK_HOLD_ENTER = {
    "overhead_reach": {
        "kind": "all",
        "of": [
            {"kind": "delta", "metric": "shoulder_flexion_right", "op": "<", "valuePerSecond": 15.0},
            {"kind": "metric", "metric": "shoulder_flexion_right", "op": ">=", "value": 60},
        ],
    },
    "ankle_dorsiflexion": {
        "kind": "all",
        "of": [
            {"kind": "delta", "metric": "tibia_inclination_right", "op": "<", "valuePerSecond": 15.0},
            {"kind": "metric", "metric": "tibia_inclination_right", "op": ">=", "value": 15},
        ],
    },
    "lateral_bend": {
        "kind": "all",
        "of": [
            {"kind": "delta", "metric": "trunk_lateral_tilt", "op": "<", "valuePerSecond": 15.0},
            {"kind": "metric", "metric": "trunk_lateral_tilt", "op": ">=", "value": 15},
        ],
    },
}

# Senaryo: "donmuş omuzla 50°'ye ulaşabilen kullanıcı" (L-135'in kendi
# örneği) — eski eşiğin (60/15/15) altında ama gerçek, sürdürülebilir bir
# hareket. Kaynak: 0 -> below_old_gate arası 1.5 sn'de düz rampa, sonra 3 sn
# düz tutuş (minDurationMs 1500'ü rahatça karşılasın), sonra iniş.
SCENARIOS = {
    "overhead_reach": {"metric": "shoulder_flexion_right", "below_old_gate": 50.0, "old_gate": 60},
    "ankle_dorsiflexion": {"metric": "tibia_inclination_right", "below_old_gate": 11.0, "old_gate": 15},
    "lateral_bend": {"metric": "trunk_lateral_tilt", "below_old_gate": 12.0, "old_gate": 15},
}


def _cmp(value: float, op: str, target: float) -> bool:
    return {
        ">": value > target, ">=": value >= target,
        "<": value < target, "<=": value <= target,
        "==": value == target, "!=": value != target,
    }[op]


def eval_cond(cond: dict, value: float, delta: float) -> bool:
    kind = cond["kind"]
    if kind == "metric":
        return _cmp(value, cond["op"], cond["value"])
    if kind == "delta":
        return _cmp(delta, cond["op"], cond["valuePerSecond"])
    if kind == "all":
        return all(eval_cond(c, value, delta) for c in cond["of"])
    if kind == "any":
        return any(eval_cond(c, value, delta) for c in cond["of"])
    raise ValueError(f"bilinmeyen kind: {kind}")


def build_trajectory(peak: float, hold_s: float = 3.0) -> list[tuple[float, float]]:
    """0 -> peak (1.5sn rampa) -> peak sabit (hold_s) -> 0 (1.5sn iniş)."""
    frames: list[tuple[float, float]] = []
    t = 0.0
    rise_ms = 1500.0
    while t < rise_ms:
        frames.append((t, peak * (t / rise_ms)))
        t += DT_MS
    hold_end = rise_ms + hold_s * 1000
    while t < hold_end:
        frames.append((t, peak))
        t += DT_MS
    fall_end = hold_end + rise_ms
    while t < fall_end:
        frames.append((t, peak * (1 - (t - hold_end) / rise_ms)))
        t += DT_MS
    return frames


def with_deltas(frames: list[tuple[float, float]]) -> list[tuple[float, float, float]]:
    """(t, value, delta_per_second) — delta 200ms geriye-bakan fark oranı."""
    out = []
    lookback = int(DELTA_WINDOW_MS / DT_MS)
    for i, (t, v) in enumerate(frames):
        j = max(0, i - lookback)
        t0, v0 = frames[j]
        dt_s = (t - t0) / 1000.0
        delta = (v - v0) / dt_s if dt_s > 0 else 0.0
        out.append((t, v, delta))
    return out


def first_sustained_entry(frames_vd: list[tuple[float, float, float]], enter_cond: dict,
                           min_duration_ms: float, timeout_ms: float) -> float | None:
    """İlk SÜRDÜRÜLEBİLİR giriş anının değeri, yoksa None (= zaman aşımı, sessiz düşüş)."""
    run_start_t: float | None = None
    for t, v, d in frames_vd:
        if t > timeout_ms:
            return None
        if eval_cond(enter_cond, v, d):
            if run_start_t is None:
                run_start_t = t
            elif t - run_start_t >= min_duration_ms:
                return v
        else:
            run_start_t = None
    return None


def classify_tier(value: float, bands: dict | None) -> str:
    """M-F-71 madde 3/5: en düşük bandın altı KOÇLANAN'dır, SKORLANAN değil."""
    if bands is None:
        return "no-numeric-bands"  # örn. ankle_dorsiflexion — yalnız nitel
    lowest_low = min(b["low"] for b in bands.values())
    return "coached_below_range" if value < lowest_low else "scored"


def main() -> int:
    phases_doc = json.loads(PHASES.read_text(encoding="utf-8"))
    battery_doc = json.loads(BATTERY.read_text(encoding="utf-8"))
    battery_by_id = {t["id"]: t for t in battery_doc["tests"]}

    failures: list[str] = []
    print("L-135 senaryo testi — eşik-altı kullanıcı 3 testte ne görüyor\n")

    for test_id, scenario in SCENARIOS.items():
        test = next(t for t in phases_doc["tests"] if t["testId"] == test_id)
        peak_hold = next(p for p in test["phases"] if p["id"] == "peak_hold")
        new_enter = peak_hold["enter"]
        min_dur = peak_hold["minDurationMs"]
        timeout = peak_hold.get("timeoutMs", 6000)
        # Ölçüm ÖNCESİ faz (raising/bending) timeoutMs'i — eski davranışta
        # kullanıcı bu süre içinde hiç peak_hold'a giremeyip orada düşerdi.
        pre_phase_id = "raising" if "raising" in {p["id"] for p in test["phases"]} else "bending"
        pre_phase = next(p for p in test["phases"] if p["id"] == pre_phase_id)
        pre_timeout = pre_phase["timeoutMs"]

        frames = with_deltas(build_trajectory(scenario["below_old_gate"]))

        old_result = first_sustained_entry(
            frames, OLD_PEAK_HOLD_ENTER[test_id], min_dur, pre_timeout)
        new_result = first_sustained_entry(frames, new_enter, min_dur, pre_timeout)

        old_ok = old_result is None  # BEKLENEN: eski kapı bu kullanıcıyı hiç ölçmüyordu
        new_ok = new_result is not None and abs(new_result - scenario["below_old_gate"]) < 0.5

        print(f"  {test_id}: senaryo değeri {scenario['below_old_gate']}° "
              f"(eski eşik {scenario['old_gate']}°)")
        print(f"    ESKİ kapı  → {'SESSİZ TIMEOUT (ölçüm yok)' if old_ok else f'BEKLENMEDİK: {old_result}'}"
              f"  [{'✅' if old_ok else '❌'}]")
        print(f"    YENİ kapı  → {'ölçüldü: ' + format(new_result, '.1f') + '°' if new_ok else f'BEKLENMEDİK: {new_result}'}"
              f"  [{'✅' if new_ok else '❌'}]")

        if not old_ok:
            failures.append(f"{test_id}: eski kapı hâlâ ölçüyor — karşılaştırma anlamsız")
        if not new_ok:
            failures.append(f"{test_id}: yeni kapı eşik-altı kullanıcıyı ÖLÇMEDİ — L-135 açık kalıyor")

        # M-F-71 madde 3/5: sonuç bandın altındaysa KOÇLANAN, SKORLANAN değil.
        scoring = battery_by_id[test_id].get("scoring", {})
        bands = scoring.get("bands") if scoring.get("type") == "banded" else None
        # bantlar yaş-grubu altında iç içe; hepsini birleştirip en düşük tabanı bul
        flat_bands = None
        if bands:
            flat_bands = {f"{age}:{lvl}": {"low": v} for age, levels in bands.items()
                          for lvl, v in levels.items() if lvl == "low"}
            # basitleştir: yalnız 'low' seviyelerini topla
            flat_bands = {k: v for k, v in flat_bands.items()}
        tier = classify_tier(new_result, flat_bands) if new_result is not None else "unmeasured"
        print(f"    sonuç katmanı → {tier}")
        if flat_bands is not None and tier != "coached_below_range":
            failures.append(
                f"{test_id}: eşik-altı sonuç 'coached_below_range' olarak sınıflanmadı — {tier}")
        print()

    if failures:
        print(f"❌ {len(failures)} sorun:")
        for f in failures:
            print(f"  {f}")
        return 1
    print("✅ 3 testte de: eski kapı sessizce düşerdi, yeni kapı ölçüyor ve sonucu koçlanan-katmana yerleştiriyor.")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
