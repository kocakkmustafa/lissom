# Çelişki-kapısı envanteri — SIRA② (koordinatörün 3. sevki, A2)

> Ostinato MUT-A'nın (`tools/mutation_lock.py`'nin taşıdığı) asıl hedefi
> **ÇELİŞKİ kapıları**: iki bağımsız kaynağı karşılaştıran, ve "iki kaynağı
> BİRDEN tutarlı bozarsan yine yeşil kalabilen" kapılar. Bu envanter MUT-A'yı
> hedefsiz koşturmamak için — mutasyonların KENDİSİ burada değil, bir SONRAKİ
> tur.

**Yöntem:** 38 test dosyasının tamamının başlık/docstring'i okundu (mekanik
grep değil — her dosyanın "ne ölçtüğünü" anlatan kendi cümlesi). Sınıflandırma
iki eksende: **kaç bağımsız kaynak karşılaştırıyor** (1 = VARLIK, ≥2 = ÇELİŞKİ)
ve **MUT-A'nın "iki kaynağı birden" sınavını daha önce geçmiş mi**.

## ⭐ DÜZELTME (2026-08-12, koordinatör onaylı) — 13 değil 3

İlk sürüm 13 kapıyı "ÇELİŞKİ" saydı. Yeniden ölçüldü: çoğu **config
(VERİ) ↔ render edilen widget (AYNI veriden TÜREYEN kod)** biçiminde —
Ostinato'nun MUT-A'sı ise **iki BAĞIMSIZ veri dosyasını** (ruleset JSON ↔
reference-artefakt JSON) mutasyona uğratıyor. Bunlar FARKLI risk sınıfları:

- **Tek kaynak → kod dönüşümü riski.** Veri BİR yerde yaşar, widget ondan
  TÜRER. Risk: *rendering kodu veriyi yanlış/eksik yansıtır mı* — bu VARLIK
  kapısının işi (aşağıdaki tabloda ayrı sınıflandırıldı, silinmedi).
- **İki bağımsız kaynak → sürüklenme riski.** İki dosya AYRI AYRI elle
  düzenlenebilir. Risk: *ikisi birbirinden bağımsız yanlış yönde
  sürüklenir, ya da BİRLİKTE tutarlı-yanlış hâle getirilirse kapı bunu
  YAKALAMAZ* — MUT-A'nın asıl hedefi bu, ve yalnız üç kapıda gerçekten var.

Aile dersi: *bir çelişki kapısı iki BAĞIMSIZ kaynağı karşılaştırmalıdır;
aynı kökten türeyen iki temsil, ne kadar farklı GÖRÜNÜRSE görünsün,
birlikte sürüklenir ve mutasyon onları birlikte bozar — yani sınav yapmış
olmaz.*

---

## ÇELİŞKİ kapıları — MUT-A'nın GERÇEK hedefi (3)

| Dosya | İki BAĞIMSIZ kaynak | MUT-A geçmişi |
|---|---|---|
| `pin_equality_test.dart` | `pubspec.lock` (git tarafından yönetilir) ↔ test dosyasındaki MÜHÜRLÜ sabit (elle yazılır) ↔ sürüm çifti | ✅ ZATEN 3-çapalı, "ikisi de aynı YANLIŞ commit'te" sınıfına karşı ÇAPA 2 kurulu (Ostinato deseninin aynısı) — **en iyi örnek** |
| `metric_coverage_test.dart` | `config/tests/lissom-assessment.v1.json` (JSON, tasarımcı düzenler) ↔ `kMetricBindings`/`kUnbridgedMetrics` (`metric_bridge.dart`'ta HARDCODED Dart sabitleri, mühendis düzenler) | 🔴 **SABOTAJLA KANITLANDI, KORUMASIZ (2026-08-12, `tools/mutation_metric_coverage.py`).** Üç sahne, ÜÇÜ DE `flutter test` (TAM CÜMLE, `lissom_engine`) 103/103 yeşille geçti — hiçbiri `metric_coverage_test.dart`ın BÖLME/OKUNABİLİRLİK testlerince yakalanmadı: **(A)** ÇALIŞAN bir binding kaldırılıp aynı metrik "engellendi" diye beyan edilirse (bölme denklemi bir metriğin `bridged`↔`declared` YER DEĞİŞTİRMESİNİ hiç GÖREMEZ — config sabit kaldığı sürece). **(B)** "çekirdekte imkânsız" denen bir metrik YANLIŞ bir `coreJointId`yle köprülü sayılırsa ("gerçekten OKUNABİLİYOR" testi yalnız `returnsNormally` diyor, DOĞRU eklem mi diye bakmıyor — bir YAKIN-ISKA ölçüldü: `tibia_inclination_right` denendiğinde `real_replay_test.dart`ın HARDCODED bir örneği tesadüfen yakaladı, `reach_depth`e değiştirilince aynı mutasyon sessizce geçti, yani o "yakalama" yapısal değildi). **(C)** `UnbridgedMetric.measureKind` config'in gerçek `kind`inden SAPTIRILIRSA — `metric_bridge.dart`ın KENDİ doc yorumu (satır 166) *"kapıda karşılaştırılıyor"* dese de, kod tabanında bu karşılaştırmayı yapan TEK satır YOK (ölçüldü). **KOORDİNATÖR HÜKMÜ BEKLENİYOR — bu bir ÖLÇÜM, kod burada DEĞİŞTİRİLMEDİ.** |
| `reference_equivalence_test.dart` | `kBridgeIsReferenceEquivalent`+`docs/L-031-ESDEGERLIK-KANITI.json` (kanıt zinciri, YALNIZ `tools/l031_space_divergence.py --claim-equivalence` yazar) ↔ `metric_bridge.dart`daki gerçek kod durumu (kapı bağımsızca yeniden hash'ler) | ✅ **KAPATILDI (2026-08-12, L-262, M-F-462/474 — koordinatör onaylı tasarım).** Choreia `harvest_rig/manifest.py`'nin `rig_version()`'ından (içerik-hash kimlik+güncellik, dosya-başına harita) ve `validate_metric_vocabulary.py`'nin `readers_of()`'ından (doğrulayıcı üreticiyle aynı yol OLAMAZ) aktarılan desen — `rig_staleness_warning()`'in "uyar/reddetme" tutumu BİLEREK aktarılmadı (buradaki risk tam tersi, fail-CLOSED). `tools/mutation_reference_equivalence.py` üç sahneyle sınadı: ① bayrak+uzay elle çevrilip JSON'a dokunulmazsa → 🔴 ② JSON yazılır ama `inputsSha256` bayat kalırsa → 🔴 ③ GERÇEK `--claim-equivalence` koşumu (tek fixture, gevşek öz-test barı) → 🟢. Üçü de beklenen çıktıyı verdi — kapı hem kaçak sızdırmıyor hem gerçek kanıtı reddetmiyor. Dürüst sınır: hash bağı sahteleme MALİYETİNİ yükseltir, NİYETİ kanıtlamaz (rig_version()'ın kendisi de aynı sınırı taşır). |

**Sıradaki iş — koordinatör hükmü:** `metric_coverage_test.dart`ın üç sahnesi
de ölçüldü ve korumasız çıktı; düzeltme tasarımı (③, değişim-dedektörü ile
aynı sırada mı yoksa önce mi) koordinatörden bekleniyor. `pin_equality_
test.dart` zaten iyi savunulmuş, düşük öncelik.

---

## VARLIK-yakını kapılar — tek kaynak → kod-dönüşümü sınar, MUT-A'nın hedefi DEĞİL (10)

Yeniden etiketlendi (silinmedi): her biri config/veri ↔ AYNI veriden
türeyen render/hesap arasındaki DÖNÜŞÜMÜ sınıyor. Değerli kapılar —
yalnız Ostinato'nun "iki bağımsız dosya sürüklenmesi" sınıfının riskini
TAŞIMIYORLAR, o yüzden JSON-mutasyonlu bir MUT-A turu buraya harcanmamalı.

| Dosya | Tek kaynak → türeyen |
|---|---|
| `honesty_presence_test.dart` | config sınır/muafiyet listesi → render edilen metin |
| `os_layer_test.dart` | `lib/` capture-yolu varlığı → `Info.plist` izin metni gereksinimi |
| `shell_test.dart` | config `tabs` listesi → `LissomShell` render edilen sekmeler |
| `family_page_test.dart` | config'in canlı/engelli kural sayısı → sayfada görünen sayı |
| `library_screen_test.dart` | inşa edilmiş aile sayısı (veri) → kart sayısı (render) |
| `ship_blocker_test.dart` | `pubspec` `assets:` beyanı → disk-okuma (test) vs bundle-okuma (cihaz) yöntemi |
| `subject_test.dart` | config başlığı → hardcoded gövde metni (ikisi de AYNI ekranın parçası, ayrı dosyalar değil) |
| `capability_claim_test.dart` | yetenek iddiası (metin) → gerçek kod/pubspec taraması |
| `summary_test.dart` | hesaplanan statü (`tier`/`lessonClass`) → render edilen bölüm |
| `battery_summary_view_test.dart` | hesaplanan bant → hangi BÖLÜMDE render edildiği |

---

## VARLIK kapıları — tek kaynak, dönüşüm bile yok (25)

`contrast_test` · `rendered_contrast_test` · `defensive_default_test` ·
`home_screen_test` · `ia_test` · `measurement_limit_test` ·
`orientation_test` · `pose_model_test` · `progress_screen_test` ·
`reachability_test` · `screen_evidence_test` · `shipped_claim_test` ·
`surface_language_test` · `hard_rule_sweep_test` · `assessment_history_test`
· `visual_ban_test` · `live_evaluator_test` · `live_session_state_test` ·
`mf71_test` · `real_config_test` · `real_replay_test` ·
`reference_status_test` · `session_test` · `invalidation_test` ·
`network_dependency_check.py` (A3 — kendi üç kanalıyla zaten ayrı bir
öz-test taşıyor, tekrar sayılmadı).

---

## Bu envanterin YAPMADIĞI — isimle

Mutasyon FONKSİYONLARININ kendisi yazılmadı (Ostinato'nun 13 `m_*`
fonksiyonu gibi) — bu envanter yalnız NEREYE yazılacağını, hangi SIRAYLA,
ve mevcut kısmi-koruma durumunu belirliyor. `tools/mutation_lock.py`
çekirdeği bu envanterin üstüne yazılmaya hazır (`GATES` dict + `TOUCHED`
dosya listesi + `m_*` fonksiyonları eklenerek); o kurulum ayrı bir tur.
