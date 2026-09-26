# Lissom ilk sürüm hesap veri beyanı taslağı — 2026-09-25

Bu dosya satışın kapalı olduğu ilk sürüm kaynağına ve Motion üretim şemasına göredir. App Store Connect
ve Google Play veri güvenliği formlarına henüz girilmiş/onaylanmış beyan değildir.

## Kaynakla uzlaştırma — 2026-09-26

Başlıktaki 2026-09-25 ilk taslak tarihidir. Bu güncelleme mevcut ilk kurs,
yerel ilerleme, çözümlenen hesap paketi ve native izin kaynaklarının
kontrolüdür; canlı sağlayıcı, fiziksel cihaz veya mağaza formu kabulü değildir.

| Veri | Cihaz dışına çıkar mı? | Amaç | Mağaza veri türü |
|---|---|---|---|
| E-posta adresi | Evet, Motion Auth | Kayıt, giriş, doğrulama, kurtarma | Apple Email Address; Play Personal info / Email address |
| Görünen ad | Kullanıcı girerse evet | Profil | Apple Name; Play Personal info / Name |
| Rastgele hesap kimliği | Evet | Oturum ve hesap veri ayrımı | Apple User ID; Play Personal info / User IDs |
| Satın alma geçmişi | Hayır; ilk sürümde satış ve ücretli oturum kapalı | Kullanılmaz | İlk sürüm formunda beyan edilmez; satış açılırsa yeniden değerlendirilir |
| Kamera görüntüsü ve eklem noktaları | Hayır | Canlı cihaz içi ölçüm | Sunucuya toplanmaz |
| Hatha kursu ilerlemesi | Hayır | Görüldü, çalışıldı ve kullanıcı beyanıyla tamamlandı durumları | Konuk/hesap kapsamına ayrılmış yerel `hatha_progress.jsonl`; Motion hesabına senkronize edilmez |
| Mikrofon/ses | Kullanılmaz | İlk kurs mikrofon istemez | iOS mikrofon gerekçesi ve Android `RECORD_AUDIO` yoktur |
| Ölçüm ve seans geçmişi | Hayır | Cihazdaki uygulama geçmişi | Sunucuya toplanmaz |

Parola Auth isteğinde iletilir; uygulama geçmişinde tutulmaz. Ödeme kartı
bilgisi Motion'a gelmez. Apple manifestinde üç toplanan tür `Linked=true`,
`Tracking=false`, `PurposeAppFunctionality` olarak beyanlıdır. Kamera/video,
yerel geçmiş, mikrofon ve reklam kimliği sunucuya gönderilmez; ilk sürümde
mikrofon izni yoktur. Bu tablo gerçek cihaz, birleşik iOS gizlilik raporu ve
mağaza formlarının son kabulünün yerine geçmez.

[Apple](https://developer.apple.com/app-store/app-privacy-details/) ve
[Google Play](https://support.google.com/googleplay/android-developer/answer/10787469?hl=en)
yalnız cihazda kalan işlem/kaydın collection beyanı gerektirmediğini açıklar.
Cihaz dışına gönderilen türetilmiş veri veya SDK trafiği ayrı değerlendirilir.
Hatha öz beyanı poz/ustalık veya sağlık uygunluğu puanı değildir; genel
uyarlama açıklaması kişisel sağlık verisinin sağlayıcıya gönderimi değildir.
Ostinato'nun izinli isteğe bağlı mikrofon kararı Lissom'a mikrofon eklemez.

Kaynaklar: `lib/main.dart`, `lib/app/hatha_progress.dart`,
`lib/app/local_account_bridge.dart`, native izin dosyaları ve
`ios/Runner/PrivacyInfo.xcprivacy`. Hesap silme ilgili hesabın yerel dizinini
kapsar; konuk verisi ayrı kalır. Çözümlenen `motion_account` paketindeki
`motion_release_policy.dart` değeri `motionPaidFeaturesAvailable=false`;
satış/üyelik ve paid-session girişleri kapalıdır. Manifestte yalnız e-posta,
ad ve kullanıcı ID'si collected olarak beyanlıdır; purchase-history türü
yoktur. Final paket/SDK raporu, sağlayıcı günlükleri/saklama, uygulama dışı
hesap silme bağlantısı ve gerçek Apple/Play yanıtları ayrıca doğrulanır.
