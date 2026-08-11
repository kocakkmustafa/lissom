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

---

## ÇELİŞKİ kapıları — MUT-A'nın asıl hedefi (13)

| Dosya | İki kaynak | MUT-A geçmişi |
|---|---|---|
| `pin_equality_test.dart` | `pubspec.lock` ref/resolved-ref ↔ mühürlü sabit ↔ sürüm çifti | ✅ ZATEN 3-çapalı, "ikisi de aynı YANLIŞ commit'te" sınıfına karşı ÇAPA 2 kurulu (Ostinato deseninin aynısı) — **en iyi örnek** |
| `honesty_presence_test.dart` | kaynak (config sınır/muafiyet listesi) ↔ yüzey (render edilen metin) | ⚠️ İKİ TEKİL sabotaj koşuldu (kaba+sinsi silme), ama **KOORDİNELİ** "kaynak VE yüzey birlikte tutarlı bozulursa" hiç sınanmadı |
| `metric_coverage_test.dart` | batarya-istediği metrikler ↔ köprü kapsamı ↔ ölçüm uzayı | ⚠️ 3 öz-test var (beyansız metrik, çelişkili beyan) — hepsi TEK kaynak sabotajı, "her iki taraf da" sınanmamış |
| `os_layer_test.dart` | `Info.plist` izin metni ↔ `lib/` capture-yolu varlığı | ⛔ sabotaj YOK — simetri iddiası var ama hiç sınanmamış |
| `shell_test.dart` | config `tabs` listesi ↔ `LissomShell` render edilen sekmeler | ⛔ sabotaj YOK |
| `family_page_test.dart` | config'in canlı/engelli kural sayısı ↔ sayfada görünen sayı | ⛔ sabotaj YOK |
| `library_screen_test.dart` | veri (inşa edilmiş aile sayısı) ↔ render (kart sayısı) | ⛔ sabotaj YOK |
| `ship_blocker_test.dart` | `pubspec` `assets:` beyanı ↔ disk yolları ↔ test-okuma yöntemi (disk) vs cihaz-okuma yöntemi (bundle) | ⛔ sabotaj YOK — kendi docstring'i tam bu asimetriyi TANIMLIYOR ama sınamıyor |
| `reference_equivalence_test.dart` | kod bayrağı (`kBridgeIsReferenceEquivalent`) ↔ docs artefaktı (medyan/p95/kabul-ölçütü) | ⛔ sabotaj YOK — L-187 göçü tam bu ikisini birden değiştirecek bir değişiklik |
| `subject_test.dart` | config başlığı ↔ hardcoded gövde metni | ⛔ sabotaj YOK — J-154'ün bulduğu kusur sınıfının kendisi |
| `capability_claim_test.dart` | yetenek iddiası (metin) ↔ gerçek kod/pubspec yeteneği | ⛔ sabotaj YOK |
| `summary_test.dart` | hesaplanan statü (`tier`/`lessonClass`) ↔ render edilen bölüm | ⛔ sabotaj YOK |
| `battery_summary_view_test.dart` | hesaplanan bant ↔ hangi BÖLÜMDE render edildiği | ⛔ sabotaj YOK — kendi docstring'i "iki bölüm birleştirilse geçerdi" riskini zaten adlandırmış |

**Öncelik sırası (ölçülmüş gerekçeyle):** `honesty_presence_test.dart` ve
`metric_coverage_test.dart` ZATEN kısmi sabotaj taşıyor — ilk MUT-A turu
bunları "tek kaynak → koordineli iki kaynak"a GENİŞLETMEK olmalı, çünkü
altyapı (sabotaj fonksiyonu, kapı listesi) zaten orada. `ship_blocker_test
.dart` ve `reference_equivalence_test.dart` en YÜKSEK risk taşıyor —
ikisi de kendi docstring'inde tam bu asimetriyi anlatıyor ama hiç
sabotajla kanıtlanmamış.

---

## VARLIK kapıları — tek kaynak, MUT-A'nın hedefi DEĞİL (25)

Tek bir kaynağı (render edilen ağaç, kod deseni, config'in kendi iç
tutarlılığı) sınıyor — "iki kaynağı birden tutarlı boz" sınıfının riski
yapısal olarak yok. Listelendi ki bir sonraki tur bunlara MUT-A YAZMAYA
çalışıp zaman kaybetmesin:

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
