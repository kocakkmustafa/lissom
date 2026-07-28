# LISSOM — Tam Kapsam Blueprint (oturumun kapsam otoritesi)

**Tarih:** 2026-07-28 · **Statü:** KURUCU-ONAYLI ("ekledikleri yeterli"). Ortak omurga: motion-core `docs/30-URUN-BLUEPRINT-STANDARDI.md` (ÖNCE onu oku).
**Nihai ürün:** "Mobility & Yoga" — ölç→programla→yeniden-ölç döngülü; tam değerlendirme bataryası + yoga stilleri + esneklik-hedef programları + popülasyon paketleri, hepsi kendi sayfasında listelenen TAM mobilite uygulaması.

---

## 1. TAM KAPSAM — 4 dalga (kurucu-kesin)

| Dalga | İçerik ailesi (kendi sayfası) | Fizibilite | Not |
|---|---|---|---|
| 1 | **Değerlendirme Bataryası (genişletilmiş):** V1 seti + tek-bacak denge, ASLR, overhead squat, plank/rotasyon-stabilite | ⚠️ FMS-tarzı ama KLİNİK DEĞİL; eksen-rotasyon testleri sınırlı (L-006 korunur) | Batarya sayfası = ürünün kalbi; her test kendi alt-sayfası + trend grafiği |
| 1 | **Yoga: Hatha · Vinyasa · Yin** | ✅ ayakta/oturan; ⚠️ yer/flow (gevşek skorlama "flow modu") | Down Dog-vari seviye yapısı; Vinyasa'da poz-poz düzeltme İDDİASIZ, akış+nefes-tempo koçluğu |
| 1 | **Esneklik-hedef programları: Front/Middle Split · Kalça · Hamstring** | ✅ | Pliability "paths" modeli; haftalık açı-trend grafiği = farklılaştırıcı |
| 2 | **Chair/Office Yoga** + **Masa-başı · Koşucu · Lifter paketleri** + **Backbend · Omuz-açma programları** | ✅ (backbend wheel ⚠️ güven-sönümleme) | Chair yoga aylık ~60k arama, hızlı büyüme |
| 3 | **Ashtanga temel seri** + **AİLE ISINMA PAKETLERİ** (Dövüşçü→JabLab · Dansçı→Choreia · Calisthenics→Gravita; deep-link) + **Nefes/Meditasyon (yalnız ses-rehberli)** | ✅ | Nefes kamerayla ÖLÇÜLMEZ — iddia yok; aile çapraz-satış |
| 4 (temkinli) | **Senior Mobility** (doktor-onayı kapısı + tanı-değil dili; tek-bacak-denge trendi akademik emsalli) + **Prenatal** (sert medikal kapı; ACOG-hizalı güvenli-poz alt-kümesi: derin backbend/twist yok, 20. haftadan sonra sırtüstü yok) | ⚠️ sorumluluk-yönetimli | En son; uzman turu zorunlu |
| Poz kütüphanesi | **Tier-1 ~150-250 poz** (ayakta/oturan/diz-üstü) tam koçluk · **Tier-2** yer/supine gevşek-skor · **Tier-3** inversiyonlar avatar-demo-only | katmanlı | "Complete" tanımı bu üç katmandır |

**❌ Kapsam-dışı ("Neden yok?"):** Çocuk paketi (model yetişkin-doğrulamalı + reşit-olmayan sorumluluğu) · kamera-nefes/meditasyon ölçümü · klinik FMS/tanı/düşme-riski İDDİASI · Bikram (ısı ortam işi) · hip iç/dış rotasyon ölçümü (L-006).

## 2. Bilgi mimarisi (standart §2'nin Lissom örneği)
Kütüphane → **Aile sayfaları**: Değerlendirme Bataryası · Yoga Stilleri (her stil kendi sayfası) · Esneklik Hedefleri (her hedef kendi sayfası: "Path to Splits") · Popülasyon Paketleri · Aile Isınmaları · Nefes/Meditasyon. Her sayfa: tanıtım + kurs/ders listesi + kişisel trend grafiği + ölçüm-dürüstlük kutusu. Ana sayfa: günlük program (assessment-türevli) + sonraki yeniden-test sayacı (Kuzey Yıldızı döngüsü).

## 3. Motor iş listesi
1. mocore ölçüm sözleşmesinin native (Dart/Kotlin/Swift) karşılığı — G1-a config'leri birebir (differential test).
2. Test motoru: state-machine + geçersizleştirme + varyant-başına güven eşiği (ConfidenceGate.forVariant) + StructuralValidator entegrasyonu (L-019).
3. MDC (minimum anlamlı değişim) eşiği hattı (L-021): test-retest ölçümünden türet; eşik altı fark "gelişme" DENMEZ.
4. Program rule-engine (assessment→günlük plan; içerik=paket) + flow-modu (Vinyasa gevşek skor).
5. Provenance alanları her TestAttempt'e (L-022) + kalibrasyonsuz-skor-gösterme yasağı (L-025 → sertleşti: doğrulama öncesi yalnız nitel bant).

## 4. İçerik hattı
PT/klinik kanal havuzu (Physiotutors, E3 Rehab, Clinical Physio, Movement by David, NASM/Brookbush) + esneklik uzmanları (Emmet Louis, Tom Merrick) → test-başına ≥3 eğitmen video-düzeyi teyit → referans + tolerans → yoga stil sayfaları için asana referansları (Tier-1 öncelik) → program config'leri → voice-pack (EN; tutuş sayımı/nefes ritmi) → iskelet-avatar dersleri. Doğrulama: MM-Fit/AIST++ + kendi sentetik + TestFlight beta rızası (§6.3; ücretli klip YOK — M-F-17).

## 5. Görev backlog'u (dalga-bazlı)
**W0:** G2 PRD güncelle (bu blueprint kapsamıyla) + IA çatısı (tüm aile sayfaları "yakında" durumlu) + platform katmanı + batarya-genişletme (4 yeni test G1-a metodolojisiyle).
**W1:** Hatha/Vinyasa/Yin sayfaları (Tier-1 pozlar) + 3 esneklik-hedef programı + günlük program motoru → G5 iskelet → G6 içerik.
**W2:** Chair yoga + 3 popülasyon paketi + backbend/omuz programları.
**W3:** Ashtanga + aile ısınma paketleri (deep-link) + ses-rehberli nefes/meditasyon.
**W4:** Senior (kapılı) + Prenatal (kapılı) + kapsam-tamamlama turu.
Her dalga sonunda: wellness-dil süzgeci CI + runtime sweep + DEFTER + vault.

## 6. Lissom-özel platform deltaları
Yeniden-test döngüsü + hatırlatma sayacı · açı-trend grafikleri (haftalık) · aile deep-link'leri (ısınma paketleri) · HealthKit "Yoga/Flexibility" workout + Mindful Minutes (nefes) yazımı.

## 7. Dürüstlük/güvenlik (Lissom-özel)
"Yaklaşık ölçüm" dili + kamera-koşul bağımlılığı açık · ağrı-durdurma akışı tavizsiz (L-001) · yaş dili YOK ("Lissom Score") · FDA general-wellness kopya süzgeci her içerik dalga-sonunda CI'da · senior/prenatal kapı metinleri uzman-onaylı.

## 8. Manuel-sona listesi (kurucu)
Mobilite/fizyo uzman turu (batarya + senior/prenatal kapıları) · iç doğrulama çalışması (TestFlight beta kohortu kurulunca) · cihaz-benchmark (G8) · fiyat onayı · voice-pack bütçesi · submission.
