# Video-düzeyinde envanter — Denge / Lunge / Rotasyon (05)

Not: WebFetch, YouTube'un JS-render eden `watch?v=` sayfalarında video oynatıcı metadata'sını
döndürmüyor (yalnız statik footer/nav HTML görünüyor). Bu yüzden her URL, YouTube'un resmi
**oembed** endpoint'i (`https://www.youtube.com/oembed?url=...&format=json`) ile doğrulandı —
bu endpoint gerçek video başlığını ve kanal adını (author_name) döndürür; URL uydurma veya
kırık link ihtimalini ekarte eder. **Süre ve kadraj bilgisi oembed'de yok** — bu alanlar
video sayfası görsel olarak izlenerek doğrulanmadığı için çoğu satırda "?" / "belirsiz"
işaretlendi (uydurulmadı). Kadraj doğrulaması ölçüm entegrasyonundan ÖNCE elle yapılmalı.

---

## Single-leg stance / single-leg balance test

**Durum:** ✅ ≥3 bağımsız eğitmen

| # | Kanal | Video başlığı | URL | Süre | Kadraj | Doğrulama |
|---|---|---|---|---|---|---|
| 1 | Physiotutors | What Single Leg Stance Assessment can tell you | https://www.youtube.com/watch?v=A9pi7_JRgwQ | ? | belirsiz — kadraj izlenerek doğrulanmadı | ✅ oembed: title+author eşleşti |
| 2 | Physiotutors | Single Leg Stance Test \| Gluteal Tendinopathy (GTPS) | https://www.youtube.com/watch?v=3vdJhti9tZE | ? | belirsiz — kadraj izlenerek doğrulanmadı | ✅ oembed: title+author eşleşti |
| 3 | Feldman Physical Therapy and Performance | Single Leg Balance Test | https://www.youtube.com/watch?v=KOWGQVDx_8o | ? | belirsiz — kadraj izlenerek doğrulanmadı | ✅ oembed: title+author eşleşti |
| 4 | Triumph Physio | Single leg balance test (Shorts) | https://www.youtube.com/shorts/U1kx6jys4FI | ? (Shorts, <60sn) | dikey format (Shorts) — tam vücut olasılığı yüksek ama doğrulanmadı | ✅ oembed: title+author eşleşti |

⚠️ Uyarı: #1 ve #2 aynı marka/kanal (Physiotutors) — kurucu kararındaki "≥3 BAĞIMSIZ eğitmen"
gerekçesi (aynalama + eğitmenler-arası varyans) göz önüne alınırsa, bu ikisinin AYNI kişi
(muhtemelen aynı sunucu — kanalın birden fazla fizyoterapisti var: Kai Sigel, Andreas Heck, Max
van der Velden, Ellen Vandyck, Kirsten Hoelandt) olup olmadığı video izlenerek TEYİT edilmeli.
Konsensüs/tolerans hesaplaması için #3 (Feldman PT) ve #4 (Triumph Physio) gerçekten bağımsız
kaynaklar — bu ikisi + Physiotutors'tan biri = güvenli 3'lü. Ek tarama önerilir: E3 Rehab'ın kendi
single-leg-stance test videosu aranırken yalnızca genel "single leg balance" egzersiz videoları
bulundu (test/assessment odaklı değil) — bu yüzden listeye alınmadı.

---

## Forward lunge assessment (diz valgus gözlemi dahil)

**Durum:** ✅ ≥3 bağımsız eğitmen — FMS "In-Line Lunge" testi bu hareketle birebir örtüşüyor
(dar taban, resiprokal kol-bacak pozisyonu; yaygın kompanzasyonlar: diz valgus, gövde rotasyonu,
topuk kalkması)

| # | Kanal | Video başlığı | URL | Süre | Kadraj | Doğrulama |
|---|---|---|---|---|---|---|
| 1 | TuricumFit GmbH (Fitness/Crossfit/Physiotherapie/Personal Training) | FMS In Line Lunge | https://www.youtube.com/watch?v=s2eE4XqTBcw | ? | belirsiz — kadraj izlenerek doğrulanmadı | ✅ oembed: title+author eşleşti |
| 2 | Conviction Training Facility | FMS - Inline Lunge | https://www.youtube.com/watch?v=iTBv9mmWNbU | ? | belirsiz — kadraj izlenerek doğrulanmadı | ✅ oembed: title+author eşleşti |
| 3 | MAT (Muscle Activation Techniques) | How to perform a Lunge Assessment using the MAT | https://www.youtube.com/watch?v=_Ybr_84CG18 | ? | belirsiz — kadraj izlenerek doğrulanmadı | ✅ oembed: title+author eşleşti |
| 4 | Testosterone Nation | Lunge Assessment | https://www.youtube.com/watch?v=kEpN9ES6wpg | ? | belirsiz — kadraj izlenerek doğrulanmadı | ✅ oembed: title+author eşleşti |

⚠️ Uyarı: Öncelikli kanal havuzundan (Physiotutors, E3 Rehab, Clinical Physio, Movement by David,
NASM/Brookbush, Emmet Louis, Tom Merrick) hiçbiri bu tur taramada bu spesifik hareket için
doğrulanabilir bir video vermedi:
- NASM'nin "Dynamic Postural Assessments: Knee Valgus/Knee Knocks" videosu (`9Nk9YtEIO9s`, oembed
  ile doğrulandı: NASM kanalı) bulundu ama içeriğin **forward lunge mi yoksa squat-bazlı bir
  değerlendirme mi** olduğu WebFetch ile teyit edilemedi (sayfa JS-render, açıklama metni
  alınamadı) — bu yüzden tabloya ALINMADI, ek tarama/manuel izleme gerekli.
- Brookbush Institute sonuçları "Lateral Lunge" ve "Transverse Plane Lunge" videolarına çıktı —
  bunlar forward/sagittal lunge DEĞİL, farklı düzlem hareketleri; hedefle eşleşmiyor.
- Weight-Bearing Lunge Test (WBLT/Knee-to-Wall Test, Physiotutors dahil çok kaynakta var) hedefle
  KARIŞTIRILMAMALI: bu ayak bileği dorsifleksiyon ROM testidir, diz valgus gözlemi amaçlı bir
  hareket kalitesi değerlendirmesi değildir — listeye alınmadı.

---

## Seated/quadruped thoracic rotation test (lumbar-locked pozisyon)

**Durum:** ✅ ≥3 bağımsız eğitmen

| # | Kanal | Video başlığı | URL | Süre | Kadraj | Doğrulama |
|---|---|---|---|---|---|---|
| 1 | Tom Merrick (Bodyweight Warrior) | Improve Your Spinal Rotation (Beginner To Advanced) | https://www.youtube.com/watch?v=MrmJeKHmOoY | ? | belirsiz — kadraj izlenerek doğrulanmadı | ✅ oembed: title+author eşleşti |
| 2 | Salmon Bay Physical Therapy | Thoracic Rotation Test | https://www.youtube.com/watch?v=2MUD8ioDsPk | ? | belirsiz — kadraj izlenerek doğrulanmadı | ✅ oembed: title+author eşleşti |
| 3 | HNL Movement \| Optimizing Human Performance | Quadruped Thoracic Rotation Tutorial | https://www.youtube.com/watch?v=mGtD0v5uOiQ | ? | belirsiz — kadraj izlenerek doğrulanmadı | ✅ oembed: title+author eşleşti |

⚠️ Uyarı: Klinik literatürde aranan spesifik protokol —"quadruped **lumbar-locked** position"
(kalça+lomber fleksiyonda maksimuma kilitlenip yalnız torasik rotasyonu izole eden versiyon,
IJSPT 2024 güvenilirlik makalesinde tarif edilen) — hiçbir bulunan videonun açıklamasında bu
spesifik "lumbar-locked" terimiyle teyit edilemedi (WebFetch video açıklamasını çekemedi). Videolar
genel "quadruped thoracic rotation" mobilite/germe egzersizi başlıklı; klinik ölçüm protokolüyle
bire bir örtüştüğü doğrulanmadı — manuel izleme ile teyit gerekli.
Öncelikli kanallardan yalnızca Tom Merrick doğrulandı; Physiotutors/E3 Rehab/Clinical Physio'nun
kendi quadruped thoracic rotation TEST (assessment, egzersiz değil) videosu bu turda bulunamadı —
E3 Rehab için bulunan tek "Thoracic Rotation Test" videosu aslında Salmon Bay Physical Therapy'ye
ait çıktı (arama sonucu başlığı yanıltıcıydı, oembed ile düzeltildi).

---

## Özet tablosu

| Hareket | Bulunan bağımsız eğitmen sayısı | Durum |
|---|---|---|
| Single-leg stance / balance test | 4 (2'si aynı marka olabilir, riski notlu) | ✅ |
| Forward lunge assessment (FMS in-line lunge) | 4 | ✅ |
| Seated/quadruped thoracic rotation test | 3 | ✅ |

---

## Açık kalanlar (≥3'e ulaşamayan hareketler + neden)

Üç hareketin de nominal olarak ✅ eşiğine ulaştığı görülüyor, ancak aşağıdaki açıklar duruyor:

1. **Single-leg stance:** #1 ve #2 aynı Physiotutors markası altında — gerçek bağımsız kişi sayısı
   video izlenmeden teyit edilemiyor (aynı sunucu olabilir). Etkili bağımsız sayı 3 değil 3-4
   arası belirsiz aralıkta. Öncelikli-kanal havuzundan E3 Rehab, Clinical Physio, Emmet Louis
   için doğrudan "test/assessment" formatında video bulunamadı (yalnızca genel egzersiz videoları
   çıktı) — ek arama gerekli.
2. **Forward lunge assessment:** Hiçbir öncelikli kanal (Physiotutors/E3 Rehab/Clinical
   Physio/Movement by David/NASM/Brookbush/Emmet Louis/Tom Merrick) bu turda doğrulanamadı;
   bulunan 4 kaynak öncelik-dışı ama gerçek (FMS sertifikalı klinikler + MAT + Testosterone
   Nation). NASM'nin olası videosu (`9Nk9YtEIO9s`) içerik itibariyle teyit edilemediği için
   dışarıda bırakıldı — bir sonraki turda bizzat izlenerek değerlendirilmeli.
3. **Thoracic rotation:** Bulunan 3 video "lumbar-locked" klinik protokolle bire bir eşleştiği
   teyit edilmeden genel "quadruped thoracic rotation" başlığı taşıyor; kurucunun özellikle
   vurguladığı lumbar-locked pozisyon farkı videolar izlenmeden doğrulanamadı.

## Uyarılar

- **Kadraj:** Bu turda HİÇBİR video için kadraj (sagittal/frontal/tam vücut/kesik) görsel olarak
  doğrulanamadı — WebFetch, YouTube video sayfasının oynatıcı/açıklama bölümünü çekemiyor (yalnız
  statik footer HTML dönüyor). **Ölçüm entegrasyonundan önce bu 11 video elle (tarayıcıda) açılıp
  kadraj + tam-vücut görünürlüğü tek tek teyit edilmeli.** Bu, envanterin en kritik açık maddesi.
- **Lisans:** Tüm videolar standart YouTube lisansı varsayılıyor (CC-BY olduğu sayfa üzerinde
  açıkça görülmedi) — hiçbiri CC olarak işaretlenmedi.
- **Aynalama riski:** Single-leg stance ve forward lunge testlerinde eğitmen genelde kameraya
  yan/ön duruyor ve "sol/sağ" yönü sözlü anlatıyor olabilir — bu ayna-yönü belirsizliği video
  izlenmeden çözülemez; N-eğitmen konsensüs yöntemi (kurucu kararındaki gerekçe a) tam olarak
  bunun için gerekli.
- **Physiotutors iç-bağımsızlık riski:** Single-leg stance kategorisindeki 2 Physiotutors videosu
  aynı kanaldan — kanalın 5 fizyoterapisti olduğu biliniyor ama bu 2 videoda kimin sunduğu teyit
  edilmedi; varyans-toleransı hesaplamasında bu ikisini TEK eğitmen gibi saymak daha güvenli.
- **Kapsam dışı bırakılanlar:** Weight-Bearing Lunge Test / Knee-to-Wall Test (ayak bileği ROM
  testi) ve Brookbush'un Lateral/Transverse Plane Lunge videoları hedef hareketle
  KARIŞTIRILMASIN diye bilerek listeye alınmadı — bunlar farklı ölçüm amaçlı/farklı düzlemde
  hareketler.
