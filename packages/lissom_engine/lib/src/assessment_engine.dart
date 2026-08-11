/// ROM Assessment Engine — bir ölçüm testini kare akışı üzerinde koşturur.
///
/// **M-F-71 hükmü bu sınıfın mimarisidir, bir kontrol listesi değil:**
///
///   1. Girişim kapısı GİRİŞİM ölçer, ROM DEĞİL. [_attemptDetected] hedef
///      metriğin girişim eşiğini `requiredHoldS` kadar KESİNTİSİZ aşmasını
///      bekler — bu bir "yeterince iyi mi" sorusu değil, "hareket oldu mu"
///      sorusudur. Eşik `movementPresence`'tan gelir (fixture doğrulamasıyla
///      AYNI kaynak), skor bandından değil.
///   2. Girişim algılandıysa ölçüm DAİMA tamamlanır: [_peak] her karede
///      güncellenir ve deneme nasıl biterse bitsin (tamamlandı/timeout)
///      raporlanır. "Yetersiz açı" diye ölçüm-reddi YOKTUR.
///   4. Her çıkış yolu isimli bir [ResultCode] üretir — timeout dahil.
///      [finish] hiçbir yolda null dönmez; sessiz düşüş yapısal olarak
///      imkânsızdır.
///
/// Faz makinesinin kendisi çekirdekten gelir (`PhaseStateMachine`); bu motor
/// onun ÜSTÜNDE ölçüm-testi semantiğini kurar. Çekirdeğe app mantığı sızmaz,
/// buraya çekirdek matematiği kopyalanmaz (M-F-31: aile aracının varsayımı
/// kendi verinde ÖLÇÜLMEDEN devralınmaz — bu yüzden ölçüm `JointAngleVector`
/// üzerinden çekirdeğin kendi geometrisiyle okunur, paralel bir hesap yazılmaz).
library;

import 'package:motion_core/motion_core.dart';

import 'assessment_result.dart';
import 'battery.dart';

/// Bir karenin motor tarafından okunmuş hâli.
final class _FrameReading {
  const _FrameReading(this.tUs, this.value, this.judgeable, this.issue);
  final int tUs;

  /// Girişim metriğinin bu karedeki değeri; okunamadıysa null.
  final double? value;
  final bool judgeable;
  final QualityIssue? issue;
}

/// Tek bir testin tek bir tarafını koşturan motor.
///
/// Yaşam döngüsü: [reset] → her kare için [process] → [finish].
/// [finish] çağrılmadan sonuç YOKTUR (yarı-yolda kalan bir denemenin
/// "sonucu" olamaz), ve çağrıldığında DAİMA isimli bir sonuç döner.
final class AssessmentEngine {
  AssessmentEngine({
    required this.test,
    required this.metricReader,
    required this.provenance,
    this.side = 'right',
    this.ageBand,
    this.gate = const ConfidenceGate(),
    this.setupTimeoutMs = 30000,
    this.measurementTimeoutMs = 8000,
    this.trackingLostGraceMs = 500,
  }) : assert(side == 'right' || side == 'left' || side == 'bilateral',
            'taraf right|left|bilateral olmalı');

  final TestSpec test;

  /// Girişim metriğini bir kareden okur. Çekirdeğin geometrisini kullanan bir
  /// kapanış olarak enjekte edilir — motor kendi açı matematiğini YAZMAZ
  /// (üçüncü bir paralel implementasyon, farklı-sonuç riski demektir).
  final double? Function(PoseFrame frame, String metricName) metricReader;

  /// M-F-07/L-022: model varyantı+sha, config sürümleri, kalibrasyon profili.
  final Map<String, String> provenance;

  final String side;

  /// Yaş bandı — skorlama bantları yaşa göre değişir. null iken EN
  /// MUHAFAZAKÂR bant kullanılır (bkz. [ScoringSpec.floorsFor]).
  final String? ageBand;

  final ConfidenceGate gate;

  /// Girişim hiç algılanmazsa ne kadar bekleriz.
  final int setupTimeoutMs;

  /// Girişim algılandıktan sonra ölçüm için ne kadar bekleriz.
  ///
  /// ⚠️ Bu bir ÖLÇÜM-REDDİ süresi DEĞİL: süre dolduğunda o ana kadarki tepe
  /// değer RAPORLANIR ([ResultCode.measurementTimedOut] koduyla), atılmaz.
  final int measurementTimeoutMs;

  final int trackingLostGraceMs;

  bool _started = false;
  int? _firstFrameUs;
  int? _attemptStartUs;
  int? _holdStartUs;
  int? _lastHoldUs;
  int? _lostSinceUs;
  double? _peak;
  int _lowConfidenceFrames = 0;
  int _totalFrames = 0;
  String? _abortCode;

  bool get attemptDetected => _attemptStartUs != null;

  /// O ana kadar ölçülmüş tepe değer (girişim algılanmadan da birikebilir —
  /// M-F-71 madde 2: değer bir SONUÇTUR, kapıdan geçmesi şart değil).
  double? get peak => _peak;

  void reset() {
    _started = false;
    _firstFrameUs = null;
    _attemptStartUs = null;
    _holdStartUs = null;
    _lastHoldUs = null;
    _lostSinceUs = null;
    _peak = null;
    _lowConfidenceFrames = 0;
    _totalFrames = 0;
    _abortCode = null;
  }

  /// Bir guard koşulunu dışarıdan iptal olarak bildirir (config'in
  /// `abortCode`'u). Motor guard'ların İÇERİĞİNİ bilmez — kod config'ten
  /// gelir, motor yalnız taşır.
  void reportAbort(String abortCode) => _abortCode ??= abortCode;

  /// Bir kareyi işler. Dönüş: bu karede ölçüm güncellendi mi.
  bool process(PoseFrame frame) {
    _totalFrames++;
    _started = true;
    _firstFrameUs ??= frame.tUs;

    final _FrameReading r = _read(frame);
    if (!r.judgeable) {
      _lowConfidenceFrames++;
      _lostSinceUs ??= frame.tUs;
      return false;
    }
    _lostSinceUs = null;

    // ⛔ `invalidation` BİLEREK burada değerlendirilmiyor (A4, 2026-08-11).
    //
    // Denendi ve GERİ ALINDI: "herhangi bir karede ihlal → tüm deneme iptal"
    // tetiklemesi gerçek `X2u_vGL0qJU` fixture replay'inde (önceden geçerliliği
    // kanıtlanmış, temiz bir baş-üstü uzanma — L-141/L-162) yanlış-pozitif
    // üretti: `elbow_extension_right` 5899 karenin BİRİNDE 150°'nin altına
    // düştü (muhtemelen izleme gürültüsü) ve bu tek kare TÜM ölçümü
    // `aborted/BENT_ELBOW` yaptı — `real_replay_test.dart` bunu yakaladı.
    //
    // Doğru tetikleme politikası (tepe-karesinde mi, sürdürülmüş ihlalde mi,
    // ne kadar sürede) ÖLÇÜLMEDİ ve config'te bir `minViolationHoldS` gibi
    // beyan edilmiş bir eşik YOK — icat etmek burada eşik icadı olurdu.
    // `TestSpec.invalidation` (battery.dart) artık config'i doğru okuyor;
    // motor bağlantısı bu politika kararı netleşene kadar KASITLI eksik.
    // Bkz. A1-A5 raporu + koordinatöre 2. sevk cevabı.

    final double? v = r.value;
    if (v == null) return false;

    // M-F-71 madde 2: tepe DAİMA güncellenir. Girişim kapısının altında
    // kalan bir değer de ölçümdür — 50° bir sonuçtur, hata değil.
    final PresenceGate? g = test.presenceGate;
    final bool better = _peak == null ||
        (test.scoring.higherIsBetter ? v > _peak! : v < _peak!);
    if (better) _peak = v;

    if (g == null) return true;

    // Girişim kapısı: eşiği KESİNTİSİZ olarak requiredHoldS kadar aşmalı.
    // Kümülatif kare sayımı YETMEZ — gürültü ve kısa jestler toplamda
    // eşiği kolayca geçer ama tutuş üretmez (fixture_check.py'nin
    // `longest_hold_s` dersi, aynı kural motor tarafında).
    if (g.holds(v)) {
      final int? last = _lastHoldUs;
      final bool broken =
          last != null && (frame.tUs - last) > trackingLostGraceMs * 1000;
      if (_holdStartUs == null || broken) _holdStartUs = frame.tUs;
      _lastHoldUs = frame.tUs;
      final int heldUs = frame.tUs - _holdStartUs!;
      if (_attemptStartUs == null &&
          heldUs >= (test.requiredHoldS * 1e6).round()) {
        _attemptStartUs = _holdStartUs;
      }
    } else {
      _holdStartUs = null;
      _lastHoldUs = null;
    }
    return true;
  }

  /// Denemeyi kapatır ve DAİMA isimli bir sonuç döner (M-F-71 madde 4).
  ///
  /// Hiçbir yolda null yoktur: her çıkış — ölçüldü, girişim yok, timeout,
  /// iptal, izleme kaybı, düşük güven — kendi [ResultCode]'unu taşır.
  AssessmentResult finish({int? nowUs}) {
    if (!_started) {
      return AssessmentResult.notMeasured(
        testId: test.id,
        side: side,
        code: ResultCode.noAttemptDetected,
        provenance: provenance,
        lessonClass: _lessonClass,
      );
    }

    final int end = nowUs ?? _lastHoldUs ?? _firstFrameUs ?? 0;

    // İptal, her şeyden önce gelir: guard bir ölçümü geçersiz kılar.
    final String? abort = _abortCode;
    if (abort != null) {
      return AssessmentResult.notMeasured(
        testId: test.id,
        side: side,
        code: ResultCode.aborted,
        provenance: provenance,
        abortCode: abort,
        lessonClass: _lessonClass,
        attemptMicros: _attemptMicros(end),
      );
    }

    // ⚠️ SIRA M-F-71 MADDE 2'NİN TA KENDİSİ — gerçek fixture bunu yakaladı.
    //
    // İlk sürümde izleme-kaybı ve düşük-güven kontrolleri ölçüm raporundan
    // ÖNCE geliyordu. Gerçek videoda kişi tekrarını yapıp kadrajdan çıkıyor
    // (ya da video kararıyor), yani KUYRUK kareleri hüküm-dışı oluyor —
    // ve tamamlanmış, geçerli bir ölçüm `trackingLost` diye ÇÖPE GİDİYORDU.
    // Ölçüldü: `X2u_vGL0qJU` fixture'ında 5899/10730 kare okundu, girişim
    // algılandı, tepe değer birikti, sonuç yine "notMeasured/trackingLost".
    //
    // Doğru semantik: izleme kaybı ölçümü ENGELLEDİYSE bir sebeptir; ölçüm
    // ZATEN tamamlandıysa sebep değil, sonrasında olmuş bir olaydır.
    // Bu yüzden ölçüm önce raporlanır, kalite kodları yalnız ölçüm YOKKEN
    // sebep olarak konuşur.
    if (_attemptStartUs != null && _peak != null) {
      return _measuredResult(end);
    }

    // Buradan aşağısı: ölçüm ALINAMADI. Sebep ZORUNLU ve isimli.
    if (_totalFrames > 0 && _lowConfidenceFrames * 2 > _totalFrames) {
      return AssessmentResult.notMeasured(
        testId: test.id,
        side: side,
        code: ResultCode.lowConfidence,
        provenance: provenance,
        lessonClass: _lessonClass,
        attemptMicros: _attemptMicros(end),
      );
    }
    final int? lost = _lostSinceUs;
    if (lost != null && (end - lost) > trackingLostGraceMs * 1000) {
      return AssessmentResult.notMeasured(
        testId: test.id,
        side: side,
        code: ResultCode.trackingLost,
        provenance: provenance,
        lessonClass: _lessonClass,
        attemptMicros: _attemptMicros(end),
      );
    }

    // Girişim hiç algılanmadı: hazırlık zaman aşımı mı, hiç deneme mi?
    final int elapsed = end - (_firstFrameUs ?? end);
    return AssessmentResult.notMeasured(
      testId: test.id,
      side: side,
      code: elapsed >= setupTimeoutMs * 1000
          ? ResultCode.setupTimedOut
          : ResultCode.noAttemptDetected,
      provenance: provenance,
      timedOutPhase: elapsed >= setupTimeoutMs * 1000 ? 'ready' : null,
      lessonClass: _lessonClass,
      attemptMicros: _attemptMicros(end),
    );
  }

  /// Girişim penceresi — girişim hiç başlamadıysa null (0 DEĞİL: "çalışma
  /// olmadı" ile "çalışma oldu ama sıfır sürdü" farklı iddialardır).
  int? _attemptMicros(int end) {
    final int? start = _attemptStartUs;
    return start == null ? null : end - start;
  }

  /// Ölçüm raporu — timeout değeri KORUR, yalnız kodu değiştirir.
  AssessmentResult _measuredResult(int end) {
    final double value = _peak!;
    final int measuring = end - _attemptStartUs!;
    final AssessmentResult measured = AssessmentResult.measured(
      testId: test.id,
      side: side,
      value: value,
      unit: test.scoring.unit ?? '',
      provenance: provenance,
      bandFloors: test.scoring.floorsFor(ageBand),
      lessonClass: _lessonClass,
      attemptMicros: measuring,
    );
    if (measuring >= measurementTimeoutMs * 1000) {
      // ⚠️ Timeout ölçümü ÇÖPE ATMAZ — değeri korur, kodu değiştirir.
      // Eskiden bu yol sessizce düşüyordu (L-146).
      return AssessmentResult(
        testId: measured.testId,
        side: measured.side,
        tier: measured.tier,
        code: ResultCode.measurementTimedOut,
        provenance: measured.provenance,
        value: measured.value,
        unit: measured.unit,
        bandLabel: measured.bandLabel,
        lowestBandFloor: measured.lowestBandFloor,
        timedOutPhase: 'peak_hold',
        lessonClass: measured.lessonClass,
      );
    }
    return measured;
  }

  /// M-F-185(c): ders-sınıfı YAZIM ANINDA testin referans durumundan gelir.
  String? get _lessonClass =>
      test.referenceStatus?.isMeasurementOnly == true ? 'measurementOnly' : null;

  _FrameReading _read(PoseFrame frame) {
    final String metricName = test.primaryMetricFor(side);
    final FrameQuality q = gate.evaluate(frame, required: const <int>[]);
    if (!q.judgeable) {
      return _FrameReading(frame.tUs, null, false, q.issue);
    }
    return _FrameReading(
        frame.tUs, metricReader(frame, metricName), true, null);
  }
}
