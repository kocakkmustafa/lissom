// DRAFT ONLY / SDK UNRUN. Real host scope + controller ownership contracts.
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lissom/app/lissom_appearance.dart';

import 'lissom_appearance_test.dart' show MemoryAppearanceStore;

const _hostKey = Key('appearance.lifetime.host');
const _probeKey = Key('appearance.lifetime.probe');

class _ScopeProbe extends StatefulWidget {
  const _ScopeProbe({super.key});
  @override
  State<_ScopeProbe> createState() => _ScopeProbeState();
}

class _ScopeProbeState extends State<_ScopeProbe> {
  final lifetime = Object();
  LissomAppearanceController? active;
  @override
  Widget build(BuildContext context) {
    active = LissomAppearanceScope.of(context);
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
  testWidgets('same-key external to null retains and never disposes external', (
    tester,
  ) async {
    final store = MemoryAppearanceStore();
    final a = LissomAppearanceController(store: store);
    addTearDown(a.dispose);
    await a.initialize();
    await tester.pumpWidget(
      LissomAppearanceHost(
        key: _hostKey,
        controller: a,
        child: const _ScopeProbe(key: _probeKey),
      ),
    );
    final before = tester.state<_ScopeProbeState>(find.byKey(_probeKey));
    await tester.pumpWidget(
      const LissomAppearanceHost(
        key: _hostKey,
        child: _ScopeProbe(key: _probeKey),
      ),
    );
    _expectImmutableDiagnostic(tester);
    expect(tester.state(find.byKey(_probeKey)), same(before));
    expect(before.active, same(a));
    await tester.pumpWidget(const SizedBox.shrink());
    expect(await a.select(ThemeMode.dark), isTrue);
    expect(
      store.writes,
      1,
      reason: 'The external controller remains caller-owned.',
    );
  });

  testWidgets('same-key external A to B reports and leaves A active', (
    tester,
  ) async {
    final sa = MemoryAppearanceStore();
    final sb = MemoryAppearanceStore();
    final a = LissomAppearanceController(store: sa);
    final b = LissomAppearanceController(store: sb);
    addTearDown(a.dispose);
    addTearDown(b.dispose);
    await a.initialize();
    await b.initialize();
    await tester.pumpWidget(
      LissomAppearanceHost(
        key: _hostKey,
        controller: a,
        child: const _ScopeProbe(key: _probeKey),
      ),
    );
    final before = tester.state<_ScopeProbeState>(find.byKey(_probeKey));
    final lifetime = before.lifetime;
    await tester.pumpWidget(
      LissomAppearanceHost(
        key: _hostKey,
        controller: b,
        child: const _ScopeProbe(key: _probeKey),
      ),
    );
    _expectImmutableDiagnostic(tester);
    expect(before.active, same(a));
    expect(
      tester.state<_ScopeProbeState>(find.byKey(_probeKey)).lifetime,
      same(lifetime),
    );
    await tester.pumpWidget(const SizedBox.shrink());
    expect(await a.select(ThemeMode.light), isTrue);
    expect(await b.select(ThemeMode.dark), isTrue);
    expect(sa.writes, 1);
    expect(
      sb.writes,
      1,
      reason: 'Neither external controller is disposed by host.',
    );
  });

  testWidgets(
    'same-key internal to external keeps ownership and retires internal',
    (tester) async {
      final ownedStore = MemoryAppearanceStore();
      final owned = LissomAppearanceController(store: ownedStore);
      final externalStore = MemoryAppearanceStore();
      final external = LissomAppearanceController(store: externalStore);
      addTearDown(external.dispose);
      await owned.initialize();
      await external.initialize();
      await tester.pumpWidget(
        LissomAppearanceHost.owned(
          key: _hostKey,
          createController: () => owned,
          child: const _ScopeProbe(key: _probeKey),
        ),
      );
      final before = tester.state<_ScopeProbeState>(find.byKey(_probeKey));
      await tester.pumpWidget(
        LissomAppearanceHost(
          key: _hostKey,
          controller: external,
          child: const _ScopeProbe(key: _probeKey),
        ),
      );
      _expectImmutableDiagnostic(tester);
      expect(tester.state(find.byKey(_probeKey)), same(before));
      expect(before.active, same(owned));
      await tester.pumpWidget(const SizedBox.shrink());
      expect(
        await owned.select(ThemeMode.dark),
        isFalse,
        reason:
            'First-created internal controller must be disposed without leaking.',
      );
      expect(ownedStore.writes, 0);
      expect(await external.select(ThemeMode.dark), isTrue);
      expect(externalStore.writes, 1);
    },
  );

  testWidgets(
    'new host key intentionally adopts B and recreates child lifetime',
    (tester) async {
      final a = LissomAppearanceController(store: MemoryAppearanceStore());
      final b = LissomAppearanceController(store: MemoryAppearanceStore());
      addTearDown(a.dispose);
      addTearDown(b.dispose);
      await a.initialize();
      await b.initialize();
      await tester.pumpWidget(
        LissomAppearanceHost(
          key: const Key('host.A'),
          controller: a,
          child: const _ScopeProbe(key: _probeKey),
        ),
      );
      final before = tester.state<_ScopeProbeState>(find.byKey(_probeKey));
      await tester.pumpWidget(
        LissomAppearanceHost(
          key: const Key('host.B'),
          controller: b,
          child: const _ScopeProbe(key: _probeKey),
        ),
      );
      final after = tester.state<_ScopeProbeState>(find.byKey(_probeKey));
      expect(after.active, same(b));
      expect(identical(after.lifetime, before.lifetime), isFalse);
      expect(tester.takeException(), isNull);
      await tester.pumpWidget(const SizedBox.shrink());
      expect(await a.select(ThemeMode.dark), isTrue);
      expect(await b.select(ThemeMode.light), isTrue);
    },
  );
}
