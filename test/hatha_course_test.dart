import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lissom/app/hatha_course.dart';
import 'package:lissom/app/hatha_course_screen.dart';
import 'package:lissom/app/hatha_progress.dart';
import 'package:lissom/app/hatha_session_preparation.dart';
import 'package:lissom/app/ia.dart';
import 'package:lissom/app/library_screen.dart';
import 'package:lissom/app/lissom_theme.dart';
import 'package:lissom/app/local_account_bridge.dart';
import 'package:lissom/app/shell.dart';

import 'support/facts_from_disk.dart';
import 'support/narrow_surface.dart';

// Independent reviewed display literal: EN-TR-FINAL-40 ASQ-02.
// Keep the immutable raw-copy guard and also forbid the actual clarified step.
const String _reviewedH59RehearsalEnglish =
    "Rehearse once only a transition taught in an earlier lesson whose entry, "
    "support and exit you know and have used comfortably. Do not physically "
    "test a first-time or unresolved transition: keep it on paper, replace it "
    "with a familiar taught route or observation, then revise the plan before "
    "h60.";

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
  test('session bridge scopes physical lessons without gating knowledge', () {
    expect(HathaSessionPreparation.requiredFor('h03'), isTrue);
    expect(HathaSessionPreparation.requiredFor('h44'), isTrue);
    expect(HathaSessionPreparation.requiredFor('h54'), isTrue);
    expect(HathaSessionPreparation.requiredFor('h56'), isTrue);
    expect(HathaSessionPreparation.requiredFor('h57'), isTrue);
    expect(HathaSessionPreparation.requiredFor('h59'), isTrue);
    expect(HathaSessionPreparation.requiredFor('h60'), isTrue);
    for (final String id in <String>['h05', 'h06', 'h31', 'h55']) {
      expect(HathaSessionPreparation.requiredFor(id), isFalse, reason: id);
    }
    DateTime now = DateTime(2026, 9, 28, 20);
    final HathaSessionPreparation preparation = HathaSessionPreparation(
      now: () => now,
    );
    preparation.acknowledge();
    expect(preparation.acknowledged, isTrue);
    now = DateTime(2026, 9, 29, 8);
    expect(preparation.acknowledged, isFalse);
    preparation.acknowledge();
    preparation.reset();
    expect(preparation.acknowledged, isFalse);
  });

  testWidgets(
    'yesterday progress opens h44 through fresh preparation without false practice',
    (tester) async {
      final HathaCourse course = HathaCourse.parse(_asset());
      final _MemoryHathaProgressStore store = _MemoryHathaProgressStore();
      final DateTime yesterday = DateTime.now().subtract(
        const Duration(days: 1),
      );
      for (final HathaLesson lesson in course.lessons.take(43)) {
        store.records.add(
          HathaPracticeRecord(
            lessonId: lesson.id,
            courseId: course.id,
            courseVersion: course.version,
            practicedAt: yesterday,
          ),
        );
      }
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
          home: HathaCourseScreen(
            course: course,
            initialProgress: await store.read(),
            storeLoader: () async => store,
          ),
        ),
      );
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(HathaCourseScreen.continueKey));
      await tester.pumpAndSettle();
      expect(
        find.byKey(const Key('hatha.session.preparation')),
        findsOneWidget,
      );
      expect(find.byKey(HathaLessonScreen.practiceKey), findsNothing);
      expect(find.text('ÖĞREN'), findsNothing);
      expect(store.records.length, 43);

      await tester.tap(find.byKey(const Key('hatha.session.readOnly')));
      await tester.pumpAndSettle();
      expect(find.byKey(HathaLessonScreen.practiceKey), findsNothing);
      expect(find.text('ÖĞREN'), findsNothing);
      await tester.tap(
        find.byKey(const Key('hatha.session.prepareToPractice')),
      );
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const Key('hatha.session.prepared')));
      await tester.pumpAndSettle();
      expect(find.byKey(const Key('hatha.session.preparation')), findsNothing);
      await tester.scrollUntilVisible(
        find.byKey(HathaLessonScreen.reflectionKey),
        300,
        scrollable: find.byType(Scrollable).last,
      );
      await Scrollable.ensureVisible(
        tester.element(find.byKey(HathaLessonScreen.reflectionKey)),
        alignment: 0.5,
      );
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(HathaLessonScreen.reflectionKey));
      await tester.pumpAndSettle();
      await tester.scrollUntilVisible(
        find.byKey(HathaLessonScreen.practiceKey),
        200,
        scrollable: find.byType(Scrollable).last,
      );
      expect(
        tester
            .widget<FilledButton>(find.byKey(HathaLessonScreen.practiceKey))
            .onPressed,
        isNotNull,
      );
      await tester.scrollUntilVisible(
        find.byKey(const Key('hatha.session.restart')),
        -250,
        scrollable: find.byType(Scrollable).last,
      );
      await tester.tap(find.byKey(const Key('hatha.session.restart')));
      await tester.pumpAndSettle();
      expect(find.byKey(HathaLessonScreen.practiceKey), findsNothing);
      expect(store.records.length, 43);
      await tester.tap(find.byKey(const Key('hatha.session.prepared')));
      await tester.pumpAndSettle();
      await tester.scrollUntilVisible(
        find.byKey(HathaLessonScreen.practiceKey),
        300,
        scrollable: find.byType(Scrollable).last,
      );
      expect(find.byKey(HathaLessonScreen.practiceKey), findsOneWidget);
      expect(
        tester
            .widget<FilledButton>(find.byKey(HathaLessonScreen.practiceKey))
            .onPressed,
        isNull,
      );
      await tester.scrollUntilVisible(
        find.text('NE ZAMAN DURMALI'),
        -180,
        scrollable: find.byType(Scrollable).last,
      );
      expect(find.text('DAHA KOLAY YOLU SEÇ'), findsOneWidget);
      expect(find.text('NE ZAMAN DURMALI'), findsOneWidget);
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets(
    'h59 written plan can be previewed without transition rehearsal',
    (tester) async {
      final HathaCourse course = HathaCourse.parse(_asset());
      final _MemoryHathaProgressStore store = _MemoryHathaProgressStore();
      await tester.pumpWidget(
        MaterialApp(
          theme: buildLissomTheme(),
          home: HathaLessonScreen(
            course: course,
            lesson: course.lessons.firstWhere((lesson) => lesson.id == 'h59'),
            store: store,
            isRepeat: false,
          ),
        ),
      );
      expect(
        find.byKey(const Key('hatha.session.preparation')),
        findsOneWidget,
      );
      await tester.tap(find.byKey(const Key('hatha.session.readOnly')));
      await tester.pumpAndSettle();
      expect(find.textContaining('Written planning is open'), findsOneWidget);
      await tester.scrollUntilVisible(
        find.textContaining('Review h42'),
        200,
        scrollable: find.byType(Scrollable).last,
      );
      expect(find.textContaining('Review h42'), findsOneWidget);
      expect(
        find.textContaining('Rehearse only', skipOffstage: false),
        findsNothing,
      );
      expect(
        find.textContaining(
          _reviewedH59RehearsalEnglish,
          skipOffstage: false,
        ),
        findsNothing,
      );
      expect(find.byKey(HathaLessonScreen.practiceKey), findsNothing);
      expect(store.records, isEmpty);
    },
  );

  testWidgets('an open physical lesson relocks after the local day changes', (
    tester,
  ) async {
    final HathaCourse course = HathaCourse.parse(_asset());
    final _MemoryHathaProgressStore store = _MemoryHathaProgressStore();
    DateTime now = DateTime(2026, 9, 28, 23, 59, 59);
    final HathaSessionPreparation preparation = HathaSessionPreparation(
      now: () => now,
    )..acknowledge();
    await tester.pumpWidget(
      MaterialApp(
        theme: buildLissomTheme(),
        home: HathaLessonScreen(
          course: course,
          lesson: course.lessons.firstWhere((lesson) => lesson.id == 'h44'),
          store: store,
          isRepeat: false,
          preparation: preparation,
        ),
      ),
    );
    expect(find.byKey(const Key('hatha.session.preparation')), findsNothing);
    now = DateTime(2026, 9, 29);
    await tester.pump(const Duration(seconds: 2));
    expect(preparation.acknowledged, isFalse);
    expect(find.byKey(const Key('hatha.session.preparation')), findsOneWidget);
    expect(find.byKey(HathaLessonScreen.practiceKey), findsNothing);
    expect(store.records, isEmpty);
  });

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

  test('reviewed narrow lesson sources have visible scope boundaries', () {
    final HathaCourse course = HathaCourse.parse(_asset());
    const Map<String, String> expected = <String, String>{
      'h08': 'umich_standing_turn',
      'h28': 'cc_wall_legs',
      'h52': 'ace_bent_knee_reverse_table',
    };
    expect(course.version, '1.0.1');
    expect(course.sourceScopes.keys.toSet(), <String>{
      ...expected.values,
      'yi_chair_triangle',
      'cc_wall_legs',
      'yj_wall_chair_rest',
      'yi_wall_side_exit',
      'nhs_pregnancy',
      'acog',
      'yj_locust_components',
      'yj_locust_combined',
      'yei_bridge_flow',
    });
    for (final HathaLesson lesson in course.lessons) {
      final String? sourceId = expected[lesson.id];
      final Iterable<String> credited = lesson.sourceIds.where(
        expected.values.toSet().contains,
      );
      expect(
        credited,
        sourceId == null ? isEmpty : contains(sourceId),
        reason: lesson.id,
      );
      if (sourceId != null) {
        expect(credited, hasLength(1));
        expect(course.sourceScopes[sourceId]!.supports.tr, isNotEmpty);
        expect(course.sourceScopes[sourceId]!.doesNotSupport.en, isNotEmpty);
      }
    }
    expect(
      course.sources['umich_standing_turn'],
      'https://hr.umich.edu/node/74294',
    );
    expect(
      course.lessons.singleWhere((l) => l.id == 'h08').sourceIds,
      isNot(contains('artofliving_standing_spinal_twist')),
    );
  });

  test(
    'source scope requires an existing source and bilingual limitations',
    () {
      final Map<String, dynamic> content = (jsonDecode(_asset()) as Map)
          .cast<String, dynamic>();
      final Map<String, dynamic> scopes = (content['sourceScopes'] as Map)
          .cast<String, dynamic>();
      scopes['not-a-course-source'] = scopes['umich_standing_turn'];
      expect(
        () => HathaCourse.parse(jsonEncode(content)),
        throwsFormatException,
      );
      scopes.remove('not-a-course-source');
      (scopes['umich_standing_turn'] as Map)['doesNotSupport']['tr'] = '';
      expect(
        () => HathaCourse.parse(jsonEncode(content)),
        throwsFormatException,
      );
    },
  );

  testWidgets('reviewed lessons display the source boundary beside the link', (
    tester,
  ) async {
    final HathaCourse course = HathaCourse.parse(_asset());
    for (final MapEntry<String, String> entry in <String, String>{
      'h08': 'umich_standing_turn',
      'h28': 'cc_wall_legs',
      'h52': 'ace_bent_knee_reverse_table',
    }.entries) {
      final HathaSessionPreparation preparation = HathaSessionPreparation();
      preparation.acknowledge();
      await tester.pumpWidget(
        MaterialApp(
          theme: buildLissomTheme(),
          home: HathaLessonScreen(
            course: course,
            lesson: course.lessons.firstWhere((l) => l.id == entry.key),
            store: _MemoryHathaProgressStore(),
            isRepeat: false,
            preparation: preparation,
          ),
        ),
      );
      await tester.scrollUntilVisible(
        find.text('Teaching sources'),
        200,
        scrollable: find.byType(Scrollable).last,
      );
      // scrollUntilVisible accepts a sliver child whose bottom edge is one
      // pixel beyond the test viewport; bring the header into the hit area.
      await tester.drag(find.byType(Scrollable).last, const Offset(0, -100));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Teaching sources'));
      await tester.pumpAndSettle();
      await tester.scrollUntilVisible(
        find.byKey(Key('hatha.sourceScope.${entry.value}')),
        200,
        scrollable: find.byType(Scrollable).last,
        maxScrolls: 30,
      );
      expect(
        find.byKey(Key('hatha.sourceScope.${entry.value}')),
        findsOneWidget,
      );
      expect(
        find.byKey(Key('hatha.sourceLimit.${entry.value}')),
        findsOneWidget,
      );
      await tester.pumpWidget(const SizedBox.shrink());
    }
  });

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
    // Lazy text blocks can settle after first visibility. Centre the actual
    // control before tapping, rather than accepting a partial intersection.
    await tester.pumpAndSettle();
    await Scrollable.ensureVisible(
      tester.element(find.byKey(HathaLessonScreen.reflectionKey)),
      alignment: 0.5,
    );
    await tester.pumpAndSettle();
    expect(
      find.byKey(HathaLessonScreen.reflectionKey).hitTestable(),
      findsOneWidget,
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
