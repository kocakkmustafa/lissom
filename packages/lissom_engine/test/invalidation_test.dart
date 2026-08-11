/// `invalidation` config-okuyucusu + `trigger` şeması (A4, 2026-08-11).
///
/// Ölçüldü (`docs/A1-A5-AILE-DENETIMI-2026-08-11.md`): config'teki
/// `invalidation` kuralları `TestSpec`te alan olarak yoktu, hiçbir kod
/// okumuyordu. Bu kapatıldı — `TestSpec.invalidation` artık gerçek config'in
/// İKİ biçimini de (metrik-karşılaştırma VE çıplak bayrak) doğru ayrıştırıyor.
///
/// ⛔ **Motor bağlantısı BİLEREK YARIM bırakıldı, bu süitin kapsamı DIŞINDA
/// değil — konusu.** "Herhangi bir karede ihlal → iptal" denendi ve gerçek
/// `X2u_vGL0qJU` fixture replay'inde yanlış-pozitif üretti (`real_replay_
/// test.dart`, tek karelik izleme gürültüsü temiz bir ölçümü iptal etti).
/// Doğru tetikleme politikası ÖLÇÜLMEDİ ve koordinatör de icat ETMEDİ
/// (2026-08-11, 3. sevk): `trigger` alanı artık ZORUNLU, beyansız kural
/// KIRMIZI yanar — bugün her kural `unmeasured` taşır, motor bunu GÖRÜNÜR
/// biçimde atlar (sessizce değil).
library;

import 'dart:io';

import 'package:lissom_engine/lissom_engine.dart';
import 'package:motion_core/motion_core.dart';
import 'package:test/test.dart';

const String _unmeasured = '"trigger": {"type": "unmeasured"}';

/// `active_straight_leg_raise`'in özü.
final Battery _battery = Battery.parseJson('''
{
  "id": "t", "version": "1",
  "tests": [{
    "id": "aslr",
    "perSide": true,
    "confidenceClass": "B",
    "primaryMetric": "hip_flexion_{side}",
    "movementPresence": {"metric": "hip_flexion_{side}", "op": "lte", "value": 150},
    "invalidation": [
      {"rule": "knee_flexion_{side} < 165", "code": "BENT_KNEE",
       "message": "Keep the raised leg straight.", $_unmeasured},
      {"rule": "hip_flexion_{opposite} < 170", "code": "OPPOSITE_LEG_LIFTED",
       "message": "Keep your other leg flat on the floor.", $_unmeasured},
      {"rule": "confidence < 0.6", "code": "LOW_CONFIDENCE", $_unmeasured}
    ],
    "scoring": {
      "type": "banded", "unit": "deg", "higherIsBetter": false,
      "bands": {"u40": {"low": 110, "normal": 100, "good": 90}},
      "source": "test fixture"
    }
  }]
}
''');

final Map<String, String> _prov = <String, String>{'test': 'invalidation'};

PoseFrame _frame(int tMs) {
  final List<PoseLandmark> lms =
      List<PoseLandmark>.generate(33, (int i) => const PoseLandmark(0.5, 0.5, 0, 1));
  return PoseFrame(tUs: tMs * 1000, landmarks: lms);
}

AssessmentResult _run(
  TestSpec test,
  int frames, {
  required double Function(int frameIndex, String metric) reader,
  String side = 'right',
  int stepMs = 100,
}) {
  final AssessmentEngine engine = AssessmentEngine(
    test: test,
    side: side,
    provenance: _prov,
    metricReader: (PoseFrame f, String name) =>
        reader((f.tUs ~/ 1000) ~/ stepMs, name),
  );
  for (int i = 0; i < frames; i++) {
    engine.process(_frame(i * stepMs));
  }
  return engine.finish(nowUs: (frames - 1) * stepMs * 1000);
}

void main() {
  final TestSpec aslr = _battery.tests['aslr']!;

  group('ayrıştırma — TestSpec.invalidation gerçek config biçimlerini ALIYOR', () {
    test('metrik-karşılaştırma kuralları doğru ayrıştırılır', () {
      expect(aslr.invalidation, hasLength(3));
      final InvalidationRule bentKnee =
          aslr.invalidation.firstWhere((InvalidationRule r) => r.code == 'BENT_KNEE');
      expect(bentKnee.metric, 'knee_flexion_{side}');
      expect(bentKnee.op, '<');
      expect(bentKnee.value, 165);
      expect(bentKnee.isNumericComparison, isTrue);
      expect(bentKnee.message, contains('straight'));
      expect(bentKnee.trigger.type, InvalidationTriggerType.unmeasured);

      final InvalidationRule lowConf =
          aslr.invalidation.firstWhere((InvalidationRule r) => r.code == 'LOW_CONFIDENCE');
      expect(lowConf.message, isNull,
          reason: 'config\'te mesaj yok — burada UYDURULMAMALI');
      expect(lowConf.isConfidenceRule, isTrue);
    });

    test('çıplak bayrak kuralları (supportContact) FIRLATMADAN ayrıştırılır', () {
      // Gerçek config'te tests[7].invalidation[0] — regex'in ilk sürümü
      // yalnız `active_straight_leg_raise`e (test 10) bakılarak yazılmıştı
      // ve TÜM 12 test taranınca bu biçim çıktı (metodolojik ders: tek
      // örnekten genelleme, `real_config_test.dart` yakaladı).
      final Battery b = Battery.parseJson('''
      {
        "id": "t", "version": "1",
        "tests": [{
          "id": "balance", "confidenceClass": "B",
          "primaryMetric": "hip_flexion_right",
          "invalidation": [
            {"rule": "supportContact", "code": "USED_SUPPORT",
             "message": "Holding onto something ends the test.", $_unmeasured},
            {"rule": "footTouchdown", "code": "FOOT_DOWN", $_unmeasured}
          ],
          "scoring": {"type": "banded", "unit": "deg", "higherIsBetter": false,
            "bands": {"u40": {"low": 110}}, "source": "test"}
        }]
      }
      ''');
      final TestSpec balance = b.tests['balance']!;
      expect(balance.invalidation, hasLength(2));
      expect(balance.invalidation.every((InvalidationRule r) => !r.isNumericComparison),
          isTrue, reason: 'bayrak kuralları sayısal-karşılaştırma DEĞİL — '
              'unit:bool, source:phase, kare-geometrisinden gelmiyor');
    });

    test('gerçek üretim config\'i (12 test) tamamen ayrıştırılır', () {
      // real_config_test.dart aynısını sınıyor; burada AYRICA invalidation
      // kapsamını sayıyoruz — bu satır bu testin var olma sebebidir.
      final Battery real = Battery.parseJson(
          File('../../config/tests/lissom-assessment.v1.json').readAsStringSync());
      final int withInvalidation =
          real.tests.values.where((TestSpec t) => t.invalidation.isNotEmpty).length;
      expect(withInvalidation, 12,
          reason: '12 testin hepsi en az confidence kuralı taşıyor — '
              'biri bile ayrıştırma sırasında sessizce düşerse bu sayı kayar');
      expect(
          real.tests.values.expand((TestSpec t) => t.invalidation)
              .every((InvalidationRule r) => r.trigger.type == InvalidationTriggerType.unmeasured),
          isTrue,
          reason: 'gerçek config\'teki 24 kuralın HEPSİ bugün unmeasured — '
              'biri bile başka bir tür taşırsa motor UnimplementedError '
              'fırlatır (bkz. assessment_engine.dart)');
    });
  });

  group('trigger — ZORUNLU, beyansız kural KIRMIZI yanar (koordinatör hükmü)', () {
    test('trigger alanı YOKSA parse BatteryError fırlatır', () {
      expect(
          () => Battery.parseJson('''
          {
            "id": "t", "version": "1",
            "tests": [{
              "id": "x", "confidenceClass": "B",
              "primaryMetric": "hip_flexion_right",
              "invalidation": [{"rule": "confidence < 0.6", "code": "LOW_CONFIDENCE"}],
              "scoring": {"type": "banded", "unit": "deg", "higherIsBetter": false,
                "bands": {"u40": {"low": 110}}, "source": "test"}
            }]
          }
          '''),
          throwsA(isA<BatteryError>()),
          reason: 'trigger beyan edilmeden bir invalidation kuralı sessizce '
              'geçmemeli — bu ÖZ-TEST sabotajın (trigger silme) yakalandığını '
              'kanıtlar');
    });

    test('bilinmeyen trigger.type BatteryError fırlatır', () {
      expect(
          () => Battery.parseJson('''
          {
            "id": "t", "version": "1",
            "tests": [{
              "id": "x", "confidenceClass": "B",
              "primaryMetric": "hip_flexion_right",
              "invalidation": [{"rule": "confidence < 0.6", "code": "LOW_CONFIDENCE",
                "trigger": {"type": "vibesBased"}}],
              "scoring": {"type": "banded", "unit": "deg", "higherIsBetter": false,
                "bands": {"u40": {"low": 110}}, "source": "test"}
            }]
          }
          '''),
          throwsA(isA<BatteryError>()));
    });

    test('dört tür de (peakFrame/sustained/ratio/unmeasured) ayrıştırılır', () {
      for (final String type in <String>['peakFrame', 'sustained', 'ratio', 'unmeasured']) {
        final Battery b = Battery.parseJson('''
        {
          "id": "t", "version": "1",
          "tests": [{
            "id": "x", "confidenceClass": "B",
            "primaryMetric": "hip_flexion_right",
            "invalidation": [{"rule": "confidence < 0.6", "code": "LOW_CONFIDENCE",
              "trigger": {"type": "$type"}}],
            "scoring": {"type": "banded", "unit": "deg", "higherIsBetter": false,
              "bands": {"u40": {"low": 110}}, "source": "test"}
          }]
        }
        ''');
        expect(b.tests['x']!.invalidation.single.trigger.type.name, type);
      }
    });
  });

  group('motor — unmeasured GÖRÜNÜR biçimde atlanır (sessizce değil)', () {
    test('bugün gerçek bir BENT_KNEE senaryosu SESSİZCE ölçülür — bu satır o boşluğun kanıtı', () {
      // Bu test kırmızı YANMAZ. Yeşil kalması ÖLÇÜLMÜŞ bir gerçeği kaydeder:
      // motor unmeasured kuralları uygulamıyor — assessment_engine.dart'taki
      // switch'in `unmeasured` case'i bunu GÖRÜNÜR biçimde yapıyor (kod
      // orada duruyor, atlanmıyor kazara).
      final AssessmentResult r = _run(aslr, 25, reader: (int i, String m) {
        if (m == 'hip_flexion_right') return 100;
        if (m == 'knee_flexion_right') return 140; // BÜKÜLÜ — 25 karenin HEPSİNDE
        if (m == 'hip_flexion_left') return 179;
        return 0; // confidence dahil sorulmayan her şey
      });
      expect(r.code, isNot(ResultCode.aborted),
          reason: 'motor unmeasured kuralları uygulamıyor — ÖLÇÜLMÜŞ bir '
              'eksiklik, kazara bir geçiş değil');
      expect(r.isMeasured, isTrue);
    });

    test('peakFrame/sustained/ratio göründüğünde motor SESSİZ KALMAZ, durur', () {
      final Battery b = Battery.parseJson('''
      {
        "id": "t", "version": "1",
        "tests": [{
          "id": "x", "perSide": true, "confidenceClass": "B",
          "primaryMetric": "hip_flexion_{side}",
          "movementPresence": {"metric": "hip_flexion_{side}", "op": "lte", "value": 150},
          "invalidation": [{"rule": "knee_flexion_{side} < 165", "code": "BENT_KNEE",
            "trigger": {"type": "peakFrame"}}],
          "scoring": {"type": "banded", "unit": "deg", "higherIsBetter": false,
            "bands": {"u40": {"low": 110}}, "source": "test"}
        }]
      }
      ''');
      expect(
          () => _run(b.tests['x']!, 5, reader: (int i, String m) {
            if (m == 'hip_flexion_right') return 100;
            if (m == 'knee_flexion_right') return 178;
            return 0;
          }),
          throwsA(isA<UnimplementedError>()),
          reason: 'uygulanmayan bir trigger türü SESSİZCE yok sayılmamalı — '
              'motor onu isimle durdurmalı (koordinatör hükmü)');
    });
  });
}
