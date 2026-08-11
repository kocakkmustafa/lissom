/// Canlı ölçüm ekranı — `FakePoseSource` ile UÇTAN UCA (kamera olmadan,
/// kamera-kabuğu sevki SIRA③, 2026-08-12).
///
/// `live_evaluator_test.dart`'ın `_overheadReach`/`_armFrame` deseni AYNEN
/// kullanıldı — "gerçek kare → ölçüm" iddiasının bu ailedeki KANONİK
/// fixture'ı, ikinci bir kopya İCAT EDİLMEDİ.
library;

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lissom/app/lissom_theme.dart';
import 'package:lissom/app/live_capture_screen.dart';
import 'package:lissom_engine/lissom_engine.dart';
import 'package:motion_core/motion_core.dart';

const FrameSize _size = FrameSize(1080, 1920);

PoseFrame _armFrame({required double elbowY, int tUs = 0}) {
  final List<PoseLandmark> lms = List<PoseLandmark>.generate(33, (int i) {
    return switch (i) {
      12 => const PoseLandmark(0.5, 0.35, 0, 1),
      14 => PoseLandmark(0.5, elbowY, 0, 1),
      24 => const PoseLandmark(0.5, 0.60, 0, 1),
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

/// Kol baş üstüne çıkıp 1,2 sn tutulan bir senaryo — girişim eşiğini
/// (`requiredHoldS` = holdSeconds/2 = 1,0 sn) GERÇEKTEN aşacak kadar uzun.
List<PoseSourceEvent> _fullAttemptScript() => <PoseSourceEvent>[
      for (int i = 0; i <= 12; i++)
        SourceFrameEvent(_armFrame(elbowY: 0.15, tUs: i * 100000), size: _size),
    ];

Future<void> _pump(WidgetTester tester, PoseSource source) async {
  await tester.pumpWidget(MaterialApp(
    theme: buildLissomTheme(),
    home: LiveCaptureScreen(
      test: _overheadReach(),
      batteryVersion: 'test',
      sourceOverride: source,
    ),
  ));
}

void main() {
  testWidgets('hâl olayı olduğu gibi geçer — PermissionDenied İSİMLE görünür',
      (WidgetTester tester) async {
    await _pump(
        tester,
        FakePoseSource(const <PoseSourceEvent>[
          SourceStateEvent(PermissionDenied(
              kind: PermissionDenialKind.permanent,
              userText: 'Open Settings to turn it on.')),
        ]));
    await tester.pump();
    await tester.pump();
    expect(find.text('Open Settings to turn it on.'), findsOneWidget);
    expect(find.byKey(const Key('liveCapture.finish')), findsNothing,
        reason: 'ölçülemeyen bir hâlde "I\'m done" düğmesi GÖRÜNMEMELİ');
  });

  testWidgets('gerçek kare akışı → Measuring → "I\'m done" → sonuç görünür',
      (WidgetTester tester) async {
    await _pump(tester, FakePoseSource(_fullAttemptScript()));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 50));
    await tester.pump(const Duration(milliseconds: 50));

    expect(find.byKey(const Key('liveCapture.finish')), findsOneWidget,
        reason: 'kare akışı Measiring hâlini üretmeliydi — üretmediyse '
            'ekran kamerayla motoru BAĞLAMIYOR ("bağlandı ≠ canlı" tam '
            'bu durum, ters yönde)');

    await tester.tap(find.byKey(const Key('liveCapture.finish')));
    await tester.pump();

    expect(find.byKey(const Key('liveCapture.tryAgain')), findsOneWidget,
        reason: 'bitirince sonuç ekranı (Try again ile) görünmeli');
  });

  testWidgets('BOŞ kaynak → ölçüm hâli hiç doğmaz (öz-test, sabotaj)',
      (WidgetTester tester) async {
    await _pump(tester, FakePoseSource(const <PoseSourceEvent>[]));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 50));
    expect(find.byKey(const Key('liveCapture.finish')), findsNothing,
        reason: 'kare yokken Measuring doğuyorsa ekran uyduruyor');
  });
}
