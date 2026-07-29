# M-TALEBİ — `romMode` kapsamı: pasif icra her testte mümkün değil

**Karar:** M-F-43 (kaynak-uygunluk, fail-closed) · **Tarih:** 2026-07-29
**Statü:** M-F-43 UYGULANDI ve doğru; bu talep kuralı **gevşetmiyor**, kapsamını netleştiriyor.

## 1. Uygulama tamam, ama ölçüm bir sorun gösteriyor

`romMode` rig'e bağlandı (`d4aa150`): fail-closed, karışık kaynak = passive, provenance'a akıyor, blok [7] 7/7. Lissom'un 4 kaynağı `active=1 · passive=2 · unknown=1` → `overhead_reach` referansı **kurulmadı**. Karar doğrulandı.

Sonra kuyruğun tamamını (272 aday) başlıktan ön-sınıflandırdım:

| | aday | oran |
|---|---|---|
| active | 4 | %1,5 |
| passive | 10 | %3,7 |
| **unknown** | **258** | **%94,9** |

**Başlıklar modu söylemiyor.** "Deep Squat Assessment", "How To Test Ankle Mobility" gibi başlıklar hiçbir işaret taşımıyor. Fail-closed kural + başlık-tek kanıt = kuyruğun %95'i elenir.

## 2. Birinci sonuç: transkript artık OPSİYONEL DEĞİL

Gece boyunca `--no-transcribe` ile koştuk (hız için). `romMode` devreye girdiğine göre transkript **zorunlu aşama** olmalı: en güçlü işaretler yalnız konuşmada geçiyor (*"just relax, I'll move it for you"*, *"I'm going to take your leg"*) ve başlıkta asla görünmüyor. Rig zaten transkript sonrası yeniden sınıflandırıyor; eksik olan, transkriptin atlanabilir olması.

**Öneri:** referans-türetimi hedefleyen hasatta `--no-transcribe` YASAK (ya da `romMode` etkinken sert hata). Maliyet: aday başına whisper-small.

## 3. İkinci sonuç — asıl talep: pasif icra her testte MÜMKÜN DEĞİL

M-F-43'ün gerekçesi şu: *pasif ROM'da aralığı klinisyen üretir ve aktiften geniştir.* Bu gerekçe **izole eklem** testleri için geçerli — klinisyen kolu kaldırabilir, bacağı kaldırabilir, ayak bileğini bükebilir.

Ama **ağırlık taşıyan / tüm-vücut** görevlerinde pasif icra fizyolojik olarak imkânsızdır. Kimse birine pasif olarak squat yaptıramaz, plank tutturamaz, tek ayak üzerinde dengede durduramaz. Bu testlerde `unknown` bir belirsizlik DEĞİL: mod zaten aktif olmak zorunda.

| sınıf | testler | aday | pasif icra |
|---|---|---|---|
| ağırlık taşıyan | `deep_squat` `overhead_squat` `hip_hinge` `single_leg_balance` `forward_lunge` `plank_hold` | **114** | **imkânsız** |
| izole eklem | `overhead_reach` `active_straight_leg_raise` `hamstring_reach` `ankle_dorsiflexion` `thoracic_rotation` `lateral_bend` | 127 | mümkün — kural ŞART |
| yoga | duruşlar | 31 | imkânsız (kendi ağırlığı) |

**Öneri:** batarya her teste `passiveExecutionPossible: true|false` beyan etsin (varsayılan `true` = muhafazakâr). `false` olan testlerde `unknown` referansa girebilir; `passive` işareti bulunursa **yine dışarıda kalır** — çünkü o durumda kaynak muhtemelen o testi göstermiyordur.

Bu kuralı gevşetmek değil, **doğru yere uygulamak**: fail-closed disiplini pasif icranın mümkün olduğu yerde korunuyor, mümkün olmadığı yerde 114 adayı gereksiz yere bloke etmiyor.

**Ölçek uyarısı:** bu benim tek-app gözlemim. Gravita'nın ağırlık-taşıyan hareketlerinde aynı ayrım geçerli olmalı; JabLab/Choreia/Ostinato'da pasif icra kavramı zaten karşılıksız olabilir. Kararı aile düzeyinde vermeniz gerekiyor — ben `passiveExecutionPossible` alanını beyan etmeye hazırım ama **onay gelmeden Lissom'da etkinleştirmiyorum.**

## 4. Bu arada engellenmeyen iş

`lateral_bend` başlıktan **3 aktif** kaynak çıkarıyor — M-F-38'in ≥3 eşiğini karşılayan tek test. Referans denemesi için sıradaki aday orası; `overhead_reach` ise aktif kaynak bulunana dek beklemede.
