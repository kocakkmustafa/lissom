# Lissom — Fixture Çekim Listesi (kurucu eli gerekir)

**Tarih:** 2026-07-26 · **Kime:** kurucu · **Ne için:** G1-b görüntü güvenilirlik kapısı (`G1-V0-KAPI-PROTOKOLU.md §3`)
**Süre tahmini:** Tur 1 ≈ 25-35 dk · tüm turlar ≈ 60-75 dk (turlar bağımsız, sırayla yapılabilir)

> **Neden bu iş kritik:** Lissom'un tüm ürün varsayımı "telefon kamerası bu 10 hareketi güvenilir ölçebilir" cümlesine dayanıyor. Bu cümle şu an **kanıtlanmamış bir varsayım**. Bu çekimler olmadan motor kodu yazmak, ölçülemeyen bir şeyi ölçüyormuş gibi gösteren bir ürün riski taşır (DEFTER L-001 / L-005). Tur 1 tek başına kapının yaklaşık %70'ini açar.

---

## 0. Hazırlık (bir kez)

**Donanım**
- Telefon: iPhone (arka kamera — ön kameradan daha iyi optik). Tripod veya sabit yüzey (kitap yığını olur).
- Kayıt ayarı: **1080p, 30 fps.** (60 fps DEĞİL — fixture, üretimdeki kare hızıyla birebir aynı boruyu izlemeli; katalog §6.)
- Ortam: en az 2.5 m derinlik, düz zemin, sade arka plan (desenli halı/kalabalık raf değil).

**Kamera yerleşimi (araştırma-güdümlü, JMIR 2026 e82412 + PLOS ONE 2023)**
- **Mesafe: 180-200 cm** (kamera ↔ kişi). Bu, literatürde en yüksek doğruluk veren bant. 90 cm gibi yakın mesafe ölçümü çökertiyor.
- **Yükseklik: ~100 cm** (kalça/göbek hizası). Tripod yoksa: masa + kitap.
- **Telefon dikey mi yatay mı:** **dikey (portrait)** — ayakta tüm vücut testlerinde baş-ayak kadraja daha rahat sığar. Oturur test (T10) yatay olabilir.
- Kadraj: tüm hareket boyunca **baş ve ayaklar kadrajda kalmalı**, üstte/altta ~10 cm boşluk.

**Kritik kural — "kamera-tarafı eklem"**
Yandan (sagittal) çekimde kameraya **yakın** taraftaki eklem 1.5-4° hatayla ölçülüyor; **uzak** taraf bunun ~2 katı hata alıyor. Bu yüzden tek-taraflı ölçümlerde **her iki taraf ayrı ayrı çekilir** (kişi 180° döner), sağ-sol farkı iki ayrı klipten hesaplanır. Aynı klipte "sağ ve sol" karşılaştırması yapılmaz.

**Her klipte 3 tekrar**
Her klip, aynı hareketin **3 ardışık tekrarını** içerir (aralarında ~2 sn dur). Böylece test-retest tutarlılığı (TRV) tek klipten hesaplanabilir — ayrı klip çekmeye gerek yok.

**Klip başı/sonu payı**
Kaydı başlat → yerine geç → **3 sn hareketsiz bekle** → hareketi yap → bitişte **2 sn bekle** → kaydı durdur. Baştaki bekleme, ölçüm hattının "hazır" durumunu yakalaması için gerekli.

**Dosya adlandırma (harness bunu otomatik okuyacak — şemadan sapma = o klip işlenmez)**

```
<testId>__<subject>__<side>__<plane>__<light>__<clothing>__<distance>__<take>.mov
```

| Alan | İzinli değerler | Örnek |
|---|---|---|
| `testId` | aşağıdaki tablodaki ID | `overhead_reach` |
| `subject` | `s1`, `s2`, … (kurucu = `s1`) | `s1` |
| `side` | `left` · `right` · `bilateral` | `right` |
| `plane` | `sagittal` · `frontal` · `diagonal` | `sagittal` |
| `light` | `bright` (gündüz/iyi ışık) · `dim` (akşam/tek lamba) | `bright` |
| `clothing` | `tight` (tayt/dar tişört) · `loose` (eşofman/bol tişört) | `tight` |
| `distance` | `190` (cm, yaklaşık) | `190` |
| `take` | `01`, `02`, … | `01` |

Örnek: `overhead_reach__s1__right__sagittal__bright__tight__190__01.mov`

**Nereye kaydedilecek:** `~/lissom-fixtures/raw/` — **repo İÇİNE KOYMA.**
Gerekçe: ham video hiçbir koşulda repoya girmez (gizlilik ilkesi + repo şişmesi). Hattımız videodan landmark JSON üretir; repoya yalnız **JSON** girer, video sende kalır.

---

## 1. TUR 1 — Temel geçerlilik (ÖNCELİKLİ, ~16 klip)

İyi koşul: `bright` + `tight` + `190` cm. Her klipte 3 tekrar.

| # | testId | Hareket (ne yapacaksın) | Düzlem | Taraf | Klip |
|---|---|---|---|---|---|
| 1 | `overhead_reach` | Ayakta, kollar yanda → yavaşça baş üstüne kadar kaldır, 2 sn tut, indir | sagittal (yan dur) | right | 1 |
| 2 | `overhead_reach` | Aynısı, diğer yanını kameraya dön | sagittal | left | 1 |
| 3 | `deep_squat` | Ayaklar omuz genişliği, kollar önde → gidebildiğin kadar çök, 2 sn tut, kalk | sagittal (yan dur) | bilateral | 1 |
| 4 | `deep_squat` | Aynısı, kameraya **dönük** (önden) | frontal | bilateral | 1 |
| 5 | `overhead_squat` | Kollar baş üstünde düz → çök, kollar yukarıda kalsın, kalk | sagittal | bilateral | 1 |
| 6 | `overhead_squat` | Aynısı önden | frontal | bilateral | 1 |
| 7 | `ankle_dorsiflexion` | Duvara bakarak, ayak duvardan ~10 cm geride, topuk yerde → dizi duvara değdirmeye çalış | sagittal | right | 1 |
| 8 | `ankle_dorsiflexion` | Aynısı sol bacak | sagittal | left | 1 |
| 9 | `hamstring_reach` | Ayakta, dizler düz → öne eğil, ellerinle ayaklara uzan, 2 sn tut, doğrul | sagittal | right | 1 |
| 10 | `hamstring_reach` | Aynısı, diğer yanın kamerada | sagittal | left | 1 |
| 11 | `hip_hinge` | Ayakta, eller kalçada → sırt düz kalarak kalçadan öne kır, doğrul | sagittal | right | 1 |
| 12 | `lateral_bend` | Ayakta, kollar yanda → sağa yana eğil, dön, sola yana eğil (3 çift) | frontal (önden) | bilateral | 1 |
| 13 | `single_leg_balance` | Tek ayak üstünde 20 sn dur, eller kalçada, gözler açık | frontal | right | 1 |
| 14 | `single_leg_balance` | Aynısı sol bacak | frontal | left | 1 |
| 15 | `forward_lunge` | Öne adım at, dizi indir, geri dön (3 tekrar) | frontal | right | 1 |
| 16 | `thoracic_rotation` | Sandalyede otur, kollar göğüste çapraz → gövdeni sağa çevir, ortaya, sola çevir | frontal (önden, biraz yukarıdan) | bilateral | 1 |

**Tur 1 tamamlandığında** kapının B1 (iyi koşulda geçerli-ölçüm oranı), B3 (test-retest) ve B6 (süre) kriterleri ölçülebilir hale gelir.

---

## 2. TUR 2 — Koşul dayanıklılığı (~12 klip)

Sadece **6 çekirdek test** × 2 zorlu koşul. Amaç: ölçüm koşul değişince ne kadar kayıyor (kapı kriteri B2, B4).

Çekirdek testler: `overhead_reach` (right) · `deep_squat` (sagittal) · `ankle_dorsiflexion` (right) · `hamstring_reach` (right) · `single_leg_balance` (right) · `lateral_bend`

| Koşul | Ne değişecek | Klip sayısı |
|---|---|---|
| A | `dim` + `tight` (akşam / tek lamba, aynı kıyafet) | 6 |
| B | `bright` + `loose` (aynı ışık, **bol eşofman + bol tişört**) | 6 |

Diğer her şey (mesafe, düzlem, taraf) Tur 1 ile aynı kalmalı — yoksa neyin değiştiğini ayıramayız.

---

## 3. TUR 3 — Geçersizlik senaryoları (~10 klip, kasıtlı HATALI)

Bunlar "bozuk" çekimler ve **kasıtlı olarak bozuk** olmalı. Motorun bunları reddedip reddetmediğini ölçüyoruz (kapı kriteri B7). Adlandırmada `take` yerine `invalid-<sebep>` yaz:
`deep_squat__s1__bilateral__sagittal__bright__tight__190__invalid-outofframe.mov`

| # | Sebep etiketi | Ne yapacaksın |
|---|---|---|
| 1 | `invalid-outofframe` | Squat yaparken kadrajın dışına doğru kay (ayaklar görünmesin) |
| 2 | `invalid-tooclose` | Kamerayı ~80 cm'e getir, aynı hareketi yap |
| 3 | `invalid-toofar` | Kamerayı ~350 cm'e götür, aynı hareketi yap |
| 4 | `invalid-heellift` | Squat'ta topukları kasıtlı kaldır |
| 5 | `invalid-partial` | Hareketi yarıda bırak (yarı squat, doğrulma yok) |
| 6 | `invalid-twoperson` | Kadraja ikinci bir kişi girsin (yoksa: büyük bir ayna/poster yansıması ya da bu klibi atla) |
| 7 | `invalid-occluded` | Ölçülecek eklemin önüne bir engel koy (sandalye arkasında squat) |
| 8 | `invalid-support` | Tek ayak dengesinde duvara/mobilyaya tutun |
| 9 | `invalid-dark` | Işıkları neredeyse tamamen kapat, hareketi yap |
| 10 | `invalid-angle` | Kamerayı tam yan yerine ~45° eğik koy, sagittal test yap |

Bunlar G3'te **negatif fixture** olarak da kullanılacak (roadmap G3: her test için ≥1 doğru + ≥2 hatalı fixture şartı).

---

## 4. TUR 4 — Bilinen-açı referansı (~6 klip, OPSİYONEL ama değerli)

Bu tur, kapının B5 (mutlak doğruluk / MAE) kriterini açar. Olmadan da kapı geçilebilir ama **"measures your mobility" iddiası** bu ölçüm olmadan kurulamaz (L-005).

**Yöntem (ikisinden biri, hangisi kolaysa):**
- **(a) İkinci telefon açıölçer:** Statik pozda dur (ör. kolu 90°'de sabitle). İkinci telefonu koluna/bacağına daya, açıölçer/su terazisi uygulamasından açıyı oku, sesli söyle ("ninety degrees") — ses kayda girsin, sonra eşleştiririm.
- **(b) Duvara referans çizgi:** Duvara bantla 0°/45°/90°/135° çizgileri yapıştır, kolunu çizgiye hizala.

| # | Test | Hedef açılar |
|---|---|---|
| 1-3 | `overhead_reach` statik | ~45°, ~90°, ~135° (kol) |
| 4-5 | `hip_hinge` statik | ~45°, ~90° (gövde) |
| 6 | `lateral_bend` statik | ~30° (gövde) |

Adlandırma: `overhead_reach__s1__right__sagittal__bright__tight__190__ref-090.mov`

---

## 5. Çeşitlilik notu (dürüstlük kaydı)

Bütün çekimler tek kişiyle (`s1`) yapılırsa kapı **vücut-tipi yanlılığıyla** geçer. Bu yanlılık, kapı raporunda açıkça yazılacak ve DEFTER'de açık kalacak. Mümkünse **1-2 kişi daha** (farklı boy / vücut oranı / cinsiyet) Tur 1'i tekrarlasın (`s2`, `s3`) — sadece Tur 1 yeterli. Bu G8'e kadar kapanması gereken bir açık.

---

## 6. Çekim bittiğinde ne olacak

Sen hiçbir şey yapmayacaksın; klasörü haber ver, gerisini hat yapar:

```bash
cd ~/Documents/YULAlab-AI/ventures/motion-core/lib/tools/fixture_pipeline
./.venv/bin/python extract_landmarks.py --input ~/lissom-fixtures/raw --output ~/lissom-fixtures/landmarks
```

Bu komut her videoyu MediaPipe'tan geçirir, `fixture JSON` üretir (şema: katalog §6), ham video **hiçbir yere kopyalanmaz**. Sonra kapı ölçümü koşar ve `G1-V0-KAPI-RAPORU.md` üretilir.
