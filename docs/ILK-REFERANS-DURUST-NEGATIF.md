# İlk Lissom Referansı — DÜRÜST NEGATİF RAPORU

**Hüküm: `overhead_reach` ve `deep_squat` MEVCUT malzemeyle referans
KURAMAZ.** Bu bir başarısızlık raporu değil, bir ÖLÇÜM raporu: havuzun
neden yetmediği eksenlerde sayıyla gösterilmiştir ve neyin değişmesi
gerektiği isimlidir.

**Tarih:** 2026-07-30 · **Çekirdek:** `motion_core` @ `c561204` ·
**İlgili kayıtlar:** L-147 · L-148 · L-149 · L-153 · L-157 · L-162 · L-166 ·
**L-169 (bu raporun ÖNEMLİ REVİZESİ — §1b)**

> ## ⚠️ REVİZE 2026-07-30 (L-169) — bu raporun ana çıkarımı DEĞİŞTİ
>
> İlk sürümde aile bağlamına dayanarak "Lissom'un havuzu da *havuz
> büyütmek anlaşma getirmiyor* sınıfında" denmişti. **Ölçüm bunu
> ÇÜRÜTTÜ.** Koordinatörün talimatıyla havuz `c561204` rig'iyle yeniden
> sınıflandırıldı, bir kaynak daha uygun hâle geldi ve deneme 7 kaynakla
> yeniden koşuldu: **tek kaynak eklemek sapmaların BEŞİNİN DÖRDÜNÜ
> düşürdü, ortalamayı %22 indirdi** (75,2° → 58,3°), en iyi kaynağı
> 52,7° → **32,8°** yaptı. Hüküm hâlâ RET (eşik ≤14°) ama **yön ters
> yönde:** bu havuz heterojen olmaktan çok **AZ-NÜFUSLU**. Ayrıntı §1b.
>
> Sonuç: §5'teki "hedefli hasat" artık bir umut değil, **ölçülmüş bir
> beklenti** — ve aile sınırını Lissom'a peşinen uygulamam yanlıştı.
>
> ## ⚠️⚠️ REVİZE-2 (L-173) — KÖK NEDEN BULUNDU, "az-nüfus" AÇIKLAMASININ ÜSTÜNDE
>
> M-F-175'in **varyant-kimliği** ölçütü havuzuma uygulandı ve asıl sebep
> çıktı: **7 kaynağın 7'si TEK bir baş-üstü uzanma testi DEĞİL** —
> altısı çok-egzersizli rutin ("10 MIN MOBILITY ROUTINE", "Follow Along",
> "5 Moves"), yedincisi ise adıyla **"Wall Slides"** (duvar-destekli
> varyant). `presence_isolator` her birinde "bir kol baş üstüne çıktı ve
> orada kaldı" penceresi buldu — ama **hangi EGZERSİZ olduğunu sormadı.**
> Yedi kaynak yedi FARKLI egzersizden pencere verdi; 42-108° anlaşmazlık
> bunun doğal sonucu. Ayrıntı §1d.

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

## 1b. Tur 6 — HAVUZ TAZELENDİ, YÖN DEĞİŞTİ (L-169)

Koordinatör talimatı: JabLab'ın ikinci-şahıs emir-kipi sınıfı (`c561204`)
merge'lendikten sonra havuzu YENİDEN SINIFLANDIR, deneme en dolu havuzla
yapılsın.

**Yeniden sınıflandırma** (`tools/reclassify_pool.py`, 68 manifest):
6 kaynak `None` → **`active`** oldu. Yalnız 1'inin çıkarılmış fixture'ı
var (`GaP20t6ZOfU`, InvictusFitness, `overhead_reach`) — kalan 5 çıkarım
ister, o da hasat sıramı bekler.

**Yol boyunca bulunan M-F-138 İKİZİ — bayat YOKLUK:** `GaP20t6ZOfU`'nun
landmark fixture'ı romMode hattından ÖNCE çıkarılmış, provenance'ında
`referenceEligible` alanı HİÇ YOK. Manifest tazelendi ama fixture bunu
bilmiyordu; kanonik CLI fail-closed davranıp `unattested` saydı ve kapıda
bıraktı — **havuz gerçekte olduğundan KÜÇÜK görünüyordu.** Kesici artık
uygunluğu KESİM ANINDA MANİFESTTEN çözüyor (çekirdek `94b4ae9` ile aynı
ilke). Bayat yokluk, bayat varlık kadar zararlı.

**Kesin koşum — 7 kaynak, taze uygunluk (6 ölçülebilir take):**

| kaynak | 5-take | 6-take | değişim |
|---|---|---|---|
| Igzmhbghcd4 | 72,3° | 57,2° | **−15,1** |
| SfxyICleU4I | 108,2° | 97,7° | **−10,5** |
| T8KTiE9bTZI | 70,1° | 49,7° | **−20,4** |
| X2u_vGL0qJU | 52,7° | **32,8°** | **−19,9** |
| gsz3BLAkkQ4 | 72,9° | 72,9° | 0,0 |
| GaP20t6ZOfU | — | 39,7° | (yeni) |

**Ortalama sapma 75,2° → 58,3° (−%22). En iyi kaynak 52,7° → 32,8°.**

**Bu, ilk raporumun ana çıkarımını çürütüyor.** Havuzu heterojen sayıp
aile sınırını ("havuz büyütmek anlaşma getirmiyor") Lissom'a peşinen
uygulamıştım. Ölçüm tersini söylüyor: **tek kaynak eklemek beşin dördünü
düşürdü.** Mekanizma açık — konsensüs medoid ve hücre-bazlı ortalamadan
türetiliyor, az-nüfuslu bir havuzda her yeni take konsensüsü daha tutarlı
bir merkeze çekiyor. Bu havuz **heterojen değil, AZ-NÜFUSLU.**

Hüküm hâlâ RET (32,8° ≫ 14°) ve §2'nin üç-eksen bulgusu AYAKTA — ama
§5'in "hedefli hasat" maddesi artık umut değil, **ölçülmüş eğilim.**

**Pencerelemenin kötüleştirmesi bir çelişki değil, bir kanıt:** kesilen
pencereler 129-1294 kare arasında (10× yayılım) — L-153'ün "şüpheli uzun
tutuş" bulgusunu doğruluyor. Pencereler aynı uzunlukta OLMADIĞI için DTW
çok farklı süreleri hizalamak zorunda kaldı.

## 1c. Tur 7 — "5 bekleyen kaynak" ÇÜRÜTÜLDÜ; havuz 7'de sabit (L-170)

Hasat sırası bana geçti; paket "5 bekleyen kaynağın çıkarımı → 11-kaynak
havuzu" diyordu. **İkisi de ölçümle çürüdü.**

**(a) Beş kaynak "çıkarım bekliyor" DEĞİL, TRİYAJ-REDDİ taşıyor:**

| kaynak | hareket | triyaj reddi | romMode geri alır mı |
|---|---|---|---|
| `QlUhbo41GTg` | overhead_reach | netlik **28** < 40 (bulanık) | **hayır** |
| `IHApHfNA2Ag` | deep_squat | süre **69s** < 90s | **hayır** |
| `8V3uad4MSaE` | lateral_bend | **dikey format** 480×854 | **hayır** |
| `ghL3AJfRT6k` | lateral_bend | netlik **14** < 40 | **hayır** |
| `lr3_bA48EBM` | ? | netlik **37,8** < 40 (**SINIRDA**) | hayır |

`rom_mode` gösterim-modunu sorar; triyaj kadraj/netlik/süre/format sorar.
**Biri aktifleşince öteki geri alınmaz.** Bunları çıkarmak = triyaj kapısını
gevşetmek; yapılmadı. Aynı sınıf: §2/§3'ün "üç ölçüt bağımsız" bulgusu, bir
kat daha yukarıda (uygunluk ölçütleri de birbirinin yerine geçmez).

**(b) "11-kaynak havuzu" YOK.** `overhead_reach`'in gerçek uygun+fixture'lı
havuzu **7** (L-141'in 6'sı + `GaP20t6ZOfU`) ve yedisi de ÇOKTAN
çıkarılmıştı — yani §1b'nin koşumu zaten "en dolu havuz"du. `deep_squat` 3.

**(c) v0.8.8 doğrulaması** (pinli tag, M-F-154): sapmalar 0.8.4 ile
**BİREBİR AYNI** — `overhead_reach` 57,2/97,7/49,7/32,8/72,9/39,7 ·
`deep_squat` 23,4/33,8/38,6. `medoidTakeId`/`gateJoints` sürümü sayıları
oynatmadı (beklenen: ikisi de bu yolda devreye girmiyor).

**(d) `evidenceThickness`/`capFillShare`/`medoidTakeId` dağılımı
RAPORLANAMADI** — bu alanlar artefaktta yaşıyor, artefakt ancak kurulum
BAŞARILI olunca üretiliyor. Üç koşumun üçü de anlaşma kapısında reddedildi,
dolayısıyla artefakt YOK. Aile eşik-tabanına Lissom verisi ilk BAŞARILI
kurulumda gelebilir; şimdi vermek uydurma olurdu.

**(e) `gateJoints` KULLANILMADI, gerekçeli:** `overhead_reach`'te kollar
hareketin KENDİSİ; kapı-daraltması yalnız ÖLÇÜLMÜŞ `coached_only` temeliyle
meşru (M-F-143). Elimde öyle bir ölçüm yok — daraltma sapmaları düşürürdü
ama gerekçesiz olurdu, yani eşiği gevşetmenin başka bir adı.

**Tek açık kalem:** `lr3_bA48EBM` netliği **37,8 vs eşik 40** — sınırda.
L-141'de de benzer bir sınırda-ret vardı (38<40). Bu bir EŞİK sorusu,
override sorusu değil; koordinatöre bırakıyorum.

## 1d. Tur 8 — VARYANT-KİMLİĞİ: kök neden (L-173)

Koordinatör M-F-175'i ekledi (Gravita'nın yayımlı squat referansında yüklü
varyant kirlenmesi: medoid 198 kg barbell triple, %17 katkı). Ölçüt benim
havuzuma uygulandı.

**(a) Metin taraması — 1 bayrak, ve EN KÖTÜ yerde.** `deep_squat`'ın 3
kaynağı **temiz**. `overhead_reach`'te tek bayrak: **`X2u_vGL0qJU`** —
yani L-162'nin iki ölçütünü de geçen TEK kaynak, §1b'de sapması en çok
düşen (52,7→32,8°) kaynak. Gerekçe zayıf-kanıt değil, SPESİFİK: video
5 egzersizlik bir dizi ve #2'si *"banded inferior shoulder
mobilizations"* (açıklamada zaman damgalarıyla).

**(b) Pencere haritalandı — bayraktan DAHA KÖTÜ çıktı.** Kesilen pencere
kare 4080-4221 @25fps = **2:43-2:49**. Video bölümleri: 2:24 *wall
slides* · 3:11 *banded mobilizations* · 3:44 *bench opener*. Pencere
bantlı bölümde DEĞİL — **wall slides** bölümünde. Ve wall slides de aranan
varyant değil: test *"Stand side-on… let your arms hang… raise the arm as
high overhead as you can"* diyor; wall slides duvara dayalı bir skapular
egzersizdir.

**(c) ASIL BULGU — havuzun TAMAMI varyant-uyumsuz:**

| kaynak | başlık | ne | zaman damgası |
|---|---|---|---|
| 6u_rV3C80wU | 10-Minute Shoulder Arthritis Exercises: **Follow Along Routine** | çok-egzersiz | — |
| Igzmhbghcd4 | 10 MIN PERFECT MOBILITY **ROUTINE** | çok-egzersiz | — |
| SfxyICleU4I | Unlock your Chest and Shoulders (**Follow Along**) | çok-egzersiz | — |
| T8KTiE9bTZI | Shoulder Mobility **Follow-Along** | çok-egzersiz | — |
| X2u_vGL0qJU | **5 Moves** You've Never Tried | çok-egzersiz | 7 |
| gsz3BLAkkQ4 | Essential Shoulder Mobility **Tests** | çok-egzersiz | 8 |
| GaP20t6ZOfU | **Wall Slides** | yanlış varyant | — |

**Hiçbiri tek bir baş-üstü uzanma testi değil.** `presence_isolator`
"birincil metrik eşiği aştı ve tuttu" penceresi buluyor — bu soru
"hareket var mı"dır, **"hangi egzersiz"** değil. Yedi kaynak yedi farklı
egzersizden pencere verdi.

**(d) AİLE KATKISI — varyant-kimliği KAYNAK düzeyinde çözülemez:**
M-F-175 kaynak-başına bayrak öneriyor; ölçüm bunun YETMEDİĞİNİ gösterdi.
Çok-egzersizli bir kaynakta bayrak "bu videoda bantlı bir şey var" der,
ama KESİLEN PENCERENİN hangi egzersiz olduğunu söylemez — benim vakamda
bayrak bantlı bölümü işaret etti, pencere ise başka (yine yanlış) bir
bölümdeydi. **Varyant kimliği PENCERE düzeyinde sorulmalı.**

**(e) L-169 ile ilişki — çürütme değil, ALTINI AÇIKLAMA:** "bir kaynak
eklemek sapmaları %22 düşürdü" ölçümü AYAKTA; ama mekanizma artık daha
net. Havuz yalnız az-nüfuslu değil, **karışık-egzersizli**; yeni take
konsensüsü çekiyor çünkü konsensüs zaten tek bir hareketin değil, bir
egzersiz KARIŞIMININ ortalaması. Hedefli hasat hâlâ doğru yol — ama
kriter "daha çok kaynak" değil, **tek-egzersiz kaynağı**.

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
- ⚠️ **"Havuz büyütmek anlaşma getirmez"** — BEN İDDİA ETTİM, ÖLÇÜM
  ÇÜRÜTTÜ (§1b): tek kaynak eklemek ortalamayı %22 düşürdü. Bu madde
  artık çürütülenler listesinde DEĞİL, **desteklenenler** tarafında.
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
   **§1b'nin katkısı:** eklenen her uygun kaynak sapmaları ölçülebilir
   biçimde düşürüyor (1 kaynak = −%22 ortalama). Bu, hasatın işe
   yarayacağının KANITI değil ama EĞİLİM kanıtı — ve eğilim doğru yönde.
3. ~~**Bekleyen 5 yeni-uygun kaynak** çıkarım ister~~ → **ÇÜRÜTÜLDÜ,
   §1c.** Beşi de TRİYAJ-REDDİ taşıyor; romMode'un aktifleşmesi başka bir
   eksendeki reddi geri almaz. Havuz bu yolla BÜYÜMEZ.
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
