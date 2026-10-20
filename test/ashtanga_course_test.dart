import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lissom/app/app_facts.dart';
import 'package:lissom/app/ashtanga_course.dart';
import 'package:lissom/app/hatha_course.dart';
import 'package:lissom/app/hatha_course_screen.dart';
import 'package:lissom/app/hatha_progress.dart';
import 'package:lissom/app/hatha_session_preparation.dart';
import 'package:lissom/app/library_screen.dart';
import 'package:lissom/app/lissom_theme.dart';
import 'package:lissom/app/local_account_bridge.dart';
import 'package:lissom/app/progress_screen.dart';
import 'package:lissom/app/shell.dart';

import 'support/facts_from_disk.dart';
import 'support/education_authoring_oracle.dart';

HathaCourse _course() =>
    HathaCourse.parse(File(kAshtangaCourseAssetPath).readAsStringSync());

HathaPracticeRecord _record(
  HathaCourse course,
  String lesson, {
  String? version,
}) => HathaPracticeRecord(
  lessonId: lesson,
  courseId: course.id,
  courseVersion: version ?? course.version,
  practicedAt: DateTime.utc(2026, 10, 16),
);

class _Store implements HathaProgressStore {
  final records = <HathaPracticeRecord>[];
  bool failWrite = false;
  int writes = 0;

  @override
  Future<HathaProgress> read() async =>
      HathaProgress(records: List.unmodifiable(records), unreadableRecords: 0);

  @override
  Future<void> markPracticed(HathaCourse course, String lessonId) async {
    if (failWrite) throw const FileSystemException('injected write failure');
    final prior = (await read()).practicedIn(course);
    if (!course.lessonById(lessonId)!.prerequisites.every(prior.contains)) {
      throw StateError('prerequisite');
    }
    writes++;
    records.add(_record(course, lessonId));
  }
}

class _Bundle extends CachingAssetBundle {
  _Bundle({this.missing = false, this.tamper = false});
  final bool missing;
  final bool tamper;

  @override
  Future<ByteData> load(String key) async {
    if (missing && key == kAshtangaCourseAssetPath) throw StateError('missing');
    final bytes = File(key).readAsBytesSync();
    if (tamper && key == kAshtangaCourseAssetPath) bytes[bytes.length - 1] = 32;
    final padded = Uint8List(bytes.length + 8)
      ..setRange(4, bytes.length + 4, bytes);
    return ByteData.view(padded.buffer, 4, bytes.length);
  }
}

AppFacts _facts({HathaProgress? progress}) {
  final base = factsFromDisk();
  return AppFacts(
    ia: base.ia,
    battery: base.battery,
    liveness: base.liveness,
    history: base.history,
    hatha: base.hatha,
    ashtanga: _course(),
    hathaProgress: progress ?? base.hathaProgress,
  );
}

Future<void> _pump(WidgetTester tester, Widget home, String language) async {
  tester.view.physicalSize = const Size(320, 640);
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);
  await tester.pumpWidget(
    MaterialApp(
      theme: buildLissomTheme(),
      locale: Locale(language),
      supportedLocales: const [Locale('en'), Locale('tr')],
      localizationsDelegates: GlobalMaterialLocalizations.delegates,
      builder: (context, child) => MediaQuery(
        data: MediaQuery.of(context).copyWith(textScaler: TextScaler.linear(2)),
        child: child!,
      ),
      home: home,
    ),
  );
  await tester.pumpAndSettle();
}

Future<void> _tap(
  WidgetTester tester,
  Finder finder, {
  double delta = 300,
}) async {
  await tester.scrollUntilVisible(
    finder,
    delta,
    scrollable: find.byType(Scrollable).last,
    maxScrolls: 80,
  );
  await Scrollable.ensureVisible(tester.element(finder), alignment: 0.5);
  await tester.pumpAndSettle();
  await tester.tap(finder);
  await tester.pumpAndSettle();
}

Future<_Store> _openLesson(
  WidgetTester tester,
  String id,
  String language,
) async {
  final course = _course();
  final store = _Store();
  for (final lesson in course.lessons.takeWhile((l) => l.id != id)) {
    store.records.add(_record(course, lesson.id));
  }
  await _pump(
    tester,
    HathaCourseScreen(
      course: course,
      initialProgress: await store.read(),
      storeLoader: () async => store,
    ),
    language,
  );
  await _tap(tester, find.byKey(HathaCourseScreen.continueKey));
  expect(find.byType(HathaLessonScreen), findsOneWidget);
  return store;
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test(
    '13 bilingual source-owned lessons have ordered prerequisites and bounded sources',
    () async {
      final course = await loadVerifiedAshtangaCourse(_Bundle());
      expect(course.id, kAshtangaCourseId);
      expect(course.modules, hasLength(4));
      expect(
        course.lessons.map((l) => l.id),
        List.generate(13, (i) => 'a${(i + 1).toString().padLeft(2, '0')}'),
      );
      expect(course.sourceScopes.keys.toSet(), course.sources.keys.toSet());
      final prior = <String>{};
      for (final lesson in course.lessons) {
        expect(lesson.prerequisites, prior.isEmpty ? isEmpty : [prior.last]);
        expect(lesson.steps.length, greaterThanOrEqualTo(4));
        for (final text in [
          lesson.title,
          lesson.objective,
          ...lesson.steps,
          lesson.practice,
          lesson.selfCheck,
          lesson.answerKey!,
          lesson.adaptation,
          lesson.stopSignal,
          lesson.mediaBrief,
        ]) {
          expect(text.en.trim(), isNotEmpty);
          expect(text.tr.trim(), isNotEmpty);
          expect(text.en, isNot(text.tr));
        }
        for (final id in lesson.sourceIds) {
          expect(course.sources, contains(id));
          expect(
            course.sourceScopes[id]!.doesNotSupport.en,
            contains('Does not endorse'),
          );
        }
        prior.add(lesson.id);
      }
      expect(course.intro.en, contains('not the full Primary Series'));
      expect(course.intro.tr, contains('Tam temel seri değildir'));
      for (final lesson in course.lessons) {
        expect(lesson.practice.en,
            authoredEducationText(course.id, lesson.id, 'en', 'practice'));
        expect(lesson.practice.tr,
            authoredEducationText(course.id, lesson.id, 'tr', 'practice'));
      }
      expect(
        course.lessonById('a10')!.steps.last.en,
        contains('not required physical progression'),
      );
    },
  );

  test('missing and valid-JSON changed bytes fail closed', () async {
    await expectLater(
      loadVerifiedAshtangaCourse(_Bundle(missing: true)),
      throwsStateError,
    );
    await expectLater(
      loadVerifiedAshtangaCourse(_Bundle(tamper: true)),
      throwsFormatException,
    );
  });

  test('physical preparation applies only to taught movement units', () {
    final course = _course();
    const physical = {'a04', 'a05', 'a06', 'a07', 'a09', 'a11'};
    for (final lesson in course.lessons) {
      expect(
        HathaSessionPreparation.requiredFor(lesson.id),
        physical.contains(lesson.id),
      );
      expect(course.isWrittenStudy(lesson.id), !physical.contains(lesson.id));
    }
    expect(course.allowsLessonPreview, isTrue);
    expect(course.recordsParticipation, isTrue);
  });

  test(
    'all lessons persist, repeat and stay isolated from version, course and account',
    () async {
      final root = await Directory.systemTemp.createTemp(
        'lissom-ashtanga-progress-',
      );
      addTearDown(() => root.delete(recursive: true));
      final course = _course();
      final file = File('${root.path}/practice.jsonl');
      final store = JsonlHathaProgressStore(file);
      await expectLater(store.markPracticed(course, 'a13'), throwsStateError);
      for (final lesson in course.lessons) {
        await store.markPracticed(course, lesson.id);
      }
      await store.markPracticed(course, 'a01');
      final progress = await JsonlHathaProgressStore(file).read();
      expect(progress.records, hasLength(14));
      expect(progress.practicedIn(course), hasLength(13));
      expect(progress.practicedIn(factsFromDisk().hatha!), isEmpty);
      final nextRaw =
          jsonDecode(File(kAshtangaCourseAssetPath).readAsStringSync())
              as Map<String, dynamic>;
      nextRaw['version'] = '2.0.0';
      final next = HathaCourse.parse(jsonEncode(nextRaw));
      expect(progress.practicedIn(next), isEmpty);
      expect(progress.oldVersionCount(next), 14);
      expect(
        (await JsonlHathaProgressStore(
          File('${root.path}/other/practice.jsonl'),
        ).read()).records,
        isEmpty,
      );
    },
  );

  test(
    'actual startup includes Ashtanga and rejects absent or changed Ashtanga',
    () async {
      final root = await Directory.systemTemp.createTemp(
        'lissom-ashtanga-facts-',
      );
      final owners = LissomOwnerRegistry(canonicalSupportDirectory: root);
      const id = 'aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaaa';
      final scope = owners.openScope(id);
      addTearDown(() async {
        owners.dispose();
        await root.delete(recursive: true);
      });
      final facts = await AppFacts.load(scope: scope, bundle: _Bundle());
      expect(facts.ashtanga!.id, kAshtangaCourseId);
      expect(facts.ashtanga!.lessons, hasLength(13));
      await expectLater(
        AppFacts.load(scope: scope, bundle: _Bundle(missing: true)),
        throwsStateError,
      );
      await expectLater(
        AppFacts.load(scope: scope, bundle: _Bundle(tamper: true)),
        throwsFormatException,
      );
    },
  );

  for (final language in ['en', 'tr']) {
    final tr = language == 'tr';
    for (final id in ['a01', 'a04', 'a08', 'a11']) {
      testWidgets('$id $language 320px/2x scroll, answer and preparation', (
        tester,
      ) async {
        final store = await _openLesson(tester, id, language);
        if (HathaSessionPreparation.requiredFor(id)) {
          expect(
            find.byKey(const Key('hatha.session.preparation')),
            findsOneWidget,
          );
          expect(find.byKey(HathaLessonScreen.practiceKey), findsNothing);
          await _tap(tester, find.byKey(const Key('hatha.session.prepared')));
        }
        final lesson = _course().lessonById(id)!;
        final practice = displayedEducationText(kAshtangaCourseId, id, language, 'practice');
        await tester.scrollUntilVisible(
          find.text(practice), 250,
          scrollable: find.byType(Scrollable).last, maxScrolls: 80,
        );
        expect(find.text(practice), findsOneWidget);
        expect(store.writes, 0);
        final answer = tr ? lesson.answerKey!.tr : lesson.answerKey!.en;
        expect(find.text(answer), findsNothing);
        await _tap(tester, find.byKey(Key('course.answer.$id')));
        expect(find.text(answer), findsOneWidget);
        final reflection = find.byKey(HathaLessonScreen.reflectionKey);
        await _tap(tester, reflection);
        final save = find.byKey(HathaLessonScreen.practiceKey);
        await tester.scrollUntilVisible(
          save,
          250,
          scrollable: find.byType(Scrollable).last,
        );
        await tester.ensureVisible(save);
        await tester.pumpAndSettle();
        expect(tester.widget<FilledButton>(save).onPressed, isNotNull);
        expect(store.writes, 0);
        expect(tester.takeException(), isNull);
      });
    }

    testWidgets('stop, locked preview and background never record $language', (
      tester,
    ) async {
      final store = await _openLesson(tester, 'a04', language);
      await _tap(tester, find.byKey(const Key('hatha.session.stop')));
      expect(find.byType(HathaLessonScreen), findsNothing);
      expect(store.writes, 0);
      await _tap(tester, find.byKey(HathaCourseScreen.continueKey));
      await _tap(tester, find.byKey(const Key('hatha.session.readOnly')));
      expect(find.byKey(HathaLessonScreen.practiceKey), findsNothing);
      await _tap(
        tester,
        find.byKey(const Key('hatha.session.prepareToPractice')),
        delta: -250,
      );
      await _tap(tester, find.byKey(const Key('hatha.session.prepared')));
      tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.inactive);
      tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.hidden);
      tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.paused);
      await tester.pump();
      tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.hidden);
      tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.inactive);
      tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.resumed);
      await tester.pump();
      await tester.scrollUntilVisible(
        find.byKey(const Key('hatha.session.preparation')),
        -250,
        scrollable: find.byType(Scrollable).last,
      );
      expect(
        find.byKey(const Key('hatha.session.preparation')),
        findsOneWidget,
      );
      expect(find.byKey(HathaLessonScreen.practiceKey), findsNothing);
      expect(store.writes, 0);
    });

    testWidgets('write error retries and repeat records once per tap $language', (
      tester,
    ) async {
      final store = await _openLesson(tester, 'a01', language);
      store.failWrite = true;
      await _tap(tester, find.byKey(HathaLessonScreen.reflectionKey));
      await _tap(tester, find.byKey(HathaLessonScreen.practiceKey));
      expect(store.writes, 0);
      expect(
        find.text(
          tr
              ? 'Çalışman kaydedilemedi. Hesabın değiştiyse kursu yeniden aç veya tekrar dene.'
              : 'Your practice was not saved. Reopen the course if your account changed, or try again.',
        ),
        findsOneWidget,
      );
      store.failWrite = false;
      await _tap(tester, find.byKey(HathaLessonScreen.practiceKey));
      expect(find.byType(HathaLessonScreen), findsNothing);
      expect(store.writes, 1);
      final title = tr
          ? _course().lessons.first.title.tr
          : _course().lessons.first.title.en;
      await _tap(tester, find.widgetWithText(ListTile, title));
      expect(
        tester
            .widget<HathaLessonScreen>(find.byType(HathaLessonScreen))
            .isRepeat,
        isTrue,
      );
      await _tap(tester, find.byKey(HathaLessonScreen.reflectionKey));
      await _tap(tester, find.byKey(HathaLessonScreen.practiceKey));
      expect(store.writes, 2);
      expect((await store.read()).practicedIn(_course()), {'a01'});
      expect(tester.takeException(), isNull);
    });

    testWidgets(
      'locked later lesson preview cannot prepare or record $language',
      (tester) async {
        final course = _course();
        final store = _Store();
        await _pump(
          tester,
          HathaCourseScreen(
            course: course,
            initialProgress: await store.read(),
            storeLoader: () async => store,
          ),
          language,
        );
        final lesson = course.lessonById('a11')!;
        await _tap(
          tester,
          find.widgetWithText(ListTile, tr ? lesson.title.tr : lesson.title.en),
        );
        expect(
          tester
              .widget<HathaLessonScreen>(find.byType(HathaLessonScreen))
              .previewOnly,
          isTrue,
        );
        expect(find.byKey(HathaLessonScreen.practiceKey), findsNothing);
        expect(
          find.byKey(const Key('hatha.session.prepareToPractice')),
          findsNothing,
        );
        expect(find.text(tr ? 'ÖĞREN' : 'LEARN'), findsNothing);
        expect(store.writes, 0);
        expect(tester.takeException(), isNull);
      },
    );

    testWidgets(
      'Home and Library open exact Ashtanga course and back $language',
      (tester) async {
        final facts = _facts();
        await _pump(tester, LissomShell(loader: () async => facts), language);
        final entry = find.byKey(const Key('home.ashtangaCourse'));
        await tester.scrollUntilVisible(entry, 250);
        final button = find.descendant(
          of: entry,
          matching: find.byType(FilledButton),
        );
        await _tap(tester, button);
        expect(
          tester
              .widget<HathaCourseScreen>(find.byType(HathaCourseScreen))
              .course
              .id,
          kAshtangaCourseId,
        );
        await tester.tap(find.byType(BackButton));
        await tester.pumpAndSettle();
        expect(find.byType(HathaCourseScreen), findsNothing);
        await _pump(
          tester,
          FamilyPage(
            family: facts.ia.families.singleWhere((f) => f.id == 'yoga_styles'),
            facts: facts,
            hathaStoreLoader: () async => _Store(),
          ),
          language,
        );
        await _tap(
          tester,
          find.text(
            tr ? 'Ashtanga temellerini aç' : 'Open Ashtanga foundations',
          ),
        );
        expect(
          tester
              .widget<HathaCourseScreen>(find.byType(HathaCourseScreen))
              .course
              .id,
          kAshtangaCourseId,
        );
        expect(tester.takeException(), isNull);
      },
    );

    testWidgets('progress and finished route report participation $language', (
      tester,
    ) async {
      final course = _course();
      final records = [
        for (final lesson in course.lessons) _record(course, lesson.id),
        _record(course, 'a01'),
        _record(course, 'a02', version: '0.0.0'),
      ];
      final progress = HathaProgress(records: records, unreadableRecords: 0);
      await _pump(
        tester,
        Scaffold(
          body: ProgressScreen(facts: _facts(progress: progress)),
        ),
        language,
      );
      final heading = find.text(
        tr ? 'Ashtanga katılımı' : 'Ashtanga participation',
      );
      await tester.scrollUntilVisible(heading, 250);
      expect(heading, findsOneWidget);
      expect(
        find.textContaining(
          tr
              ? '13/13 birimde katılım kaydı'
              : '13/13 units with participation records',
        ),
        findsOneWidget,
      );
      final store = _Store()..records.addAll(records);
      await _pump(
        tester,
        HathaCourseScreen(
          course: course,
          initialProgress: progress,
          storeLoader: () async => store,
        ),
        language,
      );
      expect(find.byKey(HathaCourseScreen.continueKey), findsNothing);
      final end = find.textContaining(
        tr
            ? 'Ders kayıtların sona ulaştı.'
            : 'Your lesson records reach the end.',
      );
      await tester.scrollUntilVisible(end, 250);
      expect(end, findsOneWidget);
      expect(tester.takeException(), isNull);
    });
  }
}
