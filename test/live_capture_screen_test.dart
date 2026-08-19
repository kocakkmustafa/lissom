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

/// **L-353 — `deep_squat`, ekran-seviyesinde İLK KEZ gerçek karelerle sınanıyor.**
///
/// Ölçülmüş boşluk: `deep_squat` motor-seviyesinde sağlamdı
/// (`mf71_test.dart` sentetik spec'le M-F-71 politikasını sınıyordu) ama bu
/// dosyada (kameradan `LiveCaptureScreen`e KADAR uzanan tek nokta) yalnız
/// `overhead_reach` vardı — `grep -rl deep_squat test/` 8 dosya döndürüyordu,
/// hiçbiri bu deseni taşımıyordu (workspace/DEFTER.md L-352 eki).
///
/// Üçlü RIGHT_HIP(24)–RIGHT_KNEE(26)–RIGHT_ANKLE(28), config'in KENDİ
/// `presence` alanından (`lissom-assessment.v1.json`, `deep_squat.presence`):
/// `{"proximal":"RIGHT_HIP","joint":"RIGHT_KNEE","distal":"RIGHT_ANKLE"}`.
/// Açı yönü de config'ten: `movementPresence.op:"lte", value:110` — ayakta
/// düz duruşta ~180°, çömelmede eşiğin (110°) altına iner (`metric_bridge.
/// dart`ın kendi yorumu: "Diz: Lissom da iç açı konuşuyor (180 = düz
/// bacak) → dönüşüm YOK").
///
/// ⚠️ **Aspect-ratio tuzağına düşülmedi (`full_flow_walk_test.dart`nin
/// dersi):** her iki poz da köşe noktalarını SAF yatay/dikey ışınlarla
/// kuruyor (diz→ayak bileği hep dikey, diz→kalça ayakta dikey/çömelmede
/// yatay) — anizotropik `frameSize` düzeltmesi yalnız x/y'yi BAĞIMSIZ
/// ölçekler, saf eksen-hizalı bir ışını DÖNDÜRMEZ. Açı bu yüzden
/// `_armFrame`nin 1080×1920'siyle de bozulmadan okunur; kare yüzey
/// ZORUNLU değildi.
PoseFrame _squatFrame({required double hipX, required double kneeY, int tUs = 0}) {
  final List<PoseLandmark> lms = List<PoseLandmark>.generate(33, (int i) {
    return switch (i) {
      24 => PoseLandmark(hipX, kneeY, 0, 1), // sağ kalça
      26 => const PoseLandmark(0.50, 0.75, 0, 1), // sağ diz — SABİT
      28 => const PoseLandmark(0.50, 0.90, 0, 1), // sağ ayak bileği — SABİT
      _ => const PoseLandmark(0.5, 0.5, 0, 1),
    };
  });
  return PoseFrame(tUs: tUs, landmarks: lms);
}

TestSpec _deepSquat() => Battery.parseJson('''
{
  "id": "t", "version": "1",
  "tests": [{
    "id": "deep_squat", "perSide": false, "holdSeconds": 2,
    "primaryMetric": "knee_flexion_right",
    "scoring": {
      "type": "banded", "unit": "deg", "higherIsBetter": false,
      "bands": {"x": {"low": 110}},
      "source": "TEST — kablolama sınaması, bant iddiası değil."
    },
    "movementPresence": {
      "metric": "knee_flexion_right", "op": "lte", "value": 110
    }
  }]
}
''').tests['deep_squat']!;

/// Çömelip 1,2 sn tutulan bir senaryo — diz açısı knee(26)→hip(24) ışını
/// SAF YATAY (kalça diz hizasında, 0,20 geride) olacak şekilde kuruldu;
/// diz(26)→ayak-bileği(28) ışını SAF DİKEY. İki dik ışın arasındaki açı
/// **90°**, eşiğin (110°) rahatça altında ve fizyolojik olarak makul bir
/// çömelme-dibi duruşu (uyluk yatay, incik dikey — ders kitabı formu).
List<PoseSourceEvent> _fullSquatScript() => <PoseSourceEvent>[
      for (int i = 0; i <= 12; i++)
        SourceFrameEvent(_squatFrame(hipX: 0.30, kneeY: 0.75, tUs: i * 100000),
            size: _size),
    ];

Future<void> _pump(WidgetTester tester, PoseSource source,
    {TestSpec? test}) async {
  await tester.pumpWidget(MaterialApp(
    theme: buildLissomTheme(),
    home: LiveCaptureScreen(
      test: test ?? _overheadReach(),
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

  testWidgets(
      'deep_squat: gerçek kare akışı → Measuring → sonuç görünür (L-353)',
      (WidgetTester tester) async {
    // Bu test `overhead_reach`in yukarıdaki ikiziyle AYNI iddiayı, FARKLI
    // bir köprülenmiş metrikle (knee_flexion_right, düz açı yerine düşük
    // açı = derin) sınıyor — kameradan ekrana zincirin `deep_squat` için de
    // GERÇEKTEN bağlı olduğunun ilk ekran-seviyesi kanıtı.
    await _pump(tester, FakePoseSource(_fullSquatScript()), test: _deepSquat());
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 50));
    await tester.pump(const Duration(milliseconds: 50));

    expect(find.byKey(const Key('liveCapture.finish')), findsOneWidget,
        reason: 'kare akışı Measuring hâlini üretmeliydi — üretmediyse '
            'ekran kamerayla motoru deep_squat için BAĞLAMIYOR');

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

  testWidgets(
      'önizleme yokluğu KULLANICIYA beyanlı — kaynak işaretçisi yetmez '
      '(L-293)', (WidgetTester tester) async {
    // 🪤 Bu test bir SABOTAJ sonucunda doğdu: `PLACEHOLDER(asset)`
    // işaretçisini `gen_placeholder_register.py` koruyor, ama kullanıcıya
    // görünen kartı SİLDİĞİMDE kapı YEŞİL KALDI — yani yokluk kullanıcı
    // için yeniden SESSİZLEŞEBİLİRDİ, kayıt onu hâlâ listelerken.
    //
    // → *Kaynakta beyanlı olmak, KULLANICIYA beyanlı olmak değildir.*
    //   İki ayrı yüzey, iki ayrı kapı.
    await _pump(tester, FakePoseSource(_fullAttemptScript()));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 50));

    expect(find.text('No camera image on this screen'), findsOneWidget,
        reason: 'ekranda kamera görüntüsü YOK ve bunu söyleyen bir yüzey '
            'olmalı — yokluk sessiz kalamaz');
    expect(find.textContaining('left out on purpose'), findsOneWidget,
        reason: 'sınıf ERTELENMİŞ: sorumluluk ÜSTLENİLİR');
    expect(find.textContaining('yet'), findsNothing,
        reason: '"yet" bir TARİH TAAHHÜDÜdür ve ertelenmiş sınıfında '
            'yasaktır (M-F-186)');
  });
}
