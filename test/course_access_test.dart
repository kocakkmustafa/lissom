import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lissom/app/course_access.dart';
import 'package:lissom/app/hatha_course.dart';
import 'package:lissom/app/hatha_course_screen.dart';
import 'package:lissom/app/hatha_progress.dart';
import 'package:lissom/app/lissom_theme.dart';

import 'support/narrow_surface.dart';

const Map<String, String> _files = <String, String>{
  'lissom.hatha.foundations': 'hatha',
  'lissom.chair-office.beginner': 'chair-office',
  'lissom.vinyasa.supported-standing.beginner': 'vinyasa-standing',
  'lissom.yin.supported.beginner': 'yin-supported',
  'lissom.ashtanga.foundations.beginner': 'ashtanga-foundations',
};

HathaCourse _course(String file) =>
    HathaCourse.parse(File('config/courses/$file.v1.json').readAsStringSync());

class _Store implements HathaProgressStore {
  _Store([List<HathaPracticeRecord>? records])
    : records = records ?? <HathaPracticeRecord>[];
  final List<HathaPracticeRecord> records;

  @override
  Future<HathaProgress> read() async =>
      HathaProgress(records: List.unmodifiable(records), unreadableRecords: 0);

  @override
  Future<void> markPracticed(HathaCourse course, String lessonId) async =>
      records.add(_record(course, lessonId));

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

HathaPracticeRecord _record(HathaCourse course, String lessonId) =>
    HathaPracticeRecord(
      lessonId: lessonId,
      courseId: course.id,
      courseVersion: course.version,
      practicedAt: DateTime.utc(2026, 10, 23, 12),
    );

Future<void> _pump(
  WidgetTester tester,
  HathaCourse course,
  _Store store, {
  required Future<bool> Function(BuildContext)? gate,
}) async {
  pinTallSurface(tester, height: 9000);
  await tester.pumpWidget(
    MaterialApp(
      supportedLocales: const <Locale>[Locale('en'), Locale('tr')],
      localizationsDelegates: GlobalMaterialLocalizations.delegates,
      theme: buildLissomTheme(),
      builder: (BuildContext context, Widget? child) =>
          LissomCourseAccess(ensureAccess: gate, child: child!),
      home: HathaCourseScreen(
        course: course,
        initialProgress: await store.read(),
        storeLoader: () async => store,
      ),
    ),
  );
  await tester.pumpAndSettle();
}

Finder _lessonTile(HathaCourse course, String id) =>
    find.widgetWithText(ListTile, course.lessonById(id)!.title.en);

void main() {
  test('free part = shortest whole-module prefix covering >= 1/3', () {
    const Map<String, int> expectedFree = <String, int>{
      'lissom.hatha.foundations': 24,
      'lissom.chair-office.beginner': 6,
      'lissom.vinyasa.supported-standing.beginner': 5,
      'lissom.yin.supported.beginner': 5,
      'lissom.ashtanga.foundations.beginner': 7,
    };
    expect(kFreeModuleIds.keys.toSet(), _files.keys.toSet());
    for (final MapEntry<String, String> e in _files.entries) {
      final HathaCourse course = _course(e.value);
      expect(course.id, e.key);
      final int total = course.lessons.length;
      final Set<String> prefix = <String>{};
      int covered = 0;
      for (final HathaModule m in course.modules) {
        prefix.add(m.id);
        covered += m.lessons.length;
        if (covered * 3 >= total) break;
      }
      expect(kFreeModuleIds[course.id], prefix, reason: course.id);
      expect(freeLessonCount(course), expectedFree[course.id]);
      expect(freeLessonCount(course) * 3, greaterThanOrEqualTo(total));
      // The independent/extension module at the end is always paid.
      expect(
        course.modules.last.lessons.every(
          (HathaLesson l) => !isFreeLesson(course, l.id),
        ),
        isTrue,
        reason: course.id,
      );
    }
  });

  test('unknown course and unknown lesson are not free', () {
    final HathaCourse vinyasa = _course('vinyasa-standing');
    expect(isFreeLesson(vinyasa, 'v01'), isTrue);
    expect(isFreeLesson(vinyasa, 'v06'), isFalse);
    expect(isFreeLesson(vinyasa, 'nope'), isFalse);
  });

  testWidgets('free lesson opens without the gate; paid lesson asks once', (
    WidgetTester tester,
  ) async {
    final HathaCourse course = _course('vinyasa-standing');
    int gateCalls = 0;
    bool allow = false;
    await _pump(
      tester,
      course,
      _Store(),
      gate: (_) async {
        gateCalls++;
        return allow;
      },
    );
    expect(find.byKey(HathaCourseScreen.accessNoteKey), findsOneWidget);
    expect(
      find.textContaining('The first 5 of 14 lessons are free.'),
      findsOneWidget,
    );

    await tester.tap(_lessonTile(course, 'v01'));
    await tester.pumpAndSettle();
    expect(find.byType(HathaLessonScreen), findsOneWidget);
    expect(gateCalls, 0);
    await tester.pageBack();
    await tester.pumpAndSettle();

    // Declined or cancelled purchase: the paid lesson does not open.
    await tester.tap(_lessonTile(course, 'v06'));
    await tester.pumpAndSettle();
    expect(find.byType(HathaLessonScreen), findsNothing);
    expect(gateCalls, 1);
    expect(find.byKey(HathaCourseScreen.subscriptionClosedKey), findsNothing);

    // Active membership (purchase or restore): opens and is remembered.
    allow = true;
    await tester.tap(_lessonTile(course, 'v06'));
    await tester.pumpAndSettle();
    expect(find.byType(HathaLessonScreen), findsOneWidget);
    expect(gateCalls, 2);
    await tester.pageBack();
    await tester.pumpAndSettle();
    expect(find.byKey(HathaCourseScreen.accessNoteKey), findsNothing);
    await tester.tap(_lessonTile(course, 'v14'));
    await tester.pumpAndSettle();
    expect(find.byType(HathaLessonScreen), findsOneWidget);
    expect(gateCalls, 2);
  });

  testWidgets('without an account service paid lessons stay closed', (
    WidgetTester tester,
  ) async {
    final HathaCourse course = _course('yin-supported');
    await _pump(tester, course, _Store(), gate: null);
    await tester.tap(_lessonTile(course, 'y09'));
    await tester.pumpAndSettle();
    expect(find.byType(HathaLessonScreen), findsNothing);
    expect(find.byKey(HathaCourseScreen.subscriptionClosedKey), findsOneWidget);
    await tester.tap(_lessonTile(course, 'y01'));
    await tester.pumpAndSettle();
    expect(find.byType(HathaLessonScreen), findsOneWidget);
  });

  testWidgets('records of paid lessons stay readable while locked', (
    WidgetTester tester,
  ) async {
    final HathaCourse course = _course('ashtanga-foundations');
    final _Store store = _Store(<HathaPracticeRecord>[
      for (final HathaLesson l in course.lessons.take(9)) _record(course, l.id),
    ]);
    await _pump(tester, course, store, gate: (_) async => false);
    // a08/a09 are paid (third module) but practised: counted and checked.
    expect(
      find.textContaining('9 participation records across 19 units'),
      findsOneWidget,
    );
    final ListTile a09 = tester.widget<ListTile>(_lessonTile(course, 'a09'));
    expect((a09.leading! as Icon).icon, Icons.check_circle_outline);
    final ListTile a10 = tester.widget<ListTile>(_lessonTile(course, 'a10'));
    expect((a10.leading! as Icon).icon, Icons.workspace_premium_outlined);
    expect(
      find.descendant(
        of: _lessonTile(course, 'a10'),
        matching: find.textContaining('Included with a Lissom or Motion+'),
      ),
      findsOneWidget,
    );
    expect(store.records, hasLength(9));
  });
}
