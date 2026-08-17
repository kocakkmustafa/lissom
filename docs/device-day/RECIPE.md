# Cihaz günü reçetesi — Lissom (`L-347`, 2026-08-17)

**Amaç:** kurucu telefonunu bağladığında beş dakikada yürünecek, üç adımlı
bir akış. **Kurulum** (adım 2) otomatik/betiklenebilir — **yürüyüş**
(adım 3) kurucunun elini ister (`H-9`: fiziksel cihazda dokunuş MCP ile
sürülemez, simülatör araçları yalnız simülatör listeler).

Şema Ostinato'dan alındı (aile-geneli emsal, orkestratörün kendi sevki);
adımların içeriği Lissom'un kendisi. **Aile-geneli tuzaklar** (dört hatta
bulunan) paylaşılan tek yerde:
`motion-core/workspace/CIHAZ-GUNU-AILE-RECETESI.md` — burası yalnız
Lissom'un kendi yürüyüş tablosunu taşır, İÇERİK kopyalanmadı.

⚠️ **Adlandırma notu (dürüstçe yazıldı):** Lissom'un ön-uçuş betiği
`tools/a12_device_preflight.sh` (BASH, aile şemasının Python'u değil) —
`L-313`te, aile şeması yaygınlaşmadan ÖNCE bağımsız yazıldı. `docs/A12-
KOSUM-HATTI.md` bu betiğin TAM anlatımını taşıyor (bu dosya onun YERİNE
geçmiyor, ailenin beklediği `docs/device-day/RECIPE.md` konumuna bir
KÖPRÜ). ✅ Ölçüldü: betik aile-geneli reçetenin §0b (iki profil dizini)
ve §0c (`ProvisionedDevices` DOLU profili "en yeni" tarihliye tercih
etme) tuzaklarının İKİSİNE de yapısal olarak bağışık — `profile_match_
check()` tek bir "en iyi" profil SEÇMİYOR, bundle'ı kapsayan TÜM
profilleri tarıyor ve cihazı İÇEREN herhangi biri varsa yeşil yakıyor.
Bu, Ostinato/Gravita'nın orijinal `find_<app>_profile()`ından (tek profil
seçip yalnız onu kontrol eden) **yapısal olarak farklı ve bu iki tuzağa
karşı bağışık** bir desen — aileye bildirilecek.

---

## 0 — "Eşleşmiş" ≠ "bağlı" + profil durumu

`motion-core/workspace/CIHAZ-GUNU-AILE-RECETESI.md §0`/`§0b`/`§0c`ye bak
(USB-ikinci-kaynak doğrulaması + profil tuzakları). **Lissom'un kendi
ölçümü** (aile reçetesinin `§0b` tablosu, 2026-08-16): geliştirme profili
**14 Ağustos**, kurucunun telefonu dâhil **4** cihaz kayıtlı — aile
sıralamasında *"4/5 hazır"* grubunda.

## 1 — Ön-uçuş (30 saniye, komut satırından)

```bash
./tools/a12_device_preflight.sh
```

Tam anlatım + çıktı örneği: `docs/A12-KOSUM-HATTI.md`. Betik `⛔ ÖLÇÜLEMEDİ`
ile `❌ YOK`u ayırır (`L-323`) — cihaz ulaşılamazken "hüküm yok" der,
"portal kaydı gerekir" DEMEZ (o ayrım kanıtlanmamış bir işi icat etmez).

⚠️ `⛔` dönerse aşağıdaki adım 2'ye geçme — önce profili tazele:
```bash
xcodebuild -workspace ios/Runner.xcworkspace -scheme Runner \
  -configuration Release -destination "id=<GERÇEK-UDID>" \
  -allowProvisioningUpdates build
```

## 2 — Kurulum (tek komut, `--release`)

```bash
flutter install --release -d <cihaz-adı-veya-id-öneki>
```

🔴 **Kanıt `--release` olmalı** (aile reçetesi §1 madde 2) — debug paketi
cihazda `signal 11` ile düşebilir; *"cihazda çöktü"* raporunun çoğu zaman
gerçek sebebi budur, ürünün kusuru değil.

## 3 — LaunchImage + ikon — İKİSİ de bugün ÖLÇÜLDÜ, ikisi de gerçek

Aile reçetesi §3'ün iki ayrı ekseni Lissom'da AYRI AYRI doğrulandı (`L-341`):
```
storyboard backgroundColor: RGB(0.953, 0.929, 0.914) — tema rengi, Flutter varsayılanı DEĞİL
LaunchImage*.png:            150×150 / 300×300 / 450×450 — 1×1 şablon DEĞİL
```
Cihaz gününde tekrar bakılacak TEK şey: bu ikisinin GERÇEK cihazda (simülatör
değil) doğru göründüğü — renk/boyut kanıtı burada duruyor, görsel doğrulama
cihaz gününün kendi işi.

## 4 — Yürüyüş tablosu (kurucunun eli) — Lissom'un kendi ekranları

| # | Ekran/eylem | Ne YAPILACAK | "Çalışıyor" NASIL görünür | Sorun işareti |
|---|---|---|---|---|
| 1 | İlk açılış | Wellness feragatnamesini oku, kabul et | `OnboardingFlow` kamera adımına ilerler | Feragatname atlanıyor/takılıyor |
| 2 | Kamera izni | İzin iste ekranını gör, izin ver | Sistem izin diyaloğu çıkar, kabul sonrası akış devam eder | Diyalog çıkmıyor / uygulama izinsiz devam ediyor |
| 3 | Kütüphane | Assessment battery kartını aç | Başlık altında `"$total tests · $live measurable by camera in this build"` yazısını oku — `$total` **12** olmalı, `$live` köprüden TÜRETİLİR (bu turda elle sayılmadı, ekrandan oku) | `$total` 12 değil / `$live` 0 / sayı hiç görünmüyor |
| 4 | Kamera kurulum uyarısı | Test mesafesi/çerçeveleme talimatına uy | Baş+ayak çerçeve içinde kalınca uyarı kayboluyor | Uyarı hiç kaybolmuyor / yanlış pozitif |
| 5 | Bir test koş (ör. `Deep Squat`) | Hareketi tamamla | Ölçüm biter, sonuç ekrana gelir (değer + birim) | Donuyor / sonuç hiç gelmiyor / yanlış birim |
| 6 | Sonuç okuma | Değeri ve bandı oku | Sayı + tarih görünür, "improved/worsened" dili YOK | Karşılaştırma dili sızmış (kapı yakalamalı, gözle de bak) |
| 7 | Test Detay sayfası | Az önceki testin geçmişine gir | Son değer + ham liste (tarihli) görünür | Liste boş/yanlış test gösteriyor |
| 8 | Progress sekmesi | Genel ilerleme kartlarını gör | "The number lives on each test's own page" kartı doğru yönlendiriyor | Eski "kayıp" dili görünüyor |
| 9 | Profile sekmesi | Ayarlar/gizlilik kartlarını gör | "Reminders are not in this build" + hesap-yok mesajı tutarlı | Var olmayan bir özellik ima ediliyor |
| 10 | Uygulamayı kapat-aç | Soğuk başlatma | Onboarding'i tekrar göstermiyor, son durumdan devam ediyor | Onboarding'e geri düşüyor / veri kayboluyor |

⭐ **Aile reçetesinin ortak son maddesi burada da geçerli:** kamera
köprüsünün canlılığı (gerçek telefon + gerçek insan gövdesi) bugüne kadar
yalnız simülatörde koşuldu (`L-339`, `xcrun simctl`) — bu bir *"son
kontrol"* değil, **cihaz gününün asıl sorusu.**

---

## Kaynaklar

- Aile-geneli tuzaklar (İÇERİK burada TEKRARLANMADI):
  `motion-core/workspace/CIHAZ-GUNU-AILE-RECETESI.md`
- Ön-uçuş betiği + tam anlatım: `tools/a12_device_preflight.sh` ·
  `docs/A12-KOSUM-HATTI.md`
- LaunchImage/ikon kanıtı: `workspace/DEFTER.md` `L-341`
- Kamera-canlılık açığı: `workspace/DEFTER.md` `L-339` (simülatör kanıtı,
  cihaz kanıtı YOK)
