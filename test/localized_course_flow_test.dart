// Eight prepared widget flows, one per product locale. UNRUN until the normal
// coordinated Flutter test path is admitted. The store below is a serialized
// in-memory journal: these tests make no JSONL/disk, device, camera, physical
// teaching, assistive-technology or store-release acceptance claim.
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lissom/app/hatha_course.dart';
import 'package:lissom/app/hatha_course_screen.dart';
import 'package:lissom/app/hatha_progress.dart';
import 'package:lissom/app/hatha_session_preparation.dart';
import 'package:lissom/app/lissom_locales.dart';
import 'package:lissom/app/lissom_localizations.dart';
import 'package:lissom/app/lissom_theme.dart';

final class _CourseFlowCase {
  const _CourseFlowCase(this.tag, this.courseFile);
  final String tag;
  final String courseFile;
}

const _cases = <_CourseFlowCase>[
  _CourseFlowCase('en', 'hatha'),
  _CourseFlowCase('tr', 'ashtanga-foundations'),
  _CourseFlowCase('es-419', 'chair-office'),
  _CourseFlowCase('pt-BR', 'vinyasa-standing'),
  _CourseFlowCase('de', 'yin-supported'),
  _CourseFlowCase('fr', 'hatha'),
  _CourseFlowCase('ja', 'chair-office'),
  _CourseFlowCase('ar', 'ashtanga-foundations'),
];

final class _ActualCatalogBundle extends CachingAssetBundle {
  @override
  Future<ByteData> load(String key) async =>
      ByteData.sublistView(File(key).readAsBytesSync());
}

Future<_ActualCatalogBundle> _readyCatalog(
  WidgetTester tester,
  Locale locale,
) async {
  final bundle = _ActualCatalogBundle();
  // Keep the real >50 KiB AssetBundle isolate decode, but await its cached
  // Future outside the fake clock instead of treating settled frames as ready.
  final raw = await tester.runAsync(
    () => bundle.loadString('config/l10n/${canonicalLocaleTag(locale)}.json'),
  );
  expect(raw, isNotNull, reason: 'The actual catalog must finish loading.');
  expect(raw, isNotEmpty);
  return bundle;
}

HathaCourse _course(String file) =>
    HathaCourse.parse(File('config/courses/$file.v1.json').readAsStringSync());

/// Reconstructs records from the actual v1 serialization on every read. It has
/// no File, owner, path-provider, queue or native-platform implementation.
final class _MemoryJournalStore implements HathaProgressStore {
  _MemoryJournalStore(List<HathaPracticeRecord> initial)
    : _rows = <Map<String, dynamic>>[
        for (final record in initial)
          Map<String, dynamic>.from(record.toJson()),
      ];

  final List<Map<String, dynamic>> _rows;
  int reads = 0;
  int writes = 0;

  HathaProgress get snapshot => HathaProgress(
    records: List<HathaPracticeRecord>.unmodifiable(
      _rows.map(
        (row) => HathaPracticeRecord.parse(Map<String, dynamic>.from(row)),
      ),
    ),
    unreadableRecords: 0,
  );

  List<Map<String, dynamic>> get copiedRows => <Map<String, dynamic>>[
    for (final row in _rows) Map<String, dynamic>.from(row),
  ];

  @override
  Future<HathaProgress> read() async {
    reads++;
    return snapshot;
  }

  @override
  Future<void> markPracticed(HathaCourse course, String lessonId) async {
    final lesson = course.lessonById(lessonId);
    if (lesson == null) throw ArgumentError.value(lessonId, 'lessonId');
    final practiced = snapshot.practicedIn(course);
    if (!lesson.prerequisites.every(practiced.contains)) {
      throw StateError('Synthetic journal requires the lesson prerequisites');
    }
    if (practiced.contains(lessonId)) return;
    _rows.add(
      Map<String, dynamic>.from(
        HathaPracticeRecord(
          lessonId: lessonId,
          courseId: course.id,
          courseVersion: course.version,
          practicedAt: DateTime.utc(2026, 10, 20, 12),
        ).toJson(),
      ),
    );
    writes++;
  }
}

// Expectations read real catalog values independently of localeText,
// localeTemplate and hathaText. Turkish keeps each caller's source context.
String _phrase(BuildContext context, String english, String turkish) {
  final catalog = LissomLocalizations.maybeOf(context);
  expect(catalog, isNotNull);
  final available = catalog!;
  expect(available.catalogAvailable, isTrue);
  final translated = available.lookup(english);
  expect(translated, isNotNull, reason: 'Missing actual catalog key: $english');
  return switch (canonicalLocaleTag(Localizations.localeOf(context))) {
    'tr' => turkish,
    'en' => english,
    _ => translated!,
  };
}

String _text(BuildContext context, HathaText text) =>
    _phrase(context, text.en, text.tr);

String _render(String template, Map<String, String> arguments) =>
    template.replaceAllMapped(
      RegExp(r'\{([A-Za-z][A-Za-z0-9_]*)\}'),
      (match) => arguments[match.group(1)]!,
    );

String _progressText(
  BuildContext context,
  HathaCourse course,
  int done,
) => _render(
  _phrase(
    context,
    course.recordsParticipation
        ? '{done} participation records across {total} units; physical skill is not established.'
        : '{done} of {total} lessons practised',
    course.recordsParticipation
        ? '{total} birimde {done} katılım kaydı; fiziksel beceri gösterilmez.'
        : '{total} dersten {done} tanesi çalışıldı',
  ),
  <String, String>{
    'done': MaterialLocalizations.of(context).formatDecimal(done),
    'total': MaterialLocalizations.of(
      context,
    ).formatDecimal(course.lessons.length),
  },
);

Finder _scrollableWithin(Finder screen) =>
    find.descendant(of: screen, matching: find.byType(Scrollable)).first;

Future<void> _reveal(
  WidgetTester tester,
  Finder target,
  Finder screen, {
  double delta = 280,
}) async {
  // The real first Yin self-check is intentionally long. A bounded scroll
  // traverses the genuine lesson instead of replacing it with a short fixture.
  await tester.scrollUntilVisible(
    target,
    delta,
    scrollable: _scrollableWithin(screen),
    maxScrolls: 250,
  );
  await tester.pumpAndSettle();
  expect(target, findsOneWidget);
  await Scrollable.ensureVisible(tester.element(target), alignment: 0.5);
  await tester.pumpAndSettle();
  expect(tester.takeException(), isNull);
}

void main() {
  for (final scenario in _cases) {
    testWidgets(
      'actual course save and return ${scenario.tag}/${scenario.courseFile} at 320px and 2x text',
      (tester) async {
        tester.view.physicalSize = const Size(320, 812);
        tester.view.devicePixelRatio = 1;
        addTearDown(tester.view.resetPhysicalSize);
        addTearDown(tester.view.resetDevicePixelRatio);

        final course = _course(scenario.courseFile);
        final first = course.lessons.first;
        final second = course.lessons[1];
        expect(first.prerequisites, isEmpty);
        final unrelated = _course(
          scenario.courseFile == 'hatha' ? 'chair-office' : 'hatha',
        );
        final original = <HathaPracticeRecord>[
          HathaPracticeRecord(
            lessonId: unrelated.lessons.first.id,
            courseId: unrelated.id,
            courseVersion: unrelated.version,
            practicedAt: DateTime.utc(2026, 10, 18),
          ),
          HathaPracticeRecord(
            lessonId: first.id,
            courseId: course.id,
            courseVersion: '${course.version}-older',
            practicedAt: DateTime.utc(2026, 10, 18),
          ),
        ];
        final store = _MemoryJournalStore(original);
        final before = store.copiedRows;
        final locale = lissomLocaleForTag(scenario.tag)!;
        final bundle = await _readyCatalog(tester, locale);
        var storeOpens = 0;
        await tester.pumpWidget(
          MaterialApp(
            locale: locale,
            supportedLocales: kLissomSupportedLocales,
            localeListResolutionCallback: resolveLissomLocale,
            localizationsDelegates: <LocalizationsDelegate<dynamic>>[
              LissomLocalizationsDelegate(bundle: bundle),
              ...GlobalMaterialLocalizations.delegates,
            ],
            theme: buildLissomTheme(),
            builder: (context, child) => MediaQuery(
              data: MediaQuery.of(
                context,
              ).copyWith(textScaler: const TextScaler.linear(2)),
              child: child!,
            ),
            home: HathaCourseScreen(
              course: course,
              initialProgress: store.snapshot,
              storeLoader: () async {
                storeOpens++;
                return store;
              },
            ),
          ),
        );
        await tester.pumpAndSettle();

        final courseScreen = find.byType(HathaCourseScreen);
        var context = tester.element(courseScreen);
        expect(
          canonicalLocaleTag(Localizations.localeOf(context)),
          scenario.tag,
        );
        expect(MediaQuery.sizeOf(context).width, 320);
        expect(MediaQuery.textScalerOf(context).scale(1), 2);
        final direction = scenario.tag == 'ar'
            ? TextDirection.rtl
            : TextDirection.ltr;
        expect(Directionality.of(context), direction);
        expect(find.text(_text(context, course.title)), findsOneWidget);
        final progressCard = find.byKey(HathaCourseScreen.progressKey);
        await _reveal(tester, progressCard, courseScreen);
        expect(
          find.descendant(
            of: progressCard,
            matching: find.text(_progressText(context, course, 0)),
          ),
          findsOneWidget,
        );

        final continueButton = find.byKey(HathaCourseScreen.continueKey);
        await _reveal(tester, continueButton, courseScreen);
        final firstLabel = _render(
          _phrase(context, 'Continue: {title}', 'Devam et: {title}'),
          <String, String>{'title': _text(context, first.title)},
        );
        expect(
          find.descendant(of: continueButton, matching: find.text(firstLabel)),
          findsOneWidget,
        );
        await tester.tap(continueButton);
        await tester.pumpAndSettle();

        final lessonScreen = find.byType(HathaLessonScreen);
        expect(lessonScreen, findsOneWidget);
        final lessonWidget = tester.widget<HathaLessonScreen>(lessonScreen);
        expect(lessonWidget.course.id, course.id);
        expect(lessonWidget.lesson.id, first.id);
        expect(lessonWidget.previewOnly, isFalse);
        context = tester.element(lessonScreen);
        expect(Directionality.of(context), direction);
        final objective = find.text(_text(context, first.objective));
        await _reveal(tester, objective, lessonScreen);

        if (HathaSessionPreparation.requiredFor(first.id)) {
          expect(find.byKey(HathaLessonScreen.practiceKey), findsNothing);
          final prepared = find.byKey(const Key('hatha.session.prepared'));
          await _reveal(tester, prepared, lessonScreen);
          await tester.tap(prepared);
          await tester.pumpAndSettle();
        }

        final selfCheck = find.text(_text(context, first.selfCheck));
        await _reveal(tester, selfCheck, lessonScreen);
        final stopText = find.text(_text(context, first.stopSignal));
        await _reveal(tester, stopText, lessonScreen);
        expect(store.writes, 0);

        final save = find.byKey(HathaLessonScreen.practiceKey);
        await _reveal(tester, save, lessonScreen);
        expect(tester.widget<FilledButton>(save).onPressed, isNull);
        final reflection = find.byKey(HathaLessonScreen.reflectionKey);
        await _reveal(tester, reflection, lessonScreen, delta: -280);
        expect(tester.widget<CheckboxListTile>(reflection).value, isFalse);
        await tester.tap(reflection);
        await tester.pumpAndSettle();
        expect(tester.widget<CheckboxListTile>(reflection).value, isTrue);
        await _reveal(tester, save, lessonScreen);
        expect(tester.widget<FilledButton>(save).onPressed, isNotNull);
        await tester.tap(save);
        await tester.pumpAndSettle();

        expect(find.byType(HathaLessonScreen), findsNothing);
        expect(courseScreen, findsOneWidget);
        expect(storeOpens, 1);
        expect(store.writes, 1);
        expect(
          store.reads,
          1,
          reason:
              'The real course must read the store after the lesson route returns.',
        );
        expect(store.copiedRows.take(before.length).toList(), before);
        expect(store.copiedRows, hasLength(3));
        expect(store.copiedRows.last['evidence'], 'self_report');
        expect(store.copiedRows.last['courseId'], course.id);
        expect(store.copiedRows.last['courseVersion'], course.version);
        expect(store.copiedRows.last['lessonId'], first.id);
        final reopenedMemorySnapshot = await store.read();
        expect(reopenedMemorySnapshot.practicedIn(course), <String>{first.id});
        expect(reopenedMemorySnapshot.practicedIn(unrelated), <String>{
          unrelated.lessons.first.id,
        });
        expect(reopenedMemorySnapshot.oldVersionCount(course), 1);

        context = tester.element(courseScreen);
        await _reveal(tester, progressCard, courseScreen, delta: -280);
        expect(
          find.descendant(
            of: progressCard,
            matching: find.text(_progressText(context, course, 1)),
          ),
          findsOneWidget,
        );
        expect(
          find.descendant(
            of: progressCard,
            matching: find.text(_progressText(context, course, 0)),
          ),
          findsNothing,
        );
        await _reveal(tester, continueButton, courseScreen);
        final secondLabel = _render(
          _phrase(context, 'Continue: {title}', 'Devam et: {title}'),
          <String, String>{'title': _text(context, second.title)},
        );
        expect(
          find.descendant(of: continueButton, matching: find.text(secondLabel)),
          findsOneWidget,
        );

        if (scenario.tag == 'tr') {
          final standing = course.modules.singleWhere(
            (module) => module.title.en == 'Standing foundations',
          );
          await _reveal(tester, find.text(standing.title.tr), courseScreen);
          expect(standing.title.tr, 'Ayakta temeller');
          expect(find.text(standing.title.tr), findsOneWidget);
        }
        expect(tester.takeException(), isNull);
        await tester.pumpWidget(const SizedBox.shrink());
        await tester.pump();
      },
    );
  }
}
