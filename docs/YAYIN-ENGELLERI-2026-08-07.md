# Lissom — App Store'a gönderilebilir mi? (2026-08-07 11:5x, ölçülmüş)

## CEVAP: **HAYIR.**

Ve engel **içerik kütüphanesi değil.** Çekirdek akış — *kamerayla ölçüm* —
**kabuğa hiç bağlı değil.** Bugün Lissom, ölçüm **hakkında** dürüst bir okuma
uygulamasıdır; ölçüm **yapan** bir uygulama değildir.

Uygulamanın kendi metni bunu zaten söylüyor:
> *"No session can be captured in this build: the camera run is not wired…"*

---

## ⛔ YAYINI ENGELLEYEN (store reddeder ya da kullanıcı kullanamaz)

| # | Engel | Sınıf | Büyüklük |
|---|---|---|---|
| 1 | **Kamera kabuğa hiç bağlı değil.** `lib/` içinde `motion_camera` · `PoseSource` · `LiveEvaluator` · `AssessmentEngine` çağrısı **SIFIR** — bulunan tüm "camera" geçişleri kameradan *bahseden metin*. Kullanıcı **hiçbir ölçüm yapamaz**, tek bir seans bile. | `kod` | **gün** (kamera ekranı + izin akışı + sonuç yazımı + geçmiş) |
| 2 | **`NSCameraUsageDescription` yok** (`ios/Runner/Info.plist` → 0 eşleşme). Kamera bağlansa bile iOS uygulamayı **anında sonlandırır**; store ayrıca reddeder. | `kod` | **dakika** |
| 3 | **`PrivacyInfo.xcprivacy` yok.** 2024'ten beri **zorunlu**; eksikse yükleme/inceleme reddedilir. | `kod` | **saat** |
| 4 | **App ikonu = Flutter varsayılanı** (mavi "F"; `Icon-App-1024x1024@1x.png` doğrudan görüldü). Guideline reddi. | `içerik` (marka görseli) | **kurucu** |
| 5 | **Onboarding yok.** `lib/app/` altında onboarding/welcome/intro dosyası **yok**. İlk açılışta kullanıcıya ne yapacağı söylenmiyor. Gece direktifinin *ortak yayın blokajı*. | `kod` + `içerik` | **gün** |
| 6 | **Store metadata hiç yok** — ekran görüntüleri, açıklama, anahtar kelimeler, yaş derecesi, gizlilik anketi. `store/` · `metadata/` · `fastlane/` **yok**. | `manuel/kurucu` | **gün** |
| 7 | **ASC'de uygulama kaydı / TestFlight geçmişi** — bu oturumdan **ölçülemedi**. | `ölçülmemiş` | **bilinmiyor** |

---

## ⚠️ YAYINI ZAYIFLATAN (çıkar ama kötü olur)

| # | Kalem | Sınıf | Büyüklük |
|---|---|---|---|
| 8 | **Progress ekranı kalıcı olarak boş** — kıyas kapalı (tasarlanmış hâl) **ve** ölçüm olmadığı için hiç veri yok. İki ayrı sebep aynı boşluğa çıkıyor. | `kod` (1'e bağlı) | 1 çözülünce düzelir |
| 9 | **`BatterySummaryView` erişilemez** — sonuç özeti ekranı kodda var, kabuğa **hiç bağlanmamış** (L-225). Ölçüm gelince ilk ihtiyaç duyulacak yüzey. | `kod` | **saat** |
| 10 | **5 aile kurulmamış** (yoga · nefes/meditasyon · hareket paketleri…). Library'de **isimleri var, içerikleri yok** — dürüstçe söyleniyor ama vitrin zayıf. | `içerik` | **gün+** |
| 11 | **IAP/paywall yok.** Ücretsiz yayınlanacaksa **engel değil**; para modeli istenecekse eksik. | `kurucu kararı` | — |
| 12 | **Sürüm `0.1.0+1`** — ilk gönderim için kabul edilebilir, ama bilinçli bir karar olmalı. | `manuel` | dakika |

---

## Bugün GERÇEKTEN yapılmış olan (dürüstlük için)

- **Ölçüm motoru gerçek ve sınanmış:** 95/95 motor testi, 12 testlik batarya
  config'i, M-F-71 dört sonuç katmanı, bant/eşik disiplini.
- **Köprü 8/19 metrik canlı**, kalan 11'in her birinin **isimli** gerekçesi var.
- **6 gezilebilir ekran** (katı okuma: 2 ayrı rota), 0 ulaşılamayan.
- **140 app + 95 motor + 13 python kapısı yeşil**; dürüstlük kuralları yapısal
  olarak zorlanıyor.
- **Sevk edilen her cümle bir kapıyla korunuyor** (vaat dili, gauge yasağı,
  kontrast, ölçüm-sınırı beyanı, sınıflandırma tutarlılığı).

**Ama bunların hiçbiri kullanıcıya bir ölçüm yaptırmıyor.**

---

## Tek cümlelik özet

> **Lissom'un DÜRÜSTLÜK katmanı yayına hazır; ÖLÇÜM katmanı kullanıcıya hiç
> bağlanmadı. Bugün gönderilse, kamerasız bir kamera uygulaması gönderilmiş
> olur.**

**Kritik yol:** ①+② (kamera bağlama + izin metni) → ⑤ onboarding → ③④ store
teknik/görsel → ⑥ metadata.
