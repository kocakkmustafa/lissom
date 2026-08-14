# ⏸️ BEKLEME MODU — DESIGN LİNKİ BEKLENİYOR (devir: 2026-08-05, koordinatör yazdı)

> **Bu blok en güncel talimattır ve altındaki her şeyden ÖNCELİKLİDİR.**
> Aşağıdaki eski bölüm (önceki oturumun devir promptu) teknik durum/sınırlar için
> GEÇERLİ — ama "kendi tasarımını sen yap" varsayımı **SÜPERSEDE** edildi (M-F-279).

## 🎨 Yeni model (kurucu kararı 2026-08-05)
Tasarımlar **TEK design-orkestrasyonu oturumunda** üretilir (Remotion + Claude design
paneli), sonra sana **tasarım linki + giydirme brief'i** olarak gelir. Her uygulama
KENDİ dilinde, birbirinden TAMAMEN FARKLI tasarlanacak.

**BU OTURUMDA YAPMAYACAKLARIN:**
- ❌ Tasarım kararı üretme (renk/tipografi/düzen/akış dili) — yön koordinatörden gelir.
- ❌ Kendi başına design turu başlatma, UI yeniden yazma, "cila" turu koşma.
- ❌ Kurucuya doğrudan tasarım sorusu sorma (M-F-77; koordinatörden geçer).

**BU OTURUMDA YAPACAKLARIN:**
1. Aşağıdaki okuma listesini bitir (bağlam kopukluğu olmasın).
2. Ağacı doğrula: `git -C ventures/lissom/app status` + `git -C ventures/lissom/app log -1` (**beyana değil ağaca güven**).
3. Kısa bir "hazırım" özeti yaz: okuduklarını + doğrulanan tepe commit'i + varsa
   ağaçta beklenmedik bir şey. **Sonra BEKLE.**
4. Giydirme brief'i gelince: tasarımı KENDİ yüzeyine uygula, dürüstlük sınırlarını
   ESNETMEDEN (aşağıda), kapılarını koştur, commit+push (kalıcı yetkin var).

## 📖 Okuma listesi (sırayla — bağlam bunlarda)
1. **Vault:** `knowledge/Yula Lab/20 Şirketler/Motion/🔄 Oturum Devri 2026-08-05 — Lissom Kamera Entegrasyonu Bitti (kalan-4).md` — senin son turunun kaydı.
2. **Vault:** `📊 Durum Panosu — Motion.md` → **08-05 "GÜNCEL DURUM BU BLOK"** (altı tarihsel).
3. **Vault:** `🔄 Oturum Devri 2026-08-05 — Orkestratör Kamera Dalgası Kapanışı → Design Orkestrasyonu Devri.md` — §4 yeni model + §5 kalan işler.
4. `ventures/lissom/workspace/DEFTER.md` + `PROGRESS.md` — **son bölüm** (kendi hükümlerin).
5. `ventures/motion-core/workspace/DEFTER.md` — **M-F-260 → M-F-279** (aile kuralları, bağlayıcı).
6. Bu dosyanın altındaki eski bölüm — teknik durum, ölçülmüş tuzaklar, bağlayıcı sınırlar.

## 📍 Senin durumun (2026-08-05, git-doğrulandı)
**Kamera entegrasyonu TAM** — main `ddd6c25`, push 0/0, ağaç temiz. Canlı-3 (`overhead_reach`·`deep_squat`·`active_straight_leg_raise`) + engelli-9 TÜRETİMLİ liste; köprü 8/19 metrik (kalan 11'in engeli ÇEKİRDEK yeteneği — mekanik eksiklik değil, isimli); engine 95/95 · app 37/37 · sim kanıtı `app/docs/kanit/sim-canli3-engelli9.png`. ⚠️ Sen cross-session MESAJ GÖNDERMEZSİN — raporunu oturum-içi son mesaj olarak yaz, koordinatör transcript'ten okur.

**İlk işin:** okuma listesi + ağaç doğrulaması + 'hazırım' özeti (oturum-içi), sonra BEKLE (tasarım linki gelecek).

## 🚧 Tasarımda da ESNEMEYEN sınırlar (giydirme sırasında geçerli)
- **K8:** kalibre edilmemiş sayısal skor YOK ("bant, nokta değil").
- **M-F-186:** vaat dili (`comingSoon`/"yakında") YASAK · engelli özellik İSİMLİ
  gerekçeyle görünür · `measurementOnly` beyanı **yüzeyin TEPESİNDE** (konum içeriğin parçası).
- **Dürüst hâller birinci sınıf ekrandır** (izin · kamera-yok · kimse-yok · kadraj-dışı) —
  tasarım bunları "artık" gibi ele alamaz; hâl-başına ayrı render yolu korunur.
- **Türetimli listeler elle yazılmaz** · ham `detail`/hata kodu yüzeye sızmaz.
- **Ekran kanıtı KAPIDIR:** "testler metnin VARLIĞINI sınar, DOĞRULUĞUNU sınamaz"
  (95 yeşil test yanlış-anatomi metnini görmedi — Lissom P0 dersi).
- Yeni ölçü/kapı/eşik tasarımı veya dürüstlük-metriği hükmü → **koordinatöre**.

## ⚙️ Kalıcı kurallar
- commit + push + merge **KALICI YETKİLİ**; `ventures/motion-core/lib` paylaşımlı ağacında
  **dal değiştirmek YASAK** (M-F-22).
- **iCloud-altı repoda `git add -A` yerine DOSYA-İSİMLİ add** (0-bayt `index.lock` riski, M-F-273);
  başkasının untracked dosyasına dokunma (M-016; `* 2.plist`-sınıfı iCloud artıkları dahil).
- **Bağlam sıkışırsa İSİMLİ DURDUR** — sessiz kalite düşüşü yerine isimli duruş (aile standardı).
- **Cihaz-kanıtı vaat edilmez:** iOS sim'de kamera YOK; gerçek-kamera canlılığı cihaz gününe
  ertelendi (kurucu, tek oturum). Hiçbir yüzey "cihazda kanıtlı" demez.

---
---

# Lissom — yeni oturum devir promptu (**DESIGN TURU**)

Bunu yeni Claude Code oturumuna AYNEN yapıştır. Tek devir kaynağı budur;
soğuk başlangıç için yazıldı. Detay: `PROGRESS.md` §"TUR MÜHRÜ — 2026-08-05"
ve `DEFTER.md` L-205…L-211 + tur mührü. (Kamera-devri promptu SÜPERSEDE.)

---

Sen **Lissom** oturumususun — Yula Motion ailesinin (Choreia/Gravita/JabLab/
Ostinato kardeşleri, ortak `motion_core`) kamera-tabanlı hareket-sağlığı/ROM
değerlendirme **wellness** uygulaması. Yön genelde **koordinatör oturumdan**
gelir (`Motion Orchestration`); kurucu doğrudan devreye dört istisnada girer:
harcama · store gönderimi · nihai fiyatlama · lisans-riski devri (M-F-77).

## 🎨 BU OTURUMUN İŞİ: DESIGN TURU

Kurucu kararı: kamera entegrasyonu bitti, **sıradaki tur tasarım.** Kod
altyapısı hazır ve yeşil; bu tur **görünen yüzeyi** ele alıyor.

**Elindeki gerçek:** `lib/app/assessment_home.dart` şu an **işlevsel ama
tasarlanmamış** — düz `Card`+`ListTile` listesi, ham test kimlikleri
(`overhead_reach`), ham metrik adları (`shoulder_flexion_left`). Sim kanıtı:
`app/docs/kanit/sim-canli3-engelli9.png` — **önce ona bak**, tasarım turunun
başlangıç noktası o ekran.

**Bağlayıcı sınırlar (tasarım bunları ESNETEMEZ):**
- **K8 + ADR-003:** sayısal skor YOK · karşılaştırma YOK · MDC/klinik iddia
  YOK. "Başlangıç noktan bu" anlatı sınıfı.
- **M-F-186 dört koşul:** yüzey gerekçesi · terfi yolu · yazım-anı
  `lessonClass` · **"ölçüm, not değil" beyanı YÜZEYİN TEPESİNDE.** Beyanı
  aşağı almak, kaydırmayan kullanıcıdan saklamaktır — konum içeriğin parçası.
- **Vaat dili YASAK:** `comingSoon` / "yakında" yok. Engelli testler İSİMLİ
  gerekçeyle görünür (L-206 hükmü). Mevcut metin *"Bunlar 'yakında' değil"*
  diye AÇIKÇA reddediyor — bu cümle korunmalı.
- **Tıbbi dil yasak** (wellness sınırı) · `tools/wellness_lint.py` kapısı var.
- **Canlı/engelli ayrımı TÜRETİLİR** (`deriveLiveness()`), elle liste YAZILMAZ.
- Danışmanlar: `design-review-auditor` · `visual-polish-critic` ·
  `uiux-designer`; erişilebilirlik için `accessibility-specialist`.

**Muhtemel tasarım kalemleri** (koordinatör önceliklendirir):
ham kimlikler → insan-okur adlar + açıklama · canlı/engelli ayrımının görsel
dili · dürüst hâllerin (izin · kamera · kimse-yok · eklem-kadraj-dışı) ekran
tasarımı · ölçüm anı yüzeyi · batarya özeti cilası · tipografi/renk/boşluk
sistemi · a11y (kontrast, dinamik yazı, VoiceOver).

## Başlangıç sırası

1. `ventures/lissom/workspace/PROGRESS.md` **son bölümünü** oku (tur mührü).
2. `DEFTER.md` L-205…L-211 + tur mührü.
3. **Sim ekran kanıtını GÖR:** `app/docs/kanit/sim-canli3-engelli9.png`.
4. `git status` **her iki ağaçta** ("beyana değil ağaca güven").

## Durum (2026-08-05 tur sonu — doğrulandı, beyan değil)

**Repo:** `lissom/app` main, tüm tur push'lu. `motion-core/lib` paylaşımlı ağaç
`feat/lissom-v3-onayi` @ `05aacaf` — **DOKUNULMADI, dalı DEĞİŞTİRİLMEDİ.**

**Pin:** `motion_core 0.11.0` + `motion_camera 0.1.2`, **tek ref**
`f13bdc93b2eae2f741bfcdb4c9270a88e5d75e5d` (TAM-40-SHA). Pin kapısı **9/9**,
üç çapalı (iç tutarlılık · dış sabit · çözülen sürüm).

**Platform kabuğu KURULDU:** `ios/` + `android/` · `com.yulalab.lissom` ·
görünen ad **Lissom** · iOS deployment **14.0** ×3 · Podfile
`platform :ios, '14.0'` + `use_frameworks! :linkage => :static`.

**Kapılar:** engine **95/95** · app **37/37** · analyze TEMİZ (ikisi de) ·
Python **10 kapı** · araç-kapıları (`two_mode_report` · `synthetic_ceiling` ·
`vmr_baseline`) · **iOS sim derleme ✓** · **Android debug APK ✓**.

**Canlı yol hazır:** `live_evaluator.dart` (kaynak BİLDİRİR, değerlendirici
ÖLÇER) · `live_session_state.dart` (5 sealed hâl) · `FakePoseSource` (sim'de
kamera olmadığı için ürünün ikinci kaynak tipi, mock DEĞİL).

**Kapsam:** 12 testin **3'ü** canlı (`overhead_reach` · `deep_squat` ·
`active_straight_leg_raise`), **9'u** isimli engelli. Köprü **8/19** metrik;
kalan 11'in engeli çekirdek yeteneği (üç ölçü tipi Dart'ta yok + düzlem
ayrımı yok), mekanik eksiklik DEĞİL.

## ⚠️ Bu turda ödenmiş bedeller (tekrarlamayın)

- **Platform duvarları** (Gravita/Ostinato ölçümü): iOS deployment **14**
  (MediaPipe şartı, pbxproj'da ÜÇ yer) · Podfile **`:linkage => :static`**
  (MediaPipe statik xcframework; dinamikte CocoaPods REDDEDİYOR) · pod
  komutları **`LANG=en_US.UTF-8`**. **Şablonun eklediği ÇIPLAK
  `use_frameworks!` statik linkage'ı EZER** — kaldırıldı, geri gelmesin.
- **iCloud/codesign SIRASI:** `flutter clean` koşarsan symlink'i **YENİDEN
  KUR**: ÖNCE `rm -rf build && flutter clean`, SONRA
  `ln -sfn ~/lissom_buildout build`. Ters sıra temizliği symlink'i siler.
- **Pub ref'leri STRING karşılaştırır** — kısa SHA da tag adı da reddedilir.
  TAM-40-SHA yaz, kilitten (`pubspec.lock` `resolved-ref`) doğrula.
- **Sim-çekişme reçetesi:** `xcrun simctl terminate <udid> com.yulalab.lissom`
  → `install` → `launch` → **6 sn bekle** → `screenshot`.
- **`grep` dosya yokken de "YOK" der** — yokluk iddiasını emsalle ayırt et
  (bu turda `Profile.xcconfig`'te tam bu oldu; Gravita'da da yok, uyarı
  BEKLENEN, müdahale edilmedi).
- **`nohup &` harness'ın "completed" bildirimini yanıltır** (exit 0 =
  başlatma komutunun kodu). Uzun işi doğrudan arka planda koştur ya da bitişi
  `pgrep`/çıktı dosyasıyla DOĞRULA.

## Sert kurallar (kalıcı)

- `ventures/motion-core/lib` paylaşımlı ağacında **DAL DEĞİŞTİRMEK YASAK**
  (M-F-22). Rig işi izole worktree'de; araçlar `MOCORE_RIG` env'i okur.
- ⚠️ iCloud-altı repolarda geniş `git add -A` yerine **DOSYA-İSİMLİ add** —
  `add -A` iCloud senkronunda 0-bayt `index.lock` bırakabiliyor (M-F-273).
- **Ölçülmemiş eşik YAZILMAZ; sayılar TÜRETİLİR.** Beş canlılık sorusu
  bağlayıcı — özellikle "bu kapıyı kim SORUYOR?" ve "kapı KIRMIZI yanabiliyor
  mu?" (öz-testi olmayan kapı hiçbir şey kanıtlamaz).
- **Yeni ölçü/kapı/eşik tasarımı, dürüstlük-metriği hükmü → koordinatöre.**
  Tasarım turunda da geçerli: görsel karar serbest, **dürüstlük sınırı
  esnetilemez.**
- commit + push + merge **KALICI YETKİLİ**. **M-016:** başkasının untracked
  dosyasına DOKUNMA (`* 2.plist`-sınıfı iCloud artıkları dahil — bildir, silme).
- **Cihaz-kanıtı VAAT EDİLMEZ:** iOS sim'de kamera YOK. Gerçek-kamera
  canlılığı **cihaz gününe** ertelendi (kurucu kararı, tek oturum). Hiçbir
  beyan "cihazda kanıtlı" DEMEZ; `judgedRatio`-sınıfı sayı vaat edilmez.

## 🎓 Bu turun en değerli dersi (tasarım turunda birebir geçerli)

**Ekran kanıtı, 95 testin görmediği bir kusuru yakaladı.** `ankle_dorsiflexion`
engel gerekçesi *"gövde açısı iki ayrı düzlemde ölçülemiyor"* diyordu — ama o
testin metriği `tibia_inclination`, yani **kaval kemiği, gövde DEĞİL.**
Kullanıcıya yanlış anatomi söylüyordum.

**Testler metnin VARLIĞINI sınar, DOĞRULUĞUNU sınamaz.** Bir gerekçenin
anatomisi ancak okunarak yakalanır. Tasarım turunda bu daha da kritik: metin
ve görsel doğruluğu yalnız EKRANDA görülür — ekran kanıtı formalite değil
**KAPI**.

## Açık kalanlar (hepsi koordinatörde, tasarım turunun konusu DEĞİL)

L-187 (L-031 Dart uzay göçü — köprü sayısı normatif referanstan medyan
**11,29°** / p95 **37,47°** sapıyor; `measurementOnly` yüzey bu yüzden doğru) ·
L-193 (süs-beyan guard'ı göçle gelir) · L-203 (netlik kapı-tasarımı — eşik
TÜRETİLEMEDİ, isimli kapanış) · L-185 (hareket-kimliği) · L-173 (varyant
kimliği) · 11 fixture yeniden-kesim · **cihaz günü**.
