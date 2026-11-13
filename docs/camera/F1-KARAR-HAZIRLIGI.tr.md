# Lissom kamera koçluğu — F1 karar hazırlığı (eşik altı duruşlar)

F1, kamera doğrulayıcısının ölçülen doğru kabulü (TA) ürün eşiğinin altında kalan 7 duruşun ne olacağı sorusudur (`docs/yula-execution/STATUS.md` §3, F1 satırı). Bu belge karar vermez, öneri içermez; yalnız kanıtı ve her seçeneğin etkisini toplar.
Kaynak commit `fd202bb`, tarih 2026-11-13. Tıbbi/sağlık ya da puan iddiası yoktur. Kamera zincirinin (video → MediaPipe) bağımsız sınaması yoktur; özelliğin tamamı "deneme" etiketli ve bayrak arkasında, varsayılan kapalıdır (`MODEL-KARTI.tr.md:3`).

## Kanıt özeti
Hedef eşik: TA ≥ 0,90 ve yanlış kabul (FA) ≤ 0,10 (`MODEL-KARTI.tr.md:64`). Fark = ölçülen TA − 0,90 (çıkarım, aritmetik). "Ders" = katalogdaki `lessons` listesi uzunluğu.

| Duruş (katalog id) | Model | Tür | Ders | Ölçülen TA (hangi sınama) | Hedef | Fark | FA | Kaynak |
|---|---|---|---|---|---|---|---|---|
| Dağ duruşu (`mountain`) | M1 | ayakta | 4 | 0,83 (E15 bağımsız DSZ-Yoga; E14'te TA yok) | 0,90 | −0,07 | 0,05 / 0,00 | `MODEL-KARTI.tr.md:37`; `camera-poses.v1.json:39,114` |
| Yarım kalkış (`halfway-lift`) | M1 | ayakta | 2 | 0,87 (E15; E14'te TA yok) | 0,90 | −0,03 | 0,07 / 0,07 | `MODEL-KARTI.tr.md:41`; `camera-poses.v1.json:305,364` |
| Küçük sandalye duruşu (`small-chair-pose`) | M1 | ayakta | 2 | 0,80 (E15; E14'te TA yok) | 0,90 | −0,10 | 0,05 / 0,03 | `MODEL-KARTI.tr.md:44`; `camera-poses.v1.json:491,547` |
| Kısa adımlı Savaşçı I (`warrior-one-short`) | M1 | ayakta | 2 | 0,62 (E15); E14 veri içi 0,92 | 0,90 | −0,28 (E15) | 0,00 / 0,01 | `MODEL-KARTI.tr.md:47`; `camera-poses.v1.json:667,728` |
| Alçak kobra (`low-cobra`) | M2 | yer | 2 | 0,83 (E14 YAR ayrılmış kişiler, veri içi; E15'te TA yok) | 0,90 | −0,07 | 0,00 / 0,02 | `MODEL-KARTI.tr.md:75,91`; `camera-poses.v1.json:1363,1415` |
| Uzanarak dinlenme (`lying-rest`) | M2 | yer | 3 | 0,83 (E14, veri içi; E15'te TA yok) | 0,90 | −0,07 | 0,01 / 0,03 | `MODEL-KARTI.tr.md:80,91`; `camera-poses.v1.json:1610,1656` |
| Aşağı bakan köpek (`down-dog`) | M2 | yer | 2 | 0,82 (E15 bağımsız); E14 veri içi 1,00 | 0,90 | −0,08 (E15) | 0,05 / 0,00 | `MODEL-KARTI.tr.md:78,91`; `camera-poses.v1.json:1517,1560` |

- Her satırdaki FA, `MODEL-KARTI.tr.md`'deki "E14 / E15" sırasıdır; 7 duruşun FA'sı ≤ 0,10: M1'in 4'ü için `MODEL-KARTI.tr.md:65` ("FA 20 duruşun hepsinde ≤ 0,10"), M2'nin 3'ü için tablo satırları (`MODEL-KARTI.tr.md:75,78,80`).
- M1'in 4'ü bağımsız sınamada (E15, 3B iskeletin sentetik yan görüşü, "iyimser olabilir") eşik altı kaldı (`MODEL-KARTI.tr.md:59,65`). Nedeni kaynakta: `define` aralıkları duruş ailesinden dar; ön kayıt gereği bu veriyle düzeltilmedi (`MODEL-KARTI.tr.md:65`).
- M2'nin 3'ünde de ayar yapılmadı (`MODEL-KARTI.tr.md:91`). Kataloğun kanıt etiketi: M1 dördü `independent-below`, `low-cobra` ve `lying-rest` `in-data-below`, `down-dog` `independent-below`.
- E16 (UI-PRMD), aile ilkesiyle genişletilmiş v1.1 aralıklarını denedi; ön kayıtlı kurala göre kabul edilmedi, katalog v1.0'da kaldı (`MODEL-KARTI.tr.md:60`).
- Kapsam sayıları: M1 20 duruş, M2 15 yer duruşu, toplam 35 duruş, 60 ders (`KAPSAM.tr.md:5`); M1 hedefi ≥ 20 duruş (`KAPSAM.tr.md:3`). `packages/lissom_engine/test/camera/camera_coach_test.dart:68-70` M1'i değil, katalogdaki toplam duruş sayısını (≥ 20) denetler.

## Seçenekler
Sayılar katalogdan hesaplandı (çıkarım): 4 M1 duruşu kaldırılırsa bu duruşların derslerinden yalnız başka duruşu olmayanlar kamerasız kalır: h03, a03, a06, a11, h44, h57 = 6 ders (60 → 54). 7 duruşun hepsi kaldırılırsa ek olarak h17, v12, h16, h29, y12, h46 = toplam 12 ders (60 → 48). Diğer ders (h53, v02, a05, a09, v13) başka duruşla kamerada kalır.

| | (a) "Deneme"de tut (bugünkü durum) | (b) Kapsamdan çıkar | (c) Eşik altı kalsın, kullanıcıdan gizle |
|---|---|---|---|
| Ne değişir | Hiçbir şey. Kodda, katalogda, belgede değişiklik yok. | Katalogtan duruşlar silinir. STATUS §3 F1'e göre M1 20 → 16 (hedef ≥ 20'nin altı), toplam 35 → 31 (`STATUS.md:41`; `KAPSAM.tr.md:38`). Bu yalnız M1'in 4'ünü sayar; M2'nin 3'ü de çıkarsa toplam 28 (çıkarım). MODEL-KARTI ve KAPSAM tabloları güncellenir. | Katalog kalır, kullanıcıya gösterilmez. Mevcut mekanizma bulunamadı: yeni iş gerekir. Katalogdaki kök `status` alanı ("trial", `camera-poses.v1.json:5`) Dart'ta okunmuyor; `evidence` alanı okunuyor (`camera_pose_catalog.dart:98,244`) ama `lib/` içinde kullanılmıyor; duruş bazlı gizleme yok (`posesForLesson`, `camera_pose_catalog.dart:177-184`, süzmeden döner). |
| Kullanıcıya etkisi | Bayrak açıkken 7 duruşun tüm dersleri (4+2+2+2+2+3+2 = 17 ders-duruş eşleşmesi) "Kamera koçluğu · deneme" altında koçluk alır (`lesson_camera_section.dart:61-62`). | Çıkarılan duruşların kamerasız kalan dersleri (M1 4 için 6 ders; 7 için 12 ders) "Bu dersi kamera değerlendirmiyor." gösterir (`lesson_camera_section.dart:80-90`). Başka duruşu olan dersler kamerasız kalmaz ama kaldırılan duruşun kamera kontrolünü kaybeder (örn. h53: `mountain` + `small-back-extension`; v02: `mountain` + `standing-arm-raise`; `camera-poses.v1.json` `lessons` listeleri). | (b) ile aynı ekran davranışı olabilir; ama kullanıcının ne göreceği tanımsız, mekanizma yok. |
| Yanlış geri bildirim riski | FA ≤ 0,10 (yanlış onay oranı düşük ölçüldü; M1'in 4'ünde E15 sentetik yan görüş ve iyimser olabilir, M2'nin 3'ünün FA'sı veri içi ölçümdür: satır 19–20). Doğru duruşun kaçırılma payı: 1 − TA (çıkarım): 0,17 / 0,13 / 0,20 / 0,38 / 0,17 / 0,17 / 0,18. Kaynak, yanlış reddi kullanıcıyı yanlış yöne itmeyen ama can sıkıcı bir hata olarak tanımlar (`MODEL-KARTI.tr.md:111`). | Bu duruşlar için kamera geri bildirimi olmaz; yanlış geri bildirim riski kalkar. | Gizlenen yerde (a) riski yok; gizlenmeyen yerde (a) ile aynı. |
| Geri dönüş maliyeti | Yok. | Katalog satırlarını geri eklemek (katalog düzenlemesi küçük; ama kanıt etiketi, belgeler ve aşağıda sayılan testler yeniden yazılır); kullanıcı tarafında dersler yeniden kamerayla gelir. | Mekanizmanın kendisi yeni iş; kapatma maliyeti mekanizmaya bağlı (bilinmiyor). |
| Etkilenen belge / test | Yok. | `KAPSAM.tr.md` (satır 3, 5, 12–16, 38), `MODEL-KARTI.tr.md` (tablolar), `STATUS.md` §3 F1, Motion panosu; testler: `floor_test.dart:20` (`cat.poses.length == 35`, 7'nin hepsi çıkarsa floor 15 → 12 için `:19`), `camera_coach_test.dart:70` (toplam duruş ≥ 20, 31 ve 28'de sağlanır). Kaldırılan duruşu `cat.pose('<id>')!` ile çağıran testler `null` üzerinde patlar (grep, çıkarım): `mountain` için `floor_test.dart:33`, `camera_coach_test.dart:123,144,169,196,207,216`, `camera_latency_test.dart:18`, `test/camera/camera_data_boundary_test.dart:274`, `test/camera/camera_coaching_trial_test.dart:140,161,180,203`, `integration_test/camera_device_smoke_test.dart:90,135,142`; `lying-rest` için (yalnız M2 de çıkarsa) `floor_test.dart:30,47,66`. Diğer 5 duruşun test kullanımı ve `camera_catalog_copy_test.dart` bu belgede taranmadı: `DOĞRULANMADI`. | Belirsiz (mekanizma yok); en az `MODEL-KARTI.tr.md` ve `KAPSAM.tr.md` yeni durumu yazmak zorunda; test etkisi `DOĞRULANMADI`. |

Not: STATUS §3 F1 satırında (c) "aralıklar genişletilip yeni bağımsız veriyle yeniden sınansın" diye yazıyor (`STATUS.md:41`; `KAPSAM.tr.md:38`); bu belgedeki (c) "gizle" ise brif tanımıdır. İki metin aynı seçeneği anlatmıyor.
Not: STATUS "M2'nin 3'ü için ayrı karar maddesi henüz yok, aynı üç seçenek geçerli" diyor (`STATUS.md:41`); KAPSAM'daki karar maddesi yalnız M1'in 4'ünü anıyor (`KAPSAM.tr.md:37-38`).

## Kurucuya sorulacak tek soru
"7 eşik altı duruş (M1: dağ, yarım kalkış, küçük sandalye, kısa Savaşçı I; M2: alçak kobra, uzanarak dinlenme, aşağı bakan köpek) için (a), (b) ya da (c)? Aynı seçenek hepsine mi, M1 ve M2 ayrı mı?"

## Karar sonrası iş
Kurucunun cevabı ADR-L00x olarak kaydedilir; `KAPSAM.tr.md`, `MODEL-KARTI.tr.md` ve STATUS §3 F1 buna göre güncellenir.

## Kaynaklar
- `docs/camera/MODEL-KARTI.tr.md` (satır 3, 37–47, 58–66, 75–91, 111)
- `docs/camera/KAPSAM.tr.md` (satır 3, 5, 12–16, 37–38)
- `docs/yula-execution/STATUS.md` §3, F1 (satır 41)
- `config/yoga/camera-poses.v1.json` (satır 5, 39, 305, 491, 667, 1363, 1517, 1610 ve `evidence` satırları)
- `packages/lissom_engine/lib/src/camera/camera_pose_catalog.dart` (satır 98, 177–184, 244)
- `lib/app/camera/lesson_camera_section.dart` (satır 61–62, 80–90)
- `packages/lissom_engine/test/camera/floor_test.dart` (19–20), `camera_coach_test.dart` (68–70)
- `docs/camera/VERI-LISANS-KAYDI.tr.md` (satır 7–9: E14 YAR, E15 DSZ-Yoga, E16 UI-PRMD veri bağlamı)
