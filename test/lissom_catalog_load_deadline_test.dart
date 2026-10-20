// Defined regression coverage only. SDK execution is coordinated separately.
import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lissom/app/lissom_locales.dart';
import 'package:lissom/app/lissom_localizations.dart';
import 'package:lissom/app/profile_screen.dart';

import 'support/facts_from_disk.dart';

// Override binary asset IO only. The real inherited loadString, UTF-8 decoding,
// caching and delegate parsing remain in the exercised path.
final class _PendingCatalogBundle extends CachingAssetBundle {
  final Completer<ByteData> _bytes = Completer<ByteData>();
  final List<String> requestedKeys = <String>[];

  bool get isCompleted => _bytes.isCompleted;

  @override
  Future<ByteData> load(String key) {
    requestedKeys.add(key);
    return _bytes.future;
  }

  void completeBytes(List<int> bytes) {
    _bytes.complete(Uint8List.fromList(bytes).buffer.asByteData());
  }

  void completeCatalog(String tag) => completeBytes(
    utf8.encode(
      jsonEncode(<String, Object>{
        'schemaVersion': 1,
        'id': 'lissom.l10n.$tag',
        'locale': tag,
        'messages': <String, Object>{
          'Hello': '안녕하세요',
          'Value {value} on {date}': '{date}의 값 {value}',
          'Repeat {value} then {value}': '{value} 이후 다시 {value}',
          '{count} readings': <String, String>{'other': '{count}개 기록'},
        },
      }),
    ),
  );

  void fail(Object error) => _bytes.completeError(error, StackTrace.current);
}

final class _MemoryLocaleStore implements LocalePreferenceStore {
  @override
  Future<String?> read() async => null;

  @override
  Future<void> write(String? tag) async {}
}

void main() {
  testWidgets(
    'default five-second deadline releases the first subtree to existing Profile catalog failure',
    (WidgetTester tester) async {
      final _PendingCatalogBundle bundle = _PendingCatalogBundle();
      final LissomLocaleController controller = LissomLocaleController(
        store: _MemoryLocaleStore(),
      );
      addTearDown(controller.dispose);
      await controller.initialize();
      LissomLocalizations? visibleCatalog;
      await tester.pumpWidget(
        LissomLocaleHost(
          controller: controller,
          child: MaterialApp(
            locale: const Locale('en'),
            supportedLocales: kLissomSupportedLocales,
            localizationsDelegates: <LocalizationsDelegate<dynamic>>[
              LissomLocalizationsDelegate(bundle: bundle),
            ],
            home: Builder(
              builder: (BuildContext context) {
                visibleCatalog = LissomLocalizations.maybeOf(context);
                return Scaffold(body: ProfileScreen(facts: factsFromDisk()));
              },
            ),
          ),
        ),
      );
      expect(bundle.requestedKeys, <String>['config/l10n/en.json']);
      expect(find.byType(ProfileScreen), findsNothing);
      await tester.pump(const Duration(milliseconds: 4999));
      expect(visibleCatalog, isNull);
      expect(find.byType(ProfileScreen), findsNothing);

      await tester.pump(const Duration(milliseconds: 1));
      await tester.pump();
      expect(find.byType(ProfileScreen), findsOneWidget);
      expect(visibleCatalog?.tag, 'en');
      expect(visibleCatalog?.catalogAvailable, isFalse);
      expect(visibleCatalog?.messages, isEmpty);
      // The deadline supplies a fallback; it does not cancel pending asset IO.
      expect(bundle.isCompleted, isFalse);

      final Finder failure = find.byKey(
        const Key('profile.language.catalogFailure'),
      );
      await tester.scrollUntilVisible(
        failure,
        200,
        scrollable: find.byType(Scrollable).first,
      );
      await Scrollable.ensureVisible(tester.element(failure), alignment: 0.5);
      await tester.pump();
      expect(failure.hitTestable(), findsOneWidget);
      expect(
        tester.widget<Text>(failure).data,
        'This language catalog could not be loaded. Missing text is shown in English.',
      );
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets(
    'late bytes cannot replace a timed-out result and a later explicit load parses the cached catalog',
    (WidgetTester tester) async {
      final _PendingCatalogBundle bundle = _PendingCatalogBundle();
      final LissomLocalizationsDelegate delegate = LissomLocalizationsDelegate(
        bundle: bundle,
        loadDeadline: const Duration(milliseconds: 20),
      );
      LissomLocalizations? firstResult;
      final Future<LissomLocalizations> first = delegate.load(
        const Locale('ko'),
      );
      unawaited(
        first.then((LissomLocalizations value) {
          firstResult = value;
        }),
      );
      await tester.pump(const Duration(milliseconds: 19));
      expect(firstResult, isNull);
      await tester.pump(const Duration(milliseconds: 1));
      final LissomLocalizations unavailable = await first;
      expect(unavailable.tag, 'ko');
      expect(unavailable.catalogAvailable, isFalse);
      expect(unavailable.lookup('Hello'), isNull);

      bundle.completeCatalog('ko');
      await tester.pump();
      expect(firstResult, same(unavailable));
      expect(unavailable.catalogAvailable, isFalse);
      expect(unavailable.lookup('Hello'), isNull);

      // No automatic retry is promised. An explicit later load may use the
      // completed real CachingAssetBundle string future.
      final Future<LissomLocalizations> retry = delegate.load(
        const Locale('ko'),
      );
      await tester.pump();
      final LissomLocalizations available = await retry;
      expect(available, isNot(same(unavailable)));
      expect(available.tag, 'ko');
      expect(available.catalogAvailable, isTrue);
      expect(available.lookup('Hello'), '안녕하세요');
      expect(available.lookup('Value {value} on {date}'), '{date}의 값 {value}');
      expect(
        available.lookup('Repeat {value} then {value}'),
        '{value} 이후 다시 {value}',
      );
      expect(
        available.lookup('{count} readings', pluralCategory: 'one'),
        '{count}개 기록',
      );
      expect(bundle.requestedKeys, <String>['config/l10n/ko.json']);
      expect(delegate.isSupported(const Locale('ko')), isTrue);
      expect(
        delegate.isSupported(
          const Locale.fromSubtags(languageCode: 'zh', scriptCode: 'Hans'),
        ),
        isTrue,
      );
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets(
    'asset and UTF-8 errors fall back before the deadline and reload identity includes the deadline',
    (WidgetTester tester) async {
      final _PendingCatalogBundle brokenAsset = _PendingCatalogBundle();
      final LissomLocalizationsDelegate assetDelegate =
          LissomLocalizationsDelegate(
            bundle: brokenAsset,
            loadDeadline: const Duration(seconds: 30),
          );
      final Future<LissomLocalizations> assetLoad = assetDelegate.load(
        const Locale('it'),
      );
      brokenAsset.fail(FlutterError('fixture binary asset read failed'));
      // No fake time advances here: an early IO error must not wait 30 seconds.
      await tester.pump();
      final LissomLocalizations assetFailure = await assetLoad;
      expect(assetFailure.tag, 'it');
      expect(assetFailure.catalogAvailable, isFalse);
      expect(assetFailure.messages, isEmpty);

      final _PendingCatalogBundle invalidUtf8 = _PendingCatalogBundle();
      final Future<LissomLocalizations> decodeLoad =
          LissomLocalizationsDelegate(
            bundle: invalidUtf8,
            loadDeadline: const Duration(seconds: 30),
          ).load(const Locale('id'));
      invalidUtf8.completeBytes(<int>[0xC3, 0x28]);
      await tester.pump();
      final LissomLocalizations decodeFailure = await decodeLoad;
      expect(decodeFailure.tag, 'id');
      expect(decodeFailure.catalogAvailable, isFalse);
      expect(decodeFailure.messages, isEmpty);
      expect(tester.takeException(), isNull);

      expect(
        const LissomLocalizationsDelegate().shouldReload(
          const LissomLocalizationsDelegate(),
        ),
        isFalse,
      );
      expect(
        LissomLocalizationsDelegate(
          bundle: brokenAsset,
          loadDeadline: const Duration(seconds: 30),
        ).shouldReload(assetDelegate),
        isFalse,
      );
      expect(
        LissomLocalizationsDelegate(
          bundle: invalidUtf8,
          loadDeadline: const Duration(seconds: 30),
        ).shouldReload(assetDelegate),
        isTrue,
      );
      expect(
        LissomLocalizationsDelegate(
          bundle: brokenAsset,
          loadDeadline: const Duration(seconds: 29),
        ).shouldReload(assetDelegate),
        isTrue,
      );
    },
  );
}
