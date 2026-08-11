# A1-A5 aile denetimi — Ostinato aktarımı (2026-08-11, Lissom)

> Koordinatör sevki: her soruyu kendi ağacında ölç. Aşağıdakiler `6d3b446`
> üzerinde ölçüldü, hiçbiri yazılmadı/uydurulmadı.

---

## A1 — «N süit yeşil» satırı SEVK EDİLEN kodu mu kapsıyor?

**Ölçüldü, kusur bulunamadı.**

`tools/all_gates.py` süit listesini ELLE YAZMIYOR — `packages/*/pubspec.yaml`
taranarak türetiliyor (JabLab J-145 dersi zaten burada uygulanmış). İki kontrol
eklendi:

- `integration_test/` dizini YOK — yani `flutter test`in görmediği bir
  entegrasyon katmanı (JabLab'ın kör noktası) burada mevcut değil.
- `lib/`'teki 16 dosyanın hepsi `test/` içinde adıyla geçiyor (kaba tarama —
  "adı geçmek" "anlamlı sınandığı" anlamına gelmez, ama en azından yetim
  dosya yok).

`tools/*.py` dışındaki tek python dosyası `ios/Flutter/ephemeral/…` — Flutter'ın
kendi üretimi, kaynak değil.

---

## A2 — mutasyon harness'ında KİLİT var mı?

**Ölçüldü: HAYIR, kalıcı/tekrar-koşulabilir bir sabotaj aracı yok.**

`sabotaj`/`mutasyon` geçen tüm yerler ya (a) test dosyasına gömülü kalıcı
regresyon testleri (`pin_equality_test.dart` — iyi, bunlar tekrar koşuyor) ya
da (b) yalnızca YORUMDA anlatılan, bir kereliğine elle koşulmuş sabotajlar
(`honesty_presence_test.dart:6` — "İki sabotaj koştum" diyor ama sabotajın
kendisi kod olarak depoda yok). Ostinato'nun O-084 deseninin aksine, Lissom'da
"mutasyon uygulandığını ASSERT eden" bir harness YOK — (b) sınıfındaki
sabotajlar bugün TEKRAR koşulamaz, yani o testlerin hâlâ kırmızı
yanabildiğini kimse yeniden doğrulayamıyor.

---

## A3 — «cihazda kalır / yüklenmez» iddialarından hangisi bir KAPIYA bağlı?

**Ölçüldü: HİÇBİRİ.**

`lib/app/profile_screen.dart`, `progress_screen.dart`, `home_screen.dart`
içinde en az 6 yüzey "on this phone" / "on this device" diyor. `test/
os_layer_test.dart` yalnız KAMERA İZNİ simetrisini ölçüyor — ağ bağımlılığı
kaydı değil. `pubspec.yaml:55` `google_fonts: ^6.2.1` taşıyor (devir notunda
L-222 olarak zaten işaretli, açık) ve repo'da ağa-çıkan-bağımlılık kaydı
tutan bir kapı (Ostinato'nun O-080 deseni) yok. **Bu, L-222'nin zaten bilinen
halini doğruluyor** — yeni açık değil, ama "korunuyor mu" sorusunun cevabı
netleşti: hayır.

---

## A4 — kayıt setinde TEK bir kaydın taşımadığı alan var mı?

**Ölçüldü: EVET, ve iz sürünce daha büyük bir kusura çıktı.**

`config/tests/lissom-assessment.v1.json` → `tests[10].invalidation`
(`active_straight_leg_raise`): üç kuraldan ikisi (`BENT_KNEE`,
`OPPOSITE_LEG_LIFTED`) kullanıcıya gösterilecek `message` taşıyor,
`LOW_CONFIDENCE` taşımıyor.

Asıl bulgu bundan daha temel: `packages/lissom_engine/lib/src/battery.dart`
içindeki `TestSpec` sınıfı (`:155-185`) sabit bir alan listesi taşıyor — `id,
name, instruction, perSide, primaryMetric, scoring, presenceGate,
holdSeconds, confidenceClass, referenceStatus`. **`invalidation` bu listede
YOK.** `grep -rn invalidation packages/lissom_engine/lib/` **sıfır sonuç**
verdi. Yani `config`'te üç testin (bakılan yalnız #10 değil, tarama tüm
`tests[]`'i kapsıyor) yazılı `invalidation` kuralları — BENT_KNEE mesajı,
OPPOSITE_LEG_LIFTED mesajı dahil — motor tarafından **hiç okunmuyor**.
İçerik var, onu okuyan kod yok — Choreia'nın "yazmadan önce okuyan kod var
mı" dersinin ters/geç hâli: burada içerik ÖNCE yazılmış, okuyucu hiç
eklenmemiş.

**Kapsam:** `config/ia/library.v1.json`'daki `reason` asimetrisi (tier 1'de
yok, tier 2-3'te var) taramada çıktı ama incelemede İYİ HUYLU — tier 1 tam
kapasite, `reason` yalnız DEĞİRİLMİŞ tier'lerde gerekli. `lissom-phases.v1.json`
'daki `timeoutCode`/`timeoutMs` yokluğu da İYİ HUYLU — `complete` fazının
zaten zaman aşımı yok. İkisi de yanlış-pozitif, elenmiş.

---

## A5 — hangi kapı «önce şunu yap»ı dayatıyor, oracle seçiminin yan etkisi mi?

**Ölçüldü: O-084 şeklinde bir kapı bulunamadı; ama bitişik bir kusur bulundu.**

`.git/hooks/pre-commit` (L-275 commit kapısı) doğru sırada: `all_gates.py`
ÖNCE koşuyor, commit SONRA. Ostinato'nun O-084'ündeki ters sıra (commit
önce, doğrulama sonra) burada yok. `pin_equality_test.dart` da commit
durumuna bağlı değil, `pubspec.lock`'u doğrudan okuyor.

**Bitişik bulgu (A5'in sıfırıncı-şart ikizi):** `.git/hooks/pre-commit`
**git tarafından izlenmiyor** — `.git/hooks/` standart olarak versiyonlanmaz
ve bu depo `core.hooksPath`'i versiyonlu bir dizine yönlendirmiyor
(`husky`/`lefthook` yok). Yani bu kapı yalnızca **bu makinede, bu
checkout'ta** var; taze bir `git clone` (başka bir worktree, CI, disk
değişimi) SIFIR koruma ile başlar ve repo içinde bunu söyleyen hiçbir şey
yok. Choreia'nın M-F-399 dersi ("sıfırıncı şart: kapının VAR OLMASI") bir
seviye yukarıda tekrarlanıyor: kapı kendi düşebildiğini kanıtladı ama kendi
NAKLEDİLEBİLİRLİĞİNİ hiç sınamadı.

---

## Özet tablo

| # | Soru | Sonuç |
|---|---|---|
| A1 | süit kapsamı sevkedilen kodu kapsıyor mu | ✅ ölçüldü, kusur yok |
| A2 | mutasyon harness'inde kilit var mı | 🔴 yok — narratif sabotajlar tekrar koşulamıyor |
| A3 | cihaz-içi iddialar kapıya bağlı mı | 🔴 hiçbiri değil (L-222 ile aynı kök) |
| A4 | kayıt setinde eksik alan var mı | 🔴 `invalidation` bloğu TÜMÜYLE okunmuyor (3 test, 2 mesaj boşa yazılmış) |
| A5 | kapı "önce şunu yap" dayatıyor mu | ✅ commit kapısı temiz; 🔴 ama kapının kendisi taşınmıyor (git-izlenmiyor) |
