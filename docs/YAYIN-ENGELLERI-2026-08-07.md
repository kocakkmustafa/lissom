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
| 2 | ✅ **ÇÖZÜLDÜ (12:4x).** `NSCameraUsageDescription` eklendi. ⚠️ Önce **kendi kapım reddetti** ve ben kapıyı savundum; sonra ölçtüm: L-262'nin zararı *"KULLANICIYA olmayan bir yeteneği anlatmak"*tı, oysa izin metnini gösteren **diyalog hiç açılmıyor** → zarar **oluşamıyor**. Buna karşılık `motion_camera` **bağlı bir bağımlılık**, Apple statik denetimde görür. **Kapı fazla genişti** — bu gece başkasında defalarca bulduğum kusur, bu kez benimdi. Metin `wellness_lint`in **OS katmanı** taramasından geçiyor. | ✅ kapandı | — |
| 2b | ✅ **ÇÖZÜLDÜ (13:0x).** Poz modeli aile deseniyle kuruldu: `tool/fetch_pose_model.sh` (pin URL+SHA, `latest` yasak) · `pubspec` `assets/models/` · `materializePoseModel()` bundle→**mutlak yol**. Model **9 398 198 bayt**, SHA pin'le birebir. ⭐ Ve hazırlama adımı **kamera gelmeden kanıtlandı**: test gerçek dosya sistemine yazıyor, N=2 davranışını ve **yarım-yazma** kurtarmasını ölçüyor. | ✅ kapandı | — |
| 3 | **`PrivacyInfo.xcprivacy` yok** — dosyanın yokluğu **ölçüldü**. ⚠️ *"Zorunlu"* dediğim kısmı **ölçmedim**: Apple bunu **required-reason API** kullanımına bağlıyor ve o taramayı yapmadım. `path_provider` kullanıyoruz, yani muhtemelen gerekiyor — **ama bu bir tahmin.** | `kod` + **`ölçülmemiş`** (gereklilik koşulu) | saat, *koşul doğrulanınca* |
| 4 | **App ikonu = Flutter varsayılanı** (mavi "F"; `Icon-App-1024x1024@1x.png` doğrudan görüldü). Guideline reddi. | `içerik` (marka görseli) | **kurucu** |
| 5 | **Onboarding EKRANI ve tetiği yok** — ama ⚠️ **metni HAZIR.** `config/copy/disclaimers.en.json → disclaimers.onboarding` tam metni **ve yüzeyini** beyan ediyor (*"First launch, one-time screen, must be acknowledged"*). Eksik olan **ekran** (`lib/app/`'te 0 dosya) ve **ilk-açılış tetiği** (kabukta 0 atıf). *Beyanın varlığı, tetiğinin varlığı değil* — ve bu, ilk yazdığım *"onboarding yok"*tan **daha küçük** bir iş. | `kod` (içerik ✅) | **saat–gün** |
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

**Kameranın çalışmaması ÜÇ ayrı sebepten, ve üçü de bağımsız:**
① kabuk kamerayı **hiç çağırmıyor** · ②b poz modeli **yok** (kamera *başlamaz*)
· ② izin metni yok (kamera *çökertir*). **Üçü de aynı commit ailesinde
çözülmeli**, yoksa her biri diğerinin arkasına saklanır.

**Kritik yol:** ①+②+②b (kamera bağlama + izin metni + poz modeli — **aynı
commit ailesi**; izin metnini kapı zorunlu kılıyor) → ⑤ onboarding → ③④ store teknik/görsel → ⑥ metadata.

---

## EK ÖLÇÜM (11:5x) — Choreia tuzağı ve dokunulabilirlik

**② `pubspec` varlık beyanı:** `rootBundle` bugün **iki** yol okuyor
(`config/tests/…`, `config/ia/…`) ve **ikisi de beyanlı** → **çökme yok**.
Ama `config/copy/` · `config/content/` · `config/harvest/` **beyansız** ve
diskte duruyor. Testler `File()` ile **diskten**, cihaz `rootBundle` ile
**bundle'dan** okuyor — biri `rootBundle`'a girdiği an **cihazda çöker,
testler yeşil kalarak.** → kapı kuruldu (`ship_blocker_test`), sabotajla
kanıtlandı.

**İki kaynak tek olgu:** `limitsCopy` config'ten **elle taşınmış** bir kopya;
bugün **birebir** ama kapısı yoktu → kapılandı.

⚠️ **Kendi ölçüm aracım bu turda üç kez yanlış rapor verdi** — `assets:`
parser'ı *"hiçbiri beyanlı değil"* dedi (yanlış), iç içe JSON anahtarını
bulamayıp **iki boş dizeyi eşitledi** (vakum-doğru "✅"), ve tırnak karışımı
yüzünden Dart sabitini okuyamadı. Üçü de **düzeltilip yeniden ölçüldü**.
