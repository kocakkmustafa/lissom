/// A5 batarya özeti — statü-örgüsünün YÜZEY tarafındaki kanıtı.
library;

import 'dart:convert';
import 'dart:io';

import 'package:lissom_engine/lissom_engine.dart';
import 'package:test/test.dart';

final File _batteryFile = File('../../config/tests/lissom-assessment.v1.json');
final File _blocksFile = File('../../config/tests/assessment-blocks.v1.json');
Battery _b() => Battery.parseJson(_batteryFile.readAsStringSync());

AssessmentResult _measured(String id, double v,
        {Map<String, double>? bands, String? lesson}) =>
    AssessmentResult.measured(
      testId: id, side: 'right', value: v, unit: 'deg',
      provenance: const <String, String>{'t': 'x'},
      bandFloors: bands, lessonClass: lesson,
    );

void main() {
  group('statü-örgüsü YÜZEYDE ayrışıyor', () {
    test('measurementOnly satırı valueNotCompared olur, bant TAŞIMAZ', () {
      final Battery b = _b();
      final BatterySummary s = BatterySummary.from(
        battery: b,
        results: <String, AssessmentResult>{
          'overhead_reach': _measured('overhead_reach', 150,
              bands: <String, double>{'low': 130}, lesson: 'measurementOnly'),
        },
      );
      final SummaryRow r = s.rows.single;
      expect(r.presentation, SummaryPresentation.valueNotCompared);
      expect(r.value, 150, reason: 'ölçüm görünür — çalışıyor');
      expect(r.bandLabel, isNull,
          reason: 'referansa kıyaslanmamış ölçüme bant adı verilemez');
      expect(r.userNote, isNotNull, reason: 'gerekçe config\'ten gelmeli');
      expect(r.promotionNote, isNotNull, reason: 'terfi yolu görünür olmalı');
      expect(s.notComparedCount, 1);
    });

    test('M-F-186: hiçbir ölçüm satırı "yakında" olarak sunulamaz', () {
      final Battery b = _b();
      final BatterySummary s = BatterySummary.from(
        battery: b,
        results: <String, AssessmentResult>{
          'overhead_reach': _measured('overhead_reach', 150,
              lesson: 'measurementOnly'),
          'lateral_bend': _measured('lateral_bend', 30,
              bands: <String, double>{'low': 18}),
        },
      );
      for (final SummaryRow r in s.rows) {
        expect(r.mayShowAsComingSoon, isFalse,
            reason: 'comingSoon ÖLÇÜMÜN YOKLUĞUDUR; ölçüm varken '
                'kullanılamaz (M-F-186)');
      }
    });

    test('normal test bant etiketi TAŞIR (kıyas gerçekten yapıldı)', () {
      final BatterySummary s = BatterySummary.from(
        battery: _b(),
        results: <String, AssessmentResult>{
          'lateral_bend': _measured('lateral_bend', 30,
              bands: <String, double>{'low': 18, 'normal': 26}),
        },
      );
      expect(s.rows.single.presentation, SummaryPresentation.scoredWithBand);
      expect(s.rows.single.bandLabel, isNotNull);
    });

    test('bandın altı: değer VAR, bant YOK, taban TAŞINMIYOR', () {
      final BatterySummary s = BatterySummary.from(
        battery: _b(),
        results: <String, AssessmentResult>{
          'lateral_bend':
              _measured('lateral_bend', 10, bands: <String, double>{'low': 18}),
        },
      );
      final SummaryRow r = s.rows.single;
      expect(r.presentation, SummaryPresentation.valueBelowRange);
      expect(r.value, 10);
      expect(r.bandLabel, isNull);
      // §5.1: taban dolum-çubuğu olmasın diye satıra HİÇ konmuyor.
      expect(r.userNote, isNull);
    });

    test('ölçülemeyen satır sebebini İSİMLE taşır', () {
      final BatterySummary s = BatterySummary.from(
        battery: _b(),
        results: <String, AssessmentResult>{
          'lateral_bend': AssessmentResult.notMeasured(
            testId: 'lateral_bend', side: 'right',
            code: ResultCode.trackingLost,
            provenance: const <String, String>{'t': 'x'},
          ),
        },
      );
      expect(s.rows.single.presentation,
          SummaryPresentation.notMeasuredWithReason);
      expect(s.rows.single.reasonCode, 'trackingLost');
      expect(s.notMeasuredCount, 1);
      expect(s.measuredCount, 0);
    });
  });

  group('bütünlük kuralları', () {
    test('bataryada olmayan sonuç SERT HATA', () {
      expect(
          () => BatterySummary.from(
                battery: _b(),
                results: <String, AssessmentResult>{
                  'ghost': _measured('ghost', 1),
                },
              ),
          throwsA(isA<ArgumentError>()));
    });

    test('koşulmayan test satır ÜRETMEZ ("hiç koşulmadı" ≠ "ölçülemedi")', () {
      final BatterySummary s = BatterySummary.from(
        battery: _b(),
        results: <String, AssessmentResult>{
          'lateral_bend': _measured('lateral_bend', 30),
        },
      );
      expect(s.rows.length, 1,
          reason: '12 testin 11\'i koşulmadı — satır uydurulmaz');
    });

    test('sayılar TÜRETİLİR (M-O-28)', () {
      final BatterySummary s = BatterySummary.from(
        battery: _b(),
        results: <String, AssessmentResult>{
          'overhead_reach':
              _measured('overhead_reach', 150, lesson: 'measurementOnly'),
          'lateral_bend': _measured('lateral_bend', 30),
          'thoracic_rotation': AssessmentResult.notMeasured(
            testId: 'thoracic_rotation', side: 'right',
            code: ResultCode.lowConfidence,
            provenance: const <String, String>{'t': 'x'},
          ),
        },
      );
      expect(s.rows.length, 3);
      expect(s.measuredCount, 2);
      expect(s.notMeasuredCount, 1);
      expect(s.notComparedCount, 1);
    });
  });

  group('oturumla uçtan uca', () {
    test('yarım oturumda YALNIZ korunan ölçümler özete girer', () {
      final Battery b = _b();
      final BlockConfig c = BlockConfig.parse(
        jsonDecode(_blocksFile.readAsStringSync()) as Map<String, dynamic>,
        batteryTestIds: b.tests.keys.toSet(),
      );
      final AssessmentSession s = AssessmentSession(blocks: c.blocks);
      final AssessmentBlock first = c.blocks.first;
      s.beginBlock(first.id, calibrationProfile: 'cal-A');
      for (final String id in first.testIds) {
        s.record(first.id, _measured(id, 100));
      }
      // İkinci bloğa gir, yarıda bırak.
      final AssessmentBlock second = c.blocks[1];
      s.beginBlock(second.id, calibrationProfile: 'cal-B');
      s.record(second.id, _measured(second.testIds.first, 30));

      final BatterySummary sum = BatterySummary.from(
        battery: b, results: s.preservedResults);
      expect(sum.rows.length, first.testIds.length,
          reason: 'yarım blok özete girmez (M-F-133/3)');
    });
  });
}
