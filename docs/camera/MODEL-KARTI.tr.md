# Lissom kamera koçluğu — model kartı (deneme sürümü v1)

**Durum:** deneme. Bağımsız kamera (video → MediaPipe) sınaması yok; kurucu kararı (2026-11-04) gereği özellik "deneme" etiketiyle çıkar ve tek bayrak arkasında, varsayılan kapalıdır.

## Ne yapar
- Dersin istediği **tek** duruşu yan görüşten kontrol eder (hedefli mod). "Bu duruşta mısın?" sorusuna evet/hayır der; adını tahmin etmez.
- Duruş onaylanınca tutuş süresini sayar; süre yalnız duruş tutarken ilerler.
- Aynı anda en fazla **bir** düzeltmeyi sesli söyler (8 s ara, aynı düzeltme en çok 2 kez). Düzeltmeler yalnız daha az açı, yumuşak eklem ya da hizalama ister; derinleştirmeyi asla istemez.
- Puan, not, sağlık ya da tedavi iddiası **yoktur**.

## Ne yapmaz
- Önden, yerde (sırtüstü, yüzüstü, diz üstü) ve akış (Vinyasa sekansı) duruşlarını değerlendirmez; bu derslerde "bu dersi kamera değerlendirmiyor" yazar.
- Birden çok kişiyi ayırt etmez (MediaPipe tek kişi); 4 m'den uzakta, baş görünmüyorken güvenilmez.
- Görüntüyü kaydetmez, göndermez, saklamaz. Kare cihazdaki poz modeline ve ekrana (ayna) gider; uygulama kodu yalnız eklem noktalarını görür.
- Telefon **dik** (portre) durmalıdır: köprü portre kare verir; koç ekranı açıkken uygulama portreye kilitlenir.

## Bileşenler
| Katman | Seçim | Lisans |
|---|---|---|
| Poz modeli | MediaPipe Pose Landmarker Full `pose_landmarker_full.v1.task` (sha256 `5134a3aa…`, mevcut pin) | Apache-2.0 |
| Kamera köprüsü | Motion Core `motion_camera` 0.4.0 (pin `4145a04`, önizleme texture'ı; core PR #15) | kendi kodumuz |
| Ayna | Koç ekranında: aynı `motion_camera` oturumunun texture'ı + üstünde iskelet ve dikey referans çizgisi (tek kamera). Ayrı ayna ekranı: Flutter `camera` 0.12.2, yalnız önizleme (Ostinato K8 yöntemi) | BSD-3 |
| Doğrulayıcı | Kural tabanlı: `config/yoga/camera-poses.v1.json` + `lissom_engine/lib/src/camera/` | kendi kodumuz |
| Ses | Cihazın kendi konuşma motoru (`flutter_tts`) | MIT |

**Öğrenilmiş sınıflandırıcı kullanılmıyor.** E10–E13'ün p(T) modeli YAR'ın tam (derin) biçimlerine eğitildi; derslerin destekli, küçük biçimlerine uymuyor. Bu sürümde doğrulayıcı açı kuralıdır; gerekçe ve sayılar E14/E15'te.

## Özellikler (yan görüş, 2B, en-boy düzeltmeli)
Gövde eğimi (işaretli: + öne), kalça, diz (yakın, en küçük/büyük, ön/arka, kalkan/basan), omuz fleksiyonu, dirsek, baş düşüşü, uyluk dikeyden, ayak bileği yüksekliği farkı, adım açıklığı, baş-kalça yüksekliği, omuz genişliği oranı (yan görüş kapısı), ayak bileği düşüşü (ayakta/sandalye/yer ayrımı). Python başvurusu `tool/camera_model/features.py`, Dart `pose_features.dart`; 60 sentetik karede birebir (`feature_parity.v1.json`, 1e-6).

## Karar kuralı
1 s'lik pencerede her özelliğin medyanı alınır. Duruşun tüm `define` kontrolleri 1,5 s kesintisiz tutarsa duruş onaylanır. Kurulum kapısı: tam vücut görünür (baş, omuz, kalça, diz, ayak bileği; görünürlük ≥ 0,5, kenardan %2 içeride), ortalama görünürlük ≥ 0,7, vücut kare yüksekliğinin %45–97'si, omuz genişliği/gövde ≤ 0,45 (yan görüş).

## Değerlendirme
| Duruş | Ad | Tür | Dersler | Tutuş | YAR ayrılmış kişiler TA / FA (E14) | DSZ-Yoga bağımsız TA / FA (E15) | Kanıt |
|---|---|---|---|---|---|---|---|
| `mountain` | Dağ duruşu | ayakta | Hatha h03, Hatha h53, Vinyasa v02, Ashtanga a03 | 15 s | — / 0.05 | 0.83 / 0.00 | independent-below |
| `standing-arm-raise` | Kollar kalkık ayakta duruş | ayakta | Ashtanga a04, Ashtanga a09, Vinyasa v02 | 10 s | 0.94 / 0.01 | — / 0.00 | in-data-pass |
| `chair-supported-fold` | Sandalye destekli öne eğilme | ayakta | Hatha h11, Hatha h12 | 15 s | 1.00 / 0.07 | 1.00 / 0.01 | independent-pass |
| `shallow-fold` | Eller uylukta sığ öne eğilme | ayakta | Ashtanga a05, Ashtanga a09 | 10 s | — / 0.02 | — / 0.01 | false-accept-only |
| `halfway-lift` | Yarım kalkış | ayakta | Ashtanga a05, Ashtanga a09 | 10 s | — / 0.07 | 0.87 / 0.07 | independent-below |
| `wall-half-hinge` | Duvar destekli yarım menteşe | ayakta | Vinyasa v03, Vinyasa v06 | 15 s | — / 0.03 | — / 0.01 | false-accept-only |
| `wall-dog-prep` | Duvarda köpek hazırlığı | ayakta | Vinyasa v04, Vinyasa v06 | 15 s | — / 0.07 | — / 0.00 | false-accept-only |
| `small-chair-pose` | Küçük sandalye duruşu (Utkatasana uyarlaması) | ayakta | Ashtanga a06, Ashtanga a11 | 10 s | — / 0.05 | 0.80 / 0.03 | independent-below |
| `shin-supported-fold` | Eller kaval kemiğinde öne eğilme | ayakta | Ashtanga a15 | 15 s | 1.00 / 0.04 | 0.91 / 0.10 | independent-pass |
| `wide-leg-fold` | Geniş bacakla sandalyeye öne eğilme | ayakta | Ashtanga a18 | 15 s | — / 0.06 | — / 0.01 | false-accept-only |
| `warrior-one-short` | Kısa adımlı Savaşçı I | ayakta | Hatha h44, Hatha h57 | 10 s | 0.92 / 0.00 | 0.62 / 0.01 | independent-below |
| `staggered-stance` | Destekli kademeli duruş | ayakta | Vinyasa v05, Vinyasa v06 | 10 s | — / 0.00 | — / 0.00 | false-accept-only |
| `hinge-balance` | Destekli menteşe dengesi | ayakta | Hatha h50 | 10 s | — / 0.08 | — / 0.03 | false-accept-only |
| `small-back-extension` | Ayakta küçük geriye uzanma | ayakta | Hatha h53 | 8 s | 1.00 / 0.02 | — / 0.01 | in-data-pass |
| `tree-wall` | Duvarla ağaç duruşu | ayakta | Hatha h10, Hatha h12 | 10 s | 0.90 / 0.03 | — / 0.00 | in-data-pass |
| `seated-upright` | Sandalyede dik oturuş | sandalye | Sandalye c01, Sandalye c04, Sandalye c06, Sandalye c07, Hatha h21 | 15 s | — / 0.00 | — / 0.00 | false-accept-only |
| `seated-arm-arc` | Oturarak küçük kol yayı | sandalye | Sandalye c04, Sandalye c07 | 8 s | — / 0.01 | — / 0.02 | false-accept-only |
| `seated-foot-lift` | Oturarak ayak kaldırma | sandalye | Sandalye c06, Sandalye c07 | 8 s | — / 0.01 | — / 0.03 | false-accept-only |
| `seated-rounding` | Oturarak omurgayı yuvarlama | sandalye | Sandalye c14 | 8 s | — / 0.00 | — / 0.00 | false-accept-only |
| `seated-lengthening` | Oturarak omurgayı uzatma | sandalye | Sandalye c14 | 8 s | — / 0.02 | — / 0.02 | false-accept-only |

- **E14** (YAR/YogNet, CC BY 4.0, yan görüş, 8 ayrılmış kişi grubu): veri içi; YAR E04–E13'te kullanıldı, özellik dağılımlarına tüm veride bakıldı. Bağımsız değil.
- **E15** (DSZ-Yoga, CC BY 4.0, 12 yeni kişi): bağımsız ve kişi ayrık, ama **3B iskeletin sentetik yan görüşü** — kamera ve MediaPipe hatası yok, bu yüzden iyimser olabilir.
- Ürün eşiği (§7.4): TA ≥ 0,90, FA ≤ 0,10.
- **Sonuç:** FA 20 duruşun hepsinde ≤ 0,10 (yanlış onay riski düşük). TA bağımsız sınamada 2/6 geçti; dağ, yarım kalkış, küçük sandalye ve kısa Savaşçı I eşik altı. Neden: `define` aralıkları duruş ailesinden dar (DSZ'de geriye eğik dağ ≈ −16°, ≈ 84° diz sandalye, ≈ 33° gövde yarım kalkış, arka diz ≈ 108° savaşçı). Ön kayıt gereği bu veriyle düzeltilmedi.
- 13 duruşta hiçbir yerde pozitif örnek yok (sandalye duruşlarının tamamı dahil): yalnız yanlış kabul ölçüldü.

## Gecikme
- Masaüstü (Dart VM, M-serisi Mac): özellik + koç kare başına ölçümü `camera_latency_test.dart` yazar.
- Telefon: cihaz smoke raporu (`docs/camera/CIHAZ-SMOKE.tr.md`).

## Bilinen riskler
- Yanlış ret (duruştayken "henüz değil") derin ya da farklı biçimlerde sık; kullanıcıyı yanlış yöne itmez (koç ret anında düzeltme söylemez) ama can sıkıcıdır.
- Sandalye duruşları hiç pozitif veriyle sınanmadı.
- Ağaç duruşunda kalkan dizin açısı yandan ölçülemez (diz kameraya bakıyor); yalnız ayak yüksekliği kullanılır.
- Işık "ölçümü" yoktur; düşük görünürlük "görüntü net değil" diye bildirilir.
