#!/bin/bash
# Newsreader + Nunito Sans yazı tiplerini indirir ve SHA-256'sını DOĞRULAR
# (L-348/LIS-P0-002 — `tool/fetch_pose_model.sh`nin AYNI deseni: pinli
# URL + hash-doğrulama build kapısı, ikili git'e commit edilmez).
#
# NİYE BU HASH'LER: elle seçilmedi. `google_fonts` paketinin BU projenin
# pubspec.lock'ta ÇÖZÜLMÜŞ sürümü (6.3.3 — SÜRÜM İDDİANIN PARÇASIDIR,
# PrivacyInfo.xcprivacy'nin path_provider_foundation dersi) kendi
# `lib/src/google_fonts_parts/part_n.g.dart` dosyasında HER ağırlık için
# bu SHA-256'yı taşıyor; `GoogleFontsFile.url` getter'ı
# `https://fonts.gstatic.com/s/a/$hash.ttf` üretiyor. Yani bu betik
# runtime'da `google_fonts`un ZATEN indireceği TAM O DOSYAYI, TAM O
# URL'DEN, build-time'a taşıyor — yeni bir kaynak İCAT EDİLMEDİ.
#
# NEDEN 4 DOSYA, TÜM AĞIRLIKLAR DEĞİL: `lib/app/lissom_theme.dart`
# `buildLissomTheme()` yalnız Newsreader'ı w300 (varsayılan `display()`)
# ve w400'de (`headlineMedium`/`headlineSmall`), Nunito Sans'ı yalnız
# w400'de (`sans.bodyLarge/Medium/Small`, override'sız — Material3
# varsayılanı) ve w600'de (`titleLarge/Medium/Small`, `label()` — hepsi
# AÇIKÇA override) kullanıyor. Kullanılmayan ağırlığı bundle etmek
# paket boyutunu büyütür, hiçbir ekranı değiştirmez.
set -euo pipefail

DEST_DIR="assets/fonts"
declare -a FONTS=(
  # dest_filename                sha256                                                            size
  "Newsreader-Light.ttf          09cdb18a68c56dac91d53f4bb4f80853376cdebecb912f8c20d31e36c383f50b  109452"
  "Newsreader-Regular.ttf        e57916a6608d8319d2fe2aab76131086c6cf889fe9f144e5909059ae5d2a963a  109516"
  "NunitoSans-Regular.ttf        1563a052d1d6552b3b802f10aa4efb3208d7fc91c701b61dbe1edb0548c1c1fa  106736"
  "NunitoSans-SemiBold.ttf       94bbbb4ad81df4d26a044fcd34bd878ec319798c7f45882f83e19bc6e2ec5228  106844"
)

cd "$(dirname "$0")/.."
mkdir -p "$DEST_DIR"

verify() {
  local got
  got=$(shasum -a 256 "$1" | awk '{print $1}')
  [ "$got" = "$2" ] || { echo "⛔ SHA UYUŞMUYOR: $1"; echo "   beklenen: $2"; echo "   bulunan : $got"; return 1; }
}

for entry in "${FONTS[@]}"; do
  read -r name hash size <<< "$entry"
  dest="$DEST_DIR/$name"
  url="https://fonts.gstatic.com/s/a/${hash}.ttf"
  if [ -f "$dest" ] && verify "$dest" "$hash" 2>/dev/null; then
    echo "✓ zaten yerinde ve doğrulandı: $dest"
    continue
  fi
  echo "indiriliyor: $name ← $url"
  curl -fsSL "$url" -o "$dest"
  verify "$dest" "$hash"
  got_size=$(stat -f%z "$dest" 2>/dev/null || stat -c%s "$dest")
  [ "$got_size" = "$size" ] || { echo "⛔ BOYUT UYUŞMUYOR: $dest ($got_size ≠ $size)"; exit 1; }
  echo "✓ doğrulandı: $dest ($size bayt)"
done

echo "→ $DEST_DIR (4/4 doğrulandı)"
