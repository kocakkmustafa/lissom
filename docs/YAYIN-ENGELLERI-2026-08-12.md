# Lissom — App Store'a gönderilebilir mi? (2026-08-12, ölçülmüş)

> `YAYIN-ENGELLERI-2026-08-07.md`in **yeniden ölçümü**. O liste 5 gün ve
> ~100 commit önceydi; bayat bir listeden iş sevk edilmez (M-F-509).
> Her satır bugün yeniden ölçüldü — devralınan hiçbir "✅" doğru sayılmadı.

## CEVAP: **HAYIR** — ama engel ARTIK BAŞKA BİR ŞEY.

08-07'de engel *"kamera kabuğa hiç bağlı değil"*di. **O kapandı.**
Bugünkü engel bir katman ötede:

> ***Kullanıcı bir ölçüm yapabiliyor, ama ölçüm HİÇBİR YERE yazılmıyor.***
> Ekranı kapattığı an sayı kayboluyor; Progress ve geçmiş **kalıcı olarak
> boş**. Ve sonuç ekranı kullanıcıya *"This is your starting point — **we'll
> track it from here**"* diyor.
>
> **Bugün Lissom ölçüm YAPAN ama ölçümü TUTMAYAN bir uygulama.**

---

## 08-07'den beri KAPANANLAR (yeniden ölçüldü, devralınmadı)

| # | Kalem | Bugünkü ölçüm |
|---|---|---|
| 1 | Kamera kabuğa bağlı değil | ✅ **KAPANDI** — `LiveCaptureScreen` var, Home'dan gerçek rotayla ulaşılıyor (`home_screen_test` sürüyor). ⚠️ **cihazda DOĞRULANMADI** (aşağıda ⑬) |
| 2 | `NSCameraUsageDescription` | ✅ dolu ve dürüst (Info.plist'te doğrudan görüldü) |
| 2b | Poz modeli | ✅ `tool/fetch_pose_model.sh` · `pubspec`'te `assets/models/` **beyanlı** · dosya diskte **9 398 198 B**. ⚠️ git'te DEĞİL (kasıtlı) → **temiz klonda script koşmadan kamera başlamaz** |
| 5 | Onboarding ekranı + tetiği | ✅ **KAPANDI** (bugün) — `OnboardingGate` uygulamanın girişi, 5 adım, yaş bandı motora bağlı (L-280) |
| — | Kalıcı izin reddi çıkmaz sokağı | ✅ **KAPANDI** (bugün, L-283) — iki yerde, `isRestricted` dahil |

---

## ⛔ YAYINI ENGELLEYEN — bugünkü liste

| # | Engel | Sınıf | Kanıt |
|---|---|---|---|
| **13** | 🔴 **ÖLÇÜM KAYDEDİLMİYOR.** `live_capture_screen.dart`ta `SessionStore`a yazma **SIFIR** (pozitif kontrol: `SessionStore` başka 4 dosyada geçiyor, süzgeç çalışıyor). Geçmiş `app_facts.dart`ta OKUNUYOR ama kimse YAZMIYOR → Progress/geçmiş **kalıcı boş**, ve sonuç ekranı *"we'll track it from here"* **vaadini tutamıyor**. | `hat-yereli` | `git grep SessionStore -- live_capture_screen.dart` → 0 |
| **14** | 🔴 **Android release imzası DEBUG anahtarlarıyla.** `build.gradle.kts:35` — *"TODO: Add your own signing config"*, `signingConfig = signingConfigs.getByName("debug")`. Play debug-imzalı AAB'yi **reddeder**. | `hat-yereli` + **kurucu** (keystore) | doğrudan okundu |
| **3** | **`PrivacyInfo.xcprivacy` YOK** (ölçüldü: `find ios -name '*.xcprivacy'` → **0**). ⚠️ Gereklilik koşulu bu turda **kısmen** ölçüldü: `path_provider_foundation` **kendi** manifest'ini taşıyor ✅, ama uygulamanın **kendi** `dart:io` dosya-zaman-damgası kullanımı ayrı bir beyandır. **Tam koşul hâlâ ölçülmedi.** | `hat-yereli` + `ölçülmemiş` (koşul) | dosya yokluğu ölçüldü |
| **4** | **App ikonu Flutter varsayılanı** — 🪤 SHA karşılaştırmam *"özel ikon var"* dedi ve **YANLIŞTI**: şablon dosyası 0 baytlık `.img.tmpl` (SHA'sı boş-girdi hash'i `e3b0c442…`). **Görüntüye bakıldı: mavi Flutter logosu.** Guideline reddi. | **kurucu** (marka görseli) | ikon görsel olarak açıldı |
| **6** | **Store metadata hiç yok** — `store/` · `metadata/` · `fastlane/` **yok**; ASC'de sürüm 1.0 `PREPARE_FOR_SUBMISSION` ama ekran görüntüsü/açıklama/yaş derecesi/gizlilik anketi yok. | **kurucu** | ASC + dosya sistemi |

---

## ⚠️ YAYINI ZAYIFLATAN

| # | Kalem | Sınıf | Kanıt |
|---|---|---|---|
| **9** | `BatterySummaryView` **hâlâ erişilemez** — kabukta **sıfır** atıf (L-225). ⑬ çözülünce ilk ihtiyaç duyulacak yüzey. | `hat-yereli` | ölçüldü |
| **8** | Progress ekranı boş — **artık ⑬'e bağlı** (08-07'de ①'e bağlıydı). | `hat-yereli` | ⑬'ün sonucu |
| **10** | **İçerik:** `library.v1.json` **6 aile**, beşi `coming_soon` ve **0 öğe**; `Assessment Battery` `in_progress` ve IA'da **0 öğe** (batarya config'inde 12 test var — vitrin ile motor ayrı yerlerden besleniyor). | `içerik` / **kurucu** | config okundu |
| **13b** | **Cihaz doğrulama borcu** — kamera hiçbir gerçek cihazda sınanmadı. Ekranın kendi kartı dört kalemi **tek tek** sayıyor: izin diyaloğu · kare akışı · landmark kalitesi · kalibrasyon eşiği (yaw ≤10°). | `hat-yereli` (cihaz gerekir) | `NamedGapCard` metni |
| **11** | IAP/paywall yok — ücretsizse engel değil. | **kurucu kararı** | — |
| **12** | Sürüm `0.1.0+1`; ASC'de sürüm dizesi **1.0**. **İkisi ayrışık** — ilk gönderimde bilinçli hizalanmalı. | **kurucu** | pubspec + ASC |

---

## ✅ ÖLÇÜLDÜ — 08-07'nin "ölçülemedi"si kapandı

| # | Soru | Cevap |
|---|---|---|
| **7** | ASC kaydı / TestFlight geçmişi | **KAYITLI:** app `6794715023`, *"Lissom: Mobility & Yoga"*, `com.yulalab.lissom`, sku `yula-lissom-2026`, `en-US`. Sürüm **1.0 · PREPARE_FOR_SUBMISSION** (2026-07-25). **Yüklenmiş build: 0** — TestFlight geçmişi YOK. ⚠️ `releaseType: AFTER_APPROVAL` (onaylanınca **otomatik yayın**). |
| — | Android kamera izni | ✅ **Manifest merge ile geliyor** — uygulamanın kendi manifest'inde yok ama `motion_camera`ın **PİNLİ** sürümü (`f13bdc9`) `CAMERA` + `camera` feature beyan ediyor. *(İlk baktığım checkout `101ed95c`'ydi — pin DEĞİL; pinliyle yeniden doğrulandı.)* |
| — | Placeholder/TODO | ✅ `lib/` genelinde **0** |

## ❓ BU TURDA ÖLÇÜLMEDİ — isimle

- **Play Console kaydı** (Android'in ⑦ karşılığı) — okuma-yalnız bir yol bulamadım, yazma yapmadım.
- **Release build'in gerçekten derlendiği** (`flutter build ipa/appbundle`) — koşulmadı.
- ③'ün **gereklilik koşulu** (yukarıda).

---

## Kritik yol (ölçüme göre)

**⑬ ölçümü kaydet** → ⑨ özet yüzeyi bağla → ⑧ Progress kendiliğinden dolar
→ ③④⑥ store teknik/görsel/metadata → ⑬b cihaz turu → ⑭ Android keystore.

⑬ **hat-yereli ve kurucu-bağımsız**; ④⑥ **kurucu**; ⑭ keystore **kurucu**.

## Tek cümlelik özet

> **08-07'de "kamerasız bir kamera uygulaması"ydı. Bugün kamera var, ölçüm
> var — ama ölçüm HATIRLANMIYOR. Uygulamanın kullanıcıya verdiği tek
> takip sözü (*"we'll track it from here"*) bugün tutulamıyor.**
