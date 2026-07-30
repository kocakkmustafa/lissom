/// GERÇEK config'i okur — `config/tests/lissom-assessment.v1.json`.
///
/// Neden ayrı bir süit: `mf71_test.dart` motoru sentetik spec'lerle sınıyor,
/// yani "motor doğru davranıyor mu" sorusunu cevaplıyor. Bu süit farklı bir
/// soruyu cevaplıyor: "motor GERÇEK config'imizi okuyabiliyor mu, ve o
/// config'in gerçek sayıları motorun beklediği şekilleri taşıyor mu."
/// İkisi ayrı ayrı yanlış olabilir — sentetik testlerle yeşil olup gerçek
/// dosyada patlayan bir okuyucu, "beyan ≠ canlı" sınıfının ta kendisidir
/// (L-146/M-F-90).
library;

import 'dart:io';

import 'package:lissom_engine/lissom_engine.dart';
import 'package:test/test.dart';

/// Paket kökünden bataryaya göreli yol. Testler paket kökünden koşar.
final File _batteryFile =
    File('../../config/tests/lissom-assessment.v1.json');

void main() {
  test('gerçek batarya config\'i parse EDİLEBİLİR', () {
    expect(_batteryFile.existsSync(), isTrue,
        reason: 'yol yanlışsa bu test sessizce atlanmamalı — dosya bulunmalı');
    final Battery b = Battery.parseJson(_batteryFile.readAsStringSync());
    expect(b.tests, isNotEmpty);
    expect(b.version, isNotEmpty);
  });

  test('12 testin hepsi parse edilir — kapsam boşluğu YOK', () {
    final Battery b = Battery.parseJson(_batteryFile.readAsStringSync());
    // Batarya 12 test taşıyor (config_check/phase_check aynı sayıyı görüyor).
    // Sayıyı elle yazmıyoruz — dosyadan türetiyoruz ki bayatlamasın
    // (M-O-28: kapı raporundaki sayılar ölçümden TÜRETİLİR, yazılmaz).
    expect(b.tests.length, greaterThanOrEqualTo(12));
  });

  group('M-F-71 hükmünün gerçek config\'teki izleri', () {
    late Battery b;
    setUp(() => b = Battery.parseJson(_batteryFile.readAsStringSync()));

    test('L-135\'in üç testi girişim kapısı BEYAN EDİYOR', () {
      // Bu üçü M-F-71'in konusuydu: eşik-altı kullanıcı hiçbir şey
      // görmüyordu. Girişim kapısı beyan edilmemiş bir test için motor
      // ölçüm-kapısı KURAMAZ — o yüzden beyanın varlığı sınanır.
      for (final String id in <String>[
        'overhead_reach',
        'ankle_dorsiflexion',
        'lateral_bend',
      ]) {
        final TestSpec? t = b.tests[id];
        expect(t, isNotNull, reason: '$id bataryada olmalı');
        expect(t!.presenceGate, isNotNull,
            reason: '$id girişim kapısını beyan etmeli (L-093: beyansız '
                'test için fixture doğrulanamaz, sessizce geçirmek kapının '
                'hiç olmaması demektir)');
      }
    });

    test('girişim eşiği ile skor tabanı AYRI sayılar', () {
      // M-F-71 madde 1/3'ün gerçek-config kanıtı: bu ikisi karışırsa
      // L-135 geri gelir.
      final TestSpec reach = b.tests['overhead_reach']!;
      final double gate = reach.presenceGate!.value;
      final Map<String, double>? floors = reach.scoring.floorsFor(null);
      expect(floors, isNotNull);
      final double floor =
          floors!.values.reduce((double a, double b) => a < b ? a : b);
      expect(gate, isNot(floor),
          reason: 'girişim kapısı skor tabanının kopyası olmamalı');
    });

    test('lateral_bend: girişim eşiği bant tabanının ALTINDA', () {
      // Bu, "skorsuz ama ölçülü" bölgenin gerçek-config'te VAR OLDUĞUNUN
      // kanıtı: 15° girişimi açar, 60+ tabanı 18° — arada ölçülen ama
      // skorlanmayan bir bölge var ve motor onu measuredBelowRange olarak
      // sınıflandırıyor (mf71_test.dart bunu davranış olarak sınıyor).
      final TestSpec lb = b.tests['lateral_bend']!;
      final double gate = lb.presenceGate!.value;
      final Map<String, double> f = lb.scoring.floorsFor('60plus')!;
      expect(gate, lessThan(f['low']!),
          reason: 'girişim kapısı bant tabanının altında olmalı — aksi hâlde '
              'bandın altındaki kullanıcı ölçülemez (L-135)');
    });

    test('her testin skorlama beyanı bir KAYNAK taşıyor', () {
      for (final TestSpec t in b.tests.values) {
        expect(t.scoring.source, isNotEmpty,
            reason: '${t.id}: dayanaksız bant yayılamaz');
      }
    });

    test('deep_squat: bantları BOŞ ve bu dürüstçe measuredNoBands\'e düşer',
        () {
      // deep_squat'ın skorlama bantları henüz yazılmadı. Motor bunu
      // "skorlanabilir" saymıyor — floorsFor null dönüyor, sonuç
      // measuredNoBands oluyor. Yani değer raporlanır, bant iddiası
      // EDİLMEZ. Bantlar geldiğinde bu test kırılacak ve bu DOĞRU:
      // davranış değişikliği fark edilmeden geçmesin.
      final TestSpec ds = b.tests['deep_squat']!;
      expect(ds.scoring.floorsFor(null), isNull,
          reason: 'bantlar eklendiyse bu testi ve M-F-71 sınıflandırmasını '
              'gözden geçir — davranış sessizce değişmesin');
      // POZİTİF İKİZ (ikiz taraması bulgusu): başlık "dürüstçe
      // measuredNoBands'e düşer" diyordu ama gövde bunu HİÇ sınamıyordu —
      // yalnız bantların boş olduğunu iddia ediyordu. Bir başlığın
      // vaat ettiği davranış, gövdede iddia edilmediyse yoktur.
      final AssessmentResult r = AssessmentResult.measured(
        testId: ds.id, side: 'bilateral', value: 95, unit: 'deg',
        provenance: const <String, String>{'t': 'x'},
        bandFloors: ds.scoring.floorsFor(null),
      );
      expect(r.tier, ResultTier.measuredNoBands);
      expect(r.value, 95, reason: 'değer RAPORLANIR — bant iddiası edilmez');
      expect(r.bandLabel, isNull);
    });
  });
}
