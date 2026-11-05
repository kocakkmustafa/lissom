import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lissom/app/course_access.dart';
import 'package:lissom/app/hatha_beginner_path.dart';
import 'package:lissom/app/hatha_course.dart';
import 'package:lissom/app/hatha_course_screen.dart';
import 'package:lissom/app/hatha_progress.dart';
import 'package:lissom/app/ia.dart';
import 'package:lissom/app/library_screen.dart';
import 'package:lissom/app/lissom_theme.dart';

import 'support/facts_from_disk.dart';

HathaCourse _hatha() =>
    HathaCourse.parse(File('config/courses/hatha.v1.json').readAsStringSync());

final class _MemoryStore implements HathaProgressStore {
  _MemoryStore(this.records);

  final List<HathaPracticeRecord> records;

  @override
  Future<HathaProgress> read() async => HathaProgress(
    records: List<HathaPracticeRecord>.unmodifiable(records),
    unreadableRecords: 0,
  );

  @override
  Future<void> markPracticed(HathaCourse course, String lessonId) async {}
}

List<HathaPracticeRecord> _practised(
  HathaCourse course,
  Iterable<String> ids,
) => <HathaPracticeRecord>[
  for (final String id in ids)
    HathaPracticeRecord(
      lessonId: id,
      courseId: course.id,
      courseVersion: course.version,
      practicedAt: DateTime.utc(2026, 11, 6),
    ),
];

Widget _app(Widget home, {String language = 'en'}) => MaterialApp(
  theme: buildLissomTheme(),
  locale: Locale(language),
  supportedLocales: const <Locale>[Locale('en'), Locale('tr')],
  localizationsDelegates: const <LocalizationsDelegate<dynamic>>[
    GlobalMaterialLocalizations.delegate,
    GlobalCupertinoLocalizations.delegate,
    GlobalWidgetsLocalizations.delegate,
  ],
  home: home,
);

void main() {
  test('path is the consecutive Hatha opening h01-h10 and all exist', () {
    final HathaCourse course = _hatha();
    expect(hathaBeginnerPathLessonIds, <String>[
      for (int i = 1; i <= 10; i++) 'h${i.toString().padLeft(2, '0')}',
    ]);
    expect(hathaBeginnerPathAvailable(course), isTrue);
    expect(
      hathaBeginnerPathLessons(course).map((HathaLesson l) => l.id).toList(),
      hathaBeginnerPathLessonIds,
    );
    // arrival h01-h06 + standing h07-h10, taken from the real modules.
    expect(course.modules[0].id, 'arrival');
    expect(course.modules[1].id, 'standing');
    expect(
      course.modules[0].lessons.map((HathaLesson l) => l.id),
      hathaBeginnerPathLessonIds.sublist(0, 6),
    );
    expect(
      course.modules[1].lessons.map((HathaLesson l) => l.id).take(4),
      hathaBeginnerPathLessonIds.sublist(6),
    );
    expect(course.lessonById(hathaBeginnerPathNextLessonId), isNotNull);
  });

  test('every path prerequisite is inside the path or absent', () {
    final HathaCourse course = _hatha();
    for (final HathaLesson lesson in hathaBeginnerPathLessons(course)) {
      for (final String pre in lesson.prerequisites) {
        expect(hathaBeginnerPathLessonIds, contains(pre), reason: lesson.id);
      }
    }
    // h01 is the root; the path is therefore openable by a brand-new user.
    expect(course.lessonById('h01')!.prerequisites, isEmpty);
  });

  test(
    'a fresh user can practise all 10 in order, none out of order',
    () async {
      final HathaCourse course = _hatha();
      final Directory dir = await Directory.systemTemp.createTemp(
        'lissom-path-',
      );
      addTearDown(() => dir.delete(recursive: true));
      final JsonlHathaProgressStore store = JsonlHathaProgressStore(
        File('${dir.path}/practice.jsonl'),
      );
      // Hatha's own prerequisite rule still holds: no skipping ahead.
      await expectLater(store.markPracticed(course, 'h05'), throwsStateError);
      for (final String id in hathaBeginnerPathLessonIds) {
        await store.markPracticed(course, id);
      }
      final HathaProgress progress = await store.read();
      expect(
        progress.practicedIn(course),
        hathaBeginnerPathLessonIds.toSet(),
        reason: '10/10 recorded against the Hatha course id/version',
      );
      expect(
        progress.records.map((HathaPracticeRecord r) => r.courseId).toSet(),
        {course.id},
      );
    },
  );

  test('the path adds no access gate: Hatha rule decides, all 10 are free', () {
    final HathaCourse course = _hatha();
    for (final String id in hathaBeginnerPathLessonIds) {
      expect(isFreeLesson(course, id), isTrue, reason: id);
    }
  });

  testWidgets('path screen reads Hatha records and shares them with Hatha', (
    tester,
  ) async {
    final HathaCourse course = _hatha();
    final _MemoryStore store = _MemoryStore(
      _practised(course, hathaBeginnerPathLessonIds.take(9)),
    );
    await tester.pumpWidget(
      _app(
        HathaCourseScreen(
          course: course,
          initialProgress: await store.read(),
          storeLoader: () async => store,
          pathLessonIds: hathaBeginnerPathLessonIds,
        ),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.text('Beginner path'), findsOneWidget);
    expect(find.text('9 of 10 lessons practised'), findsOneWidget);
    // Next lesson is h10, taken from Hatha records the path never wrote.
    expect(find.textContaining('Tree with a wall'), findsWidgets);
    // Only path lessons are listed: h11 is not on this screen.
    expect(find.text('Gentle forward fold'), findsNothing);
    expect(find.byKey(HathaCourseScreen.pathContinueHintKey), findsNothing);

    // The full Hatha screen over the same store sees the same 9 records.
    await tester.pumpWidget(
      _app(
        HathaCourseScreen(
          course: course,
          initialProgress: await store.read(),
          storeLoader: () async => store,
        ),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.text('9 of 60 lessons practised'), findsOneWidget);
  });

  testWidgets('finishing the path points at Hatha h11', (tester) async {
    final HathaCourse course = _hatha();
    final _MemoryStore store = _MemoryStore(
      _practised(course, hathaBeginnerPathLessonIds),
    );
    await tester.pumpWidget(
      _app(
        HathaCourseScreen(
          course: course,
          initialProgress: await store.read(),
          storeLoader: () async => store,
          pathLessonIds: hathaBeginnerPathLessonIds,
        ),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.text('10 of 10 lessons practised'), findsOneWidget);
    expect(find.byKey(HathaCourseScreen.continueKey), findsNothing);
    final Text hint = tester.widget<Text>(
      find.byKey(HathaCourseScreen.pathContinueHintKey),
    );
    expect(
      hint.data,
      'You finished the Beginner path. Continue the Hatha course with: '
      'Gentle forward fold',
    );
  });

  testWidgets('library offers Beginner path before Hatha and opens the path', (
    tester,
  ) async {
    // Tall surface so the lazy list builds both cards.
    tester.view.physicalSize = const Size(900, 5000);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    final facts = factsFromDisk();
    final HathaCourse course = facts.hatha!;
    final _MemoryStore store = _MemoryStore(<HathaPracticeRecord>[]);
    final LibraryFamily family = facts.ia.families.singleWhere(
      (LibraryFamily f) => f.id == 'yoga_styles',
    );
    await tester.pumpWidget(
      _app(
        FamilyPage(
          family: family,
          facts: facts,
          hathaStoreLoader: () async => store,
        ),
      ),
    );
    await tester.pumpAndSettle();
    final Finder beginner = find.byKey(const Key('library.beginnerPath'));
    expect(beginner, findsOneWidget);
    expect(find.text('Open Hatha course'), findsOneWidget);
    expect(
      tester.getTopLeft(beginner).dy,
      lessThan(tester.getTopLeft(find.text('Open Hatha course')).dy),
      reason: 'Beginner entry sits in front of the Hatha card',
    );
    await tester.ensureVisible(find.text('Open Beginner path'));
    await tester.tap(find.text('Open Beginner path'));
    await tester.pumpAndSettle();
    final HathaCourseScreen screen = tester.widget<HathaCourseScreen>(
      find.byType(HathaCourseScreen),
    );
    expect(screen.course.id, course.id, reason: 'not a derived course');
    expect(screen.course.lessons.length, course.lessons.length);
    expect(screen.pathLessonIds, hathaBeginnerPathLessonIds);
    expect(tester.takeException(), isNull);
  });
}
