# §3.2b TAVAN ÖLÇÜMÜ — sentetik ground-truth VMR

**Tarih:** 2026-08-04 · **Durum:** ölçüldü, tavan yarısı KAPANDI · **frameBasis:** anatomical + camera (ikisi de raporlu)

Yeniden üretim: `python3 tools/synthetic_ceiling.py`

## Soru

Protokol §3.2b: *"Tavan (ceiling): sentetik ground-truth kliplerde VMR. %100'e
ulaşılamıyorsa fark koşuldan değil **hattın kendisinden** gelir; B1/B2
arasındaki boşluk o kaybı da içerir."*

Sentetik iskelet kusursuz (`confidence=1.0`, gürültü yok, landmark'lar
kinematik zincirden türüyor). O hâlde VMR **%100 olmalı**; olmuyorsa kayıp
hattındır.

## Cevap — hat kaybı SIFIR

**T-A (ideal kadraj, yaw=0): 10/10 testte VMR = 1,000, her iki frameBasis'te.**

| test | metrik | VMR(anat) | VMR(cam) | med(anat) | aralık(anat) |
|---|---|---|---|---|---|
| overhead_reach | shoulder_flexion_right | 1,000 | 1,000 | 85,00° | 170,00 |
| deep_squat | knee_flexion_right | 1,000 | 1,000 | 120,00° | 120,00 |
| overhead_squat | trunk_lean | 1,000 | 1,000 | 12,50° | 25,00 |
| ankle_dorsiflexion | tibia_inclination_right | 1,000 | 1,000 | 10,00° | 20,00 |
| hamstring_reach | reach_depth | 1,000 | 1,000 | 1,64 | 0,124 |
| hip_hinge | trunk_lean | 1,000 | 1,000 | 40,00° | 80,00 |
| lateral_bend | trunk_lateral_tilt | 1,000 | 1,000 | 20,00° | 40,00 |
| forward_lunge | knee_height_right | 1,000 | 1,000 | 0,81 | 0,113 |
| thoracic_rotation | shoulder_line_foreshortening | 1,000 | 1,000 | 0,69 | 0,400 |
| active_straight_leg_raise | hip_flexion_right | 1,000 | 1,000 | 140,00° | 80,00 |

**Hüküm: B1 (%90) / B2 (%75) boşluğu SAF KOŞUL ETKİSİ olarak okunabilir** —
hat kendi başına hiçbir geçerli ölçümü düşürmüyor. §3.2b'nin tavan yarısı
kapandı; taban yarısı (triyajın reddettiği kliplerde VMR) karantina çekimini
bekliyor.

### Varyans kapısı — iki gerçek delik buldu

"VMR %100" tek başına hiçbir şey kanıtlamaz: metrik senaryo boyunca SABİT
kalıyorsa senaryo o metriği hiç sürmüyor demektir ve %100 "hat kayıpsız"
değil **"hiçbir şey ölçülmedi"** anlamına gelir (L-183 vacuous-geçiş sınıfı).
Bu yüzden araç her metriğin senaryo içindeki aralığını da ölçüyor ve sıfırsa
**kırmızı yanıyor**. İlk koşumda ikisini yakaladı:

1. **`overhead_squat`** — primary metriği `trunk_lean`, ama senaryom yalnız
   kol/kalça/diz sürüyordu; değer 60 kare boyunca sabit **0,00°** kaldı.
   Düzeltildi (gerçek overhead squat'ta gövde de öne eğilir → `trunk_lean=25°`).
2. **`thoracic_rotation`** — senaryom SABİT bir yaw uyguluyordu, yani
   rotasyon hiç değişmiyordu (0,80 sabit). Ama bu testin ÖLÇTÜĞÜ ŞEY
   rotasyonun kendisi. Düzeltildi: yaw artık 0→60° **rampa**.

İkisi de "geçen" bir tavan üretiyordu. Kapı olmasa rapor %100 der ve iki test
hakkında hiçbir şey bilmediğimizi söylemezdi.

## T-B (dönük özne, yaw=±30°) — M-F-54 iddiasının sentetik sınaması

Lissom'un 12 testinden 8'i kullanıcıya *"yandan dur"* diyor, yani bu senaryo
süs değil.

**Anatomik mod TÜM yaw değerlerinde BİREBİR SABİT kaldı:**

| test | anat(0) | anat(−30) | anat(+30) | cam(0) | cam(−30) | cam(+30) | kamera sapması |
|---|---|---|---|---|---|---|---|
| overhead_reach | 85,00 | 85,00 | 85,00 | 85,00 | 87,09 | 81,37 | −3,63 … +2,09 |
| deep_squat | 120,00 | 120,00 | 120,00 | 120,00 | 124,62 | 124,62 | **+4,62** |
| overhead_squat | 12,50 | 12,50 | 12,50 | 12,50 | 10,87 | 10,87 | −1,63 |
| ankle_dorsiflexion | 10,00 | 10,00 | 10,00 | 10,00 | 8,68 | 8,68 | −1,32 |
| hip_hinge | 40,00 | 40,00 | 40,00 | 40,00 | 36,01 | 36,01 | **−3,99** |
| lateral_bend | 20,00 | 20,00 | 20,00 | 20,00 | 17,50 | 17,50 | −2,50 |
| active_straight_leg_raise | 140,00 | 140,00 | 140,00 | 140,00 | 141,13 | 146,86 | **+6,86** |
| reach_depth | 1,64 | 1,64 | 1,64 | 1,64 | 1,64 | 1,64 | 0,00 |
| knee_height_right | 0,81 | 0,81 | 0,81 | 0,81 | 0,81 | 0,81 | 0,00 |

**Anatomik modun yaw sapması: tüm kategorilerde tam SIFIR.** M-F-54'ün
iddiası sentetik ground-truth'ta doğrulandı.

**VMR her iki modda ve her yaw'da 1,000** — yani yaw geçerliliği düşürmüyor,
yalnız kamera modunda DEĞERİ kaydırıyor. Bu ayrım önemli: kamera-modu kaybı
"ölçemedim" değil, **"yanlış ölçtüm"** biçiminde geliyor ve VMR kapısı onu
yakalamıyor.

### Yan gözlemler (dürüstlük notları)

- **Yaw-işareti duyarlılığı ayrışıyor:** `deep_squat`, `hip_hinge`,
  `lateral_bend`, `ankle` kamera modunda ±30° için AYNI değeri veriyor (|yaw|'a
  bağlı), ama `overhead_reach` (87,09 / 81,37) ve `active_straight_leg_raise`
  (141,13 / 146,86) yaw'ın İŞARETİNE duyarlı. İkinci grupta kamera modu
  yalnız gürültü değil **yönlü sapma** üretiyor.
- **`thoracic_rotation` doğru davranıyor:** `frameRef: camera` olduğu için
  anat = cam her zaman, ve yaw ofsetiyle değişiyor (0,69 → 0,77 → 0,40) —
  çünkü onun İŞİ rotasyonu ölçmek. Anatomik mod onu bozmuyor.
- **`reach_depth` yaw'dan tamamen bağımsız (her iki modda)** — L-192'nin beyan
  düzeltmesini bağımsızca doğruluyor: 3B mesafe rotasyon-değişmezi.
- ⚠️ **Bu senaryo L-190/2'yi SINAMIYOR.** `knee_height` da yaw'dan bağımsız
  çıktı, ama `height_diff_norm`'un riski **roll**'da (kamera yana yatarsa dünya
  y'si yerçekimi olmaktan çıkar), yaw'da değil. `synth.yaw` roll üretmiyor,
  dolayısıyla bu tablodaki 0,00 sapma L-190/2 hakkında **hiçbir şey
  söylemiyor** — o düzeltmenin doğrulaması roll senaryosu ister.

## Test→poz eşlemesi bir TASARIM kararıdır

`synth.Pose` yalnız sagittal açıları + `lateral_bend` + `heel_lift` taşıyor;
config'ten otomatik türetilemez. Her eşleme `tools/synthetic_ceiling.py`
içinde gerekçeli yazılı (ör. tibia eğimi ayrı parametre DEĞİL, kinematik
zincirden türüyor; hamstring'de diz DÜZ kalır çünkü guard tam onu koruyor).
**Eşleme yanlışsa tavan da yanlış olur**, o yüzden gizli bırakılmadı.

Geometrik olmayan iki test (`single_leg_balance`, `plank_hold` →
`hold_duration`) sessizce atlanmıyor, raporda isimle bildiriliyor.
