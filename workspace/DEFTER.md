# Lissom — DEFTER (Bulgu Defteri)
Format: holding FABLE_PLAN §5C — kapanış kanıtı zorunlu; P0 açıkken yeni kapsam yok. Aile-geneli bulgular: `ventures/motion-core/workspace/DEFTER.md`.
| ID | Tür | Şiddet | Bulgu | Durum | Kapanış kanıtı |
|---|---|---|---|---|---|
| L-228 | kusur | P1 | **Devralınan kapı-sayısı iddiası ölçülmeden tekrarlandı.** Gece promptu ve önceki tur mührü "10 Python kapısı" diyordu; ben bunu ilk commit mesajıma ÖLÇMEDEN yazdım. Ölçüldüğünde: argümansız koşan **7 kapı** var; `fixture_check.py` bir kapı değil argüman alan bir araç ve bu makinede HİÇ koşamıyor (fixture kütüphanesi yok + paylaşımlı rig `anatomical_mode()` taşımıyor, M-F-280). Aynı sebeple engine süitinde 6 test atlanıyor. **Kendi "beyana değil ağaca güven" dersimin ihlali** — devralınan bir sayı da bir beyandır | **kapalı (düzeltildi)** | PROGRESS mührü ölçülmüş sayıyla yeniden yazıldı; `fixture_check`in neden koşamadığı isimli. Engine 95/95'in içindeki `~6` atlama artık kayıtlı |
| L-254 | kapı | P1 | **HÜKÜM L-187 GELDİ ("göçü yap") — AMA GÖÇ BU HATTAN YAPILAMAZ, ve sebebi yapısal.** Verdiğim "3 dosya"nın 2'si paylaşımlı çekirdekte: `motion_core` GitHub'dan **tam-SHA'ya çivili** çözülüyor (`f13bdc9…`, pub-cache SALT-OKUNUR). O iki dosyayı değiştirmek = motion-core deposuna commit → yeni SHA → Lissom'da **iki pin birden** güncelleme (pin-eşitliği kapısı ikisinin aynı olmasını zorluyor, J-071). Paylaşımlı ağaç `feat/lissom-v3-onayi @ 05aacaf`, **main'in 122 commit gerisinde** (M-F-280) — doğru taban bile değil; brief o ağaçta dal değiştirmeyi YASAKLIYOR (M-F-22). *"Hüküm geldi, yaptım"* demek bu gecenin tüm konusunun ihlali olurdu | **isimli engel — çekirdek turu gerekiyor** | Bunun yerine **hükmün ŞARTI çivilendi:** `kBridgeIsReferenceEquivalent` ancak ölçüm artefaktı ① medyan ② p95 ③ **kabul ölçütü** (ölçümü yapanın kendi beyanı) ④ yeniden-üretim komutu taşıyorsa `true` olabilir. Kapı *"kaç derece iyi"* sorusuna CEVAP VERMİYOR — o bir eşik ve eşik icadı yasak; zorladığı şey ölçütün ölçümün YANINDA beyan edilmesi. Karşıt yön de sınanıyor: `false` da ÖLÇÜLMÜŞ olmalı, ihtiyat beyanı değil. Sabotaj: bayrak ölçümsüz `true` → kırmızı, *"EŞİK İCADIDIR"* gerekçesiyle |
| L-253 | kusur | **P0** | **KAPILARIM SESSİZLİĞİ KORUYORDU, DÜRÜSTLÜĞÜ DEĞİL** (JabLab aktarımı: *bir dürüstlük kapısı koruduğu cümlenin SİLİNMESİNİ de geçerli sayarsa, dürüstlüğü değil sessizliği korur*). **İki sabotajla ölçtüm:** kaba silme (whyNot 5→1, notMeasured 4→1) 4 test yaktı ama **hepsi tesadüfen** — silinen belirli metinlere adıyla dokunan testlerdi. **Sinsi silme** (yalnız testlerin anmadığı kalemler: whyNot 5→2, notMeasured 4→2) → **yalnız 1 test yandı.** Yani 3 sınır ve 2 limit **sessizce kaldırılabiliyordu.** Ayrıca kural bir İÇERİK boşluğu da buldu: **7 metrik `coreLacksMeasureKind` sınıfındaydı (mesafe/yükseklik) ve dürüstlük kutusu o sınıftan HİÇ bahsetmiyordu** — kullanıcı test-başına gerekçeleri görüyor ama ailenin ÖZETİ boşluğu atlıyordu | **kapalı** | Alt sınır ("en az N kalem") KOYULMADI — L-239 tuzağı olurdu. Kural **kaynak→yüzey tamlığı**: hâlâ doğru olan her beyan edilmiş sınır yüzeyde görünmek ZORUNDA (dışlamalar · poz katmanları · whyNot kalemleri · engelli test gerekçeleri · notMeasured satırları). Artı `falsifiedIfBridged`in **eksik yarısı**: metrik hâlâ köprüsüzken satır silinirse sessizce *"artık ölçüyoruz"* iddia edilmiş olur. Artı **her engel SINIFI kutuda adlandırılmalı** → mesafe/yükseklik satırı eklendi. Sinsi sabotaj artık **3 kapı** yakıyor, gerekçesiyle |
| L-251 | kapı | P1 | **SEVK EDİLMİŞ İDDİA ÖLÇÜTÜ (J-133): *bir cümle sevk edildiyse, onu yanlışa çevirecek en MAKUL değişikliği sor; makulse kapı gerekir.*** İki iddiam ölçüldü, ikisi de makul bir değişiklikle yalanlanıyordu ve **hiçbirinin kapısı yoktu**: ① *"we have no figure for how much a reading can move on its own"* — bugün doğru (config'te MDC/tekrarlanabilirlik rakamı YOK, tarandı) ama bir MDC eşiği eklendiği gün YALAN olur, ve MDC eklemek açık yol haritasında. ② *"the measurement engine keeps a single tilt"* — **L-187 göçü tam bunu değiştirecek**, yani yalanlayan değişiklik makul değil BEKLENİYOR. **Kimse yalan söylemeye karar vermez; bir göç ya da bir iyileştirme yapar** | **kapalı** | ① `shipped_claim_test` config ağacında MDC-sınıfı anahtar arıyor; belirirse Progress cümlesinin yeniden yazılmasını ZORLUYOR. ② `notMeasured` satırları düz metinden `{claim, falsifiedIfBridged}`e geçti — motor sınırı anan satır, onu yalanlayacak metrikleri BEYAN eder; biri köprüye girdiği an kırmızı. **İlk tasarımımdaki gerekçe (*"fazla iddia eden taraf ispatlar"*) doğruydu ama EKSİKTİ:** negatif bir iddia da sevk edilmiş bir iddiadır. Sabotaj: MDC rakamı → ①  kırmızı · `trunk_lean` köprüye → ② kırmızı |
| L-252 | kusur | P2 | **Kapının KENDİ ÖLÇÜSÜ yalan söyledi:** `shipped_claim_test`teki MDC regex'inde kaçış yanlış yazılmıştı (`\\s` Dart kaynağında düz eğik-çizgi+s'ye çözülüyordu), yani desen HİÇ eşleşmiyordu. Kapı yeşildi ve **hiçbir şey ölçmüyordu.** Yalnız TERS SABOTAJ gösterdi — sabotaj 0 yakaladı ve o sıfır beni uyardı | **kapalı** | Kaçış düzeltildi; sabotaj artık 1 yakalıyor. **Ders: yeşil bir kapı, ölçtüğünü ölçtüğünü kanıtlamaz — sabotaj kapının ölçüsünü de sınar** |
| L-249 | kusur | P1 | **CAVEAT ENFLASYONU — olmayan bir sınırı beyan etmek dürüstlük değil gürültüdür** (aile sınırı, JabLab aktarımı). Ölçüldü: **① Profile'ın "Settings" kartı** *"no account, no sync and no reminder **in this build**"* diyordu — hesap ve senkron bir DERLEME EKSİĞİ değil **tasarım kararı** (gidecek sunucu yok ve olmayacak); üstelik *"in this build"* senkronun geleceğini İMA EDİYORDU. **② `MeasurementLimitsFootnote` "What Lissom doesn't do" sayfasında da basılıyordu** — o sayfanın KENDİSİ sınırlar sayfası; aynı beyanı orada tekrarlamak gerçek sınırların ağırlığını düşürür. **Dürüstlük kapıları tek yönlü kurulursa dürüstlüğün kendisi enflasyona uğrar: her şeye caveat eklenir, hiçbiri okunmaz, gerçek sınır sahte sınırların arasında kaybolur** | **kapalı** | ① tasarım kararı olarak yeniden yazıldı (*"not because they are missing, but because everything stays on this phone"*), gerçek sınır olan tek kalem (hatırlatıcı) isimli kaldı ② dipnot whyNot sayfasından KALDIRILDI. **Karşıt yön ölçüldü:** 3 canlı testin beyan ettiği sınırlar hâlâ GEÇERLİ (`overhead_reach` 0/7 kaynak · `deep_squat` anlaşma 23-39° vs eşik ≤14° · `active_straight_leg_raise` caveat TAŞIMIYOR — doğru) |
| L-250 | kusur | P1 | **İŞLETİM SİSTEMİ KATMANI hiçbir kapının bakmadığı katmandı** (*"ilk soru hangi kelimeler değil, hangi KATMANLAR"*). `wellness_lint` `config/**` + `lib/**` + `lissom_engine/lib/**` tarıyor; **`ios/Runner/Info.plist` ve Android manifest hiç taranmıyor** — oysa oradaki metinler İŞLETİM SİSTEMİNİN KENDİ diyaloğunda görünür ve uygulamanın dışına çıkan İLK cümledir. Bulgu: **`NSCameraUsageDescription` HİÇ YOK**, oysa `motion_camera` bağımlılık ve ürünün tüm önermesi kamerayla ölçüm; iOS izin isteyen uygulamayı bu anahtar olmadan ANINDA çökertir | **kapalı (bağlanarak)** | ⛔ Metin ŞİMDİ EKLENMEDİ, bilinçli: bugün capture yolu YOK (L-242) ve kamera izni beyan etmek **olmayan bir yeteneği beyan etmek** olurdu — L-249'un ikizi. Onun yerine `test/os_layer_test.dart` ikisini BİRBİRİNE BAĞLADI: capture yolu doğduğu an izin metni ZORUNLU olur; capture yokken izin metni OLMAMALI (simetrik). Bugün yeşil, yarın kendiliğinden kırmızı. **Sabotajla doğrulandı** (sahte `CameraController` → kapı kırmızı, adıyla) |
| L-248 | kapı | P1 | **TERS NEGATİF İKİZ kurulmadı — bende 0'dı** (JabLab aktarımı). Bugüne kadarki bütün ikizler *"düzeltme kaldırılırsa kırılır mı"* diye soruyordu; hiçbiri **kapının kendisi FAZLA GENİŞLERSE** ne olacağını sormuyordu. Gerekçe ÖLÇÜLDÜ: fazla geniş kapı bu depoda İKİ KEZ ödendi (L-237 `rose` deseni `roseDeepHover`ı eşledi · L-246 `will not`u vaat sandı) ve **iki kez de kapıyı geri daraltan şey bir ölçüm değil İNSANIN FARK ETMESİYDİ.** İkiz o refleksi mekanikleştiriyor. **Kural: her dar kapı, darlığını koruyan bir ikiz taşımalı** | **kapalı** | Python: `lint_selftest` içinde 4 canlı cümle DEPODAN okunur (21 egzersizin `pain` içeren güvenlik notu · ⑱ beyanı `accuracyStatement`+`limitsCopy` · `will not` reddi). Dart: `expectGateStaysNarrow(liveSentences)` — cümleler PARAMETRE, çağıran onları config+köprüden TÜRETİR (kopyalansalardı üründen ayrışır ve ikiz var olmayan bir metni korurdu). **ÜÇ ters sabotaj:** `pain` yasaklandı → ikiz ölecek güvenlik notunu ADIYLA gösterdi · koşullu-`will` muafiyeti kaldırıldı → ikiz **⑱ beyanını** kurtardı · defter-atfı deseni "parantez içi her şey"e genişletildi → ikiz whyNot gerekçesini yakaladı. Üçünde de geri alınınca yeşil |
| L-247 | kusur | P1 | **BU GECE GÜÇLENDİRDİĞİM SATIRLARIN KONTRASTINI ÖLÇMEMİŞTİM** (koordinatörün doğrudan sorusu, JabLab J-126). `contrast_test` tema stillerinin VARSAYILAN renklerini ölçüyordu; bir yüzey rengi **yerinde** geçebilir (`copyWith(color: …)`) ve o yol kapının DIŞINDAYDI. *Bir satıra dokunmak, o satırı denetlemek değildir* — 9 engelli test gerekçesini ve "What Lissom doesn't do"yu güçlendirdim, okunurluklarını hiç ölçmedim. Ayrıca ham `Color(0x…)` yasağı yalnız ELLE doğrulanmıştı (L-236'da iki kart-gradyanı tam böyle gizlenmişti) | **kapalı** | `test/rendered_contrast_test.dart` — ekranı GERÇEKTEN kurar, her `Text`in ETKİN stilini çözer (`DefaultTextStyle` + widget `style`ı) ve **en koyu zemine** karşı ölçer. Sonuç: **hepsi geçiyor** (L-234'ün yan etkisi — yani ŞANStı, kapı değildi). Sabotaj: yerinde-geçilen sönük renk → kırmızı. Ayrıca ham-renk yasağı KAPI oldu (`lib/app/` içinde `Color(0x…)` yasak, palet evi hariç) — sabotajla doğrulandı. Kapının SINIRI yazılı: yalnız KURULMUŞ widget'ları görür, o yüzden yüzey içeriğin tamamını alacak kadar uzun + her testte pozitif çapa |
| L-244 | kusur | P1 | **375pt kapısı YALNIZ PORTRE ölçüyordu** (kapı envanteri). `lib/` altında `setPreferredOrientations` HİÇ YOK ve `ios/Runner/Info.plist` üç yönü açıyor (`Portrait`·`LandscapeLeft`·`LandscapeRight`) → **telefonu çeviren kullanıcı hiç sınanmamış bir yerleşim görüyordu.** Kapı bir eksende çok iyiydi, ikinci eksende hiç bakılmamıştı — *yeşil bir kapı, bakılmayan bir alan üretir* | **kapalı (ölçüm)** | `test/orientation_test.dart` — dört sekmenin dördü de 812×375'te **taşmıyor**; yani bugün canlı kusur yok ama bu ŞANStı, kapı değildi. Yatayın desteklenip desteklenmeyeceği ürün kararı; kapı hüküm vermiyor, bugünün gerçeğini ölçüyor |
| L-245 | kusur | P1 | **`will` ÜÇ SINIF taşıyor, kapı hiçbirine bakmıyordu:** ① tarihsiz VAAT ② adı olan koşula bağlı (M-F-186 uyumlu, `promotionPath` deseni) ③ vaadin REDDİ (`will not`). Depodaki üç kullanımın üçü de ②/③ — ihlal yok ama **hiçbir şey onları o sınıfta tutmuyordu.** Kapı kelimeyi değil BİÇİMİ ölçmeli | **kapalı** | `CONDITIONAL_PROMISE` + `CONDITION` çapası (pencere YOK — koşul cümlesi tüm cümleyi yönetir; bedeli isimli). Sabotajla doğrulandı |
| L-246 | kusur | P1 | **Süzgeç PARÇA tarıyordu, CÜMLE değil.** Dart'ta `'…When that study is ' 'run, the number will appear here.'` TEK dizedir; `wellness_lint` bitişik literalleri AYRI tarıyordu → *"When" bir parçada, "will" ötekinde* ve kapı meşru bir biçimi ihlal sandı. **`roseDeepHover`ı `rose` sanan alt-dize hatasıyla (L-237) aynı sınıf: doğru şeyi YANLIŞ BİRİMDE ölçmek.** Ayrıca `will not` (vaadin reddi) ilk turda ihlal sayıldı — bir kapı doğru davranışı cezalandırıyorsa o kapı yanlıştır. **İkisi de kapıyı kurarken, kapının kendi koşusunda çıktı** | **kapalı** | Bitişik literaller birleştiriliyor; `will not` muaf. Tarama 1252 → 1233 metin (birleşme yüzünden AZALDI, kapsam BÜYÜDÜ) |
| L-242 | kusur | **P0** | **YAYIN ENVANTERİ (JabLab aktarımı): uygulamanın TAMAMI çalışan bir ölçüm döngüsünün ŞİMDİKİ ZAMANIYLA konuşuyordu**, oysa kullanıcı hiçbir ölçüm yapamıyor. Boşluğu YALNIZ Home'un tepesindeki beyan söylüyordu; Library ya da Progress'ten başlayan kullanıcı onu HİÇ görmüyordu. **Yokluk sessiz değil, KONUŞKAN**dı — 7 yüzey var olmayan bir mekanizmayı anlatıyordu. Sınıf *"beyan var üretici yok"*un TERSİ. En pahalısı Profile'daki gizlilik cümlesi: *"Your camera images and your readings stay on this phone"* — **sonucu DOĞRU, gerekçesi YANLIŞ** (gizlilik iddiası sağlam ama kamera görüntüsü hiç yok); *doğru sonucu yanlış gerekçeyle söylemek en zor yakalanan hatadır, kimse sonucu sorgulamaz.* Ayrıca `retest_countdown` **YAPILAMAYAN bir eyleme davet ediyordu** (*"Measure when you are ready"*) | **kapalı** | Envanter belgesi `docs/YAYIN-ENVANTERI-2026-08-07.md` (kanıt sütunlu, kullanıcı tarafından sorulmuş). Tek paylaşılan beyan `CaptureUnavailableNote` — 7 yerde yeniden anlatmak yeni bir ikiz üretirdi. Davet dili kaldırıldı, quick-start cümlesi MOTOR yeteneğini anlattığını söylüyor, gizlilik cümlesi gerekçesinden ayrıldı. Kapı: Library ve Progress beyanı TAŞIMAK ZORUNDA (`shell_test`) |
| L-243 | kusur | P2 | **Kendi "sayı değil kural" dersimi (L-239) iki yerde ihlal etmişim:** `progress_screen_test`te `noticeY < 400` sihirli sayısı — ekrana bir kart eklenince 429'a kaydı ve test ürün DOĞRU değişirken kırmızı yandı. Ayrıca sıra iddiaları dar-KISA yüzeyde ölçülüyordu: tembel liste hedefi hiç kurmadığı için test, ölçmek istediği şeyi değil EKRAN BOYUNU ölçüyordu | **kapalı** | `noticeY < ledgerY` (yapısal sıra) + `pinTallSurface` (375 GENİŞ × 2400) yalnız sıra iddiaları için; taşma/okunabilirlik kapıları 375×812'de kalıyor |
| L-240 | kusur | P1 | **OKUYUCUSUZ CONFIG ALANI SINIFINI, ONU KAPATIRKEN YAZDIĞIM OKUYUCUDA ÜRETTİM.** `LibraryIa` `tabs·home·families·whyNotPage` okuyor; `poseLibraryTiers` ve `navigationRules` **okunmuyordu**. Bedeli iki yerde ölçüldü: **(a)** tier 3'ün gerekçesi — *"pose models silently swap limb labels on inverted bodies with high confidence"* (aile bulgusu M-019) — **hiçbir yüzeyde yoktu**; yoga kutusu yalnız *"Inversions are demonstrated by the avatar only"* diyordu, yani OLGU vardı SEBEP yoktu. **(b)** `navigationRules.maxTaps*` beyan edilmiş ve ÖLÇÜLEBİLİR bir kısıttı, iki yıl hiç sınanmadı. Bu, JabLab'ın dersinin birebir örneği: *bir kusur sınıfını teşhis etmek, onu aynı commit'te üretmene engel değil* | **kapalı** | `PoseTier` + `NavigationRules` okuyucuları; tier okuyucusu KATI — tam skorlanmayan katman **gerekçesiz olamaz**. Tier'lar "What Lissom doesn't do" sayfasında yüzeye çıktı, M-019 gerekçesi İLK KEZ görünür. `maxTapsHomeToActiveCourse` kapıya bağlandı (sayı config'ten TÜRETİLİR); kapının sınırı yazılı: **dokunuş sayar, kaydırma saymaz** |
| L-241 | bulgu | P1 | **İki beyan edilmiş gezinme kuralı SESSİZCE karşılanmıyor:** `librarySearchRequired: true` (kütüphanede arama YOK) · `allCoursesIndexRequired: true` (tüm-kurslar dizini YOK). Okuyucu olmadığı için ihlal edilip edilmedikleri de bilinmiyordu. Bugün tek inşa edilmiş aile ve sıfır kurs varken arama kutusunun anlamı tartışmalı — ama kuralı config BEYAN ediyor | açık — **koordinatör/kurucu (IA kararı)** | — |
| L-239 | kusur | P1 | **TESTLERİM SAYIYI ÇİVİLİYORDU, KURALI DEĞİL** (JabLab aktarımı: *"fazla geniş bir test, ürün DOĞRU genişlerken kırmızıya döner"*). Ölçtüm: köprü 8/19'dan büyüdüğü an **en az 4 iddia kırılırdı** — `f.live.map(...) == ['active_straight_leg_raise','deep_squat','overhead_reach']` · `blocked hasLength(9)` · yüzeydeki `(3)` ve `(9)` sabitleri. Kırılma sebebi **bir şey bozulduğu için değil, İLERLEDİĞİ için** olurdu; ve düzeltme yolu "beklenen listeyi elle güncellemek", yani testin kapatmaya çalıştığı hatanın ta kendisi. Aynı sınıf `ia_test` (iddia sayıları), `library_screen_test` (aile kovaları), config kalem sayıları | **kapalı** | Sayılar DENKLİK kurallarına çevrildi: *canlı ⟺ birincil metriklerin hepsi köprüde* · *iddia canlı ⟺ `requires`ın hepsi köprüde* · *built+notBuilt == families* · yüzey sayıları `f.live.length`ten TÜRETİLİYOR · config kalem sayıları ham JSON uzunluğuyla kıyaslanıyor ("okuyucu kayıt düşürmüyor"). Her kuralın yanına iki-yönlü POZİTİF ÇAPA kondu (kural boş kümede de doğru). **SİMÜLASYONLA DOĞRULANDI:** `trunk_lean` köprüye eklendi → köprü 8→9, canlı 3/12→**5/12**, app 89/89 + motor 95/95 YEŞİL kaldı; sonra geri alındı |
| L-236 | kusur | P1 | **ÖRÜNTÜYÜ DEĞİL ÖRNEĞİ DÜZELTMİŞİM** (JabLab J-116 aktarımı). L-234'te tema token'larını düzelttim ve "kapandı" dedim; ölçtüm: `battery_summary_view.dart` **iki kart-gradyanı ucunu HAM `Color(0x…)` olarak** gömüyordu (#FCF5F0 · #F7F3F0) ve kontrast kapısının zemin listesi ELLE yazılmış olduğu için onları HİÇ ÖLÇMEDİ. Geçiyorlar (5,56 / 5,43) — **ama bu şanstı, kapı değildi.** Ayrıca `LissomColors.note` (#8B7F88) ölü token'dı ve metin olarak kullanılsaydı 3,75 ile doğardı (`LissomMono` ile aynı sınıf: ölü token, bir gün birinin eline geçen yüklü silah) | **kapalı** | İki renk token'a çevrildi ve zemin listesine girdi; `note` KALDIRILDI. Asıl düzeltme liste uzatmak DEĞİL: **BÜTÜNLÜK kapısı** eklendi — palet `lissom_theme.dart` KAYNAĞINDAN okunuyor ve her token üç kovadan birine (zemin · ön plan · süs/dolgu) girmek ZORUNDA; kovasız token kırmızı yanıyor. **Sabotajla doğrulandı** (yeni token → kapı adıyla kırmızı). Süs kovası muafiyet değil sınıflandırma: kaynak taraması o token'ların metin rengi olarak kullanılmadığını da sınıyor |
| L-237 | kusur | P2 | **Kapının KENDİ testinde yanlış-pozitif:** süs-token taraması sınırsız `contains('color: LissomColors.$token')` kullanıyordu ve `rose` deseni `roseDeepHover`u da eşliyordu. Kapı kendi kovasında olmayan bir ihlal bildirdi — ve bunu ancak KOŞUNCA gördüm. Tanımlayıcı eşleşmesi harf sınırı ister | **kapalı** | `RegExp('…\\.$token(?![A-Za-z0-9_])')` |
| L-238 | ölçüm | P2 | **Hiyerarşi üst sınırı ÖLÇÜLDÜ** (JabLab'ın ikinci testi): `ink` 12,32 ↔ `bodySecondary` 5,87 → **2,1× ayrım**, yani okunurluk uğruna hiyerarşi feda EDİLMEMİŞ. Kapı artık iki kısıtı birlikte tutuyor: **alt sınır okunurluk** (WCAG 4.5) · **üst sınır hiyerarşi** (>2× ayrım). Not: bu palette ÜÇÜNCÜ bir luminans katmanı mümkün değil (4.5 tabanı ile `bodySecondary` arasında yer yok) — üçüncü katman boyut+ikon+sözcükle taşınıyor | ölçüldü | `contrast_test.dart` |
| L-234 | kusur | **P0** | **KONTRAST HİÇ ÖLÇÜLMEMİŞTİ** (JabLab J-114 aktarımı). Ölçüm: ölçüm-sınırı beyanı gradyan üstünde **2,01:1** · hüküm sınırı + engel gerekçesi **2,57** · sönük iddia metni ve eyebrow **2,94** · `videocam_off`/`block` durum ikonu **2,94** (metin-dışı eşik 3.0) · `roseDeep` metin olarak **3,58**. **En acısı: açık ihlal ⑱'in kapanışı olan beyan, uygulamanın EN OKUNMAZ metniydi** — oradaydı, doğruydu, görünmüyordu. Bu, L-231'in (metin doğruydu, okunmuyordu) renk eksenindeki ikizi | **kapalı** | Palet İCAT EDİLMEDİ: ölçüldü ki 12,5px'i 4.5'e çıkarmak `metaMono`yu da `labelMuted`i de ~#6C626B'ye (=`bodySecondary`) taşıyor — üç token tek renge çöküyor, yani "WCAG-uyumlu sönük" bu palette body rengiyle aynı şey. Bunun yerine **doğru token seçildi**; meşru, çünkü anlam renge bağlı DEĞİL (ikon + "Not in this build ·" sözcüğü taşıyor, WCAG 1.4.1). Tek palet değişikliği `roseDeepHover` #8E5A73→#86556D (ton+doygunluk aynen, yalnız açıklık; eşiğe TEĞET geçen #87566E=4,498 bilerek reddedildi). `primary` artık metin değil ikon rengi · beyan kartı `ink` kullanıyor (peach ucunda `bodySecondary` bile 3,76) · `LissomMono` kaldırıldı (L-224+L-234+L-222 üçü birden). Kapı `test/contrast_test.dart` (6 test, alfa ZEMİNE bindiriliyor, sabotaj dahil). Commit `0315fe8` |
| L-235 | bulgu | P2 | **Dört-katman görsel ayrımının yükü artık YALNIZ ikon+sözcükte.** L-234 sönük tonları okunabilir seviyeye çıkardığı için canlı/ölü iddia ve engelli/canlı test satırları arasındaki LUMİNANS farkı azaldı. Anlam kaybı YOK (ikon + açık sözcük taşıyor) ama görsel hiyerarşi zayıfladı. Bu palette luminansla de-emphasis + WCAG uyumu AYNI ANDA mümkün değil — ölçüldü | açık — **tasarım yönü, koordinatör/kurucu** | — |
| L-232 | kusur | P1 | **Muafiyet denetimi "gerekçe ESKİDİ"yi ölçüyordu, "gerekçenin işaret ettiği şey HİÇ YOKTU"yu değil** (JabLab `engineDriven` aktarımı). İki delik: **(a) vakum-doğru ONAY** — metrik hiç geçerli ölçüm üretmezse iki mod da tamamen NaN olur, `np.array_equal(equal_nan=True)` TRUE döner ve muafiyet "bit-aynı, doğrulandı" işaretlenir → **hiçbir şey ölçmeyen metrik kendi muafiyetini onaylıyordu**; veriyi (`valid`/`vmr`) zaten hesaplıyorduk, hükme sokmuyorduk. **(b) YETİM muafiyet** — `EXPECTED_INVARIANT.get(md.id)` yalnız `defs` üzerinde dönüyor; sözlükte olup tanımlarda olmayan anahtar hiç ziyaret edilmez (bugün isabet yok, ölçüldü — ama izlenmiyordu). **`stale_exemptions`ı kurmuş olmam beni bu sınıftan KORUMADI** | **kapalı** | İki denetim eklendi; hüküm saf fonksiyona çıkarıldı (`audit_exemptions`) çünkü araç bu makinede HİÇ koşamıyor (fixture yok + rig bayat, M-F-280) — sınanamayan kapı koruma sanılan boşluktur. `tools/two_mode_selftest.py`: 5 vaka + pozitif çapa, yeşil. Commit `5bb98aa` |
| L-233 | kusur | **P0** | **CANLI iddia HÜKÜM SINIRI TAŞIMIYORDU** (JabLab J-113 aktarımı — bir yeteneği olduğundan GENİŞ yazmak; hata kullanıcının ALEYHİNE). Ölçüldü: *"Shoulder, hip and knee angles…"* tek cümlesi **iki farklı hüküm sınıfını** topluyor — `overhead_reach` (omuz) ve `deep_squat` (diz) `measurementOnly` (referans YOK), `active_straight_leg_raise` (kalça) BANTLI. Kullanıcı *"omuz açımı ölçüyorsunuz"*u *"ve nasıl olduğunu söyleyeceksiniz"* diye okur; omuz için hiçbir zaman söylemiyoruz. Kutunun asimetrisi buydu: `notMeasured` uzun+gerekçeli, `measured` SINIRSIZ. Kıyasın kapalı olduğu bir üründe *"ölçtük"* ↔ *"iyi/kötü dedik"* mesafesi korunan şeyin ta kendisi | **kapalı** | `AppFacts.verdictNoteFor` sınırı bataryadan TÜRETİYOR (hepsi bantlı / hepsi referanssız / KARIŞIK); terfi olursa cümle kendiliğinden değişir, elle yazılsaydı bayatlardı. 2 yeni kapı İKİ YÖNLÜ: canlı iddia not taşımalı + karışık sınıfı gizlememeli · ölü iddiaya not ASILMAZ · yalnız-bantlı küme "no verdict" DEMEMELİ. Commit `74f79e0` |
| L-230 | kusur | **P0** | **DÜRÜSTLÜK KUTUSUNUN KENDİSİ, UYGULAMANIN EN AZ DÜRÜST YÜZEYİYDİ** (Ostinato O-040 aktarımı, koordinatör sordu). `assessment_battery` honestyBox'ının 3 `measured` iddiasından **2'si kabukta canlı DEĞİLDİ**: *"…sagittal and frontal planes (… trunk, shank)"* → `trunk_lean`/`tibia_inclination` köprülü değil, üstelik köprü uzayı `isotropic` olduğu için **"frontal plane" HİÇBİR metrik için doğru değildi**; *"Hold duration and gross balance"* → `hold_duration` faz-türevi (L-220). Yalnız sol/sağ iddiası gerçekti. Bir iddia listesi, kendini doğrulayan mekanizma olmadan pazarlama listesinden ayırt edilemez | **kapalı** | `honestyBox.measured` düz metinden **kanıt taşıyan nesneye** geçti (`{claim, requires:[metrik…]}`); inşa edilmiş ailede `requires` ZORUNLU → dayanaksız iddia config'e giremez. `AppFacts.blockerForClaim` iddiayı köprüye karşı doğruluyor, gerekçe köprünün KENDİ metninden (`blockerTextFor`) geliyor. Canlı olmayan iddia SİLİNMİYOR — sönük ikon + isimli gerekçe. "frontal plane" iddiası kaldırıldı ve yokluğu `notMeasured`da İSİMLİ (sessizce silmek = iddiayı gizlice geri çekmek). 4 yeni kapı, İDDİA↔YETENEK iki yönlü (TAM 2 canlı + TAM 2 sönük). Commit `c2d5e41` |
| L-231 | kusur | P2 | **Sönük iddia satırında ÇİFT TİRE:** *"Not in this build **—** Hold time **—** this test is timed…"* — engel metni zaten `<özne> — <gerekçe>` biçiminde geldiği için ayraç olarak tire kullanmak cümleyi okunmaz yapıyordu. Testler göremedi (metin VARDI, doğruydu, yalnız okunmuyordu); **simülatör ekranı yakaladı** | **kapalı** | Ayraç orta-noktaya çevrildi (`·`) |
| L-229 | kusur | **P0** | **`yet` vaat dili 3 kullanıcı-görünür yerde — ve ASIL bulgu, KAPININ KENDİSİNDEKİ İKİ KÖRLÜK.** İhlaller: `summary_strings.dart:36/38` (*"Measured — not compared **yet**"*, *"Why we cannot compare it **yet**"*) + `lissom-assessment.v1.json` `userText` (İKİ `yet`, doğrudan sonuç ekranına giden alan). Anlam ihlali üsluptan ağır: *"not compared yet"*, kıyas yapmama kararını **tasarlanmış bir hâlden eksik bir hâle** indiriyordu. **Kapı neden göremedi:** ① `copy_gate.dart` RENDER EDİLMİŞ ağacı tarıyor, `summary_strings` → `BatterySummaryView` ve o kabuktan ERİŞİLEMEZ (L-225) — *ulaşılamayan ama yine de GÖNDERİLEN kodu ağaç-tarayan kapı tanımı gereği göremez*; ② config `userText` `USER_FACING_KEYS`te HİÇ YOKTU, o alan bugüne dek hiçbir denetimden geçmemişti. Ayrıca `SummaryStrings.forbiddenSurfaceWords` `copy_gate`in İKİZİYDİ ve içinde `yet` YOKTU — dosya iki ihlal taşırken kendi listesiyle yeşil yanıyordu. **Kuralı `library_screen.dart`ta doğru yazmış olmam iki dosya öteki ihlali engellemedi: kural yorumda yaşarsa yalnız o dosyada yaşar (aile dersi 8).** Koordinatör buldu, ben değil | **kapalı** | `wellness_lint.py` `PROMISE` kategorisi (kaynak düzeyi, erişilebilirlikten BAĞIMSIZ, olumsuzlama kaçışı yok) + `userText`/`setupNote`/`framingRule` `USER_FACING_KEYS`e eklendi + ikiz sözlük SİLİNDİ, tek kaynak `copy_gate.kBannedSurfaceCopy` + `battery_summary_view_test` tam kapıya bağlandı. **Sabotaj: `yet` geri konduğunda kaynak süzgeci VE widget kapısı ikisi de kırmızı.** Commit `b31deb0` |
| L-187 | ölçüm | P1 | **L-031 Dart uzay göçünün (seçenek C) kapsamı ÖLÇÜLDÜ** — koordinatör talebi. **Dosya:** çekirdek tarafı **2 dosya** (`geometry/joint_angles.dart` — `JointSpec` bugün düzlem/projeksiyon parametresi TAŞIMIYOR; `geometry/normalization.dart` — türetilmiş eksenler). `vec3.dart` DEĞİŞMEZ: `cross`/`dot`/`normalized` zaten var → brief'in *"ek landmark gerekmez"* fizibilitesi Dart tarafında da doğrulandı. **Lissom tarafı TEK dosya** (`metric_bridge.dart`); uzay varsayımını taşıyan başka dosya yok (tarandı). **Metrik:** 11 engelli metriğin **yalnız 4'ünü** açar (düzlem-ayrımı sınıfı: `trunk_lean` · `trunk_lateral_tilt` · `tibia_inclination` L/R); kalan 7 ölçü-tipi sınıfı ve göç onlara DOKUNMAZ. **Test: 3/12 → 7/12.** Açılan: `overhead_squat` · `ankle_dorsiflexion` · `hip_hinge` · `lateral_bend`. Açılmayan 5: `hamstring_reach`/`forward_lunge`/`thoracic_rotation` (ölçü-tipi) + `plank_hold`/`single_leg_balance` (faz-türevi, L-220). **Asıl ödül metrik sayısı değil:** `kBridgeIsReferenceEquivalent` bugün `false` ve göç onu `true` yapabilecek TEK iş — köprünün sayısı ilk kez referans-derecesi sunulabilir hâle gelir ⚠️ **BU NUMARA İKİ KAYITTA — atıf çözerken İKİSİNE de bak (L-305; yeniden numaralandırma YOK: bir numarayı değiştirmek ona işaret eden HER atfı sessizce yanlış yapar).** | ölçüldü — karar koordinatörde | Ölçüm `Battery` + `kUnbridgedMetrics` + `kMetricBindings` üzerinden TÜRETİLDİ, elle sayılmadı |
| L-219 | kusur | P1 | **`excluded` bloğunun HİÇ OKUYUCUSU YOKTU** — `Battery.parse` onu ayrıştırmıyordu; iki test (`hip_internal_external_rotation`, `cervical_rotation`) ÖLÇÜLMÜŞ gerekçeyle bataryadan çıkarılmış ama kullanıcı bunu hiçbir yüzeyde göremiyordu. "Neyi ölçmediğimizi söylemek" bu ürünün konumlandırması olduğu için bu, süs alan değil kayıp yüzey. L-181 sınıfı | **kapalı** | `battery.dart` `_parseExcluded` + `whyNotTopic` BEYAN alanı (metin benzerliğinden tahmin YOK); `what_lissom_doesnt_do.dart` bağlanmamış dışlamaya kendi bölümünü veriyor. Kanıt: `docs/kanit/sim-375pt-*` — `Cervical rotation` artık yüzeyde. Test: `ia_test.dart` grubu + `family_page_test.dart` |
| L-220 | kusur | **P0** | **HAM METRİK ID + GELİŞTİRİCİ JARGONU KULLANICI YÜZEYİNDE.** `plank_hold` ve `single_leg_balance` kartlarında *"measurement bridge not declared (hold_duration)"* yazıyordu. Kök neden: `hold_duration` geometrik değil (config `derivedMeasures.source = phase`) ve o blok da okunmuyordu; ayrıca kapsam kapısı gereken metrikleri `known` kümesine göre SÜZDÜĞÜ için `hold_duration`ı hiç görmüyordu — yokluk iddiasını vakum-doğru yapan bir süzgeç (aile dersi 4). **71 yeşil test görmedi, EKRAN yakaladı** | **kapalı** | `DerivedMeasure` okuyucusu + `BridgeBlocker.measureIsPhaseDerived`; gerekçe artık *"Hold time — this test is timed by the session rather than measured from camera angles…"* ve "çalışmıyor" İDDİA ETMİYOR (faz makinesinin bunu üretip üretmediği ÖLÇÜLMEDİ). Beyansız dal ham id BASMIYOR. Kapı: `family_page_test.dart` — hiçbir gerekçede config'ten türetilen id geçemez. Kanıt: `docs/kanit/sim-375pt-batarya-engelli-gerekceler-2026-08-07.png` |
| L-221 | kusur | P1 | **`wellness_lint.py` DART'A HİÇ BAKMIYORDU** — yalnız `.json`/`.arb` tarıyordu, oysa yüzey kopyasının büyük kısmı Dart'ta yaşıyor. Önceki tur bunu "yeni Dart kopyası elle de kontrol edildi" diye kayda geçmişti; elle kontrol bir kapı değildir | **kapalı** | `DART_DIRS` + yorum-silen string-sabiti çıkarıcı; tarama 500 → **1250 metin**. İLK KOŞUŞTA bir isabet: `progress_screen.dart` "treat it as a floor" — masum anlamda da olsa `treat` mağaza taramasının kelimesi, yeniden yazıldı. Boş-tarama koruması eklendi (Dart'tan hiç string çıkmazsa çıkarıcı bozuktur → kırmızı) |
| L-222 | risk | P1 | **`google_fonts` yazı tiplerini ÇALIŞMA ANINDA indiriyor** (`fonts.gstatic.com`). İki sonuç: (a) çevrimdışı ilk açılışta tasarımın tipografisi hiç yüklenmez, uygulama sessizce yedek fontla açılır; (b) kullanıcı hiçbir şey yapmadan üçüncü bir sunucuya bağlantı gider — "her şey cihazda" diyen bir üründe gizlilik beyanının kapsamına girer. Ayrıca golden ekran kanıtını tipografi açısından değersiz kılıyor (Ahem bloklarıyla çiziliyor) | **açık — KOORDİNATÖRDE** | Panzehir: üç OFL yazı tipini pakete gömmek (Newsreader · Nunito Sans · IBM Plex Mono). Lisans + bağımlılık + app boyutu kararı olduğu için TEK TARAFLI YAPILMADI. `test/flutter_test_config.dart` bulguyu yazılı taşıyor |
| L-223 | kusur | P1 | **DAHİLİ DEFTER ATFI KULLANICI YÜZEYİNDE:** `excluded[].reason` metinleri `(L-006)` ile bitiyordu ve "What Lissom doesn't do" sayfasında görüldü. Ham metrik-id sızıntısıyla aynı sınıf — dahili sözlüğün yüzeye düşmesi. Yine test değil EKRAN yakaladı | **kapalı** | Atıf `record` alanına taşındı (silinmedi, izlenebilirlik korundu); `copy_gate.dart` artık `(L-006)`/`(M-F-71)`/`(J-064)` sınıfı her atfı kırmızı yakıyor. Test: `family_page_test.dart` |
| L-224 | kusur | P2 | **`LissomMono` (IBM Plex Mono token) hiç kullanılmıyor** — tanımlı, çağıran yok. Kullanılırsa `google_fonts` üçüncü bir yazı tipini daha çalışma anında indirmeye çalışır (L-222'yi büyütür) | açık | — |
| L-225 | kusur | P2 | **`BatterySummaryView` erişilemez** — hiçbir yol oraya çıkmıyor; batarya koşusu olmadan `BatterySummary` üretilemiyor. Sahte veriyle giriş açmak yasak olduğu için bu tur wire EDİLMEDİ; canlı-tur ekranı gelene kadar ölü yüzey (aile dersi 6: repliğin varlığı tetiğinin varlığı değildir) | açık — canlı-capture UI'a bağlı | — |
| L-226 | bulgu | P2 | **Yeniden-ölçüm aralığı (`retest_countdown`in X'i) HİÇBİR config'te tanımlı değil** — `lissom-assessment`, `assessment-blocks`, `lissom-phases`, `library` dosyalarının hiçbirinde yok. §5.2 hükmü *"yeniden ölçüm: X gün"* örneği veriyor ama o X'in artefaktı yok; eşik icadı yasak olduğu için Home'da vade YAZILMADI ve aralığın tanımsız olduğu kullanıcıya SÖYLENDİ. Hüküm ihlal edilmedi, RUHU uygulandı (davetin sayıya ihtiyacı yok) | açık — koordinatörde | — |
| L-227 | bulgu | P2 | **`disclaimers.scoreScreen` metni ürünün kendi hükümleriyle ÇELİŞİYOR:** *"This **score** reflects your movement pattern **compared with your own history**"* — oysa K8 skor vermeyi, Progress'in tasarlanmış hâli de kıyaslamayı yasaklıyor. Config'te yazıyor diye basmak, dürüstlük ihlalini config'e havale etmek olurdu; kalıcı beyan için `measurementLimits` kullanıldı | açık — koordinatörde (yasal-metin revizyonu) | — |
| L-001 | risk | **P0** | Skor kovalayıp aşırı zorlama riski + tek kamerayla 3D ölçüm yanılsaması; 'yaklaşık' dili ve ağrı-durdurma akışı tavizsiz. Yoga içerik katmanı (D4) medikal-dil süzgecinden geçer | açık | — |
| L-002 | risk | P1 | GOWOD'un mobilite testinin mekanizması belirsizdi (CV mi öz-değerlendirme mi) — konumlandırma iddiamız buna bağlıydı | **kapalı** | 2026-07-26 G0 fan-out: GOWOD'un kendi "how it works" sayfası testin **CV OLMADIĞINI** söylüyor — kullanıcı referans videoyu izleyip **slider ile kendi kendini değerlendiriyor**. Lissom'un "gerçekten ölçer" farkı kanıtlandı. Kayıt: `research/06-rakip-dogrulama-turu.md` |
| L-003 | risk | P1 | 2D tek kamera iç/dış rotasyonu güvenilir ölçemez → skor bandı politikası gerekiyor | **kısmi** | Literatür doğrulandı (`research/05`, PMC10635560: transvers düzlem twist "nadiren güvenilir çıkarılabilir"). Karar: hip/shoulder rotasyonu V1'e HİÇ alınmadı (L-006); thoracic rotation Sınıf C + dolaylı metrik. Bant politikası G2 PRD'de kesinleşir |
| L-004 | risk | P1 | MediaPipe "Preview" statülü — model sürümü pinlenmezse davranış sessizce değişir | **kapalı** | Aile-geneli M-L-01 olarak kanıtlandı ve çözüldü: `full` varyantında `/latest/` ile `/1/` FARKLI hash veriyor (aynı dosya boyutu!). Pin + SHA-256 manifesti: `motion-core/lib/tools/fixture_pipeline/models/MODELS.md`; hash her fixture JSON'una gömülüyor |
| L-005 | risk | **P0** | Assessment doğrulama çalışması yapılmadan "measures" iddiası kurulamaz | açık | Kapı protokolü §3.5 + §6'da sabitlendi: iddia, bilinen-açı referanslı iç doğrulama (n≥20-30) olmadan kurulamaz. Çekim listesi Tur 4 bunun ilk adımı |
| L-006 | karar | P1 | **Hip internal/external rotation ve cervical rotation V1 test setinden ÇIKARILDI** (kapıya bile alınmadı). Gerekçe: tek kamera 2D bu hareketleri ölçemez; ölçemediğimiz şeyi ölçüyormuş gibi göstermek L-001'in ta kendisi | **kapalı** | `G1-V0-KAPI-PROTOKOLU.md §1`; kurucu adına karar (`20-URETIM-SURECI §0` yetkisi) |
| L-007 | karar | P1 | **Araştırma çıktısındaki çelişki hakemlendi:** JMIR e82412 "yan çekim kötü, diyagonal iyi" der; PLOS ONE 2023 "sagittal kamera-tarafı en iyi (1.5-4°)" der. Çelişki görünürde — JMIR **tekrar sayımı** doğruluğunu ölçmüş, eklem açısını değil. Lissom bir ÖLÇÜM ürünü → **sagittal öncelikli**, ama 90 cm değil **180-200 cm** | **kapalı** | Kapı protokolü rev.2 §1; `research/01` |
| L-008 | karar | P1 | **G1 kapısı ikiye bölündü:** G1-a (sayısal doğruluk, sentetik iskelet, kurucusuz) + G1-b (görüntü güvenilirliği, gerçek video, kurucu çekimi). Gerekçe: birleşik kapı, çekim gelene kadar TÜM ilerlemeyi bloke ederdi | **kapalı** | Kapı protokolü §0 |
| L-009 | bulgu | **P1** | **Ham 3D eklem açısı ROM uçlarında ±5.71° sistematik hata veriyor.** Kök neden: omuz genişliği (0.40 m) ≠ kalça genişliği (0.30 m) → hip→shoulder vektörüne sahte yanal bileşen karışıyor. Hata 0° ve 180°'de maksimum, yani "çok kısıtlı" ve "çok esnek" kullanıcılarda en yanıltıcı | **kapalı** | G1-a ölçümü: ham 3D max hata **5.71°**, sagittal izdüşümle **0.00°**. Düzeltme: açı metriklerinde `plane` alanı config seviyesinde ZORUNLU (`measures.py` yükleme anında reddediyor) |
| L-010 | bulgu | **P1** | **Gövde açıları tek taraflı landmark çiftiyle ölçülemez.** `LEFT_HIP→LEFT_SHOULDER` vektörü gövde hattı değil; frontal düzlemde 11.31°'ye varan sahte yana-eğim üretiyor (gövde öne eğildikçe büyüyor) | **kapalı** | G1-a: `trunk_lateral_tilt` hatası **11.31°** → türetilmiş orta-hat landmark'larıyla (`MID_HIP`/`MID_SHOULDER`) **0.00°**. `landmarks.VIRTUAL` + config güncellemesi |
| L-011 | bulgu | **P0→kapalı** | **Ölü metrik yakalandı:** `angle_vertical` + `transverse` kombinasyonu matematiksel olarak HER ZAMAN 90° döner (transverse düzlem dikey ekseni sıfırlar). `shoulder_line_rotation` bu tanımla sabit değer üretiyordu — G1-b'ye böyle girseydi thoracic rotation testi makul GÖRÜNEN sabit bir skor üretir, kimse fark etmezdi. Sessiz yanlışların en tehlikeli sınıfı | **kapalı** | Ölçüm: yaw 0/15/30/45/90° → hepsinde tam 90.0000°. Üç katmanlı düzeltme: (1) kombinasyon yükleme anında yasaklandı, (2) metrik `shoulder_line_foreshortening` (frontal izdüşüm oranı) olarak yeniden tanımlandı, (3) kapıya A9 ölü-metrik kriteri eklendi |
| L-012 | karar | P1 | **Kapının kendi zayıflığı kapatıldı (L-033 dersi):** A1-A4 yalnız beklenen-değer formülü olan metrikleri test ediyordu; formülü olmayan metrikler hiç sınanmıyordu — L-011 tam bu boşluktan geçmişti. A9 kriteri eklendi: hiçbir bozucuya tepki vermeyen metrik = KALDI; kapsam dışı metrikler raporda isimle listeleniyor | **kapalı** | Kapı protokolü rev.3 A9; koşum çıktısı 4 kapsam-dışı metriği raporluyor |
| L-013 | görev | P1 | **A5 yaw duyarlılığı kalibrasyon toleransını belirledi:** gövde metrikleri kamera hizası sapmasına en duyarlı (`trunk_lateral_tilt` ±10°'de 5.73°, ±15°'de 8.50°); sagittal eklem açıları dayanıklı (±15°'de <1.6°). Kalibrasyon sihirbazı **≤10° sapma** dayatmalı, ≤5° hedeflemeli | açık (G2 PRD'ye girecek) | Ölçüm tablosu: `docs/G1-V0-KAPI-RAPORU.md` |
| L-014 | görev | P1 | **A7/A8 ölçülmedi:** state-machine henüz yazılmadı, kapı bu iki kriteri boş bıraktı. G1-a "ŞARTLI GEÇTİ" hükmü bu eksikle verildi | açık | — |
| L-015 | risk | P1 | **Fixture çeşitlilik açığı:** tüm çekimler tek kişiyle (`s1`) yapılırsa kapı vücut-tipi yanlılığıyla geçer. Sentetik testte ölçek bağımsızlığı kanıtlandı (A4=0.00°) ama gerçek vücut çeşitliliği ≠ ölçek çarpanı | açık (G8'e kadar kapanmalı) | — |
| L-016 | risk | P1 | **4 metrik doğruluk garantisi olmadan taşınıyor:** `heel_rise_*`, `reach_depth`, `shoulder_line_foreshortening` için beklenen-değer formülü yok; yalnız A9 (ölü değil) korumasındalar. Bunlar `distance_norm` tipinde ve sentetik üreteçten türetilebilir — A1 kapsamına alınmalı | **kapalı** (reach_depth hariç) | Kapı kapsamı genişletildi: beklenen-değer formülü olmayan metrikler artık A4/A5/A9'a giriyor (eşleştirme anahtarı hedef değer yerine taranan poz-alanı değeri oldu). `heel_rise_*`, `knee_height_*`, `shoulder_line_foreshortening` için **analitik** beklentiler yazıldı (kinematikten türetildi, üreteç kodunun kopyası değil) → A1 hâlâ 0.000°. Kalan tek kapsam-dışı: `reach_depth` — analitik beklentisi üretecin kinematik zincirini tekrar etmek olurdu (tautoloji); A4/A5/A9 koruması yeterli sayıldı, raporda isimle görünüyor |
| L-017 | risk | **P0** | **Gelen aile dersi (Gravita M-019):** MediaPipe ters/atipik vücut duruşunda güveni DÜŞÜRMÜYOR — kol↔bacak etiketlerini sessizce takas edip yüksek güven (%0,93) veriyor; iskelet simetrik olduğu için gözle de fark edilmiyor. **Lissom'u doğrudan ilgilendirir:** yoga içerik katmanında ters/yere yakın pozlar (down dog, child's pose, forward fold'un derin hâli) var. Güven kapımız (A6, 0 sızıntı) bu hata sınıfını YAKALAYAMAZ — güven yüksek kalıyor | açık | — |
| L-018 | risk | P1 | **Gelen aile dersi (Choreia):** "DTW park etme" — geniş bantlı zaman hizalayıcı, hareketsiz duran kullanıcıya yüksek benzerlik skoru verebiliyor (0.938 → warp cezasıyla 0.775). Lissom V1'de DTW yok ama seans rehberliğinde poz-tutuş karşılaştırması yapılırsa aynı tuzak geçerli: hiç hareket etmeyen kullanıcı "mükemmel tutuş" almamalı | açık | — |
| L-019 | görev | P1 | **Lissom aday testlerinin yapısal-tutarlılık denetimine tabi tutulması gerekiyor** (L-017'nin sonucu). Choreia oturumu `StructuralValidator`'ı Dart çekirdeğine yazmış — Lissom test motoru onu kullanmalı, kendi kontrolünü yazmamalı. Özellikle `hamstring_reach` (derin öne eğilme) ve yoga paketleri risk altında | **kapalı** | Kurucu kararı (M-F-05/M-F-06): `StructuralValidator` ÇEKİRDEKTEN tüketilir, Lissom kendi kontrolünü YAZMAZ. G2 PRD'ye bağımlılık olarak işlendi |
| L-020 | risk | **P0** | **ÇELİŞKİ: üç app "modelin sol/sağ etiketine güvenme" diyor, Lissom sağ-sol farkını ÜRÜN VAADİ olarak satıyor.** Gravita ADR-003 (kurallar taraf-agnostik, taraf geometrik seçilir) · JabLab ADR-004 (motor `lead/rear` ile çalışır, `left/right` ile değil) · Choreia K6 (ayna modu varsayılan, sol/sağ merkezî çözülür). Lissom'un planı §6'da "sağ-sol farkı" ölçülebilecekler listesinde ve bölgesel skorun bileşeni. Ayrıca L-017 (M-019): model ters/atipik duruşta kol↔bacak etiketini yüksek güvenle takas ediyor. Sol/sağ kararı verilmeden simetri metriği yazılamaz | **kapalı** | **Kurucu hakemliği (M-F-06): simetri vaadi KORUNUYOR, şartlı.** Kural: modelin `left/right` etiketine ham güven YOK; taraf kimliği geometrik + StructuralValidator-temiz akışta kurulur; L/R kullanıcıya yalnız kalibrasyon pozunda eşleme kurulduktan SONRA raporlanır. Gerekçe: Lissom'un ölçüm bağlamı (kalibre, frontal/sagittal, dik, statik) tam da L/R'nin güvenilir olduğu bölge — diğer 3 app'in tuzağı hareketli/ters/atipik duruştan geliyor. Koşullar sağlanmazsa simetri skoru ÜRETİLMEZ |
| L-021 | risk | **P0** | **Minimum anlamlı değişim (MDC) eşiği yok — "gelişme" iddiasının temeli eksik.** Ürünün çekirdek döngüsü ölç→programla→4 hafta sonra yeniden ölç. Test-retest değişkenliği hedefi ≤5° (kapı B3); yani 4 hafta sonraki 3°'lik artış gürültü mü gelişme mi belli değil. Halo verisi durumu ağırlaştırıyor: tekrarlanabilirlik hareket-kısıtlı grupta %35 daha kötü — en çok gelişmesi beklenen grupta ölçüm en gürültülü. MDC eşiği G1-b ölçümünden türetilmeli, ondan önce hiçbir "geliştin" mesajı gösterilemez | açık | — |
| L-022 | görev | **P0** | **Köken (provenance) alanları kararı yok** (Gravita ADR-005 devralınmalı): her `TestAttempt` kaydına model varyantı + model sürümü/sha + kural seti sürümü + metrik config sürümü + kalibrasyon profili yazılmalı. Aksi halde model güncellenince eski ve yeni ölçüm kıyaslanamaz ve "gelişme" model gürültüsü olabilir. Lissom bu riski en çok taşıyan app: tüm değer önerisi zaman-içi karşılaştırma | **kapalı** (karar) · açık (uygulama) | Kurucu kararı M-F-07: provenance ZORUNLU. Her `TestAttempt`: model varyantı + model sürümü/sha + kural seti sürümü + metrik config sürümü + kalibrasyon profili. G2 PRD veri modeline girdi |
| L-023 | risk | P1 | **Varyant-başına güven eşiği uygulanmadı** (aile kuralı M-018/M-020: `visibility` varyantlar arası kıyaslanamaz). Lissom assessment'ta `heavy`, günlük seansta `full` kullanacak — iki varyant, tek eşik (0,6). Cihaz `lite`'a düşerse eşik sessizce başka bir şeye dönüşür. Choreia çekirdeğe `ConfidenceGate.forVariant` yazmış; Lissom config'i bunu kullanmalı | **kapalı** (karar) · açık (uygulama) | Kurucu kararı: `ConfidenceGate.forVariant` ÇEKİRDEKTEN tüketilir (M-018/M-020 aile kuralı). Lissom kendi varyant eşiği tanımlamaz |
| L-024 | görev | P1 | **Sesli koç gecikme kalibrasyonu kararı yok** (Choreia K4 karşılığı: route-başına ses gecikmesi kalibrasyonu zorunlu). Lissom tutuş sayıyor ("hold for two seconds", 30 sn denge) ve sesli sayım Bluetooth kulaklıkta ~200 ms gecikebilir → sayım kayar, kullanıcı erken/geç bırakır. Choreia bunu beat için çözdü; Lissom sayım/tutuş için çözmeli | **kapalı** (karar) · açık (uygulama) | Kurucu kararı M-F-08: ses-gecikme kalibrasyonu **core modülü** olur (Choreia K4 deseni aileye taşındı). Lissom tutuş/sayım hattı bu modülü tüketir |
| L-025 | karar | P1 | **Kalibrasyonsuz skor gösterilmez kuralı Lissom'da sertleştirilmedi** (Choreia C-012/K8 karşılığı). Test bataryası config'inde bandlar "UNVALIDATED" etiketli ama gösterim yasağı kural değil, not seviyesinde. Öneri: G1-b + iç doğrulama çalışması tamamlanmadan hiçbir sayısal skor kullanıcıya gösterilmez; o zamana kadar yalnız nitel bant | **kapalı** | Kurucu kararı M-F-04 (K8 aile kuralı): doğrulama öncesi **yalnız nitel bant, sayısal skor YOK**. Test bataryası config'indeki `banded` skorlamalar iç hesap olarak kalır, kullanıcıya gösterilmez |
| L-026 | karar | P1 | **Kalibrasyon sihirbazı kapı mı, öneri mi?** (JabLab ADR-003 karşılığı — orada "kapı, öneri değil" ve "ürünün en yüksek getirili tek bileşeni" denmiş). Lissom'da yaw toleransı ≤10° yazıldı ama sert kapı olup olmadığı kararsız. G1-a A5 ölçümü kapı olması yönünde: `trunk_lateral_tilt` ±10° sapmada 5,73° kayıyor, bu tek başına kapı kriteri B4'ü (≤5°) aşıyor | **kapalı** | Kurucu kararı M-F-09: kalibrasyon **SERT KAPI** (öneri değil), yaw ≤10° dayatılır. JabLab ADR-003 ile hizalı |
| L-027 | görev | P2 | **Kararı verilmemiş üç ürün mekanizması:** (a) yaş/cinsiyet verisi nasıl toplanacak — yaş bandı skorlama için ZORUNLU kılındı ama veri kaynağı ve gizlilik beyanı kararı yok (KVKK/GDPR + App Privacy); (b) ağrı bildirildiğinde program NASIL değişir — disclaimer metni var, mekanik yok (L-001 P0 buna bağlı); (c) "uzman doğrulaması şart" işaretli 7 hareketin filtrelenmesi — araştırma önerdi (ağrı öyküsünde otomatik dışla), karar verilmedi | **kapalı** | Kurucu kararları M-F-11: (a) yaş BANDI onboarding'de zorunlu, cinsiyet OPSİYONEL ("prefer not to say" dahil), yalnız cihazda + App Privacy beyanı; (b) ağrı bildirimi → o bölgenin egzersizleri seanstan çıkar + nazik alternatif + wellness dili, tekrar eden ağrıda profesyonele yönlendirme; (c) ağrı öyküsünde uzman-şart 7 hareket OTOMATİK dışlanır |
| L-028 | bulgu | **P1** | **`heel_rise` metriği yanlış şeyi ölçüyordu.** Tanım `distance_norm(HEEL, FOOT_INDEX)` idi — bu topuk kalkmasını değil **ayak uzunluğunu** ölçer ve topuk ne yaparsa yapsın sabit kalır. Squat'ta topuk kalkmasını yakalaması gereken geçersizleştirme koruması, hiçbir zaman ateşlenmezdi. İkinci katman: sentetik üreteçte topuk-kalkma diye bir olgu YOKTU, yani metrik hiç sınanmıyordu bile (Choreia C-011 dersinin aynısı: fixture, sınadığı olguyu içermeli) | **kapalı** | Kapı A9 yakaladı. Düzeltme: metrik `height_diff_norm(HEEL, FOOT_INDEX)` oldu + üretece `heel_lift` parametresi eklendi + taramaya girdi. Beklenen değer analitik doğrulandı (A1 0.000°) |
| L-029 | bulgu | **P1** | **Normalizasyon referansı poza duyarlıydı.** `torso_length`, "omuz-ortası ↔ her iki kalça mesafesinin ortalaması" (ICCV 2017/PCK geleneği) olarak yazılmıştı; gövde yana eğilince bir mesafe uzayıp diğeri kısalıyor ve ortalama küçülüyor (40° yan eğimde **%1,63**). Payda kayınca ona bölünen TÜM mesafe metrikleri kayıyordu — anatomik olarak sabit olması gereken topuk metriği %1,66 oynadı | **kapalı** | Ölçüldü ve düzeltildi: referans **orta-hattan orta-hatta** (`MID_SHOULDER ↔ MID_HIP`) olarak değiştirildi → tüm pozlarda tam 0,50000, sapma %0,00. **Kanonik Dart çekirdeği zaten böyle yapıyordu** (`(shoulderMid - hipMid)`); Python hattı ona uyduruldu — differential test yapılsaydı uyuşmazlık verecekti |
| L-030 | karar | P2 | **Kapı probları elle yazılmaz, tarama uzayından türetilir.** A9'un bozucu listesi sabit yazılmıştı; `heel_lift` parametresi eklenince liste eskidi ve metrik masum olduğu hâlde "ölü" göründü. Problar artık `SWEEPS`'ten otomatik üretiliyor (+ yaw + ölçek) — yeni bir poz parametresi eklendiğinde kapı kendiliğinden kapsar | **kapalı** | `gate_g1a.py` prob üretimi; A9 0/18 ölü |
| L-031 | risk | P2 | **Python hattı ile Dart çekirdeği farklı uzaylarda çalışıyor:** Dart `length2D` (image düzlemi, z atılmış), Python 3D world landmarks. İkisi aynı fixture'da aynı sayıyı vermek zorunda (G4 differential test) ama uzay farkı sistematik sapma üretebilir. L-029'da tanım hizalandı, uzay hizalanmadı | açık | — |
| L-032 | bulgu | **P1** | **Wellness süzgeci, egzersiz havuzu dosyasını "taradı" ve temiz dedi — ama içinden HİÇ metin çıkarmamıştı.** Süzgeç yalnız bilinen alan adlarını (`instruction`/`message`/`label`…) okuyor; içerik şemasının alanları (`nameEn`, `safetyNote`, `regression`, `progression`, `dose.raw`, `cameraNote`) listede yoktu → 72 hareketlik dosyadan 0 string, sonuç yeşil. Bu, aynı gün üçüncü kez karşılaşılan kalıp: **bulmayan denetim ile bozuk denetim dışarıdan aynı görünür** (L-011 ölü metrik · boş dizin taraması · bu). Bulguyu alt-ajan kendi işini teslim ederken bildirdi — "the clean result is trivial, not a genuine scan" | **kapalı** | Üç katmanlı düzeltme: (1) alan listesi içerik şemasını kapsayacak şekilde genişletildi → gerçek tarama **410 metin**, 0 ihlal; (2) **yapısal koruma**: `config/content|tests|copy` altındaki bir dosyadan hiç metin çıkmazsa süzgeç çıkış kodu 3 verir (`config/metrics/` kasıtlı muaf — teknik config, kullanıcı metni taşımaz); (3) öz-teste iki regresyon vakası eklendi (içerik şeması alanı taranıyor mu · sessiz dosya geçiyor mu). Öz-test 8 vaka, hepsi geçiyor |
| L-033 | görev | P1 | **Egzersiz havuzu config'e çevrildi:** 72 hareket, 7 bölge (ankle 10 · hip 12 · thoracic 10 · shoulder 10 · cervical 10 · lateral_chain 10 · posterior_chain 10), 7 uzman-şart işareti, kamera sınıflaması 63 tam / 8 kısmen / 1 hayır. Tüm kullanıcı metni İngilizce; kaynak Türkçe güvenlik notlarındaki **tanı adları nötr semptom diline çevrildi** (Aşil tendinopatisi, disk hernisi, impingement, siyatik, osteoporoz, servikal radikülopati, rotator manşet, labrum, protez/ameliyat kısıtları) — FDA general wellness sınırı gereği | **kapalı** | `config/content/exercise-pool.v1.json`; 72/72 benzersiz id, JSON geçerli, wellness süzgeci 410 metinde 0 ihlal. ⚠️ Güvenlik notları hâlâ **uzman doğrulaması bekliyor** (L-005 sınıfı borç) — üretime girmeden fizyoterapist onayı şart |
| L-034 | görev | P1 | **W0 başladı — blueprint kapsamı işlendi.** `LISSOM-BLUEPRINT.md` (M-F-18, kurucu onaylı) + motion-core `30-URUN-BLUEPRINT-STANDARDI.md` okundu; roadmap'e 4 dalga tablosu + poz-kütüphanesi katmanları (Tier-1/2/3) + revize fixture planı işlendi. PRD'ye dalga kapsamı, IA bölümü ve 3 yeni kabul kriteri eklendi | **kapalı** | `lissom-roadmap.md §4.5/§5/§7` · `PRD.md §1.1/§4.5/§11` |
| L-035 | görev | P1 | **Batarya 10 → 12 teste genişletildi** (blueprint W0): `active_straight_leg_raise` + `plank_hold`. ASLR yeni metrik GEREKTİRMEDİ — mevcut `hip_flexion_*` + guard'larla tanımlandı; bu, "yeni test = config, kod değil" mimarisinin ilk gerçek sınavıydı ve geçti. Plank için tek yeni metrik tipi eklendi: `line_deviation_norm` (nokta–doğru uzaklığı) | **kapalı** | Kapı regresyonu temiz: 19 metrik, A1 0.000°, A9 0/19 ölü. Plank ölçümü doğrulandı: hizada 0.0000, 10° kalça sapmasında 0.1102, 20°'de 0.2194 (monotonik, simetrik) |
| L-036 | karar | P1 | **İki yeni testin taşıdığı risk config'e açıkça yazıldı:** (a) ASLR **supine** — yerde yatan vücut tek kameranın en zayıf olduğu yer (self-occlusion), G1-b'de düşme adayı olarak işaretlendi; (b) plank bir **dayanıklılık** testi — wellness ürününde kullanıcıyı fazla zorlamaya en yakın yer, bu yüzden "rekorunu kır" teşviki YOK ve durma kararı açıkça kullanıcıya bırakıldı (L-001 ruhu) | **kapalı** | `lissom-assessment.v1.json` warning alanları |
| L-037 | görev | P1 | **IA çatısı kuruldu** (`config/ia/library.v1.json`): 6 aile sayfası + alt-öğeler, hepsi dalga-etiketli ve `coming_soon` durumlu; poz kütüphanesi 3 katman; "Neden yok?" sayfası 5 maddeyle; navigasyon kuralları (2-tık). **Her aile sayfası zorunlu dürüstlük kutusu taşıyor** (neler ölçülür / ölçülmez) — ör. Nefes sayfası: "Nothing. The camera stays off." | **kapalı** | Config geçerli; wellness süzgeci 494 metinde temiz |
| L-038 | bulgu | P1 | **Süzgecin kör noktası DÖRDÜNCÜ kez ortaya çıktı** — bu sefer IA config'inde: `intro`, `reason`, `topic`, `scope`, `measured`, `notMeasured` alanları tanınan alan listesinde yoktu, yani kütüphanenin en kritik metinleri (dürüstlük kutuları, "Neden yok?" gerekçeleri) taranmıyordu. Ayrıca `config/ia` içerik dizinleri listesinde olmadığı için sessiz-tarama koruması da devrede değildi | **kapalı** | Alan listesi + `CONTENT_DIRS` genişletildi → tarama 450'den **494 metne** çıktı ve **2 gerçek belirsizlik** yakalandı (aşağıda) |
| L-039 | bulgu | P1 | **Süzgeç "Neden yok?" sayfasında iki belirsiz ifade yakaladı:** `"Clinical movement screens, diagnosis or fall-risk scores"` ve `"Those claims belong to a regulated medical device"` — ikisi de olumsuzlamadan uzak kalmış, yani tek başına okunduğunda ürünün ne OLDUĞU sanılabilir. Muafiyet eklemek yerine metin yeniden yazıldı: olumsuzlama cümlenin başına alındı (*"is not a medical device, so it does not screen, diagnose or predict injury risk"*). Süzgeç burada yanlış alarm vermedi — metni gerçekten netleştirmeye zorladı | **kapalı** | `library.v1.json whyNotPage`; süzgeç 494 metinde 0 ihlal |
| L-040 | görev | P1 | **G1-b kaynak devri tamamlandı (rev.4).** B1-B7 kriterleri SİLİNMEDİ, kaynak merdivenine göre yeniden tanımlandı: B1/B2 → triyajdan geçmiş/sınırda PT klipleri · B3 → aynı eğitmenin farklı videoları + klip-içi tekrar + sentetik jitter (üç katman ayrı raporlanır) · B5 → AIST++ + sentetik · B7 → **triyajın reddettiği klipler doğal negatif fixture havuzu** (eskisinden zengin) | **kapalı** | `G1-V0-KAPI-PROTOKOLU.md §3.0` |
| L-041 | risk | **P1** | **Kaynak devrinin iki bedeli açıkça kaydedildi:** (a) **B4 artık farklı bir büyüklük ölçüyor** — kontrollü ışık/kıyafet varyasyonu yok, yerine "kaynak-arası varyans" (eğitmen × kadraj × ışık karışık); koşul etkisi ile eğitmen farkı AYRIŞMAZ, bu B4'ün üst sınırıdır. (b) **B5 gerçek görüntüde yalnız AIST++ hareket örtüşmesi kadar geçerli**; MM-Fit'in pose'u mocap değil "estimates" olduğu için MAE'ye giremez. İkisi de "measures" iddiasının sınırını daraltır ve skor bantlarının nitel kalma gerekçesini güçlendirir | açık (yaşayan kısıt) | — |
| L-042 | karar | P1 | **B6 (ilk geçerli ölçüme süre) KOŞULLU ERTELENDİ, iptal edilmedi.** Kamu videosunda "kullanıcı testi başlattı" anı yok; ölçüm cihaz kapısına (G8) taşındı ve protokolde "cihaz kapısında doğrulanacak" etiketiyle duruyor. Kriter silinmiş gibi davranılmaz | **kapalı** | Kapı protokolü §3.0 tablosu |
| L-043 | görev | P1 | **Hasat kuyruğu üretildi + pilot koşuldu.** Envanterden (7 kol, oEmbed doğrulamalı) **100 benzersiz video / 31 hareket** türetildi → `docs/harvest/queue.{txt,json}`. Depolama M-F-26'ya uygun: ham hasat `~/motion-harvest/lissom/`, repoya GİRMEZ | **kapalı** | Rig pilotu: ilk video **triyajca REDDEDİLDİ** (netlik 8 < 40 — eleme çalışıyor), ikincisi geçti: fixture v2, **7425 kare, %94,9 tespit**, provenance tam (sourceUrl/kanal/lisans/tarih) |
| L-044 | bulgu | P1 | **Kamu videosunda ilk tespit oranı ölçüldü: %94,9** (7044/7425 kare, `full` varyant, 1280x720@25fps). Bu B1'in ilk gerçek sinyali — ama TEK videodan; kadraj/hareket uygunluğu ayrı sorular ve triyaj geçiş oranı henüz istatistiksel değil (1/2 örneklemde 1 ret) | açık (geniş pilot koşuyor) | — |
| L-045 | görev | P1 | **İlk feat→main merge (M-F-24 yetkisiyle).** 13 commit `main`'e alındı ve push edildi (`9d29136`). Merge anında koşulan kapı kanıtı: config_check 6 dosya geçerli · wellness_lint 494 metin 0 ihlal · lint_selftest yeşil · gate_g1a A1 0.000° / A9 0/19 ölü → ŞARTLI GEÇTİ. Force-push yok, `--no-ff` ile merge noktası bırakıldı | **kapalı** | `lissom@9d29136` origin/main |
| L-046 | bulgu | **P0→kapalı** | **Hasat triyajı "kişi kadrajda mı" ölçüyordu, "ölçmek istediğim eklem kadrajda mı" DEĞİL.** Rig'in üst-gövde sondası burun+iki omuza bakıyor; Lissom testlerinin çoğu (squat, ayak bileği, lunge, hamstring) ALT vücut ister. Pilotta ölçüldü: üst-gövde eşiğini geçen kliplerde alt-vücut metriklerinin geçerli-ölçüm oranı **%72-77 medyan, bazı kliplerde %2-7**. Yani triyajdan geçmiş bir klip, Lissom'un ana testleri için kullanılamaz olabiliyordu ve bunu hiçbir şey söylemiyordu | **kapalı** | Rig'e `min_full_body_ratio` eşiği + tam-gövde sondası (burun+omuz+kalça+ayak bileği) eklendi; varsayılan 0.0 = kapalı, geriye uyumlu. Lissom profili: `config/harvest/triage-profile.v1.json` |
| L-047 | bulgu | **P1** | **Tam-gövde sondası alt-vücut ölçülebilirliğini ÖNGÖRÜYOR, üst-gövde sondası öngörmüyor** — 4 pilot klipte ölçüldü: `92%→VMR 97%` · `83%→96%` · **`50%→52%`** · **`17%→7%`**. Üst-gövde oranı ise sinyal vermiyor (92% üst-gövde, %52 VMR). Eşik 0.6 iki düşük klibi eler ve geçenlerin VMR'ı %96-97 → **kapı kriteri B1 (≥%90) doğrudan sağlanıyor** | **kapalı** | Ölçüm tablosu profil dosyasında `evidence` bloğunda; n=4, sinyal güçlü ama örneklem küçük — geniş hasatta yeniden ölçülecek |
| L-048 | bulgu | P1 | **Triyaj geçiş oranı ölçüldü: 4/14 (%28,6).** Ret gerekçeleri: 3× netlik (bulanık) · 3× süre <90 sn (shorts) · 2× üst-gövde kadrajı. **Planlama sonucu:** 100 videoluk kuyruktan ~29 kullanılabilir klip beklenir; test-başına ≥3 eğitmen kuralı 31 hareket için ~93 klip ister → **mevcut kuyruk YETMEZ**, hasat kapsamı genişletilmeli (özellikle shorts-ağırlıklı kanallardan uzun-form içerik aranmalı) | açık | Pilot logu; `docs/harvest/queue.json` |
| L-049 | bulgu | P1 | **Kamu videosunda poz tespit oranı: medyan %97,4** (4 klip, 23.039 kare, `full` varyant, min %94,9 / max %98,4). Ama bu "poz bulundu" oranıdır; **geçerli-ölçüm oranı (VMR) metriğe göre çok değişiyor**: gövde metrikleri ~%100, omuz ~%86, alt vücut %72-77. Tek bir "tespit oranı" sayısı kapı kararı için yetersiz — VMR metrik bazında raporlanmalı | açık (G1-b'ye girdi) | Ön-ölçüm çıktısı |
| L-050 | bulgu | **P1** | **KENDİ HATAM — katkıyı hedef yolundan geçirmeden teslim ettim.** `harvest_rig` tam-gövde eşiği katkımda iki isim hatası vardı (`model_path`→`pose_model`, `report.rejections`→`rejects`); eşik açık olsaydı `triage()` **NameError ile çökerdi**. Kavramı kendi ölçüm betiğimle doğruladım (sondayı DOĞRUDAN çağırarak) ama `triage()` yolunu hiç koşmadım — üstelik varsayılanı `0.0` (kapalı) bıraktığım için pilot koşumunda da o kod yolu hiç çalışmadı. Yani "çalışıyor" kanıtım, çalıştırmadığım bir yola aitti. Bu, kendi kapı disiplinimin (L-011/L-032/L-038 "bulmayan denetim ile bozuk denetim aynı görünür") ihlali | **kapalı** | Koordinatör düzeltti ve main'e aldı (`a0e4da9`); sondayı tek çıkarım geçişine indirdi (2× maliyet kalktı) + entegrasyon yolunu stub'lı teste bağladı. **Aile kuralı M-F-27 doğdu:** rig katkılarında `tests/test_rig.py`'ye en az bir entegrasyon iddiası zorunlu |
| L-051 | karar | P1 | **Kuyruk genişletme onaylandı (koordinatör).** Hedef: kuyruk ≈ hedef-klip × 3,5 (%28,6 geçiş oranından) → 93 klip için **~325 aday URL**. Genişletme körlemesine yapılmaz: ret-gerekçesi dağılımı kaynak seçimini yönlendirir — bulanıklık ve shorts elemesi **kaynak seçimiyle** düşürülebilir, o yüzden uzun-form ve tripod'lu klinik kanallar öncelikli | açık (uygulanacak) | Ret dağılımı: 3× netlik · 3× süre<90sn · 2× kadraj |
| L-052 | görev | P2 | **Çekirdek pini 0.2.0'a güncellenebilir** — `motion_core-v0.2.0` çıktı (CycleAligner, periyodik-hizalama). 0.1.0 API'lerinde kırılma yok. Lissom'un 4-hafta karşılaştırması statik pozlarda bundan etkilenmez; **dinamik akış testlerinde** (Vinyasa flow modu, W1) kullanılacak | açık | — |
| L-053 | görev | P1 | **Faz tanımı katmanı kuruldu (A7/A8 hazırlığı).** `config/phases/lissom-phases.v1.json`: koşul dilbilgisi (metric/delta/timeInPhase/confidence/all/any) + üç çekirdek desen (rom_sweep · descend_return · timed_hold) + 3 çekirdek test tanımı. **Mimari ayrım netleşti:** faz MANTIĞI çekirdekte (`PhaseCondition` = tip-güvenli Dart fonksiyonu, JSON değil), faz SIRASI/EŞİKLERİ/zamanlaması config'te. "Yeni test = config" iddiası bu sınırda geçerli | **kısmi** (3/12; kalan 9 alt-ajanda) | `phase_check.py` yeşil |
| L-054 | görev | **P1** | **Faz config denetimi CI'a bağlandı** (`tools/phase_check.py`) — 7 değişmez: tam bir terminal faz · terminal olmayan her fazda `timeoutMs` · tam bir `measureHere` fazı · her `abort` için `abortCode` · metrik referansları tanımlı · koşul dilbilgisi geçerli · batarya kapsamı tam. **En kritiği timeout kuralı:** çekirdeğin kendi uyarısı — timeout'suz faz çıkış koşulunu kaçırınca sonsuza park eder ve bu dışarıdan "kullanıcı hareketsiz" gibi görünür | **kapalı** | Denetim ilk koşumda **kendi config'imde 2 eksik buldu** (`abortCode` yok) — M-F-27 dersinin doğrudan uygulaması: hedef yoldan doğrula |
| L-055 | bulgu | **P1** | **Faz sürücüsü ≠ ölçüm metriği — kendi görev tablomda hata vardı, alt-ajan yakaladı.** `overhead_squat` için "birincil metrik: trunk_lean" yazmıştım; alt-ajan faz sürücüsünü `knee_flexion` yapıp `trunk_lean`'i ölçüm fazında bıraktı. Gerekçesi doğru: **gövde eğimi bir HATA ölçüsüdür ve iyi performansta ~0 kalır** — faz geçişini ona bağlamak, mükemmel yapan kullanıcıda "descending" fazının HİÇ tetiklenmemesi demekti. Ayrım `hip_hinge`'de tersine döner (orada öne eğilme hareketin kendisi) | **kapalı** | Config `_notes`'a kural olarak yazıldı; 12/12 faz tanımı `phase_check` yeşil |
| L-056 | görev | P2 | **Denetim boşluğu (L-055'ten):** `phase_check.py` "hata metriği faz sürücüsü olmuş mu" sorusunu SORAMIYOR — çünkü config'te bir metriğin "hareket mi kusur mu" ölçtüğü işaretli değil. `guardMetrics` yakın ama yeterli değil (`overhead_squat`'ta `knee_flexion` hem guard hem meşru sürücü). Öneri: faz config'ine açık `phaseDriver` alanı; denetim ikisinin farkını görünür kılar, yasaklamaz | açık | — |
| L-057 | görev | P1 | **12/12 faz tanımı tamam.** Alt-ajan 9 testi şablona uygun yazdı; ek olarak ölçüm fazlarına form-abort'ları ekledi (`KNEES_BENDING`, `TORSO_ROTATED`, `LATERAL_LEAN`, `TRUNK_LEAN_EXCESS`) — verilen iki örnek de ölçüm fazını bir kusur kontrolüyle kapılıyordu, tutarlı. Dürüstlük notları korundu: `single_leg_balance`'ta destek/ayak-değme tespiti V1'de metrikle YAPILAMIYOR (kullanıcı beyanına düşüyor), `active_straight_leg_raise` supine ve G1-b düşme adayı | **kapalı** | `phase_check`: 12/12, tüm değişmezler ✅ · eşikler geçici, G1-b'de kalibre edilecek |
| L-058 | görev | P1 | **Kuyruk genişletildi: 100 → 272 aday** (241 değerlendirme + 31 yoga), 12 testin 11'i yeterli aday sayısına ulaştı (≥11 aday = %28,6 geçiş oranıyla ~3 klip). `single_leg_balance` 10 adayla sınırda. **Yöntem LLM araması DEĞİL:** `yt-dlp ytsearch` ile doğrudan kaynaktan — uydurma URL riski sıfır, süre/kanal metadata'sı gerçek | **kapalı** | `docs/harvest/queue.json` v1.3.0 |
| L-059 | karar | P1 | **Süre filtresi KAYNAĞA taşındı (koordinatör önerisinin uygulaması).** Pilot ret dağılımının 3/8'i "süre<90 sn (shorts)" idi; arama sorgusuna 120-1800 sn filtresi konarak bu eleme **indirmeye gerek kalmadan** yapıldı. Bulanıklık ve kadraj elemesi indirme sonrası triyajda kalıyor — onlar metadata'dan bilinemez | **kapalı** | `queue.json._expansion.method` |
| L-060 | bulgu | P1 | **Öncelikli klinik kanallardan 15 video-düzeyi isabet bulundu** (Physiotutors · E3 Rehab · Clinical Physio · Brookbush Institute · NASM). Envanter turunda 7 kolun tamamı "bu kanallardan video-düzeyi isabet bulunamadı" demişti — **doğrudan arama, LLM aramasının bulamadığını buldu.** Ders: kaynak-düzeyi sorgular (yt-dlp/kanal API) metin-arama fan-out'undan hem daha güvenilir hem daha ucuz | **kapalı** | Genişletme çıktısı |
| L-061 | bulgu | P2 | **Kuyrukta ad tutarsızlığı vardı ve sayımı bozuyordu:** envanterden gelen adlar uzun/serbest ("Deep squat assessment / bodyweight squat screen"), aramadan gelenler test id'si ("deep_squat") — aynı hareket iki isimle sayılıyordu. Normalize edildi + kategori eklendi (`assessment` / `yoga` / `mobility_content`), böylece "test başına ≥3 eğitmen" kuralı gerçekten ölçülebilir hale geldi | **kapalı** | Kategori dağılımı: 241 / 31 / 0 |
| L-062 | bulgu | **P1** | **Eklediğim eşik CLI'dan ERİŞİLEMİYORDU** — `harvest.py` `TriageThresholds()`'i hep varsayılanla çağırıyordu, yani `min_full_body_ratio` hiçbir koşumda etkin olamazdı. Özellik vardı, yolu yoktu (L-050'nin kardeşi). CLI'ya `--triage-profile` eklendi (JSON okur) + **bilinmeyen eşik anahtarı sessizce yutulmuyor**, `SystemExit` ile reddediliyor — "eşiği verdim ama etkisi yok" hatasının en sinsi biçimi budur | **kapalı** | `tests/test_rig.py [4]` — 5 entegrasyon iddiası yeşil (M-F-27 uygulaması) |
| L-063 | bulgu | **P1** | **AYNI HATA SINIFI BU TURDA ÜÇ KEZ TEKRARLANDI ve üçünde de sebebi `str.replace`'in sessiz kaçması oldu.** Desen eşleşmediğinde Python hiçbir şey yapmaz, hata vermez; ben "eklendi" diye raporladım. Sonuçlar: (a) fonksiyon çağrılıyor ama tanımlı değil → çalıştırılsa NameError (L-050'nin birebir tekrarı), (b) test yazıldı ama `main()`'e bağlanmadı → hiç koşmadı, (c) testte `Path` importu eksikti. **Üçünü de test yakaladı** — M-F-27'yi uyguladığım için. Kalıcı kural: her programatik düzenlemeden sonra sonucu `grep`/okuma ile DOĞRULA; "replace çalıştı" varsayma | **kapalı** | Her düzenlemeden sonra doğrulama satırı eklendi; rig süiti [1]-[4] tam yeşil |
| L-064 | görev | P1 | **Tam-gövde eşiğinin uçtan uca ETKİN olduğu kanıtlandı** — L-062'nin kapanış kanıtı. Hasat manifestinde `"fullBodyRatio": 0.75` kaydı görüldü (0.6 eşiğini geçerek kabul). Zincirin üç halkası da doğrulandı: profil JSON yüklendi → sonda koştu → eşik uygulandı → manifest'e yazıldı. Artık "özellik var ama yolu yok" durumu YOK | **kapalı** | `~/motion-harvest/lissom/manifests/yWfMPZWHnVw.json` triage bloğu |
| L-065 | bulgu | P2 | **İlk batch koşumu sessizce başarısız oldu** (exit 1, boş log): subshell içinde `cd $RIG` yaptım ama Python yolu lissom/app'e göreliydi ve dizin değişince bozuldu. Hiçbir video işlenmedi ama hata mesajı da log'a düşmedi. Ders: uzun-koşumlu arka plan işlerinde **mutlak yol** kullan; göreli yol + `cd` kombinasyonu sessiz başarısızlık üretir | **kapalı** | Mutlak yollarla yeniden koşuldu, ilk video geçti |
| L-066 | bulgu | **P1** | **`movement_isolator` Lissom'a OLDUĞU GİBİ uymuyor — ölçüldü.** Araç periyodiklik + hareket enerjisiyle çalışıyor (Choreia: dans adımı tanım gereği tekrarlar). Lissom kliplerinde 6 fixture'da denendi: `min_period_s=0,4` ile periyodiklik 0,89-0,93 çıkıyor **ama periyot her seferinde tam alt sınıra yapışıyor (0,37 s = 11 kare)** — bu gerçek tekrar değil, düşük-lag otokorelasyon artefaktı (komşu kareler zaten benzer). Alt sınır 1,5 s'ye çekilince yalnız 1 klipte pencere kalıyor (skor 0,68'e düşüyor), 2,5 s'de **hiçbir klipte pencere yok**. Pencere boyutunu 6→24 s büyütmek de değiştirmiyor | **kapalı** (bulgu) | Ölçüm tablosu: 3 klip × 3 alt-sınır |
| L-067 | karar | P1 | **Lissom'da hareket-penceresi seçimi periyodiklikle DEĞİL, test-özel metrik dinamiğiyle yapılmalı.** Gerekçe L-066: Lissom testleri (3 tekrar, 3-6 s/tekrar, çoğu tek-yönlü ROM taraması) periyodik sinyal üretmiyor; `plank_hold` ve `single_leg_balance` ise tanım gereği **tekil tutuş** — periyodiklik orada kavramsal olarak da yanlış araç. Doğru sinyal zaten elimizde: faz state-machine'inin sürücü metriği (ör. `shoulder_flexion` belirgin artış→tepe→azalış). Yani pencere seçimi G4 motorunun doğal çıktısı, ayrı bir ön-eleme adımı değil | açık (G4'te uygulanacak) | — |
| L-068 | karar | P2 | **Aile aracı ≠ app'e hazır araç — ikinci örnek.** Triyaj eşiğinde (L-046) ve şimdi isolator'da (L-066) aynı kalıp: çekirdek araç bir app'in ihtiyacına göre kalibre edilmiş, başka app'te sessizce yanlış cevap veriyor (triyajda "kabul" diyordu ama alt vücut yoktu; isolator'da "periyodik" diyor ama artefakt). **Kural: aile aracını devralan app, aracın varsayımını kendi verisinde ÖLÇMEDEN kullanmaz** | **kapalı** | İki ölçülmüş örnek |
| L-069 | bulgu | **P0** | **Faz `delta` eşikleri KARE-BAŞINA tanımlı ve bu iki yönden kırılgan.** (a) **Genliğe duyarlı:** 1,0°/kare eşiği 150°'lik omuz kaldırmada rahat geçiliyor (3,33°/kare) ama 33°'lik yana eğilmede GEÇİLEMİYOR (0,73°/kare) — aynı sürede, aynı hızda yapılan iki hareketten biri faz atlıyor. (b) **fps'e duyarlı:** aynı hareket 60 fps'te yarı değere düşüyor (`deep_squat` 2,56→1,28, `lateral_bend` 0,73→0,37) — cihaz kare hızı değişince faz makinesi sessizce durur. Kapı A7'de yakalandı: `lateral_bend` `ready`'de takılıp kaldı | **kapalı** (ölçüm) · açık (şema düzeltmesi) | Ölçüm tablosu: 3 hareket × 2 fps |
| L-070 | karar | **P0** | **`delta` birimi kare-başına DEĞİL, saniye-başına olmalı** (`valuePerSecond`), yorumlayıcı fps'e bölerek uygular. Bu, L-069'un iki bacağını da kapatır: eşik hareketin gerçek hızını tarif eder ve cihaz fps'inden bağımsızlaşır. **Aile-geneli:** JabLab'ın faz-süresi metriği ve Gravita'nın RepEngine'i aynı köprüyü kuruyor — şema önerisine dahil edilecek (koordinatörün M-talebi çağrısı) | açık (core köprüsüne girecek) | — |
| L-071 | görev | P1 | **A7/A8 İLK KEZ ÖLÇÜLDÜ** (taslak köprüyle; core sürümü çıkınca devredecek). A7 3/5 · A8 8/10. İki başarısızlık gerçek: `lateral_bend` L-069 yüzünden faz atlıyor · `overhead_squat` `ready` koşulu çok-metrikli (`all`) ve senaryo üretecim yalnız tek poz alanı gezdiriyor. **Kapsam dürüstlüğü:** 7 test senaryo üreteci olmadığı için A7/A8 KAPSAMI DIŞINDA ve rapor bunları isimle sayıyor — türev metrikli testlerde (reach_depth, knee_height, foreshortening) metrik→poz ters eşlemesi yok | açık | Kapı çıktısı; `gate_g1a.py measure_a7_a8` |
| L-072 | bulgu | **P1** | **`lateral_bend`'in TORSO_ROTATED guard'ı hiçbir zaman doğru çalışamazdı.** Koşul `shoulder_line_foreshortening > 0.15` yazılmıştı; metrik nötr duruşta **0,80** (omuz genişliği/gövde uzunluğu) ve rotasyonda **KÜÇÜLÜR** — yani koşul her duruşta doğruydu ve test her denemede abort ediyordu. Operatör ters, eşik anlamsız. Ölü-metrik ailesinden: guard var, hiçbir zaman iş görmüyor | **kapalı** | Düzeltildi (`< 0.60`, geçici eşik); A7 4/5 → **5/5** |
| L-073 | görev | **P1** | **A10 kapı kriteri eklendi: "doğru duruşta hiçbir abort tetiklenmemeli".** Tüm guard'ları tek seferde denetler — kusursuz bir duruşta tetiklenen guard'ın koşulu terstir veya eşiği anlamsızdır. İlk koşumda **2 bozuk guard** buldu (biri gerçek hata L-072, biri kriterin kendi kusuru: `overhead_squat`'ın doğru başlangıcı kollar YUKARIDA, "nötr poz" oradaki test için yanlış referans). Kriter test-özel doğru duruşa bağlandı | **kapalı** | A10: 0/11 guard yanlış tetikleniyor ✅ |
| L-074 | görev | **P1** | **G1-a KAPISI TAM GEÇTİ — A1-A10 hepsi yeşil.** A1 0,000° · A2 0,467° · A3 0,931° · A4 0,040° · A6 0/125 sızıntı · A7 **5/5** · A8 **10/10** · A9 0/19 ölü · A10 0/11 yanlış guard. Hüküm artık "ŞARTLI" değil: **GEÇTİ**. ⚠️ Kapsam sınırı raporda isimle duruyor: 7 test A7/A8 kapsamı dışında (türev metrikli; metrik→poz ters eşlemesi yok) ve 2 metrik A1-A4 dışında | **kapalı** | `docs/g1a-rapor.json` |
| L-075 | bulgu | P1 | **İkinci hasat turu: 22 klip → 8 kabul (%36 geçiş).** Ret dağılımı: 6× süre<90sn · 4× netlik · **3× tam-gövde oranı** (yeni eşik, alt vücut kadraj dışı). Geçiş oranı ilk tura göre yükseldi (%28,6 → %36) ama bu batch AĞIRLIKLI OLARAK ESKİ kuyruktan geldi — süre filtresi yalnız yeni adaylarda uygulandı, o yüzden 6 shorts reddi hâlâ var. Filtrelenmiş adaylarla geçiş oranının daha yüksek olması beklenir; ölçülmedi | açık | Toplam kütüphane: 14 fixture |
| L-076 | görev | P1 | **Tam-gövde eşiği sahada 3 klip eledi** — hepsi üst-gövde sondasından geçmiş olurdu. L-046/L-047'nin pratik karşılığı: bu klipler Lissom'un squat/ayak bileği/lunge testleri için kullanılamazdı ve eski triyajda "kabul" damgası alacaktı | **kapalı** | Hasat logu ret gerekçeleri |
| L-077 | görev | P1 | **Faz-config şeması taslağına diff verildi (M-talebi).** Taslak Lissom'un 12 testinin 11'ini olduğu gibi ifade edebiliyor; koşul cebiri + saniye-birimli delta + iki değişmez zaten bizim önerimizdi. **Tek gerçek eksik: `perSide`/`{side}` taraf parametrizasyonu** — 7 testimiz iki taraflı ve tek tanımdan örnekleniyor; taslakla yazınca 35 fazlık kopya gerekir. Kozmetik değil: kopyalanan eşik ayrışır ve taraf simetrisi Lissom'un ÖLÇTÜĞÜ şeyin kendisi (sağ-sol farkı bölgesel skorun bileşeni) | **kapalı** (bildirildi) | `docs/M-TALEBI-faz-config-diff.md` |
| L-078 | görev | P1 | **M-F-34 (taban-değeri) uygulandı — beyan edilmedi, ÖLÇÜLDÜ.** 7 oran metriğinin kusursuz-durum tabanı sentetik nötr duruşta ölçülüp config'e yazıldı: `shoulder_line_foreshortening` **0,80** · `knee_height_*` **0,84** · `reach_depth` **1,60** · `heel_rise_*` ve `plank_hip_deviation` **0,00**. Açı metrikleri kapsam dışı (mutlak açı ölçüyorlar, taban kavramı uygulanmaz) | **kapalı** | Kapı **A11**: 0/7 sapma ✅ |
| L-079 | görev | P1 | **A11 kapı kriteri: beyan edilen taban ≤%1 sapmayla ölçülenle uyuşmalı.** Gerekçe doğrudan L-072: tabanı 0,80 olan metrik sıfır sanılıp guard `> 0.15` yazılmıştı ve her duruşta tetikleniyordu. Yanlış beyan edilmiş taban, her eşiği yanlış yerden ölçtürür — A11 bunu kalıcı olarak yakalar | **kapalı** | A11 0/7 ✅ |
| L-080 | hata | **P0** | **Triyaj sondası kadraj şartını SABİT tutuyordu; ölçüm ayak bileğine hiç bakmayan testlerin adaylarını eledi.** `overhead_reach` (bir OMUZ testi) 8 adayın 8'inde geçemedi — 7'si "alt vücut kadraj dışı". **Gerçek veride doğrulandı:** reddedilen 5 klip testin GERÇEKTEN istediği kalça kümesiyle yeniden triyajlandı → **4'ü yanlış red** (kalça oranı 0.75-1.00 iken ayak bileği 0.00). Süre filtresi bu sınıfa dokunamıyordu: hedeflediği sınıfı sıfırladı (süre reddi 6→0) ama toplam geçme oranı düştü, çünkü asıl darboğaz kadrajdı | **kapalı** | çekirdek `lower_body_ids` parametresi + `perMovement` profili; ayak bileği şartı **12/12 → 9/12** teste indi |
| L-081 | hata | **P0** | **Bataryanın metrik referansları HİÇBİR kontrol tarafından doğrulanmıyordu.** Envanter çıkarılınca üç kırık ad bulundu: `hip_flexion_{opposite}` (yer tutucu hiçbir yerde çözülmüyordu → ASLR'nin "karşı bacak yerde kalmalı" guard'ı **asla çalışamazdı**, L-072 ile aynı sınıf), `hold_duration` ve `supportContact`/`footTouchdown`/`confidence`/`heelRiseDelta` (meşru ama beyansız büyüklükler) | **kapalı** | `{opposite}` çözümü + `derivedMeasures` beyan bloğu (+`requiredLandmarks`) + CI değişmezi |
| L-082 | ders | P1 | **Kendi düzeltmem yeni bir sessiz boşluk açtı ve iki kez daha açtı.** Sırasıyla: türetmeyi metrikteki geri-işaretten yaptım → 12 testin 9'u çıktı; `derivedMeasures` beyan ettim ama kadraj ihtiyacı alanı yoktu → `single_leg_balance` ayak bileği aramıyordu; beyanı `invalidation` kurallarına bağlamadım → `footTouchdown` hiç okunmuyordu. **Ders: "türetilmiş" olmak doğruluk garantisi değil — türetmenin GİRDİ KÜMESİ de eksik olabilir.** Otorite batarya, tarama alanı ise kural metinleri dahil TÜM referans yüzeyi | **kapalı** | 12/12 test türetiliyor |
| L-083 | hata | P1 | **`tests/test_rig.py` hükmü blok [4] çağrılmadan ÖNCE veriyordu** — o bloktaki kırıklar hiç raporlanmıyor, betik "Hepsi geçti" deyip 0 dönüyordu. Yazılmış ama hükme bağlanmamış test (L-063 sınıfı, bu kez çekirdek rig'de) | **kapalı** | hüküm en sona alındı + kırıklar tek tek basılıyor |
| L-084 | ölçüm | **P1** | **L-080 düzeltmesi doğru ama `overhead_reach`'e fixture KAZANDIRMADI — ve ara ölçümüm yanıltıcıydı.** Yanlış-red doğrulamasını YALNIZ KALÇA kümesiyle yapıp "4/6 yanlış red" (oran 0,75-1,00) sonucuna varmıştım; oysa testin gerçek türetilmiş kümesi dirsek+bilek+kalça (`shoulder_flexion` dirseğe, `elbow_extension` bileğe bakıyor). **Tam kümeyle 13 aday: 0 kabul**, oranlar 0,42-0,58. Kısmi küme üzerinden ölçülen iyileşme tam kümede yoktu | **kapalı** (düzeltildi, vault notu da) | `/tmp/harvest_oh.log` |
| L-085 | açık | **P1** | **Bağlayıcı kısıt artık 0,6 oranı eşiği ve o eşik BAŞKA bir küme için kalibre edilmişti** — yani L-080'in aynısı, bu kez eşiğin kendisinde. Ayrıca oran video geneline yayılmış karelerden hesaplanıyor: kollar aşağıdayken geçen konuşma bölümleri, hareket anında ölçülebilir bir klibi aşağı çekiyor. **Eşiği sayı tutsun diye gevşetmek YASAK** — önce ölçüm penceresi hareket anına daraltılmalı, sonra eşik o pencerede yeniden kalibre edilmeli | **AÇIK** | sonraki tur |
| L-086 | çözüm | **P1** | **L-085 kapandı: eşik gevşetilmedi, ÖLÇÜLEN ŞEY değiştirildi.** Görünürlük oranı videonun tamamından hesaplanıyordu; oysa fixture bir temiz TEKRAR ister, temiz bir VİDEO değil. **Ölçüm:** reddedilen 6 `overhead_reach` klibinin **6'sında da** kesintisiz kullanılabilir pencere var — **114/54/36/19/9/7 sn**. 114 saniye kusursuz görünürlük taşıyan klip, genel oranı 0,47 (giriş+konuşma) olduğu için elenmişti | **kapalı** | çekirdek `min_usable_window_s` (varsayılan 0 = KAPALI, geriye uyumlu); pencere sondası yalnız oran düştüğünde koşar, geçen klip ek maliyet ödemez; Lissom profili 6 sn |
| L-087 | hata | **P1** | **Kendi eklediğim kurtarma mantığı regresyon üretti, test yakaladı.** `if (window or 0) < esik` yazmıştım; eşik 0 (özellik KAPALI) iken `0 < 0` = False dönüyor ve oran eşiğini geçemeyen her klip **sessizce KABUL** ediliyordu. "Eski davranış birebir korunuyor" testi olmasa fark edilmezdi — özellik kapalıyken davranışın değişmediğini sınamak, özelliğin çalıştığını sınamak kadar gerekli | **kapalı** | `rescued = esik>0 AND pencere>=esik`; blok [6] 3/3 |
| L-088 | ölçüm | P1 | **Pencere sondası pencereyi FAZLA tahmin ediyor (~%30) — eşik marjı göründüğünden ince.** `V_NOw5VqpYA` için kaba sonda (1 sn örnekleme) 114 sn dedi; üretilen fixture'da kare düzeyinde gerçek kesintisiz pencere **80 sn** (33.221 kare, %99 tespit, 24 fps). Fark saniye-altı kopmalardan: örnekleme onları göremiyor. Yani profildeki 6 sn'lik eşik, kare düzeyinde ~4 sn'ye karşılık gelebilir. Bir tekrar için hâlâ yeterli ama **marj sanıldığı kadar geniş değil**; eşik düşürülmemeli ve pencere yaklaşımı hareket-varlığı kontrolüyle tamamlanmadan gevşetilmemeli | **kapalı** (kayıt) | fixture ölçümü |
| L-089 | görev | P1 | **`overhead_reach` 0 fixture'dan çıktı.** Daha önce reddedilen üç klip pencere ölçütüyle fixture üretti (`V_NOw5VqpYA` · `ZFTY2UndWNI` · `cP4LLJie9kw`); ilkinde 23 dakikalık videonun içinde 80 sn kesintisiz tam-görünür malzeme var. Tur sürüyor (4/13) ⚠️ **BU NUMARA İKİ KAYITTA — atıf çözerken İKİSİNE de bak (L-305; yeniden numaralandırma YOK: bir numarayı değiştirmek ona işaret eden HER atfı sessizce yanlış yapar).** | **kısmen açık** (tur bitmedi) | `/tmp/harvest_oh2.log` |
| L-089 | görev | P1 | **`overhead_reach` 0 → 4 fixture.** Tur kapandı: 13 aday, **4 kabul**, 9 red. Kabul edilenlerin dördü de daha önce "alt vücut kadraj dışı" diye elenmiş kliplerdi. Kalan redler tamamen BAŞKA gerekçelerden — netlik 3 · kopya 2 · üst-gövde kadraj 2 · süre 2 — yani landmark/pencere ölçütü artık bağlayıcı kısıt DEĞİL ⚠️ **BU NUMARA İKİ KAYITTA — atıf çözerken İKİSİNE de bak (L-305; yeniden numaralandırma YOK: bir numarayı değiştirmek ona işaret eden HER atfı sessizce yanlış yapar).** | **kapalı** | `/tmp/harvest_oh2.log` |
| L-090 | açık | P1 | **Aynı kusur bir katman yukarıda duruyor: ÜST-gövde oranı da video geneli ortalaması.** İki red "üst-gövde oranı 0,50/0,58 < 0,6" diyor. Alt-gövde oranı için kanıtladığım şey burada da geçerli: giriş/konuşma bölümleri, hareket anında kusursuz kadrajlı klipleri aşağı çekiyor. Pencere ölçütü `min_usable_window_s` şu an YALNIZ alt-gövde şartına uygulanıyor. **Düzeltmeden önce ÖLÇÜLMELİ** (L-085'teki gibi): bu iki klipte üst-gövde için kesintisiz pencere var mı? ⚠️ **BU NUMARA İKİ KAYITTA — atıf çözerken İKİSİNE de bak (L-305; yeniden numaralandırma YOK: bir numarayı değiştirmek ona işaret eden HER atfı sessizce yanlış yapar).** | **AÇIK** | sonraki tur |
| L-090 | çözüm | P1 | **Üst-gövde oranı da aynı kusuru taşıyordu — ölçüldü, kapatıldı.** Üst-gövde gerekçesiyle reddedilen 2 klipte kesintisiz pencere: **74 sn ve 277 sn.** Pencere kurtarması artık üst-gövde reddine de uygulanıyor ve sonda iki kümenin BİRLEŞİMİNİ görüyor (kullanılabilir pencere = her gerekli landmark AYNI ANDA görünür) ⚠️ **BU NUMARA İKİ KAYITTA — atıf çözerken İKİSİNE de bak (L-305; yeniden numaralandırma YOK: bir numarayı değiştirmek ona işaret eden HER atfı sessizce yanlış yapar).** | **kapalı** | rig blok [6] 5/5 |
| L-091 | hata | **P1** | **12 kareyle oran tahmininin gürültüsü karar marjıyla aynı büyüklükte — eşik civarında hüküm KISMEN RASTLANTISAL.** `pose_probe_frames=12`, oran için standart hata ≈ **0,14**; karar eşiği 0,60. Ölçülen iki klipte gerçek üst-gövde oranı **0,70 ve 0,79** iken triyaj **0,50 ve 0,58** raporlamıştı. **Epistemik uyarı:** bu iki klibi düşük gözlenen değere göre SEÇTİM, dolayısıyla ortalamaya dönüş gereği gerçek değerin yüksek çıkması garanti — "sistematik sapma" İDDİA EDİLEMEZ. Kanıt olan şey gürültünün büyüklüğü, ki o ilk ilkelerden hesaplanıyor ve seçilmiş örnekten bağımsız | **kapalı** (pencere ölçütüyle) | yoğun örneklenen pencere sondası hem ortalama hem gürültü sorununu çözüyor; eşik OYNATILMADI |
| L-092 | hata | **P0** | **REFERANS KURULMADI — 4 fixture'ın 3'ü hareketi İÇERMİYOR.** M-F-38 yeterlilik kapısı bağımsızlıktan geçiyordu (4 fixture = 4 ayrı kanal) ama asıl soru bu değilmiş. Ölçüm: `overhead_reach` tam uzanmada ~150-180° omuz fleksiyonu ister; **tepe (p95) değerleri 85° · 76° · 152° · 92°** ve 140°'yi aşan kare oranı **0,00 · 0,02 · 0,06 · 0,00**. Yalnız `cP4LLJie9kw` gerçek baş-üstü uzanma içeriyor. `OtE8CdyRtuk`'te karelerin **%69'u dik duruş bile değil** (klinik "Manual Resistance" videosu — ya hasta yatıyor ya da izlenen kişi KLİNİSYEN). **Bağımsız eğitmen sayısı 4 değil, kullanılabilir kaynak sayısı 1** → referans kurulamaz | **kapalı** (kurulmadı) | `/tmp/ref_check.py` |
| L-093 | ders | **P0** | **Kadraj kapısı hareket kapısı değil — ve bunu pencere ölçütünü yazarken KENDİM uyarı olarak kaydetmiştim (L-086: "pencere görünürlük garantisi verir, tekrarın gerçekleştiğini DEĞİL"). Uyarı iki tur sonra veriyle gerçekleşti.** Hasat hattında hiçbir kapı "bu klipte hareket var mı" sorusunu sormuyordu; triyaj kadrajı, dedup kopyayı, netlik kaliteyi ölçüyor. Yazılı bir sınırın kapıya dönüştürülmemesi, sınırın olmaması kadar tehlikeli | **açık → L-094** | — |
| L-094 | **DÜZELTME** | **P0** | **L-092 YANLIŞTI — "4 fixture'ın 3'ü hareketi içermiyor" hükmüm hatalı.** `ref_check.py`'de "tepe fleksiyon" diye raporladığım değer aslında **p95**'ti, yani videonun GENELİ — ve genel, konuşma/hazırlık kareleriyle dolu. **Gerçek maksimumlar dört klipte de 178-180°.** Kesintisiz tutuş ölçütüyle: **1,0 · 4,1 · 5,2 · 0,1 sn** → 4'ün **3'ü** ≥1 sn baş-üstü tutuş içeriyor; yalnız `OtE8CdyRtuk` (0,1 sn) içermiyor. **Bu, gece boyunca düzelttiğim hatanın (video-geneli ortalaması yanlış şeyi ölçer — L-086/L-090) kendi analiz betiğimde tekrarıdır** ve üzerine hüküm kurdum. Ders: düzeltilen hata sınıfı, düzeltmeyi yapan kişinin kendi araçlarında da aranmalı | **kapalı** | ölçüm: `≥140° kare` 26/288/244/8 |
| L-095 | açık | **P1** | **Pasif↔aktif ROM ayrımı landmark'tan GÖRÜLEMİYOR — referans geçerliliği tehdidi.** Kaynakların üçü klinik muayene videosu ("Passive and Resisted", "Manual Resistance"): klinisyen kolu kaldırıyorsa landmark izi aktif uzanmayla AYNI. Pasif ROM tipik olarak daha geniştir, yani böyle bir referans kullanıcıya **ulaşılamaz hedef** koyar. `movementPresence` kapısı bunu ayırt EDEMEZ. Referans provisional işaretlenmeli ve insan-uzman turunda ilk sorulacak soru bu olmalı | **AÇIK** | — |
| L-096 | görev | P1 | **M-F-43 uygulandı: `romMode` rig'e bağlandı** (fail-closed · karışık kaynak=passive · provenance'a akıyor · blok [7] 7/7). Lissom'un 4 kaynağı: **active=1 · passive=2 · unknown=1** → `overhead_reach` referansı **KURULMADI**, M-F-43 doğrulandı | **kapalı** | motion-core `d4aa150` |
| L-097 | ölçüm | **P0** | **Kural doğru ama başlık-tek kanıtla kuyruğun %95'ini eliyor.** 272 aday başlıktan ön-sınıflandırıldı: **active 4 · passive 10 · unknown 258**. Başlıklar modu söylemiyor ("Deep Squat Assessment" hiçbir işaret taşımıyor). **Sonuç: transkript artık opsiyonel değil** — en güçlü işaretler yalnız konuşmada ("just relax, I'll move it for you") ve gece boyunca `--no-transcribe` koşmuştuk | **AÇIK** (M-talebi) | `docs/M-TALEBI-rommode-kapsam.md` |
| L-098 | öneri | **P1** | **Pasif icra her testte MÜMKÜN DEĞİL — kural doğru yere uygulanmalı.** Kimse birine pasif olarak squat yaptıramaz, plank tutturamaz, tek ayakta dengede durduramaz. **114 aday** ağırlık-taşıyan testlere ait ve orada `unknown` belirsizlik değil, mod zaten aktif olmak zorunda. Öneri: bataryada `passiveExecutionPossible` beyanı (varsayılan `true` = muhafazakâr). **Onay gelmeden Lissom'da ETKİNLEŞTİRİLMEDİ** — M-F-43 aile kuralı, kapsamı koordinatörün | **AÇIK** (onay bekliyor) | aynı belge |
| L-099 | hata | **P1** | **Kabuk betiğim URL listesinin SON satırını sessizce düşürüyordu.** `while read -r u` sondaki newline yoksa son satırı okumaz. `overhead_reach` turunda "13 aday" dediğim şey aslında **14**'tü; düşen aday `QlUhbo41GTg`. `lateral_bend`'de düşen aday `kB2woSanHPc` idi ve yeniden koşulunca **geçti** — sessiz atlama bize gerçek bir fixture'a mal olmuş | **kapalı** | `while read -r u \|\| [ -n "$u" ]` |
| L-100 | açık | **P1** | **`trunk_lateral_tilt` anatomik olarak imkânsız değerler üretiyor ve sebebi AÇIK.** `kB2woSanHPc` fixture'ında p90 **90,3°**, p99 **178°**, tepe **180°** — ayakta yana eğilmede mümkün değil (medyan 3,2°, ≥15° oranı %33,5). **Hipotezim yanlış çıktı:** düzlem projeksiyonunun eksikliğini sanmıştım, kanonik `mocore` ölçümüne devrettim, **aynı dağılım geldi**. Kaynakta (öne eğilme/yatma/çoklu kamera açısı) ya da izlemede (yanlış kişi/kısmi kadraj) bir sorun var ve **sayıdan ayırt edilemiyor** — görsel doğrulama gerek. 14 sn'lik "tutuş" bu yüzden GÜVENİLİR DEĞİL | **AÇIK** | referans bu fixture üzerine KURULMADI |
| L-101 | görev | P1 | **`lateral_bend` referansı da kurulmadı.** 3 aktif adaydan: 1 dikey format (Shorts), 1 bulanık (netlik 14), 1 geçti ama L-100 nedeniyle güvenilmez. **≥3 eşiği karşılanmıyor.** `fixture_check` kanonik `mocore` ölçümüne devredildi (elle yazılmış paralel geometri kaldırıldı) — mimari olarak doğru, anomaliyi açıklamıyor | **kapalı** (kurulmadı) | — |
| L-102 | görev | P1 | **M-F-45 uygulandı: `passiveExecutionPossible` 12/12 beyan edildi**, her satır kendi gerekçesiyle (varsayılmadı). Pasif icra MÜMKÜN DEĞİL (6): `deep_squat` `overhead_squat` `hip_hinge` `single_leg_balance` `forward_lunge` `plank_hold`. Politika triyaj profiline **türetilerek** yazılıyor (`movementRomPolicy`) ve bayatlık CI'da kırılıyor — batarya tek kaynak. `deep_squat`'ın 21 adayının **21'i** açıldı | **kapalı** | lissom `9542e4e` · core `0e8b80c` |
| L-103 | hata | **P1** | **Testim kendi eklediğim alanda konumsal-argüman kayması yakaladı.** `passive_execution_possible` alanını `sources_seen`'den ÖNCE eklemişim; konumsal `RomVerdict(...)` çağrılarında `sources` listesi bool slotuna kayıyordu ve **dolu liste truthy olduğu için muafiyet TERS çalışıyordu** (pasif-imkânsız iken bile uygun=False). Üç çağrı anahtar-kelimeye çevrildi + alan-sırası testi eklendi. Dataclass'a ortadan alan eklemek sessiz bir kırılma yüzeyidir | **kapalı** | blok [7] 11/11 |
| L-104 | ölçüm | P2 | **`deep_squat` presence eşiği testin kendi bantlarından TÜRETİLEMEDİ** — `scoring.bands` boş. Hareket tanımına dayandırıldı (dik duruş ~175-180°, eşik ≤110° = çömelmenin OLUP OLMADIĞI, derinlik değil) ve bu sınır gerekçeye açıkça yazıldı; bantlar geldiğinde gözden geçirilmeli. `lateral_bend`'de bantlardan türetilebilmişti (en düşük bant 18° → eşik 15°) | **açık** (bantlar bekleniyor) | — |
| L-105 | **DÜZELTME** | **P1** | **Fixture envanterim yanlıştı — kütüphane loglardan daha doluymuş.** "deep_squat 0 fixture" demiştim; sayım hasat LOGLARINDAN yapılıyordu. Kütüphanede **21 fixture** var: `hip_hinge` **5/5 bağımsız kanal**, `deep_squat` **4/4** — ikisi de M-F-38'in ≥3 eşiğini ÇOKTAN geçiyormuş. Ayrıca **manifest hangi hareket için toplandığını KAYDETMİYOR** (`--movement` geçiliyor ama yazılmıyor); eşleme kuyruk üzerinden yapılmak zorunda kaldı | **kapalı** (envanter doğru) | kütüphane taraması |
| L-106 | hata | P1 | **Dedup videoyu KENDİSİYLE kopya sayıyor.** `check_duplicate` mevcut video_id'yi dışlamıyor; indekste kayıtlı bir video yeniden koşulunca "kopya: X ile eşleşti" diyor — X'in kendisi. Yeniden hasadı imkânsız kılıyor ve mesaj yanıltıcı. (Ayrıca hamming eşiği 512-bit imzada 64 — gevşek, ayrı inceleme) | **AÇIK** | — |
| L-107 | hata | **P0** | **Fixture'lar ANATOMİK OLARAK İMKÂNSIZ değerler taşıyor ve hiçbir kapı süzmüyor.** `deep_squat`'ta diz fleksiyonu minimumları **0-3°** (tam bükülü diz ~30-40°; 0° baldırın uyluğa tamamen katlanması demek). L-100'deki `trunk_lateral_tilt` 180° anomalisiyle aynı sınıf. **Referans bu veriden TÜRETİLEMEZ.** Çözüm v3 şemasında zaten var: metrik `range` alanı — ama bizde beyan edilmemiş ve `range` config-yazımını korur, ÖLÇÜLEN veriyi süzmez. İkisi de gerekli | **AÇIK** | — |
| L-108 | ölçüm | P1 | **`deep_squat` yeterlilik kapısını GEÇTİ ama referans KURULMADI.** 4 fixture · 4 bağımsız kanal · 4/4 romMode-uygun · 4/4 hareket içeriyor · oturma-confound'u elendi (medyan diz 153-172° = ayakta, 4-26 iniş-çıkış döngüsü = dinamik). Kaynaklar arası tepe: **65/38/24/38°**, medyan 38°, **yayılım 41°, sd 17,2°** — konsensüs DAR DEĞİL. n=4'te M-F-38 varyans-türetimi yasaklıyor. **Engel: L-107.** ReferenceBuilder çekirdekte kod olarak YOK (blueprint'te tanımlı); app tarafında paralel sürüm YAZILMADI — `fixture_check`'te aynı hatadan dönmüştüm | **kapalı** (girdi ölçüldü) | — |
| L-109 | hata | **P0** | **`transcribe()` çıktı dizinini OLUŞTURMUYORDU — transkript zorunlu olur olmaz her başarılı aday çökecekti.** `out_dir.mkdir` yok; `FileNotFoundError` extract'ten SONRA patlıyor, yani fixture diske yazılıyor ama imza indeksine kaydedilmiyor → sonraki koşumda "kopya" sanılıyor. Sessiz aday (`TuQ4jYbazuw`) bu yüzden ne kabul ne red satırı üretmişti: traceback grep desenine uymuyordu. Gece boyunca `--no-transcribe` koşulduğu için bu yol HİÇ çalışmamıştı | **kapalı** | core `09a8681` |
| L-110 | çözüm | **P0** | **L-107 kapandı: fiziksel-aralık kapısı kanonik ölçüme eklendi.** 12/12 metriğe `range` beyan edildi (hareketin BEKLENEN aralığı değil, anatomik sınır). **Neden güven kapısı yetmiyor:** landmark YÜKSEK GÖRÜNÜRLÜKLE ama yanlış yerde kestirilebiliyor; `confidence` bunu göremiyor. **Ölçülen etki (deep_squat, 4 kaynak):** atılan kare 15/25/604/130 (Beam With Jim ~%10 artefakt); tepe değerleri 65/38/24/38° → **65/39/37/41°**, yayılım 41°→**29°**, sd 17,2→**13,4** | **kapalı** | core `712f329` |
| L-111 | ölçüm | P1 | **Süzülmüş veride konsensüs göründü: 4 kaynağın 3'ü 37-41° (4° içinde), dördüncüsü 65°'de tek başına** (Man Flow Yoga — yoga bağlamı, muhtemelen daha sığ çömelme ya da farklı kamera açısı). ReferenceBuilder'ın ≥3-konsensüs mantığının tam da ayıklaması gereken desen. Motor çekirdekte kod olarak YOK; app tarafında paralel sürüm YAZILMADI (`fixture_check`'te aynı hatadan dönmüştüm) — girdi ölçülüp devredildi | **kapalı** (girdi hazır) | — |
| L-112 | ölçüm | P1 | **`hip_hinge`: 5 fixture → hareket kapısından 3'ü geçti.** Kalan ikisi gerçek red: `lPOdTeASiyY` tepe **18°**, `v0iMLWtkHD4` tepe **35°** — 45° eşiğine hiç yaklaşmıyor. Muhtemel sebep kaynak uygunluğu: test "kameraya YANDAN dön" diyor, önden çekilmiş videoda sagittal izdüşüm öne katlanmayı olduğundan az okur. `idHgOkqvtKU`'da range kapısı **1488 kare** attı (ham tepe 180° — Gymnastics BC, ters duruş içeriyor) | **kapalı** | — |
| L-113 | **öneri** | **P0** | **≥3 SAYI kapısı yeterli değil — ANLAŞMA kapısı da gerekiyor.** İki test de M-F-38'in ≥3 eşiğini geçiyor ama veri kalitesi taban tabana zıt: `deep_squat` 65/39/37/41° (yayılım **29°**, üçü 4° içinde) · `hip_hinge` 67/23/112° (yayılım **88°**, sd **44,2**). 23°-112° arasından türetilecek bir referans anlamsız bir hedef üretir. **Öneri:** ReferenceBuilder'a kaynak-arası dağılım kapısı — eşik aşılırsa referans kurulmaz, aykırı kaynak raporlanır. `hip_hinge` bu haliyle referansa DÖNMEMELİ | **AÇIK** (koordinatör kararı) | — |
| L-114 | görev | P1 | **İki test de CLI köprüsü için hazır.** `deep_squat` 4 kaynak (3'ü 37-41°) · `hip_hinge` 3 kaynak (dağınık). Zincir her ikisinde de aynı: romMode uygunluk → triyaj+pencere → `movementPresence` → fiziksel-aralık süzgeci → kaynak-arası tepe ölçümü. ReferenceBuilder Dart'ta VAR (`packages/motion_core/lib/src/scoring/reference_builder.dart`); eksik olan fixture-JSON→CLI köprüsü, koordinatörün kuyruğunda | **kapalı** (girdi hazır) | — |
| L-115 | **DÜZELTME** | P1 | **L-112'deki "önden çekim" açıklamam ÖLÇÜMLE ÇÜRÜDÜ.** Reddedilen iki `hip_hinge` kaynağının önden çekildiğini varsaymıştım. `shoulder_line_foreshortening` ölçümü tersini söylüyor: Core Exercise Solutions **reddedildi** ama medyan **0,28** = tam YANDAN (ideal açı); Dr. Mitch Israel **geçti** ama **0,65** = daha önden. Bakış açısı ile `trunk_lean` okumaları arasında ilişki YOK. Redler gerçek (veride menteşe yok) ama gerekçem desteksizdi | **REDDEDİLDİ (kapalı) — YOL: "önden çekim" açıklaması · ÖLÇÜM: `shoulder_line_foreshortening` medyan 0,28 çürüttü** | — |
| L-116 | **öneri** | **P1** | **`cameraView` metadata'dan DEĞİL, ÖLÇÜLEREK belirlenmeli — `romMode` deseni burada geçerli değil.** `romMode` metinden sınıflandırılıyor çünkü pasif/aktif ayrımı landmark'ta GÖRÜNMÜYOR (klinisyen kolu kaldırınca iz aynı). Bakış açısı için bu gerekçe yok: `shoulder_line_foreshortening` doğrudan ölçüyor ve kaynaklar arasında net ayrışıyor (medyan **0,25-0,65**). Metinden parse etmek, zaten elimizde olan bir ölçümü zayıf bir vekile çevirir. **Öneri:** sagittal-ölçümlü testlerde kaynak-uygunluk kapısı ölçülmüş kısalma değerine dayansın; alan `provenance`'a ölçüm olarak yazılsın | **AÇIK** (koordinatör kararı) | ölçüm yukarıda |
| L-117 | hata | **P0** | **Test talimatları ile kanonik sagittal projeksiyon ÇELİŞİYOR — 8/12 test etkileniyor.** Sagittal düzlemli her test kullanıcıya *"stand side-on to the camera"* diyor. Ama `project(v,"sagittal")` sol-sağ bileşenini atar: kişi kameraya **dönükse** öne eğilme derinlik ekseninde kalır ve korunur; **yandan** durursa öne eğilme sol-sağ eksenine düşer ve projeksiyon onu **ATAR**. **Sentetik ölçüm:** kısalma 0,80 (dönük) → sapma **0,0°** · 0,69 → 3,7° · 0,61 → 7,0° · 0,51 → 11,9° · 0,40 (yandan) → **19,1°**. Yani talimat, ölçümün en kötü çalıştığı duruşu istiyor | **AÇIK** | sentetik yaw taraması |
| L-118 | ders | **P0** | **L-117, L-031'in (Dart görüntü-düzlemi ↔ Python 3D-world uzay uyuşmazlığı) somut tezahürü.** İki uzayda DOĞRU CEVAP TERS: görüntü düzleminde ölçüm yapılıyorsa yandan çekim doğrudur (öne eğilme iyi çözümlenen x-y düzleminde kalır); world uzayında sagittal projeksiyonla ölçülüyorsa kameraya dönük olmak doğrudur (ama o zaman ölçüm MediaPipe'ın en gürültülü ekseni olan derinliğe bağlanır). **Kaynak-uygunluk eşiği bu çelişki çözülmeden KONULAMAZ** — hangi yönde eşik koyacağımız kanonik uzayın hangisi olduğuna bağlı ve iki yön birbirinin tersi | **AÇIK** (koordinatör kararı) | — |
| L-119 | **DÜZELTME** | **P0** | **`overhead_reach`'in uygun kaynak sayısı 1 değil SIFIR.** 8 fixture transkriptle yeniden sınıflandırıldı: **5 passive · 3 unknown · 0 active**. En kritiği `cP4LLJie9kw` — **aktif** dediğim, hareket kapısını 6,0 sn ile geçen, "gerçek baş-üstü uzanma içeren tek klip" diye raporladığım kaynak — transkriptte `passive` + `resisted` geçiyor ve **passive**'a döndü. Başlığı ("Active Range of Motion: Shoulder") yalnız eksik değil, **YANILTICIYDI** | **kapalı** | `/tmp/reclass.log` |
| L-120 | ders | **P0** | **Başlık-tek romMode sınıflandırması güvenli değil — yalnız `unknown` üretmiyor, YANLIŞ `active` de üretiyor.** 8 kaynaktan 2'si transkriptle değişti, **ikisi de daha kısıtlayıcı yöne** (`unknown→passive`, `active→passive`). Bu, kod yorumumdaki "yeniden koşum yalnız daha izinli yöne döner" iddiasını çürüttü. M-F-45 muafiyetiyle birleşince sonuç ağır: muafiyetli harekette `unknown` UYGUNDUR, transkript onu `passive` yaparsa uygunluk KALKAR — **transkript atlanırsa kapı gevşek kalır** | **kapalı** (kod düzeltildi) | core `a2a64a9` |
| L-121 | ölçüm | P1 | **Transkript her şeyi çözmüyor:** 3 kaynak (`GaP20t6ZOfU` `HVQ1YNtw_yQ` `PfpJnU8x1kU`) transkriptle de **hiçbir mod işareti taşımıyor** → `unknown` kalıyor. Fail-closed gereği referansa giremiyorlar. `overhead_reach` izole-eklem testi olduğu için M-F-45 muafiyeti YOK; bu testin referansı **aktif kaynak bulunana dek kurulamaz** ve mevcut 8 fixture'ın hiçbiri işe yaramıyor | **AÇIK** | yeni kaynak araması gerekli |
| L-122 | hata | **P0** | **"Herhangi bir pasif işaret → PASSIVE" kuralı YANLIŞ POZİTİF üretiyordu ve teslimatı öldürüyordu.** `deep_squat`'ın 4 kaynağından 2'si transkriptle elendi; bağlama bakınca ikisi de yanlıştı: *"level one is the deep squat **with an assist** using something in front of you"* (kişi KENDİ tutunuyor, progresyon seviyesi) · *"with more **resistance** or with more body weight"* (YÜK) · *"**mobilization** and soft-tissue pliability techniques" (videonun öğrettiği konu). **Yanlış pozitif asimetrik zarar verir: iyi kaynağı ÖLDÜRÜR** — muhafazakârlık adına konulan kural kaynak havuzunu sistematik yok ediyordu | **kapalı** | core `214a66a` |
| L-123 | çözüm | **P0** | **GÜÇLÜ/ZAYIF işaret ayrımı.** Güçlü = hareketi BAŞKA BİRİNİN ürettiğini açıkça söyler (`passive` `PROM` `therapist` `examiner` `over pressure` `"let me move"` `"relax your arm"`) → aynen eler. Zayıf (`assist` `resistance` `mobiliz`) → tek başına elemez, kaydedilir. **Doğrulama: hiçbir doğru tespit kaybedilmedi** — `overhead_reach`'in 4 passive kaynağının hepsi güçlü işarete dayanıyor, 0/8'de kaldı; `deep_squat` 4/4'e döndü | **kapalı** | blok [7] 18/18 |
| L-124 | ölçüm | **P1** | **Transkriptli nihai tablo:** `deep_squat` **4/4 uygun** (`TuQ4jYbazuw` active · `YG-iGrQvw44` active · diğer ikisi unknown+M-F-45 muafiyeti) → **≥3 KARŞILANIYOR, CLI köprüsünü bekliyor.** `overhead_reach` **0/8** — dördü güçlü-işaretli passive, dördü unknown ve izole-eklem testi olduğu için muafiyet YOK; **mevcut 8 fixture'ın hiçbiri işe yaramıyor**, yeni aktif kaynak gerekli. `hip_hinge` transkriptleri koşuyor | **kısmen açık** | — |
| L-125 | ölçüm | **P1** | **NİHAİ UYGUNLUK (transkript + güçlü/zayıf ayrımı):** `deep_squat` **4/4** ✅ (TuQ4jYbazuw active · YG-iGrQvw44 active · ikisi unknown+M-F-45) → **CLI köprüsünü bekliyor** · `hip_hinge` **2/3** ❌ · `overhead_reach` **0/8** ❌ | **kapalı** | — |
| L-126 | ölçüm | P1 | **`hip_hinge`'de ÜÇ BAĞIMSIZ SİNYAL aynı kaynağı işaret etti — kapı yığını kendini doğruladı.** `idHgOkqvtKU` (Gymnastics BC): (1) romMode **passive**, güçlü işaret (`passive`) → uygunluk dışı, etiket `demo-mode-mismatch`; (2) fiziksel-aralık kapısı **1488 kare (%18)** attı → `tracking-artifact` eşiğinin üstünde; (3) `trunk_lean` **112°** ile 88°'lik dağılımın baş sorumlusu. Üç ayrı gerekçeyle aynı hüküm. Dışlanınca `hip_hinge` **2 kaynağa** düşüyor: artık yalnız anlaşma kapısında değil **SAYI kapısında** da takılıyor (kalan ikisi 67° ve 23°, aralarında 44° var) | **kapalı** | — |
| L-127 | görev | P1 | **`hip_hinge` → KAYNAK-YETERSİZ, BEKLEMEDE.** 3 fixture'ın 1'i romMode `passive` (güçlü işaret) → 2 uygun kaynak kaldı, ≥3 sağlanmıyor. Kalan ikisi 67° ve 23°, aralarında **44°** var; üçüncü kaynak gelse bile M-F-47'nin ≤14° anlaşma kapısını geçmesi zor. Yeni kaynak aranmadan referansa dönmez | **beklemede** | — |
| L-128 | görev | P1 | **Kanonik-uzay karar brifi yazıldı** (`docs/KARAR-BRIFI-kanonik-uzay.md`). Üç seçenek: (A) projeksiyon kalır, talimatlar "face the camera"a döner — ölçüm en gürültülü eksene bağlanır · (B) talimatlar kalır, projeksiyon görüntü düzlemine döner — 3D bilgisi atılır · **(C) ÖNERİLEN: düzlemler landmark'tan TÜRETİLİR** (kalça+omuz hattı → medial-lateral eksen), kamera yönelimine bağımsız. Fizibilite doğrulandı: ek landmark gerekmiyor. Bloke ettiği işler: `view-unsuitable` türeticisi · 8 testin talimat metni · L-031 kapanışı | **AÇIK** (koordinatör kararı) | — |
| L-129 | **DÜZELTME** | P1 | **"`overhead_reach` kuyruğunda 21 aday daha var" YANLIŞTI — kuyruk TÜKENMİŞ.** 29 adayın 29'u işlenmiş, işlenmemiş **0**. Rakamı daha dar bir log kümesinden hesaplamıştım. Sonuç: bu testin kaynakları mevcut kuyruktan **bitmiştir**; 8 fixture'ın hepsi uygunsuz ve yeni aday kuyruk DIŞINDAN bulunmalı | **kapalı** | — |
| L-130 | çözüm | **P0** | **M-F-54 taksonomisi uygulandı — yaw sapması TÜM kategorilerde sıfırlandı.** `trunk_lateral_tilt` 16,57→**0,00** · `trunk_lean` 11,11→**0,00** · `hip_flexion` 16,96→**0,00** · `shoulder_flexion` 14,14→**0,00** · `knee_flexion` 2,80→**0,00** · `elbow_extension` 0,14→**0,00** · `shoulder_line_foreshortening` 0,11→0,11 (kasıtlı: `camera`). A1-A11 **iki modda da** yeşil | **kapalı** | core `feat/lissom-v3-onayi` |
| L-131 | hata | P1 | **`proximal` ilk koşumda hiç etki etmedi — regexim çağrıları atlamıştı.** `project(a - b, plane)` biçimindeki çağrılar `\w+` desenine uymadığı için `axes` hiç ulaşmıyordu; iki kolon da 16,96° veriyordu. "Aynı sayı iki modda" bunun imzasıydı. Bu, gecenin tekrar eden sınıfı: **özellik yazıldı ama hedef yoldan geçmiyor** (L-050·L-062·L-063 ile aynı) | **kapalı** | 2 çağrı düzeltildi |
| L-132 | görev | **P1** | **Kaynak-arama turu (Protokol v1) — HAVUZ KURU DEĞİL.** 6 arama terimi (TR+EN) → **85 aday / 71 farklı kanal** filtreden geçti (≥90sn, kütüphane+kuyruk dedup, kullanılmış-kanal karalistesi). En uzun 40'ı altyazıdan sınıflandırıldı → **9 YENİ bağımsız eğitmen** romMode-uygun. Hedef ≥3, bulunan **9** ✅ | **kapalı** | `/tmp/source_search_result.json` |
| L-133 | ölçüm | P1 | **"9 uygun" ZİNCİRE GİREN sayıdır, hayatta kalan değil.** Bu adaylar yalnız romMode kapısını geçti; triyaj (kadraj/netlik/süre), `movementPresence` ve fiziksel-aralık kapıları HENÜZ koşulmadı. Tarihsel yıpranma ağır: `overhead_reach`'te 29 aday → 8 fixture → 0 uygun. Fark şu ki bu kez romMode ÖN-filtre olarak kullanıldı, yani başlangıç noktası çok daha iyi — ama 9'un kaçının fixture'a döneceği ölçülmeden bilinemez | **açık** | — |
| L-134 | sınır | P2 | **Kuru-havuz hükmü VERİLEMEZ: 45 aday maliyet nedeniyle altyazı turuna alınmadı.** Betik bunu sessizce kırpmıyor, açık uyarı basıyor. "Havuz kuru" meşru bir sonuç ama bu turda kanıtlanmadı — tersine, incelenmeyen 45 aday duruyor | **açık** | — |
| L-135 | hata | **P0** | **M-F-57 sessiz-hiçlik Lissom'da DA var — 3 testte, ve en çok ihtiyacı olan kullanıcıyı vuruyor.** Ölçüm fazı (`peak_hold`) bir eşik istiyor ama birincil metrik üzerinde **hiçbir testte hata kuralı yok**: `overhead_reach` kapı **≥60°** (en düşük skor bandı 130°) · `ankle_dorsiflexion` **≥15°** · `lateral_bend` **≥15°** (en düşük bant 18°). Eşiğin altında kalan kullanıcı ne ölçüm ne uyarı alıyor — test **hiç tamamlanmıyor** ve sebebi söylenmiyor. **Donmuş omuzla 50°'ye ulaşabilen biri tam olarak hiçbir şey görmez**; oysa uygulamanın var olma sebebi o kişi | **kapalı** (M-F-71 hükmü uygulandı) | L-150 |
| L-136 | öneri | **P1** | **Çözüm yönü: `deep_squat` deseni.** O test derinlik kapısı KULLANMIYOR — ölçüm fazına hızın yavaşlamasıyla giriliyor (`delta > -15°/s`), yani her tekrar nerede biterse orada ölçülüyor ve düşük değer dürüstçe raporlanıyor. Bu yüzden sessiz-hiçlik üretmiyor. Öneri: üç testte de ölçüm kapısı metrik-eşiğinden hız-tabanlı tepe tespitine çevrilsin (v3'ün `localMax`'ı tam bu iş için), skorlama bandının altındaki sonuç `RESULT_BELOW_RANGE` gibi bir kodla **söylensin**. Eşik değerlerini tek başıma değiştirmedim: skorlamayı etkiliyor, ürün kararı | **kapalı** (koordinatör önerimi M-F-71 ile onayladı) | `docs/M-TALEBI-sessiz-hiclik-olcum-kapisi.md` · L-150 |
| L-150 | çözüm | **P0** | **M-F-71 UYGULANDI — 5 maddenin hepsi.** (1) 3 testin `peak_hold.enter`'ı delta-only (deep_squat/hamstring_reach deseni), `phases` v1.1.0→1.2.0. (2) Girişim algılanınca ölçüm daima tamamlanıyor — eski 60/15/15° mutlak-eşik `enter`'dan tamamen kaldırıldı. (3) Eski değerler skor-bandı rolüne not düşüldü (kod değişikliği gerektirmedi — bantlar zaten "low" altını doğal biçimde temsil ediyordu). (4) **Her 44 terminal-olmayan faza `timeoutCode` eklendi** + `phase_check.py`'ye değişmez #8 (timeoutCode zorunlu, L-146'nın yakaladığı kaçış artık linter'da kapı). (5) `threshold_gate_scenario_test.py`'de sonuç sınıflandırması `coached_below_range` (skorlanan değil). **Yan-bulgu:** `ankle_dorsiflexion`'ın `movementPresence`'ı hiç beyan edilmemiş çıktı (M-F-71 öncesi hiç sınanmamıştı) — provisional 15° ile eklendi (`lissom-assessment` 1.4.0→1.5.0), gerçek fixture'la yeniden türetilmeli. **Kabul kanıtı ikisi de yeşil:** `phase_check_selftest.py` (linter timeoutCode/abortCode eksikliğini yakalıyor, temiz config'i geçiriyor) · `threshold_gate_scenario_test.py` (3 testte eski kapı sessiz-timeout, yeni kapı ölçüyor + doğru katmana koyuyor). Mevcut tüm kontroller (config_check/phase_check/wellness_lint+selftest/triage_landmarks) yeşil kaldı | **kapalı** | `f2816be` origin'de |
| L-137 | **DÜZELTME** | **P0** | **`deep_squat` anlaşma kapısından GEÇMEDİ — ve "3'ü 4° içinde" iddiam yanıltıcıydı.** Kanonik CLI (v0.7.0) reddetti: take sapmaları **44,8 / 44,4 / 39,0 / 29,3°** (eşik ≤14°). **Hipotezim çürüdü:** segmentasyonsuz take'lerin boşta kareleri sanmıştım; hareket penceresine kırpınca sapmalar neredeyse değişmedi (40,4 / 42,6 / 39,1 / 23,8). Anlaşmazlık GERÇEK. Sebep: ben **tek eklem** (diz tepe değeri) ölçmüştüm, CLI çok-eklemli. Eklem bazında yayılım: `hip_flexion` **94°** · `knee_flexion` 34° · `tibia_inclination` 25° · `trunk_lean` 19° | **kapalı** (düzeltildi) | CLI çıktısı |
| L-138 | hata | **P0** | **`movementPresence` kapım YALNIZ birincil metriğe bakıyor — dizi büken ama çömelme OLMAYAN hareketi geçiriyor.** `U5qlAYuZzCg` (Advanced PT) kapıyı 24,2 sn ile geçmişti; oysa medyan `hip_flexion` **152°** (kalça neredeyse AÇIK) ve `knee_flexion` 51°. Diz bükük + kalça açık = diz çökme / yüzüstü diz bükme, çömelme DEĞİL. Kapı tek metrikle "hareket var" dedi, hareketin KENDİSİ farklıydı. Aynı sınıf: tek sinyalle çok-eklemli bir hareketi doğrulamak | **kapalı** (`identity_check` L-139'un ölçtüğü eşiği tüketiyor, canlı doğrulandı) | L-149: `fixture_check.py` `U5qlAYuZzCg`'yi `hipKneeCoupling=-0.46` ile isimle reddetti |
| L-139 | **ölçüm** | **P1** | **Kalça-diz bağlaşım ölçüsü tanımlandı ve eşiği VERİDEN türetildi (M-F-60).** Tanım: **`r` = hareket penceresinde `hip_flexion` ile `knee_flexion` arasındaki Pearson korelasyonu.** Çömelmede ikisi BİRLİKTE kapanır → pozitif. Ölçüm: iyi kaynaklar **+0,56 / +0,45 / +0,57** · şüpheli kaynak **−0,46**. **İşaret dönüyor** — yani ayrım kategorik, ince eşik ayarı değil. Diz büküldükçe kalça AÇILIYOR, bu bir çömelme değil. Önerilen eşik **r ≥ +0,20**: iyi kümenin en düşüğünün (0,45) yarısı, kötüden 0,66 uzak. İkincil sınır: **en derin dizde kalça ≤110°** (iyi 68/46/55° · kötü **151°**) | **kapalı** (ölçüm) | 4 fixture |
| L-140 | sınır | P2 | **Eşik n=4 ve tek negatif örnekle türetildi — provisional.** Sağlam olan şey **işaretin kendisi** (pozitif↔negatif), sayısal eşik değil; +0,20 muhafazakâr bir taban olarak seçildi, kalibre edilmiş değil. Daha çok kaynak geldikçe gözden geçirilmeli. `movementPresence` bu ölçüyü rig'in `perMovement` kimlik-config'inden TÜKETECEK, kendi sözlüğünü kurmayacak (M-F-60) | **açık** | — |
| L-141 | görev | **P1** | **9-aday zinciri: 8 fixture, 6 uygun, 6/6 hareket kapısını geçti.** GİREN 9 eğitmen → HAYATTA **6 bağımsız eğitmen** (`Strength Side` · `Virtual Hand Care` · `Fitness For Freedom` · `Fraser Wilson` · `Hooper's Beta` · `Comeback Performance`). Elenenler: 1 netlik (38<40, sınırda) · 2 romMode `passive` (`therapist` güçlü işareti). `overhead_reach` 0'dan **6 uygun kaynağa** çıktı | **kapalı** | — |
| L-142 | hata | P1 | **Arama ön-filtrem AÇIKLAMA alanını okumuyordu.** Aramada başlık+altyazı bakıp `active` dediğim 2 kaynak, hasatta başlık+**açıklama** ile `passive` çıktı (`therapist`). Yani ön-filtre hasattan DAHA ZAYIF; 2 aday boşuna indirildi. Sınıflandırma hangi metin alanlarına bakıldığına bağlı ve alanlar ayrışabiliyor | **açık** | arama betiğine açıklama eklenmeli |
| L-143 | hata | **P0** | **Kanonik CLI ÇÖKÜYOR ve çöküşü "kapı reddi" gibi raporluyor.** `overhead_reach` 6 kaynakla: *"REDDEDİLDİ (sayı/kaynak kapısı): Invalid value"* — bir politika reddi gibi görünüyor. Tek fixture + `--min-takes 1 --min-sources 1` ile izole edilince gerçek sebep çıktı: **`Bad state: No element` · `ReferenceBuilder._deviationsFromConsensus` (reference_builder.dart:692) · boş listede `List.first`**. Kod kusuru veri sorunu gibi sunuluyor — saatler kaybettirebilecek sınıf. (Anlaşma kapısı bundan etkilenmiyor: `deep_squat` reddi gerçek sayılarla geldi) | **kapalı** (koordinatör 0.7.3'te düzeltti) | `motion_core-v0.7.3` (`1e8d7a8`) — kanıt: L-147 |
| L-147 | ölçüm | P1 | **0.7.3 ile overhead_reach kanonik CLI koşumu — L-143 doğrulandı düzeldi, YENİ bulgu: gizli 6. dışlama.** 6 kaynaktan yalnız 5'i `takes`e girdi: `Virtual Hand Care` (`6u_rV3C80wU`) eligibility=`attested` ama **20978/20978 kare güven-kapısından düştü** (muhtemelen kadraj hep el/bilek yakın-çekimi — omuz/kalça nadiren görünür), `noMeasurableFrames` ile isimle dışlandı (çöküş YOK, 0.7.3 çalışıyor) — ama bu dışlama yalnız `prepareTake` raporunda var, `ReferenceAgreementError` yoluna hiç YANSIMADI (havuz 3'ün altına inmediği için "pool thinned" dalı hiç tetiklenmedi); CLI çıktısını okuyan biri 6. kaynağın var olduğunu bile bilemez. Kalan 5 (tam-video, `cycleCount: null`) **anlaşma kapısından REDDEDİLDİ** (eşik 14°): Fraser Wilson 55,7° · Strength Side 59,6° · Fitness For Freedom 42,0° · Comeback Performance 51,7° · Hooper's Beta 50,4° — hepsi L-139'un imzası (segmentasyonsuz tam-video DTW'si). Sonuç: `overhead_reach` şu an dürüstçe referans KURAMIYOR, ama artık gerçek sayılarla | **kapalı (L-143) / açık (agreement + gizli-dışlama + 0.8.0 bekliyor)** | worktree koşumu — ayrıntı koordinatöre mesajda |
| L-144 | görev | P1 | **İki dışlanan kaynak NEDENİYLE işaretlendi (M-F-51), sadece düşürülmedi.** `TuQ4jYbazuw` → **`intent-variant`** (kaynak `channel`): yoga bağlamı, diz medyanı 80° vs diğerleri 46/46°; kaynak KENDİ bağlamında doğru, bizim tanımımız strength/mobility'den geliyor. `U5qlAYuZzCg` → **`different-movement`** (kaynak `measurement`): `hipKneeCoupling` −0,46, en derin dizde kalça 151° — diz çökme/yüzüstü diz bükme. Etiketler hem manifeste hem fixture provenance'ına yazıldı | **kapalı** | — |
| L-145 | doğrulama | P1 | **L-139 hipotezim tasarım gerçeğiyle doğrulandı** (koordinatör): CLI'da çevrim segmentasyonu YOK; ReferenceBuilder tam açı-serilerini DTW'yle medoide büküyor ve farklı tekrar-sayılı videolarda çevrim sınırlarını ezmek zorunda — 34-43°'lik sapmaların kaynağı bu. `cycleCount: null` tam bu yüzden dürüst. Önerdiğim ayırt-edici sınama (aynı kaynaktan iki rep-segmenti → sıfıra yakın sapma) 0.8.0'ın kabul-testi oldu | **kapalı** | — |
| L-146 | denetim | P2 | **İki gece-deseni kendi 6 aracımda (`tools/*.py`, 1001 satır) tek tek arandı.** "Video-geneli ortalaması yanlış şeyi ölçer": **bulunmadı** — `fixture_check.py` (`longest_hold_s`, kesintisiz-tutuş penceresi), `identity_check` (yalnız hareket penceresi `win`) hepsi zaten pencereli; muhtemelen L-080/L-092/L-093 sertleşmelerinin kalıcı sonucu. "Özellik yazıldı ama hedef yoldan geçmiyor": **YENİ bir örneği bulundu** — `phase_check.py` yalnız `timeoutMs` VARLIĞINI (sonsuz park koruması) ve `abort`→`abortCode` EŞLEŞMESİNİ doğruluyor; bir fazın düz TIMEOUT'la (abort değil) bitmesi durumunda kullanıcıya bir SONUÇ kodu ulaşıp ulaşmadığını hiç sormuyor. Bu tam olarak L-135'in linter'dan kaçış yolu: `peak_hold`'a hiç girilmeden `raising`/`bending` timeout'u sessizce düşüyor, kapı "yazılı" ama "hedef yolu" (kullanıcıya ulaşan bir kod) hiç sınanmıyor — L-131 ile aynı sınıf, denetim katmanında | **kapalı** (M-F-71 madde 4 — değişmez #8 eklendi, L-150) | tools/*.py tam okuma · `phase_check_selftest.py` |
| L-148 | ölçüm | P1 | **0.8.0 ile overhead_reach yeniden koşuldu — sayılar DEĞİŞMEDİ, ve doğru sebeple.** Aynı 5 kaynak, aynı sapmalar (55,7/59,6/42,0/51,7/50,4°). Sebep: `CyclePeriodEstimator` 5'inin 5'inde de `measured=false, reason="moving but not repeating"` — `overhead_reach` bir tek-tutuş (rom_sweep) testi, tekrarlı-çevrim İÇERMİYOR, segmentasyonun bulacağı bir periyot yok. `cycleSegmentation.state` kalıyor: `notApplied`. Yani L-139 düzeltmesi bu testte YAPISAL OLARAK devreye giremiyor — 42-60°'lik anlaşmazlığın kaynağı segmentasyon DEĞİL; ya gerçek kaynaklar-arası tanım farkı ya tam-videonun squat-dışı bölümlerinin (giriş/konuşma) DTW'ye karışması. İkincisi ölçülmedi — ayrı bir soru. **0.8.1 doğrulaması** (koridor zamansal düzeltmesi — 5 kaynak gerçekten karışık fps: 24/24/60/24/25): sapmalar 55,6/59,7/42,2/51,8/**52,1**° — en büyük fark gsz3BLAkkQ4'te 50,4→52,1° (+1,7°). Küçük ama gerçek kayma; hüküm DEĞİŞMEDİ, hâlâ RET | **açık (agreement + kök neden ayrışmadı)** | worktree koşumu (probe: `CyclePeriodEstimator.estimate`) · 0.8.1 doğrulaması |
| L-149 | ölçüm | P1 | **M-F-60(1) planı uygulandı: ÖNCE kapı, SONRA yeniden ölçüm — L-138 canlı doğrulandı, deep_squat yine reddedildi ama artık farklı sebeple.** 4 aday fixture'a (`TuQ4jYbazuw`/`YG-iGrQvw44`/`yWfMPZWHnVw`/`U5qlAYuZzCg`) önce kendi `identity_check`'imi (fixture_check.py) koştum: **`U5qlAYuZzCg` `hipKneeCoupling=-0,46` ile isimle-sebeple reddedildi** (L-138 kapandı, gerçek veriyle çalışıyor), kalan 3 geçti. 3'ü 0.8.0 CLI'a verildi (`--allow-unattested`: 2'sinin fixture provenance'ında `referenceEligible` alanı hiç yok — eski hasat, romMode pipeline'ından önce). **Sonuç yine RET** (M-F-47, eşik 14°): TuQ4jYbazuw 43,5° · YG-iGrQvw44 39,2° · yWfMPZWHnVw 34,1°. Cycle segmentasyon probu: **3'ü de `measured=false`** ("no prominent ACF peak") — bunlar da tekrarlı-set değil, TEK-gösterim değerlendirme videoları (başlıklar: "Deep Squat Assessment", "How To Assess Your Squat", "Squat Assessment"). **L-139'un çözdüğü sınıf (çok-tekrarlı DTW ezmesi) bu 3 fixture'a hiç uygulanmıyor** — kalıcı anlaşmazlık (34-43°) tek-gösterim squat DERİNLİĞİ yorumundaki gerçek kanal-arası fark olabilir, ya da tam-video kırpılmamışlığının (giriş/konuşma karışması) bir başka görünümü. `deep_squat` şu an dürüstçe referans KURAMIYOR; L-138 kapısı çalışıyor ama havuz (3 kaynak, hepsi tek-gösterim) M-F-47'yi geçecek kadar dar değil. **0.8.1 doğrulaması** (3'ü de karışık fps: 30/25/30): sapmalar 43,7/39,4/34,2° — hepsi +0,1-0,2° kaydı, hüküm DEĞİŞMEDİ, hâlâ RET | **açık (agreement + kök neden ayrışmadı — muhtemelen segmentasyon-DIŞI bir sınıf, koordinatöre bırakıyorum)** | worktree koşumu — TuQ4jYbazuw/YG-iGrQvw44/yWfMPZWHnVw/U5qlAYuZzCg · 0.8.1 doğrulaması |
| L-154 | hata | **P0** | **`fixture_check.py` M-F-54 taksonomisini HİÇ uygulamıyormuş — Gravita'nın G-064 diferansiyel test talebiyle bulundu.** `_series()` `mz.evaluate(md, frame)`'i `anatomical` bayrağı OLMADAN çağırıyordu; varsayılan `False` = "eski davranış, dünya ekseni" (measures.py'nin kendi belgesi). `gate_g1a.py` bu bayrağı `MOCORE_ANATOMICAL` env-var'ından okuyordu, `fixture_check.py` hiç okumuyordu — L-131/L-146 sınıfının bir örneği daha (config beyan ediyor, kod uygulamıyor). **Etkilenen: L-138/L-139/L-150'nin dayandığı hipKneeCoupling ölçümü hiç `proximal` çerçevesini kullanmamıştı.** Düzeltildi (`MOCORE_ANATOMICAL` bayrağı eklendi, varsayılan davranış AYNI kalıyor — sessiz geriye-dönük değişim yok). **Yeniden ölçüm** (4 deep_squat fixture, doğru çerçeveyle): +0,31/+0,77/+0,62/**-0,07** (eskisi +0,56/+0,45/+0,57/-0,46). **Kapı KARARI değişmedi** (4'ü de hâlâ 0,20 eşiğine göre aynı tarafta, U5qlAYuZzCg hâlâ reddediliyor) ama L-139'un "işaret döner, ayrım kategorik" iddiası zayıfladı — kötü örnek artık -0,46 değil -0,07, neredeyse sıfır. Eşiği (0,20) DEĞİŞTİRMEDİM — yalnız `basis` metnini düzeltip düzeltilmiş sayıları ekledim; eşiğin yeniden türetilip türetilmeyeceği koordinatör/Gravita kararı | **açık (eşik yeniden-değerlendirme koordinatörde — Gravita'ya iletildi)** | `fe3ce4a` — 4 fixture çift-ölçüm (anatomical açık/kapalı) |
| L-152 | çözüm | **P0** | **`presence_isolator` implement edildi (M-F-85) — motion-core `feat/presence-isolator` pushlu, koordinatör incelemesi bekliyor.** `tools/harvest_rig/presence_isolator.py`: sürücü sinyal HIP→SHOULDER→ELBOW 3-nokta açısı (ham görüntü-düzlemi, mocore'un tam geometrisi değil — pencereyi BULMAK için yeterli proksi, skorlamak için değil), eşik+süre tabanlı (L-135'in hız-kapısı hastalığını PAYLAŞMIYOR — kendi self-test'i kanıtlıyor). `hold_isolator`'ın M-O-41/42/43 derslerini import'la yeniden kullandı (görünürlük+gövde-dörtlüsü aynası, kapsam aşağı-akış setine daralır) — yeniden türetmedi. 9 self-test senaryosu: hedef-hareket kabulü · **KONUŞMA-JESTİ reddi (L-151'in ölçtüğü 116,9→10,5→6,8→36,2→114,0 dizisi bire bir sentetikleştirildi — hepsi geçti)** · yavaş-sürüklenme (6sn'de kalkan GERÇEK hareket, KABUL — L-135 hastalığı yok kanıtı) · bel-üstü scope (fullBody ret / upperBody kabul) · iki-hız · gövde-güvensiz ret · **J-052-v2 required_ids** (M-F-99: `d7ce89b`'yi origin/main'den MERGE'le aldım — rebase DEĞİL, `3f6d99b` DEFTER'de atıf gördüğü için tarihi bozmadım, repo'nun pre-push guard'ı zaten zorluyordu; tek-triplet'te `required_ids` doğrudan geçiriliyor, `{side}` ikili-triplet'te bilerek GEÇİLMİYOR çünkü hold_isolator'ın AND-mantığı benim OR-of-AND ihtiyacımla çakışır — `_driver_value` zaten aynı korumayı triplet-başına sağlıyor; yeni senaryo yalnız PENCERE bölgesinde dirseği görünmez bırakıp çekirdek tutuşu dokunmadan bırakarak mekanizmayı gerçekten izole etti, min_coverage=0 kontrolüyle doğrulandı: 0,756 kapsama). `tests/test_rig.py`'ye [11] olarak bağlandı, `hold_isolator`'la birlikte 11/11 yeşil. `harvest.py`'nin perMovement doğrulayıcısına `presence` anahtarı eklendi (identity'nin kardeşi — M-F-60). Lissom tarafında: `overhead_reach`'e `presence` speklendi (eşik 140° movementPresence'tan devralındı, L-092), `triage_landmarks.py` identity gibi TÜRETİYOR artık (elle yazılmadı), profil yeniden üretildi, tüm kontroller (config_check/phase_check/triage_landmarks) yeşil | **açık (koordinatör inceleme→merge bekliyor)** | motion-core `feat/presence-isolator` (`77caef9`, tarihi `3f6d99b`'yi koruyor) · lissom `60ffbd9`/`fe3ce4a`/`ba64a49` |
| L-153 | sınır | P1 | **Gerçek fixture'larda uçtan uca sınandı — 3/6 makul, 3/6 ŞÜPHELİ.** 6 overhead_reach kaynağı gerçek profille koşuldu: `X2u_vGL0qJU` (1,4-2,6sn), `gsz3BLAkkQ4` (2,4sn) makul (talimatın "2sn tut"una yakın); `6u_rV3C80wU` 5,7-9,4sn (eşiğe yakın tepe 147-148°, kuşkulu ama sınırda). **`Igzmhbghcd4` (30,3sn) · `SfxyICleU4I` (12,2-18,6sn) · `T8KTiE9bTZI` (7,3-30,5sn) fizyolojik olarak imkânsız uzunlukta "tutuş" veriyor** — 2D proksinin bu üç kadrajda gerçek shoulder_flexion'dan saptığına işaret (belki gövde dönüşü, belki farklı bir poz). Uydurma eşik koymadım (max-tutuş sınırı İCAT olurdu — G-043); `presence` spec'inin `basis` alanına PROVISIONAL + bu üç kaynak adıyla not düşüldü. **Kestim/koşturmadım** — kesme+CLI adımı koordinatör incelemesinden SONRA (talimat böyleydi); bu üçü kesilirse önce insan gözden geçirmesi ya da video izleme önerilir | **açık (koordinatöre bırakıldı — kesmeden önce karar)** | presence_isolator CLI çıktısı, 6/6 kaynak |
| L-155 | ölçüm | P1 | **M-F-99 kuyruk-sorusu (J-056) yanıtlandı: `mocore/measures.py` `evaluate()` düşük-görünürlüklü landmark'ı NaN'LAMAZ — gerçek (çöp olabilecek) sayı DÖNER, yalnız `valid=False` bayrağıyla.** Kod okuması (measures.py ~185-230): `pts` HER ZAMAN `frame.xyz`'den hesaplanır (görünürlükten bağımsız); `value` bu noktalardan HER ZAMAN üretilir; ancak SONRASINDA `conf < min_confidence` ise `Measurement(..., value, conf, **False**, INVALID_LOW_CONFIDENCE, ...)` döner — `value` alanı GARBAGE sayıyı hâlâ taşır, silinmez/NaN'lanmaz. Dart'ın 0.8.3-öncesi hâliyle AYNI mimari (J-054/J-056'nın kendisi) — mocore Python tarafı bu sınıfı KENDİ İÇİNDE düzeltmedi, her tüketicinin `.valid`'i kontrol etmesine güveniyor. **Denetim (erişebildiğim 2 tüketici):** `fixture_check.py` (GERÇEK hasat verisiyle çalışan tek tüketici) `.valid` DOĞRU kontrol ediyor (satır ~109, benim L-154 düzeltmemle de aynı yerde) — hipKneeCoupling GÜVENDE. `gate_g1a.py`'nin 2 `.value`-doğrudan-alma noktası (A11 taban kontrolü, A9 ölü-metrik avı) `.valid` kontrol ETMİYOR ama HER İKİSİ DE sentetik/kontrollü pozlarla çalışıyor (A6 ayrı olarak `.valid`'i BİZZAT test ediyor — occlusion senaryosu, doğru davranıyor) — gerçek-veri sızıntısı YOK, ölçtüm. **Sonuç: bugünkü tüketiciler güvenli ama mimari kırılgan** — NaN-döndürme yerine bayrak-döndürme deseni, "kontrolü unutan yeni tüketici" sınıfına açık kapı bırakıyor (Gravita/Choreia kendi hipKneeCoupling implementasyonlarını yazarken düşebilir). Mimari değişiklik (NaN'a geçiş, ya da güven-kapısını `evaluate()`'in içine gömme — Dart'ın 0.8.3 çözümü) TASARIM kararı, kendim yapmadım | **açık (mimari karar koordinatörde — mocore Python tarafı)** | measures.py okuması + fixture_check.py/gate_g1a.py denetimi |
| L-151 | hata (BENDE değil — araç uygunluğu) | **P0** | **İş paketi madde 2 (pencere-kesme) DURDURULDU: `movement_isolator.py` kendi belgesinin uyardığı tuzağa tam düştü, ölçtüm.** Koordinatör "malzemen periyodik" dedi; ölçüm ZITINI gösteriyor. Aracın KENDİ docstring'i zaten uyarıyordu: *"wrong question for single-direction ROM sweeps... 3-rep assessment clips: Lissom measured that... periodicity scores are low-lag autocorrelation artifacts"* + *"For phase-defined tests the movement window is the phase state machine's own output, not a pre-filter."* Lissom'un rom_sweep testleri TAM OLARAK faz-tanımlı. **deep_squat'ta araç tutarlı: 3/3 fixture'da 0 pencere** (Dart `CyclePeriodEstimator`'la aynı hüküm — çapraz-doğrulama). **overhead_reach'te TUTARSIZ: 5/5 fixture'da pencere BULDU** (periyot 0,46-1,83sn, periyodiklik 0,51-0,98) — ama Dart aynı ham veride 5/5 `measured=false` diyordu. Çelişkiyi çözmek için gerçek `shoulder_flexion_right` değerlerini iki adayın PENCERESİ İÇİNDE örnekledim: `T8KTiE9bTZI` (per=0,98, "en güvenli" aday) 0,5sn aralıklarla **116,9→10,5→6,8→36,2→114,0→17,1...** — fizyolojik olarak imkânsız bir sıçrama deseni (talimat "yavaşça kaldır, 2sn tut" ile hiçbir ilgisi yok); `Igzmhbghcd4` 76-130° arası dar ama yine ~0,5sn'de salınıyor — muhtemelen konuşurken el sallama, gerçek reach değil. Araç gövde-genelinde HERHANGİ periyodik hareketi (jest, kaymayan tespit gürültüsü) yakalıyor, hedef eklemin GERÇEKTEN döngülü olup olmadığını değil — tam da kendi "trap" bölümünün tarif ettiği sınıf, farklı bir kılıkta. **Kestim/koştum: HAYIR** — bu pencerelerle fixture kesip CLI'a vermek "notApplied" dürüstlüğünden DAHA KÖTÜ bir sonuç üretirdi (jestin/gürültünün ölçümü, hedef hareketin değil). Alternatif öneri (uygulamadım, tasarım kararı): araç kendi metninde zaten söylüyor — faz-tanımlı testte pencere phase-machine'in çıktısı olmalı; Lissom'da bunun en yakın karşılığı `fixture_check.py`'nin zaten hesapladığı `win` (movementPresence eşiğini aşan kareler) — bunu resmi bir "kes ve provenance'a `windowRule` yaz" aracına çevirmek yeni bir araç tasarımı, tek başıma kararlaştırmadım | **açık (koordinatör kararı bekliyor — hangi pencereleme yöntemi)** | movement_isolator çıktısı (5 pencere) + T8KTiE9bTZI/Igzmhbghcd4 örnekleme + deep_squat 3/3 boş (çapraz-doğrulama) |
| L-156 | çözüm | **P0** | **L-155/M-F-114 uygulandı: `evaluate()` artık `mask_invalid=True` varsayılan — motion-core `feat/measures-mask-invalid` pushlu (`2108f28`).** 3 geçersiz-dönüş noktası (DEGENERATE/LOW_CONFIDENCE/OUT_OF_RANGE) artık `value`'yu NaN'a maskeliyor; `valid`/`reason`/`confidence` aynen kalıyor; `mask_invalid=False` ham değer isteyen teşhis kodu için kaçış kapısı. **Göç güvenliği ÖLÇÜLDÜ, VARSAYILMADI:** `fixture_check.py` (gerçek hasat verisiyle çalışan TEK tüketici) 4 kontrolde (deep_squat×2, overhead_reach, ankle_dorsiflexion) BİT-ÖZDEŞ — zaten `.valid` ile dışlıyordu, maskelenen değeri hiç okumuyordu. `gate_g1a.py` BİT-ÖZDEŞ DEĞİL ve fark GERÇEK: **A9 (ölü-metrik avı) `tibia_inclination_right/left`'i ölü işaretledi, hüküm GEÇTİ'den SINIRDA (9/10)'a düştü.** Kök neden teşhis edildi: SWEEPS'in 7 probu ayak bileğine hiç dokunmuyor (ayak-bileği süren parametre YOK) ve dürüstçe sabit 0,0000° veriyor; kalan 2'si (hip_flex=110, knee_flex=120) eskiden ham sızıntıyla SÜPÜRME DEĞERİNE neredeyse birebir eşit (110,0°/120,0°) fizyolojik-imkânsız değerler veriyordu — `INVALID_OUT_OF_PHYSICAL_RANGE` artık bunları doğru maskeliyor. **A9 iki çöp okumayı "perturbasyona tepki veriyor" sayarak YANLIŞ GEÇİYORDU.** Bu, doktrinin bu vardiyada üçüncü kendini-kanıtlaması (referenceEligible gecesi + gate_g1a'nın 2 denetimsiz çağrısı + şimdi bu) — REGRESYON DEĞİL, düzeltmedim, SWEEPS/A9 tasarımı kime aitse ona bırakıyorum. **Denetimde 3. tüketici bulundu (önceden bayrak yoktu):** `mocore/phases.py`'nin `PhaseRunner._metric_value()` `res.valid` DEĞİL `np.isfinite(res.value)` kontrol ediyordu — eski mimaride düşük-güven/aralık-dışı okumaları BEDAVA kabul ediyordu (çöp sonlu sayı `isfinite`'ı geçer); `mask_invalid=True` bu tüketiciyi DOKUNMADAN düzeltiyor (NaN sonlu değil). A7/A8 sayıları bu koşumda değişmedi (guard senaryoları geçersiz-güven geçişine denk gelmedi) ama kırılganlık ORADA DA vardı | **açık (mimari düzeltme kapalı; A9/SWEEPS kapsam boşluğu + phases.py bulgusu koordinatöre/sahibine bırakıldı)** | motion-core `feat/measures-mask-invalid` (`2108f28`) — 4 fixture_check kontrolü + gate_g1a öncesi/sonrası JSON (`/tmp/gate_before.json`/`/tmp/gate_after.json`) |
| L-157 | ölçüm | **P0** | **İLK LİSSOM REFERANSI denemesi: presence-pencereli kesim İKİ testte de sonuç vermedi — RET, ve daha bilgilendirici bir RET.** `overhead_reach` (6 kaynak, presence_isolator@77caef9 ile kesildi): sapmalar **72,3/108,2/70,1/52,7/72,9°** — pencereleme ÖNCESİNDEN (42-60°) DAHA KÖTÜ. `deep_squat` (3 identity-geçen kaynak, aynı yöntemle): 23,4/33,8/38,6° — karışık (biri iyileşti, biri kötüleşti), toplamda benzer büyüklükte, hâlâ RET. **Teşhis:** kesilen pencereler 129-1294 kare arasında (10× fark) — L-153'ün "şüpheli" 3 kaynağı (uzun, 8-30sn "tutuş") ile "makul" kaynaklar (2-9sn) arasındaki BÜYÜK süre farkı, DTW'yi çok farklı-uzunluktaki içerikleri hizalamaya zorluyor; bu da L-153'ün 2D-proksi sapması bulgusunu DOĞRULUYOR, çürütmüyor. **Sonuç: pencereleme kök nedeni ÇÖZMEDİ — anlaşmazlık artık M-F-71/L-151'in "3. adım"ına (karar-sınıfı sayı) taşınmış durumda:** kaynak-başına hareket-kimliği incelemesi (kanal-arası TANIM farkı mı, stil varyansı mı) yapılmadı — bu oturumda kapsam dışı bırakıldı (lissom_engine + UI-BRIEF önceliklendirildi), açık bırakılıyor. deep_squat'a `presence` speklendi (RIGHT_HIP→RIGHT_KNEE→RIGHT_ANKLE, 110°, movementPresence'tan devralındı) | **açık (3. adım: kaynak-uygunluk raporu — koordinatöre/sıradaki oturuma bırakıldı)** | worktree koşumu (0.8.4) — `cut_presence.py` scratchpad'de, kalıcı Lissom aracı DEĞİL |
| L-158 | çözüm | **P0** | **`lissom_engine` KURULDU — Lissom'un en büyük açığı kapandı (gece paketi #4).** `packages/lissom_engine`, `motion_core-v0.8.4`'e TAG'le pinli (path DEĞİL: paylaşımlı ağaçta path, başka bir oturum dal değiştirince sessizce değişir — M-F-22). **M-F-71 hükmü mimarinin KENDİSİ, sonradan takılmış bir kontrol listesi değil:** girişim kapısı `movementPresence`'tan gelir (fixture_check.py'nin doğruladığı AYNI kaynak) ve KESİNTİSİZ `requiredHoldS` tutuş ister — kümülatif kare sayımı gürültüyü/kısa jesti geçirirdi (L-151 sınıfı, motor tarafında) · girişim açıldıysa tepe HER karede güncellenir ve timeout değeri KORUR yalnız kodu değiştirir (L-146'nın sessizce düşen yolu) · en düşük bandın altı `measuredBelowRange` ve **bant etiketi ALMAZ** (bandın altındaki değere bant adı vermek ölçmediğimiz sınıflandırmayı iddia etmek olurdu), `lowestBandFloor` koçlanan anlatı için taşınır · `finish()` HİÇBİR yolda null dönmez → sessiz düşüş yapısal olarak imkânsız · `speaksAsCoaching` madde 5'i kodluyor. **23/23 test, analyze temiz.** İki süit KASITLI olarak iki farklı soruyu cevaplıyor: `mf71_test.dart` "motor doğru davranıyor mu" (sentetik spec) · `real_config_test.dart` "GERÇEK config'imizi okuyabiliyor mu". İkincisi yerini derhal hak etti (aşağı) | **açık (metricReader kapanışı gerçek JointAngleExtractor'a bağlanacak — sonraki artırım)** | `fcf239c` |
| L-159 | hata (BENDE) | P1 | **Gerçek-config süiti ilk koşumda kendi okuyucumdaki boşluğu yakaladı: ÜÇÜNCÜ bir skorlama tipi varmış.** Batarya `banded` (6) + `qualitative` (5) + **`ordinal` (1)** taşıyor; `deep_squat` ordinal (sürekli derece normu literatürde YOK — PubMed 35321135 yalnız gruplar-arası fark veriyor, o yüzden betimsel kriterli seviye dürüst seçenek). Okuyucum yalnız ilk ikisini biliyordu: **tüm sentetik testler yeşilken gerçek dosyada patlıyordu** — "beyan ≠ canlı" sınıfının kendi kodumdaki hâli (L-146/M-F-90 ile aynı aile). Düzeltildi: `ordinal` kendi şekliyle ayrıştırılıyor (`level`+`label`+`criteria` ZORUNLU — kriteri olmayan seviye kullanıcıya neden o seviyede olduğunu söyleyemez), `qualitative`'in düz-string listesinden AYRI (birini diğeri sanmak sessizce boş liste üretirdi). **Ders: sentetik-yeşil bir okuyucu, okuduğu iddia edilen dosyayı hiç okumamış olabilir** — her config okuyucusu gerçek dosyayı okuyan en az bir teste sahip olmalı | **kapalı** | `fcf239c` — `real_config_test.dart` |
| L-160 | görev | P1 | **UI-BRIEF yazıldı** (`docs/design/UI-BRIEF.md`, gece paketi ortak kalemi) — `claude.ai/design` oturumlarına girdi. Uydurma ekran YOK: envanter `config/ia/library.v1.json` (4 sekme · 6 aile · honestyBox · navigasyon kuralları · 3 poz-katmanı · whyNotPage), `config/copy/disclaimers.en.json` (5 zorunlu yüzey), PRD §5 (akış + 3-deneme kuralı) ve `lissom_engine`'in sonuç katmanlarından TÜRETİLDİ. Merkezi bölüm §2.4: sonuç ekranının DÖRT katmanı motorun `ResultTier`'ıyla birebir; `measuredBelowRange`'in bant etiketi almaması ve `measurementTimedOut`'un değeri KORUMASI tasarıma taşındı — bu ayrımlar görselleşmezse L-135 geri gelir. İsimle taşınan sınırlar: karşılaştırma iddiası MDC'ye dek kapalı · izin-reddinde uygulama çalışmaya devam eder (yalnız ölçüm kapanır) · tier-3 ters duruşlar skorlanmaz (M-019) · **kamera native köprüsü YOK, canlı-tur ekranı gerçek kamerayla test EDİLMEDİ**. 4 tasarım sorusu kurucu/koordinatöre bırakıldı, kendim karara bağlamadım. `wellness_lint` temiz | **kapalı** | `d5101b7` |
| L-161 | çözüm | **P0** | **A9/SWEEPS kapsama açığı DÜZELTİLDİ (M-F-126 görevi) — motion-core `fix/a9-valid-only-probes` pushlu.** Teşhis ÖLÇÜLDÜ: SWEEPS her poz alanını TEK BAŞINA gezdiriyor; zincirden TÜREYEN metrikler böyle uyarılamaz — `synth.Pose`'un kendi belgesi söylüyor ("tibia eğimi ayrı parametre DEĞİLDİR, (hip_flex − knee_flex) ilişkisinden türer"). Tek-eksenli prob (`hip_flex=110` yalnız başına) ANATOMİK OLARAK İMKÂNSIZ duruş kurar; `tibia_inclination` orada 110° okur, beyan edilen 0-90° aralığının dışına düşer, doğru şekilde geçersiz sayılır. Eski mimaride bu geçersiz okuma HAM değeriyle (110.0) dönüyordu ve SONLU olduğu için A9 onu "perturbasyona tepki" sayıp metriğe SAHTE YEŞİL veriyordu. **Ölçüm (eşgüdümlü duruşlar):** hip+knee BİRLİKTE büküldüğünde `tibia_inclination_right` = 0→5→10→15° (hepsi GEÇERLİ) — tepki gerçek, prob kümesi eksikti. Düzeltme: `CHAIN_PROBES` (3 çömelme derinliği + topuk-kalkık, hepsi beyan edilen fiziksel aralık içinde). **Sonuç: A9 dürüst yoldan GEÇTİ'ye döndü — 0/19 ölü, hüküm GEÇTİ (A1-A9 tam), tibia 11/13 probda geçerli tepki.** Ek: metrik-başına geçerli-yanıtlayan sayımı JSON rapora + **İNCE KAPSAMA uyarısı** (yalnız 2 geçerli probla yaşayan metrik ölü değil ama aralığı iki noktadan biliniyor — "A9 yeşil"in tek başına okunması sahte-yeşilin yumuşak hâliydi). **Dördüncü canlılık sorusu (M-F-58) üç yoldan sınandı:** gerçekten sabit metrik hâlâ ölü okunuyor · 2-geçerli-okuma metrik ince-uyarıyı tetikliyor · tibia chain-probe OLMADAN hâlâ ölü okunuyor (yani düzeltmenin sebebi chain problar, kaza değil). **AİLE DERSİ: tek-eksenli perturbasyon zincirden türeyen metriklere YAPISAL OLARAK KÖRDÜR — "hiçbir bozucuya tepki vermiyor" derken ilk soru "bozucular bu metriği uyarabiliyor mu?" olmalı** | **kapalı (merge koordinatörde)** | `fix/a9-valid-only-probes` · `/tmp/gate_a9fix.json` |
| L-162 | ölçüm | **P0** | **ADIM-3 CEVABI: kaynaklar AYNI ŞEYİ göstermiyor — ve ölçüm bunu İKİ BAĞIMSIZ eksende söylüyor.** `tools/identity_review.py` (yeni, kalıcı araç) kaynak-başına profil çıkardı. **Eksen 1 — DURUŞ (`trunk_lean` medyanı):** `overhead_reach`'te iki kaynak yatay gövdede — Fraser Wilson **79,2°**, Strength Side **75,8°** (diğerleri 1,8-11,5°). Talimat "STAND side-on... raise the arm overhead" diyor; 76-79° gövde eğimi ayakta bir baş-üstü uzanma DEĞİL (yerde/eğilmiş omuz mobilite çalışması olabilir). **Eksen 2 — KAMERA GÖRÜŞÜ (`shoulder_line_foreshortening` medyanı, sentetik tabanla kalibre edildi: 0,80=kameraya dönük/yaw 0° · 0,00=yandan/yaw 90°):** sagittal test SIDE-ON ister (≲0,2) ama ölçülen 0,5-0,6 = **~41-51° yaw**, yani kaynaklar çoğunlukla kameraya DÖNÜK çekilmiş. **İki kriter birlikte uygulandığında `overhead_reach`'te 6 kaynağın 1'i, `deep_squat`'ta 4 kaynağın 1'i geçiyor — minSources=3 yapısal olarak sağlanamıyor.** Ayırt edici sınama: yatay-gövde iki kaynağı DIŞLAYIP koştum → sapmalar 43-80° (hâlâ RET), yani duruş gerçek bir bulgu ama TEK sebep değil; kamera görüşü bağımsız ikinci sebep. **⚠️ İRONİ, kayda geçsin:** `deep_squat`'ta iki kriteri de geçen TEK kaynak `Advanced Physical Therapy` — benim KENDİ kimlik kapımın `different-movement` diye reddettiği kaynak (hipKneeCoupling −0,46, L-144). Yani üç kriter (kamera · duruş · hareket-kimliği) BAĞIMSIZ ve hiçbir kaynak üçünü birlikte geçmiyor. **Hüküm: bu havuzlarla referans kurulamaz — eşik gevşetilerek değil, hedefli hasatla çözülür** (arama terimleri "side view / side-on / sagittal" + ayakta-gösterim). **Sınır beyanı:** yaw kestirimim nötr-ayakta sentetik tabana dayanıyor; baş-üstü uzanma omuz hattı geometrisini bir miktar değiştirir, dolayısıyla yaw sayıları YAKLAŞIK — ama 0,1 ↔ 0,6 ayrışması bu belirsizliğin çok üstünde | **açık (hedefli hasat kararı koordinatörde)** | `tools/identity_review.py` çıktıları — 10 kaynak × 5-6 metrik |
| L-163 | talep | P1 | **UI-BRIEF'in 4 TASARIM SORUSU — koordinatör hükmüne (kurucu design-oturumları öncesi, M-F-126 madde 4).** Hepsi `docs/design/UI-BRIEF.md` §5'te; burada karar-odaklı özetleniyor. **(1) `measuredBelowRange` görselleştirmesi:** hedef tabanı (`lowestBandFloor`, motor taşıyor) bir ilerleme çubuğu olarak göstermek MOTİVE edici mi, yoksa "yetersizsin" hissi mi yaratır? Bu sorunun ağırlığı L-135'ten geliyor: bu katman TAM OLARAK donmuş-omuzlu kullanıcı için var; yanlış görselleştirme onu kaybettirir. Seçenekler: (a) hedefe-uzaklık çubuğu · (b) yalnız çıplak değer + "başlangıç noktan bu" · (c) kişisel trend (ama MDC'ye dek karşılaştırma iddiası KAPALI, yani ilk ölçümde gösterecek bir şey yok). **(2) `retest_countdown` ana ekranda ne kadar öne çıkmalı?** Yeniden-ölçüm döngüsü ürünün Kuzey Yıldızı (IA config'te `home` bölümü) ama geri sayım baskı da yaratır — wellness tonuyla çelişme riski. **(3) 12 test tek oturumda mı, bölünebilir mi?** Yorgunluk sırası etkiliyor: `plank_hold` dayanıklılık testi ve `active_straight_leg_raise` (supine, tek kameranın en zayıf konumu) sonda mı başta mı? Bölünürse ölçümler farklı `calibrationProfile`'a düşebilir ve karşılaştırma kuralı (PRD §267) kırılır. **(4) `coming_soon` ailelerin görünürlüğü:** IA config kapsamın TAMAMININ baştan görünmesini istiyor (dar-app algısı önlensin) ama 6 aileden 5'i `coming_soon` iken "boş uygulama" hissi riski var. Karar: hepsi listelenir mi, yalnız sıradaki dalga mı, yoksa bir "yol haritası" sayfasına mı toplanır? **Hiçbirini kendim karara bağlamadım** — dördü de ürün/ton kararı, M-F-77 gereği koordinatöre | **açık (koordinatör hükmü bekliyor)** | `docs/design/UI-BRIEF.md` §5 |
| L-164 | hata (BENDE ×2) | **P0** | **Gerçek-fixture replay'i (M-F-126 madde 3) İKİ gerçek hata yakaladı — ikisi de sentetik süite GÖRÜNMEZDİ.** Motor çekirdeğin KENDİ hattına bağlandı (`PoseNormalizer`→`JointAngleExtractor`, paralel implementasyon YOK) — `lib/src/metric_bridge.dart` + `test/real_replay_test.dart`. **(1) KONVANSİYON TERSTİ, ve yanlış olan benim kendi yorumumdu.** Köprüyü `invert: true` ile yazdım, gerekçesi kulağa makul geliyordu ("çekirdek iç-açı okur, Lissom ROM dili konuşur"). ÖLÇÜM: `right_shoulder` JointSpec'i `a=ELBOW, b=SHOULDER, c=HIP` — kol yanda aşağıyken İKİ ışın da aşağı bakar ⇒ **0°**, baş üstünde zıtlaşır ⇒ **180°**. Çekirdek ZATEN ROM konvansiyonunda; benim çevrimim her okumayı ters çeviriyordu (aşağı=180°, yukarı=0°) ve **makul GÖRÜNEN bir sayı olduğu için testsiz sonsuza dek fark edilmezdi**. `invert:false`, işaret artık testle çivili. **(2) KUYRUK İZLEME-KAYBI TAMAMLANMIŞ ÖLÇÜMÜ ÇÖPE ATIYORDU — M-F-71 madde 2'nin kendi motorumda ihlali.** Kalite kontrolleri ölçüm raporundan ÖNCE koşuyordu; gerçek videoda kişi tekrarını yapıp kadrajdan çıkınca (kuyruk kareleri hüküm-dışı) sonuç `notMeasured/trackingLost` oluyordu — 5899 okunabilir kare, algılanmış girişim ve birikmiş tepe değere RAĞMEN. Doğru semantik: izleme kaybı ölçümü ENGELLEDİYSE sebeptir; ölçüm zaten tamamlandıysa sonrasında olmuş bir olaydır. Sıra düzeltildi: ölçüm önce raporlanır, kalite kodları yalnız ölçüm YOKKEN konuşur. **KANIT (gerçek fixture `X2u_vGL0qJU` — L-162'de kamera+duruş kriterlerini geçen TEK kaynak):** 10730 kare / 5899 okundu → `scored` · `measurementTimedOut` · **180,0°** · `band=good`. Timeout kodu doğru ve dürüst (klip ölçüm penceresinden çok daha uzun baş-üstü tutuyor) ve **değeri KORUYOR** — motorun vaat ettiği L-146 davranışı. Ek: eşlenmemiş metrik sessiz null yerine ADIYLA fırlatıyor; replay süiti fixture kütüphanesi yoksa İSİMLE SKIP veriyor (sessizce yeşil yanan replay, hiç koşmamış replay'den ayırt edilemez). **28/28 test · analyze temiz · 7 Python kapısı yeşil** | **kapalı** | `1152c70` |
| L-165 | talep | P1 | **M-F-133 madde 3 hükmü ile VERİ ayrıştı — hüküm revizesi koordinatörde.** Hüküm "ayakta-bloğu / yer-bloğu" örneğini veriyor; batarya talimatları ölçüldüğünde ayakta testler İKİ kamera konumuna bölünüyor: **6'sı "stand SIDE-ON", 3'ü "stand FACING"**. Yan-duruş ve önden çekim aynı `calibrationProfile` DEĞİLDİR, dolayısıyla ikisini tek blokta toplamak hükmün BAĞLAYICI kuralını (blok = tek kalibrasyon) ihlal ederdi. Bloklar (kamera görüşü × vücut konumu) ile tanımlandı: `standing_sagittal`(6) → `standing_frontal`(3) → `seated_frontal`(1) → `floor_sagittal`(2). Hükmün bağlayıcı kuralı korundu, örneği bu veride yetersiz kaldı. Yorgunluk sırası aynen uygulandı (plank kendi bloğunun sonunda, ASLR yer-bloğunda) | **açık (hüküm revizesi koordinatörde)** | `config/tests/assessment-blocks.v1.json` `_notes` · `e6a366e` |
| L-166 | hata (BENDE) | **P0** | **Hasat ön-elemesinin İLK TASARIMI ölçümle ÇÜRÜTÜLDÜ — ve kullanılabilir TEK kaynağı eliyordu.** İlk sürüm "kamera görüşü" eksenini METİNDEN skorluyordu. L-162'nin hüküm verdiği 6 gerçek kaynakta sınandı: **6 kaynağın 0'ı** metninde kamera görüşünden söz ediyor (`side view`/`front view`/`sagittal` — 438-4916 karakterlik açıklamalarda HİÇBİRİ). Dahası filtre iki ölçütü de geçen TEK kaynağı (`X2u_vGL0qJU`) **"ELE"** işaretledi, duruş-kusurlu ikisini "denemeye değer" saydı. Yeniden tasarlandı: **görüş metinden SKORLANMAZ** (sıfır-sinyalli eksene skor vermek, ölçmediğim seçiciliği iddia etmek olurdu) · arama TERİMLERİ değerli ama mekanizması FİLTRELEME DEĞİL, hangi adayların GELDİĞİNİ değiştirmek · yalnız NEGATİF işaretler metinde gerçek sinyal taşıyor → betik artık **YALNIZ ELEYİCİ**, seçici değil. İki yönlü doğrulandı: gerçek korpusta kullanılabilir kaynağı 1/1 KORUYOR (ve hiçbirini elemiyor — orada dürüst bir no-op) · sentetik vakalarda yer/pasif/derleme malzemesini doğru eliyor (M-F-58: kapı kırmızı yanabiliyor). `multiPerson` KASITLI bayrak, eleyici değil — grup videosunda kesilebilir tek-kişi segmenti olabilir | **kapalı** | `8de0f1f` — 6 gerçek kaynak + 5 sentetik vaka |
| L-167 | denetim | P1 | **M-F-138 (bayat-uygunluk) süpürmesi — İZOLATÖRLERİM TEMİZ, KESİCİ ETKİLENMİŞ.** Üç izolatör (`movement`/`hold`/`presence`) `referenceEligible`·`romMode`·`provenance` alanlarının HİÇBİRİNİ okumuyor — saf geometri, kare girer pencere çıkar; bayat snapshot TAŞIYAMAZLAR. Bayatlık bir adım aşağıda: **KESİCİ** kaynağın provenance'ını olduğu gibi kopyalıyor, dolayısıyla kesilmiş pencereler snapshot'lanmış `referenceEligible: true` taşıyor (kendi çıktımda doğrulandı: 3/3 kesim). Ortak yardımcı (JabLab yazıyor) gelene dek yapılan: kesici artık `derivedFrom` yazıyor — kaynak fixture + video id + uygunluk snapshot'ı + açık bayatlık uyarısı. **Snapshot SİLİNMEDİ** (aşağı-akış onu bekliyor), **SORULABİLİR yapıldı** — sorulamayan bir snapshot bayat olduğunu asla söylemez. Yardımcı indiğinde hizalanacak | **kapalı (tespit) / açık (ortak yardımcıya hizalama)** | `8de0f1f` · `tools/cut_presence_window.py` |
| L-168 | ölçüm | **P0** | **İLK LİSSOM REFERANSI: DÜRÜST NEGATİF — rapor mühürlendi** (`docs/ILK-REFERANS-DURUST-NEGATIF.md`). Beş tur ölçümle denendi ve beşi de RET: tam-video 42-60° → 0.8.0 segmentasyon (yapısal olarak devreye giremedi, `overhead_reach` aperiyodik) → 0.8.1 koridor (≤1,7° kayma) → **presence-pencereli kesim DAHA KÖTÜ (72,3/108,2/70,1/52,7/72,9°)** → yatay-gövde 2 kaynak dışlanınca kalan 3'te 43-80°. `deep_squat` paralel: 34-43° → 23,4/33,8/38,6°, hâlâ RET. **Kök neden ÜÇ BAĞIMSIZ eksende ölçüldü:** duruş (`trunk_lean` 76-79° vs 1,8-11,5°) · kamera görüşü (`foreshortening` 0,5-0,6 ≈ 41-51° yaw, sagittal test SIDE-ON ister) · hareket kimliği (`hipKneeCoupling` −0,46). **Üçünü birlikte geçen kaynak: `overhead_reach` 1/6 · `deep_squat` 1/4** — minSources=3 yapısal olarak sağlanamıyor. Beş alternatif açıklama sırayla ELENDİ (raporun §4'ü). Hükmü değiştirecek şey isimli: hedefli hasat (sıram ÜÇÜNCÜ), hedef ≥3 üç-ölçütlü kaynak, ~9-18 aday taraması (TAHMİN, ölçüm değil). **Havuz kuru çıkarsa meşru sonuç:** bu iki test referanssız yaşar — motor bunu zaten destekliyor (`ResultTier.measuredNoBands`). Raporun §6'sı kendi ölçümümün sınırlarını sayıyor (yaw kestirimi ±10°, presence eşikleri PROVISIONAL, kesim provenance'ı M-F-138 sınıfında) | **REDDEDİLDİ (kapalı) — YOL: tam-video referans çıkarımı (BEŞ yol) · ÖLÇÜM: beş tur, beşi de RET** / açık (hedefli hasat, sıra bekliyor) | `docs/ILK-REFERANS-DURUST-NEGATIF.md` |
| L-169 | **DÜZELTME** | **P0** | **KENDİ ANA ÇIKARIMIM ÇÜRÜTÜLDÜ: bu havuz heterojen değil, AZ-NÜFUSLU.** Koordinatör talimatıyla havuz `c561204` rig'iyle (JabLab ikinci-şahıs emir-kipi sınıfı) yeniden sınıflandırıldı (`tools/reclassify_pool.py`, 68 manifest): **6 kaynak `None`→`active`**, 1'inin fixture'ı var (`GaP20t6ZOfU`/InvictusFitness/overhead_reach), 5'i çıkarım bekliyor. **Yol boyunca M-F-138'in İKİZİ bulundu — BAYAT YOKLUK:** o fixture romMode hattından ÖNCE çıkarılmış, provenance'ında `referenceEligible` alanı HİÇ YOK; manifest tazelendi ama fixture bilmiyordu, kanonik CLI fail-closed `unattested` sayıp kapıda bıraktı — **havuz gerçekte olduğundan KÜÇÜK görünüyordu.** Kesici artık uygunluğu KESİM ANINDA MANİFESTTEN çözüyor (çekirdek `94b4ae9` ilkesi). **7 kaynakla kesin koşum: tek kaynak eklemek 5 sapmanın 4'ünü düşürdü** — Igzmhbghcd4 72,3→57,2 · SfxyICleU4I 108,2→97,7 · T8KTiE9bTZI 70,1→49,7 · X2u_vGL0qJU **52,7→32,8** · gsz3BLAkkQ4 72,9 sabit · yeni GaP20t6ZOfU 39,7. **Ortalama 75,2°→58,3° (−%22), en iyi kaynak 32,8°.** Hüküm hâlâ RET (eşik 14°) ve §2'nin üç-eksen bulgusu ayakta, AMA aile sınırını ("havuz büyütmek anlaşma getirmiyor") Lissom'a PEŞİNEN uygulamam yanlıştı — mekanizma açık: konsensüs medoid+hücre-ortalamasından türetiliyor, az-nüfuslu havuzda her yeni take konsensüsü daha tutarlı merkeze çekiyor. Rapor revize edildi (§1b + §4'te kendi iddiam "çürütülenler"den "desteklenenler"e taşındı + §5 ölçüme dayandırıldı). **Ders: başka ürünlerde ölçülmüş bir aile sınırını kendi verinde ölçmeden devralmak, M-F-31'in ("aile aracı ≠ app'e hazır araç") sınır-devri hâli** | **kapalı (ölçüm) / açık (5 bekleyen kaynak çıkarım istiyor — hasat sıram)** | `94fea0f` · rapor §1b · `tools/reclassify_pool.py` |
| L-170 | **DÜZELTME** | **P0** | **HASAT SIRASI GELDİ, PAKETİN İKİ ÖNCÜLÜ DE ÇÜRÜDÜ — ve ikisi de benim yaratmadığım engeller.** (a) **"5 bekleyen kaynak çıkarım ister" YANLIŞ: beşi de TRİYAJ-REDDİ taşıyor** — `QlUhbo41GTg` netlik 28<40 · `IHApHfNA2Ag` süre 69s<90s · `8V3uad4MSaE` dikey format 480×854 · `ghL3AJfRT6k` netlik 14<40 · `lr3_bA48EBM` netlik 37,8<40 (SINIRDA). `rom_mode` gösterim-modunu sorar, triyaj kadraj/netlik/süre/format sorar; **biri aktifleşince öteki geri alınmaz.** Çıkarmak triyaj kapısını gevşetmek olurdu — YAPMADIM. Üç-eksen bulgusunun bir kat üstü: uygunluk ölçütleri de birbirinin yerine geçmez. (b) **"11-kaynak havuzu" YOK:** `overhead_reach`'in gerçek uygun+fixture'lı havuzu **7** ve yedisi de çoktan çıkarılmıştı — §1b'nin koşumu ZATEN en dolu havuzdu; `deep_squat` 3. (c) **v0.8.8 (pinli tag) doğrulaması: sapmalar 0.8.4 ile BİREBİR AYNI** (57,2/97,7/49,7/32,8/72,9/39,7 · 23,4/33,8/38,6) — `medoidTakeId`/`gateJoints` bu yolda devreye girmiyor. (d) **`evidenceThickness`/`capFillShare`/`medoidTakeId` dağılımı RAPORLANAMADI:** bu alanlar artefaktta yaşıyor, artefakt ancak BAŞARILI kurulumda doğuyor; üç koşum da anlaşma kapısında reddedildi → artefakt YOK. Aile eşik-tabanına Lissom verisi ilk başarılı kurulumda gelir; şimdi vermek uydurma olurdu. (e) **`gateJoints` KULLANILMADI, gerekçeli:** `overhead_reach`'te kollar hareketin KENDİSİ, daraltma yalnız ölçülmüş `coached_only` temeliyle meşru (M-F-143) — elimde o ölçüm yok, daraltma sapmaları düşürürdü ama eşiği gevşetmenin başka adı olurdu | **REDDEDİLDİ (kapalı) — YOL: hasat paketinin İKİ öncülü · ÖLÇÜM: beşi de triyaj-reddi taşıyor** / açık (`lr3_bA48EBM` 37,8 vs 40 sınırda — EŞİK sorusu, koordinatörde) | rapor §1c · `1402a69` |
| L-171 | ölçüm | **P0** | **NETLİK EŞİĞİ (40) ÖLÇÜMLE DAYANAKSIZ ÇIKTI — eşik sorusu ölçüm sorusuna çevrildi (M-F-173 hükmü).** Sınır klip (`lr3_bA48EBM`, netlik 37,8) **KARANTİNADA** çıkarıldı (`scratchpad/quarantine/`, kütüphaneye/kuyruğa/havuza GİRMEDİ — kapı gevşemedi) ve landmark kalitesi kabul edilmişlerle kıyaslandı (`tools/landmark_quality.py`, yeni araç). **Sonuç 1 — AYIRT EDİLEMEZ:** tespit 0,967 · görünürlük ort. 0,862 · p10 0,770 · kadraj-içi 0,990 · jitter/sn 0,0290 — beşinin beşi kabul-aralığında, **dördü medyanın ÜSTÜNDE.** Reddedilen klip kabul edilenlerin çoğundan DAHA İYİ landmark üretiyor. **Sonuç 2 (asıl bulgu) — n=29'da netlik landmark kalitesini ÖNGÖRMÜYOR:** r(netlik,tespit)=**+0,179** · r(netlik,görünürlük)=**+0,008** · r(netlik,jitter)=**+0,213 TERS İŞARET** (net video az jitter beklenir). Kabul havuzunun netlik aralığı 41,9–1268,9 (**30× yayılım**) ve bu yayılım boyunca ilişki YOK; en DÜŞÜK netlikli iki kaynak (41,9 · 53,7) en iyi görünürlük ve en düşük jitter'lardan, en YÜKSEK netlikli (1268,9) havuzun en kötü jitter'ı. **Öneri (karar koordinatörde):** `lr3_bA48EBM` netlik-reddi kaldırılabilir; eşik ya ölçülmüş ilişkiye dayandırılsın ya KAPI olmaktan çıkıp raporlanan alana dönsün. **SINIR BEYAN EDİLDİ — aralık kısıtlaması:** yalnız 41,9 ÜSTÜ ölçülebildi (altındakiler hiç çıkarılmamış), dolayısıyla "netlik hiç önemsiz" DENMİYOR; `ghL3AJfRT6k` (netlik 14) hakkında hüküm YOK — reddi "kanıtsız", "yanlış" değil. Alt-uç ucuz sınanabilir: en düşük 2-3'ü karantinada çıkar, aynı kıyası koş | **REDDEDİLDİ (kapalı) — YOL: netlik eşiği 40'ın DAYANAĞI · ÖLÇÜM: yeniden-türetme dayanaksız buldu** / açık (eşik kararı + alt-uç örneklemi koordinatörde) | `608a739` · `docs/NETLIK-ESIGI-YENIDEN-TURETME.md` |
| L-172 | görev | P1 | **HEDEFLİ ARAMA TURU — ön-eleme HASATTAN ÖNCE koştu (`tools/targeted_search.py`, Choreia probe deseni).** Üç ölçüt: triyaj-uyumluluk (süre ≥90s · dikey format değil) · bağımsız eğitmen (kütüphanedeki kanal ATLANIR, M-F-32) · `harvest_prescreen` eleyicileri. **Verim: `overhead_reach` 45 görülen → 17 kalan / 16 bağımsız kanal · `deep_squat` 32 → 6 / 6 bağımsız kanal.** Düşenlerin dağılımı isimli: süre <90s **44 aday** (en büyük kalem — indirilip sonra reddedilecek olanlar ÖNCE düşürüldü, L-170'in beş vakasının aynı sınıfı) · kütüphanede var 5 · kanal tekrarı 4 · metin eleyici 1. Metadata ucuz, çıkarım pahalı — sıra bu yüzden böyle. ⚠️ Betik "uygun" DEMİYOR: kamera görüşü ve duruş yalnız landmark'tan ölçülür (L-162/L-166) | **kapalı (arama+ön-eleme)** | `/tmp/ts_or.json` · `/tmp/ts_ds.json` |
| L-173 | **KÖK NEDEN** | **P0** | **VARYANT-KİMLİĞİ (M-F-175) HAVUZUMA UYGULANDI VE 42-108° ANLAŞMAZLIĞIN ASIL SEBEBİNİ BULDU — "az-nüfus" açıklamasının ÜSTÜNDE.** (a) Metin taraması BAYRAK olarak eklendi (oto-ret DEĞİL — metin kanıtı zayıf, oto-ret L-166'nın hatasını tekrarlardı). `deep_squat` 3 kaynağı TEMİZ; `overhead_reach`'te tek bayrak **`X2u_vGL0qJU`** — yani L-162'nin iki ölçütünü de geçen TEK kaynak ve §1b'nin en çok düşen sapması (52,7→32,8). Kanıt spesifik: video 5-egzersizlik dizi, #2 *"banded inferior shoulder mobilizations"*, zaman damgalı. (b) **Pencere haritalandı, bayraktan DAHA KÖTÜ çıktı:** kesim 4080-4221@25fps = **2:43-2:49**, bantlı bölümde (3:11) DEĞİL **wall slides** bölümünde (2:24) — o da aranan varyant değil (duvar-destekli skapular egzersiz; test "stand side-on, arms hang, raise as high overhead as you can" diyor). (c) **ASIL BULGU: havuzun 7/7'si varyant-uyumsuz** — 6'sı çok-egzersizli rutin ("10 MIN MOBILITY ROUTINE" · "Follow Along" ×3 · "5 Moves" · "Mobility Tests"), 7'ncisi adıyla **"Wall Slides"**. Hiçbiri TEK bir baş-üstü uzanma testi değil. `presence_isolator` "birincil metrik eşiği aştı ve tuttu" penceresi buluyor — bu soru "hareket var mı", **"hangi egzersiz" DEĞİL.** Yedi kaynak yedi FARKLI egzersizden pencere verdi; anlaşmazlık bunun doğal sonucu. (d) **AİLE KATKISI: varyant-kimliği KAYNAK düzeyinde çözülemez.** M-F-175 kaynak-başına bayrak öneriyor; ölçüm yetmediğini gösterdi — çok-egzersizli kaynakta bayrak "videoda bantlı bir şey var" der ama KESİLEN PENCERENİN hangi egzersiz olduğunu söylemez (benim vakamda bayrak bantlı bölümü, pencere başka bölümü işaret etti). **PENCERE düzeyinde sorulmalı.** (e) **L-169 ile ilişki: çürütme değil, mekanizmasını açıklama** — "+1 kaynak %22 düşürdü" ölçümü ayakta, ama havuz yalnız az-nüfuslu değil **karışık-egzersizli**; yeni take konsensüsü çekiyor çünkü konsensüs zaten tek hareketin değil bir KARIŞIMIN ortalaması. Hedefli hasat doğru yol ama kriter "daha çok kaynak" değil **TEK-EGZERSİZ kaynağı** | **kapalı (kök neden) / açık (pencere-düzeyi varyant kimliği tasarımı koordinatörde)** | rapor §1d · `tools/harvest_prescreen.py` |
| L-174 | ölçüm | **P0** | **HEDEFLİ HASAT TURU KOŞTU — 5 giren, 0 kullanılabilir. ULAŞILAN ÇIKIŞ: (b) İSİMLİ KAPANIŞ.** Zincir her adımda sayılı (izole worktree `f34acd8`, M-F-139/154): arama+ön-eleme **45 görülen → 17 aday** (16 bağımsız kanal; süre<90s **44** adayı ÖNCE düşürdü) → hasat 5 → **5/5 fixture** (triyaj 5/5 GEÇTİ — netlik/kadraj/süre hiç sorun değildi) → romMode **3 uygun** (2 `unknown`, fail-closed) → **üç-eksen ölçümü: 0.** Ayrıntı: `lrhDL2sLd28` duruş 2,8° ✓ ama kamera 0,6 (~41° yaw) ✗ · `xbsjy1Z08pQ` trunk **101,4°** (yatay-ötesi; "Internal Rotation" = farklı hareket) ✗ · `_XP9Y4cnz88` kamera 0,2 (~76°) ✓ ama trunk 52,3° ✗ ("CNA Skills" = bakıcı HASTANIN kolunu hareket ettiriyor). **Üçü de metin ön-elemesinden GEÇMİŞTİ** (varyant bayrağı yok, eleyici yok) — L-166 bir kez daha doğrulandı: metin hükmü VEREMEZ; ikisi başlığından okunabiliyordu ama filtre yakalamadı, landmark ölçümü yakaladı. **Sonuç:** `overhead_reach` 7 kaynak + 7/7 varyant-uyumsuz (L-173) + turdan 0 ekleme → mevcut malzemeyle referans KURULAMAZ; `deep_squat` 3 kaynak (varyant temiz, sayı kapısında, anlaşma 23-39°). **Kapanış önerisi (ürün yüzeyi — koordinatör onayı):** iki test ölçülmüş gerekçeyle referanssız yaşar; motor ZATEN destekliyor (`ResultTier.measuredNoBands` — değer raporlanır, bant iddia edilmez) ve bugün ship edilebilen yüzey ETKİLENMEZ (`lissom_engine` + assessment-blocks + UI-BRIEF akışı referans beklemiyor). **Sonraki turun kriteri DEĞİŞTİ (L-173):** "daha çok kaynak" değil **TEK-EGZERSİZ kaynağı**; arama terimleri "routine/follow along" malzemesini getirmeyecek biçimde yenilenmeli | **kapalı (tur) / açık (kapanış onayı + pencere-düzeyi varyant kimliği koordinatörde)** | rapor §1e |
| L-175 | çözüm | **P0** | **REFERANSSIZ-CANLI UYGULANDI — M-F-185'in DÖRT ŞARTI da kodda/config'te/yüzeyde** (`a9e2e1d`). **(a) Ölçülü gerekçe YÜZEYDE:** batarya 1.9.0, `overhead_reach`'e `referenceStatus` (kod `variant-mismatch`: havuzun 7/7'si farklı egzersiz, hedefli tur 5'in 0'ını geçirdi) ve `deep_squat`'a (kod `count-gate`: 3 kaynak, anlaşma 23,4/33,8/38,6° vs eşik 14°). Her biri İÇ ölçülmüş gerekçe + AYRI kullanıcı-dili metni taşıyor; okuyucu biri eksikse SERT HATA veriyor — gerekçesiz bir `measurementOnly`, sebebini söylemeyen bir eksikliktir (L-135'in config katmanı). **(b) Terfi yolu İSİMLİ:** `unblockedBy: single-exercise harvest round` + kriter + ÖLÇÜLMÜŞ boşluk (Choreia promotionPath deseni) — "bir gün belki" değil, adı olan bekleyen iş. **(c) `lessonClass` YAZIM ANINDA damgalanıyor:** HER sonuç yolu (ölçüldü · girişim yok · timeout · abort · izleme kaybı · düşük güven) testin beyanına göre `measurementOnly` taşıyor. Sonradan TÜRETİLMİYOR — sonradan hesaplanan sınıf, config değişince sessizce anlam değiştirir; kayıt hangi rejimde yazıldığını KENDİ üstünde taşımalı (M-F-138'in oturum-kaydı hâli). **(d) Yüzey BEYAN EDİYOR:** UI-BRIEF §2.4b *"We show you measurements, not marks"* + ekran-başı gereksinim + tek AÇIK YASAK: bu iki test "coming soon"/"beta" olarak GÖSTERİLMEZ — ölçüm ÇALIŞIYOR ve değer GERÇEK, eksik olan yalnız referans kıyası; "coming soon" demek çalışan bir ölçümü yok saymak, yani L-135 zararının yeni kılığı olurdu. **Ölçümün hiçbir yanı engellenmedi:** `overhead_reach` hâlâ ölçüyor ve bant etiketi alıyor, yalnız referansa karşı kıyaslanmadığını KAYDA GEÇİRİYOR. **52/52 test · analyze temiz · 7 Python kapısı yeşil** | **kapalı** | `a9e2e1d` |
| L-176 | çözüm | P1 | **Statü-örgüsü KAPIYA çevrildi + `BatterySummary` (A5 yüzeyi) yazıldı.** (1) **Kapı:** M-F-186 yasağımı aile yüzey-kuralına terfi ettirdi, o hâlde doküman satırı değil KAPI olmalı (L-093: yazılı ama uygulanmayan sınır, olmayan sınır kadar tehlikeli). Karışma YAPISAL olarak mümkündü — aile durumu `config/ia/library.v1.json`'da, test-başına `referenceStatus` bataryada, ikisini bağlayan hiçbir şey yoktu. `tools/status_weave_check.py` üç değişmez zorluyor: `measurementOnly` test `coming_soon` aileden BESLENEMEZ · hiçbir test `comingSoon`/`beta`/`unavailable` alanı taşımaz · besleyen aile CANLI olmalı. Besleyen aile `itemsSource`'tan TÜRETİLİYOR (elle liste bayatlar ve kapı yanlış aileye bakar). Öz-test kapının kırmızı yanabildiğini kanıtlıyor (M-F-58: 3 yakalanmalı ✅, 1 geçmeli ✅). (2) **`BatterySummary`:** A5'in veri modeli. Var olma sebebi — bu çeviri UI'da yapılırsa her ekran kendi "ölçüldü mü/skorlandı mı/neden yok" yorumunu kurar ve İLK AYRIŞAN yorum sessizce yanlış yüzey üretir. Tasarım kararları: **hiçbir metin UYDURMUYOR** (kullanıcıya giden her cümle config'ten, motor yalnız SEÇİYOR) · `valueNotCompared` bant/bantsız ayrımının ÜSTÜNDE (kullanıcıya söylenecek asıl şey "bu değer referansa kıyaslanmadı") · `measurementOnly` satırında `bandLabel`, bandın-altı satırında `lowestBandFloor` KASITLI TAŞINMIYOR — ikincisi UI'ın §5.1'in yasakladığı dolum-çubuğunu yapma fırsatı olmasın diye (**alanı vermemek, yasağı belgelemekten güçlüdür**) · koşulmayan test satır ÜRETMEZ ("hiç koşulmadı" ≠ "ölçülemedi"; ikincisini birincisi gibi göstermek sebep uydurmak olurdu) · `mayShowAsComingSoon` sabit `false` — kolaylık değil BEYAN: "yakında" göstermek isteyen UI kodu buradan izin alamaz. **61/61 test · analyze temiz · 8 Python kapısı yeşil** | **kapalı** | `tools/status_weave_check.py` · `lib/src/battery_summary.dart` |
| L-177 | çözüm | P1 | **A5 yapı-widget'ı + `BatterySummary` tür-ayrımı (ilk Flutter yüzeyi).** Kök `pubspec.yaml` + `lib/app/` + `test/` — Choreia/Gravita emsali (M-F-168 orta-yol). **(1) Yapı, üsluptan ÖNCE:** statü-örgüsü bir üslup tercihi değil, **neyin neyin YANINDA görünebileceğine dair kısıt** — kıyaslanmış ve kıyaslanmamış ölçüm aynı görsel grupta duramaz · bandın-altı değer dolum-çubuğuna dönüşemez (§5.1) · çalışan ölçüm "yakında" olamaz · ölçülemeyen her satır sebebini İSİMLE taşır. Bu kısıtlar görsel geçişten önce TEST EDİLMİŞ kodda olmalı ki tasarım oturumu DEVRALSIN, yeniden keşfetmesin. **(2) TÜR-AYRIMI — bir commit önce kendi yazdığım koda düzeltme:** widget'ı yazarken gördüm ki düz `rows` listesi bir BİRLEŞTİRME DAVETİ (tek döngüde tek grupta basılabilir → `valueNotCompared` kıyaslanmış okunur, M-F-186'nın yasağı). Kendi kuralımı kendime uyguladım (**alanı vermemek > "yapma" yazmak**) ve birleşik listeyi belgelemek yerine KALDIRDIM; beş liste, beş farklı dürüstlük iddiası. `noBands` ↔ `notCompared` ayrı kaldı: biri ASLA bant almayacak, diğeri HENÜZ almadı — birleştirmek geçici boşluğu kalıcı gösterirdi. **(3) KÖKEN AYRIMI (`summary_strings.dart`):** yüzeye iki tür metin gidiyor ve karıştırılırsa "hiçbir metin uydurmuyoruz" sözü sessizce bozulur — *ölçüm durumu hakkındaki İDDİALAR* config'ten (referenceStatus/promotionPath/sonuç kodları), *yüzey MOBİLYASI* (bölüm başlığı, birim biçimi, hüküm-yok tiresi) kodda. Sınır sınavı: **bir cümle belirli bir testin ölçüm durumu değişince yanlışlanabiliyorsa, config'e aittir.** Boş bölüm BASILMIYOR — Choreia'dan bilinçli sapma: orada boş Evaluated ÜRÜN eksikliğidir ve saklamak kullanıcıyı suçlar, burada boş "starting point" kullanıcı hakkında İYİ HABERDİR. **(4) SABOTAJ DOĞRULAMASI — dördüncü canlılık sorusu bir GERÇEK DELİK buldu:** 11 test ilk koşuda yeşildi, o yüzden widget'ı dört yerden kırdım. (a) bandın-altı satıra hedef sayısı → 🔴 (b) başlığa "Coming soon" → 🔴 (c) `notCompared` satırlarını `_scoredRow` ile bantlı bölümde bas → **🟢 GEÇTİ** (d) bölümün satırlarını sessizce düşür → kapsanmıyordu. **(c) kötü bir sabotaj değil, testimin deliğiydi:** metin-tabanlı ayrım testim "gerekçe scored bölümünde görünmesin" diyordu, ama `_scoredRow` ile basılan yabancı satır ad+değer+tire basar ve gerekçesini HİÇ basmaz → test SESSİZ kalır, kullanıcı kıyaslanmamış sayıyı kıyaslanmış okur. Panzehir: bölümün **satır KİMLİKLERİNİ sayan** yapısal kapı — render biçiminden bağımsız olarak yabancı/kayıp satırı görür; (c) ve (d) artık ikisi de 🔴. **Görsel doğrulama YOK** (cihaz/emülatör/kamera yok) — kanıtlanan YAPI'dır, görünüm hakkında iddia edilmiyor. **11 widget + 63 motor testi · analyze temiz · 8 Python kapısı yeşil** | **kapalı** | `lib/app/battery_summary_view.dart` · `lib/app/summary_strings.dart` · `test/battery_summary_view_test.dart` · `lib/src/battery_summary.dart` |
| L-178 | bulgu | P2 | **`reps: 3` SAHİPSİZ bir config alanı — hiçbir okuyucusu yok.** Bataryadaki 12 testin hepsi `reps` beyan ediyor, ama: (a) `TestSpec` onu parse BİLE etmiyor (`grep -c reps battery.dart` → 0), (b) motor `finish()` başına TEK deneme penceresi kapatıyor (tepe o pencerede birikir), (c) `AssessmentSession._results` testId ile anahtarlı, yani ikinci bir tekrar birinciyi EZER. Yani boru hattının gerçekten yaptığı şey **bir deneme**, config'in söylediği **üç tekrar**. Bu, gecenin aradığım desenlerinden birinin ta kendisi: **"yazıldı ama hedef yol hiç geçilmiyor"** — sadece bu kez kodda değil CONFIG'te. Kalıcılık kablolamasında `plannedUnits: 3` yazmak iki yoldan da yalan olurdu (her test sonsuza dek "1/3 tamamlanmamış" ya da yüzey 3 tekrar iddia eder), o yüzden kayıt `plannedUnits: 1` + `unitLabel: 'attempt'` diyor. **Karar KOORDİNATÖRÜN:** ya `reps` config'ten KALKAR (tek deneme kasıtlıysa), ya motor/oturum çok-tekrar destekler (üç tekrar kasıtlıysa) — ikisi de tasarım kararı, tek başıma seçmiyorum | koordinatörde | `config/tests/lissom-assessment.v1.json` · `lib/src/battery.dart` |
| L-179 | çözüm | P1 | **Geçmiş kalıcılığı terfi edilmiş çekirdek `SessionStore`'a bağlandı (`motion_core-v0.9.0` = `13d07ce`, M-F-193) — ilk tüketici.** Pin motor VE app'te birlikte yükseltildi (aynı paketin iki ref'i çözümlenemez; sürüm ayrışması "yazdığım şema ≠ okuduğum şema" sınıfını doğurur). Depo BİÇİMİ çekirdeğin; buradaki iş ÇEVİRİ ve dört kararı var: **(1) kayıt birimi TEST** — `SessionRecord` başına tek `lessonClass` var, Lissom bloğu ise sınıf-karışık; blok başına yazmak `'scored'` seçince `measurementOnly` ölçümü GEÇMİŞTE skorlanmış gösterirdi (M-F-186 ihlali), `'measurementOnly'` seçince gerçekten kıyaslananları eksik anlatırdı. **(2) `unitLabel:'attempt'`, `plannedUnits:1`** — config `reps:3` derken; gerekçe ölçülmüş, bkz. [[L-178]]. **(3) `workedSeconds` deneme PENCERESİNDEN** — çekirdek onu "dinlenme hariç gerçekten çalışılan saniye" diye tanımlıyor ve kapılar onu sayıyor; `ready` fazını eklemek kazanılmayan kapıları geçirirdi. Bunun için `AssessmentResult.attemptMicros` eklendi — **motor bu sayıyı zaten hesaplıyor ve ÇÖPE ATIYORDU**; girişim yoksa null, girişim başladı-hüküm verilemediyse null DEĞİL ("çalışma olmadı" ≠ "çalışma oldu, sıfır sürdü"). **(4) ölçülemeyen deneme `unmeasuredUnits`'e YAZILIR** — çekirdeğin `isComplete`'i girişimleri sayıyor; kaydetmemek yarın yüzeyin "1 deneme" demesine yol açardı, kullanıcı 1 yapmış ve o ölçülememişken: **sessizlik yalan söyler**. 🎓 **`_classOf` SIRASI CANLI bir kusuru kapatıyor:** `overhead_reach` HEM skor bantlı (u40 low:150) HEM `measurementOnly` → 150°'lik uzanma `tier=scored` üretir; katmana göre eşleştirsem geçmişe doğrulanmış referansa hiç kıyaslanmamış bir ölçüm **skorlanmış** olarak geçerdi. Sınıf sözlüğü çekirdeğin en-az-yetki okumasına KASITLI yaslanıyor (yalnız `'scored'` skorlanmış sayılır): bandın altı `'coached'` gider — M-F-71 madde 5 geçmiş katmanında da geçerli. Geçmiş ANAHTARI perSide testte tarafı taşır (`historyKeyFor`, tek adres): sol/sağ ROM gerçekten farklı, tek seriye katmak değerlendirmenin asıl konusu olan **asimetriyi ortalamada eritirdi**. Depo değişmezleri (bozuk-satır toleransı, atomik yazım, v1 okuma, boş-geçmiş yolu) ÇEKİRDEK testlerinde çivili — burada tekrarlamak aynı iddiaya iki yerden bakmak olurdu; testlerim yalnız ÇEVİRİMİ sınıyor. **Sabotaj: 23 test ilk koşuda yeşildi → dört şeyi kırdım — tier'ı measurementOnly'den önce sor (canlı kusur) 🔴 · bandın altını 'scored' say 🔴 · ölçülemeyen çalışmayı kaydetme 🔴 · tarafı anahtardan düşür 🔴.** **23 app + 66 motor testi · analyze temiz · 8 Python kapısı yeşil** | **kapalı** | `lib/app/assessment_history.dart` · `lib/src/assessment_result.dart` · `pubspec.yaml` ×2 |
| L-180 | bulgu | P2 | **B1/B2 (VMR eşikleri) KONTROL KOŞULU ölçülmeden okunamaz** — JabLab taban-oran eki. B1 (≥%90) ve B2 (≥%75) iki FARKLI popülasyondan (triyajı geçen alt-küme vs "sınırda" işaretlenenler) gelen iki oranı bir **koşul etkisi** gibi okuyor. Eksik olan taban: **triyajın REDDETTİĞİ kliplerde VMR nedir?** Reddedilenler de %88 veriyorsa B1'in %90'ı "iyi koşul çalışıyor"u değil **poz modelinin taban oranını** ölçüyor — eşik hiçbir şeyi AYIRT ETMİYOR. Tavan da gerek: sentetik ground-truth'ta %100'e ulaşılamıyorsa B1↔B2 boşluğu hattın kendi kaybını da içerir. Kural: **bir orana "düşük/yüksek" demeden önce kontrol koşulu ölçülür**; tabanla B2 arasındaki mesafe = B2'nin ayırt edici GÜCÜ. `docs/G1-V0-KAPI-PROTOKOLU.md §3.2b`'ye ÖN KOŞUL olarak yazıldı — **eşikler DEĞİŞTİRİLMEDİ** (eşik tasarımı koordinatörün; eklenen şey ne zaman OKUNABİLİR olduğu). Şu an ölçülemez: triyaj reddettiğini indirmiyor → karantina-örnek çekmek gerek (L-171 yolunun aynısı) | koordinatörde | `docs/G1-V0-KAPI-PROTOKOLU.md` |
| L-181 | çözüm | **P0** | **MOTOR ÜÇ TESTTE ÖLÇÜMÜ TERS YÖNDE TOPLUYORDU — canlı kusur, sweep buldu.** Zincir: [[L-178]] hükmüyle `reps` config'ten çıktı; tek yetimi silip geçmek yerine (ölü-config ailesinin 5. vakası) batarya test-düzeyi şema yüzeyinde TARAMA yaptım → `aggregation` da okunmuyordu → onu motorun GERÇEKTE okuduğu alanla çaprazlayınca kusur çıktı. Motor tepe yönünü `scoring.higherIsBetter`'dan seçiyor ve alan YOKKEN **sessizce `true`** varsayıyordu; beş test hiç beyan etmemişti, üçü MİNİMUM istiyor: **deep_squat** (üç sinyal birlikte: `aggregation:min` + `presence.op '<='` + `movementPresence 'lte'`, son ikisi fixture-doğrulanmış) · **forward_lunge** (`knee_height` — lunge dizi AŞAĞI indirir) · **thoracic_rotation** (`shoulder_line_foreshortening` — kendi kalibrasyonum: 0.80=kameraya dönük → 0.00=yandan, rotasyon DÜŞÜRÜR). Bu üçünde motor MAKSİMUMU tutuyordu → **deep_squat'ta EN AZ çömelinen an "ölçüm" olarak raporlanacaktı.** Dördüncüsü (**overhead_squat**) config'in kendi içinde çelişiyordu (`aggregation:max` ↔ `higherIsBetter:false`); orada okunan alan DOĞRU, yetim alan yanlıştı (`trunk_lean`: az eğim iyidir). ✅ **KİRLENME YOK ve bunu VARSAYMADIM, KONTROL ETTİM:** Python rig bu iki alanı hiç okumuyor (hasat/referans sayıları o yoldan geliyor) ve Dart motoru bugüne dek yalnız `overhead_reach` koştu (max, doğru) → kusur kodda canlıydı ama HİÇBİR raporlanmış sayıya ulaşmamıştı. **Panzehir kök-nedende:** `higherIsBetter` artık ZORUNLU (yokluğu SERT config hatası) — bir yön alanının güvenli varsayılanı OLAMAZ, çünkü "büyük olan iyidir" bir İDDİADIR ve beyan edilmediği yerde iddia edilmemeli. 12 testin yönü ölçülmüş kanıtla açıkça yazıldı; `overhead_squat` aggregation `min`e düzeltildi. `tools/direction_check.py` üç yön sinyalinin ÇELİŞMEDİĞİNİ zorluyor ve **tek bir alanı otorite İLAN ETMİYOR** — sweep gösterdi ki elle yazılan iki alanın ikisi de tek başına yanılabiliyor, o yüzden çelişkiyi GÖRÜNÜR kılmak daha güvenli. `aggregation` böylece bir OKUYUCU kazandı: **silmekten iyi bir cevap, çünkü okuyucusu olmayan alan süse dönüşür ve süs sessizce yanlış olabilir.** Pozitif ikiz: min-yönlü ve max-yönlü testlerin ikisi de ayrı ayrı kanıtlandı (biri olmadan "yön çalışıyor" denemez). 🎓 Sert-hata testi ilk yazımda YANLIŞ sebepten kırmızı yandı — fixture `scoring.source`'u da atlıyordu, parse DAHA ÖNCE patlıyordu; **hatanın PATH'ini iddia etmek** bunu yakaladı, tip-only `throwsA` hiçbir şey kanıtlamadan geçerdi | **kapalı** | `tools/direction_check.py` · `lib/src/battery.dart` · `config/tests/lissom-assessment.v1.json` (1.11.0) |
| L-182 | çözüm | P1 | **Hüküm-YOK yollarının canlılık kapısı** (aile fallback-canlılık reçetesi). Bir `ResultCode` enum değeri üç şeyin hiçbirini garanti etmez: **üretiliyor mu** (motorda o kodu döndüren yol var mı, yoksa kod bir temenni) · **sınanıyor mu** (hiçbir test iddia etmiyorsa o yolun çalıştığını kimse bilmiyor) · **konuşuyor mu** (yüzeyde AÇIK cümlesi mi var, genel yedeğe mi düşüyor — ikincisi "sebebi isimle söyle" sözünü sessizce bozar, L-135). `tools/noverdict_liveness.py` üçünü birlikte soruyor; `measured` ADIYLA+GEREKÇESİYLE muaf (sessiz istisna listesi kapıyı oyar). **Sonuç: 6 canlı kodun hepsi geçti — temiz kapı da bir sonuçtur.** Öz-test hayalet kod uydurup üç kusuru birlikte yakalıyor + enum okunamazsa sessiz-yeşil vermiyor | **kapalı** | `tools/noverdict_liveness.py` |
| L-183 | çözüm | P1 | **Pozitif-ikiz taraması: 5 vacuous-geçiş yolu, hepsi benim.** 92 test bloğu tarandı — pozitif çapası OLMAYAN iddialar aranıyor (yalnız-yokluk iddiası, özellik TAMAMEN ÖLÜ olduğunda da geçer). İlk regex 21 bloğu işaretledi ama **eşitlik iddiaları da pozitif çapadır** → tarayıcıyı düzelttim, SONRA hareket ettim (kaba bir taramaya göre 21 dosyaya dokunmak, gürültüyü işe çevirmek olurdu). Gerçek 5: (1) yasak-sözcük taraması BOŞ ağaçta geçiyordu · (2) `real_config` başlığı "dürüstçe measuredNoBands'e düşer" diyordu ama gövde bunu HİÇ iddia etmiyordu — **başlığın vaat ettiği davranış gövdede yoksa yoktur** · (3) `reference_status` `lessonClass==null` iddia ediyordu, ama ölçüm ALINMADIYSA o da null → "normal rejim" hakkında hiçbir şey kanıtlamadan geçerdi · (4) girişim-yok testi sebebin HANGİSİ olduğunu iddia etmiyordu · (5) mobilya-sözcük testi **ELLE YAZILMIŞ sabit listesi** üzerinde dönüyordu → biri sabiti yeniden adlandırıp listeden düşürünce sonsuza dek yeşil kalırdı; `status_weave_check.py`'ye taşındı ve küme dosyadan **TÜRETİLİYOR** (küçülemez), öz-test Dart↔Python listelerinin AYRIŞMASINI da kırmızı yakıyor (iki liste tutmak, birinin bayatlaması demektir). **Tarama artık 0 döndürüyor.** | **kapalı** | `test/*.dart` · `tools/status_weave_check.py` |
| L-184 | bulgu+çözüm | P1 | **`reclassify_pool.py` İKİ transkript deposundan BİRİNİ okuyordu — 11 manifest YANLIŞ ÖNCÜLLE fail-closed olmuş.** Çoğul-yönerge ailesi (`40e80fc`) için havuzu yeniden sınıflandırırken kendi aracımdaki (L-167) kusur çıktı. Ölçüm: `subs/` 27 kimlik `.en.vtt` · `transcripts/` 20 kimlik `.transcript.json` · **kesişim 1** — iki çekim mekanizması iki ayrı yere yazmış. Betik yalnız `subs/`u okuyordu → **19 videonun metni hiç görülmedi**, sınıflandırma `unknown`a düştü ve gerekçesine *"TRANSKRİPT YOK"* yazdı. **11 manifestte o gerekçe FİİLEN YANLIŞTI**: dosya öteki klasörde duruyordu. 🎓 Ders: **fail-closed olmak doğruydu, YANLIŞ BİR ÖNCÜLLE fail-closed olmak değil** — ve manifeste yazılan sahte gerekçe, sebebi arayan bir sonrakini de yanıltıyordu. Asıl kusur yanlış CEVAP değil, kendinden emin yanlış GEREKÇEydi. **Panzehir:** `_transcript` iki depoyu birleştiriyor + **yanlış-öncül kapısı** — "transkript yok" demeden ÖNCE o kimliğe ait dosya var mı diye SORUYOR, varsa yüksek sesle bildiriyor (eski gerekçesi "yok" diyen kimlikleri de işaretliyor); çıktı depo sayılarını taşıyor ki sessizce boş bir dizin "okundu" gibi görünmesin. **KÖKEN AYRIMI — varsaymadım, ÖLÇTÜM:** aynı manifestleri İKİ rig'den geçirdim → çoğul-yönerge ailesinin NET katkısı **tam olarak koordinatörün adını verdiği 2 klip** (`W_O65GVbLQM`, `YghyGHKKojA`) — atıf bağımsızca doğrulandı; **benim klasör kusurumun katkısı 4 EK kaynak** (`0Ttn3z_rVBk`, `PfpJnU8x1kU`, `TuQ4jYbazuw`, `yWfMPZWHnVw`, eski rig de zaten sınıflandırabilirdi ama metni hiç görmedi) + `unknown`da duran **5 kaynağın kesin `passive` dışlanması**. 11 manifest `rigSha: 40e80fc` köken damgasıyla yazıldı (izole worktree, paylaşımlı ağacın dalı DEĞİŞTİRİLMEDİ). ⚠️ **11 fixture eski uygunluk snapshot'ıyla kesilmiş → yeniden kesim gerek (M-F-138)** | **kapalı** | `tools/reclassify_pool.py` |
| L-185 | bulgu | P1 | **Havuz darboğazı UYGUNLUK değil, HAREKET KİMLİĞİ — 23 uygun kaynağın 19'u etiketsiz.** L-184 turundan sonra uygun havuz 19→23 çıktı, ama hareket başına ulaşılabilir büyüme **yalnız `overhead_reach` 3→4**. Tablo: `overhead_reach` 4 uygun+etiketli · **`<ETİKET YOK>` 19 uygun** · 42 `unknown` + 7 `passive` etiketsiz. `deep_squat` ve `lateral_bend` havuzları **hiç büyümedi** çünkü uygun+etiketli tek kaynağı yok. Koordinatörün adını verdiği iki klipten `YghyGHKKojA` → `overhead_reach` (havuza girdi), `W_O65GVbLQM` → **etiketsiz** (uygun ama hangi harekete ait belirsiz, "Wall And Dowel Tests: Hip Hinge" başlığı çoklu-test). Yani **rom_mode kapısını açmak referans havuzunu büyütmüyor; sıradaki kapı "bu klipte HANGİ egzersiz var"** — bu [[L-173]] varyant-kimliği sorusunun bir seviye ÖNCESİ ve koordinatörün kuyruğundaki pencere-düzeyi tasarımın aynı köküne dokunuyor. Öneri: etiketsiz 19 uygun kaynağa hareket-kimliği turu; karar koordinatörde | koordinatörde | `~/motion-harvest/lissom/manifests/` |

| L-186 | çözüm | **P0** | **J-028 İHLALİ CANLI YOLDAYDI: köprü ham anizotropik uzayda ölçüyordu.** `CoreMetricReader` kareleri `PoseNormalizer`'a **`toIsotropic` çağırmadan** veriyordu. Çekirdeğin kendi sözleşmesi bunu açıkça yasaklıyor: *"A consumer that has this must go through `frameSize`/`toIsotropic` before measuring"* — gerekçe M-F-30/J-028: MediaPipe `x`'i genişliğe, `y`'yi yüksekliğe bölüyor, ham normalize uzay ANİZOTROPİK ve orada ölçülen her açı en-boy oranıyla BÜKÜLÜYOR (aile ölçümü: eklem açılarının %42'si >5° kayıyor, en kötü 62°). Çekirdek notu ayrıca *"Three apps independently reimplemented this correction the night it was found"* diyor — yani bu bilinen bir aile gotcha'sıydı ve Lissom onu hiç uygulamamıştı. **Panzehir tür düzeyinde:** `frameSize` artık ZORUNLU alan (opsiyonel bırakılsa aynı sessiz bükülme geri gelir; çekirdeğin tercih ettiği yol da bu). 34/34 hasat fixture'ı `resolution` taşıyor → fail-closed olmak KARŞILANABİLİYOR, **uydurma en-boy oranı KONULMADI** (yanlış oran, düzeltmemekten kötüdür çünkü "düzeltildi" GÖRÜNÜR). **Etki ölçüldü, 44.022 eşleştirilmiş karede:** normatif referansa medyan sapma 18,20°→**14,30°** (−21,4%), p95 67,55°→**60,64°** (−10,2%). 24 hücrenin 23'ünde iyileşti, **1'inde kötüleşti** (`knee_flexion_left`/`-wwRNGArTI0` 15,94°→17,42°) — bu gizlenmiyor, M-O-08 zaten ölçmüş: izotropik düzeltme dönük öznede medyanı iyileştirirken en kötü durumu kötüleştirebiliyor | **kapalı** | `lib/src/metric_bridge.dart` · `docs/L-031-UZAY-SAPMASI-OLCUMU.md` |
| L-187 | bulgu | **P0** | **[[L-031]] ARTIK BİR OLASILIK DEĞİL, ÖLÇÜLMÜŞ BİR SAYI — ve canlı-tur ekranını bloke ediyor.** L-031 iki aydır *"uzay farkı sistematik sapma ÜRETEBİLİR"* diye P2'de duruyordu. Ölçtüm: **üretiyor.** Yöntem: aynı fixture'ın AYNI karelerinde iki hat yan yana, eşleştirilmiş fark (3 fixture × 8 köprülü metrik × **44.022 kare**). Normatif taraf Python (`world` 3D + config `frameRef`, `anatomical=True`) — çekirdek doktrini *"when the two disagree, this package is right by definition"*; karşılaştırma bilerek Python tarafında yazıldı, **hakemi taraflardan biri yapmamak için**. 🔬 **Taklit kontrolü (pozitif kontrol): Dart↔elle-yazılmış-ham-2D = 0,00° medyan/p95/max**, 44.022 karede — yani Dart'ın ne yaptığı tahmin edilmedi, ÇİVİLENDİ: ham görüntü-normalize koordinatlarda düz 2D açı, `frameRef` uygulanmadan. **J-028 düzeltmesinden ([[L-186]]) SONRA kalan sapma L-031'in gerçek kapsamı: medyan 14,30° · p95 60,64° · tepe 160,47°.** Bu yuvarlama değil YÖN farkı: `overhead_reach` girişim kapısı 140°'de, bantlar derece cinsinden → hem kapı geçişi hem bant ataması değişir. **Kök neden zaten kayıtlı ve karar zinciri yarım kalmış:** `docs/KARAR-BRIFI-kanonik-uzay.md` seçenek **C**'yi önerdi (düzlemler landmark'tan türetilir); C **uygulandı ama YALNIZ Python'da** — M-F-53 (`b424246`) + M-F-54 (`05aacaf`) commit'leri `git show --stat` ile doğrulandı: **yalnız** `tools/fixture_pipeline/` (94+47 satır, SIFIR Dart). Lissom'un pini `motion_core-v0.9.0`'ın Dart geometrisinde `frameRef` **0 kez** geçiyor (pozitif kontrol: aynı dosyada `AngleKind` 25 kez → grep çalışıyor). **Dart hattı bugün fiilen seçenek B'de duruyor** — brifin *"3D bilgisi atılır, perspektif hatası KALICILAŞIR"* diye reddettiği seçenekte. M-O-08 kalıntının neden kaçınılmaz olduğunu da söylüyor: izotropik düzeltme yalnız 2D izdüşümü onarır, özne dönükken 3D eksen derinlikte kısalır — Lissom'un 12 testinden **8'i** *"yandan dur"* diyor. **Karar koordinatörde** (paylaşımlı çekirdek + 4 kardeş app; eskalasyon kuralı): (1) Dart çekirdeği `world`+`frameRef`'e geçecek mi = C'nin Dart göçü · (2) geçene dek canlı-tur hangi statüde koşacak — **öneri `measurementOnly`** (M-F-185, kod zaten destekliyor), gerekçesi bu sayı · (3) **[[L-118]]/[[L-128]] defter durumu bayat**: ikisi de "AÇIK (koordinatör kararı)" ama C fiilen kararlaşmış ve bir tarafı uygulanmış ⚠️ **BU NUMARA İKİ KAYITTA — atıf çözerken İKİSİNE de bak (L-305; yeniden numaralandırma YOK: bir numarayı değiştirmek ona işaret eden HER atfı sessizce yanlış yapar).** | **koordinatörde** | `docs/L-031-UZAY-SAPMASI-OLCUMU.md` · `tools/l031_space_divergence.py` · `packages/lissom_engine/tool/dump_angles.dart` |
| L-188 | çözüm | P1 | **Metrik kapsam kapısı + köprü 4→8; devir notunun iki sayısı yanlıştı.** Bataryanın gerektirdiği geometrik metrik kümesi artık config'ten **TÜRETİLİYOR** (elle yazılmıyor): `primaryMetric` + girişim kapısı + `guardMetrics` + guard kuralları, `{side}` çözülmüş → **19** metrik (+`hold_duration`, geometri-dışı). Devir notu **"18"** diyordu (eksik sayma) ve **"5 bağlı (… + trunk_lean)"** diyordu; ağaçta **4** bağlıydı, `trunk_lean` Dart tarafında **hiçbir yerde** geçmiyordu — geçemezdi de. **+4 yeni köprü, konvansiyonu ÖLÇÜLDÜ ([[L-181]] dersi, varsayılmadı):** `hip_flexion` L/R (ayakta düz **180,0°** · diz öne+yukarı **78,7°** → çevrim YOK, config "smaller = deeper" diyor) · `elbow_extension` L/R (kol düz **180,0°** · dirsek bükülü **6,3°** → çevrim YOK, guard `<150`=bükülü). Landmark üçlüleri birebir aynı, doğrulandı. **Kalan 11 metrik İSİMLİ engelle beyan edildi:** `corePlaneSeparationMissing` ×4 (çekirdekte tek ve İŞARETLİ `trunk_tilt` var — ölçüldü: −97,9°…+124,4°; config iki AYRI düzlem metriği istiyor, ikisini aynı sayıya bağlamak **[[L-011]]'in ölü-metrik sınıfı** olurdu) · `coreLacksMeasureKind` ×7 (`distance_norm`/`height_diff_norm`/`line_deviation_norm` Dart çekirdeğinde YOK, Python'da var). **Kapı** `metric_coverage_test.dart`: *gereken = köprülü ⊎ beyan edilmiş* bölmesini zorluyor (eksik · bayat · çelişkili beyan, üçü ayrı ayrı) + her binding'in config `frameRef`'ini DOĞRU beyan ettiğini + `kBridgeIsReferenceEquivalent`'in sessizce `true`ya çekilmediğini. `frameRef` uygulanamıyor ama **kaydı tutuluyor** — `aggregation`'ın okuyucusuz kalıp sessizce yanlışlaşması ([[L-181]]) tam bu sınıftı. Çekirdeğin KENDİ `MeasurementSpace` sözlüğü kullanıldı, paralel sözlük yazılmadı. **4 sabotaj öz-testi** kapıyı gerçekten kırmızı yaktırıyor + pozitif kontrol (boş config'te bölme iddiaları trivially geçerdi) | **kapalı** | `packages/lissom_engine/test/metric_coverage_test.dart` |

| L-189 | çözüm | P1 | **M-F-230 pozitif kontrolü kuruldu — ve tek yönlü hâli YANLIŞ ALARM verirdi.** Koordinatör zeyli (2026-08-04) her `MOCORE_ANATOMICAL=1` turu için pozitif kontrol zorunlu kıldı: *"çıktılar bit-aynıysa bu 'fark yok' DEĞİL 'bayrak bağlanmamış' demektir."* Kuralı olduğu gibi uygulamak KUSURLU olurdu, çünkü ölçtüm: `measures.evaluate` bayrağı **yalnız** `frame_ref ∈ (gravityYaw, proximal, none)` metriklerinde kullanıyor — `camera` çerçevesinde HİÇBİR ŞEY yapmıyor. Yani `shoulder_line_foreshortening`in bit-aynı çıkması bayrak kusuru değil, **doğru davranış**. Bu yüzden `tools/two_mode_report.py` kuralı **iki yönlü** uyguluyor: **pozitif kontrol** (bayrağın dokunduğu metrikler gerçekten değişiyor mu → hepsi aynıysa bayrak bağlanmamış, tur GEÇERSİZ) + **negatif kontrol** (`camera` metrikleri gerçekten sabit mi → değişiyorsa bayrak FAZLA yere bağlı). Yalnız pozitif kontrol *"bayrak bağlı"* der; ikisi birlikte *"bayrak DOĞRU yere bağlı"* der. **Koşuldu, GEÇTİ:** 3 gerçek fixture, `8/11` metrik-fixture çiftinde mod ölçülebilir fark üretti (ör. `hip_flexion_right` Δmed **+21,6°**, `knee_flexion_right` **+17,9°**), `camera` çifti bit-aynı kaldı. **Ayrıca isimli bir kör nokta:** koordinatör *"fixture_check'in zaten bu env'i okuyor"* dedi ve DOĞRUYDU (`tools/fixture_check.py:76`) — benim ilk grep'im yanlış ağaçta (motion-core rig'i) arayıp "okumuyor" sonucuna varmıştı; ağaca karşı ölçmek düzeltti. ⚠️ **Yapısal uyarı raporda:** `tools/landmark_quality.py` — L-171 netlik eşiğinin GİRDİSİ — `measures`'ı hiç import etmiyor, yani `mz.evaluate`'ten geçmiyor; o katmanda iki modun aynı çıkması YAPISAL, bayrak kusuru DEĞİL. Şart 5 ("eşik-türetimi anatomik sayılardan") bu yüzden L-171'in landmark-kalitesi girdilerinde **boş bir şarttır** ve tek-yönlü kural orada yanlış alarm verirdi | **kapalı** | `tools/two_mode_report.py` |
| L-190 | bulgu | P1 | **BEŞ METRİK `frameRef: gravityYaw` BEYAN EDİYOR AMA HESAP O ÇERÇEVEYİ YAPISAL OLARAK KULLANMIYOR** — [[L-181]]'in tam sınıfı (beyan edilen ama okuyucusu olmayan alan), iki-mod kontrolü ortaya çıkardı. `heel_rise` L/R + `knee_height` L/R (`height_diff_norm`) ve `reach_depth` (`distance_norm`, `plane: none`) üç fixture'da da **bit-aynı** çıktı. Sebep tahmin edilmedi, KODDA ölçüldü: `measures.evaluate` gövdesinde ölçü tipi başına `axes` kullanımı → `angle3` EVET · `angle_vertical` EVET · `line_deviation_norm` EVET · **`height_diff_norm` HAYIR** (yalnız `(pts[0][1]-pts[1][1])/torso`, dünya y'sini dikey sayıyor) · `distance_norm` yalnız `plane != "none"` iken (reach_depth'in plane'i `none` → atlanıyor). Yani M-F-54 taksonomisi bu iki ölçü tipini KAPSAMIYOR ve config onların yerçekimi-göreli ölçüldüğünü İDDİA etmeye devam ediyor. Risk somut: MediaPipe world landmark'ları kalça-merkezli ama yönelimi KAMERAYA göre — telefon roll yaparsa world y yerçekimi DEĞİLDİR, ve bu beş metrik sessizce kamera-göreli "dikey" ölçer. **M-F-56 kriter-2'ye etkisi:** anatomik moda çevirmek bu beş metriği HİÇ değiştirmeyecek; flip "temiz" görünse de beyan-uygulama ayrışması kapanmaz. **Karar koordinatörde** (ölçü tasarımı + paylaşımlı rig): ya beyan düzeltilir (bu iki ölçü tipi için `gravityYaw` anlamsız → doğru değer ne?) ya hesap düzeltilir (gerçek yerçekimi-hizalı dikey). Üçüncü seçenek YOK: uygulanmayan bir beyan bırakmak, `aggregation`'ın süse dönüşüp sessizce yanlışlaşması ([[L-181]]) demektir | **koordinatörde** | `tools/two_mode_report.py` · `mocore/measures.py` |
| L-191 | çözüm | P2 | **Aracın kendi kör noktası: `-` ile başlayan hasat kimliği argparse'a flag görünüyordu.** Hasat kimlikleri YouTube video id'si ve `-` ile BAŞLAYABİLİYOR — kütüphanede `-wwRNGArTI0` var (34 kaynağın 1'i). `nargs="*"` onu *"unrecognized arguments"* diye reddediyordu, yani araç kütüphanenin gerçek bir alt kümesinde HİÇ çalışmıyordu; ama `--all` yolu glob kullandığı için **sorunsuz görünüyordu** — kusuru yalnız tek-fixture çağrısı açığa çıkarıyor. argparse tamamen kaldırıldı: `--all`/`-h` dışındaki her şey dosya adı, bilinmeyen seçenek 64 ile ölür. 🎓 Ders: **bir aracı yalnız toplu yolundan sınamak, tek-öge yolundaki kusuru gizler** — ve kimlik uzayında `-` gibi bir karakter varsa CLI ayrıştırıcısı veri sözleşmesinin parçasıdır | **kapalı** | `tools/two_mode_report.py` |

| L-192 | çözüm | P1 | **L-190/1 KAPANDI (beyan düşürüldü) + muafiyet artık KENDİNİ SINAYAN bir iddia.** Koordinatör hükmü ölçü türüne göre ayırdı: `reach_depth` (distance_norm, `plane: none`) → **beyan** düzeltmesi bende; 3B Euclidean mesafe **rotasyon-değişmezidir**, `gravityYaw` boş iddiaydı → `frameRef: none` (config 1.2.0→**1.2.1**, davranış **bit-değişmez**, değişen tek şey beyanın doğru olması). `heel_rise`/`knee_height` TERS yönde çözülüyor (hesap çekirdekte beyana getirilecek, koordinatör işi — YAMALAMADIM). 🎓 **Ders config `_notes`'a yazıldı:** uygulanmayan bir çerçeve beyanı İKİ farklı kusurun belirtisi olabilir — beyan fazlaysa beyan düşer, hesap eksikse hesap yükselir; ikisini aynı reçeteyle kapatmak birini yanlış çözer. ⚙️ **Araç düzeltmesi (yoksa yanlış alarm):** `frameRef: none` + `plane: none` olan metrik yapısal olarak bit-değişmez (bayrak `plane`i `none`a zorluyor, o da zaten `none`), ama `none` FLAG_TOUCHES'ta olduğu için araç ona "bit-aynı (beklenmiyor)" diyecekti. `EXPECTED_INVARIANT` tablosu eklendi: muafiyetler **gerekçeli** ve **iki yönlü sınanıyor** — listede olmayan dokunulan metrik bit-aynıysa KIRMIZI (bayrak bağlanmamış), **listede olan metrik DEĞİŞİRSE de KIRMIZI** (gerekçe çürük, liste bayat). Yani muafiyet sessiz istisna değil; `heel_rise`/`knee_height` satırları GEÇİCİ ve çekirdek düzeltmesi inince SİLİNECEK — **liste böylece o düzeltmenin tamamlandığını da kanıtlıyor.** Kapı yeniden koşuldu: pozitif **8/8** · muafiyetler tutarlı **3/3** · negatif kontrol geçti. ⏱️ Not: `--all` (34 fixture) >2 dk sürüyor, 3 fixture yeterli ve koordinatörün istediği de o | **kapalı** | `config/metrics/lissom-metrics.v1.json` (1.2.1) · `tools/two_mode_report.py` |
| L-193 | bulgu | P2 | **Ek kontrol kalemi (koordinatör talebi) — Dart tarafında L-190 sınıfı ŞU AN YOK, ama MEVCUT bir örneği var.** Ölçüldü, iddia edilmedi: Lissom Dart kodunda (`packages/lissom_engine/lib` + `lib`) **ham `.y` aritmetiği HİÇ YOK**; `heel_rise`/`knee_height`/`reach_depth`/`plank_hip_deviation` yalnız `kUnbridgedMetrics` kayıtlarında geçiyor, yani "yok" olarak BEYAN EDİLMİŞ halde — hesap hiç yazılmadığı için ham-y kusuru da doğmamış. **AMA aynı sınıfın Dart'ta canlı bir örneği var:** pinli çekirdeğin `trunkTilt`i dikeyi **görüntü dikeyi** sayıyor (`rawTorsoAxisAngle − (−π/2)`), yani kamera roll'unda yerçekimi dikeyinden sapar — config ise `trunk_lean`/`trunk_lateral_tilt` için `gravityYaw` BEYAN EDİYOR. Bu, L-190/2'nin (Python `height_diff_norm` dalının ham dünya-y kullanması) Dart'taki karşılığıdır. Köprü bugün `trunkTilt`i tüketmiyor (`corePlaneSeparationMissing` ile bloke), ama **blocker'ın gerekçesi eksikti**: yalnız "düzlem ayrımı yok" değil, "dikey referansı yerçekimi değil kamera" da var. Gerekçe `metric_bridge.dart`'a ikinci madde olarak yazıldı — düzeltme YAPILMADI (koordinatör "önce ölçüm" dedi). Sonuç: **Dart'a bir gün height-tipi metrik eklenirse iki normalize modunun İKİSİNDE de yerçekimi dikeyi yok** (`translateScale` = ham görüntü y'si, `rotate` = gövde-göreli y) → aynı kusur doğmaya hazır | **koordinatörde** | `packages/lissom_engine/lib/src/metric_bridge.dart` |

| L-194 | çözüm | P1 | **§3.2b TAVAN YARISI KAPANDI: hat kaybı SIFIR** — B1/B2 boşluğu artık saf koşul etkisi olarak okunabilir. Sentetik ground-truth (`confidence=1.0`, gürültü yok, landmark'lar kinematik zincirden) 10 geometrik testin **10'unda VMR = 1,000**, her iki frameBasis'te. Yani hat kendi başına hiçbir geçerli ölçümü düşürmüyor; protokolün *"%100'e ulaşılamıyorsa fark hattın kendisinden gelir"* şartı KARŞILANDI. Geometrik olmayan iki test (`single_leg_balance`, `plank_hold` → `hold_duration`) sessizce atlanmadı, raporda isimle bildirildi. **Taban yarısı** (triyajın reddettiği kliplerde VMR) karantina çekimini bekliyor. 🔬 **VARYANS KAPISI İKİ GERÇEK DELİK BULDU** — "VMR %100" tek başına hiçbir şey kanıtlamıyor: metrik senaryo boyunca SABİT kalırsa senaryo onu hiç sürmüyor demektir ve %100 "hat kayıpsız" değil **"hiçbir şey ölçülmedi"** anlamına gelir ([[L-183]] vacuous-geçiş sınıfı). (1) **`overhead_squat`** — primary metriği `trunk_lean` ama senaryom yalnız kol/kalça/diz sürüyordu, değer 60 kare sabit **0,00°**; düzeltildi (gerçek overhead squat'ta gövde de eğilir). (2) **`thoracic_rotation`** — senaryom SABİT yaw uyguluyordu, yani rotasyon hiç değişmiyordu (0,80 sabit), oysa testin ÖLÇTÜĞÜ ŞEY rotasyonun kendisi; yaw artık 0→60° RAMPA. İkisi de "geçen" bir tavan üretiyordu — kapı olmasa rapor %100 der ve iki test hakkında hiçbir şey bilmediğimizi söylemezdi. 🎓 **Test→poz eşlemesi bir TASARIM kararıdır, ölçüm değil** (`Pose` yalnız sagittal + lateral_bend + heel_lift taşıyor, config'ten türetilemez) → her eşleme gerekçeli yazıldı, gizli bırakılmadı; eşleme yanlışsa tavan da yanlış olur | **kapalı** | `tools/synthetic_ceiling.py` · `docs/32b-TAVAN-OLCUMU.md` |
| L-195 | bulgu | P1 | **M-F-54 İDDİASI SENTETİK GROUND-TRUTH'TA DOĞRULANDI: anatomik modun yaw sapması tüm kategorilerde TAM SIFIR.** T-B senaryosu (yaw=±30°, Lissom'un 12 testinden 8'i *"yandan dur"* dediği için süs değil): anatomik mod 9 metrikte de yaw=0 değerini BİREBİR korudu (85,00 · 120,00 · 12,50 · 10,00 · 40,00 · 20,00 · 140,00 · 1,64 · 0,81). Kamera modu saptı: `active_straight_leg_raise` **+6,86°** · `deep_squat` **+4,62°** · `hip_hinge` **−3,99°** · `overhead_reach` −3,63…+2,09° · `lateral_bend` −2,50° · `ankle` −1,32°. ⚠️ **Kritik ayrım: VMR her iki modda ve her yaw'da 1,000** — yaw geçerliliği DÜŞÜRMÜYOR, yalnız kamera modunda DEĞERİ kaydırıyor. Yani kamera-modu kaybı *"ölçemedim"* değil ***"yanlış ölçtüm"*** biçiminde geliyor ve **VMR kapısı onu YAKALAMIYOR**; B1/B2 eşikleri bu sapmaya kördür. 🔍 **Yaw-işareti duyarlılığı ayrışıyor:** `deep_squat`/`hip_hinge`/`lateral_bend`/`ankle` ±30° için AYNI değeri veriyor (|yaw|'a bağlı) ama `overhead_reach` ve `active_straight_leg_raise` yaw'ın İŞARETİNE duyarlı → ikinci grupta kamera modu gürültü değil **yönlü sapma** üretiyor. ✅ `thoracic_rotation` doğru davranıyor (`frameRef: camera` → anat=cam, yaw ofsetiyle 0,69→0,77→0,40 değişiyor; işi rotasyonu ölçmek, anatomik mod onu bozmuyor). ✅ `reach_depth` yaw'dan tamamen bağımsız → [[L-192]]'nin beyan düzeltmesini BAĞIMSIZCA doğruladı. ⚠️ **DÜRÜSTLÜK NOTU: bu senaryo L-190/2'yi SINAMIYOR** — `knee_height` de yaw'dan bağımsız çıktı ama `height_diff_norm`'un riski **ROLL**'da (kamera yana yatarsa dünya y'si yerçekimi olmaktan çıkar), yaw'da değil; `synth.yaw` roll üretmiyor, dolayısıyla o 0,00 sapma L-190/2 hakkında **hiçbir şey söylemiyor.** Çekirdek düzeltmesinin doğrulaması ROLL senaryosu ister — koordinatörün yeniden-koşum işaretine bunu eklemesi gerek | **koordinatörde** | `docs/32b-TAVAN-OLCUMU.md` |

| L-196 | çözüm | P1 | **KENDİ GEREKÇEMİ DÜZELTTİM: config'e yazdığım roll açıklaması YANLIŞTI.** Koordinatörün öz-düzeltmesini kodda doğruladım: `geometry.body_axes` gravityYaw dalında **`si = [0.0, -1.0, 0.0]`** — yani SI dünya-y'nin kendisi (işaret ters, yukarı yön). Dolayısıyla gravityYaw'da ham-y ZATEN çerçeve-doğru hesaptı ve **anatomik mod roll'u DÜZELTMEZ; düzeltmemesi TASARIM** (docstring: SI gövdeden türetilse `trunk_lean` tanım gereği sıfırlanır, ilk sürümde olan tam bu — A1 60,000° hata). Roll bir **İSİMLİ ÇERÇEVE VARSAYIMIDIR** ("dünya-y = yerçekimi, kamera roll ≈ 0") ve TÜM gravityYaw metriklerini eşit etkiler, height'a özel DEĞİL. Ben 1.2.1'de config `_notes`'a *"onlar gerçekten yerçekimi-dikeyi ister (kamera roll'unda ham-y yanlış ölçümdür)"* yazmıştım — gerekçe yanlıştı, düzeltildi (1.2.2, L-196 notu). L-190'ın gerçek sınıfı roll değil: **BEYANIN TÜKETİLMEMESİ** (`height_diff_norm` beyanı hiç okumuyordu → `proximal` beyan edilse sessizce ham-y ölçmeye devam ederdi) + süs-beyan guard eksikliği. 🎓 **[[L-184]]'ün dersi bu kez BENDE tekrarlandı:** yanlış cevap kadar kötü olan şey kendinden emin YANLIŞ GEREKÇEdir — ve bir config yorumu kalıcı olduğu için yanlış gerekçe orada en uzun yaşar | **kapalı** | `config/metrics/lissom-metrics.v1.json` (1.2.2) |
| L-197 | çözüm | **P0** | **KENDİ ÖLÇÜM ARACIM SAPMAYI ŞİŞİRİYORDU — L-187'nin sayıları DÜZELTİLDİ (hüküm değişmedi).** Zincir: taze rig'e (a4a1ac2) karşı yeniden koşumda medyanlar sıçradı (`heel_rise` 0,01→0,11 · `reach_depth` 1,47→2,23 · `plank_hip_deviation` 0,21→0,05) ve bir an bunu *"çekirdek düzeltmesi bit-aynılık iddiasını ihlal etti"* sandım. **Koordinatöre yanlış alarm vermek yerine kök nedeni aradım ve kusur BENDEYDİ:** `a4a1ac2` `mask_invalid=True` varsayılanını getirdi (L-155/M-F-114), yani geçersiz ölçümler artık `value` alanında NaN dönüyor; ÖNCEDEN ham/ÇÖP sayı taşıyorlardı ve yalnız `valid=False` yan-kanal bayrağıyla işaretliydiler. Benim iki aracım da (`two_mode_report`, `l031_space_divergence`) `.value`'yu **`valid` bayrağını OKUMADAN** topluyor, sonra `isfinite` süzüyordu → **özet istatistikler geçersiz ölçümlerle KİRLENİYORDU.** `valid` otorite yapıldı. **KONTROLLÜ DENEY:** aynı config (1.2.2) + aynı fixture + düzeltilmiş araç ile iki rig **BİREBİR EŞLEŞTİ** (12 metrik × 2 mod × VMR) → koordinatörün *"gravityYaw BİT-AYNI — testle çivili"* iddiası gerçek veride DOĞRULANDI. **L-187 SAYI DÜZELTMESİ:** J-028 öncesi 18,20°/67,55° → **14,83°/45,91°**; sonrası 14,30°/60,64° → **11,29°/37,47°**; J-028 kazancı −21,4%/−10,2% → **−23,9%/−18,4%** (yani düzeltmenin kazancı rapor ettiğimden DAHA İYİ, sapma ise DAHA KÜÇÜK). En kötü hücreler de kaydı: kirli seride tepeyi tutan `knee`/`hip` (p95 155-163°) şişkinliğin kendisiydi; temiz seride `elbow_extension_right` 64,06° ve `shoulder_flexion_right` 59,81°. **HÜKÜM DEĞİŞMEDİ:** 11,29° medyan + 37,47° p95 hâlâ yön farkı, `overhead_reach` girişim kapısı 140°'de → L-031 açık ve canlı-tur ekranını hâlâ bloke ediyor. 🎓 **Ders (L-155'in TÜKETİCİ tarafı):** yan-kanal geçerlilik bayrağı taşıyan bir API'de *"sayıyı al, sonra NaN'ları at"* YETMEZ — bayrağı okumayan kod çöpü gerçek ölçüm sanar; ve bu kusur ancak rig varsayılanı değişince GÖRÜNÜR oldu, yani iki aracım da aylarca sessizce kirli sayı üretebilirdi | **kapalı** | `tools/two_mode_report.py` · `tools/l031_space_divergence.py` · `docs/L-031-UZAY-SAPMASI-OLCUMU.md` |
| L-198 | çözüm | P1 | **Yeniden-koşum TEMİZ + üç muafiyet sınıfı isimlendi + guard benim düzeltmemi ZORUNLU kılıyordu.** Koordinatörün işareti uyarınca izole worktree kuruldu (`scratchpad/rig-a4a1ac2`, detached a4a1ac2 — **paylaşımlı ağacın dalı DEĞİŞTİRİLMEDİ**, M-F-22) ve araç rig-yolu `MOCORE_RIG` env'iyle parametrik yapıldı: varsayılan paylaşımlı ağaç olduğu için taze düzeltme oradan OKUNAMIYORDU, ve araç artık hangi rig'e karşı ölçtüğünü RAPORA BASIYOR (bayat pinle "temiz" demenin panzehiri). **Yeniden koşum: pozitif 8/8 · muafiyet 3/3 tutarlı · negatif kontrol geçti.** Zeyil uyarınca "bit-aynı" artık TEK torba değil, **üç İSİMLİ sınıf**: `camera-negatif` (bayrak dokunmaz) · `yaw-değişmez` (gravityYaw'da SI = dünya-y olduğu için height_diff tüketimi bit-aynı) · `frame-değişmez` (düzlemsiz mesafe rotasyon-değişmezi). Muafiyet gerekçeleri de güncellendi: `heel_rise`/`knee_height` artık "axes kullanmıyor" DEĞİL "SI = dünya-y → tüketim bit-aynı" — muafiyet aynı kaldı ama SEBEBİ değişti ve bunu kaydetmek zorunlu. ⚠️ **Koordinatörün "reach_depth: sende iş yok, config zaten none'du (9cbe893)" iddiası TERS:** `git log` ile ölçtüm — frameRef'i **BEN** değiştirdim (`a575bb1`, gravityYaw→none); `9cbe893` o dosyaya dokunan önceki commit ama frameRef'e dokunmadı. Üstelik **taze rig'in yeni guard'ı eski hâli REDDEDİYOR** (*"düzlemsiz distance_norm rotasyon-DEĞİŞMEZİDİR; 'frameRef: gravityYaw' boş iddiadır"*) → L-192 yapılmasaydı Lissom config'i yeni rig'de **yükleme anında patlayacaktı.** İş yapılmamış değil, tam zamanında yapılmış. 📋 **Dart kontrol kalemi (revize soru) cevabı:** Dart tarafında height-tipi metrik HİÇ YOK (ham `.y` aritmetiği sıfır), dolayısıyla "frameRef tüketiyor mu" sorusu boş — ama **süs-beyan guard'ının Dart karşılığı da YOK**: `metric_coverage_test.dart` beyanın config'e UYGUNLUĞUNU sınıyor, TÜKETİLDİĞİNİ sınamıyor. Guard koyacak bir tüketim noktası olmadığı için bu ancak L-031 kapanışıyla (Dart'ın `world`+`frameRef`'e geçişi) anlamlı olur — o göç guard'ı da beraberinde getirmeli | **kapalı** | `tools/two_mode_report.py` · `packages/lissom_engine/lib/src/metric_bridge.dart` |

| L-199 | bulgu+çözüm | **P1** | **KARANTİNA ÇEKİMİ GEREKSİZDİ — reddedilen kliplerin videoları ZATEN YEREL DİSKTE.** L-180 *"şu an ölçülemez: triyaj reddettiğini indirmiyor → karantina-örnek çekmek gerek"* diyordu ve tur boyunca ağ/slot/403 riski buna göre planlandı. Ölçtüm: `~/motion-harvest/lissom/raw/` içinde **149 dosya** var ve **39 reddedilen klibin hepsinin** `local_path`'i DURUYOR (7 örnek tek tek doğrulandı). Atlanan aşama indirme değil **`extract`**: manifest `stages`'te `pull: ok` + `triage: ok(rejects)` var, `extract` YOK. Yani **[[L-184]]'ün tam sınıfı, bu kez plan düzeyinde: yanlış öncülle fail-closed olmak** — "indirmiyor" doğruydu ama "elde yok" yanlıştı, ve o yanlış öncül iki turdur ölçümü bloke ediyordu. **İndirme YAPILMADI**, ağa çıkılmadı, JabLab'ın slotuna dokunulmadı; yalnız yerel dosyalardan izole karantinaya (`scratchpad/quarantine/`) landmark çıkarıldı — **havuz temiz kaldı, 34 dosya sayıldı ve doğrulandı.** 🎓 Ders: bir ölçümün "imkânsız" gerekçesi de tıpkı ölçümün kendisi gibi TARİHİ olur ve bayatlar; "ölçülemez" hükmü verilirken hangi aşamanın eksik olduğu İSİMLE yazılmalı ("indirilmemiş" ≠ "çıkarılmamış") | **REDDEDİLDİ (kapalı) — YOL: karantina ÇEKİMİ · ÖLÇÜM: klipler zaten yerel diskte (L-180 öncülü çürüdü)** | `~/motion-harvest/lissom/raw/` · `scratchpad/quarantine/` |
| L-200 | çözüm | **P1** | **§3.2b TABAN ÖLÇÜLDÜ — L-180'in korkusu ÇÜRÜDÜ, eşikler taban-göreli OKUNABİLİR.** Ret grubu: yalnız-netlik-reddi 2 klip (`F8q1kEF2JCA` netlik **4,3** · `E3Eu0F73ROI` netlik **8,3**) — kadraj/süre reddi olanlar KASITLA dışarıda, çünkü onlarda düşük VMR'yi netliğe atfetmek karışıklık (confound) olurdu; bu iki klip diğer tüm triyaj kriterlerini GEÇMİŞ. B1 örneklemi: kabul edilen 34 klipten netlik yayılımına göre **5** (41,9 · 98,1 · 153,5 · 200,5 · 1268,9). Ölçüm anatomik modda (M-F-224 şart 5), kamera deltası ayrı kolonda. **Sonuç: medyan ayrışma (KABUL − RET) = +0,429 · RET ≥ KABUL olan test 0/10 · ayrışma <0,10 olan test 1/10** (yalnız `thoracic_rotation`: 0,996 vs 1,000 — metriği `shoulder_line_foreshortening` ve omuz landmark'ları hep görünür olduğu için o metrik zaten ayırt edici değil, eşik kusuru DEĞİL). En büyük ayrışmalar: `deep_squat` +0,749 · `hamstring_reach` +0,742 · `forward_lunge` +0,646 · `active_straight_leg_raise` +0,626 · `ankle_dorsiflexion` +0,620. **Yani B1 (%90)/B2 (%75) eşikleri "poz modelinin taban oranını" ölçmüyor; triyaj gerçekten ayırt ediyor** ve M-F-224'ün eşik-türetim formülü UYGULANABİLİR. ⚠️ **İki dürüstlük notu raporda:** (1) ölçülen şey **kare-düzeyi** geçerlilik oranı, protokolün **deneme-düzeyi** VMR'sinin ÜST SINIRI — muhafazakâr ve doğru yönde bir vekil (kare-tabanı düşükse deneme-tabanı kesin düşüktür), ama aynı sayı değil ve araç bunu her koşumda basıyor. (2) **n=2 ret küçük.** 🔬 **Metodolojik ders:** tek-klip kıyası YANILTTI — `F8q1kEF2JCA` (netlik 4,3, RET) tek bir kabul klibine (`X2u`) karşı 5 metrikte DAHA İYİ VMR veriyordu (shoulder 0,548 vs 0,358 · hip 0,455 vs 0,268 · heel_rise 0,621 vs 0,294) ve bu "eşik ayırt etmiyor" gibi görünüyordu; **popülasyon medyanıyla kıyas ters cevabı verdi.** Bir kontrol koşulu tek örnekle kurulamaz | **kapalı** | `tools/vmr_baseline.py` |
| L-201 | bulgu | P2 | **L-171 düşük-uç: tespit oranı YANILTICI, VMR keskin.** Karantina çıkarımının ham sayıları: `F8q1kEF2JCA` (netlik 4,3) tespit **%65,2** (4651/7137) → L-171'in kabul aralığının (0,795–0,991) ALTINDA, eşik burada haklı. Ama `E3Eu0F73ROI` (netlik 8,3) tespit **%97,1** (9659/9943) → aralığın ÜST kısmında, yani *"reddedilen klip kabul edilenlerin çoğundan daha iyi landmark üretiyor"* [[L-171]] bulgusu düşük-uçta da tekrarlıyor. **AMA metrik-düzeyi VMR bunu düzeltiyor:** aynı klipte alt-vücut metrikleri neredeyse tamamen geçersiz (`knee_flexion` 0,002 · `tibia_inclination` 0,002 · `heel_rise` 0,002 · `reach_depth` 0,002 · `knee_height` 0,002 · `plank_hip_deviation` 0,002) buna karşılık üst-vücut yüksek (`trunk_lean` 0,939 · `shoulder_flexion` 0,823 · `shoulder_line` 0,999) — landmark TESPİT ediliyor ama alt vücut kullanılabilir değil. **Sonuç: L-171'in dört ölçüsü (tespit oranı · görünürlük · jitter · kadraj-içi) yanlış soruyu soruyor olabilir; asıl soru "kaç landmark bulundu" değil "kaç GEÇERLİ ÖLÇÜM üretti".** Bu, netlik eşiğinin landmark-kalitesi ölçüleriyle savunulamazken VMR ile savunulabilir olduğunu düşündürüyor — ama **eşiğin TAM YERİNİ türetmek için sınır klibi şart** ve o hâlâ çıkarımda: `o0knCTTMZHM` netlik **38,7** (eşik 40'ın hemen altı, 698s/228MB). Sınır klibi B1'e mi tabana mı yakın çıkacak, eşik-türetiminin belirleyici noktası — **tur bu yüzden KAPATILMADI** | **açık — sınır klibi bekleniyor** | `tools/vmr_baseline.py` · `docs/NETLIK-ESIGI-YENIDEN-TURETME.md` |
| L-202 | ders | P3 | **`nohup ... &` ile arka plana atılan iş, harness'ın "completed" bildirimini YANILTIR.** Üçüncü karantina çıkarımını `nohup &` ile başlattım; harness görevi "completed (exit 0)" bildirdi ve bir an çıkarımın bittiğini sandım — oysa exit 0 **başlatma komutunun** koduydu, çıkarım hâlâ koşuyordu (çıktı dosyası yoktu, `pgrep` süreci canlı gösterdi). Doğrusu: uzun işi `run_in_background` ile DOĞRUDAN koştur (harness gerçek bitişi izler) ya da bitişi `pgrep`/çıktı-dosyası ile DOĞRULA. "Exit 0" hangi sürecin kodu olduğu belirsizse hiçbir şey kanıtlamaz — sessiz-yeşil ailesinin araç-zinciri versiyonu | **kapalı** | — |

| L-203 | çözüm | **P0** | **L-171 EŞİK TÜRETİMİ — İSİMLİ KAPANIŞ: EŞİK TÜRETİLEMEZ.** Sınır klibi (`o0knCTTMZHM`, netlik **38,7** — eşik 40'ın hemen altı) L-202 dersiyle doğrulandı (süreç-bitişi + çıktı dosyası + log `✓`, başlatma koduyla DEĞİL): 20.918 kare, tespit **%99,8**. Klip-başına VMR medyanı (10 geometrik testin primary metriği, anatomik mod): RET 4,3→**0,419** · 8,3→**0,454** · SINIR 38,7→**0,515** ‖ KABUL 41,9→**0,918** · 98,1→**0,447** · 153,5→**0,978** · 200,5→**1,000** · 1268,9→**0,590**. **ÜÇ BAĞIMSIZ SEBEPLE TÜRETİLEMEZ:** (1) **netlik VMR'yi öngörmüyor — Pearson r = +0,001** (n=8; Spearman +0,690 yanıltıcı, netlik-reddi grubunun topluca düşük olmasından gelen GRUP etkisi, sürekli ilişki değil). (2) **Gruplar ÖRTÜŞÜYOR:** `ZFTY2UndWNI` (netlik 98,1, KABUL) VMR 0,447 — reddedilen 8,3'lük klipten (0,454) DAHA KÖTÜ; `SfxyICleU4I` (netlik **1268,9**, havuzun en neti) 0,590, sınır klibinin yalnız 0,075 üstünde → RET [0,419–0,515] ∩ KABUL [0,447–1,000] ≠ ∅. (3) **VMR'yi süren değişkenin ZATEN AYRI kapısı var:** öngörücü `fullBodyRatio` (r=**+0,876**, n=4) ve triyaj zaten `fullBodyRatio < 0,6` kapısı uyguluyor (17 klip böyle reddedilmiş) — sinyal netlik eşiğine değil yanındaki kadraj kapısına ait. **M-F-224 formülü:** ölçülmüş-taban ✅ (0,436) ama **ölçülmüş-ayrışma-k ❌** — `k` hesaplanırsa (0,918/0,436=2,1) kabul grubunun İÇ VARYANSINI ayrışma sanmak olur. **Yeni eşik YAZILMADI** ("ölçülmemiş eşik yazılmaz"). Kapı **fail-closed KALIR**, **"dayanaksız-provisional" damgası KALKMADI**, kapı-tasarımı koordinatöre döner. ⚠️ **[[L-201]]'in VMR-yeniden-temellendirme hipotezi DENENDİ ve ÇÜRÜDÜ** — dayanak beyanı `docs/L-171-ESIK-TURETIMI-KAPANIS.md`'de isimli yazılı (sessiz değil, M-F-253/2). 🔬 **[[L-200]] ile ÇELİŞMİYOR, farklı mercek:** L-200 test-başına ret↔kabul medyanı (+0,429), bu klip-başına tüm-test medyanı; eşik **KLİP düzeyinde** uygulandığı için türetim mercek olarak ikincisini ister ve orada kabul grubunun iç varyansı ret↔kabul ayrımından BÜYÜK — medyan iki düşük-VMR kabul klibini maskeliyordu. **Ders: doğru merceği ölçüm değil KARAR BİRİMİ belirler** (L-200'ün "tek örnekle kontrol kurulamaz" dersinin ters yönde tekrarı). 📋 Koordinatöre gözlem (öneri DEĞİL, confound'lu): netlik-reddi alan klipler triyajda kadraj ölçümüne HİÇ ulaşmıyor (erken çıkış → `fullBodyRatio: nan`), o yüzden kadraj↔VMR yalnız n=4'te ölçülebildi; iki kapıyı ayrıştırmak triyajın erken-çıkış sırasını değiştirmeyi ister. **Örneklem: n=3 ret + 5 kabul — küçük ve gizlenmiyor;** r=+0,001 bu boyutta bile anlamlı (ilişki VARSA işaret verirdi) ama `fullBodyRatio` n=4 **hipotez üretir, hüküm vermez** | **kapalı — eşik türetilemedi (dürüst son)** | `docs/L-171-ESIK-TURETIMI-KAPANIS.md` · `tools/vmr_baseline.py` |

| L-204 | çözüm | **P1** | **FLIP SONRASI KANONİK ÇÖZÜCÜYE GEÇİLDİ — ve geçiş "küçük temizlik" değil GERÇEK bir tutarsızlığı kapattı.** Koordinatör bunu "doğal dokunuşta, acele yok" diye verdi; ölçtüm ve acelesi VARDI: flip (çekirdek `4204272`, `ANATOMICAL_DEFAULT = True`) sonrası `fixture_check.py`'nin elle satırı (`os.environ.get("MOCORE_ANATOMICAL") == "1"`) kanonik çözücüyle **ÇELİŞİYORDU** — env yokken `mz.anatomical_mode()` = **True**, o satır = **False**. Yani env set edilmemiş HER koşum sessizce **kamera** modunda ölçüyordu, oysa sistemin kanonik varsayılanı anatomik; bu tam olarak L-181/L-190 ailesinin "sessiz varsayılan" sınıfı ve flip'in kendisi onu doğurmuştu. **Dağınık-okuma taraması yapıldı (M-F-241):** Lissom araçlarında tek kaynak `fixture_check.py:76`, başka yok. **İki ek düzeltme geçiş için ZORUNLUYDU:** (1) rig yolu sabit paylaşımlı-ağaç yoluydu → `MOCORE_RIG` env'iyle parametrik yapıldı (paylaşımlı ağacın dalı değiştirilemez, M-F-22, yani taze çekirdek oradan okunamıyor); (2) **fail-closed:** kanonik çözücü yoksa `hasattr` kapısı İSİMLE durur — sessizce elle-okumaya düşmek "bayat rig'e karşı anatomik koştum" sanmak olurdu, yani kapatmaya çalıştığım kusurun aynısı. **Üç env durumu da doğrulandı:** taze rig + env yok → `True` ✅ · env=`0` → `False` (açık opt-out korunuyor, M-F-53 şart-b) ✅ · bayat rig → isimli hata ✅. ⚠️ **Koordinatöre bildirim:** bu geçiş sonrası `fixture_check.py` **paylaşımlı ağaçla (05aacaf) artık koşmaz** — `MOCORE_RIG` ile taze worktree göstermek gerekiyor. Paylaşımlı ağacın dalını ben değiştiremem (M-F-22), o ağaç `4204272`'yi görene dek koşumlarda `MOCORE_RIG` şart. Bilinçli takas: **sessizce yanlış modda ölçmek yerine isimle durmak.** Kapılar: 10 Python kapısı + tavan + iki-mod + Dart 79/79 hepsi YEŞİL (fixture_check kapı değil, araç) | **kapalı** | `tools/fixture_check.py` |

| L-205 | çözüm | P1 | **PİN ÇİFTİ İNDİ: `motion_core 0.11.0` + `motion_camera 0.1.2`, tek ref `f13bdc9` — kilitten DOĞRULANDI.** Kamera paketi Lissom'a İLK kez bağlandı. 🔍 **Kendi ilk ölçümüm KUSURLUYDU ve düzelttim:** ilk kontrolde "TAG YOK / ref YOK" çıktı, sebep shell quoting hatasıydı (`$G="git -C ..."` zsh'de tek komut sanıldı) — L-197'nin dersini kendime uygulayıp doğrudan komutlarla yeniden ölçtüm, pinler yerindeydi. **Bir yanlış alarmı koordinatöre bildirmekten yine kök-neden araması kurtardı.** ⚙️ **Pin-eşitliği (J-071) ölçüldü, varsayılmadı:** `f13bdc9` = `motion_camera-v0.1.2` tag'i ve `motion_core-v0.11.0`'ın (`2018469`) **ARDILI** → tek pin ikisini de kapsıyor; `f13bdc9` origin/main'de; iki paket de o commit'te var. Kilit çözümü: her ikisi de `resolved-ref: f13bdc9…`, sürümler **0.11.0** ve **0.1.2**. ⚠️ **Zeyilin (M-F-265) bir notunda düzeltme:** "motion_camera kendi motion_core bağımlılığını TAM-40-SHA bildiriyor" — ölçtüm, `f13bdc9`'te **`path: ../motion_core`** yazıyor. Bu bizim için DAHA GÜÇLÜ: aynı url+ref tek git checkout'una çözüldüğü için kameranın gördüğü çekirdek ile motorun gördüğü çekirdek AYNI dosyalar. TAM-40-SHA yine de yazıldı (pub `ref`'i METİN karşılaştırır). 🚪 **Yeni kapı `test/pin_equality_test.dart` — ÜÇ ÇAPA + 4 sabotaj öz-testi (9 test):** ÇAPA 1 iç tutarlılık (iki `resolved-ref` aynı mı — tek başına yetmez, ikisi de aynı YANLIŞ commit'te olabilir) · **ÇAPA 2 dış sabit** (mühürlü `kSealedRef`, kilitten TÜRETİLMEZ — türetilse tautoloji olurdu) · **ÇAPA 3 çözülen sürüm çifti** (doğru commit'i pinlemek o commit'in beklenen SÜRÜMLERİ taşıdığını kanıtlamaz — tag kaymış ya da pubspec bump'lanmamış olabilir; Ostinato deseni) + `ref` ↔ `resolved-ref` aynı-dize ve 40-karakter iddiaları. Kilit ayrıştırması ELLE (yaml paketi eklemek, bağımlılıkları doğrulayan kapıya yeni bağımlılık katmak olurdu). ✅ **0.9.0 → 0.11.0 bump BREAKING DEĞİL:** engine **79/79** · app **31/31** (22+9) · analyze temiz (ikisi de) | **kapalı** | `pubspec.yaml` · `test/pin_equality_test.dart` |
| L-206 | bulgu | **P0** | **KOORDİNATÖR PAKETİNDE İKİ VARSAYIM YANLIŞ — biri turun TASARIMINI geçersiz kılıyor.** (1) *"18 metrik köprün hazır — bunun için kurmuştun"* → **YANLIŞ, köprü 8/19.** Ölçüldü (koddan türetildi): köprülü 8 (`shoulder_flexion` L/R · `knee_flexion` L/R · `hip_flexion` L/R · `elbow_extension` L/R), engelli 11 (isimli blocker'larla, [[L-188]]). **Sonuç: 12 testin yalnız 3'ü canlı koşabilir** — `overhead_reach` · `deep_squat` · `active_straight_leg_raise`. Koşamayanlar: `overhead_squat`+`hip_hinge` (`trunk_lean`) · `ankle_dorsiflexion` (`tibia_inclination`) · `hamstring_reach` (`reach_depth`) · `lateral_bend` (`trunk_lateral_tilt`) · `forward_lunge` (`knee_height`) · `thoracic_rotation` (`shoulder_line_foreshortening`) · `single_leg_balance`+`plank_hold` (`hold_duration`, geometrik değil → köprü konusu değil). Engel mekanik eksiklik DEĞİL: `distance_norm`/`height_diff_norm`/`line_deviation_norm` Dart çekirdeğinde YOK, ve `trunk_lean`↔`trunk_lateral_tilt` için çekirdekte tek+işaretli `trunk_tilt` var (ikisini aynı sayıya bağlamak [[L-011]] ölü-metrik sınıfı). (2) *"Küçük kalan kalemin bu tura katlanır: fixture_check → kanonik `anatomical_mode()`"* → **ZATEN YAPILDI** bir tur önce ([[L-204]], `d3488e1`); ek olarak o geçiş fail-closed olduğu için `MOCORE_RIG` olmadan paylaşımlı ağaçla koşmuyor, ve kanonik varsayılan zaten anatomik olduğundan "koşumlarda env'i açık yaz" talimatı da gereksiz. ⚠️ **Ayrıca [[L-187]] hâlâ AÇIK:** köprünün ürettiği sayı normatif referanstan medyan **11,29°** / p95 **37,47°** sapıyor — `measurementOnly` yüzey talimatı bu yüzden DOĞRU, ama sapmanın büyüklüğü "ölçüm, not değil" beyanının ne kadar güçlü olması gerektiğini etkiliyor. **KAPSAM KARARI KOORDİNATÖRDE** (eskalasyon kuralı: ölçü/kapı tasarımı + M-F-186 `comingSoon` ↔ `measurementOnly` karışmaz kuralı): 3 testle mi kurulacak (9'u isimli engelle "canlı-değil" görünür), yoksa 11 metriğin çekirdek işi mi beklenecek? **Canlı yüzey bu karar gelmeden KURULMADI** — yanlış statü-örgüsü kurmak, sessizce daraltılmış kapsamdan kötüdür | **koordinatörde** | `packages/lissom_engine/lib/src/metric_bridge.dart` |

| L-207 | bulgu | **P0** | **LISSOM'UN PLATFORM KABUĞU HİÇ YOK — `ios/` ve `android/` klasörleri MEVCUT DEĞİL.** Zeyil-2 (M-F-266) Gravita'nın aştığı üç platform duvarını "entegrasyonunda birebir lazım" diye verdi: iOS deployment 13→14 · Podfile `use_frameworks! :linkage => :static` · CocoaPods `LANG=en_US.UTF-8`. Uygulamaya geçtim ve **üçünün de uygulanacağı dosya YOK:** app kökünde yalnız `build/ config/ docs/ lib/ packages/ test/ tools/` var; `ios/Runner.xcodeproj/project.pbxproj` yok, `ios/Podfile` yok, `android/` yok. Yani Lissom bugüne dek **platform kabuğu olmayan** bir Flutter projesi olarak yaşadı (tüm işler saf-Dart motor + config + araç katmanındaydı; `flutter test` platform kabuğu istemiyor, bu yüzden hiç fark edilmemiş). **Etkilediği kalemler:** (a) üç duvarın hiçbiri şu an uygulanamaz — ön koşul platform kabuğu; (b) `motion_camera` bir Flutter **plugin** (platform kanalları taşıyor: `flutter: plugin: platforms: android...`) → kabuk olmadan çalışamaz; (c) paketin doğrulama ayağı — *"iOS sim + Android debug DERLEME + simülatörde EKRAN KANITI"* — ön koşul karşılanmadan KOŞULAMAZ. **Kabuk oluşturmak (`flutter create --platforms=ios,android .`) yapısal bir karar ve tek başıma almadım:** bundle ID beyanı (`com.yulalab.lissom`, CLAUDE.md'de rezerve), app görünen adı, min sürümler ve **iCloud/codesign tuzağı** ([[feedback-lissom-icloud-build]]: `~/Documents` altındaki Flutter projelerinde `build/` symlink'i iCloud DIŞINA alınmalı, ÖNCE `flutter clean` SONRA symlink — LifeOS ve Gravita'da ölçülmüş) hepsi bu adımda çakılıyor. Koordinatöre gidiyor: kabuğu bu turda kurayım mı, hangi bundle ID/ad ile? | **koordinatörde** | `ventures/lissom/app/` (kök) |
| L-208 | bulgu | P1 | **KAYIP KAYIT, 2026-08-13'te GERİ YAZILDI (L-311 ölçümü buldu).** İki commit bu numarayı iddia etti — `fb701fa` (*"JabLab üç canlı-yüzey deseni tipli — L-208"*) ve `ddd6c25` (*"— L-208..211"*) — ama defterde **hiçbir biçimde kaydı yoktu**; komşuları (L-205·206·207·209·210·211·212) yerindeydi, yani toplu bir kayıp değil **tek bir düşme**. Tazelik kapısı bunu **göremiyordu**: okuyucusu yalnız conventional-commit KAPSAMINA (`fix(L-280):`) bakıyordu, bu iki commit ise numarayı **kuyruğa** yazmıştı ⇒ kapı 186 commit'te 47 numara görüyordu, gerçek 193. ⚠️ **İÇERİK UYDURULMADI:** bu satır yalnız git'ten DOĞRULANABİLİR olanı taşır — iş `live_session_state.dart` (beş mühürlü canlı hâl) + export + testiydi; kaydın ORİJİNAL metni kayıptır ve geri getirilemez. *Bir kaydı geri yazmak, onu hatırlamak değildir; yazılabilecek tek dürüst şey neyin bilindiği ve neyin bilinmediğidir.* | **kapalı** | `packages/lissom_engine/lib/src/live_session_state.dart` · commit'ler `fb701fa` + `ddd6c25` |

| L-209 | çözüm | P1 | **KALEM 1 — PoseSource → metricReader kablolama CANLI.** `live_evaluator.dart`: kaynak yaşam-döngüyü BİLDİRİR, değerlendirici yalnız ÖLÇER (Ostinato deseni, M-F-272). Bu ayrım olmadan yüzey kameranın hâllerini bilmek zorunda kalır ve **gerçek kamera geldiğinde YÜZEY DEĞİŞİR** — oysa değişmemesi tasarımın kendisi. `PoseSourceEvent` sealed: kaynak "ne olduğunu" söylemek ZORUNDA (hâl VEYA kare); sessizce hiçbir şey bildirmeyen kaynak çıkmaz-sokak üretir. **Mimari ayrım:** soyutlama engine'de (saf Dart, test edilebilir), kamera adaptörü app katmanında — çünkü `motion_camera` bir Flutter **plugin**'i ve çekirdek Flutter'a bağlanmamalı (aile kuralı). `FakePoseSource` bir **mock DEĞİL**, ürünün desteklediği ikinci kaynak tipi ve sim kanıtının dayanağı (iOS sim'de kamera YOK); yüzey ikisini ayırt etmiyor. **Kapı: 6 test** — "kaynağın gerekçesi YENİDEN YAZILMAZ" iddiası dahil (kamera-bozuk ↔ geri-çekil farkı silinmesin, M-F-266), tepe-korunur (`higherIsBetter` config'ten, sessiz varsayılan yok — L-181), yokluk-0-sızmaz, + boş-kaynak sabotajı | **kapalı** | `packages/lissom_engine/lib/src/live_evaluator.dart` |
| L-210 | çözüm | P1 | **KALEM 2 — canlı-3 / engelli-9 yüzeyi, SABİT DEĞİL TÜRETİMLİ.** `deriveLiveness(Battery)` hangi testin canlı koşabildiğini köprüden (`kMetricBindings`) TÜRETİR; elle yazılmış bir "canlı testler" listesi köprü değişince **sessizce bayatlardı** — `reps`/`aggregation` ailesinin ([[L-178]]/[[L-181]]) tam aynı tuzağı. Köprü büyüdükçe canlı küme kendiliğinden büyür. `assessment_home.dart`: beyan YÜZEYİN TEPESİNDE (M-F-186 koşul 4 — aşağıda olsaydı kaydırmayan kullanıcı hiç görmezdi, konum içeriğin parçası) · engel metni NEDEN'i taşır · `comingSoon`/vaat dili YOK (vaat, bilmediğimiz bir tarihi ima eder = ölçüm yerine sayı uydurmakla aynı sınıf) · **config okunamazsa ekran YİNE AÇILIR ve sebebi söyler** (çıkmaz-sokak yasağı, M-F-267 desen 1). **Kapı: 6 test, pozitif ikiz İKİ YÖNLÜ** (koordinatör şartı): canlı-3 canlı görünür **VE** engelli-9 isimli görünür — tek yön sınanırsa hepsini engelli gösteren (ya da hepsini canlı gösteren) bir yüzey de geçerdi. Ayrıca beyan-konumu (dy karşılaştırması), vaat-dili taraması ve asset-kaydı iddiası. 🎓 Kendi test iddiam bir kez fazla katıydı: asset kaydını yalnız tam-dosya-yolu olarak arıyordum, oysa Flutter DİZİN kaydı da paketliyor ve kayıt zaten vardı — kusur üretimde değil testte olduğu için iddia düzeltildi | **kapalı** | `lib/app/assessment_home.dart` · `metric_bridge.dart` (`deriveLiveness`) |
| L-211 | çözüm | **P1** | **KALEM 3 — PLATFORM DUVARLARI AŞILDI + SİM KANITI ALINDI; ve EKRAN bir YANLIŞ GEREKÇE YAKALADI.** `pod install` (`LANG=en_US.UTF-8`): **MediaPipeTasksVision 0.10.21 STATİK linkage ile kuruldu** — Gravita'nın duvarı aşıldı (çıplak `use_frameworks!`'ü önceki turda kaldırmam bunun ön koşuluydu). **iOS simülatör derlemesi ✓**, app sim'de koştu (iPhone 17 Pro Max), ekran kanıtı `docs/kanit/sim-canli3-engelli9.png` — canlı-3 (`active_straight_leg_raise` · `deep_squat` · `overhead_reach`) + engelli-9 gerekçeleriyle, beyan tepede, *"Bunlar 'yakında' değil"* cümlesi görünür. 🔴 **ASIL BULGU — ekran kanıtı, testlerin GÖRMEDİĞİ bir kusuru yakaladı:** `ankle_dorsiflexion` için engel metni *"gövde açısı iki ayrı düzlemde ölçülemiyor"* yazıyordu, ama o testin metriği `tibia_inclination` — **kaval kemiği, GÖVDE DEĞİL.** Yani kullanıcıya yanlış anatomi söylüyordum. [[L-184]]/[[L-196]]'nın aynı sınıfı (kendinden emin YANLIŞ GEREKÇE), bu kez **kendi ekranımda ve kendi metnimde.** Sebep yapısal: dört metrik aynı blocker'ı paylaşıyor (`trunk_lean` · `trunk_lateral_tilt` · `tibia_inclination` L/R), tek metin ikisini de anlatmak zorunda. Düzeltildi: *"bu açının gerektirdiği düzlem ayrımı ölçüm çekirdeğinde yok"* — genel ama sebep hâlâ İSİMLİ. 🎓 **Ders: testler metnin VARLIĞINI sınar, DOĞRULUĞUNU sınamaz** — bir gerekçenin anatomisi ancak okunarak yakalanır, ve bu yüzden ekran kanıtı bir formalite değil bir KAPI. ⚠️ `Profile.xcconfig` uyarısı: dosya Flutter şablonunda YOK ve **Gravita'da da yok** (o canlı çalışıyor) → beklenen uyarı, müdahale edilmedi. Kendi ölçüm belirsizliğim: `grep` dosya yokken de "YOK" der, Gravita emsaliyle ayırt ettim. **Cihaz-kanıtı VAAT EDİLMEDİ** — sim'de kamera yok, gerçek-kamera canlılığı cihaz gününe ertelendi ve hiçbir yerde "cihazda kanıtlı" denmedi | **kapalı** | `docs/kanit/sim-canli3-engelli9.png` · `ios/Podfile` |
| L-212 | karar | P1 | **GİYDİRME TURU — tasarım>kod boşluğu KAPATILMADI, İSİMLE bırakıldı.** Design brief 24 ekranlı aspirasyonel bir IA/akış tasarladı (4 sekme + tam canlı-capture akışı); gerçek kod yalnız 3 yüzeyden ibaretti (home + battery-summary + bu turda eklenen statik sayfa). 4-tab nav/kalibrasyon/canlı-capture ekranları İCAT EDİLMEDİ — kamerasız sahte-kamera UI'sı kesinlik taklidi (§8 madde ⑫) olurdu | **kapalı** | `docs/design/DESIGN-AHEAD-OF-CODE.md` |
| L-213 | bulgu | P1 | **battery_summary_view.dart'ın sabotaj-testli Column/Text-sayısı invaryantı İLK taslakta KENDİ elimle kırıldı.** Görsel kart sarmalayıcısı anahtarlı `Column`'un ÜSTÜNE ikinci bir `Column` ekliyordu (`_card` helper'da + `_scoredRow`'un iç `Row`'unda nested `Column`). `flutter test` koşusu bölüm-sırası testini VE case-mismatch'i hemen kırmızı yaktı. Kural: kartlaştırma DAİMA anahtarlı `Column`'un DIŞINDA (`Padding`/`DecoratedBox`), asla içinde ikinci `Column` | **kapalı** | `lib/app/battery_summary_view.dart` |
| L-214 | ders | P1 | **Gelen aile dersi (Choreia): synthetic fixture metni gerçek içerik metninden kısaydı, taşma ancak GERÇEK metinle görünür.** Uygulandı: `deriveLiveness()` gerçek config'e karşı koşturulup en uzun blocker metni (**73 karakter**) ÖLÇÜLDÜ (varsayılmadı); 4 `Row(...)` kullanımı tek tek denetlendi, hepsi `Expanded` ile korunuyor. **Tek gerçek risk: AppBar `actions`** — o `Row`'u biz yazmıyoruz, `Expanded` ile sarmalayamayız. `IconButton`'a çevrildi (yapısal olarak taşma İMKÂNSIZ, cihaz genişliği/yazı-tipi ölçeğinden bağımsız). Doğrulama iPhone SE (**375pt, en dar yaygın cihaz**) ekran kanıtıyla — koordinatör bunu aile standardı yaptı: *"taşma kanıtı EN DAR cihazda alınır, en geniş cihazda değil."* | **kapalı** | `docs/kanit/giydirme-tasma-stres-testi-375pt-2026-08-06.png` |
| L-215 | çözüm | P2 | **`gen_placeholder_register.py` KAPI hâline getirildi** (aile standardı, Choreia emsali): `PLACEHOLDER(` yazılmış ama `unblocked by` taşımayan bozuk işaret artık sessizce atlanmaz, `exit 1`. Öz-test: sabotaj denendi (kırmızı yandığı doğrulandı), temize döndürüldü | **kapalı** | `tools/gen_placeholder_register.py` |
| L-216 | bulgu | P2 | **`Plank Hold`+`Single-Leg Balance`'ın jenerik "measurement bridge not declared (hold_duration)" metnine düşmesi İNCELENDİ, SINIFLANDIRILDI.** `metric_coverage_test.dart`'ın `requiredGeometricMetrics()` fonksiyonu `hold_duration`-sınıfı faz-türevi büyüklükleri **KASITLI VE BELGELİ** olarak dışarıda bırakıyor ("metrik geometrik değil, oturum/faz makinesi üretiyor" — kodun kendi yorumu). Yani test KÖR değil — doğru kapsamda doğru şekilde sessiz. Asıl kusur `_blockerText`'in `null`-dalındaki yorum: *"buraya düşmek zaten bir kapı ihlali"* iddiası bu metrik sınıfı için **YANLIŞ/BAYAT** (kapsam dışı bırakılan bir şeye düşmek ihlal değildir). **Sınıflandırma: (a) yorum bayat.** Motor kararına DOKUNULMADI | **koordinatörde** | `packages/lissom_engine/lib/src/metric_bridge.dart` |
| L-217 | bulgu | P2 | **Giydirme sırasında iki "kod > tasarım" kaçağı bulundu ve KAPATILDI** (hiçbir mockup ham dahili kimlik/sözlük göstermiyor): (1) canlı satır altyazısı ham metrik id'si basıyordu (`shoulder_flexion_left · ...`) — kaldırıldı, artık yalnız ikon+ad. (2) "What Lissom doesn't do" sayfasının AppBar'ı "Profile" diyordu, oysa o sekme kodda yok — başlık kaldırıldı. Üçüncü kalem (`notCompared` satırının uzun metni her-zaman-açık vs. tasarımın ima ettiği "why"-dokunuşu) DAVRANIŞ kararı olduğu için DEĞİŞTİRİLMEDİ, koordinatöre bırakıldı | **kapalı (2/3)** | `docs/design/DESIGN-AHEAD-OF-CODE.md` §2 |
| L-218 | ders | **P1** | **Aile dersi (Ostinato, gelen) — L-214'ün YARIM kaldığı yer.** Ekran kanıtını en-dar cihazda (375pt) almıştım ama OTOMATİK widget testleri hâlâ `flutter_test`'in varsayılan yüzeyinde koşuyordu. Ölçtüm (varsaymadım): bu Flutter sürümünde varsayılan mantıksal genişlik **TAM 800.0pt** (`physicalSize` 2400×1800 @ dpr 3.0) — gerçek en-dar telefonun neredeyse İKİ KATI, Ostinato'nun ölçtüğü rakamla birebir örtüşüyor. Yani kapı yarım kapanmıştı: regresyon test-yeşil görünürken gerçek dar-telefon kullanıcısı taşma görebilirdi — tek seferlik ekran kontrolü KALICI kapı değildir. **Düzeltme:** `test/support/narrow_surface.dart` → `pinNarrowSurface(tester)`, 375×812'ye sabitler + testin sonunda otomatik geri alır. `battery_summary_view_test.dart`'ta TEK NOKTA (paylaşılan `pump()` helper'ı, 9 çağrı sitesine dokunmadan); `assessment_home_test.dart`'ta paylaşılan pump yok, 5 testin her birine ayrı eklendi. **37/37 test 375pt'te de YEŞİL** | **kapalı** | `test/support/narrow_surface.dart` |

---

## 🔒 TUR MÜHRÜ — 2026-08-06, GİYDİRME TURU (design-orkestrasyon devri)

Koordinatör emri: `Lissom.dc.html` tasarımını mevcut yüzeye uygula, 19 madde
uyum denetimi + placeholder kaydı + kapılar. Detay: L-212…L-217 +
`docs/design/DESIGN-AHEAD-OF-CODE.md`. 19 madde uyum tablosu oturum-içi son
mesaj (koordinatör transcript'ten okuyor, bu deftere kopyalanmadı).

### Ne yapıldı
- `lib/app/lissom_theme.dart` — palet/tipografi (Newsreader+Nunito Sans+IBM
  Plex Mono via `google_fonts`)/radi/gölge/hareket süreleri, tasarımdan
  BİREBİR.
- `assessment_home.dart` + `battery_summary_view.dart` giydirildi — YAPI
  (Key'ler, bölüm sırası, satır metin-sayısı invaryantları) DEVRALINDI,
  İCAT EDİLMEDİ.
- Yeni statik sayfa: "What Lissom doesn't do" (5 kalem, tasarım kopyası
  BİREBİR).
- `metric_bridge.dart`: `TestLiveness.name` eklendi (config'ten taşınır) +
  blocker metinleri İngilizce'ye çevrildi (arayüz dili — L-206'nın sözlü
  köprüsü şimdi kullanıcı diliyle).

### Kapılar (tur sonu)
engine **95/95** · app **37/37** · analyze temiz (ikisi de) ·
`wellness_lint.py` temiz (500 metin, 8 dosya) · placeholder kapısı **0
geçerli / 0 bozuk** (öz-test sabotajlandı, kırmızı yandı, temize döndü) ·
iOS sim derleme+koşum ✓ (iki simülatör: 402pt geniş + **375pt dar-stres**).

### Açık kalan (koordinatörde)
`hold_duration` yorum-güncelleme (L-216) · `notCompared` her-zaman-açık vs.
"why"-dokunuşu ürün kararı (L-217) · kamera-doğruluk dipnotu ÖLÇÜM bekliyor
(icat edilmedi) · tasarım>kod boşluğunun tamamı (`DESIGN-AHEAD-OF-CODE.md`
§1) — hepsi tasarım turunun kapsamı DIŞINDA, sonraki ürün-genişletme turuna.

**MÜHÜRLENDİ.**

---

## 🔒 TUR MÜHRÜ — 2026-08-05, KAMERA ENTEGRASYONU (kalan-4 kapandı)

Kurucu emri (M-F-272 sonrası): kalan dört kalem bu oturumda. **Dördü de bitti.**
Sınır tutuldu: **design turuna GEÇİLMEDİ.**

### Kalemler

| # | iş | sonuç | defter |
|---|---|---|---|
| 1 | PoseSource → metricReader kablolama | kaynak bildirir · değerlendirici ölçer · 6 test | L-209 |
| 2 | canlı-3 + engelli-9 **türetimli** | `deriveLiveness()` · iki yönlü pozitif ikiz · 6 test | L-210 |
| 3 | pod install + iOS sim + ekran kanıtı | MediaPipe **statik** ✓ · sim derleme ✓ · kanıt PNG | L-211 |
| 4 | kapanış zinciri | bu mühür + Obsidian + prompt + merge | — |

### Turun en değerli bulgusu

**Ekran kanıtı, 95 testin görmediği bir kusuru yakaladı:** engel gerekçesinde
yanlış anatomi (`tibia` için "gövde"). Testler metnin VARLIĞINI sınıyordu,
DOĞRULUĞUNU sınamıyordu. Bu, ekran kanıtının neden formalite değil KAPI
olduğunun kanıtı — ve dürüstlük kusurlarının en sinsi türü: kullanıcıya
söylenen şey doğru GÖRÜNÜYOR ama yanlış.

### Kapılar (tur sonu)

Dart `lissom_engine` **95/95** (89→95) · `lissom` (app) **37/37** (31→37) ·
analyze TEMİZ (ikisi de) · Python **10 kapı** · araç-kapıları (two_mode ·
tavan · vmr_baseline) · **iOS sim derleme ✓** · **Android debug APK ✓** ·
**pin kapısı 9/9** (üç çapa).

### Kabuk & pin durumu

`ios/` + `android/` kuruldu (`com.yulalab.lissom`, ad **Lissom**) · iOS
deployment **14.0** ×3 · Podfile `platform :ios, '14.0'` +
`use_frameworks! :linkage => :static` (çıplak `use_frameworks!` KALDIRILDI —
statik linkage'ı ezerdi) · `build → ~/lissom_buildout` (iCloud DIŞI, sıra
doğru) · pin `f13bdc9` TAM-40-SHA, Gravita pubspec'iyle birebir teyitli.

### Açık kalan (hepsi koordinatörde)

[[L-187]] L-031 Dart uzay göçü (canlı-tur `measurementOnly` — **bu turda
uygulandı**, göç hâlâ açık) · [[L-193]] süs-beyan guard'ı göçle gelir ·
[[L-203]] netlik kapı-tasarımı · [[L-185]] hareket-kimliği · [[L-173]]
varyant kimliği · 11 fixture yeniden-kesim · **cihaz günü** (gerçek kamera
canlılığı — vaat edilmedi, isimli beklemede).

**MÜHÜRLENDİ.**

---

## 🔒 TUR MÜHRÜ — 2026-08-04, MOCORE KRİTER-2 SON AYAĞI

Koordinatör talimatı M-F-253 uyarınca tur kapatılıyor. **Bu mühür kriter-2'nin
son ayağıdır; sonrası varsayılan-çevirme (flip) koordinatörde.**

### Kriter-2 özeti (M-F-56 · anatomik modda tam hasat-KARAR çevrimi)

**Bayrak-canlılık (M-F-230, iki yönlü — M-F-241 ile resmî zeyil):**
- **POZİTİF KONTROL ✅** taze rig `a4a1ac2`'ye karşı **8/8** metrik-fixture
  çiftinde mod ölçülebilir fark üretti (`hip_flexion_right` Δmed +21,6° ·
  `knee_flexion_right` +17,9°). Bayrak BAĞLI.
- **NEGATİF KONTROL ✅** `camera` çerçeveli metrik bit-aynı kaldı. Bayrak
  DOĞRU yere bağlı.
- **MUAFİYETLER ✅ 3/3 tutarlı**, hiçbiri çürümemiş.

**Üç bit-aynı sınıfı (zeyil revizesi — "bit-aynı" tek şey demiyor):**
`camera-negatif` (bayrak dokunmaz) · `yaw-değişmez` (gravityYaw'da SI =
dünya-y olduğu için `height_diff_norm` tüketimi bit-aynı) · `frame-değişmez`
(düzlemsiz mesafe rotasyon-değişmezi).

**Rig kimliği:** ölçümler izole worktree `rig-a4a1ac2` üzerinde, araç hangi
rig'e karşı ölçtüğünü rapora BASIYOR. **Paylaşımlı ağacın dalı bu tur boyunca
DEĞİŞTİRİLMEDİ** (M-F-22) — `feat/lissom-v3-onayi` @ `05aacaf`.

**L-180 §3.2b — TAVAN + TABAN ikisi de ölçüldü:**
- **Tavan:** sentetik ground-truth'ta 10/10 testte VMR = 1,000 → **hat kaybı
  SIFIR**, B1/B2 boşluğu saf koşul etkisi olarak okunabilir ([[L-194]]).
  Varyans kapısı iki vacuous senaryo yakaladı ve düzeltti.
- **Taban:** medyan ayrışma **+0,429**, RET ≥ KABUL 0/10 → triyaj gerçekten
  ayırt ediyor, eşikler taban-göreli OKUNABİLİR ([[L-200]]).
- **Karantina çekimi GEREKSİZDİ** — videolar zaten diskteydi, ağa
  çıkılmadı, JabLab slotuna dokunulmadı, havuz temiz (34) ([[L-199]]).

**L-171 — eşik türetimi: İSİMLİ KAPANIŞ "TÜRETİLEMEZ"** ([[L-203]]).
Netlik ↔ VMR Pearson **r = +0,001**; gruplar örtüşüyor; öngörücü değişken
kadraj ve onun zaten ayrı kapısı var. Kapı fail-closed KALIR,
"dayanaksız-provisional" damgası KALKMADI, kapı-tasarımı koordinatörde.

### Kapılar (tur sonu)
Dart `lissom_engine` **79/79** + `lissom` (app) **22/22** + analyze TEMİZ
(ikisi de) · Python **10 kapı** yeşil · **+3 yeni araç-kapısı**:
`two_mode_report` (pozitif+negatif+muafiyet) · `synthetic_ceiling` (tavan +
varyans) · `vmr_baseline` (taban + ayrışma).

### Açık kalan (koordinatörde)
[[L-187]] L-031 Dart uzay göçü (canlı-tur `measurementOnly` önerisi) ·
[[L-193]] süs-beyan guard'ı L-031 göçüyle gelecek · [[L-203]] netlik
kapı-tasarımı · [[L-185]] hareket-kimliği turu · [[L-173]] pencere-düzeyi
varyant kimliği · 11 fixture yeniden-kesim ([[L-184]], M-F-138).

**MÜHÜRLENDİ.**

---

## 🔒 VARDİYA MÜHRÜ — 2026-07-30, kurucu direktifiyle KAPANIŞ

Kurucu tüm oturumları sonlandırıyor; devam yeni oturumda. Kapanış öncesi son
kontrol: `lissom/app` main `2d2aae5` origin-eşit, çalışma ağacı temiz.
`motion-core/lib` `feat/lissom-v3-onayi` @ `05aacaf` origin-eşit, çalışma
ağacı temiz, origin/main'in ecdadı (bekleyen merge YOK). Paylaşımlı ağacın
dalı bu vardiya boyunca hiç değiştirilmedi.

**Koordinatörün kapanış-emri metnindeki iki iddia ağaca karşı ölçüldü ve
DÜZELTİLDİ** (kesinti-sonrası "beyana değil ağaca güven" kuralının kapanışta
da uygulanışı):
- *"M-F-53/54 kısmi, MOCORE bekliyor"* → **yanlış**; ikisi de `motion_core-
  v0.9.0` tag'inin içinde (Lissom'un aktif pini), M-F-54 M-F-53'ün bıraktığı
  kısmı kapattı (frameRef taksonomisi, yaw sapması tüm kategorilerde SIFIR,
  A1-A11 iki modda yeşil), Lissom kendi config'i zaten tüketiyor (L-154).
  Kalan iş yok.
- *"bu vardiyanın gotcha'ları: FakeAsync+gerçek-I/O, rootBundle kilitlenmesi,
  wave-körlüğü"* → bu üç terimin app'te, motion-core'da, PROGRESS'te,
  DEFTER'de SIFIR izi var. Muhtemelen kardeş-app çapraz-oturum karışması;
  devir promptuna UYDURULMADI.

Tam vardiya özeti + devralınan kuyruk: `PROGRESS.md` §"VARDİYA KAPANIŞI" +
`YENI-OTURUM-PROMPT.md` (tek devir kaynağı). Kapılar: Dart 69+22 test +
analyze temiz (motor+app) · Python 10 kapı (3 öz-testli) yeşil.

**MÜHÜRLENDİ.**

---

## L-255 — Yokluk ölçen kapı, bulucusunu kanıtlamak zorunda (POZİTİF İKİZ)

**Kaynak:** JabLab, koordinatör aktarımı. `find.byType` **alt sınıfları
eşleştirmiyor** — `FilledButton`ı `ButtonStyleButton` diye aramak *her zaman*
sıfır döndürüyor ve test yeşil kalıyor.

> ***Sıfır bekleyen bir kapı, bozuk aracı asla göstermez.***

**Neden bende özellikle pahalı:** kapılarımın çoğu YOKLUK ölçüyor — *gauge yok*
· *tezahürat yok* · *tıbbi dil yok* · *improved/worsened yok*. Yokluk ölçen bir
kapı **zaten sıfır bekler**, yani **bozuk bir bulucu ile doğru bir sonuç
birbirinden ayırt edilemez.**

**Ölçüm:** 24 `find.byType` kullanımı, 5'i yokluk iddiası. Beşine de pozitif
ikiz eklendi (`test/support/finder_twin.dart`). Üçü sabotajla kanıtlandı; en
kritiği **gauge yasağı** (§5.1) — `LinearProgressIndicator` yerine soyut
`ProgressIndicator` koyunca ikiz yandı, yani JabLab'ın vakası bende **birebir**
üretilebiliyordu.

**Vakum kapısının tamamlayıcısı, aynısı DEĞİL:**
- vakum kapısı → *"hiç bulamadım"*
- pozitif ikiz → *"aracım bozuk"*

---

## L-256 — İkiz, iddianın KENDİ kodunu çağırmazsa kendi kopyasını kanıtlar

L-255'i uygularken aynı commit'te iki kez düştüm:

**① Ayrı kopya.** `shipped_claim_test`'te MDC desenini ikize **kopyaladım**;
kopya bozuktu (`\$k` Dart'ta düz dolar işareti, interpolasyon değil). İkiz bunu
anında yakaladı — iyi. Ama asıl kusur şu: **ikiz kendi kopyasının çalıştığını
kanıtlıyordu, iddianınkini değil.** Desen bozuk kalıp ikiz doğru olsaydı, hiçbir
şey yanmazdı. Çözüm: desen tek adrese (`_mdcPattern`) alındı; iddia ve ikiz
**aynı fonksiyonu** çağırıyor. (`paintersIn` bu yüzden zaten paylaşımlıydı.)

**② Eklenmemiş ikiz.** `contrast_test`'in ikizini eklediğimi sanıp sabotaj
koştum; sabotaj "geçti". Gerçek: ikiz **hiç eklenmemişti** — düzenlemenin
anchor'ı tutmamıştı ve sessizce hiçbir şey yazılmamıştı. *Sabotajın geçmesi,
kapının var olduğunu kanıtlamaz; önce kapının VARLIĞINI ölç.*

**Kural:** bir düzenleme aracı "başarılı" dönmedikçe değişikliği YAPILMIŞ sayma;
ve ikiz ile iddia **tek kaynaktan** beslenmek zorunda.

---

## L-257 — Kapılarım kelime tarıyordu; DİLE bakan yoktu

Koordinatör JabLab'ın **tekrar eden replik** kusurunu sordu. Ölçtüm ve **hüküm
buraya olduğu gibi geçmiyor** — bunu söylemek, uygulamaktan daha doğruydu:

| Ölçüm | Sonuç |
|---|---|
| `LiveEvaluator` durum metni yayılımı | **kare başına** (`continue` `await for` içinde) |
| Varyant sayısı | **1** |
| `lib/` içinde `LiveEvaluator` atfı | **0** → kullanıcıya ulaşan tekrar **SIFIR** |

**Ve sınıf farkı:** JabLab'daki replikler *söz edimi* — her ateşleme ayrı bir
söyleyiş, altı kez = altı rahatsızlık. Buradakiler *durum etiketi* — süren bir
durum TEK etiket olarak görünür; kare başına tekrar yüzeyde görünmez.
*"Varyant sayısı ateşlenme sıklığıyla ölçeklensin"* kuralını buraya kopyalamak,
**ürün doğru davranırken kırmızıya dönen fazla-geniş bir kapı** olurdu.

### Ama ölçüm asıl kusuru buldu — ve o dil katmanındaydı

Motorun **5 kullanıcı-yüzü metni Türkçeydi**; kabuğun sevk edilen kopyası
**%100 İngilizce**. Kapılarım kelime tarıyordu (wellness yasakları, vaat
yasağı) ama **hiçbiri DİLE bakmıyordu.** *Katman sorusu, kelime sorusundan
önce gelir.*

### ⚠️ Ölçümüm önce DARDI

Yalnız `live_evaluator.dart`'a baktım, **2** buldum. Katmanın tamamı
(`packages/lissom_engine/lib`) **37** Türkçe metin taşıyordu: **32'si
`throw`/assert** (geliştirici-yüzü — **doğru ve kalmalı**), **5'i**
kullanıcı-yüzü. ***Bir dosya, bir katman değildir.***

Aynı turda ikinci dar-ölçüm: `flutter analyze` + app süiti yeşilken **motor
süiti derlenmiyordu**. *"App yeşil" ≠ "paket yeşil"* — app süiti motorun kendi
testlerini derlemiyor.

### Eşik icat DEĞİL — referansa bağlı

*"Kullanıcı metni İngilizce olmalı"* demedim; bu benim icadım olurdu. Kural
**kabuğun kendi sevk ettiği dile** bağlı. Ürün Türkçeye geçerse kural
kendiliğinden döner — kapı geleceğin doğru hâlini yasaklamıyor (L-248).

**Referansa bağlı kuralın açığı REFERANSI DÜŞÜRMEKTİR:** kabuğun kullanıcı
metinleri silinirse hüküm vakum-doğru olurdu → ayrı bir dal referansın
kendisini ölçüyor. (Ters ikizin beşinci yönü; `stale_exemptions`'ın kardeşi.)

**Yan kazanç:** `JointsOutOfFrame.userText` artık `missingGroup`'tan
**türetiliyor**. İki alan aynı olguyu ayrı taşıyordu ve elle yazılan cümle
grubu **hiç anmıyordu** — yani M-F-186'nın "isimli gerekçe" hükmünü de
karşılamıyordu.

---

## L-258 — Kural korunuyordu; korunan şey BİR EKRANDAKİ HÂLİYDİ

Koordinatörün sert-kural süpürmesi ve **tahmini doğru çıktı**: ailenin en sert
**görsel** yasağı (`⛔ gauge/dolum göstergesi`) **beş yüzeyin yalnız birinde**
kapılıydı. Home · Library · FamilyPage · Profile **kapsam dışıydı**.

> *Yasak metinde değil ÇİZİMDE yaşıyor. `wellness_lint` metin tarıyor; çizimi
> kimse taramıyordu.*

**Kapsam elle liste değil, kabuğun kendi rotası:** kapı `LissomShell`i sürüyor
ve sekmeleri config'in `tabs` listesinden geziyor → altıncı sekme kendiliğinden
kapsama girer. FamilyPage ayrıca navigasyonla geziliyor: *sekme olmaması,
kullanıcının oraya gitmediği anlamına gelmiyor* — ve ölçüm sonuçlarının
yaşadığı yer tam orası.

**`paintersIn` tam kabukta FAZLA GENİŞTİ:** Flutter'ın `Material`'i her kart
için `_ShapeBorderPainter` üretiyor; onları yasaklamak **ürün doğru davranırken
kırmızıya dönerdi**. Ayrım türetildi (çerçeve painter'ları `_` ile başlar,
sevk edilen uygulama painter'ı public) — elle liste değil.

**🪤 Sabotaj iki kez koşuldu; birincisi YANLIŞ GEREKÇEYLE kırmızıydı.**
Enjeksiyonum `const const` üretmiş, derleme hatası vermişti — kapı hiç
çalışmadı ve neredeyse *"kapsam doğrulandı"* diye kaydediyordum.
***Kırmızının varlığı, doğru kırmızının varlığı değildir.***

---

## L-259 — Kapının kendisi, koordinatörün öngördüğü zararı ÜRETTİ

Sert kural süpürmesi: **10 ⛔ kalemi**, 8'i kapılı, **2'si kapısız** (mood
takibi · ayrı yol-haritası sayfası). Taksonomi tabloya yazıldı — **① meşru hâli
var · ② ölçütünü geçemiyor · ③ referansı yok**; üçü tek kutuya konursa
*hangisinin bir gün bağlanabileceği kaybolur*.

**⚠️ Bir kapı VAR ama ÖZNESİ UYUYOR:** *"bandın altındaki değere bant etiketi
verilmez"* kuralı `battery_summary_view_test`te — ama o widget kabuktan
**erişilemiyor** (L-225). Kapıyı erişilebilir ekranlara **kopyalamak yanlış**
olurdu: onlar bant etiketi hiç basmıyor, kopya **vakum-doğru** olurdu.
*Özne uyandığı gün kapı zaten yerinde.*

**③'ü isimlendirdim:** *"geri sayım estetiği yok"* bir **algı** hükmü;
`copy_gate` rakam-geri-sayımını yakalar, **estetiği** yakalayamaz. Kapısız
bırakıyorum **ve ③ diyorum** — ② sanılırsa bir gün bağlanabileceği düşünülür.

### ⭐ Ve kapı, uyarılan zararı birebir üretti

İlk mood desenim `feeling`i düz yasakladı ve **sevk edilmiş ağrı güvenlik
notunu öldürdü**: *"We're sorry you're feeling discomfort… please speak to a
doctor."* Koordinatörün ters-ikiz uyarısının tam hâli.

**Yasak kelime değil EDİM:** ruh hâlini *sormak/kaydetmek*. Hissedilene bir
cümlede değinmek — özellikle güvenlik notunda — meşru. Ters negatif ikiz o
cümleyi çiviliyor.

Sonra **daraltma öbür yöne kaçtı** (düz bir mood sorusu artık yakalanmıyordu)
ve bunu **pozitif ikiz** yakaladı. *İki ikiz, kapının iki yakasını tutuyor:
biri fazla genişlemesini, öteki fazla daralmasını.*

---

## L-260 — "Testler yeşil" bu depoda EKSİK bir cümle

JabLab J-145: koordinatöre **kırk kez** *"N/N yeşil"* yazılmış; **o app
süitiydi ve motor süiti J-104'ten beri kırmızıydı.** Üç gerçek kusur oradaydı.

> ***Bir kapının yeşili, o kapının KAPSADIĞI kadar geçerlidir.***

### Bu gecenin dürüst muhasebesi

| Koşum | Ölçüm | Bu gece koştu mu? |
|---|---|---|
| app Dart | **122/122** | her turda — bildirdiğim sayılar **buydu** |
| `lissom_engine` Dart | **95/95** | L-257'de (`71ecc2b`) **ve şimdi** |
| `tools/` python | **13/14** | `wellness_lint` sürekli; **tam 23'lük tarama İLK KEZ** |

`56c8a57`'de `metric_bridge.dart`'a dokunmuştum ve **o an motor süitini
koştuğuma dair kaydım yok** — bugün yeşil, yani geriye dönük kapsandı, ama
*"koştu"* diyemem. Cümlem eksikti.

**Tek gerçek kırmızı:** `fixture_check.py` — paylaşımlı rig
(`motion-core/lib/tools/fixture_pipeline`) kanonik `anatomical_mode()`
taşımıyor (M-F-280). **L-187 göçünü bloke eden ağacın AYNISI** — iki blokaj tek
kök.

### Yapısal fix: `tools/all_gates.py`

Üç koşum tek komutta, **tek birleşik hüküm**. Süitler `packages/*/pubspec.yaml`
taramasından **türetiliyor** — elle liste yazsaydım, JabLab'ın en ince
tespitini (*kusuru kapıya bağlarken kusuru üreten TANIMI da mühürlemek*) betiğin
kendisinde üretmiş olurdum.

Sabotaj: motor kırıldı, app yeşil bırakıldı → **«EKSİK VEYA KIRMIZI»**.

### 🪤 İki ölçüm-DÜZENEĞİ kusuru, aynı turda

1. İlk taramam **23 kapının hepsini `rc=127` kırmızı** gösterdi. Sebep:
   macOS'ta `timeout` binary'si yok. *Ürün değil düzenek* — az kalsın
   "23 kapı kırmızı" diye bildiriyordum.
2. İlk sabotajım **etkisizdi** ve "yeşil" verdi. Kesin bir kırmızı üretene
   kadar **hiçbir şey kanıtlanmamıştı** (L-258'in `const const` kusurunun
   kardeşi).

***Ölçüm aracının kırmızısı, ölçülen şeyin kırmızısı değildir.***

---

## L-261 — Test, kusuru değil BUGÜNÜ koruyabilir

JabLab J-144: *kapı dar tanımı kodluyordu; **test çelişkinin kendisini**
kodluyordu — ikisi de yeşildi.* Koordinatörün öngördüğü iki riski taradım;
**biri gerçekti ve tam öngördüğü yerdeydi.**

### 🔴 ① Bayrak çivisi — L-187 göçünü kırmızıya çevirecekti

`packages/lissom_engine/test/metric_coverage_test.dart` →
`expect(kBridgeIsReferenceEquivalent, isFalse)`. **Kendi yorumu bile**
*"kapanmışsa bu testi ölçüm raporuyla birlikte güncelle"* diyordu.

Yani: **göç BAŞARILI olduğu gün bu test kırmızı yanacaktı**, ve yanan şey bir
kusur değil **bugünün korunması** olacaktı. O anda "kapıyı gevşet" doğru refleks
gibi görünür — oysa kapı zaten yanlış şeyi ölçüyordu.

⚠️ Ve **motor süitindeydi** — yani tutarlı koşmadığım tarafta (L-260).

**M-F-317 uygulandı — değeri değil KURALI ölç:**

> referans-eşdeğeri **⟺** köprü referans uzayında (`world`) ölçüyor

Türetilmiş hüküm: göç `kBridgeSpace`i `world`e taşırsa bayrak **meşru olarak**
`true` olabilir ve test **elle güncellenmeden** yeşil kalır. İki yön de
sabotajla kanıtlandı — ① bayrak `true` + uzay `isotropic` → *"EŞİK İCADIDIR"*
② uzay `world` + bayrak `false` → *"ihtiyattan bastırmak dürüstlük değil
GÜRÜLTÜDÜR"*.

### ② Örneğe çivili kural

`library_screen_test` çocuksuz aileyi **adıyla** (`breath_meditation`)
çivilemişti. O aile çocuk kazanırsa test **yanlış gerekçeyle** kırılır ve asıl
kural (*"0 named" uydurma*) sessizce sınanmaz olur. Kural artık **hâle** bağlı
— çocuksuz OLAN her aile — **ve** bir vakum kapısı taşıyor: sınayacak örnek
kalmazsa kırmızı, sessizce geçmez.

### ③ Gerekçesiz "beni uyandır" çivisi

`JointCoverage.values.length == 2` **meşru** bir çiviydi (yüzey iki hâle
dallanıyor) ama **gerekçesizdi** — kırmızı yandığı gün doğru refleks *sayıyı
büyütmek* gibi görünür. Gerekçe yazıldı: üçüncü hâl **kendi eylemini**
isteyebilir; sessizce ikisinden birine düşerse kullanıcı yanlış şeyi dener.

### Temiz çıkan

**Köprü sayısı** çivili değil: `greaterThan(10)` biçiminde, yani M-F-317 orada
zaten karşılanmıştı. Göç 4 metrik açtığında hiçbir sayı testi kırılmaz.

---

## L-262 — «Bunu kim görüyor?» sorusu, «bu doğru mu?»yu da cevapladı

J-147 yöntemi: **doğruluk denetimi pahalı, izleyici denetimi ucuz — ve ikincisi
çoğu zaman birincisini de yapıyor.** Denedim; yaptı.

### Bulunan: bir SINIR anlatılırken araya sıkışmış bir YETENEK

*"What Lissom doesn't do"* kalem 2:

> *"Our breath sessions are **voice-guided** with the camera off"*

Ölçüm: `pubspec`te ses paketi **yok**, `lib/` ve motorda konuşma çağrısı
**yok**, `breath_meditation` **`notBuilt` ve sıfır çocuklu**. Cümle **olmayan
bir yeteneği şimdiki zamanda** anlatıyordu. (`speaksAsCoaching` ad benzerliği —
dil üslubu bayrağı, ses değil.)

Bu **M-F-287'nin ters yönü**: yeteneği olduğundan **geniş** yazmak. Ve daha
tehlikeli — *eksik yazmak kullanıcıyı korur, fazla yazmak **aldatır**.*

### ⭐ Kapı, okumayla bulamadığım ikincisini buldu

Aynı ailenin **`intro`** satırı da *"Voice-guided only"* diyordu — kullanıcının
Library'de **gördüğü** yerde. ***Okuyarak örnek bulunur, kapıyla SINIF
bulunur.***

### Kural referansa bağlı

*"'voice' kelimesi yasak"* demedim — o icat olurdu ve ses eklendiği gün doğru
cümleyi öldürürdü. Kural: **bir yetenek iddiası, o yeteneğin KOD YOLU varsa
meşrudur.** Ters ikiz darlığı koruyor (*"Lissom keeps a plain voice"* geçiyor).
**Kapının ölçmediği, isimle:** yalnız ses sınıfı; *"kişiselleştirilmiş plan"*,
*"hatırlatma"* gibi iddialar dışarıda — onlar ayrı bir yokluk ölçümü ister.

### Denetimin TEMİZ çıkanları (üçü de ölçüldü)

- **Anatomi doğru:** `ankle_dorsiflexion → tibia_inclination → "Shin angle"`.
  Eski *"gövde"* kusuru geri gelmemiş — ve gelemez, çünkü özne metrik
  haritasından **türetiliyor**.
- **11 engelli metriğin 7'si genelleme değil:** her biri somut `measureKind`
  adlandırıyor (`height_diff_norm` vb.) ve config'e karşı doğrulanıyor.
- **whyNot kalem 1'in dayanağı gerçek:** `ageBands ['u40','40-59','60plus']` —
  en genç bant gerçekten tek bir *"under 40"*.

### 🪤 Yan ders: commit mesajı bir KANAL, ve sessizce veri kaybediyor

`f6ec7b6`'nın gövdesinde backtick'ler kabuk tarafından **komut olarak
yorumlandı** ve iki ad silindi. Amend denedim; `pre-push` kancası geçmiş
yeniden yazmayı engelledi — **kanca haklıydı, atlatmadım**, düzeltmeyi ek
commit olarak yolladım. Bundan sonra çok satırlı mesajlar **dosyadan** (`-F`).

---

## L-263 — Kapının kendisi, aynı gecede DÜZELTTİĞİ kusuru ÜÇ kez üretti

Madde ⑱ (uydurma `±5° typical error`) kapatılmıştı; şimdi **geri gelmesi**
kapıya bağlandı. J-133: *sevk edilmiş cümleyi yanlışa çevirecek en makul
değişiklik* — **birinin bir gün oraya bir sayı yazması.**

**İki kapı, iki ayrı şey:** ① beyan kabuktan **görülebiliyor mu** ② doğruluk
ölçümü yokken **marj rakamı belirmiyor mu**. Eşik icat değil: rakam,
`docs/ACCURACY-*.md` adıyla beyan edilmiş, **medyan + p95 + kabul ölçütü**
taşıyan bir çalışma varsa meşru (L-254 ile aynı biçim). Ters yön de tutuluyor:
çalışma gelince *"ölçmedik"* cümlesi **yalan** olur.

**Kapının ölçmediği, isimle:** beyanın **hangi ekranda** duracağı. Bugünkü
yerleşim bir tasarım kararı (*caveat enflasyonu*: sınır sayfası kendini tekrar
etmez) ve onu çivilemek **L-261'in kusuru** olurdu.

### 🪤 Ve kapı kendi kusurunu ÜÇ kez üretti — üçü de bu gecenin sınıfı

1. **Artefakt bulucusu kelime birlikteliği arıyordu** (`reference instrument`
   + medyan + p95) ve **kendi rapor belgeme** takıldı — o belge çalışmanın
   **yokluğunu** anlatıyor. Kapı *"çalışma var, beyanı güncelle"* diyordu:
   yani az önce düzelttiğim **uydurma-yetenek** kusurunu **ters yönden**
   üretti. *Bir belgeden bahsetmek, o belgenin varlığı değildir.*
2. **Tüm config tarandı** ve `_notes` içindeki mühendislik kayıtları yakalandı
   — `±5,7° sistematik hata` geliştiriciye yazılmış bir **ölçüm**, `±30° yaw`
   ise marj değil bir **koşul**. L-257'nin katman ayrımı: *aynı kelime, farklı
   katmanda farklı şey.* Yasak **kullanıcıya marj vaat etmek**, mühendislik
   defterini susturmak değil.
3. **Bulucu `docs/.DS_Store`'da UTF-8 çözerken patlıyordu** — kapı, taradığı
   dizinin çöpüne takılıp **ölçüm yapamaz** hâle geliyordu.

**Sabotaj:** gecenin özgün ihlali (`±5° typical error`) geri konuldu → kapı
kırmızı ve gerekçe **madde ⑱'i adıyla** anıyor.

---

## L-264 — Kapsamın ÜÇÜNCÜ ekseni: yüzey

J-151: *bir kusuru bulduğun yüzeyde düzeltmek, onu ürünün geri kalanında
düzeltmek değildir.* Bu gece kapsam kusuru **üç eksende** çıktı — **dizin**
(L-260 · `packages/` taranıyor mu) · **katman** (L-257 · kullanıcı-yüzü mü
geliştirici-yüzü mü) · ve şimdi **yüzey**.

### Koordinatörün hipotezi tersine çıktı, kusur yine de gerçekti

Hipotez: *"Library ve Progress kontrast düzeltmelerinden SONRA inşa edildiyse
kusuru taşıyor olabilir."* Ölçüm: dört sekme de `4de4322` (02:19) ile **aynı
anda** doğdu, düzeltmelerden (04:34, 08:06) **önce**. Yani sorun *"yeni sekme
eski düzeltmeyi kaçırdı"* değil — **kapı, o gün baktığım iki yüzeyi
geziyordu**:

| Kapı | Gezdiği |
|---|---|
| `rendered_contrast_test` (L-247) | FamilyPage · WhatLissomDoesntDo |
| home · library · progress · profile | **kapsam DIŞI** |

L-258'in (gauge yasağı 5 yüzeyin 1'inde) birebir kardeşi.

### Tur açılır açılmaz gerçek bir kusur buldu

Home'un **birincil eylem çağrısı** — *"See what each test measures"* — beyaz
metin, `roseDeep` dolgu → **3,66:1**. 13,5px normal ağırlık için WCAG AA eşiği
**4,5**. Ürünün en önemli butonu **ölçülebilir biçimde okunmuyordu.**

**En dar yol seçildi:** `roseDeep`i koyulaştırmak marka/seed rengini
değiştirirdi; `roseDeepHover` kullanmak hover ile durgun hâli aynılaştırırdı;
seçilen → **`fillForWhiteText` #9C677F**, yalnız dolgu, ton korunur (×0,89).
*Adı rengini değil sözleşmesini söylüyor.*

**Ve sınıf kapılandı, örnek değil** — yeni kova `_whiteTextFills`: beyaz metin
taşıyan **her** dolgu 4,5'i geçmek zorunda. `_fillTokens`a koymak **yanlış**
olurdu; o kova *"metin eşiğine tabi değil"* diyor. ***Yanlış kova, sessiz bir
muafiyettir.***

### 🪤 Kapı kendi kusurunu iki kez üretti

1. Yüklem **her** metni sayfa arka planına göre ölçüyordu → beyaz buton
   etiketini **pembe sayfaya** karşı ölçtü, **1,30:1** dedi. *Yanlış çift,
   yanlış sonuç.* **Muafiyet yazmadım** — muafiyet, arkasına gerçek bir kusurun
   saklanabileceği bir deliktir; zemin **temadan türetiliyor**.
2. Sonra zemini `LissomColors.roseDeep` diye **sabitledim** ve tema
   düzeltilince kapı **eski rengi** ölçmeye devam etti — *düzeltmeyi görmedi*.
   Tek-adres ilkesi kendi kapıma çarptı.

**Ve mevcut bir kapı yeni token'ı yakaladı:** *"KOVASIZ token — kontrast kapısı
onu hiç ölçmez"*. Kapılar birbirini tutuyor.

---

## L-265 — JabLab'ın hatasının AYNADAKİ hâli (ve benimki kendi lehime)

J-153: *"Neden yok?"* sayfasının girişi tek bir sebep ilan ediyordu (*"a single
phone camera genuinely cannot see"*) ama 12 kalemin yalnız 2'si o sınıftandı.

> ***Teknik kısıt örtük bir VAAT taşır ("daha iyi teknoloji çözer"); kasıtlı
> karar taşımaz.***

**Bende tam tersi yönde:**

| | JabLab | Ben |
|---|---|---|
| Çerçeve | *"kamera göremiyor"* | *"every line below is a **decision**"* |
| Hata yönü | kararı teknik kısıt gibi | **teknik kısıtı karar gibi** |
| Kimin lehine | ürünün aleyhine (vaat borcu) | **kendi lehime** |

Yapamadığımı **ilke** gibi göstermek, üründe olmayan bir duruş iddia etmektir
— **L-262'nin (olmayan yeteneği vaat etmek) kardeşi.**

### Ölçüm — beş kalem, ÜÇ sınıf

| Kalem | Sınıf |
|---|---|
| Programmes for children | `judgement` — mükemmel veriyle de değişmez |
| Breath measurement | `capability` — kamera göremiyor, **değişebilir** |
| Clinical screens | `judgement` — veri değil **YETKİ** |
| Hot yoga | `measurement` — ödünç esnekliği ayıramıyoruz |
| Hip rotation | `capability` — tek lens geometrisi |

**İki çerçeve cümlesi de yanlıştı**, ve kod tarafı daha keskindi
(*"every line below is a decision"* — kategorik).

### Düzeltme YAPISAL, çünkü kusur cümle düzeyinde görünmüyordu

***Hiçbir cümle yalan söylemeden sayfa yanlış okunuyordu.*** O yüzden:
`LimitKind` her satırda **zorunlu** · okuyucu sınıfsız satırı **adıyla
reddediyor** · her kart sınıfını **yüzeyde** söylüyor · `judgement` satırı
açıkça *"We would keep it even with perfect measurement"* diyor.

### Kapı MEKANİK, semantik değil

Sınıflandırmanın **doğru** olduğunu ölçmüyor — ölçütü yok, **kör nokta olarak
kaydedildi** (koordinatör hükmü). Ölçtüğü: tek sebep ilan edilmiyor ·
sınıf beyan ediliyor · yüzeyde görünüyor · sınıflar **gerçekten ayrışıyor**
(hepsi aynıysa etiket süstür).

### 🪤 Kapı yine FAZLA GENİŞ doğdu

Makine-adı sızıntısını `textContaining` ile ölçünce **meşru İngilizceyi**
yakaladı: *"The reason is the **measurement**, not the effort."*
`capability`/`measurement`/`judgement` sıradan kelimeler; sızıntı olan
onların **etiket konumunda** görünmesi. ***Kapı bir kelimeyi değil bir KONUMU
ölçmeli.***

## 🕳️ KÖR NOKTA (kapılanamaz — kayıt)

Bir sınırın **hangi sınıftan olduğu** semantik bir yargıdır ve ölçütü yok.
Kapı sınıfın **beyan edildiğini** ve **ayrıştığını** tutar; **doğru
atandığını** tutamaz. Yanlış atanmış bir sınıf — özellikle `capability`
yerine `judgement` — sessizce kalır ve **tam olarak bu gecenin kusurunu**
küçük ölçekte tekrar eder.

---

## L-266 — Aynı kart, iki özne: başlık sistemin, gövde kullanıcının

J-154. Zincir tamamlandı: *sözcük* → *cümle* → *çerçeve* → **ÖZNE**.
Ortak kök: ***doğruluk, okunduğu yerden ölçülür.***

**Ailenin en hassas kartında bulundu** (`retest_countdown`, brief'in hükmü:
*bu bir DAVET, geri sayım değil*):

| | Metin | Özne |
|---|---|---|
| **Gövde** | *"Lissom does not set a date… we are not going to schedule you."* | ✅ kullanıcı |
| **Başlık** | *"Next re-assessment"* | 🔴 **sistem** — bir sonraki VAR ve PLANLI |

Başlık **sistemin yuvasını** (ana ekranda bir bölüm var), gövde
**kullanıcının gerçeğini** anlatıyordu. ***İkisi de tek başına yalan değil;
birlikte yanlış okunuyorlardı.*** Ve kullanıcı **önce başlığı okur.**

→ *"Next re-assessment"* → **"Measuring again"**

**Kapı:** ana ekran başlıklarında takvim/vade dili yasak. **Ters ikiz kartın
kendi dürüst gövdesini çiviliyor** — *"we are not going to schedule you"*
geçmek **zorunda**; bir kapı onu öldürüyorsa **kapı yanlıştır**.

## 🕳️ KÖR NOKTA — jargon vekili TÜRETİLEMEDİ

İlk kapım *"görünen ad, id'nin baş-harfli hâli olamaz"* diyordu ve
**`deep_squat → "Deep Squat"`i sızıntı saydı**. Ölçtüğüm yanlıştı:
***id-eşitliği jargon demek değil.***

Sonra jargon sözlüğünü config'in **kendi iki sözlüğünden** türetmeyi denedim
(metrik id'lerinde geçip insan metinlerinde geçmeyen sözcükler).
***Türetme kendini yiyor:*** insan sözlüğünü adlardan hesaplarsam, eklenen her
ad **kendi sözcüklerini meşrulaştırır** ve kapı hiçbir şey yakalayamaz.

*"Bu ad vücut dilinde mi motorun dilinde mi?"* semantik bir yargı, ölçütü yok
— **L-265'in kör noktasıyla aynı sınıf.** Kapı kurmadım.

**Kesin olan dar parça kapılandı:** ham makine id'si (alt çizgili) hiçbir
kullanıcı metninde geçemez — *`squat` tartışılır, `deep_squat` tartışılmaz.*

**Bugünkü ölçüm (olgu, garanti DEĞİL):** 12 testin 12'si vücut dilinde
(`ankle_dorsiflexion` → *"Ankle Mobility"*) ve 11 engelli metriğin `subject`'i
de öyle (*"Shin angle"*). Koordinatörün andığı eski *"gövde ↔ kaval kemiği"*
kusuru **geri gelmemiş** — ve gelemez, çünkü özne metrik haritasından
türetiliyor.

---

## L-267 — Savunmacı varsayılanın yargıya dönüştüğü yer + göçün ikinci sonucu

O-070: `sampleCount == 0 ? 1 : …` → *"Steady."* **Sıfır ölçümle olumlu hüküm.**
Sinsi olan: `? 1 :` **matematiksel olarak masum** bir bölme-sıfır koruması —
***kod düzeyinde doğru, ürün düzeyinde yalan.***

**Tarama: 4 savunmacı varsayılan, hiçbiri olumlu yargıya bağlanmıyor.** Motor
ayrımı isimle koruyor: `_attemptMicros` girişim yoksa **`null`, `0` DEĞİL**
(*"çalışma yapılmadı" ≠ "sıfır saniye çalışıldı"*) · `elapsed` varsayılanı
**ihtiyatlı** yöne düşüyor · bandın altına etiket yok · `history`'nin `?? 0`'ı
ayrımı **`unmeasuredUnits`** alanında koruyor. **Bugün temiz; kapı yarını
tutuyor.**

### 🪤 İlk sabotajım GEÇTİ — yani hiçbir şey kanıtlamamıştı

`bandLabel: value < floor ? null : label` korumasını kaldırdım, **test yeşil
kaldı.** Sebep: etiketi engelleyen şey **o koruma değil**, eşleşme döngüsünün
kendisi (`value >= e.value` hiç eşleşmiyor). **Mekanizmayı yanlış
atfetmiştim** — *doğru sonuç, yanlış gerekçe*, koordinatörün kendi uyarısı.
Doğru sabotaj (döngü) kapıyı kırmızı yaktı; kapıya `tier` iddiası da eklendi.

### ⭐ «Bu yapısal eksik BAŞKA neyi kırıyor?»

`motion_core`'un açı çıkarıcısı `planar` anahtarı taşıyor, **varsayılanı
`true`**, ve Lissom onu **ezmiyor**:

| Sonuç | |
|---|---|
| ① | Lissom açıları **tamamen 2D**, `z`'ye hiç dokunmuyor → sevk edilen 8 köprülü metrik sözde-derinlikten **etkilenmiyor**; gizli çarpıtma **YOK** |
| ② | Göç **üçüncü boyut** kazandı: `planar` da `false` olmalı, yoksa dünya koordinatları gelir ve **kullanılmaz**. Ve `planar` **paylaşımlı varsayılan** → beş hattın açı semantiği |
| ③ | Kapsam **3 değil ALTI** dosya |
| ④ | **L-031'in sayısı açıklandı:** Dart 2D görüntü-düzlemi, Python 3D dünya ölçüyor. Medyan **11,29° bir HATA değil**, iki farklı ölçünün farkı |

---

## L-268 — SINIF kusuru: kutu yüzeyde tutarlıydı, gerekçesi uymuyordu

J-163: ***araç kusuru yanlış ÖLÇÜM verir; sınıf kusuru yanlış İŞ verir.***
Çözüm: sınıflandırmanın da **doğru-pozitifi** olmalı — *"bu kutuya koyduğum
başka ne var, ve onlarla gerçekten aynı mı?"*

**Sordum, cevap HAYIRDI.**

`corePlaneSeparationMissing` kutusunda **4 metrik** vardı ve dördü de
`measureKind: 'angle_vertical'` — kutu **yüzeyde tutarlı** görünüyordu. Ama
kutunun **gerekçesi gövdeye özgü**: *"çekirdekte tek ve işaretli bir
`trunk_tilt` var, config iki ayrı düzlem metriği istiyor."*

***Kaval kemiği açısı `trunk_tilt`ten türemiyor.*** O gerekçe ona hiç
uymuyordu.

### Gerçek engel ölçüldü

Çekirdeğin `AngleKind`'ı üç tür taşıyor: `flexion` (eklem içi) · `orientation`
(**gövde eksenine** göre yön) · `trunkTilt` (yalnız gövde). Bir uzvun
**yerçekimi dikeyine** göre açısı **hiçbirinde yok.**

→ yeni sınıf **`coreLacksVerticalReference`** (`tibia_inclination_left/right`)

**Ve bu yanlış İŞ veriyordu:** *"düzlem ayrımı ekle"* ile *"uzuv-dikey ölçüsü
ekle"* **farklı işlerdir**, ve ilki kaval kemiğini **hiç açmazdı**. L-187
kapsamı da bu satırla yeniden okunmalı.

### ⭐ Kendi kapım yakaladı

**L-253'ün kuralı** (*her engel sınıfı dürüstlük kutusunda adlandırılır*) yeni
sınıf doğar doğmaz **kırmızı yandı** — özet onu sessizce atlayacaktı. Bir
gecelik kapı, bir gecelik kusuru aynı gün tuttu.

### Diğer kutu DOĞRU çıktı

7 metriğin `coreLacksMeasureKind` sınıfı **ölçüldü**: çekirdeğin geometry
katmanında mesafe/yükseklik üreten **hiçbir çıkarıcı yok**. Genelleme değil.

### 🪞 Ve bedelini bu gece bizzat ödedim

*"M-F-22 yasaklıyor"* dediğim şey **kural değil ölçüm eksikliğiydi** ve L-187'yi
**dört tur** bloke etti. ***Aynı hata, iki farklı katmanda*** — biri kural
yorumunda, biri metrik sınıflandırmasında.

---

## L-269 — «İmkânsız» kutusu bir taahhüttür; 4 kalemin 1'i orada olmamalıydı

J-165: ***`imkânsız` kutusu bir çöp kutusu değil, bir TAAHHÜT: "bunu hiç
kovalamayacağız."*** O taahhüdü **ölçmeden** vermek, bir işi **sessizce
gömmek** oluyor. İkinci ders: ***ölçütü DAR tutmak kapıyı KURULABİLİR kılıyor
— bazı şeyler imkânsız değil, sadece fazla geniş tanımlanmış.***

### Koordinatörün dört adayı: dördü de zaten kapıda

| Aday | Gerçek |
|---|---|
| gauge/dolum yok | `visual_ban_test`, **5/5 yüzey** (L-258) |
| tıbbi dil yok | `wellness_lint` (+ olumsuzlama ayrımı) |
| ölçüm-sınırı beyanı | `measurement_limit_test` (L-263); sınıfı **ölçülmemiş**, imkânsız değil |
| 11 engelli metrik | L-268'de yeniden ölçüldü → **2/11 yanlış kutudaydı (%18)** |

**Hiçbiri kutumda değil.**

### Gerçek kutum — ve biri geçmedi

**K1** LimitKind doğruluğu · **K2** jargon vekili · **K3** *"geri sayım
estetiği"* · **K4** beyan-ölçüm uzay eşitliği.

**K1 sınandı ve düştü.** Ölçütü *"sınıflandırma semantik olarak doğru mu?"*
diye yazmıştım — **o gerçekten ölçülemez.** Ama dar dilim ölçülebilir:

```
capability  ⟹ gerekçe bir DONANIM kısıtı anar (camera/lens/sensor)
judgement   ⟹ donanıma DAYANMAZ, bir YETKİ/karar sebebi anar
measurement ⟹ donanım anmaz (anarsa zaten capability'dir)
```

Beş kalemin beşi de bu dilimden geçiyor. **Sabotaj:** nefes ölçümü
`judgement` yapıldı (*yapamamayı ilke göstermek*) → kapı kırmızı, gerekçe
**L-265'i adıyla** anıyor.

⛔ **Kutu küçüldü, boşalmadı:** sınıfın *doğru* olduğu hâlâ ölçülmüyor.
K2/K3/K4 kutuda kaldı, gerekçeleri yazılı.

### 🪞 Bu dersin kanıtı bendeydi

*"M-F-22 yasaklıyor"* dedim, **kural sandım**, ölçünce **ölçüm eksikliği**
çıktı — **dört tur bloke etti.** ***"İmkânsız sanılan şey aslında on dakikalık
iş"*** vakasının tam kendisi.

---

## L-270 — Gezilebilir ekran: **6** (02:00 ölçümü **2** diyordu)

Kurucu sabah **inşa turu sırasına** karar verecek; elindeki sayı 02:00'de
ölçülmüş ve arada **200+ commit** geçti. ***Bayat öncülle verilen sıra kararı
yanlış çıkar*** — bu gecenin dört-tur blokajıyla aynı sınıf.

| Ekran | Yol |
|---|---|
| HomeScreen | sekme «home» |
| LibraryScreen | sekme «library» |
| ProgressScreen | sekme «progress» |
| ProfileScreen | sekme «profile» |
| FamilyPage | Library'de **aile kartına dokunuş** |
| WhatLissomDoesntDoScreen | Profile'da **giriş kartına dokunuş** |

**Var ama ulaşılamıyor: 0** (tur kapsamında).
**Sayım dışı:** `BatterySummaryView` — kabuğa **hiç bağlanmamış** (L-225, açık
karar koordinatörde).

### 🪤 Ölçüm aracım İKİ KEZ yanlış saydı

1. **Statik sınıf-atıf taraması** `FamilyPage`'i *"erişilemez"* gösterdi —
   sınıf **kendi tanım dosyasında** kullanılıyordu ve filtrem o dosyayı
   dışlıyordu.
2. **İlk tur yalnız `FilledButton`/`TextButton`a basıyordu** ve
   `WhatLissomDoesntDoScreen`i *"ulaşılamıyor"* saydı — oysa Profile'daki bir
   **kartın `onTap`**'iyle açılıyor.

Koordinatörün kendi deseninin Ostinato'ya **3** deyip gerçeğin **11**
çıkmasıyla **aynı sınıf**: ***kanonik sayı yalnız kapıdan gelir.***

Ve turlar arasında **boş ağaç** gerekti: aksi hâlde önceki turun ittiği rota
ayakta kalıyor ve **tur kendi geçmişini ölçüyor.**

### ⭐ Tur bir ÇERÇEVE kusuru daha buldu

Profile'daki giriş kartı hâlâ *"The **decisions** behind the edges of the
product"* diyordu — **L-265'te düzelttiğim çerçevenin başka bir yüzeydeki
kopyası.** J-151 birebir: *kusuru bulduğun yüzeyde düzeltmek, ürünün geri
kalanında düzeltmek değildir.*
→ *"What we chose not to do, and what we cannot do."*

**Kalıcı kapı:** sayı **6'nın altına** düşerse kırmızı. Üst sınır **yok** —
kapı büyümeyi yasaklamaz, **küçülmeyi** yakalar. *Sayı bir daha bayatlamaz.*

---

## L-271 — Bir sayı, kuralı yazılmadan karşılaştırılamaz

Koordinatörün düzeltmesi: *"ayrı ekran"* dedi ama **rota mı perde mi**
belirtmedi. **Siparişteki belirsizlik bende tam ortaya düşüyor:**

Lissom'un kabuğu **tek `Scaffold`** içinde `switch`le gövde değiştiriyor ve
`NavigationBar` **hep görünür**. Yani dört sekmem, katı kuralın *"sayılmaz"*
dediği **üç maddenin üçüne birden** uyuyor.

| Okuma | Sayı | İçerik |
|---|---|---|
| **KATI** (yalnız ayrı ROTA) | **2** | FamilyPage · WhatLissomDoesntDoScreen |
| **GENİŞ** (sekme hedefleri + rotalar) | **6** | + Home · Library · Progress · Profile |

Kuralın **amacı** *"navigasyon kabuğu eksik mi"* ve **sekmeler kabuğun
kendisi** — o amaca göre 6. **Tek sayı beyan etmedim**; kapı geniş okumayı
tutuyor, katı okuma raporda ayrıca basılıyor. ***Hangi kural kazanırsa
kazansın ölçüm geçerli kalıyor.***

📌 **Ve 02:00'deki *"Lissom 2"* yanlış değildi, BAYATTI:** dört sekme mimarisi
(`4de4322`) **02:19'da** doğdu — ölçüm ondan **19 dakika önce** alınmıştı.

### ④ Yeni denetim yöntemi koşuldu

*Bir sınıflandırmanın gerekçesini deponun kendi yazılı kuralına karşı sına.*
7 engelin iddiası: *"config bu ölçü türlerini **istiyor**, Dart çekirdeği
**sağlamıyor**."* Config'te bulunan `height_diff_norm` / `distance_norm` /
`line_deviation_norm` satırları **çelişki değil, engelin öncülü**. Ve L-268'de
**doğrudan ölçülmüştü**: çekirdeğin geometry katmanında mesafe çıkarıcısı
**yok** — belge kontrolünden **güçlü** kanıt.

---

## L-272 — Cihazda çöken / testte yeşil kalan sınıf

Choreia'nın tuzağı: testler `File()` ile **diskten**, cihaz `rootBundle` ile
**bundle'dan** okuyor. Ölçtüm: `rootBundle` iki yol okuyor, **ikisi de
beyanlı** → çökme yok. Ama `config/copy/` · `config/content/` ·
`config/harvest/` **beyansız** ve diskte duruyor → biri `rootBundle`'a girdiği
an **cihazda çöker, testler yeşil kalarak.** Kapı kuruldu + sabotaj.

Ayrıca `limitsCopy` config'ten **elle taşınmış** kopya; bugün birebir ama
kapısı yoktu → kapılandı (iki kaynak tek olgu).

## L-273 — İzin metni: kendi kapım fazla genişti, ve **onu savundum**

Koordinatör üç kez istedi, üç kez kapımı gerekçe gösterdim. Sonunda **kapıyı
ölçtüm, savunmayı değil**: L-262'nin zararı *"KULLANICIYA olmayan bir yeteneği
anlatmak"*tı — izin metnini gösteren **diyalog hiç açılmıyor**, yani zarar
**oluşamıyor**. Buna karşılık `motion_camera` **bağlı bağımlılık**, Apple
statik denetimde görüyor.

> ***Kendi kapını savunmak, başkasının kapısını denetlemekten daha zor.***

Linter **OS katmanına** genişletildi (`OS_FILES` + `strings_from_plist` +
`.plist` dalı). 🪤 Dart kapısı önce `contains('strings_from_plist')` diyordu ve
**sabotajı geçti** — fonksiyonu yeniden adlandırdım, **çağrı yeri** hâlâ o adı
taşıyordu. *Kelimenin varlığı, çağrının çalıştığı değildir.* Davranış artık
`lint_selftest.py`de **gerçek linter koşturularak** sınanıyor.

## L-274 — Poz modeli: hazırlama adımı **kamera gelmeden** kanıtlandı

`motion_camera` modeli **kasıtlı taşımıyor** ve `modelPath` **mutlak dosya
yolu** istiyor → `pubspec` yetmez, bundle→dosya sistemi adımı gerekiyor.
Aile deseni kuruldu (`fetch_pose_model.sh` pin+SHA, `latest` yasak · pubspec ·
`materializePoseModel()`). Model **9 398 198 bayt**, SHA birebir.

**Ölü kod değil, çünkü testi onu gerçek dosya sisteminde koşturuyor:** mutlak
yol · **N=2'de yeniden yazmıyor** · **yarım dosya varsa kurtarıyor** (o kusur
ölçüm hattında, hazırlama adımından **uzakta** görünürdü).

## L-275 — Commit kapım **hiç yoktu**

JabLab'ınki vakum-doğruydu (`| tail -1 && git commit` — boru hattının çıkış
kodu son komutunki). **Benimki daha çıplak: hook yoktu.** Kapıları ayrı
komutta koşturup commit ediyordum — *"her seferinde yeşildi"* bir güvence
değil bir **alışkanlıktır**.

🪤 **Pozitif kontrol ilk turda doğru sonucu yanlış sebeple verdi:** hook
`.git/hooks`'tan `cd ../..` yapınca `.git/`'e gitti, betiği bulamadı, commit
durdu. Kontrol olmasa *"kapı çalışıyor"* diye kaydedecektim — **bu gecenin
beşinci aynı deseni.** `git rev-parse --show-toplevel` ile düzeltildi; ikinci
tur zinciri gerçekten durdurdu.

**L-275 EK — kapının SIFIRINCI şartı.** Choreia'da kapı `&&` bile değil **iki
ayrı satırdı**: commit test sonucundan **tamamen bağımsız** koşuyordu.
→ M-F-399'a sıfırıncı şart: ***kapının VAR OLMASI*** (kurulmuş · düşebilir ·
okunur — üçü de varlığı varsayıyordu).

**İki soruyla doğrulandı:** ① yorumlar süzülünce boru sayısı **0**, çalışan tek
komut `all_gates.py`; `false | tail -1` çıkış kodu **0** olarak ölçüldü — boru
neden yasak. *(İlk sayımım yorumdaki boruyu da saydı ve 1 gösterdi: araç
kusuru.)* ② **Sabotajın indiği ölçüldü** — Choreia'nın kazası (dizgi dosyada
yok, düzenleme sessizce hiçbir şey yapmamış, kapı yeşil, *"kapı bozuk"*
yazılacaktı) birebir önlendi: `assert n != s` + `grep -c` + testin gerçekten
kırmızı olduğu → **sonra** commit denendi → **durdu**.

> ***Bir pozitif kontrol, KENDİSİNİN indiği doğrulanmadan kanıt değildir.
> Tersi daha tehlikeli: inmemiş bir sabotaj, ÇALIŞAN bir kapıyı bozuk
> gösterir.***

---

## L-276 — Raporlarımı koordinatörün OKUMADIĞI yere yazdım (iki saat)

Koordinatör beş kez *"kurucu cevabı gelmedi"* dedi; ben beş kez **oturum-içi**
yazdım. Brief'im *"cross-session mesaj göndermiyorsun, raporlarını oturum-içi
yaz"* diyor — ama koordinatör **`git log` ve Obsidian okuyor.**

***Kanalın varlığını ölçmeden varsaydım.***

Bu, gecenin kendi dersinin bana dönmüş hâli: **beyanın varlığı, tetiğinin
varlığı değildir.** Rapor yazıldı (beyan), ama okunacağı yere konmadı (tetik).
Ve teşhis, koordinatörün ısrarını *"ölçümün bayat"* diye açıklamaya
çalışırken çıktı — **ikimiz de doğruyduk, farklı ağaçlara bakıyorduk.**

**Düzeltme:** `docs/KAPANIS-RAPORU-2026-08-07.md` + commit **başlığında** özet
(`6d3b446`) — daha önce `56c8a57`'de aynı yolu bir kez kullanmıştım ve
unutmuşum.

> ***Bir rapor, okunduğu yerde vardır.***

---

## L-277 — `reference_equivalence` kanıt zinciri: regex nesri doğruluyordu, ispatı değil

L-254'ün regex-tabanlı doğrulaması `mutation_reference_equivalence.py`'nin
2. turunda YALANLANDI (500+ karakterlik uydurma nesir kapıyı geçti).
Choreia `rig_version()`+`readers_of()`den aktarılan (felsefe SINANIP kısmen
REDDEDİLEREK — `rig_staleness_warning()`'in "uyar/reddetme"si burada TERS)
bir kanıt zinciri kuruldu: `docs/L-031-ESDEGERLIK-KANITI.json`, yalnız
gerçek bir ölçüm koşumunun yazabildiği, dosya-başına içerik-hash haritalı,
kendi kabul-hükmünü taşıyan (kapı OKUR, yeniden hesaplamaz) bir artefakt.
Üç sahneyle sınandı — asıl delik/bayatlık kırmızı, gerçek koşum yeşil.
Ayrıntı: `docs/CELISKI-KAPISI-ENVANTERI-2026-08-11.md`, commit `015238d`.

🪤 **Kendi numaralandırma hatam:** bu girdiye önce yanlışlıkla "L-262"
dedim — o numara ZATEN «Bunu kim görüyor?» girdisine ait (yukarıda),
tamamen alakasız bir bulgu. Gerçek sonraki numarayı (bu ledger'ı okuyup)
DOĞRULAMADAN, hafızadan bir sayı kullandım — gecenin kendi dersinin
(devralınan bir sayı da bir beyandır, L-228) küçük bir tekrarı. `sed` ile
üç dosyada (`test/reference_equivalence_test.dart`,
`tools/mutation_reference_equivalence.py`,
`docs/CELISKI-KAPISI-ENVANTERI-2026-08-11.md`) L-262→L-277 düzeltildi.

## L-278 — `metric_coverage_test.dart`: üç sahne, üçü de korumasız (ÖLÇÜM, kod değişmedi)

Envanterin şüphesi ("iki kaynak BİRDEN tutarlı sürüklenirse hiç
sınanmamış") `tools/mutation_metric_coverage.py` ile doğrulandı: **(A)**
çalışan bir binding kaldırılıp aynı metrik "engellendi" beyan edilirse
bölme denklemi göremiyor. **(B)** "imkânsız" denen bir metrik YANLIŞ
eklemle köprülü sayılırsa "gerçekten okunabiliyor" testi (`returnsNormally`)
yakalamıyor — bir YAKIN-ISKA ölçüldü: `tibia_inclination_right` ile
denendiğinde `real_replay_test.dart`ın hardcoded bir örneği TESADÜFEN
yakaladı; `reach_depth`e değiştirilince aynı mutasyon sessizce geçti.
**(C)** `measureKind`in "config ile kapıda karşılaştırılıyor" diyen doc
iddiası, kod tabanında karşılığı OLMAYAN bir iddia çıktı. Üçü de kırmızı
yanmadı — commit `239988e`. **Düzeltme kararı koordinatörde**, kod burada
DEĞİŞTİRİLMEDİ.

## L-279 — (A)+(B) `kSealedBridgedJoints` mührü + A3 değişim-dedektörü — kuyruk KAPANDI

L-278'in (A)+(B)'si `pin_equality_test.dart`ın ÇAPA 2 deseniyle kapatıldı:
`kMetricBindings`'ten TÜRETİLMEYEN (tautoloji olurdu) bir `metric→joint`
mührü, `test/`de yaşıyor, canlı eşlemeye karşı exact-equality sınanıyor.
Kapsamı doc'ta DAR yazıldı (yalnız metric→joint; `invert` AÇIK boşluk,
kapatılmadı). Üç sahne (A/B/C) `mutation_metric_coverage.py` ile YENİDEN
koşuldu, üçü de 🔴→✅ — commit `841af7f`.

Sonra A3'ün yapısal deliği (③, M-F-455): `NETWORK_DEP_HINTS` bir
RET-LİSTESİ, listede olmayan paket adı sessizce geçer. Dördüncü kanal
eklendi — `pubspec.lock`taki 63 paketin HER biri `NETWORK_DEPS_RECORDED`
⊎ `NETWORK_DEPS_KNOWN_SAFE` (60 paket, kategori+itibarla sınıflandırıldı,
dürüst sınır isimle yazıldı) bölmesine girmek ZORUNDA. 2 yeni öz-test —
commit `1abd4a0`.

> ***Üç kapı da (①②③) kapandı — bu gecenin dispatch kuyruğu BİTTİ.***

## Kapanış — 2026-08-12 sabah, kalıcı

Kurucu direktifi (dolaylı, koordinatör aktardı): G3 çekimi sona ötelendi ·
internet videosu referans yolu AÇILDI, `hold_isolator` (M-F-75) ön koşullu.
Koordinatörün C-195 kaydı düzeltildi (M-F-506): "beş hat çözdü" YANLIŞTI,
Lissom'un "kilit BİLEREK YOK" ölçümü ÇEKİRDEK KARARINA döndü — motion-core'a
zorunlu-kilit API'si TAŞINMAYACAK. Kanıt: `docs/C-195-YARIS-OLCUMU-2026-08-12.md`.

Bu oturumun SON işi: Obsidian kayıt zinciri (devir notu + kendi bulduğu
başlangıç-promptu staleness'ı, dört kardeş hatta da yayıldı) + bir sonraki
oturumun promptu (onboarding YENİDEN ÖLÇÜM ilk iş, sıfır kurucu kararı,
kurucu-bağımlı maddeler ayrı "BEKLER" bölümünde — kurucu bugün ULAŞILAMAZ).

**Bu oturum kalıcı olarak kapanıyor.** Bir sonraki Lissom oturumu
`🚀 Başlangıç Promptu — Lissom.md`den başlar.

## Bu gecenin TAM zinciri (koordinatör dispatch özeti, 2026-08-12)

Kamera-kabuğu SIRA①-⑤ (L-273..276) → çelişki-kapısı envanteri 13→3 →
`invalidation.trigger` şeması → L-277 (`reference_equivalence` kanıt
zinciri, KAPALI) → L-278/L-279 (`metric_coverage_test.dart` A+B+C, KAPALI)
→ L-279 (A3 değişim-dedektörü, KAPALI). **Açık kalan tek kalem:** L-187
göçüne bağlı içerik (Dart çekirdeğin `world` uzayına geçmesi — ayrı,
motion-core işi, bu oturumun kapsamı DIŞINDA).

---

# Oturum 2026-08-12 (gündüz) — onboarding ÖLÇÜMÜ ve yaş bandı zinciri

## L-280 — Onboarding "VAR"dı; topladığı şeyin OKUYUCUSU yoktu

**İLK İŞ ölçümdü, ve iki öncül de bayat çıktı — biri LEHİME, biri ALEYHİME.**

**① Lehime (prompt bayattı):** promptum *"gezilebilir ekran sayısı (08-07'de
**2**) yeniden ÖLÇÜLMEDİ"* diyordu. DEFTER L-270/L-271 bunu **dün gece zaten
ölçmüştü**: `reachability_test.dart` kabuğu SÜREREK **6 geniş / 2 katı**,
*var-ama-ulaşılamayan* **0**, ve **6'nın altına düşerse kırmızı** kalıcı
kapısı. Kendim koşturdum, aynen doğrulandı. → *M-F-509'un kuralının bana
düşen hâli: bir kayıt işi HATIRLATIR, açık olup olmadığı ÖLÇÜLÜR.*

**② Aleyhime (asıl bulgu):** *"onboarding var mı"* sorusu **yanlış soruydu.**
`OnboardingGate` uygulamanın girişi, `OnboardingFlow` beş adım — **VAR.**
Ama:

> ***Onboarding kullanıcıya yaş bandını ZORUNLU seçtiriyor, diske yazıyor,
> ve HİÇBİR YER okumuyordu.***

`OnboardingProfile`ın `lib/app/onboarding_*` **dışında tek okuyucusu yoktu.**
`AssessmentEngine` `ageBand` parametresini **kabul ediyor**,
`ScoringSpec.floorsFor` bandı **gerçekten kullanıyor**, config üç bandı
**gerçekten taşıyor** — ama `live_capture_screen.dart`ın `_newEngine()`'i
`ageBand`i **hiç geçmiyordu.** Yani ekran *"Scoring bands are age-based"*
diyor, kullanıcı seçiyor, **her ölçüm en muhafazakâr bantla koşuyordu.**

**L-262 sınıfının tam hâli:** *kullanıcıya OLMAYAN bir yeteneği anlatmak* —
ve bu kez zarar **oluşuyordu**, çünkü ekran açılıyor ve seçim ZORUNLU.

### 🪤 Zincirin ortasında KENDİ AÇTIĞIM delik

Kabloyu `s.data!.profile.ageBand`ten çektim. **Yanlıştı ve testim yakaladı:**
geçit `_loaded`'ı diskten **bilerek yeniden okumuyor** (L-273 turunda öyle
tasarlanmış), yani o profil **AÇILIŞTA** okunmuş — onboarding'i **az önce**
bitiren kullanıcının bandı orada **YOK**. Bant ancak **bir sonraki açılışta**
etki ederdi: kullanıcının **İLK ölçümü** — yani onboarding'in var oluş
sebebi olan ölçüm — **yanlış bantla koşardı.** `onDone` artık **yazılan
profilin kendisini** taşıyor.

> ***Bir kabloyu doğru uca bağlamak yetmez; o ucun O ANDA dolu olduğu
> ölçülmeli.***

### 🪤 İkinci delik: tek koşulda birleştirilmiş İKİ OLGU (kapı yakaladı)

`ageBandDeclaredButUnknown` damgasını `declared != null && effective == null`
diye yazdım. **Nitel testlerin bandı hiç yok** → geçerli bir beyan
*"bilinmeyen"* diye damgalanıyordu. İki ayrı olgu: ① test BANTLI ama bandı
tanımıyor (SAPMA) ② test BANTSIZ (NORMAL). Kapı bunu ilk koşumda kırmızı
yaktı. → *L-278'in dersinin aynısı, bu kez kendi kodumda.*

### Kapı bir YAZIM kapısı DEĞİL — ve kendi sabotajıyla sınandı

`floorsFor` tanımadığı bantta **`BatteryError` FIRLATIR**. Yani kablolama,
config sapınca sessiz bir hiçliği **cihazda çökmeye** çevirebilirdi. Kapı bu
yüzden iki listeyi karşılaştırmıyor; **gerçek config üstünde her (test × bant)
çiftini gerçekten çağırıyor** ve *uydurma bant FIRLATMALI* pozitif kontrolünü
taşıyor (nitel testler erken `null` döndüğü için, kontrolsüz hâli
**vakum-doğru** olabilirdi).

**Dört sabotaj, dördü de İNDİĞİ ÖLÇÜLEREK (dizge 1→0) koşuldu, dördü de
kırmızı:** ① motor bandı almasın ② home→ölçüm halkası kopsun ③ az-önce-
tamamlanan profil yoksayılsın ④ config'ten bir bant düşsün. ④'ün mesajı
düzeltmeyi de söylüyor (*"ya config'e ekleyin ya kOfferedAgeBands'ten
çıkarın"*).

### Alınan kararlar (koordinatöre bildirildi, onay BEKLEMEDEN uygulanmadı)

- **Emniyet kemeri, kilit değil:** tanınmayan bant motora GEÇMEZ (çıkmaz
  sokak yasağı, M-F-267), en muhafazakâr banda dönülür, **ve düşen beyan
  provenance'a İSİMLE yazılır** — sessiz düşürme yok.
- **`provenance['ageBand']`** eklendi: ölçümü hangi bandın skorladığı kaydın
  parçası (M-F-07 sınıfı). Provenance anahtarlarında tam-eşitlik mührü
  OLMADIĞI ölçüldü, ekleme güvenli.
- **Yaş bandı ZORUNLU kalmaya devam ediyor** (mevcut davranış değişmedi) —
  opsiyonel yapmak bir ÜRÜN kararı, koordinatörde.

### ⛔ KAPATILMADI — isimle açık

- **`gender` ve `painNotes` hâlâ okuyucusuz.** Bu tur **yalnız `ageBand`**
  kablolandı, çünkü zarar orada ölçüldü: bant **ZORUNLU** ve ekran onun
  hakkında **iddia** taşıyor. `painNotes` ipucu (*"Anything Lissom should
  know about"*) bir vaat gibi okunabilir — **ürün kararı, koordinatörde.**
- **`reachability_test.dart` kabuğu sürüyor, `OnboardingGate`i DEĞİL.**
  Kapının kendi sorusu *"uygulamayı AÇAN kullanıcı"* diyor; onboarding
  eklendiğinden beri açılış artık kabuk değil. Sayı kabuk için doğru,
  **cümlesi artık kapsamından geniş** — ölçü tanımı koordinatörün kalemi,
  DOKUNMADIM.

## L-281 — Okuyucusu olmayan alan: SORUYU düşürdüm, ipucunu düzeltmedim

**Koordinatör hükmü (Gravita O3/O4 ile aynı, tutarlılık zorunlu):** *okuyucusu
olmayan alan, okunuyormuş gibi konuşamaz.* İki seçenek verdi (alanı düşür /
ipucunu dürüstleştir), **en ucuzunu seçip gerekçesini kaydetmemi** istedi.

**Önce ölçtüm, sonra seçtim — ve ilk ölçümüm YANLIŞTI.** `git grep -c` dört
dosya/32 isabet gösterdi ve *"düşürmek pahalı"* diye okudum. Dosyalara
bakınca: **`onboarding_store_test.dart`in 8 isabeti MODEL düzeyinde**
(serileştirme turu) ve şema alanları kalınca **ikisinde de ayakta.** Gerçek
fark yalnız `_ProfileStep` + 3 test satırı. → ***İki seçeneğin tek-seferlik
maliyeti EŞİT çıktı; "isabet sayısı" onları ayırt edemiyordu.***

> ***Bir sayı, neyin sayısı olduğu görülmeden karşılaştırma yapamaz***
> (M-F-501'in araç dersinin bana düşen hâli).

**Seçim: girdiyi DÜŞÜR.** Ayıran şey tek-seferlik değil **SÜREKLİ** maliyet:

1. *"Buraya yaz, okumuyoruz"* diyen bir alan **her metin turunda ve her
   mağaza gizlilik-beyanında yeniden savunulmak** zorundadır.
2. **Serbest metinli sakatlık geçmişi, OKUNMASA BİLE beyan edilmesi gereken
   bir sağlık-verisi toplama noktasıdır.** Girdiyi kaldırmak noktayı da
   kaldırır — dürüst bir ipucu bunu yapmaz.
3. Wellness sınırında zarar daha keskin: kullanıcı sakatlığını yazıp
   **ölçümde dikkate alınacağını umardı.**

**Şema alanları KALDI** (`fromJson` toleransı — eski bir build'in yazdığı
profil hâlâ ayrıştırılsın); yazma yolu yok. ⛔ **Okuyucu YAZMADIM** —
koordinatör sınırı. Geri gelme koşulu ZAMAN değil: **onları OKUYAN üretim
kodu doğduğunda.**

**Kapı + sabotaj:** O4'te `gender`/`painNotes` girdisi ve vaat-ipucu
ARANMIYOR olmalı; pozitif çapa yaş-bandı çiplerinin görünmesi (yoksa
*"girdi yok"* vakum-doğru olurdu). 🪤 **İlk sabotajım İNMEDİ** (perl çapası
tutmadı, isabet 0) — *sonucu raporlamadım*, çapayı tekillik `assert`iyle
yeniden kurdum, indi (0→1) ve test kırmızı yandı. *L-275 birebir tekrar:
inmemiş bir sabotaj, çalışan bir kapıyı bozuk gösterir.*

## L-281 EK — `reachability` kapısı: CÜMLE daraldı, SAYI değil

Kapının sorusu *"uygulamayı AÇAN kullanıcı"* diyordu; onboarding aynı gün
eklendiğinden beri açılış artık `OnboardingGate`, ama kapı `LissomShell`i
sürüyor. **Sayı doğruydu, iddiası kapsamını aşıyordu.**

**Gravita aynı şerhi bağımsız düştü → 2/5, yani Lissom kusuru değil aile
ölçü-tanımı sorunu.** Koordinatör hükmü: ***şimdi cümleyi daralt, ölçüyü
DEĞİŞTİRME*** — kapsamı büyütmek **sayıyı** değiştirir, ve o sayı panoya +
aile karşılaştırmasına giriyor; vardiya ortasında birimi değiştirmek
kıyaslanabilirliği **sessizce** bozar. Onboarding-dahil tanım çekirdek turuna
alındı.

Ölçüldü: cümle değişti (*"KABUĞA girmiş"*, başlık *"KABUK-İÇİ"*), sayı
**6 geniş / 2 katı / ulaşılamayan 0** — **birebir aynı.**

## L-282 — Sevk edilen koruma ZATEN VARDI ve ÇALIŞIYOR (ölçüm, kod yazılmadı)

Koordinatör *"`reference_equivalence` koruması — ŞİMDİ, korumayı KUR"* diye
sevk etti. **Kurmadan önce ölçtüm** (kendi kuralı: *bir kayıt işi HATIRLATIR,
açık olup olmadığı hattın kendi ağacında ÖLÇÜLÜR*, M-F-509). Sonuç:

> ***Koruma zaten tam — hem kapısı hem ÜRETİCİSİ, ve bugün ÇALIŞTIĞI
> ölçüldü.***

| Parça | Durum |
|---|---|
| `test/reference_equivalence_test.dart` | ✅ 10 385 B |
| `tools/l031_space_divergence.py --claim-equivalence` | ✅ üretici, altı alanı da yazıyor |
| `tools/mutation_reference_equivalence.py` | ✅ 10 587 B |
| `docs/L-031-ESDEGERLIK-KANITI.json` | ❌ YOK — **ve doğrusu bu** (aşağıda) |

**Mutasyon tanısı KOŞULDU (bugün, benim iki commit'imin üstünde):**
① asıl delik (uydurma kanıt) **KIRMIZI** ② bayatlık (hash uyuşmuyor)
**KIRMIZI** ③ pozitif çapa (gerçek koşum) **YEŞİL**.
→ *hem kaçak sızdırmıyor hem gerçek ölçümü reddetmiyor.*

### 🪤 "Eksik dosya" beni yanıltmaya BİR ADIM kalmıştı

`L-031-ESDEGERLIK-KANITI.json` yok, `.gitignore`'da da yok, ama süit YEŞİL —
ilk okumam ***"koruma kurulu ama ATIL"*** oldu. **Yanlıştı.** Testi okuyunca:
`kBridgeIsReferenceEquivalent` bugün `false` ve kapı o dalda erken dönüyor;
kanıt dosyası **yalnız bayrak `true` yapılınca** zorunlu. Yani dosyanın
yokluğu bir eksik değil, **bugünkü dürüst hâlin ta kendisi** — kanıt, iddia
edildiği gün doğar.

> ***Bir kapının bugün sessiz olması, kurulu olmadığı anlamına gelmez;
> koşulu henüz gerçekleşmemiş olabilir.*** Ve bunu ayırt etmenin tek yolu
> kapıyı OKUMAKTI — dosya listesine bakmak yanlış cevabı veriyordu.

### 📌 Aile deseninin ÜÇÜNCÜ tekrarı

Choreia `--self-test` · Ostinato `hold_isolator` · **şimdi Lissom
`reference_equivalence`** — üçünde de sevk *"kur/düzelt"* dedi, üçünde de iş
**zaten kapalıydı**, ve üçünü de **hat ölçerek** yakaladı. Kaynak her seferinde
aynı: kaydın DURUMU okundu, GERÇEĞİ ölçülmedi (M-F-508/509).

**Kod yazılmadı, commit yok** — yazılacak bir şey yoktu. Sahte bir "kurdum"
commit'i, kapının kanıt gücünü değiştirmeden defteri kirletirdi.

## L-283 — Çıkmaz sokak VARDI; ama "adapte et" denen hat onu ÇÖZMEMİŞTİ

Koordinatör aile taraması beni **aday** işaretledi (`permanentlyDenied`
işleniyor, OS-ayar-açma **0**) ve *"JabLab çözmüş (`openAppSettings` 4) →
İCAT ETME, ADAPTE ET"* dedi.

**Ölçüm: kusur BENDE VAR, ama JabLab'da ÇÖZÜM YOK.**

### 🪤 Pozitif kontrolüm ÇÖKTÜ, ve çöküşü asıl bulguyu verdi

M-F-505'in kuralını uyguladım — *pozitif kontrol ARACA değil DİZGEYE
kurulur* — ve dizgemi **çözdüğü BİLİNEN** hatta sınadım: **JabLab
`openAppSettings` = 0.** Desenim yanlış olabilirdi. Araştırdım:

| Hat | OS-ayar-açma | `permanentlyDenied` |
|---|---|---|
| Choreia | 0 | 2 |
| Gravita | 0 | 0 |
| **JabLab** | **0** | 4 |
| **Lissom** | **0** | 2 |
| **Ostinato** | **1** ✅ | 1 |

JabLab'ın `_openSettings`i **uygulamanın KENDİ `SettingsPage`ine** gidiyor;
`openAppSettings`/`AppSettings.`/`url_launcher`/`launchUrl` **hepsi 0**, ve
kalıcı-ret dalı yalnız bir CÜMLE üretiyor (*"You can turn it on in
Settings"*) — **yani JabLab'da da aynı çıkmaz sokak var.**

> ***Koordinatörün "4" sayısı bir VEKİLDİ*** — `permanentlyDenied` isabetini
> *"çözdü"* için vekil almış (M-F-506'nın birebir tekrarı: `--grep` isabeti
> bir ADAYDIR, bir SONUÇ değil). *"Adapte et"* talimatı, **adapte edilecek
> şey olmadan** geldi.

Desenim doğruydu: **Ostinato**'da isabet etti (`live_screen.dart`), ve API
adını paketin kaynağından doğruladım (`openAppSettings()`,
permission_handler 11.4.0). **Desen Ostinato'dan alındı:** *dürüst hâl
ekranı bir EYLEM taşır* (etiket + geri çağırım).

### Bulunan iki yer — ve iddiayı TAM boyunda tuttum

① **Canlı ölçüm ekranı:** metin *"Open Settings…"* diyor, **hiçbir kontrol
yok**, ve `canMeasure` false olduğu için ekranda başka düğme de kalmıyor.
② **Onboarding O3:** metin *"…later in Settings"* diyor; kalan tek kontrol
(*"Check again"*) kullanıcı ayarları açana kadar gözle görülür hiçbir şey
yapmıyor.

⚠️ **"Ölü düğme" DEMEDİM.** *"Check again"* kullanıcı ayarlardan **döndükten
sonra** gerçekten çalışıyor (`request()` güncel durumu okur). Kusur düğme
değil, **oraya gitmenin yolunun olmaması** — düğme, kullanıcının fiilen
izleyebildiği yol boyunca atıl kalıyordu. ***Fazla iddia, eksik iddia kadar
pahalıdır*** (Choreia'nın bulgusunu kendi ağacıma OLDUĞUNDAN büyük
kopyalamak kolaydı).

### Kapı: VARLIK değil ETKİ

Düğme enjekte edilebilir bir geri çağırımla kuruldu (`sourceOverride`la aynı
sözleşme) — çünkü `openAppSettings` bir platform kanalı çağırır ve widget
testinde yalnız **varlığı** ölçülebilirdi. O3'ün kalıcı-ret hâline **gerçek
kod yolundan** girildi: `permission_handler` kanalı (`flutter.baseflow.com/
permissions/methods`) stub'landı, kaynak taraması YAPILMADI.

🪤 **Ve enum sıra numarasını ölçerken kendi aracım yanılttı:** filtrem
`^\s*[a-z]+,` idi ve **camelCase'i süzüyordu** — `permanentlyDenied`
listede GÖRÜNMEDİ. Python'la yeniden saydım: **4**. *Bir sayım aracı, neyi
saymadığını söylemez.*

**Üç sabotaj, üçü de indiği ölçülerek (1→0), üçü de kırmızı:** ① canlı
düğme kaldırıldı ② **düğme VAR ama hiçbir şey yapmıyor** ③ O3 düğmesi
kaldırıldı. ②'yi ayrıca koştum çünkü bu kapının asıl iddiası *varlık* değil
*etki*.

**Geçici rette düğme YOK** — sistem hâlâ soracak; kullanıcıyı OS ayarlarına
yollamak gereksiz bir yolculuk ve yanlış bir kesinlik iması.

📌 **Aile kalemi:** çıkmaz sokak **Choreia · JabLab · Lissom**'da ölçüldü,
**Ostinato**'da çözülmüş. Gravita'nın `permanentlyDenied`i **0** — dalı hiç
işlemiyor olabilir, **ayrı bir soru** (ölçmedim, sınırım dışı).

## L-283 EK — `isRestricted`: kodda VARDI, davranışla SÜRÜLMEMİŞTİ

Koordinatör referansını düzeltti (JabLab→Ostinato — benim ölçümümle aynı) ve
bir şerh düştü: ***`isRestricted` kritik*** — MDM/ebeveyn denetimli cihazda
izin diyaloğu **HİÇ çıkmaz**, yani *"ikinci ret = kalıcı"* sezgisi o vakayı
**ilkece** göremez.

**Ölçtüm — ve şerh haklı çıktı, ama beklediğim yerde değil:**

| | kodda kapsanıyor | DAVRANIŞLA sürülüyor |
|---|---|---|
| canlı yol (`permissionState`) | ✅ | ✅ `camera_pose_source_test.dart:42` |
| **onboarding O3** | ✅ | ❌ **YOK** |

Yani `||`'ın ikinci terimini **görmüştüm** ve doğru saymıştım — ama O3'te
onu **hiç sürmemiştim.** ***Bu tam olarak benim bütün gün polislik ettiğim
ayrım, kendi testimde:*** kodda bir terimin VARLIĞINI doğrulamak, o terimin
ÇALIŞTIĞINI doğrulamak değildir (L-278/L-279'un aynası).

**Sabotaj hükmü kesin:** `_isPermanentlyDenied`ten `|| s.isRestricted`
düşürüldü (dizge 1→0, indiği ölçüldü) → **yalnız YENİ test kırmızı yandı**,
diğer üçü YEŞİL kaldı. → *Yeni testi yazmasaydım, `isRestricted`'ın
düşürülmesi sessizce geçerdi.*

### 📌 Koordinatörün sayısı — bugünün ÜÇÜNCÜ vekili

*"`openAppSettings` sende 4 dosyada"* dedi. Ölçüm: **2 dosya**, 4 **isabet**
(biri doc yorumu, biri `show` importu). **Satır sayısı dosya sayısı olarak
okunmuş.** Bugün üçüncü kez aynı sınıf (JabLab "4" · benim ilk `git grep -c`
32'm · şimdi bu) — ve üçünde de **düzeltme ölçümden çıktı, tartışmadan
değil.**

📌 Koordinatörün kendi kaydettiği ders (Choreia'dan): **terim taraması
sınıf-adı taramasını kaçırır** — Ostinato bu hâli `PermissionDeniedPermanent`
adlı sealed bir durumla işliyor. Benim ailem-taramamın `openAppSettings`
üstünden yürümesi bu yüzden tuttu: **API adı**, sınıf adından daha kararlı
bir çapa.

## L-284 — Yayın engeli ölçümü: engel KATMAN DEĞİŞTİRDİ, ve yeni engel bir VAAT

`YAYIN-ENGELLERI-2026-08-07.md` yeniden ölçüldü (5 gün, ~100 commit).
Devralınan hiçbir "✅" doğru sayılmadı. **4 kalem gerçekten kapanmış**
(kamera bağlantısı · izin metni · poz modeli · onboarding) — ve bugün
beşincisi (izin çıkmaz sokağı) eklendi.

### 🔴 Yeni baş engel: ölçüm KAYDEDİLMİYOR

`live_capture_screen.dart`ta `SessionStore`a yazma **SIFIR** (pozitif
kontrol: `SessionStore` başka **4** dosyada geçiyor → süzgeç çalışıyor).
Geçmiş `app_facts.dart`ta **okunuyor**, kimse **yazmıyor**.

> Kullanıcı ölçüm yapıyor, sayıyı görüyor, ekranı kapatıyor — **sayı yok.**
> Progress ve geçmiş **kalıcı olarak boş.**

Ve sonuç ekranı aynen şunu diyor: *"This is your starting point — **we'll
track it from here.**"* → ***Bu, bugün TUTULAMAYAN bir vaat*** — sabahki
`ageBand` kusurunun (toplanan ama okunmayan) **büyük kardeşi**: burada
üretilen ama saklanmayan. **Aynı sınıfın iki ucu, aynı gün.**

📌 Ve `surface_language_test.dart` (vaat dili kapısı) bunu **yakalamadı** —
kapı vaat *kelimelerini* arıyor, *tutulamayan bir sözü* değil. Kapının
kapsamı burada bitiyor; **ölçtüm, genişletmedim** (ölçü tanımı koordinatörde).

### 🪤 Kendi aracım bu turda İKİ kez yanlış rapor verdi

① **`sed` `assets:` bloğunu bulamadı** → *"pubspec'te assets YOK"* diye
okuyacaktım; doğrudan `grep` **satır 79'da** buldu. *(08-07 turunda da aynı
parser üç kez yanılmış — aynı dosya, aynı sınıf.)*

② **İkon SHA karşılaştırmam *"özel ikon var"* dedi ve YANLIŞTI.** Şablon
dosyası **0 baytlık** bir `.img.tmpl`; karşılaştırdığım hash `e3b0c442…`
yani **boş girdinin** SHA-256'sı. **Boş dosyayla karşılaştırıp "farklı"
sonucuna varmak vakum-doğrudur.** Görüntüyü **açtım**: mavi Flutter logosu,
engel **açık**. → ***Bir karşılaştırmanın iki tarafı da doğrulanmadan
sonucu okunamaz.***

### ✅ 08-07'nin "ölçülemedi"si kapandı

ASC: app **6794715023**, *"Lissom: Mobility & Yoga"*, sürüm **1.0
PREPARE_FOR_SUBMISSION**, **yüklenmiş build 0** (TestFlight geçmişi yok),
`releaseType: AFTER_APPROVAL` (onaylanınca **otomatik yayın**).

### 🪤 Pin tuzağı — az kalsın yanlış paketi ölçüyordum

Android kamera izni uygulamanın kendi manifest'inde **yok**; `motion_camera`
merge ile getiriyor. İlk baktığım checkout **`101ed95c`**'ydi — **pin
DEĞİL**. Pinli sürümle (`f13bdc9`) yeniden doğrulandı, orada da var.
*Pub-cache'te birden çok checkout durur; hangisini okuduğun ölçümün parçası.*

### Yeni bulunan, 08-07 listesinde HİÇ olmayan

**Android release imzası DEBUG anahtarlarıyla** (`build.gradle.kts:35`,
`TODO` duruyor) — Play debug-imzalı AAB'yi reddeder. Keystore **kurucu**
kalemi.

**Kritik yol:** ⑬ kaydet → ⑨ özet yüzeyi → ⑧ Progress dolar → ③④⑥ store →
⑬b cihaz turu → ⑭ keystore. ⑬ hat-yereli ve **kurucu-bağımsız**.

## L-285 — ⑬ Ölçüm kaydedilmiyordu: yol YAPILMIŞ, RAMPASI yoktu

`live_capture_screen`de `SessionStore`a yazma **SIFIR**dı. Ama asıl bulgu
şu: **çeviri katmanı zaten vardı** — `assessment_history.dart`ın
`recordFor`u ve `appendPreserved`ı, dört kararının her birinin ölçülmüş
gerekçesiyle **yazılmış, belgelenmiş**, ve `lib/` içinde **sıfır çağıranı**
olan bir yol. ***Yapılmış yol, rampası yok.***

Sonuç: kullanıcı ölçüm yapıyor, sayıyı görüyor, ekranı kapatıyor — **sayı
yok.** Ve sonuç ekranı *"This is your starting point — **we'll track it from
here**"* diyordu: **08-07'den beri TUTULAMAYAN bir vaat.**

**`appendPreserved` DEĞİL `recordFor` kullanıldı** — o fonksiyon
`AssessmentSession`ın çok-bloklu orkestrası içindir (yarım blok girmesin
diye); bu ekran TEK bir `AssessmentEngine` koşturuyor. *Var olan bir
fonksiyonu adı uyduğu için çağırmak, sözleşmesini okumadan kullanmaktır.*

### Söz artık OLGUYA bağlı

Yazmayı bağlayıp cümleyi koşulsuz bırakmak **kusuru bir katman derine
taşımak** olurdu. Takip sözü yalnız `saved == true` iken çıkıyor; yazma
patlarsa ekran çökmüyor (M-F-267) ama **susmuyor da**: *"could not be saved
… will not appear in Progress"* + sebep ikincil tonda. Üçüncü hâl
(*"Saving…"*) ayrı.

**Deneme başına sıfırlama:** *"Try again"* kayıt hâlini siliyor — kayıt bir
**OLAY**, durum değil (depo ek-yalnız); sıfırlanmasa yeni denemenin ekranı
önceki denemenin *"kaydedildi"*sini gösterirdi.

### 🪤 Testim üç kez kırmızı yandı ve kusur ÜRÜNDE DEĞİL TESTTEYDİ

İlk yazışımda gerçek `JsonlSessionStore`u `testWidgets` içinde kullandım.
Üçü de kırmızı. **Sebep: widget testleri `FakeAsync` bölgesinde koşar ve
`pumpAndSettle` GERÇEK dosya I/O'sunu BEKLEMEZ** — dosya hiç oluşmadan
iddia okunuyordu. *Az kalsın "ürün kaydetmiyor" diye rapor edecektim.*

→ **Bölme:** gerçek diske yazma saf `test()` içinde (FakeAsync yok, gerçek
dosya, gerçek `recordFor` çıktısı, üstelik `unreadableRecords()==0` ile
*"kendi okuyucusu okuyabiliyor mu"* da sınanıyor) · ekranın çağırdığı
`testWidgets` içinde **kaydeden** depoyla. İkisi ayrı kanıt; birleşik hâlde
ikisi de belirsizdi.

🪤 İkinci araç hatam: birim `°` sandım, config **`deg`** diyor. *Bir yüzey
iddiası, yüzeyin GERÇEK metniyle yazılır, hatırlananla değil.*

**İki sabotaj, ikisi de TEMİZ DERLEMEYLE indi** (derleme hatasının kırmızısı
kapı kanıtı değildir — önce `analyze` ile ölçüldü): ① kaydetme çağrısı
kaldırıldı → **3 kırmızı** ② yazma başarısızken de aynı söz verildi →
**1 kırmızı** (dürüst-hâl testi).

### ⛔ Kapsam dışı bırakıldı — isimle

- **Çekirdeğe DOKUNULMADI**, alan EKLENMEDİ (koordinatör sınırı: turda
  `SessionRecord`ın iki alanı değişecek, değişiklik toplamalı olacak).
- **Home/Progress kaydın ARDINDAN tazelenmiyor** — kabuk `AppFacts`i bir kez
  okuyor; yeni kayıt ancak yeniden açılışta görünür. Kayıt DİSKTE doğru,
  **yüzey tazeleme ayrı bir iş** (⑨ ile birlikte bakılmalı). Sevk *"kaydet
  ve göster"*di; sonuç ekranında gösteriliyor, **geçmiş yüzeyinde değil.**

## L-286 — ⑭ İmza kapısı: metin kapısı KANITLI, Gradle koruması DOĞRULANMADI

Release, **debug anahtarlarıyla** imzalanıyordu (`TODO` duruyordu) ve kusur
**08-07 engel listesinde hiç yoktu** — çünkü derleme **BAŞARILI** oluyor;
kusur ancak **Play reddedince** görünürdü. Ailenin *"sessiz-hiçlik"*
kuralının imza katmanı.

**Yapılan (koordinatör sınırı: keystore ÜRETME):**
① `build.gradle.kts` — gerçek imza `android/key.properties`ten gelir; yoksa
ve **gerçekten bir release görevi istendiyse** `GradleException` ile durur,
mesajı çözümü ve *"keystore workspace'te DURMAZ"* sınırını söyler. Debug
anahtarına düşmek artık bir VARSAYILAN değil, açık bir KARAR
(`-PallowDebugSigning`). Debug/test yolu bilerek etkilenmiyor — *kapı,
ürünün kendisini engellememeli*.
② `tools/release_signing_check.py` — korumanın **sessizce kaldırılamaması**
için. Öz-testi iki sahne taşıyor: sessiz düşüş yakalanmalı **ve** kelimeler
yalnız YORUMDA geçiyorsa geçirilmemeli (L-273: *kelimenin varlığı, çağrının
çalıştığı değildir*). Sabotaj: koruma silinip eski hâle dönüldü → **kırmızı**.
`all_gates.py` python sayısı **16 → 17** (kapı otomatik alındı).

### ⛔ VE BURADA DÜRÜST SINIR — koruma ÇALIŞTIĞI DOĞRULANMADI

`./gradlew :app:tasks` ve `:app:assembleRelease --dry-run`, **benim koduma
ULAŞMADAN** `25.0.2` diye çöküyor (Android toolchain).

**Bunu bana ait sanmadım, ÖLÇTÜM:** değişikliğimi `git stash` ile geri alıp
aynı komutu koştum — **aynı hata**. Yani çöküş **önceden var**, ben
kırmadım. Ama sonuç değişmiyor:

> ***Metin kapısı kanıtlı; Gradle korumasının GERÇEKTEN ateşlendiği
> DOĞRULANMADI.*** Kotlin DSL'imin derlendiği bile doğrulanmadı — Gradle
> yapılandırmaya hiç geçmedi.

Bu, bugünün kendi standardının bana dönmüş hâli: *bir korumanın VARLIĞI,
ateşlendiği anlamına gelmez.* Kapıyı yazdım, ama kapının kendi ateşleyicisi
bu makinede sınanamıyor.

📌 **Ve bu, engel listesine YENİ bir kalem ekliyor:** ⑮ **Android derleme
hattı bu makinede hiç koşmuyor** (`25.0.2`) — ⑭'ün doğrulanması buna bağlı,
ve *"release build gerçekten derleniyor mu"* sorusu (08-12 listesinde
`ölçülmedi` diye duruyordu) artık **`ölçüldü: HAYIR`**.

## L-286 EK — Koruma ATEŞLEDİ; ve metin kapımın göremediği kusur derlemede çıktı

Koordinatör ⑮'i teşhis etti: sebep NDK değil **JDK** — sistem Temurin
**25.0.2**, Gradle 8.14'ün Kotlin'i onu ayrıştıramıyor, `.kts` **hiç
derlenmiyordu.** JDK 17 ile koştum (kalıcı değişiklik YOK, çağrı başına
`JAVA_HOME`).

**🔴 VE İLK KOŞUM BENİM KODUMU ÇÜRÜTTÜ — kapım bunu göremezdi:**

```
Line 47: val keyProps = java.util.Properties()
                             ^ Unresolved reference: util
```

Gradle Kotlin DSL'inde **`java` `JavaPluginExtension`a çözümleniyor ve paket
adını GÖLGELİYOR.** Nitelikli ad derlenmiyor; `import java.util.Properties`
ZORUNLU.

> ***Metin kapım "koruma VAR" diyordu ve HAKLIYDI — ama koruma DERLENMİYORDU.
> Bir kapının doğrulayabildiği şey, kapının gördüğü katmanla sınırlıdır.***

Bu, bugün üç kez yazdığım dersin bana en pahalı dönüşü: `release_signing_
check.py` bir **metin** kapısı, ve metin doğruydu. Ateşleyicinin varlığını
ancak **gerçek derleme** gösterdi — ve o gün (`5ae3df0`) *"doğrulanmadı"*
diye kaydetmem, bugün onu düzeltebilmemin tek sebebi.

### Üç yol da ÖLÇÜLDÜ (JDK 17, `--dry-run`)

| Yol | Beklenen | Ölçülen |
|---|---|---|
| `assembleDebug` | koruma ATEŞLEMEZ, derlenir | ✅ **BUILD SUCCESSFUL** |
| `assembleRelease` (imzasız) | **DURUR**, sebebi+çözümü söyler | ✅ **FAILURE**, mesaj birebir (line 92) |
| `assembleRelease -PallowDebugSigning=true` | geçer ama **UYARIR** | ✅ **BUILD SUCCESSFUL** + *"Play'e YÜKLENEMEZ"* |

Üçüncüsü ayrıca **kapının ürünü kilitlemediğini** kanıtlıyor — *kapı, ürünün
kendisini engellememeli.*

📌 **⑮ ve *"release build gerçekten derleniyor mu"* artık ÖLÇÜLDÜ: EVET**
(JDK 17 ile). Kalıcı çözüm venture-ötesi ve **kurucuda** — `gradle.
properties`e makine yolu YAZILMADI (başka makinede/CI'da kırardı).

## L-287 — Tazeleme kapandı; ⑨ ise YAPISAL olarak kapanamıyor (ölçüm)

### Tazeleme — zincirin üçüncü halkası

Kabuk `AppFacts`i **bir kez** okuyordu (`late final`) ve `AppFacts` GEÇMİŞİ
de taşıyor. Yani L-285 ölçümü diske yazdıktan sonra bile, kullanıcı dönünce
Home ve Progress **ölçümden ÖNCEKİ dünyayı** gösteriyordu.

> ***Bir verinin YAZILMASI, GÖRÜNMESİ değildir.***

Bugünün zinciri tamamlandı: `ageBand` **toplanan ama okunmayan** (L-280) →
ölçüm **üretilen ama saklanmayan** (L-285) → geçmiş **saklanan ama
gösterilmeyen** (L-287). *Üç uç, aynı sınıf, aynı gün.*

Rota artık `await` ediliyor; dönüşte `onMeasurementDone` → kabuk geçmişi
yeniden okuyor. **Kapı çağrıyı SAYMIYOR, ETKİYİ ölçüyor:** yükleyici ikinci
çağrıda BAŞKA bir dünya döndürüyor ve *"Nothing recorded on this device"*
cümlesinin **düştüğü** sınanıyor.

**İkinci test kapının kendi panzehiri:** koşulsuz tazeleyen bir yüzey
birinci testi de geçerdi (L-258 sınıfı) → sekme gezinmesinde yeniden okuma
OLMAMALI. Sabotajla doğrulandı: sekmeye `_reloadFacts()` eklenince
**kırmızı**.

🪤 **Framework kendi kusurumu ilk koşumda yakaladı:** `setState(() => _facts
= …)` — ok-fonksiyonu **atamanın DEĞERİNİ** (bir `Future`) döndürüyor ve
Flutter bunu reddediyor (*"setState callback argument returned a Future"*).
Blok gövdeye çevrildi. *Bir dil kısayolu, sessizce bir sözleşmeyi bozabilir.*

**İki sabotaj, ikisi de TEMİZ DERLEMEYLE** (biri önce derleme hatası verdi,
o koşumu KANIT SAYMADIM ve geçerli Dart'la tekrarladım): ① tazeleme çağrısı
kaldırıldı → kırmızı ② koşulsuz tazeleme → kırmızı.

### ⑨ — ÖLÇÜLDÜ: bugün KAPANAMAZ, ve sebebi yapısal

`BatterySummaryView` bir `BatterySummary` ister; `BatterySummary.from`
`Map<String, AssessmentResult>` alır — yani **ölçülen DEĞER + bant** gerekir.

**`SessionRecord` bunları TAŞIMIYOR** (çekirdek tipi, ölçüldü): `lessonId ·
completedAt · workedSeconds · unitsCompleted · plannedUnits · unitLabel ·
lessonClass · unmeasuredUnits · unmeasuredReason`. **Değer yok, birim yok,
bant yok.**

→ ***Özet geçmişten YENİDEN KURULAMAZ.*** İki yol var, ikisi de bu turun
sınırı dışında:
- **(a)** çok-bloklu `AssessmentSession` bağlanır (özet canlı sonuçlardan
  doğar) — ayrı ve büyük iş;
- **(b)** `SessionRecord`a değer/bant alanları eklenir — **ÇEKİRDEK
  değişikliği, bu tur AÇIKÇA YASAK** (ve koordinatörün kendi notu: turda
  `SessionRecord`ın iki alanı zaten değişecek).

⚠️ **Ve tek sonucu "batarya özeti" diye göstermek DÜRÜST OLMAZDI:** 12
testlik bir bataryanın 1 satırını *"Assessment Battery"* başlığıyla sunmak,
bataryanın koşulduğunu ima ederdi. Yüzeyi bağlamak için içeriği uydurmak,
bu deponun bütün gün söktüğü kusurun ta kendisi.

**Kod yazılmadı.** ⑨ kritik yoldan **çıkarılmalı ve çekirdek turuna
bağlanmalı** — kararı koordinatörde.

## L-288 — ③ Gizlilik manifesti: koşul ÖLÇÜLDÜ, beyan yazıldı, ve PAKETE BAĞLANDI

**Gereklilik koşulu tam olarak ölçüldü** (08-12 sabahı *"kısmen"* kalmıştı).
Taranan: app `lib/` + `packages/lissom_engine` + **PİNLİ çekirdek**
(`motion_core`+`motion_camera` @ `f13bdc9` — pub-cache'te başka checkout'lar
da duruyor, L-284'ün tuzağı).

| Gerekçeli-API kategorisi | İsabet |
|---|---|
| dosya zaman damgası (`lastModified`/`stat`/`FileStat`) | **0** |
| disk alanı · sistem açılış · aktif klavye · UserDefaults | **0** |

**Üç katmanlı pozitif kontrol:** araç (`readAsString` bulunuyor) · dizge
(`File(` çekirdekte bulunuyor) · **kapsam** (aynı tarama pinli ağaçta
`readAsLines` buluyor) → *"0" aracın körlüğü değil, ölçülmüş bir yokluk.*

Eklentiler **kendi** manifestlerini taşıyor (ölçüldü): `permission_handler_
apple` ✅ · `path_provider_foundation` ✅ → onların API'leri yazılmadı; çift
beyan sahipliği bulanıklaştırırdı.

### 🔴 Ve JabLab'ın J-217'si BENDE DE VAR

`google_fonts` **doğrudan bağımlılık ve ÜRETİMDE kullanılıyor**
(`lissom_theme.dart` → `nunitoSansTextTheme()` + `newsreaderTextTheme()`),
`allowRuntimeFetching` **hiç kapatılmamış** (varsayılan AÇIK), `pubspec`te
**`fonts:` bloğu YOK** → uygulama yazı tipi yüzlerini **çalışma anında
Google'dan indiriyor.** Kendi üretim kodunda ağ **0** (ölçüldü).

> ***Kendi kodunda ağ olmaması, ÜRÜNÜNDE ağ olmaması demek değildir.***

Manifest bu yüzden *"hiçbir şey cihazdan çıkmıyor"* **DEMİYOR** — giden tek
isteğin bir FONT dosyası olduğunu ve kullanıcı verisi taşımadığını söylüyor.
*JabLab'ın sonucunu kopyalamadım; aynı katmanı kendi ağacımda ölçtüm ve
aynı kusuru buldum.*

### ⭐ Asıl kapı: dosyanın VARLIĞI değil, PAKETE GİRMESİ

> ***Bir manifest, Xcode projesine BAĞLI DEĞİLSE pakete GİRMEZ.***

Dosya depoda durur, git mutlu, kimse fark etmez — **mağaza yine reddeder.**
Bugünün *"yapılmış yol / rampası yok"* sınıfının iOS paketleme katmanındaki
hâli. JabLab'ın deseni alındı (**4 atıf**: `PBXBuildFile` ·
`PBXFileReference` · grup çocuğu · Resources fazı) ve `plutil -lint` ile
**pbxproj'un hâlâ ayrıştırıldığı** doğrulandı (pozitif kontrol: `plutil`
bozuk plist'i yakalıyor). *Gradle dersinin aynısı — metin kapısı
ayrıştırmayı göremez.*

🪤 **Kapımın kendi sayısı yanlıştı:** `.count()` **geçiş** sayıyor, satır
değil — bir `PBXBuildFile` satırı dizgeyi İKİ kez taşıyor, yani *"6/4
bağlı"* gibi anlamsız bir sayı üretiyordu. **Dört YAPISAL ÇAPA ayrı ayrı**
aranacak şekilde düzeltildi ve öz-testin sahte dizisi **gerçek pbxproj
biçimine** çevrildi (sahte girdi, gerçeğin reddedeceğini kabul ederdi).
*Bugün bütün gün polislik ettiğim şey, kendi kapımın mesajındaydı.*

**Sabotaj:** manifest yerinde ama **Resources fazından sökülmüş** →
**kırmızı**, ve eksik çapayı ADIYLA söylüyor. `all_gates.py` python
**17 → 18**.

## L-289 — ① bölme zaten doğruydu (keskinleştirdim) · ② sayma kuralı YAZILDI

### ① `google_fonts` bölmede — düzeltme DEĞİL, keskinleştirme

Koordinatör *"networkCapable mı, gerekçesi çalışma-anı çekmeyi adıyla
söylüyor mu, söylemiyorsa düzelt"* dedi. **Ölçtüm: zaten söylüyordu.**
`NETWORK_DEPS_RECORDED`da, gerekçesi *"yazı tipi indirir (GET); kullanıcı
verisi TAŞIMAZ … çevrimdışı açılışta tipografi kaybı"* diyor, ve bölme
`http`yi de **transitive** olarak yakalamış (*google_fonts'un runtime
yazı tipi GET'i için istemci*).

**Bir kusur bulamadım ve uydurmadım.** Eklediğim şey bugünkü ölçümün
kesinleştirdiği kısım: indirme **OLASI değil KESİN** — üretimde kullanılıyor
+ `allowRuntimeFetching` hiç kapatılmamış + `fonts:` bloğu YOK, yani
**paketlenmiş yedek olmadığı için ilk açılışta font GERÇEKTEN iniyor.**
Aile taraması **5/5 yapısal**. Kapı yeşil, **davranış değişmedi.**

### ② Gezilebilirlik sayma kuralı — ölçü DEĞİŞMEDİ, yalnız YAZILDI

Gravita'nın uyarısı haklı: *"6/2 · 5/3 · 7/4 aynı şeyi ölçmüyor olabilir —
fark İÇERİK değil SAYMA KURALI olabilir."* Kural `reachability_test.dart`ın
kendi doküman başlığına yazıldı (**kapı kendi kuralını taşır**), yedi madde:

1. Başlangıç **KABUK**, uygulama kökü değil → **onboarding DIŞARIDA**
2. **Sekme gövdesi GENİŞ'te 1 sayılır, KATI'da sayılmaz** (tek `Scaffold`,
   `switch`le gövde, `NavigationBar` hep görünür) → *Gravita'nın okumasıyla
   AYNI, o yüzden sayılar kıyaslanabilir*
3. KATI'ya girmenin ölçütü **gerçekten `Navigator.push`** (kod okuma değil)
4. Aday envanteri **ELLE** — desen türetme DENENDİ ve YANLIŞ saydı (L-270,
   `FamilyPage`i kaçırdı); **isimli sınır:** listeye eklenmemiş ekran
   kapıya görünmez
5. modal/sheet · kabuk kroması · yükleme/hata hâlleri sayılmaz
6. *"var ama ulaşılamıyor"* ve *"kabuğa hiç bağlanmamış"* AYRI raporlanır
7. kapı **alt sınır** tutar (6), üst sınır yok

🪤 **Ve kuralın gizli bir dayanağını adıyla yazdım:** tur rota açtığında
alttaki sekme gövdesi ağaçta KALIYOR; sayının doğru çıkmasının sebebi
`find.byType`ın **`skipOffstage: true`** varsayılanı + `pumpAndSettle`.
**İddiayı hafızadan yazmadım, Flutter kaynağında doğruladım.** Biri
değişirse (ör. saydam rota) sayım **sessizce** bozulur.

Ölçüm sonrası: **6 GENİŞ / 2 KATI — birebir aynı.**

## L-290 — Kapının HÜKMÜ doğruydu, RAPORU yanılttı (kendi commit'imde)

L-289'u commit ederken kapı şunu bastı:

```
✅ dart:lissom_engine    Waiting for another flutter command to release the startup lock...
```

**Yeşil bir hüküm, ama satırı "süit hiç koştu mu?" dedirtiyor.** Commit'i o
hükümle attım ve **sonra doğruladım** — süit gerçekten koşmuştu (109/109,
çıkış 0).

**Sebep ölçüldü:** hüküm `p.returncode == 0`dan geliyor (**sağlam**), ama
gösterilen satır `(stdout + stderr)`in SONUYDU ve `flutter`ın kilit uyarısı
**stderr'e** gidiyor → stderr doluyken test sonucunu **her zaman** eziyordu.

> ***Bir kapının HÜKMÜ doğru olabilir ve RAPORU yine de yanıltabilir —
> rapor da ölçümün parçasıdır.***

L-288'in kendi sayı hatasıyla (`.count()` geçiş sayıyor) **aynı sınıf**, ve
bugün ikinci kez **kendi kapımda.** Düzeltme: çıkış kodu 0 iken **stdout'un**
son satırı gösteriliyor; stderr yalnız düşen koşumda anlamlı.

**Pozitif kontrol — koşulu YENİDEN ÜRETTİM:** paralel bir `flutter test`
koşarken kapıyı çalıştırdım (kilit çekişmesi gerçekten oluştu) ve rapor
artık `+109: All tests passed!` diyor. *Kilit mesajını görmeden "düzeldi"
demek, düzelttiğim şeyi ölçmemek olurdu.*

⚠️ **Bu, sevk edilen ①②'nin dışında, kendi başıma yaptığım küçük bir
düzeltmedir** — ürün davranışına dokunmuyor, yalnız kapının kendi raporunu
dürüst yapıyor. Koordinatöre isimle bildirildi; veto edilebilir.

## L-291 — "Eklenti kendi manifestini taşıyor" iddiam YANLIŞTI (sonucu sıfır)

L-288'de *"`path_provider_foundation` ✅ kendi manifestini taşıyor"* yazdım.
**Olgu olarak yanlış.** Gravita çürüttü, koordinatör bildirdi, **ben ölçtüm.**

**Sebep — bugün İKİNCİ kez aynı tuzak:** pub-cache'te **iki sürüm** duruyor
(`2.5.1` + `2.6.0`); taramam `head -1` ile **2.5.1**i seçti ve manifest
buldu. **Çözülmüş sürüm `2.6.0`** (pubspec.lock **ve** package_config.json —
iki bağımsız kaynak) ve onda manifest **YOK**.

> ***Bir bağımlılığın "kendi manifestini taşıdığı" iddiası, O SÜRÜMDE
> ölçülmeden yazılamaz — SÜRÜM, İDDİANIN PARÇASIDIR.***

Aynı tuzağa bugün `motion_camera`da da düşmüştüm (pin `f13bdc9` yerine
`101ed95c` okumuştum) ve **oradan ders çıkardığımı sanıyordum** — ders
çıkarmak, bir sonraki farklı kılıkta tanımayı garanti etmiyor.

### Sonucu SIFIR — ve bunu devralmadım, ölçtüm

🪤 İlk sonuç taramam da **kapsam hatasıydı:** `2.6.0` artık Swift eklenti
DEĞİL, **FFI**'ya geçmiş; `*.swift` taraması yalnız **örnek** kodu
görüyordu. Kapsam düzeltilip gerçek uygulama (`ffi_bindings.g.dart` +
`path_provider_foundation_real.dart`) tarandı:

- `creationDate` · `modificationDate` · `attributesOfItem` · `getattrlist`
  · `systemUptime` · `freeSize` → **0**
- yaptığı tek şey **dizin çözümleme** (`NSFileManager` + `NS…Directory`)
  — gerekçeli-API listesinde **değil**
- **pozitif kontrol AYNI dosyalarda:** `FileManager` 15 · `Directory` 66

🪤 Ve pozitif kontrolüm **ilk denemede DÜŞTÜ** (`URLsForDirectory` 0 isabet
— üretilmiş FFI farklı adlandırıyor); *negatif sonucu kullanmadan önce
dizgemi düzelttim.* Kontrol geçmeden okunan bir sıfır, sıfır değildir.

→ `2.5.1`in manifesti de **her listeyi boş** bildiriyordu ⇒ manifestin
kaldırılması **bir beyanın kaybı değil, BOŞ bir beyanın kaldırılması.**
**③ kapalı kalıyor**, `NSPrivacyAccessedAPITypes []` beyanı **doğru**.

### ⭐ Ve düzeltmeyi yazarken kendi kapım `plutil`i geçti

Düzeltme metnine `--include=*.swift` yazdım — **XML yorumunda `--` YASAK**.
`plutil -lint` **OK dedi**; `privacy_manifest_check.py` (plistlib) **bozuk
plist** diye kırmızı yandı. İzole bir örnekle doğrulandı: `plutil` kabul
ediyor, `plistlib` reddediyor.

> ***Kapım sistem aracından KATI çıktı — ve haklıydı.*** Bir doğrulayıcının
> "OK" demesi, girdinin geçerli olduğu anlamına gelmiyor; hangi
> doğrulayıcının hangi katmanı gördüğü ölçümün parçası.

## L-292 — Çekirdek turu etki değerlendirmesi (kod YOK) + kendi aleyhime bir bulgu

Gündemin 9 kalemi kendi ağacımda ölçüldü; yayılım sayıları **devralınmadı**.

| # | kalem | bendeki ölçüm | duruş |
|---|---|---|---|
| ① | C-195 | tek-ekran mimari, yarış yok (belgeli) | **karşı-ölçüm** — garanti ✅ / kilit ⛔ |
| ② | worldLandmarks | `worldLandmark*` **0** · `.z` **0** (poz.k. `PoseLandmark` 8) | **karşı-ölçüm — beni SAYMA**; 2D bir SEÇİM |
| ③ | pencere-koşulu | şema var, **motor bağlantısı bilerek yarım** | **kısmi** — "uyguladı" YAZILMASIN |
| ④+⑦ | `workedSeconds → int?` | `attemptMicros ?? 0` → **girişim yokken 0 yazıyorum** | 🟢 **DESTEK** (sayaç bende yok) |
| ⑤ | kamera önizleme | `Texture(` **0** (poz.k. kamera 4 dosya) | 🔴 **aleyhime**, aşağıda |
| ⑥ | tutuş-süresi | `requiredHoldS` girişim kapısını sürüyor | 🟢 **DESTEK, canlı** |
| ⑧ | izin/gizlilik kapısı | 4 araç + 14 yüzey metni | 🟢 **referans olabilirim** |
| ⑨ | dürüst hâl ekranı | iki yerde uygulandı + `isRestricted` davranışla | 🟢 **DESTEK** |
| 🆕⑩ | `SessionRecord` **değer+bant** | özet geçmişten kurulamıyor | **1/5 — şişirme** |

### 🔴 Kendi aleyhime: önizleme yokluğum SESSİZ

JabLab'ın önizleme yokluğu **beyanlı** (`PLACEHOLDER(asset)` + `unblocked
by:` + kapı) → sınıfı **ERTELENMİŞ**. Bende `Texture(`/`textureId` **0**
ve **yokluğu söyleyen TEK bir yüzey yok**: kullanıcı ölçüm ekranını açıyor,
kamera görüntüsü görmüyor, **hiçbir şey neden olduğunu söylemiyor.**

> ***Sınıfım JabLab'ınkiyle aynı değil: onunki ERTELENMİŞ, benimki SESSİZ.***

Ailenin *"sessiz-hiçlik"* kuralının ihlali, ve **bugün başkasının ağacında
üç kez aradığım şey benim ağacımda duruyordu.** Kod yazmadım (tur sınırı);
koordinatöre isimle bildirildi.

### 📌 Kendi karşılaştırma iddiamı düzelttim

*"6/2 ile 7/4 kıyaslanabilir, fark içerik"* demiştim — **eksikti.** Hizalı
olan **sekme ekseni**; **envanter ekseninde ayrışıyoruz** (ben ELLE ·
Gravita DESEN · JabLab elle+yürüyerek) ve farkın ne kadarının içerik, ne
kadarının YÖNTEM olduğu **ölçülmedi.** *Bir hizalanma bulmak, tüm eksenlerde
hizalı olmak değildir.*

### Turun bende açtığı kapı sayısı: ÜÇ

④+⑦+⑩ bugün **ifade edilemeyen** üç olguyu ifade edilebilir kılıyor
(*girişim yok ≠ 0 saniye* · olay sayacı · *değer+bant*). ⑥⑧ zaten canlı,
①②③ kapı açmıyor. **JabLab'ın *"yetenek verir, kapı açmaz"* durumunda
DEĞİLİM** — bu, turun sıralamasında benim tarafımdan bir destek argümanı.

## L-293 — ⑤ Önizleme yokluğu artık BEYANLI · ve beyan üç kusur doğurdu

Sınıf ölçüldü: pinli `motion_camera` **texture sunmuyor** (0 dosya, poz.
kontrol `PoseSource` 3) ⇒ JabLab/Gravita ile **aynı çekirdek kısıtı** ⇒
sınıf **ERTELENMİŞ** (yapılabilir, biz yapmadık). Desen JabLab'dan
**adapte** edildi: tek satır `PLACEHOLDER(asset): … — unblocked by: …` +
kullanıcı cümlesi (*"left out on purpose"*, tarih YOK — *"yet"* yasak).
Kapı zaten bende vardı (`gen_placeholder_register.py`, **0 işaretçiyle**).

### 🪤 Üç kusur, üçü de kendi eklememden doğdu

**① İşaretçi ÇOK SATIRLIYDI** → kapı *"BOZUK işaret, kayda GİRMEDİ"* dedi.
Tek satıra alındı. *(Ve `EXIT=$?` yine `tail`in çıkışını okudu — bugün
üçüncü kez aynı boru tuzağı; gerçek çıkış ayrı ölçüldü.)*

**② Kart 375pt'te ekranı 118 piksel TAŞIRDI.** Dar-yüzey kapısı yakaladı;
800pt varsayılanında hiçbir işaret yoktu. **Metni KISALTMADIM** — bir
dürüstlük beyanının boyunu YERLEŞİMİN belirlemesi tam da kaçındığımız şey
olurdu. İçerik kaydırılabilir yapıldı.

**③ Ve kaydırma, L-283'ü ZAYIFLATTI:** *"Open Settings"* — kalıcı retten
çıkışın TEK yolu — **y=986'ya, katlamanın ALTINA** düştü. `tap()` uyarısı
yakaladı (*"widget is actually off-screen"*). → **Hâlin BİRİNCİL EYLEMİ
altta SABİT** (ölçümü bitir · ayarlara git); **açıklayıcı metin kayar,
EYLEM kaymaz.**

> ***Bir dürüstlük beyanı eklemek, ekranın FİZİĞİNİ değiştirir — ve
> düzeltmesi başka bir dürüstlük kusuru üretebilir.*** Üçü de kapılar
> tarafından yakalandı, hiçbiri iddiayla.

### ⭐ Sabotaj, korumamın YARIM olduğunu gösterdi

Kartı sildim → **kapı YEŞİL KALDI.** Çünkü `gen_placeholder_register.py`
**kaynak işaretçisini** koruyor, **kullanıcıya görünen cümleyi değil** —
yani yokluk kullanıcı için yeniden **sessizleşebilir**, kayıt onu hâlâ
listelerken.

> ***Kaynakta beyanlı olmak, KULLANICIYA beyanlı olmak değildir. İki ayrı
> yüzey, iki ayrı kapı.***

İkinci kapı eklendi (widget testi: kart görünür · *"left out on purpose"*
var · **`"yet"` YOK**). Yeniden sabotaj → **kırmızı**. Kapılar: **196/196**.

## L-294 — Defter tazeliği kapısı: biçim ÖLÇÜLDÜ, sonra yazıldı

Aile ölçümü: 2026-08-12'de iki hatta **59 kayıt** kaybı (JabLab 6 · Gravita 5
· Ostinato ~50) ve **beş hattın hiçbirinde** defterin tazeliğini ölçen kapı
yoktu. Referans **Gravita `1d110be`** — icat edilmedi, **adapte** edildi.

> ***Bir işin YAPILMIŞ olması, KAYDEDİLMİŞ olması değildir.***

### ⭐ Gravita'nın uyarısı bende BİREBİR gerçekleşti — ve önce ölçtüm

*"Defterin BİÇİMİ hatta göre değişir"* dedi (onun ilk yazımı tek biçim
tanıdığı için **47 yanlış pozitif** vermiş). **Kapıyı yazmadan ÖNCE kendi
defterimi ölçtüm:**

| biçim | sayı | ne |
|---|---|---|
| `\| L-NNN \| tür \| öncelik \|…` | **253** | ESKİ bölüm, tablo kaydı |
| `## L-NNN — …` | **39** | YENİ bölüm, prose başlığı |
| satır başında çıplak `L-NNN` | **7** | ⛔ **atıf, KAYIT DEĞİL** |

**Kesişim 0** → ikisi de gerçek kayıt, ayrık kümeler. **Yalnız `##`
tanısaydım 253 sahte gedik bildirirdim** — kapı doğduğu gün güvenilirliğini
kaybederdi. Ve 7 çıplak satırın **hepsi tek tek okundu**: *"L-289'u commit
ederken…"*, *"L-255'i uygularken…"* — atıf. Girdiye alınmadılar.

### Gravita'dan ALINMAYAN bir öz-test — ve gerekçesi ölçüldü

Onun ③. testi *"depodaki `G-999` sentinel'i girdiye karışmıyor"* diyor.
Bende `L-9xx` sentinel'i **YOK** (ölçüldü: **0** isabet) → kopyalamak,
**hiç var olmayan bir şeyi kontrol eden VAKUM-DOĞRU bir test** olurdu.
Yerine bu hattın **gerçek** kirlenme riski sınanıyor: **düzyazı atıfları**.

> ***Bir öz-testi kopyalamak, koruduğu riski de devraldığını varsaymaktır.***

### Desen de kopyalanamadı

Gravita `^G-\d+` (başlık BAŞINDA) arıyor; benim başlıklarım
**conventional-commit** (`fix(L-280): …`), numara **parantez içinde** →
`^[a-z]+\((L-\d+)`. Kapsam = commit'in **kendi iddiası**; `docs: bkz L-182`
eşleşmiyor (sınandı).

**Öz-test 4/4** (iki biçim AYRI AYRI · düzyazı atfı · sözünü etmek≠iddia) ·
**uçtan uca sabotaj:** `## L-293` defterden silindi → **kırmızı**, eksik
numarayı **adıyla** bildirdi; geri alınınca yeşil. Taban: **34 iddia / 172
commit / 292 kayıt · gedik 0.**

## L-295 — Placeholder BÖLMESİ: kapı sonuç dayatmıyor, KARARSIZLIĞI yasaklıyor

Kendi bulgum (*"kaynakta beyanlı olmak, kullanıcıya beyanlı olmak
değildir"*) üç hatta doğrulandı — ve **Ostinato bir adım ileri gitti.**
Desen ondan **adapte** edildi: her işaretçi **birine** girmek zorunda —
`user-surface: <WidgetKey>` **⊎** `source-only: <gerekçe>`; **üçüncü hâl
kırmızı.**

**Farkı gördüm:** benim iki kapım *"kullanıcı cümlesi var mı, dolu mu,
tarih vermiyor mu"* diye bir **SONUÇ** sınıyordu. Ostinato'nunki hiçbir
sonuç dayatmıyor — `source-only` meşru bir cevap; yasakladığı tek şey
**kararsızlık.**

> ***Bir kapı, bir sonucu dayatmak yerine KARARSIZLIĞI yasaklayabilir — o
> zaman hattı zorlamaz, yalnız SESSİZ KAYBI imkânsız kılar.***

Ve boşluk **gerçekti:** iki kapım da yalnız kullanıcı-yüzeyi OLAN
işaretçileri koruyordu; `user-surface` de `source-only` de olmayan biri
**ikisinden de sessizce geçerdi.**

### Kopyalamadım — kendi kuralım bana geri döndü

*Bir öz-testi kopyalamak, koruduğu riski de devraldığını varsaymaktır.*
Önce ölçtüm: **1 işaretçi, tek biçim** (`PLACEHOLDER(cat): … — unblocked
by: …`). Ostinato'nun sözdizimi değil, **benimki** genişletildi.

**Ayrıştırıcı TEK:** `gen_placeholder_register`den **içe aktarıldı**,
yeniden türetilmedi (*iki bağımsız çıkarım ayrışır* — bu vardiyada dört kez).

### 🪤 Ostinato'nun körlüğünü ADIYLA sınadım

Onun kapısı ilk hâlinde **kördü**: `(.+?)` işaretçinin geri kalanını
yutuyordu → *"anahtar sevk edilen kodda var mı"* sorusu **hiç
sorulmuyordu** (kapı koşuyor, soru sorulmuyor). Bende `binding` **ayrı
grup**, ve öz-test #2 tam bunu ölçüyor: bağ `unblocked`ın **içine
düşmemeli**.

**Ve anahtar kanıtı YORUMDAN gelmiyor** (öz-test #4): işaretçinin kendisi
bir yorum satırı; onu kanıt saymak kapıyı **kendi kendini doğrulatır**
hâle getirirdi. Yorumlar düşürülüp yalnız **sevk edilen kod** taranıyor.

### Payda DENETLENDİ, türetilmedi

`toplam ≠ user ⊎ source ⊎ kararsız` ise kırmızı. **Parçalardan toplayıp
*"denetledim"* demek aritmetik bir kimliktir, bir ölçüm değil** — JabLab'ın
bugün ölçtüğü kusur (sabotajda exit 0 vermişti).

**Öz-test 4/4** · **iki sabotaj, ikisi de kırmızı:** ① bağ kaldırıldı →
*"KARARSIZ"* ② anahtar bozuldu → *"var olmayan bir yüzeye işaret ediyor"*.
**Bölme: 1 işaretçi · user-surface 1 · source-only 0 · kararsız 0.**
Kapılar **19→20**.

## L-296 — Türkçenin iki `i`si: bir kapı varlık sebebini kaybetmişti

Koordinatörün aile ölçümü (`grep -i` Türkçe katlamıyor) kendi ağacımda
sınandı. **Teşhisini kısmen çürüttüm:** araç bazlı ayrışıyor —
`.lower()`/`.casefold()` kırık, ama **Python `re.IGNORECASE` ÇALIŞIYOR**
(ölçüldü, altı çiftin altısı).

### Tablo tamamlandı — kıran harf İKİ TANE, ters yönlerden

| yol | jetonda | yüzeyde | katlama | sonuç |
|---|---|---|---|---|
| **`ı`** (benim bulgum) | `ı` | `I` | `'I'.lower()`=`'i'` | 🔴 kaçırır |
| **`İ`** (koordinatör) | `i` | `İ` | `'İ'.lower()`=`'i̇'` (**2 kod noktası**) | 🔴 kaçırır |
| `ş ğ ç ö ü` | — | — | — | ✅ sağlam |

> ***Bir dilin iki harfi aynı ASCII harfe düşüyorsa, katlama HER İKİ YÖNDE
> de kaybeder — ve kaybın yönü, hangi harfin JETONDA olduğuna bağlıdır.***

### Bulunan: `status_weave_check` varlık sebebini kaybetmişti

Yasaklı listesinde **`"yakında"`** var (`ı`), karşılaştırma `.lower()` ile.
`"YAKINDA".lower()` = `"yakinda"` (noktalı) ≠ jeton (noktasız).

> ***`YAKINDA` yazan bir yüzey, "coming soon" sınıfını yakalamak için var
> olan kapıdan SESSİZCE geçiyordu.***

**Sabotaj sırası koordinatörün şartıydı ve tuttu:** sentetik yüzeye
`YAKINDA` enjekte edildi → **düzeltmeden ÖNCE EXIT 0** (kör) → düzeltme →
**EXIT 1** (ötüyor) → küçük kip `yakında` de **hâlâ** kırmızı (regresyon
yok) → temiz ağaç **yeşil** (yanlış pozitif yok).

### 🪤 VE İKİNCİ İDDİAM YANLIŞTI — kendi ölçümüm çürüttü

`harvest_prescreen`i de maruz bildirmiştim. **Kaynak-regex'im `"zayıf"`/
`"görüş"`/`"iki kişi"` buldu ve ben bunları DESEN sandım.** Modülü
introspection'la ölçünce: **blob'a karşı eşleşen kümelerde Türkçe desen
SIFIR** — bulduklarım **etiket ve gerekçe** dizeleriydi.

Değişikliği **geri aldım** (koordinatör kısıtı: *ASCII girdiye uygulanan
`.lower()` doğru ve dokunulmaz*). → ***Kaynağı regex'le okumak, bir kümenin
ÜYESİ ile o kümeyi ANLATAN metni ayırt edemez; ölçüm modülün kendisinden
yapılır.*** Bu vardiyada üçüncü kez aynı sınıf (pin checkout'u · `*.swift`
kapsamı · şimdi bu).

📌 **Panzehir DİLE BAĞLI:** Python'da `re.IGNORECASE`; **Dart'ta TERS** —
`RegExp(caseSensitive:false)` kırık, `.toLowerCase()` doğru (JabLab ölçtü).
Reçete taşınmaz.

## L-297 — "Varılabilir ama boş": oran Choreia'yla AYNI ŞEKİLDE, kusur SIFIR

Choreia ölçtü: gezilebilirlik **KATI 3 / GEVŞEK 5** ama **34 stilin 33'ü
çıkmaz sokak**. Aile hükmü *"üç app gezilemez"*di; gerçek ***"geziliyor ama
gidilen yerde bir şey yok"***. Kendi ağacımda ölçüldü.

**Tanım ÖNCE yazıldı** (koordinatör kısıtı: *tanım ölçümden sonra yazılırsa
sayıyı takip eder*), ve Choreia'nın modeli **kopyalanmadı** — onun içerik
birimi *ders*, benimki *ölçüm testi*.

### Ölçüm (yürüyerek, kartlara basarak)

| küme | sayı | hangileri |
|---|---|---|
| varılabilir aile hedefi | **6 / 6** | denklem denetlendi |
| içeriği VAR | **1** | Assessment Battery |
| **BOŞ-BEYANLI** (dürüst hâl) | **5** | Yoga · Flexibility · For Your Day · Warm-ups · Breath |
| **BOŞ-SESSİZ** (kusur) | **0** | — |

**Oran Choreia'yla aynı şekilde: 5/6 (%83) varılabilir-ama-boş.** Ama
**hiçbiri sessiz değil** — beşi de `honestyBox` + envanter satırı taşıyor
(*"N named · none in this build"*, sayı config'ten TÜRETİLİR, *"yakında N
kurs"* DEMEZ).

> ***Boş tek başına bir kusur değildir; kusur, boşluğun SESSİZ olmasıdır.***

⇒ Bende bu bir **dürüstlük kusuru DEĞİL, İÇERİK sorusu** — ve içerik
kurucunun kalemi (⑩, engel listesinde zaten var).

### 🪤 Denklem denetimi SAHTE TEMİZİ yakaladı

İlk yürüyüşüm kaydırmıyordu ve **altı aileden yalnız BİRİNE** ulaştı;
*"BOŞ-SESSİZ 0"* diye **doğru sonucu YANLIŞ SEBEPLE** basacaktı. Denklem
(`varılabilir = 1 ≠ 6`) kırmızı yandı.

> ***Ölçüm aracının körlüğü, bulguya dönüşmeden önce paydayla yakalanır —
> ve "0 kusur" en kolay sahtelenen sayıdır.***

Koordinatörün ③. kısıtı (*payda + işlem, denklemi denetle*) tam bunu
önledi. Ve bu, bugünkü *"bir rota tablosu kodun ANLATIMI, yürüyüş ise
GERÇEĞİ"* kuralının dördüncü ödemesi: yürüyüş de **eksik yürünürse** yalan
söyler.

## L-298 — Gezilebilirlik sözleşmesi: elle listem BİR ROTA UNUTMUŞ (KATI 2→3)

Aile sözleşmesi geldi; bende **iki parça** eksikti ve ikisi de KATI'yı
bozuyordu.

### ② Envanter — elle liste HAFIZADAN okur

Eski kapım `const List<Type> kCountableScreens` tutuyordu ve *"tek adres"*
diye savunuyordum. **Koordinatörün düzeltmesi haklı:** tek adres olması onu
**tazeleyen** bir şey değil, yalnız **tek yerde** tutuyor.

> ***Bir elle liste, modülün kendisi değil onun ANLATIMIDIR.***

Ve bu, bugün **kendi yazdığım** kuralın dördüncü hâli (pin checkout ·
`*.swift` kapsamı · desen sanılan etiket · şimdi elle liste).

**🔴 Ve gerçekten unutmuş:** `LiveCaptureScreen` listede YOKTU — oysa
Home'daki *"Start a measurement"* onu **gerçek bir rotayla** açıyor
(bugün L-285'te kendim bağladım). ***KATI sayım 2 değil 3'müş.***

### ③ Başlangıç — kabuktan başlamak, kullanıcının görmediği uygulamayı ölçmek

Ölçüm `LissomShell`den başlıyordu. Artık **uygulama kökünden**: taze
kurulum, ilk-koşu bayrağı `false`, onboarding **düğmeye basılarak** geçiliyor
(bayrak set edilerek DEĞİL).

### ÖNCE / SONRA — zorunlu, ve farkın sebebi

| | eski | yeni |
|---|---|---|
| başlangıç | kabuk | **uygulama kökü** |
| envanter | **elle** (6 tip) | **desenden** (7 aday, iki kanal) |
| üyelik | yürüyüş | yürüyüş + **`NavigatorObserver` tanıklığı** (9 push) |
| **KATI** | **2** | **3** |
| varılamayan | raporlanmıyordu | **0**, ve ayrı basılıyor |

**Farkın sebebi tek kalem: `LiveCaptureScreen`.**
⚠️ **Başlangıç noktası değişikliğinin KATI'ya etkisi SIFIR** — onboarding
rota AÇMIYOR (tek `Scaffold`, adım değiştiriyor). **Ama yazılıyor:**
*değişmemek de bir ölçümdür*, ve ölçüm artık kullanıcının başladığı yerden
başlıyor.

### Aday küme iki KANALDAN türetiliyor — tek kanal eksik sayardı

`tools/reachability_candidates.py`: ① `Scaffold` sahibi widget'lar
② **kabuğun `switch`indeki sekme gövdeleri** — bunlar Scaffold KURMAZ
(kabuk kurar), yani ①'in deseni onları **kaçırır**. Dışlananlar (hâl
ekranları, akış, kabuk) **adıyla** basılıyor, gizlenmiyor.

🪤 **Kapı doğduğu koşumda kendi kusurunu bildirdi:** desenim `=>\s*(\w+)\(`
idi ve `=> setState(...)`i "sekme gövdesi" saydı. *Bir desen, aradığı şeyin
BİÇİMİNİ de tanımlamalı — "bir şey çağrılıyor" yetmez.* Widget adı büyük
harfle başlar → `[A-Z]\w*`.

**Sabotaj:** sözleşmeden `LiveCaptureScreen` düşürüldü → **kırmızı**, adıyla.
Öz-test 3/3. Eski kapıya *"kanonik sayı artık burada değil"* şerhi kondu —
iki kaynak tek olgu olmasın.

## L-299 — (d) maddesini yazdım ve İLK HÂLİ VAKUM-DOĞRUYDU

Sözleşmenin (d) maddesi **benim bulgumdan** doğdu (*yürüyüş de eksik
yürünürse yalan söyler*). Kendi ağacıma uygularken **kendi maddemi kör
yazdım.**

**İlk hâli:** `reachedOutsideCandidates = reached − adaylar`. Ama `reached`,
`_visible()`ten geliyordu — **o da yalnız adaylara bakıyor.** Yani `reached`
**tanım gereği** aday-dışı bir şey içeremezdi.

**Sabotaj bunu gösterdi:** aday kümesinden `FamilyPage` düşürüldü, yürüyüş
oraya **gerçekten varıyor**, kapı **ötmedi**.

> ***Bir bölme denetimi, iki tarafı AYNI kaynaktan okuyorsa denetim değil
> TANIMDIR.***

**Düzeltme:** gözlem aday listesinden **bağımsız** hâle getirildi —
`_observedScreenLike()` ağacı **ada göre** tarıyor (`…Screen`/`…Page`),
aday listesine hiç bakmadan. Aynı sabotaj artık **adıyla ötüyor:**
*"yürüyüş aday kümesinde OLMAYAN bir yüzeye vardı: {FamilyPage} — desen bu
ekranı KAÇIRMIŞ."*

📌 Ve bu, koordinatörün **aynı gün** JabLab'da ölçtüğü kusurun bende
tekrarı (*türetilmiş bir toplamı assert etmek aritmetik bir kimliktir*) —
uyarıyı **okumuş**, kuralı **yazmış**, ve yine de **kendi kodumda**
yapmıştım. *Bir kuralı bilmek, onu uyguladığın anlamına gelmiyor.*

### 🪤 İkinci küçük kusur: cümlem fazla genişti

*"Kabuk açılışında rota push'u olmamalı"* diye assert ettim → **kırmızı**:
`MaterialApp`in **başlangıç rotası** (`/`) da bir push. Ürün kusuru değil,
**iddiam** fazla genişti. Ölçülen şey *"başlangıç rotasının ÖTESİNDE
gezinme"* → düzeltildi (8 push, başlangıç hariç).

### ③ ölçüldü, iddia edilmedi

Kabuktan başlayan tur **onboarding'i GÖRMÜYOR** (ayrı test, pozitif
çapasıyla: kabuk gerçekten açıldı, yani bulgu boş ekranın değil kabuğun
ölçümü). **KATI'ya etkisi SIFIR** — onboarding rota açmıyor. *Değişmemek de
bir ölçümdür.*

## L-300 — (e): elle liste SİLİNMEDİ, RÜTBESİ DÜŞÜRÜLDÜ

JabLab sözleşmeyi düzeltti: onun türetimi ilk hâlinde **bozuktu** (`_XState`
elemesi her StatefulWidget ekranını yok etti) ve ***yakalayan şey elle
beklenen kümesiydi.***

> ***Bir elle liste, KAYNAK olarak yanlıştır ama KONTROL olarak doğrudur —
> silinmez, RÜTBESİ DÜŞÜRÜLÜR.***

`kCountableScreens` artık **kaynak değil**, `reachability_candidates.py`nin
**pozitif kontrolü**: türetim onu **kapsamıyorsa kapı öter.**

**Sabotajla kanıtlandı:** sekme kanalı kapatıldı (türetim bozuldu) → kapı
**kırmızı** ve **dört sekme gövdesini adıyla** saydı. Yani hata türetimde
olduğunda **elle liste yakalıyor** — tam JabLab'ın vakası.

### Ve kendi eksikliği ŞERHLİ

⛔ Bu küme **bir ALT SINIRDIR, tam envanter DEĞİLDİR** — çünkü
`LiveCaptureScreen`i **taşımıyordu** (L-298). Türetim onu kapsamalı ama
**eşit olmak zorunda değil**; fazlası beklenir. Şerh listenin başına
yazıldı: *"buraya ekleme yapmak envanter güncellemesi DEĞİL, kontrolün
tabanını yükseltmektir."*

📌 Ve listenin en temiz kanıtı kendi başlığında duruyor:
> ***`LiveCaptureScreen` bu listede yoktu — ve onu bağlayan commit'i AYNI
> GÜN ben yazmıştım (L-285).*** Bir elle liste, kendi yazarının aynı gün
> eklediği şeyi bile kaçırır; çünkü **kodun yanında değil, hafızanın
> yanında** durur.

📌 Koordinatörün ④. düzeltmesi kayda geçti: *"kabuktan başlayan KATI
onboarding'i kaçırıyor"* gerekçesi **mekanizmada yanlıştı** — onboarding
zaten **rota açmıyor** (Gravita ve ben bağımsız ölçtük). Hüküm duruyor
(**envanteri tamamlıyor**), gerekçesi düzeldi.

## L-301 — Kapalı-kayıt envanteri: 15 reddedilmiş yol YALNIZ HAFIZAYA bağlı

Choreia bugün **kapalı bir kaydı okumadan** aynı çıkmaz sokağa girdi
(M-F-581). Koordinatör kendi ağacımda envanter istedi.

> ***Kapalı bir kaydı okumamak onu yeniden açmaz — yalnız aynı çıkmaz
> sokağa ikinci kez girer.***

Ve bu, bugün benim yazdığım kuralın **zaman ekseni**: elle liste *kodun
değil hafızanın yanında* durur; **kapalı bir kayıt da öyle durur, üstelik
aylar önce yazıldığı için daha da sessizdir.**

### Ölçüt ÖNCE yazıldı — ve defterimin BİÇİMİNDEN çıktı

Tablo biçimi **altı sütunlu** ve ikisi tam bu soruya ait: **`Durum`** +
**`Kapanış kanıtı`**. Prose başlıklarında **ikisi de yok.** ⇒ ***Kapalılığın
kanıtı biçime göre değişiyor*** (L-294'te ölçtüğüm iki-biçimliliğin sonucu),
o yüzden üç kaynak: **(a) yapısal · (b) dış artefakt · (c) yalnız anlatı.**

### Payda

**305 kayıt** (tablo 256 · prose 49) · `Durum` KAPALI **178** ·
**kanıt sütunu BOŞ 13** (*kapalı deniyor, kanıtı yok*) · AÇIK **62** ·
**(c) yalnız anlatı 49 (%16)**.

### 🔴 Asıl sınıf: düzeltilmiş kusur ≠ reddedilmiş yol

*Düzeltilmiş bir kusur* tekrar edilmez; ***ölçülüp reddedilmiş bir yola
YENİDEN GİRİLEBİLİR.*** Ayrım yapılmasa 178'in hepsi aynı kovada olurdu.

- **20** ölçülüp reddedilmiş yol (yeniden girilebilir sınıf)
- **5**'inin bağlı **kapısı var** · 4'ü dış artefakta bağlı
- ⚠️ **15'inin kapısı YOK** — *ne bir kapı korur, ne bir alan işaretler;
  yalnız okuyanın hatırlamasına bağlı.* **Choreia'nın vakası tam bu sınıf.**

Liste `app/docs/KAPALI-KAYIT-ENVANTERI-2026-08-12.md`de; **hüküm yok,
yeniden açma yok** (sevkin sınırı).

### Sınırlar — adıyla

`.lower()` kullanılmadı. **"Reddedilmiş" süzgeci dizgeye dayanıyor** ⇒
***eksik olabilir, fazla değil*** — bu kelimelerle yazılmamış bir ret kaydı
sayıma girmez. **Prose'un (c)'ye düşmesi yapısal bir sonuçtur**, o kayıtların
kapalı olmadığı anlamına gelmez.

📌 Ve koordinatörün aday-çıkarımımda bulduğu iki artefakt (`#29`,`#53` —
markdown gövdesi, kural değil) + 1 yinelenen kayda geçti: ***bir çıkarıcı,
çıkardığı şeyin BİÇİMİNİ de denetlemelidir*** — benim *"desen, aradığı şeyin
biçimini de tanımlamalı"* kuralımın çıkarım katmanı, ve **bu turda ben
uygulamadım.**

## L-302 — 15'i ELLE OKUDUM: 10'u süzgecimi ÇÜRÜTTÜ (%67)

Koordinatör *"süzgeci genişletme, OKU"* dedi. Okudum.

| sonuç | sayı |
|---|---|
| taranan | **15** (dizge süzgecinin *"kapısız reddedilmiş yol"* dediği) |
| **gerçekten REDDEDİLMİŞ yol** | **5** — `L-115` `L-168` `L-170` `L-171` `L-199` |
| düzeltilmiş kusur çıktı | 7 |
| ürün kuralı cümlesi / tamamlanmış eylem | 3 |
| **elle okuma süzgeci çürüttü** | **10/15 = %67** |

**JabLab'ınki 3/9 (%33) idi; benimki %67.** İkisi de aynı sınıf ama
benimki **iki kat** — çünkü jetonlarım daha genişti (`reddedil` çıplak
hâliyle *"triyaj REDDETTİ"* gibi **ürün davranışı** cümlelerini de yakaladı,
tam JabLab'ın uyardığı biçim).

> ***Bir süzgecin yönü, onu yazanın ölçüsüdür — süzgecin özelliği değil.***
> Ben *"eksik olabilir, fazla değil"* yazmıştım; **kendi ölçütüm için
> doğruydu, ama yönü ölçmemiştim.** Elle okuma gösterdi: **fazla** yakalıyor.

### 🪤 Ve envanterimin ALT KOVALARI AYRIK DEĞİLDİ

`kapılı 5 + dış 4 + kapısız 15 = 24` ama toplam çıkmaz **20**. Kesişim:
`L-168` `L-171` `L-172` — **`.md` uzantısı kapı desenimde yoktu** (yalnız
`.dart/.py/.sh`), o yüzden `docs/`e bağlı kayıtlar *"kapısız"* sayıldı.
→ Gerçek: **kapılı 5 · yalnız-dış 3 · hiçbir bağı yok 12.**

> ***Bir bölmenin toplamı paydayı aşıyorsa, kovalar ayrık değildir*** —
> ve ben bunu **payda denetimini kendi kurduğum turda** kaçırdım.

### ② Otoritenin kendisine yazıldı (M-F-584)

Beş gerçek kaydın `Durum` sütunu artık ayırt edici:
`REDDEDİLDİ — <hangi yol> · <hangi ölçüm>`. Örnek:
- `L-168`: *tam-video referans çıkarımı, BEŞ yol · beş tur ölçüm, beşi de RET*
- `L-171`: *netlik eşiği 40'ın DAYANAĞI · yeniden-türetme ölçümü dayanaksız buldu*
- `L-199`: *karantina ÇEKİMİ yolu · klipler zaten yerel diskteydi*

**Açık kısımlar KORUNDU** (`/ açık (…)`) — kapatma yapılmadı.

> ***Reddedilmiş bir yolu ayırt edilebilir kılmanın en ucuz yolu,
> OTORİTENİN KENDİSİNE yazmaktır*** — sonra hiçbir süzgeç, tarama ya da
> elle okuma gerekmez.

### `kanıt sütunu BOŞ 13` ile kesişim

**1 kayıt:** `L-115` — hem *"kapalı deniyor, kanıtı yok"* hem **gerçek
reddedilmiş yol**. ⛔ Doldurmadım (sevkin sınırı), **sayıldı ve isimlendi.**

Defter bütünlüğü: **256 tablo kaydı** (değişmedi) · tazelik kapısı yeşil.

## L-303 — ÜÇ KUSUR, üçü de ÖLÇÜLDÜ (düzeltilmedi): biri BENİM AKTİF veri hatam

Koordinatör JabLab'ın bulduğu bir biçim kusurunu bildirdi ve *"ölç, düzeltme"*
dedi. Üçü de bende gerçekleşti.

### 🔴 ① SAYAN KELİMEYİ SİLDİM — 178 → 173, ve HİÇBİR KAPI ÖTMEDİ

`Durum` sütununu `REDDEDİLDİ — …` yaptım ve **`kapalı` jetonunu YERİNDEN
ETTİM.** Benim *"kapalı"* tespitim `Durum`da **dizge taraması**
(`kapal[ıi]|kapand[ıi]|çözüldü|düzeltildi`).

**Ölçüm: beş kaydın BEŞİ de jetonu kaybetti** → kapalı sayısı **178 → 173.**

> ***BİR KAYDI AYIRT EDİLEBİLİR KILAN KELİME, ONU SAYAN KELİMEYİ SİLMEMELİ.***

⚠️ **Bu AKTİF bir veri hatası** — defterim şu an kapalı sayısını **5 eksik**
gösteriyor. Düzeltilmedi (sevkin sınırı), **ölçüldü ve isimlendi.**
Doğru biçim: **`REDDEDİLDİ (kapalı) — YOL: … · ÖLÇÜM: …`**

📌 Ve kusur **iyileştirme kılığında** geldi: kaydı **daha okunur** yapan bir
değişiklik, sessizce bir sayıyı düşürdü. ***Bir alana ayırt edici bir değer
eklerken, o alanı OKUYAN her sayacın hangi dizgeye baktığı ÖNCE ölçülür.***

### 🔴 ② ID ÇAKIŞMASI: 256 satır, **253 benzersiz ID**

**`L-187` · `L-089` · `L-090` — üçü de İKİ KEZ.** ⇒ *bir atıf iki kayda
çözülüyor*, ve *"L-090'a bak"* diyen her cümle belirsiz.

### 🔴 ③ TAZELİK KAPIMIN GÜVENCESİ SANDIĞIMDAN DAR — ve sütun indekslemem KAYIYOR

Kapımın deseni `^(?:#+ |\| )(L-\d+)\b` **sütun sayısına BAKMIYOR.** ⇒
güvencesi *"her numara bir KAYITTIR"* değil, ***"her numara kayıt-biçimli
GÖRÜNEN bir satırda geçiyor"***. JabLab'ın vakasıyla aynı katman sınırı.

**Ve daha somut bir sonucu var:** 256 satırın **3'ü 8 sütunlu**
(`L-032` · `L-099` · `L-195`) — metinlerinde `|` geçiyor. Envanterimin
`c[4]`/`c[5]` indekslemesi bu üçünde **yanlış sütunu okudu**:
- `L-195`: ben `yaw` okudum, gerçek durum başka
- `L-032`/`L-099`: `**kapalı**` okudum ama **doğru konumdan değil**

⇒ ***L-301 ve L-302'nin sayıları bu üç kayıt için güvenilmez.*** Payda
etkisi küçük (3/256) ama **yön bilinmiyor**, ve *"küçük" bir hatayı
ölçmeden "önemsiz" demek* bu defterin yasakladığı şey.

> ***Bir satırı sütunlara ayırmak, ayıracının veride GEÇMEDİĞİNİ varsayar.***

## L-304 — Üç ayrışma kapandı; ve (c)'yi kurarken DÖRT KEZ yanlış gerekçe ürettim

Metne karşı bulduğum üç ayrışma, sıraya göre kapatıldı. **KATI 3 · fark 0**
— *(a) hayalet bulmadı, yani bu bir ÖLÇÜM.*

### (c) — gerekçeler artık KODDAN türetiliyor

7 dışlanan, 4 **grup anlatısı** yerine **kalem başına ölçülmüş olgu**:
`kap:4` · `akis_adimi:5` · `hal_kosullu:<gerçek koşul>` ×5. Gerekçesi
ölçülemeyen bir dışlama **kırmızı** (sabotaj: uydurma sınıf → öttü).

Adlandırma Ostinato'nun dersini taşıyor (`unreachable_reason` →
`camera_dependency`): kategoriler **olgu** adı taşıyor, **iddia** adı değil.

### 🪤 VE BU TURUN ASIL DERSİ: dört deneme, dört yanlış gerekçe

| deneme | ürettiği | neden yanlış |
|---|---|---|
| 1 | `_TabMismatchScreen` → **`kap:4`** | koşul deseni bitişik varsayıyordu |
| 2 | `LissomShell` → **`hal_kosullu`** | sıra yanlıştı: koşul, yapıdan önce soruluyordu |
| 3 | 3 hâl ekranı → **`kap:4`** | `body` **tüm dosyayı** alıyordu |
| 4 | ✅ hepsi doğru | yapı-önce + gerçek gövde + iç-parantezli koşul |

> ***Bir sınıfın gövdesi, onu İÇEREN dosya değildir.***
> ***Ayırt edici olan KURULUM KOŞULU değil, sınıfın KENDİ YAPISIDIR.***

Ve üçü de **makul görünen** yanlışlardı — `kap:4` bir hata gibi durmuyor.
Tam olarak sözleşmenin (c) şerhinin yasakladığı şey: ***yanlış bir sebep,
sebepsizlikten daha kötüdür; denetimi doğrulanmış gösterir.*** Ben bunu
**gerekçe üretme mekanizmasını kurarken** üç kez yaptım.

### (a) — iki bağımsız türetim artık UZLAŞIYOR

**YAPI** (`Scaffold` sahibi + kabuk `switch`i) ↔ **AD** (`*Screen|*Page`),
ve **ayrışma KIRMIZI**. Bugün: YAPI 7 · AD 7 · **ayrışma 0**.
Sabotaj: AD türetimine hayalet üye sokuldu → *"ADDA var, YAPIDA yok —
HAYALET ÜYE adayı"*. ⇒ Ostinato'nun `SettingsScreenRoute ≠ SettingsScreen`
sınıfı artık **bende de görünür.**

### (d) — vakum koruması AÇIK, bağımlılık KESİLDİ

Önceden (e)'nin kapsama kontrolü **üzerinden** çalışıyordu: *bugün
korunuyor, yapısal olarak değil.* Artık açık: `derived` boşsa kapı öter.
Sabotaj: YAPI türetimi boşaltıldı → *"VAKUM — bir kapının hiçbir şey
bulmaması, ölçtüğü şeyin yokluğu değildir"*.

**Üç sabotaj AYRI AYRI koşuldu** (*bir beklentiyi başkasının sabotajıyla
kanıtlamak, ikisini tek beklenti saymaktır*). Kapılar: **app 200/200 ·
python 20/21.**

## L-305 — Üç kalem: veri hatası düzeltildi · sütun kayması ÖLÇÜLDÜ · çakışma TAŞINIYOR

### ① Aktif veri hatası düzeltildi: **173 → 178**

Biçim: **`REDDEDİLDİ (kapalı) — YOL: <yol> · ÖLÇÜM: <ölçüm>`** — ayırt edici
**eklendi**, sayan kelime **korundu**. Koordinatörün tahmini birebir çıktı.

**Çapa kuruldu:** `REDDEDİLDİ` yazan her `Durum`, kapalılığı **sayan**
jetonlardan en az birini de taşımalı. Sabotaj: `(kapalı)` silindi →
**kırmızı**, kaydı adıyla saydı.

> ***BİR KUSUR, İYİLEŞTİRME KILIĞINDA GELDİĞİNDE HİÇBİR KAPI ÖTMEZ —
> çünkü kapılar KÖTÜLEŞMEYİ arar, DEĞİŞİMİ değil.***

### ② Sütun kayması: SAYI DEĞİŞTİ, ve iki ayrı sebepten

Choreia'nın *"sondan indeksle"* çözümü **bana uymadı** — ölçtüm:

| yöntem | kapalı |
|---|---|
| naif `c[4]` | 178 |
| **"son-2" sezgisi (Choreia'nınki)** | **176** ⛔ |
| **backtick-korumalı `c[4]`** | **178** ✅ |

**Sebep ölçüldü:** `L-032`/`L-099`'da fazla `|` **kanıt** hücresinde
(`c[4]` doğru), `L-195`'te **bulgu** hücresinde (`c[4]` yanlış).
***Hiçbir konumsal sezgi üçünü birden doğru okumuyor*** — panzehir konum
değil, **ayıracı koruma**.

⚠️ `L-195` maskelemeden sonra da 8 sütunlu (fazla `|` düz metinde). **Sayıma
etkisi YOK** — hem yanlış hem doğru hücre *kapalı değil*. Yani **178 doğru,
ama o satır için ŞANSA doğru.** İsimle bırakıldı.

**L-301/L-302 yeniden koşuldu — DEĞİŞTİ:**
- **reddedilmiş 20 → 21** (`L-032` korumalı ayırmayla ortaya çıktı; **elle
  okunmadı**, yeni aday)
- **kapısız 15 → 14** (`L-168`·`L-171` artık **kapılı** — kapı desenime
  `.md`/`docs/` eklendi; bunlar zaten dış artefakta bağlıydı, **desenim
  görmüyordu**)

> ***BİR SATIRI SÜTUNLARA AYIRMAK, AYIRACININ VERİDE GEÇMEDİĞİNİ VARSAYAR.***

### ③ ID çakışması: TAŞINIYOR, çözülmüyor

`L-089`·`L-090`·`L-187` ikişer kez (256 satır / 253 ID). ⛔ **Yeniden
numaralandırma YOK** — *bir numarayı değiştirmek, ona işaret eden HER atfı
sessizce yanlış yapar.*

**(a) Kapı:** yeni çakışma **imkânsız**; bilinen üçü **SAYILI muafiyet**
(muafiyet büyürse kapı öter — *muafiyet bir kapı değil, bir SAYIDIR*).
Sabotaj: yeni çakışma yaratıldı → kırmızı.
**(b) Şerh:** altı hücrenin **altısına** *"bu numara İKİ kayıtta — atıf
çözerken ikisine de bak"*.

> ***Çözülemeyen bir çakışmayı, ÇÖZÜLEMEZ olduğu BİLİNEREK taşımak.***

## L-306 — `L-032` elle okundu: REDDEDİLMİŞ YOL DEĞİL (aday elendi)

`reddedilmiş 20 → 21` artışının tek kalemi `L-032`ydi ve **elle okunmamıştı.**
Okudum.

**Bulgu:** wellness süzgeci bir dosyayı *"taradı ve temiz dedi"* ama içinden
**hiç metin çıkarmamıştı** (alan listesi içerik şemasını kapsamıyordu → 72
hareketlik dosyadan **0 string**, sonuç yeşil).
**Kanıt:** **üç katmanlı düzeltme** — alan listesi genişletildi (gerçek
tarama **410 metin**, 0 ihlal) · **yapısal koruma** (metin çıkmazsa çıkış
kodu 3) · öz-teste **iki regresyon vakası** (öz-test 8 vaka, hepsi geçiyor).

⇒ **DÜZELTİLMİŞ KUSUR.** Reddedilmiş bir yol değil — bir kör nokta bulundu
ve **kapatıldı.**

### 🪤 Tetikleyen jeton ölçüldü: `çıkmazsa`

> *"…bir dosyadan hiç metin **çıkmazsa** süzgeç çıkış kodu 3 verir…"*

**Fiil**, isim değil — *"çıkmaz sokak"*la hiçbir ilgisi yok. Tam JabLab'ın
uyardığı biçim: ***çıplak bir jeton, ürün davranışı düzyazısında geçer.***

📌 **Ve artışın kaynağı öğretici:** `L-032`yi **korumalı ayırma ortaya
çıkardı** — naif ayırma kanıt hücresini `config/content|tests|copy`
borusunda **kesiyordu**, yani jeton görünmüyordu. ⇒ ***Bir ölçüm aracını
düzeltmek, yanlış pozitifleri de görünür kılar; artan sayı bir BULGU
değil, aracın YENİ GÖRDÜĞÜ olabilir.***

**DÜZELTİLMİŞ SAYI: reddedilmiş 20 → 21 → (elle okuma sonrası) 20.**
`L-032` **aday olarak elendi** ve bu **adıyla yazıldı** — yazılmasaydı bir
sonraki tarama onu **yeniden aday** yapardı. *Bir adayın elenmesi de bir
ölçümdür.*

**`Durum` sütununa DOKUNULMADI** — `L-032` zaten `**kapalı**`, ve
*düzeltilmiş kusur* olduğu için `REDDEDİLDİ` etiketi **almaz.**

---

## L-307 — Kendi mührümü daralttım: **ölçtüğüm KÜME ile yazdığım cümlenin kümesi aynı değildi**

**Durum:** **kapalı** · **Kapanış kanıtı:** aşağıdaki ölçüm + üç dosyada düzeltme
**Tetik:** kapanış sonrası `🚀 Başlangıç Promptu` tazelenirken tablo satırı
**3** (`invert` korumasız) ile devir notunun ⓐ kovası (*"kod tarafında
ölçülebilir kalem kalmadı"*) **çelişti**.

**Ölçüm (ve iki tuzak):**
1. İlk tarama `packages/lissom_engine/...` yoluna baktı — **o yol YOK**
   (gerçeği `app/packages/…`), `2>/dev/null` hatayı yuttu ⇒ **boşlukta sıfır**.
2. `--include=*.dart` **tırnaksız** yazıldı; zsh glob'ladı, komut düştü.
3. Pozitif kontrolden sonra (`LissomShell` 45 isabet / 87 dart dosyası):
   `metric_coverage_test.dart` ~L110 **kendi gövdesinde** yazıyor:
   *"`invert` hiçbir kontrolle korunmuyor (AÇIK boşluk, bu tur kapatılmıyor)"*.
   8 binding'in **hepsi** `invert: false` ⇒ yanlış bir `true` **sessizce geçer**.

**Kusur BENDE:** ölçtüğüm küme **yayın engelleriydi**; yazdığım cümle
**kodun tamamıydı**. Koordinatörün tekrar eden uyarısının aynısı:
***sınırı GENİŞ yazmak DAR yazmak kadar pahalı.***

**Yayılma:** hatalı cümle üç yerde vardı — devir notu **tek cümlelik hüküm**,
devir notu **ⓐ kovası**, prompt **İLK İŞ bloğu**. Üçü de daraltıldı; ⓐ'ya
iki kalem **isimle** yazıldı (`invert` · köprülenemeyen `measureKind`
metrikleri + Library/Progress derinliği).

⇒ ***Bir iddiayı kaynağında daraltıp türevlerini bırakmak, düzeltmeyi
GERİ ALIR: bir sonraki oturum hangisini okuyacağını seçmez, ÖNCE
rastladığını okur.***

📌 **Kalıcı kural adayı (aileye):** **Bir kapanış cümlesi, ÖLÇÜLEN kümenin
adını taşımalı** — *"yayın engeli kalmadı"* ile *"kod kalmadı"* aynı ölçümden
çıkmaz. Kapanış notlarında **kümenin adı cümlenin içinde** geçsin.

## L-308 — iOS pod durumu **BAYATTI** ve bunu bir kapı değil, bir A11 koşumu buldu

**Durum:** **kapalı** · **Kapanış kanıtı:** `pod install` çıktısı commit'lendi
(`ios/Podfile.lock` + `ios/Runner.xcodeproj/project.pbxproj`), aşağıdaki ölçüm
**Tetik:** A1–A12 mesafe ölçümünde `flutter build ios --release --no-codesign`
(A11 kalemi) koşuldu; koordinatör kapanışta **`kirli=2`** ölçtü.

**Ve önce BENİM kusurum, adıyla:** *"tek dosya değişmedi, `git status` hâlâ
temiz"* dedim — o ölçüm **turun BAŞINDAydı**, derlemeden önce.
⇒ ***Bir kapanış iddiası, turun başındaki bir ölçümle kurulamaz: tur, o
ölçümü GEÇERSİZLEŞTİRMEK için vardır.*** (`L-307`'nin ikizi — orada eksik olan
kümenin ADI'ydı, burada ölçümün ANI.)

**Ölçüm — iki dosya, ve ikisi de gürültü DEĞİL:**

1. **`ios/Podfile.lock`** — `permission_handler_apple (9.4.8)` **eklendi**.
   Commit'li lock `ddd6c25`ten; `permission_handler` pubspec'e `0b911ae`
   (SIRA②) ile girdi ⇒ **lock, sevk edilen bir bağımlılığı hiç görmemiş.**
   Paket `lib/`de **üç dosyada** kullanılıyor (`onboarding_flow` ·
   `live_capture_screen` · `camera_pose_source`), yani test-only değil.
   ***Sevk edilen bir bağımlılığı kilitlemeyen bir lock, kilit değildir.***

2. **`ios/Runner.xcodeproj/project.pbxproj`** — iki AYRI değişiklik aynı diff'te:
   - ✅ **`[CP] Copy Pods Resources` fazı EKLENDİ.** Commit'li dosyada
     **0 isabet** (pozitif kontrollü: dosya 30.779 bayt / 721 satır,
     `PBXShellScriptBuildPhase` 6 · `Thin Binary` 3 · `PrivacyInfo.xcprivacy`
     4 isabet ⇒ **0 gerçek ölçüm, "boşlukta sıfır" değil**). Bu faz, pod
     kaynak paketlerini uygulamaya kopyalayan fazdır — ve A8 ölçümümde
     `Runner.app/permission_handler_apple_privacy.bundle/PrivacyInfo.xcprivacy`
     **paketin içinde bulundu**, yani o bundle oraya **bu faz sayesinde**
     giriyor.
   - ⚪ `9F1PRIV0001/0002` satırları **yer değiştirdi** — Xcode'un alfabetik
     yeniden sıralaması, **anlamsız**. Ayıklanmadı: üretilmiş bir dosyanın
     içinden elle satır ayıklamak, kusurun kendisinden pahalı.

**KARAR: COMMIT (geri alma DEĞİL), sebebiyle.** Geri almak **bayatlığı geri
getirirdi** ve ölçümü görünmez kılardı. `pod install` her makinede yeniden
üretir — ama *"araç yeniden üretir"* ile *"depo doğru"* **aynı şey değildir**:
ikincisi denetlenebilir, birincisi yalnız umut edilir.

**🔴 VE HİÇBİR KAPI ÖTMEDİ.** `pubspec.yaml` bir pod bağımlılığı kazandı,
`Podfile.lock` bayatladı, ve 21 kapının hiçbiri bunu ölçmüyor. Bu, bu hattın
sistematik olarak avladığı sınıfın iOS paketleme katmanındaki hâli
(`L-288`in ikizi: *dosya depoda durur, `git` mutlu, kimse fark etmez*).
⇒ **Kapı adayı sıraya alındı, bu turda KURULMADI** — kurulursa hangi A
kalemini doğrulayacağı önce yazılacak (ölçüt kısıtı: *bir kapı, ancak A
tablosundaki bir kalemin iddiasını doğruluyorsa kurulur*).

📌 **Ölçütün kendi boşluğu (koordinatör kayda geçirdi):** *"salt okuma"* bir
**niyet** beyanıdır; **A11 tanım gereği depoyu kirletir** (iOS'ta `pod install`
⇒ `Podfile.lock` + `project.pbxproj`). Kural aracı hesaba katmıyordu.

## L-309 — **A1 KAPANDI**: iki yeşil yarım bir köprüyle tek yürüyüş oldu

**Durum:** **kapalı** · **Kapanış kanıtı:** `test/full_flow_walk_test.dart`
2/2 yeşil; `all_gates.py` **exit 0** (app **200→202** · engine 109 · python 20/21)
**Tetik:** A1–A12 mesafe ölçümü A1'i `⛔` ölçtü; koordinatör sırayı onayladı.

**Ölçülen boşluk (ve bu bir SAYIYDI, sezgi değil):**
`grep -rl "onboarding.continue" test/` **5** · `grep -rl "liveCapture.finish"
test/` **2** · **kesişim BOŞ.** Pozitif kontrol: iki tarama da dolu döndü ⇒
boşluk gerçekti, aletin körlüğü değil.

> ***İKİ YEŞİL YARIM BİR YEŞİL BÜTÜN DEĞİLDİR — aralarındaki dikiş
> hiçbirinin testinde geçmez.***

**Köprü: yeni desen İCAT EDİLMEDİ, var olan uzatıldı.**
`LiveCaptureScreen.sourceOverride` **zaten vardı**; ona ulaşamayan
`HomeScreen`di. Dikiş `ageBand`ın izlediği yoldan geçirildi —
`OnboardingGate → LissomShell → HomeScreen → LiveCaptureScreen` — ve
`storeLoader`/`shellLoader` sözleşmesiyle aynı: **yükleyici çağırana ait.**

**İki adlandırma kararı, ikisi de gerekçeli:**
1. **`…Loader` = FABRİKA, `…Override` = ÖRNEK.** `poseSourceLoader` bir
   `PoseSource Function()` — çünkü `FakePoseSource` akışı **TÜKETİR**; tek
   örnek paylaşılsaydı ikinci ölçüm sessizce olaysız açılır ve yürüyüş
   *"kaynak kuru"* hâlini **ürün kusuru** sanardı.
2. **`sessionStoreLoader`, `storeLoader` DEĞİL** — o ad bu ağaçta
   `OnboardingStore` için kullanılıyor. İki ayrı depo aynı adı taşısaydı, bir
   katman yukarıda hangisinin geçtiği **okunarak ayırt edilemezdi.**

**Üretimde davranış DEĞİŞMEDİ:** iki alan da `null` ⇒ ekran kendi
varsayılanlarını kurar (`CameraPoseSource` / `openSessionStore`).
*Enjeksiyon yürüyüşü mümkün kılar, davranışı değiştirmez.*

**Yürüyüşün ölçümü:** taze kurulum (bayrak `false`, onboarding **düğmeyle**
7 dokunuş) → Home → *Start a measurement* → **1 rota push'u tanıklı** →
enjekte kaynak → *I'm done* → **sonuç yüzeyi** → **depoya 1 kayıt**
(`active_straight_leg_raise:right`, canlı **3/12**).

**🔒 SABOTAJ İKİZİ — yürüyüşün kendisi vakum-doğru DEĞİL:** aynı yol, tek
farkla boş kaynak script'i ⇒ `liveCapture.finish` **görünmüyor**, depo
**boş**. > ***Bir yürüyüşün başarısı, ancak BAŞARISIZ OLABİLDİĞİ
gösterildiğinde ölçümdür.***

**⚠️ SINIR — DAR yazıldı (L-307'nin dersi):** bu yürüyüş **kamerayı
kanıtlamaz.** Kaynak `FakePoseSource`; gerçek kare akışı, gerçek ışıkta
landmark kalitesi ve kalibrasyon eşiği hâlâ **cihazda doğrulanmadı**
(*"Bağlandı ≠ canlı"* aynen geçerli, **A12 açık**). Kanıtlanan tam olarak
şu: ***kullanıcının bastığı düğmeler, taze bir kurulumdan bir ölçüm
sonucuna kadar birbirine bağlı.***

🪤 **Ve bir tuzak ödendi:** `_RecordingStore` ilk yazımda `SessionStore`un
üç üyesini (`recent` · `workedSecondsFor` · `unreadableRecords`) taşımıyordu
ve dosya **derlenmedi**. `unreadableRecords` için `0` bir varsayılan değil
**BEYAN** olarak yazıldı (çekirdeğin kendi hükmü, M-F-228).

## L-310 — **A4 KAPANDI**: dağılım yazıldı, ve devir notunun tanımadığı bir sınıf çıktı

**Durum:** **kapalı** · **Kapanış kanıtı:** `test/deadend_taxonomy_test.dart`
3/3 yeşil + `docs/A4-CIKMAZ-SOKAK-SAYIMI.md`; `all_gates.py` **exit 0**
(app **202→205** · engine 109 · python 20/21)
**Tetik:** `AJAN-DEVRI-LISSOM.md` §3 ⓷ — *"A4 — dağılımı yaz (§4'te sayılar hazır)"*.

**Ön-girdi TEYİT EDİLDİ, yerine geçirilmedi — ve bir sınıf eksikti.**
Devir notu **00:37**'de yazıldı, ölçütün **`E` = `awaiting-capability`** sınıfı
**00:44**'te eklendi (Ostinato ölçtü, kabul edildi). Devrin §4 dağılımı A/B/C/D
taksonomisiyle kurulmuş ve 9 engelli testi *"çıkmaz sokak değil"* diyerek
**sınıfsız** bırakmıştı. Yedi dakikalık bayatlık, bir sınıfın tamamını görünmez
kılıyordu.

> ***BİR ÖN-GİRDİ, YAZILDIĞI ANDAKİ TAKSONOMİ KADAR GEÇERLİDİR.***

**Ölçüm (yürüyerek, iki payda, işlemiyle):**
· **Aile düzeyi** payda **6** − başlatılabilir **1** = **çıkmaz 5**,
  dağılım `A=5 · A′=0 · B=0 · C=0 · D=0 · E=0`.
· **Test düzeyi** payda **12** = canlı **3** ⊎ engelli **9**; **çıkmaz 0**,
  engellilerin sınıfı **E**, beyansız **0**.

**Sınıf benim yorumum DEĞİL, ürünün kendi beyanı.** Aile düzeyinde
`LibraryFamily.itemsSource` (*"isimlendirilmiş ≠ inşa edilmiş"*), test düzeyinde
`BridgeBlocker`ın dört sınıfı — dördü de *"çekirdekte bu ölçü tipi/referansı
YOK"* diyor, yani **alet** eksikliği, içerik değil. Beyansız bir metrik çıkarsa
test kırmızı yanar ve o test `E` **sayılmaz**.

**Devrin bir cümlesi ölçümle daraldı:** *"5 aile = coming_soon, yalnız çocuk
adları"* — `breath_meditation`ın **çocuğu da yok** (`NamedGapCard` yolu).
Sınıf değişmedi (**A**), **gerekçe metni** değişti: beşi tek kalıba sokan cümle
dördü anlatıyordu.

**"Dokunulamaz satır" bir İDDİAYDI — ölçüldü.** Devir 9 engelli testi
*"dokunulamaz `_TestRow`"* diye çıkmaz sayımından çıkarıyordu. Test artık hem
**canlı** hem **engelli** bir satıra **basıyor** ve rota derinliğinin
değişmediğini ölçüyor. *Bir satırın hedefe dönüşmesi sınıflandırmayı
değiştirir: içeriksiz bir HEDEF çıkmaz sokaktır, içeriksiz bir SATIR değildir.*

**🔒 `C` sınıfı KASITLI olarak türetilmiyor — ve bu bir eksiklik değil, ölü-dal
reddi.** *"Kutusuz aile"* yüklemi yazılabilirdi ama `LibraryIa` kutusuz bir
aileyi zaten **ayrıştıramıyor** (tip düzeyinde zorlanıyor) ⇒ dal **hiçbir zaman
ateşlenmezdi**, `L-011`in ölü metriğiyle aynı sınıf. `C = 0`ın dayanağı bir
yüklem değil, IA config'te **beyan edilmiş kapsam standardı**. Ve kural tablosu
kendi ölü-dal sınavını taşıyor: altı olgu demeti, beş sınıf ötüyor.

**🔒 ANKRAJ — doküman sessizce bayatlayamaz.** Sayılar dokümandan **okunuyor** ve
türetilene karşı sınanıyor (dokümanı türetimden üretmek ters yön olurdu: kimse
yeniden üretmeyi unuttuğunda sessizce bayatlardı). **Sabotaj ikizi koşuldu:**
`aile.A 5→4` ve `test.canli 3→2` **ayrı ayrı** kırmızı yaktı, sonra geri alındı.

**⚠️ SINIR — DAR yazıldı.** Bu sayımın paydası **içerik VAAT EDEN hedefler**
(aile hedefleri + batarya testleri). Sözleşmenin aday kümesindeki kalan beş
yüzey (`HomeScreen` · `ProgressScreen` · `ProfileScreen` ·
`WhatLissomDoesntDoScreen` · `LiveCaptureScreen`) sayıma **girmedi** ve
**`0` değil `bilinmiyor`** yazıldı. Sebebi isimli: bir **beyan ekranı** tanım
gereği terminaldir; onu *"öğe sunmuyor"* diye çıkmaz saymak ölçütün açıkça
yasakladığı **yanlış sebebi** üretirdi. ⇒ *"Terminal beyan ekranı çıkmaz sokak
mıdır?"* bir **ölçü tanımı** sorusudur → **koordinatöre**.

## L-311 — **A6 KAPANDI**: ikinci yön açıldı, ve BİRİNCİ yönün deliği oradan göründü

**Durum:** **kapalı** · **Kapanış kanıtı:** `app/tools/defter_freshness.py`
öz-test **8/8** (4/8 bu turda eklendi) · `all_gates.py` **exit 0**
(app 205 · engine 109 · python 20/21)
**Tetik:** `AJAN-DEVRI-LISSOM.md` §3 ⓶ — *"A6 — ikinci yön (§5'i ÖNCE oku)"*.

**🔴 ASIL BULGU, ARANMAYAN YERDEN GELDİ: bu kapı gerçek bir gediği KAÇIRIYORDU.**
`L-208` — **iki commit** iddia etti (`fb701fa`, `ddd6c25`) ve defterde
**hiçbir biçimde kaydı yoktu**. Komşuları (205·206·207·209·210·211·212)
yerindeydi ⇒ toplu kayıp değil, **tek bir düşme**. Kapı bunu göremiyordu
çünkü okuyucusu yalnız conventional-commit KAPSAMINA bakıyordu
(`fix(L-280):`), o iki commit ise numarayı **kuyruğa** yazmıştı.

**Okuyucunun ölçümü (M-F-588 canlı):** 186 commit'te numara —
kapsamda **47** · başlıkta herhangi bir yerde **102** · başlık+gövdede **193**.

> ***BİR KAPI, EN ÇOK, BAKMADIĞI DİZGEDE KÖRDÜR — VE ORADA KÖR OLDUĞUNU
> KENDİ YEŞİLİ SÖYLEMEZ.***

`L-208` geri yazıldı, **içeriği uydurulmadan**: yalnız git'ten doğrulanabilir
olan (iş = `live_session_state.dart` beş mühürlü hâl + export + test) ve
orijinal metnin **kayıp olduğu** kaydedildi.

**TERS YÖNÜN BİRİMİ — üç kez daraltıldı, her adım ölçüldü:**

| birim | gedik | hüküm |
|---|---|---|
| defterdeki her kayıt | **262** | ⛔ kapı doğduğu gün susturulur |
| gövdesinde repo dosyası ANAN kayıt | **99** | ⛔ hâlâ gürültü (ölçüm kayıtları da dosya anar) |
| **`Kapanış kanıtı` alanı repo KOD dosyası anan kayıt** | **6** | ✅ taşınabilir |

Son daraltmanın gerekçesi yapısal: `Kapanış kanıtı` kaydın *"ne ürettim"*
beyanıdır — ölçüm kaydı oraya çıktı yazar (`/tmp/…json`, *"kod okuması"*),
kod kaydı **repo yolu** yazar. Gövdenin geri kalanı ANLATIDIR ve
*bir dosyadan söz etmek onu değiştirmek değildir* — kapının kendi
*"sözünü etmek ≠ iddia etmek"* kuralının **defter tarafındaki karşılığı**.
`.md` kanıtı bilerek KOD sayılmıyor; bu tek ayrım 99 ↔ 6 farkını üretti.

**Kalan 6 (`L-053`·`L-159`·`L-213`·`L-215`·`L-216`·`L-218`) bir hedef değil
TABAN:** `IZSIZ_KOD_KAYITLARI` **SAYILI muafiyet**, kapı **büyümeyi** yakalar
(`BILINEN_CAKISMA` ile aynı idiom). Küçülürse haber verir, düşürmez.

**🔒 ÖZ-TEST 4 → 8, ve ARTIK VARSAYILANDA KOŞUYOR.** `all_gates.py` kapıları
**argümansız** çağırıyor ⇒ `--self-test` arkasındaki her kontrol tam cümleye
**hiç girmiyordu** (devir ⓸). Bu turda dört yeni kontrol eklendi (geniş
okuyucu aile kaydına sızmıyor · aralık `L-208..211` açılıyor · doküman kanıtı
kod sayılmıyor · sentetik izsiz kayıt yakalanıyor) ve hepsi varsayılan koşuma
alındı — sıra da anlamlı: **önce alet sınanır, sonra ölçüm yapılır.**

> ***BAYRAK ARKASINDAKİ BİR ÖZ-TEST, VARSAYILAN KOŞUMDA OLMAYAN BİR
> ÖZ-TESTTİR.***

🪤 **Ödenen tuzak:** geniş okuyucunun ilk hâli `\bL-\d+` idi ve **aile
kayıtlarının içine düştü** (`M-L-01` → `L-01`) — var olmayan bir numara
uydurup kapıyı sonsuza dek kırmızı yakacaktı. Sınır koruması
(`(?<![-A-Za-z0-9])`) + öz-testi eklendi.

**⚠️ TAŞINAN (bu tur kapatılmadı):** kalan **5 kapının** öz-testi hâlâ
yalnız `--self-test` ile ateşleniyor (`direction_check` · `noverdict_liveness`
· `reachability_candidates` · `status_weave_check` ·
`validate_placeholder_surface`) — A5 şerhi **daraldı, kapanmadı**.

🪤 **İKİNCİ tuzak, ve kapının kendisi ötürttü: kapı KENDİ COMMIT'İNİ
KİLİTLİYORDU.** Ters yön ilk hâliyle bu kaydın (`L-311`) üzerinde ötüyordu —
kayıt deftere yazılır, izini **commit** taşıyacaktır, ama `pre-commit` kancası
commit **var olmadan** koşar. Kapı, kanıtını üretecek adımı engelliyordu.

> ***BİR KAPI, KENDİ KANITINI ÜRETECEK ADIMI ENGELLİYORSA, ÖLÇMÜYOR
> DEMEKTİR — YASAKLIYORDUR.***

Çözüm muafiyet değil **sıra kuralı**: izlenen en yüksek numaradan sonraki
kayıtlar *uçuşta* sayılır. Zayıflatmıyor — uçuştakileri commit'lemeden bir
sonrakini commit'lersen taban yükselir ve **hepsi birden gedik olur**; yani
biriktirme yakalanır, yalnız **anlık** olan affedilir.

🪤 **Üçüncü tuzak, öz-testin kendi içinde:** *"tavan altı ötüyor mu"* sınavını
`L-{tavan−5}` ile yazdım ve o numara **gerçekten commit'liydi** ⇒ küme boş
çıktı, sınav **vakum-doğru** oldu ve kapı kendini *"sahte kapı"* diye suçladı.
Sentetik girdi, gerçek kümeyle **çakışmayan** bir numara olmak zorunda
(`L-000`). *Bir öz-testin girdisi, ölçtüğü dünyadan bağımsız seçilmezse,
öz-test dünyanın bir kopyasını değil bir gölgesini sınar.* Öz-test **9/9**.

## L-312 — Kendi kapımı bir tur sonra düzelttim: **iki yön, iki okuyucu**

**Durum:** **kapalı** · **Kapanış kanıtı:** `app/tools/defter_freshness.py`
öz-test **9/9**, iki yön de yeşil
**Tetik:** `L-311` push'landıktan **sonra** kapı kırmızı yandı — ve gedik
**benim kendi commit mesajımdı.**

**Ne oldu:** `L-311`in commit gövdesinde öz-test girdisi olarak `L-000`
geçiyordu. Tek okuyucu (başlık+gövde) iki yönde birden kullanılınca, gövdedeki
o **anma** YÖN-1'de bir **İDDİA** sayıldı ⇒ kapı, hiç var olmayan bir kaydı
arayarak öttü.

> ***SÖZÜNÜ ETMEK ≠ İDDİA ETMEK — VE BU KURAL, KAPIYI GENİŞLETİRKEN EN KOLAY
> UNUTULAN YERDE, GÖVDEDE ÇİĞNENİR.***

Kapının **kendi dokümanında yazılı** olan kural buydu (tuzak 1), ve ben onu
okuyucuyu genişletirken çiğnedim. *Bir kuralı yazmış olmak, onu genişletme
anında hatırlayacağın anlamına gelmiyor.*

**Çözüm — ayrım GEREKÇELİ, muafiyet değil:** iki yön **iki farklı soru**
soruyor, o hâlde iki farklı dizgeye bakarlar.

| yön | soru | okuyucu | sayı |
|---|---|---|---|
| **YÖN-1** | *bu commit hangi kaydı YAPTIĞINI söylüyor?* | **yalnız başlık** | 109 |
| **YÖN-2** | *bu kaydın git'te herhangi bir İZİ var mı?* | başlık **+ gövde** | 195 |

Ve bu ayrım defter tarafındakinin **birebir aynası**: `Kapanış kanıtı` = iddia,
gövde = anlatı. Aynı sınır, iki kaynakta.

🪤 **Üçüncü tuzak, ve ikinci çarem birinciyi çürüttü:** öz-testin "tavan altı"
girdisini önce `L-{tavan−5}` yazdım (gerçekten commit'liydi ⇒ vakum-doğru),
sonra çare diye `L-000` **sabitledim** — ve o numarayı bir commit mesajında
andığım an YÖN-2 okuyucusu onu **ize** çevirdi. Girdi artık ölçtüğü kümeden
**türetiliyor** (tavan altındaki en büyük KULLANILMAMIŞ numara).

> ***BİR ÖZ-TESTİN SENTETİK GİRDİSİ ELLE SEÇİLEMEZ: ÖLÇTÜĞÜ KÜMEDEN
> TÜRETİLMEZSE, ER GEÇ O KÜMENİN ÜYESİ OLUR.***

📌 **Aile adayı:** bu üç tuzağın ortak sınıfı — *bir kapıyı genişletmek, onun
kendi varsayımlarını yeniden sınamayı gerektirir; genişleme, eski
gerekçelerin geçerlilik alanını sessizce aşar.*

---

## L-313 — A12'nin engeli **imza değildi**: yanlış dizinden ölçülmüş bir yokluk

**Durum:** **kapalı** (engelin KİMLİĞİ) · **açık** (A12'nin kendisi — onay bekler)
**Kapanış kanıtı:** `app/tools/a12_device_preflight.sh` öz-test **2/2** ·
tam koşum **geçen 7 · düşen 0 · onay bekleyen 3** (`exit 2`) ·
`xcodebuild … -destination 'generic/platform=iOS'` → **`** BUILD SUCCEEDED **`**
**Tetik:** devir promptunun *"engel imza, B1/B7 — kurucuda"* iddiasını teyit
etmeye çalışmak.

**Ne oldu:** İddia şuydu: *"makinede kurulu **tek** provizyon profili
`com.yulalab.burunfarki`; `com.yulalab.lissom` YOK."* Ölçüm **yanlış dizinden**
kurulmuştu — `~/Library/MobileDevice/Provisioning Profiles/` (eski) okunmuş,
Xcode 26 ise `~/Library/Developer/Xcode/UserData/Provisioning Profiles/`
kullanıyor. Gerçek: **1 değil 9** iOS profili, ve joker `T5HZGYBWK8.*`
`com.yulalab.lissom`u **kapsıyor** (geçerlilik 2027-05-12).

⇒ **İmzalı cihaz derlemesi bugün geçti**, hiçbir kurucu eylemi olmadan:
`codesign` `Identifier=com.yulalab.lissom`, `TeamIdentifier=T5HZGYBWK8`.

> ***YANLIŞ YOL + SESSİZ HATA = BOŞLUKTA SIFIR*** — bu benim **kendi kayıtlı
> tuzağım** (`packages/…` ↔ `app/packages/…`), bu kez profil dizininde.
> ⇒ ***TEŞHİS, BAĞIŞIKLIK DEĞİLDİR.***

🔬 **Ve yanlışı YAKALAYAN ŞEY ENVANTER DEĞİLDİ.** Kendi açtığım envanter
turu da eski dizine baktı ve *"1 profil"* dedi — yani hatayı **ben de
yeniden ürettim**. Açan şey **imzalı derlemeyi fiilen koşmaktı.**
> ***BİR ENVANTER, NEREYE BAKTIĞINI DOĞRULAMAZ; ÇALIŞTIRMAK DOĞRULAR.***

**Gerçek engel — ölçüldü, ve imza değil:** joker profilin `ProvisionedDevices`
listesinde **1 cihaz** var ve o, bağlı telefon değil
(`00008132-001A70163AD3801C` ↔ bağlı `00008120-001804D83E13C01E`). **Ama**
bağlı telefon takıma **KAYITLI** — 9 profilin **4'ünde** görünüyor. Portal
cihaz kaydı **gerekmiyor**; eksik olan tek teknik şey jokerin **tazelenmesi**,
onu da `-allowProvisioningUpdates` otomatik yapıyor.

⇒ Kurucudan istenen **"imza altyapısı kur"** değil, **iki onay**:
① profil tazeleme (Apple hesabına yazar) ② kişisel telefona kurulum.
> ***KURUCUDAN İSTENEN ŞEYİN BOYU, ÖLÇÜLMEMİŞ BIRAKILAN ŞEYİN BOYUDUR.*** (6.11)

📊 **AYNI SINIF, BEŞ HATTA TARANDI:** beş Motion app'inin **beşi de**
`T5HZGYBWK8` takımında (`choreia` · `gravita` · `jablab` · `ostinato` ·
`lissom`). Joker profil **beşini de kapsar** ⇒ *"provizyon profili yok"* diye
yazılmış her A12 engeli **beş hatta da yeniden ölçülmeli.** Koordinatöre
bildirildi. *(Bir vaka düzeltilir; bir sınıf taranır.)*

🪤 **Kendi paydamı da düzelttim:** `ls | wc -l` **10** diyordu, betiğin
`grep -c '\.mobileprovision$'` süzgeci **9**. Fark bir **macOS**
`.provisionprofile` girdisiydi — *`ls` GİRDİ sayar, profil değil.* İlk
raporumda 10 yazmıştım; sayı **9**.

**Kurulan alet — ve neden KAPI DEĞİL:** `tools/a12_device_preflight.sh`
`all_gates.py`e **eklenmedi**. Bugün NO-GO/ONAY-BEKLER döndüğü için
tam-cümleye girseydi 21 kapılık yeşili **kalıcı kırmızıya** çevirirdi.
> ***BİR KAPI KENDİ ÜRÜNÜNÜN İLERLEMESİNİ CEZALANDIRIYORSA, ÜRÜNÜN DÜŞMANIDIR.***
Öz-testi **yanlış çıkabildiğini** kanıtlıyor: uydurma bundle + uydurma cihaz
⇒ ötüyor; ve vakum koruması profil dizininin dolu olduğunu ayrıca sınıyor.

🔴 **A12 BİR ONAY KUTUSU DEĞİL — ürünün kendi dürüstlük metnini sınıyor.**
`surfaces.dart`/`CaptureUnavailableNote` kullanıcıya şunu **yazıyor**:
*"This has not been tried on a real phone: camera permission, frame quality,
and calibration still need a device pass."* A1 `FakePoseSource` ile kapandı;
**gerçek kamera yolu hâlâ ölçülmedi.** Cihaz koşusu geçerse o cümle
**değişmeli**; geçmezse ürün **yayına hazır değil.**

**C durma koşulu — bu tur:** `⛔ → ✅` = **0**. A12 kapanmadı; kapanan şey
**engelin kimliğiydi**, ve o bir `bilinmiyor → ölçüldü`dür, C sayacına
**girmez**. Sayaç **1**. Koordinatöre bildirildi.

---

## L-314 — `invert` sessiz-geçişi kapandı, ve kapının kendi başlığı bayat çıktı

**Durum:** **kapalı** · **Kapanış kanıtı:** `kSealedBindingInvert` +
5 yeni test · engine **114/114** (taban 109) · **İZOLE GERÇEK SABOTAJ**:
`metric_bridge.dart:279` `invert: false→true` ⇒ **tam 1 test düştü**
(113 geçen + 1 düşen = 114), ve düşen test **benimki**.
**Tetik:** ⓐ kovasından devredilen açık — mühür yalnız `metric→coreJointId`
koruyordu, 8 binding'in hepsi `invert: false` ⇒ yanlış bir `true` SESSİZCE
geçerdi.

**Neden bu bir kusur:** ters bir işaret **fırlatmaz**. `metric_bridge.dart`
başlığının kendi ölçümü: çevrim sayıları ters çevirir (aşağı=180°,
yukarı=0°) ve bu **makul GÖRÜNEN** bir sayıdır ⇒ *testsiz fark edilmez.*
Kusurun biçimi **sessiz yanlış sayı**, ve o sayı **kullanıcıya gösteriliyor.**

**İki sabotaj koştum, ve İKİNCİSİ kanıt oldu:**

| # | hedef | düşen kapı | okuma |
|---|---|---|---|
| 1 | `shoulder_flexion_right` (satır 247) | **3** | ⛔ İZOLE DEĞİL — hangisinin ötüğü belirsiz |
| 2 | `hip_flexion_left` (satır 279) | **1** | ✅ yalnız benim mührüm |

Birinci hedef **davranışsal çapası olan tek binding**ti; sabotaj `real_replay`
konvansiyon testini ve fixture replay'i de kırmızı yaptı.
> ***ÖTME KANIT DEĞİL, ÖTME SEBEBİ KANITTIR*** — kural 2.11'i **kendi
> sabotajımda** yaşadım: ilk vaka üç kapıyı birden kırdı ve *"mührüm
> çalışıyor"* diye okunabilirdi. İkinci vaka, **başka hiçbir koruması
> olmayan** bir binding'i seçtiği için kanıt oldu.

⚠️ **Sabotajın İNDİĞİ ayrıca doğrulandı** (`grep -q 'invert: true,'`) —
Choreia'nın kazası: inmeyen bir sabotajın yeşili *"kapı bozuk"* diye yazılır.
Geri alma **satır bazında** (`sed '279s/…/…/'`), dosya bazında değil (6.7);
`git status` ile `metric_bridge.dart` **temiz** doğrulandı.

## 🔴 ARANMAYAN YERDEN ÇIKAN BULGU — kapının BAŞLIĞI yalanmış

Dosya başlığı *"öz-test grubu **üç** sabotaj vakasını kırmızı yaptırıyor"*
diyordu. Saydım: **11**. Yani sayı **benim eklememden ÖNCE de 8**'di —
cümle **zaten yanlıştı** ve *hiçbir kapı ötmemişti*, çünkü **bir yorum
yanlışsa hiçbir şey ölçmez.**

> ***BİR SAYI ÇAPASI, DENETLEDİĞİ ŞEY BÜYÜDÜKÇE SESSİZCE YANLIŞLAŞIR***
> (kural 4.5) — ve *bir belgenin sayısını YAZMAK, onu DENETLEMEK değildir.*

**Çare sayı düzeltmek DEĞİLDİ** (11 de bayatlayacaktı): cümle artık **YAPI**
iddia ediyor — *"her mühür ve her bölme iddiası için en az bir sabotaj"*.
⛔ Sayıyı çapalayan bir test **kurmadım**: o *kapının kapısını denetleyen
kapı* olurdu (ölçüt C).

**Mührün kapsamı — DAR yazıldı, kasıtlı:** ROM konvansiyonu davranışsal
olarak **yalnız `shoulder_flexion_right`** için çivili (`real_replay_test.dart`
L33-64). Payda **8**, davranışsal çapa **1**. Mühür kalan 7'yi
**DOĞRULAMAZ**; sessizce **DEĞİŞMELERİNİ** yakalar.
> ***BİR MÜHÜR, DEĞERİN DOĞRU OLDUĞUNU DEĞİL, SESSİZCE DEĞİŞMEDİĞİNİ
> KANITLAR — VE İKİSİNİ AYNI CÜMLEDE YAZMAK, OLMAYAN BİR ÖLÇÜMÜ VAR
> GÖSTERİR.***

**Kayma denetimi eklendi:** iki mühür iki ayrı dizge; biri güncellenip öteki
unutulursa *"mühürlü"* sessizce yarım kalırdı. Anahtar kümeleri sınanıyor.

**C durma koşulu:** `⛔ → ✅` = **0** (A tablosunda açık kalem yalnız A12, ve
engeli onayda). Sayaç **2** ⇒ ölçüt gereği **koordinatöre bildirim** — L-313
raporunda zaten açıldı, C'nin bu hat için yeniden tanımlanması gerekiyor.

---

## L-315 — **A3 PAYDA GENİŞLEDİ**: tanım ölçümden önce, ve ölçüm ÜÇ kusur buldu

**H-5 · H-6 işlendi.** H-5'in birim değişikliğiyle (C sayacı artık *"kullanıcının
göreceği yüzeyde ölçülmüş ne değişti"*) çalışıldı; H-6'nın A12 düzeltmesi zaten
benim ölçümümdü, reçetemde *"profil yok"* varsayımı YOK — denetlendi.

### Payda: **6 → 12**, ve eskisine DOKUNULMADI

`reachable_but_empty_test.dart` A3'ü **6 batarya ailesi** üzerinde ölçüyordu.
Kullanıcının gezdiği ekranlar paydaya hiç girmemişti. Yeni dosya
`a3_silent_surface_test.dart` **12 yüzey** ölçüyor: 6 sekme/ekran
(`Home·Library·Progress·Profile·LiveCapture·WhatLissomDoesntDo`) + **6
`FamilyPage` örneği**. ⛔ Eski dosya değiştirilmedi — *iki ayrı payda, iki ayrı
birim; birleştirmek ikisini tek sayıya toplamak olurdu.*

### Goodhart karşıtı kanıt BEYAN değil, GIT SIRASI

`docs/A3-SESSIZ-ORAN-TANIMI.md` **ayrı ve ÖNCEKİ** commit'te (`a7fc901`).
Doğrulaması dosyanın 3. satırındaki komut: tanım commit'i ölçüm commit'inden
eski olmalı. *Bir tanım, ölçümden sonra yazıldığında ölçümü övecek biçimde
yazılabilir; bir önceki commit'te duran tanım yazılamaz.*

Tanımın ürettiği asıl şey bir sayı değil, **ölçümden önce yapılmış bir ayrım**:
ⓒ (sessiz) ikiye bölünür ve **yalnız biri kusurdur** —
**ⓒ¹ BAŞLIKLI BOŞLUK** (vaat çizilir, içerik çizilmez) = 🔴 kusur ·
**ⓒ² BÜTÜN-BÖLÜM YOKLUĞU** (vaat de yok) = ⚪ A4'e devredilir.
> ***BİR BAŞLIK, ALTINDAKİ BOŞLUĞU GÖRÜNÜR KILAR; BAŞLIĞIN KENDİSİ DE
> KAYBOLDUĞUNDA GÖRÜNEN BİR KUSUR YOKTUR — VE İKİSİNİ AYNI SAYIYA TOPLAMAK,
> OLMAYAN BİR KUSURU VAR, OLANI YOK GÖSTERİR.***

### ÖLÇÜM — iki pencere, tek sayıya TOPLANMADI

**BUGÜN** (sevk edilen config, taze kurulum) — kova sayımı **paydasıyla**:
`ⓐ SUNAN 2 · ⓑ SÖYLEYEN 5 · ⓒ SESSİZ 0` ⇒ payda **7**, **sessiz oran %0,0**.
Artefakt: `docs/a3-sessiz-oran.json`, **testin kendisi yazıyor** (elle yazılsaydı
bir gün koddan ayrışırdı — L-314'ün bayat başlık dersi).

**YARIN** (veri kaynakları boşaltıldı) — **ÜÇ başlıklı boşluk bulundu ve
KAPATILDI**, üçü de `library_screen.dart`'ta:

| # | tetik | başlık | kova |
|---|---|---|---|
| 1 | `liveness` boş | «Measured by camera in this build (0)» | ⓒ¹ |
| 2 | `liveness` boş | «Not measured by camera (0)» | ⓒ¹ |
| 3 | **aileler hepsi inşa edilmiş** | «Planned, not in this build (0)» | ⓒ¹ |

③ en ağırı: tetiği bir arıza değil **ürünün İLAN EDİLMİŞ HEDEFİ** — yol haritası
bittiğinde `pending` boşalır. Eski kod o an *"(0)"* başlığı + *"These are named
so you can see the whole shape of Lissom"* paragrafını **hiçbir ad olmadan**
çizerdi: sessiz değil, **YANLIŞ**.
> ***BİR "YARIN" PENCERESİ, ÜRÜNÜN GİTMEYİ VAAT ETTİĞİ YERİ İÇERMİYORSA,
> YARINI DEĞİL YALNIZ ARIZAYI ÖLÇER*** — ilk yazımımda bu vaka penceremde
> YOKTU; `liveness` ve `history` boşaltılmıştı, aile listesi hiç.

**Düzeltmenin asimetrisi KASITLI:** `live` boşsa **gerekçe** çizilir
(`NamedGapCard`), `blocked`/`pending` boşsa **türetilmiş olgu cümlesi**. Sebep:
*"hiçbir şey ölçülemiyor"* kullanıcının bilmesi gereken bir eksiklik,
*"hiçbir şey engelli değil"* bir eksikliğin YOKLUĞU. İkisi özdeş biçimde
yazıldı — *iki özdeş durum iki farklı tonla yazılsaydı ürünün sesi çatallanırdı.*

### 🪤 ÜÇ KEZ ÖLÇÜM ARACIM KÖR ÇIKTI — üçünü de POZİTİF ÇAPA yakaladı

Bu turun asıl dersi bu. **Her üç vakada da ölçüm testleri "0 bulgu" diyordu.**

1. **Paydam kusurun BULUNDUĞU ekranı içermiyordu.** D1'in pozitif kontrolü
   `LibraryScreen`i boş `liveness` ile kurdu ve **ötmedi** — aradığı başlık
   `FamilyPage`de yaşıyordu, bir dokunuş ötede. *Ölçüm aracının körlüğü paydayla
   yakalanır* — ve bu kez onu **payda değil pozitif kontrol** yakaladı.
2. **`find.byType` ALT SINIFLARI eşlemiyor.** ⓐ kovası **0** çıktı; `FilledButton`
   bir `ButtonStyleButton` alt sınıfı olduğu için hiç eşleşmemişti. Taze kurulumda
   Home gerçekten düğme çiziyor ⇒ sayım *"düğme yok"* demiyordu,
   ***"düğme ARAMADIM"*** diyordu.
   > ***BİR SIFIR, ARADIĞINI BULAMAMAKLA ARAMAMIŞ OLMAK ARASINDA AYRIM YAPMAZ.***
3. **`_uncounted…` tarayıcısı** boş dönüyordu ve bu doğru olabilirdi de,
   bozuk desen de — ayrımı `scanned > 0` çapası yapıyor.

⇒ Üç kapı da yeşil yanacaktı ve rapor **"A3 temiz, sessiz oran %0"** olacaktı.
***YEŞİL BİR ÖLÇÜM TESTİ, POZİTİF ÇAPASI OLMADAN "KUSUR YOK" DEĞİL
"BAKMADIM" DEMEKTİR.***

### 🔴 BEKLENTİM ÇÜRÜDÜ — ADIYLA (tanım §4 gereği)

**Madde 2 YANLIŞTI.** *"En olası ⓒ¹ adayım `home_screen.dart:145`'in `switch`
varsayılanı"* demiştim. Ölçüldü: **o dal ULAŞILAMAZ.** `_section` önce
`_keys[s.id]`e bakıyor, tanımadığı id `_unknownSection`e gidiyor ve orada
**gerekçeli bir `NamedGapCard`** çiziliyor. Yani ürün benim tahminimden **daha
iyi** çıktı — Home'un her dalı gerekçe taşıyor.
Madde 1·3·4·5 doğrulandı (③ ⓒ² değil ⓒ² çıktı: `WhatLissomDoesntDo`'nun iki
koşullu bölümü başlığıyla birlikte yok oluyor ⇒ kusur değil).

**Ama tahminin YANLIŞ olması, tehlikenin yok olması değil:** `_keys`'e `switch`'te
karşılığı olmayan bir id eklenirse `k != null` olur, `switch` `_` dalına düşer ve
**başlıklı boşluk O AN ULAŞILABİLİR HÂLE GELİR.** ⇒ Kapı kuruldu:
`_keys` domaini ile `switch` dalları **küme eşitliği**, iki tarafı da ayrı
pozitif çapayla (boş kümeler birbirine eşittir ve test hiçbir şey ölçmeden
yeşil yanardı).

### Kapı kurma kısıtı — ne kuruldu, ne KURULMADI

✅ Kurulan üç kapı da bir **kullanıcı-yüzeyi iddiasını** doğruluyor:
*"başlığı olup gövdesi olmayan bir bölüm yoktur."*
⛔ **Kurulmadı:** tanım dosyası tazeliği kapısı (*kapının kapısı*, ölçüt C) ·
ⓒ² sayısını çapalayan sayı-kapısı (*bir sayı çapası, denetlediği şey büyüdükçe
sessizce yanlışlaşır*, L-314).

### Kanıtın yeniden alınması

D1'in pozitif kontrolü **bir kez gerçek ekranda ötüyordu** (`FamilyPage` 2 bulgu,
`LibraryScreen` 1 bulgu) — **düzeltme onu bozdu.** *Bir kapıyı güçlendiren
düzeltme, ötme kanıtını geçersiz kılar.* Tetiği geri getirmek için ürünü
BOZMADIM (*kapı ötsün diye kusuru yaşatmak, kapının amacını tersine çevirir*);
kalıcı kontrol asgari ağaca çekildi, gerçek-ekran ötmeleri **tarihiyle kayıtta**,
ve ürün ağacına bakıldığının kanıtı iki pencere testinin **AYNI `titledVoids`
fonksiyonunu** çağırması (J-232: kopya sınanmaz).

### C durma koşulu (H-5 birimiyle)

*"Kullanıcının göreceği yüzeyde ölçülmüş ne değişti?"* → **Üç yüzey kusuru
kapandı** (`library_screen.dart`, boş-hâl dalları). Sayaç **0**.

**Kapılar:** app **211/211** (taban 205, +6) · engine **114/114** ·
python **20/21** (21'inci `fixture_check.py` = **M-F-280 BİLİNEN**) · `all_gates.py` exit **0**.

### 🪤 ALET TUZAĞI — commit mesajındaki BACKTICK zsh'te çalıştırılır

`git commit -m "…"` **çift tırnak** içinde backtick kullandım; zsh onu **komut
ikamesi** sandı ve mesajdan bir kelime **sessizce düştü**
(`command not found: pending` → mesajda *"bitince  boşalır"*).
Tuzak listemde bu YOKTU; ekleniyor: ***commit mesajı bir kabuk dizesidir ve
backtick orada koddur.*** Panzehir: `-F -` + heredoc, ya da tek tırnak.

⛔ **Force-push YAPILMADI.** Kayıp tek kelime, ve yetkili kayıt DEFTER'in bu
girdisi — zaten eksiksiz. *Bir commit mesajındaki kozmetik kayıp için
`main`'i force-push etmek, geri alınamaz sınıfta bir işi kozmetik bir kazanç
için yapmaktır.*

---

## L-316 — **ÜRÜN DERİNLİĞİ**: Lissom ölçtüğü sayıyı SAKLAMIYOR — ve artık bunu söylüyor

### Bulgu — aranmayan yerden çıktı

Ürün derinliği turuna *"Progress ne kadar derin"* diye başladım. Progress'in
kıyas kartı kıyasın neden kapalı olduğunu anlatıyor ve gerekçesi şu:
*"aynı model, uyumlu config, benzer kamera kurulumu — geçmişte bunların
**üçü de** saklanmıyor."* Depoyu izledim ve **daha büyüğünü** buldum:

`AssessmentResult` → `value` · `unit` · `bandLabel` · `provenance` taşıyor.
`recordFor()` onu çekirdeğin `SessionRecord`una çeviriyor ve **dördünün de
karşılığı yok.** ⇒ ***Lissom bir eklem açısını ölçer, bir kez gösterir, ve
sonsuza dek atar.*** 147,5° ölçen kullanıcı yarın geldiğinde *"Overhead
Reach · right, ölçüldü"* görür — **147,5'i bir daha hiçbir yerde göremez.**

**Ölçüldü, iddia edilmedi** (`test/measurement_value_persistence_test.dart`,
3 test): kaydın JSON'unda `147` de `deg` de `pose_landmarker` da YOK —
alan adı değil **sayının kendisi** arandı, bir alan adı değişse bile bulgu
geçerli kalsın diye. İki pozitif çapa: ① sonucun değeri gerçekten taşıdığı
② kayıt satırının ekranda gerçekten çizildiği.

### 🔴 Bu bir kusur DEĞİL, gerekçesi BAYATLAMIŞ bir karar

Çekirdek bunu **kasıtlı** yapıyor ve sebebini kendi başlığında yazıyor:
> *"there is deliberately NO verdict/score field — recording zeros **before
> the camera bridge** would draw zeros on tomorrow's progress chart."*

**Ön koşul: "kamera köprüsü YOKKEN".** Lissom'da kamera köprüsü **VAR** —
A1 kapandı (`L-309`), ölçüm uçtan uca koşuyor, gerçek açı üretiyor. Sıfır
yazma riski **geçti**; geriye yalnız kaybın kendisi kaldı.
> ***BİR KARARIN GEREKÇESİ BİR ÖN KOŞULA DAYANIYORSA, O ÖN KOŞUL DEĞİŞTİĞİNDE
> KARAR SESSİZCE GEREKÇESİZ KALIR — ve kimse fark etmez, çünkü karar hâlâ
> orada durur.*** Kapı bunu göremez: hiçbir şey KIRILMAZ, yalnız bir cümlenin
> dayanağı buharlaşır.

Çekirdeğin ikinci cümlesi de yön veriyor: *"attempt-level provenance … is
deliberately absent: that is attempt-level data, **this is a session-level
record**."* ⇒ Çekirdek deneme-düzeyi veriyi **kendi işi saymıyor**; o hâlde
sahibi APP katmanıdır. Ama şema beş app'i bağladığı için **karar koordinatörün**
(H-4②'nin emsali: aile kuralını tek taraflı değiştirme). ⛔ Şemaya DOKUNMADIM.

### Bu turda YAPILAN — kullanıcının gördüğü yüzeyde

Altyazı **üç şey vaat ediyordu**: *"what was measured, when, and under what
conditions."* Depo **birini** karşılıyor:
`what` = yalnız HANGİ test (sayı değil) · `when` = ✅ · `under what conditions`
= **hiç yok** (provenance düşüyor).
⇒ Altyazı karşılığı olana kısaltıldı (*"Which test you measured, and when."*)
ve **kesilen yarı sessizce düşürülmedi**: kıyas kartıyla aynı yerde ve aynı
tonda yeni bir kart — *"The reading itself is not kept"* — sayının neden yok
olduğunu ve **paylaşılan çekirdek kaydında yeri olmadığını** söylüyor.

### 🔴 A3 KAPIM BUNU YAKALAYAMAZDI — ve sınırı artık yazılı

Bu gece kurduğum iki detektör **yapısal olarak BOŞ** bölümü bulur. Buradaki
bölüm **DOLU** — satırlar var — ama başlığın vaat ettiği şey altında yok.
> ***BİR BAŞLIK, ALTI BOŞ OLDUĞUNDA DEĞİL, ALTI YANLIŞ ŞEYLE DOLU OLDUĞUNDA DA
> YALAN SÖYLER — ve bunu hiçbir boşluk detektörü göremez, çünkü ölçtüğü şey
> VARLIK, KARŞILIK değil.*** ⇒ A3'ün üçüncü kusur biçimi: **KARŞILIKSIZ VAAT.**
Kapı KURMADIM: *"her başlık altındakini doğru tarif ediyor mu"* metin-anlam
sorusudur, kapı değil hüküm ister.

### 🪤 Kendi eklediğim kart, kendi testimin çapasını kırdı

Yeni kart Progress'e girince kayıt satırı **katlamanın altına** düştü; çapa
"satır yok" diye kırmızı yandı — kayıp yüzünden değil, **erişim** yüzünden.
`scrollTo` eklendi. *Bir yüzeye içerik eklemek, o yüzeydeki HER arama testinin
erişim varsayımını değiştirir* (L-297'nin kazası, ekleyen tur geri getirdi).

### C durma koşulu (H-5 birimiyle)

*"Kullanıcının göreceği yüzeyde ölçülmüş ne değişti?"* → Progress altyazısı
karşılığı olana çekildi **ve** kaybın kendisi kullanıcıya söylenir oldu.
Sayaç **0**.

**Kapılar:** app **214/214** (taban 211, +3) · engine **114/114** ·
python **20/21** (M-F-280 BİLİNEN) · `all_gates.py` exit **0**.
**KOORDİNATÖRE SORU (açık):** deneme-düzeyi kayıt — çekirdek şemasına mı,
yoksa app-sahipli yan deftere mi? Çekirdeğin kendi cümlesi ikincisini işaret
ediyor, ama beş app'i bağladığı için hüküm koordinatörün.

---

## L-317 — **CİHAZDA YÜRÜDÜM ve ekran KENDİ KENDİYLE ÇELİŞİYORDU** — hiçbir kapı göremezdi

Bu turun tamamı tek bir kuralın bedelini ödedi: ***yeşil test iddiadır.***

### Yürüyüş (gerçek cihaz, gerçek derleme)

`iPhone 17 Pro Max · iOS 26.4` · `flutter build ios --simulator` · taze kurulum →
onboarding **5 adım** (2. adım *"I understand"* olmadan Continue KAPALI; 4. adım
yaş bandı olmadan KAPALI — ikisi de doğru) → Home → Progress. Ekran görüntüsü
alındı. ⚠️ Derleme depoyu **kirletmedi** (L-308'in bayat pod kilidi tekrarlamadı).

### 🔴 BULGU — aynı ekran aynı şeyi hem VAAT EDİP hem REDDEDİYORDU

Progress'in boş-hâl kartı şöyle diyordu:
> *"**No session can be captured in this build**, so there is nothing to list.
> When one can, **every reading it produced appears here with its date and
> conditions.**"*

**İki ayrı yalan, ikisi de bu gece görünür oldu:**
① *"bu derlemede oturum yakalanamaz"* — **BAYAT.** A1 kapandı (`L-309`), ölçüm
uçtan uca koşuyor ve depoya yazıyor. Cümle köprüden ÖNCE yazılmış, köprü gelince
kimse geri dönüp okumamış. *(L-316'daki çekirdek gerekçesiyle **aynı sınıf**: ön
koşul değişti, cümle yerinde kaldı.)*
② *"her okuma tarihi ve KOŞULLARIYLA burada görünür"* — bu ekranın **üç kart
yukarısı**, bu gece benim eklediğim kart, *"the reading itself is not kept … no
place for a value or for the conditions"* diyor. **Ekran kendi kendini
çürütüyordu** — ve çelişkiyi görünür kılan şey benim eklediğim karttı.

> ***BİR EKRANIN İÇ TUTARLILIĞI, PARÇALARININ TEK TEK DOĞRULUĞUNDAN ÇIKMAZ.***
> Her iki metin de çiziliyordu, her iki testi de yeşildi, ve hiçbir kapı bir
> ekrandaki İKİ CÜMLEYİ birbirine karşı okumaz. **Bunu ancak ekranı YÜRÜYEN
> görür.**

### 🪤 KURDUĞUM KAPI KÖRDÜ — ve sabotaj onu yakaladı

Çelişki kapısını yazdım, **yeşil yandı.** Sabotaj olarak eski metni geri koydum
(`grep -q` ile indiği doğrulandı) → kapı **ÖTMEDİ.** Sebep: yalnız
`pumpAndSettle` anında çizilmiş `Text`leri tarıyordu; suçlu kart katlamanın
ALTINDA ve `ListView` onu **hiç kurmamıştı**. (`skipOffstage: false` kurtarmaz —
ağaçta yok.) Kaydırarak toplamaya çevrildi; sabotaj tekrar → **tam 1 test düştü**,
ve düşen **benimkiydi** ⇒ izole, ötme SEBEBİ kanıt.
> ***AYNI TUZAĞA BİR SAAT ARAYLA İKİ KEZ DÜŞTÜM*** — önce kayıt-satırı çapası
> (L-316), sonra bu kapı. *Bir dersi bir testte uygulamak, onu SONRAKİ testte
> uygulamış olmaz; ders kişisel hafıza değil KONTROL LİSTESİ olmalı.*

### 🪤 Geri-alma doğrulamam da yanlış yerden okudu

Sabotajı geri aldıktan sonra `grep -q "every reading it produced"` **hâlâ eşleşti**
ve bir an *"geri alma tutmadı"* sandım. Tutmuştu: eşleşen şey, sabotajı
BELGELEYEN yorumdu — eski metni yorumda birebir alıntılamıştım.
⇒ Kendi tuzak listemin maddesi (*metin tarayan kapı YORUMLARI kodla aynı sayar*)
bu kez **sabotaj-doğrulama komutumda** tuttu. Doğrulama yorum-hariç tekrarlandı:
canlı kodda **0** eşleşme.

### 🪤 VE ÜRÜNÜN KENDİ KAPISI BENİ YAKALADI

Yeni metne *"You have not measured anything here **yet**"* yazdım.
`wellness_lint.py` + `expectNoBannedCopy` **ikisi birden** reddetti: **`yet` bir
VAATTİR** (M-F-186), bilmediğimiz bir tarihi ima eder. Kural zaten
`library_screen.dart`ta yazılıydı ve ben **tam o kuralı ihlal ederek dürüstlük
metni yazdım.**
> ***BİR KURALI BİLMEK, ONU YAZARKEN UYGULAMAK DEĞİLDİR — UYGULAYAN ŞEY KAPIDIR.***
İki kırmızının **tek** sebebi buydu; tek kelime iki kapıyı birden düşürdü.

### Kapanış

Metin düzeltildi, cihazda **yeniden derlenip yeniden yürünerek** doğrulandı;
ayrıca başlıkla gerekçenin aynı cümleyi tekrarladığı görüldü (yalnız cihazda
belli oldu) ve gerekçe tekrar etmeyecek biçimde kısaltıldı.

**C durma koşulu (H-5 birimiyle):** Progress'in boş-hâl metni artık ne bayat ne
çelişkili; kullanıcı ilk açılışta tutarlı bir ekran görüyor. Sayaç **0**.

**Kapılar:** app **215/215** (taban 214) · engine **114/114** ·
python **20/21** (M-F-280 BİLİNEN) · `all_gates.py` **TÜMÜ YEŞİL**.

---

## L-318 — Gecenin kusur SINIFINI önden kapattım: cihaz-geçişi iddiası TEK KAYNAKTAN

### Neden bu tur — iki bulgu bir DESEN gösterdi

`L-316` ve `L-317` aynı sınıftandı: ***ön koşul değişti, cümle yerinde kaldı.***
Üçüncüsünü **beklemek yerine aradım.** `lib/` altındaki yetenek iddiası taşıyan
**26** kullanıcı dizesini taradım; çoğu config'ten TÜRETİLİYOR (kendiliğinden
tazeleniyor). Tehlikeli olan **elle yazılmış** olanlar.

### Bulgu — aynı olgu ÜÇ (aslında DÖRT) yerde elle yazılmış

*"Gerçek telefonda denenmedi"* (A12) iddiası:
`surfaces.dart` `CaptureUnavailableNote` (Home·Library·Progress'in paylaştığı) ·
`home_screen.dart` `DeclarationBanner` · `live_capture_screen.dart`
`NamedGapCard.reason` — **üç ayrı cümle, tek olgu.**

🔴 Ve `surfaces.dart`ın **kendi başlığı** kuralı zaten yazıyordu:
> *"aynı beyanı üç ekranda üç farklı tonda yazmak, üçünden ikisinin sessizce
> yumuşamasına yol açar. **Beyan bir kez yazılır, üç yerde GÖSTERİLİR.**"*

Kural yazılıydı, paylaşılan not için **uygulanmıştı**, ve aynı iddia için **iki
kez çiğnenmişti.** *Bir kuralı dosyanın başına yazmak, onu o dosyada uygulamayı
garanti etmiyor — L-317'nin `yet` dersinin aynısı, bu kez mimari düzeyde.*

### Neden ACİL: A12 kapanmak üzere

Preflight hazır (`docs/A12-KOSUM-HATTI.md`, öz-test 2/2), engel yalnız kurucu
onayı. A12 kapandığı gün biri bu cümlelerden birini/ikisini güncelleyip
üçüncüsünü unutacaktı ⇒ uygulama aynı anda *"cihazda doğrulandı"* ve *"gerçek
telefonda denenmedi"* diyecekti — **`L-317`'nin birebir tekrarı.**
> ***AYNI OLGUYU İKİ YERE YAZMAK, ONLARI AYIRMANIN BİR YOLUNU AÇIK BIRAKMAKTIR
> — VE O YOL ER YA DA GEÇ KULLANILIR.***

### Yapılan

`DevicePassClaim` (`surfaces.dart`) — olgu tek yerde: `verified` (bool, A12'nin
makine karşılığı) · `notTried` · `stillNeeds` (geniş çerçeve) · `stillNeedsLead`
(dar çerçeve). Üç yüzey de ondan TÜRETİYOR.
⇒ A12 kapandığında **tek sabit** değişir, üç yüzey birden düzelir.
⛔ Farklı ÇERÇEVE yasaklanmadı — `LiveCaptureScreen` dört kalemi tek tek saymaya
devam ediyor (koordinatör şartı). *Farklı sunum meşru, farklı OLGU değil.*

### 🪤 Kapı İLK KOŞUMDA öttü — ve saymadığım DÖRDÜNCÜ kopyayı buldu

Üç yeri düzeltip kapıyı koştum: **kırmızı.** `live_capture_screen.dart:349`ün
`detail` alanı *"Still needs a device pass:"*i hâlâ elle taşıyordu — envanterimde
**yoktu**, çünkü ilk taramamda `reason`a bakıp `detail`i saymamıştım.
> ***BİR KAPININ İLK KOŞUMUNDA ÖTTÜĞÜ ŞEY, SAYILMAMIŞ BİR KOPYADIR*** — ve bu,
> kapının envanterden ÜSTÜN olduğunun ölçüsü: envanteri ben yaptım, kapı düzeltti.

### Kapının iki yarısı ve NE yasaklamadığı

① kaynak taraması: olgu ikinci kez ELLE yazılamaz (yorumlar HARİÇ — L-317'de
kendi sabotaj-doğrulamam yorumla eşleşmişti; bu dosyanın kendi başlığı da
iddiayı alıntılıyor, dışlanmasaydı kapı kendi belgesini ihlal sayardı).
② çizilmiş ağaç: paylaşılan not olguyu GERÇEKTEN taşıyor + `verified` hâlâ
`false`. **İkisi ayrı iddia:** *"ikinci kez yazılmadı"* ile *"aynı şeyi
söylüyorlar"* aynı şey değil.
Pozitif kontrol **iki yönlü**: desen elle-yazımı yakalıyor **VE** türeten kodu
suçlamıyor — *meşru kullanımı engelleyen bir kapıyı hat kapatır ve koruma
tamamen kaybolur.*
Payda çapası: taranan satır **>500** (yol/desen bozuksa "0 ihlal" vakum-doğru
olurdu — bu gece üç kez yaşandı).

### Metin DEĞİŞMEDİ — ölçüldü

Türetilen dizeler, elle yazılan öncekilerle **birebir aynı** (geçici testle
karşılaştırıldı, sonra silindi). *Bir yeniden düzenleme kullanıcı metnini
sessizce değiştirseydi, kendisi bir kusur olurdu.*

**Kapılar:** app **218/218** (taban 215, +3) · engine **114/114** ·
python **20/21** (M-F-280 BİLİNEN) · `all_gates.py` TÜMÜ YEŞİL.
**C sayacı:** bu tur kullanıcı metnini DEĞİŞTİRMEDİ (kasıtlı) — değişen şey,
A12 kapandığında üç yüzeyin **birlikte** düzelecek olması. Sayaç **0** değil
**ÖNLENEN 1**: L-317 sınıfı bir kusurun tekrarı yapısal olarak imkânsızlaştı.

---

## L-319 — **H-10 görevi: kendi hattımda İKİ bayat yokluk cümlesi daha** (+ kapım yine kör doğdu)

**H-7 · H-8 · H-9 · H-10 okundu ve işlendi.** H-10 aileye görev veriyor: *yokluk
beyan eden her cümleyi tara, konusu O ZAMANDAN BERİ UYGULANMIŞ olanı bul.*
`L-317`'m bu sınıfın iki örneğinden biriymiş (öteki Choreia `C-275`) — **aynı
gece, birbirimizden habersiz, ikimiz de UYGULAMAYI YÜRÜYEREK bulmuşuz.**

### Taradım, ve iki tane daha çıktı

**① `profile_screen.dart` — *"Nothing is captured by the camera in this build
either"*.** A1 `L-309`'da kapandı: kamera yakalıyor, ölçüm koşuyor, kayıt
`sessions.jsonl`e giriyor. Cümle **yazıldığında doğruydu.**

🔴 **Ve tam ÜSTÜNDEKİ yorum bunu ÖNCEDEN yazmıştı:**
> *"Doğru sonucu yanlış gerekçeyle söylemek en zor yakalanan hatadır: kimse
> sonucu sorgulamaz. **Ve gerekçe bir gün gerçekleştiğinde cümle aynen kalır,
> yalnız artık denetlenmemiş olur.**"*
Kod kendi bayatlamasını **tahmin etti**, uyarıyı yazdı, ve **yine de bayatladı.**
> ***BİR RİSKİ YORUMA YAZMAK ONU ÖNLEMEZ — ÖNLEYEN ŞEY KAPIDIR.***

**② `onboarding_flow.dart` — *"nothing is recorded, saved, or sent anywhere"*.**
Cümlenin ÖZNESİ videoydu, ama *"nothing is … saved"* **her şey** diye okunur.
Lissom ölçüm kaydını diske yazıyor ⇒ **her yeni kullanıcı ilk açılışta *"hiçbir
şey saklanmıyor"* öğreniyor, sonra Progress'te listesini buluyordu.** Choreia'nın
vakasının birebir aynısı, farklı gramerle.
> ***BİR YOKLUK CÜMLESİNİN ÖZNESİ BELİRSİZSE, YOKLUK BÜYÜR*** — okuyucu onu en
> geniş hâliyle anlar, ve **en geniş hâli yalandır.**

Düzeltildi: özne açık (*"The video is never recorded…"*) **ve** saklananın ne
olduğu adıyla (*"What is written down is which test you measured and when"*) —
Progress'in cümlesiyle **aynı** olgu. Üç yüzey (onboarding · Progress · Profile)
artık tek şey söylüyor; **cihazda yürüyerek üçü de doğrulandı.**

### 🪤 KAPIM YİNE KÖR DOĞDU — ve sebebi bu kez DİLİN KENDİSİYDİ

`stale_absence_claim_test.dart` yazıldı, **yeşil yandı.** Sabotaj (eski profil
cümlesi geri) → **ötmedi.** Sebep yapısal ve öncekilerden farklı:
**Dart uzun dizeleri satırlara BÖLER.**
```
'there is nowhere for your data to go. Nothing is '
'captured by the camera in this build either. …'
```
⇒ *"nothing is captured by the camera"* **hiçbir satırda tam geçmiyor.** Satır
tabanlı tarayıcım yalnız **bir satıra sığan** ifadeleri görebiliyordu — yani tam
da bayat iddiaları taşıyan **uzun cümleleri asla göremezdi.**
> ***BİR KAYNAK TARAYICISI, DİLİN METNİ BÖLDÜĞÜ YERİ BİLMİYORSA, ARADIĞI ŞEYİN
> EN UZUN HÂLİNİ HİÇ GÖREMEZ.***
Bitişik dize parçaları birleştiriliyor (`' … '\n' … '` → tek dize); sabotaj
tekrar → **öttü, ve tam olarak sabote edilen iddiayı adıyla yazdı.** Geri alma
satır bazında; canlı kodda kalıntı **0** (birleştirilmiş taramayla doğrulandı).

📌 **Bu, gecenin ÜÇÜNCÜ kör kapısı** (① A3 paydası `FamilyPage`i içermiyordu ·
② `find.byType` alt sınıf eşlemiyordu · ③ bu). Üçünü de **pozitif çapa/sabotaj**
yakaladı, üçü de yeşil yanıyordu.
⚠️ **Ve `L-318`'in kapısı aynı zaafı taşıyor ama TESADÜFEN çalışıyor:** aradığı
ifadeler (*"on a real phone"*, *"needs a device pass"*) kısa olduğu için tek
satıra sığıyor. **Tesadüf bir tasarım değildir** — kayda geçiyor; o kapıya uzun
bir ifade eklenirse birleştirme oraya da taşınmalı.

### Kapının sınırı — ADIYLA

Yasak liste **bilinen ve ölçülmüş** yalanları taşıyor; her desenin yanında *onu
çürüten ölçüm* yazılı. ⛔ *"Her yokluk cümlesi hâlâ doğru mu"* kapısı
**KURULMADI** — o metin-anlam sorusudur, kapı değil hüküm ister.
> *Bir kapı her şeyi koruyamaz; koruduğu şeyi ADIYLA yazmalı.*
Pozitif kontrol iki yönlü (bayatı yakalar **ve** meşru metni suçlamaz), payda
çapası >500 satır.

**Kapılar:** app **221/221** (taban 218, +3) · engine **114/114** ·
python **20/21** (M-F-280 BİLİNEN) · `all_gates.py` TÜMÜ YEŞİL.
**C sayacı:** üç kullanıcı yüzeyinde metin düzeldi (onboarding · Profile +
Progress'le tutarlılık), cihazda doğrulandı. Sayaç **0**.

### L-319 eki — TESADÜFEN çalışan kapıyı tesadüfsüz yaptım

`L-319`'da *"L-318'in kapısı aynı zaafı taşıyor ama tesadüfen çalışıyor"* diye
**yazdım**; aynı turda **kapattım** — yazıp bırakmak, bu gecenin
*"riski yoruma yazmak onu önlemez"* dersini tekrarlamak olurdu.

Birleştirme `device_claim_single_source_test.dart`e de taşındı ve **BÖLÜNMÜŞ bir
sabotajla** kanıtlandı: iddia iki satıra bölünerek elle yazıldı → **eski kapı
göremezdi, yenisi ötüyor** (`«on a real phone»` + `«need a device pass»`, ikisi
de adıyla). Geri alma satır bazında, canlı kalıntı **0**.
> ***TESADÜFEN ÇALIŞAN BİR KAPI, ÇALIŞTIĞI SÜRECE TASARLANMIŞ GÖRÜNÜR — VE İLK
> UZUN GİRDİDE SUSAR.***
📌 Ve bu, *"bir dersi bir testte uygulamak sonrakinde uygulamış olmaz"* kuralının
ilk kez **ÖNDEN** uygulanışı: ders bu gece üç kez arkadan geldi, bu kez önden.

**Kapılar:** app **221/221** · engine **114/114** · python **20/21** · exit 0.

---

## L-320 — Kamera-reddi yolunu yürüdüm: kullanıcı aynı talimatı İKİ KEZ okuyordu

### Nasıl bulundu — testle değil, YÜRÜYEREK

Simülatörde *"Start a measurement"*a bastım. Simülatörde kamera donanımı yok ⇒
uygulama **kamera-reddi** hâline düşüyor — ve bu **gerçek bir kullanıcı yolu**:
izni reddeden herkes tam bu ekranı görüyor.

**İyi haber önce:** çıkmaz sokak YOK. Gerekçe adıyla var, `Open Settings`
düğmesi var ve çalışıyor (`L-283`'te kapatılmış). ⓐ SUNAN kovası.

### 🔴 Kusur: aynı talimat iki kez

```
Camera access is off for Lissom. Open Settings to turn it on.   ← kaynak
Open Settings to turn camera access on for Lissom.              ← ekran
```
Geçici dalda da aynısı: *"… Try again."* + *"You can try again."*

**Sebep bir KATMAN karışıklığıydı:** `camera_pose_source.permissionState()`
olguyu bildirirken **talimat da** veriyordu; `live_capture_screen` ise `kind`den
**türettiği** yönergeyi zaten basıyordu. İki katman aynı cümleyi söylüyordu.

**Çare tekrarı silmek değil, ROLLERİ ayırmak oldu:**
**kaynak OLGUYU bildirir · ekran EYLEMİ sunar.** Bu yalnız tekrarı kaldırmıyor,
katman sınırını da düzeltiyor — *bir poz kaynağının kullanıcıya ne yapması
gerektiğini söylemesi zaten onun işi değildi.*
> ***AYNI CÜMLEYİ İKİ KATMAN BİRDEN SÖYLÜYORSA, BİRİ ONU SÖYLEMEMELİDİR — VE
> HANGİSİ OLDUĞU KATMAN SINIRINDAN OKUNUR.***

### Kapı — ve neden ekranın metnine DEĞİL kaynağa bakıyor

Kapı `permissionState()`in ÜRETTİĞİ gerçek metinleri okuyor (fixture değil) ve
içlerinde `open settings` / `try again` **talimatı** olmamasını zorluyor.
⛔ Genel bir *"tekrar var mı"* kapısı KURULMADI — o metin-anlam sorusudur.
Bu kapı **ölçülmüş ve adı konmuş tek kusuru** kilitliyor.
Sabotaj: talimat kaynağa geri kondu → **kapı öttü ve tekrarlanan cümleyi adıyla
yazdı**; geri alma satır bazında, canlı kalıntı **0**.

### 🪤 Mevcut testlerin çapası KORUNDU — ve neredeyse kıracaktım

`permission_dead_end_test.dart` iki dalı ayırt etmek için tam bu iki alt-satırı
**pozitif çapa** olarak kullanıyor. İlk düşüncem alt-satırı SİLMEKTİ — o zaman
iki testin dal-ayrımı çökerdi **ve ben bunu ancak testler kırıldığında
görürdüm.** Fixture'ın `userText`i iki dalda AYNI olduğu için (`'Camera access
is off.'`) `userText` dalı ayırt edemiyor: alt-satır **tek kind-türevi metin.**
> ***BİR TEKRARI SİLMEDEN ÖNCE, İKİ KOPYADAN HANGİSİNİN BİR ŞEYİ AYIRT
> ETTİĞİNE BAK*** — özdeş görünen iki cümleden biri taşıyıcı olabilir.
⇒ Silinen taraf **kaynağınki** oldu, ekranınki değil.

**Cihazda doğrulandı** (yeniden derlendi, yeniden yürünüldü): olgu → eylem →
düğme, tekrar yok.

**Kapılar:** app **222/222** (taban 221) · engine **114/114** ·
python **20/21** (M-F-280) · `all_gates.py` TÜMÜ YEŞİL.
**C sayacı:** kamera-reddi ekranındaki tekrar kalktı, cihazda ölçüldü. **0**.

---

## L-321 — Cihaz yürüyüşü TAMAMLANDI (temiz) + bekleyen hüküm "ateşe hazır" yapıldı

### Kalan yüzeyler yüründü — bulgu YOK, ve bu bir ÖLÇÜM

`Library` · `FamilyPage «Assessment Battery»` · `WhatLissomDoesntDo` cihazda
gezildi (ekran görüntülü). **Kusur bulunamadı** — ve bu tur bulgu üretmemesi
bir başarısızlık değil, önceki turların kapattığının ölçüsü:

- Library: sayı tutarlılığı üç yüzeyde **aynı** (`Home` *"3 of 12"* ·
  `Library` *"12 tests · 3 measurable"* · `FamilyPage` *"(3)"* + *"(9)"*,
  3+9=12). Hepsi `facts.liveness`ten TÜRETİLDİĞİ için **yapısal olarak**
  tutarlı — elle yazılsalardı bu gecenin kusur sınıfının adayıydılar.
- FamilyPage: engelli 9 testin her biri **kendi anatomisiyle** gerekçe veriyor
  (*"Shin angle — … reads a limb against the line of your torso, not against
  upright"*). `measureKind` turunun aradığı kusur (*"belirli olma ki yanlış
  olma"*) burada **zaten çözülmüş**; prompt kalemi kapanıyor.
- WhatLissomDoesntDo: her sınır **KARAR mı SINIR mı** olduğunu söylüyor
  (*"A choice. We would keep it even with perfect measurement."* / *"A limit of
  what a phone camera can do."*) — *çünkü fark, o şeyin bir gün değişip
  değişemeyeceğini belirler.* Ürünün kimliği bu ekranda.

📌 `DevicePassClaim` türetmesi (L-318) **üç yüzeyde de** doğru çizildi — cihazda
görüldü, yalnız testte değil.

### Bekleyen hükmü "ateşe hazır" yaptım — UYGULAMADAN

`docs/M-TALEBI-deneme-duzeyi-kayit.md` yazıldı: olgu (ölçümle), çekirdeğin
kendi iki cümlesinin ne dediği, **iki seçenek bedelleriyle**, (b) seçilirse
şeklin taslağı ve **yazılmadan önce kararlaştırılacak üç kapı**.
⛔ **Tek satır kod yazılmadı.** Hüküm koordinatörün; belge yalnız hüküm
geldiğinde işin dakikalar sürmesi için var (A12 preflight'ıyla aynı disiplin).

Belgeye **kendi tuzağımı önceden** yazdım: değer saklanmaya başlarsa Progress'in
*"The reading itself is not kept"* kartı **aynı turda** güncellenmeli, yoksa
`L-317` sınıfı bayat cümle üretilir.
> ***BU KEZ ÖNCEDEN BİLİYORUZ*** — ve bu gecenin dersi tam olarak şuydu:
> *bir riski yoruma yazmak onu önlemez.* O yüzden risk bir **kapı şartı**
> olarak yazıldı, bir uyarı olarak değil.

**Kapılar:** app **222/222** · engine **114/114** · python **20/21** (M-F-280) ·
`all_gates.py` TÜMÜ YEŞİL.
**C sayacı:** bu tur kullanıcı yüzeyinde değişiklik ÜRETMEDİ — **ölçtü ve temiz
buldu.** H-5'in birimiyle sayaç **1**. Üst üste ikinci "hiçbir şey" gelirse
dururum ve bildiririm.

---

## L-322 — Bir tekrarı düzeltirken YENİSİNİ ürettim, ve kendim buldum

`L-320`'de kamera-reddi ekranındaki tekrarı kaldırdım. Sonra Progress'i taze
kurulum hâlinde okudum ve **bu gece kendi eklediğim kartın** alttaki kıyas
kartıyla ÇAKIŞTIĞINI gördüm:

| kart | ne diyordu |
|---|---|
| *"The reading itself is not kept"* (**benim**, L-316) | *"…no place for a value **or for the conditions** a reading was taken under"* |
| *"No comparison is made here"* (önceden var) | *"…the same model, a compatible configuration and a similar camera setup. What we store … **does not record any of those three**"* |

İkisi de *"koşulları saklamıyoruz"* diyordu — ve **alttaki daha kesin
söylüyordu** (üçünü adıyla sayarak). Yani eklediğim cümle yalnız tekrar değil,
**daha belirsiz** olanıydı.

> ***BİR TEKRARI DÜZELTİRKEN YENİSİNİ ÜRETMEK, KURALI ÖĞRENMEDEN VAKAYI
> KAPATMAKTIR*** — `L-320`'nin dersini yazdığım gece, aynı sınıftan bir kusuru
> kendi elimle ürettim.

**Çare — her eksikliğin TEK sahibi:** üst kart **DEĞERİ**, alt kart
**KOŞULLARI** anlatır. Sınır artık kodda yazılı, ve cihazda doğrulandı
(yeniden derlendi, Progress yeniden okundu: çakışma yok).

### 🪤 VE BU TURDA CİHAZ KANITIM NEREDEYSE YANLIŞ ÇIKIYORDU

Ekran görüntüsü alırken **Gravita'nın uygulaması ön plana geldi** — durum çubuğu
*"◀ Lissom"*, içerik *"What Gravita is — and isn't"*. Yani tapım **Gravita'nın
uygulamasına** düştü. RAPOR 03'te uyardığım paylaşımlı-simülatör çakışması
**gerçekleşti**, ve bu ikinci vaka (ilki Choreia'ydı).
⇒ O kareyi Lissom kanıtı saymadım; Lissom yeniden başlatılıp yürüyüş tekrarlandı,
ve doğrulama karesinde durum çubuğu *"◀ Gravita"* diyor — **yani ön planda
Lissom var.**
> ***PAYLAŞILAN BİR CİHAZDA EKRAN GÖRÜNTÜSÜ, ÖN PLANDAKİ UYGULAMA
> DOĞRULANMADAN KANIT DEĞİLDİR*** — ve doğrulama karenin KENDİ İÇİNDE olmalı,
> hatırlamada değil.

**Kapılar:** app **222/222** · engine **114/114** · python **20/21** (M-F-280) ·
`all_gates.py` TÜMÜ YEŞİL.
**C sayacı:** Progress'te tekrar kalktı, cihazda ölçüldü ⇒ sayaç **0**'a döndü.

---

## L-323 — **A12 fiilen denendi**: teknik engel KALKTI, fiziksel engel kaldı — ve üç kusur kendi aletimde çıktı

**H-11…H-17 okundu ve işlendi.** ⚠️ **H-16 beni adıyla yazıyor:** *"doğal duruş
noktası bir bitiş değildir"* — gece bitmeden durmuştum, hüküm haklı; kalem
engellenince **sıradakine** geçilir. Kaydediyorum.

### ① H-15 — kendi simülatörüm
`lissom-hatti` (`C87A2274-5AB5-4EE2-9E50-BE1747EAF22B`) oluşturuldu ve tüm
kurulum/kare çağrıları buna sabitlendi. Paylaşılan cihaz artık kullanılmıyor.

### ② H-14 — zehri ÖLÇTÜM, ve zinciri ÜÇÜNCÜ halkasına kadar gördüm

**Cihaz derlemesinden ÖNCE:** `527696B · x86_64+arm64 · IOSSIMULATOR` (temiz).
**Cihaz derlemesinden SONRA:** `284480B · yalnız arm64 · platform IOS` ⇒
🔴 **H-12/J-253 bu ağaçta BAĞIMSIZ olarak yeniden üretildi.**

**H-14'ün iddiası sınandı ve DOĞRULANDI:** `flutter clean` koşuldu, zehirli
dosya **aynı boyut, aynı zaman damgasıyla yerinde kaldı.**
Doğru panzehir (symlink **hedefindeki** `native_assets/ios/` silindi) uygulandı,
simülatör derlemesi tekrarlandı ⇒ `527696B · iki dilim · IOSSIMULATOR` **geri geldi.**
⛔ **Her iki dilim de ölçüldü** — yalnız ilkine bakmak kısmi ölçüm olurdu.

**🪤 VE HİÇBİR HÜKÜMDE OLMAYAN ÜÇÜNCÜ HALKA:**
`flutter clean` **`build` symlink'inin KENDİSİNİ de siler.** Flutter onu
**gerçek dizin** olarak `~/Documents` (iCloud) içinde yeniden kurar ve
**`CodeSign failed` ile derleme düşer** — bu ailenin en eski tuzağı.
> ***BİR PANZEHİR BAŞKA BİRİNİN ETKİ YOLUNU KESEBİLİR (H-14) — VE ÜÇÜNCÜSÜ,
> İKİNCİSİNİ UYGULARKEN BİRİNCİYİ SİLEBİLİR.***
⇒ Sıra artık betikte yazılı: *zehri temizle → symlink'i GERİ KUR → derle.*

### ③ A12 — teknik engel KALKTI, fiziksel engel KALDI

- `xcodebuild … -allowProvisioningUpdates` koştu ⇒ **app'e özel profil ÜRETİLDİ**
  (`T5HZGYBWK8.com.yulalab.lissom`) ve **cihazı İÇERİYOR** (ölçüldü, `cihaz:1`).
- 🪤 **Ama ilk derleme JOKERİ gömdü** (`ProvisionedDevices` = başka bir cihaz).
  *Profili üretmek, onu gömmekle aynı şey değil* — betiğe yazıldı.
- Kurulum denendi: `0xe8008012` (H-9'un cümlesi birebir: *bir imzanın geçmesi
  kurulabildiği anlamına gelmez*), sonra ikinci denemede **`error 1011`** —
  cihaz `unavailable`.
⇒ **A12 kapanmadı, ve sebebi artık ADIYLA belli: telefon ulaşılamıyor** (uyku/
kilit/ağ dışı; kurucu uykuda). **Teknik engel yok.**

### 🔴 ÜÇ KUSUR KENDİ ALETİMDE — üçü de bu turda ölçüldü

**(a) ALT-DİZE KÖRLÜĞÜ.** `grep -q 'available'` **`unavailable`ı da eşliyordu.**
Ölçüldü: cihaz `unavailable` iken betiğim *"✅ erişilebilir cihaz VAR"* diyordu.
**A12 kapısı, telefona ulaşılamazken "yol açık" diyordu** — yanlış yönde yanılan
bir kapı, kapı değildir.
> ***BİR DURUM SÖZCÜĞÜ BAŞKA BİRİNİN İÇİNDE GEÇEBİLİR — VE O ZAMAN ARAMA,
> ARADIĞININ TERSİNİ DE BULUR.***

**(b) "ÖLÇEMEDİM" ile "YOK" KARIŞMIŞTI.** Cihaz ulaşılamayınca `DEVICE_UDID`
boş kalıyor ve ⑤ **kesin olumsuz** basıyordu: *"cihaz hiçbir profilde yok —
portal kaydı gerekir (KURUCU)"*. Oysa profil onu **içeriyor**. Yani betik,
**yapamadığı bir ölçümün sonucunu kurucuya İŞ olarak yazıyordu.**
> ***BİR KONTROL, GİRDİSİ YOKKEN "YOK" DEMEZ — "BAKAMADIM" DER; İKİSİNİ
> KARIŞTIRAN BİR RAPOR, OLMAYAN BİR İŞİ İCAT EDER.*** (Ölçütün kendi kuralı:
> `⛔ ÖLÇÜLEMEDİ` yazılır, `❌` değil.)

**(c) ONAY KAPILARI BAYATLAMIŞTI.** Betik *"profil tazeleme + kurulum: kurucu
onayı"* diyordu; H-9 birincisini **rutin altyapı**, H-17 ikincisini **Lissom'a
doğrudan görev** yaptı. ⇒ Kapılar **silinmedi, KİM AÇTIĞI yazılarak** açıldı.
> ***BİR ONAY KAPISINI SİLMEK İLE AÇILDIĞINI KAYDETMEK AYNI ŞEY DEĞİLDİR —
> SİLİNEN KAPI, YETKİ DEĞİŞİNCE GERİ GELMEZ.***

### 🪤 VE KENDİ ÇIKARIMIMI DÜZELTİYORUM

Bu turun başında *"cihaz ERİŞİLEBİLİR — `devicectl device info details` canlı
donanım bilgisi döndürdü"* dedim. **Yanlıştı.** O komut **önbellekten** döner:
`list` *unavailable* derken aynı komut tam bilgi verdi ve kurulum 1011 ile düştü.
> ***BİR BİLGİ KOMUTUNUN VERİ DÖNDÜRMESİ, CİHAZIN ERİŞİLEBİLİR OLDUĞUNU
> KANITLAMAZ — ERİŞİLEBİLİRLİĞİ ANCAK BİR İŞLEM KANITLAR.*** Betiğe yazıldı.

**Kapılar:** app **222/222** · engine **114/114** · python **20/21** (M-F-280) ·
`all_gates.py` TÜMÜ YEŞİL · preflight öz-test **2/2**.
**C sayacı:** kullanıcı yüzeyi değişmedi; değişen **A12'nin gerçek durumu** ve
üç aletsel yalanın kapanması. H-16 gereği durmuyorum, sıradakine geçiyorum.

---

## L-324 — **ÜRÜN DERİNLİĞİ (H-17 ③)**: bir oturum, on iki satır gibi görünüyordu

### Bulgu

`appendPreserved()` **test başına** bir `SessionRecord` yazar — ve bu **doğru**
(bir bloğun testleri sınıf bakımından KARIŞIK, `assessment_history.dart` §1).
Ama `ProgressScreen` kayıtları **DÜZ** çiziyordu: tek oturumda 12 test ölçen
kullanıcı **aynı tarihi taşıyan 12 satır** görüyor, ve hiçbir şey bunların
**tek bir oturum** olduğunu söylemiyordu. Tarih 12 kez tekrarlandığı için ekran
***"on iki ayrı kez ölçtün"*** diye okunuyordu.

> ***KAYIT BİRİMİ İLE GÖSTERİM BİRİMİ AYNI OLMAK ZORUNDA DEĞİLDİR — VE İKİSİNİ
> AYNI VARSAYMAK, DOĞRU KAYDEDİLMİŞ BİR ŞEYİ YANLIŞ GÖSTERİR.***

⛔ **Şemaya dokunulmadı** — bu tamamen SUNUM katmanı, yani bekleyen çekirdek
hükmünden bağımsız ve hattın yetkisinde. (Bekleyen hüküm *değerin* nereye
yazılacağıydı; bu onunla ilgisiz.)

### Yapılan

Kayıtlar `completedAt`in KENDİSİNE göre gruplanıyor (`appendPreserved` tek
oturumun tümünü aynı damgayla yazar). ⛔ **Güne göre gruplamak yanlış olurdu** —
aynı gün iki kez ölçen kullanıcının iki oturumu tek yığına düşerdi. Depo sırası
KORUNUYOR (yeniden sıralamak deponun sırasını sessizce ezmek olurdu).
Başlık: `6 Aug 2026 · 2 readings`; tarih satırlardan KALDIRILDI.
Her başlık kendi damgasıyla anahtarlı — *aynı `Key` iki widget'ta olamaz*, ve
"kaç oturum çizildi" ancak sayılabilir anahtarlarla ölçülür.

**Cihazda doğrulandı:** enjekte edilmiş 6 kayıt (4+2, iki ayrı damga) → iki
başlık, tarih tekrarı yok.

### 🪤 TEST İKİ KEZ KÖR ÇIKTI — ikisini de SABOTAJ yakaladı

Sabotaj: eski **düz** hâl geri kondu (başlık yok + tarih her satırda).
1. **Kaydırma döngüm aynı satırları tekrar tekrar saydı** (6 yerine 78) ⇒ eşik
   anlamsızlaştı. Ölçtüm: yüzey `pinTallSurface(4000)` ile tek ekrana **sığıyor**,
   altı satırın altısı da çiziliyor ⇒ kaydırma **gereksiz**, ve gereksizliği
   **ölçüldü, varsayılmadı** (çapa her koşumda yeniden doğruluyor).
2. **Yanlış dizeyi arıyordum:** yüzey `10 Aug 2026` yazıyor, ben
   `10 August 2026` arıyordum ⇒ **sabotaj altında bile 0 buldum.**
> ***YANLIŞ DİZEYİ ARAYAN BİR TEST, ARADIĞININ YOKLUĞUNU DEĞİL KENDİ SORUSUNUN
> YANLIŞLIĞINI ÖLÇER — VE İKİSİ DE YEŞİL GÖRÜNÜR.***
Düzeltildikten sonra sabotaj **iki iddiayı da** düşürdü ve sayıyı adıyla yazdı:
*"tarihi TEKRARLIYOR (6 kez)"* · *"iki ayrı oturum … yanlış birim"*.

### 🪤 FIXTURE TUZAĞI — enjekte edilen kayıt SESSİZCE yutuldu

Cihaza kayıt enjekte ettim, uygulama *"Nothing recorded"* dedi. Dosya **doğru
yerdeydi ve okunabilirdi.** Sebep: `JsonlSessionStore` satırı **`v` alanına göre**
ayrıştırıyor (`v == schemaVersion(2)` → oku · `v == 1` → göç · **başka → SKIP**).
`v` yazmamıştım ⇒ altı satır da *bilinmeyen sürüm* sayılıp atlandı.
> ***BİR FIXTURE'IN DOĞRU YERDE VE OKUNABİLİR OLMASI, OKUNACAĞI ANLAMINA
> GELMEZ — ŞEMA SÜRÜMÜ DE FIXTURE'IN PARÇASIDIR.***
📌 Çekirdeğin davranışı **doğru**: bilinmeyen sürüm sessizce yutulmuyor, `skipped`
sayılıyor. Benim ekranım o sayıyı boş-hâl kartına düşürmüyor — ayrı bir kalem
olarak not edildi.

**Kapılar:** app **224/224** (taban 222, +2) · engine **114/114** ·
python **20/21** (M-F-280) · `all_gates.py` TÜMÜ YEŞİL.
**C sayacı:** Progress'te oturum gruplaması kullanıcı yüzeyinde, cihazda ölçüldü ⇒ **0**.

### ⚠️ H-15 kısmen uygulanabildi
Kendi simülatörüm `lissom-hatti` **oluşturuldu ve kullanılıyor** (kurulum +
`simctl` ekran görüntüsü çalışıyor). Ama **MCP cihaz erişimi kurucu onayı
istiyor** ve kurucu uykuda ⇒ tap/gezinme yapılamıyor. Bu turun gezinme kanıtı
onaylı simülatörde alındı, **ön plan kare içinde doğrulandı** (H-15'in asıl
şartı). Kurucu onay verince tüm akış kendi cihazıma taşınır.

---

## L-325 — **OKUNAMAYAN GEÇMİŞ, BOŞ GEÇMİŞ DEĞİLDİ** — ve kusuru KAZARA yaşadım

### Nasıl bulundu — hedeflenmedi, ÇARPILDI

`L-324`'te cihaza kayıt enjekte ederken `v` (şema sürümü) alanını yazmamıştım.
Altı kaydın altısı da *bilinmeyen sürüm* sayılıp atlandı, ve uygulama
**"Nothing recorded on this device"** dedi.
⇒ **Kullanıcının 6 kaydı vardı; uygulama okuyamadı ve "hiç yok" diye rapor etti.**

Bu, koordinatörün `H-13`'te aileye bağladığı **`C-280` sınıfı**: *okunamayan
geçmiş, boş geçmiş değildir.* Choreia bulmuştu; **ben aynı kusuru kendi hattımda
kazara ürettim ve yaşadım.**

### Yapısal sebep — kayıp, TAM DA tek kanıtı kayıp olan durumda görünmezdi

`records=[] ∧ unreadable=6` ⇒ `SessionHistoryView.partial` ⇒
`countsAreTrustworthy = true` (unavailable DEĞİL) ∧ `hasRecords = false`
⇒ **boş-hâl dalı kazanıyor.** Taban uyarısı (`_floorBanner`) ise yalnız
**kayıt VARKEN** çizilen `else` dalında duruyordu.
> ***BİR KAYBI YALNIZ "BİR ŞEY KALDIYSA" GÖSTEREN YÜZEY, HER ŞEYİ KAYBEDEN
> KULLANICIYA HİÇBİR ŞEY SÖYLEMEZ.***

### Yapılan

Boş-hâl dalı **ikiye ayrıldı** — çünkü ikisi **farklı olgular**:
*"ölçmedin"* ile *"ölçtün ama okuyamıyoruz"*. Yeni kart sayıyı ADIYLA veriyor ve
**silinmediğini** söylüyor:
> *"Your readings are here, but we cannot read them — 6 recorded readings could
> not be read by this version of Lissom. They are still on this phone — we are
> not going to tell you the list is empty when it is not."*

⛔ Aynı kartı paylaşsalardı ayrım yüzeyde kaybolurdu, ve kaybolan tam olarak
**kullanıcının işi** olurdu.

### Kanıt

Sabotaj: dal devre dışı bırakıldı ⇒ kapı öttü (*"okunamayan 6 kaydın sayısı
hiçbir yerde yok"*), geri alındı, kalıntı **0**.
**Cihazda doğrulandı — ve fixture olarak KAZANIN KENDİSİ kullanıldı:** `v` alanı
kayıtlardan tekrar silindi, uygulama artık *"hiç yok"* demiyor, altı kaydın
okunamadığını **sayısıyla** söylüyor.
> *Bir kusuru bulan kaza, o kusurun en dürüst fixture'ıdır.*

**Kapılar:** app **225/225** (taban 224) · engine **114/114** ·
python **20/21** (M-F-280) · `all_gates.py` TÜMÜ YEŞİL.
**C sayacı:** kullanıcı yüzeyinde ölçülmüş değişiklik, cihazda doğrulandı ⇒ **0**.

---

## L-326 — H-20 kontrol listesini **İKİNCİ DEPOYA** uyguladım: açılışta çökme buldum

`H-20` (benim `L-325`'imden doğdu) *"depon kısmi/bozuk okuma üretebiliyor mu"*
diye sordu. Seans deposunu düzeltmiştim; **onboarding deposunu** aynı listeyle
taradım ve **daha ağır** bir kusur çıktı.

### Bulgu — koruma vardı ama YANLIŞ bozulmayı bekliyordu

`JsonOnboardingStore.read()` yalnız **`FormatException`** yakalıyordu. Ama
`OnboardingProfile.fromJson` `as bool?` / `as String?` **cast**'leri kullanıyor:
geçerli JSON ama **yanlış tipli** bir alan `TypeError` fırlatır ve o `catch`ten
**kaçar.** Ölçüldü:

```
{"completed": "true"}  → type 'String' is not a subtype of type 'bool?'
{"gender": 42}         → type 'int' is not a subtype of type 'String?'
```

⇒ Profil okuma **açılışta** (`OnboardingGate`) olduğu için bu bir **başlangıç
çökmesi.** Ve bu kuram değil: şema değişikliği (alan tipi değişmesi / yeniden
adlandırma) dosyayı **tam olarak** böyle bozar — `L-325`'in `v` alanı vakasının
kardeşi.

> ***BİR "BOZUK DOSYA" KORUMASI, YALNIZ KENDİ HAYAL ETTİĞİ BOZULMA BİÇİMİNİ
> YAKALAR — VE DOSYALAR HAYAL EDİLMEMİŞ BİÇİMLERDE BOZULUR.***

### Yapılan — tolerans ALAN BAŞINA, dosya başına değil

`fromJson` artık her alanı ayrı ayrı doğruluyor; `read()`in geniş yakalaması
**arkalık** olarak duruyor (*bir tolerans yalnız ayrıştırıcıda olursa,
ayrıştırıcının görmediği hata yine dışarı çıkar*).

⭐ Ve tolerans **alan başına** kasıtlı: bozuk bir `gender`, okunabilir bir
`ageBand`ı **düşürmüyor.** `L-325`'in dersinin bu katmandaki karşılığı —
*okunamayan, okunabileni geçersiz kılmaz.* Testle çivilendi: `gender` bozukken
`ageBand='u40'` **korunuyor**, yoksa kullanıcı beyanını yeniden vermek zorunda
kalırdı.

⛔ **`toString()` ÇAĞRILMADI:** `42`yi `"42"`ye çevirmek, kullanıcının vermediği
bir beyanı **uydurmak** olurdu. Yanlış tipli alan `null`a düşer, sessizce
"kurtarılmaz".

### Kanıt
4 test: bozuk JSON · boş dosya · **geçerli JSON + yanlış tip** (çökme vakası) ·
**kısmi geçerlilik** (okunabilen alan korunuyor). Yanlış-tip testinde pozitif
çapa var: fixture'ın **gerçekten geçerli JSON** olduğu doğrulanıyor — olmasaydı
bir üstteki `FormatException` dalını tekrar ölçerdik ve test yeni hiçbir şey
söylemezdi.

**Kapılar:** app **229/229** (taban 225, +4) · engine **114/114** ·
python **20/21** (M-F-280) · `all_gates.py` TÜMÜ YEŞİL.
**C sayacı:** açılışta çökme sınıfı kapandı ⇒ **0**.

---

## L-327 — H-13'ün İKİNCİ YÖNÜ: Library **olmayan bir yeteneği vaat ediyordu**

`H-13` *"yapmadığımızı yapıyoruz dedik"* yönünü aileye bağladı. Kendi hattımda
taradım ve **bir vaka** çıktı — ve **`lib/`de değil `config/`de**.

### Bulgu

`config/ia/library.v1.json:51` — batarya ailesinin tanıtımı:
> *"Twelve camera-based movement tests. Each one measures a specific area,
> tells you what it could and could not see, **and feeds your daily plan**."*

Oysa **aynı derlemede** Home diyor ki:
> *"A daily routine is meant to be built from your own measurements. **The part
> of Lissom that builds it is not in this build**, so there is nothing here that
> would be yours."*

⇒ **İki yüzey, bir derleme, zıt iddia.** Ve bu cümle cihazda **iki yerde**
görünüyor (Library kartı + FamilyPage girişi) — yani `L-317`'nin ekran-içi
çelişkisinin **ekranlar-arası** kardeşi.

### Neden hiçbir kapım göremezdi

Bu gece kurduğum bayat-cümle kapısı **yalnız `lib/` altındaki Dart'ı** tarıyor.
İddia **config'te** duruyordu.
> ***BİR YETENEK VAADİ, ONU YALANLAYAN CÜMLEYLE AYNI DERLEMEDE YAŞAYABİLİR — VE
> İKİSİ FARKLI DOSYA TÜRLERİNDEYSE HİÇBİR KAPI İKİSİNİ BİRDEN OKUMAZ.***
`H-13`'ün uyarısı birebir tuttu: *"`lib/` yetmez: `content/`, onboarding,
yardım, dürüstlük kartı dahil."*

### Yapılan

Karşılıksız yan cümle **kaldırıldı** (kalan iki iddia ölçüldü ve DOĞRU: her test
belirli bir alanı ölçüyor · ne görüp göremediğini söylüyor — FamilyPage'in
engelli listesi ve sonuç yüzeyi bunu gerçekten yapıyor).
⛔ *"yakında gelecek"* diye **yazılmadı** — o bir vaat olurdu (M-F-186).

**Yeni kapı `config/` tarıyor** (bu gecenin ilk config kapısı): karşılıksız vaat
listesi + her birinin yanında **onu çürüten ölçüm**. Sabotajla kanıtlandı —
cümle geri kondu, kapı öttü ve **çürüten ölçümü de yazdı**; geri alındı,
kalıntı **0**.
📌 Listeye Gravita'nın `G-213` vakası (*"we tell you what to change"*) da
**önleyici** olarak eklendi: o cümle bu hatta hiç yoktu, ama sınıf ailede
ölçüldüğü için girmesini engelliyorum.

### Süpürmenin kapsamı — sayıyla
`config/**/*.json` tarandı; yetenek fiili taşıyan **4 aday** cümle bulundu, üçü
**doğru** çıktı (biri gerçek bir yeteneği anlatıyor, ikisi zaten olumsuz iddia).
⇒ Karşılıksız: **1/4**, ve o düzeltildi.

**Kapılar:** app **231/231** (taban 229, +2) · engine **114/114** ·
python **20/21** (M-F-280) · `all_gates.py` TÜMÜ YEŞİL.
**C sayacı:** kullanıcının iki yüzeyde gördüğü yanlış vaat kalktı ⇒ **0**.

---

## L-328 — **Yapabildiğin testler sana EN AZ şeyi söylüyordu** (H-17 ③, Library derinliği)

### Bulgu — asimetri, ve yönü ters

`FamilyPage`de **engelli 9 test** kendi gerekçesini taşıyordu (*"Shin angle —
the engine reads a limb against the line of your torso, not against upright…"*),
ama **canlı 3 test** yalnız **ad + ikon**.

Aile tanıtımı ise şunu vaat ediyor: *"Each one measures a specific area and
tells you what it could and could not see."*
⇒ Vaat **yapamadığın** testler için tutuluyordu, **yapabildiklerin** için hiç.

> ***DÜRÜSTLÜK MAKİNESİ YALNIZ BAŞARISIZLIKTA ATEŞLENİYORSA, KULLANICI ÜRÜNÜ
> EN ÇOK KULLANDIĞI YERDE EN AZ ŞEY ÖĞRENİR.***

### Ve içerik ZATEN YAZILMIŞTI

`TestSpec.instruction` config'te dolu (*"Stand side-on to the camera. Let your
arms hang…"*), `battery.dart` onu **ayrıştırıyor**, ve `lib/` altında **hiçbir
okuyucusu yok**. `L-178`'in sınıfı: **okuyucusu olmayan config alanı** — bu kez
eksik olan kod değil, **köprü**.
> *Yazılmış içeriği göstermek, yeni içerik yazmak değildir.* Uydurma yok.

Canlı satırlar artık talimatı alt satır olarak taşıyor — **engelli satırların
gerekçesiyle aynı slot, aynı görsel ağırlık.** Simetri: *canlı = NASIL yapılır ·
engelli = NEDEN olmaz.*
⛔ Boş talimat `null`a düşürülüyor: boş bir alt satır, bu gecenin **başlıklı
boşluk** sınıfını (A3) geri getirirdi.

### 🪤 Ve kendi eklemem MEVCUT bir testi kırdı — iki kez, iki ayrı sebeple

Sayfa uzayınca `family_page_test.dart`in *"NOT MEASURED BY CAMERA (9)"* araması
**bulunamadı** dedi. İddia yanlışlanmadı — **erişilemedi** (`ListView` katlama
altını kurmuyor).
> ***BİR YÜZEYE İÇERİK EKLEMEK, O YÜZEYDEKİ HER ARAMA TESTİNİN ERİŞİM
> VARSAYIMINI DEĞİŞTİRİR — VE KIRILAN TEST, KIRILAN İDDİA DEĞİLDİR.***

**İlk düzeltmem de yanlıştı:** `blockedListKey`e kaydırdım, hâlâ kırmızı —
çünkü listeye kaydırmak, onun **ÜSTÜNDEKİ başlığı** ekranın dışına itiyor ve
`ListView` onu bırakıyor. *Doğru sınıf, yanlış hedef.* Hedef **başlığın kendisi**
olunca geçti. ⛔ Testi gevşetmedim: iddia aynen duruyor, yalnız erişim eklendi.

### Kanıt
Ölçüm ÖNCE yazıldı ve **kırmızı** yandı (*"canlı test yalnız AD gösteriyor"*),
sonra düzeltme yeşile çevirdi. **Cihazda doğrulandı**: üç canlı testin üçü de
talimatını taşıyor, tanıtım cümlesi `L-327` sonrası hâliyle doğru.

**Kapılar:** app **232/232** (taban 231) · engine **114/114** ·
python **20/21** (M-F-280) · `all_gates.py` TÜMÜ YEŞİL.
**C sayacı:** kullanıcı artık yapabildiği testin nasıl yapıldığını görüyor ⇒ **0**.

---

## L-329 — Kardeş dalı ölçtüm: **kusur yoktu**, ama kapı da yoktu

`L-325` *"hepsi okunamayan"* dalını düzeltti. Kardeş dalı — **kısmen** okunan
liste — ölçtüm: taban uyarısı **zaten doğru çalışıyor**, okunamayan sayı yüzeyde.
> *Bir kusuru bir dalda kapatmak, kardeş dalı ölçmüş olmaz* — ve bu kez ölçüm
> **temiz** çıktı. Bunu bir başarı değil bir **ölçüm** olarak yazıyorum.

⚠️ Ama **kapsam boşluğu gerçekti:** `countsAreFloor`/taban uyarısının Progress
tarafında **hiç testi yoktu** (arama: yalnız `home_screen_test` kısmi hâli
sınıyordu). Yani davranış doğruydu ve **korumasızdı** — bir sonraki düzenleme
onu sessizce düşürebilirdi.
> ***DOĞRU DAVRANAN KORUMASIZ KOD, KUSURLU KODDAN YALNIZ ZAMANLAMAYLA
> AYRILIR.***

Kapı eklendi ve **sabotajla kanıtlandı**: taban uyarısı devre dışı bırakıldı →
kapı öttü (*"okunamayan 3 kayıt hiçbir yerde söylenmiyor — kullanıcı listesini
TAM sanır"*), geri alındı, kalıntı **0**.

**Kapılar:** app **233/233** (taban 232, +1) · engine **114/114** ·
python **20/21** (M-F-280) · `all_gates.py` TÜMÜ YEŞİL.
**C sayacı:** kullanıcı yüzeyi değişmedi (kusur yoktu); değişen **korumasız bir
davranışın kapılanması**. Sayaç **1** — üst üste ikinci "hiçbir şey"de dururum.

---

## L-330 — H-24 ②'yi kendi hattımda koştum: **kurulum tarifi yazılıydı, ayrıştırıcısı bile yoktu**

### Süpürme — payda ve DARALTMA işlemiyle

`H-24` sordu: *"config/content içinde okuyucusu olmayan alan var mı?"*
Mekanik tarama: **222 config anahtarı**, kodda hiç geçmeyen **91**.
⛔ 91 ham sayı bir bulgu DEĞİL — çoğu motor eşiği, sözlük anahtarı, ya da
Türkçe geliştirici notu. **Daraltma yazılı:** yalnız **düzyazı taşıyan** alanlar
(≥45 karakter, boşluklu) ⇒ **42**; bunların okuyucusu olmayanı ⇒ **20**.
Yirmisini tek tek sınıflandırdım:
- **Doğru şekilde uykuda (19):** `_purpose`/`_fatigueNote` (alt çizgi = dahili) ·
  faz belgeleri (Türkçe) · `rationale`/`warning`/`passiveExecutionRationale`
  (geliştirici gerekçesi) · `disclaimers.en.json`ın **yasak-ifade → güvenli
  yeniden yazım** sözlüğü (kapı katmanı okuyor, `lib/` değil — doğru) ·
  `exercise-pool` alanları (**inşa edilmemiş** bir kütüphanenin içeriği;
  göstermek yanlış olurdu).
- **Gerçek köprü eksiği (1):** `globalCameraSetup`.

> *Bir taramanın ham sayısı bulgu değildir; bulgu, daraltmanın SONUNDA kalan
> ve tek tek okunmuş olandır.*

### Bulgu

`globalCameraSetup` — mesafe `[180,200] cm`, yükseklik `[90,110] cm`, kadraj
kuralı, yaw toleransı `10°`. **Ayrıştırıcısı bile yoktu** (`Battery` bu bloğu
hiç okumuyordu), dolayısıyla hiçbir yüzeye ulaşmıyordu.
⇒ Kullanıcı telefonu nereye koyacağını **bilmiyordu**, ama ölçüm sonradan
*"kadraj yüzünden okunamadı"* diyebiliyordu.
> ***BİR ÜRÜN, BAŞARISIZLIĞIN SEBEBİNİ SONRADAN SÖYLEYEBİLİYORSA, ONU ÖNCEDEN
> DE SÖYLEYEBİLİR.***

`L-328`de köprünün **UI yarısı** eksikti; burada **ayrıştırıcı yarısı da** yoktu.

### Yapılan

`CameraSetup` (engine) + *"Before you start"* kartı (`LiveCaptureScreen`, ölçüm
denemesinden ÖNCE). Her satır config'ten **türetilir**; eksik alan **satırı
düşürür**, uydurma değer üretmez.
⛔ Blok yoksa `parse` **`null`** döner ve kart **hiç çizilmez** — boş bir
*"Before you start"* başlığı, bu gecenin **A3 başlıklı-boşluk** sınıfı olurdu.
⛔ Bozuk aralık (`[180]` · `[200,180]` · `["a","b"]`) **düşürülür**: *"180 ile
180 arası"* diye bir tarif yoktur ve eksik aralığı tamamlamak uydurmaktır. Ama
**sağlam alan korunur** — `L-326`'nın alan-başına tolerans dersi, bu katmanda.

**Cihazda doğrulandı:** dört satır da yüzeyde, ölçüm ekranının en üstünde.

**Kapılar:** app **236/236** (taban 233, +3) · engine **114/114** ·
python **20/21** (M-F-280) · `all_gates.py` TÜMÜ YEŞİL.
**C sayacı:** kullanıcı artık telefonu nereye koyacağını biliyor ⇒ **0**.

## L-331 — H-26 sabotajı: gerçek son kayıt biçim değiştirince araç KAYBETMİYOR — naif okuyucu KAYBEDİYOR

**H-26 işlendi.** YAYIN YOLU rejimi (H-28) başladı; F1'in ilk kalemi bu.

### Ölçüm — defter gerçekten karma mı

`grep -cE "^\| L-[0-9]+"` → **257** · `grep -cE "^#+ L-[0-9]+"` → **80**.
İkisi de sıfırdan büyük ⇒ H-26'nın tarifiyle bu defter **karma biçimde**
(postmortem'deki iki hattın kendisi gibi — Lissom da o sınıfta).

### Sabotaj — H-26'nın tarif ettiği tam senaryo, önceki testten FARKLI

`_self_test()`in eski ① testi ELDEKİ bir örneği **ID'sini bozarak** gizliyordu
(`L-255` → `xx-000`); biçim hiç DEĞİŞMİYORDU. H-26'nın postmortemi başka bir
şey anlatıyor: *biçimin kendisi* ortada değişti. İkisi farklı sabotaj, farklı
kanıt — biri "bozuk ID kaybolur mu", öbürü "biçim değişince kaybolur mu".

Gerçek son kaydı (`L-330`, başlık biçimi) aldım, satırının **yalnız başlık
jetonunu** (`## ` → `| `) çevirdim, gövdeye dokunmadım — tıpkı postmortem'in
anlattığı "bir hat ortada biçim değiştirdi" durumu. İki okuyucuyla okudum:
- `_ENTRY` (bu aracın geniş okuyucusu, `#+ ` ve `\| ` ikisini de tanır) →
  **hâlâ görüyor**.
- Yalnız eski biçimi arayan NAİF okuyucu (`^#+ (L-\d+)`) → **körleşti**,
  tam H-26'nın *"satır başında boru arayan her sayaç"* dediği gibi.

İki sonuç ZIT çıkmalı, çıktı — `_self_test()`e ⑨ olarak eklendi (10/10).

> ***BU ARAÇ POSTMORTEM'İN TARİF ETTİĞİ KÖRLÜĞE ZATEN BAĞIŞIKTI — AMA BU
> BAĞIŞIKLIK HİÇ GERÇEK SON KAYITLA SINANMAMIŞTI.***

### Yapılan

`tools/defter_freshness.py` `_self_test()`e ⑨. numaralı kontrol eklendi:
son kaydı bulur (`_ENTRY.finditer(text)[-1]`), başlık jetonunu öbür biçime
çevirir, geniş+naif okuyucuyla karşılaştırır. Kod değişikliği yok, DEFTER
kaydı yok — bu bir test-only ekleme, `kod_iddia_eden` onu KOD saymaz (doğru:
`.py` değişikliği var ama `Kapanış kanıtı` alanı bunu anlatıyor).

**Kapılar:** app **236/236** · engine **114/114** · python **20/21**
(M-F-280) · öz-test **10/10** (+1, `tools/defter_freshness.py`) ·
`all_gates.py` TÜMÜ YEŞİL.
**C sayacı:** değişmedi — bu iş kullanıcı yüzeyi değil, H-26 alet
sağlamlaştırması; sayaç yalnız kullanıcı-görünür değişiklik sayar.

## L-332 — H-27 taraması: **iki iş de temiz çıktı**, ama korumanın şekli farklı

**H-27 işlendi.**

### İş 1 — `tools/` içinde depo-dışına çıkan yol var mı

`grep -rn 'parent /' tools/` → **0 isabet**. `grep -rn 'parents\[' tools/` →
**5 isabet**, hepsi `parents[1]` (= `tools/`'dan bir üst = repo kökü, doğru).
`grep -rn '\.parent\.parent'` → **20 isabet**, hepsi aynı derinlik (repo
kökü) — `parents[1]`in eşdeğeri, farklı yazım. Kalan iki `.parent` kullanımı
(`l031_space_divergence.py:127`, `all_gates.py:95`) `__file__`den değil,
**taranan bir dosyanın** kendi klasörünü buluyor — ikisi de repo İÇİNDE
kalıyor. ⇒ **Lissom'un H-27 bulduğu `ROOT.parent / "workspace"` sınıfından
hiçbir kalıntı yok** — beklenen: bu hat kendi kapısını (`defter_freshness.py`)
zaten `H-27`nin KENDİSİNDE düzeltmişti (mühür `aa2075c`), tarama bunu
DOĞRULUYOR, yeni bir şey bulmuyor.

### İş 2 — `⚪ ORTAM YOK` ile geçen kapı sayısı

`grep -rln "ORTAM YOK\|⚪\|ortam eksik" tools/` → **1 isabet**, ve o da
`defter_freshness.py`'nin DOCSTRING'inde H-27'nin kendi hükmünü anan bir
CÜMLE (*"...yokluğu ortam eksikliği değil, gerçek bir kayıp demektir"*) —
kod dalı DEĞİL. Gerçek kod tarafında: `defter_text()` defter yoksa artık
`SystemExit` **fırlatıyor** (H-27'nin kendi düzeltmesi). ⇒ **canlı `⚪ ORTAM
YOK` bypass'ı sıfır.**

### Kapsam boşluğu — H-25'in sorusunu sordum

*"Kusur yok" demek durmak değil* (`L-329`/`H-25`): bu doğru duruşu kim
KORUYOR? Cevap **kısmi**: `all_gates.py` her aracı GERÇEKTEN çalıştırıyor,
yani yanlış bir `parents[N]` derinliği (elle yazılmış bir gelecek commit'te)
bir sonraki koşuda **hemen** patlar (`FileNotFoundError`/`SystemExit`) —
bu YÜRÜTME-zamanlı bir koruma, ölçüldü, gerçek. Ama STATİK bir kapı
(commit ÖNCESİ, `.py` dosyasını hiç çalıştırmadan "yanlış derinlik" desenini
yakalayan) **yok**. Bunu yeni bir alet olarak ŞİMDİ kurmadım — 20 dosyayı
tarayan bir statik-lint, bu turun tek-kalem disiplinini aşardı ve H-27'nin
kendi fiili ("bakın", "sayın") bunu istemiyor. **Orkestratöre not düşüyorum**,
F1'in geri kalanına devam ediyorum.

**Kapılar:** app **236/236** · engine **114/114** · python **20/21**
(M-F-280) · `all_gates.py` TÜMÜ YEŞİL (kod değişikliği yok, yalnız tarama).
**C sayacı:** değişmedi — kullanıcı yüzeyi değil, H-27 alet denetimi.

## L-333 — D4 + D10: sürüm `1.0.0+1`, `TARGETED_DEVICE_FAMILY=1` (iPhone-only)

**D4:** `pubspec.yaml` sürümü `0.1.0+1` → **`1.0.0+1`**. Build numarası `1`de
kaldı (ilk yayın adayı) — yalnız MARKA (major.minor.patch) 1.0'a geçti.

**D10:** `ios/Runner.xcodeproj/project.pbxproj`'daki üç build config'in
(Debug/Release/Profile) hepsinde `TARGETED_DEVICE_FAMILY = "1,2"` (iPhone+iPad)
idi → **`1`** (yalnız iPhone) — plan kararıyla eşleşti (D10, iPad V1 kapsamı
DIŞINDA).

**Doğrulama:** `plutil -lint` → **OK** (pbxproj bozulmadı) ·
`xcodebuild -showBuildSettings` → `TARGETED_DEVICE_FAMILY = 1` **gerçekten
ÇÖZÜLÜYOR** (yalnız dosyada yazılı olması yetmez — Xcode'un okuduğunu
ölçtüm). ⛔ `flutter build ios` KOŞULMADI (H-4 kendi tuzağım: depoyu
kirletir) — build-settings sorgusu artefakt üretmeden aynı doğrulamayı verdi.

**Kapılar:** app **236/236** · engine **114/114** · python **20/21**
(M-F-280) · `all_gates.py` TÜMÜ YEŞİL.
**C sayacı:** kullanıcı yüzeyi değişmedi (mağaza metadatası); F4'ün ön-koşulu
kapandı.

## L-334 — F1'in son kalemi zaten KAPALIYDI: skipped-sayısı boş-hâl kartında (L-325'in ürünü)

### Ölçüm

YAYIN-YOLU-LISSOM.md'nin F1 listesi *"Skipped-kayıt sayısını boş-hâl kartına
düşür (L-324 📌 — kendi kalemin)"* diyor. Kodu okudum: `progress_screen.dart:222-232`
zaten `!h.hasRecords && h.unreadable > 0` dalında *"Your readings are here,
but we cannot read them"* kartını sayıyla birlikte çiziyor (`${h.unreadable}
recorded reading(s) could not be read...`); `h.countsAreFloor` dalı
(251-252) kısmi durumda `_floorBanner`i sayıyla çiziyor. `home_screen.dart`
aynı deseni `_floorNote` ile tekrarlıyor (343). `library_screen.dart`
kontrol edildi — session-history DEĞİL, statik içerik kataloğu gösteriyor,
bu kalemin kapsamı dışında.

### Neden zaten kapalı

`L-324`'ün 📌'si *"ayrı bir kalem"* olarak not düşülmüştü — ve **aynı gece,
hemen ardından `L-325` onu kapatmıştı** (*"OKUNAMAYAN GEÇMİŞ, BOŞ GEÇMİŞ
DEĞİLDİ"*, `C-280`/`H-13`), `L-329` kardeş dalını (kısmi okunan liste)
ayrıca doğrulamıştı. Üçü de **sabotajla kanıtlı** — öz-testler
`test/home_screen_test.dart` + `test/progress_depth_test.dart`ta yaşıyor
(grep doğruladı, `unreadableAllKey`/`countsAreFloor`/`SessionHistoryView.partial`
anahtarlarıyla).

⇒ Bu kalem YAYIN-YOLU dosyasına yazılırken **L-325/L-329 hesaba
katılmamış** — kendi `H-26` hükmümün anlattığı sınıfa yakın bir hata, ama bu
kez orkestratörün defter-özetinde: kapanmış bir 📌, açık kalem gibi
taşınmış. **Kod DEĞİŞMEDİ** — bu turun kanıtı, bulgunun kendisi.
Orkestratöre raporda düzeltiyorum.

**Kapılar:** app **236/236** · engine **114/114** · python **20/21**
(M-F-280) · `all_gates.py` TÜMÜ YEŞİL (kod değişikliği yok, yalnız ölçüm).
**C sayacı:** değişmedi — bu tur bir ÖLÇÜM, kod kalemi değil.

---

## L-335 — H-31: `CLAUDE.md`'nin bayat KOD BAŞLATMA KİLİDİ düzeltildi

Koordinatör ölçtü: `CLAUDE.md` satır 4 hâlâ *"kurucu 'Lissom'a başlayalım'
demeden üretim kodu YAZILMAZ"* diyordu — **210+ commit'lik, 330+ kayıtlı bir
depoda**, ve bu dosya **her yeni oturumun ilk okuduğu dosya** (kendi açılış
protokolümün de ilk adımı). Bir kilit, kilitlediği şey çoktan açılmışken
duruyorsa artık kilit değil, **yanlış bilgidir**.

### Yapılan

`## 🔒 KOD BAŞLATMA KİLİDİ` başlığı `## 🚀 GÜNCEL REJİM — YAYIN YOLU (H-28)`
oldu: güncel yetki (`YAYIN-YOLU-LISSOM.md` + posta kutusu yolu, kalıcı
commit/push/merge izni, BEŞ ŞEY kurucuya/tasarım orkestratöre) baş satıra
çıktı. Eski V0-öncesi sıra **silinmedi** — *"ARTIK BAĞLAYICI DEĞİL — tarihsel"*
etiketiyle altına taşındı, çünkü tarihi silmek "neden V0 diye bir kapı
vardı"yı okunamaz yapardı (`H-27`nin kendi dersi: *"bir bağımlılık sabit
yazılmadıysa yok demek değildir"* — burada tersi: **eski bir gerçeği silmek**
onu hiç var olmamış gösterir).

⚠️ **Fark ettim, dokunmadım:** eski kilidin `V0 kapısı` maddesindeki `D4`
(*"yoga içerik katmanının D4"*) ile bu turun kendi `D4`ü (pubspec sürümü,
`L-333`) **AYNI HARF, FARKLI KARAR** — iki ayrı plan neslinin numaralandırması
çakışıyor. Notunu düştüm (*"eski plandaki D4, YAYIN-YOLU'nun D4'ünden
FARKLI"*), yeniden numaralandırma YAPMADIM (`L-305`nin dersi: numarayı
değiştirmek ona işaret eden her atfı sessizce bozar).

**Kapılar:** app **236/236** · engine **114/114** · python **20/21**
(M-F-280) · `all_gates.py` TÜMÜ YEŞİL (yalnız `CLAUDE.md`, kod değişikliği yok).
**C sayacı:** değişmedi — kullanıcı yüzeyi değil, H-31 doküman düzeltmesi.

---

## L-336 — H-35 (Gravita kalıcı hasarı): `tavan` yanlış okuyucudan türüyordu, ACİL düzeltildi

**Bulan orkestratör, kanıtlayan Gravita'nın kendi kazası.** Gravita bir
sabotaj denemesini (yürütmedi, geri aldı) commit GÖVDESİNDE anlattı; YÖN-2
okuyucusu (başlık+gövde geniş) o numarayı gerçek sandı ve `ters_yon()`ün
`tavan`ını **kalıcı** şişirdi (git geçmişi geri alınmaz) — sonraki HER
gerçek kayıt artık erişilemez bir tavanın altında kalıp izsiz görünüyor ve
pre-commit kapısında reddediliyor.

### Kendi dosyamda AYNI yapı vardı — okudum, doğruladım

`tools/defter_freshness.py:250` (düzeltmeden önce): `tavan = max((_num(i)
for i in trace), default=0)` — `trace = commit_trace()`, YÖN-2'nin geniş
(BAŞLIK+GÖVDE) okuyucusu. Bu benim `L-311` docstring'imin kendi yazdığı
kuralı 100+ satır aşağıda çiğniyordu: *"SÖZÜNÜ ETMEK ≠ İDDİA ETMEK — ve bu
kural, kapıyı genişletirken en kolay unutulan yerde, GÖVDEDE çiğnenir."*
Kendi dersimi yazmış, uygulamamıştım (`H-24`nin en keskin hâli).

### Yapılan

`tavan` artık `commit_ids()`ten (YÖN-1, BAŞLIK-yalnız geniş) türüyor —
*"en yüksek İDDİA EDİLMİŞ kayıt hangisi"* bir YÖN-1 sorusu, YÖN-2'nin değil.
**Üyelik testi (`izsiz`/`ucusta` ayrımı) GENİŞ KALDI** — `trace` hâlâ
`commit_trace()`ten geliyor, çünkü o gerçekten bir VARLIK sorusu ("bu
kaydın izi var mı, nerede olursa olsun"), sahiplik değil. Yalnız EŞİK
kaynağı değişti. Öz-test ⑧ (uçuş kuralı) da AYNI kaynağa geçirildi —
`ids_iddia = commit_ids()` — yoksa test kendi REFERANS tavanını implementasyonla
UYUŞMAYAN bir kaynaktan hesaplardı ve ikisi ayrışabilirdi.

⛔ **Gerçek bir git commit'iyle repro DENEMEDİM** — orkestratörün kendi
uyarısı (prob numarasını yüksekten seçmek zehri KALICI yapar) tam bu riski
anlatıyor. Kanıt onun yerine: (a) `ters_yon()`ün docstring'i mekanizmayı
adıyla yazıyor, (b) öz-test ⑧ artık `tavan`ı **implementasyonla AYNI
kaynaktan** türetip üstü/altı davranışını hâlâ doğru sınıyor (10/10),
(c) `commit_ids()`/`commit_trace()` ikisi de değişmedi — yalnız hangi
FONKSİYONUN çağrıldığı değişti, yani mevcut 400 commit'lik pencerede
regresyon riski yok.

**Kapılar:** app **236/236** · engine **114/114** · python **20/21**
(M-F-280) · öz-test **10/10** · `all_gates.py` TÜMÜ YEŞİL.
**C sayacı:** değişmedi — kullanıcı yüzeyi değil, alet-bütünlüğü acil
düzeltmesi.

---

## L-337 — F2/D13 yazma yolu: `attempt_values.jsonl` yaşıyor, LiveCaptureScreen ona da yazıyor

### Keşif — değer TAM OLARAK nerede düşüyordu

`AssessmentResult.value` (ölçülen açı) `assessment_history.dart:recordFor()`de
çekirdeğin `SessionRecord`una çevrilirken düşüyordu — **çekirdeğin kendi
KASITLI kararı**, kendi başlığında yazılı: *"attempt-level provenance...
is attempt-level data, this is a session-level record."* Çekirdek bunu APP
katmanının taşımasını BEKLİYORDU; hiç kurulmamıştı. `measurement_value_
persistence_test.dart` (L-316) bu kaybı zaten kilitlemiş, sabotajla
kanıtlamıştı — o dosyaya DOKUNMADIM, çünkü hâlâ DOĞRU: `ProgressScreen`
henüz yeni depoyu okumuyor (bu turun kapsamı yalnız YAZMA).

### Yapılan

`lib/app/attempt_values.dart` — `AttemptValue` + `JsonlAttemptValueStore`,
`motion_core`un `JsonlSessionStore`ıyla AYNI güvenlik özellikleri (pinli
`f13bdc9`'dan okundu, KOPYALANMADI çünkü çekirdeğin private yardımcılarına
erişim yok — desen bilinçli tekrar): atomik tmp+rename yazım, `v` şema
alanı (H-21), dizin/dosya ayrımı (M-F-251), bozuk-satır sayılı toleransı
(M-F-228). `lessonId`+`completedAt` çekirdek kaydıyla AYNI anahtarla
kurulur — ayrı bir yabancı-anahtar şeması icat edilmedi.

`LiveCaptureScreen._persist()` artık İKİ yazıyor (yalnız ölçülmüş
denemede — `notMeasured`ın değeri yok): oturum kaydı (değişmedi) + deneme
değeri (yeni). **`_saved` yalnız İKİSİ DE başarılıysa `true`** — biri
düşüp diğeri geçerse "kaydedildi" demek, sayının kaybını gizlemek olurdu
(L-316'nın kendisi, bir katman derinde).

### Sabotaj — üçlü (task #9'un ilk yarısı)

`test/attempt_values_test.dart` (9 test): gerçek yazıp-okuma turu + bozuk
satır + yanlış-tip değer + bilinmeyen şema + eksik `v` alanı + atomik
yazımın `.tmp` kalıntısı bırakmadığı. Hepsi `unreadableRecords()`e SAYILI
taşınıyor mu diye sınandı, hiçbiri sessizce yutulmuyor.

`test/measurement_persistence_test.dart` güncellendi: `_RecordingAttemptValueStore`
eklendi, ekranın İKİNCİ yazmayı GERÇEKTEN çağırdığını + depoya giren sayı
ile ekranda GÖSTERİLEN sayının AYNI olduğunu doğruluyor (sabit bir değer
VARSAYMADIM — ilk denemem `168` yazdı ve YANLIŞTI, gerçek motor `180.0`
üretti; düzeltme ekranla çapraz-doğrulamaya geçti, bir dahaki fixture
değişikliğinde de kırılmaz).

⛔ **BİTMEDİ:** `ProgressScreen` henüz `attempt_values.jsonl`ı okumuyor —
SON DEĞER/trend çizimi ve L-321'in "not kept" kartı güncellemesi SIRADA,
AYNI round'da kapanacak (koordinatör hükmü bağlayıcı).

**Kapılar:** app **245/245** (taban 236, +9 — yalnız yeni test dosyası,
mevcut testler DEĞİŞMEDİ sayıca) · engine **114/114** · python **20/21**
(M-F-280) · `all_gates.py` TÜMÜ YEŞİL.
**C sayacı:** henüz **0** — yazma yolu kullanıcı yüzeyine ULAŞMADI (Progress
hâlâ eski kartı gösteriyor); sayaç F2'nin okuma+kart turunda hareket eder.

---

## L-338 — H-35'in ikinci yarısı: `SENTINEL_RANGE`/`PROBE_IDS` (Ostinato/Gravita emsali)

Orkestratör uyardı: yapısal panzehir (tavan `commit_ids()`ten türer, `L-336`)
**tek başına yetmez** — Gravita `G-223`/`G-224` ölçtü, bir prob numarası
YÖN-1 VE YÖN-2'yi BİRDEN bozabilir. Panzehrin İKİ yarısı TAMAMLAYICI, biri
ötekinin yerine geçmez.

`SENTINEL_RANGE = range(900, 1000)` (gelecekte bir prob numarası gerekirse
BURADAN seçilir) + `PROBE_IDS: set[int] = set()` (BİLİNÇLİ boş — bu hat
hiçbir zaman gerçek bir commit'le canlı sabotaj denemedi; `L-336`'nın kendi
kaydı) eklendi, `ters_yon()`ün `izsiz` hesabına ikinci bir filtre olarak
girdi. Sibling'lerden KOPYALANMADI — Gravita'nın `linked`/`_TYPED` yapısı
benim `kod_iddia_eden`/`commit_trace` yapımla birebir örtüşmüyor, desen
çevrildi.

### ⚠️ Dürüst sınır — bu turda ÖLÇMEDİĞİM şey

`izsiz` süzgeci `_num(c) <= tavan` şartına BAĞIMLI; `SENTINEL_RANGE`
(900-999) bugünkü tavanın (337) ÇOK üstünde, yani bugün `izsiz`e hiç
ULAŞAMAZ — bu filtre şu an **ölü kod gibi davranıyor**, aktif değil.
Asıl koruyan şey Gravita'nın gerçek vakasındaki gibi `PROBE_IDS`e (tavanın
ALTINDA bir numara) bir gün bir şey eklenirse devreye girecek olması.
Sentetik bir ⑩ öz-testiyle "gerçekten ateşliyor mu" SINAMADIM — mevcut
⑦/⑧ (sentetik numaralarla çalışıyor) hâlâ geçiyor, yani filtre var olan
DAVRANIŞI bozmuyor, ama YENİ davranışı POZİTİF kanıtlamadım. Kayıt bunun
için: bir sonraki tur bunu "kanıtlanmış" sanmasın.

**Kapılar:** öz-test **10/10** (değişmedi) · app **245/245** ·
engine **114/114** · python **20/21** · `all_gates.py` TÜMÜ YEŞİL.
**C sayacı:** değişmedi — alet-sağlamlaştırma, kullanıcı yüzeyi değil.

---

## F1 KAPANDI — dört kalem, dördü de kapalı (biri zaten kapalıydı)

`L-331` (H-26 sabotajı) · `L-332` (H-27 taraması) · `L-333` (D4+D10) ·
`L-334` (L-324 kalemi zaten kapalıydı, düzeltme). Kapılar boyunca **TÜMÜ
YEŞİL**, taban büyümedi (app 236, engine 114 — F1 davranış değiştirmedi,
alet+metadata sağlamlaştırdı). Sıradaki: F2 — deneme değeri saklama (D13).
