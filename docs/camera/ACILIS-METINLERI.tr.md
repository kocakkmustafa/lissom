# Kamera denemesi — açılış metinleri (hazır, uygulanmadı)

Bayrak (`lissomCameraCoachingTrialOpen`) mağaza sürümünde açılmadıkça bu metinler **uygulanmaz**: bugünkü izin metni "kamera ölçümleri bu sürümde kapalı" der ve kapalı yapı için doğrudur. Açılış kararı kurucunundur; aynı sürümde aşağıdakilerin hepsi birlikte değişir. 14 dil çevirisi açılış PR'ında yapılır (EN/TR burada).

## 1. iOS kamera izin metni (`NSCameraUsageDescription`, Info.plist + 14 `InfoPlist.strings`)
- EN: "Lissom uses the camera only when you start the optional camera practice in a lesson. The image is processed on this device to find body positions; video is not recorded or uploaded."
- TR: "Lissom kamerayı yalnız bir derste isteğe bağlı kamera çalışmasını başlattığında kullanır. Görüntü vücut konumlarını bulmak için bu cihazda işlenir; video kaydedilmez veya yüklenmez."
- Bağlı testler: `test/release_camera_copy_test.dart`, `test/os_layer_test.dart`, `test/ship_blocker_test.dart` (kapalı metni kilitler; açılışta birlikte güncellenir).

## 2. Uygulama içi "kamera kapalı" cümleleri
`CaptureUnavailableNote`, Ana sayfa ve Profil cümleleri ROM **ölçümleri** için doğrudur (Core `motionCameraCoachingAvailable = false` değişmiyor). Açılışta bunlara bir cümle eklenir:
- EN: "Some standing and chair lessons have an optional camera coaching trial."
- TR: "Bazı ayakta ve sandalye derslerinde isteğe bağlı kamera koçluğu denemesi var."

## 3. Gizlilik metni (yulalab.com Lissom gizlilik sayfası; ayrı depo, ayrı onay)
- EN: "Camera coaching (trial): when you start it in a lesson, the camera image is processed on your device by an on-device pose model to estimate body positions. Images, video and body positions are not recorded, stored or sent to us or anyone else. Spoken corrections use your device's speech engine."
- TR: "Kamera koçluğu (deneme): bir derste başlattığında kamera görüntüsü, vücut konumlarını tahmin etmek için cihazındaki poz modeliyle cihazında işlenir. Görüntü, video ve vücut konumları kaydedilmez, saklanmaz, bize ya da başkasına gönderilmez. Sesli düzeltmeler cihazının kendi konuşma motorunu kullanır."
- Veri güvenliği / App Privacy yanıtları **değişmez**: veri toplanmıyor, paylaşılmıyor.

## 4. Mağaza açıklaması (14 dil listing)
- EN: "Camera coaching (trial) in standing and chair lessons: place the phone at your side, and Lissom checks whether you are in the pose, times the hold and says one correction at a time — on your device, with no score."
- TR: "Ayakta ve sandalye derslerinde kamera koçluğu (deneme): telefonu yanına koy; Lissom duruşta olup olmadığını kontrol eder, tutuşu sayar ve bir seferde tek düzeltme söyler — cihazında, puan vermeden."

## 5. App Review notu (4.3(a) — Lissom'u ortak Motion kabuğundan ayıran içerik)

Düzeltme: LIS-P1-11. Mevcut sürümde kamera özelliği yoktur (`LISSOM_CAMERA_TRIAL` kapalı, `lib/app/lissom_release_policy.dart:16-22`); bu not, aşağıdaki "yok" cümlesi dışında, kamerayı özellik olarak anmaz. Sayılar ve satır atıfları `docs/store/reviewer-notes.md:11-17` tablosundadır (`config/courses/*.v1.json`: modüller `hatha.v1.json:45`, `ashtanga-foundations.v1.json:193`, `yin-supported.v1.json:149`, `vinyasa-standing.v1.json:105`, `chair-office.v1.json:61`); "14 dil" `docs/store/listing.json:7` ve `lib/app/lissom_locales.dart:9-24`'e dayanır (JSON'larda yalnız EN/TR içerik doğrulandı, `DOĞRULANMADI`); yerel pratik kaydı `lib/app/hatha_progress.dart`.

"Lissom is a library of written yoga courses: 5 courses, 26 modules and 120 lessons, with the interface and every lesson in 14 languages (Hatha 60, Ashtanga beginner foundations 19, supported Yin 12, supported standing Vinyasa 14, chair/office 15). The Hatha course is a 60-lesson, 10-module path from foundations onwards; the first 24 Hatha lessons are free. Every lesson has a learning goal, a practice task, a self-check, an easier path, when to stop and its teaching sources; the courses list their teaching sources, and where a source scope is recorded it states what the source does and does not support (Hatha lists 30 sources, 11 with a scope entry). Practice records are the learner's own, stored on the device. Lessons are written and there is no demonstration video. Lissom is not a medical device. This version has no camera feature."

### Bayrak açıldığında (kurucu kararı) kullanılacak ayrı taslak

**ŞU AN GEÇERSİZ — LISSOM_CAMERA_TRIAL kapalı.** Aşağıdaki metin mevcut sürümde kullanılamaz; bayrağı açmak kurucu kararıdır.

"Lissom 1.x adds an on-device camera coaching trial to 27 standing and chair lessons (Library → Hatha → Mountain stance → prepare → 'Practise with the camera'). It checks from a side view whether the learner is in the lesson's pose, times the hold and speaks one alignment cue at a time, using a pinned MediaPipe Pose model on the device. It is specific to yoga lessons and to Lissom's 20-pose catalogue; no other Motion app has it. No image, video or landmark leaves the device; there is no score and no health claim. A front-camera mirror (preview only) is also offered in the same lessons."

## 6. Sürüm notu
"Yeni: bazı ayakta ve sandalye derslerinde kamera koçluğu denemesi."
