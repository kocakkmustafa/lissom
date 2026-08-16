# Yokluk-iddiaları envanteri — L-343 (2026-08-17)

`H-44` (koordinatör, 2026-08-16): *"'bu yok' demek de bir iddiadır, yaptığınız
an yalan olur"* — orkestratör envanteri Lissom'da **12** yokluk-beyanı saymıştı
(desen: *"not in this build" · "have not built" · "no screen that" ·
"is not built" · "henüz yok"*). Bu tur o sayımı **canlı yeniden ölçtü** ve
kapsamı `H-23` gereği `lib/` dışına (`config/**/*.json`) genişletti.

⚠️ **Bu envanter bir kapı DEĞİL.** `test/stale_absence_claim_test.dart`nin
kendi belgesi bunu adıyla söylüyor: *"her yokluk cümlesi hâlâ doğru mu" bir
kapı değil, HÜKÜM ister.* O kapı yalnız **bilinen ve ölçülmüş** yalanların
geri gelmesini engelliyor (`_staleClaims` haritası). Bu belge o haritanın
**aday havuzu** — biri bayatladığında oraya taşınır.

## Yöntem — Türkçe-güvenli (`H-64`)

Shell `grep -i` Türkçe büyük harfi katlamıyor (`Ç/Ğ/İ/I/Ö/Ş/Ü`). İngilizce
desenler ASCII olduğu için `grep -iE` güvenli; Türkçe *"henüz yok"* için elle
katlama (Türkçe harf çiftleri) kullanıldı. Tarama `lib/**/*.dart` +
`config/**/*.json` — yalnız `lib/` YETMEZ (`H-13`: bir kapasite vaadi ile onu
yalanlayan cümle farklı dosya türlerinde yaşayabilir, tam da
`stale_absence_claim_test.dart`nin kendi `_capabilityClaimGate`i `config/`de
bir vaka bulmuştu).

## Envanter — dokuz canlı iddia, ikisi kod-belgesi (11), hiçbiri BAYAT değil

| # | konum | iddia (kısaltılmış) | çürüten ölçüm (bugün YOK) | sınıf |
|---|---|---|---|---|
| 1 | `profile_screen.dart:148` | *"Reminders are not in this build"* | `grep -rn "notification\|reminder" lib/` → yalnız bu cümle, hiçbir hatırlatıcı kodu yok | buildable-someday |
| 2 | `live_capture_screen.dart:431` | *"we have not built it"* (kamera önizlemesi) | `LiveCaptureScreen`de önizleme widget'ı yok (yorumun kendisi: "Ertelenmiş = YAPILABİLİR, biz yapmadık") | buildable-someday |
| 3 | `ia.dart:188` | *"Named, not in this build — no sessions are bundled"* | `isBuilt`/`itemsSource` alanlarından TÜRETİLİYOR — statik değil, kendi kendini güncelliyor | öz-düzelten (kod-türetilmiş) |
| 4 | `surfaces.dart:204` + `library_screen.dart:109` | *"Not in this build · \$blocker"* / *"Planned, not in this build (N)"* | `$blocker`/`pending.length` GERÇEK veriden hesaplanıyor | öz-düzelten (kod-türetilmiş) |
| 5 | `surfaces.dart:332` (`notTried`) | *"This has not been tried on a real phone"* | `A12` hâlâ KURUCUDA/cihaz-günü bekliyor (`PROGRESS.md:898`) — L-339'daki build+launch **SİMÜLATÖRDE**, gerçek telefonda DEĞİL | doğru, cihaz-günü'nde düşecek |
| 6 | `home_screen.dart:223-225` | *"does not set a date… we have not established [interval]"* | `grep -rn "interval\|reTest\|schedule" lib/` → aralık/hatırlatma mantığı yok | buildable-someday |
| 7 | `config/ia/library.v1.json:121` + `surfaces.dart:422-423` | *"our own validation study has not been run"* | DEFTER'de hiçbir referans-cihaz karşılaştırma kaydı yok (`grep`lendi) | buildable-someday, pahalı |
| 8 | `progress_screen.dart:174` | *"Lissom does not draw a trend line for you"* | `TestDetailScreen` (L-339) yalnız SON DEĞER + HAM liste gösteriyor, trend/grafik YOK — **çelişmiyor** | doğru, L-339 sonrası yeniden doğrulandı |
| 9 | `what_lissom_doesnt_do.dart:192` | *"Coaching level not declared."* | config alanı boşsa dönen dinamik geri-düşüş metni | öz-düzelten (kod-türetilmiş) |
| 10 | `assessment_history.dart:60` (kod-belgesi) | *"referans HENÜZ yok (referenceStatus.measurementOnly)"* | `referenceStatus` enum'ında `measurementOnly` DIŞINDA bir dal yok | doğru, kod-belgesi |
| 11 | `onboarding_gate.dart:64` (kod-belgesi) | *"o profilde bant HENÜZ YOK"* | bant hesaplama profile bağlı, boş profilde gerçekten yok | doğru, kod-belgesi |

## Hüküm

**Hiçbiri bayat değil.** Beş kalem (3,4,9,10,11) zaten **kod-türetilmiş** —
statik yalan söyleyemezler, çünkü cümlenin kendisi çalışma-anı durumundan
hesaplanıyor. Kalan altısı (1,2,5,6,7,8) **statik ve buildable-someday** —
bunlar geri gelmesi ölçülen `_staleClaims` sınıfının aday havuzu: biri
gerçekleştiğinde (`#1` hatırlatıcı · `#2` kamera önizlemesi · `#5` A12 ·
`#6` aralık mantığı · `#7` validasyon çalışması) o satır **AYNI TURDA**
`_staleClaims`e taşınmalı (`H-73`nün bağlayıcı kancası: *bir yol ölçülüp
elendiğinde AYNI TURDA engelleyen kaleme yazılır, sonradan değil*).

**Sayı notu:** orkestratörün 2026-08-16 envanteri 12 saymıştı; bugünkü canlı
tarama 9 canlı + 2 kod-belgesi = 11 buluyor. Fark muhtemelen aradaki
turlarda (`L-337`…`L-342`) bazı satırların değişmesi/kod-belgeye
dönüşmesinden — kaynak commit'i yeniden kazmak bu farkın kendisini
açıklamaya değecek kadar önemli değil (sayı bir hedef değil, envanterin
KENDİSİ önemli); ama fark **adıyla** yazılı kalsın, sessizce 12→11
düzeltilmiş gösterilmesin (`H-77`: tazelik `max`la ölçülür, geçmiş sayı
metinde donuk kalmamalı).
