// EXTERNAL DRAFT. COMPILE / FORMAT / ANALYZER / SDK EXECUTION UNRUN.
// Full production host + presentation path, with the existing public intent
// runtime fixture pattern. This is not real-provider/Session-proof acceptance.
import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:lissom/app/home_screen.dart';
import 'package:lissom/app/live_capture_screen.dart';
import 'package:lissom/app/lissom_appearance.dart';
import 'package:lissom/app/lissom_locales.dart';
import 'package:lissom/app/lissom_localizations.dart';
import 'package:lissom/app/lissom_presentation_host.dart';
import 'package:lissom/app/local_account_bridge.dart';
import 'package:lissom/app/local_owner.dart';
import 'package:lissom/app/local_owner_context.dart';
import 'package:lissom/app/onboarding_gate.dart';
import 'package:lissom/app/onboarding_store.dart';
import 'package:lissom/app/profile_screen.dart';
import 'package:lissom/app/shell.dart';
import 'package:lissom/main.dart';
import 'package:motion_account/motion_account.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'support/facts_from_disk.dart';

const _id = 'aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaaa';
const _draft = 'Host route draft survives appearance and language';
User _user() => const User(id: _id, appMetadata: {}, userMetadata: null,
  aud: 'authenticated', createdAt: '2026-10-20T00:00:00Z',
  email: 'fixture@example.invalid');
Map<String, dynamic> _session() => <String, dynamic>{
  'access_token': 'public-fixture-token', 'refresh_token': 'public-fixture-refresh',
  'token_type': 'bearer', 'expires_at': 4102444800, 'user': _user().toJson(),
};

/// Reduced owner_host_recovery_test pattern. HTTP is entirely MockClient;
/// its public Session is a UI intent fixture, not a provider verification.
final class _IntentAccount extends MotionAccountClient {
  _IntentAccount(List<String> requests) : super(
    supabase: SupabaseClient('https://fixture.invalid', 'public-fixture',
      authOptions: const AuthClientOptions(autoRefreshToken: false),
      httpClient: MockClient((request) async {
        requests.add('${request.method} ${request.url.path}');
        return http.Response(jsonEncode(request.url.path.endsWith('/token')
          ? _session() : request.url.path.endsWith('/user')
            ? _user().toJson() : <String, dynamic>{}), 200,
          headers: const <String, String>{'content-type': 'application/json'});
      })),
    app: MotionApp.lissom, emailRedirectTo: kLissomAuthRedirect,
  ) {
    initialSessionReady = supabase.auth.setInitialSession(jsonEncode(_session()));
  }
  late final Future<void> initialSessionReady;
  int profileReads = 0;
  int membershipReads = 0;
  final savedNames = <String>[];
  @override
  Future<Map<String, dynamic>?> loadProfile() async {
    profileReads++;
    return <String, dynamic>{'display_name': 'Initial host fixture'};
  }
  @override
  Future<void> saveDisplayName(String value) async {
    savedNames.add(value);
  }
  @override
  Future<bool> hasActiveMembership() async {
    membershipReads++;
    return false;
  }
}

final class _IntentRuntime implements MotionAccountRuntime {
  _IntentRuntime(List<String> requests) : account = _IntentAccount(requests);
  @override
  final _IntentAccount account;
  @override
  final phase = ValueNotifier(MotionIdentityPhase.verified);
  @override
  final userId = ValueNotifier<String?>(_id);
  @override
  final passwordRecovery = ValueNotifier(false);
  @override
  bool get isPasswordRecovery => passwordRecovery.value;
  @override
  Listenable get identityVerification => phase;
  bool _disposed = false;
  Future<void>? _closed;
  Future<void> get closed => _closed ?? Future<void>.value();
  @override
  bool get isDisposed => _disposed;
  @override
  bool get isCurrentSessionVerified => !_disposed &&
    phase.value == MotionIdentityPhase.verified &&
    account.supabase.auth.currentSession?.user.id == userId.value;
  @override
  Future<void> refreshIdentity() async {
    phase.value = MotionIdentityPhase.verified;
  }
  @override
  void dispose() {
    if (_disposed) {
      return;
    }
    _disposed = true;
    phase.dispose();
    userId.dispose();
    passwordRecovery.dispose();
    _closed = account.supabase.dispose();
    // Observe disposal now; the test still awaits the original result later.
    _closed!.ignore();
  }
  @override
  dynamic noSuchMethod(Invocation invocation) =>
    throw UnsupportedError('Unexpected intent fixture call: ${invocation.memberName}');
}

final class _AcceptedOnboarding implements OnboardingStore {
  _AcceptedOnboarding(this.owner);
  final LissomLocalOwner owner;
  @override
  Future<OnboardingProfile> read() => owner.io.run(() async =>
    const OnboardingProfile(completed: true, ageBand: 'u40'));
  @override
  Future<void> write(OnboardingProfile value) async {
    throw StateError('Completed onboarding must not write in this scenario');
  }
}

/// Real file stores, with one controlled pre-write admission barrier each.
/// Releasing a barrier is not cancellation, retry or a mocked persistence win.
final class _GatedLocaleStore implements LocalePreferenceStore {
  _GatedLocaleStore(this.file);
  final FileLocalePreferenceStore file;
  final release = Completer<void>();
  int writes = 0;
  @override
  Future<String?> read() => file.read();
  @override
  Future<void> write(String? tag) async {
    writes++;
    await release.future;
    await file.write(tag);
  }
}
final class _GatedAppearanceStore implements AppearancePreferenceStore {
  _GatedAppearanceStore(this.file);
  final FileAppearancePreferenceStore file;
  final release = Completer<void>();
  int writes = 0;
  @override
  Future<ThemeMode> read() => file.read();
  @override
  Future<void> write(ThemeMode mode) async {
    writes++;
    await release.future;
    await file.write(mode);
  }
}

Future<void> _wait(WidgetTester tester, bool Function() ready, String reason) async {
  final elapsed = Stopwatch()..start();
  while (elapsed.elapsed < const Duration(seconds: 10)) {
    await tester.runAsync(() => Future<void>.delayed(const Duration(milliseconds: 20)));
    await tester.pump(const Duration(milliseconds: 20));
    if (ready()) {
      return;
    }
  }
  fail(reason);
}
bool _accountReady(WidgetTester tester, String tag, Brightness brightness) {
  final elements = find.byType(MotionAccountPage).evaluate();
  if (elements.length != 1) {
    return false;
  }
  final context = elements.single;
  final app = LissomLocalizations.maybeOf(context);
  final core = Localizations.of<MotionAccountLocalizations>(context, MotionAccountLocalizations);
  return app != null && app.catalogAvailable && app.tag == tag &&
    core != null && identical(core, MotionAccountLocalizations.of(context)) &&
    core.locale.toLanguageTag() == tag &&
    Localizations.localeOf(context).toLanguageTag() == tag &&
    Theme.of(context).brightness == brightness;
}
Future<void> _tapVisible(WidgetTester tester, Finder finder) async {
  await tester.ensureVisible(finder);
  await tester.pump();
  expect(finder.hitTestable(), findsOneWidget);
  await tester.tap(finder);
  await tester.pump();
}

void main() {
  late Directory directory;
  setUp(() async {
    directory = await Directory.systemTemp.createTemp('lissom-host-presentation-');
  });
  tearDown(() async {
    if (await directory.exists()) {
      await directory.delete(recursive: true);
    }
  });
  testWidgets('real host keeps owner and account route until and after persisted theme plus locale change', (tester) async {
    tester.platformDispatcher.platformBrightnessTestValue = Brightness.light;
    addTearDown(tester.platformDispatcher.clearPlatformBrightnessTestValue);
    final localeFile = FileLocalePreferenceStore(File('${directory.path}/preferences/locale.json'));
    final appearanceFile = FileAppearancePreferenceStore(File('${directory.path}/preferences/appearance.json'));
    final localeStore = _GatedLocaleStore(localeFile);
    final appearanceStore = _GatedAppearanceStore(appearanceFile);
    final locale = LissomLocaleController(store: localeStore);
    final appearance = LissomAppearanceController(store: appearanceStore);
    final requests = <String>[];
    final runtime = _IntentRuntime(requests);
    final owners = LissomOwnerRegistry(canonicalSupportDirectory: directory);
    Future<bool>? localeSave;
    Future<bool>? appearanceSave;
    LissomLocalOwner? admittedOwner;
    var mountedHost = false;
    addTearDown(() async {
      final cleanupErrors = <(String, Object, StackTrace)>[];
      // Release and observe each admitted write, even if the other one fails.
      // A late result here is cleanup only, never a persistence-success oracle.
      try {
        await tester.runAsync(() async {
          if (!localeStore.release.isCompleted) {
            localeStore.release.complete();
          }
          if (!appearanceStore.release.isCompleted) {
            appearanceStore.release.complete();
          }
          for (final (label, write) in <(String, Future<bool>?)>[
            ('locale write', localeSave), ('appearance write', appearanceSave),
          ]) {
            if (write != null) {
              try {
                await write.timeout(const Duration(seconds: 5));
              } catch (error, stack) {
                cleanupErrors.add((label, error, stack));
              }
            }
          }
        });
      } catch (error, stack) {
        cleanupErrors.add(('pending-write async zone', error, stack));
      }
      try {
        await tester.pumpWidget(const SizedBox.shrink());
      } catch (error, stack) {
        cleanupErrors.add(('production host unmount', error, stack));
      }
      // A mounted production host owns runtime/registry disposal. Before mount,
      // this fixture owns both; each disposal must still get its own attempt.
      if (!mountedHost) {
        try {
          runtime.dispose();
        } catch (error, stack) {
          cleanupErrors.add(('unmounted runtime dispose', error, stack));
        }
        try {
          owners.dispose();
        } catch (error, stack) {
          cleanupErrors.add(('unmounted registry dispose', error, stack));
        }
      }
      try {
        await tester.runAsync(() async {
          try {
            await runtime.closed.timeout(const Duration(seconds: 5));
          } catch (error, stack) {
            cleanupErrors.add(('runtime shutdown', error, stack));
          }
          try {
            await admittedOwner?.retireAndDrain();
          } catch (error, stack) {
            cleanupErrors.add(('admitted owner drain', error, stack));
          }
        });
      } catch (error, stack) {
        cleanupErrors.add(('shutdown async zone', error, stack));
      } finally {
        try {
          locale.dispose();
        } catch (error, stack) {
          cleanupErrors.add(('locale controller dispose', error, stack));
        } finally {
          try {
            appearance.dispose();
          } catch (error, stack) {
            cleanupErrors.add(('appearance controller dispose', error, stack));
          }
        }
      }
      if (cleanupErrors.isNotEmpty) {
        final (_, firstError, firstStack) = cleanupErrors.first;
        try {
          if (cleanupErrors.length > 1) {
            final additional = cleanupErrors.skip(1).map((failure) =>
              '${failure.$1}: ${failure.$2}\n${failure.$3}').join('\n');
            FlutterError.reportError(FlutterErrorDetails(
              exception: FlutterError('Additional teardown failures:\n$additional'),
              context: ErrorDescription('while cleaning the host presentation fixture'),
            ));
          }
        } finally {
          Error.throwWithStackTrace(firstError, firstStack);
        }
      }
    });
    await tester.runAsync(() async {
      await localeFile.write('en');
      await appearanceFile.write(ThemeMode.light);
      await Future.wait<void>(<Future<void>>[
        locale.initialize(), appearance.initialize(), runtime.account.initialSessionReady,
      ]).timeout(const Duration(seconds: 5));
      for (final tag in <String>['en', 'ar']) {
        final raw = await rootBundle.loadString('config/l10n/$tag.json')
          .timeout(const Duration(seconds: 5));
        expect(LissomLocalizations.parse(raw, tag).catalogAvailable, isTrue);
      }
    });
    expect(runtime.account.supabase.auth.currentSession?.user.id, _id);
    expect(motionPaidFeaturesAvailable, isFalse);
    var cameraInvocations = 0;
    var factsLoads = 0;
    await tester.pumpWidget(LissomAppearanceHost(controller: appearance,
      child: LissomLocaleHost(controller: locale,
        child: LissomPresentationHost(child: LissomAccountHost(
          runtime: runtime, owners: owners, measurementAvailable: false,
          factsLoader: () async {
            factsLoads++;
            return factsFromDisk();
          },
          onboardingLoader: (scope) async => _AcceptedOnboarding(scope.owner!),
          poseSourceLoader: () {
            cameraInvocations++;
            throw StateError('Camera construction is forbidden in this scenario');
          },
        )))));
    mountedHost = true;
    await _wait(tester, () => find.byType(HomeScreen).evaluate().length == 1 &&
      LissomLocalizations.maybeOf(tester.element(find.byType(HomeScreen)))?.catalogAvailable == true,
      'The actual host/home must mount with the actual catalog.');
    final hostState = tester.state(find.byType(LissomAccountHost));
    final presentationState = tester.state(find.byType(LissomPresentationHost));
    final appElement = tester.element(find.byType(LissomApp));
    final appWidget = tester.widget<LissomApp>(find.byType(LissomApp));
    final scope = appWidget.localScope;
    admittedOwner = scope.owner!;
    final owner = admittedOwner!;
    final epoch = owner.epoch;
    final lifetime = scope.lifetimeKey;
    final materialState = tester.state(find.byType(MaterialApp));
    final shellState = tester.state(find.byType(LissomShell));
    final onboardingState = tester.state(find.byType(OnboardingGate));
    final materialKey = tester.widget<MaterialApp>(find.byType(MaterialApp)).key;
    final navigator = tester.state<NavigatorState>(find.byType(Navigator));
    final gateElement = tester.element(find.byType(MotionIdentityGate));
    expect(scope.userId, _id);
    expect(owner.isActive, isTrue);
    final profileTab = find.descendant(of: find.byType(NavigationBar), matching: find.text('Profile'));
    await _tapVisible(tester, profileTab);
    await _wait(tester, () => find.byKey(ProfileScreen.accountEntryKey).evaluate().length == 1,
      'The real Profile account entry must mount.');
    await _tapVisible(tester, find.byKey(ProfileScreen.accountEntryKey));
    await _wait(tester, () => _accountReady(tester, 'en', Brightness.light) &&
      find.byType(TextField).evaluate().length == 1 &&
      tester.widget<TextField>(find.byType(TextField)).controller!.text == 'Initial host fixture',
      'The real account route and profile read must be ready.');
    final accountState = tester.state(find.byType(MotionAccountPage));
    final route = ModalRoute.of(tester.element(find.byType(MotionAccountPage)))!;
    final factsBefore = factsLoads;
    final requestsBefore = requests.toList();
    await tester.enterText(find.byType(TextField), _draft);
    await tester.pump();
    void expectLifetime() {
      expect(tester.state(find.byType(LissomAccountHost)), same(hostState));
      expect(tester.state(find.byType(LissomPresentationHost)), same(presentationState));
      expect(tester.element(find.byType(LissomApp)), same(appElement));
      expect(tester.state(find.byType(MaterialApp)), same(materialState));
      expect(tester.state(find.byType(LissomShell, skipOffstage: false)), same(shellState));
      expect(tester.state(find.byType(OnboardingGate, skipOffstage: false)), same(onboardingState));
      expect(tester.widget<MaterialApp>(find.byType(MaterialApp)).key, materialKey);
      expect(tester.state<NavigatorState>(find.byType(Navigator)), same(navigator));
      expect(ModalRoute.of(tester.element(find.byType(MotionAccountPage))), same(route));
      expect(route.isCurrent, isTrue);
      expect(navigator.canPop(), isTrue);
      expect(tester.element(find.byType(MotionIdentityGate)), same(gateElement));
      expect(tester.state(find.byType(MotionAccountPage)), same(accountState));
      final currentScope = tester.widget<LissomApp>(find.byType(LissomApp)).localScope;
      expect(currentScope, same(scope));
      expect(currentScope.owner, same(owner));
      expect(currentScope.lifetimeKey, lifetime);
      expect(owner.epoch, epoch);
      expect(owner.isActive, isTrue);
      expect(LissomOwnerContext.maybeOf(tester.element(find.byType(MotionAccountPage))), same(owner));
      expect(tester.widget<TextField>(find.byType(TextField)).controller!.text, _draft);
      expect(runtime.account.savedNames, isEmpty);
      expect(runtime.account.profileReads, 1);
      expect(runtime.account.membershipReads, 0);
      expect(cameraInvocations, 0);
      expect(factsLoads, factsBefore);
      expect(requests, requestsBefore);
      expect(find.byType(MotionMembershipPage), findsNothing);
      expect(find.byType(LiveCaptureScreen), findsNothing);
    }
    // Start in the real async zone: file IO and its completion are not replaced
    // with fake data or considered finished by pumpAndSettle.
    await tester.runAsync(() async {
      localeSave = locale.select('ar');
      appearanceSave = appearance.select(ThemeMode.dark);
    });
    await tester.pump();
    expect(locale.isSaving, isTrue);
    expect(appearance.isSaving, isTrue);
    expect(localeStore.writes, 1);
    expect(appearanceStore.writes, 1);
    expect(locale.tag, 'en');
    expect(appearance.mode, ThemeMode.light);
    expect(_accountReady(tester, 'en', Brightness.light), isTrue);
    expect(Localizations.localeOf(tester.element(find.byType(LissomAccountHost))), const Locale('en'));
    expect(Theme.of(tester.element(find.byType(LissomAccountHost))).brightness, Brightness.light);
    expectLifetime();
    final beforeValues = await tester.runAsync(() async =>
      (await localeFile.read(), await appearanceFile.read()));
    expect(beforeValues, ('en', ThemeMode.light));
    await tester.runAsync(() async {
      localeStore.release.complete();
      appearanceStore.release.complete();
      expect(await localeSave!.timeout(const Duration(seconds: 5)), isTrue);
      expect(await appearanceSave!.timeout(const Duration(seconds: 5)), isTrue);
    });
    await _wait(tester, () => _accountReady(tester, 'ar', Brightness.dark) &&
      Localizations.localeOf(tester.element(find.byType(LissomAccountHost))) == const Locale('ar') &&
      Theme.of(tester.element(find.byType(LissomAccountHost))).brightness == Brightness.dark,
      'After actual successful persistence the same account route must use AR/dark.');
    expectLifetime();
    expect(find.text('حساب Motion'), findsOneWidget);
    expect(Directionality.of(tester.element(find.byType(MotionAccountPage))), TextDirection.rtl);
    expect(localeStore.writes, 1);
    expect(appearanceStore.writes, 1);
    final afterValues = await tester.runAsync(() async =>
      (await FileLocalePreferenceStore(localeFile.file).read(),
       await FileAppearancePreferenceStore(appearanceFile.file).read()));
    expect(afterValues, ('ar', ThemeMode.dark));
    final save = find.widgetWithText(FilledButton, 'حفظ الملف الشخصي');
    await _tapVisible(tester, save);
    await _wait(tester, () => runtime.account.savedNames.length == 1 &&
      find.text('تم حفظ الملف الشخصي.').evaluate().length == 1,
      'Only the explicit Save must submit the retained exact profile payload.');
    expect(runtime.account.savedNames, <String>[_draft]);
    expect(tester.state(find.byType(MotionAccountPage)), same(accountState));
    expect(ModalRoute.of(tester.element(find.byType(MotionAccountPage))), same(route));
    expect(owner.isActive, isTrue);
    expect(cameraInvocations, 0);
    expect(runtime.account.membershipReads, 0);
    expect(requests, requestsBefore);
    await tester.pump(const Duration(milliseconds: 100));
    expect(runtime.account.savedNames, <String>[_draft], reason: 'No second save follows the presentation rebuild.');
    expect(tester.takeException(), isNull);
  });
}
