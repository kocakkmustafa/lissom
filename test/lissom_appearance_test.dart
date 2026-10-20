// DRAFT: place under app/test only in the single-writer implementation window.
// All Flutter tests here are UNRUN. They refer to proposed, uninstalled files.
import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lissom/app/lissom_appearance.dart';
import 'package:lissom/app/lissom_palette.dart';
import 'package:lissom/app/lissom_theme.dart';

final class MemoryAppearanceStore implements AppearancePreferenceStore {
  ThemeMode value = ThemeMode.system;
  Object? readError;
  Object? writeError;
  Completer<ThemeMode>? pendingRead;
  Completer<void>? pendingWrite;
  int writes = 0;

  @override
  Future<ThemeMode> read() async {
    if (readError != null) { throw readError!; }
    if (pendingRead != null) { return await pendingRead!.future; }
    return value;
  }

  @override
  Future<void> write(ThemeMode next) async {
    ++writes;
    if (writeError != null) { throw writeError!; }
    await pendingWrite?.future;
    value = next;
  }
}

void main() {
  test('dispose during a reopened store admits no late write', () async {
    var opens = 0;
    final pendingOpen = Completer<AppearancePreferenceStore>();
    final store = MemoryAppearanceStore();
    final c = LissomAppearanceController(openStore: () {
      if (++opens == 1) {
        throw StateError('synthetic initial open failure');
      }
      return pendingOpen.future;
    });
    await c.initialize();
    expect(c.isReady, isTrue);
    expect(c.readFailed, isTrue);
    final saving = c.select(ThemeMode.dark);
    expect(c.isSaving, isTrue);
    expect(store.writes, 0);
    c.dispose();
    pendingOpen.complete(store);
    expect(await saving, isFalse);
    expect(c.isSaving, isFalse);
    expect(store.writes, 0,
      reason: 'Retirement before write admission must admit no new write.');
    expect(store.value, ThemeMode.system);
  });
  testWidgets('long pending write stays honest and does not permit a second writer', (tester) async {
    final store = MemoryAppearanceStore()..pendingWrite = Completer<void>();
    final c = LissomAppearanceController(store: store);
    addTearDown(c.dispose);
    await c.initialize();
    final saving = c.select(ThemeMode.dark);
    await tester.pump(const Duration(milliseconds: 3100));
    expect(c.writePendingLong, isTrue);
    expect(c.mode, ThemeMode.system);
    expect(c.isSaving, isTrue);
    expect(await c.select(ThemeMode.light), isFalse);
    expect(store.writes, 1);
    store.pendingWrite!.complete();
    expect(await saving, isTrue);
    expect(c.writePendingLong, isFalse);
    expect(c.mode, ThemeMode.dark);
  });

  testWidgets('timed-out initial read cannot replace a newer saved choice', (tester) async {
    final oldRead = Completer<ThemeMode>();
    final s = MemoryAppearanceStore()..pendingRead = oldRead;
    final c = LissomAppearanceController(store: s,
      readDeadline: const Duration(milliseconds: 10));
    addTearDown(c.dispose);
    final loading = c.initialize();
    await tester.pump(const Duration(milliseconds: 11));
    await loading;
    expect(c.isReady, isTrue);
    expect(c.readFailed, isTrue);
    expect(await c.select(ThemeMode.light), isTrue);
    oldRead.complete(ThemeMode.dark);
    await tester.pump();
    expect(c.mode, ThemeMode.light);
  });

  testWidgets('host builds no MaterialApp before delayed preference is ready', (tester) async {
    final pending = Completer<ThemeMode>();
    final s = MemoryAppearanceStore()..pendingRead = pending;
    final c = LissomAppearanceController(store: s);
    addTearDown(c.dispose);
    await tester.pumpWidget(LissomAppearanceHost(controller: c,
      child: Builder(builder: (context) => MaterialApp(
        theme: buildLissomTheme(),
        darkTheme: buildLissomTheme(brightness: Brightness.dark),
        themeMode: LissomAppearanceScope.of(context).mode,
        themeAnimationDuration: Duration.zero,
        home: const Scaffold(key: Key('first-ready-home')),
      )),
    ));
    expect(find.byType(MaterialApp), findsNothing);
    pending.complete(ThemeMode.dark);
    await tester.pump();
    await tester.pump();
    expect(find.byType(MaterialApp), findsOneWidget);
    final context = tester.element(find.byKey(const Key('first-ready-home')));
    expect(Theme.of(context).brightness, Brightness.dark);
  });

  testWidgets('read retry and theme change preserve a mounted draft across lifecycle', (tester) async {
    var mounts = 0;
    final s = MemoryAppearanceStore();
    final c = LissomAppearanceController(store: s);
    addTearDown(c.dispose);
    await c.initialize();
    await tester.pumpWidget(LissomAppearanceHost(controller: c,
      child: Builder(builder: (context) => MaterialApp(
        theme: buildLissomTheme(),
        darkTheme: buildLissomTheme(brightness: Brightness.dark),
        themeMode: LissomAppearanceScope.of(context).mode,
        themeAnimationDuration: Duration.zero,
        home: _DraftProbe(onMount: () => mounts++),
      )),
    ));
    await tester.enterText(find.byType(TextField), 'unsaved recall draft');
    expect(await c.select(ThemeMode.dark), isTrue);
    await tester.pump();
    s.readError = const FormatException('synthetic unreadable preference');
    await c.retryRead();
    await tester.pump();
    tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.paused);
    tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.resumed);
    await tester.pump();
    expect(mounts, 1);
    expect(find.text('unsaved recall draft'), findsOneWidget);
    expect(c.mode, ThemeMode.dark);
    expect(c.readFailed, isTrue);
  });

  test('missing preference resolves system', () async {
    final c = LissomAppearanceController(store: MemoryAppearanceStore());
    addTearDown(c.dispose);
    await c.initialize();
    expect(c.isReady, isTrue);
    expect(c.mode, ThemeMode.system);
    expect(c.readFailed, isFalse);
  });

  test('read failure is observable and never overwrites the file', () async {
    final s = MemoryAppearanceStore()..readError = const FormatException();
    final c = LissomAppearanceController(store: s);
    addTearDown(c.dispose);
    await c.initialize();
    expect(c.mode, ThemeMode.system);
    expect(c.readFailed, isTrue);
    expect(s.writes, 0);
  });

  test('choice is displayed only after persistence succeeds', () async {
    final s = MemoryAppearanceStore()..pendingWrite = Completer<void>();
    final c = LissomAppearanceController(store: s);
    addTearDown(c.dispose);
    await c.initialize();
    final result = c.select(ThemeMode.dark);
    expect(c.mode, ThemeMode.system);
    expect(c.isSaving, isTrue);
    expect(await c.select(ThemeMode.light), isFalse);
    expect(s.writes, 1);
    s.pendingWrite!.complete();
    expect(await result, isTrue);
    expect(c.mode, ThemeMode.dark);
  });

  test('write failure preserves prior value; retry can succeed', () async {
    final s = MemoryAppearanceStore()..value = ThemeMode.dark;
    final c = LissomAppearanceController(store: s);
    addTearDown(c.dispose);
    await c.initialize();
    s.writeError = StateError('disk full');
    expect(await c.select(ThemeMode.light), isFalse);
    expect(c.mode, ThemeMode.dark);
    expect(c.writeFailed, isTrue);
    s.writeError = null;
    expect(await c.select(ThemeMode.light), isTrue);
    expect(c.mode, ThemeMode.light);
    expect(c.writeFailed, isFalse);
  });

  test('disposed pending write never notifies a disposed controller', () async {
    final s = MemoryAppearanceStore()..pendingWrite = Completer<void>();
    final c = LissomAppearanceController(store: s);
    await c.initialize();
    final result = c.select(ThemeMode.dark);
    c.dispose();
    s.pendingWrite!.complete();
    expect(await result, isFalse);
  });

  testWidgets('saved dark is already resolved on the first Flutter frame',
      (tester) async {
    final s = MemoryAppearanceStore()..value = ThemeMode.dark;
    final c = LissomAppearanceController(store: s);
    addTearDown(c.dispose);
    await c.initialize(); // Production bootstrap must await this before runApp.
    final observed = <Brightness>[];
    await tester.pumpWidget(MaterialApp(
      theme: buildLissomTheme(),
      darkTheme: buildLissomTheme(brightness: Brightness.dark),
      themeMode: c.mode,
      themeAnimationDuration: Duration.zero,
      home: Builder(builder: (context) {
        observed.add(Theme.of(context).brightness);
        return const SizedBox();
      }),
    ));
    expect(observed, isNotEmpty);
    expect(observed.toSet(), <Brightness>{Brightness.dark});
  });

  testWidgets('system mode tracks platform brightness without rewriting choice',
      (tester) async {
    addTearDown(tester.platformDispatcher.clearPlatformBrightnessTestValue);
    tester.platformDispatcher.platformBrightnessTestValue = Brightness.light;
    final s = MemoryAppearanceStore();
    final c = LissomAppearanceController(store: s);
    addTearDown(c.dispose);
    await c.initialize();
    Brightness? observed;
    await tester.pumpWidget(MaterialApp(
      theme: buildLissomTheme(),
      darkTheme: buildLissomTheme(brightness: Brightness.dark),
      themeMode: c.mode,
      themeAnimationDuration: Duration.zero,
      home: Builder(builder: (context) {
        observed = Theme.of(context).brightness;
        return const SizedBox();
      }),
    ));
    expect(observed, Brightness.light);
    tester.platformDispatcher.platformBrightnessTestValue = Brightness.dark;
    await tester.pump();
    expect(observed, Brightness.dark);
    expect(s.writes, 0);
  });

  testWidgets('reduced motion bypasses custom fade and slide completely',
      (tester) async {
    const target = SizedBox(key: Key('transition-target'));
    final theme = buildLissomTheme();
    Widget? transition;
    await tester.pumpWidget(MaterialApp(
      theme: theme,
      builder: (context, child) => MediaQuery(
        data: MediaQuery.of(context).copyWith(disableAnimations: true),
        child: Builder(builder: (context) {
          transition = theme.pageTransitionsTheme.builders[TargetPlatform.iOS]!
              .buildTransitions<void>(
                MaterialPageRoute<void>(builder: (_) => target), context,
                const AlwaysStoppedAnimation<double>(.5),
                const AlwaysStoppedAnimation<double>(0), target,
              );
          return transition!;
        }),
      ),
      home: const SizedBox(),
    ));
    expect(identical(transition, target), isTrue);
  });

  testWidgets('both themes register a semantic palette', (tester) async {
    for (final brightness in Brightness.values) {
      final theme = buildLissomTheme(brightness: brightness);
      expect(theme.brightness, brightness);
      expect(theme.extension<LissomPalette>(), isNotNull);
      expect(theme.textTheme.bodyMedium!.color,
          theme.extension<LissomPalette>()!.textSecondary);
    }
  });
}

class _DraftProbe extends StatefulWidget {
  const _DraftProbe({required this.onMount});
  final VoidCallback onMount;
  @override
  State<_DraftProbe> createState() => _DraftProbeState();
}
class _DraftProbeState extends State<_DraftProbe> {
  final text = TextEditingController();
  @override
  void initState() { super.initState(); widget.onMount(); }
  @override
  void dispose() { text.dispose(); super.dispose(); }
  @override
  Widget build(BuildContext context) => Scaffold(body: TextField(controller: text));
}
