# Lissom — App Store 4.3(a) farklılaşma dosyası (hazırlık, gönderim YOK)

Bilet: LIS-P1-10 · Tarih: 2026-11-14 · Kapsam: yalnız belge. Resolution Center'a hiçbir şey gönderilmez; mağazaya dokunulmaz. Lissom 1.0.0 (build 5) `REJECTED 4.3(a)` durumunda bekler; yeniden gönderim Ostinato yayınlanana kadar bekler (kurucu 2026-11-06: "Evet, beklesin", `docs/yula-execution/DECISIONS.md:28-32`). Ret gerekçesinin resmî metni bu repoda yok (`DOĞRULANMADI`); elde yalnız kurucunun özeti var: "5 motionu aynı anda gönderdiğimiz için spam sayıldı" (`DECISIONS.md:30`) ve `docs/yula-execution/STATUS.md:31,47`.

Kaynak kuralı: yollar bu depo köküne göredir. `ventures/<uygulama>/app/…` diye başlayanlar diğer Motion depolarıdır (salt-okur okundu). Satır numarası belirtilmemişse "dosya düzeyinde" demektir.

## 1. Lissom'a özgü olanların kanıtlı envanteri

| # | Özgü öğe | Kanıt (dosya:satır) |
|---|---|---|
| 1 | Beş yoga kursu, 120 ders: Hatha 60 (10 modül), Ashtanga başlangıç 19 (5), Yin 12 (3), Vinyasa 14 (3), sandalye/ofis 15 (5). Sayılar kurs JSON'larından ayrıca sayıldı (modül→ders toplamı) | `config/courses/hatha.v1.json`, `ashtanga-foundations.v1.json`, `yin-supported.v1.json`, `vinyasa-standing.v1.json`, `chair-office.v1.json`; mağaza iddiası `docs/store/listing.json:7,15,72-111` |
| 2 | Başlangıç yolu: Hatha h01–h10 (varış h01–h06, ayakta h07–h10), sonraki ders h11 | `lib/app/hatha_beginner_path.dart:1-30` |
| 3 | Kurs yükleyicileri (her kurs için ayrı) | `lib/app/hatha_course.dart`, `ashtanga_course.dart`, `yin_course.dart`, `vinyasa_course.dart`, `chair_office_course.dart` |
| 4 | Hatha pratik kaydı / ilerleme (yalnız bu uygulamada) | `lib/app/hatha_progress.dart`; `lib/app/progress_screen.dart` |
| 5 | 14 dil: arayüz ve her ders | `lib/app/lissom_locales.dart:9-24`; mağaza metni `docs/store/listing.*.json` (14 dosya) |
| 6 | Ücretsiz bölüm kuralı: her kursun açılış kısmı, en az üçte birini kapsayan en kısa tam modül ön eki; modül kimlikleri açık yazılı | `lib/app/course_access.dart:7-14` |
| 7 | Yoga'ya özgü motor paketi (duruş özellikleri, canlı değerlendirme) | `packages/lissom_engine/lib/src/` (assessment_engine, live_evaluator, camera/camera_coach, pose_features, yoga_observation) |
| 8 | Yoga duruş kataloğu (kamera için) | `config/yoga/camera-poses.v1.json`; şema `packages/lissom_engine/lib/src/camera/camera_pose_catalog.dart:1,68`. Duruş sayısı bu bilette sayılmadı (`DOĞRULANMADI`); `docs/camera/ACILIS-METINLERI.tr.md:24` "20 duruşluk katalog" diyor |
| 9 | Yazılı ders yapısı: her derste `objective`, `steps`, `practice`, `selfCheck`, `adaptation`, `stopSignal`, `mediaBrief` alanları (Hatha h01 JSON anahtarları okundu). Diğer uygulamaların ders şeması okunmadı; bu alan kümesinin Lissom'a özgü olduğu iddia EDİLMEZ | `config/courses/hatha.v1.json` (modül→ders); mağaza anlatımı `docs/store/listing.json:15` |
| 10 | Mağaza kimliği: ad "Lissom: Yoga & Mobility", alt başlık "Hatha, Yin, Vinyasa, Ashtanga" (TR: "Lissom: Yoga ve Mobilite", aynı alt başlık) | `docs/store/listing.json:5-6`; `docs/store/listing.tr-TR.json:5-7` |
| 11 | İkon: koyu mor zemin, oturan yoga figürü (yeşil/krem), turuncu mat | `ios/Runner/Assets.xcassets/AppIcon.appiconset/Icon-App-1024x1024@1x.png`; Android `android/app/src/main/res/mipmap-*/ic_launcher.png` |

**Kamera denemesi "yok" sayılır.** `LISSOM_CAMERA_TRIAL` varsayılanı kapalıdır (`lib/app/lissom_release_policy.dart:16-22`); kapalıyken ders ekranındaki kamera bölümü çizilmez (`lib/app/hatha_course_screen.dart:518,535,692`). Çekirdeğin ölçüm bayrağı da kapalıdır (`../../motion-core/lib/packages/motion_account/lib/src/motion_release_policy.dart:6` → `motionCameraCoachingAvailable = false`). Bu yüzden 4.3(a) için kamera, mevcut sürümde bir farklılaştırıcı değildir. `docs/camera/ACILIS-METINLERI.tr.md:24` içindeki App Review notu ("27 ders kamera koçluğu denemesi") bayrak kapalıyken **geçerli değildir**; bayrağın mağaza sürümünde açılması kurucu kararıdır (`docs/yula-execution/STATUS.md` F-kararları) ve bu belge onu önermez.

**Bayrak kapalıyken kameradan geriye kalan, tutarlılık gerektiren izler:**
- Onboarding'de `_Step.camera` adımı kodda var (`lib/app/onboarding_flow.dart:73,98,256-261,396`); `measurementAvailable` (varsayılan `motionCameraCoachingAvailable = false`, `:42`) kapalıyken ayrı bir dal çizilir (`:514`) ve izin istenmez (`docs/store/reviewer-notes.md:9`). Bu dalın ekranda tam metni bu bilette görülmedi (`DOĞRULANMADI`). Mevcut App Review metni: `docs/store/release-review.json:66`; taslak onunla uyumlu tutulmalı.
- Kamera kodu derlemede var, kamera kullanım açıklaması ve Android kamera izni bildirimde kalıyor; model dosyası git'te değil, build sırasında indirilir (`pubspec.yaml:145-147`, `tool/fetch_pose_model.sh`). Mağaza notu: "the camera step is gated off … the app never requests camera permission" (`docs/store/reviewer-notes.md:9`).

## 2. Beş Motion uygulamasıyla ortak şablon öğeleri

Diğer depolar salt-okurdu; satır numaraları orada okunan dosyalardandır. Okunmayan hücre "bulunamadı"/"doğrulanmadı" yazıldı, tahmin edilmedi.

| Öğe | Ostinato | **Lissom** | Gravita | Choreia | JabLab |
|---|---|---|---|---|---|
| İkon | koyu mor, beyaz "O" halka + üç pastel damla | koyu mor, oturan yoga figürü | koyu bordo, krem "G" halter plakası | koyu bordo, krem/pembe dansçı | koyu zemin, kırmızı bantlı yumruk |
| Ana düzen | alt gezinme bulunamadı (`ventures/ostinato/app/lib/app/screens/`) | `NavigationBar`, 4 sekme: Ana Sayfa / Kütüphane / İlerleme / Profil (`lib/app/shell.dart:229,313-318`) | `NavigationBar`, 4 sekme: Bugün / Kütüphane / İlerleme / Profil (`ventures/gravita/app/lib/app/gravita_app.dart:539`) | `NavigationBar`, 3 sekme: Stiller / İlerleme / Profil (`ventures/choreia/app/lib/app/shell/choreia_shell.dart:498`) | `shell_candidate/` altında aday kabuk: 4 sekme (`ventures/jablab/app/lib/shell_candidate/shell_scaffold.dart:39-70`); üretim kabuğu olduğu doğrulanmadı (`ventures/jablab/app/lib/shell_candidate/README.md:26,65`) |
| Onboarding | `lib/app/screens/onboarding_screen.dart:61,247,286,366` (welcome/scope/sensors) | 5 adım: welcome, disclaimer, camera, profile, limits (`lib/app/onboarding_flow.dart:73`); sayaç "Step {step} of {total}" (`:168`) | 3 adım: value, safety, camera (`ventures/gravita/app/lib/app/onboarding_screen.dart:42`) | ayrı dosya bulunamadı | `ventures/jablab/app/lib/app/onboarding_page.dart:150,160` |
| Paywall / erişim | `ventures/ostinato/app/lib/app/course_access.dart:10-14` | `lib/app/course_access.dart:7-14` (ayrı paywall ekranı dosyası bulunamadı) | `ventures/gravita/app/lib/app/paywall_policy.dart:106-109` | `ventures/choreia/app/lib/app/course/course_access.dart:20-29` | `ventures/jablab/app/lib/app/course_access.dart:9,26,114` |
| Abonelik düzeni | "ilk modül ya da kursun ~üçte biri ücretsiz; Motion+" | "ilk bölüm ücretsiz; Lissom ya da Motion+" | "ilk dersler ücretsiz; üyelik" (`paywall_policy.dart:109`) | "kursun ~ilk üçte biri ücretsiz; Choreia ya da Motion+" | "ilk dersler ücretsiz; üyelik" |
| ASC metni | "Ostinato: Music Practice" / "Notadan müziğe gitar" | "Lissom: Yoga & Mobility" / "Hatha, Yin, Vinyasa, Ashtanga" | "Gravita: Skills & Strength" / "Calisthenics at your pace" | "Choreia: Learn to Dance" / "Five solo dance practice paths" | "JabLab: Shadow Training" / "Solo martial arts practice" |
| Core | `motion_core` import eden dosya: 2 | 11 (`pubspec.yaml:43-47` pin) | 6 | 13 | 8 |

(Core satırı: her `lib/` içinde `grep -rl "package:motion_core/motion_core.dart"` sayımı, 2026-11-14.)

(Ostinato/Gravita/Choreia/JabLab mağaza metni: `ventures/<uygulama>/app/docs/store/listing.json`; Lissom: `docs/store/listing.json:5-7`.)

**Birebir ya da yapısal olarak aynı olanlar (kanıtlı):**
- Ortak çatı: hepsi `motion_core`'dan `MotionApp`, hesap/kimlik/kamera/genç satın alma politikası bileşenlerini kullanıyor (`pubspec.yaml:43-47`; diğer depolarda `import 'package:motion_core/motion_core.dart'`).
- Ücretsiz-önce erişim kalıbı: kurs başına açılış kısmı ücretsiz, geri kalanı "uygulama üyeliği ya da Motion+" (yukarıdaki beş `course_access` kaynağı). Aynı abonelik grubu "Motion membership" (`docs/store/reviewer-notes.md`, "Subscriptions").
- Alt gezinme iskeleti: Lissom ve Gravita'da aynı 4 sekmeli `NavigationBar` kalıbı (Bugün/Ana Sayfa, Kütüphane, İlerleme, Profil); Choreia 3 sekme; JabLab'da yalnız aday kabuk aynı kalıpta (üretimde olduğu doğrulanmadı).
- Mağaza ad kalıbı "Ad: Etiket" beşinde aynı; "yazılı dersler" anlatımı beşinde benzer (`ventures/<uygulama>/app/docs/store/listing.json` `description`).
- Metin düzeyinde aynı cümle bulunmadı: açıklamaların ilk üç cümlesi her uygulamada ayrı yazılmış.
- Karşılaştırılamayan: paywall plan/fiyat ekranı düzeni hiçbir uygulamada ekran olarak okunmadı (`DOĞRULANMADI`).

## 3. Boşluk listesi ve önerilen düzeltmeler (4.3(a) gerekçesine göre)

Resmî ret metni elde olmadığından boşluklar, kurucunun özetine ("aynı anda beş benzer uygulama") ve yukarıdaki kanıtlara dayanır. Beden: S ≈ metin/not, M ≈ küçük kod+mağaza varlığı, L ≈ ürün farklılığı. Hiçbiri bu bilette uygulanmaz.

| # | Boşluk | Kanıt | Önerilen düzeltme | Beden |
|---|---|---|---|---|
| G1 | Beş uygulama aynı gün, aynı çatı ve erişim kalıbıyla gönderildi | `DECISIONS.md:30`; §2 | Gönderimleri zamana yay (zaten karar: Lissom Ostinato'dan sonra); Resolution Center'da bunun olgusal açıklaması | S |
| G2 | Sekme düzeni, abonelik kalıbı ve "Motion membership" grubu aynı | §2 | Lissom'a özgü ana ekran (örn. Başlangıç yolunun öne çıktığı Ana Sayfa) ve Lissom'a özel bir ürün-açıklama satırı; yapısal değişiklik kurucu kararı | M |
| G3 | Mağaza ad/alt başlık kalıbı benzer, ekran görüntüleri ortak kabuğu gösterebilir | `docs/store/listing.json:5-6`; `docs/store/feature-graphics`, `icon-candidates` | Ekran görüntülerinde yoga'ya özgü içerik (duruş açıklamaları, çok dilli ders sayfası); mağaza metninde 120 yazılı ders / 5 kurs / 14 dil vurgusu zaten var, öne al | S |
| G4 | Kamera, tek gerçek farklılaştırıcı, kapalı; App Review notu (`ACILIS-METINLERI.tr.md:24`) kapalı sürümde geçersiz | §1; `lissom_release_policy.dart:16-22` | Kamerayı gerekçe gösterme. Bayrağı açmak kurucu kararı (izin metni, gizlilik, mağaza metni birlikte); belgede yalnız seçenek olarak kalır | L (karar kurucuda) |
| G5 | Onboarding'in kamera adımı kapalı kamera iddiasıyla tutarsız görünebilir | `onboarding_flow.dart:73,98,256-261` | Adımın kapalıyken ne gösterdiğini ekranda doğrula; gerekirse kamera yokken adımı gizle | M |
| G6 | Yoga içeriğinin özgünlüğü hakemin gözünde kanıtlanmalı (kaynak, hazırlayan, çeviri) | `config/courses/*`, `docs/store/reviewer-notes.md` "Content" | Reviewer notuna kurs/ders yapısını ve kaynak kapsamını (`sourceScopes`) ekle; içeriğin nasıl üretildiğine dair bir cümle ancak kurucu/Motion orchestration kanıtı verirse yazılır (şimdilik `DOĞRULANMADI`) | S |
| G7 | Paywall/abonelik ekranı Core'dan geliyor olabilir, Lissom'a özgü sunum yok | §2 (`DOĞRULANMADI`) | Önce paywall ekranının Lissom'da gerçekte neyi gösterdiğini ekranla doğrula, sonra karar | S |

## 4. Resolution Center yanıt taslağı (GÖNDERİLMEZ)

> Merhaba,
> Lissom, beş Motion uygulamasından biri olarak aynı günlerde incelemeye gönderildi; bu yüzden benzer bir paket gibi göründüğünü anlıyoruz. Gönderimleri artık zamana yayıyoruz ve Lissom'u ayrı ele alıyoruz.
> Lissom yalnız yoga'ya ve mobiliteye yönelik, 14 dilde yazılı 120 ders ve 5 kurstan oluşur (Hatha 60, Ashtanga başlangıç 19, Yin 12, Vinyasa 14, sandalye/ofis 15). Hatha başlangıç yolu ve yoga ders içeriği bu uygulamaya özgüdür; diğer Motion uygulamaları başka alanlara (gitar, calisthenics, dans, boks) aittir.
> Hesap, abonelik ve güvenlik altyapısı ile ücretsiz-önce erişim kalıbı ortaktır; içerik, ikon, ad ve alan ayrıdır. Bu sürümde kamera özelliği kapalıdır ve bir farklılık olarak öne sürülmemektedir.
> Ek bilgi isterseniz memnuniyetle sağlarız.

Notlar: (a) Taslak yalnız §1'deki kanıtlı maddelere dayanır; ret metni görülünce yeniden yazılmalıdır. (b) "Diğer uygulamalarda yoga içeriği bulunmaz" cümlesi Core'un yoga'ya özgü bir içerik taşımadığı varsayımına dayanır; gönderimden önce Motion orchestration doğrulasın. (c) Gönderim, mağaza yazışması ve zamanlama kurucu/Motion orchestration işidir.

## 5. Doğrulanmayanlar

- Resmî 4.3(a) ret metni ve Apple'ın güncel yönerge metni (bu repoda yok).
- Duruş kütüphanesi sayısı; `LISSOM_CAMERA_TRIAL` kapalıyken onboarding'in kamera adımı ekranı.
- Paywall ekranlarının düzeni/fiyat sunumu (beş uygulamada da ekran düzeyinde okunmadı); Ostinato'nun alt gezinmesi; Choreia'nın onboarding dosyası.
- Ders JSON alan kümesinin diğer uygulamalarla farkı (okunmadı); "içerik el yapımıdır" olgusu.
- ASC metni/ikon/abonelik hücrelerinin satır numarası (diğer depolar): dosya düzeyinde.
- Ses/müzik ve bildirim özellikleri Lissom'da arandı değil.
- Diğer depolardaki satır numaraları ajan okumasındandır; kritik olanlar gönderimden önce yeniden doğrulanmalıdır.
