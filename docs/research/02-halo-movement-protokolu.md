# Amazon Halo Movement — Doğrulama Protokolü Derinlemesine (2026-07-26)

Kaynak: G0 tazeleme fan-out

## Özet

Amazon Halo Movement, tek bir akıllı telefon kamerasıyla (yer'e yatay yerleştirilmiş, kullanıcı ekrandaki kareye tam sığacak şekilde) 5 hareketten oluşan bir test bataryası uygulayıp mobilite/stabilite/postür alt-skorlarından 0-100 arası "movement health" skoru üreten, artık üretimden kaldırılmış (2023-08-01, Halo hattı tamamen kapatıldı) bir Amazon ürünüydü. Doğrulama makalesi (npj Digital Medicine, Eylül 2022, n=150 yetişkin, 18-85 yaş) Xsens MVN Awinda 17-sensörlü IMU sistemini ve fizyoterapist uygulamalı 13 klinik testi altın-standart olarak kullandı; genel skor ile referans testler arası r=0.29-0.63, Xsens metrikleriyle r=0.23-0.83 (p<0.05) bulundu. Hareket-bazlı korelasyon kırılımı makalede AYRI raporlanmamış — bu Lissom için önemli bir boşluk. Test-tekrar-test değişkenliği (CV=%1.64±1.42) düşük skorlu (mobilite-kısıtlı) grupta belirgin şekilde arttı (%2.16 vs %1.60), yani cihaz zayıf hareketlilikte daha az güvenilir. Kullanıcıya sunulan tavsiye: 2-4 haftada bir yeniden ölç.

## Bulgular (kanıtlı, URL'li)

### Çalışma tasarımı ve örneklem
- Toplam n=150 yetişkin (18-85 yaş): 113 sağlıklı (%62.8 kadın), 17 atlet (%94.1 kadın), 20 hareket-kısıtlı (%35 kadın). Demografik: %74 Kafkasyalı, %15.3 Asyalı, %4.7 Siyahi, %3.3 Hispanik, %2.7 çok-ırklı. Yaş dağılımı: 18-29 %29.3, 30-39 %29.3, 40-49 %10.7, 50-59 %9.3, 60-69 %14, 70-85 %7.3. — https://pmc.ncbi.nlm.nih.gov/articles/PMC9445016/
- Çocuk (18 yaş altı) ve ciddi hareket kısıtlılığı olup testi tamamlayamayan bireyler ÇALIŞMA DIŞI bırakıldı. — https://pmc.ncbi.nlm.nih.gov/articles/PMC9445016/

### 5 hareketin talimat/tekrar/süre/metrik detayı
Kamera kurulumu tüm hareketlerde ortak: telefon yere yatay yerleştirilir, kullanıcı ekrandaki kareye tüm vücudu görünecek şekilde konumlanır (yaklaşık diz-hizası/alçak açı, tam-vücut görüş).

1. **Single-leg stance** — Talimat: "stand upright on one leg and hold the position as steady as possible for ten seconds"; her bacak için 10 saniye. Çıkarılan metrikler (Xsens karşılaştırmalı): postural sway (kütle merkezi ivmesinin X-Y düzleminde %95 güven elipsi), yerdeki ayak-parmağı dokunma sayısı, maksimum lateral gövde açısı, lateral gövde açısı varyansı. — https://pmc.ncbi.nlm.nih.gov/articles/PMC9445016/
2. **Forward lunge** — Talimat: gövdeyi dik tutarak öne doğru lunge yap, dizi yere hafifçe dokundur; her iki bacakta 3 tekrar. Metrikler: ortalama minimum diz-yer mesafesi, maksimum lateral gövde açısı, lateral gövde açısı varyansı. — https://pmc.ncbi.nlm.nih.gov/articles/PMC9445016/ (WebSearch özeti de 3 tekrar/bacak doğruladı)
3. **Overhead squat** — Talimat: "raise their arms high above the head and squat as low as they could, holding their arms straight and steady"; 6 tekrar. Metrikler: dizlerin altında pelvis derinliği, maksimum kalça fleksiyon açısı, maksimum diz fleksiyon açısı, maksimum lateral gövde açısı, dirsek fleksiyon açısı varyansı. — https://pmc.ncbi.nlm.nih.gov/articles/PMC9445016/
4. **Overhead reach** — Talimat: "reach forward and slowly raise the arms as high above the head as possible"; 3 tekrar. Metrikler: omuz hareket açıklığı (maksimum fleksiyon açısı), maksimum dirsek fleksiyon açısı, dirsek açısı varyansı. — https://pmc.ncbi.nlm.nih.gov/articles/PMC9445016/
5. **Feet-together squat** — Talimat: "keep the feet and knees together and squat as low as possible to the ground"; 3 tekrar. Metrikler: dizlerin altında pelvis derinliği, maksimum kalça fleksiyon açısı, maksimum diz fleksiyon açısı. — https://pmc.ncbi.nlm.nih.gov/articles/PMC9445016/

### Gold-standard karşılaştırma
- Birincil: Xsens MVN Awinda — 17 kablosuz IMU sensörü, 3D eklem kinematiği; makalede "önceki çalışmalarda kapsamlı doğrulanmış" diye tanımlanıyor. — https://pmc.ncbi.nlm.nih.gov/articles/PMC9445016/
- İkincil: fizyoterapist uygulamalı 13 klinik-doğrulanmış fonksiyonel test — plumb line test, reach-behind-back, closed kinetic chain upper extremity test, Y-balance test, sit-and-reach, functional reach test, star excursion balance test, hurdle step test, unilateral hip bridge endurance test, single-leg hop test, Clinical Test of Sensory Interaction on Balance (CTSIB), Sharpened Romberg test. — https://pmc.ncbi.nlm.nih.gov/articles/PMC9445016/

### Korelasyon / güvenilirlik sonuçları
- Genel Halo skoru vs 13 fonksiyonel test: "moderate to strong statistically significant correlations, 0.29 < r < 0.63; p < 0.05." — https://pmc.ncbi.nlm.nih.gov/articles/PMC9445016/
- Genel Halo skoru vs Xsens sensör metrikleri: 0.23 < r < 0.83; p < 0.05. — https://pmc.ncbi.nlm.nih.gov/articles/PMC9445016/
- Grup ortalamaları: Atlet 86.64±5.69, Sağlıklı 81.28±6.73, Hareket-kısıtlı 68.43±6.74 (tüm farklar p<0.05). — https://pmc.ncbi.nlm.nih.gov/articles/PMC9445016/
- Test-tekrar-test güvenilirliği: genel örneklemde (n=99, 3 tekrar deneme) intra-subject CV=%1.64±1.42. Hareket-kısıtlı grupta CV=%2.16±0.99, sağlıklı grupta %1.60±1.28 — yani düşük skorlu/kısıtlı kullanıcılarda test daha az tekrarlanabilir. — https://pmc.ncbi.nlm.nih.gov/articles/PMC9445016/
- DOĞRULANMADI: Hareket-bazlı (single-leg stance / lunge / squat vb. ayrı ayrı) korelasyon veya ICC değerleri — makale bunları sadece toplu/genel-skor düzeyinde raporlamış, hareket-özel kırılım metinde açıkça verilmemiş. Bu, "hangi hareketler zayıf performans gösterdi" sorusuna kesin sayısal cevap vermeyi engelliyor.

### Zayıf performans gösteren alan
- CTSIB'in SÜRE bileşeni Halo genel skoruyla zayıf korelasyon gösterdi; makale nedenini "tavan etkisi" olarak açıklıyor — çoğu katılımcı dengeyi tüm süre boyunca koruyabildiği için ayırt edicilik düşük çıktı. Buna karşılık CTSIB sırasında ölçülen postural sway (ivme metriği) anlamlı korelasyon gösterdi — yani zaman-bazlı skorlama value kaçırırken sensör verisi farkı yakaladı. — https://pmc.ncbi.nlm.nih.gov/articles/PMC9445016/

### Limitations (tam metin, İngilizce orijinal)
> "While this study suggests that Halo Movement provides a valid assessment of movement health, there are a number of limitations to note. First, while we made best efforts to recruit a diverse sample size of ages, ethnicities, and genders, we used a sample size of convenience for this pilot study and thus so far it has mostly been shown that the halo score is valid in Caucasian, healthy populations. Further, we did not test the application on children under 18 years old, nor on individuals with significant movement impairments that prevented them from attempting the assessment. Future studies may investigate the validity of Halo Movement on a wider population. Second, while the thirteen reference tests have each been individually validated to assess the function of a specific joint or movement pattern, there exists no 'gold standard' for assessing movement health on a whole-body level. In designing the study, the combination of reference movement tests was intended to cover the entire body, but certain body parts or movement patterns may be over or under-represented in our set of reference tests, skewing correlations and regression analyses. Third, while the scope of this study focused on validating the overall score of Halo Movement, future work could focus on validating the sub-scores for mobility, stability and posture as well. Lastly, grouping participants into athlete, healthy, and movement impaired simplified a substantially complex task; the ability-level and manifestation of any movement health impairments varied significantly between individuals in each cohort. The results show, at a population-level, that Halo Movement can differentiate between groupings of these individuals, but further validation studies need to be done to determine whether Halo Movement can pinpoint the specific deficiencies of a participant." — https://pmc.ncbi.nlm.nih.gov/articles/PMC9445016/

### Skor yapısı ve kullanıcı deneyimi (kamuya açık — basın/inceleme kaynakları)
- Genel skor 0-100 aralığında; alt-kırılım Mobilite/Stabilite/Postür + gövde bölgesi bazında (core, hips, lower body, shoulders) ek bilgi. — https://www.myhealthyapple.com/amazon-halo-movement-health-score-features/
- İlk değerlendirme sonrası düşük skorlu alanlara özel kişiselleştirilmiş egzersiz programı sunuluyordu. — https://www.myhealthyapple.com/amazon-halo-movement-health-score-features/
- Amazon'un tavsiyesi: ilerlemeyi izlemek için 2-4 haftada bir yeniden değerlendirme; egzersiz seti ~5-10 dk sürüyor ve haftada en az 3 kez önerilir. — WebSearch özeti (birincil basın kaynağı ayrıştırılamadı, DOĞRULANMADI tam-orijinal-cümle düzeyinde ama birden fazla ikincil kaynakta tutarlı)
- Ürün Halo Membership'in ($3.99/ay) bir parçasıydı. — https://www.techradar.com/news/amazons-halo-fitness-tracker-can-now-help-you-avoid-throwing-out-your-back
- Skor bandı etiketleri (örn. "elite/good/below-average" gibi resmi eşik adları) kamuya açık kaynaklarda BULUNAMADI — yalnız grup ortalamaları (atlet/sağlıklı/kısıtlı) biliniyor, resmi bant sınırları DOĞRULANMADI.
- Ürün ve app 2023-08-01 itibarıyla tamamen kapatıldı (Halo Band/View/Rise donanımıyla birlikte); artık çalışmıyor. — https://www.digitaltrends.com/wearables/amazon-halo-killed-dont-trust-tech-subscriptions/

## Ürüne doğrudan girdi

Lissom'un 8-10 testlik bataryası için Halo şablonundan uyarlanmış taslak (talimat metni + süre/tekrar + çıkarılacak metrik). Halo'nun 5 hareketi + olası ek 3-5 hareket önerisi:

| # | Hareket | Talimat metni taslağı (İngilizce) | Süre/Tekrar | Çıkarılacak metrik(ler) | Kamera güvenilirlik notu |
|---|---|---|---|---|---|
| 1 | Single-leg stance | "Stand upright on one leg. Hold as steady as possible for 10 seconds." | 10 sn × her bacak | postural sway proxy (kalça/omuz merkezi salınımı), yere değme sayısı, lateral gövde açısı + varyansı | Halo'da doğrulandı (r bandında); DÜŞÜK skorlu kullanıcıda tekrarlanabilirlik daha zayıf (CV %2.16) — Lissom eşik/gürültü payı buna göre ayarlanmalı |
| 2 | Forward lunge (per leg) | "Step forward into a lunge, tap your back knee lightly to the floor, keep your torso upright." | 3 tekrar × her bacak | diz-yer minimum mesafesi, gövde açısı + varyansı | Halo'da doğrulandı; tek-kamera derinlik belirsizliği (ön-arka mesafe) için yandan çekim gerekebilir |
| 3 | Overhead squat | "Raise arms overhead, keep them straight, squat as low as you can." | 6 tekrar | pelvis-diz derinliği, kalça/diz fleksiyon açısı, gövde açısı, dirsek açısı varyansı | Halo'da doğrulandı; çok-eklemli olduğu için 2D projeksiyon hatası riski en yüksek hareketlerden — 3D BlazePose kaba tahmini burada faydalı |
| 4 | Overhead reach | "Reach forward, then slowly raise arms as high overhead as possible." | 3 tekrar | omuz fleksiyon ROM, dirsek fleksiyon açısı + varyansı | Halo'da doğrulandı; görece basit/tek-düzlemli → tek-kamera 2D için güvenilir aday |
| 5 | Feet-together squat | "Keep feet and knees together, squat as low to the ground as possible." | 3 tekrar | pelvis-diz derinliği, kalça/diz fleksiyon açısı | Halo'da doğrulandı |
| 6 (ek aday) | Trunk rotation (yoga/mobilite spesifik) | "Rotate your torso as far as comfortable to each side, keeping hips forward." | 3 tekrar × yön | omuz-kalça rotasyon açı farkı | DOĞRULANMADI — Halo bataryasında yok; MediaPipe Pose tek-kamera ile rotasyon açısını z-derinlik belirsizliği nedeniyle güvenilir ölçemeyebilir — pilot doğrulama şart |
| 7 (ek aday) | Seated forward fold / hamstring reach | "Sit with legs extended, reach forward toward toes." | 1×, statik tutuş 5 sn | parmak-ayak mesafesi proxy, gövde-bacak açısı | DOĞRULANMADI — oturma pozisyonunda kamera açısı/oklüzyon riski yüksek |
| 8 (ek aday) | Standing quad stretch balance | Halo'nun single-leg stance'ine benzer ama ek eklem açısı (diz fleksiyonu) ekli | 5-10 sn × her bacak | diz fleksiyon açısı + salınım | Tek-bacak dengesi zaten Halo'da zayıf-skor kullanıcıda güvenilirlik düşüşü gösterdi — bu varyant için DAHA DA dikkatli eşikleme gerekir |

**Kamerayla güvenilir ölçülemeyen/riskli hareketler (uyarı):**
- Derinlik-eksenli (ön-arka, kameraya doğru/kameradan uzağa) hareketler — tek 2D kamera için doğal zayıflık; Halo'nun forward lunge'ında bile bu risk var, BlazePose'un kaba 3D tahmini telafi edici olabilir ama DOĞRULANMADI (Halo makalesinde bu konuda açık ifade yok).
- CTSIB tipi süre-bazlı denge testleri "tavan etkisi" nedeniyle ayırt edici gücü düşük çıkabilir — Lissom'da salt "süre" yerine salınım/ivme-benzeri proxy metrikleri (örn. kalça merkezi hareket genliği) önceliklendirilmeli.
- Rotasyon-ağırlıklı hareketler (gövde rotasyonu, omuz iç/dış rotasyon) MediaPipe 33-landmark 2D + BlazePose kaba-3D ile güvenilirliği Halo çalışmasında test EDİLMEDİ — Lissom'un yoga-odaklı testlerinde bu tür hareketler varsa ayrı bir doğrulama turu (kendi küçük pilot + referans video ölçümü) gerekli.
- Düşük-mobiliteli/kısıtlı kullanıcı segmentinde test-tekrar-test güvenilirliği genel popülasyona göre ~%35 daha kötü (CV %2.16 vs %1.60) — Lissom'un "4 haftada yeniden ölç" karşılaştırmalarında bu grup için daha geniş güven aralığı/daha az kesin dil kullanılmalı (wellness sınırı zaten tıbbi kesinlik iddiasını yasaklıyor, bu bulgu o kısıtı pekiştiriyor).

## Açık sorular (kapatılamayanlar, neden)

1. **Hareket-bazlı korelasyon/ICC kırılımı yok** — npj Digital Medicine makalesi sadece genel-skor düzeyinde r değerleri raporluyor; hangi TEK hareketin/metricin en güçlü veya en zayıf geçerliliğe sahip olduğu makale metninde AÇIKÇA verilmemiş. Amazon Science PDF'inin ek/supplementary tablolarında olabilir ama bu oturumda erişilip taranmadı (zaman/kapsam kısıtı) — DOĞRULANMADI.
2. **Resmi skor bandı eşikleri (örn. 0-40 "needs work", 40-70 "average" gibi) bulunamadı** — yalnız grup ortalamaları biliniyor (atlet 86.64, sağlıklı 81.28, kısıtlı 68.43); bunlar bant sınırı değil, tanımlı grupların ortalama skorları. Kullanıcıya sunulan gerçek UI metni/renk kodlaması (örn. kırmızı/sarı/yeşil eşikleri) kamuya açık arşiv sayfalarında taranmadı.
3. **Amazon Science PDF (assets.amazon.science) ve GOWOD'un CV-mi-öz-değerlendirme-mi belirsizliği** — bu oturumda GOWOD taraması KAPSAM DIŞI bırakıldı (görev sadece Halo'ya odaklandı); ayrı bir fan-out turu gerekebilir.

## Kaynaklar

- https://pmc.ncbi.nlm.nih.gov/articles/PMC9445016/ (tam metin, birincil kaynak)
- https://www.nature.com/articles/s41746-022-00684-9 (yayıncı sayfası — login duvarına takıldı, PMC üzerinden okundu)
- https://pubmed.ncbi.nlm.nih.gov/36065060/
- https://assets.amazon.science/18/40/eb6854ec495ab28026df8497b4c9/validation-of-amazon-halo-movement-a-smartphone-camera-based-assessment-of-movement-health.pdf (erişilemedi/detaylı taranmadı — yalnız arama sonucunda listelendi)
- https://www.researchgate.net/publication/363299663_Validation_of_Amazon_Halo_Movement_a_smartphone_camera-based_assessment_of_movement_health
- https://www.myhealthyapple.com/amazon-halo-movement-health-score-features/
- https://www.techradar.com/news/amazons-halo-fitness-tracker-can-now-help-you-avoid-throwing-out-your-back
- https://www.digitaltrends.com/wearables/amazon-halo-killed-dont-trust-tech-subscriptions/
- https://www.makeuseof.com/amazon-halo-health-movement/
