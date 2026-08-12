#!/usr/bin/env python3
"""RELEASE İMZASI KAPISI (L-286) — debug anahtarına SESSİZ düşüş yasak.

Ölçüm (yayın-engeli turu, 2026-08-12): `android/app/build.gradle.kts`
release'i **debug anahtarlarıyla** imzalıyordu, `TODO` duruyordu, ve kusur
**08-07 engel listesinde HİÇ YOKTU** — çünkü derleme BAŞARILI oluyor. Kusur
ancak **Play reddedince** görünürdü.

Bu kapı Gradle'ın kendi gürültülü hatasını KORUR: koruma silinip eski
sessiz varsayılana dönülürse, `all_gates.py` **burada** kırmızı yanar —
yani kusur bir mağaza reddiyle değil, bir commit denemesiyle yakalanır.

⚠️ Bu kapı imza ÜRETMEZ ve keystore ARAMAZ. Keystore kurucunun kalemidir ve
workspace'te DURMAZ (`~/.secrets/yula/`). Kapının sorusu tek: *release,
imzasızken SESSİZCE üretilebiliyor mu?*
"""
from __future__ import annotations

import re
import sys
from pathlib import Path

REPO = Path(__file__).resolve().parents[1]
GRADLE = REPO / "android" / "app" / "build.gradle.kts"


def check(src: str) -> list[str]:
    """Kusurları döndürür; boş liste = geçti."""
    problems: list[str] = []

    # Yorumları düş — bir kuralın YORUMDA geçmesi onu uygulamaz
    # (L-273'ün dersi: kelimenin varlığı, çağrının çalıştığı değildir).
    code = re.sub(r"//[^\n]*", " ", src)

    # ① Koşulsuz debug imzası: `signingConfig = signingConfigs.getByName("debug")`
    #    release bloğunda, hiçbir dal/koşul olmadan duruyorsa SESSİZ DÜŞÜŞTÜR.
    m = re.search(r"release\s*\{(.*?)\n\s{8}\}", code, re.S)
    if m is None:
        problems.append(
            "`release { … }` bloğu bulunamadı — kapı ölçemediği bir şeyi "
            "geçirmez (yapı değiştiyse kapı da güncellenmeli)"
        )
        return problems

    block = m.group(1)
    has_debug = 'signingConfigs.getByName("debug")' in block
    has_guard = "GradleException" in block
    has_optin = "allowDebugSigning" in block

    if has_debug and not has_guard:
        problems.append(
            "release bloğu debug anahtarlarıyla imzalıyor ve GÜRÜLTÜLÜ bir "
            "durdurucu (GradleException) YOK → imzasız bir AAB SESSİZCE "
            "üretilir ve Play REDDEDER (L-286)"
        )
    if has_debug and not has_optin:
        problems.append(
            "debug imzasına düşüş açık bir KARAR olmalı "
            "(`-PallowDebugSigning`), sessiz bir VARSAYILAN değil"
        )
    return problems


def _self_test() -> None:
    """Kapının yakaladığını İDDİA ettiği kusuru GERÇEKTEN yakaladığı."""
    silent = """
    buildTypes {
        release {
            // TODO: Add your own signing config for the release build.
            signingConfig = signingConfigs.getByName("debug")
        }
    }
"""
    assert check(silent), "ÖZ-TEST: sessiz düşüş YAKALANMADI — kapı kör"

    # Ve kuralın YORUMDA anılması kapıyı geçirmemeli (vakum-doğru olurdu).
    commented = """
    buildTypes {
        release {
            // GradleException ve allowDebugSigning burada sadece YORUMDA geçiyor
            signingConfig = signingConfigs.getByName("debug")
        }
    }
"""
    assert check(commented), (
        "ÖZ-TEST: yorumdaki kelimeler kapıyı geçirdi — kelime taraması "
        "davranış taramasının yerine geçemez"
    )
    print("  öz-test: 2/2 ✅")


def main() -> int:
    _self_test()
    if not GRADLE.exists():
        print(f"⛔ {GRADLE.relative_to(REPO)} yok")
        return 1
    problems = check(GRADLE.read_text())
    if problems:
        print("⛔ RELEASE İMZASI KAPISI — kırmızı:")
        for p in problems:
            print(f"   · {p}")
        return 1
    print("✅ release imzası: sessiz düşüş YOK (gürültülü durdurucu + açık opt-in)")
    return 0


if __name__ == "__main__":
    sys.exit(main())
