# Design ↔ Code Delta — Lissom giydirme turu (2026-08-06)

Kapanış artefaktı (aile standardı, Choreia emsali). Kaynak: `Lissom.dc.html`
(`claude.ai/design` `28cd0df6…`) ↔ bu turda yazılan Flutter kodu.

İki yön ayrı tutulur çünkü ikisi FARKLI risk taşır: birinci yönün ürünü
göze çarpar (eksik ekran fark edilir); ikinci yön SESSİZDİR — tasarımın
unuttuğu bir beyan, hiç eksik gibi görünmeden kaybolabilir.

---

## 1. Tasarım > kod (mockup'ta var, kodda karşılığı YOK)

Design paneline verilen brief aspirasyonel bir 24-ekranlı ürünü tasarladı
(4 sekme + 12-testlik canlı akış + gerekli hâller + ağrı yolu). Gerçek kod
bugün **3 ekrandan** ibaret (home listesi, batarya özeti, artı bu turda
eklenen bir statik sayfa). Bu tur KASITLI olarak aradaki boşluğu
DOLDURMADI — yalnız var olan yüzeyi giydirdi. Boşluk listesi:

| Mockup ekranı/grubu | Neden kodda yok | Not |
|---|---|---|
| **4 sekme** (home/library/progress/profile as nav destinations) | Uygulamada `BottomNavigationBar`/tab mimarisi hiç yok — tek ekran (`AssessmentHomeScreen`) | Nav mimarisi eklemek ürün-yapısı kararı, giydirme değil — koordinatöre |
| **Home dashboard** (today · retest countdown · continue · quick start) | Oturum/seri/zamanlama veri modeli yok; `AssessmentHomeScreen` yalnız test listesi | Home ekranımız görsel dili PAYLAŞIYOR ama mockup'ın SAYFA YAPISINI uygulamıyor |
| **Library** (assessment battery + 5 "coming" aile + arama/filtre + honesty box) | Yalnız tek aile (assessment battery) var; diğer 5 aile hiç kodlanmamış | — |
| **Progress** (kendine-göre trend, karşılaştırma-kapalı hâli) | Trend/geçmiş veri sunumu yok | `assessment_history.dart` bu bir UI ekranı DEĞİL — SessionRecord yazma/okuma katmanı |
| **Block intro / Test instruction / Calibration passed/failed / Live capture / Live capture warnings** | Kamera/pose UI **hiç yok** — `live_evaluator.dart`+`live_session_state.dart` motor katmanında var ama hiçbir Flutter widget'a bağlı değil | En büyük boşluk; sahte kamera-önizleme/iskelet-overlay YAPILMADI (gerçek olmayanı gerçekmiş göstermek olurdu) |
| **Bireysel sonuç ekranları** (Result scored/below range/no bands/not measured TAM EKRAN, "Next test"/"Repeat"/egzersiz kartı/"Why" detay sayfası ile) | Yalnız TOPLU görünüm (Battery Summary) var — dört katman orada KOMPAKT satır olarak uygulandı, tam-ekran birebir değil | §2'de ilgili not var |
| **Block complete** | Blok kavramı yok (tek batarya, blok ayrımı YAPILMADI) | — |
| **Loading / Error / Permission denied TAM EKRAN hâlleri** | Bunlar `AssessmentHomeScreen`'in `FutureBuilder` dallarında SATIR-İÇİ ele alınıyor, mockup'ın ayrı tam-ekran deneyimi değil | Davranış dürüst (hiçbir hâl atlanmadı) ama sunum mockup'tan farklı |
| **Pain flow ("Something hurts")** | Girişim noktası (`her canlı-tur ekranından erişilebilir`) — canlı-tur ekranı YOK, dolayısıyla girişim noktası da yok | Canlı-capture UI yazılınca bu akış da yazılmalı |
| **"Export" (Battery summary footer)** | Uygulanmadı | Düşük öncelik, isimli bekliyor |
| **Camera-model/accuracy dipnotu** ("Camera model 2.3 · ±5° / ±3 cm typical") | **KASITLI eklenmedi** — bu bir görsel/metin eksikliği DEĞİL: kod tabanında böyle bir doğruluk sayısı ÖLÇÜLMEMİŞ. Var olan tek ilgili ölçüm (L-031, medyan 11,29°/p95 37,47°) FARKLI bir sapma sınıfını ölçüyor. Bu rakamı yazmak §8 madde ⑫'nin (kesinlik taklidi) doğrudan ihlali olurdu | **Kapanmadan önce ÖLÇÜM ister, kopya işi DEĞİL** — motion-cv-engineer/movement-science-advisor |

## 2. Kod > tasarım (üründe var, mockup açık karşılık VERMEDİ)

Bu yön daha sinsi: tasarımın hiç düşünmediği bir gerçek-ürün beyanı,
"mockup'ta yok" diye sessizce budanabilir. Bulunanlar:

- **`notCompared` satırının uzun metni her zaman görünür, mockup'ın
  kompakt-tablo deseni "why" DOKUNUŞUYLA açılan bir katman ima ediyor**
  (Battery Summary mockup'ında hücre "no norm reference · **why**" —
  kısa, tıklanabilir). Kodda `userNote`+`promotionNote` HER ZAMAN satırda
  açık. Bilinçli seçim: tasarımın "why" davranışını taklit etmek bir
  detay-sayfası/BottomSheet mimarisi gerektirirdi (giydirme kapsamı DEĞİL);
  bilgiyi HER ZAMAN göstermek gizlemekten daha dürüst bir varsayılan.
  **Ürün davranışı sorusu — kalıcı mı, yoksa "why" dokunuşuna mı geçilsin
  → koordinatöre.**
- **Ham metrik-id sızıntısı (`shoulder_flexion_left · shoulder_flexion_
  right`) canlı satırların altyazısındaydı** — hiçbir mockup ekranı dahili
  metrik sözlüğünü kullanıcıya göstermiyor. **Bu turda FARK EDİLDİ VE
  KAPATILDI** (canlı satır artık yalnız ikon+ad; engel gerekçesi hâlâ
  satırda çünkü o gerçek kullanıcı-dili metin).
- **"What Lissom doesn't do" sayfasının AppBar başlığı "Profile" idi** —
  var olmayan bir sekmeye ait gibi okunuyordu (mockup'ta bu sayfa gerçekten
  Profile sekmesinin İÇİNDE yaşıyor, ama kodda öyle bir sekme yok). **Bu
  turda FARK EDİLDİ VE KAPATILDI** (başlık kaldırıldı, sayfa kendi serif
  başlığıyla tanıtılıyor).
- **`AssessmentHomeScreen`'in AppBar'ındaki bilgi-erişimi ikonla** (mockup
  hiçbir ekranda bu girişi göstermiyor çünkü mockup'ta bu bir Profile-sekme
  öğesi) — tasarımın nav mimarisi olmadığı için icat edilen, isimli bir
  köprü. Davranış değişmiyor, yalnız erişim yolu farklı.

## Özet

Tasarım > kod boşluğu **büyük ve BEKLENEN** (aspirasyonel brief, gerçek
kod yalnız 3 yüzey) — hiçbiri sahte/yarım inşa edilmedi. Kod > tasarım
tarafında **4 madde** bulundu; **2'si bu turda kapatıldı** (ham id sızıntısı,
yanlış başlık), **1'i isimli ürün-kararı** olarak koordinatöre bırakıldı
(`notCompared` her-zaman-açık vs. "why"-dokunuşu), **1'i ÖLÇÜM bekliyor**
(kamera doğruluk dipnotu — icat edilmedi).
