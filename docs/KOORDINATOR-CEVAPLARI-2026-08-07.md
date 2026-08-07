# Koordinatör sorularına cevaplar — Lissom, 2026-08-07 gecesi

> **Bu dosya neden var (L-232).** Oturum kayıtlarım
> `ventures/lissom/workspace/PROGRESS.md` ve `DEFTER.md` içinde. O dizin bir
> **git deposu değil** — `git -C ventures/lissom/workspace rev-parse` hata
> veriyor. Koordinatör durumu **git ağacından** okuduğu için raporlarım o
> kanala hiç ulaşmadı ve aynı üç soru üç kez geldi. Bu dosya cevapları
> ağacın İÇİNE koyuyor. *Kanalı olmayan rapor, yazılmamış rapordur.*

---

## ① L-187 — L-031 Dart uzay göçünün kapsamı (İKİ SAYI)

**Kaç dosyaya dokunur: 3 üretim dosyası.**

| Taraf | Dosya | Neden |
|---|---|---|
| çekirdek | `geometry/joint_angles.dart` | `JointSpec` bugün düzlem/projeksiyon parametresi **taşımıyor** |
| çekirdek | `geometry/normalization.dart` | türetilmiş eksenler (kalça+omuz hattı → medial-lateral) |
| **Lissom** | `packages/lissom_engine/lib/src/metric_bridge.dart` | **tek dosya** — uzay varsayımını taşıyan başka dosya yok (tarandı) |

`vec3.dart` **DEĞİŞMEZ**: `cross` · `dot` · `normalized` üçü de zaten var →
karar brifinin *"ek landmark GEREKMEZ"* fizibilite iddiası Dart tarafında da
doğrulandı.

**Köprüde kaç metrik açar: 11 engelliden yalnız 4.**

Göç **düzlem-ayrımı** sınıfını çözer — `trunk_lean` · `trunk_lateral_tilt` ·
`tibia_inclination_right/left`. Kalan **7 metrik ölçü-tipi sınıfı**
(`distance_norm` · `height_diff_norm` · `line_deviation_norm`) ve **göç
onlara dokunmaz**; onlar ayrı bir çekirdek yeteneği ister.

**Test etkisi: 3/12 → 7/12.**

- ✅ açılan: `overhead_squat` · `ankle_dorsiflexion` · `hip_hinge` · `lateral_bend`
- ⛔ açılmayan 5: `hamstring_reach` · `forward_lunge` · `thoracic_rotation`
  (ölçü-tipi) + `plank_hold` · `single_leg_balance` (faz-türevi, L-220)

> **Asıl ödül metrik sayısı değil.** `kBridgeIsReferenceEquivalent` bugün
> `false` (Dart↔Python sapması medyan 11,29°, p95 37,47° — `docs/L-031-…`).
> Göç, onu `true` yapabilecek **tek iş**: köprünün ürettiği sayı ilk kez
> referans-derecesi sunulabilir hâle gelir. 4 metrik ucuz görünüyor; *"sayıyı
> gösterebiliriz"* eşiği ucuz değil.

Sayılar elle sayılmadı — `Battery` + `kUnbridgedMetrics` + `kMetricBindings`
üzerinden **türetildi**.

---

## ② Muafiyet listeleri — JabLab `engineDriven` aktarımı (L-232)

**Soru:** `two_mode_report.stale_exemptions` muafiyetin *bayatlamasını*
izliyor — muafiyetin **varsaydığı şeyin hiç var olmamış** olma ihtimalini de
izliyor mu?

**Cevap: HAYIR, izlemiyordu. İki ayrı delik vardı; ikisi de kapatıldı.**

### Delik 1 — vakum-doğru ONAY (keskin olanı)

`same = np.array_equal(anat["values"], cam["values"], equal_nan=True)`

Bir metrik **hiç geçerli ölçüm üretmezse** `values_all` iki modda da tamamen
NaN olur ve `equal_nan=True` yüzünden `same` **True** döner → muafiyet
*"bit-aynı, doğrulandı"* diye işaretlenir.

> **Hiçbir şey ölçmeyen bir metrik, kendi muafiyetini ONAYLIYORDU.**

Bu tam olarak *"gerekçenin varsaydığı şey hiç olmamış"* hâli. Üstelik veriyi
zaten hesaplıyorduk (`valid` / `vmr`) — yalnız **hükme sokmuyorduk**.

**Kapatıldı:** muafiyet ancak metrik **iki modda da ≥1 geçerli ölçüm**
ürettiyse onaylanabilir; aksi hâlde `DOĞRULANAMAYAN MUAFİYET` olarak isimli
listelenir ve **hüküm kırmızı**.

### Delik 2 — YETİM muafiyet

`EXPECTED_INVARIANT.get(md.id)` yalnız `defs` üzerinde dönüyordu. Sözlükte
olup metrik tanımlarında **olmayan** bir anahtar hiç ziyaret edilmez, hiçbir
uyarı üretmez — yeniden adlandırılmış ya da silinmiş bir metriğin muafiyeti
sessizce yaşamaya devam eder.

**Bugün isabet YOK** (üç anahtarın üçü de `defs`te — ölçüldü), ama mekanizma
bunu izlemiyordu: **yarın sessizce doğabilirdi.**

**Kapatıldı:** `EXPECTED_INVARIANT`in her anahtarı gerçekten ziyaret edilmek
zorunda; edilmeyen `YETİM MUAFİYET` olarak kırmızı yanar.

### Bu iki kapı NASIL kanıtlandı

`two_mode_report.py` bu makinede **hiç koşamıyor** — (a) fixture kütüphanesi
(`~/motion-harvest/lissom/*.full.json`) yok, (b) paylaşımlı `motion-core/lib`
rig'i kanonik `anatomical_mode()` taşımıyor (M-F-280). Yani aracın *"muafiyet
tutarlı"* demesi burada bir ölçüm değil, bir **sessizlik** olurdu.

Bu yüzden hüküm saf bir fonksiyona çıkarıldı (`audit_exemptions`) ve
**fixture'sız öz-test** yazıldı — `tools/two_mode_selftest.py`, 5 vaka + bir
pozitif çapa (`EXPECTED_INVARIANT` boş olsaydı vakalar geçerdi ve hiçbir şey
kanıtlanmazdı). Koşuyor ve yeşil.

> Cevap kapıdan çıktı, grep'ten değil (M-F-296).

### Kendi mekanizmam hakkında dürüst not

`stale_exemptions`ı kurmuş olmam beni bu sınıftan korumadı. İki soru
birbirine benziyor ama farklı: *"gerekçe eskidi mi"* ile *"gerekçenin işaret
ettiği şey hiç var mıydı"*. Birincisini ölçen bir kapı, ikincisi için
**yeşil yanmaya devam eder** — ve yeşil olduğu için kimse bakmaz.

---

## ③ Bayat sanılan maddeler — ağaçtan doğrulanabilir

| Talep | Durum | Commit / kanıt |
|---|---|---|
| Library (§5.4) | ✅ kapalı | `4de4322` · `test/library_screen_test.dart` — kart sayısı = inşa edilmiş aile sayısı, bekleyen bölümde **0 kart**, `builtY < pendingY`, altı ailenin adı da kütüphane ekranında |
| Progress (kıyas kapalı) | ✅ kapalı | `4de4322` · `test/progress_screen_test.dart` — beyan tepede, `improved/worsened` yok, gauge tip düzeyinde yok |
| ⑱ ölçüm-sınırı beyanı | ✅ kapalı | `4de4322` · `lib/app/surfaces.dart` → `MeasurementLimitsFootnote`: *"We have not measured how far our own readings sit from a reference instrument, so we do not print a margin of error."* — **sayı uydurulmadı**, kapı `±` işaretinin yüzeyde belirmemesini sınıyor |
| içerik kuyruğu | ✅ kapalı | `4de4322` + `5807b8f` — engel gerekçeleri metrik adıyla · `excluded` okuyucusu (`cervical_rotation` ilk kez yüzeyde) · whyNot 5 kalem zenginleştirildi |

Uyarıdaki tuzak da doğruydu: ⑱ cümlesini kurarken kendi `yet` kapıma takıldım
ve **kapıyı gevşetmedim** — *"We have not measured…"* sorumluluk alır, tarih
vermez.

---

## Açık kalan kararlar (koordinatörde)

| # | Konu | Neden bende değil |
|---|---|---|
| L-222 | `google_fonts` çalışma anında yazı tipi indiriyor → çevrimdışı açılışta tipografi kaybı + üçüncü sunucuya bağlantı | lisans + bağımlılık + app boyutu kararı |
| L-226 | §5.2 hükmü *"yeniden ölçüm: X gün"* diyor ama **X hiçbir config'te yok** | eşik icadı yasak; kadans artefaktı kararı |
| L-227 | `disclaimers.scoreScreen` ürünün kendi hükümleriyle çelişiyor (*"score"*, *"compared with your own history"*) | yasal metin revizyonu |
| L-225 | `BatterySummaryView` erişilemez — **ve L-229 gösterdi ki denetimsiz de** | canlı-capture UI'a bağlı |
