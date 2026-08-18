# assets/fonts/

Bu klasördeki `.ttf` dosyaları git'te DEĞİLDİR (`.gitignore`: `assets/fonts/*.ttf`
— `assets/models/*.task` ile aynı desen). Bu dosya klasörün kendisini git'te
tutmak için var; Flutter asset bundling boş bir bildirilmiş klasörü kabul
eder, ama HİÇ VAR OLMAYAN bir klasörü `pubspec.yaml`de görünce build/test
sert hata verir (ölçüldü, L-348/LIS-P0-002).

Doldurmak için: `tool/fetch_fonts.sh` — pinli SHA-256 doğrulamasıyla iner.
Beklenen 4 dosya: `Newsreader-Light.ttf`, `Newsreader-Regular.ttf`,
`NunitoSans-Regular.ttf`, `NunitoSans-SemiBold.ttf`.
