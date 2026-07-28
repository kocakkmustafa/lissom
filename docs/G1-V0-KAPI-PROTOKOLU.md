# Lissom — G1 / V0 Fizibilite Kapısı: Protokol ve Eşikler

**Tarih:** 2026-07-26 · **Sürüm: rev.2** · **Statü:** ÖLÇÜMDEN ÖNCE YAZILDI (ön-kayıt) — `20-URETIM-SURECI §2.6` gece modu kuralı
**Hiyerarşi:** `00-AILE-MIMARISI.md` > `20-URETIM-SURECI.md` > `10-ARAC-KATALOGU.md` > `lissom-roadmap.md` > bu dosya

> **Bu dosyanın varlık nedeni:** eşikler sonuç görüldükten sonra yazılırsa kapı anlamını kaybeder. Aşağıdaki tüm sayılar HİÇBİR ölçüm yapılmadan, yalnız literatür ve mimari kısıtlardan türetilerek yazılmıştır. Ölçüm sonuçları `G1-V0-KAPI-RAPORU.md`'ye ayrı yazılır; bu dosya **ölçüm başladıktan sonra** DEĞİŞTİRİLMEZ (değişirse gerekçe DEFTER'e L-kaydı olarak düşer).

> **rev.2 gerekçesi (2026-07-26, hâlâ ölçüm ÖNCESİ):** rev.1 yazıldığında G0 tazeleme fan-out'u henüz bitmemişti. Araştırma dosyaları (`docs/research/01,03,04,05,06,10`) üç yerde protokolü değiştirdi: (1) tek bir MAE eşiği literatüre aykırı — eklem sınıfına göre ayrıştırıldı (§3.2 B5); (2) sagittal çekimde "kamera-tarafı eklem" kuralı keşfedildi → L/R ölçümü aynı klipten yapılamaz (§1 not); (3) düzlem/mesafe atamaları somut sayılara bağlandı. Hiçbir ölçüm yapılmadığı için bu revizyon "sonuca göre eşik ayarlama" DEĞİLDİR; kaynak ayrımı L-007'de kayıtlı.

---

## 0. Kapının iki yarısı (bağlayıcı ayrım)

Roadmap G1'i tek kapı olarak tanımlar; ölçülebilirlik açısından **iki bağımsız yarıya** ayırıyorum. Gerekçe: yarılardan biri kurucu eli (video çekimi) gerektirirken diğeri gerektirmiyor — birleşik tutmak, çekim gelene kadar TÜM ilerlemeyi bloke ederdi.

| Yarı | Adı | Neyi kanıtlar | Girdi | Kurucu eli gerekir mi |
|---|---|---|---|---|
| **G1-a** | Sayısal doğruluk kapısı | Açı/normalizasyon/güven matematiği ve test state-machine'leri, bilinen girdiye doğru cevap veriyor | Sentetik landmark dizileri (matematiksel olarak bilinen açılar) | ❌ Hayır |
| **G1-b** | Görüntü güvenilirlik kapısı | MediaPipe'ın gerçek dünyada bu 10 testte geçerli ölçüm üretme oranı | Gerçek video fixture'ları (`FIXTURE-CEKIM-LISTESI.md`) | ✅ Evet (çekim) |

**Faz kilidi:** G1-a geçmeden G4 motor kodu yazılmaz. G1-b geçmeden hiçbir test **V1 test setine alınmaz** ve hiçbir yerde "measures / ölçer" iddiası kurulmaz (L-005).

---

## 1. Kapıya giren aday test havuzu (10 aday → V1'e ≥8 hedefi)

Kaynak: `lissom-plan.md §5` (10 test önerisi) ∩ Amazon Halo Movement bataryası (5 hareket, npj Digital Medicine 2022 — tek hakemli emsal) ∩ kamera-görülebilirlik süzgeci. Aday havuz kasıtlı olarak V1 hedefinden (8) BÜYÜK: kapının işi eleme yapmak.

| # | Test ID | Ad (EN, ürün dili) | Düzlem | Birincil metrik | Halo'da var mı | Ön-risk |
|---|---|---|---|---|---|---|
| T1 | `overhead_reach` | Overhead Reach | sagittal | Shoulder flexion angle (°) | ✅ | düşük — literatürde en iyi doğrulanan eklem |
| T2 | `deep_squat` | Deep Squat | sagittal | Hip/knee flexion (°), heel lift (px→norm) | ✅ (feet-together squat) | düşük |
| T3 | `overhead_squat` | Overhead Squat | sagittal + frontal | Trunk-arm line (°), squat depth | ✅ | orta — 2 düzlem gerekir |
| T4 | `ankle_dorsiflexion` | Ankle Mobility (knee-to-wall) | sagittal | Tibia inclination (°) / diz-duvar mesafesi | ❌ | orta — literatürde ICC 0.72-0.82, en değişken |
| T5 | `hamstring_reach` | Standing Hamstring Reach | sagittal | Hip flexion (°), lumbar katkı ayrımı | ❌ | orta — kalça/bel ayrımı zor |
| T6 | `hip_hinge` | Hip Hinge | sagittal | Lumbo-pelvic rhythm (hip:spine oranı) | ❌ | orta-yüksek — türev metrik |
| T7 | `lateral_bend` | Lateral Trunk Bend | frontal | Trunk lateral flexion (°), L/R farkı | ❌ | düşük |
| T8 | `single_leg_balance` | Single-Leg Balance | frontal | Hold süresi (s), salınım (norm birim) | ✅ (single-leg stance) | orta — jitter kirlenmesi |
| T9 | `forward_lunge` | Forward Lunge | frontal | Knee valgus (°), pelvis tilt | ✅ | orta |
| T10 | `thoracic_rotation` | Seated Thoracic Rotation | üstten/frontal | Rotation angle (°) | ❌ | **yüksek — 2D'de rotasyon ölçümü zayıf (L-003)** |

**Eklem sınıfları (rev.2 — B5 eşiği bunlara göre uygulanır):**

| Sınıf | Kapsam | Testler | Literatür dayanağı |
|---|---|---|---|
| **A** — yüksek güven | Sagittal düzlemde, kameraya YAKIN taraftaki büyük eklem fleksiyon/ekstansiyonu | T1, T2, T3, T5 | Sagittal kamera-tarafı diz/kalça hatası 1.5-4°, marker-based'e yakın (PLOS ONE 2023) |
| **B** — orta güven | Gövde/segment açıları, çok-eklemli türev metrikler | T6, T7, T9 | Ara bant; doğrudan tek-eklem doğrulaması yok |
| **C** — düşük güven | Ayak bileği ve transvers düzlem (rotasyon) | T4, T8(salınım), T10 | Ayak bileği limits-of-agreement ±12-24°; transvers düzlem twist tek kamerayla "nadiren güvenilir çıkarılabilir" (PMC10635560) |

**Kamera-tarafı kuralı (rev.2, bağlayıcı):** sagittal çekimde kameraya uzak taraf ~2× hata alır (PLOS ONE 2023: kalçada std-of-bias +%108). Bu nedenle **sağ-sol farkı aynı klipten hesaplanamaz** — her taraf ayrı klip olarak çekilir ve ölçülür. Çekim listesi buna göre yazıldı.

**Düzlem/mesafe ataması (rev.2):** ROM açı ölçümü → **sagittal**, kamera-tarafı eklem; simetri/valgus/lateral → **frontal**; **mesafe 180-200 cm** (JMIR e82412'nin en yüksek doğruluk bandı). ⚠️ Araştırma çıktısında bir çelişki vardı ve hakemlendi (L-007): JMIR "side kötü, diagonal iyi" der ama o çalışma **tekrar sayımı** doğruluğunu ölçmüştür, eklem açısını değil; açı ölçümü için sagittal üstündür (PLOS ONE). Lissom bir ölçüm ürünü olduğu için **sagittal öncelikli**, ama 90 cm değil 180-200 cm'de.

**Kasıtlı DIŞARIDA bırakılanlar (kapıya bile girmiyor, gerekçeli):**
- **Hip internal/external rotation:** literatür açıkça söylüyor ki tek kamera 2D bu kompanzasyonu güvenilir yakalayamaz (OHS 2D-vs-3D eleştirisi). Ölçemeyeceğimiz şeyi ölçüyormuş gibi göstermek L-001'in ta kendisi. → V1 dışı, nitel gözlem bile yok.
- **Cervical rotation:** düşük risk sanılıyor ama yüz landmark'ları pose modelinde kaba; boyun rotasyonu için gereken hassasiyet yok. → V1 dışı.

Bu iki eleme, kapı ölçümüne girmeden alınmış tasarım kararıdır (kurucu adına, `20-URETIM-SURECI §0` yetkisiyle) ve DEFTER'e L-006 olarak işlenir.

---

## 2. G1-a — Sayısal doğruluk kapısı (kurucusuz, bu gece ölçülebilir)

### 2.1 Yöntem
Gerçek video kullanmadan, **sentetik landmark üreteci** ile bilinen açılara sahip 33-nokta iskelet dizileri üretilir (`tools/fixture_pipeline/synth_skeleton.py`). Üreteç, ölçüm motorunun görmesi gereken tam cevabı bilir; motor o cevabı bulmak zorundadır.

Sentetik senaryolar (her test için):
1. **Bilinen-açı taraması:** hedef eklem açısı 0°→180° arası 5° adımlarla; motorun ölçtüğü açı ile üretilen açı karşılaştırılır.
2. **Gürültü dayanıklılığı:** landmark'lara σ = {0.002, 0.005, 0.01} (normalize koordinat birimi) Gauss gürültüsü eklenir; ölçümün kayması izlenir.
3. **Vücut oranı değişkenliği:** aynı açı, farklı segment uzunlukları (kısa/uzun bacak, geniş/dar omuz) ile üretilir; normalizasyon sonrası ölçüm SABİT kalmalıdır.
4. **Perspektif bozulması:** iskelet, kameraya göre ±15° yaw ile döndürülür; düzlem-dışı hatanın büyüklüğü ölçülür.
5. **Güven kapısı:** kritik landmark'ların `visibility` değeri eşik altına düşürülür; motor skor ÜRETMEMELİ, `INVALID_LOW_CONFIDENCE` dönmelidir.
6. **State-machine geçişleri:** her test için doğru dizilim (READY→…→COMPLETE) ve 3 hatalı dizilim (yarıda bırakma, kadraj dışı, çift kişi) verilir; beklenen geçersizlik kodu doğrulanır.

### 2.2 Eşikler (ön-kayıt — ölçümden önce yazıldı)

| # | Kriter | Eşik | Gerekçe |
|---|---|---|---|
| A1 | Gürültüsüz sentetik girdide açı hatası | **≤ 0.5°** | Saf matematik; bundan büyük hata kod hatasıdır, ölçüm belirsizliği değil |
| A2 | σ=0.005 gürültüde açı hatası (medyan) | **≤ 2.0°** | Tipik landmark jitter'ı bu mertebe; motor bunu yutmalı |
| A3 | σ=0.01 gürültüde açı hatası (medyan) | **≤ 5.0°** | Kötü koşul; bandın genişlemesi kabul, patlaması değil |
| A4 | Vücut-oranı değişiminde ölçüm sapması | **≤ 1.0°** | Normalizasyon çalışıyorsa oran bağımsız olmalı |
| A5 | ±15° yaw'da açı sapması | **raporlanır, eşik YOK** | Bu bir gerçeklik ölçümü; sonucu kalibrasyon sihirbazının toleransını belirler |
| A6 | Güven kapısı: düşük-güven girdide skor üretimi | **%100 reddetmeli (0 kaçak)** | P0 kural: "düşük güvende hüküm yok". Tek kaçak = kapı KALDI |
| A7 | State-machine: doğru dizilim tanıma | **10/10 test** | — |
| A8 | State-machine: hatalı dizilimde doğru geçersizlik kodu | **≥ 29/30 senaryo** | 1 tolerans, ama A6 kaçağı toleranssız |

### 2.3 Karar kuralı (G1-a)
- **GEÇTİ:** A1-A4 + A6-A8 tümü sağlanıyor → G4 motor inşasına devam.
- **ŞARTLI GEÇTİ:** A1, A2, A4, A6, A7 sağlanıyor; A3 veya A8 sınırda → ilgili test(ler) işaretlenir, motor devam eder, sapma DEFTER'e.
- **KALDI:** A6 ihlali (tek kaçak yeter) VEYA A1 > 0.5° → motor kodu durur, matematik yeniden yazılır.

---

## 3.0 rev.4 — G1-b KAYNAK DEVRİ (M-F-13/16/17; koordinatör çerçevesi onaylı)

**Kurucu çekimi yok.** Aşağıdaki B1-B7 kriterleri **silinmedi**; her biri yeni kaynak merdivenine (katalog §6.3) göre yeniden tanımlandı. Ölçülemeyen kriter iptal edilmez — **koşullu ertelenir** ve "cihaz kapısında doğrulanacak" etiketiyle taşınır.

| # | Kriter | Eski kaynak | **Yeni ölçüm yolu** | Durum |
|---|---|---|---|---|
| **B1** | VMR — iyi koşul ≥%90 | Kurucu, kontrollü çekim | **PT kanal klipleri**, triyajdan geçmiş alt-küme (net · tek sahne · tam vücut · yatay). Triyaj etiketi "iyi koşul" tanımının yerine geçer | ✅ ölçülebilir |
| **B2** | VMR — zorlu koşul ≥%75 | Kurucu, loş ışık / bol kıyafet | **Aynı havuzun triyajda "sınırda" işaretlenen klipleri** (düşük ışık, bol kıyafet, kısmi kadraj). Doğal varyasyon; kontrollü değil | ✅ ölçülebilir, ⚠️ koşullar etiketli değil-kontrollü |
| **B3** | TRV — test-retest ≤5° | Aynı kişi, ayrı oturum | **İki katman:** (a) aynı eğitmenin FARKLI videoları (aynı hareketi ayrı çekimde yapmış) → gerçek oturumlar-arası; (b) klip-içi ardışık tekrarlar → kısa-vadeli. **(c) sentetik jitter perturbasyonu** ölçümün gürültü tabanını verir | ✅ ölçülebilir (üç katman ayrı raporlanır) |
| **B4** | CS — koşul kayması ≤5° | Kontrollü ışık/kıyafet varyasyonu | ⚠️ **TANIM DEĞİŞTİ:** kontrollü varyasyon yok. Yerine **kaynak-arası varyans** ölçülür (eğitmen × kadraj × ışık karışık). Bu, B4'ün ölçtüğü şeyin ÜST sınırıdır — koşul etkisi ile eğitmen farkı ayrışmaz | ⚠️ ölçülebilir ama farklı büyüklük; skor bandı kararı bu üst sınıra göre muhafazakâr verilir |
| **B5** | MAE — mutlak doğruluk | Bilinen-açı referansı (goniometre) | **AIST++** (çok-kameralı rekonstrüksiyon, CC-BY) + **kendi sentetiğimiz** (ground truth %100 bizim). ⚠️ **MM-Fit pose'u "estimates"** — mocap değil, model çıktısı; MM-Fit yalnız VMR/dayanıklılık için kullanılır, MAE için DEĞİL | ⚠️ kısmi: sentetikte tam, gerçek görüntüde yalnız AIST++ hareket örtüşmesi kadar |
| **B6** | TTF — ilk geçerli ölçüme süre ≤8 s | Kurucu, canlı kullanım | ❌ Kamu videosunda "kullanıcı testi başlattı" anı yok — ölçülemez. **KOŞULLU ERTELEME: cihaz kapısında (G8) doğrulanacak** | ⏸️ ertelendi, silinmedi |
| **B7** | Geçersizlik yakalama ≥%90 | Kasıtlı bozuk çekimler | **Triyajın REDDETTİĞİ klipler** doğal negatif fixture havuzudur (kadraj dışı, kesik, çok sahne, bulanık) + sentetik bozulma (`SyntheticNoise` + açı perturbasyonu). Etiket bedava: bozulmayı biz uyguladık | ✅ ölçülebilir, hatta eskisinden zengin |

**Kaynak devrinin bedeli (dürüstlük kaydı):** B4 artık farklı bir büyüklük ölçüyor ve B5 gerçek görüntüde ancak AIST++'ın kapsadığı hareketler kadar geçerli. Bu iki kısıt, "measures your mobility" iddiasının sınırını daha da daraltır (L-005) ve skor bantlarının **nitel** kalmasının gerekçesini güçlendirir (ADR-003).

**Çekirdek v0.1.0 API'lerinin kapıya etkisi:**
- `StructuralValidator.check(frame, expected:)` — **yatay/supine gövdede eksen hükmü VERMEZ.** ASLR testinin supine riski (L-036) için doğrudan ilgili: yerde yatan vücutta "eksen ters" alarmı üretmeyecek, ama uzuv-oranı ve kemik-kararlılığı denetimleri sürüyor.
- `AttemptProvenance` — 4-hafta karşılaştırması **farklı enstrümanla ölçülmüş kayıtlar arasında API düzeyinde reddedilir** (M-F-07 artık kod seviyesinde zorunlu, PRD §9.1'in karşılığı).
- Fixture şeması **v2** — hasat provenance bloku taşır; v1 dosyalar okunmaya devam eder.

## 3. G1-b — Görüntü güvenilirlik kapısı (kaynak: kamu hasadı + sentetik; kurucu çekimi YOK)

### 3.1 Ölçülecek metrikler (tanımlar — muğlaklık bırakmadan)

| Metrik | Tanım | Nasıl hesaplanır |
|---|---|---|
| **VMR** (Valid Measurement Rate) | Bir testin, bir koşulda, güven kapısını geçip skor üretebilen deneme oranı | `geçerli_deneme / toplam_deneme` |
| **TRV** (Test-Retest Variability) | Aynı kişi, aynı koşul, ardışık 3 denemede ölçülen açının standart sapması | `stdev(açı₁, açı₂, açı₃)` derece |
| **CS** (Condition Shift) | İyi koşul ile zorlu koşul arasındaki ölçüm ortalaması farkı | `|mean(iyi) − mean(zorlu)|` derece |
| **MAE** (bilinen-açı hatası) | Elle ölçülen referans açıya (protractor/inclinometer) göre mutlak hata | `mean(|ölçüm − referans|)` derece |
| **TTF** (Time To First valid) | Kullanıcı testi başlattıktan sonra ilk geçerli ölçüme kadar geçen süre | saniye |

### 3.2 Eşikler (ön-kayıt)

| # | Kriter | Eşik | Gerekçe |
|---|---|---|---|
| B1 | VMR — iyi koşul (parlak ışık, dar kıyafet, doğru mesafe/düzlem) | **≥ %90** | Ürünün "ölçer" vaadinin taban şartı; 10 denemeden 9'u tutmalı |
| B2 | VMR — zorlu koşul (zayıf ışık VEYA bol kıyafet) | **≥ %75** | Gerçek kullanıcı evde ideal koşulda değil; %75 altı = ürün çalışmıyor demektir |
| B3 | TRV (ROM testleri) | **≤ 5.0°** | 5° altı, kullanıcının gerçek gün-içi ROM dalgalanmasının altında kalır → gelişim sinyali gürültüden ayrışır |
| B4 | CS | **≤ 5°** → normal bant · **5-10°** → geniş bant + nitel dil · **> 10°** → test V1'den DÜŞER | Koşula bu kadar duyarlı bir sayıyı kullanıcıya "senin ROM'un" diye sunmak dürüstlük ihlali olur |
| B5 | MAE (bilinen-açı referansına karşı) — **eklem sınıfına göre** (rev.2) | **Sınıf A ≤ 6°** · **Sınıf B ≤ 8°** · **Sınıf C ≤ 12°** | Tek eşik literatüre aykırıydı: iyi kurulumda sagittal diz/kalça 1.5-5°, gövde açıları orta, ayak bileği ±12-24° (PLOS ONE 2023; PMC12589393). Aynı çıtayı ayak bileğine ve omza koymak, birini haksız düşürür veya diğerini haksız geçirir |
| B6 | TTF (medyan) | **≤ 8 s** | UX eşiği: bundan uzunu kullanıcının "bozuk" diye algıladığı sınır |
| B7 | Geçersizlik yakalama | Kasıtlı hatalı çekimlerin **≥ %90'ı** doğru geçersizlik koduyla reddedilmeli | Yanlış ölçüm vermektense ölçmemek daima üstün (`00-AILE-MIMARISI §7`) |

### 3.3 Test-başına sınıflandırma (kapı çıktısı)

Her test, ölçüm sonrası şu üç kovadan birine düşer:

- 🟢 **QUANTITATIVE** — B1+B2+B3+B4(≤5°)+B5 sağlanıyor → sayısal derece/cm olarak raporlanır, gelişim eğrisine girer.
- 🟡 **QUALITATIVE** — B1 sağlanıyor ama B4 5-10° bandında veya B5 > 8° → kullanıcıya SAYI GÖSTERİLMEZ; "limited / typical / good" gibi 3-5 bantlı nitel dil kullanılır. Skora düşük ağırlıkla girer.
- 🔴 **DROPPED** — B1 < %90 veya B2 < %75 veya B4 > 10° → V1'den düşer. (Vizyon tavansız: V2'de çoklu-açı/heavy varyant/ikinci kamera ile geri gelebilir.)

### 3.4 Karar kuralı (G1-b)
- **GEÇTİ:** ≥ 8 test 🟢 veya 🟡, bunların ≥ 5'i 🟢 → V1 test seti kurulur, G2 PRD'ye geçilir.
- **ŞARTLI GEÇTİ (gece modu):** ≥ 6 test 🟢/🟡, ≥ 4'ü 🟢 → ilerlenir; eksik testler V1.1'e ertelenir, kurucu onayı sabah retrospektif.
- **KALDI:** < 6 test kullanılabilir → **ürün varsayımı çürümüştür.** Katalog §1 yedek merdivenine geçilir (heavy varyant zorunlu / RTMPose spike / iOS Vision 3D katmanı) ve sonuç kurucuya ACİL sunulur — bu, gece modunda tek başına ilerlenemeyecek durumdur.

### 3.5 Ölçüm dürüstlüğü şartı
- Her sayı, hangi cihaz / hangi model varyantı (`full` vs `heavy`) / hangi koşulla üretildiği etiketiyle raporlanır (`00-AILE-MIMARISI §7`).
- Kapı raporunda **n** (deneme sayısı) her hücrede görünür. n < 3 olan hücre "yetersiz örnek" damgası alır, eşikle karşılaştırılmaz.
- Model varyantı: assessment modunda `heavy`, günlük seansta `full` (katalog §1). Kapı ölçümü **her iki varyantla** koşulur; fark raporlanır.

---

## 4. D4 — Yoga içerik katmanının bağlanma tasarımı (kapının ikinci çıktısı)

Roadmap G1 kapısı ölçümün yanında bir **tasarım** çıktısı da istiyor: yoga akışları program motoruna nasıl bağlanır?

**Karar (kurucu adına, gerekçeli):** Yoga akışı **ayrı bir özellik değil, program motorunun içerik paketidir** — bu, D4'ün zaten dayattığı şey. Bağlanma sözleşmesi:

```
ContentPack (versiyonlu, JSON)
├── id, version, title(en), description(en)
├── targets: [RegionScore]        # hangi bölgesel skoru besler (ankle/hip/thoracic/shoulder/lateral/posterior)
├── prerequisites: {minScore?, maxScore?, painFlags: []}   # kime uygun DEĞİL
├── durationMin, intensity, equipment: []
├── blocks: [ { kind: warmup|main|cooldown, items: [ExerciseRef | PoseRef] } ]
└── cameraPolicy: required | optional | none    # her öğe bazında override edilebilir
```

- Program motoru, egzersizi değil **paketi** seçer; paket içindeki öğeleri kullanıcının skoruna/süresine göre budar.
- Yoga pozu ile mobilite egzersizi **aynı öğe tipidir** (`Exercise`); yoga pozu yalnız `style: yoga` etiketi ve Sanskritçe/İngilizce ad alanı taşır. İki ayrı motor YOK.
- `cameraPolicy: none` olan öğeler kamera olmadan çalışır (plan §9: "kamera sürekli zorunlu olmayabilir") — sürtünme düşürücü.
- Yeni paket eklemek **kod değişimi gerektirmez** (gece modu "ileriye dönük mimari" şartı): paket JSON'u + varsa yeni egzersiz kaydı yeterli.

Bu tasarım G2 PRD'de ADR olarak sabitlenir.

---

## 5. Kapı raporu şablonu (`G1-V0-KAPI-RAPORU.md` bunu doldurur)

1. Ölçüm ortamı: cihaz(lar), OS sürümü, MediaPipe model sürümü + hash, harness commit'i
2. G1-a tablosu: A1-A8 → değer / eşik / ✅❌
3. G1-b tablosu: test × koşul → VMR / TRV / CS / MAE / n
4. Test sınıflandırması: 🟢🟡🔴 listesi + gerekçe
5. Kapı hükmü: GEÇTİ / ŞARTLI GEÇTİ / KALDI + hangi kurala göre
6. Sonraki adım kararı ve DEFTER kayıtları

---

## 6. Bu protokolün kendisine dair sınırlar (dürüstlük notu)

- Eşikler literatürden **türetilmiştir, kalibre edilmemiştir**: markerless-vs-mocap bias literatürü araştırma-sınıfı düzeneklerden gelir; bizim tek-telefon düzeneğimiz için doğrudan geçerli değildir. Eşikler bu yüzden "ürün iddiası" değil, "iç geçiş kriteri"dir.
- Kapıyı geçmek, ürünün **doğru ölçtüğünü kanıtlamaz** — yalnızca tutarlı ve koşula makul dayanıklı ölçtüğünü gösterir. "Measures your mobility" iddiası, ayrıca yapılacak **iç doğrulama çalışmasına** (n≥20-30, bilinen-açı referansına karşı) bağlıdır (L-005; roadmap §5).
- Kurucunun tek vücut tipiyle çekilen fixture'lar **vücut-tipi yanlılığı** taşır. Kapı bu yanlılıkla geçse bile, çeşitlilik açığı DEFTER'de açık kalır ve G8'de kapanması gerekir.
