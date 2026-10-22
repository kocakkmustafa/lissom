// Host accessibility smoke: Flutter's own screen-reader/tap-target/contrast
// guidelines over the four tabs, the course list of every bundled course and
// the first lesson of each 2026-10-21 extension module. This is a host proxy
// for VoiceOver/TalkBack; it is not a real-device screen-reader acceptance.
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lissom/app/hatha_course.dart';
import 'package:lissom/app/hatha_course_screen.dart';
import 'package:lissom/app/hatha_progress.dart';
import 'package:lissom/app/hatha_session_preparation.dart';
import 'package:lissom/app/home_screen.dart';
import 'package:lissom/app/library_screen.dart';
import 'package:lissom/app/lissom_theme.dart';
import 'package:lissom/app/profile_screen.dart';
import 'package:lissom/app/progress_screen.dart';

import 'support/facts_from_disk.dart';
import 'support/narrow_surface.dart';

class _Store implements HathaProgressStore {
  _Store(this.records);
  final List<HathaPracticeRecord> records;

  @override
  Future<HathaProgress> read() async =>
      HathaProgress(records: List.unmodifiable(records), unreadableRecords: 0);

  @override
  Future<void> markPracticed(HathaCourse course, String lessonId) async {
    records.add(_record(course, lessonId));
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

HathaPracticeRecord _record(HathaCourse course, String lessonId) =>
    HathaPracticeRecord(
      lessonId: lessonId,
      courseId: course.id,
      courseVersion: course.version,
      practicedAt: DateTime.utc(2026, 10, 21, 12),
    );

HathaCourse _course(String name) =>
    HathaCourse.parse(File('config/courses/$name.v1.json').readAsStringSync());

Future<void> _pump(WidgetTester tester, Widget home, String language) async {
  await tester.pumpWidget(
    MaterialApp(
      locale: Locale(language),
      supportedLocales: const <Locale>[Locale('en'), Locale('tr')],
      localizationsDelegates: GlobalMaterialLocalizations.delegates,
      theme: buildLissomTheme(),
      home: home is Scaffold ? home : Scaffold(body: home),
    ),
  );
  await tester.pumpAndSettle();
}

Future<void> _expectGuidelines(WidgetTester tester) async {
  await expectLater(tester, meetsGuideline(labeledTapTargetGuideline));
  await expectLater(tester, meetsGuideline(androidTapTargetGuideline));
  await expectLater(tester, meetsGuideline(iOSTapTargetGuideline));
  await expectLater(tester, meetsGuideline(textContrastGuideline));
}

void main() {
  testWidgets('NEGATIVE TWIN: an unlabelled 10x10 tap target fails', (
    WidgetTester tester,
  ) async {
    final SemanticsHandle semantics = tester.ensureSemantics();
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Center(
            child: GestureDetector(
              onTap: () {},
              child: const SizedBox(width: 10, height: 10),
            ),
          ),
        ),
      ),
    );
    // Evaluate directly: an async guideline matcher cannot be wrapped in isNot.
    final Evaluation size = await androidTapTargetGuideline.evaluate(tester);
    final Evaluation label = await labeledTapTargetGuideline.evaluate(tester);
    expect(size.passed, isFalse, reason: size.reason);
    expect(label.passed, isFalse, reason: label.reason);
    semantics.dispose();
  });

  for (final String language in const <String>['en', 'tr']) {
    testWidgets('four tabs meet screen-reader, tap-target and contrast '
        'guidelines ($language)', (WidgetTester tester) async {
      final SemanticsHandle semantics = tester.ensureSemantics();
      pinNarrowSurface(tester);
      final facts = factsFromDisk();
      for (final Widget screen in <Widget>[
        HomeScreen(facts: facts, onOpenLibrary: () {}),
        LibraryScreen(facts: facts),
        ProgressScreen(facts: facts),
        ProfileScreen(facts: facts),
      ]) {
        await _pump(tester, screen, language);
        await _expectGuidelines(tester);
      }
      semantics.dispose();
    });

    // Course list for every bundled course, then the first lesson of each new
    // extension module opened through "continue" (prerequisites recorded).
    for (final (String name, String lessonId) in const <(String, String)>[
      ('hatha', 'h01'),
      ('chair-office', 'c13'),
      ('vinyasa-standing', 'v11'),
      ('yin-supported', 'y09'),
      ('ashtanga-foundations', 'a15'),
    ]) {
      testWidgets('$name course list and $lessonId meet guidelines '
          '($language)', (WidgetTester tester) async {
        final SemanticsHandle semantics = tester.ensureSemantics();
        pinNarrowSurface(tester);
        final HathaCourse course = _course(name);
        final _Store store = _Store(<HathaPracticeRecord>[
          for (final HathaLesson lesson in course.lessons.takeWhile(
            (HathaLesson l) => l.id != lessonId,
          ))
            _record(course, lesson.id),
        ]);
        await _pump(
          tester,
          HathaCourseScreen(
            course: course,
            initialProgress: await store.read(),
            storeLoader: () async => store,
          ),
          language,
        );
        await _expectGuidelines(tester);
        await tester.tap(find.byKey(HathaCourseScreen.continueKey));
        await tester.pumpAndSettle();
        final HathaLessonScreen screen = tester.widget<HathaLessonScreen>(
          find.byType(HathaLessonScreen),
        );
        expect(screen.lesson.id, lessonId);
        if (HathaSessionPreparation.requiredFor(lessonId)) {
          expect(
            find.byKey(const Key('hatha.session.preparation')),
            findsOneWidget,
          );
        }
        await _expectGuidelines(tester);
        semantics.dispose();
      });
    }
  }
}
