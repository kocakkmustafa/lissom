# UI-BRIEF — Lissom

**Amaç:** `claude.ai/design` oturumlarına girdi. Bu belge KOD DEĞİL, tasarım
brief'idir. Ekran envanteri, her ekranın durumları, akış ve marka tonu.

**Kaynaklar (uydurma yok — hepsi mevcut config/doküman):**
`config/ia/library.v1.json` (sekmeler, aileler, dürüstlük kutuları, navigasyon
kuralları, poz-katmanları, "yapmadıklarımız" sayfası) · `config/copy/disclaimers.en.json`
(5 zorunlu yüzey) · `config/tests/lissom-assessment.v1.json` (12 test, skorlama
tipleri) · `docs/PRD.md` §5 (test akışı, geçersizlik) · `packages/lissom_engine`
(sonuç katmanları — M-F-71).

**Dil:** ürün yüzeyi **EN** (config'lerdeki tüm kullanıcı metni İngilizce, wellness
süzgecinden geçiyor). Bu brief TR yazılmıştır; ekran metni örnekleri EN verilir.

---

## 0. Ürünün bir cümlesi

Telefon kamerasıyla hareket kapasitesini **ölçen** ve ölçtüğü şeyi dürüstçe
söyleyen bir wellness uygulaması. Rakiplerden ayrıldığı yer: GOWOD'un mobilite
testi CV değil, kullanıcı kendini slider'la puanlıyor (araştırma bulgusu,
`docs/research/`). Lissom **gerçekten ölçüyor** — ve ölçemediğinde bunu söylüyor.

## 1. Marka tonu

| Evet | Hayır |
|---|---|
| Sakin, ölçülü, yetişkin | Neşeli-spor-koç, ünlemli |
| "Yaklaşık", "tahmini", "ölçemedim" demeye istekli | Kesinlik taklidi, sahte hassasiyet |
| Kullanıcının başlangıç noktasını normalleştiren | Rekor kırma / streak baskısı |
| Sayının yanında DAİMA sınırı | Çıplak skor |

**Tavizsiz iki kural:** (a) tıbbi dil YASAK — wellness sınırı CI'da taranıyor
(`tools/wellness_lint.py`); (b) ölçemediğini ölçmüş gibi göstermek yasak.

**Ton örneği (eşik-altı sonuç):** ✅ "Your reach measured 50°. That's your
starting point — we'll track it from here." · ❌ "Poor mobility detected."

## 2. Ekran envanteri

### 2.1 Onboarding (ilk açılış)

| # | Ekran | İçerik | Not |
|---|---|---|---|
| O1 | Welcome | Tek cümle vaat + "measures, doesn't guess" | |
| O2 | **Wellness disclaimer** | `disclaimers.onboarding` tam metni | **Onay ZORUNLU** — atlanamaz |
| O3 | Camera permission | Neden gerektiği + "video cihazdan çıkmaz" | İzin-reddi durumu ZORUNLU (§3) |
| O4 | Profile | Yaş bandı (ZORUNLU — bantlar yaşa göre) · cinsiyet (OPSİYONEL) · ağrı/sakatlık öyküsü | Yaş bandı olmadan skorlama muhafazakâr tabana düşer |
| O5 | **Measurement limits** | `disclaimers.measurementLimits` | İlk ölçümden önce bir kez |
| O6 | Camera setup | Mesafe/yükseklik/ışık; canlı iskelet önizleme | Kalibrasyon **SERT KAPI** (ADR-002): yaw ≤10° |

### 2.2 Ana sekmeler (4)

`home` · `library` · `progress` · `profile` (IA config'ten).

**home** — 4 bölüm: `today` (günün planı) · `retest_countdown` ("next
re-assessment" — Kuzey Yıldızı döngüsünün görünür yüzü) · `continue` ·
`quick_start`.

**library** — 6 aile: `assessment_battery` (aktif, wave 0) + 5 tanesi
`coming_soon` (yoga_styles, flexibility_goals, population_packs,
family_warmups, breath_meditation). **Kapsamın tamamı baştan görünür** ama
SAHTE kurs asla listelenmez: `coming_soon` sayfası kurs listesi göstermez,
ne geleceğini anlatır. Arama ZORUNLU; filtreler: level/duration/equipment/region.
Her aile sayfasında **honestyBox** (ölçülenler / ölçülmeyenler) — opsiyonel değil.

**progress** — trend grafiği (assessment_battery + flexibility_goals'da var).
⚠️ **Karşılaştırma iddiası kapalı:** iki ölçüm ancak aynı `modelVariant`,
uyumlu config sürümü ve benzer `calibrationProfile`'da kıyaslanır; biri
tutmuyorsa kıyas YAPILMAZ ve "yeniden temel ölçüm" önerilir (PRD §267).
MDC eşiği gelene dek "improved/worsened" dili YOK.

**profile** — ayarlar · "How measurement works" · **"What Lissom doesn't do"**
(`whyNotPage`: 5 kalem, her biri gerekçeli — çocuk programı, nefes ölçümü,
klinik tarama, hot yoga, kalça rotasyonu). Bu sayfa bir özellik, bir özür değil.

### 2.3 Değerlendirme akışı (ürünün kalbi)

Test başına: **talimat → kalibrasyon kontrolü → canlı tur → sonuç.**

| # | Ekran | Kritik davranış |
|---|---|---|
| A1 | Test instruction | Config'in `instruction` metni + hangi tarafla başlanacağı |
| A2 | Calibration check | Sert kapı; geçmezse ölçüm BAŞLAMAZ (dürüst ret) |
| A3 | **Live capture** | Sesli sayım/tutuş yönlendirmesi (ses-gecikme kalibrasyonu çekirdekten). İskelet overlay. Guard uyarıları ANLIK ("keep the elbow straight") |
| A4 | **Attempt result** | Aşağıdaki 4 sonuç katmanı (§2.4) |
| A5 | Battery summary | 12 testin tablosu; ölçülemeyenler İSİMLE ve sebebiyle |

**Tekrar kuralı:** 3 deneme de geçersizse test "not measured" olarak KAPANIR,
kullanıcı ilerler. **Tahmin edilmez, boş bırakılır** (PRD §5.2).

### 2.4 Sonuç ekranı — dört katman (M-F-71, motorla birebir)

Bu, tasarımın en önemli parçası. `lissom_engine`'in `ResultTier`'ı dört durum
üretir ve **dördü de farklı görünmeli**:

| Katman | Kullanıcı ne görür | Ton |
|---|---|---|
| `scored` | Değer + bant etiketi (low/normal/good) + bandın anlamı | Nötr-bilgilendirici |
| `measuredBelowRange` | **Değer + "başlangıç noktan bu" anlatısı. Bant etiketi YOK** (bandın altındaki değere bant adı vermek, ölçmediğimiz bir sınıflandırmayı iddia etmek olurdu). Hedef taban gösterilebilir | **KOÇLANAN** — skorlanan değil |
| `measuredNoBands` | Değer + "bu test için sayısal norm yok, nitel seviye kullanıyoruz" | Dürüst-sınırlı |
| `notMeasured` | **Sebep İSİMLİ** (aşağıdaki kodlar) + ne yapması gerektiği | Suçlayıcı DEĞİL |

**`notMeasured` sebep kodları** (motorun `ResultCode`'u — her biri kullanıcı
metni ister): `noAttemptDetected` · `setupTimedOut` · `measurementTimedOut`
(⚠️ bu durumda **değer VAR ve gösterilir**, yalnız kod farklı) · `aborted`
(config'in `abortCode`'u: BENT_ELBOW / HEEL_LIFT / ...) · `trackingLost` ·
`lowConfidence`.

⚠️ **Tasarım tuzağı, isimle:** eskiden eşiğin altında kalan kullanıcı HİÇBİR
ŞEY görmüyordu (L-135) — ne ölçüm ne sebep. Donmuş omuzla 50°'ye ulaşan biri
tam olarak boş ekran görüyordu, oysa uygulamanın var olma sebebi o kişi.
Tasarım bu dört katmanı ayırt etmezse hata geri gelir.

**Her sonuç ekranında** `disclaimers.scoreScreen` küçük punto ile kalıcı.

### 2.5 Ağrı akışı (her yerden tetiklenebilir)

Kullanıcı rahatsızlık bildirdiğinde: `disclaimers.painFlow` + o günün rutini
YUMUŞATILIR. Tıbbi yorum YOK, "sebebini söyleyemeyiz" açıkça yazılı.
Bu akış her canlı-tur ekranından erişilebilir olmalı.

### 2.6 Poz kütüphanesi katmanları (yoga dalgası, wave 1)

Tasarım şimdiden bilmeli: 3 katman ve **görsel olarak ayrışmalı**.
Tier 1 (ayakta/oturarak, ~150-250 poz): tam koçluk, skorlanır.
Tier 2 (yerde/supine): yönlendirmeli, gevşek skor (self-occlusion).
Tier 3 (ters duruşlar): **yalnız avatar demo, skorlanmaz** — poz modelleri ters
vücutta uzuv etiketlerini yüksek güvenle sessizce takas ediyor (M-019).

---

## 3. Her ekranın durumları

Aşağıdaki durumlar **tasarlanmadıysa eksik sayılır**:

| Durum | Nerede kritik | Not |
|---|---|---|
| **Boş** | library (coming_soon aileler) · progress (henüz ölçüm yok) | "Henüz veri yok" ≠ hata |
| **Yükleniyor** | canlı tur başlatma · model yükleme | İlk model yüklemesi uzun sürebilir |
| **Hata** | kamera açılamadı · model yüklenemedi | Teknik jargon YOK |
| **İzin reddi** | O3 sonrası ve sonradan iptal edildiğinde | Uygulama ÇALIŞMAYA devam eder: kütüphane/why-not gezilebilir, yalnız ölçüm kapalı. Ayarlara yönlendirme |
| **Kalibrasyon geçmedi** | A2 | Dürüst ret + ne düzeltilecek (mesafe/açı/ışık) |
| **Ölçüm alınamadı** | A4 | 6 sebep kodunun her biri ayrı metin |
| **Karşılaştırma kapalı** | progress | Config/kalibrasyon uyuşmazlığında trend gösterilmez, sebebi yazılır |
| **Düşük ışık / kadraj dışı** | A3 canlı | Anlık, engelleyici değil ama görünür |

## 4. Akış diyagramı (metin)

```
İlk açılış
  O1 Welcome → O2 Disclaimer(onay ZORUNLU) → O3 Camera permission
     ├─ izin verildi → O4 Profile → O5 Measurement limits → O6 Camera setup
     └─ izin REDDEDİLDİ → home (ölçüm kapalı, kütüphane+why-not açık)

home ──(≤2 dokunuş)──> aktif kurs / bugünün planı
library ──(≤3 dokunuş)──> herhangi bir kurs
     └─ aile sayfası (honestyBox ZORUNLU) → öğe sayfası

Değerlendirme (bir test):
  A1 Instruction → A2 Calibration check
       ├─ GEÇMEDİ → dürüst ret → A2 (ne düzeltilecek)
       └─ GEÇTİ → A3 Live capture (sesli yönlendirme + guard uyarıları)
             → A4 Attempt result
                  ├─ scored / measuredBelowRange / measuredNoBands → sonraki test
                  └─ notMeasured → 3 denemeye kadar tekrar
                        └─ 3/3 geçersiz → "not measured" KAPANIR → sonraki test
  ...12 test... → A5 Battery summary → program üretimi → home

Her yerden: ağrı bildirimi → §2.5 pain flow (rutin yumuşatılır)
```

## 5. Tasarımcıya açık sorular (kurucu/koordinatör kararı)

1. `measuredBelowRange` görselleştirmesi: hedef tabanı bir ilerleme çubuğu
   olarak göstermek motive edici mi, yoksa "yetersizsin" hissi mi yaratır?
2. `retest_countdown` ana ekranda ne kadar öne çıkmalı — döngü ürünün Kuzey
   Yıldızı ama geri sayım baskı da yaratabilir.
3. 12 testin tamamı tek oturumda mı, bölünebilir mi? (plank dayanıklılık
   testi ve ASLR supine yorgunluk sırası etkiler.)
4. `coming_soon` ailelerin görünürlüğü: kapsam algısı için gerekli ama
   "boş uygulama" hissi riski var.

## 6. Bu brief'in kapsamadığı

- Görsel kimlik (renk/tipografi/logo) — ayrı iş.
- Yoga dalgası içerik ekranları (wave 1) — envanterde yer tutuyor, detay yok.
- Programs/rutin motoru ekranları — assessment akışı önce oturmalı.
- Kamera native köprüsü henüz YOK (aile geneli en büyük eksik kod bloku,
  koordinatör kuyruğunda): bugün her şey fixture/replay üzerinde. Tasarım
  canlı-tur ekranını gerçek kamerayla test EDİLMEDİĞİNİ bilerek okumalı.
