# Lissom — G1 / V0 Kapı Raporu

**Tarih:** 2026-07-26 · **Koşum:** gece oturumu (otonom mod) · **Protokol:** `G1-V0-KAPI-PROTOKOLU.md` rev.3
**Hüküm: G1-a ŞARTLI GEÇTİ · G1-b ÖLÇÜLMEDİ (kurucu fixture çekimi bekliyor)**

> Eşikler bu ölçümden ÖNCE yazıldı ve koşum sırasında değiştirilmedi. Betik eşikleri protokolden okur, üretmez.

---

## 1. Ölçüm ortamı

| Ne | Değer |
|---|---|
| Ölçüm hattı | `motion-core/lib/tools/fixture_pipeline` (Python 3.12, mediapipe 0.10.35, numpy 2.5.1, opencv 5.0.0) |
| Metrik config | `lissom-metrics.v1.json` v1.0.0 — 16 metrik (10 tanım + 6 ayna) |
| Girdi | Sentetik iskelet, 41 poz noktası × 6 poz alanı taraması |
| Model | G1-a'da model KULLANILMAZ (matematik testi); G1-b'de `pose_landmarker_heavy/float16/1` |
| Makine | Apple M4, macOS 26.5 |

## 2. G1-a — Sayısal doğruluk kapısı

| # | Kriter | Eşik | Ölçüm | Sonuç |
|---|---|---|---|---|
| A1 | Gürültüsüz maksimum açı hatası | ≤ 0.5° | **0.000°** | ✅ |
| A2 | σ=0.005 gürültüde medyan hata | ≤ 2.0° | **0.854°** (p95 3.197°, n=2460) | ✅ |
| A3 | σ=0.010 gürültüde medyan hata | ≤ 5.0° | **1.705°** (p95 6.364°, n=2460) | ✅ |
| A4 | Vücut ölçeği sapması (0.75× / 1.30×) | ≤ 1.0° | **0.000°** | ✅ |
| A5 | Yaw duyarlılığı | eşiksiz | aşağıdaki tablo | ℹ️ |
| A6 | Güven kapısı sızıntısı | = 0 | **0 / 110 kontrol** | ✅ |
| A9 | Ölü metrik (sabit değer üreten) | = 0 | **0 / 16** | ✅ |
| A7 | State-machine doğru dizilim | 10/10 | **ÖLÇÜLMEDİ** | ⏳ |
| A8 | State-machine geçersizlik kodları | ≥29/30 | **ÖLÇÜLMEDİ** | ⏳ |

**Hüküm:** protokol §2.3'e göre A1-A4 + A6 + A9 tam → **ŞARTLI GEÇTİ**. A7/A8 state-machine yazılmadığı için ölçülemedi (L-014); G4'te kapatılacak. Ham çıktı: `g1a-rapor.json`.

### A5 — Yaw (kamera hizası) duyarlılığı: metrik bazında maksimum sapma

Eşiksiz ölçüm; amacı kalibrasyon sihirbazının toleransını belirlemek.

| Metrik | ±5° | ±10° | ±15° | ±30° |
|---|---|---|---|---|
| `trunk_lateral_tilt` | 2.88° | **5.73°** | **8.50°** | 16.10° |
| `hip_flexion_right` | 2.35° | 4.67° | **6.94°** | 13.24° |
| `trunk_lean` | 1.82° | 3.62° | **5.38°** | 10.31° |
| `hip_flexion_left` | 1.29° | 2.56° | 3.81° | 7.34° |
| `knee_flexion_*` | 0.16° | 0.66° | 1.48° | 6.04° |
| `shoulder_flexion_*` | 0.53° | 1.06° | 1.57° | 2.98° |
| `tibia_inclination_*` | 0.05° | 0.22° | 0.49° | 1.94° |
| `elbow_extension_*`, `reach_depth`, `heel_rise_*` | 0.00° | 0.00° | 0.00° | 0.00° |

**Okuma:** gövde metrikleri kamera hizasına belirgin duyarlı, sagittal eklem açıları dayanıklı. ±10°'de `trunk_lateral_tilt` tek başına B4 eşiğini (≤5°) aşıyor.

**Karar (L-013):** kalibrasyon sihirbazı omuz-kalça hattının kameraya göre yaw sapmasını **≤10° dayatır, ≤5° hedefler**; sapma 10°'yi aşarsa gövde metrikleri ölçülmez (test geçersiz), sagittal eklem metrikleri ölçülmeye devam edebilir.

> **rev.2 (2026-07-26, aynı gün):** kapı kapsamı L-016 gereği genişletildi (beklenen-değer formülü olmayan metrikler artık A4/A5/A9'da) ve bu genişletme **iki hata daha** buldu. Güncel sayılar: A1 **0,000°** · A2 **0,467°** · A3 **0,931°** (n=3910) · A4 **0,040°** · A6 **0/120** · A9 **0/18 ölü**. Hüküm değişmedi: ŞARTLI GEÇTİ. Kurucu retrospektif onayı alındı (M-F-01).

## 3. Kapının yakaladığı beş gerçek hata

Kapı üç kez kırmızı yandı ve üçünde de kod/tanım hatası buldu. Bu, kapının çalıştığının kanıtı.

| # | Bulgu | Ölçülen hata | Düzeltme sonrası |
|---|---|---|---|
| **L-009** | Ham 3D eklem açısı, omuz/kalça genişlik farkı yüzünden ROM uçlarında sistematik sapıyor | 5.71° | **0.00°** (düzlem izdüşümü zorunlu kılındı) |
| **L-010** | Gövde açısı tek taraflı landmark çiftiyle ölçülemez; frontal düzlemde sahte yana-eğim | 11.31° | **0.00°** (türetilmiş orta-hat landmark'ları) |
| **L-011** | `angle_vertical`+`transverse` matematiksel olarak ölü: her zaman tam 90° | sabit 90° | metrik yeniden tanımlandı + kombinasyon yasaklandı + A9 kriteri eklendi |
| **L-028** | `heel_rise` topuk kalkmasını değil **ayak uzunluğunu** ölçüyordu; squat koruması hiç ateşlenmezdi. İkinci katman: üreteçte topuk-kalkma olgusu yoktu, metrik sınanmıyordu bile | sabit (hiç değişmiyor) | `height_diff_norm` + üretece `heel_lift` parametresi → A1 0,000° |
| **L-029** | Normalizasyon referansı poza duyarlı: gövde yana eğilince `torso_length` kayıyor, ona bölünen **tüm** metrikler onunla kayıyor | %1,63 (40° yan eğim) | orta-hattan orta-hatta ölçüm → tüm pozlarda %0,00 |

**L-029 ayrıca bir uyum bulgusu:** kanonik Dart çekirdeği bu referansı zaten doğru tanımlamış (`shoulderMid − hipMid`); Python hattı farklı bir literatür tanımını kullanıyordu. Differential test çalıştırılsaydı uyuşmazlık verirdi. Kalan uyumsuzluk L-031'de: Dart image düzleminde, Python 3D world uzayında ölçüyor.

Dördüncü bir olay kapı hatası DEĞİLDİ: ilk koşuda `hip_flexion` 60° sapma gösterdi, incelendi, **ölçümün doğru testin yanlış** olduğu görüldü (kalça açısı tanım gereği gövde eğimini içerir). Beklenti formülü düzeltildi; ürün tarafı sonucu `hip_flexion` ile `trunk_lean`'in bağımsız olmadığı — hip hinge testindeki lumbo-pelvik ritim tam olarak bu oran.

## 4. G1-b — Görüntü güvenilirlik kapısı: ÖLÇÜLMEDİ

**Neden:** gerçek video fixture'ı yok. Kurucu çekimi gerekiyor — `FIXTURE-CEKIM-LISTESI.md`.

**Hazır olan:** çıkarma hattı (`extract_landmarks.py`) uçtan uca koştu ve doğrulandı:
- 3 test videosu işlendi; dosya adı sözleşmesine uymayan klip reddedildi, diğerleri etkilenmedi.
- Üretilen JSON şemaya uygun: `schemaVersion`, `recordingMeta` (parse edilmiş koşullar), `modelVersion`, `modelSha256`, kare dizisi.
- `invalid-outofframe` etiketi otomatik tanındı (`intentionally_invalid: true`).
- MediaPipe GPU (Metal) hattı çalışıyor.
- ⚠️ Test videolarında insan yok (ffmpeg test deseni) → `detected: 0/60`. Bu **beklenen**; hattın mekaniği doğrulandı, MediaPipe'ın gerçek insandaki performansı doğrulanmadı.

**Kurucu çekimi geldiğinde tek komut yeterli:**
```bash
cd ventures/motion-core/lib/tools/fixture_pipeline && ./.venv/bin/python extract_landmarks.py --input ~/lissom-fixtures/raw --output ~/lissom-fixtures/landmarks
```

## 5. Bu raporun sınırları (dürüstlük notu)

- **G1-a, MediaPipe hakkında hiçbir şey söylemez.** Sentetik iskelet mükemmel landmark verir; gerçek dünyada landmark'ın kendisi hatalıdır. A1=0.000° "ölçümümüz mükemmel" demek DEĞİL, "matematiğimizde hata yok" demektir.
- **A2/A3 gürültü modeli bir varsayımdır:** izotropik Gauss gürültüsü varsayıldı. Gerçek MediaPipe hatası izotropik değil (derinlik ekseninde 2-3× büyük, `research/01`) ve kareler arası bağımsız değil. Gerçek dayanıklılık G1-b'de ölçülür.
- **A4 vücut-ölçeği testi, orantılı büyütmedir** — gerçek vücut çeşitliliği (farklı uzuv oranları, kilo, cinsiyet) bundan fazlasıdır (L-015).
- **4 metrik doğruluk garantisi olmadan taşınıyor** (L-016): `heel_rise_*`, `reach_depth`, `shoulder_line_foreshortening` yalnız A9 korumasında.
- Hiçbir "measures your mobility" iddiası bu kapıdan doğmaz; o iddia L-005'e bağlı.
