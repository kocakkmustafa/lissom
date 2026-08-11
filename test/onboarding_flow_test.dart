/// Onboarding akışı — O1 Welcome → O2 Disclaimer(ZORUNLU) → O3 Camera-info →
/// O4 Profile(yaş bandı ZORUNLU) → O5 Measurement limits (SIRA①, 2026-08-12).
///
/// **Ölü-buton yasağı (home_screen.dart deseni):** her adımda "Continue"
/// gerçekten bir sonraki adıma geçmeli; O2/O4'te ZORUNLU alan boşken
/// düğme DEVRE DIŞI kalmalı — atlanabilir bir "zorunlu" alan, zorunlu
/// değildir.
library;

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lissom/app/lissom_theme.dart';
import 'package:lissom/app/onboarding_flow.dart';
import 'package:lissom/app/onboarding_store.dart';

/// Bellek-içi sahte depo — gerçek dosya sistemine dokunmadan `write`
/// çağrısını GÖZLEMLENEBİLİR kılar.
final class _FakeStore implements OnboardingStore {
  OnboardingProfile? written;
  @override
  Future<OnboardingProfile> read() async => const OnboardingProfile.notStarted();
  @override
  Future<void> write(OnboardingProfile profile) async => written = profile;
}

Future<void> _pump(WidgetTester tester, OnboardingStore store, VoidCallback onDone) async {
  await tester.pumpWidget(MaterialApp(
    theme: buildLissomTheme(),
    home: OnboardingFlow(store: store, onDone: onDone),
  ));
  await tester.pumpAndSettle();
}

Future<void> _continue(WidgetTester tester) async {
  await tester.tap(find.byKey(const Key('onboarding.continue')));
  await tester.pumpAndSettle();
}

void main() {
  testWidgets('O1 — hoş geldin metni ve Continue baştan AKTİF', (WidgetTester tester) async {
    final _FakeStore store = _FakeStore();
    await _pump(tester, store, () {});
    expect(find.text('Welcome to Lissom'), findsOneWidget);
    final FilledButton btn = tester
        .widget<FilledButton>(find.byKey(const Key('onboarding.continue')));
    expect(btn.onPressed, isNotNull);
  });

  testWidgets('O2 — onay KUTUSU işaretlenmeden Continue DEVRE DIŞI', (WidgetTester tester) async {
    final _FakeStore store = _FakeStore();
    await _pump(tester, store, () {});
    await _continue(tester); // O1 → O2

    expect(find.textContaining('general wellness app'), findsOneWidget,
        reason: 'disclaimers.onboarding.text BİREBİR görünmeli');
    FilledButton btn = tester
        .widget<FilledButton>(find.byKey(const Key('onboarding.continue')));
    expect(btn.onPressed, isNull,
        reason: 'zorunlu onay işaretlenmeden geçiş İZİN VERİLMEMELİ');

    await tester.tap(find.byKey(const Key('onboarding.disclaimer.ack')));
    await tester.pumpAndSettle();
    btn = tester.widget<FilledButton>(find.byKey(const Key('onboarding.continue')));
    expect(btn.onPressed, isNotNull,
        reason: 'onaylandıktan sonra düğme GERÇEKTEN aktif olmalı — ölü '
            'buton sınıfı burada TERSİNE de geçerli');
  });

  testWidgets('O3 — kamera BU BUILD\'de yok metni, dürüst (uydurma izin akışı değil)',
      (WidgetTester tester) async {
    final _FakeStore store = _FakeStore();
    await _pump(tester, store, () {});
    await _continue(tester); // O1 → O2
    await tester.tap(find.byKey(const Key('onboarding.disclaimer.ack')));
    await tester.pumpAndSettle();
    await _continue(tester); // O2 → O3

    expect(find.textContaining('No session can be captured in this build'),
        findsOneWidget,
        reason: 'CaptureUnavailableNote.text AYNEN kullanılmalı — yeni bir '
            'kamera-izni cümlesi İCAT EDİLMEMELİ');
  });

  testWidgets('O4 — yaş bandı seçilmeden Continue DEVRE DIŞI, seçilince aktif',
      (WidgetTester tester) async {
    final _FakeStore store = _FakeStore();
    await _pump(tester, store, () {});
    await _continue(tester);
    await tester.tap(find.byKey(const Key('onboarding.disclaimer.ack')));
    await tester.pumpAndSettle();
    await _continue(tester);
    await _continue(tester); // O3 → O4

    FilledButton btn = tester
        .widget<FilledButton>(find.byKey(const Key('onboarding.continue')));
    expect(btn.onPressed, isNull,
        reason: 'yaş bandı ZORUNLU — bantlar yaşa göre (UI-BRIEF O4)');

    await tester.tap(find.byKey(const Key('onboarding.ageBand.40-59')));
    await tester.pumpAndSettle();
    btn = tester.widget<FilledButton>(find.byKey(const Key('onboarding.continue')));
    expect(btn.onPressed, isNotNull);
  });

  testWidgets('uçtan uca: beş adım tamamlanınca store.write DOĞRU profille çağrılır',
      (WidgetTester tester) async {
    final _FakeStore store = _FakeStore();
    bool done = false;
    await _pump(tester, store, () => done = true);

    await _continue(tester); // O1 → O2
    await tester.tap(find.byKey(const Key('onboarding.disclaimer.ack')));
    await tester.pumpAndSettle();
    await _continue(tester); // O2 → O3
    await _continue(tester); // O3 → O4
    await tester.tap(find.byKey(const Key('onboarding.ageBand.60plus')));
    await tester.pumpAndSettle();
    await tester.enterText(find.byKey(const Key('onboarding.painNotes')), 'knee, mild');
    await _continue(tester); // O4 → O5

    expect(find.textContaining('approximate picture of how you move'), findsOneWidget,
        reason: 'MeasurementLimitsFootnote.limitsCopy BİREBİR görünmeli');
    expect(find.text('Get started'), findsOneWidget,
        reason: 'son adımda buton etiketi "Continue" DEĞİL "Get started" olmalı');

    await _continue(tester); // O5 → bitiş

    expect(done, isTrue);
    expect(store.written, isNotNull);
    expect(store.written!.completed, isTrue);
    expect(store.written!.ageBand, '60plus');
    expect(store.written!.painNotes, 'knee, mild');
    expect(store.written!.gender, isNull,
        reason: 'boş bırakılan opsiyonel alan null KALMALI, boş string DEĞİL');
  });
}
