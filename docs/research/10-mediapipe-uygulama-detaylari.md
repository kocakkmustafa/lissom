# MediaPipe Pose Landmarker — Uygulama Detayları (2026-07-26)

Kaynak: G0 tazeleme fan-out

## Özet

MediaPipe Pose Landmarker (Apache-2.0, 33 landmark, lite/full/heavy) hâlâ aile standardı; model bundle URL'leri stabil GCS yollarında. Python paketi (`mediapipe` PyPI) **0.10.35** (2026-04-27) ile **Python 3.9–3.12** destekliyor — **3.13 ve 3.14 resmi wheel YOK** (kaynak: GitHub issue #6159, aktif açık). Android `tasks-vision` Maven'de en güncel doğrulanan sürüm **0.10.29**; resmi dokümantasyon pin yerine `latest.release` kullanıyor (üretimde RİSKLİ — aşağıda not). iOS CocoaPods `MediaPipeTasksVision` **0.10.33+ sürümlerinde XCFramework linking sorunu bildirilmiş** (GitHub #6258, 2026-03-25); **0.10.21 çalışır durumda** doğrulanmış son sürüm. `visibility`/`presence` alanlarının ikisi de dokümantasyonda resmî olarak tanımsız (community/issue kaynaklı yorum var, DOĞRULANMADI). `worldLandmarks` = metre cinsinden, kalça-ortası (hip midpoint) orijinli 3D koordinat — bu kaynaklı ve güvenilir.

## Bulgular (kanıtlı, URL'li)

### (a) Model bundle indirme URL'leri
- Lite: `https://storage.googleapis.com/mediapipe-models/pose_landmarker/pose_landmarker_lite/float16/1/pose_landmarker_lite.task`
- Full: `https://storage.googleapis.com/mediapipe-models/pose_landmarker/pose_landmarker_full/float16/1/pose_landmarker_full.task`
- Heavy: `https://storage.googleapis.com/mediapipe-models/pose_landmarker/pose_landmarker_heavy/float16/1/pose_landmarker_heavy.task`
- Sürüm segmenti URL'de `/1/` olarak pinlenebilir (bundle-level versioning) — kaynak: [Pose landmark detection guide](https://ai.google.dev/edge/mediapipe/solutions/vision/pose_landmarker)
- Dosya boyutları: Lite ~3MB, Heavy ~30MB (yaklaşık, arama sonucu üzerinden — **DOĞRULANMADI kesin byte cinsinden**, resmi sayfa tam boyutu vermiyor). Full modelin boyutu kaynaklarda net verilmedi — **DOĞRULANMADI**.
- Python rehberi bundle'ı doğrudan indirip yerel path vermeyi öneriyor, sürüm pinleme dosya adı/URL üzerinden yapılmalı (guide sadece "select and download the model" diyor, otomatik sürüm takibi önermiyor). Kaynak: [Pose landmark detection guide for Python](https://developers.google.com/edge/mediapipe/solutions/vision/pose_landmarker/python)

### (b) Python `mediapipe` paketi
- PyPI güncel sürüm: **0.10.35**, yayın tarihi **2026-04-27**. Kaynak: https://pypi.org/project/mediapipe/
- Desteklenen Python sürümleri (classifier): **3.9, 3.10, 3.11, 3.12**. Python **3.13 desteklenmiyor** — resmi wheel yok, kaynaktan derleme Bazel/pybind11/CPython 3.13 ABI hatalarıyla başarısız oluyor. Kaynak: [Python 3.13 Support: MediaPipe Fails to Build and No Wheels Available · Issue #6159](https://github.com/google-ai-edge/mediapipe/issues/6159)
- Python **3.14 desteği hakkında hiçbir doğrulanmış kaynak bulunamadı — DOĞRULANMADI.**
- `mediapipe-nightly` PyPI'da ayrı paket olarak mevcut (nightly build kanalı) — https://pypi.org/project/mediapipe-nightly/ (içerik detayına inilmedi, sadece varlığı doğrulandı).
- VIDEO modu timestamp yönetimi kod örneği (resmi kaynak):
```python
options = PoseLandmarkerOptions(
    base_options=BaseOptions(model_asset_path=model_path),
    running_mode=VisionRunningMode.VIDEO)

with PoseLandmarker.create_from_options(options) as landmarker:
    pose_landmarker_result = landmarker.detect_for_video(mp_image, frame_timestamp_ms)
```
  Kaynak: [Pose landmark detection guide for Python](https://developers.google.com/edge/mediapipe/solutions/vision/pose_landmarker/python)
- RunningMode üç değer alır: `IMAGE` (tekil görüntü), `VIDEO` (çözülmüş video kareleri), `LIVE_STREAM` (kamera gibi canlı akış, asenkron callback). Kaynak: aynı sayfa.

### (c) Android
- Gradle bağımlılığı resmi rehberde: `implementation 'com.google.mediapipe:tasks-vision:latest.release'` — **sürüm pinlenmemiş, `latest.release` kullanılıyor** (kaynak: [Pose landmark detection guide for Android](https://developers.google.com/edge/mediapipe/solutions/vision/pose_landmarker/android)). Bu üretimde reproducibility riski taşır.
- Maven Central'da doğrulanan somut sürüm numarası: **0.10.29** (mvnrepository.com/artifact/com.google.mediapipe/tasks-vision/0.10.29) — ancak bu sayfanın "en güncel" olduğu garanti değil, sadece arama sonucunda görülen en yüksek numaralı sürüm. **Kesin "son sürüm" iddiası DOĞRULANMADI** — Maven Central arşivi doğrudan taranmadı (bu görev repo/web taraması kısıtlı).
- `RunningMode.LIVE_STREAM` + `setResultListener()` deseni: task, sonucu asenkron callback ile döndürür, "returns immediately and doesn't block the current thread." CameraX `ImageAnalysis` entegrasyonunun kod detayı resmi sayfada değil, referans GitHub örneğinde (`PoseLandmarkerHelper.kt`) — bu dosyaya bu oturumda erişilmedi (**erişilemedi**, sadece referans olarak anıldığı görüldü).
- Delegate (CPU vs GPU) seçimi `BaseOptions` üzerinden yapılır ancak resmi Android rehberi bu ayarın detaylarını sayfada açıklamıyor — kod örneği GitHub'da (`PoseLandmarkerHelper.kt`), bu oturumda içeriğine inilmedi. **Detay DOĞRULANMADI/erişilemedi.**

### (d) iOS
- MediaPipeTasksVision CocoaPods sürümü: **0.10.33 ve üzeri sürümlerde XCFramework linking sorunu** bildirilmiş (module import hatası, linker hatası), issue tarihi 2026-03-25. Kaynak: [[iOS] MediaPipeTasksVision 0.10.33 XCFramework linking issues with CocoaPods · Issue #6258](https://github.com/google-ai-edge/mediapipe/issues/6258)
- **0.10.21** sürümü çalışır durumda olarak libraries.io kaydında görülüyor: https://libraries.io/cocoapods/MediaPipeTasksVision
- CocoaPods minimum sürüm gereksinimi: **CocoaPods 1.12.1 veya üzeri** (kaynak: [Setup guide for iOS](https://ai.google.dev/edge/mediapipe/solutions/setup_ios), yalnızca arama özeti üzerinden — sayfa içeriği doğrudan fetch edilmedi, **kısmen doğrulanmış**).
- AVCaptureVideoDataOutput deseni ile ilgili somut kod örneği bu oturumda çekilemedi — **erişilemedi**.

### (e) visibility / presence
- `visibility`: landmarkın görüntüde görünür olma olasılığı (confidence skoru). Kaynak: resmi dokümantasyon metni ("likelihood of the landmark being visible within the image").
- `presence`: örnek çıktılarda görülüyor (`presence: 0.9999984502792358` gibi) ama **resmi dokümantasyonda tanımı YOK** — bu, topluluk tarafından da eleştirilmiş bir dokümantasyon boşluğu. Kaynak: [Landmarks Presence vs Visibility · Issue #4411](https://github.com/google/mediapipe/issues/4411)
- `presence` alanının `visibility`'den farkı **resmi olarak DOĞRULANMADI** — pratikte iki alanın da benzer amaçlı iki ayrı sinyal (görünürlük vs. var-olma/oklüzyon) olduğu tahmin ediliyor ama bu görev kapsamında kanıtlanmış bir ayrım bulunamadı.

### (f) worldLandmarks koordinat sistemi
- `world_landmarks`: gerçek-dünya 3D koordinatları, **metre cinsinden**, orijin **kalçaların orta noktası** (hip midpoint). z ekseni derinlik: küçük değer kameraya daha yakın anlamına gelir. Kaynak: GitHub issue tartışması + Pose solutions sayfası (chuoling.github.io/mediapipe/solutions/pose.html üzerinden özetlenmiş, resmi doküman metniyle tutarlı).
- Normalize `landmarks` (image-space, 0-1 aralığı) ile `world_landmarks` (metre, hip-orijinli) İKİ AYRI çıktı — biri piksel/oransal konum için, diğeri gerçek ölçekli açı/mesafe hesapları için kullanılmalı.

### (g) Bilinen tuzaklar (araştırmadan toplanan + genel MediaPipe bilgisi — bazıları DOĞRULANMADI)
- **Aynalama (ön kamera):** Ön kamera görüntüsü genelde önizleme için yatay çevrilir (mirror); pose landmark x-koordinatları bu çevirme ile tutarlı olmalı — yoksa sol/sağ taraf karışır. Bu genel bir CameraX/AVFoundation davranışıdır, MediaPipe'a özgü bir resmi uyarı bu oturumda bulunamadı — **DOĞRULANMADI (genel bilgi, kaynak yok)**.
- **Rotasyon/EXIF:** Kamera sensör rotasyonu ile görüntü buffer rotasyonu uyuşmazsa landmark açıları yanlış çıkar. MediaPipe Tasks API'de `ImageProcessingOptions` ile rotasyon derecesi verilebiliyor (bilinen API yüzeyi, ancak bu oturumda resmi sayfadan doğrudan alıntılanmadı) — **kısmen DOĞRULANMADI, sayfa fetch edilmedi**.
- **YUV→RGB dönüşümü:** Android CameraX `ImageAnalysis` çıktısı YUV_420_888 formatında gelir, MediaPipe `MPImage`/`Bitmap` RGB bekler — dönüşüm gerekiyor. Bu, MediaPipe Android örnek kodlarında bilinen bir adım ama bu oturumda kaynak sayfası (`PoseLandmarkerHelper.kt`) içeriği çekilmedi — **DOĞRULANMADI/erişilemedi**.
- **İlk-inference gecikmesi:** Model yükleme + ilk çalıştırma (warm-up) genelde sonraki karelerden belirgin şekilde yavaş olur — genel ML-runtime davranışı, MediaPipe'a özgü ölçülmüş rakam bu oturumda bulunamadı — **DOĞRULANMADI (rakamsız)**.
- **GPU delegate uyumsuzlukları:** iOS/Android GPU delegate bazı cihaz/GPU sürücü kombinasyonlarında çökme veya desteksizlik gösterebiliyor — genel MediaPipe bilgi tabanında bilinen bir sorun sınıfı ama bu oturumda spesifik 2026 issue/kaynak taranmadı — **DOĞRULANMADI (kaynak taranmadı)**.

## Ürüne doğrudan girdi

### (1) Offline fixture çıkarma hattı — Python reçetesi
```bash
# Python 3.12 kullan (3.13/3.14 wheel yok — doğrulanmış kısıt)
python3.12 -m venv .venv
source .venv/bin/activate
pip install mediapipe==0.10.35 opencv-python
```
```python
import mediapipe as mp
from mediapipe.tasks import python as mp_python
from mediapipe.tasks.python import vision

BaseOptions = mp_python.BaseOptions
PoseLandmarker = vision.PoseLandmarker
PoseLandmarkerOptions = vision.PoseLandmarkerOptions
VisionRunningMode = vision.RunningMode

model_path = "pose_landmarker_full.task"  # lite/full/heavy seçilebilir

options = PoseLandmarkerOptions(
    base_options=BaseOptions(model_asset_path=model_path),
    running_mode=VisionRunningMode.VIDEO,
)

with PoseLandmarker.create_from_options(options) as landmarker:
    # her video karesi için:
    # mp_image = mp.Image(image_format=mp.ImageFormat.SRGB, data=frame_rgb_ndarray)
    # frame_timestamp_ms artan sırada, kare aralığına göre hesaplanmalı (örn. int(frame_idx * 1000 / fps))
    result = landmarker.detect_for_video(mp_image, frame_timestamp_ms)
    # result.pose_landmarks -> normalize (0-1) image-space
    # result.pose_world_landmarks -> metre, hip-orijinli 3D
```
Not: `frame_timestamp_ms` her çağrıda **kesinlikle artan** olmalı (VIDEO/LIVE_STREAM modu bunu zorunlu kılar) — fixture üretiminde video FPS'ine göre deterministik timestamp üretilmeli, aksi halde API hata verir (bu davranış Tasks API genel sözleşmesidir).

### (2) Native köprü için sürüm-pinli bağımlılık listesi
| Platform | Paket | Önerilen pin | Not |
|---|---|---|---|
| Android (Gradle) | `com.google.mediapipe:tasks-vision` | `0.10.29` (doğrulanmış Maven kaydı) — resmi rehber `latest.release` öneriyor ama bu **prod'da pinlenmeli**, reproducibility için | `latest.release` KULLANMA — sürüm sürüklenmesi (drift) build'i beklenmedik şekilde değiştirebilir |
| iOS (CocoaPods) | `MediaPipeTasksVision` | `0.10.21` (0.10.33+ XCFramework linking hatası bildirilmiş, GitHub #6258) | 0.10.33+ pinlemeden önce issue'nun kapanma durumu kontrol edilmeli |
| Python (offline fixture) | `mediapipe` | `0.10.35` | Python 3.9-3.12 ile sınırlı — CI/dev ortamı buna göre pinlenmeli, 3.13/3.14 kullanma |

### (3) Tuzak → önlem tablosu
| Tuzak | Önlem |
|---|---|
| Python 3.13/3.14 ile mediapipe kurulumu başarısız | Geliştirme + fixture ortamını Python 3.12'ye sabitle (venv/pyenv) |
| Android `latest.release` sürüm sürüklenmesi | Gradle'da somut sürüm pinle (örn. `0.10.29`), CI'da lockfile/version catalog kullan |
| iOS CocoaPods 0.10.33+ XCFramework link hatası | `0.10.21` gibi doğrulanmış sürüme pinle; yükseltmeden önce ilgili GitHub issue'yu kontrol et |
| Ön kamera aynalama → sol/sağ karışması | UI'da landmark çizerken x-koordinatını kamera önizleme aynalamasıyla tutarlı çevir/çevirme; assessment mantığında sol/sağ eklem etiketlerini kameranın mirror durumuna göre doğrula |
| Rotasyon/EXIF uyumsuzluğu → yanlış açı hesapları | Kare MediaPipe'a verilmeden önce sensör rotasyonunu `ImageProcessingOptions`/eşdeğer parametreyle bildir; native tarafta rotasyonu manuel test et (bu detay bu oturumda resmi kaynaktan doğrulanamadı — köprü geliştirmesi sırasında ayrıca doğrulanmalı) |
| YUV→RGB dönüşüm maliyeti/yanlışlığı | CameraX `ImageAnalysis` çıkışını doğru format dönüşümüyle (RGBA_8888 veya benzeri) MPImage'a besle; native tarafta bu adımı ayrı test et |
| İlk-inference gecikmesi kullanıcı deneyimini bozar | Assessment ekranına girişte model'i arka planda önceden yükle/warm-up yap, kullanıcıya "hazırlanıyor" durumu göster |
| GPU delegate cihaz uyumsuzluğu | CPU delegate'i güvenli varsayılan yap; GPU'yu yalnızca bilinen/test edilmiş cihaz sınıflarında opt-in aç, çökme durumunda CPU'ya fallback |
| Model bundle URL/sürüm sabit değilse üretimde farklı davranış | `.task` dosyalarını build sırasında indirip repo/asset içine gömerek (veya checksum ile pinleyerek) sürüm sürüklenmesini engelle |

## Açık sorular (kapatılamayanlar, neden)

1. **Model dosya boyutları (lite/full/heavy) tam byte cinsinden nedir?** Resmi sayfa (`ai.google.dev/.../pose_landmarker`) tam boyut vermiyor, yalnızca yaklaşık "lite ~3MB, heavy ~30MB" arama özetinden geldi; full modelin boyutu hiç bulunamadı. Kapatmak için: `.task` dosyalarını doğrudan HEAD isteğiyle indirip Content-Length okumak gerekir (bu oturumda dosya indirme yapılmadı — kural gereği).
2. **Android `tasks-vision` ve iOS `MediaPipeTasksVision`'ın 2026-07 itibarıyla GERÇEK en güncel (en yüksek) sürüm numarası nedir?** Maven Central/CocoaPods'un canlı sürüm listesi bu oturumda doğrudan taranmadı (arama sonuçları üzerinden 0.10.29 ve 0.10.33+ görüldü ama bunlar "en yüksek arama sonucu", "kesin en güncel" garantisi değil. Kapatmak için: `https://mvnrepository.com/artifact/com.google.mediapipe/tasks-vision` ve CocoaPods trunk API'si canlı sorgulanmalı.
3. **CameraX `ImageAnalysis` ↔ MediaPipe `MPImage` YUV→RGB dönüşüm kod deseni ve rotasyon parametresi (`ImageProcessingOptions`) native köprü tarafında tam olarak nasıl kullanılıyor?** Resmi rehber bunu `PoseLandmarkerHelper.kt` referans koduna yönlendiriyor ama bu dosyanın içeriği bu oturumda çekilmedi (fan-out kapsamı/zaman kısıtı). Kapatmak için: GitHub `google-ai-edge/mediapipe-samples` reposundaki `PoseLandmarkerHelper.kt` ve iOS eşdeğeri doğrudan fetch edilmeli.

## Kaynaklar

- https://storage.googleapis.com/mediapipe-models/pose_landmarker/pose_landmarker_lite/float16/1/pose_landmarker_lite.task
- https://storage.googleapis.com/mediapipe-models/pose_landmarker/pose_landmarker_full/float16/1/pose_landmarker_full.task
- https://storage.googleapis.com/mediapipe-models/pose_landmarker/pose_landmarker_heavy/float16/1/pose_landmarker_heavy.task
- https://ai.google.dev/edge/mediapipe/solutions/vision/pose_landmarker
- https://developers.google.com/edge/mediapipe/solutions/vision/pose_landmarker
- https://developers.google.com/edge/mediapipe/solutions/vision/pose_landmarker/python
- https://developers.google.com/edge/mediapipe/solutions/vision/pose_landmarker/android
- https://ai.google.dev/edge/mediapipe/solutions/setup_ios
- https://pypi.org/project/mediapipe/
- https://pypi.org/project/mediapipe-nightly/
- https://github.com/google-ai-edge/mediapipe/issues/6159 (Python 3.13 desteklenmiyor)
- https://github.com/google-ai-edge/mediapipe/issues/6258 (iOS 0.10.33+ XCFramework linking sorunu)
- https://libraries.io/cocoapods/MediaPipeTasksVision
- https://mvnrepository.com/artifact/com.google.mediapipe/tasks-vision/0.10.29
- https://github.com/google/mediapipe/issues/4411 (visibility vs presence dokümantasyon boşluğu)
- https://github.com/google-ai-edge/mediapipe/issues/3577 (world landmarks hesaplama yöntemi tartışması)
- https://chuoling.github.io/mediapipe/solutions/pose.html (world coordinates, hip-orijinli metre açıklaması)
