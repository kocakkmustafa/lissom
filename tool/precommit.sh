#!/bin/bash
# COMMIT KAPISI (L-275) — JabLab aktarımı.
#
# 🪤 JabLab'ın kusuru: `flutter test 2>&1 | tail -1 && git commit …`
#    Boru hattının çıkış kodu SON komutunki; `tail` HER ZAMAN 0 döner ve
#    başarısızlığı YUTAR. Kapı vakum-doğruydu.
#
# 🪤 BENİM kusurum farklıydı ve ölçtüm: **hiç kapı yoktu.** Kapıları ayrı bir
#    komutta koşturup sonra commit ediyordum — yanlış-güven değil,
#    KAPISIZLIK. Gece boyunca elle koştum ve her seferinde yeşildi, ama
#    "her seferinde" bir güvence değil bir alışkanlıktır.
#
# ⛔ BORU HATTI YOK. Çıkış kodu doğrudan taşınır.
# ⚠️ `dirname $0` KULLANILMAZ: hook olarak koşarken `$0` `.git/hooks/...`
# olur ve `cd ../..` depo köküne DEĞİL `.git/`e gider. İlk denemede tam bu
# oldu — commit DURDU ama YANLIŞ GEREKÇEYLE (betik bulunamadı). Doğru sonuç,
# yanlış sebep: pozitif kontrol olmasa "kapı çalışıyor" diye kaydedecektim.
set -euo pipefail
cd "$(git rev-parse --show-toplevel)"
python3 tools/all_gates.py
