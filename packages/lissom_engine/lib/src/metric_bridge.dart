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
///
/// ⛔ **BU KÖPRÜ REFERANS-EŞDEĞERİ DEĞİL — ÖLÇÜLDÜ (L-031).** Aşağıdaki
/// [kBridgeIsReferenceEquivalent] `false`, ve bu bir ihtiyat beyanı değil,
/// 44.022 eşleştirilmiş karede ölçülmüş bir olgu. Çekirdeğin Dart hattı
/// `lm` (görüntü-normalize x,y) üzerinde HAM 2D açı hesaplıyor; normatif
/// Python yorumlayıcısı `world` (metrik 3D) üzerinde config'in
/// `frameRef`/`plane` taksonomisiyle hesaplıyor (M-F-53/54). Fark:
/// **medyan 11,29°, p95 37,47°, tepe 124,62°** (kanıt:
/// `docs/L-031-UZAY-SAPMASI-OLCUMU.md`; ilk raporladığım 14,30°/60,64°
/// ŞİŞKİNDİ — karşılaştırma betiği `valid` bayrağını okumuyordu, L-197).
/// Yani bu okuyucunun ürettiği sayı
/// canlı-tur ekranında **referans-derecesi ölçüm olarak sunulamaz**;
/// [kUnbridgedMetrics] ve `metric_coverage_test.dart` bunu yapısal olarak
/// zorlar. Kanonik-uzay kararı: `docs/KARAR-BRIFI-kanonik-uzay.md` seçenek C
/// (Python'da uygulandı, Dart'a GÖÇMEDİ).
library;

import 'dart:math' as math;

import 'package:motion_core/motion_core.dart';

import 'battery.dart';

/// Bu köprünün ürettiği sayı normatif Python yorumlayıcısıyla aynı mı?
///
/// **Hayır — ve bu ÖLÇÜLDÜ, varsayılmadı.** `true` yapılabilmesi için
/// çekirdeğin Dart hattının `world` uzayına + config `frameRef`'ine geçmesi
/// gerekir (L-031 kapanışı). Sabit burada duruyor ki "referans-eşdeğeri"
/// iddiası bir gün sessizce doğmasın: kapı bu sabitle beyanların
/// tutarlılığını sınıyor.
const bool kBridgeIsReferenceEquivalent = false;

/// Köprünün fiilen ölçtüğü uzay — çekirdeğin OWN sözlüğüyle.
///
/// Kendi enum'umuzu uydurmuyoruz: `MeasurementSpace` çekirdekte zaten var
/// (`world` · `isotropic` · `pixel`) ve ailenin varsayılanı `isotropic`.
/// Paralel bir sözlük, paralel bir geometri implementasyonu kadar tehlikeli
/// olurdu — iki taraf aynı kelimeye farklı şey der ve kimse fark etmez.
const MeasurementSpace kBridgeSpace = MeasurementSpace.isotropic;

/// Bir Lissom metriğinin çekirdek karşılığı + konvansiyon dönüşümü.
final class MetricBinding {
  const MetricBinding({
    required this.lissomMetric,
    required this.coreJointId,
    required this.invert,
    required this.configFrameRef,
  });

  final String lissomMetric;
  final String coreJointId;

  /// `true` ise çekirdeğin iç-açısı ROM diline çevrilir (180 − x).
  final bool invert;

  /// Config'in bu metrik için BEYAN ETTİĞİ çerçeve (`proximal` · `none` ·
  /// `gravityYaw` · `camera`).
  ///
  /// Köprü bunu bugün UYGULAYAMIYOR ([kBridgeSpace] görüntü düzlemi) — alan
  /// yine de ZORUNLU, çünkü uygulanmayan bir çerçeve beyanının kaydı
  /// tutulmazsa sapma görünmez hale gelir. `aggregation`ın okuyucusuz kalıp
  /// sessizce yanlışlaşması (L-181) tam bu sınıftı: bilgi taşıyan alana
  /// OKUYUCU verilir, süs olarak bırakılmaz.
  final String configFrameRef;

  double toLissomDegrees(double coreRadians) {
    final double deg = coreRadians * 180 / math.pi;
    return invert ? 180 - deg : deg;
  }
}

/// Neden bir metrik bugün köprülenemiyor — İSİMLİ engel sınıfı.
enum BridgeBlocker {
  /// Çekirdeğin Dart hattında bu ölçü TİPİ hiç yok (`distance_norm`,
  /// `height_diff_norm`, `line_deviation_norm`). Python'da var, Dart'ta yok.
  coreLacksMeasureKind,

  /// Çekirdekte tek ve İŞARETLİ bir `trunk_tilt` var; config iki AYRI
  /// düzlem metriği istiyor (sagittal `trunk_lean`, frontal
  /// `trunk_lateral_tilt`). İkisini aynı sayıya bağlamak L-011'in ölü-metrik
  /// sınıfı olurdu — iki farklı metrik, tek bir sayı.
  ///
  /// ⚠️ **İKİNCİ gerekçe, L-190 turunda ölçüldü:** düzlem ayrımı gelse bile
  /// çekirdeğin `trunkTilt`i dikeyi **görüntü dikeyi** sayıyor
  /// (`rawTorsoAxisAngle − (−π/2)`), yani kamera roll'unda yerçekimi
  /// dikeyinden sapar. Config ise `gravityYaw` BEYAN EDİYOR. Bu, L-190/2'nin
  /// (`height_diff_norm` dalının ham dünya-y kullanması) Dart'taki MEVCUT
  /// örneğidir — Python'da düzeltilecek olan sınıfın aynısı. Köprü bugün
  /// bunu tüketmiyor; tüketirse aynı beyan-uygulama ayrışmasını devralır.
  corePlaneSeparationMissing,
}

/// Bataryanın İSTEDİĞİ ama köprülenmemiş metrikler — her biri İSİMLİ engelle.
///
/// Bu liste bir eksiklik itirafı DEĞİL, bir kapı girdisidir: `metric_coverage_
/// test.dart` bataryanın gerektirdiği kümeyi config'ten TÜRETİR ve
/// köprülenmiş ∪ burada beyan edilmiş kümesine eşit olmasını zorlar. Yeni bir
/// metrik config'e girdiğinde ne sessizce çalışır görünür ne de canlı turda
/// patlar — kapı derhal kırmızı yanar.
const Map<String, BridgeBlocker> kUnbridgedMetrics = <String, BridgeBlocker>{
  'trunk_lean': BridgeBlocker.corePlaneSeparationMissing,
  'trunk_lateral_tilt': BridgeBlocker.corePlaneSeparationMissing,
  'tibia_inclination_right': BridgeBlocker.corePlaneSeparationMissing,
  'tibia_inclination_left': BridgeBlocker.corePlaneSeparationMissing,
  'heel_rise_right': BridgeBlocker.coreLacksMeasureKind,
  'heel_rise_left': BridgeBlocker.coreLacksMeasureKind,
  'knee_height_right': BridgeBlocker.coreLacksMeasureKind,
  'knee_height_left': BridgeBlocker.coreLacksMeasureKind,
  'reach_depth': BridgeBlocker.coreLacksMeasureKind,
  'shoulder_line_foreshortening': BridgeBlocker.coreLacksMeasureKind,
  'plank_hip_deviation': BridgeBlocker.coreLacksMeasureKind,
};

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
      invert: false,
      configFrameRef: 'proximal'),
  MetricBinding(
      lissomMetric: 'shoulder_flexion_left',
      coreJointId: 'left_shoulder',
      invert: false,
      configFrameRef: 'proximal'),
  // Diz: Lissom da iç açı konuşuyor (180 = düz bacak) → dönüşüm YOK.
  MetricBinding(
      lissomMetric: 'knee_flexion_right',
      coreJointId: 'right_knee',
      invert: false,
      configFrameRef: 'none'),
  MetricBinding(
      lissomMetric: 'knee_flexion_left',
      coreJointId: 'left_knee',
      invert: false,
      configFrameRef: 'none'),
  // ÖLÇÜLDÜ (sentetik iskelet, `bridge_convention_test.dart` çiviliyor):
  // ayakta düz duruşta çekirdek `right_hip` = 180,0°; diz öne+yukarı
  // (oturma) duruşunda 78,7°. Config aynı dili konuşuyor ("Smaller = deeper
  // flexion", aralık [20,200]) → çevrim YOK. Landmark üçlüsü BİREBİR aynı:
  // config `[RIGHT_SHOULDER, RIGHT_HIP, RIGHT_KNEE]` = çekirdek
  // `rightHip(a: rightShoulder, b: rightHip, c: rightKnee)`.
  MetricBinding(
      lissomMetric: 'hip_flexion_right',
      coreJointId: 'right_hip',
      invert: false,
      configFrameRef: 'proximal'),
  MetricBinding(
      lissomMetric: 'hip_flexion_left',
      coreJointId: 'left_hip',
      invert: false,
      configFrameRef: 'proximal'),
  // ÖLÇÜLDÜ: kol düz uzanmışken çekirdek `right_elbow` = 180,0°; dirsek tam
  // bükülüyken 6,3°. Config guard'ı "elbow_extension_{side} < 150 →
  // BENT_ELBOW" yani BÜYÜK = daha düz; yön aynı → çevrim YOK. Üçlü birebir:
  // config `[RIGHT_SHOULDER, RIGHT_ELBOW, RIGHT_WRIST]`.
  MetricBinding(
      lissomMetric: 'elbow_extension_right',
      coreJointId: 'right_elbow',
      invert: false,
      configFrameRef: 'none'),
  MetricBinding(
      lissomMetric: 'elbow_extension_left',
      coreJointId: 'left_elbow',
      invert: false,
      configFrameRef: 'none'),
];

/// Bir testin canlı koşabilme durumu — **türetilir, elle yazılmaz.**
final class TestLiveness {
  const TestLiveness({
    required this.testId,
    required this.metrics,
    required this.blocker,
  });

  final String testId;

  /// Testin ihtiyaç duyduğu (`{side}` çözülmüş) birincil metrikler.
  final List<String> metrics;

  /// `null` = canlı koşabilir. Dolu = İSİMLİ engel.
  ///
  /// Metin NEDEN'i taşır ve **vaat dili İÇERMEZ** (M-F-186): "yakında"
  /// bilmediğimiz bir tarihi ima eder — ölçüm yerine sayı uydurmakla aynı
  /// dürüstlük sınıfı.
  final String? blocker;

  bool get isLive => blocker == null;
}

/// Bataryanın her testi için canlılık durumunu TÜRETİR.
///
/// Kapsam hükmü (M-F-272 / L-206) burada bir SABİT değil bir SONUÇ: köprü
/// büyüdükçe canlı küme kendiliğinden büyür, kimse listeyi güncellemeyi
/// unutamaz. Elle yazılmış bir "canlı testler" listesi, köprü değişince
/// sessizce bayatlardı — `reps`/`aggregation` ailesinin (L-178/L-181) tam
/// aynı tuzağı.
List<TestLiveness> deriveLiveness(Battery battery) {
  final Set<String> bridged =
      kMetricBindings.map((MetricBinding b) => b.lissomMetric).toSet();
  final List<TestLiveness> out = <TestLiveness>[];

  for (final TestSpec t in battery.tests.values) {
    final List<String> sides =
        t.perSide ? <String>['right', 'left'] : <String>['right'];
    final List<String> metrics =
        sides.map(t.primaryMetricFor).toSet().toList()..sort();

    final List<String> missing =
        metrics.where((String m) => !bridged.contains(m)).toList();
    if (missing.isEmpty) {
      out.add(TestLiveness(testId: t.id, metrics: metrics, blocker: null));
      continue;
    }
    // Engel gerekçesi metriğin KENDİ blocker'ından gelir; "bir şeyler eksik"
    // değil, hangi kapı olduğu isimli (M-F-272 kapsam hükmü).
    final Set<String> reasons = <String>{
      for (final String m in missing) _blockerText(m),
    };
    out.add(TestLiveness(
      testId: t.id,
      metrics: metrics,
      blocker: reasons.join(' · '),
    ));
  }
  out.sort((TestLiveness a, TestLiveness b) => a.testId.compareTo(b.testId));
  return out;
}

/// Bir metriğin engel gerekçesi — kullanıcı diliyle, vaat İÇERMEDEN.
String _blockerText(String metric) {
  final BridgeBlocker? b = kUnbridgedMetrics[metric];
  return switch (b) {
    BridgeBlocker.coreLacksMeasureKind =>
      'bu ölçü tipi ölçüm çekirdeğinde henüz yok',
    // ⚠️ İlk yazımda "gövde açısı iki ayrı düzlemde ölçülemiyor" yazıyordu ve
    // SİM EKRANINDA yakalandı: `ankle_dorsiflexion` bu blocker'ı taşıyor ama
    // metriği `tibia_inclination` — kaval kemiği, GÖVDE DEĞİL. Yani kullanıcıya
    // yanlış anatomi söylüyordum. L-184/L-196'nın aynı sınıfı (kendinden emin
    // YANLIŞ GEREKÇE) ve bu kez ekran kanıtı yakaladı, test değil: dört metrik
    // aynı blocker'ı paylaşıyor (trunk_lean · trunk_lateral_tilt ·
    // tibia_inclination L/R), o yüzden metin İKİSİNİ de kapsayacak kadar genel
    // ama sebebi hâlâ İSİMLİ olmalı.
    BridgeBlocker.corePlaneSeparationMissing =>
      'bu açının gerektirdiği düzlem ayrımı ölçüm çekirdeğinde yok',
    // Beyan edilmemiş bir metrik: sessizce "engelli" saymak yerine
    // BİLİNMEDİĞİNİ söyler. `metric_coverage_test` bu durumu kırmızı yakar,
    // yani buraya düşmek zaten bir kapı ihlalidir.
    null => 'ölçüm köprüsü beyan edilmemiş ($metric)',
  };
}

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
///
/// ⛔ **Ürettiği sayı [kBridgeSpace] uzayındadır, normatif referans DEĞİL**
/// ([kBridgeIsReferenceEquivalent] `false`, ölçüm: L-031 raporu). Bu okuyucu
/// motoru uçtan uca koşturmak ve İSİMLİ sonuç üretmek için yeterlidir; bir
/// sayıyı kullanıcıya ROM ölçümü olarak SUNMAK için yeterli DEĞİLDİR.
final class CoreMetricReader {
  CoreMetricReader({
    required this.frameSize,
    List<JointSpec> specs = StandardJoints.fullBody,
    PoseNormalizer? normalizer,
  })  : _extractor = JointAngleExtractor(specs: specs),
        _normalizer = normalizer ?? PoseNormalizer(),
        _specs = specs;

  /// Kaynak karenin piksel boyutu — **ZORUNLU, ve bu bir katılık değil.**
  ///
  /// M-F-30 / J-028: MediaPipe `x`'i genişliğe, `y`'yi yüksekliğe bölüyor,
  /// yani ham normalize uzay ANİZOTROPİK ve orada ölçülen her açı en-boy
  /// oranıyla BÜKÜLÜYOR. Aile ölçümü: eklem açılarının %42'si >5° kayıyor,
  /// en kötü tek eklem 62°. Çekirdeğin kendi sözleşmesi bunu açıkça yazıyor:
  /// *"A consumer that has this must go through frameSize/toIsotropic before
  /// measuring."* Bu okuyucu o çağrıyı YAPMIYORDU — düzeltildi; alan
  /// opsiyonel bırakılırsa aynı sessiz bükülme geri gelir, o yüzden
  /// sözleşme TÜR düzeyinde tutuluyor (çekirdeğin tercih ettiği yol).
  ///
  /// ⚠️ Yeterli DEĞİL (M-O-08, ölçülmüş): izotropik düzeltme yalnız 2D
  /// izdüşümü onarır. Özne kameraya göre DÖNÜKKEN 3D eksen derinlikte
  /// kısalır ve düzlem-içi hiçbir ölçekleme onu geri getirmez — Lissom'un
  /// 12 testinden 8'i kullanıcıya *"yandan dur"* diyor, yani tam bu hâl.
  /// Kalan sapma L-031'in gerçek kapsamıdır ve `world` uzayı ister.
  final FrameSize frameSize;

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
    final JointAngleVector v = _extractor
        .extract(_normalizer.normalize(frame.toIsotropic(frameSize)));
    final double rad = v.values[idx];
    if (rad.isNaN) return null;
    return b.toLissomDegrees(rad);
  }
}
