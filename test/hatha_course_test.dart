import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lissom/app/hatha_course.dart';
import 'package:lissom/app/hatha_course_screen.dart';
import 'package:lissom/app/hatha_progress.dart';
import 'package:lissom/app/ia.dart';
import 'package:lissom/app/library_screen.dart';
import 'package:lissom/app/lissom_theme.dart';
import 'package:lissom/app/local_account_bridge.dart';
import 'package:lissom/app/shell.dart';

import 'support/facts_from_disk.dart';
import 'support/narrow_surface.dart';

String _asset() => File('config/courses/hatha.v1.json').readAsStringSync();

final class _MemoryHathaProgressStore implements HathaProgressStore {
  final List<HathaPracticeRecord> records = <HathaPracticeRecord>[];

  @override
  Future<HathaProgress> read() async => HathaProgress(
    records: List<HathaPracticeRecord>.unmodifiable(records),
    unreadableRecords: 0,
  );

  @override
  Future<void> markPracticed(HathaCourse course, String lessonId) async {
    records.add(
      HathaPracticeRecord(
        lessonId: lessonId,
        courseId: course.id,
        courseVersion: course.version,
        practicedAt: DateTime.utc(2026, 9, 26),
      ),
    );
  }
}

void main() {
  test(
    'shipped Hatha path has bilingual complete lessons and self reports',
    () {
      final HathaCourse course = HathaCourse.parse(_asset());
      expect(course.modules.length, 10);
      expect(course.lessons.length, 60);
      expect(course.lessons.first.prerequisites, isEmpty);
      expect(course.lessons.last.id, 'h60');
      for (final HathaLesson lesson in course.lessons) {
        expect(lesson.steps.length, greaterThanOrEqualTo(4));
        expect(lesson.evidenceMode, HathaEvidenceMode.selfReport);
        expect(lesson.mediaBrief.tr, isNotEmpty);
        expect(lesson.sourceIds, isNotEmpty);
      }
    },
  );

  test('unsupported camera grades and skipped prerequisites fail closed', () {
    final Map<String, dynamic> content = (jsonDecode(_asset()) as Map)
        .cast<String, dynamic>();
    final Map<String, dynamic> first =
        content['modules'][0]['lessons'][0] as Map<String, dynamic>;
    first['evidenceMode'] = 'camera_scored';
    expect(() => HathaCourse.parse(jsonEncode(content)), throwsFormatException);
    first['evidenceMode'] = 'self_report';
    first['prerequisites'] = <String>['h42'];
    expect(() => HathaCourse.parse(jsonEncode(content)), throwsFormatException);
    first['prerequisites'] = <String>[];
    (first['steps'][0] as Map<String, dynamic>)['tr'] = '';
    expect(() => HathaCourse.parse(jsonEncode(content)), throwsFormatException);
  });

  test(
    'account-scoped practice survives reload and cannot skip a lesson',
    () async {
      final Directory root = await Directory.systemTemp.createTemp(
        'lissom-hatha-',
      );
      addTearDown(() => root.delete(recursive: true));
      final HathaCourse course = HathaCourse.parse(_asset());
      final LissomLocalScope a = LissomLocalScope.account('account-a');
      final LissomLocalScope b = LissomLocalScope.account('account-b');
      final JsonlHathaProgressStore storeA = JsonlHathaProgressStore(
        a.file(root, LissomLocalFile.hathaProgress),
      );
      final JsonlHathaProgressStore storeB = JsonlHathaProgressStore(
        b.file(root, LissomLocalFile.hathaProgress),
      );

      await expectLater(storeA.markPracticed(course, 'h03'), throwsStateError);
      await storeA.markPracticed(course, 'h01');
      await storeA.markPracticed(course, 'h01');
      final HathaProgress reopened = await JsonlHathaProgressStore(
        a.file(root, LissomLocalFile.hathaProgress),
      ).read();
      expect(reopened.records.length, 2);
      expect(reopened.practicedIn(course), <String>{'h01'});
      expect((await storeB.read()).records, isEmpty);

      final File file = a.file(root, LissomLocalFile.hathaProgress);
      await file.writeAsString('bad record\n', mode: FileMode.append);
      expect((await storeA.read()).unreadableRecords, 1);
    },
  );

  testWidgets('Hatha family opens course and records a first practice', (
    WidgetTester tester,
  ) async {
    final _MemoryHathaProgressStore store = _MemoryHathaProgressStore();
    final facts = factsFromDisk();
    final LibraryFamily yoga = facts.ia.families.singleWhere(
      (LibraryFamily family) => family.id == 'yoga_styles',
    );

    await tester.pumpWidget(
      MaterialApp(
        theme: buildLissomTheme(),
        home: FamilyPage(
          family: yoga,
          facts: facts,
          hathaStoreLoader: () async => store,
        ),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.textContaining('60 lessons'), findsOneWidget);
    await tester.tap(find.text('Open Hatha course'));
    await tester.pumpAndSettle();
    expect(find.byType(HathaCourseScreen), findsOneWidget);
    expect(find.text('0 of 60 lessons practised'), findsOneWidget);
    await tester.tap(find.byKey(HathaCourseScreen.continueKey));
    await tester.pumpAndSettle();
    expect(find.byType(HathaLessonScreen), findsOneWidget);
    await tester.scrollUntilVisible(
      find.byKey(HathaLessonScreen.reflectionKey),
      350,
      scrollable: find.byType(Scrollable).last,
    );
    await tester.tap(find.byKey(HathaLessonScreen.reflectionKey));
    await tester.pumpAndSettle();
    await tester.scrollUntilVisible(
      find.byKey(HathaLessonScreen.practiceKey),
      350,
      scrollable: find.byType(Scrollable).last,
    );
    await tester.tap(find.byKey(HathaLessonScreen.practiceKey));
    await tester.pumpAndSettle();
    expect(find.text('1 of 60 lessons practised'), findsOneWidget);
    expect((await store.read()).practicedIn(facts.hatha!), <String>{'h01'});
  });

  test(
    'parallel practice writes survive and deleted accounts cannot write again',
    () async {
      final Directory root = await Directory.systemTemp.createTemp(
        'lissom-course-guard-',
      );
      addTearDown(() => root.delete(recursive: true));
      final HathaCourse course = HathaCourse.parse(_asset());
      final LissomLocalScope scope = LissomLocalScope.account('course-account');
      final File file = scope.file(root, LissomLocalFile.hathaProgress);
      final JsonlHathaProgressStore a = JsonlHathaProgressStore(file);
      final JsonlHathaProgressStore b = JsonlHathaProgressStore(file);
      await Future.wait(<Future<void>>[
        for (int i = 0; i < 12; i++)
          (i.isEven ? a : b).markPracticed(course, 'h01'),
      ]);
      expect((await a.read()).records.length, 12);
      await clearLissomLocalData(
        'course-account',
        supportDirectory: () async => root,
      );
      await expectLater(a.markPracticed(course, 'h01'), throwsStateError);
      await expectLater(
        JsonlHathaProgressStore(file).markPracticed(course, 'h01'),
        throwsStateError,
      );
      expect(await scope.directory(root).exists(), isFalse);
    },
  );

  test('a store pinned to the prior identity rejects a new practice', () async {
    final Directory root = await Directory.systemTemp.createTemp(
      'lissom-course-identity-',
    );
    addTearDown(() => root.delete(recursive: true));
    final HathaCourse course = HathaCourse.parse(_asset());
    bool current = true;
    final JsonlHathaProgressStore store = JsonlHathaProgressStore(
      File('${root.path}/hatha.jsonl'),
      canWrite: () => current,
    );
    await store.markPracticed(course, 'h01');
    current = false;
    await expectLater(store.markPracticed(course, 'h02'), throwsStateError);
    expect((await store.read()).practicedIn(course), <String>{'h01'});
  });

  testWidgets('first home surface opens the bundled Hatha course', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: buildLissomTheme(),
        home: LissomShell(loader: () async => factsFromDisk()),
      ),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.text('Start Hatha course'));
    await tester.pumpAndSettle();
    expect(find.byType(HathaCourseScreen), findsOneWidget);
    expect(find.text('0 of 60 lessons practised'), findsOneWidget);
  });

  test('the complete course remains reachable and version isolated', () async {
    final Directory root = await Directory.systemTemp.createTemp(
      'hatha-capstone-',
    );
    addTearDown(() => root.delete(recursive: true));
    final HathaCourse course = HathaCourse.parse(_asset());
    final File file = File('${root.path}/practice.jsonl');
    final JsonlHathaProgressStore store = JsonlHathaProgressStore(file);
    for (final HathaLesson lesson in course.lessons) {
      await store.markPracticed(course, lesson.id);
    }
    final HathaProgress done = await JsonlHathaProgressStore(file).read();
    expect(
      done.practicedIn(course),
      course.lessons.map((lesson) => lesson.id).toSet(),
    );
    expect(done.practicedIn(course), contains('h60'));
    final Map<String, dynamic> next = (jsonDecode(_asset()) as Map)
        .cast<String, dynamic>();
    next['version'] = '2.0.0';
    final HathaCourse nextVersion = HathaCourse.parse(jsonEncode(next));
    expect(done.practicedIn(nextVersion), isEmpty);
    expect(done.oldVersionCount(nextVersion), 60);
    next['id'] = 'another.course';
    expect(done.practicedIn(HathaCourse.parse(jsonEncode(next))), isEmpty);
    expect(done.oldVersionCount(HathaCourse.parse(jsonEncode(next))), 0);
    await file.writeAsString('broken tail', mode: FileMode.append);
    await store.markPracticed(course, 'h60');
    final HathaProgress repaired = await store.read();
    expect(repaired.records.length, 61);
    expect(repaired.unreadableRecords, 1);
  });

  testWidgets('Turkish course and lesson fit 375px at double text size', (
    tester,
  ) async {
    pinNarrowSurface(tester);
    final HathaCourse course = HathaCourse.parse(_asset());
    final _MemoryHathaProgressStore store = _MemoryHathaProgressStore();
    await tester.pumpWidget(
      MaterialApp(
        theme: buildLissomTheme(),
        locale: const Locale('tr'),
        supportedLocales: const <Locale>[Locale('en'), Locale('tr')],
        localizationsDelegates: const <LocalizationsDelegate<dynamic>>[
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
        home: HathaCourseScreen(
          course: course,
          initialProgress: await store.read(),
          storeLoader: () async => store,
        ),
      ),
    );
    await tester.pumpAndSettle();
    await tester.scrollUntilVisible(
      find.byKey(HathaCourseScreen.continueKey),
      300,
    );
    await tester.tap(find.byKey(HathaCourseScreen.continueKey));
    await tester.pumpAndSettle();
    await tester.scrollUntilVisible(
      find.byKey(HathaLessonScreen.reflectionKey),
      300,
    );
    await tester.tap(find.byKey(HathaLessonScreen.reflectionKey));
    await tester.pumpAndSettle();
    await tester.scrollUntilVisible(
      find.byKey(HathaLessonScreen.practiceKey),
      200,
    );
    await tester.tap(find.byKey(HathaLessonScreen.practiceKey));
    await tester.pumpAndSettle();
    expect(store.records.length, 1);
    expect(tester.takeException(), isNull);
  });
}
