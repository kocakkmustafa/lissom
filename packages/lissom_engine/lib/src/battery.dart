/// Batarya config okuyucusu — `config/tests/lissom-assessment.v1.json`.
///
/// Motor hiçbir test adını, eşiği ya da bandı BİLMEZ; hepsi buradan gelir.
/// Okuyucu KATI: bilinmeyen alan sessizce yutulmaz (M-J-03 sınıfı — beklemediğini
/// atlayan okuyucu veriyi yok gibi gösterir ve yukarı akışta P0 üretir).
library;

import 'dart:convert';

final class BatteryError implements Exception {
  BatteryError(this.path, this.message);
  final String path;
  final String message;
  @override
  String toString() => 'BatteryError($path: $message)';
}

/// Ordinal bir seviyenin tanımı — `deep_squat` deseni.
///
/// Literatürde sürekli (derece cinsinden) norm YOKKEN dürüst seçenek budur:
/// sayısal bir bant uydurmak yerine betimsel kriterli seviyeler. Kriterler
/// bilerek AÇIK metin — özel bir protokolün (FMS) kopyası değil.
final class OrdinalLevel {
  const OrdinalLevel({
    required this.level,
    required this.label,
    required this.criteria,
  });
  final int level;
  final String label;
  final String criteria;
}

/// Bir testin REFERANS DURUMU — "ölçüm var, hüküm yok" beyanı (M-F-185).
///
/// Aile doktrini: bir test referanssız YAŞAYABİLİR, ama gerekçesi ÖLÇÜLMÜŞ
/// olmalı ve YÜZEYDE görünmeli. `measurementOnly` bir eksiklik itirafı
/// değil, bir dürüstlük beyanıdır — değeri gösteririz, hükmü vermeyiz
/// (M-F-71'in skorsuz-ama-ölçülü bölgesinin test düzeyindeki hâli).
final class ReferenceStatus {
  const ReferenceStatus({
    required this.state,
    required this.basisCode,
    required this.basisMeasured,
    required this.basisUserText,
    required this.unblockedBy,
    required this.criterion,
    required this.measuredGap,
  });

  /// `measurementOnly` — ölçüm raporlanır, referans/bant iddiası EDİLMEZ.
  final String state;

  /// Makine-okur gerekçe kodu (`variant-mismatch` · `count-gate` …).
  final String basisCode;

  /// ÖLÇÜLMÜŞ gerekçe — sayılarla, kayıt atıflı. Boş olamaz.
  final String basisMeasured;

  /// Aynı gerekçenin KULLANICI diliyle hâli. Yüzeyde bu görünür.
  final String basisUserText;

  /// TERFİ YOLU — neyin açacağı İSİMLİ (Choreia promotionPath deseni).
  /// "Bir gün belki" değil, adı olan bir iş.
  final String unblockedBy;
  final String criterion;
  final String measuredGap;

  bool get isMeasurementOnly => state == 'measurementOnly';
}

/// Bir testin skorlama beyanı.
final class ScoringSpec {
  const ScoringSpec({
    required this.type,
    required this.unit,
    required this.higherIsBetter,
    required this.bandFloorsByAge,
    required this.qualitativeLevels,
    required this.ordinalLevels,
    required this.source,
  });

  /// `banded` | `qualitative` | `ordinal`.
  ///
  /// Üç tip KASITLI olarak ayrıdır ve birbirinin yerine geçmez — her biri
  /// literatürün GERÇEKTEN söylediğine göre seçildi (config `_notes`):
  /// sayısal norm varsa `banded`, hiç yoksa `qualitative`, betimsel-kriterli
  /// seviye varsa `ordinal`. Norm yokken sayı uydurulmadı.
  final String type;
  final String? unit;
  final bool higherIsBetter;

  /// yaş bandı → (etiket → taban). Yalnız `banded` testlerde dolu.
  final Map<String, Map<String, double>> bandFloorsByAge;

  /// `qualitative` testlerin seviye adları.
  final List<String> qualitativeLevels;

  /// `ordinal` testlerin kriterli seviyeleri.
  final List<OrdinalLevel> ordinalLevels;

  /// Sayının nereden geldiği. Boş olamaz — dayanaksız bant yayılamaz
  /// (M-C-01 / kaynak-beyanı disiplini).
  final String source;

  bool get isBanded => type == 'banded';
  bool get isOrdinal => type == 'ordinal';

  /// Verilen yaş bandı için (etiket → taban) haritası; bant yoksa null.
  ///
  /// Yaş bandı verilmezse EN MUHAFAZAKÂR (tabanı en düşük) bant seçilir:
  /// yaş bilinmiyorken daha yüksek bir taban varsaymak, kullanıcıyı
  /// hak etmediği bir "yetersiz" hükmüne sokar.
  Map<String, double>? floorsFor(String? ageBand) {
    if (bandFloorsByAge.isEmpty) return null;
    if (ageBand != null) {
      final Map<String, double>? exact = bandFloorsByAge[ageBand];
      if (exact != null) return exact;
      throw BatteryError('scoring.bands', 'bilinmeyen yaş bandı: $ageBand '
          '(tanımlı: ${bandFloorsByAge.keys.join(", ")})');
    }
    Map<String, double>? best;
    double bestFloor = double.infinity;
    for (final Map<String, double> f in bandFloorsByAge.values) {
      final double floor = f.values.reduce((double a, double b) => a < b ? a : b);
      if (floor < bestFloor) {
        bestFloor = floor;
        best = f;
      }
    }
    return best;
  }
}

/// Hareket-varlığı beyanı — M-F-71 madde 1'in girişim kapısı.
final class PresenceGate {
  const PresenceGate({
    required this.metric,
    required this.op,
    required this.value,
    required this.minHoldS,
  });

  final String metric;

  /// `gte` | `lte`.
  final String op;
  final double value;
  final double minHoldS;

  bool holds(double v) => op == 'gte' ? v >= value : v <= value;
}

/// `{side}`/`{opposite}` yer tutucularını çözer — [TestSpec.primaryMetricFor]
/// ve [InvalidationRule] AYNI kaynağı kullanır (iki yerde iki farklı kural
/// riski, `requiredHoldS` dersiyle aynı sınıf).
String resolveSideToken(String metric, String side) => metric
    .replaceAll('{side}', side)
    .replaceAll('{opposite}', side == 'right' ? 'left' : 'right');

/// `invalidation.trigger.type`in İZİNLİ değerleri — koordinatör hükmüyle
/// SAYILI (icat edilmedi, üçü henüz UYGULANMADI). Yeni bir tür eklemek bir
/// isimlendirme kararı değil, bir ÖLÇÜM kararıdır — bkz. `InvalidationRule`.
enum InvalidationTriggerType {
  /// Yalnız TEPE değerin okunduğu karede ihlal varsa ateşler. Henüz
  /// UYGULANMADI.
  peakFrame,

  /// İhlal `ms` boyunca KESİNTİSİZ sürerse ateşler (girişim kapısının
  /// `requiredHoldS` deseniyle aynı aile). Henüz UYGULANMADI.
  sustained,

  /// İhlalli karelerin ORANI bir eşiği aşarsa ateşler (`lowConfidence`in
  /// `_lowConfidenceFrames * 2 > _totalFrames` deseniyle aynı aile). Henüz
  /// UYGULANMADI.
  ratio,

  /// Politika henüz ÖLÇÜLMEDİ. Motor bu kuralı GÖRÜNÜR biçimde atlar —
  /// sessizce değil (bkz. AssessmentEngine.process).
  unmeasured,
}

/// `trigger` alanının ayrıştırılmış hâli. `sustained`/`ratio` parametre
/// taşıyabilir (`ms`/`ratio`) — bugün hiçbir kural bu türleri kullanmadığı
/// için parametreler opsiyonel kaldı; ilk gerçek kullanım onları zorunlu
/// kılacak bir sonraki ölçüm turudur.
final class InvalidationTrigger {
  const InvalidationTrigger({required this.type, this.ms, this.ratio});

  final InvalidationTriggerType type;
  final double? ms;
  final double? ratio;
}

/// Bir ölçümü GEÇERSİZ kılan koşul (`invalidation`, A4 2026-08-11).
///
/// **Bu alanın iki gün okuyucusu yoktu.** `config/tests/lissom-assessment.v1
/// .json`'daki her testin `invalidation` dizisi (BENT_KNEE/OPPOSITE_LEG_
/// LIFTED mesajları dahil) `TestSpec`te alan olarak YOKTU — yazılmış içerik,
/// okuyan kod yoktu. Kamera kabuğu henüz bağlı olmadığı için (yayın engeli
/// #1) bu bugünkü SEVK EDİLEN hiçbir yüzeyi etkilemiyordu (latent, canlı
/// değil — ölçüldü, `docs/A1-A5-AILE-DENETIMI-2026-08-11.md`); kamera
/// bağlandığı gün ölçüm anında CANLI olurdu.
///
/// `confidence` metriği KASITLI OLARAK bağlanmadı: `motion_core`'un
/// `ConfidenceGate.landmarkThreshold` (0,5, [FrameQuality.meanVisibility])
/// zaten AYRI bir eşikle aynı işi yapıyor gibi görünüyor ama aynı büyüklük
/// olduğu ÖLÇÜLMEDİ — iki eşiği sessizce birleştirmek bir eşik icadı
/// olurdu. Bu yüzden `confidence` kuralları isimli boş bırakıldı (yokluk
/// kendi anlatısını taşır, sessizce puanlamaz) — bkz. `AssessmentEngine`.
///
/// ⚠️ **12 testin TAMAMI tarandıktan sonra ölçüldü, tek testten
/// genellenmedi (ilk sürümün hatası buydu):** kurallar İKİ AYRI biçimde —
/// `"metrik OP sayı"` (ör. `knee_flexion_{side} < 165`) VE çıplak bayrak
/// (`supportContact`, `footTouchdown` — `unit: bool`, `source: phase`,
/// operatörsüz). `op`/`value` bu yüzden OPSİYONEL: `op == null` yapısal
/// olarak sayısal-karşılaştırma OLMAYAN bir kuralı işaretler ([isEvaluable]
/// false döner) — ayrıştırma onu ATMAZ, sadece motora taşınamayacağını
/// beyan eder.
///
/// ## `trigger` — koordinatör hükmü (2026-08-11, 3. sevk)
///
/// "Herhangi bir karede ihlal → iptal" gerçek fixture'da yanlış-pozitif
/// üretti (bkz. AssessmentEngine yorumu). Doğru tetikleme politikası
/// (tepe-karesi mi, sürdürülmüş ihlal mi, hangi süre) ÖLÇÜLMEDİ ve
/// koordinatör KENDİSİ de icat etmedi: *"karar bende, ve kararım DEĞER
/// KOYMAMAK — mekanizmayı kuruyorum, sayıyı ölçüm verecek (kurucu kuyruğu:
/// cihaz turu)."* Bu yüzden `trigger` ZORUNLU alan — beyansız kural
/// KIRMIZI yanar (`_parseInvalidation`). Bugün her kural `unmeasured`
/// taşır; motor bunu GÖRÜNÜR biçimde atlar (bkz. AssessmentEngine).
final class InvalidationRule {
  const InvalidationRule({
    required this.metric,
    required this.op,
    required this.value,
    required this.code,
    required this.trigger,
    this.message,
  });

  /// `{side}`/`{opposite}` taşıyabilir. Özel değer `confidence` — bugün
  /// KASITLI olarak motor tarafından değerlendirilmiyor (yukarıdaki not).
  /// Sayısal-olmayan kurallarda bu, çıplak bayrak adının kendisidir
  /// (`supportContact`).
  final String metric;

  /// `<` | `>` | `<=` | `>=` — yapısal olarak ayrıştırılamadıysa `null`.
  final String? op;
  final double? value;

  /// Makine-okur kod (`BENT_KNEE` …) — [AssessmentResult.abortCode]'a gider.
  final String code;

  /// Bu kuralın NE ZAMAN ateşleyeceği — ZORUNLU, icat edilmedi (yukarıdaki
  /// not). `unmeasured` dışındaki üç tür bugün motor tarafından
  /// UYGULANMIYOR (henüz hiçbir kuralda kullanılmıyor); göründüklerinde
  /// `AssessmentEngine`e eklenecekler.
  final InvalidationTrigger trigger;

  /// Kullanıcı diliyle gerekçe. Opsiyonel — `LOW_CONFIDENCE` taşımıyor
  /// (config'te böyle yazılmış, burada UYDURULMADI).
  final String? message;

  bool get isConfidenceRule => metric == 'confidence';

  /// `op`/`value` ayrıştırılabildiyse true. Bayrak-biçimli kurallar
  /// (`supportContact`) ve `confidence` — false; motor bunları İSİMLE atlar.
  bool get isNumericComparison => op != null && value != null;

  bool violatedBy(double v) {
    assert(isNumericComparison,
        'yalnız sayısal karşılaştırma kuralları değerlendirilebilir — '
        'çağıran taraf isNumericComparison\'ı önce kontrol etmeli');
    return switch (op) {
      '<' => v < value!,
      '>' => v > value!,
      '<=' => v <= value!,
      '>=' => v >= value!,
      _ => throw StateError('bilinmeyen invalidation operatörü: $op'),
    };
  }
}

final class TestSpec {
  const TestSpec({
    required this.id,
    required this.name,
    required this.instruction,
    required this.perSide,
    required this.primaryMetric,
    required this.scoring,
    required this.presenceGate,
    required this.holdSeconds,
    required this.confidenceClass,
    this.referenceStatus,
    this.invalidation = const <InvalidationRule>[],
  });

  final String id;
  final String name;
  final String instruction;
  final bool perSide;

  /// `{side}` yer tutucusu TAŞIYABİLİR — motor tarafta çözülür (M-F-06:
  /// taraf geometrik kurulur, ham `LEFT_*`/`RIGHT_*` config'te yasak).
  final String primaryMetric;
  final ScoringSpec scoring;

  /// M-F-71 madde 1: girişim kapısı. Beyan edilmemişse null — o testte
  /// ölçüm-kapısı KURULAMAZ ve motor bunu isimle söyler (sessizce her şeyi
  /// geçirmek, kapının hiç olmaması demektir — L-093).
  final PresenceGate? presenceGate;

  final double? holdSeconds;
  final String confidenceClass;

  /// null = normal (referanslı/bantlı) test. Dolu = "ölçüm var, hüküm yok".
  final ReferenceStatus? referenceStatus;

  /// Bir ölçümü GEÇERSİZ kılan koşullar (A4 2026-08-11). Boş liste meşrudur
  /// — her testin form-hatası taşıması gerekmez.
  final List<InvalidationRule> invalidation;

  /// Girişim kapısı için gereken minimum tutuş (sn).
  ///
  /// `minHoldS` beyan edilmişse o; değilse testin kendi `holdSeconds`'inin
  /// yarısı, en az 1,0 sn — `tools/fixture_check.py`'nin türetme kuralıyla
  /// BİREBİR AYNI. İki yerde iki farklı kural, aynı soruya iki farklı cevap
  /// verirdi.
  double get requiredHoldS {
    final double? declared = presenceGate?.minHoldS;
    if (declared != null) return declared;
    final double half = (holdSeconds ?? 2) / 2;
    return half < 1.0 ? 1.0 : half;
  }

  /// `{side}` çözülmüş birincil metrik adı.
  String primaryMetricFor(String side) => resolveSideToken(primaryMetric, side);
}

/// Bataryaya KASITLI olarak alınmamış bir test — ve gerekçesi.
///
/// **Bu alanın iki yıl okuyucusu yoktu** (L-181 sınıfı: bilgi taşıyan config
/// alanı süs olarak bırakılmış). Sonuç: iki test ÖLÇÜLDÜ, gerekçeleriyle
/// birlikte dışarıda bırakıldı ve kullanıcı bunu HİÇ ÖĞRENEMEDİ —
/// `cervical_rotation` hiçbir yüzeyde geçmiyordu. Oysa "neyi ölçmediğimizi
/// söylemek" bu ürünün konumlandırmasının kendisi.
final class ExcludedTest {
  const ExcludedTest({
    required this.id,
    required this.reason,
    required this.whyNotTopic,
    required this.record,
  });

  final String id;

  /// ÖLÇÜLMÜŞ gerekçe, kullanıcı diliyle. Boş olamaz.
  ///
  /// ⚠️ **DEFTER ATFI BU ALANDA DEĞİL, [record]'da yaşar (L-223).** Metin
  /// eskiden `… stand behind. (L-006)` diye bitiyordu ve o parantez SİMÜLATÖR
  /// EKRANINDA görüldü: `(L-006)` bir iç-defter numarası, kullanıcı için
  /// anlamsız bir şifre. Ham metrik-id sızıntısıyla aynı sınıf — dahili
  /// sözlüğün yüzeye düşmesi — ve yine ekran yakaladı, test değil.
  final String reason;

  /// İç defter atfı (`L-006`). **Yüzeye BASILMAZ**; kaydın izlenebilirliği
  /// için config'te durur.
  final String? record;

  /// Bu dışlamanın ürün-düzeyi karşılığı (`whyNotPage.items[].topic`), varsa.
  ///
  /// Dolu olduğunda yüzey iki kaydı BİRLEŞTİRİR: ürün sınırı üstte, ölçülmüş
  /// gerekçe altında. Dolu değilse dışlama KENDİ satırını alır — sessizce
  /// kaybolmaz. Eşleştirme metin karşılaştırmasıyla TAHMİN EDİLMEZ; config
  /// bunu BEYAN eder, çünkü tahmini bir eşleşme bir gün sessizce kayar.
  final String? whyNotTopic;
}

/// Geometriden DEĞİL, oturumun kendisinden gelen bir büyüklük.
///
/// Config `derivedMeasures` bloğunda `source: "phase"` diye beyan ediyor:
/// *"Produced by the phase machine, not from landmark geometry."*
///
/// **Bu bloğun da okuyucusu yoktu (L-220) ve bedeli ekranda görüldü.**
/// `hold_duration` iki testin (`plank_hold`, `single_leg_balance`) birincil
/// büyüklüğü; köprü onu tanımadığı için ikisi de kullanıcıya
/// *"measurement bridge not declared (hold_duration)"* diyordu — hem
/// geliştirici jargonu hem HAM METRİK ID'si, ikisi de yüzeye sızmaması
/// gereken şeyler. Üstelik kapsam kapısı bunu göremiyordu: kapı gereken
/// metrikleri `known` kümesine göre SÜZÜYOR ve `hold_duration` o kümede
/// olmadığı için sessizce eleniyordu — yokluk iddiasını vakum-doğru yapan
/// bir süzgeç (aile dersi 4).
final class DerivedMeasure {
  const DerivedMeasure({
    required this.id,
    required this.unit,
    required this.source,
    required this.description,
  });

  final String id;
  final String unit;

  /// `phase` (oturum makinesi) · `frame` (kare-düzeyi sinyal).
  final String source;
  final String description;

  bool get isPhaseDerived => source == 'phase';
}

final class Battery {
  const Battery({
    required this.id,
    required this.version,
    required this.tests,
    required this.excluded,
    required this.derivedMeasures,
    this.cameraSetup,
  });

  final String id;
  final String version;
  final Map<String, TestSpec> tests;

  /// **KAMERA KURULUMU — config'te vardı, HİÇ ayrıştırılmıyordu (L-330).**
  ///
  /// `globalCameraSetup` bloğu mesafe/yükseklik aralığını, kadraj kuralını ve
  /// yaw toleransını taşıyor — yani *"telefonu nereye koyayım"* sorusunun
  /// cevabı **yazılıydı** ve ne ayrıştırıcısı ne okuyucusu vardı.
  /// `H-24`'ün ikinci sorusunun bu hattaki cevabı: *eksik olan içerik değil,
  /// KÖPRÜYDÜ* — ve bu kez köprünün **ayrıştırıcı yarısı da** yoktu.
  ///
  /// ⛔ Yokluğu HATA değil: eski config'ler bloğu taşımayabilir ⇒ `null`.
  /// Yüzey `null`da hiçbir şey çizmez (uydurma kurulum tarifi vermez).
  final CameraSetup? cameraSetup;

  /// Bataryaya alınmamış testler — İSİMLİ gerekçeleriyle.
  final List<ExcludedTest> excluded;

  /// Geometri-dışı büyüklükler (faz makinesi / kare sinyali).
  final Map<String, DerivedMeasure> derivedMeasures;

  static Battery parseJson(String source) =>
      parse(jsonDecode(source) as Map<String, dynamic>);

  static Battery parse(Map<String, dynamic> root) {
    final Object? version = root['version'];
    if (version is! String) {
      throw BatteryError('version', 'sürüm beyan edilmemiş — sürümsüz config '
          'sessizce yorumlanır ve uyumsuzluk fark edilmeden davranış değiştirir');
    }
    final Object? rawTests = root['tests'];
    if (rawTests is! List) {
      throw BatteryError('tests', 'liste olmalı');
    }
    final Map<String, TestSpec> tests = <String, TestSpec>{};
    for (int i = 0; i < rawTests.length; i++) {
      final Object? raw = rawTests[i];
      if (raw is! Map<String, dynamic>) {
        throw BatteryError('tests[$i]', 'nesne olmalı');
      }
      final TestSpec spec = _parseTest(raw, 'tests[$i]');
      tests[spec.id] = spec;
    }
    return Battery(
      id: root['id'] as String? ?? 'lissom.assessment.battery',
      version: version,
      tests: tests,
      excluded: _parseExcluded(root['excluded']),
      derivedMeasures: _parseDerived(root['derivedMeasures']),
      cameraSetup: CameraSetup.parse(root['globalCameraSetup']),
    );
  }

  static Map<String, DerivedMeasure> _parseDerived(Object? raw) {
    if (raw == null) return const <String, DerivedMeasure>{};
    if (raw is! Map<String, dynamic>) {
      throw BatteryError('derivedMeasures', 'nesne olmalı');
    }
    final Map<String, DerivedMeasure> out = <String, DerivedMeasure>{};
    for (final MapEntry<String, dynamic> e in raw.entries) {
      final Object? v = e.value;
      if (v is! Map<String, dynamic>) {
        throw BatteryError('derivedMeasures.${e.key}', 'nesne olmalı');
      }
      final Object? source = v['source'];
      final Object? unit = v['unit'];
      final Object? desc = v['description'];
      if (source is! String || unit is! String || desc is! String) {
        throw BatteryError('derivedMeasures.${e.key}',
            '`unit`, `source` ve `description` zorunlu — kaynağı beyan '
            'edilmemiş bir büyüklük, nereden geldiği bilinmeyen bir sayıdır');
      }
      out[e.key] = DerivedMeasure(
          id: e.key, unit: unit, source: source, description: desc);
    }
    return out;
  }

  /// `excluded` YOKSA boş liste meşrudur (bir batarya hiçbir şeyi dışlamamış
  /// olabilir); ama VARSA katı okunur — gerekçesiz bir dışlama, "bir şey
  /// eksik ama nedenini söylemiyoruz" demektir ve bu ürünün reddettiği tek
  /// şeydir.
  static List<ExcludedTest> _parseExcluded(Object? raw) {
    if (raw == null) return const <ExcludedTest>[];
    if (raw is! List) throw BatteryError('excluded', 'liste olmalı');
    final List<ExcludedTest> out = <ExcludedTest>[];
    for (int i = 0; i < raw.length; i++) {
      final Object? e = raw[i];
      if (e is! Map<String, dynamic>) {
        throw BatteryError('excluded[$i]', 'nesne olmalı');
      }
      final Object? id = e['id'];
      final Object? reason = e['reason'];
      if (id is! String || id.trim().isEmpty) {
        throw BatteryError('excluded[$i].id', 'zorunlu');
      }
      if (reason is! String || reason.trim().isEmpty) {
        throw BatteryError('excluded[$i].reason',
            'zorunlu — gerekçesiz dışlama, sebebini saklayan bir eksikliktir');
      }
      out.add(ExcludedTest(
        id: id,
        reason: reason,
        whyNotTopic: e['whyNotTopic'] as String?,
        record: e['record'] as String?,
      ));
    }
    return out;
  }

  static TestSpec _parseTest(Map<String, dynamic> raw, String path) {
    final Object? id = raw['id'];
    if (id is! String) throw BatteryError(path, '`id` zorunlu');

    final Object? rawScoring = raw['scoring'];
    if (rawScoring is! Map<String, dynamic>) {
      throw BatteryError('$path.scoring', 'zorunlu nesne');
    }
    final String type = rawScoring['type'] as String? ?? '';
    if (type != 'banded' && type != 'qualitative' && type != 'ordinal') {
      throw BatteryError('$path.scoring.type',
          'banded|qualitative|ordinal olmalı, verilen: $type');
    }
    final String? source = rawScoring['source'] as String?;
    if (source == null || source.isEmpty) {
      throw BatteryError('$path.scoring.source',
          'sayının nereden geldiği beyan edilmeli — dayanaksız bant yayılamaz');
    }
    final Map<String, Map<String, double>> floors =
        <String, Map<String, double>>{};
    final Object? bands = rawScoring['bands'];
    if (bands is Map<String, dynamic>) {
      for (final MapEntry<String, dynamic> age in bands.entries) {
        final Object? levels = age.value;
        if (levels is! Map<String, dynamic>) {
          throw BatteryError('$path.scoring.bands.${age.key}', 'nesne olmalı');
        }
        floors[age.key] = <String, double>{
          for (final MapEntry<String, dynamic> l in levels.entries)
            l.key: (l.value as num).toDouble(),
        };
      }
    }
    // `banded` ama bantları boş bir test: HATA DEĞİL, ama sessizce
    // "skorlanabilir" de sayılmaz — `floorsFor` null döner ve sonuç
    // `measuredNoBands` olur (değer raporlanır, bant iddiası EDİLMEZ).

    // Ordinal seviyeler: `deep_squat` deseni (sürekli norm yok, betimsel
    // kriterli seviye var). `qualitative`'in düz string listesinden AYRI
    // ayrıştırılır çünkü şekilleri farklı ve birini diğeri sanmak
    // sessizce boş bir liste üretirdi.
    final List<OrdinalLevel> ordinals = <OrdinalLevel>[];
    if (type == 'ordinal') {
      final Object? raw = rawScoring['levels'];
      if (raw is! List || raw.isEmpty) {
        throw BatteryError('$path.scoring.levels',
            'ordinal skorlama kriterli seviye listesi ister');
      }
      for (int i = 0; i < raw.length; i++) {
        final Object? l = raw[i];
        if (l is! Map<String, dynamic>) {
          throw BatteryError('$path.scoring.levels[$i]',
              'ordinal seviye nesne olmalı ({level, label, criteria})');
        }
        final Object? level = l['level'];
        final Object? label = l['label'];
        final Object? criteria = l['criteria'];
        if (level is! num || label is! String || criteria is! String) {
          throw BatteryError('$path.scoring.levels[$i]',
              '`level`, `label` ve `criteria` zorunlu — kriteri olmayan bir '
              'seviye kullanıcıya neden o seviyede olduğunu söyleyemez');
        }
        ordinals.add(OrdinalLevel(
          level: level.toInt(),
          label: label,
          criteria: criteria,
        ));
      }
    }

    PresenceGate? gate;
    final Object? mp = raw['movementPresence'];
    if (mp is Map<String, dynamic>) {
      final Object? metric = mp['metric'];
      final Object? op = mp['op'];
      final Object? value = mp['value'];
      if (metric is! String || op is! String || value is! num) {
        throw BatteryError('$path.movementPresence',
            '`metric`, `op` (gte|lte) ve `value` zorunlu');
      }
      if (op != 'gte' && op != 'lte') {
        throw BatteryError('$path.movementPresence.op',
            'gte|lte olmalı, verilen: $op');
      }
      gate = PresenceGate(
        metric: metric,
        op: op,
        value: value.toDouble(),
        // minHoldS opsiyonel; yokluğu `TestSpec.requiredHoldS`'te türetilir.
        minHoldS: (mp['minHoldS'] as num?)?.toDouble() ??
            _derivedHold(raw['holdSeconds'] as num?),
      );
    }

    return TestSpec(
      id: id,
      name: raw['name'] as String? ?? id,
      instruction: raw['instruction'] as String? ?? '',
      perSide: raw['perSide'] as bool? ?? false,
      primaryMetric: raw['primaryMetric'] as String? ??
          (throw BatteryError('$path.primaryMetric', 'zorunlu')),
      invalidation: _parseInvalidation(raw['invalidation'], path),
      scoring: ScoringSpec(
        type: type,
        unit: rawScoring['unit'] as String?,
        // ⚠️ VARSAYILAN YOK — ve bu bir katılık gösterisi değil, ölçülmüş bir
        // kusurun panzehiri. Eskiden `?? true` idi; motor bu alanla tepe
        // yönünü seçiyor (`higherIsBetter ? v > peak : v < peak`), yani
        // alanın SESSİZ varsayılanı üç testte ölçümü TERS yönde topluyordu
        // (deep_squat, forward_lunge, thoracic_rotation — L-181). Bir yön
        // alanının güvenli varsayılanı OLAMAZ: "büyük olan iyidir" bir
        // iddiadır ve beyan edilmediği yerde iddia edilmemelidir.
        higherIsBetter: rawScoring['higherIsBetter'] as bool? ??
            (throw BatteryError('$path.scoring.higherIsBetter',
                'zorunlu — yön beyan edilmeden ölçüm hangi uca doğru '
                'toplanacağını bilemez; sessiz varsayılan ölçümü ters '
                'çevirir (L-181)')),
        bandFloorsByAge: floors,
        qualitativeLevels: <String>[
          if (type == 'qualitative')
            for (final Object? l in (rawScoring['levels'] as List? ?? const []))
              l as String,
        ],
        ordinalLevels: ordinals,
        source: source,
      ),
      presenceGate: gate,
      holdSeconds: (raw['holdSeconds'] as num?)?.toDouble(),
      confidenceClass: raw['confidenceClass'] as String? ?? 'C',
      referenceStatus: _parseRefStatus(raw['referenceStatus'], path),
    );
  }

  /// `referenceStatus` KATI okunur: beyan varsa EKSİKSİZ olmalı.
  /// Yarım bir beyan, gerekçesiz bir "measurementOnly" üretir — yani
  /// kullanıcıya sebebini söylemeyen bir eksiklik (L-135 sınıfı).
  static ReferenceStatus? _parseRefStatus(Object? raw, String path) {
    if (raw == null) return null;
    if (raw is! Map<String, dynamic>) {
      throw BatteryError('$path.referenceStatus', 'nesne olmalı');
    }
    final Object? basis = raw['statusBasis'];
    final Object? promo = raw['promotionPath'];
    if (basis is! Map<String, dynamic> || promo is! Map<String, dynamic>) {
      throw BatteryError('$path.referenceStatus',
          '`statusBasis` ve `promotionPath` ZORUNLU — gerekçesiz bir '
          'measurementOnly, sebebini söylemeyen bir eksikliktir');
    }
    for (final (Map<String, dynamic> m, String k, String where) in <
        (Map<String, dynamic>, String, String)>[
      (basis, 'code', 'statusBasis'),
      (basis, 'measured', 'statusBasis'),
      (basis, 'userText', 'statusBasis'),
      (promo, 'unblockedBy', 'promotionPath'),
      (promo, 'criterion', 'promotionPath'),
      (promo, 'measuredGap', 'promotionPath'),
    ]) {
      final Object? v = m[k];
      if (v is! String || v.trim().isEmpty) {
        throw BatteryError('$path.referenceStatus.$where.$k',
            'zorunlu ve boş olamaz');
      }
    }
    return ReferenceStatus(
      state: raw['state'] as String? ?? 'measurementOnly',
      basisCode: basis['code'] as String,
      basisMeasured: basis['measured'] as String,
      basisUserText: basis['userText'] as String,
      unblockedBy: promo['unblockedBy'] as String,
      criterion: promo['criterion'] as String,
      measuredGap: promo['measuredGap'] as String,
    );
  }

  /// `invalidation` YOKSA boş liste meşrudur. VARSA katı okunur: `rule` +
  /// `code` + `trigger` zorunlu, `message` opsiyonel (config'te
  /// `LOW_CONFIDENCE` mesajsız — burada UYDURULMUYOR, `null` kalıyor).
  ///
  /// `trigger` zorunluluğu koordinatör hükmü (2026-08-11, 3. sevk):
  /// tetikleme politikası HENÜZ ölçülmedi, ama "beyan edilmedi" diye
  /// sessizce geçmek de olmaz — her kural NE ZAMAN ateşleyeceğini adıyla
  /// söylemek ZORUNDA, cevap `unmeasured` olsa bile.
  static List<InvalidationRule> _parseInvalidation(Object? raw, String path) {
    if (raw == null) return const <InvalidationRule>[];
    if (raw is! List) throw BatteryError('$path.invalidation', 'liste olmalı');
    final List<InvalidationRule> out = <InvalidationRule>[];
    for (int i = 0; i < raw.length; i++) {
      final Object? e = raw[i];
      if (e is! Map<String, dynamic>) {
        throw BatteryError('$path.invalidation[$i]', 'nesne olmalı');
      }
      final Object? rule = e['rule'];
      final Object? code = e['code'];
      if (rule is! String || rule.trim().isEmpty) {
        throw BatteryError('$path.invalidation[$i].rule', 'zorunlu');
      }
      if (code is! String || code.trim().isEmpty) {
        throw BatteryError('$path.invalidation[$i].code', 'zorunlu — kodsuz '
            'bir geçersiz kılma, kullanıcıya İSİMLİ bir sebep veremez');
      }
      final InvalidationTrigger trigger =
          _parseTrigger(e['trigger'], '$path.invalidation[$i]');
      out.add(_parseRule(
          rule, code, e['message'] as String?, trigger, '$path.invalidation[$i]'));
    }
    return out;
  }

  static InvalidationTrigger _parseTrigger(Object? raw, String path) {
    if (raw is! Map<String, dynamic>) {
      throw BatteryError('$path.trigger',
          'ZORUNLU — tetikleme politikası ölçülmemişse bile `{"type": '
          '"unmeasured"}` yazılmalı; beyansız bir kural sessizce '
          'geçemez (koordinatör hükmü, 2026-08-11)');
    }
    final Object? type = raw['type'];
    if (type is! String) {
      throw BatteryError('$path.trigger.type', 'zorunlu');
    }
    InvalidationTriggerType? parsed;
    for (final InvalidationTriggerType t in InvalidationTriggerType.values) {
      if (t.name == type) {
        parsed = t;
        break;
      }
    }
    if (parsed == null) {
      throw BatteryError('$path.trigger.type',
          'bilinmeyen tür: "$type" — izinli: '
          '${InvalidationTriggerType.values.map((InvalidationTriggerType t) => t.name).join(", ")}');
    }
    return InvalidationTrigger(
      type: parsed,
      ms: (raw['ms'] as num?)?.toDouble(),
      ratio: (raw['ratio'] as num?)?.toDouble(),
    );
  }

  /// `"knee_flexion_{side} < 165"` biçimini ayrıştırır. Tam ifade
  /// değerlendiricisi YAZILMADI — 12 testin tamamı tarandı ve iki biçim
  /// çıktı: `metrik OP sayı` VE çıplak bayrak (`supportContact`). Üçüncü
  /// bir biçim ÖLÇÜLMEDİ; genişletilmiş bir grameri şimdiden inşa etmek
  /// `PresenceGate`'in kaçındığı aynı riski taşırdı (kullanılmayan
  /// esneklik, sınanmamış dal).
  static final RegExp _rulePattern =
      RegExp(r'^(\S+)\s*(<=|>=|<|>)\s*(-?[\d.]+)$');

  /// Çıplak tanımlayıcı (`supportContact`, `footTouchdown`) — `unit: bool`,
  /// `source: phase` metriklerin config'teki hâli. Motor bunları bugün
  /// DEĞERLENDİREMEZ (faz-makinesi durumu, kare-geometrisi değil); ayrıştırma
  /// yine de kabul eder — `InvalidationRule.isNumericComparison == false`.
  static final RegExp _flagPattern = RegExp(r'^[A-Za-z_][A-Za-z0-9_]*$');

  static InvalidationRule _parseRule(String rule, String code, String? message,
      InvalidationTrigger trigger, String path) {
    final String trimmed = rule.trim();
    final RegExpMatch? m = _rulePattern.firstMatch(trimmed);
    if (m != null) {
      return InvalidationRule(
        metric: m.group(1)!,
        op: m.group(2)!,
        value: double.parse(m.group(3)!),
        code: code,
        trigger: trigger,
        message: message,
      );
    }
    if (_flagPattern.hasMatch(trimmed)) {
      return InvalidationRule(
          metric: trimmed,
          op: null,
          value: null,
          code: code,
          trigger: trigger,
          message: message);
    }
    throw BatteryError('$path.rule',
        'ayrıştırılamadı: "$rule" — beklenen "metrik OP sayı" (OP: <, >, '
        '<=, >=) ya da çıplak bayrak adı');
  }

  static double _derivedHold(num? holdSeconds) {
    final double half = (holdSeconds?.toDouble() ?? 2) / 2;
    return half < 1.0 ? 1.0 : half;
  }
}

/// Kameranın nereye konacağı — **config'ten, uydurulmadan** (L-330).
///
/// Bu blok `config/tests/lissom-assessment.v1.json` içinde duruyordu ve
/// **hiçbir ayrıştırıcısı yoktu**; yani kullanıcı ölçüme başlarken telefonu
/// nereye koyacağını bilmiyordu, ama ölçüm sonradan *"kadraj yüzünden
/// okunamadı"* diyebiliyordu.
/// > ***BİR ÜRÜN, BAŞARISIZLIĞIN SEBEBİNİ SONRADAN SÖYLEYEBİLİYORSA, ONU
/// > ÖNCEDEN DE SÖYLEYEBİLİR.***
final class CameraSetup {
  const CameraSetup({
    required this.distanceCm,
    required this.heightCm,
    required this.framingRule,
    required this.yawToleranceDeg,
  });

  /// `[min, max]` — santimetre. Boşsa `null`.
  final List<int>? distanceCm;
  final List<int>? heightCm;
  final String? framingRule;
  final num? yawToleranceDeg;

  /// Hiçbir alan yoksa `null` döner — **boş bir kurulum kartı çizmemek için.**
  /// (Bu gecenin A3 dersi: karşılıksız başlık, yokluktan kötüdür.)
  static CameraSetup? parse(Object? raw) {
    if (raw is! Map<String, dynamic>) return null;
    final List<int>? d = _ints(raw['distanceCm']);
    final List<int>? h = _ints(raw['heightCm']);
    final Object? fr = raw['framingRule'];
    final Object? yaw = raw['yawToleranceDeg'];
    final CameraSetup s = CameraSetup(
      distanceCm: d,
      heightCm: h,
      framingRule: fr is String && fr.trim().isNotEmpty ? fr : null,
      yawToleranceDeg: yaw is num ? yaw : null,
    );
    return s.isEmpty ? null : s;
  }

  bool get isEmpty =>
      distanceCm == null &&
      heightCm == null &&
      framingRule == null &&
      yawToleranceDeg == null;

  /// ⛔ Tek elemanlı ya da bozuk aralık KABUL EDİLMEZ: *"180 cm ile 180 cm
  /// arası"* diye bir tarif yoktur, ve eksik bir aralığı tamamlamak
  /// uydurmaktır.
  static List<int>? _ints(Object? v) {
    if (v is! List || v.length != 2) return null;
    final List<int> out = <int>[];
    for (final Object? x in v) {
      if (x is! num) return null;
      out.add(x.toInt());
    }
    return out[0] <= out[1] ? out : null;
  }
}
