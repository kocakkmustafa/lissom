# Android kamera izni — kapalı sürümde bildirilmez

Karar: LIS-P1-15. Kamera denemesi kapalıyken (`LISSOM_CAMERA_TRIAL` kapalı, `lib/app/lissom_release_policy.dart`; Core `motionCameraCoachingAvailable = false`) Yula Lab Lissom'un Android uygulama manifestinde `CAMERA` izni ve kamera `uses-feature` satırları YOKTUR. Uygulama kamera izni istemez; kullanılmayan izin mağaza ve kullanıcı güveni açısından gereksiz bildirimdir. `uses-feature` satırları (ADR-L006'da `required=false` yapılmıştı) yalnız izin varken anlamlıydı; izin kalkınca onlar da kalktı.

Kapsam: yalnız uygulama manifesti. Kütüphane manifestleri `CAMERA` iznini birleşik manifeste geri ekliyordu; bu yüzden uygulama manifestinde `CAMERA` için `tools:node="remove"` direktifi durur.

Birleşik manifest doğrulaması (`flutter build apk --debug`, `build/app/intermediates/merged_manifests/debug/processDebugManifest/AndroidManifest.xml`): `permission.CAMERA` YOK; `uses-feature camera.any`, `uses-feature camera` ve `RECORD_AUDIO` kütüphanelerden VAR. Çıktı kopyası: `scratch/2026-11-15-lis-p1-15/merged-manifest-debug.xml` (repoda değil).

Kilit: `test/android_manifest_camera_permission_test.dart` (bayrak varsayılanı kapalı; manifestte CAMERA izni ve `android.hardware.camera` yok).

## `LISSOM_CAMERA_TRIAL` mağaza sürümünde açılırken (kurucu kararı)
`android/app/src/main/AndroidManifest.xml` içine şu satırlar eklenir:

```xml
<uses-permission android:name="android.permission.CAMERA" />
<uses-feature android:name="android.hardware.camera" android:required="false" />
<uses-feature android:name="android.hardware.camera.front" android:required="false" />
```

- Manifestteki `CAMERA` için `tools:node="remove"` satırı (kütüphaneler izni birleşik manifeste geri ekliyordu) kaldırılır.
- Bu değişiklik izin metni (iOS `NSCameraUsageDescription` + 14 `InfoPlist.strings`), gizlilik metni ve mağaza metniyle birlikte yapılır: bkz. `docs/camera/ACILIS-METINLERI.tr.md`.
- `test/android_manifest_camera_permission_test.dart` aynı değişiklikte güncellenir (açıkken izin ve uses-feature beklenir).
- `docs/store/reviewer-notes.md`, `release-review.json` ve `FARKLILASMA-4.3a.tr.md` içindeki "Android izni bildirimde yok" cümleleri de açılışta düzeltilir.

## Kaynak ve kapsam notları (LIS-P1-15 incelemesi)
- Birleşik manifestteki `camera.any` (required belirtilmemiş = varsayılan `true`), `CAMERA` ve `RECORD_AUDIO` kaynağı `camera_android_camerax-0.7.6+1` kütüphane manifestidir (`~/.pub-cache/hosted/pub.dev/camera_android_camerax-0.7.6+1/android/src/main/AndroidManifest.xml:3-5`). `camera.any` required=true olduğundan Play'de kamerasız cihazları eleyebilir (ADR-L006'nın "uyumluluk listesi daralmaz" sonucu bu noktada tam sağlanmıyor olabilir); kaldırma ya da `required=false` ayrı karar.
- Doğrulama yalnız debug birleşik manifestte yapıldı; release için `DOĞRULANMADI`.
