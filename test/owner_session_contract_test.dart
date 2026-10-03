// Actual public Session consumer regressions; execution receipt is lane-owned.
import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:lissom/app/account_epoch_client.dart';
import 'package:lissom/app/auth_session_fence.dart';
import 'package:lissom/app/local_account_bridge.dart';
import 'package:lissom/app/local_owner.dart';
import 'package:lissom/app/onboarding_gate.dart';
import 'package:lissom/app/onboarding_store.dart';
import 'package:lissom/main.dart';
import 'package:motion_account/motion_account.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'support/facts_from_disk.dart';

const _alice = 'aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaaa';
const _bob = 'bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbbbbb';

Map<String, dynamic> _sessionBody(String id, {String token = 'fixture-a'}) => {
  'access_token': token,
  'refresh_token': 'public-fixture-refresh',
  'token_type': 'bearer',
  'expires_at': 4102444800,
  'expires_in': 3600,
  'user': _userBody(id),
};

Map<String, dynamic> _userBody(String id) => {
  'id': id,
  'aud': 'authenticated',
  'created_at': '2026-10-02T00:00:00Z',
  'app_metadata': <String, dynamic>{},
};

String _session(String id, {String token = 'fixture-a'}) =>
    jsonEncode(_sessionBody(id, token: token));

http.Response _json(Object body, {int status = 200}) => http.Response(
  jsonEncode(body), status, headers: {'content-type': 'application/json'},
);

/// All HTTP requests terminate in this in-memory fixture, including real Core
/// getUser, token-refresh, deletion, and local sign-out requests. No live URL.
final class _Fixture {
  _Fixture() {
    client = SupabaseClient(
      'https://motion.fixture.invalid', 'public-test-fixture',
      authOptions: const AuthClientOptions(autoRefreshToken: false),
      httpClient: MockClient(_respond),
    );
  }

  late final SupabaseClient client;
  Future<http.Response> Function()? verify;
  Completer<void>? deletionEntered;
  Completer<void>? deletionRelease;
  int deletions = 0;
  int logouts = 0;

  Future<http.Response> _respond(http.Request request) async {
    if (request.url.path.endsWith('/user')) {
      return verify == null ? _json(_userBody(_alice)) : verify!();
    }
    if (request.url.path.endsWith('/token')) {
      return _json(_sessionBody(_alice, token: 'fixture-refreshed'));
    }
    if (request.url.path.endsWith('/motion-delete-account')) {
      deletions++;
      deletionEntered?.complete();
      await deletionRelease?.future;
      return _json({'deleted': true, 'userId': _alice});
    }
    if (request.url.path.endsWith('/logout')) logouts++;
    return _json({});
  }

  MotionAccountClient get account => MotionAccountClient(
    supabase: client, app: MotionApp.lissom,
    emailRedirectTo: kLissomAuthRedirect,
  );

  MotionAccountRuntime runtime(LissomOwnerRegistry owners) =>
      MotionAccountRuntime.forTesting(
        client: client, app: MotionApp.lissom,
        onDeletedAccount: owners.eraseConfirmedAccount,
        localAccountIds: () async => const <String>[],
        wasAccountDeleted: (_) async => false,
      );
}

/// Only the dialog's dispatch spy is overridden; Session/auth getter and
/// public SDK stream are actual. Deletion/cleanup tests below use actual Core.
final class _DialogAccount extends MotionAccountClient {
  _DialogAccount(SupabaseClient client) : super(
    supabase: client, app: MotionApp.lissom,
    emailRedirectTo: kLissomAuthRedirect,
  );
  int dispatches = 0;
  @override
  Future<Map<String, dynamic>?> loadProfile() async => null;
  @override
  Future<void> deleteCommonAccount({
    Future<void> Function(String userId)? afterRemoteDelete,
  }) async {
    dispatches++;
    await afterRemoteDelete?.call(currentUser!.id);
  }
}

final class _Onboarding implements OnboardingStore {
  _Onboarding(this.owner);
  final LissomLocalOwner owner;
  @override
  Future<OnboardingProfile> read() => owner.io.run(() async =>
      const OnboardingProfile(completed: true, ageBand: 'u40'));
  @override
  Future<void> write(OnboardingProfile value) => owner.io.run(() async {});
}

Future<void> _settleSdk() async {
  for (int i = 0; i < 8; i++) {
    await Future<void>.delayed(Duration.zero);
  }
}

Future<void> _mount(WidgetTester tester, MotionAccountRuntime runtime,
    LissomOwnerRegistry owners) async {
  await tester.pumpWidget(LissomAccountHost(
    runtime: runtime, owners: owners,
    factsLoader: () async => factsFromDisk(),
    onboardingLoader: (scope) async => _Onboarding(scope.owner!),
  ));
  await tester.pumpAndSettle();
}

Future<void> _openDeletion(WidgetTester tester) async {
  await tester.ensureVisible(find.text('Delete Motion account'));
  await tester.tap(find.text('Delete Motion account'));
  await tester.pumpAndSettle();
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  late Directory root;
  setUp(() async {
    root = await Directory.systemTemp.createTemp('lissom-session-proposal-');
  });
  tearDown(() async {
    if (await root.exists()) await root.delete(recursive: true);
  });

  test('public initialSession new object blocks a retained wrapper with same UUID/token', () async {
    final f = _Fixture();
    final owners = LissomOwnerRegistry(canonicalSupportDirectory: root);
    await owners.initialize();
    owners.openScope(_alice);
    addTearDown(() async { owners.dispose(); await f.client.dispose(); });
    await f.client.auth.setInitialSession(_session(_alice));
    final Session? opening = f.client.auth.currentSession;
    final page = LissomEpochAccountClient(
      account: f.account, registry: owners, ticket: owners.captureTicket(_alice),
    );
    await f.client.auth.setInitialSession(_session(_alice));
    expect(identical(opening, f.client.auth.currentSession), isFalse);
    expect(f.client.auth.currentSession?.accessToken, opening?.accessToken);
    await expectLater(page.deleteCommonAccount(), throwsA(isA<LissomCleanupConflict>()));
    expect(f.deletions, 0);
    expect(f.logouts, 0);
  });

  test('silent public recoverSession emits zero events and cannot authorize an old wrapper', () async {
    final f = _Fixture();
    final owners = LissomOwnerRegistry(canonicalSupportDirectory: root);
    await owners.initialize();
    final owner = owners.openScope(_alice).owner!;
    await f.client.auth.setInitialSession(_session(_alice));
    await _settleSdk();
    final events = <AuthState>[];
    final sub = f.client.auth.onAuthStateChange.listen(events.add);
    await _settleSdk(); // Drain public ReplaySubject's existing event.
    events.clear();
    final opening = f.client.auth.currentSession;
    final marker = File('${root.path}/lissom/accounts/$_alice/sessions.jsonl');
    await marker.parent.create(recursive: true);
    await marker.writeAsString('A retained');
    final page = LissomEpochAccountClient(
      account: f.account, registry: owners, ticket: owners.captureTicket(_alice),
    );
    await f.client.auth.recoverSession(_session(_alice));
    await _settleSdk();
    expect(events, isEmpty);
    expect(identical(opening, f.client.auth.currentSession), isFalse);
    await expectLater(page.deleteCommonAccount(), throwsA(isA<LissomCleanupConflict>()));
    expect(f.deletions, 0);
    expect(f.logouts, 0);
    expect(await marker.readAsString(), 'A retained');
    // Silence supplies no idle notification: only the stale intent is blocked.
    expect(owner.isActive, isTrue);
    await sub.cancel();
    owners.dispose();
    await f.client.dispose();
  });

  test('actual public stream replay of the same Session does not replace a lifetime', () async {
    final f = _Fixture();
    addTearDown(f.client.dispose);
    await f.client.auth.setInitialSession(_session(_alice));
    final session = f.client.auth.currentSession;
    final fence = LissomAuthSessionFence(session);
    final replay = await f.client.auth.onAuthStateChange.first;
    expect(identical(replay.session, session), isTrue);
    expect(fence.observe(f.client.auth.currentSession, event: replay), LissomSessionChange.none);
    expect(fence.canInitiate(f.client.auth.currentSession), isTrue);
    // The same-reference signedIn classifier is supplied only public AuthState;
    // no private subscriber or Session setter is used to forge an SDK event.
    expect(fence.observe(session, event: AuthState(AuthChangeEvent.signedIn, session)),
        LissomSessionChange.none);
  });

  testWidgets('actual initialSession replacement synchronously retires host admission before cached verification', (tester) async {
    final f = (await tester.runAsync(() async => _Fixture()))!;
    final owners = LissomOwnerRegistry(canonicalSupportDirectory: root);
    await tester.runAsync(() => f.client.auth.setInitialSession(_session(_alice)));
    final runtime = (await tester.runAsync(() async => f.runtime(owners)))!;
    await tester.runAsync(() async { await runtime.refreshIdentity(); await _settleSdk(); });
    await _mount(tester, runtime, owners);
    final old = tester.widget<OnboardingGate>(find.byType(OnboardingGate)).localScope;
    final gates = (await tester.runAsync(() async =>
        (Completer<void>(), Completer<http.Response>())))!;
    final entered = gates.$1;
    final release = gates.$2;
    f.verify = () { if (!entered.isCompleted) entered.complete(); return release.future; };
    await tester.runAsync(() async {
      await f.client.auth.setInitialSession(_session(_alice));
      await entered.future.timeout(const Duration(seconds: 5));
      await _settleSdk();
    });
    expect(old.owner!.isActive, isFalse);
    // One frame delivers retirement without advancing the held HTTP timeout.
    await tester.pump();
    expect(find.byType(OnboardingGate), findsNothing);
    expect(runtime.phase.value, MotionIdentityPhase.verified); // Existing cached value.
    release.complete(_json(_userBody(_alice)));
    await tester.runAsync(_settleSdk);
    await tester.pumpAndSettle();
    // Exact public Session proof admits a fresh epoch only after verification.
    expect(runtime.isCurrentSessionVerified, isTrue);
    expect(find.byType(OnboardingGate), findsOneWidget);
    final fresh = tester.widget<OnboardingGate>(find.byType(OnboardingGate)).localScope;
    expect(fresh.lifetimeKey, isNot(old.lifetimeKey));
    await tester.pumpWidget(const SizedBox.shrink());
    await tester.runAsync(f.client.dispose);
  });

  testWidgets('actual normal token refresh preserves host owner and storage E while credential initiation closes', (tester) async {
    final f = (await tester.runAsync(() async => _Fixture()))!;
    final owners = LissomOwnerRegistry(canonicalSupportDirectory: root);
    await tester.runAsync(() => f.client.auth.setInitialSession(_session(_alice)));
    final runtime = (await tester.runAsync(() async => f.runtime(owners)))!;
    await tester.runAsync(() async { await runtime.refreshIdentity(); await _settleSdk(); });
    await _mount(tester, runtime, owners);
    final old = tester.widget<OnboardingGate>(find.byType(OnboardingGate)).localScope;
    final ticket = owners.captureTicket(_alice);
    final fence = LissomAuthSessionFence(f.client.auth.currentSession);
    final oldPage = LissomEpochAccountClient(account: f.account, registry: owners, ticket: ticket);
    final event = f.client.auth.onAuthStateChange.firstWhere((e) => e.event == AuthChangeEvent.tokenRefreshed);
    await tester.runAsync(() async { await f.client.auth.refreshSession(); await _settleSdk(); });
    final observed = (await tester.runAsync(() => event))!;
    expect(fence.observe(f.client.auth.currentSession, event: observed), LissomSessionChange.credentialRefresh);
    expect(fence.canInitiate(f.client.auth.currentSession), isFalse);
    expect(old.owner!.isActive, isTrue);
    await tester.pumpAndSettle();
    expect(tester.widget<OnboardingGate>(find.byType(OnboardingGate)).localScope.lifetimeKey, old.lifetimeKey);
    expect(owners.isCurrentTicket(ticket), isTrue);
    await tester.runAsync(() => expectLater(oldPage.deleteCommonAccount(), throwsA(isA<LissomCleanupConflict>())));
    expect(f.deletions, 0);
    await tester.pumpWidget(const SizedBox.shrink());
    await tester.runAsync(f.client.dispose);
  });

  test('queued stale tokenRefreshed cannot bless a silent newer Session', () async {
    final f = _Fixture();
    addTearDown(f.client.dispose);
    await f.client.auth.setInitialSession(_session(_alice));
    final fence = LissomAuthSessionFence(f.client.auth.currentSession);
    final refreshEvent = f.client.auth.onAuthStateChange.firstWhere((e) => e.event == AuthChangeEvent.tokenRefreshed);
    await f.client.auth.refreshSession();
    final event = await refreshEvent;
    await f.client.auth.recoverSession(_session(_alice, token: 'fixture-refreshed'));
    expect(identical(event.session, f.client.auth.currentSession), isFalse);
    expect(fence.observe(f.client.auth.currentSession, event: event), LissomSessionChange.replacement);
    expect(fence.canInitiate(f.client.auth.currentSession), isFalse);
  });

  test('a fresh wrapper after silent replacement cannot reuse cached credential binding', () async {
    final f = _Fixture();
    final owners = LissomOwnerRegistry(canonicalSupportDirectory: root);
    await owners.initialize(); owners.openScope(_alice);
    await f.client.auth.setInitialSession(_session(_alice));
    final fence = LissomAuthSessionFence(f.client.auth.currentSession);
    await f.client.auth.recoverSession(_session(_alice));
    expect(fence.observe(f.client.auth.currentSession), LissomSessionChange.replacement);
    final fresh = LissomEpochAccountClient(
      account: f.account, registry: owners, ticket: owners.captureTicket(_alice),
      canInitiate: () => fence.canInitiate(f.client.auth.currentSession),
    );
    await expectLater(fresh.deleteCommonAccount(), throwsA(isA<LissomCleanupConflict>()));
    expect(f.deletions, 0);
    owners.dispose(); await f.client.dispose();
  });

  test('verified exact replacement can bind a fresh wrapper while old wrapper stays closed', () async {
    final f = _Fixture();
    final owners = LissomOwnerRegistry(canonicalSupportDirectory: root);
    await owners.initialize();
    owners.openScope(_alice);
    await f.client.auth.setInitialSession(_session(_alice));
    final runtime = f.runtime(owners);
    await runtime.refreshIdentity();
    final old = LissomEpochAccountClient(
      account: f.account, registry: owners, ticket: owners.captureTicket(_alice),
    );
    final fence = LissomAuthSessionFence(f.client.auth.currentSession);
    await f.client.auth.recoverSession(_session(_alice));
    fence.observe(f.client.auth.currentSession);
    expect(runtime.isCurrentSessionVerified, isFalse);
    await runtime.refreshIdentity();
    expect(runtime.isCurrentSessionVerified, isTrue);
    fence.bindVerified(f.client.auth.currentSession);
    final fresh = LissomEpochAccountClient(
      account: f.account, registry: owners, ticket: owners.captureTicket(_alice),
      canInitiate: () => runtime.isCurrentSessionVerified &&
          fence.canInitiate(f.client.auth.currentSession),
    );
    await expectLater(old.deleteCommonAccount(), throwsA(isA<LissomCleanupConflict>()));
    await fresh.deleteCommonAccount();
    expect(f.deletions, 1);
    runtime.dispose();
    owners.dispose();
    await f.client.dispose();
  });

  testWidgets('silent replacement is reconciled at the actual host account-route boundary', (tester) async {
    final f = (await tester.runAsync(() async => _Fixture()))!;
    final owners = LissomOwnerRegistry(canonicalSupportDirectory: root);
    await tester.runAsync(() => f.client.auth.setInitialSession(_session(_alice)));
    final runtime = (await tester.runAsync(() async => f.runtime(owners)))!;
    await tester.runAsync(() async { await runtime.refreshIdentity(); await _settleSdk(); });
    await _mount(tester, runtime, owners);
    final old = tester.widget<OnboardingGate>(find.byType(OnboardingGate)).localScope;
    final events = <AuthState>[];
    final sub = (await tester.runAsync(() async =>
        f.client.auth.onAuthStateChange.listen(events.add)))!;
    await tester.runAsync(_settleSdk); events.clear();
    await tester.runAsync(() async {
      await f.client.auth.recoverSession(_session(_alice)); await _settleSdk();
    });
    expect(events, isEmpty);
    expect(old.owner!.isActive, isTrue); // No silent idle notification promised.
    final app = tester.widget<LissomApp>(find.byType(LissomApp));
    final routeContext = tester.element(find.byType(OnboardingGate));
    await tester.runAsync(() async {
      app.accountRouteBuilder!(routeContext, MotionApp.lissom.name);
      await _settleSdk();
    });
    expect(old.owner!.isActive, isFalse); // Actual synchronous host admission seam.
    await tester.runAsync(_settleSdk); await tester.pumpAndSettle();
    expect(runtime.isCurrentSessionVerified, isTrue);
    expect(find.byType(OnboardingGate), findsOneWidget);
    final fresh = tester.widget<OnboardingGate>(find.byType(OnboardingGate)).localScope;
    expect(fresh.lifetimeKey, isNot(old.lifetimeKey));
    expect(runtime.phase.value, MotionIdentityPhase.verified);
    await tester.runAsync(() => sub.cancel().timeout(const Duration(seconds: 5)));
    await tester.pumpWidget(const SizedBox.shrink());
    await tester.runAsync(f.client.dispose);
  });

  test('superseded real runtime verification cannot authorize cached verified values', () async {
    final f = _Fixture();
    final owners = LissomOwnerRegistry(canonicalSupportDirectory: root);
    await owners.initialize();
    await f.client.auth.setInitialSession(_session(_alice));
    final runtime = f.runtime(owners);
    await runtime.refreshIdentity();
    await _settleSdk();
    expect(runtime.phase.value, MotionIdentityPhase.verified);
    await f.client.auth.recoverSession(_session(_alice)); // Silent actual replacement.
    final captured = f.client.auth.currentSession;
    final requests = <Completer<http.Response>>[];
    f.verify = () { final reply = Completer<http.Response>(); requests.add(reply); return reply.future; };
    final first = runtime.refreshIdentity();
    await _settleSdk();
    final second = runtime.refreshIdentity();
    await _settleSdk();
    expect(requests.length, 2);
    requests[0].complete(_json(_userBody(_alice)));
    await first; // Rejected internally as superseded; its public result is void.
    expect(identical(f.client.auth.currentSession, captured), isTrue);
    expect(runtime.phase.value, MotionIdentityPhase.verified);
    expect(runtime.userId.value, _alice);
    expect(runtime.isCurrentSessionVerified, isFalse);
    final error = expectLater(second, throwsA(anything));
    requests[1].complete(_json({'message': 'fixture verification unavailable'}, status: 500));
    await error;
    expect(runtime.phase.value, MotionIdentityPhase.unavailable);
    runtime.dispose();
    owners.dispose();
    await f.client.dispose();
  });

  testWidgets('same actual Session with rebuilt wrapper dispatches the opening wrapper and cleanup', (tester) async {
    final f = (await tester.runAsync(() async => _Fixture()))!;
    final owners = LissomOwnerRegistry(canonicalSupportDirectory: root);
    await tester.runAsync(owners.initialize);
    owners.openScope(_alice);
    await tester.runAsync(() => f.client.auth.setInitialSession(_session(_alice)));
    final opening = _DialogAccount(f.client);
    final replacement = _DialogAccount(f.client);
    final ticket = owners.captureTicket(_alice);
    final first = LissomEpochAccountClient(account: opening, registry: owners, ticket: ticket);
    final second = LissomEpochAccountClient(account: replacement, registry: owners, ticket: ticket);
    final selected = ValueNotifier<MotionAccountClient>(first);
    var openingCleanup = 0;
    var replacementCleanup = 0;
    await tester.pumpWidget(MaterialApp(home: ValueListenableBuilder<MotionAccountClient>(
      valueListenable: selected,
      builder: (_, value, _) => MotionAccountPage(account: value, clearLocalData: (_) async {
        if (identical(value, first)) { openingCleanup++; } else { replacementCleanup++; }
      }),
    )));
    await tester.pumpAndSettle();
    await _openDeletion(tester);
    final session = f.client.auth.currentSession;
    selected.value = second;
    await tester.pumpAndSettle();
    expect(identical(session, f.client.auth.currentSession), isTrue);
    await tester.tap(find.text('Delete account'));
    await tester.pumpAndSettle();
    expect(opening.dispatches, 1);
    expect(replacement.dispatches, 0);
    expect(openingCleanup, 1);
    expect(replacementCleanup, 0);
    await tester.pumpWidget(const SizedBox.shrink());
    selected.dispose(); owners.dispose();
    await tester.runAsync(f.client.dispose);
  });

  testWidgets('fresh actual Session with same UUID/token cannot inherit an open dialog', (tester) async {
    final f = (await tester.runAsync(() async => _Fixture()))!;
    final account = _DialogAccount(f.client);
    await tester.runAsync(() => f.client.auth.setInitialSession(_session(_alice)));
    await tester.pumpWidget(MaterialApp(home: MotionAccountPage(account: account, clearLocalData: (_) async {})));
    await tester.pumpAndSettle();
    await _openDeletion(tester);
    final opening = f.client.auth.currentSession;
    await tester.runAsync(() => f.client.auth.setInitialSession(_session(_alice)));
    expect(identical(opening, f.client.auth.currentSession), isFalse);
    await tester.pump();
    await tester.tap(find.text('Delete account'));
    await tester.pumpAndSettle();
    expect(account.dispatches, 0);
    await tester.pumpWidget(const SizedBox.shrink());
    await tester.runAsync(f.client.dispose);
  });

  testWidgets('disposed account parent cannot dispatch from a retained dialog', (tester) async {
    final f = (await tester.runAsync(() async => _Fixture()))!;
    final account = _DialogAccount(f.client);
    final visible = ValueNotifier<bool>(true);
    await tester.runAsync(() => f.client.auth.setInitialSession(_session(_alice)));
    await tester.pumpWidget(MaterialApp(home: ValueListenableBuilder<bool>(
      valueListenable: visible,
      builder: (_, value, _) => value ? MotionAccountPage(account: account, clearLocalData: (_) async {}) : const SizedBox(),
    )));
    await tester.pumpAndSettle(); await _openDeletion(tester);
    visible.value = false;
    await tester.pumpAndSettle();
    expect(find.text('Delete account'), findsOneWidget);
    await tester.tap(find.text('Delete account'));
    await tester.pumpAndSettle();
    expect(account.dispatches, 0);
    expect(tester.takeException(), isNull);
    await tester.pumpWidget(const SizedBox.shrink()); visible.dispose();
    await tester.runAsync(f.client.dispose);
  });

  testWidgets('retained deletion dialog uses its live localized context after parent removal', (tester) async {
    final f = (await tester.runAsync(() async => _Fixture()))!;
    final account = _DialogAccount(f.client);
    final locale = ValueNotifier<Locale>(const Locale('en'));
    final visible = ValueNotifier<bool>(true);
    await tester.runAsync(() => f.client.auth.setInitialSession(_session(_alice)));
    await tester.pumpWidget(ValueListenableBuilder<Locale>(valueListenable: locale, builder: (_, value, _) =>
      MaterialApp(locale: value, supportedLocales: const [Locale('en'), Locale('tr')],
        localizationsDelegates: const [GlobalMaterialLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate, GlobalWidgetsLocalizations.delegate],
        home: ValueListenableBuilder<bool>(valueListenable: visible,
          builder: (_, value, _) => value ? MotionAccountPage(account: account, clearLocalData: (_) async {}) : const SizedBox()),
      ),
    ));
    await tester.pumpAndSettle(); await _openDeletion(tester);
    visible.value = false; locale.value = const Locale('tr');
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
    expect(find.text('Hesabı sil'), findsOneWidget);
    await tester.tap(find.text('Hesabı sil'));
    await tester.pumpAndSettle();
    expect(account.dispatches, 0);
    await tester.pumpWidget(const SizedBox.shrink()); locale.dispose(); visible.dispose();
    await tester.runAsync(f.client.dispose);
  });

  test('held real deletion plus actual token refresh keeps E then drains before erasure and preserves replacement Auth', () async {
    final f = _Fixture();
    final owners = LissomOwnerRegistry(canonicalSupportDirectory: root);
    await owners.initialize();
    final scope = owners.openScope(_alice);
    await f.client.auth.setInitialSession(_session(_alice));
    final ticket = owners.captureTicket(_alice);
    final page = LissomEpochAccountClient(account: f.account, registry: owners, ticket: ticket);
    final marker = scope.file(root, LissomLocalFile.sessions);
    await marker.parent.create(recursive: true); await marker.writeAsString('A');
    final drain = Completer<void>(); var retired = false;
    scope.owner!.registerResource(() { retired = true; return drain.future; });
    f.deletionEntered = Completer<void>(); f.deletionRelease = Completer<void>();
    final deletion = page.deleteCommonAccount(afterRemoteDelete: (id) => owners.eraseWithTicket(ticket, id));
    await f.deletionEntered!.future;
    await f.client.auth.refreshSession();
    final replacement = f.client.auth.currentSession;
    expect(owners.isCurrentTicket(ticket), isTrue);
    expect(scope.owner!.isActive, isTrue);
    f.deletionRelease!.complete(); await _settleSdk();
    expect(retired, isTrue); expect(scope.owner!.isActive, isFalse);
    expect(await marker.exists(), isTrue); expect(owners.isFenced(_alice), isTrue);
    drain.complete(); await deletion;
    expect(await marker.exists(), isFalse);
    expect(identical(f.client.auth.currentSession, replacement), isTrue);
    expect(f.logouts, 0);
    owners.dispose(); await f.client.dispose();
  });

  test('permanent confirmed UUID fences ALL A epochs despite a fresh Session and preserves guest/B', () async {
    final f = _Fixture();
    final owners = LissomOwnerRegistry(canonicalSupportDirectory: root);
    await owners.initialize();
    final a = owners.openScope(_alice);
    final oldTicket = owners.captureTicket(_alice);
    await f.client.auth.setInitialSession(_session(_alice));
    await f.client.auth.setInitialSession(_session(_alice));
    final replacement = f.client.auth.currentSession;
    owners.invalidateTickets(_alice);
    final a1 = owners.openScope(_alice);
    final b = owners.openScope(_bob); final guest = owners.openScope(null);
    for (final scope in [a1, b, guest]) {
      final file = scope.file(root, LissomLocalFile.sessions);
      await file.parent.create(recursive: true); await file.writeAsString(scope.ownerKey);
    }
    await expectLater(owners.eraseWithTicket(oldTicket, _alice), throwsA(isA<LissomCleanupConflict>()));
    expect(a1.owner!.isActive, isTrue); // Old page cannot retire successor.
    final closeA = Completer<void>(); final closeA1 = Completer<void>();
    a.owner!.registerResource(() => closeA.future);
    a1.owner!.registerResource(() => closeA1.future);
    final erase = owners.eraseConfirmedAccount(_alice); // No Session predicate.
    expect(a.owner!.isActive, isFalse); expect(a1.owner!.isActive, isFalse);
    expect(b.owner!.isActive, isTrue); expect(guest.owner!.isActive, isTrue);
    expect(() => owners.openScope(_alice), throwsA(isA<LissomOwnerClosed>()));
    closeA.complete(); await _settleSdk();
    expect(await a1.file(root, LissomLocalFile.sessions).exists(), isTrue);
    closeA1.complete(); await erase;
    expect(await a1.file(root, LissomLocalFile.sessions).exists(), isFalse);
    expect(await b.file(root, LissomLocalFile.sessions).readAsString(), b.ownerKey);
    expect(await guest.file(root, LissomLocalFile.sessions).readAsString(), guest.ownerKey);
    expect(identical(f.client.auth.currentSession, replacement), isTrue);
    owners.dispose(); await f.client.dispose();
  });
}
