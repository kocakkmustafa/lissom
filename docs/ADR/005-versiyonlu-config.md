# ADR-005 — Ölçüm ve içerik versiyonlu config'te; motor içerik-bağımsız

**Tarih:** 2026-07-26 · **Statü:** kabul · **Bağlam:** aile kuralı (Gravita ADR-004, JabLab ADR-004, Choreia K1)

## Karar

Metrik tanımları, test bataryası, içerik paketleri ve kural setleri **versiyonlu JSON**'da yaşar. Motor bunları yorumlar; hiçbir metrik, test veya hareket koda gömülmez. Yeni test/paket eklemek kod değişimi gerektirmez.

## Neden

Kütüphane büyüyecek: 72 hareket, 3 yoga paketi ve 2 program profiliyle başlıyoruz, plan uzun vadede sekiz profil öngörüyor. Her yeni içerik motor koduna dokunuyorsa, içerik üretimi mühendislik darboğazına girer.

Ek fayda ölçüldü: config seviyesinde kısıt koyabilmek gerçek hataları yakaladı. Açı metriklerinde `plane` alanını **zorunlu** kılmak (L-009) ve `angle_vertical`+`transverse` kombinasyonunu yükleme anında **reddetmek** (L-011), aynı hataların bir daha yazılmasını mimari olarak engelliyor.

## Reddedilen alternatifler

- **Metrikleri kodda tutmak:** hızlı başlar, her içerik eklemede yavaşlar.
- **Şemasız JSON:** sürüm uyumsuzluğu sessizce yorumlanır; `schemaVersion` kontrolü sert tutuluyor.

## Sonuç

Python referans yorumlayıcısı ve native motor **aynı config'i** okur ve aynı sayıyı üretmek zorundadır (G4 differential test).
