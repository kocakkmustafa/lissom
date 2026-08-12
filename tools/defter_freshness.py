#!/usr/bin/env python3
"""DEFTER TAZELİĞİ — **İKİ YÖNLÜ** (L-294 · iki yön L-311)

    YÖN-1  commit → defter : commit'in iddia ettiği her kayıt defterde mi?
    YÖN-2  defter → commit : **kod ürettiğini söyleyen** her kaydın izi var mı?

⛔ **YÖN-2 ham hâliyle KURULAMAZ.** *"Defterdeki her kayıt commit'li olmalı"*
ölçüldü: **262 sahte gedik** — çünkü kayıtların çoğu meşru olarak commit'sizdir
(ölçüm · analiz · reddedilmiş yol · karar). Kapı doğduğu gün susturulurdu
(Gravita'nın 47 yanlış pozitifiyle aynı sınıf). Birim üç kez daraltıldı ve her
adım ölçüldü — `kod_iddia_eden()`in dokümanına bak.

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

#: **GENİŞ OKUYUCU (L-311).** `_SUBJECT` bu deponun TEK yazım biçimi değil:
#: erken commit'ler numarayı **konuya değil kuyruğa** yazmış
#: (`feat(live): … — L-208`). Ölçüldü (187 commit): kapsamda **47** ·
#: **başlıkta herhangi bir yerde 109** (= YÖN-1 okuyucusu) ·
#: başlık+gövdede **195** (= YÖN-2 okuyucusu, `commit_trace`).
#:
#: > ***BİR SAYACIN GÖRDÜĞÜ ŞEY, BAKTIĞI DİZGE KADARDIR*** (M-F-588) — ve
#: > bu kapı 139 numarayı görmediği için **gerçek bir gediği kaçırmıştı**
#: > (`L-208`: iki commit iddia etti, defterde YOK).
#:
#: ⚠️ **Sınır koruması ZORUNLU:** çıplak `\bL-\d+` aile kayıtlarının içine
#: düşüyor (`M-L-01` → `L-01`) ve **var olmayan bir numara** uyduruyordu.
#: Önündeki `-`/harf/rakam reddedilir.
_WIDE = re.compile(r"(?<![-A-Za-z0-9])(L-\d+)\b")
#: `— L-208..211` aralığı: baştaki numara `_WIDE`ye takılır, **kalanı
#: görünmez**. Aralık AÇILIR, yoksa commit iddia ettiği kaydın üçte ikisini
#: sayaca hiç göstermez.
_RANGE = re.compile(r"(?<![-A-Za-z0-9])L-(\d+)\.\.(\d+)\b")
#: Defterdeki gerçek kayıt — İKİ biçim, ÖLÇÜLDÜ (yukarıdaki tablo).
#: Satır başındaki çıplak `L-NNN` KASITLA dışarıda: 7'sinin de atıf olduğu
#: tek tek okundu.
_ENTRY = re.compile(r"^(?:#+ |\| )(L-\d+)\b", re.M)


def commit_ids(limit: int = 400) -> tuple[list[str], int]:
    """Commit'lerin iddia ettiği kayıt numaraları — **GENİŞ** okuyucuyla.

    `_SUBJECT` (conventional kapsam) tek başına bırakıldı mı 139 numara
    görünmez oluyor; ölçümü modül başındaki `_WIDE` notunda.
    """
    subjects = subprocess.run(
        ["git", "-C", str(ROOT), "log", f"-{limit}", "--format=%s"],
        capture_output=True, text=True, check=True).stdout
    ids = list(_WIDE.findall(subjects))
    for lo, hi in _RANGE.findall(subjects):
        w = len(lo)
        ids += [f"L-{n:0{w}d}" for n in range(int(lo), int(hi) + 1)]
    return ids, len(subjects.splitlines())


def commit_trace(limit: int = 400) -> set[str]:
    """**YÖN-2'nin okuyucusu — BAŞLIK + GÖVDE, ve ayrım GEREKÇELİ.**

    İki yön aynı dizgeye bakmaz, çünkü **iki farklı soru soruyorlar:**

    · **YÖN-1 = İDDİA.** *"Bu commit hangi kaydı yaptığını söylüyor?"*
      Cevabı yalnız **başlıktır**; gövde anlatıdır ve bir numaradan söz
      etmek onu yapmak değildir. (Defter tarafındaki `Kapanış kanıtı` ↔
      gövde ayrımının **birebir aynası**.)
    · **YÖN-2 = İZ.** *"Bu kaydın git'te herhangi bir izi var mı?"*
      Burada gövdedeki bir anma da **izdir** — soru sahiplik değil varlık.

    🪤 **Ve bu ayrım ÖDENEREK öğrenildi:** tek okuyucu (başlık+gövde) iki
    yönde birden kullanılınca, `L-311`in commit **gövdesinde** geçen
    sentetik `L-000` YÖN-1'de bir **iddia** sayıldı ve kapı, hiç var
    olmayan bir kaydı arayarak kırmızı yandı — *kendi commit mesajının
    ürettiği gedik*.

    > ***SÖZÜNÜ ETMEK ≠ İDDİA ETMEK — VE BU KURAL, KAPIYI GENİŞLETİRKEN
    > EN KOLAY UNUTULAN YERDE, GÖVDEDE ÇİĞNENİR.***
    """
    out = subprocess.run(
        ["git", "-C", str(ROOT), "log", f"-{limit}", "--format=%s%n%b"],
        capture_output=True, text=True, check=True).stdout
    ids = set(_WIDE.findall(out))
    for lo, hi in _RANGE.findall(out):
        w = len(lo)
        ids |= {f"L-{n:0{w}d}" for n in range(int(lo), int(hi) + 1)}
    return ids


#: Kod dosyası — **`.md` KASITLA DIŞARIDA.** Bir ölçüm kaydı kanıtını
#: `docs/…md`ye yazar; onu "kod değişikliği" saymak ölçümü koda çevirir ve
#: ters yön **99 sahte gedik** verir (ölçüldü, L-311).
_CODE = re.compile(r"[A-Za-z0-9_./-]+\.(?:dart|py|kts|plist|pbxproj|yaml)\b")


def _tracked() -> set[str]:
    return set(subprocess.run(["git", "-C", str(ROOT), "ls-files"],
                              capture_output=True, text=True,
                              check=True).stdout.split())


def _entry_spans(text: str) -> list[tuple[str, list[str]]]:
    """Her kaydın (numara, gövde satırları) çifti — bir sonraki kayda kadar."""
    lines = text.splitlines()
    heads = [(m.group(1), i) for i, ln in enumerate(lines)
             if (m := re.match(r"^(?:#+ |\| )(L-\d+)\b", ln))]
    out: list[tuple[str, list[str]]] = []
    for k, (eid, i) in enumerate(heads):
        j = heads[k + 1][1] if k + 1 < len(heads) else len(lines)
        out.append((eid, lines[i:j]))
    return out


def kod_iddia_eden(text: str, tracked: set[str]) -> set[str]:
    """**TERS YÖNÜN BİRİMİ (L-311): "kod değişikliği İDDİA EDEN" kayıt.**

    ⛔ Ham ters yön (*"defterdeki her kayıt commit'li olmalı"*) **262 sahte
    gedik** üretir ve kapı **doğduğu gün susturulur**: defter kayıtlarının
    çoğu meşru olarak commit'sizdir — ölçüm · analiz · reddedilmiş yol ·
    karar kaydı. Hiçbiri kod değişikliği değil.

    Birim üç kez daraltıldı, her adım ÖLÇÜLDÜ:
      · defterdeki her kayıt ................. 262 gedik  ⛔ anlamsız
      · gövdesinde repo dosyası ANAN kayıt .... 99 gedik  ⛔ hâlâ gürültü
      · **`Kapanış kanıtı` alanı repo KOD dosyası anan kayıt** ... **6**

    Son daraltmanın gerekçesi yapısal: `Kapanış kanıtı` alanı kaydın
    *"ne ürettim"* beyanıdır. Bir ölçüm kaydı oraya çıktı yazar
    (`/tmp/gate_after.json`, *"kod okuması"*); bir kod kaydı **repo yolu**
    yazar. Gövdenin geri kalanı ise ANLATIDIR ve bir dosyadan söz etmek onu
    değiştirmek değildir — *sözünü etmek ≠ iddia etmek*, kapının kendi
    kuralının defter tarafındaki karşılığı.
    """
    out: set[str] = set()
    for eid, body in _entry_spans(text):
        head = body[0]
        if head.startswith("| "):
            cols = [c.strip() for c in head.split("|")[1:-1]]
            ev = cols[-1] if cols else ""
        else:
            m = re.search(r"\*\*Kapanış kanıtı:?\*\*:?(.{0,400})",
                          "\n".join(body), re.S)
            ev = m.group(1) if m else ""
        if not ev.strip():
            continue
        hits = {h.lstrip("./") for h in _CODE.findall(ev)}
        if any(t == h or t.endswith("/" + h) for h in hits for t in tracked):
            out.add(eid)
    return out


#: **TAŞINAN KALINTI — SAYILI muafiyet (L-311, ölçüldü 2026-08-13).**
#: `Kapanış kanıtı`nda repo kod dosyası anan ama commit izi olmayan 6 kayıt.
#: ⛔ Bunlar bir hedef değil bir **TABAN**: kapı **BÜYÜMEYİ** yakalar.
#: *Muafiyet bir kapı değil, bir SAYIDIR* (`BILINEN_CAKISMA` ile aynı idiom).
IZSIZ_KOD_KAYITLARI = {"L-053", "L-159", "L-213", "L-215", "L-216", "L-218"}


def _num(eid: str) -> int:
    return int(eid.split("-")[1])


def ters_yon(text: str) -> tuple[list[str], int, int]:
    """(YENİ izsiz kayıtlar, kod iddia eden toplam, taşınan kalıntı).

    🪤 **UÇUŞTAKİ KAYIT — kapı kendi commit'ini kilitliyordu (ölçüldü).**
    İlk yazımda bu kontrol, yazıldığı turun kaydının (`L-311`) kendisinde
    ötüyordu: kayıt deftere yazılır, commit **onun izini taşıyacaktır**, ama
    `pre-commit` kancası commit **var olmadan** koşar ⇒ kapı, izini
    üretecek olan commit'i **engelliyordu.**

    > ***BİR KAPI, KENDİ KANITINI ÜRETECEK ADIMI ENGELLİYORSA, ÖLÇMÜYOR
    > DEMEKTİR — YASAKLIYORDUR.***

    Çözüm bir muafiyet değil bir **sıra kuralı**: izlenen en yüksek
    numaradan **sonraki** kayıtlar *uçuşta* sayılır. Kural kendini
    zayıflatmıyor: uçuştaki kayıtları commit'lemeden **bir sonraki** kaydı
    commit'lersen taban yükselir ve **hepsi birden gedik olur** — yani
    biriktirme davranışı tam olarak yakalanır, yalnız **anlık** olan
    affedilir.
    """
    tracked = _tracked()
    claims = kod_iddia_eden(text, tracked)
    trace = commit_trace()
    tavan = max((_num(i) for i in trace), default=0)
    izsiz = {c for c in claims - trace if _num(c) <= tavan}
    ucusta = sorted(claims - trace - izsiz, key=_num)
    if ucusta:
        print(f"   [YÖN-2] uçuşta {len(ucusta)}: {', '.join(ucusta)} "
              f"(izlenen tavan L-{tavan}) — commit izini bu tur üretecek")
    yeni = sorted(izsiz - IZSIZ_KOD_KAYITLARI, key=_num)
    return yeni, len(claims), len(izsiz)


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


#: Kapalılığı SAYAN jetonlar — `defter_status_check` bunlara bakar.
_KAPALI = re.compile(r"kapal[ıi]|kapand[ıi]|çözüldü|düzeltildi", re.IGNORECASE)


def reddedildi_capasi() -> list[str]:
    """**ÇAPA (L-305): ayırt edici kelime, SAYAN kelimeyi silmemeli.**

    2026-08-12'de `Durum` sütununu `REDDEDİLDİ — …` yaptım ve `kapalı`
    jetonunu **yerinden ettim**: kapalı sayısı **178 → 173** düştü, beş
    kayıt kümeden **sessizce** çıktı, ve ***hiçbir kapı ötmedi.***

    > ***BİR KUSUR, İYİLEŞTİRME KILIĞINDA GELDİĞİNDE HİÇBİR KAPI ÖTMEZ —
    > çünkü kapılar KÖTÜLEŞMEYİ arar, DEĞİŞİMİ değil.***

    Bu çapa o yolu kapatıyor: `REDDEDİLDİ` içeren her `Durum` hücresi,
    kapalılığı sayan jetonlardan **en az birini** de taşımalı.
    """
    bad: list[str] = []
    for ln in defter_text().splitlines():
        m = re.match(r"^\| (L-\d+) \|", ln)
        if not m:
            continue
        cols = [c.strip() for c in ln.split("|")[1:-1]]
        if len(cols) < 6:
            continue
        durum = cols[-2] if len(cols) > 6 else cols[4]
        if "REDDEDİLDİ" in durum and not _KAPALI.search(durum):
            bad.append(m.group(1))
    return bad


#: ⚠️ BİLİNEN ÇAKIŞMA — SAYILI ve GEREKÇELİ muafiyet (L-305).
#: Bu üç numara defterde İKİŞER kez geçiyor. ⛔ **Yeniden numaralandırma
#: YOK**: ***bir numarayı değiştirmek, ona işaret eden HER atfı sessizce
#: yanlış yapar*** — ve atıf, iddiadan daha sessiz bozulur (M-F-529).
#: Çözülemeyen bir çakışma, ***çözülemez olduğu BİLİNEREK*** taşınır.
BILINEN_CAKISMA = {"L-089", "L-090", "L-187"}


def id_cakismasi() -> list[str]:
    """**YENİ** çakışma imkânsız: `satır sayısı == benzersiz ID`.

    Bilinen üç çakışma muaf — ama **sayılı**: muafiyet büyürse kapı öter,
    yani *muafiyet bir kapı değil, bir SAYIDIR.*
    """
    ids = re.findall(r"^\| (L-\d+) \|", defter_text(), re.M)
    seen, dup = set(), set()
    for i in ids:
        (dup if i in seen else seen).add(i)
    return sorted(dup - BILINEN_CAKISMA)


def run() -> int:
    missing, scanned, claimed, recorded = gap()
    print(f"   taranan commit {scanned} · commit'in İDDİA ettiği kayıt "
          f"{claimed} · defterde {recorded}")
    yeni_cakisma = id_cakismasi()
    if yeni_cakisma:
        print(f"⛔ YENİ ID ÇAKIŞMASI: {', '.join(yeni_cakisma)} — bir atıf "
              f"iki kayda çözülür. (Bilinen 3 muaf, SAYILI.)")
        return 1

    reddet = reddedildi_capasi()
    if reddet:
        print(f"⛔ ÇAPA — `REDDEDİLDİ` yazan ama SAYAN jetonu taşımayan "
              f"{len(reddet)} kayıt: {', '.join(reddet)}")
        print("   Ayırt edici kelime, sayan kelimeyi SİLMEMELİ (L-305).")
        return 1

    if missing:
        print(f"⛔ DEFTER GEDİĞİ [YÖN-1] — {len(missing)} kayıt commit'te VAR, "
              f"defterde YOK: {', '.join(missing)}")
        print("   Bir işin YAPILMIŞ olması, KAYDEDİLMİŞ olması değildir.")
        return 1

    # YÖN-2 (L-311): defter → commit. Payda ve İŞLEM her zaman yazılı.
    yeni, iddia, kalinti = ters_yon(defter_text())
    print(f"   [YÖN-2] kod iddia eden kayıt {iddia} · izsiz {kalinti} "
          f"(taşınan taban {len(IZSIZ_KOD_KAYITLARI)}, SAYILI)")
    if yeni:
        print(f"⛔ DEFTER GEDİĞİ [YÖN-2] — {len(yeni)} kayıt KOD ürettiğini "
              f"söylüyor ama commit izi YOK: {', '.join(yeni)}")
        print("   Bir kaydın YAZILMIŞ olması, işin COMMIT'LENMİŞ olması "
              "değildir — ve `Kapanış kanıtı` bir repo dosyasıysa iddia KODDUR.")
        return 1
    if kalinti < len(IZSIZ_KOD_KAYITLARI):
        print(f"   ℹ️ taban KÜÇÜLDÜ ({len(IZSIZ_KOD_KAYITLARI)} → {kalinti}) "
              f"— IZSIZ_KOD_KAYITLARI güncellenebilir")
    print("✅ defter TAZE — İKİ YÖNDE de gedik yok")
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

    # ④ GENİŞ OKUYUCUNUN SINIRI (L-311) — aile kaydı sızmamalı.
    #   `M-L-01` içindeki `L-01` sızsaydı kapı **var olmayan bir numarayı**
    #   arayıp sonsuza dek kırmızı yanardı; ve bu gerçekten oldu.
    dirty = _WIDE.findall("M-L-01 · M-F-588 · J-163 — ama L-208 gerçek")
    clean = dirty == ["L-208"]
    print(f"   {'✅' if clean else '⛔'} geniş okuyucu aile kaydına "
          f"{'SIZMIYOR' if clean else f'SIZDI: {dirty}'}")
    ok = ok and clean
    fired += 1

    # ⑤ ARALIK AÇILIYOR — `L-208..211` üç kaydı da göstermeli.
    rng = sorted({f"L-{n:03d}" for lo, hi in _RANGE.findall("bkz L-208..211")
                  for n in range(int(lo), int(hi) + 1)})
    spread = rng == ["L-208", "L-209", "L-210", "L-211"]
    print(f"   {'✅' if spread else '⛔'} aralık gösterimi "
          f"{'açılıyor' if spread else f'AÇILMADI: {rng}'}")
    ok = ok and spread
    fired += 1

    # ⑥ TERS YÖNÜN BİRİMİ — `.md` kanıtı KOD sayılmamalı, `.dart` sayılmalı.
    #   Bu ayrım ölçümde 99 ↔ 6 farkını üretti; ölmesi sessiz olurdu.
    tr = {"lib/app/home_screen.dart", "docs/PRD.md"}
    olcum = kod_iddia_eden(
        "| L-901 | ölçüm | P1 | x | kapalı | Ölçüm tablosu: `docs/PRD.md` |",
        tr)
    kod = kod_iddia_eden(
        "| L-902 | çözüm | P1 | x | kapalı | `lib/app/home_screen.dart` |", tr)
    unit = olcum == set() and kod == {"L-902"}
    print(f"   {'✅' if unit else '⛔'} ters yön birimi: doküman kanıtı "
          f"{'KOD SAYILMIYOR' if unit else f'AYRIM YOK ({olcum}/{kod})'}")
    ok = ok and unit
    fired += 1

    # ⑦ TERS YÖN GERÇEKTEN ÖTEBİLİYOR MU — sentetik izsiz kayıt.
    #   ⛔ Bir öz-test *"bugün 0"* demekle yetinirse, kapının ötme YETENEĞİ
    #   hiç sınanmamış olur (M-F-58 dördüncü canlılık sorusu).
    sahte = ("| L-903 | çözüm | P1 | x | kapalı | `lib/app/home_screen.dart` |")
    izsiz = kod_iddia_eden(sahte, tr) - commit_trace()
    fires = izsiz == {"L-903"} and "L-903" not in IZSIZ_KOD_KAYITLARI
    print(f"   {'✅' if fires else '⛔'} ters yön sentetik izsiz kaydı "
          f"{'YAKALIYOR' if fires else 'YAKALAMIYOR — SAHTE KAPI'}")
    ok = ok and fires
    fired += 1

    # ⑧ UÇUŞTAKİ KAYIT AFFEDİLİR, BİRİKEN AFFEDİLMEZ.
    #   İki senaryo AYNI fonksiyonla sınanır: tavanın ÜSTÜ (uçuşta, sessiz)
    #   ↔ tavanın ALTI (gedik, ötüyor). Yalnız birincisini sınamak, kapının
    #   affı öğrenip yakalamayı unuttuğu hâli göremezdi.
    ids = commit_trace()
    tavan = max((_num(i) for i in ids), default=0)
    # 🪤 **İKİ KEZ ÖDENDİ, ve ikincisi birincinin çaresini çürüttü.**
    #   ① "tavan altı" için `L-{tavan-5}` yazdım — o numara GERÇEKTEN
    #      commit'liydi ⇒ küme boş, sınav **vakum-doğru**, kapı kendini
    #      "sahte" sandı.
    #   ② Çare diye `L-000` sabitledim — sonra o numarayı bir **commit
    #      mesajında** andım ve YÖN-2 okuyucusu (gövdeyi de tarar) onu
    #      **ize** çevirdi. Sabit sentetik girdi, ölçtüğü dünyaya sızdı.
    #
    #   > ***BİR ÖZ-TESTİN SENTETİK GİRDİSİ ELLE SEÇİLEMEZ: ÖLÇTÜĞÜ
    #   > KÜMEDEN TÜRETİLMEZSE, ER GEÇ O KÜMENİN ÜYESİ OLUR.***
    kullanilmis = {_num(i) for i in ids}
    bos = [k for k in range(1, tavan + 1) if k not in kullanilmis]
    if not bos:
        print("   ⛔ uçuş kuralı sınanamadı — tavan altında BOŞ numara yok")
        return 1
    ust, alt = f"L-{tavan + 5}", f"L-{max(bos):03d}"
    tr2 = {"lib/app/home_screen.dart"}
    row = "| {} | çözüm | P1 | x | kapalı | `lib/app/home_screen.dart` |"
    ucus_ok = kod_iddia_eden(row.format(ust), tr2) - set(ids) == {ust}
    yeni_ust, _, _ = ters_yon(row.format(ust))
    yeni_alt, _, _ = ters_yon(row.format(alt))
    sira = ucus_ok and yeni_ust == [] and yeni_alt == [alt]
    print(f"   {'✅' if sira else '⛔'} uçuş kuralı: tavan üstü "
          f"{'AFFEDİLİYOR' if yeni_ust == [] else 'ÖTTÜ'} · tavan altı "
          f"{'ÖTÜYOR' if yeni_alt == [alt] else 'SESSİZ — SAHTE KAPI'}")
    ok = ok and sira
    fired += 1

    print(f"✅ {fired}/{fired} kapı ateşlendi" if ok
          else "⛔ defter tazeliği öz-testi DÜŞTÜ")
    return 0 if ok else 1


if __name__ == "__main__":
    # ⚠️ **ÖZ-TEST VARSAYILANDA KOŞAR (L-311).** `all_gates.py` kapıları
    # ARGÜMANSIZ çağırıyor (`_run([sys.executable, str(g)], ROOT)`), yani
    # `--self-test` arkasına saklanan her kontrol **tam cümleye hiç
    # girmiyordu**. Bu turda öz-test 4→8 kontrole çıktı; onları bayrak
    # arkasında bırakmak, *"kapıyı güçlendirdim"* diyip güçlendirmenin
    # koşmadığı yerde durmak olurdu.
    #
    # > ***BAYRAK ARKASINDAKİ BİR ÖZ-TEST, VARSAYILAN KOŞUMDA OLMAYAN BİR
    # > ÖZ-TESTTİR.***
    #
    # Sıra da anlamlı: önce kapının KENDİSİ sınanır, sonra ölçüm yapılır —
    # kırık bir aletle alınan temiz ölçüm, ölçüm değildir.
    if "--self-test" in sys.argv:
        sys.exit(_self_test())
    rc = _self_test()
    sys.exit(rc or run())
