// Prepared reader/widget regressions. Execution is UNRUN until the coordinated
// normal Flutter SDK test path is admitted; source checks are not visual proof.
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lissom/app/hatha_course.dart';
import 'package:lissom/app/hatha_course_screen.dart';
import 'package:lissom/app/hatha_knowledge_diagrams.dart';
import 'package:lissom/app/lissom_locales.dart';
import 'package:lissom/app/lissom_localizations.dart';

const _courseNames = <String>[
  'hatha',
  'chair-office',
  'vinyasa-standing',
  'yin-supported',
  'ashtanga-foundations',
];

final class _ActualCatalogBundle extends CachingAssetBundle {
  @override
  Future<ByteData> load(String key) async {
    final bytes = File(key).readAsBytesSync();
    return ByteData.sublistView(bytes);
  }
}

Future<_ActualCatalogBundle> _readyCatalog(
  WidgetTester tester,
  Locale locale,
) async {
  final bundle = _ActualCatalogBundle();
  // Real catalogs exceed AssetBundle.loadString's 50 KiB isolate threshold.
  // Await that exact cached Future outside the fake clock before mounting;
  // pumpAndSettle only waits for frames, not an outstanding isolate decode.
  final raw = await tester.runAsync(
    () => bundle.loadString(
      'config/l10n/${canonicalLocaleTag(locale)}.json',
    ),
  );
  expect(raw, isNotNull, reason: 'The actual catalog must finish loading.');
  expect(raw, isNotEmpty);
  return bundle;
}

List<HathaCourse> _courses() => <HathaCourse>[
  for (final name in _courseNames)
    HathaCourse.parse(File('config/courses/$name.v1.json').readAsStringSync()),
];

Iterable<HathaText> _texts(HathaCourse course) sync* {
  yield course.title;
  yield course.intro;
  for (final scope in course.sourceScopes.values) {
    yield scope.supports;
    yield scope.doesNotSupport;
  }
  for (final module in course.modules) {
    yield module.title;
    yield module.outcome;
    for (final lesson in module.lessons) {
      yield lesson.title;
      yield lesson.objective;
      yield* lesson.steps;
      yield lesson.practice;
      yield lesson.selfCheck;
      if (lesson.answerKey case final HathaText answer) yield answer;
      yield lesson.adaptation;
      yield lesson.stopSignal;
      // Parsed content coverage only; mediaBrief has no current UI call site.
      yield lesson.mediaBrief;
    }
  }
}

Widget _app({
  required Locale locale,
  required Widget home,
  required AssetBundle bundle,
}) => MaterialApp(
  locale: locale,
  supportedLocales: kLissomSupportedLocales,
  localeListResolutionCallback: resolveLissomLocale,
  localizationsDelegates: <LocalizationsDelegate<dynamic>>[
    LissomLocalizationsDelegate(bundle: bundle),
    ...GlobalMaterialLocalizations.delegates,
  ],
  home: home,
);

void main() {
  test(
    'all existing course text frames are read without schema/data migration',
    () {
      final courses = _courses();
      expect(courses.length, 5);
      expect(courses.expand((course) => course.lessons).length, 103);
      expect(courses.expand(_texts).length, 1303);
      expect(
        courses.expand(_texts).map((text) => text.en).toSet().length,
        1127,
      );
    },
  );

  for (final locale in kLissomSupportedLocales) {
    final tag = canonicalLocaleTag(locale);
    testWidgets('actual parsed course reader and catalog coverage ($tag)', (
      tester,
    ) async {
      final courses = _courses();
      final bundle = await _readyCatalog(tester, locale);
      var checked = 0;
      await tester.pumpWidget(
        _app(
          locale: locale,
          bundle: bundle,
          home: Builder(
            builder: (context) {
              checked = 0;
              final catalog = LissomLocalizations.maybeOf(context)!;
              expect(catalog.catalogAvailable, isTrue);
              for (final course in courses) {
                for (final text in _texts(course)) {
                  expect(
                    catalog.lookup(text.en),
                    isNotNull,
                    reason: '$tag: ${course.id} reader key missing: ${text.en}',
                  );
                  final expected = tag == 'tr'
                      ? text.tr
                      : tag == 'en'
                      ? text.en
                      : catalog.lookup(text.en)!;
                  expect(hathaText(context, text), expected);
                  checked++;
                }
              }
              return Scaffold(
                body: SingleChildScrollView(
                  child: Column(
                    children: <Widget>[
                      for (final course in courses) ...<Widget>[
                        Text(
                          hathaText(context, course.title),
                          key: Key('reader.${course.id}.title'),
                        ),
                        Text(
                          hathaText(context, course.lessons.first.stopSignal),
                          key: Key('reader.${course.id}.stop'),
                        ),
                        Text(
                          hathaText(context, course.lessons.last.selfCheck),
                          key: Key('reader.${course.id}.last.selfCheck'),
                        ),
                      ],
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      );
      await tester.pumpAndSettle();
      expect(checked, 1303);
      for (final course in courses) {
        expect(find.byKey(Key('reader.${course.id}.title')), findsOneWidget);
      }
      expect(tester.takeException(), isNull);
    });

    testWidgets('diagram title and labels use actual locale catalog ($tag)', (
      tester,
    ) async {
      final bundle = await _readyCatalog(tester, locale);
      await tester.pumpWidget(
        _app(
          locale: locale,
          bundle: bundle,
          home: const Scaffold(
            body: SingleChildScrollView(
              child: HathaKnowledgeDiagrams(lessonId: 'h54'),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();
      final context = tester.element(find.byType(HathaKnowledgeDiagrams));
      final catalog = LissomLocalizations.maybeOf(context)!;
      expect(catalog.catalogAvailable, isTrue);
      final expectedTitle = tag == 'tr'
          ? 'Tek bacak hazırlığı'
          : tag == 'en'
          ? 'One-leg preparation'
          : catalog.lookup('One-leg preparation');
      final expectedLabel = tag == 'tr'
          ? 'Baş ve omuzlar yerde kalır.'
          : tag == 'en'
          ? 'Head and shoulders remain on the floor.'
          : catalog.lookup('Head and shoulders remain on the floor.');
      expect(expectedTitle, isNotNull);
      expect(expectedLabel, isNotNull);
      expect(find.text(expectedTitle!), findsOneWidget);
      expect(find.textContaining(expectedLabel!), findsOneWidget);
      expect(
        Directionality.of(context),
        tag == 'ar' ? TextDirection.rtl : TextDirection.ltr,
      );
      expect(tester.takeException(), isNull);
    });
  }

  testWidgets('Turkish course context variants survive global-key collisions', (
    tester,
  ) async {
    final courses = _courses();
    final bundle = await _readyCatalog(tester, const Locale('tr'));
    await tester.pumpWidget(
      _app(
        locale: const Locale('tr'),
        bundle: bundle,
        home: Builder(
          builder: (context) => Scaffold(
            body: Column(
              children: <Widget>[
                Text(hathaText(context, courses.first.modules[1].title)),
                Text(hathaText(context, courses.last.modules[1].title)),
              ],
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.text('Ayakta temel duruşlar'), findsOneWidget);
    expect(find.text('Ayakta temeller'), findsOneWidget);
  });
}
