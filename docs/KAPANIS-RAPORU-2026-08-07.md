# Lissom — gece vardiyası KAPANIŞ RAPORU (2026-08-07)

> ⚠️ **Kanal notu:** bu rapor iki saat boyunca **oturum-içi** yazıldı ve
> koordinatöre ulaşmadı — o `git log` ve Obsidian okuyor. *Kanalın varlığını
> ölçmeden varsaydım;* gecenin kendi dersinin (**beyanın varlığı ≠ tetiğinin
> varlığı**) bana dönmüş hâli.

## Beş satır

| | |
|---|---|
| **son SHA** | `8d55267` |
| **süitler** | app **148/148** · engine **95/95** · python **13/14** → `python3 tools/all_gates.py` = **TÜMÜ YEŞİL** |
| **ağaç** | `main` · uzakla fark **0** · kirli **0** · 49 commit (giriş `bd33801`) |
| **AÇIK KALANLAR** | aşağıda, her biri sınıfıyla |
| **YENİ OTURUM İLK İŞ** | **C-195 static kilidi — kamerayı bağlayan commit'ten ÖNCE** |

---

## 🔴 KURUCU CEVABI — Lissom bugün gönderilemez, **4 engel**

**Ölçü:** *bir insan telefonuna indirse* → **açılır, dört sekmeyi gezer, ne
ölçtüğümüzü ve ne ölçmediğimizi okur — ama tek bir seans yapamaz.**

| # | Engel | Sınıf | Büyüklük |
|---|---|---|---|
| **1** | **Kamera kabuğa hiç bağlı değil** — `lib/`'te tek `CameraController`/`motion_camera`/`startImageStream` çağrısı yok (yorumlar soyularak ölçüldü) | `kod` | **gün** |
| **2** | **Onboarding ekranı + ilk-açılış tetiği yok** — ⚠️ **metni HAZIR** (`disclaimers.onboarding`, yüzeyi bile beyanlı) | `kod` (içerik ✅) | **saat–gün** |
| **3** | **İkon Flutter varsayılanı** (`1 commit`) · **splash 68 bayt** · **store metadata yok** | `içerik` + `manuel` | **kurucu** |
| **4** | `PrivacyInfo.xcprivacy` yok — ⚠️ **zorunluluk koşulu ölçülmedi** · ASC kaydı **ölçülmedi** | **`ölçülmemiş`** | bilinmiyor |

### ⚠️ Zayıflatan
Progress kalıcı boş (①'e bağlı) · `BatterySummaryView` **erişilemez** (ölçüm
gelince ilk gereken yüzey) · 5 aile kurulmamış · IAP yok (**ücretsizse engel
değil — kurucu kararı**) · sürüm `0.1.0`

### ✅ Bu gece kapananlar
- **`NSCameraUsageDescription`** — `6e31923`; **cihazda doğrulandı**.
  *(Koordinatörün ölçümü build çıktısını okuyordu ve o build 11:36'daydı,
  anahtardan önce. Kaynak ağaçta ve `origin/main`'de hep vardı.)*
- **Poz modeli hattı** — `1c813ee`; 9 398 198 bayt, SHA pin'le birebir,
  hazırlama adımı **kamera gelmeden** kanıtlandı.
- **Commit kapısı** — `a9f0aa8` + `8d55267`; **dört şart tam**: kurulmuş ·
  **düşebildiği ölçüldü** · okunur · kapsamı yazılı. Sabotajın **indiği** de
  ayrıca doğrulandı (`assert` + `grep -c` + testin kırmızılığı → **sonra**
  commit denendi → durdu).

**Gezilebilir ekran: KATI 2 · GENİŞ 6** (02:00'de 2'ydi — o ölçüm dört sekme
mimarisinden 19 dk önce alınmıştı: yanlış değil, **bayat**).

---

## 🔴 AÇIK KALANLAR

| # | Kalem | Sınıf |
|---|---|---|
| 1 | **C-195 kamera yarışı — sende ÖLÇÜLMEDİ.** JabLab ve Choreia kapattı. Desen: **süreç-geneli static kilit** · `stop()` **bilerek async değil** · **2sn sınır** (kilitsiz = tipli `already-running`, kilitli = **sessiz donma**, ikincisi daha kötü) · `debugResetCameraLock`. ⚠️ Bende yarış **bugün oluşamaz** (kamerayı açan yol yok) ama **①'i çözen commit onu DOĞURUR** | `kod` |
| 2 | **`worldLandmarks` göçü (L-187)** — *onaylandı, ön koşullu*. Zincir: **rig tazeleme → `worldLandmarks` → `planar=false` → göç → bayrak ölçümü.** Kapsam **3 değil ALTI dosya**; `planar` **beş hattın paylaşımlı varsayılanı** | `kod` + **koordineli** |
| 3 | **Köprünün engelli metrikleri + Library/Progress içeriği** ⚠️ Choreia kuralı: *yazmadan önce, yazacağın şeyi **okuyan bir kod var mı**?* | `içerik` |
| 4 | **Kurucuda 3 ⛔:** ikon · splash · store metadata | `manuel/kurucu` |
| 5 | **Kör noktalar** (kapılanamaz, gerekçeleri yazılı): K2 jargon vekili · K3 *"geri sayım estetiği"* · K4 beyan-ölçüm uzay eşitliği | `ölçülemez` |

## ❓ YENİ OTURUM İLK ÜÇ SORU

1. **«Kamerayı bağlayan commit'i yazmadan önce static kilit yerinde mi?»**
   — yarış o commit'le **doğar**, sonra değil
2. **«Bu içeriği okuyan bir kod var mı?»** — yazmadan **önce** ölç
3. **«Bu cümle N=2'de hâlâ doğru mu?»** — ilerleme dili N'e bağlıdır

---

## Gecenin tek cümlesi

> **Lissom'un DÜRÜSTLÜK katmanı yayına hazır; ÖLÇÜM katmanı kullanıcıya hiç
> bağlanmadı.**

**En pahalı dersim kendi hakkımdaydı:** dört tur *"M-F-22 yasaklıyor"* dedim,
**kural sandım**, ölçünce **ölçüm eksikliği** çıktı. Sonra aynı hatayı **kendi
kapımı savunarak** tekrarladım (L-273). Ve bu raporun kendisi üçüncüsü oldu:
**kanalın varlığını ölçmeden varsaydım.**
