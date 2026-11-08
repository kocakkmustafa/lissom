# Lissom kamera koçluğu — kapsam (Aşama 0)

Kurucu kararı 2026-11-04 ("Lissom, önerilerle"): ilk kamera kapsamı ayakta ve sandalye duruşları, en az 20 duruş, yandan ölçülebilenler (M1). Yer duruşları o gün "sonraki sürüm"di; kurucu 2026-11-05'te bunları **M2** olarak kapsama aldı (aşağıda "M2 yer duruşları"). Vinyasa akışları (M3) sonraki sürümde kalır.

**Katalog:** `config/yoga/camera-poses.v1.json` — toplam 35 duruş, 60 ders: M1 20 duruş (15 ayakta, 5 sandalye; 4 kurstan 27 ders) + M2 15 yer duruşu (33 ders). Ayrıntılı sayılar `MODEL-KARTI.tr.md`. Aşağıdaki "Kamerada olan dersler" ve "Kamerada olmayanlar" bölümleri **M1** tablosudur; M2 bölümü onları tamamlar.

## Seçim ölçütü
1. Ayakta ya da sandalyede.
2. Duruşu tanımlayan açılar **sagital düzlemde** (yandan bakan telefon görür): gövde eğimi, kalça ve diz bükümü, kol kaldırma, baş-boyun hizası, ayak yüksekliği, adım.
3. Dersin metni hedef bir biçim tarif ediyor (sabit duruş ya da tutuş), yalnız bilgi ya da plan değil.

## Kamerada olan dersler (27)
- **Hatha:** h03 dağ, h10 duvarla ağaç, h11 sandalyeye öne eğilme, h12 ayakta dizi (dağ, öne eğilme, ağaç), h21 sandalyede oturuş, h44 kısa adımlı Savaşçı I, h50 destekli menteşe dengesi, h53 küçük geriye uzanma (+ dağ), h57 yön değiştiren ayakta dizi (Savaşçı I).
- **Ashtanga:** a03 ayakta başlangıç (dağ), a04 kollar yukarı, a05 sığ eğilme ve yarım kalkış, a06 küçük Utkatasana, a09 Güneşe Selam A ayakta öğeleri, a11 ayakta Güneşe Selam B uyarlaması (küçük sandalye), a15 kaval kemiğine destekli öne eğilme, a18 geniş bacakla sandalyeye eğilme.
- **Vinyasa:** v02 dağ + kol, v03 duvarda yarım menteşe, v04 duvarda köpek hazırlığı, v05 kademeli duruş, v06 seçilen yolu bağlama.
- **Sandalye/ofis:** c01 sandalye kurulumu, c04 dik oturuş + küçük kol yayı, c06 ayak kaldırma, c07 istasyonlu kısa çalışma, c14 omurgayı yuvarlama/uzatma.

## Kamerada olmayanlar ve nedeni
| Ders / grup | Neden |
|---|---|
| h45 Savaşçı II, h09 ve a16 üçgen, a17 yan açı | Duruşu tanımlayan açı önden (frontal düzlem); yandan bacaklar üst üste biner. Önden doğruluk ~0,80 (E06/E08). |
| c13 oturarak yana uzanma, c05/h22 oturarak dönüş | Yana eğilme ve dönme yandan görünmez. |
| h13–h20, h25–h30, h37–h40, h43, h46–h48, h51, h52, h54–h56, Yin dersleri, v11–v14 | Yer duruşları (diz üstü, oturuş, sırtüstü, yüzüstü): **M1'de yoktu** (kurucu kararıyla sonraki sürüm). 2026-11-05'te M2 olarak alındı: bu gruptan kamerada olan dersler aşağıdaki "M2 yer duruşları" listesindedir; o listede olmayanlar kamerada hâlâ yoktur. |
| h34, h35, h49, h58, a08, a10, a07 | Akış ve geçişler (DTW gerekir): sonraki sürüm. |
| h01, h02, h31–h33, h36, h41, h42, h59, h60, a01, a02, a12–a14, a19, v01, v07–v10, c02, c03, c08–c12, c15 | Bilgi, nefes, plan ya da tekrar dersleri; değerlendirilecek sabit duruş yok. |

Kamera açıkken bu derslerde dürüst not gösterilir: "Bu dersi kamera değerlendirmiyor."

## M2 yer duruşları (kurucu 2026-11-05)
Yer duruşları bu sürüme alındı ("Evet, M1'den sonra"): 15 duruş, 33 ders.
- **Hatha:** h04, h13, h14, h15, h16, h17, h19, h20, h22, h23, h25, h26, h27, h29, h37, h38, h39, h40, h43, h46, h47, h48, h51, h52.
- **Vinyasa:** v11, v12, v13.
- **Yin:** y03, y04, y09, y10, y11, y12.

Akış (Vinyasa, Güneşe Selam) sonraki sürümde. Bel, sırt ve masa başı için yeni kurs açılmıyor. Kamerada hâlâ olmayanlar şunlar: dönüşler (y05 sırtüstü burgu), duvarda bacaklar (h28), yarım saban (h54), lotus ve balık bilgi dersleri.

## Kurucu kararı bekleyen kapsam maddesi
Bağımsız sınamada (E15) dört duruş gerçek kabul eşiğinin altında kaldı: dağ, yarım kalkış, küçük sandalye, kısa Savaşçı I. Seçenekler: (a) "deneme" içinde kalsınlar (varsayılan, bu PR), (b) kapsamdan çıksınlar (16 duruş, ≥20 hedefinin altı), (c) aralıklar aileye göre genişletilip yeni bağımsız veriyle (ör. UI-PRMD) yeniden sınansın.
