/// A5 özet yüzeyinin SABİT metinleri — ve bunların sınırı.
///
/// **Köken ayrımı (bu dosyanın var olma sebebi).** Yüzeyde iki farklı köken
/// taşıyan metin var, ve karıştırılırlarsa "hiçbir metin uydurmuyoruz" sözü
/// sessizce bozulur:
///
///   1. **ÖLÇÜM DURUMU HAKKINDAKİ İDDİALAR** — "bu testin referansı neden yok",
///      "bunu ne açar", "neden ölçemedik". Bunlar CONFIG'ten gelir
///      (`referenceStatus.statusBasis.userText`, `promotionPath`, sonuç
///      kodları). Buraya YAZILMAZ. Bir ölçüm hakkındaki iddia, ölçümün
///      kaydıyla birlikte yaşamalı — kodda sabitlenmiş bir gerekçe, config
///      değişince SESSİZCE yanlışa döner.
///   2. **YÜZEY MOBİLYASI** — bölüm başlıkları, birim biçimi, "hüküm yok"
///      işareti. Bunlar bir ölçüm hakkında hiçbir şey İDDİA ETMEZ; sadece
///      kullanıcının hangi bölüme baktığını söyler. Onlar burada.
///
/// Sınır sınavı: *bir cümle belirli bir testin ölçüm durumu değişince
/// yanlışlanabiliyorsa, o cümle config'e aittir.*
library;

/// Yüzey mobilyası. Ölçüm hakkında iddia YOK.
abstract final class SummaryStrings {
  static const String scoredSection = 'Measured and compared';
  static const String scoredSubtitle =
      'Your number, placed against the range we compare with.';

  static const String belowRangeSection = 'Measured — your starting point';
  static const String belowRangeSubtitle =
      'Below the lowest range we compare against. That is a starting point, '
      'not a failure — and the number is yours.';

  static const String noBandsSection = 'Measured — read qualitatively';
  static const String noBandsSubtitle =
      'These tests have no numeric range to compare against, by design.';

  /// ⚠️ Buradaki iki metin `yet` taşıyordu ve `yet` M-F-186'nın yasakladığı
  /// üç kelimeden biri. İhlal ÜSLUP meselesi değildi: *"not compared **yet**"*,
  /// karşılaştırmama kararını **tasarlanmış bir hâlden eksik bir hâle**
  /// indiriyordu — oysa Progress'in kıyas yapmaması bir eksiklik değil, bu
  /// ürünün en dürüst kararı. Sebep zaten her satırda; `yet` bilgi eklemiyor,
  /// yalnız söz veriyor. (Ostinato'nun hükmü, koordinatör taşıdı:
  /// *"gerekçenin varlığı 'yet'i affetmiyor."*)
  static const String notComparedSection = 'Measured — not compared';
  static const String notComparedSubtitle =
      'The number is real. Why we cannot compare it is on each row.';

  static const String notMeasuredSection = 'Not measured';
  static const String notMeasuredSubtitle =
      'Named, with the reason. We would rather tell you than leave a blank.';

  /// A5'in tepesindeki beyan — koordinatörün (d) koşulu, M-F-186 mührü.
  /// Yüzey ne olduğunu KENDİ söylüyor: bunlar ölçüm, not değil.
  static const String header = 'MEASUREMENTS, NOT MARKS';

  /// Hüküm YOK işareti. Boş bırakmak "değer eksik" gibi okunur; tire
  /// "hüküm ABSENT" der — sıfır hükmü DEĞİL (Choreia noBand emsali).
  static const String noJudgement = '—';

  /// Birim taşıyan biçim: hiçbir çağıran çıplak sayı basamaz.
  static String value(double v, String? unit) =>
      unit == null ? v.toStringAsFixed(1) : '${v.toStringAsFixed(1)} $unit';

  /// Ölçülemeyen satırda sebebin makine adı yüzey diline çevrilir.
  /// Bilinmeyen kod SESSİZCE yutulmaz — kodun kendisi gösterilir, çünkü
  /// isimsiz bir başarısızlık L-135'in ta kendisi.
  static String reason(String code) => switch (code) {
        'noAttemptDetected' => 'We did not see an attempt at this movement.',
        'measurementTimedOut' => 'The measurement ran out of time.',
        'setupTimedOut' => 'The setup pose was never reached.',
        'aborted' => 'The attempt was stopped by a form check.',
        'trackingLost' => 'The camera lost track of you.',
        'lowConfidence' => 'The camera view was not clear enough to judge.',
        _ => 'Not measured ($code).',
      };

  // NOT: `forbiddenSurfaceWords` listesi BURADAN KALDIRILDI (L-229).
  //
  // Aynı sözlük `test/support/copy_gate.dart`ta da vardı — ikiz. Ve ikizin
  // bedeli ölçüldü: bu dosyanın KENDİSİ iki `yet` ihlali taşırken, listesinde
  // `yet` YOKTU; üstelik liste `lib/` içinde yaşadığı için kaynak-düzeyi
  // süzgeç onu "yasak kelime kullanımı" sanıp false-positive üretiyordu.
  //
  // Yasaklı sözcük sözlüğü bir ÜRÜN verisi değil bir KAPI verisidir; yeri
  // test katmanı. Tek kaynak artık `copy_gate.kBannedSurfaceCopy` ve o liste
  // `yet`i de taşıyor.
}
