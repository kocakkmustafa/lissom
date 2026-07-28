# Lissom — Ürün Gereksinim Dokümanı (G2)

**Tarih:** 2026-07-26 · **Statü:** G1-a şartlı geçti (kurucu onaylı, M-F-01); G1-b ölçüm bekliyor
**Hiyerarşi:** `00-AILE-MIMARISI.md` > `20-URETIM-SURECI.md` > `10-ARAC-KATALOGU.md` > `lissom-roadmap.md` > bu dosya > `lissom-plan.md`
**Ürün dili:** İngilizce (UI + içerik + sesli koç + store). İç doküman Türkçe.

> Bu PRD, kurucu karar paketindeki M-F-04/06/07/08/09/11 kararları işlenmiş hâlidir. Kararların gerekçeleri DEFTER'de (L-019..L-027); burada yalnız **ne yapılacağı** yazar.

---

## 1. Ürün tanımı ve sınır

**Lissom: Mobility & Yoga** — telefon kamerasıyla hareket kapasitesini ölçer, ölçüme göre günlük program üretir, dört haftada yeniden ölçer.

**Kuzey Yıldızı:** 4-hafta yeniden-test tamamlama oranı.
**İkincil:** geçerli-ölçüm oranı · D7/D30 tutundurma.

**Ürün DEĞİLDİR:** tıbbi cihaz · teşhis aracı · fizyoterapi ikamesi. Wellness sınırı `config/copy/disclaimers.en.json` ve `tools/wellness_lint.py` ile korunur.

**Kapsam otoritesi:** `LISSOM-BLUEPRINT.md` (motion-core `30-URUN-BLUEPRINT-STANDARDI.md` omurgası). "Bitti" tanımı standart §1'den: kullanıcı store'dan indirir → onboarding → **kütüphanenin TAMAMI düzenli sayfalarda gezilebilir** → kurs seçer → canlı seansta sesli koçluk → grafiklerle ilerleme → abonelik akışı → çökmez, offline çalışır.

### 1.1 Dalga kapsamı

| Dalga | İçerik |
|---|---|
| **W0** | PRD + IA çatısı + platform katmanı + batarya genişletme (**12 test**) |
| **W1** | Yoga: Hatha · Vinyasa · Yin (Tier-1) + esneklik hedefleri (Front/Middle Split · Kalça · Hamstring) + program motoru |
| **W2** | Chair/Office Yoga + popülasyon paketleri (Masa-başı · Koşucu · Lifter) + Backbend/Omuz-açma |
| **W3** | Ashtanga + aile ısınmaları (JabLab/Choreia/Gravita deep-link) + nefes/meditasyon (ses-rehberli) |
| **W4** | Senior (doktor-onayı kapısı) + Prenatal (ACOG-hizalı alt-küme) |

**Poz kütüphanesi katmanları:** Tier-1 ~150-250 poz (ayakta/oturan/diz-üstü) tam koçluk · Tier-2 yer/supine gevşek skor · Tier-3 inversiyonlar yalnız avatar demosu. Tier-3'ün gerekçesi ölçülmüş: pose modeli ters vücutta uzuv etiketlerini **yüksek güvenle** takas ediyor (aile bulgusu M-019).

**V1 kapsam dışı** (plan §18 + blueprint §1): sayısal skor gösterimi (§6.1) · çocuk paketi · kamerayla nefes/meditasyon ölçümü · klinik screen/tanı/düşme-riski iddiası · Bikram · hip iç/dış rotasyon (L-006) · çoklu kamera · giyilebilir. Hepsi tek bir **"Neden yok?" sayfasında** kullanıcıya açıklanır (`config/ia/library.v1.json → whyNotPage`).

---

## 2. Uçtan uca akış

```
Onboarding (yaş bandı · hedef · süre · cinsiyet[ops.])
  → Güvenlik taraması (ağrı/öykü)
  → Kalibrasyon sihirbazı  ⟵ SERT KAPI
  → Değerlendirme (8-10 test)
  → Bölgesel sonuçlar (nitel)
  → Program üretimi (kural motoru)
  → Günlük seans (sesli koç)   ⟳ günlük
  → Haftalık mini test          ⟳ haftalık
  → 4-hafta yeniden değerlendirme → karşılaştırma (MDC kapılı)
```

Her adım kendi başına terk edilebilir; ilerleme kaydedilir ve kaldığı yerden sürer. Değerlendirme yarıda kalırsa tamamlanan testler saklanır.

---

## 3. Onboarding ve profil

### 3.1 Toplanan veri (M-F-11a)

| Alan | Zorunlu | Neden | Saklama |
|---|---|---|---|
| Yaş **bandı** (`u40` / `40-59` / `60plus`) | ✅ | Skor bantları yaşa göre değişir; denge süresi 60-69→80-99 arası 27 sn'den 8,5'e düşer. Bandsız skor yaşlı kullanıcıya sistematik haksızlık | Yalnız cihazda |
| Cinsiyet | ❌ opsiyonel, **"prefer not to say" dahil** | Bazı normlar (uzanma) cinsiyet-ayrık; verilmezse birleşik bant kullanılır | Yalnız cihazda |
| Hedef · günlük süre · mevcut spor | ✅ | Program profili seçimi | Yalnız cihazda |

Tam doğum tarihi **istenmez** — band yeterli, daha azı yeterliyse daha azı toplanır. App Privacy / Data Safety beyanında "Health & Fitness · cihazda işlenir · aktarılmaz" olarak listelenir.

### 3.2 Güvenlik taraması

Ağrı/yaralanma öyküsü bölge bazında sorulur (omuz · boyun · bel · kalça · diz · ayak bileği). Sonuç iki yere bağlanır:

1. **Riskli hareket filtresi (M-F-11c):** ilgili bölgede öykü işaretlenmişse, `expertReviewRequired: true` işaretli 7 hareket program havuzundan **otomatik çıkarılır**. Kullanıcıya gerekçe wellness dilinde gösterilir ("we've left out a few movements based on what you told us").
2. **Test filtresi:** aynı bölgenin değerlendirme testi opsiyonel hâle gelir; atlanırsa o bölge "not measured" kalır, tahmin edilmez.

---

## 4. Kalibrasyon sihirbazı — SERT KAPI (M-F-09)

Kalibrasyon bir öneri değil, **geçilmesi zorunlu kapıdır**. Ölçüm buna bağlı (G1-a A5: gövde metrikleri ±10° yaw sapmasında 5,73° kayıyor — bu tek başına kapı kriteri B4'ü aşar).

### 4.1 Kabul koşulları

| Koşul | Eşik | Kaynak |
|---|---|---|
| Kamera–kullanıcı mesafesi | 180-200 cm | JMIR e82412 en yüksek doğruluk bandı |
| Kamera yüksekliği | 90-110 cm | Kalça/göbek hizası |
| **Yaw sapması (omuz-kalça hattı ↔ kamera)** | **≤ 10° dayatılır · ≤ 5° hedeflenir** | G1-a A5 ölçümü |
| Kadraj | Baş ve ayaklar tüm hareket boyunca içeride | — |
| Landmark güveni | Test metriklerinin gerektirdiği tüm noktalar eşik üstü | Config |
| **Yapısal denetim** | `StructuralValidator` temiz | M-019 / L-019 |

Koşullar sağlanmazsa test **başlamaz**. "Yine de devam et" seçeneği yoktur — çünkü sonuç kullanıcıya sayı olarak dönecek ve yanlış kurulumla üretilmiş bir sayı, ölçüm olmadığını gizler.

### 4.2 Taraf eşlemesi (M-F-06)

Kalibrasyon pozunda kullanıcının sol/sağ tarafı **geometrik olarak** belirlenir ve oturum boyunca sabitlenir:

- Modelin `LEFT_*`/`RIGHT_*` etiketine **ham güven yoktur** (aile kuralı: Gravita ADR-003, JabLab ADR-004, Choreia K6).
- Taraf kimliği kadraj konumu + kameraya yakınlık + `StructuralValidator`-temiz akış üzerinden kurulur.
- Sagittal testlerde ölçülen taraf **kameraya yakın olandır** (uzak taraf ~2× hata alır, PLOS ONE 2023) ve kullanıcıya hangi taraf ölçüldüğü açıkça söylenir.
- Eşleme kurulamazsa **simetri skoru üretilmez** — o oturum tek taraflı raporlanır.

---

## 4.5 Bilgi mimarisi

Kaynak: `config/ia/library.v1.json` (standart §2 — "her öğe kendi sayfası").

```
Ana Sayfa (bugünkü plan · yeniden-test sayacı · devam eden · hızlı başlat)
└── Kütüphane (arama + filtre + tüm-kurslar dizini ZORUNLU)
    ├── Değerlendirme Bataryası      → her test kendi alt-sayfası + trend grafiği
    ├── Yoga Stilleri                → Hatha · Vinyasa · Yin · Ashtanga · Chair
    ├── Esneklik Hedefleri           → her hedef kendi "path" sayfası + haftalık açı trendi
    ├── Popülasyon Paketleri         → Masa-başı · Koşucu · Lifter · Senior* · Prenatal*
    ├── Aile Isınmaları              → JabLab · Choreia · Gravita (deep-link)
    ├── Nefes & Wind-down            → yalnız ses-rehberli, kamera KAPALI
    └── "Neden yok?"                 → kapsam-dışı öğeler + gerekçeleri
```
`*` doktor/medikal kapı arkasında.

**Kapsamın tamamı baştan görünür:** açılmamış dalgalar `coming_soon` durumuyla listelenir — dar-app algısı yaratılmaz. Ama **sahte/boş kurs asla listelenmez**: `coming_soon` sayfası kurs listesi göstermez, ne geleceğini anlatır.

**Her aile sayfası bir dürüstlük kutusu taşır** (opsiyonel değil): bu öğede *neler ölçülür* / *neler ölçülmez*. Örnek — Nefes sayfası: *"Nothing. These sessions are guided by audio and timed — the camera stays off."*

**Navigasyon:** ana sayfadan aktif kursa ≤2 dokunuş, kütüphaneden herhangi bir kursa ≤3.

## 5. Değerlendirme

### 5.1 Test seti

Aday havuz `config/tests/lissom-assessment.v1.json` — **12 test** (W0'da ASLR ve plank/rotasyon-stabilite eklendi). V1 seti **G1-b kapısından** çıkar: 🟢 nicel / 🟡 nitel / 🔴 düşer sınıflaması ölçümle belirlenir.

İki yeni testin taşıdığı özel riskler config'te açıkça yazılı: **ASLR supine** (yerde yatan vücut, tek kameranın en zayıf olduğu yer — G1-b'de düşme adayı) ve **plank** (dayanıklılık testi; kullanıcıyı fazla zorlama riski en yüksek olan, bu yüzden "rekorunu kır" teşviki yok, durma kararı kullanıcıda).

Her test: talimat metni (EN) → kalibrasyon kontrolü → kayıt → metrik çıkarımı → geçersizlik kontrolü → sonuç.

### 5.2 Geçersizlik ve tekrar

Geçersizlik kodları config'te tanımlı (`BENT_ELBOW`, `HEEL_LIFT`, `LOW_CONFIDENCE`, `CAMERA_ANGLE`, `USED_SUPPORT`, `FOOT_DOWN`…). Her kod, kullanıcıya **ne yapması gerektiğini** söyleyen bir mesaj taşır; "geçersiz" tek başına gösterilmez.

Bir test 3 denemede de geçersizse: test "not measured" olarak kapanır, kullanıcı ilerler. **Tahmin edilmez, boş bırakılır.**

### 5.3 Ölçüm kaydı

Her deneme `TestAttempt` olarak saklanır (§9). Değerlendirme sonucu, denemelerin config'teki `aggregation` kuralına göre birleştirilmesidir (max/min/duration).

---

## 6. Skorlama

### 6.1 Kalibrasyonsuz sayı YOK (M-F-04 / K8 aile kuralı)

**İç doğrulama çalışması tamamlanana kadar kullanıcıya hiçbir sayısal skor gösterilmez.** Bantlı skorlama iç hesap olarak çalışır; kullanıcı arayüzü yalnız **nitel bant** görür:

```
limited · typical · good        (test düzeyi)
```

Gerekçe: bantlar literatür ortalamalarından türetildi, klinik kesim noktası değil. Sayı göstermek, sahip olmadığımız bir kesinliği ima eder. Bu kısıt L-005 kapandığında (n≥20-30 bilinen-açı doğrulaması) kalkar.

### 6.2 Bölgesel sonuçlar

Bölgeler: `shoulder · thoracic · hip · posterior_chain · lateral_chain · ankle · balance`.
Her bölge, kendisini besleyen testlerin nitel bantlarından türetilir. Ölçülemeyen bölge **"not measured"** kalır; komşu bölgeden tahmin edilmez.

### 6.3 Açıklanabilirlik

Her bölgesel sonuç, hangi testten hangi ölçümle geldiğini gösterir (plan §19: "skor algoritmasını gizli ve açıklanamaz bırakma"). Kullanıcı "neden bu sonuç?" diyebilmeli ve cevabı görmeli.

### 6.4 Güven sınıfı görünürlüğü

Sınıf C testleri (ayak bileği, rotasyon) sonuçta **düşük güven işaretiyle** gösterilir. Aynı ekranda eşit görünen iki sonuçtan biri diğerinden daha az güvenilirse, bu saklanmaz.

---

## 7. Program motoru

### 7.1 Deterministik kural motoru

LLM yok (plan §8). Girdi: bölgesel sonuçlar + hedef + günlük süre + ağrı/öykü beyanı + geçmiş uyum. Çıktı: günlük seans.

```
assessment → uygun içerik paketleri → hareket seçimi → doz → haftalık progresyon
```

**Her seçimin nedeni loglanır** — "bu hareket neden bugün burada?" sorusunun makine-okunur cevabı saklanır.

### 7.2 İçerik paketi mimarisi (D4)

Yoga akışları ayrı bir özellik değil, program motorunun **içerik paketidir**. Şema `G1-V0-KAPI-PROTOKOLU.md §4`'te; yoga pozu ile mobilite hareketi **aynı öğe tipidir** (`style: yoga` etiketi ve Sanskritçe ad alanı farkı dışında).

Yeni paket eklemek **kod değişimi gerektirmez**.

### 7.3 V1 içeriği

- Hareket havuzu: 72 hareket, 7 bölge (`research/08`) — 63'ü tam kamerayla izlenebilir, 8'i kısmen, 1'i hayır
- Yoga paketleri: 3 (Morning Mobility Flow · Desk Posture Reset · Hip & Hamstring Opening) — hepsi ayakta/duruş ağırlıklı
- Program profilleri: 2 (General Mobility · Desk Worker)
- Yerde/yüzükoyun pozlar `isScored: false` — uygulanır, ölçülmez (self-occlusion, `research/07`)

---

## 8. Günlük seans ve sesli koç

### 8.1 Kamera politikası

Her öğe `cameraPolicy: required | optional | none` taşır. Kamera **sürekli zorunlu değildir** (plan §9) — sürtünmeyi düşürmek için gerekmeyen öğelerde kapalı çalışır.

### 8.2 Sesli koç ve gecikme (M-F-08)

Tutuş sayımı ve süre yönlendirmesi sesle yapılır. **Ses gecikme kalibrasyonu zorunludur** ve `motion_core`'un ses-gecikme modülünden tüketilir (aile modülü; Choreia K4 deseni).

Gerekçe: Bluetooth kulaklıkta ~200 ms gecikme, "iki saniye tut" talimatını kaydırır; kullanıcı erken veya geç bırakır ve ölçüm bozulur. Kalibre edilmemiş çıkışta **süre-kritik sesli sayım kullanılmaz**, görsel sayaca düşülür.

### 8.3 Ağrı akışı (M-F-11b)

Kullanıcı seans içinde ağrı bildirdiğinde:

1. O **bölgenin** egzersizleri seansın kalanından çıkarılır.
2. Yerine nazik alternatif önerilir (aynı süre, farklı bölge veya gevşeme).
3. Dil wellness sınırında kalır — sebep yorumu yapılmaz, teşhis ima edilmez.
4. **Tekrar eden ağrı** (aynı bölge, N seans içinde) → profesyonele yönlendirme ekranı.
5. Ağrı verisi hassas kabul edilir (plan §14), yalnız cihazda.

---

## 9. Veri modeli

Plan §14'teki varlıklar geçerli. Bu PRD'nin eklediği zorunluluk:

### 9.1 Köken (provenance) alanları — ZORUNLU (M-F-07)

Her `TestAttempt` şunları taşır:

| Alan | Neden |
|---|---|
| `modelVariant` (`lite`/`full`/`heavy`) | Güven skorları varyantlar arası kıyaslanamaz (M-018) |
| `modelVersion` + `modelSha256` | `latest` etiketi sessizce değişiyor — ölçülü gerçek (M-L-01) |
| `metricConfigVersion` | Metrik tanımı değişirse eski ölçüm kıyaslanamaz |
| `ruleSetVersion` | Skorlama kuralı sürümü |
| `calibrationProfile` | Mesafe/yükseklik/yaw değerleri |
| `appVersion` | — |

**Bu alanlar olmadan iki ölçüm karşılaştırılamaz.** Lissom'un tüm değer önerisi zaman-içi karşılaştırma olduğu için, köken eksikse "gelişme" iddiası model gürültüsü olabilir (Gravita ADR-005).

### 9.2 Depolama

Local-first, Drift/SQLCipher (LifeOS deseni). **Ham video hiçbir koşulda saklanmaz veya aktarılmaz.** Bulut senkronu V1'de yok.

---

## 10. Yeniden ölçüm ve gelişim

### 10.1 MDC kapısı (L-021)

İki ölçüm arasındaki fark, **minimum anlamlı değişim (MDC) eşiğinin** altındaysa "değişim yok" olarak raporlanır.

**MDC eşiği G1-b ölçümünden türetilir** — test-retest değişkenliğinden (TRV) hesaplanır. Bu eşik hesaplanana kadar:
- Karşılaştırma ekranı **gösterilmez**,
- Hiçbir "geliştin / kötüleştin" mesajı üretilmez.

Ek kısıt: Halo verisi, tekrarlanabilirliğin hareket-kısıtlı grupta %35 daha kötü olduğunu gösteriyor (CV %2,16 vs %1,60). MDC eşiği bu gruplar için **daha geniş** olmalı — yani en çok gelişmesi beklenen kullanıcıda çıta en yüksek. Bu rahatsız edici ama dürüst.

### 10.2 Karşılaştırma geçerliliği

İki ölçüm ancak şu koşullarda karşılaştırılır: aynı `modelVariant` · uyumlu `metricConfigVersion` · benzer `calibrationProfile`. Biri tutmuyorsa karşılaştırma yapılmaz, kullanıcıya "yeniden temel ölçüm" önerilir.

---

## 11. Kabul kriterleri (V1)

| # | Kriter |
|---|---|
| 1 | G1-b'den ≥6 test 🟢/🟡 çıkmış, ≥4'ü 🟢 |
| 2 | Kalibrasyon sihirbazı sert kapı olarak çalışıyor; yaw >10° testi başlatmıyor |
| 3 | Taraf eşlemesi geometrik; eşleme kurulamazsa simetri üretilmiyor |
| 4 | Hiçbir ekranda sayısal skor yok (doğrulama tamamlanana dek) |
| 5 | Tüm `TestAttempt` kayıtları köken alanlarını taşıyor |
| 6 | Ağrı akışı uçtan uca çalışıyor; riskli 7 hareket öyküde filtreleniyor |
| 7 | `wellness_lint.py` CI'da yeşil; kullanıcıya görünen tüm metin süzgeçten geçiyor |
| 8 | Ölü buton = 0 · mock veri = 0 |
| 9 | İnternetsiz tam çalışma |
| 10 | 2 program profili + 3 yoga paketi + ≥10 kamera-doğrulamalı egzersiz |
| 11 | MDC eşiği hesaplanmış ve karşılaştırma ekranı ona bağlı |
| 12 | `StructuralValidator` çekirdekten tüketiliyor (Lissom kendi kontrolünü yazmıyor) |
| 13 | Kütüphanenin TAMAMI gezilebilir; açılmamış dalgalar `coming_soon` görünür, sahte kurs yok |
| 14 | Her aile sayfasında dürüstlük kutusu var; "Neden yok?" sayfası kapsam-dışını açıklıyor |
| 15 | 2-tık kuralı sağlanıyor (ana→aktif kurs ≤2, kütüphane→kurs ≤3); arama + filtre + tüm-kurslar dizini çalışıyor |

---

## 12. Mimari karar kayıtları

Ayrı dosyalarda: `docs/ADR/`

| ADR | Karar |
|---|---|
| 001 | Taraf kimliği geometrik kurulur; model etiketine ham güven yok |
| 002 | Kalibrasyon sert kapı; yaw ≤10° |
| 003 | Doğrulama öncesi yalnız nitel bant; sayısal skor yok |
| 004 | Köken alanları zorunlu; eksikse karşılaştırma yapılmaz |
| 005 | Ölçüm sözleşmesi versiyonlu config; motor içerik-bağımsız |
| 006 | Çekirdek bileşenler `motion_core`'dan tüketilir, kopyalanmaz |

---

## 13. Açık bağımlılıklar

| Ne | Kime bağlı |
|---|---|
| V1 test seti | G1-b kurucu çekimi |
| MDC eşiği | G1-b (TRV ölçümü) |
| Sayısal skor gösterimi | İç doğrulama çalışması (L-005) |
| Egzersiz güvenlik notları | Uzman doğrulaması (fizyoterapist) |
| Ses gecikme modülü | `motion_core` (koordinatör oturum) |
| `StructuralValidator` | `motion_core` (mevcut) |
| Sesli koç ses paketi | Üretim harcaması (kurucu onayı) |
