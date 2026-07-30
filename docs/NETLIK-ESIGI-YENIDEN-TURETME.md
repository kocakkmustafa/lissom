# Netlik eşiği (40) — ölçümle yeniden türetme

**Tetik:** `lr3_bA48EBM` netlik **37,8** ile reddedildi; eşik 40. Koordinatör
hükmü (M-F-173): *"ne 40'ı bökerim ne 37,8'i reddederim — ÖLÇÜME ÇEVİR."*
Sınır-vakası, eşiğin temelini türetme tetiğidir.

**Tarih:** 2026-07-30 · **Tur SHA:** `f34acd8` (izole worktree, M-F-139) ·
**Model:** pinli `pose_landmarker_full.v1.task`

---

## 1. Yöntem

Eşik neyi korumak için var? **Kullanılabilir landmark.** O hâlde sorulacak
soru: *netlik, landmark kalitesini öngörüyor mu?*

- Sınır-vaka klibi **KARANTİNADA** çıkarıldı (`scratchpad/quarantine/`,
  kütüphaneye GİRMEDİ, hiçbir havuza dokunmadı — kapı gevşemedi).
- Landmark kalitesi 4 ölçüyle: **tespit oranı** · **görünürlük ortalaması**
  (12 gövde landmark'ı) · **görünürlük p10** (kötü kuyruk) · **kare-arası
  jitter** (saniye-normalize, M-O-23 birim kuralı).
- Kıyas kümesi: kabul edilmiş, landmark'ı VE netlik ölçümü olan **29 kaynak**.

## 2. Sınır-vaka: kabul edilmişlerden AYIRT EDİLEMEZ

| ölçü | karantina (37,8) | kabul-aralığı | hüküm |
|---|---|---|---|
| tespit oranı | 0,967 | 0,795 – 0,991 | **içinde** |
| görünürlük ort. | 0,862 | 0,566 – 0,957 | **içinde** (2./6) |
| görünürlük p10 | 0,770 | 0,269 – 0,910 | **içinde** (2./6) |
| kadraj-içi oran | 0,990 | 0,125 – 0,999 | **içinde** (2./6) |
| jitter/sn | 0,0290 | 0,0201 – 0,1269 | **içinde** (2./6, düşük=iyi) |

Beş ölçünün beşinde aralık içinde; dördünde **medyanın üstünde**. Yani
reddedilen klip, kabul edilenlerin çoğundan DAHA İYİ landmark üretiyor.

## 3. Asıl bulgu: netlik landmark kalitesini ÖNGÖRMÜYOR (n=29)

| ilişki | Pearson r | beklenen | gözlenen |
|---|---|---|---|
| netlik ↔ tespit oranı | **+0,179** | güçlü + | ihmal edilebilir |
| netlik ↔ görünürlük ort. | **+0,007** | güçlü + | **sıfır** |
| netlik ↔ jitter | **+0,213** | **negatif** (net video = az jitter) | **TERS İŞARET** |

Kabul edilmiş havuzun netlik aralığı **41,9 – 1268,9** (30× yayılım) ve bu
yayılım boyunca landmark kalitesi netlikle ilişkili DEĞİL. Jitter ilişkisinin
işareti eşiğin öncülünün tersi.

**Çarpıcı uçlar:** en DÜŞÜK netlikli iki kabul (`HhApHbLgxMA` 41,9 ·
`YG-iGrQvw44` 53,7) en İYİ görünürlüklerden (0,921 · 0,938) ve en düşük
jitter'lardan (0,0089 · 0,0254) — en YÜKSEK netlikli kaynak
(`SfxyICleU4I` 1268,9) ise havuzun en yüksek jitter'ına (0,1165) sahip.

## 4. Hüküm önerisi (karar koordinatörde — M-F-77)

**Eşik 40'ın landmark-kalitesi temelinde ÖLÇÜLMÜŞ dayanağı YOK.** Koruduğu
iddia edilen büyüklükle ilişkisi ölçülemedi (r ≈ 0,00–0,21, biri ters
işaretli). Öneri:

1. `lr3_bA48EBM`'in netlik-reddi **kaldırılabilir** — ayırt edilemezliği
   ölçülü. (Ayrı soru: klibin hangi harekete ait olduğu kuyrukta belirsiz
   `?`; havuza girmesi için önce hareket-kimliği belirlenmeli.)
2. **Eşik yeniden türetilmeli:** ya landmark kalitesiyle ölçülmüş bir
   ilişkiye dayandırılsın, ya da netlik bir KAPI olmaktan çıkıp raporlanan
   bir bilgi alanına dönüşsün (kapı olmayan ölçü, "ölçtük ama karar
   vermiyoruz" biçiminde dürüsttür).
3. L-141'in sınır-vakası (38 < 40) aynı dosyaya girer.

## 5. Bu ölçümün SINIRI — aşırı genelleme yapmıyorum

⚠️ **Aralık kısıtlaması (range restriction).** Ölçüm yalnız **41,9 üstü**
netliklerde yapıldı, çünkü altındakiler zaten reddedilmiş ve hiç
çıkarılmamıştı. Dolayısıyla bu veri şunu **söylemiyor**: "netlik hiç önemli
değil." Söylediği: *bu aralıkta* netlik varyasyonu landmark kalitesini
öngörmüyor.

Bu yüzden **`ghL3AJfRT6k` (netlik 14) hakkında hüküm YOK** — 14, ölçülen
aralığın çok altında ve onun için kanıtım yok. Reddi "kanıtsız", "yanlış"
değil. Eşiğin gerçek yeri ancak alt uçtan örnek eklenirse bilinir; bu, en
düşük netlikli 2-3 reddi karantinada çıkarıp aynı kıyası koşmakla ölçülür
(ucuz, ve kapı gevşemeden yapılabilir).

**Karantina disiplini:** çıkarılan klip `scratchpad/quarantine/` altında
kaldı; kütüphaneye, kuyruğa ya da herhangi bir referans havuzuna GİRMEDİ.
Eşik hâlâ yerinde — yalnız dayanağı artık ölçülmüş durumda.
