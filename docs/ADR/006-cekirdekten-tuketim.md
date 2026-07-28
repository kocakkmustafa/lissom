# ADR-006 — Ortak bileşenler motion_core'dan tüketilir, kopyalanmaz

**Tarih:** 2026-07-26 · **Statü:** kabul (M-F-03, M-F-05) · **Bağlam:** L-019, L-023, L-024, M-017

## Karar

Şu bileşenler `motion_core`'dan tüketilir, Lissom kendi sürümünü **yazmaz**:

| Bileşen | Neden çekirdekte |
|---|---|
| `StructuralValidator` | Uzuv-etiketi takasını yakalar (M-019); 5 app'i ilgilendirir |
| `ConfidenceGate.forVariant` | `visibility` varyantlar arası kıyaslanamaz (M-018) |
| Ses-gecikme kalibrasyonu | Choreia K4 deseni, aile modülü (M-F-08) |
| Açı/normalizasyon matematiği | Kanonik Dart çekirdeği (M-F-03) |
| Fixture şeması + replay | Aile sözleşmesi |

Lissom'a ait kalan: test tanımları, kural setleri, içerik paketleri, program motoru.

## Neden

2026-07-26 gecesi çekirdek **iki kez** üretildi (M-017) — dört oturum paralel çalışırken aynı matematik iki dilde yazıldı. Kurucu kararı: Dart `motion_core` kanonik, Python `mocore` kanonik fixture hattı.

Ders somut: normalizasyon referansı iki tarafta **farklı tanımlanmıştı** ve Python'daki tanım poza duyarlıydı (L-029, %1,63 kayma). Kanonik olana uyduruldu. Bu tür sessiz ayrışma, kopyalanan her bileşende tekrar eder.

## Sonuç

Çekirdeğe yeni ihtiyaç DEFTER üzerinden bildirilir; Lissom kendi kopyasını açmaz. Kalan uyumsuzluk L-031'de kayıtlı: Dart image düzleminde, Python 3D world uzayında ölçüyor — differential test öncesi hizalanmalı.
