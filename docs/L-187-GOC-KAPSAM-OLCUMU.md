# L-187 göçü — ÖLÇÜLMÜŞ kapsam (2026-08-07, Lissom)

**Hüküm:** koordinatör göçü onayladı; şart `test/reference_equivalence_test.dart`
ve `packages/lissom_engine/test/metric_coverage_test.dart`'ta çivili.

**Bu belge hükmü sorgulamıyor — hükmün ÖNCÜLÜNÜ ölçüyor.** Hüküm *"3 dosya, 2'si
çekirdekte"* varsayımıyla verildi. Ölçtüm: **öncül eksik.**

---

## ⚠️ ÖNCE KENDİ HATAM

Dört tur boyunca *"göç bu şapkadan yapılamaz, M-F-22 dal değiştirmeyi
yasaklıyor"* dedim. **Yanlıştı.** M-F-22 *paylaşımlı ağacın* (`ventures/
motion-core/lib`) dalını değiştirmeyi yasaklıyor; **ayrı bir worktree açmayı
değil** — ve diğer hatlar bunu rutin yapıyor:

```
~/motion-core-worktrees/jablab-camera      [fix/motion-camera-readme-status]
~/motion-core-worktrees/jablab-imperative  [fix/rom-mode-imperative]
~/motion-worktrees/coordinator-main        [main @ 63a0b3e]
```

Blokaj iddiam bir **ölçüm eksikliğiydi**, kural değil. Kaydediyorum çünkü aynı
iddiayı dört kez tekrarladım ve her tekrar onu daha sağlam gösterdi.

---

## ÖLÇÜM

| Soru | Yöntem | Sonuç |
|---|---|---|
| Göç bir **pin yükseltmesi** mi? | `git diff --stat f13bdc9..main -- packages/motion_core/lib/src/geometry/` | **BOŞ** — dosyalar aynı |
| `main` `world` uzayını üretiyor mu? | `grep -rn world …/geometry/*.dart` | **hiç geçmiyor** |
| Enum `world` taşıyor mu? | `engine/phase_config.dart:199` | ✅ `{ world, isotropic, pixel }` |
| Kamera 3D veri taşıyor mu? | `frame_envelope.dart:85` | ✅ `33 × [x, y, z, vis]` |
| **Native hangi kümeyi yolluyor?** | Kotlin `:286` · Swift `:242` | 🔴 **`result.landmarks`** |

### 🔴 Belirleyici bulgu

Her iki native eklenti de **`result.landmarks`** kullanıyor —
**`worldLandmarks` DEĞİL.**

```kotlin
// android/.../MotionCameraPlugin.kt:286
val pose = result.landmarks().firstOrNull() ?: return null
floats[i * 4 + 2] = landmark.z()          // :294
```
```swift
// ios/Classes/MotionCameraPlugin.swift:242
let pose = result.landmarks.first
floats[i * 4 + 2] = lm.z                  // :252
```

MediaPipe'ta bu iki küme **farklı şeylerdir**: `landmarks` görüntüye
normalize edilmiştir ve `z`si **kalçaya göre, x ile kabaca aynı ölçekte bir
sözde-derinliktir**; `worldLandmarks` ise kalça merkezli **metrik** 3D'dir.
Normatif Python tarafı (`anatomical=True`, `world` 3D) ikincisini kullanıyor.

**Yani bugün Dart'a ulaşan `z`, metrik dünya koordinatı değil.**

---

## Sonuç — kapsam 3 dosya DEĞİL

Göç, Dart geometry katmanını `world`e çevirmekle **bitmiyor**; kaynak veri
zaten dünya uzayında değil. Gerçek kapsam:

1. `android/…/MotionCameraPlugin.kt` — `worldLandmarks()`e geçiş
2. `ios/Classes/MotionCameraPlugin.swift` — aynısı
3. `geometry/joint_angles.dart` — 3D açı hesabı
4. `geometry/normalization.dart` — dünya-uzayı normalizasyonu
5. `lissom_engine/metric_bridge.dart` — `kBridgeSpace` beyanı + 4 metriğin açılması

**⛔ Ve Dart-only yapmanın sonucu, hükmün kendi şartının ihlalidir:** sözde-
derinlikten hesaplanan bir "world-space" açı, **referans-eşdeğeri GİBİ görünen
ama olmayan** bir sayı üretir. Bayrak o ölçümle `true` yapılırsa bu tam olarak
şartın yasakladığı **eşik icadıdır**.

> Not: `metric_coverage_test`teki yeni kural (`bayrak ⟺ kBridgeSpace == world`)
> bunu **yakalamaz** — beyan ile ölçümün gerçekten aynı uzayda olup olmadığını
> Dart'tan görmek mümkün değil. Bu, **kapının ölçmediği** şey ve isimle burada.

---

## KOORDİNATÖRE SORU (kapsam — brief'e göre SORULUR, yapılmaz)

Göç **iki native eklentiye** dokunuyor; ikisi de **beş hattın ortak
bağımlılığı** ve `motion_camera` pin'i J-071 gereği çekirdekle **aynı SHA**.
Yani bu değişiklik Lissom'un tek başına alacağı bir karar değil:

1. **Native `worldLandmarks` geçişi onaylanıyor mu?** (5 hattı birden etkiler)
2. Onaylanmazsa göç **düşer** — Dart-only hâli şartın yasakladığı şeyi üretir.
3. `fixture_check.py` kırmızısı **aynı kökten**: rig `anatomical_mode()`
   taşımıyor (M-F-280, ağaç 122 commit geride). Göç ölçülecekse **önce rig
   tazelenmeli**, yoksa "göç sonrası sapma" ölçülemez.

**Bu üçü cevaplanana kadar göç başlatılamaz — ama artık sebep "yapamıyorum"
değil, İSİMLİ bir kapsam kararı.**

---

## EK (11:4x) — «Bu yapısal eksik BAŞKA neyi kırıyor?» (JabLab dersi)

Koordinatörün sorusu: *aynı eksik yapı, iki farklı kusur sınıfı üretir.*
Ölçtüm — ve cevap **rahatlatıcı yönde**, ama göç kapsamını **büyütüyor**.

### Ölçüm

`motion_core`'un açı çıkarıcısı bir anahtar taşıyor:

```dart
out[i] = planar ? jointAngle2D(a, b, c) : jointAngle(a, b, c);
// JointAngleExtractor({... this.planar = true});
```

Ve Lissom'un `CoreMetricReader`'ı **bu varsayılanı ezmiyor** →
**`planar = true`**.

### Sonuç ①: sevk edilen ölçümler TEMİZ

Lissom açıları **tamamen 2D**; `z`'ye **hiç dokunmuyorlar**. Yani native'in
sözde-derinlik yollaması, **bugün sevk edilen 8 köprülü metriği
bozmuyor** — gizli bir çarpıtma YOK. Ölçümler kendi içinde tutarlı.

### Sonuç ②: göç kapsamı ÜÇÜNCÜ boyut kazandı

Göç yalnız *"native'i `worldLandmarks`e çevir"* değil; `planar` da `false`
olmalı, yoksa dünya koordinatları gelir ve **kullanılmaz**. Ve `planar`
**paylaşımlı bir varsayılan**: onu çevirmek **beş hattın da** açı
semantiğini değiştirir.

**Güncel kapsam — 3 değil, 6:**

1. `android/…/MotionCameraPlugin.kt` → `worldLandmarks()`
2. `ios/Classes/MotionCameraPlugin.swift` → aynısı
3. `JointAngleExtractor.planar` → `false` (**paylaşımlı varsayılan**)
4. `geometry/joint_angles.dart` → 3B açı yolu
5. `geometry/normalization.dart` → dünya-uzayı normalizasyonu
6. `lissom_engine/metric_bridge.dart` → `kBridgeSpace` + 4 metrik

### Ve L-031'in sayısı açıklandı

Dart **2D görüntü-düzlemi** açısı ölçüyor, normatif Python **3D dünya** açısı.
Medyan **11,29°** sapma tam olarak bu farkın kendisi — bir hata değil, **iki
farklı ölçünün** farkı.
