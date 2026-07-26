# ADR-004 — Köken alanları zorunludur; eksikse karşılaştırma yapılmaz

**Tarih:** 2026-07-26 · **Statü:** kabul (M-F-07; Gravita ADR-005'ten devralındı) · **Bağlam:** L-022, L-004

## Karar

Her `TestAttempt` şunları taşır: `modelVariant` · `modelVersion` + `modelSha256` · `metricConfigVersion` · `ruleSetVersion` · `calibrationProfile` · `appVersion`. İki ölçüm ancak bu alanlar uyumluysa karşılaştırılır.

## Neden

Lissom'un tüm değer önerisi zaman-içi karşılaştırma: "dört hafta önce şuradaydın, şimdi burada." Bu cümle, iki ölçümün **aynı koşullarda** üretildiği varsayımına dayanır.

Varsayım kırılgan ve bunu ölçtük: MediaPipe'ın `full` bundle'ı `/1/` ve `/latest/` yollarında **farklı hash** veriyor, üstelik dosya boyutu aynı (M-L-01). Model sessizce değişirse, kullanıcının "gelişmesi" model güncellemesi olabilir.

## Reddedilen alternatifler

- **Yalnız sürüm numarası tutmak:** `latest` etiketi sürüm numarasını değiştirmeden içerik değiştirebiliyor; hash şart.
- **Uyumsuz ölçümleri yine de karşılaştırıp uyarı göstermek:** karşılaştırma ekranının kendisi bir iddiadır; uyarı onu geri almaz.

## Sonuç

Uyumsuzlukta kullanıcıya "yeniden temel ölçüm" önerilir. Geçmiş silinmez, yalnız kıyaslanmaz.
