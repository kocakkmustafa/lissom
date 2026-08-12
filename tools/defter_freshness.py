#!/usr/bin/env python3
"""DEFTER TAZELİĞİ — `git log`taki her `L-NNN` deftere geçmiş mi? (L-294)

## Neden var

2026-08-12'de iki hatta **59 kayıt** kaybı ölçüldü: iş yapıldı, commit'lendi,
rapor edildi — **deftere geçmedi** (JabLab 6 · Gravita 5 · Ostinato ~50).
Beş hattın **hiçbirinde** defterin tazeliğini ölçen bir kapı yoktu.

    Bir işin YAPILMIŞ olması, KAYDEDİLMİŞ olması değildir.

JabLab'ın yöntemi (*"yeni kaydı yazarken bir öncekinin çapasını ara"*) ucuz
ve doğru, **ama kusurun EN AĞIR hâlinde KÖR:** çapa ancak *sıradaki kaydı
yazarken* aranır; **hiç kayıt yazmadığın anı** görmez. Bu kapının ölçütü
**alışkanlık-bağımsız**: kaynağı kayıt yazma huyu değil, **commit'in
kendisi**.

⛔ **İCAT EDİLMEDİ — Gravita `tools/defter_freshness.py` (`1d110be`)
ADAPTE edildi.** Ama desenleri KOPYALANMADI: Lissom'un biçimleri ÖNCE
ölçüldü (aşağıda), çünkü Gravita'nın kendi uyarısı tam buydu —
*"defterin BİÇİMİ hatta göre değişir"*, ve onun ilk yazımı tek biçim
tanıdığı için **47 yanlış pozitif** vermişti.

## Ölçülmüş biçimler (2026-08-12, bu hattın kendi defteri)

| biçim | sayı | ne |
|---|---|---|
| `\\| L-NNN \\| tür \\| öncelik \\| …` | **253** | ESKİ bölüm, tablo kaydı |
| `## L-NNN — …` | **39** | YENİ bölüm, prose başlığı |
| satır başında çıplak `L-NNN` | 7 | ⛔ **KAYIT DEĞİL** — düzyazı atfı |

**Kesişim 0** → iki biçim de gerçek kayıt, ayrık kümeler. Yalnız `##`
tanısaydım **253 sahte gedik** bildirirdim; kapı doğduğu gün güvenilirliğini
kaybederdi.

Ve 7 çıplak satırın **hepsi** ölçüldü (*"L-289'u commit ederken…"*,
*"L-255'i uygularken…"*): **atıf**, kayıt değil. Girdiye ALINMAZLAR —
*bir kavramdan söz eden cümle, o kavramın kaydı değildir.*

## Üç tuzak

1. **SÖZÜNÜ ETMEK ≠ İDDİA ETMEK.** Bir commit başlığı *"bkz L-182"*
   diyebilir; bu onun L-182 OLDUĞU anlamına gelmez. Yalnız **conventional
   commit KAPSAMI** sayılır (`fix(L-280): …`) — commit'in KENDİ iddiası.
   ⚠️ Gravita'nın deseni (`^G-\\d+`) burada ÇALIŞMAZ: bu hattın başlıkları
   `tür(kapsam):` biçiminde, numara **parantez içinde**.
2. **SÖZÜNÜ ETMEK ≠ KAYIT OLMAK** (defter tarafı) — yukarıdaki 7 satır.
3. **PAYDA HER ZAMAN YAZILI** — *taranan commit N · iddia edilen M ·
   defterde K*. Paydasız bir sayı güven yanılsaması üretir.

📌 **Gravita'dan ALINMAYAN bir öz-test var, ve gerekçesi ölçüldü:** onun ③.
testi *"depodaki `G-999` sentinel'i girdiye karışmıyor"* diyor. Bu hatta
`L-9xx` sentinel'i **YOK** (ölçüldü: 0 isabet) → o testi kopyalamak, **hiç
var olmayan bir şeyi kontrol eden vakum-doğru bir test** olurdu. Yerine bu
hattın GERÇEK kirlenme riski sınanıyor: **düzyazı atıfları**.

⚠️ DEFTER depo DIŞINDA (`../workspace/DEFTER.md`). Bulunamazsa bu kapı
**gürültüyle düşer** — bulunamayan bir dosya üzerinden *"gedik yok"*
raporlamak ölçüm değil körlüktür.
"""
from __future__ import annotations

import re
import subprocess
import sys
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
DEFTER = ROOT.parent / "workspace" / "DEFTER.md"

#: Commit'in KENDİ iddiası: conventional-commit KAPSAMI (`fix(L-280): …`).
_SUBJECT = re.compile(r"^[a-z]+\((L-\d+)")
#: Defterdeki gerçek kayıt — İKİ biçim, ÖLÇÜLDÜ (yukarıdaki tablo).
#: Satır başındaki çıplak `L-NNN` KASITLA dışarıda: 7'sinin de atıf olduğu
#: tek tek okundu.
_ENTRY = re.compile(r"^(?:#+ |\| )(L-\d+)\b", re.M)


def commit_ids(limit: int = 400) -> tuple[list[str], int]:
    out = subprocess.run(
        ["git", "-C", str(ROOT), "log", f"-{limit}", "--format=%s"],
        capture_output=True, text=True, check=True).stdout.splitlines()
    ids = [m.group(1) for line in out if (m := _SUBJECT.match(line.strip()))]
    return ids, len(out)


def defter_text() -> str:
    if not DEFTER.exists():
        raise SystemExit(
            f"⛔ DEFTER BULUNAMADI ({DEFTER}) — bulunamayan bir dosya "
            f"üzerinden 'gedik yok' raporlamak ölçüm değil KÖRLÜKTÜR.")
    return DEFTER.read_text(encoding="utf-8")


def gap() -> tuple[list[str], int, int, int]:
    ids, scanned = commit_ids()
    recorded = set(_ENTRY.findall(defter_text()))
    missing = sorted({i for i in ids if i not in recorded},
                     key=lambda s: int(s.split("-")[1]))
    return missing, scanned, len(set(ids)), len(recorded)


def run() -> int:
    missing, scanned, claimed, recorded = gap()
    print(f"   taranan commit {scanned} · commit'in İDDİA ettiği kayıt "
          f"{claimed} · defterde {recorded}")
    if missing:
        print(f"⛔ DEFTER GEDİĞİ — {len(missing)} kayıt commit'te VAR, "
              f"defterde YOK: {', '.join(missing)}")
        print("   Bir işin YAPILMIŞ olması, KAYDEDİLMİŞ olması değildir.")
        return 1
    print("✅ defter TAZE — commit'in iddia ettiği her kayıt defterde")
    return 0


def _self_test() -> int:
    ok = True
    fired = 0
    text = defter_text()

    # ⓪ TABAN — kapı kendi doğduğu gün gediği bildirmeli, saklamamalı.
    missing, scanned, claimed, recorded = gap()
    if missing:
        print(f"   ⛔ TABAN KİRLİ — bugün zaten gedik var: {missing}")
        return 1
    print(f"   ✅ taban temiz (gedik 0, {claimed} iddia / {scanned} commit / "
          f"{recorded} kayıt)")

    # ① GEDİK SAPTAMA — İKİ BİÇİM AYRI AYRI sınanır. Tek biçimle sınamak,
    #   Gravita'nın 47 yanlış pozitifini üreten körlüğün ta kendisiydi.
    for label, sample in (
        ("başlık", next(iter(re.findall(r"^#+ (L-\d+)\b", text, re.M)), None)),
        ("tablo", next(iter(re.findall(r"^\| (L-\d+)\b", text, re.M)), None)),
    ):
        if sample is None:
            print(f"   ⛔ {label} biçimi defterde BULUNAMADI — kapı bu "
                  f"biçimi ölçemez")
            ok = False
            continue
        hidden = re.sub(rf"^(#+ |\| ){re.escape(sample)}\b",
                        r"\1xx-000", text, count=1, flags=re.M)
        caught = sample not in _ENTRY.findall(hidden)
        print(f"   {'✅' if caught else '⛔'} gedik saptama [{label}] "
              f"({sample} gizlendi): "
              f"{'yakalandı' if caught else 'YAKALANMADI — SAHTE KAPI'}")
        ok = ok and caught
        fired += 1

    # ② DÜZYAZI ATFI ≠ KAYIT (bu hattın GERÇEK kirlenme riski; Gravita'nın
    #   sentinel testinin yerine geçer — bkz. modül dokümanı).
    prose = "L-999'u uygularken aynı commit'te iki kez düştüm:"
    leaked = "L-999" in _ENTRY.findall(prose)
    print(f"   {'✅' if not leaked else '⛔'} düzyazı atfı girdiye "
          f"{'KARIŞMIYOR' if not leaked else 'KARIŞTI — kapı kör'}")
    ok = ok and not leaked
    fired += 1

    # ③ SÖZÜNÜ ETMEK ≠ İDDİA ETMEK (commit tarafı).
    claims = _SUBJECT.match("fix(L-280): gerçek kayıt") is not None
    mentions = _SUBJECT.match("docs: bkz L-182 — bu commit ONUN DEĞİL") is None
    print(f"   {'✅' if (claims and mentions) else '⛔'} 'sözünü etmek ≠ "
          f"iddia etmek': {'ayrım çalışıyor' if claims and mentions else 'AYRIM YOK'}")
    ok = ok and claims and mentions
    fired += 1

    print(f"✅ {fired}/{fired} kapı ateşlendi" if ok
          else "⛔ defter tazeliği öz-testi DÜŞTÜ")
    return 0 if ok else 1


if __name__ == "__main__":
    sys.exit(_self_test() if "--self-test" in sys.argv else run())
