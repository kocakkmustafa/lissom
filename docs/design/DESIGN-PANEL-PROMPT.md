# Lissom — Claude Design Paneli Promptu (v1, 2026-08-05)

> Koordinatör hazırladı, **kurucu onayı sonrası** panele verilir.
> Kaynak: kurucu tasarım yönü (M-F-282, *"biraz daha pastel"*) + 2 referans görsel
> + ölçülmüş yüzey envanteri (`UI-BRIEF.md`, motorla birebir).
> §5 ve §8'deki kısıtlar **estetik tercih değil** — CI ve testler zorluyor.

---

## 0. Ne tasarlıyorsun

**Lissom** — telefon kamerasıyla **hareket kapasitesini gerçekten ölçen** bir wellness
uygulaması. Kullanıcı telefonu karşısına koyar, 12 hareket testinden geçer; uygulama
açıyı/erişimi ölçer ve **ölçemediğinde ölçemediğini söyler.**

**Konumlandırma cümlesi — tasarımın taşıması gereken fikir:**
> **"We show you measurements, not marks."**

Rakip (GOWOD) kullanıcıya kendi mobilitesini **slider'la puanlatıyor**. Lissom gerçekten
ölçüyor. Bu ürünün tek satırlık farkı ve tasarım bunu görünür kılmalı.

**Karakter:** sakin, ölçülü, **yetişkin**. Neşeli spor koçu DEĞİL. Ünlem yok, tezahürat
yok, streak baskısı yok. *"Yaklaşık"*, *"tahmini"*, *"ölçemedim"* demeye istekli bir ton.

**Ton örneği (bağlayıcı):**
> ✅ *"Your reach measured 50°. That's your starting point — we'll track it from here."*
> ⛔ *"Poor mobility detected."*

---

## 1. Görsel yön (kurucu + referanslar)

> **⚠️ Referanslar nasıl okunacak — kurucu talimatı:** iki görsel **yalnız RENK PALETİ ve
> KART YERLEŞİMİ** için gönderildi. **Kopyalanmayacaklar.** Referans-1 bir mindfulness/müzik
> uygulaması — ekran kompozisyonu (çalma listesi, mood istatistiği, oynatıcı) bizim
> ürünümüzle **ilgisiz**. Ondan alınacak olan **renk dili ve kartların yerleşim
> mantığı**dır; ekranların kendisi değil.
> **Tasarım bizim yüzeyimize göre kurulur** (§2-§6): 12 testlik değerlendirme akışı, dört
> katmanlı sonuç ekranı, dürüst hâller. Referansa uyacak diye yapımızı eğme — gerektiğinde
> referanstan **serbestçe ayrıl**.

**Referans-1 (Serenity Waves / mindfulness):** yumuşak mor-gül gradyanlar · zarif
**serif** başlık tipografisi · yuvarlak köşeli, hafif açılı fotoğraf kartları · hap
biçimli filtre çipleri · bol nefes alanı.
→ **AL:** gradyan dili, serif başlık, kart yumuşaklığı, sakinlik, boşluk cömertliği.
→ **ALMA:** kalp şeklindeki %88 göstergesi · *"Keep going!"* · *"Statistics up 15%"* ·
mood halkası. (Gerekçe §8.)

**Referans-2 (soft-3D / kil dokusu kiti):** pastel şeftali-mavi-krem paleti · mat, yumuşak
3B kil formları · çok yumuşak gölge · organik/akışkan şekiller · katmanlı kartlar.
→ **AL:** palet, mat 3B doku, yumuşak gölge, organik form dili, katmanlanma.
→ **DİKKAT:** o kitteki halka/donut grafikler ölçüm göstergesi olarak kullanılamaz (§8.1).

**Sentez:** iki referansın kesişimi = **açık, pastel, mat, yumuşak, nefes alan.**
Serif başlık + yumuşak sans gövde. Yuvarlak ve organik biçim dili. Gölgeler dağınık ve
yumuşak, keskin kenar yok. Hareket **yavaş ve süzülen**.

### ⚠️ Kardeşlerden ayrışma (bağlayıcı)

Bu tasarım 4 kardeş uygulamayla **aynı elden çıkmış görünmemeli.** JabLab az önce
tasarlandı: **koyu · kırmızı · yüksek kontrast · sıkı yoğunluk · keskin-hızlı hareket ·
ağır geniş tipografi.** Lissom onun **tam karşıtı** olmalı:

| Eksen | JabLab | **Lissom** |
|---|---|---|
| Zemin | koyu, cam | **açık, pastel, mat** |
| Kontrast | yüksek | **düşük, yumuşak** |
| Tipografi | ağır, geniş, sans | **zarif serif başlık + yumuşak sans** |
| Biçim | keskin cam kenar | **yuvarlak, organik, kil** |
| Yoğunluk | sıkı | **bol boşluklu** |
| Hareket | keskin, hızlı | **yavaş, süzülen** |

**Palet dışında en az 3 eksende ayrışmayan çıktı "tek elden re-skin"dir ve reddedilir.**

---

## 2. Sayfa yapısı

Dört ana sekme (IA config'ten gelir, ürün yapısıdır) + içine gömülü değerlendirme sihirbazı.

### `home`
Dört bölüm: **today** (günün planı) · **retest countdown** · **continue** · **quick start**.

> **`retest countdown` — HÜKÜM: bu bir DAVET, geri sayım değil.**
> Sakin kart: *"next re-assessment: X days"*. ⛔ Tık-tak saat, kırmızı aciliyet, yanıp
> sönen sayaç **YASAK**. Vakti gelince birincil eyleme yükselir. **Geciktiğinde ASLA
> suçlamaz** — *"kaçırdın"* yok; ton *"hazır olduğunda"*.

### `library`
Altı aile: **assessment battery** (aktif) + 5 tanesi henüz yok (yoga styles · flexibility
goals · population packs · family warmups · breath meditation).

> **HÜKÜM — tam genişlik, katmanlı:** aktif dalga **birinci sınıf** yerleşim; henüz
> gelmemiş aileler **görsel olarak ayrı, kompakt** bir bölümde, her biri **dürüst tek
> satırlık durumla**. ⛔ Ayrı yol-haritası sayfası **YASAK** (genişliği saklar).
> ⛔ Eşit ağırlıkta listeleme **YASAK** (sahte doluluk üretir).

Arama zorunlu; filtreler: level / duration / equipment / region.
Her aile sayfasında **honesty box** — *ne ölçülür / ne ölçülmez*. Opsiyonel değil.

### `progress`
Kendine-göre trend. ⛔ **Karşılaştırma iddiası bugün KAPALI:** iki ölçüm ancak aynı model
sürümü ve uyumlu kalibrasyonda kıyaslanır; tutmuyorsa kıyas **yapılmaz** ve sebebi yazılır.
**`improved` / `worsened` dili YOK.** Bu "eksik ekran" değil — **tasarlanmış bir hâl**.

### `profile`
Ayarlar · *"How measurement works"* · **"What Lissom doesn't do"** — 5 kalem, her biri
gerekçeli (çocuk programı · nefes ölçümü · klinik tarama · hot yoga · kalça rotasyonu).

> Bu sayfa **bir özellik, bir özür değil.** Duruş tonunda tasarla — rakiplerin sustuğu
> yerde konuşan ürün olduğumuzu burası anlatıyor.

---

## 3. Değerlendirme akışı — ürünün kalbi

**Oturum BLOKLARDAN oluşur:** `standing` (8 test) → `floor` (4 test). Her blok **tek
kalibrasyon penceresi**; bloklar arası kamera yeniden konumlanır.

Test başına: **talimat → kalibrasyon kontrolü → canlı tur → sonuç.**

| Ekran | Kritik davranış |
|---|---|
| **Block intro** | Hangi blok, kaç test, kamera nereye |
| Test instruction | Talimat + hangi tarafla başlanacağı |
| **Calibration check** | **SERT KAPI** — geçmezse ölçüm başlamaz; dürüst ret + ne düzeltilecek (mesafe/açı/ışık) |
| **Live capture** | İskelet overlay · sesli yönlendirme · anlık uyarılar (*"keep the elbow straight"*) |
| **Attempt result** | §4'teki **dört katman** |
| **Block complete** | *"bu bloğun ölçümleri kaydedildi"* — burada bırakılabilir |
| Battery summary | 12 testin tablosu; ölçülemeyenler **isimle ve sebebiyle** |

> ⛔ **Yarım kalan oturumda "hiçbir şey kaydedilmedi" DENMEZ.** Tamamlanan blokların
> ölçümleri korunur ve Block complete ekranı bu sözü verir.

**Tekrar kuralı:** 3 deneme de geçersizse test *"not measured"* olarak kapanır ve kullanıcı
ilerler. **Tahmin edilmez, boş bırakılır.**

---

## 4. ⭐ Sonuç ekranı — DÖRT KATMAN (tasarımın en önemli parçası)

Motor dört farklı durum üretir ve **dördü de görsel olarak farklı olmalı.**

| Katman | Kullanıcı ne görür | Ton |
|---|---|---|
| **scored** | Değer + bant etiketi (low/normal/good) + bandın anlamı | nötr-bilgilendirici |
| **measured below range** | **Değer + "başlangıç noktan bu" anlatısı. Bant etiketi YOK** — bandın altındaki değere bant adı vermek, ölçmediğimiz bir sınıflandırmayı iddia etmek olurdu | **KOÇLANAN**, skorlanan değil |
| **measured, no bands** | Değer + *"bu test için sayısal norm yok, nitel seviye kullanıyoruz"* | dürüst-sınırlı |
| **not measured** | **Sebep İSİMLİ** + ne yapması gerektiği | **suçlayıcı DEĞİL** |

**`not measured` altı ayrı sebep taşır** ve her biri kendi metnini ister:
kimse denemedi · kurulum zaman aşımı · **ölçüm zaman aşımı (bu durumda değer VAR ve
gösterilir)** · iptal (dirsek büküldü / topuk kalktı…) · takip kaybı · düşük güven.

> 🔴 **İsimli tasarım tuzağı — bu ürünün geçmişte yaptığı en büyük hata:**
> eşiğin altında kalan kullanıcı eskiden **hiçbir şey görmüyordu** — ne ölçüm, ne sebep.
> Donmuş omuzla 50°'ye ulaşan biri **boş ekran** görüyordu; oysa uygulamanın var olma
> sebebi tam olarak o kişi. **Dört katman ayırt edilmezse hata geri gelir.**

Her sonuç ekranında ölçüm sınırı beyanı küçük puntoyla **kalıcı** durur.

---

## 5. "Measurements, not marks" — iki test referanssız yaşıyor

`overhead_reach` ve `deep_squat` **ölçülüyor ama norm kıyası yok.** Bu saklanmıyor,
**yüzeye taşınıyor**:

- **test sonucunda:** değer + sebep metni (sönük, ikincil)
- **batarya özetinde:** bu ikisi *"measured"* olarak; **bant/skor sütunu BOŞ** ve sebebi
  tıklanabilir
- **kütüphanede:** honesty box içinde — ne ölçülür / neden referans yok / **neyin açacağı**
- **progress'te:** trendleri **gösterilir** (kendine-göre), norm kıyası yok

**Terfi yolu görünür olmalı:** kullanıcı *"bu neden böyle ve değişecek mi?"* sorusunun
cevabını bulabilmeli — kapalı bir kapı değil, **adı olan bekleyen bir iş**.

⛔ **Bu iki testi "coming soon" ya da "beta" diye göstermek YASAK.** Ölçüm **çalışıyor** ve
değer **gerçek**; eksik olan yalnız referans kıyası.

---

## 6. Ağrı akışı

Kullanıcı rahatsızlık bildirdiğinde: uyarı metni + o günün rutini **yumuşatılır**.
**Tıbbi yorum YOK**; *"sebebini söyleyemeyiz"* açıkça yazılı.
Bu akış **her canlı-tur ekranından** erişilebilir olmalı — tasarımda yeri olsun.

---

## 7. Hareket ve geçişler

- Geçişler **yavaş, süzülen, yumuşak** — JabLab'ın keskin/hızlı dilinin karşıtı.
- Gradyanlar hafifçe canlı olabilir (yavaş kayan, nefes alan).
- Kalibrasyon geçtiğinde: **sakin bir onay**, kutlama değil.
- Ölçüm sonucu belirirken: değer **yumuşakça yerleşsin**, sayaç-fırlatma efekti yok.
- Blok tamamlandığında: huzur verici bir kapanış anı — konfeti/rozet **yok**.
- Referans-2'nin mat 3B formları geçiş öğesi olarak kullanılabilir.

---

## 8. ⛔ ASLA — testler ve CI bunları zorluyor

Referans-1'de bunların bir kısmı **var**; bilerek çıkarıldılar.

1. **Ölçüm için DOLUM/GAUGE göstergesi YASAK.** Kalp şeklindeki %88, dolum çubuğu,
   ilerleme halkası, hedefe-uzaklık göstergesi — hiçbiri.
   *Gerekçe:* 50°'de neredeyse boş bir çubuk, **sayıyla değil grafikle söylenmiş bir
   "yetersizsin" hükmüdür.** Bant bilgisi **sönük detay metni** olabilir, **gösterge asla**.
2. **"Keep going!" sınıfı tezahürat ve ünlem YASAK.** Neşeli spor-koç tonu değil.
3. **"Statistics up 15%" / improved / worsened YASAK** — karşılaştırma iddiası bugün kapalı.
4. **Mood/duygu takibi YOK** — böyle bir özellik yok, ekranda da olmaz.
5. **TIBBİ DİL YASAK** — CI'da taranıyor (`wellness_lint.py`). *"Poor mobility detected"*,
   "postüral bozukluk", "tanı", "tedavi" — hiçbiri.
6. **Çıplak skor YASAK** — sayının yanında **daima sınırı** durur.
7. **Streak / rekor / rozet baskısı YASAK.**
8. **Geri sayım estetiği YASAK** ve gecikme **asla suçlanmaz**.
9. **Bandın altındaki değere bant etiketi verilmez.**
10. **Yarım oturumda "hiçbir şey kaydedilmedi" denmez.**
11. **Ayrı yol-haritası sayfası ve eşit-ağırlık listeleme YASAK.**
12. **Kesinlik taklidi / sahte hassasiyet YASAK** — ölçemediğini ölçmüş gibi gösterme.

---

## 9. Zorunlu hâller (tasarlanmadıysa eksik sayılır)

**boş** (henüz ölçüm yok — "veri yok" ≠ hata) · **yükleniyor** (ilk model yüklemesi uzun
sürebilir) · **hata** (teknik jargon YOK) · **izin reddi** (⚠️ uygulama **çalışmaya devam
eder**: kütüphane ve why-not gezilebilir, yalnız ölçüm kapalı) · **kalibrasyon geçmedi** ·
**ölçüm alınamadı** (6 sebebin her biri ayrı) · **karşılaştırma kapalı** · **düşük ışık /
kadraj dışı** (anlık, engelleyici değil ama görünür).

---

## 10. Teslim

- 4 sekme + değerlendirme sihirbazının tüm adımları
- **Sonuç ekranının dört katmanı ayrı ayrı** (en kritik teslim kalemi)
- `not measured` altı sebebinin görsel çözümü
- Zorunlu hâllerin tamamı (§9)
- "What Lissom doesn't do" sayfası
- Geçiş animasyonlarının tarifi
- Palet, tipografi ölçeği, gölge/biçim spesifikasyonu
- **Arayüz metinleri İNGİLİZCE**

---

*Bağlayıcı kaynak: `docs/design/UI-BRIEF.md` §5 (M-F-133 hükümleri) · M-F-71 (dört katman) ·
M-F-185 (measurements-not-marks) · K8 · `tools/wellness_lint.py` · M-F-282 (kurucu yönü).*
