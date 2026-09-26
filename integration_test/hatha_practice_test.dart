import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:integration_test/integration_test.dart';
import 'package:lissom/app/app_facts.dart';
import 'package:lissom/app/hatha_course_screen.dart';
import 'package:lissom/app/hatha_progress.dart';
import 'package:lissom/app/lissom_theme.dart';
import 'package:lissom/app/local_account_bridge.dart';
import 'package:lissom/app/shell.dart';
import 'package:path_provider/path_provider.dart';

void main() {
  final IntegrationTestWidgetsFlutterBinding binding =
      IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets(
    'native course navigation, practice, reload and account deletion',
    (WidgetTester tester) async {
      GoogleFonts.config.allowRuntimeFetching = false;
      // The SDK image-surface capture stalls on the retained API 37 emulator.
      // Keep Android's native flow acceptance independent from that tool.
      final bool screenshots =
          const bool.fromEnvironment('HATHA_SCREENSHOTS') && Platform.isIOS;
      // An ephemeral local scope keeps real guest/account journals untouched.
      final String owner =
          'hatha-test-${DateTime.now().microsecondsSinceEpoch}';
      final LissomLocalScope scope = LissomLocalScope.account(owner);
      final Directory support = await getApplicationSupportDirectory();
      addTearDown(() => clearLissomLocalData(owner));

      Widget shell() => MaterialApp(
        theme: buildLissomTheme(),
        locale: const Locale('tr'),
        supportedLocales: const <Locale>[Locale('en'), Locale('tr')],
        localizationsDelegates: const <LocalizationsDelegate<dynamic>>[
          GlobalMaterialLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
        ],
        home: LissomShell(localScope: scope),
      );

      await tester.pumpWidget(shell());
      await tester.pumpAndSettle();
      final AppFacts facts = await AppFacts.load(scope: scope);
      final int total = facts.hatha!.lessons.length;
      if (screenshots) await binding.takeScreenshot('hatha-home-tr');
      await tester.tap(find.text('Hatha kursuna başla'));
      await tester.pumpAndSettle();
      expect(find.byType(HathaCourseScreen), findsOneWidget);
      expect(find.text('$total dersten 0 tanesi çalışıldı'), findsOneWidget);
      if (screenshots) await binding.takeScreenshot('hatha-course-tr');
      await tester.tap(find.byKey(HathaCourseScreen.continueKey));
      await tester.pumpAndSettle();
      expect(find.byType(HathaLessonScreen), findsOneWidget);
      if (screenshots) await binding.takeScreenshot('hatha-lesson-tr');

      await tester.scrollUntilVisible(
        find.byKey(HathaLessonScreen.reflectionKey),
        300,
        scrollable: find.byType(Scrollable).last,
      );
      await tester.tap(find.byKey(HathaLessonScreen.reflectionKey));
      await tester.pumpAndSettle();
      await tester.scrollUntilVisible(
        find.byKey(HathaLessonScreen.practiceKey),
        200,
        scrollable: find.byType(Scrollable).last,
      );
      await tester.tap(find.byKey(HathaLessonScreen.practiceKey));
      await tester.pumpAndSettle();
      expect(find.text('$total dersten 1 tanesi çalışıldı'), findsOneWidget);
      if (screenshots) await binding.takeScreenshot('hatha-progress-tr');

      final HathaProgressStore reopened = await openHathaProgressStore(
        scope: scope,
      );
      expect((await reopened.read()).practicedIn(facts.hatha!), <String>{
        'h01',
      });
      expect(
        await scope.file(support, LissomLocalFile.hathaProgress).exists(),
        isTrue,
      );

      // Destroy the shell and rebuild with the real app loader and file store.
      await tester.pumpWidget(const SizedBox.shrink());
      await tester.pumpAndSettle();
      await tester.pumpWidget(shell());
      await tester.pumpAndSettle();
      await tester.tap(find.text('Hatha kursuna devam et'));
      await tester.pumpAndSettle();
      expect(find.text('$total dersten 1 tanesi çalışıldı'), findsOneWidget);

      final LissomLocalScope other = LissomLocalScope.account('$owner-other');
      expect(
        (await (await openHathaProgressStore(scope: other)).read()).records,
        isEmpty,
      );
      await clearLissomLocalData(owner);
      await expectLater(
        reopened.markPracticed(facts.hatha!, 'h01'),
        throwsStateError,
      );
      expect(await scope.directory(support).exists(), isFalse);
      expect(tester.takeException(), isNull);
    },
  );
}
