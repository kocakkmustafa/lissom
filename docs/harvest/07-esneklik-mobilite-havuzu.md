# 07 — Esneklik & Mobilite Havuzu: Eğitmen Video Envanteri

**Yöntem notu (dürüstlük için önemli):** Genel web araması (WebSearch) YouTube video başlıklarını
bulmakta güvenilir ama **kanal atfını sık sık YANLIŞ veriyor** (ör. bir sonucu "Physiotutors" diye
özetledi, gerçekte kanal "Physical Therapy & Hand Clinic of Hillsboro" çıktı). Bu yüzden her URL,
YouTube'un `oembed` uç noktası (`youtube.com/oembed?url=...&format=json`) ile açılıp **gerçek
`author_name` alanı** okunarak doğrulandı. Yalnızca bu şekilde teyit edilen satırlar aşağıda yer
alıyor. Kanalı teyit edilemeyen veya öncelik listesindeki kanallardan çıkmayan adaylar YAZILMADI.

**Sonuç:** Öncelik havuzundaki (Physiotutors, E3 Rehab, Clinical Physio, Movement by David, NASM,
Brookbush, Emmet Louis, Tom Merrick) kanallardan **video-düzeyinde tek bir doğrulanmış eşleşme
bulunamadı** — genel web araması bu kanalların spesifik video URL'lerini güvenilir şekilde yüzeye
çıkaramadı (YouTube'un kendi arama/kanal sayfaları JS ile render edildiği için WebFetch içeriği
görbet çıkmıyor, yalnızca sayfa başlığı/footer geliyor). Bulunan ve doğrulanan videolar bunun yerine
**farklı, gerçek ve doğrulanmış** kanallardan — ancak hiçbiri hedef 3-eğitmen eşiğine ulaşmıyor.

Bu envanter dolayısıyla **iskelet/format** ve **doğrulanmış-ama-yetersiz** bir başlangıç niteliğinde;
hareket başına ≥3 bağımsız eğitmen hedefine ulaşmak için kanal-bazlı doğrudan tarama (her kanalın
kendi YouTube "video" sekmesinde manuel arama, ya da YouTube Data API ile programatik arama) gerekiyor
— bu oturumda mevcut değildi.

---

## standing calf stretch (wall lean)
**Durum:** ❌ bulunamadı (doğrulanmış video yok)

Arama çok sayıda "wall calf stretch" videosu döndürdü ama hiçbirinin kanalı oembed ile teyit edilmedi
(zaman bütçesi nedeniyle bu hareket için doğrulama turu tamamlanamadı).

## ankle circles
**Durum:** ⚠️ 1 eğitmen (öncelik listesi DIŞI)

| # | Kanal | Video başlığı | URL | Süre | Kadraj | Doğrulama |
|---|---|---|---|---|---|---|
| 1 | Different Strokes UK | Rehab Reset Ankle Circles – Increase Ankle Mobility & Improve Walking Balance - Without Music | https://www.youtube.com/watch?v=rQ-EWPDUSNI | ? | belirsiz (WebFetch video içeriğini göremedi, yalnız başlık teyit edildi) | ✅ oembed ile açıldı, author_name="Different Strokes UK" teyit edildi |

## wall ankle rock
**Durum:** ❌ bulunamadı

## 90/90 hip switch
**Durum:** ⚠️ 1 eğitmen (öncelik listesi DIŞI — Tom Merrick aranan ama bu video onun DEĞİL)

| # | Kanal | Video başlığı | URL | Süre | Kadraj | Doğrulama |
|---|---|---|---|---|---|---|
| 1 | Simone Sports Performance | 90/90 Hip Switch (Improve Hip Health & Mobility) | https://www.youtube.com/watch?v=qq_Z7sAmVrA | ? | belirsiz | ✅ oembed ile açıldı, author_name teyit edildi |

⚠️ Not: WebSearch bu videoyu ilk aramada "Tom Merrick'e ait olabilir" diye ima etmişti — oembed
doğrulaması bunun YANLIŞ olduğunu gösterdi. Tom Merrick'in kendi 90/90 videosu bulunamadı.

## half-kneeling hip flexor stretch
**Durum:** ⚠️ 2-3 aday (kısmen öncelik listesinden — E3 Rehab var, ama videolar dar-anlamda "stretch
demosu" değil, daha geniş "hip flexor rehab/assessment" içerikleri; tek hareketin izole gösterimi
olarak KULLANILABİLİR mi ayrıca değerlendirilmeli)

| # | Kanal | Video başlığı | URL | Süre | Kadraj | Doğrulama |
|---|---|---|---|---|---|---|
| 1 | E3 Rehab | Tight Hip Flexors? (Self-Assessment \| Stretches \| Exercises) | https://www.youtube.com/watch?v=iQnNn67aAeg | ? | belirsiz — video geniş kapsamlı (assessment+stretch+exercise), tek hareket için kesip kullanmak gerekir | ✅ oembed, author_name="E3 Rehab" teyit edildi |
| 2 | E3 Rehab | Hip Flexor Pain \| Strain \| Tendinitis \| Tendinopathy Rehab (Iliopsoas Strength & Mobility Exercises) | https://www.youtube.com/watch?v=Ujf2h0WWryw | ? | belirsiz — rehab programı videosu, stretch tek segment | ✅ oembed, author_name="E3 Rehab" teyit edildi |
| 3 | Live Lean TV Daily Exercises | How To: Half Kneeling Hip Flexor Stretch | https://www.youtube.com/watch?v=Bfb-9dIWEr4 | ? | belirsiz | ✅ oembed, author_name teyit edildi |

⚠️ E3 Rehab'ın iki videosu AYNI KANAL — bağımsız eğitmen sayısı olarak yalnızca **1** sayılmalı (E3 Rehab
kurucuları aynı klinik ekip). Yani gerçek bağımsız eğitmen sayısı 2 (E3 Rehab + Live Lean TV), 3 eşiğine
ULAŞMIYOR.

## figure-4 glute stretch
**Durum:** ❌ bulunamadı (aday videolar bulundu ama hiçbiri oembed ile doğrulanmadı; zaman bütçesi tükendi)

## deep squat hold
**Durum:** ❌ bulunamadı (NASM/Brookbush'tan spesifik video tespit edilemedi)

## cat-cow
**Durum:** ❌ bulunamadı (Movement by David'in kendi videosu tespit edilemedi)

## open-book / thoracic rotation reach
**Durum:** ⚠️ 1 eğitmen (öncelik listesi DIŞI)

| # | Kanal | Video başlığı | URL | Süre | Kadraj | Doğrulama |
|---|---|---|---|---|---|---|
| 1 | Peak Functional | How to Do T-Spine Rotation (Open Book) \| Thoracic Mobility & Postural Reset | https://www.youtube.com/watch?v=5TdmVlQe64c | ? | belirsiz | ✅ oembed, author_name teyit edildi |

## thread the needle
**Durum:** ⚠️ 1 eğitmen (öncelik listesi DIŞI)

| # | Kanal | Video başlığı | URL | Süre | Kadraj | Doğrulama |
|---|---|---|---|---|---|---|
| 1 | Elite Performance Institute | Thread The Needle For Thoracic Rotation | https://www.youtube.com/watch?v=7C8-zj3nRro | ? | belirsiz | ✅ oembed, author_name teyit edildi |

## cross-body shoulder stretch
**Durum:** ❌ bulunamadı. Bir aday ("Cross Body Adduction / Posterior Capsule Stretch") WebSearch
tarafından yanlışlıkla Physiotutors'a atfedildi; oembed doğrulaması gerçek kanalın
**"Physical Therapy & Hand Clinic of Hillsboro"** olduğunu gösterdi — bu yüzden yazılmadı (öncelik
listesi dışı VE tek örnek, eşik altı).

## overhead triceps-lat stretch
**Durum:** ❌ bulunamadı

## wall pec stretch
**Durum:** ❌ bulunamadı

## standing hamstring stretch
**Durum:** ❌ bulunamadı

## inverted-V (downward-dog benzeri)
**Durum:** ❌ bulunamadı

## glute bridge
**Durum:** ❌ bulunamadı. İki aday video ("ACL Rehab Phase 3 – Glute bridge single leg / Feet Elevated
Glute Bridge") WebSearch tarafından E3 Rehab'a ait sanılmıştı; oembed doğrulaması gerçek kanalın
**"Professeur Étienne Cavaignac"** olduğunu gösterdi — E3 Rehab DEĞİL. Yazılmadı.

## bird-dog
**Durum:** ❌ bulunamadı

## standing side bend
**Durum:** ❌ bulunamadı

## lateral lunge
**Durum:** ❌ bulunamadı

## side plank
**Durum:** ❌ bulunamadı. Aday video ("ACL Rehab Phase 3 – Side plank") de aynı şekilde
"Professeur Étienne Cavaignac" kanalına ait çıktı, E3 Rehab değil — yazılmadı.

---

## Özet tablosu

| Hareket | Bulunan bağımsız eğitmen (doğrulanmış) | Durum |
|---|---|---|
| Standing calf stretch (wall lean) | 0 | ❌ |
| Ankle circles | 1 | ⚠️ |
| Wall ankle rock | 0 | ❌ |
| 90/90 hip switch | 1 | ⚠️ |
| Half-kneeling hip flexor stretch | 2 | ⚠️ |
| Figure-4 glute stretch | 0 | ❌ |
| Deep squat hold | 0 | ❌ |
| Cat-cow | 0 | ❌ |
| Open-book / thoracic rotation reach | 1 | ⚠️ |
| Thread the needle | 1 | ⚠️ |
| Cross-body shoulder stretch | 0 | ❌ |
| Overhead triceps-lat stretch | 0 | ❌ |
| Wall pec stretch | 0 | ❌ |
| Standing hamstring stretch | 0 | ❌ |
| Inverted-V | 0 | ❌ |
| Glute bridge | 0 | ❌ |
| Bird-dog | 0 | ❌ |
| Standing side bend | 0 | ❌ |
| Lateral lunge | 0 | ❌ |
| Side plank | 0 | ❌ |

**18 hareketin 0'ı ≥3 bağımsız eğitmen eşiğine ulaştı.**

## Açık kalanlar (≥3'e ulaşamayan hareketler + neden)

Tüm 18 hareket eşik altı. Kök neden — yöntemsel, hareket-spesifik değil:

1. **Genel WebSearch, öncelik kanallarının (Physiotutors, E3 Rehab, Clinical Physio, Movement by
   David, NASM, Brookbush, Emmet Louis, Tom Merrick) spesifik video URL'lerini güvenilir şekilde
   yüzeye çıkarmadı.** Arama sonuçları çoğunlukla üçüncü taraf kanallardan (klinikler, bireysel PT'ler)
   geldi; öncelik kanallarının adı sonuç başlıklarında geçse bile bu genelde WebSearch'ün kendi
   özetleme hatasıydı (ör. "Physiotutors" ve "E3 Rehab" diye sunulan 3 video, oembed doğrulamasında
   FARKLI kanallar çıktı: "Physical Therapy & Hand Clinic of Hillsboro" ve "Professeur Étienne
   Cavaignac").
2. **YouTube kanal/arama sayfaları WebFetch ile açıldığında JS-render edilmiş içerik döndürmüyor**
   (yalnız footer/nav geliyor) — bu yüzden "kanalın kendi arşivinde ara" yaklaşımı bu araç setiyle
   çalışmadı. Doğru araç: YouTube Data API (arama+videos.list, `channelId` filtresiyle) veya kanal
   başına manuel tarayıcı gezintisi.
3. Zaman/tur bütçesi, her hareket için onlarca aday URL'yi tek tek oembed ile doğrulamaya yetmedi —
   yalnızca ilk birkaç yüksek-olasılıklı aday test edildi.

## Uyarılar

- **En kritik uyarı:** Bu oturumda WebSearch'ün kanal atıfları en az 3 kez YANLIŞ çıktı (Tom Merrick,
  Physiotutors, E3 Rehab iddiaları — hepsi oembed'de çürütüldü). Gelecekteki taramalarda **kanal adı
  WebSearch özetinde geçiyor diye asla güvenilmemeli**; her satır oembed veya doğrudan video sayfası
  ile ayrıca doğrulanmalı.
- Kadraj bilgisi bu turda HİÇBİR video için netleştirilemedi — WebFetch, YouTube video sayfalarından
  video oynatıcı/açıklama içeriğini çekemiyor (yalnızca oembed başlık+kanal veriyor, süre/kadraj vermiyor).
  Bu alan tüm satırlarda "?" / "belirsiz" — gerçek kadraj+süre bilgisi için video fiilen izlenmeli
  (tarayıcı ile).
- Lisans: hiçbiri CC-BY olarak doğrulanmadı → hepsi "standart (varsayılan)" kabul edilmeli.
- **Önerilen sonraki adım:** Bu envanteri tamamlamak için YouTube Data API erişimi (arama
  `channelId=` filtresiyle öncelik kanallarının video listesi) veya bir tarayıcı-otomasyon aracıyla
  (Chrome MCP gibi) her öncelik kanalının "Videos" sekmesinde canlı arama yapılması gerekiyor —
  bu görev tanımında "keşif yasak / repo tarama yok" kısıtı vardı ama web-tarama araçları da
  YouTube'un JS-ağırlıklı arayüzünde kanal-bazlı filtreleme için yetersiz kaldı.
