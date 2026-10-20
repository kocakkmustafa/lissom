// EXTERNAL DRAFT / COMPILE, FORMAT, ANALYZER AND SDK TESTS UNRUN.
// Target: public Core 8f38158e092c6c9fc60c8ff88ecef449802a259f only.
// Real Core delegates/pages/gate; only account/runtime IO is a public fixture.
import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lissom/app/lissom_locales.dart';
import 'package:motion_account/motion_account.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

const _probeKey = Key('core8f.actual.delegate');
const _ownerKey = ValueKey<String>('smoke:guest:stable-ticket');
const _paidKey = Key('core8f.closed.paid');
const _accountKey = Key('core8f.open.account');

// Independent literal expectations transcribed from immutable 8f, not produced
// by the implementation being tested. These are not fake localizations.
const _copy = <String, (String, String)>{
  'en': ('Motion account', 'Lissom membership'),
  'tr': ('Motion hesabı', 'Lissom üyeliği'),
  'es-419': ('Cuenta de Motion', 'Membresía de Lissom'),
  'pt-BR': ('Conta Motion', 'Assinatura do Lissom'),
  'de': ('Motion-Konto', 'Lissom-Mitgliedschaft'),
  'fr': ('Compte Motion', 'Abonnement Lissom'),
  'ja': ('Motionアカウント', 'Lissomのメンバーシップ'),
  'ar': ('حساب Motion', 'عضوية Lissom'),
};
const _deleteEnglish =
    'This deletes your shared account and access in all five apps, then erases local history in this app. Cancel any store subscription separately in your Apple or Google account.';
const _deleteArabic =
    'سيؤدي هذا إلى حذف حسابك المشترك وحقوق الوصول في التطبيقات الخمسة، ثم مسح السجل المحلي لهذا التطبيق. يجب إلغاء أي اشتراك في المتجر بشكل منفصل من حساب Apple أو Google.';

final class _MemoryPreference implements LocalePreferenceStore {
  _MemoryPreference(this.value);
  String? value;
  @override
  Future<String?> read() async => value;
  @override
  Future<void> write(String? tag) async {
    value = tag;
  }
}

Widget _installationApp(LissomLocaleController controller, Widget home) =>
    LissomLocaleHost(
      key: const Key('core8f.installation.host'),
      controller: controller,
      child: Builder(
        builder: (context) {
          final installation = LissomLocaleScope.maybeOf(context)!;
          return MaterialApp(
            locale: installation.locale,
            supportedLocales: MotionAccountLocalizations.supportedLocales,
            localizationsDelegates: MotionAccountLocalizations.delegates,
            localeResolutionCallback:
                MotionAccountLocalizations.localeResolutionCallback,
            home: home,
          );
        },
      ),
    );

/// Observe postmount real delegate state. No never-ending spinner settling and
/// no detached catalog parse is accepted as mounted localization readiness.
Future<void> _pumpUntil(
  WidgetTester tester,
  bool Function() condition,
  String reason,
) async {
  for (var frame = 0; frame < 100; frame++) {
    await tester.pump(const Duration(milliseconds: 20));
    if (condition()) {
      return;
    }
  }
  expect(condition(), isTrue, reason: reason);
}

class _PublicProbe extends StatefulWidget {
  const _PublicProbe({super.key});
  @override
  State<_PublicProbe> createState() => _PublicProbeState();
}

class _PublicProbeState extends State<_PublicProbe> {
  MotionAccountLocalizations? registered;
  MotionAccountLocalizations? selected;
  Locale? materialLocale;
  TextDirection? direction;
  @override
  Widget build(BuildContext context) {
    registered = Localizations.of<MotionAccountLocalizations>(
      context,
      MotionAccountLocalizations,
    );
    selected = MotionAccountLocalizations.of(context);
    materialLocale = Localizations.localeOf(context);
    direction = Directionality.of(context);
    return Scaffold(
      body: Column(
        children: [
          Text(selected!.text(MotionAccountString.accountTitle)),
          Text(selected!.membershipForApp('Lissom')),
        ],
      ),
    );
  }
}

class _GuestProbe extends StatefulWidget {
  const _GuestProbe({super.key});
  @override
  State<_GuestProbe> createState() => _GuestProbeState();
}

class _GuestProbeState extends State<_GuestProbe> {
  final lifetime = Object();
  @override
  Widget build(BuildContext context) => const Text('SMOKE_GUEST_CONTENT');
}

// Same public-interface fixture pattern as Core 8f account_localizations_test
// and Lissom account_native_contract_test. No real client/HTTP/session is opened.
class _FixtureSupabase implements SupabaseClient {
  const _FixtureSupabase();
  @override
  GoTrueClient get auth => const _FixtureAuth();
  @override
  dynamic noSuchMethod(Invocation invocation) => throw UnsupportedError(
    'Unexpected fixture call: ${invocation.memberName}',
  );
}

class _FixtureAuth implements GoTrueClient {
  const _FixtureAuth();
  @override
  Session? get currentSession => null;
  @override
  User? get currentUser => null;
  @override
  Stream<AuthState> get onAuthStateChange => const Stream.empty();
  @override
  dynamic noSuchMethod(Invocation invocation) => throw UnsupportedError(
    'Unexpected fixture call: ${invocation.memberName}',
  );
}

class _FixtureAccount implements MotionAccountClient {
  _FixtureAccount({this.signedIn = false});
  final bool signedIn;
  int userReads = 0;
  int membershipReads = 0;
  int deleteCalls = 0;
  @override
  SupabaseClient get supabase => const _FixtureSupabase();
  @override
  MotionApp get app => MotionApp.lissom;
  @override
  String get emailRedirectTo => 'com.yulalab.lissom://auth/callback';
  @override
  User? get currentUser {
    userReads++;
    return signedIn
        ? const User(
            id: 'consumer-copy-fixture',
            appMetadata: {},
            userMetadata: null,
            aud: 'authenticated',
            createdAt: '2026-10-20T00:00:00Z',
          )
        : null;
  }

  @override
  Stream<AuthState> get authChanges => const Stream.empty();
  @override
  Future<Map<String, dynamic>?> loadProfile() async => <String, dynamic>{
    'display_name': 'Fixture',
  };
  @override
  Future<bool> hasActiveMembership() async {
    membershipReads++;
    return false;
  }

  @override
  Future<void> deleteCommonAccount({
    Future<void> Function(String userId)? afterRemoteDelete,
  }) async {
    deleteCalls++;
    throw StateError('Copy-only fixture must not confirm account deletion');
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => throw UnsupportedError(
    'Unexpected fixture call: ${invocation.memberName}',
  );
}

class _PhaseRuntime implements MotionAccountRuntime {
  @override
  final _FixtureAccount account = _FixtureAccount();
  @override
  final phase = ValueNotifier(MotionIdentityPhase.signedOut);
  @override
  final userId = ValueNotifier<String?>(null);
  @override
  final passwordRecovery = ValueNotifier(false);
  @override
  bool get isPasswordRecovery => passwordRecovery.value;
  @override
  Listenable get identityVerification => phase;
  @override
  bool get isCurrentSessionVerified => false;
  bool _disposed = false;
  @override
  bool get isDisposed => _disposed;
  @override
  void dispose() {
    if (_disposed) {
      return;
    }
    _disposed = true;
    phase.dispose();
    userId.dispose();
    passwordRecovery.dispose();
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => throw UnsupportedError(
    'Unexpected fixture call: ${invocation.memberName}',
  );
}

class _PaidHarness extends StatelessWidget {
  const _PaidHarness({
    required this.account,
    required this.result,
    required this.onRoute,
    required this.onCleanup,
  });
  final _FixtureAccount account;
  final ValueNotifier<bool?> result;
  final VoidCallback onRoute;
  final VoidCallback onCleanup;
  @override
  Widget build(BuildContext context) => Scaffold(
    body: Column(
      children: [
        FilledButton(
          key: _paidKey,
          onPressed: () async {
            // Deliberately use the real default policy; do not force false here.
            result.value = await requireMotionPaidAccess(
              context,
              account: account,
              accountPageBuilder: (_) {
                onRoute();
                return const SizedBox.shrink();
              },
              membershipPageBuilder: (_) {
                onRoute();
                return const SizedBox.shrink();
              },
            );
          },
          child: const Text('CLOSED_PAID'),
        ),
        TextButton(
          key: _accountKey,
          onPressed: () {
            Navigator.of(context).push<void>(
              MaterialPageRoute<void>(
                builder: (_) => MotionAccountPage(
                  account: account,
                  clearLocalData: (_) async {
                    onCleanup();
                  },
                ),
              ),
            );
          },
          child: const Text('OPEN_ACCOUNT'),
        ),
      ],
    ),
  );
}

void main() {
  testWidgets('public 8f delegates follow actual Lissom installation selection', (
    tester,
  ) async {
    final controller = LissomLocaleController(store: _MemoryPreference('en'));
    await controller.initialize();
    addTearDown(() async {
      await tester.pumpWidget(const SizedBox.shrink());
      controller.dispose();
    });
    expect(MotionAccountLocalizations.supportedLocales, hasLength(8));
    expect(
      MotionAccountLocalizations.delegates,
      contains(MotionAccountLocalizations.delegate),
    );
    expect(
      MotionAccountLocalizations.localeFor(const Locale('es', 'MX')),
      const Locale('es', '419'),
    );
    expect(
      MotionAccountLocalizations.localeFor(const Locale('pt', 'PT')),
      const Locale('pt', 'BR'),
    );
    expect(
      MotionAccountLocalizations.localeFor(const Locale('it')),
      const Locale('en'),
      reason:
          '8f has eight locales; this does not accept the later 14-locale Core.',
    );
    expect(
      MotionAccountLocalizations.localeResolutionCallback(
        const Locale('ar'),
        const <Locale>[Locale('tr'), Locale('en')],
      ),
      const Locale('en'),
    );
    await tester.pumpWidget(
      _installationApp(controller, const _PublicProbe(key: _probeKey)),
    );
    _PublicProbeState? first;
    for (final tag in _copy.keys) {
      expect(await controller.select(tag), isTrue);
      final expectedLocale = lissomLocaleForTag(tag)!;
      final expected = _copy[tag]!;
      await _pumpUntil(
        tester,
        () {
          final elements = find.byKey(_probeKey).evaluate();
          if (elements.length != 1) {
            return false;
          }
          final state = tester.state<_PublicProbeState>(find.byKey(_probeKey));
          return state.registered != null &&
              identical(state.registered, state.selected) &&
              state.selected!.locale == expectedLocale &&
              state.materialLocale == expectedLocale &&
              state.selected!.text(MotionAccountString.accountTitle) ==
                  expected.$1;
        },
        'Actual mounted Core delegate must match saved installation locale $tag',
      );
      final state = tester.state<_PublicProbeState>(find.byKey(_probeKey));
      first ??= state;
      expect(
        state,
        same(first),
        reason: 'Changing language keeps child State.',
      );
      expect(
        state.direction,
        tag == 'ar' ? TextDirection.rtl : TextDirection.ltr,
      );
      expect(find.text(expected.$1), findsOneWidget);
      expect(find.text(expected.$2), findsOneWidget);
      expect(
        state.selected!.membershipForApp('Lissom{appName}'),
        expected.$2.replaceAll('Lissom', 'Lissom{appName}'),
      );
      expect(
        () => state.selected!.text(MotionAccountString.appMembership),
        throwsArgumentError,
      );
    }
    expect(tester.takeException(), isNull);
  });

  testWidgets(
    'real 8f nested gate inherits selection and retains guest State while blocked',
    (tester) async {
      tester.platformDispatcher.localesTestValue = const <Locale>[Locale('en')];
      addTearDown(tester.platformDispatcher.clearLocalesTestValue);
      final controller = LissomLocaleController(store: _MemoryPreference('tr'));
      final runtime = _PhaseRuntime();
      await controller.initialize();
      addTearDown(() async {
        await tester.pumpWidget(const SizedBox.shrink());
        runtime.dispose();
        controller.dispose();
      });
      await tester.pumpWidget(
        _installationApp(
          controller,
          MotionIdentityGate(
            runtime: runtime,
            child: const _GuestProbe(key: _ownerKey),
          ),
        ),
      );
      await _pumpUntil(
        tester,
        () => find.text('SMOKE_GUEST_CONTENT').evaluate().length == 1,
        'The initial synthetic guest must be admitted.',
      );
      final guest = tester.state<_GuestProbeState>(find.byKey(_ownerKey));
      final gateElement = tester.element(find.byType(MotionIdentityGate));
      runtime.phase.value = MotionIdentityPhase.verifying;
      await _pumpUntil(
        tester,
        () => find.text('Hesap doğrulanıyor…').evaluate().length == 1,
        'Manual TR, rather than system EN, must reach the actual nested blocker.',
      );
      expect(find.text('SMOKE_GUEST_CONTENT'), findsNothing);
      expect(
        tester.state(find.byKey(_ownerKey, skipOffstage: false)),
        same(guest),
      );
      expect(await controller.select('ar'), isTrue);
      await _pumpUntil(
        tester,
        () => find.text('جارٍ التحقّق من الحساب…').evaluate().length == 1,
        'A mounted blocked gate must follow a new parent locale.',
      );
      final checking = tester.element(find.text('جارٍ التحقّق من الحساب…'));
      final actual = Localizations.of<MotionAccountLocalizations>(
        checking,
        MotionAccountLocalizations,
      );
      expect(actual, isNotNull);
      expect(MotionAccountLocalizations.of(checking), same(actual));
      expect(actual!.locale, const Locale('ar'));
      expect(Directionality.of(checking), TextDirection.rtl);
      final nestedApp = find.descendant(
        of: find.byType(MotionIdentityGate),
        matching: find.byType(MaterialApp),
      );
      expect(tester.widget<MaterialApp>(nestedApp).locale, const Locale('ar'));
      expect(
        tester.element(find.byType(MotionIdentityGate)),
        same(gateElement),
      );
      runtime.phase.value = MotionIdentityPhase.unavailable;
      await _pumpUntil(
        tester,
        () =>
            find
                .text('تعذّر التحقّق من حسابك. تحقّق من الاتصال وحاول مجددًا.')
                .evaluate()
                .length ==
            1,
        'Unavailable copy must also use the selected Arabic locale.',
      );
      expect(await controller.select('ja'), isTrue);
      await _pumpUntil(
        tester,
        () =>
            find
                .text('アカウントを確認できませんでした。接続を確認して、もう一度お試しください。')
                .evaluate()
                .length ==
            1,
        'An already-open unavailable blocker must update to Japanese.',
      );
      expect(tester.widget<MaterialApp>(nestedApp).locale, const Locale('ja'));
      expect(
        tester.state(find.byKey(_ownerKey, skipOffstage: false)),
        same(guest),
      );
      runtime.phase.value = MotionIdentityPhase.signedOut;
      await _pumpUntil(
        tester,
        () => find.text('SMOKE_GUEST_CONTENT').evaluate().length == 1,
        'Returning to the synthetic guest must reveal its existing State.',
      );
      expect(tester.state(find.byKey(_ownerKey)), same(guest));
      expect(runtime.userId.value, isNull);
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets(
    '8f default paid false and retained deletion copy keep store cancellation separate',
    (tester) async {
      final controller = LissomLocaleController(store: _MemoryPreference('en'));
      final account = _FixtureAccount(signedIn: true);
      final result = ValueNotifier<bool?>(null);
      var routes = 0;
      var cleanups = 0;
      await controller.initialize();
      addTearDown(() async {
        await tester.pumpWidget(const SizedBox.shrink());
        result.dispose();
        controller.dispose();
      });
      expect(motionPaidFeaturesAvailable, isFalse);
      await tester.pumpWidget(
        _installationApp(
          controller,
          _PaidHarness(
            account: account,
            result: result,
            onRoute: () => routes++,
            onCleanup: () => cleanups++,
          ),
        ),
      );
      await _pumpUntil(
        tester,
        () => find.byKey(_paidKey).evaluate().length == 1,
        'Real Material/Core delegates must mount before interaction.',
      );
      await tester.tap(find.byKey(_paidKey));
      await _pumpUntil(
        tester,
        () =>
            result.value == false &&
            find
                    .text('This session will open in a future update.')
                    .evaluate()
                    .length ==
                1,
        'The real default paid=false branch returns false and shows existing copy.',
      );
      expect(routes, 0);
      expect(
        account.userReads,
        0,
        reason: 'Closed sales must stop before auth/membership reads.',
      );
      expect(account.membershipReads, 0);
      expect(account.deleteCalls, 0);
      await tester.tap(find.byKey(_accountKey));
      await _pumpUntil(
        tester,
        () =>
            find.byType(MotionAccountPage).evaluate().length == 1 &&
            find.text('Delete Motion account').evaluate().length == 1,
        'Mount the real public account page using only in-memory account IO.',
      );
      await tester.ensureVisible(find.text('Delete Motion account'));
      await tester.tap(find.text('Delete Motion account'));
      await _pumpUntil(
        tester,
        () => find.text(_deleteEnglish).evaluate().length == 1,
        'Real account deletion dialog must explain separate store cancellation.',
      );
      final dialogElement = tester.element(find.byType(AlertDialog));
      expect(await controller.select('ar'), isTrue);
      await _pumpUntil(
        tester,
        () => find.text(_deleteArabic).evaluate().length == 1,
        'An open real deletion dialog must re-localize without losing its warning.',
      );
      expect(tester.element(find.byType(AlertDialog)), same(dialogElement));
      expect(
        Directionality.of(tester.element(find.text(_deleteArabic))),
        TextDirection.rtl,
      );
      await tester.tap(find.text('إلغاء'));
      await _pumpUntil(
        tester,
        () => find.byType(AlertDialog).evaluate().isEmpty,
        'Cancel must close the dialog without deletion or local cleanup.',
      );
      expect(account.deleteCalls, 0);
      expect(cleanups, 0);
      expect(routes, 0);
      expect(account.membershipReads, 0);
      expect(tester.takeException(), isNull);
    },
  );
}
