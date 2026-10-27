# Güncel mağaza metni girişi · 27 Ekim 2026

Yayıma hazırlanacak metinlerin kaynağı 14 mağaza dilindeki `listing*.json` dosyalarıdır
(EN [listing.json](listing.json), TR [listing.tr-TR.json](listing.tr-TR.json), diğer on iki dil
`listing.<locale>.json`; K-6, 2026-10-27). Bu dosyalarda `$` önekli
alanlar gerekçe notudur ve mağazaya taşınmaz. Motion Core R4 `0d29d1b` pin, sürüm 1.0.0 (build 4);
kurucu kararları K-2, K-6, K-7 (2026-10-27) işlendi. Bu dosya mağaza paneline yazıldığı, güncel
imzalı pakette bulunduğu ya da fiziksel cihazda kabul edildiği anlamına gelmez.
Bu bakımda mağazaya hiçbir şey yazılmadı ve yükleme yapılmadı.

**Kapsam:** beş yazılı yoga kataloğu, toplam **120 ders**: Hatha 60 / 10 modül,
Ashtanga başlangıç temelleri 19 / 5 modül (tam Primary Series değil), destekli Yin 12,
destekli ayakta Vinyasa 14 (isteğe bağlı dizler yerde zemin uzantısı) ve sandalye/ofis 15.
Arayüz ve dersler 14 dilde. İlerleme kişinin cihazdaki öz kaydıdır; ustalık, poz puanı
ya da tıbbi uygunluk iddiası yoktur. Gösterim videosu yoktur. Kamera değerlendirmesi
kapalıdır. Kurs varlık kimlikleri ve hash'leri `$courseCatalogPreparationCurrent`
alanındadır (`test/store_scope_preparation_test.dart` bunları paketteki baytlarla eşler).

**Satış (karar A, 2026-10-23; Core R3 ile uzlaştırıldı 2026-10-27):** abonelik açıktır
(Lissom + Motion+). Her kursun ilk bölümü ücretsizdir: Hatha 24/60, sandalye/ofis 6/15,
Vinyasa 5/14, Yin 5/12, Ashtanga 7/19, toplam **120 dersin 47'si**. Bunlar
**uygulamadaki mevcut sayılardır; kurucu K-7 ile onaylandı (2026-10-27)**. Kalan dersler
Lissom veya Motion+ aboneliği ister ve ilerleme her zaman okunur. Fiyat, deneme süresi ve
yenileme koşullarını mağaza ve uygulamadaki Üyelik sayfası gösterir. Açıklamaya
Guideline 3.1.2 için yenileme ve iptal cümlesi eklendi (JabLab/Gravita düzeyi).

İlgili dosyalar:
[release-review.json](release-review.json) (sürüm politikası, App Review metni EN/TR,
Play hesap silme alanı, yaş derecesi, açık kabuller) ·
[privacy-review.json](privacy-review.json) (yedi Apple türü ve Play önerileri; satın alma
geçmişi dahil) · [subscriptions-draft.json](subscriptions-draft.json) (ürün kimlikleri,
fiyat, P14D, Motion+ tek deneme, Play teklifleri) ·
[account-data-safety-draft.md](account-data-safety-draft.md) (2026-10-27 bölümü:
konsol giriş adımları) · [reviewer-notes.md](reviewer-notes.md) (uzun inceleme notu).

## Alan eşlemesi (14 dil, ölçülmüş)

| Dil | Dosya | Ad | Subtitle | Promo | Keywords | Play kısa | Açıklama |
|---|---|---|---|---|---|---|---|
| en-US | [listing.json](listing.json) | Lissom: Yoga & Mobility | 28 | 168 | 98 B | 79 | 2280 |
| tr-TR | [listing.tr-TR.json](listing.tr-TR.json) | Lissom: Yoga ve Mobilite | 30 | 147 | 99 B | 62 | 2099 |
| es-419 | [listing.es-419.json](listing.es-419.json) | Lissom: Yoga y movilidad | 25 | 166 | 98 B | 80 | 2583 |
| pt-BR | [listing.pt-BR.json](listing.pt-BR.json) | Lissom: Yoga e mobilidade | 26 | 166 | 96 B | 77 | 2478 |
| de | [listing.de.json](listing.de.json) | Lissom: Yoga & Mobilität | 28 | 170 | 95 B | 79 | 2552 |
| fr | [listing.fr.json](listing.fr.json) | Lissom: Yoga et mobilité | 27 | 163 | 98 B | 74 | 2615 |
| ja | [listing.ja.json](listing.ja.json) | Lissom: ヨガとモビリティ | 14 | 87 | 98 B | 39 | 1170 |
| ar | [listing.ar.json](listing.ar.json) | Lissom: يوغا ومرونة الحركة | 26 | 148 | 97 B | 67 | 1920 |
| it | [listing.it.json](listing.it.json) | Lissom: Yoga e mobilità | 27 | 166 | 96 B | 78 | 2577 |
| ko | [listing.ko.json](listing.ko.json) | Lissom: 요가 & 모빌리티 | 15 | 95 | 97 B | 40 | 1248 |
| id | [listing.id.json](listing.id.json) | Lissom: Yoga dan Mobilitas | 29 | 166 | 99 B | 78 | 2319 |
| pl | [listing.pl.json](listing.pl.json) | Lissom: Joga i mobilność | 28 | 169 | 98 B | 74 | 2409 |
| hi | [listing.hi.json](listing.hi.json) | Lissom: योग और गतिशीलता | 24 | 152 | 84 B | 70 | 2117 |
| zh-Hans | [listing.zh-Hans.json](listing.zh-Hans.json) | Lissom：瑜伽与灵活性 | 11 | 68 | 94 B | 29 | 756 |
| **Sınır** | | 30 | 30 | 170 | 100 B | 80 | 4000 |

Ortak alanlar: Support URL `https://yulalab.com/support` · Privacy URL
`https://yulalab.com/privacy/motion` · Terms `https://yulalab.com/terms` · ASC License
Agreement **Apple standart EULA** (K-7) · Play hesap silme URL'si
`https://yulalab.com/en/delete-account/motion` — `pending_live` (YUL-09 ile canlı; TR kök
`/delete-account/motion`). Karakter sayısı Unicode kod noktası, anahtar kelimeler UTF-8
bayttır (ar/ja/hi/zh'de karakter sınırı geçip bayt sınırı aşılabilir).

Kapılar: `test/store_listing_test.dart` — EN/TR uzunluk ve varlık, TR adı ve satış
cümleleri, vaat dili, cihaz kanıtı iddiası; on iki yerel dosya için aynı sınırlar,
anahtar kelime baytı, `Lissom` adı, sayı tutarlılığı (120 · 60 · 19 · 12 · 14×3 · 15 · 47 ·
24 saat), `Motion+`, vaat dili ve ortak URL'ler. Yerel metinlerin ana dil / hukuk / mağaza
incelemesi **UNRUN** (her dosyanın `$doc` alanı).

## Kurucu kararları (K-2, K-6, K-7 — 2026-10-27)

| Alan | Karar | Repoda |
|---|---|---|
| Mağaza adı | **`Lissom: Yoga & Mobility`** (eski `Lissom: Movement Checks` / `Lissom: Hareket Testleri`); her dilde yerel karşılığı, `Lissom` markası korunur | `listing*.json` `appStore.name`; `store_listing_test` |
| Ücretsiz ders sayıları | uygulamadaki sayılar: Hatha 24/60, sandalye/ofis 6/15, Vinyasa 5/14, Yin 5/12, Ashtanga 7/19 = **47/120** | açıklamalarda "120 dersin 47'si"; `release-review.json`, `subscriptions-draft.json` |
| Yaş derecesi | diğer Motion app'leriyle aynı: Apple anketi içerik gerçeklerinden, Made for Kids / Kids Category **hayır**; Play hedef kitle 13–15 / 16–17 / 18+; IARC diğer app'lerle aynı. 13+ hesap kuralı içerik derecesi değil, kayıt kapısı (App Review notunda) | `release-review.json` `ageRating` |
| Ülkeler | **tüm ülkeler** | `release-review.json` `availability` |
| Lisans sözleşmesi | **Apple standart EULA** + `https://yulalab.com/terms` | `release-review.json` `privacy.licenseAgreement` |
| Mağaza dilleri | **14 dil** (uygulama ve site ile aynı) | `listing.<locale>.json` |
| 13–17 satın alma | **mağaza aile denetimleri** (`storeFamilyControls`, beş app) | `lib/app/lissom_release_policy.dart`; App Review notu |
| Kategori / sağlık beyanı | Health & Fitness; tıbbi cihaz değil, genel bilgi | — |

## Konsol adımları (Yönetim; bu repo konsola yazmaz)

1. **ASC → Lissom (6794715023)**: App Information → Name/Subtitle (14 dil, `listing*.json`) ·
   Age Rating anketi (diğer Motion app'leriyle aynı yanıtlar) · Availability → tüm ülkeler · App Privacy (`account-data-safety-draft.md` 2026-10-27 adım 1:
   Purchases → Purchase History, linked, App Functionality) · License Agreement → Apple standart EULA ·
   1.0.0 sürüm sayfası → Description / Promotional Text / Keywords / Support URL ·
   App Review Information → Notes = `release-review.json` `appReview.en-US`, demo
   hesabı güvenli kanaldan · Subscriptions → "Motion membership" (YLIS-05a).
2. **Play Console → Lissom**: Store listing (14 dil; short + full description) · App content →
   Target audience (13–15, 16–17, 18+) · Data safety (`account-data-safety-draft.md`
   adım 2; Financial info → Purchase history) · Data deletion URL `https://yulalab.com/en/delete-account/motion` (YUL-14; canlı olunca) ·
   Monetize → Subscriptions (YLIS-05b; Motion+ teklifi `free-trial`, Developer determined,
   tag `motion-plus-trial`).
3. Her adım için kanıt: ekran görüntüsü veya readback. Sonuç bu dosyalara geri yazılır.

## Ne yazılmadı (bilerek)

- Cihazda kanıtlanmış hiçbir cümle; ekran görüntüleri imzalı adaydan yeniden alınacak.
- Kamera ölçümü, poz puanı, koçluk veya kişisel program vaadi.
- Yerel metinlerin ana dil / hukuk incelemesi yapılmış gibi bir iddia.
- Fiyatın yerel para birimindeki karşılığı (mağaza gösterir; USD baz yalnız taslaklarda).
