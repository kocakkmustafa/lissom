# Güncel mağaza metni girişi · 27 Ekim 2026

Yayıma hazırlanacak TR/EN metinlerin kaynağı [listing.json](listing.json) ve
[listing.tr-TR.json](listing.tr-TR.json) dosyalarıdır. Bu dosyalarda `$` önekli
alanlar gerekçe notudur ve mağazaya taşınmaz. Kaynak `e455e27` (Motion Core R3
`f43d71a` pin), sürüm 1.0.0 (build 4). Bu dosya mağaza paneline yazıldığı, güncel
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
**uygulamadaki mevcut sayılardır; kurucu onayı bekleniyor (K-7)**. Kalan dersler
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

## Alan eşlemesi

| Mağaza alanı | Kaynak | EN (karakter) | TR (karakter) | Sınır |
|---|---|---|---|---|
| ASC name | `appStore.name` | `Lissom: Movement Checks` (23) | `Lissom: Hareket Testleri` (24) | 30 |
| ASC subtitle | `appStore.subtitle` | 28 | 29 | 30 |
| ASC promotional text | `appStore.promotionalText` | 156 | 140 | 170 |
| ASC keywords | `appStore.keywords` | 71 | 71 | 100 |
| Play short description | `playStore.shortDescription` | 77 | 65 | 80 |
| Description (ASC + Play) | `description` | 2243 | 2072 | 4000 |
| Support URL | `supportUrl` | `https://yulalab.com/support` | aynı | — |
| Privacy URL | `privacyPolicyUrl` | `https://yulalab.com/privacy/motion` | aynı | — |
| Terms / EULA | `$subscriptionTerms20261027` | `https://yulalab.com/terms`; ASC License Agreement önerisi Apple standart EULA (K-7) | aynı | — |
| Play hesap silme URL'si | `release-review.json` `play` | `https://yulalab.com/en/delete-account/motion` — `pending_live` (YUL-09 ile canlı) | TR kök `/delete-account/motion` | — |

Uzunluk ve varlık kapıları: `test/store_listing_test.dart` (TR adı, satış cümleleri, vaat
dili ve cihaz kanıtı iddiası taraması dahil).

## Kurucu kararı bekleyen alanlar (K-7)

| Alan | Bugünkü taslak | Öneri |
|---|---|---|
| Mağaza adı | `Lissom: Movement Checks` / `Lissom: Hareket Testleri` | **öneri: `Lissom: Yoga & Mobility`** (23 karakter). Kamera kapalıyken "Movement Checks" bir ölçümü çağrıştırıyor. Onay gelince `appStore.name`, TR adı ve `store_listing_test` birlikte değişir |
| Ücretsiz ders sayıları | 47/120 (uygulamadaki mevcut sayılar) | diğer dört app gibi "uygulamadaki sayılar korunur" — **K-7 onayı bekliyor** |
| Yaş derecesi | `$ageRating` "4+ / Everyone" tahmini (satış öncesi) | ASC anketi yeniden yanıtlanır. Hesaplar 13+ ve 13 altı misafir; Play hedef kitle 13–15 / 16–17 / 18+ |
| Ülkeler | — | global (yaş/veli akışı ve Core canlı olmadan hiçbir ülke) |
| Kategori / sağlık beyanı | Health & Fitness | tıbbi cihaz değil; genel bilgi |
| Lisans sözleşmesi | — | Apple standart EULA + `https://yulalab.com/terms` |

Ad dışında isteğe bağlı bir kopya notu: `promotionalText` "bilingual lessons" diyor;
arayüz ve katalog metni 14 dilde. Ad kararıyla birlikte gözden geçirilebilir.

## Konsol adımları (Yönetim; bu repo konsola yazmaz)

1. **ASC → Lissom (6794715023)**: App Information → Name/Subtitle (K-7 sonrası) ·
   Age Rating anketi · App Privacy (`account-data-safety-draft.md` 2026-10-27 adım 1:
   Purchases → Purchase History, linked, App Functionality) · License Agreement ·
   1.0.0 sürüm sayfası → Description / Promotional Text / Keywords / Support URL ·
   App Review Information → Notes = `release-review.json` `appReview.en-US`, demo
   hesabı güvenli kanaldan · Subscriptions → "Motion membership" (YLIS-05a).
2. **Play Console → Lissom**: Store listing (short + full description) · App content →
   Target audience (13–15, 16–17, 18+) · Data safety (`account-data-safety-draft.md`
   adım 2; Financial info → Purchase history) · Data deletion URL `https://yulalab.com/en/delete-account/motion` (YUL-14; canlı olunca) ·
   Monetize → Subscriptions (YLIS-05b; Motion+ teklifi `free-trial`, Developer determined,
   tag `motion-plus-trial`).
3. Her adım için kanıt: ekran görüntüsü veya readback. Sonuç bu dosyalara geri yazılır.

## Ne yazılmadı (bilerek)

- Cihazda kanıtlanmış hiçbir cümle; ekran görüntüleri imzalı adaydan yeniden alınacak.
- Kamera ölçümü, poz puanı, koçluk veya kişisel program vaadi.
- Fiyatın yerel para birimindeki karşılığı (mağaza gösterir; USD baz yalnız taslaklarda).
