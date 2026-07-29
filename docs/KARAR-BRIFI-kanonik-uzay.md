# KARAR BRİFİ — Kanonik ölçüm uzayı (L-117 / L-118)

**Karar sahibi:** koordinatör · **Tarih:** 2026-07-29 · **Etki:** 5 app, tüm düzlem-projeksiyonlu metrikler

## Sorun (1 satır)

`geo.project(v, "sagittal")` **sabit dünya eksenini** sıfırlıyor (`x=0`) ve x'in vücudun medial-lateral ekseni olduğunu **varsayıyor** — bu varsayım yalnız kişi kameraya dönükken doğru; oysa Lissom'un 12 testinden 8'i kullanıcıya *"stand side-on to the camera"* diyor.

## Kanıt (ölçülmüş, sentetik yaw taraması)

| omuz kısalması | duruş | `trunk_lean` sapması |
|---|---|---|
| 0,80 | kameraya dönük | **0,0°** |
| 0,61 | | 7,0° |
| 0,40 | yandan | **19,1°** |

Talimat, ölçümün en kötü çalıştığı duruşu istiyor. Bu L-031'in (Dart görüntü-düzlemi ↔ Python 3D-world) somut tezahürü: **iki uzayda doğru cevap birbirinin tersi.**

## Seçenekler

| | ne yapılır | bedel |
|---|---|---|
| **A** | Projeksiyon kalır; talimatlar *"face the camera"*a çevrilir | Ölçüm MediaPipe'ın **en gürültülü ekseni olan derinliğe** bağlanır; 8 testin metni + çekim rehberi değişir |
| **B** | Talimatlar kalır; projeksiyon görüntü düzlemine çevrilir | Dart tarafıyla hizalanır ama 3D bilgisi atılır; perspektif hatası kalıcılaşır |
| **C** ⭐ | **Düzlemler landmark'tan TÜRETİLİR** (kalça+omuz hattı → medial-lateral eksen; dikey → sagittal normal) | `geo.project` semantiği değişir; G1-a A1-A11 ve kalibre eşikler yeniden doğrulanır |

## Önerim: C

Kamera yönelimine **bağımsız** hale getirir — kullanıcı ister yandan ister önden dursun ölçüm aynı kalır, yani talimat metni bir ölçüm parametresi olmaktan çıkar. A ve B'de "doğru duruş" bir varsayım olarak koda gömülü kalır ve her yeni app aynı tuzağa düşer. C ayrıca `view-unsuitable` etiketinin eşiğini anlamlı kılar: uygunluk artık "hangi yöne dönük" değil, "iki kalça ve iki omuz güvenle görünüyor mu" sorusuna iner.

**Fizibilite doğrulandı:** LEFT/RIGHT_HIP ve LEFT/RIGHT_SHOULDER zaten var; medial-lateral eksen bu iki hattın ortalaması, sagittal normal ise onun dikeyle çapraz çarpımı. Ek landmark GEREKMEZ.

## Bloke ettiği işler

`view-unsuitable` türeticisi (eşiğin **yönü** karara bağlı) · 8 testin talimat metni · sagittal metriklerin kaynak-uygunluk kapısı · L-031'in kapanışı (Dart↔Python differential testing).
