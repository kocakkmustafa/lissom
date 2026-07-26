# Yoga Asana Aileleri — Eğitmen Video Envanteri (V1 içerik paketleri için)

**Amaç:** Lissom V1 yoga paketlerini (Morning Mobility Flow, Desk Posture Reset, Hip & Hamstring Opening)
besleyecek temel asanalar için kamuya açık, gerçek eğitmen videolarından skorlama referansı hasadı.
Kural: hareket başına ≥3 bağımsız eğitmen (aynalama sol/sağ belirsizliğini N-take konsensüsle çözmek
ve eğitmenler-arası varyansı tolerans olarak kullanmak için).

**Doğrulama yöntemi:** Her URL WebFetch ile açıldı ve YouTube sayfasının `<title>` etiketi ile aranan
hareket eşleştirildi. WebFetch, YouTube'un JS ile render edilen tam sayfasını değil, sunucu tarafı
render edilen `<title>` dışında çoğunlukla yalnız footer/navigasyon metnini döndürüyor — yani **kanal adı,
video süresi ve kadraj (yandan/önden çekim) bu araçla görsel olarak doğrulanamadı**. Kanal/eğitmen adı
alanı arama sonucu snippet'lerinden alınmıştır (bazı durumlarda "kanal adı doğrulanamadı" olarak
işaretlenmiştir). Kadraj sütunu tamamı "belirsiz — görsel inceleme gerekli" olarak işaretlenmiştir;
gerçek açı/kadraj tespiti için videoların insan tarafından (veya video-anlama aracıyla) izlenmesi şarttır.
Bu envanter yalnızca "video var, URL gerçek, başlık eşleşiyor" seviyesinde doğrulanmıştır — sonraki adım
görsel kadraj/açı denetimidir.

Birkaç aday URL (ör. Dylan Werner kanalının çoklu videoları, Briohny Smyth Half Moon videosu) WebFetch ile
tekrar tekrar denendiği halde sayfa içeriği/başlığı alınamadığı için **YAZILMADI** — "az ama doğru" kuralı
gereği bu satırlar envantere dahil edilmemiştir.

---

## Mountain Pose (Tadasana)

**Durum:** ✅ ≥3 bağımsız eğitmen (ayakta duruş, kadraj denetimi gerekli)

| # | Kanal | Video başlığı | URL | Süre | Kadraj | Doğrulama |
|---|---|---|---|---|---|---|
| 1 | Iyengar Yoga (kanal adı arama snippet'inden) | How to do MOUNTIAN POSE (Tadasana) \| step by step \| Iyengar Yoga | https://www.youtube.com/watch?v=elBp2FpAOOI | ? | belirsiz, görsel inceleme gerekli | ✅ WebFetch ile açıldı, başlık eşleşti |
| 2 | Yoga With Adriene | Mountain Pose (Tadasana) - Yoga With Adriene | https://www.youtube.com/watch?v=NYhH8Gr35cI | ? | belirsiz, görsel inceleme gerekli | ✅ WebFetch ile açıldı, başlık eşleşti |
| 3 | kanal adı doğrulanamadı | Learn the Mountain Pose - Tadasana \| Yoga | https://www.youtube.com/watch?v=5NxDs-ovJU8 | ? | belirsiz, görsel inceleme gerekli | ✅ WebFetch ile açıldı, başlık eşleşti |

Lisans: standart (varsayılan) — CC işareti sayfada görülmedi.

---

## Standing Forward Fold (Uttanasana)

**Durum:** ⚠️ 2 eğitmen — 3. bağımsız kaynak bulunamadı (ek tarama gerekli)

| # | Kanal | Video başlığı | URL | Süre | Kadraj | Doğrulama |
|---|---|---|---|---|---|---|
| 1 | kanal adı doğrulanamadı | Standing Forward Fold Pose / Uttanasana (Yoga Tutorial) | https://www.youtube.com/watch?v=eTEBAanmDmA | ? | belirsiz, görsel inceleme gerekli | ✅ WebFetch ile açıldı, başlık eşleşti |
| 2 | kanal adı doğrulanamadı | Standing Forward Bend | https://www.youtube.com/watch?v=0KzyEgkq7zw | ? | belirsiz, görsel inceleme gerekli | ⚠️ WebFetch yalnız tarayıcı sekmesi başlığını doğruladı ("Standing Forward Bend - YouTube"), içerik detayına ulaşılamadı |

Lisans: standart (varsayılan).

Not: Bu hareket "Morning Mobility Flow" ve "Hip & Hamstring Opening" paketlerinde muhtemelen kullanılacak
— 3. bağımsız eğitmen bulunana kadar ⚠️ statüsünde kalmalı.

---

## Chair Pose (Utkatasana)

**Durum:** ⚠️ 2 eğitmen — 3. bağımsız kaynak bulunamadı (ek tarama gerekli)

| # | Kanal | Video başlığı | URL | Süre | Kadraj | Doğrulama |
|---|---|---|---|---|---|---|
| 1 | Yoga With Divya | Chair Pose (Utkatasana) Tutorial \| 9-Min Posture Clinic For Stability & Alignment \| Yoga With Divya | https://www.youtube.com/watch?v=taYIpsxdwTM | ~9 dk (başlıkta belirtilmiş) | belirsiz, görsel inceleme gerekli | ✅ WebFetch ile açıldı, başlık eşleşti |
| 2 | Iyengar Yoga (kanal adı arama snippet'inden) | How to do CHAIR POSE / FIERCE POSE (Utkatasana) \| step by step \| Iyengar Yoga | https://www.youtube.com/watch?v=s9ESgwn3k3k | ? | belirsiz, görsel inceleme gerekli | ✅ WebFetch ile açıldı, başlık eşleşti |

Not: "Dylan Werner" kanalına ait aday video (Utkatasana Tutorial, v=tEZhXr0FuAQ) WebFetch ile iki kez denendi,
sayfa içeriği/başlığı alınamadı → **DOĞRULANMADI, envantere yazılmadı.**

Lisans: standart (varsayılan).

---

## Warrior I & II (Virabhadrasana I / II)

**Durum:** ✅ Warrior II ≥3 bağımsız eğitmen · ⚠️ Warrior I 2 eğitmen (ek tarama gerekli)

### Warrior II (Virabhadrasana II)

| # | Kanal | Video başlığı | URL | Süre | Kadraj | Doğrulama |
|---|---|---|---|---|---|---|
| 1 | Yoga With Adriene | Warrior 2 Yoga Pose - Yoga With Adriene | https://www.youtube.com/watch?v=4Ejz7IgODlU | ? | belirsiz, görsel inceleme gerekli | ✅ WebFetch ile açıldı, başlık eşleşti |
| 2 | kanal adı doğrulanamadı | Yoga Pose Tutorial \| Warrior 2 (Virabhadrasana II) Detailed Breakdown for Strength & Alignment | https://www.youtube.com/watch?v=5NZJS-i7h-k | ? | belirsiz, görsel inceleme gerekli | ✅ WebFetch ile açıldı, başlık eşleşti |
| 3 | kanal adı doğrulanamadı | Warrior 2 Tutorial - Proper Alignment in Warrior 2 | https://www.youtube.com/watch?v=V_VsRe015pU | ? | belirsiz, görsel inceleme gerekli | ✅ WebFetch ile açıldı, başlık eşleşti |
| 4 | Annie Adamson (arama snippet'inde adı geçiyor) | How to Do Warrior II Pose with Correct Alignment | https://www.youtube.com/watch?v=pJhevMZfOHA | ? | belirsiz, görsel inceleme gerekli | ✅ WebFetch ile açıldı, başlık eşleşti |

### Warrior I (Virabhadrasana I)

| # | Kanal | Video başlığı | URL | Süre | Kadraj | Doğrulama |
|---|---|---|---|---|---|---|
| 1 | Iyengar Yoga (kanal adı arama snippet'inden) | Ways to practice WARRIOR 1 POSE - Virabhadrasana I - Iyengar yoga | https://www.youtube.com/watch?v=bclyJteWXic | ? | belirsiz, görsel inceleme gerekli | ✅ WebFetch ile açıldı, başlık eşleşti |
| 2 | kanal adı doğrulanamadı | Warrior 1 Tutorial \| Proper alignment for Virabhadrasana I \| how-to-do warrior 1 properly | https://www.youtube.com/watch?v=IcAGektqvsc | ? | belirsiz, görsel inceleme gerekli | ✅ WebFetch ile açıldı, başlık eşleşti |

Not: "Dylan Werner" kanalına ait Warrior I adayı (v=NytDpa2r34g) WebFetch ile iki kez denendi, sayfa
içeriği/başlığı alınamadı → **DOĞRULANMADI, envantere yazılmadı.**

Lisans: standart (varsayılan).

---

## Triangle Pose (Trikonasana)

**Durum:** ✅ ≥3 bağımsız eğitmen

| # | Kanal | Video başlığı | URL | Süre | Kadraj | Doğrulama |
|---|---|---|---|---|---|---|
| 1 | kanal adı doğrulanamadı | Triangle Pose (Trikonasana) Tutorial \| Step-by-Step Yoga for Beginners | https://www.youtube.com/watch?v=mdRks-UG1qw | ? | belirsiz, görsel inceleme gerekli | ✅ WebFetch ile açıldı, başlık eşleşti |
| 2 | Yoga With Adriene (Foundations of Yoga) | Triangle Pose \| Trikonasana \| Foundations of Yoga | https://www.youtube.com/watch?v=upFYlxZHif0 | ? | belirsiz, görsel inceleme gerekli | ✅ WebFetch ile açıldı, başlık eşleşti |
| 3 | Iyengar Yoga (kanal adı arama snippet'inden) | TRIANGLE POSE tutorial \| Trikonasana VARIATIONS \| Iyengar Yoga | https://www.youtube.com/watch?v=EPaf4b3pD84 | ? | belirsiz, görsel inceleme gerekli | ✅ WebFetch ile açıldı, başlık eşleşti |
| 4 | YogaRenew | Triangle Pose \| Yoga Poses \| YogaRenew How To Yoga Pose Video | https://www.youtube.com/watch?v=5ZTXM4lbzXQ | ? | belirsiz, görsel inceleme gerekli | ✅ WebFetch ile açıldı, başlık eşleşti |

Lisans: standart (varsayılan).

---

## Low Lunge (Anjaneyasana)

**Durum:** ✅ ≥3 bağımsız eğitmen (yerde/diz-üstü poz — "uygulanır, ölçülmez" kategorisine yakın; ön bacak
dizden yukarısı ayakta kadraja girebilir, alt gövde kamerayla güvenilir ölçülemeyebilir — kadraj denetimi
şart)

| # | Kanal | Video başlığı | URL | Süre | Kadraj | Doğrulama |
|---|---|---|---|---|---|---|
| 1 | Yoga Upload (arama snippet'inde adı geçiyor) | How to do Low Lunge Pose \| Anjaneyasana \| Yoga Tutorial | https://www.youtube.com/watch?v=Y8jM-f_mUTM | ? | belirsiz, görsel inceleme gerekli | ✅ WebFetch ile açıldı, başlık eşleşti |
| 2 | Josey Prior | Low Lunge (Anjaneyasana) - Yoga Pose Guide Tutorial | https://www.youtube.com/watch?v=MjiC4mGTnTw | ? | belirsiz, görsel inceleme gerekli | ✅ WebFetch ile açıldı, başlık eşleşti |
| 3 | Aham Yoga | Anjaneyasana (low lunge pose) & High Lunge yoga pose tutorial - Aham Yoga | https://www.youtube.com/watch?v=hvfU9dp2eDA | ? | belirsiz, görsel inceleme gerekli | ✅ WebFetch ile açıldı, başlık eşleşti |

Lisans: standart (varsayılan).

---

## Downward Dog (Adho Mukha Svanasana)

**Durum:** ✅ ≥3 bağımsız eğitmen — **yerde/dört-ayak destekli poz: kamerayla self-occlusion riski yüksek,
"uygulanır, ölçülmez" kategorisine aday, kadraj denetimiyle karar verilmeli**

| # | Kanal | Video başlığı | URL | Süre | Kadraj | Doğrulama |
|---|---|---|---|---|---|---|
| 1 | kanal adı doğrulanamadı (Ashtanga odaklı) | How To Do Adho Mukha Svanasana \| Downward Facing Dog in Ashtanga Yoga | https://www.youtube.com/watch?v=T7qT6l9npPg | ? | belirsiz, görsel inceleme gerekli | ✅ WebFetch ile açıldı, başlık eşleşti |
| 2 | Liforme | How to do Yoga Downward Dog (Adho Mukha Svanasana) \| Liforme | https://www.youtube.com/watch?v=F8q1kEF2JCA | ? | belirsiz, görsel inceleme gerekli | ✅ WebFetch ile açıldı, başlık eşleşti |
| 3 | kanal adı doğrulanamadı (Iyengar odaklı) | Adho Mukha Svanasana - Tutorial. Instruction for Dog Head Down. Iyengar Yoga for Beginners. | https://www.youtube.com/watch?v=Z3ZTAxVe90s | ? | belirsiz, görsel inceleme gerekli | ✅ WebFetch ile açıldı, başlık eşleşti |

Not: "Dylan Werner" kanalına ait Downward Dog adayı (v=EC7RGJ975iM) WebFetch ile denendi, sayfa
içeriği/başlığı alınamadı → **DOĞRULANMADI, envantere yazılmadı.**

Lisans: standart (varsayılan).

---

## Cat-Cow (Marjaryasana-Bitilasana)

**Durum:** ✅ ≥3 bağımsız eğitmen — **yerde/dört-ayak (all-fours) poz: kamerayla güvenilir ölçülemez,
"uygulanır, ölçülmez" kategorisi**

| # | Kanal | Video başlığı | URL | Süre | Kadraj | Doğrulama |
|---|---|---|---|---|---|---|
| 1 | Yoga With Adriene | Cat-Cow Yoga Pose - Yoga With Adriene | https://www.youtube.com/watch?v=y39PrKY_4JM | ? | belirsiz, görsel inceleme gerekli | ✅ WebFetch ile açıldı, başlık eşleşti (içerik detayı sınırlı) |
| 2 | kanal adı doğrulanamadı | 21 Day Yoga Challenge \| How to do Cat Cow Pose \| Bitilasana Marjaryasana- Yoga Pose Guide Tutorial | https://www.youtube.com/watch?v=HYJhWVfFzVA | ? | belirsiz, görsel inceleme gerekli | ✅ WebFetch ile açıldı, başlık eşleşti |
| 3 | YogaRenew | Cat Pose \| Yoga Poses \| YogaRenew How To Yoga Pose Video | https://www.youtube.com/watch?v=vJ0jg3xqaQk | ? | belirsiz, görsel inceleme gerekli | ✅ WebFetch ile açıldı, başlık eşleşti |

Not: "Dylan Werner" kanalına ait Cat/Cow adayları (v=LGLIyrfTiUc, v=W5KVx0ZbB_4) WebFetch ile denendi,
sayfa içeriği/başlığı alınamadı → **DOĞRULANMADI, envantere yazılmadı.**

Lisans: standart (varsayılan).

---

## Thread the Needle (Parsva Balasana)

**Durum:** ✅ ≥3 bağımsız eğitmen — **yerde/dört-ayak destekli poz: kamerayla self-occlusion, "uygulanır,
ölçülmez" kategorisi**

| # | Kanal | Video başlığı | URL | Süre | Kadraj | Doğrulama |
|---|---|---|---|---|---|---|
| 1 | kanal adı doğrulanamadı | Thread the Needle Pose Yoga Pose Tutorial - Parsva Balasana Tips & Tricks | https://www.youtube.com/watch?v=vOukJVt56os | ? | belirsiz, görsel inceleme gerekli | ✅ WebFetch ile açıldı, başlık eşleşti |
| 2 | Yoga with Louise | Thread It Right - How to do Thread The Needle Pose \| Yoga with Louise | https://www.youtube.com/watch?v=YjRBOASo3zM | ? | belirsiz, görsel inceleme gerekli | ✅ WebFetch ile açıldı, başlık eşleşti |
| 3 | kanal adı doğrulanamadı | Yoga Tutorial - Thread The Needle pose | https://www.youtube.com/watch?v=SMhhMBqkZP4 | ? | belirsiz, görsel inceleme gerekli | ✅ WebFetch ile açıldı, başlık eşleşti |

Lisans: standart (varsayılan).

---

## Standing Side Bend (Parsva Urdhva Hastasana)

**Durum:** ❌ bulunamadı — yalnızca 1 aday (bir YouTube Shorts, uzun-format eğitmen videosu değil), 3
bağımsız eğitmen eşiğinden çok uzak

| # | Kanal | Video başlığı | URL | Süre | Kadraj | Doğrulama |
|---|---|---|---|---|---|---|
| 1 | kanal adı doğrulanamadı | Parsva Urdhva Hastasana \| Standing Side Bend | https://www.youtube.com/shorts/ntr6I765D8g | Shorts (<60 sn) | belirsiz, görsel inceleme gerekli | ⚠️ URL doğrulanmadı (WebFetch ile açılıp başlık teyit edilmedi) — yalnız arama snippet'i var |

Bu hareket için ayrı ve daha kapsamlı bir arama turu gerekiyor (bkz. Açık Kalanlar).

---

## Half Moon (Ardha Chandrasana)

**Durum:** ✅ ≥3 bağımsız eğitmen — denge pozu, tek ayak üstünde durma, ayakta ve tam vücut kadraj şart

| # | Kanal | Video başlığı | URL | Süre | Kadraj | Doğrulama |
|---|---|---|---|---|---|---|
| 1 | Yoga With Adriene (Foundations of Yoga) | Half Moon Pose - Foundations of Yoga | https://www.youtube.com/watch?v=EriPRTk1ly0 | ? | belirsiz, görsel inceleme gerekli | ✅ WebFetch ile açıldı, başlık eşleşti |
| 2 | kanal adı doğrulanamadı | How to do Ardha Chandrasana - "Half Moon" Pose Tutorial (15-min) Yoga Breakdown | https://www.youtube.com/watch?v=HhApHbLgxMA | ~15 dk (başlıkta belirtilmiş) | belirsiz, görsel inceleme gerekli | ✅ WebFetch ile açıldı, başlık eşleşti |
| 3 | Iyengar Yoga (kanal adı arama snippet'inden) | Tips on HALF MOON POSE - Ardha Chandrasana \| Iyengar Yoga | https://www.youtube.com/watch?v=-wwRNGArTI0 | ? | belirsiz, görsel inceleme gerekli | ✅ WebFetch ile açıldı, başlık eşleşti (ilk denemede timeout, ikinci denemede başarılı) |

Not: "Briohny Smyth" kanalına ait Half Moon adayı (v=csErxVR7dpA) WebFetch ile denendi, sayfa
içeriği/başlığı alınamadı → **DOĞRULANMADI, envantere yazılmadı.**

Lisans: standart (varsayılan).

---

## Tree Pose (Vrksasana)

**Durum:** ✅ ≥3 bağımsız eğitmen — denge pozu, ayakta, tam vücut kadraj şart

| # | Kanal | Video başlığı | URL | Süre | Kadraj | Doğrulama |
|---|---|---|---|---|---|---|
| 1 | Yoga With Adriene | Tree Pose - Vrksasana - Yoga With Adriene | https://www.youtube.com/watch?v=yVE4XXFFO70 | ? | belirsiz, görsel inceleme gerekli | ✅ WebFetch ile açıldı, başlık eşleşti |
| 2 | Lisa Sanson (arama snippet'inde adı geçiyor, YYOGA eğitmen eğitimcisi) | Alignment Tips for Tree Pose - VRKSASANA TUTORIAL | https://www.youtube.com/shorts/L2g5cq8h3as | Shorts (<60 sn) | belirsiz, görsel inceleme gerekli | ✅ WebFetch ile açıldı, başlık eşleşti — DİKKAT: bu bir YouTube Shorts, poz muhtemelen kesik/kısa süreli gösteriliyor |
| 3 | kanal adı doğrulanamadı | Tree Pose Alignment & Tips - Yoga for Beginners | https://www.youtube.com/watch?v=ZRS0dXit51Q | ? | belirsiz, görsel inceleme gerekli | ✅ WebFetch ile açıldı, başlık eşleşti |

Lisans: standart (varsayılan).

---

## Özet tablosu (hareket × bulunan eğitmen sayısı × durum)

| Hareket | Bulunan bağımsız eğitmen sayısı | Durum |
|---|---|---|
| Mountain Pose (Tadasana) | 3 | ✅ |
| Standing Forward Fold (Uttanasana) | 2 | ⚠️ |
| Chair Pose (Utkatasana) | 2 | ⚠️ |
| Warrior II (Virabhadrasana II) | 4 | ✅ |
| Warrior I (Virabhadrasana I) | 2 | ⚠️ |
| Triangle Pose (Trikonasana) | 4 | ✅ |
| Low Lunge (Anjaneyasana) | 3 | ✅ |
| Downward Dog (Adho Mukha Svanasana) | 3 | ✅ |
| Cat-Cow (Marjaryasana-Bitilasana) | 3 | ✅ |
| Thread the Needle (Parsva Balasana) | 3 | ✅ |
| Standing Side Bend (Parsva Urdhva Hastasana) | 0 (1 doğrulanmamış Shorts adayı) | ❌ |
| Half Moon (Ardha Chandrasana) | 3 | ✅ |
| Tree Pose (Vrksasana) | 3 | ✅ |

**Toplam: 13 hareket taranmış (Warrior I ve II ayrı sayıldı), 9/13 ≥3 eşiğine ulaştı.**

---

## Açık kalanlar (≥3'e ulaşamayan hareketler + neden)

1. **Standing Side Bend (Parsva Urdhva Hastasana)** — 0 doğrulanmış eğitmen. Bu poz genellikle bağımsız bir
   asana olarak değil, Sun Salutation / Tadasana varyasyonu içinde geçici bir an olarak öğretiliyor; "how to
   do standing side bend correctly" tipi bağımsız alignment videosu neredeyse yok. Öneri: Parsvottanasana
   (Pyramid/Intense Side Stretch) veya "Extended Side Angle" gibi komşu/ilişkili duruşlarla birleştirilmiş
   arama yapılmalı, ya da bu poz V1'den çıkarılıp ileriki bir pakete ertelenmeli.
2. **Chair Pose (Utkatasana)** — 2/3. Dylan Werner kanalının adayı URL doğrulanamadığı için düştü. 3.
   bağımsız kaynak için NASM/Brookbush Institute veya E3 Rehab kanallarında Utkatasana'ya karşılık gelen
   "squat pattern" içerikli videolar aranmalı (bu kanallar klinik/PT odaklı, yoga-spesifik pose adı
   kullanmayabilir).
3. **Warrior I (Virabhadrasana I)** — 2/3. Dylan Werner adayı düştü. 3. kaynak için ayrı bir tur gerekiyor;
   Warrior II'de bulunan kanallardan (ör. "Warrior 2 Detailed Breakdown", "Warrior 2 Tutorial - Proper
   Alignment") aynı kanalların Warrior I versiyonu var mı kontrol edilmeli.
4. **Standing Forward Fold (Uttanasana)** — 2/3, ikinci video için içerik detayı sınırlı doğrulandı (yalnız
   sekme başlığı teyit edildi). 3. bağımsız eğitmen için ayrı arama gerekiyor.

---

## Uyarılar (kadraj sorunları, lisans şüpheleri, aynalama riski yüksek videolar)

- **Kadraj hiçbir satırda görsel olarak doğrulanmadı.** WebFetch yalnız metin/başlık seviyesinde çalıştığı
  için "sagittal / frontal / tam vücut mu kesik mi" sorusu bu envanterde **açık kaldı**. Bir sonraki adım:
  bu URL listesindeki videoları (a) tarayıcıda açıp kare-kare inceleme, veya (b) video-anlama destekli bir
  araçla (ör. video_analysis) otomatik kadraj sınıflandırması yapmak olmalı. Şu anki tabloda "kadraj"
  sütunundaki "belirsiz" ifadesi gerçek bir bulgudur, varsayılan doldurma değildir.
- **Yerde/dört-ayak pozlar (Downward Dog, Cat-Cow, Thread the Needle, Low Lunge'ın alt gövdesi):** kamerayla
  self-occlusion riski yüksek — kurucu kararına göre bu hareketler "uygulanır, ölçülmez" kategorisine
  girmeli; V1'in "AYAKTA" ölçüm iddiası bu pozlar için geçerli değil, yalnızca gösterim/talimat amaçlı
  kullanılabilir.
- **Kanal kimliği çoğu satırda tam doğrulanamadı** ("kanal adı doğrulanamadı" işaretli satırlar) — WebFetch
  YouTube'un kanal/yazar meta verisini tutarlı biçimde döndürmedi. Bu satırlardaki videolar gerçek ve
  başlıkları hareketle eşleşiyor, ama "bağımsız eğitmen" sayımı kanal kimliğine dayandığından, aynı kişiye
  ait birden fazla kanal/takma isim olmadığından emin olmak için ek doğrulama (kanal sayfasını açıp "Hakkında"
  bölümüne bakmak) önerilir.
- **Aynalama riski:** hiçbir video için sol/sağ yönelim bu turda kontrol edilmedi. N-take konsensüs
  metodolojisinin işlemesi için her pozun her eğitmende hangi yöne baktığı (kameraya göre) ayrıca
  kodlanmalı — bu envanter yalnız "video var" seviyesinde, "yön kodlaması" bir sonraki adım.
- **Dylan Werner kanalına ait 5 aday URL** (Chair, Warrior I, Downward Dog, Cat, Cow) WebFetch ile tekrar
  tekrar denendi ve tutarlı biçimde sayfa/başlık alınamadı — bu videoların kaldırılmış, gizli, ya da yanlış
  ID'li olma ihtimali var. **Hiçbiri envantere yazılmadı**; bu kanal için ayrı, doğrudan kanal sayfası
  üzerinden (arama motoru sonucu değil) bir tarama yapılması önerilir.
- **Lisans:** hiçbir videoda sayfa içinde açık CC-BY işareti görülmedi; tüm satırlar "standart (varsayılan)"
  lisans olarak işaretlendi. Ticari/derivatif kullanım (skorlama referansı çıkarma) öncesi her kanalın kendi
  ToS'una ve fair-use sınırlarına hukuki bakış gerekebilir — bu envanter yalnızca içerik-bulma, lisans
  danışmanlığı değildir.
