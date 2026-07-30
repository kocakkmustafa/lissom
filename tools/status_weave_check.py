#!/usr/bin/env python3
"""Statü-örgüsü kapısı — `comingSoon` ile `measurementOnly` ASLA karışmaz.

Aile yüzey-kuralı (M-F-186, benim öz-kararımdan terfi etti):

    comingSoon        = ÖLÇÜMÜN KENDİSİ yok
    measuredNoBands   = ölçüm VAR, yalnız kıyas yok
                        (test düzeyinde: referenceStatus.state=measurementOnly)

Bu ikisi karışırsa **çalışan bir ölçümü "yakında" diye etiketlemiş** oluruz —
kullanıcının yaptığı işi sahiplenmemek, yani L-135 zararının yeni kostümü.
Kural doküman olarak yazılıydı; **yazılı ama uygulanmayan sınır, olmayan
sınır kadar tehlikelidir (L-093)** — bu yüzden kapı.

Denetlenen değişmezler:
  1. `referenceStatus` taşıyan bir test, `coming_soon` bir aileden
     BESLENEMEZ. Aile "yakında" derken içindeki test ölçüm yapıyorsa,
     yüzey yanlış konuşur.
  2. Bir test aynı anda hem `referenceStatus` hem `comingSoon`-benzeri bir
     alan taşıyamaz (kelime kaçağı avı: comingSoon/coming_soon/beta).
  3. `referenceStatus` beyan eden testin ailesi CANLI olmalı
     (`in_progress` | `available`).

Bağımlılık YOK — saf stdlib.
"""

from __future__ import annotations

import json
import sys
from pathlib import Path

ROOT = Path(__file__).resolve().parent.parent
BATTERY = ROOT / "config/tests/lissom-assessment.v1.json"
IA = ROOT / "config/ia/library.v1.json"

#: Testte GÖRÜLMESİ YASAK "yakında" sözcükleri — statü-örgüsü kaçağı.
FORBIDDEN_TEST_KEYS = {"comingSoon", "coming_soon", "beta", "unavailable"}

#: Ailenin CANLI sayıldığı durumlar.
LIVE_FAMILY_STATES = {"in_progress", "available"}


def check(battery: dict, ia: dict) -> list[str]:
    problems: list[str] = []

    # Batarya'yı besleyen aile(ler)i bul — elle yazmıyoruz, itemsSource'tan
    # TÜRETİYORUZ (elle yazılan eşleme bayatlar ve kapı yanlış aileye bakar).
    battery_rel = "config/tests/" + BATTERY.name
    feeding = [
        f for f in ia.get("families", [])
        if (f.get("itemsSource") or "").endswith(BATTERY.name)
    ]
    if not feeding:
        problems.append(
            f"IA'da hiçbir aile {battery_rel}'i beslemiyor — kapı hangi ailenin "
            "durumuna bakacağını bilemez (sessiz geçiş değil, SERT hata)"
        )

    measurement_only = [
        t for t in battery.get("tests", [])
        if isinstance(t.get("referenceStatus"), dict)
        and t["referenceStatus"].get("state") == "measurementOnly"
    ]

    for t in battery.get("tests", []):
        leaked = FORBIDDEN_TEST_KEYS & set(t)
        if leaked:
            problems.append(
                f"{t['id']}: '{', '.join(sorted(leaked))}' alanı taşıyor — "
                "bir TEST 'yakında' olamaz. comingSoon ÖLÇÜMÜN YOKLUĞUDUR; "
                "ölçüm varken kıyas yoksa doğru beyan referenceStatus/"
                "measurementOnly'dir (M-F-186)"
            )

    if measurement_only:
        names = ", ".join(t["id"] for t in measurement_only)
        for f in feeding:
            state = f.get("status")
            if state not in LIVE_FAMILY_STATES:
                problems.append(
                    f"'{f['id']}' ailesi durumu '{state}' ama içinde ÖLÇÜM YAPAN "
                    f"measurementOnly test(ler) var ({names}) — çalışan bir "
                    "ölçümü 'yakında' diye sunmak, kullanıcının yaptığı işi "
                    "sahiplenmemektir (M-F-186 / L-135'in yeni kostümü)"
                )

    return problems


def _self_test() -> int:
    """Kapı KIRMIZI yanabiliyor mu (M-F-58 dördüncü canlılık sorusu)."""
    fails: list[str] = []

    live_ia = {"families": [{"id": "b", "status": "in_progress",
                             "itemsSource": f"config/tests/{BATTERY.name}"}]}
    mo_test = {"id": "x", "referenceStatus": {"state": "measurementOnly"}}

    # 1) coming_soon aile + measurementOnly test → YAKALANMALI
    soon_ia = {"families": [{"id": "b", "status": "coming_soon",
                             "itemsSource": f"config/tests/{BATTERY.name}"}]}
    if not check({"tests": [mo_test]}, soon_ia):
        fails.append("coming_soon aile + measurementOnly test yakalanmadı")

    # 2) testte 'comingSoon' alanı → YAKALANMALI
    if not check({"tests": [{"id": "y", "comingSoon": True}]}, live_ia):
        fails.append("testteki comingSoon alanı yakalanmadı")

    # 3) besleyen aile YOK → YAKALANMALI (sessiz geçiş olmasın)
    if not check({"tests": [mo_test]}, {"families": []}):
        fails.append("besleyen aile yokluğu yakalanmadı")

    # 4) MEŞRU durum → geçmeli
    if check({"tests": [mo_test]}, live_ia):
        fails.append("YANLIŞ ALARM: canlı aile + measurementOnly geçmeliydi")

    print(f"statü-örgüsü öz-testi — 4 vaka (3 yakalanmalı, 1 geçmeli)")
    if fails:
        print(f"\n❌ Kapı BOZUK — {len(fails)} vaka:")
        for f in fails:
            print(f"  {f}")
        return 1
    print("✅ Kapı bilinen karışmaları yakalıyor, meşru durumu geçiriyor.")
    return 0


def main() -> int:
    if "--self-test" in sys.argv:
        return _self_test()

    battery = json.loads(BATTERY.read_text(encoding="utf-8"))
    ia = json.loads(IA.read_text(encoding="utf-8"))
    problems = check(battery, ia)

    mo = sum(1 for t in battery.get("tests", [])
             if isinstance(t.get("referenceStatus"), dict))
    print(f"Statü-örgüsü denetimi — {len(battery.get('tests', []))} test, "
          f"{mo} measurementOnly beyanı")
    if problems:
        print(f"\n❌ {len(problems)} sorun:")
        for p in problems:
            print(f"  {p}")
        return 1
    print("✅ comingSoon ile measurementOnly karışmıyor.")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
