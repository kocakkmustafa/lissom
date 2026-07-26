# 09 — Wellness Dil Süzgeci (2026-07-26)

Kaynak: G0 tazeleme fan-out

Kapsam: Lissom'un TÜM kullanıcıya görünen metinleri (skor ekranı, geri bildirim, sesli koç replikleri, onboarding, store metni) için dil kontrol listesi. Kaynaklar: FDA General Wellness Policy, Apple App Store Review Guidelines 1.4.1/5.1.1, Google Play sağlık politikası, EU MDR/MDCG sınır kriteri, gerçek red vakaları.

## Özet

Dört rejim de aynı eksene bakıyor: **iddia dili** (claim language) ürünü wellness'tan tıbbi cihaza kaydırıyor, özellik kendisi değil. FDA (2026 güncel rehber, 2019'un yerine geçti) "genel wellness iddiası" + "düşük risk" ikilisini arıyor — hastalık adı yok, teşhis/tedavi eşiği yok, invaziv olmayan tahmin serbest ama "belirli bir hastalığa referans" veya "tanısal eşik" YASAK. Apple 1.4.1 iki şeye bakıyor: (a) doğruluk iddiasının kanıtlanabilirliği (yalnız telefon sensörüyle "ölçüm" iddiası reddedilir), (b) "doktora danışın" hatırlatması var mı. Google Play 2026'dan itibaren "Medical Device" etiketleme sistemi getirdi — yanıltıcı sağlık iddiası veya tıbbi konsensüse aykırı iddia yasak. EU MDR/MDCG çizgisi "bilgi mi veriyor, karar mı veriyor" — biyometrikten "fizyolojik durum çıkarımı" yapıp "anlamlı sağlık sinyali" gibi sunmak sınırı aşıyor. Gerçek vaka: wellness-only, disclaimer'lı, sadece göreli aralık ("slow/average/fast") gösteren bir app yine de Apple'da 1.4.1 altında reddedildi — disclaimer TEK BAŞINA yeterli değil, UI'ın kendisi de klinik hissettirmemeli.

## Bulgular (kanıtlı, URL'li)

### (a) FDA General Wellness Policy

- FDA, "General Wellness: Policy for Low Risk Devices" rehberini **2026-01-06 tarihinde revize edip 2019 sürümünün yerine koydu.** Kaynak: https://www.troutman.com/insights/fdas-2026-guidance-on-general-wellness-devices-policy-for-low-risk-devices/ ve https://www.cov.com/en/news-and-insights/insights/2026/01/fda-issues-revised-guidance-on-general-wellness-products
- Temel çerçeve değişmedi: düşük-riskli genel wellness ürünleri FDCA kapsamında cihaz olarak düzenlenmiyor (enforcement discretion). Kaynak: https://www.troutman.com/insights/fdas-2026-guidance-on-general-wellness-devices-policy-for-low-risk-devices/
- **2026 güncellemesinin en önemli değişikliği:** invaziv olmayan ürünlerin (giyilebilir/kamera tabanlı dahil yorumlanabilir) kan basıncı, oksijen satürasyonu, kan şekeri, HRV gibi fizyolojik parametreleri **tahmin etmesine/çıkarsamasına** izin veriliyor — YETER Kİ **belirli bir hastalığa referans vermesin** ve **tanısal eşik (diagnostic threshold)** kullanmasın. Kaynak: https://www.troutman.com/insights/fdas-2026-guidance-on-general-wellness-devices-policy-for-low-risk-devices/
- FDA orijinal rehber PDF'i (https://www.fda.gov/media/90652/download) bu oturumda **erişilemedi (404)** — içerik ikincil kaynaklardan (hukuk bürosu özetleri) alındı, DOĞRULANMADI birincil metinle karşılaştırılmadı. Resmi PDF'in güncel adresi doğrulanmalı.
- FDA 2026-02-11'de bu rehber için bir town hall yaptı. Kaynak: https://www.fda.gov/medical-devices/medical-devices-news-and-events/town-hall-general-wellness-policy-low-risk-devices-final-guidance-02112026

### (b) Apple App Store Review Guidelines

- **1.4.1 tam metin (resmi sayfadan alındı, 2026-07-26 itibariyle):**
  > "Medical apps that could provide inaccurate data or information, or that could be used for diagnosing or treating patients may be reviewed with greater scrutiny. Apps must clearly disclose data and methodology to support accuracy claims relating to health measurements, and if the level of accuracy or methodology cannot be validated, we will reject your app. For example, apps that claim to take x-rays, measure blood pressure, body temperature, blood glucose levels, or blood oxygen levels using only the sensors on the device are not permitted. Apps should remind users to check with a doctor in addition to using the app and before making medical decisions."
  Kaynak: https://developer.apple.com/app-store/review/guidelines/
- **5.1.1 tam metin (veri toplama/gizlilik, sağlık verisi dahil):** privacy policy zorunlu + ne veri toplandığının açık beyanı + üçüncü taraf paylaşımı beyanı + rıza alma + rızayı geri çekme yolu. Kaynak: https://developer.apple.com/app-store/review/guidelines/ (HealthKit'e özel ek kural bu genel metinde açık değil, ayrı HealthKit dokümantasyonuna bakılmalı — DOĞRULANMADI, bu oturumda ayrıca aranmadı).
- **Gerçek vaka (Apple Developer Forums, thread 807508):** Wellness-only iddia eden, disclaimer'ı olan, yalnız göreli/kategorik gösterge kullanan (numeric ölçüm yok, "slow/average/fast" gibi) bir app yine de 1.4.1 altında "tıbbi veri/sağlık ölçümü/teşhis/tedavi tavsiyesi, uygun regülatif onay olmadan" gerekçesiyle reddedildi. Apple'ın yanıtı jenerik itiraz süreci yönlendirmesiydi, spesifik netlik VERİLMEDİ. Kaynak: https://developer.apple.com/forums/thread/807508
- Genel gözlem (ikincil kaynak): Health & Fitness kategorisi apps ek denetime tabi değil ama Medical kategorisi ek disclaimer + kaynak-linki zorunlu tutuyor; kaynak göstermeden sağlık tavsiyesi veren app'ler (ör. BMI/RMR hesaplayan) reddedilmiş. Kaynak: https://newagesysit.com/blog/ftc-guidelines-app-store-health-data-rules-for-wellness-platforms-in-the-united-states/ (ikincil, DOĞRULANMADI birincil Apple kaynağıyla).

### (c) Google Play sağlık politikası

- 2026-01-28'e kadar mevcut sağlık app'lerinin doğrulanmış Organizasyon Hesabına geçmesi zorunlu tutuldu (bireysel geliştirici hesabı değil). Kaynak: https://myappmonitor.com/blog/google-play-health-apps-update-2026-requirements
- 2026'dan itibaren "Medical Device" etiketleme sistemi var — FDA/CE onayı kanıtlanan app'lere doğrulanmış etiket veriliyor. Kaynak: https://myappmonitor.com/blog/google-play-health-apps-update-2026-requirements
- Google, "var olan tıbbi konsensüse aykırı" veya "kullanıcıya zarar verebilecek" yanıltıcı sağlık iddialarını yasaklıyor. Kaynak: https://myappmonitor.com/blog/google-play-health-apps-update-2026-requirements
- Kamera/cihaz sensörü ile sağlık fonksiyonu iddia eden app'ler (ör. oksimetri) hangi cihaz modellerinin desteklendiğini açıkça beyan etmek zorunda. Bu, kamera-tabanlı mobilite ölçümü yapan Lissom için doğrudan emsal. Kaynak: https://myappmonitor.com/blog/google-play-health-apps-update-2026-requirements
- Resmi Google Play Console yardım sayfaları (support.google.com, Health Content and Services) bu oturumda AÇILMADI/okunmadı — yukarıdaki bulgular ikincil blog kaynağından, birincil politika metniyle DOĞRULANMADI. Resmi sayfa: https://support.google.com/googleplay/android-developer/answer/16679511

### (d) EU MDR / MDCG sınır kriteri

- MDR'ın kendisi wellness/fitness app'lerini "medical device software" DIŞINDA tutuyor; temel ayrım **amaç** — wellness app yaşam tarzı/fitness/iyi-oluş bilgisi verir, medical device software hastalık/klinik durumun teşhis veya tedavisi için bilgi verir. Kaynak: https://namsa.com/resources/blog/eu-mdr-and-ivdr-classifying-medical-device-software-mdsw/
- MDCG 2019-11 kriteri: yazılım "teşhis veya tedavi amaçlı karar almak için kullanılan bilgi" veriyorsa medical device'tır; sadece veriyi saklıyor/gösteriyor/aktarıyorsa değildir. Kaynak: https://namsa.com/resources/blog/eu-mdr-and-ivdr-classifying-medical-device-software-mdsw/
- Somut örnek çizgisi: kalp atış hızını günün içinde gösteren app medical device DEĞİL; ama biyometrik veriden **fizyolojik durum çıkarımı yapıp bunu "anlamlı sağlık sinyali" gibi sunmak** çizgiyi aşabilir — bu, tek bir bilinçli karar olmadan da gerçekleşebilir (özellik ekleye ekleye kayma riski). Kaynak: https://namsa.com/resources/blog/eu-mdr-and-ivdr-classifying-medical-device-software-mdsw/
- MDCG 2019-11 Revision 1 (resmi PDF: https://health.ec.europa.eu/system/files/2020-09/md_mdcg_2019_11_guidance_en_0.pdf) bu oturumda AÇILMADI — yukarıdaki özet ikincil kaynaktan, birincil metinle DOĞRULANMADI.

### (e) Gerçek red/uyarı vakaları

- Apple Developer Forums thread 807508: yukarıda (b)'de detaylandırıldı — disclaimer + göreli-dil TEK BAŞINA koruma sağlamadı.
- İkincil kaynak (DOĞRULANMADI, birincil Apple case yok): BMI/RMR hesaplayan ve kaynak göstermeyen sağlık tavsiyesi app'lerinin reddedildiği iddiası. Kaynak: https://newagesysit.com/blog/ftc-guidelines-app-store-health-data-rules-for-fitness-platforms-in-the-united-states/
- GOWOD veya benzeri doğrudan rakip için spesifik red/uyarı vakası bu aramada BULUNAMADI — DOĞRULANMADI.

## Ürüne doğrudan girdi

### 1) YASAK ifadeler listesi (İngilizce, örnekli)

| Yasak ifade / örnek | Neden yasak |
|---|---|
| "diagnose", "diagnosis", "diagnostic" (ör. "this diagnoses your shoulder impingement") | Apple 1.4.1 + FDA/MDR teşhis eşiği |
| "treat", "treatment", "therapy for [condition]" (ör. "treats your frozen shoulder") | Tedavi iddiası = medical device sınırı |
| "measures your [blood pressure/oxygen/heart rate] using only your phone camera" | Apple 1.4.1 açıkça yasaklıyor — yalnız cihaz sensörüyle fizyolojik ölçüm iddiası |
| Belirli hastalık/klinik durum adı geçen skor/tavsiye (ör. "you may have scoliosis", "signs of impingement syndrome", "rotator cuff tear risk: high") | FDA 2026: hastalığa referans = wellness sınırının dışına çıkar |
| "clinically proven", "clinically validated" (kanıt yoksa) | Apple: doğrulanamayan doğruluk iddiası reddedilir |
| Sayısal/kesin klinik ölçüm dili: "Your ROM is 87 degrees, below the clinical threshold of 90" | "Diagnostic threshold" kullanımı — FDA 2026 açıkça yasaklıyor |
| "prescribe", "your prescribed program" | Tıbbi reçete çağrışımı |
| "cure", "fix your pain permanently" | Tedavi/iyileştirme iddiası |
| "risk of [disease name]" (ör. "risk of osteoarthritis") | Hastalık adı + risk skoru = teşhis-yakını dil |
| "medical grade", "FDA cleared" (onay yoksa) | Yanlış regülatif iddia |
| "this replaces seeing a physical therapist/doctor" | Doktor yerine geçme iddiası — tam ters yönde disclaimer gerekiyor |

### 2) GÜVENLİ karşılıkları (wellness dilinde yeniden yazım)

| Yasak | Güvenli karşılık |
|---|---|
| "Your ROM is 87°, below clinical threshold" | "Your shoulder mobility is in the lower range compared to your last 3 assessments" (göreli, kişisel-baseline'a kıyasla, mutlak klinik eşik yok) |
| "Signs of impingement syndrome" | "Your movement pattern in this test showed limited range — try today's mobility routine" |
| "This diagnoses your posture problem" | "This gives you a general snapshot of your movement capacity for wellness tracking — not a diagnosis" |
| "Treats your shoulder pain" | "Offers a gentle daily mobility routine that may help you feel more comfortable moving" |
| "Risk of osteoarthritis: high" | (Bu tür bir çıktı tamamen KALDIRILMALI — hastalık adı + risk skoru kombinasyonu hiçbir yeniden yazımla güvenli hale gelmez) |
| "Clinically proven to improve flexibility" | "Designed using published mobility research; individual results vary" (iddia varsa kaynak linkiyle beraber) |
| "Measures your blood pressure via camera" | (Ürün kapsamı dışı — Lissom kan basıncı ölçmüyor; bu satır yalnızca gelecekte benzeşik bir özellik eklenirse dikkat çekmek için) |
| "Your prescribed program" | "Your personalized routine" |

### 3) Zorunlu disclaimer taslakları

**Onboarding (ilk açılış, tek seferlik ekran):**
> "Lissom is a general wellness app. It uses your phone's camera to estimate movement capacity for tracking purposes only. It is not a medical device, does not diagnose or treat any condition, and is not a substitute for professional medical or physical therapy advice. If you have pain, an injury, or a medical condition, talk to a qualified healthcare provider before starting any new movement routine."

**Skor ekranı (her assessment sonucunun altında, kalıcı küçük metin):**
> "This score reflects your movement pattern compared to your own history — it is not a medical measurement and should not be used to diagnose or rule out any condition."

**Ağrı akışı (kullanıcı ağrı bildirdiğinde tetiklenen ekran):**
> "We're sorry you're experiencing discomfort. Lissom is not able to assess pain causes or provide medical advice. If pain is new, severe, or persistent, please consult a doctor or physical therapist. We'll adjust today's routine to be gentler, but this is not a substitute for professional care."

**Store metni (uygulama açıklaması, her mağaza için kısa varyant):**
> "Lissom is a wellness app for tracking mobility and yoga practice using your phone's camera — 100% on-device, nothing uploaded. Not a medical device; not intended to diagnose, treat, cure, or prevent any disease."

### 4) Otomatik denetim için yasak-kelime listesi (CI string taraması, İngilizce anahtar kelimeler)

```
diagnos          # diagnose, diagnosis, diagnostic
treat            # treat, treatment, treats, treated
cure
prescri          # prescribe, prescription, prescribed
clinical         # "clinically proven/validated" kontrolü için (bağlamsal — kaynak varsa istisna edilebilir)
FDA cleared
FDA approved
medical grade
medical device
symptom
syndrome
disorder
disease
pathology
impingement
rotator cuff tear
osteoarthritis
scoliosis
herniat          # herniated disc
degenerat        # degenerative
risk of          # "risk of [disease]" kalıbı için bağlamsal kontrol
blood pressure
blood oxygen
blood glucose
heart rate variability   # yalnız kamera/sensörle "ölçüm" iddiası bağlamında kontrol
x-ray
replace your doctor
replace physical therapy
guaranteed
permanently fix
```

Not: Bu liste **bağlamsal false-positive üretir** (ör. disclaimer metninin kendisi "diagnose" kelimesini "does not diagnose" şeklinde meşru kullanır). CI taraması negation-aware olmalı veya bu liste yalnızca kullanıcıya-görünen dinamik/üretilen metin (skor, geri bildirim, sesli koç) dosyalarına uygulanmalı, statik disclaimer dosyaları hariç tutulmalı.

## Açık sorular

1. **FDA 2026 rehberinin birincil metni bu oturumda okunamadı** (fda.gov/media/90652/download 404 verdi). "Fizyolojik parametre çıkarımı serbest, hastalık referansı/tanısal eşik yasak" özeti yalnızca hukuk bürosu ikincil kaynaklarından geldi — resmi PDF'in güncel URL'i bulunup birincil metinle çapraz doğrulanmalı.
2. **Google Play'in HealthKit-benzeri "Health Content and Services" resmi sayfası** (support.google.com/googleplay/android-developer/answer/16679511) açılıp okunmadı — kamera-tabanlı vücut analizi için özel bir madde olup olmadığı DOĞRULANMADI.
3. **GOWOD'un (doğrudan rakip) herhangi bir store red/uyarı vakası** bulunamadı — rakibin dil sınırını nasıl geçtiği (ya da geçmediği) hâlâ belirsiz; ayrı bir rakip-vaka araştırması gerekebilir.

## Kaynaklar

- https://www.troutman.com/insights/fdas-2026-guidance-on-general-wellness-devices-policy-for-low-risk-devices/
- https://www.cov.com/en/news-and-insights/insights/2026/01/fda-issues-revised-guidance-on-general-wellness-products
- https://www.fda.gov/medical-devices/medical-devices-news-and-events/town-hall-general-wellness-policy-low-risk-devices-final-guidance-02112026
- https://www.fda.gov/media/90652/download (erişilemedi — 404)
- https://developer.apple.com/app-store/review/guidelines/
- https://developer.apple.com/forums/thread/807508
- https://newagesysit.com/blog/ftc-guidelines-app-store-health-data-rules-for-fitness-platforms-in-the-united-states/
- https://myappmonitor.com/blog/google-play-health-apps-update-2026-requirements
- https://support.google.com/googleplay/android-developer/answer/16679511 (yalnız arama sonucu görüldü, sayfa açılmadı)
- https://namsa.com/resources/blog/eu-mdr-and-ivdr-classifying-medical-device-software-mdsw/
- https://health.ec.europa.eu/system/files/2020-09/md_mdcg_2019_11_guidance_en_0.pdf (yalnız arama sonucu görüldü, sayfa açılmadı)
