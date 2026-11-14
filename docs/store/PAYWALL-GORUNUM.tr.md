# Kilitli ders → paywall görünümü (LIS-P1-12b, salt-okur inceleme)

Tarih 2026-11-14. Kaynak yolları `ventures/` köküne göredir (`M/` = `motion-core/lib/packages/motion_account/lib/src/`). Çalıştırma/ekran görüntüsü yok (aşağıda).

## 1. Akış (Lissom'a özgü: yalnız kapı; ekran Core'un)
- Kilit kuralı Lissom'da: ücretsiz kısım `kFreeModuleIds` (`lissom/app/lib/app/course_access.dart:15-35`), karar Core `isLessonUnlocked` (`course_access.dart:51-60`).
- Kilitli derse dokunma: `hatha_course_screen.dart:93-95` → `LissomCourseAccessState.requestOpen` (`course_access.dart:100-108`) → `ensureAccess` (`main.dart:169-170`).
- `ensureAccess` = Core `requireMotionPaidAccess` (`lissom/app/lib/main.dart:615-621`; `salesAvailable: true`, `teenPurchasePolicy: lissomTeenPurchasePolicy` = `storeFamilyControls`, `lib/app/lissom_release_policy.dart:10-11`).
- Lissom `membershipPageBuilder` VERMEZ (`main.dart:615-621`), yani Core varsayılanı açılır: `MotionMembershipPage` (`M/motion_paid_access.dart:66-74`).
- Sıra (`M/motion_paid_access.dart:26-75`): satış kapalıysa snackbar "future update"; oturum yoksa Lissom'un `_accountPage` (`main.dart:494`, Core `MotionAccountPage`) ile giriş; üyelik zaten aktifse sayfa hiç açılmaz; değilse üyelik sayfası; dönüşte yeniden kontrol (`:75`).
- Sonuç: paywall = tamamen Core `MotionMembershipPage`. Lissom'a özgü sunum/metin/plan satırı YOK (Lissom içinde `MotionMembershipPage` geçmez; grep `lib/` boş).

## 2. Ekranda ne var (`M/motion_membership_page.dart`)
- AppBar: `membershipTitle` (:362) en "Membership" / tr "Üyelik" (`motion_account_localizations.dart:1289-1291`).
- Başlık `membershipForApp(appName)` (:384-389); `appName` Core `motion_app_brand.dart:3` → "Lissom"; en "Lissom membership" / tr "Lissom üyeliği" (`localizations:1355-1357`).
- Fayda `guidedBenefit` (:390): en "Provides access to available guided sessions in this app. Check the catalog before purchasing." / tr "Bu uygulamadaki kullanılabilir rehberli seanslara erişim sağlar. Satın almadan önce kataloğu incele." (`localizations:976-977`). Lissom'a özgü değil; "ders/kurs" yerine "rehberli seans" der.
- Plan satırları (`_offer`, :327-356): "Aylık/Monthly" ve "Yıllık/Yearly" + `offer.localizedPrice` + "Seç/Choose". Deneme varsa "{days} gün ücretsiz, ardından aylık/yıllık {price}" (`localizations:2120-2137`).
- Motion+ bölümü (:397-399): başlık "Motion+" (sabit), `motionPlusBenefit` en "Unlocks the paid lessons and practice available today in all five Motion apps. Camera coaching and lessons not yet released are not included." (`localizations:1390-1392`); başka uygulamada aktif abonelik varsa bunun yerine `otherSubscription` (:395, `:1372-1373`).
- Alt metinler: `autoRenewTerms` (:402, `:1408-1410`), deneme varsa `trialRenewTerms` (:406, `:2153-2154`), `storeFamilyControls` ise aile denetimi notu (:403-404, `:2189-2190`), Geri yükle / Durumu yenile / Mağazada yönet / Kullanım şartları (`yulalab.com/terms`) / Gizlilik (`yulalab.com/privacy/motion`) (:408-430), `subscriptionDisclosure` (:431, `:1506-1508`).
- Durum dalları: oturum yok → `signInFirst`; veli onayı gerekli → `parentalConsentNeeded`; aktif → `yourMembershipActive`; mağaza teklifi yoksa → `storeMembershipsUnavailable` en "Store memberships are unavailable right now. Try again later." (:366-383; `localizations:1337-1339`).

## 3. Fiyat nereden
- Kodda fiyat yok. Teklifler `_store.fetchProducts(_productIds())` ile mağazadan gelir (:176); gösterilen tutar `offer.localizedPrice` (:344). Sayfa belgesi: "Prices are shown only after the installed app's store returns real offers" (:15).
- Ürün kimlikleri: Android `lissom_individual`, `lissom_motion_plus`; iOS `com.yulalab.lissom.{individual|motionplus}.{monthly|yearly}` (:140-146; `_appId` = `widget.account.app.name` :56).
- Taslak USD tablosu ve 14 gün deneme repoda `docs/store/subscriptions-draft.json` (:7-11, :62+) yalnız mağaza konsolu girdisi; uygulama içinde okunmaz (kodda bağ bulunmadı).

## 4. Diğer 4 uygulama
- Ostinato: `ostinato/app/lib/app/motion_account_bootstrap.dart:121-126` Core `requireMotionPaidAccess`, özel sayfa yok → aynı `MotionMembershipPage`.
- Gravita: `gravita/app/lib/app/motion_account_bootstrap.dart:109-114` `MotionMembershipPage` (Core) → aynı.
- Choreia: `choreia/app/lib/main.dart:290-296` Core kapısı, özel sayfa yok → aynı.
- JabLab: `jablab/app/lib/main.dart:125-137` `MotionMembershipPage` (Core) → aynı.
- Sonuç (yalnız kod okuma): 5 uygulamada da paywall ekranı aynı Core bileşeni; fark yalnız uygulama adı (`motionAppBrandName`), ürün kimliği önekleri ve `teenPurchasePolicy` (Lissom/JabLab `storeFamilyControls`; Ostinato/Gravita/Choreia kendi `*TeenPurchasePolicy` sabitleri, değerleri DOĞRULANMADI).

## 5. Doğrulanmayanlar
- DOĞRULANMADI: çalışan ekran metni. Widget testi yazılmadı; sayfa gerçek `MotionAccountClient` (Supabase) ve `PurchaseAdapter` ister, scratch'te güvenle kurulamadı. Metinler yerelleştirme tablosundan okundu, render çıktısı değil.
- Ekran görüntüsü alınamadı: oturum + mağaza (StoreKit/Play) teklifi gerekir; simülatörde sahte teklifsiz yalnız "mağaza üyelikleri kullanılamıyor" dalı görünürdü.
- DOĞRULANMADI: mağazada fiyatların/14 gün denemenin fiilen oluşturulduğu (konsol okunmadı).
- DOĞRULANMADI: Lissom `_subscriptionClosed` (kapı yoksa) mesajı ve diğer dillerin (es/pt vb.) render'ı.
- Not: "fayda" metni (`guidedBenefit`) Lissom'un yazılı-ders içeriğiyle birebir örtüşmeyebilir; yalnız tespit, öneri değil.
