# İlk Lissom Referansı — DÜRÜST NEGATİF RAPORU

**Hüküm: `overhead_reach` ve `deep_squat` MEVCUT malzemeyle referans
KURAMAZ.** Bu bir başarısızlık raporu değil, bir ÖLÇÜM raporu: havuzun
neden yetmediği iki bağımsız eksende sayıyla gösterilmiştir ve neyin
değişmesi gerektiği isimlidir.

**Tarih:** 2026-07-30 · **Çekirdek:** `motion_core-v0.8.4` · **İlgili kayıtlar:**
L-147 · L-148 · L-149 · L-153 · L-157 · L-162 · L-166
**Aile bağlamı:** aile "havuz büyütmek anlaşma getirmiyor" sınırını başka
ürünlerde de ölçtü (Ostinato üç çalgı · JabLab stance). Lissom'un havuzu
aynı sınıfta — utanç değil, veri.

---

## 1. Ne denendi (kronolojik, hepsi ölçümle)

| Tur | Yapılan | Sonuç |
|---|---|---|
| 1 | 6 uygun kaynak (romMode-aktif, L-141), tam video | RET — sapmalar **42-60°** (eşik ≤14°) |
| 2 | 0.8.0 çevrim-segmentasyonu | Sapmalar DEĞİŞMEDİ — `CyclePeriodEstimator` 5/5 kaynakta `measured=false` ("moving but not repeating"): `overhead_reach` tekrarlı-çevrim İÇERMEZ, segmentasyon yapısal olarak devreye giremez (L-148) |
| 3 | 0.8.1 zamansal koridor | Sapmalar +0,1-1,7° kaydı, hüküm aynı (karışık fps: 24/24/60/24/25) |
| 4 | **presence-pencereli kesim** (`presence_isolator`) | RET, ve **DAHA KÖTÜ**: **72,3 / 108,2 / 70,1 / 52,7 / 72,9°** (L-157) |
| 5 | Yatay-gövde 2 kaynak dışlanarak | RET — kalan 3'te **43-80°**: duruş gerçek bir sebep ama TEK sebep değil |

`deep_squat` paralel: tam video 34-43° → presence-pencereli 23,4/33,8/38,6°
(karışık: biri iyileşti, biri kötüleşti). Hâlâ RET.

**Pencerelemenin kötüleştirmesi bir çelişki değil, bir kanıt:** kesilen
pencereler 129-1294 kare arasında (10× yayılım) — L-153'ün "şüpheli uzun
tutuş" bulgusunu doğruluyor. Pencereler aynı uzunlukta OLMADIĞI için DTW
çok farklı süreleri hizalamak zorunda kaldı.

## 2. Kök neden: kaynaklar aynı şeyi göstermiyor — İKİ BAĞIMSIZ EKSEN

`tools/identity_review.py` kaynak-başına profil çıkardı (medyan değerler,
hareket penceresi içinde).

### Eksen 1 — DURUŞ (`trunk_lean`)

| kanal | trunk medyan | hüküm |
|---|---|---|
| Fitness For Freedom | 1,8° | ayakta ✓ |
| Virtual Hand Care | 7,9° | ayakta ✓ |
| Hooper's Beta | 9,9° | ayakta ✓ |
| Comeback Performance | 11,5° | ayakta ✓ |
| **Strength Side** | **75,8°** | ✗ yatay gövde |
| **Fraser Wilson** | **79,2°** | ✗ yatay gövde |

Talimat: *"**Stand** side-on to the camera… raise the arm overhead"*.
76-79° gövde eğimi ayakta bir baş-üstü uzanma DEĞİL (yerde/eğilmiş omuz
mobilite çalışması olabilir — kaynak kendi bağlamında doğru olabilir,
bizim tanımımıza uymuyor).

### Eksen 2 — KAMERA GÖRÜŞÜ (`shoulder_line_foreshortening`)

Sentetik tabanla kalibre edildi: **0,80 = kameraya dönük (yaw 0°)** ·
**0,00 = yandan (yaw 90°)**. Sagittal bir test SIDE-ON ister (≲0,2).

| kanal | foreshortening | ~yaw | hüküm |
|---|---|---|---|
| Fraser Wilson | 0,1 | ~83° | yandan ✓ |
| **Comeback Performance** | **0,2** | **~76°** | **yandan ✓** |
| Hooper's Beta | 0,5 | ~51° | ✗ önden |
| Strength Side | 0,5 | ~51° | ✗ önden |
| Virtual Hand Care | 0,6 | ~41° | ✗ önden |
| Fitness For Freedom | 0,6 | ~41° | ✗ önden |

### İki eksen BİRLİKTE

| hareket | kaynak | iki ölçütü de geçen | minSources |
|---|---|---|---|
| `overhead_reach` | 6 | **1** (Comeback Performance) | 3 |
| `deep_squat` | 4 | **1** (Advanced Physical Therapy) | 3 |

**Havuz yapısal olarak yetmiyor.** Eşiği gevşetmek bunu çözmez, yalnız
saklar.

## 3. Üçüncü bağımsız eksen: hareket kimliği

`deep_squat`'ta iki ölçütü de geçen TEK kaynak (`Advanced Physical Therapy`),
Lissom'un KENDİ kimlik kapısının `different-movement` diye reddettiği
kaynaktır: `hipKneeCoupling` **−0,46** (eşik ≥ +0,20), en derin dizde kalça
**151°** — diz çökme/yüzüstü diz bükme, çömelme değil (L-144).

**Üç ölçüt bağımsızdır ve hiçbir kaynak üçünü birlikte geçmiyor.** Bu, tek
bir kusurun üç görünümü değil; üç ayrı uygunluk sorusu.

## 4. Ne DEĞİL — çürütülen açıklamalar

Bunlar sırayla denendi ve ELENDİ (her biri ölçümle):

- ❌ **"Segmentasyon eksikti"** — 0.8.0 geldi, `overhead_reach` yapısal
  olarak aperiyodik, devreye girmedi (L-148).
- ❌ **"fps karışıklığı"** — 0.8.1 koridor düzeltmesi ≤1,7° kaydırdı.
- ❌ **"Tam video sulandırıyor"** — pencereleme sapmaları KÖTÜLEŞTİRDİ.
- ❌ **"Tek kötü kaynak var"** — iki yatay-gövde kaynağı dışlandı, kalan
  3'te 43-80°.
- ❌ **"Metin ön-elemesiyle daha iyi kaynak seçilebilir"** — 6/6 kaynağın
  metninde kamera görüşü hiç geçmiyor; ön-eleme kullanılabilir TEK kaynağı
  eliyordu (L-166).

## 5. Hükmü değiştirecek şey — isimli

1. **Hedefli hasat** (sıra: Choreia → JabLab → Lissom; makine-başına tek
   tur). Terimler `tools/harvest_prescreen.py --terms` ile üretilir ve
   L-162'nin iki eksenini ARAMA tarafına taşır (`side view` · `standing`).
   ⚠️ Terimin mekanizması filtreleme DEĞİL, hangi adayların GELDİĞİni
   değiştirmek (L-166).
2. **Hedef:** hareket başına ≥3 kaynak, üç ölçütü de geçen (duruş ·
   kamera görüşü · hareket kimliği). Mevcut oran 1/6 ve 1/4 olduğuna göre
   ~9-18 aday taranmalı — bu bir TAHMİN, ölçüm değil; gerçek verim
   hasat turunda ölçülür.
3. **Havuz kuru çıkarsa** meşru sonuç: bu iki test referanssız kalır,
   `measuredNoBands` / nitel bant yolunda yaşar (motor bunu zaten
   destekliyor — `lissom_engine` `ResultTier.measuredNoBands`), ve ürün
   J-038 desenindeki gibi eksik ÖLÇÜMÜN adıyla konuşur.

## 6. Bu raporun sınırları (kendi ölçümüme karşı dürüstlük)

- **Yaw kestirimi YAKLAŞIK:** sentetik taban nötr-ayakta duruştan alındı;
  baş-üstü uzanma omuz hattı geometrisini bir miktar değiştirir. 0,1 ↔ 0,6
  ayrışması bu belirsizliğin çok üstünde, ama tablodaki derece değerleri
  ±10° mertebesinde okunmalı.
- **`trunk_lean` medyanı pencere içinde alındı**, tüm video değil — farklı
  pencere tanımı sayıları oynatabilir.
- **`presence` eşikleri PROVISIONAL:** `movementPresence`'tan devralındı,
  ayrıca türetilmedi (2D-proksi geometrisi mocore'un gerçek ölçümüyle
  karşılaştırılmadı).
- **Kesim provenance'ı M-F-138 sınıfında:** pencereler snapshot'lanmış
  `referenceEligible` taşıyor; `derivedFrom` alanı tazeliği SORULABİLİR
  yaptı ama doğrulamıyor (ortak yardımcı JabLab'da).
