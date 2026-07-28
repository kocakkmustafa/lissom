# ADR-001 — Taraf kimliği geometrik kurulur, model etiketine ham güven yoktur

**Tarih:** 2026-07-26 · **Statü:** kabul (kurucu hakemliği M-F-06) · **Bağlam:** L-020, L-017

## Karar

Sol/sağ ayrımı MediaPipe'ın `LEFT_*`/`RIGHT_*` etiketlerinden **okunmaz**. Taraf kimliği kalibrasyon pozunda geometrik olarak kurulur (kadraj konumu + kameraya yakınlık) ve oturum boyunca sabitlenir. Kullanıcıya L/R yalnız bu eşleme kurulduktan sonra raporlanır; kurulamazsa **simetri skoru üretilmez**.

## Neden

Ailenin diğer üç app'i bağımsız olarak aynı sonuca vardı: Gravita ADR-003 (kurallar taraf-agnostik), JabLab ADR-004 (motor `lead/rear` ile çalışır), Choreia K6 (sol/sağ merkezî çözülür). Kök neden ölçüldü: model ters/atipik duruşta kol↔bacak zincirlerini **yüksek güvenle** takas ediyor (Gravita D1: bir vakada 0,93 güven, gözle fark edilmiyor).

Lissom'un durumu diğerlerinden farklı ve bu fark kararın şeklini belirledi: sağ-sol farkı **ürün vaadinin parçası** (plan §6), yani basitçe "taraftan kaçın" denemez.

## Neden yine de simetriyi tutuyoruz

Kurucu hakemliği: Lissom'un ölçüm bağlamı — kalibre kurulum, frontal/sagittal düzlem, dik duruş, statik poz — tam da L/R'nin güvenilir olduğu bölge. Diğer app'lerin tuzağı hareketli, ters ve atipik duruşlardan geliyor. Vaat korunur, ama **koşula bağlanır**.

## Reddedilen alternatifler

- **Model etiketine güvenmek:** ölçülmüş hata sınıfı var, kabul edilemez.
- **Simetriyi V1'den çıkarmak:** ürün vaadini gereksiz daraltırdı; ölçüm bağlamımız elverişli.
- **Yalnız yapısal denetime yaslanmak:** `StructuralValidator` takası yakalar ama hangi tarafın hangisi olduğunu söylemez; eşleme yine gerekli.

## Sonuç

Kalibrasyon çıktısı bir taraf-eşleme tablosu üretir. Sagittal testlerde ölçülen taraf kameraya yakın olandır ve kullanıcıya söylenir. Eşleme yoksa tek taraflı rapor verilir — "analiz edemedim" yanlış hükümden üstündür.
