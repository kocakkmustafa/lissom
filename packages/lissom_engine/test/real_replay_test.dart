/// GERÇEK fixture replay'i — Lissom'un "bağlandı ≠ canlı" turu.
///
/// `mf71_test.dart` motoru enjekte edilmiş sayılarla sınıyor; bu süit motoru
/// GERÇEK hasat fixture'ıyla, çekirdeğin GERÇEK geometrisiyle koşturuyor.
/// Aradaki fark tam olarak L-154'ün sınıfı: bir hat "bağlı" görünürken
/// hiç doğru çalışmıyor olabilir.
///
/// ⚠️ Bu süit fixture kütüphanesine bağımlıdır (`~/motion-harvest/lissom/`).
/// Kütüphane yoksa test ATLANMAZ, SKIP ile İSİMLE bildirilir — sessizce
/// yeşil yanan bir replay, hiç koşmamış bir replay'den ayırt edilemez.
library;

import 'dart:io';

import 'package:lissom_engine/lissom_engine.dart';
import 'package:motion_core/motion_core.dart';
import 'package:test/test.dart';

final String _home = Platform.environment['HOME'] ?? '';
final Directory _lib = Directory('$_home/motion-harvest/lissom/landmarks');

/// Kamera+duruş kriterlerini geçen TEK `overhead_reach` kaynağı (L-162).
/// Kasıtlı olarak bu seçildi: en "temiz" kaynak bile motoru uçtan uca
/// koşturabiliyor mu?
final File _fixture = File('${_lib.path}/X2u_vGL0qJU.full.json');

final File _batteryFile = File('../../config/tests/lissom-assessment.v1.json');

void main() {
  final bool haveFixture = _fixture.existsSync();

  group('konvansiyon köprüsü — ÖLÇÜLDÜ, varsayılmadı', () {
    test('kol yanda aşağıyken ROM ~0°, baş üstünde ~180°', () {
      // Sentetik iskelet: çekirdeğin iç-açısı ile Lissom'un ROM dili TERS
      // yönde artar. Bu test o dönüşümün İŞARETİNİ çiviler — sessiz bir
      // ters-çevirme, ölçülen her şeyi bozar ve makul GÖRÜNÜR.
      final CoreMetricReader reader = CoreMetricReader();

      // Kol yanda aşağı: omuz ve dirsek kalçanın üstünde, dikey hizada.
      final PoseFrame armDown = _frame(<int, List<double>>{
        12: <double>[0.55, 0.35], // right shoulder
        14: <double>[0.55, 0.55], // right elbow (aşağıda)
        24: <double>[0.55, 0.60], // right hip
      });
      // Kol baş üstü: dirsek omzun ÜSTÜNDE.
      final PoseFrame armUp = _frame(<int, List<double>>{
        12: <double>[0.55, 0.35],
        14: <double>[0.55, 0.15], // elbow yukarıda
        24: <double>[0.55, 0.60],
      });

      final double? down = reader.read(armDown, 'shoulder_flexion_right');
      final double? up = reader.read(armUp, 'shoulder_flexion_right');
      expect(down, isNotNull);
      expect(up, isNotNull);
      expect(down!, lessThan(30),
          reason: 'kol yanda aşağı ROM diline ~0° demeli, ölçülen: $down');
      expect(up!, greaterThan(150),
          reason: 'kol baş üstü ROM diline ~180° demeli, ölçülen: $up');
      expect(up, greaterThan(down),
          reason: 'ROM dili kol kalktıkça ARTMALI — işaret ters olamaz');
    });

    test('eşlenmemiş metrik SESSİZCE null dönmez, ADIYLA reddedilir', () {
      final CoreMetricReader reader = CoreMetricReader();
      expect(
          () => reader.read(_frame(const <int, List<double>>{}),
              'tibia_inclination_right'),
          throwsA(isA<ArgumentError>()),
          reason: 'köprüsü olmayan metrik sessiz sıfır üretmemeli');
    });
  });

  group('gerçek fixture replay', () {
    test('fixture kütüphanesi mevcut', () {
      expect(haveFixture, isTrue,
          reason: 'kütüphane yoksa bu süit koşmuş SAYILMAZ — '
              'beklenen yol: ${_fixture.path}');
    }, skip: haveFixture ? null : 'fixture kütüphanesi yok: ${_fixture.path}');

    test('overhead_reach uçtan uca koşuyor ve İSİMLİ sonuç üretiyor', () {
      final Battery battery =
          Battery.parseJson(_batteryFile.readAsStringSync());
      final TestSpec test = battery.tests['overhead_reach']!;
      final Fixture fx = Fixture.decode(_fixture.readAsStringSync());
      final CoreMetricReader reader = CoreMetricReader();

      final AssessmentEngine engine = AssessmentEngine(
        test: test,
        provenance: <String, String>{
          'fixture': 'X2u_vGL0qJU',
          'coreVersion': 'motion_core-v0.8.4',
          'batteryVersion': battery.version,
        },
        metricReader: reader.read,
      );

      int read = 0;
      for (final PoseFrame f in fx.frames) {
        if (engine.process(f)) read++;
      }
      final AssessmentResult r = engine.finish(
          nowUs: fx.frames.isEmpty ? 0 : fx.frames.last.tUs);

      // Kanıt: sayılar TÜRETİLİR, yazılmaz (M-O-28).
      printOnFailure('okunan kare: $read / ${fx.frames.length}');
      printOnFailure('sonuç: $r');

      expect(fx.frames, isNotEmpty, reason: 'fixture kare taşımalı');
      expect(read, greaterThan(0),
          reason: 'HİÇ kare okunamadıysa köprü bağlı değil — '
              '"bağlandı ≠ canlı" tam bu durum');
      // M-F-71 madde 4: hangi yol olursa olsun sonuç İSİMLİ.
      expect(r.code, isNotNull);
      expect(r.provenance, isNotEmpty);
      // Bu kaynak gerçek bir baş-üstü uzanma içeriyor (L-141/L-162: kamera+
      // duruş kriterlerini geçen tek kaynak), yani ölçüm BEKLENİR.
      expect(r.isMeasured, isTrue,
          reason: 'temiz kaynakta ölçüm alınmalı — alınamadıysa sebep: '
              '${r.code.name}');
      expect(r.value, isNotNull);
      expect(r.value!, greaterThan(90),
          reason: 'baş-üstü uzanma 90°ün üstünde tepe üretmeli, '
              'ölçülen: ${r.value}');
    }, skip: haveFixture ? null : 'fixture kütüphanesi yok');

    test('M-F-71 skorsuz-ama-ölçülü bölge GERÇEK veriyle de çalışır', () {
      // Aynı fixture, ama yapay olarak yüksek bir bant tabanıyla: gerçek
      // ölçüm bandın altına düşerse motor onu measuredBelowRange olarak
      // sınıflandırmalı ve bant ETİKETİ vermemeli.
      final Fixture fx = Fixture.decode(_fixture.readAsStringSync());
      final CoreMetricReader reader = CoreMetricReader();
      final Battery synthetic = Battery.parseJson('''
      {
        "id": "t", "version": "1",
        "tests": [{
          "id": "overhead_reach", "perSide": true, "holdSeconds": 2,
          "primaryMetric": "shoulder_flexion_{side}",
          "scoring": {
            "type": "banded", "unit": "deg", "higherIsBetter": true,
            "bands": {"x": {"low": 400}},
            "source": "SENTETİK — ulaşılamaz taban, sınıflandırmayı sınar."
          },
          "movementPresence": {
            "metric": "shoulder_flexion_{side}", "op": "gte", "value": 140
          }
        }]
      }
      ''');
      final AssessmentEngine engine = AssessmentEngine(
        test: synthetic.tests['overhead_reach']!,
        provenance: const <String, String>{'fixture': 'X2u_vGL0qJU'},
        metricReader: reader.read,
        ageBand: 'x',
      );
      for (final PoseFrame f in fx.frames) {
        engine.process(f);
      }
      final AssessmentResult r =
          engine.finish(nowUs: fx.frames.last.tUs);
      expect(r.isMeasured, isTrue);
      expect(r.tier, ResultTier.measuredBelowRange,
          reason: 'ulaşılamaz tabanın altındaki GERÇEK ölçüm skorsuz-ama-'
              'ölçülü bölgeye düşmeli');
      expect(r.bandLabel, isNull,
          reason: 'bandın altındaki değere bant adı verilemez');
      expect(r.speaksAsCoaching, isTrue);
    }, skip: haveFixture ? null : 'fixture kütüphanesi yok');
  });
}

/// Verilen landmark'ları yerleştirir, kalanını görünür ama nötr bırakır.
PoseFrame _frame(Map<int, List<double>> points) {
  final List<PoseLandmark> lms = List<PoseLandmark>.generate(33, (int i) {
    final List<double>? p = points[i];
    return p == null
        ? const PoseLandmark(0.5, 0.5, 0, 1)
        : PoseLandmark(p[0], p[1], 0, 1);
  });
  return PoseFrame(tUs: 0, landmarks: lms);
}
