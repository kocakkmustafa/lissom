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
  String primaryMetricFor(String side) =>
      primaryMetric.replaceAll('{side}', side).replaceAll(
          '{opposite}', side == 'right' ? 'left' : 'right');
}

final class Battery {
  const Battery({
    required this.id,
    required this.version,
    required this.tests,
  });

  final String id;
  final String version;
  final Map<String, TestSpec> tests;

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
    );
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

  static double _derivedHold(num? holdSeconds) {
    final double half = (holdSeconds?.toDouble() ?? 2) / 2;
    return half < 1.0 ? 1.0 : half;
  }
}
