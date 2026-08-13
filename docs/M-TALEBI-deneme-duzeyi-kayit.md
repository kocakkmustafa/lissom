# M-TALEBİ — DENEME-DÜZEYİ KAYIT: ölçülen sayı nereye yazılır?

> **Durum:** ⏳ koordinatör hükmü bekleniyor · **Uygulama BAŞLATILMADI.**
> **Talep eden:** Lissom hattı · **Tarih:** 2026-08-14 · **Kayıt:** `L-316`
>
> ⛔ Bu belge bir **karar** değil, kararı **uygulanabilir kılan hazırlık**.
> Hüküm geldiğinde iş dakikalar sürsün diye yazıldı (A12 preflight'ıyla aynı
> disiplin). *Hazırlık evet, uygulama onayla.*

---

## 1. OLGU — ölçüldü, iddia edilmedi

`test/measurement_value_persistence_test.dart` (3 test, iki pozitif çapalı):

**`AssessmentResult` taşır:** `value` · `unit` · `bandLabel` · `provenance`
**`SessionRecord` (çekirdek) taşır:** `lessonId` · `completedAt` ·
`workedSeconds` · `unitsCompleted` · `plannedUnits` · `unitLabel` ·
`lessonClass` · `unmeasuredUnits` · `unmeasuredReason`

⇒ `recordFor()` çeviriyi yaparken **dördünü de düşürür.** Kaydın JSON'unda
`147` de `deg` de `pose_landmarker` da yok (alan adı değil **sayının kendisi**
arandı, bir alan adı değişse bile bulgu geçerli kalsın diye).

> ***Lissom bir eklem açısını ölçer, bir kez gösterir, ve sonsuza dek atar.***

**Kullanıcıya bugün ne diyoruz:** Progress'te *"The reading itself is not kept"*
(L-316'da eklendi) — yani **yalanlamıyoruz**, ama ürün kimliği *"ölçüm"* olan
bir uygulamada ölçümün kendisi saklanmıyor.

---

## 2. Bu bir kusur DEĞİL — gerekçesi BAYATLAMIŞ bir karar

Çekirdeğin kendi başlığı (`session_store.dart`):

> *"**Why so few fields:** every stored field is an invitation for a product
> surface to lean on it. There is deliberately NO verdict/score field —
> recording zeros **before the camera bridge** would draw zeros on tomorrow's
> progress chart. Attempt-level provenance (ADR-005: analysisConfidence,
> orientationStrategy, model SHA) is deliberately absent too: **that is
> attempt-level data, this is a session-level record.**"*

**İki cümle, iki ayrı bilgi:**

**① Ön koşul GEÇTİ.** *"Kamera köprüsünden ÖNCE"* deniyor. Lissom'da köprü
**VAR** (A1, `L-309`): ölçüm uçtan uca koşuyor, gerçek açı üretiyor, depoya
yazıyor. Sıfır yazma riski geçti.
> ***BİR KARARIN GEREKÇESİ BİR ÖN KOŞULA DAYANIYORSA, O ÖN KOŞUL DEĞİŞTİĞİNDE
> KARAR SESSİZCE GEREKÇESİZ KALIR.***

**② Çekirdek kapsamı KENDİ çiziyor.** *"Bu bir oturum-düzeyi kayıt"* diyerek
deneme-düzeyi veriyi **kendi işi saymıyor.** Bu, sorunun cevabına dair bir
işaret — ama hüküm değil, çünkü şema **beş app'i** bağlıyor.

---

## 3. İKİ SEÇENEK — ve her birinin BEDELİ

### (a) Çekirdeğe deneme-düzeyi kayıt eklenir

| ✅ | ⛔ |
|---|---|
| Tek şema, beş app aynı dili konuşur | **Beş app'i etkiler** — koordinatör hükmü şart |
| İleride aile-düzeyi kıyas/dışa aktarım mümkün | Çekirdek kendi kapsamını *"oturum-düzeyi"* diye çizmiş; genişletmek o kararı **geri almak** demek |
| Gravita/JabLab'ın da benzer ihtiyacı olabilir (**ölçülmedi — varsayım**) | Pin `f13bdc9` kırılır, dört hat senkron gerektirir |

### (b) Lissom kendi deneme-düzeyi defterini tutar

| ✅ | ⛔ |
|---|---|
| Kural ihlali YOK: çekirdek kodu kopyalanmaz, app mantığı çekirdeğe sızmaz | Aile bir gün ikinci bir çözüm bulursa **ayrışma** doğar |
| Çekirdeğin kendi cümlesi bunu işaret ediyor (*"attempt-level data"*) | İki depo, iki yaşam döngüsü — silme/göç/yedek iki yerde düşünülür |
| Lissom bugün başlayabilir, kimseyi beklemez | Kıyas ileride aile düzeyine taşınırsa **göç** gerekir |

**Hattın önerisi: (b)** — çekirdeğin kendi kapsam beyanına dayanarak, ve
ayrışma riskini **bilerek** kabul ederek. ⛔ Ama **başlatılmadı**; hüküm
koordinatörün.

---

## 4. (b) SEÇİLİRSE — şeklin taslağı

⚠️ Aşağısı **taslak**, sözleşme değil. Hüküm gelmeden tek satır kod yazılmaz.

```
AttemptRecord            // Lissom'a ait, çekirdeğe DOKUNMAZ
  lessonId               // SessionRecord ile AYNI anahtar (historyKeyFor)
  completedAt            // eşleştirme için
  value / unit           // ölçülen sayı — ürünün varlık sebebi
  bandLabel?             // varsa; UYDURULMAZ
  provenance             // model · config sürümü · kalibrasyon profili
```

**Neden `provenance` şart:** Progress'in kıyas kartı *"aynı model, uyumlu
config, benzer kamera kurulumu — üçü de saklanmıyor"* diyor. Bu üçü kaydedilirse
**kıyasın ÖN KOŞULU denetlenebilir** hâle gelir.
⛔ Bu **kıyası açmaz**: ikinci engel (MDC — *"bir okumanın kendiliğinden ne
kadar oynadığı"*) ölçüm-bilimi sorusudur ve **hattın yetkisinde değildir**;
eşik icat etmek bu ürünün varlık sebebine aykırıdır.
⇒ Kazanılacak somut şey: *"bu iki ölçüm **kıyaslanabilir değil**, çünkü config
sürümü değişmiş"* diyebilmek. **Dürüst bir HAYIR, sessiz bir belirsizlikten
iyidir.**

**Zorunlu kapılar (yazılmadan önce kararlaştırılır):**
1. `AttemptRecord` ile `SessionRecord` **aynı olayı** anlatır ⇒ sayıları
   birbirine karşı denetlenir (ayrışan iki defter, tek defterden kötüdür).
2. Değer yazılıyorsa **yüzeyde gösterilmeli**; yazılıp gösterilmeyen alan
   `L-178` sınıfıdır (okuyucusu olmayan config alanı).
3. Progress'in *"The reading itself is not kept"* kartı **aynı turda**
   güncellenmeli — yoksa `L-317` sınıfı bayat cümle üretilir. **Bu kez
   önceden biliyoruz.**

---

## 5. KARAR GEREKEN TEK SORU

> **Deneme-düzeyi ölçüm kaydı çekirdeğe mi (a), yoksa Lissom'a mı (b) yazılır?**

Hüküm `KOORDINATOR-HUKUMLERI.md`'ye düşerse hat aynı turda uygular.
Hüküm gelene kadar **hiçbir şey yazılmaz** ve Progress bugünkü dürüst hâlinde
kalır.
