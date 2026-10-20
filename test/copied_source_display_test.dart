// EXTERNAL DRAFT — UNRUN. Copy into app/test only after root accepts the
// reviewed catalogs, 14-locale infrastructure and EN/TR display clarifications.
// The separate reviewed-hash gate must pin catalog contents independently;
// this file checks the actual lesson -> localization -> rendered Text route.
// Synthetic preparation is not physical readiness, teaching or device evidence.
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

const _localeTags = <String>[
  'tr',
  'en',
  'es-419',
  'pt-BR',
  'de',
  'fr',
  'ja',
  'ar',
  'it',
  'ko',
  'id',
  'pl',
  'hi',
  'zh-Hans',
];

final class _DisplayAnchor {
  const _DisplayAnchor(
    this.name,
    this.courseFile,
    this.lessonId,
    this.stepIndex,
    this.sourceKey, {
    this.unsafeEnglish = false,
    this.unsafeTurkish = false,
  });

  final String name;
  final String courseFile;
  final String lessonId;
  final int stepIndex;
  final String sourceKey;
  final bool unsafeEnglish;
  final bool unsafeTurkish;
}

const _anchors = <_DisplayAnchor>[
  _DisplayAnchor(
    'h41 ordinary breath during movement pause',
    'hatha',
    'h41',
    2,
    'Choose two standing shapes, two seated/low shapes, one breathing pause and rest.',
    unsafeEnglish: true,
    unsafeTurkish: true,
  ),
  _DisplayAnchor(
    'h39 pelvis down before either hand lifts',
    'hatha',
    'h39',
    3,
    'Lower the seat before lifting either hand, then rest wrists without rolling onto them.',
    unsafeEnglish: true,
    unsafeTurkish: true,
  ),
  _DisplayAnchor(
    'h52 pelvis down then release hands',
    'hatha',
    'h52',
    3,
    'Bend at the hips to lower the seat slowly; only after sitting down release hands and rest the wrists.',
    unsafeEnglish: true,
    // The original Turkish already says slowly sit, then release hands.
  ),
  _DisplayAnchor(
    'v04 both palms stay on the wall',
    'vinyasa-standing',
    'v04',
    1,
    'Keeping both palms in contact and knees soft, move the hips a little back and incline the trunk only a little. Elbows may straighten comfortably, never lock. This limited high wall variation is a preparation related to Downward Dog, not its floor form; no horizontal torso or head-below-hips target.',
    unsafeEnglish: true,
    unsafeTurkish: true,
  ),
  _DisplayAnchor(
    'v04 second hand has its own support condition',
    'vinyasa-standing',
    'v04',
    3,
    'Once the familiar upright base and comfortable wall contact are restored, pause, then lower one hand to the thigh, followed by the other only if support is no longer needed. No foot approach occurs within this variation. If you cannot maintain comfortable contact/return at this distance, choose a shallower range or omit; do not improvise a backward/forward walking transition.',
    // The frozen English already attaches the condition to the second hand.
    unsafeTurkish: true,
  ),
];

final class _ViewportCase {
  const _ViewportCase(this.name, this.size, this.textScale);
  final String name;
  final Size size;
  final double textScale;
}

const _viewports = <_ViewportCase>[
  _ViewportCase('default 800x600 1x', Size(800, 600), 1),
  _ViewportCase('narrow 320x812 2x', Size(320, 812), 2),
];

final class _ActualCatalogBundle extends CachingAssetBundle {
  @override
  Future<ByteData> load(String key) async =>
      ByteData.sublistView(await File(key).readAsBytes());
}

Future<_ActualCatalogBundle> _readyCatalog(
  WidgetTester tester,
  String tag,
) async {
  final bundle = _ActualCatalogBundle();
  // Real file IO and the real >50 KiB AssetBundle decode complete on the real
  // clock. The very same cached bundle is passed to the real delegate below.
  final raw = await tester.runAsync(
    () => bundle
        .loadString('config/l10n/$tag.json')
        .timeout(const Duration(seconds: 10)),
  );
  expect(raw, isNotNull);
  expect(raw, isNotEmpty);
  final parsed = LissomLocalizations.parse(raw!, tag);
  expect(parsed.catalogAvailable, isTrue);
  for (final anchor in _anchors) {
    expect(
      parsed.lookup(anchor.sourceKey),
      isNotNull,
      reason: 'The reviewed source key must exist in the real $tag catalog.',
    );
  }
  return bundle;
}

final class _MemoryOnlyProgress implements HathaProgressStore {
  int reads = 0;
  int writes = 0;
  final List<HathaPracticeRecord> records = <HathaPracticeRecord>[];

  @override
  Future<HathaProgress> read() async {
    reads++;
    return HathaProgress(
      records: List<HathaPracticeRecord>.unmodifiable(records),
      unreadableRecords: 0,
    );
  }

  @override
  Future<void> markPracticed(HathaCourse course, String lessonId) async {
    writes++;
    throw StateError(
      'A display-only regression must not record participation.',
    );
  }
}

Future<void> _waitForLessonCatalog(WidgetTester tester, String tag) async {
  final ready = await tester.runAsync(() async {
    final elapsed = Stopwatch()..start();
    while (elapsed.elapsed < const Duration(seconds: 10)) {
      await tester.pump(const Duration(milliseconds: 16));
      final mounted = find.byType(HathaLessonScreen).evaluate();
      if (mounted.length == 1) {
        final context = mounted.single;
        final catalog = LissomLocalizations.maybeOf(context);
        if (catalog != null &&
            catalog.catalogAvailable &&
            catalog.tag == tag &&
            canonicalLocaleTag(Localizations.localeOf(context)) == tag) {
          return true;
        }
      }
      await Future<void>.delayed(const Duration(milliseconds: 10));
    }
    return false;
  });
  expect(
    ready,
    isTrue,
    reason: 'The real localized lesson must mount within 10 seconds.',
  );
}

String _numbered(String template, String number, String text) =>
    template.replaceAll('{number}', number).replaceAll('{text}', text);

Future<void> _reveal(WidgetTester tester, Finder target) async {
  final scrollable = find
      .descendant(
        of: find.byType(HathaLessonScreen),
        matching: find.byType(Scrollable),
      )
      .first;
  await tester.scrollUntilVisible(
    target,
    220,
    scrollable: scrollable,
    maxScrolls: 150,
  );
  await Scrollable.ensureVisible(tester.element(target), alignment: 0.05);
  await tester.pump(const Duration(milliseconds: 100));
  expect(target, findsOneWidget);
  expect(
    tester.getRect(target).overlaps(tester.getRect(scrollable)),
    isTrue,
    reason: 'The real lesson paragraph must overlap the real viewport.',
  );
}

void main() {
  for (final tag in _localeTags) {
    for (final viewport in _viewports) {
      testWidgets('reviewed physical display $tag / ${viewport.name}', (
        tester,
      ) async {
        // Fail explicitly before a partial 8-locale app can masquerade as 14.
        expect(
          kLissomSupportedLocales.map(canonicalLocaleTag).toSet(),
          unorderedEquals(_localeTags),
        );
        final locale = lissomLocaleForTag(tag);
        expect(locale, isNotNull);
        tester.view.physicalSize = viewport.size;
        tester.view.devicePixelRatio = 1;
        addTearDown(tester.view.resetPhysicalSize);
        addTearDown(tester.view.resetDevicePixelRatio);
        final bundle = await _readyCatalog(tester, tag);
        final courses = <String, HathaCourse>{
          for (final file in <String>{
            for (final anchor in _anchors) anchor.courseFile,
          })
            file: HathaCourse.parse(
              File('config/courses/$file.v1.json').readAsStringSync(),
            ),
        };
        final store = _MemoryOnlyProgress();
        final visited = <String>{};
        for (final route in _anchors) {
          final routeId = '${route.courseFile}/${route.lessonId}';
          if (!visited.add(routeId)) continue;
          final course = courses[route.courseFile]!;
          final lesson = course.lessonById(route.lessonId)!;
          final preparation = HathaSessionPreparation(
            now: () => DateTime(2026, 10, 20, 12),
          )..acknowledge();
          expect(preparation.acknowledged, isTrue);
          try {
            await tester.pumpWidget(
              MaterialApp(
                locale: locale!,
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
                  ).copyWith(textScaler: TextScaler.linear(viewport.textScale)),
                  child: child!,
                ),
                home: HathaLessonScreen(
                  course: course,
                  lesson: lesson,
                  store: store,
                  isRepeat: false,
                  preparation: preparation,
                ),
              ),
            );
            await _waitForLessonCatalog(tester, tag);
            final screen = find.byType(HathaLessonScreen);
            final context = tester.element(screen);
            final catalog = LissomLocalizations.maybeOf(context)!;
            expect(MediaQuery.sizeOf(context), viewport.size);
            expect(
              MediaQuery.textScalerOf(context).scale(1),
              viewport.textScale,
            );
            expect(
              Directionality.of(context),
              tag == 'ar' ? TextDirection.rtl : TextDirection.ltr,
            );
            expect(find.byType(HathaSessionPreparationCard), findsNothing);
            for (final anchor in _anchors.where(
              (item) =>
                  item.courseFile == route.courseFile &&
                  item.lessonId == route.lessonId,
            )) {
              final source = lesson.steps[anchor.stepIndex];
              expect(
                source.en,
                anchor.sourceKey,
                reason: '${anchor.name}: actual parsed course source drifted.',
              );
              // No localeText/hathaText/configText helper is used as oracle.
              // Reviewed catalog bytes are pinned by the separate hash gate.
              final expected = catalog.lookup(anchor.sourceKey);
              expect(expected, isNotNull, reason: anchor.name);
              final template = catalog.lookup('{number}. {text}');
              expect(template, isNotNull);
              final format = template!;
              final number = MaterialLocalizations.of(
                context,
              ).formatDecimal(anchor.stepIndex + 1);
              final displayed = _numbered(format, number, expected!);
              final text = find.descendant(
                of: screen,
                matching: find.text(displayed),
              );
              await _reveal(tester, text);
              // These explicit negative oracles fail if EN/TR's old ambiguous
              // inline source bypasses the accepted displayed catalog value.
              final unsafeSource = tag == 'en' && anchor.unsafeEnglish
                  ? source.en
                  : tag == 'tr' && anchor.unsafeTurkish
                  ? source.tr
                  : null;
              if (unsafeSource != null) {
                expect(
                  expected,
                  isNot(unsafeSource),
                  reason:
                      '${anchor.name}: catalog still contains ambiguous original.',
                );
                expect(
                  find.descendant(
                    of: screen,
                    matching: find.text(
                      _numbered(format, number, unsafeSource),
                    ),
                  ),
                  findsNothing,
                );
                expect(
                  find.descendant(
                    of: screen,
                    matching: find.text(unsafeSource),
                  ),
                  findsNothing,
                );
              }
              expect(store.writes, 0);
              expect(store.records, isEmpty);
              expect(tester.takeException(), isNull, reason: anchor.name);
            }
          } finally {
            // Dispose the actual screen and its day-boundary timer per route.
            await tester.pumpWidget(const SizedBox.shrink());
            await tester.pump();
            expect(store.writes, 0);
            expect(store.records, isEmpty);
          }
        }
        expect(visited.length, 4);
        expect(store.writes, 0);
        expect(store.records, isEmpty);
      });
    }
  }
}
