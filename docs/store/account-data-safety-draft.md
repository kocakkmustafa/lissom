# Lissom ilk sürüm hesap veri beyanı taslağı — 2026-09-25

Bu dosya satışın kapalı olduğu ilk sürüm kaynağına ve Motion üretim şemasına göredir. App Store Connect
ve Google Play veri güvenliği formlarına henüz girilmiş/onaylanmış beyan değildir.

## Satış açık + Core R3 uzlaştırması — 2026-10-27 (güncel; aşağıdaki "satış kapalı" satırlarının yerine geçer)

Kaynak `496e072` (Core R4 `0d29d1b` pin; satın alma ve yaş verisi R3 ile aynı). Satış 2026-10-23'te açıldı (karar A); kamera değerlendirmesi
kapalı kalır. Aşağıdaki 2026-09-26 tablosundaki "Satın alma geçmişi — Hayır; satış kapalı" satırı ve
2026-10-18 bölümündeki "103 ders / satış kapalı" cümleleri **tarihseldir**. Güncel katalog 120 yazılı derstir
(Hatha 60, Ashtanga temelleri 19, destekli Yin 12, ayakta Vinyasa 14, sandalye/ofis 15). Makine-okur
karşılık `privacy-review.json`'dur (yedi Apple türü ve Play önerileri).

| Veri | Cihaz dışına çıkar mı? | Amaç | Apple App Privacy | Play Data safety |
|---|---|---|---|---|
| Satın alma geçmişi (mağaza, ürün kimliği, orijinal işlem kimliği, durum, bitiş, doğrulama zamanı — `motion_entitlements`; Motion+ deneme başlangıcı — `motion_trial_ledger`) | Evet, sunucu doğrulaması ve mağaza sunucu bildirimleri (ASSN v2 / RTDN) | Aboneliği hesaba bağlamak, geri yüklemek, beş app'te Motion+ kapsamı, hesap başına tek Motion+ denemesi | **Purchases → Purchase History**: Linked to user = Evet; Tracking = Hayır; amaç **App Functionality** | **Financial info → Purchase history**: Collected; Shared = (P01 açık); işleme zorunlu değil (satın almayan kullanıcı için oluşmaz); amaç App functionality + Account management |
| Beyan edilen doğum ay/yılı ve ülke (gün sorulmaz) | Evet, hesapla saklanır | Hesap özellikleri ve yaş korumaları | Other Data Types (mevcut satır) | Personal info → Other info |
| Veli/vasi e-postası (13–17, onay gereken ülke) | Bir kez onay bağlantısı için gönderilir; adres saklanmaz, yalnız tek yönlü özet | Veli onayı | Contact Info → Email Address kapsamında App Functionality | Personal info → Email address |
| Mağaza yaş aralığı (iOS 26+ Declared Age Range, Play Age Signals) | Hayır; cihazda beyanla karşılaştırılır | Yaş akışını yalnız sıkılaştırmak | Toplanmaz | Toplanmaz |
| Ödeme kartı bilgisi | Uygulamaya veya Motion sunucusuna hiç gelmez | — | — | — |

Hesap silme `motion_entitlements` ve `motion_trial_ledger` satırlarını da siler; **mağaza aboneliğini iptal etmez**
(iptal mağaza hesap ayarlarındadır). Uygulama içi yol: Profil → Hesap → Motion hesabını sil. Uygulama dışı
silme talebi URL'si YULALAB YUL-14 ortak Motion sayfasıdır: `https://yulalab.com/en/delete-account/motion`
(TR kök `/delete-account/motion`, 14 dil). Sayfa YUL-09 site sürümüyle canlıya çıkana kadar durum
`pending_live`dır (`release-review.json` → `play.accountDeletionWebUrlStatus`).

**Konsol giriş adımları (Yönetim; bu repo forma bir şey yazmaz):**
1. ASC → Lissom (6794715023) → App Privacy → Edit → Data Types → **Purchases → Purchase History** işaretle →
   "Used for: App Functionality" → "Linked to the user's identity: Yes" → "Used for tracking: No" → Publish.
   Mevcut altı tür (Email Address, Name, User ID, Other Diagnostic Data, Coarse Location, Other Data Types)
   aynı yanıtlarla kalır.
2. Play Console → Lissom → App content → Data safety → Data types → **Financial info → Purchase history**:
   collected = Yes, shared = (P01 kararına göre), processed ephemerally = No, required/optional = Optional,
   purposes = App functionality, Account management. Diğer satırlar `privacy-review.json` `playProposal`
   alanlarına göre; "Data deletion" bölümünde uygulama içi silme + YUL-14 URL'si (`https://yulalab.com/en/delete-account/motion`, canlı olunca).
3. Kanıt: konsol ekran görüntüsü veya readback; değerler bu dosyaya geri yazılır.

## Kaynakla uzlaştırma — 2026-09-26

Başlıktaki 2026-09-25 ilk taslak tarihidir. Bu güncelleme mevcut ilk kurs,
yerel ilerleme, çözümlenen hesap paketi ve native izin kaynaklarının
kontrolüdür; canlı sağlayıcı, fiziksel cihaz veya mağaza formu kabulü değildir.

## Sağlayıcı günlükleri ve kimlik doğrulama — 2026-09-27

Üretim sağlayıcısının 2026-09-26 21:36 UTC tarihli salt okunur alan/sayı
makbuzu, cihaz dışındaki Auth ve edge günlüklerinin saklandığını doğrular.
Ölçüm anına kadar dönen örnekte edge günlüklerinin 6/6 kaydında IP, user-agent ve
ülke/bölge/şehir alanları; Auth günlüklerinin 6/6 kaydında IP ve 2/6 kaydında
hesap kimliği; ayrı Auth audit deposunun 1/1 kaydında kimlik ve user-agent
vardır. Veritabanındaki `auth.audit_log_entries` satır sayısının sıfır olması,
[ayrı Auth günlük deposunun](https://supabase.com/docs/guides/auth/audit-logs)
boş olduğu anlamına gelmez. Ham IP, kimlik, parola veya günlük içeriği bu
belgeye alınmamıştır. Makbuz ortak servise aittir; her uygulamada yeni bir
canlı ağ oturumu ölçüldüğü iddiası değildir.

| Sunucuda saklanan veri | Apple manifest türü | Amaç ve bağlantı |
|---|---|---|
| IP, user-agent, istemci platform/sürüm bilgisi ve Auth/istek güvenlik günlükleri | `NSPrivacyCollectedDataTypeOtherDiagnosticData` | İşletim, güvenlik ve teknik tanılama; App Functionality, kullanıcıya bağlı, tracking yok |
| Edge isteğine eklenen IP tabanlı ülke/bölge/şehir | `NSPrivacyCollectedDataTypeCoarseLocation` | Aynı hizmetin işletim/güvenlik kaydı; App Functionality, kullanıcıya bağlı, tracking yok; GPS veya kesin konum izni değildir |
| Parola kimlik doğrulama verisi ve saklanan parola hash'i | `NSPrivacyCollectedDataTypeOtherDataTypes` | Hesap doğrulama; App Functionality, kullanıcıya bağlı, tracking yok |

[Supabase Auth](https://supabase.com/docs/guides/auth/password-security)
parolanın bcrypt hash'ini `auth.users.encrypted_password` alanında tutar;
parola uygulamanın kurs/seans geçmişine yazılmaz. Apple parola için ayrı
bir tür adlandırmadığından **Other Data Types eşlemesi bu projede yapılan
bir sınıflandırma çıkarımıdır**. Kullanıcı kimliğinin tek yönlü özetiyle
tutulan hesap silme makbuzu da güvenlik/hesap verisidir; hash olması tek
başına anonim veri olduğu anlamına gelmez. IP ve hesap ilişkisinin toplama
öncesinde kaldırıldığı kanıtlanmadığından bu üç tür `Linked=true` beyan edilir.

Manifest artık e-posta, isteğe bağlı ad, kullanıcı ID'si ve bu üç türden
oluşan **altı** collected-data kaydı taşır. Hepsinde
`NSPrivacyCollectedDataTypePurposeAppFunctionality`, `Linked=true` ve
`Tracking=false` vardır. Bu, davranış analitiği veya reklam amacı eklendiği
anlamına gelmez. Kamera/kareler, cihazda kalan kurs ilerlemesi ve seans
geçmişi için collection beyanı eklenmez. Lissom mikrofon/ses kaydı kullanmaz. Sunucu günlükleri, cihaz içi geçici işleme ile aynı şey değildir.

[Apple collection ve kullanım tanımları](https://developer.apple.com/app-store/app-privacy-details/)
ve [manifest tür/anahtarları](https://developer.apple.com/documentation/bundleresources/describing-data-use-in-privacy-manifests)
bu ayrımın temelidir. Apple manifestinin güncellenmesi App Store Connect
veya Play Data safety formunun girildiği/onaylandığı anlamına gelmez.
Play kategorileri kendi form tanımlarıyla ayrıca eşleştirilir. Sağlayıcı
saklama süreleri, günlüklerin silme/erişim politikası, gerçek hesap silme
akışı ve son paket/SDK gizlilik raporu ayrı kabul kapılarıdır.

| Veri | Cihaz dışına çıkar mı? | Amaç | Mağaza veri türü |
|---|---|---|---|
| E-posta adresi | Evet, Motion Auth | Kayıt, giriş, doğrulama, kurtarma | Apple Email Address; Play Personal info / Email address |
| Görünen ad | Kullanıcı girerse evet | Profil | Apple Name; Play Personal info / Name |
| Rastgele hesap kimliği | Evet | Oturum ve hesap veri ayrımı | Apple User ID; Play Personal info / User IDs |
| Satın alma geçmişi | Hayır; ilk sürümde satış ve ücretli oturum kapalı | Kullanılmaz | İlk sürüm formunda beyan edilmez; satış açılırsa yeniden değerlendirilir |
| Kamera görüntüsü ve eklem noktaları | Hayır | Canlı cihaz içi ölçüm | Sunucuya toplanmaz |
| Beş katalogdaki kurs ilerlemesi | Hayır | Kullanıcının çalışma kaydı; ustalık/poz notu değildir | Hatha, Ashtanga temelleri, destekli Yin, ayakta Vinyasa ve sandalye/ofis kayıtları aynı yerel `hatha_progress.jsonl` günlüğünde `courseId`/`courseVersion` ile ayrılır; konuk/hesap kapsamı korunur, sunucuya senkronize edilmez |
| Mikrofon/ses | Kullanılmaz | İlk kurs mikrofon istemez | iOS mikrofon gerekçesi ve Android `RECORD_AUDIO` yoktur |
| Ölçüm ve seans geçmişi | Hayır | Cihazdaki uygulama geçmişi | Sunucuya toplanmaz |

Parola Auth isteğinde iletilir; uygulama geçmişinde tutulmaz. Ödeme kartı
bilgisi Motion'a gelmez. Apple manifestinde altı toplanan tür `Linked=true`,
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
Lissom için mikrofon veya ses toplama beyanı eklenmez.

Kaynaklar: `lib/main.dart`, `lib/app/hatha_progress.dart`,
`lib/app/local_account_bridge.dart`, native izin dosyaları ve
`ios/Runner/PrivacyInfo.xcprivacy`. Hesap silme ilgili hesabın yerel dizinini
kapsar; konuk verisi ayrı kalır. Çözümlenen `motion_account` paketindeki
`motion_release_policy.dart` değeri `motionPaidFeaturesAvailable=false`;
satış/üyelik ve paid-session girişleri kapalıdır. Manifestte e-posta, ad, kullanıcı ID'si ve yukarıdaki üç sağlayıcı veri türü
collected olarak beyanlıdır; purchase-history türü yoktur. Final paket/SDK raporu, sağlayıcı günlükleri/saklama, uygulama dışı
hesap silme bağlantısı ve gerçek Apple/Play yanıtları ayrıca doğrulanır.

## Beş katalog ve mevcut yayın kapısı — 2026-10-18

Kaynakta Hatha60, Ashtanga temelleri13, destekli Yin8, ayakta Vinyasa10 ve
sandalye/ofis12 olmak üzere103 yazılı ders var. Bu sayım tam öğretim,
gösterim videosu, fiziksel uygunluk veya model başarımı kabulü değildir.
Yerel ilerleme kayıtları kurs kimliği/sürümüyle ayrılır; yeni cloud sync,
telemetri, mikrofon veya satın alma veri akışı eklenmedi. Kamera
değerlendirmesi ve abonelik satışı kapalıdır. Mevcut ortak hesap silme tüm
Motion hesabını etkiler; guest kaydı ve başka hesap kapsamı ayrı kalır.

`privacy-draft.json`, altı mevcut Apple manifest türü ile yerel/sunucu
ayrımını otomasyon için taşır. Mağaza formlarının güncel yayını, dış hesap
silme bağlantısı, sağlayıcı saklama/silme süreleri ve birleşik final paket
SDK raporu hâlâ doğrulanmalıdır. Eski200URL okumaları güncel canlı kabul
sayılmaz;18Ekim web aracı privacy/support URL'lerini okuyamadı. Bu erişim
sınırı başka araçla aşılmadı.
