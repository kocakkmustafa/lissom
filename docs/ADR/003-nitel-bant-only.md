# ADR-003 — Doğrulama öncesi yalnız nitel bant; sayısal skor gösterilmez

**Tarih:** 2026-07-26 · **Statü:** kabul (M-F-04, K8 aile kuralı) · **Bağlam:** L-005, L-025

## Karar

İç doğrulama çalışması (n≥20-30, bilinen-açı referansı) tamamlanana kadar kullanıcıya **hiçbir sayısal skor gösterilmez**. Bantlı skorlama iç hesap olarak çalışır; arayüz `limited / typical / good` gösterir.

## Neden

Skor bantları literatür ortalamalarından **türetildi**, klinik kesim noktası değil. Üstelik bazı testlerde norm birimi bizim ölçtüğümüzden farklı (ayak bileği literatürü cm, biz derece) ve bazılarında norm hiç yok (lumbo-pelvik ritim).

"87 derece" demek, sahip olmadığımız bir kesinliği ima eder. Nitel bant, elimizdeki kanıtın gerçekten desteklediği çözünürlük.

Ek dayanak: tek hakemli emsalimiz Halo Movement, genel skorunda referans testlerle yalnız r=0,29-0,63 korelasyon almış.

## Reddedilen alternatifler

- **Sayıyı hata payıyla göstermek** ("87° ± 8°"): kullanıcı hata payını okumaz, sayıyı okur.
- **Sayıyı "beta" etiketiyle göstermek:** etiket sorumluluğu kullanıcıya devretmek olur.
- **Kendi kullanıcı verimizle kalibre etmek:** referans olmadan kalibrasyon, gürültüyü norm sanmaktır.

## Kalkma koşulu

L-005 kapandığında (iç doğrulama çalışması) bu kısıt kalkar. O zamana kadar geçerli.
