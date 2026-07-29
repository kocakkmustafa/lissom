# M-TALEBİ — Faz-Config Şeması taslağı diff'i (Lissom)

**Taslak:** motion-core `docs/40-FAZ-CONFIG-SEMASI-TASLAK.md` (M-F-35)
**Tarih:** 2026-07-29 · **Statü:** diff penceresi yanıtı — sessizlik onay sayılacağı için **bir eksik bildiriliyor**

---

## 1. Sonuç

Taslak Lissom'un 12 testinin **11'ini olduğu gibi ifade edebiliyor.** Koşul cebiri, saniye-birimli delta ve iki değişmez zaten bizim önerimizdi; `localMax`, teknik-düzeyi `requiredLandmarks` ve `fallback` bizde olmayan ama işimize yarayacak eklemeler (aşağıda §3).

**Tek gerçek eksik: taraf parametrizasyonu.**

## 2. EKSİK — `perSide` / `{side}` yer tutucusu (M-talebi)

### Sorun

Lissom'un 12 testinden **7'si iki taraflı** (`overhead_reach`, `ankle_dorsiflexion`, `hamstring_reach`, `lateral_bend`, `single_leg_balance`, `forward_lunge`, `active_straight_leg_raise`). Bizim formatımızda bu tek bir tanımla ifade ediliyor:

```json
{
  "testId": "overhead_reach",
  "perSide": true,
  "phases": [
    { "id": "ready",
      "enter": { "kind": "metric", "metric": "shoulder_flexion_{side}", "op": "<", "value": 40 },
      "requiredLandmarks": ["{SIDE}_SHOULDER", "{SIDE}_ELBOW", "MID_HIP"] }
  ]
}
```

Koşucu `side="right"|"left"` ile örnekleniyor ve `{side}` / `{SIDE}` metrik ve landmark adlarında çözülüyor.

Taslakta bu mekanizma yok. Onunla yazınca aynı fazları **iki kez** yazmak gerekiyor — 7 test × ortalama 5 faz = **35 fazlık kopya**, ve her eşik değişiminde iki yerde güncelleme.

### Neden kozmetik değil

Kopyalanan eşik, er geç ayrışır. Bu gecede tam olarak bu sınıftan üç hata çıktı (L-050, L-062, L-063): bir yerde düzeltilip diğerinde unutulan tanımlar. Taraf simetrisi Lissom'un **ölçtüğü şeyin kendisi** olduğu için (sağ-sol farkı bölgesel skorun bileşeni), iki tarafın tanımının ayrışması doğrudan yanlış bir simetri sonucu üretir.

Ayrıca ADR-001 gereği taraf kimliği **geometrik** kuruluyor, model etiketinden okunmuyor — yani `{side}` bir çalışma-zamanı parametresi, yazım-zamanı sabiti değil.

### Öneri (asgari)

Teknik düzeyinde bir alan ve iki yer tutucu:

```
teknik := { ..., perSide?: bool }
```
- `perSide: true` ise yorumlayıcı tanımı iki kez örnekler (`right`, `left`)
- `{side}` metrik adlarında, `{SIDE}` landmark adlarında çözülür
- Çıktı `AttemptRun`'a hangi tarafın koşulduğu yazılır

Alternatif (daha genel): rastgele bir `params` sözlüğü + şablon çözümü. Ama bizim ihtiyacımız yalnız taraf; genel şablon motoru gereğinden fazla olabilir.

## 3. Taslakta olup bizde olmayan — benimseyeceklerimiz

Bunlar itiraz değil, kabul:

| Özellik | Kaynak | Lissom'da nereye |
|---|---|---|
| `localMax` | JabLab | ROM testlerinde tepe tespiti. Şu an `delta < eşik` ("hareket durdu") ile yapıyoruz; `localMax` daha doğrudan ve gürültüye daha az bağımlı |
| Teknik-düzeyi `requiredLandmarks` | JabLab | Testin tamamı için tek beyan; faz ezer. Bizde her fazda tekrar ediliyor |
| `signalConditioning` (filtre+eşik birlikte pinlenir) | M-C-07/J-027 | One Euro parametrelerimiz henüz kalibre edilmedi; kalibre edilince eşiklerle birlikte pinlenecek |
| `baseline` beyanı | G-024/M-F-34 | §4'te uygulanıyor |
| Bilinmeyen alan = sert hata | M-J-03 | Bizim `phase_check` batarya kapsamını zorluyor ama bilinmeyen ALAN adını yakalamıyor — taslak sürümü daha sıkı, iyi |

## 4. M-F-34 (taban-değeri) — Lissom uygulaması

Kural: *tolerans taşıyan her metrik kusursuz-durum taban değerini beyan eder; taban "sıfır sanılıyorsa" ölçülmemiş demektir.*

Lissom'un 19 metriğinden **tabanı sıfır OLMAYANLAR** — bunlar sessiz hata kaynağı:

| Metrik | Kusursuz-durum tabanı | Neden sıfır değil |
|---|---|---|
| `shoulder_line_foreshortening` | **0,80** | Omuz genişliği / gövde uzunluğu oranı; gövde kameraya tam dönükken bile 0,80. **Bu tam olarak L-072'nin sebebiydi:** guard `> 0.15` yazılmıştı, taban 0,80 olduğu için her duruşta tetikleniyordu |
| `heel_rise_*` | **0,00** | Topuk parmak hizasındayken sıfır — taban gerçekten sıfır ✓ |
| `knee_height_*` | **0,84** | Diz-ayakbileği dikey farkı / gövde; ayakta dururken shank/torso oranı |
| `reach_depth` | **~1,60** | Bilek-ayakbileği mesafesi / gövde; ayakta kollar yanda |
| `plank_hip_deviation` | **0,00** | Kusursuz hizada sıfır ✓ |
| Açı metrikleri (12 adet) | tanım gereği açı | Taban kavramı uygulanmaz — mutlak açı ölçüyorlar |

**Uygulanan:** taban değerleri metrik config'ine `baseline` alanı olarak yazıldı ve **kapıya A11 kriteri eklendi**: beyan edilen taban ile sentetik kusursuz-durumda ölçülen değer ≤%1 sapmalı. Yanlış beyan edilmiş taban, L-072'nin tekrarını üretir.

## 5. Göç

Taslağın göç yolu kabul: mevcut formatla çalışmaya devam, çekirdek yorumlayıcı çıkınca ince çevirici yazılır. `mocore/phases.py` taslak köprüsü o gün silinir.

Tek şart: **`perSide` çözülmeden çevirici yazılamaz** — çünkü çeviricinin kendisi 7 testi ikiye açmak zorunda kalır ve kopya sorunu app tarafına taşınmış olur.
