# F6 analizi: "Kollar kalkık ayakta duruş" yanlış kabulü (E16)

**DURUM: DOĞRULANMADI** — yanlış kabulün abdüksiyon / öne kaldırma (fleksiyon) dökümü örnek bazında yok; yalnız hareket bazında sayılar var. Bu belge tanım önermez ve karar vermez; kararı kurucu/içerik verir (`docs/yula-execution/STATUS.md:46`, F6).

## 1. Veri var mı?
- (i) MODEL-KARTI özet sayıları: **var**. (ii) Örnek bazında sınıflandırma: **yok**.
- `ventures/lissom/app` (`grep E16`, `find *e16* *prmd*`), `app/workspace/` ve `YULAlab-AI/scratch/` altında E16 sonuç dosyası bulunmadı; yalnız belgeler ve `tool/camera_model/evaluate_uiprmd.py` çıktı.
- Ek arama `ventures/lissom/data/` altında bulundu (repo dışı, ağaç dışı veri; `app/` ya da worktree içinde değil): `/Users/mustafakaankocak/Developer/YULAlab-AI/ventures/lissom/data/E16-uiprmd-v1-v11/` içinde `RESULT-v1.0.json`, `RESULT-v1.1.json`, `PLAN.tr.md`; ham veri `/Users/mustafakaankocak/Developer/YULAlab-AI/ventures/lissom/data/data/zenodo-23104965-uiprmd/ext/Segmented Movements/Vicon/Positions/` (990 dosya); hareket adları `/Users/mustafakaankocak/Developer/YULAlab-AI/ventures/lissom/data/data/zenodo-23104965-uiprmd/raw/README.md`.
- `RESULT-*.json` yalnız toplu sayı tutar; tekrar (örnek) bazında doğru/yanlış kabul listesi yoktur (`evaluate_uiprmd.py:100-122` yalnız `falseAcceptBy` toplar; `rows` diske yazılmaz).

## 2. MODEL-KARTI ne diyor
- `docs/camera/MODEL-KARTI.tr.md:61`: "`standing-arm-raise` 0,35"; yana açılan kollar da "kollar kalkık" görünüyor, "aile tanımı sorusu".
- `:110`: kaynak omuz abdüksiyonu ve skapsiyon; a04 ve v02 kolu "rahat olduğu kadar" kaldırtıyor; karar: "her yönden" mi, yalnız öne kaldırma mı. Yalnız öne kaldırma seçilirse yan görüş bunu tek başına ayıramaz (kartın kendi ifadesi).
- Kaynak sayı: `RESULT-v1.0.json` ve `RESULT-v1.1.json` (`standing-arm-raise`): 350 / 990 = 0,3535 (pozitif 0, negatif 990). v1.1 aynı sayıyı verir.

## 3. Elde olan en yakın döküm (hareket bazında, örnek bazında DEĞİL)
`falseAcceptBy` (tekrarın ortasındaki 0,5 s pencere "kollar kalkık" sayıldı) ve hareket adları (`raw/README.md:37-41`, yalnız ad listesi; yol §1); tekrar sayıları `Positions/` dosya sayımı (m03 = 90, diğerleri 100). "Not" sütunu README'de yazmaz, **çıkarım**dır (ad ve anatomi bilgisinden; kaynakta yok):

| Hareket | Ad (README) | Yanlış kabul | Not |
|---|---|---|---|
| m07 | Ayakta omuz abdüksiyonu (yana) | 100 / 100 | abdüksiyon (çıkarım: yana kaldırma) |
| m10 | Ayakta omuz skapsiyonu | 98 / 100 | çıkarım: skapsiyon yana ile öne arası bir düzlem; kart "abdüksiyon ve skapsiyon" diyor (`MODEL-KARTI.tr.md:110`) |
| m09 | Omuz iç-dış rotasyon | 77 / 100 | kol yan (`MODEL-KARTI.tr.md:60` destekliyor); **DOĞRULANMADI** neden kabul edildi |
| m08 | Omuz ekstansiyonu | 41 / 100 | çıkarım: geriye kaldırma; **DOĞRULANMADI** |
| m06 | Dik bacak kaldırma | 34 / 100 | çıkarım: kol hareketi değil (bacak hareketi); **DOĞRULANMADI** |
| diğer | m01–m05 | 0 | |

- Toplam 34+100+41+77+98 = 350. Abdüksiyon+skapsiyon (m07+m10) = 198/350 (≈ %57); m10'un "yana" sayılması çıkarımdır. Kartın "kaynağı yana açılan kollar" cümlesi bunun yarıdan fazlasını açıklar, kalan 152 (m06, m08, m09) kartta açıklanmamıştır (m09 için kart :60 "omuz rotasyonu kollar yandayken yapılıyor" der).
- Ad listesinde (`raw/README.md:37-41`) öne kaldırma (fleksiyon) adlı hareket yok (çıkarım: saf öne kaldırma pozitifi E16'da yok); bu yüzden "öne kaldırma kabul edilir mi" E16 ile ölçülemez. `standing-arm-raise` pozitif sayısı 0 (`RESULT-v1.0.json`).

## 4. Kural kodda nasıl çalışıyor
- Katalog: `config/yoga/camera-poses.v1.json:117` `standing-arm-raise`. `define` (kabul için hepsi): `ankleDrop` 1,25–2,6; `thighFromVertical` ≤ 35; `kneeMin` ≥ 155; `trunkLean` −15…15; `shoulderFlex` ≥ 50 (`:159-161`). Tutuş 10 s.
- `shoulderFlex` kolun açısı: omuzda, dirsek–omuz–kalça açısı, 2B, işaretsiz 0–180°, iki kolun **büyüğü** (`pose_features.dart:213-223`; Python başvurusu `tool/camera_model/features.py:132-139`, `_angle` `:39-48`). Karar: `CameraPose.inPose` tüm `define` aralıklarını arar (`camera_pose_catalog.dart:101`; Python `verifier.py:37-48`).
- Yan görüş kapısı: omuz genişliği/gövde ≤ 0,45 (`MODEL-KARTI.tr.md:32`).

## 5. Neden ayrım kuralda yapılamıyor (çıkarım)
Aşağıdakiler **çıkarım**dır, kod okumasına dayanır; E16'da yeniden ölçülmemiştir.
- Açı işaretsizdir: öne ve geriye kalkan kol aynı büyüklüğe düşebilir; yön (öne/geri) taşınmaz (çıkarım; `features.py:39-48`).
- Yalnız alt sınır var (≥ 50): üst sınır, dirsek, bilek ve derinlik (z) koşulu yok; kolun hangi düzlemde olduğuna bakılmaz (çıkarım; `:159-161`).
- İki kolun maksimumu alınır: tek kol yeter; hangisi olduğu önemsizdir (çıkarım).
- Yandan bakışta açı 2B izdüşümdür (`features.py:133-135` yalnız x,y). E16 projeksiyonu yanal ekseni z kanalına atar (`evaluate_uiprmd.py:77`; `shoulderFlex` onu kullanmaz). Çıkarım: saf yana kaldırmada dirsek x'te kıpırdamaz; omuz seviyesinin altında 2B açı ≈ 0°, üstünde ≈ 180° okunur, öne kaldırmada θ okunur. Yani 50–90° aralığında yana ve öne ayrışır; yatay düzlemin üstünde ayrışmaz (çıkarım). m07'nin 100/100 kabulü kolların omuz üstüne çıkmasından olabilir (olası, ölçülmedi).
- Sonuç (çıkarım): kural yön ayrımı için ayrı bir girdi taşımaz (işaretsiz açı, alt sınır ≥ 50, z yok); ancak 2B izdüşümde yana/öne ayrımı omuz seviyesinin altında kısmen mümkün görünüyor, üstünde değil. MODEL-KARTI:110'daki "yan görüş tek başına ayıramaz" ile uyumlu ama bu belge ölçmedi.

## 6. Doğrulama için gereken
1. E16 yeniden koşusu: `python3 tool/camera_model/evaluate_uiprmd.py <uiprmd-dir> <catalog.json> <out.json>`; girdi `ventures/lissom/data/data/zenodo-23104965-uiprmd` ve `E16-uiprmd-v1-v11/catalog-v1.0.json`. Çıktıya tekrar bazında satır (`rows`) yazılması gerekir (şimdiki araç yazmıyor); bu iş ayrı görevdir, bu belgede yapılmadı.
2. m06, m08, m09 yanlış kabullerinin nedeni için o tekrarların `shoulderFlex` değerleri.
3. Gerçek öne kaldırma pozitifi (UI-PRMD'de yok): E15 DSZ-Yoga'da `standing-arm-raise` pozitifi yok (`MODEL-KARTI.tr.md:38`, "— / 0.00"), yani başka veri gerekir.

## 7. Kurucuya soru
`standing-arm-raise` "kollar yukarıda, her yönden" (a) mi, yoksa yalnız öne kaldırma (b) mi sayılsın?
