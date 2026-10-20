import 'dart:io';
import 'dart:convert';
import 'package:lissom/app/app_facts.dart';
import 'package:lissom/app/library_screen.dart';
import 'package:lissom/app/shell.dart';
import 'support/facts_from_disk.dart';
import 'support/education_authoring_oracle.dart';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:lissom/app/yin_course.dart';
import 'package:lissom/app/hatha_course.dart';
import 'package:lissom/app/hatha_course_screen.dart';
import 'package:lissom/app/hatha_progress.dart';
import 'package:lissom/app/hatha_session_preparation.dart';
import 'package:lissom/app/progress_screen.dart';

HathaCourse _yin() =>
    HathaCourse.parse(File(kYinCourseAssetPath).readAsStringSync());

final class _OffsetBundle extends CachingAssetBundle {
  _OffsetBundle(this.bytes);
  final Uint8List bytes;

  @override
  Future<ByteData> load(String key) async {
    if (key != kYinCourseAssetPath) throw StateError(key);
    final padded = Uint8List(bytes.length + 8)
      ..setRange(4, bytes.length + 4, bytes);
    return ByteData.view(padded.buffer, 4, bytes.length);
  }
}

final class _CountingStore implements HathaProgressStore {
  int writes = 0;
  bool fail = false;
  @override
  Future<HathaProgress> read() async => const HathaProgress(
    records: <HathaPracticeRecord>[],
    unreadableRecords: 0,
  );
  @override
  Future<void> markPracticed(HathaCourse course, String lessonId) async {
    if (fail) throw StateError("injected write failure");
    writes++;
  }
}

final class _MissingBundle extends CachingAssetBundle {
  @override
  Future<ByteData> load(String key) async => throw FlutterError('Missing $key');
}

AppFacts _facts() {
  final base = factsFromDisk();
  return AppFacts(
    ia: base.ia,
    battery: base.battery,
    liveness: base.liveness,
    history: base.history,
    hatha: base.hatha,
    chairOffice: HathaCourse.parse(File('config/courses/chair-office.v1.json').readAsStringSync()),
    vinyasa: HathaCourse.parse(File('config/courses/vinyasa-standing.v1.json').readAsStringSync()),
    yin: _yin(),
    hathaProgress: base.hathaProgress,
  );
}

Future<void> _tap(WidgetTester tester, Finder finder) async {
  await Scrollable.ensureVisible(tester.element(finder), alignment: 0.5);
  await tester.pumpAndSettle();
  await tester.tap(finder);
  await tester.pumpAndSettle();
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('actual Yin asset parses and verified loader returns same course', () async {
    final bytes = File(kYinCourseAssetPath).readAsBytesSync();
    final parsed = HathaCourse.parse(utf8.decode(bytes));
    final verified = await loadVerifiedYinCourse(_OffsetBundle(bytes));
    expect(parsed.id, 'lissom.yin.supported.beginner');
    expect(verified.id, parsed.id);
    expect(verified.version, parsed.version);
    expect(verified.lessons.map((lesson) => lesson.id).toList(),
      parsed.lessons.map((lesson) => lesson.id).toList());
    final raw = jsonDecode(utf8.decode(bytes)) as Map<String, dynamic>;
    final sourceKeys = (raw['sources'] as Map).keys.toSet();
    expect(sourceKeys, <String>{'s1', 's2', 's3', 's4', 's5', 's6', 's7', 's8'});
    expect((raw['sourceScopes'] as Map).keys.toSet(), sourceKeys);
    for (final module in raw['modules'] as List) {
      for (final lesson in (module as Map)['lessons'] as List) {
        for (final source in (lesson as Map)['sourceIds'] as List) {
          expect(sourceKeys, contains(source));
        }
      }
    }
  });

  test(
    'Yin integrity checks exactly the ByteData view and rejects tamper',
    () async {
      final bytes = File(kYinCourseAssetPath).readAsBytesSync();
      final course = await loadVerifiedYinCourse(_OffsetBundle(bytes));
      expect(course.id, 'lissom.yin.supported.beginner');
      final changed = Uint8List.fromList(bytes);
      changed[changed.length - 1] =
          32; // Still valid JSON, different byte identity.
      await expectLater(
        loadVerifiedYinCourse(_OffsetBundle(changed)),
        throwsFormatException,
      );
    },
  );

  test('Yin records do not consume Hatha history or another version', () {
    final yin = _yin();
    final hatha = HathaCourse.parse(
      File('config/courses/hatha.v1.json').readAsStringSync(),
    );
    final progress = HathaProgress(
      records: <HathaPracticeRecord>[
        HathaPracticeRecord(
          lessonId: 'h01',
          courseId: hatha.id,
          courseVersion: hatha.version,
          practicedAt: DateTime.utc(2026),
        ),
        HathaPracticeRecord(
          lessonId: 'y01',
          courseId: yin.id,
          courseVersion: yin.version,
          practicedAt: DateTime.utc(2026),
        ),
        HathaPracticeRecord(
          lessonId: 'y02',
          courseId: yin.id,
          courseVersion: '0.0.0',
          practicedAt: DateTime.utc(2026),
        ),
      ],
      unreadableRecords: 0,
    );
    expect(progress.practicedIn(hatha), <String>{'h01'});
    expect(progress.practicedIn(yin), <String>{'y01'});
    expect(progress.oldVersionCount(yin), 1);
  });

  testWidgets('answers start hidden and require a separate reveal', (
    tester,
  ) async {
    final yin = _yin();
    final lesson = yin.lessonById(
      'y06',
    )!; // Independent A/B cases, answer key separately revealed.
    await tester.pumpWidget(
      MaterialApp(
        home: HathaLessonScreen(
          course: yin,
          lesson: lesson,
          store: _CountingStore(),
          isRepeat: false,
          preparation: HathaSessionPreparation()..acknowledge(),
        ),
      ),
    );
    await tester.pumpAndSettle();
    final reveal = find.byKey(const Key('course.answer.y06'));
    await tester.scrollUntilVisible(reveal, 400);
    expect(find.text(lesson.answerKey!.en), findsNothing);
    await _tap(tester, find.text('Reveal after writing your answer'));
    await tester.pumpAndSettle();
    expect(find.text(lesson.answerKey!.en), findsOneWidget);
  });

  testWidgets('locked Yin preview cannot show physical steps or save', (
    tester,
  ) async {
    final yin = _yin();
    final lesson = yin.lessonById('y06')!;
    final store = _CountingStore();
    final preparation = HathaSessionPreparation()..acknowledge();
    await tester.pumpWidget(
      MaterialApp(
        home: HathaLessonScreen(
          course: yin,
          lesson: lesson,
          store: store,
          isRepeat: false,
          preparation: preparation,
          previewOnly: true,
        ),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.text('1. ${lesson.steps.first.en}'), findsNothing);
    expect(find.byKey(HathaLessonScreen.practiceKey), findsNothing);
    expect(
      find.byKey(const Key('hatha.session.prepareToPractice')),
      findsNothing,
    );
    tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.inactive);
    tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.hidden);
    tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.paused);
    await tester.pump();
    tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.hidden);
    tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.inactive);
    tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.resumed);
    await tester.pump();
    expect(find.text('1. ${lesson.steps.first.en}'), findsNothing);
    expect(find.byKey(HathaLessonScreen.practiceKey), findsNothing);
    expect(store.writes, 0);
  });
  test(
    'missing Yin asset fails rather than supplying an empty course',
    () async {
      await expectLater(
        loadVerifiedYinCourse(_MissingBundle()),
        throwsA(isA<FlutterError>()),
      );
    },
  );

  test('Yin movement preparation expires across midnight and reset', () {
    var now = DateTime(2026, 10, 4, 23, 59, 59);
    final preparation = HathaSessionPreparation(now: () => now)..acknowledge();
    expect(preparation.acknowledged, isTrue);
    now = DateTime(2026, 10, 5);
    expect(preparation.acknowledged, isFalse);
    preparation.acknowledge();
    preparation.reset();
    expect(preparation.acknowledged, isFalse);
    for (final lesson in _yin().lessons) {
      expect(
        HathaSessionPreparation.requiredFor(lesson.id),
        lesson.id != 'y01',
      );
    }
  });

  for (final locale in const <String>['en', 'tr']) {
    for (var number = 1; number <= 8; number++) {
      final id = 'y${number.toString().padLeft(2, '0')}';
      testWidgets(
        '$id $locale large text: scroll, reveal, preparation and reset',
        (tester) async {
          final semantics = tester.ensureSemantics();

          tester.view.physicalSize = const Size(390, 844);
          tester.view.devicePixelRatio = 1;
          addTearDown(tester.view.resetPhysicalSize);
          addTearDown(tester.view.resetDevicePixelRatio);
          final course = await loadVerifiedYinCourse(
            _OffsetBundle(File(kYinCourseAssetPath).readAsBytesSync()),
          );
          final lesson = course.lessonById(id)!;
          final practice = authoredEducationText(course.id, id, locale, 'practice');
          final question = authoredEducationText(course.id, id, locale, 'selfCheck');
          final answer = authoredEducationText(course.id, id, locale, 'answerKey');
          expect(locale == 'tr' ? lesson.practice.tr : lesson.practice.en, practice);
          expect(locale == 'tr' ? lesson.selfCheck.tr : lesson.selfCheck.en, question);
          expect(lesson.answerKey, isNotNull);
          expect(locale == 'tr' ? lesson.answerKey!.tr : lesson.answerKey!.en, answer);
          expect(question, isNot(practice));
          expect(answer, isNot(question));
          final displayedPractice = displayedEducationText(course.id, id, locale, 'practice');
          final displayedQuestion = displayedEducationText(course.id, id, locale, 'selfCheck');
          final displayedAnswer = displayedEducationText(course.id, id, locale, 'answerKey');
          expect(displayedQuestion, isNot(displayedPractice));
          expect(displayedAnswer, isNot(displayedQuestion));
          final store = _CountingStore();
          Future<void> open() async {
            await tester.pumpWidget(
              MaterialApp(
                locale: Locale(locale),
                supportedLocales: const <Locale>[Locale('en'), Locale('tr')],
                localizationsDelegates: GlobalMaterialLocalizations.delegates,
                builder: (context, child) => MediaQuery(
                  data: MediaQuery.of(
                    context,
                  ).copyWith(textScaler: const TextScaler.linear(2)),
                  child: child!,
                ),
                home: HathaLessonScreen(
                  course: course,
                  lesson: lesson,
                  store: store,
                  isRepeat: false,
                  preparation: HathaSessionPreparation()..acknowledge(),
                ),
              ),
            );
            await tester.pumpAndSettle();
          }

          await open();
          final reveal = find.byKey(Key('course.answer.$id'));
          await tester.scrollUntilVisible(find.text(displayedPractice), 300, maxScrolls: 100);
          expect(find.text(displayedPractice), findsOneWidget);
          await tester.scrollUntilVisible(find.text(displayedQuestion), 300, maxScrolls: 100);
          expect(find.text(displayedQuestion), findsOneWidget);
          expect(store.writes, 0);
          await tester.scrollUntilVisible(reveal, 300, maxScrolls: 100);
          expect(find.text(displayedAnswer), findsNothing);
          await _tap(tester, reveal);
          expect(find.text(displayedAnswer), findsOneWidget);
          expect(store.writes, 0);
          await tester.scrollUntilVisible(
            find.byKey(HathaLessonScreen.reflectionKey),
            300,
            maxScrolls: 100,
          );
          await _tap(tester, find.byKey(HathaLessonScreen.reflectionKey));
          await tester.pump();
          final save = find.byKey(HathaLessonScreen.practiceKey);
          await tester.scrollUntilVisible(save, 300);
          expect(tester.widget<FilledButton>(save).onPressed, isNotNull);
          expect(
            tester.getSemantics(save),
            matchesSemantics(
              isButton: true,
              hasEnabledState: true,
              isEnabled: true,
              hasTapAction: true,
              hasFocusAction: true,
              isFocusable: true,
              label: (tester.widget<FilledButton>(save).child as Text).data!,
            ),
          );
          expect(tester.takeException(), isNull);
          tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.inactive);
          tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.hidden);
          tester.binding.handleAppLifecycleStateChanged(
            AppLifecycleState.paused,
          );
          await tester.pump();
          tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.hidden);
          tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.inactive);
          tester.binding.handleAppLifecycleStateChanged(
            AppLifecycleState.resumed,
          );
          await tester.pump();
          expect(store.writes, 0);
          expect(find.text(displayedAnswer), findsNothing);
          await tester.pumpWidget(const SizedBox.shrink());
          await open();
          await tester.scrollUntilVisible(reveal, 300, maxScrolls: 100);
          expect(find.text(displayedAnswer), findsNothing);
          expect(store.writes, 0);
          await tester.scrollUntilVisible(
            find.byKey(HathaLessonScreen.reflectionKey),
            300,
            maxScrolls: 100,
          );
          await _tap(tester, find.byKey(HathaLessonScreen.reflectionKey));
          await tester.pump();
          await tester.scrollUntilVisible(
            find.byKey(HathaLessonScreen.practiceKey),
            300,
          );
          await _tap(tester, find.byKey(HathaLessonScreen.practiceKey));
          await tester.pumpAndSettle();
          expect(store.writes, 1);
          expect(tester.takeException(), isNull);
          semantics.dispose();
        },
      );
    }
  }

  testWidgets('real Home opens Yin path then back returns Home', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(home: LissomShell(loader: () async => _facts())),
    );
    await tester.pumpAndSettle();
    final entry = find.byKey(const Key('home.yinCourse'));
    await tester.scrollUntilVisible(entry, 300);
    final button = find.descendant(
      of: entry,
      matching: find.byType(FilledButton),
    );
    await _tap(tester, button);
    await tester.pumpAndSettle();
    expect(
      tester
          .widget<HathaCourseScreen>(find.byType(HathaCourseScreen))
          .course
          .id,
      _yin().id,
    );
    await tester.pageBack();
    await tester.pumpAndSettle();
    expect(find.byType(HathaCourseScreen), findsNothing);
  });

  testWidgets('real Library family entry loads Yin-specific course', (
    tester,
  ) async {
    final facts = _facts();
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: LibraryScreen(
            facts: facts,
            hathaStoreLoader: () async => _CountingStore(),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
    final title = facts.ia.families
        .singleWhere((f) => f.id == 'yoga_styles')
        .title;
    // Existing family card navigation uses its displayed name.
    await tester.scrollUntilVisible(find.text(title), 300);
    await _tap(tester, find.text(title));
    await tester.pumpAndSettle();
    final button = find.text('Open supported Yin');
    await tester.scrollUntilVisible(button, 300);
    await _tap(tester, button);
    await tester.pumpAndSettle();
    expect(
      tester
          .widget<HathaCourseScreen>(find.byType(HathaCourseScreen))
          .course
          .id,
      facts.yin!.id,
    );
  });

  testWidgets('Yin foundation button opens actual Hatha teaching', (tester) async {
    await tester.pumpWidget(MaterialApp(home: LissomShell(loader: () async => _facts())));
    await tester.pumpAndSettle();
    final entry = find.byKey(const Key('home.yinCourse'));
    await tester.scrollUntilVisible(entry, 300);
    await _tap(tester, find.descendant(of: entry, matching: find.byType(TextButton)));
    expect(tester.widget<HathaCourseScreen>(find.byType(HathaCourseScreen)).course.id,
      'lissom.hatha.foundations');
  });

  testWidgets('course navigation cannot turn locked Yin preview into movement', (tester) async {
    final course = _yin();
    final store = _CountingStore();
    await tester.pumpWidget(MaterialApp(home: HathaCourseScreen(
      course: course,
      initialProgress: const HathaProgress(records: [], unreadableRecords: 0),
      storeLoader: () async => store,
    )));
    await tester.pumpAndSettle();
    final lesson = course.lessonById('y03')!;
    final tile = find.text(lesson.title.en);
    await tester.scrollUntilVisible(tile, 300);
    await _tap(tester, tile);
    final screen = tester.widget<HathaLessonScreen>(find.byType(HathaLessonScreen));
    expect(screen.previewOnly, isTrue);
    expect(find.text('1. ${lesson.steps.first.en}'), findsNothing);
    expect(find.byKey(HathaLessonScreen.practiceKey), findsNothing);
    expect(find.byKey(const Key('hatha.session.prepareToPractice')), findsNothing);
    expect(store.writes, 0);
  });

  testWidgets('Yin movement preparation names access limits and keeps save closed', (tester) async {
    final course = _yin();
    final lesson = course.lessonById('y05')!;
    final store = _CountingStore();
    await tester.pumpWidget(MaterialApp(home: HathaLessonScreen(
      course: course, lesson: lesson, store: store, isRepeat: false,
    )));
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('hatha.session.preparation')), findsOneWidget);
    expect(find.textContaining('reading h35 or ticking this card'), findsOneWidget);
    expect(find.text('1. ${lesson.steps.first.en}'), findsNothing);
    expect(find.byKey(HathaLessonScreen.practiceKey), findsNothing);
    expect(store.writes, 0);
  });

  testWidgets('Progress includes distinct Yin participation without mastery', (tester) async {
    await tester.pumpWidget(MaterialApp(home: Scaffold(body: ProgressScreen(facts: _facts()))));
    await tester.pumpAndSettle();
    await tester.scrollUntilVisible(find.text('Yin participation'), 300);
    expect(find.text('Yin participation'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('save failure leaves lesson open and retry records once', (
    tester,
  ) async {
    final course = _yin();
    final store = _CountingStore()..fail = true;
    await tester.pumpWidget(
      MaterialApp(
        home: HathaLessonScreen(
          course: course,
          lesson: course.lessonById('y01')!,
          store: store,
          isRepeat: false,
        ),
      ),
    );
    await tester.pumpAndSettle();
    final reflection = find.byKey(HathaLessonScreen.reflectionKey);
    await tester.scrollUntilVisible(reflection, 300);
    await _tap(tester, reflection);
    await tester.pump();
    final save = find.byKey(HathaLessonScreen.practiceKey);
    await tester.scrollUntilVisible(save, 300);
    await _tap(tester, save);
    await tester.pumpAndSettle();
    expect(store.writes, 0);
    expect(
      find.text(
        'Your practice was not saved. Reopen the course if your account changed, or try again.',
      ),
      findsOneWidget,
    );
    store.fail = false;
    await _tap(tester, save);
    await tester.pumpAndSettle();
    expect(store.writes, 1);
  });

  testWidgets('midnight closes answer and invalidates physical save', (
    tester,
  ) async {
    var now = DateTime(2026, 10, 4, 23, 59, 59);
    final preparation = HathaSessionPreparation(now: () => now)..acknowledge();
    final course = _yin();
    final lesson = course.lessonById('y06')!;
    final store = _CountingStore();
    await tester.pumpWidget(
      MaterialApp(
        home: HathaLessonScreen(
          course: course,
          lesson: lesson,
          store: store,
          isRepeat: false,
          preparation: preparation,
        ),
      ),
    );
    await tester.pump();
    final reveal = find.byKey(const Key('course.answer.y06'));
    await tester.scrollUntilVisible(reveal, 300);
    await _tap(tester, reveal);
    await tester.pump(const Duration(milliseconds: 300));
    expect(find.text(lesson.answerKey!.en), findsOneWidget);
    now = DateTime(2026, 10, 5);
    await tester.pump(const Duration(seconds: 2));
    expect(preparation.acknowledged, isFalse);
    expect(find.text(lesson.answerKey!.en), findsNothing);
    expect(find.byKey(HathaLessonScreen.practiceKey), findsNothing);
    expect(store.writes, 0);
  });
  test('v2 asset preserves unloaded-prop order and independent questions', () {
    final course = _yin();
    expect(course.lessons.length, 8); // Content identity, not completion.
    final butterfly = course.lessonById('y03')!;
    final caterpillar = course.lessonById('y04')!;
    final questions = course.lessonById('y06')!;
    expect(butterfly.steps.map((x) => x.en).join(' '),
      contains('lift forearms completely off'));
    expect(butterfly.steps.map((x) => x.en).join(' '),
      contains('Outer-thigh cushions stay in place'));
    expect(butterfly.steps.map((x) => x.tr).join(' '),
      contains('Dış uyluk altı yastıklar yerinde kalır'));
    expect(caterpillar.steps.map((x) => x.en).join(' '),
      contains('neither leg may still be resting its weight'));
    expect(caterpillar.steps.map((x) => x.tr).join(' '),
      contains('iki bacak da artık desteğe ağırlık vermiyor'));
    expect(questions.practice.en, contains('A: No symptoms'));
    expect(questions.practice.en, isNot(contains('A: Leave under control')));
    expect(questions.selfCheck.tr, isNot(contains('A: Pozdan kontrollü çık')));
    expect(questions.answerKey!.en, contains('do not retry'));
    expect(questions.answerKey!.tr, contains('yeniden deneme'));
    expect(course.lessonById('y03')!.prerequisites, ['y01', 'y02']);
    expect(course.lessonById('y04')!.prerequisites, ['y01', 'y02']);
    expect(course.lessonById('y05')!.prerequisites, ['y01', 'y02']);
    expect(course.lessonById('y07')!.prerequisites, ['y06']);
    for (final lesson in course.lessons) {
      expect(lesson.steps.length, greaterThanOrEqualTo(4));
      for (final step in lesson.steps) {
        expect(step.en.trim(), isNotEmpty);
        expect(step.tr.trim(), isNotEmpty);
      }
    }
    final raw = jsonDecode(File(kYinCourseAssetPath).readAsStringSync()) as Map<String,dynamic>;
    final first = ((raw['modules'] as List).first as Map)['lessons'] as List;
    (first.first as Map)['prerequisites'] = ['unknown'];
    expect(() => HathaCourse.parse(jsonEncode(raw)), throwsFormatException);
  });
  test('four courses and old Yin versions retain separate participation', () {
    final yin = _yin();
    final courses = <HathaCourse>[
      yin,
      HathaCourse.parse(File('config/courses/chair-office.v1.json').readAsStringSync()),
      HathaCourse.parse(File('config/courses/hatha.v1.json').readAsStringSync()),
      HathaCourse.parse(File('config/courses/vinyasa-standing.v1.json').readAsStringSync()),
    ];
    final records = HathaProgress(records: [
      for (final course in courses)
        HathaPracticeRecord(lessonId: course.lessons.first.id, courseId: course.id,
          courseVersion: course.version, practicedAt: DateTime.utc(2026)),
      HathaPracticeRecord(lessonId: 'y02', courseId: yin.id,
        courseVersion: '0.0.0', practicedAt: DateTime.utc(2026)),
    ], unreadableRecords: 0);
    for (final course in courses) {
      expect(records.practicedIn(course), <String>{course.lessons.first.id});
    }
    expect(records.oldVersionCount(yin), 1);
  });
}
