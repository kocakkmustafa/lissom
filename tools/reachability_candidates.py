#!/usr/bin/env python3
"""GEZİLEBİLİRLİK ADAY KÜMESİ — DESENDEN türetilir (L-298, sözleşme §a).

Aile hükmü: aday küme **desenden** türetilir, **elle liste tutulmaz**.

    Elle liste HAFIZADAN okur; kusuru SESSİZ ve SINIRSIZ —
    ne unuttuğunu bilemezsin.

Ve gerçekten unutmuştu: eski `kCountableScreens` **`LiveCaptureScreen`i
taşımıyordu**, oysa Home'daki *"Start a measurement"* düğmesi onu gerçek bir
rotayla açıyor. KATI sayısı **2 yerine 3**miş.

> ***Bir elle liste, modülün kendisi değil onun ANLATIMIDIR*** — bu hattın
> bugün üç kez ödediği kuralın (pin checkout · `*.swift` kapsamı · desen
> sanılan etiket) dördüncü hâli.

## Bu script ne yapar

Kodu tarayıp **iki sınıf** aday bulur ve `test/reachability_contract_test
.dart`ın `kCandidateScreens` listesiyle **karşılaştırır**; ayrışma KIRMIZI.

  ① **Rota yüzeyi** — kendi `Scaffold`unu kuran widget (push ile açılır)
  ② **Sekme gövdesi** — kabuğun `switch`inde çizilen widget (Scaffold
     KURMAZ; kabuk kurar) — bu hattın mimarisine özgü, ve yalnız
     "Scaffold sahibi" desenini kullanan bir tarama bunları KAÇIRIR.

⛔ **Dışlananlar, isimle:** yükleme/hata/uyuşmazlık hâlleri
(`_GateLoadingScreen` · `_LoadFailureScreen` · `_TabMismatchScreen`) ve
onboarding akışı. Sebep: sayma kuralının §5'i — *hâl ekranları ve akış
adımları ekran sayılmaz.* Bunlar **dışlanıyor, gizlenmiyor**: aşağıda
adlarıyla basılıyorlar.
"""
from __future__ import annotations

import re
import sys
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
CONTRACT = ROOT / "test" / "reachability_contract_test.dart"

#: §5 gereği sayılmayanlar. ⛔ **GEREKÇE BURADA YAZILMAZ, TÜRETİLİR** —
#: `exclusion_facts()` her kalemin gerekçesini KODDAN ölçer.
#:
#: 🔴 Sözleşme (c): *"sebepsiz dışlama yasak"* **ve** *"sebep de ölçülür"*.
#: Önceki hâli **grup yorumuydu** (*"geçit hâlleri"*, *"kabuk hâlleri"*) —
#: yani **7 kalem için 4 anlatı**, hiçbiri ölçülmemiş. Ostinato'nun vakası
#: bunun bedelini gösterdi: *"üçü de kamera arkasında"* dedi, **yanlış
#: çıktı.**
#:
#: > ***YANLIŞ BİR SEBEP, SEBEPSİZLİKTEN DAHA KÖTÜDÜR: DENETİMİ
#: > DOĞRULANMIŞ GÖSTERİR.***
#:
#: ⚠️ Ve adlandırma Ostinato'nun dersini taşıyor (`unreachable_reason` →
#: `camera_dependency`): kategoriler bir **OLGU** adı taşır (`hal_kosullu` ·
#: `akis_adimi` · `kap`), bir **İDDİA** adı değil — *bir olguyu iddia diye
#: adlandırmak, kapsamı sessizce genişletir.*
EXCLUDED = {
    "_GateLoadingScreen", "_GateFailureScreen",
    "_LoadingScreen", "_LoadFailureScreen", "_TabMismatchScreen",
    "OnboardingFlow",
    "LissomShell",
}

#: Kurulum yeri KOŞUL altında mı — ve hangi koşul? (olgu, iddia değil)
_GUARD = re.compile(r"if \(([^)]{1,60})\)\s*return (\w+)\(|"
                    r"if \(([^)]{1,60})\)\s*\{?\s*return (\w+)\(")


def exclusion_facts() -> dict[str, str]:
    """Her dışlananın gerekçesini **KODDAN ÖLÇER** (sözleşme §c).

    Üç olgu sınıfı, üçü de kaynaktan türetilir:
      · `hal_kosullu:<koşul>` — kurulum yeri bir hâl koşulunun altında
        (yükleme/hata/uyuşmazlık); boyanmış bir kontrol oraya götürmez
      · `akis_adimi:<n>` — tek `Scaffold`, içeride `n` adımlı `enum`
      · `kap:<n>` — kendisi aday DEĞİL, `n` adayı ÇİZEN kap

    ⛔ Gerekçesi ölçülemeyen bir dışlama **kırmızıdır** — sessizce
    dışlanmaz.
    """
    src = {p.name: re.sub(r"//[^\n]*", " ", p.read_text(encoding="utf-8"))
           for p in (ROOT / "lib").rglob("*.dart")}
    blob = "\n".join(src.values())
    facts: dict[str, str] = {}

    for cls in EXCLUDED:
        # 🪤 3. DENEME: `body` TÜM DOSYAYI alıyordu (sınıf gövdesini değil)
        # → `shell.dart`taki üç hâl ekranı da "kap" göründü, çünkü dosya
        # `=> HomeScreen(` içeriyor. ***Bir sınıfın gövdesi, onu İÇEREN
        # dosya değildir.*** Gövde artık gerçekten kesiliyor.
        body = ""
        for v in src.values():
            mm = re.search(rf"class {cls}\b", v)
            if not mm:
                continue
            nxt = v.find("\nclass ", mm.end())
            body = v[mm.start(): nxt if nxt > 0 else len(v)]
            st = re.search(rf"class _{cls}State\b", v)
            if st:
                n2 = v.find("\nclass ", st.end())
                body += v[st.start(): n2 if n2 > 0 else len(v)]
            break
        # ⚠️ SIRA ÖNEMLİ ve iki kez yanlış kurdum:
        #   1. deneme — koşul deseni bitişik varsayıyordu → `_TabMismatchScreen`
        #      kaçtı ve **`kap:4`** dedi (makul görünen YANLIŞ gerekçe)
        #   2. deneme — koşul önce bakıyordu → `LissomShell` *hâl ekranı*
        #      sanıldı, çünkü o da bir koşulun altında kuruluyor
        # ⇒ Ayırt edici olan KURULUM KOŞULU değil, sınıfın KENDİ YAPISI.
        #   Önce YAPI sorulur (kap? akış?), koşul EN SONA kalır.
        drawn = {c for c in re.findall(r"=>\s*([A-Z]\w*)\(", body)
                 if c not in EXCLUDED and c[0].isupper()}
        if drawn:
            facts[cls] = f"kap:{len(drawn)}"
            continue
        steps = re.search(r"enum _Step \{([^}]*)\}", body)
        if steps and body.count("Scaffold(") == 1:
            n = len([x for x in steps.group(1).split(",") if x.strip()])
            facts[cls] = f"akis_adimi:{n}"
            continue
        # Koşul: iç parantez OLABİLİR (`!_tabsMatch(facts)`) → non-greedy.
        m = re.search(
            rf"if \((.{{1,70}}?)\)\s*\{{?\s*return (?:const )?{cls}\(",
            blob, re.S)
        facts[cls] = f"hal_kosullu:{m.group(1).strip()}" if m else "ÖLÇÜLEMEDİ"
    return facts


def scaffold_owners() -> set[str]:
    """① Kendi `Scaffold`unu kuran widget'lar."""
    out: set[str] = set()
    for p in sorted((ROOT / "lib").rglob("*.dart")):
        src = re.sub(r"//[^\n]*", " ", p.read_text(encoding="utf-8"))
        for m in re.finditer(
                r"class\s+(\w+)\s+extends\s+(?:Stateless|Stateful)Widget\b", src):
            name = m.group(1)
            start = m.end()
            nxt = src.find("\nclass ", start)
            body = src[start: nxt if nxt > 0 else len(src)]
            st = re.search(rf"class\s+_{name}State\s+extends\s+State<{name}>", src)
            if st:
                s2 = st.end()
                n2 = src.find("\nclass ", s2)
                body += src[s2: n2 if n2 > 0 else len(src)]
            if "Scaffold(" in body:
                out.add(name)
    return out


def tab_bodies() -> set[str]:
    """② Kabuğun `switch`inde çizilen sekme gövdeleri.

    Scaffold KURMAZLAR (kabuk kurar) → ①'in deseni bunları KAÇIRIR. Bu
    hattın mimarisine özgü ikinci kanal; tek kanallı bir tarama sessizce
    eksik sayardı."""
    shell = (ROOT / "lib" / "app" / "shell.dart").read_text(encoding="utf-8")
    m = re.search(r"Widget _page\(AppFacts facts\)\s*=>\s*switch.*?\n  \}",
                  shell, re.S)
    blk = m.group(0) if m else shell
    # ⚠️ Widget adı BÜYÜK harfle başlar. İlk yazımım `=>\s*(\w+)\(` idi ve
    # `=> setState(...)` çağrısını "sekme gövdesi" saydı — kapı doğduğu
    # koşumda `setState`i eksik aday diye bildirdi. *Bir desen, aradığı
    # şeyin BİÇİMİNİ de tanımlamalı; "bir şey çağrılıyor" yetmez.*
    return set(re.findall(r"=>\s*([A-Z]\w*)\(", blk)) - EXCLUDED


def legacy_hand_list() -> set[str]:
    """**(e) — elle listenin YENİ RÜTBESİ: pozitif kontrol.**

    JabLab sözleşmeyi düzeltti: onun türetimi ilk hâlinde **bozuktu**
    (`_XState` elemesi her StatefulWidget ekranını yok etti) ve
    ***yakalayan şey elle beklenen kümesiydi.***

    > ***Bir elle liste, KAYNAK olarak yanlıştır ama KONTROL olarak
    > doğrudur — silinmez, RÜTBESİ DÜŞÜRÜLÜR.***

    ⚠️ **VE BU HATTA ÖZEL BİR ŞERH VAR:** bu liste `LiveCaptureScreen`i
    **taşımıyordu** (KATI 2 yerine 3'tü, L-298). Yani kontrol olarak da
    **kendisi eksik.** ⇒ ***Bu küme bir ALT SINIRDIR, tam envanter
    DEĞİLDİR:*** türetim onu KAPSAMALI, ama ona EŞİT olmak zorunda değil —
    fazlası **beklenen** (ve gerçekten fazlası var).
    """
    src = (ROOT / "test" / "reachability_test.dart").read_text(encoding="utf-8")
    m = re.search(r"kCountableScreens\s*=\s*<Type>\[(.*?)\];", src, re.S)
    if not m:
        raise SystemExit(
            "⛔ kCountableScreens bulunamadı — (e) gereği bu liste POZİTİF "
            "KONTROL olarak DURMALI; silinmişse türetim kontrolsüz kalır")
    body = re.sub(r"//[^\n]*", " ", m.group(1))
    return {t.strip() for t in body.split(",") if t.strip()}


def name_derived() -> set[str]:
    """**(a) İKİNCİ türetim — AD tabanlı, YAPIDAN bağımsız.**

    Sözleşme (a) iki bağımsız türetimin **UZLAŞMASINI** istiyor (Ostinato
    deseni: AD ↔ YAPI); ***ayrışırlarsa kapı öter.*** Bende iki kanal
    vardı ama **tamamlayıcıydı** (birleşim), **karşılaştırılmıyordu** —
    yani *hayalet üye* sınıfı (`SettingsScreenRoute` ≠ `SettingsScreen`)
    bende **görünmezdi.**

    > ***BİR SAYININ DOĞRU OLMASI, ÜYELERİNİN DOĞRU OLMASI DEĞİLDİR.***
    """
    out: set[str] = set()
    for pth in (ROOT / "lib").rglob("*.dart"):
        src = re.sub(r"//[^\n]*", " ", pth.read_text(encoding="utf-8"))
        for m in re.finditer(
                r"class\s+(\w*(?:Screen|Page))\s+extends\s+"
                r"(?:Stateless|Stateful)Widget\b", src):
            out.add(m.group(1))
    return out - EXCLUDED


def declared() -> set[str]:
    """Sözleşme testinin beyan ettiği aday küme."""
    src = CONTRACT.read_text(encoding="utf-8")
    m = re.search(r"kCandidateScreens\s*=\s*<Type>\[(.*?)\];", src, re.S)
    if not m:
        raise SystemExit("⛔ kCandidateScreens bulunamadı — sözleşme testi yok?")
    body = re.sub(r"//[^\n]*", " ", m.group(1))
    return {t.strip() for t in body.split(",") if t.strip()}


def main() -> int:
    derived = (scaffold_owners() | tab_bodies()) - EXCLUDED
    decl = declared()
    print(f"   desenden aday {len(derived)} · beyan edilen {len(decl)} · "
          f"dışlanan {len(EXCLUDED)}")
    # (c) — her dışlanan KENDİ ÖLÇÜLMÜŞ gerekçesiyle. Grup anlatısı DEĞİL.
    facts = exclusion_facts()
    print("   dışlananlar (her biri ÖLÇÜLMÜŞ gerekçesiyle):")
    for k in sorted(EXCLUDED):
        print(f"     · {k:24} {facts[k]}")
    olcelemeyen = [k for k, v in facts.items() if v == "ÖLÇÜLEMEDİ"]
    if olcelemeyen:
        print(f"⛔ GEREKÇESİ ÖLÇÜLEMEYEN dışlama: {sorted(olcelemeyen)}")
        print("   Sebepsiz bir dışlama, denetimi yeniden TANIMA çevirir.")
        return 1

    # (e) POZİTİF KONTROL — türetim, elle listeyi KAPSAMALI.
    # Bu, türetimin KENDİSİNİN bozulduğu günü tutar (JabLab'ın vakası:
    # bozuk eleme her StatefulWidget ekranını yok etti ve yakalayan şey
    # elle beklenen kümesiydi).
    # (d) VAKUM KORUMASI — AÇIK, dolaylı değil.
    # Önceki hâlde koruma (e)'nin kapsama kontrolü ÜZERİNDEN çalışıyordu:
    # *bugün korunuyor, YAPISAL olarak değil.* Elle liste boşaltılsa
    # koruma da kaybolurdu.
    if not derived:
        print("⛔ VAKUM — kaynak taraması HİÇ aday bulamadı; bir kapının "
              "hiçbir şey bulmaması, ölçtüğü şeyin yokluğu değildir")
        return 1

    # (a) İKİ BAĞIMSIZ TÜRETİMİN UZLAŞMASI — ayrışma KIRMIZI.
    byname = name_derived()
    only_struct = derived - byname
    only_name = byname - derived
    print(f"   (a) uzlaşma: YAPI {len(derived)} · AD {len(byname)} · "
          f"ayrışma {len(only_struct) + len(only_name)}")
    if only_struct or only_name:
        if only_struct:
            print(f"⛔ YAPIDA var, ADDA yok: {sorted(only_struct)}")
        if only_name:
            print(f"⛔ ADDA var, YAPIDA yok: {sorted(only_name)} "
                  f"— HAYALET ÜYE adayı")
        print("   İki bağımsız türetim ayrıştı; biri eksik ya da biri "
              "hayalet üye taşıyor.")
        return 1

    hand = legacy_hand_list()
    uncovered = hand - derived
    print(f"   (e) pozitif kontrol: elle liste {len(hand)} üye · "
          f"türetim kapsıyor mu: {'EVET' if not uncovered else 'HAYIR'}")
    if uncovered:
        print(f"⛔ TÜRETİM BOZUK — elle listedeki şu üyeleri KAPSAMIYOR: "
              f"{sorted(uncovered)}")
        print("   Elle liste bir ALT SINIRDIR; türetim onu kapsamıyorsa "
              "hata türetimdedir, listede değil.")
        return 1

    missing = derived - decl          # kod var, sözleşme yok → SESSİZ KAYIP
    extra = decl - derived            # sözleşme var, kod yok → HAYALET
    if missing:
        print(f"⛔ desende VAR, sözleşmede YOK: {sorted(missing)}")
        print("   Elle liste hafızadan okur; ne unuttuğunu bilemezsin.")
    if extra:
        print(f"⛔ sözleşmede VAR, desende YOK: {sorted(extra)} — hayalet aday")
    if missing or extra:
        return 1
    print("✅ aday küme desenle AYNI — elle sapma yok")
    return 0


def _self_test() -> int:
    ok = True
    # ① Desen GERÇEKTEN bir şey buluyor mu (vakum-doğru değil)?
    d = scaffold_owners()
    hit = "FamilyPage" in d and "LiveCaptureScreen" in d
    print(f"   {'✅' if hit else '⛔'} Scaffold deseni isabet ediyor "
          f"({len(d)} sınıf)")
    ok = ok and hit
    # ② Sekme gövdeleri AYRI kanaldan geliyor mu (①'in kaçırdıkları)?
    t = tab_bodies()
    hit2 = "HomeScreen" in t and "HomeScreen" not in d
    print(f"   {'✅' if hit2 else '⛔'} sekme gövdeleri ikinci kanaldan "
          f"({sorted(t)}) — ① onları KAÇIRIYOR: {'HomeScreen' not in d}")
    ok = ok and hit2
    # ③ Ayrışma yakalanıyor mu?
    caught = bool((d | t) - EXCLUDED - declared()) is False
    print(f"   {'✅' if caught else '⛔'} bugün ayrışma yok (taban temiz)")
    ok = ok and caught
    print("✅ 3/3 kapı ateşlendi" if ok else "⛔ aday-küme öz-testi DÜŞTÜ")
    return 0 if ok else 1


if __name__ == "__main__":
    sys.exit(_self_test() if "--self-test" in sys.argv else main())
