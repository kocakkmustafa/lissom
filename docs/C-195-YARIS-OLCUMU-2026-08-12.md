# C-195 kamera-kapanış yarışı — Lissom'da ÖLÇÜLDÜ (2026-08-12)

> Koordinatör hükmü: kilit YAZMA (O-076/C-195 çekirdek kuyruğunun 4. kalemi,
> pin beş hatta ortak — yerel çözüm ayrışma üretir). Ama "bende yarış yok"u
> İDDİA ETME, ÖLÇ. Soru "ekranlar arası geçiş" değil, **"iki yaşam-döngüsü
> çağrısı ÇAKIŞABİLİR mi"**.

## Ölçüm 1 — eklentinin KENDİ koruması (motion_camera, pinli, `f13bdc9`)

`MotionCameraController` sınıf dokümanı: *"One session at a time, by
design: the pose model is the scarce resource, and 'two silent
half-sessions' is a worse failure mode than a named
`CameraFailure.alreadyRunning`."* — ve `enum CameraFailure` gerçekten
`alreadyRunning('already-running')` taşıyor.

**Sonuç:** eklenti native tarafta ZATEN "ikinci `start()` ÇAKIŞIRSA" hâlini
**isimli bir hataya** çeviriyor, sessiz bozulmaya DEĞİL. O-076'nın önlediği
şey *silme/çökme* değil — **kullanıcının hiçbir şey yanlış yapmadığı bir
anda gördüğü, isimsiz görünen bir hata.** Bu, kilidin gerekçesini
KÜÇÜLTMEZ ama SINIFINI değiştirir: güvenlik değil, gürültü.

## Ölçüm 2 — Ostinato'nun ASIL tetiklediği yol: Lissom'da YOK (mimari karar, varsayım değil)

Ostinato'nun yarışı: `SetupCheck` ekranı (kendi `MotionCameraController`ı)
→ `pushReplacement` → `LiveScreen` (**AYRI bir** `MotionCameraController`
örneği) → `SetupCheck.dispose()`un `stop()`u BEKLEMEDEN `LiveScreen.start()`
çağrılır → İKİ FARKLI denetleyici örneği çakışır.

**Lissom'un planı (bu turda kuruluyor): TEK ekran, TEK `MotionCameraController`
örneği** — kurulum + yakalama aynı State'in içinde, ayrı bir
`pushReplacement` YOK. Bu, ölçülmemiş bir varsayım değil, **şimdi verilen
bir mimari karar**: `LiveCaptureScreen` kendi denetleyicisini `initState`te
kurar, `dispose`ta bırakır, ikinci bir ekran ikinci bir örnek AÇMAZ. Bu
karar durduğu sürece Ostinato'nun spesifik yolu **yapısal olarak
oluşamaz** — varsayım değil, o yolu kapatan tasarımın kendisi.

## Ölçüm 3 — beş aday yol, TEK ekran içinde de mi çakışabilir?

| # | Yol | Lissom'da mümkün mü | Savunma |
|---|---|---|---|
| 1 | **widget rebuild** | Flutter semantiği: `State` `key` değişmedikçe rebuild'de YENİDEN KURULMAZ (`initState`/`dispose` tekrar çağrılmaz) — `LiveCaptureScreen`e sabit `key` verilecek, zorlanmış remount YOK. **Risk yok.** | — |
| 2 | **arka plana alınıp geri gelme** (`AppLifecycleState`) | Bu turda bir `WidgetsBindingObserver` EKLENMİYOR (kapsam dışı — kamera OS tarafından askıya alınırsa `motion_camera`nın kendi kare-akışı sessizce durur, biz `stop()`/`start()` ÇAĞIRMIYORUZ). **Risk bu turda yok** çünkü tetikleyen kod YAZILMIYOR — ileride bir lifecycle-gözlemci eklenirse bu satır YENİDEN ölçülmeli. | İSİMLİ: bugün yok, ileride eklenirse yeniden ölç |
| 3 | **retry/yeniden dene düğmesi** | GERÇEK risk: kullanıcı `stop()` uçuştayken (önceki hata sonrası temizlik) "Try again" basarsa `start()` çakışabilir — AYNI State içinde, aynı denetleyici. | Yerel koruma: `LiveCaptureScreen` içinde tek bir `Future<void>? _inFlight` bayrağı — yeni `start()`/`stop()` isteği önce ÖNCEKİNİ bekler. Paylaşımlı O-076 DEĞİL, sınıf-içi bir mutex; beş hatla koordinasyon GEREKTİRMEZ. |
| 4 | **dispose sırasında pop** | GERÇEK risk: kullanıcı `start()` uçuştayken geri giderse `dispose()` `stop()`u çağırır, ikisi ÇAKIŞIR. | Aynı `_inFlight` bayrağı `dispose()`ta da beklenir (senkron `dispose()` `unawaited` ile tetikler, kendi içindeki sıralama korunur — Ostinato'nun `releaseCamera`/`noteClosing` deseninin TEK-EKRAN, PAYLAŞIMSIZ hâli). |
| 5 | **hata sonrası otomatik yeniden başlatma** | Bu turda otomatik retry YOK (kullanıcı elle "Try again" basar) — #3 ile aynı kapsamda. | #3'ün koruması yeterli |

## Hüküm

**Yol VAR (3 ve 4), ama TEK State İÇİNDE — paylaşımlı O-076 kilidi
GEREKMİYOR.** Savunma: `LiveCaptureScreen`e yerel bir `_inFlight` bayrağı
(sınıf-içi sıralama, süreç-geneli kilit DEĞİL). Bu, C-195'in çekirdek
kuyruktaki kapsamını GENİŞLETMEZ — Ostinato'nun asıl bulduğu **çok-ekranlı**
yarış Lissom'un bu turki mimarisinde yapısal olarak yok; kalan risk
tek-sınıf içi bir sıralama sorunu ve yerel bir çözümü var.

**Beyan edilen sınır:** eğer ileride Lissom'a `AppLifecycleState`
gözlemcisi ya da ikinci bir kamera ekranı (ör. ayrı bir kalibrasyon
sayfası, O6'nın gecikmiş hâli) eklenirse, bu ölçüm YENİDEN yapılmalı —
bugünkü sonuç bugünkü mimariye bağlıdır.
