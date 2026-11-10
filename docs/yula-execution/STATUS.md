# Lissom — durum (kaynak gerçeği)

**Tarih:** 2026-11-10 · **Kaynak commit:** `main` `5ea39cb` (lissom#24 merge) · **Bilet:** LIS-P1-01 (ilk yazım 2026-11-08), güncelleme LIS-P1-02/03
Bu dosya "şu an ne çalışıyor" sorusunun tek cevabıdır. Her satırın kanıtı yanındadır; kanıtı olmayan satır `DOĞRULANMADI` yazar. Kararların gerekçesi `DECISIONS.md`'dedir.

## 1. Ne çalışıyor (kod main'de)

| Yüzey | Durum | Kanıt |
|---|---|---|
| Hatha kursu | 60 ders, v1.0.1, bütünlük manifestli | `config/courses/hatha.v1.json`; `dart run tool/build_hatha_integrity_manifest.dart --check` |
| Sandalye/ofis kursu | 15 ders, v1.0.0 | `config/courses/chair-office.v1.json` |
| Destekli ayakta Vinyasa | 14 ders, v1.0.0 | `config/courses/vinyasa-standing.v1.json` |
| Destekli Yin | 12 ders, v1.0.0 | `config/courses/yin-supported.v1.json` |
| Ashtanga temelleri | 19 ders, v1.0.0 (tam Primary Series değil) | `config/courses/ashtanga-foundations.v1.json`; `docs/ASHTANGA-FOUNDATIONS-2026-10-16.md` |
| **Başlangıç yolu** | Hatha h01–h10, yeni ders yok; ilerleme, önkoşul ve erişim Hatha'nın kendisi (ayrı kurs/kayıt yok); bitince Hatha h11'e yönlendirir | lissom#21 → `87deb09`; `lib/app/hatha_beginner_path.dart`; `test/hatha_beginner_path_test.dart` (7 test) |
| Kamera koçluğu — M1 (deneme, bayrak arkasında) | 20 duruş (15 ayakta + 5 sandalye), 27 ders | `config/yoga/camera-poses.v1.json` (v1.2.0, durum `trial`) |
| Kamera koçluğu — M2 (deneme, bayrak arkasında) | 15 yer duruşu, 33 ders (2026-11-05'te alındı) | aynı katalog: 35 duruş = 15 ayakta + 15 yer + 5 sandalye, 60 ders |
| Kamera bayrağı | `LISSOM_CAMERA_TRIAL`, **varsayılan kapalı**; yalnız `--dart-define=LISSOM_CAMERA_TRIAL=true` ile açılır (cihaz smoke derlemesi) | `lib/app/lissom_release_policy.dart` |
| Ölçüm bataryası kamerası | Kapalı (Core `motionCameraCoachingAvailable = false`); bayraktan bağımsız | `lib/app/lissom_release_policy.dart` yorumu; `CaptureUnavailableNote` |
| Ayna (iki yol) | (1) Koç ekranında Core `motion_camera` 0.4.0 oturumunun texture'ı + iskelet + dikey çizgi (tek kamera); (2) ayrı ayna ekranı: Flutter `camera` paketi, yalnız önizleme | `lib/app/camera/camera_coach_screen.dart`, `lib/app/camera/mirror_camera.dart`, `lib/app/camera/mirror_screen.dart`; `docs/camera/MODEL-KARTI.tr.md` "Bileşenler" |
| Android kamera | `uses-feature camera required=false` | lissom#20 → `a731513` |
| Yerelleştirme | 14 dil, `config/l10n/*.json`, 1983 mesaj | `python3 -B tools/check_content_localization.py` |
| Test/CI | Yerel `flutter analyze` temiz, `flutter test` 1105 geçti (2026-11-08, #21 dalında); CI 3/3 yeşil | lissom#21 CI; `.github/workflows/checks.yml` |

Kamera doğrulayıcısı kural tabanlıdır (öğrenilmiş sınıflandırıcı yok). Görüntü, video ve eklem noktaları kaydedilmez ve gönderilmez; puan ve sağlık iddiası yoktur (`docs/camera/MODEL-KARTI.tr.md`). "Deneme" etiketli ve bayrak arkasındadır; bu dosya bayrağın mağaza sürümünde açık olduğunu **söylemez**.

## 2. Mağaza ve cihaz durumu (Motion panosundan, bu bilette yeniden doğrulanmadı)

| Yüzey | Durum | Kaynak |
|---|---|---|
| App Store | 1.0.0 (build 5) REJECTED, 4.3(a) Spam; gönderim UNRESOLVED_ISSUES | Motion Durum Panosu (2026-11-06); `DOĞRULANMADI` bu bilette |
| Google Play | Yalnız alpha (kapalı test) build 5; üretim kapalı | aynı |
| iPhone kamera smoke | Doğrulayıcı maliyeti ölçüldü (≈40 µs/kare); kamera izni, texture, kare hızı, MediaPipe çıkarım süresi **ölçülmedi** | `docs/camera/CIHAZ-SMOKE.tr.md` |
| Kamera güvenlik testleri | Kare/landmark ağa çıkmaz, izin reddinde ders kamerasız sürer, bayrak kapalıyken kamera yolu tetiklenmez: 12 test (yalnız test, cihazsız; `TEST_ONLY`) | lissom#23 → `c4cffe2`; `test/camera/camera_data_boundary_test.dart` |
| Uygulama içi kamera açılış metinleri | `LessonCameraSection`'da izin açıklaması ve gizlilik satırı var (`canStart:false` iken de görünür; 14 dil; bayrak kapalı kalır); 10 test | lissom#24 → `5ea39cb`; `test/camera/camera_opening_copy_test.dart`; kaynak metin `docs/camera/ACILIS-METINLERI.tr.md` |

## 3. Kurucu kararı bekleyenler (tek liste)

| # | Madde | Seçenekler / durum | Kaynak |
|---|---|---|---|
| F1 | Eşik altı duruşlar: M1'de 4 (dağ, yarım kalkış, küçük sandalye, kısa Savaşçı I); M2'de 3 (alçak kobra 0,83, uzanarak dinlenme 0,83, aşağı bakan köpek 0,82; bu veriyle ayar yapılmadı). M2'nin 3'ü için ayrı karar maddesi henüz yok, aynı üç seçenek geçerli | (a) "deneme" içinde kalsınlar (varsayılan, bugünkü durum), (b) kapsamdan çıksınlar (M1 hedefi ≥20 duruş için 16'ya düşer; katalog toplamı 35'ten 31'e), (c) aralıklar genişletilip yeni bağımsız veriyle yeniden sınansın | `docs/camera/KAPSAM.tr.md` son bölüm; `docs/camera/MODEL-KARTI.tr.md` (M2 eşik altı); Motion panosu |
| F2 | iPhone kamera smoke | Kurucu 2026-11-05: "kamera testi beklesin"; izin/kare hızı/çıkarım süresi ölçülmedi | `docs/camera/CIHAZ-SMOKE.tr.md` |
| F3 | Kamera açılışı ve ücreti | Bayrağın mağaza sürümünde açılması (aynı sürümde izin metni + gizlilik metni + mağaza metni birlikte) ve kamera için ücret | Açılış: `lissom_release_policy.dart` yorumu, `docs/camera/ACILIS-METINLERI.tr.md`; ücret: Motion Durum Panosu "Kalan işler" |
| F4 | M3 akış (Vinyasa, Güneşe Selam) | Sonraki sürüm; DTW gerekir | `docs/camera/KAPSAM.tr.md` |
| F5 | Ashtanga açık kalanlar | Yetkin öğretmen/öğrenci incelemesi, kabul edilmiş demonstrasyon/lisans, sensör doğruluğu; tam Primary Series kapsam dışı | `docs/ASHTANGA-FOUNDATIONS-2026-10-16.md` "Açık kalanlar" |
| F6 | `standing-arm-raise` tanımı | "Kollar yukarıda (her yönden)" mi, yalnız öne kaldırma mı; E16'da yanlış kabul %35 | `docs/camera/MODEL-KARTI.tr.md` "Bilinen riskler" |
| F7 | Mağaza reddi 4.3(a) | Ret gerekçesi, yeni build, abonelik kapsamı/fiyat; yeniden gönderim Ostinato onaylanıp yayınlanana kadar bekliyor (kurucu 2026-11-06) | Motion Durum Panosu |

F2, F4 ve F7'de kurucu bir erteleme ya da sıralama kararı verdi (F2: "kamera testi beklesin"; F4: M3 sonraki sürüm; F7: yeniden gönderim beklemede); kalan iş, zamanı gelince karar ya da uygulamadır. F1, F3, F5 ve F6 açık kurucu/içerik kararıdır.

Bu liste tek yerdir: yeni bir kurucu kararı bekleyen madde buraya eklenir, karar alınınca satır silinmez, `DECISIONS.md`'ye ADR olarak taşınır ve burada "karar: ADR-Lxxx" yazılır.

## 4. Bilinen belge borcu

- `docs/camera/MODEL-KARTI.tr.md` "Ne yapmaz" bölümü hâlâ yer duruşlarını değerlendirmediğini söylüyor; M2 (2026-11-05) sonrası bu cümle eskidir. Bu bilette düzeltilmedi (kapsam: yalnız `KAPSAM.tr.md`); ayrı bilet ya da bir sonraki kamera biletinde düzeltilir.

## 5. Doğrulama komutları

```bash
git -C ventures/lissom/app fetch origin -q && git -C ventures/lissom/app log origin/main --oneline -3
python3 -c "import json;d=json.load(open('config/yoga/camera-poses.v1.json'));print(len(d['poses']))"   # 35
dart run tool/build_hatha_integrity_manifest.dart --check
python3 -B tools/check_content_localization.py
flutter analyze && flutter test
```
