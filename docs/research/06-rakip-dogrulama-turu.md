# Rakip Doğrulama Turu — 2026-07-26

Kaynak: G0 tazeleme fan-out

## Özet

GOWOD, Pliability (eski ROMWOD), StretchIt, Bend, Down Dog ve Alo Moves'ın 2026 güncel fiyatları web kaynaklarıyla doğrulandı. Fiyat aralığı aylıkta $9.99–$19.99, yıllıkta $39.99–$179.95 arasında değişiyor; hepsi 7-22 günlük ücretsiz deneme sunuyor. "Flexify" adında belirgin bir pazar oyuncusu bulunamadı (DOĞRULANMADI/muhtemelen kastedilen başka bir isim — Flexy/Flex/Flexio gibi benzer adlı küçük oyuncular var). GOWOD'un mobilite testi mekanizması kamuya açık kaynaklarla NET olarak çözüldü: kamera/CV tabanlı DEĞİL, video-karşılaştırmalı öz-değerlendirme (slider ile kullanıcı kendi hareket videosunu referans videoyla eşleştiriyor). Bu, Lissom'un "gerçek CV ile ölçüm" konumlandırmasını güçlü şekilde destekliyor. 2025-2026'da çıkan yeni rakiplerde tüketiciye yönelik, kamera-tabanlı mobilite testi sunan doğrudan bir rakip bulunamadı; bulunan kamera/pose-estimation projeleri (PoseIQ, QuickPose.ai, "Posed") ya B2B/okul-kulüp odaklı ya da fotoğraf-pozu odaklı, mobilite-assessment tüketici uygulaması değil.

## Bulgular (kanıtlı, URL'li)

### GOWOD
- Fiyat: En ucuz seçenek aylık $9.99; yıllık ödemede aylık $7.49'a denk gelen ~$90/yıl paket. Kaynak: [GOWOD App Review 2026](https://simplmobility.com/blog/gowod-app-review)
- Ücretsiz deneme: 7 gün, "Risk free - No commitment - Cancel anytime". Kaynak: [GOWOD Pricing](https://www.gowod.app/pricing) (WebFetch ile doğrulandı; premium fiyat sayfada placeholder "$000.00" gösteriyor — canlı fiyat sayfa render hatası, gerçek tutar signup akışında).
- Mobilite testi ÜCRETSİZ: "The flexibility test and access to the exercise video library are free, however other features require a monthly, bi-annual, or annual fee." Kaynak: [GOWOD App Review 2026](https://simplmobility.com/blog/gowod-app-review)
- **Test mekanizması ÇÖZÜLDÜ — CV DEĞİL, öz-değerlendirme:** "GOWOD's mobility assessment doesn't rely on video analysis. Instead, you watch a demonstration video of someone performing the movement thoroughly, then you're given a slider to adjust. As you move the slider, the video adjusts to show you the corresponding frame." Kaynak: [How Does The GOWOD App Work?](https://www.gowod.app/how-it-works) (arama motoru özetinden; orijinal sayfa doğrudan fetch edilmedi — WebSearch snippet'i kullanıldı)
- Premium sonucu iddiası: "premium users improving their mobility score by an average of 18% in just 60 days" — GOWOD'un kendi pazarlama iddiası, bağımsız doğrulama YOK. Kaynak: [GOWOD Pricing](https://www.gowod.app/pricing)
- App Store puanı: 4.81/5 (~3.1k puan, iOS); Google Play 4.50/5 (~6.3k puan). İndirme: 500k-750k+ (Android), kendi iddiasıyla "1.7 million athletes" kullanıcı tabanı (bağımsız doğrulanmadı). Kaynak: [AppGrooves GOWOD](https://appgrooves.com/app/gowod-by-gowod), [AppBrain GOWOD](https://www.appbrain.com/appstore/gowod-mobility-stretching/ios-1227834875)

### Pliability (eski ROMWOD)
- Fiyat: $19.95/ay veya yıllık planda aylık $14.99'a denk gelen ~$179.95/yıl. Kaynak: [Pliability App Review 2026](https://simplmobility.com/blog/pliability-app-review), [ROMWOD is now pliability](https://pliability.com/targets/romwod)
- Ücretsiz deneme: 7 gün, kart bilgisi istiyor — kullanıcı yorumlarında iade politikası eleştirisi var ("no refunds once the card is charged", Nisan 2026 Trustpilot yorumu). Kaynak: [Pliability Review 2026](https://feelingbetter.io/pliability-review/), [Trustpilot](https://www.trustpilot.com/review/pliability.com)
- Assessment/ölçüm iddiası: bulunan kaynaklarda CV veya kamera tabanlı bir mobilite testi iddiası YOK — ürün video-eşliğinde mobilite rutinleri (1,700+ rutin) sunuyor, GOWOD'daki gibi bir "test" akışına dair kanıt bulunamadı → DOĞRULANMADI (Pliability'nin ölçüm mekanizması var mı/yok mu net değil, ayrı bir teardown gerekir).
- App Store: Trustpilot'ta yalnız 32 yorum var; App Store/Play puan sayısı bu turda net rakamla doğrulanamadı → "erişilemedi/DOĞRULANMADI" (sayfa taraması dolaylı, doğrudan Apple/Play sayfası fetch edilmedi).

### StretchIt
- Fiyat: $19.99/ay veya $159.99/yıl (%33 tasarruf). Kaynak: [STRETCHIT Review 2026](https://fitnessdrum.com/stretchit-review/)
- Ücretsiz deneme: 7 gün. Kaynak: aynı.
- App Store: 4.8/5 (12,000+ yorum, iOS); Android 4.6/5 (1,100 yorum), Android indirme 100,000+. Kaynak: aynı.
- Kamera/CV tabanlı ölçüm iddiası bulunamadı → StretchIt video-rehberli esneme dersleri sunuyor, assessment mekanizması yok gibi görünüyor (DOĞRULANMADI, negatif kanıt).

### Bend
- Fiyat: $13.99/ay veya $39.99/yıl; ücretsiz katmanda yalnızca 1 adet 5-dakikalık rutin var. Kaynak: [Bend App Cost](https://pliability.com/stories/bend-app-cost)
- Ölçek: 15 milyon kullanıcı iddiası, aylık $1.1M gelir (kendi/üçüncü-parti pazarlama analizi iddiası, bağımsız doğrulanmadı). Kaynak: [Bend Onboarding Teardown](https://tasu.ai/library/bend-stretching-onboarding-teardown-paywall-strategy)
- CV/kamera tabanlı ölçüm iddiası bulunamadı → DOĞRULANMADI (negatif kanıt, ürün genel esneme/postür rutinleri sunuyor).

### Down Dog
- Fiyat: Standart $9.99/ay veya $59.99/yıl (app store üzerinden); web sitesinden doğrudan alımda $7.99/ay veya $39.99/yıl. Kaynak: [Down Dog App Review 2026](https://www.garagegymreviews.com/down-dog-app-review)
- Ücretsiz deneme: 22 gün (öğrenci/öğretmen/sağlık çalışanı indirimleri de var). Kaynak: aynı.
- Down Dog bir yoga-akış üretici uygulaması; mobilite testi/assessment iddiası bulunamadı → DOĞRULANMADI (negatif kanıt; kapsamı farklı: sonsuz varyasyonlu yoga/HIIT/meditasyon akışları, ölçüm değil).

### Alo Moves
- Fiyat: $12.99/ay veya $129.99/yıl, 14 gün ücretsiz deneme. NOT: Alo Moves 2025-2026'da hibrit modele geçti — bazı içerik ücretsiz, tam kütüphane ücretli katmanla açılıyor (fiyatlandırma önceki $19.99'dan aşağı çekilmiş). Kaynak: [Alo Moves Fitness App Pricing Lowered](https://themantraco.com/exciting-news-alo-moves-fitness-app-pricing-just-got-lowered-to-12-99-month-or-129-year/)
- Kamera/CV tabanlı mobilite testi iddiası bulunamadı → DOĞRULANMADI (negatif kanıt; ürün geniş yoga/fitness video kütüphanesi, ölçüm/assessment odaklı değil).

### Flexify
- Bu isimde net bir pazar oyuncusu bulunamadı. Yakın isimli küçük oyuncular var: "Flexy" (birden fazla farklı app, aynı isim), "Flex", "Flexio" — hiçbiri belirgin pazar payı/CV-tabanlı ölçüm sinyali göstermiyor. DOĞRULANMADI — muhtemelen kullanıcı/prompt'ta kastedilen isim farklı bir üründür veya "Flexify" pazardan çekilmiş/yeniden adlandırılmış olabilir.

### 2025-2026 yeni rakip taraması (kamera/CV tabanlı mobilite testi arayışı)
- **PoseIQ** (poseiq.com): "movement intelligence" — canlı kamera ile hareket takibi, gerçek zamanlı geri bildirim ve performans skorlama sunuyor, ama hedef kitlesi okul/kulüp/PE-STEM oturumları ve klinikler/kurumlar — TÜKETİCİ mobilite-app'i değil, B2B/kurumsal. Fiyatlandırma bulunamadı. Kaynak: [PoseIQ](https://poseiq.com/)
- **QuickPose.ai**: pose-estimation SDK/altyapı sağlayıcısı, kendi tüketici mobilite app'i değil — geliştiricilere satılan bir araç. Kaynak: [QuickPose.ai](https://quickpose.ai/)
- **"Posed: AI Pose Coach"**: fotoğraf/poz önerisi (influencer/fotoğrafçı hedefli), mobilite ölçümüyle ilgisi YOK — arama sırasında yanlışlıkla eşleşen alakasız bir sonuç. Kaynak: [Posed App Store](https://apps.apple.com/us/app/posed-ai-pose-coach/id6762599608)
- **Akademik/klinik referanslar** (Lissom'un iddialarını destekleyen ama tüketici rakip DEĞİL): JMIR 2026 markerless motion capture scoping review ve iPad-kamera tabanlı sit-to-stand/TUG/SPPB doğrulama çalışması, "eğitimli sağlık profesyoneli skorlamasıyla güçlü uyum" bulmuş — bu, kamera-tabanlı ev-ölçümünün bilimsel olarak makul olduğunu gösteriyor ama bu çalışmalar tüketici ürünleri değil. Kaynak: [JMIR mHealth e65474 scoping review](https://mhealth.jmir.org/2026/1/e65474), [PLOS Digital Health markerless validation](https://journals.plos.org/digitalhealth/article?id=10.1371%2Fjournal.pdig.0001172)
- **Sonuç:** 2025-2026 taramasında Lissom'un iddia ettiği "telefon kamerasıyla on-device CV mobilite ölçümü + günlük kişiselleştirilmiş program + 4 haftalık yeniden ölçüm" kombinasyonunu tüketici pazarında aynı anda sunan DOĞRUDAN bir rakip bulunamadı. Bu, konumlandırma boşluğunu destekliyor ama "hiç rakip yok" iddiası yerine "bu turda bulunamadı" olarak okunmalı — App Store/Play kategori taraması (arama terimleriyle sınırlı WebSearch, doğrudan mağaza kategori sayfası taranmadı) tam kapsamlı değil.

## Ürüne doğrudan girdi

**Fiyat karşılaştırma tablosu (2026, doğrulanmış aylık/yıllık fiyatlar):**

| Ürün | Aylık | Yıllık | Ücretsiz deneme | Ölçüm/Assessment | Kaynak |
|---|---|---|---|---|---|
| GOWOD | $9.99 | ~$90 (~$7.49/ay) | 7 gün | VAR — ama CV değil, video-slider öz-değerlendirme | [1](https://simplmobility.com/blog/gowod-app-review) [2](https://www.gowod.app/pricing) [3](https://www.gowod.app/how-it-works) |
| Pliability | $19.95 | $179.95 (~$14.99/ay) | 7 gün | Net kanıt yok (DOĞRULANMADI) | [4](https://simplmobility.com/blog/pliability-app-review) |
| StretchIt | $19.99 | $159.99 | 7 gün | Yok (negatif kanıt) | [5](https://fitnessdrum.com/stretchit-review/) |
| Bend | $13.99 | $39.99 | Sınırlı ücretsiz (1 rutin) | Yok (negatif kanıt) | [6](https://pliability.com/stories/bend-app-cost) |
| Down Dog | $9.99 (app) / $7.99 (web) | $59.99 / $39.99 | 22 gün | Yok — kapsam farklı (yoga akış üretici) | [7](https://www.garagegymreviews.com/down-dog-app-review) |
| Alo Moves | $12.99 | $129.99 | 14 gün | Yok — geniş video kütüphanesi | [8](https://themantraco.com/exciting-news-alo-moves-fitness-app-pricing-just-got-lowered-to-12-99-month-or-129-year/) |
| Flexify | DOĞRULANMADI — pazarda belirgin ürün bulunamadı | — | — | — | — |

**Lissom fiyat konumlandırması için sayısal girdi:** Kategori aylık fiyat bandı $9.99–$19.99 arasında oturmuş; $9.99-$12.99 bandı (GOWOD, Down Dog, Alo Moves) "erişilebilir/geniş kitle" konumu, $19.99+ bandı (Pliability, StretchIt) "premium/derin içerik kütüphanesi" konumu olarak ayrışıyor. Lissom'un CV-tabanlı gerçek ölçüm iddiası bu iki bandın da sunmadığı bir değer önerisi olduğundan, fiyatı GOWOD ile StretchIt arasına ($12.99–$16.99 aylık bandı) konumlandırmak, "ölçüm bazlı, GOWOD'dan daha objektif" farklılaşmasını fiyatla da destekler — ama bu ÖNERİ, kesin sayı için kendi CAC/LTV modelinizle çapraz kontrol edilmeli.

**Savunulabilir farklılaşma cümlesi (önerilen, kanıta dayalı):**
"GOWOD'un mobilite testi kullanıcının kendi öznel slider ayarına dayanır ('demo videoyla eşleştir'); Lissom, telefon kameranızla MediaPipe Pose Landmarker tabanlı gerçek hareket-yakalama ile ölçer — kendi gözünüze değil, verinize güvenin."
Bu cümle GOWOD'un kendi "how-it-works" sayfasından doğrulanan mekanizma farkına dayanıyor, bu yüzden savunulabilir.

**Kaçınılması gereken abartılı iddialar:**
1. "Piyasadaki TEK kamera-tabanlı mobilite ölçüm app'i" DEME — bu turda doğrudan tüketici rakibi bulunamadı ama tarama App Store/Play kategori sayfalarını tam taramadı; iddia "bulduğumuz rakipler arasında" ile sınırlı kalmalı.
2. GOWOD'un "%18 mobilite artışı 60 günde" gibi rakip pazarlama istatistiklerini kıyaslama olarak KULLANMA — bu GOWOD'un kendi doğrulanmamış iddiası, bilimsel kaynak değil.
3. Pliability/StretchIt/Bend/Down Dog/Alo Moves için "onlarda ölçüm YOK" derken kesin dil kullanma — bu turda negatif kanıt (bulunamama) var, ama kapsamlı ürün-içi teardown yapılmadı; "kamuya açık kaynaklarda ölçüm iddiasına rastlanmadı" şeklinde temkinli ifade kullan.
4. Tıbbi/teşhis dili zaten yasak (ürün kısıtı) — rakip karşılaştırmasında da "GOWOD'un testi yanlış/geçersiz" gibi iddialı-negatif dil kullanma; "mekanizması farklı" nötr çerçevesi kullan.

## Açık sorular (kapatılamayanlar, neden)

1. **Pliability'nin kendi bir mobilite testi/assessment akışı var mı?** Kamuya açık blog/inceleme kaynaklarında net bir "test" akışı tarifi bulunamadı (GOWOD'daki gibi detaylı bir "how it works" sayfası incelemesi yapılamadı). Elle teardown (uygulamayı indirip onboarding akışını gözlemlemek) gerekiyor.
2. **StretchIt/Bend/Down Dog/Alo Moves'ta gizli/az bilinen bir "değerlendirme" özelliği var mı?** Bu turda yalnızca genel pazarlama/inceleme sayfaları tarandı, uygulama içi onboarding akışları doğrudan gözlemlenmedi — kamuya açık kaynaklar bu düzeyde detay vermiyor.
3. **App Store/Play kategori taramasıyla 2025-2026'da çıkan TÜM yeni "mobility test" tüketici uygulamaları bulundu mu?** WebSearch anahtar-kelime aramasıyla sınırlı kaldı; mağaza kategori sayfalarının (App Store "Health & Fitness" yeni-çıkanlar, Play "mobility" arama sonuçları ilk 50) doğrudan taranması yapılmadı — bu, gerçek bir mağaza-arama oturumu (Chrome MCP ile canlı App Store/Play taraması) gerektirir, bu turda kapsam dışı tutuldu (prompt keşif yasağı + zaman kısıtı).

## Kaynaklar

- https://www.gowod.app/pricing
- https://www.gowod.app/how-it-works
- https://simplmobility.com/blog/gowod-app-review
- https://appgrooves.com/app/gowod-by-gowod
- https://www.appbrain.com/appstore/gowod-mobility-stretching/ios-1227834875
- https://simplmobility.com/blog/pliability-app-review
- https://pliability.com/targets/romwod
- https://feelingbetter.io/pliability-review/
- https://www.trustpilot.com/review/pliability.com
- https://fitnessdrum.com/stretchit-review/
- https://pliability.com/stories/bend-app-cost
- https://tasu.ai/library/bend-stretching-onboarding-teardown-paywall-strategy
- https://www.garagegymreviews.com/down-dog-app-review
- https://themantraco.com/exciting-news-alo-moves-fitness-app-pricing-just-got-lowered-to-12-99-month-or-129-year/
- https://poseiq.com/
- https://quickpose.ai/
- https://apps.apple.com/us/app/posed-ai-pose-coach/id6762599608
- https://mhealth.jmir.org/2026/1/e65474
- https://journals.plos.org/digitalhealth/article?id=10.1371%2Fjournal.pdig.0001172
