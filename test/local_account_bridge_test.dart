import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lissom/app/home_screen.dart';
import 'package:lissom/app/local_account_bridge.dart';
import 'package:lissom/app/onboarding_flow.dart';
import 'package:lissom/app/onboarding_gate.dart';
import 'package:lissom/app/onboarding_store.dart';
import 'package:lissom/app/profile_screen.dart';
import 'package:lissom/app/shell.dart';

import 'support/facts_from_disk.dart';

final class _MemoryStore implements OnboardingStore {
  _MemoryStore(this.profile);
  OnboardingProfile profile;

  @override
  Future<OnboardingProfile> read() async => profile;

  @override
  Future<void> write(OnboardingProfile value) async => profile = value;
}

void main() {
  test(
    'guest paths stay legacy; two account IDs have distinct journals',
    () async {
      final Directory tmp = await Directory.systemTemp.createTemp(
        'lissom-owner-',
      );
      addTearDown(() => tmp.delete(recursive: true));
      const LissomLocalScope guest = LissomLocalScope.guest;
      final LissomLocalScope alice = LissomLocalScope.account('user-a');
      final LissomLocalScope bob = LissomLocalScope.account('user-b');

      expect(kLissomMotionAppId, 'lissom');
      expect(
        guest.file(tmp, LissomLocalFile.onboarding).path,
        '${tmp.path}/lissom/onboarding.json',
      );
      for (final LissomLocalFile kind in LissomLocalFile.values) {
        expect(alice.file(tmp, kind).path, isNot(guest.file(tmp, kind).path));
        expect(bob.file(tmp, kind).path, isNot(alice.file(tmp, kind).path));
      }

      final JsonOnboardingStore guestStore = JsonOnboardingStore(
        guest.file(tmp, LissomLocalFile.onboarding),
      );
      final JsonOnboardingStore aliceStore = JsonOnboardingStore(
        alice.file(tmp, LissomLocalFile.onboarding),
      );
      final JsonOnboardingStore bobStore = JsonOnboardingStore(
        bob.file(tmp, LissomLocalFile.onboarding),
      );
      await guestStore.write(
        const OnboardingProfile(completed: true, ageBand: 'u40'),
      );

      expect(
        (await aliceStore.read()).completed,
        isFalse,
        reason: 'sign-in must not claim the legacy guest profile',
      );
      await aliceStore.write(
        const OnboardingProfile(completed: true, ageBand: '40-59'),
      );
      expect((await bobStore.read()).completed, isFalse);
      expect((await guestStore.read()).ageBand, 'u40');
      expect((await aliceStore.read()).ageBand, '40-59');
    },
  );

  test('account IDs reject path separators, traversal and empty values', () {
    for (final String invalid in <String>[
      '',
      '../guest',
      'a/b',
      'a\\b',
      'a@b',
    ]) {
      expect(() => LissomLocalScope.account(invalid), throwsArgumentError);
    }
  });

  test('account deletion callback removes only the requested owner', () async {
    final Directory tmp = await Directory.systemTemp.createTemp(
      'lissom-clear-',
    );
    addTearDown(() => tmp.delete(recursive: true));
    const LissomLocalScope guest = LissomLocalScope.guest;
    final LissomLocalScope alice = LissomLocalScope.account('user-a');
    final LissomLocalScope bob = LissomLocalScope.account('user-b');
    for (final LissomLocalScope scope in <LissomLocalScope>[
      guest,
      alice,
      bob,
    ]) {
      final File file = scope.file(tmp, LissomLocalFile.sessions);
      await file.parent.create(recursive: true);
      await file.writeAsString(scope.ownerKey);
    }

    // The host can pass this one-argument shape to MotionAccountPage.
    final Future<void> Function(String) coreCallback = clearLissomLocalData;
    expect(coreCallback, isNotNull);
    Future<void> callback(String userId) =>
        clearLissomLocalData(userId, supportDirectory: () async => tmp);
    final Future<void> Function(String) signature = callback;
    await signature('user-a');

    expect(await alice.directory(tmp).exists(), isFalse);
    expect(
      await guest.file(tmp, LissomLocalFile.sessions).readAsString(),
      'guest',
    );
    expect(
      await bob.file(tmp, LissomLocalFile.sessions).readAsString(),
      'account:user-b',
    );
  });

  test('reconciliation lists only real UUID account directories', () async {
    final Directory tmp = await Directory.systemTemp.createTemp(
      'lissom-reconcile-',
    );
    addTearDown(() => tmp.delete(recursive: true));
    final Directory accounts = Directory('${tmp.path}/lissom/accounts');
    await accounts.create(recursive: true);
    const String first = '11111111-1111-4111-8111-111111111111';
    const String second = '22222222-2222-4222-8222-222222222222';
    const String fileId = '33333333-3333-4333-8333-333333333333';
    const String linkId = '44444444-4444-4444-8444-444444444444';
    await Directory('${accounts.path}/$second').create();
    await Directory('${accounts.path}/$first').create();
    await Directory('${accounts.path}/user-a').create();
    await File('${accounts.path}/$fileId').writeAsString('not a directory');
    await Link('${accounts.path}/$linkId').create('${accounts.path}/$first');

    final Future<Iterable<String>> Function() coreCallback =
        listLissomLocalAccountIds;
    expect(coreCallback, isNotNull);
    expect(
      await listLissomLocalAccountIds(supportDirectory: () async => tmp),
      <String>[first, second],
    );
  });

  test('reconciliation refuses a linked accounts ancestor', () async {
    final Directory tmp = await Directory.systemTemp.createTemp(
      'lissom-linked-accounts-',
    );
    addTearDown(() => tmp.delete(recursive: true));
    final Directory lissom = Directory('${tmp.path}/lissom');
    await lissom.create();
    final Directory elsewhere = Directory('${tmp.path}/elsewhere');
    await elsewhere.create();
    await Link('${lissom.path}/accounts').create(elsewhere.path);

    expect(
      () => listLissomLocalAccountIds(supportDirectory: () async => tmp),
      throwsStateError,
    );
  });

  testWidgets(
    'identity change reloads onboarding instead of reusing guest state',
    (WidgetTester tester) async {
      final _MemoryStore guest = _MemoryStore(
        const OnboardingProfile(completed: true, ageBand: 'u40'),
      );
      final _MemoryStore account = _MemoryStore(
        const OnboardingProfile.notStarted(),
      );
      LissomLocalScope scope = LissomLocalScope.guest;
      Future<OnboardingStore> loadStore() async =>
          scope.isGuest ? guest : account;

      Widget app() => MaterialApp(
        home: OnboardingGate(
          localScope: scope,
          storeLoader: loadStore,
          shellLoader: () async => factsFromDisk(),
        ),
      );
      await tester.pumpWidget(app());
      await tester.pumpAndSettle();
      expect(find.byType(LissomShell), findsOneWidget);

      scope = LissomLocalScope.account('user-a');
      await tester.pumpWidget(app());
      await tester.pumpAndSettle();
      expect(find.byType(OnboardingFlow), findsOneWidget);
      expect(find.byType(LissomShell), findsNothing);
    },
  );

  testWidgets('account routes appear only with a real page builder', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(body: ProfileScreen(facts: factsFromDisk())),
      ),
    );
    expect(find.byKey(ProfileScreen.accountEntryKey), findsNothing);

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: ProfileScreen(
            facts: factsFromDisk(),
            accountRouteBuilder: (BuildContext context, String appId) =>
                Scaffold(body: Center(child: Text('$appId account route'))),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.byKey(ProfileScreen.accountEntryKey), findsOneWidget);
    await tester.tap(find.byKey(ProfileScreen.accountEntryKey));
    await tester.pumpAndSettle();
    expect(find.text('lissom account route'), findsOneWidget);
  });

  testWidgets('onboarding account entry passes the fixed Lissom app ID', (
    WidgetTester tester,
  ) async {
    final _MemoryStore store = _MemoryStore(
      const OnboardingProfile.notStarted(),
    );
    await tester.pumpWidget(
      MaterialApp(
        home: OnboardingGate(
          storeLoader: () async => store,
          accountRouteBuilder: (BuildContext context, String appId) =>
              Scaffold(body: Center(child: Text('$appId account route'))),
        ),
      ),
    );
    await tester.pumpAndSettle();
    expect(
      find.text(
        'Browse assessments without an account. Live camera checks require a Motion account and Lissom or Motion+ membership.',
      ),
      findsOneWidget,
    );
    expect(
      tester
          .widget<FilledButton>(find.byKey(const Key('onboarding.continue')))
          .onPressed,
      isNotNull,
    );
    expect(find.byKey(const Key('onboarding.accountEntry')), findsOneWidget);
    await tester.tap(find.byKey(const Key('onboarding.accountEntry')));
    await tester.pumpAndSettle();
    expect(find.text('lissom account route'), findsOneWidget);
  });

  testWidgets('shell passes scoped journal loaders to measurement route', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        home: LissomShell(
          localScope: LissomLocalScope.account('user-a'),
          loader: () async => factsFromDisk(),
        ),
      ),
    );
    await tester.pumpAndSettle();
    final HomeScreen home = tester.widget<HomeScreen>(find.byType(HomeScreen));
    expect(home.sessionStoreLoader, isNotNull);
    expect(home.attemptValueStoreLoader, isNotNull);
  });
}
