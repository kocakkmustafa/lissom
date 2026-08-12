#!/usr/bin/env python3
"""PLACEHOLDER BÖLMESİ — her işaretçi bir KARAR taşır (L-295).

## Neden var

Bu hat 2026-08-12'de şunu buldu ve üç hat bağımsız doğruladı:

    Kaynakta beyanlı olmak, KULLANICIYA beyanlı olmak değildir.

Ona iki kapı kurdum. **Ama ikisi de yalnız KULLANICI-YÜZEYİ OLAN
işaretçileri koruyor** — `user-surface` da `source-only` da olmayan, yani
**hiç karar verilmemiş** bir işaretçi ikisinden de sessizce geçerdi.
Ostinato bunu bir adım ileri götürdü ve desen ondan **adapte** edildi:

    Her işaretçi BİRİNE girmek zorunda:
        user-surface: <WidgetKey>   ⊎   source-only: <gerekçe>
    Üçüncü hâl (kararsızlık) KIRMIZI.

⭐ **Bu kapı bir SONUÇ dayatmıyor.** `source-only` tamamen meşru bir cevap;
yasakladığı tek şey **kararsızlık** ve **sessiz kayıp**.

> ***Bir kapı, bir sonucu dayatmak yerine KARARSIZLIĞI yasaklayabilir — o
> zaman hattı zorlamaz, yalnız SESSİZ KAYBI imkânsız kılar.***

## İki tuzak, ikisi de ölçülmüş

1. **AYRIŞTIRICI TEK OLMALI.** Ayrıştırma `gen_placeholder_register`den
   **içe aktarılıyor**, yeniden türetilmiyor — *iki bağımsız çıkarım
   ayrışır* (bu vardiyada dört kez ölçüldü).
2. **YUTAN DESEN = KÖR KAPI.** Ostinato'nun aynı kapısı ilk hâlinde
   **kördü**: deseninin `(.+?)`si işaretçinin geri kalanını yutuyordu, yani
   *"anahtar sevk edilen kodda var mı"* sorusu **hiç sorulmuyordu** — kapı
   koşuyor, soru sorulmuyor. Bu yüzden `binding` **ayrı grup** olarak
   yakalanıyor ve öz-test **anahtarı bozup kapının ÖTMESİNİ** sınıyor.

⚠️ `user-surface` anahtarı **sevk edilen kodda** (`lib/`) GERÇEKTEN
bulunmalı — bulunmuyorsa işaretçi var olmayan bir yüzeye işaret ediyordur
ve bu, koruduğunu sandığın şeyin hiç olmaması demektir.

⛔ `source-only` bir SESSİZ KALMA İZNİ DEĞİL (koordinatör hükmü):
*"kullanıcı-yüzeyi bağı yok"* ile *"kullanıcıya söylenecek bir şey yok"*
**aynı cümle değildir.** `source-only` yazan her satır, kullanıcı sonucunu
da adıyla taşımalı — ve o sonuçlar koordinatöre gider.
"""
from __future__ import annotations

import re
import sys
from pathlib import Path

sys.path.insert(0, str(Path(__file__).resolve().parent))
from gen_placeholder_register import find_markers  # noqa: E402  (tek ayrıştırıcı)

ROOT = Path(__file__).resolve().parents[1]
SHIPPED = ROOT / "lib"

_USER = re.compile(r"^user-surface:\s*(?P<key>\S+)$")
_SRC = re.compile(r"^source-only:\s*(?P<why>.+)$")


def _key_in_shipped(key: str) -> bool:
    """Anahtar SEVK EDİLEN kodda geçiyor mu (yorumda değil, gerçek kod)."""
    for path in SHIPPED.rglob("*.dart"):
        try:
            src = path.read_text(encoding="utf-8")
        except (UnicodeDecodeError, OSError):
            continue
        # Yorum satırları düşürülür: işaretçinin KENDİSİ anahtarı içeriyor
        # ve onu "kanıt" saymak, kapıyı kendi kendine doğrulatırdı.
        code = re.sub(r"//[^\n]*", " ", src)
        if key in code:
            return True
    return False


def partition() -> tuple[list, list, list]:
    valid, malformed = find_markers()
    if malformed:
        raise SystemExit(
            f"⛔ {len(malformed)} BOZUK işaretçi var — bölme ölçülemez "
            f"(önce `gen_placeholder_register.py`)")
    user, src, undecided = [], [], []
    for rel, ln, cat, what, unblocked, binding in valid:
        if (m := _USER.match(binding)):
            user.append((rel, ln, what, m.group("key")))
        elif _SRC.match(binding):
            src.append((rel, ln, what, binding))
        else:
            undecided.append((rel, ln, what))
    return user, src, undecided


def run() -> int:
    user, src, undecided = partition()
    total = len(user) + len(src) + len(undecided)
    # PAYDA DENETLENİR, türetilmez: toplamı parçalardan hesaplayıp
    # "denetledim" demek aritmetik bir kimliktir, bir ölçüm değil
    # (JabLab'ın bugün ölçtüğü kusur — sabotajda exit 0 vermişti).
    counted, _ = find_markers()
    print(f"   işaretçi {len(counted)} · user-surface {len(user)} · "
          f"source-only {len(src)} · KARARSIZ {len(undecided)}")
    if len(counted) != total:
        print(f"⛔ PAYDA TUTMUYOR: taranan {len(counted)} ≠ bölme {total}")
        return 1

    bad = False
    for rel, ln, what, key in user:
        if not _key_in_shipped(key):
            print(f"⛔ `{rel}:{ln}` `user-surface: {key}` diyor ama bu "
                  f"anahtar SEVK EDİLEN kodda YOK — var olmayan bir yüzeye "
                  f"işaret ediyor")
            bad = True
    if undecided:
        print(f"⛔ {len(undecided)} işaretçi KARARSIZ — `user-surface:` ya da "
              f"`source-only:` taşımıyor:")
        for rel, ln, what in undecided:
            print(f"    {rel}:{ln} — {what}")
        print("   Kararsızlık, sessiz kaybın kendisidir.")
        bad = True
    if bad:
        return 1
    print("✅ bölme tam: her işaretçi bir KARAR taşıyor, her anahtar sevk "
          "edilen kodda")
    return 0


def _self_test() -> int:
    ok, fired = True, 0
    user, src, undecided = partition()

    if undecided:
        print(f"   ⛔ TABAN KARARSIZ: {undecided}")
        return 1
    print(f"   ✅ taban temiz (user-surface {len(user)} · source-only "
          f"{len(src)} · kararsız 0)")

    # ① KARARSIZLIK yakalanıyor mu (bağsız işaretçi).
    from gen_placeholder_register import STRICT
    line = ("// PLACEHOLDER(asset): x — unblocked by: y")
    m = STRICT.search(line)
    caught = m is not None and not (m.group("binding") or "")
    print(f"   {'✅' if caught else '⛔'} bağsız işaretçi KARARSIZ sayılıyor")
    ok, fired = ok and caught, fired + 1

    # ② YUTAN DESEN tuzağı — Ostinato'nun körlüğü. Bağ AYRI yakalanmalı,
    #   `unblocked`ın içine düşmemeli.
    line2 = ("// PLACEHOLDER(asset): x — unblocked by: y — "
             "user-surface: some.Key")
    m2 = STRICT.search(line2)
    separated = (m2 is not None
                 and m2.group("binding") == "user-surface: some.Key"
                 and "user-surface" not in m2.group("unblocked"))
    print(f"   {'✅' if separated else '⛔'} bağ AYRI yakalanıyor "
          f"(yutan-desen körlüğü YOK)")
    ok, fired = ok and separated, fired + 1

    # ③ VAR OLMAYAN ANAHTAR ötüyor mu — kapının ASIL sorusu.
    ghost = not _key_in_shipped("ZZQQ.olmayanAnahtar")
    real = all(_key_in_shipped(k) for _, _, _, k in user) if user else True
    print(f"   {'✅' if (ghost and real) else '⛔'} anahtar varlığı GERÇEKTEN "
          f"sorgulanıyor (hayalet={ghost}, mevcutlar={real})")
    ok, fired = ok and ghost and real, fired + 1

    # ④ Anahtar kanıtı YORUMDAN gelmiyor: işaretçinin kendisi yorumdadır.
    comment_only = not _key_in_shipped("kamera akışının canlı görüntüsü")
    print(f"   {'✅' if comment_only else '⛔'} yorum METNİ kanıt sayılmıyor")
    ok, fired = ok and comment_only, fired + 1

    print(f"✅ {fired}/{fired} kapı ateşlendi" if ok
          else "⛔ bölme öz-testi DÜŞTÜ")
    return 0 if ok else 1


if __name__ == "__main__":
    sys.exit(_self_test() if "--self-test" in sys.argv else run())
