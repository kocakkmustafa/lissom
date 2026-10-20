import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:lissom/app/account_epoch_client.dart';
import 'package:lissom/app/camera_pose_source.dart';
import 'package:lissom/app/home_screen.dart';
import 'package:lissom/app/live_capture_screen.dart';
import 'package:lissom/app/lissom_locales.dart';
import 'package:lissom/app/lissom_localizations.dart';
import 'package:lissom/app/local_account_bridge.dart';
import 'package:lissom/app/local_owner.dart';
import 'package:lissom/app/onboarding_gate.dart';
import 'package:lissom/app/onboarding_store.dart';
import 'package:lissom/app/shell.dart';
import 'package:lissom/main.dart';
import 'package:lissom_engine/lissom_engine.dart';
import 'package:motion_account/motion_account.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'support/facts_from_disk.dart';

const String _alice = 'aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaaa';
const String _bob = 'bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbbbbb';

User _user(String id) => User(
  id: id,
  appMetadata: const <String, dynamic>{},
  userMetadata: null,
  aud: 'authenticated',
  createdAt: '2026-10-02T00:00:00Z',
  email: 'fixture@example.invalid',
);

Map<String, dynamic> _fixtureSession(
  String id, [
  String token = 'fixture-initial',
]) => {
  'access_token': token,
  'refresh_token': 'public-fixture-refresh',
  'token_type': 'bearer',
  'expires_at': 4102444800,
  'user': _user(id).toJson(),
};

/// In-memory HTTP only. These legacy runtime doubles remain intent/lifetime
/// fixtures; new Session acceptance claims use owner_session_contract_test.
final class _Account extends MotionAccountClient {
  _Account()
    : super(
        supabase: SupabaseClient(
          'https://fixture.invalid',
          'public-fixture',
          authOptions: const AuthClientOptions(autoRefreshToken: false),
          httpClient: MockClient(
            (request) async => http.Response(
              jsonEncode(
                request.url.path.endsWith('/token')
                    ? _fixtureSession(_alice, 'fixture-refreshed')
                    : <String, dynamic>{},
              ),
              200,
              headers: const {'content-type': 'application/json'},
            ),
          ),
        ),
        app: MotionApp.lissom,
        emailRedirectTo: kLissomAuthRedirect,
      ) {
    initialSessionReady = supabase.auth.setInitialSession(
      jsonEncode(_fixtureSession(_alice)),
    );
  }

  late final Future<void> initialSessionReady;
  final StreamController<AuthState> changes =
      StreamController<AuthState>.broadcast(sync: true);
  User? user = _user(_alice);
  bool updateFails = false;
  int deleteCalls = 0;
  int passwordCalls = 0;
  VoidCallback? onUpdated;
  Completer<void>? remoteDeletion;
  Completer<void>? deletionSettled;
  Object? deletionError;

  @override
  User? get currentUser => user;
  @override
  Stream<AuthState> get authChanges => changes.stream;
  @override
  Future<Map<String, dynamic>?> loadProfile() async => null;
  @override
  Future<bool> hasActiveMembership() async => false;
  @override
  Future<UserResponse> updatePassword(String password) async {
    passwordCalls++;
    if (updateFails) throw StateError('fixture password error');
    onUpdated?.call();
    changes.add(const AuthState(AuthChangeEvent.userUpdated, null));
    return UserResponse.fromJson(user!.toJson());
  }

  @override
  Future<void> deleteCommonAccount({
    Future<void> Function(String userId)? afterRemoteDelete,
  }) async {
    deleteCalls++;
    final String captured = user!.id;
    await remoteDeletion?.future;
    try {
      await afterRemoteDelete?.call(captured);
    } catch (error) {
      deletionError = error;
      rethrow;
    } finally {
      deletionSettled?.complete();
    }
  }

  void event(AuthChangeEvent event) =>
      changes.add(AuthState(event, supabase.auth.currentSession));

  Future<void> refreshCredential() async {
    await supabase.auth.refreshSession();
    event(AuthChangeEvent.tokenRefreshed);
  }

  void replaceSession(String id) {
    unawaited(supabase.auth.setInitialSession(jsonEncode(_fixtureSession(id))));
  }

  void close() {
    unawaited(changes.close());
    unawaited(supabase.dispose());
  }
}

final class _Runtime implements MotionAccountRuntime {
  _Runtime({
    bool recovery = false,
    MotionIdentityPhase initialPhase = MotionIdentityPhase.verified,
  }) : phase = ValueNotifier<MotionIdentityPhase>(initialPhase),
       passwordRecovery = ValueNotifier<bool>(recovery) {
    account.onUpdated = () => passwordRecovery.value = false;
  }

  @override
  final _Account account = _Account();
  @override
  final ValueNotifier<String?> userId = ValueNotifier<String?>(_alice);
  @override
  final ValueNotifier<MotionIdentityPhase> phase;
  @override
  final ValueNotifier<bool> passwordRecovery;
  @override
  bool get isPasswordRecovery => passwordRecovery.value;
  @override
  bool get isDisposed => _disposed;
  bool _disposed = false;
  @override
  Listenable get identityVerification => phase;
  @override
  bool get isCurrentSessionVerified =>
      !_disposed &&
      phase.value == MotionIdentityPhase.verified &&
      account.supabase.auth.currentSession?.user.id == userId.value;

  void recover() {
    passwordRecovery.value = true;
    account.event(AuthChangeEvent.passwordRecovery);
  }

  void replacement(String? id) {
    account.user = id == null ? null : _user(id);
    if (id != null) account.replaceSession(id);
    userId.value = id;
    phase.value = id == null
        ? MotionIdentityPhase.signedOut
        : MotionIdentityPhase.verified;
    account.event(
      id == null ? AuthChangeEvent.signedOut : AuthChangeEvent.signedIn,
    );
  }

  @override
  Future<void> refreshIdentity() async {
    phase.value = MotionIdentityPhase.verified;
  }

  @override
  void dispose() {
    _disposed = true;
    account.close();
    phase.dispose();
    userId.dispose();
    passwordRecovery.dispose();
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

final class _Onboarding implements OnboardingStore {
  _Onboarding(this.owner);
  final LissomLocalOwner owner;
  @override
  Future<OnboardingProfile> read() => owner.io.run(
    () async => const OnboardingProfile(completed: true, ageBand: 'u40'),
  );
  @override
  Future<void> write(OnboardingProfile profile) => owner.io.run(() async {});
}

final class _Source implements StartablePoseSource {
  final StreamController<PoseSourceEvent> eventsController =
      StreamController<PoseSourceEvent>.broadcast(sync: true);
  final Completer<void> closeBarrier = Completer<void>();
  int starts = 0;
  int disposals = 0;
  bool retired = false;
  @override
  Stream<PoseSourceEvent> events() => eventsController.stream;
  @override
  Future<void> start() async {
    starts++;
  }

  @override
  Future<void> dispose() {
    disposals++;
    retired = true;
    return closeBarrier.future;
  }
}

Future<void> _hostVisible(
  WidgetTester tester,
  Finder target, {
  bool admissionClosed = false,
}) async {
  for (int attempt = 0; attempt < 100; attempt++) {
    if (admissionClosed) {
      expect(find.byType(OnboardingGate), findsNothing);
      expect(find.byType(HomeScreen), findsNothing);
      expect(find.byType(LiveCaptureScreen), findsNothing);
    }
    if (target.evaluate().isNotEmpty) {
      expect(target, findsOneWidget);
      expect(
        LissomLocalizations.maybeOf(tester.element(target))?.catalogAvailable,
        isTrue,
      );
      return;
    }
    // A fresh keyed MaterialApp re-enters the real asynchronous delegate even
    // when its rootBundle string is cached. Never replace it with a fake sync
    // delegate or release held resource/root Futures to make the UI appear.
    await tester.runAsync(
      () => Future<void>.delayed(const Duration(milliseconds: 20)),
    );
    await tester.pump(const Duration(milliseconds: 20));
  }
  fail('Timed out waiting for the actual host surface: $target');
}

Future<void> _mount(
  WidgetTester tester,
  _Runtime runtime,
  LissomOwnerRegistry owners,
) async {
  await tester.runAsync(() async {
    await runtime.account.initialSessionReady.timeout(
      const Duration(seconds: 5),
    );
    if (runtime.phase.value == MotionIdentityPhase.signedOut) {
      // A signed-out fixture must also have a genuinely null public Session.
      await runtime.account.supabase.auth.signOut(scope: SignOutScope.local);
    }
  });
  expect(
    runtime.account.supabase.auth.currentSession?.user.id,
    runtime.userId.value,
  );
  final String tag = canonicalLocaleTag(
    resolveLissomLocale(
      tester.platformDispatcher.locales,
      kLissomSupportedLocales,
    ),
  );
  // Complete the real rootBundle >50KiB decode outside the fake clock. The
  // production delegate then awaits this same cached Future; no catalog fake.
  final String? raw = await tester.runAsync(
    () => rootBundle
        .loadString('config/l10n/$tag.json')
        .timeout(const Duration(seconds: 5)),
  );
  expect(raw, isNotNull);
  expect(LissomLocalizations.parse(raw!, tag).catalogAvailable, isTrue);
  // A deliberately held immutable-root Future must remain held. Wait only for
  // the appropriate visible host surface, never initialize/complete its root.
  final Finder ready = !owners.isInitialized
      ? find.byKey(const Key('lissom.owner.closed'))
      : runtime.isPasswordRecovery
      ? find.text('Save password')
      : find.byType(HomeScreen);
  await tester.pumpWidget(
    LissomAccountHost(
      runtime: runtime,
      owners: owners,
      factsLoader: () async => factsFromDisk(),
      onboardingLoader: (LissomLocalScope scope) async =>
          _Onboarding(scope.owner!),
    ),
  );
  for (int attempt = 0; attempt < 100 && ready.evaluate().isEmpty; attempt++) {
    await tester.runAsync(
      () => Future<void>.delayed(const Duration(milliseconds: 20)),
    );
    await tester.pump(const Duration(milliseconds: 20));
  }
  expect(
    ready,
    findsOneWidget,
    reason: 'The actual host must be ready before its lifecycle is exercised',
  );
  expect(
    LissomLocalizations.maybeOf(tester.element(ready))?.catalogAvailable,
    isTrue,
  );
  await tester.pumpAndSettle();
}

Future<void> _capture(WidgetTester tester, _Source source) async {
  final BuildContext context = tester.element(find.byType(HomeScreen));
  // Camera remains closed in production. This mounts the real future route
  // solely to probe the actual host lifetime and source-retirement seam.
  unawaited(
    Navigator.of(context).push<void>(
      MaterialPageRoute<void>(
        builder: (_) => LiveCaptureScreen(
          test: batteryFromDisk().tests['overhead_reach']!,
          batteryVersion: batteryFromDisk().version,
          sourceOverride: source,
        ),
      ),
    ),
  );
  await tester.pumpAndSettle();
}

void main() {
  late Directory directory;
  setUp(() async {
    directory = await Directory.systemTemp.createTemp('lissom-host-adoption-');
  });
  tearDown(() async {
    await directory.delete(recursive: true);
  });

  testWidgets(
    'cold recovery uses real host account route without store admission',
    (tester) async {
      final _Runtime runtime = _Runtime(recovery: true);
      final LissomOwnerRegistry owners = LissomOwnerRegistry(
        canonicalSupportDirectory: directory,
      );
      await _mount(tester, runtime, owners);
      expect(find.text('Save password'), findsOneWidget);
      expect(find.byType(OnboardingGate), findsNothing);
      expect(find.byType(LiveCaptureScreen), findsNothing);
      expect(find.textContaining('Membership options'), findsNothing);
      await tester.pumpWidget(const SizedBox.shrink());
    },
  );

  testWidgets('cold recovery waits immutable root binding before account UI', (
    tester,
  ) async {
    final _Runtime runtime = _Runtime(recovery: true);
    final Completer<Directory> support = Completer<Directory>();
    final LissomOwnerRegistry owners = LissomOwnerRegistry(
      supportDirectory: () => support.future,
    );
    await _mount(tester, runtime, owners);
    expect(find.byKey(const Key('lissom.owner.closed')), findsOneWidget);
    expect(find.byType(MotionAccountPage), findsNothing);
    expect(find.byType(OnboardingGate), findsNothing);
    support.complete(directory);
    await tester.pumpAndSettle();
    await _hostVisible(tester, find.text('Save password'), admissionClosed: true);
    expect(find.text('Save password'), findsOneWidget);
    expect(find.byType(OnboardingGate), findsNothing);
    await tester.pumpWidget(const SizedBox.shrink());
  });

  testWidgets(
    'warm same-user recovery retires mounted capture before UI frame',
    (tester) async {
      final _Runtime runtime = _Runtime();
      final LissomOwnerRegistry owners = LissomOwnerRegistry(
        canonicalSupportDirectory: directory,
      );
      await _mount(tester, runtime, owners);
      final LissomLocalScope old = tester
          .widget<OnboardingGate>(find.byType(OnboardingGate))
          .localScope;
      final _Source source = _Source();
      await _capture(tester, source);
      expect(source.starts, 1);
      runtime.recover();
      expect(old.owner!.isActive, isFalse);
      expect(source.retired, isTrue);
      expect(source.disposals, 1);
      await tester.pumpAndSettle();
      await _hostVisible(tester, find.text('Save password'), admissionClosed: true);
      expect(find.text('Save password'), findsOneWidget);
      expect(find.byType(LiveCaptureScreen), findsNothing);
      source.closeBarrier.complete();
      await tester.pumpAndSettle();
      await tester.pumpWidget(const SizedBox.shrink());
      await source.eventsController.close();
    },
  );

  testWidgets(
    'password success waits old close before opening a fresh same-user lifetime',
    (tester) async {
      final _Runtime runtime = _Runtime();
      final LissomOwnerRegistry owners = LissomOwnerRegistry(
        canonicalSupportDirectory: directory,
      );
      await _mount(tester, runtime, owners);
      final LissomLocalScope old = tester
          .widget<OnboardingGate>(find.byType(OnboardingGate))
          .localScope;
      final _Source source = _Source();
      await _capture(tester, source);
      runtime.recover();
      await tester.pumpAndSettle();
      await _hostVisible(tester, find.text('Save password'), admissionClosed: true);
      await tester.enterText(find.byType(TextField), 'fixture-only-password');
      await tester.tap(find.text('Save password'));
      await tester.pumpAndSettle();
      expect(runtime.passwordRecovery.value, isFalse);
      expect(find.byType(OnboardingGate), findsNothing);
      await _hostVisible(
        tester,
        find.byKey(const Key('lissom.owner.closed')),
        admissionClosed: true,
      );
      expect(find.byKey(const Key('lissom.owner.closed')), findsOneWidget);
      source.closeBarrier.complete();
      await tester.pumpAndSettle();
      await _hostVisible(tester, find.byType(OnboardingGate));
      final LissomLocalScope fresh = tester
          .widget<OnboardingGate>(find.byType(OnboardingGate))
          .localScope;
      expect(fresh.ownerKey, old.ownerKey);
      expect(fresh.lifetimeKey, isNot(old.lifetimeKey));
      expect(old.owner!.isActive, isFalse);
      expect(fresh.owner!.isActive, isTrue);
      expect(source.disposals, 1);
      await tester.pumpWidget(const SizedBox.shrink());
      await source.eventsController.close();
    },
  );

  testWidgets(
    'password error keeps recovery form and resource admission closed',
    (tester) async {
      final _Runtime runtime = _Runtime(recovery: true);
      runtime.account.updateFails = true;
      final LissomOwnerRegistry owners = LissomOwnerRegistry(
        canonicalSupportDirectory: directory,
      );
      await _mount(tester, runtime, owners);
      await tester.enterText(find.byType(TextField), 'fixture-only-password');
      await tester.tap(find.text('Save password'));
      await tester.pumpAndSettle();
      expect(runtime.account.passwordCalls, 1);
      expect(runtime.passwordRecovery.value, isTrue);
      expect(find.text('Save password'), findsOneWidget);
      expect(find.byType(OnboardingGate), findsNothing);
      await tester.pumpWidget(const SizedBox.shrink());
    },
  );

  testWidgets(
    'failed capture close blocks owner remount after password success',
    (tester) async {
      final _Runtime runtime = _Runtime();
      final LissomOwnerRegistry owners = LissomOwnerRegistry(
        canonicalSupportDirectory: directory,
      );
      await _mount(tester, runtime, owners);
      final LissomLocalScope old = tester
          .widget<OnboardingGate>(find.byType(OnboardingGate))
          .localScope;
      final _Source source = _Source();
      await _capture(tester, source);
      runtime.recover();
      await tester.pumpAndSettle();
      await _hostVisible(tester, find.text('Save password'), admissionClosed: true);
      source.closeBarrier.completeError(
        StateError('fixture native close failure'),
      );
      await tester.pumpAndSettle();
      await tester.enterText(find.byType(TextField), 'fixture-only-password');
      await tester.tap(find.text('Save password'));
      await tester.pumpAndSettle();
      expect(runtime.passwordRecovery.value, isFalse);
      expect(old.owner!.isActive, isFalse);
      expect(find.byType(OnboardingGate), findsNothing);
      await _hostVisible(
        tester,
        find.byKey(const Key('lissom.owner.closed')),
        admissionClosed: true,
      );
      expect(find.byKey(const Key('lissom.owner.closed')), findsOneWidget);
      expect(find.textContaining('could not close'), findsOneWidget);
      expect(source.disposals, 1);
      await tester.pumpWidget(const SizedBox.shrink());
      await source.eventsController.close();
    },
  );

  testWidgets(
    'recovery verification error keeps identity gate and retained owner closed',
    (tester) async {
      final _Runtime runtime = _Runtime();
      final LissomOwnerRegistry owners = LissomOwnerRegistry(
        canonicalSupportDirectory: directory,
      );
      await _mount(tester, runtime, owners);
      final LissomLocalScope old = tester
          .widget<OnboardingGate>(find.byType(OnboardingGate))
          .localScope;
      runtime.recover();
      runtime.phase.value = MotionIdentityPhase.unavailable;
      expect(old.owner!.isActive, isFalse);
      await tester.pumpAndSettle();
      expect(find.byType(OnboardingGate), findsNothing);
      expect(find.text('Save password'), findsNothing);
      expect(find.textContaining('Could not verify'), findsOneWidget);
      await tester.pumpWidget(const SizedBox.shrink());
    },
  );

  testWidgets(
    'real token refresh preserves owner epoch and a fresh Session retires it pending proof',
    (tester) async {
      final _Runtime runtime = _Runtime();
      final LissomOwnerRegistry owners = LissomOwnerRegistry(
        canonicalSupportDirectory: directory,
      );
      await _mount(tester, runtime, owners);
      final LissomLocalScope old = tester
          .widget<OnboardingGate>(find.byType(OnboardingGate))
          .localScope;
      await tester.runAsync(runtime.account.refreshCredential);
      await tester.pumpAndSettle();
      expect(
        tester
            .widget<OnboardingGate>(find.byType(OnboardingGate))
            .localScope
            .lifetimeKey,
        old.lifetimeKey,
      );
      runtime.replacement(_alice);
      expect(old.owner!.isActive, isFalse);
      await tester.pumpAndSettle();
      expect(find.byType(OnboardingGate), findsNothing);
      await _hostVisible(
        tester,
        find.byKey(const Key('lissom.owner.closed')),
        admissionClosed: true,
      );
      expect(find.byKey(const Key('lissom.owner.closed')), findsOneWidget);
      await tester.pumpWidget(const SizedBox.shrink());
    },
  );

  testWidgets(
    'token refresh during held deletion keeps epoch and drains captured resources',
    (tester) async {
      final _Runtime runtime = _Runtime();
      final LissomOwnerRegistry owners = LissomOwnerRegistry(
        canonicalSupportDirectory: directory,
      );
      await _mount(tester, runtime, owners);
      final LissomLocalScope old = tester
          .widget<OnboardingGate>(find.byType(OnboardingGate))
          .localScope;
      final LissomDeletionTicket ticket = owners.captureTicket(_alice);
      final LissomEpochAccountClient page = LissomEpochAccountClient(
        account: runtime.account,
        registry: owners,
        ticket: ticket,
      );
      bool resourceRetired = false;
      final Completer<void> resourceClose = Completer<void>();
      old.owner!.registerResource(() {
        resourceRetired = true;
        return resourceClose.future;
      });
      final File marker = old.file(directory, LissomLocalFile.sessions);
      runtime.account.remoteDeletion = Completer<void>();
      late Future<void> deletion;
      await tester.runAsync(() async {
        await marker.parent.create(recursive: true);
        await marker.writeAsString('captured epoch data');
        deletion = page.deleteCommonAccount(
          afterRemoteDelete: (String id) => owners.eraseWithTicket(ticket, id),
        );
      });
      await tester.runAsync(runtime.account.refreshCredential);
      await tester.pumpAndSettle();
      expect(owners.isCurrentTicket(ticket), isTrue);
      expect(old.owner!.isActive, isTrue);
      expect(resourceRetired, isFalse);
      await tester.runAsync(() async {
        runtime.account.remoteDeletion!.complete();
        await Future<void>.delayed(Duration.zero);
      });
      expect(resourceRetired, isTrue);
      expect(old.owner!.isActive, isFalse);
      expect(owners.isFenced(_alice), isTrue);
      expect(await tester.runAsync(marker.exists), isTrue);
      await tester.runAsync(() async {
        resourceClose.complete();
        await deletion;
      });
      expect(await tester.runAsync(marker.exists), isFalse);
      expect(runtime.account.currentUser?.id, _alice);
      await tester.pumpAndSettle();
      expect(find.byType(OnboardingGate), findsNothing);
      await tester.pumpWidget(const SizedBox.shrink());
    },
  );

  testWidgets(
    'secondary auth stream error retires resources without fresh admission',
    (tester) async {
      final _Runtime runtime = _Runtime();
      final LissomOwnerRegistry owners = LissomOwnerRegistry(
        canonicalSupportDirectory: directory,
      );
      await _mount(tester, runtime, owners);
      final LissomLocalScope old = tester
          .widget<OnboardingGate>(find.byType(OnboardingGate))
          .localScope;
      final _Source source = _Source();
      await _capture(tester, source);
      runtime.account.changes.addError(StateError('fixture auth stream error'));
      expect(old.owner!.isActive, isFalse);
      expect(source.retired, isTrue);
      expect(source.disposals, 1);
      source.closeBarrier.complete();
      await tester.pumpAndSettle();
      // This secondary listener changes only admission. The canonical runtime
      // remains the sole authority for identity and later retry verification.
      expect(runtime.phase.value, MotionIdentityPhase.verified);
      expect(find.byType(OnboardingGate), findsNothing);
      await _hostVisible(
        tester,
        find.byKey(const Key('lissom.owner.closed')),
        admissionClosed: true,
      );
      expect(find.byKey(const Key('lissom.owner.closed')), findsOneWidget);
      expect(tester.takeException(), isNull);
      runtime.phase.value = MotionIdentityPhase.unavailable;
      runtime.phase.value = MotionIdentityPhase.verified;
      await tester.pumpAndSettle();
      await _hostVisible(tester, find.byType(OnboardingGate));
      final LissomLocalScope fresh = tester
          .widget<OnboardingGate>(find.byType(OnboardingGate))
          .localScope;
      expect(fresh.lifetimeKey, isNot(old.lifetimeKey));
      await tester.pumpWidget(const SizedBox.shrink());
      await source.eventsController.close();
    },
  );

  testWidgets(
    'held account callback cannot switch to replacement same-UUID registry',
    (tester) async {
      final _Runtime oldRuntime = _Runtime();
      final LissomOwnerRegistry oldOwners = LissomOwnerRegistry(
        canonicalSupportDirectory: directory,
      );
      await _mount(tester, oldRuntime, oldOwners);
      final LissomApp app = tester.widget<LissomApp>(find.byType(LissomApp));
      final BuildContext context = tester.element(find.byType(HomeScreen));
      unawaited(
        Navigator.of(context).push<void>(
          MaterialPageRoute<void>(
            builder: (BuildContext pageContext) =>
                app.accountRouteBuilder!(pageContext, kLissomMotionAppId),
          ),
        ),
      );
      await tester.pumpAndSettle();
      oldRuntime.account.remoteDeletion = Completer<void>();
      oldRuntime.account.deletionSettled = Completer<void>();
      await tester.ensureVisible(find.text('Delete Motion account'));
      await tester.tap(find.text('Delete Motion account'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Delete account'));
      await tester.pump();
      expect(oldRuntime.account.deleteCalls, 1);
      final _Runtime replacement = _Runtime();
      final LissomOwnerRegistry newOwners = LissomOwnerRegistry(
        canonicalSupportDirectory: directory,
      );
      await _mount(tester, replacement, newOwners);
      final LissomLocalScope fresh = tester
          .widget<OnboardingGate>(find.byType(OnboardingGate))
          .localScope;
      final File marker = fresh.file(directory, LissomLocalFile.sessions);
      await tester.runAsync(() async {
        await marker.parent.create(recursive: true);
        await marker.writeAsString('replacement-registry same-UUID data');
      });
      oldRuntime.account.remoteDeletion!.complete();
      await tester.pumpAndSettle();
      expect(oldRuntime.account.deletionSettled!.isCompleted, isTrue);
      expect(oldRuntime.account.deletionError, isA<LissomCleanupConflict>());
      expect(fresh.owner!.isActive, isTrue);
      expect(
        await tester.runAsync(marker.readAsString),
        'replacement-registry same-UUID data',
      );
      expect(replacement.account.currentUser?.id, _alice);
      await tester.pumpWidget(const SizedBox.shrink());
    },
  );

  testWidgets(
    'guest offline course remains available with no camera or paid flow',
    (tester) async {
      final _Runtime runtime = _Runtime(
        initialPhase: MotionIdentityPhase.signedOut,
      );
      runtime.userId.value = null;
      runtime.account.user = null;
      final LissomOwnerRegistry owners = LissomOwnerRegistry(
        canonicalSupportDirectory: directory,
      );
      await _mount(tester, runtime, owners);
      final LissomLocalScope scope = tester
          .widget<OnboardingGate>(find.byType(OnboardingGate))
          .localScope;
      expect(scope.isGuest, isTrue);
      expect(scope.ownerKey, 'guest');
      expect(find.byType(HomeScreen), findsOneWidget);
      expect(find.byKey(HomeScreen.startMeasurementKey), findsNothing);
      expect(find.byType(LiveCaptureScreen), findsNothing);
      await tester.pumpWidget(const SizedBox.shrink());
    },
  );

  testWidgets(
    'already-guest auth error drains old owner then reopens guest preserving files',
    (tester) async {
      final _Runtime runtime = _Runtime(
        initialPhase: MotionIdentityPhase.signedOut,
      );
      runtime.userId.value = null;
      runtime.account.user = null;
      final LissomOwnerRegistry owners = LissomOwnerRegistry(
        canonicalSupportDirectory: directory,
      );
      await _mount(tester, runtime, owners);
      final LissomLocalScope old = tester
          .widget<OnboardingGate>(find.byType(OnboardingGate))
          .localScope;
      final _Source source = _Source();
      await _capture(tester, source);
      await tester.runAsync(() async {
        for (final LissomLocalFile kind in LissomLocalFile.values) {
          final File file = old.file(directory, kind);
          await file.parent.create(recursive: true);
          await file.writeAsString('guest-preserved:${kind.name}');
        }
      });
      runtime.account.changes.addError(
        StateError('fixture guest auth stream error'),
      );
      // Core's primary onError assigns the same canonical guest values here,
      // producing no notifier change: successful drain must still reopen guest.
      runtime.userId.value = null;
      runtime.phase.value = MotionIdentityPhase.signedOut;
      expect(old.owner!.isActive, isFalse);
      expect(old.owner!.journalWrites.isActive, isFalse);
      expect(source.retired, isTrue);
      expect(source.disposals, 1);
      await tester.pumpAndSettle();
      expect(find.byType(OnboardingGate), findsNothing);
      expect(find.byType(HomeScreen), findsNothing);
      await _hostVisible(
        tester,
        find.byKey(const Key('lissom.owner.closed')),
        admissionClosed: true,
      );
      expect(find.byKey(const Key('lissom.owner.closed')), findsOneWidget);
      source.closeBarrier.complete();
      await tester.pumpAndSettle();
      await _hostVisible(tester, find.byType(HomeScreen));
      final LissomLocalScope fresh = tester
          .widget<OnboardingGate>(find.byType(OnboardingGate))
          .localScope;
      expect(fresh.isGuest, isTrue);
      expect(fresh.ownerKey, old.ownerKey);
      expect(fresh.lifetimeKey, isNot(old.lifetimeKey));
      expect(fresh.owner!.isActive, isTrue);
      expect(old.owner!.isActive, isFalse);
      expect(source.disposals, 1);
      expect(find.byType(HomeScreen), findsOneWidget);
      expect(find.byKey(HomeScreen.startMeasurementKey), findsNothing);
      expect(tester.takeException(), isNull);
      await tester.runAsync(() async {
        for (final LissomLocalFile kind in LissomLocalFile.values) {
          expect(
            await old.file(directory, kind).readAsString(),
            'guest-preserved:${kind.name}',
          );
        }
      });
      await tester.pumpWidget(const SizedBox.shrink());
      await source.eventsController.close();
    },
  );

  testWidgets(
    'already-guest auth error with failed close preserves files and blocks reopening',
    (tester) async {
      final _Runtime runtime = _Runtime(
        initialPhase: MotionIdentityPhase.signedOut,
      );
      runtime.userId.value = null;
      runtime.account.user = null;
      final LissomOwnerRegistry owners = LissomOwnerRegistry(
        canonicalSupportDirectory: directory,
      );
      await _mount(tester, runtime, owners);
      final LissomLocalScope old = tester
          .widget<OnboardingGate>(find.byType(OnboardingGate))
          .localScope;
      final _Source source = _Source();
      await _capture(tester, source);
      final File marker = old.file(directory, LissomLocalFile.sessions);
      await tester.runAsync(() async {
        await marker.parent.create(recursive: true);
        await marker.writeAsString('guest-close-failure-preserved');
      });
      runtime.account.changes.addError(
        StateError('fixture guest auth stream error'),
      );
      expect(old.owner!.isActive, isFalse);
      expect(source.retired, isTrue);
      source.closeBarrier.completeError(
        StateError('fixture guest native close failure'),
      );
      await tester.pumpAndSettle();
      expect(runtime.phase.value, MotionIdentityPhase.signedOut);
      expect(runtime.userId.value, isNull);
      expect(find.byType(OnboardingGate), findsNothing);
      expect(find.byType(HomeScreen), findsNothing);
      await _hostVisible(
        tester,
        find.byKey(const Key('lissom.owner.closed')),
        admissionClosed: true,
      );
      expect(find.byKey(const Key('lissom.owner.closed')), findsOneWidget);
      expect(find.textContaining('could not close'), findsOneWidget);
      expect(source.disposals, 1);
      expect(
        await tester.runAsync(marker.readAsString),
        'guest-close-failure-preserved',
      );
      expect(tester.takeException(), isNull);
      await tester.pumpWidget(const SizedBox.shrink());
      await source.eventsController.close();
    },
  );

  testWidgets(
    'retained shell route loaders keep their captured owner lifetime',
    (tester) async {
      final LissomOwnerRegistry owners = LissomOwnerRegistry(
        canonicalSupportDirectory: directory,
      );
      final LissomLocalScope old = owners.openScope(_alice);
      await tester.pumpWidget(
        MaterialApp(
          home: LissomShell(
            localScope: old,
            loader: () async => factsFromDisk(),
          ),
        ),
      );
      await tester.pumpAndSettle();
      final HomeScreen retained = tester.widget<HomeScreen>(
        find.byType(HomeScreen),
      );
      await old.owner!.retireAndDrain();
      final LissomLocalScope fresh = owners.openScope(_alice);
      await tester.pumpWidget(
        MaterialApp(
          home: LissomShell(
            localScope: fresh,
            loader: () async => factsFromDisk(),
          ),
        ),
      );
      await tester.pumpAndSettle();
      await expectLater(
        retained.sessionStoreLoader!(),
        throwsA(isA<LissomOwnerClosed>()),
      );
      await expectLater(
        retained.attemptValueStoreLoader!(),
        throwsA(isA<LissomOwnerClosed>()),
      );
      expect(
        tester
            .widget<LissomShell>(find.byType(LissomShell))
            .localScope
            .lifetimeKey,
        fresh.lifetimeKey,
      );
      await tester.pumpWidget(const SizedBox.shrink());
      owners.dispose();
    },
  );

  testWidgets(
    'actual account dialog cannot authorize a fresh same-UUID epoch',
    (tester) async {
      final _Account account = _Account();
      final LissomOwnerRegistry owners = LissomOwnerRegistry(
        canonicalSupportDirectory: directory,
      );
      owners.openScope(_alice);
      final LissomDeletionTicket ticket = owners.captureTicket(_alice);
      final LissomEpochAccountClient page = LissomEpochAccountClient(
        account: account,
        registry: owners,
        ticket: ticket,
      );
      await tester.pumpWidget(
        MaterialApp(
          home: MotionAccountPage(
            account: page,
            clearLocalData: (String id) => owners.eraseWithTicket(ticket, id),
          ),
        ),
      );
      await tester.pumpAndSettle();
      await tester.ensureVisible(find.text('Delete Motion account'));
      await tester.tap(find.text('Delete Motion account'));
      await tester.pumpAndSettle();
      owners.invalidateTickets(_alice);
      owners.openScope(_alice);
      account.event(AuthChangeEvent.signedIn);
      await tester.pump();
      await tester.tap(find.text('Delete account'));
      await tester.pumpAndSettle();
      expect(account.deleteCalls, 0);
      await tester.pumpWidget(const SizedBox.shrink());
      owners.dispose();
      account.close();
    },
  );

  test(
    'delayed client callback after fresh A reports conflict and preserves file marker',
    () async {
      final _Account account = _Account();
      final LissomOwnerRegistry owners = LissomOwnerRegistry(
        canonicalSupportDirectory: directory,
      );
      owners.openScope(_alice);
      final LissomDeletionTicket ticket = owners.captureTicket(_alice);
      final LissomEpochAccountClient page = LissomEpochAccountClient(
        account: account,
        registry: owners,
        ticket: ticket,
      );
      account.remoteDeletion = Completer<void>();
      final Future<void> deletion = page.deleteCommonAccount(
        afterRemoteDelete: (String id) => owners.eraseWithTicket(ticket, id),
      );
      final Future<void> pending = expectLater(
        deletion,
        throwsA(isA<LissomCleanupConflict>()),
      );
      owners.invalidateTickets(_alice);
      final LissomLocalScope fresh = owners.openScope(_alice);
      final File marker = fresh.file(directory, LissomLocalFile.sessions);
      await marker.parent.create(recursive: true);
      await marker.writeAsString('new-session-data');
      account.remoteDeletion!.complete();
      await pending;
      expect(await marker.readAsString(), 'new-session-data');
      expect(fresh.owner!.isActive, isTrue);
      expect(account.currentUser?.id, _alice);
      owners.dispose();
      account.close();
    },
  );

  test(
    'captured client callback after B erases A while B remains writable',
    () async {
      final _Account account = _Account();
      final LissomOwnerRegistry owners = LissomOwnerRegistry(
        canonicalSupportDirectory: directory,
      );
      final LissomLocalScope a = owners.openScope(_alice);
      final LissomDeletionTicket ticket = owners.captureTicket(_alice);
      final LissomEpochAccountClient page = LissomEpochAccountClient(
        account: account,
        registry: owners,
        ticket: ticket,
      );
      final File marker = a.file(directory, LissomLocalFile.sessions);
      await marker.parent.create(recursive: true);
      await marker.writeAsString('A');
      account.remoteDeletion = Completer<void>();
      final Future<void> deletion = page.deleteCommonAccount(
        afterRemoteDelete: (String id) => owners.eraseWithTicket(ticket, id),
      );
      account.user = _user(_bob);
      final LissomLocalScope b = owners.openScope(_bob);
      final File bFile = b.file(directory, LissomLocalFile.sessions);
      await bFile.parent.create(recursive: true);
      await bFile.writeAsString('B');
      account.remoteDeletion!.complete();
      await deletion;
      expect(await marker.exists(), isFalse);
      expect(await bFile.readAsString(), 'B');
      expect(b.owner!.isActive, isTrue);
      expect(account.currentUser?.id, _bob);
      owners.dispose();
      account.close();
    },
  );
}
