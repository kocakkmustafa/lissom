/// Canlı kablolama kapısı — kaynak→değerlendirici→hâl yolu UÇTAN UCA.
///
/// Kritik iddia: **yüzey kaynağı ayırt etmiyor.** `FakePoseSource` ile koşan
/// akış, gerçek kamerayla da aynı hâl tiplerini üretir; kamera geldiğinde
/// yüzey DEĞİŞMEZ (Ostinato deseni, M-F-272).
library;

import 'package:lissom_engine/lissom_engine.dart';
import 'package:motion_core/motion_core.dart';
import 'package:test/test.dart';

const FrameSize _size = FrameSize(1080, 1920);

/// Kolu istenen açıya yakın getiren sentetik kare (omuz fleksiyonu için).
///
/// ÖLÇÜLDÜ (L-186/L-188): çekirdek `right_shoulder` iç açısı ROM diliyle
/// AYNI yönde — kol yanda aşağı ~0°, baş üstü ~180°.
PoseFrame _armFrame({required double elbowY, int tUs = 0}) {
  final List<PoseLandmark> lms = List<PoseLandmark>.generate(33, (int i) {
    return switch (i) {
      12 => const PoseLandmark(0.5, 0.35, 0, 1), // right shoulder
      14 => PoseLandmark(0.5, elbowY, 0, 1), // right elbow
      24 => const PoseLandmark(0.5, 0.60, 0, 1), // right hip
      _ => const PoseLandmark(0.5, 0.5, 0, 1),
    };
  });
  return PoseFrame(tUs: tUs, landmarks: lms);
}

TestSpec _overheadReach() => Battery.parseJson('''
{
  "id": "t", "version": "1",
  "tests": [{
    "id": "overhead_reach", "perSide": true, "holdSeconds": 2,
    "primaryMetric": "shoulder_flexion_{side}",
    "scoring": {
      "type": "banded", "unit": "deg", "higherIsBetter": true,
      "bands": {"x": {"low": 100}},
      "source": "TEST — kablolama sınaması, bant iddiası değil."
    },
    "movementPresence": {
      "metric": "shoulder_flexion_{side}", "op": "gte", "value": 140
    }
  }]
}
''').tests['overhead_reach']!;

void main() {
  group('kablolama — kaynak bildirir, değerlendirici ölçer', () {
    test('kaynağın HÂL olayı olduğu gibi geçer (gerekçe yeniden yazılmaz)',
        () async {
      // Değerlendirici "kamera bozuk" ile "geri çekil" farkını SİLMEMELİ:
      // kaynağın gerekçesi kaynağa aittir (M-F-266).
      final LiveEvaluator ev = LiveEvaluator(
        test: _overheadReach(),
        side: 'right',
        source: FakePoseSource(const <PoseSourceEvent>[
          SourceStateEvent(PermissionDenied(
              kind: PermissionDenialKind.permanent,
              userText: 'İzni Ayarlar\'dan açın.')),
        ]),
      );
      final List<LiveSessionState> out = await ev.states().toList();
      expect(out.first, isA<LiveIdle>(),
          reason: 'akış her zaman bir hâlle BAŞLAR — sessiz boşluk yok');
      final PermissionDenied p =
          out.whereType<PermissionDenied>().single;
      expect(p.kind, PermissionDenialKind.permanent);
      expect(p.retryMakesSense, isFalse,
          reason: 'kalıcılık bilgisi kaynaktan yüzeye SAĞLAM geçmeli');
      expect(p.userText, 'İzni Ayarlar\'dan açın.',
          reason: 'değerlendirici gerekçeyi yeniden yazmaz');
    });

    test('GERÇEK kare → ölçüm: canlı yol uçtan uca koşuyor', () async {
      // Kol baş üstüne çıkıyor: elbowY 0.55 (aşağı) → 0.15 (yukarı).
      final LiveEvaluator ev = LiveEvaluator(
        test: _overheadReach(),
        side: 'right',
        source: FakePoseSource(<PoseSourceEvent>[
          SourceFrameEvent(_armFrame(elbowY: 0.55), size: _size),
          SourceFrameEvent(_armFrame(elbowY: 0.35, tUs: 100000), size: _size),
          SourceFrameEvent(_armFrame(elbowY: 0.15, tUs: 200000), size: _size),
        ]),
      );
      final List<LiveSessionState> out = await ev.states().toList();
      final List<Measuring> ms = out.whereType<Measuring>().toList();
      expect(ms, isNotEmpty,
          reason: 'HİÇ ölçüm hâli üretilmediyse kablolama bağlı DEĞİL — '
              '"bağlandı ≠ canlı" tam bu durum');
      final LiveReading last = ms.last.reading;
      expect(last.hasMeasurement, isTrue);
      expect(last.degrees!, greaterThan(100),
          reason: 'kol baş üstüne çıktı, tepe yüksek olmalı; ölçülen: '
              '${last.degrees}');
    });

    test('tepe KORUNUR — kol inse bile en yüksek değer düşmez', () async {
      // `higherIsBetter: true` → tepe maksimum. Sessiz varsayılan YOK (L-181),
      // yön config'ten geliyor.
      final LiveEvaluator ev = LiveEvaluator(
        test: _overheadReach(),
        side: 'right',
        source: FakePoseSource(<PoseSourceEvent>[
          SourceFrameEvent(_armFrame(elbowY: 0.15), size: _size),
          SourceFrameEvent(_armFrame(elbowY: 0.55, tUs: 100000), size: _size),
        ]),
      );
      final List<Measuring> ms =
          (await ev.states().toList()).whereType<Measuring>().toList();
      expect(ms.last.reading.degrees, ms.first.reading.degrees,
          reason: 'tepe geri düşerse "en iyi denemen" iddiası bozulur');
    });

    test('okunamayan metrik → JointsOutOfFrame, İSİMLİ grup (L-201)', () async {
      // Tüm landmark'lar görünmez: metrik okunamaz. Bu "kamera bozuk" DEĞİL.
      final PoseFrame invisible = PoseFrame(
        tUs: 0,
        landmarks: List<PoseLandmark>.generate(
            33, (int i) => const PoseLandmark(0.5, 0.5, 0, 0)),
      );
      final LiveEvaluator ev = LiveEvaluator(
        test: _overheadReach(),
        side: 'right',
        source: FakePoseSource(<PoseSourceEvent>[
          SourceFrameEvent(invisible, size: _size),
        ]),
      );
      final List<LiveSessionState> out = await ev.states().toList();
      // Kalite kapısı ya da metrik-okunamaz yolu: ikisi de İSİMLİ hâl üretir,
      // hiçbiri sessizce sıfır göstermez.
      expect(out.length, greaterThan(1));
      final LiveSessionState last = out.last;
      expect(last is JointsOutOfFrame || last is Measuring, isTrue);
      if (last is Measuring) {
        expect(last.reading.hasMeasurement, isFalse,
            reason: 'ölçüm alınamadıysa çıplak sayı GÖSTERİLMEZ');
      } else if (last is JointsOutOfFrame) {
        expect(last.missingGroup, 'upper-body',
            reason: 'eksik grup İSİMLİ olmalı');
      }
    });

    test('ölçüm hiç başlamadıysa yokluk ANLATIYLA gelir, 0 ile değil',
        () async {
      final LiveEvaluator ev = LiveEvaluator(
        test: _overheadReach(),
        side: 'right',
        source: FakePoseSource(const <PoseSourceEvent>[
          SourceStateEvent(NoPersonDetected()),
        ]),
      );
      final List<LiveSessionState> out = await ev.states().toList();
      expect(out.whereType<NoPersonDetected>(), hasLength(1));
      // Hiçbir hâl "0°" sızdırmıyor.
      for (final LiveSessionState s in out) {
        expect(s.userText, isNot(matches(RegExp(r'\b0\s*°'))),
            reason: '${s.runtimeType} çıplak 0° sızdırıyor — '
                '"hiç başlamadı ≠ sıfır" ihlali');
      }
    });
  });

  group('öz-test — kapı kırmızı yanabiliyor', () {
    test('sabotaj: boş kaynak ölçüm ÜRETMEZ (pozitif kontrol)', () async {
      final LiveEvaluator ev = LiveEvaluator(
        test: _overheadReach(),
        side: 'right',
        source: FakePoseSource(const <PoseSourceEvent>[]),
      );
      final List<LiveSessionState> out = await ev.states().toList();
      expect(out.whereType<Measuring>(), isEmpty,
          reason: 'kare yokken ölçüm hâli doğuyorsa değerlendirici uyduruyor');
      expect(out, hasLength(1), reason: 'yalnız açılış hâli beklenir');
    });
  });
}
