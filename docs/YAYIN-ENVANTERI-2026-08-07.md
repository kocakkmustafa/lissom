# Yayın envanteri — Lissom, 2026-08-07

**Yöntem (JabLab aktarımı, iki biçim kuralı):**

1. Soru **kullanıcı tarafından** soruldu: *"bir kullanıcı bugün bu uygulamayı
   açsa, hangi yüzey onu YANLIŞ bilgilendirir?"* — *"ne eksik"* diye
   sorulsaydı bu bulguların hiçbiri çıkmazdı, çünkü hepsi **eksik değil
   FAZLA**: var olmayan bir mekanizmayı anlatıyorlar.
2. **Kanıt sütunu zorunlu** — *"nasıl biliyorum"*. Kanıtsız satır envantere
   girmez.

**Kapsam:** `lib/app/*.dart` içindeki 171 kullanıcı-görünür cümle parçası
(yorumlar hariç, string sabitleri) + yüzeye giden config metinleri.

---

## 🔴 BULGU — tek bir örüntü, yedi yüzey

> **Uygulamanın tamamı, çalışan bir ölçüm döngüsünün ŞİMDİKİ ZAMANIYLA
> konuşuyor. Oysa kullanıcı hiçbir ölçüm yapamıyor.**

Kamera turu hiçbir ekrana bağlı değil: `lib/app/` altında capture widget'ı
YOK, `motion_camera` bağımlılığı duruyor ama çağıran yok, `live_evaluator` ve
`live_session_state` motor katmanında kalıyor. Bu gerçeği **yalnızca Home'un
tepesindeki beyan** söylüyor. Library'den ya da Progress'ten başlayan bir
kullanıcı onu hiç görmüyor.

**Yokluk sessiz değil — konuşkan.**

| # | Yüzey | Cümle | Kullanıcı ne anlar | Gerçek | Kanıt |
|---|---|---|---|---|---|
| 1 | Home · retest kartı | *"Measure when you are ready"* | "hazır olduğumda ölçebilirim" | **Ölçemez.** Başlatacak bir yol yok | `lib/app/` altında capture ekranı yok; `shell.dart` dört sekmenin hiçbirinden capture'a gitmiyor |
| 2 | Library · alt başlık | *"What Lissom can actually do on your phone today."* | "aşağıdakiler telefonumda çalışıyor" | Batarya **telefonda çalıştırılamıyor** | Aynı; ayrıca Home beyanıyla DOĞRUDAN çelişiyor |
| 3 | Home · quick start | *"3 of 12 tests can be measured by camera"* | "bu üçünü kamerayla ölçebilirim" | Motor hesaplayabilir; **kullanıcı ölçemez** | `deriveLiveness` `kMetricBindings`ten türer — MOTOR yeteneği, capture yolu değil |
| 4 | Aile sayfası | *"Measured by camera in this build (3)"* | aynı | aynı | aynı |
| 5 | Profile · gizlilik | *"Your camera images and your readings stay on this phone."* | "kamera görüntülerim var ve burada duruyor" | **Kamera görüntüsü hiç yok** | Uygulama kamerayı hiç açmıyor |
| 6 | Progress · boş hâl | *"Once a session is measured, every reading it produced is listed here"* | "bir oturum ölçersem burada görürüm" | Oturum ölçülemez | Aynı |
| 7 | Ölçüm-sınırı beyanı | *"Lissom tells you when a reading was not reliable enough to score"* | "okumalar oluyor ve bana söyleniyor" | Okuma olmuyor | `disclaimers.measurementLimits`, config metni |

### En pahalı olan: **5 numara**

*"Your camera images and your readings stay on this phone"* — **sonucu
DOĞRU, gerekçesi YANLIŞ.** Gizlilik iddiası gerçekten sağlam (hesap yok,
sunucu yok, gönderilecek yer yok), ama dayandığı mekanizma — kamera
görüntüleri ve okumalar — **hiç yok.**

Doğru sonucu yanlış gerekçeyle söylemek en zor yakalanan hatadır: kimse
sonucu sorgulamaz, çünkü sonuç doğrudur. Ve gerekçe bir gün yanlış tarafa
döndüğünde (kamera bağlandığında ve bir yere gönderildiğinde) cümle aynen
kalır, yalnız artık yalan olur.

---

## ✅ Envanterden GEÇEN — yanlış bilgilendirmeyenler

| Yüzey | Neden temiz |
|---|---|
| Home beyan kartı | Boşluğu ADIYLA söylüyor: *"The camera run is not wired to a screen in this build"* |
| `today` bölümü | *"The part of Lissom that builds it is not in this build"* — mekanizmanın yokluğu isimli |
| Engelli test gerekçeleri | Her biri NEDEN'i söylüyor, ve neden motor yeteneğine dayanıyor (L-220) |
| Progress kıyas beyanı | Kıyasın neden yapılmadığını üç koşulla anlatıyor; **olmayan bir kıyası ima etmiyor** |
| Dürüstlük kutusu | Canlı olmayan iddia sönük + isimli gerekçeli (L-230) |
| *"What Lissom doesn't do"* | Sınırlar + ölçülmüş dışlamalar + poz katmanları, hepsi gerekçeli |

---

## Düzeltme ilkesi

Boşluğu **yedi yerde yeniden anlatmak** değil — aynı hatayı yeni bir ikiz
üretmekle kapatmak olurdu. Tek bir paylaşılan beyan (`CaptureUnavailableNote`)
ve onu **ölçüm ima eden her yüzeye** bağlamak; metin bir kez yazılır, dört
yerde gösterilir.

Davet dili de düzeltilir: **yapılamayan bir eyleme davet edilmez.**
