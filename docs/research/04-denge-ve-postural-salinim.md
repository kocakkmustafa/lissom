# Denge ve Postural Salınım — Tek Kamera Ölçüm Güvenilirliği (2026-07-26)

Kaynak: G0 tazeleme fan-out

## Özet

Markerless/video-tabanlı postural sway ölçümü, gelişmiş sistemlerde (Theia3D, OpenCap gibi çok-kameralı/araştırma-kalite pipeline'lar) force plate'e karşı **kısmen** doğrulanmış durumda — ancak korelasyonlar metriğe göre büyük varyans gösteriyor (R=0.39–0.94 ham, düzeltme sonrası R²=0.98–1.00 bazı parametrelerde). Tek kamera + telefon sınıfı MediaPipe/BlazePose kurulumu için doğrudan force-plate-karşı doğrulama literatürü SINIRLI bulundu; en yakın kanıt smartphone-tabanlı COM/COP çalışmalarından geliyor. Single-leg stance testinin protokolü (süre, göz durumu, başarısızlık kriterleri) iyi standardize edilmiş ve yaşa-bağımlı düşüş net biçimde gösterilmiş, ancak tam sayısal yaş-bandı normları (mean±SD) bu oturumda erişilen kaynaklarda DOĞRULANAMADI (abstract seviyesinde kaldı). MediaPipe'ın kendi landmark smoothing modülü One Euro filter kullanıyor ve resmi varsayılan parametreleri (min_cutoff=0.05, beta=80.0 ana landmark'lar için) doğrudan GitHub kaynağından teyit edildi.

## Bulgular (kanıtlı, URL'li)

1. **Theia3D (markerless, çok-kameralı) postural kontrol doğrulaması**: Vicon (marker-based) karşısında ankle-driven anterior-posterior sway korelasyonu r=0.998, medio-lateral sway r=0.990 (PCA tabanlı analiz). Bu, tek-kamera değil çok-kamera profesyonel sistem sonucu — üst sınırı gösteriyor.
   Kaynak: https://www.sciencedirect.com/science/article/pii/S0021929025003434

2. **OpenCap (2 telefon kamerası, iOS tabanlı) — serebral palsili çocuklarda denge değerlendirmesi (2025)**: COM parametreleri ile force-plate COP parametreleri arasında Pearson R = 0.39–0.94 (metriğe göre büyük değişkenlik); düzeltme (correction) sonrası bazı parametrelerde R²=0.98–1.00'e çıkıyor. Bu, ham video-COM tahmininin bazı sway metriklerinde (özellikle mutlak yer değiştirme) force-plate'e yakın, bazılarında (özellikle hız-türevi metrikler) daha zayıf kaldığını gösteriyor.
   Kaynak: https://www.mdpi.com/1424-8220/25/18/5911

3. **Smartphone (arbitrary pozisyon) COM→COP dönüşüm doğrulaması (2025, PMC)**: Rijit-cisim kinematiği + ters sarkaç modeliyle tek telefon üzerinden COM ivmesi hesaplanıp COP'a çevrilerek force plate ile doğrudan karşılaştırılmış — bu, tek-kamera/tek-cihaz sınıfına en yakın doğrulama kanıtı, ancak burada "kamera" değil telefon IMU/ivmeölçer kullanılıyor, MediaPipe pose değil.
   Kaynak: https://pmc.ncbi.nlm.nih.gov/articles/PMC12073742/ (PubMed özet: https://pubmed.ncbi.nlm.nih.gov/40363079/)

4. **SWAY Balance (accelerometer) vs Biodex Biosway (force plate) kinematik doğrulama**: Postural sway'in ivmeölçer-tabanlı ölçümünün force-plate ile kinematik uyumu incelenmiş — yine kamera-pose değil ama "telefon-sınıfı sensörle sway ölçümü mümkün mü" sorusuna dolaylı kanıt sağlıyor.
   Kaynak: https://www.ncbi.nlm.nih.gov/pmc/articles/PMC6942738/

5. **Force plate + IMU ile COM tahmini (2023, Sensors)**: COM tahmininde force-platform ile inertial sensör birleşimi değerlendirilmiş; salt video-pose'un COM tahminindeki hata payına dair karşılaştırmalı bağlam sağlıyor (doğrudan MediaPipe değil).
   Kaynak: https://doi.org/10.3390/s23104933 (PMC: https://pmc.ncbi.nlm.nih.gov/articles/PMC10222371/)

6. **Senkronize video+mocap+force-plate veri seti (Scientific Data, 2024)**: Markerless hareket analizini doğrulamak için tasarlanmış açık veri seti — Lissom'un kendi doğrulama testleri için potansiyel referans/benchmark veri kaynağı olabilir. Tam metne bu oturumda erişilemedi (Nature login/redirect duvarı — "erişilemedi").
   Kaynak: https://www.nature.com/articles/s41597-024-04077-3 (erişilemedi — doi kaydı üzerinden atıf yapılıyor)

7. **Unipedal Stance Test (UPST) — Springer ve ark. protokolü (549 sağlıklı denek, 6 yaş grubu: 18-39, 40-49, 50-59, 60-69, 70-79, 80+)**: Gözler açık ve kapalı koşullarda test edilmiş; yaşla anlamlı düşüş gösterilmiş (istatistiksel anlamlılık teyitli). İnter-rater güvenilirlik ICC=0.994 (gözler açık), ICC=0.998 (gözler kapalı) — çok yüksek. **Ancak yaş-bandı bazında tam sayısal ortalama/SD değerleri bu oturumda erişilen PubMed özetinde YOKTU — DOĞRULANAMADI**, tam metin gerekiyor.
   Kaynak: https://pubmed.ncbi.nlm.nih.gov/19839175/

8. **UPST genel protokol unsurları (RehabMeasures/Physiopedia derlemesi)**: Test, ayak yerden kalktığı andan ayağın yere/diğer bacağa değmesine veya elin kalçadan ayrılmasına kadar süre tutularak yapılır. Kayıt edilmesi gerekenler: taraf, süre, zaman-sınırı, göz durumu, zemin, ayakkabı, kol pozisyonu, semptomlar, kompansasyonlar. Protokoller arası fark var: bazı protokoller 60 sn tavan, bazıları 30 sn tavan + bacak teması/ayak yere değme/zıplama-sıçrama hareketi/dış destek kullanımında sonlandırma kriterleri kullanıyor.
   Kaynak: https://www.sralab.org/rehabilitation-measures/timed-unipedal-stance-test-single-leg-support-one-leg-stance-test ve https://www.physio-pedia.com/Single_Leg_Stance_Test

9. **MediaPipe resmi landmark smoothing modülü — One Euro Filter, kaynak koddan teyitli varsayılan parametreler**: Ana pose landmark'ları için `min_cutoff=0.05`, `beta=80.0`, `derivate_cutoff=1.0` (hızlı harekette ~0.94 EMA alpha'ya karşılık geliyor). Yardımcı (auxiliary) landmark'lar için daha ağır smoothing: `min_cutoff=0.01`, `beta=10.0` (~0.68 EMA alpha).
   Kaynak: https://github.com/google-ai-edge/mediapipe/blob/master/mediapipe/modules/pose_landmark/pose_landmark_filtering.pbtxt

10. **Genel pratik kanıt (mühendislik kaynağı, akademik değil)**: Her eklem konumuna bağımsız One-Euro veya Kalman filtre uygulamak, hızlı harekette gecikme yaratmadan düşük-genlikli titremeyi bastırıyor; tek eklem başına ~30 satır kodla uygulanabilir, iki hiperparametre (`mincutoff`, `beta`) ile ayarlanabilir. Bir kaynak, ham MediaPipe pose çıktısının hızlı hareket sırasında ciddi titrediğini ve One-Euro filtrenin gürültünün ~%80'ini giderdiğini iddia ediyor — bu rakam DOĞRULANMADI (tekil blog/mühendislik kaynağı, akademik ölçüm yok).
    Kaynak: https://medium.com/@debasishraut.dev/setting-up-smoothing-filters-for-mediapipe-pose-estimation-pipeline-a-practical-guide-fcc03f462196

## Ürüne doğrudan girdi

**Ölçülebilir metrik listesi (single-leg stance testi için, video-pose ile):**
- **Süre (birincil metrik, en güvenilir)** — ayak kalkışından düşüşe/temasa kadar saniye. Force-plate gerektirmez, sadece landmark görünürlük eşiği + göz/kol pozisyon takibi yeterli. Bu metrik MediaPipe gürültüsünden neredeyse etkilenmez (event-detection, sürekli sinyal değil).
- **COM (kütle merkezi) yer değiştirme genliği (AP/ML sway alanı)** — kanıt DESTEKLİYOR ama değişken güvenilirlikte (bulgu 2: R=0.39-0.94). Tek kamera 2D + BlazePose kaba 3D için "orta güvenilirlik" olarak konumlandırılmalı, kesin klinik ölçüm gibi sunulmamalı.
- **Sway hızı / hız-türevi metrikler (velocity, jerk)** — bulgu 2 ve 9'daki filtre-gürültü ilişkisine göre bunlar **"gürültüden ayırt edilemez" kategoriye en yakın metrik** — türev alma landmark jitter'ını büyütür. ÖNERİ: bu metrikleri ürün UI'de kullanıcıya "kesin sayı" olarak gösterme, sadece süre + kaba genlik göster.
- **Salınım alanı (95% confidence ellipse area)** — force-plate literatüründe standart ama video-pose'da düzeltme (correction) gerektiriyor (bulgu 2); düzeltmesiz ham video kullanılacaksa bu metrik "gürültüden ayırt edilemez" listesine eklenmeli.

**Önerilen temporal smoothing:**
- Filtre tipi: **One Euro Filter** (MediaPipe'ın kendi varsayılanı, ek bağımlılık gerektirmiyor, gerçek-zamanlı düşük gecikme).
- Cutoff önerisi: Ana vücut landmark'ları için MediaPipe resmi varsayılanını başlangıç noktası al: `min_cutoff≈0.05`, `beta≈80.0`. Denge testi gibi yavaş/düşük-genlik hareket senaryosunda beta'yı DÜŞÜRMEK (ör. 10-20 aralığı) daha uygun olabilir çünkü denge testinde hızlı hareket beklenmiyor, asıl hedef titremeyi bastırmak — bu bir ADAPTASYON ÖNERİSİDİR, literatürde denge-spesifik cutoff DOĞRULANMADI, kendi pilot testinizle kalibre edin.
- Ek olarak hareketli ortalama (moving average, 3-5 frame) süre/eşik-tabanlı event detection (ayak kalkışı/düşüşü) için filtre sonrası ikinci bir gürültü-azaltma katmanı olarak düşünülebilir — bu öneri DOĞRULANMADI, mühendislik pratiği.

**Testin geçersizlik kuralları (literatürden + mantıksal çıkarım):**
- Kol kalçadan ayrılması (bulgu 8'deki standart kriter — landmark açısından: bilek-kalça mesafesi eşik üstü).
- Kaldırılan ayağın yere değmesi veya destek bacağına teması (bulgu 8).
- Hoplama/zıplama hareketi (bazı protokollerde açık sonlandırma kriteri — bulgu 8).
- Dış destek kullanımı (duvar, mobilya tutma).
- Kadraj dışına çıkma / landmark görünürlük skorunun (MediaPipe visibility score) test süresinin önemli bir kısmında eşik altına düşmesi — bu, video-tabanlı teste özgü EK bir geçersizlik kriteri (literatürde force-plate testlerinde karşılığı yok, Lissom'a özgü mühendislik gerekliliği).

## Açık sorular (kapatılamayanlar, neden)

1. **UPST'nin tam yaş-bandı normatif değerleri (mean±SD, saniye)** kapatılamadı — Springer ve ark. (2009) çalışmasının sadece PubMed özeti erişildi, tam metin (Wolters Kluwer / J Geriatr Phys Ther) bu oturumda erişilemedi. Ürün için yaş-normlu referans aralıkları gerekiyorsa tam metne (ödeme duvarı olabilir) veya alternatif açık-erişim normatif çalışmaya ayrıca ulaşılmalı.
2. **MediaPipe/BlazePose landmark jitter'ının sway ölçümünü NİCEL olarak ne kadar kirlettiği** (ör. "X mm RMS hata" gibi bir sayı) doğrudan akademik kaynakta bulunamadı — mevcut kanıt (bulgu 2, 10) dolaylı/kısmi. Bu, Lissom'un kendi pilot verisiyle (telefon + varsa referans force-plate/IMU) ölçülmesi gereken bir boşluk.
3. **Tek-kamera (tam anlamıyla monoküler, çok-kameralı değil) MediaPipe/BlazePose ile force-plate karşılaştırmalı BİREBİR bir doğrulama çalışması** bu oturumda bulunamadı — mevcut en yakın kanıtlar ya çok-kameralı (Theia3D, OpenCap) ya da telefon-IMU tabanlı (kamera-pose değil). Bu, "tek kamera 2D" kısıtına en doğrudan uyan boşluk ve ürün iddialarında dikkatli dil gerektiriyor (ör. "araştırma-kalite doğrulama henüz yok" notu iç dokümantasyonda tutulmalı).

## Kaynaklar

- https://www.sciencedirect.com/science/article/pii/S0021929025003434
- https://www.mdpi.com/1424-8220/25/18/5911
- https://pmc.ncbi.nlm.nih.gov/articles/PMC12073742/
- https://pubmed.ncbi.nlm.nih.gov/40363079/
- https://www.ncbi.nlm.nih.gov/pmc/articles/PMC6942738/
- https://doi.org/10.3390/s23104933
- https://pmc.ncbi.nlm.nih.gov/articles/PMC10222371/
- https://www.nature.com/articles/s41597-024-04077-3 (erişilemedi)
- https://pubmed.ncbi.nlm.nih.gov/19839175/
- https://www.sralab.org/rehabilitation-measures/timed-unipedal-stance-test-single-leg-support-one-leg-stance-test
- https://www.physio-pedia.com/Single_Leg_Stance_Test
- https://github.com/google-ai-edge/mediapipe/blob/master/mediapipe/modules/pose_landmark/pose_landmark_filtering.pbtxt
- https://medium.com/@debasishraut.dev/setting-up-smoothing-filters-for-mediapipe-pose-estimation-pipeline-a-practical-guide-fcc03f462196
