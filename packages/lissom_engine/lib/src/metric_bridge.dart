/// Lissom metrik adı → çekirdeğin `JointSpec` açısı köprüsü.
///
/// **Neden bir köprü, kendi hesabı DEĞİL:** motor açı matematiğini yazmaz.
/// Üçüncü bir paralel geometri implementasyonu, farklı-sonuç riskinin ta
/// kendisidir (L-154'ün bulduğu sınıf: iki ayrı hat aynı metriği farklı
/// çerçevede ölçüyordu ve kimse fark etmiyordu). Bu dosya YALNIZ eşleme
/// yapar; sayıyı çekirdek üretir.
///
/// ⚠️ **KONVANSİYON — ÖLÇÜLDÜ, ve ilk varsayımım YANLIŞ ÇIKTI.** Bu bloğun
/// ilk hâlinde "çekirdek iç-açı okur, Lissom ROM dili konuşur, dolayısıyla
/// 180−x çevrimi gerekir" yazıyordu. `real_replay_test.dart` ölçtü:
/// `right_shoulder` JointSpec'i `a=ELBOW, b=SHOULDER, c=HIP` — yani ışınlar
/// omuzdan dirseğe ve omuzdan kalçaya gider. Kol yanda aşağıyken İKİ ışIN DA
/// aşağı bakar ⇒ açı **0°**; kol baş üstündeyken ışınlar zıtlaşır ⇒ **180°**.
/// Çekirdek ZATEN ROM konvansiyonunda. Benim çevrimim sayıları TERS
/// çeviriyordu (aşağı=180°, yukarı=0°) ve bu makul GÖRÜNEN bir sayı olduğu
/// için testsiz fark edilmezdi. `invert` alanı yine de duruyor: başka bir
/// metrik gerçekten çevrim isterse mekanizma yerinde olsun, ve her binding'in
/// işareti ölçümle çivilenmiş olsun.
library;

import 'dart:math' as math;

import 'package:motion_core/motion_core.dart';

/// Bir Lissom metriğinin çekirdek karşılığı + konvansiyon dönüşümü.
final class MetricBinding {
  const MetricBinding({
    required this.lissomMetric,
    required this.coreJointId,
    required this.invert,
  });

  final String lissomMetric;
  final String coreJointId;

  /// `true` ise çekirdeğin iç-açısı ROM diline çevrilir (180 − x).
  final bool invert;

  double toLissomDegrees(double coreRadians) {
    final double deg = coreRadians * 180 / math.pi;
    return invert ? 180 - deg : deg;
  }
}

/// V0 kapsamı: `AssessmentEngine`'in bugün gerçek fixture'la koşturulabildiği
/// metrikler. Liste KASITLI kısa — bağlanmayan metrik burada YOK, ve
/// [bindingFor] bilinmeyen adı sessizce null döndürmek yerine ADIYLA
/// reddeder ("bağlandı ≠ canlı": eksik eşleme sessiz sıfır üretmemeli).
const List<MetricBinding> kMetricBindings = <MetricBinding>[
  // ÖLÇÜLDÜ: kol yanda aşağı → 0°, kol baş üstü → 180°. Çekirdek zaten ROM
  // konvansiyonunda; çevrim YOK (ilk varsayımım tersiydi, bkz. modül başlığı).
  MetricBinding(
      lissomMetric: 'shoulder_flexion_right',
      coreJointId: 'right_shoulder',
      invert: false),
  MetricBinding(
      lissomMetric: 'shoulder_flexion_left',
      coreJointId: 'left_shoulder',
      invert: false),
  // Diz: Lissom da iç açı konuşuyor (180 = düz bacak) → dönüşüm YOK.
  MetricBinding(
      lissomMetric: 'knee_flexion_right',
      coreJointId: 'right_knee',
      invert: false),
  MetricBinding(
      lissomMetric: 'knee_flexion_left',
      coreJointId: 'left_knee',
      invert: false),
];

MetricBinding bindingFor(String lissomMetric) {
  for (final MetricBinding b in kMetricBindings) {
    if (b.lissomMetric == lissomMetric) return b;
  }
  throw ArgumentError(
    'metrik köprüsü YOK: $lissomMetric. Eşlenmemiş bir metrik sessizce '
    'sıfır/null üretmemeli — köprüyü ekleyin ya da testi kapsam dışı '
    'bırakın (bağlandı ≠ canlı).',
  );
}

/// Gerçek fixture'ları motora bağlayan okuyucu.
///
/// Çekirdeğin kendi hattını kullanır: `PoseNormalizer` → `JointAngleExtractor`.
/// `ConfidenceGate` motorun kendi tarafında koşar (motor kare kalitesini
/// zaten sorguluyor), burada yalnız açı okunur.
final class CoreMetricReader {
  CoreMetricReader({
    List<JointSpec> specs = StandardJoints.fullBody,
    PoseNormalizer? normalizer,
  })  : _extractor = JointAngleExtractor(specs: specs),
        _normalizer = normalizer ?? PoseNormalizer(),
        _specs = specs;

  final JointAngleExtractor _extractor;
  final PoseNormalizer _normalizer;
  final List<JointSpec> _specs;

  /// `AssessmentEngine.metricReader` imzasına uyan okuyucu.
  double? read(PoseFrame frame, String lissomMetric) {
    final MetricBinding b = bindingFor(lissomMetric);
    final int idx = _specs.indexWhere((JointSpec s) => s.id == b.coreJointId);
    if (idx < 0) {
      throw ArgumentError(
        '${b.coreJointId} bu JointSpec kümesinde yok — yanlış scope ile '
        'okuma denenirse metrik sessizce ölçülemez görünür (M-O-43 dersi).',
      );
    }
    final JointAngleVector v = _extractor.extract(_normalizer.normalize(frame));
    final double rad = v.values[idx];
    if (rad.isNaN) return null;
    return b.toLissomDegrees(rad);
  }
}
