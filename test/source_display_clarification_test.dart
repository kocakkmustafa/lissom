// External review draft only. NOT copied into the product and NOT executed.
// Uses small in-memory catalogs and production localization helpers; no File,
// workspace report JSON, path override, native feature, or network dependency.
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lissom/app/lissom_locales.dart';
import 'package:lissom/app/lissom_localizations.dart';
import 'package:lissom/app/locale_text.dart';

const _resultKey = Key('sourceDisplay.result');
const _contextAKey = Key('sourceDisplay.contextA');
const _contextBKey = Key('sourceDisplay.contextB');

// Full expected copy comes from independently reviewed selected source meaning,
// not from importing or reading the production private finite map.
const _h41Source =
    'Choose two standing shapes, two seated/low shapes, one breathing pause and rest.';
const _h41InlineTurkish =
    'İki ayakta, iki oturarak/alçak şekil, bir nefes molası ve dinlenme seç.';
const _h41SafeEnglish =
    'Choose two standing shapes, two seated/low shapes, one pause from movement while continuing ordinary comfortable breathing, and rest.';
const _clinicalSource =
    'Lissom is a general wellness app and is not a medical device, so it does not screen, diagnose or predict injury risk. Those claims require clinical validation we have not done and are not seeking. A movement reading, however carefully taken, is not evidence about your health.';
const _clinicalReviewedTurkish =
    'Lissom genel iyi yaşam uygulamasıdır; tıbbi cihaz değildir. Tarama, tanı veya sakatlanma riski tahmini yapmaz. Bu iddialar, yapmadığımız ve hedeflemediğimiz klinik doğrulama gerektirir. Hareket ölçümü tek başına sağlık durumuna ilişkin kanıt değildir.';
const _assessmentSource =
    'Twelve camera-based movement tests. Each one measures a specific area and tells you what it could and could not see.';
const _assessmentHonestEnglish =
    'Twelve movement assessments are listed. Each test shows its current limits.';
const _assessmentFrench =
    'Douze évaluations du mouvement sont répertoriées. Chaque test présente ses limites actuelles.';

final class _MemoryCatalogBundle extends CachingAssetBundle {
  _MemoryCatalogBundle(this.catalogs);

  final Map<String, Map<String, Object>> catalogs;

  @override
  Future<ByteData> load(String key) async {
    final String tag = key.split('/').last.replaceAll('.json', '');
    final Map<String, Object>? messages = catalogs[tag];
    if (messages == null) {
      throw FlutterError('Fixture catalog unavailable');
    }
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
  required Locale locale,
  required AssetBundle bundle,
  required WidgetBuilder build,
}) => MaterialApp(
  locale: locale,
  supportedLocales: kLissomSupportedLocales,
  localeListResolutionCallback: resolveLissomLocale,
  localizationsDelegates: <LocalizationsDelegate<dynamic>>[
    GlobalMaterialLocalizations.delegate,
    GlobalWidgetsLocalizations.delegate,
    GlobalCupertinoLocalizations.delegate,
    LissomLocalizationsDelegate(bundle: bundle),
  ],
  home: Builder(builder: build),
);

String _text(WidgetTester tester, Key key) =>
    tester.widget<Text>(find.byKey(key)).data!;

void main() {
  testWidgets('unavailable French catalog uses clarified English for h41', (
    tester,
  ) async {
    await tester.pumpWidget(
      _localized(
        locale: const Locale('fr'),
        bundle: _MemoryCatalogBundle(<String, Map<String, Object>>{}),
        build: (context) => Scaffold(
          body: Text(
            localeText(context, _h41Source, _h41InlineTurkish),
            key: _resultKey,
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
    final BuildContext context = tester.element(find.byKey(_resultKey));
    expect(LissomLocalizations.maybeOf(context)!.catalogAvailable, isFalse);
    expect(_text(tester, _resultKey), _h41SafeEnglish);
    expect(tester.takeException(), isNull);
  });

  testWidgets('Turkish config707 finite copy wins over legacy direct copy', (
    tester,
  ) async {
    await tester.pumpWidget(
      _localized(
        locale: const Locale('tr'),
        bundle: _MemoryCatalogBundle(<String, Map<String, Object>>{
          'tr': <String, Object>{
            _clinicalSource: 'Catalog sentinel must not override reviewed TR.',
          },
        }),
        build: (context) => Scaffold(
          body: Text(configText(context, _clinicalSource), key: _resultKey),
        ),
      ),
    );
    await tester.pumpAndSettle();
    final BuildContext context = tester.element(find.byKey(_resultKey));
    expect(LissomLocalizations.maybeOf(context)!.catalogAvailable, isTrue);
    expect(_text(tester, _resultKey), _clinicalReviewedTurkish);
    expect(tester.takeException(), isNull);
  });

  testWidgets('unreviewed English key preserves two inline Turkish contexts', (
    tester,
  ) async {
    const String source = 'Unreviewed context-specific fixture source';
    await tester.pumpWidget(
      _localized(
        locale: const Locale('tr'),
        bundle: _MemoryCatalogBundle(<String, Map<String, Object>>{
          'tr': <String, Object>{source: 'Global catalog collision sentinel'},
        }),
        build: (context) => Scaffold(
          body: Column(
            children: <Widget>[
              Text(localeText(context, source, 'Bağlam A'), key: _contextAKey),
              Text(localeText(context, source, 'Bağlam B'), key: _contextBKey),
            ],
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
    final BuildContext context = tester.element(find.byKey(_contextAKey));
    expect(LissomLocalizations.maybeOf(context)!.catalogAvailable, isTrue);
    expect(_text(tester, _contextAKey), 'Bağlam A');
    expect(_text(tester, _contextBKey), 'Bağlam B');
    expect(tester.takeException(), isNull);
  });

  testWidgets('assessment config looks up honest value by immutable old key', (
    tester,
  ) async {
    await tester.pumpWidget(
      _localized(
        locale: const Locale('fr'),
        bundle: _MemoryCatalogBundle(<String, Map<String, Object>>{
          'fr': <String, Object>{_assessmentSource: _assessmentFrench},
        }),
        build: (context) => Scaffold(
          body: Text(configText(context, _assessmentSource), key: _resultKey),
        ),
      ),
    );
    await tester.pumpAndSettle();
    final BuildContext context = tester.element(find.byKey(_resultKey));
    final LissomLocalizations catalog = LissomLocalizations.maybeOf(context)!;
    expect(catalog.catalogAvailable, isTrue);
    expect(catalog.lookup(_assessmentSource), _assessmentFrench);
    expect(catalog.lookup(_assessmentHonestEnglish), isNull);
    expect(_text(tester, _resultKey), _assessmentFrench);
    expect(tester.takeException(), isNull);
  });
}
