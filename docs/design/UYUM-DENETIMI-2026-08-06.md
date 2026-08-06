# Uyum Denetimi — Lissom giydirme turu, 2026-08-06

Koordinatörün 19 maddelik kontrol listesine (giydirme görevi mesajı §4) karşı.
Üç sınıf — JabLab'ın eklediği ayrımla:
- **uyumlu** — yüzey var, kontrol edildi, uyuyor.
- **ihlal** — yüzey var, kontrol edildi, UYMUYOR (isimli açık bulgu).
- **ölçülmedi** — yüzey yok (bu turda giydirilmedi) YA DA soru bu turun
  kapsamı dışında; **"bilinmiyor" değil, "kapsam dışı."**

| # | Madde | Durum | Kanıt / gerekçe |
|---|---|---|---|
| ① | Dolum/gauge göstergesi yasağı | **uyumlu** | `battery_summary_view.dart` — hiçbir satırda fill-bar/halka/yüzde-kalp yok; `belowRange`'de dash bile pil-DIŞI düz metin (pil = sınıflandırıldı anlamı taşırdı) |
| ② | "Keep going!" tezahürat yasağı | **uyumlu** | Tüm kopya elle yazıldı, ünlem/tezahürat sıfır (`assessment_home.dart`, `what_lissom_doesnt_do.dart`, `battery_summary_view.dart`) |
| ③ | improved/worsened yasağı | **ölçülmedi** | Progress/trend yüzeyi bu app'te hiç yok — DESIGN-AHEAD-OF-CODE.md §1 |
| ④ | Mood takibi yok | **uyumlu** | Var olan üç yüzeyde de (home/summary/profile-sayfası) yok |
| ⑤ | Tıbbi dil yasağı | **uyumlu** | `wellness_lint.py` temiz (500 metin/8 dosya, config); yeni Dart kopyası `tools/wellness_lint.py`'nin HARD/SOFT listesine karşı elle de kontrol edildi |
| ⑥ | Çıplak skor yasağı | **uyumlu** | `_scoredRow`'da değer DAİMA pille yan yana; ekran kanıtı: `docs/kanit/giydirme-battery-summary-2026-08-06.png` |
| ⑦ | Streak/rozet baskısı yok | **uyumlu** | Var olan yüzeylerde yok; `assessment_history.dart`'ta (persistence katmanı) da streak/rozet alanı yok |
| ⑧ | Geri sayım estetiği yasağı | **ölçülmedi** | Retest-countdown / Home-dashboard yüzeyi yok |
| ⑨ | Bandın altına bant etiketi yasağı | **uyumlu** | Tip-düzeyinde imkânsız (`SummaryRow` belowRange için bant taşımıyor); ekran kanıtında (`giydirme-battery-summary-2026-08-06.png`) `Ankle Mobility` satırı görünür: `28.0 deg` + düz tire, pil YOK |
| ⑩ | Yarım oturum "kaydedilmedi" yasağı | **ölçülmedi** | Block complete yüzeyi yok |
| ⑪ | Yol-haritası sayfası/eşit-ağırlık yasağı | **ölçülmedi** | Library yüzeyi yok |
| ⑫ | Kesinlik taklidi yasağı | **uyumlu** | Aktif korundu: kamera-doğruluk dipnotu ("±5° typical error") BİLEREK yazılmadı — kod tabanında bu rakam hiç ölçülmemiş (tek ilgili ölçüm L-031, farklı sapma sınıfı). Bkz. DESIGN-AHEAD-OF-CODE.md §1, madde ⑱ |
| ⑬ | Dört/beş katman görsel ayrım | **uyumlu** | `docs/kanit/giydirme-battery-summary-2026-08-06.png` — `notCompared` (kum rengi kart + "single-exercise harvest round" rose-tint etiket) ile `notMeasured` (sebep başlık-konumunda, isim küçük/soluk) görsel olarak birbirinden VE `scored`/`belowRange`'den ayrı. Kapsam: toplu özet ekranı; bireysel tam-ekran varyantlar `ölçülmedi` (yüzey yok) |
| ⑭ | "Measurements not marks" — referanssız testler görünür, coming-soon yasak | **uyumlu** | Aynı ekran kanıtı: `Overhead Reach` gerçek değer (150.0 deg) + gerçek gerekçe metniyle görünür, "beta"/"coming soon" yok |
| ⑮ | Kütüphane katmanlaması | **ölçülmedi** | Library yüzeyi yok |
| ⑯ | "What Lissom doesn't do" — 5 kalem | **uyumlu** | `what_lissom_doesnt_do.dart`, tasarım kopyası birebir; ekran kanıtı `docs/kanit/giydirme-what-lissom-doesnt-do-2026-08-06.png` + `giydirme-tasma-stres-testi-375pt-2026-08-06.png` |
| ⑰ | Ağrı akışı her canlı ekrandan erişilebilir | **ölçülmedi** | Canlı-capture yüzeyi hiç yok |
| ⑱ | Kalıcı ölçüm-sınırı beyanı (küçük punto) | **ihlal** | Yüzey VAR (Battery Summary), beyan YOK. Bilerek yazılmadı: yazılacak tek kaynak "±5° typical error" idi ve HİÇ ÖLÇÜLMEMİŞ. Kapanması ÖLÇÜM ister (motion-cv-engineer), kopya değil |
| ⑲ | Kardeş ayrışması (mat kil/serif/yavaş vs. Ostinato'nun camsı dili) | **uyumlu** | `lissom_theme.dart` — opak kartlar/gradyan-dolgu, `BackdropFilter`/saydamlık hiç kullanılmadı; Newsreader serif + 520ms `easeOutCubic` glide (JabLab'ın keskin/hızlı dilinin karşıtı) |

## `hold_duration` sınıflandırması

**Konum:** `ventures/lissom/workspace/DEFTER.md` satır 232, `L-216`.

**Tek cümle:** `metric_coverage_test.dart`'ın `requiredGeometricMetrics()`
fonksiyonu `hold_duration`-sınıfı faz-türevi metrikleri **kasıtlı ve
belgeli** olarak dışarıda bırakıyor (kodun kendi yorumu: "metrik geometrik
değil, oturum/faz makinesi üretiyor") — yani **(a) `_blockerText`'in
null-dalındaki yorum bayat** ("buraya düşmek zaten bir kapı ihlali" iddiası
bu metrik sınıfı için yanlış), **test kör değil.**

## Ekran kanıtı envanteri (bu tur)

- `giydirme-battery-summary-2026-08-06.png` (19:03) — debug preview, gerçek
  fixture, `notCompared`+`notMeasured` katmanları
- `giydirme-home-2026-08-06.png` (19:04)
- `giydirme-what-lissom-doesnt-do-2026-08-06.png` (19:04)
- `giydirme-tasma-stres-testi-375pt-2026-08-06.png` (19:28) — en-dar-cihaz
  taşma stres testi (L-214)
- `sim-canli3-engelli9.png` (önceki tur, kamera entegrasyonu)
