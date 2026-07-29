#!/usr/bin/env python3
"""`phase_check.py`'nin kendisini sınar — CI kapısı.

`lint_selftest.py` deseni: bulmayan bir denetim ile bozuk bir denetim
dışarıdan aynı görünür. Bu betik bilinen bozuklukları `check()`'e verir ve
yakalamasını bekler; yakalamazsa denetim bozulmuş demektir.

M-F-71 madde 4 kabul kanıtının bir parçası: `timeoutCode` eksikliğinin
yakalandığını KANITLAR — yalnız "şu an config'te sorun yok" demek yetmez,
denetimin sorunu tanıdığını göstermek gerekir (L-011/L-146 dersi: boş tarama
ile çalışan tarama dışarıdan aynı görünür).
"""

from __future__ import annotations

import copy
import json
from pathlib import Path

import phase_check as pc

ROOT = Path(__file__).resolve().parent.parent


def _load_real() -> tuple[dict, dict, dict]:
    phases = json.loads(pc.PHASES.read_text(encoding="utf-8"))
    metrics = json.loads(pc.METRICS.read_text(encoding="utf-8"))
    battery = json.loads(pc.BATTERY.read_text(encoding="utf-8"))
    return phases, metrics, battery


def _find_phase(phases_doc: dict, test_id: str, phase_id: str) -> dict:
    test = next(t for t in phases_doc["tests"] if t["testId"] == test_id)
    return next(p for p in test["phases"] if p["id"] == phase_id)


def main() -> int:
    failures: list[str] = []

    phases, metrics, battery = _load_real()

    # ---- Gerçek config temiz mi (pozitif kontrol) --------------------------
    clean = pc.check(phases, metrics, battery)
    if clean:
        failures.append(f"GERÇEK CONFIG TEMİZ DEĞİL — {len(clean)} sorun: {clean[:3]}")

    # ---- MUST_CATCH: timeoutCode silinince yakalanmalı ---------------------
    broken = copy.deepcopy(phases)
    victim = _find_phase(broken, "overhead_reach", "raising")
    assert "timeoutCode" in victim, "test kırılgan — alan adı değişmiş olabilir"
    del victim["timeoutCode"]
    problems = pc.check(broken, metrics, battery)
    if not any("overhead_reach.raising" in p and "timeoutCode" in p for p in problems):
        failures.append(
            "KAÇIRDI: `timeoutCode` silinen faz yakalanmadı — "
            f"dönen sorunlar: {problems}"
        )

    # ---- MUST_CATCH: abortCode hâlâ ayrı sınanıyor (regresyon) -------------
    broken2 = copy.deepcopy(phases)
    victim2 = _find_phase(broken2, "overhead_reach", "peak_hold")
    del victim2["abortCode"]
    problems2 = pc.check(broken2, metrics, battery)
    if not any("overhead_reach.peak_hold" in p and "abortCode" in p for p in problems2):
        failures.append(f"KAÇIRDI: `abortCode` silinen faz yakalanmadı — {problems2}")

    # ---- MUST_PASS: terminal faza timeoutCode ZORUNLU değil ----------------
    # `complete` fazları zaten timeoutMs taşımıyor — üzerlerinde timeoutCode
    # aramak yanlış-alarm olurdu. Gerçek config'te zaten yok; burada regresyon
    # olarak bir terminal faza timeoutCode EKLEMENİN sorun ÜRETMEDİĞİNİ sınıyoruz.
    passthrough = copy.deepcopy(phases)
    complete = _find_phase(passthrough, "overhead_reach", "complete")
    complete["timeoutCode"] = "SHOULD_BE_HARMLESS"
    problems3 = pc.check(passthrough, metrics, battery)
    if problems3:
        failures.append(
            f"YANLIŞ ALARM: terminal faza timeoutCode eklemek sorun üretti — {problems3}"
        )

    print(f"phase_check öz-testi — {3 + 1} vaka (1 pozitif kontrol, 2 yakalanmalı, 1 geçmeli)")
    if failures:
        print(f"\n❌ Denetim BOZUK — {len(failures)} vaka:")
        for f in failures:
            print(f"  {f}")
        return 1
    print("✅ phase_check.py bilinen bozuklukları yakalıyor, temiz config'i geçiriyor.")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
