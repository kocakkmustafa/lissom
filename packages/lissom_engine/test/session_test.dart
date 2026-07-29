/// M-F-133 madde 3 hükmünün kanıtı: blok-sınırı + tamamlanmışı-koruma.
library;

import 'dart:convert';
import 'dart:io';

import 'package:lissom_engine/lissom_engine.dart';
import 'package:test/test.dart';

final File _blocksFile = File('../../config/tests/assessment-blocks.v1.json');
final File _batteryFile = File('../../config/tests/lissom-assessment.v1.json');

Battery _battery() => Battery.parseJson(_batteryFile.readAsStringSync());

BlockConfig _blocks() => BlockConfig.parse(
      jsonDecode(_blocksFile.readAsStringSync()) as Map<String, dynamic>,
      batteryTestIds: _battery().tests.keys.toSet(),
    );

AssessmentResult _res(String testId) => AssessmentResult.measured(
      testId: testId,
      side: 'right',
      value: 150,
      unit: 'deg',
      provenance: const <String, String>{'t': 'test'},
    );

void main() {
  group('gerçek blok config', () {
    test('parse edilir ve 12 testin TAMAMINI kapsar', () {
      final BlockConfig c = _blocks();
      final int covered =
          c.blocks.fold(0, (int a, AssessmentBlock b) => a + b.testIds.length);
      expect(covered, _battery().tests.length,
          reason: 'bloğu olmayan test oturumda sessizce hiç sorulmaz (L-093)');
    });

    test('eksik kapsama SERT HATA', () {
      final Map<String, dynamic> root =
          jsonDecode(_blocksFile.readAsStringSync()) as Map<String, dynamic>;
      expect(
          () => BlockConfig.parse(root,
              batteryTestIds: <String>{..._battery().tests.keys, 'ghost_test'}),
          throwsA(isA<ArgumentError>()),
          reason: 'kapsanmayan test sessizce geçmemeli');
    });

    test('çift kapsama SERT HATA', () {
      final Map<String, dynamic> root = <String, dynamic>{
        'version': '1',
        'blocks': <Map<String, dynamic>>[
          <String, dynamic>{
            'id': 'a', 'cameraView': 'sagittal', 'bodyPosition': 'standing',
            'tests': <String>['overhead_reach'],
          },
          <String, dynamic>{
            'id': 'b', 'cameraView': 'frontal', 'bodyPosition': 'standing',
            'tests': <String>['overhead_reach'],
          },
        ],
      };
      expect(
          () => BlockConfig.parse(root,
              batteryTestIds: <String>{'overhead_reach'}),
          throwsA(isA<ArgumentError>()));
    });

    test('HÜKÜM: plank_hold kendi bloğunun SONUNDA', () {
      final AssessmentBlock floor =
          _blocks().blocks.firstWhere((AssessmentBlock b) =>
              b.testIds.contains('plank_hold'));
      expect(floor.testIds.last, 'plank_hold',
          reason: 'dayanıklılık testi sonda olmalı — yorgunluk sonraki '
              'ölçümü bozar (M-F-133/3)');
    });

    test('HÜKÜM: ASLR yer-bloğunda', () {
      final AssessmentBlock b = _blocks().blocks.firstWhere(
          (AssessmentBlock b) =>
              b.testIds.contains('active_straight_leg_raise'));
      expect(b.bodyPosition, 'floor');
    });

    test('bir blok TEK kamera görüşü taşır (tek-kalibrasyon kuralı)', () {
      for (final AssessmentBlock b in _blocks().blocks) {
        expect(<String>['sagittal', 'frontal'], contains(b.cameraView));
      }
      // Aynı (görüş, konum) çifti iki blokta tekrarlanmamalı — tekrar,
      // gereksiz kamera hareketi demektir.
      final Set<String> seen = <String>{};
      for (final AssessmentBlock b in _blocks().blocks) {
        final String key = '${b.cameraView}/${b.bodyPosition}';
        expect(seen.add(key), isTrue, reason: 'yinelenen kurulum: $key');
      }
    });
  });

  group('tamamlanmışı-koruma (hükmün asıl vaadi)', () {
    test('yarım kalan oturumda tamamlanan blok KORUNUR', () {
      final BlockConfig c = _blocks();
      final AssessmentSession s = AssessmentSession(blocks: c.blocks);
      final AssessmentBlock first = c.blocks.first;

      s.beginBlock(first.id, calibrationProfile: 'cal-A');
      for (final String t in first.testIds) {
        s.record(first.id, _res(t));
      }
      expect(s.stateOf(first.id), BlockState.completed);

      // İkinci bloğa girip YARIDA bırak.
      final AssessmentBlock second = c.blocks[1];
      s.beginBlock(second.id, calibrationProfile: 'cal-B');
      s.record(second.id, _res(second.testIds.first));

      // Korunan: yalnız birinci bloğun ölçümleri.
      expect(s.preservedResults.length, first.testIds.length,
          reason: 'tamamlanmış blok korunmalı');
      expect(s.preservedResults.containsKey(second.testIds.first), isFalse,
          reason: 'yarım blok kalibrasyon penceresini kapatmadı — '
              '"tamamlanmışı koru" ≠ "yarımı da say"');
    });

    test('tamamlanmış blok geçersizleştirilemez', () {
      final BlockConfig c = _blocks();
      final AssessmentSession s = AssessmentSession(blocks: c.blocks);
      final AssessmentBlock b = c.blocks.first;
      s.beginBlock(b.id, calibrationProfile: 'cal-A');
      for (final String t in b.testIds) {
        s.record(b.id, _res(t));
      }
      s.invalidateBlock(b.id); // sonradan bozulan kalibrasyon
      expect(s.stateOf(b.id), BlockState.completed,
          reason: 'sonradan bozulan kalibrasyon tamamlanmış ölçümü geriye '
              'dönük bozmaz');
      expect(s.preservedResults.length, b.testIds.length);
    });

    test('tamamlanmış blok yeniden başlatılamaz', () {
      final BlockConfig c = _blocks();
      final AssessmentSession s = AssessmentSession(blocks: c.blocks);
      final AssessmentBlock b = c.blocks.first;
      s.beginBlock(b.id, calibrationProfile: 'cal-A');
      for (final String t in b.testIds) {
        s.record(b.id, _res(t));
      }
      expect(() => s.beginBlock(b.id, calibrationProfile: 'cal-C'),
          throwsA(isA<StateError>()));
    });

    test('geçersizleşen blok SIFIRLANIR, öncekiler sağlam kalır', () {
      final BlockConfig c = _blocks();
      final AssessmentSession s = AssessmentSession(blocks: c.blocks);
      final AssessmentBlock first = c.blocks.first;
      final AssessmentBlock second = c.blocks[1];

      s.beginBlock(first.id, calibrationProfile: 'cal-A');
      for (final String t in first.testIds) {
        s.record(first.id, _res(t));
      }
      s.beginBlock(second.id, calibrationProfile: 'cal-B');
      s.record(second.id, _res(second.testIds.first));
      s.invalidateBlock(second.id);

      expect(s.stateOf(second.id), BlockState.invalidated);
      expect(s.preservedResults.length, first.testIds.length,
          reason: 'geçersizleşen blok öncekini etkilemez');
      // Yeniden başlanabilir.
      s.beginBlock(second.id, calibrationProfile: 'cal-B2');
      expect(s.nextTestIn(second.id), second.testIds.first,
          reason: 'yeniden başlayan blok baştan sorar');
    });
  });

  group('sıra ve sınır kuralları', () {
    test('blok içi sıra korunur (yorgunluk düzeni)', () {
      final BlockConfig c = _blocks();
      final AssessmentSession s = AssessmentSession(blocks: c.blocks);
      final AssessmentBlock b = c.blocks.first;
      s.beginBlock(b.id, calibrationProfile: 'cal');
      for (final String expected in b.testIds) {
        expect(s.nextTestIn(b.id), expected);
        s.record(b.id, _res(expected));
      }
      expect(s.nextTestIn(b.id), isNull);
    });

    test('aktif olmayan bloğa yazmak SERT HATA', () {
      final BlockConfig c = _blocks();
      final AssessmentSession s = AssessmentSession(blocks: c.blocks);
      expect(() => s.record(c.blocks.first.id, _res('overhead_reach')),
          throwsA(isA<StateError>()),
          reason: 'kalibrasyon penceresi dışında alınan ölçüm hangi profile '
              'ait olduğunu söyleyemez');
    });

    test('yanlış bloğa yazmak SERT HATA', () {
      final BlockConfig c = _blocks();
      final AssessmentSession s = AssessmentSession(blocks: c.blocks);
      final AssessmentBlock b = c.blocks.first;
      s.beginBlock(b.id, calibrationProfile: 'cal');
      final String alien = c.blocks[1].testIds.first;
      expect(() => s.record(b.id, _res(alien)), throwsA(isA<ArgumentError>()));
    });

    test('özet sayıları TÜRETİLİR', () {
      final BlockConfig c = _blocks();
      final AssessmentSession s = AssessmentSession(blocks: c.blocks);
      final AssessmentBlock b = c.blocks.first;
      s.beginBlock(b.id, calibrationProfile: 'cal-A');
      for (final String t in b.testIds) {
        s.record(b.id, _res(t));
      }
      final Map<String, dynamic> sum = s.summary();
      expect(sum['preservedTests'], b.testIds.length);
      expect(sum['measuredTests'], b.testIds.length);
      final List<dynamic> blocks = sum['blocks'] as List<dynamic>;
      expect(blocks.length, c.blocks.length);
      expect((blocks.first as Map<String, dynamic>)['calibrationProfile'],
          'cal-A');
    });
  });
}
