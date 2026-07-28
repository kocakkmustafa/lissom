# Omuz Testleri — Video Envanteri (Lissom skorlama referansı)

**Tarih:** 2026-07-26
**Yöntem notu:** Her URL, YouTube oEmbed API'si (`https://www.youtube.com/oembed?url=...`) ile canlı
sorgulanarak var olduğu ve gerçek kanal adı (`author_name`) doğrulandı; ayrıca video sayfası HTML'inden
(`lengthSeconds`) gerçek süre çekildi. Bu iki kaynak da YouTube'un kendi sunucusundan geldiği için
uydurma URL riski taşımaz. **ANCAK:** video içeriği kare kare İZLENMEDİ (bu ortamda video oynatma aracı
yok) — kadraj (sagittal/frontal/tam vücut) bilgisi yalnızca video açıklamasında (description) açıkça
yazılıysa verildi, aksi halde **"belirsiz — izlenmeli"** olarak işaretlendi. Ölçüm hattına dahil etmeden
önce her video insan gözüyle kare-kare izlenip kadraj + aynalama yönü teyit edilmelidir.

---

## Overhead Reach / Shoulder Flexion Assessment

**Durum:** ✅ ≥3 bağımsız eğitmen (kadraj teyidi bekliyor)

| # | Kanal | Video başlığı | URL | Süre | Kadraj | Doğrulama |
|---|---|---|---|---|---|---|
| 1 | Clinical Physio (Premium) | Shoulder Full Assessment Run Through \| Clinical Physio Premium | https://www.youtube.com/watch?v=E3Eu0F73ROI | 5:32 | belirsiz — izlenmeli | ✅ oEmbed: author_name="Clinical Physio", başlık eşleşti; lengthSeconds=332 sayfadan doğrulandı |
| 2 | Jungle Botany (konuk: Emmet Louis) | How Flexible Are You? 4 Simple Tests With Emmet Louis | https://www.youtube.com/watch?v=PfpJnU8x1kU | 4:57 | belirsiz — izlenmeli | ✅ oEmbed: author_name="Jungle Botany", başlıkta "Emmet Louis" açıkça geçiyor (konuk eğitmen); lengthSeconds=297 |
| 3 | Mobility Doc | Master the FMS Shoulder Mobility Test: Unlock Better Performance and Prevent Injuries | https://www.youtube.com/watch?v=HVQ1YNtw_yQ | 2:45 | belirsiz — izlenmeli | ✅ oEmbed: author_name="Mobility Doc", başlık eşleşti; lengthSeconds=165 |
| 4 | ACE Fitness | Shoulder Mobility Assessment | https://www.youtube.com/watch?v=GL6kBBMtWkY | 4:58 | belirsiz — izlenmeli | ✅ oEmbed: author_name="ACEfitness", başlık eşleşti; lengthSeconds=298 |

⚠️ İçerik uyarısı: #3 (FMS Shoulder Mobility Test) klasik FMS testi tek elin baş üstünden sırta, diğerinin
belden sırta uzanmasını ölçen **kompozit bir test** — saf "overhead reach" değil, ilgili ama farklı bir
ölçüm. #1 genel bir "tam omuz muayenesi" videosu, yalnızca fleksiyon kısmı bu hareketle örtüşüyor
(video içinde ilgili segment zaman damgasıyla bulunmalı). Öncelikli kanallardan (Physiotutors, E3 Rehab,
NASM/Brookbush, Tom Merrick) doğrudan "overhead reach / shoulder flexion assessment" videosu bulunamadı —
kanal sayfalarında var olabilir ama video-düzeyinde URL doğrulanamadı (bkz. Açık kalanlar).

---

## Shoulder Mobility Screen (genel, ekipmansız)

**Durum:** ✅ ≥3 bağımsız eğitmen (kadraj teyidi bekliyor)

| # | Kanal | Video başlığı | URL | Süre | Kadraj | Doğrulama |
|---|---|---|---|---|---|---|
| 1 | Clinical Physio (Premium) | Shoulder Observation \| Clinical Physio Premium | https://www.youtube.com/watch?v=2ejiBQ3mxQU | 15:05 | belirsiz — izlenmeli | ✅ oEmbed: author_name="Clinical Physio", başlık eşleşti; lengthSeconds=905 |
| 2 | Clinical Physio (Premium) | Shoulder Full Assessment Run Through \| Clinical Physio Premium | https://www.youtube.com/watch?v=E3Eu0F73ROI | 5:32 | belirsiz — izlenmeli | ✅ (yukarıdaki #1 ile aynı — aynı kanaldan 2. video, ayrı eğitmen SAYILMAZ) |
| 3 | Mobility Doc | Master the FMS Shoulder Mobility Test | https://www.youtube.com/watch?v=HVQ1YNtw_yQ | 2:45 | belirsiz — izlenmeli | ✅ (yukarıdaki ile aynı doğrulama) |
| 4 | Jungle Botany (konuk: Emmet Louis) | How Flexible Are You? 4 Simple Tests With Emmet Louis | https://www.youtube.com/watch?v=PfpJnU8x1kU | 4:57 | belirsiz — izlenmeli | ✅ (yukarıdaki ile aynı doğrulama) |
| 5 | ACE Fitness | Shoulder Mobility Assessment | https://www.youtube.com/watch?v=GL6kBBMtWkY | 4:58 | belirsiz — izlenmeli | ✅ (yukarıdaki ile aynı doğrulama) |

**Not:** Bağımsız eğitmen sayımı için #2'yi (aynı Clinical Physio kanalı) düşün­ce bile kalan **4 farklı
kanal/eğitmen** (Clinical Physio, Mobility Doc, Emmet Louis, ACE Fitness) mevcut → ✅ kriteri karşılanıyor.

---

## Wall Angels / Wall Slides

**Durum:** ✅ ≥3 bağımsız eğitmen (kadraj teyidi bekliyor)

| # | Kanal | Video başlığı | URL | Süre | Kadraj | Doğrulama |
|---|---|---|---|---|---|---|
| 1 | Rehab My Patient | Wall Angel | https://www.youtube.com/watch?v=cvx06snMQ3A | 0:31 | belirsiz — izlenmeli (çok kısa, tek açı olası) | ✅ oEmbed: author_name="Rehab My Patient", başlık eşleşti; lengthSeconds=31 |
| 2 | Sports Chiropractic Institute | Wall Angel Test | https://www.youtube.com/watch?v=VZnhIQarBQc | 3:12 | belirsiz — izlenmeli | ✅ oEmbed: author_name="sportschiroinstitute", başlık eşleşti; lengthSeconds=192 |
| 3 | Integrated Health Sciences | Wall Angel Functional Test #6: 8 Foundations of Movement | https://www.youtube.com/watch?v=KPcCg8RVUk0 | 1:00 | belirsiz — izlenmeli | ✅ oEmbed: author_name="Integrated Health Sciences", başlık eşleşti; lengthSeconds=60 |
| 4 | FAQ Fitness Podcast | Wall Angel Mobility Assessment | https://www.youtube.com/watch?v=NmrOMjNQNng | 3:36 | belirsiz — izlenmeli | ✅ oEmbed: author_name="FAQ Fitness Podcast", başlık eşleşti; lengthSeconds=216 |
| 5 | The Coach House Madeira | Home Fitness Test \| Testing Movement \| Wall Angel | https://www.youtube.com/watch?v=QlUhbo41GTg | 2:00 | belirsiz — izlenmeli | ✅ oEmbed: author_name="thecoachhousemadeira", başlık eşleşti; lengthSeconds=120 |
| 6 | Invictus Fitness | Wall Slides | https://www.youtube.com/watch?v=GaP20t6ZOfU | 2:02 | belirsiz — izlenmeli | ✅ oEmbed: author_name="InvictusFitness", başlık eşleşti; lengthSeconds=122. Açıklamada: "Wall Slides are a great shoulder mobility check to see where an athlete's range of motion starts breaking down to improper form" |

⚠️ Öncelikli klinik/PT kanal havuzundan (Physiotutors, E3 Rehab, Clinical Physio, Movement by David,
NASM/Brookbush, Emmet Louis, Tom Merrick) doğrudan bir "wall angel/wall slide" videosu **video-düzeyinde
doğrulanamadı** — bulunan 6 video genel fitness/kayropraktik/rehab kanallarından (öncelik dışı ama
bağımsız ve meşru). Kurucunun önceliklendirdiği kanallardan ek tarama gerekiyor (bkz. Açık kalanlar).

---

## Özet tablosu

| Hareket | Bulunan bağımsız eğitmen sayısı | Durum |
|---|---|---|
| Overhead Reach / Shoulder Flexion Assessment | 4 | ✅ |
| Shoulder Mobility Screen (genel) | 4 (Clinical Physio, Mobility Doc, Emmet Louis, ACE Fitness) | ✅ |
| Wall Angels / Wall Slides | 6 | ✅ |

---

## Açık kalanlar

1. **Öncelikli kanal havuzundan (Physiotutors, E3 Rehab, Movement by David, NASM/Brookbush, Tom Merrick)
   hiçbir 3 harekette de video-düzeyinde URL doğrulanamadı.** Arama sonuçları bu kanalların ilgili
   playlist/wiki sayfalarına işaret etti ama tekil video URL'si bulunamadı ya da bulunanlar (ör.
   Brookbush "Shoulder Flexion Goniometry") arama sonucunda tam YouTube linkine dönüşmedi — sonraki
   turda bu kanalların kendi YouTube sayfaları taranıp video-düzeyinde URL çıkarılmalı.
2. **Kadraj (sagittal/frontal, tam vücut/kesik) hiçbir video için görsel olarak teyit edilmedi** — bu
   ortamda video oynatma/kare-yakalama aracı yoktu. Ölçüm hattına girmeden önce 12 videonun tamamı elle
   izlenip kadraj + aynalama yönü (sol/sağ) işaretlenmeli.
3. **Aynalama çözümü (N-take konsensüs) için bu videoların sol/sağ kolu hangi yöne kaldırdığı** henüz
   tek tek belirlenmedi — bu da izleme turunda yapılmalı.

## Uyarılar

- **Lisans:** Listelenen tüm videolar için CC-BY olduğuna dair sayfada açık bir ibare görülmedi →
  hepsi **standart (varsayılan) YouTube lisansı** kabul edilmeli. Ticari kullanım/referans amaçlı
  kullanmadan önce telif durumu ayrıca değerlendirilmeli.
- **Kadraj riski:** cvx06snMQ3A ("Wall Angel", 31 saniye) çok kısa — muhtemelen tek kısa klip, kadraj
  çeşitliliği/tam vücut görünürlüğü şüpheli, izlerken öncelikli kontrol edilmeli.
- **Aynalama riski:** Tüm videolar eğitmenin izleyiciye dönük durup "ayna" pozisyonunda öğretmesi
  varsayımıyla seçildi (tipik fitness/rehab video formatı) ama bu doğrulanmadı — izleme turunda kontrol
  edilmeli.
- **Kanal çakışması:** "Shoulder Mobility Screen" bölümündeki #1 ve #2 aynı kanaldan (Clinical Physio) —
  bağımsız eğitmen sayımında TEK eğitmen olarak sayılmalı, çeşitlilik iddiası bu ikisine dayanmamalı.
- Aranıp da **atlanan** (WebFetch/oEmbed ile açılamayan veya başlığı eşleşmeyen) hiçbir uydurma URL
  rapora dahil edilmedi; yalnızca yukarıdaki 12 satır canlı doğrulandı.
