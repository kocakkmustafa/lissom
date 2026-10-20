// DRAFT ONLY. 14 locales × 2 brightness × 2 scales = 56 proposed widget cases.
// Real catalogs are required; English fallback must not silently pass coverage.
// Host layout/semantics does not establish native font/shaping/AT acceptance.
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lissom/app/lissom_appearance.dart';
import 'package:lissom/app/lissom_locales.dart';
import 'package:lissom/app/lissom_localizations.dart';
import 'package:lissom/app/lissom_theme.dart';
import 'package:lissom/app/profile_screen.dart';

import 'lissom_appearance_test.dart' show MemoryAppearanceStore;
import 'support/facts_from_disk.dart';
import 'support/theme_catalog_readiness.dart';

const _locales = <String, Locale>{
  'en': Locale('en'),
  'tr': Locale('tr'),
  'es-419': Locale('es', '419'),
  'pt-BR': Locale('pt', 'BR'),
  'de': Locale('de'),
  'fr': Locale('fr'),
  'ja': Locale('ja'),
  'ar': Locale('ar'),
  'it': Locale('it'),
  'ko': Locale('ko'),
  'id': Locale('id'),
  'pl': Locale('pl'),
  'hi': Locale('hi'),
  'zh-Hans': Locale.fromSubtags(languageCode: 'zh', scriptCode: 'Hans'),
};
const _requiredKeys = <String>[
  'Appearance',
  'Use system appearance',
  'Light',
  'Dark',
  'Appearance is saved on this installation. It does not change your account or practice records.',
  'The saved appearance could not be read. The current appearance remains active. Retry reading it or choose a new preference.',
  'Retry reading preference',
  'Reading appearance…',
  'Saving appearance…',
  'Saving is taking longer than expected. Your previous appearance is still active. You can close this dialog.',
  'The appearance could not be saved. Your previous choice is unchanged. Try again.',
  'Close',
  'Loading…',
];

final class _ActualCatalogBundle extends CachingAssetBundle {
  @override
  Future<ByteData> load(String key) async =>
      ByteData.sublistView(File(key).readAsBytesSync());
}

final class _UnavailableCatalogBundle extends CachingAssetBundle {
  @override
  Future<ByteData> load(String key) async {
    throw const FormatException('synthetic unavailable catalog');
  }
}

void main() {
  testWidgets('mounted English fallback cannot pass real catalog readiness', (
    tester,
  ) async {
    final c = LissomAppearanceController(store: MemoryAppearanceStore());
    addTearDown(c.dispose);
    await c.initialize();
    await tester.pumpWidget(
      LissomAppearanceHost(
        controller: c,
        child: MaterialApp(
          theme: buildLissomTheme(),
          locale: const Locale('en'),
          localizationsDelegates: [
            LissomLocalizationsDelegate(bundle: _UnavailableCatalogBundle()),
            ...GlobalMaterialLocalizations.delegates,
          ],
          home: Scaffold(body: ProfileScreen(facts: factsFromDisk())),
        ),
      ),
    );
    expect(
      await waitForActiveThemeCatalog(
        tester,
        anchor: find.byType(ProfileScreen),
        tag: 'en',
        requiredKeys: _requiredKeys,
        deadline: const Duration(seconds: 1),
      ),
      isFalse,
    );
    // A missing screen is not accepted as this negative test's proof.
    expect(find.byType(ProfileScreen), findsOneWidget);
    final active = LissomLocalizations.maybeOf(
      tester.element(find.byType(ProfileScreen)),
    );
    expect(active, isNotNull);
    expect(active!.catalogAvailable, isFalse);
    expect(active.tag, 'en');
    expect(active.lookup('Appearance'), isNull);
    expect(tester.takeException(), isNull);
    await tester.pumpWidget(const SizedBox.shrink());
  });

  for (final entry in _locales.entries) {
    for (final brightness in Brightness.values) {
      for (final scale in <double>[1, 2]) {
        testWidgets(
          'actual theme Profile/dialog ${entry.key} $brightness ${scale}x',
          (tester) async {
            tester.view.physicalSize = const Size(320, 812);
            tester.view.devicePixelRatio = 1;
            addTearDown(tester.view.reset);
            expect(
              canonicalLocaleTag(entry.value),
              entry.key,
              reason: 'The real 14-locale resolver must be integrated first.',
            );
            final bundle = _ActualCatalogBundle();
            final raw = await tester.runAsync(
              () => bundle
                  .loadString('config/l10n/${entry.key}.json')
                  .timeout(const Duration(seconds: 10)),
            );
            expect(raw, isNotNull);
            final catalog = LissomLocalizations.parse(raw!, entry.key);
            for (final key in _requiredKeys) {
              expect(
                catalog.lookup(key),
                isNotNull,
                reason: 'Theme text must exist in the actual catalog: $key',
              );
            }
            final store = MemoryAppearanceStore();
            final c = LissomAppearanceController(store: store);
            addTearDown(c.dispose);
            await c.initialize();
            await tester.pumpWidget(
              LissomAppearanceHost(
                controller: c,
                child: MaterialApp(
                  theme: buildLissomTheme(
                    brightness: brightness,
                    locale: entry.value,
                  ),
                  locale: entry.value,
                  supportedLocales: _locales.values,
                  localizationsDelegates: [
                    LissomLocalizationsDelegate(bundle: bundle),
                    GlobalMaterialLocalizations.delegate,
                    GlobalCupertinoLocalizations.delegate,
                    GlobalWidgetsLocalizations.delegate,
                  ],
                  builder: (context, child) => MediaQuery(
                    data: MediaQuery.of(context).copyWith(
                      textScaler: TextScaler.linear(scale),
                      disableAnimations: true,
                    ),
                    child: child!,
                  ),
                  home: Scaffold(body: ProfileScreen(facts: factsFromDisk())),
                ),
              ),
            );
            expect(
              await waitForActiveThemeCatalog(
                tester,
                anchor: find.byType(ProfileScreen),
                tag: entry.key,
                requiredKeys: _requiredKeys,
                expected: catalog,
              ),
              isTrue,
              reason:
                  'Actual Profile delegate, exact locale and all 13 theme lookups must be ready.',
            );
            final activeCatalog = LissomLocalizations.maybeOf(
              tester.element(find.byType(ProfileScreen)),
            );
            expect(activeCatalog, isNotNull);
            expect(activeCatalog!.catalogAvailable, isTrue);
            expect(activeCatalog.tag, entry.key);
            for (final key in _requiredKeys) {
              expect(activeCatalog.lookup(key), catalog.lookup(key));
            }
            await tester.pumpAndSettle();
            final choose = find.byKey(const Key('profile.appearance.choose'));
            await tester.scrollUntilVisible(choose, 300, maxScrolls: 100);
            await Scrollable.ensureVisible(tester.element(choose));
            await tester.pump();
            expect(find.text(catalog.lookup('Appearance')!), findsOneWidget);
            expect(
              Directionality.of(tester.element(choose)),
              entry.key == 'ar' ? TextDirection.rtl : TextDirection.ltr,
            );
            await tester.tap(choose);
            await tester.pumpAndSettle();
            expect(
              find.byKey(const Key('profile.appearance.dialog')),
              findsOneWidget,
            );
            for (final mode in ThemeMode.values) {
              final option = find.byKey(
                Key('profile.appearance.option.${mode.name}'),
              );
              await Scrollable.ensureVisible(tester.element(option));
              await tester.pump();
              expect(option, findsOneWidget);
            }
            expect(
              tester.takeException(),
              isNull,
              reason: 'Overflow or layout exception is a real host failure.',
            );
            await tester.tap(find.byKey(const Key('profile.appearance.close')));
            await tester.pumpAndSettle();
            store.writeError = StateError('synthetic write failure');
            await tester.tap(choose);
            await tester.pumpAndSettle();
            final darkOption = find.byKey(
              const Key('profile.appearance.option.dark'),
            );
            await Scrollable.ensureVisible(tester.element(darkOption));
            await tester.tap(darkOption);
            await tester.pump();
            expect(
              find.byKey(const Key('profile.appearance.writeFailure')),
              findsOneWidget,
            );
            expect(tester.takeException(), isNull);
            await tester.tap(find.byKey(const Key('profile.appearance.close')));
            await tester.pumpAndSettle();
            store.readError = const FormatException(
              'synthetic preference failure',
            );
            await c.retryRead();
            await tester.pump();
            final readFailure = find.byKey(
              const Key('profile.appearance.readFailure'),
            );
            await Scrollable.ensureVisible(tester.element(readFailure));
            await tester.pump();
            expect(readFailure, findsOneWidget);
            expect(tester.takeException(), isNull);
          },
        );
      }
    }
  }
}
