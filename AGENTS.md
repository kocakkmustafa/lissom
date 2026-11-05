# YULAlab — yerel Codex girişi

Önce [ortak bağlam girişini](../../../AGENTS.md), ardından [bu reponun tek yerel ürün/güvenlik kaynağını](CLAUDE.md) oku. CLAUDE.md içindeki yerel bilgiler Codex ve Claude için aynıdır; teknik yöntemi model seçer, dosya işlem yetkisi üretmez.

Bu dosya Codex ve diğer kod ajanları içindir. Kısa tutulur; ayrıntı `CLAUDE.md` ve depo belgelerindedir.

## Yığın
- Flutter (stable) / Dart ^3.9 · içerik araçları Python 3.12 (`tools/`) · durum yönetimi: yok; ChangeNotifier/ValueNotifier
- Ortak altyapı pinli Motion Core'dan gelir (`pubspec.yaml` git ref); yerel paket: `packages/lissom_engine`.
- Kurulum: `flutter pub get` · Analiz: `flutter analyze` · Test: `flutter test`
- Motor testi: `(cd packages/lissom_engine && flutter test)` · Hatha bütünlük: `dart run tool/build_hatha_integrity_manifest.dart --check`
- İçerik kapıları (CI `checks.yml`): `python3 tools/config_check.py` · `python3 -B tools/check_content_localization.py` · `python3 tools/phase_check.py` · `python3 tools/wellness_lint.py` · `python3 -B tools/build_hatha_course.py --check` · `python3 -B tools/check_lissom_source_projection.py --check`

## Kurallar
- **Minimal diff:** yalnız istenen dosyalara dokun; biçimlendirme/yeniden adlandırma turu yapma.
- Yerelleştirme: ARB/`gen-l10n` yok. Metinler `config/l10n/<dil>.json` (14 dil, `messages` sözlüğü); yeni ya da değişen metni 14 kataloğa birlikte işle, sonra `check_content_localization.py` ve `python3 -B -m unittest discover -s tools -p 'test_*localization.py'` koş.
- Wellness: tıbbi iddia yok; ham video cihazda kalır; gerçek-zamanlı LLM yok (`CLAUDE.md`). Metin değişince `tools/wellness_lint.py` temiz olmalı.
- Testler: uygulama `test/*_test.dart` (`test/fixtures`, `test/support`), cihaz `integration_test/`; yeni davranışa test ekle; mevcut testi silme ya da atlatma.
- Bitirmeden: analiz ve test temiz olmalı; çıktının son 5 satırını rapora koy.

## Dokunulmaz
- Sır dosyaları (`.env*`, anahtarlar, `~/.secrets`), imzalama/fastlane yapılandırması, fiyat/abonelik kimlikleri, Supabase göçleri/şeması — yalnız açık talimatla.
- Mağaza meta verisi ve sürüm numarası — yalnız açık talimatla.
- Motion Core pini (`pubspec.yaml`'daki `ref`) — yalnız açık talimatla.
- Kamera özelliği bayrağı `LISSOM_CAMERA_TRIAL` (`lib/app/lissom_release_policy.dart`) kapalı kalır; açılması kurucu kararıdır.
- Burun Farkı ve Iron Bank'a dokunulmaz.
