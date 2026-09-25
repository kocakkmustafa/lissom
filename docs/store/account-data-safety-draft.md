# Lissom ilk sürüm hesap veri beyanı taslağı — 2026-09-25

Bu dosya satışın kapalı olduğu ilk sürüm kaynağına ve Motion üretim şemasına göredir. App Store Connect
ve Google Play veri güvenliği formlarına henüz girilmiş/onaylanmış beyan değildir.

| Veri | Cihaz dışına çıkar mı? | Amaç | Mağaza veri türü |
|---|---|---|---|
| E-posta adresi | Evet, Motion Auth | Kayıt, giriş, doğrulama, kurtarma | Apple Email Address; Play Personal info / Email address |
| Görünen ad | Kullanıcı girerse evet | Profil | Apple Name; Play Personal info / Name |
| Rastgele hesap kimliği | Evet | Oturum ve hesap veri ayrımı | Apple User ID; Play Personal info / User IDs |
| Satın alma geçmişi | Hayır; ilk sürümde satış ve ücretli oturum kapalı | Kullanılmaz | İlk sürüm formunda beyan edilmez; satış açılırsa yeniden değerlendirilir |
| Kamera görüntüsü ve eklem noktaları | Hayır | Canlı cihaz içi ölçüm | Sunucuya toplanmaz |
| Ölçüm ve seans geçmişi | Hayır | Cihazdaki uygulama geçmişi | Sunucuya toplanmaz |

Parola Auth isteğinde iletilir; uygulama geçmişinde tutulmaz. Ödeme kartı
bilgisi Motion'a gelmez. Apple manifestinde üç toplanan tür `Linked=true`,
`Tracking=false`, `PurposeAppFunctionality` olarak beyanlıdır. Kamera/video,
yerel geçmiş, mikrofon ve reklam kimliği sunucuya gönderilmez; ilk sürümde
mikrofon izni yoktur. Bu tablo gerçek cihaz, birleşik iOS gizlilik raporu ve
mağaza formlarının son kabulünün yerine geçmez.
