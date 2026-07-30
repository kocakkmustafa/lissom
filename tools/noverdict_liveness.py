#!/usr/bin/env python3
"""Hüküm-YOK yollarının CANLILIK kapısı (aile fallback-canlılık reçetesi).

M-F-71 madde 4 her çıkış yolunun isimli bir sonuç kodu üretmesini istiyor.
`ResultCode` enum'u bunu TİP düzeyinde garanti ediyor gibi görünüyor — ama
enum'a bir değer eklemek üç ayrı şeyin OLDUĞUNU kanıtlamaz:

  1. **ÜRETİLİYOR mu?** Motorda o kodu döndüren bir yol var mı? Yoksa kod bir
     temenni: yüzeyde metni var, hayatta karşılığı yok.
  2. **SINANIYOR mu?** Hiçbir test o kodu iddia etmiyorsa, o yolun çalıştığını
     kimse bilmiyor — "yazıldı ama yol hiç geçilmiyor" ailesi.
  3. **KONUŞUYOR mu?** Yüzeyde o koda ait AÇIK bir cümle var mı? Genel bir
     yedek metne düşmek, sebebi İSİMLE söyleme sözünü sessizce bozar (L-135).

Dördüncü canlılık sorusu ("bu kapıyı kim SORUYOR?") bu üçünü sormadan
cevaplanamaz. Kapı metin taraması yapıyor — kaba ama tam olarak doğru soruyu
soruyor ve bir enum değeri eklendiğinde sessiz kalmıyor.

Bağımlılık YOK — saf stdlib.
"""

from __future__ import annotations

import re
import sys
from pathlib import Path

ROOT = Path(__file__).resolve().parent.parent
RESULT = ROOT / "packages/lissom_engine/lib/src/assessment_result.dart"
ENGINE = ROOT / "packages/lissom_engine/lib/src/assessment_engine.dart"
STRINGS = ROOT / "lib/app/summary_strings.dart"
TEST_DIRS = (ROOT / "packages/lissom_engine/test", ROOT / "test")

#: Ölçüm ALINDI kodu — bir hüküm-yok yolu DEĞİL, bu yüzden canlılık üçlüsünden
#: muaf. Muafiyet ADIYLA ve GEREKÇESİYLE burada: sessiz bir istisna listesi,
#: kapının kendisini oyulmuş hâle getirir.
EXEMPT = {"measured": "ölçüm alındı kodu — hüküm-YOK yolu değil"}


def _codes(result_src: str) -> list[str]:
    """`enum ResultCode { ... }` içindeki değer adları."""
    m = re.search(r"enum ResultCode \{(.*?)\n\}", result_src, re.S)
    if not m:
        raise SystemExit("ResultCode enum'u bulunamadı — kapı yanlış dosyaya bakıyor")
    body = re.sub(r"///[^\n]*", "", m.group(1))  # doc yorumlarını at
    return re.findall(r"^\s*([a-zA-Z][a-zA-Z0-9]*)\s*,", body, re.M)


def check(result_src: str, engine_src: str, strings_src: str,
          test_src: str) -> list[str]:
    problems: list[str] = []
    codes = _codes(result_src)
    if len(codes) < 2:
        problems.append(
            f"ResultCode'da yalnız {len(codes)} değer ayrıştırıldı — kapı "
            "büyük olasılıkla enum'u okuyamadı (sessiz yeşil riski)"
        )
    for c in codes:
        if c in EXEMPT:
            continue
        if f"ResultCode.{c}" not in engine_src:
            problems.append(
                f"{c}: motorda ÜRETİM yolu yok — yüzeyde metni olan ama "
                "hayatta karşılığı olmayan bir sebep"
            )
        if f"ResultCode.{c}" not in test_src:
            problems.append(
                f"{c}: hiçbir test bu kodu İDDİA etmiyor — o çıkış yolunun "
                "çalıştığını kimse bilmiyor"
            )
        if f"'{c}'" not in strings_src:
            problems.append(
                f"{c}: yüzeyde AÇIK cümlesi yok, genel yedeğe düşüyor — "
                "sebebi isimle söyleme sözü sessizce bozulur (L-135)"
            )
    return problems


def _self_test() -> int:
    """Kapı KIRMIZI yanabiliyor mu (M-F-58)."""
    result = "enum ResultCode {\n  measured,\n  trackingLost,\n  ghostCode,\n}\n"
    engine = "code: ResultCode.trackingLost,"
    strings = "'trackingLost' => 'The camera lost track of you.',"
    tests = "expect(r.code, ResultCode.trackingLost);"
    fails: list[str] = []

    got = check(result, engine, strings, tests)
    # ghostCode üç kusuru birlikte taşıyor: üretim yok, test yok, metin yok.
    for want in ("ÜRETİM yolu yok", "İDDİA etmiyor", "AÇIK cümlesi yok"):
        if not any(want in p and "ghostCode" in p for p in got):
            fails.append(f"ghostCode için '{want}' yakalanmadı")
    if any("trackingLost" in p for p in got):
        fails.append("YANLIŞ ALARM: üç ayağı tam olan kod şikâyet üretti")
    if any("measured" in p for p in got):
        fails.append("muafiyet çalışmıyor: 'measured' şikâyet edildi")

    # Enum hiç okunamazsa kapı SESSİZ YEŞİL vermemeli.
    if not check("enum ResultCode {\n}\n", "", "", ""):
        fails.append("boş/okunamayan enum sessiz geçti")

    print("hüküm-yok canlılık öz-testi — 5 iddia")
    if fails:
        print(f"\n❌ Kapı BOZUK — {len(fails)}:")
        for f in fails:
            print(f"  {f}")
        return 1
    print("✅ Kapı ölü kodları yakalıyor, canlı olanı geçiriyor.")
    return 0


def main() -> int:
    if "--self-test" in sys.argv:
        return _self_test()

    test_src = "\n".join(
        p.read_text(encoding="utf-8")
        for d in TEST_DIRS
        for p in d.rglob("*_test.dart")
    )
    result_src = RESULT.read_text(encoding="utf-8")
    problems = check(
        result_src,
        ENGINE.read_text(encoding="utf-8"),
        STRINGS.read_text(encoding="utf-8"),
        test_src,
    )
    codes = _codes(result_src)
    print(
        f"Hüküm-yok canlılık denetimi — {len(codes)} sonuç kodu "
        f"({len(EXEMPT)} muaf), her biri için üretim + test + yüzey cümlesi"
    )
    if problems:
        print(f"\n❌ {len(problems)} sorun:")
        for p in problems:
            print(f"  {p}")
        return 1
    print("✅ Her hüküm-yok yolu üretiliyor, sınanıyor ve İSİMLE konuşuyor.")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
