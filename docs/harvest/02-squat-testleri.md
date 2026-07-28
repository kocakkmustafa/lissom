# Squat Testleri — Video-Düzeyinde Envanter

**Tarih:** 2026-07-26
**Yöntem:** WebSearch ile aday video bulundu → her URL `youtube.com/oembed` endpoint'i (resmi YouTube API,
gerçek video metadata'sı döner: `title` + `author_name`) ile doğrulandı. Uydurulan/erişilemeyen hiçbir URL
yazılmadı. Video süresi oembed'de dönmüyor — süre bulunamadığı için tüm satırlarda "?" yazıldı (UYDURULMADI).
Kadraj (sagittal/frontal/tam-vücut) hiçbiri için görsel doğrulama YAPILAMADI (WebFetch/oembed görsel içerik
döndürmüyor, yalnız metadata) — bu nedenle tüm kadraj hücreleri "doğrulanamadı" olarak işaretlendi. Bu ciddi
bir sınırlamadır, aşağıda "Uyarılar" bölümünde detaylandırıldı.

---

## Deep squat assessment / bodyweight squat screen

**Durum:** ✅ ≥3 bağımsız eğitmen/kanal (fakat kadraj doğrulanamadı — aşağıya bakın)

| # | Kanal | Video başlığı | URL | Süre | Kadraj | Doğrulama |
|---|---|---|---|---|---|---|
| 1 | Man Flow Yoga | Deep Squat Assessment | https://www.youtube.com/watch?v=TuQ4jYbazuw | ? | belirsiz (oembed metadata doğrulandı, görsel kadraj kontrol edilemedi) | ✅ oembed ile açıldı, başlık eşleşti |
| 2 | Hinge Health | How to Do a Deep Squat According to Physical Therapists | https://www.youtube.com/watch?v=IHApHfNA2Ag | ? | belirsiz | ✅ oembed ile açıldı, başlık eşleşti |
| 3 | Beam With Jim | How To Assess Your Squat | https://www.youtube.com/watch?v=YG-iGrQvw44 | ? | belirsiz | ✅ oembed ile açıldı, başlık eşleşti |
| 4 | PT Growth Academy | How to Master Your Squat Assessment | https://www.youtube.com/watch?v=o0knCTTMZHM | ? | belirsiz | ✅ oembed ile açıldı, başlık eşleşti |
| 5 | Testosterone Nation | Squat Assessment | https://www.youtube.com/watch?v=yWfMPZWHnVw | ? | belirsiz | ✅ oembed ile açıldı, başlık eşleşti |

**Not:** Öncelikli kanal havuzundan (Physiotutors, E3 Rehab, Clinical Physio) hiçbiri bu spesifik hareket için
video-düzeyinde bulunamadı — kanal genel sayfaları var ama tek bir "deep squat / bodyweight squat screen"
videosu tespit edilip doğrulanamadı. Yukarıdaki 5 kanal öncelik dışı ama bağımsız ve gerçek.

---

## Overhead squat assessment

**Durum:** ✅ ≥3 bağımsız eğitmen/kanal — öncelikli havuzdan 2 tanesi (Brookbush, NASM) dahil

| # | Kanal | Video başlığı | URL | Süre | Kadraj | Doğrulama |
|---|---|---|---|---|---|---|
| 1 | Brookbush Institute | Introduction to Overhead Squat Assessment | https://www.youtube.com/watch?v=9vmnmm7otao | ? | belirsiz | ✅ oembed ile açıldı, başlık eşleşti |
| 2 | NASM (resmi kanal) | How to Set Up an Overhead Squat Assessment | https://www.youtube.com/watch?v=ybBvcJ50UZ8 | ? | belirsiz | ✅ oembed ile açıldı, başlık eşleşti |
| 3 | The Axiom Personal Trainer Academy | NASM Overhead Squat Assessment | https://www.youtube.com/watch?v=z65p0Bc0T-Q | ? | belirsiz | ✅ oembed ile açıldı, başlık eşleşti |
| 4 | Precision Movement | Overhead Squat Assessment: 4 Areas to Assess | https://www.youtube.com/watch?v=LHZQF1vAjz4 | ? | belirsiz | ✅ oembed ile açıldı, başlık eşleşti |

**Dedupe notu:** NASM kanalının aynı konudaki ikinci videosu (`xpc2EIF9Pxw`, "Understanding the Overhead Squat
Assessment") ve Axiom'un ikinci videosu (`dtBvwmMpcRg`) BULUNDU+DOĞRULANDI ama aynı kanal olduğu için bağımsız
eğitmen sayısına eklenmedi (yalnız çeşitlilik/yedek olarak not düşülüyor).

---

## Heel-elevated vs flat squat comparison

**Durum:** ⚠️ 1-2 gerçek eğitmen (klinik/PT bağlamı zayıf, ek tarama gerekli)

| # | Kanal | Video başlığı | URL | Süre | Kadraj | Doğrulama |
|---|---|---|---|---|---|---|
| 1 | Morphfit Training Systems | Squat - Heels Elevated Vs. Flat | https://www.youtube.com/watch?v=YECk8R-rVU4 | ? | belirsiz | ✅ oembed ile açıldı, başlık eşleşti |
| 2 | nutritioneering | Flat Footed vs Heel Elevated Squats Comparison | https://www.youtube.com/watch?v=5LeCCGjKQso | ? | belirsiz | ✅ oembed ile açıldı, başlık eşleşti |
| 3 | Syracuse Fitness Center | Heel Elevated Squats \| Ankle Mobility | https://www.youtube.com/watch?v=MKY-feF0dDo | ? | belirsiz | ✅ oembed ile açıldı, başlık eşleşti — DOĞRUDAN karşılaştırma değil, tek-koşul (yalnız heel-elevated) içerik olabilir |

**Neden ⚠️:** Bu 3 kanalın hiçbiri klinik/PT öncelik havuzunda değil (genel fitness/kuvvet antrenörlüğü
kanalları). Ayrıca #3 başlığı "vs" karşılaştırması değil, yalnız heel-elevated odaklı görünüyor — video
içeriği (sagittal iki-koşul yan yana çekim var mı) doğrulanamadı, yalnız başlık/kanal metadata'sı doğrulandı.
Tom Merrick (öncelikli olmayan ama tanınmış mobilite koçu) kanalında ilgili ankle-mobility-for-squat videoları
bulundu (`fqWkZBBXFRo` "Squat Ankle Mobility Hack", `gVk6e7p7tTs` "Flexible Ankles = Deeper Squat") ancak bunlar
doğrudan "heel-elevated vs flat" karşılaştırması değil, genel ayak bileği mobilitesi içerikleri — bu listeye
dahil edilmedi çünkü hareket eşleşmesi net değildi.

---

## Özet tablosu

| Hareket | Bulunan bağımsız eğitmen/kanal sayısı | Durum |
|---|---|---|
| Deep squat assessment / bodyweight squat screen | 5 | ✅ |
| Overhead squat assessment | 4 | ✅ |
| Heel-elevated vs flat squat comparison | 3 (öncelik dışı, zayıf klinik bağlam) | ⚠️ |

## Açık kalanlar (≥3'e ulaşamayan hareketler + neden)

1. **Heel-elevated vs flat squat comparison** — sayısal olarak 3'e ulaşıyor ama (a) hiçbiri öncelikli
   klinik/PT kanal havuzundan değil, (b) hiçbirinin gerçekten "iki koşulu yan yana / art arda sagittal
   kadrajla karşılaştırdığı" görsel olarak doğrulanamadı (yalnız başlık doğrulandı, video içeriği izlenmedi).
   Physiotutors / E3 Rehab / Clinical Physio / Movement by David kanallarında bu spesifik karşılaştırma
   videosu aranmış ama bulunamamış — bu üç kanalın YouTube arşivi tek tek taranmalı (kanal içi arama ile,
   genel web araması bu düzeyde spesifik sonuç vermiyor).
2. Öncelikli 7 kanaldan yalnız **Brookbush Institute** ve **NASM** somut video-düzeyinde doğrulanabildi.
   Physiotutors, E3 Rehab, Clinical Physio, Movement by David, Emmet Louis, Tom Merrick için genel arama
   sonuç vermedi veya ilgisiz/tek taraflı içerik çıktı (örn. Tom Merrick'in ankle-mobility videoları hedef
   hareketle net eşleşmiyor). Bu kanalların kendi YouTube arama kutusunda ("channel:X squat assessment")
   taranması gerekiyor — bu ortamda kanal-içi arama yapılamadı, yalnız genel web arama motoru kullanıldı.

## Uyarılar

- **Kadraj sorunu (KRİTİK):** Bu envanterdeki HİÇBİR video için sagittal/frontal/tam-vücut kadraj görsel
  olarak doğrulanamadı. WebFetch/oembed yalnız metadata (başlık, kanal adı) döndürüyor, video karesini analiz
  edemiyor. Ölçüm için sagittal+tam-vücut şartı olduğundan, bu tablodaki her satır kullanılmadan ÖNCE video
  gerçekten izlenerek kadraj teyit edilmeli. Bu envanter yalnız "video var, başlık doğru, URL gerçek" seviyesinde
  bir doğrulamadır — kadraj/kullanılabilirlik doğrulaması AYRI bir adım olarak kalıyor.
- **Süre uydurulmadı:** oembed API süre alanı döndürmüyor; tüm satırlarda "?" bırakıldı.
- **Lisans:** Hiçbiri için CC-BY iddia edilmedi — hepsi "standart (varsayılan)" YouTube lisansı olarak kabul
  edilmeli.
- **Aynalama riski:** Hiçbir video için sol/sağ aynalama yönü doğrulanamadı (bu da görsel izleme gerektirir).
  Kurucunun kararındaki "N takede konsensüsle çöz" ilkesi uygulanmadan önce bu videoların gerçekten izlenmesi
  şart.
- **Genel kısıt:** Bu tur yalnız metin-tabanlı web araması + oembed metadata doğrulaması ile yapıldı; hiçbir
  video gerçek anlamda izlenmedi. Bir sonraki adım: bu listedeki URL'leri tarayıcıda açıp (1) kadraj, (2) süre,
  (3) aynalama yönü, (4) tam vücut görünürlüğü kontrol edilmeli.
