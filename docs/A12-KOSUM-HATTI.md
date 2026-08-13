# 📱 A12 — CİHAZ KOŞUM HATTI (L-313, 2026-08-13)

> **Kabul ölçütü (devir promptu):** *"profil geldiğinde koşacak komut budur"* diyen
> **çalıştırılabilir bir reçete**, ve o reçetenin **imza dışındaki her adımının BUGÜN
> ölçülmüş** olması.
>
> **Durum:** ✅ imza dışındaki **7 adımın 7'si bugün ölçüldü** ·
> 🛑 **3 onay kapısı** açık · ⛔ **0 teknik engel**

---

## 🔴 ÖNCE: DEVREDİLEN ENGEL YANLIŞTI

Devir notu ve koordinatör A12'yi şöyle yazdı:

> *"makinede kurulu **tek** provizyon profili `com.yulalab.burunfarki`;
> `com.yulalab.lissom` **YOK**. ⇒ Engel **imza**, yani **B1/B7 — kurucuda.**"*

**Ölçüm (bugün, bu hat):** iddia **yanlış dizinden** kuruldu.

| ne | iddia | ölçüm |
|---|---|---|
| profil dizini | `~/Library/MobileDevice/Provisioning Profiles/` | Xcode 26 **`~/Library/Developer/Xcode/UserData/Provisioning Profiles/`** kullanıyor |
| profil sayısı | **1** | **9** iOS profili (+1 macOS `.provisionprofile` = 10 girdi) |
| `com.yulalab.lissom` kapsayan profil | **YOK** | **VAR** — `iOS Team Provisioning Profile: *` (`T5HZGYBWK8.*`), geçerlilik **2027-05-12** |
| imzalı cihaz derlemesi | denenmedi | **`** BUILD SUCCEEDED **`** — `codesign` `Identifier=com.yulalab.lissom`, `TeamIdentifier=T5HZGYBWK8` |

> ***YANLIŞ YOL + SESSİZ HATA = BOŞLUKTA SIFIR*** — bu hattın **kendi kayıtlı tuzağı**
> (`packages/…` yerine `app/packages/…`), bu kez **profil dizininde** tekrarladı.
> ⇒ *Teşhis, bağışıklık değildir.*

🔬 **Ve ölçümü yakalayan şey envanter DEĞİL, GERÇEĞİ DENEMEKTİ:** ilk envanter turu da
eski dizine baktı ve *"1 profil"* dedi. Yanlışı **imzalı derlemeyi fiilen koşmak** açtı.

### 📊 AYNISINDAN KAÇ TANE DAHA VAR? — **beş hattın BEŞİ**

| hat | bundle | takım |
|---|---|---|
| Choreia | `com.yulalab.choreia` | `T5HZGYBWK8` |
| Gravita | `com.yulalab.gravita` | `T5HZGYBWK8` |
| JabLab | `com.yulalab.jablab` | `T5HZGYBWK8` |
| Ostinato | `com.yulalab.ostinato` | `T5HZGYBWK8` |
| **Lissom** | `com.yulalab.lissom` | `T5HZGYBWK8` |

Joker profil **`T5HZGYBWK8.*`** beşini de kapsar. ⇒ *"provizyon profili yok"* diye
yazılmış her A12 engeli **beş hatta da yeniden ölçülmelidir.* (Koordinatöre bildirildi.)

---

## GERÇEK ENGEL — ölçüldü, ve İMZA DEĞİL

Joker profil bundle'ı kapsıyor **ama** `ProvisionedDevices` listesinde **1 cihaz** var
ve o, bağlı telefon **değil**:

```
joker profil cihazı : 00008132-001A70163AD3801C
bağlı telefon       : 00008120-001804D83E13C01E     ← farklı
```

**Ama bağlı telefon bu takıma KAYITLI** — 9 profilin **4'ünde** görünüyor
(`lifeos` · `burunfarki` · `lifeos.LifeOSWidget` · `braavolabs.mobile`).

⇒ Portal cihaz kaydı **GEREKMİYOR**. Eksik olan tek teknik şey **jokerin tazelenmesi**,
ve onu `-allowProvisioningUpdates` **otomatik** yapar.

> ***KURUCUDAN İSTENEN ŞEYİN BOYU, ÖLÇÜLMEMİŞ BIRAKILAN ŞEYİN BOYUDUR.*** (6.11)
> İstenen **"imza altyapısı kur"** değil; **iki onay.**

---

## 🛑 ÜÇ ONAY KAPISI — hat kapatamaz (M-F-77)

| # | kapı | neden hatta değil |
|---|---|---|
| **1** | joker profili tazele (`-allowProvisioningUpdates`) | **Apple Developer hesabına YAZAR** — hesap durumu mutasyonu |
| **2** | uygulamayı telefona **kur** | kurucunun **kişisel** telefonu; devir promptu açıkça yasakladı |
| **3** | ekran kaydı / cihaz logu al | kurulumun ardından; cihazda kullanıcı eylemi |

---

## ▶️ REÇETE — onay geldiği an koşacak komutlar

### 0) Ön uçuş (her zaman önce — **teknik engel var mı?**)

```bash
bash tools/a12_device_preflight.sh --build
```
`exit 0` = GO · `exit 2` = onay bekler, teknik engel yok · `exit 1` = teknik engel
Öz-testi: `bash tools/a12_device_preflight.sh --self-test` → **2/2**

### 1) Profil tazeleme + kurulum + koşu — **TEK KOMUT** (onay 1+2)

```bash
flutter run --release -d 00008120-001804D83E13C01E
```
Flutter `-allowProvisioningUpdates` ile çağırır; joker profil **otomatik tazelenir**,
uygulama kurulur ve açılır. Alternatif (Xcode ile, aynı iş):

```bash
xcodebuild build -workspace ios/Runner.xcworkspace -scheme Runner \
  -configuration Release -destination 'id=00008120-001804D83E13C01E' \
  -allowProvisioningUpdates
```

### 2) Cihazda yürünecek akış — **A1'in cihaz karşılığı**

`test/full_flow_walk_test.dart` neyi yürüdüyse elle o yürünür:

| # | adım | beklenen |
|---|---|---|
| 1 | uygulamayı **taze kurulumdan** aç | onboarding açılır (bayrak `false`) |
| 2 | onboarding'i **7 dokunuşla** geç | ⚠️ bayrak set edilerek DEĞİL, **düğmeye basarak** |
| 3 | Home → **Start a measurement** | `LiveCaptureScreen` push'lanır |
| 4 | **kamerayı gerçekten çalıştır** | ⬅️ **A1'in KANITLAMADIĞI tek yer** |
| 5 | **I'm done** | sonuç yüzeyi |
| 6 | Progress sekmesi | **1 kayıt** görünür |

🔴 **4. adım bu koşumun ASIL SEBEBİ.** A1 `FakePoseSource` ile kapandı; **gerçek kare
akışı, gerçek ışıkta landmark kalitesi ve kalibrasyon eşiği cihazda doğrulanmadı.**
Ürünün kendi kopyası bunu **kullanıcıya söylüyor** (`surfaces.dart`,
`CaptureUnavailableNote`): *"This has not been tried on a real phone: camera permission,
frame quality, and calibration still need a device pass."*

> ⇒ **A12 bir onay kutusu değil:** uygulamanın kendi dürüstlük metnini **doğru ya da
> yanlış** çıkaran ölçüm. Geçerse o cümle **değişmeli**; geçmezse ürün **yayına hazır değil.**

### 3) Kanıt — ikisi de alınır

```bash
# ekran kaydı (cihazda; kurucu başlatır)
xcrun devicectl device info details --device 00008120-001804D83E13C01E

# cihaz logu — uygulama süzgeciyle, koşu SIRASINDA
xcrun devicectl device console --device 00008120-001804D83E13C01E \
  | grep -i lissom > /tmp/lissom_a12_device.log
```
Kabul: **ekran kaydı** (6 adımın tamamı) **+** cihaz logunda ölçüm kaydının izi.

---

## ✅ BUGÜN ÖLÇÜLENLER — imza dışındaki her adım

| # | adım | ölçüm |
|---|---|---|
| ① | profil kaynağı | 9 iOS profili, Xcode dizini |
| ② | hedef kimliği | `com.yulalab.lissom` · `T5HZGYBWK8` |
| ③ | cihaz | `available (paired)`, kablosuz bağlı, UDID okundu |
| ④ | imza kimliği | `Apple Development` mevcut |
| ⑤a | kapsayan profil | joker `T5HZGYBWK8.*` VAR |
| ⑤b | cihaz takıma kayıtlı | 4 profilde görünüyor |
| ⑥ | imzalı derleme | `BUILD SUCCEEDED`, depo kirliliği **0 satır** |

**Ölçülemeyen, adıyla:** 4. adım (gerçek kamera) — *tanımı gereği* cihazda ölçülür.
`xctrace` cihazı hâlâ `Devices Offline` diyor; `devicectl`/`flutter` `available` diyor.
İki araç, **iki kimlik uzayı** (`00008120-…` UDID ↔ `882CC2EC-…` CoreDevice) —
*bir aracın duvarı, sorunun duvarı değildir.*
