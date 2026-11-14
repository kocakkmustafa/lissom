/// LIS-P1-12a — kamera kapalıyken (`measurementAvailable=false`) onboarding'de
/// kamera adımı akıştan TAMAMEN çıkar: sayaç 4 adım, kapalı-kamera adım metni
/// hiçbir adımda görünmez, izin istenmez. `true` iken 5 adım ve kamera adımı
/// aynen korunur.
library;

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:lissom/app/lissom_theme.dart';
import 'package:lissom/app/onboarding_flow.dart';
import 'package:lissom/app/onboarding_store.dart';

final class _Store implements OnboardingStore {
  @override
  Future<OnboardingProfile> read() async => const OnboardingProfile.notStarted();
  @override
  Future<void> write(OnboardingProfile profile) async {}
}

Future<void> _tapContinue(WidgetTester tester) async {
  await tester.tap(find.byKey(const Key('onboarding.continue')));
  await tester.pumpAndSettle();
}

void main() {
  const closedStep = 'Camera measurements are closed';
  const cameraKeys = <String>[
    'onboarding.camera.requestPermission',
    'onboarding.camera.openSettings',
  ];

  testWidgets('measurementAvailable=false: kamera adımı yok, sayaç 4 adım',
      (WidgetTester tester) async {
    int requests = 0;
    await tester.pumpWidget(MaterialApp(
      theme: buildLissomTheme(),
      home: OnboardingFlow(
        store: _Store(),
        measurementAvailable: false,
        onRequestPermission: () async {
          requests++;
          return PermissionStatus.granted;
        },
        onDone: (_) {},
      ),
    ));
    await tester.pumpAndSettle();
    final List<String> seen = <String>[];
    for (int n = 1; n <= 4; n++) {
      expect(find.text('STEP $n OF 4'), findsOneWidget, reason: 'adım $n');
      expect(find.textContaining(closedStep), findsNothing);
      expect(find.textContaining('We do not request camera access'),
          findsNothing);
      for (final String k in cameraKeys) {
        expect(find.byKey(Key(k)), findsNothing);
      }
      seen.add('STEP $n OF 4');
      if (n == 2) {
        await tester.tap(find.byKey(const Key('onboarding.disclaimer.ack')));
        await tester.pumpAndSettle();
      }
      if (n == 3) {
        await tester.tap(find.byKey(const Key('onboarding.ageBand.u40')));
        await tester.pumpAndSettle();
      }
      if (n < 4) await _tapContinue(tester);
    }
    expect(find.text('STEP 5 OF 4'), findsNothing);
    expect(requests, 0);
  });

  testWidgets('measurementAvailable=true: 5 adım, kamera adımı korunur',
      (WidgetTester tester) async {
    await tester.pumpWidget(MaterialApp(
      theme: buildLissomTheme(),
      home: OnboardingFlow(
        store: _Store(),
        measurementAvailable: true,
        onDone: (_) {},
      ),
    ));
    await tester.pumpAndSettle();
    expect(find.text('STEP 1 OF 5'), findsOneWidget);
    await _tapContinue(tester);
    await tester.tap(find.byKey(const Key('onboarding.disclaimer.ack')));
    await tester.pumpAndSettle();
    await _tapContinue(tester);
    expect(find.text('STEP 3 OF 5'), findsOneWidget);
    expect(find.byKey(const Key('onboarding.camera.requestPermission')),
        findsOneWidget);
  });
}
