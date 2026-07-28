# Kamera Kurulumu ve Ölçüm Hatası — 2026-07-26

Kaynak: G0 tazeleme fan-out

## Özet

Kamera yerleşimi (mesafe, açı, düzlem seçimi), pose-tabanlı eklem açısı ölçümünün doğruluğunu tek başına domine eden değişken. JMIR 2026 e82412 çalışması, squat/push-up için 12 kamera konfigürasyonunu (3 açı × 4 mesafe) test etmiş: en iyi sonuç diyagonal (~45°) 180-200 cm'de (squat %95.5 doğruluk, MAE=0.05 tekrar), en kötü sonuç yan (side) 90 cm'de (squat %0 doğruluk, MAE=5). Bağımsız literatür bunu destekliyor: sagittal düzlemde kamera-tarafı (görünür) eklemler 1.5-4° hata ile marker-based sistemlere yakın performans gösterirken, kameraya uzak (occluded) taraf ~2x hata büyümesi yaşıyor; frontal düzlemde ayak bileği hata payı ROM'un %35-46'sına ulaşıyor (kullanılamaz seviye). Genel 2D markerless ROM hatası eklem/harekete göre 2-10° (kalça/diz) ile 10-28° (dirsek, ayak bileği) arasında değişiyor; derinlik (kameraya doğru/uzağa hareket) hatası yatay/dikey hatanın 2-3 katı. Bu bulgular Lissom'un kalibrasyon sihirbazı için somut kabul kriterlerine çevrilebilir durumda.

## Bulgular (kanıtlı, URL'li)

1. **JMIR mHealth 2026;14:e82412 (Oliosi et al.)** — Smartphone kamera açısı/mesafesinin squat ve push-up için AI pose-tabanlı tekrar sayımına etkisini test eden gözlemsel çalışma. 3 açı (front/side/diagonal) × 4 mesafe kombinasyonu.
   - Squat: en iyi diagonal görüş, 200 cm'de %95.5 doğruluk, MAE=0.05; en kötü side görüş, 90 cm'de %0 doğruluk, MAE=5.
   - Push-up: front 90 cm ve diagonal 360 cm görüşleri, side-90cm'e göre sınıflandırma odds'unu anlamlı düşürüyor (yani daha kötü); diagonal yakın/orta mesafe görüşleri far-front görüşlerden anlamlı düşük MAE veriyor.
   - Genel sonuç: **diyagonal ve frontal görüşler, 180-200 cm orta mesafede en yüksek tespit doğruluğu ve sayım hassasiyeti veriyor.**
   - URL: https://mhealth.jmir.org/2026/1/e82412 (tam metin PDF metin-olarak çıkarılamadı — "erişilemedi", yalnız arama-motoru özeti + WebSearch snippet'leri kullanıldı; sayısal iddialar bu snippet'lerden alındı, ikinci bir bağımsız arama sorgusuyla çapraz doğrulandı).

2. **Examination of 2D frontal and sagittal markerless motion capture (PLOS ONE, biorxiv 2023.01.17.523930)** — Frontal vs sagittal düzlem karşılaştırması, yürüme analizi.
   - Kamera-tarafı (görünür) sagittal diz açısı farkı: 1.5° ± 4.1° (marker-based referansla), literatürdeki marker-based hata payı olan 2.8° ± 2.6°'ya yakın/kabul edilebilir.
   - Occluded-taraf (kameraya uzak) kalça/diz açıları, kamera-tarafına göre ~2x varyasyon (kalçada +%108 std-of-bias artışı).
   - Frontal düzlemde ayak bileği: standart sapma/bias, toplam ROM'un kalça için %46, diz için %35, ayak bileği için %39'unu oluşturuyor — klinik olarak sorunlu belirsizlik.
   - Frontal düzlem ayak bileği "limits of agreement" değeri 23.8°'ye ulaşıyor → tüm gait cycle boyunca güvenilmez.
   - Sagittal ayak bileği yalnızca early/mid-stance'te kullanılabilir, swing phase'de değil.
   - URL: https://journals.plos.org/plosone/article?id=10.1371%2Fjournal.pone.0293917

3. **Assessment of monocular human pose estimation models for clinical movement analysis (PMC12589393)** — RTMPose/HRNet/OpenPose/Detectron2 karşılaştırması, 4 kamera (2 yükseklik: 270mm ve 950mm), 3-3.5 m mesafe, 30fps.
   - Diz fleksiyonu (2D projeksiyon) MAE: 9.3°-28.4° (model bağımlı; en iyi RTMPose ~9.3°); uzman görsel değerlendirme referansı ~25° MAE.
   - Dirsek fleksiyonu MAE: 21.5°-35.8° (en iyi 21.5°); uzman görsel değerlendirme 10-15° ile HPE'den daha iyi.
   - Frontal düzlemde dikey hata yatay hatadan belirgin büyük; sagittal düzlemde yatay/dikey hatalar birbirine daha yakın.
   - Derinlik (self-occlusion kaynaklı) hatası, yatay/dikey hatanın 2-3 katı.
   - 2D pozisyon hatası (mm, joint-level ortalama): RTMPose ~72mm, HRNet ~85mm, OpenPose ~100mm, Detectron2 ~122mm.
   - Bulgular laboratuvar koşullarında (tek kişi, uniform ışık, minimal arka plan karmaşası) elde edilmiş — ev/klinik ortamında performansın düşebileceği açıkça belirtiliyor.
   - URL: https://pmc.ncbi.nlm.nih.gov/articles/PMC12589393/

4. **Genel 2D markerless ROM hata literatürü (WebSearch derlemesi, çoklu kaynak — OpenPose/DeepLabCut karşılaştırmaları)** — Yürüme/koşu/bisiklet hareketlerinde ortalama eklem açısı hatası: yürüyüş 3.0°, koşu 4.1°, bisiklet 4.0°; ROM hatası sırasıyla 2.7°, 2.3°, 4.3°. Kalça ve diz için ayakta durma hareketlerinde tahmin hatası <10°; ayak bileğinde limits-of-agreement ±12° ile "pratik uygulamalar için çok yüksek" değerlendirilmiş. (DOĞRULANMADI — bu rakamlar WebSearch AI-özeti üzerinden geldi, orijinal makale URL'si arama sonuçlarında net tekil kaynağa bağlanamadı; muhtemelen Pose2Sim/PMC9002957 ailesi ama tam eşleşme doğrulanmadı.)
   URL (aday kaynak, doğrulanmamış eşleşme): https://pmc.ncbi.nlm.nih.gov/articles/PMC9002957/

5. **Diz kinematiği tek-akıllı-telefon-kamera + MediaPipe (arXiv / countermovement jump çalışmaları)** — Diz fleksiyonu MAE 4.10°±2.32° (sağ) ve 3.15°±3.10° (sol); countermovement jump analizinde MSE <5.7°, MAE <4.5°, maksimum amplitüd hatası <3.2°.
   URL: https://arxiv.org/pdf/2302.10749 ve https://www.ncbi.nlm.nih.gov/pmc/articles/PMC11451555/ (WebSearch snippet üzerinden; tam metin doğrudan fetch edilmedi — "erişilemedi" düzeyinde, yalnız arama özeti).

6. **Lens distorsiyon düzeltmesi** — "Single Camera Calibration" tipi uygulamalarla smartphone lens distorsiyonu düzeltilebiliyor; bir çalışma ortalama tahmin hatasını %0.09'a indirdiğini bildiriyor (DOĞRULANMADI — kaynak makale tam metni açılmadı, yalnız WebSearch özeti; hangi lens/mesafe koşulunda geçerli olduğu belirsiz).
   URL (aday): https://opg.optica.org/ao/abstract.cfm?uri=ao-53-29-H1

## Ürüne doğrudan girdi

**Lissom kalibrasyon sihirbazı — önerilen kabul kriterleri (taslak, kurucu onayına açık):**

- **Mesafe aralığı:** 180-200 cm (kamera-kişi), JMIR e82412'nin en yüksek doğruluk bandı. 90 cm gibi yakın mesafeler REDDEDİLMELİ (squat'ta %0 doğruluğa düşüyor). >300-360 cm gibi çok uzak mesafeler de push-up'ta doğruluğu düşürüyor — üst sınır ~250 cm önerilir (JMIR'de test edilen tam ara mesafe değerleri tam metinden doğrulanamadı, bu üst sınır ihtiyatlı bir enterpolasyon; DOĞRULANMADI net sayı).
- **Kamera yüksekliği:** Tüm vücut testleri için kalça/göbek hizasına yakın (tripod ~90-110 cm), egzersize göre ayarlanabilir olmalı. PMC12589393'teki 270mm/950mm test noktaları arasında en detaylı ROM verisi yayınlanmamış — spesifik "ideal yükseklik cm" değeri DOĞRULANMADI, sadece "göz/kalça hizası" genel kural olarak literatürden çıkarılabilir.
- **Açı:** Diyagonal (~45°) veya frontal, ASLA yan (side, 90°) — side görüş squat'ta en kötü sonuç (%0 doğruluk). Sagittal (yandan) düzlem gerektiren testlerde (ör. diz fleksiyon ROM) kamera-tarafı (vücudun kameraya yakın yarısı) ölçülmeli; uzak taraf 2x hata riski taşıyor → tek-taraflı sagittal testlerde kullanıcı kamera-yakın tarafını göstermeli, uygulama hangi tarafın ölçüldüğünü net belirtmeli.
- **Kadraj doluluk oranı:** Nicel bir yüzde literatürde bulunamadı (DOĞRULANMADI); pratik kural: tüm hareket ROM'u boyunca tüm eklemler kadraj dışına çıkmamalı, baş-ayak arası kadrajın ortasında %70-85 doluluk hedeflenebilir (bu ürün-tarafı sağduyu önerisidir, araştırmayla doğrulanmamış — MVP'de A/B test edilmeli).
- **Düzlem seçimi eklem/test bazında:**
  - Diz/kalça fleksiyon-ekstansiyon ROM testleri → **sagittal** (yandan), kamera-tarafı bacak ölçülmeli.
  - Omuz abdüksiyon, kalça abdüksiyon gibi frontal düzlem hareketleri → frontal çekim kaçınılmaz olsa da, ayak bileği/alt ekstremite frontal ölçümlerinden KAÇIN (ROM'un %35-46'sı kadar hata) — bu tür testler ya çıkarılmalı ya da "düşük güven" etiketiyle sunulmalı.
  - Squat/genel tüm-vücut mobilite hareketleri → **diyagonal (~45°) veya frontal**, kesinlikle side değil.
- **Düzlem-dışı hareket hatası:** Derinlik ekseninde (kameraya doğru/uzağa) hata, düzlem-içi (yatay/dikey) hatanın **2-3 katı**. Kalibrasyon sihirbazı kullanıcıyı "hareketi kameraya paralel düzlemde yap" diye net uyarmalı; kullanıcı kameraya doğru/uzağa eğilirse güven skoru düşürülmeli.
- **Beklenen ölçüm hata payı (kullanıcıya/üründe raporlanacak "güven aralığı" için girdi):** İyi kurulumda (sagittal, kamera-tarafı, 180-200cm) diz/kalça için ~1.5-5°, dirsek için ~10-20°, ayak bileği (özellikle frontal) için ±12-24° — bu değerler ürünün "±X derece hassasiyet" iddiasında ASLA tıbbi kesinlik dili olmadan, "tahmini" olarak sunulmalı.
- **Kalibrasyon sihirbazı akışı önerisi:** (1) MediaPipe landmark confidence + tüm gerekli eklemlerin kadrajda olduğunu kontrol et, (2) kullanıcı-kamera mesafesini vücut boyu/landmark ölçeğinden tahmin et, 180-200cm dışında ise "biraz geri/ileri git" uyarısı, (3) açı sapmasını omuz-kalça hattının kameraya göre açısından hesapla, side'a (~90°) yakınsa "kamerayı diyagonal konuma al" uyarısı ver, (4) zemin/arka plan için yüksek-kontrast basit arka plan öner (spesifik araştırma bulunamadı, sağduyu önerisi — DOĞRULANMADI).

## Açık sorular

1. JMIR e82412'nin tam metin PDF'i text olarak çıkarılamadı (binary/tarama sorunu) — kesin mesafe aralıkları (ör. tam olarak hangi 4 mesafe test edildi: 90/180/200/360 cm dışında ara değer var mı) ve açı derecelerinin (diagonal tam olarak kaç derece) tam sayısal tablosu doğrulanamadı. Kapatmak için: PDF'i doğrudan indirip OCR/metin katmanından okumak gerekir (bu oturumda erişim/araç kısıtı nedeniyle yapılamadı).
2. "Kadraj doluluk oranı" (vücudun kare içinde kapladığı % alan) için doğrudan hakemli bir sayısal öneri bulunamadı — bu Lissom'un kendi test verisiyle (pilot kullanıcı kaydı + MediaPipe confidence skoru korelasyonu) deneysel olarak kalibre edilmesi gereken bir parametre olarak kalıyor.
3. Lens distorsiyonunun günümüz akıllı telefonlarında (geniş açı / ultra-geniş açı kameralar dahil) ROM ölçümüne pratik etkisi net rakamla doğrulanamadı; bulunan "%0.09 hata" rakamı hangi lens/koşulda geçerli belirsiz, MediaPipe'ın kendi lite/full/heavy modellerinin lens distorsiyonuna duyarlılığı ayrı bir soru — ayrı bir araştırma turu gerektirir.

## Kaynaklar

- https://mhealth.jmir.org/2026/1/e82412
- https://mhealth.jmir.org/2026/1/e82412/PDF (erişilemedi — metin çıkarılamadı)
- https://journals.plos.org/plosone/article?id=10.1371%2Fjournal.pone.0293917
- https://www.biorxiv.org/content/10.1101/2023.01.17.523930.full.pdf (aynı çalışmanın preprint hali)
- https://pmc.ncbi.nlm.nih.gov/articles/PMC12589393/
- https://pmc.ncbi.nlm.nih.gov/articles/PMC9002957/ (Pose2Sim — doğrulanmamış eşleşme, bkz. Açık sorular)
- https://arxiv.org/pdf/2302.10749
- https://www.ncbi.nlm.nih.gov/pmc/articles/PMC11451555/
- https://opg.optica.org/ao/abstract.cfm?uri=ao-53-29-H1 (doğrulanmamış, bkz. Bulgular #6)
