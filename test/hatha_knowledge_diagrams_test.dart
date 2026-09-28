import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lissom/app/hatha_course.dart';
import 'package:lissom/app/hatha_course_screen.dart';
import 'package:lissom/app/hatha_knowledge_diagrams.dart';
import 'package:lissom/app/hatha_progress.dart';
import 'package:lissom/app/lissom_theme.dart';

void main() {
  test('knowledge drawings do not replace the physical preparation lesson', () {
    expect(HathaKnowledgeDiagrams.supports('h27'), isFalse);
    expect(HathaKnowledgeDiagrams.supports('unknown'), isFalse);
    for (final id in ['h54', 'h55', 'h56']) {
      expect(HathaKnowledgeDiagrams.supports(id), isTrue);
    }
  });

  for (final language in ['en', 'tr']) {
    for (final id in ['h54', 'h55', 'h56']) {
      testWidgets(
        'actual $id diagram at 320px/200percent $language is knowledge only and saves nothing',
        (tester) async {
          tester.view.physicalSize = const Size(320, 812);
          tester.view.devicePixelRatio = 1;
          addTearDown(tester.view.reset);
          final root = Directory.systemTemp.createTempSync(
            'hatha-diagram-view-',
          );
          addTearDown(() => root.deleteSync(recursive: true));
          final file = File('${root.path}/progress.jsonl');
          final course = HathaCourse.parse(
            File('config/courses/hatha.v1.json').readAsStringSync(),
          );
          await tester.pumpWidget(
            MaterialApp(
              theme: buildLissomTheme(),
              locale: Locale(language),
              supportedLocales: const [Locale('en'), Locale('tr')],
              localizationsDelegates: const [
                GlobalMaterialLocalizations.delegate,
                GlobalCupertinoLocalizations.delegate,
                GlobalWidgetsLocalizations.delegate,
              ],
              builder: (context, child) => MediaQuery(
                data: MediaQuery.of(
                  context,
                ).copyWith(textScaler: const TextScaler.linear(2)),
                child: child!,
              ),
              home: HathaLessonScreen(
                course: course,
                lesson: course.lessonById(id)!,
                store: JsonlHathaProgressStore(file),
                isRepeat: false,
              ),
            ),
          );
          await tester.pumpAndSettle();
          if (id != 'h55') {
            expect(
              find.byKey(const Key('hatha.session.preparation')),
              findsOneWidget,
            );
            expect(find.byKey(HathaLessonScreen.practiceKey), findsNothing);
            await Scrollable.ensureVisible(
              tester.element(find.byKey(const Key('hatha.session.readOnly'))),
              alignment: 0.5,
            );
            await tester.pumpAndSettle();
            await tester.tap(find.byKey(const Key('hatha.session.readOnly')));
            await tester.pumpAndSettle();
            expect(find.byKey(HathaLessonScreen.practiceKey), findsNothing);
          }
          await tester.scrollUntilVisible(
            find.byKey(Key('hatha-diagrams-$id')),
            300,
            scrollable: find.byType(Scrollable).first,
            maxScrolls: 80,
          );
          await tester.pump();
          expect(find.byType(HathaKnowledgeDiagrams), findsOneWidget);
          expect(
            find.textContaining(
              language == 'tr'
                  ? 'Yalnız bilgi için. Bu duruşları taklit etme.'
                  : 'Knowledge only. Do not copy these poses.',
            ),
            findsOneWidget,
          );
          expect(tester.takeException(), isNull);
          expect(file.existsSync(), isFalse);
          await tester.pumpWidget(const SizedBox.shrink());
        },
      );
    }
  }
}
