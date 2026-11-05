# Kamera denemesi — cihaz smoke raporu (2026-11-05)

Test: `integration_test/camera_device_smoke_test.dart` (dokunma gerektirmez; yalnız sayı raporlar, kamera ekranının görüntüsü alınmaz). Bayrak açık profil derlemesi (`--dart-define=LISSOM_CAMERA_TRIAL=true`), Core pin `4145a04`.

## iPhone (kurucunun cihazı, iOS 27.0.1, kablosuz bağlantı)
| Ölçüm | Sonuç |
|---|---|
| Kod imzalı profil derlemesi, kurulum, açılış | ✅ (otomatik imza, takım T5HZGYBWK8) |
| Doğrulayıcı + koç maliyeti (özellik çıkarımı, pencere medyanı, karar), 3000 kare | **≈ 40 µs/kare** (30 fps bütçesi 33 ms) |
| Kamera izni, oturum başlatma, önizleme texture'ı, kare hızı, MediaPipe çıkarım süresi | ⏳ **ölçülmedi**: cihazda kamera izni bir kişinin "İzin ver" demesini bekliyor; telefon başında kimse yokken uygulama arka plana düştü |

Notlar:
- `flutter drive` kablosuz bağlantıda Dart VM'e bağlanamadı (20 dk "Installing and launching"). Bu yüzden test sürücüsüz çalıştırıldı: sonuç uygulamanın kendi `Documents/lissom-camera-smoke.json` dosyasına yazılır ve `xcrun devicectl device copy from` ile okunur.
- Telefondaki Lissom şu an bu test derlemesi; TestFlight'tan geri yüklenebilir.
- iOS sürüm derlemesi (no-codesign) Core 0.4.0 yerel Swift önizleme koduyla CI'da ve yerelde geçti.

## Android
- Bağlı Android cihaz yok. CI'da Android release appbundle derlemesi Core 0.4.0 Kotlin önizleme koduyla geçti.
- **Cihazda denenmedi.** Önizleme döndürmesi (`previewQuarterTurns`) ve ön kamera ayna yönü gerçek cihazda doğrulanmalı.

## Kalan kurucu adımı (iPhone kamera kısmı, ~1 dk)
1. Telefonu açık tut; Lissom'u aç.
2. Kamera izni sorulunca "İzin ver".
3. 15 sn telefona yanını dönerek dik dur.
Komut (oturumdan çalıştırılır):
```
flutter build ios --profile -t integration_test/camera_device_smoke_test.dart --dart-define=LISSOM_CAMERA_TRIAL=true
xcrun devicectl device install app --device <id> build/ios/iphoneos/Runner.app
xcrun devicectl device process launch --device <id> com.yulalab.lissom
xcrun devicectl device copy from --device <id> --domain-type appDataContainer --domain-identifier com.yulalab.lissom --source Documents/lissom-camera-smoke.json --destination smoke.json
```
