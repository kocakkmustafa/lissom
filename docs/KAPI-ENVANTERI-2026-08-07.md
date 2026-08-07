# Kapı envanteri — Lissom, 2026-08-07

> **Şablon notu (JabLab J-126):** *Kapı kurmak bir iş değil, İKİ iş — kapıyı
> kurmak ve **KAPSAMINI YAZMAK**. İkincisi atlanınca kapı yeşil kalır ve o
> alanda kimse bakmaz: **yeşil bir kapı, bakılmayan bir alan üretir.***

**Yöntem:** soru **dışarıdan** soruldu — *"bu kapı neyi ÖLÇMÜYOR?"* —, her
satırda **kanıt sütunu** zorunlu. Kör nokta sınıfı: *algı · kod · ölçüm
yöntemi*.

---

## Kapılar ve KAPSAMLARI

| Kapı | Ölçtüğü | **ÖLÇMEDİĞİ** | Kanıt / sınıf |
|---|---|---|---|
| `contrast_test` | WCAG luminans oranı, alfa zemine bindirilerek; alt sınır okunurluk + üst sınır hiyerarşi; palet bütünlüğü | **Ayırt edilebilirlik.** Aynı orana sahip iki renk birbirine karışabilir ve kapı yeşil yanar | dosya başlığında yazılı; WCAG'ın kendi tanımı (ölçüm yöntemi) |
| `copy_gate` (widget) | Basılan ağaçtaki yasaklı kopya | **Ulaşılamayan ama gönderilen kod.** `BatterySummaryView` kabuktan erişilemez (L-225) → ağaç taraması onu hiç görmez | L-229'da CANLI ihlal buldu; panzehir kaynak-düzeyi `PROMISE` |
| `wellness_lint` | Tıbbi dil + vaat dili, JSON `USER_FACING_KEYS` + Dart string sabitleri | **Çalışma-anında birleştirilen metin** (`'$n tests'` şablonu taranır, sonuç taranmaz) · listede olmayan config alanı | `userText` iki yıl taranmamıştı (L-229); `claim` şema değişince eklendi (L-230) |
| ↳ `will` sınıfı | Koşula bağlanmamış gelecek zaman | — | **L-245: hiç bakmıyordu.** Üç sınıf: vaat · koşullu · REDDİ (`will not`) |
| `375pt` yüzey | Taşma, en dar YAYGIN genişlikte | **Yatay.** `setPreferredOrientations` yok, `Info.plist` üç yönü açıyor | **L-244: hiç bakılmamıştı.** Şimdi `orientation_test` (4 ekran, 812×375, taşma YOK) |
| `two_mode` muafiyet | Muafiyetin BAYATLAMASI | **Muafiyetin ilk baştan yanlış olması** | **L-232'de kapatıldı:** yetim anahtar + vakum-doğru onay |
| `metric_coverage` | gereken = köprülü ⊎ beyan edilmiş | **`known` süzgecinden düşen metrik** | **L-220: `hold_duration` görünmüyordu**, vakum-doğru süzgeç |
| `ekran kanıtı` (golden) | 375×812'de YAPI | **Metin.** `google_fonts` test altında yüklenemiyor → Ahem blokları | Bu gecenin dört kusurunu da GERÇEK CİHAZ yakaladı, golden değil |
| `gezinme` | Dokunuş sayısı | **Zahmet.** Uzun bir kaydırma iki dokunuşu ucuz göstermez | L-240'ta kapının içine yazıldı |
| `narrow_surface` sıra | Belge sırası (uzun yüzeyde) | — | L-243: dar-KISA yüzeyde sıra ölçmek EKRAN BOYUNU ölçüyordu |

---

## Bu envanterin ÜRETTİĞİ iki canlı bulgu

### L-244 — 375pt kapısı yalnız portre ölçüyordu
`lib/` altında `setPreferredOrientations` **hiç yok**; `ios/Runner/Info.plist`
`Portrait` + `LandscapeLeft` + `LandscapeRight` açıyor. **Telefonu çeviren
kullanıcı hiç sınanmamış bir yerleşim görüyordu.**

Ölçüldü: dört sekmenin dördü de 812×375'te **taşmıyor** — yani bugün canlı
kusur yok, ama bu bir *şanstı*, kapı değildi. Artık `orientation_test`.

> Yatayın DESTEKLENİP desteklenmeyeceği ürün kararı — kapı hüküm vermiyor,
> bugünün gerçeğini ölçüyor.

### L-245 — `will` üç sınıf taşıyor, kapı hiçbirine bakmıyordu
1. *"the number **will** appear here"* → tarihsiz **VAAT**
2. *"**When** that study is run, the number **will** appear here"* → adı olan
   bir koşula bağlı, M-F-186 uyumlu (`promotionPath` deseni)
3. *"we **will not** estimate a number we can't take"* → vaadin **REDDİ**,
   bu ürünün en dürüst cümlelerinden biri

Depodaki üç kullanımın üçü de ②/③ sınıfında — **ihlal yok**, ama hiçbir şey
onları o sınıfta tutmuyordu.

**Ve kapı kurulurken KENDİ iki kusurunu üretti / açığa çıkardı:**

- **Parça değil cümle:** Dart'ta `'…When that study is ' 'run, the number will
  appear here.'` tek dizedir; süzgeç onları AYRI tarıyordu, yani *"When" bir
  parçada, "will" ötekindeydi.* Kapı cümleyi değil **parçayı** gördü ve meşru
  bir biçimi ihlal sandı. `roseDeepHover`ı `rose` sanan alt-dize hatasıyla
  aynı sınıf: **doğru şeyi yanlış BİRİMDE ölçmek.** → bitişik literaller artık
  birleştiriliyor.
- **Reddi vaat sanmak:** `will not` ilk turda ihlal sayıldı. Bir kapı doğru
  davranışı cezalandırıyorsa, o kapı yanlıştır.

---

## Sabotaj doğrulaması

| Sabotaj | Sonuç |
|---|---|
| Koşulsuz `will` eklendi | ❌ kırmızı (1 ihlal), geri alınınca yeşil |
| `yet` geri kondu | ❌ kırmızı, geri alınınca yeşil |
| Kovasız palet token'ı | ❌ kırmızı, adıyla |
| Köprü büyütüldü (`trunk_lean`) | ✅ **yeşil kaldı** — ürün doğru genişlerken kırılmıyor (L-239) |

---

## Kapsamı yazılmamış kalan

`tools/` altındaki ölçüm araçlarının çoğu (`triage_landmarks`, `harvest_*`,
`l031_space_divergence`, `synthetic_ceiling`) **kapı değil ARAÇ** — bir kapı
gibi yeşil/kırmızı vermiyorlar. Bu envanter kapıları kapsıyor; araçların
kapsam yazısı ayrı bir iş ve **isimli açık.**
