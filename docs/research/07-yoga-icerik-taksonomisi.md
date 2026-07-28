# Yoga İçerik Taksonomisi & Dizileme (Sequencing) İlkeleri — 2026-07-26

Kaynak: G0 tazeleme fan-out

## Özet

Lissom'un yoga içerik katmanı için (a) hangi yoga stilinin ölçüm-güdümlü bir mobilite ürününe uyduğu, (b) yaygın amaç-bazlı paket temaları ve tipik süre/poz sayıları, (c) klasik dizileme (sequencing) ilkeleri, (d) kamerayla (tek 2D + MediaPipe Pose Landmarker) güvenilir/güvenilmez şekilde değerlendirilebilecek pozlar ve (e) Sanskritçe/İngilizce adlandırma normu araştırıldı. Kanıtlar gösteriyor ki: **Vinyasa/mobility-flow tarzı dinamik, ayakta-ağırlıklı diziler** kamera-tabanlı ölçüme en uyumlu olanlar; **Yin/restorative** (uzun süreli, çoğunlukla yerde/destekli tutuşlar) ölçülebilirlik açısından zayıf ama "wind-down" paketi için içerik değeri var (sadece takip amaçlı, skor beslemeyecek şekilde). Kamera-tabanlı pose estimation literatürü, yerde-yüzüstü pozlarda ciddi self-occlusion sorunu olduğunu doğruluyor — bu, Lissom'un "hangi pozlar skor besler" kararını doğrudan etkiliyor.

## Bulgular (kanıtlı, URL'li)

### (a) Yoga stilleri ve mobilite hedefi uyumu

- Hatha yoga: "traditional poses, slow-paced stretches, and breathwork... combines dynamic movements with muscle engagement to build both strength and active flexibility." — ayakta/duruş-bazlı, orta hızda, aktif esneklik hedefli. [Arhanta Yoga](https://www.arhantayoga.org/blog/which-yoga-style-best-fits-your-needs/)
- Vinyasa yoga: "active style... flows quickly from one pose to another" — dinamik hareket geçişleri, kamera takibi için daha fazla "hareket halinde landmark" verisi üretir (hem avantaj hem zorluk: hızlı geçişlerde blur/motion artefaktı). [Arhanta Yoga](https://www.arhantayoga.org/blog/which-yoga-style-best-fits-your-needs/)
- Yin yoga: "settle into supported floor poses for minutes at a time... targeting deep connective tissues like fascia and ligaments... enhance passive flexibility, especially in stiff areas such as the hips, spine, and shoulders." — ÇOĞUNLUKLA YERDE, uzun statik tutuş. [Arhanta Yoga](https://www.arhantayoga.org/blog/which-yoga-style-best-fits-your-needs/)
- Restorative yoga: "helps an unhealthy body, or an injured body, restore itself... by relaxing in poses, with the aid of props, without strain or pain." — prop-destekli, pasif, ölçüm hedefli değil, dinlenme/iyileşme odaklı. [Arhanta Yoga](https://www.arhantayoga.org/blog/yin-yoga-vs-restorative-yoga/)
- Genel ayrım: "Yin Yoga releases deep fascia and connective tissue to improve flexibility in an already healthy body, while Restorative Yoga helps an injured or ill body to heal." [Arhanta Yoga](https://www.arhantayoga.org/blog/yin-yoga-vs-restorative-yoga/)

**Sonuç:** Ölçüm-güdümlü (assessment-linked) bir mobilite ürünü için en uygun stil ailesi **Hatha-türevi ve "mobility-flow"** (ayakta/duruş-bazlı, orta hızda, tutuş süresi kısa-orta, poz geçişleri net) — Vinyasa'nın dinamik akıcılığı SEÇİLİ pozlarda (geçiş dışı, tutuş anında ölçüm) kullanılabilir. Yin/restorative kamera-ölçümüne UYGUN DEĞİL (çoğunlukla yerde, uzun tutuş, poz doğruluğu değil rahatlama hedefli) ama içerik kütüphanesinde "wind-down" paketi olarak (skor beslemeden) yer alabilir.

### (b) Amaç-bazlı yoga paket temaları — süre/poz sayısı

- Desk relief: "A desk yoga sequence focuses on the hips, lower back, shoulders, chest, and wrists, and typically requires about five minutes... many of these poses can be done in 30 seconds or less." [Yoga.com](https://yoga.com/practice-sequences/yoga-for-desk-workers-a-short-practice-that-can-help-your-body)
- Hip opening: "Practicing hip openers 3–4 times a week... hold hip-opening poses for 30–60 seconds, or even longer" — bazı pozlar 30-45 sn, bazıları (lunge, goddess pose) 30 sn-1 dk. [MyYogaTeacher](https://myyogateacher.com/articles/hip-openers)
- Shoulder opening: örnek bir dizi "5 different tension-taming asanas" içeriyor, her poz "10-20 breaths" tutuluyor (nefes-bazlı süre, yaklaşık 40-80 sn/poz). [Daily Burn](https://dailyburn.com/life/fitness/yoga-shoulder-stretches/)
- Pre-workout warm-up: "dynamic stretching routine can last anywhere from two to 10 minutes... For yoga specifically, limit the length of the flow to about 10 to 15 minutes, and never hold any pose longer than 20–30 seconds." [ATI Physical Therapy](https://www.atipt.com/pre-post-workout-stretches/)
- Post-run/post-workout: "static stretches... held for a period of time, usually between 10-60 seconds... hold each stretch for 30-60 seconds for optimal results." [ATI Physical Therapy](https://www.atipt.com/pre-post-workout-stretches/)
- DOĞRULANMADI: "morning flow", "spinal mobility", "wind-down/sleep" paket temaları için spesifik süre/poz-sayısı istatistiği taşıyan tekil bir kaynak bulunamadı (genel blog içerikleri var ama nicel veri sunmuyor) — bu paketler için sayısal norm YOK, ürün ekibi kendi süre standardını (örn. 5/10/15 dk kademeleri) belirlemeli.

### (c) Dizileme (sequencing) ilkeleri

- Genel yapı ("mountain arc"): "a gradual ascent through preparatory poses, a summit at the peak pose, and a gradual descent through counter-poses and restorative work into Savasana." [Yogajala](https://yogajala.com/yoga-sequencing-principles-peak-pose/)
- Enerji yayı: "Arrival and grounding → Warm-up (gentle, mobilizing movement that generates heat) → Building (progressively more challenging) → Peak (most demanding moment) → Counter and cool-down (systematically neutralizes the peak) → Integration and rest (Savasana)." [Yogajala](https://yogajala.com/yoga-sequencing-principles-peak-pose/)
- Peak Pose Method: "organizes an entire class around a single destination pose... every pose leading up to it serves a specific purpose: warming the body, opening target muscle groups, building necessary strength, developing proprioceptive awareness." [Yogajala](https://yogajala.com/yoga-sequencing-principles-peak-pose/)
- Counterpose/soğuma kuralı: "cool-down should include an immediate counter-pose (such as Knees to Chest after backbends), 2-3 gentle floor poses, a supine twist, and full Savasana." [Yogajala](https://yogajala.com/yoga-sequencing-principles-peak-pose/)
- Counterpose'un "zorunlu kural" olup olmadığı tartışmalı — bir kaynak bu kuralların her zaman katı biçimde gerekli olmadığını tartışıyor (başlık: "Yoga Pose/Counterpose Rules: Are They Necessary?") ancak içerik detayı taranmadı; DOĞRULANMADI olarak işaretliyorum (kaynak var ama iddia teyit edilmedi). [Jenni Rawlings Blog](https://jennirawlingsblog.com/blog/yoga-pose-counterpose-rules-are-they-necessary)
- Tutuş süreleri dinamik vs yin: pre-workout dinamik akışta pozlar "never hold... longer than 20-30 seconds" iken, post-workout statik/yin tutuşlar "30-60 seconds" ve Yin yoga'da "minutes at a time" (dakikalarca). [ATI PT](https://www.atipt.com/pre-post-workout-stretches/) · [Arhanta Yoga](https://www.arhantayoga.org/blog/which-yoga-style-best-fits-your-needs/)

### (d) Kamerayla değerlendirme güvenilirliği

- Genel CV zorlukları: "variability in body shapes, complex poses, occlusions, ambiguity in pose interpretation, and limited availability of datasets" + "vision-based methods... cannot robustly solve the occlusion problem." [PMC — yoga pose joint detection](https://pmc.ncbi.nlm.nih.gov/articles/PMC10280249/)
- Yerde/yüzüstü pozlar: "lying down poses cause most body parts to be self-occluded... self-occlusion poses a big challenge for pose estimation backbones." [arXiv 2503.06012](https://arxiv.org/pdf/2503.06012)
- MediaPipe'a özgü: "shows challenges when handling low light, occlusion, and far away persons" ve el/parmak occlusion'da "detector fails entirely and no landmarks are produced" (bu el-landmark bulgusu MediaPipe Hands'e ait, Pose değil — ama aynı aile mimarisinin occlusion'a genel duyarlılığına işaret eder, DOĞRULANMADI olarak Pose'a genellenmemeli). [LearnOpenCV](https://learnopencv.com/yolov7-pose-vs-mediapipe-in-human-pose-estimation/) · [arXiv 2405.03545](https://arxiv.org/pdf/2405.03545)
- Stereo/çoklu kamera çözümü önerisi mevcut ama Lissom tek-kamera kısıtına tabi: "Multi-camera setups and sensor fusion represent potential solutions to overcome the occlusion limitations inherent in single-camera vision-based systems." [PMC](https://pmc.ncbi.nlm.nih.gov/articles/PMC10280249/)

**Pratik çıkarım:** Kamera açısı mat üzerinde sabit/yandan olduğunda, YERDE UZANMA gerektiren pozlar (supine/prone) hem kamera açısına göre landmark'ların çoğu vücutla üst üste biner (self-occlusion) hem de yerden yansıyan/gölgeli aydınlatma sorunlarını büyütür — bu DOĞRULANMADI seviyesinde nicel bir hata oranı bulunamadı (spesifik yoga+MediaPipe supine-poz hata oranı literatürde raporlanmamış), ama occlusion mekanizması güçlü kanıtla destekleniyor.

### (e) Sanskritçe vs İngilizce adlandırma

- "English tells you what it looks like, while Sanskrit tells you where it came from... While English names vary... Sanskrit provides a universal vocabulary." [YogaUOnline](https://yogauonline.com/yoga-practice-teaching-tips/yoga-for-beginners/english-or-sanskrit-pose-names/)
- "English names help make practice more accessible to beginners, while traditional teachers often prefer Sanskrit... depends largely on teaching environment—for example... a gym, English names probably work better." [YogaUOnline](https://yogauonline.com/yoga-practice-teaching-tips/yoga-for-beginners/english-or-sanskrit-pose-names/)
- Başarılı yoga app'leri genelde "Sanskrit isim + İngilizce açıklama" ikili gösterim kullanıyor (kaynak genel gözlem, spesifik app-adı analizi yok — DOĞRULANMADI seviyesinde detay).

### GOWOD test mekanizması (bağlam bilgisini tazeleme)

- GOWOD mobility test: "guided through 10 different tests with video demonstrations... takes about 12 to 15 minutes... evaluates specific areas such as shoulders, overhead, thorax, hips, posterior chain, and ankles." Test mekanizmasının CV mi öz-değerlendirme (kullanıcı kendi hareketini video izleyerek kıyaslıyor) mi olduğu bu kaynaktan NET ÇIKMADI — "video demonstrations" ifadesi rehber-video'ya işaret ediyor, otomatik kamera-analizi olduğuna dair açık kanıt yok. **DOĞRULANMADI**: GOWOD'un gerçek zamanlı CV kullanıp kullanmadığı. [GOWOD App Store](https://apps.apple.com/us/app/gowod-mobility-stretching/id1227834875) · [GOWOD.app](https://www.gowod.app/)

## Ürüne doğrudan girdi

**V1 için önerilen 2-3 paket (kamera-ölçümüyle uyumlu, ayakta/duruş-ağırlıklı):**

1. **Morning Mobility Flow** (Hatha/mobility-flow karışımı, ~7-10 dk, 8-10 poz) — genel günlük ısınma; ayakta duruş + hafif diz-üstü pozlar. Besler: genel mobilite skoru + omurga + kalça bölgesel skoru.
2. **Desk Posture Reset** (Hatha-türevi, ~5 dk, 5-7 poz, çoğu 30 sn tutuş) — omuz, üst sırt, kalça fleksör odaklı; ayakta/oturur pozisyon ağırlıklı (kamera görüş açısı korunur). Besler: omuz + üst-sırt + kalça-fleksör bölgesel skoru.
3. **Hip & Hamstring Opening** (Hatha/mobility-flow, ~10 dk, 6-8 poz, 30-60 sn tutuş) — kalça ve posterior chain; çoğunlukla ayakta lunge-türevi varyasyonlar + destekli forward-fold (yerde değil, ayakta öne eğilme). Besler: kalça + hamstring/posterior-chain bölgesel skoru.

Not: Yin/restorative "wind-down/sleep" paketi V1'de EKLENEBİLİR ama **skor beslemez** — sadece takip/tamamlama amaçlı, çünkü pozların çoğu yerde ve uzun-statik, kamera-ölçüm güvenilirliği düşük.

**Paket veri yapısı için önerilen alan listesi:**
- `package_id`, `name_en`, `theme` (morning/desk/hips/hamstring/shoulders/spine/wind-down/pre-workout/post-run)
- `style_tag` (hatha/vinyasa/yin/restorative/mobility-flow)
- `target_regions[]` (skorlanan bölgesel kategoriler: shoulder, thorax, hips, posterior-chain, ankle, spine)
- `is_scored: bool` (kamera-ölçüm skoruna girer mi — yerde/yin paketlerde false)
- `total_duration_sec`, `pose_count`
- `sequence[]`: her poz için `{pose_id, sanskrit_name, english_name, hold_duration_sec, is_peak_pose: bool, is_counterpose: bool, camera_reliability: high/medium/low, floor_pose: bool}`
- `warmup_pose_ids[]`, `peak_pose_id`, `cooldown_pose_ids[]` (Peak Pose Method yapısını veri modelinde birebir tutmak için)
- `breath_cue` (nefes-hareket eşlemesi metni, opsiyonel)

**Kamerayla izlenmesi ÖNERİLMEYEN poz kategorileri (skor beslemeyecek / "practice-only" işaretlenecek):**
- Tüm supine (sırtüstü yerde) pozlar — self-occlusion riski yüksek
- Tüm prone (yüzükoyun) pozlar — kamera açısından gövde büyük ölçüde örtülü
- Derin twist/yerde-oturma pozları (kol-bacak birbirinin üzerine binen, örtüşen landmark'lar)
- Baş-aşağı/ters (inversion) pozlar — tek 2D kamerada landmark yönelimi belirsizleşir (DOĞRULANMADI: spesifik nicel veri yok, ama genel occlusion+açı mantığından çıkarım)
- Prop-destekli restorative pozlar (bolster/blok kullanımı obje-occlusion yaratır)

## Açık sorular (kapatılamayanlar, neden)

1. **MediaPipe Pose Landmarker'ın yerde/supine pozlarda nicel hata oranı ne?** — Literatürde mekanizma (self-occlusion) kanıtlanıyor ama Lissom'un kullandığı spesifik model (lite/full/heavy) için ölçülmüş bir accuracy/landmark-confidence tablosu bulunamadı. Kapatmak için: kendi test setiyle (birkaç supine poz + tek kamera) ampirik ölçüm gerekir.
2. **GOWOD'un test mekanizması gerçekten CV mi, yoksa video-rehberli öz-değerlendirme mi?** — Kaynaklar (App Store, resmi site) bunu netleştirmiyor; uygulamayı canlı test etmeden (App Store/Play Store'da kurup deneyerek) kesin cevap alınamaz.
3. **"Morning flow", "spinal mobility" ve "wind-down/sleep" paketleri için endüstri-standardı süre/poz-sayısı normu var mı?** — Aranan kaynaklarda nicel veri çıkmadı; bu üç paket için ürün ekibinin kendi süre kademesini (örn. 5/10/15 dk) belirlemesi gerekecek, dışarıdan bir "doğru sayı" yok.

## Kaynaklar

- https://www.arhantayoga.org/blog/which-yoga-style-best-fits-your-needs/
- https://www.arhantayoga.org/blog/yin-yoga-vs-restorative-yoga/
- https://yogajala.com/yoga-sequencing-principles-peak-pose/
- https://jennirawlingsblog.com/blog/yoga-pose-counterpose-rules-are-they-necessary (erişilmedi — sadece başlık/özet görüldü, içerik detaylı okunmadı)
- https://yoga.com/practice-sequences/yoga-for-desk-workers-a-short-practice-that-can-help-your-body
- https://myyogateacher.com/articles/hip-openers
- https://dailyburn.com/life/fitness/yoga-shoulder-stretches/
- https://www.atipt.com/pre-post-workout-stretches/
- https://pmc.ncbi.nlm.nih.gov/articles/PMC10280249/
- https://arxiv.org/pdf/2503.06012
- https://learnopencv.com/yolov7-pose-vs-mediapipe-in-human-pose-estimation/
- https://arxiv.org/pdf/2405.03545
- https://yogauonline.com/yoga-practice-teaching-tips/yoga-for-beginners/english-or-sanskrit-pose-names/
- https://apps.apple.com/us/app/gowod-mobility-stretching/id1227834875
- https://www.gowod.app/
