import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lissom/app/onboarding_flow.dart';
import 'package:lissom/app/onboarding_store.dart';
import 'package:lissom/app/progress_screen.dart';
import 'package:lissom/app/home_screen.dart';
import 'package:lissom/app/live_capture_screen.dart';
import 'package:lissom/app/session_history_view.dart';
import 'package:lissom_engine/lissom_engine.dart';

import 'support/facts_from_disk.dart';
import 'support/narrow_surface.dart';

final class _MemoryOnboardingStore implements OnboardingStore {
  @override
  Future<OnboardingProfile> read() async =>
      const OnboardingProfile.notStarted();

  @override
  Future<void> write(OnboardingProfile profile) async {}
}

void main() {
  testWidgets('Turkish device locale reaches the first two onboarding steps', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        locale: const Locale('tr'),
        supportedLocales: const <Locale>[Locale('en'), Locale('tr')],
        localizationsDelegates: const <LocalizationsDelegate<dynamic>>[
          GlobalMaterialLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
        ],
        home: OnboardingFlow(
          store: _MemoryOnboardingStore(),
          onDone: (OnboardingProfile _) {},
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Lissom’a hoş geldin'), findsOneWidget);
    expect(find.text('Devam et'), findsOneWidget);

    await tester.tap(find.byKey(const Key('onboarding.continue')));
    await tester.pumpAndSettle();
    expect(find.text('DEVAM ETMEDEN ÖNCE'), findsOneWidget);
    expect(find.text('Anladım'), findsOneWidget);
  });

  testWidgets(
    'Turkish progress keeps the empty record and comparison limit distinct',
    (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          locale: const Locale('tr'),
          supportedLocales: const <Locale>[Locale('en'), Locale('tr')],
          localizationsDelegates: const <LocalizationsDelegate<dynamic>>[
            GlobalMaterialLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
          ],
          home: Scaffold(body: ProgressScreen(facts: factsFromDisk())),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Ölçüm kaydın'), findsOneWidget);
      expect(find.text('BURADA KARŞILAŞTIRMA YAPILMAZ'), findsOneWidget);
    },
  );

  testWidgets('Turkish camera failure names its current state', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        locale: const Locale('tr'),
        supportedLocales: const <Locale>[Locale('en'), Locale('tr')],
        localizationsDelegates: const <LocalizationsDelegate<dynamic>>[
          GlobalMaterialLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
        ],
        home: LiveCaptureScreen(
          test: batteryFromDisk().tests['overhead_reach']!,
          batteryVersion: 'test',
          sourceOverride: FakePoseSource(const <PoseSourceEvent>[
            SourceStateEvent(
              SetupFailed(code: 'noSuchCamera', userText: 'Camera unavailable'),
            ),
          ]),
        ),
      ),
    );
    await tester.pump();
    await tester.pump();

    expect(
      find.text('Kamera başlatılamadı. Yeniden dene.'),
      findsOneWidget,
    );
    expect(find.textContaining('noSuchCamera'), findsNothing);
    expect(find.text('Bu ekranda kamera görüntüsü yok'), findsOneWidget);
    expect(find.textContaining('Bu sürümde görüntü önizlemesi bulunmuyor'),
        findsOneWidget);
  });

  testWidgets('Turkish progress explains unavailable history without raw OS error',
      (WidgetTester tester) async {
    await tester.pumpWidget(
      MaterialApp(
        locale: const Locale('tr'),
        supportedLocales: const <Locale>[Locale('en'), Locale('tr')],
        localizationsDelegates: const <LocalizationsDelegate<dynamic>>[
          GlobalMaterialLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
        ],
        home: Scaffold(
          body: ProgressScreen(
            facts: factsFromDisk(
              history: const SessionHistoryView.unavailable(
                'FileSystemException: /private/history',
              ),
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
    await scrollTo(tester, find.byKey(ProgressScreen.unavailableKey));
    expect(find.textContaining('Geçmişin açılamadı'), findsOneWidget);
    expect(find.textContaining('Uygulamayı yeniden açıp'), findsOneWidget);
    expect(find.textContaining('FileSystemException'), findsNothing);
    expect(find.textContaining('/private/history'), findsNothing);
  });

  testWidgets('Turkish home history error keeps the next step readable',
      (WidgetTester tester) async {
    await tester.pumpWidget(
      MaterialApp(
        locale: const Locale('tr'),
        supportedLocales: const <Locale>[Locale('en'), Locale('tr')],
        localizationsDelegates: const <LocalizationsDelegate<dynamic>>[
          GlobalMaterialLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
        ],
        home: Scaffold(
          body: HomeScreen(
            facts: factsFromDisk(
              history: const SessionHistoryView.unavailable(
                'PathNotFoundException: /private/history',
              ),
            ),
            onOpenLibrary: () {},
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
    await scrollTo(tester, find.byKey(HomeScreen.retestKey));
    expect(find.textContaining('Ölçüm geçmişi açılamadı'), findsOneWidget);
    expect(find.textContaining('Uygulamayı yeniden açıp'), findsOneWidget);
    expect(find.textContaining('PathNotFoundException'), findsNothing);
  });
}
