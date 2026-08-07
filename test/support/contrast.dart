/// WCAG 2.2 kontrast ölçümü — **ekranda GERÇEKTEN oluşan renkten.**
///
/// **Neden bu dosya var (L-234, JabLab J-114 aktarımı).** Bu depoda kontrast
/// hiç ölçülmemişti: `WCAG|contrastRatio|relativeLuminance` yalnız tasarım
/// brief'inde geçiyordu, kodda ya da testte YOKTU. Yani "sönük" ile
/// "görünmez" arasındaki sınır bir SAYI ve o sayı hiç bakılmamış bir sayıydı.
///
/// JabLab aynı kör noktayı ölçtü: *"analiz hiç yok"* kovasının ikonu 1,80:1
/// veriyordu ve testi bunu göremiyordu, çünkü *"üç renk birbirinden farklı"*
/// diye ölçüyordu — `Color` KİMLİĞİNİ. Üç renk gerçekten farklıydı; biri
/// sadece görünmüyordu.
///
/// **Bu, L-231'in renk eksenindeki ikizi.** Orada metin VARDI ve DOĞRUYDU,
/// yalnız okunmuyordu. Burada renk VAR ve FARKLI, yalnız görünmüyor.
///
/// ## İki yöntem kuralı
///
/// **1. Alfa zemine BİNDİRİLİR.** Yarı saydam bir rengin kendi parlaklığını
/// ölçmek, ekranda hiç var olmayan bir pikseli ölçmektir. [over] bunu yapar.
///
/// **2. Eşik İCAT DEĞİL.** WCAG 2.2 dış standart: normal metin 4.5 · büyük
/// metin (≥24px ya da ≥18.66px kalın) 3.0 · metin-dışı (ikon, sınır, gösterge)
/// 3.0. Bu ailenin "eşik artefakttan türer" kuralının en temiz hâli — artefakt
/// burada bir W3C tavsiyesi.
///
/// ## ⚠️ KAPININ SINIRI — isimle
///
/// WCAG kontrastı *"bu iki renk birbirinden ayırt edilebilir mi"* sorusunu
/// **ÖLÇMEZ**; yalnız luminans farkını ölçer. Yani bu kapı **görünürlüğü**
/// kapatır, **ayırt edilebilirliği** değil. Aynı orana sahip iki renk
/// birbirine karışabilir ve kapı yeşil yanar.
library;

import 'dart:math' as math;
import 'dart:ui';

/// WCAG eşikleri — W3C 2.2, §1.4.3 ve §1.4.11.
abstract final class Wcag {
  /// Normal metin (24px altı, ya da 18.66px altı kalın).
  static const double normalText = 4.5;

  /// Büyük metin: ≥24px, ya da ≥18.66px + FontWeight.w700.
  static const double largeText = 3.0;

  /// Metin-dışı: ikon, form sınırı, anlam taşıyan grafik (§1.4.11).
  static const double nonText = 3.0;

  /// Bir metin boyutu için geçerli eşik. Kalınlık da girer, çünkü WCAG'ın
  /// "büyük metin" tanımı ikisini birlikte kullanıyor.
  static double forText(double fontSize, FontWeight weight) {
    final bool bold = weight.value >= FontWeight.w700.value;
    final bool large = fontSize >= 24 || (bold && fontSize >= 18.66);
    return large ? largeText : normalText;
  }
}

/// [fg]'yi [bg] üstüne BİNDİRİR (source-over) ve ekranda oluşan opak rengi
/// döner. Alfası tam olan renk aynen döner.
Color over(Color fg, Color bg) {
  final double a = fg.a;
  if (a >= 1.0) return fg;
  double mix(double f, double b) => f * a + b * (1 - a);
  return Color.from(
    alpha: 1.0,
    red: mix(fg.r, bg.r),
    green: mix(fg.g, bg.g),
    blue: mix(fg.b, bg.b),
  );
}

/// WCAG göreli parlaklık.
double relativeLuminance(Color c) {
  double lin(double v) =>
      v <= 0.03928 ? v / 12.92 : math.pow((v + 0.055) / 1.055, 2.4).toDouble();
  return 0.2126 * lin(c.r) + 0.7152 * lin(c.g) + 0.0722 * lin(c.b);
}

/// İki rengin kontrast oranı. [fg] saydamsa önce [bg] üstüne bindirilir —
/// **bu adım atlanırsa ölçüm ekranda olmayan bir pikseli ölçer.**
double contrastRatio(Color fg, Color bg) {
  final double l1 = relativeLuminance(over(fg, bg));
  final double l2 = relativeLuminance(bg);
  final double hi = math.max(l1, l2);
  final double lo = math.min(l1, l2);
  return (hi + 0.05) / (lo + 0.05);
}

/// Denetlenen tek bir çift — ve NEREDE göründüğü.
///
/// [where] boş geçilemez: eşiğin altında kalan bir çiftin hangi yüzeyde
/// olduğunu bilmeyen bir rapor, düzeltilemeyen bir rapordur.
final class ContrastPair {
  const ContrastPair({
    required this.where,
    required this.fg,
    required this.bg,
    required this.threshold,
  });

  final String where;
  final Color fg;
  final Color bg;
  final double threshold;

  double get ratio => contrastRatio(fg, bg);
  bool get passes => ratio >= threshold;

  String get report =>
      '${passes ? "✅" : "❌"} $where — ${ratio.toStringAsFixed(2)}:1 '
      '(eşik ${threshold.toStringAsFixed(1)})';
}
