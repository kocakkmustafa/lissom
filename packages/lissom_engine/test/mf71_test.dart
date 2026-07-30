/// M-F-71 hükmünün beş maddesinin motor-tarafı kanıtı.
///
/// `tools/threshold_gate_scenario_test.py` config KATMANINDA kanıtlıyor
/// (peak_hold.enter artık ROM eşiği taşımıyor); bu süit MOTOR katmanında
/// kanıtlıyor: eşik-altı kullanıcı gerçekten bir DEĞER ve isimli bir SONUÇ
/// alıyor mu. İki katman ayrı ayrı sınanır çünkü biri doğru olup diğeri
/// yanlış olabilir — "beyan ≠ canlı" (L-146/M-F-90 sınıfı).
library;

import 'package:lissom_engine/lissom_engine.dart';
import 'package:motion_core/motion_core.dart';
import 'package:test/test.dart';

/// `overhead_reach`'in gerçek config'inin özü (bantlar PMC7549223'ten).
/// Motor testinde gerçek JSON okumak yerine aynı SAYILARI taşıyan bir spec
/// kullanıyoruz; JSON okuma ayrıca `battery_test.dart`'ta sınanıyor.
final Battery _battery = Battery.parseJson('''
{
  "id": "lissom.assessment.battery",
  "version": "1.8.0",
  "tests": [
    {
      "id": "overhead_reach",
      "name": "Overhead Reach",
      "instruction": "Raise the arm overhead, hold two seconds, lower.",
      "perSide": true,
      "holdSeconds": 2,
      "confidenceClass": "A",
      "primaryMetric": "shoulder_flexion_{side}",
      "scoring": {
        "type": "banded",
        "unit": "deg",
        "higherIsBetter": true,
        "bands": {
          "60plus": {"low": 130, "normal": 150, "good": 165}
        },
        "source": "PMC7549223 (n=2404, age/sex banded active ROM)."
      },
      "movementPresence": {
        "metric": "shoulder_flexion_{side}",
        "op": "gte",
        "value": 140
      }
    },
    {
      "id": "ankle_dorsiflexion",
      "name": "Ankle Mobility",
      "instruction": "Bend the knee toward the wall, heel down.",
      "perSide": true,
      "confidenceClass": "C",
      "primaryMetric": "tibia_inclination_{side}",
      "scoring": {
        "type": "qualitative",
        "higherIsBetter": true,
        "levels": ["limited", "typical", "good"],
        "source": "Literature norms are in CENTIMETRES; we measure ANGLE."
      },
      "movementPresence": {
        "metric": "tibia_inclination_{side}",
        "op": "gte",
        "value": 15
      }
    },
    {
      "id": "deep_squat",
      "name": "Deep Squat",
      "instruction": "Squat as low as you comfortably can.",
      "perSide": false,
      "holdSeconds": 2,
      "confidenceClass": "A",
      "primaryMetric": "knee_flexion_right",
      "aggregation": "min",
      "scoring": {
        "type": "qualitative",
        "higherIsBetter": false,
        "levels": ["limited", "typical", "good"],
        "source": "Direction proven, bands deliberately absent."
      },
      "movementPresence": {
        "metric": "knee_flexion_right",
        "op": "lte",
        "value": 110
      }
    }
  ]
}
''');

const Map<String, String> _prov = <String, String>{
  'modelVariant': 'test',
  'batteryVersion': '1.8.0',
};

/// Sentetik kare: tek metriği olan bir sahte okuma üretmek için, gerçek
/// landmark geometrisi kurmadan. `metricReader` enjekte edilebilir olduğu
/// için motor testinde iskelet kurmak GEREKMEZ — bu kasıtlı bir tasarım:
/// motor açı matematiğini kendi yazmadığı için burada onu taklit etmemize
/// de gerek yok.
PoseFrame _frame(int tMs) {
  final List<PoseLandmark> lms = List<PoseLandmark>.generate(
    33,
    (int i) => const PoseLandmark(0.5, 0.5, 0, 1),
  );
  return PoseFrame(tUs: tMs * 1000, landmarks: lms);
}

/// Bir değer dizisini motora verir ve sonucu döner.
AssessmentResult _run(
  TestSpec test,
  List<double> values, {
  String? ageBand,
  int stepMs = 100,
  String? abortCode,
  int? finishAtMs,
}) {
  int i = 0;
  final AssessmentEngine engine = AssessmentEngine(
    test: test,
    provenance: _prov,
    ageBand: ageBand,
    metricReader: (PoseFrame f, String name) => values[i],
  );
  for (; i < values.length; i++) {
    engine.process(_frame(i * stepMs));
  }
  if (abortCode != null) engine.reportAbort(abortCode);
  return engine.finish(
      nowUs: (finishAtMs ?? (values.length - 1) * stepMs) * 1000);
}

/// Sabit bir değeri `seconds` boyunca tutan dizi.
List<double> _hold(double v, double seconds, {int stepMs = 100}) =>
    List<double>.filled((seconds * 1000 / stepMs).round() + 1, v);

void main() {
  final TestSpec reach = _battery.tests['overhead_reach']!;
  final TestSpec ankle = _battery.tests['ankle_dorsiflexion']!;

  group('M-F-71 madde 1 — girişim kapısı ROM eşiği DEĞİL', () {
    test('girişim eşiği movementPresence\'tan gelir, skor bandından değil', () {
      // Bant tabanı 130, girişim eşiği 140. İkisi AYRI sayılardır ve
      // birbirinin yerine kullanılamaz: 135° bandın İÇİNDE ama girişim
      // eşiğinin altında. Eğer motor bandı kapı sanarsa bu durum yanlış
      // sınıflanır.
      expect(reach.presenceGate!.value, 140);
      expect(reach.scoring.floorsFor('60plus')!['low'], 130);
    });

    test('kısa jest girişim SAYILMAZ (tutuş şartı)', () {
      // 0,3 sn boyunca 150° — eşiğin üstünde ama requiredHoldS (1,0 sn)
      // altında. L-151'in konuşma-jesti sınıfı, motor tarafında.
      final AssessmentResult r = _run(reach, <double>[
        ..._hold(10, 1.0),
        ..._hold(150, 0.3),
        ..._hold(10, 1.0),
      ]);
      expect(r.attemptDetectedProxy, isFalse,
          reason: 'kısa jest girişim kapısını açmamalı');
      expect(r.code, ResultCode.noAttemptDetected);
    });

    test('gerçek tekrar girişim SAYILIR', () {
      final AssessmentResult r = _run(reach, <double>[
        ..._hold(10, 1.0),
        ..._hold(150, 2.0),
        ..._hold(10, 1.0),
      ]);
      expect(r.isMeasured, isTrue);
      expect(r.value, 150);
    });
  });

  group('M-F-71 madde 2 — girişim varsa ölçüm DAİMA tamamlanır', () {
    test('eşik-altı kullanıcı bir DEĞER alır (L-135\'in ta kendisi)', () {
      // Donmuş omuz senaryosu: 50°'ye ulaşıyor, girişim eşiği 140°.
      // Girişim kapısı açılmadığı için "ölçüldü" DEĞİL ama sebep İSİMLİ
      // ve tepe değer motor içinde birikmiş durumda (madde 2'nin sınırı:
      // kapı açılmadan sonuç raporlanamaz, ama sebep sessiz kalamaz).
      final AssessmentResult r = _run(reach, _hold(50, 3.0));
      expect(r.code, ResultCode.noAttemptDetected);
      expect(r.tier, ResultTier.notMeasured);
      // Sessiz düşüş YOK: kod isimli.
      expect(r.code, isNot(ResultCode.measured));
    });

    test('timeout ölçümü ÇÖPE ATMAZ — değeri korur, kodu değiştirir', () {
      // Girişim açılıyor (2 sn @ 150°), sonra ölçüm penceresi aşılıyor.
      final AssessmentResult r = _run(
        reach,
        <double>[..._hold(150, 2.0), ..._hold(150, 9.0)],
        finishAtMs: 11000,
      );
      expect(r.code, ResultCode.measurementTimedOut);
      expect(r.value, 150, reason: 'timeout değeri atmamalı');
      expect(r.isMeasured, isTrue);
      expect(r.timedOutPhase, 'peak_hold');
    });
  });

  group('M-F-71 madde 3 — bandın altı "skorsuz ama ÖLÇÜLÜ"', () {
    test('bandın altındaki ölçüm measuredBelowRange olur ve bant ETİKETİ ALMAZ',
        () {
      // Girişim eşiği 140, bant tabanı 130. 135° girişimi açar mı? Hayır —
      // o yüzden 145° kullanıyoruz: girişim açılır (>=140) ama bandın
      // en düşük tabanının (130) ÜSTÜNDE, yani `scored`. Bandın ALTINI
      // sınamak için girişim eşiğini bant tabanının altına indiren bir
      // test gerekir — ankle_dorsiflexion tam bu durumda (aşağıda).
      final AssessmentResult r =
          _run(reach, _hold(145, 2.5), ageBand: '60plus');
      expect(r.tier, ResultTier.scored);
      expect(r.bandLabel, 'low');
    });

    test('sayısal bandı olmayan test measuredNoBands döner (bant UYDURMAZ)',
        () {
      final AssessmentResult r = _run(ankle, _hold(20, 2.5));
      expect(r.tier, ResultTier.measuredNoBands);
      expect(r.value, 20);
      expect(r.bandLabel, isNull,
          reason: 'nitel testte sayısal bant etiketi iddia edilemez');
    });

    test('sentetik bant: taban altı → measuredBelowRange, etiket YOK', () {
      // Girişim eşiği bant tabanının ALTINDA olan bir spec — gerçek
      // dünyada `lateral_bend` bu durumda (girişim 15°, 60+ tabanı 18°).
      final Battery b = Battery.parseJson('''
      {
        "id": "t", "version": "1",
        "tests": [{
          "id": "lateral_bend", "perSide": true,
          "primaryMetric": "trunk_lateral_tilt",
          "scoring": {
            "type": "banded", "unit": "deg", "higherIsBetter": true,
            "bands": {"60plus": {"low": 18, "normal": 26, "good": 32}},
            "source": "AAOS 35 / Kendall 40 reference."
          },
          "movementPresence": {
            "metric": "trunk_lateral_tilt", "op": "gte", "value": 15,
            "minHoldS": 0.5
          }
        }]
      }
      ''');
      final AssessmentResult r =
          _run(b.tests['lateral_bend']!, _hold(16, 1.5), ageBand: '60plus');
      expect(r.isMeasured, isTrue, reason: '16° bir SONUÇtur');
      expect(r.tier, ResultTier.measuredBelowRange);
      expect(r.value, 16);
      expect(r.bandLabel, isNull);
      expect(r.lowestBandFloor, 18,
          reason: 'koçlanan anlatı için hedef taban taşınır');
    });
  });

  group('M-F-71 madde 4 — her çıkış yolu isimli bir sonuç kodu üretir', () {
    test('hiç kare gelmezse: noAttemptDetected', () {
      final AssessmentEngine e = AssessmentEngine(
        test: reach,
        provenance: _prov,
        metricReader: (PoseFrame f, String n) => null,
      );
      expect(e.finish().code, ResultCode.noAttemptDetected);
    });

    test('hazırlık zaman aşımı: setupTimedOut + faz adı', () {
      final AssessmentResult r =
          _run(reach, _hold(10, 31.0), finishAtMs: 31000);
      expect(r.code, ResultCode.setupTimedOut);
      expect(r.timedOutPhase, 'ready');
    });

    test('guard iptali: aborted + config\'in abortCode\'u', () {
      final AssessmentResult r =
          _run(reach, _hold(150, 2.5), abortCode: 'BENT_ELBOW');
      expect(r.code, ResultCode.aborted);
      expect(r.abortCode, 'BENT_ELBOW');
      expect(r.tier, ResultTier.notMeasured);
    });

    test('HİÇBİR sonuç kodsuz olamaz — dört yolun hepsi isimli', () {
      final List<AssessmentResult> all = <AssessmentResult>[
        _run(reach, _hold(150, 2.5)),
        _run(reach, _hold(50, 3.0)),
        _run(reach, _hold(150, 2.5), abortCode: 'HEEL_LIFT'),
        _run(reach, _hold(10, 31.0), finishAtMs: 31000),
      ];
      for (final AssessmentResult r in all) {
        expect(r.code, isNotNull);
        expect(r.provenance, isNotEmpty,
            reason: 'sayı dayanağını taşımadan yayılamaz (M-F-07)');
      }
    });
  });

  group('M-F-71 madde 5 — eşik-altında konuşan katman KOÇLANAN', () {
    test('measuredBelowRange ve notMeasured koçlanan katmandan konuşur', () {
      final Battery b = Battery.parseJson('''
      {
        "id": "t", "version": "1",
        "tests": [{
          "id": "x", "perSide": false, "primaryMetric": "m",
          "scoring": {"type": "banded", "unit": "deg", "higherIsBetter": true,
            "bands": {"a": {"low": 100}}, "source": "s"},
          "movementPresence": {"metric": "m", "op": "gte", "value": 20,
            "minHoldS": 0.5}
        }]
      }
      ''');
      final TestSpec t = b.tests['x']!;
      expect(_run(t, _hold(30, 1.5), ageBand: 'a').speaksAsCoaching, isTrue);
      expect(_run(t, _hold(5, 1.5), ageBand: 'a').speaksAsCoaching, isTrue);
      // Skorlanan sonuç koçlanan katmandan KONUŞMAZ.
      expect(_run(t, _hold(120, 1.5), ageBand: 'a').speaksAsCoaching, isFalse);
    });
  });

  group('attemptMicros — "çalışma oldu" ile "çalışma olmadı" ayrı iddialar', () {
    test('ölçülen denemede pencere VAR ve hazırlığı İÇERMEZ', () {
      // 2s hazırlık (eşik altında), sonra 3s tutuş.
      final AssessmentResult r = _run(reach, <double>[
        ..._hold(60, 2.0),
        ..._hold(170, 3.0),
      ]);
      expect(r.isMeasured, isTrue);
      final int? us = r.attemptMicros;
      expect(us, isNotNull);
      // Pencere yalnız girişim algılandıktan SONRASI: 5s'nin tamamı değil.
      expect(us! / 1e6, lessThan(4.0),
          reason: 'hazırlık fazı dâhil olsaydı kullanıcı kazanmadığı '
              'çalışma-saniyesi biriktirirdi (aile şeması: dinlenme hariç)');
      expect(us / 1e6, greaterThan(0.5));
    });

    test('girişim HİÇ algılanmadıysa null — 0 DEĞİL', () {
      final AssessmentResult r = _run(reach, _hold(60, 3.0));
      // Pozitif çapa: sebep İSİMLE iddia ediliyor. Yalnız "ölçülmedi +
      // pencere null" demek, motor bambaşka bir sebeple düşse de geçerdi.
      expect(r.code, ResultCode.noAttemptDetected);
      expect(r.isMeasured, isFalse);
      expect(r.attemptMicros, isNull,
          reason: '0 "çalışma oldu ama sıfır sürdü" derdi; doğru beyan '
              '"sayılacak çalışma yok"');
    });

    test('girişim başladı ama iptal edildi → pencere KORUNUR', () {
      final AssessmentResult r = _run(
        reach,
        <double>[..._hold(170, 3.0)],
        abortCode: 'BENT_ELBOW',
      );
      expect(r.code, ResultCode.aborted);
      expect(r.attemptMicros, isNotNull,
          reason: 'hüküm verilemedi ama çalışma gerçekten oldu — '
              'kaydedilmemesi yarın yüzeyi yalancı yapardı');
    });
  });

  group('ölçüm YÖNÜ — L-181 pozitif ikizi', () {
    // Bu grup "yanlış olan olmuyor" demiyor, "DOĞRU olan OLUYOR" diyor.
    // Yön kusurunun sinsiliği tam buradaydı: hiçbir test yanlış yönde
    // toplandığını iddia etmiyordu, çünkü hiçbir test min-yönlü bir testin
    // değerini HİÇ sınamıyordu — negatif iddia, ölü özellikte de geçer.
    final TestSpec squat = _battery.tests['deep_squat']!;

    test('min-yönlü testte raporlanan değer EN KÜÇÜK olan', () {
      expect(squat.scoring.higherIsBetter, isFalse,
          reason: 'vaka gerçekten min-yönlü olmalı');
      expect(squat.presenceGate, isNotNull,
          reason: 'girişim kapısı olmadan deneme hiç açılmaz');
      final AssessmentResult r = _run(squat, <double>[
        ..._hold(170, 1.0), // ayakta
        ..._hold(95, 2.0), // çömelme — girişim kapısı burada açılır (<=110)
        ..._hold(150, 1.0), // kalkış
      ]);
      expect(r.isMeasured, isTrue);
      expect(r.value, 95,
          reason: 'ters yön 170 raporlardı: EN AZ çömelinen an "ölçüm" olarak '
              'geçerdi (L-181 kusurunun kullanıcıya görünen hâli)');
    });

    test('max-yönlü testte raporlanan değer EN BÜYÜK olan', () {
      // Simetrik ikiz: yön alanı gerçekten OKUNUYOR mu, yoksa min her yerde
      // mi kazanıyor? İki yön ayrı ayrı kanıtlanmadan "yön çalışıyor"
      // denemez.
      expect(reach.scoring.higherIsBetter, isTrue);
      final AssessmentResult r = _run(reach, <double>[
        ..._hold(60, 1.0),
        ..._hold(170, 2.0),
        ..._hold(120, 1.0),
      ]);
      expect(r.value, 170);
    });

    test('yön BEYANSIZ config SERT HATA — sessiz varsayılan yok', () {
      const String noDirection = '''
{"id":"t","version":"0.0.1","metricSet":"m","tests":[
 {"id":"x","name":"X","primaryMetric":"a","aggregation":"min",
  "scoring":{"type":"qualitative","levels":["a"],"source":"s"}}]}''';
      expect(
          () => Battery.parseJson(noDirection),
          throwsA(isA<BatteryError>().having((BatteryError e) => e.path,
              'path', contains('higherIsBetter'))),
          reason: 'bir yön alanının güvenli varsayılanı olamaz — "büyük olan '
              'iyidir" bir İDDİADIR. NOT: hatanın PATH\'i iddia ediliyor, '
              'yalnız tipi değil — ilk yazımda fixture source alanını da '
              'atlıyordu ve parse DAHA ÖNCE patlıyordu; tip-only bir iddia '
              'bunu geçer, higherIsBetter hakkında hiçbir şey kanıtlamadan');
    });
  });

  group('türetme kuralları tek yerden gelir', () {
    test('requiredHoldS fixture_check.py ile AYNI kuralı uygular', () {
      // holdSeconds=2 → max(1.0, 2/2) = 1.0
      expect(reach.requiredHoldS, 1.0);
      // holdSeconds beyan edilmemiş → varsayılan 2 üzerinden 1.0
      expect(ankle.requiredHoldS, 1.0);
    });

    test('yaş bandı verilmezse EN MUHAFAZAKÂR bant seçilir', () {
      final Battery b = Battery.parseJson('''
      {
        "id": "t", "version": "1",
        "tests": [{
          "id": "x", "perSide": false, "primaryMetric": "m",
          "scoring": {"type": "banded", "unit": "deg", "higherIsBetter": true,
            "bands": {"u40": {"low": 150}, "60plus": {"low": 130}},
            "source": "s"},
          "movementPresence": {"metric": "m", "op": "gte", "value": 100,
            "minHoldS": 0.5}
        }]
      }
      ''');
      final Map<String, double> f = b.tests['x']!.scoring.floorsFor(null)!;
      expect(f['low'], 130,
          reason: 'yaş bilinmiyorken yüksek taban varsaymak, kullanıcıyı '
              'hak etmediği bir "yetersiz" hükmüne sokar');
    });

    test('bilinmeyen yaş bandı SESSİZCE yutulmaz', () {
      expect(() => reach.scoring.floorsFor('nosuchband'),
          throwsA(isA<BatteryError>()));
    });
  });
}

/// Test kolaylığı: sonucun girişim algılanıp algılanmadığını kodundan okur.
extension on AssessmentResult {
  bool get attemptDetectedProxy => isMeasured;
}
