# Ashtanga başlangıç temelleri — 16 Ekim 2026

Mevcut app-owned kurs şeması ve JSONL kayıt deposu kullanılarak beşinci yazılı başlangıç kursu eklendi: `lissom.ashtanga.foundations.beginner@1.0.0`, **13 ders / 4 modül**. Yeni mimari, Shared Motion değişikliği, bağımlılık veya farklı ilerleme deposu yoktur. Önceki Hatha/sandalye/Vinyasa/Yin ders byte'ları korunur.

## Kapsam

| Dersler | Öğretilen sınırlı sonuç |
|---|---|
| a01–a03 | Ashtanga kimliği, nefes/bakış/sayım kavramları, yazılı alan/destek/çıkış planı |
| a04–a07 | Küçük iki ayaklı duruş/kollar, sığ katlanma/yarı doğrulma, sığ Utkatasana uyarlaması, ayrı sağ/sol kısa adım ve nötr dönüş |
| a08 / a10 | Geleneksel Güneşe Selam A'nın 9, B'nin 17 sayılı hareketinin **yazılı sıra haritası**; yer durakları fiziksel görev değildir |
| a09 / a11 | Yalnız öğretilen ayakta öğeleri kullanan, atlamaları belirtilmiş Lissom uyarlamaları; tam geleneksel Güneşe Selam A/B değildir |
| a12–a13 | Yazılı bağımsız yol planı ve sonraki hatırlama; fiziksel çalışma için a09/a11'e ve güncel hazırlığa dönülür |

Fiziksel hazırlık yalnız a04/a05/a06/a07/a09/a11 için gerekir. Geçmiş kayıt, günlük hazırlık veya gözlenmiş beceri yerine geçmez. İleri pozlar, sıçrama, lotus, bağlama, ters duruş ve tam alçak şınav zorunlu ilerleme şartı değildir. Okuma/katılım kaydı, geleneksel serinin veya fiziksel becerinin kabulü değildir.

## Birincil öğretim kaynakları

16 Ekim 2026'da kurum/öğretmenin kendi yayını üzerinden okunup doğrulanan referanslar:

- [K. Pattabhi Jois Ashtanga Yoga Shala — yöntem](https://kpjayshala.com/about-ashtanga.html): sekiz basamak, sıralı nefes/hareket/bakış kavramları ve eğitimli öğretmenin rolü.
- [AYI — geleneksel dizi haritası](https://www.ashtangayoga.info/ashtanga-yoga/traditional-practice-series/): selamlar, ayakta temeller, kapanış ve temel serinin ayrı olması.
- [AYI — Güneşe Selam A](https://www.ashtangayoga.info/ashtanga-yoga/surya-namaskara-a-sun-salutation/) ve [B](https://www.ashtangayoga.info/ashtanga-yoga/surya-namaskara-b-sun-salutation-b/): sayılı sıranın adları ve sağ/sol ayrımı.
- Aynı AYI dizilerindeki Samasthiti, yukarı kollar, Uttanasana A/B, Utkatasana ve Virabhadrasana A öğretim sayfaları: ilgili durak adları/yerleşimi. Tam URL'ler her dersin kaynak alanında ve kursun `sources` sözlüğünde saklıdır.

Kaynaklar **Lissom'un ayakta uyarlamalarını veya tüm kursunu onaylamaz**. Her kaynak için desteklediği ayrıntı ve desteklemediği kapsam uygulamada gösterilir. Kurumsal sayfalardaki arınma/detoks veya sağlık yararı anlatımları benimsenmedi. Özgün TR/EN metin dışında kaynak görseli, video veya lisanslı demonstrasyon kopyalanmadı. Gösterim medyası mevcut değildir.

## Yazılım davranışı ve kabul

SHA doğrulamalı loader, gerçek startup, Home/Library girişi, Progress katılım kartı, sürüm/kurs/hesap ayrımlı kalıcılık, tekrar, bitiş ve store hata/retry akışı mevcut bileşenlerle çalışır. Eksik/değiştirilmiş asset boş kursa düşmez. Gelecek derslerin incelemesi fiziksel adımları veya kaydı açmaz. İptal/background dönüşü kayıt üretmez ve hazırlığı yeniler. TR/EN 320 px / 2× metin testleri gerçek ders metinleriyle yürütülür.

Hedefli ilk son tur: **73 PASS** (Ashtanga, giriş recovery, envanter, gerçek startup ve owner-session dosyaları). Tam app/analyze/CI sonuçları ve exact kaynak kimliği `scratch/2026-10-16-lissom-ashtanga/RESULT.json` içinde kapatılır; sayılar örtüşür.

Önceki `6843499` main push CI run [38832903975](https://github.com/kocakkmustafa/lissom/actions/runs/38832903975) **668 PASS / 1 FAIL** ile sonlandı. Eski hesap-silme testinin sekiz event-loop turu gerçek fence dosya I/O'sunu beklemiyordu. `ab12c26` yalnız testi gerçek resource retirement olayına bağlar; kapanış/fence/erasure/replacement Auth beklentileri korunur. SDK, Core ve auth davranışı değişmedi. O başarısız koşu yeniden başlatılmadı; yeni kaynak kabulü ayrı tutulur.

## Açık kalanlar

Bu, tam Primary Series müfredatı veya tam fiziksel Ashtanga öğretimi değildir. Yetkin öğretmen/öğrenci incelemesi, bireysel fiziksel uygunluk ve teknik, kabul edilmiş demonstrasyon/lisans, sensör doğruluğu, gerçek cihaz/IAP/mağaza kabulü açık kalır. Native simülatör çalışması koordine edilen sırayı bekler. Mağaza yüklemesi ve simge değişikliği yapılmadı.
