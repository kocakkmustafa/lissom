/// M-F-185 (b)-çıkışının dört şartının kanıtı: "ölçüm var, hüküm yok".
library;

import 'dart:io';

import 'package:lissom_engine/lissom_engine.dart';
import 'package:motion_core/motion_core.dart';
import 'package:test/test.dart';

final File _batteryFile = File('../../config/tests/lissom-assessment.v1.json');
Battery _b() => Battery.parseJson(_batteryFile.readAsStringSync());

PoseFrame _frame(int tMs) => PoseFrame(
      tUs: tMs * 1000,
      landmarks: List<PoseLandmark>.generate(
          33, (int i) => const PoseLandmark(0.5, 0.5, 0, 1)),
    );

AssessmentResult _run(TestSpec t, List<double> values, {int stepMs = 100}) {
  int i = 0;
  final AssessmentEngine e = AssessmentEngine(
    test: t,
    provenance: const <String, String>{'src': 'test'},
    metricReader: (PoseFrame f, String n) => values[i],
  );
  for (; i < values.length; i++) {
    e.process(_frame(i * stepMs));
  }
  return e.finish(nowUs: (values.length - 1) * stepMs * 1000);
}

void main() {
  group('şart (a) — ölçülü gerekçe YÜZEYDE', () {
    test('iki test de referenceStatus taşıyor, gerekçesi ÖLÇÜLMÜŞ', () {
      final Battery b = _b();
      for (final String id in <String>['overhead_reach', 'deep_squat']) {
        final ReferenceStatus? rs = b.tests[id]!.referenceStatus;
        expect(rs, isNotNull, reason: '$id referans durumunu beyan etmeli');
        expect(rs!.isMeasurementOnly, isTrue);
        // Gerekçe SAYI taşımalı — "yetersiz veri" gibi bir el sallaması değil.
        expect(rs.basisMeasured, matches(RegExp(r'\d')),
            reason: '$id gerekçesi ölçülmüş olmalı (sayı içermeli)');
        expect(rs.basisMeasured.length, greaterThan(40));
      }
    });

    test('gerekçenin KULLANICI dili ayrı ve İngilizce yüzey metni', () {
      final Battery b = _b();
      for (final String id in <String>['overhead_reach', 'deep_squat']) {
        final ReferenceStatus rs = b.tests[id]!.referenceStatus!;
        expect(rs.basisUserText, isNotEmpty);
        expect(rs.basisUserText, isNot(rs.basisMeasured),
            reason: 'kullanıcı metni, iç gerekçenin kopyası olamaz');
        // Yüzey dili EN (config'in geri kalanıyla tutarlı).
        expect(rs.basisUserText, matches(RegExp(r'\b(we|you|your)\b',
            caseSensitive: false)));
      }
    });

    test('gerekçe kodları makine-okur ve AYRI', () {
      final Battery b = _b();
      expect(b.tests['overhead_reach']!.referenceStatus!.basisCode,
          'variant-mismatch');
      expect(b.tests['deep_squat']!.referenceStatus!.basisCode, 'count-gate');
    });
  });

  group('şart (b) — terfi yolu İSİMLİ', () {
    test('unblockedBy + kriter + ölçülmüş boşluk, üçü de dolu', () {
      final Battery b = _b();
      for (final String id in <String>['overhead_reach', 'deep_squat']) {
        final ReferenceStatus rs = b.tests[id]!.referenceStatus!;
        expect(rs.unblockedBy, isNotEmpty);
        expect(rs.criterion, isNotEmpty);
        expect(rs.measuredGap, matches(RegExp(r'\d')),
            reason: 'boşluk ÖLÇÜLMÜŞ olmalı — "bir gün belki" değil');
      }
    });

    test('yarım beyan SERT HATA — gerekçesiz measurementOnly olamaz', () {
      // Bu, L-135 sınıfının config katmanındaki hâli: sebebini söylemeyen
      // bir eksiklik. Okuyucu bunu sessizce kabul ETMEMELİ.
      const String half = '''
      {"id":"t","version":"1","tests":[{
        "id":"x","perSide":false,"primaryMetric":"m",
        "scoring":{"type":"qualitative","levels":["a"],"source":"s"},
        "referenceStatus":{"state":"measurementOnly",
          "statusBasis":{"code":"c","measured":"m"},
          "promotionPath":{"unblockedBy":"u","criterion":"c","measuredGap":"1"}}
      }]}''';
      expect(() => Battery.parseJson(half), throwsA(isA<BatteryError>()),
          reason: 'statusBasis.userText eksik — kullanıcıya sebep ulaşmaz');
    });
  });

  group('şart (c) — lessonClass YAZIM ANINDA damgalanır', () {
    test('measurementOnly testin HER sonuç yolu damgayı taşır', () {
      final TestSpec t = _b().tests['overhead_reach']!;
      // ölçüldü
      final AssessmentResult ok =
          _run(t, List<double>.filled(30, 150));
      // girişim yok
      final AssessmentResult none = _run(t, List<double>.filled(30, 10));
      for (final AssessmentResult r in <AssessmentResult>[ok, none]) {
        expect(r.lessonClass, 'measurementOnly',
            reason: 'kayıt hangi rejimde alındığını KENDİ üstünde taşımalı');
        expect(r.isMeasurementOnly, isTrue);
      }
    });

    test('normal (referanslı) test damga TAŞIMAZ', () {
      // lateral_bend referenceStatus beyan etmiyor → normal rejim.
      final TestSpec t = _b().tests['lateral_bend']!;
      final AssessmentResult r = _run(t, List<double>.filled(30, 30));
      expect(r.lessonClass, isNull);
      expect(r.isMeasurementOnly, isFalse);
    });

    test('damga sonradan TÜRETİLMEZ — sonucun kendi alanında', () {
      // M-F-138 dersinin oturum-kaydı hâli: config sonradan değişse bile
      // eski kayıt hangi rejimde yazıldığını söyleyebilmeli.
      final AssessmentResult r =
          _run(_b().tests['overhead_reach']!, List<double>.filled(30, 150));
      // Alan sonucun üstünde; testin şu anki config'ine bakılmıyor.
      expect(r.lessonClass, isNotNull);
    });
  });

  group('measurementOnly ile M-F-71 birlikte çalışıyor', () {
    test('overhead_reach ölçülür ve bant etiketi alır ama damgalıdır', () {
      // Aile doktrini: "ölçüm var, hüküm yok" — ölçüm engellenmiyor,
      // yalnız REFERANSA karşı kıyaslanmadığı kayda geçiyor.
      final AssessmentResult r =
          _run(_b().tests['overhead_reach']!, List<double>.filled(30, 150));
      expect(r.isMeasured, isTrue, reason: 'ölçüm ENGELLENMEZ');
      expect(r.value, 150);
      expect(r.lessonClass, 'measurementOnly');
    });

    test('deep_squat: ordinal (bantsız) + measurementOnly', () {
      final AssessmentResult r =
          _run(_b().tests['deep_squat']!, List<double>.filled(30, 80));
      expect(r.tier, ResultTier.measuredNoBands,
          reason: 'ordinal test sayısal bant iddia etmez');
      expect(r.lessonClass, 'measurementOnly');
    });
  });
}
