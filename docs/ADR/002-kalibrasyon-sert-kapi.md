# ADR-002 — Kalibrasyon bir kapıdır, öneri değil

**Tarih:** 2026-07-26 · **Statü:** kabul (M-F-09) · **Bağlam:** L-013, L-026

## Karar

Kalibrasyon koşulları sağlanmadan değerlendirme **başlamaz**. Yaw sapması ≤10° dayatılır (≤5° hedeflenir), mesafe 180-200 cm, yükseklik 90-110 cm, kadrajda baş-ayak. "Yine de devam et" seçeneği yoktur.

## Neden

Kendi ölçümümüz kapı olmasını gerektiriyor. G1-a A5 taraması: `trunk_lateral_tilt` ±10° yaw sapmasında **5,73°** kayıyor, ±15°'de 8,50°. Kapı kriteri B4 koşul kaymasını ≤5° istiyor — yani 10°'lik bir kamera hatası tek başına ölçümü kabul edilemez hâle getiriyor.

JabLab bağımsız olarak aynı sonuca vardı (ADR-003) ve kurulum sihirbazını "ürünün en yüksek getirili tek bileşeni" diye niteledi.

## Reddedilen alternatifler

- **Uyarı gösterip devam etmek:** kullanıcı devam eder, sonuç sayıya döner ve yanlış kurulumla üretildiği görünmez. Ölçüm ürününde en kötü seçenek.
- **Sapmayı sonradan düzeltmek:** yaw düzeltmesi derinlik bilgisi ister; tek kamerada güvenilir değil.
- **Yalnız gövde metriklerini kapatmak:** kısmi ölçüm kullanıcı için anlaşılmaz; kurulum zaten düzeltilebilir bir şey.

## Sonuç

Sürtünme artar. Kabul ediyoruz: ölçmediğimiz bir şeyi ölçmüş gibi göstermenin maliyeti daha yüksek.
