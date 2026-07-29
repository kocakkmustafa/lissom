/// Blok-tabanlı değerlendirme oturumu — M-F-133 madde 3 hükmünün kod hâli.
///
/// Hükmün bağlayıcı kuralı: **bir blok TEK `calibrationProfile` içinde
/// tamamlanır** (biter ya da yeniden başlar). Bloklar arasında kamera
/// yeniden konumlanır ve yeni bir kalibrasyon alınır.
///
/// İkinci bağlayıcı kural, ve bu sınıfın var olma sebebi: **yarım kalan
/// oturumda tamamlanan blokların ölçümleri KORUNUR.** M-F-71 madde 2'nin
/// oturum düzeyindeki karşılığı — tamamlanmış bir ölçüm, oturum bitmediği
/// için atılamaz. Kullanıcıya "bitirmedin, hiçbir şey kaydedilmedi" demek
/// tam olarak L-135'in yasakladığı zarar sınıfı (emek harcadı, hiçbir şey
/// görmedi).
library;

import 'assessment_result.dart';

/// Bir bloğun tanımı (`config/tests/assessment-blocks.v1.json`).
final class AssessmentBlock {
  const AssessmentBlock({
    required this.id,
    required this.title,
    required this.cameraView,
    required this.bodyPosition,
    required this.setupNote,
    required this.testIds,
  });

  final String id;
  final String title;

  /// `sagittal` (yandan) | `frontal` (önden) — kalibrasyon profilinin bir
  /// parçası; iki farklı görüş AYNI blokta olamaz.
  final String cameraView;

  /// `standing` | `seated` | `floor`.
  final String bodyPosition;
  final String setupNote;

  /// Blok içindeki test sırası ANLAMLIDIR (yorgunluk sırası hükümden).
  final List<String> testIds;
}

/// Bir bloğun oturum içindeki durumu.
enum BlockState {
  /// Henüz başlanmadı.
  pending,

  /// Kalibrasyon alındı, testler koşuyor.
  active,

  /// Bloğun tüm testleri bir sonuç üretti (ölçüldü ya da isimli sebeple
  /// ölçülemedi — ikisi de "bitti"dir; M-F-71 madde 4).
  completed,

  /// Kalibrasyon bloğun ortasında bozuldu → blok YENİDEN BAŞLAR.
  /// Bloğun o ana kadarki sonuçları GEÇERSİZ (tek-kalibrasyon kuralı),
  /// ama ÖNCEKİ blokların sonuçları etkilenmez.
  invalidated,
}

/// Blok-tabanlı bir değerlendirme oturumu.
///
/// Motor değil, ORKESTRA: hangi testin sırası geldiğini, bir bloğun bitip
/// bitmediğini ve hangi ölçümlerin kalıcı olduğunu tutar. Tek bir testi
/// koşturmak `AssessmentEngine`'in işi.
final class AssessmentSession {
  AssessmentSession({required this.blocks})
      : assert(blocks.length > 0, 'oturum en az bir blok ister');

  final List<AssessmentBlock> blocks;

  final Map<String, BlockState> _state = <String, BlockState>{};
  final Map<String, Map<String, AssessmentResult>> _results =
      <String, Map<String, AssessmentResult>>{};
  final Map<String, String> _calibrationByBlock = <String, String>{};

  BlockState stateOf(String blockId) => _state[blockId] ?? BlockState.pending;

  /// Bir bloğa kalibrasyonla girer. Aynı bloğa yeniden girmek onu SIFIRLAR
  /// (yeniden-başlama yolu) — eski sonuçlar farklı bir kalibrasyona aitti
  /// ve karşılaştırma kümesine karışamaz.
  void beginBlock(String blockId, {required String calibrationProfile}) {
    final AssessmentBlock b = _block(blockId);
    if (_state[b.id] == BlockState.completed) {
      throw StateError(
        'tamamlanmış blok yeniden başlatılamaz: ${b.id} — tamamlanmış ölçüm '
        'atılmaz (M-F-71). Yeniden ölçüm YENİ bir oturumdur.',
      );
    }
    _state[b.id] = BlockState.active;
    _results[b.id] = <String, AssessmentResult>{};
    _calibrationByBlock[b.id] = calibrationProfile;
  }

  /// Bir testin sonucunu kaydeder.
  ///
  /// Sonuç, `AssessmentEngine.finish()`'in DÖNDÜĞÜ şeydir — ölçülmüş ya da
  /// isimli sebeple ölçülememiş. İkisi de kaydedilir: "ölçemedim" bir
  /// sonuçtur ve özette İSİMLE görünmelidir (PRD §5.2: tahmin edilmez,
  /// boş bırakılır — ama sebebi yazılır).
  void record(String blockId, AssessmentResult result) {
    final AssessmentBlock b = _block(blockId);
    if (_state[b.id] != BlockState.active) {
      throw StateError(
        'aktif olmayan bloğa sonuç yazılamaz: ${b.id} '
        '(durum: ${stateOf(b.id).name}) — kalibrasyon penceresi dışında '
        'alınan ölçüm hangi profile ait olduğunu söyleyemez',
      );
    }
    if (!b.testIds.contains(result.testId)) {
      throw ArgumentError(
        '${result.testId} ${b.id} bloğuna ait değil — yanlış bloğa yazılan '
        'ölçüm sessizce kayıp gider',
      );
    }
    _results[b.id]![result.testId] = result;
    if (_results[b.id]!.length == b.testIds.length) {
      _state[b.id] = BlockState.completed;
    }
  }

  /// Kalibrasyon blok ortasında bozuldu — blok geçersiz, öncekiler SAĞLAM.
  void invalidateBlock(String blockId) {
    final AssessmentBlock b = _block(blockId);
    if (_state[b.id] == BlockState.completed) {
      // Tamamlanmış blok geçersizleştirilemez: ölçümü zaten tek kalibrasyon
      // içinde bitti. Sonradan bozulan kalibrasyon onu geriye dönük
      // bozmaz — aksi hâlde "tamamlanmış ölçüm atılmaz" sözü tutulamaz.
      return;
    }
    _state[b.id] = BlockState.invalidated;
    _results[b.id] = <String, AssessmentResult>{};
  }

  /// Sıradaki test — blok içi sıra ANLAMLIDIR (yorgunluk düzeni).
  /// Aktif blok yoksa ya da blok bittiyse null.
  String? nextTestIn(String blockId) {
    final AssessmentBlock b = _block(blockId);
    if (_state[b.id] != BlockState.active) return null;
    final Map<String, AssessmentResult> done =
        _results[b.id] ?? const <String, AssessmentResult>{};
    for (final String id in b.testIds) {
      if (!done.containsKey(id)) return id;
    }
    return null;
  }

  /// Sıradaki başlanabilir blok (pending ya da invalidated), yoksa null.
  AssessmentBlock? get nextBlock {
    for (final AssessmentBlock b in blocks) {
      final BlockState s = stateOf(b.id);
      if (s == BlockState.pending || s == BlockState.invalidated) return b;
    }
    return null;
  }

  /// **KORUNAN ölçümler** — yarım kalan oturumun ürünü.
  ///
  /// Yalnız TAMAMLANMIŞ blokların sonuçları. Aktif bir bloğun yarısı
  /// KASITLI olarak dışarıda: o ölçümler tek-kalibrasyon penceresini
  /// kapatmadı, yani karşılaştırma kümesine giremezler. "Tamamlanmışı
  /// koru" sözü, "yarım olanı da say" demek DEĞİLDİR — ikisini karıştırmak
  /// kalibrasyon kuralını sessizce gevşetirdi.
  Map<String, AssessmentResult> get preservedResults {
    final Map<String, AssessmentResult> out = <String, AssessmentResult>{};
    for (final AssessmentBlock b in blocks) {
      if (stateOf(b.id) != BlockState.completed) continue;
      out.addAll(_results[b.id] ?? const <String, AssessmentResult>{});
    }
    return out;
  }

  /// Tamamlanmış bloğun kalibrasyon profili — köken alanı (L-022/M-F-07).
  String? calibrationOf(String blockId) => _calibrationByBlock[blockId];

  /// Oturum özeti: her blok kendi durumuyla, tamamlananların ölçüm sayısıyla.
  /// Sayılar TÜRETİLİR, yazılmaz (M-O-28).
  Map<String, dynamic> summary() => <String, dynamic>{
        'blocks': <Map<String, dynamic>>[
          for (final AssessmentBlock b in blocks)
            <String, dynamic>{
              'id': b.id,
              'state': stateOf(b.id).name,
              'tests': b.testIds.length,
              'recorded': (_results[b.id] ?? const <String, AssessmentResult>{})
                  .length,
              'calibrationProfile': _calibrationByBlock[b.id],
            },
        ],
        'preservedTests': preservedResults.length,
        'measuredTests': preservedResults.values
            .where((AssessmentResult r) => r.isMeasured)
            .length,
      };

  AssessmentBlock _block(String id) {
    for (final AssessmentBlock b in blocks) {
      if (b.id == id) return b;
    }
    throw ArgumentError('bilinmeyen blok: $id');
  }
}

/// Blok config okuyucusu + KAPSAMA doğrulayıcısı.
///
/// Doğrulama neden burada: bir testin hiçbir bloğa ait olmaması, o testin
/// oturumda sessizce HİÇ SORULMAMASI demektir — L-093'ün ("yazılı ama
/// uygulanmayan sınır, olmayan sınır kadar tehlikeli") oturum düzeyindeki
/// hâli. Bu yüzden eksik/çift kapsama SERT HATA.
final class BlockConfig {
  const BlockConfig({required this.version, required this.blocks});

  final String version;
  final List<AssessmentBlock> blocks;

  static BlockConfig parse(
    Map<String, dynamic> root, {
    required Set<String> batteryTestIds,
  }) {
    final Object? version = root['version'];
    if (version is! String) {
      throw ArgumentError('blocks config: `version` zorunlu');
    }
    final Object? raw = root['blocks'];
    if (raw is! List || raw.isEmpty) {
      throw ArgumentError('blocks config: boş olmayan `blocks` listesi zorunlu');
    }
    final List<AssessmentBlock> blocks = <AssessmentBlock>[];
    final Map<String, String> owner = <String, String>{};
    for (final Object? b in raw) {
      if (b is! Map<String, dynamic>) {
        throw ArgumentError('blocks[]: nesne olmalı');
      }
      final String id = b['id'] as String;
      final List<String> tests = <String>[
        for (final Object? t in (b['tests'] as List)) t as String,
      ];
      if (tests.isEmpty) {
        throw ArgumentError('$id: boş blok — test taşımayan blok anlamsız');
      }
      for (final String t in tests) {
        if (!batteryTestIds.contains(t)) {
          throw ArgumentError(
              '$id: bataryada olmayan test — $t (config\'ler ayrışmış)');
        }
        final String? prev = owner[t];
        if (prev != null) {
          throw ArgumentError(
              '$t iki bloğa ait: $prev ve $id — bir test tam bir bloğa aittir');
        }
        owner[t] = id;
      }
      blocks.add(AssessmentBlock(
        id: id,
        title: b['title'] as String? ?? id,
        cameraView: b['cameraView'] as String,
        bodyPosition: b['bodyPosition'] as String,
        setupNote: b['setupNote'] as String? ?? '',
        testIds: tests,
      ));
    }
    final Set<String> missing = batteryTestIds.difference(owner.keys.toSet());
    if (missing.isNotEmpty) {
      throw ArgumentError(
        'hiçbir bloğa ait OLMAYAN test(ler): ${missing.join(", ")} — '
        'bloğu olmayan test oturumda sessizce hiç sorulmaz (L-093)',
      );
    }
    return BlockConfig(version: version, blocks: blocks);
  }
}
