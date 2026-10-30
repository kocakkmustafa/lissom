# Güncel mağaza metni girişi · 30 Ekim 2026

Mağaza metninin kaynağı 14 mağaza dilindeki `listing*.json` dosyalarıdır:
EN [listing.json](listing.json), TR [listing.tr-TR.json](listing.tr-TR.json), diğer on iki dil
`listing.<locale>.json`.

**30 Ekim yeniden yazımı:**
- Dosyalar Yönetim brifine göre baştan yazılan metinle eşitlendi:
  `scratch/2026-10-30-magaza-metinleri/lissom/STORE-COPY.json`.
- Aynı klasörde iddia başına kanıt (`EVIDENCE.md`) ve eskimiş ifadelerin listesi (`README.tr.md`) var.
- Kaynak:
  - aday `f66a3fa` (1.0.0, build 5);
  - Motion Core R4.3 `5b15308`;
  - yulalab-web `4bb91af`.
- `$` önekli alanlar gerekçe notudur, mağazaya taşınmaz.
- Bu dosya mağaza paneline yazıldığı ya da fiziksel cihazda kabul edildiği anlamına gelmez. Yükleme yapılmadı; konsol girişi Yönetim'de.

## Alanlar

| Alan | en-US, tr-TR | Diğer 12 dil |
|---|---|---|
| `appStore.name` | App Store adı = Play başlığı | Play başlığı (K-7 yerel ad) |
| `appStore.subtitle` / `promotionalText` / `keywords` | 30 Ekim App Store metni | K-6 yerel taslağı. Bu sürümün App Store metni yalnız en-US + tr |
| `description` | **App Store** açıklaması: Apple 3.1.2 cümleleri + Şartlar (EULA) ve Gizlilik bağlantıları; Google adı geçmez | **Play** tam açıklaması |
| `playStore.title` / `shortDescription` / `fullDescription` | Play metni; Apple adı geçmez | Play metni |

Abonelik adları, açıklamaları, Play faydaları ve grup görünen adı (14 dil) yalnız
`STORE-COPY.json`'da: `subscriptions`, `subscriptionGroup`. Konsol dil kodları
(`es-419` → ASC `es-MX` vb.) aynı dosyada: `$ascLocale` / `$playLocale`.

## Metnin özü

**Kapsam:**
- Beş yazılı yoga kursu, toplam **120 ders**:
  - Hatha 60 / 10 modül;
  - Ashtanga başlangıç temelleri 19 / 5 modül (tam Primary Series değil);
  - destekli Yin 12;
  - destekli ayakta Vinyasa 14;
  - sandalye/ofis 15.
- Arayüz ve tüm dersler 14 dilde.
- Her dersin parçaları: hedef, uygulama, öz denetim, kolay yol, ne zaman durulacağı, öğretim kaynakları.
- İlerleme cihazdaki öz kayıttır. Poz puanı ya da ustalık iddiası yoktur.
- Kamera ile puanlama, düzeltme veya sayım yoktur. Gösterim videosu yoktur.
- Misafir kullanım var. Motion hesabı isteğe bağlıdır: 13+, ülkenin dijital rıza yaşının altında önce veli onayı. Hesap uygulamadan silinir.
- Tıbbi cihaz değildir.
- Kurs varlık kimlikleri ve hash'leri `$courseCatalogPreparationCurrent` alanında. `test/store_scope_preparation_test.dart` bunları paketteki baytlarla eşler.

**Satış (karar A, 2026-10-23; Core R4.3):**
- Abonelik açık: Lissom üyeliği + Motion+, aylık ve yıllık.
- Her kursun ilk kısmı ücretsiz, toplam **120 dersin 47'si**: Hatha 24/60, sandalye/ofis 6/15, Vinyasa 5/14, Yin 5/12, Ashtanga 7/19 (`lib/app/course_access.dart`; K-7).
- Motion+ tanımı Core R4.3 metniyle aynı anlamda: beş uygulamada bugün yayındaki ücretli dersler; kamera koçluğu ve yayımlanmamış dersler hariç.
  - 13 dilde Core metni olduğu gibi.
  - EN'de "not yet released" yerine "unreleased" kullanıldı; vaat kapısı "yet" kelimesini reddediyor.
- 14 gün ücretsiz deneme. Motion+ denemesi her Motion hesabı için bir kez.
- Metinde sabit fiyat yok; fiyatı mağaza gösterir.
- Hesap silmek mağaza aboneliğini iptal etmez.

## Alan ölçümü (14 dil)

Karakter sayısı Unicode kod noktası, anahtar kelimeler UTF-8 bayttır.

| Dil | Dosya | Ad / Play başlığı | Subtitle | Promo | Keywords | AS açıklama | Play kısa | Play tam |
|---|---|---|---|---|---|---|---|---|
| en-US | [listing.json](listing.json) | Lissom: Yoga & Mobility | 29 | 147 | 97 B | 2791 | 73 | 2550 |
| tr-TR | [listing.tr-TR.json](listing.tr-TR.json) | Lissom: Yoga ve Mobilite | 29 | 123 | 96 B | 2645 | 64 | 2429 |
| es-419 | [listing.es-419.json](listing.es-419.json) | Lissom: Yoga y movilidad | — | — | — | — | 77 | 2908 |
| pt-BR | [listing.pt-BR.json](listing.pt-BR.json) | Lissom: Yoga e mobilidade | — | — | — | — | 72 | 2720 |
| de | [listing.de.json](listing.de.json) | Lissom: Yoga & Mobilität | — | — | — | — | 76 | 2972 |
| fr | [listing.fr.json](listing.fr.json) | Lissom: Yoga et mobilité | — | — | — | — | 76 | 2971 |
| ja | [listing.ja.json](listing.ja.json) | Lissom: ヨガとモビリティ | — | — | — | — | 32 | 1292 |
| ar | [listing.ar.json](listing.ar.json) | Lissom: يوغا ومرونة الحركة | — | — | — | — | 64 | 2149 |
| it | [listing.it.json](listing.it.json) | Lissom: Yoga e mobilità | — | — | — | — | 71 | 2821 |
| ko | [listing.ko.json](listing.ko.json) | Lissom: 요가 & 모빌리티 | — | — | — | — | 40 | 1450 |
| id | [listing.id.json](listing.id.json) | Lissom: Yoga dan Mobilitas | — | — | — | — | 69 | 2745 |
| pl | [listing.pl.json](listing.pl.json) | Lissom: Joga i mobilność | — | — | — | — | 73 | 2737 |
| hi | [listing.hi.json](listing.hi.json) | Lissom: योग और गतिशीलता | — | — | — | — | 72 | 2390 |
| zh-Hans | [listing.zh-Hans.json](listing.zh-Hans.json) | Lissom：瑜伽与灵活性 | — | — | — | — | 29 | 1024 |
| **Sınır** | | 30 | 30 | 170 | 100 B | 4000 | 80 | 4000 |

## Ortak alanlar

- Support URL: `https://yulalab.com/support`.
- Privacy URL: `https://yulalab.com/privacy/motion`.
- Açıklamadaki bağlantılar her dilde kendi site yolunu taşır: `https://yulalab.com/<dil>/terms`, `…/<dil>/privacy/motion`. TR kökte.
- ASC License Agreement: **Apple standart EULA** (K-7). Şartlar sayfası onu tamamlar.
- Play hesap silme URL'si: `https://yulalab.com/en/delete-account/motion`.
- 2026-10-30 anonim GET: bu bağlantıların hepsi 200.

## Kapılar

`test/store_listing_test.dart`:
- **EN/TR:** uzunluk ve varlık; K-7 adı; TR satış ve hesap cümleleri.
- **EN/TR yasaklar:** hareket testi kataloğu ve "Kamera değerlendirmeleri" ifadesi geri dönmesin.
- **3.1.2:** Şartlar (EULA) ve Gizlilik bağlantıları; App Store metninde Google, Play metninde Apple adı yok; Play başlığı App Store adına eşit.
- **Dil kalıpları:** vaat dili; cihaz kanıtı iddiası.
- **On iki yerel dosya:** aynı sınırlar, anahtar kelime baytı, sayı tutarlılığı, `Motion+`, ortak URL'ler.

Yerel metinlerin ana dil, hukuk ve mağaza incelemesi **UNRUN**.

## Kurucu kararları

| Alan | Karar | Repoda |
|---|---|---|
| Mağaza adı | **`Lissom: Yoga & Mobility`** (eski `Lissom: Movement Checks` / `Lissom: Hareket Testleri`); her dilde yerel karşılığı, `Lissom` markası korunur. App Store adı = Play başlığı (30 Eki brifi) | `listing*.json` `appStore.name`, `playStore.title` |
| Ücretsiz ders sayıları | uygulamadaki sayılar, **47/120** (K-7) | açıklamalar; `subscriptions-draft.json` |
| Yaş derecesi | 13+ ile uyumlu; Made for Kids **hayır**; Play hedef kitle 13–15 / 16–17 / 18+ | `release-review.json` `ageRating` |
| Ülkeler | **tüm ülkeler** | `release-review.json` `availability` |
| Lisans sözleşmesi | **Apple standart EULA** + `https://yulalab.com/terms` | `release-review.json` `privacy.licenseAgreement` |
| Mağaza dilleri | **14 dil** (K-6) | `listing.<locale>.json` |
| 13–17 satın alma | **mağaza aile denetimleri** (K-2) | `lib/app/lissom_release_policy.dart` |
| Kategori / sağlık beyanı | Health & Fitness; tıbbi cihaz değil, genel bilgi | — |

## Konsol adımları (Yönetim; bu repo konsola yazmaz)

1. **ASC → Lissom (6794715023):**
   - App Information → Name/Subtitle (en-US, tr).
   - 1.0.0 sürüm sayfası → Description / Promotional Text / Keywords.
   - Subscriptions → ürün adları ve açıklamaları, grup görünen adı (`STORE-COPY.json`).
   - License Agreement → Apple standart EULA.
2. **Play Console → Lissom:**
   - Store listing: 14 dil; başlık + kısa + tam açıklama.
   - Monetize → Subscriptions → `lissom_individual`, `lissom_motion_plus` adları ve faydaları.
3. **Kanıt:** her adım için ekran görüntüsü veya readback. Sonuç bu dosyalara geri yazılır.

## Ne yazılmadı (bilerek)

- Sabit fiyat, tarih, "yakında", gelecek özellik.
- Kamera ölçümü, poz puanı, koçluk veya kişisel program vaadi.
- Hareket testi kataloğu (Overhead Reach vb.). Kapalı ölçüm özelliğine bağlı.
- Cihazda kanıtlanmış bir cümle; yerel metinlerin incelendiği iddiası.
