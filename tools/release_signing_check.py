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

    # This is a source regression gate, not a Kotlin/Gradle interpreter.
    # The exact policy anchors below must be kept together; native Gradle
    # graph/configuration checks remain separate acceptance evidence.
    required = {
        "release build type": r"\brelease\s*\{",
        "real signing source":
            r'val\s+hasRealSigning\s*=\s*keyProps\.getProperty\("storeFile"\)\s*!=\s*null',
        "true-only opt-in":
            r'val\s+allowDebugSigning\s*=\s*providers\.gradleProperty\("allowDebugSigning"\)\.orNull\s*==\s*"true"',
        "real signing selection": r'hasRealSigning\s*->\s*signingConfig\s*=\s*signingConfigs\.getByName\("release"\)',
        "explicit debug selection":
            r'allowDebugSigning\s*->\s*\{\s*signingConfig\s*=\s*signingConfigs\.getByName\("debug"\)\s*logger\.warn\(',
        "unsigned fallback": r'else\s*->\s*signingConfig\s*=\s*null',
        "actual app release graph refusal":
            r'if\s*\(!hasRealSigning\s*&&\s*!allowDebugSigning\)\s*\{\s*'
            r'gradle\.taskGraph\.whenReady\s*\{\s*val\s+graph\s*=\s*this\s*'
            r'if\s*\(graph\.allTasks\.any\s*\{\s*task\s*->\s*'
            r'task\.project\s*==\s*project\s*&&\s*'
            r'task\.name\.contains\("Release",\s*ignoreCase\s*=\s*true\)\s*'
            r'\}\)\s*\{\s*throw\s+GradleException\(',
    }
    for name, pattern in required.items():
        if re.search(pattern, code, re.S) is None:
            problems.append(f"signing policy anchor missing: {name}")
    if re.search(r'hasProperty\("allowDebugSigning"\)', code):
        problems.append("presence-only debug opt-in accepts false/empty values")
    if "gradle.startParameter.taskNames" in code:
        problems.append("requested task names miss release dependencies of assemble/wrappers")
    if re.search(r'else\s*->\s*signingConfig\s*=\s*signingConfigs\.getByName\("debug"\)', code):
        problems.append("release without explicit opt-in falls back to debug signing")
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
    print("✅ release signing source: true-only opt-in + actual app task graph guard")
    print("   Native Gradle/configuration and signed-binary acceptance remain separate.")
    return 0


if __name__ == "__main__":
    sys.exit(main())
