# 🚧 A4 — ÇIKMAZ SOKAK SAYIMI (Lissom)

> **Evergreen.** Tarih başlıkta değil, `guncelleme` satırında ve satır içlerinde.
> **guncelleme:** 2026-08-13 · **kanıt:** `test/deadend_taxonomy_test.dart`
> **doğrular:** `YAYIN-HAZIRLIK-OLCUTU.md` **A4** — *"çıkmaz sokak sayısı ölçülmüş ve ADIYLA yazılmış"*

⚠️ **Bu doküman ANKRAJDIR, özet değil.** Aşağıdaki makine-okur blok testin
**karşılaştırma kaynağıdır**: sayı ağaçta değişip burada değişmezse kapı öter.
Ters yönde (dokümanı türetimden üretmek) kimse yeniden üretmeyi unuttuğunda
sessizce bayatlardı.

---

## 0. TAKSONOMİ — ithal, icat DEĞİL

Kaynak: `motion-core/workspace/YAYIN-HAZIRLIK-OLCUTU.md` §A4.

| sınıf | tanım | kim kapatır |
|---|---|---|
| **A** | içerik **hiç yazılmamış** | içerik kapasitesi (aylar) |
| **A′** | içerik **başlamış**, referans **yok** | hasat turu |
| **B** | içerik **var**, **bağlı değil** | hat |
| **C** | kart/yüzey **hiç olmamalıydı** | hat |
| **D** | içerik **tam + bağlı**, bilerek **KAPALI** | çoğu zaman kurucu |
| **E** | **ölçüm YETENEĞİ yok** (`awaiting-capability`) | çekirdek turu |

🔴 **`E` bu ağaca devir notundan GELMEDİ — ölçüte 2026-08-13 **00:44**'te
eklendi, `AJAN-DEVRI-LISSOM.md` ise **00:37**'de yazıldı.** Devrin §4
dağılımı A/B/C/D taksonomisiyle kuruldu ve 9 engelli testi *"çıkmaz sokak
değil"* diye **sınıfsız** bıraktı. Yedi dakikalık bayatlık, bir sınıfın
tamamını görünmez kılıyordu.

> ***BİR ÖN-GİRDİ, YAZILDIĞI ANDAKİ TAKSONOMİ KADAR GEÇERLİDİR.***

---

## 1. AİLE DÜZEYİ — payda **6**, işlem **6 − 1 = 5**

**Payda:** IA config'in ilan ettiği 6 aile hedefi.
**Başlatılabilir:** yürüyüşte config'ten türeyen **en az bir öğe** sunan hedef.
**İşlem:** `çıkmaz = payda − başlatılabilir` = **6 − 1 = 5**.

| aile | sınıf | dayanak (ölçülen olgu) |
|---|---|---|
| `assessment_battery` | — *(çıkmaz değil)* | `itemsSource` dolu · yürüyüşte 3 canlı test adı **çizildi** |
| `yoga_styles` | **A** | `itemsSource` **yok** · 5 çocuk **yalnız ad** |
| `flexibility_goals` | **A** | `itemsSource` **yok** · 6 çocuk yalnız ad |
| `population_packs` | **A** | `itemsSource` **yok** · 5 çocuk yalnız ad |
| `family_warmups` | **A** | `itemsSource` **yok** · 3 çocuk yalnız ad |
| `breath_meditation` | **A** | `itemsSource` **yok** · **çocuk da yok** — `NamedGapCard` |

**Dağılım:** `A=5 · A′=0 · B=0 · C=0 · D=0 · E=0`

📌 **Sınıf `A`nın dayanağı yorum değil, modelin kendi beyanı:**
`LibraryFamily.itemsSource` docstring'i — *"Boş ise ailenin öğeleri yalnız
`children` olarak İSİMLENDİRİLMİŞTİR — isimlendirilmiş ≠ inşa edilmiş."*
Yüzey de aynı şeyi kullanıcıya söylüyor: *"Names, not content. Nothing below
exists in the app you are holding."* ⇒ ad, içerik değildir ⇒ `A′` değil `A`.

⚠️ **`breath_meditation` diğer dördünden AYRI bir yüzey hâli** (çocuk yok →
`NamedGapCard`) ama **aynı sınıf**: ikisinde de yazılmış içerik sıfır. Devir
notunun *"yalnız çocuk adları"* ifadesi beşini tek kalıba sokuyordu; ölçüm
**dört + bir** gösterdi. Sınıf değişmedi, **gerekçe metni değişti.**

### `C = 0` — dayanağı bir YÜKLEM değil, BEYAN EDİLMİŞ KAPSAM STANDARDI

`C` (*kart hiç olmamalıydı*) çalışma-zamanında **türetilmiyor** ve bu bilinçli:
`LibraryIa` dürüstlük kutusu olmayan bir aileyi zaten **ayrıştıramıyor** (tip
düzeyinde zorlanıyor), yani *"kutusuz aile"* yüklemi **hiçbir zaman
ateşlenmezdi** — ölü dal, `L-011`in ölü metriğiyle aynı sınıf.

`C = 0`ın gerçek dayanağı: 6 ailenin tamamını göstermek **IA config'te beyan
edilmiş kapsam standardıdır** (`_notes`: *"Kapsamın TAMAMI kullanıcıya baştan
görünür… Ama SAHTE/boş kurs asla listelenmez"*), ve yüzey bunu kullanıcıya
sayısıyla söylüyor (*"Planned, not in this build (5)"*). Kaza değil, karar.

---

## 2. TEST DÜZEYİ — payda **12**, çıkmaz **0**, ama sınıf **E = 9**

**Payda:** bataryanın 12 testi. **İşlem:** `12 = canlı 3 ⊎ engelli 9`.

| küme | sayı | adlar |
|---|---|---|
| canlı | **3** | `active_straight_leg_raise` · `deep_squat` · `overhead_reach` |
| engelli → **E** | **9** | `ankle_dorsiflexion` · `forward_lunge` · `hamstring_reach` · `hip_hinge` · `lateral_bend` · `overhead_squat` · `plank_hold` · `single_leg_balance` · `thoracic_rotation` |
| beyansız (sınıflandırılamaz) | **0** | — |

### Çıkmaz sokak **0** — ve bu ÖLÇÜLDÜ, varsayılmadı

Devir notu *"9'u çıkmaz sokak DEĞİL, dokunulamaz `_TestRow`"* diyordu. Bu bir
**iddiaydı**; test artık hem **canlı** hem **engelli** bir satıra **basıyor** ve
rota derinliğinin değişmediğini ölçüyor.

> ***Bir satırın hedefe dönüşmesi sınıflandırmayı değiştirir: içeriksiz bir
> HEDEF çıkmaz sokaktır, içeriksiz bir SATIR değildir.***

### `E` neden doğru sınıf — köprünün KENDİ beyanı

9 testin eksik metriklerinin tamamı `BridgeBlocker` taşıyor:
`coreLacksMeasureKind` · `corePlaneSeparationMissing` ·
`coreLacksVerticalReference` · `measureIsPhaseDerived`. Dördü de *"çekirdekte
bu ölçü tipi/referansı **YOK**"* diyor — **içerik değil, ALET eksikliği.**
Ostinato'nun `E` tanımıyla birebir (*"a missing measurement **TOOL**, not a
missing threshold"*). Sınıfı ben atamıyorum, **köprü beyan ediyor**; beyansız
bir metrik çıkarsa test **kırmızı yanar** ve o test `E` sayılmaz.

⇒ **Kapatan:** çekirdek turu (`ⓑ` kovası), hat değil.

---

## 3. KAPSAM SINIRI — `bilinmiyor`, `0` DEĞİL

Bu sayımın paydası **içerik VAAT EDEN hedefler**: aile hedefleri + batarya
testleri. Sözleşmenin aday kümesindeki kalan yüzeyler
(`HomeScreen` · `ProgressScreen` · `ProfileScreen` ·
`WhatLissomDoesntDoScreen` · `LiveCaptureScreen`) bu sayıma **girmedi**.

⛔ **Bunlar `0` çıkmaz DEĞİL, `bilinmiyor`** (ölçütün kuralı: *`⛔` ile
`bilinmiyor` aynı kovaya girmez*).

**Ve sebebi isimli:** bu yüzeyler **farklı bir birimdir** — bir beyan ekranı
(`WhatLissomDoesntDo`) tanım gereği terminaldir ve onu *"öğe sunmuyor"* diye
çıkmaz saymak, ölçütün açıkça yasakladığı **yanlış sebebi** üretirdi:

> ***YANLIŞ BİR SEBEP, SEBEPSİZLİKTEN DAHA KÖTÜDÜR: DENETİMİ DOĞRULANMIŞ
> GÖSTERİR.***

⇒ *"Terminal beyan ekranı çıkmaz sokak mıdır?"* bir **ölçü tanımı** sorusudur
ve bu hattın kendi başına kapatamayacağı sınıftadır → **koordinatöre**.

---

## 4. MAKİNE-OKUR BLOK — testin karşılaştırma kaynağı

<!-- A4-SAYIM:BAŞ -->
aile.payda = 6
aile.baslatilabilir = 1
aile.cikmaz = 5
aile.contentNeverWritten = 5
aile.contentStartedNoReference = 0
aile.contentUnwired = 0
aile.shouldNotExist = 0
aile.deliberatelyClosed = 0
aile.awaitingCapability = 0
test.payda = 12
test.canli = 3
test.awaitingCapability = 9
test.cikmaz = 0
<!-- A4-SAYIM:SON -->

---

## 5. NE DEĞİŞİRSE BU DOSYA KIRMIZI YANAR

- bir aileye `itemsSource` eklenirse (→ `A` düşer, `A′` ya da `B` doğar)
- bir metrik köprüye girerse (→ `E` düşer, canlı sayısı artar)
- bir test satırı **hedefe** dönüşürse (→ payda birimi değişir, `test.cikmaz` yanlışlanır)
- bir engelli testin metriği **beyansız** kalırsa (→ sınıflandırılamaz, kapı öter)
