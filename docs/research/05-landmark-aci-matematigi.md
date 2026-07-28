# Landmark → Eklem Açısı Matematiği — 2026-07-26

**Kaynak: G0 tazeleme fan-out**

## Özet

Lissom'un ölçüm motoru için üç katmanlı bir mühendislik reçetesi çıkarılabilir: (1) MediaPipe Pose Landmarker **world landmarks** (3D, metre, kalça-merkezli) sagital/frontal düzlem açıları için 2D image landmarks'a göre daha az perspektif hatası taşır ve bu yüzden birincil kaynak olmalı; (2) Pose2Sim/OpenSim ekolü ham landmark'ları doğrudan açıya çevirmez — segment vektörleri + (ideal olarak) inverse-kinematics/optimizasyon katmanı kullanır, biz IK'sız olduğumuz için basit vektör-açısı + visibility-ağırlıklı güven skoruna razı olmalıyız; (3) kişiler-arası karşılaştırma için **gövde uzunluğu (torso length = omuz-orta noktası↔kalça-orta noktası ortalama mesafesi)** literatürde en kararlı normalizasyon referansı olarak kullanılıyor; (4) visibility/presence eşiği MediaPipe varsayılanı 0.5, pratikte sıkı filtreleme için 0.6-0.7 aralığı kullanılıyor; (5) tek kamera 2D sistemler transvers düzlem (iç/dış rotasyon, twist) hareketini prensipte güvenilir ölçemez — bu DOĞRULANMIŞ bir literatür kısıtı, spesifik sayısal hata büyüklüğü ise DOĞRULANAMADI.

## Bulgular (kanıtlı, URL'li)

### (a) 2D vs 3D world landmarks

- MediaPipe/BlazePose "world landmarks" gerçek-dünya 3D koordinatları (metre cinsinden), orijin kalçalar arası merkezde; normal (image) landmarks ise 3D nesnenin 2D görüntü yüzeyine izdüşümü (piksel koordinatı). Kaynak: alphaXiv BlazePose GHUM Holistic özeti — https://www.alphaxiv.org/overview/2206.11678v1 ve orijinal makale https://arxiv.org/pdf/2206.11678
- Model, kalça merkezine göre göreli koordinatlarda, metrik uzayda 3D vücut pozunu tahmin edecek şekilde eğitilmiş — bu global konumlamadan (kameraya mesafe/açı) bağımsızlık sağlar. Kaynak: aynı — https://arxiv.org/pdf/2206.11678
- World-mode'da iskelet boyutu kamera-vücut mesafesine göre DEĞİŞMEZ; 2D/image-mode'da iskelet boyutu mesafeye bağlıdır (perspektif ölçek kayması). Kaynak: geaxgx/depthai_blazepose deposu tartışması — https://github.com/geaxgx/depthai_blazepose
- "Exercise quantification from single camera view markerless 3D pose estimation" (PMC10951609) tek-kamera 3D poz tahmininden egzersiz metrikleri çıkarımını inceliyor; spesifik perspektif-hata büyüklük sayısı bu aramada elde edilemedi → **DOĞRULANMADI (sayısal hata büyüklüğü)**. Kaynak: https://www.ncbi.nlm.nih.gov/pmc/articles/PMC10951609/

### (b) Pose2Sim / OpenSim metodolojisi

- Pose2Sim = "OpenPose to OpenSim": çoklu kameradan 2D keypoint alır, kalibre kameralarla 3D'ye triangüle eder, sonuçları tam-vücut 3D inverse-kinematics OpenSim modeline besleyerek biyomekanik olarak tutarlı eklem açıları üretir. Kaynak: GitHub — https://github.com/perfanalytics/pose2sim
- OpenSim'in kullanılma nedeni: fiziksel olarak tutarlı tam-vücut model + IK optimizasyon algoritması, bu 3D koordinatları rafine edip 3D eklem açılarını üretiyor (yani ham vektör açısı değil, model-kısıtlı optimize açı). Kaynak: Pose2Sim Part 1/Part 2 (Sensors dergisi) — https://www.mdpi.com/1424-8220/21/19/6530 , https://www.ncbi.nlm.nih.gov/pmc/articles/PMC9002957/
- Doğruluk: sagital düzlemde ortalama CMC (coefficient of multiple correlation) >0.9; koşuda kalça açısında sistematik 15° sapma (CMC=0.65) ve bisiklette bacak açısında kısmi oklüzyondan CMC=0.75. Kaynak: https://www.ncbi.nlm.nih.gov/pmc/articles/PMC9002957/
- Hangi segment vektörleri / hangi düzlem izdüşümü kullanıldığına dair (omuz-dirsek-bilek gibi üçlü nokta tanımları ötesinde) ayrıntılı formül bu aramada elde edilemedi → **DOĞRULANMADI (ayrıntı formül seviyesi), tam metinde olabilir, erişilmedi.**

### (c) Vücut-oranı normalizasyonu

- Vücut normalizasyonu tipik olarak sol-omuz/sağ-omuz/sol-kalça/sağ-kalça'nın merkezi etrafında döndürülerek dikey referans hizalanır (boyun-merkez hattı dikey olacak şekilde). Kaynak: "Human Pose Estimation using Global and Local Normalization" (ICCV 2017) — https://arxiv.org/pdf/1709.07220
- **Gövde uzunluğu (torso length)** = boyun keypoint'inden sağ ve sol kalçaya mesafelerin ortalaması. Diğer segment uzunlukları (örn. üst kol) gövde uzunluğunun ORANI olarak ifade edilir (örn. 0.6 = üst kol, gövdenin 0.6 katı). Bu normalizasyon güçlü çünkü gövde uzunluğu video karesi boyunca çok sabit kalıyor. Kaynak: aynı makale — https://arxiv.org/pdf/1709.07220
- PCK (Percentage of Correct Keypoints) metriğinde eşik, kişinin gövde uzunluğunun bir fraksiyonu olarak tanımlanır; gövde uzunluğu = sol-omuz↔sağ-kalça mesafesi (PCK0.1 = eşik gövde uzunluğunun %10'u). Kaynak: aynı — https://arxiv.org/pdf/1709.07220
- Antropometrik ölçüm tahmininde gövde/bacak oranı gibi basit oran özellikleri harici vücut-oranı veri setleriyle regresyon modellerine girdi olarak kullanılıyor. Kaynak: "An Empirical Study of Monocular Human Body Measurement Under Weak Calibration" — https://arxiv.org/pdf/2601.01639

### (d) Visibility/presence eşikleri

- MediaPipe Pose Landmarker resmi parametreleri (Google AI Edge dokümantasyonu): `minPoseDetectionConfidence` (varsayılan 0.5), `minPosePresenceConfidence` (varsayılan 0.5), `minTrackingConfidence` (varsayılan 0.5) — hepsi 0.0-1.0 aralığında. Kaynak: https://developers.google.com/edge/mediapipe/solutions/vision/pose_landmarker/web_js
- Çıktıda her landmark için `visibility` (landmark'ın görüntüde görünür olma olasılığı) ve `presence` (landmark'ın tespit edilme kesinliği) skorları bulunur. Kaynak: aynı sayfa.
- MediaPipe GitHub Issue #4462'de topluluk tartışması: bazı pratik uygulamalarda 0.7 gibi daha sıkı eşikler kullanılıyor, araştırmalarda 0.4 gibi daha gevşek eşiklerin de jitter azaltımı için etkili olduğu bulunmuş. Kaynak: https://github.com/google/mediapipe/issues/4462
- Net bir "endüstri standardı eşik" literatürde tek bir sayı olarak belirlenmemiş — 0.5 varsayılan, 0.4-0.7 pratik aralık. **Kısmen DOĞRULANMADI**: Lissom'a özgü ideal eşik ampirik testle belirlenmeli.

### (e) Temporal smoothing — One Euro Filter

- One Euro Filter iki parametre ile ayarlanır: `mincutoff` (minimum kesim frekansı, Hz, >0) ve `beta` (hız katsayısı, >0). `mincutoff` düşürmek yavaş-hız jitter'ını azaltır ama gecikmeyi artırır; `beta` artırmak hızlı hareketlerdeki gecikmeyi azaltır. Kaynak: https://jaantollander.com/post/noise-filtering-using-one-euro-filter/ ve orijinal makale https://www.researchgate.net/publication/254005010_1_Filter_A_Simple_Speed-based_Low-pass_Filter_for_Noisy_Input_in_Interactive_Systems
- Önerilen ayar prosedürü: önce `beta=0`, `mincutoff=1 Hz` gibi orta değerle başla; vücut parçası sabit/çok yavaş tutulurken `mincutoff` jitter'ı gidermek için ayarlanır; sonra vücut parçası hızlı hareket ettirilirken `beta` gecikmeyi azaltacak şekilde artırılır. Kaynak: aynı — https://jaantollander.com/post/noise-filtering-using-one-euro-filter/
- One Euro Filter'ın gerçek-zamanlı jitter azaltımı için adaptif kesim frekansıyla önerildiği ve MediaPipe gibi sistemlerden gelen poz landmark'larının yumuşatılmasına uygun olduğu belirtiliyor. Kaynak: mmhuman3d dokümantasyonu — https://mmhuman3dyl-1993.readthedocs.io/en/latest/_modules/mmhuman3d/core/filter/oneeuro_filter.html

### (f) Tek-kamera 2D'nin transvers düzlem kısıtı (iç/dış rotasyon)

- Transvers düzlemde vücut segmentlerinin kameranın 2D görüş düzleminden uzağa doğru burulduğu (twist) rotasyonel hareket, tek-kamera markerless sistemlerde nadiren doğru çıkarılabilir/raporlanabilir. Kaynak: "Examination of 2D frontal and sagittal markerless motion capture: Implications for markerless applications" — https://www.ncbi.nlm.nih.gov/pmc/articles/PMC10635560/
- Daha fazla kamera twist hareketini takip etme olasılığını artırsa da, transvers düzlem açısal hareketi doğru ve güvenilir çıkarmak zor kalmaya devam ediyor. Kaynak: aynı — https://www.ncbi.nlm.nih.gov/pmc/articles/PMC10635560/
- Kısıtın temel nedeni: 3D açısal kinematik ölçümü için bir vücut segmentinin 3 referans noktasına ihtiyaç duyan yerel 3D koordinat sistemi tanımı — markerless sistemlerde bu sınırlı sayıda vücut-referanslı noktayla mevcut değil. Kaynak: aynı.
- Amazon Halo Movement (npj Digital Medicine 2022) doğrulama çalışması: tam-vücut Xsens IMU takım elbisesi referans olarak kullanılmış, sensör-tabanlı ve kamera-tabanlı metrikler arası 0.23<r<0.83 (p<0.05) korelasyon bulunmuş — yani kamera-tabanlı tek-görüş sistemin bazı eklem/hareket metriklerinde IMU'ya göre orta-güçlü, bazılarında zayıf korelasyon gösterdiği kanıtlanmış (spesifik olarak hangi eklem/hangi düzlemde zayıf olduğu bu aramada ayrıştırılamadı). Kaynak: https://pmc.ncbi.nlm.nih.gov/articles/PMC9445016/ ve https://www.nature.com/articles/s41746-022-00684-9

## Ürüne doğrudan girdi

**Motion-core için somut formül/karar seti:**

1. **Açı kaynağı seçimi (karar önerisi):** Sagital düzlem hareketleri (diz/kalça fleksiyon-ekstansiyon, omuz fleksiyon, gövde eğilme gibi Lissom'un çekirdek mobilite testleri) için **world landmarks (3D, metre, kalça-merkezli)** üzerinden açı hesapla — perspektif/mesafe kaynaklı ölçek kaymasından etkilenmiyor. 2D image landmarks yalnız fallback (world landmark visibility düşükse) veya ekranda çizim/overlay amaçlı kullanılsın.
2. **Açı hesabı formülü:** Üç landmark (A-B-C, B = eklem köşesi) için `açı = acos( (BA·BC) / (|BA|·|BC|) )` (dot-product/kosinüs kuralı), world-landmark 3D vektörlerle. 2D fallback'te aynı formül XY düzleminde veya `atan2` bazlı imzalı açı olarak.
3. **Güven ağırlıklandırma:** Her açı hesabında kullanılan 3 landmark'ın `visibility × presence` çarpımlarının minimumunu (ya da ortalamasını) o açının "ölçüm güveni" skoru olarak taşı. Eşik önerisi: **min 0.6** güven altında açıyı "belirsiz/tekrar dene" olarak işaretle (MediaPipe varsayılanı 0.5'ten biraz daha sıkı — Lissom'un wellness bağlamında yanlış-pozitif "iyi skor" riskini azaltmak için). Bu eşik ampirik olarak Lissom'un kendi test setinde doğrulanmalı (literatürde tek sabit sayı yok — bkz. Açık Sorular).
4. **Normalizasyon:** Kişiler-arası/zaman-içi karşılaştırma için **gövde uzunluğu** = ortalama( |omuz-orta-noktası − sağ-kalça|, |omuz-orta-noktası − sol-kalça| ) referans ölçek olarak kullanılsın; tüm mesafe-bazlı metrikler (örn. squat derinliği, öne-eğilme mesafesi) bu referansa bölünerek boy/vücut-tipinden bağımsız hale getirilsin. Açı metrikleri zaten boyuttan bağımsızdır (sadece mesafe-bazlı metrikler normalize edilmeli).
5. **Temporal smoothing:** Her landmark koordinatına (3D world + 2D image) bağımsız One Euro Filter uygula. Başlangıç parametreleri: `mincutoff ≈ 1.0 Hz`, `beta = 0` ile başla, sabit-duruş testlerinde (ör. squat alt pozisyonda bekleme) jitter'ı gözle azalt, sonra hızlı-hareket testlerinde (ör. hızlı kalça fleksiyonu) `beta`'yı kademeli artırarak gecikmeyi azalt. Bu iki parametre Lissom'un kendi test videolarıyla ampirik kalibre edilmeli — literatür sadece prosedürü veriyor, Lissom'a özgü sayı vermiyor.
6. **"Bu eklem 2D'de güvenilir ölçülemez" listesi (öneri):**
   - Kalça iç/dış rotasyonu (transvers düzlem twist)
   - Omuz iç/dış rotasyonu (transvers düzlem twist)
   - Diz valgus/varus'un hassas derece ölçümü (frontal düzlemde küçük açı farkları, tek kameranın açısına çok duyarlı)
   - Gövde rotasyonu (trunk axial rotation / spinal twist)
   Bu dört hareket sınıfı kategorik olarak "kısıtlı görüş" (limited visibility) uyarısıyla kullanıcıya sunulmalı; ürün dilinde tıbbi/teşhis iddiası olmadan "bu hareket kamera açısına duyarlıdır, tutarlı kamera konumu önerilir" gibi ifade edilebilir.
7. **Kamera konumu / kurulum önerisi:** Test bataryasında sagital-düzlem hareketleri için kamera **doğrudan yandan (90°)** konumlandırılmalı; frontal-düzlem hareketleri (ör. yana eğilme, omuz abdüksiyonu) için kamera **doğrudan önden** konumlandırılmalı — düzlem-kamera hizalaması perspektif hatasını en aza indirir (bu, world-landmarks kullanılsa bile visibility/presence kalitesini artıracağı için önerilir; JMIR 2026 e82412 kamera-pozisyon çalışmasıyla tutarlı, ayrıntılı sayısal karşılaştırma bu oturumda tekrar aranmadı çünkü zaten bilinen kabul edildi).

## Açık sorular

1. **Lissom'a özgü visibility/presence eşiği ve One Euro Filter (mincutoff, beta) parametreleri ampirik olarak belirlenmedi** — literatür sadece prosedür ve genel aralık (0.4-0.7 eşik; mincutoff~1Hz başlangıç) veriyor, Lissom'un kendi kamera/ışık/mesafe koşullarında test edilmesi gerekiyor. Neden kapatılamadı: bu bir mühendislik-kalibrasyon işi, literatür taramasıyla çözülemez.
2. **Pose2Sim/OpenSim'in tam segment-vektörü ve düzlem-izdüşüm formülleri** (hangi 3 nokta hangi eksen etrafında nasıl projekte ediliyor, IK maliyet fonksiyonu detayı) bu aramada tam metin seviyesinde elde edilemedi — GitHub README ve özet makaleler genel akışı anlatıyor ama formül-seviyesinde ayrıntı içermiyor. Neden kapatılamadı: kaynak dokümantasyonun derinlemesine (kod-seviyesi) incelenmesi gerekir, bu oturumun kapsamı web arama ile sınırlı.
3. **2D perspektif hatasının sayısal büyüklüğü** (örn. "X derece kamera açısı sapmasında Y derece açı hatası") spesifik bir sayı olarak bulunamadı — literatür niteliksel olarak "world landmarks daha az perspektif hatası taşır" diyor ama nicel bir hata-bütçesi tablosu bu aramada çıkmadı. Neden kapatılamadı: bu tür nicel karşılaştırmalar büyük olasılıkla spesifik akademik makalelerin (örn. JMIR 2026 e82412 veya BlazePose doğrulama makaleleri) tam metninde olabilir, bu oturumda tam metin erişimi denenmedi.

## Kaynaklar

- https://www.alphaxiv.org/overview/2206.11678v1
- https://arxiv.org/pdf/2206.11678
- https://github.com/geaxgx/depthai_blazepose
- https://www.ncbi.nlm.nih.gov/pmc/articles/PMC10951609/
- https://github.com/perfanalytics/pose2sim
- https://www.mdpi.com/1424-8220/21/19/6530
- https://www.ncbi.nlm.nih.gov/pmc/articles/PMC9002957/
- https://arxiv.org/pdf/1709.07220
- https://arxiv.org/pdf/2601.01639
- https://developers.google.com/edge/mediapipe/solutions/vision/pose_landmarker/web_js
- https://github.com/google/mediapipe/issues/4462
- https://jaantollander.com/post/noise-filtering-using-one-euro-filter/
- https://www.researchgate.net/publication/254005010_1_Filter_A_Simple_Speed-based_Low-pass_Filter_for_Noisy_Input_in_Interactive_Systems
- https://mmhuman3dyl-1993.readthedocs.io/en/latest/_modules/mmhuman3d/core/filter/oneeuro_filter.html
- https://www.ncbi.nlm.nih.gov/pmc/articles/PMC10635560/
- https://pmc.ncbi.nlm.nih.gov/articles/PMC9445016/
- https://www.nature.com/articles/s41746-022-00684-9
