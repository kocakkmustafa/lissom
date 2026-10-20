import 'dart:io';
import 'dart:convert';
import 'package:lissom/app/app_facts.dart';
import 'package:lissom/app/library_screen.dart';
import 'package:lissom/app/shell.dart';
import 'support/facts_from_disk.dart';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:lissom/app/vinyasa_course.dart';
import 'package:lissom/app/hatha_course.dart';
import 'package:lissom/app/hatha_course_screen.dart';
import 'package:lissom/app/hatha_progress.dart';
import 'package:lissom/app/hatha_session_preparation.dart';

// Independent reviewed literals: LIS-ENTR-0809 (v04/TR answer) and
// LIS-ENTR-0098 (v06/EN first step), not production-derived expectations.
const String _reviewedV04AnswerTurkish =
    "İkisi de gerekmez: ayaklar sabit, kalça yerine gelirken ve gövde "
    "doğrulurken avuç teması korunur; eller yukarı kayabilir. Destek gerekmeyen "
    "sağlam dik tabanda önce biri sonra diğeri bırakılır. Yer biçimi kanıtı "
    "değildir.";

const String _reviewedV06FirstStepEnglish =
    "Before movement write: upright base → optional small free-arm rise/lower → "
    "supported shallow hinge OR familiar wall-dog preparation → upright base → "
    "optional short staggered stance and return of the right foot to neutral → "
    "neutral → optional return of the left foot to neutral → neutral rest. "
    "Choose only familiar components, keep required support and never remove it "
    "to make the route look continuous.";

HathaCourse _vinyasa() =>
    HathaCourse.parse(File(kVinyasaCourseAssetPath).readAsStringSync());

final class _OffsetBundle extends CachingAssetBundle {
  _OffsetBundle(this.bytes);
  final Uint8List bytes;

  @override
  Future<ByteData> load(String key) async {
    if (key != kVinyasaCourseAssetPath) throw StateError(key);
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
    vinyasa: _vinyasa(),
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

  test('actual Vinyasa asset parses and verified loader returns same course', () async {
    final bytes = File(kVinyasaCourseAssetPath).readAsBytesSync();
    final parsed = HathaCourse.parse(utf8.decode(bytes));
    final verified = await loadVerifiedVinyasaCourse(_OffsetBundle(bytes));
    expect(parsed.id, 'lissom.vinyasa.supported-standing.beginner');
    expect(verified.id, parsed.id);
    expect(verified.version, parsed.version);
    expect(verified.lessons.map((lesson) => lesson.id).toList(),
      parsed.lessons.map((lesson) => lesson.id).toList());
    final raw = jsonDecode(utf8.decode(bytes)) as Map<String, dynamic>;
    final sourceKeys = (raw['sources'] as Map).keys.toSet();
    expect(sourceKeys, <String>{'s1', 's2', 's3', 's4', 's5', 's6', 's7'});
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
    'chair integrity checks exactly the ByteData view and rejects tamper',
    () async {
      final bytes = File(kVinyasaCourseAssetPath).readAsBytesSync();
      final course = await loadVerifiedVinyasaCourse(_OffsetBundle(bytes));
      expect(course.id, 'lissom.vinyasa.supported-standing.beginner');
      final changed = Uint8List.fromList(bytes);
      changed[changed.length - 1] =
          32; // Still valid JSON, different byte identity.
      await expectLater(
        loadVerifiedVinyasaCourse(_OffsetBundle(changed)),
        throwsFormatException,
      );
    },
  );

  test('chair records do not consume Hatha history or another version', () {
    final chair = _vinyasa();
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
          lessonId: 'v01',
          courseId: chair.id,
          courseVersion: chair.version,
          practicedAt: DateTime.utc(2026),
        ),
        HathaPracticeRecord(
          lessonId: 'v02',
          courseId: chair.id,
          courseVersion: '0.0.0',
          practicedAt: DateTime.utc(2026),
        ),
      ],
      unreadableRecords: 0,
    );
    expect(progress.practicedIn(hatha), <String>{'h01'});
    expect(progress.practicedIn(chair), <String>{'v01'});
    expect(progress.oldVersionCount(chair), 1);
  });

  testWidgets('answers start hidden and require a separate reveal', (
    tester,
  ) async {
    final chair = _vinyasa();
    final lesson = chair.lessonById(
      'v07',
    )!; // Written planning, no movement gate.
    await tester.pumpWidget(
      MaterialApp(
        home: HathaLessonScreen(
          course: chair,
          lesson: lesson,
          store: _CountingStore(),
          isRepeat: false,
        ),
      ),
    );
    await tester.pumpAndSettle();
    final reveal = find.byKey(const Key('course.answer.v07'));
    await tester.scrollUntilVisible(reveal, 400);
    expect(find.text(lesson.answerKey!.en), findsNothing);
    await _tap(tester, find.text('Reveal after writing your answer'));
    await tester.pumpAndSettle();
    expect(find.text(lesson.answerKey!.en), findsOneWidget);
  });

  testWidgets('locked chair preview cannot show physical steps or save', (
    tester,
  ) async {
    final chair = _vinyasa();
    final lesson = chair.lessonById('v06')!;
    final store = _CountingStore();
    final preparation = HathaSessionPreparation()..acknowledge();
    await tester.pumpWidget(
      MaterialApp(
        home: HathaLessonScreen(
          course: chair,
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
    expect(
      find.text('1. $_reviewedV06FirstStepEnglish', skipOffstage: false),
      findsNothing,
    );
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
    expect(
      find.text('1. $_reviewedV06FirstStepEnglish', skipOffstage: false),
      findsNothing,
    );
    expect(find.byKey(HathaLessonScreen.practiceKey), findsNothing);
    expect(store.writes, 0);
  });
  test(
    'missing chair asset fails rather than supplying an empty course',
    () async {
      await expectLater(
        loadVerifiedVinyasaCourse(_MissingBundle()),
        throwsA(isA<FlutterError>()),
      );
    },
  );

  test('chair movement preparation expires across midnight and reset', () {
    var now = DateTime(2026, 10, 4, 23, 59, 59);
    final preparation = HathaSessionPreparation(now: () => now)..acknowledge();
    expect(preparation.acknowledged, isTrue);
    now = DateTime(2026, 10, 5);
    expect(preparation.acknowledged, isFalse);
    preparation.acknowledge();
    preparation.reset();
    expect(preparation.acknowledged, isFalse);
    for (final lesson in _vinyasa().lessons) {
      expect(
        HathaSessionPreparation.requiredFor(lesson.id),
        lesson.id != 'v01' && lesson.id != 'v07',
      );
    }
  });

  for (final locale in const <String>['en', 'tr']) {
    for (var number = 1; number <= 10; number++) {
      final id = 'v${number.toString().padLeft(2, '0')}';
      testWidgets(
        '$id $locale large text: scroll, reveal, preparation and reset',
        (tester) async {
          final semantics = tester.ensureSemantics();

          tester.view.physicalSize = const Size(390, 844);
          tester.view.devicePixelRatio = 1;
          addTearDown(tester.view.resetPhysicalSize);
          addTearDown(tester.view.resetDevicePixelRatio);
          final course = _vinyasa();
          final lesson = course.lessonById(id)!;
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
          await tester.scrollUntilVisible(reveal, 300);
          final answer = id == 'v04' && locale == 'tr'
              ? _reviewedV04AnswerTurkish
              : locale == 'tr'
              ? lesson.answerKey!.tr
              : lesson.answerKey!.en;
          expect(find.text(answer), findsNothing);
          await tester.ensureVisible(reveal);
          await _tap(tester, reveal);
          await tester.pumpAndSettle();
          expect(find.text(answer), findsOneWidget);
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
          tester.binding.handleAppLifecycleStateChanged(
            AppLifecycleState.inactive,
          );
          tester.binding.handleAppLifecycleStateChanged(
            AppLifecycleState.hidden,
          );
          tester.binding.handleAppLifecycleStateChanged(
            AppLifecycleState.paused,
          );
          await tester.pump();
          tester.binding.handleAppLifecycleStateChanged(
            AppLifecycleState.hidden,
          );
          tester.binding.handleAppLifecycleStateChanged(
            AppLifecycleState.inactive,
          );
          tester.binding.handleAppLifecycleStateChanged(
            AppLifecycleState.resumed,
          );
          await tester.pump();
          expect(store.writes, 0);
          expect(find.text(answer), findsNothing);
          await tester.pumpWidget(const SizedBox.shrink());
          await open();
          await tester.scrollUntilVisible(reveal, 300);
          expect(find.text(answer), findsNothing);
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

  testWidgets('real Home opens chair path then back returns Home', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(home: LissomShell(loader: () async => _facts())),
    );
    await tester.pumpAndSettle();
    final entry = find.byKey(const Key('home.vinyasaCourse'));
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
      _vinyasa().id,
    );
    await tester.pageBack();
    await tester.pumpAndSettle();
    expect(find.byType(HathaCourseScreen), findsNothing);
  });

  testWidgets('real Library family entry loads chair-specific course', (
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
    final button = find.text('Open supported standing Vinyasa');
    await tester.scrollUntilVisible(button, 300);
    await _tap(tester, button);
    await tester.pumpAndSettle();
    expect(
      tester
          .widget<HathaCourseScreen>(find.byType(HathaCourseScreen))
          .course
          .id,
      facts.vinyasa!.id,
    );
  });

  testWidgets('save failure leaves lesson open and retry records once', (
    tester,
  ) async {
    final course = _vinyasa();
    final store = _CountingStore()..fail = true;
    await tester.pumpWidget(
      MaterialApp(
        home: HathaLessonScreen(
          course: course,
          lesson: course.lessonById('v07')!,
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
    final course = _vinyasa();
    final lesson = course.lessonById('v04')!;
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
    final reveal = find.byKey(const Key('course.answer.v04'));
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
  test('v2 decoder has bilingual steps and taught support/exit prerequisites', () {
    final course = _vinyasa();
    expect(course.lessons.length, 10); // Identity contract, not skill completion.
    expect(course.lessonById('v04')!.steps[0].en, contains('feet stay fixed'));
    expect(course.lessonById('v04')!.steps[2].en, contains('slide palms'));
    expect(course.lessonById('v06')!.steps[0].tr, contains('sağ ayağı nötre geri getir'));
    for (final lesson in course.lessons) {
      expect(lesson.steps.length, 4);
      expect(lesson.answerKey, isNotNull);
      for (final step in lesson.steps) {
        expect(step.en.trim(), isNotEmpty);
        expect(step.tr.trim(), isNotEmpty);
      }
    }
    final raw = jsonDecode(File(kVinyasaCourseAssetPath).readAsStringSync()) as Map<String,dynamic>;
    final first = ((raw['modules'] as List).first as Map)['lessons'] as List;
    (first.first as Map)['prerequisites'] = ['unknown'];
    expect(() => HathaCourse.parse(jsonEncode(raw)), throwsFormatException);
  });
  test('Vinyasa records do not count as chair or Hatha participation', () {
    final vinyasa = _vinyasa();
    final chair = HathaCourse.parse(File('config/courses/chair-office.v1.json').readAsStringSync());
    final hatha = HathaCourse.parse(File('config/courses/hatha.v1.json').readAsStringSync());
    final records = HathaProgress(records: [
      HathaPracticeRecord(lessonId: 'v01', courseId: vinyasa.id,
        courseVersion: vinyasa.version, practicedAt: DateTime.utc(2026)),
      HathaPracticeRecord(lessonId: 'c01', courseId: chair.id,
        courseVersion: chair.version, practicedAt: DateTime.utc(2026)),
      HathaPracticeRecord(lessonId: 'h01', courseId: hatha.id,
        courseVersion: hatha.version, practicedAt: DateTime.utc(2026)),
    ], unreadableRecords: 0);
    expect(records.practicedIn(vinyasa), <String>{'v01'});
    expect(records.practicedIn(chair), <String>{'c01'});
    expect(records.practicedIn(hatha), <String>{'h01'});
  });

}
