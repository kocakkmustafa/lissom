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

## 5. App Review notu (4.3(a) — Lissom'u ortak Motion kabuğundan ayıran özellik)
"Lissom 1.x adds an on-device camera coaching trial to 27 standing and chair lessons (Library → Hatha → Mountain stance → prepare → 'Practise with the camera'). It checks from a side view whether the learner is in the lesson's pose, times the hold and speaks one alignment cue at a time, using a pinned MediaPipe Pose model on the device. It is specific to yoga lessons and to Lissom's 20-pose catalogue; no other Motion app has it. No image, video or landmark leaves the device; there is no score and no health claim. A front-camera mirror (preview only) is also offered in the same lessons."

## 6. Sürüm notu
"Yeni: bazı ayakta ve sandalye derslerinde kamera koçluğu denemesi."
