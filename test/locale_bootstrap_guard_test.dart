// DRAFT ONLY / SDK UNRUN. Six focused lifecycle/first-child regressions.
// Real catalog readiness is observed after mount; native launch/AT is UNRUN.
import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lissom/app/lissom_locales.dart';
import 'package:lissom/app/lissom_localizations.dart';

final class _MemoryLocale implements LocalePreferenceStore {
  _MemoryLocale([this.value]);
  String? value;
  Completer<String?>? pendingRead;
  Completer<void>? pendingWrite;
  int writes = 0;

  @override
  Future<String?> read() async =>
      pendingRead == null ? value : await pendingRead!.future;

  @override
  Future<void> write(String? tag) async {
    writes++;
    await pendingWrite?.future;
    value = tag;
  }
}

final class _ActualCatalogBundle extends CachingAssetBundle {
  @override
  Future<ByteData> load(String key) async =>
      ByteData.sublistView(File(key).readAsBytesSync());
}

const _host = Key('locale.lifetime.host');
const _probe = Key('locale.lifetime.probe');

class _ScopeProbe extends StatefulWidget {
  const _ScopeProbe({super.key});
  @override
  State<_ScopeProbe> createState() => _ScopeProbeState();
}

class _ScopeProbeState extends State<_ScopeProbe> {
  final lifetime = Object();
  LissomLocaleController? active;
  @override
  Widget build(BuildContext context) {
    active = LissomLocaleScope.maybeOf(context)!;
    return const SizedBox();
  }
}

void _expectImmutableDiagnostic(WidgetTester tester) {
  final error = tester.takeException();
  expect(error, isA<StateError>());
  expect(error.toString(), contains('initial controller remains active'));
  expect(error.toString(), contains('new host Key'));
}

void main() {
  testWidgets(
    'never-read becomes bounded system fallback and ignores late result',
    (tester) async {
      final lateRead = Completer<String?>();
      final store = _MemoryLocale()..pendingRead = lateRead;
      final c = LissomLocaleController(store: store);
      addTearDown(c.dispose);
      expect(c.readDeadline, const Duration(seconds: 2));
      final loading = c.initialize();
      expect(c.isReady, isFalse);
      expect(await c.select('it'), isFalse);
      await tester.pump(const Duration(milliseconds: 2001));
      await loading;
      expect(c.isReady, isTrue);
      expect(c.readFailed, isTrue);
      expect(
        c.tag,
        isNull,
        reason: 'Existing UI identifies the system fallback.',
      );
      expect(
        store.writes,
        0,
        reason: 'A failed read must not rewrite preference bytes.',
      );
      expect(await c.select('it'), isTrue);
      expect(c.tag, 'it');
      expect(c.readFailed, isFalse);
      lateRead.complete('ja');
      await tester.pump();
      expect(
        c.tag,
        'it',
        reason: 'Late bootstrap cannot undo the explicit saved choice.',
      );
      expect(c.readFailed, isFalse);
      expect(store.writes, 1);
    },
  );

  test('pending reopened store after dispose starts no write', () async {
    var opens = 0;
    final pendingOpen = Completer<LocalePreferenceStore>();
    final store = _MemoryLocale();
    final c = LissomLocaleController(
      openStore: () {
        if (++opens == 1) {
          throw StateError('synthetic initial open failure');
        }
        return pendingOpen.future;
      },
    );
    await c.initialize();
    expect(c.isReady, isTrue);
    expect(c.readFailed, isTrue);
    var notifications = 0;
    c.addListener(() => notifications++);
    final selecting = c.select('ar');
    expect(c.isSaving, isTrue);
    expect(await c.select('ja'), isFalse);
    final beforeDispose = notifications;
    c.dispose();
    pendingOpen.complete(store);
    expect(await selecting, isFalse);
    expect(store.writes, 0);
    expect(c.tag, isNull);
    expect(c.isSaving, isFalse);
    expect(notifications, beforeDispose);
  });

  test('already-started write after dispose cannot apply UI state', () async {
    final store = _MemoryLocale('ja')..pendingWrite = Completer<void>();
    final c = LissomLocaleController(store: store);
    await c.initialize();
    var notifications = 0;
    c.addListener(() => notifications++);
    final selecting = c.select('ar');
    expect(store.writes, 1);
    expect(c.tag, 'ja');
    expect(await c.select('it'), isFalse);
    final beforeDispose = notifications;
    c.dispose();
    store.pendingWrite!.complete();
    expect(await selecting, isFalse);
    expect(c.tag, 'ja');
    expect(c.isSaving, isFalse);
    expect(c.writeFailed, isFalse);
    expect(notifications, beforeDispose);
    expect(
      store.value,
      'ar',
      reason:
          'An admitted write may finish; this test does not claim IO cancellation.',
    );
    expect(store.writes, 1);
  });

  testWidgets('first mounted child and actual delegate use saved locale only', (
    tester,
  ) async {
    tester.platformDispatcher.localesTestValue = const <Locale>[Locale('en')];
    addTearDown(tester.platformDispatcher.clearLocalesTestValue);
    final read = Completer<String?>();
    final c = LissomLocaleController(
      store: _MemoryLocale()..pendingRead = read,
    );
    addTearDown(c.dispose);
    final bundle = _ActualCatalogBundle();
    final raw = await tester.runAsync(
      () => bundle
          .loadString('config/l10n/ja.json')
          .timeout(const Duration(seconds: 10)),
    );
    expect(raw, isNotNull);
    final expected = LissomLocalizations.parse(raw!, 'ja');
    final seenInstallationTags = <String?>[];
    final seenMaterialTags = <String>[];
    const localizedProbe = Key('locale.actual.delegate.probe');
    await tester.pumpWidget(
      LissomLocaleHost(
        controller: c,
        child: Builder(
          builder: (context) {
            final locale = LissomLocaleScope.maybeOf(context)!;
            seenInstallationTags.add(locale.tag);
            return MaterialApp(
              locale: locale.locale,
              supportedLocales: kLissomSupportedLocales,
              localeListResolutionCallback: resolveLissomLocale,
              localizationsDelegates: [
                LissomLocalizationsDelegate(bundle: bundle),
                ...GlobalMaterialLocalizations.delegates,
              ],
              home: Builder(
                builder: (context) {
                  seenMaterialTags.add(
                    canonicalLocaleTag(Localizations.localeOf(context)),
                  );
                  return Text(
                    LissomLocalizations.maybeOf(context)?.lookup('Profile') ??
                        'SYNTHETIC_MISSING_CATALOG',
                    key: localizedProbe,
                  );
                },
              ),
            );
          },
        ),
      ),
    );
    expect(find.byKey(const Key('locale.bootstrap.pending')), findsOneWidget);
    expect(find.byType(MaterialApp), findsNothing);
    expect(seenInstallationTags, isEmpty);
    read.complete('ja');
    // Detached parse above is insufficient: observe actual postmount delegates.
    final ready = await tester.runAsync(() async {
      final elapsed = Stopwatch()..start();
      while (elapsed.elapsed < const Duration(seconds: 10)) {
        await tester.pump();
        final elements = find.byKey(localizedProbe).evaluate();
        if (elements.length == 1) {
          final context = elements.single;
          final active = LissomLocalizations.maybeOf(context);
          if (active != null &&
              active.catalogAvailable &&
              active.tag == 'ja' &&
              active.lookup('Profile') == expected.lookup('Profile')) {
            return true;
          }
        }
        await Future<void>.delayed(const Duration(milliseconds: 10));
      }
      return false;
    });
    expect(ready, isTrue);
    expect(seenInstallationTags, isNotEmpty);
    expect(seenInstallationTags.toSet(), <String>{'ja'});
    expect(seenMaterialTags, isNotEmpty);
    expect(seenMaterialTags.toSet(), <String>{'ja'});
    expect(find.text(expected.lookup('Profile')!), findsOneWidget);
    expect(tester.takeException(), isNull);
    await tester.pumpWidget(const SizedBox.shrink());
  });

  testWidgets(
    'same-key external changes retain A and dispose neither caller controller',
    (tester) async {
      for (final toNull in <bool>[true, false]) {
        final sa = _MemoryLocale('ja');
        final sb = _MemoryLocale('ar');
        final a = LissomLocaleController(store: sa);
        final b = LissomLocaleController(store: sb);
        addTearDown(a.dispose);
        addTearDown(b.dispose);
        await a.initialize();
        await b.initialize();
        await tester.pumpWidget(
          LissomLocaleHost(
            key: _host,
            controller: a,
            child: const _ScopeProbe(key: _probe),
          ),
        );
        final before = tester.state<_ScopeProbeState>(find.byKey(_probe));
        await tester.pumpWidget(
          LissomLocaleHost(
            key: _host,
            controller: toNull ? null : b,
            child: const _ScopeProbe(key: _probe),
          ),
        );
        _expectImmutableDiagnostic(tester);
        expect(tester.state(find.byKey(_probe)), same(before));
        expect(before.active, same(a));
        await tester.pumpWidget(const SizedBox.shrink());
        expect(await a.select('it'), isTrue);
        expect(await b.select('ko'), isTrue);
        expect(sa.writes, 1);
        expect(sb.writes, 1);
      }
    },
  );

  testWidgets(
    'initial internal ownership survives changed arg; new key adopts B',
    (tester) async {
      final ownedStore = _MemoryLocale('ja');
      final owned = LissomLocaleController(store: ownedStore);
      final externalStore = _MemoryLocale('ar');
      final external = LissomLocaleController(store: externalStore);
      addTearDown(external.dispose);
      await owned.initialize();
      await external.initialize();
      await tester.pumpWidget(
        LissomLocaleHost.owned(
          key: _host,
          createController: () => owned,
          child: const _ScopeProbe(key: _probe),
        ),
      );
      final before = tester.state<_ScopeProbeState>(find.byKey(_probe));
      await tester.pumpWidget(
        LissomLocaleHost(
          key: _host,
          controller: external,
          child: const _ScopeProbe(key: _probe),
        ),
      );
      _expectImmutableDiagnostic(tester);
      expect(tester.state(find.byKey(_probe)), same(before));
      expect(before.active, same(owned));
      await tester.pumpWidget(
        LissomLocaleHost(
          key: const Key('locale.new.host'),
          controller: external,
          child: const _ScopeProbe(key: _probe),
        ),
      );
      final after = tester.state<_ScopeProbeState>(find.byKey(_probe));
      expect(after.active, same(external));
      expect(identical(before.lifetime, after.lifetime), isFalse);
      expect(await owned.select('it'), isFalse);
      expect(
        ownedStore.writes,
        0,
        reason: 'The initially owned controller was retired.',
      );
      expect(await external.select('ko'), isTrue);
      await tester.pumpWidget(const SizedBox.shrink());
      expect(await external.select('ja'), isTrue);
      expect(externalStore.writes, 2);
      expect(tester.takeException(), isNull);
    },
  );
}
