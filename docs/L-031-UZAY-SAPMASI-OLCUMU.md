# L-031 ÖLÇÜMÜ — Dart canlı yol ↔ normatif Python yorumlayıcısı

**Tarih:** 2026-08-04 · **Durum:** ölçüldü, karar koordinatörde · **Etki:** Lissom canlı-tur ekranı, G4 differential sözleşmesi

## Neden bu belge var

L-031 defterde şöyle kayıtlıydı: *"Python hattı ile Dart çekirdeği farklı
uzaylarda çalışıyor … uzay farkı sistematik sapma **üretebilir**."* Bir
olasılık olarak, P2 olarak, iki aydır açık. Bu tur onu **sayıya çevirdi.**

Sapma üretiyor, ve büyük.

## Yöntem

Aynı fixture'ın **aynı karelerinde** iki hat yan yana koşturuldu — eşleştirilmiş
(paired) fark, dağılım kıyası değil. Üç hesap:

| ad | ne | not |
|---|---|---|
| **HAM** | Dart, ham anizotropik `lm` | J-028 düzeltmesi ÖNCESİ davranış |
| **İZO** | Dart, `toIsotropic` sonrası | bu turda düzeltildi, şimdiki kod |
| **REF** | Python, `world` 3D + config `frameRef`/`plane` (`anatomical=True`) | **NORMATİF** |

REF'in normatif olması çekirdeğin kendi doktrini: *"the native ports are
validated by replaying shared fixtures and comparing against this
implementation's output. When the two disagree, this package is right by
definition."* Karşılaştırma bilerek **Python tarafında** yazıldı — hakemi
taraflardan biri yapmamak için.

**Kapsam:** 3 fixture × 8 köprülü metrik × **44.022 kare** (10.730 + 25.514 +
7.778). Üçü de 1920×1080 (aspect 1,778).

**Yeniden üretim:**
```
cd packages/lissom_engine && dart run tool/dump_angles.dart /tmp/dart.json
python3 tools/l031_space_divergence.py /tmp/dart.json
```

### Taklit kontrolü (pozitif kontrol)

Ölçümün ilk turunda Dart çıktısı, `lm` x,y üzerinde elle yazılmış ham 2D açıyla
kıyaslandı: **medAbs = p95 = maxAbs = 0,00°**, 44.022 karede. Yani Dart canlı
yolun ne yaptığı tahmin edilmedi, **çivilendi**: ham görüntü-normalize
koordinatlarda düz 2D açı, `frameRef` uygulanmadan.

## Bulgu 1 — J-028 ihlali (Lissom tarafı, DÜZELTİLDİ)

Çekirdek sözleşmeyi açıkça yazıyor: *"A consumer that has this must go through
`frameSize`/`toIsotropic` before measuring."* Gerekçe M-F-30 / J-028: MediaPipe
`x`'i genişliğe, `y`'yi yüksekliğe bölüyor; ham normalize uzay **anizotropik**
ve orada ölçülen her açı en-boy oranıyla **büküyor**. Aile ölçümü: eklem
açılarının %42'si >5° kayıyor, en kötü tek eklem 62°.

`CoreMetricReader` bu çağrıyı **yapmıyordu.** Düzeltildi; `frameSize` artık
tür düzeyinde ZORUNLU (opsiyonel bırakılsa aynı sessiz bükülme geri gelirdi —
çekirdeğin tercih ettiği yol da bu). 34/34 hasat fixture'ı `resolution`
taşıyor, yani fail-closed olmak KARŞILANABİLİYOR; uydurma en-boy oranı
konulmadı (yanlış oran, düzeltmemekten kötüdür çünkü "düzeltildi" görünür).

**Düzeltmenin ölçülmüş etkisi:**

| | medyan \|sapma\| | p95 \|sapma\| |
|---|---|---|
| HAM ↔ REF | 14,83° | 45,91° |
| İZO ↔ REF | **11,29°** | **37,47°** |
| değişim | **−23,9%** | **−18,4%** |

> ⚠️ **SAYI DÜZELTMESİ (L-197, 2026-08-04).** Bu tablonun ilk sürümünde
> 18,20° → 14,30° (−21,4%) ve 67,55° → 60,64° (−10,2%) yazıyordu. **Sayılar
> ŞİŞKİNDİ ve kusur bendeydi:** karşılaştırma betiği `evaluate(...).value`'yu
> `valid` bayrağını OKUMADAN topluyordu. Rig `mask_invalid` varsayılanından
> önce geçersiz ölçümler `value` alanında HAM/ÇÖP sayı taşıyordu (yalnız
> `valid=False` yan-kanal bayrağıyla işaretli), dolayısıyla REF serisi
> geçersiz ölçümlerle kirlenmişti. `valid` otorite yapıldı; yukarıdaki
> sayılar temiz seriden. **Hüküm DEĞİŞMEDİ** (L-031 açık ve büyük), ama
> J-028 düzeltmesinin kazancı aslında rapor ettiğimden DAHA İYİ çıktı.

24 hücrenin (3 fixture × 8 metrik) 23'ünde medyan iyileşti veya sabit kaldı;
**1 hücrede kötüleşti** (`knee_flexion_left` / `-wwRNGArTI0`: 15,94° → 17,42°).
Bu beklenen bir davranış, gizlenmiyor: M-O-08 zaten ölçmüş — izotropik
düzeltme dönük öznede *medyanı iyileştirirken en kötü durumu kötüleştirebiliyor*
(aile ölçümü 41%→27% medyan, 62%→74% en kötü).

## Bulgu 2 — L-031'in gerçek kapsamı (AÇIK, koordinatör kararı)

Düzeltmeden **sonra kalan** sapma L-031'in kendisidir:

**medyan 11,29° · p95 37,47° · tepe 124,62°**

En kötü hücreler (İZO↔REF, p95):

| fixture | metrik | medyan | p95 |
|---|---|---|---|
| 0Ttn3z_rVBk | `elbow_extension_right` | 21,32° | **64,06°** |
| -wwRNGArTI0 | `shoulder_flexion_right` | 19,35° | **59,81°** |
| -wwRNGArTI0 | `shoulder_flexion_left` | 16,09° | 58,71° |
| X2u_vGL0qJU | `elbow_extension_right` | 11,08° | 55,86° |
| 0Ttn3z_rVBk | `hip_flexion_right` | 8,01° | 53,67° |

Bu **yuvarlama farkı değil, yön farkı.** `overhead_reach`'in girişim kapısı
140°'de; skorlama bantları derece cinsinden. 11° medyan kayma + 37° p95, hem
kapı geçişini hem bant atamasını değiştirir. (Temiz seride en kötü hücreler
`elbow_extension` ve `shoulder_flexion`'a kaydı — kirli seride tepeyi tutan
`knee`/`hip` hücreleri şişkinliğin kendisiydi.)

### Neden kapanmıyor: sebep zaten kayıtlı

`docs/KARAR-BRIFI-kanonik-uzay.md` (2026-07-29) üç seçenek sundu ve **C**
önerildi: düzlemler landmark'tan TÜRETİLİR, kamera yönelimine bağımsız.
Seçenek **B** ("projeksiyon görüntü düzlemine çevrilir") için bedel şöyle
yazılmıştı: *"Dart tarafıyla hizalanır ama 3D bilgisi atılır; perspektif
hatası kalıcılaşır."*

**Dart hattı bugün fiilen B'de duruyor** — seçilmeyen seçenekte.

Seçenek C **uygulandı ama yalnız Python'da:** M-F-53 (`b424246`) ve M-F-54
(`05aacaf`) commit'leri **yalnız** `tools/fixture_pipeline/` dosyalarına
dokundu (94 + 47 satır, sıfır Dart değişikliği — `git show --stat` ile
doğrulandı). Lissom'un pini `motion_core-v0.9.0`'ın Dart geometrisinde
`frameRef` **sıfır kez** geçiyor (pozitif kontrol: aynı dosyada `AngleKind`
25 kez geçiyor, yani grep çalışıyor).

M-O-08 kaydı bu kalıntının neden kaçınılmaz olduğunu da söylüyor: izotropik
düzeltme **yalnız 2D izdüşümü** onarır; özne kameraya göre dönükken 3D eksen
derinlikte kısalır ve düzlem-içi hiçbir ölçekleme onu geri getirmez. Lissom'un
12 testinden **8'i** kullanıcıya *"yandan dur"* diyor — yani tam bu hâl.

## Bulgu 3 — köprü kapsamı: 8/19, kalanı ölçü-tipi engelli

Bataryanın gerektirdiği geometrik metrik sayısı config'ten **türetildi** (elle
yazılmadı): `primaryMetric` + girişim kapısı + guard'lar, `{side}` çözülmüş →
**19** metrik (+ `hold_duration`, geometri-dışı). Devir notundaki "18" bir
eksik saymaydı.

| durum | sayı | metrikler |
|---|---|---|
| köprülü | **8** | shoulder_flexion L/R · knee_flexion L/R · **hip_flexion L/R (yeni)** · **elbow_extension L/R (yeni)** |
| `corePlaneSeparationMissing` | 4 | trunk_lean · trunk_lateral_tilt · tibia_inclination L/R |
| `coreLacksMeasureKind` | 7 | heel_rise L/R · knee_height L/R · reach_depth · shoulder_line_foreshortening · plank_hip_deviation |

Devir notu "5 bağlı (… + trunk_lean)" diyordu; ağaçta **4** bağlıydı ve
`trunk_lean` Dart tarafında **hiçbir yerde** geçmiyordu — geçemezdi de:

- **`corePlaneSeparationMissing`** — çekirdekte tek ve İŞARETLİ bir
  `trunk_tilt` var (ölçüldü: −97,9° … +124,4°). Config iki AYRI düzlem
  metriği istiyor: sagittal `trunk_lean` [0,120] ve frontal
  `trunk_lateral_tilt` [0,75]. İkisini aynı sayıya bağlamak **L-011'in
  ölü-metrik sınıfı** olurdu: iki farklı metrik, tek bir sayı, kimse fark
  etmez.
- **`coreLacksMeasureKind`** — `distance_norm`, `height_diff_norm`,
  `line_deviation_norm` Dart çekirdeğinde **yok**. Python'da var
  (`mocore/measures.py`), Dart'ta yok.

Yeni iki köprü çiftinin konvansiyonu **ölçüldü, varsayılmadı** (L-181 dersi):

| metrik | ölçüm | çevrim |
|---|---|---|
| `hip_flexion` | ayakta düz 180,0° · diz öne+yukarı 78,7° | YOK (config: "smaller = deeper") |
| `elbow_extension` | kol düz 180,0° · dirsek bükülü 6,3° | YOK (guard: `< 150` = bükülü) |

Landmark üçlüleri birebir aynı: config `[RIGHT_SHOULDER, RIGHT_HIP,
RIGHT_KNEE]` = çekirdek `rightHip(a: rightShoulder, b: rightHip, c: rightKnee)`.

## Ne değişti (kod)

- `CoreMetricReader.frameSize` **zorunlu**; `toIsotropic` uygulanıyor.
- `kMetricBindings` 4 → **8**; her binding config `frameRef`'ini BEYAN ediyor
  (uygulanamıyor, ama kaydı tutuluyor — `aggregation`'ın okuyucusuz kalıp
  sessizce yanlışlaşması, L-181, tam bu sınıftı).
- `kUnbridgedMetrics`: 11 metrik, her biri **isimli engelle**.
- `kBridgeIsReferenceEquivalent = false` + `kBridgeSpace = isotropic` —
  çekirdeğin KENDİ `MeasurementSpace` sözlüğüyle (paralel sözlük yazılmadı;
  paralel geometri kadar tehlikeli olurdu).
- **Yeni kapı** `metric_coverage_test.dart` (10 test, 4 sabotaj öz-testi):
  bataryanın gerektirdiği küme config'ten türetilir ve *gereken = köprülü ⊎
  beyan edilmiş* bölmesi zorlanır. Yeni bir metrik config'e girdiğinde ne
  sessizce çalışır görünür ne de canlı turda patlar.

## Koordinatöre giden karar

Kalan sapma bir **kapı/ölçü tasarımı** sorusudur ve paylaşımlı çekirdeği
(4 kardeş app) ilgilendirir — eskalasyon kuralı gereği tek başıma karar
vermiyorum. Somut soru:

1. **Dart çekirdeği `world` uzayına + config `frameRef`'ine geçirilecek mi?**
   (= seçenek C'nin Dart göçü, L-031 kapanışı.) Bu bir `motion-core` işi.
2. Geçene kadar canlı-tur ekranı **hangi statüde** koşacak? Öneri:
   `measurementOnly` (M-F-185) — ölçüm gösterilir, ROM hükmü verilmez;
   gerekçesi bu belgedeki sayı. Kod bunu hâlihazırda destekliyor.
3. **L-118/L-128 defter durumu güncellenmeli:** ikisi de "AÇIK (koordinatör
   kararı)" diye kayıtlı, ama seçenek C fiilen KARARA BAĞLANMIŞ ve Python'da
   uygulanmış. Defter bir tarafı bitmiş bir kararı hâlâ açık gösteriyor.
