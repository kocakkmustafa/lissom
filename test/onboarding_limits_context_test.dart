import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lissom/app/lissom_theme.dart';
import 'package:lissom/app/onboarding_flow.dart';
import 'package:lissom/app/onboarding_store.dart';

class _Store implements OnboardingStore {
  @override
  Future<OnboardingProfile> read() async =>
      const OnboardingProfile.notStarted();
  @override
  Future<void> write(OnboardingProfile p) async {}
}

void main() {
  for (final language in ['en', 'tr']) {
    for (final available in [false, true]) {
      testWidgets(
        'STEP5 explains conditional camera capability $available ($language)',
        (tester) async {
          await tester.binding.setSurfaceSize(const Size(375, 812));
          addTearDown(() => tester.binding.setSurfaceSize(null));
          await tester.pumpWidget(
            MaterialApp(
              locale: Locale(language),
              supportedLocales: const [Locale('en'), Locale('tr')],
              localizationsDelegates: GlobalMaterialLocalizations.delegates,
              theme: buildLissomTheme(),
              home: OnboardingFlow(
                store: _Store(),
                onDone: (_) {},
                measurementAvailable: available,
              ),
            ),
          );
          await tester.pumpAndSettle();
          Future<void> next() async {
            await tester.tap(find.byKey(const Key('onboarding.continue')));
            await tester.pumpAndSettle();
          }

          await next();
          await tester.tap(find.byKey(const Key('onboarding.disclaimer.ack')));
          await tester.pumpAndSettle();
          final int total = available ? 5 : 4;
          String step(int n) => language == 'tr'
              ? '$total ADIMIN $n. ADIMI'
              : 'STEP $n OF $total';
          await next();
          expect(find.text(step(3)), findsOneWidget); // kamera (5) / profil (4)
          if (available) {
            await next(); // kamera adımı → profil; izin düğmesine basılmadı
            expect(find.text(step(4)), findsOneWidget);
          }
          await tester.tap(find.byKey(const Key('onboarding.ageBand.u40')));
          await tester.pumpAndSettle();
          await next();
          expect(find.text(step(total)), findsOneWidget);
          final context = find.textContaining(
            language == 'tr'
                ? 'Bu sınırlar, kamera ölçümü alındığında'
                : 'These limits describe the measurement engine when a camera reading is taken',
          );
          expect(context, findsOneWidget);
          final copy = tester.widget<Text>(context).data!;
          final closed = language == 'tr'
              ? 'Bu sürümde canlı kamera ölçümleri kapalıdır.'
              : 'Live camera measurements are closed in this release.';
          if (available) {
            expect(copy, isNot(contains(closed)));
            expect(
              copy,
              contains(
                language == 'tr'
                    ? 'Desteklenen testlerde'
                    : 'for supported tests',
              ),
            );
          } else {
            expect(copy, contains(closed));
          }
          expect(tester.takeException(), isNull);
        },
      );
    }
  }
}
