# Lissom — Ürün Yol Haritası (G0→G10)

**Tarih:** 2026-07-26 · **Statü:** Kurucu-onaylı çerçeve; oturumlar bu haritayı işler, sapmalar DEFTER'e.
**Hiyerarşi:** `00-AILE-MIMARISI.md` (D4 dahil) > `20-URETIM-SURECI.md` > `10-ARAC-KATALOGU.md` > bu dosya > `lissom-plan.md`.
**Ürün dili: İNGİLİZCE** (UI+içerik+ses+store). İç doküman Türkçe.

> ⚡ **REVİZYON 2026-07-26 (kurucu direktifi — KURUCUSUZ VERİ FABRİKASI + GENİŞ KÜTÜPHANE, M-F-13..16):** Bu haritadaki "kurucu çekimi / fixture çekim listesi kurucuya" varsayımları KALDIRILDI — kurucu çekim YAPMAZ. Birincil veri = kamu-video hasadı + sentetik (katalog §6.2; ücretli klip İPTAL — M-F-17); doğrulama = §6.3 merdiveni; öğretim görselleri = §6.4 katmanlı AI-eğitmen hattı (T1 = iskelet-sürümlü uygulama-içi avatar, $0 ve form-garantili). Kurucudan yalnız onay/kapı kararları + EN SONDA (G8'de, deneme amaçlı) cihaz-benchmark'ı beklenir — erken fazlar benchmark'ı BEKLEMEZ. **Geniş kütüphane:** Test bataryası + yoga asana aileleri + esneklik içerikleri GENİŞ hasat edilir (PT-kanal havuzu: Physiotutors/E3 Rehab/Clinical Physio/Movement by David + Emmet Louis/Merrick); G1-b gerçek-video bacağı kamu-video + MM-Fit/AIST++ + sentetik + gerekirse ücretli klip ile ölçülür; iç doğrulama çalışması TestFlight beta rızası/ücretli klip yoluyla. Sorularını bu çerçevede kendin karara bağla — kurucuya soru YOK.

## 1. Kimlik ve Kuzey Yıldızı

**Lissom: Mobility & Yoga** — kamerayla hareket kapasiteni ölç, sana özel günlük programı hocan yanındaymış gibi sesli rehberlikle uygula, 4 haftada yeniden ölç. Aile sırası **1**: pose modelinin en güvenilir bölgesi (yavaş/statik pozlar) + en geniş pazar + ailenin ortak değerlendirme katmanı (Gravita bilek/omuz ön-şartı, JabLab ısınması buradan beslenecek).
**Kuzey Yıldızı metriği:** 4-hafta yeniden-test tamamlama oranı (ölç-geliş döngüsü kanıtı). İkincil: geçerli-ölçüm oranı, D7/D30 retention.
**Vizyon (tavansız, §1.1):** tam bir esneklik/yoga stüdyosu koçu — V1 sınırları sıralamadır, tavan değil.

## 2. Konumlandırma ve rakip boşluğu (G0 araştırma özeti — kanıtlı)

| Rakip | Ne yapıyor | Boşluk |
|---|---|---|
| GOWOD (~$14.99/ay) | 10-12dk mobilite testi → skor → günlük program | Testin CV mi öz-değerlendirme mi olduğu BELİRSİZ → elle teardown görevi (G0). Sesli gerçek-zamanlı koçluk yok |
| Bend / StretchIt / Pliability ($15-20/ay) | Video kütüphanesi | ÖLÇÜM YOK — takip-et videosu |
| Down Dog | Algoritmik yoga seansı | Tercihe göre kişiselleştirme, ölçüme göre değil; kamera yok |
| Zenia (ölü) | Gerçek-zamanlı CV yoga geri bildirimi (2019-22) | Terk edilmiş — başarısızlık nedeni doğrulanamadı; ders çıkarımı temkinli |
| Amazon Halo Movement (ölü, 2022) | 5-hareket CV değerlendirmesi, hakemli doğrulama (npj Digital Medicine) | İş kararıyla kapandı, teknik başarısızlık değil — **test bataryamızın ŞABLONU** |

**Konumlandırma cümlesi (EN):** *"The only mobility app that actually measures you — camera-based assessment, a daily plan built from YOUR limits, and a voice coach that guides every hold."* Literatür dayanağı: FMS/OHS'nin belgeli zaafı = değerlendirici öznelliği → objektif CV skorlaması bunun ilacı (pazarlamada kullanılabilir, abartısız).

## 3. Teknik mimari kararları (katalogdan bağlanmış)

- Pose: MediaPipe Pose Landmarker — assessment modunda **heavy**, günlük seans modunda **full** (katalog §1). Native köprü + Pigeon + kanal diyeti (katalog §2).
- Test bataryası: **Halo-Movement-modelli 8-10 test** (plan §5 listesi korunur; overhead squat + single-leg stance + overhead reach çekirdek — hakemli emsalli hareketler). Her test bağımsız modül (plan §11 arayüzü) + geçersizleştirme kuralları.
- 2D sınırı DÜRÜSTLÜĞÜ: iç rotasyon gibi 3D kompanzasyonlar tek kamerayla güvenilir ölçülemez → bu eklemler geniş skor bandı/nitel dil alır (araştırma bulgusu; asla eşit hassasiyet imâ edilmez).
- Skor: "Lissom Score / hareket kapasitesi" dili — YAŞ DİLİ YOK (D4). Bileşen skorları açıklanabilir.
- Program motoru: deterministik rule engine (plan §8); yoga akışları = program motorunun İÇERİK PAKETLERİ (D4 — ayrı ürün değil). Her egzersiz seçiminin nedeni loglanır.
- Sesli koç: hibrit voice-pack + sistem TTS (katalog §5). Poz tutuşlarında nefes/süre sayan gerçek-zamanlı rehberlik = çekirdek vaat.
- Depolama: Drift/SQLCipher deseni (LifeOS mirası), local-first; ham video cihazda.

## 4. Faz planı

### G0 — Derin araştırma & bilgi kütüphanesi (çıktı: `docs/research/`)
1. Bu haritanın §2 tablosunu elle doğrula: GOWOD'a gerçek hesapla gir, mobilite testini uçtan uca çöz (CV mi? skorlama nasıl?); Bend/Pliability güncel fiyat ekran görüntüsü. `competitive-intelligence-analyst` protokolüyle.
2. Test bataryası bilim dosyası: Halo protokolü + JMIR 2026 kamera-pozisyon çalışması (e82412) tam metin + eklem-başına ROM güvenilirlik notları → her testin ölçüm tanımı, güven bandı, geçersizlik koşulu.
3. Yoga içerik taksonomisi (D4): stil/paket kataloğu (morning flow, desk-relief, deep stretch...), her paketin hangi bölgesel skoru beslediği haritası.
4. Müfredat kütüphanesi: egzersiz havuzu (~60-80 hareket; ekipmansız; İngilizce adlar + niyet + regresyon/progresyon + güvenlik notu) — `movement-science-advisor` ilk-geçiş denetimiyle.
**Kapı:** her iddia URL'li; müfredat uzman-doğrulama ihtiyaç listesi çıkmış.

### G1 — V0 fizibilite kapısı (Lissom'a özgü)
1. Fixture çekim listesi üret (İLK iterasyon — kurucu paralel çeksin): 8-10 test × {2-3 vücut tipi, 2 ışık, 2 kıyafet, 2 mesafe} + bilinen-açı referans çekimleri (goniometre/açıölçer karşılaştırmalı).
2. Kayıtlarda MediaPipe (full vs heavy) landmark güven + açı tekrarlanabilirlik ölçümü; test-başına geçerli-ölçüm oranı; kamera-pozisyon hassasiyet matrisi.
3. Eşik önerileri: hangi test hangi güven bandında "ölçülebilir" sayılır; hangi testler V1'den düşer.
**Kapı çıktısı (kurucuya):** test-başına güvenilirlik tablosu + V1 test seti önerisi + D4 yoga-paket bağlanma tasarımı.

### G2 — PRD + teknik tasarım
PRD.md (İngilizce ürün sözlüğüyle): akışlar (onboarding→safety screen→kalibrasyon→assessment→skor→program→günlük seans→haftalık mini test→4-hafta re-test), veri modeli (plan §14), rule-set config şeması, ADR'ler (model varyant politikası, kanal sözleşmesi, skor formülleri). `architect` + `uiux-designer` (akış) danışmanlığı.

### G3 — Veri & fixture kütüphanesi
Fixture JSON şeması (katalog §6) ile: kurucu çekimleri + InfiniteRep uygun klipler işlenir; her test için ≥1 doğru + ≥2 hatalı/geçersiz fixture; replay harness motion-core'da kurulur ve CI'a bağlanır.

### G4 — Motor inşası (⚠️ İLK AİLE APP'İ: motion-core çekirdeği BURADA kurulur)
1. **motion-core v0.1.0** (ayrı repo, semver): kamera kalibrasyon sihirbazı çekirdeği · pose bridge (Pigeon sözleşmesi) · landmark güven kapısı · temporal smoothing · vücut-oranı normalizasyonu · state-machine çatısı · versiyonlu rule-set motoru · feedback önceliklendirici+cooldown · skor bileşen çatısı · replay/fixture harness · Drift/SQLCipher yerel depolama · TTS/ducking ses modülü. Her modül fixture-testli, app'siz yeşil.
2. Lissom motoru (app reposunda): 8-10 test modülü (state-machine + metrik + geçersizleştirme + skor haritalama) · bölgesel skor + Lissom Score hesabı · program rule engine (2 profil: General Mobility, Desk Worker) · seans rehberi (poz süresi/tekrar sayımı).
**Kapı:** tüm motor fixture-replay'de yeşil; UI'sız CLI/test çıktısıyla assessment uçtan uca simüle edilebiliyor.

### G5 — İskelet uygulama (alpha, İngilizce)
Flutter iskelet: tüm akışlar cilasız çalışır — onboarding, kalibrasyon, assessment (canlı kamera + overlay), skor ekranı, program, günlük seans (sesli koçlu), geçmiş, ayarlar. i18n anahtar altyapısı (yalnız `en` dolu). Ölü buton 0. **Impeller kamera-ekran benchmark'ı burada.** `mobile-runtime-tester` sweep.

### G6 — İçerik üretimi
1. Müfredat config'leri: 2 program profili + yoga içerik paketleri (D4; V1'de 2-3 paket) — versiyonlu rule-set.
2. Sesli koç replik kütüphanesi (EN): assessment yönlendirme, tutuş sayımı, düzeltme cue'ları, tebrik/dinlenme (~300-500 satır) → aile voice-pack hattıyla üretim (ElevenLabs/OpenAI toplu — HARCAMA: kurucu onayı) + dinamik sayılar sistem TTS.
3. Egzersiz görsel anlatımları (V1: kendi çekimlerimiz/animasyonlu iskelet gösterimi — stok video lisans tuzağına girilmez).
**Uzman doğrulama ihtiyacı** (test güvenliği, egzersiz seçimi, skor dili) manuel listeye.

### G7 — UI giydirme (Claude Design)
`uiux-designer` akış onayı → Claude Design'da görsel kimlik (sakin/ölçüm-odaklı estetik; skor görselleştirmesi = ürünün vitrini) → token sistemi (`design-systems-architect`) → uygulama. `design-review-auditor` + `visual-polish-critic` turu; dark/light + %200 font + taşma temiz.

### G8 — Sertleştirme (beta)
Cihaz matrisi ölçümü (fps/ısı/pil — düşük-orta Android + eski iPhone) · adaptif kalite politikası doğrulaması · a11y turu (`accessibility-specialist`: sesli koçun VoiceOver'la barışı!) · crash raporlama + gizlilik-temiz analytics (`product-analytics-strategist`: karar-besleyen az-event seti; geçerli-ölçüm oranı, re-test oranı) · offline çalışma kanıtı.

### G9 — Monetizasyon + uyum
- Paywall: **assessment-kapılı soft paywall** (ilk ölçüm ücretsiz + skor gösterilir → program/günlük koçluk abonelikte). Fiyat ÖNERİSİ katalog §8 koridorundan (`pricing-monetization-strategist`) → **kurucu onayı**. Trial 7-14 gün analizi.
- IAP: RevenueCat değerlendirmesi; sandbox kanıtı zorunlu; Opus bağımsız doğrulama (riskli sınıf).
- Uyum: `privacy-data-guardian` (KVKK/GDPR; kamera+vücut verisi; on-device beyanı) + `store-policy-officer` (wellness dili, Apple 5.1.1, kamera izin metinleri) + FDA general-wellness kopya süzgeci (plan §13 yasak ifadeler) + Art.50 değerlendirmesi (LifeOS şablonu).

### G10 — Pazarlama & lansman hazırlığı
- ASO (`marketing-aso-specialist`): başlık "Lissom: Mobility & Yoga" + anahtar kelime seti (mobility test, flexibility, stretching, ROM, yoga); ekran görüntüsü anlatısı: ölçüm→skor→program→gelişim eğrisi (gerçek ekranlar; sahte grafik yok — §7 ölçüm dürüstlüğü).
- Lansman planı (`growth-marketing-strategist`): soft launch → ölçüm döngüsü kanıtı → genel lansman; reklam kreatif brief'leri (`brand-identity-designer`): "before/after ROM" dürüst anlatı.
- **Submission = kurucu tetiği.**

## 4.5 Dalga planı (kapsam otoritesi: `LISSOM-BLUEPRINT.md`)

G-fazları dalga-bazlı koşulur: **her dalga için G3→G6 içerik/motor döngüsü, platform katmanı bir kez (G5'te)** — standart §4.2.

| Dalga | Kapsam | Fizibilite notu |
|---|---|---|
| **W0** | PRD blueprint kapsamıyla güncelle · IA çatısı (tüm aile sayfaları "yakında" durumlu) · platform katmanı · **batarya genişletme** (ASLR + plank/rotasyon-stabilite; tek-bacak denge ve overhead squat zaten V1 havuzunda) | G1-a metodolojisi yeni testlere aynen uygulanır |
| **W1** | Yoga: Hatha · Vinyasa · Yin (Tier-1 pozlar) + esneklik hedefleri (Front/Middle Split · Kalça · Hamstring) + günlük program motoru → G5 iskelet → G6 içerik | Vinyasa'da poz-poz düzeltme İDDİASIZ; akış+nefes-tempo koçluğu ("flow modu" gevşek skor) |
| **W2** | Chair/Office Yoga + popülasyon paketleri (Masa-başı · Koşucu · Lifter) + Backbend/Omuz-açma | Backbend wheel ⚠️ güven-sönümleme |
| **W3** | Ashtanga temel seri + aile ısınma paketleri (JabLab/Choreia/Gravita deep-link) + nefes/meditasyon (yalnız ses-rehberli) | **Nefes kamerayla ÖLÇÜLMEZ** — iddia yok |
| **W4** | Senior Mobility (doktor-onayı kapısı) + Prenatal (ACOG-hizalı güvenli-poz alt-kümesi) | En son; uzman turu zorunlu |

**Poz kütüphanesi katmanları:** Tier-1 ~150-250 poz (ayakta/oturan/diz-üstü) tam koçluk · Tier-2 yer/supine gevşek-skor · Tier-3 inversiyonlar avatar-demo-only. "Complete" tanımı bu üç katmandır.

**Kapsam dışı** (tek "Neden yok?" sayfasında açıklanır): çocuk paketi · kamera ile nefes/meditasyon ölçümü · klinik FMS/tanı/düşme-riski iddiası · Bikram · hip iç/dış rotasyon ölçümü (L-006).

## 5. Fixture & veri planı — ⚡ REVİZE (M-F-13/17)

**Kurucu çekimi YOK.** `FIXTURE-CEKIM-LISTESI.md` artık **opsiyonel şablon** (ileride TestFlight kohortu veya gönüllü çekim olursa protokol hazır dursun diye korunuyor).

Birincil: **kamu PT/klinik kanal hasadı** (≥3 bağımsız eğitmen/hareket — `docs/harvest/`) + **kendi sentetiğimiz** (Unity Perception). Doğrulama merdiveni katalog §6.3:

| Kapı türü | Kaynak |
|---|---|
| Doğruluk (açı) | AIST++ (CC-BY) + MM-Fit (CC-BY — Zenodo'da teyit edildi) + sentetik |
| Güvenilirlik/çeşitlilik | Kamu-video çeşitliliği + sentetik vücut-tipi varyasyonu · TestFlight beta (ileride) |
| Cihaz (fps/termal) | **G8'de, deneme amaçlı** — erken fazlar beklemez; o güne dek muhafazakâr fps varsayımı, eşikler "cihazda doğrulanacak" etiketli |

❌ **Yasak-varsayılan:** Human3.6M · MPI-INF-3DHP · 3DPW · AMASS · BEDLAM (yazılı izinsiz iç-QA'da bile) · **Fit3D** (`/legal` okundu: ticari kullanım VE eşik/parametre türetme açıkça yasak) · ücretli klip (M-F-17) · Yoga-82 (non-commercial, yalnız taksonomi).

## 6. Riskler / DEFTER tohumları
L-001 (mevcut): aşırı-zorlama + 3D yanılsaması — ağrı-durdurma akışı tavizsiz. Yeni: L-002 GOWOD mekanizma belirsizliği (G0'da kapat) · L-003 2D iç-rotasyon sınırı (skor bandı politikası) · L-004 "Preview" statülü MediaPipe sürüm pinleme · L-005 assessment-doğrulama çalışması yapılmadan "measures" iddiasının sınırlandırılması.

## 7. Manuel / kurucu görevleri — ⚡ REVİZE

~~Fixture çekimleri~~ **DÜŞTÜ** (M-F-13: kurucu çekim yapmaz) · ~~ücretli klip bütçesi~~ **DÜŞTÜ** (M-F-17).

Kalan: mobilite/fizyo **uzman turu** (batarya + senior/prenatal kapıları) · iç doğrulama çalışması (TestFlight beta kohortu kurulunca) · **cihaz-benchmark (G8, deneme amaçlı)** · voice-pack üretim bütçesi · fiyat onayı · store submission · domain (lissom.fit / lissom.yoga — M-006) · GOWOD hesabı (ücretliyse onay).

## 8. Oturum örgütlenmesi
Ana oturum Fable/high; fan-out `sonnet`; IAP/güvenlik doğrulaması Opus; /loop ile tempo; kapı kanıtı olmadan faz geçişi yok. Başlangıç promptu: vault `20 Şirketler/Motion/🚀 Başlangıç Promptu — Lissom`.
