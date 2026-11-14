/// LIS-P1-14 — `OnboardingGate`in `measurementAvailable`ı `OnboardingFlow`a
/// İLETMESİ. Başlangıç noktası uygulama kökü (kapı); akış doğrudan
/// kurulmaz. `null` → OnboardingFlow'un üretim varsayılanı (Core sabiti).
library;

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lissom/app/lissom_theme.dart';
import 'package:lissom/app/onboarding_gate.dart';
import 'package:lissom/app/onboarding_store.dart';
import 'package:motion_account/motion_account.dart'
    show motionCameraCoachingAvailable;

final class _Store implements OnboardingStore {
  @override
  Future<OnboardingProfile> read() async =>
      const OnboardingProfile.notStarted();
  @override
  Future<void> write(OnboardingProfile profile) async {}
}

const List<String> _cameraKeys = <String>[
  'onboarding.camera.requestPermission',
  'onboarding.camera.openSettings',
];

Future<void> _pumpGate(WidgetTester tester, {bool? available}) async {
  await tester.pumpWidget(
    MaterialApp(
      theme: buildLissomTheme(),
      home: OnboardingGate(
        measurementAvailable: available,
        storeLoader: () async => _Store(),
        shellLoader: () async =>
            throw StateError('onboarding bitmeden yüklenmez'),
      ),
    ),
  );
  await tester.pumpAndSettle();
}

Future<void> _continue(WidgetTester tester) async {
  await tester.tap(find.byKey(const Key('onboarding.continue')));
  await tester.pumpAndSettle();
}

Future<void> _toStep3(WidgetTester tester, int total) async {
  expect(find.text('STEP 1 OF $total'), findsOneWidget);
  await _continue(tester);
  await tester.tap(find.byKey(const Key('onboarding.disclaimer.ack')));
  await tester.pumpAndSettle();
  await _continue(tester);
}

void main() {
  testWidgets('kapı measurementAvailable:true → 5 adım, kamera adımı görünür', (
    WidgetTester tester,
  ) async {
    await _pumpGate(tester, available: true);
    await _toStep3(tester, 5);
    expect(find.text('STEP 3 OF 5'), findsOneWidget);
    expect(find.byKey(Key(_cameraKeys.first)), findsOneWidget);
  });

  testWidgets('kapı measurementAvailable:false → 4 adım, kamera adımı yok', (
    WidgetTester tester,
  ) async {
    await _pumpGate(tester, available: false);
    await _toStep3(tester, 4);
    expect(find.text('STEP 3 OF 4'), findsOneWidget);
    for (final String k in _cameraKeys) {
      expect(find.byKey(Key(k)), findsNothing);
    }
  });

  testWidgets(
    'kapı measurementAvailable:null → üretim varsayılanı (Core sabiti)',
    (WidgetTester tester) async {
      final int total = motionCameraCoachingAvailable ? 5 : 4;
      await _pumpGate(tester);
      await _toStep3(tester, total);
      expect(find.text('STEP 3 OF $total'), findsOneWidget);
      expect(
        find.byKey(Key(_cameraKeys.first)),
        motionCameraCoachingAvailable ? findsOneWidget : findsNothing,
      );
      // Üretimde kamera kapalı: 4 adım.
      expect(total, 4);
    },
  );
}
