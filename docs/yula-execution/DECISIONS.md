# Lissom — karar günlüğü (ADR biçimi)

**Bilet:** LIS-P1-01 · Eski kararlar `docs/ADR/001`–`006`'dadır (2026-07, mimari). Bu dosya 2026-10-31 sonrası ürün ve süreç kararlarını tutar. Biçim: Tarih · Statü · Bağlam · Karar · Sonuç. Kurucu sözü yalnız kayıtlı kaynakta geçtiği gibi tırnaklanır; kaynak yazılıdır.

## ADR-L001 — Kamera koçluğu denemesi: ilk kapsam ve tek bayrak
**Tarih:** 2026-11-04 · **Statü:** kabul (kurucu) · **Kaynak:** `docs/camera/KAPSAM.tr.md`
- **Bağlam:** Lissom'a kamera koçluğu eklenecek mi, nasıl?
- **Karar:** Kurucu "Lissom, önerilerle" (2026-11-04) ile sıradaki Motion uygulamasını seçti. İlk kamera kapsamı (ayakta ve sandalye duruşları, en az 20 duruş, yandan ölçülebilenler; yer duruşları ve Vinyasa sonra) bu kararla birlikte raporun varsayılanlarıyla kabul edilen alt karardır (vault: "Karar — Sıradaki Uygulama Lissom (2026-11-04)"). Özellik "deneme" etiketli, tek bayrak (`LISSOM_CAMERA_TRIAL`) arkasında, varsayılan kapalı.
- **Sonuç:** 20 duruş (15 ayakta + 5 sandalye), 27 ders. Bayrağı mağaza sürümünde açmak ayrı kurucu kararıdır (F3).

## ADR-L002 — M2: yer duruşları kapsama alındı
**Tarih:** 2026-11-05 · **Statü:** kabul (kurucu) · **Kaynak:** `docs/camera/KAPSAM.tr.md` "M2 yer duruşları"
- **Bağlam:** M1 yer duruşlarını "sonraki sürüm"e bırakmıştı.
- **Karar:** Kurucu "Evet, M1'den sonra" (2026-11-05): yer duruşları bu sürüme alındı.
- **Sonuç:** +15 duruş, +33 ders (katalog toplamı 35 duruş, 60 ders). Akış (Vinyasa, Güneşe Selam) M3'e kaldı (F4). `KAPSAM.tr.md` M1 satırı bu karardan sonra eskimişti; LIS-P1-01'de düzeltildi.

## ADR-L003 — iPhone kamera smoke ertelendi
**Tarih:** 2026-11-05 · **Statü:** kabul (kurucu) · **Kaynak:** Motion oturum devri 2026-11-06 (Lissom)
- **Karar:** Kurucu "kamera testi beklesin" (2026-11-05). Bayrak kapalı kalır.
- **Sonuç:** Cihazda kamera izni, texture, kare hızı ve MediaPipe çıkarım süresi ölçülmedi (`CIHAZ-SMOKE.tr.md`). Mühendislik sonucu (kurucu kararı değil): cihazsız kanıt `TEST_ONLY` etiketlenir; kameranın veri sınırı testleri bu etiketle planlandı (Backlog LIS-P1-02).

## ADR-L004 — Başlangıç yolu Hatha'nın seçimidir, ayrı kurs değildir
**Tarih:** 2026-11-06 · **Statü:** kabul (kurucu) · **Kaynak:** lissom#21 → `87deb09`
- **Bağlam:** Yeni kullanıcıya kısa bir giriş yolu isteniyor; ilk seçim kuralı ("her modülden ilk ders") Hatha önkoşul zincirinde 10 dersin 9'unu kilitli bırakıyordu.
- **Karar:** Kurucu "Evet, yol olsun" (2026-11-06): yeni ders yazılmaz. Yol Hatha'nın ardışık başlangıcı h01–h10 (arrival h01–h06 + standing h07–h10). Yol, tam Hatha kursunu daraltan bir görünümdür.
- **Sonuç:** İlerleme kaydı, önkoşul ve erişim Hatha'nınki; yeni kapı ya da kayıt yok; bitince h11'e yönlendirir. Türetilmiş/küçültülmüş kurs yasak (ilerleme kurs id/sürümüne ve `freeLessonCount` ders sayısına bağlı).

## ADR-L005 — Yeniden gönderim Ostinato yayınlanana kadar bekler
**Tarih:** 2026-11-06 · **Statü:** kabul (kurucu) · **Kaynak:** Motion oturum devri 2026-11-06 (Lissom)
- **Bağlam:** 31 Ekim'de beş Motion uygulaması 4.3(a) Spam reddi aldı; kurucu 2026-11-06: "5 motionu aynı anda gönderdiğimiz için spam sayıldı".
- **Karar:** Kurucu "Evet, beklesin" (2026-11-06): Lissom yeniden gönderimi Ostinato onaylanıp yayınlanana kadar bekler; mağazaya hiçbir şey gönderilmez.
- **Sonuç:** Lissom 1.0.0 (build 5) REJECTED durumunda bekler (F7).

## ADR-L006 — Android kamera `uses-feature` isteğe bağlı
**Tarih:** 2026-11-06 · **Statü:** kabul (mühendislik; kurucu kararı gerekmez, kapsam: manifest +2 satır) · **Kaynak:** lissom#20 → `a731513`
- **Karar:** `android.hardware.camera` `required=false`: kamerasız cihazlar da uygulamayı kurabilir; kamera yolu zaten bayrak arkasında.
- **Sonuç:** Mağaza uyumluluk listesi daralmaz.
