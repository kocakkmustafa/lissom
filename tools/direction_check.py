#!/usr/bin/env python3
"""Ölçüm YÖNÜ kapısı — hangi uca doğru topladığımız TEK bir cevap vermeli.

Bu kapının doğuşu bir sweep bulgusu (L-181). `aggregation` alanının hiçbir
okuyucusu yoktu; motor yönü `scoring.higherIsBetter`'dan okuyor ve o alan
YOKKEN sessizce `true` varsayıyordu. Sonuç: üç testte (deep_squat,
forward_lunge, thoracic_rotation) motor tepeyi TERS yönde biriktiriyordu —
`deep_squat`'ta en AZ çömelinen an "ölçüm" olarak raporlanacaktı. Dördüncüsü
(`overhead_squat`) config'in kendi içinde çelişiyordu: `aggregation: max`
ama `higherIsBetter: false`.

Ders, alanı silmek değil: **okuyucusu olmayan alan süse dönüşür, ve süs
sessizce yanlış olabilir.** O yüzden `aggregation` burada TÜKETİLİYOR — artık
bir okuyucusu var ve çelişince kapı kırmızı yanıyor.

Yön için elimizde üç bağımsız sinyal var, hepsi config'te:
  1. `aggregation`          max | min | duration
  2. `scoring.higherIsBetter`  motorun GERÇEKTE okuduğu alan
  3. `presence.op` / `movementPresence.op`  hareketin hangi yönde olduğu
     (fixture ile doğrulanmış kapılar — en güvenilir sinyal)

Kapı bunların ÇELİŞMEDİĞİNİ zorlar. Tek bir "doğru alan" seçmiyor, çünkü
sweep gösterdi ki ikisi de tek başına yanılabiliyor; çelişkiyi GÖRÜNÜR
kılmak, bir alanı otorite ilan etmekten güvenli.

Bağımlılık YOK — saf stdlib.
"""

from __future__ import annotations

import json
import sys
from pathlib import Path

ROOT = Path(__file__).resolve().parent.parent
BATTERY = ROOT / "config/tests/lissom-assessment.v1.json"

#: op → "büyük değer hareketi gösterir mi"
OP_DIR = {">=": True, ">": True, "gte": True, "<=": False, "<": False, "lte": False}

#: aggregation → aynı soru. `duration` yönsüzdür (süre daima artar; iyi olan
#: UZUN tutuştur ve bu `higherIsBetter: true` ile ifade edilir).
AGG_DIR = {"max": True, "min": False, "duration": None}


def check(battery: dict) -> list[str]:
    problems: list[str] = []
    for t in battery.get("tests", []):
        tid = t.get("id", "<isimsiz>")
        scoring = t.get("scoring") or {}

        if "higherIsBetter" not in scoring:
            problems.append(
                f"{tid}: `scoring.higherIsBetter` YOK — motor yönü bu alandan "
                "okuyor ve sessiz varsayılan ölçümü ters çevirir (L-181). "
                "Yön BEYAN edilmeli."
            )
            continue
        hib = scoring["higherIsBetter"]

        agg = t.get("aggregation")
        if agg is None:
            problems.append(f"{tid}: `aggregation` YOK — yön çapraz-denetimi yapılamaz")
        elif agg not in AGG_DIR:
            problems.append(
                f"{tid}: `aggregation: {agg}` bilinmiyor (max|min|duration) — "
                "tanınmayan değer sessizce denetim DIŞI kalır"
            )
        else:
            agg_dir = AGG_DIR[agg]
            if agg_dir is not None and agg_dir != hib:
                problems.append(
                    f"{tid}: `aggregation: {agg}` ile `higherIsBetter: {hib}` "
                    f"ÇELİŞİYOR — biri yanlış, ve motor yalnız ikincisini "
                    "okuduğu için hata sessiz kalır"
                )

        # Fixture ile doğrulanmış kapılar en güvenilir sinyal: çelişirlerse
        # şüphe elle yazılmış alanlardadır.
        for field in ("presence", "movementPresence"):
            gate = t.get(field) or {}
            op = gate.get("op")
            if op is None:
                continue
            if op not in OP_DIR:
                problems.append(f"{tid}: `{field}.op: {op}` bilinmiyor")
                continue
            if OP_DIR[op] != hib:
                problems.append(
                    f"{tid}: `{field}.op: {op}` hareketin "
                    f"{'BÜYÜK' if OP_DIR[op] else 'KÜÇÜK'} değerde olduğunu "
                    f"söylüyor ama `higherIsBetter: {hib}` — kapı fixture ile "
                    "doğrulanmış, şüphe elle yazılan yöndedir"
                )
    return problems


def _self_test() -> int:
    """Kapı KIRMIZI yanabiliyor mu (M-F-58 dördüncü canlılık sorusu)."""
    fails: list[str] = []

    def case(name: str, test: dict, should_catch: bool) -> None:
        got = bool(check({"tests": [test]}))
        if got != should_catch:
            fails.append(
                f"{name}: {'yakalanmalıydı' if should_catch else 'GEÇMELİYDİ'}"
            )

    # 1) L-181'in ta kendisi: yön beyanı YOK
    case("yön beyansız", {"id": "a", "scoring": {}, "aggregation": "min"}, True)
    # 2) aggregation ↔ higherIsBetter çelişkisi (overhead_squat vakası)
    case("agg↔hIB çelişkisi",
         {"id": "b", "scoring": {"higherIsBetter": False}, "aggregation": "max"},
         True)
    # 3) fixture kapısı yönü çürütüyor (deep_squat vakası)
    case("presence.op çelişkisi",
         {"id": "c", "scoring": {"higherIsBetter": True}, "aggregation": "max",
          "presence": {"op": "<="}},
         True)
    # 4) aggregation hiç yok → çapraz-denetim imkânsız
    case("aggregation yok", {"id": "d", "scoring": {"higherIsBetter": True}}, True)
    # 5) tanınmayan aggregation sessizce geçmesin
    case("tanınmayan agg",
         {"id": "e", "scoring": {"higherIsBetter": True}, "aggregation": "peak"},
         True)
    # 6) MEŞRU: üç sinyal de aynı yönü söylüyor
    case("hepsi uyumlu",
         {"id": "f", "scoring": {"higherIsBetter": False}, "aggregation": "min",
          "presence": {"op": "<="}, "movementPresence": {"op": "lte"}},
         False)
    # 7) MEŞRU: duration yönsüz, uzun tutuş iyidir
    case("duration",
         {"id": "g", "scoring": {"higherIsBetter": True}, "aggregation": "duration"},
         False)

    print("yön kapısı öz-testi — 7 vaka (5 yakalanmalı, 2 geçmeli)")
    if fails:
        print(f"\n❌ Kapı BOZUK — {len(fails)} vaka:")
        for f in fails:
            print(f"  {f}")
        return 1
    print("✅ Kapı bilinen yön kusurlarını yakalıyor, meşru durumu geçiriyor.")
    return 0


def main() -> int:
    if "--self-test" in sys.argv:
        return _self_test()

    battery = json.loads(BATTERY.read_text(encoding="utf-8"))
    problems = check(battery)
    tests = battery.get("tests", [])
    signals = sum(
        1
        for t in tests
        for f in ("presence", "movementPresence")
        if (t.get(f) or {}).get("op")
    )
    print(
        f"Yön denetimi — {len(tests)} test, {signals} fixture-doğrulanmış "
        "yön sinyali"
    )
    if problems:
        print(f"\n❌ {len(problems)} sorun:")
        for p in problems:
            print(f"  {p}")
        return 1
    print("✅ Her testte yön beyanı VAR ve tüm sinyaller aynı yönü söylüyor.")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
