// Defined regression coverage. Runtime results belong to the coordinated SDK
// run; writing these cases is not visual, native or localization acceptance.
import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lissom/app/lissom_locales.dart';
import 'package:lissom/app/lissom_localizations.dart';
import 'package:lissom/app/locale_text.dart';
import 'package:lissom/app/profile_screen.dart';

import 'support/facts_from_disk.dart';

final class _MemoryStore implements LocalePreferenceStore {
  _MemoryStore([this.value]);
  String? value;
  bool failWrite = false;
  Completer<void>? pending;
  int writes = 0;

  @override
  Future<String?> read() async => value;

  @override
  Future<void> write(String? tag) async {
    writes++;
    await pending?.future;
    if (failWrite) throw const FileSystemException('fixture write denied');
    value = tag;
  }
}

final class _CatalogBundle extends CachingAssetBundle {
  _CatalogBundle({this.missing = false});
  final bool missing;

  @override
  Future<ByteData> load(String key) async {
    if (missing) throw FlutterError('fixture catalog unavailable');
    final String tag = key.split('/').last.replaceAll('.json', '');
    final Map<String, Object> messages = <String, Object>{
      'Hello': '[$tag] Hello',
      'Value {value} on {date}': '{date} [$tag] {value}',
      for (final String source in <String>[
        'Cervical rotation',
        'right',
        'left',
        '{name} · {side}',
        'Reopen Lissom and check your records again.',
        'Of the {total} tests behind this line, {compared} is compared against a reference range and {uncompared} are reported without one — the second kind carries no verdict.',
        '{count} named · none in this build.',
        'Stand about {min}–{max} cm from the camera.',
        'Put the phone {min}–{max} cm off the floor.',
        'Face the camera square-on — more than {degrees}° of turn and the reading is not used.',
        'Forward trunk lean',
        'Sideways trunk tilt',
        'the measurement engine keeps a single tilt figure and cannot tell forward lean apart from sideways lean',
        '{first} and {last}',
        '{subject} — {reason}',
      ])
        source: '[$tag] $source',
      '{count} readings': <String, String>{
        for (final String form in <String>[
          'zero',
          'one',
          'two',
          'few',
          'many',
          'other',
        ])
          form: '$form {count}',
      },
    };
    final List<int> bytes = utf8.encode(
      jsonEncode(<String, Object>{
        'schemaVersion': 1,
        'id': 'lissom.l10n.$tag',
        'locale': tag,
        'messages': messages,
      }),
    );
    return Uint8List.fromList(bytes).buffer.asByteData();
  }
}

Widget _localized({
  Key? appKey,
  required Locale locale,
  required Widget child,
  AssetBundle? bundle,
}) => MaterialApp(
  key: appKey,
  locale: locale,
  supportedLocales: kLissomSupportedLocales,
  localeListResolutionCallback: resolveLissomLocale,
  localizationsDelegates: <LocalizationsDelegate<dynamic>>[
    LissomLocalizationsDelegate(bundle: bundle ?? _CatalogBundle()),
    ...GlobalMaterialLocalizations.delegates,
  ],
  home: Scaffold(body: child),
);

Widget _profileHost(
  LissomLocaleController controller, {
  bool missing = false,
  int ownerEpoch = 1,
}) => LissomLocaleHost(
  controller: controller,
  child: Builder(
    builder: (BuildContext context) => _localized(
      appKey: ValueKey<int>(ownerEpoch),
      locale: LissomLocaleScope.maybeOf(context)?.locale ?? const Locale('en'),
      bundle: _CatalogBundle(missing: missing),
      child: ProfileScreen(facts: factsFromDisk()),
    ),
  ),
);

Future<void> _reveal(
  WidgetTester tester,
  Finder target,
  Finder scrollable,
) async {
  await tester.scrollUntilVisible(target, 200, scrollable: scrollable);
  // A cached ListView child can be found before it is on screen. The final
  // ensureVisible jump needs a layout frame before its hit-test position is used.
  await tester.pumpAndSettle();
  await Scrollable.ensureVisible(tester.element(target), alignment: 0.5);
  await tester.pumpAndSettle();
  expect(target.hitTestable(), findsOneWidget);
}

Future<void> _tapRevealed(
  WidgetTester tester,
  Finder target,
  Finder scrollable,
) async {
  await _reveal(tester, target, scrollable);
  await tester.tap(target);
  await tester.pumpAndSettle();
}

void main() {
  test(
    'approved locale tags and device dialects resolve without account state',
    () {
      expect(kLissomSupportedLocales.map(canonicalLocaleTag).toList(), <String>[
        'en',
        'tr',
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
      ]);
      expect(
        resolveLissomLocale(<Locale>[const Locale('es', 'MX')], const []),
        const Locale('es', '419'),
      );
      expect(
        resolveLissomLocale(<Locale>[const Locale('pt', 'PT')], const []),
        const Locale('pt', 'BR'),
      );
      expect(
        resolveLissomLocale(<Locale>[
          const Locale('zz'),
          const Locale('ja', 'JP'),
        ], const []),
        const Locale('ja'),
      );
      expect(
        resolveLissomLocale(<Locale>[const Locale('zz')], const []),
        const Locale('en'),
      );
      expect(resolveLissomLocale(null, const []), const Locale('en'));
      expect(lissomLocaleForTag('es-MX'), isNull);
      expect(lissomLocaleForTag('pt'), isNull);
    },
  );

  test(
    'explicit Chinese script wins over region and preserves device order',
    () {
      const hans = Locale.fromSubtags(languageCode: 'zh', scriptCode: 'Hans');
      const vectors = <(List<Locale>?, Locale)>[
        (
          <Locale>[
            Locale.fromSubtags(
              languageCode: 'zh',
              scriptCode: 'Hant',
              countryCode: 'CN',
            ),
            Locale('ko'),
          ],
          Locale('ko'),
        ),
        (
          <Locale>[
            Locale.fromSubtags(
              languageCode: 'zh',
              scriptCode: 'Hant',
              countryCode: 'SG',
            ),
            Locale('hi'),
          ],
          Locale('hi'),
        ),
        (
          <Locale>[
            Locale.fromSubtags(
              languageCode: 'zh',
              scriptCode: 'Hans',
              countryCode: 'TW',
            ),
          ],
          hans,
        ),
        (
          <Locale>[
            Locale.fromSubtags(
              languageCode: 'zh',
              scriptCode: 'Hans',
              countryCode: 'HK',
            ),
          ],
          hans,
        ),
        (
          <Locale>[
            Locale.fromSubtags(
              languageCode: 'zh',
              scriptCode: 'Hans',
              countryCode: 'MO',
            ),
          ],
          hans,
        ),
        (
          <Locale>[
            Locale.fromSubtags(
              languageCode: 'zh',
              scriptCode: 'Latn',
              countryCode: 'CN',
            ),
            Locale('pl'),
          ],
          Locale('pl'),
        ),
        (
          <Locale>[
            Locale('zh', 'TW'),
            Locale('zz'),
            Locale('pt', 'PT'),
            Locale('ko'),
          ],
          Locale('pt', 'BR'),
        ),
        (<Locale>[Locale('ko'), hans], Locale('ko')),
        (<Locale>[], Locale('en')),
        (null, Locale('en')),
      ];
      for (final vector in vectors) {
        expect(
          resolveLissomLocale(vector.$1, const <Locale>[]),
          vector.$2,
          reason: 'Explicit independent expectation for ${vector.$1}',
        );
      }
      const rejected = <Locale>[
        Locale.fromSubtags(
          languageCode: 'zh',
          scriptCode: 'Hant',
          countryCode: 'CN',
        ),
        Locale.fromSubtags(
          languageCode: 'zh',
          scriptCode: 'Hant',
          countryCode: 'SG',
        ),
        Locale.fromSubtags(
          languageCode: 'zh',
          scriptCode: 'Hant',
          countryCode: 'TW',
        ),
        Locale.fromSubtags(
          languageCode: 'zh',
          scriptCode: 'Latn',
          countryCode: 'CN',
        ),
        Locale('zz'),
      ];
      for (final locale in rejected) {
        expect(isLissomLocaleSupported(locale), isFalse);
        expect(
          const LissomLocalizationsDelegate().isSupported(locale),
          isFalse,
        );
      }
      for (final region in <String>['TW', 'HK', 'MO']) {
        final locale = Locale.fromSubtags(
          languageCode: 'zh',
          scriptCode: 'Hans',
          countryCode: region,
        );
        expect(isLissomLocaleSupported(locale), isTrue);
        expect(const LissomLocalizationsDelegate().isSupported(locale), isTrue);
      }
    },
  );

  test(
    'Chinese script selection respects the next supported device language',
    () {
      const simplified = Locale.fromSubtags(
        languageCode: 'zh',
        scriptCode: 'Hans',
      );
      const traditional = Locale.fromSubtags(
        languageCode: 'zh',
        scriptCode: 'Hant',
      );
      for (final locale in <Locale>[
        const Locale('zh'),
        const Locale('zh', 'CN'),
        const Locale('zh', 'SG'),
        simplified,
      ]) {
        expect(resolveLissomLocale(<Locale>[locale], const []), simplified);
        expect(isLissomLocaleSupported(locale), isTrue);
      }
      for (final locale in <Locale>[
        traditional,
        const Locale('zh', 'TW'),
        const Locale('zh', 'HK'),
        const Locale('zh', 'MO'),
      ]) {
        expect(
          resolveLissomLocale(<Locale>[locale, const Locale('ko')], const []),
          const Locale('ko'),
        );
        expect(
          resolveLissomLocale(<Locale>[locale], const []),
          const Locale('en'),
        );
        expect(
          const LissomLocalizationsDelegate().isSupported(locale),
          isFalse,
        );
      }
      expect(lissomLocaleForTag('zh-Hans'), simplified);
      expect(lissomLocaleForTag('zh-Hant'), isNull);
      expect(lissomLocaleForTag('zh'), isNull);
    },
  );

  test('new integer cardinal boundaries preserve Polish and Hindi grammar', () {
    for (final n in <int>[0, 5, 11, 12, 14, 21, 25, 101, 112]) {
      expect(lissomPluralCategory('pl', n), 'many');
    }
    expect(lissomPluralCategory('pl', 1), 'one');
    for (final n in <int>[2, 3, 4, 22, 24, 102, 104, -22]) {
      expect(lissomPluralCategory('pl', n), 'few');
    }
    expect(lissomPluralCategory('hi', 0), 'one');
    expect(lissomPluralCategory('hi', 1), 'one');
    expect(lissomPluralCategory('hi', 2), 'other');
    expect(lissomPluralCategory('it', 1), 'one');
    expect(lissomPluralCategory('it', 1000000), 'many');
    expect(lissomPluralCategory('it', 1000001), 'other');
    for (final tag in <String>['ja', 'ko', 'id', 'zh-Hans']) {
      for (final n in <int>[0, 1, 2, 12, 1000000]) {
        expect(lissomPluralCategory(tag, n), 'other');
      }
    }
  });

  for (final String tag in kLissomLanguageNames.keys) {
    test(
      '$tag preference survives file close/reopen without changing journals',
      () async {
        final Directory temp = await Directory.systemTemp.createTemp(
          'lissom-locale-',
        );
        addTearDown(() => temp.delete(recursive: true));
        final File journal = File('${temp.path}/lissom/hatha_progress.jsonl');
        await journal.parent.create(recursive: true);
        await journal.writeAsString('unchanged legacy fixture\n', flush: true);
        final List<int> original = await journal.readAsBytes();
        final File file = File(
          '${temp.path}/lissom-preferences/locale.v1.json',
        );
        final FileLocalePreferenceStore store = FileLocalePreferenceStore(file);
        expect(await store.read(), isNull);
        await store.write(tag);
        final LissomLocaleController reopened = LissomLocaleController(
          store: FileLocalePreferenceStore(File(file.path)),
        );
        addTearDown(reopened.dispose);
        await reopened.initialize();
        expect(reopened.tag, tag);
        expect(reopened.readFailed, isFalse);
        expect(await journal.readAsBytes(), original);
        await reopened.select(null);
        expect(await FileLocalePreferenceStore(File(file.path)).read(), isNull);
      },
    );
  }

  for (final String raw in <String>[
    '{bad',
    '[]',
    '{"schemaVersion":2,"locale":"ja"}',
    '{"schemaVersion":1,"locale":"xx"}',
    '{"schemaVersion":1,"locale":42}',
  ]) {
    test(
      'corrupt or unsupported preference falls back without rewriting: $raw',
      () async {
        final Directory temp = await Directory.systemTemp.createTemp(
          'lissom-locale-',
        );
        addTearDown(() => temp.delete(recursive: true));
        final File file = File('${temp.path}/locale.v1.json');
        await file.writeAsString(raw);
        final LissomLocaleController controller = LissomLocaleController(
          store: FileLocalePreferenceStore(file),
        );
        addTearDown(controller.dispose);
        await controller.initialize();
        expect(controller.isReady, isTrue);
        expect(controller.tag, isNull);
        expect(controller.readFailed, isTrue);
        expect(await file.readAsString(), raw);
        expect(await controller.select('fr'), isTrue);
        expect(controller.readFailed, isFalse);
        expect(await FileLocalePreferenceStore(file).read(), 'fr');
      },
    );
  }

  test('failed write retains previous language and reports failure', () async {
    final _MemoryStore store = _MemoryStore('de')..failWrite = true;
    final LissomLocaleController controller = LissomLocaleController(
      store: store,
    );
    addTearDown(controller.dispose);
    await controller.initialize();
    expect(await controller.select('ja'), isFalse);
    expect(controller.tag, 'de');
    expect(store.value, 'de');
    expect(controller.writeFailed, isTrue);
    store.failWrite = false;
    expect(await controller.select('ja'), isTrue);
    expect(controller.writeFailed, isFalse);
  });

  test(
    'pending preference write admits one selection and changes after success',
    () async {
      final _MemoryStore store = _MemoryStore('en')
        ..pending = Completer<void>();
      final LissomLocaleController controller = LissomLocaleController(
        store: store,
      );
      addTearDown(controller.dispose);
      await controller.initialize();
      final Future<bool> first = controller.select('ar');
      expect(controller.isSaving, isTrue);
      expect(controller.tag, 'en');
      expect(await controller.select('ja'), isFalse);
      store.pending!.complete();
      expect(await first, isTrue);
      expect(controller.tag, 'ar');
      expect(store.writes, 1);
    },
  );

  test('catalog rejects placeholder loss and invalid plural values', () {
    String catalog(Object messages) => jsonEncode(<String, Object>{
      'schemaVersion': 1,
      'id': 'lissom.l10n.ar',
      'locale': 'ar',
      'messages': messages,
    });
    expect(
      () => LissomLocalizations.parse(
        catalog(<String, Object>{'Item {count}': 'عنصر'}),
        'ar',
      ),
      throwsFormatException,
    );
    expect(
      () => LissomLocalizations.parse(
        catalog(<String, Object>{'Item {count}': '{count} {count}'}),
        'ar',
      ),
      throwsFormatException,
    );
    expect(
      () => LissomLocalizations.parse(
        catalog(<String, Object>{
          'Item {count}': <String, String>{'one': '{count} عنصر'},
        }),
        'ar',
      ),
      throwsFormatException,
    );
    expect(
      () => LissomLocalizations.parse(
        catalog(<String, Object>{
          'Item {count}': <String, String>{
            'other': '{count} عنصر',
            'bogus': '{count}',
          },
        }),
        'ar',
      ),
      throwsFormatException,
    );
    final Map<String, dynamic> wrongIdentity =
        jsonDecode(catalog(<String, Object>{'Item {count}': '{count} عنصر'}))
            as Map<String, dynamic>;
    wrongIdentity['id'] = 'another.app.catalog';
    expect(
      () => LissomLocalizations.parse(jsonEncode(wrongIdentity), 'ar'),
      throwsFormatException,
    );
  });

  test(
    'integer plural categories cover Arabic forms and approved dialects',
    () {
      expect(
        <int>[
          0,
          1,
          2,
          3,
          10,
          11,
          99,
          100,
          102,
          103,
          -3,
        ].map((int count) => lissomPluralCategory('ar', count)).toList(),
        <String>[
          'zero',
          'one',
          'two',
          'few',
          'few',
          'many',
          'many',
          'other',
          'other',
          'few',
          'few',
        ],
      );
      expect(lissomPluralCategory('ja', 1), 'other');
      expect(lissomPluralCategory('fr', 0), 'one');
      expect(lissomPluralCategory('pt-BR', 0), 'one');
      expect(lissomPluralCategory('de', 0), 'other');
      expect(lissomPluralCategory('es-419', 1000000), 'many');
    },
  );

  for (final Locale locale in kLissomSupportedLocales) {
    final String tag = canonicalLocaleTag(locale);
    for (final Size size in <Size>[
      const Size(320, 568),
      const Size(900, 1100),
    ]) {
      testWidgets(
        '$tag formats template/date/number on ${size.width} width at large text',
        (WidgetTester tester) async {
          tester.view.physicalSize = size;
          tester.view.devicePixelRatio = 1;
          addTearDown(tester.view.resetPhysicalSize);
          addTearDown(tester.view.resetDevicePixelRatio);
          await tester.pumpWidget(
            _localized(
              locale: locale,
              child: Builder(
                builder: (BuildContext context) => MediaQuery(
                  data: MediaQuery.of(
                    context,
                  ).copyWith(textScaler: const TextScaler.linear(2)),
                  // These are formatter probes, so eagerly mount each one.
                  // A ListView can omit the final LTR probe behind long dates.
                  child: SingleChildScrollView(
                    child: Column(
                      children: <Widget>[
                        Text(localeText(context, 'Hello', 'Merhaba')),
                        Text(
                          localeTemplate(
                            context,
                            'Value {value} on {date}',
                            '{date} tarihinde {value}',
                            <String, Object>{
                              'value': localizedDecimal(context, 1234.5),
                              'date': localizedDate(
                                context,
                                DateTime(2026, 10, 19),
                              ),
                            },
                          ),
                        ),
                        Text(
                          localeText(
                            context,
                            'Unknown source stays visible',
                            'Bilinmeyen kaynak görünür kalır',
                          ),
                        ),
                        Text(
                          localizedDate(
                            context,
                            DateTime.utc(2026, 10, 19, 23, 58),
                          ),
                          key: const Key('locale.fixture.date'),
                        ),
                        Text(
                          Directionality.of(context) == TextDirection.rtl
                              ? 'rtl'
                              : 'ltr',
                          key: const Key('locale.fixture.direction'),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          );
          await tester.pumpAndSettle();
          expect(
            find.text(
              tag == 'tr'
                  ? 'Merhaba'
                  : tag == 'en'
                  ? 'Hello'
                  : '[$tag] Hello',
            ),
            findsOneWidget,
          );
          final Finder direction = find.byKey(
            const Key('locale.fixture.direction'),
          );
          await tester.ensureVisible(direction);
          await tester.pumpAndSettle();
          expect(direction.hitTestable(), findsOneWidget);
          expect(find.text(tag == 'ar' ? 'rtl' : 'ltr'), findsOneWidget);
          expect(
            find.text(
              tag == 'tr'
                  ? 'Bilinmeyen kaynak görünür kalır'
                  : 'Unknown source stays visible',
            ),
            findsOneWidget,
          );
          final BuildContext context = tester.element(
            find.byKey(const Key('locale.fixture.date')),
          );
          final DateTime timestamp = DateTime.utc(2026, 10, 19, 23, 58);
          final String date = tester
              .widget<Text>(find.byKey(const Key('locale.fixture.date')))
              .data!;
          final MaterialLocalizations material = MaterialLocalizations.of(
            context,
          );
          final String year = material.formatYear(timestamp.toLocal());
          expect(date, contains(year));
          if (tag == 'ar') {
            expect(year, '٢٠٢٦');
          }
          expect(date, material.formatFullDate(timestamp.toLocal()));
          final String decimal = localizedDecimal(context, 12.5);
          final String separator =
              const <String>{
                'tr',
                'pt-BR',
                'de',
                'fr',
                'it',
                'id',
                'pl',
              }.contains(tag)
              ? ','
              : '.';
          expect(
            decimal,
            '${material.formatDecimal(12)}$separator${material.formatDecimal(5)}',
          );
          final String configNumber = localizedConfigNumber(context, 10.25);
          expect(
            configNumber,
            '${material.formatDecimal(10)}$separator'
            '${material.formatDecimal(2)}${material.formatDecimal(5)}',
            reason: 'configuration tolerances must not round to whole degrees',
          );
          if (tag == 'ar') {
            // Material's date/year and decimal formatters use independent
            // locale data: this SDK renders the Arabic year as ٢٠٢٦, while
            // formatDecimal and these display helpers use Western digits.
            expect(material.formatDecimal(12), '12');
            expect(decimal, '12.5');
            expect(configNumber, '10.25');
          }
          expect(() => localizedDecimal(context, 1e20), returnsNormally);
          expect(() => localizedDecimal(context, -1e20), returnsNormally);
          expect(localizedDecimal(context, double.nan), '—');
          final List<String> typedConfig = <String>[
            'Cervical rotation · right',
            'Of the 3 tests behind this line, 1 is compared against a reference range and 2 are reported without one — the second kind carries no verdict.',
            '4 named · none in this build.',
            'Stand about 100–200 cm from the camera.',
            'Put the phone 50–80 cm off the floor.',
            'Face the camera square-on — more than 10° of turn and the reading is not used.',
            'Forward trunk lean and Sideways trunk tilt — the measurement engine keeps a single tilt figure and cannot tell forward lean apart from sideways lean',
          ];
          for (final String source in typedConfig) {
            final String translated = configText(context, source);
            expect(translated, tag == 'en' ? source : isNot(source));
            if (tag != 'tr' && tag != 'en') {
              expect(translated, contains('[$tag]'));
            }
          }
          expect(
            configText(context, 'unknown-user-id · right'),
            'unknown-user-id · right',
          );
          expect(
            configText(context, 'Hold time — unknown message'),
            'Hold time — unknown message',
          );
          expect(localizedHistoryFailureDetail(context, null), isNull);
          expect(
            localizedHistoryFailureDetail(
              context,
              '/private/path/session-token',
            ),
            isNot(contains('session-token')),
          );
          expect(
            () => localeTemplate(
              context,
              '{count}',
              '{count}',
              <String, Object>{},
            ),
            throwsArgumentError,
          );
          for (final int count in <int>[0, 1, 2, 3, 11, 100]) {
            final String digits = material.formatDecimal(count);
            final String plural = localePlural(
              context,
              '{count} readings',
              '{count} ölçüm',
              count,
              englishOne: '{count} reading',
            );
            if (tag == 'en') {
              expect(plural, '$digits ${count == 1 ? 'reading' : 'readings'}');
            } else if (tag == 'tr') {
              expect(plural, '$digits ölçüm');
            } else {
              expect(plural, '${lissomPluralCategory(tag, count)} $digits');
            }
          }
          expect(tester.takeException(), isNull);
        },
      );
    }
  }

  testWidgets(
    'actual Profile selector persists language and applies RTL without owner state',
    (WidgetTester tester) async {
      final _MemoryStore store = _MemoryStore('en');
      final LissomLocaleController controller = LissomLocaleController(
        store: store,
      );
      addTearDown(controller.dispose);
      await controller.initialize();
      await tester.pumpWidget(_profileHost(controller));
      await tester.pumpAndSettle();
      await _tapRevealed(
        tester,
        find.byKey(const Key('profile.language.choose')),
        find
            .descendant(
              of: find.byType(ProfileScreen),
              matching: find.byType(Scrollable),
            )
            .first,
      );
      final Finder dialog = find.byKey(const Key('profile.language.dialog'));
      expect(dialog, findsOneWidget);
      await _tapRevealed(
        tester,
        find.byKey(const Key('profile.language.option.ar')),
        find.descendant(of: dialog, matching: find.byType(Scrollable)).first,
      );
      expect(controller.tag, 'ar');
      expect(store.value, 'ar');
      expect(store.writes, 1);
      expect(find.byKey(const Key('profile.language.dialog')), findsNothing);
      final BuildContext context = tester.element(find.byType(ProfileScreen));
      expect(Directionality.of(context), TextDirection.rtl);
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets(
    'actual Profile keeps dialog and visible error after rejected write',
    (WidgetTester tester) async {
      final _MemoryStore store = _MemoryStore('en')..failWrite = true;
      final LissomLocaleController controller = LissomLocaleController(
        store: store,
      );
      addTearDown(controller.dispose);
      await controller.initialize();
      await tester.pumpWidget(_profileHost(controller));
      await tester.pumpAndSettle();
      await _tapRevealed(
        tester,
        find.byKey(const Key('profile.language.choose')),
        find
            .descendant(
              of: find.byType(ProfileScreen),
              matching: find.byType(Scrollable),
            )
            .first,
      );
      final Finder dialog = find.byKey(const Key('profile.language.dialog'));
      expect(dialog, findsOneWidget);
      final Finder dialogScroll = find
          .descendant(of: dialog, matching: find.byType(Scrollable))
          .first;
      await _tapRevealed(
        tester,
        find.byKey(const Key('profile.language.option.tr')),
        dialogScroll,
      );
      expect(controller.tag, 'en');
      expect(store.value, 'en');
      expect(store.writes, 1);
      expect(find.byKey(const Key('profile.language.dialog')), findsOneWidget);
      final Finder failure = find.byKey(
        const Key('profile.language.writeFailure'),
      );
      await _reveal(tester, failure, dialogScroll);
      expect(failure, findsOneWidget);
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets(
    'locale host retains preference across keyed navigator replacement',
    (WidgetTester tester) async {
      final _MemoryStore store = _MemoryStore('ar');
      final LissomLocaleController controller = LissomLocaleController(
        store: store,
      );
      addTearDown(controller.dispose);
      await controller.initialize();
      await tester.pumpWidget(_profileHost(controller, ownerEpoch: 1));
      await tester.pumpAndSettle();
      final BuildContext first = tester.element(find.byType(ProfileScreen));
      expect(Localizations.localeOf(first), const Locale('ar'));
      await tester.pumpWidget(_profileHost(controller, ownerEpoch: 2));
      await tester.pumpAndSettle();
      final BuildContext second = tester.element(find.byType(ProfileScreen));
      expect(Localizations.localeOf(second), const Locale('ar'));
      expect(controller.tag, 'ar');
      expect(store.writes, 0);
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets(
    'missing catalog remains English and has visible Profile warning',
    (WidgetTester tester) async {
      final LissomLocaleController controller = LissomLocaleController(
        store: _MemoryStore('ja'),
      );
      addTearDown(controller.dispose);
      await controller.initialize();
      await tester.pumpWidget(_profileHost(controller, missing: true));
      await tester.pumpAndSettle();
      await tester.scrollUntilVisible(
        find.byKey(const Key('profile.language.catalogFailure')),
        200,
        scrollable: find.byType(Scrollable).first,
      );
      expect(
        find.byKey(const Key('profile.language.catalogFailure')),
        findsOneWidget,
      );
      expect(find.text('App language'), findsOneWidget);
      expect(tester.takeException(), isNull);
    },
  );
}
