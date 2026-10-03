# Lissom — İlerleme Kaydı

## 2026-10-01 — Hatha kaynak paketi app pinine bağlandı

60 ders, 480 sahne ve 480 varyantın kurs/dilim/projeksiyon SHA'ları
uygulama Dart sabitleri ve paket testiyle eşleşiyor. h30'un sekiz
semantik varyantı hâlâ **HOLD**; medya okunmadan reddediliyor. Medya
odak testleri **22/22**, hedefli analiz temiz, bağımsız kaynak incelemesi
dar PASS (`scratch/2026-10-01-motion-ol-live-pin-independent-peer-v1/REPORT.md`).
Gerçek video, kişi-ayrık uzman form modeli ve fiziksel cihaz kabulü açık.


## 2026-09-28 — Hatha paket bütünlüğü ve üretici sapması onarımı

Değişmeyen 60 derslik Hatha JSON'u (259.103 bayt; SHA
`0e339eec3e24446260621703ab93f8163efc750f76979b0c4210abd942d4ff08`)
tek varlıklı Motion Content manifestiyle açılışta doğrulanıyor; bozuk veya
eksik paket ders/ilerleme görünmeden yükleme hatasına düşüyor. Manifest
`--check`, **9/9** odak Flutter testi ve hedefli analiz geçti. Bağımsız
kaynak incelemesi runtime yamada P0/P1/P2 bulmadı.

Eski Hatha üreticisi yayımlanan zenginleştirilmiş JSON'u yeniden
üretemiyordu: `--write` 60 dersin pratik/öz değerlendirme eklerini geri
alabilirdi. Repo içi, 60 kimliğe ve izinli alanlara bağlı overlay ile taban
ve çıktı SHA/uzunluk kapıları eklendi. `--check` artık yayımlanan JSON'la
bayt-bayt eşit; **11/11** Python testi ve bağımsız tekrar inceleme PASS
(`scratch/2026-09-28-lissom-runtime-integrity-peer/ADDENDUM.md`). Üretici
ve manifest kontrolleri CI'a bağlandı. Kurs JSON'u, ders sırası ve
ilerleme şeması değiştirilmedi. Gerçek video, kişi-ayrık uzman form modeli,
native cihaz ve kurucu fiziksel kabulü açık.

## 2026-09-28 — Hatha Yoga ilk kursu; içerik köprüsü dar PASS, ürün kabulü açık

İlk Hatha Yoga kursu **60 ders** ve canlı v8d kaynak paketinde. Gebelik,
sakatlık ve kronik durumlar için yalnız genel bilgi/uyarlama sınırı geçerli;
kişisel rehabilitasyon veya otomatik güvenli form hükmü yok. Gerçek onaylı
video, uzman kişi-ayrık hata verisi ve tam-kurs form modeli **0**. Sabit
Motion Core `motion_content` okuyucusu güncel kurs JSON'unu SHA ile
doğruladı; odak testi **4/4**, bağımsız dar peer PASS
(`scratch/2026-09-28-lissom-content-bridge-peer-v1/REPORT.md`). Üretim
manifesti, ekran/oynatıcı ve gerçek cihaz kabulü açık.

Güncel kurs ve kaynak düzeyi içerik köprüsü `a9599ab` commitinde mevcut PR #1
incelemesine taşındı. GitHub Actions'ın üç işi bütçe engeliyle başlamadı;
bu kaynaklar için yararlı CI, merge veya mağaza kabulü yok. Kanonik devam:
`holding/plans/MOTION-MODEL-RESUME-2026-09-27.md`.

## 2026-07-25 — Venture AÇILDI (ayrı repo; kod YOK)
- Kurucu kararıyla monorepo'dan ayrı repoya kuruldu (`kocakkmustafa/lissom`); plan + kilitli CLAUDE.md + defterler hazır; bundle-id `com.yulalab.lissom` rezerve.

## 2026-07-26 — KOD KİLİDİ AÇILDI · G0 tamam · G1-a ŞARTLI GEÇTİ
Kurucu tetiği: "Lissom'a başlayalım". Otonom gece modu aktif.
Dallar (yerel, push YOK): lissom `feat/g0-arastirma-g1-kapi` · motion-core `feat/lissom-g1-olcum-hatti`

### G0 — Derin araştırma (KANIT: 10 dosya, hepsi URL'li kaynaklı)
`app/docs/research/` — 10 paralel araştırma (Workflow fan-out, sonnet, ~972k token):
kamera kurulumu · Halo protokolü · ROM normatif değerler · denge/salınım · açı matematiği ·
rakip doğrulama · yoga taksonomisi · egzersiz havuzu · wellness dil süzgeci · MediaPipe detayları

**En değerli bulgu — L-002 KAPANDI:** GOWOD'un mobilite testi CV DEĞİL. Kullanıcı referans videoyu
izleyip **slider ile kendini değerlendiriyor** (kendi "how it works" sayfası). Lissom'un "gerçekten
ölçer" konumlandırması artık kanıta dayanıyor, varsayıma değil.

**Dürüstlük sinyali:** Halo Movement (tek hakemli emsal) genel skoru referans testlerle yalnız
r=0.29-0.63 korelasyon almış; test-tekrar güvenilirliği hareket-KISITLI grupta %35 daha kötü
(CV %2.16 vs %1.60) — yani tam bizim hedef kitlemizde en gürültülü. Bandlar buna göre yazıldı.

### G1 — Kapı ikiye bölündü (L-008), G1-a ölçüldü
- `docs/G1-V0-KAPI-PROTOKOLU.md` (rev.3): eşikler ÖLÇÜMDEN ÖNCE yazıldı, koşum sırasında değişmedi
- `docs/G1-V0-KAPI-RAPORU.md`: ölçüm sonuçları + yaw duyarlılık matrisi
- `docs/FIXTURE-CEKIM-LISTESI.md`: kurucu çekim protokolü (4 tur, dosya adı sözleşmesi)

**G1-a HÜKÜM: ŞARTLI GEÇTİ** — A1 0.000° · A2 0.854° · A3 1.705° · A4 0.000° · A6 0 sızıntı ·
A9 0 ölü metrik (18 metrik). A7/A8 (state machine) ÖLÇÜLMEDİ → L-014.

**Kapı üç kez kırmızı yandı, üçünde de gerçek hata buldu:**
| Bulgu | Ölçülen hata | Düzeltme sonrası |
|---|---|---|
| L-009 ham 3D açı (omuz≠kalça genişliği) | 5.71° | 0.00° |
| L-010 tek taraflı gövde vektörü | 11.31° | 0.00° |
| L-011 ölü metrik (`angle_vertical`+`transverse` = hep 90°) | sabit 90.0000° | yeniden tanımlandı |

L-011 en tehlikelisiydi: sabit değer makul GÖRÜNEN bir skora dönüşür, kimse fark etmez.
Kapının bunu kaçırma zaafı da kapatıldı (A9 kriteri, L-012).

### Ölçüm altyapısı (motion-core `tools/fixture_pipeline/`)
- `extract_landmarks.py` — video → MediaPipe → fixture JSON. 3 test klibiyle uçtan uca koştu;
  bozuk isimli klip reddedildi, diğerleri etkilenmedi. ⚠️ Test videolarında insan yok → gerçek
  tespit oranı DOĞRULANMADI (kurucu çekimi bekliyor).
- `fetch_models.sh` — pinli `/1/` yolundan indirir, SHA-256 doğrular
- `gate_g1a.py` + `mocore/` — kapı koşucusu ve ölçüm matematiği referansı
- **M-L-01 ölçüldü:** MediaPipe `full` bundle'ı `/latest/` ile `/1/` FARKLI hash veriyor (dosya
  boyutu aynı → fark gözden kaçar). Pinleme artık teorik değil, kanıtlı zorunluluk.

### Config'ler (Lissom `app/config/`)
- `metrics/lissom-metrics.v1.json` — 18 metrik (11 tanım + 7 ayna), versiyonlu
- `tests/lissom-assessment.v1.json` — 10 aday test: talimat metni (EN), düzlem, tekrar, metrikler,
  geçersizlik kuralları, yaş-bandlı skorlama. Hangi testin sayısal/nitel/ordinal olacağı literatürün
  gerçekten söylediğine göre ayrıldı — norm yoksa sayı uydurulmadı.

### Kurucu kararları (bu oturumda alınan)
| Karar | İçerik |
|---|---|
| Çekirdek | **Dart `motion_core` kanonik**; Python hattı yalnız video→fixture çıkarma aracı. Devir notu: `docs/DART-COREA-DEVIR.md` |
| Kapsam | motion-core'a dokunulmayacak (eşzamanlı oturum orada Dart yazıyor) |
| Commit | feat dalına yerel commit, push yok |

### ⚠️ Eşzamanlı oturum tespiti
motion-core main'ine 02:41'de başka bir oturum `8950c03 feat(core): motion_core çekirdeği` commit'i
attı (19 dosya, Dart). Ölçüm matematiği benim Python hattımla örtüşüyor. Kurucu kararıyla Dart
kanonik ilan edildi. Bu oturumun bulguları (L-009/010/011 + 2 tasarım farkı) devir notuyla Dart
tarafına taşındı. **Dart'ta kontrol edilmesi gereken tek açık:** frontal çekimde tek taraflı eklem
açıları L-009 hatasını taşıyabilir.
Ayrıca: `.gitignore`'u yeniden yazarken diğer oturumun `.dart_tool/` ignore'unu silmiştim — onarıldı.

### Sıradaki (bu oturum devam ederse)
1. Wellness dil süzgeci → çalıştırılabilir CI denetimi (`research/09` hazır)
2. G2 PRD (akışlar, veri modeli, ADR'ler)
3. L-016: 6 metrik doğruluk garantisi olmadan taşınıyor — A1 kapsamına alınmalı
4. Egzersiz havuzunun ürünleştirilmesi (`research/08` hazır)

### Kurucu eli gerekenler (biriken liste)
- **Fixture çekimi** (`docs/FIXTURE-CEKIM-LISTESI.md`) — G1-b bunsuz ölçülemez, ürünün tüm varsayımı buna bağlı
- Uzman doğrulaması (mobilite/fitness uzmanı) — test güvenliği + egzersiz seçimi
- İç doğrulama çalışması katılımcıları (n≥20-30) — "measures" iddiası için (L-005)
- Domain (lissom.fit $2.99 / lissom.yoga — M-006)
- Push / main'e merge onayı

## 2026-07-26 (2. tur) — Kurucu karar paketi işlendi · G2 PRD yazıldı

Koordinatör oturumdan gelen karar paketi (M-F-01..M-F-12) alındı ve uygulandı.
Push doğrulandı: `origin/feat/g0-arastirma-g1-kapi` = `4c40976`, yerelle senkron.

### Kapanan kararlar
| Kayıt | Sonuç |
|---|---|
| L-020 | **Simetri vaadi KORUNUYOR, şartlı** — taraf kimliği geometrik kurulur, model etiketine ham güven yok; eşleme yoksa simetri üretilmez |
| L-019/L-023 | `StructuralValidator` + `ConfidenceGate.forVariant` çekirdekten tüketilir, Lissom kendi sürümünü yazmaz |
| L-022 | Köken alanları zorunlu (model varyantı/sürümü/sha + config sürümleri + kalibrasyon profili) |
| L-024 | Ses-gecikme kalibrasyonu core modülünden gelir |
| L-025 | Doğrulama öncesi **sayısal skor yok**, yalnız nitel bant |
| L-026 | Kalibrasyon **sert kapı**, yaw ≤10° |
| L-027 | Yaş bandı zorunlu · cinsiyet opsiyonel · ağrı akışı tanımlı · riskli 7 hareket öyküde filtrelenir |

### L-016 kapandı — ve kapı iki hata daha buldu
Kapsam genişletmesi sırasında (beklenen-değer formülü olmayan metrikleri A4/A5/A9'a almak):

| Bulgu | Ne çıktı |
|---|---|
| **L-028** | `heel_rise` yanlış şeyi ölçüyordu: `distance_norm(HEEL, FOOT_INDEX)` = **ayak uzunluğu**, topuk ne yaparsa yapsın sabit. Squat'ta topuk kalkmasını yakalaması gereken koruma hiç ateşlenmezdi. Üstelik üreteçte topuk-kalkma olgusu hiç yoktu → metrik sınanmıyordu bile |
| **L-029** | Normalizasyon referansı poza duyarlıydı: `torso_length` gövde yana eğilince **%1,63** kayıyor, ona bölünen her metrik onunla kayıyor. Kanonik Dart çekirdeği zaten doğru yapıyormuş; Python ona uyduruldu |
| **L-030** | Kapı probları elle yazılmıştı, yeni parametre eklenince eskidi ve masum metriği "ölü" gösterdi → problar artık tarama uzayından türetiliyor |
| **L-031** (açık) | Dart image düzleminde, Python 3D world uzayında ölçüyor — differential test öncesi hizalanmalı |

Kapı son durum: **A1 0,000° · A2 0,467° · A3 0,931° · A4 0,040° · A6 0 sızıntı · A9 0/18 ölü.** Kapsam dışı tek metrik `reach_depth` (analitik beklentisi tautoloji olurdu; A4/A5/A9 koruması var, raporda isimle görünüyor).

### G2 üretildi
- `docs/PRD.md` — 13 bölüm; akışlar, kalibrasyon kapısı, skorlama, program motoru, veri modeli (köken alanları), MDC kapısı, 12 kabul kriteri
- `docs/ADR/001..006` — taraf kimliği · kalibrasyon kapısı · nitel-bant · köken · versiyonlu config · çekirdekten tüketim
- `.github/workflows/checks.yml` + `tools/config_check.py` + `tools/lint_selftest.py`

**CI'ın üçüncü kapısı süzgecin kendisini sınıyor:** 4 bilinen ihlal yakalanmalı, 2 meşru metin geçmeli. Gerekçe pratikten geldi — ADR'leri yanlış dizine yazınca süzgeç 0 dosya tarayıp "temiz" dedi. Artık boş tarama çıkış kodu 2 veriyor.

### Sıradaki
Egzersiz havuzunun config'e çevrilmesi (72 hareket) · G1-b kurucu çekimi bekliyor · MDC eşiği G1-b'den türetilecek

---

## 🔔 OTURUM SONU — 2026-07-29 (gece vardiyası)

### Bu oturumda BİTEN

- **M-F-54 çerçeve taksonomisi motion-core main'de** (`frameRef`: camera·gravityYaw·proximal·none). ±30° yaw sapması **tüm kategorilerde 0,00°** (öncesi 11-17°); `shoulder_line_foreshortening` kasıtlı 0,11°'de (`camera`). A1-A11 **iki modda da** yeşil. `MOCORE_ANATOMICAL` varsayılan **0** — çevirme AYRI karar (kriter: Gravita gövde-metriği kapıları iki modda yeşil + bir tam hasat çevrimi).
- **L-138 kapandı:** `movementPresence` artık çok-eklemli ve sözlüğünü rig'in `perMovement.identity` bloğundan **TÜKETİYOR**, kendi sözlüğünü kurmuyor. `hipKneeCoupling` (pearson, min 0,20, `provisional`) bataryada beyan edilip türeticiyle profile taşınıyor; `pending` sinyaller kapı kurmuyor.
- **L-139 teşhisi doğrulandı** (koordinatör): CLI'da çevrim segmentasyonu YOK → DTW farklı tekrar-sayılı videoları bükerken çevrim sınırlarını eziyor; 34-43°'lik sapmaların kaynağı bu. Önerdiğim ayırt-edici sınama **0.8.0'ın kabul-testi** oldu.
- **Kaynak-arama turu:** 85 aday / 71 kanal → **9 yeni bağımsız eğitmen**. Zincir koştu: **giren 9 → hayatta 6** (triyaj 8/9 · romMode 6/8 · presence 6/6). `overhead_reach` **0'dan 6 uygun kaynağa** çıktı.
- Fiziksel-aralık kapısı · `romMode` güçlü/zayıf işaret ayrımı · `contextTags` · `passiveExecutionPossible` · transcribe P0 (dizin oluşturmuyordu) · dedup kendi-eşleşmesi — hepsi çekirdekte, testli.

### AÇIK — yeni oturumun devraldığı

| konu | durum |
|---|---|
| **`deep_squat` dürüst-red** | 3 kapı da (kimlik · sayı · hizalama) gerçek engel bildirdi, hiçbiri gevşetilmedi. **0.8.0 çevrim-segmentasyonunu bekliyor.** |
| **`overhead_reach` 6 uygun kaynak** | CLI'ın `_deviationsFromConsensus` çökmesi (L-143, P0) düzelince ilk kanonik referans adayı |
| **L-135 sessiz-hiçlik** (3 test) | ürün kararı bekliyor — `overhead_reach` ≥60° · `ankle_dorsiflexion`/`lateral_bend` ≥15° kapıları altında kullanıcı HİÇBİR ŞEY görmüyor |
| **A1-A11 anatomik varsayılan** | ayrı karar, tetiklenmedi |
| `hip_hinge` | kaynak-yetersiz (2 uygun), beklemede |
| L-142 | arama ön-filtrem AÇIKLAMA alanını okumuyor (2 aday boşuna indirildi) |

### Park edilen arka-plan işi

**YOK.** `overhead_reach` hasat zinciri **TAMAMLANDI** (9/9 aday işlendi — koordinatörün "2/9" kaydı bayat). Kuyrukta bu test için işlenmemiş aday **0**; yeni kaynaklar kuyruk DIŞINDAN arama turuyla geldi ve hepsi işlendi.

### Repo durumu

`lissom/app` main `9cbe893` · `motion-core/lib` `feat/lissom-v3-onayi` `05aacaf` — ikisi de origin ile **eşit**, çalışma ağaçları temiz. motion-core katkılarım koordinatör tarafından `2432fbf` ve sonrasında merge edildi.

---

## 🌙 GECE VARDİYASI — 2026-07-29/30 (Opus-high, ürün-tamamlama hedefi)

Paket: `ventures/motion-core/workspace/GECE-PAKETLERI-2026-07-29.md` → LİSSOM (5 kalem).

### 1. presence_isolator — BİTTİ, merge bekliyor
motion-core `feat/presence-isolator` @ `77caef9` (origin'de). Üçüncü izolatör:
periyodik tekrar→`movement_isolator` · statik tutuş→`hold_isolator` ·
**faz-tanımlı gösterim→`presence_isolator`**. Sürücü: 3-nokta açısı, eşik+SÜRE
tabanlı (hız/periyodiklik DEĞİL) → L-151'in konuşma-jesti tuzağına yapısal
olarak bağışık. 9 self-test senaryosu, `tests/test_rig.py` [11] olarak bağlı,
11/11 yeşil. J-052-v2 `required_ids` tek-triplet savunması olarak bağlandı;
`{side}`-şablonlu çiftlerde OR-of-ANDs gerekçesi kodda yazılı. (L-152/L-153)

### 2. L-155 göçü — BİTTİ, merge bekliyor
motion-core `feat/measures-mask-invalid` @ `2108f28`. `evaluate()` artık
`mask_invalid=True` varsayılan. **Göç güvenliği ölçüldü, varsayılmadı:**
`fixture_check.py` 4 kontrolde bit-özdeş · `gate_g1a.py` bit-özdeş DEĞİL ve
fark GERÇEK (A9 iki çöp okumayı "perturbasyona tepki" sayarak yanlış geçiyordu;
hüküm GEÇTİ→SINIRDA 9/10). Düzeltmedim — SWEEPS/A9 kapsam boşluğu sahibine
bırakıldı. Denetimde 3. tüketici bulundu (`phases.py` `.valid` yerine
`isFinite` kontrol ediyordu — bu fix onu bedava düzeltti). (L-156)

### 3. Presence-pencereli yeniden-koşumlar — YAPILDI, referans YİNE KURULMADI
`overhead_reach` 6 kaynak kesildi → sapmalar **72,3/108,2/70,1/52,7/72,9°**
(pencereleme ÖNCESİNDEN kötü). `deep_squat` 3 kaynak → 23,4/33,8/38,6° (karışık).
Teşhis: kesilen pencereler 129-1294 kare arası (10× fark) — L-153'ün "şüpheli
uzun tutuş" bulgusunu DOĞRULUYOR. **Pencereleme kök nedeni çözmedi**; anlaşmazlık
M-F-71/L-151'in "3. adım"ına (kaynak-başına kimlik incelemesi) taşındı, o adım
bu vardiyada kapsam dışı bırakıldı. `deep_squat`'a `presence` speklendi. (L-157)

### 4. lissom_engine — KURULDU (en büyük açık kapandı)
`packages/lissom_engine`, `motion_core-v0.8.4` tag-pinli. M-F-71 hükmü
mimarinin kendisi: girişim kapısı ROM değil hareket-varlığı · girişim varsa
ölçüm daima tamamlanır (timeout değeri KORUR) · bandın altı `measuredBelowRange`
ve bant etiketi ALMAZ · `finish()` hiçbir yolda null dönmez. **23/23 test,
analyze temiz.** İki süit iki farklı soruyu cevaplıyor; gerçek-config süiti ilk
koşumda kendi okuyucumdaki boşluğu yakaladı (`ordinal` = 3. skorlama tipi,
sentetik-yeşilken gerçek dosyada patlıyordu). (L-158/L-159)

### 5. UI-BRIEF — YAZILDI
`docs/design/UI-BRIEF.md`. Uydurma ekran yok; envanter mevcut config/PRD/motordan
türetildi. Merkezi bölüm: sonuç ekranının 4 katmanı, motorun `ResultTier`'ıyla
birebir. 4 tasarım sorusu kurucu/koordinatöre bırakıldı. (L-160)

### Kapılar (vardiya sonu)
Python: config_check · phase_check · phase_check_selftest · triage_landmarks ·
wellness_lint · lint_selftest · threshold_gate_scenario_test — **hepsi yeşil**.
Dart: `lissom_engine` 23/23 + analyze temiz. rig `tests/test_rig.py` 11/11.

### Repo durumu
`lissom/app` main `d5101b7` (origin-eşit) · motion-core iki dal origin'de
merge bekliyor (`feat/presence-isolator` `77caef9` · `feat/measures-mask-invalid`
`2108f28`) · paylaşımlı ağaç `ventures/motion-core/lib` HÂLÂ `feat/lissom-v3-onayi`,
dal değiştirilmedi.

### Sıradaki oturumun devraldığı
1. **metricReader kapanışı gerçek `JointAngleExtractor`'a bağlanacak** — motor
   bugün enjekte edilen değerlerle test ediliyor, gerçek geometriyle değil.
2. Kaynak-kimlik incelemesi (L-157 3. adım): kanal-arası TANIM farkı mı, stil
   varyansı mı — `overhead_reach`/`deep_squat` referansının önündeki tek engel.
3. A9/SWEEPS kapsam boşluğu (L-156) — ayak bileğini süren prob yok.
4. Kamera native köprüsü (koordinatör kuyruğunda) gelmeden canlı-tur ekranı
   gerçek kamerayla doğrulanamaz.

---

## 🌙 GECE VARDİYASI — devam paketi (2026-07-30, kesinti sonrası)

Kesinti (22:20 "Server error mid-response") sonrası ilk iş ağaç doğrulaması
oldu: `e6a366e` temiz, ahead/behind 0, 42/42 test + analyze yeşil — beyana
değil ağaca güvenildi, kayıp YOK.

### Tamamlanan (4+3 kalem)

| # | İş | Sonuç |
|---|---|---|
| A9/SWEEPS | Zincir problar | **A9 dürüst yoldan GEÇTİ'ye döndü** (0/19 ölü). `fix/a9-valid-only-probes` → koordinatör MERGE'ledi (`144b767`) |
| Adım-3 | Kaynak-kimlik incelemesi | `tools/identity_review.py`; **üç bağımsız eksen** ölçüldü (L-162) |
| Replay | Motor ↔ gerçek fixture | **İKİ kendi hatamı buldu** (ters konvansiyon + tamamlanmış ölçümü çöpe atan sıra) — L-164 |
| Tasarım | 4 soru → koordinatöre | L-163 → hükümler geldi (M-F-133) |
| M-F-133 | 4 hüküm kodlandı | UI-BRIEF §5 bağlayıcı kısıt; blok modeli config+motor (`AssessmentSession`) |
| Ön-eleme | L-162 → arama tarafı | **İlk tasarımım çürütüldü** — kullanılabilir tek kaynağı eliyordu (L-166); yalnız-eleyiciye çevrildi |
| M-F-138 | Bayat-uygunluk süpürmesi | **İzolatörler temiz, KESİCİ etkilenmiş** → `derivedFrom` ile snapshot SORULABİLİR yapıldı (L-167) |

### İlk referans: DÜRÜST NEGATİF (mühürlü)

`docs/ILK-REFERANS-DURUST-NEGATIF.md` — beş tur, beşi de RET. Kök neden üç
bağımsız eksende ölçüldü (duruş · kamera görüşü · hareket kimliği); üçünü
birlikte geçen kaynak `overhead_reach` **1/6**, `deep_squat` **1/4**,
minSources=3. Beş alternatif açıklama sırayla elendi. Aile bağlamı: Ostinato
üç çalgı + JabLab stance ile aynı sınıf — "havuz büyütmek anlaşma getirmiyor".

### Bu turun kendi-hata bilançosu (dürüstlük kaydı)

Bu tur **üç** kendi hatamı ölçümle buldum: ters konvansiyon köprüsü ·
tamamlanmış ölçümü çöpe atan `finish()` sırası · kullanılabilir tek kaynağı
eleyen ön-eleme tasarımı. Üçü de "makul GÖRÜNEN" çıktı üretiyordu; üçünü de
gerçek veriye karşı koşmak yakaladı, kod okumak yakalamadı.

### Kapılar (tur sonu)
Dart: `lissom_engine` **42/42** + analyze temiz. Python: config_check(8 dosya) ·
phase_check · phase_check_selftest · wellness_lint · lint_selftest ·
triage_landmarks · threshold_gate_scenario_test — hepsi yeşil.

### Repo
`lissom/app` main **`8de0f1f`** + bu tur DEFTER/PROGRESS/rapor · motion-core
`fix/a9-valid-only-probes` MERGE'li · paylaşımlı ağaç `feat/lissom-v3-onayi`
dokunulmadı.

### Devralınan
1. **Hedefli hasat — sıram ÜÇÜNCÜ** (Choreia → JabLab → ben). Filtre kodu
   HAZIR (`harvest_prescreen.py`), probe/indirme SIRA BEKLİYOR.
2. M-F-138 ortak yardımcısı (JabLab) indiğinde kesiciyi hizala.
3. M-F-133 madde 3 hüküm revizesi (L-165): blok örneği ↔ veri ayrışması.
4. `motion_camera` plugin doğdu — `lissom_engine` ileride tüketecek.
5. metricReader yalnız 4 metriğe bağlı (shoulder/knee); kalan metrikler
   köprüye eklenmeli.

---

## 🌙 VARDİYA KAPANIŞI — 2026-07-30 (kurucu direktifi: tüm oturumlar
sonlandırılıyor, devam YENİ oturumda)

Bu bölüm önceki günlüğün BIRAKTIĞI yerden devam eder (metricReader/kaynak-
kimlik/A9/kamera köprüsü kalemleri) ve gece vardiyasının kalan tamamını
kapsar. Tam devir kaynağı: **`YENI-OTURUM-PROMPT.md`** — burası özet.

### Bu vardiyada tamamlanan (sırayla, DEFTER L-numaralarıyla)

| iş | sonuç |
|---|---|
| M-F-71 uygulaması | `lissom_engine` bootstrap edildi — 5 dosya, tier/kod/oturum/köprü/özet |
| Reference-free-live (4 koşul) | koordinatör onaylı: yüzey gerekçesi + terfi yolu + yazım-anı `lessonClass` + "ölçüm, not değil" beyanı |
| L-176 | Statü-örgüsü KAPI oldu (`status_weave_check.py`) + `BatterySummary` (A5 veri modeli, tür-ayrımı) |
| L-177 | A5 YAPI widget'ı (`battery_summary_view.dart`) — 11 test, 4 sabotaj vakası (3'ü 🔴, 1'i gerçek delik buldu → panzehir) |
| L-178 | `reps` config'ten SİLİNDİ (koordinatör hükmü — okuyucusu yoktu) |
| L-179 | Çekirdek `SessionStore`'a İLK tüketici bağlaması (`motion_core-v0.9.0`) — 4 çeviri kararı, hepsi ölçümle |
| L-180 | B1/B2 taban-oran ön-koşulu — **ONAYLI ve BAĞLAYICI** (§3.2b), karantina-çekme YETKİLİ, henüz KOŞULMADI |
| **L-181** | **P0 — motor 3 testte (deep_squat/forward_lunge/thoracic_rotation) ölçümü TERS yönde topluyordu.** `higherIsBetter` artık ZORUNLU; `direction_check.py` |
| L-182 | Hüküm-yok yolları canlılık kapısı (`noverdict_liveness.py`) — 6/6 canlı kod temiz |
| L-183 | Pozitif-ikiz taraması — 5 vacuous-geçiş yolu (hepsi kendi testlerim), hepsi kapandı |
| L-184 | `reclassify_pool.py` iki transkript deposundan birini okuyordu — 11 manifest yanlış öncülle fail-closed olmuş, düzeltildi |
| L-185 | **Bulgu:** havuz darboğazı uygunluk değil HAREKET KİMLİĞİ — 23 uygun kaynağın 19'u etiketsiz |
| L-171 | **Sonuç, tek satır:** izole-sonda BİTTİ ve PUSH'LU (`608a739`) — eşiğin (40) landmark-kalitesiyle ölçülmüş dayanağı YOK (r≈0,00–0,21, biri ters işaretli); karar koordinatörde, düşük-uç örneklemesi L-180'in karantina turuyla PAYLAŞIYOR |

### ⚠️ Koordinatör iletisindeki İKİ İDDİA DOĞRULANDI VE DÜZELTİLDİ

Kapanış görevi metninde iki iddia vardı; ikisini de ağaca karşı ölçtüm (kesinti-
sonrası "beyana değil ağaca güven" kuralı burada da geçerli):

1. **"M-F-53/54 anatomik-düzlem KISMİ, MOCORE bunu bekliyor"** — YANLIŞ.
   `b424246`(M-F-53) + `05aacaf`(M-F-54) ikisi de `motion_core-v0.9.0`
   TAG'İNİN İÇİNDE, o tag zaten origin/main'de VE Lissom'un aktif pini. M-F-54
   M-F-53'ün bıraktığı kısmı (uzuv açılarının kayması) `frameRef` taksonomisiyle
   (camera|gravityYaw|proximal|none) TAMAMEN kapattı — yaw sapması tüm
   kategorilerde SIFIR, A1-A11 iki modda yeşil. Lissom kendi config'inde
   `MOCORE_ANATOMICAL` bayrağını zaten tüketiyor (L-154, bu turdan önce).
   **Kalan iş YOK.**
2. **"Bu vardiyanın gotcha'ları: FakeAsync+gerçek-I/O, rootBundle kilitlenmesi,
   wave-körlüğü"** — bu üç terim `lissom/app`'te, `motion-core`'da, bu
   PROGRESS'te ve DEFTER'de SIFIR eşleşme veriyor. Muhtemelen kardeş bir
   app'in (Choreia/Gravita/JabLab/Ostinato) gotcha'ları koordinatörün
   çapraz-oturum belleğinde karıştı. **YENI-OTURUM-PROMPT.md'ye UYDURULMADI**
   — orada gerçekten bu turda ölçülen gotcha'lar var (L-181 sessiz varsayılan,
   L-184 sessiz-yanlış-gerekçe).

### Repo durumu (doğrulandı, beyan değil)

`lissom/app` main **`2d2aae5`**, origin-eşit, çalışma ağacı temiz. `motion-
core/lib` **`feat/lissom-v3-onayi` @ `05aacaf`**, origin-eşit, çalışma ağacı
temiz, **zaten origin/main'in ecdadı** (merge bekleyen iş yok). Paylaşımlı
ağacın dalı bu vardiya boyunca DEĞİŞTİRİLMEDİ.

### Kapılar (vardiya sonu — TAM liste)

Dart: `lissom_engine` **69/69** + `lissom` (app) **22/22** + analyze TEMİZ (her
ikisi). Python (10 kapı, 3'ü öz-testli): config_check · phase_check ·
phase_check_selftest · triage_landmarks · wellness_lint · lint_selftest ·
threshold_gate_scenario_test · status_weave_check · direction_check ·
noverdict_liveness — **hepsi yeşil**.

### Devralınan (SIRALI — tam gerekçe `YENI-OTURUM-PROMPT.md`'de)

1. **metricReader köprüsü 18 metriğin yalnız 5'ine bağlı** (shoulder/knee
   L+R + trunk_lean) — kalan 13 metrik canlı-tur ekranını engelliyor.
2. L-180 §3.2b taban-oran ölçümü — karantina-çekme yetkili, koşulmadı.
3. L-171 düşük-uç örneklemesi — L-180 ile AYNI turda (tek çıkarma).
4. L-185 hareket-kimliği turu — 19 etiketsiz uygun kaynak.
5. L-173 pencere-düzeyi varyant-kimliği tasarımı — koordinatörün kuyruğunda.
6. 11 fixture yeniden-kesim gerektiriyor (L-184, M-F-138).

**MÜHÜRLENDİ** — bu vardiyanın son girdisi. Devam `YENI-OTURUM-PROMPT.md`'den.

---

## 🌅 VARDİYA — 2026-08-04 (metricReader köprüsü turu)

Koordinatör emri: *"metricReader köprüsü ŞİMDİ — 13 eksik metrik; canlı-tur
ekranının gerçek-geometri yolu."* Köprüye girdim; **köprünün eksik olduğu
kadar YANLIŞ UZAYDA olduğu çıktı.** Kuyruk maddesi 2 (L-180/L-171 tek-çıkarma
turu) bu turda BAŞLAMADI.

### Yapılanlar

| iş | sonuç | defter |
|---|---|---|
| Köprü kapsamı config'ten türetildi | Gereken **19** (devir notu "18" diyordu) · bağlı **4** (devir notu "5, trunk_lean dahil" diyordu — `trunk_lean` Dart'ta hiç yoktu) | L-188 |
| +4 köprü, konvansiyonu ÖLÇÜLDÜ | `hip_flexion` L/R · `elbow_extension` L/R → **8/19** | L-188 |
| Kalan 11 metrik isimli engelle beyan | `corePlaneSeparationMissing` ×4 · `coreLacksMeasureKind` ×7 | L-188 |
| Kapsam kapısı + 4 sabotaj öz-testi | `metric_coverage_test.dart`, bölme zorlanıyor | L-188 |
| **J-028 ihlali bulundu ve düzeltildi** | Köprü ham anizotropik uzayda ölçüyordu; `toIsotropic` uygulanmıyordu. `frameSize` artık ZORUNLU | **L-186** |
| **L-031 ilk kez ÖLÇÜLDÜ** | 3 fixture × 8 metrik × **44.022 kare**, eşleştirilmiş | **L-187** |

### Ölçülen sayı (kanıt: `docs/L-031-UZAY-SAPMASI-OLCUMU.md`)

Normatif referans = Python `world` 3D + config `frameRef` (`anatomical=True`).
Karşılaştırma bilerek Python tarafında — hakemi taraflardan biri yapmamak için.

| | medyan \|sapma\| | p95 | tepe |
|---|---|---|---|
| J-028 düzeltmesi ÖNCESİ | 18,20° | 67,55° | — |
| **SONRASI (şimdiki kod)** | **14,30°** | **60,64°** | 160,47° |
| düzeltmenin kazancı | −21,4% | −10,2% | — |

**Taklit kontrolü (pozitif):** Dart ↔ elle yazılmış ham 2D açı = **0,00°**
(medyan/p95/max, 44.022 kare) → Dart'ın ne yaptığı tahmin edilmedi, çivilendi.

**Kalan 14,30° medyan / 60,64° p95 = L-031'in gerçek kapsamı.** Yuvarlama
değil yön farkı: `overhead_reach` girişim kapısı 140°'de, bantlar derece
cinsinden.

### ⚠️ Karar zinciri yarım kalmış — koordinatöre giden

`docs/KARAR-BRIFI-kanonik-uzay.md` seçenek **C**'yi önerdi; C **yalnız
Python'da uygulandı**. `git show --stat` ile doğrulandı: M-F-53 (`b424246`) +
M-F-54 (`05aacaf`) **yalnız** `tools/fixture_pipeline/`'a dokundu, SIFIR Dart.
Pin `motion_core-v0.9.0`'ın Dart geometrisinde `frameRef` **0 kez** geçiyor
(pozitif kontrol: `AngleKind` 25 kez → grep çalışıyor). **Dart hattı bugün
fiilen seçenek B'de** — brifin *"perspektif hatası kalıcılaşır"* diye
reddettiği seçenekte.

Üç somut soru (paylaşımlı çekirdek + 4 kardeş app → eskalasyon kuralı):
1. Dart çekirdeği `world` + config `frameRef`'e geçecek mi (C'nin Dart göçü,
   L-031 kapanışı)? Bu bir `motion-core` işi, benim tek başıma alacağım karar
   değil.
2. Geçene dek canlı-tur ekranı hangi statüde koşacak? **Öneri:
   `measurementOnly`** (M-F-185) — ölçüm gösterilir, ROM hükmü verilmez;
   gerekçesi bu belgedeki sayı. Kod bunu zaten destekliyor.
3. **L-118/L-128 defter durumu bayat:** ikisi de "AÇIK (koordinatör kararı)"
   diye kayıtlı, ama C fiilen kararlaşmış ve bir tarafı uygulanmış.

### Neden kalan 11 metrik köprülenmedi

Mekanik eksiklik değil, çekirdek yeteneği eksikliği — ve bugünkü uzay
sorunu üstüne 11 metrik daha eklemek, bilinen-yanlış bir ölçümü çoğaltmak
olurdu:
- `distance_norm` · `height_diff_norm` · `line_deviation_norm` Dart
  çekirdeğinde **yok** (Python'da var).
- Çekirdekte tek ve İŞARETLİ bir `trunk_tilt` var (ölçüldü: −97,9°…+124,4°);
  config iki AYRI düzlem metriği istiyor (`trunk_lean` sagittal,
  `trunk_lateral_tilt` frontal). İkisini aynı sayıya bağlamak **L-011'in
  ölü-metrik sınıfı** olurdu.

### Kapılar (tur sonu)

Dart: `lissom_engine` **79/79** (69→79, +10 kapsam kapısı) + `lissom` (app)
**22/22** + analyze TEMİZ (ikisi de). Python **10 kapı** (3'ü öz-testli) —
hepsi yeşil.

### Repo

`lissom/app` main — bu tur commit'li+push'lu. `motion-core/lib` paylaşımlı
ağacına **DOKUNULMADI**, dalı DEĞİŞTİRİLMEDİ (M-F-22). Ölçüm çekirdeğin
pub-cache'teki PİNİ üzerinden yapıldı — paylaşımlı ağaç pinin kendisi değil,
bu turda öğrenilen ayrım.

---

## 📎 ZEYİL TURU (M-F-230) — ön-koşul KURULDU ve GEÇTİ, tur BAŞLAMADI

Koordinatör zeyli L-180/L-171 turunu MOCORE kriter-2 çevrimi ilan etti ve
pozitif kontrol zorunlu kıldı. Bayrak bağlı değilse **tüm tur geçersiz**
olacağı için bunu turdan ÖNCE ölçtüm (ağ gerektirmiyor — indirme slotunu
beklerken yapılacak en değerli iş).

`tools/two_mode_report.py` — iki-mod raporu + bayrak-canlılık kapısı. Kuralı
**iki yönlü** uyguluyor, çünkü tek yönlü hâli yanlış alarm verirdi:

- **POZİTİF KONTROL ✅ GEÇTİ** — 3 gerçek fixture, **8/11** metrik-fixture
  çiftinde mod ölçülebilir fark üretti: `hip_flexion_right` Δmed **+21,6°**,
  `knee_flexion_right` **+17,9°**, `tibia_inclination_right` +2,9°,
  `trunk_lateral_tilt` +1,2°. Bayrak BAĞLI.
- **NEGATİF KONTROL ✅ GEÇTİ** — `shoulder_line_foreshortening`
  (`frameRef: camera`) bit-aynı kaldı. `measures.evaluate` bayrağı yalnız
  `gravityYaw|proximal|none` çerçevelerinde kullanıyor, yani camera'da
  bit-aynılık **doğru davranış**; tek-yönlü kural burayı kırmızı yakardı.
  Yalnız pozitif kontrol "bayrak bağlı" der; ikisi birlikte **"bayrak DOĞRU
  yere bağlı"** der.

**Şart 5 hakkında isimli uyarı:** L-171 eşik-türetiminin girdileri
(`tools/landmark_quality.py` — tespit oranı · görünürlük · jitter · kadraj-içi)
`measures`'ı **hiç import etmiyor**, yani `mz.evaluate`'ten geçmiyor. O
katmanda anatomik/kamera farkı **yapısal olarak sıfırdır**; "eşik-türetimi
anatomik sayılardan yapılır" şartı orada boş bir şart. VMR ise etkilenir
(`evaluate` geçerliliği `value_range` süzgeciyle de belirliyor) — araç VMR'yi
ayrı kolonda tutuyor.

**Koordinatörün bir iddiası DOĞRUYDU, benim ilk grep'im yanlıştı:**
`fixture_check.py` env'i gerçekten okuyor (`tools/fixture_check.py:76`); ben
yanlış ağaçta (motion-core rig'i) arayıp "okumuyor" sonucuna varmıştım.
Ağaca karşı ölçmek düzeltti.

### ⚠️ Tur başlamadan çıkan yeni bulgu — L-190 (P1, koordinatörde)

**Beş metrik `frameRef: gravityYaw` beyan ediyor ama hesap o çerçeveyi
yapısal olarak KULLANMIYOR:** `heel_rise` L/R + `knee_height` L/R
(`height_diff_norm`) ve `reach_depth` (`distance_norm`, `plane: none`) — üç
fixture'da da bit-aynı. Sebep tahmin edilmedi, KODDA ölçüldü; `axes` kullanımı
ölçü tipi başına: `angle3` ✓ · `angle_vertical` ✓ · `line_deviation_norm` ✓ ·
**`height_diff_norm` ✗** · `distance_norm` yalnız `plane != none` iken.

**M-F-56 kriter-2'ye doğrudan etkisi:** anatomik moda çevirmek bu beş metriği
HİÇ değiştirmeyecek; flip "temiz" görünse de beyan-uygulama ayrışması
kapanmaz. Karar koordinatörde: beyan mı düzeltilir (bu iki ölçü tipi için
`gravityYaw` anlamsız), hesap mı (gerçek yerçekimi-hizalı dikey)? Üçüncü
seçenek yok — uygulanmayan beyan bırakmak L-181'in süse-dönüşme sınıfıdır.

### Kapılar (zeyil ön-koşulu sonrası)

Dart **79/79** + **22/22** + analyze temiz · Python **10 kapı** yeşil ·
`two_mode_report` pozitif+negatif kontrol GEÇTİ.

### Turun kalanı

İndirme (karantina çekmesi) BAŞLAMADI — slot JabLab'da, sabit kural teyit
istiyor. Ağ gerektirmeyen kalan iş: **sentetik tavan** (B1↔B2 boşluğunun
hattın kendi kaybını içerip içermediği, protokol §3.2b "tavan" satırı).

---

## 🔒 TUR MÜHRÜ — 2026-08-04: MOCORE KRİTER-2 SON AYAĞI

Koordinatör talimatı M-F-253. **Sonrası flip koordinatörde.** Tam kayıt:
`DEFTER.md` §"TUR MÜHRÜ" + L-186…L-203.

### Bu turda kapanan (sırayla)

| iş | sonuç | defter |
|---|---|---|
| metricReader köprüsü | 4→**8/19**; kalan 11 isimli engelle beyanlı + kapsam kapısı | L-188 |
| **J-028 ihlali** | köprü ham anizotropik uzayda ölçüyordu → `frameSize` ZORUNLU, `toIsotropic` uygulanıyor | **L-186** |
| **L-031 ilk kez ölçüldü** | 44.022 eşleştirilmiş kare; kalan sapma medyan **11,29°** / p95 **37,47°** | **L-187** |
| M-F-230 pozitif kontrol | **iki yönlü** kuruldu (tek yönlü yanlış alarm verirdi) | L-189 |
| L-190/1 | `reach_depth` beyanı düşürüldü (`frameRef: none`) — taze rig guard'ı eskisini REDDEDİYOR | L-192 |
| kendi gerekçe hatam | config `_notes`'taki roll açıklaması YANLIŞTI, düzeltildi | L-196 |
| **valid-otorite kusuru** | iki aracım geçersiz ölçümleri istatistiğe katıyordu → L-187 sayıları DÜZELTİLDİ | **L-197** |
| yeniden-koşum (taze rig) | pozitif 8/8 · muafiyet 3/3 · negatif geçti · üç bit-aynı sınıfı isimlendi | L-198 |
| **§3.2b tavan** | 10/10 testte VMR = 1,000 → **hat kaybı SIFIR** | **L-194** |
| M-F-54 sentetik doğrulama | anatomik modun yaw sapması TÜM kategorilerde **SIFIR** | L-195 |
| **karantina: gereksizdi** | videolar zaten diskte — ağa çıkılmadı, havuz temiz (34) | **L-199** |
| **§3.2b taban** | medyan ayrışma **+0,429** · RET ≥ KABUL **0/10** | **L-200** |
| **L-171 eşik türetimi** | **İSİMLİ KAPANIŞ: TÜRETİLEMEZ** (netlik↔VMR r = **+0,001**) | **L-203** |

### Kriter-2 özeti

**Bayrak-canlılık (iki yönlü, M-F-241 zeyli):** pozitif **8/8** · negatif ✅ ·
muafiyet **3/3**. **Üç bit-aynı sınıfı:** `camera-negatif` · `yaw-değişmez` ·
`frame-değişmez`. **Rig:** izole worktree `a4a1ac2`, araç rig kimliğini
rapora basıyor; **paylaşımlı ağacın dalı DEĞİŞTİRİLMEDİ** (M-F-22).

**L-180 §3.2b:** tavan ✅ (hat kaybı sıfır) + taban ✅ (ayrışma +0,429) —
ikisi de ölçüldü, B1/B2 artık taban-göreli okunabilir.

**L-171:** eşik **türetilemedi**; kapı fail-closed KALIR,
"dayanaksız-provisional" damgası KALKMADI, kapı-tasarımı koordinatörde.

### Kapılar
Dart **79/79** + **22/22** + analyze temiz · Python **10 kapı** ·
**+3 yeni araç-kapısı** (`two_mode_report` · `synthetic_ceiling` ·
`vmr_baseline`).

### Repo
`lissom/app` main — tüm tur commit'li+push'lu. Paylaşımlı `motion-core`
ağacına DOKUNULMADI.

### Açık kalan (hepsi koordinatörde)
L-187 (L-031 Dart uzay göçü — canlı-tur `measurementOnly` önerim) ·
L-193 (süs-beyan guard'ı göçle gelecek) · L-203 (netlik kapı-tasarımı) ·
L-185 (hareket-kimliği) · L-173 (varyant kimliği) · 11 fixture yeniden-kesim.

**MÜHÜRLENDİ.**


---

## 🔒 TUR MÜHRÜ — 2026-08-05: KAMERA ENTEGRASYONU (kalan-4 kapandı)

Kurucu emri: kalan dört kalem tek oturumda. **Dördü de bitti**; design turuna
GEÇİLMEDİ (sınır tutuldu). Tam kayıt: `DEFTER.md` L-205…L-211 + tur mührü.

| # | iş | sonuç |
|---|---|---|
| 1 | PoseSource → metricReader kablolama | kaynak BİLDİRİR · değerlendirici ÖLÇER (Ostinato) · 6 test |
| 2 | canlı-3 + engelli-9 | **TÜRETİMLİ** (`deriveLiveness`) · iki yönlü pozitif ikiz · 6 test |
| 3 | platform duvarları + sim kanıtı | MediaPipe **statik** ✓ · iOS sim derleme ✓ · `docs/kanit/sim-canli3-engelli9.png` |
| 4 | kapanış zinciri | mühür · Obsidian · design-turu promptu · merge |

### Turun en değerli bulgusu

**Ekran kanıtı, 95 testin görmediği kusuru yakaladı:** `ankle_dorsiflexion`
engel gerekçesi "gövde açısı" diyordu, oysa metriği `tibia_inclination` —
kaval kemiği, gövde DEĞİL. Testler metnin VARLIĞINI sınıyor, DOĞRULUĞUNU
sınamıyor. Ekran kanıtı bu yüzden formalite değil KAPI.

### Kapılar
engine **95/95** · app **37/37** · analyze temiz · Python 10 kapı ·
iOS sim derleme ✓ · Android debug APK ✓ · pin kapısı 9/9 (üç çapa).

### Kabuk
`com.yulalab.lissom` / **Lissom** · iOS deployment 14.0 ×3 · Podfile static
linkage (çıplak `use_frameworks!` kaldırıldı) · `build → ~/lissom_buildout`
(iCloud DIŞI) · pin `f13bdc9` TAM-40-SHA, Gravita ile birebir.

### Açık (koordinatörde)
L-187 (L-031 Dart uzay göçü) · L-193 · L-203 · L-185 · L-173 · 11 fixture ·
**cihaz günü** (gerçek kamera — VAAT EDİLMEDİ, isimli beklemede).

**MÜHÜRLENDİ.** Sonraki oturum = **design turu**.

---

## 🔒 TUR MÜHRÜ — 2026-08-06, GİYDİRME TURU

Design paneli çıktısı (`Lissom.dc.html`, `claude.ai/design 28cd0df6…`)
mevcut yüzeye uygulandı. Detay: `DEFTER.md` L-212…L-217 +
`docs/design/DESIGN-AHEAD-OF-CODE.md`.

### Kalemler

| iş | sonuç | L-ID |
|---|---|---|
| Tema/tipografi | `lissom_theme.dart` — palet/Newsreader+Nunito Sans+IBM Plex Mono/radi/gölge/hareket, tasarımdan birebir | L-212 |
| Home + Battery Summary giydirme | YAPI (Key/sıra/metin-sayısı) devralındı, icat edilmedi | L-212, L-213 |
| **Sabotaj kendi elimde patladı, kendi elimde kapandı** | çift-`Column` kırığı `flutter test`te yakalandı, aynı oturumda düzeltildi | L-213 |
| Aile dersi (Choreia) uygulandı | gerçek-metin taşma taraması, en dar cihazda (375pt) doğrulandı, AppBar → IconButton | L-214 |
| Placeholder kaydı → KAPI | `unblocked by` yoksa `exit 1`, öz-test sabotajlandı | L-215 |
| `hold_duration` bulgusu sınıflandırıldı | (a) yorum bayat — test kör değil | L-216 |
| "Kod > tasarım" kaçakları | ham metrik-id + yanlış "Profile" başlığı kapatıldı (2/3) | L-217 |

### Kapılar
engine **95/95** · app **37/37** · analyze temiz (ikisi de) ·
`wellness_lint.py` temiz · placeholder kapısı **0/0** (öz-test sabotajlı) ·
iOS sim: **402pt** (genel) + **375pt en-dar-stres** (`docs/kanit/giydirme-
tasma-stres-testi-375pt-2026-08-06.png`).

### Mühür-sonrası ek (koordinatör, Ostinato bulgusu aktardı)
**L-218 — testler 375pt'e SABİTLENDİ, kalıcı kapı.** Ölçtüm: varsayılan
`flutter_test` yüzeyi **800.0pt** — L-214'ün ekran-kanıtıyla aldığı 375pt
standardı otomatik testlerde YOKTU, yani kapı yarım kapalıydı. Artık
`test/support/narrow_surface.dart` her `testWidgets`'ı 375×812'ye sabitliyor;
37/37 test bu genişlikte de yeşil.

### Repo
`lissom/app` main — tüm tur commit'li+push'lu (`36a3d73` → `4e6a92f` →
`67f63a7`). Paylaşımlı `motion-core` ağacına DOKUNULMADI.

### Açık kalan (koordinatörde)
`hold_duration` yorum güncellemesi (L-216) · `notCompared` her-zaman-açık vs.
"why"-dokunuşu ürün kararı (L-217) · kamera-doğruluk dipnotu ÖLÇÜM bekliyor ·
`docs/design/DESIGN-AHEAD-OF-CODE.md` §1'in TAMAMI (4-tab IA, canlı-capture
UI, bireysel sonuç ekranları, pain flow — hiçbiri bu turun kapsamında değildi).

**MÜHÜRLENDİ.**

---

## 🔒 TUR MÜHRÜ — 2026-08-07, DÖRT SEKME MİMARİSİ (gece vardiyası)

### Ne yapıldı
**Tasarımın dört sekmesi kodda karşılıksızdı** (2 ekran, `BottomNavigationBar`
hiç yok — önceki turun `DESIGN-AHEAD-OF-CODE.md §1` kaydı). Bu tur boşluğu
kapattı ve sekmeleri **config'ten TÜRETTİ**, Dart'a kopyalamadı:

- `lib/app/ia.dart` — `config/ia/library.v1.json` okuyucusu. **KATI:** her
  ailenin `honestyBox`'ı zorunlu, `notMeasured` boş olamaz. Config'in
  *"bu kutu opsiyonel değil"* notunun tek uygulanabilir hâli — kutusuz bir
  aile sayfası artık ÜRETİLEMEZ.
- `lib/app/shell.dart` — sekme AYRIŞMA KAPISI: config beşinci sekme derse
  kabuk sessizce dördünü göstermez, iki kümeyi de adıyla basar (aile dersi 4:
  yapısal kaldırma yokluk iddialarını vakum-doğru yapar).
- **home** — `today` (program motoru YOK, sahte plan gösterilmez) ·
  `retest_countdown` (DAVET; **vade YOK** çünkü hiçbir config yeniden-ölçüm
  aralığı tanımlamıyor → L-226) · `continue` · `quick_start` (canlı-3
  türetimli, ölü buton yok).
- **library** — §5.4 katmanlaması: aktif aile tam kart, 5 inşa edilmemiş aile
  görsel-ayrı kompakt satırda, dürüst tek satır **envanterden türetilir**
  ("5 named · none in this build").
- **progress** — kıyas KAPALI, sebebi ekranın TEPESİNDE: `SessionRecord` ne
  ölçüm değeri ne `modelVariant`/config-sürümü/kalibrasyon-profili taşıyor,
  yani kıyasın yapılabilir olduğu **doğrulanamıyor**. Bu "eksik ekran" değil,
  tasarlanmış hâl.
- **profile** — "How measurement works" + "What Lissom doesn't do". Önceki
  turun AppBar'a icat ettiği ikon köprüsü KAPANDI.

### İki açık ihlal kapandı
- **⑱ kalıcı ölçüm-sınırı beyanı** — `disclaimers.measurementLimits` BİREBİR
  + doğruluk marjının **ölçülmediğini** söyleyen isimli cümle. Sayı
  UYDURULMADI. (`disclaimers.scoreScreen` bilerek kullanılmadı → L-227.)
- **VAAT DİLİ** — `yet` canlı koddaydı: `_blockerText`in iki gerekçesi de
  *"isn't in the measurement engine yet"* diyordu ve eski kapı yalnız
  `comingSoon`/`yakında` arıyordu. Kapı vardı, ölçtüğü şey eksikti.

### Turun en değerli bulgusu
**Ekran kanıtı ÜÇÜNCÜ kez, 71 yeşil testin görmediğini yakaladı.** Dört sekme
gerçek 375pt iPhone SE'de gezildi ve üç sızıntı çıktı: ham metrik id +
geliştirici jargonu (`"measurement bridge not declared (hold_duration)"`,
L-220 · **P0**), dahili defter atfı `(L-006)` (L-223), ve wellness süzgecinin
Dart'a hiç bakmadığı (L-221 — genişletilince İLK KOŞUŞTA bir isabet buldu).

Alt-ders: **golden ekran kanıtı bu boşluğu KAPATMIYOR.** `google_fonts` test
altında yazı tipi yükleyemediği için golden'lar Ahem bloklarıyla çiziliyor
(L-222) — yani golden YAPIYI kanıtlar, METNİ kanıtlamaz. Metin doğruluğunun
kanıtı gerçek cihazdan gelmek zorunda.

### Kapılar (tur sonu)
`flutter analyze` temiz · app **74/74** (37 → 74) · engine **95/95** ·
`wellness_lint` temiz (**500 → 1250 metin**, 24 Dart dosyası dahil) ·
tüm widget testleri 375pt'e sabit.

⚠️ **"10 Python kapısı yeşil" İDDİASI ÖLÇÜLDÜ ve YANLIŞ ÇIKTI (L-228).**
Devir promptundan devraldığım bu cümleyi ilk commit mesajıma ÖLÇMEDEN
yazdım — tam olarak *"beyana değil ağaca güven"* dersinin ihlali. Ölçüm:
argümansız koşan **7 kapı yeşil** (`config_check` · `phase_check` ·
`direction_check` · `lint_selftest` · `phase_check_selftest` ·
`noverdict_liveness` · `status_weave_check`) + `wellness_lint`. Kalanlar:
`fixture_check.py` argüman alır (kapı değil, araç) ve bu makinede **hiç
koşamıyor** — (a) fixture kütüphanesi (`~/motion-harvest/lissom/*.full.json`)
YOK, (b) paylaşımlı `motion-core/lib` rig'i kanonik `anatomical_mode()`
taşımıyor (M-F-280: ağaç main'in ~122 commit gerisinde). İkisi de bu turun
regresyonu DEĞİL, ikisi de bu turda kapatılamaz. Aynı sebeple engine
süitinde **6 test atlanıyor** (`~6`) — fixture'a bağımlı olanlar.

### Ekran kanıtı
`docs/kanit/ia-375pt-*` (golden 375×812 — **yapıyı** kanıtlar, tipografiyi
DEĞİL) · `docs/kanit/sim-375pt-*` (gerçek iPhone SE, gerçek gliflerle —
düzeltme öncesi/sonrası).

⚠️ Ölçüm düzeltmesi: iPhone SE 3. nesil **375×667pt**, 812 DEĞİL.
`narrow_surface.dart`'ın `Size(375, 812)` sabiti gerçek SE yüksekliği değil
(genişlik doğru, taşma kapısı geçerli) — adlandırma düzeltildi.

### Repo
`lissom/app` main — `4de4322` (dört sekme) → `5807b8f` (ekran kanıtı
düzeltmeleri), ikisi de origin'de. Paylaşımlı `motion-core` ağacına
DOKUNULMADI.

### Açık kalan (hepsi koordinatörde)
**L-222 yazı tipi gömme** (lisans+bağımlılık kararı — çevrimdışı açılış +
gizlilik + golden tipografisi, üçünü birden çözer) · **L-226 yeniden-ölçüm
aralığı** (artefakt yok, §5.2 hükmü bir X varsayıyor) · **L-227
`disclaimers.scoreScreen` ürünün kendi hükümleriyle çelişiyor** (yasal metin
revizyonu) · L-224 kullanılmayan `LissomMono` · L-225 erişilemez
`BatterySummaryView` (canlı-capture UI'a bağlı) · önceki turdan devam:
`notCompared` her-zaman-açık vs "why"-dokunuşu · kamera-doğruluk ÖLÇÜMÜ ·
canlı-capture UI + bireysel sonuç ekranları + pain flow.

**MÜHÜRLENDİ.**

---

## 🔒 EK TUR — 2026-08-07 04:35, KOORDİNATÖR TALEPLERİ (①②③ bayat çıktı, ⑤ ciddi)

### Koordinatörün listesi ağaca karşı ölçüldü
①②③ (L-187 ölçümü · Library+Progress · ⑱ açık ihlal) **dördü de daha önce
kapanmıştı** — `4de4322` ve önceki rapor. Bayatlık kaynağı muhtemelen benim
4,5 saat kayıtsız kalmam: koordinatör 02:16'da haklı olarak `bd33801`
görüyordu.

### ⑤ Ostinato O-040 aktarımı — ASIL İŞ (L-230, P0)
Soru: honestyBox `measured` iddialarının kabukta canlı yolu var mı?
**Ölçtüm: 3 iddiadan 2'si canlı DEĞİLDİ.**
- *"…sagittal and frontal planes (… trunk, shank)"* → `trunk_lean`/
  `tibia_inclination` köprülü değil; üstelik köprü uzayı `isotropic` olduğu
  için **"frontal plane" hiçbir metrik için doğru değildi.**
- *"Hold duration and gross balance"* → `hold_duration` faz-türevi (L-220).

Yani **dürüstlük kutusu, uygulamanın en az dürüst yüzeyiydi.**

Panzehir metin düzeltmek değil YAPI: `measured` artık kanıt taşıyan nesne
(`{claim, requires:[metrik…]}`), inşa edilmiş ailede `requires` ZORUNLU,
`AppFacts.blockerForClaim` iddiayı köprüye karşı doğruluyor, canlı olmayan
iddia silinmiyor — isimli gerekçeyle sönük gösteriliyor. Gerekçe köprünün
KENDİ metninden geliyor, ikinci kez yazılmıyor.

### `yet` temizliği (L-229) — kapının kendi körlüğü
Koordinatörün bulduğu 3 ihlal düzeltildi. Ama asıl bulgu: **kapım neden
göremedi.** ① `copy_gate` render edilmiş ağacı tarıyor, `summary_strings` →
`BatterySummaryView` ve o ERİŞİLEMEZ (L-225) — *ulaşılamayan ama yine de
gönderilen kodu ağaç-tarayan kapı göremez*; ② config `userText`
`USER_FACING_KEYS`te hiç yoktu. ③ `SummaryStrings.forbiddenSurfaceWords`
`copy_gate`in ikiziydi ve içinde `yet` YOKTU — dosya iki ihlal taşırken
kendi listesiyle yeşil yanıyordu. Sözlük silindi, tek kaynak `copy_gate`.
Kaynak-düzeyi `PROMISE` kategorisi eklendi (erişilebilirlikten bağımsız).

### L-187 ÖLÇÜMÜ (koordinatörün hükmü için)
**Dosya:** çekirdek 2 (`joint_angles.dart` · `normalization.dart`) + Lissom 1
(`metric_bridge.dart`). `vec3.dart` değişmez — `cross`/`dot`/`normalized`
zaten var, fizibilite Dart tarafında da doğrulandı.
**Metrik:** 11 engelliden **yalnız 4** (düzlem-ayrımı sınıfı). Kalan 7
ölçü-tipi sınıfı, göç onlara dokunmaz. **Test 3/12 → 7/12.**
**Asıl ödül:** `kBridgeIsReferenceEquivalent` `false` → göç onu `true`
yapabilecek TEK iş.

### Ekran kanıtı DÖRDÜNCÜ kusuru yakaladı
L-231: sönük iddia satırında çift tire (*"Not in this build — Hold time —
this test is…"*). Metin VARDI ve DOĞRUYDU, yalnız OKUNMUYORDU — okunabilirlik
`find.textContaining` ile ölçülemez.

### Kapılar
analyze temiz · app **79/79** · engine 95/95 · wellness_lint temiz
(1252 metin, 24 Dart dosyası) · 7 Python kapısı.

### Repo
`b31deb0` → `c2d5e41` → `d3951f9`, hepsi origin'de, ağaç temiz.

**MÜHÜRLENDİ.**

---

# MÜHÜR — 2026-08-12 (gündüz vardiyası, Lissom)

## Ölçülmüş durum

| ölçüm | değer |
|---|---|
| `HEAD` | `9468bbe` · ahead **0** · behind **0** · kirli **0** |
| bu oturumun commit'i | **25** (`1abd4a0` → `9468bbe`) |
| Dart süiti | **app 200/200** · **engine 109/109** |
| Python kapısı | **20/21** — 21'inci `fixture_check.py`, **BİLİNEN** (paylaşımlı rig `anatomical_mode()` taşımıyor, M-F-280); ayrıca 11 araç argüman ister, **kapı değil**, sayılmadı |
| DEFTER kaydı | **311** (tablo 256 · prose 55) · bu oturumdan **27** (`L-280`…`L-306`) |
| `Durum` KAPALI | **178** (gün içinde 173'e düştü, **düzeltildi ve çapalandı**) |

⚠️ **İKİ TURUN GİT İZİ YOK, adıyla:** `L-302` (elle okuma) ve `L-306` (`L-032`
elenmesi) — ikisinin de tüm değişikliği `DEFTER.md`de, o da **repo dışında**
(`workspace VCS` açık kalemi). ***İş yapıldı, git izi yok*** — bu bir eksiklik
değil, bilinen bir yapı sonucu.

## Bu oturumda KAPANANLAR

**Yayın engelleri:** onboarding yaş bandı motora bağlandı (L-280) · okuyucusuz
alanlar düşürüldü (L-281) · kalıcı izin reddi çıkmaz sokağı, `isRestricted`
dahil (L-283) · **ölçüm kaydediliyor** + takip sözü olguya bağlandı (L-285) ·
imzada sessiz düşüş yasaklandı, ateşlediği kanıtlı (L-286) · geçmiş yüzeyi
tazeleniyor (L-287) · gizlilik manifesti yazıldı **ve pakete bağlandı** (L-288)
· önizleme yokluğu beyanlı (L-293).

**Kapılar:** defter tazeliği (L-294) · placeholder bölmesi (L-295) ·
gezilebilirlik sözleşmesi **metne karşı 5/5** (L-298/299/300/304) · ID
çakışması + `REDDEDİLDİ` çapası (L-305).

**Ölçümler (kod yok):** yayın engelleri yeniden ölçüldü (L-284) · çekirdek turu
etki değerlendirmesi (L-292) · *"varılabilir ama boş"* (L-297) · kapalı-kayıt
envanteri (L-301/302) · `L-032` elendi (L-306).

## AÇIK KALEMLER — üç kovada

### ⓐ HAT-YERELİ (kurucu-bağımsız kalan YOK)
- *(boş — kod tarafında ölçülebilir kalem kalmadı, ölçülerek söylendi)*

### ⓑ KOORDİNATÖR / ÇEKİRDEK TURU
| kalem | nerede duruyor | sıradaki adım |
|---|---|---|
| ⑨ batarya özeti | `SessionRecord` **değer+bant taşımıyor** ⇒ özet geçmişten kurulamıyor | çekirdek turunda `SessionRecord`a alan (üçüncü kalem) |
| `surface_language_test` kapsamı | vaat **kelimesi** aranıyor, *tutulamayan söz* görülmüyor | ölçü tanımı koordinatörde — kuyruğa alındı |
| `reachability` GEVŞEK okuma | KATI **3** kanonik; GEVŞEK karşılaştırılamaz (M-F-571) | onboarding-dahil tanım çekirdek turunda |

### ⓒ KURUCU
| kalem | nerede duruyor | sıradaki adım |
|---|---|---|
| ④ app ikonu | **Flutter varsayılanı** (görsel olarak doğrulandı) — guideline reddi | marka görseli |
| ⑥ store metadata | `store/` `metadata/` `fastlane/` **yok**; ASC sürüm 1.0 `PREPARE_FOR_SUBMISSION`, **build 0** | ekran görüntüsü · açıklama · yaş derecesi · gizlilik anketi |
| ⑩ içerik | 6 aileden **5'i boş-BEYANLI** (kusur değil, içerik sorusu) | aile içeriği kararı |
| ⑪ IAP | ücretsizse engel değil | para modeli kararı |
| ⑫ sürüm hizası | pubspec `0.1.0+1` ↔ ASC `1.0` **ayrışık** | bilinçli hizalama |
| ⑬b cihaz doğrulama | kamera **hiçbir gerçek cihazda** sınanmadı (4 kalem isimli) | fiziksel telefon turu |
| ⑭ Android keystore | release **debug anahtarına düşüyor**; kapı artık **gürültülü durduruyor** | keystore kurucudan (`~/.secrets/yula/`) |
| `google_fonts` | üretimde, fetch **kapatılmamış**, paketlenmiş font **yok** → ilk açılışta indiriyor; aile **5/5** | font paketle **ya da** fetch kapat |
| **JDK** (venture-ötesi) | JDK 25 altında `.kts` **hiç derlenmiyor**; JDK 17 ile çalışıyor | makine geneli karar — LifeOS + BF'yi de etkiler |
| ⚠️ `releaseType` | ASC'de **`AFTER_APPROVAL`** — onaylanınca **otomatik yayın** | bilerek seçilsin |

## Taşınan bilinen açıklar (çözülmedi, ADIYLA taşınıyor)

- **ID çakışması 3** — `L-187`·`L-089`·`L-090` ikişer kez. Yeniden
  numaralandırma **YOK**; kapı **yeni** çakışmayı engelliyor, üçü **SAYILI
  muafiyet**, altı hücrenin altısında şerh.
- **`L-195` 8 sütunlu** — maskelemeden sonra da; **sayıma etkisi yok**, ama
  *"178 doğru, o satır için ŞANSA doğru"*.
- **`Kapanış kanıtı` BOŞ 13** — *kapalı deniyor, kanıtı yok*; sayıldı,
  **doldurulmadı**.
- **5 `REDDEDİLDİ (kapalı)` kaydı** — `L-115`·`L-168`·`L-170`·`L-171`·`L-199`.
- **`workspace/` git dışında** — iki turun izi bu yüzden yok.

**MÜHÜRLENDİ.**

---

# MÜHÜR — 2026-08-13 (A4 + A6 turu, Lissom)

## Ölçülmüş durum (kapanış ANINDA, turun başında değil)

| ölçüm | değer |
|---|---|
| `HEAD` | `94dcd80` · ahead **0** · behind **0** · kirli **0** |
| bu oturumun commit'i | **3** (`5bf3e26` · `1408eaf` · `94dcd80`) |
| Dart süiti | **app 205/205** (~6 atlandı) · **engine 109/109** |
| Python kapısı | **20/21** — 21'inci `fixture_check.py`, **BİLİNEN** (M-F-280) |
| `defter_freshness` öz-testi | **4/4 → 9/9**, ve artık **varsayılanda koşuyor** |
| DEFTER kaydı | **312** (bu turdan **3**: `L-310`·`L-311`·`L-312`) + geri yazılan `L-208` |

## C DURMA KOŞULU — bu tur `⛔ → ✅` = **2**

| kalem | önce | sonra | kanıt |
|---|---|---|---|
| **A4** çıkmaz sokak dağılımı | ⛔ | ✅ | `test/deadend_taxonomy_test.dart` 3/3 + `docs/A4-CIKMAZ-SOKAK-SAYIMI.md` (ankraj, sabotajla ötürtüldü) |
| **A6** defter tazeliği | ⛔ (tek yön) | ✅ | `tools/defter_freshness.py` iki yön + öz-test 9/9 |

Sayaç sıfırlandı; hat **durmadı**.

## Bu turun en pahalı üç dersi

1. **Ön-girdi, yazıldığı andaki taksonomi kadar geçerlidir.** Devir notu 00:37'de
   yazıldı, `E` sınıfı ölçüte 00:44'te eklendi — 9 engelli test **sınıfsız**
   kalmıştı.
2. **Bir kapı en çok bakmadığı dizgede kördür, ve orada kör olduğunu kendi
   yeşili söylemez.** A6'nın ters yönünü kurarken **birinci yönün** deliği
   göründü: `L-208` iki commit'in iddia ettiği, defterde **hiç olmayan** kayıt.
3. **Bir kapıyı genişletmek, onun kendi varsayımlarını yeniden sınamayı
   gerektirir.** Üç tuzak da bu sınıftandı (aile kaydına sızma · kendi
   commit'ini kilitleme · sentetik girdinin ölçtüğü kümeye sızması).

## A TABLOSU — devralınan hâl güncellendi

`A1`✅ `A2`✅ `A3`✅ **`A4`✅** `A5`✅*(şerh daraldı)* **`A6`✅** `A7`✅ `A8`✅
`A9`✅ `A11`✅ · **`A10`→B8 ve `A12` KURUCUDA** (M-F-77: tasarım yönü · cihaz).

⇒ **Hattın kapatabileceği A kalemi KALMADI.** Kalan iki kalem yetki gereği
kurucuda; hattın kuyruğu artık ⓑ (çekirdek turu) ve ⓒ (kurucu) kovalarında.

## AÇIK — koordinatöre giden (ölçü tanımı, hat kapatamaz)

- **A4 kapsam sınırı:** sayımın paydası *"içerik vaat eden hedefler"*. Kalan beş
  yüzey (`Home`·`Progress`·`Profile`·`WhatLissomDoesntDo`·`LiveCapture`)
  **`0` değil `bilinmiyor`**. *"Terminal beyan ekranı çıkmaz sokak mıdır?"*
- **A5 şerhi daraldı, kapanmadı:** 5 kapının öz-testi hâlâ yalnız
  `--self-test` ile ateşleniyor (`direction_check` · `noverdict_liveness` ·
  `reachability_candidates` · `status_weave_check` ·
  `validate_placeholder_surface`).
- **Aile adayı kural:** *bir kapıyı genişletmek, eski gerekçelerin geçerlilik
  alanını sessizce aşar — genişleyen kapı kendi varsayımlarını yeniden sınamalı.*

## TAŞINAN (bu tur dokunulmadı)

`invert` korumasız (`metric_coverage_test.dart` ~L110) · köprülenemeyen 11
`measureKind` · ID çakışması **3** (SAYILI muafiyet) · YÖN-2 taşınan taban **6**
(`L-053`·`L-159`·`L-213`·`L-215`·`L-216`·`L-218`) · `workspace/` git dışında.

**MÜHÜRLENDİ.**

---

# TUR — L-313 · 2026-08-13 (A12 engelinin kimliği)

**Kapanan:** A12'nin **engelinin kimliği** (kalem değil). `⛔→✅` = **0**;
C sayacı **1**. *(`bilinmiyor→ölçüldü` C'ye girmez.)*

**Bulgu:** *"provizyon profili yok ⇒ imza ⇒ kurucuda"* iddiası **yanlış
dizinden** kurulmuştu. Xcode 26: `~/Library/Developer/Xcode/UserData/…`;
okunan yer eski `~/Library/MobileDevice/…`. Gerçek **9** iOS profili, joker
`T5HZGYBWK8.*` bundle'ı **kapsıyor**, ve **imzalı cihaz derlemesi GEÇTİ**
(`BUILD SUCCEEDED`, `codesign Identifier=com.yulalab.lissom`, kirlilik 0).
`-allowProvisioningUpdates` **kullanılmadı** ⇒ hesap mutasyonu yok.

**Gerçek engel:** joker profil bağlı telefonu içermiyor, **ama telefon takıma
kayıtlı** (9 profilin 4'ünde) ⇒ portal kaydı gerekmiyor, yalnız **tazeleme**.
Kurucudan istenen: **iki onay** (tazeleme · kişisel telefona kurulum).

**Sınıf:** beş Motion app'inin **beşi de** `T5HZGYBWK8` ⇒ joker beşini kapsar.
Aynı yanlış engel diğer hatlarda da olabilir — koordinatöre bildirildi.

**Kurulan:** `app/tools/a12_device_preflight.sh` (öz-test **2/2**; koşum
**7 geçen · 0 düşen · 3 onay**, `exit 2`) + `app/docs/A12-KOSUM-HATTI.md`.
⛔ `all_gates.py`e **eklenmedi** — onay-bekler döndüğü için tam-cümleyi
kalıcı kırmızıya çevirirdi.

**Kapılar (kapanışta ölçüldü):** app **205/205** · engine **109/109** ·
python **20/21** (`fixture_check.py` — M-F-280 BİLİNEN).

## 🔴 KENDİ KUSURLARIM — adıyla

1. **Hatayı yeniden ürettim:** açtığım envanter turu da eski dizine baktı,
   *"1 profil"* dedi. Açan şey envanter değil **derlemeyi koşmaktı.**
   ⇒ *teşhis bağışıklık değildir.*
2. **10 ≠ 9:** ilk raporumda `ls | wc -l` = 10 yazdım; `.mobileprovision`
   süzgeci **9**. Fark bir macOS `.provisionprofile` — *`ls` GİRDİ sayar.*
3. **`5` ↔ `6` ayrışması — BENİM hatam, promptun değil.** Koordinatöre
   *"kalan yüzey 6, prompt 5 diyor"* yazdım. Uzlaşma: **7 aday − FamilyPage
   (ölçüldü) − LibraryScreen (aile kartlarını GÖRÜNÜR taşıyor) = 5**; `6`
   LibraryScreen'i de sayan birim. **İkisi de savunulabilir, birim farklı.**
   ⇒ *bir sayı, PENCERESİ yazılmadan başka bir sayıyla karşılaştırılamaz* —
   ve bu kez kuralı **ben** çiğnedim. Düzeltme koordinatöre gidecek.

## TAŞINAN (bu tur dokunulmadı)

`invert` korumasız (`metric_coverage_test.dart` ~L110) — **sıradaki iş** ·
A3/A4 paydası (5 yüzey, birim yukarıda) · köprülenemeyen 11 `measureKind` ·
A5 şerhi (5 kapı öz-testi yalnız `--self-test`) · ID çakışması **3**.

⚠️ **`invert` için ölçülmüş sınır:** ROM konvansiyonu davranışsal olarak
**yalnız `shoulder_flexion_right`** için çivili (`real_replay_test.dart`
L33-64). Kalan **7** binding konvansiyonu yapıca miras alıyor, **tek tek
ölçülmedi** — mühür bunu *kapatmaz*, yanlış bir `true`yu **yakalar**.

---

# TUR — L-314 · 2026-08-13 (`invert` sessiz-geçişi)

**Kapanan:** ⓐ kovasının `invert` açığı. `⛔→✅` = **0** · C sayacı **2**
⇒ ölçüt gereği **koordinatöre DURMA bildirimi yapıldı.**

**Kanıt:** `kSealedBindingInvert` + iki mühür arası kayma denetimi + 3 sabotaj
testi · engine **114/114** (taban 109) · commit hook'u yeşil.

**İki gerçek sabotaj — ikincisi kanıt oldu:**
`shoulder_flexion_right` (247) ⇒ **3 kapı** düştü (İZOLE DEĞİL: davranışsal
çapası olan tek binding) · `hip_flexion_left` (279) ⇒ **tam 1** kapı, o da
benimki. *Ötme kanıt değil, ötme SEBEBİ kanıt* (2.11) — kendi sabotajımda.

**Mührün kapsamı DAR, ölçülmüş:** ROM konvansiyonu davranışsal olarak yalnız
`shoulder_flexion_right` için çivili. Payda **8** · davranışsal çapa **1**.
Mühür kalan 7'yi **doğrulamaz**, sessizce **değişmelerini** yakalar.

## 🔴 ARANMAYAN YERDEN — kapının kendi başlığı bayatmış

Başlık *"öz-test grubu **ÜÇ** sabotaj vakasını kırmızı yaptırıyor"* diyordu;
ölçüm **11** ⇒ sayı **benim eklememden ÖNCE de 8**'di. Cümle **zaten
yanlıştı**, hiçbir kapı ötmedi. Çare sayı düzeltmek değil (11 de bayatlardı):
cümle artık **YAPI** iddia ediyor. Sayıyı çapalayan test **kurulmadı** —
*kapının kapısı* olurdu.
📌 **Aile adayı:** ***BİR BELGENİN SAYISINI YAZMAK, ONU DENETLEMEK DEĞİLDİR.***

## MÜHÜR (kapanışta ölçüldü, turun başında değil)

`HEAD` **`42296bc`** · ağaç **temiz** · app **205/205** · engine **114/114** ·
python **20/21** (`fixture_check.py` — M-F-280 **BİLİNEN**).

## SIRADAKİ — tanım ZATEN YAZILDI (Goodhart)

**A3/A4 paydası:** kalan **5** yüzey (`Home`·`Progress`·`Profile`·
`WhatLissomDoesntDo`·`LiveCapture`). Tanım ölçümden **önce** yazıldı:
`scratch` → `A3-TANIM-ONCE.md` (içerik ≠ çerçeve · üç kova · iki durum ·
üç pozitif kontrol · **beklenti yazılı: boş-sessiz 0**).

⚠️ **İlk sabotaj adayım ZAYIFLADI:** `LibraryScreen`in
*"Planned, not in this build (0)"* başlığında `NamedGapCard` yok **ama**
hemen altında gerekçe paragrafı VAR ⇒ **boş-BEYANLI**, kusur değil.
*Bir hipotez, ölçülmeden önce kod okunarak da düşebilir.*

**TAŞINAN:** köprülenemeyen 11 `measureKind` · A5 şerhi (5 kapı öz-testi
yalnız `--self-test`) · ID çakışması **3** (SAYILI muafiyet) ·
`A12` üç onay kapısı (kurucuda).

---

# 🌙 GECE VARDİYASI — 2026-08-14→15

## MÜHÜR (kapanışta ölçüldü)

Giriş **`42296bc`** → çıkış **`47e138b`** (hattın son commit'i) · **16 commit**
· `main` push'lu · ahead **0** · kirli **0**.
⚠️ Depo `HEAD`i **`aa2075c`** — *"DEFTER + workspace versiyon kontrolüne alındı"*
(kayıt zinciri göçü, **başka bir el**). Yani `workspace/` artık
`ventures/lissom/app/workspace/` altında ve **git izliyor**; eski yol YOK.

Kapılar: app **236/236** (taban 205, **+31**) · engine **114/114** ·
python **20/21** (`fixture_check.py` = M-F-280 **BİLİNEN**) · `all_gates.py` exit **0**.
DEFTER: bu oturumdan **16 kayıt** (`L-315`…`L-330`).

## A TABLOSU — tek açık kalem A12, ve engeli FİZİKSEL

`A12` **fiilen denendi**: `-allowProvisioningUpdates` app'e özel profil ÜRETTİ
ve cihazı **içeriyor** (ölçüldü). Kurulum `0xe8008012` → sonra **`error 1011`**
⇒ telefon **`unavailable`**. **Teknik engel YOK.**

## ÖNCEKİ TURUN "SIRADAKİ"si — KAPANDI

A3 paydası **6 → 12 yüzey** genişletildi (`L-315`). Tanım ölçümden ÖNCE, **ayrı
commit'te** (`a7fc901`) — Goodhart kanıtı beyan değil **git sırası**.
BUGÜN penceresi: `ⓐ2 · ⓑ5 · ⓒ0` ⇒ payda **7**, sessiz oran **%0,0**.
YARIN penceresi **3 başlıklı boşluk** buldu, üçü kapandı.

## TAŞINAN

⛔ **Deneme-düzeyi kayıt** — koordinatör hükmü bekliyor (a) çekirdek şeması /
(b) Lissom yan defteri. Hazırlık: `docs/M-TALEBI-deneme-duzeyi-kayit.md`.
⛔ `A12` cihaz koşusu — telefon uyanınca **tek komut**.
⛔ H-15 tam uygulanamadı: `lissom-hatti` sim'i var ama **MCP gezinme erişimi
kurucu onayı** istiyor.


## 2026-09-26 — ilk tam Hatha öğretim yolu (yerel WIP)

60 TR/EN ders / 10 modül / 240 teknik adım; Home, Library ve Progress
girişleri, önerilen sıra ve öz beyanlı çalışma kaydı eklendi. Hesap/sürüm
ayrımı, atomik-seri yazım ve silme sonrası eski deponun yeniden yazamaması
sınandı. Mevcut ölçüm bataryası ve kamera skor kapıları açılmadı.

Tam Flutter 314 PASS / 6 mevcut SKIP; analiz temiz; mağaza metni 10 PASS.
Son kurs iPhone iOS 27 simülatörü ve Android API 37 emülatöründe gerçek
yerel kayıt / ekran yeniden açılış / silme readback testini geçti. iPhone
dört kurs görüntüsü alındı; Android SDK görüntü yakalama takılması ayrı
kaydedildi. Fiziksel kişi/telefon modeli, AI medya, imzalı son paket ve
mağaza kabulü hâlâ açık. Commit/push/deploy yapılmadı.

Kanıt: `docs/research/HATHA-COURSE-EVIDENCE-2026-09-26.md` ve kapsam matrisi.
Önceden var olan iş akışı WIP'i korundu; ortak motion-core değiştirilmedi.
## 2026-10-02 — yayın haftası kaynak devamı

Thread `01a0f939-e1fa-7c13-bd5b-3aa1b931f610`, host local; app baseline
`main@7f2e8f27669d83598800b5cab89bbb5a0c0e6b81`, güncel uncommitted WIP.
READY source lease altında çalışıldı. Mevcut SDK Flutter3.47.5/Dart3.13.4
offline bootstrap tamamlandı; RW-SDK-004 released, descriptor/lock pinleri
`f2ea161c` ve dosya hashleri değişmedi. Yeni commit/push/submit/deploy yok.

İlk dalga: onboarding diske yazma/okuma hata yolu TR/EN yeniden denenebilir;
onboarding/attempt/session yazıcıları hesap silme kuyruğuna katılır, emekli
hesabın dizinini yeniden yaratamaz; concurrent session append korunur.
h03/h04 hazırlığı kilitli gelecekteki h05 dersini varsaymaz. Medya kapanışı
tek controller retirement ve token-sahipli native slot bırakma kullanır.

Gerçek RED kayıtları sonrası recovery13/13, affected74/74 ve media23/23 PASS.
İlk dalga full app383/383 PASS, analyze no issues; bağımsız storage+media
R2 blocker yok ve exact SHA mühürleri eşlendi. Bunlar yerel kaynak kanıtıdır.

İkinci dalga camera adapter delayed permission/model/native-start retirement
ve live capture actual background invalidation kaynak düzeyinde tamamlandı. Root ekranı
paused/hidden/detached için kapatır, OS permission `inactive` durumunu korur;
yarım denemenin geç finish/kare kaydı olmaz, completed result korunur.
Peer pending-save retry yarışını buldu; meaningful RED2 sonrası minimum
retry guard ile final focused24/24 PASS, bağımsız R2 ACCEPTED. Camera adapter
pre-start disposal'ın yeni kaynağı stop etmesi iki-source RED ile düzeltildi;
final19/19 ve bağımsız19/19 PASS. Native issued-start gerçek owner kabulü değildir.

İlk sürüm TR/EN onboarding kamera izni istemiyor; ertelenmiş izin akışı testte
açık seçiliyor. h02 doğal nefes içeriği sınırlar metnine doğru yansıtıldı;
listing tarihsel snapshot korunup current course SHA eklendi, cihaz recipe
ilk sürüm kapsamına bağlandı. İlgili49/49 ve son metadata/test addendum11/11
PASS. Canlı privacy/support anonim GET HTTP200; gizlilik sayfası hesap ve yerel
veri kapsamını açıklıyor. Sağlayıcı mağaza alanları yüklenmedi.

Android signing exacttrue debug opt-in ve gerçek app release taskGraph guard
kullanır. Bağımsız source/API R2 ACCEPTED; Python14/14, Dart3/3 ve RW-GRADLE-001
izole pluginsiz Groovy host API fixture22/22 PASS. Lease RELEASE edildi.
Android Kotlin/AGP/configuration-cache ve gerçek imzalı binary kabulü açık.

Son kaynak dalgası full app **408/408 PASS**, engine **114/114 PASS**, analyze
**no issues**. `evidence/app-final-green-verified.log`, `engine-final-green.log`,
`analyze-final.log`. İlk final app407+1 ara sonucu eski deferred kamera testinin
closed-default varsayımı nedeniyleydi; test scope'u düzeltilip full yeniden
ölçüldü, ara log korundu. Suite sayıları örtüşür, birbirine eklenmez.

Course generator21/21, projection8/8 ve --check60/480/480/HOLD8 PASS;
course1.0.1 SHA `be597ebcb4d9a3ae05410e2b33752b061bdc4ad1aea49896ae978733b7405a3c`
değişmedi. h08 üç toplam/üç çift TR-EN farkı için bounded generator stage
hazır: base21+new25=46/46, bağımsız46/46 ve same temp-alias positive1/1
PASS. Yalnız scratch output; exact overlay/parent/hash/tek h08.TR alanı;
default live --check be597 aynı. Mac temp path alias fikstürü gerçek yola
alındı; production symlink/no-follow ret korunur. Canlı ortak cutover yapılmadı;
h30 sekiz HOLD ve frozen19/no-retry sınırı korunur. Gerçek config
battery1.13.0 source-capable3/12; release camera/payments gate kapalı.

Kalan: reviewed immutable Core adoption, h08 ortak cutover, native/device
lease ve gerçek kapanış/ses, signed paket/privacy readback, canlı mail/auth/
deletion-provider ve mağaza readback; gerçek Flow/model/kurucu fiziksel kabul
en son. `scratch/2026-10-01-release-week-dispatch/lanes/lissom/` STATUS,
peer raporları/evidence ve uygulanabilir RELEASE-CARDS kanonik bu-tur kanıtı.
Vault/holding/shared kayıtların tek yazarı merkez; deltalara mesaj gönderildi.

Flow current60/480 pointer/hash teslim indeksi ownlane'de hazır. Ortak
v2k delivery validator manifest/file bytes kontrolüne current source-pin/HOLD
gate'ini bağlamıyor; iki bağımsız salt okunur source readback doğruladı.
Review trust yoksa kapalı, releaseEligible/visible false/progress0 ve app
runtime h30 HOLD ret korunur. Bu actual media acceptance/bypass değil; merkez
ayrı current-only joined guard planı istedi. Frozen shared files değiştirilmez;
prototip için ortak delivery lease beklenir. Yeni gerçek medya/approval yok.
