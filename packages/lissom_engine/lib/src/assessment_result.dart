/// Bir ölçüm-testi denemesinin sonucu — M-F-71 hükmünün KOD hâli.
///
/// Bu dosyanın var olma sebebi bir hata: `peak_hold` fazına giriş bir ROM
/// eşiği istiyordu, eşiğin altında kalan kullanıcı ne ölçüm ne uyarı alıyordu
/// (L-135). Donmuş omuzla 50°'ye ulaşabilen biri tam olarak hiçbir şey
/// görüyordu — oysa uygulamanın var olma sebebi o kişi. Hüküm (M-F-71) beş
/// maddeydi ve üçü doğrudan burada yaşıyor:
///
///   (2) Girişim algılandıysa ölçüm DAİMA tamamlanır ve değer raporlanır —
///       50° bir SONUÇTUR, hata değil. Bu yüzden [AssessmentResult] "ölçüm
///       yok" durumunu bir başarısızlık olarak DEĞİL, ayrı ve İSİMLİ bir
///       sonuç kodu olarak taşır.
///   (3) Skor bantları İÇ kalite çizgileridir; en düşük bandın altı
///       "skorsuz ama ÖLÇÜLÜ" bölgedir — [ResultTier.measuredBelowRange].
///   (4) HER faz-çıkış yolu kullanıcıya ulaşan bir sonuç kodu üretir,
///       timeout dahil. Bu yüzden [ResultCode] boş/null olamaz.
library;

/// Sonucun hangi katmana ait olduğu (M-F-71 madde 3 + 5).
enum ResultTier {
  /// Ölçüldü VE en düşük skor bandının içinde ya da üstünde — skorlanabilir.
  scored,

  /// Ölçüldü ama en düşük skor bandının ALTINDA. Kullanıcı değerini görür
  /// ("başlangıç noktan bu"); karşılaştırma/ilerleme İDDİASI kapalı kalır
  /// (MDC eşiği gelene dek). Konuşan katman KOÇLANAN'dır, SKORLANAN değil
  /// (M-F-71 madde 5, J-042/M-F-60(3) simetrisi).
  measuredBelowRange,

  /// Ölçüldü ama testin sayısal skorlama bandı YOK (ör. ankle_dorsiflexion:
  /// yalnız nitel limited/typical/good). Değer dürüstçe raporlanır, sayısal
  /// bant iddiası edilmez.
  measuredNoBands,

  /// Ölçüm hiç alınamadı. Sebep DAİMA [AssessmentResult.code]'da isimlidir —
  /// sessiz düşüş yok (M-F-71 madde 4).
  notMeasured,
}

/// Neden bu sonuç — kullanıcıya ulaşacak gerekçenin makine hâli.
///
/// "Ölçemedim" demek yanlış ölçmekten daima üstündür (00-AILE-MIMARISI §7),
/// AMA sebebini söylememek ikisinden de kötüdür (L-135).
enum ResultCode {
  /// Ölçüm alındı ve tamamlandı (tier scored / measuredBelowRange /
  /// measuredNoBands ile birlikte gelir).
  measured,

  /// Girişim hiç algılanmadı — kullanıcı hedef eklemi hedef yönde hiç
  /// hareket ettirmedi (ya da kamera görmedi). Girişim kapısı ROM eşiği
  /// DEĞİL, hareket-varlığıdır (M-F-71 madde 1).
  noAttemptDetected,

  /// Ölçüm fazına girildi ama zaman aşımına uğradı — eskiden bu yol SESSİZ
  /// düşüyordu (L-146: `phase_check.py` timeout'un bir sonuç kodu ürettiğini
  /// hiç sormuyordu). Artık isimli.
  measurementTimedOut,

  /// Ölçümden ÖNCEKİ bir faz zaman aşımına uğradı (ör. hazırlık duruşu hiç
  /// alınmadı). Faz adı [AssessmentResult.timedOutPhase]'de.
  setupTimedOut,

  /// Bir guard koşulu denemeyi iptal etti (dirsek bükük, topuk kalktı...).
  /// Kod config'in `abortCode`'undan gelir; [AssessmentResult.abortCode] o
  /// ham değeri taşır.
  aborted,

  /// İzleme kaybedildi — kamera kişiyi yeterince göremedi.
  trackingLost,

  /// Kare kalitesi hüküm için yetersizdi (düşük güven / kadraj dışı).
  lowConfidence,
}

/// Bir tekrarın (ya da tek-taraflı bir denemenin) sonucu.
final class AssessmentResult {
  const AssessmentResult({
    required this.testId,
    required this.side,
    required this.tier,
    required this.code,
    required this.provenance,
    this.value,
    this.unit,
    this.bandLabel,
    this.lowestBandFloor,
    this.timedOutPhase,
    this.abortCode,
    this.lessonClass,
    this.attemptMicros,
  });

  /// Ölçüm ALINDI kurucusu — değeri bandlara göre sınıflandırır.
  ///
  /// `bands` null ise (testin sayısal bandı yok) tier `measuredNoBands`;
  /// değer en düşük tabanın altındaysa `measuredBelowRange`; aksi hâlde
  /// `scored`. Sınıflandırma BURADA tek yerde yapılır — çağıran taraf kendi
  /// eşik kopyasını kurmaz (M-F-60 kelime-dağarcığı ilkesinin sonuç-katmanı
  /// karşılığı; kopyalanan eşik sessizce ayrışır).
  factory AssessmentResult.measured({
    required String testId,
    required String side,
    required double value,
    required String unit,
    required Map<String, String> provenance,
    Map<String, double>? bandFloors,
    String? lessonClass,
    int? attemptMicros,
  }) {
    if (bandFloors == null || bandFloors.isEmpty) {
      return AssessmentResult(
        testId: testId,
        side: side,
        tier: ResultTier.measuredNoBands,
        code: ResultCode.measured,
        provenance: provenance,
        value: value,
        unit: unit,
        lessonClass: lessonClass,
        attemptMicros: attemptMicros,
      );
    }
    // En düşük taban = tüm yaş bantlarının en alt eşiği. Bunun ALTI
    // "skorsuz ama ölçülü" bölgedir; kullanıcı sayısını görür ama bir bant
    // etiketi ATANMAZ (uydurma bant, ölçmediğimiz bir şeyi iddia etmek olur).
    final double floor =
        bandFloors.values.reduce((double a, double b) => a < b ? a : b);
    String? label;
    for (final MapEntry<String, double> e in bandFloors.entries) {
      if (value >= e.value && (label == null || e.value > bandFloors[label]!)) {
        label = e.key;
      }
    }
    return AssessmentResult(
      testId: testId,
      side: side,
      tier: value < floor ? ResultTier.measuredBelowRange : ResultTier.scored,
      code: ResultCode.measured,
      provenance: provenance,
      value: value,
      unit: unit,
      bandLabel: value < floor ? null : label,
      lowestBandFloor: floor,
      lessonClass: lessonClass,
      attemptMicros: attemptMicros,
    );
  }

  /// Ölçüm ALINAMADI kurucusu — sebep ZORUNLU.
  factory AssessmentResult.notMeasured({
    required String testId,
    required String side,
    required ResultCode code,
    required Map<String, String> provenance,
    String? timedOutPhase,
    String? abortCode,
    String? lessonClass,
    int? attemptMicros,
  }) {
    assert(code != ResultCode.measured,
        'notMeasured bir "measured" kodu taşıyamaz — sonuç kodu sonucu tarif eder');
    return AssessmentResult(
      testId: testId,
      side: side,
      tier: ResultTier.notMeasured,
      code: code,
      provenance: provenance,
      timedOutPhase: timedOutPhase,
      abortCode: abortCode,
      lessonClass: lessonClass,
      attemptMicros: attemptMicros,
    );
  }

  final String testId;

  /// `right` / `left` / `bilateral` — testin `perSide` beyanına göre.
  final String side;
  final ResultTier tier;
  final ResultCode code;

  /// M-F-07 / L-022: model varyantı+sürüm+sha, config sürümleri, kalibrasyon
  /// profili. Bir sayı dayanağını taşımadan yayılamaz.
  final Map<String, String> provenance;

  /// Ölçülen değer. `tier == notMeasured` iken null.
  final double? value;
  final String? unit;

  /// Atanan bant etiketi (`low`/`normal`/`good`). `measuredBelowRange`'de
  /// KASITLI null: bandın altındaki değere bant adı vermek, ölçmediğimiz bir
  /// sınıflandırmayı iddia etmek olurdu.
  final String? bandLabel;

  /// En düşük bant tabanı — kullanıcıya "hedefe ne kadar kaldı" anlatısı
  /// için (KOÇLANAN katman), skor olarak DEĞİL.
  final double? lowestBandFloor;

  final String? timedOutPhase;
  final String? abortCode;

  /// **Deneme PENCERESİNİN süresi** (µs) — girişim algılandığı andan denemenin
  /// kapandığı ana kadar. Hazırlık/`ready` fazı DIŞARIDA: aile kalıcılık
  /// şeması `workedSeconds`'ı "gerçekten ÇALIŞILAN saniye, dinlenme hariç"
  /// diye tanımlıyor ve ilerleme kapıları onu sayıyor — duvar-saati süresi
  /// kullanmak kullanıcının kazanmadığı kapıları geçirirdi.
  ///
  /// Girişim hiç algılanmadıysa null. Girişim BAŞLADI ama hüküm verilemediyse
  /// (izleme kaybı, düşük güven, iptal) **null DEĞİL** — o çalışma gerçekten
  /// oldu ve `unmeasuredUnits` ile birlikte kaydedilmeli; sessizlik yalan
  /// söyler.
  final int? attemptMicros;

  /// **YAZIM ANINDA damgalanan ders-sınıfı** (aile standardı, M-F-185(c)).
  ///
  /// `measurementOnly` = bu ölçüm bir referansa karşı KIYASLANMADI, çünkü
  /// testin referansı ölçülmüş bir gerekçeyle YOK (`TestSpec.referenceStatus`).
  /// Neden yazım anında: sonradan türetilen bir sınıf, config değişince
  /// SESSİZCE anlam değiştirir — kayıt hangi rejimde alındığını kendi
  /// üstünde taşımalı (M-F-138'in oturum-kaydı düzeyindeki karşılığı).
  ///
  /// null = normal rejim (referanslı/bantlı test).
  final String? lessonClass;

  bool get isMeasurementOnly => lessonClass == 'measurementOnly';

  bool get isMeasured => tier != ResultTier.notMeasured;

  /// M-F-71 madde 5: bu sonuçta konuşan katman koçlanan mı?
  ///
  /// Eşik-altı ölçüm ve ölçülemeyen deneme, ikisi de KOÇLANAN katmandan
  /// konuşur ("kolun kalktı, ölçüm için biraz daha yukarı" sınıfı) —
  /// skorlanan katmandan değil.
  bool get speaksAsCoaching =>
      tier == ResultTier.measuredBelowRange || tier == ResultTier.notMeasured;

  @override
  String toString() => 'AssessmentResult($testId/$side, ${tier.name}, '
      '${code.name}${value == null ? "" : ", ${value!.toStringAsFixed(1)}$unit"}'
      '${bandLabel == null ? "" : ", band=$bandLabel"})';
}
