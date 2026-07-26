# Python ölçüm hattı → Dart motion_core devir notu

**Tarih:** 2026-07-26 · **Kurucu kararı:** Dart `packages/motion_core` **kanonik**; Python hattı yalnız *video → MediaPipe → fixture JSON* çıkarma aracı olarak kalır.

> **Bağlam:** 2026-07-26 gecesi iki oturum paralel çalıştı. Biri Dart `motion_core` paketini yazdı (`8950c03`, main), diğeri (bu oturum) Lissom G0/G1 işini ve Python offline hattını yazdı. Örtüşen ölçüm matematiği kurucu kararıyla Dart'a bırakıldı. Bu not, Python tarafında **ölçülerek bulunan** üç hatayı ve iki farkı Dart tarafına taşır.

---

## 1. Dart'ta zaten doğru olanlar (kontrol edildi, iş gerekmiyor)

| Bulgu | Dart durumu |
|---|---|
| **L-010** — gövde açısı tek taraflı landmark çiftiyle ölçülemez | ✅ Zaten doğru: `normalization.dart` gövde eksenini `shoulderMid − hipMid` olarak kuruyor, `joint_angles.dart` `trunkTilt`'i `rawTorsoAxisAngle` üzerinden okuyor. Orta hat kullanılıyor. |
| **L-011** — `angle_vertical` + transverse = ölü metrik (hep 90°) | ✅ Uygulanamaz: Dart'ta transverse düzlem kavramı yok, `trunkTilt` image düzleminde ölçülüyor. |
| **L-009** — ham 3D açının ROM uçlarındaki sistematik hatası | ✅ Farklı yolla çözülmüş: `JointAngleExtractor(planar: true)` varsayılanı z'yi atıp image düzleminde ölçüyor. Sagittal çekimde kamera düzlemi = sagittal düzlem olduğu için medial-lateral genişlik farkı z'ye düşer ve atılır. |

## 2. ⚠️ Kontrol edilmesi gereken tek açık: frontal çekimde tek taraflı eklem açıları

`planar: true` derinliği (z) atar. Bu, **sagittal** çekimde genişlik farkını temizler ama **frontal** çekimde temizlemez: frontal görüntüde image-x zaten medial-lateral eksendir, yani omuz/kalça genişlik farkı düzlemde KALIR.

Somut risk: `hip_flexion` gibi eklem açıları `RIGHT_SHOULDER → RIGHT_HIP → RIGHT_KNEE` üçlüsüyle ölçülüyorsa, frontal çekimde L-009 hatası aynen ortaya çıkar. Python tarafında ölçülen büyüklük **±5.71°**, ROM uçlarında maksimum.

**Öneri:** gövde referansı isteyen eklem açılarında (`hip_flexion` gibi) tek taraflı omuz yerine orta-hat kullanın — Dart'ta bunun altyapısı zaten var (`midpoint`). Ya da `JointSpec`'e düzlem/çekim-yönü bilgisi ekleyip frontal çekimlerde bu metrikleri devre dışı bırakın.

**Doğrulama yolu:** `fixture/synthetic.dart` üreteciyle omuz genişliği ≠ kalça genişliği olan bir iskelet üretip `hip_flexion`'ı frontal konfigürasyonda ölçün; hata 0'a yakın değilse bulgu geçerlidir.

## 3. İki tasarım farkı (karar Dart tarafının)

**(a) Güven kapısı `presence`'ı kullanmıyor.**
Dart `gate()` yalnız `visibility < minVisibility` bakıyor. MediaPipe her landmark için **iki** skor veriyor: `visibility` (görünür mü) ve `presence` (tespit kesinliği). Python tarafı `visibility × presence` çarpımını kullanıyor — oklüzyonu daha iyi yakalıyor.
⚠️ Not: `presence` alanı Google dokümanında **resmen tanımsız** (issue #4411) — kullanmak bir bahis, kullanmamak da bilgi kaybı. Karar gerekçesiyle DEFTER'e yazılmalı.

**(b) Eşik 0.5 vs 0.6.**
Dart `minVisibility = 0.5` (MediaPipe varsayılanı). Python 0.6 seçti; gerekçe `research/05`: pratik aralık 0.4-0.7, ve Lissom'un wellness bağlamında **yanlış-pozitif "iyi skor"** riski, kaçırılan ölçümden daha pahalı. Nihai değer her iki durumda da G1-b'de gerçek fixture'la kalibre edilmeli.

**(c) Ölçülemedi sebebi kayboluyor.**
Dart ölçülemeyen açıyı `NaN` yapıyor. Python `INVALID_LOW_CONFIDENCE` / `INVALID_DEGENERATE_GEOMETRY` ayrımı tutuyor. Kullanıcıya "kameranı biraz geri al" mı yoksa "bu hareket ölçülemedi" mi diyeceğimiz bu ayrıma bağlı — UI katmanı için gerekli olacak.

## 4. Python hattının kalan rolü (çakışma yok)

Bunlar Dart'ta **yapılamaz** (MediaPipe yalnız Python/native'de var):

- `extract_landmarks.py` — video dosyası → MediaPipe → fixture JSON. Kurucunun çekimlerini Dart'ın `fixture/replay.dart`'ının okuyabileceği veriye çeviren tek yol.
- `fetch_models.sh` — model bundle'larını pinli sürümden indirip SHA-256 doğrulama (M-017: `latest` sessizce değişiyor).
- `gate_g1a.py` + `mocore/` — G1-a kapı ölçümü. Kurucu kararıyla ölçüm matematiği Dart'a devredildiği için bu kod **artık referans değil**; G1-a'nın Dart karşılığı yazıldığında bu koşucu emekliye ayrılabilir. O güne kadar bulgu üreten çalışır durumda bir kapı olarak duruyor.

**Fixture JSON şeması uyumu:** Python `mocore/fixture.py` ile Dart `src/fixture/fixture.dart` aynı veriyi tanımlıyor. İki şema **karşılaştırılmadı** — çıkarma hattının ürettiği JSON'u Dart'ın okuyabildiği ilk gerçek fixture'la doğrulanmalı. Uyuşmazsa kanonik olan Dart şemasıdır ve Python yazıcısı ona uydurulur.

## 5. Ölçüm kanıtı

Bu nottaki hata büyüklükleri tahmin değil, sentetik iskelet üzerinde ölçülmüş değerlerdir:

| Bulgu | Düzeltme öncesi | Düzeltme sonrası |
|---|---|---|
| L-009 ham 3D açı | 5.71° | 0.00° |
| L-010 tek taraflı gövde vektörü | 11.31° | 0.00° |
| L-011 ölü metrik | sabit 90.0000° (yaw 0/15/30/45/90'da değişmiyor) | metrik yeniden tanımlandı |

Tam rapor: `G1-V0-KAPI-RAPORU.md` · ham çıktı: `g1a-rapor.json`
