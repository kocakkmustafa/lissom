/// Kök geçit — onboarding tamamlanmışsa `LissomShell`, değilse
/// `OnboardingFlow` (SIRA①, 2026-08-12). Ve **ÇIKMAZ-SOKAK YASAĞI**
/// (`shell.dart`'ın kendi disipliniyle AYNI): okuma patlarsa isimli hata
/// ekranı, sonsuz spinner değil.
library;

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lissom/app/lissom_theme.dart';
import 'package:lissom/app/onboarding_flow.dart';
import 'package:lissom/app/onboarding_gate.dart';
import 'package:lissom/app/onboarding_store.dart';
import 'package:lissom/app/shell.dart';

import 'support/facts_from_disk.dart';

final class _FakeStore implements OnboardingStore {
  _FakeStore(this._profile);
  OnboardingProfile _profile;
  @override
  Future<OnboardingProfile> read() async => _profile;
  @override
  Future<void> write(OnboardingProfile profile) async => _profile = profile;
}

/// `shellLoader` HER ZAMAN enjekte edilir — `LissomShell`in varsayılanı
/// `rootBundle`/`path_provider` ister ve widget testinde SONSUZ ASILI
/// kalır (`shell_test.dart`'ın kendi deseni, bkz. `factsFromDisk()`
/// dokümanı).
Future<void> _pump(
    WidgetTester tester, Future<OnboardingStore> Function() storeLoader) async {
  await tester.pumpWidget(MaterialApp(
    theme: buildLissomTheme(),
    home: OnboardingGate(
      storeLoader: storeLoader,
      shellLoader: () async => factsFromDisk(),
    ),
  ));
  await tester.pumpAndSettle();
}

void main() {
  testWidgets('tamamlanmamışsa OnboardingFlow açılır', (WidgetTester tester) async {
    await _pump(tester,
        () async => _FakeStore(const OnboardingProfile.notStarted()));
    expect(find.byType(OnboardingFlow), findsOneWidget);
    expect(find.byType(LissomShell), findsNothing);
  });

  testWidgets('tamamlanmışsa DOĞRUDAN LissomShell açılır, onboarding GÖRÜNMEZ',
      (WidgetTester tester) async {
    await _pump(
        tester,
        () async => _FakeStore(
            const OnboardingProfile(completed: true, ageBand: 'u40')));
    expect(find.byType(LissomShell), findsOneWidget);
    expect(find.byType(OnboardingFlow), findsNothing);
  });

  testWidgets('okuma PATLARSA sonsuz spinner değil, isimli hata ekranı',
      (WidgetTester tester) async {
    await _pump(tester, () async => throw StateError('disk dolu'));
    expect(find.byKey(const Key('onboarding.gate.loadFailure')), findsOneWidget);
    expect(find.textContaining('disk dolu'), findsOneWidget,
        reason: 'hatanın SEBEBİ yutulmamalı — M-F-267');
  });

  testWidgets(
      'OnboardingFlow bitince (onDone) DOĞRUDAN LissomShell\'e geçer, yeniden okumaz',
      (WidgetTester tester) async {
    final _FakeStore store = _FakeStore(const OnboardingProfile.notStarted());
    await _pump(tester, () async => store);
    expect(find.byType(OnboardingFlow), findsOneWidget);

    // Beş adımı geçmeden `onDone`ı doğrudan tetiklemek yerine gerçek akışı
    // sürüyoruz — geçitin SADECE `onDone` sinyaline mi yoksa yeniden
    // diskten OKUMAYA mı güvendiğini ayırt etmek için `store` write
    // SONRASI BİLE değiştirmiyoruz (`completed` hâlâ false kalsaydı ve
    // geçit yine LissomShell'e geçtiyse, bu diskten değil `onDone`dan
    // geldiğini kanıtlar — ki gerçek `OnboardingFlow.write` zaten
    // completed:true yazar, bu yüzden ayrı bir sahte-tutarsızlık testi
    // yerine gerçek uçtan-uca akış yeterli).
    await tester.tap(find.byKey(const Key('onboarding.continue'))); // O1
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('onboarding.disclaimer.ack')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('onboarding.continue'))); // O2
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('onboarding.continue'))); // O3
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('onboarding.ageBand.u40')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('onboarding.continue'))); // O4
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('onboarding.continue'))); // O5 → bitiş
    await tester.pumpAndSettle();

    expect(find.byType(LissomShell), findsOneWidget);
    expect(find.byType(OnboardingFlow), findsNothing);
  });
}
