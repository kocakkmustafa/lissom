# Güncel native simge — 2026-10-16

Yeni onay: **v17-vivid-jade**. Güncel master, platform envanteri,
boyutlar ve hashler [onaylı simge kaydında](../../design/icon/approved-2026-10-16/README.md).
15 iOS AppIcon ve 5 Android launcher PNG güncellendi. Aşağıdaki adaylar ve
mağaza dosyaları tarihsel kayıttır; yeni onaylı simgeyle mağaza görsellerinin
hazır olduğu anlamına gelmez. Native kurulum ve mağaza yüklemesi yapılmadı.

---

# Lissom mağaza simgesi adayı — 2026-09-24

Kurucu, pastel mat zemin üzerindeki yoga matında **ağaç pozu** yapan yüzü ayrıntısız figürün son çizimini seçti. Seçilen kaynak `tree-pose-yoga-selected-reference-1254.png` dosyasıdır (SHA-256: `a113af9d54224ba80258754eb1283281cf717d4e57e6dc41913e1176ad3667e9`).

| Dosya | Kullanım |
|---|---|
| `tree-pose-yoga-selected-reference-1254.png` | Seçilen, opak RGB kaynak görsel (1254 × 1254) |
| `tree-pose-yoga-rounded-preview-1254.png` | Dört dış köşesi yaklaşık %9 yumuşatılmış, saydam köşeli önizleme |
| `tree-pose-yoga-App-Store-1024.png` | Kare ve opak 1024 × 1024 mağaza ve native ikon ortak kaynağı |
| `tree-pose-yoga-Google-Play-512.png` | Kare ve opak 512 × 512 mağaza adayı |

Yuvarlatılmış önizleme, seçilen kaynak görsele yalnız alfa maskesi uygulanarak üretildi. Alfa kapatılarak yapılan piksel karşılaştırmasında kaynakla fark **0** çıktı. Kare/opak mağaza adayları aynı kaynaktan küçültüldü.

## 2026-09-26 — native ikon kaynağı eşitlendi

Mevcut native ikon da seçilmiş 1254 px çizimden üretilmişti: eski iOS 1024 ikonunun, bu kaynağın LANCZOS küçültmesiyle RGB piksel farkı **0** olarak doğrulandı. Mağaza 1024 dosyasıyla görülen fark yeniden örnekleme yönteminden kaynaklanıyordu; farklı veya yeni bir çizim seçilmedi.

`tree-pose-yoga-App-Store-1024.png` artık mevcut **15 iOS AppIcon PNG** ve **5 Android mipmap/ic_launcher PNG** için ortak kaynaktır. iOS 1024 dosyası kaynakla byte ve RGB piksel düzeyinde aynıdır; diğer boyutlar bu 1024 dosyasından LANCZOS ile türetildi. Tüm ikonlar kare, RGB ve opaktır. `tools/uret_ikon_launch.py` kaynak/boyut konfigürasyonu aynı 1024 dosyasına güncellendi; bu aktarımda generator'ın launch döngüsü çalıştırılmadı ve LaunchImage dosyaları değişmedi.

Eski 20 ikon, bu README ve generator görev kapsamındaki exact yedekte korunuyor. Boyut, PNG biçimi, piksel, opaklık ve SHA256 makbuzu: workspace kökünde `scratch/2026-09-26-motion-device-release/lissom-icon-source-receipt.json`; yedek: aynı dizinde `lissom-icon-source-backup/`.

Bu kayıt native kaynak entegrasyonunu doğrular. Bu işlemde build, cihaz kurulumu veya mağaza konsoluna upload yapılmadı.

## 2026-10-15 — Google Play dosya biçimi

Güncel `tree-pose-yoga-Google-Play-512.png` dosyası, [Google Play ikon şartına](https://developer.android.com/distribute/google-play/resources/icon-design-specifications) uygun 512 × 512, 32-bit RGBA PNG olarak dışa aktarıldı; sRGB etiketi taşır. Önceki RGB pikselleri birebir korundu (fark 0); alfa kanalı her pikselde 255, görünüm opaktır. Kaynak çizim, App Store adayı ve native ikonlar değişmedi. Bu yerel dosya doğrulamasıdır; mağazaya yükleme kabulü değildir.
