/// Onboarding akışı — O1 Welcome → O2 Disclaimer(ZORUNLU) → O3 Camera-info →
/// O4 Profile(yaş bandı ZORUNLU) → O5 Measurement limits (SIRA①, 2026-08-12).
///
/// **Ölü-buton yasağı (home_screen.dart deseni):** her adımda "Continue"
/// gerçekten bir sonraki adıma geçmeli; O2/O4'te ZORUNLU alan boşken
/// düğme DEVRE DIŞI kalmalı — atlanabilir bir "zorunlu" alan, zorunlu
/// değildir.
library;

import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lissom/app/lissom_theme.dart';
import 'package:lissom/app/onboarding_flow.dart';
import 'package:lissom/app/onboarding_store.dart';
import 'package:lissom/app/profile_screen.dart';

import 'support/narrow_surface.dart';
import 'support/facts_from_disk.dart';

/// Bellek-içi sahte depo — gerçek dosya sistemine dokunmadan `write`
/// çağrısını GÖZLEMLENEBİLİR kılar.
final class _FakeStore implements OnboardingStore {
  OnboardingProfile? written;
  @override
  Future<OnboardingProfile> read() async => const OnboardingProfile.notStarted();
  @override
  Future<void> write(OnboardingProfile profile) async => written = profile;
}

Future<void> _pump(WidgetTester tester, OnboardingStore store, VoidCallback onDone,
    {bool measurementAvailable = false}) async {
  await tester.pumpWidget(MaterialApp(
    theme: buildLissomTheme(),
    home: OnboardingFlow(
      store: store,
      measurementAvailable: measurementAvailable,
      // `onDone` artık YAZILAN profili taşıyor (yaş bandı zinciri, L-280);
      // bu dosyanın iddiaları profile bakmıyor, o yüzden yutuluyor.
      onDone: (OnboardingProfile _) => onDone(),
    ),
  ));
  await tester.pumpAndSettle();
}

Future<void> _continue(WidgetTester tester) async {
  await tester.tap(find.byKey(const Key('onboarding.continue')));
  await tester.pumpAndSettle();
}

void main() {
  for (final language in ['en', 'tr']) {
    testWidgets(
      'current course and closed camera copy is visible in $language',
      (tester) async {
        Widget host(Widget child) => MaterialApp(
          locale: Locale(language),
          supportedLocales: const [Locale('en'), Locale('tr')],
          localizationsDelegates: const [
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          theme: buildLissomTheme(),
          home: child,
        );
        await tester.pumpWidget(
          host(
            OnboardingFlow(
              store: _FakeStore(),
              onDone: (_) {},
              onOpenAccount: () {},
            ),
          ),
        );
        await tester.pumpAndSettle();
        expect(
          find.textContaining(
            language == 'tr'
                ? 'Yazılı yoga kurslarını hesap veya kamera olmadan'
                : 'Study the written yoga courses without an account or camera',
          ),
          findsOneWidget,
        );
        expect(
          find.textContaining(
            language == 'tr'
                ? 'kamera ölçümleri ve abonelik satışı kapalıdır'
                : 'measurements and subscription sales are closed',
          ),
          findsWidgets,
        );
        expect(find.textContaining('uses your phone\'s camera'), findsNothing);
        expect(find.textContaining('üyeliği gerekir'), findsNothing);
        await _continue(tester);
        expect(
          find.textContaining(
            language == 'tr'
                ? 'Bu sürümde canlı kamera ölçümleri kapalıdır'
                : 'Live camera measurements are closed in this release',
          ),
          findsOneWidget,
        );
        await tester.pumpWidget(
          host(Scaffold(body: ProfileScreen(facts: factsFromDisk()))),
        );
        await tester.pumpAndSettle();
        expect(
          find.textContaining(
            language == 'tr'
                ? 'Yazılı yoga kursları kamera olmadan çalışır'
                : 'Written yoga courses work without a camera',
          ),
          findsOneWidget,
        );
        expect(
          find.textContaining(
            'The camera reads your movement while you measure',
          ),
          findsNothing,
        );
        expect(tester.takeException(), isNull);
      },
    );
  }
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

  testWidgets(
      'O3 — gerçek izin metni ("video never leaves this device"), '
      'düğme dokunulmadan Continue AKTİF kalır', (WidgetTester tester) async {
    final _FakeStore store = _FakeStore();
    await _pump(tester, store, () {}, measurementAvailable: true);
    await _continue(tester); // O1 → O2
    await tester.tap(find.byKey(const Key('onboarding.disclaimer.ack')));
    await tester.pumpAndSettle();
    await _continue(tester); // O2 → O3

    expect(find.textContaining('never leaves this device'), findsOneWidget,
        reason: 'CameraPoseSource bağlandı — O3 artık GERÇEK bir izin '
            'adımı, "bu build\'de yakalanamaz" DEĞİL (koordinatör şartı, '
            '2026-08-12)');
    expect(find.byKey(const Key('onboarding.camera.requestPermission')),
        findsOneWidget,
        reason: 'gerçek bir "izin iste" düğmesi olmalı — ölü buton değil');
    // İzin düğmesine BİLEREK dokunulmuyor: platform kanalı bu testte
    // mocklanmıyor (`Permission.camera.request()` gerçek bir OS çağrısı).
    // O4 kamera durumundan BAĞIMSIZ olduğu için (koordinatör onaylı),
    // Continue düğmeye dokunulmadan da aktif kalmalı.
    final FilledButton btn = tester
        .widget<FilledButton>(find.byKey(const Key('onboarding.continue')));
    expect(btn.onPressed, isNotNull);
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

    expect(find.textContaining('Choose your age range to continue'),
        findsOneWidget);

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

    // L-281: onboarding artık YALNIZ yaş bandı topluyor. `gender`/`painNotes`
    // girdileri KALDIRILDI — okuyucusu olmayan alan, okunuyormuş gibi
    // konuşamaz (`painNotes` ipucu bir VAATTİ). Şema alanları eski
    // profiller ayrıştırılabilsin diye duruyor; bu akış onlara DEĞER KOYMAZ.
    expect(store.written!.gender, isNull);
    expect(store.written!.painNotes, isNull);
  });

  testWidgets(
      'O4 artık gender/pain GİRDİSİ ÇİZMİYOR — kaldırılan yüzey geri '
      'sızarsa kırmızı (L-281)', (WidgetTester tester) async {
    pinNarrowSurface(tester);
    final _FakeStore store = _FakeStore();
    await _pump(tester, store, () {});

    await _continue(tester); // O1 → O2
    await tester.tap(find.byKey(const Key('onboarding.disclaimer.ack')));
    await tester.pumpAndSettle();
    await _continue(tester); // O2 → O3
    await _continue(tester); // O3 → O4

    // POZİTİF ÇAPA: gerçekten O4'teyiz — yoksa "girdi yok" vakum-doğru olur.
    expect(find.byKey(const Key('onboarding.ageBand.60plus')), findsOneWidget,
        reason: 'yaş bandı çipleri görünmüyorsa bu test O4\'ü ölçmüyor');

    expect(find.byKey(const Key('onboarding.gender')), findsNothing);
    expect(find.byKey(const Key('onboarding.painNotes')), findsNothing);
    expect(find.textContaining('Anything Lissom should know about'),
        findsNothing,
        reason: 'VAAT taşıyan ipucu — okuyucusu yokken sorulmamalı');
  });
}
