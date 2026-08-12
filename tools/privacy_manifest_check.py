#!/usr/bin/env python3
"""GİZLİLİK MANİFESTİ KAPISI (L-288).

`PrivacyInfo.xcprivacy` 2024'ten beri App Store'da zorunlu; yokluğu bir RET
sebebi. Ama bu kapının asıl derdi dosyanın VARLIĞI değil:

    ***Bir manifest, Xcode projesine BAĞLI DEĞİLSE pakete GİRMEZ.***

Dosya depoda durur, `git` mutlu, kimse fark etmez — ve mağaza yine reddeder.
Bu, bu hattın bugün üç kez gördüğü sınıfın (yapılmış yol / rampası yok) iOS
paketleme katmanındaki hâli. O yüzden kapı DÖRT atfın dördünü de arar:
PBXBuildFile · PBXFileReference · grup çocuğu · Resources fazı.

Ayrıca beyanın KENDİSİ sınanır: gerekçeli-API listesi doluysa, boş olduğunu
söyleyen ölçüm bayatlamış demektir (bu kapı listeyi DOĞRULAMAZ, yalnız
"beyan ile ölçüm birlikte yaşasın" der).
"""
from __future__ import annotations

import plistlib
import sys
from pathlib import Path

REPO = Path(__file__).resolve().parents[1]
MANIFEST = REPO / "ios" / "Runner" / "PrivacyInfo.xcprivacy"
PBXPROJ = REPO / "ios" / "Runner.xcodeproj" / "project.pbxproj"

REQUIRED_KEYS = (
    "NSPrivacyTracking",
    "NSPrivacyTrackingDomains",
    "NSPrivacyCollectedDataTypes",
    "NSPrivacyAccessedAPITypes",
)


def check(manifest_bytes: bytes | None, pbx: str) -> list[str]:
    problems: list[str] = []

    if manifest_bytes is None:
        problems.append(
            f"{MANIFEST.relative_to(REPO)} YOK — App Store 2024'ten beri "
            "zorunlu tutuyor, yokluğu RET sebebi"
        )
        return problems

    try:
        data = plistlib.loads(manifest_bytes)
    except Exception as e:  # noqa: BLE001 — sebebi isimle raporlanacak
        problems.append(f"manifest ayrıştırılamıyor ({e}) — bozuk plist paketlenemez")
        return problems

    for k in REQUIRED_KEYS:
        if k not in data:
            problems.append(f"manifest `{k}` anahtarını TAŞIMIYOR")

    # ⭐ ASIL SORU: pakete giriyor mu?
    #
    # 🪤 Ham `count()` KULLANILMIYOR: bir satır dizgeyi İKİ kez taşıyabilir
    # (`PBXBuildFile` satırı hem adı hem `fileRef` yorumunu içerir), yani
    # "6/4 bağlı" gibi anlamsız bir sayı üretirdi. *Bir kapının raporladığı
    # sayı, neyin sayısı olduğu belli değilse kapıyı da yanıltır.*
    # Onun yerine DÖRT YAPISAL ÇAPA ayrı ayrı aranıyor.
    lines = [l for l in pbx.splitlines() if "PrivacyInfo.xcprivacy" in l]
    anchors = {
        "PBXBuildFile girdisi": any(
            "isa = PBXBuildFile" in l and "fileRef" in l for l in lines
        ),
        "PBXFileReference girdisi": any(
            "isa = PBXFileReference" in l for l in lines
        ),
        "Runner grubu çocuğu": any(
            l.strip().endswith("*/,") and "isa =" not in l
            and "in Resources" not in l for l in lines
        ),
        "Resources build fazı": any("in Resources */," in l for l in lines),
    }
    missing = [name for name, ok in anchors.items() if not ok]
    if missing:
        problems.append(
            "manifest Xcode projesine TAM bağlı değil — eksik çapa(lar): "
            + ", ".join(missing)
            + ". Dosya depoda durur ama PAKETE GİRMEZ ve mağaza yine "
            "reddeder (yapılmış yol / rampası yok)"
        )
    return problems


def _self_test() -> None:
    """Kapının yakaladığını iddia ettiği kusurları GERÇEKTEN yakaladığı."""
    good = plistlib.dumps({k: [] if "Types" in k or "Domains" in k else False
                           for k in REQUIRED_KEYS})
    # GERÇEK pbxproj biçiminin dört çapası (JabLab'ın dosyasından alındı,
    # uydurulmadı) — sahte bir dizi kullansaydık kapı gerçeğin reddedeceği
    # bir girdiyi kabul ederdi (test-double gerçeğin kuralını uygulamaz).
    wired = (
        "\t\t9F1PRIV0002 /* PrivacyInfo.xcprivacy in Resources */ = "
        "{isa = PBXBuildFile; fileRef = 9F1PRIV0001 /* PrivacyInfo.xcprivacy */; };\n"
        "\t\t9F1PRIV0001 /* PrivacyInfo.xcprivacy */ = {isa = PBXFileReference; "
        'lastKnownFileType = text.plist.xml; path = PrivacyInfo.xcprivacy; '
        'sourceTree = "<group>"; };\n'
        "\t\t\t\t9F1PRIV0001 /* PrivacyInfo.xcprivacy */,\n"
        "\t\t\t\t9F1PRIV0002 /* PrivacyInfo.xcprivacy in Resources */,\n"
    )
    assert not check(good, wired), "ÖZ-TEST: sağlam hâl kırmızı yandı"

    assert check(None, wired), "ÖZ-TEST: eksik manifest yakalanmadı"

    # ⭐ En önemlisi: dosya VAR ama projeye BAĞLI DEĞİL.
    assert check(good, "hiç atıf yok"), (
        "ÖZ-TEST: bağlanmamış manifest GEÇTİ — kapının bütün sebebi buydu"
    )

    # Bozuk plist
    assert check(b"<plist bozuk", wired), "ÖZ-TEST: bozuk plist yakalanmadı"

    # Eksik anahtar
    partial = plistlib.dumps({"NSPrivacyTracking": False})
    assert check(partial, wired), "ÖZ-TEST: eksik anahtar yakalanmadı"
    print("  öz-test: 5/5 ✅")


def main() -> int:
    _self_test()
    blob = MANIFEST.read_bytes() if MANIFEST.exists() else None
    if not PBXPROJ.exists():
        print(f"⛔ {PBXPROJ.relative_to(REPO)} yok")
        return 1
    problems = check(blob, PBXPROJ.read_text())
    if problems:
        print("⛔ GİZLİLİK MANİFESTİ KAPISI — kırmızı:")
        for p in problems:
            print(f"   · {p}")
        return 1
    print("✅ gizlilik manifesti: var, geçerli, ve Xcode projesine 4/4 bağlı")
    return 0


if __name__ == "__main__":
    sys.exit(main())
